//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/9/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    // MARK: Outlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    // MARK: Shared Instance
    let otmClient = OTMClient.sharedInstance
    
    // MARK: Variables
    var location: CLLocation?
    var locationString: String?
    
    // MARK: - Overridden Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = view.center
        
        submitButton.isEnabled = false
        locationMapView.isHidden = true
        
        // Remove these two lines later
        locationTextField.text = "New York"
        websiteTextField.text = "https://www.google.com"
    }
    
    // MARK: - IBActions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func find(_ sender: UIButton) {
        guard let locationString = locationTextField.text, locationString != "" else {
            postFailed("Location Not Found", "Must Enter a Location")
            return
        }
        
        self.locationString = locationString
        
        findLocation(locationString)
    }
    
    @IBAction func submit(_ sender: UIBarButtonItem) {
        guard let location = self.location, let locationString = self.locationString else {
            postFailed("Post Failed", "Try Aftre Finding a Location on the Map.")
            return
        }
        
        guard let websiteString = websiteTextField.text, websiteString != "" else {
            postFailed("Post Failed", "Must Enter a Website")
            return
        }
        
        guard websiteString.lowercased().starts(with: "http://") || websiteString.lowercased().starts(with: "https://") else {
            postFailed("Post Failed", "Invalide Link. Include HTTP(S)://")
            return
        }
        
        let parameters = ["mapString": "\"\(locationString)\"", "mediaURL": "\"\(websiteString)\"", "latitude": "\(location.coordinate.latitude)", "longitude": "\(location.coordinate.longitude)"]

        activityIndicator.startAnimating()
        
        let _ = self.otmClient.postAStudentLocation(with: parameters) { (success, errorString) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if success {
                self.postSucceeded()
            } else {
                self.postFailed("Post Failed", "Could not post the location.")
            }
        }
    }

    // MARK: - Methods
    func findLocation(_ locationString: String) {
        activityIndicator.startAnimating()
        
        geoCoding(locationString) {(success, location, error) -> Void in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if success {
                guard let location = location else {
                    self.postFailed("Where are you?", "Cannot Find Your Location.")
                    return
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                
                DispatchQueue.main.async {
                    self.locationMapView.isHidden = false
                    self.locationMapView.setCenter(location.coordinate, animated: false)
                    self.locationMapView.showAnnotations([annotation], animated: true)
                }
                
                self.location = location
                self.submitButton.isEnabled = true
                
            } else {
                self.postFailed("Where are you?", "Cannot Find Your Location.")
            }
        }
    }
        
    func geoCoding(_ locationString: String, completionHandlerForGeoCoding: @escaping (_ success: Bool, _ location: CLLocation?, _ error: NSError?) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(locationString) { (placeMark, error) in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGeoCoding(false, nil, NSError(domain: "geoCoding", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                print("\(error!)")
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let location = placeMark?[0].location else {
                sendError("No locations received.")
                return
            }
            
            completionHandlerForGeoCoding(true, location, nil)
        }
    }
    
    // Alert when the post is failed.
    func postFailed(_ title: String, _ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
                NSLog(title)
                return
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Alert when the post is succeeded.
    func postSucceeded() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Your location is posted!", message: "Will return to the previous scene.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
                self.refreshLocations()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // After the post is succeeded, dismiss and refresh locations
    func refreshLocations() {
        // Look for which viewController presented the current viewController
        let presentingVC = self.presentingViewController as! UITabBarController
        let selectedVC = presentingVC.selectedViewController as! UINavigationController
        
        self.dismiss(animated: true, completion: {
            if let topVC = selectedVC.topViewController as? OTMMapViewController {
                topVC.reloadData()
            } else if let topVC = selectedVC.topViewController as? OTMTableViewController {
                topVC.reloadData()
            }
        })
    }
}

// MARK: - UITextFieldDelegate
extension InformationPostingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
