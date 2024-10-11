//
//  ScheduleDay.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import Foundation


public enum ScheduleDay: Int {
    
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    
    public var abbreviation: String {
        
        switch self {
        case .sunday: return "Su"
        case .monday: return "M"
        case .tuesday: return "Tu"
        case .wednesday: return "W"
        case .thursday: return "Th"
        case .friday: return "F"
        case .saturday: return "Sa"
        }
    }
    
    
    public static var allDays: Set<ScheduleDay> {
        [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    }
}
