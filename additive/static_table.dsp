import("stdfaust.lib");

freq_table = waveform{100, 120, 430, 567, 926.3};
size = freq_table : _,!;

freq(n) = freq_table, n+1 : rdtable;

amp = hslider("amplitude", 0.1, 0, 1, 0.01) : si.smoo;
process = sum(n, size, os.osc(freq(n))/size) * amp;
