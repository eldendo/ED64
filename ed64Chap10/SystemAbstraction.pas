(*****************************************************************
* SystemAbstraction unit                                         *
* This file is part of ED64                                      *
* Copyright (c) 2006 - 2009 by ir. Marc Dendooven                *
* Version: Chapter 10 (same as chapter 9)                        *
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

uses WinGraph, WinCRT, memio;

var gd,gm : integer;
    PixelSize : byte;

procedure openscreen;
var res : char;
begin
    writeln ('Choose graphic resolution');
    writeln;
    writeln ('0. Default       4. 1024x768');
    writeln ('1. 320x200       5. 1280x1024');
    writeln ('2. 640x480       6. Maximized');
    writeln ('3. 800x600       7. Fullscreen');
    writeln;
    writeln ('Your choise : (another value sets to Default) ');
    readln (res);
    case res of
        '1' : gm := m320x200;
        '2' : gm := m640x480;
        '3' : gm := m800x600;
        '4' : gm := m1024x768;
        '5' : gm := m1280x1024;
        '6' : gm := mMaximized;
        '7' : gm := mFullscr
        else
            gm := mDefault
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

    setPalette(0,black);
    setPalette(1,white);
    setPalette(2,red);
    setPalette(3,cyan);
    setPalette(4,purple);
    setPalette(5,green);
    setPalette(6,blue);
    setPalette(7,yellow);
    setPalette(8,orange);
    setPalette(9,brown);
    setPalette(10,lightred);
    setPalette(11,darkgray);
    setPalette(12,gray);
    setPalette(13,lightgreen);
    setPalette(14,lightblue);
    setPalette(15,lightgray)
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
    closeScreenRequest := closeGraphRequest
end;

procedure aWriteLn (s: string);
begin
    writeBuf(s)
end;

function aKeyPressed : boolean;
begin
    aKeyPressed := keyPressed;
end;

function aReadKey : char;
begin
    aReadKey := readKey;
end;

function getFileName(msg:string): string;
var filename : string;
begin
    writebuf(msg);
    readbuf (filename,40);
    getFileName := filename;
end;

end.
