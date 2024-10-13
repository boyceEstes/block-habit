//
//  ActivityDetailCalculationType.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/14/24.
//

import Foundation

public enum ActivityDetailCalculationType: String, CaseIterable, Identifiable, Hashable, Codable  {
     
    case sum = "Sum"
    case average = "Average"
    
    public var id: ActivityDetailCalculationType { self }
}
