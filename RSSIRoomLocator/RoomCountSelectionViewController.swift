//
//  RoomCountSelectionViewController.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/2/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import UIKit
class RoomCountSelectionViewController: UIViewController {
    @IBOutlet weak var roomCountStepper:UIStepper!
    @IBOutlet weak var countLabel:UILabel!
    @IBOutlet weak var tableView:UITableView!
    private let trainer = RSSIDataTrainer()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        
    }
    @IBAction func dismissTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveTrainingData() {
        trainer.trainingDataForSamples()
    }
    
    private func initUI() {
        let valueChangeSignal = RACObserve(roomCountStepper, "value")
        valueChangeSignal.subscribeNext {
            [unowned self] (value) in
            self.tableView.reloadData()
        }
        
        valueChangeSignal.map {
            value in
            return "\(value)"
        } ~> RAC(countLabel, "text")
        
    }
}

extension RoomCountSelectionViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(roomCountStepper.value)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        cell.textLabel?.text = "\(indexPath.row + 1)"
        return cell
    }
}

extension RoomCountSelectionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        trainer.startCollectingDataForRoom(indexPath.row + 1)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        trainer.finishCollectiongData()
    }
}
