//
//  NLFViewModel.swift
//  NLF
//
//  Created by Thinh Nguyen on 10/5/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import Foundation
import MapKit

class RoutesViewModel {
    
    var dataManager = NLFDataManager()
    let allLaureates = NLFDataManager().getAllLaureates()
    // Serial queue
    let routesQueue = DispatchQueue(label: "com.prospertin.nlf.routeQueue")
    // Example of concurrent let routesQueue = DispatchQueue(label: "com.prospertin.nlf.routeQueue", attributes: .concurrent)
    var processCount = 0
    
    func findRoute(startYear: Int, startLocation: CLLocation, completionHandler: @escaping ([NLFDestinationViewModel])->Void) {
        //Keep track of how many processes were launched
        processCount += 1
        routesQueue.async() {[weak self] in
                
            guard let self = self else {
                return
            }
            
            let viewModels = self.allLaureates.map({(model:LaureateModel) -> NLFDestinationViewModel in
                return NLFDestinationViewModel(model, startYear, startLocation)
            })
            
            let sortedViewModels = viewModels.sorted {
                return $0.rank < $1.rank
            }
            //Get the top 20
            let destinations = Array(sortedViewModels.prefix(Constants.ROUTE_SIZE))
            DispatchQueue.main.async {
                self.processCount -= 1
                if self.processCount == 0 {
                    //update UI only if there is no other processed launched
                    completionHandler(destinations)
                }
            }
        }
    }
    
    /*
     * Build annotations from the list of routes, combining years from same locations, assuming name of institution is unique
     */
    func getAnnotations(from route:[NLFDestinationViewModel]) -> [NLFAnnotationViewModel] {
        var map:[String: NLFAnnotationViewModel] = [:]
        
        route.forEach({destination in
            if let annotation = map[destination.institution] {
                if let subtitle = annotation.subtitle {
                    annotation.subtitle = "\(subtitle), \(destination.fullName) (\(destination.year))"
                } else {
                    annotation.subtitle = "\(destination.fullName) (\(destination.year))"
                }
            } else {
                map[destination.institution] = NLFAnnotationViewModel(destination.institution, "\(destination.fullName) (\(destination.year))", coordinate: destination.coordinate)
            }
        })
        
        return map.map({ (key, value) in
            return value
        })
    }
}

class NLFDestinationViewModel {
    var fullName = ""
    var institution = ""
    var year = 0
    var locationName = ""
    
    var distance = Double.greatestFiniteMagnitude
    var rank = Double.greatestFiniteMagnitude
    var coordinate: CLLocationCoordinate2D
    
    init(_ laureate: LaureateModel, _ startYear: Int, _ startLocation: CLLocation) {
        fullName = "\(laureate.firstname) \(laureate.surname)"
        institution = "\(laureate.name)"
        locationName = "\(laureate.city) (\(laureate.country))"
        year = Int(laureate.year) ?? Int.max
        
        if let loc = laureate.location {
            let location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            distance = location.distance(from: startLocation)
            rank = Double(abs(startYear - year) * Constants.TIME_FACTOR) + distance
            coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        } else {
            coordinate = CLLocationCoordinate2D(
                latitude: Double.greatestFiniteMagnitude,
                longitude: Double.greatestFiniteMagnitude)
        }
    }
}

class NLFAnnotationViewModel: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title:String? = ""
    var subtitle: String? = ""
    
    init(_ title: String, _ subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

class Constants {
    static let START_YEAR = 1900
    static let END_YEAR = 2020
    static let ROUTE_SIZE = 20
    static let TIME_FACTOR = 10000 //10 km
    static let REGION_PADDING = 100000.0 // 100 km padding for better display
    static let MAP_RADIUS = 1000000.0
}
