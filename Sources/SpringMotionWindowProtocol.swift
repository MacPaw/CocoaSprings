//
//  SpringMotionWindowProtocol.swift
//
//
//  Created by Oryna Semenets on 17.10.2024.
//

#if canImport(AppKit)
import AppKit

public protocol SpringMotionWindowProtocol: NSWindow {
    var configuration: SpringConfiguration { get set }
    var destinationPoint: NSPoint? { get set }
    var motionPhysics: SpringMotionPhysics { get set }
    var currentMotionState: SpringMotionState? { get set }
    var displayLink: CVDisplayLink? { get set }
    var anchorWindowFrameObservation: NSKeyValueObservation? { get set }
    
    func move(to point: NSPoint)
    func pinToWindow(_ anchorWindow: NSWindow, offsetFromCenter: NSPoint)
    func unpinFromWindow()
    func startMotion()
    func stopMotion()
}

// MARK: - API
public extension SpringMotionWindowProtocol {
    
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

// MARK: - Start/stop motion
private extension SpringMotionWindowProtocol {
    
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

open class SpringMotionBase: NSWindow, SpringMotionWindowProtocol {
    
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
extension SpringMotionBase {
    
    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        // Stop window from moving if the user grabbed it.
        if isMovableByWindowBackground {
            stopMotion()
        }
    }
    
    override open func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        // Continue movement after the user lets go.
        if isMovableByWindowBackground {
            startMotion()
        }
    }
}

#endif
