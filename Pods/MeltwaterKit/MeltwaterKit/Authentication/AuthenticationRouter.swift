//
//  AuthenticationRouter.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 11/1/19.
//  Copyright © 2019 Meltwater. All rights reserved.
//

import Foundation
import UIKit

public class AuthenticationRouter: AuthenticationRouterProtocol {
    static func initializeModule(view: AuthenticationViewProtocol?, interactor: AuthenticationInteractor) {
        let presenter = AuthenticationPresenter()
        view?.presenter = presenter
        presenter.view = view // Weak
        presenter.interactor = interactor
        interactor.presenter = presenter
    }
}
