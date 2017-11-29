//
//  RFDuinoDelegate.swift
//  OpenBCI App
//
//  Created by Olav Bakke Ljosland on 09/11/2017.
//  Copyright © 2017 Olav Bakke Ljosland. All rights reserved.
//


import Foundation
import CoreBluetooth

protocol RFDuinoDelegate {
    func didTimeout(_ rfduino: RFDuino)
    func didDisconnect(_ rfduino: RFDuino)
    func didDiscover(_ rfduino: RFDuino)
    func didDiscoverServices(_ rfduino: RFDuino)
    func didDiscoverCharacteristics(_ rfduino: RFDuino)
    func didSendData(_ rfduino: RFDuino, forCharacteristic: CBCharacteristic, error: Error?)
    func didReceiveData(_ rfduino: RFDuino, data: Data?)
}


protocol RFDuinoManagerDelegate {
    func showAlert(title: String, message: String)
    func didDiscover(_ rfduino: RFDuino, manager: RFDuinoManager)
    func didConnect(to rfduino: RFDuino, manager: RFDuinoManager)
}
