//
//  DayView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/24/24.
//

import SwiftUI

struct DayView: View {
    
    let destroyHabitRecord: (HabitRecord) -> Void
    let goToHabitRecordDetail: (HabitRecord) -> Void
    /// We want this to determine the itemHeight, alternatively we could just set the item height/width
    let graphHeight: CGFloat
    // We want this to keep the same itemHeight/width when presenting the squares in the list
    let numOfItemsToReachTop: Int
    
    // This should be the same as in `dateColumn(graph:numOfItemsToReachTop:info)`
    let dateLabelHeight: CGFloat = 30
    var itemWidth: CGFloat { (graphHeight - dateLabelHeight) / CGFloat(numOfItemsToReachTop) }
    var itemHeight: CGFloat { itemWidth }
    
    var habitRecords: [HabitRecord]
    let selectedDay: Date
    
    
    
    
    init(
        destroyHabitRecord: @escaping (HabitRecord) -> Void,
        goToHabitRecordDetail: @escaping (HabitRecord) -> Void,
        graphHeight: CGFloat,
        numOfItemsToReachTop: Int,
        habitRecords: [HabitRecord],
        selectedDay: Date
    ) {
        self.destroyHabitRecord = destroyHabitRecord
        self.goToHabitRecordDetail = goToHabitRecordDetail
        self.graphHeight = graphHeight
        self.numOfItemsToReachTop = numOfItemsToReachTop
        self.habitRecords = habitRecords
        self.selectedDay = selectedDay
    }
    
    
    var body: some View {
        
        List {
            ForEach(habitRecords, id: \.self) { habitRecord in
                HStack(spacing: 16) {
                    
                    ActivityBlock(
                        colorHex: habitRecord.habit.color,
                        itemWidth: itemWidth,
                        itemHeight: itemHeight
                    )
                    
//                    VStack(alignment: .leading) {
//                        Text("\(habitRecord.habit?.name ?? "Could Not Find Habit")")
//                        Text("\(DisplayDatePolicy.date(for: habitRecord.toModel(), on: selectedDay))")
//                            .font(.footnote)
//                            .foregroundStyle(Color.secondary)
//                    }
                    ActivityRecordRowTitleDate(selectedDay: selectedDay, activityRecord: habitRecord)
                        .sectionBackground(padding: .detailPadding, color: .secondaryBackground)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        destroyHabitRecord(habitRecord)
                        print("Deleting!")
                    } label: {
                        Label("Delete", systemImage: "trash")
                          .foregroundStyle(Color.blue)
                    }
                }
                .onTapGesture {
                    // FIXME: This is broken Cannot navigate to habit record detail without a DataHabitRecord right now
                    goToHabitRecordDetail(habitRecord)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.primaryBackground)

        }
        .frame(height: graphHeight)
//        .background(Color(uiColor: .systemGroupedBackground))
//        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
}


//#Preview {
//    DayView(
//        graphHeight: 300,
//        habitRecords: [
//            DataHabitRecord(creationDate: Date(), completionDate: Date(), habit: DataHabit(name: "Any", color: "#FFFFFF", habitRecords: []))
//        ]
//    )
//}
