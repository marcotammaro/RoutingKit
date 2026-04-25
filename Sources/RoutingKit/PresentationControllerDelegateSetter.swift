//
//  PresentationControllerDelegateSetter.swift
//  RoutingKit
//
//  Created by Marco Tammaro on 24/04/26.
//

import UIKit
import SwiftUI

// A helper to access the underlying presentationController and set its delegate reliably
private struct PresentationControllerDelegateSetter: UIViewControllerRepresentable {
    final class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var onWillDismiss: (() -> Void)?
        var onDidDismiss: (() -> Void)?
        var onAttemptToDismiss: (() -> Void)?
        var shouldDismiss: (() -> Bool)?

        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            onWillDismiss?()
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            onDidDismiss?()
        }

        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            return shouldDismiss?() ?? true
        }

        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            onAttemptToDismiss?()
        }
    }

    // A child view controller that installs the delegate once the parent (sheet's hosting controller)
    // is in place and/or has a presentationController available.
    final class DelegateInstallerViewController: UIViewController {
        weak var coordinator: Coordinator?

        private func installDelegateIfPossible() {
            if let pc = (self.parent?.presentationController ?? self.presentationController) {
                pc.delegate = coordinator
            }
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            installDelegateIfPossible()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            installDelegateIfPossible()
        }

        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            // Try again in case the presentationController becomes available later in the cycle
            installDelegateIfPossible()
        }
    }

    var onWillDismiss: (() -> Void)?
    var onDidDismiss: (() -> Void)?
    var onAttemptToDismiss: (() -> Void)?
    var shouldDismiss: (() -> Bool)?

    func makeCoordinator() -> Coordinator {
        let c = Coordinator()
        c.onWillDismiss = onWillDismiss
        c.onDidDismiss = onDidDismiss
        c.onAttemptToDismiss = onAttemptToDismiss
        c.shouldDismiss = shouldDismiss
        return c
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = DelegateInstallerViewController()
        controller.view.isHidden = true
        controller.view.isUserInteractionEnabled = false
        controller.coordinator = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let installer = uiViewController as? DelegateInstallerViewController {
            installer.coordinator = context.coordinator
        }
    }
}

// Convenience view modifier to attach the delegate
internal extension View {
    func presentationControllerDelegate(
        shouldDismiss: (() -> Bool)? = nil,
        onWillDismiss: (() -> Void)? = nil,
        onDidDismiss: (() -> Void)? = nil,
        onAttemptToDismiss: (() -> Void)? = nil
    ) -> some View {
        background(
            PresentationControllerDelegateSetter(
                onWillDismiss: onWillDismiss,
                onDidDismiss: onDidDismiss,
                onAttemptToDismiss: onAttemptToDismiss,
                shouldDismiss: shouldDismiss
            )
        )
    }
}
