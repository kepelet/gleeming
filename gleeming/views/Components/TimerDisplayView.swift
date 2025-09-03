//
//  TimerDisplayView.swift
//  gleeming
//
//  Created by ervan on 03/09/25.
//

import SwiftUI

struct TimerDisplayView: View {
    let timeRemaining: Double
    let isTimedMode: Bool
    
    var body: some View {
        if isTimedMode {
            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.caption)
                    .foregroundColor(timerColor)
                
                Text(timeString)
                    .font(.caption.monospacedDigit())
                    .foregroundColor(timerColor)
                    .animation(.easeInOut(duration: 0.2), value: timerColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(timerBackgroundColor)
            )
            .scaleEffect(timeRemaining <= 5.0 ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: timeRemaining <= 5.0)
        }
    }
    
    private var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var timerColor: Color {
        if timeRemaining <= 3.0 {
            return .red
        } else if timeRemaining <= 10.0 {
            return .orange
        } else {
            return .primary
        }
    }
    
    private var timerBackgroundColor: Color {
        if timeRemaining <= 3.0 {
            return .red.opacity(0.1)
        } else if timeRemaining <= 10.0 {
            return .orange.opacity(0.1)
        } else {
            return Color(.systemGray6)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TimerDisplayView(timeRemaining: 125.7, isTimedMode: true)
        TimerDisplayView(timeRemaining: 68.3, isTimedMode: true)
        TimerDisplayView(timeRemaining: 12.1, isTimedMode: true)
        TimerDisplayView(timeRemaining: 15.0, isTimedMode: false)
    }
    .padding()
}
