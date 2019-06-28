//
//  LowPassFilter.swift
//  TestFoscamCam
//
//  Created by Giovanni Murru on 28/06/2019.
//  Copyright © 2019 Giovanni Murru. All rights reserved.
//

struct LowPassFilter {
    /// Current signal value
    var value: Float
    
    /// A scaling factor in the range 0.0..<1.0 that determines
    /// how resistant the value is to change
    let filterFactor: Float
    
    /// Update the value, using filterFactor to attenuate changes
    mutating func update(newValue: Float) {
        value = filterFactor * value + (1.0 - filterFactor) * newValue
    }
}
