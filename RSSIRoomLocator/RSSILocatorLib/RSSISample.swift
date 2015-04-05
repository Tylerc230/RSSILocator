//
//  RSSISample.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/5/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import Foundation
typealias RSSIValue = Float
let kMissingValue:Float = -1000.0


@objc class RSSISample: DebugPrintable {
    let peripheralIdentifier:String
    let rssiValue:RSSIValue
    let timestamp:NSDate
    init(peripheralIdentifier:String, rssiValue:RSSIValue) {
        self.peripheralIdentifier = peripheralIdentifier
        self.rssiValue = rssiValue
        self.timestamp = NSDate()
    }
    
    var debugDescription:String {
        return "Peripheral \(peripheralIdentifier) rssi: \(rssiValue)"
    }
}
