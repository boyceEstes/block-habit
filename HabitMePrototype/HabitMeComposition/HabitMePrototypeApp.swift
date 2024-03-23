//
//  HabitMePrototypeApp.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/20/24.
//

import SwiftUI
import SwiftData
import CoreData


@main
struct HabitMePrototypeApp: App {
    
    /*
     * There is currently a store that was made by SwiftData
     * We need to ensure that we can use this same store to setup CoreData PersistentContainer
     * Do that logic in the initialization, here.
     */
    
    let blockHabitStore: CoreDataBlockHabitStore
    var container: ModelContainer
    
    
    init() {
        
        do {
            let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("default.store")
            
            let config = ModelConfiguration(url: localStoreURL)
            
            container = try ModelContainer(
                for: DataHabit.self,
                DataHabitRecord.self,
                DataActivityDetail.self,
                DataActivityDetailRecord.self,
                configurations: config
            )

            if let storeURL = container.mainContext.sqliteStore {
                
                let bundle = Bundle(for: CoreDataBlockHabitStore.self)
                blockHabitStore = try CoreDataBlockHabitStore(storeURL: storeURL, bundle: bundle)
                
            } else {
                throw NSError(domain: "Could not find sqliteStore", code: 0)
            }
        } catch {
            fatalError("Could not configure local store: '\(error)'")
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(blockHabitStore: blockHabitStore)
        }
        .modelContainer(container)
//        .modelContainer(
//            for: [
//                DataHabit.self,
//                DataHabitRecord.self,
//                DataActivityDetail.self,
//                DataActivityDetailRecord.self
//            ]
//        ) { result in
//            do {
//                let container = try result.get()
//                
//                // Detect if we have already prepopulated the activity details
//                let descriptor = FetchDescriptor<DataActivityDetail>()
//                let existingActivityDetailCount = try container.mainContext.fetchCount(descriptor)
//                
//                // Only works when there are ZERO activity details loaded
//                guard existingActivityDetailCount == 0 else { return }
//                
//                // Load and decode the json that we have inserted
//                let resourceName = "ActivityDetailSeedData"
//                let resourceExtension = "json"
//                guard let url = Bundle.main.url(forResource: "\(resourceName)", withExtension: "\(resourceExtension)") else {
//                    fatalError("Failed to find '\(resourceName)' with '\(resourceExtension)' extension")
//                }
//                let data = try Data(contentsOf: url)
//                let decodedActivityDetails = try JSONDecoder().decode([DataActivityDetail].self, from: data)
//                
//                // Insert the objects that we have made from the JSON into the container context
//                for activityDetail in decodedActivityDetails {
//                    
//                    container.mainContext.insert(activityDetail)
//                }
//                
//            } catch {
//                print("FAILED to pre-seed the database: \(error.localizedDescription)")
//            }
//        }
    }
}
