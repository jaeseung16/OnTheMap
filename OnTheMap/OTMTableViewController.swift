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
    let reuseIdentifier = "OTMTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.locations = []
        
        otmLocations.refresh { (success, errorString) in
            if success {
                DispatchQueue.main.async {
                    for location in self.otmLocations.studentLocations {
                        self.locations.append(location)
                    }
                    print("\(self.otmLocations.studentLocations.count)")
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.tableView.reloadData()
                    //self.activityIndicator.stopAnimating()
                    //self.performSegue(withIdentifier: "LogedIn", sender: self)
                }
            } else {
                //self.loginFailed(errorString!)
                print("Refresh failed")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
        }
        
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
