//
//  MouseHandlingView.swift
//  CocoaSpringsDemo-macOS
//
//  Created by Anton Barkov on 04.04.2023.
//

import Cocoa

final class MouseHandlingView: NSView {
    
    var onMouseDown: ((NSPoint) -> Void)?
    var onMouseDragged: ((NSPoint) -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        var pointInView = convert(event.locationInWindow, from: nil)
        onMouseDown?(pointInView)

        var shouldContinue = true
        while shouldContinue {
            guard let nextEvent = window?.nextEvent(matching: [.leftMouseUp, .leftMouseDragged]) else {
                continue
            }

            pointInView = convert(nextEvent.locationInWindow, from: nil)
            let isInside = bounds.contains(pointInView)

            switch nextEvent.type {
            case .leftMouseDragged:
                if isInside {
                    onMouseDragged?(pointInView)
                }

            case .leftMouseUp:
                shouldContinue = false

            default:
                break
            }
        }
    }
}
