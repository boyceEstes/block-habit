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
        
        Task { @MainActor in
            let recordsForSelectedDay = habitRecordsForDays[selectedDay] ?? []
            isCompletedHabits = latestNonArchivedHabits.toIsCompleteHabits(recordsForSelectedDay: recordsForSelectedDay)
        }
    }
    
    
    /// This is assumed that it is already been guarded to go here
    private func setSelectedDayRaw(to date: Date) {
        
        Task { @MainActor in
            
            selectedDay = date
            updateHabitsIsCompletedForDay()
        }
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


// MARK: Create habit
extension HabitController {
    
    public func createHabit(_ habit: Habit) {
        
        Task {
            do {
                try await blockHabitRepository.createHabit(habit)
                
                // It will always be false because it can't be done on creation
                isCompletedHabits.insert(IsCompletedHabit(habit: habit, isCompleted: false))
                
            } catch {
                fatalError("FAILED MISERABLY TO CREATE HABIT - \(error)")
            }
        }
    }
}

// MARK: Create record
extension HabitController {

    // I am moving away from using that fun protocol system that I made because this
    // logic should be pretty central and shared with everything. If I need to break it up
    // I know how, but simplicity is the name of the game for now.
    public func createRecordOrNavigateToRecordWithDetails(
        for habit: Habit,
        goToCreateActivityRecordWithDetails: @escaping (Habit, Date) -> Void
    ) {
        
        if isNavigatingToCreateRecordWithDetails(for: habit) {
            goToCreateActivityRecordWithDetails(habit, selectedDay)
        } else {
            createRecord(for: habit, activityDetailRecords: [])
        }
    }
    
    
    public func createRecord(
        for habit: Habit,
        activityDetailRecords: [ActivityDetailRecord] = []
    ) {
        Task {
            do {
                let habitRecord = await makeHabitRecord(for: habit, activityDetailRecords: activityDetailRecords)
                
                try await insertRecord(habitRecord: habitRecord, in: blockHabitRepository)
                
                await updateLocalWithNewRecord(habitRecord)
                
            } catch {
                // FIXME: Handle Errors
                fatalError("ERROR OH NO - BURN IT ALL DOWN")
            }
        }
    }
    
    
    private func updateLocalWithNewRecord(_ habitRecord: HabitRecord) async {
        
        Task { @MainActor in
            // This should never be nil because we set each date in the dictionary to have an empty array
            habitRecordsForDays[selectedDay]?.insert(habitRecord, at: 0)
            await populateHabits()
        }
    }
    
    
    private func isNavigatingToCreateRecordWithDetails(for habit: Habit) -> Bool {
        
        return !habit.activityDetails.isEmpty
    }
    
    
    private func makeHabitRecord(
        for habit: Habit,
        activityDetailRecords: [ActivityDetailRecord]
    ) async -> HabitRecord {
        
        let (creationDate, completionDate) = ActivityRecordCreationPolicy.calculateDatesForRecord(on: selectedDay)
        
        let habitRecord = HabitRecord(
            id: UUID().uuidString,
            creationDate: creationDate,
            completionDate: completionDate,
            activityDetailRecords: activityDetailRecords,
            habit: habit
        )
        
        return habitRecord
    }
    
    
    private func insertRecord(
        habitRecord: HabitRecord,
        in store: BlockHabitRepository
    ) async throws {
        
        try await store.createHabitRecord(habitRecord)
    }
}
