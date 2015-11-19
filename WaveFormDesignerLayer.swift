//
//  WaveFormDesignerLayer.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class WaveFormDesignerLayer: CALayer {
    var highlighted : Bool = false
    weak var waveFormDesigner : WaveFormDesigner! = nil
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        
    savingContext(ctx) {
        let n = self.waveFormDesigner.x.count
        CGContextMoveToPoint(ctx, CGFloat(self.waveFormDesigner.x[0]), CGFloat(self.waveFormDesigner.y[0]))
            
        for i in 1..<n {
            CGContextAddLineToPoint(ctx, CGFloat(self.waveFormDesigner.x[i])*self.bounds.width, CGFloat(self.waveFormDesigner.y[i])*self.bounds.height);
        }
        CGContextStrokePath(ctx)
        }
    }
}
