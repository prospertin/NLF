//
//  MWTools.swift
//  MeltwaterKit
//
//  Created by Kent Wang on 10/3/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import UIKit

public class MWTools: NSObject {
    // Call this method for bundle resources. Returns the MeltwaterKit bundle for other bundles. Returns nil if MeltwaterKit is current bundle (e.g. for MeltwaterKitDemo)
    public static func getBundle() -> Bundle? {
        let podBundle = Bundle(for: self)
        let bundleURL = podBundle.url(forResource: "MeltwaterKit", withExtension: "bundle")
        var bundle: Bundle?
        if let url = bundleURL {
            bundle = Bundle(url: url)
        }
        return bundle
    }
    
    public static func showAlert(_ msg: String?, on viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Status", message: msg ?? "Unknown Error", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController?.present(alert, animated: true, completion: nil)
        }
    }
}
