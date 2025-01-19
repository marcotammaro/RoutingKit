//
//  Destination.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 03/01/25.
//

import SwiftUI

public struct Destination: Identifiable, Hashable {
    public let id = UUID()
    public let content: () -> any View
    
    public init(content: @escaping () -> any View) {
        self.content = content
    }
    
    public static func == (lhs: Destination, rhs: Destination) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
