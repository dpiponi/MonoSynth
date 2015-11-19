//
//  WaveFormDesigner.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class WaveFormDesigner: UIControl {

    var n : Int
    var x : [Double] = [0.0, 0.25, 0.5, 0.75]
    var y : [Double] = [0.0, 0.0, 0.25, 0.75]
    
    var waveFormLayer : WaveFormDesignerLayer! = nil
    
    var initialTouchPoint : CGPoint = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        waveFormLayer = WaveFormDesignerLayer()
        waveFormLayer.waveFormDesigner = self
        self.layer.addSublayer(waveFormLayer)
        
        self.setLayerFrames()
    }
    
    func setLayerFrames() -> Void {
        waveFormLayer.frame = CGRectInset(bounds, 5.0, 5.0)
        
        waveFormLayer.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        waveFormLayer = WaveFormDesignerLayer()
        waveFormLayer.waveFormDesigner = self
        self.layer.addSublayer(waveFormLayer)
        
        self.setLayerFrames()
    }
    
//    override func beginTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
//        initialTouchPoint = touch.locationInView(self)
//        initialValue = value
//        
//        // hit test the knob layers
//        if CGRectContainsPoint(knobLayer1.frame, initialTouchPoint) {
//            knobLayer1.highlighted = true
//            knobLayer1.setNeedsDisplay()
//        }
//        return knobLayer1.highlighted
//    }
//    
//    override func continueTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
//        let touchPoint = touch.locationInView(self)
//        
//        let delta = touchPoint.x-initialTouchPoint.x
//        value = valueForAngle(shrink(angleForValue(detent), amount: 20.0, x: angleForValue(initialValue)+delta))
//        
//        //        previousTouchPoint = touchPoint
//        
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        
//        setLayerFrames()
//        CATransaction.setAnimationDuration(0.0)
//        CATransaction.commit()
//        
//        sendActionsForControlEvents(.ValueChanged)
//        
//        return true
//    }
//    
//    override func endTrackingWithTouch(touch : UITouch?, withEvent event: UIEvent?) -> Void {
//        knobLayer1.highlighted = false
//        knobLayer1.setNeedsDisplay()
//    }
    
    func redrawLayers() -> Void {
        waveFormLayer.setNeedsDisplay()
    }
    
    //
    // http://stackoverflow.com/questions/30745026/checking-if-code-is-running-in-interface-builder-in-swift
    //
    #if TARGET_INTERFACE_BUILDER
    override func drawRect(rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    let myFrame = self.bounds
    CGContextSetLineWidth(context, 10)
    let myFrame2 = CGRectInset(myFrame, 5.0, 5.0)
    CGContextStrokeEllipseInRect(context, myFrame2)
    }
    #endif

}
