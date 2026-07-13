#!/bin/bash

# cross x86_64-unknown-linux-gnu
crossdev --b 2.46.1 --g 16.1.0 --k 6.19 --l 2.43-r2 -t x86_64-unknown-linux-gnu || exit 1

# cross x86_64-pc-linux-musl
crossdev --b 2.46.1 --g 16.1.0 --k 6.19 --l 1.2.6-r1 -t x86_64-pc-linux-musl || exit 1

# cross armv6j-unknown-linux-gnueabihf
crossdev --b 2.46.1 --g 16.1.0 --k 6.19 --l 2.43-r2 -t armv6j-unknown-linux-gnueabihf || exit 1

# cross riscv64-unknown-linux-gnu
crossdev --b 2.46.1 --g 16.1.0 --k 6.19 --l 2.43-r2 -t riscv64-unknown-linux-gnu || exit 1
