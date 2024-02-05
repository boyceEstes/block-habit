//
//  CreateHabitRecordWithDetailsView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/3/24.
//

import SwiftUI
import SwiftData



struct CreateHabitRecordWithDetailsView: View, ActivityRecordCreatorWithDetails {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // We pass this in and use its information along with the current
    // datetime to autopopulate some details
    let activity: DataHabit
    let selectedDay: Date
    let creationDate = Date()
//    @State private var activityRecord: DataHabitRecord
    // Keeping this separate from the above property just because SwiftData is a little finicky
    // and I want things in smaller pieces for making the relationship connections
    @State var activityDetailRecords: [ActivityDetailRecord]
    @FocusState var isActive: Bool
    
    init(activity: DataHabit, selectedDay: Date) {
        
        self.activity = activity
        self.selectedDay = selectedDay

        self._activityDetailRecords = State(
            initialValue: activity.activityDetails.map { activityDetail in
                
                print("Looping through activitydetails to create DataActivityDetailRecords \(activityDetail.name)")
                
                return ActivityDetailRecord(
                    activityDetail: activityDetail, 
                    value: ""
                )
            }
        )
        
        // Maybe I should wait until after we enter the information to do this part?
        // I'm not sure how this will work, inserting this information into activityRecord now
        // is that a circular reference?
//        self.activityRecord.activityDetailRecords = activityRecordDetails
        
        
        // This should possibly be set later. Lets just try to set the variables now and update them
        // later after we hit the create button to prevent fun weird stuff happening.
    }
    
    @State private var testing = "Testing"
    
    var body: some View {
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                if !activityDetailRecords.isEmpty {

                    ForEach($activityDetailRecords, id: \.id) { $activityDetailRecord in
                            
                        let activityDetail =
                        activityDetailRecord.activityDetail
                        
                        
                        switch activityDetail.valueType {
                        case .number:
                            EditableActivityDetailNumberView(
                                name: activityDetail.name,
                                units: activityDetail.availableUnits.first?.lowercased(),
                                textFieldValue: $activityDetailRecord.value
                            )
                        case .text:
                            TextField(activityDetail.name, text: $activityDetailRecord.value, axis: .vertical)
                                .focused($isActive)
                                .lineLimit(4)
                                .sectionBackground()
                        }
                    }
                } else {
                    Text("There are no activity record details")
                }
            }
            .padding(.horizontal)
        }

        
        .topBar {
            Text(activity.name)
                .font(.navTitle)
        } topBarTrailingContent: {
            HabitMeSheetDismissButton(dismiss: { dismiss() })
        }
        
        .bottomBar {
            HabitMePrimaryButton(
                title: "Record Activity",
                action: didTapCreateActivityRecord
            )
            .padding()
        }
    }
    
    
    // MARK: UI Helpers
//    private func valueBinding(for activityDetailRecord: ActivityDetailRecord) -> Binding<String> {
//        
//        return Binding {
//            activityDetailRecord.value
//            
//        } set: { newValue in
//            activityDetailRecord.value = newValue
//        }
//    }
    
    
    // MARK: Logic
    private func didTapCreateActivityRecord() {

        // We already have the DataHabit so we just need to create the DataHabitRecord
        // and make the DataActivityDetailRecord objects to insert into that DataHabitRecord
        createRecord(for: activity, in: modelContext)
        
        DispatchQueue.main.async {
            dismiss()
        }
    }
}


#Preview {
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
    
//    activity.activityDetails = decodedActivityDetails
    
    for activityDetail in activity.activityDetails {
        
        activityDetail.habits.append(activity)
    }

    
    return NavigationStack {
        CreateHabitRecordWithDetailsView(activity: activity, selectedDay: Date())
    }
    .modelContainer(container)
}
