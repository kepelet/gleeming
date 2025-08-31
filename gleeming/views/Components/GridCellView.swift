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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeManager) private var themeManager
    
    private var colors: ThemeManager.GameColors {
        themeManager.colors(for: colorScheme)
    }
    
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
                .animation(.easeInOut(duration: 0.2), value: cell.isWrong)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var cellColor: Color {
        if cell.isHighlighted {
            return colors.cellHighlighted
        } else if cell.isWrong {
            return colors.cellWrong
        } else if cell.isSelected {
            return colors.cellSelected
        } else {
            return colors.cellDefault
        }
    }
    
    private var strokeColor: Color {
        if cell.isHighlighted || cell.isWrong || cell.isSelected {
            return colors.cellBorderActive
        } else {
            return colors.cellBorder
        }
    }
    
    private var strokeWidth: CGFloat {
        if cell.isHighlighted || cell.isSelected || cell.isWrong {
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
        
        GridCellView(cell: GridCell(position: GridPosition(row: 0, column: 3), isWrong: true)) {}
    }
    .padding()
}
