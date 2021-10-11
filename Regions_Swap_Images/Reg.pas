unit Reg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

const // для Button
 ColDark=clGray;
 ColNorm=clSilver;
 ColLight=clWhite;
 XPos=10;
 YPos=300;
 dx=1;
 dy=1;

var // для Region
 AR1:array[0..4] of Tpoint=((X:85;Y:190),(X:130;Y:190),
 (X:153;Y:207),(X:129;Y:221),(X:102;Y:221));
 AR2:array[0..3] of Tpoint=((X:54;Y:125),(X:87;Y:125),
 (X:105;Y:147),(X:63;Y:147));
 AR3:array[0..3] of Tpoint=((X:133;Y:131),(X:168;Y:131),
 (X:186;Y:155),(X:147;Y:155));
 AR4:array[0..2] of Tpoint=((X:113;Y:120),(X:136;Y:180),
 (X:96;Y:180));
 AR5:array[0..3] of Tpoint=((X:013;Y:137),(X:037;Y:137),
 (X:016;Y:165),(X:033;Y:173));
 Rgn1,Rgn2,Rgn3,Rgn4,Rgn5: HRGN;
 s: string;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
 Rgn1:=CreatePolygonRgn(AR1,5,WINDING);
 Rgn2:=CreatePolygonRgn(AR2,4,WINDING);
 Rgn3:=CreatePolygonRgn(AR3,4,WINDING);
 Rgn4:=CreatePolygonRgn(AR4,3,WINDING);
 Rgn5:=CreatePolygonRgn(AR5,4,WINDING);
 // для Button
 Form1.Canvas.Brush.Style:=bsClear;
 with Form1.Canvas.Font do
  begin
   Name:='Arial';
   Size:=20;
   Style:=[fsBold];
 end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 DeleteObject(Rgn1);
 DeleteObject(Rgn2);
 DeleteObject(Rgn3);
 DeleteObject(Rgn4);
 DeleteObject(Rgn5);
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if PTInRegion(Rgn1,x,y) then s:=Label4.Caption;
 if PTInRegion(Rgn2,x,y) then s:=Label1.Caption;
 if PTInRegion(Rgn3,x,y) then s:=Label2.Caption;
 if PTInRegion(Rgn4,x,y) then s:=Label3.Caption;
 if PTInRegion(Rgn5,x,y) then s:=Label5.Caption;
end;

procedure TForm1.Button1Click(Sender: TObject);
const
 count=100;
var
 i: integer;
 x, y: integer;
 bm, bm1, bm2: TBitMap;
 p1, p2, p: PByteArray;
 c: integer;
 k: integer;
begin
 bm:=TBitMap.Create;
 bm1:=TBitMap.Create;
 bm2:=TBitMap.Create;
 if OpenDialog1.Execute
 then bm1.LoadFromFile(OpenDialog1.FileName);
 OpenDialog2.FileName:=OpenDialog1.FileName;
 if OpenDialog2.Execute
 then bm2.LoadFromFile(OpenDialog2.FileName);
 if bm1.Height<bm2.Height then
  begin
   bm.Height:=bm1.Height;
   bm2.Height:=bm1.Height;
  end
 else
  begin
   bm.Height:=bm2.Height;
   bm1.Height:=bm2.Height;
  end;
 if bm1.Width<bm2.Width then
  begin
   bm.Width:=bm1.Width;
   bm2.Width:=bm1.Width;
  end
 else
  begin
   bm.Width:=bm2.Width;
   bm1.Width:=bm2.Width;
  end;
 bm.PixelFormat:=pf24bit;
 bm1.PixelFormat:=pf24bit;
 bm2.PixelFormat:=pf24bit;

 Form1.Canvas.Draw(260, 40, bm1);
 for i:=1 to count-1 do
  begin
   for y:=0 to bm.Height-1 do
    begin
     p:=bm.ScanLine[y];
     p1:=bm1.ScanLine[y];
     p2:=bm2.ScanLine[y];
     for x:=0 to bm.Width*3-1 do
      p^[x]:=round((p1^[x]*(count-i)+p2^[x]*i)/count);
    end;
   Form1.Canvas.Draw(260, 40, bm);
   Form1.Caption:=IntToStr(round(i/count*100))+'%';
   Application.ProcessMessages;
   Sleep(10);
   if Application.Terminated
   then Break;
  end;
 Form1.Caption:='Regions / Swap Images';
 Form1.Canvas.Draw(260, 40, bm2);
 bm1.Destroy;
 bm2.Destroy;
 bm.Destroy;
end;

//////////////////////////// для Button

procedure ClickOnForm(wnd: HWND; caption: string);
var
 TheChildHandle: HWND;
begin
 TheChildHandle:=FindWindowEx(wnd, 0, nil, PChar(caption));
 SendMessage(TheChildHandle, WM_LButtonDown, 1, 1);
 SendMessage(TheChildHandle, WM_LButtonUP, 1, 1);
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Form1.Repaint;
 with Form1.Canvas do
 begin
  Font.Color:=ColDark;
  TextOut(XPos-dx, YPos-dy,s);
  Font.Color:=ColLight;
  TextOut(XPos+dx, YPos+dy,s);
  Font.Color:=ColNorm;
  TextOut(XPos,YPos,s);
 end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 with Form1.Canvas do
  begin
   Font.Color:=ColLight;
   TextOut(XPos-dx,YPos-dy,s);
   Font.Color:=ColDark;
   TextOut(XPos+dx,YPos+dy,s);
   Font.Color:=ColNorm;
   TextOut(XPos,YPos,s);
  end;
end;

end.
