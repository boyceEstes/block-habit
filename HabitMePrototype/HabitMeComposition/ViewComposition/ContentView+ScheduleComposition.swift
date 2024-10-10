//
//  ContentView+ScheduleComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import SwiftUI


extension ContentView {
    
    func makeScheduleView(schedulingUnits: Binding<ScheduleTimeUnit>, rate: Binding<Int>, scheduledWeekDays: Binding<Set<ScheduleDay>>, reminderTime: Binding<Date?>) -> ScheduleHabitView {
        
        return ScheduleHabitView()
    }
}
