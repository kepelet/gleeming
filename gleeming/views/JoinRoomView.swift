//
//  JoinRoomView.swift
//  gleeming
//
//  Created by ervan on 10/09/25.
//

import SwiftUI

struct JoinRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MultiplayerViewModel
    @Binding var roomCode: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "door.right.hand.open")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Join Room")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Enter the room code to join an existing game")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                // Player Name
                VStack(alignment: .leading, spacing: 12) {
                    Text("Player Name")
                        .font(.headline)
                    
                    TextField("Enter your name", text: Binding(
                        get: { viewModel.playerName },
                        set: { viewModel.updatePlayerName($0) }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                }
                .padding(.horizontal, 20)
                
                // Room Code
                VStack(alignment: .leading, spacing: 12) {
                    Text("Room Code")
                        .font(.headline)
                    
                    TextField("Enter room code", text: $roomCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .font(.system(.body, design: .monospaced))
                        .onChange(of: roomCode) { oldValue, newValue in
                            // Auto-format: trim whitespace and convert to uppercase
                            let formatted = newValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                            if formatted != newValue {
                                roomCode = formatted
                            }
                        }
                }
                .padding(.horizontal, 20)
                
                // Join Button
                Button(action: {
                    Task {
                        let trimmedCode = roomCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                        await viewModel.joinRoom(withCode: trimmedCode)
                        print("🔍 JoinRoomView: After joinRoom, isInRoom = \(viewModel.isInRoom)")
                        // Don't dismiss here - let the parent view handle navigation
                    }
                }) {
                    HStack {
                        if viewModel.isJoiningRoom {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "door.right.hand.open")
                        }
                        
                        Text(viewModel.isJoiningRoom ? "Joining..." : "Join Room")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canJoinRoom ? .blue : .gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!canJoinRoom)
                .padding(.horizontal, 20)
                
                if !canJoinRoom {
                    Text(joinRequirementText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isInRoom },
            set: { _ in }
        )) {
            RoomLobbyView(viewModel: viewModel)
                .onAppear {
                    print("🔍 JoinRoomView: RoomLobbyView appeared from JoinRoomView")
                }
        }
    }
    
    private var canJoinRoom: Bool {
        viewModel.isConnected &&
        viewModel.isPlayerNameValid &&
        isRoomCodeValid &&
        !viewModel.isJoiningRoom
    }
    
    private var isRoomCodeValid: Bool {
        let trimmedCode = roomCode.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedCode.count >= 4 && trimmedCode.count <= 8
    }
    
    private var joinRequirementText: String {
        if !viewModel.isConnected {
            return "Connecting to server..."
        } else if !viewModel.isPlayerNameValid {
            return "Please enter a valid player name"
        } else if !isRoomCodeValid {
            return "Please enter a valid room code"
        } else {
            return ""
        }
    }
}

#Preview {
    let viewModel = MultiplayerViewModel()
    return JoinRoomView(viewModel: viewModel, roomCode: .constant("ABC123"))
}
