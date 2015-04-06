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
    private let centralManager: CBCentralManager! = nil
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
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
        trainingDataForSamples()
    }
    
    public func cancelCurrentCollection() {
        
    }
    
    public func trainingDataForSamples() -> NSData {
        let allPeripheralIdentifiers = collectPeripheralIdentifiers()
        let numColums = allPeripheralIdentifiers.count
        print(allPeripheralIdentifiers)
        return NSData()
    }
    
    //Mark: private methods
    private func startAdvertisingStream() -> RACSignal {
        centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        return rac_signalForSelector(Selector("centralManager:didDiscoverPeripheral:advertisementData:RSSI:"), fromProtocol: CBCentralManagerDelegate.self).map {
            (obj:AnyObject!) -> AnyObject in
            let params = obj as RACTuple
            let peripheral = params.second as CBPeripheral
            let rssi = params.fourth as RSSIValue
            let UUIDString = peripheral.identifier.UUIDString
            return RSSISample(peripheralIdentifier: UUIDString, rssiValue: rssi)
        }
    }
    
    private func stopAdvertisingStream() {
        centralManager.stopScan()
    }
    
    private func collectPeripheralIdentifiers() -> [String] {
        let identifiers = NSMutableSet()
        for collection in collections {
            if let collection = collection as? RoomTrainingDataCollection {
                identifiers.unionSet(collection.allPeripheralIds())
            }
        }
        let identifierArray = identifiers.allObjects as [String]
        return identifierArray.sorted(<)
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