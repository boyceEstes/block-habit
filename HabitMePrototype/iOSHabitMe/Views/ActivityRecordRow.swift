//
//  ActivityRecordRow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/9/24.
//

import SwiftUI
import HabitRepositoryFW


/// Intended for use when displaying activity records that will have some sort of Title and Date in the title
/// For example, in the DayView.
struct ActivityRecordRowTitleDate: View {
    
    // This is for knowing the date to display
    let selectedDay: Date
    let activityRecord: HabitRecord
    
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: .vRowSubtitleSpacing) {
            HStack(alignment: .center) {
                Text("\(activityRecord.habit.name)")
                    .font(.rowTitle)
                Spacer()
                Text("\(DisplayDatePolicy.date(for: activityRecord, on: selectedDay))")
                    .font(.callout)
            }
            
            let detailRecords = activityRecord.activityDetailRecords
            
            if !detailRecords.isEmpty {
                ActivityDetailRecordIndicators(detailRecords: detailRecords)
            }
        }
    }
}


/// Intended for use when displaying activity records that will only need some Date as the title
/// For example, the `HabitDetailView` would show logs with only the date
struct ActivityRecordRowDateWithInfo: View {
    
    let habitRecord: HabitRecord
    
    var body: some View {
        
        let detailRecords = habitRecord.activityDetailRecords
        let displayDate = DisplayDatePolicy.date(for: habitRecord, on: habitRecord.completionDate)
        
        VStack {
            VStack(alignment: .leading, spacing: .vRowSubtitleSpacing) {

                if !detailRecords.isEmpty {
                    
                    ActivityDetailRecordRowContentInfo(
                        detailRecords: detailRecords
                    )
                }
            }
            
            HStack {
                Text("\(displayDate)")
                Spacer()
                ActivityDetailRecordIndicators(detailRecords: detailRecords)
            }
            .foregroundColor(.secondaryFont)
            .font(.footnote)
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
    
    let detailRecords: [ActivityDetailRecord]
    
    var body: some View {
        
        HStack {
            ForEach(detailRecords, id: \.id) { detailRecord in
                
                let detail = detailRecord.activityDetail
                
                detail.valueType.asset.image()
            }
        }
    }
}


//struct ActivityRecordRowContent: View {
//    
//    let habitRecord: HabitRecord
//    let detailRecords: [ActivityDetailRecord]
//    
//    var body: some View {
//        
//        // FIXME: Ensure that there is never too many details to where this goes out of bounds - the view will be ruined - for lower numbers it should be okay though.
//        LazyVStack(alignment: .leading, spacing: .vItemSpacing) {
//            ActivityDetailRecordIndicators(detailRecords: detailRecords)
//            ActivityDetailRecordRowContentInfo(detailRecords: detailRecords)
//        }
//    }
//}


struct ActivityDetailRecordRowContentInfo: View {
    
    let detailRecords: [ActivityDetailRecord]
    
    var numberActivityDetailRecords: [ActivityDetailRecord] {
        detailRecords.valueType(.number)
    }
    
    var textActivityDetailRecords: [ActivityDetailRecord] {
        detailRecords.valueType(.text)
    }
    
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: .vItemSpacing) {
            
            if !detailRecords.isEmpty {
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
    }
}



// FIXME: How do I ensure that this will only have `activityDetail` values where valueType == .text
struct ActivityDetailRecordTextList: View {
    
    let textActivityDetailRecords: [ActivityDetailRecord]
    
    var body: some View {
        
        ForEach(textActivityDetailRecords) { textActivityDetailRecord in
            
            VStack(alignment: .leading) {
                Text("\(textActivityDetailRecord.activityDetail.name)")
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
    
    let numberActivityDetailRecords: [ActivityDetailRecord]
    
    let columnCount: Int
    
    var columns: [GridItem] {
        Array(repeatElement(GridItem(.flexible(), alignment: .top), count: columnCount))
    }
    
    init(numberActivityDetailRecords: [ActivityDetailRecord]) {
        
        self.numberActivityDetailRecords = numberActivityDetailRecords
        
        let columnLimit = 2
//        let recordCount = numberActivityDetailRecords.count
        // I like the simple 2 column grid more than having the whole row 
        // filled with little content
        self.columnCount = columnLimit //recordCount >= columnLimit ? columnLimit : recordCount
    }
    
    
    var body: some View {
        
        LazyVGrid(columns: columns) {
            
            ForEach(numberActivityDetailRecords) { numberActivityDetailRecord in
                
                VStack(alignment: .leading) {
                    Text("\(numberActivityDetailRecord.activityDetail.name)")
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
    func hStackFit(for numberActivityDetailRecord: ActivityDetailRecord) -> some View {
        
        HStack {
            UnwrappedValueText(activityDetailRecord: numberActivityDetailRecord)
        }
        .lineLimit(1)
    }
    
    @ViewBuilder
    func vStackFit(for numberActivityDetailRecord: ActivityDetailRecord) -> some View {
        
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
    
    let activityDetailRecord: ActivityDetailRecord
    
    var body: some View {
        
        let value = activityDetailRecord.value
        
        if !value.isEmpty {
            let units = activityDetailRecord.activityDetail.availableUnits
            
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
    
    let creationDate = DateComponents(calendar: .current, year: 2024, month: 2, day: 10, hour: 16, minute: 30, second: 01).date!
    
    return VStack {
        ActivityRecordRowTitleDate(selectedDay: creationDate, activityRecord: HabitRecord.preview)
            .sectionBackground(padding: .detailPadding)
        ActivityRecordRowTitleDate(selectedDay: creationDate, activityRecord: HabitRecord.preview)
            .sectionBackground(padding: .detailPadding)
        ActivityRecordRowDateWithInfo(habitRecord: HabitRecord.preview)
            .sectionBackground(padding: .detailPadding)
        ActivityRecordRowDateWithInfo(habitRecord: HabitRecord.preview)
            .sectionBackground(padding: .detailPadding)
    }
}


