unit poll;

interface

uses
  app, objects, dialogs, views, drivers, menus, MsgBox;  

const
  cmNewpoll = 101;
  cmGetstats = 102;
  cmPass = 103;
  num = 4; 
{count of quesitons. 
Value shoud be equal to number of described questions in 'Body' array}
  
type
  POrder = ^TOrder;
  TOrder = record
    answer: Word;
  end; 
  {structure for keeping radio button answer}
  warehouse = array[1..num, 1..num] of Integer;
  {array for keeping saved answers from passed forms}
  quests = array[1..num] of string;
  {array for keeping text for quesitons}
  session = array[1..num] of Integer; 
  {array for keeping marked answers, whie form not passed}
  
var
  Body: quests; 
  questionIndex: integer;
  tempstr: string;
  {uses for func Str}

type
  PListWindow = ^TListWindow;
  TListWindow = object (TDialog)
    Cluster: PRadioButtons;
    questText   :PView;
    Constructor Init;
    Procedure NextQuestion;
  end;

  PPollApp = ^TPollApp;
  TPollApp = object (TApplication)
    ListWindow: PListWindow;
    PollInfo:TOrder; 
    Arr:warehouse; {array for keeping text for quesitons}
    save:session; {array for keeping marked answers, whie form not passed}
    Constructor Init;
    Procedure InitMenuBar; Virtual;
    Procedure HandleEvent (var event: TEvent); Virtual;
    Procedure Newpoll;
    Procedure StatsResult;
    Procedure InitArray;
    Procedure InitQuestions;
    Procedure PageSwitch;
    Destructor Done; Virtual;
  end;

implementation
{-----------------------------------------------------------------}
Procedure TListWindow.NextQuestion;
var 
   r: Trect;
  Begin  
    if Cluster <> nil then 
      begin
    Delete(Cluster);
    Dispose(Cluster, Done);
    Cluster := nil;
    Delete(questText);
    Dispose(questText, Done);
    questText := nil; 
      end;  
              
    Str(questionIndex, tempstr);
    r.Assign (4, 2, 15, 3);
    Insert(New(PLabel, Init(r, 'Question:' + tempstr, questText)));
    r.Assign (3, 3, 62, 12);
    questText := New(PStaticText, Init(r, Body[questionIndex]));
    Insert(questText);
    
    r.Assign (3, 12, 50, 13);
    Cluster^.Options := Cluster^.Options or ofCenterX; 
    cluster := New(PRadioButtons, Init(r, NewSItem('~A~', 
    NewSItem('~B~', NewSItem('~C~', nil)))));
    Insert(Cluster);
  End;
{-----------------------------------------------------------------}
Constructor TListWindow.Init;
var 
   r: Trect;
  Begin
    r.Assign (0, 0, 65, 15 );
    Inherited Init ( r, '~Questions~');
    options := options or ofcentered;
    
    r.Assign(52, 12, 62, 14);
    Insert(New(PButton, Init(r, '>>>', cmPass, bfDefault)));
  End; 
{-----------------------------------------------------------------}
Constructor TPollApp.Init;
  Begin
    Inherited Init;
    TPollApp.InitArray;
    TPollApp.InitQuestions;
    questionIndex:=1;
  End;
{-----------------------------------------------------------------}
Procedure TPollApp.InitMenuBar;
  var
    r : Trect;
  Begin
    GetExtent(r);
    r.b.y := r.a.y + 1;
    menubar := New (PMenuBar, Init (r, NewMenu(
           newsubmenu ('~Poll~', hcNoContext, 
           newmenu(newitem  ('~S~tart new', '', kbNoKey, cmNewpoll, hcNoContext,
           newitem  ('~G~et stats', '', kbNoKey, cmGetstats, hcNoContext,
           newitem  ('~E~xit', '', kbNoKey, cmQuit, hcNoContext,
           nil)))),  
           nil))));

  End;
{-----------------------------------------------------------------}
Procedure TPollApp.PageSwitch;
var 
  i:integer;
  begin
    if questionIndex <= num then begin
      
      ListWindow^.GetData(PollInfo);
      save[questionIndex] := pollinfo.answer+1;
      questionIndex := questionIndex + 1;          
      ListWindow^.NextQuestion;
    end;
    if questionIndex > num then
    begin
      for i := 1 to num do
          arr[i, save[i]] := arr[i, save[i]] + 1;
      ListWindow^.Hide;
      Str(num, tempstr);
      MessageBox('You passed '+tempstr+' questions'#13 +
      'Your answers saved', nil, mfInformation or mfOkButton);
    end;
   end;
{-----------------------------------------------------------------}
procedure TPollApp.HandleEvent(var Event: TEvent);
  var
    R: TRect;
  begin
    inherited HandleEvent(Event);
    if Event.What = evCommand then
    begin
      case Event.Command of
        cmNewpoll:
          begin
            Newpoll;
            ClearEvent(Event);
          end;
        cmPass:
          begin
            PageSwitch;
            ClearEvent(Event);
          end;
        cmQuit:
          begin
            EndModal(cmQuit);
            ClearEvent(Event);
          end;
        cmGetstats:
          begin
            StatsResult;
            ClearEvent(Event);
          end;
      end;
    end;
  end;
{-----------------------------------------------------------------}
Procedure TPollApp.Newpoll;
var i:integer;
  begin
    for i := 1 to num do
    save[num]:=0;
    questionIndex:=1;
    ListWindow := New(PListWindow, Init);
    Desktop^.Insert(ListWindow); 
    ListWindow^.NextQuestion;
  End;

{-----------------------------------------------------------------}
procedure TPollApp.StatsResult;
var
  i, j: Integer;
  statsText: string;
  frst0, scnd0, thrd0: string;
begin
  statsText := '';
  for i := 1 to num do
  begin
    Str(arr[i, 1], frst0);
    Str(arr[i, 2], scnd0);
    Str(arr[i, 3], thrd0);
    Str(i,tempstr);
    statsText := statsText + tempstr + ': question: A-' + frst0 + ', B-' + scnd0 + ', C-' + thrd0 + #13#10;
  end;
  
  MessageBox(statsText, nil, mfInformation or mfOkButton);
end;
{-----------------------------------------------------------------}
procedure TPollApp.InitArray;
  var
    j, i: Integer;
  begin
    for i := 1 to num do
    begin
      for j := 1 to 3 do
      begin
        Arr[i, j] := 0;
      end;
    end;
  end;
{-----------------------------------------------------------------}
procedure TPollApp.InitQuestions;
begin  
  Body[1] := 'Who was the first President of the United States? '+
  'An American Founding Father, military officer, and politician '+
  'who served as the first president of the United States from 1789 to 1797'#13 +
                  'A:George Washington'#13 +
                  'B:Abraham Lincoln'#13 +
                  'C:John F. Kennedy';
  
  Body[2] := 'In which year did the French Revolution take place? '+
  'period of political and societal change in France that began with the '+
  'Estates General of 1789, and ended with the coup of 18 Brumaire in November'+
  '1799 and the formation of the French '#13 +
                  'A:1789'#13 +
                  'B:1812'#13 +
                  'C:1917';

  Body[3] := 'In which country Adolf Hitler was born? Adolf Hitler is known '+
  'as a politic and leader of Nazi Germany, he was an ideological person '+
  'and had a great talent for oratory art, thats why he had a lot of followers'#13 +
                  'A:Austria'#13 +
                  'B:Germany'#13 +
                  'C:Italy';
    Body[4] := 'Who was the first President of the United States? '+
  'An American Founding Father, military officer, and politician '+
  'who served as the first president of the United States from 1789 to 1797'#13 +
                  'A:George Washington'#13 +
                  'B:Abraham Lincoln'#13 +
                  'C:John F. Kennedy';                  
end;
{-----------------------------------------------------------------}
Destructor TPollApp.Done;
  Begin
    Inherited Done;
  End;
{-----------------------------------------------------------------}
end.