//
//  HabitMenuDataSourceTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 4/29/24.
//

import XCTest
@testable import HabitRepositoryFW
import Combine
import CoreData



class HabitMenuDataSourceTests: XCTestCase {
    
    // test initialize habitmenu datasource for a day with no habits inside should return no habits
    func test_initWithNothingInCache_deliversEmptyArray() async {
        
        // given
        let (sut, _) = makeSUT()
        
        // when
        var cancellables = Set<AnyCancellable>()
        let exp = expectation(description: "waiting for habit menu items")
        
        var receivedHabitsForDay = [[IsCompletedHabit]]()
        
        sut.habitsForDayPublisher
            .sink { isCompletedHabits in
            
                receivedHabitsForDay.append(isCompletedHabits)
                exp.fulfill()
            }.store(in: &cancellables)
        
        // then
        await fulfillment(of: [exp])
        XCTAssertEqual(receivedHabitsForDay, [[]])
    }
    
    
    func test_initWithOneHabitWithNoRecordsInCache_deliversOneIncompleteHabit() async {
        
        // given
        let (sut, store) = makeSUT()
        let someHabit = anyHabit()
        let expectedHabitsForDay = [IsCompletedHabit(habit: someHabit, isCompleted: false)]
        
        // when
        do {
            try await store.create(someHabit)
        } catch {
            XCTFail("\(error as NSError)")
        }
        
        var cancellables = Set<AnyCancellable>()
        let exp = expectation(description: "waiting for habit menu items")
        
        var receivedHabitsForDay = [[IsCompletedHabit]]()
        
        sut.habitsForDayPublisher
            .sink { isCompletedHabits in
            
                receivedHabitsForDay.append(isCompletedHabits)
                exp.fulfill()
            }.store(in: &cancellables)
        
        // then
        await fulfillment(of: [exp])
        XCTAssertEqual(receivedHabitsForDay, [expectedHabitsForDay])
        
    }
    
    
    func test_createNewHabit_deliversNewHabitInArray() async {
        
        // given
        let (sut, store) = makeSUT()
        let someHabit = anyHabit(name: "habit 1")
        let someHabit2 = anyHabit(name: "habit 2")
        let expectedHabitsForDay = [IsCompletedHabit(habit: someHabit, isCompleted: false)]
        let expectedHabitsForDay2 = [IsCompletedHabit(habit: someHabit, isCompleted: false), IsCompletedHabit(habit: someHabit2, isCompleted: false)]
        
        // when
        do {
            try await store.create(someHabit)
        } catch {
            XCTFail("\(error as NSError)")
        }
        
        var cancellables = Set<AnyCancellable>()
        let exp = expectation(description: "waiting for habit menu items")
        exp.expectedFulfillmentCount = 2
        
        var receivedHabitsForDay = [[IsCompletedHabit]]()
        
        sut.habitsForDayPublisher
            .sink { isCompletedHabits in
            
                receivedHabitsForDay.append(isCompletedHabits)
                exp.fulfill()
            }.store(in: &cancellables)
        
        // when
        do {
            try await store.create(someHabit2)
        } catch {
            XCTFail("\(error as NSError)")
        }
        
        // then
        await fulfillment(of: [exp])
        XCTAssertEqual(receivedHabitsForDay, [expectedHabitsForDay, expectedHabitsForDay2])
    }
    
    
//    func test_reachHabitCompletionGoal_deliversCompletedHabit() async {
//        
//        // given
//        let selectedDay = Date().adding(days: -1) // A specific date
//        let (sut, store) = makeSUT(selectedDay: selectedDay)
//        let someHabit = anyHabit(goalCompletionsPerDay: 1)
//        let expectedHabitsForDay = [IsCompletedHabit(habit: someHabit, isCompleted: false)]
//        let expectedHabitsForDay2 = [IsCompletedHabit(habit: someHabit, isCompleted: true)]
//        
//        do {
//            try await store.create(someHabit)
//        } catch {
//            XCTFail("\(error as NSError)")
//        }
//        
//        var cancellables = Set<AnyCancellable>()
//        let exp = expectation(description: "waiting for habit menu items")
//        exp.expectedFulfillmentCount = 2
//        
//        var receivedHabitsForDay = [[IsCompletedHabit]]()
//        
//        sut.habitsForDayPublisher
//            .sink { isCompletedHabits in
//            
//                receivedHabitsForDay.append(isCompletedHabits)
//                exp.fulfill()
//            }.store(in: &cancellables)
//        
//        // when
//        let habitRecord = HabitRecord(id: UUID().uuidString, creationDate: selectedDay, completionDate: selectedDay, activityDetailRecords: [], habit: someHabit)
//        do {
//            try await store.create(habitRecord)
//        } catch {
//            XCTFail("\(error as NSError)")
//        }
//        
//        // then
//        await fulfillment(of: [exp])
//        XCTAssertEqual(receivedHabitsForDay, [expectedHabitsForDay, expectedHabitsForDay2])
//    }
    
    
    // TODO: Test when the completion goal is updated while there is a record in there
    // TODO: Test removing a record will make sure that the right thing is still completed
    
    
    /// Input with specific date if work needs to be tested with inserting records since this is date-specific
    private func makeSUT(selectedDay: Date = Date(), file: StaticString = #file, line: UInt = #line) -> (dataSource: HabitMenuDataSourceFRCAdapter, store: CoreDataBlockHabitStore) {
        
        let storeURL = URL(fileURLWithPath: "/dev/null") // specificTestStoreURL()
        let bundle = Bundle(for: CoreDataBlockHabitStore.self)
        let blockHabitStore = try! CoreDataBlockHabitStore(storeURL: storeURL, bundle: bundle)
//        let localRoutineRepository = LocalRoutineRepository(routineStore: routineStore)
//        trackForMemoryLeaks(routineStore)
//        trackForMemoryLeaks(localRoutineRepository)
        
        let frc = NSFetchedResultsController(
            fetchRequest: ManagedHabit.habitsMenuRequest(),
            managedObjectContext: blockHabitStore.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        let getHabitRecordsForDay: (Date) async throws -> [ManagedHabitRecord] = { selectedDay in
            return try await blockHabitStore.readManagedHabitRecords(for: selectedDay)
        }
        
        let habitsMenuPublisher = HabitMenuDataSourceFRCAdapter(frc: frc, selectedDay: selectedDay, getHabitRecordsForDay: getHabitRecordsForDay)
        
        return (habitsMenuPublisher, blockHabitStore)
    }
    
    
    
    private func specificTestStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    
    private func anyHabit(name: String = "Mood", goalCompletionsPerDay: Int = 0)-> Habit {
        let uuid = UUID().uuidString
        return Habit(
            id: uuid,
            name: name,
            creationDate: Date(),
            isArchived: false,
            goalCompletionsPerDay:
                goalCompletionsPerDay,
            color: "#ffffff",
            activityDetails: [],
            // Dummy for now
            schedulingUnits: .daily,
            rate: 1,
            scheduledWeekDays: [],
            reminderTime: nil
        )
    }
    
    
    // have a habit datasource
    // create habit updates habits list
    // 
    
    
    // datasource needs to be initialized with some date
    // datasource
}

