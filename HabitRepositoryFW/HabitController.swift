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
    @Published public var habitRecordsForDays = [Date: [HabitRecord]]() {
        didSet {
            print("habitRecordsForDays")
        }
    }
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
    
    
    public func habitRecordsForDays(for habit: Habit) -> AnyPublisher<[Date: [HabitRecord]], Never> {
        
        $habitRecordsForDays
            .map { habitRecordsForDaysEmission in
                
                print("BOYCE: habitRecordsForDays emitted \(habitRecordsForDaysEmission.count)")
                let filteredHabitRecordsForDays = habitRecordsForDaysEmission.mapValues { habitRecordForDay in
        
                    // NOTE: This must be id in case the color changes
                    habitRecordForDay.filter { $0.habit.id == habit.id }
                }
                print("BOYCE: habitRecordsForDays emitted \(filteredHabitRecordsForDays.count)")
                return filteredHabitRecordsForDays
            }
            .eraseToAnyPublisher()
    }
    
    
    public func latestHabitInformation(for habit: Habit) -> AnyPublisher<IsCompletedHabit, Error> {
        
        $isCompletedHabits.tryMap { receivedIsCompletedHabits in
            guard let latestForHabit: IsCompletedHabit = receivedIsCompletedHabits.first(where: { $0.habit.id == habit.id}) else {
                throw NSError(domain: "We couldn't find the habit was sent up", code: 1)
            }
            return latestForHabit
        }.eraseToAnyPublisher()
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


// MARK: Habit
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
    
    
    /// Expected to be given the updated habit (it should have all the fields updated and is expected to have the same ID as the previous store)
    public func updateHabit(_ updatedHabit: Habit) {
        
        Task {
            do {
                try await blockHabitRepository.updateHabit(id: updatedHabit.id, with: updatedHabit)
                
                guard let outdatedHabit = isCompletedHabits.first(where: { $0.habit.id == updatedHabit.id }) else { throw NSError(domain: "Could not find habit locally", code: 1)}
                
                // I actually think we don't need to even populate for core data we can just rely on the inmemory stuff
                await populateHabits()
                
                // TODO: We can optimize this by not always pulling from Core Data if we don't need to but for now I am just going to do it all the same way
//                if outdatedHabit.habit.goalCompletionsPerDay != updatedHabit.goalCompletionsPerDay {
//                    
//                    // Need to repopulate the habits in order to have the correct isCompletedStatus - this will set everything from the database so we know it'll be right
//                    await populateHabits()
//                    
//                } else {
//                    // Instead of reading the update from core data, we can just update locally
//                    isCompletedHabits.remove(outdatedHabit)
//                    let updatedIsCompletedHabit = IsCompletedHabit(habit: updatedHabit, isCompleted: outdatedHabit.isCompleted)
//                    isCompletedHabits.insert(updatedIsCompletedHabit)
//                }
                
                
                // if there is a change in the color, we need to update the habits color in the habitRecordsForDays
                if outdatedHabit.habit.color != updatedHabit.color {
                    
                    updateHabitInHabitRecordsForDays(from: outdatedHabit.habit, to: updatedHabit)
                }
            } catch {
                // FIXME: Handle error updating!
                fatalError("I GOT 99 PROBLEMS AND THIS IS 1 - \(error)")
            }
        }
    }
    
    
    private func updateHabitInHabitRecordsForDays(from outdatedHabit: Habit, to updatedHabit: Habit) {
        
        // loop through all of the habitRecords
        let updatedHabitRecordsForDays = habitRecordsForDays.mapValues { habitRecords in
            habitRecords.map { habitRecord in
                // for each habit record
                if habitRecord.habit.id == outdatedHabit.id {
                    return HabitRecord(
                        id: habitRecord.id,
                        creationDate: habitRecord.creationDate,
                        completionDate: habitRecord.completionDate,
                        activityDetailRecords: habitRecord.activityDetailRecords,
                        habit: updatedHabit
                    )
                } else {
                    return habitRecord
                }
            }
        }
        
        self.habitRecordsForDays = updatedHabitRecordsForDays
    }
}


// MARK: Archived Habits
extension HabitController {
    
    public func archivedHabits() async -> [Habit] {
        
        return await (try? blockHabitRepository.readAllArchivedHabits()) ?? []
    }
    
    
    public func archiveHabit(_ habit: Habit) {
        
        // We want to update the habit's `isArchived` property to true
        Task {
            do {
                let id = habit.id
                var archivedHabit = habit
                archivedHabit.isArchived = true
                
                try await blockHabitRepository.updateHabit(id: id, with: archivedHabit)
                
                // Remove from the underlying habits list - this might not be necessary since it is not primary driver of the habitsmenu, however there is logic with it when we are deciding what is or isn't complete, so I still want to keep it to date
                latestNonArchivedHabits.removeAll {
                    $0.id == habit.id
                }
                
                guard let isCompletedHabit = isCompletedHabits.first(where: { $0.habit.id == habit.id }) else { return }
                
                isCompletedHabits.remove(isCompletedHabit)
            } catch {
                fatalError("AGHHHHHH IT WON'T GO AWAY! \(error)")
            }
        }
        
        
    }
}


// MARK: Record
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
    
    
    /// `day` is really just to make this more available for other - default is current selectedDay
    public func destroyRecord(
        _ habitRecord: HabitRecord,
        day: Date? = nil
    ) {
        
        Task { @MainActor in
            let day = day ?? selectedDay
            
            do {
                try await blockHabitRepository.destroyHabitRecord(habitRecord)
                
                // Update habitRecordsForDays locally
                habitRecordsForDays[day]?.removeAll(where: { $0.id == habitRecord.id })
                
                // Ensure that habits are updated for isCompleted
                updateHabitsIsCompletedForDay()
            } catch {
                
                fatalError("DESTROYING DIDN'T WORK - ITS INVINCIBLE \(error)")
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
    
    
    public func updateHabitRecord(_ updatedHabitRecord: HabitRecord) {
        
        Task {
            do {
                try await blockHabitRepository.updateHabitRecord(id: updatedHabitRecord.id, with: updatedHabitRecord)
                
                // Update it locally if it is successful
                // Find the habitRecord, and replace it with the new one
                // Get today's habits (Because it had to be the selected day to see the detail view)
                // TODO: Make a general version of this for the future in case there is ever a need to go to this screen without having that day selected. this could easily happen in the habit detail view.
                replaceHabitRecord(withId: updatedHabitRecord.id, in: &habitRecordsForDays, newRecord: updatedHabitRecord)
            } catch {
                fatalError("This aint a problem is an issue")
            }
        }
    }
    

    // TODO: Make generic
    func replaceHabitRecord(withId id: String, in dictionary: inout [Date: [HabitRecord]], newRecord: HabitRecord) {
        
        for (date, habitRecords) in dictionary {
            if let index = habitRecords.firstIndex(where: { $0.id == id }) {
                // Replace the HabitRecord at the found index with the new instance
                dictionary[date]?[index] = newRecord
                return
            }
        }
    }
}
