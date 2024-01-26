//
//  HomeNavigationFlow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI


class HomeNavigationFlow: NewStackNavigationFlow, NewSheetyNavigationFlow {
    
    // MARK: - Properties
    @Published var path = [StackIdentifier]()
    @Published var displayedSheet: SheetyIdentifier?
    
    
    // MARK: - Stack Destinations
    enum StackIdentifier: Hashable {

        case habitDetail(habit: DataHabit)
    }
    
    
    // MARK: - Sheety Destinations
    enum SheetyIdentifier: Identifiable, Hashable {
        
        var id: Int { self.hashValue }
        
        case createHabit
        case habitRecordDetail(habitRecord: DataHabitRecord)
    }
}
