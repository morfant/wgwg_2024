(
SynthDef(\ColdPersonsWayOfLoveClimateChange, {
    |out=100, amp=0.5, pan=0, freq=440, sustain=1|
    var sig, env;
    
    // Choose Waveshaping synthesis method
    var osc = SinOsc.ar(freq) * 0.2 + Saw.ar(freq * 1.5) * 0.3;
    sig = osc.clip2(0.5) * 0.8; // Waveshaping
    
    // Envelope
    env = EnvGen.kr(Env.perc(0.01, sustain), doneAction: 2);
    
    // Apply reverb
    sig = FreeVerb.ar(sig, mix: 0.8);
    
    // Pan and output
    sig = Pan2.ar(sig, pan) * env * amp;
    Out.ar(out, sig);
}).add;

Pdef(\ColdPersonsWayOfLoveClimateChange, Pbind(
    \instrument, \ColdPersonsWayOfLoveClimateChange,
    \dur, Pseq([0.25, 0.5, 0.75, 1], inf),
    \freq, Pseq([440, 550, 660, 770, 880, 990].scramble, 20),
    \amp, 0.5,
    \pan, 0,
    \sustain, Pseq([0.2, 0.5, 1], inf),
    \out, 100
)).play;
)