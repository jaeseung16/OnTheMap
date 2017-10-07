//
//  OnTheMapTabBarController.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/7/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import UIKit

class OnTheMapTabBarController: UITabBarController {
    
    var studentLocations = [StudentLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("Received: \(studentLocations.count)")
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

}
