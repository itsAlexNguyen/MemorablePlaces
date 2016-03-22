//
//  ViewController.swift
//  Memorable Places
//
//  Created by Alex Nguyen on 2015-12-26.
//  Copyright © 2015 Alex Nguyen. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager: CLLocationManager!

    @IBOutlet weak var map: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Get location routine
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if activePlace == -1 {
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        } else {
            let latitude = NSString(string: places[activePlace]["lat"]!).doubleValue
            let longitude = NSString(string: places[activePlace]["lon"]!).doubleValue
            var coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            //Longitude and latitude precision
            var latDelta:CLLocationDegrees = 0.01
            var lonDelta:CLLocationDegrees = 0.01
            //Create Coordinate span
            var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            //Create region span
            var region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            //Set the map
            self.map.setRegion(region, animated: true)
            
            var annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            
            annotation.title = places[activePlace]["name"]
            
            self.map.addAnnotation(annotation)
        
        }
        
        //Long press routine
        var uilgpr = UILongPressGestureRecognizer(target: self, action: "action:")
        
        //Set minimum press duration of 2.0 seconds
        uilgpr.minimumPressDuration = 2.0
        
        //Add the press to the map
        map.addGestureRecognizer(uilgpr)
        
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            var touchPoint = gestureRecognizer.locationInView(self.map)
            
            var newCoordinate = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            var location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                var title = ""
                
                if (error == nil) {
                    if let p = placemarks?[0]{
                        var subThoroughfare:String = ""
                        var thoroughfare:String = ""
                        if p.subThoroughfare != nil {
                            subThoroughfare = "\(p.subThoroughfare!)"
                        }
                        if p.thoroughfare != nil {
                            thoroughfare = "\(p.thoroughfare!)"
                        }
                        title = "\(subThoroughfare) \(thoroughfare)"
                    }
                }
                if title == "" {
                    title = "Added on \(NSDate())"
                
                }
                
                places.append(["name":title,"lat":"\(newCoordinate.latitude)","lon":"\(newCoordinate.longitude)"])
                
                
                var annotation = MKPointAnnotation()

                annotation.coordinate = newCoordinate
                
                annotation.title = title

                self.map.addAnnotation(annotation)
            })
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations) //DEBUGGING
        
        //Get user location
        let userLocation:CLLocation = locations[0]
        //Set Longitude and latitude
        var latitude = userLocation.coordinate.latitude
        var longitude = userLocation.coordinate.longitude
        //Create CLLCoordinate from longitude and latitude
        var coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        //Longitude and latitude precision
        var latDelta:CLLocationDegrees = 0.01
        var lonDelta:CLLocationDegrees = 0.01
        //Create Coordinate span
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        //Create region span
        var region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        //Set the map
        self.map.setRegion(region, animated: true)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

