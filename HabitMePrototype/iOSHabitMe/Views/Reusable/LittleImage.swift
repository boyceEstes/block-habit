//
//  LittleImage.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/19/24.
//

import SwiftUI

/// Good for rows in SwiftUI default list
struct LittleImage: View {
    
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    let imageSystemName: String
    let color: Color
    @ScaledMetric(relativeTo: .body) var width = 15
    
    var body: some View {
        Image(systemName: imageSystemName)
            .resizable()
            .scaledToFit()
            .frame(minWidth: 20)
            .frame(width: width, height: width)
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
