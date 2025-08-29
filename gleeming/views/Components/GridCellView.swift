//
//  GridCellView.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import SwiftUI

struct GridCellView: View {
    let cell: GridCell
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            RoundedRectangle(cornerRadius: 12)
                .fill(cellColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .animation(.easeInOut(duration: 0.3), value: cell.isHighlighted)
                .animation(.easeInOut(duration: 0.2), value: cell.isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var cellColor: Color {
        if cell.isHighlighted {
            return .blue.opacity(0.8)
        } else if cell.isSelected {
            return .green.opacity(0.6)
        } else {
            return Color(.systemGray6)
        }
    }
    
    private var strokeColor: Color {
        if cell.isHighlighted {
            return .blue
        } else if cell.isSelected {
            return .green
        } else {
            return Color(.systemGray4)
        }
    }
    
    private var strokeWidth: CGFloat {
        if cell.isHighlighted || cell.isSelected {
            return 3
        } else {
            return 1
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GridCellView(cell: GridCell(position: GridPosition(row: 0, column: 0))) {}
        
        GridCellView(cell: GridCell(position: GridPosition(row: 0, column: 1), isHighlighted: true)) {}
        
        GridCellView(cell: GridCell(position: GridPosition(row: 0, column: 2), isSelected: true)) {}
    }
    .padding()
}
