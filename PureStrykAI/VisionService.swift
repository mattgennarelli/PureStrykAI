//
//  VisionService.swift
//  PureStrykAI
//
//  Created by You on Today's Date.
//

import UIKit

class VisionService {
    
    static let shared = VisionService()
    private init() {}
    
    /// Calls Google Vision API for OCR
    func performCloudOCR(on originalImage: UIImage,
                         completion: @escaping (Result<String, Error>) -> Void) {

        // 0. (Optional) resize image
        guard let resizedImage = resizeImage(originalImage, maxDimension: 1200) else {
            let error = NSError(domain: "VisionService",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to resize image"])
            completion(.failure(error))
            return
        }
        
        // 1. Convert to base64
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            let error = NSError(domain: "VisionService",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to JPEG"])
            completion(.failure(error))
            return
        }
        let base64Image = imageData.base64EncodedString()

        // 2. Construct the Vision API URL
        let apiKey = Secrets.googleVisionApiKey  // or however you store it
        guard let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)") else {
            let error = NSError(domain: "VisionService",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid Vision API URL"])
            completion(.failure(error))
            return
        }

        // 3. Prepare request
        let requestBody: [String: Any] = [
            "requests": [
                [
                    "image": ["content": base64Image],
                    "features": [
                        ["type": "DOCUMENT_TEXT_DETECTION"]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        // 4. Execute
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let error = NSError(domain: "VisionService",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "No data in Vision response"])
                completion(.failure(error))
                return
            }

            // Debug raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Cloud OCR Response:\n\(jsonString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responses = (json["responses"] as? [[String: Any]])?.first {
                    
                    // Check if there's an error
                    if let errorDict = responses["error"] as? [String: Any],
                       let message = errorDict["message"] as? String {
                        // Google returned an error
                        completion(.failure(NSError(domain: "VisionAPIError",
                                                    code: -1,
                                                    userInfo: [NSLocalizedDescriptionKey: message])))
                        return
                    }
                    
                    if let annotation = responses["fullTextAnnotation"] as? [String: Any],
                       let detectedText = annotation["text"] as? String {
                        completion(.success(detectedText))
                    } else {
                        completion(.success("")) // no text
                    }
                } else {
                    completion(.success(""))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Helper for resizing
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if aspectRatio > 1 {
            // landscape
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            // portrait
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
