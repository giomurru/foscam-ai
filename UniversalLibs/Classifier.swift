//
//  Classifier.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 29/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation
import Vision
import CoreML


enum ClassifierError: Error {
    case invalidModel
}

protocol ClassifierDelegate : AnyObject {
    func predictionDidChange(_ prediction: String, sender: Classifier)
}

class Classifier: VisionRequestManager {
    
    //VisionRequestManager protocol requirements
    var name : String
    var confidenceThreshold : Float
    var imageOrientation : CGImagePropertyOrientation
    var imageSize : CGSize
    
    //Other vars
    private var model : VNCoreMLModel
    private var request: [VNCoreMLRequest]?
    private var filteredPredictions : [String : LowPassFilter]
    weak var delegate : ClassifierDelegate?
    
    init(mlModel: MLModel, labels: [String], changeCategoryFilteringFactor: Float = 0.7, confidenceOfPredictionThreshold: Float = 0.97, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) throws {
        self.name = mlModel.modelDescription.metadata[.description] as! String
        self.confidenceThreshold = confidenceOfPredictionThreshold
        self.filteredPredictions = [String : LowPassFilter]()
        self.imageOrientation = imageOrientation
        self.imageSize = imageSize
        do {
            self.model =  try VNCoreMLModel(for: mlModel)
        } catch {
            throw ClassifierError.invalidModel
        }
        for category in labels {
            self.filteredPredictions[category] = LowPassFilter(value: 0.5, filterFactor: changeCategoryFilteringFactor)
        }
    }
    
    private var prediction : String = "Undefined"
    {
        didSet {
            if oldValue != prediction {
                //did change prediction print it!
                delegate?.predictionDidChange(prediction, sender:self)
            } else {
                //prediction is the same
            }
        }
    }
    
    // Public API
    func runRequest(on imageData: Data, for objectObservations: [VNDetectedObjectObservation]) {
        if objectObservations.count > 0 {
            for croppedFace in VisionUtils.croppedFaces(from: imageData, using: objectObservations, imageSize: imageSize) {
                runRequest(on: croppedFace)
            }
        } else {
            runRequest(on: imageData)
        }
    }
    
    func runRequest(on image: CGImage) {
        let requestHandler = VNImageRequestHandler(cgImage: image, orientation: imageOrientation, options: [:])
        do {
            guard let request = self.request else {
                return
            }
            try requestHandler.perform(request)
        } catch let error {
            print("Failed to perform request: \(error.localizedDescription)")
        }
    }
    
    func runRequest(on imageData: Data) {
        let requestHandler = VNImageRequestHandler(data: imageData, orientation: imageOrientation, options: [:])
        do {
            guard let request = self.request else {
                return
            }
            try requestHandler.perform(request)
        } catch let error {
            print("Failed to perform request: \(error.localizedDescription)")
        }
    }
    
    func prepareRequest() {
        let request = VNCoreMLRequest(model: self.model, completionHandler: { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            for classification in results {
                self.filteredPredictions[classification.identifier]?.update(newValue: classification.confidence)
                if let newConfidence = self.filteredPredictions[classification.identifier]?.value {
                    if newConfidence > self.confidenceThreshold {
                        self.prediction = classification.identifier
                    }
                }
            }
        })
        self.request = [request]
    }
}

