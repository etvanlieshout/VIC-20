This directory stores some .d64 disk images for use with the VICE Emulator.
The image name will specify whether it is for the Commodore VIC-20 or the C64.

NOTE: Everything letter is capital on the VIC-20, so no need to hit <SHIFT> + <LETTER>

To load a VIC-20 disk in VICE's XVIC emu:
Start the emulator & press F12 for the menu.
Select 'Drives' and then select 'Attach Drive to device no 8' & use the horrible
file system navigator to find where you saved your .d64 file; select the file
by pressing <ENTER>. Leave the menu and return to the VIC-20.

From here, type the following commands (ignoring the $ and no spaces), pressing <ENTER> after each:
$ LOAD"BEE",8,1
$ LOAD"BEETEST",8,1
$ POKE36869,254
After you type the last command, the screen text will be garbled; don't worry,
we just moved the pointer to character/graphics data.
Lastly, type RUN and hit <ENTER> to see the bee!
(the R U N will appear as gibberish, but as long as you typed it correct it doesn't matter):


Additionally, you can type a bee on screen with @ABCDE + arrow keys to put the
cursor in the correct place
