//
//  RFDuinoUtils.swift
//  OpenBCI App
//
//  Created by Olav Bakke Ljosland on 09/11/2017.
//  Copyright © 2017 Olav Bakke Ljosland. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct RFDuinoUUIDS {
    public static var discoverUUID: String?
    public static var disconnectUUID: String?
    public static var receiveUUID: String?
    public static var sendUUID: String?
}

internal enum RFDuinoUUID: String {
    case discover = "2220"
    case disconnect = "2221"
    case receive = "2222"
    case send = "2223"
    
    var id: CBUUID {
        get {
            switch self {
            case .discover: return CBUUID(string: RFDuinoUUIDS.discoverUUID ?? self.rawValue)
            case .disconnect: return CBUUID(string: RFDuinoUUIDS.disconnectUUID ?? self.rawValue)
            case .receive: return CBUUID(string: RFDuinoUUIDS.receiveUUID ?? self.rawValue)
            case .send: return CBUUID(string: RFDuinoUUIDS.sendUUID ?? self.rawValue)
            }
        }
    }
}

extension Array where Element: RFDuino {
    mutating func insertIfNotContained(_ rfduino: RFDuino) {
        if !(self.contains { return $0.peripheral == rfduino.peripheral }) {
            // append the newly discovered rfduino
            self.append(rfduino as! Element)
            rfduino.confirmAndTimeout()
        } else {
            // find existing rfduino and notify it of rediscovery
            let indexOfExistingRFDuino = self.index { return $0.peripheral == rfduino.peripheral }
            let existingRFDuino = self[indexOfExistingRFDuino!]
            existingRFDuino.peripheral.delegate = existingRFDuino
            existingRFDuino.confirmAndTimeout()
        }
    }
    
    func findRFDuino(_ peripheral: CBPeripheral) -> RFDuino? {
        let indexOfRFDuino = self.index { return $0.peripheral == peripheral }
        if let index = indexOfRFDuino {
            return self[index]
        } else {
            return nil
        }
    }
}

