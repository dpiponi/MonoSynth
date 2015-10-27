import UIKit

//
// http://www.raywenderlich.com/32283/core-graphics-tutorial-lines-rectangles-and-gradients
// http://stackoverflow.com/questions/24113239/issue-when-im-trying-to-draw-gradient-in-swift
//
class SignalPathView: UIView {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    //
    // http://blog.helftone.com/demystifying-inner-shadows-in-quartz/
    //
    
    func drawButton(context: CGContext, rect: CGRect, selected: Bool) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 0.4, 0.5, 1.0 ]
        
        //        NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
        
        
        
        let colors: CFArray = [
            UIColor(white:0.85, alpha: 1.0).CGColor,
            UIColor(white:1.0, alpha: 1.0).CGColor,
            UIColor(white:1.0, alpha: 1.0).CGColor,
            UIColor(white:0.75, alpha: 1.0).CGColor]
        
        let gradient : CGGradientRef = CGGradientCreateWithColors(colorSpace, colors, locations)!
        
        
        CGContextSaveGState(context)
        
        let components : [CGFloat] = [0.4, 0.4, 0.4, 1.0]
        let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
        
        // Draw inside
        CGContextSaveGState(context)
        CGContextAddRect(context, rect)
        CGContextClip(context)
        let startPoint = CGPoint(x: rect.origin.x, y: rect.origin.y)
        let endPoint = CGPoint(x: rect.origin.x, y: rect.origin.y+rect.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        CGContextRestoreGState(context)

        // Draw border
        CGContextAddRect(context, rect)
        CGContextClip(context)
        CGContextSetLineWidth(context, 4.0)
        if selected {
            CGContextSetShadowWithColor(context, CGSize(width: 1.0,height: 1.0), 5.0, shadowColor)
        } else {
            CGContextSetShadowWithColor(context, CGSize(width: 0.0,height: 0.0), 1.0, shadowColor)
            
        }
        let rect2 = CGRectInset(rect, -1.0, -1.0)
        CGContextAddRect(context, rect2)
        CGContextDrawPath(context, .Stroke)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
        
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let path1 = NSBundle.mainBundle().pathForResource("signalpath", ofType:"png")
        
        let dataProvider1 = CGDataProviderCreateWithFilename(path1!)
        let image1 = CGImageCreateWithPNGDataProvider(dataProvider1, nil, false, .RenderingIntentDefault)
//        let rect = CGRectInset(knobFrame, 2.0, 2.0)
        CGContextSaveGState(context)
        CGContextSetInterpolationQuality(context, .High)
        CGContextScaleCTM(context, 8.0, -8.0)
        CGContextTranslateCTM(context, 0.0, -100.0)
        CGContextDrawImage(context, CGRect(x: 0.0,y: 0.0,width: 100.0,height: 100.0), image1)
        CGContextRestoreGState(context)
        
//        CGContextSaveGState(context)
//        CGContextSetShouldAntialias(context, true)
//        CGContextSetLineWidth(context, 2.0)
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let components : [CGFloat] = [0.0, 0.0, 0.0, 1.0]
//        let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
//        CGContextSetShadowWithColor(context, CGSizeMake(0.0,0.0), 4.0, shadowColor)
//        let color = CGColorCreate(colorSpace, components)
//        CGContextSetStrokeColorWithColor(context, color)
//        CGContextRestoreGState(context)
        
//        CGContextMoveToPoint(context, 30, 30)
//        CGContextAddLineToPoint(context, 100, 200)
        let buttonWidth : CGFloat = 48.0
        let buttonheight : CGFloat = 32.0
        let myRect = CGRect(x:100.0, y:100.0, width:buttonWidth, height:buttonheight)
        let myRect2 = CGRect(x:100.0+buttonWidth, y:100.0, width:buttonWidth, height:buttonheight)
        let myRect3 = CGRect(x:100.0+2*buttonWidth, y:100.0, width:buttonWidth, height:buttonheight)
        let myRect4 = CGRect(x:100.0+3*buttonWidth, y:100.0, width:buttonWidth, height:buttonheight)
        
        CGContextSaveGState(context)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components : [CGFloat] = [0.4, 0.4, 0.4, 1.0]
        let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
        CGContextSetShadowWithColor(context, CGSize(width: 1.0,height: 1.0), 6.0, shadowColor)

        drawButton(context!, rect:myRect2, selected: true)
        CGContextBeginTransparencyLayer(context, nil)
        drawButton(context!, rect:myRect, selected: false)
        drawButton(context!, rect:myRect3, selected: false)
        drawButton(context!, rect:myRect4, selected: false)
        CGContextEndTransparencyLayer(context)
        
        CGContextRestoreGState(context)
        
        
//        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0);
//        
//        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
//        CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
//        
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGFloat components[4] = {0.0, 0.0, 0.0, 1.0};
//        CGColorRef shadowColor = CGColorCreate(colorSpace, components);
//        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(10,10), 4.0, shadowColor);
    }
}
