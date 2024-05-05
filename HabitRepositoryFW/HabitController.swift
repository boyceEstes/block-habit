//
//  HabitController.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/3/24.
//

import Foundation
import Combine


public class HabitController: ObservableObject {
    
    let minimumNumberOfDays = 7
    let blockHabitRepository: BlockHabitRepository
    
    @Published public var selectedDay: Date
    @Published public var habitRecordsForDays = [Date: [HabitRecord]]()
    @Published public var isCompletedHabits = Set<IsCompletedHabit>() {
        didSet {
            print("BOYCE: did change isCompletedHabits")
        }
    }
    
    // These values don't need to be published, they are only here to reduce need to get them repeatedly from the database if there are no changes
    var latestNonArchivedHabits = [Habit]()
    
    public var completeHabits: [Habit] {
        
        isCompletedHabits
            .filter { $0.isCompleted == true }
            .map { $0.habit }
            .sorted(by: { $0.name < $1.name })
    }
    
    
    public var incompleteHabits: [Habit] {
        
        isCompletedHabits
            .filter { $0.isCompleted == false }
            .map { $0.habit }
            .sorted(by: { $0.name < $1.name })
        
    }
    
    
    public init(
        blockHabitRepository: BlockHabitRepository,
        selectedDay: Date
    ) {
        
        self.blockHabitRepository = blockHabitRepository
        self.selectedDay = selectedDay
        
        Task {
            await populateHabitRecordsForDay()
            await populateHabits()
        }
    }
    
    
    /// This must be done first in order to have the information to successfully organize the completed habits
    private func populateHabitRecordsForDay() async {
        
        do {
            let allHabitRecords = try await blockHabitRepository.readAllHabitRecords()
            habitRecordsForDays = allHabitRecords.toHabitRecordsForDays(onCurrentDate: selectedDay, delimiter: minimumNumberOfDays)
            
        } catch {
            // TODO: send an error to a publisher say to subscribers that there has been a problem reading the habit records.
            fatalError("Problem getting habit records")
        }
    }
    
    
    private func populateHabits() async {
        
        do {
            latestNonArchivedHabits = try await blockHabitRepository.readAllNonarchivedHabits()
            updateHabitsIsCompletedForDay()
        } catch {
            // TODO: send an error to a publisher say to subscribers that there has been a problem reading the habit records.
            fatalError("Problem getting habits")
        }
    }
    
    
    private func updateHabitsIsCompletedForDay() {
        
        let recordsForSelectedDay = habitRecordsForDays[selectedDay] ?? []
        isCompletedHabits = latestNonArchivedHabits.toIsCompleteHabits(recordsForSelectedDay: recordsForSelectedDay)
    }
    
    
    /// This is assumed that it is already been guarded to go here
    private func setSelectedDayRaw(to date: Date) {
        
        selectedDay = date
        updateHabitsIsCompletedForDay()
    }
    
    
    public func setSelectedDay(to date: Date) {
        
        let habitRecordsForNewDay = habitRecordsForDays[date]
        if habitRecordsForNewDay != nil {
            setSelectedDayRaw(to: date)
        }
    }
     
    
    public func goToNextDay() {
        
        if isAllowedToGoToNextDay() {
            let nextDay = selectedDay.adding(days: 1)
            setSelectedDayRaw(to: nextDay)
        }
    }
    
    
    public func goToPrevDay() {
        
        if isAllowedToGoToPrevDay() {
            
            let prevDay = selectedDay.adding(days: -1)
            setSelectedDayRaw(to: prevDay)
        }
    }
    
    
    /// Useful for disabling buttons if necessary
    public func isAllowedToGoToNextDay() -> Bool {
        
        let nextDay = selectedDay.adding(days: 1)
        let habitRecordsForNextDay = habitRecordsForDays[nextDay]
        
        return habitRecordsForNextDay != nil
    }
    
    
    /// Useful for disabling buttons if necessary
    public func isAllowedToGoToPrevDay() -> Bool {
        
        let prevDay = selectedDay.adding(days: -1)
        let habitRecordsForPrevDay = habitRecordsForDays[prevDay]
        
        return habitRecordsForPrevDay != nil
    }
}
