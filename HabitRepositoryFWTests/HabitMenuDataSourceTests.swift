//
//  HabitMenuDataSourceTests.swift
//  HabitRepositoryFWTests
//
//  Created by Boyce Estes on 4/29/24.
//

import XCTest
import HabitRepositoryFW



import Combine

protocol HabitMenuDataSource {
    
    var habitsForDayPublisher: AnyPublisher<[IsCompletedHabit], Never> { get }
}


class HabitMenuDataSourceSpy: HabitMenuDataSource {
    
    var habitsForDayPublisher: AnyPublisher<[IsCompletedHabit], Never>
    private var habitsForDay = CurrentValueSubject<[IsCompletedHabit], Never>([])
    
    init() {
        self.habitsForDayPublisher = habitsForDay.eraseToAnyPublisher()
    }
}


class HabitMenuDataSourceTests: XCTestCase {
    
    // test initialize habitmenu datasource for a day with no habits inside should return no habits
    func test_init_noHabitsAvailable_deliversEmptyArray() {
        
        // given
        let sut = HabitMenuDataSourceSpy()
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
        XCTAssertEqual(initialHabitsForDay, [])
    }
    
    // have a habit datasource
    // create habit updates habits list
    // 
    
    
    // datasource needs to be initialized with some date
    // datasource
}

