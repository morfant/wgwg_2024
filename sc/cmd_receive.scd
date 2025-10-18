(
// SynthDef 등록
~of1.free;
~of1 = OSCdef(\cmd_revc1, { |msg, time, addr, port|
    var code = msg[1];
	"====/registerSynth====".postln;
	code = code.asString;
	code.class.postln;
	code.postln;  // 코드 출력 (디버깅용)

	code.interpretPrint;  // SuperCollider 명령으로 해석하고 실행

}, '/registerSynth', recvPort: 57120);


// OSC 메시지를 수신하고 해석하여 실행하는 OSCFunc 설정
// 등록된 SynthDef 실행 -> 소리 발생
~of2.free;
~of2 = OSCdef(\cmd_revc2, { |msg, time, addr, port|
    var run, synthName = msg[1];
	"====/playSynth====".postln;

	synthName = synthName.asSymbol;
	synthName.postln;
	Pdef(synthName).play;

}, '/playSynth', recvPort: 57120);


/*
// Pattern(Pdef) 등록
~of3.free;
~of3 = OSCdef(\cmd_revc3, { |msg, time, addr, port|
    // msg 배열의 첫 번째 요소를 코드로 해석
	var pat, code = msg[1];

	("code: " + code).postln;
	code = code.asString;
	code.interpretPrint;  // SuperCollider 명령으로 해석하고 실행

}, '/registerPattern', recvPort: 57120);  // 메시지를 받을 주소와 포트 설정
*/


// Pattern + instrument 실행
~of4.free;
~of4 = OSCdef(\cmd_revc4, { |msg, time, addr, port|
    // msg 배열의 첫 번째 요소를 코드로 해석
	var pat, code = msg[1], synth = msg[2];
	"====/playPattern====".postln;

	("code: " + code).postln;
	("synth: " + synth).postln;
	code = code.asString;
	synth = synth.asSymbol;

	pat = code.interpretPrint;

	(pat <> (instrument: synth)).play;



}, '/playPattern', recvPort: 57120);  // 메시지를 받을 주소와 포트 설정


// limiter
{
	arg ceil = 0.8, relTime = 0.01, amp = 0.8;
    var source, limitedSignal;

	limitedSignal = Limiter.ar(In.ar(100), ceil, relTime);

	Out.ar(0, Pan2.ar(limitedSignal, 0, amp));
}.play;

)



s.dumpOSC(1); // 0: off, 1: on-parsed, 2: on-hex, 3: on-both
s.dumpOSC(0); // 0: off, 1: on-parsed, 2: on-hex, 3: on-both




// _가 포함된 이름을 제외한 등록된 Synth 이름을 가져오는 예제
(
SynthDescLib.global.synthDescs
.select { |desc| desc.name.contains("_").not }  // _가 포함되지 않은 항목만 선택
.collect { |desc| desc.name }
.do { |synthName| synthName.postln; };
)



