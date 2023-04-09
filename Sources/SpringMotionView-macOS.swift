//
//  File.swift
//  
//
//  Created by Anton Barkov on 29.03.2023.
//

#if canImport(AppKit)

import AppKit

open class SpringMotionView: NSView {
    
    public var onPositionUpdate: ((NSPoint) -> Void)?

    public var configuration: SpringConfiguration = .default {
        didSet {
            motionPhysics = .init(configuration: configuration, timeStep: timeStep)
        }
    }
    
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
                guard let self, let destinationPoint else {
                    self?.stopMotion()
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
