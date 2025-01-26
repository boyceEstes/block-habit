//
//  SettingsRow.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/18/24.
//

import SwiftUI



struct SettingsRow: View {

    let imageSystemName: String
    let label: String
    let color: Color
    let tapAction: () -> Void
    let showDisclosure: Bool
    
    init(imageSystemName: String, label: String, color: Color, showDisclosure: Bool = true, tapAction: @escaping () -> Void) {
        
        self.imageSystemName = imageSystemName
        self.label = label
        self.color = color
        self.showDisclosure = showDisclosure
        self.tapAction = tapAction
    }
    
    var body: some View {

        Button(action: tapAction) {
            HStack {
                
                LittleImage(imageSystemName: imageSystemName, color: color)
                
                
                Text("\(label)")
                    .font(.headline)
                    .fontWeight(.regular)
                
                Spacer()
                
                if showDisclosure {
                    CustomDisclosure()
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsRow(
        imageSystemName: "flame",
        label: "Some Fire ish",
        color: .accent,
        tapAction: { }
    )
}
