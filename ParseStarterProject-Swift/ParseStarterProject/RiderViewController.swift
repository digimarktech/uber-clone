//
//  RiderViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Marc Aupont on 1/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager:CLLocationManager!
    
    var latitude:CLLocationDegrees = 0
    var longitude:CLLocationDegrees = 0
    
    var riderRequestActive = false
    
    @IBOutlet var map: MKMapView!

    @IBOutlet var callUberButton: UIButton!
    
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
        
        var riderRequest = PFObject(className:"riderRequest")
        riderRequest["username"] = PFUser.currentUser()?.username
        riderRequest["location"] = PFGeoPoint(latitude:latitude, longitude:longitude)
        
        
        riderRequest.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                
                self.callUberButton.setTitle("Cancel Uber", forState: UIControlState.Normal)
                
                
                
            } else {
                
                let alert = UIAlertController(title: "Could Not Call Uber", message: "Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
            riderRequestActive = true
        
        } else {
            
            self.callUberButton.setTitle("Call an Uber", forState: UIControlState.Normal)
            
            riderRequestActive = false
            
            var query = PFQuery(className:"riderRequest")
            query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    print("Successfully retrieved \(objects!.count) scores.")
                    
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                } else {
                    
                    print(error)
                }
            }
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        print("locations = \(location.latitude) \(location.longitude)")
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        self.map.removeAnnotations(map.annotations)
        
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Your Location"
        self.map.addAnnotation(objectAnnotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //This code will happen whenever there is a segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutRider" {
            
            PFUser.logOut()
        }
        
    }
    

   

}
