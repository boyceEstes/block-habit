//
//  CreateActivityDetailView.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 2/11/24.
//

import SwiftUI

enum ActivityDetailCalculationType: String, CaseIterable, Identifiable {
     
    case sum = "Sum"
    case average = "Average"
    
    var id: ActivityDetailCalculationType { self }
   
    var explanation: String {
        
        var _explanation: String = .calculationTypExplanation
        
        switch self {
        case .sum:
            _explanation.append(" \(String.sumExplanation)")
        case .average:
            _explanation.append(" \(String.avgExplanation)")
        }
        
        return _explanation
    }
}


struct CreateActivityDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var detailName: String = ""
    @State private var typeSelection: ActivityDetailType = .number
    @State private var units: String = "min"
    @State private var calculationTypeSelection: ActivityDetailCalculationType = .sum
    
    var body: some View {
        VStack(spacing: .vSectionSpacing) {
            HStack {
                
                TextField("Name", text: $detailName)
                    .textFieldBackground()
                
                Picker("Type", selection: $typeSelection) {
                    ForEach(ActivityDetailType.allCases) { type in
                        Text("\(type.rawValue)")
                    }
                }
            }
            
            if typeSelection == .number {
                numberDetailSection
            }
            
            Spacer()
        }
        .sheetyTopBarNav(title: "Create Activity Detail", dismissAction: { dismiss() })
    }
    
    
    var numberDetailSection: some View {
        
        VStack(alignment: .leading, spacing: .vItemSpacing) {
            
            HStack {
                TextField("Units", text: $units)
                    .frame(width: 85)
                    .textFieldBackground()
                Spacer()
                Text("Example '27\(units.isEmpty ? "" : " \(units)")'")
            }
            
            calculationType
        }
        
    }
    
    
    var calculationType: some View {
        VStack (spacing: .vItemSpacing) {
            HStack {
                Text("Calculation Type")
                Spacer()
                Picker("Calculation Type", selection: $calculationTypeSelection) {
                    ForEach(ActivityDetailCalculationType.allCases) { type in
                        Text("\(type.rawValue)")
                    }
                }
            }
            
            Text("\(calculationTypeSelection.explanation)")
                .font(.footnote)
        }
    }
}

#Preview {
    
    NavigationStack {
        CreateActivityDetailView()
    }
}
