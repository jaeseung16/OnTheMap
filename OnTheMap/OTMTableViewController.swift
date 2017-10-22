//
//  OTMTableViewController.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/8/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import UIKit

class OTMTableViewController: UITableViewController {
    
    // MARK: Properties
    // MARK: Shared Instances
    let otmLocations = OTMLocations.sharedInstance
    let otmClient = OTMClient.sharedInstance
    
    // MARK: Other Properties
    let reuseIdentifier = "OTMTableViewCell"

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        otmLocations.refresh { (success, errorString) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.alertController("Refresh Failed", errorString!, "Dismiss")
                return
            }
        }
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
    
    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otmLocations.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = otmLocations.studentLocations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as UITableViewCell
        
        cell.textLabel!.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel!.text = "\(String(describing: location.mediaURL))"

        return cell
    }
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = otmLocations.studentLocations[indexPath.row]
        let app = UIApplication.shared
        
        if let url = URL(string:location.mediaURL) {
            app.open(url)
        }
    }

}
