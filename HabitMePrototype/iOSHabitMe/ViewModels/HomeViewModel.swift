//
//  HomeViewModel.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation
import Combine


@Observable
final class HomeViewModel {
    
    let blockHabitStore: CoreDataBlockHabitStore
    let habitDataSource: HabitDataSource
    
    var cancellables = Set<AnyCancellable>()
    var habits = [Habit]() {
        didSet {
            print("didSet habits - count: \(habits.count)")
        }
    }
    
    
    init(blockHabitStore: CoreDataBlockHabitStore) {
        
        self.blockHabitStore = blockHabitStore
        habitDataSource = blockHabitStore.habitDataSource()
        
        bindHabitDataSource()
    }
    
    
    private func bindHabitDataSource() {
        
        habitDataSource
            .habits
            .sink { error in
                fatalError("THERES BEEN A HORRIBLE CRASH INVOLVING '\(error)' - prosecute to the highest degree of the law.")
            } receiveValue: { habits in
                self.habits = habits
            }
            .store(in: &cancellables)

    }
}
