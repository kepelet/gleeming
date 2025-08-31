//
//  SettingsView.swift
//  gleeming
//
//  Created by ervan on 30/08/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var gameSettings = GameSettings.shared
    @State private var showingGridSizePicker = false
    @State private var showingDifficultyPicker = false
    @State private var showingThemePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Settings sections
                ScrollView {
                    VStack(spacing: 20) {
                        gameSettingsSection
                        audioSettingsSection
                        visualSettingsSection
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .confirmationDialog("Select Grid Size", isPresented: $showingGridSizePicker) {
            ForEach(gameSettings.availableGridSizes, id: \.self) { size in
                let sizeDisplay = "\(size)×\(size)"
                let isSelected = size == gameSettings.gridSize
                let title = isSelected ? "✓ \(sizeDisplay)" : sizeDisplay
                
                Button(title) {
                    gameSettings.gridSize = size
                    gameSettings.saveSettings()
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose the grid size for your game")
        }
        .confirmationDialog("Select Difficulty Mode", isPresented: $showingDifficultyPicker) {
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
        .confirmationDialog("Select Theme", isPresented: $showingThemePicker) {
            ForEach(GameSettings.Theme.allCases, id: \.self) { theme in
                let isSelected = theme == gameSettings.selectedTheme
                let title = isSelected ? "✓ \(theme.displayName)" : theme.displayName
                
                Button(title) {
                    gameSettings.selectedTheme = theme
                    gameSettings.saveSettings()
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Auto: Follows system appearance\nLight: Always light mode\nDark: Always dark mode")
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Done") {
                isPresented = false
            }
            .font(.headline)
            .foregroundColor(.blue)
            
            Spacer()
            
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("Done")
                .font(.headline)
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var gameSettingsSection: some View {
        SettingsSection(title: "Game") {
            SettingsRow(
                icon: "gamecontroller",
                title: "Difficulty",
                subtitle: gameSettings.difficultyMode.displayName,
                action: {
                    showingDifficultyPicker = true
                }
            )
            
            SettingsRow(
                icon: "grid",
                title: "Grid Size",
                subtitle: gameSettings.gridSizeDisplay,
                action: {
                    showingGridSizePicker = true
                }
            )
            
            SettingsRow(
                icon: "timer",
                title: "Show Duration",
                subtitle: gameSettings.showDurationDisplay,
                action: {}
            )
        }
    }
    
    private var audioSettingsSection: some View {
        SettingsSection(title: "Audio") {
            SettingsToggleRow(
                icon: "speaker.wave.2",
                title: "Sound Effects",
                isOn: $gameSettings.soundEffectsEnabled
            )
            
            SettingsToggleRow(
                icon: "music.note",
                title: "Background Music",
                isOn: $gameSettings.backgroundMusicEnabled
            )
            
            SettingsRow(
                icon: "speaker.3",
                title: "Volume",
                subtitle: gameSettings.volumeDisplay,
                action: {}
            )
        }
    }
    
    private var visualSettingsSection: some View {
        SettingsSection(title: "Visual") {
            SettingsToggleRow(
                icon: "wand.and.rays",
                title: "Animations",
                isOn: $gameSettings.animationsEnabled
            )
            
            SettingsToggleRow(
                icon: "iphone.radiowaves.left.and.right",
                title: "Haptic Feedback",
                isOn: $gameSettings.hapticFeedbackEnabled
            )
            
            SettingsRow(
                icon: "paintbrush",
                title: "Theme",
                subtitle: gameSettings.selectedTheme.displayName,
                action: { showingThemePicker = true }
            )
        }
    }
    
    private var aboutSection: some View {
        SettingsSection(title: "About") {
            SettingsRow(
                icon: "info.circle",
                title: "App Version",
                subtitle: "1.0.0",
                action: {}
            )
            
            SettingsRow(
                icon: "questionmark.circle",
                title: "How to Play",
                subtitle: "",
                action: {}
            )
            
            SettingsRow(
                icon: "star",
                title: "Rate App",
                subtitle: "",
                action: {}
            )
            
            SettingsRow(
                icon: "square.and.arrow.up",
                title: "Share App",
                subtitle: "",
                action: {}
            )
        }
    }
}

// MARK: - Supporting Views
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    SettingsView(isPresented: .constant(true))
}
