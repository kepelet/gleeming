//
//  CreateRoomView.swift
//  gleeming
//
//  Created by ervan on 10/09/25.
//

import SwiftUI

struct CreateRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MultiplayerViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingAdvancedSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Connection Status Bar
                connectionStatusBar
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Player Name Section
                        playerNameSection
                        
                        // Game Mode Selection
                        gameModeSection
                        
                        // Basic Settings
                        basicSettingsSection
                        
                        // Advanced Settings Toggle
                        advancedSettingsToggle
                        
                        // Advanced Settings (Collapsible)
                        if showingAdvancedSettings {
                            advancedSettingsSection
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // Create Room Button
                        createRoomButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    connectionIndicator
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isInRoom },
            set: { _ in }
        )) {
            RoomLobbyView(viewModel: viewModel)
                .onAppear {
                    print("🔍 CreateRoomView: RoomLobbyView appeared from CreateRoomView")
                }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error occurred")
        }
        .onAppear {
            if !viewModel.isConnected {
                viewModel.connectToServer()
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
    
    private var connectionIndicator: some View {
        Button(action: {
            if viewModel.connectionState == .disconnected || viewModel.connectionState.isError {
                viewModel.connectToServer()
            }
        }) {
            Image(systemName: connectionIconName)
                .foregroundColor(connectionColor)
        }
        .disabled(viewModel.connectionState == .connecting)
    }
    
    private var connectionIconName: String {
        switch viewModel.connectionState {
        case .connected:
            return "wifi"
        case .connecting, .reconnecting:
            return "wifi.slash"
        case .disconnected, .error:
            return "wifi.exclamationmark"
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Create Room")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Set up a multiplayer game for you and your friends")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Player Name Section
    private var playerNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Player Name")
                    .font(.headline)
                
                Spacer()
                
                Button("Random") {
                    viewModel.updatePlayerName(generateRandomName())
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            TextField("Enter your name", text: Binding(
                get: { viewModel.playerName },
                set: { viewModel.updatePlayerName($0) }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.words)
            .disableAutocorrection(true)
            
            if !viewModel.isPlayerNameValid && !viewModel.playerName.isEmpty {
                Text("Name must be between 2-20 characters")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private func generateRandomName() -> String {
        let adjectives = ["Swift", "Bright", "Quick", "Smart", "Sharp", "Fast", "Clever", "Bold"]
        let nouns = ["Player", "Gamer", "Master", "Pro", "Ace", "Star", "Hero", "Legend"]
        
        let adj = adjectives.randomElement() ?? "Swift"
        let noun = nouns.randomElement() ?? "Player"
        let num = Int.random(in: 100...999)
        
        return "\(adj)\(noun)\(num)"
    }
    
    // MARK: - Game Mode Section
    private var gameModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Mode")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(MultiplayerGameMode.allCases, id: \.id) { mode in
                    GameModeSelectionCard(
                        mode: mode,
                        isSelected: viewModel.selectedGameMode == mode
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedGameMode = mode
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Basic Settings Section
    private var basicSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game Settings")
                .font(.headline)
            
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
                }
            }
        }
    }
    
    // MARK: - Advanced Settings Toggle
    private var advancedSettingsToggle: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingAdvancedSettings.toggle()
            }
        }) {
            HStack {
                Text("Advanced Settings")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: showingAdvancedSettings ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Advanced Settings Section
    private var advancedSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 12) {
                // Difficulty Mode
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
                }
                
                Divider()
                
                // Private Room Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Private Room")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text("Only accessible with room code")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $viewModel.isPrivateRoom)
                        .labelsHidden()
                }
                
                // Custom Room Code (if private)
                if viewModel.isPrivateRoom {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Room Code")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button("Generate") {
                                viewModel.generateRandomRoomCode()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        TextField("Enter custom code (optional)", text: $viewModel.customRoomCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                        
                        if !viewModel.isCustomRoomCodeValid && !viewModel.customRoomCode.isEmpty {
                            Text("Room code must be 4-8 characters")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Create Room Button
    private var createRoomButton: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await viewModel.createRoom()
                    // Don't dismiss here - let the parent view handle navigation
                }
            }) {
                HStack {
                    if viewModel.isCreatingRoom {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "plus")
                    }
                    
                    Text(viewModel.isCreatingRoom ? "Creating Room..." : "Create Room")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonBackgroundColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!canCreateRoom)
            
            // Requirement text
            if !canCreateRoom {
                Text(createRoomRequirementText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }
    
    private var buttonBackgroundColor: Color {
        if canCreateRoom && !viewModel.isCreatingRoom {
            return .blue
        } else {
            return .gray
        }
    }
    
    private var canCreateRoom: Bool {
        viewModel.isConnected &&
        viewModel.isPlayerNameValid &&
        (viewModel.customRoomCode.isEmpty || viewModel.isCustomRoomCodeValid) &&
        !viewModel.isCreatingRoom
    }
    
    private var createRoomRequirementText: String {
        if !viewModel.isConnected {
            return "Connecting to server..."
        } else if !viewModel.isPlayerNameValid {
            return "Please enter a valid player name"
        } else if !viewModel.isCustomRoomCodeValid {
            return "Please enter a valid room code"
        } else {
            return ""
        }
    }
}

// MARK: - Supporting Views

struct GameModeSelectionCard: View {
    let mode: MultiplayerGameMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreateRoomView()
}
