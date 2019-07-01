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

protocol FaceDetectorDataSource : AnyObject {
    var displaySize : CGSize { get }
    func overlayLayerScaleMultipliers() -> CGPoint // multipliers to the scale of the overlay layer
}

class FaceDetector : VisionRequestManager
{
    func runRequest(on image: CGImage) {
        
    }
    
    func runRequest(on imageData: Data, for objectObservations: [VNDetectedObjectObservation]) {
        
    }
    
    //VisionRequestManager protocol requirements
    var name : String
    var confidenceThreshold : Float
    var imageOrientation : CGImagePropertyOrientation
    var imageSize : CGSize
    
    weak var datasource : FaceDetectorDataSource?
    
    // Layer UI for drawing Vision results
    var rootLayer: CALayer?
    var detectionOverlayLayer: CALayer?
    var detectedFaceRectangleShapeLayer: CAShapeLayer?
    
    var detectedFaces = [VNFaceObservation]()
    // Vision requests
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    
    init(confidenceOfPredictionThreshold: Float = 0.97, imageSize: CGSize, imageOrientation: CGImagePropertyOrientation) {
        self.name = "Face Detector"
        self.confidenceThreshold = confidenceOfPredictionThreshold
        self.imageSize = imageSize
        self.imageOrientation = imageOrientation
    }
    
    func runRequest(on imageData: Data) {
        let requestHandlerOptions: [VNImageOption: AnyObject] = [:]
        let imageRequestHandler = VNImageRequestHandler(data: imageData, orientation: imageOrientation, options: requestHandlerOptions)
        do {
            guard let detectRequests = self.detectionRequests else {
                return
            }
            try imageRequestHandler.perform(detectRequests)
        } catch let error {
            print("Failed to perform FaceRectangleRequest: \(error.localizedDescription)")
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
            
            self.detectedFaces = results
            
            DispatchQueue.main.async {
                self.drawFaceObservations(results)
            }
        })
        
        
        
        // Start with detection.  Find face, then track it.
        self.detectionRequests = [faceDetectionRequest]
        
        self.setupVisionDrawingLayers()
    }
    
    fileprivate func setupVisionDrawingLayers() {
        let captureDeviceResolution = self.imageSize
        
        let captureDeviceBounds = CGRect(x: 0,
                                         y: 0,
                                         width: captureDeviceResolution.width,
                                         height: captureDeviceResolution.height)
        
        let captureDeviceBoundsCenterPoint = CGPoint(x: captureDeviceBounds.midX,
                                                     y: captureDeviceBounds.midY)
        
        let normalizedCenterPoint = CGPoint(x: 0.5, y: 0.5)
        
        guard let rootLayer = self.rootLayer else {
            self.presentErrorAlert(message: "view was not property initialized")
            return
        }
        
        let overlayLayer = CALayer()
        overlayLayer.name = "DetectionOverlay"
        overlayLayer.masksToBounds = true
        overlayLayer.anchorPoint = normalizedCenterPoint
        overlayLayer.bounds = captureDeviceBounds
        overlayLayer.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        
        let faceRectangleShapeLayer = CAShapeLayer()
        faceRectangleShapeLayer.name = "RectangleOutlineLayer"
        faceRectangleShapeLayer.bounds = captureDeviceBounds
        faceRectangleShapeLayer.anchorPoint = normalizedCenterPoint
        faceRectangleShapeLayer.position = captureDeviceBoundsCenterPoint
        faceRectangleShapeLayer.fillColor = nil
        faceRectangleShapeLayer.strokeColor = UIColor.green.cgColor
        faceRectangleShapeLayer.lineWidth = 1
        
        overlayLayer.addSublayer(faceRectangleShapeLayer)
        rootLayer.addSublayer(overlayLayer)
        
        self.detectionOverlayLayer = overlayLayer
        self.detectedFaceRectangleShapeLayer = faceRectangleShapeLayer
        
        self.updateLayerGeometry()
        
    }
    
    fileprivate func addBoundingBox(to faceRectanglePath: CGMutablePath, for faceObservation: VNFaceObservation) {
        let faceBounds = VisionUtils.faceBounds(from: faceObservation.boundingBox, imageSize: imageSize)
        faceRectanglePath.addRect(faceBounds)
    }
    
    /// - Tag: DrawPaths
    fileprivate func drawFaceObservations(_ faceObservations: [VNFaceObservation]) {
        guard let faceRectangleShapeLayer = self.detectedFaceRectangleShapeLayer
            else {
                return
        }
        
        CATransaction.begin()
        
        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
        
        let faceRectanglePath = CGMutablePath()
        
        for faceObservation in faceObservations {
            self.addBoundingBox(to: faceRectanglePath, for: faceObservation)
        }
        
        faceRectangleShapeLayer.path = faceRectanglePath
        
        self.updateLayerGeometry()
        
        CATransaction.commit()
    }
    
    fileprivate func presentErrorAlert(withTitle title: String = "Unexpected Failure", message: String) {
        //TODO: Implement
        print("Error Alert: \(title)\n\(message)")
    }
    
    fileprivate func updateLayerGeometry() {
        guard let overlayLayer = self.detectionOverlayLayer,
            let rootLayer = self.rootLayer
            else {
                return
        }
        
        // Rotate the layer into screen orientation.
        if let datasource = self.datasource {
            CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
            let rotation : CGFloat = 0
            let scaleX : CGFloat = datasource.displaySize.width / imageSize.width
            let scaleY : CGFloat = datasource.displaySize.height / imageSize.height
            
            let multipliers = datasource.overlayLayerScaleMultipliers()
            // Scale and mirror the image to ensure upright presentation.
            let affineTransform = CGAffineTransform(rotationAngle: radiansForDegrees(rotation))
                .scaledBy(x: multipliers.x * scaleX, y: multipliers.y * scaleY)
            overlayLayer.setAffineTransform(affineTransform)
            
            // Cover entire screen UI.
            let rootLayerBounds = rootLayer.bounds
            overlayLayer.position = CGPoint(x: rootLayerBounds.midX, y: rootLayerBounds.midY)
        }
    }
    
    fileprivate func radiansForDegrees(_ degrees: CGFloat) -> CGFloat {
        return CGFloat(Double(degrees) * Double.pi / 180.0)
    }
}
