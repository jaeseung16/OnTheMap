//
//  OTMMapViewController.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/7/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import UIKit
import MapKit

class OTMMapViewController: UIViewController, MKMapViewDelegate {

    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var locations = (self.navigationController?.tabBarController as! OnTheMapTabBarController).studentsInformation
        
        for location in locations {
            
            let latitude = location.latitude
            let longitude = location.longitude
            
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            annotations.append(annotation)
            
        }
        
        // print(annotations.count)
        self.mapView.removeAnnotations(annotations)
        self.mapView.addAnnotations(annotations)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        let _ = OTMClient.sharedInstance().logOut { (success, sessionID, errorString) in
            
            if success {
                OTMClient.sharedInstance().reset()
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Logout Failed", message: errorString, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        NSLog("Logout Failed")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        let _ = OTMClient.sharedInstance().getStudentLocations(completionHandlerForStudentLocation: { (success, results, errorString) in
            
            if success {
                DispatchQueue.main.async {
                    var locations = [StudentInformation]()
                    for result in results! {
                        let studentLocation = StudentInformation(dictionary: result)
                        locations.append(studentLocation)
                    }
                    self.mapView.removeAnnotations(self.annotations)
                    
                    self.annotations = []
                    
                    for location in locations {
                        
                        let latitude = location.latitude
                        let longitude = location.longitude
                        
                        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(location.firstName) \(location.lastName)"
                        annotation.subtitle = location.mediaURL
                        
                        self.annotations.append(annotation)
                        
                    }
                    
                    // print(annotations.count)
                    self.mapView.addAnnotations(self.annotations)
                    
                    print("\(locations.count)")
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    //self.activityIndicator.stopAnimating()
                    //self.performSegue(withIdentifier: "LogedIn", sender: self)
                }
            } else {
                //self.loginFailed(errorString!)
                print("Refresh failed")
                return
            }
        })
    }
    
    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        
        let _ = OTMClient.sharedInstance().getAStudentLocation { (success, result, errorString) in
            if success {
                DispatchQueue.main.async {
                    let message = "You already posted a student location. Would you like to overwrite your location?"
                    let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { _ in
                        NSLog("Overwriting")
                        print("overwrite")
                        return
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
                        NSLog("Overwriting Canceled.")
                        print("not overwrite")
                        return
                    }))
                    
                    self.present(alert, animated: true, completion: nil)

                }
            } else {
                print("new location")
                
                guard (errorString == "Could not find the student location.") else {
                    return
                }
                
                DispatchQueue.main.async {
                    var informationPostingViewController: InformationPostingViewController
                    informationPostingViewController = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingVC") as! InformationPostingViewController
                    
                    informationPostingViewController.studentLocation = result
                    
                    // self.navigationController?.pushViewController(informationPostingViewController, animated: true)
                    self.present(informationPostingViewController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - MKMapViewDelegate
    
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
