FT2232-based NAND reader (and maybe writer?)

Hardware (and software) is described at:
http://spritesmods.com/?art=ftdinand

Build instructions:
- Build the hardware. Without it, this software isn't really any use.
- Make sure the development libraries for libftdi are installed, as well as gcc etc
- Run 'make'
- ...
- Profit!

If you happen to have an FT2232H-board which uses a different VID/PID, you can use
the -u parameter to make the program use that:

jeroen@spritesws$ lsusb
[...]
Bus 001 Device 010: ID 0403:8a98 Future Technology Devices International, Ltd 
jeroen@spritesws$ ./ftdinandreader -u 0403:8a98 -i
Nand type: NAND 512MiB 3,3V 8-bit
Manufacturer: Samsung
Size: 512MB, pagesize 2048 bytes, OOB size 64 bytes
Large page, needs 5 addr bytes.
All done.
jeroen@spritesws$

At the moment the program only supports reading NAND chips. Some work on writing
has been done too, but it'll need a fair amount of work to get working. If you
manage to do that, or have other improvements, feel free to mail me the patches
at jeroen at spritesmods.com

