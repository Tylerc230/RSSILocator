//
//  FirstViewController.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 3/29/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !TrainingData.hasTrainingData() {
            showDataTrainer()
        }
    }
    
    func showDataTrainer() {
        tabBarController!.performSegueWithIdentifier("TrainingDataSegue", sender: self)
    }

}

