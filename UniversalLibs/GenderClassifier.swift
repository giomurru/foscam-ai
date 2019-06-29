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

class GenderClassifier : Classifier {
    init(changeCategoryFilteringFactor: Float = 0.7, confidenceOfPredictionThreshold: Float = 0.97, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) throws {
        try super.init(mlModel: GenderNet().model, labels: ["Male", "Female"], changeCategoryFilteringFactor: changeCategoryFilteringFactor, confidenceOfPredictionThreshold: confidenceOfPredictionThreshold, imageSize: imageSize, imageOrientation: imageOrientation)
        self.name = "Gender"
    }
}
