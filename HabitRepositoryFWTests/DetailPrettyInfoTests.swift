//
//  DetailPrettyInfoTests.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/15/25.
//



import XCTest
@testable import HabitRepositoryFW





class DetailPrettyInfoTests: XCTestCase {
    
    func test_prettyUnits_textWithoutUnits_deliversEmptyString() {
        
        // given
        let activityDetail = makeActivityDetail(name: "Any", units: nil, valueType: .text, calculationType: .sum)
        
        // when/then
        XCTAssertEqual(activityDetail.prettyUnits(), "")
    }
    
    
    func test_prettyUnits_numberWithoutUnits_deliversEmptyString() {
        
        // given
        let activityDetail = makeActivityDetail(name: "Any", units: nil, valueType: .number, calculationType: .sum)
        
        // when/then
        XCTAssertEqual(activityDetail.prettyUnits(), "")
    }
    
    
    func test_prettyUnits_textWithUnits_deliversEmptyString() {
        
        // given
        let activityDetail = makeActivityDetail(name: "Any", units: "shouldn't be here", valueType: .text, calculationType: .sum)
        
        // when/then
        XCTAssertEqual(activityDetail.prettyUnits(), "")
    }
    
    
    func test_prettyUnits_numberWithUnits_deliversFormattedUnits() {
        
        // given
        let activityDetail = makeActivityDetail(name: "Any", units: "g", valueType: .number, calculationType: .sum)
        
        // when/then
        XCTAssertEqual(activityDetail.prettyUnits(), "in g")
    }
    
    
    // MARK: Helpers
    func makeActivityDetail(name: String, units: String?, valueType: ActivityDetailType, calculationType: ActivityDetailCalculationType) -> ActivityDetail {
        
        return ActivityDetail(id: UUID().uuidString, name: name, availableUnits: units, isArchived: false, creationDate: Date(), calculationType: calculationType, valueType: valueType)
    }
}
