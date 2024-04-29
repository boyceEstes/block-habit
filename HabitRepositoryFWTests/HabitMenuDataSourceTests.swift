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


class HabitMenuDataSourceFRCAdapter: HabitMenuDataSource {
    
    var habitsForDayPublisher: AnyPublisher<[IsCompletedHabit], Never>
    private var habitsForDay: CurrentValueSubject<[IsCompletedHabit], Never>
    
    
    init(habits: [IsCompletedHabit] = []) {
        self.habitsForDay = CurrentValueSubject(habits)
        self.habitsForDayPublisher = habitsForDay.eraseToAnyPublisher()
    }
}


class HabitMenuDataSourceTests: XCTestCase {
    
    // test initialize habitmenu datasource for a day with no habits inside should return no habits
    func test_init_noHabitsAvailable_deliversEmptyArray() {
        
        // given
        let sut = HabitMenuDataSourceFRCAdapter()
        let exp = expectation(description: "Wait for initial habits")
        var cancellables = Set<AnyCancellable>()
        
        var initialHabitsForDay = [IsCompletedHabit]()
        
        // when
        sut.habitsForDayPublisher
            .sink { isCompletedHabits in
            
                initialHabitsForDay = isCompletedHabits
                exp.fulfill()
            }.store(in: &cancellables)
        
        // then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(initialHabitsForDay, [])
    }
    
    
    func test_init_oneHabitAvailable_deliversOneIsCompletedHabit() {

        let anyHabit = Habit(id: UUID().uuidString, name: "Mood", isArchived: false, goalCompletionsPerDay: 0, color: "#ffffff", activityDetails: [])
        let anyIsCompletedHabit = IsCompletedHabit(habit: anyHabit, isCompleted: false)
        
        let isCompletedHabits = [anyIsCompletedHabit]
        
        let sut = HabitMenuDataSourceFRCAdapter(habits: isCompletedHabits)
        
        
        let exp = expectation(description: "Wait for initial habits")
        var cancellables = Set<AnyCancellable>()
        
        
        var initialHabitsForDay = [IsCompletedHabit]()
        
        sut.habitsForDayPublisher
            .sink { isCompletedHabits in
            
                initialHabitsForDay = isCompletedHabits
                exp.fulfill()
            }.store(in: &cancellables)
        
        // when/then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(initialHabitsForDay, isCompletedHabits)
    }
    
    
    // have a habit datasource
    // create habit updates habits list
    // 
    
    
    // datasource needs to be initialized with some date
    // datasource
}

