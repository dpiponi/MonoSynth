//
//  PianoKey.swift
//  MonoSynth
//
//  Created by Dan Piponi on 10/24/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit

class PianoKey: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var pianoKeyLayer : PianoKeyLayer! = nil
    var numWhiteKeys : Int = 8 {
        didSet {
            self.setLayerFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        pianoKeyLayer = PianoKeyLayer()
        pianoKeyLayer.key = self
        self.layer.addSublayer(pianoKeyLayer)
        
        self.setLayerFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        pianoKeyLayer = PianoKeyLayer()
        pianoKeyLayer.key = self
        self.layer.addSublayer(pianoKeyLayer)
        
        self.setLayerFrames()
    }
    
    func setLayerFrames() -> Void {
//        knobWidth = bounds.size.height
        let keyWidth : CGFloat = bounds.size.width/CGFloat(numWhiteKeys)
//        pianoKeyLayer.frame = CGRectMake(0, 0, CGFloat(numWhiteKeys)*keyWidth, 128.0)
        pianoKeyLayer.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height)
        
        pianoKeyLayer.setNeedsDisplay()
    }
    
}
