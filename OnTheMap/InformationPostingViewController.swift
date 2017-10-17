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
    
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: Variables
    let otmClient = OTMClient.sharedInstance
    var location = CLLocation()
    var mapRect = MKMapRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = view.center
        
        // Remove these two lines later
        locationTextField.text = "New York"
        websiteTextField.text = "https://www.google.com"
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        guard let locationString = locationTextField.text, locationString != "" else {
            postFailed("Location Not Found", "Must Enter a Location", "Dismiss")
            return
        }
        
        guard let websiteString = websiteTextField.text, websiteString != "" else {
            postFailed("Location Not Found", "Must Enter a Website", "Dismiss")
            return
        }
        
        guard websiteString.lowercased().starts(with: "http://") || websiteString.lowercased().starts(with: "https://") else {
            postFailed("Location Not Found", "Invalide Link. Include HTTP(S)://", "Dismiss")
            return
        }
        
        activityIndicator.startAnimating()
        
        geoCoding(locationString) {(success, location, error) -> Void in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if success {
                guard let location = location else {
                    return
                }
                
                print("latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude)")
                
                let parameters = ["mapString": "\"\(locationString)\"", "mediaURL": "\"\(websiteString)\"", "latitude": "\(location.coordinate.latitude)", "longitude": "\(location.coordinate.longitude)"]
                
                let _ = self.otmClient.postAStudentLocation(with: parameters) { (success, errorString) in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    if success {
                        // self.dismiss(animated: true)
                    } else {
                        DispatchQueue.main.async {
                            print(errorString!)
                            self.postFailed("Post Failed", "Could not post the location.", "Dismiss")
                        }
                    }
                }
                
            } else {
                self.postFailed("Where are you?", "Cannot Find Your Location.", "Dismiss")
            }
            
        }
        
    }
    
    // Mark: - Methods
    func geoCoding(_ location: String, completionHandlerForGeoCoding: @escaping (_ success: Bool, _ location: CLLocation?, _ error: NSError?) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(location) { (placeMark, error) in
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
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            
            DispatchQueue.main.async {
                self.locationMapView.setCenter(self.location.coordinate, animated: false)
                self.locationMapView.showAnnotations([annotation], animated: true)
            }
            
            completionHandlerForGeoCoding(true, location, nil)
            
        }
    }
    
    func postFailed(_ title: String, _ message: String, _ action: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: action, style: .default, handler: { _ in
                NSLog("Post Failed")
                return
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension InformationPostingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
