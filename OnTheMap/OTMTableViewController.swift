//
//  OTMTableViewController.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/8/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import UIKit

class OTMTableViewController: UITableViewController {
    
    var locations = [StudentInformation]()
    
    let otmLocations = OTMLocations.sharedInstance
    let otmClient = OTMClient.sharedInstance
    
    let reuseIdentifier = "OTMTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        for location in self.otmLocations.studentLocations {
            self.locations.append(location)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        let _ = otmClient.logOut { (success, errorString) in
            
            if success {
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.locations = []
        
        otmLocations.refresh { (success, errorString) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //self.activityIndicator.stopAnimating()
            }
            
            if success {
                DispatchQueue.main.async {
                    for location in self.otmLocations.studentLocations {
                        self.locations.append(location)
                    }
                    print("\(self.otmLocations.studentLocations.count)")

                    self.tableView.reloadData()
                }
            } else {
                //self.loginFailed(errorString!)
                print("Refresh failed")
                return
            }
        }
        
    }
    
    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        
        let _ = otmClient.getAStudentLocation { (success, result, errorString) in
            if success {
                DispatchQueue.main.async {
                    let message = "You already posted a student location. Would you like to overwrite your location?"
                    self.alertOverwrite(message)
                }
            } else {
                guard (errorString == "Could not find the student location.") else {
                    return
                }
                self.presentInformationPostingVC()
            }
        }
    }

    func alertOverwrite(_ message: String) {
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
    
    func presentInformationPostingVC() {
        DispatchQueue.main.async {
            var informationPostingViewController: InformationPostingViewController
            informationPostingViewController = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingVC") as! InformationPostingViewController
            
            self.present(informationPostingViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = locations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel!.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel!.text = "\(String(describing: location.mediaURL))"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations[indexPath.row]
        
        let app = UIApplication.shared
        
        if let url = URL(string:location.mediaURL) {
            app.open(url)
        }
    }

}
