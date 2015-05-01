//
//  TableGenerator.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/18/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import Foundation
class MatrixGenerator {
    let kSampleExpiration = 1.0
    var lastSampleForUUID = [String:RSSISample]()
    
    func addSample(sample:RSSISample, toMatrix matrix:Matrix<RSSIValue>, atRow row:Int, featureOrder:[String]) {
        let numColumns = featureOrder.count
        pruneExpiredSamples(sample.getTimestamp())
        for column in 0..<numColumns {
            var cellValue: RSSIValue = 0.0
            let featureName = featureOrder[column]
            if sample.peripheralIdentifier == featureName && sample.rssiValue < 0 {
                cellValue = sample.rssiValue
            } else {
                if let lastSample = lastSampleForUUID[featureName] {
                    cellValue = lastSample.rssiValue
                } else {
                    cellValue = kMissingValue
                }
            }
            matrix[row, column] = cellValue
        }
        lastSampleForUUID[sample.peripheralIdentifier] = sample
    }
    
    func fillMatrix(matrix:Matrix<RSSIValue>,  withSamples samples:[RSSISample], featureOrder:[String]) {
        let numRows = samples.count
        for row in 0..<numRows {
            let rowSample = samples[row]
            addSample(rowSample, toMatrix: matrix, atRow: row, featureOrder: featureOrder)
        }
    }
    
    private func pruneExpiredSamples(currentSampleTime:NSDate) {
        for (key, sample) in lastSampleForUUID {
            if fabs(sample.getTimestamp().timeIntervalSinceDate(currentSampleTime)) > kSampleExpiration {
                lastSampleForUUID.removeValueForKey(key)
            }
        }
    }
}
