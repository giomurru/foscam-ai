//
//  OverlayView.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 01/07/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    
    var wantsLayer : Bool = true //dummy flag used to maintain compatibility with osx API
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
        self.backgroundColor = .clear
    }
}
