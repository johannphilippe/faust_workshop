import("stdfaust.lib");

MAX_SMPS = 48000 * 2;
recdel(smps, fb) = +~de.delay(MAX_SMPS, smps) * fb;
mix_recdel(mix,  smps, fb, sig) = sig : recdel(smps, fb) : _*mix + sig * (1 - mix); 

// Our echo is taking 3 parameters and 1 input : dry/wet, duration (max 2 seconds), feedback
echo(mix, dur, fb, sig) = sig : mix_recdel(mix, dur * ma.SR, fb);

process = _ <: echo(0.4, 0.5, 0.7), echo(0.4, 0.6, 0.7);

