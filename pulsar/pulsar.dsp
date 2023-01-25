import("stdfaust.lib");
pulsar(fq, form_fq, sine_cycles) = sine
with {
    pulsaret_phase = os.phasor(1, fq) * form_fq / fq;
    gate = (pulsaret_phase < 1);    
    window =  pulsaret_phase^4,0 : select2(gate > 1);
    sine = sin(pulsaret_phase * 2 * ma.PI * sine_cycles) * window * gate;
};

fq = hslider("frequency", 30, 1, 1000, 1) : si.smoo;
form_fq = hslider("formant_frequency", 50, 2, 8000, 1) : si.smoo;
sine_cycles = hslider("sine_cycles", 1, 1, 10, 1);

amp = hslider("amplitude", 0.1, 0, 1, 0.01) : si.smoo;

process = pulsar(fq, form_fq, sine_cycles) * amp;
