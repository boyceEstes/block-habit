//
//  CreateActivityDetailView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/11/24.
//

import SwiftUI
import HabitRepositoryFW


struct CreateActivityDetailView: View {
    
    @EnvironmentObject var habitController: HabitController
    @Environment(\.dismiss) var dismiss
    
    @State private var detailName: String = ""
    @State private var typeSelection: ActivityDetailType = .text
    @State private var units: String = ""
    @State private var calculationTypeSelection: ActivityDetailCalculationType = .sum
    
    var body: some View {
    
        VStack(spacing: .vSectionSpacing) {
            HStack {
                TextField("Name", text: $detailName)
                    .textFieldBackground(color: .tertiaryBackground)
                
                Picker("Type", selection: $typeSelection) {
                    ForEach(ActivityDetailType.allCases) { type in
                        Text("\(type.rawValue)")
                    }
                }
                .tint(.primary)
                .sectionBackground(padding: 0, color: .tertiaryBackground)
            }
            .sectionBackground()
            
            switch typeSelection {
            case .number:
                numberDetailSection
                
            case .text:
                Text("Example 'The horse was infuriated. I guess its true what they say about bringing snake to a rodeo. Lesson learned.'")
                    .font(.footnote)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .animation(.default, value: typeSelection)
        .navigationTitle("New Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create") {
                    didTapCreateDetail()
                }
                .disabled(!isAbleToTapCreate)
            }
        }
    }
    
    
    var numberDetailSection: some View {
        
        VStack(alignment: .leading, spacing: .vItemSpacing) {
            
            Text("Number Details")
                .font(.sectionTitle)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: .vSectionSpacing) {
                HStack {
                    TextField("Units", text: $units)
                        .frame(width: 85)
                        .textFieldBackground(color: .tertiaryBackground)
                    Spacer()
                    Text("Example '27\(units.isEmpty ? "" : " \(units)")'")
                }
                .sectionBackground()
                
                calculationType
                .sectionBackground()
            }
            
            Text("\(calculationTypeSelection.explanation)")
                .font(.footnote)
                .padding(.horizontal)
        }
    }
    
    
    var calculationType: some View {
        
        HStack {
            Text("Calculation Type")
            Spacer()
            Picker("Calculation Type", selection: $calculationTypeSelection) {
                ForEach(ActivityDetailCalculationType.allCases) { type in
                    Text("\(type.rawValue)")
                }
            }
            .tint(.primary)
            .sectionBackground(padding: 0, color: .tertiaryBackground)
        }
    }
    
    
    var isAbleToTapCreate: Bool {
        
        !detailName.isEmpty
    }
    
    
    private func didTapCreateDetail() {
        
        guard isAbleToTapCreate else { return }

//            try modelContext.createActivityDetail(
//                name: detailName,
//                valueType: typeSelection,
//                units: units,
//                calculationType: calculationTypeSelection,
//                overrideDuplicateNameError: true
//            )
//            
            let activityDetail = ActivityDetail(
                id: UUID().uuidString,
                name: detailName,
                availableUnits: units,
                isArchived: false,
                creationDate: Date(),
                calculationType: calculationTypeSelection,
                valueType: typeSelection
            )
            
            habitController.createActivityDetail(activityDetail)
            
            dismiss()
    }
}


#Preview {
    
    NavigationStack {
        CreateActivityDetailView()
            .background(Color.primaryBackground)
    }
}
