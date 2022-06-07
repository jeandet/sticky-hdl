DOCKER_CMD="$(command -v winpty) docker run --rm -t -v :/src -w /src"
T=ads92x4.vhd clk_gen.vhd clock.vhd fifo.vhd io_pin.vhd nor_interface.vhd pulse_gen.vhd top_sticky.vhd

all:
	podman run  --rm -t -v ../..:/src -w /src hdlc/ghdl:yosys  yosys -v 9 -m ghdl -p 'ghdl  --std=08 /src/HDL/clk_gen.vhdl /src/HDL/pulse_gen.vhdl /src/HDL/ads92x4.vhdl /src/HDL/clock.vhd /src/HDL/fifo.vhd /src/HDL/io_pin.vhd /src/HDL/nor_interface.vhd /src/top/Sticky/top_sticky.vhd -e top_sticky; synth_ice40 -json /src/top/Sticky/top_sticky.json'
	podman run  --rm -t -v .:/src -w /src hdlc/nextpnr:ice40 nextpnr-ice40 --package sg48 --up5k --json top_sticky.json --pcf top_sticky.pcf --asc top_sticky.asc
