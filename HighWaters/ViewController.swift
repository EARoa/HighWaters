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

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var highWatersAnnotation: MKAnnotation!
    var container: CKContainer!
    var publicDB: CKDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseSetup()
        populateFloodLocations()
    }

    private func  databaseSetup() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.container = CKContainer.defaultContainer()
        self.publicDB = self.container.publicCloudDatabase
    }
    
    
    private func populateFloodLocations() {
        let query = CKQuery(recordType: "Locations", predicate: NSPredicate(format: "name = %@", "location"))
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records: [CKRecord]?, error: NSError?) in
            for location in records!{
                let locations = location["floodLocation"] as! CLLocation
                let annotationCoordinate = locations.coordinate
                let highWatersLocationsAnnotation = MKPointAnnotation()
                highWatersLocationsAnnotation.title = "Warning!"
                highWatersLocationsAnnotation.coordinate = annotationCoordinate
                self.mapView.addAnnotation(highWatersLocationsAnnotation)
            }
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            let highWatersAnnotation = MKPointAnnotation()
            highWatersAnnotation.title = "Warning!"
            highWatersAnnotation.coordinate = self.mapView.userLocation.coordinate
            let savedAnnotation = CLLocation(coordinate: highWatersAnnotation.coordinate, altitude:0, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: NSDate())
            let pinPointedRecord = CKRecord(recordType: "Locations")
            pinPointedRecord["floodLocation"] = savedAnnotation
            pinPointedRecord["name"] = "location"
            self.publicDB.saveRecord(pinPointedRecord) { (record: CKRecord?, error: NSError?) in }
            self.mapView.addAnnotation(highWatersAnnotation)
        }
    }

    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if let annotationView = views.first {
            if let annotation = annotationView.annotation {
                if annotation is MKUserLocation {
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 300, 200)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        self.highWatersAnnotation = view.annotation
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let hazardousPhoto = UIImage(named: "caution")
        var highWatersAnnotation = self.mapView.dequeueReusableAnnotationViewWithIdentifier("highWatersAnnotation")
        if highWatersAnnotation == nil {
            highWatersAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "highWatersAnnotation")
        } else {
            highWatersAnnotation?.annotation = annotation
        }
        highWatersAnnotation?.frame = CGRectMake(0, 0, 50, 50)
        let hazardView = UIImageView(image: hazardousPhoto)
        hazardView.frame.size = CGSize(width: 250, height:  250)
        highWatersAnnotation?.image = hazardousPhoto
        highWatersAnnotation?.frame = CGRectMake(0, 0, 50, 50)
        highWatersAnnotation?.userInteractionEnabled = true
        highWatersAnnotation!.canShowCallout = true
        let leftView = UIView(frame: CGRectMake(0,0,60,80))
        let delete = UIButton(frame: CGRectMake(0,-15.5,60,80))
        delete.titleLabel?.textColor = UIColor.blackColor()
        delete.setTitle("Delete", forState: UIControlState.Normal)
        delete.addTarget(self, action: #selector(destoryAnnotation), forControlEvents:UIControlEvents.TouchUpInside)
        leftView.backgroundColor = UIColor(red: 202.0/255, green: 15.0/255, blue: 20.0/255, alpha: 1.0)
        leftView.addSubview(delete)
        highWatersAnnotation!.leftCalloutAccessoryView = leftView
        return highWatersAnnotation
    }

    func destoryAnnotation() {
        let query = CKQuery(recordType: "Locations", predicate: NSPredicate(format: "name = %@", "location"))
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records: [CKRecord]?, error: NSError?) in
            if let locations = records {
                for loactionRecord in locations {
                    let recordCoordinate = loactionRecord["floodLocation"] as! CLLocation
                    let savedLongtitudeCoordinate = recordCoordinate.coordinate.longitude
                    let longitudeSavedAnnotation = self.highWatersAnnotation.coordinate.longitude
                    let savedLatitudeCoordinate = recordCoordinate.coordinate.latitude
                    let latitudeSavedAnnotation = self.highWatersAnnotation.coordinate.latitude
                    if(savedLongtitudeCoordinate == longitudeSavedAnnotation && savedLatitudeCoordinate == latitudeSavedAnnotation ){
                        self.publicDB.deleteRecordWithID(loactionRecord.recordID, completionHandler: { (recordId: CKRecordID?, error: NSError?) in })
                    }
                }
            }
        }
        mapView.removeAnnotation(self.highWatersAnnotation)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}