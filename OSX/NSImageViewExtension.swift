//
//  NSImageViewExtension.swift
//  TestFoscamCam_osx
//
//  Created by Giovanni Murru on 28/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)
        
        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }
    convenience init(cgImage image: CGImage) {
        self.init(cgImage: image, size: NSZeroSize)
    }
}
