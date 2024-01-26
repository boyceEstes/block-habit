//
//  View+FlowNavigationDestination.swift
//  NavigationStackDependencyInjectionDemo
//
//  Created by Boyce Estes on 7/3/23.
//

import SwiftUI



struct FlowNavigationDestination<DestinationContent: View, StackIdentifier: Hashable>: ViewModifier {
    
    @Binding var flowPath: [StackIdentifier]
    @ViewBuilder let flowDestination: (StackIdentifier) -> DestinationContent
    
    init(
        flowPath: Binding<[StackIdentifier]>,
        @ViewBuilder flowDestination: @escaping (StackIdentifier) -> DestinationContent
    ) {
        self._flowPath = flowPath
        self.flowDestination = flowDestination
    }
    
    func body(content: Content) -> some View {
        
        NavigationStack(path: $flowPath) {
            content
                .navigationDestination(for: StackIdentifier.self, destination: flowDestination)
        }
    }
}


extension View {
    
    func flowNavigationDestination<DestinationContent: View, StackIdentifier: Hashable> (
        flowPath: Binding<[StackIdentifier]>,
        @ViewBuilder flowDestination: @escaping (StackIdentifier) -> DestinationContent
    ) -> some View {
        
        modifier(
            FlowNavigationDestination(flowPath: flowPath, flowDestination: flowDestination)
        )
    }
}
