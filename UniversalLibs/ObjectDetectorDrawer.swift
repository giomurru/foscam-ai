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
    var detectedObjectRectangleShapeLayer: CAShapeLayer?
    
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
        
        let objectRectangleShapeLayer = CAShapeLayer()
        objectRectangleShapeLayer.name = "RectangleOutlineLayer"
        objectRectangleShapeLayer.bounds = captureDeviceBounds
        objectRectangleShapeLayer.anchorPoint = normalizedCenterPoint
        objectRectangleShapeLayer.position = captureDeviceBoundsCenterPoint
        objectRectangleShapeLayer.fillColor = nil
        objectRectangleShapeLayer.strokeColor = UIColor.green.cgColor
        objectRectangleShapeLayer.lineWidth = 1
        
        overlayLayer.addSublayer(objectRectangleShapeLayer)
        rootLayer.addSublayer(overlayLayer)
        
        self.detectionOverlayLayer = overlayLayer
        self.detectedObjectRectangleShapeLayer = objectRectangleShapeLayer
        
        self.updateLayerGeometry()
        
    }
    
    func clear() {
        draw([])
    }
    
    /// - Tag: DrawPaths
    ///
    ///
    func draw(_ objectObservations: [VNDetectedObjectObservation]) {
        guard let objectRectangleShapeLayer = self.detectedObjectRectangleShapeLayer
            else {
                return
        }
        
        CATransaction.begin()
        
        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
        
        let objectRectanglePath = CGMutablePath()
        
        for objectObservation in objectObservations {
            var objectBounds = VisionUtils.objectBounds(from: objectObservation.boundingBox, imageSize: captureSize)
            #if os(OSX)
            objectBounds = CGRect(origin: CGPoint(x: objectBounds.origin.x, y: captureSize.height - objectBounds.origin.y - objectBounds.size.height), size: objectBounds.size)
            #endif
            objectRectanglePath.addRect(objectBounds)
        }
        
        objectRectangleShapeLayer.path = objectRectanglePath
        
        self.updateLayerGeometry()
        
        CATransaction.commit()
    }
    
    private func presentErrorAlert(withTitle title: String = "Unexpected Failure", message: String) {
        //TODO: Implement
       
    }
    
    private func updateLayerGeometry() {
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
    
    private func radiansForDegrees(_ degrees: CGFloat) -> CGFloat {
        return CGFloat(Double(degrees) * Double.pi / 180.0)
    }
}
