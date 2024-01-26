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
        
        // TODO: We want to be able to change the completionDate of an activity later
        /*
         * But I don't want to ever change the creationDate - it should be a constant
         * I don't care about how many times its edited though.
         *
         * Anyway, right now we are checking to see if the creation day is the same as the selected day
         * but what I want to do in the future is a little more complicated
         *
         * The purpose: We want the user to only be able to edit a task's completionTime - and order
         * properly when it is changed, despite the creationDate having an entirely different date
         *
         * if the completionDate's time == 23:59:59 && the creationDate is another day
         *   -- We want to display the activity's creationDate
         * else if completionDate's time != 23:59:59 && the creationDate is another day
         *   -- We want to display the activity's completionDate (this would have been edited, 
         *   so we want to sort it to where it should sit in the day according to the user's edit)
         * else if creationDate is today {
         *   -- We want to display the completionDate - it'll be set the same as the creationDate
         *   unless edited, and even then, it can still be displayed without the day
         * }
         *
         */
        if dayOfActivityCreation == selectedDay {
            // Format by only displaying the time, HH:mm a
            let timeToFormat = habitRecord.completionDate
            return timeDateFormatter.string(from: timeToFormat).lowercased()
            
        } else {
            // Format by displaying the time that it was created, Day, MM-dd at HH:mm a
            let dateTimeToFormat = habitRecord.creationDate
            return dateTimeDateFormatter.string(from: dateTimeToFormat).lowercased()
        }
    }
    
    
    private func deleteActivity(habitRecord: DataHabitRecord) {
        modelContext.delete(habitRecord)
    }
    
//    private func deleteActivities(at offsets: IndexSet) {
//        
//        for i in offsets {
//            modelContext.delete(habitRecords[i])
//        }
//    }
}


//#Preview {
//    DayView(
//        graphHeight: 300,
//        habitRecords: [
//            DataHabitRecord(creationDate: Date(), completionDate: Date(), habit: DataHabit(name: "Any", color: "#FFFFFF", habitRecords: []))
//        ]
//    )
//}
