(*****************************************************************
* ED64 : EL DENDO's Commodore 64 emulator                        *
* VIC emulation unit                                             *
* (c) 2006 - 2009 by ir. Marc Dendooven                          *
* Versie Chapter 10                                              *
*****************************************************************)

Unit vic;
(****************************************************************)
interface

uses SystemAbstraction;

procedure vicVMupdate(pos: word; val: byte);
procedure vicPMupdate(pos: word; val: byte);
function  vicRead(address : word) : byte;
procedure vicWrite(address : word ; val : byte);
procedure colorWrite(address : word; color : nibble);
function  colorRead(address : word) : nibble;
procedure vicBank(val : byte);
(****************************************************************)

implementation

uses memio;

const CMbase = $D800;
       SCM = $00;
       MCCM = $10;
       ECCM = $40;
       SBMM = $20;
       MCBMM = $30;

var
    bankAddress : word;
    VMbase : word;
    PMbase : word;
    reg : array[$D000..$D02E] of byte;
    color_ram : array[$D800..$DBFF] of nibble;

    bmm : boolean;
    vidMode : byte = $00;
    PMlenght : word = 1999;

procedure refresh;
var i : word;
begin
        for i := 0 to 999 do poke (VMbase+i,peek(VMbase+i))
end;

procedure setVicValues;
begin
        vidMode := (reg[$D011] and $60) or (reg[$D016] and $10);
(*      case vidMode of
            SCM    : writeln ('video mode : SCM');
            MCCM   : writeln ('video mode : MCCM');
            ECCM   : writeln ('video mode : ECCM');
            SBMM   : writeln ('video mode : SBMM');
            MCBMM  : writeln ('video mode : MCBMM')
        end;   *)
        bmm := boolean (vidmode and $20);
        VMbase := bankAddress + (reg[$D018] shr 4)*$400;
        if bmm then begin
                        PMbase := bankAddress + (reg[$D018] and $08)*$400;
                        PMlenght := 7999
                     end
               else begin
                        PMbase := bankAddress + (reg[$D018] and $0E)*$400;
                        PMlenght := 1999
                     end;
        setVicVMwatchRange(VMbase,VMbase+999);
        setVicPMwatchRange(PMbase,PMbase+PMlenght);
//       refresh
end;

procedure vicBank(val : byte);
begin
    bankAddress := not(val and 3) * $4000;
    setVicValues
end;

procedure colorWrite(address : word; color : nibble);
begin
    color_ram[address] := color;
    vicVMupdate(address-CMbase,peek(address-CMbase+VMbase))
end;

function colorRead(address : word) : nibble;
begin
    colorRead := color_ram[address]
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
    setVicValues
end;

procedure updateSCM(pos: word; val: byte);
var x0,y0,x,y:integer;
begin
       x0:=(pos mod 40)*8;
       y0:=(pos div 40)*8;
       for x:=0 to 7 do
          for y := 0 to 7 do
             if boolean(vicPeek(PMbase+val*8+y) and ($80 shr x))
                   then setPixel(x0+x,y0+y,color_ram[CMbase+pos])
                   else setPixel(x0+x,y0+y,reg[$D021])
end;

procedure updateECCM(pos: word; val: byte);
var x0,y0,x,y:integer;
    bg : byte;
begin
       x0:=(pos mod 40)*8;
       y0:=(pos div 40)*8;
       bg := (val and $C0) shr 6;
       val := val and $3F;
       for x:=0 to 7 do
          for y := 0 to 7 do
             if boolean(vicPeek(PMbase+val*8+y) and ($80 shr x))
                   then setPixel(x0+x,y0+y,color_ram[CMbase+pos])
                   else setPixel(x0+x,y0+y,reg[$D021+bg])
end;

procedure updateMCCM(pos: word; val: byte);
var x0,y0,x,y:integer;
begin
    if boolean(color_ram[CMbase+pos] and $8)
        then
            begin
                x0:=(pos mod 40)*8;
                y0:=(pos div 40)*8;
                for x:=0 to 7 do
                    for y := 0 to 7 do
                        case (vicPeek(PMbase+val*8+y) shr (2*((7-x) div 2))) and 3 of
                            0 : setPixel(x0+x,y0+y,reg[$D021]);
                            1 : setPixel(x0+x,y0+y,reg[$D022]);
                            2 : setPixel(x0+x,y0+y,reg[$D023]);
                            3 : setPixel(x0+x,y0+y,color_ram[CMbase+pos] and $7)
                        end
            end
        else updateSCM (pos,val)
end;

procedure updateSBMM(pos: word; val: byte);
var x0,y0,x,y:integer;
begin
       x0:=(pos mod 40)*8;
       y0:=(pos div 40)*8;
       for x:=0 to 7 do
          for y := 0 to 7 do
             if boolean(vicPeek(PMbase+pos*8+y) and ($80 shr x))
                   then setPixel(x0+x,y0+y,(val and $F0) shr 4)
                   else setPixel(x0+x,y0+y,val and $0F)
end;

procedure updateMCBMM(pos: word; val: byte);
var x0,y0,x,y:integer;
begin
        x0:=(pos mod 40)*8;
        y0:=(pos div 40)*8;
        for x:=0 to 7 do
           for y := 0 to 7 do
              case (vicPeek(PMbase+pos*8+y) shr (2*((7-x) div 2))) and 3 of
                            0 : setPixel(x0+x,y0+y,reg[$D021]);
                            1 : setPixel(x0+x,y0+y,(val and $F0) shr 4);
                            2 : setPixel(x0+x,y0+y,val and $0F);
                            3 : setPixel(x0+x,y0+y,color_ram[CMbase+pos])
              end
end;

procedure vicVMupdate(pos: word; val: byte);
begin
    case vidMode of
        SCM  : updateSCM (pos,val);
        MCCM : updateMCCM(pos,val);
        ECCM : updateECCM(pos,val);
        SBMM : updateSBMM(pos,val);
        MCBMM: updateMCBMM(pos,val);
    else
            aWriteLn ('WARNING: Undefined Video Mode !')
    end
end;

procedure vicPMupdate(pos: word; val: byte);
begin
    if bmm 	then vicVMupdate(pos div 8, vicPeek(VMbase+(pos div 8)))
        //       else refresh;
end;

end.
