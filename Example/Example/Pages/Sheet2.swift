//
//  Sheet2.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 28/11/24.
//

import SwiftUI
import RoutingKit

struct Sheet2: View {
    
    var body: some View {
        VStack {
            Text("Some content")
            
            Spacer()
            
            Button {
                router.dismiss(option: .toRoot)
            } label: {
                Text("Go to root")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button {
                router.dismiss(option: .toNavigationBegin)
            } label: {
                Text("Go to navigation begin")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button {
                router.dismiss()
            } label: {
                Text("Go back")
            }
            .buttonStyle(BorderedProminentButtonStyle())

        }
        .navigationTitle("Sheet2")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.yellow.ignoresSafeArea()
        }
    }
}
