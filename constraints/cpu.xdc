# 100 MHz clock target (10 ns).  Tighten/relax to find the real Fmax.
create_clock -period 10.000 -name clck [get_ports clck]
# Pin assignments are not set: this is a synthesis-only constraint set.
