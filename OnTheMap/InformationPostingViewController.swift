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
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var location = CLLocation()
    var mapRect = MKMapRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationMapView.isHidden = true
        submitButton.isHidden = true
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
    
    @IBAction func submit(_ sender: UIButton) {
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationTextField.text!) { (placeMark, error) in
            guard (error == nil) else {
                print("There is an error.")
                return
            }
            
            guard let location = placeMark?[0].location else {
                print("No location received.")
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
        }
        
    }
    
    // MARK: - MKMapViewDelegate
    /*
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    */
}
