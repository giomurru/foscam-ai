//
//  OverlayView.swift
//  TestFoscamCam_osx
//
//  Created by Giovanni Murru on 01/07/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Cocoa

class OverlayView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.clear.set()
        dirtyRect.fill()
        // Drawing code here.
    }
}
