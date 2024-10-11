//
//  NotificationPermissionManager.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import UserNotifications

public class NotificationPermissionManager {
    
    // MARK: Accessor
    public static let shared = NotificationPermissionManager()
    // MARK: Constants
    let center = UNUserNotificationCenter.current()
    
    private init() {}

    
    // Check current notification permission status
    public func checkNotificationPermission() async -> UNAuthorizationStatus {
        let settings = await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
        return settings.authorizationStatus
    }
    
    
    // Request notification permission
    /// Delivers `true` if notification request was granted
    public func requestNotificationPermission() async throws -> Bool {
        
        return try await withCheckedThrowingContinuation() { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
}


// MARK: Scheduling

extension NotificationPermissionManager {
    
    func cancelNotifications(for habit: Habit) {
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [habit.id])
    }
    
    
    func scheduleNotification(for habit: Habit) {
        
        guard let reminderTime = habit.reminderTime else { return }
        
        let habitDateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: habitDateComponents, repeats: true)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let content = habitNotificationContent(habit)
        
        // I am going to be setting the notification requests with the Habit ID - these should all be guaranteed to be unique
        // this allows me to easily habits from the request queue if this is ever changed
        let request = UNNotificationRequest(identifier: habit.id, content: content, trigger: trigger)
        
        registerNotificationRequest(request)
    }

    
    private func registerNotificationRequest(_ request: UNNotificationRequest) {
        
        Task {
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            do {
                
                try await notificationCenter.add(request)
                let pendingRequests = await notificationCenter.pendingNotificationRequests()
                
                pendingRequests.forEach { request in
                    print("Pending notification: \(request.identifier), trigger: \(String(describing: request.trigger))")
                }
                
            } catch {
                // Handle errors that may occur during add.
                fatalError("HEHEHEHEHEHEHE")
            }
        }
    }
    
    
    private func habitNotificationContent(_ habit: Habit) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "It's time to do your \(habit.name)"
        content.sound = .default
        return content
    }

}
