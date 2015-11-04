//
//  ViewController.swift
//  FunctionGenerator
//
//  Created by Dan Piponi on 10/20/15.
//  Copyright © 2015 Dan Piponi. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

//
// These lenses differ from Haskell lenses because A is mutable.
// si fueris Rōmae...
//
struct Lens<A, B> {
    let set: (inout A, B) -> Void
    let get: A -> B
}

//
// http://www.cocoawithlove.com/2010/10/ios-tone-generator-introduction-to.html
//
// http://stackoverflow.com/questions/1135163/how-do-i-use-uiscrollview-in-interface-builder
// https://grokswift.com/custom-fonts/
// https://github.com/HeshamMegid/HMSegmentedControl/blob/master/HMSegmentedControl/HMSegmentedControl.m
//
class ViewController: UIViewController {

    @IBOutlet weak var vco1Panel: UIView!
    @IBOutlet weak var lfo1Panel: UIView!
    @IBOutlet weak var lfo2Panel: UIView!
    @IBOutlet weak var filt1Panel: UIView!
    @IBOutlet weak var env1Panel: UIView!
    @IBOutlet weak var env2Panel: UIView!
    @IBOutlet weak var vcaPanel: UIView!
    @IBOutlet weak var env1Graph: ADSRPlot!
    @IBOutlet weak var env2Graph: ADSRPlot!
    
    @IBOutlet weak var waveformSelector: MultiButton!
    @IBOutlet weak var lfo1Frequency: Knob!
    @IBOutlet weak var lfo2Frequency: Knob!
    
    //
    // VCO1
    //
    @IBOutlet weak var vco1Detune: Knob!
    @IBOutlet weak var vco1Number: Knob!
    @IBOutlet weak var vco1Spread: Knob!
    @IBOutlet weak var vco1Lfo1Modulation: Knob!
    
    @IBOutlet weak var filterCutoff: Knob!
    @IBOutlet weak var filterResonance: Knob!
    @IBOutlet weak var filterCutoffLFO1Modulation: Knob!
    @IBOutlet weak var filterCutoffLFO2Modulation: Knob!
    @IBOutlet weak var filterCutoffEnv1Modulation: Knob!
    
    //
    // ENV1
    //
    @IBOutlet weak var envDelay: Knob!
    @IBOutlet weak var envAttack: Knob!
    @IBOutlet weak var envHold: Knob!
    @IBOutlet weak var envDecay: Knob!
    @IBOutlet weak var envSustain: Knob!
    @IBOutlet weak var envRelease: Knob!
    @IBOutlet weak var envRetrigger: Knob!
    
    //
    // VCA
    //
    @IBOutlet weak var vcaEnv2Switch: UISwitch!
    @IBOutlet weak var vcaLfo1Modulation: Knob!
    @IBOutlet weak var vcaLfo2Modulation: Knob!
    
    var gen : AudioComponentInstance = nil

    var sampleRate : Double = 44100.0
    
    var state = AudioState()
    
    var keys : [UIButton] = [UIButton]()
    
    //
    // UI handlers
    //
    @IBAction func filterCutoffChanged(sender: Knob) {
        state.filter_cutoff = Double(sender.value)
    }
    
    @IBAction func filterResonanceChanged(sender: Knob) {
        state.filter_resonance = Double(sender.value)
        print("res",state.filter_resonance)
    }
    
    //
    // LFO1 & LFO2
    //
    @IBAction func lfo1FrequencyChanged(sender: Knob) {
        switch sender.tag {
        case 0:
            state.lfo_frequency.0 = Double(sender.value)
        case 1:
            state.lfo_frequency.1 = Double(sender.value)
        default: break
        }
    }
    
    //
    // LPF1
    //
    @IBAction func filterFrequencyLFO1ModulationChanged(sender: Knob) {
        switch sender.tag {
        case 0:
            state.lfo_filter_cutoff_modulation.0 = Double(sender.value)
        case 1:
            state.lfo_filter_cutoff_modulation.1 = Double(sender.value)
        default: break;
        }
    }
    
    @IBAction func filterCutoffEnvModulation(sender: Knob) {
        switch sender.tag {
        case 0:
            state.filter_cutoff_env_modulation.0 = Double(sender.value)
        case 1:
            state.filter_cutoff_env_modulation.1 = Double(sender.value)
        default:
            break
        }
    }

    
    //
    // VCO1
    //
    @IBAction func vco1Lfo1ModulationChanged(sender: Knob) {
        state.vco1_lfo1_modulation = Double(sender.value)
    }
    
    @IBAction func vco1DetuneChanged(sender: Knob) {
        state.vco1_detune = Double(sender.value)
    }
    @IBAction func vco1NumberChanged(sender: Knob) {
        state.vco1_number = Int32(sender.value)
    }
    @IBAction func vco1SpreadChanged(sender: Knob) {
        state.vco1_spread = Double(sender.value)
    }
    
    
    @IBAction func vco1Pressed(sender: UIButton) {
        vco1Panel.hidden = false
        lfo1Panel.hidden = true
        lfo2Panel.hidden = true
        filt1Panel.hidden = true
        env1Panel.hidden = true
        env2Panel.hidden = true
        vcaPanel.hidden = true
    }
    
    @IBAction func lfo1Pressed(sender: UIButton) {
        vco1Panel.hidden = true
        lfo1Panel.hidden = false
        lfo2Panel.hidden = true
        filt1Panel.hidden = true
        env1Panel.hidden = true
        env2Panel.hidden = true
        vcaPanel.hidden = true
    }
    
    @IBAction func lfo2Pressed(sender: UIButton) {
        vco1Panel.hidden = true
        lfo1Panel.hidden = true
        lfo2Panel.hidden = false
        filt1Panel.hidden = true
        env1Panel.hidden = true
        env2Panel.hidden = true
        vcaPanel.hidden = true
    }
    
    @IBAction func filt1Button(sender: UIButton) {
        vco1Panel.hidden = true
        lfo1Panel.hidden = true
        lfo2Panel.hidden = true
        filt1Panel.hidden = false
        env1Panel.hidden = true
        env2Panel.hidden = true
        vcaPanel.hidden = true
    }
    
    @IBAction func env1ButtonPressed(sender: UIButton) {
        vco1Panel.hidden = true
        lfo1Panel.hidden = true
        lfo2Panel.hidden = true
        filt1Panel.hidden = true
        env1Panel.hidden = false
        env2Panel.hidden = true
        vcaPanel.hidden = true
    }
    
    @IBAction func env2ButtonPressed(sender: UIButton) {
        vco1Panel.hidden = true
        lfo1Panel.hidden = true
        lfo2Panel.hidden = true
        filt1Panel.hidden = true
        env1Panel.hidden = true
        env2Panel.hidden = false
        vcaPanel.hidden = true
    }
    
    @IBAction func vcaPressed(sender: UIButton) {
        vco1Panel.hidden = true
        lfo1Panel.hidden = true
        lfo2Panel.hidden = true
        filt1Panel.hidden = true
        env1Panel.hidden = true
        env2Panel.hidden = true
        vcaPanel.hidden = false
    }
    
    //
    // ENV1
    //
    
    @IBAction func envDelayChanged(sender: Knob) {
        switch sender.tag {
        case 0:
            state.envDelay.0 = Double(sender.value)
            env1Graph.delay = sender.value
            env1Graph.setNeedsDisplay()
        case 1:
            state.envDelay.1 = Double(sender.value)
            env2Graph.delay = sender.value
            env2Graph.setNeedsDisplay()
        default:
            break
        }
    }
    @IBAction func envAttackChanged(sender: Knob) {
        switch sender.tag {
        case 0:
            state.envAttack.0 = Double(sender.value)
            env1Graph.attack = sender.value
            env1Graph.setNeedsDisplay()
        case 1:
            state.envAttack.1 = Double(sender.value)
            env2Graph.attack = sender.value
            env2Graph.setNeedsDisplay()
        default:
            break
        }
    }
    @IBAction func envHoldChanged(sender: Knob) {
        switch sender.tag {
        case 0:
            state.envHold.0 = Double(sender.value)
            env1Graph.hold = sender.value
            env1Graph.setNeedsDisplay()
        case 1:
            state.envHold.1 = Double(sender.value)
            env2Graph.hold = sender.value
            env2Graph.setNeedsDisplay()
        default:
            break
        }
    }
    @IBAction func envDecayChanged(sender: Knob) {
        switch sender.tag {
        case 0:
            state.envDecay.0 = Double(sender.value)
            env1Graph.decay = sender.value
            env1Graph.setNeedsDisplay()
        case 1:
            state.envDecay.1 = Double(sender.value)
            env2Graph.decay = sender.value
            env2Graph.setNeedsDisplay()
        default:
            break
        }
    }
    @IBAction func envSustainChanged(sender: Knob) {
        switch sender.tag {
        case 0:
            state.envSustain.0 = Double(sender.value)
            env1Graph.sustain = sender.value
            env1Graph.setNeedsDisplay()
        case 1:
            state.envSustain.1 = Double(sender.value)
            env2Graph.sustain = sender.value
            env2Graph.setNeedsDisplay()
        default:
            break
        }
    }
    @IBAction func envReleaseChanged(sender: Knob) {
        switch sender.tag {
        case 0:
            state.envRelease.0 = Double(sender.value)
            env1Graph.release_ = sender.value
            env1Graph.setNeedsDisplay()
        case 1:
            state.envRelease.1 = Double(sender.value)
            env2Graph.release_ = sender.value
            env2Graph.setNeedsDisplay()
        default:
            break
        }
    }
    @IBAction func envRetriggerChanged(sender: Knob) {
        switch sender.tag {
        case 0:
            state.envRetrigger.0 = Double(sender.value)
        case 1:
            state.envRetrigger.1 = Double(sender.value)
        default:
            break
        }
    }
    
    //
    // VCA
    //
    @IBAction func vcaEnv2(sender: UISwitch) {
        state.vcaEnv2 = sender.on ? 1 : 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vco1Panel.hidden = true
        lfo1Panel.hidden = true
        lfo2Panel.hidden = true
        filt1Panel.hidden = true
        env1Panel.hidden = true
        env2Panel.hidden = true
        vcaPanel.hidden = false
        
        let audioSession = AVAudioSession.sharedInstance()
        
        if audioSession.otherAudioPlaying {
            do {
                try audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
            } catch { print("Error1") }
        } else {
            do {
                try audioSession.setCategory(AVAudioSessionCategoryAmbient)
            } catch { print("Error2") }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleInterruption:",
            name: AVAudioSessionInterruptionNotification,
            object: nil)
        
        
        
        init_audio_state(&state)
        
//        lfo1Frequency.value = 2.0
//
//        filterCutoff.value = 2.0
//        
//        filterResonance.value = 2.0
//        
//        filterCutoffLFO1Modulation.value = 2.0
//        
//        filterCutoffChanged(filterCutoff)
//        filterResonanceChanged(filterResonance)
        
        restoreState()
        
         NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "saveState", userInfo: nil, repeats: true)
        
                
        //
        // http://stackoverflow.com/questions/1378765/how-do-i-create-a-basic-uibutton-programmatically
        //
        let button = PianoKey(type:.System)
        button.frame = CGRectMake(16.0, 280.0, 640, 128.0)
        button.numWhiteKeys = 16
        button.backgroundColor = UIColor.blackColor()
        view.addSubview(button)
        button.addTarget(self, action:"keyDown:event:", forControlEvents: .TouchDown)
        button.addTarget(self, action:"keySlide:event:", forControlEvents: .TouchDragInside)
//        button.addTarget(self, action:"keyDown:event:", forControlEvents: .TouchDragOutside)
        button.addTarget(self, action:"keyUp:", forControlEvents: .TouchUpInside)
        button.addTarget(self, action:"keyUp:", forControlEvents: .TouchUpOutside)
//        button.tag = octave[i]
        keys.append(button)
        
        togglePlay()
    }
    
    func frequencyFromNote(noteNumber: Int) -> Double {
        let middleC = 261.625565
        return pow(2.0, Double(noteNumber)/12.0)*middleC*0.25
    }
    
    func noteFromXY(x : CGFloat, y : CGFloat) -> Double {
        // Could it be a black key?
        let keyWidth = CGFloat(40.0)
        if y < 64.0 {
            let keyMask = [true, true, false, true, true, true, false, true]
            let blackKeyNumber = Int(floor((x-0.5*keyWidth)/keyWidth))
            if blackKeyNumber >= 0 {
                if keyMask[blackKeyNumber] {
                    let octave : [Int] = [0, 2, 4, 5, 7, 9, 11, 12]
                    let noteNumber = octave[blackKeyNumber]+1
                    return frequencyFromNote(noteNumber)
                }
            }
        }
        
        let keyNumber = Int(x/keyWidth)
        let octave : [Int] = [0, 2, 4, 5, 7, 9, 11, 12]
        let octaveNumber = keyNumber/7
        let noteNumber = octave[keyNumber%7]+12*octaveNumber
        return frequencyFromNote(noteNumber)
    }
    
    func keyDown(sender: PianoKey, event: UIEvent) -> Void{
        let touches = event.touchesForView(sender)
        let touch = touches!.first
        let touchPoint = touch!.locationInView(sender)
//        targetAmplitude = 1.0
        if traitCollection.forceTouchCapability == .Available {
            print("Touch pressure is \(touch!.force), maximum possible force is \(touch!.maximumPossibleForce)")
//            state.targetAmplitude = Double(touch!.force/touch!.maximumPossibleForce)
            state.gate = 1.0
        } else {
//            state.targetAmplitude = 1.0
            state.gate = 1.0
        }
        state.frequency = noteFromXY(touchPoint.x, y: touchPoint.y)
        print("frequency, gate=", state.frequency, state.gate)
    }
    
    func keySlide(sender: PianoKey, event: UIEvent) -> Void{
        let touches = event.touchesForView(sender)
        let touch = touches!.first
        print("Touch pressure is \(touch!.force), maximum possible force is \(touch!.maximumPossibleForce)")
        let touchPoint = touch!.locationInView(sender)
        if traitCollection.forceTouchCapability == .Available {
            print("Touch pressure is \(touch!.force), maximum possible force is \(touch!.maximumPossibleForce)")
//            state.targetAmplitude = Double(touch!.force/touch!.maximumPossibleForce)
            state.gate = 1.0
            print("down")
        } else {
//            state.targetAmplitude = 1.0
            state.gate = 1.0
            print("down")
        }
        state.frequency = noteFromXY(touchPoint.x, y: touchPoint.y)
//        print("frequency=", frequency)
    }
    
    func keyUp(sender: PianoKey) -> Void {
//        state.targetAmplitude = 0.0
        state.gate = 0.0;
//        print("Up", sender.tag)
        print("up")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    typealias Field = Lens<AudioState, Double>
    
//    @IBOutlet weak var envDelay: Knob!
//    @IBOutlet weak var envAttack: Knob!
//    @IBOutlet weak var envHold: Knob!
//    @IBOutlet weak var envDecay: Knob!
//    @IBOutlet weak var envSustain: Knob!
//    @IBOutlet weak var envRelease: Knob!
//    @IBOutlet weak var envRetrigger: Knob!

    
    var knobList : [(String, Knob, Field)]? = nil
    
    func knobs() -> [(String, Knob, Field)] {
        if knobList != nil {
            return knobList!
        }
        knobList = [
            //
            // ENV1
            //
            ("env1Delay", envDelay,
                Field(
                    set: {(inout a : AudioState, b) in a.envDecay.0 = b},
                    get: {a in return a.envDecay.0}
                )
            ),
            ("env1Attack", envAttack,
                Field(
                    set: {(inout a : AudioState, b) in a.envAttack.0 = b},
                    get: {a in return a.envAttack.0}
                )
            ),
            ("env1Hold", envHold,
                Field(
                    set: {(inout a : AudioState, b) in a.envHold.0 = b},
                    get: {a in return a.envHold.0}
                )
            ),
            ("env1Decay", envDecay,
                Field(
                    set: {(inout a : AudioState, b) in a.envDecay.0 = b},
                    get: {a in return a.envDecay.0}
                )
            ),
            ("env1Sustain", envSustain,
                Field(
                    set: {(inout a : AudioState, b) in a.envSustain.0 = b},
                    get: {a in return a.envSustain.0}
                )
            ),
            ("env1Release", envRelease,
                Field(
                    set: {(inout a : AudioState, b) in a.envRelease.0 = b},
                    get: {a in return a.envRelease.0}
                )
            ),
            ("env1Retrigger", envRetrigger,
                Field(
                    set: {(inout a : AudioState, b) in a.envRetrigger.0 = b},
                    get: {a in return a.envRetrigger.0}
                )
            ),
            
            //
            // LFO1
            //
            ("lfo1Frequency", lfo1Frequency,
                Field(
                    set: {(inout a : AudioState, b) in a.lfo_frequency.0 = b},
                    get: {a in return a.lfo_frequency.0}
                )
            ),
            ("lfo2Frequency", lfo2Frequency,
                Field(
                    set: {(inout a : AudioState, b) in a.lfo_frequency.1 = b},
                    get: {a in return a.lfo_frequency.1}
                )
            ),
            
            //
            // VCO1
            //
            ("vco1Detune", vco1Detune,
                Field(
                    set: {(inout a : AudioState, b) in a.vco1_detune = b},
                    get: {a in return a.vco1_detune}
                )
            ),
            ("vco1Number", vco1Number,
                Field(
                    set: {(inout a : AudioState, b) in a.vco1_number = Int32(b)},
                    get: {a in return Double(a.vco1_number)}
                )
            ),
            ("vco1Spread", vco1Spread,
                Field(
                    set: {(inout a : AudioState, b) in a.vco1_spread = b},
                    get: {a in return a.vco1_spread}
                )
            ),
            ("vco1Lfo1Modulation", vco1Lfo1Modulation,
                Field(
                    set: {(inout a : AudioState, b) in a.vco1_lfo1_modulation = b},
                    get: {a in return a.vco1_lfo1_modulation}
                )
            ),
            
            //
            // LPF
            //
            ("lpfCutoff", filterCutoff,
                Field(
                    set: {(inout a : AudioState, b) in a.filter_cutoff = b},
                    get: {a in return a.filter_cutoff}
                )
            ),
            ("lpfResonance", filterResonance,
                Field(
                    set: {(inout a : AudioState, b) in a.filter_resonance = b},
                    get: {a in return a.filter_resonance}
                )
            ),
            ("lpfLfo1Modulation", filterCutoffLFO1Modulation,
                Field(
                    set: {(inout a : AudioState, b) in a.filter_cutoff_env_modulation.0 = b},
                    get: {a in return a.filter_cutoff_env_modulation.0}
                )
            ),
            ("lpfLfo2Modulation", filterCutoffLFO2Modulation,
                Field(
                    set: {(inout a : AudioState, b) in a.filter_cutoff_env_modulation.1 = b},
                    get: {a in return a.filter_cutoff_env_modulation.1}
                )
            )
        ]
        
        return knobList!
    }
    
    func saveState() {
        let saveFile = "save.dat"
        
        let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        
        let savePath = dir.stringByAppendingPathComponent(saveFile)
        
        var saveDict = Dictionary<String, AnyObject>()

        for (name, knob, _) in knobs() {
            saveDict[name] = knob.value
//            print("Saved \(name) as \(knob.value)")

        }
        //
        // LPF
        //
//        saveDict["lpfCutoff"] = filterCutoff.value
//        saveDict["lpfResonance"] = filterResonance.value
//        saveDict["lpfLfo1Modulation"] = filterCutoffLFO1Modulation
//        saveDict["lpfLfo2Modulation"] = filterCutoffLFO2Modulation.value
        
        //
        // VCA
        //
        saveDict["vcaEnv2Switch"] = vcaEnv2Switch.on
        saveDict["vcaLfo1Modulation"] = vcaLfo1Modulation.value
        saveDict["vcaLfo2Modulation"] = vcaLfo2Modulation.value
        
        NSKeyedArchiver.archiveRootObject(saveDict, toFile: savePath)
        
        print("Saved")
    }
    
    func restoreState() { // XXX Needs to restore graph
        let saveFile = "save.dat"
        
        let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        
        let savePath = dir.stringByAppendingPathComponent(saveFile)
        
        if let saveDict = NSKeyedUnarchiver.unarchiveObjectWithFile(savePath) as? Dictionary<String, AnyObject> {
            
            for (name, knob, field) in knobs() {
                if let value = saveDict[name] as? CGFloat {
                    knob.value = value
                    field.set(&state, Double(value))
                    print("Setting \(name) to \(value)")
                }
            }
            
            //
            // LPF
            //
//            if let lpfCutoffValue = saveDict["lpfCutoff"] as? CGFloat {
//                filterCutoff.value = lpfCutoffValue
//                state.filter_cutoff = Double(lpfCutoffValue)
//            }
//            if let lpfResonanceValue = saveDict["lpfResonance"] as? CGFloat {
//                filterResonance.value = lpfResonanceValue
//                state.filter_resonance = Double(lpfResonanceValue)
//            }
//            if let lpfLfo1ModulationValue = saveDict["vcaLfo1Modulation"] as? CGFloat {
//                vcaLfo1Modulation.value = lpfLfo1ModulationValue
//                state.filter_cutoff_env_modulation.0 = Double(lpfLfo1ModulationValue)
//            }
//            if let lpfLfo2ModulationValue = saveDict["vcaLfo2Modulation"] as? CGFloat {
//                vcaLfo2Modulation.value = lpfLfo2ModulationValue
//                state.filter_cutoff_env_modulation.1 = Double(lpfLfo2ModulationValue)
//            }

            //
            // VCA
            //
            if let vcaEnv2SwitchValue = saveDict["vcaEnv2Switch"] as? Bool {
                vcaEnv2Switch.on = vcaEnv2SwitchValue
                state.vcaEnv2 = vcaEnv2SwitchValue ? 1 : 0
            }
            if let vcaLfo1ModulationValue = saveDict["vcaLfo1Modulation"] as? CGFloat {
                vcaLfo1Modulation.value = vcaLfo1ModulationValue
                // XXX Doesn't exist yet
            }
            if let vcaLfo2ModulationValue = saveDict["vcaLfo2Modulation"] as? CGFloat {
                vcaLfo2Modulation.value = vcaLfo2ModulationValue
                // XXX Doesn't exist yet
            }
        }
    }
    
    //
    // Needs testing
    //
    func handleInterruption(player: AVAudioPlayer) {
        print("Hello")
        stop()
    }
    
    @IBAction func waveformSelectorChanged(sender: MultiButton) {
        print("Button!")
        state.oscType = OscType(UInt32(sender.selectedButton))
    }
    func getAudioComponentDescription() -> AudioComponentDescription {
        return AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kAudioUnitSubType_RemoteIO,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0
        )
    }
    
    func getAudioStreamBasicDescription() -> AudioStreamBasicDescription {
        let sizeofFloat = UInt32(sizeof(Float))
        return AudioStreamBasicDescription(
                    mSampleRate: sampleRate,
                    mFormatID: kAudioFormatLinearPCM,
                    mFormatFlags: kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved,
                    mBytesPerPacket: sizeofFloat,
                    mFramesPerPacket: 1,
                    mBytesPerFrame: sizeofFloat,
                    mChannelsPerFrame: 1,
                    mBitsPerChannel: sizeofFloat * 8,
                    mReserved: 0)
    }
    
    func getDefaultOutput() -> AudioComponent {
        //
        // http://hondrouthoughts.blogspot.com/2014/09/livecoding-with-swift-audio-continued.html
        //
        var defaultOutputDescription = getAudioComponentDescription()
        
        let defaultOutput : AudioComponent = AudioComponentFindNext(nil, &defaultOutputDescription)
        print("defaultOutput=", defaultOutput)
        return defaultOutput
    }
    
    //
    // http://stackoverflow.com/questions/32290485/audiotoolbox-c-function-pointers-and-swift
    //
    func setCallback() -> Void {
        var input = AURenderCallbackStruct(inputProc: audio_render, inputProcRefCon: &state)
//        var input = AURenderCallbackStruct(inputProc: sampleShader, inputProcRefCon: UnsafeMutablePointer<Void>(unsafeAddressOf(self)))
        
        let err = AudioUnitSetProperty(
            gen,
            kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0,
            &input,
            UInt32(sizeof(input.dynamicType)))
            print("callback set err=", err)
    
        print("Creation err =", err)
    }
    
    func setFormat() -> Void {
        var streamFormat = getAudioStreamBasicDescription()
        let err = AudioUnitSetProperty(
            gen,
            kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0,
            &streamFormat, UInt32(sizeof(AudioStreamBasicDescription)))
        print("format err=", err)
        
    }
    
    func genCreate() -> Void {
        let defaultOutput = getDefaultOutput()
        AudioComponentInstanceNew(defaultOutput, &gen);
        setCallback()
        setFormat()
    }
    
    func togglePlay() {
        if gen != nil {
            AudioOutputUnitStop(gen)
            AudioUnitUninitialize(gen)
            AudioComponentInstanceDispose(gen)
            gen = nil;
            
//            selectedButton.setTitle("Off", forState: UIControlState(rawValue:0))
        } else {
            genCreate()
            
            var err = AudioUnitInitialize(gen);
            print("Init err =", err)
            
            err = AudioOutputUnitStart(gen);
            print("Start err=", err)
        }
    }
    
    func stop() -> Void {
        if gen != nil {
            togglePlay()
        }
    }
    
}

