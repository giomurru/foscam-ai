//
//  iOSXBridge.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 01/07/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

#if os(OSX)
import Cocoa
typealias UIViewController = NSViewController
typealias UIColor = NSColor
typealias UIImage = NSImage
typealias UIImageView = NSImageView
typealias UIButton = NSButton
#elseif os(iOS)
import UIKit
#endif
