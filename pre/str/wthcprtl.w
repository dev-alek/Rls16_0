DEFINE TEMP-TABLE tt-c-wth-parts NO-UNDO LIKE c-wth-parts.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as CHARACTER no-undo.
define input PARAMETER p-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог просмотра истории партии серийных МЦ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEF BUFFER LOCKED_wealth FOR wealth.
DEF BUFFER b-wealth FOR wealth.
DEF BUFFER b-goods FOR goods.
DEF BUFFER LOCKED_wth-ser FOR wth-ser.
DEF BUFFER locked_wth-par FOR wth-par.
DEF BUFFER locked_c-wth-parts FOR c-wth-parts.
DEF BUFFER b-wth-par FOR wth-par.
DEF BUFFER buf_wth-gds FOR wth-gds.
DEF BUFFER buf_wth-doc FOR wth-doc.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "        Диапазон (факт)"
      VIEW-AS TEXT
     SIZE 31 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "     Диапазон (документ)"
      VIEW-AS TEXT
     SIZE 31.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "       Срок годности"
      VIEW-AS TEXT
     SIZE 30.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "           Цена"
      VIEW-AS TEXT
     SIZE 31.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "              Серия"
      VIEW-AS TEXT
     SIZE 30.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE fl-artic AS CHARACTER FORMAT "X(16)":U INITIAL "0"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-maska AS CHARACTER FORMAT "X(256)":U
     LABEL "Маска"
     VIEW-AS FILL-IN
     SIZE 19.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-par-rate AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Коэффициент"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-par-val AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Номинал"
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-ProdCode AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-prodType AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-wth-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название МЦ"
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY 5.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.5 BY 5.25.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 65 BY 5.25.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.5 BY 4.75.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.5 BY 4.75.
DEFINE QUERY Dialog-Frame FOR
      tt-c-wth-parts,
      parts SCROLLING.
DEFINE FRAME Dialog-Frame
     tt-c-wth-parts.VAT-pc AT ROW 16 COL 48.5 COLON-ALIGNED WIDGET-ID 1118
          LABEL "НДС" FORMAT ">9.9<%"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     b-quit AT ROW 1 COL 1.5 WIDGET-ID 8
     B-Help AT ROW 1 COL 81 WIDGET-ID 4
     fl-artic AT ROW 2.5 COL 18 COLON-ALIGNED WIDGET-ID 46
     fl-gds AT ROW 2.5 COL 52.5 COLON-ALIGNED WIDGET-ID 58
     fl-prodType AT ROW 3.5 COL 18 COLON-ALIGNED WIDGET-ID 54
     fl-ProdCode AT ROW 3.5 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     fl-obj-name AT ROW 3.5 COL 52.5 COLON-ALIGNED WIDGET-ID 290
     tt-c-wth-parts.wth-code AT ROW 4.5 COL 18 COLON-ALIGNED WIDGET-ID 246
          LABEL "Код МЦ"
          VIEW-AS FILL-IN
          SIZE 10.5 BY 1
     fl-wth-name AT ROW 4.5 COL 52.5 COLON-ALIGNED WIDGET-ID 50
     tt-c-wth-parts.par-code AT ROW 5.5 COL 18 COLON-ALIGNED WIDGET-ID 218
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     fl-par-val AT ROW 5.5 COL 52.5 COLON-ALIGNED WIDGET-ID 52
     fl-par-rate AT ROW 5.5 COL 74 COLON-ALIGNED WIDGET-ID 250
     FILL-IN-2 AT ROW 7.75 COL 65.5 COLON-ALIGNED NO-LABEL WIDGET-ID 260
     FILL-IN-3 AT ROW 7.75 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 270
     tt-c-wth-parts.ser-code AT ROW 9 COL 11.5 COLON-ALIGNED WIDGET-ID 230
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-c-wth-parts.db-num AT ROW 10 COL 11.5 COLON-ALIGNED WIDGET-ID 176
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-c-wth-parts.fact-rangeFrom AT ROW 9 COL 76.5 COLON-ALIGNED WIDGET-ID 194
          LABEL "С"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-c-wth-parts.fact-rangeTo AT ROW 10 COL 76.5 COLON-ALIGNED WIDGET-ID 196
          LABEL "По"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-c-wth-parts.doc-rangeFrom AT ROW 9 COL 43 COLON-ALIGNED WIDGET-ID 262
          LABEL "C"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-c-wth-parts.doc-rangeTo AT ROW 10 COL 43 COLON-ALIGNED WIDGET-ID 264
          LABEL "По"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-c-wth-parts.fact-qnty AT ROW 11 COL 76.5 COLON-ALIGNED WIDGET-ID 266
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-c-wth-parts.qnty-doc AT ROW 11 COL 43 COLON-ALIGNED WIDGET-ID 224
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     fl-maska AT ROW 11 COL 11.5 COLON-ALIGNED WIDGET-ID 252
     FILL-IN-4 AT ROW 12.75 COL 2.5 NO-LABEL WIDGET-ID 278
     FILL-IN-5 AT ROW 12.75 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 286
     tt-c-wth-parts.beg-dt AT ROW 14 COL 11.5 COLON-ALIGNED WIDGET-ID 168
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-wth-parts.end-dt AT ROW 15 COL 11.5 COLON-ALIGNED WIDGET-ID 182
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-wth-parts.price-rubl AT ROW 14 COL 48.5 COLON-ALIGNED WIDGET-ID 222
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     FILL-IN-6 AT ROW 7.75 COL 2.5 NO-LABEL WIDGET-ID 1114
     tt-c-wth-parts.price-base AT ROW 15 COL 48.5 COLON-ALIGNED WIDGET-ID 1116
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     RECT-1 AT ROW 2.25 COL 1.5 WIDGET-ID 254
     RECT-2 AT ROW 7.25 COL 1.5 WIDGET-ID 256
     RECT-3 AT ROW 7.25 COL 34 WIDGET-ID 272
     RECT-4 AT ROW 12.5 COL 1.5 WIDGET-ID 280
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.
DEFINE FRAME Dialog-Frame
     RECT-5 AT ROW 12.5 COL 34 WIDGET-ID 288
     SPACE(31.87) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии Серийной материальной ценности" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON LEAVE OF tt-c-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame
DO:
    tt-c-wth-parts.qnty-doc:SCREEN-VALUE = string(int(tt-c-wth-parts.doc-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.doc-rangeFrom:SCREEN-VALUE) + 1).
    tt-c-wth-parts.fact-rangefrom:SCREEN-VALUE  = tt-c-wth-parts.doc-rangeFrom:SCREEN-VALUE.
    tt-c-wth-parts.fact-rangeto:SCREEN-VALUE  = tt-c-wth-parts.doc-rangeto:SCREEN-VALUE.
    tt-c-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-c-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.
ON RETURN OF tt-c-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.
END.
ON LEAVE OF tt-c-wth-parts.doc-rangeTo IN FRAME Dialog-Frame
DO:
    tt-c-wth-parts.qnty-doc:SCREEN-VALUE = string(int(tt-c-wth-parts.doc-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.doc-rangeFrom:SCREEN-VALUE) + 1).
    tt-c-wth-parts.fact-rangefrom:SCREEN-VALUE  = tt-c-wth-parts.doc-rangeFrom:SCREEN-VALUE.
    tt-c-wth-parts.fact-rangeto:SCREEN-VALUE  = tt-c-wth-parts.doc-rangeto:SCREEN-VALUE.
    tt-c-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-c-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.
ON RETURN OF tt-c-wth-parts.doc-rangeTo IN FRAME Dialog-Frame
DO:
  APPLY "tab":U TO SELF.
  RETURN NO-APPLY.
END.
ON LEAVE OF tt-c-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame
DO:
   tt-c-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-c-wth-parts.fact-rangeto:SCREEN-VALUE) -
   int(tt-c-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.
ON RETURN OF tt-c-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.
END.
ON LEAVE OF tt-c-wth-parts.fact-rangeTo IN FRAME Dialog-Frame
DO:
    tt-c-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-c-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-c-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.
ON RETURN OF tt-c-wth-parts.fact-rangeTo IN FRAME Dialog-Frame
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-c-wth-parts.beg-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of tt-c-wth-parts.beg-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of tt-c-wth-parts.beg-dt in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of tt-c-wth-parts.beg-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of tt-c-wth-parts.beg-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of tt-c-wth-parts.beg-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-description = 'Годен до &1 (для партии товара, включительно)'
    .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date5
    MENU-ITEM m-ed-date5-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date5-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date5-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date5-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if tt-c-wth-parts.beg-dt :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-c-wth-parts.beg-dt :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date5 :HANDLE
      tt-c-wth-parts.beg-dt :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle5 as handle no-undo .
  assign
    v-label-handle5 = tt-c-wth-parts.beg-dt :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle5)
  then do:
    if v-label-handle5 :tooltip = ""
    or v-label-handle5 :tooltip = ?
    then do:
      assign
        v-label-handle5 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date5-1 in menu m-ed-date5 DO:
    apply "ctrl-b":U to tt-c-wth-parts.beg-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date5-2 in menu m-ed-date5 DO:
    apply "ctrl-d":U to tt-c-wth-parts.beg-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date5-3 in menu m-ed-date5 DO:
    apply "ctrl-e":U to tt-c-wth-parts.beg-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date5-4 in menu m-ed-date5 DO:
    apply "ctrl-f":U to tt-c-wth-parts.beg-dt in frame Dialog-Frame .
  END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-c-wth-parts.end-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of tt-c-wth-parts.end-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of tt-c-wth-parts.end-dt in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of tt-c-wth-parts.end-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of tt-c-wth-parts.end-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of tt-c-wth-parts.end-dt in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-description = 'Годен до &1 (для партии товара, включительно)'
    .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date7
    MENU-ITEM m-ed-date7-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date7-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date7-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date7-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if tt-c-wth-parts.end-dt :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-c-wth-parts.end-dt :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date7 :HANDLE
      tt-c-wth-parts.end-dt :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle7 as handle no-undo .
  assign
    v-label-handle7 = tt-c-wth-parts.end-dt :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle7)
  then do:
    if v-label-handle7 :tooltip = ""
    or v-label-handle7 :tooltip = ?
    then do:
      assign
        v-label-handle7 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date7-1 in menu m-ed-date7 DO:
    apply "ctrl-b":U to tt-c-wth-parts.end-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-2 in menu m-ed-date7 DO:
    apply "ctrl-d":U to tt-c-wth-parts.end-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-3 in menu m-ed-date7 DO:
    apply "ctrl-e":U to tt-c-wth-parts.end-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-4 in menu m-ed-date7 DO:
    apply "ctrl-f":U to tt-c-wth-parts.end-dt in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF par-mode <>  'ПРОСМОТР':U THEN DO:
    MESSAGE
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.
  FIND FIRST LOCKED_c-wth-parts NO-LOCK WHERE
      recid(LOCKED_c-wth-parts) = p-rec
      NO-ERROR.
     IF NOT AVAILABLE LOCKED_c-wth-parts THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена партия с recid &1", p-rec)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
     END.
     FIND FIRST LOCKED_wealth NO-LOCK WHERE
                LOCKED_wealth.wth-code = LOCKED_c-wth-parts.wth-code NO-ERROR.
     IF NOT AVAILABLE LOCKED_wealth THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена МЦ с кодом &1 ",LOCKED_c-wth-parts.wth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
       FIND FIRST LOCKED_wth-par NO-LOCK WHERE
                LOCKED_wth-par.par-code = LOCKED_c-wth-parts.par-code
           AND  LOCKED_wth-par.wth-code = LOCKED_c-wth-parts.wth-code          NO-ERROR.
    IF NOT AVAILABLE LOCKED_wth-par THEN DO:
        MESSAGE
        SUBSTITUTE("Не найден номинал с кодом &1 для МЦ с кодом &2", LOCKED_c-wth-parts.par-code,  LOCKED_c-wth-parts.wth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
       FIND FIRST LOCKED_wth-ser NO-LOCK WHERE
                LOCKED_wth-ser.ser-code = LOCKED_c-wth-parts.ser-code
           AND  LOCKED_wth-ser.db-num = LOCKED_c-wth-parts.db-num          NO-ERROR.
    IF NOT AVAILABLE LOCKED_wth-ser THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена серия с кодом &1-&2", LOCKED_c-wth-parts.ser-code,  LOCKED_c-wth-parts.db-num)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    CREATE tt-c-wth-parts.
    BUFFER-COPY LOCKED_c-wth-parts TO tt-c-wth-parts.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  RUN disp-fl.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disp-fl :
DEF VAR v-cash-type-pay AS CHAR no-undo.
define variable p-plt-id AS INT no-undo.
define variable  p-plt-db-num   AS INT no-undo.
define variable  p-pdf-id  AS INT no-undo.
define variable  p-pdf-db-num AS INT no-undo.
define variable  p-sale-price-base AS DEC no-undo.
define variable  p-sale-price-rubl AS DEC no-undo.
define variable  p-road-tax-base AS DEC no-undo.
define variable  p-road-tax-rubl AS DEC no-undo.
define variable  p-excise-base AS DEC no-undo.
define variable  p-excise-rubl AS DEC no-undo.
define variable  p-fact-order  AS DEC no-undo.
DEF BUFFER b-cash-pay FOR ub.cash-pay.
DEF BUFFER b-clients FOR ub.clients.
    fill-in-6:SCREEN-VALUE IN FRAME Dialog-Frame = "            Серия".
    fill-in-2:SCREEN-VALUE IN FRAME Dialog-Frame = "         Диапазон (факт)".
    fill-in-3:SCREEN-VALUE IN FRAME Dialog-Frame = "        Диапазон (док)".
    fill-in-4:SCREEN-VALUE IN FRAME Dialog-Frame = "        Срок годности".
    fill-in-5:SCREEN-VALUE IN FRAME Dialog-Frame = "           Цена".
  IF AVAILABLE locked_c-wth-parts THEN DO WITH FRAME Dialog-Frame:
      FIND FIRST b-wealth WHERE b-wealth.wth-code = locked_c-wth-parts.wth-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wealth THEN DISP b-wealth.wth-name @ fl-wth-name.
      ELSE fl-wth-name:SCREEN-VALUE = '?':U.
      FIND FIRST b-wth-par WHERE b-wth-par.wth-code =  locked_c-wth-parts.wth-code AND b-wth-par.par-code = locked_c-wth-parts.par-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wth-par THEN DISP b-wth-par.par-val @ fl-par-val
                                       b-wth-par.par-rate @ fl-par-rate.
      ELSE do:
          fl-par-val:SCREEN-VALUE = '?':U.
          fl-par-rate:SCREEN-VALUE = '0':U.
      END.
      FIND FIRST b-goods WHERE b-goods.gds-code = locked_c-wth-parts.gds-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-goods THEN do:
                                DISP b-goods.artic     @ fl-artic
                                     b-goods.prod-type @ fl-prodType
                                     b-goods.prod-code @ fl-prodCode
                                     b-goods.gds-name  @ fl-gds.
        FIND FIRST b-clients WHERE b-clients.obj-type = b-goods.prod-type AND
             b-clients.obj-code = b-goods.prod-code NO-LOCK NO-ERROR.
        IF AVAILABLE b-clients THEN DISP b-clients.obj-name @ fl-obj-name.
      END.
      ELSE   ASSIGN fl-artic:SCREEN-VALUE = '?':U
             fl-prodType:SCREEN-VALUE = '?':U
             fl-prodCode:SCREEN-VALUE = '?':U
             fl-gds:SCREEN-VALUE = '?':U.
      find first locked_wth-ser exclusive-LOCK WHERE
              locked_wth-ser.ser-code = LOCKED_c-wth-parts.ser-code AND
              locked_wth-ser.db-num = locked_c-wth-parts.db-num NO-ERROR.
      if available locked_wth-ser THEN
          ASSIGN fl-maska:SCREEN-VALUE = LOCKED_wth-ser.maska.
  END.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-c-wth-parts SHARE-LOCK,       EACH parts WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY fl-artic fl-gds fl-prodType fl-ProdCode fl-obj-name fl-wth-name
          fl-par-val fl-par-rate FILL-IN-2 FILL-IN-3 fl-maska FILL-IN-4
          FILL-IN-5 FILL-IN-6
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-wth-parts THEN
    DISPLAY tt-c-wth-parts.VAT-pc tt-c-wth-parts.wth-code tt-c-wth-parts.par-code
          tt-c-wth-parts.ser-code tt-c-wth-parts.db-num tt-c-wth-parts.fact-rangeFrom
          tt-c-wth-parts.fact-rangeTo tt-c-wth-parts.doc-rangeFrom
          tt-c-wth-parts.doc-rangeTo tt-c-wth-parts.fact-qnty tt-c-wth-parts.qnty-doc
          tt-c-wth-parts.beg-dt tt-c-wth-parts.end-dt tt-c-wth-parts.price-rubl
          tt-c-wth-parts.price-base
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help fl-artic fl-gds fl-prodType fl-ProdCode fl-obj-name
         tt-c-wth-parts.wth-code fl-wth-name tt-c-wth-parts.par-code fl-par-val
         fl-par-rate tt-c-wth-parts.ser-code tt-c-wth-parts.db-num
         tt-c-wth-parts.fact-rangeFrom tt-c-wth-parts.fact-rangeTo
         tt-c-wth-parts.doc-rangeFrom tt-c-wth-parts.doc-rangeTo
         tt-c-wth-parts.fact-qnty tt-c-wth-parts.qnty-doc fl-maska
         tt-c-wth-parts.beg-dt tt-c-wth-parts.end-dt tt-c-wth-parts.price-rubl
         tt-c-wth-parts.price-base RECT-1 RECT-2 RECT-3 RECT-4 RECT-5
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
ENABLE
b-quit
B-Help
WITH FRAME Dialog-Frame.
DISPLAY
   tt-c-wth-parts.VAT-pc tt-c-wth-parts.wth-code tt-c-wth-parts.par-code tt-c-wth-parts.ser-code tt-c-wth-parts.db-num tt-c-wth-parts.fact-rangeFrom tt-c-wth-parts.fact-rangeTo tt-c-wth-parts.doc-rangeFrom tt-c-wth-parts.doc-rangeTo tt-c-wth-parts.fact-qnty tt-c-wth-parts.qnty-doc tt-c-wth-parts.beg-dt tt-c-wth-parts.end-dt tt-c-wth-parts.price-rubl tt-c-wth-parts.price-base
WITH FRAME Dialog-Frame  .
if tt-c-wth-parts.stts = 1 then do:
  tt-c-wth-parts.fact-rangeFrom:screen-value = '?'.
  tt-c-wth-parts.fact-rangeTo:screen-value = '?'.
  tt-c-wth-parts.fact-qnty:screen-value = '0'.
end.
IF par-mode = 'ПРОСМОТР':U THEN DO:
  ASSIGN
  b-quit:COLUMN = 1
  b-quit:LABEL = "&Выход".
END.
VIEW FRAME Dialog-Frame.
frame Dialog-Frame:title = substitute("&1 &2"
                                     ,frame Dialog-Frame:title
                                     ,par-mode
                                     ).
END PROCEDURE.
