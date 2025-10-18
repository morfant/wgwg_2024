(
SynthDef(\ClimateCrisisNeoliberalSorrow, {
    var freq1, freq2, env, osc1, osc2, mix, pan;
    freq1 = [50, 52, 53, 55, 57, 60, 62, 63, 65, 67, 70, 72, 74, 75, 77].midicps;
    freq2 = [62, 63, 65, 67, 70, 72, 74, 75, 77, 79, 82, 84, 86, 87, 89].midicps;
    env = EnvGen.kr(Env.perc(0.01, 0.4), doneAction: 2);
    osc1 = Mix.fill(10, { SinOsc.ar(Demand.kr(Impulse.kr(1), 0, Dseq(freq1, 1)), 0, 0.1) });
    osc2 = Mix.fill(10, { SinOsc.ar(Demand.kr(Impulse.kr(1), 0, Dseq(freq2, 1)), 0, 0.1) });
    mix = (osc1 + osc2) * env;
    pan = Pan2.ar(mix, 0, 0.5).dup;
    Out.ar(0, pan * -6.dbamp);
}).add;
)

(
Pdef(\ClimateCrisisNeoliberalSorrow, Pbind(
    \instrument, \ClimateCrisisNeoliberalSorrow,
    \dur, Pseq([0.2, 0.3, 0.4, 0.5], 20),
    \amp, 0.5,
    \pan, 0
));
)