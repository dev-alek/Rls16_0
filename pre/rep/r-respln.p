block-level on error undo, throw.
 def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
 def var vss-author      as character no-undo init "$Author: expertek $":U .
 def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
 def var vss-workfile    as character no-undo init "$Workfile: r-respln.p $":U .
 def var vss-archive     as character no-undo init "$Archive: rep/r-respln.p $":U .
 def var vss-description as character no-undo init " печатная форма  АРМ РЕСТОРАН   ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
 do
 on error undo, return error return-value
 :
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter v-doc-rec  as recid no-undo .
define    variable sort-name   as logical no-undo.
define    variable sort-gr     as logical no-undo.
define    variable print-graft as logical no-undo.
define    variable CostPrice   as logical no-undo .
define    variable PrintScale  as logical no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
  define variable summ as decimal no-undo .
  define variable sort-group as logical   no-undo .
  if sort-gr                  then assign sort-group = yes .
  else                             assign sort-group = no .
  DEFINE temp-table temp-str no-undo
    field   np                as integer
    field   grp-name          as  char
    field   gds-name          as  char
    field   b-code            as character
    field   norma             as decimal
    field   num-rcp           as char
    field   p-inp             as decimal
    field   qnty              as decimal
    field   price             as decimal
    field   stoim             as decimal
  .
  def stream Out-Stream.
  def buffer buf_clients for  clients .
  def buffer This_Object for  clients .
  def buffer buf_goods        for goods .
  define variable qnty as decimal   no-undo .
  define variable sum  as decimal   no-undo .
  define variable num-ln as integer   no-undo .
  def var FullNameGds as character no-undo .
  def var gds-str as char no-undo.
  def var gds-str1 as char no-undo.
  def var gds-str2 as char no-undo.
  def var i as int no-undo.
  def var j as int no-undo.
  define variable Counter1 as integer init 0  no-undo .
  def var LineBuf       as char    no-undo.
  def var Line       as char    no-undo.
  def var UndLine    as char    no-undo.
  def var     Lines_Counter as   int  init 0  no-undo.
  def var     Tmp_Counter   as   int  init 0  no-undo.
  def var     tdoc-date     like fbr-pln.doc-date no-undo.
  def var     tdoc-code     like fbr-pln.doc-code no-undo.
  def var  abbr              as  char no-undo.
  def var  pp                as  char no-undo.
  def var sym1 as char  init ":"   no-undo.
  def var sym2 as char  init ":"   no-undo.
  def var sym3 as char  init ":"   no-undo.
  def var sym4 as char  init ":"   no-undo.
  def var sym5 as char  init ":"   no-undo.
  def var sym6 as char  init ":"   no-undo.
  def var sym7 as char  init ":"   no-undo.
  def var sym8 as char  init ":"   no-undo.
  def var sym9 as char  init ":"   no-undo.
  def var sym10 as char init ":"   no-undo.
  define variable g#report-num    as integer      no-undo.
  define variable g#quest-print   as logical      no-undo.
  define variable g#log           as logical      no-undo.
  DEFINE FRAME plan-menu
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL " ! !N!п/п! ":C5 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL " !----------------------------------------!Наименование и краткая!характеристика! ":C40
                                                                                   format "X(40)" space(0)
        Sym3 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "  Блюдо и!---------!Код ! ! ":C9 format "X(9)" space(0)
        sym4 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.norma COLUMN-LABEL "гарнир!------!Норма! ! ":C6 format ">>>>>9.<<<" space(0)
        Sym5 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.num-rcp COLUMN-LABEL "!-----------!Номер блюд!по сборнику!рецептур":C11 format "x(11)" space(0)
        Sym6 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.p-inp COLUMN-LABEL "!----------!Выход!одного!блюда":C10 format "->>>>>>>9.<<<" space(0)
        Sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.qnty COLUMN-LABEL " ! !Количество! ! ":C13 format "->>>>>>>9.<<<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.Price COLUMN-LABEL " ! !Цена! ! ":C13 format "->>>>>9.99" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.stoim COLUMN-LABEL " ! !Сумма! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "План-меню N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp) AT 105 format "X(10)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) , ">>>>9") ) AT 116 format "X(13)" SKIP
        Line format "X(132)" AT 1
        with width 136 down stream-io use-text NO-BOX.
  run get-report-num in p-mainmenu-handle (
      output g#report-num
  ).
  run get-quest-print in p-mainmenu-handle (
      output g#quest-print
  ).
  FIND fbr-pln WHERE recid(fbr-pln) = v-doc-rec NO-LOCK .
  assign
    tdoc-date = (if fbr-pln.status_ <> 'факт':U then fbr-pln.doc-date else fbr-pln.fact-date)
    tdoc-code = fbr-pln.doc-code
  .
  if session:set-wait-state("compiler") then.
output STREAM Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
  define variable v-prn0 as character no-undo .
  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .
  IF var-report-r-b = "rubl" THEN Assign PP = "Цены руб.".
                       Else Assign PP = "Цены  баз.вал." .
  FIND This_Object  WHERE This_Object.obj-type = fbr-pln.obj-type AND This_Object.obj-code = fbr-pln.obj-code  NO-LOCK.
  FIND clients      WHERE clients.obj-type     = 'орг':U           AND clients.obj-code     = fbr-pln.host-code NO-LOCK.
  FORM with frame plan-menu .
  run PrintTitul in this-procedure .
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 25 ) = 0 then 100 else integer( 25 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
 run make-tt in this-procedure .
    if sort-group = yes then do:
      for each temp-str no-lock break by temp-str.grp-name by if sort-name then  temp-str.gds-name Else string(temp-str.np,"999999999") :
        if first-of( temp-str.grp-name) then run print-grp in this-procedure .
        run print-line in this-procedure .
        if last-of( temp-str.grp-name ) then  run print-grp-itog in this-procedure .
      end.
    end.
    else do:
      for each temp-str no-lock break by if sort-name then  temp-str.gds-name Else string(temp-str.np,"999999999") :
        run print-line in this-procedure .
      end.
    end.
  run on-same-page in this-procedure (input 5) .
  run print-all-itog in this-procedure .
  run PrintPodval in this-procedure .
  HIDE stream Out-Stream FRAME plan-menu .
  HIDE stream Out-Stream FRAME BottomFrame .
  HIDE stream Out-Stream FRAME BottomFrame2 .
  output stream Out-Stream CLOSE .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
procedure print-grp :
  do  on error undo, return error return-value  :
    DOWN stream Out-Stream 1 with FRAME plan-menu .
    PUT stream Out-Stream UNFORMATTED String("_______________" + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT "x(132)"  skip  .
  end.
end procedure.
procedure print-line :
  do on error undo, return error return-value :
  assign
     Lines_Counter = Lines_Counter + 1
     summ = summ  + temp-str.stoim
    .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if line-counter( Out-Stream ) < Tmp_Counter then
    assign
    .
  assign
    Tmp_Counter  = line-counter( Out-Stream )
    num-ln = num-ln + 1
  .
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END.
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.gds-name
    sym3     temp-str.b-code
    sym4     temp-str.qnty
    sym5     temp-str.stoim
    sym6     temp-str.price
    sym7     sym8 sym9 sym10
    temp-str.norma
    temp-str.num-rcp
    temp-str.p-inp
    with FRAME plan-menu.
    DOWN stream Out-Stream 1 with FRAME plan-menu.
  end.
end procedure.
procedure print-grp-itog :
  do on error undo, return error return-value :
  end.
end procedure.
procedure print-all-itog :
  underline stream Out-Stream
    sym1     Lines_Counter
    sym2     temp-str.gds-name
    sym3     temp-str.b-code
    sym4     temp-str.qnty
    sym5     temp-str.stoim
    sym6     temp-str.price
    sym7     sym8 sym9 sym10
    temp-str.norma
    temp-str.num-rcp
    temp-str.p-inp
    with FRAME plan-menu.
  DOWN stream Out-Stream 1 with FRAME plan-menu.
      PUT STREAM Out-Stream "Итого  " +   string(summ , "->>>,>>>,>>9.99") + ":" format "X(23)"  at 110 skip.
  underline stream Out-Stream
            sym9
            sym10
            temp-str.stoim
    with FRAME plan-menu.
  DOWN stream Out-Stream 1 with FRAME plan-menu.
end procedure.
procedure PrintTitul :
  do  on error undo, return error return-value  :
    case clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = clients.obj-code NO-LOCK .
            if available ub.firm
            then do:
                assign
                    t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
                    t-addres = t-addres
                        + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
                            then ""
                            else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) )
                          )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                        + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( ", " + trim( ub.firm.addres2 ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-phone = ub.firm.phone
                    t-inn   = ub.firm.inn
                    t-okpo  = ub.firm.okpo
                .
            end.
       end.
       when 'маг':U
       then do:
            FIND ub.shop WHERE ub.shop.obj-code = clients.obj-code NO-LOCK .
            if available ub.shop
            then do:
                assign
                    t-addres = ( if trim( shop.addres1 ) <> "" then ( trim( shop.addres1 ) ) else "" )
                            + ( if trim( shop.addres2 ) <> "" then ( ", " + trim( shop.addres2 ) ) else "" )
                    t-phone = shop.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'скл':U
       then do:
            FIND ub.store WHERE ub.store.obj-code = clients.obj-code NO-LOCK .
            if available ub.store
            then do:
                assign
                    t-addres = ( if trim( ub.store.addres1 ) <> "" then ( trim( ub.store.addres1 ) ) else "" )
                            + ( if trim( ub.store.addres2 ) <> "" then ( ", " + trim( ub.store.addres2 ) ) else "" )
                    t-phone = ub.store.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'чел':U
       then do:
            find ub.person where ub.person.psn-code = clients.obj-code no-lock .
            if available ub.person
            then do:
                assign
                    t-addres = ( if ub.person.ind <> 0 and ub.person.ind <> ? then string( ub.person.ind ) else "" )
                                + ( if  ub.person.city <> ? and trim(ub.person.city) <> "" then ( ", " + trim( ub.person.city ) ) else "" )
                                + ( if  ub.person.address <> ? and trim(ub.person.address) <> "" then ( ", " + trim( ub.person.address ) ) else "" )
                    t-phone = ub.person.phone1
                    t-inn = ub.person.inn
                    t-okpo = ub.person.okpo
                .
            end.
       end.
    end case.
      PUT STREAM Out-Stream
        space(5) "Унифицированная форма № ОП-2"  AT 5
        space(5) Line format  "X(19)" AT 117 skip
        space(5) "| "                 AT 117 'код':U AT 125 "|" AT 135 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 103 "| " AT 117 "0330502" "|" AT 135 skip
        space(5) string( "ИНН " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                              + t-addres + t-phone) format "X(60)"
            "по ОКПО" format "X(7)"  AT 109
                                "| " AT 117
          t-okpo format "X(16)" "|"  AT 135 skip
        space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "X(60)"
        "| " AT 117  "|" AT 135 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 92 "| " AT 117 "|" AT 135 skip
                       "Вид операции" format "X(12)" AT 102       "| " AT 117 "|" AT 135 skip
                                                                  "| " AT 117 "|" AT 135 skip
        space(5)  Line format  "X(19)" AT 117 skip
        space(87) "УТВЕРЖДАЮ" format "X(9)"               AT 87  skip
        space(87) "______________________" format "X(20)" AT 87  skip
        space(87) "______________________" format "X(20)" AT 87 "/___________________/" AT 109 SKIP
        space(87) "подпись"                               AT 87 "расшифровка подписи"   AT 109 SKIP
        space(65) Line format "X(50)" skip
        space(54) string( "ПЛАН-МЕНЮ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if fbr-pln.status_ <> 'факт':U then string( "(" + CAPS(fbr-pln.status_) + ")" ) else "")
                                    ) format "X(60)" skip
         space(65) Line format "X(50)" skip .
      .
  end.
end procedure.
procedure PrintPodval :
  do on error undo, return error return-value  :
  PUT  STREAM Out-Stream " "   skip
LineBuf format "X(25)" AT 10 LineBuf format "X(25)"   AT 40 LineBuf format "X(50)"               AT 70 SKIP
"должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
"<<       >> _________________        г. "
      .
  end.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then  page stream Out-Stream .
end procedure.
procedure make-tt :
  do
  on error undo, return error return-value
  :
define buffer buf_fbr-pln-line for fbr-pln-line .
define buffer buf_recipe for recipe .
define buffer buf_goods  for goods .
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .
define variable v-bar-code like bar-code.b-code no-undo .
 for each  buf_fbr-pln-line no-lock where buf_fbr-pln-line.doc-code = fbr-pln.doc-code
                                    break by  buf_fbr-pln-line.line-num :
  find first buf_recipe  where buf_recipe.recipe-code = buf_fbr-pln-line.recipe-code  no-lock  .
  find first buf_goods   where buf_goods.gds-code = buf_fbr-pln-line.gds-code         no-lock  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_fbr-pln-line.obj-type
  ,input  buf_fbr-pln-line.obj-code
  ,input  v-bar-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
  define variable v-grp-fbr-name as character no-undo .
  find first fbr-gds-obj no-lock where
             fbr-gds-obj.gds-code = buf_goods.gds-code and
             fbr-gds-obj.obj-code = buf_fbr-pln-line.obj-code and
             fbr-gds-obj.obj-type = buf_fbr-pln-line.obj-type
             no-error .
  if error-status :error then v-grp-fbr-name = "Блюдо и гарнир" .
  find first fbr-gds-grp no-lock where fbr-gds-grp.node-code = fbr-gds-obj.fbr-grp-code and
                                       fbr-gds-grp.obj-code = fbr-gds-obj.obj-code     and
                                       fbr-gds-grp.obj-type = fbr-gds-obj.obj-type    no-error .
  if available fbr-gds-grp then v-grp-fbr-name = fbr-gds-grp.node-name .
  else do:
    v-grp-fbr-name = "Блюдо и гарнир" .
  end.
  create temp-str .
  assign
    temp-str.np         = buf_fbr-pln-line.line-num
    temp-str.grp-name   = v-grp-fbr-name
    temp-str.gds-name   = buf_goods.gds-name
    temp-str.b-code     = string(v-bar-code)
    temp-str.p-inp      = if buf_recipe.portion-qnty <> 0 and buf_recipe.portion-qnty <> ? then  buf_recipe.qnty / buf_recipe.portion-qnty else 0
    temp-str.norma      = temp-str.p-inp
    temp-str.num-rcp    = string(buf_recipe.recipe-ref-num)
    temp-str.qnty       = buf_fbr-pln-line.fact-qnty
    temp-str.price      = if v-cur-pr = ? then 0 else v-cur-pr
    temp-str.stoim      = temp-str.qnty  * temp-str.price
    .
  end.
  end.
 end procedure.
