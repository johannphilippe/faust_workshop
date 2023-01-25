//declare options "[midi:on][nvoices:12]";
declare options "[midi:on]";
declare options "[nvoices:12]";
import("stdfaust.lib");
//Hence, any Faust program declaring the freq (or key), gain (or vel or velocity), and gate parameter is polyphony-compatible. 

freq = hslider("freq", 100, 50, 500, 1);
gain = hslider("gain", 0.5, 0, 1, 0.01);
gate = button("gate");
process = os.sawtooth(freq) * gain * gate;


