//
//  File.swift
//  RoutingKit
//
//  Created by Marco Tammaro on 05/01/25.
//

import Foundation

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
