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
    @State private var activityRecord: HabitRecord
    @State private var isHabitRecordDirty = false // Has it been changed?
    
    @State private var editableCompletionTime: Date = Date()
    @State private var showAlert: Bool = false
    @State private var alertDetail: AlertDetail? = nil
    @FocusState private var focused: Focusable?
    
    
    // FIXME: Ensure that Sorting the ActivityDetailRecords is working correctly
//    var sortedActivityRecordDetails: [ActivityDetailRecord] {
//
//        activityRecord.activityDetailRecords.bjSort()
//    }

    
    var navSubtitleDateString: String {
        DateFormatter.shortDate.string(from: activityRecord.completionDate)
    }
    
    
    init(activityRecord: HabitRecord) {
        
        self._activityRecord = State(initialValue: activityRecord)
    }
    
    /**
     * Basically what I need to happen is for the activity record to have all of its detail records displayed
     * When the activity detail record is modified it should update the original activity record
     * When we see that this has happened we should make a save button appear
     * Then we will save and update the activityRecord - we probably what to debounce this so we wait until the person has stopped typing for a set amount of time
     */
    
    var body: some View {
        ScrollView {
            let _ = print("---- This is an activity record on tapping to edit\(activityRecord)")
            LazyVStack(alignment: .leading, spacing: .vItemSpacing) {
                
//                let sortedActivityRecordDetailsCount = sortedActivityRecordDetails.count
                let activityDetailRecordCount = activityRecord.activityDetailRecords.count
                if activityDetailRecordCount > 0 {
                    ForEach(0..<activityDetailRecordCount, id: \.self) { i in
                        
                        let activityDetail = activityRecord.activityDetailRecords[i].activityDetail
//                        let valueBinding = valueBinding(for: sortedActivityRecordDetails[i])
                        
//                        let valueBinding = Binding {
//                            sortedActivityRecordDetails[i].value
//                        } set: { newValue in
//                            
//                        }
                        let valueBinding = $activityRecord.activityDetailRecords[i].value
//
                        switch activityDetail.valueType {
                        case .number:
                            NumberTextFieldRow(
                                title: activityDetail.name,
                                text: valueBinding,
                                units: activityDetail.availableUnits?.lowercased(),
                                focused: $focused,
                                focusID: i
                            )
                            
                        case .text:
                            TextFieldRow(
                                title: activityDetail.name,
                                text: valueBinding,
                                focused: $focused,
                                focusID: i
                            )
                        }
                    }
                }
                
                HStack {
                    Text("Completion Time")
                        .font(.rowDetail)
                    Spacer()
                    DatePicker("Completion Time", selection: $editableCompletionTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .sectionBackground(padding: .detailPadding)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .scrollDismissesKeyboard(.interactively)
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
        .onAppear {
            editableCompletionTime = activityRecord.completionDate
        }
        .onChange(of: editableCompletionTime) {
            // Adding this check to prevent from doing update logic when we first tap on the row
            if editableCompletionTime != activityRecord.completionDate {
                let new = DateFormatter.shortDateShortTime.string(from: editableCompletionTime)
                print("changed to \(new)")
                // FIXME: Can no longer update the DateTime
//                updateHabitRecord(activityRecord, withNewCompletionTime: editableCompletionTime)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if let previousIndex = previousTextFieldIndex {
                    Button("Prev") {
                        focused = .row(id: previousIndex)
                    }
                }
                if let nextIndex = nextTextFieldIndex {
                    Button("Next") {
                        focused = .row(id: nextIndex)
                    }
                }
                
                Button("Done") {
                    focused = nil
                }
            }
        }
        .sheetyTopBarNav(
            title: activityRecord.habit.name,
            subtitle: navSubtitleDateString,
            dismissAction: { dismiss() }
        )
    }
    
    
    
    // MARK: UI Helpers
    var previousTextFieldIndex: Int? {
        
        if case .row(let id) = focused {
            if id > 0 {
                return id - 1
            }
        }
        
        return nil
    }
    
    /// Returns the next text field index if it is available, if it is not possible to go to next  it will return nil
    var nextTextFieldIndex: Int? {
        
        if case .row(let id) = focused {
            if id < activityRecord.activityDetailRecords.count - 1 {
                return id + 1
            }
        }
        
        return nil
    }
    
    
//    private func valueBinding(for activityDetailRecord: ActivityDetailRecord) -> Binding<String> {
//        
//        return Binding {
//            activityDetailRecord.value
//        } set: { newValue in
//            activityDetailRecord.value = newValue
//        }
//    }
    
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
    // FIXME: Remove unnecessary SwiftData preview logic
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
        isArchived: false,
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
    

    let habitRecord = HabitRecord.preview
    
    return NavigationStack {
        HabitRecordDetailView(activityRecord: habitRecord)
    }
}
