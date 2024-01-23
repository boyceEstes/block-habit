//
//  SwiftDataHabitRepository.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/23/24.
//

import Foundation
import SwiftData

/*
 * We're going to be getting messy here. Just want to have a place that I can
 * provide all classes to do the same basic logic for inserting into the database
 *
 * It doesn't seem necessary on the fetching/querying side - or more like, it would
 * be more work than it is worth to do that part. So we'll just take it nice and dirty
 * for now adding what is ever convenient.
 *
 * This will NOT conform to the HabitRepository, just wanted to keep the name consistency.
 * Can extract out of Singleton format later if I want to make it more testable.
 */


final class SwiftDataHabitRepository {
    
    static let shared = SwiftDataHabitRepository()
    
    private init() {}
    
    func createHabitRecordOnDate(habit: DataHabit, selectedDay: Date, modelContext: ModelContext) {
        
        print("create habit record on selected date (for \(habit.name))")
        
        let today = Date()
        let todayNoon = today.noon!
        let selectedDay = selectedDay
        let selectedDateNoon = selectedDay.noon!
        
        var newHabitRecordCompletionDate: Date!
        

        if todayNoon == selectedDateNoon {
            // we do this because we want the exact time, for ordering purposes, on the given day
            newHabitRecordCompletionDate = today
        } else {
            // If the day has already passed (which is the only other option)
            // then we do not care the exact completionDate, and we will not be giving
            // we'll just get the latest most that we can come up with and make
            // the creationDate accurate for any sorting ties later additions would
            // make
            
            // Sets to the
            var selectedDayDateComponents = Calendar.current.dateComponents(in: .current, from: selectedDay)
            selectedDayDateComponents.hour = 23
            selectedDayDateComponents.minute = 59
            selectedDayDateComponents.second = 59
            
            newHabitRecordCompletionDate = selectedDayDateComponents.date!
        }
        
        print("tapped habit data")
        
        let newHabitRecord = DataHabitRecord(creationDate: today, completionDate: newHabitRecordCompletionDate, habit: habit)
        
        modelContext.insert(newHabitRecord)

    }
}
