//
//  ViewController.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 25/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//
import UIKit

class ViewController: FaceTrackerViewController, MJPEGLibDelegate, FaceTrackerViewControllerDataSource {
    
    
    
    // FLAG TO CHANGE PTZ
    //var ptz_type = 0;
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var cameraController : FoscamControl!;
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = self
        if let previewRootLayer = self.imageView?.layer {
            self.rootLayer = previewRootLayer
        }
        loadingIndicator.startAnimating()
        cameraController = FoscamControl(with: "192.168.1.112", user: "admin", password: "45gnAX.%2F114", streamDelegate: self)
        self.captureDeviceResolution = CGSize(width: 640, height: 480)
        self.prepareVisionRequest()
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
        drawFace(from: imageData)
    }
    
    // FaceTrackerViewControllerDataSource
    func visionContentSize() -> CGSize {
        return imageView?.contentClippingRect.size ?? CGSize()
    }
    
    func overlayLayerOrientation() -> CGImagePropertyOrientation {
        return CGImagePropertyOrientation.upMirrored
    }
    
    func overlayLayerScaleMultipliers() -> CGPoint {
        return CGPoint(x: -1.0, y: -1.0)
    }
}




