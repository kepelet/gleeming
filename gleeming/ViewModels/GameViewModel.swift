//
//  GameViewModel.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import Foundation
import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .ready
    @Published var gridCells: [[GridCell]] = []
    @Published var gameScore = GameScore()
    @Published var sequence: [GridPosition] = []
    @Published var playerSequence: [GridPosition] = []
    @Published var currentSequenceIndex = 0
    @Published var showConfetti = false
    
    private var gameSettings = GameSettings.shared
    private var configuration: GameConfiguration { gameSettings.createGameConfiguration() }
    private var showSequenceTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var baseSequence: [GridPosition] = [] // For progressive mode
    private let hapticManager = HapticManager.shared
    private let soundManager = SoundManager.shared
    
    init() {
        setupGrid()
    }
    
    // MARK: - Grid Setup
    private func setupGrid() {
        gridCells = []
        for row in 0..<configuration.gridSize {
            var cellRow: [GridCell] = []
            for column in 0..<configuration.gridSize {
                let cell = GridCell(position: GridPosition(row: row, column: column))
                cellRow.append(cell)
            }
            gridCells.append(cellRow)
        }
    }
    
    // MARK: - Settings Update
    func refreshGridForSettingsChange() {
        print("🔄 Refreshing grid for settings change. Grid size: \(gameSettings.gridSize), Difficulty: \(gameSettings.difficultyMode.displayName)")
        baseSequence = [] // Reset base sequence when settings change
        setupGrid()
        if gameState == .ready {
            // If we're not in an active game, just refresh the grid
            resetGrid()
        } else {
            // If we're in an active game, reset to ready state
            resetGame()
        }
    }
    
    // MARK: - Game Control
    func startNewGame() {
        gameScore = GameScore()
        gameScore.currentSequenceLength = configuration.initialSequenceLength
        gameScore.isTimedMode = gameSettings.timedModeEnabled
        
        // Initialize timer for timed mode
        if gameSettings.timedModeEnabled {
            gameScore.timeRemaining = gameScore.calculateTimerDuration(for: gameScore.currentLevel)
        }
        
        baseSequence = [] // Reset base sequence for progressive mode
        hapticManager.gameStarted()
        startNewRound()
    }
    
    func startNewRound() {
        resetGrid()
        generateSequence()
        gameState = .showing
        showSequence()
    }
    
    func resetGame() {
        showSequenceTask?.cancel()
        timerTask?.cancel()
        soundManager.stopAllSounds()
        gameState = .ready
        resetGrid()
        sequence = []
        playerSequence = []
        currentSequenceIndex = 0
        baseSequence = [] // Reset base sequence for progressive mode
        showConfetti = false // Reset confetti state
    }
    
    // MARK: - Grid Management
    private func resetGrid() {
        for row in 0..<gridCells.count {
            for column in 0..<gridCells[row].count {
                gridCells[row][column].isHighlighted = false
                gridCells[row][column].isSelected = false
                gridCells[row][column].isWrong = false
                gridCells[row][column].animationDelay = 0.0
            }
        }
    }
    
    // MARK: - Sequence Generation
    private func generateSequence() {
        switch gameSettings.difficultyMode {
        case .random:
            generateRandomSequence()
        case .progressive:
            generateProgressiveSequence()
        }
    }
    
    private func generateRandomSequence() {
        sequence = []
        for _ in 0..<gameScore.currentSequenceLength {
            let randomRow = Int.random(in: 0..<configuration.gridSize)
            let randomColumn = Int.random(in: 0..<configuration.gridSize)
            sequence.append(GridPosition(row: randomRow, column: randomColumn))
        }
    }
    
    private func generateProgressiveSequence() {
        if baseSequence.isEmpty {
            // First level - generate initial sequence
            for _ in 0..<gameScore.currentSequenceLength {
                let randomRow = Int.random(in: 0..<configuration.gridSize)
                let randomColumn = Int.random(in: 0..<configuration.gridSize)
                baseSequence.append(GridPosition(row: randomRow, column: randomColumn))
            }
            sequence = baseSequence
        } else {
            // Subsequent levels - add one more step to the base sequence
            let randomRow = Int.random(in: 0..<configuration.gridSize)
            let randomColumn = Int.random(in: 0..<configuration.gridSize)
            baseSequence.append(GridPosition(row: randomRow, column: randomColumn))
            sequence = baseSequence
        }
    }
    
    // MARK: - Sequence Display
    private func showSequence() {
        playerSequence = []
        currentSequenceIndex = 0
        
        hapticManager.sequenceStarted()
        
        showSequenceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
            
            for (index, position) in sequence.enumerated() {
                if Task.isCancelled { return }
                
                gridCells[position.row][position.column].isHighlighted = true
                soundManager.playNoteForGridPosition(position, gridSize: configuration.gridSize)
                
                try? await Task.sleep(nanoseconds: UInt64(configuration.showDuration * 1_000_000_000))
                
                if Task.isCancelled { return }
                
                gridCells[position.row][position.column].isHighlighted = false
                
                if index < sequence.count - 1 {
                    try? await Task.sleep(nanoseconds: UInt64(configuration.betweenShowDelay * 1_000_000_000))
                }
            }
            
            if !Task.isCancelled {
                // Wait a bit before allowing player input
                try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
                gameState = .playing
                
                // Start timer for timed mode
                if gameScore.isTimedMode {
                    startTimer()
                }
            }
        }
    }
    
    // MARK: - Player Input
    func cellTapped(at position: GridPosition) {
        guard gameState == .playing else { return }
        
        playerSequence.append(position)
        
        // Check if the move is correct
        if playerSequence[currentSequenceIndex] != sequence[currentSequenceIndex] {
            // Wrong move - show red feedback
            gridCells[position.row][position.column].isWrong = true
            hapticManager.wrongSelection()
            
            Task {
                try? await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
                gridCells[position.row][position.column].isWrong = false
            }
            
            gameOver()
            return
        }
        
        // Correct move - show green feedback
        gridCells[position.row][position.column].isSelected = true
        hapticManager.correctSelection()
        soundManager.playNoteForGridPosition(position, gridSize: configuration.gridSize)
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64(0.2 * 1_000_000_000))
            gridCells[position.row][position.column].isSelected = false
        }
        
        currentSequenceIndex += 1
        
        // Check if sequence is complete
        if currentSequenceIndex >= sequence.count {
            levelCompleted()
        }
    }
    
    // MARK: - Game Events
    private func levelCompleted() {
        gameState = .waiting
        stopTimer() // Stop the current timer
        gameScore.incrementLevel()
        hapticManager.levelCompleted()
        
        // Check if confetti should be shown (every 3 levels and confetti enabled)
        if gameScore.currentLevel % 3 == 0 && gameSettings.confettiEnabled {
            showConfetti = true
            
            // Hide confetti after 3 seconds
            Task {
                try? await Task.sleep(nanoseconds: UInt64(3.5 * 1_000_000_000))
                showConfetti = false
            }
        }
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64(1.5 * 1_000_000_000))
            if gameState == .waiting {
                startNewRound()
            }
        }
    }
    
    private func gameOver() {
        gameState = .gameOver
        gameScore.resetStreak()
        showSequenceTask?.cancel()
        timerTask?.cancel()
        
        Task {
            for position in sequence {
                gridCells[position.row][position.column].isHighlighted = true
            }
            try? await Task.sleep(nanoseconds: UInt64(2.0 * 1_000_000_000))
            resetGrid()
        }
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        timerTask?.cancel()
        
        timerTask = Task {
            while gameScore.timeRemaining > 0 && gameState == .playing && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000) // Update every 0.1 seconds
                
                if !Task.isCancelled && gameState == .playing {
                    gameScore.timeRemaining = max(0, gameScore.timeRemaining - 0.1)
                    
                    // Check for time warnings
                    if gameScore.timeRemaining <= 3.0 && gameScore.timeRemaining > 2.9 {
                        // 3 seconds left - warning haptic
                        hapticManager.sequenceStarted()
                    }
                }
            }
            
            // Time's up!
            if gameScore.timeRemaining <= 0 && gameState == .playing && !Task.isCancelled {
                gameOver()
            }
        }
    }
    
    private func stopTimer() {
        timerTask?.cancel()
    }
}
