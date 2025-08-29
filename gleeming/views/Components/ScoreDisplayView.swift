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
    
    var body: some View {
        HStack(spacing: 24) {
            ScoreItem(title: "Level", value: "\(score.currentLevel)")
            ScoreItem(title: "Score", value: "\(score.totalScore)")
            ScoreItem(title: "Streak", value: "\(score.streak)")
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
                bestStreak: 8
            ),
            gameState: .playing
        )
    }
    .padding()
}
