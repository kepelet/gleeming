//
//  UserStats.swift
//  gleeming
//
//  Created by ervan on 09/09/25.
//

import Foundation

// MARK: - User Statistics
class UserStats: ObservableObject {
    @Published var highestLevel: Int = 1
    @Published var highestScore: Int = 0
    @Published var bestStreak: Int = 0
    @Published var totalGamesPlayed: Int = 0
    @Published var totalPlayTime: TimeInterval = 0
    
    static let shared = UserStats()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadStats()
    }
    
    // MARK: - Update Methods
    func updateStats(from gameScore: GameScore) {
        var hasChanged = false
        
        if gameScore.currentLevel > highestLevel {
            highestLevel = gameScore.currentLevel
            hasChanged = true
        }
        
        if gameScore.totalScore > highestScore {
            highestScore = gameScore.totalScore
            hasChanged = true
        }
        
        if gameScore.bestStreak > bestStreak {
            bestStreak = gameScore.bestStreak
            hasChanged = true
        }
        
        totalGamesPlayed += 1
        hasChanged = true
        
        if hasChanged {
            saveStats()
        }
    }
    
    func addPlayTime(_ duration: TimeInterval) {
        totalPlayTime += duration
        saveStats()
    }
    
    // MARK: - Persistence
    private func loadStats() {
        highestLevel = userDefaults.integer(forKey: "highestLevel")
        if highestLevel == 0 { highestLevel = 1 } // Default to 1 if never saved
        
        highestScore = userDefaults.integer(forKey: "highestScore")
        bestStreak = userDefaults.integer(forKey: "bestStreak")
        totalGamesPlayed = userDefaults.integer(forKey: "totalGamesPlayed")
        totalPlayTime = userDefaults.double(forKey: "totalPlayTime")
    }
    
    private func saveStats() {
        userDefaults.set(highestLevel, forKey: "highestLevel")
        userDefaults.set(highestScore, forKey: "highestScore")
        userDefaults.set(bestStreak, forKey: "bestStreak")
        userDefaults.set(totalGamesPlayed, forKey: "totalGamesPlayed")
        userDefaults.set(totalPlayTime, forKey: "totalPlayTime")
    }
    
    // MARK: - Computed Properties
    var averagePlayTimePerGame: TimeInterval {
        guard totalGamesPlayed > 0 else { return 0 }
        return totalPlayTime / Double(totalGamesPlayed)
    }
    
    var formattedTotalPlayTime: String {
        let hours = Int(totalPlayTime) / 3600
        let minutes = Int(totalPlayTime) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var hasAnyStats: Bool {
        return highestScore > 0 || totalGamesPlayed > 0 || bestStreak > 0 || highestLevel > 1
    }
}
