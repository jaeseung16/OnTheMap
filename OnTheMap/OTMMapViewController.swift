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

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let locations = (self.navigationController?.tabBarController as! OnTheMapTabBarController).studentsInformation
        
        var annotations = [MKPointAnnotation]()
        
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
    
    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        
        guard let uniqueKey = OTMClient.sharedInstance().userID else {
            return
        }
        print(uniqueKey)
        
        var component = URLComponents()
        component.scheme = "https"
        component.host = "parse.udacity.com"
        component.path = "/parse/classes/StudentLocation"
        component.queryItems = [URLQueryItem]()
        component.queryItems!.append( URLQueryItem(name: "where", value: "{\"uniqueKey\":\"661149902\"}") )
        
        let request = NSMutableURLRequest(url: component.url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                return
            }
            guard (error == nil) else {
                
                return
            }
            
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
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
