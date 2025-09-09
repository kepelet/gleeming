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
        VStack(spacing: 0) {
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
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Main content area - centered
            VStack(spacing: 24) {
                Spacer()
                
                // App branding - larger
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 6) {
                        Text("Gleeming")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Train your memory")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Conditional content based on user experience - centered
                if UserStats.shared.hasAnyStats {
                    // Experienced user: Show stats + compact instructions
                    UserStatsView()
                    
                    VStack(spacing: 16) {
                        Text("How to Play")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 24) {
                            CompactHowToPlayItem(icon: "eye", text: "Watch")
                            CompactHowToPlayItem(icon: "hand.tap", text: "Repeat")
                            CompactHowToPlayItem(icon: "arrow.up", text: "Level up")
                        }
                    }
                } else {
                    // New user: Show detailed instructions
                    VStack(spacing: 20) {
                        Text("How to Play")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 16) {
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
                }
                
                Spacer()
                
                // Start button
                Button("Start Playing") {
                    showingGameModeSelection = true
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer()
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
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 28)
            
            Text(text)
                .font(.title3)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct CompactHowToPlayItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WelcomeView(showGame: .constant(false))
}
