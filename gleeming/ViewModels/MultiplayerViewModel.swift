//
//  MultiplayerViewModel.swift
//  gleeming
//
//  Created by ervan on 10/09/25.
//

import Foundation
import SwiftUI

@MainActor
class MultiplayerViewModel: ObservableObject {
    // MARK: - Connection State
    @Published var connectionState: ConnectionState = .disconnected
    @Published var latency: Double = 0
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    
    // MARK: - Player Info
    @Published var playerName: String = ""
    @Published var currentPlayerId: UUID?
    
    // MARK: - Room Settings
    @Published var selectedGameMode: MultiplayerGameMode = .simultaneous
    @Published var gridSize: UInt8 = 3
    @Published var maxPlayers: UInt8 = 4
    @Published var timeLimit: UInt32 = 30
    @Published var difficultyMode: DifficultyMode = .progressive
    @Published var isPrivateRoom: Bool = false
    @Published var customRoomCode: String = ""
    
    // MARK: - Room State
    @Published var isInRoom: Bool = false
    @Published var currentRoom: RoomState?
    @Published var isCreatingRoom: Bool = false
    @Published var isJoiningRoom: Bool = false
    
    // MARK: - Game State
    @Published var navigateToGame: Bool = false
    @Published var gameStarting: Bool = false
    @Published var gameCountdown: Int = 0
    
    // MARK: - Computed Properties
    var isConnected: Bool {
        connectionState == .connected
    }
    
    var isHost: Bool {
        guard let room = currentRoom, let playerId = currentPlayerId else { return false }
        return room.hostId == playerId
    }
    
    var canStartGame: Bool {
        guard let room = currentRoom else { return false }
        
        // Need at least 2 players
        if room.players.count < 2 { return false }
        
        // All non-host players must be ready
        let nonHostPlayers = room.players.filter { !$0.isHost }
        return nonHostPlayers.allSatisfy { $0.isReady }
    }
    
    var connectionStatusText: String {
        switch connectionState {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .reconnecting:
            return "Reconnecting..."
        case .error:
            return "Connection Error"
        }
    }
    
    var latencyText: String {
        if latency > 0 {
            return "\(Int(latency))ms"
        }
        return ""
    }
    
    var formattedRoomCode: String {
        currentRoom?.roomCode ?? ""
    }
    
    var isPlayerNameValid: Bool {
        playerName.count >= 2 && playerName.count <= 20
    }
    
    var isCustomRoomCodeValid: Bool {
        customRoomCode.isEmpty || (customRoomCode.count >= 4 && customRoomCode.count <= 8)
    }
    
    // MARK: - Configuration Options
    let gridSizeOptions: [UInt8] = [3, 4, 5]
    let maxPlayersOptions: [UInt8] = [2, 3, 4, 5, 6]
    let timeLimitOptions: [UInt32] = [15, 30, 45, 60, 90, 120]
    
    // MARK: - Mock Data for UI Testing
    init() {
        // Initialize with sample data for UI testing
        let randomAdjectives = ["Swift", "Bright", "Quick", "Smart", "Sharp"]
        let randomNouns = ["Player", "Gamer", "Master", "Pro", "Ace"]
        let randomAdj = randomAdjectives.randomElement() ?? "Swift"
        let randomNoun = randomNouns.randomElement() ?? "Player"
        let randomNum = Int.random(in: 100...999)
        
        playerName = "\(randomAdj)\(randomNoun)\(randomNum)"
        currentPlayerId = UUID()
        
        // Mock connection state changes for demonstration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.connectionState = .connecting
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.connectionState = .connected
            self.latency = Double.random(in: 20...100)
        }
    }
    
    // MARK: - Connection Methods (UI Only - No Network)
    func connectToServer() {
        connectionState = .connecting
        
        // Simulate connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connectionState = .connected
            self.latency = Double.random(in: 20...100)
        }
    }
    
    func disconnect() {
        connectionState = .disconnected
        latency = 0
        leaveRoom()
    }
    
    // MARK: - Player Methods
    func updatePlayerName(_ name: String) {
        playerName = name
    }
    
    func generateRandomRoomCode() {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let code = String((0..<6).map { _ in characters.randomElement()! })
        customRoomCode = code
    }
    
    // MARK: - Room Methods (UI Only - Mock Behavior)
    func createRoom() async {
        guard isConnected else {
            showError("Not connected to server")
            return
        }
        
        isCreatingRoom = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Create mock room
        let mockRoom = createMockRoom()
        currentRoom = mockRoom
        isInRoom = true
        isCreatingRoom = false
    }
    
    func joinRoom(withCode code: String) async {
        guard isConnected else {
            showError("Not connected to server")
            return
        }
        
        isJoiningRoom = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Create mock room with the provided code
        let mockRoom = createMockRoom(roomCode: code)
        currentRoom = mockRoom
        isInRoom = true
        isJoiningRoom = false
    }
    
    func leaveRoom() {
        currentRoom = nil
        isInRoom = false
        navigateToGame = false
        gameStarting = false
        gameCountdown = 0
    }
    
    func updateRoomSettings() {
        // In a real implementation, this would send settings to the server
        // For UI testing, we just update local state
        guard var room = currentRoom else { return }
        
        let updatedSettings = MultiplayerGameSettings(
            gridSize: gridSize,
            difficultyMode: difficultyMode,
            maxPlayers: maxPlayers,
            timeLimit: timeLimit,
            roundsCount: 10,
            showDuration: 1.0,
            betweenShowDelay: 0.5
        )
        
        room = RoomState(
            roomCode: room.roomCode,
            hostId: room.hostId,
            players: room.players,
            settings: updatedSettings,
            gameState: room.gameState,
            currentRound: room.currentRound,
            maxRounds: room.maxRounds,
            currentSequence: room.currentSequence,
            sequenceLength: room.sequenceLength,
            roundStartTime: room.roundStartTime,
            timeRemaining: room.timeRemaining
        )
        
        currentRoom = room
    }
    
    // MARK: - Game Methods
    func setPlayerReady(_ isReady: Bool) {
        guard var room = currentRoom, let playerId = currentPlayerId else { return }
        
        // Update player ready state in mock data
        var updatedPlayers = room.players
        if let index = updatedPlayers.firstIndex(where: { $0.id == playerId }) {
            updatedPlayers[index] = PlayerInfo(
                id: updatedPlayers[index].id,
                name: updatedPlayers[index].name,
                isReady: isReady,
                isHost: updatedPlayers[index].isHost,
                score: updatedPlayers[index].score,
                currentStreak: updatedPlayers[index].currentStreak,
                isConnected: updatedPlayers[index].isConnected,
                avatarSeed: updatedPlayers[index].avatarSeed
            )
        }
        
        currentRoom = RoomState(
            roomCode: room.roomCode,
            hostId: room.hostId,
            players: updatedPlayers,
            settings: room.settings,
            gameState: room.gameState,
            currentRound: room.currentRound,
            maxRounds: room.maxRounds,
            currentSequence: room.currentSequence,
            sequenceLength: room.sequenceLength,
            roundStartTime: room.roundStartTime,
            timeRemaining: room.timeRemaining
        )
    }
    
    func startGame() {
        guard canStartGame else { return }
        
        gameStarting = true
        gameCountdown = 3
        
        // Simulate countdown
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                self.gameCountdown -= 1
                
                if self.gameCountdown <= 0 {
                    timer.invalidate()
                    self.gameStarting = false
                    self.navigateToGame = true
                }
            }
        }
    }
    
    func resetGameNavigation() {
        navigateToGame = false
        gameStarting = false
        gameCountdown = 0
    }
    
    // MARK: - Helper Methods
    func gridSizeDisplayText(for size: UInt8) -> String {
        return "\(size)×\(size)"
    }
    
    func timeLimitDisplayText(for seconds: UInt32) -> String {
        if seconds < 60 {
            return "\(seconds) seconds"
        } else {
            let minutes = seconds / 60
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    func clearError() {
        errorMessage = nil
        showErrorAlert = false
    }
    
    // MARK: - Mock Data Creation
    private func createMockRoom(roomCode: String? = nil) -> RoomState {
        let code = roomCode ?? (customRoomCode.isEmpty ? generateMockRoomCode() : customRoomCode)
        let hostId = currentPlayerId ?? UUID()
        
        let hostPlayer = PlayerInfo(
            id: hostId,
            name: playerName,
            isReady: false,
            isHost: true,
            score: 0,
            currentStreak: 0,
            isConnected: true,
            avatarSeed: UInt32.random(in: 1...1000)
        )
        
        let mockPlayers = [hostPlayer] + generateMockPlayers()
        
        let settings = MultiplayerGameSettings(
            gridSize: gridSize,
            difficultyMode: difficultyMode,
            maxPlayers: maxPlayers,
            timeLimit: timeLimit,
            roundsCount: 10,
            showDuration: 1.0,
            betweenShowDelay: 0.5
        )
        
        return RoomState(
            roomCode: code,
            hostId: hostId,
            players: mockPlayers,
            settings: settings,
            gameState: .waiting,
            currentRound: 0,
            maxRounds: 10,
            currentSequence: nil,
            sequenceLength: 0,
            roundStartTime: nil,
            timeRemaining: nil
        )
    }
    
    private func generateMockRoomCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
    
    private func generateMockPlayers() -> [PlayerInfo] {
        let mockNames = ["Alice", "Bob", "Charlie", "Diana", "Eve"]
        var players: [PlayerInfo] = []
        
        let playerCount = Int.random(in: 1...3) // 1-3 additional players for demo
        
        for i in 0..<playerCount {
            let player = PlayerInfo(
                id: UUID(),
                name: mockNames[safe: i] ?? "Player\(i + 2)",
                isReady: i == 0, // First additional player is ready, others are not
                isHost: false,
                score: UInt32.random(in: 100...850),
                currentStreak: UInt32.random(in: 0...5),
                isConnected: true, // All mock players are connected for demo
                avatarSeed: UInt32.random(in: 1...1000)
            )
            players.append(player)
        }
        
        return players
    }
}

// MARK: - Array Safe Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Connection State Extension
extension ConnectionState {
    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}
