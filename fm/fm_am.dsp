import("stdfaust.lib");

wave_oscil(freq, index) = vgroup("Modulator", mix)
with {
    saw_amt = hslider("saw_amount_%index", 0, 0, 1, 0.01) : si.smoo;
    saw = os.sawtooth(freq) * saw_amt;
    sine_amt = hslider("sine_amount_%index", 1, 0, 1, 0.01) : si.smoo;
    sine = os.sawtooth(freq) * sine_amt;
    square_amt = hslider("square_amount_%index", 0, 0, 1, 0.01) : si.smoo;
    square = os.sawtooth(freq) * square_amt;
    mix = (saw + sine + square);
};

fm_freq = hslider("fm_frequency", 0.1, 0.1, 1000, 0.01);
fm_amount = hslider("fm_amount", 0, 0, 1, 0.01);
fm_mod = vgroup("FM_frequency modulation", wave_oscil(fm_freq, 1) : *(fm_amount));

am_freq = hslider("am_frequency", 0.1, 0.1, 1000, 0.01);
am_amp = hslider("am_amplitude", 0, 0, 1, 0.01);
am_mod = vgroup("AM Amplitude modulation", wave_oscil(am_freq, 2) : *(0.5) : + (0.5) : *(am_amp));

amp = hslider("amplitude", 0.1, 0, 1, 0.01) : si.smoo;


carrier_freq = hslider("carrier_frequency", 100, 50, 1000, 1);
carrier = os.osc(carrier_freq + (fm_mod*carrier_freq+1) ) * am_mod;
process = carrier * amp;
