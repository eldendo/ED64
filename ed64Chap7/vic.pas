(*****************************************************************
* VIC emulation unit                                             *
* This file is part of ED64                                      *
* Copyright 2007 by ir. Marc Dendooven                           *
* Version: Chapter 7 (same as chapter 6)                         *
*****************************************************************)
Unit vic;

(****************************************************************)
interface

procedure vicText(pos: word; val: byte);
(****************************************************************)

implementation

uses memio,SystemAbstraction;



procedure vicText(pos: word; val: byte);
var x0,y0,x,y:integer;
begin
       x0:=(pos mod 40)*8;
       y0:=(pos div 40)*8;
       for x:=0 to 7 do
          for y := 0 to 7 do
             if boolean(vicPeek($1000+val*8+y) and ($80 shr x))
                   then setPixel(x0+x,y0+y,14) //lightblue
                   else setPixel(x0+x,y0+y,6)  //blue

end;



end.
