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
    
    
    func toHabitRecordsForDay() -> [Date: [HabitRecord]] {
        
        return [:]
    }
}



class Array_HabitRecordsForDayTests: XCTestCase {
    
    
    // lets say that we have a bunch of habit records - lets just ensure that we are converting them to use the right days as expected
    
    func test_emptyArray_deliversEmptyDictionary() {
        
        // given
        let habitRecords = [HabitRecord]()
        
        // when
        let habitRecordsForDay = habitRecords.toHabitRecordsForDay()
        
        // then
        XCTAssertEqual(habitRecordsForDay, [:])
    }
    
    
}

