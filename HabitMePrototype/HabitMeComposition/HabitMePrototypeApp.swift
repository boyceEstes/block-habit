//
//  HabitMePrototypeApp.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/20/24.
//

import SwiftUI
import SwiftData
import CoreData
import HabitRepositoryFW

import TipKit
import Combine
//@Observable class HabitMeController {
//    
//    private let habitController: HabitController
//    
//    var selectedDay: Date = Date()
//    var habitRecordsForDays: [Date: [HabitRecord]] = [:]
////    var completedHabits: [Habit] = []
////    var incompletedHabits: [Habit] = []
//    var isCompletedHabits = [IsCompletedHabit]()
//    
//    var cancellables = Set<AnyCancellable>()
//    
//    init(blockHabitRepository: BlockHabitRepository, selectedDay: Date) {
//        self.selectedDay = selectedDay
//        
//        self.habitController = HabitController(blockHabitRepository: blockHabitRepository, selectedDay: selectedDay)
//        
//        setupSubscriptions()
//    }
//    
//    
//    private func setupSubscriptions() {
//        
//        habitController.habitRecordsForDays
//            .dropFirst()
//            .sink { [weak self] hcHabitRecordsForDays in
//            self?.habitRecordsForDays = hcHabitRecordsForDays
//            print("hcHabitRecordsForDays: \(hcHabitRecordsForDays)")
//        }.store(in: &cancellables)
//        
//        
//        habitController.isCompletedHabits
//            .sink { [weak self] habits in
//                self?.isCompletedHabits = habits.sorted(by: { $0.habit.name < $1.habit.name })
//            }.store(in: &cancellables)
//        
//        // FIXME: 2 Switchup to deliver two lists, one complete and one incomplete for easier display
////        habitController.incompleteHabits
////            .sink { [weak self] habits in
////                self?.incompletedHabits = habits
////            }.store(in: &cancellables)
////        
////        
////        habitController.completeHabits
////            .sink { [weak self] habits in
////                self?.completedHabits = habits
////            }.store(in: &cancellables)
////        
////        
//        habitController.selectedDay
//            .sink { [weak self] date in
//                print("BOYCE: gets here")
//                self?.selectedDay = date
//            }.store(in: &cancellables)
//    }
//    
//    
//    func goToNextDay() {
//        
//        habitController.goToNextDay()
//    }
//    
//    
//    func goToPrevDay() {
//        let prevDay = selectedDay.adding(days: -1)
//        selectedDay = prevDay
////        habitController.goToPrevDay()
//    }
//}


class SomeCleanupForOldStore {

    // This is what the file was named by default
    static let datamodelName = "default"
    static let storeType = "sqlite"

    static let persistentContainer = NSPersistentContainer(name: datamodelName)
    
    private static let url: URL? = {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("\(datamodelName).\(storeType)")

        guard FileManager.default.fileExists(atPath: url.path) else { return nil }

        return url
    }()
    
    

    static func loadStores() {
        persistentContainer.loadPersistentStores(completionHandler: { (nsPersistentStoreDescription, error) in
            guard let error = error else {
                return // We should get an error because there is no store left
            }
            
            fatalError(error.localizedDescription)
        })
    }
    

    static func deleteAndRebuild() {
        
        guard let url = url else { return }
        
        try! persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: storeType, options: nil)

        loadStores()
    }
}



@main
struct HabitMePrototypeApp: App {
    
    /*
     * There is currently a store that was made by SwiftData
     * We need to ensure that we can use this same store to setup CoreData PersistentContainer
     * Do that logic in the initialization, here.
     */
    @State private var habitController: HabitController
    
    let blockHabitStore: CoreDataBlockHabitStore
//    var container: ModelContainer
    
    
    init() {
        
        try? Tips.configure()
        
        do {
            
            let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            

            
//            let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("default.store")
            
//            let config = ModelConfiguration(url: localStoreURL)
            
//            container = try ModelContainer(
//                for: DataHabit.self,
//                DataHabitRecord.self,
//                DataActivityDetail.self,
//                DataActivityDetailRecord.self,
//                configurations: config
//            )
            
            // this should only be for legacy device's that are still working off of the default.store persistent store
            SomeCleanupForOldStore.deleteAndRebuild()
            
            // new store will be named "block-habit.store" to distinguish the shift
            guard let localStoreURL = appSupportDir?.appendingPathComponent("block-habit.store") else {
                throw(NSError(domain: "any", code: 1))
            }
            
            let bundle = Bundle(for: CoreDataBlockHabitStore.self)
            blockHabitStore = try CoreDataBlockHabitStore(storeURL: localStoreURL, bundle: bundle)
            self.habitController = HabitController(blockHabitRepository: blockHabitStore, selectedDay: Date().noon!)

//            if let storeURL = container.mainContext.sqliteStore {
//                let bundle = Bundle(for: CoreDataBlockHabitStore.self)
//                blockHabitStore = try CoreDataBlockHabitStore(storeURL: storeURL, bundle: bundle)
//                
//                self.habitController = HabitController(blockHabitRepository: blockHabitStore, selectedDay: Date().noon!)
////                self.habitController = HabitController(
////                    blockHabitRepository: blockHabitStore,
////                    selectedDay: Date()
////                )
//            } else {
//                throw NSError(domain: "Could not find sqliteStore", code: 0)
//            }
        } catch {
            fatalError("Could not configure local store: '\(error)'")
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(blockHabitStore: blockHabitStore)
        }
//        .modelContainer(container)
        .environmentObject(habitController)
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
