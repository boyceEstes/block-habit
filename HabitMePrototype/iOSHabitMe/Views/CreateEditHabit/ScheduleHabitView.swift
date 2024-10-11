//
//  ScheduleHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import SwiftUI
import HabitRepositoryFW

struct ScheduleHabitView: View {
    
    // MARK: Injected Properties
    @Binding var schedulingUnits: ScheduleTimeUnit // "Frequency" - Ex: "Daily", "Weekly"
    @Binding var rate: Int // "Every" in Reminders App - "Every Day", "Every 2 Days", "Every Week
    @Binding var scheduledWeekDays: Set<ScheduleDay>
    @Binding var reminderTime: Date? // If it is not nil then a reminder has been set, else no reminder for
    // MARK: View Properties
    // These make it easier to transition values
    @State private var isReminderTimeAvailableToSet: Bool
    @State private var nonOptionalReminderTime: Date
    // Notification Permission
    @State private var isPermittedToNotification = true
    // Alerts
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    
    
    init(
        schedulingUnits: Binding<ScheduleTimeUnit>,
        rate: Binding<Int>,
        scheduledWeekDays: Binding<Set<ScheduleDay>>,
        reminderTime: Binding<Date?>
    ) {
        self._schedulingUnits = schedulingUnits
        self._rate = rate
        self._scheduledWeekDays = scheduledWeekDays
        self._reminderTime = reminderTime
        
        // If reminderTime has content, then it should be toggled on
        self._isReminderTimeAvailableToSet = State(wrappedValue: reminderTime.wrappedValue != nil)
        self._nonOptionalReminderTime = State(wrappedValue: reminderTime.wrappedValue != nil ? reminderTime.wrappedValue! : Date())
    }
    
    var body: some View {
        
        Form {
            if !isPermittedToNotification {
                Section {
                    NotificationsNotEnabled()
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                        .background(Color(uiColor: .secondarySystemBackground))
                )
            }

            Section {
                Toggle("Reminders", isOn: $isReminderTimeAvailableToSet)
            } footer: {
                if !isReminderTimeAvailableToSet {
                    Text("There will be no notification reminders for this habit")
                }
            }
            
            if isReminderTimeAvailableToSet {
                Section {
//                    HStack {
//                        ForEach(ScheduleDay.allCases, id: \.self) { scheduleDay in
//                            Text("\(scheduleDay.abbreviation)")
//                        }
//                    }
                    DatePicker("Time", selection: $nonOptionalReminderTime, displayedComponents: .hourAndMinute)
                }
                footer: {
                    if isReminderTimeAvailableToSet, let reminderTime = reminderTime {
                        Text("Notifications will be delivered daily at \(DateFormatter.shortTime.string(from: reminderTime))")
                    }
                }
            }
        }
        .onChange(of: nonOptionalReminderTime) { _, newValue in
            reminderTime = newValue
        }
        .onChange(of: isReminderTimeAvailableToSet) { _, newValue in
            if newValue {
                // Show latest time
                nonOptionalReminderTime = Date()
            } else {
                // Nil out the time if no reminders
                reminderTime = nil
            }
        }
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertMessage, isPresented: $showAlert, actions: {})
        .task {
            await setUIForNotificationPermission()
        }
        // When app comes back after (potentially) toggling permission
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            
            Task {
                await setUIForNotificationPermission()
            }
        }
    }
    
    
    private func setUIForNotificationPermission() async {
        
        let manager = NotificationPermissionManager.shared
        
        let authStatus = await manager.checkNotificationPermission()
        
        switch authStatus {
        case .notDetermined:
            do {
                let isGranted = try await manager.requestNotificationPermission()
                await setIsPermittedToNotification(isGranted)
            } catch {
                await setError(error)
            }
            
        case .authorized, .provisional, .ephemeral:
            print("Granted! ...Mostly")
            await setIsPermittedToNotification(true)
            
        default:
            print("Denied (or something)...Foiled again!")
            await setIsPermittedToNotification(false)
        }
    }
    
    
    private func setIsPermittedToNotification(_ isPermitted: Bool) async {
        
        await MainActor.run {
            isPermittedToNotification = isPermitted
        }
    }
    
    
    private func setError(_ error: Error) async {
        
        await MainActor.run {
            
            showAlert = true
            alertMessage = error.localizedDescription
        }
    }
}


#Preview {
    
    @State var schedulingUnits: ScheduleTimeUnit = .weekly
    @State var rate = 1
    @State var scheduledWeekDays: Set<ScheduleDay> = ScheduleDay.allDays
    @State var reminderTime: Date? = Date()
    
    
    return NavigationStack {
        ScheduleHabitView(
            
            schedulingUnits: $schedulingUnits,
            rate: $rate,
            scheduledWeekDays: $scheduledWeekDays,
            reminderTime: $reminderTime
        )
    }
}
