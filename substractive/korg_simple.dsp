import("stdfaust.lib");

cutoff = hslider("Cutoff", 0, 0, 1, 0.01) : si.smoo;

// Warning : above 9, the filter becomes unstable (explosion)
res = hslider("Resonance", 0, 0, 1, 0.01) : *(9) : si.smoo;
amp = hslider("amplitude", 0.1, 0, 1, 0.01);

process = os.sawtooth(200) : ve.korg35LPF(cutoff, res) * amp;
