# Sipeed Tangnano

- install Yosys / nextpnr

```shell
# go to top directory
$ source ./exports.sh
$ ./build_riscv-gcc.sh
$ ./build_tangnano.sh
```

- program bitstream

```shell
$ source ./exports.sh

# example: TangNano 9K
$ openFPGALoader --detect
empty
No cable or board specified: using direct ft2232 interface
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
index 0:
        idcode 0x100481b
        manufacturer Gowin
        family GW1N
        model  GW1N(R)-9C
        irlength 8

# program to SRAM
$ openFPGALoader -m <bitstream>.fs
# or to FLASH
$ openFPGALoader -f <bitstream>.fs
```
