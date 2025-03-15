//
//  OnDeviceVisionService.swift
//  PureStrykAI
//
//  Created by Matthew Gennarelli on 3/14/25.
//
import UIKit
import Vision

class OnDeviceVisionService {
    
    static let shared = OnDeviceVisionService()
    private init() {}
    
    /// Performs Apple Vision OCR on a UIImage and returns the recognized lines
    func performOnDeviceOCR(on image: UIImage,
                            completion: @escaping (Result<[String], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(OCRServiceError.noCGImage))
            return
        }
        
        // 1. Create a VNImageRequestHandler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // 2. Create a VNRecognizeTextRequest
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.success([])) // No text found
                return
            }
            
            var recognizedLines: [String] = []
            for obs in observations {
                // We only want the top candidate
                if let topCandidate = obs.topCandidates(1).first {
                    recognizedLines.append(topCandidate.string)
                }
            }
            completion(.success(recognizedLines))
        }
        
        // 3. Configure the request
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        // If you want multiple languages or more correction, you can tweak above

        // 4. Perform the request
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
}

enum OCRServiceError: Error {
    case noCGImage
}
