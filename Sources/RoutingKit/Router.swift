//
//  Router.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 03/01/25.
//

import SwiftUI

@MainActor
public class Router: DestinationNodePopProtocol {
    
    public init() {
        self.currentNode = .empty()
        self.currentNode = .root(popDelegate: self)
    }
    
    internal func root(node: DestinationNode? = nil) -> DestinationNode {
        let node = node ?? currentNode
        if node.previous == nil { return node }
        return root(node: node.previous)
    }
    
    private func pathNode(node: DestinationNode? = nil) -> DestinationNode {
        let node = node ?? currentNode
        if node.path != nil { return node }
        return pathNode(node: node.previous)
    }
    
    private var currentNode: DestinationNode
    private var presentingNode: DestinationNode?
    private var didRequestDismissOption: DismissOptions?
    
    /// Navigate to a new `Destination` with `NavigationType` mode
    /// - Parameters:
    ///     - type:  how the navigation should be displayed
    ///     - onDismiss:  an optional callback fired when the presented destination will be dismissed
    public func navigate(to destination: Destination, type: NavigationType, onDismiss: (() -> Void)? = nil) {
        switch type {
        case .push:
            self.push(to: destination, onDismiss: onDismiss)
        case .sheet:
            self.sheet(to: destination, onDismiss: onDismiss)
        }
    }
    
    /// Navigate horizontally (through a NavigationStack) to a new `Destination`
    /// - Parameters:
    ///     - onDismiss:  an optional callback fired when the presented destination will be dismissed
    public func push(to destination: Destination, onDismiss: (() -> Void)? = nil) {
        
        // Inserting the destination into the nearest node that has a path
        let pathNode = insertDestinationIntoPathNode(destination)
        pathNode.reloadView()
        
        presentingNode = DestinationNode(
            destination: destination,
            onDismiss: onDismiss,
            previous: currentNode,
            popDelegate: self
        )
        
        currentNode = presentingNode!
        
    }
    
    /// Navigate vertically (through sheets) to a new `Destination`
    /// - Parameters:
    ///     - onDismiss:  an optional callback fired when the presented destination will be dismissed
    public func sheet(to destination: Destination, onDismiss: (() -> Void)? = nil) {
        currentNode.sheetItem = destination
        currentNode.reloadView()
        
        // Create a new sheet context with its own path
        presentingNode = DestinationNode(
            destination: destination,
            onDismiss: onDismiss,
            previous: currentNode,
            path: [],
            popDelegate: self
        )
        
        currentNode = presentingNode!
        
    }
    
    public func showAlert(title: String, message: String? = nil, actions: [TextAlertAction]? = nil) {
        let alert = TextAlert(title: title, message: message, actions: actions)
        self.showAlert(alert)
    }
    
    public func showAlert(_ alert: some AlertDestinationProtocol) {
        currentNode.alertItem = alert
        currentNode.reloadView()
    }
    
    public func dismiss(option: DismissOptions = .toPreviousView) {
        
        self.didRequestDismissOption = option
        
        if option == .toRoot, self.currentNode == root() {
            self.didRequestDismissOption = nil
            return
        }
        
        if option == .toNavigationBegin, self.currentNode == pathNode() {
            self.didRequestDismissOption = nil
            return
        }
        
        if self.currentNode.previous?.alertItem != nil {
            // dismiss alert
            self.currentNode.previous?.alertItem = nil
            return
        }
        else if self.currentNode.previous?.sheetItem != nil {
            // dismiss sheet
            self.currentNode.previous?.sheetItem = nil
        }
        else {
            // pop page
            let node = pathNode()
            let path = node.path ?? []
            if !path.isEmpty {
                node.path?.removeLast()
            }
        }
    }
    
    func onPathViewPop() {
        
        let currentNode = self.currentNode
        let node = pathNode()
        node.reloadView()
        if let previous = currentNode.previous {
            self.currentNode = previous
        }
        
        currentNode.onDismiss?()
        if let didRequestDismissOption, didRequestDismissOption != .toPreviousView {
            self.dismiss(option: didRequestDismissOption)
        }
        
    }
    
    func onSheetItemPop() {
        
        let currentNode = self.currentNode
        let pathNode = pathNode()
        pathNode.previous?.reloadView()
        if let previous = pathNode.previous {
            self.currentNode = previous
        }
        
        currentNode.onDismiss?()
        if let didRequestDismissOption, didRequestDismissOption != .toPreviousView {
            self.dismiss(option: didRequestDismissOption)
        }
        
    }
    
    private func insertDestinationIntoPathNode(_ destination: Destination) -> DestinationNode {
        let node = pathNode()
        node.path!.append(destination)
        return node
    }
    
    @MainActor
    func destination(destination: Destination) -> some View {
        
        guard let model = self.presentingNode
        else { fatalError("Navigating to a view not requested") }
        
        return RoutableView(router: self, model: model) {
            AnyView(destination.content())
        }
    }
    
}
