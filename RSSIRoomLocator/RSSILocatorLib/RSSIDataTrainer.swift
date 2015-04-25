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
        let (labelData, featureData) = trainingDataForSamples()
        let columns = peripheralIdentifiers()
        return TrainingData(columns: columns, featureData:featureData, labelData:labelData)
        
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
    
    public func trainingDataForSamples() -> (labelData:NSMutableData, featureData:NSMutableData) {
        let allPeripheralIdentifiers = peripheralIdentifiers()
        let numColums = allPeripheralIdentifiers.count
        let allFeatureData = NSMutableData()
        let allLabelData = NSMutableData()
        for roomDataObj in collections {
            let roomData = roomDataObj as! RoomTrainingDataCollection
            let roomFeatureMatrix = roomData.trainingDataWithColumns(allPeripheralIdentifiers)
            allFeatureData.appendData(roomFeatureMatrix.data)
            let roomLabelMatrix = roomData.labelData()
            allLabelData.appendData(roomLabelMatrix.data)
        }
        return (allLabelData, allFeatureData)
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

