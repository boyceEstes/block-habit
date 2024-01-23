//
//  HabitDetailView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/23/24.
//

import SwiftUI

struct HabitDetailView: View {
    
    let habit: Habit
    // Keeping a separate selectedDay here so that it does not impact the home screen when
    // this is dismissed
    @State private var selectedDay: Date = Date().noon!
    // Query to fetch all of the habit records for the habit
    
    var body: some View {
        
        GeometryReader { proxy in
//            
//            BarView(graphHeight: graphHeight, dataHabitRecordsOnDate: dataHabitRecordsOnDate, selectedDay: $selectedDay)
        }
        .navigationTitle("Habit Details: \(habit.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HabitDetailView(habit: Habit.meditation)
    }
}
