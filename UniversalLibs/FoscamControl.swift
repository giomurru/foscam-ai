//
//  FoscamControl.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 26/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation

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

class FoscamControl {
    weak var delegate: MJPEGLibDelegate?
    var IRisOn : Bool = false
    var domain : String = ""
    var stream: MJPEGLib!
    var credentials : String = ""
    
    init(with address: String, user: String, password: String, streamDelegate: MJPEGLibDelegate?) {
        credentials = "user=\(user)&pwd=\(password)"
        domain = "http://" + address
        if let url = URL(string: "\(domain)/videostream.cgi?\(credentials)") {
            stream = MJPEGLib(contentURL: url)
            stream.delegate = streamDelegate
        }
    }
    
    public func startStreaming() {
        stream.play()
    }
    
    private func sendCamera(_ command: String) {
        stream?.sendCommand("\(domain)/\(command)&\(credentials)") { (stringResult, _, _) in
            if let result = stringResult {
                print("result:\n\(result)")
            }
        }
    }
    
    private func setCameraParameters(value: String, for param: String) {
        sendCamera("camera_control.cgi?param='\(param)&value=\(value)")
    }
    
    private func getCameraParameters() {
        sendCamera("get_camera_params.cgi?")
    }
    
    private func controlCommand(for code: CameraCommands) -> String {
        return "decoder_control.cgi?command=\(code.rawValue)"
    }
    
    public func getMJPEGStream() -> MJPEGLib {
        return stream;
    }
    
    public func toggleIR() {
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
    
    public func moveRight() {
        sendCamera(controlCommand(for: CameraCommands.PAN_RIGHT))
    }
    
    public func moveLeft() {
        sendCamera(controlCommand(for: CameraCommands.PAN_LEFT))
    }
    
    public func moveDown() {
        sendCamera(controlCommand(for: CameraCommands.TILT_DOWN))
    }
    
    public func moveUp() {
        sendCamera(controlCommand(for: CameraCommands.TILT_UP))
    }
    
    public func stop() {
        sendCamera(controlCommand(for: CameraCommands.PTZ_STOP))
    }
}
