//
//  NLFAnnotationView.swift
//  NLF
//
//  Created by Thinh Nguyen on 10/7/19.
//  Copyright © 2019 Propertin. All rights reserved.
//

import Foundation
import MapKit

class NLFAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            if let info = newValue as? NLFAnnotationViewModel {
                canShowCallout = true
                calloutOffset = CGPoint(x: -5, y: 5)
                image = UIImage(named: "certificate")
                let detailLabel = UILabel()
                detailLabel.numberOfLines = 0
                detailLabel.font = detailLabel.font.withSize(12)
                detailLabel.text = info.subtitle
                detailCalloutAccessoryView = detailLabel
            } else {
                image = UIImage(named: "spaceship")
            }
            
        }
    }
}
