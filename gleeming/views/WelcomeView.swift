//
//  WelcomeView.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showGame: Bool
    @State private var showingSettings = false
    @State private var showingGameModeSelection = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with settings button
                HStack {
                    Spacer()
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 10)
                
                // App branding - more compact
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 4) {
                        Text("Gleeming")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Train your memory")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Conditional content based on user experience
                if UserStats.shared.hasAnyStats {
                    // Experienced user: Show stats + compact instructions
                    UserStatsView()
                    
                    VStack(spacing: 12) {
                        Text("How to Play")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 20) {
                            CompactHowToPlayItem(icon: "eye", text: "Watch")
                            CompactHowToPlayItem(icon: "hand.tap", text: "Repeat")
                            CompactHowToPlayItem(icon: "arrow.up", text: "Level up")
                        }
                    }
                    .padding(.vertical, 8)
                } else {
                    // New user: Show detailed instructions
                    VStack(spacing: 16) {
                        Text("How to Play")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HowToPlayItem(
                                icon: "eye",
                                text: "Watch the pattern carefully"
                            )
                            HowToPlayItem(
                                icon: "hand.tap",
                                text: "Repeat the sequence by tapping"
                            )
                            HowToPlayItem(
                                icon: "arrow.up",
                                text: "Each level gets progressively harder"
                            )
                            HowToPlayItem(
                                icon: "trophy",
                                text: "Build your streak and score"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Start button
                Button("Start Playing") {
                    showingGameModeSelection = true
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsViewWrapper(isPresented: $showingSettings)
        }
        .sheet(isPresented: $showingGameModeSelection) {
            GameModeSelectionViewWrapper(showGame: $showGame)
        }
    }
}

struct HowToPlayItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct CompactHowToPlayItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WelcomeView(showGame: .constant(false))
}
