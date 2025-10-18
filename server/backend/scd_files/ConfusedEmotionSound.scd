(
SynthDef(\ConfusedEmotionSound, {
    arg out=0, freq=110, amp=0.5, dur=6;
    var env, osc, reverb;
    
    env = EnvGen.kr(Env.linen(0.01, dur, 0.1), doneAction: 2);
    osc = Mix.fill(4, {
        var sig = SinOsc.ar(freq * [1, 1.5, 2, 2.5].choose, 0, LFNoise1.kr(10, 0.5, 1));
        Pan2.ar(sig, LFNoise1.kr(5).range(-1, 1))
    });
    
    reverb = FreeVerb.ar(osc, mix: 0.3, room: 0.5, damp: 0.4);
    Out.ar(out, reverb * env * amp);
}).add;
)