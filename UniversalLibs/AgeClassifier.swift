//
//  AgeClassifier.swift
//  Foscam-AI
//
//  Created by Giovanni Murru on 01/07/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation
import Vision
import CoreML

class AgeClassifier : Classifier {
    init(changeCategoryFilteringFactor: Float = 0.7, confidenceOfPredictionThreshold: Float = 0.97, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) throws {
        //(0-2, 4-6, 8-13, 15-20, 25-32, 38-43, 48-53, 60-)
        try super.init(mlModel: AgeNet().model, labels: ["0-2", "4-6", "8-13", "15-20", "25-32", "38-43", "48-53", "60-"], changeCategoryFilteringFactor: changeCategoryFilteringFactor, confidenceOfPredictionThreshold: confidenceOfPredictionThreshold, imageSize: imageSize, imageOrientation: imageOrientation)
        self.name = "Age"
    }
    
    func runRequest(on imageData: Data, for objectObservations: [VNFaceObservation]) {
        super.runRequest(on: imageData, for: objectObservations)
    }
}
