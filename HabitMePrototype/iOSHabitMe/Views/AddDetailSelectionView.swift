//
//  AddDetailSelectionView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/31/24.
//

import SwiftUI
import SwiftData
import HabitRepositoryFW
import TipKit


struct DetailSelectionTip: Tip {
    
    var title: Text {
        Text("Habit Details")
    }


    var message: Text? {
        Text("Is there anything you'd like to track with your habit?\n\nFor example, if you have a 'Meditate' habit, you might add a 'Duration' Detail to track how long you meditated and a 'Mood' Detail to log how you felt afterward.")
    }
}




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

            List {
                Section {
                    TipView(DetailSelectionTip(), arrowEdge: .none)
                    
                }
                .listRowSeparator(.hidden)
                    
                
                //            Section {
                //                Text("Details are useful bits of info that you want to record each time that you complete a habit\n\nAn example could be adding a 'Note' detail to your 'Workout' Habit to describe exactly much you loved it on this particular day")
                //                    .frame(maxWidth: .infinity)
                //                    .font(.callout)
                //                    .padding(.vertical, .detailPadding)
                //                    .padding(.horizontal, .detailPadding)
                //                    .background(Color.secondaryBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                ////                    .sectionBackground(padding: .detailPadding)
                //                    .frame(maxWidth: .infinity)
                //            }
                //            .listRowSeparator(.hidden)
                //            .listStyle(.plain)
                
                
                
                
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
                                    withAnimation(.spring(duration: 0.2)) {
                                        toggleSelection(for: activityDetail)
                                    }
                                }
                            }
                        }
                    } footer: {
                        Text("Choose Details that you would like to record each time you complete your Habit")
                            .font(.caption)
                            .listRowSeparator(.hidden)
                    }
                } else {
                    
                    Section {
                        VStack {
                            //                        Image("empty-box-sad-star")
                            //                            .resizable()
                            //                            .scaledToFill()
                            //                            .rotationEffect(.degrees(90))
                            //                            .frame(width: 140, height: 140)
                            //                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            
                            Text("\(.addDetailSelection_emptyList)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .listRowSeparator(.hidden)
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button {
                            goToCreateActivityDetail()
                        } label: {
                            Label("New Detail", systemImage: "plus.circle")
                                .imageScale(.large)
                            //                            .foregroundStyle(.white)
                            //                            .fontWeight(.medium)
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .listStyle(.plain)
                    
                }
            }
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

    }
    
    
    
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
        .task {
            // Configure and load your tips at app launch.
            do {
                try Tips.configure()
            }
            catch {
                // Handle TipKit errors
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
    }
}
