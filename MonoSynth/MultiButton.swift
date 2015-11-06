//
//  Knob.swift
//  Knob
//
//  Created by Dan Piponi on 10/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable class MultiButton: UIControl {
    
    var selectedButton : Int = 0
    
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
    
    let numElements : Int = 3
    
    var knobLayer1 : MultiButtonLayer! = nil
    
    var minAngle : CGFloat = 0.0 /*{
        didSet { redrawLayers() }
    }*/
    var maxAngle : CGFloat = 2*3.1415926 {
        didSet { redrawLayers() }
    }
    var minValue : CGFloat = 0.0 {
        didSet { redrawLayers() }
    }
    var maxValue : CGFloat = 1.0 {
        didSet { redrawLayers() }
    }
    
    var knobWidth : CGFloat = 200.0
    
    var previousTouchPoint : CGPoint = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        knobLayer1 = MultiButtonLayer()
        knobLayer1.slider = self
        self.layer.addSublayer(knobLayer1)
        
        self.setLayerFrames()
    }
    
    func setLayerFrames() -> Void {
//        knobWidth = bounds.size.height
        
//        knobLayer1.frame = CGRectMake(0, 0, knobWidth, knobWidth)
        knobLayer1.frame = CGRectInset(bounds, -5.0, -5.0)
        
        knobLayer1.setNeedsDisplay()
    }

    func angleForValue(value : CGFloat) -> CGFloat {
        return (value-minValue)/(maxValue-minValue)*(maxAngle-minAngle)+minAngle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        knobLayer1 = MultiButtonLayer()
        knobLayer1.slider = self
        self.layer.addSublayer(knobLayer1)
        
        self.setLayerFrames()
//        print(frame,bounds)
//        bounds = CGRectInset(bounds, -4.0, -4.0)
    }
    
    override func beginTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        previousTouchPoint = touch.locationInView(self)
        print(previousTouchPoint)
        
        selectedButton = Int(previousTouchPoint.x/bounds.width*CGFloat(numElements)) // numElements
        print(selectedButton)
        knobLayer1.setNeedsDisplay()
        
        // hit test the knob layers
        if CGRectContainsPoint(knobLayer1.frame, previousTouchPoint) {
            knobLayer1.highlighted = true
            knobLayer1.setNeedsDisplay()
        }
        
        print("Sending actions")
        sendActionsForControlEvents(.ValueChanged)

        return knobLayer1.highlighted
    }
    
    override func continueTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        let touchPoint = touch.locationInView(self)
        print(touchPoint)
    
        let delta = touchPoint.x-previousTouchPoint.x
        let valueDelta = 0.002*delta*(maxValue-minValue)
        value += valueDelta
        
        selectedButton = Int(touchPoint.x/bounds.width*CGFloat(numElements)) // numElements
        print(selectedButton)
        
        previousTouchPoint = touchPoint
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        setLayerFrames()
        CATransaction.setAnimationDuration(0.0)
        CATransaction.commit()
        
        print("Sending actions")
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
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
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
