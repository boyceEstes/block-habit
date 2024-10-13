//
//  HabitFRCDataSourceAdapter.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 3/12/24.
//

import Foundation
import Combine
import CoreData


public protocol HabitDataSource {
    
    var habits: AnyPublisher<[IsCompletedHabit], Never> { get }
    
    func setSelectedDay(to selectedDay: Date)
}


public extension Publisher {
    
    func asyncMap<T>(
        _ transform: @escaping (Output) async -> T
    ) -> Publishers.FlatMap<Future<T, Never>, Self> {
        
        flatMap { value in
            
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
}


public class ManagedHabitFRCDataSourceAdapter: NSObject, HabitDataSource {
    
    private let frc: NSFetchedResultsController<ManagedHabit>
    private let getHabitRecordsForDay: (Date) async throws -> [ManagedHabitRecord]

    public var habitsSubject = CurrentValueSubject<[Habit], Never>([])
    public var selectedDaySubject: CurrentValueSubject<Date, Never>
    public var habits: AnyPublisher<[IsCompletedHabit], Never>
    
    
//    public var routinesSubject = CurrentValueSubject<[Routine], Error>([])
//    public var routines: AnyPublisher<[Routine], Error>

    
    public init(
        frc: NSFetchedResultsController<ManagedHabit>,
        selectedDay: Date,
        getHabitRecordsForDay: @escaping (Date) async throws -> [ManagedHabitRecord]
    ) {
        
        self.frc = frc
        self.selectedDaySubject = CurrentValueSubject<Date, Never>(selectedDay)
        self.getHabitRecordsForDay = getHabitRecordsForDay
        
        self.habits = habitsSubject.combineLatest(selectedDaySubject)
            .asyncMap({ habits, selectedDay in
                
                guard let habitRecordsForDay = try? await getHabitRecordsForDay(selectedDay).toModel() else {
                    // FIXME: Handle this, don't be dumb
                    fatalError("If we can get the records for the day, we can't do any math to see the habits we should deliver")
                }
                
                print("habitRecordsForDay from Habit datasource - count: \(habitRecordsForDay.count)")
                
                // Do logic to determine if habits are comopleted or not
                // We are making two separate arrays and then putting them together at the end to maintain the sorting order as the same for completed and incompleted habits
                var isCompletedHabits = [IsCompletedHabit]()
                var isIncompletedHabits = [IsCompletedHabit]()
                
                for habit in habits {
                    // We continue if it is nil because we will never hit the completion goal
                    guard let completionGoalForHabit = habit.goalCompletionsPerDay else {
                        isIncompletedHabits.append(IsCompletedHabit(habit: habit, isCompleted: false))
                        continue
                    }
                    
                    let habitRecordsForDayForHabitCount = habitRecordsForDay.filter { $0.habit == habit }.count
                    
                    let isCompleted = habitRecordsForDayForHabitCount >= completionGoalForHabit 
                    
                    let isCompletedHabit = IsCompletedHabit(
                        habit: habit,
                        isCompleted: isCompleted
                    )
                    
                    if isCompleted {
                        isCompletedHabits.append(isCompletedHabit)
                    } else {
                        isIncompletedHabits.append(isCompletedHabit)
                    }
                }
                
                return isIncompletedHabits + isCompletedHabits
            })
            .eraseToAnyPublisher()
        
        super.init()
        
        setupFRC()
    }
    
    
    private func setupFRC() {
        
        frc.delegate = self
        
        performFetch()
    }
    
    
    private func performFetch() {
        
        do {
            try frc.performFetch()
            try updateWithLatestValues()
//            routines.value = managedRoutines.toModel()
        } catch {
            let nsError = error as NSError
            fatalError("Unresoled error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    private func updateWithLatestValues() throws {
        
        let managedHabits = frc.fetchedObjects ?? []
        
        print("BOYCE: Update with latest value count: '\(managedHabits.count)'")
        
        let habits = try managedHabits.toModel()
        
//            let managedHabitRecordsForDay = try await getHabitRecordsForDay()
//            print("I found this many records for this day: \(managedHabitRecordsForDay.count)")
        
        habitsSubject.send(habits)
    }
    
    
    public func setSelectedDay(to selectedDay: Date) {
        
        self.selectedDaySubject.send(selectedDay)
    }
}


extension ManagedHabitFRCDataSourceAdapter: NSFetchedResultsControllerDelegate {
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("BOYCE: Did change routine core data content")
        
        try? updateWithLatestValues()
    }
}
