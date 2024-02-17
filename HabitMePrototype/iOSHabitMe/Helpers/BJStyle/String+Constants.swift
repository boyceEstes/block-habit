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
    static let archive = "Archive"
    static let delete = "Delete"
    
    
    // Calculation Type
    static let calculationTypExplanation = "Calculation type is used to dictate how the detail values will be combined if there are multiple on the same day."
    static let sumExplanation = "Example (Sum Type): If you Read for 15 minutes in the morning and 20 min at night, you will have 35 min logged for the day"
    static let avgExplanation = "Example (Average Type): If you logged your weight in the morning for 190lbs and at night for 200lbs, this would be displayed as 195 lbs for the day"
    
    // add details
    static let addActivityDetails_navTitle = "Select Activity Details"
    
    // delete activity detail
    static let deleteActivityDetail_alertTitle = "Danger Zone!"
    static let deleteActivityDetail_alertMessage = "By deleting this, you would be deleting all the statistics associated. That's crazy, no? You can always archive it if you don't want to look at it right now."
    
    static let deleteActivityDetail_archiveActionTitle = "Archive"
    static let deleteActivityDetail_deleteActionTitle = "Seriously, Delete It"
}
