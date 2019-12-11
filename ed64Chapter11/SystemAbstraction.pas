(*****************************************************************
* SystemAbstraction unit                                         *
* This file is part of ED64                                      *
* Copyright (c) 2006 - 2019 by ir. Marc Dendooven                *
* Version: Chapter 11                                            *
*****************************************************************)
Unit SystemAbstraction;



(****************************************************************)
interface



type nibble = 0..15;

procedure openScreen;
procedure closeScreen;
procedure setPixel(x,y : word; color: nibble);
function closeScreenRequest : Boolean;

procedure aWriteLn (s: string);
function aKeyPressed : boolean;
function aReadKey : char;

function getFileName(msg:string): string;

(****************************************************************)
implementation


uses ptcGraph, ptcCRT;// memio;


var gd,gm : integer;
    PixelSize : byte;
    closeRequest: boolean = false;
(*
procedure OpenScreen;
Begin
 Writeln('Graphics Initialised.');
 gd := Detect;
 InitGraph(gd, gm,'');
end;
*)
procedure openscreen;
var res : char;
begin
    writeln ('Choose graphic resolution');
    writeln;
    writeln ('0. Default       4. 1024x768');
    writeln ('1. 320x200       5. 1280x1024');
    writeln ('2. 640x480                   ');
    writeln ('3. 800x600                   ');
    writeln;
    writeln ('Your choise : (another value sets to Default) ');
    readln (res);
    case res of
        '1' : gm := m320x200;
        '2' : gm := m640x480;
        '3' : gm := m800x600;
        '4' : gm := m1024x768;
        '5' : gm := m1280x1024;
        else
            gm := detectMode
    end;

    gd := D8bit;

    initgraph(gd,gm,'ED64');
	if graphresult <> grOK then
	begin
			writeln('graphic mode not supported');
			readln;
			halt(1);
    end;
    pixelsize := (getMaxX+1) div 320;

    SetBkColor(14);
    ClearDevice;
    setviewport((getmaxX-320*pixelSize) div 2,(getMaxY-200*pixelSize) div 2,getmaxX,getMaxY,clipoff);

(*    setPalette(0,black);
    setPalette(1,white);
    setPalette(2,red);
    setPalette(3,cyan);
    setPalette(4,magenta);
    setPalette(5,green);
    setPalette(6,blue);
    setPalette(7,yellow);
    setPalette(8,lightred);
    setPalette(9,brown);
    setPalette(10,lightred);
    setPalette(11,darkgray);
    setPalette(12,lightgray);
    setPalette(13,lightgreen);
    setPalette(14,lightblue);
    setPalette(15,lightgray) *)
    
 (* followin colorscheme :   
    http://www.pepto.de/projects/colorvic/
    Philip "Pepto" Timmermann, <pepto@pepto.de>
 *)   
setRGBpalette(0,$00, $00, $00);
setRGBpalette(1,$FF, $FF, $FF);
setRGBpalette(2,$68, $37, $2B);
setRGBpalette(3,$70, $A4, $B2);
setRGBpalette(4,$6F, $3D, $86);
setRGBpalette(5,$58, $8D, $43);
setRGBpalette(6,$35, $28, $79);
setRGBpalette(7,$B8, $C7, $6F);
setRGBpalette(8,$6F, $4F, $25);
setRGBpalette(9,$43, $39, $00);
setRGBpalette(10,$9A, $67, $59);
setRGBpalette(11,$44, $44, $44);
setRGBpalette(12,$6C, $6C, $6C);
setRGBpalette(13,$9A, $D2, $84);
setRGBpalette(14,$6C, $5E, $B5);
setRGBpalette(15,$95, $95, $95);

end;

procedure closeScreen;
begin
    closeGraph
end;

procedure setPixel(x,y : word; color : nibble);
begin
//    putpixel(x,y,color)
	setFillStyle(solidFill,color);
	Bar(x*pixelSize,y*pixelSize,(x+1)*pixelSize-1,(y+1)*pixelSize-1);
end;

function closeScreenRequest : Boolean;
begin
    closeScreenRequest := closeRequest
end;

procedure aWriteLn (s: string);
begin
    outText(s)
end;

function aKeyPressed : boolean;
begin
    aKeyPressed := keyPressed;
//  delay(5)
end;

function aReadKey : char;
begin
    aReadKey := readKey;
    if aReadKey = #3 then closeRequest := true;
end;

function getFileName(msg:string): string;
var filename : string ='';
	ch: char;
begin
    outText(msg);
    repeat
		if keypressed then begin 	ch := readKey;
									if ch <> chr(13) then begin outText(ch); filename := filename+ch end 
						   end
    until ch = chr(13);
    getFileName := filename;
end;

end.
