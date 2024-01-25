//
//  DayView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/24/24.
//

import SwiftUI

struct DayView: View {
    
    let graphHeight: CGFloat
    // We want this to keep the same itemHeight/width when presenting the squares in the list
    let numOfItemsToReachTop: Int
    
    // This should be the same as in `dateColumn(graph:numOfItemsToReachTop:info)`
    let dateLabelHeight: CGFloat = 30
    var itemWidth: CGFloat { (graphHeight - dateLabelHeight) / CGFloat(numOfItemsToReachTop) }
    var itemHeight: CGFloat { itemWidth }
    
    var habitRecords: [DataHabitRecord]
    let selectedDay: Date
    
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
                }
            }
        }
        .frame(height: graphHeight)
    }
    
    
    // MARK: Helper methods
    private func displayDate(for habitRecord: DataHabitRecord) -> String {
        
        let timeDateFormatter: DateFormatter = .shortTime
        let dateTimeDateFormatter: DateFormatter = .shortDateShortTime
        
        guard let dayOfActivityCreation = habitRecord.creationDate.noon else {
            return "Unknown"
        }
        
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
}


//#Preview {
//    DayView(
//        graphHeight: 300,
//        habitRecords: [
//            DataHabitRecord(creationDate: Date(), completionDate: Date(), habit: DataHabit(name: "Any", color: "#FFFFFF", habitRecords: []))
//        ]
//    )
//}
