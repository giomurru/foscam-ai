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


protocol ObjectDetectorDelegate : AnyObject {
    func predictionDidChange(_ prediction: [VNRecognizedObjectObservation], sender: ObjectDetector)
}

class ObjectDetector : VisionRequestManager
{
    weak var delegate : ObjectDetectorDelegate?
    
    var detectionsCount = [String: Int]()
    override init(confidenceOfPredictionThreshold: Float = 0.97, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) {
        super.init(confidenceOfPredictionThreshold: confidenceOfPredictionThreshold, imageSize: imageSize, imageOrientation: imageOrientation)
        self.name = "Object detector"
    }
    
    private var prediction = [VNRecognizedObjectObservation]()
    {
        didSet {
            delegate?.predictionDidChange(prediction, sender:self)
            
            prediction.forEach { observation in
                
                if let person = observation.labels.filter { $0.identifier == "person" }.first {
                    if person.confidence > 0.99 {
                        if let c = detectionsCount["person"] {
                            detectionsCount["person"] = c + 1
                        } else {
                            detectionsCount["person"] = 1
                        }
                    }
                }
                if let cat = observation.labels.filter { $0.identifier == "cat" }.first {
                    if cat.confidence > 0.9 {
                        if let c = detectionsCount["cat"] {
                            detectionsCount["cat"] = c + 1
                        } else {
                            detectionsCount["cat"] = 1
                        }
                    }
                }
                if let bird = observation.labels.filter { $0.identifier == "bird" }.first {
                    if bird.confidence > 0.5 {
                        if let c = detectionsCount["bird"] {
                            detectionsCount["bird"] = c + 1
                        } else {
                            detectionsCount["bird"] = 1
                        }
                    }
                }
            }
        }
    }
    
    func prepareRequest() {
        do {
            let visionModel = try VNCoreMLModel(for: YOLOv3().model)

            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    guard let objectDetectionRequest = request as? VNCoreMLRequest, let results = request.results as? [VNRecognizedObjectObservation] else {
                        return
                    }
                    self.prediction = results
                })
            })
            
            // Start with detection.  Find face, then track it.
            self.request = [objectRecognition]
        } catch {
            print("ERROR initializing YOLOv3 model")
        }
        
        
    }
}
