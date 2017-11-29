# SwiftyRFDuino
[![version](https://img.shields.io/cocoapods/v/SwiftyRFDuino.svg)](https://cocoapods.org/pods/swiftyrfduino)
[![swift-version](https://img.shields.io/badge/swift%20version-4.0-orange.svg)](https://cocoapods.org/pods/swiftyrfduino)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://cocoapods.org/pods/swiftyrfduino)
[![platform](https://img.shields.io/cocoapods/p/SwiftyRFDuino.svg)](https://cocoapods.org/pods/swiftyrfduino)


## Installation
### Cocoapods
SwiftyRFDuino is installed through Cocoapods.

To integrate SwiftyRFDuino add `pod 'SwiftyRFDuino'` to your Podfile.

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftyRFDuino'
end
```

Then run `pod install` from your project directory.

## Usage

WARNING: The code in the current `Example` directory will not necessarily work with the current version of the Pod. It is recommended to not rely too heavily on it.

### Basic Setup

```swift
import SwiftyRFDuino

class MyViewController: UIViewController {

    // Always use the shared instance of RFDuinoManager
    var manager = RFDuinoManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        self.manager.delegate = self
        self.manager.startScanningForRFDuinos()
        self.manager.logLevel = .all

    }
}
```

#### RFDuinoManagerDelegate methods

```swift
extension MyViewController: RFDuinoManagerDelegate {
    func didDiscover(_ rfduino: RFDuino, manager: RFDuinoManager) {
        // Handle this (or ignore it)
    }

    func didConnect(to rfduino: RFDuino, manager: RFDuinoManager) {
        // Handle this (or ignore it)
    }

    func showAlert(title: String, message: String){
        // Notify the user of an event (example below)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
```


#### RFDuinoDelegate methods

```swift
extension MyViewController: RFDuinoDelegate {
  func didTimeout(_ rfduino: RFDuino) {
      // Handle this (or ignore it)
  }

  func didDisconnect(_ rfduino: RFDuino) {
      // Handle this (or ignore it)
  }

  func didDiscover(_ rfduino: RFDuino) {
      // Handle this (or ignore it)
  }

  func didDiscoverServices(_ rfduino: RFDuino) {
      // Handle this (or ignore it)
  }

  func didDiscoverCharacteristics(_ rfduino: RFDuino) {
      // Handle this (or ignore it)
  }

  func didSendData(_ rfduino: RFDuino, forCharacteristic: CBCharacteristic, error: Error?) {
      // Handle this (or ignore it)
  }

  func didReceiveData(_ rfduino: RFDuino, data: Data?) {
      // Handle this (or ignore it)
  }
}
```

### Interface

#### RFDuinoManager methods

```swift
func startScanningForRFDuinos()

func stopScanningForRFDuinos()

func connect(to rfduino: RFDuino)

func disconnect(from rfduino: RFDuino)
```

#### RFDuino methods

```swift
func discoverServices()

func send(data: Data)
```
