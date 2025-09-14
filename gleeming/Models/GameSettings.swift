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
    @Published private var _gridSize: Int = 4
    @Published var difficultyMode: DifficultyMode = .random
    @Published var soundEffectsEnabled: Bool = true
    @Published var backgroundMusicEnabled: Bool = false
    @Published var confettiEnabled: Bool = true
    @Published var hapticFeedbackEnabled: Bool = true
    @Published var volume: Float = 0.8
    @Published var selectedTheme: Theme = .auto
    @Published var showDuration: Double = 0.6
    @Published var timedModeEnabled: Bool = false
    @Published var forgivingModeEnabled: Bool = true
    @Published var notificationsEnabled: Bool = true
    @Published var visualMode: VisualMode = .full
    
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
    enum GridSize: Int, CaseIterable {
        case small = 3
        case medium = 4
        case large = 5
        
        var displayName: String {
            switch self {
            case .small:
                return "3×3"
            case .medium:
                return "4×4"
            case .large:
                return "5×5"
            }
        }
        
        var description: String {
            switch self {
            case .small:
                return "Perfect for beginners"
            case .medium:
                return "Good balance of challenge"
            case .large:
                return "Maximum difficulty"
            }
        }
    }
    
    var gridSize: GridSize {
        get {
            return GridSize(rawValue: _gridSize) ?? .medium
        }
        set {
            _gridSize = newValue.rawValue
        }
    }
    
    var availableGridSizes: [Int] {
        return [3, 4, 5]
    }
    
    var gridSizeDisplay: String {
        return gridSize.displayName
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
    
    // MARK: - Visual Mode Options
    enum VisualMode: String, CaseIterable {
        case zen = "Zen"
        case minimal = "Minimal"
        case full = "Full"
        
        var displayName: String {
            return rawValue
        }
        
        var description: String {
            switch self {
            case .zen:
                return "Show only tiles for maximum focus"
            case .minimal:
                return "Show essential controls only"
            case .full:
                return "Show complete interface with all elements"
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
    
    // MARK: - Persistence
    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        if let difficultyRawValue = defaults.object(forKey: "difficultyMode") as? String,
           let difficulty = DifficultyMode(rawValue: difficultyRawValue) {
            difficultyMode = difficulty
        }
        
        let gridSizeValue = defaults.integer(forKey: "gridSize")
        if gridSizeValue != 0 {
            _gridSize = gridSizeValue
        }
        
        if defaults.object(forKey: "soundEffectsEnabled") != nil {
            soundEffectsEnabled = defaults.bool(forKey: "soundEffectsEnabled")
        }
        
        if defaults.object(forKey: "backgroundMusicEnabled") != nil {
            backgroundMusicEnabled = defaults.bool(forKey: "backgroundMusicEnabled")
        }
        
        if defaults.object(forKey: "confettiEnabled") != nil {
            confettiEnabled = defaults.bool(forKey: "confettiEnabled")
        }
        
        if defaults.object(forKey: "hapticFeedbackEnabled") != nil {
            hapticFeedbackEnabled = defaults.bool(forKey: "hapticFeedbackEnabled")
        }
        
        if defaults.object(forKey: "volume") != nil {
            volume = defaults.float(forKey: "volume")
        }
        
        if let themeRawValue = defaults.object(forKey: "selectedTheme") as? String,
           let theme = Theme(rawValue: themeRawValue) {
            selectedTheme = theme
        }
        
        if defaults.object(forKey: "showDuration") != nil {
            showDuration = defaults.double(forKey: "showDuration")
        }
        
        if defaults.object(forKey: "timedModeEnabled") != nil {
            timedModeEnabled = defaults.bool(forKey: "timedModeEnabled")
        }
        
        if defaults.object(forKey: "forgivingModeEnabled") != nil {
            forgivingModeEnabled = defaults.bool(forKey: "forgivingModeEnabled")
        }
        
        if defaults.object(forKey: "notificationsEnabled") != nil {
            notificationsEnabled = defaults.bool(forKey: "notificationsEnabled")
        }
        
        if let visualModeRawValue = defaults.object(forKey: "visualMode") as? String,
           let mode = VisualMode(rawValue: visualModeRawValue) {
            visualMode = mode
        }
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        
        defaults.set(difficultyMode.rawValue, forKey: "difficultyMode")
        defaults.set(_gridSize, forKey: "gridSize")
        defaults.set(soundEffectsEnabled, forKey: "soundEffectsEnabled")
        defaults.set(backgroundMusicEnabled, forKey: "backgroundMusicEnabled")
        defaults.set(confettiEnabled, forKey: "confettiEnabled")
        defaults.set(hapticFeedbackEnabled, forKey: "hapticFeedbackEnabled")
        defaults.set(volume, forKey: "volume")
        defaults.set(selectedTheme.rawValue, forKey: "selectedTheme")
        defaults.set(showDuration, forKey: "showDuration")
        defaults.set(timedModeEnabled, forKey: "timedModeEnabled")
        defaults.set(forgivingModeEnabled, forKey: "forgivingModeEnabled")
        defaults.set(notificationsEnabled, forKey: "notificationsEnabled")
        defaults.set(visualMode.rawValue, forKey: "visualMode")
    }
    
    // MARK: - Configuration Generation
    func createGameConfiguration() -> GameConfiguration {
        return GameConfiguration(
            gridSize: gridSize.rawValue,
            initialSequenceLength: 3,
            maxSequenceLength: 20,
            showDuration: showDuration,
            betweenShowDelay: 0.3
        )
    }
}
