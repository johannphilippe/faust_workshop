import("stdfaust.lib");

N_VOICES = 8;

randoms = no.noises(N_VOICES);
mult = hslider("multiplier", 0.1, 0.01, 1, 0.01);
impulse = button("impulse");
voice(n) = os.osc(frequency)
with {
    frequency =  randoms(n) 
		: abs 
		: ba.sAndH(os.impulse+impulse) 
		: *(mult) 
		: *(500) : +(80) 
		: si.smoo;
};

amp = hslider("amplitude", 0.1, 0, 1, 0.01) : si.smoo;
process = sum(n, N_VOICES, voice(n)) / N_VOICES * amp; 

