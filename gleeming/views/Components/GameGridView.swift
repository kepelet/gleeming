//
//  GameGridView.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import SwiftUI

struct GameGridView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let gridSize = min(geometry.size.width, geometry.size.height) - 32
            let cellSize = (gridSize - CGFloat(viewModel.gridCells.count - 1) * 8) / CGFloat(viewModel.gridCells.count)
            
            VStack(spacing: 8) {
                ForEach(0..<viewModel.gridCells.count, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.gridCells[row].count, id: \.self) { column in
                            GridCellView(cell: viewModel.gridCells[row][column]) {
                                viewModel.cellTapped(at: GridPosition(row: row, column: column))
                            }
                            .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
            .frame(width: gridSize, height: gridSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

#Preview {
    GameGridView(viewModel: GameViewModel())
        .frame(width: 300, height: 300)
}
