//
//  AlertDestination.swift
//  RoutingKit
//
//  Created by Marco Tammaro on 19/01/25.
//

import SwiftUI

/// `AlertDestinationProtocol` can be used to create custom alert with message and actions implementation of `View`
public protocol AlertDestinationProtocol<M, A> where M: View, A: View {
    
    associatedtype A = View
    associatedtype M = View
    
    func title() -> String
    @ViewBuilder func actions() -> A
    @ViewBuilder func message() -> M
    
}

// `AlertDestinationProtocol` Protocol Implementations

public struct TextAlertAction: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let role: ButtonRole
    public let action: () -> Void
    
    public init(title: String, role: ButtonRole, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }
    
    public static func == (lhs: TextAlertAction, rhs: TextAlertAction) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// A `AlertDestinationProtocol` implementation where title, message and actions are text based (typical alert use-case)
public struct TextAlert: AlertDestinationProtocol {
    
    private let alertTitle: String
    private let alertMessage: String
    private let alertActions: [TextAlertAction]
    
    public init(title: String, message: String? = nil, actions: [TextAlertAction]? = nil) {
        self.alertTitle = title
        self.alertMessage = message ?? ""
        self.alertActions = actions ?? []
    }
    
    public func title() -> String {
        return alertTitle
    }
    
    public func actions() -> some View {
        ForEach(alertActions, id: \.self) { action in
            Button(action.title, role: action.role, action: action.action)
        }
    }
    
    public func message() -> some View {
        Text(alertMessage)
    }
    
    
}
