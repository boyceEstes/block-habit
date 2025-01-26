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
    @State private var typeSelection: ActivityDetailType = .number
    @State private var units: String = ""
    @State private var calculationTypeSelection: ActivityDetailCalculationType = .sum
    
    var body: some View {
    
        VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Name", text: $detailName)
                        .textFieldBackground()
                    
                    //                    .textFieldBackground(color: .tertiaryBackground)
                    
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
                    
                    //                .sectionBackground(padding: 0, color: .tertiaryBackground)
                }
                
                //            .padding(8)
                //            .background(
                //                Color.secondaryBackground,
                //                in: RoundedRectangle(
                //                    cornerRadius: 10, style: .continuous
                //                )
                //            )
                //            .sectionBackground()
                
                switch typeSelection {
                case .number:
                    Text("Create a reusable number detail with your habit like 'Amount', 'Weight', or 'Duration'")
                        .font(.footnote)
                    
                    numberDetailSection
                        .padding(.top)
                    
                case .text:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Create a reusable text detail with your habit like 'Summary', 'Note', or 'Highlights'")
                        
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
                //                .fontWeight(<#T##weight: Font.Weight?##Font.Weight?#>)
            }
                
            
            
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Units", text: $units)
                            .frame(maxWidth: .infinity)
                        //                        .textFieldBackground(color: .tertiaryBackground)
                        //                    Spacer()
                        Text("'27\(units.isEmpty ? "" : " \(units)")'")
                    }
                    .textFieldBackground()
                    
                    
                        
                }
                
//                .sectionBackground()
                
                calculationType
//                .sectionBackground()
            
            
            Text("\(calculationTypeSelection.explanation)")
                .font(.footnote)
//                .padding(.horizontal)
        }
    }
    
    
    var calculationType: some View {
        
//        Menu {
//            Picker("Calculation Type", selection: $calculationTypeSelection) {
//                ForEach(ActivityDetailCalculationType.allCases) { type in
//                    Text("\(type.rawValue)")
//                }
//            }
////            Picker(selection: $selectedNumber, label: EmptyView()) {
////                ForEach(0..<10) {
////                    Text("\($0)")
////                }
////            }
//        } label: {
//            HStack {
//                Text("Calculation Type")
//                Spacer()
//                Text("\(calculationTypeSelection.rawValue)")
//            }
//        }
//        .buttonStyle(.plain)
//        .frame(maxWidth: .infinity)
//        .padding(13)
//        .background(
//            Color.secondaryBackground,
//            in: RoundedRectangle(
//                cornerRadius: 10, style: .continuous
//            )
//        )
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
//            .frame(maxWidth: .infinity, alignment: .trailing)

            
//            .sectionBackground(padding: 0, color: .tertiaryBackground)
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
