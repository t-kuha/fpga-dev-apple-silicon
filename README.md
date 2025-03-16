# fpga-dev-apple-silicon

![build test](https://github.com/t-kuha/fpga-dev-apple-silicon/actions/workflows/build.yml/badge.svg)

FPGA development on Apple Silicon Mac solely with open source tools

- macOS version: 15 (Sequoia)

## common set-up

```shell
$ ./install_python_uv.sh
$ ./build_deps.sh
```

***

## references

- [M1 Macでriscv-gnu-toolchainのビルド](https://msyksphinz.hatenablog.com/entry/2022/05/23/040000)
- [macOS build fails: Makefile:51: *** commands commence before first target. Stop](https://github.com/riscv-collab/riscv-gnu-toolchain/issues/1598)
