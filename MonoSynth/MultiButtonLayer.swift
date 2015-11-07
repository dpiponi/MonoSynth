//
//  KnobLayer.swift
//  Knob
//
//  Created by Dan Piponi on 10/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit
import QuartzCore

func sinLegend(context: CGContext, rect: CGRect, selected: Bool) -> Void {
    let size = rect.height
    let xcenter = rect.origin.x+0.5*rect.width
    let ycenter = rect.origin.y+0.5*rect.height
    
    savingContext(context) {
        CGContextSetShadowWithColor(context, CGSize(width: 1.0,height: 1.0), 1.0, nil)
        if selected {
            CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        } else {
            CGContextSetStrokeColorWithColor(context, UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0).CGColor)
        }
        CGContextTranslateCTM(context, xcenter, ycenter)
        CGContextScaleCTM(context, size, size)
        
        CGContextSetLineWidth(context, 2.0/size)
        CGContextBeginPath(context)
        for i in (-20)..<20 {
            let t = 3.1415926*Double(i)/20.0
            let x = CGFloat(i)/40.0
            let y = 0.25*CGFloat(sin(t))
            if i==(-20) {
                let size :CGFloat = 1.0
                CGContextMoveToPoint(context, x*size, y*size)
            } else {
                let size :CGFloat = 1.0
                CGContextAddLineToPoint(context, x*size, y*size)
            }
        }
        CGContextStrokePath(context)
    }
}

func squareLegend(context: CGContext, rect: CGRect, selected: Bool) -> Void {
    let size = rect.height
    let xcenter = rect.origin.x+0.5*rect.width
    let ycenter = rect.origin.y+0.5*rect.height
    
    savingContext(context) {
        CGContextSetShadowWithColor(context, CGSize(width: 0.0,height: 0.0), 0.0, nil)
        if selected {
            CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        } else {
            CGContextSetStrokeColorWithColor(context, UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0).CGColor)
        }
        CGContextTranslateCTM(context, xcenter, ycenter)
        CGContextScaleCTM(context, size, -size)
        
        CGContextSetLineWidth(context, 2.0/size)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, -0.5,-0.25)
        CGContextAddLineToPoint(context, -0.5,0.25)
        CGContextAddLineToPoint(context, 0.0,0.25)
        CGContextAddLineToPoint(context, 0.0,-0.25)
        CGContextAddLineToPoint(context, 0.5,-0.25)
        CGContextAddLineToPoint(context, 0.5,0.25)
        CGContextStrokePath(context)
    }
}

func sawLegend(context: CGContext, rect: CGRect, selected: Bool) -> Void {
    let size = rect.height
    let xcenter = rect.origin.x+0.5*rect.width
    let ycenter = rect.origin.y+0.5*rect.height
    
    savingContext(context) {
        CGContextSetShadowWithColor(context, CGSize(width: 0.0,height: 0.0), 0.0, nil)
        if selected {
            CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        } else {
            CGContextSetStrokeColorWithColor(context, UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0).CGColor)
        }
        CGContextTranslateCTM(context, xcenter, ycenter)
        CGContextScaleCTM(context, size, -size)
        
        CGContextSetLineWidth(context, 2.0/size)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, -0.5,-0.25)
        CGContextAddLineToPoint(context, 0.0,0.25)
        CGContextAddLineToPoint(context, 0.0,-0.25)
        CGContextAddLineToPoint(context, 0.5,0.25)
        CGContextAddLineToPoint(context, 0.5,-0.25)
        CGContextStrokePath(context)
    }
}

func randLegend(context: CGContext, rect: CGRect, selected: Bool) -> Void {
    let size = rect.height
    let xcenter = rect.origin.x+0.5*rect.width
    let ycenter = rect.origin.y+0.5*rect.height
    
    savingContext(context) {
        CGContextSetShadowWithColor(context, CGSize(width: 0.0,height: 0.0), 0.0, nil)
        if selected {
            CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        } else {
            CGContextSetStrokeColorWithColor(context, UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0).CGColor)
        }
        CGContextTranslateCTM(context, xcenter, ycenter)
        CGContextScaleCTM(context, size, -size)
        
        CGContextSetLineWidth(context, 2.0/size)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, -0.5,0.0)
        CGContextAddLineToPoint(context, -0.5,-0.25)
        CGContextAddLineToPoint(context, -0.25,-0.25)
        CGContextAddLineToPoint(context, -0.25,-0.125)
        CGContextAddLineToPoint(context, -0.0,-0.125)
        CGContextAddLineToPoint(context, -0.0,-0.25)
        CGContextAddLineToPoint(context, 0.25,-0.25)
        CGContextAddLineToPoint(context, 0.25,0.125)
        CGContextAddLineToPoint(context, 0.50,0.125)
        CGContextAddLineToPoint(context, 0.50,-0.0)
        
        CGContextStrokePath(context)
        
        print("RAND!!!!!!!!!!!!!!")
    }
}

class MultiButtonLayer: CALayer {
    var highlighted : Bool = false
    weak var slider : MultiButton! = nil
    
    func drawButton(context: CGContext, rect: CGRect, selected: Bool, f: MultiIcon) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 0.4, 0.5, 1.0 ]
        
        let colors: CFArray = [
            UIColor(white:0.9, alpha: 1.0).CGColor,
            UIColor(white:1.0, alpha: 1.0).CGColor,
            UIColor(white:1.0, alpha: 1.0).CGColor,
            UIColor(white:0.8, alpha: 1.0).CGColor]
        
        let gradient : CGGradientRef = CGGradientCreateWithColors(colorSpace, colors, locations)!
        
        
        savingContext(context) {
        
//            let components : [CGFloat] = [0.4, 0.4, 0.4, 1.0]
//            let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
            let components2 : [CGFloat] = [0.0, 0.0, 0.0, 1.0]
            let shadowColor2 : CGColorRef = CGColorCreate(colorSpace, components2)!
            
            // Draw inside
            savingContext(context) {
                CGContextAddRect(context, rect)
                CGContextClip(context)
                let startPoint = CGPoint(x: rect.origin.x, y: rect.origin.y)
                let endPoint = CGPoint(x: rect.origin.x, y: rect.origin.y+rect.height)
                CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
            }
            
            if selected {
                CGContextAddRect(context, CGRectInset(rect,-1.0, -1.0))
                CGContextClip(context)
                CGContextSetShadowWithColor(context, CGSize(width: 1.0,height: 1.0), 4.0, shadowColor2)
            } else {
                CGContextBeginTransparencyLayer(context, nil)
                
//                CGContextSetShadowWithColor(context, CGSize(width: 1.0,height: 1.0), 2.0, shadowColor)
                
            }

            // Draw border
            CGContextSetLineWidth(context, 2.0)
            let rect2 = CGRectInset(rect, 0.0, 0.0)
            CGContextAddRect(context, rect2)
            CGContextDrawPath(context, .Stroke)
            CGContextStrokePath(context)
            
            if !selected {
                CGContextEndTransparencyLayer(context)
            }
            
            switch f {
            case .Sine:
                sinLegend(context, rect: rect, selected: selected)
            case .Square:
                squareLegend(context, rect: rect, selected: selected)
            case .Saw:
                sawLegend(context, rect: rect, selected: selected)
            case .Rand:
                randLegend(context, rect: rect, selected: selected)
            }
        }
    }

    override func drawInContext(context: CGContextRef) -> Void {
        let bounds2 = CGRectInset(bounds, 10.0, 10.0)
        let numElements : Int = slider.icons.count
        let buttonWidth : CGFloat = bounds2.width/CGFloat(numElements)
        let buttonheight : CGFloat = bounds2.height
        let x : CGFloat = bounds2.origin.x
        let y : CGFloat = bounds2.origin.y
//        let drawer : [(CGContext, CGRect, Bool) -> Void] = [
//            sinLegend,
//            squareLegend,
//            sawLegend
//        ]
        for i in 0..<numElements {
            let myRect = CGRect(x:x+CGFloat(i)*buttonWidth, y:y, width:buttonWidth, height:buttonheight)
            
            savingContext(context) {
                self.drawButton(context, rect:myRect, selected: self.slider.selectedButton == i, f:self.slider.icons[i])
            }
        }
        
    }
}
    