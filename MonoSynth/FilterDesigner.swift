//
//  FilterDesigner.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/19/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

enum FilterNodeType {
    case Zero
    case Pole
}

class FilterDesigner: UIControl {

    var x : [Double] = [log(440.0), log(600.0), log(1000.0)]
    var y : [Double] = [-4.0, 4.0, 4.0]
    
    var filterLayer : FilterDesignerLayer! = nil
    
    var initialTouchPoint : CGPoint = CGPoint()
    var nodeType : [FilterNodeType] = [.Zero, .Pole, .Pole]
    var selectedPoint : Int = -1
    var initialX : Double = 0.0
    var initialY : Double = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        filterLayer = FilterDesignerLayer()
        filterLayer.filterDesigner = self
        self.layer.addSublayer(filterLayer)
        
        self.setLayerFrames()
    }
    
    func setLayerFrames() -> Void {
        filterLayer.frame = CGRectInset(bounds, 5.0, 5.0)
        
        filterLayer.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        filterLayer = FilterDesignerLayer()
        filterLayer.filterDesigner = self
        self.layer.addSublayer(filterLayer)
        
        self.setLayerFrames()
    }
    
    func close(x: CGFloat, y: CGFloat) -> Bool {
        return x > y-10 && x < y+10
    }
    
    func close(a: CGPoint, b: CGPoint) -> Bool {
        return close(a.x, y: b.x) && close(a.y, y: b.y)
    }
    
    override func beginTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        initialTouchPoint = touch.locationInView(self)
        print("initial=", initialTouchPoint)
        selectedPoint = -1
        
        for i in 0..<x.count {
            if close(
                initialTouchPoint,
                b: CGPoint(
                    x: bounds.width*CGFloat(x[i]/log(20000.0)),
                    y: bounds.height*CGFloat(0.5-y[i]/40.0))) {
                        selectedPoint = i
                        initialX = x[i]
                        initialY = y[i]
                        print("Selected", i)
                        return true
            }
        }
        
        return false
    }

    func clamp(x: Double, a: Double, b: Double) -> Double {
        if x < a {
            return a
        }
        if x > b {
            return b
        }
        return x
    }
    
    override func continueTrackingWithTouch(touch : UITouch, withEvent event:UIEvent?) -> Bool {
        let touchPoint = touch.locationInView(self)
        
        let deltaX = touchPoint.x-initialTouchPoint.x
        let deltaY = touchPoint.y-initialTouchPoint.y
        
        let newX = clamp(initialX+Double(deltaX/bounds.width)*log(20000.0), a: 0.0, b: log(20000.0))
        x[selectedPoint] = newX
        y[selectedPoint] = clamp(initialY-40.0*Double(deltaY/bounds.height), a: -20.0, b: 20.0)
        
        //        previousTouchPoint = touchPoint
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        setLayerFrames()
        CATransaction.setAnimationDuration(0.0)
        CATransaction.commit()
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }

    override func endTrackingWithTouch(touch : UITouch?, withEvent event: UIEvent?) -> Void {
        filterLayer.setNeedsDisplay()
        selectedPoint = -1
    }
    
    func redrawLayers() -> Void {
        filterLayer.setNeedsDisplay()
    }
    
    func computeMax() -> Double {
        var max : Double = 0.0
        
        for i in 0..<1000 {
            let logf = log(20000.0)*Double(i)/1000
            let f = exp(logf)
            let z = exp(2*3.14159265358*1.i*f/44100.0)
            // XXX Carry on here!
            //                scale = abs(g(zeros, poles, exp(2*3.14159265358*1.i*f/44100.0)))
            
            var prod = Complex64(1.0, 0.0)
            for j in 0 ..< x.count {
                var dir : Double
                switch nodeType[j] {
                case .Zero:
                    dir = 1.0
                case .Pole:
                    dir = -1.0
                }
                let f0 = exp(x[j])
                let r0 = 1-exp(dir*y[j]*0.5)/f0
                let nx = r0*cos(2*3.1415926535897*f0/44000.0)
                let ny = r0*sin(2*3.1415926535897*f0/44000.0)
                
                switch nodeType[j] {
                case .Zero:
                    prod *= z-Complex64(nx, ny)
                    prod *= z-Complex64(nx, -ny)
                case .Pole:
                    prod /= z-Complex64(nx, ny)
                    prod /= z-Complex64(nx, -ny)
                }
            }
            let trans = prod.abs
            if trans > max {
                max = trans
            }
        }
        return max;
    }
    
    
    //
    // http://stackoverflow.com/questions/30745026/checking-if-code-is-running-in-interface-builder-in-swift
    //
    #if TARGET_INTERFACE_BUILDER
    override func drawRect(rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    let myFrame = self.bounds
    CGContextSetLineWidth(context, 10)
    let myFrame2 = CGRectInset(myFrame, 5.0, 5.0)
    CGContextStrokeEllipseInRect(context, myFrame2)
    }
    #endif

}
