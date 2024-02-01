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
        .modelContainer(
            for: [
                DataHabit.self,
                DataHabitRecord.self,
                DataActivityDetail.self,
                DataActivityDetailRecord.self
            ]
        ) { result in
            do {
                let container = try result.get()
                
                // Detect if we have already prepopulated the activity details
                let descriptor = FetchDescriptor<DataActivityDetail>()
                let existingActivityDetailCount = try container.mainContext.fetchCount(descriptor)
                
                guard existingActivityDetailCount == 0 else { return }
                
                // Load and decode the json that we have inserted
                let resourceName = "ActivityDetailSeedData"
                let resourceExtension = "json"
                guard let url = Bundle.main.url(forResource: "\(resourceName)", withExtension: "\(resourceExtension)") else {
                    fatalError("Failed to find '\(resourceName)' with '\(resourceExtension)' extension")
                }
                let data = try Data(contentsOf: url)
                let decodedActivityDetails = try JSONDecoder().decode([DataActivityDetail].self, from: data)
                
                // Insert the objects that we have made from the JSON into the container context
                for activityDetail in decodedActivityDetails {
                    
                    container.mainContext.insert(activityDetail)
                }
                
            } catch {
                print("FAILED to pre-seed the database: \(error.localizedDescription)")
            }
        }
    }
}
