//
//  RoomTrainingDataCollection.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/2/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//


@objc class RoomTrainingDataCollection: NSObject {
    var latestRSSIValues:RSSISample? = nil
    let roomIndex:Int
    private var collectedData = [RSSISample]()
    
    init(roomIndex:Int) {
        self.roomIndex = roomIndex
        super.init()
        RACObserve(self, "latestRSSIValues").subscribeNext {
            [unowned self] (value) in
            if let latestValues = value as? RSSISample {
                DDLogInfo("append values \(latestValues)")
                self.collectedData.append(latestValues)
            }
        }
    }
}
