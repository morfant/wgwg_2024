SynthDef(\GentleBreezeLandscape, {
    var env, trig, freq1, freq2, dur1, dur2, pan1, pan2, signal, melody1, melody2;

    env = Env.new([0, 1, 0.7, 0], [0.01, 0.1, 0.2], 'sine');
    
    trig = Impulse.ar(10);
    
    freq1 = Demand.ar(trig, 0, Dseq((60..72).midiratio, 50));
    freq2 = Demand.ar(trig, 0, Dseq((48..60).midiratio, 50));
    
    dur1 = Demand.ar(trig, 0, Dseq((0.2 + [0.1, 0.2, 0.3].choose), 50));
    dur2 = Demand.ar(trig, 0, Dseq((0.2 + [0.1, 0.2, 0.3].choose), 50));
    
    pan1 = LFDNoise1.kr(0.25).range(-0.5, 0.5);
    pan2 = LFDNoise1.kr(0.25).range(-0.5, 0.5);
    
    melody1 = SinOsc.ar(freq1, 0, EnvGen.kr(env, 1, dur1, doneAction: 2));
    melody2 = SinOsc.ar(freq2, 0, EnvGen.kr(env, 1, dur2, doneAction: 2));
    
    signal = [melody1, melody2].sum;
    signal = LeakDC.ar(signal);
    signal = Limiter.ar(signal, 0.8);
    signal = Pan2.ar(signal, pan1 + pan2, 0.5);
    signal = signal * -6.dbamp;
    
    Out.ar(0, signal);
}).add;