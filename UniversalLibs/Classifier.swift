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
    func predictionDidChange(_ prediction: VNClassificationObservation, sender: Classifier)
}

class Classifier: VisionRequestManager {
    
    //Other vars
    private var model : VNCoreMLModel
    
    private var filteredPredictions : [String : LowPassFilter]
    weak var delegate : ClassifierDelegate?
    
    init(mlModel: MLModel, labels: [String], changeCategoryFilteringFactor: Float = 0.7, confidenceOfPredictionThreshold: Float = 0.97, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) throws {
        do {
            self.model =  try VNCoreMLModel(for: mlModel)
        } catch {
            throw ClassifierError.invalidModel
        }
        self.filteredPredictions = [String : LowPassFilter]()
        for category in labels {
            self.filteredPredictions[category] = LowPassFilter(value: 0.5, filterFactor: changeCategoryFilteringFactor)
        }
        super.init(confidenceOfPredictionThreshold: confidenceOfPredictionThreshold, imageSize: imageSize, imageOrientation: imageOrientation)
        self.name = mlModel.modelDescription.metadata[.description] as! String
    }
    
    private var prediction : VNClassificationObservation!
    {
        didSet {
            if (oldValue == nil && prediction != nil) || oldValue.identifier != prediction.identifier {
                //did change prediction print it!
                delegate?.predictionDidChange(prediction, sender:self)
            } else {
                //prediction is the same
            }
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
                        self.prediction = classification
                    }
                }
            }
        })
        self.request = [request]
    }
    
    override func runRequest(on imageData: Data, for objectObservations: [VNDetectedObjectObservation]) {
        super.runRequest(on: imageData, for: objectObservations)
    }
}

