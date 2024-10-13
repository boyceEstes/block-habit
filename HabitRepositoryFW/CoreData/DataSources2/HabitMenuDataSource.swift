//
//  HabitMenuDataSource.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/1/24.
//

import Foundation
import Combine
import CoreData

public protocol HabitMenuDataSource {
    
    var habitsForDayPublisher: AnyPublisher<[IsCompletedHabit], Never> { get }
    
    /// Required to selected the records for today, to judge if the completion goal is complete
    var selectedDayPublisher: CurrentValueSubject<Date, Never> { get }
    
//    func getHabitRecordsForDay(selectedDay: Date) async throws -> [ManagedHabitRecord]
}


/// Use in order to find the habits that are available for the given date
/// `NSFetchedResultsController` retrieves ALL habits
/// `selectedDay` will be used to determined if the habits are completed for the habit records done at that time

public class HabitMenuDataSourceFRCAdapter: NSObject {
    
    public var habitsForDayPublisher: AnyPublisher<[IsCompletedHabit], Never>
    
    private var habitsPublisher = CurrentValueSubject<[Habit], Never>([])
    var selectedDayPublisher: CurrentValueSubject<Date, Never>
    private let frc: NSFetchedResultsController<ManagedHabit>
    
    public init(
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
                
                // MARK: What if instead of making the request everytime that we make a change
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
