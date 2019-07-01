//
//  AIProtocol.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 30/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation
import Vision


class VisionRequestManager {
    var confidenceThreshold : Float
    var imageOrientation : CGImagePropertyOrientation
    var imageSize : CGSize
    var name : String = "Vision request"
    var request: [VNImageBasedRequest]?
    
    init(confidenceOfPredictionThreshold: Float, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) {
        self.confidenceThreshold = confidenceOfPredictionThreshold
        self.imageSize = imageSize
        self.imageOrientation = imageOrientation
    }
    
    func runRequest(on imageData: Data) {
        let requestHandlerOptions: [VNImageOption: AnyObject] = [:]
        let imageRequestHandler = VNImageRequestHandler(data: imageData, orientation: imageOrientation, options: requestHandlerOptions)
        do {
            guard let detectRequests = self.request else {
                return
            }
            try imageRequestHandler.perform(detectRequests)
        } catch let error {
            print("Failed to perform image request: \(error.localizedDescription)")
        }
    }
    
    func runRequest(on image: CGImage) {
        let requestHandlerOptions: [VNImageOption: AnyObject] = [:]
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: imageOrientation, options: requestHandlerOptions)
        do {
            guard let detectRequests = self.request else {
                return
            }
            try imageRequestHandler.perform(detectRequests)
        } catch let error {
            print("Failed to perform image request: \(error.localizedDescription)")
        }
    }
    
    func runRequest(on imageData: Data, for objectObservations: [VNDetectedObjectObservation]) {
        if objectObservations.count > 0 {
            for croppedObject in VisionUtils.croppedObjects(from: imageData, using: objectObservations, imageSize: imageSize) {
                runRequest(on: croppedObject)
            }
        } else {
            runRequest(on: imageData)
        }
    }
}

