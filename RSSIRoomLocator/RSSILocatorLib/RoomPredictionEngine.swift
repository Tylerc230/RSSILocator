//
//  RoomPredictionEngine.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/12/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import Foundation

class RoomPredictionEngine {
    private let predictionAlgorithm:PredictionAlgorithm
    private let rssiSource = RSSISource()
    private var currentSamples = [RSSISample]()
    private let filterSize:Int
    private let matrixGenerator = MatrixGenerator()
    private let matrix:Matrix<RSSIValue>
    private let features:[String]
    
    init(trainingData:TrainingData, filterSize:Int) {
        self.filterSize = filterSize
        features = trainingData.columns
        let columns = features.count
        predictionAlgorithm = PredictionAlgorithm(numFeatures: Int32(columns), filterSize: Int32(filterSize))
        print(trainingData.debugDescription)
        predictionAlgorithm.train(trainingData.featureData, labels:trainingData.labelData)
        matrix = Matrix(rows: filterSize, columns: columns)
    }
    
    func startPredicting() {
        let stream = rssiSource.startAdvertisingStream()
        stream.subscribeNext { (obj:AnyObject!) in
            let rssiSample = obj as! RSSISample
            self.addSample(rssiSample)
            let prediction = self.predict()
            NSLog("prediction %d", prediction)
        }
    }
    
    func addSample(sample:RSSISample) {
        if currentSamples.count >= filterSize {
            currentSamples.removeLast()
        }
        currentSamples.insert(sample, atIndex: 0)
    }
    
    func predict() -> Int {
        matrixGenerator.fillMatrix(matrix, withSamples: currentSamples, featureOrder: features)
        return Int(predictionAlgorithm.predict(matrix.data))
    }
    
    
    
}
