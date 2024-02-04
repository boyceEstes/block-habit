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
        // Adding navigation stack to get the goodies of toolbar and adding that to the keyboard .numberPad
        NavigationStack {
            HabitRecordDetailView(activityRecord: habitRecord)
        }
    }
}
