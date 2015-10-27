//
//  CGUtils.swift
//  MonoSynth
//
//  Created by Dan Piponi on 10/27/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import QuartzCore

func savingContext(context: CGContext, f: Void->Void) {
    CGContextSaveGState(context)
    f()
    CGContextRestoreGState(context)
}
