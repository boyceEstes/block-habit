//
//  NotificationPermissionManager.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import UserNotifications


class NotificationPermissionManager {
    
    // MARK: Accessor
    static let shared = NotificationPermissionManager()
    // MARK: Constants
    let center = UNUserNotificationCenter.current()
    
    private init() {}

    
    // Check current notification permission status
    func checkNotificationPermission() async -> UNAuthorizationStatus {
        let settings = await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
        return settings.authorizationStatus
    }
    
    
    // Request notification permission
    /// Delivers `true` if notification request was granted
    func requestNotificationPermission() async throws -> Bool {
        
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
