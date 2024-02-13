//
//  AddDetailSelectionView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/31/24.
//

import SwiftUI
import SwiftData

struct AddDetailsView: View {
    
    @Environment(\.editMode) var editMode
    @Environment(\.modelContext) var modelContext
    @Query(sort: [
        SortDescriptor(\DataActivityDetail.creationDate, order: .reverse)
    ]) var activityDetails: [DataActivityDetail]
    
    @State private var activityDetailsWithSelection: [DataActivityDetail: Bool]
    
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
            ForEach(activityDetails) { activityDetail in
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(activityDetail.name)")
                        Spacer()
                        Text("\(activityDetail.valueType.rawValue)")
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        
                        Text("Ex. \"\(activityDetail.example)\"")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        if !activityDetail.availableUnits.isEmpty {
                            let availableUnitsInString = activityDetail.availableUnits.joined(separator: ", ")
                            
                            Text("\(availableUnitsInString)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.detailPadding)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .stroke((activityDetailsWithSelection[activityDetail] ?? false) ? Color.white : .clear, lineWidth: 5)
                        .fill(Color.secondaryBackground)
                        .padding(.horizontal)
                        .padding(.vertical, (CGFloat.vItemSpacing / 2))
                )
                .listRowSeparator(.hidden)
                .contentShape(Rectangle())
                .onTapGesture {
                    // Do not allow to select if we are editing
                    if !(editMode?.wrappedValue.isEditing ?? false) {
                        withAnimation(.easeInOut(duration: 1.2)) {
                            toggleSelection(for: activityDetail)
                        }
                    }
                }
            }
            .onDelete { indexSet in
                deleteActivityDetails(at: indexSet)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Select Activity Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                
                EditButton()
                
                Button {
                    print("Add something")
                    goToCreateActivityDetail()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    
    private func deleteActivityDetails(at offsets: IndexSet) {
        
        // TODO: Present alert to warn that this is crazy sauce
        for index in offsets {
            
            let activityDetail = activityDetails[index]
            modelContext.delete(activityDetail)
        }
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
