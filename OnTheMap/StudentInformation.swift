//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/6/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

struct StudentInformation {
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    var updatedAt: String
    
    enum Property: String {
        case objectId, uniqueKey, firstName, lastName, mapString, mediaURL, latitude, longitude
    }

    init(dictionary: [String: AnyObject]) {
        
        if let objectId = dictionary["objectId"] as? String {
            self.objectId = objectId
        } else {
            self.objectId = ""
        }
        
        if let uniqueKey = dictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        } else {
            self.uniqueKey = ""
        }
        
        if let firstName = dictionary["firstName"] as? String {
            self.firstName = firstName
        } else {
            self.firstName = ""
        }
        
        if let lastName = dictionary["lastName"] as? String {
            self.lastName = lastName
        } else {
            self.lastName = ""
        }
        
        if let mapString = dictionary["mapString"] as? String {
            self.mapString = mapString
        } else {
            self.mapString = ""
        }
       
        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = mediaURL
        } else {
            self.mediaURL = ""
        }
        
        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = latitude
        } else {
            self.latitude = 0.0
        }
        
        if let longitude = dictionary["longitude"] as? Double {
            self.longitude  = longitude
        } else {
            self.longitude  = 0.0
        }

        if let updatedAt = dictionary["updatedAt"] as? String {
            self.updatedAt = updatedAt
        } else {
            self.updatedAt = ""
        }
    }
}
