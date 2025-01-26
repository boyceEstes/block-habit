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
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.dismiss) var dismiss
    
    @State private var detailName: String = ""
    @State private var typeSelection: ActivityDetailType = .text
    @State private var units: String = ""
    @State private var calculationTypeSelection: ActivityDetailCalculationType = .sum
    
    var body: some View {
    
        VStack(alignment: .leading, spacing: 8) {
            
            if dynamicTypeSize.isAccessibilitySize {
                
                VStack {
                    TextField("Name", text: $detailName)
                        .textFieldBackground()
                    
                    HStack {
                        if dynamicTypeSize <= .accessibility4 {
                            
                            Text("Type")
                                .padding(.vertical, 6)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            Picker(selection: $typeSelection) {
                                ForEach(ActivityDetailType.allCases) { type in
                                    Text("\(type.rawValue)")
                                    
                                }
                            } label: {
                                Text("\(typeSelection.rawValue)")
                            }
                            .tint(.primary)
                            
                        } else {
                            Picker(selection: $typeSelection) {
                                ForEach(ActivityDetailType.allCases) { type in
                                    Text("\(type.rawValue)")
                                    
                                }
                            } label: {
                                Text("\(typeSelection.rawValue)")
                            }
                            .tint(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .sectionBackground(padding: 10, color: .secondaryBackground)
//                    .background(
//                        Color.secondaryBackground,
//                        in: RoundedRectangle(
//                            cornerRadius: 10, style: .continuous
//                        )
//                    )
//                    .contentShape(Rectangle())
                }
            } else {
                HStack {
                    TextField("Name", text: $detailName)
                        .textFieldBackground()
                    
                    Picker("Type", selection: $typeSelection) {
                        ForEach(ActivityDetailType.allCases) { type in
                            Text("\(type.rawValue)")
                        }
                    }
                    .tint(.primary)
                    .padding(6)
                    .background(
                        Color.secondaryBackground,
                        in: RoundedRectangle(
                            cornerRadius: 10, style: .continuous
                        )
                    )
                }
            }
                
                switch typeSelection {
                case .number:
                    Text("Create a reusable number detail with your habit like 'Amount', 'Weight', or 'Duration'")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                    
                    numberDetailSection
                        .padding(.top)
                    
                case .text:
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Create a reusable text detail with your habit like 'Summary', 'Note', or 'Highlights'")
                            .foregroundStyle(.secondary)
                        //                    Text("\(detailName.isEmpty ? "Detail" : "\(detailName)"): 'The horse was infuriated. I guess its true what they say about bringing snake to a rodeo'")
                    }
                    .font(.footnote)
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Number Details")
                    .font(.headline)
                
            }
                
            
            
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Units", text: $units)
                            .frame(maxWidth: .infinity)
                        
                    }
                    .textFieldBackground()
                    Text("'27\(units.isEmpty ? "" : " \(units)")'")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                

                
//            calculationType
//
//            Text("\(calculationTypeSelection.explanation)")
//                .font(.footnote)
        }
    }
    
    
    var calculationType: some View {

        HStack {
            Text("Calculation Type")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
            Spacer()
            Picker("Calculation Type", selection: $calculationTypeSelection) {
                ForEach(ActivityDetailCalculationType.allCases) { type in
                    Text("\(type.rawValue)")
                }
            }

            .tint(.primary)
        }
        .padding(6)
        .background(
            Color.secondaryBackground,
            in: RoundedRectangle(
                cornerRadius: 10, style: .continuous
            )
        )
    }
    
    
    var isAbleToTapCreate: Bool {
        
        !detailName.isEmpty
    }
    
    
    private func didTapCreateDetail() {
        
        guard isAbleToTapCreate else { return }

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
