//
//  ImageViewExtension.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 27/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation
#if os(OSX)
import Cocoa
#else
import UIKit
#endif
extension UIImageView {
    //WARNING: works only with .scaleAspectFit for iOS
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        //guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
        
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        #if os(OSX)
        let y = (size.height - bounds.height) / 2.0
        #elseif os(iOS)
        let y = (bounds.height - size.height) / 2.0
        #endif
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}

