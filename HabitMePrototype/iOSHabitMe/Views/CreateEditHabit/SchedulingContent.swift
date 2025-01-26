//
//  SchedulingContent.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import SwiftUI
import HabitRepositoryFW

struct ReminderInfo: View {
    
    let backgroundColor: Color
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    let scheduledWeekDays: Set<ScheduleDay>
    let reminderTime: Date
    
    var body: some View {
        
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading) {
//                    Label("\(scheduleSummary)", systemImage: "bell")
//                        .foregroundStyle(.primary)
                HStack {
                    Image(systemName: "bell")
                    Text("\(scheduleSummary)")
                }
                .foregroundStyle(.primary)
                Text("\(DateFormatter.shortTime.string(from: reminderTime))")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .sectionBackground(padding: .detailPadding, color: backgroundColor)
        } else {
            HStack {
                Label("\(scheduleSummary)", systemImage: "bell")
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(DateFormatter.shortTime.string(from: reminderTime))")
            }
            .sectionBackground(padding: .detailPadding, color: backgroundColor)
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
            if scheduledWeekDays.count == 7 {
                return "Daily"
            } else {
                return scheduledWeekDays.sorted { $0.rawValue < $1.rawValue }.map { $0.abbreviation }.joined(separator: ", ")
            }
//        }
    }
}

struct SchedulingNotificationSettingsContent: View {
    
//    let habit: Habit
    let reminderName: String
    let scheduledWeekDays: Set<ScheduleDay>
    let reminderTime: Date
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("\(reminderName)")
                .hAlign(.leading)
            ReminderInfo(backgroundColor: .secondaryBackground, scheduledWeekDays: scheduledWeekDays, reminderTime: reminderTime)
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
            if scheduledWeekDays.count == 7 {
                return "Daily"
            } else {
                return scheduledWeekDays.sorted { $0.rawValue < $1.rawValue }.map { $0.abbreviation }.joined(separator: ", ")
            }
//        }
    }
}

struct SchedulingContent: View {

    // MARK: Injected Properties
    @Binding var schedulingUnits: ScheduleTimeUnit // "Frequency" - Ex: "Daily", "Weekly"
    @Binding var rate: Int // "Every" in Reminders App - "Every Day", "Every 2 Days", "Every Week
    @Binding var scheduledWeekDays: Set<ScheduleDay>
    @Binding var reminderTime: Date? // If it is not nil then a reminder has been set, else no reminder for habit
    // Navigation
    let goToScheduleSelection: (Binding<ScheduleTimeUnit>, Binding<Int>, Binding<Set<ScheduleDay>>, Binding<Date?>) -> Void
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text("Reminders")
                
                Spacer()
                
                CustomDisclosure()
            }
            
            
            if let reminderTime {
                
                ReminderInfo(backgroundColor: .tertiaryBackground, scheduledWeekDays: scheduledWeekDays, reminderTime: reminderTime)
                
            } else {
                
                Text("Set Reminders for this habit")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .onTapGesture {
            goToScheduleSelection(
                $schedulingUnits,
                $rate,
                $scheduledWeekDays,
                $reminderTime
            )
        }
    }
}


#Preview {
    
    @Previewable @State var schedulingUnits: ScheduleTimeUnit = .weekly
    @Previewable @State var rate = 1
    @Previewable @State var scheduledWeekDays: Set<ScheduleDay> = ScheduleDay.allDays
    @Previewable @State var reminderTime: Date? = Date()
    
    return VStack {
        SchedulingContent(
            
            schedulingUnits: $schedulingUnits,
            rate: $rate,
            scheduledWeekDays: $scheduledWeekDays,
            reminderTime: $reminderTime,
            goToScheduleSelection: { _, _, _, _ in }
        )
        
        Form {
            SchedulingNotificationSettingsContent(
                reminderName: "Shave Carrot",
                scheduledWeekDays: [
                    ScheduleDay.monday,
                    ScheduleDay.tuesday,
                    ScheduleDay.wednesday,
                    ScheduleDay.thursday,
                    ScheduleDay.friday,
                    ScheduleDay.saturday
                ], //ScheduleDay.allDays,
                reminderTime: Date()
            )
        }
    }
}
