//
//  NotificationSettingsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/12/24.
//

import SwiftUI
import HabitRepositoryFW


struct NotificationSettingsView: View {
    
    @EnvironmentObject var habitController: HabitController
    @State private var isAllNotificationsAllowed: Bool = true
    
    init() {
        self._isAllNotificationsAllowed = State(initialValue: UserDefaults.isNotificationsAllowed)
    }
    
    var isNotAllowedSummary: String {
        "Notifications are disabled - you will get ZERO reminders"
    }
    
    var habitsWithReminders: [Habit] {
        
        habitController.habitsWithReminders
    }
    
    var body: some View {
        
        Form {
            Section {
                Toggle("Allow Notifications", isOn: $isAllNotificationsAllowed)
            } footer: {
                if !isAllNotificationsAllowed {
                    Text("\(isNotAllowedSummary)")
                        .font(.caption)
                }
            }
            
            if !habitsWithReminders.isEmpty {
                Section("Habits with Reminders") {
                    ForEach(habitsWithReminders, id: \.self) { habit in

                        SchedulingNotificationSettingsContent(
                            reminderName: habit.name,
                            scheduledWeekDays: habit.scheduledWeekDays,
                            reminderTime: habit.reminderTime ?? Date()
                        )
                    }
                }
            }
        }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: isAllNotificationsAllowed) { _, isAllNotificationsAllowed in
                
                
     
                habitController.notificationSettingsChanged(isOn: isAllNotificationsAllowed)
            }
//            .onChange(of: isAllNotificationsAllowed) { _, newValue in
//                // Save this value
//                UserDefaults.isNotificationsAllowed = newValue
//                
//                if newValue {
//                    print("turned on")
//                    // We need to ensure that everything is scheduled
////                    habitController.scheduleAllHabitsWithNotifications()
//                } else {
//                    print("turned off")
//                    // We need to ensure that everything is unscheduled
////                    habitController.unscheduleAllHabitsWithNotifications()
//                }
//            }
    }
}


#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
    .environmentObject(
        HabitController(
            blockHabitRepository: CoreDataBlockHabitStore.preview(),
            selectedDay: Date()
        )
    )
}
