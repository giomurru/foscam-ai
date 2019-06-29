//
//  ViewController.swift
//  TestFoscamCam_osx
//
//  Created by Giovanni Murru on 26/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Cocoa
import CoreML
import Vision
class OverlayView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.set()
        dirtyRect.fill()
    }
}

class ViewController: NSViewController, MJPEGLibDelegate, FaceDetectorDataSource, ClassifierDelegate {

    @IBOutlet weak var imageView: NSImageView!
    var overlayView: OverlayView!
    var cameraController : FoscamControl!
    var genderClassifier : GenderClassifier!
    var faceDetector : FaceDetector!
    
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
    
    @IBAction func moveCameraRightUp(_ sender: NSButton) {
        print("move camera right up")
        cameraController.moveRightUp()
    }
    
    @IBAction func moveCameraRightDown(_ sender: NSButton) {
        print("move camera right down")
        cameraController.moveRightDown()
    }
    
    @IBAction func moveCameraLeftUp(_ sender: NSButton) {
        print("move camera left up")
        cameraController.moveLeftUp()
    }
    
    @IBAction func moveCameraLeftDown(_sender: NSButton) {
        print("move camera left down")
        cameraController.moveLeftDown()
    }
    
    @IBAction func stopCamera(_ sender: NSButton) {
        print("stop camera")
        cameraController.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.faceDetector = FaceDetector()
        self.faceDetector.datasource = self
        
        self.overlayView = OverlayView(frame: self.imageView.bounds)
        self.overlayView.wantsLayer = true
        self.imageView.addSubview(self.overlayView)
        
        if let previewRootLayer = self.overlayView?.layer {
            self.faceDetector.rootLayer = previewRootLayer
        }
        // Do any additional setup after loading the view.
        // Set the ImageView to the stream object
//        Note: to use FoscamControl you have to create a struct called LoginConstants with your credentials such as the one in the example below.
//        Example:
//        struct LoginConstants {
//            static let domain = "192.168.1.104"
//            static let user = "admin"
//            static let pwd = "password"
//        }
        cameraController = FoscamControl(with: LoginConstants.domain, user: LoginConstants.user, password: LoginConstants.pwd, streamDelegate: self)
        self.faceDetector.captureDeviceResolution = CGSize(width: 640, height: 480)
        self.faceDetector.prepareVisionRequest()
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
        faceDetector.trackFace(from: imageData)
        
        if let genderClassifier = self.genderClassifier {
            genderClassifier.runPrediction(on: imageData, for: faceDetector.detectedFaces)
        } else {
            DispatchQueue.main.async {
                if let imageRect = self.imageView?.contentClippingRect {
                    self.overlayView.frame = imageRect
                }
            }
            self.initGenderClassifier()
        }
    }
    
    func initGenderClassifier() {
        if let classifier = try? GenderClassifier(changeCategoryFilteringFactor: 0.7, confidenceOfPredictionThreshold: 0.97, imageSize: self.faceDetector.captureDeviceResolution, imageOrientation: .up) {
            self.genderClassifier = classifier
            self.genderClassifier.prepareRequest()
            self.genderClassifier.delegate = self
        }
    }
    
    // FaceDetectorDataSource
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
        return CGPoint(x: 1.0, y: -1.0)
    }
    
    // GenderClassifierDelegate
    func predictionDidChange(_ prediction: String, sender: Classifier) {
        print("\(sender.name) prediction: \(prediction)")
    }
}

