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
        activityDetails: [],
        schedulingUnits: .weekly,
        rate: 1,
        scheduledWeekDays: ScheduleDay.allDays,
        reminderTime: Date()
    )
    
    static var drinkTheKoolaid = Habit(
        id: UUID().uuidString,
        name: "Drink the Koolaid",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 2,
        color: "#ff0000",
        activityDetails: [],
        schedulingUnits: .weekly,
        rate: 1,
        scheduledWeekDays: ScheduleDay.allDays,
        reminderTime: Date()
    )
    
    static var mopTheCarpet = Habit(
        id: UUID().uuidString,
        name: "Mop the carpet",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: "#0000ff",
        activityDetails: [],
        schedulingUnits: .weekly,
        rate: 1,
        scheduledWeekDays: ScheduleDay.allDays,
        reminderTime: Date()
    )
    
    static var seoulSearch =  Habit(
        id: UUID().uuidString,
        name: "Seoul Search",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: "#a6c3e3",
        activityDetails: [],
        schedulingUnits: .weekly,
        rate: 1,
        scheduledWeekDays: ScheduleDay.allDays,
        reminderTime: Date()
    )
    
    static var mirrorPepTalk = Habit(
        id: UUID().uuidString,
        name: "Mirror Pep Talk",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: "#556b2f",
        activityDetails: [.mood],
        schedulingUnits: .weekly,
        rate: 1,
        scheduledWeekDays: ScheduleDay.allDays,
        reminderTime: Date()
    )
    
    static var somethingComplicated = Habit(
        id: UUID().uuidString,
        name: "Stretching into a triple backflip IMMEDIATELY after waking up",
        creationDate: Date(),
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: "#fdcfe5",
        activityDetails: [],
        schedulingUnits: .weekly,
        rate: 1,
        scheduledWeekDays: ScheduleDay.allDays,
        reminderTime: Date()
    )
    
    static var previewHabits = [walkTheCat, drinkTheKoolaid, mopTheCarpet, seoulSearch]
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
            Habit.seoulSearch,
            Habit.mirrorPepTalk
        ].map {
            IsCompletedHabit(habit: $0, isCompleted: true)
        }
    }
}


// MARK: HabitRecords

extension HabitRecord {
    
    static var previewRecords: [HabitRecord] = [
        HabitRecord(
            id: UUID().uuidString,
            creationDate: Date(),
            completionDate: Date(),
            activityDetailRecords: [],
            habit: .drinkTheKoolaid
        ),
        HabitRecord(
            id: UUID().uuidString,
            creationDate: Date(),
            completionDate: Date(),
            activityDetailRecords: [],
            habit: .seoulSearch
        ),
        HabitRecord(
            id: UUID().uuidString,
            creationDate: Date(),
            completionDate: Date(),
            activityDetailRecords: [],
            habit: .mopTheCarpet
        ),
        HabitRecord(
            id: UUID().uuidString,
            creationDate: Date(),
            completionDate: Date(),
            activityDetailRecords: [],
            habit: .mirrorPepTalk
        )
    ]
}



// MARK: [Date: [HabitRecord]]

extension HabitRecord {
    
    static func recordsForDaysPreview(date: Date) -> [Date: [HabitRecord]] {
        
        let today = date
        let oneDayAgo = date.adding(days: -1)
        let twoDaysAgo = date.adding(days: -2)
        let threeDaysAgo = date.adding(days: -3)
        let fourDaysAgo = date.adding(days: -4)
        let fiveDaysAgo = date.adding(days: -5)
        let sixDaysAgo = date.adding(days: -6)
        let sevenDaysAgo = date.adding(days: -7)
        let eightDaysAgo = date.adding(days: -8)
        
        let recordwalkTheCatToday = HabitRecord(
            id: UUID().uuidString,
            creationDate: today,
            completionDate: today,
            activityDetailRecords: [],
            habit: .walkTheCat
        )
        let recordwalkTheCatOneDayAgo = HabitRecord(
            id: UUID().uuidString,
            creationDate: oneDayAgo,
            completionDate: oneDayAgo,
            activityDetailRecords: [],
            habit: .walkTheCat
        )
        let recordwalkTheCatThreeDaysAgo = HabitRecord(
            id: UUID().uuidString,
            creationDate: threeDaysAgo,
            completionDate: threeDaysAgo,
            activityDetailRecords: [],
            habit: .walkTheCat
        )
        
        let recordMirrorPepTalkToday = HabitRecord(
            id: UUID().uuidString,
            creationDate: today,
            completionDate: today,
            activityDetailRecords: [],
            habit: .mirrorPepTalk
        )
        let recordMirrorPepTalkTwoDaysAgo = HabitRecord(
            id: UUID().uuidString,
            creationDate: twoDaysAgo,
            completionDate: twoDaysAgo,
            activityDetailRecords: [],
            habit: .mirrorPepTalk
        )
        
        return [
            date: [recordwalkTheCatToday, recordMirrorPepTalkToday],
            oneDayAgo: [recordwalkTheCatOneDayAgo],
            twoDaysAgo: [recordMirrorPepTalkTwoDaysAgo],
            threeDaysAgo: [recordwalkTheCatThreeDaysAgo],
            fourDaysAgo: [],
            fiveDaysAgo: [],
            sixDaysAgo: [],
            sevenDaysAgo: [],
            eightDaysAgo: []
        ]
    }
}

#endif
