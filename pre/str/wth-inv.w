DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_wth FOR ub.wealth.
DEFINE BUFFER buf_wth-line FOR ub.wth-line.
DEFINE BUFFER buf_wth-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-wth-doc NO-UNDO LIKE ub.wth-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parcli-type like ub.clients.obj-type no-undo.
define input parameter parcli-code like ub.clients.obj-code no-undo.
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo.
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "перемещение МЦ: добавление, изменение, просмотр инвентаризации":U.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer bf_wth-doc for ub.wth-doc.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
DEFINE VARIABLE v_rid      AS CHAR NO-UNDO.
DEFINE VARIABLE l-shift-on AS LOG  NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE var-peresort as logical no-undo.
define variable glog as logical no-undo .
define variable ref-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
define variable parext-doc-name as character no-undo.
define buffer auto-wth-doc-lock_batchprocess for ub.batchprocess .
define buffer cli-buf for ub.clients.
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
FIELD q-ty-bef     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во план"
FIELD q-ty-aft     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во факт"
FIELD sum-bef  like ub.wth-line.bef-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма план"
FIELD sum-aft  like ub.wth-line.aft-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма факт"
FIELD sum-fact  like ub.wth-line.fact-sum FORM "->,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Расхождение"
INDEX tt-pi    IS   PRIMARY UNIQUE par-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        sum-bef  q-ty-bef
 .
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chk
     LABEL "Че&ки"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-person1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-person2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-person3
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-person4
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-person5
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE deliver-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE inv-prs4-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE inv-prs5-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE operator-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE receiver-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE QUERY BR-lines FOR
      buf_wth-line,
      buf_wth,
      buf_wth-place SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-wth-doc SCROLLING.
DEFINE BROWSE BR-lines
  QUERY BR-lines NO-LOCK DISPLAY
      buf_wth-line.wth-code FORMAT ">>>>>>>>9":U
      buf_wth.wth-name FORMAT "X(20)":U
      buf_wth-place.w-p-name FORMAT "X(20)":U
      buf_wth-line.bef-sum COLUMN-LABEL "Сумма план" FORMAT "->,>>>,>>>,>>9.99":U
      buf_wth-line.aft-sum COLUMN-LABEL "Сумма факт" FORMAT "->,>>>,>>>,>>9.99":U
      buf_wth-line.fact-sum COLUMN-LABEL "Расхождение" FORMAT "->,>>>,>>>,>>9.99":U
  ENABLE
      buf_wth-line.fact-sum
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.8.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-prev AT ROW 1 COL 40
     B-next AT ROW 1 COL 44
     B-Help AT ROW 1 COL 95
     tt-wth-doc.doc-code AT ROW 2.13 COL 7.3 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN
          SIZE 16.1 BY 1
          FGCOLOR 4
     tt-wth-doc.doc-date AT ROW 2.13 COL 29.8 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-wth-doc.fact-date AT ROW 2.13 COL 48.4 COLON-ALIGNED
          LABEL "Факт"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     tt-wth-doc.shift-date AT ROW 2.13 COL 66.5 COLON-ALIGNED
          LABEL "Смена"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-wth-doc.shift-name AT ROW 2.13 COL 82 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
          FGCOLOR 4
     tt-wth-doc.shift-num AT ROW 2.13 COL 92.5 COLON-ALIGNED
          LABEL "П."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-doc.obj-type AT ROW 3.33 COL 11 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6.1 BY 1
     tt-wth-doc.obj-code AT ROW 3.33 COL 18.3 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1.13
     tt-wth-doc.bef-sum AT ROW 4.7 COL 11.6 COLON-ALIGNED
          LABEL "Сумма план"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-wth-doc.aft-sum AT ROW 4.7 COL 42.9 COLON-ALIGNED
          LABEL "Сумма факт"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-wth-doc.fact-sum AT ROW 4.77 COL 74.5 COLON-ALIGNED
          LABEL "Расхождение"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     BR-lines AT ROW 5.93 COL 1
     B-add AT ROW 13.83 COL 1
     B-lookup AT ROW 13.83 COL 11
     B-chg AT ROW 13.83 COL 21
     B-del AT ROW 13.83 COL 31
     B-chk AT ROW 13.83 COL 41
     B-hist AT ROW 13.83 COL 71
     tt-wth-doc.operator AT ROW 16 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     B-person1 AT ROW 16 COL 15
     tt-wth-doc.deliver AT ROW 17.2 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     B-person2 AT ROW 17.2 COL 15
     tt-wth-doc.receiver AT ROW 18.43 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     B-person3 AT ROW 18.43 COL 15
     B-person4 AT ROW 19.5 COL 15
     tt-wth-doc.inv-prs4 AT ROW 19.57 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     tt-wth-doc.inv-prs5 AT ROW 20.8 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     B-person5 AT ROW 20.8 COL 15
     for-object AT ROW 3.33 COL 29.8 COLON-ALIGNED NO-LABEL
     operator-name AT ROW 16 COL 17.1 COLON-ALIGNED NO-LABEL
     deliver-name AT ROW 17.2 COL 17.1 COLON-ALIGNED NO-LABEL
     receiver-name AT ROW 18.43 COL 17.1 COLON-ALIGNED NO-LABEL
     inv-prs4-name AT ROW 19.57 COL 17.1 COLON-ALIGNED NO-LABEL
     inv-prs5-name AT ROW 20.8 COL 17.1 COLON-ALIGNED NO-LABEL
     "ЧЛЕНЫ ИНВЕНТАРИЗАЦИОННОЙ КОМИССИИ" VIEW-AS TEXT
          SIZE 34.1 BY 1 AT ROW 14.97 COL 19.4
          BGCOLOR 3 FGCOLOR 15
     SPACE(45.49) SKIP(5.89)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Инвентаризационная ведомость движения материальных ценностей"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-b-add in this-procedure  no-error.
  if error-status:error
  or return-value = 'error'
  then return no-apply.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
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
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
 if not avail buf_wth-line then return no-apply.
  ASSIGN
  v-line-rec = RECID( buf_wth-line )
  v-doc-rec = recid(bf_wth-doc)
  .
  run proc-save-doc(no) No-ERROR.
  if error-status:error
  or return-value = 'error'
  then return no-apply.
  run str/wth-inva.w ( input parparentproc,
                   INPUT 'ИЗМЕНЕНИЕ':U,
                   input v-doc-rec,
                   input-output v-LINE-REC) no-error.
  ASSIGN
  glog = br-lines:REFRESH( ).
  apply "entry" to br-lines.
END.
ON CHOOSE OF B-chk IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  DEFINE VARIABLE loc-ref-list as character no-undo.
  run str/chk-docs.w (
                  input parparentproc
                 ,input '':U
                 ,input 'out-code':U
                 ,input ?
                 ,input parobj-type
                 ,input parobj-code
                 ,input tt-wth-doc.doc-code
                 ,input ''
                 ,input 0
                 ,input ?
                 ,input ?
                 ,input 0
                 ,output loc-ref-list) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 run proc-save-doc(if tt-wth-doc.auto-fill then no else yes) No-ERROR.
 if error-status:error
 or return-value = 'error'
 then return no-apply.
 p-doc-rec = v-doc-rec .
 APPLY "GO":U TO FRAME Dialog-Frame.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-rid-list as character no-undo .
    run str/wthcdocs.w
      (
       input  parparentproc
      ,input  'b-add'
      ,input  'one':U
      ,input  tt-wth-doc.host-code
      ,input  tt-wth-doc.obj-type
      ,input  tt-wth-doc.obj-code
      ,input  '':U
      ,input  0
      ,input '':U
      ,input  tt-wth-doc.doc-code
      ,output v-rid-list
      ).
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
 if not avail buf_wth-line then return no-apply.
  ASSIGN
  v-line-rec = RECID( buf_wth-line )
  v-doc-rec = recid(bf_wth-doc)
  .
  run str/wth-inva.w (input parparentproc,
                  INPUT 'ПРОСМОТР':U,
                  input v-doc-rec,
                  input-output v-LINE-REC
                  ) no-error.
  apply "entry" to br-lines.
END.
ON CHOOSE OF B-next IN FRAME Dialog-Frame
DO:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
       run reposition-wth-doc in this-procedure
  (input 'next':U
  ).
END.
ON CHOOSE OF B-person1 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("operator", "button").
  apply "entry" to tt-wth-doc.operator in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-person2 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("deliver", "button").
  apply "entry" to tt-wth-doc.deliver in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-person3 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("receiver", "button").
  apply "entry" to tt-wth-doc.receiver in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-person4 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("inv-prs4", "button").
  apply "entry" to tt-wth-doc.inv-prs4 in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-person5 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("inv-prs5", "button").
  apply "entry" to tt-wth-doc.inv-prs5 in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-prev IN FRAME Dialog-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
       run reposition-wth-doc in this-procedure
  (input 'prev':U
  ).
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    IF CAN-FIND( FIRST ub.wth-line NO-LOCK WHERE
                       ub.wth-line.doc-code = bf_wth-doc.doc-code ) THEN DO:
      MESSAGE
        "Документ не будет сохранен, а вся введенная Вами информация будет потеряна!" SKIP
        "Для того, чтобы сохранить документ, нужно нажать кнопку ~"" +
        B-exit:LABEL IN FRAME Dialog-Frame + "~"." SKIP( 1 )
        "Вы уверены, что хотите выйти БЕЗ СОХРАНЕНИЯ?" SKIP
        "YES[ДА] - Выйти БЕЗ СОХРАНЕНИЯ;" SKIP
        "NO[НЕТ] - Остаться в документе."
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE "Выход из документа без сохранения" UPDATE glog.
      IF glog = NO THEN DO:
        RETURN NO-APPLY.
      END.
    END.
    DO TRANSACTION ON ERROR UNDO, LEAVE :
      FIND CURRENT bf_wth-doc EXCLUSIVE-LOCK.
      DELETE bf_wth-doc.
      p-doc-rec = ?.
    END.
  END.
    p-next-prev = "QUIT".
END.
ON LEAVE OF tt-wth-doc.deliver IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-wth-doc.deliver <> tt-wth-doc.deliver then do:
    run local-psn-chk ("deliver", "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.deliver IN FRAME Dialog-Frame
OR return OF tt-wth-doc.deliver IN FRAME Dialog-Frame DO:
  run local-psn-chk ("deliver", "ret-mouse").
  apply "entry" to tt-wth-doc.deliver in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-wth-doc.inv-prs4 IN FRAME Dialog-Frame
DO:
   if input frame Dialog-Frame tt-wth-doc.inv-prs4 <> tt-wth-doc.inv-prs4 then do:
    run local-psn-chk ("inv-prs4", "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.inv-prs4 IN FRAME Dialog-Frame
OR return OF tt-wth-doc.inv-prs4 IN FRAME Dialog-Frame DO:
  run local-psn-chk ("inv-prs4", "ret-mouse").
  apply "entry" to tt-wth-doc.inv-prs4 in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-wth-doc.inv-prs5 IN FRAME Dialog-Frame
DO:
    if input frame Dialog-Frame tt-wth-doc.inv-prs5 <> tt-wth-doc.inv-prs5 then do:
     run local-psn-chk ("inv-prs5", "leave").
   end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.inv-prs5 IN FRAME Dialog-Frame
OR return OF tt-wth-doc.inv-prs5 IN FRAME Dialog-Frame DO:
  run local-psn-chk ("inv-prs5", "ret-mouse").
  apply "entry" to tt-wth-doc.inv-prs5 in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-wth-doc.operator IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-wth-doc.operator <> tt-wth-doc.operator then do:
    run local-psn-chk ("operator", "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.operator IN FRAME Dialog-Frame
OR return OF tt-wth-doc.operator IN FRAME Dialog-Frame DO:
  run local-psn-chk ("operaror", "ret-mouse").
  apply "entry" to tt-wth-doc.operator in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-wth-doc.receiver IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-wth-doc.receiver <> tt-wth-doc.receiver then do:
    run local-psn-chk ("receiver", "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.receiver IN FRAME Dialog-Frame
OR return OF tt-wth-doc.receiver IN FRAME Dialog-Frame DO:
  run local-psn-chk ("receiver", "ret-mouse").
  apply "entry" to tt-wth-doc.receiver in frame Dialog-Frame.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-lines :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
p-next-prev = "".
n-p: do while p-next-prev = "":U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if par-mode <> 'ИЗМЕНЕНИЕ':U and par-mode <> 'ДОБАВЛЕНИЕ':U and par-mode <> 'ПРОСМОТР':U then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова par-mode"
        view-as alert-box ERROR.
        return error.
    end.
    if not par-mode = 'ПРОСМОТР':U then
    p-next-prev = "QUIT".
    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = parhost-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = parobj-type AND
                ub.clients.obj-code = parobj-code No-ERROR.
    if not avail ub.clients then do:
      message vss-workfile vss-revision vss-description skip
              "Неверный параметр вызова parobj-type/parobj-code"
      view-as alert-box ERROR.
      return error.
    end.
    if parcli-type <> '':U or parcli-code <> 0 then do:
      find first ub.clients No-LOCK WHERE
                  ub.clients.obj-type = parcli-type AND
                  ub.clients.obj-code = parcli-code No-ERROR.
      if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
                "Неверный параметр вызова parcli-type/parcli-code"
        view-as alert-box ERROR.
        return error.
      end.
    end.
    tt-wth-doc.obj-type:list-items = 'орг':U + chr(44) +
                                    'чел':U + chr(44) +
                                    'маг':U + chr(44) +
                                    'скл':U + chr(44).
  Run fill-tables no-error.
  if error-status:error then return error.
  RUN Myenable in this-procedure .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-lines as INT EXTENT 18 no-undo.
DEF VAR varmvibr-lines       as INT no-undo.
DEF VAR varmvjbr-lines       as INT no-undo.
DEF VAR varmvkbr-lines       as INT no-undo.
DEF VAR varmvlbr-lines       as INT no-undo.
DEF VAR move-elementbr-lines as INT no-undo.
def var jjbr-lines           as int no-undo.
do varmvibr-lines = 1 to EXTENT(cur-clmn-numbr-lines):
  ASSIGN cur-clmn-numbr-lines[varmvibr-lines] = varmvibr-lines.
END.
RUN start-mv-clmnbr-lines.
PROCEDURE start-mv-clmnbr-lines:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  var-peresort = no  THEN DO:
   DO jjbr-lines = NUM-ENTRIES('1,2,3,4,5,6') TO 1 BY -1:
     RUN re-move-clmnbr-lines ( cur-clmn-numbr-lines[INTEGER(ENTRY (jjbr-lines, '1,2,3,4,5,6'))] , 1).
   END.
       END.
       IF  var-peresort = yes  THEN DO:
   DO jjbr-lines = NUM-ENTRIES('1,2,3,6,4,5') TO 1 BY -1:
     RUN re-move-clmnbr-lines ( cur-clmn-numbr-lines[INTEGER(ENTRY (jjbr-lines, '1,2,3,6,4,5'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-lines do:
  RUN re-move-clmnbr-lines ( 1, 18).
END.
ON ctrl-cursor-left OF BROWSE br-lines do:
  RUN re-move-clmnbr-lines (18, 1).
END.
PROCEDURE re-move-clmnbr-lines:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
    if cur-clmn-numbr-lines[varmvibr-lines] = source-column THEN cur-clmn-numbr-lines[varmvibr-lines] = -1.
  END.
  if br-lines:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-lines = source-column - 1 to target-column BY -1:
    DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
        if cur-clmn-numbr-lines[varmvibr-lines] = varmvjbr-lines THEN DO:
          cur-clmn-numbr-lines[varmvibr-lines] = cur-clmn-numbr-lines[varmvibr-lines] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-lines = source-column + 1 to target-column:
    DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
      if cur-clmn-numbr-lines[varmvibr-lines] = varmvjbr-lines THEN DO:
        cur-clmn-numbr-lines[varmvibr-lines] = cur-clmn-numbr-lines[varmvibr-lines] - 1.
      END.
    END.
  END.
  DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
    if cur-clmn-numbr-lines[varmvibr-lines] = -1 THEN cur-clmn-numbr-lines[varmvibr-lines] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-lines:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
    if cur-clmn-numbr-lines[varmvibr-lines] = cur-clmn-loc THEN move-elementbr-lines = varmvibr-lines.
  END.
  RUN re-move-clmnbr-lines (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-lines:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-lines = 1 to EXTENT(cur-clmn-numbr-lines):
    RUN re-move-clmnbr-lines (cur-clmn-numbr-lines[varmvlbr-lines], varmvlbr-lines).
  END.
  RUN start-mv-clmnbr-lines.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
end.
RUN disable_UI.
PROCEDURE control-peresort :
DEFINE OUTPUT parameter par-peresort as logical no-undo.
if tt-wth-doc.auto-fill = yes and
can-find(first ub.chk-doc No-LOCK WHERE
                   ub.chk-doc.obj-type = tt-wth-doc.obj-type AND
                    ub.chk-doc.obj-code = tt-wth-doc.obj-code AND
                    ub.chk-doc.out-code = tt-wth-doc.doc-code AND
                    ub.chk-doc.chk-type = integer('4':U)) then do:
                    par-peresort = yes.
end.
else par-peresort = no.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-wth-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY for-object operator-name deliver-name receiver-name inv-prs4-name
          inv-prs5-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-doc THEN
    DISPLAY tt-wth-doc.doc-code tt-wth-doc.doc-date tt-wth-doc.fact-date
          tt-wth-doc.shift-date tt-wth-doc.shift-name tt-wth-doc.shift-num
          tt-wth-doc.obj-type tt-wth-doc.obj-code tt-wth-doc.bef-sum
          tt-wth-doc.aft-sum tt-wth-doc.fact-sum tt-wth-doc.operator
          tt-wth-doc.deliver tt-wth-doc.receiver tt-wth-doc.inv-prs4
          tt-wth-doc.inv-prs5
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-prev B-next B-Help tt-wth-doc.doc-date
         tt-wth-doc.fact-date tt-wth-doc.shift-date tt-wth-doc.shift-name
         tt-wth-doc.shift-num tt-wth-doc.obj-code tt-wth-doc.bef-sum
         tt-wth-doc.aft-sum tt-wth-doc.fact-sum BR-lines B-add B-lookup B-chg
         B-del B-chk B-hist tt-wth-doc.operator B-person1 tt-wth-doc.deliver
         B-person2 tt-wth-doc.receiver B-person3 B-person4 tt-wth-doc.inv-prs4
         tt-wth-doc.inv-prs5 B-person5 for-object operator-name deliver-name
         receiver-name inv-prs4-name inv-prs5-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
for each tt-wth-doc:
    delete tt-wth-doc.
end.
IF par-mode = 'ДОБАВЛЕНИЕ':U then do:
   run gbl/factdate.p (
                    INPUT        parobj-type,
                    INPUT        parobj-code,
                    INPUT-OUTPUT f-date,
                    INPUT-OUTPUT f-time,
                    INPUT-OUTPUT s-date,
                    INPUT-OUTPUT s-num,
                    INPUT-OUTPUT s-name,
                    INPUT        YES
                  ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      return error.
    END.
    DO TRANSACTION ON ERROR UNDO, RETURN ERROR:
define variable l-in-ov17 as logical no-undo .
define variable v-date17 as date no-undo .
define variable v-time17 as integer no-undo .
run cur-time in this-procedure(output v-date17, output v-time17).
CREATE tt-wth-doc.
ASSIGN
  tt-wth-doc.host-code = parhost-code
  tt-wth-doc.doc-code  = TRIM( STRING( NEXT-VALUE( s-wth-doc, ub), ">>>>>>>>>9":U ) ) + "-" + TRIM( STRING( parobj-code, ">>>>>>>>9":U ) ) +                   SUBSTR( parobj-type, ( IF g#language = "RUS" THEN 1 ELSE 2 ), 1 )
   tt-wth-doc.doc-type  = 'инв':U
  tt-wth-doc.ext-doc-type  = 'iy':U
  tt-wth-doc.inter_    = if  lookup(tt-wth-doc.ext-doc-type,'ij,pj,fj,jj,oj,ej':U) > 0 then yes else no
  tt-wth-doc.exter_    = if  lookup(tt-wth-doc.ext-doc-type,'ie,ee,we,pc,ps,iy,pz,df,dp,dc,xc':U) > 0 then yes else no
  tt-wth-doc.status_   = 'накл':U
  tt-wth-doc.obj-type  = parobj-type
  tt-wth-doc.obj-code  = parobj-code
  tt-wth-doc.creid     = v-cntxt-userid
  tt-wth-doc.credate   = v-date17
.
if tt-wth-doc.doc-type = 'инв':U or lookup(tt-wth-doc.ext-doc-type, 'we,dc,dp,df':U) > 0
   or tt-wth-doc.doc-type = 'декл':U then do:
  assign
    tt-wth-doc.cli-type  = 'орг':U
    tt-wth-doc.cli-code  = parhost-code
    .
end.
else if tt-wth-doc.ext-doc-type = 'ps':U then do:
  assign
  tt-wth-doc.cli-type  = parobj-type
  tt-wth-doc.cli-code  = parobj-code
  .
end.
else if tt-wth-doc.inter_  = yes
then do:
  assign
  tt-wth-doc.cli-type  = parobj-type
  tt-wth-doc.cli-code  = parobj-code
  .
end.
else if tt-wth-doc.exter_  = yes
then do:
  assign
  tt-wth-doc.cli-type  =  (if parcli-type <> "" then parcli-type else 'орг':U)
  tt-wth-doc.cli-code  =  (if parcli-code <> 0 then parcli-code else 0)
  .
end.
else assign
    tt-wth-doc.cli-type  = parobj-type
    tt-wth-doc.cli-code  = 0
.
      ASSIGN
      tt-wth-doc.shift-date = s-date
      tt-wth-doc.shift-num  = s-num
      tt-wth-doc.shift-name = s-name
      tt-wth-doc.doc-date   = f-date
      tt-wth-doc.operator   = 0
      tt-wth-doc.receiver   = 0
      tt-wth-doc.deliver    = 0
      tt-wth-doc.inv-prs4   = 0
      tt-wth-doc.inv-prs5   = 0
      tt-wth-doc.auto-fill  = parauto-fill
      .
define variable l-in-ov18 as logical no-undo .
define variable v-date18 as date no-undo .
define variable v-time18 as integer no-undo .
run cur-time in this-procedure(output v-date18, output v-time18).
CREATE bf_wth-doc.
ASSIGN
  bf_wth-doc.host-code = parhost-code
  bf_wth-doc.doc-code  = tt-wth-doc.doc-code
   bf_wth-doc.doc-type  = 'инв':U
  bf_wth-doc.ext-doc-type  = 'iy':U
  bf_wth-doc.inter_    = if  lookup(bf_wth-doc.ext-doc-type,'ij,pj,fj,jj,oj,ej':U) > 0 then yes else no
  bf_wth-doc.exter_    = if  lookup(bf_wth-doc.ext-doc-type,'ie,ee,we,pc,ps,iy,pz,df,dp,dc,xc':U) > 0 then yes else no
  bf_wth-doc.status_   = 'накл':U
  bf_wth-doc.obj-type  = parobj-type
  bf_wth-doc.obj-code  = parobj-code
  bf_wth-doc.creid     = v-cntxt-userid
  bf_wth-doc.credate   = v-date18
.
if bf_wth-doc.doc-type = 'инв':U or lookup(bf_wth-doc.ext-doc-type, 'we,dc,dp,df':U) > 0
   or bf_wth-doc.doc-type = 'декл':U then do:
  assign
    bf_wth-doc.cli-type  = 'орг':U
    bf_wth-doc.cli-code  = parhost-code
    .
end.
else if bf_wth-doc.ext-doc-type = 'ps':U then do:
  assign
  bf_wth-doc.cli-type  = parobj-type
  bf_wth-doc.cli-code  = parobj-code
  .
end.
else if bf_wth-doc.inter_  = yes
then do:
  assign
  bf_wth-doc.cli-type  = parobj-type
  bf_wth-doc.cli-code  = parobj-code
  .
end.
else if bf_wth-doc.exter_  = yes
then do:
  assign
  bf_wth-doc.cli-type  =  (if parcli-type <> "" then parcli-type else 'орг':U)
  bf_wth-doc.cli-code  =  (if parcli-code <> 0 then parcli-code else 0)
  .
end.
else assign
    bf_wth-doc.cli-type  = parobj-type
    bf_wth-doc.cli-code  = 0
.
      ASSIGN
      bf_wth-doc.shift-date = s-date
      bf_wth-doc.shift-num  = s-num
      bf_wth-doc.shift-name = s-name
      bf_wth-doc.doc-date   = f-date
      bf_wth-doc.operator   = 0
      bf_wth-doc.receiver   = 0
      bf_wth-doc.deliver    = 0
      bf_wth-doc.inv-prs4    = 0
      bf_wth-doc.inv-prs5    = 0
      bf_wth-doc.auto-fill = parauto-fill
      v-doc-rec = recid(bf_wth-doc)
      .
    END.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = parobj-type AND
                buf_obj.obj-code = parobj-code No-ERROR.
end.
else do:
  if par-mode = 'ПРОСМОТР':U then do:
    FIND FIRST bf_wth-doc NO-LOCK WHERE
                recid(bf_wth-doc) = p-doc-rec.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
      FIND FIRST bf_wth-doc EXCLUSIVE-LOCK WHERE
                 recid(bf_wth-doc) = p-doc-rec.
    END.
  END.
  IF NOT AVAIL bf_wth-doc then
  return error.
  v-doc-rec = p-doc-rec.
  if bf_wth-doc.status_ = 'факт':U and par-mode <> 'ПРОСМОТР':U then do:
     message "Документ движения МЦ с N" bf_wth-doc.doc-code  "имеет статус" bf_wth-doc.status_ SKIP
             "Изменения не допускаются"
     view-as alert-box error.
     return error.
    end.
  create tt-wth-doc.
  buffer-copy bf_wth-doc to tt-wth-doc.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = tt-wth-doc.obj-type AND
                buf_obj.obj-code = tt-wth-doc.obj-code No-ERROR.
    if not avail buf_obj then do:
      message "Документ движения МЦ N" bf_wth-doc.doc-code  skip
              "Неверный объект" bf_wth-doc.obj-type bf_wth-doc.obj-code
      view-as alert-box ERROR.
      return error.
    end.
    FIND FIRST buf_clients No-LOCK WHERe
                buf_clients.obj-type = tt-wth-doc.cli-type AND
                buf_clients.obj-code = tt-wth-doc.cli-code No-ERROR.
   if not avail buf_clients
      or NOT (buf_clients.obj-type = 'орг':U AND buf_clients.obj-code = parhost-code) then do:
      message "Документ движения МЦ N" bf_wth-doc.doc-code  skip
              "Неверный контрагент" bf_wth-doc.cli-type bf_wth-doc.cli-code
      view-as alert-box ERROR.
      return error.
   end.
end.
if tt-wth-doc.auto-fill = yes then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run gbl/lock-prc.p
    (input 'awth':U
    ,input parobj-code
    ,input 0
    ,input 0
    ,input parobj-type
    ,input ""
    ,input ""
    ,input (
             "Код объекта" + ",,," +
             "Тип объекта" +  ",,,Формирование автоматических документов МЦ"
           )
    ,input true
    ,buffer auto-wth-doc-lock_batchprocess
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент уже производится формирование автоматических документов МЦ" skip
      view-as alert-box error .
    undo, return error .
  end.
end.
END PROCEDURE.
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "operator" and p-action = "ret-mouse" then do:
  define variable v-ref-rec20   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-wth-doc.operator <> ""
       and input frame Dialog-Frame tt-wth-doc.operator <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec20 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.operator
            cli-buf.obj-name @ operator-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.operator.
  end.
  else display ? @ tt-wth-doc.operator
               ? @ operator-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.operator cli-buf.obj-name @ operator-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.operator ? @ operator-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "operator" and p-action = "button" then do:
  define variable v-ref-rec21   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec21 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec21 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.operator
            cli-buf.obj-name @ operator-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.operator.
  end.
  else display ? @ tt-wth-doc.operator
               ? @ operator-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.operator cli-buf.obj-name @ operator-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.operator ? @ operator-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "operator" and p-action = "leave" then do:
  define variable v-ref-rec22   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.operator cli-buf.obj-name @ operator-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-wth-doc.operator.
  end.
  else display ? @ tt-wth-doc.operator ? @ operator-name with frame Dialog-Frame.
end.
if p-man = "deliver" and p-action = "ret-mouse" then do:
  define variable v-ref-rec23   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-wth-doc.deliver <> ""
       and input frame Dialog-Frame tt-wth-doc.deliver <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec23 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.deliver
            cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.deliver.
  end.
  else display ? @ tt-wth-doc.deliver
               ? @ deliver-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.deliver cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.deliver ? @ deliver-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "deliver" and p-action = "button" then do:
  define variable v-ref-rec24   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec24 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec24 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.deliver
            cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.deliver.
  end.
  else display ? @ tt-wth-doc.deliver
               ? @ deliver-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.deliver cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.deliver ? @ deliver-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "deliver" and p-action = "leave" then do:
  define variable v-ref-rec25   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.deliver cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-wth-doc.deliver.
  end.
  else display ? @ tt-wth-doc.deliver ? @ deliver-name with frame Dialog-Frame.
end.
if p-man = "receiver" and p-action = "ret-mouse" then do:
  define variable v-ref-rec26   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-wth-doc.receiver <> ""
       and input frame Dialog-Frame tt-wth-doc.receiver <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec26 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.receiver
            cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.receiver.
  end.
  else display ? @ tt-wth-doc.receiver
               ? @ receiver-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.receiver cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.receiver ? @ receiver-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "receiver" and p-action = "button" then do:
  define variable v-ref-rec27   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec27 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec27 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.receiver
            cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.receiver.
  end.
  else display ? @ tt-wth-doc.receiver
               ? @ receiver-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.receiver cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.receiver ? @ receiver-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "receiver" and p-action = "leave" then do:
  define variable v-ref-rec28   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.receiver cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-wth-doc.receiver.
  end.
  else display ? @ tt-wth-doc.receiver ? @ receiver-name with frame Dialog-Frame.
end.
if p-man = "inv-prs4" and p-action = "ret-mouse" then do:
  define variable v-ref-rec29   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs4
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-wth-doc.inv-prs4 <> ""
       and input frame Dialog-Frame tt-wth-doc.inv-prs4 <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec29 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs4
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.inv-prs4
            cli-buf.obj-name @ inv-prs4-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.inv-prs4.
  end.
  else display ? @ tt-wth-doc.inv-prs4
               ? @ inv-prs4-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.inv-prs4 cli-buf.obj-name @ inv-prs4-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.inv-prs4 ? @ inv-prs4-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "inv-prs4" and p-action = "button" then do:
  define variable v-ref-rec30   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs4
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec30 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec30 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs4
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.inv-prs4
            cli-buf.obj-name @ inv-prs4-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.inv-prs4.
  end.
  else display ? @ tt-wth-doc.inv-prs4
               ? @ inv-prs4-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.inv-prs4 cli-buf.obj-name @ inv-prs4-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.inv-prs4 ? @ inv-prs4-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "inv-prs4" and p-action = "leave" then do:
  define variable v-ref-rec31   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs4
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.inv-prs4 cli-buf.obj-name @ inv-prs4-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-wth-doc.inv-prs4.
  end.
  else display ? @ tt-wth-doc.inv-prs4 ? @ inv-prs4-name with frame Dialog-Frame.
end.
if p-man = "inv-prs5" and p-action = "ret-mouse" then do:
  define variable v-ref-rec32   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs5
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-wth-doc.inv-prs5 <> ""
       and input frame Dialog-Frame tt-wth-doc.inv-prs5 <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec32 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs5
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.inv-prs5
            cli-buf.obj-name @ inv-prs5-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.inv-prs5.
  end.
  else display ? @ tt-wth-doc.inv-prs5
               ? @ inv-prs5-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.inv-prs5 cli-buf.obj-name @ inv-prs5-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.inv-prs5 ? @ inv-prs5-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "inv-prs5" and p-action = "button" then do:
  define variable v-ref-rec33   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs5
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec33 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec33 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs5
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.inv-prs5
            cli-buf.obj-name @ inv-prs5-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.inv-prs5.
  end.
  else display ? @ tt-wth-doc.inv-prs5
               ? @ inv-prs5-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.inv-prs5 cli-buf.obj-name @ inv-prs5-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.inv-prs5 ? @ inv-prs5-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "inv-prs5" and p-action = "leave" then do:
  define variable v-ref-rec34   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs5
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.inv-prs5 cli-buf.obj-name @ inv-prs5-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-wth-doc.inv-prs5.
  end.
  else display ? @ tt-wth-doc.inv-prs5 ? @ inv-prs5-name with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE lock-peresort :
DEFINE INPUT PARAMETER par-peresort as logical no-undo.
CASE par-peresort :
    when yes then do:
        HIDE
        tt-wth-doc.aft-sum in frame Dialog-Frame
        tt-wth-doc.bef-sum in frame Dialog-Frame.
        DISPLAY tt-wth-doc.fact-sum
        with frame Dialog-Frame.
    end.
    when no then do:
        DISPLAY
        tt-wth-doc.bef-sum
        tt-wth-doc.aft-sum when NOT tt-wth-doc.status_ = 'накл':U
        with frame Dialog-Frame.
        if tt-wth-doc.status_ = 'накл':U then
        HIDE
        tt-wth-doc.fact-sum
        in frame Dialog-Frame.
    end.
END CASE.
END PROCEDURE.
PROCEDURE MyEnable :
buf_wth-line.fact-sum:READ-ONLY IN BROWSE BR-lines = YES.
  define variable v-ref-rec35   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-wth-doc.operator with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.operator cli-buf.obj-name @ operator-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.operator ? @ operator-name with frame Dialog-Frame.
  define variable v-ref-rec36   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-wth-doc.deliver with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.deliver cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.deliver ? @ deliver-name with frame Dialog-Frame.
  define variable v-ref-rec37   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-wth-doc.receiver with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.receiver cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.receiver ? @ receiver-name with frame Dialog-Frame.
  define variable v-ref-rec38   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs4
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-wth-doc.inv-prs4 with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs4
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.inv-prs4 cli-buf.obj-name @ inv-prs4-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.inv-prs4 ? @ inv-prs4-name with frame Dialog-Frame.
  define variable v-ref-rec39   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs5
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-wth-doc.inv-prs5 with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.inv-prs5
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.inv-prs5 cli-buf.obj-name @ inv-prs5-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.inv-prs5 ? @ inv-prs5-name with frame Dialog-Frame.
  IF AVAILABLE buf_obj THEN
    DISPLAY buf_obj.obj-name @ for-object
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-doc THEN
    DISPLAY
    tt-wth-doc.fact-date
    tt-wth-doc.doc-code
    tt-wth-doc.doc-date
    tt-wth-doc.shift-num
    tt-wth-doc.shift-name
    tt-wth-doc.shift-date
    tt-wth-doc.obj-code
    tt-wth-doc.obj-type
    tt-wth-doc.bef-sum
    tt-wth-doc.aft-sum
    tt-wth-doc.fact-sum
    tt-wth-doc.operator
    tt-wth-doc.deliver
    tt-wth-doc.receiver
    tt-wth-doc.inv-prs4
    tt-wth-doc.inv-prs5
    WITH FRAME Dialog-Frame.
    IF par-mode = 'ДОБАВЛЕНИЕ':U OR
        par-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
      IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
        ENABLE
        tt-wth-doc.doc-date
        b-add
        b-del
        b-chg when Not tt-wth-doc.auto-fill
        b-quit
        WITH FRAME Dialog-Frame.
        HIDE
        tt-wth-doc.fact-date IN FRAME Dialog-Frame
        tt-wth-doc.aft-sum  IN FRAME Dialog-Frame
        tt-wth-doc.fact-sum  IN FRAME Dialog-Frame
        .
      END.
      ELSE DO:
           b-exit:label = "&Выход".
        IF tt-wth-doc.status_ = 'накл':U      THEN DO:
            ENABLE
            tt-wth-doc.doc-date
            b-add
            b-del
            b-chg when Not tt-wth-doc.auto-fill
            WITH FRAME Dialog-Frame.
            HIDE
            b-quit
            tt-wth-doc.fact-date IN FRAME Dialog-Frame
            tt-wth-doc.fact-sum  IN FRAME Dialog-Frame
                        tt-wth-doc.aft-sum  IN FRAME Dialog-Frame
            .
        END.
        ELSE IF tt-wth-doc.status_ = 'разрешен':U THEN DO:
          HIDE
          tt-wth-doc.fact-date
          IN FRAME Dialog-Frame.
          ENABLE
          tt-wth-doc.aft-sum
          b-chg when Not tt-wth-doc.auto-fill
          WITH FRAME Dialog-Frame.
        END.
      END.
      ENABLE
      tt-wth-doc.operator
      tt-wth-doc.deliver
      tt-wth-doc.receiver
      tt-wth-doc.inv-prs4
      tt-wth-doc.inv-prs5
      b-person1
      b-person2
      b-person3
      b-person4
      b-person5
      B-exit
      b-lookup
      WITH FRAME Dialog-Frame.
      HIDE
      b-prev IN FRAME Dialog-Frame
      B-Next IN FRAME Dialog-Frame
      .
    END.
    ELSE IF par-mode = 'ПРОСМОТР':U  THEN DO:
      assign
      b-quit:label = "&Выход"
      b-quit:col = 1
      .
      ENABLE
      B-Prev
      B-Next
      b-quit
      WITH FRAME Dialog-Frame.
      HIDE
      b-exit
      B-person1 IN FRAME Dialog-Frame
      B-person2  IN FRAME Dialog-Frame
      B-person3 IN FRAME Dialog-Frame
      B-person4 IN FRAME Dialog-Frame
      B-person5 IN FRAME Dialog-Frame
      tt-wth-doc.fact-date IN FRAME Dialog-Frame
      .
    END.
    ENABLE
    b-help
    br-lines
    b-lookup
    b-hist when par-mode <> 'ДОБАВЛЕНИЕ':U
    b-chk when tt-wth-doc.auto-fill
    WITH FRAME Dialog-Frame.
    run control-peresort(output var-peresort) no-error.
    run lock-peresort(input var-peresort) no-error.
    OPEN QUERY BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,              EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK,              EACH buf_wth-place WHERE buf_wth-place.obj-type = buf_wth-line.obj-type AND buf_wth-place.obj-code = buf_wth-line.obj-code AND buf_wth-place.w-p-code = buf_wth-line.w-p-code  NO-LOCK.
    REPOSITION br-lines TO ROW 1 NO-ERROR.
    APPLY "ENTRY":U TO br-lines IN FRAME Dialog-Frame.
    APPLY "VALUE-CHANGED":U TO br-lines IN FRAME Dialog-Frame.
    parext-doc-name = ENTRY(LOOKUP(parext-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u) no-error.
    assign
    FRAME Dialog-Frame :TITLE = SUBSTITUTE("Инвентаризационная ведомость движения материальных ценностей № &1  - &2"
                                             ,tt-wth-doc.doc-code
                                             ,CAPS( parext-doc-name )).
    VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-add :
DEFINE VARIABLE loc-ref-list as character no-undo .
DEFINE VARIABLE valid-chk-type-list as character no-undo .
DEFINE VARIABLE valid-w-p-code like ub.wth-place.w-p-code .
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE ii-ok as integer no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-line-rec as recid no-undo .
define buffer what_chk-doc  for ub.chk-doc .
define buffer buf_chk-doc  for ub.chk-doc .
define buffer cash_wth-place for ub.wth-place.
run proc-save-doc(no) No-ERROR.
if error-status:error
or return-value = 'error'
then return error.
CASE tt-wth-doc.auto-fill:
  when no then do:
    assign
    v-doc-rec = recid(bf_wth-doc)
    v-line-rec = ?
    .
    run str/wth-inva.w (input parparentproc,
                    INPUT 'ДОБАВЛЕНИЕ':U,
                    input v-doc-rec,
                    input-output v-LINE-REC
                    ) no-error.
    if error-status:error then do:
      return 'error'.
    end.
 end.
 when yes then do:
    FIND FIRST what_chk-doc No-LOCK WHERE
               what_chk-doc.out-code = tt-wth-doc.doc-code No-ERROR.
    if available what_chk-doc then do:
      assign
      valid-chk-type-list = string(what_chk-doc.chk-type).
      FIND FIRST cash_wth-place No-LOCK WHERE
                 cash_Wth-place.obj-type = parobj-type AND
                 cash_Wth-place.obj-code = parobj-code AND
                 cash_wth-place.cash-desk = what_chk-doc.pay-desk No-ERROR.
      if not avail cash_wth-place then do:
        message
        "Не найдено МХ, соответствующее кассе, пробившей чеки, включенные в документ"
        view-as alert-box error .
        return 'error'.
      end.
      valid-w-p-code = cash_wth-place.w-p-code.
      run str/chk-docs.w (
                      input parparentproc
                     ,input 'b-sel,b-mark':U
                     ,input 'free':U
                     ,input ?
                     ,input parobj-type
                     ,input parobj-code
                     ,input '':U
                     ,input '':U
                     ,input 0
                     ,input ?
                     ,input ?
                     ,input what_chk-doc.chk-type
                     ,output loc-ref-list) no-error.
      if error-status:error then return 'error'.
    end.
    else do:
      assign
      valid-w-p-code = 0
      valid-chk-type-list = '7':U + chr(44) + '4':U.
      run str/chk-docs.w (
                     input parparentproc
                    ,input 'b-sel,b-mark':U
                    ,input 'free':U
                    ,input ?
                    ,input parobj-type
                    ,input parobj-code
                    ,input '':U
                    ,input '':U
                    ,input 0
                    ,input ?
                    ,input ?
                    ,input 0
                     ,output loc-ref-list) no-error.
      if error-status:error then return 'error'.
    end.
    if loc-ref-list = "":U then return.
  _ii:
  DO ii = 1 to num-entries(loc-ref-list):
  find first buf_chk-doc exclusive-lock where
                  recid(buf_chk-doc) = integer(entry(ii, loc-ref-list)) No-ERROR.
      if not avail buf_chk-doc or
        LOOKUP(string(buf_chk-doc.chk-type), valid-chk-type-list) = 0 then NEXT _ii.
      if tt-wth-doc.shift-date = ? then do:
        if buf_chk-doc.shift-date <> tt-wth-doc.doc-date then NEXT _ii.
      end.
      else do:
        if NOT (buf_chk-doc.shift-date = tt-wth-doc.shift-date AND
                buf_chk-doc.shift-num = tt-wth-doc.shift-num) then NEXT _ii.
      end.
      if avail(what_chk-doc) and buf_chk-doc.pay-desk <> what_chk-doc.pay-desk then NEXT _ii.
      run str/inc-wth1.p (
       buffer buf_chk-doc
      ,input 1
      ,input tt-wth-doc.doc-code
      ,input valid-w-p-code
      ,input 0
      ,input tt-wth-doc.ext-doc-type
      ,input buf_chk-doc.chk-type
      ,input no
      ) no-error .
      if error-status:error then NEXT _ii.
      ii-ok = ii-ok + 1.
  END.
  if ii - 1 <> ii-ok then do:
    message
    "Из выбранных Вами " (ii - 1) "чеков"
    "удалось включить в документ" ii-ok
    view-as alert-box WARNING.
  end.
  end.
END CASE.
FIND current bf_wth-doc EXCLUSIVE-LOCK.
run MyEnable in this-Procedure.
OPEN QUERY BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,              EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK,              EACH buf_wth-place WHERE buf_wth-place.obj-type = buf_wth-line.obj-type AND buf_wth-place.obj-code = buf_wth-line.obj-code AND buf_wth-place.w-p-code = buf_wth-line.w-p-code  NO-LOCK.
reposition br-lines to recid v-line-rec no-error.
apply "entry" to br-lines in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE VARIABLE loc-ref-list as character no-undo .
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-ok as integer no-undo.
define variable v-line-rec as recid no-undo .
DEFINE buffer buf_chk-doc for ub.chk-doc .
if not avail buf_wth-line then return no-apply.
  IF tt-wth-doc.status_ <> 'накл':U THEN DO:
    MESSAGE "Документ закрыт - удалять матценности нельзя!"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
END.
CASE tt-wth-doc.auto-fill:
  when no then do:
    MESSAGE
    "Вы уверены, что хотите удалить строку?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF glog <> YES THEN DO:
      RETURN NO-APPLY.
    END.
    ASSIGN v-line-rec = RECID( buf_wth-line).
    Erase-Block:
    DO ON ERROR UNDO Erase-Block, LEAVE Erase-Block
      ON STOP  UNDO Erase-Block, LEAVE Erase-Block :
      FIND FIRST buf_wth-line EXCLUSIVE-LOCK WHERE
                        RECID( buf_wth-line ) = v-line-rec.
      run str/wth-lnv1.p (
                       input-output v-line-rec
                      ,input  'удаление':U
                      ,input buf_wth-line.doc-code
                      ,input buf_wth-line.wth-code
                      ,input buf_wth-line.w-p-code
                      ,input (- buf_wth-line.bef-sum)
                      ,input (- buf_wth-line.aft-sum)
                      ,input table tt-par-dtl
                      ,input glog
                      ) .
      DELETE buf_wth-line.
    END.
  end.
  when yes then do:
    run str/chk-docs.w (
                   input parparentproc
                  ,input 'b-sel,b-mark':U
                  ,input 'out-code':U
                  ,input ?
                  ,input parobj-type
                  ,input parobj-code
                  ,input tt-wth-doc.doc-code
                  ,input ''
                  ,input 0
                  ,input ?
                  ,input ?
                  ,input 0
                  ,output loc-ref-list) no-error.
    if error-status:error then return error.
    if loc-ref-list = '':U then return.
     _ii:
  DO ii = 1 to num-entries(loc-ref-list):
  find first buf_chk-doc exclusive-lock where
                  recid(buf_chk-doc) = integer(entry(ii, loc-ref-list)) No-ERROR.
      if not avail buf_chk-doc or
        buf_chk-doc.out-code <> tt-wth-doc.doc-code then NEXT _ii.
      run str/inc-wth1.p (
        buffer buf_chk-doc
      ,input - 1
      ,input tt-wth-doc.doc-code
      ,input 0
      ,input 0
      ,input tt-wth-doc.ext-doc-type
      ,input buf_chk-doc.chk-type
      ,input no
      ) no-error .
      if error-status:error then NEXT _ii.
      ii-ok = ii-ok + 1.
  END.
  if ii - 1 <> ii-ok then do:
    message
    "Из выбранных Вами " (ii - 1) "чеков"
    "удалось удалить из документа" ii-ok
    view-as alert-box WARNING.
  end.
  end.
END CASE.
assign
tt-wth-doc.doc-sum = bf_wth-doc.doc-sum
tt-wth-doc.fact-sum = bf_wth-doc.fact-sum
tt-wth-doc.bef-sum = bf_wth-doc.bef-sum
tt-wth-doc.aft-sum = bf_wth-doc.aft-sum
.
RUN Myenable in this-procedure .
END PROCEDURE.
PROCEDURE proc-save-doc :
 define input parameter parlines-exist as logical no-undo .
 define variable v-doc-rec as recid no-undo .
 define variable varcli-name as character no-undo .
 IF par-mode = 'ПРОСМОТР':U THEN DO:
    RETURN NO-APPLY.
 END.
 assign
 tt-wth-doc.doc-date frame Dialog-Frame
 tt-wth-doc.operator
 tt-wth-doc.deliver
 tt-wth-doc.receiver
 tt-wth-doc.inv-prs4
 tt-wth-doc.inv-prs5
 .
run trg/wth-inv2.p (
                 input no
                ,input tt-wth-doc.doc-code
                ,input tt-wth-doc.host-code
                ,input tt-wth-doc.obj-type
                ,input tt-wth-doc.obj-code
                ,input tt-wth-doc.operator
                ,input tt-wth-doc.deliver
                ,input tt-wth-doc.receiver
                ,input tt-wth-doc.inv-prs4
                ,input tt-wth-doc.inv-prs5
                ,input tt-wth-doc.auto-fill
                ,input parlines-exist
                ,input no
                ,output varcli-name) no-error.
if error-status:error then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      return 'error'.
    end.
    hh = hh:next-sibling.
  end.
end.
end.
 v-doc-rec = recid(bf_wth-doc).
  run str/wth-inv1.p (
                  input no
                 ,input-output v-doc-rec
                 ,input        'ИЗМЕНЕНИЕ':U
                 ,input tt-wth-doc.doc-code
                 ,input tt-wth-doc.host-code
                 ,input tt-wth-doc.obj-type
                 ,input tt-wth-doc.obj-code
                 ,input tt-wth-doc.doc-date
                 ,input tt-wth-doc.fact-date
                 ,input tt-wth-doc.shift-date
                 ,input tt-wth-doc.shift-num
                 ,input tt-wth-doc.shift-name
                 ,input tt-wth-doc.operator
                 ,input tt-wth-doc.deliver
                 ,input tt-wth-doc.receiver
                 ,input tt-wth-doc.inv-prs4
                 ,input tt-wth-doc.inv-prs5
                 ,input tt-wth-doc.auto-fill
                 ,input tt-wth-doc.bef-sum
                 ,input tt-wth-doc.aft-sum
                 ,input tt-wth-doc.PS
                 ,input tt-wth-doc.status_
                 ,input parlines-exist
                 ) no-error .
    IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> '':U then do:
      CASE return-value:
        when "operator":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.operator IN FRAME Dialog-Frame.
        end.
        when "aft-sum":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.aft-sum IN FRAME Dialog-Frame.
        end.
        when "deliver":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.deliver IN FRAME Dialog-Frame.
        end.
        when "receiver":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.receiver IN FRAME Dialog-Frame.
        end.
        when "inv-prs4":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.inv-prs4 IN FRAME Dialog-Frame.
        end.
        when "inv-prs5":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.inv-prs5 IN FRAME Dialog-Frame.
        end.
        when "b-add":U then do:
          APPLY "ENTRY":U TO b-add IN FRAME Dialog-Frame.
        end.
      END CASE.
    end.
    RETURN error.
  END.
END PROCEDURE.
PROCEDURE reposition-wth-doc :
define input parameter p-direction as character no-undo .
define variable v-new-wth-doc-recid as recid no-undo .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-wth-doc in p-call-prog
      (input  p-direction
      ,output v-new-wth-doc-recid
      ).
    if v-new-wth-doc-recid <> ?
    then do:
      define buffer buf_wth-doc for ub.wth-doc .
      find first buf_wth-doc no-lock
        where recid(buf_wth-doc) = v-new-wth-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-wth-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов МЦ не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.
