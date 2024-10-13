//
//  ActivityDetailType.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/14/24.
//

import Foundation


public enum ActivityDetailType: String, CaseIterable, Identifiable, Hashable, Codable {
    
    // Very important to have these exact rawValues because they are used to decode seed data
    case number = "Number"
    case text = "Text"
    
    public var id: ActivityDetailType { self }
}
