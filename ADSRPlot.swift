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
        let holdTime = hold
        let decayTime :CGFloat = 0.25
        let releaseTime = 1.0-attackTime+decayTime//release_
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
        CGContextSetLineWidth(context, 0.1)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let components : [CGFloat] = [0.4, 0.4, 0.4, 1.0]

        let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
        
        CGContextSetShadowWithColor(context, CGSize(width: 2.0,height: 2.0), 4.0, shadowColor)
        
        CGContextSetStrokeColorWithColor(context, UIColor(white: 0.1, alpha: 1.0).CGColor)
        
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
        // Plot hold phase
        //
        if hold > 0 {
            CGContextAddLineToPoint(context, attackTime+holdTime, 1.0)
        }
        
        //
        // Plot decay phase.
        // Decay time length is chosen.
        //
        var sustainLevel : CGFloat = sustain
        if decay == 0 {
            CGContextAddLineToPoint(context, attackTime+holdTime, sustain)
        } else {
            for i in 0..<10 {
                let t = CGFloat(0.1)*CGFloat(i+1)*decayTime
                CGContextAddLineToPoint(context, attackTime+holdTime+t, sustain+CGFloat(exp(-t/decay))*(1.0-sustain))
            }
            sustainLevel = sustain+CGFloat(exp(-decayTime/decay))*(1.0-sustain)
        }
//        let sustainLevel = sustain+CGFloat(exp(-decayTime/decay))*(1.0-sustain)
        
        //
        // Plot release phase.
        //
        if release_ == 0 {
            CGContextAddLineToPoint(context, attackTime+holdTime+decayTime, 0.0)
        } else {
            for i in 0..<10 {
                let t = CGFloat(0.1)*CGFloat(i+1)*releaseTime
                CGContextAddLineToPoint(context, attackTime+holdTime+decayTime+t, CGFloat(exp(-t/release_))*sustainLevel)
            }
        }
        
        CGContextRestoreGState(context)
        
        CGContextStrokePath(context)
    }
}