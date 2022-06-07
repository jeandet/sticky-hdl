VHDL_SOURCES = /src/HDL/adc_uart.vhdl /src/HDL/pulse_gen.vhdl /src/HDL/clk_gen.vhdl /src/HDL/ads92x4.vhdl /src/HDL/UART.vhdl /src/HDL/rcc.vhdl /src/top/adc_uart/top.vhdl

all:
	podman run  --rm -t -v ../..:/src -w /src hdlc/ghdl:yosys  yosys -v 9 -m ghdl -p 'ghdl  --std=08 $(VHDL_SOURCES) -e top; synth_ice40 -json /src/top/adc_uart/top.json'
	podman run  --rm -t -v .:/src -w /src hdlc/nextpnr:ice40 nextpnr-ice40 --pre-pack contraints.py --opt-timing --detailed-timing-report  --package sg48 --up5k --json top.json --pcf top.pcf --asc top.asc
	#podman run  --rm -t -v .:/src -w /src hdlc/nextpnr:ice40 nextpnr-ice40 --pre-pack contraints.py --opt-timing --parallel-refine --tmg-ripup --placer-heap-timingweight=100 --detailed-timing-report  --package sg48 --up5k --json top.json --pcf top.pcf --asc top.asc
	podman run  --rm -t -v .:/src -w /src hdlc/icestorm icepack top.asc top.bin
	
