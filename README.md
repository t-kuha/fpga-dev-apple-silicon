# fpga-dev-apple-silicon

FPGA development on Apple Silicon Mac solely with open source tools

![build test](https://github.com/t-kuha/fpga-dev-apple-silicon/actions/workflows/build.yml/badge.svg)

## set-up

```shell-session
$ ./build_deps.sh
$ ./build_riscv-gcc.sh
```

***

## Sipeed Tangnano

- install Yosys / nextpnr / 

```shell-session
$ ./build_tangnano.sh
```

- program bitstream

```
$ openFPGALoader --detect
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
index 0:
        idcode 0x100481b
        manufacturer Gowin
        family GW1N
        model  GW1N(R)-9C
        irlength 8

# to SRAM
$ openFPGALoader -m <bitstream>.fs
# or to FLASH
$ openFPGALoader -f <bitstream>.fs
```
