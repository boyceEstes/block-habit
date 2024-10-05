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
    
    static var walkTheCat = Habit(
        id: UUID().uuidString,
        name: "Walk The Cat",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: "#a89cf0",
        activityDetails: [])
    
    static var drinkTheKoolaid = Habit(
        id: UUID().uuidString,
        name: "Drink the Koolaid",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 2,
        color: "#ff0000",
        activityDetails: [])
    
    static var mopTheCarpet = Habit(
        id: UUID().uuidString,
        name: "Mop the carpet",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: "#0000ff",
        activityDetails: [])
    
    static var soulSearch =  Habit(
        id: UUID().uuidString,
        name: "Soul Search",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: "#a6c3e3",
        activityDetails: [])
    
    static var mirrorPepTalk = Habit(
        id: UUID().uuidString,
        name: "Soul Search",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: "#556b2f",
        activityDetails: [])
    
    static var previewHabits = [walkTheCat, drinkTheKoolaid, mopTheCarpet, soulSearch]
}


// MARK: IsCompleteHabit
extension IsCompletedHabit {
    
    static var previewIncompletedHabits: [IsCompletedHabit] {
        
        [
            Habit.walkTheCat,
            Habit.drinkTheKoolaid,
            Habit.mopTheCarpet
        ].map {
            IsCompletedHabit(habit: $0, isCompleted: false)
        }
    }
    
    static var previewCompletedHabits: [IsCompletedHabit] {
        [
            Habit.soulSearch,
            Habit.mirrorPepTalk
        ].map {
            IsCompletedHabit(habit: $0, isCompleted: true)
        }
    }
}


#endif
