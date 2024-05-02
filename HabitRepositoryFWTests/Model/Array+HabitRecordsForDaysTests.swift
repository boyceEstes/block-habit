//
//  Array+HabitRecordsForDayTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 5/2/24.
//

import Foundation
import XCTest
import HabitRepositoryFW




extension Array where Element == HabitRecord {
    
    ///
    /// `currentDate` is used to know how to know how may dates to deliver back in the habitRecordForDays dictionary - There must be at least delimiter amount to fill the screen
    /// `delimiter` is the minimum number of dates to deliver back in the dictionary, even if there are no records available
    /// This array is expected to be sorted, with the first index being the earliest completion dated.
    func toHabitRecordsForDays(onCurrentDate date: Date, delimiter: Int = 7) -> [Date: [HabitRecord]] {
        
        guard let currentDateNoon = date.noon else { return [:] }
        
        
        
        
        return [:]
    }
    
    
    /// Delivers the number of buffer days that should be given to pad out the habitRecordsForDays dictionay, if there are not the minimum delimiter amount - this makes the chart look more full even when you have nothing in it
    /// Expected  to be given currentDay at noon - if it is not not noon, things might be a little messed up because everything is saved by noon so subtractions by day might not work accurately
    func bufferDaysForHabitRecordsForDays(currentDay: Date, delimiter: Int) -> Int {
        
        if self.isEmpty {
            return delimiter
            
        } else if let earliestRecordDate = self.first?.completionDate,
                    let numDaysBetweenEarliestToCurrent = Calendar.current.dateComponents([.day], from: earliestRecordDate, to: currentDay).day,
                    numDaysBetweenEarliestToCurrent < delimiter {
            
            return delimiter - (numDaysBetweenEarliestToCurrent + 1)
        } else {
            return 0
        }
    }
}


class Array_HabitRecordsForDays_BufferDaysTests: XCTestCase {
    
    func test_emptyArray_delivers7BufferDays() {
        
        // given
        let currentDay = Date()
        let habitRecords = [HabitRecord]()
        
        // when
        let bufferDays = habitRecords.bufferDaysForHabitRecordsForDays(currentDay: currentDay, delimiter: delimiter)
        
        // then
        XCTAssertEqual(bufferDays, 7)
    }
    
    
    func test_arrayOneRecordOnCurrentDay_delivers6DayBuffer() {
        
        // given
        let currentDay = Date().noon!
        let habitRecords: [HabitRecord] = [HabitRecord.habitRecord(date: currentDay, habit: Habit.archivedOneGoal)]
        
        // when
        let bufferDays = habitRecords.bufferDaysForHabitRecordsForDays(currentDay: currentDay, delimiter: delimiter)
        
        // then
        XCTAssertEqual(bufferDays, 6)
    }
    
    
    func test_arrayOneRecordOn3DaysAgoDay_delivers3DayBuffer() {
        
        // given
        let currentDay = Date().noon!
        let threeDaysAgo = currentDay.adding(days: -3)
        let habitRecords: [HabitRecord] = [HabitRecord.habitRecord(date: threeDaysAgo, habit: Habit.archivedOneGoal)]
        
        // when
        let bufferDays = habitRecords.bufferDaysForHabitRecordsForDays(currentDay: currentDay, delimiter: delimiter)
        
        // then
        XCTAssertEqual(bufferDays, 3)
    }
    
    
    func test_arrayOneRecordOn6DaysAgoDay_delivers0DayBuffer() {
        
        // given
        let currentDay = Date().noon!
        let sixDaysAgo = currentDay.adding(days: -6)
        let habitRecords: [HabitRecord] = [HabitRecord.habitRecord(date: sixDaysAgo, habit: Habit.archivedOneGoal)]
        
        // when
        let bufferDays = habitRecords.bufferDaysForHabitRecordsForDays(currentDay: currentDay, delimiter: delimiter)
        
        // then
        XCTAssertEqual(bufferDays, 0)
    }
    
    
    func test_arrayOneRecordOn7DaysAgoDay_delivers0DayBuffer() {
        
        // given
        let currentDay = Date().noon!
        let sevenDaysAgo = currentDay.adding(days: -7)
        let habitRecords: [HabitRecord] = [HabitRecord.habitRecord(date: sevenDaysAgo, habit: Habit.archivedOneGoal)]
        
        // when
        let bufferDays = habitRecords.bufferDaysForHabitRecordsForDays(currentDay: currentDay, delimiter: delimiter)
        
        // then
        XCTAssertEqual(bufferDays, 0)
    }
    
    
    func test_arrayTwoRecordOn7DaysAgoAnd3DaysAgo_delivers0DayBuffer() {
        
        // given
        let currentDay = Date().noon!
        let threeDaysAgo = currentDay.adding(days: -3)
        let sevenDaysAgo = currentDay.adding(days: -7)
        
        // ORDER MATTERS!!
        let habitRecords: [HabitRecord] = [
            HabitRecord.habitRecord(date: sevenDaysAgo, habit: Habit.nonArchivedOneGoal),
            HabitRecord.habitRecord(date: threeDaysAgo, habit: Habit.nonArchivedTwoGoal)
        ]
        
        // when
        let bufferDays = habitRecords.bufferDaysForHabitRecordsForDays(currentDay: currentDay, delimiter: delimiter)
        
        // then
        XCTAssertEqual(bufferDays, 0)
    }
            
            
    var delimiter: Int { return 7 }
    
    
}


class Array_HabitRecordsForDaysTests: XCTestCase {
    
    
    
    
    
    // lets say that we have a bunch of habit records - lets just ensure that we are converting them to use the right days as expected
    
//    func test_emptyArray_deliversEmptyDictionary() {
//        
//        // given
//        let habitRecords = [HabitRecord]()
//        let someDate = Date() // I want to give a basic current date to our method and have it give the noon date
//        let someDateNoon = someDate.noon!
//        let someDateMinus1 = someDateNoon.adding(days: -1)
//        let someDateMinus2 = someDateNoon.adding(days: -2)
//        let someDateMinus3 = someDateNoon.adding(days: -3)
//        let someDateMinus4 = someDateNoon.adding(days: -4)
//        let someDateMinus5 = someDateNoon.adding(days: -5)
//        let someDateMinus6 = someDateNoon.adding(days: -6)
//        
//        let expectedHabitRecordsForDay: [Date: [HabitRecord]] = [
//            someDate: [],
//            someDateMinus1: [],
//            someDateMinus2: [],
//            someDateMinus3: [],
//            someDateMinus4: [],
//            someDateMinus5: [],
//            someDateMinus6: []
//        ]
//        
//        // when
//        let habitRecordsForDay = habitRecords.toHabitRecordsForDays(onCurrentDate: someDate, delimiter: delimiter)
//        
//        // then
//        XCTAssertEqual(habitRecordsForDay, expectedHabitRecordsForDay)
//    }
    
    
    
    var delimiter: Int { return 7 }
    
    
}

