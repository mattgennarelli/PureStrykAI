//
//  ImagePreprocessing.swift
//  PureStrykAI
//
//  Created by Matthew Gennarelli on 3/15/25.
//

import UIKit
import CoreImage

struct ImagePreprocessing {
    
    static func preprocessImageForOCR(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Example: convert to grayscale
        guard let grayscaleFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        grayscaleFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let grayscaleOutput = grayscaleFilter.outputImage else { return nil }
        
        // Optionally apply thresholding (iOS 15+)
        let thresholdFilterName = "CIColorThreshold"
        if let thresholdFilter = CIFilter(name: thresholdFilterName) {
            thresholdFilter.setValue(grayscaleOutput, forKey: kCIInputImageKey)
            thresholdFilter.setValue(0.5, forKey: "inputThreshold") // tweak threshold
            guard let thresholdOutput = thresholdFilter.outputImage else { return nil }
            return UIImage(ciImage: thresholdOutput)
        } else {
            // fallback to just grayscale
            return UIImage(ciImage: grayscaleOutput)
        }
    }
}
