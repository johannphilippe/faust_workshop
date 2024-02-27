import("stdfaust.lib");

MAXSR = 48000;
recdel(max_smps, smps, fb) = +~de.fdelay(max_smps,smps) * fb;
flanger = recdel(max_ms * MAXSR / 1000, dur_ms * ma.SR / 1000, fb)
with {
    max_ms = 40;
    dur_ms = os.osc(hslider("lfo_fq", 0.1, 0.001, 10, 0.001) * 0.5 ) 
        : abs : *(hslider("delay_mult", 5, 1, max_ms, 0.1));
    fb = hslider("feedback", 0, 0, 1, 0.001);
};

process = _ : flanger;
