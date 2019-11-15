//
//  AuthConstants.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 3/17/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation

public class AuthConstants {
    public static let authEmailKey = "authEmailKey"
    public static let resultToken = "token"
    public static let userKey = "userKey"
    public static let companyKey = "companyKey"
    public static let resultRefreshToken = "refreshToken"
    public static let resultError = "error"
    public static let resultExpires = "expires"
    public static let resultTokenType = "tokenType"
    public static let resultMagicTokenType = "magic"
    public static let resultPasswordTokenType = "password"
    public static let resultPasswordlessToken = "passwordless"
    public static let resultUniversalLoginTokenType = "universal"
    public static let universalLoginRequired = "Login required"
    public static let resultUnknownError = "Unknown Error"
    public static let dateFormatUTC = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    public static let tokenClaim = "https://mobile.meltwater.com/mw_token"
    public static let resutAccessToken = "accessToken"
    public static let resultEmail = "email"
    public static let resultFullName = "fullName"
    public static let resultFirstName = "firstName"
    public static let resultLastName = "lastName"
    public static let resultLang = "lang"
    public static let resultUserId = "userId"
    public static let resultCompanyId = "companyId"
    public static let resultJobTitle = "jobTitle"
    public static let resultCustomer = "customer"
    public static let resultGermanPremiumContent = "germanPremiumContent"
    public static let resultUsPremiumContent = "usPremiumContent"
    public static let resultLoginUrl = "loginURL"
    public static let requestIdToken = "idToken"
    public static let requestAuth0Type = "auth0"
    //
    static let mwUsersAuthPath = "mobile-bff/user-service/v1/users/authenticate"
    static let mwUsersRefreshTokenPath = "mobile-bff/user-service/v1/users/refreshToken"
    static let mwUsersSwitchCompanyPath = "mobile-bff/user-service/v1/user/switchCompany"
    static let mwCompanyByUserPath = "mobile-bff/user-service/v1/company/byUser"
    static let externalUsersAuthPath = "mobile-emp-bff/user-service/v1/external_users"
    static let mwUsersSSOIdp = "mobile-bff/user-service/v1/sso/idp"
    //static let mwUsersSSOIdp = "user-service/v1/sso/idp"
    static let mwUsersSSOUsers = "mobile-bff/user-service/v1/sso/users"
    static let mwUsersPath = "mobile-bff/user-service/v1/users"
    static let scopeValues = "openid profile offline_access"
    static let reqParamPrompt = "prompt"
    static let promptNone = "none"
    static let reqParamEmail = "email"
    static let reqAuthParams = "authParams"
    static let reqParamUserName = "username"
    static let reqParamPassword = "password"
    static let reqParamGrantType = "grant_type"
    static let reqParamClientId = "client_id"
    static let reqParamRealm = "realm"
    static let reqParamScope = "scope"
    static let reqParamSend = "send"
    static let reqParamOpenId = "openid"
    static let reqParamProfile = "profile"
    static let reqParamState = "state"
    static let reqParamType = "type"
    static let reqParamOfflineAccess = "offline_access"
    static let auth0ResultIdToken = "id_token"
    static let auth0ResultRefreshToken = "refresh_token"
    static let auth0ResultAccessToken = "access_token"
    static let auth0ResultTokenType = "token_type"
    static let chineseSimplified = "zh_CN"
    static let chineseTrad = "zh_TW"
    static let english = "en"
    static let chineseLanguageIdentifierSimplified = "zh-Hans"
    static let chineseLanguageIdentifierTraditional = "zh-Hant"
}

extension Notification.Name {
    public static let loginResultNotification = Notification.Name("loginResultNotification")
    //static let refreshTokenNotification = Notification.Name("refreshTokenNotification")
}
