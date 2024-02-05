//
//  HabitRecordDetailView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/24.
//

import SwiftUI
import SwiftData


enum HabitRecordDetailAlert {
    case areYouSure(yesAction: () -> Void)
    
    func alertData() -> AlertDetail {
        
        switch self {
        case let .areYouSure(yesAction):
            return AlertDetail.destructiveAlert(
                title: "Are you sure?",
                message: "This will delete the record. You'll have to tap a whole button to put another one back. Then another few buttons to edit the time to this record's time. Big steaks.",
                destroyTitle: "Exterminate Record",
                destroyAction: yesAction
            )
        }
    }
}

struct HabitRecordDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // We only want to be able to edit their time, always maintain the date.
    let activityRecord: DataHabitRecord
    
    @State private var editableCompletionTime: Date = Date()
    @State private var showAlert: Bool = false
    @State private var alertDetail: AlertDetail? = nil
    
    var body: some View {
        ScrollView {
            let _ = print("---- This is an activity record on tapping to edit\(activityRecord)")
            LazyVStack(alignment: .leading, spacing: 20) {
                
                if !activityRecord.activityDetailRecords.isEmpty {
                    ForEach(activityRecord.activityDetailRecords) { activityDetailRecord in
                        
                        let activityDetail =
                        activityDetailRecord.activityDetail
                        let valueBinding = valueBinding(for: activityDetailRecord)
                        
                        switch activityDetail.valueType {
                        case .number:
                            EditableActivityDetailNumberView(
                                name: activityDetail.name,
                                units: activityDetail.availableUnits.first?.lowercased(),
                                textFieldValue: valueBinding
                            )
                        case .text:
                            TextField(activityDetail.name, text: valueBinding, axis: .vertical)
                                .lineLimit(4)
                                .sectionBackground()
                        }
                    }
                } else {
                    Text("There are no activity record details")
                }
                HStack {
                    Text("Completion Time")
                        .font(.sectionTitle)
                    Spacer()
                    DatePicker("Completion Time", selection: $editableCompletionTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .sectionBackground()
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.background)
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
        .onAppear {
            editableCompletionTime = activityRecord.completionDate
        }
        .onChange(of: editableCompletionTime) {
            // Adding this check to prevent from doing update logic when we first tap on the row
            if editableCompletionTime != activityRecord.completionDate {
                let new = DateFormatter.shortDateShortTime.string(from: editableCompletionTime)
                print("changed to \(new)")
                updateHabitRecord(activityRecord, withNewCompletionTime: editableCompletionTime)
            }
        }
        
        .topBar {
            VStack(alignment: .leading) {
                Text(activityRecord.habit?.name ?? "Could Not Find Habit")
                    .font(.navTitle)
                Text(DateFormatter.shortDate.string(from: activityRecord.completionDate))
                    .font(.navSubtitle)
            }
        } topBarTrailingContent: {
            HabitMeSheetDismissButton(dismiss: { dismiss() })
        }

    }
    
    
    
    // MARK: UI Helpers
    private func valueBinding(for activityDetailRecord: DataActivityDetailRecord) -> Binding<String> {
        
        return Binding {
            activityDetailRecord.value
        } set: { newValue in
            activityDetailRecord.value = newValue
        }
    }
    
//    
//    // MARK: Logic
//    private func didTapButtonToUpdateActivityRecord() {
//        print("did tap button to update activity record)")
//    }
    
    
    
    private func removeHabitRecord(_ habitRecord: DataHabitRecord) {
        
        DispatchQueue.main.async {
            
            modelContext.delete(habitRecord)
            
            dismiss()
        }
    }
    
    
    private func updateHabitRecord(_ habitRecord: DataHabitRecord, withNewCompletionTime newCompletionTime: Date) {
        
        habitRecord.completionDate = newCompletionTime
    }
}


struct EditableActivityDetailNumberView: View {
    
    let name: String
    let units: String?
//    let activityDetailRecord: DataActivityDetailRecord
    @Binding var textFieldValue: String
//
//    
//    init(activityDetailRecord: DataActivityDetailRecord) {
//        
//        self.activityDetailRecord = activityDetailRecord
//        
//        self._textFieldValue = State(initialValue: activityDetailRecord.value)
//    }
    
    
    var body: some View {
        
//        let activityDetail = activityDetailRecord.activityDetail
//        let units = activityDetail.availableUnits.first?.lowercased()
        
        HStack {
//            Text("\(activityDetail.name)")
            Text(name)
                .font(.sectionTitle)
            Spacer()
            VStack {
                NumberTextField(
                    "\(name)",
                    text: $textFieldValue,
                    units: units
                )
            }
        }
        .sectionBackground()
    }
}


struct HabitMeDeleteButton: View {
    
    let deleteAction: () -> Void
    
    var body: some View {
        Button {
            
            deleteAction()
        } label: {
            Image(systemName: "trash")
                .foregroundStyle(Color.red)
                .font(.title2)
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    // MARK: Load ActivityDetails
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

    
//    // MARK: Create Activity Record
    let activityRecord = DataHabitRecord(
        creationDate: Date(),
        completionDate: Date().adding(days: -1),
        habit: activity
    )
    
    container.mainContext.insert(activityRecord)

    // MARK: Create Activity Detail Record
    for activityDetail in decodedActivityDetails {
        
        let activityDetailRecord = DataActivityDetailRecord(
            value: "",
            activityDetail: activityDetail,
            activityRecord: activityRecord
        )
        
        container.mainContext.insert(activityDetailRecord)
    }
    

    
    return NavigationStack {
        HabitRecordDetailView(activityRecord: activityRecord)
    }
}
