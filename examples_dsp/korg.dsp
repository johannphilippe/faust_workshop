// Import the standard library
import("stdfaust.lib");
// Sliders are Control values - allowing to change parameters in realtime
freq = hslider("freq", 100, 50, 1000, 0.1) : si.smoo;
amp = hslider("gain", 0.3, 0, 1, 0.01) : si.smoo;
cutoff = hslider("cutoff", 0.3, 0, 1, 0.01) : si.smoo;
// Process is the main function of a Faust program
process = os.sawtooth(freq) : ve.korg35LPF(cutoff, 0.7) : *(amp) : *(0.3);
