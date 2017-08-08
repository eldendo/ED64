(*****************************************************************
* Memory and IO unit                                             *
* This file is part of ED64                                      *
* Copyright 2006 by ir. Marc Dendooven                           *
* Version: Chapter 3                                             *
*****************************************************************)
unit memio;
(****************************************************************)
interface

procedure poke(address : word ; value : byte);
function  peek(address : word) : byte;
(****************************************************************)


implementation



var
    ram         : array [$0000..$FFFF] of byte;
    basic_rom   : array [$A000..$BFFF] of byte;
    kernal_rom  : array [$E000..$FFFF] of byte;

function io(address : word) : byte;
begin
        case address of
                $D012 : io := $00
        else    
                io := $FF
        end
end;

procedure poke(address : word ; value : byte);
begin
    ram[address] := value;
end;

function peek(address : word) : byte;
begin
    case address of
        $A000..$BFFF : peek := basic_rom[address];
        $D000..$DFFF : peek := io(address);
        $E000..$FFFF : peek := kernal_rom[address]
    else
        peek := ram[address]
    end
end;



procedure loadrom (var rom : array of byte ; filename: string);
var
    f : file of byte;
    b : byte;
    address: word;
begin
        {$i-}
        assign (f,filename);
        reset(f);
        {$i+}
        if ioresult <> 0 then
                begin
                        writeln('file ',filename,' is missing');
                        readln;
                        halt
                end;
        address := low(rom);
        while not eof(f) do
        begin
                read(f,b);
                rom[address] := b;
                inc(address)
        end;
        close(f)
end;

initialization
begin
    loadrom(kernal_rom,'kernal.rom');
    loadrom(basic_rom,'basic.rom')
end;

end.
