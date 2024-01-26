//
//  NavigationFlow.swift
//  NavigationStackDependencyInjectionDemo
//
//  Created by Boyce Estes on 7/3/23.
//

import Foundation

protocol NewStackNavigationFlow: ObservableObject {
    
    associatedtype StackIdentifier: Hashable
    
    var path: [StackIdentifier] { get set }
    
    func push(_ viewIdentifier: StackIdentifier)
}


extension NewStackNavigationFlow {
    
    
    func push(_ viewIdentifier: StackIdentifier) {

        path.append(viewIdentifier)
    }
}



protocol NewSheetyNavigationFlow: ObservableObject {
    
    associatedtype SheetyIdentifier: Identifiable
    
    var displayedSheet: SheetyIdentifier? { get set }
}
