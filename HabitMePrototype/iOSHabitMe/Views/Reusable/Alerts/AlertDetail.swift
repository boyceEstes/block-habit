//
//  AlertDetail.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/9/24.
//

import Foundation



struct AlertDetail {
    
    let title: String
    let message: String
    let actions: [ActionDetail]
    
    
    init(title: String, message: String, actions: [ActionDetail] = [.ok()]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    
    static func okAlert(title: String, message: String, buttonAction: @escaping () -> Void = { }) -> AlertDetail {
        
        AlertDetail(title: title, message: message, actions: [.ok(buttonAction: buttonAction)])
    }
    
    
    static func destructiveAlert(title: String, message: String, cancelAction: @escaping () -> Void = {}, destroyTitle: String, destroyAction: @escaping () -> Void) -> AlertDetail {
        
        AlertDetail(title: title, message: message, actions: [
            .cancel(buttonAction: cancelAction),
            ActionDetail(title: destroyTitle, role: .destructive, action: destroyAction)
        ])
    }
}
