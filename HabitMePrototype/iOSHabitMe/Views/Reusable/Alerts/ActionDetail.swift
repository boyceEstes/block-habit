//
//  ActionDetails.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/9/24.
//

import SwiftUI

struct ActionDetail: Hashable {
    
    let title: String
    let role: ButtonRole?
    let action: () -> Void
    
    
    init(title: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    
    public static func == (lhs: ActionDetail, rhs: ActionDetail) -> Bool {
        lhs.title == rhs.title
    }
    
    
    static func ok(buttonAction: @escaping (() -> Void) = {}) -> ActionDetail {
        ActionDetail(title: .ok, action: buttonAction)
    }
    
    
    static func cancel(buttonAction: @escaping (() -> Void) = {}) -> ActionDetail {
        ActionDetail(title: .cancel, role: .cancel, action: buttonAction)
    }
}

