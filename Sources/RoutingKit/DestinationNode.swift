//
//  DestinationNode.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 03/01/25.
//

import SwiftUI

@MainActor
internal protocol DestinationNodePopProtocol {
    func onPathViewPop()
    func onSheetItemPop()
}

@MainActor
internal class DestinationNode: Identifiable, ObservableObject {
    
    let destination: Destination?
    let onDismiss: (() -> Void)?
    let delegate: DestinationNodePopProtocol?
    
    /// nil for root, always present for others
    let previous: DestinationNode?
    
    /// nil for intermediate views, always present for root and sheet
    var path: [Destination]? {
        didSet {
            // trigger only on view pop
            if (oldValue?.count ?? 0) > (path?.count ?? 0) {
                delegate?.onPathViewPop()
            }
        }
    }
    
    /// present if the view show a sheet
    var sheetItem: Destination? {
        didSet {
            // trigger only on view pop
            if oldValue != nil && sheetItem == nil {
                delegate?.onSheetItemPop()
            }
        }
    }
    
    /// present if the view show an alert
    var alertItem: (any AlertDestinationProtocol)?
    
    init(
        destination: Destination,
        onDismiss: (() -> Void)?,
        previous: DestinationNode? = nil,
        path: [Destination]? = nil,
        sheetItem: Destination? = nil,
        alertItem: (any AlertDestinationProtocol)? = nil,
        popDelegate: DestinationNodePopProtocol
    ) {
        self.destination = destination
        self.onDismiss = onDismiss
        self.previous = previous
        self.path = path
        self.sheetItem = sheetItem
        self.alertItem = alertItem
        self.delegate = popDelegate
    }
    
    // Root init
    
    private init(
        destination: Destination?,
        path: [Destination]? = nil,
        popDelegate: DestinationNodePopProtocol?
    ) {
        self.destination = destination
        self.onDismiss = nil
        self.previous = nil
        self.path = path
        self.sheetItem = nil
        self.delegate = popDelegate
    }
    
    static func root(
        popDelegate: DestinationNodePopProtocol
    ) -> DestinationNode {
        return DestinationNode(
            destination: nil,
            path: [],
            popDelegate: popDelegate
        )
    }
    
    static func empty() -> DestinationNode {
        return DestinationNode(
            destination: nil,
            path: [],
            popDelegate: nil
        )
    }
    
    // Utilities
    
    func reloadView() {
        objectWillChange.send()
    }
}

extension DestinationNode: Hashable {
    nonisolated static func == (lhs: DestinationNode, rhs: DestinationNode) -> Bool {
        return lhs.id == rhs.id
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
