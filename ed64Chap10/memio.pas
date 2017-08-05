(*****************************************************************
* ED64 : EL DENDO's Commodore 64 emulator                        *
* Memory and IO unit                                             *
* (c) 2006 - 2009 by ir. Marc Dendooven                           *
* Versie Chapter 10                                              *
*****************************************************************)
unit memio;
(****************************************************************)
interface

procedure poke(address : word ; value : byte);
function  peek(address : word) : byte;
function  vicPeek(address : word) : byte;
procedure setVicVMwatchRange(startAddress,endAddress : word);
procedure setVicPMwatchRange(startAddress,endAddress : word);
(****************************************************************)


implementation

uses vic;

var
    ram         : array [$0000..$FFFF] of byte;
    basic_rom   : array [$A000..$BFFF] of byte;
    kernal_rom  : array [$E000..$FFFF] of byte;
    char_rom    : array [$D000..$DFFF] of byte;

    loram, hiram, charen , hiANDlo, hiORlo: boolean;

    watchVicVMfrom,watchVicVMto : word;
    watchVicPMfrom,watchVicPMto : word;

procedure setVicVMwatchRange(startAddress,endAddress : word);
begin
    watchVicVMfrom := startAddress;
    watchVicVMto := endAddress;
end;

procedure setVicPMwatchRange(startAddress,endAddress : word);
begin
    watchVicPMfrom := startAddress;
    watchVicPMto := endAddress;
end;

procedure ioport(port : byte);
var     maskedPort : byte;
begin
        maskedPort     := port and ram[0];
        loram          := boolean (maskedport and 1);
        hiram          := boolean (maskedPort and 2);
        charen         := boolean (maskedport and 4);
        hiANDlo        := hiram and loram;
        hiORlo         := hiram or loram;
end;

function ioIn(address : word) : byte;
begin
    case address of
        $D000..$D02E : ioIn := vicRead(address);
        $D800..$DBFF : ioIn := colorRead(address);
    else
        ioIn := $FF
    end
end;

procedure ioOut(address : word ; value : byte);
begin
	case address of
		$D000..$D02E : vicWrite(address,value);
		$D800..$DBFF : colorWrite(address, value);
		$DD00 : vicBank(value);
	else
		;	
	end	
end;

procedure poke(address : word ; value : byte);
begin
    ram[address] := value;
    if (address >= watchVicVMfrom) and (address <= watchVicVMto) then VicVMupdate(address-watchVicVMFrom,value);
    if (address >= watchVicPMfrom) and (address <= watchVicPMto) then VicPMupdate(address-watchVicPMFrom,value);
    case address of
        $0001        : ioport(value);
        $D000..$DFFF : if hiORlo then ioOut(address,value); //invloed charen ??
    end
end;

function peek(address : word) : byte;
begin
    case address of
        $A000..$BFFF : if hiANDlo then peek := basic_rom[address]
                                   else peek := ram[address];
        $D000..$DFFF : if hiORlo then begin
                                           if charen then peek := ioIn(address)
                                                     else peek := char_rom[address];
                                           end
                                   else peek := ram[address];
        $E000..$FFFF : if hiram then peek := kernal_rom[address]
                                else peek := ram[address];
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
    loadrom(char_rom,'char.rom');
    poke (0,$FF);
    poke (1,$FF);
end;

end.
