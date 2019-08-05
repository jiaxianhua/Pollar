//
//  FPSController.swift
//  Polarr
//
//  Created by developer on 8/5/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit
import QuartzCore

public class FPSCounter: NSObject {
    internal class DisplayLinkProxy: NSObject {
        @objc weak var parentCounter: FPSCounter?
        
        @objc func updateFromDisplayLink(_ displayLink: CADisplayLink) {
            parentCounter?.updateFromDisplayLink(displayLink)
        }
    }
    
    
    // MARK: - Initialization
    
    private let displayLink: CADisplayLink
    private let displayLinkProxy: DisplayLinkProxy
    
    public override init() {
        self.displayLinkProxy = DisplayLinkProxy()
        self.displayLink = CADisplayLink(
            target: self.displayLinkProxy,
            selector: #selector(DisplayLinkProxy.updateFromDisplayLink(_:))
        )
        
        super.init()
        
        self.displayLinkProxy.parentCounter = self
    }
    
    deinit {
        self.displayLink.invalidate()
    }
    
    
    // MARK: - Configuration
    
    /// The delegate that should receive FPS updates.
    public weak var delegate: FPSCounterDelegate?
    
    @objc public var notificationDelay: TimeInterval = 1.0
    
    
    // MARK: - Tracking
    
    private var runloop: RunLoop?
    private var mode: RunLoop.Mode?
    @objc public func startTracking(inRunLoop runloop: RunLoop = .main, mode: RunLoop.Mode = .common) {
        self.stopTracking()
        
        self.runloop = runloop
        self.mode = mode
        self.displayLink.add(to: runloop, forMode: mode)
    }
    
    @objc public func stopTracking() {
        guard let runloop = self.runloop, let mode = self.mode else { return }
        
        self.displayLink.remove(from: runloop, forMode: mode)
        self.runloop = nil
        self.mode = nil
    }
    
    
    // MARK: - Handling Frame Updates
    
    private var lastNotificationTime: CFAbsoluteTime = 0.0
    private var numberOfFrames = 0
    
    private func updateFromDisplayLink(_ displayLink: CADisplayLink) {
        if self.lastNotificationTime == 0.0 {
            self.lastNotificationTime = CFAbsoluteTimeGetCurrent()
            return
        }
        
        self.numberOfFrames += 1
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = currentTime - self.lastNotificationTime
        
        if elapsedTime >= self.notificationDelay {
            self.notifyUpdateForElapsedTime(elapsedTime)
            self.lastNotificationTime = 0.0
            self.numberOfFrames = 0
        }
    }
    
    private func notifyUpdateForElapsedTime(_ elapsedTime: CFAbsoluteTime) {
        let fps = Int(round(Double(self.numberOfFrames) / elapsedTime))
        self.delegate?.fpsCounter(self, didUpdateFramesPerSecond: fps)
    }
}

public protocol FPSCounterDelegate: NSObjectProtocol {
    func fpsCounter(_ counter: FPSCounter, didUpdateFramesPerSecond fps: Int)
}
