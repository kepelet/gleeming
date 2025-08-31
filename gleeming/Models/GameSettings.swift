//
//  GameSettings.swift
//  gleeming
//
//  Created by ervan on 30/08/25.
//

import Foundation
import SwiftUI

// MARK: - Game Settings
class GameSettings: ObservableObject {
    @Published var gridSize: Int = 4
    @Published var difficultyMode: DifficultyMode = .random
    @Published var soundEffectsEnabled: Bool = true
    @Published var backgroundMusicEnabled: Bool = false
    @Published var animationsEnabled: Bool = true
    @Published var hapticFeedbackEnabled: Bool = true
    @Published var volume: Float = 0.8
    @Published var selectedTheme: Theme = .auto
    @Published var showDuration: Double = 0.6
    
    static let shared = GameSettings()
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Difficulty Mode
    enum DifficultyMode: String, CaseIterable {
        case random = "Random"
        case progressive = "Progressive"
        
        var displayName: String {
            return rawValue
        }
        
        var description: String {
            switch self {
            case .random:
                return "Each level has a completely new random pattern"
            case .progressive:
                return "Each level adds one step to the previous pattern"
            }
        }
    }
    
    // MARK: - Grid Size Options
    var availableGridSizes: [Int] {
        return [3, 4, 5]
    }
    
    var gridSizeDisplay: String {
        return "\(gridSize)×\(gridSize)"
    }
    
    // MARK: - Theme Options
    enum Theme: String, CaseIterable {
        case auto = "Auto"
        case light = "Light"
        case dark = "Dark"
        
        var displayName: String {
            return rawValue
        }
        
        var description: String {
            switch self {
            case .auto:
                return "Follows system appearance"
            case .light:
                return "Always use light mode"
            case .dark:
                return "Always use dark mode"
            }
        }
    }
    
    // MARK: - Volume Display
    var volumeDisplay: String {
        return "\(Int(volume * 100))%"
    }
    
    // MARK: - Show Duration Display
    var showDurationDisplay: String {
        return "\(String(format: "%.1f", showDuration)) seconds"
    }
    
    // MARK: - Persistence (placeholder for future UserDefaults implementation)
    private func loadSettings() {
        // TODO: Load from UserDefaults
    }
    
    func saveSettings() {
        // TODO: Save to UserDefaults
    }
    
    // MARK: - Configuration Generation
    func createGameConfiguration() -> GameConfiguration {
        return GameConfiguration(
            gridSize: gridSize,
            initialSequenceLength: 3,
            maxSequenceLength: 20,
            showDuration: showDuration,
            betweenShowDelay: 0.3
        )
    }
}
