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
    let set: (inout A, B) -> ()
    let get: A -> B
}

struct Bound<B> {
    let set: B -> ()
    let get: () -> B
}

//class KnobSpecification {
////    let name: String;
//    var uiKnob: Knob!
//
//    init(knob: Knob) {
//        uiKnob = knob
//    }
//    
////    init(name: String) {
////        self.name = name
////    }
//}

//
// http://www.cocoawithlove.com/2010/10/ios-tone-generator-introduction-to.html
//
// http://stackoverflow.com/questions/1135163/how-do-i-use-uiscrollview-in-interface-builder
// https://grokswift.com/custom-fonts/
// https://github.com/HeshamMegid/HMSegmentedControl/blob/master/HMSegmentedControl/HMSegmentedControl.m
//
class ViewController: UIViewController { // , UIPopoverPresentationController {
    
    
    var idToKnob: [String: Knob] = [:]

    @IBOutlet var knobs: [Knob]!
    
    @IBOutlet weak var vco1Panel: UIView!
    @IBOutlet weak var lfo1Panel: UIView!
    @IBOutlet weak var lfo2Panel: UIView!
    @IBOutlet weak var filt1Panel: UIView!
    @IBOutlet weak var env1Panel: UIView!
    @IBOutlet weak var env2Panel: UIView!
    @IBOutlet weak var vcaPanel: UIView!
    @IBOutlet weak var env1Graph: ADSRPlot!
    @IBOutlet weak var env2Graph: ADSRPlot!
    
    // LFO
//    @IBOutlet weak var lfo1Frequency: Knob!
//    @IBOutlet weak var lfo2Frequency: Knob!
    @IBOutlet weak var lfo1Type: MultiButton!
    @IBOutlet weak var lfo2Type: MultiButton!
    
    //
    // VCO1
    //
    @IBOutlet weak var waveformSelector: MultiButton!
    
    //
    // LPF
    //
    @IBOutlet weak var lpfFrequencyModulationSource: UILabel!
    @IBOutlet weak var lpfResonanceModulationSource: UILabel!
    
    //
    // ENV1
    //
    
    //
    // ENV2
    //
    
    //
    // VCA
    //
    @IBOutlet weak var vcaEnv2Switch: UISwitch!
    @IBOutlet weak var vcaModulationSource: UILabel!
    
    @IBOutlet weak var meter: VUMeter!
    @IBOutlet weak var scope: Scope!
    
    var gen : AudioComponentInstance = nil

    var sampleRate : Double = 44100.0
    
    var state = AudioState()
    
    var keys : [UIButton] = [UIButton]()
    
    @IBAction func lfoTypeChanged(sender: MultiButton) {
        switch sender.tag {
        case 0:
            state.uiState.lfoType.0 = LfoType(UInt32(sender.selectedButton))
        case 1:
            state.uiState.lfoType.1 = LfoType(UInt32(sender.selectedButton))
        default: break
        }
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
    
    //
    // LFO
    //
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
    
    //
    // VCA
    //
    @IBAction func vcaEnv2(sender: UISwitch) {
        state.uiState.vcaEnv2 = sender.on ? 1 : 0
    }
    
    func doReset() -> Void {
        print("reset")
    }
    
    func doReverse() -> Void {
        print("reverse")
    }
    
    func sourceChanged(sender: UILongPressGestureRecognizer,
                                 label: UILabel,
                                 field: Bound<Source>) {
        print("change", sender, "view=",sender.view)
        print(sender.state)
        switch sender.state {
        case .Began:
            print("Began")
            
            
            let window = UIApplication.sharedApplication().keyWindow
            if window?.rootViewController?.presentedViewController == nil {
                
                let alertController = UIAlertController(title: "LPF Frequency Modulation",
                    message: "Choose Source",
                    preferredStyle: .ActionSheet)
                
                for (title, action, style) in [
                    ("LFO1", {
                        () -> Void in
                        label.text = "LFO1"
                        field.set(SOURCE_LFO1)
                        }, UIAlertActionStyle.Default),
                    ("LFO2", {
                        () -> Void in
                        label.text = "LFO2"
                        field.set(SOURCE_LFO2)
                        }, .Default),
                    ("ENV1", {
                        () -> Void in
                        label.text = "ENV1"
                        field.set(SOURCE_ENV1)
                        }, UIAlertActionStyle.Default),
                    ("ENV2", {
                        () -> Void in
                        label.text = "ENV2"
                        field.set(SOURCE_ENV2)
                        }, .Default),
                    ("Cancel", {() -> Void in  }, .Cancel)] {
                        let resetAction = UIAlertAction(title: title, style: style) {
                            (_) in
                            action()
                        }
                        alertController.addAction(resetAction)
                        
                }
                
                let popover = alertController.popoverPresentationController
                if (popover != nil) {
                    popover!.delegate = self
                    popover!.sourceView = sender.view
                    popover!.sourceRect = sender.view!.bounds
                    popover!.permittedArrowDirections = .Any
                }
                
                // Slight behaviour difference on iPad
                //            if let controller = alertController.popoverPresentationController {
                //                controller.barButtonItem = sender
                //            }
                
                window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            }
            
            
        case .Ended:
            print("Ended")
        default:
            print("...")
        }
    }
    
    @IBAction func lpfResonanceSourceChanged(sender: UILongPressGestureRecognizer) {
        let lens = Bound<Source>(
            set: {(b : Source) in
                self.state.uiState.filter_resonance_modulation_source = b },
            get: {() in
                return self.state.uiState.filter_resonance_modulation_source }
        )
        sourceChanged(sender, label: self.lpfResonanceModulationSource, field: lens)
    }
    
    @IBAction func lpfCutoffSourceChanged(sender: UILongPressGestureRecognizer) {
        let lens = Bound<Source>(
                set: {(b : Source) in
                    self.state.uiState.filter_cutoff_modulation_source = b },
                get: {() in
                    return self.state.uiState.filter_cutoff_modulation_source }
            )
        sourceChanged(sender, label: self.lpfFrequencyModulationSource, field: lens)
    }
    
    @IBAction func vcaModulationSourceChanged(sender: UILongPressGestureRecognizer) {
        let lens = Bound<Source>(
            set: {(b : Source) in
                self.state.uiState.vca_modulation_source = b },
            get: {() in
                return self.state.uiState.vca_modulation_source }
        )
        sourceChanged(sender, label: self.vcaModulationSource, field: lens)
    }
    
    @IBAction func knobChanged(sender: Knob) {
        knobDescriptions()[sender.id]!.1.set(Double(sender.value))
        print("Setting", sender.id)
    }
    
    typealias Field = Bound<Double>
    var knobList : [String: (Knob, Field)] = [:]
    func knobDescriptions() -> [String: (Knob, Field)] {
        if knobList.count != 0 {
            return knobList
        }
        let knobList2 = [
            //
            // ENV1
            //
            "env1Delay": (
                Field(
                    set: {b in
                        self.state.uiState.envDecay.0 = b
                        self.env1Graph.delay = CGFloat(b)
                        self.env1Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envDecay.0}
                )
            ),
            "env1Attack": (
                Field(
                    set: {b in
                        self.state.uiState.envAttack.0 = b
                        self.env1Graph.attack = CGFloat(b)
                        self.env1Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envAttack.0}
                )
            ),
            "env1Hold": (
                Field(
                    set: {b in
                        self.state.uiState.envHold.0 = b
                        self.env1Graph.hold = CGFloat(b)
                        self.env1Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envHold.0}
                )
            ),
            "env1Decay": (
                Field(
                    set: {b in
                        self.state.uiState.envDecay.0 = b
                        self.env1Graph.decay = CGFloat(b)
                        self.env1Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envDecay.0}
                )
            ),
            "env1Sustain": (
                Field(
                    set: {b in
                        self.state.uiState.envSustain.0 = b
                        self.env1Graph.sustain = CGFloat(b)
                        self.env1Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envSustain.0}
                )
            ),
            "env1Release": (
                Field(
                    set: {b in
                        self.state.uiState.envRelease.0 = b
                        self.env1Graph.release_ = CGFloat(b)
                        self.env1Graph.setNeedsDisplay()
                    },
                    get: {a in return self.state.uiState.envRelease.0}
                )
            ),
            "env1Retrigger": (
                Field(
                    set: {b in
                        self.state.uiState.envRetrigger.0 = b
                        self.env1Graph.retrigger = CGFloat(b)
                        self.env1Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envRetrigger.0}
                )
            ),
            
            //
            // ENV2
            //
            "env2Delay": (
                Field(
                    set: {b in
                        self.state.uiState.envDecay.1 = b
                        self.env2Graph.delay = CGFloat(b)
                        self.env2Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envDecay.1}
                )
            ),
            "env2Attack": (
                Field(
                    set: {b in
                        self.state.uiState.envAttack.1 = b
                        self.env2Graph.attack = CGFloat(b)
                        self.env2Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envAttack.1}
                )
            ),
            "env2Hold": (
                Field(
                    set: {b in
                        self.state.uiState.envHold.1 = b
                        self.env2Graph.hold = CGFloat(b)
                        self.env2Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envHold.1}
                )
            ),
            "env2Decay": (
                Field(
                    set: {b in
                        self.state.uiState.envDecay.1 = b
                        self.env2Graph.decay = CGFloat(b)
                        self.env2Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envDecay.1}
                )
            ),
            "env2Sustain": (
                Field(
                    set: {b in
                        self.state.uiState.envSustain.1 = b
                        self.env2Graph.sustain = CGFloat(b)
                        self.env2Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envSustain.1}
                )
            ),
            "env2Release": (
                Field(
                    set: {b in
                        self.state.uiState.envRelease.1 = b
                        self.env2Graph.release_ = CGFloat(b)
                        self.env2Graph.setNeedsDisplay()
                    },
                    get: {a in return self.state.uiState.envRelease.1}
                )
            ),
            "env2Retrigger": (
                Field(
                    set: {b in
                        self.state.uiState.envRetrigger.1 = b
                        self.env2Graph.retrigger = CGFloat(b)
                        self.env2Graph.setNeedsDisplay()
                    },
                    get: {return self.state.uiState.envRetrigger.1}
                )
            ),
            
            //
            // LFO1
            //
            "lfo1Frequency": (
                Field(
                    set: {b in self.state.uiState.lfo_frequency.0 = b},
                    get: {return self.state.uiState.lfo_frequency.0}
                )
            ),
            "lfo2Frequency": (
                Field(
                    set: {b in self.state.uiState.lfo_frequency.1 = b},
                    get: {return self.state.uiState.lfo_frequency.1}
                )
            ),
            
            //
            // VCO1
            //
            "vco1Detune": (
                Field(
                    set: {b in self.state.uiState.vco1_detune = b},
                    get: {return self.state.uiState.vco1_detune}
                )
            ),
            "vco1Number": (
                Field(
                    set: {b in self.state.uiState.vco1_number = Int32(b)},
                    get: {return Double(self.state.uiState.vco1_number)}
                )
            ),
            "vco1Spread": (
                Field(
                    set: {b in self.state.uiState.vco1_spread = b},
                    get: {return self.state.uiState.vco1_spread}
                )
            ),
            "vco1Lfo1Modulation": (
                Field(
                    set: {b in self.state.uiState.vco1_lfo1_modulation = b},
                    get: {return self.state.uiState.vco1_lfo1_modulation}
                )
            ),
            "vco1SyncRatio": (
                Field(
                    set: {b in self.state.uiState.vco1SyncRatio = b},
                    get: {return self.state.uiState.vco1SyncRatio}
                )
            ),
            
            //
            // LPF
            //
            "lpfCutoff": (
                Field(
                    set: {b in self.state.uiState.filter_cutoff = b},
                    get: {return self.state.uiState.filter_cutoff}
                )
            ),
            "lpfResonance": (
                Field(
                    set: {b in self.state.uiState.filter_resonance = b},
                    get: {return self.state.uiState.filter_resonance}
                )
            ),
            "lpfCutoffModulation": (
                Field(
                    set: {b in self.state.uiState.filter_cutoff_modulation = b},
                    get: {return self.state.uiState.filter_cutoff_modulation}
                )
            ),
            "lpfResonanceModulation": (
                Field(
                    set: {b in self.state.uiState.filter_resonance_modulation = b},
                    get: {return self.state.uiState.filter_resonance_modulation}
                )
            ),
            
            //
            // VCA
            //
            "vcaModulation": (
                Field(
                    set: {b in self.state.uiState.vca_modulation = b},
                    get: {return self.state.uiState.vca_modulation}
                )
            ),
            "vcaLevel": (
                Field(
                    set: {b in self.state.uiState.vca_level = b},
                    get: {return self.state.uiState.vca_modulation}
                )
            )
        ]
        
        for (name, field) in knobList2 {
            print("name=", name)
            knobList[name] = (idToKnob[name]!, field)
        }
        return knobList
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("count=",knobs.count)
    
        for i in 0..<knobs.count {
            print("Installing knob", knobs[i].id)
            idToKnob[knobs[i].id] = knobs[i]
        }
        
        // Works! But set up correctly
        let lpr = UILongPressGestureRecognizer(target: self, action: "lpfResonanceSourceChanged:")
        lpr.minimumPressDuration = 1.0
        idToKnob["env1Delay"]?.addGestureRecognizer(lpr)
        
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
        
        meter.controller = self
        scope.controller = self
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleInterruption:",
            name: AVAudioSessionInterruptionNotification,
            object: nil)
        
        waveformSelector.icons = [.Sine, .Square, .Saw]
        lfo1Type.icons = [.Sine, .Square, .Saw, .Rand]
        lfo2Type.icons = [.Sine, .Square, .Saw, .Rand]
        
        init_audio_state(&state)
        
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
        button.addTarget(self, action:"keyUp:", forControlEvents: .TouchUpInside)
        button.addTarget(self, action:"keyUp:", forControlEvents: .TouchUpOutside)
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
            state.uiState.gate = 1.0
        } else {
//            state.targetAmplitude = 1.0
            state.uiState.gate = 1.0
        }
        state.uiState.frequency = noteFromXY(touchPoint.x, y: touchPoint.y)
        print("frequency, gate=", state.uiState.frequency, state.uiState.gate)
    }
    
    func keySlide(sender: PianoKey, event: UIEvent) -> Void{
        let touches = event.touchesForView(sender)
        let touch = touches!.first
        print("Touch pressure is \(touch!.force), maximum possible force is \(touch!.maximumPossibleForce)")
        let touchPoint = touch!.locationInView(sender)
        if traitCollection.forceTouchCapability == .Available {
            print("Touch pressure is \(touch!.force), maximum possible force is \(touch!.maximumPossibleForce)")
//            state.targetAmplitude = Double(touch!.force/touch!.maximumPossibleForce)
            state.uiState.gate = 1.0
            print("down")
        } else {
//            state.targetAmplitude = 1.0
            state.uiState.gate = 1.0
            print("down")
        }
        state.uiState.frequency = noteFromXY(touchPoint.x, y: touchPoint.y)
//        print("frequency=", frequency)
    }
    
    func keyUp(sender: PianoKey) -> Void {
//        state.targetAmplitude = 0.0
        state.uiState.gate = 0.0;
//        print("Up", sender.tag)
        print("up")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    typealias BoolField = Lens<AudioState, Bool>
    var switchList : [(String, UISwitch, BoolField)]? = nil
    func switches() -> [(String, UISwitch, BoolField)] {
        if switchList != nil {
            return switchList!
        }
        switchList = [
            ("vcaEnv2Switch", vcaEnv2Switch,
                BoolField(
                    set: {(inout a : AudioState, b : Bool) in a.uiState.vcaEnv2 = b ? 1 : 0 },
                    get: {(a : AudioState) in return a.uiState.vcaEnv2 == 0 ? false : true }
                )
            )
        ]
        
        return switchList!
    }
    
    
    typealias IntField = Lens<AudioState, Int>
    var multiButtonList : [(String, MultiButton, IntField)]? = nil
    func multibuttons() -> [(String, MultiButton, IntField)] {
        if multiButtonList != nil {
            return multiButtonList!
        }
        multiButtonList = [
            ("vco1Waveform", waveformSelector,
                IntField(
                    set: {(inout a : AudioState, b) in
                        a.uiState.vcoType = [VCO_TYPE_SINE, VCO_TYPE_SQUARE, VCO_TYPE_SAW][b]
                    },
                    get: {(a : AudioState) in
                        switch a.uiState.vcoType {
                        case VCO_TYPE_SINE:
                            return 0
                        case VCO_TYPE_SQUARE:
                            return 1
                        case VCO_TYPE_SAW:
                            return 2
                        default:
                            return 0
                        }
                    }
                )
            ),
            ("lfo1Waveform", lfo1Type,
                IntField(
                    set: {(inout a : AudioState, b) in
                        a.uiState.lfoType.0 = [LFO_TYPE_SINE, LFO_TYPE_SQUARE, LFO_TYPE_SAW, LFO_TYPE_RAND][b]
                    },
                    get: {(a : AudioState) in
                        switch a.uiState.lfoType.0 {
                        case LFO_TYPE_SINE:
                            return 0
                        case LFO_TYPE_SQUARE:
                            return 1
                        case LFO_TYPE_SAW:
                            return 2
                        case LFO_TYPE_RAND:
                            return 2
                        default:
                            return 0
                        }
                    }
                )
            )
        ]
        
        return multiButtonList!
    }
    
    func saveState() {
        let saveFile = "save.dat"
        
        let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        
        let savePath = dir.stringByAppendingPathComponent(saveFile)
        
        var saveDict = Dictionary<String, AnyObject>()

        for (name, (knob, _)) in knobDescriptions() {
            saveDict[name] = knob.value
            
        }
        
        for (name, multibutton, _) in multibuttons() {
            saveDict[name] = multibutton.selectedButton
        }
        
        for (name, switch_, _) in switches() {
            saveDict[name] = switch_.on
        }
        
        //
        // VCA
        //
        saveDict["vcaEnv2Switch"] = vcaEnv2Switch.on
        saveDict["vcaModulationSource"] = Int(state.uiState.vca_modulation_source.rawValue)
        saveDict["lpfCutoffModulationSource"] = Int(state.uiState.filter_cutoff_modulation_source.rawValue)
        saveDict["lpfResonanceModulationSource"] = Int(state.uiState.filter_resonance_modulation_source.rawValue)
//        saveDict["vcaLfo1Modulation"] = vcaLfo1Modulation.value
//        saveDict["vcaLfo2Modulation"] = vcaLfo2Modulation.value
        
        NSKeyedArchiver.archiveRootObject(saveDict, toFile: savePath)
        
        print("Saved")
    }
    
    func sourceName(source: Source) -> String {
        switch source {
        case SOURCE_LFO1:
            return "LFO1"
        case SOURCE_LFO2:
            return "LFO2"
        case SOURCE_ENV1:
            return "ENV1"
        case SOURCE_ENV2:
            return "ENV2"
        default:
            return "<ERROR>"
        }
    }
    
    func restoreState() { // XXX Needs to restore graph
        let saveFile = "save.dat"
        
        let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        
        let savePath = dir.stringByAppendingPathComponent(saveFile)
        
        if let saveDict = NSKeyedUnarchiver.unarchiveObjectWithFile(savePath) as? Dictionary<String, AnyObject> {
            
            for (name, (knob, field)) in knobDescriptions() {
                if let value = saveDict[name] as? CGFloat {
                    knob.value = value
                    field.set(Double(value))
                    print("Setting \(name) to \(value)")
                }
            }
            
            for (name, multibutton, field) in multibuttons() {
                if let value = saveDict[name] as? Int {
                    multibutton.selectedButton = value
                    field.set(&state, value)
                    print("Setting \(name) to \(value)")
                }
            }
            
            for (name, switch_, field) in switches() {
                if let value = saveDict[name] as? Bool {
                    switch_.on = value
                    field.set(&state, value)
                    print("Setting \(name) to \(value)")
                }
            }
            
            //
            // VCA
            //
            if let vcaEnv2SwitchValue = saveDict["vcaEnv2Switch"] as? Bool {
                vcaEnv2Switch.on = vcaEnv2SwitchValue
                state.uiState.vcaEnv2 = vcaEnv2SwitchValue ? 1 : 0
            }
            if let vcaModulationSourceValue = saveDict["vcaModulationSource"] as? Int {
                state.uiState.vca_modulation_source = Source(rawValue: UInt32(vcaModulationSourceValue))
                self.vcaModulationSource.text = sourceName(state.uiState.vca_modulation_source)
            }
            if let lpfCutoffModulationSourceValue = saveDict["lpfCutoffModulationSource"] as? Int {
                state.uiState.filter_cutoff_modulation_source = Source(rawValue: UInt32(lpfCutoffModulationSourceValue))
                self.lpfFrequencyModulationSource.text = sourceName(state.uiState.filter_cutoff_modulation_source)
            }
            if let lpfResonanceModulationSourceValue = saveDict["lpfResonanceModulationSource"] as? Int {
                state.uiState.filter_resonance_modulation_source = Source(rawValue: UInt32(lpfResonanceModulationSourceValue))
                self.lpfResonanceModulationSource.text = sourceName(state.uiState.filter_resonance_modulation_source)
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
        state.uiState.vcoType = VcoType(UInt32(sender.selectedButton))
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

extension ViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
//        // try swapping these; it works
//        if traitCollection.horizontalSizeClass == .Compact {
//            return .FullScreen
//            // return .None
//        }
        print("NONE!!!!!!!!!!!!!!!!!!!!!!!!!")
        return .None
    }
    
//    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
//        NSUserDefaults.standardUserDefaults().setInteger(self.oldChoice, forKey: "choice")
//    }
    
}

