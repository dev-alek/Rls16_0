block-level on error undo, throw.
define input parameter p-func-name as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 89462fe805e0, 527, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Mar 17 18:42:35 2016 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: stdfnhlp.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/stdfnhlp.p $":U .
define variable vss-description as character no-undo initial "Описание функций из std-func.i":U .
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable Help_Editor as character no-undo view-as editor    scrollbar-vertical               size-chars 98.00 by 17.25 .
define variable Func_Name   as character no-undo view-as combo-box list-items '':U    inner-lines 1 size-chars 36.00 by  1.00 sort format "x(32)":U .
define variable num_funcs   as integer   no-undo view-as fill-in                                    size-chars 16.50 by  1.00 format "->,>>>,>>>,>>9.":U .
define variable j_func      as integer   no-undo view-as fill-in                                    size-chars 16.50 by  1.00 format "->,>>>,>>>,>>9":U .
define button Btn_Exit label "Вы&ход" size-chars 10.00 by 1.00 default auto-end-key .
define frame fr-D-FunctionHelp
  Func_Name   at row  1.50 col  1.50    label "Функция"
  j_func      at row  1.50 col 47.00 no-label                 fgcolor  4
  num_funcs   at row  1.50 col 67.75    label "Всего функций" fgcolor  4
  Help_Editor at row  3.00 col  1.50 no-label                 bgcolor 15
  Btn_Exit    at row 20.75 col 44.00 skip( 0.25 )
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title "Описание функций" default-button Btn_Exit cancel-button Btn_Exit.
assign
  frame fr-D-FunctionHelp :scrollable = no
.
assign
  Help_Editor :read-only in frame fr-D-FunctionHelp = yes
.
on value-changed of Func_Name in frame fr-D-FunctionHelp
do:
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  assign
    Func_Name
  .
  assign
    j_func = Func_Name :lookup( Func_Name )
  .
  run GetFunctionHelp1 in this-procedure
    (  input Func_Name
    , output Help_Editor
    ) .
  display j_func Help_Editor with frame fr-D-FunctionHelp .
end.
if valid-handle( active-window ) and
   frame fr-D-FunctionHelp :parent = ?
then do:
  frame fr-D-FunctionHelp :parent = active-window .
end.
if current-window :window-state = window-minimized
then do:
   current-window :window-state = window-normal .
end.
on window-close of frame fr-D-FunctionHelp
do:
  apply "END-ERROR":U to frame fr-D-FunctionHelp.
end.
Main-Block:
DO
on error   undo Main-Block, leave Main-Block
on end-key undo Main-Block, leave Main-Block
on stop    undo Main-Block, leave Main-Block
:
  assign
    Func_Name :list-items  = 'LastMonthDate,LastMonthDay,LastDay-MY,LastDate-MY,NextMonth,NextYear,PrevMonth,PrevYear,NextMonth-MY,NextYear-MY,MonthNameRus,MonthNameRusGen,MonthNameRusCase,CalcMonthes,CalcMonth-MY,DateTimeHeader,PrevMonth-MY,PrevYear-MY,MonthNameEng,TimeStamp,Round-M,Trunc-M,get-dec,RedLine,Word-Sum,Total-Word,PutAcc,Roubles,Copecks,Word-Sum-Eng,Word-Curr,Int2Char,PutInt,PutSum,Stamp57,WeekDay-Full,WeekDay-Short,WeekDay-Shrt3,WeekDay-Rus,WeekDay-Full-Eng,WeekDay-Eng2,WeekDay-Eng3,Week-Num,Week-From,Week-Till,Week-Date,Week-Date-Eng,Rec2Char,DelEntry,addl-list,addf-list,addn-list,super-pos,sets-union,sets-intersection,ChooseMark,is-marked,MarkSign,Int2Hex,Hex2Int,Int2Octal,Oct2Int,Int2Bin,Bin2Int,Int2Base,Base2Int,Base2Int64,DateNum,NumDays,KeyStamp,Leap-Year,Leap-Year-d,Sparse,SparseSymbol,Compress,CompressSymbol,Centering,CenteringSymbol,ShiftRight,ShiftRightSymbol,Digital' + ',' + 'get-decade-word,get-dec-word-eng':U
    Func_Name :inner-lines = 9
  .
  assign
    num_funcs = num-entries( Func_Name :list-items )
    j_func    = Func_Name :lookup( p-func-name )
  .
  assign
    Func_Name = Func_Name :entry( ( if j_func > 0 then j_func else 1 ) )
  .
  assign
    j_func    = Func_Name :lookup( Func_Name )
  .
  display Func_Name Help_Editor num_funcs j_func with frame fr-D-FunctionHelp .
  enable  Func_Name Help_Editor Btn_Exit         with frame fr-D-FunctionHelp .
  apply   'VALUE-CHANGED':U  to Func_Name          in frame fr-D-FunctionHelp .
  wait-for endkey of frame fr-D-FunctionHelp .
end.
hide frame fr-D-FunctionHelp no-pause .
procedure GetFunctionHelp1 :
  define  input parameter p-name as character no-undo .
  define output parameter p-help as character no-undo .
  case p-name :
    when 'LastMonthDate'
    then do:
      assign
        p-help = "Возвращает дату последнего дня текущего месяца." + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                  + chr(10) +
                 "LastMonthDate RETURNS DATE ( INPUT DATE ) ."     + chr(10) + chr(10) +
                 "ПРИМЕР:"                                         + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l LastMonthDate"               + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                  + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE NO-UNDO ."   + chr(10) +
                 "DEFINE VARIABLE t_last-date AS DATE NO-UNDO ."   + chr(10) + chr(10) +
                 "ASSIGN"                                          + chr(10) +
                 "  t_curr-date = TODAY"                           + chr(10) +
                 "  t_last-date = LastMonthDate( t_curr-date )"    + chr(10) +
                 "."                                               + chr(10) +
                 'MESSAGE'                                         + chr(10) +
                 '  "Дата последнего дня месяца:" t_last-date'     + chr(10) +
                 'VIEW-AS ALERT-BOX .'                             + chr(10)
      .
    end.
    when 'LastMonthDay'
    then do:
      assign
        p-help = "Возвращает последний день текущего месяца."       + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                   + chr(10) +
                 "LastMonthDate RETURNS INTEGER ( INPUT DATE ) ."   + chr(10) + chr(10) +
                 "ПРИМЕР:"                                          + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l LastMonthDay"                 + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + chr(10) +
                 "DEFINE VARIABLE j_last-day  AS INTEGER NO-UNDO ." + chr(10) + chr(10) +
                 "ASSIGN"                                           + chr(10) +
                 "  t_curr-date = TODAY"                            + chr(10) +
                 "  j_last-day  = LastMonthDay( t_curr-date )"      + chr(10) +
                 "."                                                + chr(10) +
                 'MESSAGE'                                          + chr(10) +
                 '  "Последний день месяца:" j_last-day'            + chr(10) +
                 'VIEW-AS ALERT-BOX .'                              + chr(10)
      .
    end.
    when 'LastDate-MY'
    then do:
      assign
        p-help = "Возвращает дату последнего дня текущего месяца по месяцу и году." + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                   + chr(10) +
                 "LastDate-MY RETURNS INTEGER ( INPUT Month AS INTEGER,"            + chr(10) +
                 "                              INPUT Year  AS INTEGER ) ."         + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                          + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l LastDate-MY"                                  + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                   + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."                 + chr(10) +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."                 + chr(10) +
                 "DEFINE VARIABLE curr-year   AS INTEGER NO-UNDO ."                 + chr(10) +
                 "DEFINE VARIABLE t_last-date AS DATE    NO-UNDO ."                 + chr(10) + chr(10) +
                 "ASSIGN"                                                           + chr(10) +
                 "  t_curr-date = TODAY"                                            + chr(10) +
                 "  curr-month  = MONTH( t_curr-date )"                             + chr(10) +
                 "  curr-year   = YEAR(  t_curr-date )"                             + chr(10) +
                 "  t_last-date = LastDate-MY( curr-month, curr-year )"             + chr(10) +
                 "."                                                                + chr(10) +
                 'MESSAGE'                                                          + chr(10) +
                 '  "Дата последнего дня месяца:" t_last-date'                      + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                              + chr(10)
      .
    end.
    when 'LastDay-MY'
    then do:
      assign
        p-help = "Возвращает последний день текущего месяца по месяцу и году." + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                              + chr(10) +
                 "LastDay-MY RETURNS INTEGER ( INPUT Month AS INTEGER,"        + chr(10) +
                 "                             INPUT Year  AS INTEGER ) ."     + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                     + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l LastDay-MY"                              + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."            + chr(10) +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."            + chr(10) +
                 "DEFINE VARIABLE curr-year   AS INTEGER NO-UNDO ."            + chr(10) +
                 "DEFINE VARIABLE t_last-day  AS INTEGER NO-UNDO ."            + chr(10) + chr(10) +
                 "ASSIGN"                                                      + chr(10) +
                 "  t_curr-date = TODAY"                                       + chr(10) +
                 "  curr-month  = MONTH( t_curr-date )"                        + chr(10) +
                 "  curr-year   = YEAR(  t_curr-date )"                        + chr(10) +
                 "  t_last-day  = LastDay-MY( curr-month, curr-year )"         + chr(10) +
                 "."                                                           + chr(10) +
                 'MESSAGE'                                                     + chr(10) +
                 '  "Последний день месяца:" j_last-day'                       + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                         + chr(10)
      .
    end.
    when 'NextMonth'
    then do:
      assign
        p-help = "Возвращает номер следующего месяца по дате."      + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                   + chr(10) +
                 "NextMonth RETURNS INTEGER ( INPUT DATE ) ."       + chr(10) + chr(10) +
                 "ПРИМЕР:"                                          + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l NextMonth"                    + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + chr(10) +
                 "DEFINE VARIABLE next-month  AS INTEGER NO-UNDO ." + chr(10) + chr(10) +
                 "ASSIGN"                                           + chr(10) +
                 "  t_curr-date = TODAY"                            + chr(10) +
                 "  next-month  = NextMonth( t_curr-date )"         + chr(10) +
                 "."                                                + chr(10) +
                 'MESSAGE'                                          + chr(10) +
                 '  "Следующий месяц:" next-month'                  + chr(10) +
                 'VIEW-AS ALERT-BOX .'                              + chr(10)
      .
    end.
    when 'NextMonth-MY'
    then do:
      assign
        p-help = "Возвращает номер следующего месяца по месяцу и году."   + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                         + chr(10) +
                 "NextMonth RETURNS INTEGER ( INPUT Month AS INTEGER ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l NextMonth-MY"                       + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."       + chr(10) +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."       + chr(10) +
                 "DEFINE VARIABLE next-month  AS INTEGER NO-UNDO ."       + chr(10) + chr(10) +
                 "ASSIGN"                                                 + chr(10) +
                 "  t_curr-date = TODAY"                                  + chr(10) +
                 "  curr-month  = MONTH( t_curr-date )"                   + chr(10) +
                 "  next-month  = NextMonth-MY( curr-month )"             + chr(10) +
                 "."                                                      + chr(10) +
                 'MESSAGE'                                                + chr(10) +
                 '  "Следующий месяц:" next-month'                        + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                    + chr(10)
      .
    end.
    when 'NextYear'
    then do:
      assign
        p-help = "Возвращает год следующего месяца по дате."        + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                   + chr(10) +
                 "NextYear RETURNS INTEGER ( INPUT DATE ) ."        + chr(10) + chr(10) +
                 "ПРИМЕР:"                                          + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l NextYear"                     + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + chr(10) +
                 "DEFINE VARIABLE next-year   AS INTEGER NO-UNDO ." + chr(10) + chr(10) +
                 "ASSIGN"                                           + chr(10) +
                 "  t_curr-date = TODAY"                            + chr(10) +
                 "  next-year   = NextYear( t_curr-date )"          + chr(10) +
                 "."                                                + chr(10) +
                 'MESSAGE'                                          + chr(10) +
                 '  "Год следующего месяца:" next-year'             + chr(10) +
                 'VIEW-AS ALERT-BOX .'                              + chr(10)
      .
    end.
    when 'NextYear-MY'
    then do:
      assign
        p-help = "Возвращает год следующего месяца по текущему месяцу и году." + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                              + chr(10) +
                 "NextYear-MY RETURNS INTEGER ( INPUT Month AS INTEGER,"       + chr(10) +
                 "                              INPUT Year  AS INTEGER ) ."    + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                     + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l NextYear-MY"                             + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."            + chr(10) +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."            + chr(10) +
                 "DEFINE VARIABLE curr-year   AS INTEGER NO-UNDO ."            + chr(10) +
                 "DEFINE VARIABLE next-year   AS INTEGER NO-UNDO ."            + chr(10) + chr(10) +
                 "ASSIGN"                                                      + chr(10) +
                 "  t_curr-date = TODAY"                                       + chr(10) +
                 "  curr-month  = MONTH( t_curr-date )"                        + chr(10) +
                 "  curr-year   = YEAR(  t_curr-date )"                        + chr(10) +
                 "  next-year   = NextYear-MY( curr-month, curr-year )"        + chr(10) +
                 "."                                                           + chr(10) +
                 'MESSAGE'                                                     + chr(10) +
                 '  "Год следующего месяца:" next-year'                        + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                         + chr(10)
      .
    end.
    when 'PrevMonth'
    then do:
      assign
        p-help = "Возвращает номер предыдующего месяца по дате."    + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                   + chr(10) +
                 "PrevMonth RETURNS INTEGER ( INPUT DATE ) ."       + chr(10) + chr(10) +
                 "ПРИМЕР:"                                          + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l PrevMonth"                    + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + chr(10) +
                 "DEFINE VARIABLE prev-month  AS INTEGER NO-UNDO ." + chr(10) + chr(10) +
                 "ASSIGN"                                           + chr(10) +
                 "  t_curr-date = TODAY"                            + chr(10) +
                 "  prev-month  = PrevMonth( t_curr-date )"         + chr(10) +
                 "."                                                + chr(10) +
                 'MESSAGE'                                          + chr(10) +
                 '  "Предыдующий месяц:" prev-month'                + chr(10) +
                 'VIEW-AS ALERT-BOX .'                              + chr(10)
      .
    end.
    when 'PrevMonth-MY'
    then do:
      assign
        p-help = "Возвращает номер предыдующего месяца по месяцу и году." + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                         + chr(10) +
                 "PrevMonth RETURNS INTEGER ( INPUT Month AS INTEGER ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l PrevMonth-MY"                       + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."       + chr(10) +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."       + chr(10) +
                 "DEFINE VARIABLE prev-month  AS INTEGER NO-UNDO ."       + chr(10) + chr(10) +
                 "ASSIGN"                                                 + chr(10) +
                 "  t_curr-date = TODAY"                                  + chr(10) +
                 "  curr-month  = MONTH( t_curr-date )"                   + chr(10) +
                 "  prev-month  = PrevMonth-MY( curr-month )"             + chr(10) +
                 "."                                                      + chr(10) +
                 'MESSAGE'                                                + chr(10) +
                 '  "Предыдующий месяц:" prev-month'                      + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                    + chr(10)
      .
    end.
    when 'PrevYear'
    then do:
      assign
        p-help = "Возвращает год предыдующего месяца по дате."      + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                   + chr(10) +
                 "PrevYear RETURNS INTEGER ( INPUT DATE ) ."        + chr(10) + chr(10) +
                 "ПРИМЕР:"                                          + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l PrevYear"                     + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                   + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ." + chr(10) +
                 "DEFINE VARIABLE prev-year   AS INTEGER NO-UNDO ." + chr(10) + chr(10) +
                 "ASSIGN"                                           + chr(10) +
                 "  t_curr-date = TODAY"                            + chr(10) +
                 "  prev-year   = PrevYear( t_curr-date )"          + chr(10) +
                 "."                                                + chr(10) +
                 'MESSAGE'                                          + chr(10) +
                 '  "Год предыдующего месяца:" prev-year'           + chr(10) +
                 'VIEW-AS ALERT-BOX .'                              + chr(10)
      .
    end.
    when 'PrevYear-MY'
    then do:
      assign
        p-help = "Возвращает год предыдующего месяца по месяцу и году."     + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                           + chr(10) +
                 "PrevYear-MY RETURNS INTEGER ( INPUT Month AS INTEGER,"    + chr(10) +
                 "                              INPUT Year  AS INTEGER ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                  + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l PrevYear-MY"                          + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                           + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."         + chr(10) +
                 "DEFINE VARIABLE curr-month  AS INTEGER NO-UNDO ."         + chr(10) +
                 "DEFINE VARIABLE curr-year   AS INTEGER NO-UNDO ."         + chr(10) +
                 "DEFINE VARIABLE prev-year   AS INTEGER NO-UNDO ."         + chr(10) + chr(10) +
                 "ASSIGN"                                                   + chr(10) +
                 "  t_curr-date = TODAY"                                    + chr(10) +
                 "  curr-month  = MONTH( t_curr-date )"                     + chr(10) +
                 "  curr-year   = YEAR(  t_curr-date )"                     + chr(10) +
                 "  prev-year   = PrevYear-MY( curr-month, curr-year )"     + chr(10) +
                 "."                                                        + chr(10) +
                 'MESSAGE'                                                  + chr(10) +
                 '  "Год предыдующего месяца:" prev-year'                   + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                      + chr(10)
      .
    end.
    when 'MonthNameRus'
    then do:
      assign
        p-help = "Возвращает название месяца по-русски."              + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                     + chr(10) +
                 "MonthNameRus RETURNS CHARACTER ( INPUT INTEGER ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                            + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l MonthNameRus"                   + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                     + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE      NO-UNDO ." + chr(10) +
                 "DEFINE VARIABLE curr-month  AS INTEGER   NO-UNDO ." + chr(10) +
                 "DEFINE VARIABLE word-month  AS CHARACTER NO-UNDO ." + chr(10) + chr(10) +
                 "ASSIGN"                                             + chr(10) +
                 "  t_curr-date = TODAY"                              + chr(10) +
                 "  curr-month  = MONTH( t_curr-date )"               + chr(10) +
                 "  word-month  = MonthNameRus( curr-month )"         + chr(10) +
                 "."                                                  + chr(10) +
                 'MESSAGE'                                            + chr(10) +
                 '  "Название месяца:" word-month'                    + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                + chr(10)
      .
    end.
    when 'MonthNameRusGen'
    then do:
      assign
        p-help = "Возвращает название месяца по-русски в родительном падеже."   + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                               + chr(10) +
                 "MonthNameRusGen RETURNS CHARACTER ( INPUT INTEGER ) ."        + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                      + chr(10) + chr(10) +
                 '/* **************************************************** *\'   + chr(10) +
                 ' *                                                      *'    + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'    + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )               +
                                                                         '*'    + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'    + chr(10) +
                 ' *                                                      *'    + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'    + chr(10) +
                 ' *                                                      *'    + chr(10) +
                 '\* **************************************************** */'   + chr(10) + chr(10) +
                 "~&SCOP f-l MonthNameRusGen"                                   + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                               + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE      NO-UNDO ."           + chr(10) +
                 "DEFINE VARIABLE curr-month  AS INTEGER   NO-UNDO ."           + chr(10) +
                 "DEFINE VARIABLE word-month  AS CHARACTER NO-UNDO ."           + chr(10) + chr(10) +
                 "ASSIGN"                                                       + chr(10) +
                 "  t_curr-date = TODAY"                                        + chr(10) +
                 "  curr-month  = MONTH( t_curr-date )"                         + chr(10) +
                 "  word-month  = MonthNameRusGen( curr-month )"                + chr(10) +
                 "."                                                            + chr(10) +
                 'MESSAGE'                                                      + chr(10) +
                 '  "Число:" STRING( DAY( t_curr-date ), ">9":U ) + "-е"'       + chr(10) +
                 '  word-month YEAR(      t_curr-date ) "года."'                + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                          + chr(10)
      .
    end.
    when 'MonthNameEng'
    then do:
      assign
        p-help = "Возвращает название месяца по-английски."           + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                     + chr(10) +
                 "MonthNameEng RETURNS CHARACTER ( INPUT INTEGER ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                            + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l MonthNameEng"                   + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                     + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE      NO-UNDO ." + chr(10) +
                 "DEFINE VARIABLE curr-month  AS INTEGER   NO-UNDO ." + chr(10) +
                 "DEFINE VARIABLE word-month  AS CHARACTER NO-UNDO ." + chr(10) + chr(10) +
                 "ASSIGN"                                             + chr(10) +
                 "  t_curr-date = TODAY"                              + chr(10) +
                 "  curr-month  = MONTH( t_curr-date )"               + chr(10) +
                 "  word-month  = MonthNameEng( curr-month )"         + chr(10) +
                 '.'                                                  + chr(10) +
                 'MESSAGE'                                            + chr(10) +
                 '  "Название месяца по-английски:" word-month'       + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                + chr(10)
      .
    end.
    when 'CalcMonthes'
    then do:
      assign
        p-help = "Возвращает количество месяцев в интервале дат."                + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                + chr(10) +
                 "CalcMonthes RETURNS INTEGER ( INPUT t_from AS DATE"            + chr(10) +
                 "                            , INPUT t_till AS DATE"            + chr(10) + chr(10) +
                 "                            ) ."                               + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                       + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l LastMonthDate,CalcMonthes"                 + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."              + chr(10) +
                 "DEFINE VARIABLE t_date-from AS DATE    NO-UNDO ."              + chr(10) +
                 "DEFINE VARIABLE t_date-till AS DATE    NO-UNDO ."              + chr(10) +
                 "DEFINE VARIABLE num-monthes AS INTEGER NO-UNDO ."              + chr(10) + chr(10) +
                 "ASSIGN"                                                        + chr(10) +
                 "  t_curr-date = TODAY"                                         + chr(10) +
                 "  t_date-from = DATE( MONTH( t_curr-date ), 1, YEAR(  t_curr-date ) - 1 )"   + chr(10) +
                 "  t_date-till = LastMonthDate( t_curr-date )"                  + chr(10) +
                 "  num-monthes = CalcMonthes( t_date-from, t_date-till )"       + chr(10) +
                 '.'                                                             + chr(10) +
                 'MESSAGE'                                                       + chr(10) +
                 '  "Диапазон дат с:" t_date-from "по:" t_date-till SKIP( 0 )'   + chr(10) +
                 '  "Количество месяцев:" num-monthes'                           + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                           + chr(10)
      .
    end.
    when 'CalcMonth-MY'
    then do:
      assign
        p-help = "Возвращает количество месяцев в интервале дат, " +
                 "заданных через месяцы и годы."                                               + chr(10) +
                                                                                                 chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                              + chr(10) +
                 "CalcMonth-MY RETURNS INTEGER ( INPUT year-from  AS INTEGER"                  + chr(10) +
                 "                             , INPUT month-from AS INTEGER"                  + chr(10) +
                 "                             , INPUT year-till  AS INTEGER"                  + chr(10) +
                 "                             , INPUT month_till AS INTEGER"                  + chr(10) +
                 "                             ) ."                                            + chr(10) +
                                                                                                 chr(10) +
                 "ПРИМЕР:"                                                                     + chr(10) +
                                                                                                 chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l CalcMonth-MY,MonthNameRus,MonthNameRusGen"               + chr(10) +
                                                                                                 chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                              + chr(10) +
                                                                                                 chr(10) +
                 "DEFINE VARIABLE date_from   AS DATE    NO-UNDO ."                            + chr(10) +
                 "DEFINE VARIABLE date_till   AS DATE    NO-UNDO ."                            + chr(10) +
                 "DEFINE VARIABLE month_from  AS INTEGER NO-UNDO ."                            + chr(10) +
                 "DEFINE VARIABLE year_from   AS INTEGER NO-UNDO ."                            + chr(10) +
                 "DEFINE VARIABLE month_till  AS INTEGER NO-UNDO ."                            + chr(10) +
                 "DEFINE VARIABLE year_till   AS INTEGER NO-UNDO ."                            + chr(10) +
                 "DEFINE VARIABLE num-monthes AS INTEGER NO-UNDO ."                            + chr(10) +
                                                                                                 chr(10) +
                 "ASSIGN"                                                                      + chr(10) +
                 "  date_from   = TODAY - 31"                                                  + chr(10) +
                 "  date_till   = TODAY + 31"                                                  + chr(10) +
                 "  month_from  = MONTH( date_from )"                                          + chr(10) +
                 "  month_till  = MONTH( date_till )"                                          + chr(10) +
                 "  year_from   = YEAR(  date_from ) - 1"                                      + chr(10) +
                 "  year_till   = YEAR(  date_till ) + 1"                                      + chr(10) +
                 "  num-monthes = CalcMonth-MY( year_from, month_from,year_till, month_till )" + chr(10) +
                 "."                                                                           + chr(10) +
                 'MESSAGE'                                                                     + chr(10) +
                 '  "Диапазон дат:  с " MonthNameRusGen( month_from ) year_from'               + chr(10) +
                 '               " по " MonthNameRus(    month_till ) year_till SKIP( 0 )'     + chr(10) +
                 '  "Количество месяцев:" num-monthes'                                         + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                         + chr(10)
      .
    end.
    when 'DateTimeHeader'
    then do:
      assign
        p-help = "Заголовок отчета. Возвращает строку, содержащую текущие дату и " +
                 "время печати длиной 30 символов."                  + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                    + chr(10) +
                 "DateTimeHeader RETURNS CHARACTER ( INPUT DATE ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                           + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l DateTimeHeader"                + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                    + chr(10) + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE NO-UNDO ."     + chr(10) + chr(10) +
                 "ASSIGN"                                            + chr(10) + chr(10) +
                 "  t_curr-date = TODAY"                             + chr(10) + chr(10) +
                 "."                                                 + chr(10) + chr(10) +
                 'MESSAGE'                                           + chr(10) +
                 '  DateTimeHeader( t_curr-date )'                   + chr(10) +
                 'VIEW-AS ALERT-BOX .'                               + chr(10)
      .
    end.
    when 'TimeStamp'
    then do:
      assign
        p-help = "Заголовок отчета. Возвращает строку, содержащую текущие дату, "  +
                 "время печати и номер страницы длиной 50 символов." + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                    + chr(10) +
                 "TimeStamp RETURNS CHARACTER ( INPUT INTEGER ) ."   + chr(10) + chr(10) +
                 "ПРИМЕР:"                                           + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l TimeStamp"                     + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                    + chr(10) + chr(10) +
                 'MESSAGE'                                           + chr(10) +
                 '  TimeStamp( 1 )'                                  + chr(10) +
                 'VIEW-AS ALERT-BOX .'                               + chr(10)
      .
    end.
    when 'Stamp57'
    then do:
      assign
        p-help = "Заголовок отчета. Возвращает строку, содержащую дату и "    +
                 "время печати и номер страницы длиной 57 символов."          + chr(10)     +
                 "Если дата и/или время не заданы, то берутся текущие."       + chr(10)     + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                             + chr(10)     +
                 "Stamp57 RETURNS CHARACTER ( INPUT print-date AS DATE"       + chr(10)     +
                 "                          , INPUT print-time AS INTEGER"    + chr(10)     +
                 "                          , INPUT curr-page  AS INTEGER"    + chr(10)     + chr(10) +
                 "                           ) ."                             + chr(10)     + chr(10) +
                 "ПРИМЕР:"                                                    + chr(10)     + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Stamp57"                                + chr(10)     + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                             + chr(10)     + chr(10) +
                 "DEFINE VARIABLE t_curr-date AS DATE    NO-UNDO ."           + chr(10)     +
                 "DEFINE VARIABLE j_curr-time AS INTEGER NO-UNDO ."           + chr(10)     +
                 "DEFINE VARIABLE j_curr-page AS INTEGER NO-UNDO ."           + chr(10)     + chr(10) +
                 "ASSIGN"                                                     + chr(10)     +
                 "  t_curr-date = TODAY"                                      + chr(10)     +
                 "  j_curr-time = TIME + 120"                                 + chr(10)     +
                 "  j_curr-page = 2"                                          + chr(10)     + chr(10) +
                 "."                                                          + chr(10)     + chr(10) +
                 "IF t_curr-date <> TODAY"                                    + chr(10)     +
                 "THEN DO:"                                                   + chr(10)     +
                 "  ASSIGN"                                                   + chr(10)     +
                 "    t_curr-date = TODAY"                                    + chr(10)     +
                 "    j_curr-time = TIME + 120"                               + chr(10)     +
                 "  ."                                                        + chr(10)     +
                 "END."                                                       + chr(10)     + chr(10) +
                 'MESSAGE'                                                    + chr(10)     +
                 '  ~'"~' + Stamp57( ?,           ?,           ?           ) + ~'"~' SKIP( 0 )' + chr(10) +
                 '  ~'"~' + Stamp57( t_curr-date, j_curr-time, j_curr-page ) + ~'"~''           + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                        + chr(10)
      .
    end.
    when 'Round-M'
    then do:
      assign
        p-help = "Возвращает округленное действительное число."                   + chr(10) +
                 "Первый параметр - число, которое нужно округлить."              + chr(10) +
                 "Второй параметр - порядок округления."                          + chr(10) +
                 "Если порядок округления отрицательный, то округляются "         +
                 "цифры слева от десятичной точки, т.е.:"                         + chr(10) +
                 "  Round-M( 123.0, -1 ) = 120.0, Round-M( 123.0, -2 ) = 100.0."  + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                 + chr(10) +
                 "Round-M RETURNS DECIMAL ( INPUT decimal-number AS DECIMAL"      + chr(10) +
                 "                        , INPUM round-order    AS INTEGER"      + chr(10) +
                 "                        ) ."                                    + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                        + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Round-M"                                    + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + chr(10) + chr(10) +
                 "DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL -1234.98765 ." + chr(10) + chr(10) +
                 'MESSAGE'                                                        + chr(10) +
                 '  "Число:" d_num "округлено до:" Round-M( d_num, -3 )'          + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                            + chr(10)
      .
    end.
    when 'Trunc-M'
    then do:
      assign
        p-help = 'Возвращает "обрезанное" действительное число, т.е. отбрасывает "лишние" занки.' + chr(10) +
                 "Первый параметр - число, которое нужно обрезать."               + chr(10)   +
                 "Второй параметр - количество знаков, которые нужно отбросить."  + chr(10)   +
                 "Если порядок отрицательный, то отбрасываются цифры слева от десятичной точки:"  + chr(10) +
                 "  Trunc-M( 567.0, -1 ) = 560.0, Trunc-M( 567.0, -2 ) = 500.0."  + chr(10)   + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                 + chr(10)   +
                 "Trunc-M RETURNS DECIMAL ( INPUT decimal-number AS DECIMAL"      + chr(10)   +
                 "                        , INPUM truncate-order AS INTEGER"      + chr(10)   +
                 "                        ) ."                                    + chr(10)   + chr(10) +
                 "ПРИМЕР:"                                                        + chr(10)   + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Trunc-M"                                    + chr(10)   + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + chr(10)   + chr(10) +
                 "DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL -9876.12345 ." + chr(10)   + chr(10) +
                 'MESSAGE'                                                        + chr(10)   +
                 '  "Число:" d_num "обрезано до:" Trunc-M( d_num, -3 )'           + chr(10)   +
                 'VIEW-AS ALERT-BOX .'                                            + chr(10)
      .
    end.
    when 'get-dec'
    then do:
      assign
        p-help = 'Возвращает дробную часть действительного числа в виде целого.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                + chr(10) +
                 "get-dec RETURNS INTEGER ( INPUT decimal_number AS DECIMAL ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                       + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l get-dec"                                   + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                + chr(10) + chr(10) +
                 "DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 123.967 ."    + chr(10) + chr(10) +
                 'MESSAGE'                                                       + chr(10) +
                 '  "Число:"                  d_num   SKIP( 0 )'                 + chr(10) +
                 '  "дробная часть:" get-dec( d_num )'                           + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                           + chr(10)
      .
    end.
    when 'RedLine'
    then do:
      assign
        p-help = 'Красная строка: первая буква заглавная, остальные - прописные.'          + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                          + chr(10) +
                 "RedLine RETURNS CHARACTER ( INPUT CHARACTER ) ."                         + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                                 + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l RedLine"                                             + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                          + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_str AS CHARACTER NO-UNDO INITIAL "красная строка" .'   + chr(10) + chr(10) +
                 'MESSAGE'                                                                 + chr(10) +
                 '        v_str   "-->" RedLine(       v_str )   SKIP( 0 )'                + chr(10) +
                 '  CAPS( v_str ) "-->" RedLine( CAPS( v_str ) ) SKIP( 0 )'                + chr(10) +
                 '  LC( SUBSTRING( v_str, 1, 1 ) ) + CAPS( SUBSTRING( v_str, 2 ) ) "-->"'                + chr(10) +
                 '  RedLine( LC( SUBSTRING( v_str, 1, 1 ) ) + CAPS( SUBSTRING( v_str, 2 ) ) ) SKIP( 0 )' + chr(10) +
                 '  CAPS( SUBSTRING( v_str, 1, 1 ) ) + LC( SUBSTRING( v_str, 2 ) ) "-->"'                + chr(10) +
                 '  RedLine( CAPS( SUBSTRING( v_str, 1, 1 ) ) + LC( SUBSTRING( v_str, 2 ) ) ) SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                                   + chr(10)
      .
    end.
    when 'Int2Char'
    then do:
      assign
        p-help = 'Конвертация целого числа в строку с подавлением ведущих нулей ' +
                 'без разбивки на разряды.'                                       + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                 + chr(10) +
                 "Int2Char RETURNS CHARACTER ( INPUT INTEGER ) ."                 + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                        + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Int2Char"                                   + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + chr(10) + chr(10) +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 12345 .'       + chr(10) + chr(10) +
                 'MESSAGE'                                                        + chr(10) +
                 '            j_num   SKIP( 0 )'                                  + chr(10) +
                 '  Int2Char( j_num ) SKIP( 0 )'                                  + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                            + chr(10)
      .
    end.
    when 'PutInt'
    then do:
      assign
        p-help = 'Конвертация целого числа в строку с подавлением ведущих нулей ' +
                 'и разбивкой на разряды.'                                        + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                 + chr(10) +
                 "PutInt RETURNS CHARACTER ( INPUT INTEGER ) ."                   + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                        + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l PutInt"                                     + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + chr(10) + chr(10) +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 12345 .'       + chr(10) + chr(10) +
                 'MESSAGE'                                                        + chr(10) +
                 '          j_num   SKIP( 0 )'                                    + chr(10) +
                 '  PutInt( j_num ) SKIP( 0 )'                                    + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                            + chr(10)
      .
    end.
    when 'PutSum'
    then do:
      assign
        p-help = 'Конвертация действительного числа в строку с подавлением ведущих ' +
                 'нулей и разбивкой на разряды.'                                     + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                    + chr(10) +
                 "PutSum RETURNS CHARACTER ( INPUT INTEGER ) ."                      + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                           + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l PutSum"                                        + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                    + chr(10) + chr(10) +
                 "DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL -12345678.967 ."  + chr(10) + chr(10) +
                 'MESSAGE'                                                           + chr(10) +
                 '          d_num   SKIP( 0 )'                                       + chr(10) +
                 '  PutSum( d_num ) SKIP( 0 )'                                       + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                               + chr(10)
      .
    end.
    when 'PutAcc'
    then do:
      assign
        p-help = 'Конвертация бухгалтерского счета и субсчета в строку.'               + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                      + chr(10) +
                 "PutAcc RETURNS CHARACTER ( INPUT i-num AS INTEGER"                   + chr(10) + chr(10) +
                 "                         , INPUT i-sub AS INTEGER"                   + chr(10) + chr(10) +
                 "                         ) ."                                        + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                             + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l PutAcc"                                          + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                      + chr(10) + chr(10) +
                 'MESSAGE'                                                             + chr(10) +
                 '  PutAcc( 42, 0 ) + ", " + PutAcc( 60, 2 )'                          + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                 + chr(10) +
                 "ПРИМЕЧАНИЕ:"                                                         + chr(10) +
                 'По функции "верхнего" уровня PutAcc "включается" ее функция "нижнего" уровня '     + chr(10) +
                 'Int2Char (которая может "включаться" и самостоятельно).'             + chr(10)
      .
    end.
    when 'Rec2Char'
    then do:
      assign
        p-help = "Конвертация RECID'а записи в строку."                  + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                        + chr(10) +
                 "Rec2Char RETURNS CHARACTER ( INPUT RECID ) ."          + chr(10) + chr(10) +
                 "ПРИМЕР:"                                               + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Rec2Char"                          + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                        + chr(10) + chr(10) +
                 'FIND LAST ub.bgh-doc NO-LOCK NO-ERROR .'               + chr(10) +
                 'IF AVAILABLE ub.bgh-doc'                               + chr(10) +
                 'THEN DO:'                                              + chr(10) +
                 '  MESSAGE'                                             + chr(10) +
                 '    Rec2Char( RECID( ub.bgh-doc ) )'                   + chr(10) +
                 '  VIEW-AS ALERT-BOX .'                                 + chr(10) +
                 'END.'                                                  + chr(10) +
                 'ELSE DO:'                                              + chr(10) +
                 '  MESSAGE'                                             + chr(10) +
                 '    "Запись ~~"Бухгалтерские проводки~~" не найдена!"' + chr(10) +
                 '  VIEW-AS ALERT-BOX .'                                 + chr(10) +
                 'END.'                                                  + chr(10)
      .
    end.
    when 'Roubles' or
    when 'Copecks'
    then do:
      assign
        p-help = 'Слово ' + ( if p-name = "Roubles" then '"рубли"' else '"копейки"' )         +
                 ' в сумме.'                                                      + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                 + chr(10) +
                 "Roubles RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) ."         + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                        + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Roubles,Copecks,get-dec"                    + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + chr(10) + chr(10) +
                 "DEFINE VARIABLE d_num1 AS DECIMAL NO-UNDO INITIAL 789.65 ."     + chr(10) +
                 "DEFINE VARIABLE d_num2 AS DECIMAL NO-UNDO INITIAL 562.41 ."     + chr(10) +
                 "DEFINE VARIABLE d_num3 AS DECIMAL NO-UNDO INITIAL 341.23 ."     + chr(10) + chr(10) +
                 'MESSAGE'                                                        + chr(10) +
                 '  d_num1 "-" TRUNCATE( d_num1, 0 ) Roubles( d_num1 )'           + chr(10) +
                 '             get-dec(  d_num1    ) Copecks( d_num1 ) SKIP( 0 )' + chr(10) +
                 '  d_num2 "-" TRUNCATE( d_num2, 0 ) Roubles( d_num2 )'           + chr(10) +
                 '             get-dec(  d_num2    ) Copecks( d_num2 ) SKIP( 0 )' + chr(10) +
                 '  d_num3 "-" TRUNCATE( d_num3, 0 ) Roubles( d_num3 )'           + chr(10) +
                 '             get-dec(  d_num3    ) Copecks( d_num3 ) SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                            + chr(10)
      .
    end.
    when 'get-decade-word'
    then do:
      assign
        p-help = "Возвращает разряд числа прописью при разбивке на триады (вспомогательная функция " + chr(10) +
                 'для функции "число прописью").'                                      + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                      + chr(10) +
                 "get-decade-word RETURNS CHARACTER ( INPUT i-dec AS INTEGER"          + chr(10) +
                 "                                  , INPUT i-num AS INTEGER"          + chr(10) +
                 "                                  ) ."                               + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                          + chr(10) +
                 "i-dec - цифра, означающая разряд цифры:"                             + chr(10) +
                 "        1 - единицы (от 0 до 9), третья цифра в триаде, в десятках - не 1;"        + chr(10) +
                 "        2 - единицы (от 10 до 19), третья цифра в триаде, в десятках - 1;"         + chr(10) +
                 "        3 - десятки (от 10 до 90), вторая цифра в триаде;"           + chr(10) +
                 "        4 - сотни   (от 100 до 900), первая цифра в триаде;"         + chr(10) +
                 "i-num - цифра (от 0 до 9), которая будет возвращена прописью."       + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                             + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Word-Sum"                                        + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                      + chr(10) + chr(10) +
                 'DEFINE VARIABLE v-list  AS CHARACTER NO-UNDO INITIAL "008,019,256":U .'            + chr(10) +
                 'DEFINE VARIABLE v-triad AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE v-word  AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE jj      AS INTEGER   NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE j1      AS INTEGER   NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE j-digit AS INTEGER   NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE j-order AS INTEGER   NO-UNDO .'                      + chr(10) + chr(10) +
                 'DO jj = 1 TO NUM-ENTRIES( v-list ) :'                                + chr(10) +
                 '  ASSIGN'                                                            + chr(10) +
                 '    v-triad = ENTRY( jj, v-list )'                                   + chr(10) +
                 '  .'                                                                 + chr(10) +
                 '  REPEAT j1 = 1 TO 3 :'                                              + chr(10) +
                 '    ASSIGN'                                                          + chr(10) +
                 '      j-digit = INTEGER( SUBSTRING( v-triad, j1, 1 ) )'              + chr(10) +
                 '      j-order = ( 5 - j1 ) -'                                        + chr(10) +
                 '      ( IF j1 = 3 AND SUBSTRING( v-triad, 2, 1 ) <> "1" THEN 1 ELSE 0 )'           + chr(10) +
                 '      v-word  = get-decade-word( j-order, j-digit )'                 + chr(10) +
                 '    .'                                                               + chr(10) +
                 '    DISPLAY'                                                         + chr(10) +
                 '      jj      FORMAT ">>9.":U'                                       + chr(10) +
                 '      v-triad FORMAT "x(3)":U'                                       + chr(10) +
                 '      j-digit FORMAT "9":U'                                          + chr(10) +
                 '      j-order FORMAT "9":U'                                          + chr(10) +
                 '      v-word  FORMAT "x(30)":U'                                      + chr(10) +
                 '    WITH NO-LABELS NO-UNDERLINE NO-BOX .'                            + chr(10) +
                 '  END.'                                                              + chr(10) +
                 'END.'                                                                + chr(10) + chr(10) +
                 "ПРИМЕЧАНИЕ:"                                                         + chr(10) +
                 'Обратите внимание, что включается функция "Word-Sum" - функция "верхнего" уровня,' + chr(10) +
                 '- по которой "включаются" все функции ее "нижнего" уровня, в том числе и функция ' + chr(10) +
                 'get-decade-word.'                                                    + chr(10)
      .
    end.
    when 'get-dec-word-eng'
    then do:
      assign
        p-help = "Возвращает разряд числа прописью при разбивке на триады (вспомогательная функция " + chr(10) +
                 'для функции "число прописью").'                                      + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                      + chr(10) +
                 "get-dec-word-eng RETURNS CHARACTER ( INPUT i-dec AS INTEGER"         + chr(10) +
                 "                                   , INPUT i-num AS INTEGER"         + chr(10) +
                 "                                   ) ."                              + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                          + chr(10) +
                 "i-dec - цифра, означающая разряд цифры:"                             + chr(10) +
                 "        1 - единицы (от 0 до 9), третья цифра в триаде, в десятках - не 1;"        + chr(10) +
                 "        2 - единицы (от 10 до 19), третья цифра в триаде, в десятках - 1;"         + chr(10) +
                 "        3 - десятки (от 10 до 90), вторая цифра в триаде;"           + chr(10) +
                 "        4 - сотни   (от 100 до 900), первая цифра в триаде;"         + chr(10) +
                 "i-num - цифра (от 0 до 9), которая будет возвращена прописью."       + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                             + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Word-Sum-Eng"                                    + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                      + chr(10) + chr(10) +
                 'DEFINE VARIABLE v-list  AS CHARACTER NO-UNDO INITIAL "008,019,256":U .'            + chr(10) +
                 'DEFINE VARIABLE v-triad AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE v-word  AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE jj      AS INTEGER   NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE j1      AS INTEGER   NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE j-digit AS INTEGER   NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE j-order AS INTEGER   NO-UNDO .'                      + chr(10) + chr(10) +
                 'DO jj = 1 TO NUM-ENTRIES( v-list ) :'                                + chr(10) +
                 '  ASSIGN'                                                            + chr(10) +
                 '    v-triad = ENTRY( jj, v-list )'                                   + chr(10) +
                 '  .'                                                                 + chr(10) +
                 '  REPEAT j1 = 1 TO 3 :'                                              + chr(10) +
                 '    ASSIGN'                                                          + chr(10) +
                 '      j-digit = INTEGER( SUBSTRING( v-triad, j1, 1 ) )'              + chr(10) +
                 '      j-order = ( 5 - j1 ) -'                                        + chr(10) +
                 '                ( IF j1 = 3 AND SUBSTRING( v-triad, 2, 1 ) <> "1" THEN 1 ELSE 0 )' + chr(10) +
                 '      v-word  = get-dec-word-eng( j-order, j-digit )'                + chr(10) +
                 '    .'                                                               + chr(10) +
                 '    DISPLAY'                                                         + chr(10) +
                 '      jj      FORMAT ">>9.":U'                                       + chr(10) +
                 '      v-triad FORMAT "x(3)":U'                                       + chr(10) +
                 '      j-digit FORMAT "9":U'                                          + chr(10) +
                 '      j-order FORMAT "9":U'                                          + chr(10) +
                 '      v-word  FORMAT "x(30)":U'                                      + chr(10) +
                 '    WITH NO-LABELS NO-UNDERLINE NO-BOX .'                            + chr(10) +
                 '  END.'                                                              + chr(10) +
                 'END.'                                                                + chr(10) + chr(10) +
                 "ПРИМЕЧАНИЕ:"                                                         + chr(10) +
                 'Обратите внимание, что включается функция "Word-Sum-Eng" - функция "верхнего" '    + chr(10) +
                 'уровня, - по которой "включаются" все функции ее "нижнего" уровня, в том числе и ' + chr(10) +
                 'функция get-dec-word-eng.'                                                         + chr(10)
      .
    end.
    when 'Word-Sum'
    then do:
      assign
        p-help = 'Возвращает сумму прописью от целой части действительного числа.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                  + chr(10) +
                 "Word-Sum RETURNS CHARACTER ( INPUT DECIMAL ) ."                  + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                         + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Word-Sum"                                    + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + chr(10) + chr(10) +
                 'DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 12345 .'        + chr(10) + chr(10) +
                 'MESSAGE'                                                         + chr(10) +
                 '            d_num   SKIP( 0 )'                                   + chr(10) +
                 '  Word-Sum( d_num ) SKIP( 0 )'                                   + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                             + chr(10)
      .
    end.
    when 'Word-Sum-Eng'
    then do:
      assign
        p-help = 'Возвращает сумму прописью от целой части действительного числа.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                  + chr(10) +
                 "Word-Sum-Eng RETURNS CHARACTER ( INPUT DECIMAL ) ."              + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                         + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Word-Sum-Eng"                                + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + chr(10) + chr(10) +
                 'DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 12345 .'        + chr(10) + chr(10) +
                 'MESSAGE'                                                         + chr(10) +
                 '                d_num   SKIP( 0 )'                               + chr(10) +
                 '  Word-Sum-Eng( d_num ) SKIP( 0 )'                               + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                             + chr(10)
      .
    end.
    when 'Total-Word'
    then do:
      assign
        p-help = 'Возвращает строку с суммой в валюте прописью по-русски с указанием '       + chr(10) +
                 'валюты и дробной части валюты.'                              + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                              + chr(10) +
                 "Total-Word RETURNS CHARACTER ( INPUT i-sum  AS DECIMAL"      + chr(10) +
                 "                             , INPUT i-curr AS CHARACTER"    + chr(10) +
                 "                             , INPUT i-part AS CHARACTER"    + chr(10) +
                 "                             ) ."                            + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                  + chr(10) +
                 '  i-sum  - сумма в валюте;'                                  + chr(10) +
                 '  i-curr - валюта;'                                          + chr(10) +
                 '  i-part - название дробной части валюты.'                   + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                     + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Word-Sum,Total-Word"                     + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + chr(10) + chr(10) +
                 'DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 753.84 .'   + chr(10) + chr(10) +
                 'MESSAGE'                                                     + chr(10) +
                 '              d_num                 SKIP( 0 )'               + chr(10) +
                 '  Total-Word( d_num, "USD", "cnt" ) SKIP( 0 )'               + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                         + chr(10)
      .
    end.
    when 'Word-Curr'
    then do:
      assign
        p-help = 'Возвращает строку с суммой в валюте прописью на английском языке с указанием ' + chr(10) +
                 'валюты и дробной части валюты.'                                  + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                  + chr(10) +
                 "Word-Curr RETURNS CHARACTER ( INPUT i-sum  AS DECIMAL"           + chr(10) +
                 "                            , INPUT i-curr AS CHARACTER"         + chr(10) +
                 "                            , INPUT i-part AS CHARACTER"         + chr(10) +
                 "                            ) ."                                 + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                      + chr(10) +
                 '  i-sum  - сумма в валюте;'                                      + chr(10) +
                 '  i-curr - валюта;'                                              + chr(10) +
                 '  i-part - название дробной части валюты.'                       + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                         + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Word-Sum-Eng,Word-Curr"                      + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + chr(10) + chr(10) +
                 'DEFINE VARIABLE d_num AS DECIMAL NO-UNDO INITIAL 753.84 .'       + chr(10) + chr(10) +
                 'MESSAGE'                                                         + chr(10) +
                 '             d_num                 SKIP( 0 )'                    + chr(10) +
                 '  Word-Curr( d_num, "USD", "cnt" ) SKIP( 0 )'                    + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                             + chr(10)
      .
    end.
    when 'WeekDay-Full'
    then do:
      assign
        p-help = 'Возвращает название дня недели по-русски по дате.'         + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                            + chr(10) +
                 "WeekDay-Full RETURNS CHARACTER ( INPUT i-date AS DATE ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                   + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l WeekDay-Full"                          + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                            + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                  + chr(10) + chr(10) +
                 'ASSIGN'                                                    + chr(10) +
                 '  t_date = TODAY'                                          + chr(10) +
                 '.'                                                         + chr(10) +
                 'MESSAGE'                                                   + chr(10) +
                 '  "Сегодня:" LC( WeekDay-Full( t_date ) + ", " +'          + chr(10) +
                 '  STRING( t_date, "99/99/9999":U ) + " г." )'              + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                       + chr(10)
      .
    end.
    when 'WeekDay-Short'
    then do:
      assign
        p-help = 'Возвращает короткое название (двухбуквенный код) дня недели по-русски '   +
                 'по дате.'                                                   + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                             + chr(10) +
                 "WeekDay-Short RETURNS CHARACTER ( INPUT i-date AS DATE ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                    + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l WeekDay-Short"                          + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                             + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                   + chr(10) + chr(10) +
                 'ASSIGN'                                                     + chr(10) +
                 '  t_date = TODAY'                                           + chr(10) +
                 '.'                                                          + chr(10) +
                 'MESSAGE'                                                    + chr(10) +
                 '  "Сегодня:" LC( WeekDay-Short( t_date ) + ", " +'          + chr(10) +
                 '  STRING( t_date, "99/99/9999":U ) + " г." )'               + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                        + chr(10)
      .
    end.
    when 'WeekDay-Rus'
    then do:
      assign
        p-help = 'Возвращает порядковый номер дня недели, начиная с понедельника.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                  + chr(10) +
                 "WeekDay-Rus RETURNS INTEGER ( INPUT i-date AS DATE ) ."          + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                         + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l WeekDay-Rus"                                 + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                        + chr(10) + chr(10) +
                 'ASSIGN'                                                          + chr(10) +
                 '  t_date = TODAY'                                                + chr(10) +
                 '.'                                                               + chr(10) +
                 'MESSAGE'                                                         + chr(10) +
                 '  "Сегодня:" STRING( t_date, "99/99/9999":U ) + ","'             + chr(10) +
                 '  STRING( WeekDay-Rus( t_date ) ) + "-й день недели"'            + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                             + chr(10)
      .
    end.
    when 'WeekDay-Full-Eng'
    then do:
      assign
        p-help = 'Возвращает название дня недели по-английски по дате.'          + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                + chr(10) +
                 "WeekDay-Full-Eng RETURNS CHARACTER ( INPUT i-date AS DATE ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                       + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l WeekDay-Full-Eng"                          + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                      + chr(10) + chr(10) +
                 'ASSIGN'                                                        + chr(10) +
                 '  t_date = TODAY'                                              + chr(10) +
                 '.'                                                             + chr(10) +
                 'MESSAGE'                                                       + chr(10) +
                 '  "Today" WeekDay-Full-Eng( t_date ) + ", " +'                 + chr(10) +
                 '  STRING( t_date, "99/99/9999":U )'                            + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                           + chr(10)
      .
    end.
    when 'WeekDay-Eng2'
    then do:
      assign
        p-help = 'Возвращает короткое название (двухбуквенный код) дня недели ' +
                 'по-английски по дате.'                                        + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                               + chr(10) +
                 "WeekDay-Eng2 RETURNS CHARACTER ( INPUT i-date AS DATE ) ."    + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                      + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l WeekDay-Eng2"                             + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                               + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                     + chr(10) + chr(10) +
                 'ASSIGN'                                                       + chr(10) +
                 '  t_date = TODAY'                                             + chr(10) +
                 '.'                                                            + chr(10) +
                 'MESSAGE'                                                      + chr(10) +
                 '  "Today" WeekDay-Eng2( t_date ) + ", " +'                    + chr(10) +
                 '  STRING( t_date, "99/99/9999":U )'                           + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                          + chr(10)
      .
    end.
    when 'WeekDay-Eng3'
    then do:
      assign
        p-help = 'Возвращает короткое название (трехбуквенный код) дня недели ' +
                 'по-английски по дате.'                                        + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                               + chr(10) +
                 "WeekDay-Eng3 RETURNS CHARACTER ( INPUT i-date AS DATE ) ."    + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                      + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l WeekDay-Eng3"                             + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                               + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                     + chr(10) + chr(10) +
                 'ASSIGN'                                                       + chr(10) +
                 '  t_date = TODAY'                                             + chr(10) +
                 '.'                                                            + chr(10) +
                 'MESSAGE'                                                      + chr(10) +
                 '  "Today" WeekDay-Eng3( t_date ) + ", " +'                    + chr(10) +
                 '  STRING( t_date, "99/99/9999":U )'                           + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                          + chr(10)
      .
    end.
    when 'WeekDay-Shrt3'
    then do:
      assign
        p-help = 'Возвращает короткое название (трехбуквенный код) дня недели по-русски '   +
                 'по дате.'                                                   + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                             + chr(10) +
                 "WeekDay-Shrt3 RETURNS CHARACTER ( INPUT i-date AS DATE ) ." + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                    + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l WeekDay-Shrt3"                          + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                             + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'                   + chr(10) + chr(10) +
                 'ASSIGN'                                                     + chr(10) +
                 '  t_date = TODAY'                                           + chr(10) +
                 '.'                                                          + chr(10) +
                 'MESSAGE'                                                    + chr(10) +
                 '  "Сегодня:" WeekDay-Shrt3( t_date ) + ", " +'              + chr(10) +
                 '  STRING( t_date, "99/99/9999":U ) + " г."'                 + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                        + chr(10)
      .
    end.
    when 'DelEntry'
    then do:
      assign
        p-help = 'Снять отметку "выбрано" с записи. Возвращает "новый" список (без удаленной '  +
                 'записи).'                                                       + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                 + chr(10) +
                 "DelEntry RETURNS CHARACTER ( INPUT i-list      AS CHARACTER"    + chr(10) +
                 "                           , INPUT i-item      AS CHARACTER"    + chr(10) +
                 "                           , INPUT i-delimiter AS CHARACTER"    + chr(10) +
                 "                           ) ."                                 + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                     + chr(10) +
                 '  i-list      - список, из которого нужно удалить элемент;'     + chr(10) +
                 '  i-item      - элемент, который нужно удалить из списка;'      + chr(10) +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'  + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                        + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l DelEntry"                                   + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL "":U .'     + chr(10) +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'     + chr(10) + chr(10) +
                 'ASSIGN'                                                         + chr(10) +
                 '  v_list = "Aa,Bb,Cc,xx,Dd,Ee,Ff"'                              + chr(10) +
                 '  v_item = "xx"'                                                + chr(10) +
                 '.'                                                              + chr(10) +
                 'MESSAGE'                                                        + chr(10) +
                 '  "Список:"                   v_list              SKIP( 0 )'    + chr(10) +
                 '  "Элемент:"                          v_item      SKIP( 1 )'    + chr(10) +
                 '  "После удаления:" DelEntry( v_list, v_item, ? ) SKIP( 0 )'    + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                            + chr(10)
      .
    end.
    when 'addl-list'
    then do:
      assign
        p-help = 'Добавить новый элемент в список на последнее место. Возвращает "новый" '      +
                 'список (с добавленной записью).'                                + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                 + chr(10) +
                 "addl-list RETURNS CHARACTER ( INPUT i-list      AS CHARACTER,"  + chr(10) +
                 "                              INPUT i-item      AS CHARACTER,"  + chr(10) +
                 "                            , INPUT i-delimiter AS CHARACTER"   + chr(10) +
                 "                            ) ."                                + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                     + chr(10) +
                 '  i-list      - список, из которого нужно удалить элемент;'     + chr(10) +
                 '  i-item      - элемент, который нужно удалить из списка;'      + chr(10) +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'  + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                        + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l addl-list"                                  + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL "":U .'     + chr(10) +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'     + chr(10) + chr(10) +
                 'ASSIGN'                                                         + chr(10) +
                 '  v_list = "Aa,Bb,Cc,Dd,Ee,Ff"'                                 + chr(10) +
                 '  v_item = "xx"'                                                + chr(10) +
                 '.'                                                              + chr(10) +
                 'MESSAGE'                                                        + chr(10) +
                 '  "Список:"                      v_list              SKIP( 0 )' + chr(10) +
                 '  "Элемент:"                             v_item      SKIP( 1 )' + chr(10) +
                 '  "После добавления:" addl-list( v_list, v_item, ? ) SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                            + chr(10)
      .
    end.
    when 'addf-list'
    then do:
      assign
        p-help = 'Добавить новый элемент в список на первое место. Возвращает "новый" '         +
                 'список (с добавленной записью).'                                + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                 + chr(10) +
                 "addf-list RETURNS CHARACTER ( INPUT i-list      AS CHARACTER,"  + chr(10) +
                 "                              INPUT i-item      AS CHARACTER,"  + chr(10) +
                 "                            , INPUT i-delimiter AS CHARACTER"   + chr(10) +
                 "                            ) ."                                + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                     + chr(10) +
                 '  i-list      - список, из которого нужно удалить элемент;'     + chr(10) +
                 '  i-item      - элемент, который нужно удалить из списка;'      + chr(10) +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'  + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                        + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l addf-list"                                  + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL "":U .'     + chr(10) +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'     + chr(10) + chr(10) +
                 'ASSIGN'                                                         + chr(10) +
                 '  v_list = "Aa,Bb,Cc,Dd,Ee,Ff"'                                 + chr(10) +
                 '  v_item = "xx"'                                                + chr(10) +
                 '.'                                                              + chr(10) +
                 'MESSAGE'                                                        + chr(10) +
                 '  "Список:"                      v_list              SKIP( 0 )' + chr(10) +
                 '  "Элемент:"                             v_item      SKIP( 1 )' + chr(10) +
                 '  "После добавления:" addf-list( v_list, v_item, ? ) SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX.'                                             + chr(10)
      .
    end.
    when 'addn-list'
    then do:
      assign
        p-help = 'Добавить новый элемент в список на указанную позицию. Возвращает "новый" список (с добавленной '  +
                 'записью).'                                                            + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                       + chr(10) +
                 "addn-list RETURNS CHARACTER ( INPUT i-list      AS CHARACTER"         + chr(10) +
                 "                            , INPUT i-item      AS CHARACTER"         + chr(10) +
                 "                            , INPUT i-delimiter AS CHARACTER"         + chr(10) +
                 "                            , INPUT i-pos       AS INTEGER"           + chr(10) +
                 "                            ) ."                                      + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                           + chr(10) +
                 '  i-list      - список, из которого нужно удалить элемент;'           + chr(10) +
                 '  i-item      - элемент, который нужно удалить из списка;'            + chr(10) +
                 '  i-delimiter - разделитель в списке; если не указан, то ",";'        + chr(10) +
                 '  i-pos       - номер позиции, на которую нужно добавить элемент.'    + chr(10) + chr(10) +
                 'Если номер позиции не указан или равен "0", то элемент добавляется на 1-ю позицию.' + chr(10) +
                 'Если количество элементов в списке меньше указанной позиции, то '     +
                 'список "расширяется" пустыми '                                        + chr(10) +
                 'значениями, и элемент добавляется на последнюю позицию.'              + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                              + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l addn-list"                                        + chr(10) + chr(10) +
                 "~{ cmp/str-glbl.i        ~}"                                          + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + chr(10) + chr(10) +
                 'DEFINE VARIABLE jj      AS INTEGER   NO-UNDO INITIAL 0 .'             + chr(10) +
                 'DEFINE VARIABLE j1      AS INTEGER   NO-UNDO INITIAL 0 .'             + chr(10) +
                 'DEFINE VARIABLE v_delim AS CHARACTER NO-UNDO INITIAL "":U .'          + chr(10) +
                 'DEFINE VARIABLE v_list  AS CHARACTER NO-UNDO INITIAL "":U .'          + chr(10) +
                 'DEFINE VARIABLE v_item  AS CHARACTER NO-UNDO INITIAL "":U .'          + chr(10) + chr(10) +
                 'ASSIGN'                                                               + chr(10) +
                 '  v_list  = "Aa,Bb,Cc,Dd,Ee,Ff,Gg,Hh"'                                + chr(10) +
                 '  v_item  = "xx"'                                                     + chr(10) +
                 '  v_delim = ~{~&comma-char~}'                                         + chr(10) +
                 '  j1      = NUM-ENTRIES( v_list, v_delim )'                           + chr(10) +
                 '.'                                                                    + chr(10) +
                 'MESSAGE'                                                              + chr(10) +
                 '  "Список:"           v_list j1  SKIP( 0 )'                           + chr(10) +
                 '  "Разделитель:"      v_delim    SKIP( 0 )'                           + chr(10) +
                 '  "Элемент:"          v_item "?" SKIP( 1 )'                           + chr(10) +
                 '  "После добавления:" addn-list( v_list, v_item, v_delim, ? )'        + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                  + chr(10) +
                 'DO jj = 1 TO j1 + 1 :'                                                + chr(10) +
                 '  MESSAGE'                                                            + chr(10) +
                 '    "Список:"           v_list j1 SKIP( 0 )'                          + chr(10) +
                 '    "Разделитель:"      v_delim   SKIP( 0 )'                          + chr(10) +
                 '    "Элемент:"          v_item jj SKIP( 1 )'                          + chr(10) +
                 '    "После добавления:" addn-list( v_list, v_item, v_delim, jj )'     + chr(10) +
                 '  VIEW-AS ALERT-BOX .'                                                + chr(10) +
                 'END.'                                                                 + chr(10) +
                 'MESSAGE'                                                              + chr(10) +
                 '  "Список:"           v_list  j1     SKIP( 0 )'                       + chr(10) +
                 '  "Разделитель:"      v_delim        SKIP( 0 )'                       + chr(10) +
                 '  "Элемент:"          v_item  j1 * 2 SKIP( 1 )'                       + chr(10) +
                 '  "После добавления:" addn-list( v_list, v_item, v_delim, j1 * 2 )'   + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                  + chr(10)
      .
    end.
    when 'super-pos'
    then do:
      assign
        p-help = 'Суперпозиция двух множеств, заданных списками. '                      +
                 'Возвращает результирующее множество (список).'                        + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                       + chr(10) +
                 "super-pos RETURNS CHARACTER ( INPUT i-list-1    AS CHARACTER"         + chr(10) +
                 "                            , INPUT i-list-2    AS CHARACTER"         + chr(10) +
                 "                            , INPUT i-delimiter AS CHARACTER"         + chr(10) +
                 "                            ) ."                                      + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                           + chr(10) +
                 '  i-list-1    - 1-й список, из которого вычитается 2-й;'              + chr(10) +
                 '  i-list-2    - 2-й список, который вычитается из 1-го;'              + chr(10) +
                 '  i-delimiter - разделитель в списках; если не указан, то ",".'       + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                              + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l super-pos"                                        + chr(10) + chr(10) +
                 "~{ cmp/str-glbl.i        ~}"                                          + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_list1 AS CHARACTER NO-UNDO INITIAL "":U .'          + chr(10) +
                 'DEFINE VARIABLE v_list2 AS CHARACTER NO-UNDO INITIAL "":U .'          + chr(10) +
                 'DEFINE VARIABLE v_delim AS CHARACTER NO-UNDO INITIAL "":U .'          + chr(10) + chr(10) +
                 'ASSIGN'                                                               + chr(10) +
                 '  v_list1 = "Aa,Bb,Cc,Dd,Ee,Ff,Gg,Hh"'                                + chr(10) +
                 '  v_list2 = "Ff,Gg,Hh,Ii,Jj,Kk,Ll,Mm"'                                + chr(10) +
                 '  v_delim = ~{~&comma-char~}'                                         + chr(10) +
                 '.'                                                                    + chr(10) +
                 'MESSAGE'                                                              + chr(10) +
                 '  "1-й список:"                v_list1                     SKIP( 0 )' + chr(10) +
                 '  "2-й список:"                         v_list2            SKIP( 0 )' + chr(10) +
                 '  "Суперпозиция 1:" super-pos( v_list1, v_list2, v_delim ) SKIP( 0 )' + chr(10) +
                 '  "Суперпозиция 2:" super-pos( v_list2, v_list1, v_delim ) SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                  + chr(10)
      .
    end.
    when 'sets-union'
    then do:
      assign
        p-help = 'Объединение двух множеств, заданных списками. '                     +
                 'Возвращает результирующее множество (список).'                      + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                     + chr(10) +
                 "sets-union RETURNS CHARACTER ( INPUT i-list-1    AS CHARACTER"      + chr(10) +
                 "                             , INPUT i-list-2    AS CHARACTER"      + chr(10) +
                 "                             , INPUT i-delimiter AS CHARACTER"      + chr(10) +
                 "                             ) ."                                   + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                         + chr(10) +
                 '  i-list-1    - 1-й список;'                                        + chr(10) +
                 '  i-list-2    - 2-й список;'                                        + chr(10) +
                 '  i-delimiter - разделитель в списках; если не указан, то ",".'     + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                            + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l sets-union"                                     + chr(10) + chr(10) +
                 "~{ cmp/str-glbl.i        ~}"                                        + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                     + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_list1 AS CHARACTER NO-UNDO INITIAL "":U .'        + chr(10) +
                 'DEFINE VARIABLE v_list2 AS CHARACTER NO-UNDO INITIAL "":U .'        + chr(10) +
                 'DEFINE VARIABLE v_delim AS CHARACTER NO-UNDO INITIAL "":U .'        + chr(10) + chr(10) +
                 'ASSIGN'                                                             + chr(10) +
                 '  v_list1 = "Aa,Bb,Cc,Dd,Ee,Ff,Gg,Hh"'                              + chr(10) +
                 '  v_list2 = "Ff,Gg,Hh,Ii,Jj,Kk,Ll,Mm"'                              + chr(10) +
                 '  v_delim = ~{~&comma-char~}'                                       + chr(10) +
                 '.'                                                                  + chr(10) +
                 'MESSAGE'                                                            + chr(10) +
                 '  "1-й список:"              v_list1                     SKIP( 0 )' + chr(10) +
                 '  "2-й список:"                       v_list2            SKIP( 0 )' + chr(10) +
                 '  "Объединение:" sets-union( v_list1, v_list2, v_delim ) SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                + chr(10)
      .
    end.
    when 'ChooseMark'
    then do:
      assign
        p-help = 'Пометить / снять отметку "выбрано" с записи. Возвращает "новый" список (соответственно, '  +
                 'с помеченной или без помеченной записи).'                      + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                + chr(10) +
                 "ChooseMark RETURNS CHARACTER ( INPUT i-list      AS CHARACTER" + chr(10) +
                 "                             , INPUT i-item      AS CHARACTER" + chr(10) +
                 "                             , INPUT i-delimiter AS CHARACTER" + chr(10) +
                 "                             ) ."                              + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                    + chr(10) +
                 '  i-list      - список;'                                       + chr(10) +
                 '  i-item      - элемент;'                                      + chr(10) +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".' + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                       + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l ChooseMark"                                + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_lst1 AS CHARACTER NO-UNDO INITIAL "":U .'    + chr(10) +
                 'DEFINE VARIABLE v_lst2 AS CHARACTER NO-UNDO INITIAL "":U .'    + chr(10) +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'    + chr(10) + chr(10) +
                 'ASSIGN'                                                        + chr(10) +
                 '  v_lst1 = "Aa,Bb,Cc,xx,Dd,Ee,Ff"'                             + chr(10) +
                 '  v_lst2 = "Aa,Bb,Cc,Dd,Ee,Ff"'                                + chr(10) +
                 '  v_item = "xx"'                                               + chr(10) +
                 '.'                                                             + chr(10) +
                 'MESSAGE'                                                       + chr(10) +
                 '  "Список:"                v_lst1              SKIP( 0 )'      + chr(10) +
                 '  "Элемент:"                       v_item      SKIP( 0 )'      + chr(10) +
                 '  "Результат:" ChooseMark( v_lst1, v_item, ? ) SKIP( 1 )'      + chr(10) +
                 '  "Список:"                v_lst2              SKIP( 0 )'      + chr(10) +
                 '  "Элемент:"                       v_item      SKIP( 0 )'      + chr(10) +
                 '  "Результат:" ChooseMark( v_lst2, v_item, ? ) SKIP( 0 )'      + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                           + chr(10)
      .
    end.
    when 'is-marked'
    then do:
      assign
        p-help = 'Возвращает - помечена запись или нет.'                               + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                      + chr(10) +
                 "is-marked RETURNS LOGICAL ( INPUT i-list      AS CHARACTER"          + chr(10) +
                 "                          , INPUT i-item      AS CHARACTER"          + chr(10) +
                 "                          , INPUT i-delimiter AS CHARACTER"          + chr(10) +
                 "                          ) ."                                       + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                          + chr(10) +
                 '  i-list      - список;'                                             + chr(10) +
                 '  i-item      - элемент;'                                            + chr(10) +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'       + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                             + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l is-marked"                                       + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                      + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_list  AS CHARACTER NO-UNDO INITIAL "":U .'         + chr(10) +
                 'DEFINE VARIABLE v_item1 AS CHARACTER NO-UNDO INITIAL "":U .'         + chr(10) +
                 'DEFINE VARIABLE v_item2 AS CHARACTER NO-UNDO INITIAL "":U .'         + chr(10) + chr(10) +
                 'ASSIGN'                                                              + chr(10) +
                 '  v_list  = "Aa,Bb,Cc,xx,Dd,Ee,Ff"'                                  + chr(10) +
                 '  v_item1 = "yy"'                                                    + chr(10) +
                 '  v_item2 = "xx"'                                                    + chr(10) +
                 '.'                                                                   + chr(10) +
                 'MESSAGE'                                                             + chr(10) +
                 '  "Список:"  v_list                                               SKIP( 1 )'       + chr(10) +
                 '  "Элемент:" v_item1 "Результат:" is-marked( v_list, v_item1, ? ) SKIP( 0 )'       + chr(10) +
                 '  "Элемент:" v_item2 "Результат:" is-marked( v_list, v_item2, ? ) SKIP( 0 )'       + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                 + chr(10)
      .
    end.
    when 'MarkSign'
    then do:
      assign
        p-help = 'Возвращает текущий знак помечено или свободно для записи.'              + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                         + chr(10) +
                 "MarkSign RETURNS CHARACTER ( INPUT i-list      AS CHARACTER"            + chr(10) +
                 "                           , INPUT i-item      AS CHARACTER"            + chr(10) +
                 "                           , INPUT i-delimiter AS CHARACTER"            + chr(10) +
                 "                           ) ."                                         + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                             + chr(10) +
                 '  i-list      - список;'                                                + chr(10) +
                 '  i-item      - элемент;'                                               + chr(10) +
                 '  i-delimiter - разделитель в списке; если не указан, то ",".'          + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                                + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l MarkSign"                                           + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                         + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_lst1 AS CHARACTER NO-UNDO INITIAL "":U .'             + chr(10) +
                 'DEFINE VARIABLE v_lst2 AS CHARACTER NO-UNDO INITIAL "":U .'             + chr(10) +
                 'DEFINE VARIABLE v_item AS CHARACTER NO-UNDO INITIAL "":U .'             + chr(10) + chr(10) +
                 'ASSIGN'                                                                 + chr(10) +
                 '  v_lst1 = "Aa,Bb,Cc,xx,Dd,Ee,Ff"'                                      + chr(10) +
                 '  v_lst2 = "Aa,Bb,Cc,Dd,Ee,Ff"'                                         + chr(10) +
                 '  v_item = "xx"'                                                        + chr(10) +
                 '.'                                                                      + chr(10) +
                 'MESSAGE'                                                                + chr(10) +
                 '  "Список:"                     v_lst1                     SKIP( 0 )'   + chr(10) +
                 '  "Элемент:"                            v_item             SKIP( 0 )'   + chr(10) +
                 '  "Результат:" "~~"" + MarkSign( v_lst1, v_item, ? ) + "~~"" SKIP( 1 )' + chr(10) +
                 '  "Список:"                     v_lst2                     SKIP( 0 )'   + chr(10) +
                 '  "Элемент:"                            v_item             SKIP( 0 )'   + chr(10) +
                 '  "Результат:" "~~"" + MarkSign( v_lst2, v_item, ? ) + "~~"" SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                    + chr(10)
      .
    end.
    when 'NumDays'
    then do:
      assign
        p-help = 'Возвращает порядковый номер дня с начала года.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                 + chr(10) +
                 "NumDays RETURNS INTEGER ( INPUT DATE ) ."       + chr(10) + chr(10) +
                 "ПРИМЕР:"                                        + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l NumDays"                    + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                 + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO .'       + chr(10) + chr(10) +
                 'ASSIGN'                                         + chr(10) +
                 '  t_date = TODAY'                               + chr(10) +
                 '.'                                              + chr(10) +
                 'MESSAGE'                                        + chr(10) +
                 '  "Сегодня:"       t_date                         SKIP( 0 )'  + chr(10) +
                 '  STRING( NumDays( t_date ) ) + "-й день в году." SKIP( 0 )'  + chr(10) +
                 'VIEW-AS ALERT-BOX .'                            + chr(10)
      .
    end.
    when 'DateNum'
    then do:
      assign
        p-help = 'Возвращает дату по порядковому номеру дня в году и году.'    + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                              + chr(10) +
                 "DateNum RETURNS INTEGER ( INPUT i-days AS INTEGER"           + chr(10) +
                 "                        , INPUT i-year AS INTEGER"           + chr(10) +
                 "                        ) ."                                 + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                     + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l DateNum"                                 + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + chr(10) + chr(10) +
                 'DEFINE VARIABLE j_days AS INTEGER NO-UNDO .'                 + chr(10) +
                 'DEFINE VARIABLE j_year AS INTEGER NO-UNDO .'                 + chr(10) + chr(10) +
                 'ASSIGN'                                                      + chr(10) +
                 '  j_days = 365'                                              + chr(10) +
                 '  j_year = YEAR( TODAY )'                                    + chr(10) +
                 '.'                                                           + chr(10) +
                 'MESSAGE'                                                     + chr(10) +
                 '  STRING( j_days ) + "-й день в" j_year "году - " SKIP( 0 )' + chr(10) +
                 '  "это:" DateNum( j_days, j_year )                SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                         + chr(10)
      .
    end.
    when 'KeyStamp'
    then do:
      assign
        p-help = 'Возвращает ключ на основании текущих даты и времени.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                       + chr(10) +
                 "KeyStamp RETURNS CHARACTER ."                         + chr(10) + chr(10) +
                 "ПРИМЕР:"                                              + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l KeyStamp"                         + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                       + chr(10) + chr(10) +
                 'MESSAGE'                                              + chr(10) +
                 '  KeyStamp( ) SKIP( 0 )'                              + chr(10) +
                 '  "Подождите 5 секунд..."'                            + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                  + chr(10) +
                 'MESSAGE'                                              + chr(10) +
                 '  KeyStamp( )'                                        + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                  + chr(10)
      .
    end.
    when 'Int2Hex'
    then do:
      assign
        p-help = 'Конвертация целого числа в его 16-ричное представление.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                          + chr(10) +
                 "Int2Hex RETURNS CHARACTER ( INPUT INTEGER ) ."           + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                 + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Int2Hex"                             + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                          + chr(10) + chr(10) +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 1025 .' + chr(10) + chr(10) +
                 'MESSAGE'                                                 + chr(10) +
                 '  j_num "-->" "0x" + Int2Hex( j_num )'                   + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                     + chr(10)
      .
    end.
    when 'Hex2Int'
    then do:
      assign
        p-help = 'Конвертация 16-ричного целого числа в 10-тичное.'          + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                            + chr(10) +
                 "Hex2Int RETURNS INTEGER ( INPUT CHARACTER ) ."             + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                   + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Hex2Int"                               + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                            + chr(10) + chr(10) +
                 'DEFINE VARIABLE c_num AS CHARACTER NO-UNDO INITIAL "FF" .' + chr(10) + chr(10) +
                 'MESSAGE'                                                   + chr(10) +
                 '  "0x" + c_num "-->" Hex2Int( c_num )'                     + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                       + chr(10)
      .
    end.
    when 'Int2Base'
    then do:
      assign
        p-help = 'Конвертация целого числа в представление по заданному основанию.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                   + chr(10) +
                 "Int2Base RETURNS CHARACTER ( INPUT i-num  AS INTEGER"             + chr(10) +
                 "                           , INPUT i-base AS INTEGER"             + chr(10) +
                 "                           ) ."                                   + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                       + chr(10) +
                 '  i-num  - целое число, которое нужно сконвертировать;'           + chr(10) +
                 '  i-base - основание, по которому нужно сконвертировать число.'   + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                          + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Int2Base"                                     + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                   + chr(10) + chr(10) +
                 'DEFINE VARIABLE j_num  AS INTEGER NO-UNDO INITIAL 1000 .'         + chr(10) +
                 'DEFINE VARIABLE j_base AS INTEGER NO-UNDO INITIAL   60 .'         + chr(10) + chr(10) +
                 'MESSAGE'                                                          + chr(10) +
                 '  j_num "-->" Int2Base( j_num, j_base )'                          + chr(10) +
                 '  "по основанию" j_base'                                          + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                              + chr(10)
      .
    end.
    when 'Base2Int'
    then do:
      assign
        p-help = 'Конвертация целого числа в целое число по заданному основанию.'  + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                  + chr(10) +
                 "Base2Int RETURNS INTEGER ( INPUT i-image AS CHARACTER"           + chr(10) +
                 "                         , INPUT i-base  AS INTEGER"             + chr(10) +
                 "                         ) ."                                    + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                      + chr(10) +
                 '  i-image - целое число, которое нужно сконвертировать;'         + chr(10) +
                 '  i-base  - основание, по которому нужно сконвертировать число.' + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                         + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Base2Int"                                    + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + chr(10) + chr(10) +
                 'DEFINE VARIABLE c_num  AS CHARACTER NO-UNDO INITIAL "GЖ" .'      + chr(10) +
                 'DEFINE VARIABLE j_base AS INTEGER   NO-UNDO INITIAL 60 .'        + chr(10) + chr(10) +
                 'MESSAGE'                                                         + chr(10) +
                 '  c_num "по основанию" j_base "-->"'                             + chr(10) +
                 '  Base2Int( c_num, j_base )'                                     + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                             + chr(10)
      .
    end.
    when 'Base2Int64'
    then do:
      assign
        p-help = 'Конвертация целого числа в целое число по заданному основанию.'  + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                  + chr(10) +
                 "Base2Int64 RETURNS INT64 ( INPUT i-image AS CHARACTER"           + chr(10) +
                 "                         , INPUT i-base  AS INTEGER"             + chr(10) +
                 "                         ) ."                                    + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                      + chr(10) +
                 '  i-image - целое число, которое нужно сконвертировать;'         + chr(10) +
                 '  i-base  - основание, по которому нужно сконвертировать число.' + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                         + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Base2Int64"                                  + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                  + chr(10) + chr(10) +
                 'DEFINE VARIABLE c_num  AS CHARACTER NO-UNDO INITIAL "GЖ" .'      + chr(10) +
                 'DEFINE VARIABLE j_base AS INTEGER   NO-UNDO INITIAL 60 .'        + chr(10) + chr(10) +
                 'MESSAGE'                                                         + chr(10) +
                 '  c_num "по основанию" j_base "-->"'                             + chr(10) +
                 '  Base2Int64( c_num, j_base )'                                   + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                             + chr(10)
      .
    end.
    when 'Int2Octal'
    then do:
      assign
        p-help = 'Конвертация целого числа в его 8-ричное представление.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                         + chr(10) +
                 "Int2Octal RETURNS CHARACTER ( INPUT INTEGER ) ."        + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Int2Octal"                          + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + chr(10) + chr(10) +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 493 .' + chr(10) + chr(10) +
                 'MESSAGE'                                                + chr(10) +
                 '  j_num "-->" Int2Octal( j_num )'                       + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                    + chr(10)
      .
    end.
    when 'Oct2Int'
    then do:
      assign
        p-help = 'Конвертация 8-ричного целого числа в 10-тичное.'            + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                             + chr(10) +
                 "Oct2Int RETURNS INTEGER ( INPUT CHARACTER ) ."              + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                    + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Oct2Int"                                + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                             + chr(10) + chr(10) +
                 'DEFINE VARIABLE c_num AS CHARACTER NO-UNDO INITIAL "377" .' + chr(10) + chr(10) +
                 'MESSAGE'                                                    + chr(10) +
                 '  c_num "-->" Oct2Int( c_num )'                             + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                        + chr(10)
      .
    end.
    when 'Int2Bin'
    then do:
      assign
        p-help = 'Конвертация целого числа в его двоичное представление.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                         + chr(10) +
                 "Int2Bin RETURNS CHARACTER ( INPUT INTEGER ) ."          + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Int2Bin"                            + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + chr(10) + chr(10) +
                 'DEFINE VARIABLE j_num AS INTEGER NO-UNDO INITIAL 15 .'  + chr(10) + chr(10) +
                 'MESSAGE'                                                + chr(10) +
                 '  j_num "-->" Int2Bin( j_num )'                         + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                    + chr(10)
      .
    end.
    when 'Bin2Int'
    then do:
      assign
        p-help = 'Конвертация двоичного целого числа в 10-тичное.'              + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                               + chr(10) +
                 "Bin2Int RETURNS INTEGER ( INPUT CHARACTER ) ."                + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                      + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Bin2Int"                                  + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                               + chr(10) + chr(10) +
                 'DEFINE VARIABLE c_num AS CHARACTER NO-UNDO INITIAL "11111" .' + chr(10) + chr(10) +
                 'MESSAGE'                                                      + chr(10) +
                 '  c_num "-->" Bin2Int( c_num )'                               + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                          + chr(10)
      .
    end.
    otherwise do:
      run GetFunctionHelp2 in this-procedure
        (  input p-name
        , output p-help
        ) .
    end.
  end case.
end procedure.
procedure GetFunctionHelp2 :
  define  input parameter p-name as character no-undo .
  define output parameter p-help as character no-undo .
  case p-name :
    when 'sets-intersection'
    then do:
      assign
        p-help = 'Пересечение двух множеств, заданных списками. '                            +
                 'Возвращает результирующее множество (список).'                             + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                            + chr(10) +
                 "sets-intersection RETURNS CHARACTER ( INPUT i-list-1    AS CHARACTER"      + chr(10) +
                 "                                    , INPUT i-list-2    AS CHARACTER"      + chr(10) +
                 "                                    , INPUT i-delimiter AS CHARACTER"      + chr(10) +
                 "                                    ) ."                                   + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                                                + chr(10) +
                 '  i-list-1    - 1-й список;'                                               + chr(10) +
                 '  i-list-2    - 2-й список;'                                               + chr(10) +
                 '  i-delimiter - разделитель в списках; если не указан, то ",".'            + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                                   + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l sets-intersection"                                     + chr(10) + chr(10) +
                 "~{ cmp/str-glbl.i        ~}"                                               + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                            + chr(10) + chr(10) +
                 'DEFINE VARIABLE v_list1 AS CHARACTER NO-UNDO INITIAL "":U .'               + chr(10) +
                 'DEFINE VARIABLE v_list2 AS CHARACTER NO-UNDO INITIAL "":U .'               + chr(10) +
                 'DEFINE VARIABLE v_delim AS CHARACTER NO-UNDO INITIAL "":U .'               + chr(10) + chr(10) +
                 'ASSIGN'                                                                    + chr(10) +
                 '  v_list1 = "Aa,Bb,Cc,Dd,Ee,Ff,Gg,Hh"'                                     + chr(10) +
                 '  v_list2 = "Ff,Gg,Hh,Ii,Jj,Kk,Ll,Mm"'                                     + chr(10) +
                 '  v_delim = ~{~&comma-char~}'                                              + chr(10) +
                 '.'                                                                         + chr(10) +
                 'MESSAGE'                                                                   + chr(10) +
                 '  "1-й список:"                     v_list1                     SKIP( 0 )' + chr(10) +
                 '  "2-й список:"                              v_list2            SKIP( 0 )' + chr(10) +
                 '  "Пересечение:" sets-intersection( v_list1, v_list2, v_delim ) SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                       + chr(10)
      .
    end.
    when 'Week-Num'
    then do:
      assign
        p-help = 'Возвращает номер недели по дате.'                   + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                     + chr(10) +
                 "Week-Num RETURNS INTEGER ( INPUT DATE ) ."          + chr(10) + chr(10) +
                 "ПРИМЕР:"                                            + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Week-Num"                       + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                     + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE NO-UNDO INITIAL ? .' + chr(10) + chr(10) +
                 'ASSIGN'                                             + chr(10) +
                 '  t_date = TODAY'                                   + chr(10) +
                 '.'                                                  + chr(10) +
                 'MESSAGE'                                            + chr(10) +
                 '  "Дата:"                   t_date   SKIP( 0 )'     + chr(10) +
                 '  "Номер недели:" Week-Num( t_date ) SKIP( 0 )'     + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                + chr(10)
      .
    end.
    when 'Week-From'
    then do:
      assign
        p-help = 'Возвращает дату начала недели.'                        + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                        + chr(10) +
                 "Week-From RETURNS DATE ( INPUT i-week AS INTEGER,"     + chr(10) +
                 "                       , INPUT i-year AS INTEGER"      + chr(10) +
                 "                       ) ."                            + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                            + chr(10) +
                 '  i-week - номер недели в году;'                       + chr(10) +
                 '  i-year - год; если не указан, то берется текущий.'   + chr(10) + chr(10) +
                 "ПРИМЕР:"                                               + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Week-Num,Week-From"                + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                        + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE    NO-UNDO INITIAL ? .' + chr(10) +
                 'DEFINE VARIABLE j_week AS INTEGER NO-UNDO INITIAL 0 .' + chr(10) + chr(10) +
                 'ASSIGN'                                                + chr(10) +
                 '  t_date = TODAY'                                      + chr(10) +
                 '  j_week = Week-Num( t_date )'                         + chr(10) +
                 '.'                                                     + chr(10) +
                 'MESSAGE'                                               + chr(10) +
                 '  "Дата начала текущей недели:"'                       + chr(10) +
                 '  Week-From( j_week, YEAR( t_date ) ) SKIP( 1 )'       + chr(10) +
                 '  "Номер недели:" Week-Num( t_date )  SKIP( 0 )'       + chr(10) +
                 '  "Текущая дата:" t_date              SKIP( 0 )'       + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                   + chr(10)
      .
    end.
    when 'Week-Till'
    then do:
      assign
        p-help = 'Возвращает дату окончания недели.'                     + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                        + chr(10) +
                 "Week-Till RETURNS DATE ( INPUT i-week AS INTEGER"      + chr(10) +
                 "                       , INPUT i-year AS INTEGER"      + chr(10) +
                 "                       ) ."                            + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                            + chr(10) +
                 '  i-week - номер недели в году;'                       + chr(10) +
                 '  i-year - год; если не указан, то берется текущий.'   + chr(10) + chr(10) +
                 "ПРИМЕР:"                                               + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Week-Num,Week-Till"                + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                        + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE    NO-UNDO INITIAL ? .' + chr(10) +
                 'DEFINE VARIABLE j_week AS INTEGER NO-UNDO INITIAL 0 .' + chr(10) + chr(10) +
                 'ASSIGN'                                                + chr(10) +
                 '  t_date = TODAY'                                      + chr(10) +
                 '  j_week = Week-Num( t_date )'                         + chr(10) +
                 '.'                                                     + chr(10) +
                 'MESSAGE'                                               + chr(10) +
                 '  "Дата окончания текущей недели:"'                    + chr(10) +
                 '  Week-Till( j_week, YEAR( t_date ) ) SKIP( 1 )'       + chr(10) +
                 '  "Номер недели:" Week-Num( t_date )  SKIP( 0 )'       + chr(10) +
                 '  "Текущая дата:" t_date              SKIP( 0 )'       + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                   + chr(10)
      .
    end.
    when 'Week-Date'
    then do:
      assign
        p-help = 'Возвращает дату по номеру недели в году, номеру дня в '   +
                 'неделе и году.'                                           + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                           + chr(10) +
                 "Week-Date RETURNS DATE ( INPUT i-week AS INTEGER"         + chr(10) +
                 "                       , INPUT i-day  AS INTEGER"         + chr(10) +
                 "                       , INPUT i-year AS INTEGER"         + chr(10) +
                 "                       ) ."                               + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                               + chr(10) +
                 '  i-week - номер недели в году;'                          + chr(10) +
                 '  i-day  - номер дня в неделе (русский вариант);'         + chr(10) +
                 '  i-year - год; если не указан, то берется текущий.'      + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                  + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Week-Num,Week-Date"                   + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                           + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE    NO-UNDO INITIAL ? .'    + chr(10) +
                 'DEFINE VARIABLE j_week AS INTEGER NO-UNDO INITIAL 0 .'    + chr(10) + chr(10) +
                 'ASSIGN'                                                   + chr(10) +
                 '  t_date = TODAY'                                         + chr(10) +
                 '  j_week = Week-Num( t_date )'                            + chr(10) +
                 '.'                                                        + chr(10) +
                 'MESSAGE "Пятница на текущей неделе:"'                     + chr(10) +
                 'MESSAGE "Пятница на текущей неделе:"'                     + chr(10) +
                 '        Week-Date( j_week, 5, YEAR( t_date ) ) SKIP( 1 )' + chr(10) +
                 '        "Номер недели:" Week-Num( t_date )     SKIP( 0 )' + chr(10) +
                 '        "Текущая дата:" t_date                 SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                      + chr(10)
      .
    end.
    when 'Week-Date-Eng'
    then do:
      assign
        p-help = 'Возвращает дату по номеру недели в году, номеру дня в ' +
                 'неделе и году.'                                         + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                         + chr(10) +
                 "Week-Date-Eng RETURNS DATE ( INPUT i-week AS INTEGER"   + chr(10) +
                 "                           , INPUT i-day  AS INTEGER"   + chr(10) +
                 "                           , INPUT i-year AS INTEGER"   + chr(10) +
                 "                           ) ."                         + chr(10) + chr(10) +
                 "ПАРАМЕТРЫ:"                                             + chr(10) +
                 '  i-week - номер недели в году;'                        + chr(10) +
                 '  i-day  - номер дня в неделе (русский вариант);'       + chr(10) +
                 '  i-year - год; если не указан, то берется текущий.'    + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Week-Num,Week-Date-Eng"             + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                         + chr(10) + chr(10) +
                 'DEFINE VARIABLE t_date AS DATE    NO-UNDO INITIAL ? .'  + chr(10) +
                 'DEFINE VARIABLE j_week AS INTEGER NO-UNDO INITIAL 0 .'  + chr(10) + chr(10) +
                 'ASSIGN'                                                 + chr(10) +
                 '  t_date = TODAY'                                       + chr(10) +
                 '  j_week = Week-Num( t_date )'                          + chr(10) +
                 '.'                                                      + chr(10) +
                 'MESSAGE'                                                + chr(10) +
                 '  "Пятница на текущей неделе:"'                         + chr(10) +
                 '  Week-Date-Eng( j_week, 6, YEAR( t_date ) ) SKIP( 1 )' + chr(10) +
                 '  "Номер недели:" Week-Num( t_date )         SKIP( 0 )' + chr(10) +
                 '  "Текущая дата:" t_date                     SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                    + chr(10)
      .
    end.
    when 'Leap-Year'
    then do:
      assign
        p-help = 'Возвращает, високосный ли год (по году).'                             + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                       + chr(10) +
                 "Leap-Year RETURNS LOGICAL ( INPUT INTEGER ) ."                        + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                              + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Leap-Year"                                        + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + chr(10) + chr(10) +
                 'MESSAGE'                                                              + chr(10) +
                 '  "Нынче"'                                                            + chr(10) +
                 '  STRING( Leap-Year( YEAR( TODAY ) ), "високосный/не високосный":U )' + chr(10) +
                 '  "год."'                                                             + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                  + chr(10)
      .
    end.
    when 'Leap-Year-d'
    then do:
      assign
        p-help = 'Возвращает, високосный ли год (по дате).'                       + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                 + chr(10) +
                 "Leap-Year RETURNS LOGICAL ( INPUT DATE ) ."                     + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                        + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Leap-Year-d"                                + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                 + chr(10) + chr(10) +
                 'MESSAGE'                                                        + chr(10) +
                 '  "Нынче"'                                                      + chr(10) +
                 '  STRING( Leap-Year-d( TODAY ), "високосный/не високосный":U )' + chr(10) +
                 '  "год."'                                                       + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                            + chr(10)
      .
    end.
    when 'Sparse'
    then do:
      assign
        p-help = 'Возвращает "разреженную" строку (буквы через пробел) для заголовков.' + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                       + chr(10) +
                 "Sparse RETURNS CHARACTER ( INPUT CHARACTER ) ."                       + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                              + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Sparse"                                           + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + chr(10) + chr(10) +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO INITIAL "":U .'           + chr(10) +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO INITIAL "":U .'           + chr(10) + chr(10) +
                 'ASSIGN'                                                               + chr(10) +
                 '  c-str1 = "отчет о состоянии запаса и продажах (оборотная ведомость)"'             + chr(10) +
                 '  c-str2 = Sparse( c-str1 )'                                          + chr(10) +
                 '.'                                                                    + chr(10) +
                 'MESSAGE'                                                              + chr(10) +
                 '  ~'"~' + c-str1 + ~'"~' LENGTH( c-str1 ) SKIP( 1 )'                  + chr(10) +
                 '  ~'"~' + c-str2 + ~'"~' LENGTH( c-str2 ) SKIP( 0 )'                  + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                  + chr(10)
      .
    end.
    when 'SparseSymbol'
    then do:
      assign
        p-help = 'Возвращает "разреженную" строку (буквы через символ).'                + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                       + chr(10) +
                 "SparseSymbol RETURNS CHARACTER ( INPUT i-string AS CHARACTER"         + chr(10) +
                 "                               , INPUT i-symbol AS CHARACTER"         + chr(10) +
                 "                               ) ."                                   + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                              + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l SparseSymbol"                                     + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + chr(10) + chr(10) +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO INITIAL "":U .'           + chr(10) +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO INITIAL "":U .'           + chr(10) + chr(10) +
                 'ASSIGN'                                                               + chr(10) +
                 '  c-str1 = "отчет о состоянии запаса и продажах (оборотная ведомость)"'             + chr(10) +
                 '  c-str2 = SparseSymbol( c-str1, "_" )'                               + chr(10) +
                 '.'                                                                    + chr(10) +
                 'MESSAGE'                                                              + chr(10) +
                 '  ~'"~' + c-str1 + ~'"~' LENGTH( c-str1 ) SKIP( 1 )'                  + chr(10) +
                 '  ~'"~' + c-str2 + ~'"~' LENGTH( c-str2 ) SKIP( 0 )'                  + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                  + chr(10)
      .
    end.
    when 'Compress'
    then do:
      assign
        p-help = 'Возвращает "спрессованную" строку (без лишних пробелов, обратная к функции Sparce).' + chr(10) +
                                                                                                         chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                        + chr(10) +
                 "Compress RETURNS CHARACTER ( INPUT CHARACTER ) ."                      + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                               + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Sparse,Compress"                                   + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                        + chr(10) + chr(10) +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO INITIAL "":U .'            + chr(10) +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO INITIAL "":U .'            + chr(10) +
                 'DEFINE VARIABLE c-str3 AS CHARACTER NO-UNDO INITIAL "":U .'            + chr(10) + chr(10) +
                 'ASSIGN'                                                                + chr(10) +
                 '  c-str1 = "отчет о состоянии запаса и продажах (оборотная ведомость)"'              + chr(10) +
                 '  c-str2 = Sparse(   c-str1 )'                                         + chr(10) +
                 '  c-str3 = Compress( c-str2 )'                                         + chr(10) +
                 '.'                                                                     + chr(10) +
                 'MESSAGE'                                                               + chr(10) +
                 '  ~'"~' +     c-str1   + ~'"~' LENGTH( c-str1 ) SKIP( 0 )'             + chr(10) +
                 '  ~'"~' +     c-str2   + ~'"~' LENGTH( c-str2 ) SKIP( 1 )'             + chr(10) +
                 '  ~'"~' + LC( c-str3 ) + ~'"~' LENGTH( c-str3 ) SKIP( 0 )'             + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                   + chr(10)
      .
    end.
    when 'CompressSymbol'
    then do:
      assign
        p-help = 'Возвращает "спрессованную" строку (без лишних символов, '             +
                 'обратная к функции SparceSymbol).'                                    + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                       + chr(10) +
                 "CompressSymbol RETURNS CHARACTER ( INPUT i-string AS CHARACTER"       + chr(10) +
                 "                                 , INPUT i-symbol AS CHARACTER"       + chr(10) +
                 "                                 ) ."                                 + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                              + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l SparseSymbol,CompressSymbol"                      + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + chr(10) + chr(10) +
                 'DEFINE VARIABLE c-symb AS CHARACTER NO-UNDO INITIAL "_":U .'          + chr(10) +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO INITIAL "":U .'           + chr(10) +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO INITIAL "":U .'           + chr(10) +
                 'DEFINE VARIABLE c-str3 AS CHARACTER NO-UNDO INITIAL "":U .'           + chr(10) +
                 'DEFINE VARIABLE c-str4 AS CHARACTER NO-UNDO INITIAL "":U .'           + chr(10) + chr(10) +
                 'ASSIGN'                                                               + chr(10) +
                 '  c-str1 = "отчет о состоянии запаса и продажах (оборотная ведомость)"'             + chr(10) +
                 '  c-str2 = SparseSymbol(   c-str1, c-symb        )'                   + chr(10) +
                 '  c-str3 = CompressSymbol( c-str2, c-symb        )'                   + chr(10) +
                 '  c-str4 = REPLACE(        c-str3, c-symb, " ":U )'                   + chr(10) +
                 '.'                                                                    + chr(10) +
                 'MESSAGE'                                                              + chr(10) +
                 '  ~'"~' +     c-str1   + ~'"~' LENGTH( c-str1 ) SKIP( 0 )'            + chr(10) +
                 '  ~'"~' +     c-str2   + ~'"~' LENGTH( c-str2 ) SKIP( 1 )'            + chr(10) +
                 '  ~'"~' + LC( c-str3 ) + ~'"~' LENGTH( c-str3 ) SKIP( 0 )'            + chr(10) +
                 '  ~'"~' + LC( c-str4 ) + ~'"~' LENGTH( c-str4 ) SKIP( 0 )'            + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                  + chr(10)
      .
    end.
    when 'MonthNameRusCase'
    then do:
      assign
        p-help = "Возвращает название месяца по-русски в падеже, заданном номером:" + chr(10) +
                 "  1 - именительный;"                                              + chr(10) +
                 "  2 - родительный;"                                               + chr(10) +
                 "  3 - дательный;"                                                 + chr(10) +
                 "  4 - винительный;"                                               + chr(10) +
                 "  5 - творительный;"                                              + chr(10) +
                 "  6 - предложный."                                                + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                   + chr(10) +
                 "MonthNameCaseRus RETURNS CHARACTER ( INPUT Month AS INTEGER"      + chr(10) +
                 "                                   , INPUT Case  AS INTEGER"      + chr(10) +
                 "                                   ) ."                           + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                          + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l MonthNameRusCase"                             + chr(10) + chr(10) +
                 "~{ cmp/str-glbl.i        ~}"                                      + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                   + chr(10) + chr(10) +
                 "DEFINE VARIABLE jCase      AS INTEGER   NO-UNDO ."                + chr(10) +
                 "DEFINE VARIABLE curr-month AS INTEGER   NO-UNDO ."                + chr(10) +
                 "DEFINE VARIABLE word-month AS CHARACTER NO-UNDO EXTENT 6 ."       + chr(10) +
                 "DEFINE VARIABLE l_log      AS LOGICAL   NO-UNDO INITIAL YES ."    + chr(10) + chr(10) +
                 "DO curr-month = 1 TO 12 :"                                                      + chr(10) +
                 "  DO jCase = 1 TO EXTENT( word-month ) :"                                       + chr(10) +
                 "    ASSIGN"                                                                     + chr(10) +
                 "      word-month[ jCase ] = MonthNameRusCase( curr-month, jCase )"              + chr(10) +
                 "    ."                                                                          + chr(10) +
                 "  END. /* jCase */"                                                             + chr(10) +
                 '  MESSAGE'                                                                      + chr(10) +
                 '    "Месяц:" curr-month                             SKIP( 1 )'                  + chr(10) +
                 '    "1) именительный:" ~{~&tabulation~} word-month[ 1 ] SKIP( 0 )'              + chr(10) +
                 '    "2) родительный:"  ~{~&tabulation~} word-month[ 2 ] SKIP( 0 )'              + chr(10) +
                 '    "3) дательный:"    ~{~&tabulation~} word-month[ 3 ] SKIP( 0 )'              + chr(10) +
                 '    "4) винительный:"  ~{~&tabulation~} word-month[ 4 ] SKIP( 0 )'              + chr(10) +
                 '    "5) творительный:" ~{~&tabulation~} word-month[ 5 ] SKIP( 0 )'              + chr(10) +
                 '    "6) предложный:"   ~{~&tabulation~} word-month[ 6 ] SKIP( 1 )'              + chr(10) +
                 '  VIEW-AS ALERT-BOX BUTTONS OK-CANCEL UPDATE l_log .'                           + chr(10) +
                 '  IF l_log <> YES'                                                              + chr(10) +
                 '  THEN DO:'                                                                     + chr(10) +
                 '    LEAVE .'                                                                    + chr(10) +
                 '  END.'                                                                         + chr(10) +
                 "END. /* curr-month */"                                                          + chr(10)
      .
    end.
    when 'Centering'
    then do:
      assign
        p-help = 'Возвращает отцентрированную строку.'                              + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                   + chr(10) +
                 "Centering RETURNS CHARACTER ( INPUT InString AS CHARACTER,"       + chr(10) +
                 "                              INPUT Lenght   AS INTEGER ) ."      + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                          + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Centering"                                    + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                   + chr(10) + chr(10) +
                 'DEFINE VARIABLE c-str1   AS CHARACTER NO-UNDO .'                  + chr(10) +
                 'DEFINE VARIABLE c-str2   AS CHARACTER NO-UNDO .'                  + chr(10) +
                 'DEFINE VARIABLE c-str3   AS CHARACTER NO-UNDO .'                  + chr(10) +
                 'DEFINE VARIABLE j-length AS INTEGER   NO-UNDO .'                  + chr(10) + chr(10) +
                 'ASSIGN'                                                           + chr(10) +
                 '  c-str1   = "отцентрированная строка"'                           + chr(10) +
                 '  j-length = LENGTH( c-str1 )'                                    + chr(10) +
                 '  c-str2   = Centering( c-str1, j-length + 5 )'                   + chr(10) +
                 '  c-str3   = Centering( c-str1, j-length + 6 )'                   + chr(10) +
                 '.'                                                                + chr(10) +
                 'MESSAGE'                                                          + chr(10) +
                 '  ~'"~' + c-str1 + ~'"~' LENGTH( c-str1 ) SKIP( 0 )'              + chr(10) +
                 '  ~'"~' + c-str2 + ~'"~' LENGTH( c-str2 ) "  L:" INDEX( c-str2, c-str1 ) - 1'   + chr(10) +
                 '  "R:" LENGTH( c-str2 ) - ( j-length + INDEX( c-str2, c-str1 ) ) + 1 SKIP( 0 )' + chr(10) +
                 '  ~'"~' + c-str3 + ~'"~' LENGTH( c-str3 )  " L:" INDEX( c-str3, c-str1 ) - 1'   + chr(10) +
                 '  "R:" LENGTH( c-str3 ) - ( j-length + INDEX( c-str3, c-str1 ) ) + 1 SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                            + chr(10)
      .
    end.
    when 'CenteringSymbol'
    then do:
      assign
        p-help = 'Возвращает отцентрированную заданным символом строку.'                + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                       + chr(10) +
                 "CenteringSymbol RETURNS CHARACTER ( INPUT InString AS CHARACTER,"     + chr(10) +
                 "                                    INPUT Symbol   AS CHARACTER,"     + chr(10) +
                 "                                    INPUT Lenght   AS INTEGER ) ."    + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                              + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Centering,CenteringSymbol"                        + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                       + chr(10) + chr(10) +
                 'DEFINE VARIABLE c-str1   AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE c-str2   AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE c-str3   AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE j-length AS INTEGER   NO-UNDO .'                      + chr(10) + chr(10) +
                 'ASSIGN'                                                               + chr(10) +
                 '  c-str1   = "отцентрированная строка"'                               + chr(10) +
                 '  j-length = LENGTH( c-str1 )'                                        + chr(10) +
                 '  c-str2   = CenteringSymbol( '                                       +
                              'Centering( c-str1, j-length + 5 ), "*", j-length + 10 )' + chr(10) +
                 '  c-str3   = CenteringSymbol( '                                       +
                              'Centering( c-str1, j-length + 6 ), "*", j-length + 12 )' + chr(10) +
                 '.'                                                                    + chr(10) +
                 'MESSAGE'                                                              + chr(10) +
                 '  ~'"~' + c-str1 + ~'"~' LENGTH( c-str1 ) SKIP( 0 )'                  + chr(10) +
                 '  ~'"~' + c-str2 + ~'"~' LENGTH( c-str2 ) "  L:" INDEX( c-str2, c-str1 ) - 1'       + chr(10) +
                 '  "R:" LENGTH( c-str2 ) - ( j-length + INDEX( c-str2, c-str1 ) ) + 1 SKIP( 0 )'     + chr(10) +
                 '  ~'"~' + c-str3 + ~'"~' LENGTH( c-str3 )  " L:" INDEX( c-str3, c-str1 ) - 1'       + chr(10) +
                 '  "R:" LENGTH( c-str3 ) - ( j-length + INDEX( c-str3, c-str1 ) ) + 1 SKIP( 0 )'     + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                                + chr(10)
      .
    end.
    when 'ShiftRight'
    then do:
      assign
        p-help = 'Возвращает отцентрированную строку.'                         + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                              + chr(10) +
                 "ShiftRight RETURNS CHARACTER ( INPUT InString AS CHARACTER"  + chr(10) +
                 "                             , INPUT Lenght   AS INTEGER"    + chr(10) +
                 "                             ) ."                            + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                     + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l ShiftRight"                              + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                              + chr(10) + chr(10) +
                 'DEFINE VARIABLE c-str0   AS CHARACTER NO-UNDO .'             + chr(10) +
                 'DEFINE VARIABLE c-str1   AS CHARACTER NO-UNDO .'             + chr(10) +
                 'DEFINE VARIABLE c-str2   AS CHARACTER NO-UNDO .'             + chr(10) +
                 'DEFINE VARIABLE c-str3   AS CHARACTER NO-UNDO .'             + chr(10) +
                 'DEFINE VARIABLE j-length AS INTEGER   NO-UNDO .'             + chr(10) + chr(10) +
                 'ASSIGN'                                                      + chr(10) +
                 '  c-str1   = "сдвинуть вправо"'                              + chr(10) +
                 '  j-length = LENGTH( c-str1 )'                               + chr(10) +
                 '  c-str2   = ShiftRight( c-str1, j-length + j-length     )'  + chr(10) +
                 '  c-str3   = ShiftRight( c-str1, j-length + j-length + 1 )'  + chr(10) +
                 '  c-str0   = ShiftRight( c-str1, 10                      )'  + chr(10) +
                 '.'                                                           + chr(10) +
                 'MESSAGE'                                                     + chr(10) +
                 '  ~'"~' + c-str1 + ~'"~'      LENGTH( c-str1 ) '             +
                   '                            SKIP( 0 )'                     + chr(10) +
                 '  ~'"~' + c-str2 + ~'"~' "  " LENGTH( c-str2 ) '             +
                   'INDEX( c-str2, c-str1 ) - 1 SKIP( 0 )'                     + chr(10) +
                 '  ~'"~' + c-str3 + ~'"~' " "  LENGTH( c-str3 ) '             +
                   'INDEX( c-str3, c-str1 ) - 1 SKIP( 0 )'                     + chr(10) +
                 '  ~'"~' + c-str0 + ~'"~'      LENGTH( c-str0 ) '             +
                   '                            SKIP( 0 )'                     + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                         + chr(10)
      .
    end.
    when 'ShiftRightSymbol'
    then do:
      assign
        p-help = 'Возвращает отцентрированную строку.'                               + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                    + chr(10) +
                 "ShiftRightSymbol RETURNS CHARACTER ( INPUT InString AS CHARACTER"  + chr(10) +
                 "                                   , INPUT Symbol   AS CHARACTER"  + chr(10) +
                 "                                   , INPUT Lenght   AS INTEGER"    + chr(10) + chr(10) +
                 "                                   ) ."                            + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                           + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l ShiftRightSymbol"                              + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                    + chr(10) + chr(10) +
                 'DEFINE VARIABLE c-str1   AS CHARACTER NO-UNDO .'                   + chr(10) +
                 'DEFINE VARIABLE c-str2   AS CHARACTER NO-UNDO .'                   + chr(10) +
                 'DEFINE VARIABLE c-str3   AS CHARACTER NO-UNDO .'                   + chr(10) +
                 'DEFINE VARIABLE j-length AS INTEGER   NO-UNDO .'                   + chr(10) + chr(10) +
                 'ASSIGN'                                                            + chr(10) +
                 '  c-str1   = "сдвинуть вправо"'                                    + chr(10) +
                 '  j-length = LENGTH( c-str1 )'                                     + chr(10) +
                 '  c-str2   = ShiftRightSymbol( c-str1, "*", j-length + j-length     )'           + chr(10) +
                 '  c-str3   = ShiftRightSymbol( c-str1, "*", j-length + j-length + 1 )'           + chr(10) +
                 '.'                                                                 + chr(10) +
                 'MESSAGE'                                                           + chr(10) +
                 '  ~'"~' + c-str1 + ~'"~'      LENGTH( c-str1 ) '                   +
                   '                            SKIP( 0 )'                           + chr(10) +
                 '  ~'"~' + c-str2 + ~'"~' "  " LENGTH( c-str2 ) '                   +
                   'INDEX( c-str2, c-str1 ) - 1 SKIP( 0 )'                           + chr(10) +
                 '  ~'"~' + c-str3 + ~'"~' " "  LENGTH( c-str3 ) '                   +
                   'INDEX( c-str3, c-str1 ) - 1 SKIP( 0 )'                           + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                               + chr(10)
      .
    end.
    when 'Digital'
    then do:
      assign
        p-help = 'Возвращает, состоит ли строка только из цифр и десятичной точки.'   + chr(10) + chr(10) +
                 "ФОРМАТ ВЫЗОВА:"                                                     + chr(10) +
                 "Digital RETURNS LOGICAL ( INPUT CHARACTER ) ."                      + chr(10) + chr(10) +
                 "ПРИМЕР:"                                                            + chr(10) + chr(10) +
                 '/* **************************************************** *\' + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Файл: stdfnhlp.p                                     *'  + chr(10) +
                 ' * Функция: ' + p-name + fill( ' ':U, 44 - length( p-name ) )             +
                                                                         '*'  + chr(10) +
                 ' * Автор: Булгаков Андрей Николаевич                    *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 ' * Описание стандартных функций из std-func.i (помощь). *'  + chr(10) +
                 ' *                                                      *'  + chr(10) +
                 '\* **************************************************** */' + chr(10) + chr(10) +
                 "~&SCOPED-DEFINE f-l Digital"                                        + chr(10) + chr(10) +
                 "~{ gbl/std-func.i ~{~&f-l~} ~}"                                     + chr(10) + chr(10) +
                 'DEFINE VARIABLE c-str1 AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE c-str2 AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE c-str3 AS CHARACTER NO-UNDO .'                      + chr(10) +
                 'DEFINE VARIABLE c-str4 AS CHARACTER NO-UNDO .'                      + chr(10) + chr(10) +
                 'ASSIGN'                                                             + chr(10) +
                 '  c-str1 = "-123456789.0"'                                          + chr(10) +
                 '  c-str2 = "+123456789.0"'                                          + chr(10) +
                 '  c-str3 = "0.987654321"'                                           + chr(10) +
                 '  c-str4 = "1234567890-0987654321"'                                 + chr(10) +
                 '.'                                                                  + chr(10) +
                 'MESSAGE'                                                            + chr(10) +
                 '  ~'"~' + c-str1 + ~'"~''                                           +
                  ' STRING( Digital( c-str1 ), "ЧИСЛО/СТРОКА":U )'                    + chr(10) +
                 '  ( IF Digital( c-str1 ) THEN INTEGER( c-str1 ) ELSE ? ) SKIP( 0 )' + chr(10) +
                 '  ~'"~' + c-str2 + ~'"~''                                           +
                  ' STRING( Digital( c-str2 ), "ЧИСЛО/СТРОКА":U )'                    + chr(10) +
                 '  ( IF Digital( c-str2 ) THEN INTEGER( c-str2 ) ELSE ? ) SKIP( 0 )' + chr(10) +
                 '  ~'"~' + c-str3 + ~'"~''                                           +
                  ' STRING( Digital( c-str3 ), "ЧИСЛО/СТРОКА":U )'                    + chr(10) +
                 '  ( IF Digital( c-str3 ) THEN INTEGER( c-str3 ) ELSE ? ) SKIP( 0 )' + chr(10) +
                 '  ~'"~' + c-str4 + ~'"~''                                           +
                  ' STRING( Digital( c-str4 ), "ЧИСЛО/СТРОКА":U )'                    + chr(10) +
                 '  ( IF Digital( c-str4 ) THEN INTEGER( c-str4 ) ELSE ? ) SKIP( 0 )' + chr(10) +
                 'VIEW-AS ALERT-BOX .'                                                + chr(10)
      .
    end.
    when '':U or
    when ?
    then do:
      assign
        p-help = 'Не задано имя функции.'
      .
    end.
    otherwise do:
      assign
        p-help = substitute( 'Описание функции "&1" пока отсутствует.'
                           , p-name
                           )
      .
    end.
  end case.
end procedure.
