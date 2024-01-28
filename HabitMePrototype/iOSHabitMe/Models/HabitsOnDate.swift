//
//  HabitsOnDate.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import Foundation



struct DataHabitRecordsOnDate: Hashable {
    
    let funDate: Date
    var habits: [DataHabitRecord]
}

extension Date {
    
    var displayDate: String {
        let formatter: DateFormatter = .shortDate
        
        let today = Date().noon!
        let yesterday = Date().noon!.adding(days: -1)
        let twoDaysAgo = Date().noon!.adding(days: -2)
        switch self {
        case today:
            return "Today"
        case yesterday:
            return "Yesterday"
        case twoDaysAgo:
            return "-2 days"
        default:
            return formatter.string(from: self)
        }
    }
}
