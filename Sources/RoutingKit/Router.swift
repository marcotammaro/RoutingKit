//
//  Router.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 03/01/25.
//

import SwiftUI

// MARK: Public interface

public extension Router {
    
    /// Navigate to a new `Destination` with `NavigationType` mode
    /// - Parameters:
    ///     - type:  how the navigation should be displayed
    ///     - onDismiss:  an optional callback fired when the presented destination will be dismissed
    func navigate(to destination: Destination, type: NavigationType, onDismiss: (() -> Void)? = nil) {
        switch type {
        case .push:
            self.push(to: destination, onDismiss: onDismiss)
        case .sheet:
            self.sheet(to: destination, onDismiss: onDismiss)
        }
    }
    
    /// Navigate to a new `Destination` with `NavigationType` mode
    /// - Parameters:
    ///     - type:  how the navigation should be displayed
    ///     - onDismiss:  an optional callback fired when the presented destination will be dismissed
    @available(iOS 18.0, *)
    @available(macOS, unavailable)
    func navigate(to destination: Destination, type: NavigationType, transition: TransitionType?, onDismiss: (() -> Void)? = nil) {
        switch type {
        case .push:
            self.addPushNode(to: destination, transition: transition, onDismiss: onDismiss)
        case .sheet:
            self.addSheetNode(to: destination, transition: transition, onDismiss: onDismiss)
        }
    }
    
    /// Navigate horizontally (through a NavigationStack) to a new `Destination`
    /// - Parameters:
    ///     - onDismiss:  an optional callback fired when the presented destination will be dismissed
    func push(to destination: Destination, onDismiss: (() -> Void)? = nil) {
        self.addPushNode(to: destination, transition: nil, onDismiss: onDismiss)
    }
    
    /// Navigate horizontally (through a NavigationStack) to a new `Destination`
    /// - Parameters:
    ///     - transition:  sets the navigation transition style for this view.
    ///     - onDismiss:  an optional callback fired when the presented destination will be dismissed
    @available(iOS 18.0, *)
    @available(macOS, unavailable)
    func push(to destination: Destination, transition: TransitionType, onDismiss: (() -> Void)? = nil) {
        self.addPushNode(to: destination, transition: transition, onDismiss: onDismiss)
    }
    
    /// Navigate vertically (through sheets) to a new `Destination`
    /// - Parameters:
    ///     - onDismiss:  an optional callback fired when the presented destination will be dismissed
    func sheet(to destination: Destination, onDismiss: (() -> Void)? = nil) {
        self.addSheetNode(to: destination, transition: nil, onDismiss: onDismiss)
    }
    
    /// Navigate vertically (through sheets) to a new `Destination`
    /// - Parameters:
    ///     - onDismiss: an optional callback fired when the presented destination will be dismissed
    @available(iOS 18.0, *)
    @available(macOS, unavailable)
    func sheet(to destination: Destination, transition: TransitionType, onDismiss: (() -> Void)? = nil) {
        self.addSheetNode(to: destination, transition: transition, onDismiss: onDismiss)
    }
    
    /// Displays an alert with the given title, optional message, and actions.
    /// - Parameters:
    ///     - title: The title of the alert.
    ///     - message: An optional message to display in the alert.
    ///     - actions: An optional array of `TextAlertAction` representing the available actions.
    func showAlert(title: String, message: String? = nil, actions: [TextAlertAction]? = nil) {
        let alert = TextAlert(title: title, message: message, actions: actions)
        self.showAlert(alert)
    }
    
    /// Displays an alert using a custom alert conforming to `AlertDestinationProtocol`.
    /// - Parameter alert: An alert conforming to `AlertDestinationProtocol` to be displayed.
    func showAlert(_ alert: some AlertDestinationProtocol) {
        currentNode.alertItem = alert
        currentNode.reloadView()
    }
    
    /// Dismisses the current view with an optional dismiss option.
    /// - Parameter option: The `DismissOptions` that defines how the view should be dismissed.
    ///   Defaults to `.toPreviousView`.
    func dismiss(option: DismissOptions = .toPreviousView) {
        self.removeNode(option: option)
    }
}

// MARK: Private implementation

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
    
    private func addPushNode(to destination: Destination, transition: TransitionType?, onDismiss: (() -> Void)?) {
        // Inserting the destination into the nearest node that has a path
        let pathNode = insertDestinationIntoPathNode(destination)
        pathNode.reloadView()
        
        presentingNode = DestinationNode(
            destination: destination,
            onDismiss: onDismiss,
            previous: currentNode,
            popDelegate: self,
            transition: transition
        )
        
        currentNode = presentingNode!
    }
    
    private func addSheetNode(to destination: Destination, transition: TransitionType?, onDismiss: (() -> Void)?) {
        currentNode.sheetItem = destination
        currentNode.reloadView()
        
        // Create a new sheet context with its own path
        presentingNode = DestinationNode(
            destination: destination,
            onDismiss: onDismiss,
            previous: currentNode,
            path: [],
            popDelegate: self,
            transition: transition
        )
        
        currentNode = presentingNode!
    }
    
    private func removeNode(option: DismissOptions) {
        
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
    
    internal func onPathViewPop() {
        
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
    
    internal func onSheetItemPop() {
        
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
    internal func destination(destination: Destination) -> some View {
        
        guard let model = self.presentingNode
        else { fatalError("Navigating to a view not requested") }
        
        let view = RoutableView(router: self, model: model) {
            AnyView(destination.content())
        }
        
        // on macOS zoom transition is unavailable
        #if os(iOS)
        if #available(iOS 18.0, *) {
            return Group {
                switch model.transition {
                case .zoom(let sourceID, let namespace):
                    view.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
                default:
                    view
                }
            }
        }
        #endif
        
        return view

    }
    
}
