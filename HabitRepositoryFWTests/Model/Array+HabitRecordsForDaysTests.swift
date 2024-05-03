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
    /// `currentDate` is used to know how to know how may dates to deliver back in the habitRecordForDays dictionary - There must be at least delimiter amount to fill the screen. currentDate does not need to be noon, it will be converted automatically, so just the whatever date can be given
    /// `delimiter` is the minimum number of dates to deliver back in the dictionary, even if there are no records available
    /// This array is expected to be sorted, with the first index being the earliest completion dated.
    func toHabitRecordsForDays(onCurrentDate date: Date, delimiter: Int = 7) -> [Date: [HabitRecord]] {
        
        guard let currentDateNoon = date.noon else { return [:] }
        
        let bufferDaysForHabitRecordsForDays = bufferDaysForHabitRecordsForDays(currentDay: date, delimiter: delimiter)
        
        
        var daysForDict = 0
        if let earliestRecordDate = self.first?.completionDate {
            // earliest date is today - which is the same as current date
            // if the earliest date was another day, like Date-3, we'd have a buffer day for habit records of 3, right? yeah and from there we'd want to get 3 days before the current day. But since this is the current day we don't
//            if earliestRecordDate == date { bufferDaysForHabitRecordsForDays + 1 }
            
            let numOfDaysToEarliestRecord = Calendar.current.dateComponents([.day], from: earliestRecordDate, to: currentDateNoon).day ?? 0
            daysForDict = numOfDaysToEarliestRecord + bufferDaysForHabitRecordsForDays
        } else {
            daysForDict = bufferDaysForHabitRecordsForDays
        }
        
        
        var recordsForDays = [Date: [HabitRecord]]()
        
        
        for record in self {
            
            guard let noonDate = record.completionDate.noon else { return [:] }
            
            if recordsForDays[noonDate] != nil {
                recordsForDays[noonDate]?.append(record)
            } else {
                recordsForDays[noonDate] = [record]
            }
        }
        
        
        // Just fillin in the blanks
        for i in 0..<daysForDict {
            
            let dictDate = currentDateNoon.adding(days: -i)
            
            if recordsForDays[dictDate] == nil {
                recordsForDays[dictDate] = []
            }
        }
        
        return recordsForDays
    }
    
    
    /// Delivers the number of buffer days that should be given to pad out the habitRecordsForDays dictionay, if there are not the minimum delimiter amount - this makes the chart look more full even when you have nothing in it
    /// Expected  to be given currentDay at noon - if it is not not noon, things might be a little messed up because everything is saved by noon so subtractions by day might not work accurately
    func bufferDaysForHabitRecordsForDays(currentDay: Date, delimiter: Int) -> Int {
        
        if self.isEmpty {
            return delimiter
            
        } else if let earliestRecordDate = self.first?.completionDate,
                  let numDaysBetweenEarliestToCurrent = Calendar.current.dateComponents([.day], from: earliestRecordDate, to: currentDay).day,
                      numDaysBetweenEarliestToCurrent < delimiter {
                
            // There is more than the minimum days between today and the earliest record, no buffer needed
            return delimiter - numDaysBetweenEarliestToCurrent
        } else {
            // There is more than the minimum days between today and the earliest record, no buffer needed
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
        XCTAssertEqual(bufferDays, 7)
    }
    
    
    func test_arrayOneRecordOn3DaysAgoDay_delivers3DayBuffer() {
        
        // given
        let currentDay = Date().noon!
        let threeDaysAgo = currentDay.adding(days: -3)
        let habitRecords: [HabitRecord] = [HabitRecord.habitRecord(date: threeDaysAgo, habit: Habit.archivedOneGoal)]
        
        // when
        let bufferDays = habitRecords.bufferDaysForHabitRecordsForDays(currentDay: currentDay, delimiter: delimiter)
        
        // then
        XCTAssertEqual(bufferDays, 4)
    }
    
    
    func test_arrayOneRecordOn6DaysAgoDay_delivers0DayBuffer() {
        
        // given
        let currentDay = Date().noon!
        let sixDaysAgo = currentDay.adding(days: -6)
        let habitRecords: [HabitRecord] = [HabitRecord.habitRecord(date: sixDaysAgo, habit: Habit.archivedOneGoal)]
        
        // when
        let bufferDays = habitRecords.bufferDaysForHabitRecordsForDays(currentDay: currentDay, delimiter: delimiter)
        
        // then
        XCTAssertEqual(bufferDays, 1)
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
    
    func test_emptyArray_deliversEmptyDictionary() {
        
        // given
        let habitRecords = [HabitRecord]()
        let someDate = Date() // I want to give a basic current date to our method and have it give the noon date
        let someDateNoon = someDate.noon!
        let someDateMinus1 = someDateNoon.adding(days: -1)
        let someDateMinus2 = someDateNoon.adding(days: -2)
        let someDateMinus3 = someDateNoon.adding(days: -3)
        let someDateMinus4 = someDateNoon.adding(days: -4)
        let someDateMinus5 = someDateNoon.adding(days: -5)
        let someDateMinus6 = someDateNoon.adding(days: -6)
        
        let expectedHabitRecordsForDay: [Date: [HabitRecord]] = [
            someDateNoon: [],
            someDateMinus1: [],
            someDateMinus2: [],
            someDateMinus3: [],
            someDateMinus4: [],
            someDateMinus5: [],
            someDateMinus6: []
        ]
        
        // when
        let habitRecordsForDay = habitRecords.toHabitRecordsForDays(onCurrentDate: someDate, delimiter: delimiter)
        
        // then
        XCTAssertEqual(habitRecordsForDay, expectedHabitRecordsForDay)
    }
    
    
    func test_arrayOneRecordOnCurrentDay_delivers6PriorDaysThatAreEmpty() {
        
        
        let someDate = Date() // I want to give a basic current date to our method and have it give the noon date
        let someDateNoon = someDate.noon!
        let someDateMinus1 = someDateNoon.adding(days: -1)
        let someDateMinus2 = someDateNoon.adding(days: -2)
        let someDateMinus3 = someDateNoon.adding(days: -3)
        let someDateMinus4 = someDateNoon.adding(days: -4)
        let someDateMinus5 = someDateNoon.adding(days: -5)
        let someDateMinus6 = someDateNoon.adding(days: -6)
        
        let oneHabitRecordOnCurrentDay = HabitRecord.habitRecord(date: someDateNoon, habit: Habit.nonArchivedOneGoal)
        let habitRecords = [oneHabitRecordOnCurrentDay]
        
        let expectedHabitRecordsForDay: [Date: [HabitRecord]] = [
            someDateNoon: [oneHabitRecordOnCurrentDay],
            someDateMinus1: [],
            someDateMinus2: [],
            someDateMinus3: [],
            someDateMinus4: [],
            someDateMinus5: [],
            someDateMinus6: []
        ]
        
        
        // when
        let habitRecordsForDay = habitRecords.toHabitRecordsForDays(onCurrentDate: someDate, delimiter: delimiter)
        
        // then
        XCTAssertEqual(habitRecordsForDay, expectedHabitRecordsForDay)
    }
    
    
    func test_arrayOneRecordOn3DaysAgoDay_delivers3DayBuffer() {
        
        let someDate = Date() // I want to give a basic current date to our method and have it give the noon date
        let someDateNoon = someDate.noon!
        let someDateMinus1 = someDateNoon.adding(days: -1)
        let someDateMinus2 = someDateNoon.adding(days: -2)
        let someDateMinus3 = someDateNoon.adding(days: -3)
        let someDateMinus4 = someDateNoon.adding(days: -4)
        let someDateMinus5 = someDateNoon.adding(days: -5)
        let someDateMinus6 = someDateNoon.adding(days: -6)
        
        let oneHabitRecordOnCurrentDay = HabitRecord.habitRecord(date: someDateMinus3, habit: Habit.nonArchivedOneGoal)
        let habitRecords = [oneHabitRecordOnCurrentDay]
        
        let expectedHabitRecordsForDay: [Date: [HabitRecord]] = [
            someDateNoon: [],
            someDateMinus1: [],
            someDateMinus2: [],
            someDateMinus3: [oneHabitRecordOnCurrentDay],
            someDateMinus4: [],
            someDateMinus5: [],
            someDateMinus6: []
        ]
        
        
        // when
        let habitRecordsForDay = habitRecords.toHabitRecordsForDays(onCurrentDate: someDate, delimiter: delimiter)
        
        // then
        XCTAssertEqual(habitRecordsForDay, expectedHabitRecordsForDay)
    }
    
    
    func test_arrayOneRecordOn6DaysAgoDay_delivers1DayBuffer() {
        
        
        let someDate = Date() // I want to give a basic current date to our method and have it give the noon date
        let someDateNoon = someDate.noon!
        let someDateMinus1 = someDateNoon.adding(days: -1)
        let someDateMinus2 = someDateNoon.adding(days: -2)
        let someDateMinus3 = someDateNoon.adding(days: -3)
        let someDateMinus4 = someDateNoon.adding(days: -4)
        let someDateMinus5 = someDateNoon.adding(days: -5)
        let someDateMinus6 = someDateNoon.adding(days: -6)
        
        let oneHabitRecordOnCurrentDay = HabitRecord.habitRecord(date: someDateMinus6, habit: Habit.nonArchivedOneGoal)
        let habitRecords = [oneHabitRecordOnCurrentDay]
        
        let expectedHabitRecordsForDay: [Date: [HabitRecord]] = [
            someDateNoon: [],
            someDateMinus1: [],
            someDateMinus2: [],
            someDateMinus3: [],
            someDateMinus4: [],
            someDateMinus5: [],
            someDateMinus6: [oneHabitRecordOnCurrentDay]
        ]
        
        
        // when
        let habitRecordsForDay = habitRecords.toHabitRecordsForDays(onCurrentDate: someDate, delimiter: delimiter)
        
        // then
        XCTAssertEqual(habitRecordsForDay, expectedHabitRecordsForDay)
    }
    
    
    func test_arrayOneRecordOn7DaysAgoDay_delivers0DayBuffer() {
        
        let someDate = Date() // I want to give a basic current date to our method and have it give the noon date
        let someDateNoon = someDate.noon!
        let someDateMinus1 = someDateNoon.adding(days: -1)
        let someDateMinus2 = someDateNoon.adding(days: -2)
        let someDateMinus3 = someDateNoon.adding(days: -3)
        let someDateMinus4 = someDateNoon.adding(days: -4)
        let someDateMinus5 = someDateNoon.adding(days: -5)
        let someDateMinus6 = someDateNoon.adding(days: -6)
        let someDateMinus7 = someDateNoon.adding(days: -7)
        
        let oneHabitRecordOnCurrentDay = HabitRecord.habitRecord(date: someDateMinus7, habit: Habit.nonArchivedOneGoal)
        let habitRecords = [oneHabitRecordOnCurrentDay]
        
        let expectedHabitRecordsForDay: [Date: [HabitRecord]] = [
            someDateNoon: [],
            someDateMinus1: [],
            someDateMinus2: [],
            someDateMinus3: [],
            someDateMinus4: [],
            someDateMinus5: [],
            someDateMinus6: [],
            someDateMinus7: [oneHabitRecordOnCurrentDay]
        ]
        
        
        // when
        let habitRecordsForDay = habitRecords.toHabitRecordsForDays(onCurrentDate: someDate, delimiter: delimiter)
        
        // then
        XCTAssertEqual(habitRecordsForDay, expectedHabitRecordsForDay)
    }
    
    
    func test_arrayTwoRecordOn7DaysAgoAnd3DaysAgo_delivers0DayBuffer() {
        
        let someDate = Date() // I want to give a basic current date to our method and have it give the noon date
        let someDateNoon = someDate.noon!
        let someDateMinus1 = someDateNoon.adding(days: -1)
        let someDateMinus2 = someDateNoon.adding(days: -2)
        let someDateMinus3 = someDateNoon.adding(days: -3)
        let someDateMinus4 = someDateNoon.adding(days: -4)
        let someDateMinus5 = someDateNoon.adding(days: -5)
        let someDateMinus6 = someDateNoon.adding(days: -6)
        let someDateMinus7 = someDateNoon.adding(days: -7)
        
        let oneHabitRecordOnSevenDaysAgo = HabitRecord.habitRecord(date: someDateMinus7, habit: Habit.nonArchivedOneGoal)
        let oneHabitRecordOnThreeDaysAgo = HabitRecord.habitRecord(date: someDateMinus3, habit: Habit.nonArchivedTwoGoal)
        
        let habitRecords: [HabitRecord] = [
            oneHabitRecordOnSevenDaysAgo,
            oneHabitRecordOnThreeDaysAgo
        ]
        
        let expectedHabitRecordsForDay: [Date: [HabitRecord]] = [
            someDateNoon: [],
            someDateMinus1: [],
            someDateMinus2: [],
            someDateMinus3: [oneHabitRecordOnThreeDaysAgo],
            someDateMinus4: [],
            someDateMinus5: [],
            someDateMinus6: [],
            someDateMinus7: [oneHabitRecordOnSevenDaysAgo]
        ]
        
        
        // when
        let habitRecordsForDay = habitRecords.toHabitRecordsForDays(onCurrentDate: someDate, delimiter: delimiter)
        
        // then
        XCTAssertEqual(habitRecordsForDay, expectedHabitRecordsForDay)
    }
    
    
    
    var delimiter: Int { return 7 }
}

