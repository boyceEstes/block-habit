//
//  HomeNavigationFlow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI


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
    }
    
    
    // MARK: - Sheety Destinations
    enum SheetyIdentifier: Identifiable, Hashable {
        
        var id: Int { self.hashValue }
        
        case createHabit
        case createActivityRecordWithDetails(activity: Habit, selectedDay: Date)
        case habitRecordDetail(habitRecord: HabitRecord)
        case editHabit(habit: Habit)
    }
}
