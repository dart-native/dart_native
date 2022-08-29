//
//  SwiftStub.swift
//  Runner
//
//  Created by 杨萧玉 on 2021/11/22.
//
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import dart_native

@objcMembers
class SwiftStub: NSObject {
    static let instance = SwiftStub()
    var sideLength: Double = 1.0
    var perimeter: Double {
        get {
             return 3.0 * sideLength
        }
        set {
            sideLength = newValue / 3.0
        }
    }
    
    func fooString(_ str: String) -> String {
        DNInterfaceDemo.invokeMethod("totalCost", arguments: [0.123456789, 10, ["testArray"]]) { result, error in
            print("fuck \(result.debugDescription) \(error.debugDescription)")
        }
        return "\(str) DartNative!"
    }
    
    func fooClosure(_ block:@escaping (String) -> String) {
        DispatchQueue.global(qos: .default).async {
            let result = block("Hello")
            print(result)
        }
    }
}
