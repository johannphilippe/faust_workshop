import("stdfaust.lib");

// Custom round function
rnd(sig) = floor(sig), ceil(sig) : select2( (sig -floor(sig)) > 0.5 );
// Wavefolding function  
wavefolder(sig) = 4 * (abs(0.25 * sig + 0.25 - rnd(0.25 * sig + 0.25))-0.25);
gain = hslider("gain", 0.1, 0.1, 100, 0.001) : si.smoo;
process = _ : *(gain) : wavefolder : *(0.2);