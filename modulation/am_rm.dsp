import("stdfaust.lib");
// Amplitude modulation (modulator must be positive)
amp_mod(freq) = _ : *(os.osc(freq) * 0.5 + 0.5);

// Ring modulation (modulator can be bipolar)
ring_mod(freq) = _ : *(os.osc(freq));

// Custom round function
rnd(sig) = floor(sig), ceil(sig) : select2( (sig -floor(sig)) > 0.5 );
// Wavefolding function  
wavefolder(sig) = 4 * (abs(0.25 * sig + 0.25 - rnd(0.25 * sig + 0.25))-0.25);
complex_ring_mod(freq, gain) = _ : *( (os.osc(freq) * gain ) : wavefolder);

fq = hslider("freq", 1, 0.01, 50, 0.001);
gain = hslider("gain", 0.1, 0.1, 100, 0.001) : si.smoo;

process = complex_ring_mod(fq, gain);