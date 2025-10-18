(
SynthDef("ClimateCrisisNeolibJoy", {
    |out=0, freq=440, amp=0.5, pan=0|
    var sig, env;
    
    env = EnvGen.kr(Env.perc(0.01, 0.3), doneAction: 2);
    sig = Mix.fill(10, { 
        SinOsc.ar(freq * (1 + LFNoise1.kr(0.5).range(0.01, 0.05)), 0, amp / 10)
    });
    sig = sig * env;
    sig = Pan2.ar(sig, pan);
    
    Out.ar(out, sig);
}).add;

Pdef(\ClimateCrisisNeolibJoy, Pbind(
    \instrument, \ClimateCrisisNeolibJoy,
    \dur, Pseq((0.2..0.5).scramble, 20),
    \freq, Pseq((1..50).collect{ |i| (i + 50).midicps }, 20),
    \amp, 0.5,
    \pan, 0,
    \scale, Scale.minor
)).play;
)