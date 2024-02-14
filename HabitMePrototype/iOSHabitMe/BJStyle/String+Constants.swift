//
//  String+Constants.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/10/24.
//

import Foundation


extension String {
    
    static let notAvailable = "N/A"
    
    // Basic Alerts
    static let ok = "OK"
    static let cancel = "Cancel"
    
    
    // Calculation Type
    static let calculationTypExplanation = "Calculation type is used to dictate how the detail values will be combined if there are multiple on the same day."
    static let sumExplanation = "'Sum' will add all of the detail records together over some amount of time. If you were reading for 30 min and then read again for 25 min, this would be displayed as 55 min."
    static let avgExplanation = "'Average' will average all of the detail records together over some amount of time. If you logged your weight in the morning for 190lbs and at night for 200lbs, this would be displayed as 195 lbs for the day"
    
    
    // delete activity detail
    static let deleteActivityDetail_alertTitle = "Danger Zone!"
    static let deleteActivityDetail_alertMessage = "By deleting this, you would be deleting all the statistics associated. That's crazy, no? You can always archive it if you don't want to look at it right now."
    
    static let deleteActivityDetail_archiveActionTitle = "Archive"
    static let deleteActivityDetail_deleteActionTitle = "Seriously, Delete It"
}
