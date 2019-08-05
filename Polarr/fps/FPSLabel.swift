//
//  FPSLabel.swift
//  Polarr
//
//  Created by developer on 8/5/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit

class FPSLabel: UILabel {
    fileprivate let fpsCounter = FPSCounter()
    
    let runloop: RunLoop = .main
    let mode: RunLoop.Mode = .common
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.fpsCounter.delegate = self
        fpsCounter.startTracking(
            inRunLoop: runloop,
            mode: mode
        )
    }
    
    deinit {
        fpsCounter.stopTracking()
    }
}


extension FPSLabel: FPSCounterDelegate {
    
    @objc func fpsCounter(_ counter: FPSCounter, didUpdateFramesPerSecond fps: Int) {
        self.text = "\(fps) FPS"
        
        switch fps {
        case 45...:
//            self.backgroundColor = .green
            self.textColor = .black
        case 35...:
//            self.backgroundColor = .orange
            self.textColor = .white
        default:
//            self.backgroundColor = .red
            self.textColor = .white
        }
    }
}
