//
//  ViewController.swift
//  CocoaSpringsDemo-macOS
//
//  Created by Anton Barkov on 03.04.2023.
//

import Cocoa

final class ConfigViewController: NSViewController {

    @IBOutlet private weak var equilibriumModeControl: NSSegmentedControl!
    @IBOutlet private weak var timeoutContainer: NSStackView!
    @IBOutlet private weak var timeoutTextField: NSTextField!
    @IBOutlet private weak var manualDescriptionLabel: NSTextField!
    
    @IBOutlet private weak var isLayerActiveControl: NSSwitch!
    @IBOutlet private weak var layerConfigContainer: NSStackView!
    @IBOutlet private weak var layerAngularFrequencyControl: NSSlider!
    @IBOutlet private weak var layerDampingRatioControl: NSSlider!
    
    @IBOutlet private weak var isViewActiveControl: NSSwitch!
    @IBOutlet private weak var viewConfigContainer: NSStackView!
    @IBOutlet private weak var viewAngularFrequencyControl: NSSlider!
    @IBOutlet private weak var viewDampingRatioControl: NSSlider!
    
    @IBOutlet private weak var isWindowActiveControl: NSSwitch!
    @IBOutlet private weak var windowConfigContainer: NSStackView!
    @IBOutlet private weak var windowAngularFrequencyControl: NSSlider!
    @IBOutlet private weak var windowDampingRatioControl: NSSlider!
    
    @IBAction func equilibriumModeDidChange(_ sender: Any) {
        updateEquilibriumModeConfig()
        timeoutContainer.isHidden = AppConfig.equilibriumMode.value == .manual
        manualDescriptionLabel.isHidden = AppConfig.equilibriumMode.value != .manual
    }
    
    @IBAction func timeoutDidChange(_ sender: Any) {
        updateEquilibriumModeConfig()
    }
    
    @IBAction func isLayerActiveDidChange(_ sender: NSSwitch) {
        AppConfig.isLayerActive.value = isLayerActiveControl.state == .on
        layerConfigContainer.isHidden = sender.state != .on
    }
    
    @IBAction func layerAngularFrequencyDidChange(_ sender: Any) {
        AppConfig.layerSpringConfiguration.value = .init(
            angularFrequency: layerAngularFrequencyControl.floatValue,
            dampingRatio: layerDampingRatioControl.floatValue / 100
        )
    }
    
    @IBAction func layerDampingRatioDidChange(_ sender: Any) {
        AppConfig.layerSpringConfiguration.value = .init(
            angularFrequency: layerAngularFrequencyControl.floatValue,
            dampingRatio: layerDampingRatioControl.floatValue / 100
        )
    }
    
    @IBAction func isViewActiveDidChange(_ sender: NSSwitch) {
        AppConfig.isViewActive.value = isViewActiveControl.state == .on
        viewConfigContainer.isHidden = sender.state != .on
    }
    
    @IBAction func viewAngularFrequencyDidChange(_ sender: Any) {
        AppConfig.viewSpringConfiguration.value = .init(
            angularFrequency: viewAngularFrequencyControl.floatValue,
            dampingRatio: viewDampingRatioControl.floatValue / 100
        )
    }
    
    @IBAction func viewDampingRatioDidChange(_ sender: Any) {
        AppConfig.viewSpringConfiguration.value = .init(
            angularFrequency: viewAngularFrequencyControl.floatValue,
            dampingRatio: viewDampingRatioControl.floatValue / 100
        )
    }
    
    @IBAction func isWindowActiveDidChange(_ sender: NSSwitch) {
        AppConfig.isWindowActive.value = isWindowActiveControl.state == .on
        windowConfigContainer.isHidden = sender.state != .on
    }
    
    @IBAction func windowAngularFrequencyDidChange(_ sender: Any) {
        AppConfig.windowSpringConfiguration.value = .init(
            angularFrequency: windowAngularFrequencyControl.floatValue,
            dampingRatio: windowDampingRatioControl.floatValue / 100
        )
    }
    
    @IBAction func windowDampingRatioDidChange(_ sender: Any) {
        AppConfig.windowSpringConfiguration.value = .init(
            angularFrequency: windowAngularFrequencyControl.floatValue,
            dampingRatio: windowDampingRatioControl.floatValue / 100
        )
    }
}

// MARK: - Private
private extension ConfigViewController {
    
    private func updateEquilibriumModeConfig() {
        switch equilibriumModeControl.selectedSegment {
        case 0:
            let stringValue = timeoutTextField.stringValue.trimmingCharacters(in: .whitespaces)
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            if let timeoutValue = formatter.number(from: stringValue)?.doubleValue, timeoutValue > 0 {
                AppConfig.equilibriumMode.value = .auto(timeInterval: timeoutValue)
            }
        case 1:
            AppConfig.equilibriumMode.value = .manual
        default:
            break
        }
    }
}

