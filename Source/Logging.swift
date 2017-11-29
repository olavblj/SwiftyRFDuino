//
//  Debugging.swift
//  RFDuinoSwift4
//
//  Created by Olav Bakke Ljosland on 29/11/2017.
//  Copyright © 2017 Olav Bakke Ljosland. All rights reserved.
//


import Foundation


/**
 The amount of prints desirable to get out.

 Setting the session's LogLevel to a lower rawValue gives more prints.

 This means systemEvents are considered more important than debug and programFlow etc.
*/
enum LogLevel: Int {
    case all = 0
    case debug = 1
    case programFlow = 2
    case systemEvents = 3
    case none = 4
}


enum Log: String {
    // <-- DEBUG -->
    case point = "⛳️"
    case object = "🎾"
    // <-- PROGRAM FLOW -->
    case trying = "🌀"
    case created = "✨"
    case start = "🏁"
    case stop = "🛑"
    case done = "✅"
    case checkpoint = "🚙"
    // <-- SYSTEM EVENT -->
    case error = "❌"
    case warning = "⚠️"
    case info = "ℹ️"

    func getEmoji() -> String {
        return self.rawValue
    }
    
    func getLogLevel() -> LogLevel {
        switch self {
        case .point, .object:
            return .debug
        case .trying, .created, .start, .stop, .done, .checkpoint:
            return .programFlow
        case .error, .warning, .info:
            return .systemEvents
        }
    }
    
    func shouldPrint() -> Bool {
        return self.getLogLevel().rawValue >= RFDuinoManager.shared.logLevel.rawValue
    }
}

func log(_ type: Log = .point, _ msg: String) {
    if type.shouldPrint() {
        print(" \(type.getEmoji()) -- \(msg)")
    }
}
