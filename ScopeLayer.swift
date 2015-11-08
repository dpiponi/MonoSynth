//
//  ScopeLayer.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/7/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class ScopeLayer: CALayer {
    
    var scope : Scope! = nil
    var data : UnsafeMutablePointer<Double> = nil
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        
        if data == nil {
            return
        }
        
        let scopeFrame = CGRectInset(bounds, 2.0, 2.0)
        
        
        //
        // Flip upside-down
        //
        CGContextTranslateCTM(ctx, scopeFrame.size.width/2.0, scopeFrame.size.height/2.0)
        CGContextScaleCTM(ctx, 1.0, -1.0)
        CGContextTranslateCTM(ctx, -scopeFrame.size.width/2.0, -scopeFrame.size.height/2.0)
        
        let hscale : CGFloat = scopeFrame.width/1024.0
        let vscale : CGFloat = scopeFrame.size.height/2.0
        
        savingContext(ctx) {
        
            CGContextSetStrokeColorWithColor(ctx, UIColor(white: 0.0, alpha: 1.0).CGColor)
            CGContextMoveToPoint(ctx, 0.0, scopeFrame.size.height/2.0+vscale*CGFloat(self.data.memory))
            for i in 0 ..< 1024 {
//                if i==27 {
//                    print("data=",self.data.advancedBy(i).memory)
//                }
                CGContextAddLineToPoint(ctx, hscale*CGFloat(i), scopeFrame.size.height/2.0+vscale*CGFloat(self.data.advancedBy(i).memory))
            }
            CGContextStrokePath(ctx)
        }
        
    }
}
