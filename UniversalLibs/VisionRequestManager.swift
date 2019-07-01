//
//  AIProtocol.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 30/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation
import Vision


protocol VisionRequestManager {
    var confidenceThreshold : Float { get }
    var imageOrientation : CGImagePropertyOrientation { get }
    var imageSize : CGSize { get }
    var name : String { get }
    func prepareRequest()
    func runRequest(on image: CGImage)
    func runRequest(on imageData: Data)
    func runRequest(on imageData: Data, for objectObservations: [VNDetectedObjectObservation])
}

