//
//  SwiftStub.swift
//  Runner
//
//  Created by 杨萧玉 on 2021/11/22.
//

import UIKit

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
        return "\(str) DartNative!"
    }
    
    func fooClosure(_ block:@escaping (String) -> String) {
        DispatchQueue.global(qos: .default).async {
            let result = block("Hello")
            print(result)
        }
    }
}
