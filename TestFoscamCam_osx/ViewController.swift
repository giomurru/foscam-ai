//
//  ViewController.swift
//  TestFoscamCam_osx
//
//  Created by Giovanni Murru on 26/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Cocoa

class OverlayView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.set()
        dirtyRect.fill()
    }
}

class ViewController: FaceTrackerViewController, MJPEGLibDelegate, FaceTrackerViewControllerDataSource {

    @IBOutlet weak var imageView: NSImageView!
    var overlayView: OverlayView!
    var cameraController : FoscamControl!;
    
    @IBAction func toggleIR(_ sender: NSButton) {
        cameraController.toggleIR()
    }
    
    @IBAction func moveCameraRight(_ sender: NSButton) {
        print("move camera right")
        cameraController.moveRight()
    }
    
    @IBAction func moveCameraLeft(_ sender: NSButton) {
        print("move camera left")
        cameraController.moveLeft()
        
    }
    @IBAction func moveCameraDown(_ sender: NSButton) {
        print("move camera down")
        cameraController.moveDown()
    }
    
    @IBAction func moveCameraUp(_ sender: NSButton) {
        print("move camera up")
        cameraController.moveUp()
    }
    
    @IBAction func stopCamera(_ sender: NSButton) {
        print("stop camera")
        cameraController.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overlayView = OverlayView(frame: self.imageView.bounds)
        self.overlayView.wantsLayer = true
        self.imageView.addSubview(self.overlayView)
        
        self.datasource = self
        if let previewRootLayer = self.overlayView?.layer {
            self.rootLayer = previewRootLayer
        }
        // Do any additional setup after loading the view.
        // Set the ImageView to the stream object
        cameraController = FoscamControl(with: "192.168.1.112", user: "admin", password: "45gnAX.%2F114", streamDelegate: self)
        self.captureDeviceResolution = CGSize(width: 640, height: 480)
        self.prepareVisionRequest()
        cameraController.startStreaming()
    }
    
    func didStartPlaying() {
        print("did start playing")
    }
    
    func session(_ session: URLSession, didUpdate imageData: Data) {
        DispatchQueue.main.async {
            if let image = NSImage(data: imageData) {
                self.imageView.image = image
            }
        }
        drawFace(from: imageData)
    }
    
    // FaceTrackerViewControllerDataSource
    func visionContentSize() -> CGSize {
        if let contentRect = self.imageView?.contentClippingRect {
            self.overlayView.frame = contentRect
            return contentRect.size
        }
        return CGSize()
    }
    
    func overlayLayerOrientation() -> CGImagePropertyOrientation {
        return CGImagePropertyOrientation.up
    }
    
    func overlayLayerScaleMultipliers() -> CGPoint {
        return CGPoint(x: 1.0, y: 1.0)
    }
    
//
//    override var representedObject: Any? {
//        didSet {
//        // Update the view, if already loaded.
//        }
//    }
}

