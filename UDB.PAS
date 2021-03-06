{UDataBase 1.1 by Razumov}
unit UDB;

interface
uses
  crt, errors, helpers, locale;

const
  MAXIMUM_USER = 30;
  DBFPATH = 'database.db';  {Database file path}
  TMPATH = 'tmp.db';        {Temp file path}

type TUser = object
  firstName:string[11];
  lastName:string[11];
  school:string[20];
  city:string[11];
  dob: string[10];
  id: string[2];
  procedure Print;
  procedure Input;
  constructor Init;
end;

type TUserArray = object
  users:array [1..MAXIMUM_USER] of TUser;
  count:byte;
  constructor Init;
  procedure Get(i:byte;var u:TUser);
  procedure Add(u:TUser);
  {procedure Delete(i:byte); }
  procedure Print;
  procedure Sort(n:byte;direction:boolean);
  private
  procedure Swap(i,j:byte);
end;

type TDataBase = object
     dataFile:text;
     session:boolean;
     public
     constructor init;
     procedure getUser(var user:TUser);
     procedure getBySearch(promt:string;field:byte;var users:TUserArray);
     procedure addUser(user:TUser);
     procedure deteleUser (i:string);
     procedure getRange(start,n:byte;var users:TUserArray);
     private
     procedure openSession;
     procedure closeSession;
     procedure skipToData;
     function checkFormat:boolean;
     procedure skipLine;
     function getLine:string;

end;

implementation

constructor TUserArray.Init;
begin
     count:=0;
end;

procedure TUser.Print;
begin
     WriteLn(fitString(id,2,true),'|',
             fitString(firstName,11,true),'|',
             fitString(lastName,11,true),'|',
             fitString(dob,10,true),'|',
             fitString(city,11,true),'|',
             fitString(school,20,true),'|');
end;

constructor TUser.Init;
begin
     firstname := 'Null';
     lastName := 'Null';
     school := 'Null';
     city := 'Null';
     dob := '01.01.1970';
     id := '00';
end;

procedure TUserArray.Add(u:TUser);
begin
     Context.Deep('TUserArray.Add');

     if (count+1) > MAXIMUM_USER then raiseError(S_STACKOVER);
     inc(count);
     users[count]:=u;

     Context.Up;
end;

procedure TUserArray.Sort(n:byte;direction:boolean);
var
   i,j:byte;
   a,b:string;
begin
     Context.Deep('TUserArray.Sort');
     for i:=1 to count-1 do
         for j:=1 to count-1 do
             begin
              case n of
                   1: begin a:=users[j].firstName; b:=users[j+1].firstName; end;
                   2: begin a:=users[j].lastName; b:=users[j+1].lastName; end;
                   {3: begin a:=users[j].dob; b:=users[j+1].dob; end; }
                   3: begin a:=users[j].city; b:=users[j+1].city; end;
                   4: begin a:=users[j].school; b:=users[j+1].school; end;
              else raiseError('Sort field out of bounds');
              end;

              if direction and (a>b) then
                 swap(j,j+1);
             end;
     Context.Up;
end;

{procedure TUserArray.Delete (i:byte);
begin
     Context.Deep('TUserArray.Delete');
     raiseError(S_NOTIMPL);
     Context.Up;
end;}

procedure TUserArray.Swap(i,j:byte);
var
   t:TUser;
begin
     Context.Deep('Swap');

     {check for bounds}
     if (i<1) or (i>count) then raiseError('OUT OF BOUNDS ERROR');
     if (j<1) or (j>count) then raiseError('OUT OF BOUNDS ERROR');

     {swap}
     t:=users[i];
     users[i]:=users[j];
     users[j]:=t;

     Context.Up;
end;

procedure TUserArray.Get(i:byte; var u:TUser);
begin
     Context.Deep('TUserArray.Get');

     if (i<1) or (i>count) then raiseError('OUT OF BOUNDS ERROR');
     u:=users[i];

     Context.Up;
end;

procedure TUserArray.Print;
var
   user:TUser;
   i:byte;
begin
     context.Deep('TUserArray.Print');

     {render header}
     with user do
     begin
          id:=S_ID;
          firstName:=S_FIRSTNAME;
          lastName:=S_LASTNAME;
          dob:=S_DOB;
          city:=S_CITY;
          school:=S_SCHOOL;
     end;
     user.Print;
     with user do
     begin
          id:='==';
          firstName:='===========';
          lastName:='===========';
          dob:='==========';
          city:='===========';
          school:='====================';
     end;
     user.Print;

     {render users info}
     for i:=1 to count do users[i].Print;

     context.Up;
end;

{������� ���� ������ � ��ࠡ�⪮� �訡��
           path - ���� � ���� ������}
Constructor TDataBase.init;
begin
     context.Deep('DBINIT');

     {$I-}Assign(dataFile,DBFPATH);
     if (IOResult <> 0) then raiseError('IO ERROR');
     {$I+}
     if not checkFormat then raiseError('DATABASE FORMAT ERROR');

     context.Up;
end;

{�஢���� �� ᮮ����⢨� 䠩�� ���� ������}
function TDataBase.checkFormat:boolean;
begin
     context.Deep('CheckFormat');

     openSession;
     checkFormat:= getline = 'database';
     closeSession;

     context.Up;
end;

{���뢠�� 䠩� �� �⥭��}
procedure TDataBase.openSession;
begin
     context.Deep('OpenSession');

     if session then raiseError('SESSION ALREADY OPENED');
     {$I-}
     Reset(dataFile);
     if (IOResult <> 0) then raiseError('IO ERROR');
     {$I+}
     session := true;

     context.Up;
end;

{����뢠�� ����}
procedure TDataBase.closeSession;
begin
     context.Deep('CloseSession');

     if not session then raiseError('NO SESSION TO CLOSE');
     {$I-}
     Close(dataFile);
     if (IOResult <> 0) then raiseError('IO ERROR');
     {$I+}
     session:=false;

     context.Up;
end;

{�ய�᪠�� ��ப� � ���� ������}
procedure TDataBase.skipLine;
begin
     context.Deep('SkipLine');

     if not session then raiseError('NO SESSION ERROR');
     {$I-}
     ReadLn(dataFile);
     if (IOResult <> 0) then raiseError('IO ERROR');
     {$I+}

     context.Up;
end;

{�����頥� ᫥������ ��ப� � 䠩��}
function TDataBase.getLine:string;
var
   _t:string;
begin
     context.Deep('getLine');

     {$I-}
     ReadLn(dataFile,_t);
     if (IOResult <> 0) then raiseError('IO ERROR');
     {$I+}
     getLine := _t;

     context.Up;
end;

{����頥� ��魮��� �� ���� ������}
procedure TDataBase.getUser(var user:Tuser);
begin
     context.Deep('getUser');

     if not session then raiseError('NO SESSION ERROR');
     {$I-}
     if (getLine <> 'user') then raiseError('TYPE ERROR');
     with user do
     begin
          id:='00';
          firstName:=getLine;
          lastName:=getLine;
          dob:=getLine;
          school:=getLine;
          city:=getLine;
     end;
     if (getLine <> 'enduser') then raiseError('TYPE ERROR');
     if (IOResult <> 0) then  raiseError('IO ERROR');
     {$I+}

     context.Up;
end;

{�ய�᪠�� �孨���� ���ଠ��}
procedure TDataBase.skipToData;
begin
     context.Deep('skipToData');

     if session then raiseError('SESSION ALREADY OPENED ERROR');
     openSession;
     skipLine;

     context.Up;
end;

procedure TDataBase.getBySearch(promt:string; field:byte;var users:TUserArray);
var
   id:byte;
   user:TUser;
   s:string;
begin
     context.Deep('getBySearch');

     {init}
     skipToData; {openSession+}
     users.init; user.Init;;
     id:=0;

     {logic}
     repeat
       getUser(user);
       inc(id);
       str(id,user.id);
       case field of
            1: s:=user.firstName;
            2: s:=user.lastName;
            3: s:=user.dob;
            4: s:=user.city;
            5: s:=user.school;
       else raiseError('ARGUMENT OUT OF BOUNDS: UNKNOWN FIELD');
       end;
       if (s=promt) then users.Add(user);
     until eof(dataFile) or (users.count=MAXIMUM_USER);
     closeSession;

     context.Up;
end;

procedure TDataBase.addUser(user:TUser);
begin
     context.Deep('TDB.addUser');

     {$I-}
     if session then raiseError('SESSION OPENED, CANT APPEND');

     Append(dataFile);
     WriteLn(dataFile,'user');
     WriteLn(dataFile,user.firstName);
     WriteLn(dataFile,user.lastName);
     WriteLn(dataFile,user.dob);
     WriteLn(dataFile,user.school);
     WriteLn(dataFile,user.city);
     WriteLn(dataFile,'enduser');

     if IOResult<>0 then raiseError('IO ERROR');
     {$I+}

     context.Up;
end;

procedure TDataBase.deteleUser (i:string);
var
   user:TUser;
   tmp:text;
   id:byte;
begin
     Context.Deep('deleteUser');

     {init}
     {$I-}
     Assign(tmp,TMPATH);
     Rewrite(tmp);
     WriteLn(tmp,'database');
     if IOResult<>0 then raiseError('IO ERROR');
     {$I+}

     skipToData; {openSession+}
     id:=0;
     user.Init;

     {logic}

     repeat
       getUser(user);
       inc(id);
       str(id,user.id);
       if (i<>user.id) then
          with user do
          begin
               WriteLn(tmp,'user');
               WriteLn(tmp,firstName);
               WriteLn(tmp,lastName);
               WriteLn(tmp,dob);
               WriteLn(tmp,school);
               WriteLn(tmp,city);
               WriteLn(tmp,'enduser');
          end;
     until eof(dataFile);
     closeSession; Close(tmp);
     erase(dataFile);
     rename(tmp,DBFPATH);
     Assign(dataFile,DBFPATH);
     Context.Up;
end;

procedure TDataBase.getRange(start,n:byte;var users:TUserArray);
var
   i:byte;
   user:TUser;
begin
     Context.Deep('TDataBase.getRange');

     skipToData;
     i:=0; users.init; user.Init;

     repeat
       getUser(user);
       inc(i);
       str(i,user.id);
       if (i>=start) then
       begin
            users.Add(user);
       end;
     until eof(DataFile) or (users.count=n);

     closeSession;
     Context.Up;
end;

procedure TUser.Input;
begin
  id:='00';
  TextColor(white);
  WriteLn(S_USERINPUT);
  TextColor(LightGray); Write(S_FIRSTNAME,': '); TextColor(white); ReadLn(firstName);
  TextColor(LightGray); Write(S_LASTNAME,': '); TextColor(white); ReadLn(lastName);
  TextColor(LightGray); Write(S_DOB,': '); TextColor(white); ReadLn(dob);
  TextColor(LightGray); Write(S_CITY,': '); TextColor(white); ReadLn(city);
  TextColor(LightGray); Write(S_SCHOOL,': '); TextColor(white); ReadLn(school);
end;

end.
