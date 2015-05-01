//
//  FirstViewController.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 3/29/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, RoomPredictionDelegate {
    @IBOutlet private weak var predictionLabel:UILabel!
    var roomPredictionEngine:RoomPredictionEngine? = nil
    required init(coder aDecoder: NSCoder) {
        if TrainingData.hasTrainingData() {
            let trainingData = TrainingData.readFromDisk()
            roomPredictionEngine = RoomPredictionEngine(trainingData: trainingData, filterSize:10)
        }
        super.init(coder: aDecoder)
        roomPredictionEngine?.predictionDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !TrainingData.hasTrainingData() {
            showDataTrainer()
        }
    }
    
    func predictionMade(prediction: Int) {
        predictionLabel.text = "\(prediction)"
    }
    
    @IBAction func startPredictions() {
        roomPredictionEngine?.startPredicting()
    }
    
    func showDataTrainer() {
        tabBarController!.performSegueWithIdentifier("TrainingDataSegue", sender: self)
    }

}

