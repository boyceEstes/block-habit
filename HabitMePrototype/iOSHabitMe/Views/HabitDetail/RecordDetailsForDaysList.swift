//
//  RecordDetailsForDaysList.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 11/4/24.
//

import SwiftUI
import HabitRepositoryFW


struct RecordDetailsForDaysList: View {
    
    let recordsForDays: [Date: [HabitRecord]]
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: .vItemSpacing) {
            
            // FIXME: 2 Orient this so that all the information is given
            Text("Records")
                .font(.title3)
            
            if !recordsForDays.isEmpty {
                ForEach(recordsForDays.sorted(by: { $0.key > $1.key }), id: \.key) { day, records in
                    
                    HStack {
                        Text("\(day.displayDate)")
                            .font(.rowTitle)
                            .layoutPriority(1)
                        Spacer()
                    }
                    
                    ForEach(records, id: \.self) { record in
                        ActivityRecordRowDateWithInfo(habitRecord: record)
                    }
                }
            } else {
                Text("You've never done this before. You should try it. Come on, do it. You won't... wimp.")
                    .foregroundColor(.secondaryFont)
                    .font(.rowDetail)
            }
        }
        
    }
}


#Preview {
    
    @Previewable @State var recordsForDays = HabitRecord.recordsForDaysPreviewForOneHabit(date: Date())
    
    RecordDetailsForDaysList(recordsForDays: recordsForDays)
}
