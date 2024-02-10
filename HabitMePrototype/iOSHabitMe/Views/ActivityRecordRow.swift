//
//  ActivityRecordRow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/9/24.
//

import SwiftUI



/// Intended for use when displaying activity records that will have some sort of Title and Date in the title
/// For example, in the DayView.
struct ActivityRecordRowTitleDate: View {
    
    // This is for knowing the date to display
    let selectedDay: Date
    let activityRecord: ActivityRecord
    
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: .rowVDetailSpacing) {
            HStack(alignment: .center) {
                Text("\(activityRecord.title)")
                    .font(.rowTitle)
                Spacer()
                Text("\(DisplayDatePolicy.date(for: activityRecord, on: selectedDay))")
                    .font(.callout)
            }
            
            let detailRecords = activityRecord.detailRecords
            
            if !detailRecords.isEmpty {
                ActivityDetailRecordIndicators(detailRecords: detailRecords)
            }
        }
    }
}


/// Intended for use when displaying activity records that will only need some Date as the title
/// For example, the `HabitDetailView` would show logs with only the date
struct ActivityRecordRowDate: View {
    
    let activityRecord: ActivityRecord
    
    var body: some View {
        
        let date = activityRecord.completionDate.displayDate
        
        ActivityRecordRow {
            Text("\(date)")
                .font(.rowTitle)
        } detailRecordContent: {
            
        }
    }
}


/// Intended to prevent duplicate logic and points of failure between different rows displaying activity record date
fileprivate struct ActivityRecordRow<TitleContent: View, DetailRecordContent: View>: View {
    
    let titleContent: TitleContent
    let detailRecordContent: DetailRecordContent
    
    init(@ViewBuilder titleContent: () -> TitleContent, @ViewBuilder detailRecordContent: () -> DetailRecordContent) {
        
        self.titleContent = titleContent()
        self.detailRecordContent = detailRecordContent()
    }
    
    
    var body: some View {
        
        VStack(alignment: .center, spacing: .rowVDetailSpacing) {
            titleContent
            detailRecordContent
        }
    }
}


struct ActivityDetailRecordIndicators: View {
    
    let detailRecords: [ActivityDetailRecord2]
    
    var body: some View {
        
        HStack {
            ForEach(detailRecords, id: \.id) { detailRecord in
                
                let detail = detailRecord.detail
                
                detail.valueType.asset.image()
                    .foregroundColor(.secondaryFont)
            }
        }
    }
}


struct ActivityRecordRowContent: View {
    
    let detailRecords: [ActivityDetailRecord2]
    
    var body: some View {
        
        // FIXME: Ensure that there is never too many details to where this goes out of bounds - the view will be ruined - for lower numbers it should be okay though.
        LazyVStack(alignment: .leading) {

            ActivityDetailRecordIndicators(detailRecords: detailRecords)
//            ActivityDetailRecordGrid(detailRecords: detailRecords)
            ActivityDetailRecordRowContentInfo(detailRecords: detailRecords)
        }
    }
}


struct ActivityDetailRecordRowContentInfo: View {
    
    let detailRecords: [ActivityDetailRecord2]
    
    
    var numberActivityDetailRecords: [ActivityDetailRecord2] {
        detailRecords.valueType(.number)
    }
    
    var textActivityDetailRecords: [ActivityDetailRecord2] {
        detailRecords.valueType(.text)
    }
    
    var body: some View {
        
        VStack {
            ActivityDetailRecordNumberGrid(numberActivityDetailRecords: numberActivityDetailRecords)
            ActivityDetailRecordTextList(textActivityDetailRecords: textActivityDetailRecords)
        }
    }
}



// FIXME: How do I ensure that this will only have `activityDetail` values where valueType == .text
struct ActivityDetailRecordTextList: View {
    
    let textActivityDetailRecords: [ActivityDetailRecord2]
    
    var body: some View {
        
        ForEach(textActivityDetailRecords) { textActivityDetailRecord in
            
            VStack(alignment: .leading) {
                Text("\(textActivityDetailRecord.detail.name)")
                    .font(.callout)
                    .foregroundStyle(Color.secondaryFont)
                Text("\(textActivityDetailRecord.value)")
            }
            .sectionBackground()
        }
    }
}




// FIXME: How do I ensure that this will only have `activityDetail` values where valueType == .number
struct ActivityDetailRecordNumberGrid: View {
    
    let numberActivityDetailRecords: [ActivityDetailRecord2]
    
    let columnCount: Int
    
    var columns: [GridItem] {
        Array(repeatElement(GridItem(.flexible(), alignment: .top), count: columnCount))
    }
    
    init(numberActivityDetailRecords: [ActivityDetailRecord2]) {
        
        self.numberActivityDetailRecords = numberActivityDetailRecords
        
        let columnLimit = 3
        let recordCount = numberActivityDetailRecords.count
        self.columnCount = recordCount >= columnLimit ? columnLimit : recordCount
    }
    
    
    var body: some View {
        
        LazyVGrid(columns: columns) {
            
            ForEach(numberActivityDetailRecords) { numberActivityDetailRecord in
                
                VStack(alignment: .leading) {
                    Text("\(numberActivityDetailRecord.detail.name)")
                        .font(.callout)
                        .foregroundStyle(Color.secondaryFont)
                    
                    ViewThatFits(in: .horizontal) {
                        
                        hStackFit(for: numberActivityDetailRecord)
                        vStackFit(for: numberActivityDetailRecord)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .sectionBackground()
            }
        }
    }
    
    
    @ViewBuilder
    func hStackFit(for numberActivityDetailRecord: ActivityDetailRecord2) -> some View {
        
        let units = numberActivityDetailRecord.detail.units
        
        HStack {
            Text("\(numberActivityDetailRecord.value)")
                .layoutPriority(1)
            if let units {
                Text(units)
                    .font(.callout)
            }
        }
        .lineLimit(1)
    }
    
    @ViewBuilder
    func vStackFit(for numberActivityDetailRecord: ActivityDetailRecord2) -> some View {
        
        let units = numberActivityDetailRecord.detail.units
        
        VStack(alignment: .leading) {
            Text("\(numberActivityDetailRecord.value)")
            if let units {
                Text(units)
                    .font(.callout)
            }
        }
        .lineLimit(1)
    }
}
    


#Preview {
    
    let activityDetailTime = ActivityDetail(
        name: "Time",
        valueType: .number,
        units: "minutes"
    )
    
    
    let activityDetailAmount = ActivityDetail(
        name: "Amount",
        valueType: .number,
        units: "fl oz"
    )
    
    
    let activityDetailLength = ActivityDetail(
        name: "Length",
        valueType: .number
    )
    
    
    let activityDetailTouchdowns = ActivityDetail(
        name: "Touchdowns",
        valueType: .number,
        units: "tds"
    )
    
    
    let activityDetailNote = ActivityDetail(
        name: "Note",
        valueType: .text
    )
    
    
    let activityDetailRecordTimeRecord = ActivityDetailRecord2(
        value: "1000",
        detail: activityDetailTime
    )
    
    
    let activityDetailRecordAmountRecord = ActivityDetailRecord2(
        value: "28",
        detail: activityDetailAmount
    )
    
    
    let activityDetailLengthRecord = ActivityDetailRecord2(
        value: "203",
        detail: activityDetailLength
    )
    
    
    let activityDetailTouchdownsRecord = ActivityDetailRecord2(
        value: "21024",
        detail: activityDetailTouchdowns
    )
    
    
    let activityDetailRecordNoteRecord = ActivityDetailRecord2(
        value: "It was tough. I understood the meaning behind Code Red today. It is the code of blood. The code of pushing through the pain. It is the code of war.",
        detail: activityDetailNote
    )
    
    
    let activityRecord = ActivityRecord(
        title: "Chugging Dew",
        creationDate: Date(),
        completionDate: Date(),
        detailRecords: [
            activityDetailRecordTimeRecord,
            activityDetailRecordAmountRecord
//            activityDetailLengthRecord,
//            activityDetailRecordNoteRecord,
//            activityDetailTouchdownsRecord
        ]
    )
    
    return ActivityRecordRowTitleDate(selectedDay: Date(), activityRecord: activityRecord).sectionBackground()
}


