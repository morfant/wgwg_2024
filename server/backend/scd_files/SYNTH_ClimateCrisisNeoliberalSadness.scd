(
SynthDef(\ClimateCrisisNeoliberalSadness, {
    |out=0, amp=0.5|
    var freq1, freq2, env, sig;
    freq1 = Demand.kr(
        Impulse.kr(10), 0, 
        Dseq([60, 63, 67, 70, 72, 75, 78, 81, 83, 87, 90, 93, 95, 98, 101, 103, 107, 110, 113, 115], inf)
    ).midicps;
    freq2 = Demand.kr(
        Impulse.kr(9), 0, 
        Dseq([72, 75, 78, 81, 83, 87, 90, 93, 95, 98, 101, 103, 107, 110, 113, 115, 118, 120, 123, 125], inf)
    ).midicps;

    env = EnvGen.kr(Env.perc(0.01, 0.4), doneAction: 2);
    sig = Mix([SinOsc.ar(freq1), SinOsc.ar(freq2)]) * env * amp;
    sig = Pan2.ar(sig, 0, amp);
    Out.ar(out, sig);
}).add;
)

// Pdef
(
Pdef(\ClimateCrisisNeoliberalSadness, Pbind(
    \instrument, \ClimateCrisisNeoliberalSadness,
    \dur, Pseq([0.3, 0.4, 0.2, 0.5, 0.35, 0.25, 0.3, 0.45, 0.4, 0.3, 0.35, 0.2, 0.5, 0.25, 0.3], inf),
    \amp, -6.dbamp,
)).play;
)