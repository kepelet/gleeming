//
//  RoomLobbyView.swift
//  gleeming
//
//  Created by ervan on 10/09/25.
//

import SwiftUI

struct RoomLobbyView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MultiplayerViewModel
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingSettings = false
    @State private var showingLeaveAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Connection Status Bar
                connectionStatusBar
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Room Header
                        roomHeaderSection
                        
                        // Players Section
                        playersSection
                        
                        // Game Settings Section
                        if viewModel.isHost {
                            gameSettingsSection
                        } else {
                            gameSettingsDisplaySection
                        }
                        
                        // Ready/Start Game Section
                        actionSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Leave") {
                        showingLeaveAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isHost {
                        Button("Settings") {
                            showingSettings = true
                        }
                    }
                }
            }
        }
        .alert("Leave Room", isPresented: $showingLeaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                // Leave the room and dismiss the view
                viewModel.leaveRoom()
                
                // Use async dispatch to ensure the room state is updated before dismissal
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to leave the room?")
        }
        .sheet(isPresented: $showingSettings) {
            RoomSettingsView(viewModel: viewModel)
        }
        .overlay(
            // Game starting countdown overlay
            Group {
                if viewModel.gameStarting {
                    gameStartingOverlay
                }
            }
        )
        .fullScreenCover(isPresented: $viewModel.navigateToGame) {
            // For now, use the existing GameView as a placeholder
            // TODO: Replace with proper multiplayer game view
            MultiplayerGameView(viewModel: viewModel)
        }
        .onDisappear {
            // If the view is being dismissed and we're still connected to a room,
            // it might be an unexpected dismissal
            if viewModel.isInRoom {
                print("⚠️ RoomLobbyView disappeared while still in room")
            }
        }
    }
    
    // MARK: - Connection Status Bar
    private var connectionStatusBar: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(connectionColor)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.connectionStatusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if viewModel.latency > 0 {
                Text(viewModel.latencyText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var connectionColor: Color {
        switch viewModel.connectionState {
        case .connected:
            return .green
        case .connecting, .reconnecting:
            return .orange
        case .disconnected, .error:
            return .red
        }
    }
    
    // MARK: - Room Header
    private var roomHeaderSection: some View {
        VStack(spacing: 16) {
            // Room Code Display
            VStack(spacing: 8) {
                Text("Room Code")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Text(viewModel.formattedRoomCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                    
                    Button(action: copyRoomCode) {
                        Image(systemName: "doc.on.doc")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Room Status
            if let room = viewModel.currentRoom {
                VStack(spacing: 4) {
                    Text("Game Mode: \(viewModel.selectedGameMode.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Game State: \(room.gameState.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func copyRoomCode() {
        UIPasteboard.general.string = viewModel.formattedRoomCode
        // Could add a toast notification here
        HapticManager.shared.correctSelection()
    }
    
    // MARK: - Players Section
    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Players")
                    .font(.headline)
                
                if let room = viewModel.currentRoom {
                    Spacer()
                    Text("\(room.players.count)/\(room.settings.maxPlayers)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if let room = viewModel.currentRoom {
                LazyVStack(spacing: 12) {
                    ForEach(room.players, id: \.id) { player in
                        PlayerCard(player: player, isCurrentUser: player.name == viewModel.playerName)
                    }
                }
            }
        }
    }
    
    // MARK: - Game Settings Display (Non-Host)
    private var gameSettingsDisplaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Settings")
                .font(.headline)
            
            if let room = viewModel.currentRoom {
                VStack(spacing: 12) {
                    SettingDisplayRow(
                        title: "Grid Size",
                        value: "\(room.settings.gridSize)×\(room.settings.gridSize)"
                    )
                    
                    Divider()
                    
                    SettingDisplayRow(
                        title: "Difficulty",
                        value: room.settings.difficultyMode.rawValue.capitalized
                    )
                    
                    Divider()
                    
                    SettingDisplayRow(
                        title: "Max Players",
                        value: "\(room.settings.maxPlayers) players"
                    )
                    
                    Divider()
                    
                    SettingDisplayRow(
                        title: "Time Limit",
                        value: viewModel.timeLimitDisplayText(for: room.settings.timeLimit)
                    )
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Game Settings Section (Host)
    private var gameSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Game Settings")
                    .font(.headline)
                
                Spacer()
                
                Text("Host Controls")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(spacing: 12) {
                // Grid Size
                SettingRow(
                    title: "Grid Size",
                    value: viewModel.gridSizeDisplayText(for: viewModel.gridSize)
                ) {
                    Picker("Grid Size", selection: $viewModel.gridSize) {
                        ForEach(viewModel.gridSizeOptions, id: \.self) { size in
                            Text(viewModel.gridSizeDisplayText(for: size)).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.gridSize) {
                        viewModel.updateRoomSettings()
                    }
                }
                
                Divider()
                
                // Difficulty
                SettingRow(
                    title: "Difficulty",
                    value: viewModel.difficultyMode.rawValue.capitalized
                ) {
                    Picker("Difficulty", selection: $viewModel.difficultyMode) {
                        ForEach(DifficultyMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.difficultyMode) {
                        viewModel.updateRoomSettings()
                    }
                }
                
                Divider()
                
                // Max Players
                SettingRow(
                    title: "Max Players",
                    value: "\(viewModel.maxPlayers) players"
                ) {
                    Picker("Max Players", selection: $viewModel.maxPlayers) {
                        ForEach(viewModel.maxPlayersOptions, id: \.self) { count in
                            Text("\(count) players").tag(count)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.maxPlayers) {
                        viewModel.updateRoomSettings()
                    }
                }
                
                Divider()
                
                // Time Limit
                SettingRow(
                    title: "Time Limit",
                    value: viewModel.timeLimitDisplayText(for: viewModel.timeLimit)
                ) {
                    Picker("Time Limit", selection: $viewModel.timeLimit) {
                        ForEach(viewModel.timeLimitOptions, id: \.self) { seconds in
                            Text(viewModel.timeLimitDisplayText(for: seconds)).tag(seconds)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.timeLimit) {
                        viewModel.updateRoomSettings()
                    }
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Action Section
    private var actionSection: some View {
        VStack(spacing: 16) {
            // Determine if current user is host
            let isCurrentUserHost = viewModel.isHost
            
            if isCurrentUserHost {
                // Start Game Button (Host Only)
                Button(action: {
                    viewModel.startGame()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Game")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canStartGame ? .green : .gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.canStartGame)
                
                if !viewModel.canStartGame {
                    Text(startGameRequirementText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                // Mark as Ready Button (Non-Host Players Only)
                Button(action: {
                    viewModel.setPlayerReady(!currentPlayerIsReady)
                }) {
                    HStack {
                        Image(systemName: currentPlayerIsReady ? "checkmark.circle.fill" : "circle")
                        Text(currentPlayerIsReady ? "Ready!" : "Mark as Ready")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(currentPlayerIsReady ? .green : .blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Text("Waiting for host to start the game...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }
    
    private var startGameRequirementText: String {
        guard let room = viewModel.currentRoom else { return "" }
        
        if room.players.count < 2 {
            return "Need at least 2 players to start"
        } else {
            // Host doesn't need to be ready - only non-host players need to be ready
            let nonHostPlayers = room.players.filter { !$0.isHost }
            let notReadyNonHostPlayers = nonHostPlayers.filter { !$0.isReady }
            
            if !notReadyNonHostPlayers.isEmpty {
                return "\(notReadyNonHostPlayers.count) player(s) not ready"
            } else {
                return ""
            }
        }
    }
    
    private var currentPlayerIsReady: Bool {
        guard let room = viewModel.currentRoom,
              let currentPlayerId = viewModel.currentPlayerId else { return false }
        
        return room.players.first { $0.id == currentPlayerId }?.isReady ?? false
    }
}

// MARK: - Supporting Views

struct PlayerCard: View {
    let player: PlayerInfo
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(avatarColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(player.name.prefix(1).uppercased()))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Player Info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if player.isHost {
                        Text("HOST")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                    
                    if isCurrentUser {
                        Text("YOU")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                }
                
                HStack(spacing: 12) {
                    // Connection Status
                    HStack(spacing: 4) {
                        Circle()
                            .fill(player.isConnected ? .green : .red)
                            .frame(width: 6, height: 6)
                        
                        Text(player.isConnected ? "Connected" : "Disconnected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Ready Status
                    if player.isHost {
                        // Host doesn't show ready status - shows host indicator instead
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("Host")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    } else {
                        // Non-host players show ready status
                        if player.isReady {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text("Ready")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Text("Not Ready")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Score (if available)
            if player.score > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(player.score)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(isCurrentUser ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentUser ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
    
    private var avatarColor: Color {
        // Generate a consistent color based on player ID
        let colors: [Color] = [.blue, .green, .purple, .orange, .pink, .red, .yellow, .cyan]
        let index = abs(player.id.hashValue) % colors.count
        return colors[index]
    }
}

struct SettingDisplayRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Game Starting Overlay
extension RoomLobbyView {
    private var gameStartingOverlay: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Game Starting!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(viewModel.gameCountdown)")
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Get ready...")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .scaleEffect(viewModel.gameCountdown > 0 ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: viewModel.gameCountdown)
        }
    }
}

// MARK: - Temporary Multiplayer Game View
struct MultiplayerGameView: View {
    @ObservedObject var viewModel: MultiplayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button("Back to Lobby") {
                    viewModel.resetGameNavigation()
                    dismiss()
                }
                .padding()
                
                Spacer()
                
                Text("Multiplayer Game")
                    .font(.headline)
                
                Spacer()
                
                // Room code for reference
                Text(viewModel.formattedRoomCode)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Game content placeholder
            VStack(spacing: 16) {
                Text("🎮")
                    .font(.system(size: 80))
                
                Text("Multiplayer Game")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Game in progress...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let room = viewModel.currentRoom {
                    Text("Players: \(room.players.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("State: \(room.gameState.rawValue.capitalized)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Temporary controls
            VStack(spacing: 12) {
                Text("This is a placeholder for the multiplayer game view.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("End Game (Placeholder)") {
                    viewModel.resetGameNavigation()
                    dismiss()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Room Settings View Placeholder
struct RoomSettingsView: View {
    @ObservedObject var viewModel: MultiplayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Room Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Additional room configuration options will be available here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    // Create a mock view model for preview
    let viewModel = MultiplayerViewModel()
    return RoomLobbyView(viewModel: viewModel)
}
