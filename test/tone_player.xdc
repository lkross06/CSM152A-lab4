## =============================================================================
## tone_player.xdc  (timing-fixed revision)
## Basys3 — tone_player + PmodAMP2 on JA header
##
## Key change: set_false_path on all output ports replaces set_output_delay.
## The PmodAMP2 is a pure analog receiver — there is no setup/hold requirement
## on AIN, GAIN, or SHDN relative to any external clock, so constraining them
## as output delays was incorrect and caused Vivado to report false violations.
## set_false_path tells the timing engine to ignore those paths entirely.
## =============================================================================

## ---------------------------------------------------------------------------
## Clock — 100 MHz on W5
## ---------------------------------------------------------------------------
set_property PACKAGE_PIN W5       [get_ports clk]
set_property IOSTANDARD LVCMOS33  [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ---------------------------------------------------------------------------
## Button — BTNC (center)
## ---------------------------------------------------------------------------
set_property PACKAGE_PIN U18      [get_ports btnc]
set_property IOSTANDARD LVCMOS33  [get_ports btnc]

## The button is asynchronous to the clock; handled by the two-FF synchroniser
## in RTL.  Tell the timing engine not to analyse the input path.
set_false_path -from [get_ports btnc]

## ---------------------------------------------------------------------------
## PmodAMP2 on JA header
##
##  JA top row (left to right on board):
##    JA1 = J1  → AIN  (audio PWM input to amp)
##    JA2 = L2  → GAIN (HIGH = 6 dB; LOW = unity)
##    JA3 = J2  → NC   (not used — SHDN is on JA4)
##    JA4 = G2  → SHDN (active-LOW shutdown; drive HIGH to enable)
##
##  Note: Basys3 reference manual lists JA pins as:
##    JA1=J1, JA2=L2, JA3=J2, JA4=G2  (top row)
##    JA7=H1, JA8=K2, JA9=H2, JA10=G3 (bottom row, GND/VCC in between)
## ---------------------------------------------------------------------------
set_property PACKAGE_PIN J1       [get_ports ain]
set_property IOSTANDARD LVCMOS33  [get_ports ain]

set_property PACKAGE_PIN L2       [get_ports gain]
set_property IOSTANDARD LVCMOS33  [get_ports gain]

set_property PACKAGE_PIN G2       [get_ports shdn]
set_property IOSTANDARD LVCMOS33  [get_ports shdn]

## All three outputs feed an analog amplifier — no external clock to meet.
## Use set_false_path so Vivado does not analyse output delays to the pin.
set_false_path -to [get_ports ain]
set_false_path -to [get_ports gain]
set_false_path -to [get_ports shdn]
