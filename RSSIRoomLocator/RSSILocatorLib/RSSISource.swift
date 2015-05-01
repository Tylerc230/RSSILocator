//
//  RSSISource.swift
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/15/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReactiveCocoa

public class RSSISource: NSObject {
    private var centralManager: CBCentralManager! = nil
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
    //Mark: private methods
    func startAdvertisingStream() -> RACSignal {
        centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        return rac_signalForSelector(Selector("centralManager:didDiscoverPeripheral:advertisementData:RSSI:"), fromProtocol: CBCentralManagerDelegate.self).map {
            (obj:AnyObject!) -> AnyObject in
            let params = obj as! RACTuple
            let peripheral = params.second as! CBPeripheral
            let rssi = params.fourth as! RSSIValue
            let UUIDString = peripheral.identifier.UUIDString
            return RSSISample(peripheralIdentifier: UUIDString, rssiValue: rssi)
            }.filter {
                obj in
                let sample = obj as! RSSISample
                let isSensorTag = sample.peripheralIdentifier == "14068A33-D254-AD85-C3E4-75FAD34EFA7C"
                return isSensorTag
        }
    }
    
    func stopAdvertisingStream() {
        centralManager.stopScan()
    }
}

extension RSSISource: CBCentralManagerDelegate {
    public func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        //Must be implemented in order to rac_signalFromSelector
    }
    
    public func centralManagerDidUpdateState(central: CBCentralManager!) {
        DDLogInfo("State changed to \(central.state.rawValue)")
    }
    
}
