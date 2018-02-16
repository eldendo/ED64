# ED64 - HOW TO WRITE A COMMODORE 64 EMULATOR  
 Copyright 2007 ir. Marc Dendooven  
 Chapter 1: Introduction and Emulator Model

## Introduction  

   This document describes how to build a simple Commodore 64 emulator. You may wonder why someone should spend time writing an emulator of an old machine of which a lot of emulators already exists. The answer is simple: because it is fun! 
The main purpose of these documents is to let the reader see how an emulator is build. Therefore we will emphasis on writing clear, understandable code and not on performance. So if you are not interested in the internals of this emulator, but just want to execute C64 programs I suggest that you use a proven emulator like CCS64.


This document will contain different chapters. Each Chapter will add something to the emulator and will end with an executable program.


In this first chapter we will establish a simple model for the emulator and show how this can be programmed.

## Requirements

   1. Information

      To write an emulator, you need a good knowledge of the emulated machine. Some experience with machine code programming on the c64 will be an advantage. The c64 is a well documented machine. I used the “Commodore 64 Programmers Reference Guide” (Commodore) and “What’s really inside the Commodore 64” (Milton Bathurst). The second book is a documented assembler listing of the C64 ROM’s. A lot of information can be found on the internet too.

   2. Compiler
   
      And of course you need a compiler. Since an emulator should be fast, it is best written in assembler. But then the emulator will be system dependent. A better choice is C. C is fast and fairly general. But C code is not always that clear to read. Since we will target clarity here, Pascal was chosen to write this emulator. I used Freepascal which is a good opensource implementation that exist for different operating systems. You can find it at http://www.freepascal.org.

   3. Emulator model
      While writing this emulator we will keep it as simple as possible. We will start with a very small model and extend it when needed. An emulator con be written at different levels: you can e.g. emulate at the hardware level and use a virtual databus, addressbus, controlbus and emulate all hardware components as threaded objects which communicate with each other by means of this busses. This is probable the best way to write an emulator but it will be difficult and slow. 
Here I will emulate the user model of the commodore 64: the way a (machine code) programmer sees the machine. This is explained in the c64 programmers guide in only a few pages.

      This is quite simple: the user sees the registers in the processor (6 registers of 8 bit and 1 register of 16 bits) and sees the memory as an array of bytes. A limited number of machine code instructions are available to process the data in the registers and in the memory array. At last we should provide a mechanism to execute a machine code program (the main processor loop).

      IO hardware in the C64 is memory mapped. This means that the user communicates with it by writing to, or reading from certain memory locations in the memory map. So it is transparent in the user model. At first we will not implement other hardware than the processor and the memory. Later we will add what is necessary. 

## Implementation
   
   1. Memory
      
         The user sees the memory as a 64k array of byte. In pascal we can define:

```pascal
var ram : array [0..$FFFF] of byte;
```

remark : $ stands for hexadecimal

But that is too simple: dependant of the memory configuration a certain range in the memory can be occupied by RAM, ROM or even memory mapped hardware.

We will use a technique called data abstraction: we will NEVER access the memory immediately, but always by using two ‘methods’ to read and write to the memory.
```pascal
procedure poke(address : word ; value : byte);
begin
    ram[address] := value;
end;

function peek(address : word) : byte;
begin
    peek := ram[address];
end;
```
So when we change the implementation of the memory later on, and adapt the peek and poke methods accordingly without changing the interface (that is the way a function appears in a program calling it), the rest of the program should not be altered. In Freepascal we can enforce this by putting this code in a separate unit.

See the complete code in the file memio.pas

2. Processor registers
The registers are simply declared in our main program:
```pascal
var
    A,X,Y,S,P,IR : byte;
    PC : word;
```
3. Processor main loop
The processor executes machine code programs. A machine code program is nothing else then a sequence of bytes somewhere in memory. The program counter (PC) is a 16 bit register that points to the next byte to be treated. The content of that memory location is copied in the instruction register (IR) and PC is incremented so that it points to the next memory location. The instruction in IR is then interpreted and the whole process is started again in an infinite loop.
```pascal
while true do
begin
    IR := peek(PC);
    inc(PC);
    case IR of
        $00 : … interpret instruction $00
        $01 : … interpret instruction $01
    …
    else : … unknown instruction encountered
end;
end.
```
Remark that pascal has no infinit loop structure. ‘While true do’ will execute well, but if the compiler doesn’t optimize this, a check will be performed each loop. This will slow up the emulator considerabely.

4. The program
We can now put these lines together into an executable program. To bring the emulator in a defined state we will poke some value’s at the beginning of memory, and set PC to zero. (or with other words: we will set a fake program in memory)

You can find the main program in the file ED64.pas

When we compile memio.pas and ED64.pas, and execute the code we will see the following output:
```
--------------------------------------
Welcome to EL DENDO's c64 emulator
(c) 2006 ir. Marc Dendooven
--------------------------------------
instruction 01
instruction 00
--------------------------------------
emulator error: unknown instruction
PC=0002 IR=03

Execution has been ended
push return to exit
--------------------------------------
```
Quite simple isn’t it? The only thing we still need to do is to ‘fill up the case instruction’ with the machine code instructions for the 6510 processor. This will be done in Chapter 2

