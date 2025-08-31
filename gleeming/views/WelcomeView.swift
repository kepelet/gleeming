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
    
    var body: some View {
        VStack(spacing: 32) {
            // Settings button in top trailing corner
            HStack {
                Spacer()
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Gleeming")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("train your memory")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
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
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Start button
            Button("Start Playing") {
                showGame = true
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showingSettings) {
            SettingsViewWrapper(isPresented: $showingSettings)
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

#Preview {
    WelcomeView(showGame: .constant(false))
}
