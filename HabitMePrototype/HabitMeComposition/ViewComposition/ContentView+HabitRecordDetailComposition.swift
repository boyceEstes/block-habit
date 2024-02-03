//
//  ContentView+HabitRecordDetailComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI


extension ContentView {
    
    @ViewBuilder
    func makeHabitRecordDetailView(habitRecord: DataHabitRecord) -> some View {
        
        HabitRecordDetailView(activityRecord: habitRecord)
    }
}
