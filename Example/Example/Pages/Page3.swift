//
//  Page3.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 28/11/24.
//

import SwiftUI
import RoutingKit

struct Page3: View {
    
    var body: some View {
        VStack {
            Text("Page 3")
            
            Spacer()
            
            Button {
                router.push(to: .page2)
            } label: {
                Text("Go page 2")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button {
                router.dismiss(option: .toRoot)
            } label: {
                Text("Go to root")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button {
                router.dismiss()
            } label: {
                Text("Go back")
            }
            .buttonStyle(BorderedProminentButtonStyle())

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.indigo.ignoresSafeArea()
        }
    }
}
