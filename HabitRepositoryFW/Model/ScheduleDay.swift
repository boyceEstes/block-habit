//
//  ScheduleDay.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import Foundation


public enum ScheduleDay: Int, Identifiable, CaseIterable {
    
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    public var id: Int {
        self.rawValue
    }
    
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
    
    
    public var fullName: String {
        
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    
    public var dateComponentID: Int {
        
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    public static var allDays: Set<ScheduleDay> {
        [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    }
}
