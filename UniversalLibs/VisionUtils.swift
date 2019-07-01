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
#else
import UIKit
#endif
class VisionUtils {
    
    static func objectBounds(from boundingBox: CGRect, imageSize: CGSize) -> CGRect {
        let bbox = VNImageRectForNormalizedRect(boundingBox, Int(imageSize.width), Int(imageSize.height))
        let expandW = bbox.width * 0.0
        let expandH = bbox.height * 0.0
        let yOrigin = imageSize.height - bbox.origin.y - bbox.height - expandH/2.0
        return CGRect(x: bbox.origin.x - expandW/2.0, y: yOrigin, width: bbox.width + expandW, height: bbox.height + expandH)
    }
    
    static func croppedObjects(from imageData: Data, using objectObservations: [VNDetectedObjectObservation], imageSize: CGSize) -> [CGImage]{
        var crops = [CGImage]()
        if let cameraImage = UIImage(data: imageData)?.cgImage {
            for observation in objectObservations {
                let bbox = VisionUtils.objectBounds(from: observation.boundingBox, imageSize: imageSize)
                if let face = cameraImage.cropping(to: bbox) {
                    crops.append(face)
                }
            }
        }
        return crops
    }
}
