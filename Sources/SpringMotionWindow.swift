//
//  SpringMotionWindow.swift
//  
//
//  Created by Anton Barkov on 29.03.2023.
//

#if canImport(AppKit)

import AppKit

open class SpringMotionWindow: NSWindow {

    /// Configuration that adjusts the spring physics behind the animation.
    public var configuration: SpringConfiguration = .default {
        didSet {
            motionPhysics = .init(configuration: configuration, timeStep: 0.008)
        }
    }

    // MARK: Private
    private var destinationPoint: NSPoint? {
        didSet {
            startMotion()
        }
    }

    private lazy var motionPhysics = SpringMotionPhysics(configuration: configuration, timeStep: 0.008)
    private var currentMotionState: SpringMotionState?
    private var displayLink: CVDisplayLink?
    private var anchorWindowFrameObservation: NSKeyValueObservation?
}

// MARK: - API
public extension SpringMotionWindow {
    
    /// Moves the window to the specified point with spring animation.
    ///
    /// - Parameter point: a `CGPoint` that defines the window's destination and represents the window's center point.
    func move(to point: NSPoint) {
        destinationPoint = point
    }

    /// Starts following the given window with a certain offset from its center.
    ///
    /// - Parameter anchorWindow: an `NSWindow` that this window will follow.
    /// - Parameter offsetFromCenter: the difference between this window's center and the anchor window's center.
    func pinToWindow(_ anchorWindow: NSWindow, offsetFromCenter: NSPoint) {
        unpinFromWindow()
        move(to: anchorWindow.frame.center + offsetFromCenter)
        anchorWindowFrameObservation = anchorWindow.observe(\.frame, changeHandler: { [weak self] _, _ in
            self?.move(to: anchorWindow.frame.center + offsetFromCenter)
        })
    }

    /// Stops following a previously followed window, if any.
    func unpinFromWindow() {
        anchorWindowFrameObservation?.invalidate()
        anchorWindowFrameObservation = nil
    }
}

// MARK: - Mouse events
extension SpringMotionWindow {

    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        // Stop window from moving if the user grabbed it.
        if isMovableByWindowBackground, anchorWindowFrameObservation != nil {
            stopMotion()
        }
    }

    override open func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        // Continue movement after the user lets go.
        if isMovableByWindowBackground, anchorWindowFrameObservation != nil {
            startMotion()
        }
    }
}

// MARK: - Start/stop motion
private extension SpringMotionWindow {

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
                
                let currentState = self.currentMotionState ?? .init(position: self.frame.center, velocity: .zero)
                let nextState = self.motionPhysics.calculateNextState(from: currentState, destinationPoint: destinationPoint)
                
                if abs(nextState.velocity.horizontal) < 0.01 && abs(nextState.velocity.vertical) < 0.01 {
                    self.stopMotion()
                    return
                }
                
                self.setFrame(.init(x: nextState.position.x - self.frame.width / 2,
                                    y: nextState.position.y - self.frame.height / 2,
                                    width: self.frame.width,
                                    height: self.frame.height), display: false)
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
