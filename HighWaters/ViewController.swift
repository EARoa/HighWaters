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

    @IBOutlet weak var myCallout :UIView!
     var longitude: Double!
     var latitude: Double!
    @IBOutlet weak var mapView :MKMapView!
    
    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    var pinAnnotation = MKPointAnnotation()

    
    var locationManager  :CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationSetup()
        self.container = CKContainer.defaultContainer()
        self.publicDB = self.container.publicCloudDatabase
        self.privateDB = self.container.publicCloudDatabase
        getData()

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
    
    
    
    func getData() {
        
        
        let query = CKQuery(recordType: "Locations", predicate: NSPredicate(value:true))
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records:[CKRecord]?, error: NSError?) in
            
            dispatch_async(dispatch_get_main_queue(), {
            
                for location in records!{
                    print(location["Latitude"]!)
                    print(location["Longitude"]!)
//                    let pinAnnotation = MKPointAnnotation()
                    self.pinAnnotation.title = "Caution!!"
                    self.pinAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                    self.mapView.addAnnotation(self.pinAnnotation)
                }
            })
        }
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
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                
                self.pinAnnotation.title = "Caution!!"
                self.pinAnnotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                self.mapView.addAnnotation(self.pinAnnotation)
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("AnnotationView")
        
        if annotationView == nil {
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        annotationView?.canShowCallout = true
        
        let imageView = UIImageView(image: UIImage(contentsOfFile: "caution"))
        
        annotationView?.detailCalloutAccessoryView = self.myCallout

        
        return annotationView
        
    }
    
    
    @IBAction func deleteLocation(){
        let query = CKQuery(recordType: "Locations", predicate: NSPredicate(value:true))
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records :[CKRecord]?, error :NSError?) in
            if let records = records {
                if let record = records.first {
                    self.publicDB.deleteRecordWithID(record.recordID, completionHandler: { (recordId :CKRecordID?, error :NSError?) in
                    })
                }
            }
        }
    }
}

