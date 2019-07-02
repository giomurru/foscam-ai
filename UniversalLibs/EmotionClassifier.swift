//
//  EmotionClassifier.swift
//  Foscam-AI
//
//  Created by Giovanni Murru on 02/07/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation
import Vision
import CoreML

class EmotionClassifier : Classifier {
    init(changeCategoryFilteringFactor: Float = 0.7, confidenceOfPredictionThreshold: Float = 0.97, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) throws {
        try super.init(mlModel: CNNEmotions().model, labels: ["Angry", "Disgust", "Fear", "Happy" , "Neutral",  "Sad", "Surprise"], changeCategoryFilteringFactor: changeCategoryFilteringFactor, confidenceOfPredictionThreshold: confidenceOfPredictionThreshold, imageSize: imageSize, imageOrientation: imageOrientation)
        self.name = "Emotion"
    }
    
    func runRequest(on imageData: Data, for objectObservations: [VNFaceObservation]) {
        super.runRequest(on: imageData, for: objectObservations)
    }
}
