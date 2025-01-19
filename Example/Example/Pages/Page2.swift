//
//  Page1.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 28/11/24.
//

import SwiftUI
import RoutingKit

struct Page2: View {
    
    var body: some View {
        VStack {
            Text("Page 2")
            
            Spacer()
            
            Button {
                router.push(to: .page3)
            } label: {
                Text("Go to Page3")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button {
                router.sheet(to: .sheet1)
            } label: {
                Text("Go to Sheet1")
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
            Color.green.ignoresSafeArea()
        }
    }
}
