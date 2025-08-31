//
//  ThemeManager.swift
//  gleeming
//
//  Created by ervan on 31/08/25.
//

import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published private var gameSettings = GameSettings.shared
    
    private init() {}
    
    // MARK: - Color Scheme Determination
    
    var currentColorScheme: ColorScheme? {
        switch gameSettings.selectedTheme {
        case .auto:
            return nil // Let system decide
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    // MARK: - Theme Colors
    
    struct GameColors {
        // Grid cell colors
        let cellDefault: Color
        let cellHighlighted: Color
        let cellSelected: Color
        let cellWrong: Color
        let cellBorder: Color
        let cellBorderActive: Color
        
        // Background colors
        let primaryBackground: Color
        let secondaryBackground: Color
        let cardBackground: Color
        
        // Text colors
        let primaryText: Color
        let secondaryText: Color
        let accentText: Color
        
        // UI element colors
        let buttonPrimary: Color
        let buttonSecondary: Color
        let destructiveButton: Color
        
        // Game specific colors
        let scorePositive: Color
        let scoreNegative: Color
        let progressBar: Color
    }
    
    func colors(for colorScheme: ColorScheme) -> GameColors {
        switch colorScheme {
        case .light:
            return lightThemeColors
        case .dark:
            return darkThemeColors
        @unknown default:
            return lightThemeColors
        }
    }
    
    // MARK: - Light Theme Colors
    
    private var lightThemeColors: GameColors {
        GameColors(
            // Grid cells
            cellDefault: Color(.systemGray6),
            cellHighlighted: .blue.opacity(0.8),
            cellSelected: .green.opacity(0.6),
            cellWrong: .red.opacity(0.6),
            cellBorder: Color(.systemGray4),
            cellBorderActive: .blue,
            
            // Backgrounds
            primaryBackground: Color(.systemBackground),
            secondaryBackground: Color(.secondarySystemBackground),
            cardBackground: Color(.systemBackground),
            
            // Text
            primaryText: Color(.label),
            secondaryText: Color(.secondaryLabel),
            accentText: .blue,
            
            // Buttons
            buttonPrimary: .blue,
            buttonSecondary: Color(.systemGray2),
            destructiveButton: .red,
            
            // Game elements
            scorePositive: .green,
            scoreNegative: .red,
            progressBar: .blue
        )
    }
    
    // MARK: - Dark Theme Colors
    
    private var darkThemeColors: GameColors {
        GameColors(
            // Grid cells
            cellDefault: Color(.systemGray5),
            cellHighlighted: .blue.opacity(0.9),
            cellSelected: .green.opacity(0.8),
            cellWrong: .red.opacity(0.8),
            cellBorder: Color(.systemGray3),
            cellBorderActive: .blue,
            
            // Backgrounds
            primaryBackground: Color(.systemBackground),
            secondaryBackground: Color(.secondarySystemBackground),
            cardBackground: Color(.tertiarySystemBackground),
            
            // Text
            primaryText: Color(.label),
            secondaryText: Color(.secondaryLabel),
            accentText: .blue,
            
            // Buttons
            buttonPrimary: .blue,
            buttonSecondary: Color(.systemGray4),
            destructiveButton: .red,
            
            // Game elements
            scorePositive: .green,
            scoreNegative: .red,
            progressBar: .blue
        )
    }
}

// MARK: - Environment Value

struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    func themedColors(_ colorScheme: ColorScheme, action: @escaping (ThemeManager.GameColors) -> Void) -> some View {
        let colors = ThemeManager.shared.colors(for: colorScheme)
        action(colors)
        return self
    }
}
