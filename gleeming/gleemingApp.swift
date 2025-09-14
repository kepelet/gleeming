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
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.themeManager, themeManager)
                .preferredColorScheme(themeManager.currentColorScheme)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    notificationManager.handleAppDidBecomeActive()
                }
        }
    }
}
