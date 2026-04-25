//
//  Router.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 03/01/25.
//

import SwiftUI

// All public navigation methods are `nonisolated` so they can be called from
// any concurrency context (e.g. a non-@MainActor ViewModel or an actor).
// Each one immediately schedules the real work on the MainActor via a Task;
// the call site never needs to be on the main thread.
//
// Methods that involve `TransitionType` stay `@MainActor` because
// `TransitionType.zoom` carries a `Namespace.ID`, a SwiftUI type that is
// only available inside a View body (which is already @MainActor).
//
// `showAlert(_:)` with a custom `AlertDestinationProtocol` stays `@MainActor`
// because arbitrary protocol conformances are not guaranteed to be `Sendable`.

public extension Router {
    
    // MARK: navigate
    
    /// Navigate to a new `Destination` with `NavigationType` mode.
    /// Can be called from any concurrency context.
    nonisolated func navigate(
        to destination: Destination,
        type: NavigationType,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        Task { @MainActor [weak self] in
            switch type {
            case .push:  self?.addPushNode(to: destination, transition: nil, onDismiss: onDismiss)
            case .sheet: self?.addSheetNode(to: destination, transition: nil, onDismiss: onDismiss)
            }
        }
    }
    
    /// Navigate to a new `Destination` with a custom transition.
    /// Must be called from a `@MainActor` context (requires `Namespace.ID`).
    @available(iOS 18.0, *)
    @available(macOS, unavailable)
    func navigate(
        to destination: Destination,
        type: NavigationType,
        transition: TransitionType?,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        switch type {
        case .push:  self.addPushNode(to: destination, transition: transition, onDismiss: onDismiss)
        case .sheet: self.addSheetNode(to: destination, transition: transition, onDismiss: onDismiss)
        }
    }
    
    // MARK: push
    
    /// Navigate horizontally (push) to a new `Destination`.
    /// Can be called from any concurrency context.
    nonisolated func push(
        to destination: Destination,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        Task { @MainActor [weak self] in
            self?.addPushNode(to: destination, transition: nil, onDismiss: onDismiss)
        }
    }
    
    /// Navigate horizontally (push) with a custom transition.
    /// Must be called from a `@MainActor` context (requires `Namespace.ID`).
    @available(iOS 18.0, *)
    @available(macOS, unavailable)
    func push(
        to destination: Destination,
        transition: TransitionType,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        self.addPushNode(to: destination, transition: transition, onDismiss: onDismiss)
    }
    
    // MARK: sheet
    
    /// Navigate vertically (sheet) to a new `Destination`.
    /// Can be called from any concurrency context.
    nonisolated func sheet(
        to destination: Destination,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        Task { @MainActor [weak self] in
            self?.addSheetNode(to: destination, transition: nil, onDismiss: onDismiss)
        }
    }
    
    /// Navigate vertically (sheet) with a custom transition.
    /// Must be called from a `@MainActor` context (requires `Namespace.ID`).
    @available(iOS 18.0, *)
    @available(macOS, unavailable)
    func sheet(
        to destination: Destination,
        transition: TransitionType,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        self.addSheetNode(to: destination, transition: transition, onDismiss: onDismiss)
    }
    
    // MARK: alerts
    
    /// Show a text-based alert.
    /// Can be called from any concurrency context.
    nonisolated func showAlert(
        title: String,
        message: String? = nil,
        actions: [TextAlertAction]? = nil
    ) {
        // Build the Sendable TextAlert here, outside the task, so nothing
        // non-Sendable needs to cross the concurrency boundary inside the closure.
        let alert = TextAlert(title: title, message: message, actions: actions)
        Task { @MainActor [weak self] in
            self?.showAlert(alert)
        }
    }
    
    /// Show a custom alert conforming to `AlertDestinationProtocol`.
    /// Must be called from a `@MainActor` context because arbitrary
    /// `AlertDestinationProtocol` conformances are not `Sendable`.
    func showAlert(_ alert: some AlertDestinationProtocol) {
        currentNode.alertItem = alert
        currentNode.reloadView()
    }
    
    // MARK: dismiss
    
    /// Dismiss the current view.
    /// Can be called from any concurrency context.
    nonisolated func dismiss(option: DismissOptions = .toPreviousView) {
        Task { @MainActor [weak self] in
            self?.removeNode(option: option)
        }
    }
}


// MARK: Private implementation

@MainActor
public class Router: DestinationNodePopProtocol {
    
    public init() {
        self.currentNode = .empty()
        self.currentNode = .root(popDelegate: self)
    }
    
    private var currentNode: DestinationNode
    private var presentingNode: DestinationNode?
    private var didRequestDismissOption: DismissOptions?
    
    internal func root(of node: DestinationNode? = nil) -> DestinationNode {
        let node = node ?? currentNode
        if node.previous == nil { return node }
        return root(of: node.previous)
    }
    
    private func pathNode(of node: DestinationNode? = nil) -> DestinationNode {
        let node = node ?? currentNode
        if node.path != nil { return node }
        return pathNode(of: node.previous)
    }
    
    /// Returns true if *any* node in the chain is currently mid-dismiss by checking *presenting* node (parent)
    private func isAnyNodeDismissingSheet() -> Bool {
        var node: DestinationNode? = currentNode
        while let n = node {
            if n.isDismissingSheet { return true }
            node = n.previous
        }
        return false
    }
    
    private func addPushNode(to destination: Destination, transition: TransitionType?, onDismiss: (@MainActor () -> Void)?) {
        // Inserting the destination into the nearest node that has a path
        let pathNode = pathNode()
        pathNode.path?.append(destination)
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
    
    private func addSheetNode(to destination: Destination, transition: TransitionType?, onDismiss: (@MainActor () -> Void)?) {
        
        guard !isAnyNodeDismissingSheet() else { return }
        
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
    
    @MainActor
    internal func view(for destination: Destination) -> some View {
        
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
