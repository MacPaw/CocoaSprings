//
//  SpringMotionPhysics.swift
//  
//
//  Created by Anton Barkov on 29.03.2023.
//

import Foundation

/// Implements the physics of spring motion.
///
/// The math is inspired by [this great post](https://www.ryanjuckett.com/damped-springs).
public final class SpringMotionPhysics {
    
    private let posPosCoef: Double
    private let posVelCoef: Double
    private let velPosCoef: Double
    private let velVelCoef: Double
    
    init(configuration: SpringConfiguration, timeStep: Float = 0.001) {
        let c = configuration
        let omegaZeta = c.angularFrequency * c.dampingRatio
        let alpha = c.angularFrequency * sqrtf(1.0 - c.dampingRatio * c.dampingRatio)
        let expTerm = expf(-omegaZeta * timeStep)
        let cosTerm = cosf(alpha * timeStep)
        let sinTerm = sinf(alpha * timeStep)
        let invAlpha = 1.0 / alpha
        let expSin = expTerm * sinTerm
        let expCos = expTerm * cosTerm
        let expOmegaZetaSin_Over_Alpha = expTerm * omegaZeta * sinTerm * invAlpha
        
        posPosCoef = Double(expCos + expOmegaZetaSin_Over_Alpha)
        posVelCoef = Double(expSin * invAlpha)
        velPosCoef = Double(-expSin * alpha - omegaZeta * expOmegaZetaSin_Over_Alpha)
        velVelCoef = Double(expCos - expOmegaZetaSin_Over_Alpha)
    }
    
    func calculateNextState(
        from state: SpringMotionState,
        destinationPoint: CGPoint
    ) -> SpringMotionState {
        let relPos = state.position - destinationPoint
        let horVelCoef = state.velocity.horizontal * posVelCoef
        let verVelCoef = state.velocity.vertical * posVelCoef
        let xCoef = relPos.x * posPosCoef
        let yCoef = relPos.y * posPosCoef
        
        return SpringMotionState(
            position: .init(x: xCoef + horVelCoef + destinationPoint.x,
                            y: yCoef + verVelCoef + destinationPoint.y),
            velocity: .init(horizontal: (relPos.x * velPosCoef) + (state.velocity.horizontal * velVelCoef),
                            vertical: (relPos.y * velPosCoef) + (state.velocity.vertical * velVelCoef))
        )
    }
    
    func calculateAllStates(
        from initialState: SpringMotionState,
        destinationPoint: CGPoint
    ) -> [SpringMotionState] {
        
        var currentState = initialState
        var allStates = [SpringMotionState]()
        
        var shouldContinue = true
        while shouldContinue {
            let nextState = calculateNextState(from: currentState, destinationPoint: destinationPoint)
            
            guard abs(nextState.velocity.horizontal) > 0.001 || abs(nextState.velocity.vertical) > 0.001 else {
                shouldContinue = false
                continue
            }
            
            allStates.append(nextState)
            currentState = nextState
        }
        
        return allStates
    }
}
