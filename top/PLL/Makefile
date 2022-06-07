all:
	podman run  --rm -t -v ../..:/src -w /src hdlc/ghdl:yosys  yosys -v 9 -m ghdl -p 'ghdl  --std=08 /src/top/PLL/PLL_test.vhdl -e PLL_test; synth_ice40 -json /src/top/PLL/PLL_test.json'
	podman run  --rm -t -v .:/src -w /src hdlc/nextpnr:ice40 nextpnr-ice40 --package sg48 --up5k --json PLL_test.json --pcf PLL_test.pcf --asc PLL_test.asc
	podman run  --rm -t -v .:/src -w /src hdlc/icestorm icepack PLL_test.asc PLL_test.bin