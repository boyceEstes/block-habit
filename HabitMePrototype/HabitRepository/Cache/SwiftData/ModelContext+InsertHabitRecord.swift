//
//  ModelContext+InsertHabitRecord.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/30/24.
//

import SwiftData
import Foundation


extension ModelContext {
    
    
    // FIXME: Uncomment when we know how we are going to insert new habit records
    func createHabitRecordOnDate(
        activity: DataHabit,
        creationDate: Date,
        completionDate: Date,
        activityDetailRecords: [ActivityDetailRecord] = []
    ) {
        
        print("create habit record")
//        let activityRecord = DataHabitRecord(
//            creationDate: creationDate,
//            completionDate: completionDate,
//            habit: nil,
//            activityDetailRecords: []
//        )
//        
//        activityRecord.habit = activity
//        
//        self.insert(activityRecord)
//        
//        
//        for activityDetailRecord in activityDetailRecords {
//            
//            let dataActivityDetailRecord = DataActivityDetailRecord(
//                value: activityDetailRecord.value,
//                activityDetail: activityDetailRecord.activityDetail,
//                activityRecord: activityRecord
//            )
//            
//            self.insert(dataActivityDetailRecord)
//        }
    }
    
    // ----- old commented out stuff TODO: REMOVE OLD STUFF IF NOT NEEDED
//
//        print("create habit record on selected date (for \(habit.name))")
//        
//        let today = Date()
//        let todayNoon = today.noon!
//        let selectedDay = selectedDay
//        let selectedDateNoon = selectedDay.noon!
//        
//        var newHabitRecordCompletionDate: Date!
//        
//
//        if todayNoon == selectedDateNoon {
//            // we do this because we want the exact time, for ordering purposes, on the given day
//            newHabitRecordCompletionDate = today
//        } else {
//            // If the day has already passed (which is the only other option)
//            // then we do not care the exact completionDate, and we will not be giving
//            // we'll just get the latest most that we can come up with and make
//            // the creationDate accurate for any sorting ties later additions would
//            // make
//            
//            // Sets to the
//            var selectedDayDateComponents = Calendar.current.dateComponents(in: .current, from: selectedDay)
//            selectedDayDateComponents.hour = 23
//            selectedDayDateComponents.minute = 59
//            selectedDayDateComponents.second = 59
//            
//            newHabitRecordCompletionDate = selectedDayDateComponents.date!
//        }
//        
//        print("tapped habit data")
//        
//        let newHabitRecord = DataHabitRecord(
//            creationDate: today,
//            completionDate: newHabitRecordCompletionDate,
//            habit: nil,
//            activityDetailRecords: []
//        )
//        newHabitRecord.habit = habit
//        habit.habitRecords.append(newHabitRecord) -- saw this was less efficient here: https://fatbobman.com/en/posts/relationships-in-swiftdata-changes-and-considerations/
        // Inseting multiple rows, compose your own temporary array of habitrecords and then append them to the parents array of records so that it needs to do less
        
//        self.insert(newHabitRecord)
//    }
}
