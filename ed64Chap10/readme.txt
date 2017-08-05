ED64 : El Dendo's commodore 64 emulator
---------------------------------------

This zipfile contains the latest stable version: Chapter 10

this zip file contains:
-----------------------

ed64.exe : executable for windows
basic.rom, kernal.rom, char.rom : rom images
readme.txt : this file
*.prg : example c64 programs 

installation
------------

unzip the zip file.
ed64.exe and the rom images should be in the same directory.

instructions
------------

start the emulator by executing ed64.exe
choose graphic resolution

only limited keyboard emulation: alphanumeric and standard symbols, cursor keys and insert key.

load ans save commands do not work. use F11, Shift F11 and F12 instead.
F11 : load "filename"
shift F11 : load "filename",x,1
F12 : save "filename"

files are loaded and saved as filename.prg and are in prg format
filename.prg should be in the same directory as the ed64.exe, or you can prequalify filename.
e.g. F11 ... "c:\c64progs\test" to load c:\c64progs\test.prg

major limitations
-----------------
only the processor, memory and the VIC are implemented
Processor: no decimal mode, no 'illegal' instructions, no Timing.
VIC : only basic screen modes (3 character and 2 hires modes). No Sprites. 

futur versions
--------------

look at http://ed64.eldendo.be

contact
-------

marc.dendooven@gmail.com


