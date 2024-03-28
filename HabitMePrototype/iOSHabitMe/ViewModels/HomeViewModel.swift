//
//  HomeViewModel.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation
import Combine


@Observable
final class HomeViewModel: ActivityRecordCreatorOrNavigator {
    
    let blockHabitStore: CoreDataBlockHabitStore
    let habitDataSource: HabitDataSource // Can get updated when selectedDate changes
    
    var selectedDay: Date
    
    var goToCreateActivityRecordWithDetails: (Habit, Date) -> Void
    var habits = [Habit]() {
        didSet {
            print("didSet habits - count: \(habits.count)")
            for habit in habits {
                print("activityDetails - count: \(habit.activityDetails.count)")
            }
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(
        blockHabitStore: CoreDataBlockHabitStore,
        goToCreateActivityRecordWithDetails: @escaping (Habit, Date) -> Void
    ) {
        
        let today = Date().noon!
        
        self.blockHabitStore = blockHabitStore
        self.habitDataSource = blockHabitStore.habitDataSource(selectedDay: today)
        self.selectedDay = today
        self.goToCreateActivityRecordWithDetails = goToCreateActivityRecordWithDetails
        
        bindHabitDataSource()
    }
    
    
    private func bindSelectedDay() {
        
        /**
         * When this changes, we want to update the HabitDataSource so that it gets only the habits for today
         * This requires us to rebind the HabitDataSource so if any edits to the habits take place, we will see
         * the updates without needing to do anything else
         */
//        selectedDay
    }
    
    
    private func bindHabitDataSource() {
        
        habitDataSource
            .habits
            .sink { error in
                fatalError("THERES BEEN A HORRIBLE CRASH INVOLVING '\(error)' - prosecute to the highest degree of the law.")
            } receiveValue: { habits in
                print("BOYCE: habit data source reloaded")
                self.habits = habits
            }
            .store(in: &cancellables)
    }
    
    
    func createHabitRecord(for habit: Habit) {
        
        Task {
            do {
                try await createRecord(for: habit, in: blockHabitStore)
            } catch {
                // FIXME: Handle Error in View
                fatalError("ERROR OH NO - BURN IT ALL DOWN")
            }
        }
    }
    
    
    func archiveHabit(for habit: Habit) {
        
        Task {
            do {
                print("archiving \(habit.id) - \(habit.name)")
                try await blockHabitStore.archive(habit)
            } catch {
                // FIXME: Handle Error in View
                fatalError("ERROR OH NO - BURN IT ALL DOWN - '\(error.localizedDescription)'")
            }
        }
    }
    
    
    func destroyHabit(for habit: Habit) {
        
        Task {
            do {
                print("deleting \(habit.id) - \(habit.name)")
                try await blockHabitStore.destroy(habit)
            } catch {
                // FIXME: Handle Error in View
                fatalError("ERROR OH NO - BURN IT ALL DOWN - '\(error.localizedDescription)'")
            }
        }
    }
}
