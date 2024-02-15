//
//  AddDetailSelectionView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/31/24.
//

import SwiftUI
import SwiftData


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
    
    @Environment(\.editMode) var editMode
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<DataActivityDetail> { activityDetail in
        activityDetail.isArchived == false
    }, sort: [
        SortDescriptor(\DataActivityDetail.creationDate, order: .reverse)
    ], animation: .default) var activityDetails: [DataActivityDetail]
    
    @State private var activityDetailsWithSelection: [DataActivityDetail: Bool]
    @State private var alertDetail: AlertDetail?
    @State private var showAlert = false
    
    @Binding var selectedDetails: [DataActivityDetail]
    let goToCreateActivityDetail: () -> Void
    
    
    init(selectedDetails: Binding<[DataActivityDetail]>, goToCreateActivityDetail: @escaping () -> Void) {
        
        self._selectedDetails = selectedDetails
        self.goToCreateActivityDetail = goToCreateActivityDetail
        
        // Had to create this with a specific initialization, otherwise it would be implicitly
        // initializedand this would happen later, after the view has appeared
        self._activityDetailsWithSelection = State(
            initialValue: selectedDetails.reduce(into: [DataActivityDetail: Bool](), {
                $0[$1.wrappedValue] = true
        }))
    }
    

    var body: some View {
        List {
//            VStack(spacing: .vItemSpacing) {
                ForEach(activityDetails) { activityDetail in
                    VStack(alignment: .leading, spacing: .vRowSubtitleSpacing) {
                        
                        ActivityDetailBasicInfo(activityDetail: activityDetail.toModel())
                        
                        HStack(alignment: .firstTextBaseline) {
                            
                            Text("Ex. \"\(activityDetail.example)\"")
                                .foregroundStyle(.secondary)
                                .font(.rowDetail)
                            
                            Spacer()
                            
                            Text("[Avg]")
                                .foregroundStyle(.secondary)
                                .font(.rowDetail)
                        }
                    }
                    .swipeActions {
                        Button {
                            archiveActivityDetails(activityDetail)
                        } label: {
                            Label(String.archive, systemImage: "archivebox.fill")
                        }
                        .tint(.indigo)
                        
                        Button(role: .destructive) {
                            warnBeforeDeletion(activityDetail)
                        } label: {
                            Label(String.delete, systemImage: "trash.fill")
                        }
                    }
                    .sectionBackground(padding: .detailPadding, color: .secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: .cornerRadius)
                            .stroke((activityDetailsWithSelection[activityDetail] ?? false) ? Color.blue : .clear, lineWidth: 3)
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: .detailSelectionHorizontalPadding, bottom: .vItemSpacing, trailing: .detailSelectionHorizontalPadding))
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
//            }
        }
        .listStyle(.plain)
        .alert(showAlert: $showAlert, alertDetail: alertDetail)
        .navigationTitle(String.addActivityDetails_navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                
                Button {
                    goToCreateActivityDetail()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    
    private func warnBeforeDeletion(_ activityDetail: DataActivityDetail) {
        
        alertDetail = AddDetailsAlert.deleteActivityRecordWarning(
            deleteAction: { deleteActivityDetails(activityDetail) },
            archiveAction: { archiveActivityDetails(activityDetail) }
        ).alertData()
        
        showAlert = true
    }
    
    
    private func deleteActivityDetails(_ activityDetail: DataActivityDetail) {
        
        modelContext.delete(activityDetail)
    }
    
    
    private func archiveActivityDetails(_ activityDetail: DataActivityDetail) {
            
        activityDetail.isArchived = true
    }
    
    
//    private func isRowSelected(_ activityDetail: DataActivityDetail) -> Bool{
//        withAnimation {
//            return selectedDetails.contains(activityDetail)
//        }
//    }
    
    
    private func toggleSelection(for activityDetail: DataActivityDetail) {
        
        if let selectedDetailIndex = selectedDetails.firstIndex(where: { $0 == activityDetail }) {
            let _ = selectedDetails.remove(at: selectedDetailIndex)
            activityDetailsWithSelection[activityDetail] = false
        } else {
            selectedDetails.append(activityDetail)
            activityDetailsWithSelection[activityDetail] = true
        }
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataHabit.self, DataHabitRecord.self, configurations: config)
    
    // Load and decode the json that we have inserted
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
    
    return NavigationStack {
        AddDetailsView(
            selectedDetails:
                .constant([decodedActivityDetails.first!]), 
            goToCreateActivityDetail: { }
        )
    }
    .modelContainer(container)
}
