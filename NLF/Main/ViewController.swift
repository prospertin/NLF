//
//  ViewController.swift
//  NLF
//
//  Created by Thinh Nguyen on 10/5/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import UIKit
import MapKit
import MeltwaterKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var presenter: AuthenticationPresenterProtocol?

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var yearPickerView: UIPickerView!
    
    @IBOutlet weak var instructionsTextView: UITextView!
  
    @IBOutlet weak var viewRoutesButton: UIButton!
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBAction func onGo(_ sender: Any) {
        travel()
    }
    
    let viewModel = RoutesViewModel()
    
    var currentStartLocationAnnotation:MKPointAnnotation?
    var currentRoutes:[NLFDestinationViewModel]?
    var currentYear:Int = Constants.START_YEAR
    var currentAnnotations:[NLFAnnotationViewModel]?
    var pickerData:[Int] = [Int](Constants.START_YEAR...Constants.END_YEAR)
    var travelTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(sender:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        mapView.register(NLFAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier:
            MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
    }
    
    func processInput() {
        if let annotation = currentStartLocationAnnotation {
            let loc = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            viewModel.findRoute(startYear: currentYear, startLocation: loc, completionHandler: { routes in
                self.currentRoutes = routes
                //self.centerMapOnLocation(location: loc, radius: radius)
                self.displayLocations(routes: routes)
                self.viewRoutesButton.isHidden = false
                self.goButton.isHidden = false
                self.instructionsTextView.isHidden = true
            })
        }
    }
    
    func travel() {
        guard let ship = currentStartLocationAnnotation else {
            return
        }
        let startCoordinate = ship.coordinate
        var count = 0
        self.goButton.isEnabled = false
        travelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            UIView.animate(withDuration: 1.0) {
                if self.currentRoutes == nil || count == self.currentRoutes!.count {
                    timer.invalidate()
                    ship.coordinate = startCoordinate
                    self.goButton.isEnabled = true
                   // self.centerMapOnLocation(coordinate: ship.coordinate)
                    return
                }
                ship.coordinate = self.currentRoutes![count].coordinate
                //self.centerMapOnLocation(coordinate: ship.coordinate)
                count += 1
            }
        }
    }
    
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: Constants.MAP_RADIUS, longitudinalMeters: Constants.MAP_RADIUS)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func displayLocations(routes: [NLFDestinationViewModel]) {
        let coord = currentStartLocationAnnotation!.coordinate
        var north = coord.latitude
        var south = coord.latitude
        var east = coord.longitude
        var west = coord.longitude
        
        currentAnnotations = viewModel.getAnnotations(from: routes)
        currentAnnotations!.forEach( {annotation in
            let coord = annotation.coordinate
            north = max(north, coord.latitude)
            south = min(south, coord.latitude)
            east = max(east, coord.longitude)
            west = min(west, coord.longitude)
            
            mapView.addAnnotation(annotation)
        })
        let center = CLLocationCoordinate2D(latitude:(north+south)/2, longitude:(west+east)/2)
        let top = CLLocation(latitude: north, longitude: 0.0)
        let bottom = CLLocation(latitude: south, longitude: 0.0)
        let height = top.distance(from: bottom)
        
        let left = CLLocation(latitude: 0.0, longitude: west)
        let right = CLLocation(latitude: 0.0, longitude: east)
        let width = left.distance(from: right)
        
        let coordinateRegion = MKCoordinateRegion(center: center, latitudinalMeters: height + Constants.REGION_PADDING, longitudinalMeters: width + Constants.REGION_PADDING)
        // Sanity checks for weird edge cases.
        if coordinateRegion.span.latitudeDelta < 360 && coordinateRegion.span.longitudeDelta < 360 {
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            if let t = travelTimer {
                t.invalidate()
                self.goButton.isEnabled = true
            }
            
            let touchPoint: CGPoint = sender.location(in: mapView)
            let newCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            markStartLocation(pointedCoordinate: newCoordinate)
        }
    }
    
    func markStartLocation(pointedCoordinate: CLLocationCoordinate2D) {
        if currentStartLocationAnnotation == nil {
            currentStartLocationAnnotation = MKPointAnnotation()
            currentStartLocationAnnotation!.title = "Time Machine"
            mapView.addAnnotation(currentStartLocationAnnotation!)
        }
        currentStartLocationAnnotation!.coordinate = pointedCoordinate
        if let annotations = currentAnnotations { mapView.removeAnnotations(annotations)
        }
        processInput()
    }
    
    //PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentYear = pickerData[row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? RoutesTableViewController {
            vc.routeList = currentRoutes
        }
    }
}


