//
//  ContentView+HabitRecordDetailComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI
import HabitRepositoryFW


extension ContentView {
    
    @ViewBuilder
    func makeHabitRecordDetailView(activityRecord: HabitRecord) -> some View {
        // Adding navigation stack to get the goodies of toolbar and adding that to the keyboard .numberPad
        let activityDetailCount = activityRecord.habit.activityDetails.count
        
        NavigationStack {
            HabitRecordDetailView(blockHabitStore: blockHabitStore, activityRecord: activityRecord)
        }
        .recordSheetPresentation(activityDetailCount: activityDetailCount)
    }
}
