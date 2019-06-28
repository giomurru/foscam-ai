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
    func visionContentSize() -> CGSize
    func overlayLayerOrientation() -> CGImagePropertyOrientation
    func overlayLayerScaleMultipliers() -> CGPoint // multipliers to the scale of the overlay layer
}

class FaceDetectorViewController : UIViewController
{
    weak var datasource : FaceDetectorDataSource?
    
    var captureDeviceResolution: CGSize = CGSize()
    // Layer UI for drawing Vision results
    var rootLayer: CALayer?
    var detectionOverlayLayer: CALayer?
    var detectedFaceRectangleShapeLayer: CAShapeLayer?
    
    var detectedFaces = [VNFaceObservation]()
    // Vision requests
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    
    func trackFace(from imageData: Data) {
        let requestHandlerOptions: [VNImageOption: AnyObject] = [:]
        let exifOrientation = self.datasource?.overlayLayerOrientation() ?? CGImagePropertyOrientation.up
        let imageRequestHandler = VNImageRequestHandler(data: imageData, orientation: exifOrientation, options: requestHandlerOptions)
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
    func prepareVisionRequest() {
        
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
        let captureDeviceResolution = self.captureDeviceResolution
        
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
        let faceBounds = VisionUtils.faceBounds(from: faceObservation.boundingBox, displaySize: self.captureDeviceResolution)
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
        
        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
        
        if let videoPreviewSize = self.datasource?.visionContentSize() {
            // Rotate the layer into screen orientation.
            let rotation : CGFloat = 0
            let scaleX : CGFloat = videoPreviewSize.width / captureDeviceResolution.width
            let scaleY : CGFloat = videoPreviewSize.height / captureDeviceResolution.height
            
            let multipliers = self.datasource?.overlayLayerScaleMultipliers() ?? CGPoint(x: 1.0, y: 1.0)
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
