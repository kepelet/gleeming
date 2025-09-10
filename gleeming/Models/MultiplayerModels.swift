//
//  MultiplayerModels.swift
//  gleeming
//
//  Created by ervan on 10/09/25.
//

import Foundation
import SwiftUI

// MARK: - Multiplayer Game Mode
enum MultiplayerGameMode: String, CaseIterable, Identifiable {
    case turnBased = "Turn-Based"
    case simultaneous = "Simultaneous"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .turnBased:
            return "Players alternate levels until one fails"
        case .simultaneous:
            return "Same pattern, separate games"
        }
    }
    
    var icon: String {
        switch self {
        case .turnBased:
            return "arrow.left.arrow.right"
        case .simultaneous:
            return "rectangle.split.2x1"
        }
    }
}

// MARK: - Difficulty Mode
enum DifficultyMode: String, CaseIterable, Codable {
    case random = "random"
    case progressive = "progressive"
}

// MARK: - Game State
enum MultiplayerGameState: String, Codable {
    case waiting = "waiting"
    case countdown = "countdown"
    case showing = "showing"
    case playing = "playing"
    case roundEnd = "round_end"
    case gameOver = "game_over"
}

// MARK: - Player Info
struct PlayerInfo: Identifiable, Codable {
    let id: UUID
    let name: String
    var isReady: Bool
    var isHost: Bool
    var score: UInt32
    var currentStreak: UInt32
    var isConnected: Bool
    var avatarSeed: UInt32
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case isReady = "is_ready"
        case isHost = "is_host"
        case score
        case currentStreak = "current_streak"
        case isConnected = "is_connected"
        case avatarSeed = "avatar_seed"
    }
}

// MARK: - Room Creation Settings
struct RoomCreationSettings: Codable {
    let gridSize: UInt8
    let difficultyMode: DifficultyMode
    let maxPlayers: UInt8
    let timeLimit: UInt32
    let isPrivate: Bool
    let roomCode: String?
    
    enum CodingKeys: String, CodingKey {
        case gridSize = "grid_size"
        case difficultyMode = "difficulty_mode"
        case maxPlayers = "max_players"
        case timeLimit = "time_limit"
        case isPrivate = "is_private"
        case roomCode = "room_code"
    }
}

// MARK: - Game Settings
struct MultiplayerGameSettings: Codable {
    let gridSize: UInt8
    let difficultyMode: DifficultyMode
    let maxPlayers: UInt8
    let timeLimit: UInt32
    let roundsCount: UInt32
    let showDuration: Float
    let betweenShowDelay: Float
    
    enum CodingKeys: String, CodingKey {
        case gridSize = "grid_size"
        case difficultyMode = "difficulty_mode"
        case maxPlayers = "max_players"
        case timeLimit = "time_limit"
        case roundsCount = "rounds_count"
        case showDuration = "show_duration"
        case betweenShowDelay = "between_show_delay"
    }
}

// MARK: - Room State
struct RoomState: Codable {
    let roomCode: String
    let hostId: UUID
    let players: [PlayerInfo]
    let settings: MultiplayerGameSettings
    let gameState: MultiplayerGameState
    let currentRound: UInt32
    let maxRounds: UInt32
    let currentSequence: [GridPosition]?
    let sequenceLength: UInt32
    let roundStartTime: Date?
    let timeRemaining: Float?
    
    enum CodingKeys: String, CodingKey {
        case roomCode = "room_code"
        case hostId = "host_id"
        case players, settings
        case gameState = "game_state"
        case currentRound = "current_round"
        case maxRounds = "max_rounds"
        case currentSequence = "current_sequence"
        case sequenceLength = "sequence_length"
        case roundStartTime = "round_start_time"
        case timeRemaining = "time_remaining"
    }
}

// MARK: - Multiplayer Grid Position
extension GridPosition: Codable {
    enum CodingKeys: String, CodingKey {
        case row, col
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let row = try container.decode(UInt8.self, forKey: .row)
        let col = try container.decode(UInt8.self, forKey: .col)
        self.init(row: Int(row), column: Int(col))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(UInt8(row), forKey: .row)
        try container.encode(UInt8(column), forKey: .col)
    }
}

// MARK: - Connection State
enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case error(String)
    
    static func == (lhs: ConnectionState, rhs: ConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected),
             (.connecting, .connecting),
             (.connected, .connected),
             (.reconnecting, .reconnecting):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// MARK: - Room Creation Error
enum RoomCreationError: LocalizedError {
    case networkError(String)
    case serverError(String)
    case invalidSettings
    case roomCodeTaken
    case maxPlayersReached
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .invalidSettings:
            return "Invalid room settings"
        case .roomCodeTaken:
            return "Room code is already taken"
        case .maxPlayersReached:
            return "Room is full"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Lobby State
struct LobbyState: Codable {
    let playersCount: UInt32
    let waitingTimeEstimate: UInt32
    
    enum CodingKeys: String, CodingKey {
        case playersCount = "players_count"
        case waitingTimeEstimate = "waiting_time_estimate"
    }
}

// MARK: - Matchmaking Preferences
struct MatchmakingPreferences: Codable {
    let gridSize: UInt8
    let difficultyMode: DifficultyMode
    let maxPlayers: UInt8
    
    enum CodingKeys: String, CodingKey {
        case gridSize = "grid_size"
        case difficultyMode = "difficulty_mode"
        case maxPlayers = "max_players"
    }
}
