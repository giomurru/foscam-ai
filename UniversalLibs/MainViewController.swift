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
import AVFoundation

class MainViewController: UIViewController {

    static let kCat = "cat"
    static let kBird = "bird"
    static let kPerson = "person"
    private let cameraSize = CGSize(width: 640.0, height: 480.0)
    let synthesizer = AVSpeechSynthesizer()
    @IBOutlet weak var imageView: UIImageView!
    var overlayView: OverlayView!
    var cameraController : CameraControl!
    var genderClassifier : GenderClassifier!
    var ageClassifier : AgeClassifier!
    var emotionClassifier : EmotionClassifier!
    var faceDetector : FaceDetector!
    var faceDetectorDrawer : ObjectDetectorDrawer!
    var objectDetectorDrawer : ObjectDetectorDrawer!
    var detectedFaces : [VNFaceObservation]?
    var detectedObjects : [VNRecognizedObjectObservation]?
    var objectDetector : ObjectDetector!
    
    var soundEffectPlayer: AVAudioPlayer?
    var isPlayingSound : Bool = false
    
    var labelsOfInterest : [String] = []
    
    var smoothConfidences : [String: VNConfidence] = [kCat: 0.0, kBird: 0.0, kPerson: 0.0]
    var smoothf : Float = 0.5
    
    
    
    @IBAction func toggleIR(_ sender: UIButton) {
        cameraController.toggleIR()
        sender.isSelected = (cameraController as! FoscamControl).IRisOn
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
    
    @IBAction func enableBirdDetection(_ sender: Any) {
        if labelsOfInterest.contains(Self.kBird) {
            labelsOfInterest.remove(at: labelsOfInterest.firstIndex(of: Self.kBird)!)
            if let button = sender as? UIButton {
                button.isSelected = false
            }
        } else {
            labelsOfInterest.append(Self.kBird)
            if let button = sender as? UIButton {
                button.isSelected = true
            }
        }
        print("\(labelsOfInterest)")
    }
    
    @IBAction func enableCatDetection(_ sender: Any) {
        if labelsOfInterest.contains(Self.kCat) {
            labelsOfInterest.remove(at: labelsOfInterest.firstIndex(of: Self.kCat)!)
            if let button = sender as? UIButton {
                button.isSelected = false
            }
        } else {
            labelsOfInterest.append(Self.kCat)
            if let button = sender as? UIButton {
                button.isSelected = true
            }
        }
        print("\(labelsOfInterest)")
    }
    
    @IBAction func enablePersonDetection(_ sender: Any) {
        if labelsOfInterest.contains(Self.kPerson) {
            labelsOfInterest.remove(at: labelsOfInterest.firstIndex(of: Self.kPerson)!)
            if let button = sender as? UIButton {
                button.isSelected = false
            }
        } else {
            labelsOfInterest.append(Self.kPerson)
            if let button = sender as? UIButton {
                button.isSelected = true
            }
        }
        print("\(labelsOfInterest)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
#if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = true
#endif
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
        //cameraController?.startStreaming()
        print("view did load")
    }
    
    public func startStreaming() {
        guard let cc = cameraController, !cc.isStreaming else { return }
        print("start streaming")
        cc.startStreaming()
    }
    
    public func stopStreaming() {
        guard let cc = cameraController, cc.isStreaming else { return }
        print("stop streaming")
        cc.stopStreaming()
    }
    
    func createSpeech(speech: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: speech)
        // Configure the utterance.
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8

        let voice = AVSpeechSynthesisVoice(language: "it-IT")

        // Assign the voice to the utterance.
        utterance.voice = voice
        
        return utterance
    }
    
    func initGenderClassifier() {
        if let classifier = try? GenderClassifier(changeCategoryFilteringFactor: 0.1, confidenceOfPredictionThreshold: 0.9, imageSize: cameraSize, imageOrientation: .up) {
            classifier.delegate = self
            self.genderClassifier = classifier
            self.genderClassifier.prepareRequest()
        } else {
            print("Error on GenderClassifier init")
        }
    }
    
    func initAgeClassifier() {
        if let classifier = try? AgeClassifier(changeCategoryFilteringFactor: 0.1, confidenceOfPredictionThreshold: 0.9, imageSize: cameraSize, imageOrientation: .up) {
            classifier.delegate = self
            self.ageClassifier = classifier
            self.ageClassifier.prepareRequest()
        } else {
            print("Error on AgeClassifier init")
        }
    }
    
    func initEmotionClassifier() {
        if let classifier = try? EmotionClassifier(changeCategoryFilteringFactor: 0.1, confidenceOfPredictionThreshold: 0.9, imageSize: cameraSize, imageOrientation: .up) {
            classifier.delegate = self
            self.emotionClassifier = classifier
            self.emotionClassifier.prepareRequest()
        } else {
            print("Error on EmotionClassifier init")
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
    
    func initObjectDetector() {
        guard let contentRect = self.imageView?.contentClippingRect, let overlayView = self.overlayView else {
            return
        }
        self.objectDetector = ObjectDetector(confidenceOfPredictionThreshold: 0.97, imageSize: cameraSize, imageOrientation: .up)
        overlayView.frame = contentRect
        self.objectDetectorDrawer = ObjectDetectorDrawer(displaySize: contentRect.size, captureSize: cameraSize)
        self.objectDetector.delegate = self
        self.objectDetectorDrawer.rootLayer = overlayView.layer
        self.objectDetector.prepareRequest()
        self.objectDetectorDrawer.setupVisionDrawingLayers()
    }
    
    func stopAlarm() {
        guard isPlayingSound else { return }
        isPlayingSound = false
        soundEffectPlayer?.stop()
    }
    func startAlarm() {
        guard !isPlayingSound else { return }
        isPlayingSound = true
        let path = Bundle.main.path(forResource: "alarmsound.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            if soundEffectPlayer == nil {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
                soundEffectPlayer?.numberOfLoops = -1
            }
            soundEffectPlayer?.play()
        } catch {
            // couldn't load file :(
            print("ERROR: could not play the sound")
            isPlayingSound = false
        }
    }
}

extension MainViewController : ClassifierDelegate {
    // ClassifierDelegate
    func predictionDidChange(_ prediction: VNClassificationObservation, sender: Classifier) {
        print("\(sender.name) prediction: \(prediction.identifier) (\(String(format: "%.0f", prediction.confidence*100))%)")
    }
}

extension MainViewController : FaceDetectorDelegate {
    // FaceDetectorDelegate
    func predictionDidChange(_ prediction: [VNFaceObservation], sender: FaceDetector) {
        self.detectedFaces = prediction
        DispatchQueue.main.async {
            self.faceDetectorDrawer.draw(prediction)
        }
    }
}

extension MainViewController : ObjectDetectorDelegate {
    func predictionDidChange(_ prediction: [VNRecognizedObjectObservation], sender: ObjectDetector) {
        self.detectedObjects = prediction
        DispatchQueue.main.async {
            let prevCatConfidence = self.smoothConfidences[Self.kCat]!
            let prevPersonConfidence = self.smoothConfidences[Self.kPerson]!
            let prevBirdConfidence = self.smoothConfidences[Self.kBird]!
            var birdConfidence : VNConfidence = 0
            var catConfidence : VNConfidence = 0
            var personConfidence : VNConfidence = 0
            let filteredPredictions = prediction.count > 0 ? prediction.filter { self.labelsOfInterest.contains($0.labels[0].identifier) } : []

            if filteredPredictions.count > 0 {
                for observation in filteredPredictions {
                    // Select only the label with the highest confidence.
                    // let topLabelObservation = observation.labels[0]
                    // let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
                    // let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
                    let topLabel = observation.labels[0]
                    if topLabel.identifier == Self.kCat {
                        catConfidence = observation.labels.filter({ $0.identifier == Self.kCat}).first!.confidence
                    } else if topLabel.identifier == Self.kBird {
                        birdConfidence = observation.labels.filter({ $0.identifier == Self.kBird}).first!.confidence
                    } else if topLabel.identifier == Self.kPerson {
                        personConfidence  = observation.labels.filter({ $0.identifier == Self.kPerson}).first!.confidence
                    }
                }
            }
            
            catConfidence = catConfidence * (1 - self.smoothf) + self.smoothf * prevCatConfidence
            birdConfidence = birdConfidence * (1 - self.smoothf) + self.smoothf * prevBirdConfidence
            personConfidence = personConfidence * (1 - self.smoothf) + self.smoothf * prevPersonConfidence
            self.smoothConfidences = [Self.kCat: catConfidence, Self.kPerson: personConfidence, Self.kBird: birdConfidence]
            
            if catConfidence > 0.25 || personConfidence > 0.25 || birdConfidence > 0.25 {
                self.startAlarm()
                if filteredPredictions.count > 0 {
                    self.objectDetectorDrawer.draw(filteredPredictions)
                }
            } else {
                self.objectDetectorDrawer.clear()
                self.stopAlarm()
            }
            
            
        }
    }
}

extension MainViewController : MJPEGLibDelegate {
    func didStartPlaying() {
        print("did start playing")
    }
    
    func session(_ session: URLSession, didUpdate imageData: Data) {
        DispatchQueue.main.async {
            if let image = UIImage(data: imageData) {
                self.imageView.image = image
            }
        }
        /* DISABLE THE FACE DETECTOR
        if let faceDetector = self.faceDetector {
            faceDetector.runRequest(on: imageData)
        } else {
            DispatchQueue.main.async {
                self.initFaceDetector()
            }
        }
        */
        if let objectDetector = self.objectDetector {
            objectDetector.runRequest(on: imageData)
        } else {
            DispatchQueue.main.async {
                self.initObjectDetector()
            }
        }
        
        /* DISABLE THE EMOTION AGE AND GENDER CLASSIFICATION
        if let detectedFaces = self.detectedFaces {
            let filteredFaces : [VNFaceObservation] = detectedFaces.compactMap { face in
                if face.roll?.floatValue == 0.0 && face.yaw?.floatValue == 0.0 {
                    return face
                } else {
                    return nil
                }
            }
            
            if let genderClassifier = self.genderClassifier {
                genderClassifier.runRequest(on: imageData, for: filteredFaces)
            } else {
                DispatchQueue.main.async {
                    self.initGenderClassifier()
                }
            }
            
            if let ageClassifier = self.ageClassifier {
                ageClassifier.runRequest(on: imageData, for: filteredFaces)
            } else {
                DispatchQueue.main.async {
                    self.initAgeClassifier()
                }
            }
            
            if let emotionClassifier = self.emotionClassifier {
                emotionClassifier.runRequest(on: imageData, for: filteredFaces)
            } else {
                DispatchQueue.main.async {
                    self.initEmotionClassifier()
                }
            }
        }
         */
    }
}
