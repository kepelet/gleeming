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
    var timeRemaining: Double = 0.0
    var isTimedMode: Bool = false
    var lives: Int = 3
    var maxLives: Int = 3
    
    mutating func incrementLevel() {
        currentLevel += 1
        currentSequenceLength = min(currentSequenceLength + 1, 20)
        streak += 1
        bestStreak = max(bestStreak, streak)
        totalScore += currentSequenceLength * 10
        
        // Update timer for timed mode
        if isTimedMode {
            timeRemaining = calculateTimerDuration(for: currentLevel)
        }
    }
    
    mutating func resetStreak() {
        streak = 0
    }
    
    mutating func makeMistake() {
        lives -= 1
        streak = 0
        
        // Apply point penalty if player has points
        if totalScore > 0 {
            let penalty = max(currentSequenceLength * 5, 10) // Penalty is half the level reward, minimum 10
            totalScore = max(0, totalScore - penalty)
        }
    }
    
    mutating func resetLives() {
        lives = maxLives
    }
    
    var shouldGameOver: Bool {
        // Game over when no lives left
        return lives <= 0
    }
    
    var canContinuePlaying: Bool {
        // Can continue only if has lives remaining
        return lives > 0
    }
    
    var isOutOfLives: Bool {
        return lives <= 0
    }
    
    // Calculate timer duration: 10 base seconds + 2 seconds per level
    func calculateTimerDuration(for level: Int) -> Double {
        return 10.0 + Double(level * 2)
    }
    
    // Convenience initializer for testing and previews
    init(currentLevel: Int = 1, currentSequenceLength: Int = 3, totalScore: Int = 0, streak: Int = 0, bestStreak: Int = 0, timeRemaining: Double = 0.0, isTimedMode: Bool = false, lives: Int = 3, maxLives: Int = 3) {
        self.currentLevel = currentLevel
        self.currentSequenceLength = currentSequenceLength
        self.totalScore = totalScore
        self.streak = streak
        self.bestStreak = bestStreak
        self.timeRemaining = timeRemaining
        self.isTimedMode = isTimedMode
        self.lives = lives
        self.maxLives = maxLives
    }
}
