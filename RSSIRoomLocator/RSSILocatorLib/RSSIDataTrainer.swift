//
//  RSSIDataTrainer.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/5/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import CoreBluetooth
import CocoaLumberjack
import ReactiveCocoa


@objc public class RSSIDataTrainer: NSObject {
    private var currentCollection:RoomTrainingDataCollection? = nil
    private let collections = NSMutableSet()
    private var centralManager: CBCentralManager! = nil
    static let kTrainingDataPath = "training.dat"
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
    
    func trainingData() -> TrainingData {
        let data = trainingDataForSamples()
        let columns = peripheralIdentifiers()
        return TrainingData(columns: columns, data: data)
        
    }
    
    public func startCollectingDataForRoom(room:Int) {
        currentCollection = RoomTrainingDataCollection(roomIndex: room)
        let stream = startAdvertisingStream()
        stream ~> RAC(currentCollection, "latestRSSIValues")
    }
    
    public func finishCollectiongData() {
        stopAdvertisingStream()
        if let currentCollection = currentCollection {
            collections.addObject(currentCollection)
        }
    }
    
    public func cancelCurrentCollection() {
        
    }
    
    public func trainingDataForSamples() -> NSData {
        let allPeripheralIdentifiers = peripheralIdentifiers()
        let numColums = allPeripheralIdentifiers.count
        let data = NSMutableData()
        for roomDataObj in collections {
            let roomData = roomDataObj as! RoomTrainingDataCollection
            let rawRoomData = roomData.trainingDataWithColumns(allPeripheralIdentifiers)
            data.appendData(rawRoomData)
        }
        return data
    }
    
    //Mark: private methods
    private func startAdvertisingStream() -> RACSignal {
        centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        return rac_signalForSelector(Selector("centralManager:didDiscoverPeripheral:advertisementData:RSSI:"), fromProtocol: CBCentralManagerDelegate.self).map {
            (obj:AnyObject!) -> AnyObject in
            let params = obj as! RACTuple
            let peripheral = params.second as! CBPeripheral
            let rssi = params.fourth as! RSSIValue
            let UUIDString = peripheral.identifier.UUIDString
            return RSSISample(peripheralIdentifier: UUIDString, rssiValue: rssi)
        }
    }
    
    func peripheralIdentifiers() -> [String] {
        let identifiers = NSMutableSet()
        for collection in collections {
            if let collection = collection as? RoomTrainingDataCollection {
                identifiers.unionSet(collection.allPeripheralIds() as Set<NSObject>)
            }
        }
        let identifierArray = identifiers.allObjects as! [String]
        return identifierArray.sorted(<)
    }
    
    private func stopAdvertisingStream() {
        centralManager.stopScan()
    }
    
}

extension RSSIDataTrainer: CBCentralManagerDelegate {
    public func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        //Must be implemented in order to rac_signalFromSelector
    }
    
    public func centralManagerDidUpdateState(central: CBCentralManager!) {
        DDLogInfo("State changed to \(central.state.rawValue)")
    }
    
}