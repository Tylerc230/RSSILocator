//
//  RSSIDataTrainer.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/5/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import CocoaLumberjack
import ReactiveCocoa


@objc public class RSSIDataTrainer {
    private var currentCollection:RoomTrainingDataCollection? = nil
    private let collections = NSMutableSet()
    private let rssiSource = RSSISource()
    static let kTrainingDataPath = "training.dat"
    
    func trainingData() -> TrainingData {
        let data = trainingDataForSamples()
        let columns = peripheralIdentifiers()
        return TrainingData(columns: columns, data: data)
        
    }
    
    public func startCollectingDataForRoom(room:Int) {
        currentCollection = RoomTrainingDataCollection(roomIndex: room)
        let stream = rssiSource.startAdvertisingStream()
        stream.subscribeNext { (value:AnyObject!) -> Void in
            currentCollection?.addRSSISample(value as! RSSISample)
        }
    }
    
    public func finishCollectiongData() {
        rssiSource.stopAdvertisingStream()
        if let currentCollection = currentCollection {
            collections.addObject(currentCollection)
        }
    }
    
    public func cancelCurrentCollection() {
        
    }
    
    public func trainingDataForSamples() -> NSData {
        let allPeripheralIdentifiers = peripheralIdentifiers()
        let numColums = allPeripheralIdentifiers.count
        let data = NSMutableData()
        for roomDataObj in collections {
            let roomData = roomDataObj as! RoomTrainingDataCollection
            let rawRoomData = roomData.trainingDataWithColumns(allPeripheralIdentifiers)
            data.appendData(rawRoomData)
        }
        return data
    }
    
    
    func peripheralIdentifiers() -> [String] {
        let identifiers = NSMutableSet()
        for collection in collections {
            if let collection = collection as? RoomTrainingDataCollection {
                identifiers.unionSet(collection.allPeripheralIds() as Set<NSObject>)
            }
        }
        let identifierArray = identifiers.allObjects as! [String]
        return identifierArray.sorted(<)
    }
    
}

