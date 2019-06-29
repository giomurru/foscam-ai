//
//  ViewController.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 25/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//
import UIKit

class ViewController: UIViewController, MJPEGLibDelegate, FaceDetectorDataSource, GenderClassifierDelegate {
    
    // FLAG TO CHANGE PTZ
    //var ptz_type = 0;
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var cameraController : FoscamControl!;
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
    
    @IBAction func stopCamera(_ sender: UIButton) {
        print("stop camera")
        cameraController.stop()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.faceDetector = FaceDetector()
        self.faceDetector.datasource = self
        self.genderClassifier = GenderClassifier()
        self.genderClassifier.prepareVisionRequest()
        self.genderClassifier.delegate = self
        
        if let previewRootLayer = self.imageView?.layer {
            self.faceDetector.rootLayer = previewRootLayer
        }
        loadingIndicator.startAnimating()
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

    //MARK: MJPEGLibDelegate methods
    func didStartPlaying() {
        print("did start playing")
        loadingIndicator.stopAnimating()
    }
    
    func session(_ session: URLSession, didUpdate imageData: Data) {
        DispatchQueue.main.async {
            if let image = UIImage(data: imageData) {
                self.imageView.image = image
            }
        }
        faceDetector.trackFace(from: imageData)
        genderClassifier.predictGender(from: imageData, detectedFaces: faceDetector.detectedFaces, displaySize: faceDetector.captureDeviceResolution, exifOrientation: overlayLayerOrientation())
    }
    
    // FaceDetectorDataSource
    func visionContentSize() -> CGSize {
        return imageView?.contentClippingRect.size ?? CGSize()
    }
    
    func overlayLayerOrientation() -> CGImagePropertyOrientation {
        return CGImagePropertyOrientation.up
    }
    
    func overlayLayerScaleMultipliers() -> CGPoint {
        return CGPoint(x: 1.0, y: 1.0)
    }
    
    // GenderClassifierDelegate
    func genderDidChange(prediction: String) {
        print("gender: \(prediction)")
    }
}




