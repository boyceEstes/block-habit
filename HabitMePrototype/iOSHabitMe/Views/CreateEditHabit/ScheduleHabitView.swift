//
//  ScheduleHabitView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import SwiftUI
import HabitRepositoryFW


//
//struct SelectableHabit: Hashable, SelectableListItem {
//
//    let id: String
//    let name: String
//    var isSelected: Bool = true
//    var colorString: String?
//    
//    // This is kept for easily keeping data that will be needed later
//    var habit: Habit
//    
//    init(habit: Habit) {
//        self.id = habit.id
//        self.name = habit.name
//        self.colorString = habit.color
//        self.habit = habit
//    }
//}

struct SelectableScheduleDay: SelectableListItem {

    var id: String
    let name: String
    var isSelected: Bool
    var color: Color
    
    let scheduleDay: ScheduleDay
    
    init(scheduleDay: ScheduleDay, isSelected: Bool) {
        
        self.id = "\(scheduleDay.rawValue)"
        self.name = scheduleDay.abbreviation
        self.isSelected = isSelected
        self.color = .blue
        
        self.scheduleDay = scheduleDay
    }
}


//@Binding var selectedWeekDays: Set<ScheduleDay>  // This is the set of selected days

//@State private var selectableDays: [SelectableScheduleDay] = ScheduleDay.allCases.map {
//    SelectableScheduleDay(scheduleDay: $0, isSelected: false)
//}
//
//var body: some View {
//    VStack {
////        WeekSelectionView(selectableDays: $selectableDays)
//        
//        // Display the selected days in the parent view for verification
//        Text("Selected Days: \(selectedWeekDays.map { $0.abbreviation }.joined(separator: ", "))")
//            .padding()
//    }
//    .onChange(of: selectableDays) { newValue in
//        updateSelectedDays(newSelectableDays: newValue)
//    }
//    .onAppear {
//        syncSelectableDaysWithSelectedWeekDays()  // Ensure the selectableDays reflect the current selectedWeekDays
//    }
//}



struct ScheduleHabitView: View {
    
    // MARK: Environment
    @EnvironmentObject var habitController: HabitController
    // MARK: Injected Properties
    @Binding var schedulingUnits: ScheduleTimeUnit // "Frequency" - Ex: "Daily", "Weekly"
    @Binding var rate: Int // "Every" in Reminders App - "Every Day", "Every 2 Days", "Every Week
    @Binding var scheduledWeekDays: Set<ScheduleDay> {
        didSet {
            print("most recent \(scheduledWeekDays)")
        }
    }
    @Binding var reminderTime: Date? // If it is not nil then a reminder has been set, else no reminder for
    // MARK: View Properties
    // These make it easier to transition values
    @State private var isReminderTimeAvailableToSet: Bool
    @State private var nonOptionalReminderTime: Date
    @State private var selectableScheduleDays: [SelectableScheduleDay] = ScheduleDay.allCases.map {
        SelectableScheduleDay(scheduleDay: $0, isSelected: true)
    }
    // Notification Permission
    @State private var isPermittedToNotification = true
    // Alerts
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    // MARK: User Defaults
    @AppStorage("\(UserDefaults.CustomKey.isNotificationsAllowed.rawValue)") var isInAppNotificationAllowed = true
    
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
                    NotificationsNotEnabledView()
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                        .background(Color(uiColor: .secondarySystemBackground))
                )
            }
            
            if !isInAppNotificationAllowed {
                
                Section {
                    InAppNotificationsNotEnabledView {
                        habitController.notificationSettingsChanged(isOn: true)
                    }
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
                    WeekSelectionView(items: $selectableScheduleDays)
                    
                    DatePicker("Time", selection: $nonOptionalReminderTime, displayedComponents: .hourAndMinute)
                } footer: {
                    if isReminderTimeAvailableToSet, let reminderTime = reminderTime {
                        VStack {
                            Text("Notifications will be delivered \(scheduleSummary) at \(DateFormatter.shortTime.string(from: reminderTime))")
                        }
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
        .onChange(of: selectableScheduleDays, { _, newValue in
            updateSelectedDays(newSelectableDays: newValue)
        })
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertMessage, isPresented: $showAlert, actions: {})
        .onAppear {
            syncSelectableDaysWithSelectedWeekDays()
        }
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
    
    // Update the selectedWeekDays set whenever selectableDays changes
    private func updateSelectedDays(newSelectableDays: [SelectableScheduleDay]) {
        scheduledWeekDays = Set(
            newSelectableDays
            .filter { $0.isSelected }             // Only include selected days
            .map { $0.scheduleDay }
        )                                           // Map to ScheduleDay
    }

    // Sync the isSelected property of selectableDays with selectedWeekDays on appear
    private func syncSelectableDaysWithSelectedWeekDays() {
        for i in selectableScheduleDays.indices {
            selectableScheduleDays[i].isSelected = scheduledWeekDays.contains(selectableScheduleDays[i].scheduleDay)
        }
    }
    
    
    private var scheduleSummary: String {
        
//        switch schedulingUnits {
//        case .daily:
//            if rate == 1 {
//                return "Daily"
//            } else {
//                return "Every \(rate) days"
//            }
//        case .weekly:
//            if scheduledWeekDays.count == 7 {
//                return "Daily"
//            } else {
//                return scheduledWeekDays.sorted { $0.rawValue < $1.rawValue }.map { $0.abbreviation }.joined(separator: ", ")
//            }
//        }
        
        if scheduledWeekDays.count == 7 {
            return "Daily"
        } else {
            return scheduledWeekDays.sorted { $0.rawValue < $1.rawValue }.map { $0.abbreviation }.joined(separator: ", ")
        }
    }
    
    
    private func setupSelectableWeekDays() {
        
        var _selectableScheduleDays: [SelectableScheduleDay] = []
        
        ScheduleDay.allCases.forEach { scheduleDay in
            
            let isSelected = scheduledWeekDays.contains(scheduleDay) ? true : false
            _selectableScheduleDays.append(SelectableScheduleDay(scheduleDay: scheduleDay, isSelected: isSelected))
        }
        
        self.selectableScheduleDays = _selectableScheduleDays
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
    
    @Previewable @State var schedulingUnits: ScheduleTimeUnit = .weekly
    @Previewable @State var rate = 1
    @Previewable @State var scheduledWeekDays: Set<ScheduleDay> = ScheduleDay.allDays
    @Previewable @State var reminderTime: Date? = Date()
    
    
    return NavigationStack {
        ScheduleHabitView(
            
            schedulingUnits: $schedulingUnits,
            rate: $rate,
            scheduledWeekDays: $scheduledWeekDays,
            reminderTime: $reminderTime
        )
    }
}
