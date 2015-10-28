//
//  AudioRender.m
//  MonoSynth
//
//  Created by Dan Piponi on 10/27/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AudioUnit;
OSStatus audio_render( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData ) {
#if 0
    let viewController = (ViewController *)inRefCon;
    let buffer = UnsafeMutablePointer<Float>(ioData.memory.mBuffers.mData) // mBuffers[0]???
    
    for i in 0..<Int(inNumberFrames) {
        buffer[i] = Float(viewController.amplitude*sin(viewController.phase))
        
        viewController.phase += 2.0*M_PI*viewController.actualFrequency/viewController.sampleRate
        viewController.actualFrequency = 0.999*viewController.actualFrequency+0.001*viewController.frequency
        var rate : Double = 0.0
        if viewController.targetAmplitude > viewController.amplitude {
            rate = 0.9
        } else {
            rate = 0.9999
        }
        viewController.amplitude = rate*viewController.amplitude+(1-rate)*viewController.targetAmplitude
        if (viewController.phase > 2.0 * M_PI) {
            viewController.phase -= 2.0 * M_PI
        }
    }
#endif
    return noErr;
}