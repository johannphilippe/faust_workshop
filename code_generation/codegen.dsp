import("stdfaust.lib");

frequency = hslider("frequency", 100, 50, 500, 1);
amp = hslider("amplitude", 0, 0, 1, 0.1) : si.smoo;
process = os.osc(frequency) * amp;
