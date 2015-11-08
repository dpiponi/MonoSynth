//
//  VUMeterLayer.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/6/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class VUMeterLayer: CALayer {
    
    var meter : VUMeter! = nil
    var peak : Double = 0.0
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        
        let meterFrame = CGRectInset(bounds, 2.0, 2.0)
        
//        print("p=",peak)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colors: CFArray = [
            UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).CGColor,
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
            ]
        
        let locations : [CGFloat] = [0.0, 1.0]
        
        let gradient : CGGradientRef = CGGradientCreateWithColors(colorSpace, colors, locations)!

        
        CGContextTranslateCTM(ctx, meterFrame.size.width/2.0, meterFrame.size.height/2.0)
        CGContextScaleCTM(ctx, 1.0, -1.0)
        CGContextTranslateCTM(ctx, -meterFrame.size.width/2.0, -meterFrame.size.height/2.0)
        let rect = CGRect(origin: meterFrame.origin,
                          size: CGSize(width: meterFrame.width,
                                       height: meterFrame.height*CGFloat(peak/2.0)))
        savingContext(ctx) {
            
            CGContextAddRect(ctx, rect)
            CGContextClip(ctx)

            let startPoint = CGPoint(x: meterFrame.width/2.0, y: 0)
            let endPoint = CGPoint(x: meterFrame.width/2.0, y: meterFrame.height)
            CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        }
        
    }
}
