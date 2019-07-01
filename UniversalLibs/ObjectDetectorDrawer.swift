//
//  ObjectDetectorDrawer.swift
//  Foscam-AI
//
//  Created by Giovanni Murru on 01/07/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#endif
import Foundation
import Vision

class ObjectDetectorDrawer {
    // Layer UI for drawing Vision results
    var rootLayer: CALayer?
    var detectionOverlayLayer: CALayer?
    var detectedFaceRectangleShapeLayer: CAShapeLayer?
    
    var displaySize : CGSize
    var captureSize : CGSize
    
    init(displaySize: CGSize, captureSize: CGSize) {
        self.displaySize = displaySize
        self.captureSize = captureSize
    }
    
    func setupVisionDrawingLayers() {
        guard let rootLayer = self.rootLayer else {
            print("Error: rootLayer is nil")
            return
        }
        
        let captureDeviceBounds = CGRect(x: 0,
                                         y: 0,
                                         width: captureSize.width,
                                         height: captureSize.height)
        
        let captureDeviceBoundsCenterPoint = CGPoint(x: captureDeviceBounds.midX,
                                                     y: captureDeviceBounds.midY)
        
        let normalizedCenterPoint = CGPoint(x: 0.5, y: 0.5)
        
        let overlayLayerCenterPosition = CGPoint(x: self.displaySize.width/2.0, y: self.displaySize.height/2.0)
        let overlayLayer = CALayer()
        overlayLayer.name = "DetectionOverlay"
        overlayLayer.masksToBounds = true
        overlayLayer.anchorPoint = normalizedCenterPoint
        overlayLayer.bounds = captureDeviceBounds
        overlayLayer.position = overlayLayerCenterPosition
        
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
    
    /// - Tag: DrawPaths
    func draw(_ faceObservations: [VNFaceObservation]) {
        guard let faceRectangleShapeLayer = self.detectedFaceRectangleShapeLayer
            else {
                return
        }
        
        CATransaction.begin()
        
        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
        
        let faceRectanglePath = CGMutablePath()
        
        for faceObservation in faceObservations {
            var faceBounds = VisionUtils.objectBounds(from: faceObservation.boundingBox, imageSize: captureSize)
            #if os(OSX)
            faceBounds = CGRect(origin: CGPoint(x: faceBounds.origin.x, y: captureSize.height - faceBounds.origin.y - faceBounds.size.height), size: faceBounds.size)
            #endif
            faceRectanglePath.addRect(faceBounds)
        }
        
        faceRectangleShapeLayer.path = faceRectanglePath
        
        self.updateLayerGeometry()
        
        CATransaction.commit()
    }
    
    fileprivate func presentErrorAlert(withTitle title: String = "Unexpected Failure", message: String) {
        //TODO: Implement
       
    }
    
    fileprivate func updateLayerGeometry() {
        guard let overlayLayer = self.detectionOverlayLayer
            else {
                return
        }
        
        // Rotate the layer into screen orientation.
        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
        let rotation : CGFloat = 0
        let scaleX : CGFloat = displaySize.width / captureSize.width
        let scaleY : CGFloat = displaySize.height / captureSize.height
        
        // Scale and mirror the image to ensure upright presentation.
        let affineTransform = CGAffineTransform(rotationAngle: radiansForDegrees(rotation))
            .scaledBy(x: scaleX, y: scaleY)
        overlayLayer.setAffineTransform(affineTransform)
        
        // Cover entire screen UI.
        //let rootLayerFrame = rootLayer.frame
        //overlayLayer.position = CGPoint(x: self.displaySize.width/2.0, y: self.displaySize.height/2.0)
    }
    
    fileprivate func radiansForDegrees(_ degrees: CGFloat) -> CGFloat {
        return CGFloat(Double(degrees) * Double.pi / 180.0)
    }
}
