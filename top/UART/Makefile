all:
	podman run  --rm -t -v ../..:/src -w /src hdlc/ghdl:yosys  yosys -v 9 -m ghdl -p 'ghdl  --std=08 /src/HDL/UART.vhdl /src/HDL/diviseur.vhdl /src/HDL/compteur.vhdl /src/top/UART/top.vhdl -e top; synth_ice40 -json /src/top/UART/top.json'
	podman run  --rm -t -v .:/src -w /src hdlc/nextpnr:ice40 nextpnr-ice40 --package sg48 --up5k --json top.json --pcf top.pcf --asc top.asc
	podman run  --rm -t -v .:/src -w /src hdlc/icestorm icepack top.asc top.bin