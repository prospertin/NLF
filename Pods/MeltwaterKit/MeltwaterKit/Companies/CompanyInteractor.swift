//
//  CompanyInteractor.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/3/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation
import ObjectMapper

public class CompanyInteractor: CompanyInteractorInputProtocol {
    
    public var presenter: CompanyInteractorOutputProtocol?
    
    var companyService:MWCompanyService?
    var loginService:MWLoginService?
    
    public init(hostName: String) {
        companyService = MWCompanyService(authHost: hostName)
        loginService = MWLoginService(authHost: hostName)
    }
    //MARK: actions
    public func switchCompany(companyId: String) {
        if let token = MWKeychain.loadToken() {
            loginService?.switchCompany(companyId: companyId, authToken: token, delegate: self)
        }
    }
    
    public func getCompanies() {
        if let token = MWKeychain.loadToken(),
            let user = MWUserDefaults.getMappableObject(forKey: AuthConstants.userKey, type: UserModel.self) {
            companyService?.getCompaniesForUser(id: user.id, authToken: token, delegate: self)
        }
        presenter?.didGetCompanies(companies: [])
    }
}

extension CompanyInteractor: CompanyResultProtocol {
    //MARK: results
    public func onGetCompaniesSuccess(companies: [CompanyModel]) {
        presenter?.didGetCompanies(companies: companies)
    }
    
    public func onCompanyServiceFailure(error: Error) {
        presenter?.didGetCompaniesError(error: error)
    }
}

extension CompanyInteractor: AuthenticationResultProtocol {
    public func onAuthenticationSuccess(resultPayload: Dictionary<String, Any>) {
      if let account = Mapper<AccountModel>().map(JSON: resultPayload),
            let company = account.company {
            MWUserDefaults.saveMappableObject(obj: company, key: AuthConstants.companyKey)
            MWKeychain.saveToken(token: account.token)
        if let ts = account.expires as? Int64 {
                MWKeychain.saveExpires(expires: "\(ts/1000)")
                    presenter?.didSwitchCompany(error: nil)
            } else {
                presenter?.didSwitchCompany(error: AuthTokenError(code: 401, message: "Invalid Token"))
            }
        }
        presenter?.didSwitchCompany(error: nil)
    }
    
    public func onAuthenticationFailure(error: Error) {
        presenter?.didSwitchCompany(error: error)
    }
}
