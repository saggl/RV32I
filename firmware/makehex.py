#!/usr/bin/env python3
"""Convert a binary file to a hex file for $readmemh."""

import sys

def makehex(binfile, nwords):
    with open(binfile, "rb") as f:
        bindata = f.read()
    for i in range(nwords):
        if i * 4 < len(bindata):
            w = bindata[i*4 : i*4+4]
            # Little-endian to 32-bit hex word
            val = int.from_bytes(w, byteorder='little')
            print(f"{val:08x}")
        else:
            print("00000000")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <binfile> <nwords>", file=sys.stderr)
        sys.exit(1)
    makehex(sys.argv[1], int(sys.argv[2]))
