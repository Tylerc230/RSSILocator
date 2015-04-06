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
    
    func allPeripheralIds() -> NSSet {
        let peripheralIds = NSMutableSet()
        for sample in collectedData {
            peripheralIds.addObject(sample.peripheralIdentifier)
        }
        return peripheralIds
    }
    
    func trainingDataWithColumns(peripheralIdentifierColumns:[String]) -> NSData {
        let numColumns = peripheralIdentifierColumns.count * 1
        let numRows = collectedData.count
        let dataSize = numColumns * numRows
        let data = NSMutableData(length: dataSize)
        let columns = peripheralIdentifierColumns as NSArray
        let rows = collectedData as NSArray
        columns.rac_sequence.map {
            (obj:AnyObject!) -> AnyObject! in
            let peripheralId = obj as String
            return rows.rac_sequence.map{
                (obj:AnyObject) -> AnyObject! in
                let sample = obj as RSSISample
                if sample.peripheralIdentifier == peripheralId {
                    return sample.rssiValue
                } else {
                    return kMissingValue
                }
            }!
        }
        return data!
    }
}
