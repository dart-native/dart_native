//
//  SwiftStub.swift
//  Runner
//
//  Created by 杨萧玉 on 2021/11/22.
//

import UIKit

@objcMembers
class SwiftStub: NSObject {
    public static let instance = SwiftStub()
    
    public func fooString(_ str: String) -> String {
        return "\(str) DartNative!"
    }
    
    public func fooClosure(_ block:@escaping (String) -> String) {
        DispatchQueue.global(qos: .default).async {
            let result = block("Hello")
            print(result)
        }
    }
}
