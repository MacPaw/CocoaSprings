//
//  SimulationViewController.swift
//  CocoaSpringsDemo-macOS
//
//  Created by Anton Barkov on 03.04.2023.
//

import Cocoa
import Combine
import CocoaSprings

final class SimulationViewController: NSViewController {
    
    private var equilibriumPoint: NSPoint = .zero
    private var equilibriumUpdateTimer: Timer?
    private var equilibriumViewBottomConstraint: NSLayoutConstraint?
    private var equilibriumViewLeftConstraint: NSLayoutConstraint?
    private lazy var equilibriumView: NSView = {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.systemRed.cgColor
        view.layer?.cornerRadius = 10
        return view
    }()
    
    private lazy var mouseHandlingView: MouseHandlingView = {
        let handler: (NSPoint) -> Void = { [weak self] point in
            self?.equilibriumPoint = point
            self?.updateEquilibriumViewPosition()
            self?.moveSpringLayerToEquilibrium()
            self?.moveSpringViewToEquilibrium()
        }
        let view = MouseHandlingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onMouseDown = handler
        view.onMouseDragged = handler
        return view
    }()
    
    private lazy var springMotionLayer: SpringMotionLayer = {
        let layer = SpringMotionLayer()
        layer.backgroundColor = NSColor.lightGray.cgColor
        layer.frame = .init(origin: .zero, size: .init(width: 40, height: 40))
        layer.cornerRadius = 20
        return layer
    }()
    
    private var springMotionViewBottomConstraint: NSLayoutConstraint?
    private var springMotionViewLeftConstraint: NSLayoutConstraint?
    private lazy var springMotionView: SpringMotionView = {
        let view = SpringMotionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.gray.cgColor
        view.layer?.cornerRadius = 30
        return view
    }()
    
    private lazy var springMotionWindow = DemoWindow()
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Overrides
extension SimulationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        subscribeToAppConfig()
    }
}

// MARK: - Private
private extension SimulationViewController {
    
    func subscribeToAppConfig() {
        AppConfig.equilibriumMode
            .sink { [weak self] mode in
                self?.equilibriumUpdateTimer?.invalidate()
                self?.equilibriumUpdateTimer = nil
                
                switch mode {
                case .auto(let timeInterval):
                    self?.mouseHandlingView.isHidden = true
                    let timer = Timer(timeInterval: timeInterval, repeats: true) { [weak self] _ in
                        self?.setRandomEquilibriumPoint()
                        self?.updateEquilibriumViewPosition(animated: true)
                        self?.moveSpringLayerToEquilibrium()
                        self?.moveSpringViewToEquilibrium()
                    }
                    RunLoop.main.add(timer, forMode: .default)
                    self?.equilibriumUpdateTimer = timer
                    
                case .manual:
                    self?.mouseHandlingView.isHidden = false
                }
            }
            .store(in: &cancellables)
        
        AppConfig.isLayerActive
            .sink { [weak self] isActive in
                if isActive {
                    self?.springMotionLayer.isHidden = false
                    self?.moveSpringLayerToEquilibrium()
                } else {
                    self?.springMotionLayer.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        AppConfig.layerSpringConfiguration
            .sink { [weak self] config in
                self?.springMotionLayer.configuration = config
                self?.moveSpringLayerToEquilibrium()
            }
            .store(in: &cancellables)
        
        AppConfig.isViewActive
            .sink { [weak self] isActive in
                if isActive {
                    self?.springMotionView.isHidden = false
                    self?.moveSpringViewToEquilibrium()
                } else {
                    self?.springMotionView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        AppConfig.viewSpringConfiguration
            .sink { [weak self] config in
                self?.springMotionView.configuration = config
                self?.moveSpringViewToEquilibrium()
            }
            .store(in: &cancellables)
        
        AppConfig.isWindowActive
            .sink { [weak self] isActive in
                if isActive {
                    guard let mainWindow = self?.view.window else { return }
                    self?.springMotionWindow.makeKeyAndOrderFront(nil)
                    self?.springMotionWindow.pinToWindow(mainWindow, offsetFromCenter: .init(x: 150, y: 50))
                } else {
                    self?.springMotionWindow.close()
                    self?.springMotionWindow.unpinFromWindow()
                }
            }
            .store(in: &cancellables)
        
        AppConfig.windowSpringConfiguration
            .sink { [weak self] config in
                self?.springMotionWindow.configuration = config
            }
            .store(in: &cancellables)
    }
    
    func setRandomEquilibriumPoint() {
        let inset: CGFloat = 50
        let containerSize = view.frame.size
        let x = CGFloat.random(in: inset...containerSize.width - inset).rounded()
        let y = CGFloat.random(in: inset...containerSize.height - inset).rounded()
        equilibriumPoint = .init(x: x, y: y)
    }
    
    func updateEquilibriumViewPosition(animated: Bool = false) {
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.allowsImplicitAnimation = true
                context.duration = 0.3
                context.timingFunction = .init(name: .easeInEaseOut)
                equilibriumViewLeftConstraint?.constant = equilibriumPoint.x - equilibriumView.frame.width / 2
                equilibriumViewBottomConstraint?.constant = -(equilibriumPoint.y - equilibriumView.frame.height / 2)
                view.layoutSubtreeIfNeeded()
            }
        } else {
            equilibriumViewLeftConstraint?.constant = equilibriumPoint.x - equilibriumView.frame.width / 2
            equilibriumViewBottomConstraint?.constant = -(equilibriumPoint.y - equilibriumView.frame.height / 2)
            view.layoutSubtreeIfNeeded()
        }
    }
    
    func moveSpringLayerToEquilibrium() {
        guard AppConfig.isLayerActive.value else { return }
        springMotionLayer.move(to: equilibriumPoint)
    }
    
    func moveSpringViewToEquilibrium() {
        guard AppConfig.isViewActive.value else { return }
        springMotionView.move(to: equilibriumPoint)
    }
}

// MARK: - Setup
private extension SimulationViewController {
    
    func setup() {
        setupEquilibriumView()
        setupSpringMotionLayer()
        setupSpringMotionView()
        setupMouseHandlingView()
    }
    
    func setupEquilibriumView() {
        view.addSubview(equilibriumView)
        let bottom = equilibriumView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let left = equilibriumView.leftAnchor.constraint(equalTo: view.leftAnchor)
        equilibriumViewBottomConstraint = bottom
        equilibriumViewLeftConstraint = left
        
        NSLayoutConstraint.activate([
            bottom,
            left,
            equilibriumView.widthAnchor.constraint(equalToConstant: 20),
            equilibriumView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setupSpringMotionLayer() {
        let hostingView = NSView()
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.layer = CALayer()
        hostingView.wantsLayer = true
        hostingView.layer?.addSublayer(springMotionLayer)
        
        view.addSubview(hostingView, positioned: .below, relativeTo: equilibriumView)
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func setupSpringMotionView() {
        view.addSubview(springMotionView, positioned: .below, relativeTo: nil)
        let bottom = springMotionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let left = springMotionView.leftAnchor.constraint(equalTo: view.leftAnchor)
        springMotionViewBottomConstraint = bottom
        springMotionViewLeftConstraint = left
        
        NSLayoutConstraint.activate([
            bottom,
            left,
            springMotionView.widthAnchor.constraint(equalToConstant: 60),
            springMotionView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        springMotionView.onPositionUpdate = { [weak self] point in
            guard let self else { return }
            self.springMotionViewLeftConstraint?.constant = point.x - self.springMotionView.frame.width / 2
            self.springMotionViewBottomConstraint?.constant = -(point.y - self.springMotionView.frame.height / 2)
        }
    }
    
    func setupMouseHandlingView() {
        view.addSubview(mouseHandlingView)
        NSLayoutConstraint.activate([
            mouseHandlingView.topAnchor.constraint(equalTo: view.topAnchor),
            mouseHandlingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mouseHandlingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mouseHandlingView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
