//
//  Array+HabitRecordsForDays.swift
//  HabitRepositoryFW
//
//  Created by Boyce Estes on 5/3/24.
//

import Foundation


public extension Array where Element == HabitRecord {
    
    ///
    /// `currentDate` is used to know how to know how may dates to deliver back in the habitRecordForDays dictionary - There must be at least delimiter amount to fill the screen. currentDate does not need to be noon, it will be converted automatically, so just the whatever date can be given
    /// `delimiter` is the minimum number of dates to deliver back in the dictionary, even if there are no records available
    /// This array is expected to be sorted, with the first index being the earliest completion dated.
    func toHabitRecordsForDays(onCurrentDate date: Date, delimiter: Int = 7) -> [Date: [HabitRecord]] {
        
        guard let currentDateNoon = date.noon else { return [:] }
        
        let bufferDaysForHabitRecordsForDays = bufferDaysForHabitRecordsForDays(currentDay: date, delimiter: delimiter)
        
        var daysForDict = 0
        if let earliestRecordDate = self.last?.completionDate {
            // earliest date is today - which is the same as current date
            // if the earliest date was another day, like Date-3, we'd have a buffer day for habit records of 3, right? yeah and from there we'd want to get 3 days before the current day. But since this is the current day we don't
//            if earliestRecordDate == date { bufferDaysForHabitRecordsForDays + 1 }

            let numOfDaysToEarliestRecord = Calendar.current.dateComponents([.day], from: earliestRecordDate, to: currentDateNoon).day ?? 0
            
            daysForDict = numOfDaysToEarliestRecord + bufferDaysForHabitRecordsForDays
            
            print("earliest record day: \(earliestRecordDate) - number of days from current day to earliest day \(daysForDict)")
        } else {
            daysForDict = bufferDaysForHabitRecordsForDays
        }
        
        
        var recordsForDays = [Date: [HabitRecord]]()
        
        
        for record in self {
            
            guard let noonDate = record.completionDate.noon else { return [:] }
            
            if recordsForDays[noonDate] != nil {
                recordsForDays[noonDate]?.append(record)
            } else {
                recordsForDays[noonDate] = [record]
            }
        }
        
        
        // Just fillin in the blanks
        for i in 0..<daysForDict {
            
            let dictDate = currentDateNoon.adding(days: -i)
            
            if recordsForDays[dictDate] == nil {
                recordsForDays[dictDate] = []
            }
        }
        
        return recordsForDays
    }
    
    
    /// Delivers the number of buffer days that should be given to pad out the habitRecordsForDays dictionay, if there are not the minimum delimiter amount - this makes the chart look more full even when you have nothing in it
    /// Expected  to be given currentDay at noon - if it is not not noon, things might be a little messed up because everything is saved by noon so subtractions by day might not work accurately
    func bufferDaysForHabitRecordsForDays(currentDay: Date, delimiter: Int) -> Int {
        
        if self.isEmpty {
            return delimiter
            
        } else if let earliestRecordDate = self.last?.completionDate,
                  let numDaysBetweenEarliestToCurrent = Calendar.current.dateComponents([.day], from: earliestRecordDate, to: currentDay).day,
                      numDaysBetweenEarliestToCurrent < delimiter {
                
            // There is more than the minimum days between today and the earliest record, no buffer needed
            return delimiter - numDaysBetweenEarliestToCurrent
        } else {
            // There is more than the minimum days between today and the earliest record, no buffer needed
            return 0
        }
    }
}
