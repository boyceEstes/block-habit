//
//  HomeViewModel.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation
import Combine
import HabitRepositoryFW

// FIXME: For some reason when we go to another day, the habitDataSource loads data twice - investigate if there is room for optimization



//@Observable
//final class HomeViewModel {
//    
//    let blockHabitStore: CoreDataBlockHabitStore
//    
//    var selectedDay: Date {
//        didSet(oldValue) {
//            if oldValue != selectedDay {
//                habitDataSource.setSelectedDay(to: selectedDay)
//            }
//        }
//    }
//    
//    var goToCreateActivityRecordWithDetails: (Habit, Date) -> Void
//    var habits = [IsCompletedHabit]() {
//        didSet {
//            print("didSet habits - count: \(habits.count)")
//            for habit in habits {
//                print("activityDetails - count: \(habit.habit.activityDetails.count)")
//            }
//        }
//    }
//    
//    var datesWithHabitRecords: [Date: [HabitRecord]] = [:] {
//        didSet {
//            print("didSet habitRecords - count: \(datesWithHabitRecords.count)")
//            print("habit records for today \(datesWithHabitRecords[selectedDay]?.count ?? -1)")
//        }
//    }
//    
//    var cancellables = Set<AnyCancellable>()
//    var habitDataSourceCancellable: AnyCancellable?
//    
//    
//    init(
//        blockHabitStore: CoreDataBlockHabitStore,
//        goToCreateActivityRecordWithDetails: @escaping (Habit, Date) -> Void
//    ) {
//        let today = Date().noon!
//        
//        self.blockHabitStore = blockHabitStore
//        
//        self.selectedDay = today
//        self.goToCreateActivityRecordWithDetails = goToCreateActivityRecordWithDetails
//        
//    }
//    
//    
//    
//    func createHabitRecord(for habit: Habit) {
//        
////        Task {
////            do {
////                try await createRecord(for: habit, in: blockHabitStore)
////                
////                updateIfHabitIsCompleted(habit)
////            } catch {
////                // FIXME: Handle Error in View
////                fatalError("ERROR OH NO - BURN IT ALL DOWN")
////            }
////        }
//    }
//    
//    
//    private func updateIfHabitIsCompleted(_ habit: Habit) {
//        
//        // If there is no goal for the day, it will never be completed
//        guard let goalCompletionsPerDay = habit.goalCompletionsPerDay else {
//            return
//        }
//        
//        // TODO: We could make this more efficient by passing the index to the `createHabitRecord` call
//        // Find the habit being recorded
//        let isCompletedHabitIndex = habits.firstIndex { isCompletedHabit in
//            isCompletedHabit.habit == habit
//        }
//        
//        // We need an index to update
//        guard let isCompletedHabitIndex else { return }
//        
//        // TODO: Move this logic out of the view model - it has nothing to do with presenting
//        // if there is nothing here, then just say there's 0 records found
//        let habitRecordsForDayCount = datesWithHabitRecords[selectedDay]?.filter { $0.habit == habit }.count ?? 0
//        
//        let isCompleted = habitRecordsForDayCount >= goalCompletionsPerDay
//        
//        habits[isCompletedHabitIndex].isCompleted = isCompleted
//    }
//    
//    
//    func destroyHabitRecord(_ habitRecord: HabitRecord) {
//        
//        Task {
//            do {
//                try await blockHabitStore.destroy(habitRecord)
//                updateIfHabitIsCompleted(habitRecord.habit)
//            } catch {
//                // FIXME: Handle Error in View - note this could be called from DayView so not sure how alerts will be affected
//                fatalError("DESTROYING DIDN'T WORK - ITS INVINCIBLE \(error)")
//            }
//        }
//    }
//    
//    
//    func archiveHabit(for habit: Habit) {
//        
//        Task {
//            do {
//                print("archiving \(habit.id) - \(habit.name)")
//                try await blockHabitStore.archive(habit)
//            } catch {
//                // FIXME: Handle Error in View
//                fatalError("ERROR OH NO - BURN IT ALL DOWN - '\(error.localizedDescription)'")
//            }
//        }
//    }
//    
//    
//    func destroyHabit(for habit: Habit) {
//        
//        Task {
//            do {
//                print("deleting \(habit.id) - \(habit.name)")
//                try await blockHabitStore.destroy(habit)
//            } catch {
//                // FIXME: Handle Error in View
//                fatalError("ERROR OH NO - BURN IT ALL DOWN - '\(error.localizedDescription)'")
//            }
//        }
//    }
//}
