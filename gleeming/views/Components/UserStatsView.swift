//
//  UserStatsView.swift
//  gleeming
//
//  Created by ervan on 09/09/25.
//

import SwiftUI

struct UserStatsView: View {
    @ObservedObject var userStats = UserStats.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Your Best")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                StatItem(
                    icon: "star.fill",
                    title: "Level",
                    value: "\(userStats.highestLevel)",
                    color: .orange
                )
                
                StatItem(
                    icon: "trophy.fill",
                    title: "Score",
                    value: formatScore(userStats.highestScore),
                    color: .yellow
                )
                
                StatItem(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(userStats.bestStreak)",
                    color: .red
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func formatScore(_ score: Int) -> String {
        if score >= 1000 {
            return String(format: "%.1fK", Double(score) / 1000)
        }
        return "\(score)"
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 20) {
        UserStatsView()
        
        // Preview with sample data
        UserStatsView()
            .onAppear {
                UserStats.shared.highestLevel = 15
                UserStats.shared.highestScore = 2450
                UserStats.shared.bestStreak = 8
            }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
