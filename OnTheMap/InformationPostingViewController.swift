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
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    let otmClient = OTMClient.sharedInstance
    
    var location = CLLocation()
    var mapRect = MKMapRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationMapView.isHidden = true
        submitButton.isHidden = true
        
        locationTextField.isEnabled = true
        websiteTextField.isEnabled = true
        
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = view.center
        
        // Remove these two lines later
        locationTextField.text = "New York"
        websiteTextField.text = "https://www.google.com"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func find(_ sender: UIButton) {
        
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
        
        locationTextField.isEnabled = false
        websiteTextField.isEnabled = false
        
        activityIndicator.startAnimating()
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationTextField.text!) { (placeMark, error) in
            guard (error == nil) else {
                print("There is an error.")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            guard let location = placeMark?[0].location else {
                print("No location received.")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            self.location = location
            
            DispatchQueue.main.async {
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                // self.locationMapView.addAnnotation(annotation)
                
                self.findButton.isHidden = true
                self.submitButton.isHidden = false
                
                self.locationMapView.setCenter(self.location.coordinate, animated: true)
                self.locationMapView.showAnnotations([annotation], animated: true)
                self.locationMapView.isHidden = false
            }
            
            print("latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude)")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let parameters = ["mapString": "\"\(locationTextField.text!)\"", "mediaURL": "\"\(websiteTextField.text!)\"", "latitude": "\(location.coordinate.latitude)", "longitude": "\(location.coordinate.longitude)"]
        
        print(parameters)
        let _ = otmClient.postAStudentLocation(with: parameters) { (success, errorString) in
            if success {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                self.dismiss(animated: true)
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    print(errorString!)
                    self.postFailed("Post Failed", "Could not post the location.", "Dismiss")
                }
            }
        }
    }
    
    // Mark: - Methods
    func postFailed(_ title: String, _ message: String, _ action: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: action, style: .default, handler: { _ in
                NSLog("Post Failed")
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
