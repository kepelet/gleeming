//
//  GameSettingsView.swift
//  gleeming
//
//  Created by ervan on 09/09/25.
//

import SwiftUI

// MARK: - Game Settings View Wrapper for proper theme reactivity
struct GameSettingsViewWrapper: View {
    @Binding var showGame: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var gameSettings = GameSettings.shared
    
    var body: some View {
        GameSettingsView(showGame: $showGame)
            .environment(\.themeManager, themeManager)
            .preferredColorScheme(themeManager.currentColorScheme)
            .id(gameSettings.selectedTheme.rawValue)
    }
}




struct GameSettingsView: View {
    @Binding var showGame: Bool
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameSettings = GameSettings.shared
    @State private var showingDifficultyPicker = false
    @State private var showingGridSizePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Game Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Customize your game experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)
                
                // Settings Cards
                VStack(spacing: 16) {
                    GameSettingCard(
                        icon: "gamecontroller",
                        title: "Game Mode",
                        subtitle: gameSettings.difficultyMode.displayName,
                        description: gameSettings.difficultyMode == .random ? 
                            "Each level has a completely new pattern" : 
                            "Each level adds one step to the pattern",
                        color: .blue
                    ) {
                        showingDifficultyPicker = true
                    }
                    
                    GameSettingCard(
                        icon: "grid",
                        title: "Grid Size",
                        subtitle: gameSettings.gridSizeDisplay,
                        description: "Larger grids are more challenging",
                        color: .green
                    ) {
                        showingGridSizePicker = true
                    }
                    
                    GameSettingToggleCard(
                        icon: "stopwatch",
                        title: "Timed Mode",
                        subtitle: gameSettings.timedModeEnabled ? "On" : "Off",
                        description: gameSettings.timedModeEnabled ? 
                            "Race against the clock for extra challenge" : 
                            "Play at your own pace",
                        color: .orange,
                        isOn: $gameSettings.timedModeEnabled,
                        onToggle: {
                            gameSettings.saveSettings()
                        }
                    )
                    
                    GameSettingToggleCard(
                        icon: "heart.fill",
                        title: "Forgiving Mode",
                        subtitle: gameSettings.forgivingModeEnabled ? "On" : "Off",
                        description: gameSettings.forgivingModeEnabled ? 
                            "Get 3 lives and continue playing after mistakes" : 
                            "Classic mode - one mistake ends the game",
                        color: .pink,
                        isOn: $gameSettings.forgivingModeEnabled,
                        onToggle: {
                            gameSettings.saveSettings()
                        }
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Start Game Button
                Button("Start Game") {
                    dismiss()
                    showGame = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
            }
        }
        .confirmationDialog("Select Grid Size", isPresented: $showingGridSizePicker) {
            ForEach(GameSettings.GridSize.allCases, id: \.self) { size in
                let isSelected = size == gameSettings.gridSize
                let title = isSelected ? "✓ \(size.displayName)" : size.displayName
                
                Button(title) {
                    gameSettings.gridSize = size
                    gameSettings.saveSettings()
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose the grid size for your game")
        }
        .confirmationDialog("Select Game Mode", isPresented: $showingDifficultyPicker) {
            ForEach(GameSettings.DifficultyMode.allCases, id: \.self) { mode in
                let isSelected = mode == gameSettings.difficultyMode
                let title = isSelected ? "✓ \(mode.displayName)" : mode.displayName
                
                Button(title) {
                    gameSettings.difficultyMode = mode
                    gameSettings.saveSettings()
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Random: New pattern each level\nProgressive: Each level adds one step")
        }
    }
}

struct GameSettingCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                        .frame(width: 40, height: 40)
                        .background(color.opacity(0.1))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                
                if !description.isEmpty {
                    HStack {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct GameSettingToggleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    @Binding var isOn: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .onChange(of: isOn) { _ in
                        onToggle()
                    }
            }
            .padding(16)
            
            if !description.isEmpty {
                HStack {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    GameSettingsViewWrapper(showGame: .constant(false))
}
