//
//  ContentView+CreateActivityRecordWithDetailsComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/4/24.
//

import SwiftUI
import HabitRepositoryFW


extension ContentView {
    
    @ViewBuilder
    func makeCreateActivityRecordWithDetails(activity: Habit, selectedDay: Date) -> some View {
        
        // FIXME: When `Habit` has activityDetails attached to it - this is low key view logic that should be done in the view now the composition anyway
        let activityDetailCount = 2 //activity.activityDetails.count
        NavigationStack {
            CreateHabitRecordWithDetailsView(
                activity: activity,
                selectedDay: selectedDay,
                blockHabitStore: blockHabitStore
            )
        }
        // Basic dynamic sizing - not the fun stuff I'm experimenting with but simple and safe
        .recordSheetPresentation(activityDetailCount: activityDetailCount)
    }
}

