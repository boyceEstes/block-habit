//
//  Habit+PreviewData.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/5/24.
//



#if DEBUG


import HabitRepositoryFW

// MARK: Habit
extension Habit {
    
    static var walkTheCat = Habit(id: UUID().uuidString, name: "Walk The Cat", isArchived: false, goalCompletionsPerDay: 1, color: "#a89cf0", activityDetails: [])
    static var drinkTheKoolaid = Habit(id: UUID().uuidString, name: "Drink the Koolaid", isArchived: false, goalCompletionsPerDay: 2, color: "#ff0000", activityDetails: [])
    static var mopTheCarpet = Habit(id: UUID().uuidString, name: "Mop the carpet", isArchived: false, goalCompletionsPerDay: 1, color: "#0000ff", activityDetails: [])
    static var soulSearch =  Habit(id: UUID().uuidString, name: "Soul Search", isArchived: false, goalCompletionsPerDay: 1, color: "#a6c3e3", activityDetails: [])
    
    
    static var previewHabits = [walkTheCat, drinkTheKoolaid, mopTheCarpet, soulSearch]
}


// MARK: IsCompleteHabit
extension IsCompletedHabit {
    
    static var previewIncompletedHabits: [IsCompletedHabit] {
        
        Habit.previewHabits.map {
            IsCompletedHabit(habit: $0, isCompleted: false)
        }
    }
}


#endif
