//
//  CustomDisclosure.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/10/24.
//

import SwiftUI

struct CustomDisclosure: View {
    
    let color: Color
    
    init(color: Color = Color.accent) {
        self.color = color
    }
    
    
    var body: some View {
        Image(systemName: "chevron.right")
            .imageScale(.small)
            .fontWeight(.semibold)
            .foregroundColor(color)
    }
}




#Preview {
    CustomDisclosure()
}
