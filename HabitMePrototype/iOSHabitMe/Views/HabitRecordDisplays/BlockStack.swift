//
//  BlockStack.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 10/8/24.
//

import SwiftUI
import HabitRepositoryFW


struct BlockStack: View {
    
    let habitRecords: [HabitRecord]
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let animation: Namespace.ID
    let didTapBlock: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            ForEach(habitRecords, id: \.self) { habitRecord in
                
                let isLastRecord = habitRecords.first == habitRecord
                
                ActivityBlock(
                    color: Color(hex: habitRecord.habit.color) ?? Color.white,
                    itemWidth: itemWidth,
                    itemHeight: itemHeight,
                    tapAction: didTapBlock
                )
                .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
//                .matchedGeometryEffect(
//                    id: habitRecord.id,
//                    in: animation,
//                    isSource: true
//                )
                .clipShape(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: isLastRecord ? .bigBlockCornerRadius : 0,
                            topTrailing: isLastRecord ? .bigBlockCornerRadius : 0
                        )
                    )
                )
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
    }
}


#Preview {
    
    @Previewable @Namespace var namespace
    
    return BlockStack(
        habitRecords: HabitRecord.previewRecords,
        itemWidth: 45,
        itemHeight: 45,
        animation: namespace,
        didTapBlock: { }
    )
}
