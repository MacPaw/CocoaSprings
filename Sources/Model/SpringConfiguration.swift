//
//  File.swift
//  
//
//  Created by Anton Barkov on 29.03.2023.
//

import Foundation

public struct SpringConfiguration {
    /// Controls how fast the spring motion oscillates.
    /// The higher the value, the faster the object moves towards equilibrium.
    public var angularFrequency: Float
    /// Controls how fast the spring motion decays.
    /// The lower the value, the less velocity is lost upon each oscillation. The value must range from 0 to 1.
    public var dampingRatio: Float

    public static let `default` = Self(angularFrequency: 7.5, dampingRatio: 0.5)
    
    public init(angularFrequency: Float, dampingRatio: Float) {
        self.angularFrequency = angularFrequency
        self.dampingRatio = dampingRatio
    }
}
