//
//  Scope.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/7/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class Scope: UIView {
    
    var scopeLayer : ScopeLayer! = nil
    
    var controller : ViewController! = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scopeLayer = ScopeLayer()
        scopeLayer.scope = self
        self.layer.addSublayer(scopeLayer)
        
        self.setLayerFrames()
        
        startTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        scopeLayer = ScopeLayer()
        scopeLayer.scope = self
        self.layer.addSublayer(scopeLayer)
        
        self.setLayerFrames()
        
        startTimer()
    }
    
    func startTimer() {
        NSTimer.scheduledTimerWithTimeInterval(
            0.1, target: self, selector: "update", userInfo: nil, repeats: true)
        
    }
    
    func update() {
        //        print("Update")
        scopeLayer.data = controller.state.osc_data
        scopeLayer.setNeedsDisplay()
    }
    
    func setLayerFrames() -> Void {
        scopeLayer.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height) // = bounds?
        scopeLayer.setNeedsDisplay()
    }
    
    
    #if TARGET_INTERFACE_BUILDER
    override func drawRect(rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    let myFrame = self.bounds
    CGContextSetLineWidth(context, 10)
    let myFrame2 = CGRectInset(myFrame, 5.0, 5.0)
    CGContextStrokeRect(context, myFrame2)
    }
    #endif
    
}