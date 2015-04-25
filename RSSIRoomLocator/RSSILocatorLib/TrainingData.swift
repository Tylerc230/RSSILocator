//
//  TrainingData.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/7/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import Foundation
import UIKit

class TrainingData: NSObject, NSCoding, DebugPrintable {
    let labelData:NSMutableData
    let featureData:NSMutableData
    let columns:[String]
    
    var numColumns:Int {
        return columns.count
    }
    
    var numRows:Int {
        let floatCount = featureData.length/sizeof(RSSIValue)
        return floatCount/numColumns
    }
    
    init(columns:[String], featureData:NSMutableData, labelData:NSMutableData) {
        self.columns = columns
        self.featureData = featureData
        self.labelData = labelData
    }
    
    required init(coder aDecoder: NSCoder) {
        columns = aDecoder.decodeObjectForKey("columns") as! [String]
        featureData = aDecoder.decodeObjectForKey("featureData") as! NSMutableData
        labelData = aDecoder.decodeObjectForKey("labelData") as! NSMutableData
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(featureData, forKey: "featureData")
        aCoder.encodeObject(columns, forKey: "columns")
        aCoder.encodeObject(labelData, forKey: "labelData")
    }
    
    func saveToDisk() {
        let path = TrainingData.archiveFilePath()
        NSKeyedArchiver.archiveRootObject(self, toFile:path)
    }
    
    class func hasTrainingData() -> Bool {
        let path = TrainingData.archiveFilePath()
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
    
    class func deleteTrainingData() {
        let path = archiveFilePath()
        var error:NSError? = nil
        NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
    }
    
    class func readFromDisk() -> TrainingData {
        let path = TrainingData.archiveFilePath()
        return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! TrainingData
    }
    
    private class func archiveFilePath() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent(RSSIDataTrainer.kTrainingDataPath)
        return path
    }
    
    override var debugDescription:String {
        var output = "Training data: \n"
        let numCols = numColumns
        let numRows = self.numRows
        let bufferPointer = UnsafeBufferPointer<RSSIValue>(start: UnsafePointer<Float>(featureData.bytes), count: numCols * numRows)
        let labelPointer = UnsafeBufferPointer<RSSIValue>(start: UnsafePointer<Float>(labelData.bytes), count: numRows)
        for row in 0..<numRows {
            output += "\(labelPointer[row]): "
            for col in 0..<numCols {
                let value = bufferPointer[row * numCols + col]
                output += "\(value), "
            }
            output += "\n"
        }
        return output
    }
}
