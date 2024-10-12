//
//  SchedulingContent.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import SwiftUI
import HabitRepositoryFW

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
                
                HStack {
                    Label("\(scheduleSummary)", systemImage: "bell")
                    Spacer()
                    Text("\(DateFormatter.shortTime.string(from: reminderTime))")
                }
                .sectionBackground(padding: .detailPadding, color: .tertiaryBackground)
                
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


#Preview {
    
    @State var schedulingUnits: ScheduleTimeUnit = .weekly
    @State var rate = 1
    @State var scheduledWeekDays: Set<ScheduleDay> = ScheduleDay.allDays
    @State var reminderTime: Date? = Date()
    
    return SchedulingContent(
        
        schedulingUnits: $schedulingUnits,
        rate: $rate,
        scheduledWeekDays: $scheduledWeekDays,
        reminderTime: $reminderTime,
        goToScheduleSelection: { _, _, _, _ in }
    )
}
