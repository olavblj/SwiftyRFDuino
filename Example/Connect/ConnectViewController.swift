//
//  ViewController.swift
//  OpenBCI App
//
//  Created by Olav Bakke Ljosland on 06/11/2017.
//  Copyright © 2017 Olav Bakke Ljosland. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnectViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var manager:RFDuinoManager = {
        let manager = RFDuinoManager.shared
        manager.delegate = self
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        self.setupRFDuino()
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func setupRFDuino() {
        self.manager.delegate = self
        self.manager.startScanningForRFDuinos()
        self.manager.setLogging(enabled: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension ConnectViewController: UITableViewDelegate {
    
}


extension ConnectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(.info, "Number of RFDuinos: \(self.manager.rfduinos.count)")
        return max(self.manager.rfduinos.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.manager.rfduinos.count > 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "No results"
            return cell
        }
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        let rfduino = self.manager.rfduinos[indexPath.row]
        
        if rfduino.isTimedOut {
            cell.textLabel?.textColor = UIColor.gray
            cell.textLabel?.text = rfduino.name
            cell.detailTextLabel?.text = "(timed out)"
        } else {
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.text = rfduino.name
            cell.detailTextLabel?.text = String(describing: rfduino.RSSI ?? 0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.manager.rfduinos.count > 0 else {
            return
        }
        
        let rfduino = self.manager.rfduinos[indexPath.row]
        self.manager.connect(to: rfduino)
    }
}

extension ConnectViewController: RFDuinoManagerDelegate {
    func didDiscover(_ rfduino: RFDuino, manager: RFDuinoManager) {
        self.tableView.reloadData()
    }
    
    func didConnect(to rfduino: RFDuino, manager: RFDuinoManager) {
        self.tableView.reloadData()
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ConnectViewController: RFDuinoDelegate {
    func didTimeout(_ rfduino: RFDuino) {
        self.tableView.reloadData()
    }
    
    func didDisconnect(_ rfduino: RFDuino) {
        self.tableView.reloadData()
    }
    
    func didDiscover(_ rfduino: RFDuino) {
        self.tableView.reloadData()
    }
    
    func didDiscoverServices(_ rfduino: RFDuino) {}
    func didDiscoverCharacteristics(_ rfduino: RFDuino) {}
    func didSendData(_ rfduino: RFDuino, forCharacteristic: CBCharacteristic, error: Error?) {}
    func didReceiveData(_ rfduino: RFDuino, data: Data?) {}
}
