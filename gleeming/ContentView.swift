//
//  ContentView.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showGame = false
    
    var body: some View {
        if showGame {
            GameView(showGame: $showGame)
                .transition(.move(edge: .trailing))
        } else {
            WelcomeView(showGame: $showGame)
                .transition(.move(edge: .leading))
        }
    }
}

#Preview {
    ContentView()
}
