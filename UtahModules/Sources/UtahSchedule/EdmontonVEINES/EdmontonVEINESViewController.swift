//
// This source file is part of the CS342 2023 Utah Team Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable function_body_length
// swiftlint:disable closure_body_length
// swiftlint:disable line_length
// swiftlint:disable object_literal
// swiftlint:disable force_unwrapping

import Foundation
import ResearchKit
import SwiftUI
import UIKit

struct EdmontonVEINESViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ORKTaskViewController
    
    func makeCoordinator() -> EdmontonVEINESViewCoordinator {
        EdmontonVEINESViewCoordinator()
    }
    
    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {}
    
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let taskViewController = ORKTaskViewController(
            task: EdmontonVEINESTask.createEdmontonVEINESTask(),
            taskRun: nil
        )
        taskViewController.delegate = context.coordinator
        taskViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // & present the VC!
        return taskViewController
    }
}