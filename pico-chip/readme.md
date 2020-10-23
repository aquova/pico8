# Pico-Chip

A Chip-8 emulator for Pico-8

## How to use

The `c8_to_p8.py` script will convert a Chip-8 binary into a .p8 file for use with the emulator.

1. Run `python3 c8_to_p8.py GAME.c8`, which will produce `game.p8`
2. Edit the include statement at the start of `pico-chip.p8` to read `#include game.p8`.
3. Run `pico-chip.p8`, and the emulator should load the ROM and begin!
