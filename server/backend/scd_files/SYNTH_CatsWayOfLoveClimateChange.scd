(
SynthDef(\CatsWayOfLoveClimateChange, {
    |out=100, amp=0.5, pan=0, freq=440, revLevel=0.2|
    var sig, env, reverb;
    
    // Main synthesis method: Rich Additive
    sig = Mix.fill(10, { SinOsc.ar(freq * (1..10), 0, 0.1) });
    
    // Envelope for amplitude control
    env = EnvGen.kr(Env.perc(0.01, 1), doneAction: 2);
    
    // Apply reverb
    reverb = FreeVerb.ar(sig * env, mix: revLevel);
    
    // Pan and output
    Out.ar(out, Pan2.ar(reverb, pan, amp));
}).add;

Pdef(\CatsWayOfLoveClimateChange, Pbind(
    \instrument, \CatsWayOfLoveClimateChange,
    \dur, Pseq([0.2, 0.3, 0.25, 0.15], 20),
    \freq, Pseq([400, 450, 500, 550, 600, 650, 700, 750], 20),
    \amp, 0.5,
    \pan, 0,  // Stable panning
    \revLevel, 0.2
)).play;
)