//
//  SettingsView.swift
//  gleeming
//
//  Created by ervan on 30/08/25.
//

import SwiftUI
import UserNotifications

// MARK: - Settings View Wrapper for proper theme reactivity
struct SettingsViewWrapper: View {
    @Binding var isPresented: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var gameSettings = GameSettings.shared
    
    var body: some View {
        SettingsView(isPresented: $isPresented)
            .environment(\.themeManager, themeManager)
            .preferredColorScheme(themeManager.currentColorScheme)
            .id(gameSettings.selectedTheme.rawValue)
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var gameSettings = GameSettings.shared
    @Environment(\.themeManager) private var themeManager
    @State private var showingThemePicker = false
    @State private var showingVolumeSlider = false
    @State private var showingVisualModePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Settings sections
                ScrollView {
                    VStack(spacing: 20) {
                        audioSettingsSection
                        visualSettingsSection
                        notificationSettingsSection
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)

        .confirmationDialog("Select Theme", isPresented: $showingThemePicker) {
            ForEach(GameSettings.Theme.allCases, id: \.self) { theme in
                let isSelected = theme == gameSettings.selectedTheme
                let title = isSelected ? "✓ \(theme.displayName)" : theme.displayName
                
                Button(title) {
                    gameSettings.selectedTheme = theme
                    gameSettings.saveSettings()
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Auto: Follows system appearance\nLight: Always light mode\nDark: Always dark mode")
        }
        .confirmationDialog("Select Visual Mode", isPresented: $showingVisualModePicker) {
            ForEach(GameSettings.VisualMode.allCases, id: \.self) { mode in
                let isSelected = mode == gameSettings.visualMode
                let title = isSelected ? "✓ \(mode.displayName)" : mode.displayName
                
                Button(title) {
                    gameSettings.visualMode = mode
                    gameSettings.saveSettings()
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Zen: Show only tiles for maximum focus\nMinimal: Show essential controls only\nFull: Show complete interface with all elements")
        }
        .sheet(isPresented: $showingVolumeSlider) {
            VolumeAdjustmentView(isPresented: $showingVolumeSlider)
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Done") {
                isPresented = false
            }
            .font(.headline)
            .foregroundColor(.blue)
            
            Spacer()
            
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("Done")
                .font(.headline)
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var audioSettingsSection: some View {
        SettingsSection(title: "Audio") {
            SettingsToggleRow(
                icon: "speaker.wave.2",
                title: "Sound Effects",
                isOn: $gameSettings.soundEffectsEnabled
            )

            // TODO: Implement background music
            // SettingsToggleRow(
            //     icon: "music.note",
            //     title: "Background Music",
            //     isOn: $gameSettings.backgroundMusicEnabled
            // )

            
            SettingsRow(
                icon: "speaker.3",
                title: "Volume",
                subtitle: gameSettings.volumeDisplay,
                action: { showingVolumeSlider = true }
            )
        }
    }
    
    private var visualSettingsSection: some View {
        SettingsSection(title: "Visual") {
            SettingsToggleRow(
                icon: "sparkles",
                title: "Confetti",
                isOn: $gameSettings.confettiEnabled
            )
            
            SettingsToggleRow(
                icon: "iphone.radiowaves.left.and.right",
                title: "Haptic Feedback",
                isOn: $gameSettings.hapticFeedbackEnabled
            )
            
            SettingsRow(
                icon: "paintbrush",
                title: "Theme",
                subtitle: gameSettings.selectedTheme.displayName,
                action: { showingThemePicker = true }
            )
            
            SettingsRow(
                icon: "eye",
                title: "Visual Mode",
                subtitle: gameSettings.visualMode.displayName,
                action: { showingVisualModePicker = true }
            )
        }
    }
    
    private var notificationSettingsSection: some View {
        SettingsSection(title: "Notifications") {
            NotificationSettingsToggleRow()
        }
    }
    
    private var aboutSection: some View {
        SettingsSection(title: "About") {
            SettingsRow(
                icon: "info.circle",
                title: "App Version",
                subtitle: appVersion,
                action: {}
            )
            
            SettingsRow(
                icon: "questionmark.circle",
                title: "How to Play",
                subtitle: "",
                action: {}
            )
            
            SettingsRow(
                icon: "star",
                title: "Rate App",
                subtitle: "",
                action: {}
            )
            
            SettingsRow(
                icon: "square.and.arrow.up",
                title: "Share App",
                subtitle: "",
                action: {}
            )
        }
    }
    
    // MARK: - Computed Properties
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
}

// MARK: - Supporting Views
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Volume Adjustment View

struct VolumeAdjustmentView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var gameSettings = GameSettings.shared
    @State private var testSoundTimer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button("Done") {
                    testSoundTimer?.invalidate()
                    isPresented = false
                }
                .font(.headline)
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Volume")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Invisible button for balance
                Button("Done") {
                    isPresented = false
                }
                .hidden()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Volume Slider
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "speaker.1")
                        .foregroundColor(.secondary)
                    
                    Slider(value: $gameSettings.volume, in: 0...1) { editing in
                        if !editing {
                            gameSettings.saveSettings()
                            // Play test sound when user stops dragging
                            playTestSound()
                        }
                    }
                    
                    Image(systemName: "speaker.3")
                        .foregroundColor(.secondary)
                }
                
                Text("\(Int(gameSettings.volume * 100))%")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .onDisappear {
            testSoundTimer?.invalidate()
        }
    }
    
    private func playTestSound() {
        // Play a test note to preview volume
        let position = GridPosition(row: 0, column: 0)
        SoundManager.shared.playNoteForGridPosition(position, gridSize: 4)
    }
}

// MARK: - Notification Settings Toggle Row
struct NotificationSettingsToggleRow: View {
    @ObservedObject private var gameSettings = GameSettings.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingPermissionAlert = false
    
    // Computed property to show actual notification state
    private var isNotificationActuallyEnabled: Bool {
        gameSettings.notificationsEnabled && notificationManager.authorizationStatus == .authorized
    }
    
    private var notificationStatusText: String {
        if !gameSettings.notificationsEnabled {
            return "No daily reminders"
        }
        
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "Active - reminds you to play between 8-10 PM"
        case .denied:
            return "Permission denied - tap to enable in Settings"
        case .notDetermined:
            return "Permission will be requested automatically"
        default:
            return "Permission required"
        }
    }
    
    private var statusColor: Color {
        if !gameSettings.notificationsEnabled {
            return .secondary
        }
        
        switch notificationManager.authorizationStatus {
        case .authorized:
            return .secondary
        case .denied:
            return .orange
        case .notDetermined:
            return .blue
        default:
            return .orange
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: isNotificationActuallyEnabled ? "bell.fill" : "bell.slash.fill")
                    .font(.title3)
                    .foregroundColor(isNotificationActuallyEnabled ? .blue : .gray)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reminders")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(notificationStatusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
                
                Spacer()
                
                Toggle("", isOn: $gameSettings.notificationsEnabled)
                    .labelsHidden()
                    .onChange(of: gameSettings.notificationsEnabled) { _, newValue in
                        handleNotificationToggle()
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            if gameSettings.notificationsEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack {
                        if notificationManager.authorizationStatus == .authorized {
                            Text("Get gentle reminders to play memory games instead of mindless scrolling")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        } else if notificationManager.authorizationStatus == .denied {
                            Text("Notifications are disabled. Tap the toggle again to open Settings and enable them.")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text("We'll ask for notification permission to send gentle reminders for healthy screen time habits")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
        }
        .alert("Enable Notifications", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) {
                gameSettings.notificationsEnabled = false
                gameSettings.saveSettings()
            }
        } message: {
            Text("To receive memory training reminders, please enable notifications in Settings.")
        }
    }
    
    private func handleNotificationToggle() {
        if gameSettings.notificationsEnabled {
            // User wants to enable notifications
            switch notificationManager.authorizationStatus {
            case .notDetermined:
                // Request permission for first time
                Task {
                    let granted = await notificationManager.requestAuthorization()
                    if !granted {
                        await MainActor.run {
                            gameSettings.notificationsEnabled = false
                            gameSettings.saveSettings()
                        }
                    } else {
                        await MainActor.run {
                            gameSettings.saveSettings()
                            notificationManager.updateNotificationSettings()
                        }
                    }
                }
            case .denied:
                // Permission was denied, open Settings directly
                openAppSettings()
                // Keep the toggle on since user indicated they want notifications
                gameSettings.saveSettings()
            case .authorized:
                // Already authorized, just save and schedule
                gameSettings.saveSettings()
                notificationManager.updateNotificationSettings()
            default:
                // Other states (provisional, ephemeral) - try to save anyway
                gameSettings.saveSettings()
                notificationManager.updateNotificationSettings()
            }
        } else {
            // User wants to disable notifications
            gameSettings.saveSettings()
            notificationManager.updateNotificationSettings()
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

#Preview {
    SettingsViewWrapper(isPresented: .constant(true))
}
