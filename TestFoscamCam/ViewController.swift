//
//  ViewController.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 25/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//
import UIKit

enum CameraCommands : Int {
    case R320_240=8;
    case R640_480=32;
    case TILT_UP=0;
    case PTZ_STOP = 1;
    //case TILT_UP_STOP=1;
    case TILT_DOWN=2;
    //case TILT_DOWN_STOP=3;
    case PAN_LEFT=6;
    //case PAN_LEFT_STOP=5;
    case PAN_RIGHT=4;
    //case PAN_RIGHT_STOP=7;
    case PTZ_LEFT_UP=91;
    case PTZ_RIGHT_UP=90;
    case PTZ_LEFT_DOWN=93;
    case PTZ_RIGHT_DOWN=92;
    case PTZ_CENTER=25;
    case PTZ_VPATROL=26;
    case PTZ_VPATROL_STOP=27;
    case PTZ_HPATROL=28;
    case PTZ_HPATROL_STOP=29;
    case PTZ_PELCO_D_HPATROL=20;
    case PTZ_PELCO_D_HPATROL_STOP=21;
    case IO_ON=95;
    case IO_OFF=94;
}

class ViewController: UIViewController {
    
    // FLAG TO CHANGE PTZ
    //var ptz_type = 0;
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var stream: MJPEGStreamLib!
    var url: URL?
    var IRisOn : Bool = false
    let credentials : String = "user=admin&pwd=45gnAX.%2F114"
    let domain : String = "http://192.168.1.112"
    
    @IBAction func toggleIR(_ sender: UIButton) {
        if IRisOn {
            IRisOn = false
            print("turn off IR")
            sendCamera(controlCommand(for: CameraCommands.IO_OFF))
        } else {
            IRisOn = true
            print("turn on IR")
            sendCamera(controlCommand(for: CameraCommands.IO_ON))
        }
    }
    @IBAction func moveCameraRight(_ sender: UIButton) {
        print("move camera right")
        sendCamera(controlCommand(for: CameraCommands.PAN_LEFT))
    }
    @IBAction func moveCameraLeft(_ sender: UIButton) {
        print("move camera left")
        sendCamera(controlCommand(for: CameraCommands.PAN_RIGHT))
    }
    @IBAction func moveCameraDown(_ sender: UIButton) {
        print("move camera down")
        sendCamera(controlCommand(for: CameraCommands.TILT_DOWN))
    }
    
    @IBAction func moveCameraUp(_ sender: UIButton) {
        print("move camera up")
        sendCamera(controlCommand(for: CameraCommands.TILT_UP))
    }
    
    @IBAction func stopCamera(_ sender: UIButton) {
        print("stop camera")
        sendCamera(controlCommand(for: CameraCommands.PTZ_STOP))
    }
    
    
    private func controlCommand(for code: CameraCommands) -> String {
        return "decoder_control.cgi?command=\(code.rawValue)"
    }
    
    private func setCameraParameters(value: String, for param: String) {
        sendCamera("camera_control.cgi?param='\(param)&value=\(value)")
    }
    
    private func getCameraParameters() {
        sendCamera("get_camera_params.cgi?")
    }
    
    private func sendCamera(_ command: String) {
        stream?.sendCommand("\(domain)/\(command)&\(credentials)") { (stringResult, _, _) in
            if let result = stringResult {
                print("result:\n\(result)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the ImageView to the stream object
        stream = MJPEGStreamLib(imageView: imageView)
        // Start Loading Indicator
        stream.didStartLoading = { [unowned self] in
            self.loadingIndicator.startAnimating()
        }
        // Stop Loading Indicator
        stream.didFinishLoading = { [unowned self] in
            self.loadingIndicator.stopAnimating()
            self.getCameraParameters()
        }
        
        // Your stream url should be here !
        let url = URL(string: "http://192.168.1.112/videostream.cgi?\(credentials)&resolution=640x480")
        
        
        stream.contentURL = url
        stream.play() // Play the stream
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Make the Status Bar Light/Dark Content for this View
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        //return UIStatusBarStyle.default   // Make dark again
    }
}


