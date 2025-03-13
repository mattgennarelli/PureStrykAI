//
//  ViewController.swift
//  PureStrykAI
//
//  Created by Matthew Gennarelli on 3/13/25.
//

import UIKit
import UIKit
import FirebaseAuth      // For Auth.auth()
import FirebaseFirestore // For Firestore.firestore()

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Example usage:
        let user = Auth.auth().currentUser
        print("Current user is \(user?.uid ?? "none")")

        let db = Firestore.firestore()
        db.collection("test").document("doc1").setData(["hello": "world"]) { error in
            if let error = error {
                print("Firestore write failed: \(error)")
            } else {
                print("Firestore write succeeded!")
            }
        }
    }
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        // Step 1: Create an action sheet
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        // Step 2: Camera option (only if camera is available)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
        }
        
        // Step 3: Photo library option
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.openPhotoLibrary()
            }))
        }
        
        // Step 4: Cancel option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // On iPad, action sheets need a source view/popover anchor
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        // Step 5: Present the action sheet
        present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }

    func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }


    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            // e.g., display in a UIImageView
             capturedImageView.image = image
            
            // or call your OCR / upload function
            // performOCR(on: image)
            // uploadImage(image)
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var capturedImageView: UIImageView!
    
}
