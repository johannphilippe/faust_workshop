import("stdfaust.lib");

MAX_DUR = 3;
echo = ef.echo(MAX_DUR, dur, feedback)
with {
    dur = hslider("duration", 0.1, 0.001, 3, 0.0001);
    feedback = hslider("feedback", 0, 0, 1, 0.001);
};

process = _ <: _, echo : _, _*(0.5) :> _;
