//
//  KnobLayer.swift
//  Knob
//
//  Created by Dan Piponi on 10/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit
import QuartzCore

class KnobLayer: CALayer {
    var highlighted : Bool = false
    weak var slider : Knob! = nil
    
    
    func drawInnerKnob(context: CGContext, rect: CGRect, rect2: CGRect) {
        let components : [CGFloat] = [0.4, 0.4, 0.4, 1.0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 0.2, 1.0 ]
        let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!

        savingContext(context) {
            
            let colors: CFArray = [
                UIColor(white:1.0, alpha: 1.0).CGColor,
                UIColor(white:0.9, alpha: 1.0).CGColor,
                UIColor(white:0.85, alpha: 1.0).CGColor,
            ]
            let gradient : CGGradientRef = CGGradientCreateWithColors(colorSpace, colors, locations)!
            
            CGContextAddEllipseInRect(context, rect2)
            CGContextClip(context)
            CGContextDrawRadialGradient(context, gradient, CGPoint(x: rect.width/2-8.0, y:rect.height/2-8.0), 0.0, CGPoint(x: rect.width/2-8.0,y: rect.height/2-8.0), rect.width/2, CGGradientDrawingOptions(rawValue: 0))
        }
        
        savingContext(context) {
            CGContextSetShadowWithColor(context, CGSize(width: 1.0,height: 1.0), 4.0, shadowColor)
            
            CGContextSetStrokeColorWithColor(context, UIColor(white: 0.0, alpha: 1.0).CGColor)
            CGContextStrokeEllipseInRect(context, rect2)
        }
    }
    
    func drawMarker(context : CGContext, rect: CGRect) {
        CGContextSetFillColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor(white: 0.0, alpha: 1.0).CGColor)
        CGContextTranslateCTM(context, rect.origin.x, rect.origin.y)
        CGContextTranslateCTM(context, rect.width/2.0,  rect.height/2.0)
        CGContextRotateCTM(context, self.slider.angleForValue(self.slider.value))
        CGContextTranslateCTM(context, 0.0, 1.0*rect.width*0.2)
        let rect3 = CGRect(x: -4.0, y:-4.0, width: 8.0, height: 8.0)
        CGContextFillEllipseInRect(context, rect3)
        CGContextStrokeEllipseInRect(context, rect3)
    }
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        
        let knobFrame = CGRectInset(bounds, 2.0, 2.0)
        
        let rect = CGRectInset(knobFrame, 2.0, 2.0)
        let components : [CGFloat] = [0.4, 0.4, 0.4, 1.0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
        
        savingContext(ctx) {
            //
            // http://stackoverflow.com/questions/14404877/anti-aliasing-uiimage-looks-blurred-or-jagged
            //
            CGContextSetInterpolationQuality(ctx, .High)
            CGContextSetLineWidth(ctx, 2.0)
            
            savingContext(ctx) {
                CGContextSaveGState(ctx);
                
                CGContextSetFillColorWithColor(ctx, UIColor(white: 0.9, alpha: 1.0).CGColor)
                CGContextSetStrokeColorWithColor(ctx, UIColor(white: 0.0, alpha: 1.0).CGColor)
                CGContextSetShadowWithColor(ctx, CGSize(width: 2.0,height: 2.0), 4.0, shadowColor)
                CGContextFillEllipseInRect(ctx, rect)
                CGContextStrokeEllipseInRect(ctx, rect)
            }
            
            let rect2 = CGRectInset(rect, 12.0, 12.0)
            self.drawInnerKnob(ctx, rect: rect, rect2: rect2)
            self.drawMarker(ctx, rect: rect)
            
        }
        
    }
}
    