//
//  DetailRecordsSummaryTests.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/14/25.
//


import XCTest
@testable import HabitRepositoryFW

extension Array where Element == ActivityDetailRecord {
    
    func bjSort() -> [ActivityDetailRecord] {
        
        // Step 1: Extract all the activity details and sort them using your custom method
        let sortedDetails = Set(self.map { $0.activityDetail }).bjSort()
        
        // Step 2: Create a dictionary to store the sorted position of each detail for quick lookup
        let positionMap = Dictionary(uniqueKeysWithValues: sortedDetails.enumerated().map { ($1, $0) })
        
        // Step 3: Sort the records using the precomputed positions
        return self.sorted {
            positionMap[$0.activityDetail, default: Int.max] < positionMap[$1.activityDetail, default: Int.max]
        }
    }
    
    
    func summary() -> String {
        
        let sortedActivityDetailRecords = self.bjSort()
        
        // We want to sort everything the same way...
        // Numbers first, then Notes
        // For multiples of Numbers or Strings - sort in alphabetical order
        var summary: String = ""
        
        for i in 0..<sortedActivityDetailRecords.count {
            let label = sortedActivityDetailRecords[i].activityDetail.name
            let units = sortedActivityDetailRecords[i].activityDetail.availableUnits
            let value = sortedActivityDetailRecords[i].value
            
            if i != sortedActivityDetailRecords.count - 1 {
                // If we are not at the last index, append with ", " to prep for next one
                summary += "\(label): \(value)\(units != nil ? " \(units!)" : ""), "
            } else {
                summary += "\(label): \(value)\(units != nil ? " \(units!)" : "")"
            }
        }
        
        return summary
    }
}

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
    
    
    
    // MARK: Helpers
    func makeActivityDetailRecord(name: String, value: String, units: String?, valueType: ActivityDetailType) -> ActivityDetailRecord {
        
        let activityDetail = ActivityDetail(id: UUID().uuidString, name: name, availableUnits: units, isArchived: false, creationDate: Date(), calculationType: .sum, valueType: valueType)
        
        let activityDetailRecord = ActivityDetailRecord(value: value, unit: nil, activityDetail: activityDetail)
        
        return activityDetailRecord
    }
}
