//
//  ContentView+ScheduleComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import SwiftUI
import HabitRepositoryFW


extension ContentView {
    
    func makeScheduleView(schedulingUnits: Binding<ScheduleTimeUnit>, rate: Binding<Int>, scheduledWeekDays: Binding<Set<ScheduleDay>>, reminderTime: Binding<Date?>) -> some View {
        
        return ScheduleHabitView(schedulingUnits: schedulingUnits, rate: rate, scheduledWeekDays: scheduledWeekDays, reminderTime: reminderTime)
            .interactiveDismissDisabled(true)
    }
}
