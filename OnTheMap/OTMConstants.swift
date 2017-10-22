//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Jae-Seung Lee on 10/11/17.
//  Copyright © 2017 Jae-Seung Lee. All rights reserved.
//

import Foundation

extension OTMClient {
    
    // MARK: API Keys
    static let applicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    // MARK: URLs
    struct OTMConstant {
        static let scheme = "https"
        static let hostUdacity = "www.udacity.com"
        static let hostParse = "parse.udacity.com"
        static let pathAPI = "/api/session"
        static let pathParse = "/parse/classes/StudentLocation"
        static let numberOfLocations = 100
    }
    
    static let SessionURL = "https://www.udacity.com/api/session"
    static let UserDataURL = "https://www.udacity.com/api/users/"
    
}
