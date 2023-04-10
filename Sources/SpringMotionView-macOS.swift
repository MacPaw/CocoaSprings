//
//  File.swift
//  
//
//  Created by Anton Barkov on 29.03.2023.
//

#if canImport(AppKit)

import AppKit

open class SpringMotionView: NSView {
    
    /// Configuration that adjusts the spring physics behind the animation.
    public var configuration: SpringConfiguration = .default {
        didSet {
            motionPhysics = .init(configuration: configuration, timeStep: timeStep)
        }
    }
    
    /// A closure that is called on every step of animation.
    /// Within it you should update any relevant constraints to position the view according
    /// to the `CGPoint` parameter passed into the closure. This point represents the center of the view.
    public var onPositionUpdate: ((NSPoint) -> Void)?
    
    /// Moves the view to the specified point with spring animation.
    ///
    /// - Parameter point: a `CGPoint` that defines the view's destination and represents the view's center point.
    public func move(to point: NSPoint) {
        destinationPoint = point
    }

    // MARK: Private
    private var destinationPoint: NSPoint? {
        didSet {
            startMotion()
        }
    }

    private lazy var motionPhysics = SpringMotionPhysics(configuration: configuration, timeStep: timeStep)
    private let timeStep: Float = 0.008
    private var currentMotionState: SpringMotionState?
    private var displayLink: CVDisplayLink?
    private var anchorWindowFrameObservation: NSKeyValueObservation?
}

// MARK: - Start/stop motion
private extension SpringMotionView {

    func startMotion() {
        guard displayLink == nil,
              let screenDescription = NSScreen.main?.deviceDescription,
              let screenNumber = screenDescription[.init("NSScreenNumber")] as? NSNumber else { return }

        CVDisplayLinkCreateWithCGDisplay(screenNumber.uint32Value, &displayLink)
        guard let displayLink else { return }

        CVDisplayLinkSetOutputHandler(displayLink) { [weak self] _, inNow, _, _, _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let destinationPoint = self.destinationPoint else {
                    self?.stopMotion()
                    return
                }
                
                let currentState = self.currentMotionState ?? .init(position: frame.center, velocity: .zero)
                let nextState = self.motionPhysics.calculateNextState(from: currentState, destinationPoint: destinationPoint)
                
                if abs(nextState.velocity.horizontal) < 0.01 && abs(nextState.velocity.vertical) < 0.01 {
                    self.stopMotion()
                    return
                }
                
                self.onPositionUpdate?(nextState.position)
                self.currentMotionState = nextState
            }
            
            return kCVReturnSuccess
        }
        
        CVDisplayLinkStart(displayLink)
    }

    func stopMotion() {
        guard let link = displayLink else { return }
        CVDisplayLinkStop(link)
        displayLink = nil
        currentMotionState = nil
    }
}

#endif
