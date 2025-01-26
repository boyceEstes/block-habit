//
//  Date+GraphDisplayDate.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation


extension Date {
    
    var displayDate: String {
        let formatter: DateFormatter = .monthDayDate
        
        let today = Date().noon!
        let yesterday = Date().noon!.adding(days: -1)
        switch self {
        case today:
            return "Today"
        case yesterday:
            return "Yesterday"
        default:
            return formatter.string(from: self)
        }
    }
}
