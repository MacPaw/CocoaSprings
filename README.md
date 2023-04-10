![CocoaSprings](https://github.com/MacPaw/CocoaSprings/blob/main/Screenshots/header.gif)

## Contents
- [About](#about)
- [Installation](#installation)
- [Usage](#usage)
  - [SpringConfiguration](#springconfiguration)
  - [SpringMotionLayer](#springmotionlayer)
  - [SpringMotionView](#springmotionview)
  - [SpringMotionWindow](#springmotionwindow)
- [Demo](#demo)
- [License](#license)

## About

CocoaSprings is a lightweight Swift package that simulates damped spring physics for basic AppKit & UIKit components. The package provides subclasses of `CALayer`, `UIView`, `NSView`, and `NSWindow`, which can be moved around the UI repeatedly without breaking the continuity of their motion. This allows for the implementation of fluid, interactive animations similar to this one:

![About](https://github.com/MacPaw/CocoaSprings/blob/main/Screenshots/about.gif)

The math behind the animations is based on [this excellent blog post by Ryan Juckett](https://www.ryanjuckett.com/damped-springs/).

## Installation

CocoaSprings is available through SPM. Just add this repository as a dependency to your package or project.

```swift
dependencies: [
    .package(url: "https://github.com/MacPaw/CocoaSprings.git", branch: "main")
]
```

## Usage

### SpringConfiguration

The physics of CocoaSprings components is configured via the `SpringConfiguration` struct. It has two properties: 
- `angularFrequency` controls how fast an object moves towards its destination. The higher the value, the faster an object moves. Default value is `7.5`.
- `dampingRatio` controls how fast the spring motion decays. The lower the value, the less velocity is lost upon each oscillation. The value must range from 0 to 1, default is `0.5`.

Set the configuration on any component to adjust its physics:
```swift
let layer = SpringMotionLayer()
layer.configuration = SpringConfiguration(angularFrequency: 10, dampingRatio: 0.7)
```

### SpringMotionLayer

`SpringMotionLayer` is a `CALayer` subclass available for both iOS & macOS. 

Add it as a sublayer to the desired parent layer and call the `move(to:)` method to update the layer's position with spring animation.

Below is an example of a macOS `NSView` subclass that hosts a `SpringMotionLayer` and moves it to whichever point inside it gets clicked:

```swift
import AppKit
import CocoaSprings

final class ClickableView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private lazy var rootLayer = CALayer()
    
    private lazy var springMotionLayer: SpringMotionLayer = {
        let layer = SpringMotionLayer()
        layer.backgroundColor = NSColor.systemRed.cgColor
        layer.cornerRadius = 10
        layer.frame.size = .init(width: 20, height: 20)
        return layer
    }()
    
    private func setup() {
        layer = rootLayer
        wantsLayer = true
        rootLayer.addSublayer(springMotionLayer)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        springMotionLayer.move(to: convert(event.locationInWindow, from: nil))
    }
}
```

![Layer Example](https://github.com/MacPaw/CocoaSprings/blob/main/Screenshots/layer.gif)

### SpringMotionView

`SpringMotionView` is an `NSView`/`UIView` subclass, depending on the platform you're building for. 

Due to the fact that views are usually positioned using constraints, the client is responsible for updating the view's position during animation. On each frame of movement the view executes its `onUpdatePosition` closure, you must set it to update the relevant view's constraints.

Consider an example iOS snippet below, assume we've set up `SpringMotionView` and its constraints via Interface Builder: 

```swift
import UIKit
import CocoaSprings

final class ViewController: UIViewController {

    @IBOutlet weak var springMotionView: SpringMotionView!
    @IBOutlet weak var springMotionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var springMotionViewLeftConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Here we set up how the view should update its position
        // depending on the provided `point` parameter.
        springMotionView.onPositionUpdate = { [weak self] point in
            guard let self else { return }
            let size = self.springMotionView.frame.size
            self.springMotionViewLeftConstraint.constant = point.x - size.width / 2
            self.springMotionViewTopConstraint.constant = point.y - size.height / 2
        }
    }

    // UITapGestureRecognizer action
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        // Start moving to the tapped location
        springMotionView.move(to: sender.location(in: view))
    }
}
``` 

![View Example](https://github.com/MacPaw/CocoaSprings/blob/main/Screenshots/view.gif)

### SpringMotionWindow

`SpringMotionWindow` is an `NSWindow` subclass, available for macOS only.

- Call `move(to:)` to start animating position to a point on screen.
- Call `pinToWindow(_:offsetFromCenter:)` to make the window follow any other window on screen with spring animation (example below).
- Call `unpinFromWindow()` to stop following a previously followed window.

```swift
import AppKit
import CocoaSprings

final class ViewController: NSViewController {

    override func viewDidAppear() {
        super.viewDidAppear()
        
        let springMotionWindow = SpringMotionWindow()
        springMotionWindow.contentView = NSView()
        springMotionWindow.contentView?.wantsLayer = true
        springMotionWindow.contentView?.layer?.backgroundColor = NSColor.systemRed.cgColor
        springMotionWindow.contentView?.layer?.cornerRadius = 10
        springMotionWindow.setFrame(.init(origin: .zero, size: .init(width: 100, height: 100)), display: true)
        springMotionWindow.makeKeyAndOrderFront(nil)
        springMotionWindow.level = .mainMenu
        springMotionWindow.styleMask = [.borderless, .fullSizeContentView]
        springMotionWindow.backgroundColor = .clear
        springMotionWindow.isMovableByWindowBackground = true
        
        if let mainWindow = view.window {
            springMotionWindow.pinToWindow(mainWindow, offsetFromCenter: .init(x: 300, y: 100))
        }
    }
}
```

![View Example](https://github.com/MacPaw/CocoaSprings/blob/main/Screenshots/window.gif)

## Demo
For your convenience, most of the features described above are implemented in a demo project in this repository. Please refer to it for package usage examples.

![View Example](https://github.com/MacPaw/CocoaSprings/blob/main/Screenshots/demo.png)

## License

CocoaSprings is available under the MIT license.

See the [LICENSE](https://github.com/MacPaw/CocoaSprings/blob/master/LICENSE) file for more info.
