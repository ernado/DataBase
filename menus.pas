{Menus 0.1.5 by Razumov}
unit menus;

interface
<<<<<<< HEAD
uses errors, lists, crt, locale;
=======
uses errors, lists, crt, localization, helpers{, graph};

const
  BUTTON_COLOR = 7;
  TEXT_COLOR = 0;
  FOCUS_COLOR = 9;


>>>>>>> origin/master
type TMenu = object
     buttons:TStringList;
     code:byte;
     focus:byte;
     online:boolean;
     msg:string;
     private
<<<<<<< HEAD
     function Show(msg:string):byte;
     function ShowInput(msg:string):string;
=======
     procedure Render;
     function ShowG:byte;
     function Show:byte;
     function ShowInput:string;
     {procedure ChangeMode;    }
>>>>>>> origin/master
end;

procedure MainMenu;

implementation

function TMenu.Show(msg):byte;
var
  c:char;
  i:byte;
begin
  context.Deep('MenuShow');
  if buttons.count=0 then raiseError('NO BUTTONTS IN MENU');
  focus := 1; online:=true; {init}
  repeat
        {render}
        ClrScr;
        textColor(white);
        WriteLn(S_PROGRAMNAME);
<<<<<<< HEAD
        if (msg<>'') then WriteLn(msg);
=======
        WriteLn(msg);
>>>>>>> origin/master
        for i:=1 to buttons.count do
        begin
             textColor(TEXT_COLOR);
             TextBackGround(BUTTON_COLOR);
             if (i=focus) then
             begin
                  TextColor(TEXT_COLOR);
                  TextBackGround(FOCUS_COLOR);
             end;
             WriteLn(buttons.Get(i));
        end;
        TextBackGround(0);
        {input}
        c:=ReadKey;
        case c of
             #72: if (focus = buttons.count) then focus := 1 else inc(focus);
             #80: if (focus = 1) then focus := buttons.count else dec(focus);
             #13: begin online:=false; Show:=focus; end;
             #8 : begin online:=false; Show:=0; end;
        end;
  until not online;
  context.Up;
end;

function TMenu.ShowInput:string;
var
  _t:string;
begin
  context.Deep('ShowInput');
  {render}
  textColor(white);
  WriteLn(S_PROGRAMNAME);
  textColor(7);
  WriteLn(msg);

  {input}
  TextColor(white);
  TextBackGround(8);
  ReadLn(_t);
  ShowInput:=_t;
  context.Up;
end;

procedure TMenu.Render;
begin
  context.Deep('Render');
  raiseError('NotImplemented');
  context.Up;
end;

function TMenu.ShowG:byte;
begin
  context.Deep('ShowG');
  raiseError('NotImplemented');
  context.Up;
end;

procedure MainMenu;
var
  menu:TMenu;
begin
  context.Deep('MainMenu');
  with menu.buttons do begin
       Add(S_SEARCH);
       Add(S_DELETE);
       Add(S_ADD);
  end;
  menu.msg:=S_MAINMSG;

  menu.Show;
  raiseError('NotImplemented');
  context.Up;
end;

end.

