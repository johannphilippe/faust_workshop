import("stdfaust.lib");

hold_smps(smps_dur, trig) = pulsation
with {
    count = ba.countdown(smps_dur, trig);
    //count =  -(1)~_, smps_dur : select2(trig);
    pulsation = 0, 1 : select2(count > 0);
};
hold_dur(duration, trig) = hold_smps(ba.sec2samp(duration), trig);

N_VOICES = 8;
voice(n) = vgroup("voice_%n", os.osc(freq)*env)
with {
    // Each oscillator has a different controllable frequency
    freq = hslider("freq_%n", (n+1)*50, 50, 1000, 1);
    // Same for envelop speed (in Hz)
    env_speed = hslider("envelop_speed_%n", 0.1, 0.1, 5, 0.01);
    dur = 1 / env_speed;
    atq = dur * 0.1;
    rel = dur * 0.9;
    env = ba.beat(env_speed * 60) : hold_dur(atq) :  en.are(atq, rel);
};

amp = hslider("amplitude", 0.1, 0, 1, 0.01) : si.smoo;
process = sum(n, N_VOICES, voice(n) ) / N_VOICES * amp;

