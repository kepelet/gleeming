//
//  MultiplayerLobbyView.swift
//  gleeming
//
//  Created by ervan on 10/09/25.
//

import SwiftUI

// MARK: - Multiplayer Lobby View Wrapper for proper theme reactivity
struct MultiplayerLobbyViewWrapper: View {
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var gameSettings = GameSettings.shared
    
    var body: some View {
        MultiplayerLobbyView()
            .environment(\.themeManager, themeManager)
            .preferredColorScheme(themeManager.currentColorScheme)
            .id(gameSettings.selectedTheme.rawValue)
    }
}

struct MultiplayerLobbyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var roomCode: String = ""
    @State private var isCreatingRoom = false
    @State private var isJoiningRoom = false
    @State private var selectedGameMode: MultiplayerGameMode = .simultaneous
    @State private var showingCreateRoom = false
    @State private var showingJoinRoom = false
    @StateObject private var viewModel = MultiplayerViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 28) {
                Text("Multiplayer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                // Connection Status
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
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                
                // Game Mode Selection
                VStack(spacing: 16) {
                    Text("Game Mode")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        ForEach(MultiplayerGameMode.allCases) { mode in
                            MultiplayerModeCard(
                                mode: mode,
                                isSelected: selectedGameMode == mode
                            ) {
                                selectedGameMode = mode
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Divider()
                
                VStack(spacing: 16) {
                    Button(action: {
                        showingCreateRoom = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Create Room")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isConnected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        .foregroundColor(viewModel.isConnected ? .blue : .gray)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.isConnected)
                    
                    HStack {
                        TextField("Enter Room Code", text: $roomCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .onSubmit {
                                if !roomCode.isEmpty && viewModel.isConnected {
                                    joinRoom()
                                }
                            }
                        
                        Button(action: joinRoom) {
                            Text("Join")
                                .fontWeight(.semibold)
                        }
                        .disabled(roomCode.isEmpty || !viewModel.isConnected)
                    }
                    .padding(.horizontal, 8)
                    
                    if !viewModel.isConnected {
                        Text("Connecting to server...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
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
            }
        }
        .sheet(isPresented: $showingCreateRoom) {
            CreateRoomView()
        }
        .sheet(isPresented: $showingJoinRoom) {
            JoinRoomView(viewModel: viewModel, roomCode: $roomCode)
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isInRoom },
            set: { _ in }
        )) {
            RoomLobbyView(viewModel: viewModel)
                .onAppear {
                    // Dismiss create/join room sheets when entering a room
                    showingCreateRoom = false
                    showingJoinRoom = false
                    print("🔍 MultiplayerLobbyView: RoomLobbyView appeared")
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
    
    private func joinRoom() {
        Task {
            await viewModel.joinRoom(withCode: roomCode)
        }
    }
}

struct MultiplayerModeCard: View {
    let mode: MultiplayerGameMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
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
    MultiplayerLobbyViewWrapper()
}
