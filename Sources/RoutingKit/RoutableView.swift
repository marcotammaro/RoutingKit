//
//  RoutableView.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 03/01/25.
//

import SwiftUI

internal struct RoutableView<Content: View>: View {
    
    let router: Router
    @StateObject var model: DestinationNode
    let content: () -> Content
    
    public var body: some View {
        
        // If path != nil than the node should have a NavigationStack
        if let path = model.path {
            
            let pathBinding = Binding<[Destination]>(
                get: { return path },
                set: { model.path = $0 }
            )
            
            NavigationStack(path: pathBinding) {
                view()
                    .navigationDestination(
                        for: Destination.self,
                        destination: router.destination
                    )
            }
        } else {
            view()
        }
    }
    
    @ViewBuilder
    func view() -> some View {
        
        let alertBinding = Binding<Bool>(
            get: { return model.alertItem != nil },
            set: { if !$0 { model.alertItem = nil }}
        )
        
        content()
            .id(model.destination?.id)
            .sheet(
                item: $model.sheetItem,
                content: router.destination
            )
            .alert(
                model.alertItem?.title() ?? "",
                isPresented: alertBinding,
                actions: {
                    if let actions = model.alertItem?.actions() {
                        AnyView(actions)
                    } else {
                        EmptyView()
                    }
                },
                message: {
                    if let message = model.alertItem?.message() {
                        AnyView(message)
                    } else {
                        EmptyView()
                    }
                }
            )
    }
    
}

public struct RoutableRootView<Content: View>: View {
    let content: () -> Content
    let router: Router
    
    public init(router: Router, content: @escaping () -> Content) {
        self.router = router
        self.content = content
    }
    
    public var body: some View {
        RoutableView(router: router, model: router.root()) {
            content()
        }
    }
}
