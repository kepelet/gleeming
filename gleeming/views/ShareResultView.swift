//
//  ShareResultView.swift
//  gleeming
//
//  Created by ervan on 31/08/25.
//

import SwiftUI

struct ShareResultView: View {
    let gameScore: GameScore
    let difficultyMode: GameSettings.DifficultyMode
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Share Result")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Balance for symmetry
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Result card preview
            resultCardView
                .padding(.horizontal, 20)
            
            // Share button
            Button("Share Image") {
                shareResult()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
        }
    }
    
    private var resultCardView: some View {
        VStack(spacing: 20) {
            // App branding
            VStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Gleeming")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Memory Training Game")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .padding(.horizontal, 20)
            
            // Game results
            VStack(spacing: 16) {
                ResultRow(title: "Level Reached", value: "\(gameScore.currentLevel)")
                ResultRow(title: "Total Score", value: "\(gameScore.totalScore)")
                ResultRow(title: "Best Streak", value: "\(gameScore.bestStreak)")
                ResultRow(title: "Game Mode", value: gameMode)
            }
            
            Spacer().frame(height: 10)
            
            // Footer
            Text("Train your memory with Gleeming!")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func shareResult() {
        guard let image = generateResultImage() else { return }
        
        shareItems = [
            image,
            shareText
        ]
        showingShareSheet = true
    }
    
    private func generateResultImage() -> UIImage? {
        // Use ImageRenderer for iOS 16+
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: shareableCardView)
            renderer.scale = 3.0 // High resolution for sharing
            return renderer.uiImage
        } else {
            // Fallback for iOS 15 and earlier
            return generateImageLegacy()
        }
    }
    
    @available(iOS, deprecated: 16.0, message: "Use ImageRenderer for iOS 16+")
    private func generateImageLegacy() -> UIImage? {
        let hostingController = UIHostingController(rootView: shareableCardView)
        let targetSize = CGSize(width: 400, height: 600)
        
        hostingController.view.bounds = CGRect(origin: .zero, size: targetSize)
        hostingController.view.backgroundColor = UIColor.clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            hostingController.view.layer.render(in: context.cgContext)
        }
    }
    
    private var shareableCardView: some View {
        VStack(spacing: 24) {
            // App branding
            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Gleeming")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Memory Training Game")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            // Decorative line
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(height: 2)
                .frame(maxWidth: 200)
            
            // Game results
            VStack(spacing: 20) {
                ShareResultRow(title: "Level Reached", value: "\(gameScore.currentLevel)")
                ShareResultRow(title: "Total Score", value: "\(gameScore.totalScore)")
                ShareResultRow(title: "Best Streak", value: "\(gameScore.bestStreak)")
                ShareResultRow(title: "Game Mode", value: gameMode)
            }
            
            // Footer with gradient background
            VStack(spacing: 8) {
                Text("Train your memory with Gleeming!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                
                Text("Available on iOS")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
        .padding(32)
        .frame(width: 400, height: 600)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color.blue.opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Helper Properties
    private var gameMode: String {
        if gameScore.isTimedMode {
            return "\(difficultyMode.displayName) • Timed"
        } else {
            return difficultyMode.displayName
        }
    }
    
    private var shareText: String {
        let modeText = gameScore.isTimedMode ? "timed mode" : "standard mode"
        return "I just reached level \(gameScore.currentLevel) in Gleeming (\(modeText))! 🧠⏱️ #MemoryTraining #Gleeming #BrainChallenge"
    }
}

// MARK: - Share Sheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Supporting Views
struct ResultRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct ShareResultRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ShareResultView(
        gameScore: GameScore(
            currentLevel: 15,
            currentSequenceLength: 17,
            totalScore: 1250,
            streak: 0,
            bestStreak: 12,
            timeRemaining: 0.0,
            isTimedMode: true
        ),
        difficultyMode: .random
    )
}
