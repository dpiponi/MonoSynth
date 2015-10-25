import UIKit
import QuartzCore

class PianoKeyLayer: CALayer {
    var highlighted : Bool = false
    weak var key : PianoKey! = nil
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        let keyWidth : CGFloat = 40.0
        
        // White keys
        for i in 0..<9 {
            let keyBounds = CGRect(x: CGFloat(i)*keyWidth, y: 0.0, width: CGFloat(keyWidth), height: 128.0)
            let pianoKeyFrame = CGRectInset(keyBounds, 2.0, 2.0)
            
            let rect = CGRectInset(pianoKeyFrame, 2.0, 2.0)
            
            let redColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1.0)
            
            CGContextSetFillColorWithColor(ctx, redColor.CGColor);
            CGContextFillRect(ctx, rect)
        }
        
        // Black keys
        let blacks : [Int] = [0, 1, 3, 4, 5]
        for j in 0..<5 {
            let i = blacks[j]
            let keyBounds = CGRect(x: 0.5*keyWidth+CGFloat(i)*keyWidth, y: 0.0, width: CGFloat(keyWidth), height: 64.0)
            let pianoKeyFrame = CGRectInset(keyBounds, 2.0, 2.0)
            
            let rect = CGRectInset(pianoKeyFrame, 2.0, 2.0)
            
            let redColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
            
            CGContextSetFillColorWithColor(ctx, redColor.CGColor);
            CGContextFillRect(ctx, rect)
        }
        
    }
}
    