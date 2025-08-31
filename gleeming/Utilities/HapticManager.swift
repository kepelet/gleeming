//
//  HapticManager.swift
//  gleeming
//
//  Created by ervan on 31/08/25.
//

import Foundation
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        impactFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
        selectionFeedbackGenerator.prepare()
    }
    
    // MARK: - Haptic Feedback Methods
    
    func correctSelection() {
        guard GameSettings.shared.hapticFeedbackEnabled else { return }
        
        #if targetEnvironment(simulator)
        print("Simulator detected - would trigger correct selection haptic feedback")
        #else
        selectionFeedbackGenerator.selectionChanged()
        #endif
    }
    
    func wrongSelection() {
        guard GameSettings.shared.hapticFeedbackEnabled else { return }
        
        #if targetEnvironment(simulator)
        print("Simulator detected - would trigger wrong selection haptic feedback")
        #else
        notificationFeedbackGenerator.notificationOccurred(.error)
        #endif
    }
    
    func levelCompleted() {
        guard GameSettings.shared.hapticFeedbackEnabled else { return }
        
        #if targetEnvironment(simulator)
        print("Simulator detected - would trigger level completed haptic feedback")
        #else
        notificationFeedbackGenerator.notificationOccurred(.success)
        #endif
    }
    
    func sequenceStarted() {
        guard GameSettings.shared.hapticFeedbackEnabled else { return }
        
        #if targetEnvironment(simulator)
        print("Simulator detected - would trigger sequence started haptic feedback")
        #else
        impactFeedbackGenerator.impactOccurred()
        #endif
    }
    
    func gameStarted() {
        guard GameSettings.shared.hapticFeedbackEnabled else { return }
        
        #if targetEnvironment(simulator)
        print("Simulator detected - would trigger game started haptic feedback")
        #else
        notificationFeedbackGenerator.notificationOccurred(.warning)
        #endif
    }
}
