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
        
        savingContext(ctx) {
            let n = self.filterDesigner.x.count
            CGContextMoveToPoint(ctx,
                CGFloat(self.filterDesigner.x[0]/log(20000.0))*self.bounds.width,
                CGFloat(0.5-self.filterDesigner.y[0]/40.0)*self.bounds.height)
                
            for i in 1..<n {
                CGContextAddLineToPoint(ctx,
                    CGFloat(self.filterDesigner.x[i]/log(20000.0))*self.bounds.width,
                    CGFloat(0.5-self.filterDesigner.y[i]/40.0)*self.bounds.height
                );
            }
            CGContextStrokePath(ctx)
        }
    }
}
