//
//  Array+IsCompletedHabitsTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 5/3/24.
//

import Foundation
import HabitRepositoryFW
import XCTest


extension Array where Element == Habit {
    
    func toIsCompleteHabits(recordsForSelectedDay: [HabitRecord]) -> [IsCompletedHabit] {
        
        var isCompletedHabits = [IsCompletedHabit]()
        
        for habit in self {
            
            guard !habit.isArchived else {
                continue // Do not add this to the list. It should Ideally not even be returned and never hit, but just in case
            }
            
            guard let completionGoal = habit.goalCompletionsPerDay,
                    completionGoal != 0 else {
                isCompletedHabits.append(IsCompletedHabit(habit: habit, isCompleted: false))
                continue
            }
            
            let numOfRecordsForHabit = recordsForSelectedDay.filter { $0.habit.id == habit.id }.count
            
            isCompletedHabits.append(IsCompletedHabit(habit: habit, isCompleted: numOfRecordsForHabit >= completionGoal))
        }
        return isCompletedHabits
    }
}


class Array_IsCompletedHabitsTests: XCTestCase {
    
    func test_emptyArray_deliversEmptyIsCompletedHabits() {
        
        // given
        let habits: [Habit] = []
        let habitRecordsForDay: [HabitRecord] = []
        
        // when
        let isCompletedHabits = habits.toIsCompleteHabits(recordsForSelectedDay: habitRecordsForDay)
        
        // then
        XCTAssertEqual(isCompletedHabits, [])
    }
    
    
    func test_oneHabitWithNoRecords_deliversOneIncompleteHabit() {
        
        // given
        let habit = Habit.nonArchivedOneGoal
        let habits: [Habit] = [habit]
        let habitRecordsForDay: [HabitRecord] = []
        
        let expectedIsCompletedHabits = [IsCompletedHabit(habit: habit, isCompleted: false)]
        
        // when
        let isCompletedHabits = habits.toIsCompleteHabits(recordsForSelectedDay: habitRecordsForDay)
        
        // then
        XCTAssertEqual(isCompletedHabits, expectedIsCompletedHabits)
    }
    
    
    func test_oneHabitWithGoalRecords_deliversOneCompleteHabit() {
        
        // given
        let habit = Habit.nonArchivedOneGoal
        let habits: [Habit] = [habit]
        // We are trusting that we have gotten the date right from the habitRecordsForDays calculations
        let habitRecord = HabitRecord.habitRecord(date: Date(), habit: habit)
        let habitRecordsForDay: [HabitRecord] = [habitRecord]
        
        let expectedIsCompletedHabits = [IsCompletedHabit(habit: habit, isCompleted: true)]
        
        // when
        let isCompletedHabits = habits.toIsCompleteHabits(recordsForSelectedDay: habitRecordsForDay)
        
        // then
        XCTAssertEqual(isCompletedHabits, expectedIsCompletedHabits)
    }
    
    
    func test_oneHabitWithMoreRecordsThanGoal_deliversOneCompleteHabit() {
        
        // given
        let habit = Habit.nonArchivedOneGoal
        let habits: [Habit] = [habit]
        // We are trusting that we have gotten the date right from the habitRecordsForDays calculations
        let habitRecord = HabitRecord.habitRecord(habit: habit)
        let habitRecord2 = HabitRecord.habitRecord(habit: habit)
        let habitRecordsForDay: [HabitRecord] = [habitRecord, habitRecord2]
        
        let expectedIsCompletedHabits = [IsCompletedHabit(habit: habit, isCompleted: true)]
        
        // when
        let isCompletedHabits = habits.toIsCompleteHabits(recordsForSelectedDay: habitRecordsForDay)
        
        // then
        XCTAssertEqual(isCompletedHabits, expectedIsCompletedHabits)
    }
    
    
    func test_oneHabitWithZeroGoalAndRecords_deliversOneIncompleteHabit() {
        
        // given
        let habit = Habit.nonArchivedZeroGoal
        let habits: [Habit] = [habit]
        // We are trusting that we have gotten the date right from the habitRecordsForDays calculations
        let habitRecord = HabitRecord.habitRecord(habit: habit)
        let habitRecordsForDay: [HabitRecord] = [habitRecord]
        
        let expectedIsCompletedHabits = [IsCompletedHabit(habit: habit, isCompleted: false)]
        
        // when
        let isCompletedHabits = habits.toIsCompleteHabits(recordsForSelectedDay: habitRecordsForDay)
        
        // then
        XCTAssertEqual(isCompletedHabits, expectedIsCompletedHabits)
    }
    
    
    func test_oneArchivedHabitWithGoalRecords_deliversNothing() {
        
        // given
        let habit = Habit.archivedOneGoal
        let habits: [Habit] = [habit]
        // We are trusting that we have gotten the date right from the habitRecordsForDays calculations
        let habitRecord = HabitRecord.habitRecord(habit: habit)
        let habitRecordsForDay: [HabitRecord] = [habitRecord]
        
        let expectedIsCompletedHabits = [IsCompletedHabit]()
        
        // when
        let isCompletedHabits = habits.toIsCompleteHabits(recordsForSelectedDay: habitRecordsForDay)
        
        // then
        XCTAssertEqual(isCompletedHabits, expectedIsCompletedHabits)
    }
}
