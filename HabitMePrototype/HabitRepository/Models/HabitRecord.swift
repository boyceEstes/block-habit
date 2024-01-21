//
//  HabitRecord.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/21/24.
//

import Foundation


struct HabitRecord: Hashable {
    
    // Creation date is for those times that we will have selected a past day and added a habit record
    // to it. We will be adding it at the last possible hour/minute of the day so that it populates at
    // the end, but if we do two of those, we want to order by the one that was created latest.
    let creationDate: Date
    let completionDate: Date
    let habit: Habit
    
    static let habitRecords = [
        // Meditation logs
        // 16
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 16, hour: 9).date!,
            habit: Habit.journal
        ),
        // 17
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 10).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 10).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 17).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 17).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 18).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 17, hour: 18).date!,
            habit: Habit.meditation
        ),
        // 18
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 10).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 10).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 14).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 14).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 15).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 15).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 16).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 16).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 17).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 17).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate:  DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 18).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 18).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 20).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 20).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 23).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 18, hour: 23).date!,
            habit: Habit.journal
        ),
        // 19
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 18).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 18).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 19).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 19).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 20).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 20).date!,
            habit: Habit.meditation
        ),
        // 20
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 8).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 8).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 9).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 9).date!,
            habit: Habit.walkTheCat
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 18).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 18).date!,
            habit: Habit.reading
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 19).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 19).date!,
            habit: Habit.journal
        ),
        HabitRecord(
            creationDate:DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 20).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 20, hour: 20).date!,
            habit: Habit.meditation
        ),
        HabitRecord(
            creationDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 20).date!,
            completionDate: DateComponents(calendar: .current, timeZone: .current, year: 2024, month: 1, day: 19, hour: 20).date!,
            habit: Habit.reading
        )
    ]
}
