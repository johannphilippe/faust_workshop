import("stdfaust.lib");

N_VOICES = 10;

// Init = 100, Min = 50, Max = 100, Step = 1
base_frequency = hslider("frequency", 100, 50, 1000, 1);

amp = hslider("amplitude", 0.1, 0, 1, 0.01) : si.smoo;
process = sum(n, N_VOICES, os.osc(base_frequency * (n+1) ) / N_VOICES) * amp;
