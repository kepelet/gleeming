//
//  GameModels.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import Foundation
import SwiftUI

// MARK: - Game State
enum GameState {
    case ready
    case showing
    case waiting
    case playing
    case gameOver
}

// MARK: - Grid Cell
struct GridCell: Identifiable, Equatable {
    let id = UUID()
    let position: GridPosition
    var isHighlighted: Bool = false
    var isSelected: Bool = false
    var isWrong: Bool = false
    var animationDelay: Double = 0.0
}

// MARK: - Grid Position
struct GridPosition: Equatable, Hashable {
    let row: Int
    let column: Int
}

// MARK: - Game Configuration
struct GameConfiguration {
    let gridSize: Int
    let initialSequenceLength: Int
    let maxSequenceLength: Int
    let showDuration: Double
    let betweenShowDelay: Double
    
    static let standard = GameConfiguration(
        gridSize: 4,
        initialSequenceLength: 3,
        maxSequenceLength: 20,
        showDuration: 0.6,
        betweenShowDelay: 0.3
    )
}

// MARK: - Game Score
struct GameScore {
    var currentLevel: Int = 1
    var currentSequenceLength: Int = 3
    var totalScore: Int = 0
    var streak: Int = 0
    var bestStreak: Int = 0
    
    mutating func incrementLevel() {
        currentLevel += 1
        currentSequenceLength = min(currentSequenceLength + 1, 20)
        streak += 1
        bestStreak = max(bestStreak, streak)
        totalScore += currentSequenceLength * 10
    }
    
    mutating func resetStreak() {
        streak = 0
    }
    
    // Convenience initializer for testing and previews
    init(currentLevel: Int = 1, currentSequenceLength: Int = 3, totalScore: Int = 0, streak: Int = 0, bestStreak: Int = 0) {
        self.currentLevel = currentLevel
        self.currentSequenceLength = currentSequenceLength
        self.totalScore = totalScore
        self.streak = streak
        self.bestStreak = bestStreak
    }
}
