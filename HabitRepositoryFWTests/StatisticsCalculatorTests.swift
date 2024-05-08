//
//  StatisticsCalculatorTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 5/8/24.
//

import XCTest
import HabitRepositoryFW


typealias RecordsForDays = [Date: [HabitRecord]]
typealias HabitWithCount = (habit: Habit, count: Int)

enum StatisticsCalculator {
    
    // O(N)
    static func findTotalRecords(for recordsForDays: RecordsForDays) -> Int {
        
        var numOfRecords = 0
        
        for (_, records) in recordsForDays {
            
            numOfRecords += records.count
        }
        
        return numOfRecords
    }
    
    
    // O(1) (?)
    static func findTotalDays(for recordsForDays: RecordsForDays) -> Int {
        
        return recordsForDays.count
    }
    
    
    // Should I have only the given habits in the dictionary? I think so.
    // I would want to call this after I filter the recordsForDays by whatever habits are left, but regardless, I would want to only see these habits
    // Either way, I would need to count up for each habit
    // O(H*D*R) - habits * days
    static func findHabitWithMostCompletions(for recordsForDays: RecordsForDays, with habits: [Habit]) -> HabitWithCount? {
        
        var mostHabit: Habit?
        var mostHabitCount: Int = 0
        
        // 1. Loop through each habit,
        for habit in habits {
            
            // 2. see how many records each has
            var filteredRecordsForDays = RecordsForDays()
            for (day, records) in recordsForDays {
                
                for record in records {
                    
                    if record.habit == habit {
                        
                        if filteredRecordsForDays[day] == nil {
                            filteredRecordsForDays[day] = [record]
                        } else {
                            filteredRecordsForDays[day]?.append(record)
                        }
                    }
                }
            }
            
            let filteredRecordsCount = findTotalRecords(for: filteredRecordsForDays)
            
            // 3. if recordCount > maxRecordCount set as new one
            if filteredRecordsCount > mostHabitCount {
                mostHabit = habit
                mostHabitCount = filteredRecordsCount
            }
        }
        
        // 4. return the habitCount pair
        return mostHabit == nil ? nil : (mostHabit!, mostHabitCount)
    }
    
    
//    static func findHabitWithBestStreak() {}
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
        let expectedNumberOfRecords = 11
        
        // when
        let totalRecords = StatisticsCalculator.findTotalRecords(for: habitRecordsForDays)
        
        // then
        XCTAssertEqual(totalRecords, expectedNumberOfRecords)
    }
    
    
    // MARK: findTotalDays
    func test_findTotalDays_withNoDays_deliversZero() {
        
        // given/when
        let totalDays = StatisticsCalculator.findTotalDays(for: [:])
        // then
        XCTAssertEqual(totalDays, 0)
    }
    
    
    func test_findTotalDays_withMultipleEmptyDays_deliversNumberOfDays() {
        
        // given
        let daysWithEmptyRecords = setupDaysForDictionary()
        let expectedNumberOfDays = 7
        
        // when
        let totalDays = StatisticsCalculator.findTotalDays(for: daysWithEmptyRecords)
        
        // then
        XCTAssertEqual(totalDays, expectedNumberOfDays)
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
    
    
    // MARK: findHabitWithMostCompletions
    func test_findHabitWithMostCompletions_withNoDaysSomeHabits_deliversNil() {
        
        // given/when
        let mostCompletions = StatisticsCalculator.findHabitWithMostCompletions(for: [:], with: availableHabits())
        
        // then
        XCTAssertNil(mostCompletions)
    }
    
    
    func test_findHabitWithMostCompletions_withMultipleEmptyDays_deliversNil() {
        
        // given
        let multipleEmptyDaysRecordsForDays = setupDaysForDictionary()
        
        // when
        let mostCompletions = StatisticsCalculator.findHabitWithMostCompletions(for: multipleEmptyDaysRecordsForDays, with: availableHabits())
        
        // then
        XCTAssertNil(mostCompletions)
    }
    
    
    func test_findHabitWithMostCompletions_multipleRecordsMultipleHabitsOverDifferentDates_deliversMostCompletedHabitAndCount() {
        
        // given
        let availableHabits = availableHabits()
        let multipleEmptyDaysRecordsForDays = setupRecordsForDays()
        let expectedHabit = nonArchivedZeroGoalHabit
        let expectedCount = 5
        
        // when
        guard let (mostCompletionsHabit, mostCompletionsCount) = StatisticsCalculator.findHabitWithMostCompletions(for: multipleEmptyDaysRecordsForDays, with: availableHabits) else {
            XCTFail("Found no records")
            return
        }
        
        // then
        XCTAssertEqual(mostCompletionsHabit, expectedHabit)
        XCTAssertEqual(mostCompletionsCount, expectedCount)
    }
    
    
    // MARK: Helpers
    private func setupRecordsForDays() -> RecordsForDays {
        
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
        let hr11 = HabitRecord.habitRecord(date: someDayNoon, habit: nonArchivedTwoGoalHabit)
        
        let hr6 = HabitRecord.habitRecord(date: oneDayPrevious, habit: nonArchivedOneGoalHabit)
        
        let hr7 = HabitRecord.habitRecord(date: twoDayPrevious, habit: nonArchivedOneGoalHabit)
        
        let hR5 = HabitRecord.habitRecord(date: threeDayPrevious, habit: nonArchivedZeroGoalHabit)
        let hr8 = HabitRecord.habitRecord(date: threeDayPrevious, habit: nonArchivedOneGoalHabit)
        
        let hr9 = HabitRecord.habitRecord(date: fiveDayPrevious, habit: nonArchivedTwoGoalHabit)
        let hr10 = HabitRecord.habitRecord(date: fiveDayPrevious, habit: nonArchivedTwoGoalHabit)
        
        
        let habitRecordsForDays = [
            someDayNoon: [hR, hR2, hR3, hR4, hr11],
            oneDayPrevious: [hr6],
            twoDayPrevious: [hr7],
            threeDayPrevious: [hR5, hr8],
            fourDayPrevious: [],
            fiveDayPrevious: [hr9, hr10],
            sixDayPrevious: []
        ]
        
        return habitRecordsForDays
    }
    
    
    private func setupDaysForDictionary() -> RecordsForDays {
        
        let numberOfDays = 7
        
        var recordsForDays = RecordsForDays()
        let startDate = someDay.noon!
        
        for i in 0..<numberOfDays {
            
            let day = startDate.adding(days: -i).noon!
            recordsForDays[day] = []
        }
        
        return recordsForDays
    }
    
    
    private func availableHabits() -> [Habit] {
        
        [nonArchivedZeroGoalHabit, nonArchivedOneGoalHabit, nonArchivedTwoGoalHabit]
    }
    
        
    var someDay: Date { Date(timeIntervalSince1970: 1714674435) }
    
    // given
    let nonArchivedZeroGoalHabit = Habit.nonArchivedZeroGoal(id: "0")
    let nonArchivedOneGoalHabit = Habit.nonArchivedOneGoal(id: "1")
    let nonArchivedTwoGoalHabit = Habit.nonArchivedTwoGoal(id: "2")
}
