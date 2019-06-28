//
//  GenderClassifierController.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 28/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation
import Vision
import CoreML

protocol GenderClassifierDelegate : AnyObject {
    func genderDidChange(prediction: String)
}

class GenderClassifierController {
    
    lazy var genderModel = try? VNCoreMLModel(for: GenderNet().model)
    private var genderRequest: [VNCoreMLRequest]?
    
    var maleConfidence = LowPassFilter(value: 0.5, filterFactor: 0.5)
    
    weak var delegate : GenderClassifierDelegate?
    
    var prediction : String = "Undefined"
    {
        didSet {
            if oldValue != prediction {
                //did change prediction print it!
                delegate?.genderDidChange(prediction: prediction)
            } else {
                //prediction is the same
            }
            
        }
    }
    func predictGender(from imageData: Data, detectedFaces: [VNFaceObservation], displaySize: CGSize, exifOrientation: CGImagePropertyOrientation) {
        if detectedFaces.count > 0 {
            let requestHandlerOptions: [VNImageOption: AnyObject] = [:]
            for croppedFace in VisionUtils.croppedFaces(from: imageData, using: detectedFaces, displaySize: displaySize) {
                let genderRequestHandler = VNImageRequestHandler(cgImage: croppedFace, orientation: exifOrientation, options: requestHandlerOptions)
                do {
                    guard let genderRequests = self.genderRequest else {
                        return
                    }
                    try genderRequestHandler.perform(genderRequests)
                } catch let error {
                    print("Failed to perform GenderRequest: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func prepareVisionRequest() {
        if let gm = self.genderModel {
            let genderRequest = VNCoreMLRequest(model: gm, completionHandler: { (request, error) in
                guard let results = request.results as? [VNClassificationObservation] else {
                    return
                }
                for classification in results {
                    if classification.identifier == "Male" {
                        self.maleConfidence.update(newValue: classification.confidence)
                        break
                    }
                }
                
                if self.maleConfidence.value > 0.99 {
                    self.prediction = "Male"
                } else if self.maleConfidence.value < 0.01 {
                    self.prediction = "Female"
                }
            })
            self.genderRequest = [genderRequest]
        }
    }
}
