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

class GenderClassifier {
    
    lazy var genderModel = try? VNCoreMLModel(for: GenderNet().model)
    private var genderRequest: [VNCoreMLRequest]?
    
    var filteredPredictions : [String : LowPassFilter]
    var confidenceThreshold : Float
    var imageOrientation : CGImagePropertyOrientation
    var imageSize : CGSize
    weak var delegate : GenderClassifierDelegate?
    
    init(labels: [String], changeCategoryFilteringFactor: Float = 0.7, confidenceOfPredictionThreshold: Float = 0.97, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) {
        self.confidenceThreshold = confidenceOfPredictionThreshold
        self.filteredPredictions = [String : LowPassFilter]()
        self.imageOrientation = imageOrientation
        self.imageSize = imageSize
        for category in labels {
            self.filteredPredictions[category] = LowPassFilter(value: 0.5, filterFactor: changeCategoryFilteringFactor)
        }
    }
    
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
    func predictGender(from imageData: Data, detectedFaces: [VNFaceObservation]) {
        if detectedFaces.count > 0 {
            let requestHandlerOptions: [VNImageOption: AnyObject] = [:]
            for croppedFace in VisionUtils.croppedFaces(from: imageData, using: detectedFaces, imageSize: imageSize) {
                let genderRequestHandler = VNImageRequestHandler(cgImage: croppedFace, orientation: imageOrientation, options: requestHandlerOptions)
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
                    self.filteredPredictions[classification.identifier]?.update(newValue: classification.confidence)
                    if let newConfidence = self.filteredPredictions[classification.identifier]?.value {
                        if newConfidence > 0.97 {
                            self.prediction = classification.identifier
                        }
                    }
                }
            })
            self.genderRequest = [genderRequest]
        }
    }
}
