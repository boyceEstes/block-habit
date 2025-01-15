//
//  AddDetailSelectionView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/31/24.
//

import SwiftUI
import SwiftData
import HabitRepositoryFW


enum AddDetailsAlert {
    
    case deleteActivityRecordWarning(
        deleteAction: () -> Void,
        archiveAction: () -> Void
    )
    
    func alertData() -> AlertDetail {
        
        switch self {
            
        case let .deleteActivityRecordWarning(deleteAction, archiveAction):
            
            return AlertDetail(
                title: .deleteActivityDetail_alertTitle,
                message: .deleteActivityDetail_alertMessage,
                actions: [
                    ActionDetail.cancel(),
                    ActionDetail(
                        title: .deleteActivityDetail_archiveActionTitle,
                        role: .none,
                        action: archiveAction
                    ),
                    ActionDetail(
                        title: .deleteActivityDetail_deleteActionTitle,
                        role: .destructive,
                        action: deleteAction
                    )
                ]
            )
        }
    }
}


struct AddDetailsView: View {
    
    @EnvironmentObject var habitController: HabitController
    @Environment(\.editMode) var editMode
    @Environment(\.dismiss) var dismiss
//    @Environment(\.modelContext) var modelContext
//    @Query(filter: #Predicate<DataActivityDetail> { activityDetail in
//        activityDetail.isArchived == false
//    }, sort: [
//        SortDescriptor(\DataActivityDetail.creationDate, order: .reverse),
//        SortDescriptor(\DataActivityDetail.name, order: .forward)
//    ], animation: .default) var activityDetails: [DataActivityDetail]
    
    private var activityDetails: [ActivityDetail] {
        habitController.nonArchivedActivityDetails
    }
    
    @State private var activityDetailsWithSelection: [ActivityDetail: Bool]
    @State private var alertDetail: AlertDetail?
    @State private var showAlert = false
    
    @Binding var selectedDetails: [ActivityDetail]
    let goToCreateActivityDetail: () -> Void
    let detailSelectionColor: Color
    let originalSelectedDetails: [ActivityDetail]
    
    init(
        selectedDetails: Binding<[ActivityDetail]>,
        detailSelectionColor: Color?,
        goToCreateActivityDetail: @escaping () -> Void
    ) {
        
        self._selectedDetails = selectedDetails
        self.originalSelectedDetails = selectedDetails.wrappedValue
        self.detailSelectionColor = detailSelectionColor ?? .blue
        self.goToCreateActivityDetail = goToCreateActivityDetail
        
        // Had to create this with a specific initialization, otherwise it would be implicitly
        // initializedand this would happen later, after the view has appeared
        self._activityDetailsWithSelection = State(
            initialValue: selectedDetails.reduce(into: [ActivityDetail: Bool](), {
                $0[$1.wrappedValue] = true
        }))
    }
    

    var body: some View {
        
//        ScrollView {
//            LazyVStack {
//                ForEach(activityDetails) { activityDetail in
//                    
//                }
//            }
//        }
//        VStack {
            
        List {
            Section {
                HStack {
                    //                    Button("Reset") {
                    //                        removeAllSelections()
                    //                    }
                    //                        .font(.headline)
                    //                        .foregroundStyle(.blue)
                    //
                    //
                    Spacer()
                    Button {
                        goToCreateActivityDetail()
                    } label: {
                        Label("New Detail", systemImage: "plus.circle")
                        //                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                        
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listStyle(.plain)
                .padding(.vertical, 8)
            }
            
            
            if !activityDetails.isEmpty {
                Section {
                    ForEach(activityDetails) { activityDetail in
                        VStack(alignment: .leading, spacing: .vRowSubtitleSpacing) {
                            ActivityDetailBasicInfo(activityDetail: activityDetail)
                            
                        }
                        .padding(.vertical, 4)
                        .swipeActions {
                            Button {
                                // FIXME: Make sure archival for activity detail works
                                archiveActivityDetails(activityDetail)
                            } label: {
                                Label(String.archive, systemImage: "archivebox.fill")
                            }
                            .tint(.indigo)
                            //
                            //                        Button(role: .destructive) {
                            //                            // FIXME: Make sure deletion for activity detail works
                            //                            warnBeforeDeletion(activityDetail)
                            //                        } label: {
                            //                            Label(String.delete, systemImage: "trash.fill")
                            //                        }
                        }
                        .sectionBackground(padding: .detailPadding, color: .secondaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: .cornerRadius)
                                .stroke((activityDetailsWithSelection[activityDetail] ?? false) ? detailSelectionColor : .clear, lineWidth: 3)
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: .detailSelectionHorizontalPadding, bottom: 4, trailing: .detailSelectionHorizontalPadding))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Do not allow to select if we are editing
                            if !(editMode?.wrappedValue.isEditing ?? false) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    toggleSelection(for: activityDetail)
                                }
                            }
                        }
                    }
                } footer: {
                    Text("Choose Details that you would like to record each time you complete your Habit Block")
                        .font(.caption)
                        .listRowSeparator(.hidden)
                }
            } else {
                
                Section {
                    Text("No Details available to track with your Habits... You might need to make one 🙊")
                        .listRowSeparator(.hidden)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 16)
            }
        }
    
        
        
//            List {
//                SectionWithDisclaimerIfEmpty(
//                    isEmpty: activityDetails.isEmpty) {
//                        ForEach(activityDetails) { activityDetail in
//                            //                    let activityDetail = dataActivityDetail.toModel()
//                            
//                            VStack(alignment: .leading, spacing: .vRowSubtitleSpacing) {
//                                
//                                ActivityDetailBasicInfo(activityDetail: activityDetail)
//                                
//                                HStack(alignment: .firstTextBaseline) {
//                                    
//                                    Text("Ex. \"\(activityDetail.example)\"")
//                                        .foregroundStyle(.secondary)
//                                        .font(.rowDetail)
//                                    
//                                    Spacer()
//                                    
//                                    if activityDetail.valueType == .number {
//                                        Text("[\(activityDetail.calculationType.rawValue)]")
//                                            .foregroundStyle(.secondary)
//                                            .font(.rowDetail)
//                                    }
//                                }
//                            }
//                            .swipeActions {
//                                Button {
//                                    // FIXME: Make sure archival for activity detail works
//                                    archiveActivityDetails(activityDetail)
//                                } label: {
//                                    Label(String.archive, systemImage: "archivebox.fill")
//                                }
//                                .tint(.indigo)
//                                //
//                                //                        Button(role: .destructive) {
//                                //                            // FIXME: Make sure deletion for activity detail works
//                                //                            warnBeforeDeletion(activityDetail)
//                                //                        } label: {
//                                //                            Label(String.delete, systemImage: "trash.fill")
//                                //                        }
//                            }
//                            .sectionBackground(padding: .detailPadding, color: .secondaryBackground)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: .cornerRadius)
//                                    .stroke((activityDetailsWithSelection[activityDetail] ?? false) ? detailSelectionColor : .clear, lineWidth: 3)
//                            )
//                            .listRowBackground(Color.clear)
//                            .listRowSeparator(.hidden)
//                            .listRowInsets(EdgeInsets(top: 0, leading: .detailSelectionHorizontalPadding, bottom: .vItemSpacing, trailing: .detailSelectionHorizontalPadding))
//                            .contentShape(Rectangle())
//                            .onTapGesture {
//                                // Do not allow to select if we are editing
//                                if !(editMode?.wrappedValue.isEditing ?? false) {
//                                    withAnimation(.easeInOut(duration: 0.3)) {
//                                        toggleSelection(for: activityDetail)
//                                    }
//                                }
//                            }
//                        }
//                    } sectionEmpty: {
//                        Text("Just a blank void. Not an activity detail in sight. Try adding one!")
//                            .font(.footnote)
//                            .foregroundStyle(Color.secondaryFont)
//                            .padding(.horizontal)
//                            .listRowSeparator(.hidden)
//                        
//                    }
//            }
//        }
        .listStyle(.plain)
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
        .navigationTitle(String.addActivityDetails_navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                
                Button("Cancel") {
                    // Remove all of the stuff that was selected
                    selectedDetails = originalSelectedDetails
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                
                Button("Done") {
                    // Should have everyting already binded
                    dismiss()
                }
            }
        }
    }
    
    
    private func removeAllSelections() {
        selectedDetails = []
    }
    
    
//    private func warnBeforeDeletion(_ activityDetail: ActivityDetail) {
//        
//        alertDetail = AddDetailsAlert.deleteActivityRecordWarning(
//            deleteAction: { deleteActivityDetails(activityDetail) },
//            archiveAction: { archiveActivityDetails(activityDetail) }
//        ).alertData()
//        
//        showAlert = true
//    }
    
    
    private func archiveActivityDetails(_ activityDetail: ActivityDetail) {
            
        habitController.archiveActivityDetail(activityDetail)
//        activityDetail.isArchived = true
    }
    
    
//    private func isRowSelected(_ activityDetail: DataActivityDetail) -> Bool{
//        withAnimation {
//            return selectedDetails.contains(activityDetail)
//        }
//    }
    
    
    private func toggleSelection(for activityDetail: ActivityDetail) {
        
        if let selectedDetailIndex = selectedDetails.firstIndex(where: { $0 == activityDetail }) {
            let _ = selectedDetails.remove(at: selectedDetailIndex)
            activityDetailsWithSelection[activityDetail] = false
        } else {
            selectedDetails.append(activityDetail)
            activityDetailsWithSelection[activityDetail] = true
        }
    }
}

//#Preview {
//    
//    // FIXME: Remove the unnecessary preview logic since we might not need DataActivityDetail anymore
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
//    
//    // Load and decode the json that we have inserted
//    let resourceName = "ActivityDetailSeedData"
//    let resourceExtension = "json"
//    guard let url = Bundle.main.url(forResource: "\(resourceName)", withExtension: "\(resourceExtension)") else {
//        fatalError("Failed to find '\(resourceName)' with '\(resourceExtension)' extension")
//    }
//    let data = try! Data(contentsOf: url)
//    let decodedActivityDetails = try! JSONDecoder().decode([DataActivityDetail].self, from: data)
//    
//    // Save to the model container
//    for activityDetail in decodedActivityDetails {
//        
//        container.mainContext.insert(activityDetail)
//    }
//    
//    return NavigationStack {
//        AddDetailsView(
//            selectedDetails: .constant([ActivityDetail.amount]),
//            detailSelectionColor: .yellow,
//            goToCreateActivityDetail: { }
//        )
//    }
//    .modelContainer(container)
//}

#Preview {
    
    @Previewable @State var selectedDetails = [ActivityDetail]()
    
    NavigationStack {
        AddDetailsView(
            selectedDetails: $selectedDetails,
            detailSelectionColor: .yellow,
            goToCreateActivityDetail: { }
        )
        .environmentObject(
            HabitController(
                blockHabitRepository: CoreDataBlockHabitStore.preview(),
                selectedDay: Date().noon!
            )
        )
    }
}
