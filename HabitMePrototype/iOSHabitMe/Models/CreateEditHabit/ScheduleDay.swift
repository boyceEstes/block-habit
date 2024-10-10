//
//  ScheduleDay.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import Foundation


enum ScheduleDay: Int {
    
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var abbreviation: String {
        
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
    
    static var allDays: Set<ScheduleDay> {
        [.sunday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    }
}
