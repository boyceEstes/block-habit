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
    
    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.accentText)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(color)
                )
            
            Button(action: tapAction) {
                Text("\(label)")
                    .font(.headline)
                    .fontWeight(.regular)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            CustomDisclosure()
        }
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
