# VIC-20 VICE Emulator Workflow Guide

## Contents:
1. Creating PRG files
    1. Compiling assembly programs to desired prg w/ 64tass
    2. Creating prg files manually (future work)
2. Using the c1541 utility to create disk images containing PRG files
    1. Create 1541 disk images for use with xvic (ICE VIC-20 Emulator)
    2. Add files to existing disk image
    3. Remove files from existing disk image
3. Mount disk image in XVIC
    1. Mount
    2. Load & run prg files

---

### PRG files

Use a 6502 assembler to generate the machine code of your program. Then, add two bytes to the start of that assembled binary file: these bytes are the address in the VIC-20's memory map to which the machine code (or data) should be loaded. These bytes should be in LITTLE ENDIAN format. The default value for the VIC-20 is `$1001`, and the bytes should be added as `0x01 0x10`. When the VIC-20 loads files, it checks those two bytes and skips them when loading the actual program into system memory.

The 6502 assembler `64tass` will handle the prg format specifics for you.
Include `* = $1001` in your assembly source file and then assemble the file with the `--cbm-prg` option:
```
$ 64tass --cbm-prg asmsource.s -o myfile.prg
```


### Creating disk image files with the c1541 utility

The c1541 utility allows you to create disk image files and add your prg (and other) files to the disk image file. The disk image file can then be mounted in the XVIC emulator and accessed from the emulated VIC-20 as if it were a real disk in an attached disk drive. The c1541 utility is bundled with the VICE emulator package.

The c1541 util has a few main commands:
    - format: create/ reformat disk image
    - attach
    - write
    - delete
    - dir

These commands are implemented as flags with command line arguments passed to the c1541 utility.

**format**: Create/ reformat a (blank) d64 disk image. (Other formats than d64 are available).
```
$ c1541 -format dskname,dskid d64 mydisk.d64
```
**attach**: Passes a .d64 disk image file to the c1541 utility (to then be used with subsequent commands such as write).
```
$ c1541 -attach mydisk.d64
```
**write**: Writes a specified file to the active (attached) disk image file. Must specify the destination filename; distination filename doesn't need .prg extension; only writes a single file.
```
$ c1541 -attach mydisk.d64 -write srcfile.prg destfile
```
**delete**: Deletes a specified file from the active disk image.
```
$ c1541 -attach mydisk.d64 -delete myprg
```
**dir**: Lists the contents of the attached disk image.
```
$ c1541 -attach mydisk.d64 -dir
```
Commands can be combined:
To create a disk image and add files in a single step:
```
$ c1541 -format dskname,dskid d64 mydisk.d64 -attach mydisk.d64 -write demo1.prg demo1 -write demo2.prg demo2  -write demo3.prg demo3
```
To add multiple files to an existing disk image file:
```
$ c1541 -attach mydisk.d64 -write demo4.prg demo4 -write demo5.prg demo5  -write demo6.prg demo6
```

### Mount disk images in XVIC
Press F10 to bring up emulatore menu. Use arrow keys to navigate. Select "Drive," then "Attach disk image to drive 8," press ENTER. Use the arrow + ENTER keys to navigate the file browser: select your disk image file and press ENTER. Press escape twice to exit the emulator menus.

Now, you can load and run the programs / files on your attached disk image and press ENTER. Press escape twice to exit the emulator menus.

Now, you can load and run the programs / files on your attached disk image through the VIC-20's BASIC interpreter (i.e., as you would normally do).
