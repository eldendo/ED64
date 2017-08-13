(*****************************************************************
* ED64 : EL DENDO's Commodore 64 emulator                        *
* VIC emulation unit                                             *
* (c) 2007 by ir. Marc Dendooven                                 *
* Versie Chapter 8                                               *
*****************************************************************)

Unit vic;
(****************************************************************)
interface

uses SystemAbstraction;

procedure vicText(pos: word; val: byte);
function  vicRead(address : word) : byte;
procedure vicWrite(address : word ; val : byte);
procedure vicBank(val : byte);
(****************************************************************)

implementation

uses memio;


var
    bankAddress : word;
    screenAddress : word;
    charRomAddress: word;
    reg : array[$D000..$D02E] of byte;

procedure vicBank(val : byte);
begin
    bankAddress := not(val and 3) * $4000;
    setVicwatchRange(bankAddress+screenAddress,bankAddress+screenAddress+999);   
end;

function  vicRead(address : word) : byte;
begin
    case address of
        $D012 : vicRead := $00; //raster
    else
        vicRead := reg[address]
    end
end;

procedure vicWrite(address : word ; val : byte);
begin
    reg[address] := val;
    case address of
        $D018 : begin
                    screenAddress := (val shr 4)*$400;
                    setVicwatchRange(bankAddress+screenAddress,bankAddress+screenAddress+999);
                    charRomAddress := (val and $0E)*$400;
                end
    end
end;

procedure vicText(pos: word; val: byte);
var x0,y0,x,y:integer;
begin
       x0:=(pos mod 40)*8;
       y0:=(pos div 40)*8;
       for x:=0 to 7 do
          for y := 0 to 7 do
             if boolean(vicPeek(bankAddress+charRomAddress+val*8+y) and ($80 shr x))
                   then setPixel(x0+x,y0+y,14) //lightblue
                   else setPixel(x0+x,y0+y,6)  //blue


end;



end.
