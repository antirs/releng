#!/bin/bash

# cross x86_64-unknown-linux-gnu
crossdev --b 2.45.1 --g 15.2.1_p20251108-r1 --k 6.17 --l 2.42-r2 -t x86_64-unknown-linux-gnu || exit 1

# cross x86_64-pc-linux-musl
crossdev --b 2.45.1 --g 15.2.1_p20251108-r1 --k 6.17 --l 1.2.5-r6 -t x86_64-pc-linux-musl || exit 1

# cross armv6j-unknown-linux-gnueabihf
crossdev --b 2.45.1 --g 15.2.1_p20251108-r1 --k 6.17 --l 2.42-r2 -t armv6j-unknown-linux-gnueabihf || exit 1

# cross riscv64-unknown-linux-gnu
crossdev --b 2.45.1 --g 15.2.1_p20251108-r1 --k 6.17 --l 2.42-r2 -t riscv64-unknown-linux-gnu || exit 1
