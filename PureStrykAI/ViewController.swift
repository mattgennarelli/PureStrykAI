//
//  ViewController.swift
//  PureStrykAI
//
//  Created by You on Today's Date.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import TOCropViewController // If you want to reference it here

class ViewController: UIViewController {

    @IBOutlet weak var capturedImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // e.g., Firestore test
        let user = Auth.auth().currentUser
        print("Current user is \(user?.uid ?? "none")")

        Firestore.firestore().collection("test").document("doc1").setData(["hello": "world"]) { error in
            if let error = error {
                print("Firestore write failed: \(error)")
            } else {
                print("Firestore write succeeded!")
            }
        }
    }

    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)

        // If camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
        }
        // If photo library is available
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.openPhotoLibrary()
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad anchor
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }

        present(alert, animated: true)
    }

    private func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    // Simple utility to show final text
    func showDetectedTextAlert(_ text: String) {
        let alert = UIAlertController(title: "OCR Result",
                                      message: text.isEmpty ? "No text found" : text,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        // 1. Dismiss the picker
        picker.dismiss(animated: true) {
            // 2. Now present the cropping screen
            self.presentCropViewController(with: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Presenting the Crop VC
extension ViewController {
    func presentCropViewController(with image: UIImage) {
        let cropVC = TOCropViewController(image: image)
        cropVC.delegate = self // The delegate calls are in CropViewControllerDelegate.swift
        present(cropVC, animated: true)
    }
}
