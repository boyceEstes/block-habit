//
//  ContentView+CreateActivityRecordWithDetailsComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/4/24.
//

import SwiftUI



extension ContentView {
    
    @ViewBuilder
    func makeCreateActivityRecordWithDetails(activity: DataHabit) -> some View {
        
        NavigationStack {
            CreateHabitRecordWithDetailsView(activity: activity)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.background)
    }
}
