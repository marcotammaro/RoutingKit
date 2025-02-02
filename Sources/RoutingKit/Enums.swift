//
//  File.swift
//  RoutingKit
//
//  Created by Marco Tammaro on 05/01/25.
//

import SwiftUI

public enum DismissOptions {
    /// Dismiss only the top view, wherever it is an alert, a sheet or a page
    case toPreviousView
    /// Dismiss everything until the root view has been reached
    case toRoot
    /// Dismiss everything until the nearest view containing a path is reached
    /// e.g. a sheet or a root view
    case toNavigationBegin
}

public enum NavigationType {
    /// Horizontal navigation with a navigation stack
    case push
    /// Vertical navigation with sheet item
    case sheet
}

public enum TransitionType {
    /// A navigation transition that zooms the appearing view from a
    /// given source view.
    ///
    /// Indicate the source view using the
    /// ``View/matchedTransitionSource(id:namespace:)`` modifier.
    ///
    /// - Parameters:
    ///   - sourceID: The identifier you provide to a corresponding
    ///     `matchedTransitionSource` modifier.
    ///   - namespace: The namespace where you define the `id`. You can create
    ///     new namespaces by adding the ``Namespace`` attribute
    ///     to a ``View`` type, then reading its value in the view's body
    ///     method.
    case zoom(sourceID: any Hashable, namespace: Namespace.ID)
}
