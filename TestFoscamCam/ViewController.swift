//
//  ViewController.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 25/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//
import UIKit
/*
 var R320_240=8;
 var R640_480=32;
 var ptz_type=0;
 var PTZ_STOP=1;
 var TILT_UP=0;
 var TILT_UP_STOP=1;
 var TILT_DOWN=2;
 var TILT_DOWN_STOP=3;
 var PAN_LEFT=6;
 var PAN_LEFT_STOP=5;
 var PAN_RIGHT=4;
 var PAN_RIGHT_STOP=7;
 var PTZ_LEFT_UP=91;
 var PTZ_RIGHT_UP=90;
 var PTZ_LEFT_DOWN=93;
 var PTZ_RIGHT_DOWN=92;
 var PTZ_CENTER=25;
 var PTZ_VPATROL=26;
 var PTZ_VPATROL_STOP=27;
 var PTZ_HPATROL=28;
 var PTZ_HPATROL_STOP=29;
 var PTZ_PELCO_D_HPATROL=20;
 var PTZ_PELCO_D_HPATROL_STOP=21;
 var IO_ON=95;
 var IO_OFF=94;
 */
class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var stream: MJPEGStreamLib!
    var url: URL?
    
    var command: String?
    
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
        }
        
        // Your stream url should be here !
        let url = URL(string: "http://192.168.1.112/videostream.cgi?user=admin&pwd=45gnAX.%2F114&resolution=640x480")
        
        let command_url = URL(string: "http://192.168.1.112/decoder_control.cgi?command=\(command)&user=admin&pwd=45gnAX.%2F114")
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


