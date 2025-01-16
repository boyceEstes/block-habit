//
//  DetailRecordsSummaryTests.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/14/25.
//


import XCTest
@testable import HabitRepositoryFW



class DetailRecordsSummaryTests: XCTestCase {
    
    func test_emptyArray_deliversEmptySummary() {
        
        // given
        let detailRecords: [ActivityDetailRecord] = []
        
        // when/then
        XCTAssertEqual(detailRecords.summary(), "")
    }
    
    
    func test_arrayWithOnlyOneNumberDetailWithNoUnits_deliversDetailSummary() {
        
        // given
        let activityDetailRecord = makeActivityDetailRecord(name: "Any", value: "12", units: nil, valueType: .number)
        let detailRecords: [ActivityDetailRecord] = [activityDetailRecord]
        
        // when/then
        XCTAssertEqual(detailRecords.summary(), "Any: 12")
    }
    
    
    func test_arrayWithOnlyOneNumberDetailWithUnits_deliversDetailSummary() {
        
        // given
        let activityDetailRecord = makeActivityDetailRecord(name: "Any", value: "12", units: "g", valueType: .number)
        let detailRecords: [ActivityDetailRecord] = [activityDetailRecord]
        
        // when/then
        XCTAssertEqual(detailRecords.summary(), "Any: 12 g")
    }
    
    
    func test_arrayWithOnlyOneStringDetail_deliversDetailSummary() {
        
        // given
        let activityDetailRecord = makeActivityDetailRecord(name: "Any", value: "Some string", units: nil, valueType: .text)
        let detailRecords: [ActivityDetailRecord] = [activityDetailRecord]
        
        // when/then
        XCTAssertEqual(detailRecords.summary(), "Any: Some string")
    }
    
    
    func test_arrayWithUnorderedTwoNumberDetails_deliversDetailSummaryInCorrectOrderWithGrammar() {
        
        // given
        let activityDetailRecordReorderedToBeFirst = makeActivityDetailRecord(name: "Any", value: "12", units: "g", valueType: .number)
        let activityDetailRecordReorderedToBeSecond = makeActivityDetailRecord(name: "Something", value: "14", units: "units", valueType: .number)
        
        let detailRecords: [ActivityDetailRecord] = [
            activityDetailRecordReorderedToBeSecond,
            activityDetailRecordReorderedToBeFirst
        ]
        
        // when/then
        XCTAssertEqual(detailRecords.summary(), "Any: 12 g, Something: 14 units")
    }
    
    
    func test_arrayWithUnorderedNumberDetailAndTextDetail_deliversDetailSummaryInCorrectOrderWithGrammar() {
        
        // given
        let activityDetailRecordReorderedToBeFirst = makeActivityDetailRecord(name: "Any", value: "Its not the coffee bean, its the cacao bean to watch out for", units: nil, valueType: .text)
        let activityDetailRecordReorderedToBeSecond = makeActivityDetailRecord(name: "Something", value: "14", units: "units", valueType: .number)
        
        let detailRecords: [ActivityDetailRecord] = [
            activityDetailRecordReorderedToBeSecond,
            activityDetailRecordReorderedToBeFirst
        ]
        
        // when/then
        XCTAssertEqual(detailRecords.summary(), "Something: 14 units, Any: Its not the coffee bean, its the cacao bean to watch out for")
    }
    
    
    func test_arrayWithUnorderedTextDetails_deliversDetailSummaryInCorrectOrderWithGrammar() {
        
        // given
        let activityDetailRecordReorderedToBeFirst = makeActivityDetailRecord(name: "Any", value: "Its not the coffee bean, its the cacao bean to watch out for", units: nil, valueType: .text)
        let activityDetailRecordReorderedToBeSecond = makeActivityDetailRecord(name: "Something", value: "I challenge you to a duel of wits!", units: nil, valueType: .text)
        
        let detailRecords: [ActivityDetailRecord] = [
            activityDetailRecordReorderedToBeSecond,
            activityDetailRecordReorderedToBeFirst
        ]
        
        // when/then
        XCTAssertEqual(detailRecords.summary(), "Any: Its not the coffee bean, its the cacao bean to watch out for, Something: I challenge you to a duel of wits!")
    }
    
    func test_textWithNoValue_deliversDetailSummaryWithDash() {
        
        // given
        let activityDetailRecordReorderedToBeFirst = makeActivityDetailRecord(name: "Any", value: "", units: nil, valueType: .text)
        
        let detailRecords: [ActivityDetailRecord] = [
            activityDetailRecordReorderedToBeFirst
        ]
        
        // when/then
        XCTAssertEqual(detailRecords.summary(), "Any: N/A")
    }
    
    
    
    // MARK: Helpers
    func makeActivityDetailRecord(name: String, value: String, units: String?, valueType: ActivityDetailType) -> ActivityDetailRecord {
        
        let activityDetail = ActivityDetail(id: UUID().uuidString, name: name, availableUnits: units, isArchived: false, creationDate: Date(), calculationType: .sum, valueType: valueType)
        
        let activityDetailRecord = ActivityDetailRecord(value: value, unit: nil, activityDetail: activityDetail)
        
        return activityDetailRecord
    }
}
