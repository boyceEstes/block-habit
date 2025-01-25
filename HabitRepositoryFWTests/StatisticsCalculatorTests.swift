//
//  StatisticsCalculatorTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 5/8/24.
//

import XCTest
import HabitRepositoryFW


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
    
    
    // MARK: findAverageRecordsPerDay
    func test_findAverageRecordsPerDays_withNoDays_deliversZero() {
        
        // given/when
        let avgRecordsPerDay = StatisticsCalculator.findAverageRecordsPerDay(for: [:])
        
        // then
        XCTAssertEqual(avgRecordsPerDay, -1)
    }
    
    
    func test_findAverageRecordsPerDays_withMultipleEmptyDays_deliversAverageOfZero() {
        
        // given
        let daysWithEmptyRecords = setupDaysForDictionary()
        let expectedAverage: Double = 0
        
        // when
        let avgRecordsPerDay = StatisticsCalculator.findAverageRecordsPerDay(for: daysWithEmptyRecords)
        
        // then
        XCTAssertEqual(avgRecordsPerDay, expectedAverage)
    }
    
    
    func test_findAverageRecordsPerDays_multipleRecordsMultipleHabitsOverDifferentDates_deliversNumberOfDays() {
        
        // given
        let habitRecordsForDays = setupRecordsForDays()
        let expectedNumberOfDays = habitRecordsForDays.keys.count
        let expectedNumberOfRecords = habitRecordsForDays.values.reduce(0) { $0 + $1.count }
        let expectedAverage = Double(expectedNumberOfRecords) / Double(expectedNumberOfDays)
        
        // when
        let avgRecordsPerDay = StatisticsCalculator.findAverageRecordsPerDay(for: habitRecordsForDays)
        
        // then
        XCTAssertEqual(avgRecordsPerDay, expectedAverage)
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
    
    
    // MARK: findHabitWithBestStreak
    func test_findHabitWithBestStreak_withNoDaysSomeHabits_deliversNil() {
        
        // given
        let availableHabits = availableHabits()
        
        // when
        let bestStreak = StatisticsCalculator.findHabitWithBestStreak(for: [:], with: availableHabits)
        
        // then
        XCTAssertNil(bestStreak)
    }
    
    
    func test_findHabitWithBestStreak_withIncompleteGapBetweenDays_deliversBestHabitAndCorrectCount() {
        
        // given
        let nonArcihved1GoalHabit = nonArchivedOneGoalHabit
        var habitRecordsForDays = setupDaysForDictionary() // Zeros out all the dates in the [Date: [HabitRecord]] dict
        
        let latestDate = someDay
        let yesterDate = someDay.adding(days: -1)
        // skip the next date
        let threeDatesAgo = someDay.adding(days: -3)
        
        habitRecordsForDays[latestDate] = [HabitRecord.habitRecord(date: latestDate, habit: nonArcihved1GoalHabit)]
        habitRecordsForDays[yesterDate] = [HabitRecord.habitRecord(date: yesterDate, habit: nonArcihved1GoalHabit)]
        habitRecordsForDays[threeDatesAgo] = [HabitRecord.habitRecord(date: threeDatesAgo, habit: nonArcihved1GoalHabit)]
        
        // when
        let bestStreak = StatisticsCalculator.findHabitWithBestStreak(for: habitRecordsForDays, with: [nonArcihved1GoalHabit])
        
        // then
        XCTAssertEqual(bestStreak?.habit, nonArcihved1GoalHabit)
        XCTAssertEqual(bestStreak?.count, 2)
    }
    
    
    func test_findHabitWithBestStreak_withMultipleEmptyDays_deliversNil() {
        
        // given
        let availableHabits = availableHabits()
        let habitRecordsForDays = setupDaysForDictionary()
        
        // when
        let bestStreak = StatisticsCalculator.findHabitWithBestStreak(for: habitRecordsForDays, with: availableHabits)
        
        // then
        XCTAssertNil(bestStreak)
    }
    
    
    func test_findHabitWithBestStreak_withMultipleRecordsMultipleHabitsOverDifferentDates_deliversBestStreakHabitAndCount() { 
        
        // given
        let availableHabits = availableHabits()
        let habitRecordsForDays = setupRecordsForDays()
        
        // when
        guard let (bestStreakHabit, bestStreakCount) = StatisticsCalculator.findHabitWithBestStreak(for: habitRecordsForDays, with: availableHabits) else {
            XCTFail("Retrieved nil for some reason")
            return
        }
        
        // then
        XCTAssertEqual(bestStreakHabit, nonArchivedOneGoalHabit)
        XCTAssertEqual(bestStreakCount, 3)
    }
    
    
    // MARK: findCurrentStreakInRecordsForHabit
    func test_findCurrentStreakInRecordsForHabit_withNoDays_deliversZero() {
        
        // given
        let records: [Date: [HabitRecord]] = [:]
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: records)
        
        // then
        XCTAssertEqual(currentStreak, 0)
    }
    
    
    func test_findCurrentStreakInRecordsForHabit_withEmptyDays_deliversZero() {
        
        // given
        let records: [Date: [HabitRecord]] = setupDaysForDictionary()
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: records)
        
        // then
        XCTAssertEqual(currentStreak, 0)
    }
    
    
    
    func test_currentStreakInRecordsForHabit_multipleConsecutiveRecordsAtBeginning_deliversZero() {
        
        // given
        
        /*
         *   o  -  -  -  -  -  -
         *   o  o  o  -  -  -  -
         * [-6 -5 -4 -3 -2 -1  0]
         */
        
        
        let sixDaysPrevious = someDay.adding(days: -6) // This should be beginning of the dictionary
        let fiveDaysPrevious = someDay.adding(days: -5)
        let fourDaysPrevious = someDay.adding(days: -4)
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordSixDaysAgo2 = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFiveDaysAgo = HabitRecord.habitRecord(date: fiveDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo2)
        recordsForDays[fiveDaysPrevious]?.append(recordFiveDaysAgo)
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(currentStreak, 0)
    }
    
    func test_currentStreakInRecordsForHabit_multipleConsecutiveRecordsInMiddle_deliversZero() { 
        
        // given
        
        /*
         *   -  -  -  o  -  -  -
         *   -  -  o  o  o  -  -
         * [-6 -5 -4 -3 -2 -1  0]
         */
        
        let fourDaysPrevious = someDay.adding(days: -4) // This should be beginning of the dictionary
        let threeDaysPrevious = someDay.adding(days: -3)
        let twoDaysPrevious = someDay.adding(days: -2)
        
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo2)
        recordsForDays[twoDaysPrevious]?.append(recordTwoDaysAgo)
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(currentStreak, 0)
    }
    
    
    func test_currentStreakInRecordsForHabit_multipleConsecutiveRecordsAtEndDayBeforeLatestDay() {
        
        // given
        
        /*
         *   -  -  -  o  -  o  -
         *   -  -  o  o  o  o  -
         * [-6 -5 -4 -3 -2 -1  0]
         */
        
        let fourDaysPrevious = someDay.adding(days: -4) // This should be beginning of the dictionary
        let threeDaysPrevious = someDay.adding(days: -3)
        let twoDaysPrevious = someDay.adding(days: -2)
        let oneDaysPrevious = someDay.adding(days: -1)
        
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDaysAgo = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDaysAgo2 = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo2)
        recordsForDays[twoDaysPrevious]?.append(recordTwoDaysAgo)
        recordsForDays[oneDaysPrevious]?.append(recordOneDaysAgo)
        recordsForDays[oneDaysPrevious]?.append(recordOneDaysAgo2)
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(currentStreak, 4)
    }
    
    
    func test_currentStreakInRecordsForHabit_multipleConsecutiveRecordsAtEndDayLatestDay() {
        
        // given
        
        /*
         *   -  -  -  o  -  o  -
         *   -  -  o  o  o  o  o
         * [-6 -5 -4 -3 -2 -1  0]
         */
        
        let fourDaysPrevious = someDay.adding(days: -4) // This should be beginning of the dictionary
        let threeDaysPrevious = someDay.adding(days: -3)
        let twoDaysPrevious = someDay.adding(days: -2)
        let oneDaysPrevious = someDay.adding(days: -1)
        
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDaysAgo = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDaysAgo2 = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordToday = HabitRecord.habitRecord(date: someDay, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo2)
        recordsForDays[twoDaysPrevious]?.append(recordTwoDaysAgo)
        recordsForDays[oneDaysPrevious]?.append(recordOneDaysAgo)
        recordsForDays[oneDaysPrevious]?.append(recordOneDaysAgo2)
        recordsForDays[someDay]?.append(recordToday)
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(currentStreak, 5)
    }
    
    
    func test_currentStreakInRecordsForHabit_missingADay_deliversOne() {
        
        // given
        
        /*
         *   -  x  -  o  -  -  -
         *   o  x  o  o  o  -  o
         * [-6  x -4 -3 -2 -1  0]
         */
        
        let sixDaysPrevious = someDay.adding(days: -6)
        let fourDaysPrevious = someDay.adding(days: -4)
        let threeDaysPrevious = someDay.adding(days: -3)
        let twoDaysPrevious = someDay.adding(days: -2)
        let oneDaysPrevious = someDay.adding(days: -1)
        let today = someDay
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordToday = HabitRecord.habitRecord(date: today, habit: nonArchivedOneGoalHabit)
        
        let recordsForDays = [
            sixDaysPrevious: [recordSixDaysAgo],
            // MISSING DAY 5!
            fourDaysPrevious: [recordFourDaysAgo],
            threeDaysPrevious: [recordThreeDaysAgo, recordThreeDaysAgo2],
            twoDaysPrevious: [recordTwoDaysAgo],
            oneDaysPrevious: [],
            today: [recordToday]
        ]
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(currentStreak, 1)
    }
    
    
    // MARK: bestStreakInRecordsForHabit
    
    func test_findBestStreakInRecordsForHabit_withNoDays_deliversZero() {
        
        // given
        let records: [Date: [HabitRecord]] = [:]
        
        // when
        let bestStreak = StatisticsCalculator.findBestStreakInRecordsForHabit(for: records)
        
        // then
        XCTAssertEqual(bestStreak, 0)
    }
    
    
    func test_findBestStreakInRecordsForHabit_withEmptyDays_deliversZero() {
        
        // given
        let records: [Date: [HabitRecord]] = setupDaysForDictionary()
        
        // when
        let bestStreak = StatisticsCalculator.findBestStreakInRecordsForHabit(for: records)
        
        // then
        XCTAssertEqual(bestStreak, 0)
    }
    
    
    
    func test_bestStreakInRecordsForHabit_onlyConsecutiveRecordsAtBeginning_deliversConsecutiveStreak() {
        
        // given
        
        /*
         *   o  -  -  -  -  -  -
         *   o  o  o  -  -  -  -
         * [-6 -5 -4 -3 -2 -1  0]
         */
        
        
        let sixDaysPrevious = someDay.adding(days: -6) // This should be beginning of the dictionary
        let fiveDaysPrevious = someDay.adding(days: -5)
        let fourDaysPrevious = someDay.adding(days: -4)
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordSixDaysAgo2 = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFiveDaysAgo = HabitRecord.habitRecord(date: fiveDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo2)
        recordsForDays[fiveDaysPrevious]?.append(recordFiveDaysAgo)
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        
        // when
        let bestStreak = StatisticsCalculator.findBestStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(bestStreak, 3)
    }
    
    func test_bestStreakInRecordsForHabit_twoConsecutiveRecordsLargerFirst_deliversLargestStreak() {
        
        // given
        
        /*
         *   -  -  -  o  -  -  -
         *   o  o  o  o  -  o  o
         * [-6 -5 -4 -3 -2 -1  0]
         */
        let sixDaysPrevious = someDay.adding(days: -6)
        let fiveDaysPrevious = someDay.adding(days: -5)
        let fourDaysPrevious = someDay.adding(days: -4)
        let threeDaysPrevious = someDay.adding(days: -3)
        let oneDaysPrevious = someDay.adding(days: -1)
        let today = someDay
        
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFiveDaysAgo = HabitRecord.habitRecord(date: fiveDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDaysAgo = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordToday = HabitRecord.habitRecord(date: today, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
        recordsForDays[fiveDaysPrevious]?.append(recordFiveDaysAgo)
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo2)
        recordsForDays[oneDaysPrevious]?.append(recordOneDaysAgo)
        recordsForDays[today]?.append(recordToday)
        
        // when
        let bestStreak = StatisticsCalculator.findBestStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(bestStreak, 4)
    }
    
    
    func test_bestStreakInRecordsForHabit_ThreeRecordIslandsLargerInMiddle_deliversLargestStreak() {
        
        // given
        
        /*
         *   -  -  -  o  -  -  -
         *   o  -  o  o  o  -  o
         * [-6 -5 -4 -3 -2 -1  0]
         */
        let sixDaysPrevious = someDay.adding(days: -6)
        let fourDaysPrevious = someDay.adding(days: -4)
        let threeDaysPrevious = someDay.adding(days: -3)
        let twoDaysPrevious = someDay.adding(days: -2)
        let today = someDay
        
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
        
        let recordToday = HabitRecord.habitRecord(date: today, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
        
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo2)
        recordsForDays[twoDaysPrevious]?.append(recordTwoDaysAgo)
        
        recordsForDays[today]?.append(recordToday)
        
        // when
        let bestStreak = StatisticsCalculator.findBestStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(bestStreak, 3)
    }

    
    func test_bestStreakInRecordsForHabit_twoStreaksLargerLast_deliversLargestStreak() {
        
        // given
        
        /*
         *   -  -  -  o  -  -  -
         *   o  o  -  o  o  o  o
         * [-6 -5 -4 -3 -2 -1  0]
         */
        
        let sixDaysPrevious = someDay.adding(days: -6)
        let fiveDaysPrevious = someDay.adding(days: -5)
        let threeDaysPrevious = someDay.adding(days: -3)
        let twoDaysPrevious = someDay.adding(days: -2)
        let oneDaysPrevious = someDay.adding(days: -1)
        let today = someDay
        
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFiveDaysAgo = HabitRecord.habitRecord(date: fiveDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDaysAgo = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordToday = HabitRecord.habitRecord(date: today, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
        recordsForDays[fiveDaysPrevious]?.append(recordFiveDaysAgo)
        
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo2)
        recordsForDays[twoDaysPrevious]?.append(recordTwoDaysAgo)
        recordsForDays[oneDaysPrevious]?.append(recordOneDaysAgo)
        recordsForDays[today]?.append(recordToday)
        
        // when
        let bestStreak = StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(bestStreak, 4)
    }
    
    
    func test_bestStreakInRecordsForHabit_missingADay_deliversStreakCountIncludingLastDay() {
        
        // given
        
        /*
         *   -  x  -  o  -  -  -
         *   o  x  o  o  o  o  o
         * [-6  x -4 -3 -2 -1  0]
         */
        
        let sixDaysPrevious = someDay.adding(days: -6)
        let fourDaysPrevious = someDay.adding(days: -4)
        let threeDaysPrevious = someDay.adding(days: -3)
        let twoDaysPrevious = someDay.adding(days: -2)
        let oneDaysPrevious = someDay.adding(days: -1)
        let today = someDay
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDayAgo = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordToday = HabitRecord.habitRecord(date: today, habit: nonArchivedOneGoalHabit)
        
        let recordsForDays = [
            sixDaysPrevious: [recordSixDaysAgo],
            // MISSING DAY 5!
            fourDaysPrevious: [recordFourDaysAgo],
            threeDaysPrevious: [recordThreeDaysAgo, recordThreeDaysAgo2],
            twoDaysPrevious: [recordTwoDaysAgo],
            oneDaysPrevious: [recordOneDayAgo],
            today: [recordToday]
        ]
        
        // when
        let bestStreak = StatisticsCalculator.findBestStreakInRecordsForHabit(for: recordsForDays)
        
        // then
        XCTAssertEqual(bestStreak, 5)
    }
    
    
    // MARK: findCurrentUsageStreak
    func test_findCurrentUsageStreak_withNoDays_deliversZero() {
        
        // given
        let records: [Date: [HabitRecord]] = [:]
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentUsageStreak(for: records)
        
        // then
        XCTAssertEqual(currentStreak, 0)
    }
    
    
    func test_findCurrentUsageStreak_withEmptyDays_deliversZero() {
        
        // given
        let records: [Date: [HabitRecord]] = setupDaysForDictionary()
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentUsageStreak(for: records)
        
        // then
        XCTAssertEqual(currentStreak, 0)
    }
    
    
    
    func test_findCurrentUsageStreak_onlyConsecutiveRecordsNotAtSelectedDay_deliversZero() {
        
        // given
        
        /*
         *   o  -  -  -  -  -  -
         *   o  o  o  -  -  -  -
         * [-6 -5 -4 -3 -2 -1  0]
         */
        
        
        let sixDaysPrevious = someDay.adding(days: -6) // This should be beginning of the dictionary
        let fiveDaysPrevious = someDay.adding(days: -5)
        let fourDaysPrevious = someDay.adding(days: -4)
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordSixDaysAgo2 = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFiveDaysAgo = HabitRecord.habitRecord(date: fiveDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo2)
        recordsForDays[fiveDaysPrevious]?.append(recordFiveDaysAgo)
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentUsageStreak(for: recordsForDays)
        
        // then
        XCTAssertEqual(currentStreak, 0)
    }

    func test_findCurrentUsageStreak_twoConsecutiveRecordsLargerFirst_deliversShorterStreakConnectedToToday() {
        
        // given
        
        /*
         *   -  -  -  o  -  -  -
         *   o  o  o  o  -  o  o
         * [-6 -5 -4 -3 -2 -1  0]
         */
        let sixDaysPrevious = someDay.adding(days: -6)
        let fiveDaysPrevious = someDay.adding(days: -5)
        let fourDaysPrevious = someDay.adding(days: -4)
        let threeDaysPrevious = someDay.adding(days: -3)
        let oneDaysPrevious = someDay.adding(days: -1)
        let today = someDay
        
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFiveDaysAgo = HabitRecord.habitRecord(date: fiveDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDaysAgo = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordToday = HabitRecord.habitRecord(date: today, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
        recordsForDays[fiveDaysPrevious]?.append(recordFiveDaysAgo)
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo2)
        recordsForDays[oneDaysPrevious]?.append(recordOneDaysAgo)
        recordsForDays[today]?.append(recordToday)
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentUsageStreak(for: recordsForDays)
        
        // then
        XCTAssertEqual(currentStreak, 2)
    }
    
    func test_findCurrentUsageStreak_nothingTodayStreakUntilYesterday_deliversStreakFromYesterday() {
        
        // given
        
        /*
         *   -  -  -  -  -  -  -
         *   o  o  o  -  o  o  -
         * [-6 -5 -4 -3 -2 -1  0]
         */
        let sixDaysPrevious = someDay.adding(days: -6)
        let fiveDaysPrevious = someDay.adding(days: -5)
        let fourDaysPrevious = someDay.adding(days: -4)
        let twoDaysPrevious = someDay.adding(days: -2)
        let oneDaysPrevious = someDay.adding(days: -1)
        
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFiveDaysAgo = HabitRecord.habitRecord(date: fiveDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDaysAgo = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
        recordsForDays[fiveDaysPrevious]?.append(recordFiveDaysAgo)
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        recordsForDays[twoDaysPrevious]?.append(recordTwoDaysAgo)
        recordsForDays[oneDaysPrevious]?.append(recordOneDaysAgo)
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentUsageStreak(for: recordsForDays)
        
        // then
        XCTAssertEqual(currentStreak, 2)
    }

    
    func test_findCurrentUsageStreak_allDaysInDict_deliversCountMatchingNumOfDays() {
        
        // given
        
        /*
         *   -  -  -  -  -  -  -
         *   o  o  o  o  o  o  o
         * [-6 -5 -4 -3 -2 -1  0]
         */
        
        let sixDaysPrevious = someDay.adding(days: -6)
        let fiveDaysPrevious = someDay.adding(days: -5)
        let fourDaysPrevious = someDay.adding(days: -4)
        let threeDaysPrevious = someDay.adding(days: -3)
        let twoDaysPrevious = someDay.adding(days: -2)
        let oneDayPrevious = someDay.adding(days: -1)
        let today = someDay
        
        
        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFiveDaysAgo = HabitRecord.habitRecord(date: fiveDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
        let recordOneDaysAgo = HabitRecord.habitRecord(date: oneDayPrevious, habit: nonArchivedOneGoalHabit)
        let recordToday = HabitRecord.habitRecord(date: today, habit: nonArchivedOneGoalHabit)
        
        var recordsForDays = setupDaysForDictionary()
        
        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
        recordsForDays[fiveDaysPrevious]?.append(recordFiveDaysAgo)
        recordsForDays[fourDaysPrevious]?.append(recordFourDaysAgo)
        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo)
        recordsForDays[twoDaysPrevious]?.append(recordTwoDaysAgo)
        recordsForDays[oneDayPrevious]?.append(recordOneDaysAgo)
        recordsForDays[today]?.append(recordToday)
        
        // when
        let currentStreak = StatisticsCalculator.findCurrentUsageStreak(for: recordsForDays)
        
        // then
        XCTAssertEqual(currentStreak, 7)
    }
//
//    
//    func test_bestStreakInRecordsForHabit_twoStreaksLargerLast_deliversLargestStreak() {
//        
//        // given
//        
//        /*
//         *   -  -  -  o  -  -  -
//         *   o  o  -  o  o  o  o
//         * [-6 -5 -4 -3 -2 -1  0]
//         */
//        
//        let sixDaysPrevious = someDay.adding(days: -6)
//        let fiveDaysPrevious = someDay.adding(days: -5)
//        let threeDaysPrevious = someDay.adding(days: -3)
//        let twoDaysPrevious = someDay.adding(days: -2)
//        let oneDaysPrevious = someDay.adding(days: -1)
//        let today = someDay
//        
//        
//        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordFiveDaysAgo = HabitRecord.habitRecord(date: fiveDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordOneDaysAgo = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordToday = HabitRecord.habitRecord(date: today, habit: nonArchivedOneGoalHabit)
//        
//        var recordsForDays = setupDaysForDictionary()
//        
//        recordsForDays[sixDaysPrevious]?.append(recordSixDaysAgo)
//        recordsForDays[fiveDaysPrevious]?.append(recordFiveDaysAgo)
//        
//        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo)
//        recordsForDays[threeDaysPrevious]?.append(recordThreeDaysAgo2)
//        recordsForDays[twoDaysPrevious]?.append(recordTwoDaysAgo)
//        recordsForDays[oneDaysPrevious]?.append(recordOneDaysAgo)
//        recordsForDays[today]?.append(recordToday)
//        
//        // when
//        let bestStreak = StatisticsCalculator.findCurrentStreakInRecordsForHabit(for: recordsForDays)
//        
//        // then
//        XCTAssertEqual(bestStreak, 4)
//    }
//    
//    
//    func test_bestStreakInRecordsForHabit_missingADay_deliversStreakCountIncludingLastDay() {
//        
//        // given
//        
//        /*
//         *   -  x  -  o  -  -  -
//         *   o  x  o  o  o  o  o
//         * [-6  x -4 -3 -2 -1  0]
//         */
//        
//        let sixDaysPrevious = someDay.adding(days: -6)
//        let fourDaysPrevious = someDay.adding(days: -4)
//        let threeDaysPrevious = someDay.adding(days: -3)
//        let twoDaysPrevious = someDay.adding(days: -2)
//        let oneDaysPrevious = someDay.adding(days: -1)
//        let today = someDay
//        
//        let recordSixDaysAgo = HabitRecord.habitRecord(date: sixDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordFourDaysAgo = HabitRecord.habitRecord(date: fourDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordThreeDaysAgo = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordThreeDaysAgo2 = HabitRecord.habitRecord(date: threeDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordTwoDaysAgo = HabitRecord.habitRecord(date: twoDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordOneDayAgo = HabitRecord.habitRecord(date: oneDaysPrevious, habit: nonArchivedOneGoalHabit)
//        let recordToday = HabitRecord.habitRecord(date: today, habit: nonArchivedOneGoalHabit)
//        
//        let recordsForDays = [
//            sixDaysPrevious: [recordSixDaysAgo],
//            // MISSING DAY 5!
//            fourDaysPrevious: [recordFourDaysAgo],
//            threeDaysPrevious: [recordThreeDaysAgo, recordThreeDaysAgo2],
//            twoDaysPrevious: [recordTwoDaysAgo],
//            oneDaysPrevious: [recordOneDayAgo],
//            today: [recordToday]
//        ]
//        
//        // when
//        let bestStreak = StatisticsCalculator.findBestStreakInRecordsForHabit(for: recordsForDays)
//        
//        // then
//        XCTAssertEqual(bestStreak, 5)
//    }

    
    // MARK: Helpers
    
    private func setupRecordsForDays() -> RecordsForDays {
        
        // Setting this many just because it is our minimum number of dates in the dictionary
        let someDayNoon = someDay
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
        let startDate = someDay
        
        for i in 0..<numberOfDays {
            
            let day = startDate.adding(days: -i).noon!
            recordsForDays[day] = []
        }
        
        return recordsForDays
    }
    
    
    private func availableHabits() -> [Habit] {
        
        [nonArchivedZeroGoalHabit, nonArchivedOneGoalHabit, nonArchivedTwoGoalHabit]
    }
    
        
    var someDay: Date { Date(timeIntervalSince1970: 1714674435).noon! }
    
    // given
    let nonArchivedZeroGoalHabit = Habit.nonArchivedZeroGoal(id: "0")
    let nonArchivedOneGoalHabit = Habit.nonArchivedOneGoal(id: "1")
    let nonArchivedTwoGoalHabit = Habit.nonArchivedTwoGoal(id: "2")
}
