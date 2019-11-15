//
//  NLFCell.swift
//  NLF
//
//  Created by Thinh Nguyen on 10/7/19.
//  Copyright © 2019 Propertin. All rights reserved.
//

import UIKit

class NLFCell: UITableViewCell {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
