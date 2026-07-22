define input parameter ParParentProc  as widget-handle no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter par-list-trn   as character no-undo .
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Генерация финансовых обязательств и платежей".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table cli-list no-undo like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table cli-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info3 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table tt-add no-undo like ub.add-doc.
define temp-table tt-trn no-undo like ub.trn-doc.
define temp-table tt-ord no-undo like ub.ord-doc.
define temp-table tt-rcv no-undo like ub.ord-doc-rcv.
define temp-table c-tt-trn no-undo like ub.c-trn-doc.
define variable v-type-trn-doc as character no-undo .
DEFINE BUTTON b-exec
     LABEL "В&ыполнить"
     SIZE 15 BY 1.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 12 BY 1.
DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.
DEFINE VARIABLE res AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 85 BY 7.46 NO-UNDO.
DEFINE VARIABLE date-end AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.38 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-10 AS CHARACTER FORMAT "X(256)":U INITIAL "Обработать накладные по :"
      VIEW-AS TEXT
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-11 AS CHARACTER FORMAT "X(256)":U INITIAL "Формировать:"
      VIEW-AS TEXT
     SIZE 12.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-12 AS CHARACTER FORMAT "X(256)":U INITIAL "Обсчитывать документы:"
      VIEW-AS TEXT
     SIZE 29.63 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-13 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата ФО:"
      VIEW-AS TEXT
     SIZE 8.5 BY 1 TOOLTIP "Дата док. для ФО" NO-UNDO.
DEFINE VARIABLE FILL-IN-14 AS CHARACTER FORMAT "X(256)":U INITIAL "Расчет налогов по ставкам:"
      VIEW-AS TEXT
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE v-info AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE R-cons AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Совокупно", 1,
"Раздельно", 2
     SIZE 33.5 BY 1 TOOLTIP "раздельно - по каждой накладной отдельное ФО" NO-UNDO.
DEFINE VARIABLE R-nalog AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Совокупно", 1,
"Раздельно", 2
     SIZE 33.5 BY 1 TOOLTIP "раздельно - по каждой ставке налога отдельное ФО" NO-UNDO.
DEFINE VARIABLE R-trn AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По заказам", 4,
"По поставкам заказа", 5,
"По поставке (приходные накладные)", 1,
"По реализации (расходные накладные)", 2,
"По доп.расходам", 7,
"По всем накладным", 3,
"По спецификации", 6
     SIZE 38.5 BY 5.25 TOOLTIP "Генерация по типу" NO-UNDO.
DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Сегодня", 1,
"99/99/9999", 2
     SIZE 34 BY 1 TOOLTIP "Дата док. для ФО" NO-UNDO.
DEFINE VARIABLE T-adm AS LOGICAL INITIAL no
     LABEL "Не учитывать флаги генерации"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-exec AT ROW 1 COL 13
     B-help AT ROW 1 COL 73
     i-exit AT ROW 1.13 COL 13.25 WIDGET-ID 2
     date-end AT ROW 2.25 COL 26 COLON-ALIGNED NO-LABEL
     T-adm AT ROW 2.25 COL 41
     R-trn AT ROW 3.5 COL 14 NO-LABEL
     R-cons AT ROW 8.96 COL 31 NO-LABEL
     R-nalog AT ROW 9.96 COL 31 NO-LABEL
     RADIO-SET-1 AT ROW 11 COL 31 NO-LABEL
     res AT ROW 14.92 COL 1 NO-LABEL
     FILL-IN-10 AT ROW 2.21 COL 1 NO-LABEL
     FILL-IN-11 AT ROW 3.25 COL 1 NO-LABEL
     FILL-IN-12 AT ROW 8.96 COL 1 NO-LABEL
     FILL-IN-14 AT ROW 9.96 COL 1 NO-LABEL
     FILL-IN-13 AT ROW 11 COL 1 NO-LABEL
     v-info AT ROW 13.92 COL 1 NO-LABEL
     SPACE(5.00) SKIP(7.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Генерация расходных финансовых обязательств"
         CANCEL-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       T-adm:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON ALT-CTRL-A OF FRAME Dialog-Frame
ANYWHERE DO:
  if t-adm :visible = false then do:
      view t-adm in frame Dialog-Frame.
      t-adm = yes.
      enable t-adm with frame Dialog-Frame.
      display t-adm with frame Dialog-Frame.
  end.
  else do:
      t-adm = no.
      display t-adm with frame Dialog-Frame.
      hide t-adm in frame Dialog-Frame.
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exec IN FRAME Dialog-Frame
DO:
  assign
  date-end R-cons r-trn radio-set-1 r-nalog  t-adm
  no-error.
  define variable v-calc as integer no-undo .
  define buffer buf_add-doc     for ub.add-doc.
  define buffer buf_trn-doc     for ub.trn-doc.
  define buffer buf_ord-doc     for ub.ord-doc.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_c-trn-doc   for ub.c-trn-doc.
  define buffer buf_contract    for ub.contract.
  for each tt-add : delete tt-add. end.
  for each tt-rcv : delete tt-rcv. end.
  for each tt-ord : delete tt-ord. end.
  for each tt-trn : delete tt-trn. end.
  for each c-tt-trn : delete c-tt-trn. end.
define variable v-1 as integer   no-undo .
v-1 = num-entries(par-list-trn) .
  if par-list-trn <> ? then do:
     r-trn = ? .
    repeat v-calc = 1 to v-1 :
          if p-mode = "" then do:
            find first buf_trn-doc no-lock where recid(buf_trn-doc) = integer (entry(v-calc,par-list-trn)) no-error .
            if available buf_trn-doc then do:
              create tt-trn.
              BUFFER-COPY buf_trn-doc to tt-trn.
            end.
          end.
          if p-mode = "del" then do:
            find first buf_c-trn-doc no-lock where recid(buf_c-trn-doc) = integer (entry(v-calc,par-list-trn)) no-error .
            if available buf_c-trn-doc then do:
              create c-tt-trn.
              BUFFER-COPY buf_c-trn-doc to c-tt-trn.
            end.
          end.
          if p-mode = "order" then do:
            find first buf_ord-doc no-lock where recid(buf_ord-doc) = integer(entry(v-calc,par-list-trn)) no-error .
            if available buf_ord-doc then do:
              create tt-ord.
              BUFFER-COPY buf_ord-doc to tt-ord.
            end.
          end.
          if p-mode = "rcv" then do:
            find first buf_ord-doc-rcv no-lock where recid(buf_ord-doc-rcv) = integer(entry(v-calc,par-list-trn)) no-error .
            if available buf_ord-doc-rcv then do:
              create tt-rcv.
              BUFFER-COPY buf_ord-doc-rcv to tt-rcv.
            end.
          end.
          if p-mode = "add" then do:
            find first buf_add-doc no-lock where recid(buf_add-doc) = integer(entry(v-calc,par-list-trn)) no-error .
            if available buf_add-doc then do:
              create tt-add.
              BUFFER-COPY buf_add-doc to tt-add.
            end.
          end.
    end.
  end.
  run update-res no-error .
  if error-status :error then do:  end.
if p-mode = "order" then do:
  run str/gen-flo.p (
    input parParentProc ,
    input par-host-code ,
    input date-end   ,
    input ?  ,
    input R-cons     ,
    input r-nalog ,
    input table tt-ord ,
    input-output res,
    input radio-set-1,
    input  t-adm ,
    input  'рас':U
    ) no-error .
end.
if p-mode = "rcv" then do:
  run str/gen-flrv.p (
    input parparentproc ,
    input par-host-code ,
    input date-end   ,
    input ?  ,
    input r-cons     ,
    input r-nalog ,
    input table tt-rcv ,
    input-output res,
    input radio-set-1,
    input  t-adm
    ) no-error .
end.
if p-mode = "add" then do:
  run str/gen-flad.p (
    input parparentproc ,
    input par-host-code ,
    input date-end   ,
    input ?  ,
    input r-cons     ,
    input r-nalog ,
    input table tt-add ,
    input-output res,
    input radio-set-1,
    input  t-adm
    ) no-error .
end.
if p-mode = "" then do:
  if r-trn = 0 then r-trn = ? .
  IF r-trn = 3 THEN DO:
      run str/gen-flp.p (
        INPUT parParentProc ,
        input par-host-code ,
        input date-end   ,
        input 1  ,
        input R-cons     ,
        INPUT r-nalog ,
        input table tt-trn ,
        input-output res,
        input radio-set-1,
        INPUT  t-adm
        ) no-error .
      run str/gen-flp.p (
          INPUT parParentProc ,
          input par-host-code ,
          input date-end   ,
          input 2  ,
          input R-cons     ,
          INPUT r-nalog ,
          input table tt-trn ,
          input-output res,
          input radio-set-1,
          INPUT  t-adm
          ) no-error .
  END.
  IF r-trn = ? OR  r-trn = 1 OR r-trn = 2 THEN DO:
      run str/gen-flp.p (
          INPUT parParentProc ,
          input par-host-code ,
          input date-end   ,
          input r-trn  ,
          input R-cons     ,
          INPUT r-nalog ,
          input table tt-trn ,
          input-output res ,
          input radio-set-1,
          INPUT  t-adm
          ) no-error .
  END.
    if r-trn = 4 then do:
      run str/gen-flo.p (
        INPUT parParentProc ,
        input par-host-code ,
        input date-end   ,
        input 4  ,
        input R-cons     ,
        INPUT r-nalog ,
        input table tt-ord ,
        input-output res,
        input radio-set-1,
        INPUT  t-adm,
        input 'рас':U
        ) no-error .
    end.
    if r-trn = 5 then do:
      run str/gen-flrv.p (
        INPUT parParentProc ,
        input par-host-code ,
        input date-end   ,
        input 5  ,
        input R-cons     ,
        INPUT r-nalog ,
        input table tt-rcv ,
        input-output res,
        input radio-set-1,
        INPUT  t-adm
        ) no-error .
    end.
    if r-trn = 7 then do:
      run str/gen-flad.p (
        INPUT parParentProc ,
        input par-host-code ,
        input date-end   ,
        input 7  ,
        input R-cons     ,
        input r-nalog ,
        input table tt-add ,
        input-output res,
        input radio-set-1,
        input  t-adm
        ) no-error .
    end.
    if r-trn = 6 then do:
      run str/gen-flsp.p (
          INPUT parParentProc ,
          input par-host-code ,
          input date-end   ,
          input radio-set-1,
          input "",
          input-output res
      ) no-error .
    end.
    if error-status :error then res = res + chr(10) + error-status :get-message(1) .
end.
IF r-trn <= 3  THEN DO:
    if p-mode = "del":u or par-list-trn = ?  then do:
      res = res +  chr(10) + "--- ПО УДАЛЕННЫМ ДОКУМЕНТАМ ( 2 прохода ) ---".
      IF r-trn = 3 THEN DO:
          run str/gen-flpd.p (
                INPUT parParentProc ,
                input par-host-code ,
                input date-end   ,
                input 1  ,
                input R-cons     ,
                INPUT r-nalog ,
                input table c-tt-trn ,
                input-output res ,
                input radio-set-1
                ) no-error .
          if error-status :error then res = res + chr(10) + error-status :get-message(1) .
          run str/gen-flpd.p (
                INPUT parParentProc ,
                input par-host-code ,
                input date-end   ,
                input 2  ,
                input R-cons     ,
                INPUT r-nalog ,
                input table c-tt-trn ,
                input-output res ,
                input radio-set-1
                ) no-error .
          if error-status :error then res = res + chr(10) + error-status :get-message(1) .
          run str/gen-flpr.p (
                INPUT parParentProc ,
                input par-host-code ,
                input date-end   ,
                input 1  ,
                input R-cons     ,
                INPUT r-nalog ,
                input table c-tt-trn ,
                input-output res ,
                input radio-set-1
                ) no-error .
          if error-status :error then res = res + chr(10) + error-status :get-message(1) .
          run str/gen-flpr.p (
                INPUT parParentProc ,
                input par-host-code ,
                input date-end   ,
                input 2  ,
                input R-cons     ,
                INPUT r-nalog ,
                input table c-tt-trn ,
                input-output res ,
                input radio-set-1
                ) no-error .
                if error-status :error then res = res + chr(10) + error-status :get-message(1) .
      END.
      if r-trn = 1 or r-trn = 2 then do :
          run str/gen-flpd.p (
              INPUT parParentProc ,
              input par-host-code ,
              input date-end   ,
              input r-trn  ,
              input R-cons     ,
              INPUT r-nalog ,
              input table c-tt-trn ,
              input-output res,
              input radio-set-1
              ) no-error .
              if error-status :error then res = res + chr(10) + error-status :get-message(1) .
          run str/gen-flpr.p (
              INPUT parParentProc ,
              input par-host-code ,
              input date-end   ,
              input r-trn  ,
              input R-cons     ,
              INPUT r-nalog ,
              input table c-tt-trn ,
              input-output res ,
              input radio-set-1
              ) no-error .
              if error-status :error then res = res + chr(10) + error-status :get-message(1) .
      END.
    end.
end.
display res with frame Dialog-Frame .
END.
ON ENTRY OF date-end IN FRAME Dialog-Frame
DO:
  RADIO-SET-1:RADIO-BUTTONS = "Сегодня,1," + ( INPUT date-end ) + ",2 ".
  DISPLAY RADIO-SET-1 WITH FRAME Dialog-Frame .
END.
ON LEAVE OF date-end IN FRAME Dialog-Frame
DO:
  ASSIGN date-end.
  RADIO-SET-1:RADIO-BUTTONS = "Сегодня,1," + STRING(date-end,"99/99/9999") + ",2" .
  DISPLAY RADIO-SET-1 WITH FRAME Dialog-Frame .
END.
ON return OF date-end IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  date-end:handle ) .
  return no-apply .
END.
ON return OF R-cons IN FRAME Dialog-Frame
DO:
     run next-focus in this-procedure  (input  R-cons:handle ) .
  return no-apply .
END.
ON return OF R-nalog IN FRAME Dialog-Frame
DO:
     run next-focus in this-procedure  (input  R-nalog:handle ) .
  return no-apply .
END.
ON return OF R-trn IN FRAME Dialog-Frame
DO:
     run next-focus in this-procedure  (input  R-trn:handle ) .
  return no-apply .
END.
ON return OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  RADIO-SET-1:handle ) .
 return no-apply .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-end in frame Dialog-Frame
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
on delete-character of date-end in frame Dialog-Frame
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
on ctrl-d of date-end in frame Dialog-Frame
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
on ctrl-b of date-end in frame Dialog-Frame
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
on ctrl-e of date-end in frame Dialog-Frame
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
on ctrl-f of date-end in frame Dialog-Frame
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
  define MENU m-ed-date9
    MENU-ITEM m-ed-date9-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date9-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date9-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date9-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-end :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date-end :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date9 :HANDLE
      date-end :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle9 as handle no-undo .
  assign
    v-label-handle9 = date-end :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle9)
  then do:
    if v-label-handle9 :tooltip = ""
    or v-label-handle9 :tooltip = ?
    then do:
      assign
        v-label-handle9 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date9-1 in menu m-ed-date9 DO:
    apply "ctrl-b":U to date-end in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-2 in menu m-ed-date9 DO:
    apply "ctrl-d":U to date-end in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-3 in menu m-ed-date9 DO:
    apply "ctrl-e":U to date-end in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-4 in menu m-ed-date9 DO:
    apply "ctrl-f":U to date-end in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable v-right-supp as logical no-undo .
  v-right-supp = true .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-supp':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-right-supp
    )  .
end.
if v-right-supp = false then return .
date-end = date(cur-time-date()) .
v-type-trn-doc =  'ee,es,re,rs,we,wm,pc,':U + 'ie,ep,':U  + 'vt,ap,mp,vp,':U.
  if par-list-trn = ? then
  RUN enable_UI.
  else
  RUN enable_my.
  WAIT-FOR GO OF FRAME Dialog-Frame focus date-end .
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_my :
 do
 on error undo, return error return-value
 :
  v-info = "Выбрано " + string( num-entries( par-list-trn)  ) + " документов " .
  DISPLAY r-nalog  R-cons res FILL-IN-10 FILL-IN-11 FILL-IN-12 FILL-IN-14 v-info
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-exec B-help R-cons res r-nalog i-exit
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY date-end R-trn R-cons R-nalog RADIO-SET-1 res FILL-IN-10 FILL-IN-11
          FILL-IN-12 FILL-IN-14 FILL-IN-13 v-info
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-exec B-help i-exit date-end R-trn R-cons R-nalog RADIO-SET-1
         res FILL-IN-13
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE next-focus :
 do
 on error undo, return error return-value
 :
  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .
  assign
    l-apply-entry =   true
  .
  do with frame Dialog-Frame :
    if  date-end:handle   = p-widget-handle then do:  if r-trn:sensitive then do:  apply "entry":u to r-trn .   return . end. end.
    if  r-trn:handle  = p-widget-handle then do:              if r-cons:sensitive then do:     apply "entry":u to r-cons .      return . end. end.
    if  r-cons:handle     = p-widget-handle then do:  if r-nalog:sensitive then do:     apply "entry":u to r-nalog .     return . end. end.
    if  r-nalog:handle     = p-widget-handle then do:  if radio-set-1:sensitive then do:     apply "entry":u to radio-set-1 .     return . end. end.
    if  radio-set-1:handle     = p-widget-handle then do:  if b-exec:sensitive then do:     apply "entry":u to b-exec .      return . end. end.
  end.
 end.
END PROCEDURE.
PROCEDURE update-res :
 do
 on error undo, return error return-value
 :
 define variable v-count as integer no-undo .
 assign frame Dialog-Frame
  date-end
  R-cons
  r-nalog
  r-trn
  no-error .
if not  error-status :error  then do:
    res =  "" .
    res = "ВЫБРАНО : " + chr(10) .
    res = res + "Условие оплаты по договору : " + chr(10) + radio-label( string(r-trn) , r-trn:radio-buttons) .
end.
else do:
    res =  "" .
    r-trn = 0 .
end.
for each tt-trn :
   if lookup( tt-trn.ext-doc-type , v-type-trn-doc) = 0 then do:
      res = res + "неверный тип " + func-get-name-from-ext-type(tt-trn.ext-doc-type,no) + " -   накладную " + tt-trn.doc-code + " пропускаем "  + chr(10) .
   end.
end.
    display res with frame Dialog-Frame .
  end.
END PROCEDURE.
