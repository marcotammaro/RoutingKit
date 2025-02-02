//
//  Page1.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 28/11/24.
//

import SwiftUI
import RoutingKit

struct Page1: View {
    
    @Namespace var zoomTransitionNamespace
    
    var body: some View {
        VStack {
            Text("Page 1")
            
            Spacer()
            
            Button {
                router.sheet(
                    to: .sheet1,
                    transition: .zoom(
                        sourceID: "ZoomId",
                        namespace: zoomTransitionNamespace
                    )
                )
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .frame(height: 50)
                    .overlay { Text("Zoom Transition") }
                    .foregroundStyle(.black)
                    .padding(.horizontal)
                    .matchedTransitionSource(id: "ZoomId", in: zoomTransitionNamespace)
            }
            
            Spacer()
            
            Button {
                router.push(to: .page2) {
                    print("Page 2 dismissed")
                }
            } label: {
                Text("Go to Page2")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button {
                router.showAlert(
                    title: "Alert title",
                    message: "This is an example of alert!",
                    actions: [
                        TextAlertAction(
                            title: "Destroy it",
                            role: .destructive,
                            action: { print("Destroying..") }
                        )
                    ]
                )
            } label: {
                Text("Show Alert")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button {
                router.sheet(to: .sheet1) {
                    print("Sheet 1 dismissed")
                }
            } label: {
                Text("Go to Sheet1")
            }
            .buttonStyle(BorderedProminentButtonStyle())

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.red.ignoresSafeArea()
        }
    }
}
