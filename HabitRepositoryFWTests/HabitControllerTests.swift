//
//  HabitControllerTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 5/1/24.
//

import Foundation
import XCTest
import HabitRepositoryFW



extension Habit {
    
    static let archivedOneGoal = Habit(
        id: UUID().uuidString,
        name: "Mood",
        isArchived: true,
        goalCompletionsPerDay: 1,
        color: "#ffffff",
        activityDetails: []
    )
    static let nonArchivedZeroGoal = Habit(
        id: UUID().uuidString,
        name: "Water",
        isArchived: false,
        goalCompletionsPerDay: 0,
        color: "#ffffff",
        activityDetails: []
    )
    static let nonArchivedOneGoal = Habit(
        id: UUID().uuidString,
        name: "Exercise",
        isArchived: false,
        goalCompletionsPerDay: 1,
        color: "#ffffff",
        activityDetails: []
    )
    static let nonArchivedTwoGoal = Habit(
        id: UUID().uuidString,
        name: "Exercise",
        isArchived: false,
        goalCompletionsPerDay: 2,
        color: "#ffffff",
        activityDetails: []
    )
}


extension HabitRecord {
    
    static func habitRecord(date: Date = Date(), habit: Habit) -> HabitRecord {
        HabitRecord(
            id: UUID().uuidString,
            creationDate: date,
            completionDate: date,
            activityDetailRecords: [],
            habit: habit
        )
    }
}


actor BlockHabitRepositoryMultipleHabitsAndRecordsStub: BlockHabitRepository {
    
    enum ReceivedMessage: Equatable {
//        case createHabit
        case readAllNonarchivedHabits
//        case updateHabit
//        case deleteHabit
        
//        case createHabitRecord
        case readAllHabitRecords
//        case updateHabitRecord
//        case deleteHabitRecord
    }
    
    
    let habits: [Habit]
    let records: [HabitRecord]
    
    private(set) var requests = [ReceivedMessage]()
    
    init(habits: [Habit], records: [HabitRecord]) {
        self.habits = habits
        self.records = records
    }
    /*
     * Setup:
     *
     * Everything is for the same day
     *
     * Archived Habits: 1
     * NonArchived Habits: 3
     *
     * Day -1
     * Complete Habits: 1
     * Incomplete Habits: 2
     * Total records: 3 (1 nonArchivedOneGoal, 1 nonarchivedTwoGoal, 1 nonArchivedZeroGoal)
     *
     * Day -2
     * Complete Habits: 2
     * Incomplete Habits: 1
     * Total records: 4 (1 nonArchivedOneGoal, 2 nonarchivedTwoGoal, 1 nonArchivedZeroGoal)
     *
     */

    func readAllNonarchivedHabits() async throws -> [HabitRepositoryFW.Habit] {
        requests.append(.readAllNonarchivedHabits)
        return habits
    }
    
    // records should never be returned for archived habits
    func readAllHabitRecords() async throws -> [HabitRepositoryFW.HabitRecord] {
        requests.append(.readAllHabitRecords)
        return records
    }
    
    
    // The following are not important because this stub is only concerned with tests in retrieving records.
    func createHabit(_ habit: HabitRepositoryFW.Habit) async throws {
        // Doesn't matter
    }
    
    func updateHabit(id: String, with habit: HabitRepositoryFW.Habit) async throws {
        // Doesn't matter
    }
    
    func destroyHabit(_ habit: HabitRepositoryFW.Habit) async throws {
        // Doesn't matter
    }
    
    func createHabitRecord(_ habitRecord: HabitRepositoryFW.HabitRecord) async throws {
        // Doesn't matter
    }
    
    func updateHabitRecord(id: String, with habitRecord: HabitRepositoryFW.HabitRecord) async throws {
        // Doesn't matter
    }
    
    func destroyHabitRecord(_ habitRecord: HabitRepositoryFW.HabitRecord) async throws {
        // Don't need it
    }
}


import Combine



class HabitControllerTests: XCTestCase {
    
    // MARK: Init
    // Ensure that when initialized, the controller will fetch the latest data to populate in-memory
    func test_init_makesRequestsToReadFromStore() async {
        
        // given/when
        let (_, repository) = await makeSUTWithStubbedRepository()
        
        // then
        let requests = await repository.requests
        XCTAssertEqual(requests, [.readAllHabitRecords, .readAllNonarchivedHabits])
    }
    
    
    func test_initWithSelectedDay_matchesTheInitialSelectedDay() async {
        
        // given/when
        let selectedDay = someDay
        let (sut, _) = await makeSUTWithStubbedRepository(selectedDay: selectedDay)
        
        // then
        XCTAssertEqual(sut.selectedDay.value, selectedDay)
    }
    
    
    func test_initWithHabitRecordsInRepository_correctlyCalculatesRecordsForDates() async {
        
        // given/when
        let selectedDay = someDay
        let selectedDayNoon = someDay.noon!
        
        let selectedDayNoonsYesterday = selectedDayNoon.adding(days: -1)
        let selectedDayNoonsMinusTwo = selectedDayNoon.adding(days: -2)
        let selectedDayNoonsMinusThree = selectedDayNoon.adding(days: -3)
        let selectedDayNoonsMinusFour = selectedDayNoon.adding(days: -4)
        let selectedDayNoonsMinusFive = selectedDayNoon.adding(days: -5)
        let selectedDayNoonsMinusSix = selectedDayNoon.adding(days: -6)
        
        let habitRecord1 = HabitRecord.habitRecord(date: selectedDayNoon, habit: nonArchivedOneGoal)
        let habitRecord2 = HabitRecord.habitRecord(date: selectedDayNoon, habit: nonArchivedTwoGoal)
        let habitRecord3 = HabitRecord.habitRecord(date: selectedDayNoon, habit: nonArchivedZeroGoal)
        
        let habitRecord4 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: nonArchivedOneGoal)
        let habitRecord5 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: nonArchivedTwoGoal)
        let habitRecord6 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: nonArchivedTwoGoal)
        let habitRecord7 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: nonArchivedZeroGoal)
        let habitRecord8 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: archivedOneGoal)
        
        
        let stubRecords = [
            habitRecord1,
            habitRecord2,
            habitRecord3,
            habitRecord4,
            habitRecord5,
            habitRecord6,
            habitRecord7,
            habitRecord8
        ]
        
        let (sut, _) = await makeSUTWithStubbedRepository(selectedDay: selectedDay, stubRecords: stubRecords)

        
        let expectedHabitRecordsPerDays = [
            selectedDayNoon: [habitRecord1, habitRecord2, habitRecord3],
            selectedDayNoonsYesterday: [habitRecord4, habitRecord5, habitRecord6, habitRecord7, habitRecord8],
            selectedDayNoonsMinusTwo: [],
            selectedDayNoonsMinusThree: [],
            selectedDayNoonsMinusFour: [],
            selectedDayNoonsMinusFive: [],
            selectedDayNoonsMinusSix: []
        ]
        
        
        var receivedHabitRecordsPerDays = [Date: [HabitRecord]]()
        var cancellables = Set<AnyCancellable>()
        
        let expRecordsPerDays = expectation(description: "Wait for records")
        
        sut.habitRecordsForDay
            .sink { habitRecordsForDate in
                
                receivedHabitRecordsPerDays = habitRecordsForDate
                expRecordsPerDays.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expRecordsPerDays], timeout: 1)
        XCTAssertEqual(receivedHabitRecordsPerDays, expectedHabitRecordsPerDays)
    }
    
    
    func test_initWithHabitsAndRecords_populatesIsCompletedHabitsForTheSelectedDay() async {
        
        
        // given/when
        let selectedDayNoon = someDay.noon!
        
        let selectedDayNoonsYesterday = selectedDayNoon.adding(days: -1)
        
        let habitRecord1 = HabitRecord.habitRecord(date: selectedDayNoon, habit: nonArchivedOneGoal)
        let habitRecord2 = HabitRecord.habitRecord(date: selectedDayNoon, habit: nonArchivedTwoGoal)
        let habitRecord3 = HabitRecord.habitRecord(date: selectedDayNoon, habit: nonArchivedZeroGoal)
        
        // This shouldn't matter for this test, but it should be good to test to make sure that they don't matter
        let habitRecord4 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: nonArchivedOneGoal)
        let habitRecord5 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: nonArchivedTwoGoal)
        let habitRecord6 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: nonArchivedTwoGoal)
        let habitRecord7 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: nonArchivedZeroGoal)
        let habitRecord8 = HabitRecord.habitRecord(date: selectedDayNoonsYesterday, habit: archivedOneGoal)
        
        
        let stubRecords = [
            habitRecord1,
            habitRecord2,
            habitRecord3,
            habitRecord4,
            habitRecord5,
            habitRecord6,
            habitRecord7,
            habitRecord8
        ]
        
        let (sut, _) = await makeSUTWithStubbedRepository(selectedDay: selectedDayNoon, stubRecords: stubRecords)
        
        // given
        
        let expectedCompleteHabitsForOneDayAgo = [nonArchivedOneGoal]
        let expectedIncompleteHabitsForOneDayAgo = [nonArchivedTwoGoal, nonArchivedZeroGoal]

        var receivedCompleteHabitsForOneDayAgo = [Habit]()
        var receivedIncompleteHabitsForOneDayAgo = [Habit]()
        
        var cancellables = Set<AnyCancellable>()
        
        let expCompletedHabits = expectation(description: "Wait for completed habits")
        let expIncompleteHabits = expectation(description: "Wait for incomplete habits")
        
        sut.completeHabits
            .sink { completeHabits in
                
                receivedCompleteHabitsForOneDayAgo = completeHabits
                expCompletedHabits.fulfill()
            }
            .store(in: &cancellables)
        
        sut.incompleteHabits
            .sink { incompleteHabits in
                
                receivedIncompleteHabitsForOneDayAgo = incompleteHabits
                expIncompleteHabits.fulfill()
            }
            .store(in: &cancellables)
        
        
        await fulfillment(of: [expCompletedHabits, expIncompleteHabits], timeout: 1)
        
        XCTAssertEqual(receivedCompleteHabitsForOneDayAgo, expectedCompleteHabitsForOneDayAgo)
        XCTAssertEqual(receivedIncompleteHabitsForOneDayAgo, expectedIncompleteHabitsForOneDayAgo)
    }
    
    
    // Test to make sure only habits that are not archived are retrieved
    
    private func makeSUTWithStubbedRepository(selectedDay: Date = Date(), stubRecords: [HabitRecord] = []) async -> (HabitController, BlockHabitRepositoryMultipleHabitsAndRecordsStub) {
        
        
        
        let stubHabits = [
            archivedOneGoal,
            nonArchivedZeroGoal,
            nonArchivedOneGoal,
            nonArchivedTwoGoal
        ]
        
        /*
         * Setup:
         *
         * Everything is for the same day
         *
         * Archived Habits: 1 (archivedOneGoal)
         * NonArchived Habits: 3 (nonArchivedOneGoal, nonArchivedTwoGoal, nonArchivedZeroGoal)
         *
         * Day -1
         * Complete Habits: 1 (nonArchivedOneGoal)
         * Incomplete Habits: 2 (nonArchivedTwoGoal, nonArchivedZeroGoal)
         * Total records: 3 (1 nonArchivedOneGoal, 1 nonarchivedTwoGoal, 1 nonArchivedZeroGoal)
         *
         * Day -2
         * Complete Habits: 2
         * Incomplete Habits: 1
         * Total records: 5 (1 nonArchivedOneGoal, 2 nonarchivedTwoGoal, 1 nonArchivedZeroGoal, 1 archivedOneGoal)
         *
         */
        
        let multipleHabitsAndRecordsRepositoryStub = BlockHabitRepositoryMultipleHabitsAndRecordsStub(habits: stubHabits, records: stubRecords)
        
        let sut = await HabitController(blockHabitRepository: multipleHabitsAndRecordsRepositoryStub, selectedDay: selectedDay)
        
        return (sut, multipleHabitsAndRecordsRepositoryStub)
    }
    
    
    var archivedOneGoal: Habit { Habit.archivedOneGoal }
    var nonArchivedZeroGoal: Habit { Habit.nonArchivedZeroGoal }
    var nonArchivedOneGoal: Habit { Habit.nonArchivedOneGoal }
    var nonArchivedTwoGoal: Habit { Habit.nonArchivedTwoGoal }
    
    var someDay: Date { Date(timeIntervalSince1970: 1714674435) }
    var someDaysYesterday: Date { someDay.adding(days: -1) }
}


