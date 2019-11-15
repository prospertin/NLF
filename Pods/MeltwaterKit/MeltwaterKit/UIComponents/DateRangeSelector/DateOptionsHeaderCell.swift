//
//  DateOptionsHeaderCell.swift
//  Meltwater Mobile
//
//  Created by Carlos Duarte on 1/21/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation
import UIKit

class DateOptionsHeaderCell: UITableViewCell {
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    class var nib: UINib {
        let bundle = MWTools.getBundle()
        return UINib(nibName: identifier, bundle: bundle)
    }
    
}
