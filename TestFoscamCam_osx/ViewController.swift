//
//  ViewController.swift
//  TestFoscamCam_osx
//
//  Created by Giovanni Murru on 26/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoreML
import Vision


class ViewController: UIViewController, MJPEGLibDelegate, FaceDetectorDataSource, ClassifierDelegate {

    private let cameraSize = CGSize(width: 640.0, height: 480.0)
    
    @IBOutlet weak var imageView: UIImageView!
    #if os(OSX)
    var overlayView: OverlayView!
    #endif
    var cameraController : FoscamControl!
    var genderClassifier : GenderClassifier!
    var faceDetector : FaceDetector!
    
    @IBAction func toggleIR(_ sender: UIButton) {
        cameraController.toggleIR()
    }
    
    @IBAction func moveCameraRight(_ sender: UIButton) {
        print("move camera right")
        cameraController.moveRight()
    }
    
    @IBAction func moveCameraLeft(_ sender: UIButton) {
        print("move camera left")
        cameraController.moveLeft()
        
    }
    @IBAction func moveCameraDown(_ sender: UIButton) {
        print("move camera down")
        cameraController.moveDown()
    }
    
    @IBAction func moveCameraUp(_ sender: UIButton) {
        print("move camera up")
        cameraController.moveUp()
    }
    
    @IBAction func moveCameraRightUp(_ sender: UIButton) {
        print("move camera right up")
        cameraController.moveRightUp()
    }
    
    @IBAction func moveCameraRightDown(_ sender: UIButton) {
        print("move camera right down")
        cameraController.moveRightDown()
    }
    
    @IBAction func moveCameraLeftUp(_ sender: UIButton) {
        print("move camera left up")
        cameraController.moveLeftUp()
    }
    
    @IBAction func moveCameraLeftDown(_sender: UIButton) {
        print("move camera left down")
        cameraController.moveLeftDown()
    }
    
    @IBAction func stopCamera(_ sender: UIButton) {
        print("stop camera")
        cameraController.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if os(OSX)
        self.overlayView = OverlayView(frame: self.imageView.bounds)
        self.overlayView.wantsLayer = true
        self.imageView.addSubview(self.overlayView)
        #endif
        
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
        cameraController.startStreaming()
    }
    
    func didStartPlaying() {
        print("did start playing")
    }
    
    func session(_ session: URLSession, didUpdate imageData: Data) {
        DispatchQueue.main.async {
            if let image = UIImage(data: imageData) {
                self.imageView.image = image
            }
        }
        
        if let faceDetector = self.faceDetector {
            faceDetector.runRequest(on: imageData)
        } else {
            DispatchQueue.main.async {
                self.initFaceDetector()
            }
        }
        
        
        if let genderClassifier = self.genderClassifier {
            genderClassifier.runRequest(on: imageData, for: faceDetector.detectedFaces)
        } else {
            DispatchQueue.main.async {
                #if os(OSX)
                if let imageRect = self.imageView?.contentClippingRect {
                    self.overlayView.frame = imageRect
                }
                #endif
                self.initGenderClassifier()
            }
        }
    }
    
    func initGenderClassifier() {
        if let classifier = try? GenderClassifier(changeCategoryFilteringFactor: 0.7, confidenceOfPredictionThreshold: 0.97, imageSize: cameraSize, imageOrientation: .up) {
            classifier.delegate = self
            self.genderClassifier = classifier
            self.genderClassifier.prepareRequest()
        } else {
            print("Error on GenderClassifier init")
        }
    }
    
    func initFaceDetector() {
        self.faceDetector = FaceDetector(confidenceOfPredictionThreshold: 0.97, imageSize: cameraSize, imageOrientation: .up)
        self.faceDetector.datasource = self
        #if os(OSX)
        if let previewRootLayer = self.overlayView?.layer {
            self.faceDetector.rootLayer = previewRootLayer
        }
        #elseif os(iOS)
        if let previewRootLayer = self.imageView?.layer {
            self.faceDetector.rootLayer = previewRootLayer
        }
        #endif
        self.faceDetector.prepareRequest()
    }
    
    // FaceDetectorDataSource
    var displaySize : CGSize {
        if let contentRect = self.imageView?.contentClippingRect {
            #if os(OSX)
            self.overlayView.frame = contentRect
            #endif
            return contentRect.size
        }
        return CGSize()
    }
    
    func overlayLayerOrientation() -> CGImagePropertyOrientation {
        return CGImagePropertyOrientation.up
    }
    
    func overlayLayerScaleMultipliers() -> CGPoint {
        #if os(OSX)
        return CGPoint(x: 1.0, y: -1.0)
        #elseif os(iOS)
        return CGPoint(x: 1.0, y: 1.0)
        #endif
    }
    
    // GenderClassifierDelegate
    func predictionDidChange(_ prediction: String, sender: Classifier) {
        print("\(sender.name) prediction: \(prediction)")
    }
}
