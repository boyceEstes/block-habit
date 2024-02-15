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
        
        VStack(alignment: .leading, spacing: .vRowSubtitleSpacing) {
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
struct ActivityRecordRowDateWithInfo: View {
    
    let activityRecord: ActivityRecord
    
    var body: some View {
        
        let completionDate = activityRecord.completionDate
        let titleDate = completionDate.displayDate
        
        VStack(alignment: .leading, spacing: .vRowSubtitleSpacing) {
            
            HStack {
                Text("\(titleDate)")
                    .font(.rowTitle)
                    .layoutPriority(1)
                Spacer()
                Text("\(DisplayDatePolicy.date(for: activityRecord, on: completionDate))")
                    .font(.rowDetail)
            }
            
            let detailRecords = activityRecord.detailRecords
            
            if !detailRecords.isEmpty {
                ActivityRecordRowContent(detailRecords: detailRecords)
            }
        }
    }
}


/// Intended to prevent duplicate logic and points of failure between different rows displaying activity record date
//fileprivate struct ActivityRecordRow<TitleContent: View, DetailRecordContent: View>: View {
//    
//    let titleContent: TitleContent
//    let detailRecordContent: DetailRecordContent
//    
//    init(@ViewBuilder titleContent: () -> TitleContent, @ViewBuilder detailRecordContent: () -> DetailRecordContent) {
//        
//        self.titleContent = titleContent()
//        self.detailRecordContent = detailRecordContent()
//    }
//    
//    
//    var body: some View {
//        
//        VStack(alignment: .center, spacing: .rowVDetailSpacing) {
//            titleContent
//            detailRecordContent
//        }
//    }
//}


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
        LazyVStack(alignment: .leading, spacing: .vItemSpacing) {

            ActivityDetailRecordIndicators(detailRecords: detailRecords)
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
        
        VStack(spacing: .detailPadding) {
            if !numberActivityDetailRecords.isEmpty {
                ActivityDetailRecordNumberGrid(numberActivityDetailRecords: numberActivityDetailRecords)
            }
            
            if !textActivityDetailRecords.isEmpty {
                ActivityDetailRecordTextList(textActivityDetailRecords: textActivityDetailRecords)
            }
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
                
                UnwrappedValueText(activityDetailRecord: textActivityDetailRecord)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .sectionBackground(padding: .detailPadding, color: .tertiaryBackground)
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
                .sectionBackground(padding: .detailPadding, color: .tertiaryBackground)
            }
        }
    }
    
    
    @ViewBuilder
    func hStackFit(for numberActivityDetailRecord: ActivityDetailRecord2) -> some View {
        
        HStack {
            UnwrappedValueText(activityDetailRecord: numberActivityDetailRecord)
        }
        .lineLimit(1)
    }
    
    @ViewBuilder
    func vStackFit(for numberActivityDetailRecord: ActivityDetailRecord2) -> some View {
        
        VStack(alignment: .leading) {
            UnwrappedValueText(activityDetailRecord: numberActivityDetailRecord)
        }
        .lineLimit(1)
    }
}


/// Intended to give "N/A" if a value is empty - this should work for numbers or text, but it isn't super safe because it relies on
/// the units being empty for any text, otherwise they will show.
///
/// Also this is meant to be placed in a VStack or HStack, assuming that you want the units to be shown corrrectly
struct UnwrappedValueText: View {
    
    let activityDetailRecord: ActivityDetailRecord2
    
    var body: some View {
        
        let value = activityDetailRecord.value
        
        if !value.isEmpty {
            let units = activityDetailRecord.detail.units
            
            Text("\(activityDetailRecord.value)")
            
            if let units {
                Text(units)
                    .font(.callout)
            }

        } else {
            Text("\(.notAvailable)")
        }
    }
}
    


#Preview {

    
    
    let activityDetailRecordTimeRecord = ActivityDetailRecord2(
        value: "1000",
        detail: ActivityDetail.time
    )
    
    
    let activityDetailRecordAmountRecord = ActivityDetailRecord2(
        value: "28",
        detail: ActivityDetail.amount
    )
    
    
    let activityDetailLengthRecord = ActivityDetailRecord2(
        value: "203",
        detail: ActivityDetail.length
    )
    
    
    let activityDetailTouchdownsRecord = ActivityDetailRecord2(
        value: "",
        detail: ActivityDetail.touchdowns
    )
    
    let activityDetailRecordNoteRecord = ActivityDetailRecord2(
        value: "It was tough. I understood the meaning behind Code Red today. It is the code of blood. The code of pushing through the pain. It is the code of war.",
        detail: ActivityDetail.note
    )
    
    
    let activityDetailMoodRecord = ActivityDetailRecord2(
        value: "",
        detail: ActivityDetail.mood
    )
    
    
    let creationDate = DateComponents(calendar: .current, year: 2024, month: 2, day: 10, hour: 16, minute: 30, second: 01).date!
    let completionDateMadeFromAnotherDay = DateComponents(calendar: .current, year: 2024, month: 2, day: 9, hour: 23, minute: 59, second: 59).date!
    let completionDateMadeFromSameDay = creationDate
    
    
    let activityRecordMunchingTacos = ActivityRecord(
        title: "Munching Tacos",
        creationDate: creationDate,
        completionDate: completionDateMadeFromSameDay,
        detailRecords: []
    )
    // I want an activity record for this date and a creationDate that is different than the completionDate
    
    let activityRecordChuggingDew = ActivityRecord(
        title: "Chugging Dew",
        creationDate: creationDate,
        completionDate: completionDateMadeFromAnotherDay,
        detailRecords: [
            activityDetailRecordTimeRecord,
            activityDetailRecordAmountRecord,
//            activityDetailLengthRecord,
            activityDetailRecordNoteRecord,
            activityDetailTouchdownsRecord,
            activityDetailMoodRecord
        ]
    )
    
    return VStack {
        ActivityRecordRowTitleDate(selectedDay: creationDate, activityRecord: activityRecordMunchingTacos)
            .sectionBackground(padding: .detailPadding)
        ActivityRecordRowTitleDate(selectedDay: creationDate, activityRecord: activityRecordChuggingDew)
            .sectionBackground(padding: .detailPadding)
        ActivityRecordRowDateWithInfo(activityRecord: activityRecordMunchingTacos)
            .sectionBackground(padding: .detailPadding)
        ActivityRecordRowDateWithInfo(activityRecord: activityRecordChuggingDew)
            .sectionBackground(padding: .detailPadding)
    }
}


