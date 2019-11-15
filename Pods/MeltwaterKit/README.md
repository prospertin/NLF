# meltwater-kit
This iOS module is intended to host all the shared components used by Meltwater iOS applications. Use podfile to import the "MeltwaterKit" libraries. 

Example of podfile: 

    source 'https://github.com/meltwater/cocoapods-specs.git'
    source 'https://github.com/CocoaPods/Specs.git'

    use_frameworks!

    target 'MWKitExample' do
        pod 'Crashlytics'
        pod 'MeltwaterKit', '0.0.7'

    end

From 0.0.7, the libraries is divided into multiple sub modules: Authentication, Searches, Documents, Volumes.Networks.

    pod 'MeltwaterKit', '0.0.7' will include all.

You can import a specific sub-module:

    pod 'MeltwaterKit/Authentication', '0.0.7'
    
## Authentication module:
Encapsulate password and passwordless login. 

Add this Auth0.plist to your project:
	
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
	    <key>BffHost</key>
	    <string>http://development-backend.meltwater.net/</string>
	    <key>MWDBConnection</key>
	    <string>Username-Password-Authentication</string>
	    <key>Domain</key>
	    <string>meltwater-mobile.auth0.com</string>
	    <key>ClientId</key>
	    <string>muTxrF1z6xLSjLufrlPysewQiv8ETzXj</string>  <== REPLACE with the clientId of your app
        </dict>
        </plist>


### with password
Use legacy Gyda-token:

    /* Login with email/password */
    MWLoginService(authHost: bffBaseUrl).loginWithUser(login: "myEmail@somewhere.com", password: "myPassword")
    /* Add notification observer */
    NotificationCenter.default.addObserver(self, selector: #selector( loginResultNotificationHandler), name: .loginResultNotification, object: nil)
    ...
    
    @objc fileprivate func loginResultNotificationHandler(note: Notification) {
    /* note.userInfo is a NSDictionnary that contains the authentication payload or an Error
    */
        if let error = note.userInfo?[AuthConstants.resultError] as? Error {
            self.showAlert(error.localizedDescription)
        } else {
          let token = note.userInfo?["token"] 
           let user = note.userInfo?["user] as! NSDictionary
           let company = note.userInfo?["company"] as! NSDictionary
           let expires = note.userInfo?["expires"] as! String
           let success = note.userInfo?["success"] as! Bool
           .....
        }
         NotificationCenter.default.removeObserver(self)
    }

Use Auth0 Token:
    
    NotificationCenter.default.addObserver(self, selector: #selector( loginResultNotificationHandler), name: .loginResultNotification, object: nil)
    LoginService().loginWithUser(login: emailTextfield!.text!, password: pw)

Implement the loginResultNotificationHandle:

    fileprivate func loginResultNotificationHandler(note: Notification) {
        
        if let error = note.userInfo?[AuthConstants.resultError] as? Error {
            self.showAlert(error.localizedDescription)
        } else if let token = note.userInfo?[AuthConstants.resultToken] as? String {
            //Save token in Keychain
            KeychainDemo.saveToken(token: token)
            if let refreshToken = note.userInfo?[AuthConstants.resultRefreshToken] as? String {
                KeychainDemo.saveRefreshToken(token: refreshToken)
            }
            if let tokenType = note.userInfo?[AuthConstants.resultTokenType] as? String {
                KeychainDemo.saveTokenType(tokenType: tokenType)  // FOR DEMO ONLY. Doesn't have to save this in a keychain
            }
            debugPrint(token)

            self.showAlert(token)
        }
        NotificationCenter.default.removeObserver(self)
    }

### Login passwordless
Get the email from user input and call:

       MWLoginService(authHost: bffBaseUrl).startPasswordlessDeepLinkWith(email: "myEmail", magicLinkDelegate: self)
    
Implement the EmailLinkProtocol to handle the email result

    extension LoginViewController: EmailLinkProtocol {
        func onEmailSent() {
            DispatchQueue.main.async {
                self.showAlert("Email sent!")
            }
        }
        func onEmailFailure(error: Error) {
            let msg = error.localizedDescription
            self.showAlert("\(msg): \(error._code)")
        }
    }

In app delegate implement the applicationOpenUrl and addObserver to the .loginResultNotification the same way as for the password login.

    func application(_ application: UIApplication, open url: URL, 
                 sourceApplication: String?, annotation: Any) -> Bool {
        if (url.host == getAuth0Domain()) // "meltwater.eu.auth0.com"
        {
            NotificationCenter.default.addObserver(self, selector: #selector( loginNotificationHandler), name: .loginResultNotification, object: nil)
            return LoginService().openDeepLink(url: url, sourceApplication: sourceApplication)
        }
        return true
    }

### Web Authentication
Web authentication allows user to log in to the app and be log into an SSO session on the web browser (See Auth0 DOC for setting this up for an Auth0 application). From the app call this function to launch the browser and take the user to the SSO page:

	LoginService().webAuthentication()
	
To log out, this function should be calls. Pass the current view controller where the logout button was pressed as the presenter:

	LoginService().webAuthenticationLogout(presenter: UIViewController?)
	
If login or logout is successful, a callback deeplink is sent to the app. The app needs call the function webAuthenticationResume() to resume the login. If the login successfully resumes, the function returns true, the loginResultNotificationHandler() will be called as it is done for password or magic login. If the function returns false then either the resume failed, or the user has sussessful log out :

	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
           if (url.host == getAuth0Domain()) {
              if LoginService().webAuthenticationResume(open: url, options: options) == false {
	         // Error login or successful logout, take the user to the login screen.
                 KeychainDemo.deleteToken()
               	 KeychainDemo.deleteRefreshToken()
                // Remove the top existing Safari logout page -- may need to do some checking here
                window?.rootViewController?.dismiss(animated: false)
                let navController = createWebAuthNavigationViewController()
                window?.rootViewController?.present(navController, animated: true)
              }
    	   }
           return true
	}
	
Note that the deeplink for both login and logout is trigger by the scheme matching the bundle_id (e.g. com.meltwater.stream.mfm), so we you need to add this scheme to the Info.plist

### User Profile:
	To get user profile fields, use the AuthConstants below just like you get the token 
	Ex: let fullName = note.userInfo?[AuthConstants.resultTFullName] as? String
	public class AuthConstants {
		….
   		static let resultToken = "token"
    		static let resultRefreshToken = "refreshToken"
    		static let resutAccessToken = "accessToken"
    		static let resultError = "error"
    		static let resultExpires = "expires"
    		static let resultTokenType = "type"
    		static let resultPasswordlessToken = "passwordless"
    		static let resultEmail = "email"
    		static let resultFullName = "fullName"
    		static let resultFirstName = "firstName"
    		static let resultLastName = "lastName"
    		static let resultLang = "lang"
		….
	}

Check the MeltwaterKitDemo project out for a complete example.

## Wiki
https://github.com/meltwater/meltwater-ios-kit/wiki/DatePicker-Wiki
