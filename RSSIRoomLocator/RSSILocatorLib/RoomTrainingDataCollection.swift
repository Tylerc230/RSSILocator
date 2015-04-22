//
//  RoomTrainingDataCollection.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/2/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//
@objc class RoomTrainingDataCollection: NSObject {
    let roomIndex:Int
    private var collectedData = [RSSISample]()
    var hasData:Bool {
        return collectedData.count > 0
    }
    
    init(roomIndex:Int) {
        self.roomIndex = roomIndex
        super.init()
    }
    
    func addRSSISample(value:RSSISample) {
        DDLogInfo("append values \(value)")
        self.collectedData.append(value)
    }
    
    func allPeripheralIds() -> Set<String> {
        var peripheralIds = Set<String>()
        for sample in collectedData {
            peripheralIds.insert(sample.peripheralIdentifier)
        }
        return peripheralIds
    }
    
    func trainingDataWithColumns(peripheralIdentifierColumns:[String]) -> NSData {
        let numColumns = peripheralIdentifierColumns.count
        let numRows = collectedData.count
        let dataSize = numColumns * numRows * sizeof(Float)
        let data = NSMutableData(length: dataSize)!
        let matrixGenerator = MatrixGenerator()
        matrixGenerator.fillMatrix(data, withSamples: collectedData, featureOrder: peripheralIdentifierColumns)
        return data
    }
}
