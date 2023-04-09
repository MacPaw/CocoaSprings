//
//  AppConfig.swift
//  CocoaSpringsDemo-macOS
//
//  Created by Anton Barkov on 03.04.2023.
//

import Combine
import CocoaSprings

enum AppConfig {
    
    enum EquilibriumMode: Equatable {
        case auto(timeInterval: Double)
        case manual
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.manual, .manual):
                return true
            case (.auto(let lhsInterval), .auto(let rhsInterval)):
                return lhsInterval == rhsInterval
            default:
                return false
            }
        }
    }
    
    static let equilibriumMode = CurrentValueSubject<EquilibriumMode, Never>(.auto(timeInterval: 1))
    static let isLayerActive = CurrentValueSubject<Bool, Never>(true)
    static let isViewActive = CurrentValueSubject<Bool, Never>(false)
    static let isWindowActive = CurrentValueSubject<Bool, Never>(false)
    static let layerSpringConfiguration = CurrentValueSubject<SpringConfiguration, Never>(.default)
    static let viewSpringConfiguration = CurrentValueSubject<SpringConfiguration, Never>(.default)
    static let windowSpringConfiguration = CurrentValueSubject<SpringConfiguration, Never>(.default)
}
