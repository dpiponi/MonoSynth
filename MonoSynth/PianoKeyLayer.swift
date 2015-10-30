import UIKit
import QuartzCore

class PianoKeyLayer: CALayer {
    var highlighted : Bool = false
    weak var key : PianoKey! = nil
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        let keyWidth : CGFloat = 40.0
        let numNotes = key.numWhiteKeys
        let keyMask = [true, true, false, true, true, true, false, true]

        //
        // http://stackoverflow.com/questions/749558/why-is-there-an-frame-rectangle-and-an-bounds-rectangle-in-an-uiview
        //
        
        // White keys
        print("numnotes=", numNotes)
        for i in 0..<numNotes {
            let keyBounds = CGRect(x: CGFloat(i)*keyWidth, y: 0.0, width: CGFloat(keyWidth), height: 128.0)
            let pianoKeyFrame = CGRectInset(keyBounds, 2.0, 2.0)
            
            let rect = CGRectInset(pianoKeyFrame, 2.0, 2.0)
            
            let redColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1.0)
            
            CGContextSetFillColorWithColor(ctx, redColor.CGColor);
            CGContextFillRect(ctx, rect)
        }
        
        // Black keys
//        let blacks : [Int] = [0, 1, 3, 4, 5]
        for i in 0...numNotes {
            if keyMask[i % 7] {
                let keyBounds = CGRect(x: 0.5*keyWidth+CGFloat(i)*keyWidth, y: 0.0, width: CGFloat(keyWidth), height: 64.0)
                let pianoKeyFrame = CGRectInset(keyBounds, 2.0, 2.0)
                
                let rect = CGRectInset(pianoKeyFrame, 2.0, 2.0)
                
                let redColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
                
                CGContextSetFillColorWithColor(ctx, redColor.CGColor);
                CGContextFillRect(ctx, rect)
            }
        }
        
    }
}
    