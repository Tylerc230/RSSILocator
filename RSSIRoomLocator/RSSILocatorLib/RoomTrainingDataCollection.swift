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
    var hasData:Bool {
        return collectedData.count > 0
    }
    
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
    
    func allPeripheralIds() -> Set<String> {
        var peripheralIds = Set<String>()
        for sample in collectedData {
            peripheralIds.insert(sample.peripheralIdentifier)
        }
        return peripheralIds
    }
    
    func trainingDataWithColumns(peripheralIdentifierColumns:[String]) -> NSData {
        let numColumns = peripheralIdentifierColumns.count * 1
        let numRows = collectedData.count
        let dataSize = numColumns * numRows * sizeof(Float)
        let data = NSMutableData(length: dataSize )
        let bytes = UnsafeMutablePointer<RSSIValue>(data!.bytes)
        let columns = peripheralIdentifierColumns as NSArray
        for (var row = 0; row < numRows; row++) {
            let currentSample = collectedData[row]
            for (var column = 0; column < numColumns; column++) {
                var value: Float = 0.0
                let sampleIdentifier = currentSample.peripheralIdentifier
                if column == 0 {
                    value = Float(roomIndex)
                } else {
                    let columnPeripheralIdentifier:String = peripheralIdentifierColumns[column - 1]
                    if columnPeripheralIdentifier == sampleIdentifier {
                        value = currentSample.rssiValue
                    } else if row == 0 {
                        value = kMissingValue
                    } else {
                        value = bytes[(row - 1) * column]
                    }
                }
                bytes[row * column] = value
            }
        }
        return data!
    }
}
