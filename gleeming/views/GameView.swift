//
//  GameView.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showingGameOver = false
    @State private var showingSettings = false
    @Binding var showGame: Bool
    
    init(showGame: Binding<Bool> = .constant(true)) {
        self._showGame = showGame
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                // Header with score
                headerView
                
                // Game status
                gameStatusView
                
                // Game grid
                gameGridSection(geometry: geometry)
                
                // Control buttons
                controlButtonsView
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .onChange(of: viewModel.gameState) { oldValue, newValue in
            if newValue == .gameOver {
                showingGameOver = true
            }
        }
        .alert("Game Over", isPresented: $showingGameOver) {
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
            SettingsView(isPresented: $showingSettings)
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
                
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .frame(width: 60, alignment: .trailing)
            }
            
            ScoreDisplayView(
                score: viewModel.gameScore,
                gameState: viewModel.gameState
            )
        }
    }
    
    private var gameStatusView: some View {
        VStack(spacing: 8) {
            Text(statusText)
                .font(.headline)
                .foregroundColor(statusColor)
            
            if viewModel.gameState == .showing || viewModel.gameState == .playing {
                Text("Sequence Length: \(viewModel.gameScore.currentSequenceLength)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 60)
    }
    
    private func gameGridSection(geometry: GeometryProxy) -> some View {
        let availableHeight = geometry.size.height - 300 // Reserve space for UI
        let gridHeight = min(availableHeight, geometry.size.width - 40)
        
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
                Button("Reset") {
                    viewModel.resetGame()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                if viewModel.gameState == .gameOver {
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
