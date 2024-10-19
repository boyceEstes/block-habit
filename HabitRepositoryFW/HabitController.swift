//
//  HabitController.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/3/24.
//

import Foundation
import Combine


public class HabitController: ObservableObject {
    
    /// This is the minimum number of days because it is approximately the amount of columns that could fit on the screen by default
    let minimumNumberOfDays = 7
    let blockHabitRepository: BlockHabitRepository
    
    @Published public var selectedDay: Date
    @Published public var habitRecordsForDays = [Date: [HabitRecord]]()
    
    public var habitRecordsForSelectedDay: [HabitRecord] {
        habitRecordsForDays[selectedDay] ?? []
    }
    
    // These are created from data in latestNonArchivedHabits
    @Published public var isCompletedHabits = Set<IsCompletedHabit>()
    
    
    @Published var latestHabits = [Habit]()
    
    
    public var latestArchivedHabits: [Habit] {
        latestHabits.filter { $0.isArchived }
    }
    
    
    var latestNonArchivedHabits: [Habit] {
        latestHabits.filter { !$0.isArchived }
    }
    
    
    
    @Published var latestActivityDetails = [ActivityDetail]()
    
    
    /// This is the minimum amount of information that we need to show the users
    /// the app. I deally it shouldn't take long and it will prevent them not seeing the screen before its ready
    @Published public var isImportantInformationLoading: Bool = true

    
    /// Habit Menu Data
    public var completeHabits: [IsCompletedHabit] {
        
        isCompletedHabits
            .filter { $0.isCompleted }
            .sorted(by: { $0.habit.name.lowercased() < $1.habit.name.lowercased() })
    }
    
    /// Habit Menu Data
    public var incompleteHabits: [IsCompletedHabit] {
        
        isCompletedHabits
            .filter { !$0.isCompleted }
            .sorted(by: { $0.habit.name.lowercased() < $1.habit.name.lowercased() })
    }
    
    
    public var isRecordsEmptyForSelectedDay: Bool {
        habitRecordsForSelectedDay.isEmpty
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
    
    
    public func latestHabitInformation(for habit: Habit) -> AnyPublisher<Habit, Error> {
        
        $latestHabits.tryMap { receivedHabits in
            
            guard let latestForHabit: Habit = receivedHabits.first(where: { $0.id == habit.id}) else {
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
            
            DispatchQueue.main.async { [weak self] in
                self?.isImportantInformationLoading = false
            }
            
            await populateActivityDetails()
        }
    }
    
    
    /// This must be done first in order to have the information to successfully organize the completed habits
    private func populateHabitRecordsForDay() async {
        
        do {
            let allHabitRecords = try await blockHabitRepository.readAllHabitRecords()
            await MainActor.run {
                habitRecordsForDays = allHabitRecords.toHabitRecordsForDays(onCurrentDate: selectedDay, delimiter: minimumNumberOfDays)
            }
            
        } catch {
            // TODO: send an error to a publisher say to subscribers that there has been a problem reading the habit records.
            fatalError("Problem getting habit records")
        }
    }
    
    
    private func populateHabits() async {
        
        do {
            let habitsFromRepository = try await blockHabitRepository.readAllHabits()
            
            await MainActor.run {
                latestHabits = habitsFromRepository
                    
                updateHabitsIsCompletedForDay()
            }
        } catch {
            // TODO: send an error to a publisher say to subscribers that there has been a problem reading the habit records.
            fatalError("Problem getting habits")
        }
    }
    
    
    private func updateHabitsIsCompletedForDay() {
        
        Task { @MainActor in
            let recordsForSelectedDay = habitRecordsForSelectedDay
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
                // store:
                try await blockHabitRepository.createHabit(habit)
                
                await MainActor.run {
                    // local:
                    // Include it in all habits that will be used for later isCompletedHabit calculations
                    latestHabits.append(habit)
                    // adding this here because I don't feel like recalculating all the IsCompletedHabits
                    // when we know this is false
                    isCompletedHabits.insert(IsCompletedHabit(habit: habit, isCompleted: false))
                }
                    
                if habit.reminderTime != nil {
                    
                    let manager = NotificationPermissionManager.shared
                    manager.scheduleNotification(for: habit)
                }

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
                
                if outdatedHabit.habit.reminderTime != updatedHabit.reminderTime {
                    
                    let manager = NotificationPermissionManager.shared
                    manager.scheduleNotification(for: updatedHabit, previousDays: outdatedHabit.habit.scheduledWeekDays)
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
    
    
    private func deleteHabitInHabitRecordsForDays(habitToRemove: Habit) {
        
        let updatedHabitRecordsForDays = habitRecordsForDays.mapValues { habitRecords in
            
            var newHabitRecords = habitRecords
            newHabitRecords.removeAll {
                $0.habit.id == habitToRemove.id
            }
            return newHabitRecords
        }
        
        self.habitRecordsForDays = updatedHabitRecordsForDays
    }
    
    
    public func deleteHabit(_ habit: Habit) {
        
        Task {
            
            do {
                try await blockHabitRepository.destroyHabit(habit)
                
                guard let habitToRemoveIndex = latestHabits.firstIndex(where: { $0.id == habit.id }) else {
                    throw NSError(domain: "", code: 1)
                }
                
                await MainActor.run {
                    self.latestHabits.remove(at: habitToRemoveIndex)
                    
                    self.updateHabitsIsCompletedForDay()
                    self.deleteHabitInHabitRecordsForDays(habitToRemove: habit)
                }
                
                
                if habit.reminderTime != nil {
                    NotificationPermissionManager.shared.removeNotifications(habitID: habit.id, days: habit.scheduledWeekDays)
                }
            } catch {
                fatalError("Fix it. The ... yard trimmings... need to be removed. \(error)")
            }
        }
    }
    
//    var
    
    // MARK: Notificaitons for Habits
    
    /// Meant to be used whenever we are toggling back and forth on the NotificationSettings menu
//    public func scheduleNotificationsForHabits() {
//        
//        let habitsToSchedule = latestNonArchivedHabits.filter { $0.reminderTime != nil }
//    }
//
    
    var habitsWithReminders: [Habit] {
        latestNonArchivedHabits.filter { $0.reminderTime != nil }
    }
    
    
    public func scheduleAllNotifications(isOn: Bool) {
        
        if isOn {
            for habit in habitsWithReminders {
                NotificationPermissionManager.shared.scheduleNotification(for: habit)
            }
            print("Turned on notifications for all habits with reminders")
        } else {
            NotificationPermissionManager.shared.removeAllNotifications()
            print("Turned off notifications for all habits")
        }
    }
}


// MARK: Archived Habits
extension HabitController {
    
    public func archiveHabit(_ habit: Habit) {
        
        // We want to update the habit's `isArchived` property to true
        Task { @MainActor in
            do {
                let id = habit.id
                var archivedHabit = habit
                archivedHabit.isArchived = true
                
                try await blockHabitRepository.updateHabit(id: id, with: archivedHabit)
                
                
                guard let archiveHabitIndex = self.latestHabits.firstIndex(where: {
                    $0.id == id
                }) else {
                    throw NSError(domain: "Couldn't find habit to archive", code: 1)
                }
                
                self.latestHabits[archiveHabitIndex].isArchived = true
                
                updateHabitsIsCompletedForDay()
                
                
                if habit.reminderTime != nil {
                    NotificationPermissionManager.shared.removeNotifications(habitID: habit.id, days: habit.scheduledWeekDays)
                }
                
            } catch {
                
                fatalError("SO BAD! \(error)")
            }
        }
    }
    
    
    public func restoreHabit(_ habit: Habit) {
        
        Task { @MainActor in
            do {
                let id = habit.id
                var restoredHabit = habit
                restoredHabit.isArchived = false
                
                try await blockHabitRepository.updateHabit(id: id, with: restoredHabit)
                
                guard let archiveHabitIndex = self.latestHabits.firstIndex(where: {
                    $0.id == id
                }) else {
                    throw NSError(domain: "Couldn't find habit to restore", code: 1)
                }
                
                self.latestHabits[archiveHabitIndex].isArchived = false
                
                // I actually don't know if we have already done this habit or not before - so I should recalculate its completion rather than just setting it to complete now that I have appended to the nonarchived habits
                updateHabitsIsCompletedForDay()
                
                
                if habit.reminderTime != nil {
                    // If it is being restored from archive, there should be no notification active - simply create notification schedules
                    NotificationPermissionManager.shared.scheduleNotification(for: habit)
                }
                
            } catch {
                fatalError("GRRRRR IT WON'T COME BACK! PLEASE FORGIVE ME! \(error)")
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
    
    
    /// It will use the completionDay on the habitRecord to determine where to remove the record in the local dictionary
    public func destroyRecord(
        _ habitRecord: HabitRecord
    ) {
        
        Task { @MainActor in
            
            do {
                try await blockHabitRepository.destroyHabitRecord(habitRecord)
                
                // Update habitRecordsForDays locally
                guard let day = habitRecord.completionDate.noon,
                        let habitRecordIndex = habitRecordsForDays[day]?.firstIndex(where: { $0.id == habitRecord.id }) else {
                    throw NSError(domain: "Could not find the habitRecord in the day (locally)", code: 1)
                }
                
                habitRecordsForDays[day]?.remove(at: habitRecordIndex)
                
                // Ensure that habits are updated for isCompleted
                updateHabitsIsCompletedForDay() // FIXME: There should be some issue because this is using selectedDay instead of the deleted - but wait. That might be expected because we would not need to worry about isCompleted if it is not the selected Day - to optimize we can just check to see if we are deleting on the selectedDay
            } catch {
                
                fatalError("DESTROYING DIDN'T WORK - ITS INVINCIBLE \(error)")
            }
        }
    }
    
    
    public func destroyLastRecordOnSelectedDay() {
        
        Task {
            // 1. get day, this is mostly just ensuring that the day can be found in recordsfordays
            guard let (day, records) = habitRecordsForDays.first(where: { day, value in
                Calendar.current.isDate(day, inSameDayAs: selectedDay)
            }), !records.isEmpty else {
                return
            }
            
            await MainActor.run {
                // 2. destroy last record in-memory
                // We know for sure that day is in there because we just got it above, so we can forcibly unwrap
                let lastRecord = habitRecordsForDays[day]!.removeLast()
                
                Task {
                    do {
                        // 3. destroy last record in blockHabitRepository
                        try await blockHabitRepository.destroyHabitRecord(lastRecord)
                        
                    } catch {
                        fatalError("DESTROYING DIDN'T WORK - ITS INVINCIBLE \(error)")
                    }
                }
                
                // Ensure that habits are updated for isCompleted
                updateHabitsIsCompletedForDay()
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



// MARK: Activity Details

/*
 * Honestly this should be moved to its own thing. It could even be
 * handled entirely within the ArchivedActivityDetailsView if there is
 * nowhere else that needs it (which I don't think there is)
 *
 * Alas, I don't feel like passing around the BlockHabitRepository right now
 */

public extension HabitController {
    
    var archivedActivityDetails: [ActivityDetail] {
        
        latestActivityDetails.filter { $0.isArchived == true }
    }
    
    
    var nonArchivedActivityDetails: [ActivityDetail] {
        
        latestActivityDetails.filter { $0.isArchived == false }
    }
    
    
    func populateActivityDetails() async {
        
        Task {
            do {
                let activityDetailsFromRepository = try await blockHabitRepository.readActivityDetails()
                
                await MainActor.run {
                    latestActivityDetails = activityDetailsFromRepository
                }
            } catch {
                fatalError("POPULATE THESE ACTIVITY DETAILS")
            }
        }
    }
    
    
    func archiveActivityDetail(_ activityDetail: ActivityDetail) {
        
        updateIsArchived(for: activityDetail, to: true)
    }
    
    
    func restoreActivityDetail(_ activityDetail: ActivityDetail) {

        updateIsArchived(for: activityDetail, to: false)
    }
    
    
    private func updateIsArchived(for activityDetail: ActivityDetail, to newIsArchivedValue: Bool) {
        
        Task { @MainActor in
            
            do {
                // Attempt to update in database first
                var archivedActivityDetail = activityDetail
                
                archivedActivityDetail.isArchived = newIsArchivedValue
                let id = archivedActivityDetail.id
                
                try await blockHabitRepository.updateActivityDetail(id: id, with: archivedActivityDetail)
                
                guard let archiveActivityDetailIndex = self.latestActivityDetails.firstIndex(of: activityDetail) else {
                    return
                }
                
                self.latestActivityDetails[archiveActivityDetailIndex].isArchived = newIsArchivedValue
                
            } catch {
                fatalError("EVERYONE IS TO BLAME FOR THIS TRAVESTY! \(error)")
            }
        }
    }
    
    
    func createActivityDetail(_ activityDetail: ActivityDetail) {
        
        Task {
            do {
                try await blockHabitRepository.createActivityDetail(activityDetail)
                
                DispatchQueue.main.async { [weak self] in
                    
                    guard let self else { return }
                    // Just immediately put it in memory so the views can look and be joyous
                    self.latestActivityDetails.append(activityDetail)
                }
            }
        }
    }
    
    
    func deleteActivityDetail(_ activityDetail: ActivityDetail) {
        Task {
            do {
                try await blockHabitRepository.destroyActivityDetail(activityDetail)
                
                guard let activityDetailToRemoveIndex = latestActivityDetails.firstIndex(where: { $0.id == activityDetail.id }) else {
                    throw NSError(domain: "BOYCE: Couldn't find index for (\(activityDetail.name), \(activityDetail.id)) in \(latestActivityDetails.map { ($0.name, $0.id) })", code: 1)
                }
                
                DispatchQueue.main.async { [weak self] in
                    
                    guard let self else { return }
                    
                    self.latestActivityDetails.remove(at: activityDetailToRemoveIndex)
                    
                    // We need to update the underlying `latestHabits` array
                    // then we need to update the isCompletedHabits (which
                    // is where our menu gets its data from), but latestHabits
                    // is first because that is where isCompletedHabits gets
                    // its data from
                    self.removeActivityDetails(withID: activityDetail.id, from: &self.latestHabits)
                    
                    // FIXME: Room for optimization - we don't need to actually calculate if everything is completed, we just need to remove the activity details for the habit. Which should be a shorter calculation.
                    updateHabitsIsCompletedForDay()
                }
            } catch {
                fatalError("Fix it. The ... yard trimmings... need to be removed. \(error)")
            }
        }
    }
    
    
    func removeActivityDetails(withID id: String, from habits: inout [Habit]) {
        
        for index in habits.indices {
            habits[index].activityDetails.removeAll { $0.id == id }
        }
    }

}

