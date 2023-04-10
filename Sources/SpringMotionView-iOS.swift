//
//  SpringMotionView-iOS.swift
//  
//
//  Created by Anton Barkov on 29.03.2023.
//

#if canImport(UIKit)

import UIKit

open class SpringMotionView: UIView {
    
    /// Configuration that adjusts the spring physics behind the animation.
    public var configuration: SpringConfiguration = .default {
        didSet {
            motionPhysics = .init(configuration: configuration, timeStep: timeStep)
        }
    }
    
    /// A closure that is called on every step of animation.
    /// Within it you should update any relevant constraints to position the view according
    /// to the `CGPoint` parameter passed into the closure. This point represents the center of the view.
    public var onPositionUpdate: ((CGPoint) -> Void)?
    
    /// Moves the view to the specified point with spring animation.
    ///
    /// - Parameter point: a `CGPoint` that defines the view's destination and represents the view's center point.
    public func move(to point: CGPoint) {
        destinationPoint = point
    }

    // MARK: Private
    private var destinationPoint: CGPoint? {
        didSet {
            startMotion()
        }
    }

    private lazy var motionPhysics = SpringMotionPhysics(configuration: configuration, timeStep: timeStep)
    private let timeStep: Float = 0.008
    private var currentMotionState: SpringMotionState?
    private var displayLink: CADisplayLink?
    private var anchorWindowFrameObservation: NSKeyValueObservation?
}

// MARK: - Start/stop motion
private extension SpringMotionView {

    func startMotion() {
        guard displayLink == nil else { return }
        displayLink = CADisplayLink(target: self, selector: #selector(updatePosition))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc func updatePosition() {
        guard let destinationPoint else {
            stopMotion()
            return
        }
        
        let currentState = currentMotionState ?? .init(position: frame.center, velocity: .zero)
        let nextState = motionPhysics.calculateNextState(from: currentState, destinationPoint: destinationPoint)
        
        if abs(nextState.velocity.horizontal) < 0.01 && abs(nextState.velocity.vertical) < 0.01 {
            stopMotion()
            return
        }
        
        onPositionUpdate?(nextState.position)
        currentMotionState = nextState
    }

    func stopMotion() {
        guard let link = displayLink else { return }
        link.invalidate()
        displayLink = nil
        currentMotionState = nil
    }
}

#endif
