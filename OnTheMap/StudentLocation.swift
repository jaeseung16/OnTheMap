//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/6/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

class StudentLocation {
    var objetcId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    
    struct Fields {
        static let Id = "objectId"
        static let Key = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let URL = "mediaULR"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }

    init(dictionary: [String: AnyObject]) {
        self.objetcId = dictionary[Fields.Id] as? String
        self.uniqueKey = dictionary[Fields.Key] as? String
        self.firstName = dictionary[Fields.FirstName] as? String
        self.lastName = dictionary[Fields.LastName] as? String
        self.mapString = dictionary[Fields.MapString] as? String
        self.mediaURL = dictionary[Fields.URL] as? String
        self.latitude = dictionary[Fields.Latitude] as? Double
        self.longitude = dictionary[Fields.Longitude] as? Double
    }
}
