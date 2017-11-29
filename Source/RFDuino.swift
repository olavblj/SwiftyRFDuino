//
//  RFDuino.swift
//  OpenBCI App
//
//  Created by Olav Bakke Ljosland on 09/11/2017.
//  Copyright © 2017 Olav Bakke Ljosland. All rights reserved.
//

import Foundation
import CoreBluetooth


class RFDuino: NSObject {
    
    public var isTimedOut = false
    public var isConnected = false
    public var didDiscoverCharacteristics = false
    
    public var delegate: RFDuinoDelegate?
    public static let timeoutThreshold = 5.0
    public var RSSI: NSNumber?
    
    var whenDoneBlock: (() -> ())?
    var peripheral: CBPeripheral
    var timeoutTimer: Timer?
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        self.peripheral.delegate = self
    }
}

// MARK: - [-- Internal Methods --]

internal extension RFDuino {
    func confirmAndTimeout() {
        isTimedOut = false
        delegate?.didDiscover(self)
        
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: RFDuino.timeoutThreshold, repeats: false, block: { (Timer) in
            self.didTimeout()
        })
    }
    
    func didTimeout() {
        isTimedOut = true
        isConnected = false
        delegate?.didTimeout(self)
    }
    
    func didConnect() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        
        isConnected  = true
        isTimedOut = false
    }
    
    func didDisconnect() {
        isConnected = false
        confirmAndTimeout()
        delegate?.didDisconnect(self)
    }
    
    func findCharacteristic(characteristicUUID: RFDuinoUUID, forServiceWithUUID serviceUUID: RFDuinoUUID) -> CBCharacteristic? {
        if let discoveredServices = peripheral.services,
            let service = (discoveredServices.filter { return $0.uuid == serviceUUID.id }).first,
            let characteristics = service.characteristics {
                return (characteristics.filter { return $0.uuid ==  characteristicUUID.id}).first
            }
        return nil
    }
}

// MARK: - [-- Public Methods --]

extension RFDuino {
    func discoverServices() {
        log(.trying, "Going to discover services for peripheral")
        peripheral.discoverServices([RFDuinoUUID.discover.id])
    }
    
    func sendDisconnectCommand(whenDone: @escaping () -> ()) {
        self.whenDoneBlock = whenDone
        
        if peripheral.services == nil {
            whenDone()
            return
        }
        if let characteristic = findCharacteristic(characteristicUUID: RFDuinoUUID.disconnect, forServiceWithUUID: RFDuinoUUID.discover) {
            var byte = UInt8(1)
            let data = Data(bytes: &byte, count: 1)
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
    
    func send(data: Data) {
        if let characteristic = findCharacteristic(characteristicUUID: RFDuinoUUID.send, forServiceWithUUID: RFDuinoUUID.discover) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}

// MARK: - [-- Calculated Vars --]

extension RFDuino {
    var name: String {
        get {
            return self.peripheral.name ?? "Unknown device"
        }
    }
}

// MARK: - [-- CBPeripheralDelegate Methods --]

extension RFDuino: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        log(.done, "Did send data to peripheral")
        
        if characteristic.uuid == RFDuinoUUID.disconnect.id {
            if let doneBlock = whenDoneBlock {
                doneBlock()
            }
        } else {
            guard let characteristic = self.findCharacteristic(characteristicUUID: RFDuinoUUID.send, forServiceWithUUID: RFDuinoUUID.discover) else {
                
                log(.error, "Did not find characteristic")
                
                return
            }
            
            delegate?.didSendData(self, forCharacteristic: characteristic, error: error)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        log(.done, "Did discover services")
        if let discoveredServices = peripheral.services {
            for service in discoveredServices {
                if service.uuid == RFDuinoUUID.discover.id {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
        delegate?.didDiscoverServices(self)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for characteristic in service.characteristics! {
            log(.object, "Did discover characteristic with UUID: " + characteristic.uuid.description)
            if characteristic.uuid == RFDuinoUUID.receive.id {
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == RFDuinoUUID.send.id {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        log(.done, "Did discover characteristics for service")
        delegate?.didDiscoverCharacteristics(self)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        log(.done, "Did receive data for rfduino")
        delegate?.didReceiveData(self, data: characteristic.value)
    }
}
