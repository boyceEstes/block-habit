//
//  DayView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/24/24.
//

import SwiftUI

struct DayView: View {
    
    @Environment(\.modelContext) var modelContext
    
    let goToHabitRecordDetail: (DataHabitRecord) -> Void
    /// We want this to determine the itemHeight, alternatively we could just set the item height/width
    let graphHeight: CGFloat
    // We want this to keep the same itemHeight/width when presenting the squares in the list
    let numOfItemsToReachTop: Int
    
    // This should be the same as in `dateColumn(graph:numOfItemsToReachTop:info)`
    let dateLabelHeight: CGFloat = 30
    var itemWidth: CGFloat { (graphHeight - dateLabelHeight) / CGFloat(numOfItemsToReachTop) }
    var itemHeight: CGFloat { itemWidth }
    
    var habitRecords: [DataHabitRecord]
    let selectedDay: Date
    
    
    
    
    init(
        goToHabitRecordDetail: @escaping (DataHabitRecord) -> Void,
        graphHeight: CGFloat,
        numOfItemsToReachTop: Int,
        habitRecords: [DataHabitRecord],
        selectedDay: Date
    ) {
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
                    
                    VStack(alignment: .leading) {
                        Text("\(habitRecord.habit.name)")
                        Text("\(displayDate(for: habitRecord))")
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        deleteActivity(habitRecord: habitRecord)
                    } label: {
                        Label("Delete", systemImage: "trash")
                          .foregroundStyle(Color.blue)
                    }
                    .tint(Color(uiColor: .secondarySystemGroupedBackground))
                }
                .onTapGesture {
                    goToHabitRecordDetail(habitRecord)
                }
            }
//            .onDelete(perform: deleteActivities)
            .listRowSeparator(.hidden)
            .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))

        }
        .frame(height: graphHeight)
//        .background(Color(uiColor: .systemGroupedBackground))
//        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
    
    
    // MARK: Helper methods
    private func displayDate(for habitRecord: DataHabitRecord) -> String {
        
        let timeDateFormatter: DateFormatter = .shortTime
        let dateTimeDateFormatter: DateFormatter = .shortDateShortTime
        
        guard let dayOfActivityCreation = habitRecord.creationDate.noon else {
            return "Unknown"
        }
        
        /*
        * The purpose: We want the user to only be able to edit a task's completionTime - and order
        * properly when it is changed, despite the creationDate having an entirely different date -
        * only display the creation date when it is unedited and created on another date
        */

        let completionTime = Calendar.current.dateComponents([.hour, .minute, .second], from: habitRecord.completionDate)
        
        var isCompletionTimeLastSecond: Bool {
            completionTime.hour == 23 && completionTime.minute == 59 && completionTime.second == 59
        }
        
        
        if isCompletionTimeLastSecond && dayOfActivityCreation != selectedDay {
            let dateTimeToFormat = habitRecord.creationDate
            return dateTimeDateFormatter.string(from: dateTimeToFormat).lowercased()
            
        } else {
            let timeToFormat = habitRecord.completionDate
            return timeDateFormatter.string(from: timeToFormat).lowercased()
        }
    }
    
    
    private func deleteActivity(habitRecord: DataHabitRecord) {
        modelContext.delete(habitRecord)
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