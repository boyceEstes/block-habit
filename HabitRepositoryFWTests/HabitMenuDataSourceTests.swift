//
//  HabitMenuDataSourceTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 4/29/24.
//

import XCTest
import HabitRepositoryFW


import Combine
import CoreData

protocol HabitMenuDataSource {
    
    var habitsForDayPublisher: AnyPublisher<[IsCompletedHabit], Never> { get }
    
    /// Required to selected the records for today, to judge if the completion goal is complete
    var selectedDayPublisher: CurrentValueSubject<Date, Never> { get }
    
//    func getHabitRecordsForDay(selectedDay: Date) async throws -> [ManagedHabitRecord]
}


/// Use in order to find the habits that are available for the given date
/// `NSFetchedResultsController` retrieves ALL habits
/// `selectedDay` will be used to determined if the habits are completed for the habit records done at that time

class HabitMenuDataSourceFRCAdapter: NSObject, HabitMenuDataSource {
    
    var habitsForDayPublisher: AnyPublisher<[IsCompletedHabit], Never>
    
    private var habitsPublisher = CurrentValueSubject<[Habit], Never>([])
    var selectedDayPublisher: CurrentValueSubject<Date, Never>
    private let frc: NSFetchedResultsController<ManagedHabit>
    
    init(
        frc: NSFetchedResultsController<ManagedHabit>,
        selectedDay: Date,
        getHabitRecordsForDay: @escaping (Date) async throws -> [ManagedHabitRecord]
    ) {
        self.frc = frc
        self.selectedDayPublisher = CurrentValueSubject(selectedDay)
        self.habitsForDayPublisher = habitsPublisher.combineLatest(selectedDayPublisher)
            .asyncMap({ habits, selectedDay in
                
                // Make a call to get habit records
                guard let habitRecordsForDay = try? await getHabitRecordsForDay(selectedDay) else {
                    fatalError() // FIXME: Handle this error - can I test this somehow
                }
                
                // After we get habit records - check to see if the completion goal of any of them changed
                var isCompletedHabits = [IsCompletedHabit]()
                var isIncompletedHabits = [IsCompletedHabit]()
                
                for habit in habits {
                    
                    guard let completeGoalForHabit = habit.goalCompletionsPerDay, completeGoalForHabit !=  0 else {
                        isIncompletedHabits.append(IsCompletedHabit(habit: habit, isCompleted: false))
                        continue
                    }
                    
                    // get all the records for this particular habit
                    let numberOfRecordsForHabit = habitRecordsForDay.filter { $0.habit?.id == habit.id }.count
                    
                    let isCompleted = numberOfRecordsForHabit >= completeGoalForHabit
                    
                    if isCompleted {
                        isCompletedHabits.append(IsCompletedHabit(habit: habit, isCompleted: isCompleted))
                    } else {
                        isIncompletedHabits.append(IsCompletedHabit(habit: habit, isCompleted: isCompleted))
                    }
//                    guard let completionGoalForHabit = habit.goalCompletionsPerDay else {
//                        isIncompletedHabits.append(IsCompletedHabit(habit: habit, isCompleted: false))
//                        continue
//                    }
//                    
//                    let habitRecordsForDayForHabit = habitRecordsForDay.filter {
//                        $0.habit?.id == habit.id
//                    }.count
//                    
//                    let isCompleted = habitRecordsForDayForHabit >= completionGoalForHabit
//                    
//                    let isCompletedHabit = IsCompletedHabit(habit: habit, isCompleted: isCompleted)
//                    
//                    if isCompleted {
//                        isCompletedHabits.append(isCompletedHabit)
//                    } else {
//                        isIncompletedHabits.append(isCompletedHabit)
//                    }
                }
                
                return isIncompletedHabits + isCompletedHabits
            })
            .eraseToAnyPublisher()
        
        super.init()
        
        self.setupFRC()
    }
    
    
    private func setupFRC() {
        
        frc.delegate = self
        performFetch()
    }
    
    
    private func performFetch() {
        
        do {
            try frc.performFetch()
            try updateWithLatestValues()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    private func updateWithLatestValues() throws {
        
        let managedHabits = frc.fetchedObjects ?? []
        let habits = try managedHabits.toModel()
        
        habitsPublisher.send(habits)
    }
}

// When there is a habit record that is done
// Check the habit records that have been done for the day
// Calculate if this is one of those habits


extension HabitMenuDataSourceFRCAdapter: NSFetchedResultsControllerDelegate {
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        try? updateWithLatestValues()
    }
}


extension ManagedHabit {
    
    class func habitsMenuRequest() -> NSFetchRequest<ManagedHabit> {
        
        let request = ManagedHabit.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ManagedHabit.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}



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
    
    
    func test_reachHabitCompletionGoal_deliversCompletedHabit() async {
        
        // given
        let selectedDay = Date().adding(days: -1) // A specific date
        let (sut, store) = makeSUT(selectedDay: selectedDay)
        let someHabit = anyHabit(goalCompletionsPerDay: 1)
        let expectedHabitsForDay = [IsCompletedHabit(habit: someHabit, isCompleted: false)]
        let expectedHabitsForDay2 = [IsCompletedHabit(habit: someHabit, isCompleted: true)]
        
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
        let habitRecord = HabitRecord(id: UUID().uuidString, creationDate: selectedDay, completionDate: selectedDay, activityDetailRecords: [], habit: someHabit)
        do {
            try await store.create(habitRecord)
        } catch {
            XCTFail("\(error as NSError)")
        }
        
        // then
        await fulfillment(of: [exp])
        XCTAssertEqual(receivedHabitsForDay, [expectedHabitsForDay, expectedHabitsForDay2])
    }
    
    
    
    
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
        return Habit(id: uuid, name: name, isArchived: false, goalCompletionsPerDay: goalCompletionsPerDay, color: "#ffffff", activityDetails: [])
    }
    
    
//    func test_init_oneHabitAvailable_deliversOneIsCompletedHabit() {
//
//        let anyHabit = Habit(id: UUID().uuidString, name: "Mood", isArchived: false, goalCompletionsPerDay: 0, color: "#ffffff", activityDetails: [])
//        let anyIsCompletedHabit = IsCompletedHabit(habit: anyHabit, isCompleted: false)
//        
//        let isCompletedHabits = [anyIsCompletedHabit]
//        
//        let sut = HabitMenuDataSourceFRCAdapter(habits: isCompletedHabits)
//        
//        
//        let exp = expectation(description: "Wait for initial habits")
//        var cancellables = Set<AnyCancellable>()
//        
//        
//        var initialHabitsForDay = [IsCompletedHabit]()
//        
//        sut.habitsForDayPublisher
//            .sink { isCompletedHabits in
//            
//                initialHabitsForDay = isCompletedHabits
//                exp.fulfill()
//            }.store(in: &cancellables)
//        
//        // when/then
//        waitForExpectations(timeout: 1)
//        XCTAssertEqual(initialHabitsForDay, isCompletedHabits)
//    }
    
    
    // have a habit datasource
    // create habit updates habits list
    // 
    
    
    // datasource needs to be initialized with some date
    // datasource
}

