//
//  NSRect+Extensions.swift
//  
//
//  Created by Anton Barkov on 04.04.2023.
//

import Foundation

extension CGRect {
    
    var center: CGPoint {
        .init(x: midX, y: midY)
    }
}
