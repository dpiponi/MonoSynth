//
//  ADSRPlot.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/1/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

func plotExponential() -> Void {
}

class ADSRPlot: UIView {

    var delay : CGFloat = 0.1
    var attack : CGFloat = 0.1
    var hold : CGFloat = 0.0
    var decay : CGFloat = 0.1
    var sustain : CGFloat = 0.5
    var release_ : CGFloat = 0.5
    var retrigger : CGFloat = 10.0

    //
    // http://stackoverflow.com/questions/1030596/drawing-hermite-curves-in-opengl
    //
    override func drawRect(rect: CGRect) -> Void {
        
        let delayTime = delay
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
        UIGraphicsPushContext(context!)
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
//        CGContextMoveToPoint(context, 0.0, 0.0)
 
        CGContextSetStrokeColorWithColor(context, UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor)

        UIGraphicsPushContext(context!)
        let path = UIBezierPath()
        
        let plotSteps = 10
        let plotDelta = 1.0/CGFloat(plotSteps)
        
        //
        // Plot attack phase
        //
        path.moveToPoint(CGPoint(x: delayTime, y:0.0)) // XXX get rid of all but first
        if attack == 0 {
            let p1 = CGPoint(x: delayTime, y: 1.0)
            let q0 = CGPoint(x: delayTime, y:1.0/3.0)
            let q1 = CGPoint(x: delayTime, y:2.0/3.0)
            path.addCurveToPoint(p1, controlPoint1: q0, controlPoint2: q1)
        } else {
            for i in 0..<plotSteps {
//                let t = CGFloat(0.2)*CGFloat(i+1)*attackTime
//                CGContextAddLineToPoint(context, t, 1.3*(1.0-CGFloat(exp(-t/attack))))
                
                let t0 = CGFloat(plotDelta)*CGFloat(i)*attackTime
                let t1 = CGFloat(plotDelta)*CGFloat(i+1)*attackTime
                let p0 = CGPoint(x: delayTime+t0, y: 1.3*(1.0-CGFloat(exp(-t0/attack))))
                let p1 = CGPoint(x: delayTime+t1, y: 1.3*(1.0-CGFloat(exp(-t1/attack))))
                let g0 = 1.3/attack*exp(-t0/attack)
                let g1 = 1.3/attack*exp(-t1/attack)
                let dx = p1.x-p0.x
                let q0 = CGPoint(x: p0.x+dx/3.0, y:p0.y+g0*dx/3.0)
                let q1 = CGPoint(x: p1.x-dx/3.0, y:p1.y-g1*dx/3.0)
                path.addCurveToPoint(p1, controlPoint1: q0, controlPoint2: q1)
//                print(p0, q0, q1, p1)
            }
        }
        
        //
        // Plot hold phase
        //
        if hold > 0 {
            let p1 = CGPoint(x: delayTime+attackTime+holdTime, y: 1.0)
            let q0 = CGPoint(x: delayTime+attackTime+holdTime/3.0, y:1.0)
            let q1 = CGPoint(x: delayTime+attackTime+holdTime*2.0/3.0, y:1.0)
            path.addCurveToPoint(p1, controlPoint1: q0, controlPoint2: q1)
//            CGContextAddLineToPoint(context, attackTime+holdTime, 1.0)
        }
        
        //
        // Plot decay phase.
        // Decay time length is chosen.
        //
        var sustainLevel : CGFloat = sustain
        if decay == 0 {
            let p1 = CGPoint(x:delayTime+attackTime+holdTime, y:sustain)
            let q0 = CGPoint(x:delayTime+attackTime+holdTime, y:2.0/3.0+sustain/3.0)
            let q1 = CGPoint(x:delayTime+attackTime+holdTime, y:1/3.0+2*sustain/3.0)
            path.addCurveToPoint(p1, controlPoint1: q0, controlPoint2: q1)
            
            let r1 = CGPoint(x:delayTime+attackTime+holdTime+decayTime, y:sustain)
            let s0 = CGPoint(x:delayTime+attackTime+holdTime+decayTime/3.0, y:sustain)
            let s1 = CGPoint(x:delayTime+attackTime+holdTime+2.0*decayTime/3.0, y:sustain)
            path.addCurveToPoint(r1, controlPoint1: s0, controlPoint2: s1)
        } else {
            for i in 0..<plotSteps {
                
                
                let t0 = CGFloat(plotDelta)*CGFloat(i)*decayTime
                let t1 = CGFloat(plotDelta)*CGFloat(i+1)*decayTime
                let p0 = CGPoint(x: delayTime+attackTime+holdTime+t0, y: sustain+CGFloat(exp(-t0/decay))*(1.0-sustain))
                let p1 = CGPoint(x: delayTime+attackTime+holdTime+t1, y: sustain+CGFloat(exp(-t1/decay))*(1.0-sustain))
                let g0 = -(1.0-sustain)/decay*exp(-t0/decay)
                let g1 = -(1.0-sustain)/decay*exp(-t1/decay)
                let dx = p1.x-p0.x
                let q0 = CGPoint(x: p0.x+dx/3.0, y:p0.y+g0*dx/3.0)
                let q1 = CGPoint(x: p1.x-dx/3.0, y:p1.y-g1*dx/3.0)
//                path.moveToPoint(p0) // XXX get rid of
                path.addCurveToPoint(p1, controlPoint1: q0, controlPoint2: q1)
                
                
                
//                let t = CGFloat(0.1)*CGFloat(i+1)*decayTime
//                CGContextAddLineToPoint(context, attackTime+holdTime+t, sustain+CGFloat(exp(-t/decay))*(1.0-sustain))
            }
            sustainLevel = sustain+CGFloat(exp(-decayTime/decay))*(1.0-sustain)
        }
//        let sustainLevel = sustain+CGFloat(exp(-decayTime/decay))*(1.0-sustain)
        
        //
        // Plot release phase.
        //
        if release_ == 0 {
//            CGContextAddLineToPoint(context, attackTime+holdTime+decayTime, 0.0)
            let p1 = CGPoint(x:delayTime+attackTime+holdTime+decayTime, y:0.0)
            let q0 = CGPoint(x:delayTime+attackTime+holdTime+decayTime, y:2.0/3.0*sustainLevel)
            let q1 = CGPoint(x:delayTime+attackTime+holdTime+decayTime, y:1.0/3.0*sustainLevel)
            path.addCurveToPoint(p1, controlPoint1: q0, controlPoint2: q1)
        } else {
            for i in 0..<plotSteps {
//                let t = CGFloat(0.2)*CGFloat(i+1)*releaseTime
//                CGContextAddLineToPoint(context, attackTime+holdTime+decayTime+t, CGFloat(exp(-t/release_))*sustainLevel)
                let t0 = CGFloat(plotDelta)*CGFloat(i)*releaseTime
                let t1 = CGFloat(plotDelta)*CGFloat(i+1)*releaseTime
                let p0 = CGPoint(x: delayTime+attackTime+holdTime+decayTime+t0, y: CGFloat(exp(-t0/release_))*sustainLevel)
                let p1 = CGPoint(x: delayTime+attackTime+holdTime+decayTime+t1, y: CGFloat(exp(-t1/release_))*sustainLevel)
                let g0 = -sustainLevel/release_*exp(-t0/release_)
                let g1 = -sustainLevel/release_*exp(-t1/release_)
                let dx = p1.x-p0.x
                let q0 = CGPoint(x: p0.x+dx/3.0, y:p0.y+g0*dx/3.0)
                let q1 = CGPoint(x: p1.x-dx/3.0, y:p1.y-g1*dx/3.0)
                //                path.moveToPoint(p0) // XXX get rid of
                path.addCurveToPoint(p1, controlPoint1: q0, controlPoint2: q1)
            }
        }
        UIGraphicsPopContext()
//        CGContextSetLineWidth(context, 0.001)
        path.lineWidth = 0.01
        CGContextSetShouldAntialias(context, true);
        path.stroke()
        UIGraphicsPopContext()
        
        CGContextRestoreGState(context)
        
//        CGContextStrokePath(context)
    }
}