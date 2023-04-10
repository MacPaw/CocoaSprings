//
//  SpringMotionLayer.swift
//  
//
//  Created by Anton Barkov on 29.03.2023.
//

import Foundation
import QuartzCore

open class SpringMotionLayer: CALayer {
    
    /// Configuration that adjusts the spring physics behind the animation.
    public var configuration: SpringConfiguration = .default {
        didSet {
            motionPhysics = .init(configuration: configuration, timeStep: timeStep)
        }
    }
    
    /// Moves the layer to the specified point with spring animation.
    ///
    /// - Parameter point: a `CGPoint` that defines the layer's destination and represents the layer's center point.
    public func move(to point: CGPoint) {
        motionStates = motionPhysics.calculateAllStates(
            from: getCurrentMotionState(),
            destinationPoint: point
        )

        let animation = CAKeyframeAnimation()
        animation.keyPath = "position"
        animation.values = motionStates.map { $0.position.nsValue }
        animation.duration = Double(motionStates.count) * Double(timeStep)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        removeAllAnimations()
        add(animation, forKey: springAnimationKey)
        animationStartTime = CACurrentMediaTime()
    }
    
    // MARK: Private
    private lazy var motionPhysics = SpringMotionPhysics(configuration: configuration, timeStep: timeStep)
    private var motionStates = [SpringMotionState]()
    private let timeStep: Float = 0.001
    private let springAnimationKey = "spring-motion"
    private var animationStartTime: CFTimeInterval?
}

// MARK: - Private
private extension SpringMotionLayer {
    
    private func getCurrentMotionState() -> SpringMotionState {
        let defaultState = SpringMotionState(
            position: presentation()?.position ?? position,
            velocity: .zero
        )
        
        guard let animation = animation(forKey: springAnimationKey), let animationStartTime else {
            return defaultState
        }

        let totalDuration = animation.duration
        let elapsedDuration = CACurrentMediaTime() - animationStartTime
        guard elapsedDuration < totalDuration else { return defaultState }

        let currentStateIndex = Int(elapsedDuration / Double(timeStep))
        guard currentStateIndex < motionStates.count else { return defaultState }
        return motionStates[currentStateIndex]
    }
}
