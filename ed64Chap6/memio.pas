(*****************************************************************
* Memory and IO unit                                             *
* This file is part of ED64                                      *
* Copyright 2007 by ir. Marc Dendooven                           *
* Version: Chapter 6                                             *
*****************************************************************)
unit memio;

(****************************************************************)
interface

procedure poke(address : word ; value : byte);
function  peek(address : word) : byte;
function  vicPeek(address : word) : byte;
(****************************************************************)


implementation

uses vic;

var
    ram         : array [$0000..$FFFF] of byte;
    basic_rom   : array [$A000..$BFFF] of byte;
    kernal_rom  : array [$E000..$FFFF] of byte;
    char_rom    : array [$D000..$DFFF] of byte;

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
    case address of
        $400..$7E7 : VicText(address-$400,value)
    end
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

function  vicPeek(address : word) : byte;
begin
    case address of
		$1000..$1FFF : vicPeek := char_rom[address+$C000];
		$9000..$9FFF : vicPeek := char_rom[address+$4000]
	else
		vicPeek := ram[address]
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
    loadrom(basic_rom,'basic.rom');
    loadrom(char_rom,'char.rom')
end;

end.
