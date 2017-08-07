(*****************************************************************
* ED64 : EL DENDO's Commodore 64 emulator                        *
* Copyright 2006 by ir. Marc Dendooven                           *
* Version: Chapter 1                                             *
*****************************************************************)
program ED64;

uses memio;

(*****************************************************************
* 6510 registers                                                 *
*****************************************************************)
var
	A,X,Y,S,P,IR : byte;
	PC : word;

(******************************************************************
* Emulator help procedures and functions 						  *
******************************************************************)
procedure error (s: string);
begin
    writeln('--------------------------------------');
    writeln('emulator error: ',s);
    writeln('PC=',hexstr(PC-1,4),' IR=',hexstr(IR,2));
    writeln;
    writeln('Execution has been ended');
    writeln('push return to exit');
    writeln('--------------------------------------');
    readln;
    halt
end;

(******************************************************************
* processor main loop                                             *
******************************************************************)
begin
    writeln('--------------------------------------');
    writeln('Welcome to EL DENDO''s c64 emulator');
    writeln('(c) 2006 ir. Marc Dendooven');
    writeln('--------------------------------------');

    poke($0000,$01);
    poke($0001,$00);
    poke($0002,$03);
    PC := $0000;

    while true do
	begin
		IR := peek(PC);
		inc(PC);
		case IR of
			$00 : writeln ('instruction 00');
			$01 : writeln ('instruction 01');
		else
			error ('unknown instruction ')
		end
        end
end.
