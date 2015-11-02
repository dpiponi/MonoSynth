//
//  ADSRPlot.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/1/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class ADSRPlot: UIView {

    var delay : CGFloat = 0.1
    var attack : CGFloat = 0.1
    var hold : CGFloat = 0.0
    var decay : CGFloat = 0.1
    var sustain : CGFloat = 0.5
    var release_ : CGFloat = 0.5
    var retrigger : CGFloat = 10.0

    override func drawRect(rect: CGRect) -> Void {
        print("HI!!!!!!!!!!!!!!!!!!")
        
        let attackTime = -attack*log(1-1/1.3)
        let decayTime :CGFloat = 0.25
        let releaseTime = release_
        let totalTime = attackTime+decayTime+releaseTime
        
        let context = UIGraphicsGetCurrentContext()
        
        let redColor = UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0)
        
        //
        // http://stackoverflow.com/a/13339008/207442
        //
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 0.5*rect.width, 0.5*rect.height)
        CGContextScaleCTM(context, rect.width, -rect.height)
        CGContextTranslateCTM(context, -0.5, -0.5)
        CGContextSetLineWidth(context, 0.05)

        CGContextSetStrokeColorWithColor(context, redColor.CGColor)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, 0.0, 0.0)
        
        //
        // Plot attack phase
        //
        if attack == 0 {
            CGContextMoveToPoint(context, 0.0, 1.0)
        } else {
            for i in 0..<10 {
                let t = CGFloat(0.1)*CGFloat(i+1)*attackTime
                CGContextAddLineToPoint(context, t, 1.3*(1.0-CGFloat(exp(-t/attack))))
            }
        }
        
        //
        // Plot decay phase.
        // Decay time length is chosen.
        //
        if decay == 0 {
            CGContextAddLineToPoint(context, attackTime, sustain)
        } else {
            for i in 0..<10 {
                let t = CGFloat(0.1)*CGFloat(i+1)*decayTime
                CGContextAddLineToPoint(context, attackTime+t, sustain+CGFloat(exp(-t/decay))*(1.0-sustain))
            }
        }
        let sustainLevel = sustain+CGFloat(exp(-decayTime/decay))*(1.0-sustain)
        
        //
        // Plot release phase.
        //
        if release_ == 0 {
            CGContextAddLineToPoint(context, attackTime+decayTime, 0.0)
        } else {
            for i in 0..<10 {
                let t = CGFloat(0.1)*CGFloat(i+1)*releaseTime
                CGContextAddLineToPoint(context, attackTime+decayTime+t, CGFloat(exp(-t/release_))*sustainLevel)
            }
        }
        
        CGContextRestoreGState(context)
        
        CGContextStrokePath(context)
    }
}
