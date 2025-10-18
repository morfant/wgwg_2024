(
SynthDef(\cozyHouseSynth, {
    |out=100, amp=0.5, pan=0|
    var sig, env;
    // Local variables
    var freq, harmonics, reverb;
    
    // Frequency and harmonics for rich additive synthesis
    freq = [220, 440, 660, 880];
    harmonics = Mix(SinOsc.ar(freq) * [0.5, 0.25, 0.125, 0.0625]);
    
    // Envelope
    env = EnvGen.kr(Env.perc(0.01, 1), doneAction: 2);

    // Final signal
    sig = harmonics * env * amp;
    sig = sig * (-6.dbamp); // Final amplitude around -6dB
    
    // Reverberation
    reverb = FreeVerb.ar(sig, mix: 0.8);

    // Panning
    sig = Pan2.ar(reverb, pan);

    // Output to bus
    Out.ar(out, sig);
}).add;

Pdef(\cozyHouseSynth, Pbind(
    \instrument, \cozyHouseSynth,
    \dur, Pseq([0.1, 0.2, 0.3, 0.4], inf), // Duration pattern
    \freq, Pseq([220, 330, 440, 550, 660, 770, 880], inf), // Frequency pattern
    \amp, 0.5, // Amplitude
    \pan, 0, // Stable panning
    \out, 100, // Output bus
    \legato, 0.8 // Legato to make transitions smoother
)).play;
)