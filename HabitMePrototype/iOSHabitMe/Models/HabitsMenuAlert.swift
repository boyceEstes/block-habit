//
//  HabitsMenuAlert.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/9/24.
//

import Foundation


enum HabitsMenuAlert {
    
    case deleteHabit(yesAction: () -> Void)
    
    
    func alertData() -> AlertDetail {
        
        switch self {
        case let .deleteHabit(yesAction):
            return AlertDetail.destructiveAlert(
                title: "Are you sure?",
                message: "This will delete all of the habit's associated records as well 👀",
                destroyTitle: "Destroy It All",
                destroyAction: yesAction
            )
        }
    }
}
