//
//  ActivityBlock.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/8/24.
//

import SwiftUI


struct ActivityBlock: View {
    
    let color: Color
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let tapAction: () -> Void
    
    init(
        color: Color,
        itemWidth: CGFloat,
        itemHeight: CGFloat,
        tapAction: @escaping () -> Void = {}
    ) {
        self.color = color
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.tapAction = tapAction
    }
    
    
    var body: some View {
        
        Rectangle()
            .fill(color)
            .frame(width: 24, height: 24)
            .onTapGesture(perform: tapAction)
    }
}


#Preview {
    ActivityBlock(
        color: Color.orange,
        itemWidth: 45,
        itemHeight: 45
    ) {
        print("tapped")
    }
}
