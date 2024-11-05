//
//  RecordDetailsForDaysList.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 11/4/24.
//

import SwiftUI
import HabitRepositoryFW


struct RecordDetailsForDaysList: View {
    
    let color: Color
    let recordsForDays: [Date: [HabitRecord]]
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: .vItemSpacing) {
            
            // FIXME: 2 Orient this so that all the information is given
            Text("Records")
                .font(.title3)
            
            if !recordsForDays.isEmpty {
                ForEach(recordsForDays.sorted(by: { $0.key > $1.key }), id: \.key) { day, records in
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("\(day.displayDate)")
                                .font(.rowTitle)
                                .layoutPriority(1)
                            Spacer()
                        }
                        
                        let totalRecordInfo = totalNumberSumForDay(records: records)
                        
                        WrappingHStack(horizontalSpacing: 8, verticalSpacing: 8) {
                            ForEach(totalRecordInfo.sorted(by: { $0.key.name > $1.key.name }), id: \.key) { activityDetail, value in
                                
                                HStack {
                                    Text("\(activityDetail.name)")
                                    Text("\(String(format: "%.2f", value))")
                                }
                                .padding(4)
                                .font(.caption)
                                .foregroundStyle(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(color)
                                )
                            }
                        }
                    }
                    
//                    ForEach(records, id: \.self) { record in
//                        WrappingHStack {
//                            
//                        }
//                    }
//                    ForEach(records, id: \.self) { record in
//                        ActivityRecordRowDateWithInfo(habitRecord: record)
//                    }
                }
            } else {
                Text("You've never done this before. You should try it. Come on, do it. You won't... wimp.")
                    .foregroundColor(.secondaryFont)
                    .font(.rowDetail)
            }
        }
        
    }
    
    
    func totalNumberSumForDay(records: [HabitRecord]) -> [ActivityDetail: Double] {
        
        // We want to return ActivityDetailREcord and its corresponding sum for the day
        var sumForRecords = [ActivityDetail: Double]()
        // We'll tackle summation first, its easier
        
        // Each record has some number of activity detail records
        // Those activity detail records could be
        for record in records {
            // For each record, go through each of the activity detail records...
            // if it is a value, then update based on the new information.
            // This means that we will need to keep track of the
            for activityDetailRecord in record.activityDetailRecords {
                
                if activityDetailRecord.activityDetail.valueType == .number {
                    
                    if activityDetailRecord.activityDetail.calculationType == .sum {
                        
                        let latestValue = Double(activityDetailRecord.value) ?? -1.0
                        
                        if sumForRecords[activityDetailRecord.activityDetail] == nil {
                            sumForRecords[activityDetailRecord.activityDetail] = latestValue
                        } else {
                            sumForRecords[activityDetailRecord.activityDetail]! += latestValue
                        }
                    }
                } // Else its text and we can't sum it
            }
        }
        
        return sumForRecords
    }
}


#Preview {
    
    @Previewable @State var recordsForDays = HabitRecord.recordsForDaysPreviewForOneHabitWithActivityDetails(date: Date())
    
    ScrollView {
        RecordDetailsForDaysList(color: .orange, recordsForDays: recordsForDays)
    }
}
