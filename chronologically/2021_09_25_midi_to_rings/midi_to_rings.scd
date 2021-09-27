s.boot;

(
SynthDef(\ding, { arg pit;
    Out.ar(0, MiRings.ar(pit: pit, model: 2));
}).add;
)

// naive: just initialise new synth every time
(
var notes, on, off;

MIDIClient.init;
MIDIIn.connectAll;

notes = Array.newClear(128);    // array has one slot per possible MIDI note

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
    notes[num] = Synth(\ding, [\pit, num]);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
	"off posted".postln;
    notes[num].release;
});

q = { on.free; off.free; };
)
s.stop
s.reset


// alternative approach with one rings that has pit changed
(
SynthDef(\dong, { arg pit = 60;
    Out.ar(0, MiRings.ar(pit: pit, poly: 4, model: 2));
}).add;
)

(
var notes, on, off, theRings;

MIDIClient.init;
MIDIIn.connectAll;

theRings = Synth(\dong);

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	theRings.set(\pit, num)
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
});

q = { on.free; off.free; };
)

// alternative approach with one rings that is plucked
(
SynthDef(\dong, { arg pit = 60, trig = 0;
    Out.ar(0, MiRings.ar(pit: pit, trig: trig, poly: 4, model: 2));
}).add;
)

(
var notes, on, off, theRings;

MIDIClient.init;
MIDIIn.connectAll;

theRings = Synth(\dong);

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	theRings.set(\pit, num, \trig, 1);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
	theRings.set(\trig, 0);
});

q = { on.free; off.free; };
)


// when done:
q.value;
s.stop;