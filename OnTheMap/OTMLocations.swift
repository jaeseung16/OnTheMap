//
//  OTMLocations.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/15/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

class OTMLocations {
    // MARK: Singleton
    static let sharedInstance = OTMLocations()
    
    // MARK: - Propertires
    var studentLocations: [StudentInformation]
    var userLocation: StudentInformation?
    
    init() {
        studentLocations = [StudentInformation]()
    }
    
    // MARK: - Methods
    func load(completionHandlerForLoad: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let _ = OTMClient.sharedInstance.getStudentLocations { (success, results, errorString) in
            if success {
                for result in results! {
                    let studentLocation = StudentInformation(dictionary: result)
                    self.studentLocations.append(studentLocation)
                }
                self.studentLocations.sort { $0.updatedAt > $1.updatedAt }
                print("\(self.studentLocations[0].updatedAt) - \(self.studentLocations[1].updatedAt)")
                completionHandlerForLoad(true, nil)
            } else {
                print("\(self.studentLocations.count)")
                completionHandlerForLoad(false, errorString!)
            }
        }
    }
    
    func refresh(completionHandlerForRefresh: @escaping (_ success: Bool, _ error: String?) -> Void) {
        studentLocations = []
        load { (success, error) in
            completionHandlerForRefresh(success, error)
        }
    }
    
}
