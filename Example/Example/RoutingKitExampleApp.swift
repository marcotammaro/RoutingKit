//
//  RoutingKitExampleApp.swift
//  RoutingKitExample
//
//  Created by Marco Tammaro on 04/01/25.
//

import SwiftUI
import RoutingKit

extension Destination {
    static let page1 = Destination { Page1() }
    static let page2 = Destination { Page2() }
    static let page3 = Destination { Page3() }
    static let sheet1 = Destination { Sheet1() }
    static let sheet2 = Destination { Sheet2() }
}

@MainActor let router = Router()

@main
struct RoutingKitExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RoutableRootView(router: router) {
                Page1()
            }
        }
    }
}
