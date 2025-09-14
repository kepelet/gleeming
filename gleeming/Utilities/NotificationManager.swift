//
//  NotificationManager.swift
//  gleeming
//
//  Created by ervan on 14/09/25.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private let gameSettings = GameSettings.shared
    private let userStats = UserStats.shared
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            
            if granted {
                await scheduleNotifications()
            }
            
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    /// Handle initial permission request for new users who have notifications enabled by default
    func handleInitialPermissionRequest() async {
        // Only request if notifications are enabled in settings and permission is not determined
        guard gameSettings.notificationsEnabled && authorizationStatus == .notDetermined else {
            return
        }
        
        // Request permission automatically for new users
        let granted = await requestAuthorization()
        
        // If permission is denied, turn off the setting to reflect actual state
        if !granted {
            await MainActor.run {
                gameSettings.notificationsEnabled = false
                gameSettings.saveSettings()
            }
        }
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleNotifications() async {
        guard gameSettings.notificationsEnabled && authorizationStatus == .authorized else {
            await cancelAllNotifications()
            return
        }
        
        // Cancel existing notifications
        await cancelAllNotifications()
        
        // Schedule notifications for the next 7 days
        let calendar = Calendar.current
        let now = Date()
        
        for dayOffset in 1...7 {
            guard let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            
            // Random time between 8 PM (20:00) and 10 PM (22:00)
            let randomHour = 20
            let randomMinute = Int.random(in: 0...119) // 0-119 minutes (2 hours range)
            let finalMinute = randomMinute % 60
            let finalHour = randomHour + (randomMinute / 60)
            
            var components = calendar.dateComponents([.year, .month, .day], from: futureDate)
            components.hour = finalHour
            components.minute = finalMinute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let content = UNMutableNotificationContent()
            let messageData = getRandomNotificationMessage()
            content.title = messageData.title
            content.body = messageData.body
            content.sound = .default
            content.badge = 1
            
            let identifier = "gleeming_reminder_\(dayOffset)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Failed to schedule notification: \(error)")
            }
        }
        
        print("Scheduled \(7) notifications for the next week")
    }
    
    private func cancelAllNotifications() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Notification Messages
    
    private func getRandomNotificationMessage() -> (title: String, body: String) {
        let titles = [
            "🧠 Memory Training Time!",
            "🎯 Challenge Your Mind",
            "⚡ Brain Boost Available",
            "🌟 Ready for a Challenge?",
            "🎮 Game Time!",
            "🔥 Keep Your Streak Going",
            "💪 Mental Workout Time"
        ]
        
        let baseMessages = [
            "Take a break from scrolling and train your memory!",
            "Your brain deserves better than endless scrolling.",
            "Transform screen time into brain training time.",
            "Challenge yourself with some memory patterns!",
            "Ready to give your mind a productive workout?",
            "Trade mindless scrolling for mindful gaming.",
            "Time to exercise those memory muscles!"
        ]
        
        let title = titles.randomElement() ?? "🧠 Memory Training Time!"
        var body = baseMessages.randomElement() ?? "Take a break from scrolling and train your memory!"
        
        // Add score information if available
        if userStats.hasAnyStats {
            let scoreMessages = [
                " Your best score: \(userStats.highestScore) points!",
                " Can you beat your record of \(userStats.highestScore) points?",
                " Your best streak was \(userStats.bestStreak) - can you top it?",
                " You've reached level \(userStats.highestLevel) before!",
                " Last high score: \(userStats.highestScore). Ready to beat it?"
            ]
            
            body += scoreMessages.randomElement() ?? ""
        } else {
            let encouragementMessages = [
                " Start building your memory skills!",
                " Your first game awaits!",
                " Begin your memory training journey!",
                " Time to set your first high score!"
            ]
            
            body += encouragementMessages.randomElement() ?? ""
        }
        
        return (title: title, body: body)
    }
    
    // MARK: - Settings Integration
    
    func updateNotificationSettings() {
        Task {
            if gameSettings.notificationsEnabled && authorizationStatus == .authorized {
                await scheduleNotifications()
            } else {
                await cancelAllNotifications()
            }
        }
    }
    
    // MARK: - App Lifecycle Integration
    
    func handleAppDidBecomeActive() {
        checkAuthorizationStatus()
        
        // Reset badge count
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Handle initial permission request for new users
        Task {
            await handleInitialPermissionRequest()
            
            // Reschedule notifications if needed
            if gameSettings.notificationsEnabled && authorizationStatus == .authorized {
                await scheduleNotifications()
            }
        }
    }
    
    func handleNotificationReceived() {
        // Reset badge count when notification is received
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: - Debug Methods
    
    #if DEBUG
    /// For testing notifications quickly during development
    func scheduleTestNotification(delaySeconds: Double = 10) async {
        guard authorizationStatus == .authorized else {
            print("Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        let messageData = getRandomNotificationMessage()
        content.title = messageData.title
        content.body = messageData.body
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delaySeconds, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Test notification scheduled for \(delaySeconds) seconds")
        } catch {
            print("Failed to schedule test notification: \(error)")
        }
    }
    
    /// Check what notifications are currently scheduled
    func debugPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending notifications: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("  - \(request.identifier): \(trigger.dateComponents)")
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("  - \(request.identifier): in \(trigger.timeInterval) seconds")
                }
            }
        }
    }
    #endif
}
