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
                    
                    VStack(alignment: .leading, spacing: 8) {
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

                        LazyVStack(spacing: 0) {
                            
                            ForEach(Array(records.enumerated()), id: \.offset) { index, record in
                                
                                let completionDate = DateFormatter.shortTime.string(for: record.completionDate) ?? "Unknown Completion"
                                
                                ZStack(alignment: .bottom) {
                                    HStack {
                                        Text("\(completionDate)")
                                        Spacer()
                                        ActivityDetailRecordIndicators(detailRecords: record.activityDetailRecords)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 16)
                                    
                                    // We do not need a divider at the last element
                                    if index != records.count - 1 {
                                        Divider()
                                            .padding(.leading)
                                    }
                                }

                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(uiColor: .tertiarySystemBackground))
                        )
                    }
                    
                    
                    

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
        var tmpAvgForRecords = [ActivityDetail: (Double, Double)]()
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
                        
                        guard let latestValue = Double(activityDetailRecord.value) else { continue }
                        
                        if sumForRecords[activityDetailRecord.activityDetail] == nil {
                            sumForRecords[activityDetailRecord.activityDetail] = latestValue
                        } else {
                            sumForRecords[activityDetailRecord.activityDetail]! += latestValue
                        }
                        
                    } else {
                        
                        // This is an average type. We want to keep track of the number
                        // Average is sum / num - so we need to keep the count of each thing.
                        // We can do that by having a Dictionary with the
                        
                        guard let latestValue = Double(activityDetailRecord.value) else { continue }
                        
                        if tmpAvgForRecords[activityDetailRecord.activityDetail] == nil {
                            tmpAvgForRecords[activityDetailRecord.activityDetail] = (latestValue, 1)
                        } else {
                            guard let currentDayValuesForDetail = tmpAvgForRecords[activityDetailRecord.activityDetail] else { continue }
                            
                            let newestLatestValue = currentDayValuesForDetail.0 + latestValue
                            let numOfRecordsUntilNow = currentDayValuesForDetail.1
          
                            tmpAvgForRecords[activityDetailRecord.activityDetail] = (newestLatestValue, numOfRecordsUntilNow + 1)
                        }
                    }
                }
            }
        }
        
        
        let avgForRecords = tmpAvgForRecords.mapValues { value in
            
            let sum = value.0
            let count = value.1
            let average = sum / count
            
            return average
        }
        
        
        return sumForRecords.merging(avgForRecords) { current, new in
            current
        }
    }
}


#Preview {
    
    @Previewable @State var recordsForDays = HabitRecord.recordsForDaysPreviewForOneHabitWithActivityDetails(date: Date())
    
    ScrollView {
        RecordDetailsForDaysList(color: .orange, recordsForDays: recordsForDays)
    }
    .background(Color(uiColor: .secondarySystemBackground))
}
