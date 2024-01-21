//
//  HabitsOnDate.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import Foundation


struct HabitsOnDate: Hashable {
    
    let funDate: Date
    var habits: [HabitRecord]
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        let today = Date().noon!
        let yesterday = Date().noon!.adding(days: -1)
        let twoDaysAgo = Date().noon!.adding(days: -2)
        let threeDaysAgo = Date().noon!.adding(days: -3)
        let fourDaysAgo = Date().noon!.adding(days: -4)
        switch funDate {
        case today:
            return "Today"
        case yesterday:
            return "Yesterday"
        case twoDaysAgo:
            return "-2 days"
        case threeDaysAgo:
            return "-3 days"
        case fourDaysAgo:
            return "-4 days"
        default:
            return formatter.string(from: funDate)
        }
    }
}
