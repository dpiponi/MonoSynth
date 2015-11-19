//
//  Knob.swift
//  Knob
//
//  Created by Dan Piponi on 10/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit
import QuartzCore

func shrink(centre : CGFloat, amount : CGFloat, x : CGFloat) -> CGFloat {
    if x > centre+amount {
        return x-amount
    } else if x < centre-amount {
        return x+amount
    } else {
        return centre
    }
}

@IBDesignable class Knob: UIControl {
    
    var value : CGFloat = 0.0 {
        didSet {
            if value < minValue {
                value = minValue
            }
            if value > maxValue {
                value = maxValue
            }
            redrawLayers()
        }
    }
    
    var knobLayer1 : KnobLayer! = nil
    
    @IBInspectable var id : String = ""
    
    @IBInspectable var logarithmic : Bool = false
    
    @IBInspectable var minAngle : CGFloat = 0.0 /*{
        didSet { redrawLayers() }
    }*/
    @IBInspectable var maxAngle : CGFloat = 360.0 {
        didSet { redrawLayers() }
    }
    @IBInspectable var minValue : CGFloat = 0.0 {
        didSet { redrawLayers() }
    }
    @IBInspectable var maxValue : CGFloat = 1.0 {
        didSet { redrawLayers() }
    }
    
    @IBInspectable var detent : CGFloat = 0.0
    
    var knobWidth : CGFloat = 200.0
    
    var initialTouchPoint : CGPoint = CGPoint()
    var initialValue : CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        knobLayer1 = KnobLayer()
        knobLayer1.slider = self
        self.layer.addSublayer(knobLayer1)
        
        self.setLayerFrames()
    }
    
    func setLayerFrames() -> Void {
        knobWidth = bounds.size.height
        
        knobLayer1.frame = CGRectMake(0, 0, knobWidth, knobWidth)
        
        knobLayer1.setNeedsDisplay()
    }

    func angleForValue(value : CGFloat) -> CGFloat {
        if logarithmic {
            return (log(value)-log(minValue))/(log(maxValue)-log(minValue))*(maxAngle-minAngle)+minAngle
        } else {
            return (value-minValue)/(maxValue-minValue)*(maxAngle-minAngle)+minAngle
        }
    }
    
    func valueForAngle(angle : CGFloat) -> CGFloat {
        if logarithmic {
            return exp((angle-minAngle)/(maxAngle-minAngle)*(log(maxValue)-log(minValue))+log(minValue))
        } else {
           return (angle-minAngle)/(maxAngle-minAngle)*(maxValue-minValue)+minValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        knobLayer1 = KnobLayer()
        knobLayer1.slider = self
        self.layer.addSublayer(knobLayer1)
        
        self.setLayerFrames()
    }
    
    override func beginTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        initialTouchPoint = touch.locationInView(self)
        initialValue = value
        
        // hit test the knob layers
        if CGRectContainsPoint(knobLayer1.frame, initialTouchPoint) {
            knobLayer1.highlighted = true
            knobLayer1.setNeedsDisplay()
        }
        return knobLayer1.highlighted
    }
    
    override func continueTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        let touchPoint = touch.locationInView(self)
    
        let delta = touchPoint.x-initialTouchPoint.x
        value = valueForAngle(shrink(angleForValue(detent), amount: 20.0, x: angleForValue(initialValue)+delta))
        
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
        knobLayer1.highlighted = false
        knobLayer1.setNeedsDisplay()
    }
    
    func redrawLayers() -> Void {
        knobLayer1.setNeedsDisplay()
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
