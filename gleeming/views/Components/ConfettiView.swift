//
//  ConfettiView.swift
//  gleeming
//
//  Created by ervan on 03/09/25.
//

import SwiftUI

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var animationTimer: Timer?
    let isActive: Bool
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
        .onAppear {
            if isActive {
                startConfetti()
            }
        }
        .onDisappear {
            stopConfetti()
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                startConfetti()
            } else {
                stopConfetti()
            }
        }
    }
    
    private func startConfetti() {
        // Generate initial confetti pieces
        generateConfetti()
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateConfetti()
        }
        
        // Stop confetti after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            stopConfetti()
        }
    }
    
    private func stopConfetti() {
        animationTimer?.invalidate()
        animationTimer = nil
        
        withAnimation(.easeOut(duration: 1.0)) {
            confettiPieces.removeAll()
        }
    }
    
    private func generateConfetti() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: Double.random(in: -50...screenWidth + 50),
                y: -50,
                color: confettiColors.randomElement() ?? .blue,
                rotation: Double.random(in: 0...360),
                size: Double.random(in: 4...12),
                velocityX: Double.random(in: -4...4),
                velocityY: Double.random(in: 4...10),
                rotationSpeed: Double.random(in: -15...15)
            )
            confettiPieces.append(piece)
        }
    }
    
    private func updateConfetti() {
        let screenHeight = UIScreen.main.bounds.height
        
        withAnimation(.linear(duration: 0.1)) {
            for i in confettiPieces.indices {
                confettiPieces[i].x += confettiPieces[i].velocityX
                confettiPieces[i].y += confettiPieces[i].velocityY
                confettiPieces[i].rotation += confettiPieces[i].rotationSpeed
                
                // Remove pieces that have fallen off screen
                if confettiPieces[i].y > screenHeight + 50 {
                    confettiPieces.remove(at: i)
                    break
                }
            }
        }
    }
    
    private let confettiColors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan
    ]
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    let color: Color
    var rotation: Double
    let size: Double
    let velocityX: Double
    let velocityY: Double
    let rotationSpeed: Double
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size * 0.6)
            .rotationEffect(.degrees(piece.rotation))
            .position(x: piece.x, y: piece.y)
    }
}

#Preview {
    ConfettiView(isActive: true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}
