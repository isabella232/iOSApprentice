//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Jay on 15/9/29.
//  Copyright © 2015年 look4us. All rights reserved.
//

import UIKit

import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var tagButton: UIButton!
    
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var location: CLLocation?
    
    var updatingLocation = false
    
    var lastLocationError: NSError?
    
    
    let geocoder = CLGeocoder()
    
    var placemark:CLPlacemark?
    
    var performingReverseGecoding = false
    
    var lastGeoCodingError:NSError?
    
    var timer: NSTimer?
    
    var managedObjectContext:NSManagedObjectContext!
    
    
    @IBAction func getLocation() {
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
        
            locationManager.requestWhenInUseAuthorization()
            
            return
        
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
        
            showLocationServiceDeniedAlert()
            
            return
            
        }
        
        if updatingLocation{
            
            stopLocationManager()
            
        } else {
        
            location = nil
            
            lastLocationError = nil
            
            placemark = nil
            
            lastGeoCodingError = nil
            
            startLocationManager()
        }
        
        updateLabels()
        
        configureGetButton()
    }
    
    func showLocationServiceDeniedAlert() {
    
        let alert = UIAlertController(title: "请求位置服务失败！", message: "请在系统设置对应用设置位置服务", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateLabels()
        
        configureGetButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error:NSError) {
        
        print("didFailWithError \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
        
            return
        
        }
        
        lastLocationError = error
        
        stopLocationManager()
        
        updateLabels()
        
        configureGetButton()
    }
    
    func locationManager(manager:CLLocationManager,didUpdateLocations locations:[CLLocation]) {
        
        let newLocation = locations.last!
        
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
        
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
        
            return
            
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        
        if let location = location {
        
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
        
            lastLocationError = nil
            
            location = newLocation
            
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            
                print("*** we're done!")
                
                stopLocationManager()
            
                configureGetButton()
                
                if distance > 0 {
                
                    performingReverseGecoding = false
                
                }
            }
            
            if !performingReverseGecoding {
            
                print("***Going to geocode")
                
                performingReverseGecoding = true
                
                geocoder.reverseGeocodeLocation(newLocation,completionHandler:{
                
                    placemark,error in
                    
                    print("*** Found placemark:\(placemark),error:\(error)")
                    
                    self.lastGeoCodingError = error
                    
                    if error == nil, let p = placemark where !p.isEmpty {
                    
                        self.placemark = p.last!
                    
                    } else {
                    
                        self.placemark = nil
                    
                    }
                    
                    self.performingReverseGecoding = false
                    
                    self.updateLabels()
                })
            }
        } else if distance < 1.0 {
        
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
            
                print("*** Force done!")
                
                stopLocationManager()
                
                updateLabels()
                
                configureGetButton()
            }
        }
    }
    
    func updateLabels() {
    
        if let location = location {
        
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            
            longitudeLabel.text = String(format: "%.8f",location.coordinate.longitude)
            
            tagButton.hidden = false
            
            messageLabel.text = ""
            
            if let placemark = placemark {
                
                let placeString = stringFromPlacemark(placemark)
                
                print(placeString)
                
                addressLabel.text = placeString
                
            
            } else if performingReverseGecoding {
            
                addressLabel.text = "Searching for address..."
                
            } else if lastGeoCodingError != nil {
            
                addressLabel.text = "Error Finding Address"
            } else {
                
                addressLabel.text = "No address Found"
            }
        
        } else {
        
            latitudeLabel.text = ""
            
            longitudeLabel.text = ""
            
            addressLabel.text = ""
            
            tagButton.hidden = true
            
            let statusMessage: String
            
            if let error = lastLocationError {
                
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                
                    statusMessage = "Location Service Disabled"
                    
                } else {
                
                    statusMessage = "Error Getting Location"
                
                }
            
            } else if !CLLocationManager.locationServicesEnabled() {
            
                statusMessage = "Location Service Disabled!"
            
            } else if updatingLocation {
            
                statusMessage = "Search...."
                
            } else {
            
                statusMessage = "Tap 'Get My Location' to Start"
                
            }
        
            
            
            messageLabel.text = statusMessage
        
        }
        
    }
    
    func stringFromPlacemark(placemark:CLPlacemark) -> String {
    
        var line1 = ""
        
        if let s = placemark.subThoroughfare {
        
            line1 += s + ""
        }
        
        if let s = placemark.thoroughfare {
        
            line1 += s
            
        }
        
        var line2 = ""
        
        if let s = placemark.locality {
        
            line2 += s + ""
        
        }
        
        if let s = placemark.administrativeArea {
        
            line2 += s + ""
            
        }
        
        if let s = placemark.postalCode {
        
            line2 += s
        
        }
        
        return line1 + " " + line2
    
    }
    
    func stopLocationManager() {
    
        if updatingLocation {
        
            if let timer = timer {
            
                timer.invalidate()
            }
            
            locationManager.stopUpdatingLocation()
            
            locationManager.delegate = nil
            
            updatingLocation = false
            
        }
    }
    
    func startLocationManager() {
    
        if CLLocationManager.locationServicesEnabled() {
        
            locationManager.delegate = self
            
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            locationManager.startUpdatingLocation()
            
            updatingLocation = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target:self,selector:Selector("didTimeOut"),userInfo:nil, repeats: false)
        }
    
    }
    
    func configureGetButton() {
    
        if updatingLocation {
        
            getButton.setTitle("Stop", forState: .Normal)
            
        } else {
        
            getButton.setTitle("Get My Location", forState: .Normal)
        }
        
    }
    
    func didTimeOut() {
    
        print("*** Time out!")
        
        if location == nil {
        
            stopLocationManager()
            
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
            
            configureGetButton()
        
        }
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TagLocation" {
        
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = location!.coordinate
            
            controller.placemark = placemark
            
            controller.manageObjectContext = managedObjectContext
            
        }
    }
    
}





































//-------------------




