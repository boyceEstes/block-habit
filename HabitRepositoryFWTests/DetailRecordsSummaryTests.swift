//
//  DetailRecordsSummaryTests.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/14/25.
//


import XCTest
@testable import HabitRepositoryFW

extension Array where Element == ActivityDetailRecord {
    
    func summary() -> String {
        
        return ""
    }
}

class DetailRecordsSummaryTests: XCTestCase {
    
    func test_emptyArray_deliversEmptySummary() {
        
        // given
        let detailRecords: [ActivityDetailRecord] = []
        
        // when/then
        XCTAssertEqual(detailRecords.summary(), "")
    }
}
