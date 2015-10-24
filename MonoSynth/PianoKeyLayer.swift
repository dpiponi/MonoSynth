import UIKit
import QuartzCore

class PianoKeyLayer: CALayer {
    var highlighted : Bool = false
    weak var key : PianoKey! = nil
    
    override func drawInContext(ctx: CGContextRef) -> Void {
        
        let pianoKeyFrame = CGRectInset(bounds, 2.0, 2.0)
        
        // 1) fill - with a subtle shadow
        let rect = CGRectInset(pianoKeyFrame, 2.0, 2.0)
        
        CGContextSaveGState(ctx);
        
        //
        // http://stackoverflow.com/questions/14404877/anti-aliasing-uiimage-looks-blurred-or-jagged
        //
        
        let redColor = UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0)
        
        CGContextSetFillColorWithColor(ctx, redColor.CGColor);
        CGContextFillRect(ctx, rect)
//        CGContextRestoreGState(ctx);
        
    }
}
    