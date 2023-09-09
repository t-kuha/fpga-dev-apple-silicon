# fpga-dev-apple-silicon

FPGA development on Apple Silicon Mac solely with open source tools

![build test](https://github.com/t-kuha/fpga-dev-apple-silicon/actions/workflows/build.yml/badge.svg)

## set-up (common)

```shell-session
$ ./build_deps.sh
$ ./build_riscv-gcc.sh
```

***

## Sipeed Tangnano

- install Yosys / nextpnr

```shell-session
$ ./build_tangnano.sh
```

- program bitstream

```
$ export PATH=$(pwd)/tools/bin:${PATH}
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

***

## Xilinx 7-series FPGA

```shell-session
$ ./build_xilinx.sh
```

### tinygrad

```shell-session
$ export PATH=$(pwd)/tools/bin:$(pwd)/tools/bin/CMake.app/Contents/bin:${PATH}
$ export TOP_DIR=$(pwd)
$ mkdir tinygrad && cd tinygrad
$ git clone https://github.com/geohot/tinygrad.git
$ cd tinygrad
$ git checkout 90529d3
$ cd accel/cherry
$ mkdir out
$ ./riscv.sh
$ cd out
$ yosys -p "synth_xilinx -flatten -nowidelut -abc9 -arch xc7 -top top; write_json attosoc.json" ../src/attosoc.v ../src/attosoc_top.v ../src/simpleuart.v
$ python ${TOP_DIR}/_work/repos/nextpnr-xilinx/xilinx/python/bbaexport.py --device xc7a100tcsg324-1 --bba xc7a100t.bba
$ bbasm -l xc7a100t.bba xc7a100t.bin
$ nextpnr-xilinx --chipdb xc7a100t.bin --xdc ../src/arty.xdc --json attosoc.json --write attosoc_routed.json --fasm attosoc.fasm
$ ${TOP_DIR}/_work/repos/prjxray/utils/fasm2frames.py --db-root ${TOP_DIR}/_work/repos/prjxray/database/artix7 --part xc7a100tcsg324-1 attosoc.fasm > attosoc.frames
$ xc7frames2bit --part_file ${TOP_DIR}/_work/repos/prjxray/database/artix7/xc7a100tcsg324-1/part.yaml --part_name xc7a100tcsg324-1 --frm_file attosoc.frames --output_file attosoc.bit
```
