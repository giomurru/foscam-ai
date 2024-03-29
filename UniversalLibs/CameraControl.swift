//
//  CameraControl.swift
//  Foscam-AI
//
//  Created by Giovanni Murru on 02/07/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

import Foundation

protocol CameraControl {
    var isStreaming : Bool { get set }
    func startStreaming()
    func stopStreaming()
    func toggleIR()
    func moveRight()
    func moveRightUp()
    func moveRightDown()
    func moveLeft()
    func moveLeftUp()
    func moveLeftDown()
    func moveDown()
    func moveUp()
    func stop()
}
