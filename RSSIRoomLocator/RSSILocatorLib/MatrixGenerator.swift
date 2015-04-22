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
    
    func fillMatrix(matrix:NSMutableData,  withSamples samples:[RSSISample], featureOrder:[String]) {
        let numColumns = featureOrder.count
        let numRows = samples.count
        let bytes = UnsafeMutablePointer<RSSIValue>(matrix.bytes)
        for row in 0..<numRows {
            let rowSample = samples[row]
            pruneExpiredSamples(rowSample.getTimestamp())
            for column in 0..<numColumns {
                var cellValue: RSSIValue = 0.0
                let featureName = featureOrder[column]
                if rowSample.peripheralIdentifier == featureName && rowSample.rssiValue < 0 {
                    cellValue = rowSample.rssiValue
                } else {
                    if let lastSample = lastSampleForUUID[featureName] {
                        cellValue = lastSample.rssiValue
                    } else {
                        cellValue = kMissingValue
                    }
                }
                bytes[row * numColumns + column] = cellValue
            }
            lastSampleForUUID[rowSample.peripheralIdentifier] = rowSample
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
