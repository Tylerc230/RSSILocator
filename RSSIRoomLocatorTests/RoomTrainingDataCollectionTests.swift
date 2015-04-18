//
//  RSSITrainingDataCollectionTests.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/17/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import XCTest
typealias ValueBuffer = UnsafePointer<RSSIValue>

class FakeRSSISample: RSSISample {
    var fakeTimestamp:NSDate? = nil
    init(peripheralIdentifier: String, rssiValue: RSSIValue, timestamp:NSDate) {
        super.init(peripheralIdentifier: peripheralIdentifier, rssiValue: rssiValue)
        self.fakeTimestamp = timestamp
    }
    
    override func getTimestamp() -> NSDate {
        return fakeTimestamp ?? super.getTimestamp()
    }
}

class RoomTrainingDataCollectionTests: XCTestCase {
    let trainer = RoomTrainingDataCollection(roomIndex: 1)
    
    func testMultipleRowAddition() {
        let samples = [RSSISample(peripheralIdentifier: "ABCD", rssiValue: -20.0),
            RSSISample(peripheralIdentifier: "EFGH", rssiValue: -30.0),
            RSSISample(peripheralIdentifier: "IJKL", rssiValue: -40.0)
        ]
        
        let trainingColumns = ["ABCD", "EFGH", "IJKL"]
        let expectedValues =    [
            [1.0, samples[0].rssiValue, kMissingValue, kMissingValue],
            [1.0, samples[0].rssiValue, samples[1].rssiValue, kMissingValue],
            [1.0, samples[0].rssiValue, samples[1].rssiValue, samples[2].rssiValue]
        ]
        trainWithSamples(samples, columns: trainingColumns, expectedValues: expectedValues)
    }
    
    func test127ValueFilter() {
        let samples = [ RSSISample(peripheralIdentifier: "ABCD", rssiValue: -30),
                        RSSISample(peripheralIdentifier: "ABCD", rssiValue: 127.0)]
        let expectedValues:[[RSSIValue]] = [
            [1.0, -30.0],
            [1.0, -30.0]
        ]
        trainWithSamples(samples, columns: ["ABCD"], expectedValues: expectedValues)
    }
    
    func testExpiredSample() {
        let samples = [
            FakeRSSISample(peripheralIdentifier: "ABCD", rssiValue: -30.0, timestamp:NSDate.distantPast() as! NSDate),
            RSSISample(peripheralIdentifier: "EFGH", rssiValue: -40.0)
        ]
        let expectedValues = [
            [1.0, -30.0, kMissingValue],
            [1.0, kMissingValue, -40.0]
        ]
        trainWithSamples(samples, columns: ["ABCD", "EFGH"], expectedValues: expectedValues)
    }
    
    func trainWithSamples(samples:[RSSISample], columns:[String], expectedValues:[[RSSIValue]]) {
        for sample in samples {
            trainer.addRSSISample(sample)
        }
        let data = trainer.trainingDataWithColumns(columns)
        XCTAssertEqual(data.length, samples.count * (columns.count + 1) * sizeof(RSSIValue), "Incorrect size")
        let valueBuffer = ValueBuffer(data.bytes)
        let rowCount = expectedValues.count
        for row in 0..<rowCount {
            let expectedRow = expectedValues[row]
            XCTAssertTrue(compareRow(row, inBuffer: valueBuffer, toValues: expectedRow), "row \(row) had unepected values \(valueBuffer[3]) should have been \(expectedRow)")
        }
    }
    
    func compareRow(rowIndex:Int, inBuffer buffer:ValueBuffer, toValues values:[RSSIValue]) -> Bool {
        let rowLength = values.count
        for column in 0..<rowLength {
            let expectedValue = values[column]
            let buffValue = buffer[rowIndex * rowLength + column]
            if buffValue != expectedValue {
                return false
            }
        }
        return true
    }

}
