//
//  KnobLayer.swift
//  Knob
//
//  Created by Dan Piponi on 10/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit
import QuartzCore

class MultiButtonLayer: CALayer {
    var highlighted : Bool = false
    weak var slider : MultiButton! = nil
    
    func drawButton(context: CGContext, rect: CGRect, selected: Bool) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 0.4, 0.5, 1.0 ]
        
        let colors: CFArray = [
            UIColor(white:0.85, alpha: 1.0).CGColor,
            UIColor(white:1.0, alpha: 1.0).CGColor,
            UIColor(white:1.0, alpha: 1.0).CGColor,
            UIColor(white:0.75, alpha: 1.0).CGColor]
        
        let gradient : CGGradientRef = CGGradientCreateWithColors(colorSpace, colors, locations)!
        
        
        savingContext(context) {
        
            let components : [CGFloat] = [0.4, 0.4, 0.4, 1.0]
            let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
            
            // Draw inside
            savingContext(context) {
                CGContextAddRect(context, rect)
                CGContextClip(context)
                let startPoint = CGPoint(x: rect.origin.x, y: rect.origin.y)
                let endPoint = CGPoint(x: rect.origin.x, y: rect.origin.y+rect.height)
                CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
            }
            
            // Draw border
            CGContextAddRect(context, rect)
            CGContextClip(context)
            CGContextSetLineWidth(context, 2.0)
            if selected {
                CGContextSetShadowWithColor(context, CGSize(width: 1.0,height: 1.0), 8.0, shadowColor)
            } else {
                CGContextSetShadowWithColor(context, CGSize(width: 0.0,height: 0.0), 1.0, shadowColor)
                
            }
            let rect2 = CGRectInset(rect, 1.0, 2.0)
            CGContextAddRect(context, rect2)
            CGContextDrawPath(context, .Stroke)
            CGContextStrokePath(context)
        }
    }

    override func drawInContext(context: CGContextRef) -> Void {
        let numElements : Int = 4
        let buttonWidth : CGFloat = bounds.width/CGFloat(numElements)
        let buttonheight : CGFloat = bounds.height
        let x : CGFloat = 0.0
        let y : CGFloat = 0.0
        for i in 0..<numElements {
            let myRect = CGRect(x:x+CGFloat(i)*buttonWidth, y:y, width:buttonWidth, height:buttonheight)
            
            savingContext(context) {
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let components : [CGFloat] = [0.4, 0.4, 0.4, 1.0]
                let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
                CGContextSetShadowWithColor(context, CGSize(width: 1.0,height: 1.0), 6.0, shadowColor)
                
                CGContextBeginTransparencyLayer(context, nil)
                self.drawButton(context, rect:myRect, selected: self.slider.selectedButton == i)
                CGContextEndTransparencyLayer(context)
            }
        }
        
    }
}
    