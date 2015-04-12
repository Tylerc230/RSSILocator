//
//  TrainingData.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/7/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import Foundation
import UIKit

class TrainingData: NSObject, NSCoding {
    let data:NSData
    let columns:[String]
    
    init(columns:[String], data:NSData) {
        self.columns = columns
        self.data = data
    }
    
    required init(coder aDecoder: NSCoder) {
        columns = aDecoder.decodeObjectForKey("columns") as! [String]
        data = aDecoder.decodeObjectForKey("data") as! NSData
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(data, forKey: "data")
        aCoder.encodeObject(columns, forKey: "columns")
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
}
