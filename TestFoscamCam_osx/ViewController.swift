//
//  ViewController.swift
//  TestFoscamCam_osx
//
//  Created by Giovanni Murru on 26/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, MJPEGLibDelegate {

    @IBOutlet weak var imageView: NSImageView!
    var stream: MJPEGLib!
    var url: URL?
    var IRisOn : Bool = false
    let credentials : String = "user=admin&pwd=45gnAX.%2F114"
    let domain : String = "http://192.168.1.112"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Set the ImageView to the stream object
        if let url = URL(string: "http://192.168.1.112/videostream.cgi?\(credentials)&resolution=640x480") {
            stream = MJPEGLib(contentURL: url)
            stream.delegate = self
            stream.play()
        }
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
    }
//
//    override var representedObject: Any? {
//        didSet {
//        // Update the view, if already loaded.
//        }
//    }
}

