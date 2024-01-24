//
//  HabitMePrototypeApp.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/20/24.
//

import SwiftUI
import SwiftData


@main
struct HabitMePrototypeApp: App {
    
    let habitRepository = InMemoryHabitRepository()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DataHabit.self, DataHabitRecord.self])
    }
}
