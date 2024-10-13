//
//  DisplayDatePolicy.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/10/24.
//

import Foundation
import HabitRepositoryFW


final class DisplayDatePolicy {
    
    private init() {}
    
    
    /// When the task is retroactively completed, it will have a completionDate time of 23:59:59, so instead of showing that, we would rather
    /// display the creationDate' for activity records
    static func date(for activityRecord: HabitRecord, on selectedDay: Date) -> String {
        
        let timeDateFormatter: DateFormatter = .shortTime
        let dateTimeDateFormatter: DateFormatter = .shortDateShortTime
        
        guard let dayOfActivityCreation = activityRecord.creationDate.noon else {
            return "Unknown"
        }
        
        /*
        * The purpose: We want the user to only be able to edit a task's completionTime - and order
        * properly when it is changed, despite the creationDate having an entirely different date -
        * only display the creation date when it is unedited and created on another date
        */

        let completionTime = Calendar.current.dateComponents([.hour, .minute, .second], from: activityRecord.completionDate)
        
        var isCompletionTimeLastSecond: Bool {
            completionTime.hour == 23 && completionTime.minute == 59 && completionTime.second == 59
        }
        
        
        if isCompletionTimeLastSecond && dayOfActivityCreation != selectedDay {
            let dateTimeToFormat = activityRecord.creationDate
            return dateTimeDateFormatter.string(from: dateTimeToFormat).lowercased()
            
        } else {
            let timeToFormat = activityRecord.completionDate
            return timeDateFormatter.string(from: timeToFormat).lowercased()
        }
    }
}
