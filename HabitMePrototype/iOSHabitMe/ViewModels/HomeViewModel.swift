//
//  HomeViewModel.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation
import Combine


// FIXME: For some reason when we go to another day, the habitDataSource loads data twice - investigate if there is room for optimization


@Observable
final class HomeViewModel: ActivityRecordCreatorOrNavigator {
    
    let blockHabitStore: CoreDataBlockHabitStore
    var habitDataSource: HabitDataSource? // Can get updated when selectedDate changes
    var habitRecordDataSource: HabitRecordsByDateDataSource
    
    var selectedDay: Date {
        didSet(oldValue) {
            if oldValue != selectedDay {
                bindHabitDataSource()
            }
        }
    }
    
    var goToCreateActivityRecordWithDetails: (Habit, Date) -> Void
    var habits = [Habit]() {
        didSet {
            print("didSet habits - count: \(habits.count)")
            for habit in habits {
                print("activityDetails - count: \(habit.activityDetails.count)")
            }
        }
    }
    
    var datesWithHabitRecords: [Date: [HabitRecord]] = [:] {
        didSet {
            print("didSet habitRecords - count: \(datesWithHabitRecords.count)")
            print("habit records for today \(datesWithHabitRecords[selectedDay]?.count ?? -1)")
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    var habitDataSourceCancellable: AnyCancellable?
    
    
    init(
        blockHabitStore: CoreDataBlockHabitStore,
        goToCreateActivityRecordWithDetails: @escaping (Habit, Date) -> Void
    ) {
        let today = Date().noon!
        
        self.blockHabitStore = blockHabitStore
        self.habitRecordDataSource = blockHabitStore.habitRecordsByDateDataSource()
        
        self.selectedDay = today
        self.goToCreateActivityRecordWithDetails = goToCreateActivityRecordWithDetails
        
        bindHabitDataSource()
        bindHabitRecordsByDateDataSource()
    }
    
    
    private func bindHabitDataSource() {
        
        habitDataSourceCancellable = blockHabitStore.habitDataSource(selectedDay: selectedDay)
            .habits
            .sink { error in
                fatalError("THERES BEEN A HORRIBLE CRASH INVOLVING '\(error)' - prosecute to the highest degree of the law.")
            } receiveValue: { habits in
                print("BOYCE: habit data source reloaded")
                self.habits = habits
            }
    }
    
    
    private func bindHabitRecordsByDateDataSource() {
        
        habitRecordDataSource
            .habitRecordsByDate
            .sink { error in
                fatalError("THERES BEEN A HORRIBLE CRASH INVOLVING '\(error)' - prosecute to the highest degree of the law.")
            } receiveValue: { habitRecordsByDate in
                print("BOYCE: habit data source reloaded")
                self.datesWithHabitRecords = habitRecordsByDate
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
    
    
    func destroyHabitRecord(_ habitRecord: HabitRecord) {
        
        
        Task {
            do {
                try await blockHabitStore.destroy(habitRecord)
            } catch {
                // FIXME: Handle Error in View - note this could be called from DayView so not sure how alerts will be affected
                fatalError("DESTROYING DIDN'T WORK - ITS INVINCIBLE \(error)")
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
