//
//  SpringMotionWindow.swift
//  
//
//  Created by Anton Barkov on 29.03.2023.
//

#if canImport(AppKit)

import AppKit

open class SpringMotionWindow: NSWindow {

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
    
    func move(to point: NSPoint) {
        destinationPoint = point
    }

    /// Starts following the given window.
    /// `offsetFromCenter` is the difference between this window's center and the anchor window's center.
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
public extension SpringMotionWindow {

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        // Stop window from moving if the user grabbed it.
        if isMovableByWindowBackground {
            stopMotion()
        }
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        // Continue movement after the user lets go.
        if isMovableByWindowBackground {
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
                
                self.setFrame(.init(x: nextState.position.x - frame.width / 2,
                                    y: nextState.position.y - frame.height / 2,
                                    width: frame.width,
                                    height: frame.height), display: false)
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
