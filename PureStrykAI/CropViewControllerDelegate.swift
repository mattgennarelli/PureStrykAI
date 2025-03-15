//
//  CropViewControllerDelegate.swift
//  PureStrykAI
//
//  Created by You on Today's Date.
//
//
//  CropViewControllerDelegate.swift
//  PureStrykAI
//
//  Created by You on Today's Date.
//

import UIKit
import TOCropViewController

extension ViewController: TOCropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: TOCropViewController,
                                didCropTo image: UIImage,
                                with cropRect: CGRect,
                                angle: Int) {
            // This is called when user taps "Done" after cropping.
            
            // 1. Dismiss the crop view controller
            cropViewController.dismiss(animated: true) {
                // 2. Display the cropped image
                let preprocessed = ImagePreprocessing.preprocessImageForOCR(image) ?? image
                self.capturedImageView.image = preprocessed
                
                // 3. (Optional) Pass to your OCR service
                OnDeviceVisionService.shared.performOnDeviceOCR(on: image) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let lines):
                            let combinedText = lines.joined(separator: "\n")
                            print("Cropped OCR =>\n\(combinedText)")
                            self.showDetectedTextAlert(combinedText.isEmpty ? "No text found" : combinedText)
                        case .failure(let error):
                            print("OCR error:", error)
                        }
                    }
                }
            }
        }
    
    func cropViewController(_ cropViewController: TOCropViewController,
                                didFinishCancelled cancelled: Bool) {
        // Called when user taps "Cancel"
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
