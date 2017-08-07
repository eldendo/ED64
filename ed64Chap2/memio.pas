(*****************************************************************
* Memory and IO unit                                             *
* This file is part of ED64                                      *
* Copyright 2006 by ir. Marc Dendooven                           *
* Version: Chapter 2 (same as chapter 1)                         *
*****************************************************************)
unit memio;

(****************************************************************)
interface

procedure poke(address : word ; value : byte);
function  peek(address : word) : byte;
(****************************************************************)

implementation

var
    ram : array [0..$FFFF] of byte;

procedure poke(address : word ; value : byte);
begin
    ram[address] := value;
end;

function peek(address : word) : byte;
begin
    peek := ram[address]
end;

end.
