DEFINE BUFFER buf_wealth FOR ub.wealth.
DEFINE BUFFER buf_wth-line FOR ub.wth-line.
DEFINE TEMP-TABLE tt-wth-line NO-UNDO LIKE ub.wth-line.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter par-mode as character no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter par-current-w-p-code like ub.wth-line.w-p-code no-undo.
define input parameter par-out-w-p-code like ub.wth-line.out-code no-undo.
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo .
define input-output parameter parline-rec as recid no-undo.
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам ()"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!()"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc
 .
DEFINE TEMP-TABLE tt-wth-parts NO-UNDO LIKE ub.wth-parts.
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Добавление, изменение, просмотр строки документа МЦ (не инвентаризация)":U.
define variable parext-doc-name as character no-undo.
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
define variable vardoc-code like ub.wth-doc.doc-code no-undo.
define variable lock-line as logical no-undo.
define variable locked-wth as logical no-undo .
define variable base-code         as integer   no-undo .
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_wth-dtl     for ub.wth-dtl.
DEF BUFFER b-wealth FOR ub.wealth.
DEF BUFFER b-goods FOR ub.goods.
DEF BUFFER buf_wth-gds FOR ub.wth-gds.
DEFINE BUTTON B-dtl
     LABEL "&Номиналы"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-next
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-prev
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-wealth
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE fl-artic AS CHARACTER FORMAT "X(16)":U INITIAL "0"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-curr-abbr LIKE ub.currency.curr-abbr
      VIEW-AS TEXT
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE fl-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FL-gds-code AS INTEGER FORMAT "999999999" INITIAL 0
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-prod-name AS CHARACTER FORMAT "X(40)"
     VIEW-AS FILL-IN
     SIZE 17.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-ProdCode AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-prodType AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE TEXT-1 AS CHARACTER FORMAT "x(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 90 BY 3.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 90 BY 2.75.
DEFINE VARIABLE T-dtl AS LOGICAL INITIAL no
     LABEL "Расшифровка суммы"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.
DEFINE QUERY QUERY-lines FOR
      buf_wth-line SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-dtl AT ROW 1 COL 21
     B-prev AT ROW 1 COL 58.5
     B-next AT ROW 1 COL 62.5
     B-Help AT ROW 1 COL 80
     tt-wth-line.wth-code AT ROW 3 COL 21.88 COLON-ALIGNED
          LABEL "Материальная ценность"
          VIEW-AS FILL-IN
          SIZE 15.13 BY 1
     B-wealth AT ROW 3 COL 39
     tt-wth-line.doc-sum AT ROW 4.5 COL 22 COLON-ALIGNED
          LABEL "Кол-во движения"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
          FGCOLOR 4
     tt-wth-line.fact-sum AT ROW 4.5 COL 52.5 COLON-ALIGNED
          LABEL "Кол-во факт"
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
          FGCOLOR 4
     T-dtl AT ROW 4.5 COL 72.5
     tt-wth-line.sum-gds-rubl AT ROW 7.25 COL 19.5 COLON-ALIGNED WIDGET-ID 264
          LABEL "Сумма по связ." FORMAT "->,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          FGCOLOR 4
     tt-wth-line.sum-gds-base AT ROW 7.25 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 262 FORMAT "->,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     fl-gds AT ROW 9 COL 19.5 COLON-ALIGNED WIDGET-ID 58
     FL-gds-code AT ROW 9 COL 42 COLON-ALIGNED WIDGET-ID 250
     fl-artic AT ROW 9 COL 66.5 COLON-ALIGNED WIDGET-ID 46
     fl-prodType AT ROW 10.25 COL 19.5 COLON-ALIGNED WIDGET-ID 54
     fl-ProdCode AT ROW 10.25 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     fl-prod-name AT ROW 10.25 COL 44 NO-LABEL WIDGET-ID 248
     ub.wealth.wth-name AT ROW 3 COL 42.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 28.5 BY 1
          FGCOLOR 4
     TEXT-1 AT ROW 6 COL 20 COLON-ALIGNED NO-LABEL WIDGET-ID 270
     fl-curr-abbr AT ROW 6 COL 42.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 256
          BGCOLOR 3 FGCOLOR 15
     RECT-1 AT ROW 8.5 COL 2 WIDGET-ID 266
     RECT-2 AT ROW 5.75 COL 2 WIDGET-ID 268
     SPACE(0.74) SKIP(3.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка документа движения МЦ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       fl-artic:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       fl-curr-abbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       fl-gds:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       FL-gds-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       fl-prod-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       fl-ProdCode:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       fl-prodType:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-wth-line.sum-gds-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-wth-line.sum-gds-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       TEXT-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-dtl IN FRAME Dialog-Frame
DO:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  tt-wth-line.doc-sum
  tt-wth-line.fact-sum
  tt-wth-line.wth-code
  .
  if ub.wth-doc.ext-doc-type = 'xc':U then do:
    run str/wth-dtle.w (
                   input parparentproc
                  ,INPUT p-curr-host-code
                  ,INPUT p-curr-obj-type
                  ,INPUT p-curr-obj-code
                  ,INPUT par-mode
                  ,INPUT parline-rec
                  ,INPUT tt-wth-line.doc-code
                  ,INPUT tt-wth-line.wth-code
                  ,INPUT tt-wth-line.w-p-code
                  ,INPUT tt-wth-line.doc-sum
                  ,INPUT tt-wth-line.fact-sum
                  ,INPUT tt-wth-line.bef-sum
                  ,INPUT tt-wth-line.aft-sum
                  ,INPUT ub.wth-doc.doc-type
                  ,INPUT ub.wth-doc.ext-doc-type
                  ,input-output table tt-par-dtl ) .
  end.
  else do:
  run str/wth-dtlc.w (
                   input parparentproc
                  ,INPUT p-curr-host-code
                  ,INPUT p-curr-obj-type
                  ,INPUT p-curr-obj-code
                  ,INPUT par-mode
                  ,INPUT parline-rec
                  ,INPUT tt-wth-line.doc-code
                  ,INPUT tt-wth-line.wth-code
                  ,INPUT tt-wth-line.w-p-code
                  ,INPUT tt-wth-line.doc-sum
                  ,INPUT tt-wth-line.fact-sum
                  ,INPUT tt-wth-line.bef-sum
                  ,INPUT tt-wth-line.aft-sum
                  ,INPUT ub.wth-doc.doc-type
                  ,INPUT ub.wth-doc.ext-doc-type
                  ,input-output table tt-par-dtl ) .
   end.
 if buf_wealth.is-ser = 1 and par-mode <> 'ПРОСМОТР':U then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
tt-wth-line.doc-sum   = 0
tt-wth-line.fact-sum  = 0
tt-wth-line.sum-gds-rubl = 0
tt-wth-line.sum-gds-base = 0
tt-wth-line.price-rubl   = 0
tt-wth-line.price-base   = 0.
for each tt-par-dtl no-lock where tt-par-dtl.w-p-code = tt-wth-line.w-p-code
                       and tt-par-dtl.wth-code = tt-wth-line.wth-code
                       and tt-par-dtl.doc-code = tt-wth-line.doc-code
                       :
  assign
  tt-wth-line.doc-sum      =  tt-wth-line.doc-sum  + tt-par-dtl.doc-sum
  tt-wth-line.fact-sum     =  tt-wth-line.fact-sum + tt-par-dtl.fact-sum
  tt-wth-line.sum-gds-rubl =  tt-wth-line.sum-gds-rubl + tt-par-dtl.sum-gds-rubl
  tt-wth-line.sum-gds-base =  tt-wth-line.sum-gds-base + tt-par-dtl.sum-gds-base
  .
end.
assign
  tt-wth-line.price-rubl  =  tt-wth-line.sum-gds-rubl / tt-wth-line.fact-sum
  tt-wth-line.price-base  =  tt-wth-line.sum-gds-base / tt-wth-line.fact-sum
  .
  display
   tt-wth-line.doc-sum
   tt-wth-line.fact-sum
   tt-wth-line.sum-gds-rubl
   tt-wth-line.sum-gds-base
  with frame Dialog-Frame.
 end.
  run control-dtl in this-procedure(output lock-line).
  run lock-proc in this-procedure(input lock-line).
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-save-line in this-procedure ( input no, input-output par-mode) No-ERROR.
  if error-status:error then return no-apply.
  APPLY "GO":U TO FRAME Dialog-Frame.
END.
ON CHOOSE OF B-next IN FRAME Dialog-Frame
DO:
  run proc-b-move in this-procedure ( input self:name) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-prev IN FRAME Dialog-Frame
DO:
  run proc-b-move in this-procedure ( input self:name) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-wealth IN FRAME Dialog-Frame
DO:
  define variable v_rid-list AS CHAR NO-UNDO.
  run ref/wth-ref.w (
                 input parparentproc
                ,input "b-sel":U
                ,input ub.wth-doc.host-code
                ,input ub.wth-doc.obj-type
                ,input ub.wth-doc.obj-code
                ,input (if lookup(ub.wth-doc.ext-doc-type,'ii,fj,jj,pj,oj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,xc':U) > 0 then "wth-ser":U  else if lookup(ub.wth-doc.ext-doc-type,'ij,ei,rj,ej,we,ci,ce,iy,de':u) > 0 then "wth-nser":U else 'все':U)
                ,input-OUTPUT v_rid-list ).
  if v_rid-list = "":u then return no-apply.
  FIND FIRSt buf_wealth NO-LOCK WHERE
             RECID( buf_wealth ) = INT( ENTRY( NUM-ENTRIES( v_rid-list ), v_rid-list ) ) NO-ERROR.
  IF AVAIL buf_wealth THEN DO:
    DISPLAY
    buf_wealth.wth-code @ tt-wth-line.wth-code
    buf_wealth.wth-name @ ub.wealth.wth-name
    WITH FRAME Dialog-Frame.
    for each tt-par-dtl:
      delete tt-par-dtl.
    end.
  END.
RUN DISP-fl IN THIS-PROCEDURE.
END.
ON LEAVE OF tt-wth-line.doc-sum IN FRAME Dialog-Frame
DO:
  tt-wth-line.fact-sum:SCREEN-VALUE = SELF:SCREEN-VALUE.
END.
ON LEAVE OF tt-wth-line.wth-code IN FRAME Dialog-Frame
DO:
  RUN disp-fl IN THIS-PROCEDURE.
END.
ON LEAVE OF wealth.wth-name IN FRAME Dialog-Frame
DO:
  RUN disp-fl IN THIS-PROCEDURE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if par-mode <> 'ИЗМЕНЕНИЕ':U and par-mode <> 'ДОБАВЛЕНИЕ':U and par-mode <> 'ПРОСМОТР':U then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode = 'ПРОСМОТР':U then do:
    FIND FIRST ub.wth-doc No-LOCK WHERE
               recid(ub.wth-doc) = pardoc-rec No-ERROR.
  end.
  else do:
    FIND FIRST ub.wth-doc EXCLUSIVE-LOCK WHERE
               recid(ub.wth-doc) = pardoc-rec No-ERROR.
  end.
  IF NOT avail ub.wth-doc then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден документ движения МЦ"
    view-as alert-box.
    return error.
  end.
  vardoc-code = ub.wth-doc.doc-code.
  OPEN QUERY QUERY-lines
  FOR EACH buf_wth-line WHERE
           buf_wth-line.doc-code = vardoc-code NO-LOCK INDEXED-REPOSITION.
  if par-mode <> 'ДОБАВЛЕНИЕ':U then do:
    if par-mode = 'ПРОСМОТР':U then do:
      get first QUERY-lines.
      repeat while parline-rec <> recid(buf_wth-line):
        get next QUERY-lines.
      end.
    end.
    else do:
      get first QUERY-lines exclusive-lock.
      repeat while parline-rec <> recid(buf_wth-line):
        get next QUERY-lines exclusive-lock.
      end.
    end.
    IF error-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена строка по документу движения МЦ"
      view-as alert-box.
      return error.
    end.
  end.
  run fill-tables in this-procedure.
  RUN Myenable in this-procedure.
  RUN disp-fl IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE control-dtl :
define output parameter lock-line as logical no-undo.
if not avail tt-wth-line then return error.
if par-mode = 'ДОБАВЛЕНИЕ':U or can-find(first tt-par-dtl) then dO:
  if not available buf_wealth then  t-dtl:screen-value in frame Dialog-Frame =  "no".
  else if buf_wealth.is-ser = 0 then do:
    find first tt-par-dtl NO-LOCK  where tt-par-dtl.doc-sum > 0  No-ERROR .
    t-dtl:screen-value in frame Dialog-Frame = (if available tt-par-dtl then "yes" else "no").
  end.
  else do:
    t-dtl:screen-value in frame Dialog-Frame = if can-find(first buf_wth-parts
                                                            where buf_wth-parts.wth-code = tt-wth-line.wth-code and
                                                                  buf_wth-parts.w-p-code = tt-wth-line.w-p-code  and
                                                                  buf_wth-parts.out-code = tt-wth-line.doc-code
                                                             ) then   "yes" else "no".
  end.
end.
else do:
       find first ub.wth-dtl No-LOCK  where
                    ub.wth-dtl.doc-code = tt-wth-line.doc-code AND
                    ub.wth-dtl.wth-code = tt-wth-line.wth-code AND
                    ub.wth-dtl.w-p-code = tt-wth-line.w-p-code No-ERROR .
     t-dtl:screen-value in frame Dialog-Frame = (if available wth-dtl then "yes" else "no").
end.
if t-dtl:screen-value in frame Dialog-Frame = "yes" or par-mode = 'ПРОСМОТР':U
then lock-line = yes.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disp-fl :
DEF VAR v-doc-host-code like ub.sysconf.host-code no-undo .
define buffer buf_currency for ub.currency  .
define buffer buf_clients for ub.clients .
ASSIGN FRAME   Dialog-Frame tt-wth-line.wth-code.
IF NOT( AVAILABLE buf_wealth AND buf_wealth.wth-code =  tt-wth-line.wth-code)
THEN DO:
    FIND FIRST buf_wealth NO-LOCK WHERE
         buf_wealth.wth-code =  tt-wth-line.wth-code NO-ERROR.
END.
IF NOT AVAILABLE buf_wealth  OR (AVAILABLE buf_wealth AND buf_wealth.is-ser = 0) THEN DO:
    HIDE
        tt-wth-line.sum-gds-rubl tt-wth-line.sum-gds-base fl-gds FL-gds-code fl-artic fl-prodType fl-ProdCode fl-prod-name TEXT-1 fl-curr-abbr
    IN FRAME Dialog-Frame.
    enable tt-wth-line.doc-sum  when   AVAILABLE buf_wealth  and par-mode <> 'ПРОСМОТР':U
    with frame Dialog-Frame.
    if ub.wth-doc.doc-type = 'при':U and ub.wth-doc.exter_ = no and par-mode <> 'ПРОСМОТР':U and  AVAILABLE buf_wealth   then do:
      enable tt-wth-line.fact-sum
      with frame Dialog-Frame.
      disable tt-wth-line.doc-sum
      with frame Dialog-Frame.
    end.
    RETURN.
END.
DO WITH FRAME  Dialog-Frame:
FIND FIRST buf_clients NO-LOCK WHERE
    buf_clients.obj-type = tt-wth-line.obj-type AND
    buf_clients.obj-code = tt-wth-line.obj-code .
   v-doc-host-code =  buf_clients.host-code.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-doc-host-code
  ,output base-code
  )  .
   find first Buf_currency where Buf_currency.curr-code = base-code no-lock no-error.
   if available Buf_currency then DO :
       fl-curr-abbr:SCREEN-VALUE = Buf_currency.curr-abbr .
   END.
view tt-wth-line.sum-gds-rubl tt-wth-line.sum-gds-base fl-gds FL-gds-code fl-artic fl-prodType fl-ProdCode fl-prod-name TEXT-1 fl-curr-abbr.
disable tt-wth-line.doc-sum
    with frame Dialog-Frame.
DISPLAY
    tt-wth-line.sum-gds-rubl
    tt-wth-line.sum-gds-base
.
      find first ub.wth-gds no-lock where
              ub.wth-gds.wth-code = tt-wth-line.wth-code no-error .
      if available ub.wth-gds  then DO :
          FIND FIRST b-goods WHERE b-goods.gds-code = ub.wth-gds.gds-code NO-LOCK NO-ERROR.
          IF AVAILABLE b-goods THEN DO WITH FRAME Dialog-Frame:
                 fl-artic:SCREEN-VALUE = b-goods.artic.
                 fl-prodType:SCREEN-VALUE = string(b-goods.prod-type).
                 fl-prodCode:SCREEN-VALUE = string(b-goods.prod-code).
                 fl-gds:SCREEN-VALUE = b-goods.gds-name.
                 fl-gds-code:SCREEN-VALUE = string(b-goods.gds-code).
           END.
           ELSE DO:  ASSIGN fl-artic:SCREEN-VALUE = '?':U
                 fl-prodType:SCREEN-VALUE = '?':U
                 fl-prodCode:SCREEN-VALUE = '?':U
                 fl-gds:SCREEN-VALUE = '?':U
                 fl-gds-code:SCREEN-VALUE = '?':U
                 fl-prod-name:SCREEN-VALUE = '?':U.
           END.
          FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = b-goods.prod-type and ub.clients.obj-code = b-goods.prod-code NO-ERROR.
          IF AVAILABLE ub.clients THEN DO WITH FRAME Dialog-Frame:
              fl-prod-name:SCREEN-VALUE = ub.clients.obj-name.
          END.
          ELSE do:
             ASSIGN fl-prod-name:SCREEN-VALUE = '?':U.
          END.
      END.
      ELSE DO:  ASSIGN fl-artic:SCREEN-VALUE = '?':U
             fl-prodType:SCREEN-VALUE = '?':U
             fl-prodCode:SCREEN-VALUE = '?':U
             fl-gds:SCREEN-VALUE = '?':U
             fl-gds-code:SCREEN-VALUE = '?':U
             fl-prod-name:SCREEN-VALUE = '?':U.
      END.
 END.
      END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-dtl FL-gds-code fl-ProdCode TEXT-1
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-line THEN
    DISPLAY tt-wth-line.wth-code tt-wth-line.doc-sum tt-wth-line.fact-sum
          tt-wth-line.sum-gds-rubl tt-wth-line.sum-gds-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wealth THEN
    DISPLAY ub.wealth.wth-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-1 RECT-2 b-quit B-prev B-next B-Help tt-wth-line.wth-code
         B-wealth tt-wth-line.fact-sum T-dtl ub.wealth.wth-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
for each tt-wth-line:
  delete tt-wth-line.
end.
for each tt-par-dtl:
    delete tt-par-dtl.
end.
release buf_wealth.
  if par-mode = 'ДОБАВЛЕНИЕ':U then do:
    run cur-time in this-procedure ( output v-today, output v-time).
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CREATE tt-wth-line.
ASSIGN
  tt-wth-line.doc-code     = ub.wth-doc.doc-code
  tt-wth-line.w-p-code     = par-current-w-p-code
  tt-wth-line.out-code     = par-out-w-p-code
  tt-wth-line.obj-type     = ub.wth-doc.obj-type
  tt-wth-line.obj-code     = ub.wth-doc.obj-code
  tt-wth-line.shift-date   = ub.wth-doc.shift-date
  tt-wth-line.shift-num    = ub.wth-doc.shift-num
  tt-wth-line.shift-name   = ub.wth-doc.shift-name
  tt-wth-line.creid        = g#userid
  tt-wth-line.credate      = v-today
.
  end.
  else do:
    create tt-wth-line.
    buffer-copy buf_wth-line to tt-wth-line.
    FIND FIRST buf_wealth No-LOCK WHERE
               buf_wealth.wth-code = tt-wth-line.wth-code No-error.
    find first ub.wth-dtl No-LOCK WHERE
                  ub.wth-dtl.wth-code = tt-wth-line.wth-code AND
                  ub.wth-dtl.doc-code = tt-wth-line.doc-code AND
                  ub.wth-dtl.w-p-code = tt-wth-line.w-p-code  No-ERROR.
  end.
END PROCEDURE.
PROCEDURE lock-proc :
DEFINE INPUT PARAMETER lock-line as logical no-undo.
  if lock-line then
  DISABLE
  b-wealth
  tt-wth-line.wth-code
  with frame Dialog-Frame
  .
  ELSE
  ENABLE
  b-wealth when locked-wth = no
  tt-wth-line.wth-code when locked-wth = no
  with frame Dialog-Frame
  .
END PROCEDURE.
PROCEDURE MyEnable :
   TEXT-1 = "РУБ" .
   display TEXT-1 with frame Dialog-Frame .
IF AVAILABLE tt-wth-line THEN
    DISPLAY
    tt-wth-line.wth-code
    tt-wth-line.doc-sum
    tt-wth-line.fact-sum
  WITH FRAME Dialog-Frame.
IF AVAILABLE buf_wealth THEN
    DISPLAY
    buf_wealth.wth-name @ ub.wealth.wth-name
   WITH FRAME Dialog-Frame.
  ELSE
  DISPLAY
  '':u @ WEALTH.WTH-NAME
  WITH FRAME Dialog-Frame.
CASE par-mode:
  when 'ДОБАВЛЕНИЕ':U THEN DO:
    ENABLE
    tt-wth-line.wth-code
    B-Wealth
    B-exit
    b-quit
    b-dtl
    WITH FRAME Dialog-Frame.
    HIDE
    tt-wth-line.fact-sum
    IN FRAME Dialog-Frame
    B-Next IN FRAME Dialog-Frame
    B-Prev IN FRAME Dialog-Frame
    .
    locked-wth = no.
  END.
  when 'ИЗМЕНЕНИЕ':U  THEN DO:
      IF ub.wth-doc.status_ = 'накл':U THEN DO:
        ENABLE
        tt-wth-line.wth-code
        B-Wealth
        B-exit
        b-quit
        b-dtl
        WITH FRAME Dialog-Frame.
        HIDE
        tt-wth-line.fact-sum IN FRAME Dialog-Frame
        B-Next        IN FRAME Dialog-Frame
        B-Prev        IN FRAME Dialog-Frame
        .
        locked-wth = no.
      END.
    ELSE IF wth-doc.status_ = 'разрешен':U THEN DO:
        DISPLAY
        tt-wth-line.fact-sum
        WITH FRAME Dialog-Frame.
        ENABLE
        tt-wth-line.fact-sum
        B-exit
        b-quit
        b-dtl when avail ub.wth-dtl
        WITH FRAME Dialog-Frame.
        HIDE
        B-Next IN FRAME Dialog-Frame
        B-Prev IN FRAME Dialog-Frame
        .
        locked-wth = yes.
      END.
    END.
    when 'ПРОСМОТР':U  THEN DO:
      IF wth-doc.status_ <> 'накл':U THEN DO:
        DISPLAY
        tt-wth-line.fact-sum WITH FRAME Dialog-Frame.
      END.
      ENABLE
      B-Next
      B-Prev
      b-quit
      b-dtl when avail ub.wth-dtl
      WITH FRAME Dialog-Frame.
      HIDE
      B-Wealth IN FRAME Dialog-Frame
      .
      locked-wth = yes.
      b-quit:label = 'Выход'.
    END.
  END CASE.
  if wth-doc.doc-type = 'декл':U then do:
    hide
    tt-wth-line.fact-sum
    in frame Dialog-Frame .
  end.
  run control-dtl in this-procedure ( output lock-line).
  run lock-proc in this-procedure ( input lock-line).
  ENABLE
  b-help
  WITH FRAME Dialog-Frame.
     parext-doc-name = ENTRY(LOOKUP(parext-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u) no-error.
  FRAME Dialog-Frame:TITLE =
      "Документ № " + wth-doc.doc-code + " " + CAPS(parext-doc-name) + "  - " + CAPS( par-mode ) + " матценности".
  VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-move :
DEFINE INPUT PARAMETER par-action as character No-UNDO.
define variable is-updated as logical no-undo.
define variable loc#log as logical no-undo.
define variable v-line-rec as recid no-undo .
  ASSIGN v-line-rec = RECID( buf_wth-line ).
  CASE par-action:
    when "b-next":U then do:
        GET NEXT QUERY-lines NO-LOCK.
    end.
    when "b-prev":U then do:
        GET PREV QUERY-lines NO-LOCK.
    end.
  END CASE.
  IF AVAIL buf_wth-line THEN DO:
    ASSIGN v-line-rec = RECID( buf_wth-line ).
    run fill-tables in this-procedure.
    run MyEnable in this-procedure.
    RUN disp-fl IN THIS-PROCEDURE.
  END.
  ELSE DO:
    CASE par-action:
        when "b-next":U then do:
            GET PREV QUERY-lines NO-LOCK.
        end.
        when "b-prev":U then do:
            GET NEXT QUERY-lines NO-LOCK.
        end.
    END CASE.
    FIND FIRST buf_wth-line NO-LOCK WHERE
                    RECID( buf_wth-line ) = v-line-rec NO-ERROR.
    MESSAGE
      "Это" ( IF par-action = "B-Next":U THEN "последняя" ELSE "первая" )
      "строка в документе!"
    VIEW-AS ALERT-BOX INFORMATION.
    RETURN NO-APPLY.
  END.
END PROCEDURE.
PROCEDURE proc-save-line :
DEFINE INPUT PARAMETER par-log as logical no-undo .
define input-output parameter loc-mode as character no-undo.
DEFINE VARIABLE var-entry as character no-undo .
IF loc-mode = 'ПРОСМОТР':U THEN DO:
   RETURN NO-APPLY.
END.
parline-rec = if loc-mode = 'ДОБАВЛЕНИЕ':U then ? else parline-rec.
assign
frame Dialog-Frame tt-wth-line.wth-code
frame Dialog-Frame tt-wth-line.doc-sum
frame Dialog-Frame tt-wth-line.fact-sum
.
 run str/wth-lnc1.p (
                      input-output parline-rec
                      ,input  loc-mode
                      ,input no
                      ,input vardoc-code
                      ,input tt-wth-line.wth-code
                      ,input tt-wth-line.w-p-code
                      ,input tt-wth-line.out-code
                      ,input tt-wth-line.doc-sum
                      ,input tt-wth-line.fact-sum
                      ,input table tt-par-dtl
                      ,input par-log
                      ,input parext-type
                      ,input tt-wth-line.sum-gds-rubl
                      ,input tt-wth-line.sum-gds-base
                      ) no-error.
  IF ERROR-STATUS:ERROR THEN DO:
    if var-entry <> '':U then do:
      CASE entry(1, var-entry, chr(4)):
        when "wth-code":U then do:
            APPLY "ENTRY":U TO tt-wth-line.wth-code IN FRAME Dialog-Frame.
        end.
        when "doc-sum":U then do:
            APPLY "ENTRY":U TO tt-wth-line.doc-sum IN FRAME Dialog-Frame.
        end.
        when "fact-sum":U then do:
            APPLY "ENTRY":U TO tt-wth-line.fact-sum IN FRAME Dialog-Frame.
        end.
        when "wth-dtl":U then do:
            APPLY "ENTRY":U TO b-dtl IN FRAME Dialog-Frame.
       end.
      END CASE.
     end.
    RETURN error.
  END.
  loc-mode = 'ИЗМЕНЕНИЕ':U.
END PROCEDURE.
