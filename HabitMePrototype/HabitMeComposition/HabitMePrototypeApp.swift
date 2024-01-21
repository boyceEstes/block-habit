//
//  HabitMePrototypeApp.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/20/24.
//

import SwiftUI

@main
struct HabitMePrototypeApp: App {
    
    let habitRepository = InMemoryHabitRepository()
    
    var body: some Scene {
        WindowGroup {
            ContentView(habitRepository: habitRepository)
        }
    }
}
