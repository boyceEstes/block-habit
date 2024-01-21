//
//  Habit.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import SwiftUI


struct Habit: Hashable {

    let name: String
    let color: Color
    
    static let meditation = Habit(name: "Meditation", color: .orange)
    static let journal = Habit(name: "Journal", color: .blue)
    static let reading = Habit(name: "Reading", color: .cyan)
    static let walkTheCat = Habit(name: "Walk the Cat", color: .green)
    
    static let habits = [
        meditation,
        journal,
        reading,
        walkTheCat
    ]
}
