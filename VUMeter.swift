//
//  VUMeter.swift
//  MonoSynth
//
//  Created by Dan Piponi on 11/6/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class VUMeter: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    //
    // frame: where render will happen in parent
    // bounds: region you can draw in, based at (0, 0)
    //
    var meterLayer : VUMeterLayer! = nil
    
//    var peak : Double = 0.0 {
//        didSet {
//            if meterLayer != nil {
//                meterLayer.peak = peak
//                print("peak set to =", peak)
//            }
//        }
//    }
    
    var controller : ViewController! = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        meterLayer = VUMeterLayer()
        meterLayer.meter = self
        self.layer.addSublayer(meterLayer)
        
        self.setLayerFrames()
        
        startTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        meterLayer = VUMeterLayer()
        meterLayer.meter = self
        self.layer.addSublayer(meterLayer)
        
        self.setLayerFrames()
        
        startTimer()
    }
    
    func startTimer() {
        NSTimer.scheduledTimerWithTimeInterval(
            0.1, target: self, selector: "update", userInfo: nil, repeats: true)

    }
    
    func update() {
//        print("Update")
        meterLayer.peak = controller.state.peak
        meterLayer.setNeedsDisplay()
    }
    
    func setLayerFrames() -> Void {
        meterLayer.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height) // = bounds?
        meterLayer.setNeedsDisplay()
    }
    

    #if TARGET_INTERFACE_BUILDER
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let myFrame = self.bounds
        CGContextSetLineWidth(context, 10)
        let myFrame2 = CGRectInset(myFrame, 5.0, 5.0)
        CGContextStrokeRect(context, myFrame2)
    }
    #endif

}
