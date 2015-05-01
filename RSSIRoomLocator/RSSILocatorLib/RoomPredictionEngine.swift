//
//  RoomPredictionEngine.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/12/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import Foundation
protocol RoomPredictionDelegate {
    func predictionMade(prediction:Int)
}
class RoomPredictionEngine: NSObject {
    var predictionDelegate:RoomPredictionDelegate? = nil
    private let predictionAlgorithm:PredictionAlgorithm
    private let rssiSource = RSSISource()
    private let filterSize:Int
    private let matrixGenerator = MatrixGenerator()
    private let matrix:Matrix<RSSIValue>
    private let features:[String]
    private var currentPredictinRow = 0
    
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
            let currentPrediction = self.predict(rssiSample)
            self.predictionDelegate?.predictionMade(currentPrediction)
        }
    }
    
    func predict(currentSample:RSSISample) -> Int {
        matrixGenerator.addSample(currentSample, toMatrix: matrix, atRow: currentPredictinRow, featureOrder: features)
        let prediction = Int(predictionAlgorithm.predict(matrix.data, row: Int32(currentPredictinRow)))
        currentPredictinRow = (currentPredictinRow + 1) % filterSize
        return prediction
    }
    
    
    
}
