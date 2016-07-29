//
//  ViewController.swift
//  HighWaters
//
//  Created by Efrain Ayllon on 7/28/16.
//  Copyright © 2016 Efrain Ayllon. All rights reserved.
//

import UIKit
import CloudKit
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {

     var longitude: Double!
     var latitude: Double!
    @IBOutlet weak var mapView :MKMapView!
    
    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    var locationManager  :CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationSetup()
        self.container = CKContainer.defaultContainer()
        self.publicDB = self.container.publicCloudDatabase
        self.privateDB = self.container.publicCloudDatabase
        getData()

    }
    
    
    func getData() {
    
    
    let query = CKQuery(recordType: "Locations", predicate: NSPredicate(value:true))
    
    self.publicDB.performQuery(query, inZoneWithID: nil) { (records:[CKRecord]?, error: NSError?) in
    
        dispatch_async(dispatch_get_main_queue(), {

    for location in records!{
    print(location["Latitude"]!)
    print(location["Longitude"]!)
        
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.title = "Hello!"
        pinAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        self.mapView.addAnnotation(pinAnnotation)
        
    }
    })
    }
    }
    
    
    
    
    
    private func locationSetup(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
    }
    
    
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if let annotationView = views.first {
            if let annotation = annotationView.annotation {
                if annotation is MKUserLocation {
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
        
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        latitude = locValue.latitude
        longitude = locValue.longitude
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            
            
            let locationData = CKRecord(recordType: "Locations")
            locationData["Latitude"] = latitude
            locationData["Longitude"] = longitude
            
            print("Shake me!")
            print(locationData)
            
            self.publicDB.saveRecord(locationData) { (record:CKRecord?, error:NSError?) in
                print(record?.recordID)
            }
            
            
            
        }
    }


}

