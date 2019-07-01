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


class MainViewController: UIViewController, MJPEGLibDelegate, ClassifierDelegate, FaceDetectorDelegate {

    private let cameraSize = CGSize(width: 640.0, height: 480.0)
    
    @IBOutlet weak var imageView: UIImageView!
    var overlayView: OverlayView!
    var cameraController : FoscamControl!
    var genderClassifier : GenderClassifier!
    var faceDetector : FaceDetector!
    var faceDetectorDrawer : ObjectDetectorDrawer!
    var detectedFaces : [VNFaceObservation]?
    
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
        
        self.overlayView = OverlayView(frame: self.imageView.bounds)
        self.overlayView.wantsLayer = true
        self.imageView.addSubview(self.overlayView)
        
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
            if let detectedFaces = self.detectedFaces {
                genderClassifier.runRequest(on: imageData, for: detectedFaces)
            }
        } else {
            DispatchQueue.main.async {
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
        guard let contentRect = self.imageView?.contentClippingRect, let overlayView = self.overlayView else {
            return
        }
        self.faceDetector = FaceDetector(confidenceOfPredictionThreshold: 0.97, imageSize: cameraSize, imageOrientation: .up)
        overlayView.frame = contentRect
        self.faceDetectorDrawer = ObjectDetectorDrawer(displaySize: contentRect.size, captureSize: cameraSize)
        self.faceDetector.delegate = self
        self.faceDetectorDrawer.rootLayer = overlayView.layer
        self.faceDetector.prepareRequest()
        self.faceDetectorDrawer.setupVisionDrawingLayers()
    }
    
    // GenderClassifierDelegate
    func predictionDidChange(_ prediction: String, sender: Classifier) {
        print("\(sender.name) prediction: \(prediction)")
    }
    
    // FaceDetectorDelegate
    func predictionDidChange(_ prediction: [VNFaceObservation], sender: FaceDetector) {
        self.detectedFaces = prediction
        DispatchQueue.main.async {
            self.faceDetectorDrawer.draw(prediction)
        }
    }
}
