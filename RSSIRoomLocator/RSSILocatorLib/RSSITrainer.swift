//
//  RSSITrainer.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/2/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

typealias RSSISample = Float
let kMissingValue:Float = -1000.0

@objc class RSSITainer: NSObject {
    var latestRSSIValues:[String:RSSISample]?
    let roomIndex:Int
    private var collectedData = [[String:RSSISample]]()
    
    init(roomIndex:Int) {
        self.roomIndex = roomIndex
    }
    
    func startCollecting() {
        let latestValuesStream = RACObserve(self, "lastestRSSIValues")
        latestValuesStream.subscribeNext {
            [unowned self] (value) in
            let latestValues = value as [String:RSSISample]
            self.collectedData.append(latestValues)
        }
    }
    
    func stopCollecting() {
        
    }
}
