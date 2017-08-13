(*****************************************************************
* ED64 : EL DENDO's Commodore 64 emulator                        *
* Copyright (c) 2007 by ir. Marc Dendooven                       *
* Version : Chapter 8 (same as chapter 7)                        *
*****************************************************************)
program ED64;

uses memio, SystemAbstraction, SysUtils, DateUtils;

(*****************************************************************
* 6510 registers                                                 *
*****************************************************************)
var
        A,X,Y,S,P,IR : byte;
        PC : word;

(*****************************************************************
* help variabels                                                 *
*****************************************************************)
var
//        trace : boolean;

        startTime : TDateTime;
        timer50hz : Int64 = 20;
(******************************************************************
* Emulator help procedures and functions                                                  *
******************************************************************)
procedure error (s: string);
begin
    closeScreen;
    writeln;
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

function peek2(address : word) : word;
begin
        peek2 := peek(address) + peek(address + 1) * 256
end;

(*
procedure dump1;
begin
        write('PC=',hexstr(PC,4),' IR=',hexstr(IR,2));
end;

procedure dump2;
begin
        writeln(' A=',hexstr(A,2),' X=',hexstr(X,2),' Y=',hexstr(Y,2),
        ' S=',hexstr(S,2),' P=',binstr(P,8));
end;
*)

(******************************************************************
* load and save routines                                          *
******************************************************************)
procedure load_prg (filename : string ; basic : boolean);
var     f : file of byte;
        b : byte;
        address : word;
begin
        {$i-}
        assign (f,filename);
        reset(f);
        {$i+}
        if ioresult <> 0
        then
                aWriteLn('No file named '+filename)
        else
           begin
                read(f,b);
                address := b;
                read(f,b);
                address := address + b*256;
                if basic then address := 2048;
                while not eof(f) do
                    begin
                        read(f,b);
                        poke(address,b);
                        inc(address)
                    end;
                close(f);
                poke ($2D,lo(address));
                poke ($2E,hi(address));
                PC := $A52A
           end;
end;

procedure save_prg (filename : string ; from_address,to_address : word);
var     f : file of byte;
        i : word;
begin
        assign (f,filename);
        rewrite(f);
        write(f,lo(from_address));
        write(f,hi(from_address));
        for i := from_address to to_address do write(f,peek(i));
        close(f)
end;

(******************************************************************
* Keyboard routine                                                *
******************************************************************)
procedure addkey;
var     buff,ch : byte;
        filename: string;
begin
        buff := peek($C6);
        if buff < 10 then
                begin   ch := ord(upcase(aReadKey));
                        if ch = 0 then
                           begin
                                ch := ord(aReadKey);
                                case ch of
                                $48 : ch := 145; //up
                                $4b : ch := 157; //left
                                $50 : ch :=  17; //down
                                $4D : ch :=  29; //right
                                 82 : ch := 148; //inst-del
                                 133 : begin
                                         fileName := getFileName('EMULATOR LOAD. FILENAME: ');
                                         load_prg (filename+'.prg',true)
                                       end;
                                 135 : begin
                                         fileName := getFileName('EMULATOR LOAD,x,1. FILENAME: ');
                                         load_prg (filename+'.prg',false)
                                       end;
                                 134 : begin
                                         fileName := getFileName('EMULATOR SAVE. FILENAME: ');
                                         save_prg (filename+'.prg',2048,peek2($2D))
                                       end;
                                end;
                           end;
                        poke($0277+buff,ch);
                        poke($C6,buff+1)
                end

end;

(******************************************************************
* Addressing modes: functions which return the address for        *
* instructions to work upon                                       *
******************************************************************)
function imm : word;
begin
        imm := PC;
        inc(PC)
end;

function zp : byte;
begin
        zp := peek(PC);
        inc(PC)
end;

function zpx : byte;
begin
        zpx := peek(PC)+X;
        inc(PC)
end;

function zpy : byte;
begin
        zpy := peek(PC)+Y;
        inc(PC)
end;

function abs : word;
begin
        abs := peek2(PC);
        inc(PC,2)
end;

function absx : word;
begin
        absx := peek2(PC) + X;
        inc(PC,2)
end;

function absy : word;
begin
        absy := peek2(PC) + Y;
        inc(PC,2)
end;

function ind : word;
begin
        ind := peek2(peek2(PC));
        inc(PC,2)
end;

function indx : word;
begin
        indx := peek2(byte(peek(PC)+X));
        inc(PC)
end;

function indy : word;
begin
        indy := peek2(peek(PC)) + Y;
        inc(PC)
end;

(********************************************************************
* Actions on Status Register (P)    NV.BDIZC                        *
********************************************************************)

const
        C = $01;
        Z = $02;
        I = $04;
        D = $08;
        B = $10;
        V = $40;
        N = $80;

procedure setflag (flag : byte; status : boolean);
begin
        if status       then P := P or flag
                        else P := P and not flag
end;

function flagset (flag : byte) : boolean;
begin
        flagset := boolean(P and flag)
end;

(********************************************************************
* Stack operations                                                  *
********************************************************************)

procedure push (b : byte);
begin
        poke ($100+S,b);
        dec(S)
end;

function pull : byte;
begin
        inc(S);
        pull := peek($100+S)
end;

(******************************************************************
* generic branching instructions                                  *
******************************************************************)
procedure bfs (flag : byte);
begin
        if flagset(flag)   then PC := PC + shortint(peek(PC)) + 1
                           else inc(PC)
end;

procedure bfc (flag : byte);
begin
        if flagset(flag)   then inc(PC)
                           else PC := PC + shortint(peek(PC)) + 1
end;

(********************************************************************
* Instructions                                                                              *
********************************************************************)

procedure adc (address : word);
var     H : word;
        val : byte;
begin
        val := peek(address);
        H := A + val;
        if flagset(C) then H := H + 1;
        SetFlag(V,boolean((not (A xor val) and $80) and ((A xor H) and  $80)));
        A := H;
        setflag(C,H > $FF);
        setflag(Z,A = 0);
        setflag(N,A >= $80);
end;

procedure sbc (address : word);
var     H : word;
        val : byte;
begin
        val := peek(address);
        H := A - val;
        if not flagset(C) then H := H - 1;
        SetFlag(V,boolean(((A xor val) and $80) and ((A xor H) and  $80)));
        A := H;
        setflag(C,H<=$FF);
        setflag(Z,A=0);
        setflag(N,A>=$80);
end;

procedure and_ (address : word);
begin
        A := A and peek(address);
        setflag(Z,A=0);
        setflag(N,A>=$80);
end;

procedure ora (address : word);
begin
        A := A or peek(address);
        setflag(Z,A=0);
        setflag(N,A>=$80);
end;

procedure asl_A;
begin
        setflag(C,boolean(A and $80));
        A := A shl 1;
        setflag(Z,A=0);
        setflag(N,A>=$80);
end;

procedure asl (address : word);
var B : byte;
begin
        B := peek(address);
        setflag(C,boolean(B and $80));
        B := B shl 1;
        poke(address,B);
        setflag(Z,B=0);
        setflag(N,B>=$80)
end;

procedure rol_A;
var bit : boolean;
begin
        bit := flagset(C);
        setflag(C,boolean(A and $80));
        A := A shl 1;
        if bit then A := A or $01;
        setflag(Z,A=0);
        setflag(N,A>=$80);
end;

procedure rol (address : word);
var B : byte;
    bit : boolean;
begin
        B := peek(address);
        bit := flagset(C);
        setflag(C,boolean(B and $80));
        B := B shl 1;
        if bit then B := B or $01;
        poke(address,B);
        setflag(Z,B=0);
        setflag(N,B>=$80)
end;

procedure ror_A;
var bit : boolean;
begin
        bit := flagset(C);
        setflag(C,boolean(A and $01));
        A := A shr 1;
        if bit then A := A or $80;
        setflag(Z,A=0);
        setflag(N,A>=$80);
end;

procedure ror (address : word);
var B : byte;
    bit : boolean;
begin
        B := peek(address);
        bit := flagset(C);
        setflag(C,boolean(B and $01));
        B := B shr 1;
        if bit then B := B or $80;
        poke(address,B);
        setflag(Z,B=0);
        setflag(N,B>=$80)
end;

procedure lsr_A;
begin
        setflag(C,boolean(A and $01));
        A := A shr 1;
        setflag(Z,A=0);
        setflag(N,false);
end;

procedure lsr (address : word);
var B : byte;
begin
        B := peek(address);
        setflag(C,boolean(B and $01));
        B := B shr 1;
        poke(address,B);
        setflag(Z,B=0);
        setflag(N,false);
end;

procedure bit (address : word);
var H : byte;
begin
        H := peek(address);
        setflag(N,boolean(H and $80));
        setflag(V,boolean(H and $40));
        setflag(Z,(H and A)=0)
end;



procedure brk;
begin
        setflag(B,true);
        inc(PC);
        push(hi(PC));
        push(lo(PC));
        push(P);
        setflag(I,true);
        PC := peek2($FFFE)
end;

procedure cmp (address : word);
var H : word;
begin
        H := A - peek(address);
        setflag(C,H<=$FF);
        setflag(Z,lo(H)=0);
        setflag(N,lo(H)>=$80)
end;

procedure cpx (address : word);
var H : word;
begin
        H := X - peek(address);
        setflag(C,H<=$FF);
        setflag(Z,lo(H)=0);
        setflag(N,lo(H)>=$80)
end;

procedure cpy (address : word);
var H : word;
begin
        H := Y - peek(address);
        setflag(C,H<=$FF);
        setflag(Z,lo(H)=0);
        setflag(N,lo(H)>=$80)
end;

procedure dec_ (address : word);
var H : word;
begin
        H := peek(address) - 1;
        poke (address,H);
        setflag(Z,lo(H)=0);
        setflag(N,lo(H)>=$80)
end;

procedure dex;
var H : word;
begin
        H := X - 1;
        X := H;
        setflag(Z,X=0);
        setflag(N,X>=$80)
end;

procedure dey;
var H : word;
begin
        H := Y - 1;
        Y := H;
        setflag(Z,lo(H)=0);
        setflag(N,lo(H)>=$80)
end;

procedure eor (address : word);
begin
        A := A xor peek(address);
        setflag(Z,A=0);
        setflag(N,A>=$80);
end;

procedure inc_ (address : word);
var H : word;
begin
        H := peek(address) + 1;
        poke (address,H);
        setflag(Z,lo(H)=0);
        setflag(N,lo(H)>=$80)
end;

procedure inx;
var H : word;
begin
        H := X + 1;
        X := H;
        setflag(Z,X=0);
        setflag(N,X>=$80)
end;

procedure iny;
var H : word;
begin
        H := Y + 1;
        Y := H;
        setflag(Z,Y=0);
        setflag(N,Y>=$80)
end;

procedure jmp (address : word);
begin
        PC := address;
end;

procedure jsr (address : word);
begin
        dec(PC);
        push(hi(PC));
        push(lo(PC));
        PC := address
end;

procedure rts;
begin
        PC := pull;
        PC := PC + pull*256 + 1
end;

procedure rti;
begin
        P := pull;
        PC := pull;
        PC := PC + pull*256
end;




procedure lda (address : word);
begin
        A := peek (address);
        setflag(Z,A=0);
        setflag(N,A>=$80)
end;

procedure ldx (address : word);
begin
        X := peek (address);
        setflag(Z,X=0);
        setflag(N,X>=$80)
end;

procedure ldy (address : word);
begin
        Y := peek (address);
        setflag(Z,Y=0);
        setflag(N,Y>=$80)
end;

procedure pla;
begin
        A := pull;
        setflag(Z,A=0);
        setflag(N,A>=$80)
end;

procedure sta (address : word);
begin
        poke (address, A)
end;

procedure stx(address : word);
begin
        poke (address, X)
end;

procedure sty (address : word);
begin
        poke (address, Y)
end;

procedure tax;
begin
        X := A;
        setflag(Z,X=0);
        setflag(N,X>=$80)
end;

procedure tay;
begin
        Y := A;
        setflag(Z,Y=0);
        setflag(N,Y>=$80)
end;

procedure tsx;
begin
        X := S;
        setflag(Z,X=0);
        setflag(N,X>=$80)
end;

procedure txa;
begin
        A := X;
        setflag(Z,A=0);
        setflag(N,A>=$80)
end;

procedure txs;
begin
        S := X;
end;

procedure tya;
begin
        A := Y;
        setflag(Z,A=0);
        setflag(N,A>=$80)
end;

(******************************************************************
* interrupts and reset                                            *
******************************************************************)
procedure irq;
begin
    if not flagset(I) then
    begin
        setflag(B,false);
        push(hi(PC));
        push(lo(PC));
        push(P);
        setflag(I,true);
        PC := peek2($FFFE);
        if aKeyPressed then addkey;
        timer50Hz := timer50Hz+20
    end
end;

procedure nmi;
begin
    setflag(B,false);
    push(hi(PC));
    push(lo(PC));
    push(P);
    setflag(I,true);
    PC := peek2($FFFA)
end;

procedure reset;
begin
    PC := peek2($FFFC);
    setflag(I,true)
end;

(******************************************************************
* processor main loop                                             *
******************************************************************)
begin
    writeln('--------------------------------------');
    writeln('Welcome to EL DENDO''s c64 emulator');
    writeln('(c) 2006 ir. Marc Dendooven');
    writeln('--------------------------------------');

    openScreen;

//    trace := true;

    PC := peek2($FFFC);
//    cursorOff;

    startTime := now;


    while true do
        begin
            IR := peek(PC);
//            if PC=$fd9a then trace := true;
//            if trace then dump1;
            inc(PC);
            case IR of
                $69 : adc(imm);
                $65 : adc(zp);
                $75 : adc(zpx);
                $6D : adc(abs);
                $7D : adc(absx);
                $79 : adc(absy);
                $61 : adc(indx);
                $71 : adc(indy);

                $29 : and_(imm);
                $25 : and_(zp);
                $35 : and_(zpx);
                $2D : and_(abs);
                $3D : and_(absx);
                $39 : and_(absy);
                $21 : and_(indx);
                $31 : and_(indy);

                $0A : asl_A;
                $06 : asl(zp);
                $16 : asl(zpx);
                $0E : asl(abs);
                $1E : asl(absx);

                $90 : bfc(C); //bcc

                $B0 : bfs(C); //bcs

                $F0 : bfs(Z); //beq

                $24 : bit(zp);
                $2C : bit(abs);

                $30 : bfs(N); //bmi

                $D0 : bfc(Z); //bne

                $10 : bfc(N); //bpl

                $00 : brk;

                $50 : bfc(V); //bvc

                $70 : bfs(V); //bvs

                $18 : setflag(C,false); //clc

                $D8 : setflag(D,false); //cld

                $58 : setflag(I,false); //cli

                $B8 : setflag(V,false); //clv

                $C9 : cmp(imm);
                $C5 : cmp(zp);
                $D5 : cmp(zpx);
                $CD : cmp(abs);
                $DD : cmp(absx);
                $D9 : cmp(absy);
                $C1 : cmp(indx);
                $D1 : cmp(indy);

                $E0 : cpx(imm);
                $E4 : cpx(zp);
                $EC : cpx(abs);

                $C0 : cpy(imm);
                $C4 : cpy(zp);
                $CC : cpy(abs);

                $C6 : dec_(zp);
                $D6 : dec_(zpx);
                $CE : dec_(abs);
                $DE : dec_(absx);

                $CA : dex;

                $88 : dey;

                $49 : eor(imm);
                $45 : eor(zp);
                $55 : eor(zpx);
                $4D : eor(abs);
                $5D : eor(absx);
                $59 : eor(absy);
                $41 : eor(indx);
                $51 : eor(indy);

                $E6 : inc_(zp);
                $F6 : inc_(zpx);
                $EE : inc_(abs);
                $FE : inc_(absx);

                $E8 : inx;

                $C8 : iny;

                $4C : jmp(abs);
                $6C : jmp(ind);

                $20 : jsr(abs);

                $A9 : lda(imm);
                $A5 : lda(zp);
                $B5 : lda(zpx);
                $AD : lda(abs);
                $BD : lda(absx);
                $B9 : lda(absy);
                $A1 : lda(indx);
                $B1 : lda(indy);

                $A2 : ldx(imm);
                $A6 : ldx(zp);
                $B6 : ldx(zpy);
                $AE : ldx(abs);
                $BE : ldx(absy);

                $A0 : ldy(imm);
                $A4 : ldy(zp);
                $B4 : ldy(zpx);
                $AC : ldy(abs);
                $BC : ldy(absx);

                $4A : lsr_A;
                $46 : lsr(zp);
                $56 : lsr(zpx);
                $4E : lsr(abs);
                $5E : lsr(absx);

                $EA : ; // nop

                $09 : ora(imm);
                $05 : ora(zp);
                $15 : ora(zpx);
                $0D : ora(abs);
                $1D : ora(absx);
                $19 : ora(absy);
                $01 : ora(indx);
                $11 : ora(indy);

                $48 : push(A); //pha

                $08 : push(P); //php

                $68 : pla;

                $28 : P := pull; //plp

                $2A : rol_A;
                $26 : rol(zp);
                $36 : rol(zpx);
                $2E : rol(abs);
                $3E : rol(absx);

                $6A : ror_A;
                $66 : ror(zp);
                $76 : ror(zpx);
                $6E : ror(abs);
                $7E : ror(absx);

                $40 : rti;

                $60 : rts;

                $E9 : sbc(imm);
                $E5 : sbc(zp);
                $F5 : sbc(zpx);
                $ED : sbc(abs);
                $FD : sbc(absx);
                $F9 : sbc(absy);
                $E1 : sbc(indx);
                $F1 : sbc(indy);

                $38 : setflag(C,true);     //sec

                $F8 : setflag(D,true);     //sed

                $78 : setflag(I,true);     //sei

                $85 : sta(zp);
                $95 : sta(zpx);
                $8D : sta(abs);
                $9D : sta(absx);
                $99 : sta(absy);
                $81 : sta(indx);
                $91 : sta(indy);

                $86 : stx(zp);
                $96 : stx(zpy);
                $8E : stx(abs);

                $84 : sty(zp);
                $94 : sty(zpx);
                $8C : sty(abs);

                $AA : tax;

                $A8 : tay;

                $BA : tsx;

                $8A : txa;

                $9A : txs;

                $98 : tya;
            else
                error ('unknown instruction ')
            end;
//            if trace then dump2;
            if millisecondsbetween(now ,startTime)*6 > timer50Hz*5 then
                begin
                    irq;
                    if CloseScreenRequest then error('close button pushed');
                end
    end
end.
