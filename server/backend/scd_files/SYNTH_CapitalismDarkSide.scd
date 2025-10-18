SynthDef(\CapitalismDarkSide, {
    |out=0|
    var env, osc1, osc2, osc3, mix, filt, ampEnv, panner;
    
    env = Env.new([0, 1, 0.5, 0], [0.01, 0.18, 0.01], \sin);
    ampEnv = EnvGen.kr(env, doneAction: 2);

    osc1 = SinOsc.ar({ Demand.ar(Dust.ar(3), 0, Dseq([60, 62, 64, 65, 67, 69, 71, 72], inf).midicps) }!3, 0, 0.3);
    osc2 = Pulse.ar({ Demand.ar(Dust.ar(4), 0, Dseq([48, 50, 52, 53, 55, 57, 59, 60], inf).midicps) }!3, 0.4, 0.2);
    osc3 = Saw.ar({ Demand.ar(Dust.ar(2), 0, Dseq([36, 38, 40, 41, 43, 45, 47, 48], inf).midicps) }!3, 0.5);

    mix = Mix([osc1, osc2, osc3]) * ampEnv;

    filt = RLPF.ar(mix, 1000, 0.2);

    panner = Pan2.ar(filt, Line.kr(-0.5, 0.5, 20), 0.8);

    Out.ar(out, panner);
}).add;