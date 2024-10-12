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
    
    func scheduleNotification(for habit: Habit, previousDays: Set<ScheduleDay>? = nil) {
        
        Task {
        
            guard let reminderTime = habit.reminderTime else {
                
                // If we have turned off all notifications (nil reminderTime) then we will just keep this off
                removeNotifications(habitID: habit.id, days: previousDays ?? [])
                return
            }
            
            guard let previousDays, !previousDays.isEmpty else {
                
                // This happens on first creation of a habit with reminders. Schedule without worrying about removing anything
                scheduleNotifications(habitID: habit.id, days: habit.scheduledWeekDays, time: reminderTime, habitName: habit.name)
                return
            }
            
            guard !habit.scheduledWeekDays.isEmpty else {
                
                // Destroy whatever was in the previous days, no need to create anything
                removeNotifications(habitID: habit.id, days: previousDays)
                return
            }
            
            // Now, last case: We have a previous days and a current days. Get rid of all the previous day's notifications. Renew with Current days
            removeNotifications(habitID: habit.id, days: previousDays)
            scheduleNotifications(habitID: habit.id, days: habit.scheduledWeekDays, time: reminderTime, habitName: habit.name)
        }
    }
    
    
    func removeNotifications(habitID: String, days: Set<ScheduleDay>) {
        
        var idsToRemove = [String]()
        
        for day in days {
            
            let notificationID = "\(habitID)_\(day.rawValue)"
            idsToRemove.append(notificationID)
        }
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
    }
    
    
    private func scheduleNotifications(habitID: String, days: Set<ScheduleDay>, time: Date, habitName: String) {
        
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        
        for day in days {
            var dateComponents = DateComponents()
            dateComponents.weekday = day.dateComponentID
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let notificationID = "\(habitID)_\(day.rawValue)"
            
            let content = habitNotificationContent(habitName)
            
            let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
            registerNotificationRequest(request)
        }
    }
    
    
    private func registerNotificationRequest(_ request: UNNotificationRequest) {
        
        Task {
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            
            do {
                try await notificationCenter.add(request)

            } catch {
                // Handle errors that may occur during add.
                fatalError("N: HEHEHEHEHEHEHE")
            }
        }
    }
    
    
    private func habitNotificationContent(_ habitName: String) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "It's time to do your \(habitName)"
        content.sound = .default
        return content
    }
}
