//
//  HabitController.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/3/24.
//

import Foundation
import Combine


public class HabitController {
    
    let blockHabitRepository: BlockHabitRepository
    
    public let selectedDay: CurrentValueSubject<Date, Never>
    
    public let habitRecordsForDays = CurrentValueSubject<[Date: [HabitRecord]], Never>([:])
    
    private let isCompletedHabits = CurrentValueSubject<Set<IsCompletedHabit>, Never>([])
    
    public var completeHabits: AnyPublisher<[Habit], Never> {
        
        isCompletedHabits.map { isCompletedHabits in
            return isCompletedHabits
                .filter { $0.isCompleted == true }
                .map { $0.habit }
                .sorted(by: { $0.name < $1.name })
        }.eraseToAnyPublisher()
    }
    
    
    public var incompleteHabits: AnyPublisher<[Habit], Never> {
        
        isCompletedHabits.map { isCompletedHabits in
            return isCompletedHabits
                .filter { $0.isCompleted == false }
                .map { $0.habit }
                .sorted(by: { $0.name < $1.name })
        }.eraseToAnyPublisher()
    }
    
    public init(blockHabitRepository: BlockHabitRepository, selectedDay: Date) {
        
        self.blockHabitRepository = blockHabitRepository
        self.selectedDay = CurrentValueSubject(selectedDay)
        
        Task {
            await populateHabitRecordsForDay()
            await populateHabits()
        }
    }
    
    
    /// This must be done first in order to have the information to successfully organize the completed habits
    private func populateHabitRecordsForDay() async {
        
        do {
            let allHabitRecords = try await blockHabitRepository.readAllHabitRecords()
            habitRecordsForDays.send(allHabitRecords.toHabitRecordsForDays(onCurrentDate: selectedDay.value))
            
        } catch {
            // TODO: send an error to a publisher say to subscribers that there has been a problem reading the habit records.
            fatalError("Problem getting habit records")
        }
    }
    
    
    private func populateHabits() async {
        
        do {
            let nonArchivedHabits = try await blockHabitRepository.readAllNonarchivedHabits()
            let recordsForDays = habitRecordsForDays.value
            let recordsForSelectedDay = recordsForDays[selectedDay.value] ?? []
            isCompletedHabits.send(nonArchivedHabits.toIsCompleteHabits(recordsForSelectedDay: recordsForSelectedDay))
        } catch {
            // TODO: send an error to a publisher say to subscribers that there has been a problem reading the habit records.
            fatalError("Problem getting habits")
        }
    }
}
