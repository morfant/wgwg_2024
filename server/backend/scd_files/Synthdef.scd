// AnxiousSound

(
SynthDef(\AnxiousSound, {
    arg out=0;
    var sound, env, freq, amp, pan, dur, trig;
    
    trig = Dust.kr(1);
    dur = Demand.kr(trig, 0, Dseq([0.125, 0.25, 0.375], inf));
    freq = Demand.kr(trig, 0, Drand([200, 250, 300, 350, 400], inf));
    amp = Demand.kr(trig, 0, Drand([0.6, 0.7, 0.8, 0.9, 1.0], inf));
    pan = LFDNoise1.kr(3);

    env = EnvGen.kr(Env.perc(0.01, dur, amp), trig);
    sound = SinOsc.ar(freq, 0, env);
    sound = sound * LFNoise1.kr(5);

    Out.ar(out, Pan2.ar(sound, pan));
}).add;
)