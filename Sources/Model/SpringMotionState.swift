//
//  SpringMotionState.swift
//  
//
//  Created by Anton Barkov on 05.04.2023.
//

import Foundation

final class SpringMotionState {
    
    struct Velocity {
        
        let horizontal: Double
        let vertical: Double
        
        var isZero: Bool {
            horizontal == 0 && vertical == 0
        }
        
        static let zero = Self(horizontal: 0, vertical: 0)
    }
    
    let position: CGPoint
    let velocity: Velocity
    
    init(position: CGPoint, velocity: Velocity) {
        self.position = position
        self.velocity = velocity
    }
}
