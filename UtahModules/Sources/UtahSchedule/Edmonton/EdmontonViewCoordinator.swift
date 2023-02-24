//
// This source file is part of the CS342 2023 Utah Team Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable lower_acl_than_parent
import Firebase
import FirebaseStorage
import Foundation
import ModelsR4
import ResearchKit


class EdmontonViewCoordinator: NSObject, ORKTaskViewControllerDelegate {
    public func taskViewController(
        _ taskViewController: ORKTaskViewController,
        didFinishWith reason: ORKTaskViewControllerFinishReason,
        error: Error?
    ) {
        switch reason {
        case .completed:
            // Convert the responses into a FHIR object using ResearchKitOnFHIR
            let fhirResponse = taskViewController.result.fhirResponse

            // Add a patient identifier to the response so we know who did this survey
            fhirResponse.subject = Reference(reference: FHIRPrimitive(FHIRString("Patient/PATIENT_ID")))

            do {
                // Parse the FHIR object into JSON
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(fhirResponse)

                // Print out the JSON for debugging
                let json = String(decoding: data, as: UTF8.self)
                print(json)

                // Convert the FHIR object to a dictionary and upload to Firebase
                let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let identifier = fhirResponse.id?.value?.string ?? UUID().uuidString

                guard let jsonDict else {
                    return
                }

                let database = Firestore.firestore()
                database.collection("edmontonsurveys").document(identifier).setData(jsonDict) { err in
                    if let err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written.")
                    }
                }

                // Upload any files that are attached to the FHIR object to Firebase
                if let responseItems = fhirResponse.item {
                    for item in responseItems {
                        if case let .attachment(value) = item.answer?.first?.value {
                            guard let fileURL = value.url?.value?.url else {
                                continue
                            }

                            // Get a reference to the Cloud Storage service
                            let storageRef = Storage.storage().reference()

                            // Create a reference for the new file
                            // and put it in the "edmonton" file on Cloud Storage
                            let fileName = fileURL.lastPathComponent
                            let fileRef = storageRef.child("edmonton/" + fileName)

                            // Upload the file to Cloud Storage using the reference
                            fileRef.putFile(from: fileURL, metadata: nil) { _, error in
                                if let error {
                                    print("An error occurred: \(error)")
                                } else {
                                    print("\(fileName) was uploaded successfully!")
                                }
                            }
                        }
                    }
                }
            } catch {
                // Something didn't work!
                print(error.localizedDescription)
            }
        default:
            break
        }

        // We're done, dismiss the survey
        taskViewController.dismiss(animated: true, completion: nil)
        taskViewController.dismiss(animated: true, completion: nil)
    }
}