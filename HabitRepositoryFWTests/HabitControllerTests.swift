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


actor BlockHabitRepositorySpy: BlockHabitRepository {
    
    enum ReceivedMessage: Equatable {
        case createHabit
        case readAllNonarchivedHabits
        case updateHabit
        case deleteHabit
        
        case createHabitRecord
        case readAllHabitRecords
        case updateHabitRecord
        case deleteHabitRecord
    }
    
    private(set) var requests = [ReceivedMessage]()
    
    
    // MARK: HabitStore
    func createHabit(_ habit: Habit) async throws {
        requests.append(.createHabit)
    }
    
    func readAllNonarchivedHabits() async throws -> [Habit] {
        requests.append(.readAllNonarchivedHabits)
        print("Read")
        return []
    }
    
    func updateHabit(id: String, with habit: Habit) async throws {
        requests.append(.updateHabit)
    }
    
    func destroyHabit(_ habit: Habit) async throws {
        requests.append(.deleteHabit)
    }
    
    
    // MARK: HabitRecordStore
    func createHabitRecord(_ habitRecord: HabitRepositoryFW.HabitRecord) async throws {
        requests.append(.createHabitRecord)
    }
    
    func readAllHabitRecords() async throws -> [HabitRepositoryFW.HabitRecord] {
        requests.append(.readAllHabitRecords)
        return []
    }
    
    func updateHabitRecord(id: String, with habitRecord: HabitRepositoryFW.HabitRecord) async throws {
        requests.append(.updateHabitRecord)
    }
    
    func destroyHabitRecord(_ habitRecord: HabitRepositoryFW.HabitRecord) async throws {
        requests.append(.deleteHabitRecord)
    }
}


import Combine

class HabitController {
    
    let blockHabitRepository: BlockHabitRepository
    
    let isCompletedHabits = CurrentValueSubject<[IsCompletedHabit], Never>([])
    let habitRecordsForDay = CurrentValueSubject<[Date: [HabitRecord]], Never>([:])
    
    
    init(blockHabitRepository: BlockHabitRepository) async {
        
        self.blockHabitRepository = blockHabitRepository
        
        await populateHabits()
        await populateHabitRecordsForDay()
    }
    
    private func populateHabits() async {
        let _ = try? await blockHabitRepository.readAllNonarchivedHabits()
    }
    
    private func populateHabitRecordsForDay() async {
        let _ = try? await blockHabitRepository.readAllHabitRecords()
    }
}



class HabitControllerTests: XCTestCase {
    
    // MARK: Init
    // Ensure that when initialized, the controller will fetch the latest data to populate in-memory
    func test_init_makesRequestsToReadFromStore() async {
        
        // given/when
        let repositorySpy = BlockHabitRepositorySpy()
        let _ = await HabitController(blockHabitRepository: repositorySpy)
            
        // then
        let requests = await repositorySpy.requests
        XCTAssertEqual(requests, [.readAllNonarchivedHabits, .readAllHabitRecords])
    }
    
    
    
    
    
    // Test to make sure only habits that are not archived are retrieved
    
    
}


