//
//  HabitControllerTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 5/1/24.
//

import Foundation
import XCTest
import HabitRepositoryFW



/// Used as a boundary to allow us to replace our CoreDataHabitStore with some other mechanism for saving/retrieving data
protocol HabitStore {
    
    func createHabit(_ habit: Habit) async throws
    func readAllNonarchivedHabits() async throws -> [Habit]
    func updateHabit(id: String, with habit: Habit) async throws
    func destroyHabit(_ habit: Habit) async throws
}


protocol HabitRecordStore {
    
    func createHabitRecord(_ habitRecord: HabitRecord) async throws
    func readAllHabitRecords() async throws -> [HabitRecord]
    func updateHabitRecord(id: String, with habitRecord: HabitRecord) async throws
    func destroyHabitRecord(_ habitRecord: HabitRecord) async throws
}


protocol BlockHabitRepository: HabitStore, HabitRecordStore { }



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

class HabitController {
    
    let blockHabitRepository: BlockHabitRepository
    
    private let isCompletedHabits = CurrentValueSubject<[IsCompletedHabit], Never>([])
    let habitRecordsForDay = CurrentValueSubject<[Date: [HabitRecord]], Never>([:])
    let selectedDay: CurrentValueSubject<Date, Never>
    
    var completeHabits: AnyPublisher<[Habit], Never> {
        isCompletedHabits.map { isCompletedHabits in
            return isCompletedHabits.filter { $0.isCompleted == true }.map { $0.habit }
        }.eraseToAnyPublisher()
    }
    
    var incompleteHabits: AnyPublisher<[Habit], Never> {
        
        isCompletedHabits.map { isCompletedHabits in
            return isCompletedHabits.filter { $0.isCompleted == false }.map { $0.habit }
        }.eraseToAnyPublisher()
    }
    
    init(blockHabitRepository: BlockHabitRepository, selectedDay: Date) async {
        
        self.blockHabitRepository = blockHabitRepository
        self.selectedDay = CurrentValueSubject(selectedDay)
        
        await populateHabitRecordsForDay()
        await populateHabits()
    }
    
    
    /// This must be done first in order to have the information to successfully organize the completed habits
    private func populateHabitRecordsForDay() async {
        let _ = try? await blockHabitRepository.readAllHabitRecords()
    }
    
    
    private func populateHabits() async {
        
        let nonarchivedHabits = try? await blockHabitRepository.readAllNonarchivedHabits()
    }
}



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
        let selectedDay = oneDayAgo
        let (sut, _) = await makeSUTWithStubbedRepository(selectedDay: selectedDay)
        
        // then
        XCTAssertEqual(sut.selectedDay.value, selectedDay)
    }
    
    
    func test_initWithHabitsAndHabitRecords_populatesTheControllerAsExpected() async {
        
        let (sut, _) = await makeSUTWithStubbedRepository()
        
        let expectedCompleteHabitsForOneDayAgo = [nonArchivedOneGoal]
        let expectedIncompleteHabitsForOneDayAgo = [nonArchivedTwoGoal, nonArchivedZeroGoal]
        let expectedHabitRecordsPerDays = [oneDayAgo: [habitRecord1, habitRecord2, habitRecord3], twoDaysAgo: [habitRecord4, habitRecord5, habitRecord6, habitRecord7, habitRecord8]]
        
        var receivedCompleteHabitsForOneDayAgo = [Habit]()
        var receivedIncompleteHabitsForOneDayAgo = [Habit]()
        var receivedHabitRecordsPerDays = [Date: [HabitRecord]]()
        
        var cancellables = Set<AnyCancellable>()
        
        let expCompletedHabits = expectation(description: "Wait for completed habits")
        let expIncompleteHabits = expectation(description: "Wait for incomplete habits")
        let expRecords = expectation(description: "Wait for records")
        
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
        
        sut.habitRecordsForDay
            .sink { habitRecordsForDate in
                
                receivedHabitRecordsPerDays = habitRecordsForDate
                expRecords.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expCompletedHabits, expIncompleteHabits, expRecords], timeout: 1)
        
        XCTAssertEqual(receivedCompleteHabitsForOneDayAgo, expectedCompleteHabitsForOneDayAgo)
        XCTAssertEqual(receivedIncompleteHabitsForOneDayAgo, expectedIncompleteHabitsForOneDayAgo)
        XCTAssertEqual(receivedHabitRecordsPerDays, expectedHabitRecordsPerDays)
    }
    
    
    // Test to make sure only habits that are not archived are retrieved
    
    private func makeSUTWithStubbedRepository(selectedDay: Date = Date()) async -> (HabitController, BlockHabitRepositoryMultipleHabitsAndRecordsStub) {
        
        
        
        let stubHabits = [
            archivedOneGoal,
            nonArchivedZeroGoal,
            nonArchivedOneGoal,
            nonArchivedTwoGoal
        ]
        
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
    
    var oneDayAgo: Date { Date().adding(days: -1) }
    var twoDaysAgo: Date { Date().adding(days: -2) }
    
    var habitRecord1: HabitRecord { HabitRecord.habitRecord(date: oneDayAgo, habit: nonArchivedOneGoal) }
    var habitRecord2: HabitRecord { HabitRecord.habitRecord(date: oneDayAgo, habit: nonArchivedTwoGoal) }
    var habitRecord3: HabitRecord { HabitRecord.habitRecord(date: oneDayAgo, habit: nonArchivedZeroGoal) }
    
    var habitRecord4: HabitRecord { HabitRecord.habitRecord(date: twoDaysAgo, habit: nonArchivedOneGoal) }
    var habitRecord5: HabitRecord { HabitRecord.habitRecord(date: twoDaysAgo, habit: nonArchivedTwoGoal) }
    var habitRecord6: HabitRecord { HabitRecord.habitRecord(date: twoDaysAgo, habit: nonArchivedTwoGoal) }
    var habitRecord7: HabitRecord { HabitRecord.habitRecord(date: twoDaysAgo, habit: nonArchivedZeroGoal) }
    var habitRecord8: HabitRecord { HabitRecord.habitRecord(date: twoDaysAgo, habit: archivedOneGoal) }
}


