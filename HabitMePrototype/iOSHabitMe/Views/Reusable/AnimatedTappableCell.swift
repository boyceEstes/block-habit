//
//  AnimatedTappableCell.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/15/25.
//

import SwiftUI

/*
 
 Part of the problem here is that we would need to
 be able to detect pretty immediately when the habit
 `isComplete` - so it would seem like we might need a view
 local state property.
 
 Toggle that, and then actually trigger it in the other stuff
 
 */

struct SelectableCell: View {
    
    /// SF Symbol name
    let systemName: String
    let onSelection: () -> Void
    
    let color: Color
    @State var isCompleted = false
    @State var scale = 1.0
    
    init(color: Color, systemName: String, isCompleted: Bool = false, onSelection: @escaping () -> Void) {
        
        self.color = color
        self.systemName = systemName
        self.onSelection = onSelection
        self._isCompleted = State(wrappedValue: isCompleted)
    }
    
    
    var body: some View {
        
        image(systemName: systemName, isCompleted: isCompleted)
            .scaleEffect(scale)
            .sensoryFeedback(.increase, trigger: isCompleted)
            .onTapGesture {
                withAnimation {
                    isCompleted.toggle()
                }
                withAnimation(.spring(duration: 0.2)) {
                    
                    scale = 1.2
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation() {
                            scale = 1
                            onSelection()
                        }
                    }
                }
            }
    }
    
    
     @ViewBuilder
     func image(systemName: String, isCompleted: Bool) -> some View {
         
         
         Image(systemName: systemName)
             .resizable()
             .aspectRatio(contentMode: .fit)
             .frame(width: 20, height: 20)
             .foregroundStyle(.white)
             .fontWeight(isCompleted ? .semibold : .medium)
             .scaleEffect(isCompleted ? 1.2 : 0.8)
             .padding(10)
             .background(color
                 .brightness(isCompleted ? 0 : -0.3)
             )
             .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
     }
}


#Preview {
    
    SelectableCell(color: .pink, systemName: "checkmark", onSelection: { })
}
