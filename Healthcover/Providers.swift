//
//  Providers.swift
//  Healthcover
//
//  Created by Waseel ASP Ltd. on 11/7/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation

class Provider {
    let enName: String
    let arName: String
    let enAddress: String
    let arAddress: String
    let distance: String
    let portalCode: String
    
    init(enName: String, arName: String, portalCode: String, enAddress: String, arAddress: String, distance: String) {
        self.enName = enName
        self.arName = arName
        self.portalCode = portalCode
        self.enAddress = enAddress
        self.arAddress = arAddress
        self.distance = distance
    }
}
