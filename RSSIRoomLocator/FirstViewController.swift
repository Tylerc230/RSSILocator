//
//  FirstViewController.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 3/29/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    var roomPredictionEngine:RoomPredictionEngine? = nil
    required init(coder aDecoder: NSCoder) {
        if TrainingData.hasTrainingData() {
            let trainingData = TrainingData.readFromDisk()
            roomPredictionEngine = RoomPredictionEngine(trainingData: trainingData, filterSize:3)
        }
        super.init(coder: aDecoder)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !TrainingData.hasTrainingData() {
            showDataTrainer()
        }
    }
    
    @IBAction func startPredictions() {
        roomPredictionEngine?.startPredicting()
    }
    
    func showDataTrainer() {
        tabBarController!.performSegueWithIdentifier("TrainingDataSegue", sender: self)
    }

}

