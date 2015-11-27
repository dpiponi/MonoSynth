//
//  FilterDesignerLayer.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class FilterDesignerLayer: CALayer {
    var highlighted : Bool = false
    weak var filterDesigner : FilterDesigner! = nil
    
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        print("Redraw!!!!!")
        
        savingContext(ctx) {
            let color1 = UIColor(white: 0.5, alpha: 1.0)
            CGContextSetStrokeColorWithColor(ctx, color1.CGColor)
            print("f=", self.filterDesigner.frequency)
            
            CGContextMoveToPoint(ctx, CGFloat(log(self.filterDesigner.frequency)/log(20000.0))*self.bounds.width, 0.0)
            CGContextAddLineToPoint(ctx, CGFloat(log(self.filterDesigner.frequency)/log(20000.0))*self.bounds.width, self.bounds.height)
            CGContextDrawPath(ctx, .FillStroke)
            
            let color2 = UIColor(white: 0.7, alpha: 1.0)
            CGContextSetStrokeColorWithColor(ctx, color2.CGColor)
            CGContextMoveToPoint(ctx, CGFloat(log(2.0*self.filterDesigner.frequency)/log(20000.0))*self.bounds.width, 0.0)
            CGContextAddLineToPoint(ctx, CGFloat(log(2.0*self.filterDesigner.frequency)/log(20000.0))*self.bounds.width, self.bounds.height)
            CGContextDrawPath(ctx, .FillStroke)
            
            let color3 = UIColor(white: 0.8, alpha: 1.0)
            CGContextSetStrokeColorWithColor(ctx, color3.CGColor)
            CGContextMoveToPoint(ctx, CGFloat(log(3.0*self.filterDesigner.frequency)/log(20000.0))*self.bounds.width, 0.0)
            CGContextAddLineToPoint(ctx, CGFloat(log(3.0*self.filterDesigner.frequency)/log(20000.0))*self.bounds.width, self.bounds.height)
            CGContextDrawPath(ctx, .FillStroke)
            
            let color4 = UIColor(white: 0.9, alpha: 1.0)
            CGContextSetStrokeColorWithColor(ctx, color4.CGColor)
            CGContextMoveToPoint(ctx, CGFloat(log(4.0*self.filterDesigner.frequency)/log(20000.0))*self.bounds.width, 0.0)
            CGContextAddLineToPoint(ctx, CGFloat(log(4.0*self.filterDesigner.frequency)/log(20000.0))*self.bounds.width, self.bounds.height)
            CGContextDrawPath(ctx, .FillStroke)
        }
        
        savingContext(ctx) {
            let n = self.filterDesigner.x.count
//            CGContextMoveToPoint(ctx,
//                CGFloat(self.filterDesigner.x[0]/log(20000.0))*self.bounds.width,
//                CGFloat(0.5-self.filterDesigner.y[0]/40.0)*self.bounds.height)
            
            for i in 0..<n {
                let rectangle = CGRect(
                    x: CGFloat(self.filterDesigner.x[i]/log(20000.0))*self.bounds.width-5,
                    y: CGFloat(0.5-self.filterDesigner.y[i]/40.0)*self.bounds.height-5,
                    width: 10, height: 10)
                
                switch self.filterDesigner.nodeType[i] {
                case .Zero:
                    CGContextSetFillColorWithColor(ctx, UIColor.blueColor().CGColor)
                case .Pole:
                    CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
                }
                CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
//                CGContextSetLineWidth(context, 10)
                
                CGContextAddEllipseInRect(ctx, rectangle)
                CGContextDrawPath(ctx, .FillStroke)
                
                //                CGContextAddLineToPoint(ctx,
//                    CGFloat(self.filterDesigner.x[i]/log(20000.0))*self.bounds.width,
//                    CGFloat(0.5-self.filterDesigner.y[i]/40.0)*self.bounds.height
//                );
            }
            CGContextStrokePath(ctx)
            
            CGContextMoveToPoint(ctx, 0.0, 0.0)
            for i in 0..<1000 {
                let logf = log(20000.0)*Double(i)/1000
                let f = exp(logf)
                let z = exp(2*3.14159265358*1.i*f/44100.0)
                // XXX Carry on here!
//                scale = abs(g(zeros, poles, exp(2*3.14159265358*1.i*f/44100.0)))
                
                var prod = Complex64(1.0, 0.0)
                for j in 0 ..< self.filterDesigner.x.count {
                    var dir : Double
                    switch self.filterDesigner.nodeType[j] {
                    case .Zero:
                        dir = 1.0
                    case .Pole:
                        dir = -1.0
                    }
                    let f0 = exp(self.filterDesigner.x[j])
                    let r0 = 1-exp(dir*self.filterDesigner.y[j]*0.5)/f0
                    let nx = r0*cos(2*3.1415926535897*f0/44000.0)
                    let ny = r0*sin(2*3.1415926535897*f0/44000.0)
                    
                    switch self.filterDesigner.nodeType[j] {
                    case .Zero:
                        prod *= z-Complex64(nx, ny)
                        prod *= z-Complex64(nx, -ny)
                    case .Pole:
                        prod /= z-Complex64(nx, ny)
                        prod /= z-Complex64(nx, -ny)
                    }
                }
                let px = CGFloat(i)/1000.0
                let trans = prod.abs/self.filterDesigner.maxValue
                let py = 0.5-CGFloat(log(trans))/40.0
//                print(px, py)
                CGContextAddLineToPoint(ctx, px*self.bounds.width, py*self.bounds.height)
            }
            CGContextStrokePath(ctx)

        }
    }
}
