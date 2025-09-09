//
//  ScoreDisplayView.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import SwiftUI

struct ScoreDisplayView: View {
    let score: GameScore
    let gameState: GameState
    @ObservedObject private var gameSettings = GameSettings.shared
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                ScoreItem(title: "Level", value: "\(score.currentLevel)")
                ScoreItem(title: "Score", value: "\(score.totalScore)")
                ScoreItem(title: "Streak", value: "\(score.streak)")
                
                // Lives display (only in forgiving mode)
                if gameSettings.forgivingModeEnabled {
                    VStack(spacing: 4) {
                        Text("Lives")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 3) {
                            ForEach(0..<score.maxLives, id: \.self) { index in
                                Image(systemName: index < score.lives ? "heart.fill" : "heart")
                                    .font(.caption)
                                    .foregroundColor(index < score.lives ? .red : .gray.opacity(0.3))
                            }
                        }
                    }
                }
            }
            
            // Timer display for timed mode
            if score.isTimedMode {
                TimerDisplayView(
                    timeRemaining: score.timeRemaining,
                    isTimedMode: score.isTimedMode
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct ScoreItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreDisplayView(
            score: GameScore(),
            gameState: .playing
        )
        
        ScoreDisplayView(
            score: GameScore(
                currentLevel: 5,
                currentSequenceLength: 7,
                totalScore: 350,
                streak: 4,
                bestStreak: 8,
                timeRemaining: 18.5,
                isTimedMode: true,
                lives: 1,
                maxLives: 3
            ),
            gameState: .playing
        )
    }
    .padding()
}
