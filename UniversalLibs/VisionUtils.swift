//
//  VisionUtils.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 28/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation
import Vision
#if os(OSX)
import Cocoa
typealias UIViewController = NSViewController
typealias UIColor = NSColor
typealias UIImage = NSImage
#elseif os(iOS)
import UIKit
#endif


class VisionUtils {
    public static func faceBounds(from boundingBox: CGRect, displaySize: CGSize) -> CGRect {
        let bbox = VNImageRectForNormalizedRect(boundingBox, Int(displaySize.width), Int(displaySize.height))
        let expandW = bbox.width * 0.1
        let expandH = bbox.height * 0.1
        return CGRect(x: bbox.origin.x - expandW/2.0, y: displaySize.height - bbox.height - bbox.origin.y - expandH/2.0, width: bbox.width + expandW, height: bbox.height + expandH)
    }
    
    public static func croppedFaces(from imageData: Data, using faceObservations: [VNFaceObservation], displaySize: CGSize) -> [CGImage]{
        var crops = [CGImage]()
        if let cameraImage = UIImage(data: imageData)?.cgImage {
            for observation in faceObservations {
                let bbox = VisionUtils.faceBounds(from: observation.boundingBox, displaySize: displaySize)
                if let face = cameraImage.cropping(to: bbox) {
                    crops.append(face)
                }
            }
        }
        return crops
    }
}
