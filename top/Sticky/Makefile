VHDL_SOURCES = /src/HDL/fifo.vhd /src/HDL/bram_256x16.vhd \
               /src/HDL/io_pin.vhd /src/HDL/fmc_if.vhd \
			   /src/HDL/pulse_gen.vhdl /src/HDL/clk_gen.vhdl \
			   /src/HDL/rcc.vhdl /src/top/Sticky/top.vhdl \
			   /src/HDL/fifo_0ws.vhd /src/HDL/bram.vhd \
			   /src/HDL/fmc_if_with_fifo.vhd /src/HDL/ads92x4.vhdl

all:
	podman run  --rm -t -v ../..:/src -w /src hdlc/ghdl:yosys  yosys -v 9 -m ghdl -p 'ghdl --std=08 $(VHDL_SOURCES) -e top; synth_ice40 -json /src/top/Sticky/top.json'
	podman run  --rm -t -v .:/src -w /src hdlc/nextpnr:ice40 nextpnr-ice40 --pre-pack contraints.py --opt-timing  --package sg48 --up5k --json top.json --pcf top.pcf --asc top.asc
	podman run  --rm -t -v .:/src -w /src hdlc/icestorm icepack top.asc top.bin
	
