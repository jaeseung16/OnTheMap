//
//  OTMMapViewController.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/7/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import UIKit
import MapKit

class OTMMapViewController: UIViewController {

    // MARK: Properties
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Shared Instances
    let otmLocations = OTMLocations.sharedInstance
    let otmClient = OTMClient.sharedInstance
    
    // MARK: Other Properties
    var annotations = [MKPointAnnotation]()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.populateAnnotations()
    }
    
    // MARK: IBActions
    @IBAction func logout(_ sender: UIBarButtonItem) {
        let _ = otmClient.logOut { (success, errorString) in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            } else {
                self.alertController("Logout Failed", errorString!, "Dismiss")
            }
        }
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        self.reloadData()
    }
    
    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        let _ = otmClient.getAStudentLocation { (success, errorString) in
            if success {
                    self.alertOverwrite()
            } else {
                guard (errorString == "Could not find the student location.") else {
                    self.alertController("Add Location", "Cannot finish the job. Try again.", "Dismiss")
                    return
                }
                self.presentInformationPostingVC()
            }
        }
    }
    
    // MARK: Custom Methods
    func reloadData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.mapView.removeAnnotations(self.annotations)
        self.annotations = []
        
        otmLocations.refresh { (success, errorString) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //self.activityIndicator.stopAnimating()
            }
            
            if success {
                DispatchQueue.main.async {
                    self.populateAnnotations()
                }
            } else {
                self.alertController("Refresh Failed", errorString!, "Dismiss")
                return
            }
        }
    }
    
    func populateAnnotations() {
        for location in otmLocations.studentLocations {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude))
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func alertController(_ title: String, _ message: String, _ action: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: action, style: .default, handler: { _ in
                NSLog(message)
                return
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func alertOverwrite() {
        DispatchQueue.main.async {
            let message = "You already posted a student location. Would you like to overwrite your location?"
            let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { _ in
                NSLog("Overwriting")
                self.presentInformationPostingVC()
                return
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
                NSLog("Overwriting Canceled.")
                return
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentInformationPostingVC() {
        DispatchQueue.main.async {
            var informationPostingViewController: InformationPostingViewController
            
            informationPostingViewController = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingVC") as! InformationPostingViewController

            self.present(informationPostingViewController, animated: true)
        }
    }
}

// MARK: -
extension OTMMapViewController: MKMapViewDelegate {
    // MARK: MKMapViewDelegate
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!)
            }
        }
    }
}
