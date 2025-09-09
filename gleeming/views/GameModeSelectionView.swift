//
//  GameModeSelectionView.swift
//  gleeming
//
//  Created by ervan on 06/09/25.
//

import SwiftUI

// MARK: - Game Mode Selection View Wrapper for proper theme reactivity
struct GameModeSelectionViewWrapper: View {
    @Binding var showGame: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var gameSettings = GameSettings.shared
    
    var body: some View {
        GameModeSelectionView(showGame: $showGame)
            .environment(\.themeManager, themeManager)
            .preferredColorScheme(themeManager.currentColorScheme)
            .id(gameSettings.selectedTheme.rawValue)
    }
}

struct GameModeSelectionView: View {
    @Binding var showGame: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showingGameSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("Choose Game Mode")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                VStack(spacing: 20) {
                    // Single Player Button
                    Button {
                        showingGameSettings = true
                    } label: {
                        GameModeCard(
                            icon: "person.fill",
                            title: "Single Player",
                            subtitle: "Train your memory solo",
                            color: .blue,
                            isEnabled: true
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Multiplayer Button (Disabled)
                    Button {
                        // No action - button is disabled
                    } label: {
                        GameModeCard(
                            icon: "person.2.fill",
                            title: "Multiplayer",
                            subtitle: "Coming soon",
                            color: .gray,
                            isEnabled: false
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(true)
                }
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
        .sheet(isPresented: $showingGameSettings) {
            GameSettingsViewWrapper(showGame: $showGame)
        }
    }
}

struct GameModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(isEnabled ? color : color.opacity(0.5))
                .frame(width: 60, height: 60)
                .background((isEnabled ? color : color.opacity(0.3)).opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(isEnabled ? .secondary : Color(.tertiaryLabel))
            }
            
            Spacer()
            
            Image(systemName: isEnabled ? "chevron.right" : "lock.fill")
                .font(.title3)
                .foregroundColor(isEnabled ? .secondary : Color(.tertiaryLabel))
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(isEnabled ? 0.05 : 0.02), radius: 8, x: 0, y: 4)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

#Preview {
    GameModeSelectionViewWrapper(showGame: .constant(false))
}
