//
//  SpringMotionPanel.swift
//
//
//  Created by Oryna Semenets on 17.10.2024.
//

#if canImport(AppKit)
import AppKit

open class SpringMotionPanel: NSPanel, SpringMotionWindowProtocol {
    /// Implement the shared protocol in the NSPanel subclass.
    
    public var configuration: SpringConfiguration = .default {
        didSet {
            motionPhysics = .init(configuration: configuration, timeStep: 0.008)
        }
    }
    
    public var destinationPoint: NSPoint? {
        didSet {
            startMotion()
        }
    }
    lazy public var motionPhysics = SpringMotionPhysics(configuration: configuration, timeStep: 0.008)
    public var currentMotionState: SpringMotionState?
    public var displayLink: CVDisplayLink?
    public var anchorWindowFrameObservation: NSKeyValueObservation?
}

// MARK: - Mouse events
extension SpringMotionPanel {
    
    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        /// Stop window from moving if the user grabbed it.
        if isMovableByWindowBackground {
            stopMotion()
        }
    }
    
    override open func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        /// Continue movement after the user lets go.
        if isMovableByWindowBackground {
            startMotion()
        }
    }
}

#endif
