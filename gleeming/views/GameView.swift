//
//  GameView.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @ObservedObject private var gameSettings = GameSettings.shared
    @State private var showingGameOver = false
    @State private var showingSettings = false
    @State private var showingShareResult = false
    @Binding var showGame: Bool
    
    init(showGame: Binding<Bool> = .constant(true)) {
        self._showGame = showGame
    }
    
    // MARK: - Visual Mode Computed Properties
    
    private var shouldShowUIElements: Bool {
        switch gameSettings.visualMode {
        case .zen:
            return viewModel.gameState == .gameOver
        case .minimal:
            return viewModel.gameState == .gameOver
        case .full:
            return true
        }
    }
    
    private var shouldShowHeader: Bool {
        switch gameSettings.visualMode {
        case .zen:
            return false // Never show header in zen mode - complete focus on game
        case .minimal:
            return true // Always show menu button and title in minimal
        case .full:
            return true
        }
    }
    
    private var shouldShowGameStatus: Bool {
        // Always show game stats regardless of visual mode
        return true
    }
    
    private var shouldShowMinimalTimerAndLives: Bool {
        // Only show minimal timer and lives in Zen mode
        if gameSettings.visualMode == .zen {
            return viewModel.gameScore.isTimedMode || gameSettings.forgivingModeEnabled
        }
        return false // Minimal and Full modes use the original ScoreDisplayView
    }
    
    private var shouldShowControlButtons: Bool {
        // Always show control buttons when game is ready (for Start Game button)
        if viewModel.gameState == .ready {
            return true
        }
        
        // For other states, follow visual mode rules
        switch gameSettings.visualMode {
        case .zen:
            return viewModel.gameState == .gameOver
        case .minimal:
            return viewModel.gameState == .gameOver
        case .full:
            return true
        }
    }
    
    private var shouldShowSettingsButton: Bool {
        switch gameSettings.visualMode {
        case .zen:
            return viewModel.gameState == .gameOver
        case .minimal:
            return false // Hide settings button in minimal mode
        case .full:
            return true
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if gameSettings.visualMode == .full {
                // Full mode: maintain current layout
                VStack(spacing: shouldShowUIElements ? 24 : 0) {
                    // Header with score (conditional based on visual mode)
                    if shouldShowHeader {
                        headerView
                    }
                    
                    // Game status (conditional based on visual mode)
                    if shouldShowGameStatus {
                        gameStatusView
                    }
                    
                    // Minimal timer and lives display (always shown when relevant)
                    if shouldShowMinimalTimerAndLives {
                        minimalTimerAndLivesView
                    }
                    
                    // Game grid (always shown, but with different spacing)
                    gameGridSection(geometry: geometry)
                    
                    // Control buttons (conditional based on visual mode)
                    if shouldShowControlButtons {
                        controlButtonsView
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, shouldShowUIElements ? 20 : 0)
                .padding(.top, shouldShowUIElements ? 20 : 0)
            } else {
                // Zen and Minimal modes: header at top, game content centered
                VStack(spacing: 0) {
                    // Header stays at top (conditional based on visual mode)
                    if shouldShowHeader {
                        headerView
                            .padding(.horizontal, shouldShowUIElements ? 20 : 16)
                            .padding(.top, shouldShowUIElements ? 20 : 0)
                    }
                    
                    // Centered game content area
                    VStack {
                        Spacer()
                        
                        VStack(spacing: shouldShowUIElements ? 16 : 12) {
                            // Game status (conditional based on visual mode)
                            if shouldShowGameStatus {
                                gameStatusView
                            }
                            
                            // Minimal timer and lives display (always shown when relevant)
                            if shouldShowMinimalTimerAndLives {
                                minimalTimerAndLivesView
                            }
                            
                            // Game grid (always shown, but with different spacing)
                            gameGridSection(geometry: geometry)
                            
                            // Control buttons (conditional based on visual mode)
                            if shouldShowControlButtons {
                                controlButtonsView
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, shouldShowUIElements ? 20 : 16)
                }
            }
        }
        .overlay(
            // Confetti overlay
            ConfettiView(isActive: viewModel.showConfetti)
                .allowsHitTesting(false)
        )
        .onChange(of: viewModel.gameState) { oldValue, newValue in
            if newValue == .gameOver {
                showingGameOver = true
            }
        }
        .onChange(of: gameSettings.gridSize) { oldValue, newValue in
            viewModel.refreshGridForSettingsChange()
        }
        .onChange(of: gameSettings.difficultyMode) { oldValue, newValue in
            viewModel.refreshGridForSettingsChange()
        }
        .alert("Game Over", isPresented: $showingGameOver) {
            Button("Share Result") {
                showingShareResult = true
            }
            Button("Play Again") {
                viewModel.startNewGame()
            }
            Button("Main Menu") {
                viewModel.resetGame()
                showGame = false
            }
        } message: {
            Text("Final Score: \(viewModel.gameScore.totalScore)\nBest Streak: \(viewModel.gameScore.bestStreak)")
        }
        .sheet(isPresented: $showingSettings) {
            SettingsViewWrapper(isPresented: $showingSettings)
        }
        .sheet(isPresented: $showingShareResult) {
            ShareResultView(
                gameScore: viewModel.gameScore,
                difficultyMode: gameSettings.difficultyMode
            )
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Button("← Menu") {
                    viewModel.resetGame()
                    showGame = false
                }
                .font(.headline)
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Gleeming")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if shouldShowSettingsButton {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(isSettingsDisabled ? .gray : .blue)
                    }
                    .disabled(isSettingsDisabled)
                    .frame(width: 60, alignment: .trailing)
                } else {
                    // Invisible spacer to maintain layout balance
                    Spacer()
                        .frame(width: 60)
                }
            }
            
            ScoreDisplayView(
                score: viewModel.gameScore,
                gameState: viewModel.gameState
            )
        }
    }
    
    private var gameStatusView: some View {
        VStack(spacing: 8) {
            if viewModel.showMistakeMessage {
                Text(viewModel.mistakeMessage)
                    .font(.headline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .scale))
            } else {
                Text(statusText)
                    .font(.headline)
                    .foregroundColor(statusColor)
            }
            
            if viewModel.gameState == .showing || viewModel.gameState == .playing {
                Text("Sequence Length: \(viewModel.gameScore.currentSequenceLength)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 60)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showMistakeMessage)
    }
    
    private func gameGridSection(geometry: GeometryProxy) -> some View {
        let availableHeight: CGFloat
        let gridHeight: CGFloat
        
        if gameSettings.visualMode == .full {
            // Full mode: original layout calculation
            availableHeight = geometry.size.height - 300 // Reserve space for UI
            gridHeight = min(availableHeight, geometry.size.width - 40)
        } else {
            // Zen and Minimal modes: more centered and compact
            let uiSpaceNeeded: CGFloat = shouldShowUIElements ? 200 : 100
            availableHeight = geometry.size.height - uiSpaceNeeded
            gridHeight = min(availableHeight * 0.6, geometry.size.width - 32)
        }
        
        return GameGridView(viewModel: viewModel)
            .frame(height: gridHeight)
            .disabled(viewModel.gameState != .playing)
    }
    
    private var controlButtonsView: some View {
        HStack(spacing: 20) {
            if viewModel.gameState == .ready {
                Button("Start Game") {
                    viewModel.startNewGame()
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                if viewModel.gameState == .gameOver && !showingGameOver {
                    Button("Play Again") {
                        viewModel.startNewGame()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
    }
    
    private var statusText: String {
        switch viewModel.gameState {
        case .ready:
            return "Ready to Play"
        case .showing:
            return "Watch the Pattern"
        case .waiting:
            return "Level Complete!"
        case .playing:
            return "Repeat the Pattern"
        case .gameOver:
            return "Game Over"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.gameState {
        case .ready:
            return .primary
        case .showing:
            return .blue
        case .waiting:
            return .green
        case .playing:
            return .orange
        case .gameOver:
            return .red
        }
    }
    
    private var isSettingsDisabled: Bool {
        return viewModel.gameState == .showing || viewModel.gameState == .playing
    }
    
    private var minimalTimerAndLivesView: some View {
        HStack(spacing: 16) {
            // Timer display for timed mode
            if viewModel.gameScore.isTimedMode {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundColor(timerColor)
                    
                    Text(timeString)
                        .font(.caption.monospacedDigit())
                        .foregroundColor(timerColor)
                }
            }
            
            // Lives display for forgiving mode
            if gameSettings.forgivingModeEnabled {
                HStack(spacing: 3) {
                    ForEach(0..<viewModel.gameScore.maxLives, id: \.self) { index in
                        Image(systemName: index < viewModel.gameScore.lives ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundColor(index < viewModel.gameScore.lives ? .red : .gray.opacity(0.3))
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6).opacity(0.8))
        )
    }
    
    private var timeString: String {
        let timeRemaining = viewModel.gameScore.timeRemaining
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var timerColor: Color {
        let timeRemaining = viewModel.gameScore.timeRemaining
        if timeRemaining <= 3.0 {
            return .red
        } else if timeRemaining <= 10.0 {
            return .orange
        } else {
            return .primary
        }
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    GameView(showGame: .constant(true))
}
