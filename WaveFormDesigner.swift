//
//  WaveFormDesigner.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class WaveFormDesigner: UIControl {

    var x : [Double] = [0.0, 0.25, 0.5, 0.75, 1.0]
    var y : [Double] = [0.0, 0.0, 0.25, 0.75, 0.0]
    
    var waveFormLayer : WaveFormDesignerLayer! = nil
    
    var initialTouchPoint : CGPoint = CGPoint()
    var selectedPoint : Int = -1
    var initialX : Double = 0.0
    var initialY : Double = 0.0
    
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
    
    func close(x: CGFloat, y: CGFloat) -> Bool {
        return x > y-10 && x < y+10
    }
    
    func close(a: CGPoint, b: CGPoint) -> Bool {
        return close(a.x, y: b.x) && close(a.y, y: b.y)
    }
    
    override func beginTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        initialTouchPoint = touch.locationInView(self)
        print("initial=", initialTouchPoint)
        selectedPoint = -1
        for i in 0..<x.count {
            if close(
                initialTouchPoint,
                b: CGPoint(
                    x: bounds.width*CGFloat(x[i]),
                    y: bounds.height*CGFloat(0.5-0.5*y[i]))) {
                selectedPoint = i
                initialX = x[i]
                initialY = y[i]
                print("Selected", i)
                break;
            }
        }
        
        return selectedPoint >= 0
    }

    func clamp(x: Double, a: Double, b: Double) -> Double {
        if x < a {
            return a
        }
        if x > b {
            return b
        }
        return x
    }
    
    override func continueTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        let touchPoint = touch.locationInView(self)
        
        let deltaX = touchPoint.x-initialTouchPoint.x
        let deltaY = touchPoint.y-initialTouchPoint.y
        
        var newX = clamp(initialX+Double(deltaX/bounds.width), a: 0.0, b: 1.0)
        if selectedPoint > 0 {
            newX = clamp(newX, a: x[selectedPoint-1], b: 1.0)
        }
        if selectedPoint < x.count-1 {
            newX = clamp(newX, a: 0.0, b: x[selectedPoint+1])
        }
        x[0] = 0.0
        x[x.count-1] = 1.0
        x[selectedPoint] = newX
        y[selectedPoint] = clamp(initialY-2.0*Double(deltaY/bounds.height), a: -1.0, b: 1.0)
        if selectedPoint==0 {
            y[x.count-1] = y[0]
        }
        if selectedPoint==x.count-1 {
            y[0] = y[x.count-1]
        }
        
        //        previousTouchPoint = touchPoint
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        setLayerFrames()
        CATransaction.setAnimationDuration(0.0)
        CATransaction.commit()
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }

    override func endTrackingWithTouch(touch : UITouch?, withEvent event: UIEvent?) -> Void {
        waveFormLayer.setNeedsDisplay()
        selectedPoint = -1
    }
    
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
