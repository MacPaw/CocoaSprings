//
//  File.swift
//  
//
//  Created by Anton Barkov on 31.03.2023.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension CGPoint {
    
    var nsValue: NSValue {
        #if os(iOS)
        return NSValue(cgPoint: self)
        #else
        return NSValue(point: NSPointFromCGPoint(self))
        #endif
    }
    
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
}
