//
//  FaceTrackerViewController.swift
//  TestFoscamCam_osx
//
//  Created by Giovanni Murru on 27/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//
#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#endif
import Foundation
import Vision


protocol FaceDetectorDelegate : AnyObject {
    func predictionDidChange(_ prediction: [VNFaceObservation], sender: FaceDetector)
}

class FaceDetector : VisionRequestManager
{
    weak var delegate : FaceDetectorDelegate?
    
    override init(confidenceOfPredictionThreshold: Float = 0.97, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) {
        super.init(confidenceOfPredictionThreshold: confidenceOfPredictionThreshold, imageSize: imageSize, imageOrientation: imageOrientation)
        self.name = "Face detector"
    }
    
    private var prediction = [VNFaceObservation]()
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
    
    //Vision
    func prepareRequest() {
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
            
            if error != nil {
                print("FaceDetection error: \(String(describing: error)).")
            }

            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                let results = faceDetectionRequest.results as? [VNFaceObservation] else {
                    return
            }
            
            self.prediction = results
            
        })
        
        
        
        // Start with detection.  Find face, then track it.
        self.request = [faceDetectionRequest]
        
//        self.setupVisionDrawingLayers()
    }
}
