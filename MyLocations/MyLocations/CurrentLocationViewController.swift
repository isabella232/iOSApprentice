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
import QuartzCore

import AudioToolbox

class CurrentLocationViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var tagButton: UIButton!
    
    @IBOutlet weak var getButton: UIButton!
    
    
    @IBOutlet weak var latitudeTextLabel:UILabel!
    
    @IBOutlet weak var longitudeTextLabel:UILabel!
    
    
    @IBOutlet weak var containerView:UIView!
    
    var logoVisible = false
    
    lazy var logoButton: UIButton = {
    
        let button = UIButton(type: .Custom)
        button.setBackgroundImage(UIImage(named: "Logo"), forState: .Normal)
        button.sizeToFit()
        button.addTarget(self, action: Selector("getLocation"), forControlEvents: .TouchUpInside)
        button.center.x = CGRectGetMidX(self.view.bounds)
        button.center.y = 220
        
        return button
    }()
    
    
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
    
    var soundID:SystemSoundID = 0
    
    
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
        
        if logoVisible {
        
            hideLogoView()
        
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
        
        loadSoundEffect("Sound.caf")
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
                    
                        if self.placemark == nil {
                            
                            print("FIRST TIME!")
                            
                            self.playSoundEffect()
                        
                        }
                        
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
            
            latitudeTextLabel.hidden = false
            
            longitudeTextLabel.hidden = false
        
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
            
                statusMessage = ""
                
                showLogoView()
                
            }
            
            messageLabel.text = statusMessage
        
            latitudeTextLabel.hidden = true
            
            longitudeTextLabel.hidden = true
        }
        
    }
    
    func stringFromPlacemark(placemark:CLPlacemark) -> String {
    
        var line1 = ""
        
        line1.addText(placemark.subThoroughfare)
        
        line1.addText(placemark.thoroughfare, withSeparator: " ")
        
        
        var line2 = ""
        
        line2.addText(placemark.locality)
        
        line2.addText(placemark.administrativeArea, withSeparator: " ")
        
        line2.addText(placemark.postalCode , withSeparator: " ")
        
        line1.addText(line2)
        
        return line1
    
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
    
        let spinnerTag = 1000
        
        if updatingLocation {
        
            getButton.setTitle("Stop", forState: .Normal)
            
            if view.viewWithTag(spinnerTag) == nil {
            
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
                
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height / 2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
            
        } else {
        
            getButton.setTitle("Get My Location", forState: .Normal)
            
            if let spinner = view.viewWithTag(spinnerTag) {
                
                spinner.removeFromSuperview()
            }
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
    
    
    //MARK: - Logo View
    
    func showLogoView(){
        
        if !logoVisible {
            
            logoVisible = true
            
            containerView.hidden = true
            
            view.addSubview(logoButton)
        
        }
    }
    
    func hideLogoView(){
    
        if !logoVisible {return}
        
        logoVisible = false
        
        containerView.hidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        let centerX = CGRectGetMidX(view.bounds)
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.removedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(CGPoint:containerView.center)
        panelMover.toValue = NSValue(CGPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        containerView.layer.addAnimation(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.removedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(CGPoint:logoButton.center)
        logoMover.toValue = NSValue(CGPoint:CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.addAnimation(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.removedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        logoButton.layer.addAnimation(logoRotator, forKey: "logoRotator")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
        
    }
    
    
    func loadSoundEffect(name:String){
    
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil) {
        
            let fileURL = NSURL.fileURLWithPath(path, isDirectory: false)
            
            let error = AudioServicesCreateSystemSoundID(fileURL, &soundID)
            
            if error != kAudioServicesNoError {
            
                print("Error Code \(error) load sound at path:\(path)")
            
            }
        }
    }
    
    func unloadSoundEffect(){
    
        AudioServicesDisposeSystemSoundID(soundID)
    
    }
    
    func playSoundEffect(){
    
        AudioServicesPlaySystemSound(soundID)
    
    }
}





































//-------------------




