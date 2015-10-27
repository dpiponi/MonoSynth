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
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        
//        let path3 = NSBundle.mainBundle().pathForResource("knob3", ofType:"png")
//        
//        let dataProvider3 = CGDataProviderCreateWithFilename(path3!)
//        let image3 = CGImageCreateWithPNGDataProvider(dataProvider3, nil, false, .RenderingIntentDefault)
//        
//        let path2 = NSBundle.mainBundle().pathForResource("knob2", ofType:"png")
//        
//        let dataProvider2 = CGDataProviderCreateWithFilename(path2!)
//        let image2 = CGImageCreateWithPNGDataProvider(dataProvider2, nil, false, .RenderingIntentDefault)
//        
//        let path1 = NSBundle.mainBundle().pathForResource("knob1", ofType:"png")
//        
//        let dataProvider1 = CGDataProviderCreateWithFilename(path1!)
//        let image1 = CGImageCreateWithPNGDataProvider(dataProvider1, nil, false, .RenderingIntentDefault)
        
        let knobFrame = CGRectInset(bounds, 2.0, 2.0)
        
        // 1) fill - with a subtle shadow
        let rect = CGRectInset(knobFrame, 2.0, 2.0)
        
        CGContextSaveGState(ctx);
        
        //
        // http://stackoverflow.com/questions/14404877/anti-aliasing-uiimage-looks-blurred-or-jagged
        //
//        CGContextSetShouldAntialias(ctx, true)
        CGContextSetInterpolationQuality(ctx, .High)
        
//        CGContextDrawImage(ctx, rect, image3)
//        CGContextTranslateCTM(ctx, bounds.width/2, bounds.height/2)
//        CGContextRotateCTM(ctx, slider.angleForValue(slider.value))
//        CGContextTranslateCTM(ctx, -bounds.width/2, -bounds.height/2)
//        CGContextDrawImage(ctx, rect, image2)
//        CGContextRestoreGState(ctx);
        CGContextSetLineWidth(ctx, 2.0)
        
        CGContextSetFillColorWithColor(ctx, UIColor(white: 0.9, alpha: 1.0).CGColor)
        CGContextSetStrokeColorWithColor(ctx, UIColor(white: 0.0, alpha: 1.0).CGColor)
        CGContextFillEllipseInRect(ctx, rect)
        CGContextStrokeEllipseInRect(ctx, rect)
        
        
//        CGContextDrawImage(ctx, rect, image1)
        CGContextSaveGState(ctx)
        let rect2 = CGRectInset(rect, 12.0, 12.0)
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        
        let colors: CFArray = [
            UIColor(white:1.0, alpha: 1.0).CGColor,
            UIColor(white:0.8, alpha: 1.0).CGColor,
            ]
        let gradient : CGGradientRef = CGGradientCreateWithColors(colorSpace, colors, locations)!

//        CGContextSetFillColorWithColor(ctx, UIColor(white: 0.9, alpha: 1.0).CGColor)
        CGContextAddEllipseInRect(ctx, rect2)
        CGContextClip(ctx)
        CGContextDrawRadialGradient(ctx, gradient, CGPoint(x: rect.width/2-8.0, y:rect.height/2-8.0), 0.0, CGPoint(x: rect.width/2-8.0,y: rect.height/2-8.0), rect.width/2, CGGradientDrawingOptions(rawValue: 0))
//        CGContextFillEllipseInRect(ctx, rect2)
        CGContextRestoreGState(ctx)
        
        CGContextSaveGState(ctx);
        let components : [CGFloat] = [0.4, 0.4, 0.4, 1.0]
        let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
        CGContextSetShadowWithColor(ctx, CGSize(width: 1.0,height: 1.0), 4.0, shadowColor)

        CGContextSetStrokeColorWithColor(ctx, UIColor(white: 0.0, alpha: 1.0).CGColor)
        CGContextStrokeEllipseInRect(ctx, rect2)
        CGContextRestoreGState(ctx)
        
        CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, UIColor(white: 0.0, alpha: 1.0).CGColor)
        CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y)
        CGContextTranslateCTM(ctx, rect.width/2.0,  rect.height/2.0)
        CGContextRotateCTM(ctx, slider.angleForValue(slider.value))
        CGContextTranslateCTM(ctx, 0.0, 1.0*rect.width*0.2)
        let rect3 = CGRect(x: -4.0, y:-4.0, width: 8.0, height: 8.0)
        CGContextFillEllipseInRect(ctx, rect3)
        CGContextStrokeEllipseInRect(ctx, rect3)
//        CGContextRestoreGState(ctx);
        
    }
}
    