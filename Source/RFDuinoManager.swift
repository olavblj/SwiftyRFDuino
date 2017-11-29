//
//  RFDuinoManager.swift
//  OpenBCI App
//
//  Created by Olav Bakke Ljosland on 09/11/2017.
//  Copyright © 2017 Olav Bakke Ljosland. All rights reserved.
//

import Foundation
import CoreBluetooth


class RFDuinoManager : NSObject {
    public static let shared = RFDuinoManager()
    public var delegate: RFDuinoManagerDelegate?
    
    lazy private var centralManager:CBCentralManager = {
        let manager = CBCentralManager(delegate: RFDuinoManager.shared, queue: DispatchQueue.main)
        return manager
    }()
    
    private var reScanTimer: Timer?
    private static var reScanInterval = 10.0
    public var logLevel = LogLevel.systemEvents
    
    private var _rfduinos: [RFDuino] = []
    public var rfduinos: [RFDuino] = [] {
        didSet {
            if oldValue.count < rfduinos.count {
                delegate?.didDiscover(rfduinos.last!, manager: self)
            }
        }
    }
    
    override init() {
        super.init()
        log(.created, "initialized RFDuinoBTRManager")
    }
}

// MARK: - [-- Public Methods --]

extension RFDuinoManager {
    
    func startScanningForRFDuinos() {
        log(.start, "Started scanning for peripherals")
        
        let services = [RFDuinoUUID.discover.id]
        centralManager.scanForPeripherals(withServices: services, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanningForRFDuinos() {
        rfduinos = []
        log(.stop, "Stopped scanning for peripherals")
        centralManager.stopScan()
    }
    
    func connect(to rfduino: RFDuino) {
        log(.start, "Connecting to RFDuino")
        centralManager.connect(rfduino.peripheral, options: nil)
    }
    
    func disconnect(from rfduino: RFDuino) {
        log(.stop, "Disconnecting from RFDuino")
        rfduino.sendDisconnectCommand { () -> () in
            
            DispatchQueue.main.async {
                self.centralManager.cancelPeripheralConnection(rfduino.peripheral)
            }
        }
    }
    
    func disconnectRFDuinoWithoutSendCommand(rfduino: RFDuino) {
        self.centralManager.cancelPeripheralConnection(rfduino.peripheral)
    }
}

// MARK: - [-- Internal Methods --]
extension RFDuinoManager {
    func reScan() {
        log(.point, "Rescan")
        self.startScanningForRFDuinos()
        reScanTimer?.invalidate()
        reScanTimer = nil
        reScanTimer = Timer.scheduledTimer(withTimeInterval: RFDuinoManager.reScanInterval, repeats: true, block: { (Timer) in
            self.startScanningForRFDuinos()
        })
    }
}

// MARK: - [-- CBCentralManagerDelegate Methods --]

extension RFDuinoManager : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            log(.warning, "Bluetooth powered off")
        case .poweredOn:
            log(.info, "Bluetooth powered on")
            self.reScan()
        case .resetting:
            log(.info, "Bluetooth resetting")
        case .unauthorized:
            log(.error, "Bluethooth unauthorized")
        case .unsupported:
            log(.error, "Bluetooth unsupported")
        default:
            log(.warning, "Bluetooth state unknown")
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        log(.done, "Did connect peripheral")
        if let rfduino = rfduinos.findRFDuino(peripheral) {
            rfduino.didConnect()
            delegate?.didConnect(to: rfduino, manager: self)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log(.stop, "Did disconnect peripheral")
        if let rfduino = rfduinos.findRFDuino(peripheral) {
            rfduino.didDisconnect()
        }
    }
    
     func centralManager(_ centralManager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.rfduinos.insertIfNotContained(RFDuino(peripheral: peripheral))
        let rfDuino = self.rfduinos.findRFDuino(peripheral)
        rfDuino?.RSSI = RSSI
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log(.error, "Did fail to connect to peripheral")
    }
}
