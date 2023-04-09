//
//  DemoWindow.swift
//  CocoaSpringsDemo-macOS
//
//  Created by Anton Barkov on 04.04.2023.
//

import Cocoa
import CocoaSprings

final class DemoWindow: SpringMotionWindow {
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        contentView = makeContentView()
        backgroundColor = .clear
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        styleMask = [.borderless]
        hasShadow = false
        titleVisibility = .hidden
        level = .popUpMenu
    }
    
    private func makeContentView() -> NSView {
        let label = NSTextField(wrappingLabelWithString: "This window is pinned to the main window.\n\nTry dragging either one of them around.")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11)
        label.alignment = .center
        label.isSelectable = false
        
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.material = .fullScreenUI
        view.state = .active
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        view.layer?.borderColor = NSColor.darkGray.cgColor
        view.layer?.borderWidth = 1
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.widthAnchor.constraint(equalToConstant: 250)
        ])
        return view
    }
}
