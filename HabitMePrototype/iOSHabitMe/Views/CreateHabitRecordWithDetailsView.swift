//
//  CreateHabitRecordWithDetailsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI
import SwiftData


enum Focusable: Hashable {
    
    case none
    case row(id: Int)
}


struct CreateHabitRecordWithDetailsView: View, ActivityRecordCreatorWithDetails {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // We pass this in and use its information along with the current
    // datetime to autopopulate some details
    let activity: Habit
    let selectedDay: Date
    let blockHabitStore: CoreDataBlockHabitStore
    
    let creationDate = Date()
//    @State private var activityRecord: DataHabitRecord
    // Keeping this separate from the above property just because SwiftData is a little finicky
    // and I want things in smaller pieces for making the relationship connections
    @State var activityDetailRecords: [ActivityDetailRecord] {
        didSet {
            print("BOYCE: DidSet activityDetailRecords in CreateHabitRecordWithDetailsView: \(activityDetailRecords.count)")
        }
    }
    @FocusState var focusedActivityDetail: Focusable?
    
    init(
        activity: Habit,
        selectedDay: Date,
        blockHabitStore: CoreDataBlockHabitStore
    ) {
        
        self.activity = activity
        self.selectedDay = selectedDay
        self.blockHabitStore = blockHabitStore

        self._activityDetailRecords = State(
            initialValue: activity.activityDetails.bjSort()
                .map { activityDetail in
                    
                    print("Looping through activitydetails to create DataActivityDetailRecords \(activityDetail.name)")
                    
                    return ActivityDetailRecord(
                        value: "",
                        unit: activityDetail.availableUnits,
                        activityDetail: activityDetail
                    )
                }
        )
        
        print("BOYCE: activityDetailRecords after initializing the state - '\(activityDetailRecords.count)'")
        
        // Maybe I should wait until after we enter the information to do this part?
        // I'm not sure how this will work, inserting this information into activityRecord now
        // is that a circular reference?
//        self.activityRecord.activityDetailRecords = activityRecordDetails
        
        
        // This should possibly be set later. Lets just try to set the variables now and update them
        // later after we hit the create button to prevent fun weird stuff happening.
    }
    
    var body: some View {
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .vItemSpacing) {
                
                let activityDetailRecordsCount = activityDetailRecords.count
                if activityDetailRecordsCount > 0 {

                    ForEach(0..<activityDetailRecordsCount, id: \.self) { i in
                            
                        let activityDetail =
                        activityDetailRecords[i].activityDetail
                        let units = activityDetail.availableUnits?.lowercased()

                        if activityDetail.valueType == .number {
                            
                            NumberTextFieldRow(
                                title: activityDetail.name,
                                text: self.$activityDetailRecords[i].value, 
                                units: units,
                                focused: $focusedActivityDetail,
                                focusID: i
                            )
                            
                        } else {
                            
                            TextFieldRow(
                                title: activityDetail.name,
                                text: self.$activityDetailRecords[i].value,
                                focused: $focusedActivityDetail,
                                focusID: i
                            )
                        }
                    }
                } else {
                    Text("There are no activity record details")
                }
            }
            .padding(.horizontal)
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if let previousIndex = previousTextFieldIndex {
                    Button("Prev") {
                        print("prev")
                        focusedActivityDetail = .row(id: previousIndex)
                    }
                }
                if let nextIndex = nextTextFieldIndex {
                    Button("Next") {
                        print("next")
                        focusedActivityDetail = .row(id: nextIndex)
                    }
                } else {
                    Button("Done") {
                        print("done")
                        focusedActivityDetail = nil
                    }
                }
            }
        }
        .sheetyTopBarNav(title: activity.name, dismissAction: { dismiss() })
        .sheetyBottomBarButton(title: "Record Activity", action: didTapCreateActivityRecord)
    }
    
    
    // MARK: UI Helpers
    /// Returns the previous text field index if it is available, if it is not possible to go back it will return nil
    var previousTextFieldIndex: Int? {
        
        if case .row(let id) = focusedActivityDetail {
            if id > 0 {
                return id - 1
            }
        }
        
        return nil
    }
    
    /// Returns the next text field index if it is available, if it is not possible to go to next  it will return nil
    var nextTextFieldIndex: Int? {
        
        if case .row(let id) = focusedActivityDetail {
            if id < activityDetailRecords.count - 1 {
                return id + 1
            }
        }
        
        return nil
    }
    
    // MARK: Logic
    private func didTapCreateActivityRecord() {

        // We already have the DataHabit so we just need to create the DataHabitRecord
        // and make the DataActivityDetailRecord objects to insert into that DataHabitRecord
        Task {
            do {
                try await createRecord(for: activity, in: blockHabitStore)
                
                DispatchQueue.main.async {
                    dismiss()
                }
            } catch {
                // FIXME: 2 - Handle error better on create habit record
                fatalError("Something went wrong creating from the record with details view \(error)")
            }
        }
    }
}


#Preview {
    
    let habit = Habit.preview
    // FIXME: Remove the unnecessary preview setup after moving to independent model methodology
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    // MARK: Create ActivityDetails
    let resourceName = "ActivityDetailSeedData"
    let resourceExtension = "json"
    guard let url = Bundle.main.url(forResource: "\(resourceName)", withExtension: "\(resourceExtension)") else {
        fatalError("Failed to find '\(resourceName)' with '\(resourceExtension)' extension")
    }
    let data = try! Data(contentsOf: url)
    let decodedActivityDetails = try! JSONDecoder().decode([DataActivityDetail].self, from: data)
    
    // Save to the model container
    for activityDetail in decodedActivityDetails {
        container.mainContext.insert(activityDetail)
    }
    

    // MARK: Create Activity
    let activity = DataHabit(
        name: "Chugged Dew",
        color: Color.indigo.toHexString() ?? "#FFFFFF",
        activityDetails: [],
        habitRecords: []
    )
    
    container.mainContext.insert(activity)
    
    activity.activityDetails = decodedActivityDetails
    
    for activityDetail in activity.activityDetails {
        
        activityDetail.habits.append(activity)
    }

    
    return NavigationStack {
        CreateHabitRecordWithDetailsView(
            activity: habit,
            selectedDay: Date(),
            blockHabitStore: CoreDataBlockHabitStore.preview()
        )
    }
    .modelContainer(container)
}
