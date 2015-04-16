//
//  RoomPredictionEngine.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/12/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import Foundation

class RoomPredictionEngine {
    private let trainingData:TrainingData
    private let predictionAlgorithm = PredictionAlgorithm()
    private let rssiSource = RSSISource()
    init(trainingData:TrainingData) {
        self.trainingData = trainingData
        debugPrintln(trainingData)
        predictionAlgorithm.train(trainingData.data, numFeatures: Int32(trainingData.columns.count), filterSize: 3)
    }
    
    func startPredicting() {
        let stream = rssiSource.startAdvertisingStream()
        stream.subscribeNext { (obj:AnyObject!) in
            DDLogInfo("Next value \(obj)")
        }
    }
    
    func predict(latestSample:RSSISample) -> Int {
        return 1
    }
}
