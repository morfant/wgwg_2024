(
SynthDef(\CapitalismPositiveAspect, {
    var env, freq, amp, pan, sig, trig;
    
    // Envelope
    env = EnvGen.kr(Env.new([0, 1, 0.7, 0], [0.01, 0.18, 0.01], 'sine'), doneAction: 2);
    
    // Frequency sequence
    freq = Demand.ar(Dust.ar(8), 0, Drand([220, 330, 440, 550, 660, 770, 880], inf));
    
    // Amplitude
    amp = 0.3 * env; // Adjust amplitude to about -6dB
    
    // Panning
    pan = SinOsc.kr(0.1).range(-1, 1);
    
    // Synthesis
    sig = Mix.fill(5, { SinOsc.ar(freq * [1, 1.5, 2], 0, amp) });
    sig = sig + Mix.fill(5, { SinOsc.ar(freq * [0.5, 0.75, 1.25], 0, amp) });
    
    // Apply panning
    sig = Pan2.ar(sig, pan);
    
    // Output
    Out.ar(0, sig);
}).add;

// Play the Synth
x = Synth(\CapitalismPositiveAspect);
)