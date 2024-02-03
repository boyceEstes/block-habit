//
//  AddDetailSelectionView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/31/24.
//

import SwiftUI
import SwiftData

struct AddDetailsSelectionView: View {
    
    @Query(sort: [
        SortDescriptor(\DataActivityDetail.name)
    ]) var activityDetails: [DataActivityDetail]
    
    @State private var selectedDetails: [(order: Int, detail: DataActivityDetail)] = []
    
    var body: some View {
        List {
            ForEach(activityDetails) { activityDetail in
                VStack(alignment: .leading, spacing: 8) {
                    
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
                .padding(8)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isRowSelected(activityDetail) ? Color.white : .clear, lineWidth: 5)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                )
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Select Activity Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                
                Button {
                    print("Edit the details available")
                } label: {
                    Image(systemName: "pencil.circle")
                }
                
                Button {
                    print("Add something")
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    
    func isRowSelected(_ activityDetail: DataActivityDetail) -> Bool{
        
        let selectedActivityDetails = selectedDetails.map { $0.detail }
        return selectedActivityDetails.contains(activityDetail)
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
        AddDetailsSelectionView()
    }
    .modelContainer(container)
}
