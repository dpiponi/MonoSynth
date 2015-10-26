import UIKit

//
// http://www.raywenderlich.com/32283/core-graphics-tutorial-lines-rectangles-and-gradients
// http://stackoverflow.com/questions/24113239/issue-when-im-trying-to-draw-gradient-in-swift
//
class SignalPathView: UIView {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
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
        
        CGContextSetShouldAntialias(context, true)
        CGContextSetLineWidth(context, 2.0)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components : [CGFloat] = [0.0, 0.0, 0.0, 1.0]
        let shadowColor : CGColorRef = CGColorCreate(colorSpace, components)!
        CGContextSetShadowWithColor(context, CGSizeMake(3,3), 4.0, shadowColor)
        let color = CGColorCreate(colorSpace, components)
        CGContextSetStrokeColorWithColor(context, color)
        
//        CGContextMoveToPoint(context, 30, 30)
//        CGContextAddLineToPoint(context, 100, 200)


        let locations: [CGFloat] = [ 0.0, 0.5, 1.0 ]
        
//        NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
        
        
        
        let colors: CFArray = [
            UIColor(white:0.9, alpha: 1.0).CGColor,
            UIColor(white:1.0, alpha: 1.0).CGColor,
            UIColor(white:0.8, alpha: 1.0).CGColor]
        
        let gradient : CGGradientRef = CGGradientCreateWithColors(colorSpace, colors, locations)!
        
        let myRect = CGRect(x:100.0, y:100.0, width:200.0, height:150.0)

        CGContextAddRect(context, myRect)
        CGContextDrawPath(context, .Stroke)
        CGContextStrokePath(context)
        
        CGContextAddRect(context, myRect)
        CGContextSaveGState(context)
        CGContextClip(context)
        let startPoint = CGPoint(x: 100.0, y: 100.0)
        let endPoint = CGPoint(x: 100.0, y: 150.0)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
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
