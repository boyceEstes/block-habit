//
//  ContentView+HabitRecordDetailComposition.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI


extension ContentView {
    
    @ViewBuilder
    func makeHabitRecordDetailView(activityRecord: DataHabitRecord) -> some View {
        // Adding navigation stack to get the goodies of toolbar and adding that to the keyboard .numberPad
        let activityDetailCount = activityRecord.habit?.activityDetails.count ?? 1
        
        NavigationStack {
            HabitRecordDetailView(activityRecord: activityRecord)
        }
        .recordSheetPresentation(activityDetailCount: activityDetailCount)
    }
}
