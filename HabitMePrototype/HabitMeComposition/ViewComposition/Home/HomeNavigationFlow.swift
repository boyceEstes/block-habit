//
//  HomeNavigationFlow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI
import HabitRepositoryFW


// We can display many sheets on this one flow, as long as they are somewhere in this stack hierarchy -
// if we want to display a sheet on a sheet or need a sheet to have its own stack hierarchy we will need another
// "NavigationFlow" object for that object
class HomeNavigationFlow: NewStackNavigationFlow, NewSheetyNavigationFlow {
    
    // MARK: - Properties
    @Published var path = [StackIdentifier]()
    @Published var displayedSheet: SheetyIdentifier?
    
    
    // MARK: - Stack Destinations
    enum StackIdentifier: Hashable {

        case habitDetail(habit: Habit)
        case statistics
        case settings
        // settings paths
        case notifications
        case archivedHabits
        case archivedActivityDetails
        case buyMeACoffee
    }
    
    
    // MARK: - Sheety Destinations
    enum SheetyIdentifier: Identifiable, Hashable {
        
        var id: Int { self.hashValue }
        
        case createHabit
        case createActivityRecordWithDetails(activity: Habit, selectedDay: Date, dismissAction: () -> Void)
        case habitRecordDetail(habitRecord: HabitRecord)
        case editHabit(habit: Habit)
        
        
        static func ==(lhs: SheetyIdentifier, rhs: SheetyIdentifier) -> Bool {
            
            switch (lhs, rhs) {
            case (.createHabit, .createHabit): return true
            case (.editHabit(let lhsHabit), .editHabit(let rhsHabit)):
                return lhsHabit == rhsHabit
            case (.habitRecordDetail(let lhsHabitRecord), .habitRecordDetail(let rhsHabitRecord)):
                return lhsHabitRecord == rhsHabitRecord
            case let (.createActivityRecordWithDetails(lhsHabit, lhsSelectedDay, _), .createActivityRecordWithDetails(rhsHabit, rhsSelectedDay, _ )):
                  // The dismissAction will not apply to equating the two sheetyIdentifiers, we will keep it simpler - should be fine
                return lhsHabit == rhsHabit && lhsSelectedDay == rhsSelectedDay
            
            default: return false
            }
        }
        
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .createHabit: hasher.combine(self)
            case let .editHabit(habit): hasher.combine(habit)
            case let .habitRecordDetail(habitRecord): hasher.combine(habitRecord)
            case let .createActivityRecordWithDetails(habit, selectedDay, dismissAction: _):
                hasher.combine(habit)
                hasher.combine(selectedDay)
            }
        }
    }
}
