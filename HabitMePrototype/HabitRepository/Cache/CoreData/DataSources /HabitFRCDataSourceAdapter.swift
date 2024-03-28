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
    
    var habits: AnyPublisher<[Habit], Never> { get }
}


fileprivate extension Publisher {
    
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
    private let getHabitRecordsForDay: () async throws -> [ManagedHabitRecord]
    
    public var habitsSubject = CurrentValueSubject<[Habit], Never>([])
    public var habits: AnyPublisher<[Habit], Never>
//    public var routinesSubject = CurrentValueSubject<[Routine], Error>([])
//    public var routines: AnyPublisher<[Routine], Error>

    
    public init(
        frc: NSFetchedResultsController<ManagedHabit>,
        getHabitRecordsForDay: @escaping () async throws -> [ManagedHabitRecord]
    ) {
        
        self.frc = frc
        self.getHabitRecordsForDay = getHabitRecordsForDay
        
        self.habits = habitsSubject
            .asyncMap({ habits in
                let habitRecordsForDay = try? await getHabitRecordsForDay()
                print("habitRecordsForDay from Habit datasource - count: \(habitRecordsForDay?.count ?? -1)")
//                // Do logic to determine if habits are comopleted or not
//                for habit in habits {
//                    
//                }
                
                return habits
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
        
        print("Update with latest value count: '\(managedHabits.count)'")
        
        let habits = try managedHabits.toModel()
        
//            let managedHabitRecordsForDay = try await getHabitRecordsForDay()
//            print("I found this many records for this day: \(managedHabitRecordsForDay.count)")
        
        habitsSubject.send(habits)
    }
}


extension ManagedHabitFRCDataSourceAdapter: NSFetchedResultsControllerDelegate {
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("BOYCE: Did change routine core data content")
        
        try? updateWithLatestValues()
    }
}
