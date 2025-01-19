//
//  Sheet1.swift
//  NavigationArch
//
//  Created by Marco Tammaro on 28/11/24.
//

import SwiftUI
import RoutingKit

struct CustomAlert: AlertDestinationProtocol {
    
    @Binding var text: String
    
    public func title() -> String {
        return "Some Custom Alert"
    }
    
    public func actions() -> some View {
        TextField("A TextField", text: $text)
    }
    
    public func message() -> some View {
        Text("This is the message")
    }
}

struct Sheet1: View {
    
    @State var text: String = ""
    
    var body: some View {
        
        VStack {
            Text("Hello, this is a sheet")
            Text("Use the alert to write some text")
            
            if !text.isEmpty {
                Text("Alert says: \(text)")
            }
            
            Spacer()
            
            Button {
                router.push(to: .sheet2)
            } label: {
                Text("Go to Sheet2")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button {
                let alert = CustomAlert(text: $text)
                router.showAlert(alert)
            } label: {
                Text("Show Alert")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button {
                router.dismiss()
            } label: {
                Text("Go back")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
        }
        .navigationTitle("Sheet1")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.mint.ignoresSafeArea()
        }
    }
}
