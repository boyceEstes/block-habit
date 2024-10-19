//
//  LittleImage.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/19/24.
//

import SwiftUI

/// Good for rows in SwiftUI default list
struct LittleImage: View {
    
    let imageSystemName: String
    let color: Color
    
    var body: some View {
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
    }
}

#Preview {
    LittleImage(imageSystemName: "flame", color: .orange)
}
