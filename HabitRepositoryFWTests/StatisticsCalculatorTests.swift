//
//  StatisticsCalculatorTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 5/8/24.
//

import XCTest
import HabitRepositoryFW


typealias RecordsForDays = [Date: [HabitRecord]]

enum StatisticsCalculator {
    
    // O(N)
    static func findTotalRecords(for recordsForDays: RecordsForDays) -> Int {
        
        var numOfRecords = 0
        
        for (_, records) in recordsForDays {
            
            numOfRecords += records.count
        }
        
        return numOfRecords
    }
    
    
    static func findTotalDays(for recordsForDays: RecordsForDays) -> Int {
        
        return recordsForDays.count
    }
}


class StatisticsCalculatorTests: XCTestCase {
    
    
    // MARK: findTotalRecords
    func test_findTotalRecords_withNoRecords_deliversZero() {
        
        // given/when
        let totalRecords = StatisticsCalculator.findTotalRecords(for: [:])
        // then
        XCTAssertEqual(totalRecords, 0)
    }
    
    
    func test_findTotalRecord_multipleRecordsMultipleHabitsOverDifferentDates_deliversNumberOfRecords() {
        
        let habitRecordsForDays = setupRecordsForDays()
        let expectedNumberOfRecords = 10
        
        // when
        let totalRecords = StatisticsCalculator.findTotalRecords(for: habitRecordsForDays)
        
        // then
        XCTAssertEqual(totalRecords, expectedNumberOfRecords)
    }
    
    
    // MARK: findTotalDays
    
    // MARK: findTotalRecords
    func test_findTotalDays_withNoDays_deliversZero() {
        
        // given/when
        let totalDays = StatisticsCalculator.findTotalDays(for: [:])
        // then
        XCTAssertEqual(totalDays, 0)
    }
    
    
    func test_findTotalDays_multipleRecordsMultipleHabitsOverDifferentDates_deliversNumberOfDays() {
        
        // given
        let habitRecordsForDays = setupRecordsForDays()
        let expectedNumberOfDays = 7
        
        // when
        let totalDays = StatisticsCalculator.findTotalDays(for: habitRecordsForDays)
        
        // then
        XCTAssertEqual(totalDays, expectedNumberOfDays)
    }
    
    
    private func setupRecordsForDays() -> RecordsForDays {
        
        // given
        let nonArchivedZeroGoalHabit = Habit.nonArchivedZeroGoal
        let nonArchivedOneGoalHabit = Habit.nonArchivedOneGoal
        let nonArchivedTwoGoalHabit = Habit.nonArchivedTwoGoal
        
        // Setting this many just because it is our minimum number of dates in the dictionary
        let someDayNoon = someDay.noon!
        let oneDayPrevious = someDayNoon.adding(days: -1)
        let twoDayPrevious = someDayNoon.adding(days: -2)
        let threeDayPrevious = someDayNoon.adding(days: -3)
        let fourDayPrevious = someDayNoon.adding(days: -4)
        let fiveDayPrevious = someDayNoon.adding(days: -5)
        let sixDayPrevious = someDayNoon.adding(days: -6)
        
        
        let hR = HabitRecord.habitRecord(date: someDayNoon, habit: nonArchivedZeroGoalHabit)
        let hR2 = HabitRecord.habitRecord(date: someDayNoon, habit: nonArchivedZeroGoalHabit)
        let hR3 = HabitRecord.habitRecord(date: someDayNoon, habit: nonArchivedZeroGoalHabit)
        let hR4 = HabitRecord.habitRecord(date: someDayNoon, habit: nonArchivedZeroGoalHabit)
        
        let hr6 = HabitRecord.habitRecord(date: oneDayPrevious, habit: nonArchivedOneGoalHabit)
        
        let hr7 = HabitRecord.habitRecord(date: twoDayPrevious, habit: nonArchivedOneGoalHabit)
        
        let hR5 = HabitRecord.habitRecord(date: threeDayPrevious, habit: nonArchivedZeroGoalHabit)
        let hr8 = HabitRecord.habitRecord(date: threeDayPrevious, habit: nonArchivedOneGoalHabit)
        
        let hr9 = HabitRecord.habitRecord(date: fiveDayPrevious, habit: nonArchivedTwoGoalHabit)
        let hr10 = HabitRecord.habitRecord(date: fiveDayPrevious, habit: nonArchivedTwoGoalHabit)
        
        let habitRecordsForDays = [
            someDayNoon: [hR, hR2, hR3, hR4],
            oneDayPrevious: [hr6],
            twoDayPrevious: [hr7],
            threeDayPrevious: [hR5, hr8],
            fourDayPrevious: [],
            fiveDayPrevious: [hr9, hr10],
            sixDayPrevious: []
        ]
        
        return habitRecordsForDays
    }
        
    
    
    var someDay: Date { Date(timeIntervalSince1970: 1714674435) }
}
