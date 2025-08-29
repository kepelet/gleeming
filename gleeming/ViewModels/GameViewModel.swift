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
    
    private let configuration = GameConfiguration.standard
    private var showSequenceTask: Task<Void, Never>?
    
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
    
    // MARK: - Game Control
    func startNewGame() {
        gameScore = GameScore()
        gameScore.currentSequenceLength = configuration.initialSequenceLength
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
        gameState = .ready
        resetGrid()
        sequence = []
        playerSequence = []
        currentSequenceIndex = 0
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
        sequence = []
        for _ in 0..<gameScore.currentSequenceLength {
            let randomRow = Int.random(in: 0..<configuration.gridSize)
            let randomColumn = Int.random(in: 0..<configuration.gridSize)
            sequence.append(GridPosition(row: randomRow, column: randomColumn))
        }
    }
    
    // MARK: - Sequence Display
    private func showSequence() {
        playerSequence = []
        currentSequenceIndex = 0
        
        showSequenceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
            
            for (index, position) in sequence.enumerated() {
                if Task.isCancelled { return }
                
                gridCells[position.row][position.column].isHighlighted = true
                
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
            
            Task {
                try? await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
                gridCells[position.row][position.column].isWrong = false
            }
            
            gameOver()
            return
        }
        
        // Correct move - show green feedback
        gridCells[position.row][position.column].isSelected = true
        
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
        gameScore.incrementLevel()
        
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
        
        Task {
            for position in sequence {
                gridCells[position.row][position.column].isHighlighted = true
            }
            try? await Task.sleep(nanoseconds: UInt64(2.0 * 1_000_000_000))
            resetGrid()
        }
    }
}
