//
//  ActivityRecordCreationPolicy.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/5/24.
//

import Foundation



final class ActivityRecordCreationPolicy {
    
    private init() {}
    
    static func calculateDatesForRecord(on selectedDay: Date) -> (creationDate: Date, completionDate: Date) {
        
        
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
        
        return (today, newHabitRecordCompletionDate)
    }
}
