//
//  DateOptionsCell.swift
//  Meltwater Mobile
//
//  Created by Carlos Duarte on 1/20/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation
import UIKit

class DateOptionsCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var daysLabel: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    class var nib: UINib {
        let bundle = MWTools.getBundle()
        return UINib(nibName: identifier, bundle: bundle)
    }
    
}
