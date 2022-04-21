//
//  DartNativeInterfaceDemo.swift
//  Runner
//
//  Created by 杨萧玉 on 2022/2/11.
//

import Foundation
import CocoaLumberjack
import dart_native

// Step 1: register a Swift class for interface entry using extension of `InterfaceRegistry`
extension InterfaceRegistry {
    // Step 2: binding the interface entry and implemention class using a static property.
    // The implemention of interface entry named "mySwiftInterface" is class LogInterface.
    // NOTE:
    // 1. "@objc" and "static" is required.
    // 2. The property name is interface entry name, must be unique.
    @objc static let logInterface = LogInterface.self
}

// Step 3: Implement the Swift class registered above based on SwiftInterfaceEntry protocol. Attribute "@objcMembers" is required.
@objcMembers
class LogInterface: NSObject, SwiftInterfaceEntry {
    // Step 4: Register selectors for interface methods
    // mappingTableForInterfaceMethod is declared in SwiftInterfaceEntry
    static func mappingTableForInterfaceMethod() -> [String : Any] {
        // Binding selectors and interface method
        return [
            "log": #selector(LogInterface.log(_:message:)),
            "setLevel": #selector(LogInterface.setLevel(_:)),
        ]
    }
    
    // Step 5: Implement Swift method for interface method "log"
    func log(_ level: UInt, message: String) {
        if let level = DDLogLevel(rawValue: level) {
            switch level {
            case .verbose:
                DDLogVerbose(message)
            case .debug:
                DDLogDebug(message)
            case .info:
                DDLogInfo(message)
            case .warning:
                DDLogWarn(message)
            case .error:
                DDLogError(message)
            default:
                print(message)
            }
        }
    }
    
    func setLevel(_ level: UInt) {
        if let level = DDLogLevel(rawValue: level) {
            dynamicLogLevel = level
        }
    }
}
