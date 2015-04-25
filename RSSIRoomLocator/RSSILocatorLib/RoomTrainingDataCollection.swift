//
//  RoomTrainingDataCollection.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/2/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//
class RoomTrainingDataCollection {
    let roomIndex:Int
    private var collectedData = [RSSISample]()
    var hasData:Bool {
        return collectedData.count > 0
    }
    
    init(roomIndex:Int) {
        self.roomIndex = roomIndex
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
    
    func trainingDataWithColumns(peripheralIdentifierColumns:[String]) -> Matrix<RSSIValue> {
        let numColumns = peripheralIdentifierColumns.count
        let numRows = collectedData.count
        let matrix = Matrix<RSSIValue>(rows: numRows, columns: numColumns)
        let matrixGenerator = MatrixGenerator()
        matrixGenerator.fillMatrix(matrix, withSamples: collectedData, featureOrder: peripheralIdentifierColumns)
        return matrix
    }
    
    func labelData() -> Matrix<RSSIValue> {
        let labelMatrix = Matrix<RSSIValue>(rows: collectedData.count, columns: 1)
        for row in 0..<labelMatrix.rows {
            labelMatrix[row, 0] = RSSIValue(roomIndex)
        }
        return labelMatrix
    }
}
