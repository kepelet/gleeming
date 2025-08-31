//
//  gleemingApp.swift
//  gleeming
//
//  Created by ervan on 29/08/25.
//

import SwiftUI

@main
struct gleemingApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var gameSettings = GameSettings.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.themeManager, themeManager)
                .preferredColorScheme(themeManager.currentColorScheme)
        }
    }
}
