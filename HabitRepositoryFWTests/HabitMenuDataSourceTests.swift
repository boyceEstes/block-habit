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
}


// Is this just trying to test AnyPublisher? - it is we aren't actually testing anything attached to it. This might be pointless

class HabitMenuDataSourceSpy: HabitMenuDataSource {
    
    var habitsForDayPublisher: AnyPublisher<[IsCompletedHabit], Never>
    private var habitsForDay: CurrentValueSubject<[IsCompletedHabit], Never>
    
    init(habits: [IsCompletedHabit] = []) {
        self.habitsForDay = CurrentValueSubject(habits)
        self.habitsForDayPublisher = habitsForDay.eraseToAnyPublisher()
    }
}

/// Use in order to find the habits that are available for the given date
/// `NSFetchedResultsController` retrieves ALL habits
/// `selectedDay` will be used to determined if the habits are completed for the habit records done at that time

class HabitMenuDataSourceFRCAdapter: NSObject, HabitMenuDataSource {
    
    var habitsForDayPublisher: AnyPublisher<[IsCompletedHabit], Never>
    
    private var habitsForDaySubject = CurrentValueSubject<[IsCompletedHabit], Never>([])
    
    private let frc: NSFetchedResultsController<ManagedHabit>
    
    
    init(
        frc: NSFetchedResultsController<ManagedHabit>
    ) {
        self.frc = frc
        self.habitsForDayPublisher = habitsForDaySubject.eraseToAnyPublisher()
        
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
        let isCompletedHabits = habits.map {
            IsCompletedHabit(habit: $0, isCompleted: false)
        }
        habitsForDaySubject.send(isCompletedHabits)
    }
}


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
        let someHabit = anyHabit
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
        let someHabit = anyHabit
        let someHabit2 = anyHabit
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
        
        do {
            try await store.create(someHabit2)
        } catch {
            XCTFail("\(error as NSError)")
        }
        
        // then
        await fulfillment(of: [exp])
        XCTAssertEqual(receivedHabitsForDay, [expectedHabitsForDay, expectedHabitsForDay2])
    }
    
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (dataSource: HabitMenuDataSourceFRCAdapter, store: CoreDataBlockHabitStore) {
        
        
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
        
        let habitsMenuPublisher = HabitMenuDataSourceFRCAdapter(frc: frc)
        
        return (habitsMenuPublisher, blockHabitStore)
    }
    
    private func specificTestStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    
    private var anyHabit: Habit {
        let uuid = UUID().uuidString
        return Habit(id: uuid, name: "\(uuid)", isArchived: false, goalCompletionsPerDay: 0, color: "#ffffff", activityDetails: [])
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

