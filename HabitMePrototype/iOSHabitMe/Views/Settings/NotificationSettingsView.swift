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
    
    @State private var isAllNotificationsAllowed = true
    
    var body: some View {
        
        VStack {
            Toggle("Allow Notifications", isOn: $isAllNotificationsAllowed)
            Spacer()
        }
            .padding(.horizontal)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: isAllNotificationsAllowed) { _, newValue in
                // Save this value
                UserDefaults.isNotificationsAllowed = newValue
                
                if newValue {
                    print("turned on")
                    // We need to ensure that everything is scheduled
//                    habitController.scheduleAllHabitsWithNotifications()
                } else {
                    print("turned off")
                    // We need to ensure that everything is unscheduled
//                    habitController.unscheduleAllHabitsWithNotifications()
                }
            }
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
