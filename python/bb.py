from pythonosc import udp_client

# SuperCollider가 실행 중인 로컬 서버와 포트
client = udp_client.SimpleUDPClient("127.0.0.1", 57120)

# 좀 더 화려한 소리를 생성하는 SuperCollider 코드
supercollider_code = '''
SynthDef(\\fancySynth, {
    |freq=440, amp=0.5, dur=1|
    var env, sig, mod;
    
    // Envelope
    env = EnvGen.kr(Env.perc(0.01, 0.3, amp, -4), doneAction: 2);
    
    // Modulation
    mod = SinOsc.ar(freq * 0.5, 0, 0.2) * EnvGen.kr(Env.perc(0.1, 0.3, 1, -4), doneAction: 2);
    
    // Main signal
    sig = SinOsc.ar(freq + mod, 0, env) * 0.3;
    sig = sig + (WhiteNoise.ar(0.1) * 0.1); // Add some noise
    
    // Filtering
    sig = sig.clip2(-1, 1); // Clip to avoid distortion
    sig = sig.lpfilter(8000); // Low-pass filter to smooth the signal
    
    // Output
    Out.ar(0, sig.dup);
}).play;
'''

# SuperCollider 코드를 OSC 메시지로 전송
client.send_message("/runCode", supercollider_code)
