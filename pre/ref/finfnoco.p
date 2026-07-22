block-level on error undo, throw.
DEFINE TEMP-TABLE tt0-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0c-fin-doc NO-UNDO LIKE ub.fin-doc.
define temp-table tt-fin-doc no-undo like ub.fin-doc.
define temp-table ttc-fin-doc no-undo like ub.fin-doc.
define temp-table nc-tt-fin-doc no-undo like ub.fin-doc.
define temp-table a0-tt-fin-doc no-undo like ub.fin-doc.
define temp-table tt0-fin-doc-attr no-undo like ub.fin-doc-attr.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT     PARAMETER par-call-handle  AS HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-doc-rec as recid no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-fin-doc-type     like ub.fin-doc.fin-doc-type no-undo .
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter p-obj-type  like ub.fin-doc.obj-type no-undo .
define input parameter p-obj-code  like ub.fin-doc.obj-code no-undo .
define input parameter p-contract-code like ub.fin-doc.contract-code no-undo .
define input parameter p-ob-doc-code like ub.fin-ob.doc-code no-undo .
define input parameter p-payer-type like ub.fin-doc.payer-type no-undo .
define input parameter p-payer-code like ub.fin-doc.payer-code no-undo .
define input parameter p-payer-code-schet like ub.fin-doc.payer-code-schet no-undo.
define input parameter p-receiver-type like ub.fin-doc.receiver-type no-undo .
define input parameter p-receiver-code like ub.fin-doc.receiver-code no-undo .
define input parameter p-receiver-code-schet like ub.fin-doc.receiver-code-schet no-undo.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo .
define input parameter p-cor-acc like ub.fin-doc.cor-acc no-undo.
define input parameter p-cor-acc1 like ub.fin-doc.cor-acc1 no-undo.
define input parameter p-an-uchet-code like ub.fin-doc.an-uchet-code no-undo.
define input parameter p-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo.
define input parameter p-cashbookId like ub.fin-doc.CashBookId no-undo .
define input parameter p-cashier as character no-undo .
define INPUT-OUTPUT parameter table for tt0-fin-doc.
define INPUT-OUTPUT parameter table for ttc-fin-doc.
define OUTPUT parameter table for tt0-fin-doc-attr.
define output parameter p-limit-access as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: 5ee64da48eb6, 3419, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:30 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finfnoco.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finfnoco.p $":U .
define variable vss-description as character no-undo init "Заполнение и проверка временной таблицы платежа".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-labels no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
field f_update as logical
field f_can_update as logical
field f_parent as character
field f_visible as logical
field f_root as character
index iu f_update
index ivisible  f_visible
index iparent f_root f_parent
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
procedure tempchgs-create-lable-record :
define input parameter p-t_name as character no-undo .
define input parameter p-f_name as character no-undo .
define input parameter p-l_name as character no-undo .
define input parameter p-f_update as logical no-undo .
define input parameter p-f_parent as character no-undo .
define input parameter p-f_visible as logical no-undo .
define buffer buf_temp-labels for temp-labels.
  do
  on error undo, return error
  :
     find first buf_temp-labels where
              buf_temp-labels.t_name = p-t_name
          and buf_temp-labels.f_name = p-f_name no-error.
     if not available buf_temp-labels then do:
      create buf_temp-labels.
      assign
      buf_temp-labels.t_name = p-t_name
      buf_temp-labels.f_name = p-f_name
      buf_temp-labels.l_name = p-l_name
      .
     end.
     assign
     buf_temp-labels.f_can_update = p-f_update
     buf_temp-labels.f_parent = p-f_parent
     buf_temp-labels.f_visible = p-f_visible
     buf_temp-labels.f_root = (if p-f_parent = '':U then p-f_name else p-f_parent)
     buf_temp-labels.num_ = 0
     .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile: findocip.i $ $Revision: ff8019e24d02, 2996, rls $".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure get-single-schet :
  define input parameter p-host-code like ub.sysconf.host-code no-undo .
  define input parameter p-cli-type like ub.fin-schet.cli-type no-undo .
  define input parameter p-cli-code like ub.fin-schet.cli-code no-undo .
  define input parameter p-curr-code like ub.fin-schet.curr-code no-undo .
  define output parameter p-recid-schet as recid no-undo .
  define output parameter p-recid-bank as recid no-undo .
  define variable ii as integer no-undo .
  define buffer buf_fin-schet for ub.fin-schet.
  define buffer buf_fin-bank  for ub.fin-bank.
  do
    on error undo, return error
    :
    for each buf_fin-schet no-lock where
      buf_fin-schet.host-code = p-host-code
      AND buf_fin-schet.cli-type = p-cli-type
      AND buf_fin-schet.cli-code = p-cli-code
      AND buf_fin-schet.curr-code = p-curr-code:
      if buf_fin-schet.status_ = 'тек':U then
      do:
        find first buf_fin-bank no-lock where
          buf_fin-bank.host-code = p-host-code
          AND buf_fin-bank.code-bank = buf_fin-schet.code-bank no-error .
        if avail buf_fin-bank and buf_fin-bank.status_ = 'тек':U then
        do:
          assign
            p-recid-schet = recid(buf_fin-schet)
            p-recid-bank  = recid(buf_fin-bank)
            .
          assign
            ii = ii + 1
            .
        end.
      end.
      if ii > 1 then
      do:
        assign
          p-recid-schet = ?
          p-recid-bank  = ?
          .
      end.
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes6 as character no-undo .
    define variable v-param-type6 as character no-undo .
    define variable v-value-character6 as INTEGER no-undo .
    define variable v-value-date6 as date no-undo .
    define variable v-value-decimal6 as decimal no-undo .
    define variable v-value-integer6 AS integer no-undo .
    define variable v-value-logical6 AS LOGICAL no-undo .
    define variable v-tth6 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character6
        ,output v-value-date6
        ,output v-value-decimal6
        ,output v-value-integer6
        ,output v-value-logical6
        ,output v-param-type6
        ,INPUT-OUTPUT table-handle v-tth6
        ) no-error .
    if error-status :error then do:
      delete object v-tth6.
      v-mes6 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes6.
    end.
    delete object v-tth6.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer6)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess7 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess7
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-farh as handle no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fd-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-label = "Дата смены"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-num':U then do:     assign     p-label = "П.смены"     p-type = 'I':U      p-format = "99"     p-label = "П.смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-name':U then do:     assign     p-label = "№ смены"     p-type = 'C':U      p-format = "X(2)"     p-label = "№ смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'barcode':U then do:     assign     p-label = "Штрих-код"     p-type = 'C':U      p-format = "X(20)"     p-label = "Штрих-код"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'lockid':U then do:     assign     p-label = "ID блокировки чека"     p-type = 'C':U      p-format = "X(2)"     p-label = "ID блокировки чека"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cover_sheet':U then do:     assign     p-label = "Разбиение по номиналам"     p-type = 'C':U      p-format = "X(4000)"     p-label = "Разбиение по номиналам"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'pre-vedom':U then do:     assign     p-label = "Атрибут для препроводительной ведомости"     p-type = 'C':U      p-format = "X(256)"     p-label = "Атрибут для препроводительной ведомости"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'contr-kb':U then do:     assign     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-type = 'I':U      p-format = ">>>9"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fd-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-tooltip = "Дата смены"     p-label = "Дата смены" .   end.
            when 'shift-num':U then do:     assign     p-tooltip = "П.смены"     p-label = "П.смены" .   end.
            when 'shift-name':U then do:     assign     p-tooltip = "№ смены"     p-label = "№ смены" .   end.
            when 'barcode':U then do:     assign     p-tooltip = "Штрих-код"     p-label = "Штрих-код" .   end.
            when 'lockid':U then do:     assign     p-tooltip = "ID блокировки чека"     p-label = "ID блокировки чека" .   end.
            when 'cover_sheet':U then do:     assign     p-tooltip = "Разбиение по номиналам"     p-label = "Разбиение по номиналам" .   end.
            when 'pre-vedom':U then do:     assign     p-tooltip = "Атрибут для препроводительной ведомости"     p-label = "Атрибут для препроводительной ведомости" .   end.
            when 'contr-kb':U then do:     assign     p-tooltip = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr  exclusive-lock  where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code    = p-host-code
      AND buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_fin-doc-attr then do:
      create buf_fin-doc-attr.
      assign
      buf_fin-doc-attr.attr-code    = p-attr-code
      buf_fin-doc-attr.attr-value   = p-attr-value
      buf_fin-doc-attr.host-code    = p-host-code
      buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
       assign
       buf_fin-doc-attr.attr-value = p-attr-value.
  end.
 end.
end procedure.
procedure fd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error .
    if  available buf_fin-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure fd-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
  define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
  define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-doc-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fd-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-news = no.   end.
            when 'shift-num':U then do:     assign     p-news = no.   end.
            when 'shift-name':U then do:     assign     p-news = no.   end.
            when 'barcode':U then do:     assign     p-news = no.   end.
            when 'lockid':U then do:     assign     p-news = no.   end.
            when 'cover_sheet':U then do:     assign     p-news = no.   end.
            when 'pre-vedom':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа " + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure c-fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.c-fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr  exclusive-lock  where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.host-code    = p-host-code
      AND buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-doc-attr then do:
      create buf_c-fin-doc-attr.
      assign
      buf_c-fin-doc-attr.attr-code    = p-attr-code
      buf_c-fin-doc-attr.attr-value   = p-attr-value
      buf_c-fin-doc-attr.host-code    = p-host-code
      buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
        buf_c-fin-doc-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      AND buf_c-fin-doc-attr.host-code      = p-host-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value-nextchip :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      and buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      and buf_c-fin-doc-attr.host-code      = p-host-code
      and buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc-attr.chip-num         > p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fin-doc-temp-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_temp-fin-doc-attr for tt0-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_temp-fin-doc-attr  exclusive-lock  where
          buf_temp-fin-doc-attr.attr-code    = p-attr-code
      AND buf_temp-fin-doc-attr.host-code    = p-host-code
      AND buf_temp-fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_temp-fin-doc-attr then do:
      create buf_temp-fin-doc-attr.
      assign
      buf_temp-fin-doc-attr.attr-code    = p-attr-code
      buf_temp-fin-doc-attr.attr-value   = p-attr-value
      buf_temp-fin-doc-attr.host-code    = p-host-code
      buf_temp-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
    assign
    buf_temp-fin-doc-attr.attr-value = p-attr-value.
 end.
end procedure.
procedure fin-doc-temp-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for tt0-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
  end.
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-copy-mode                 as logical   no-undo .
define variable v-buttons                   as character no-undo .
define variable v-desc                      as character no-undo .
define variable v-t                         as character no-undo .
define variable v-num                       as integer   no-undo .
define variable v-bank-name                 like ub.fin-bank.bank-name no-undo .
define variable v-dop1                      like ub.fin-schet.dop1 no-undo .
define variable v-dop2                      like ub.fin-schet.dop2 no-undo .
define variable v-bik                       like ub.fin-bank.bik no-undo .
define variable v-c-schet                   like ub.fin-bank.cor-acc no-undo .
define variable v-r-schet                   like ub.fin-schet.r-schet no-undo .
define variable v-code-schet                like ub.fin-schet.code-schet no-undo .
define variable v-payer-schet-curr-code     like ub.fin-schet.curr-code no-undo .
define variable v-receiver-schet-curr-code  like ub.fin-schet.curr-code no-undo .
define variable v-payer-schet-curr-abbr     like ub.currency.curr-abbr no-undo .
define variable v-receiver-schet-curr-abbr  like ub.currency.curr-abbr no-undo .
define variable v-base-code                 like ub.sysconf.base-code no-undo .
define variable v-base-curr-abbr            like ub.currency.curr-abbr no-undo .
define variable v-curr-abbr-contr           like ub.currency.curr-abbr no-undo .
define variable v-sel-curr                  as character no-undo .
define variable v-curr-code                 like ub.currency.curr-code no-undo.
define variable v-today                     as date      no-undo .
define variable v-time                      as integer   no-undo .
define variable v-cli-side-inn-kpp-obj-name as character no-undo .
define variable v-contract-code             like ub.fin-doc.contract-code no-undo .
define variable v-recid-schet               as recid     no-undo .
define variable v-recid-bank                as recid     no-undo .
define variable v-ok                        as logical   no-undo .
define variable v-fin-doc-code              like ub.fin-doc.fin-doc-code no-undo .
define variable f-cor-acc-descr             as character no-undo .
define variable f-cor-acc1-descr            as character no-undo .
DEFINE VARIABLE f-an-uchet-descr            AS CHARACTER NO-UNDO.
DEFINE VARIABLE f-cel-nazn-descr            AS CHARACTER no-undo .
define variable fc-cor-acc-descr            as character no-undo .
define variable fc-cor-acc1-descr           as character no-undo .
DEFINE VARIABLE fc-an-uchet-descr           AS CHARACTER NO-UNDO.
DEFINE VARIABLE fc-cel-nazn-descr           AS CHARACTER no-undo .
define variable v-refill-payer-schet        as logical   no-undo .
define variable v-refill-receiver-schet     as logical   no-undo .
define variable v-fd-code                   as integer   no-undo .
define variable v-obj-db-num                as integer   no-undo init -1.
define variable v-author                    as character no-undo .
define variable v-param-type                as character no-undo .
define variable v-value-character           as character no-undo .
define variable v-value-date                as date      no-undo .
define variable v-value-decimal             as decimal   no-undo .
define variable v-value-integer             as INTEGER   no-undo .
define variable v-value-logical             AS LOGICAL   no-undo .
define variable v-tth                       as handle    no-undo .
define variable v-prefix-fin-doc            as character no-undo .
define variable mCashBook                   as class     ibs.th.ref.cashbookstorage no-undo .
assign
  v-tth = buffer thbjattr_thbj-attr:table-handle .
define variable o-uchet as character no-undo .
define buffer buf_contract           for ub.contract.
define buffer buf_tt-fin-doc         for tt-fin-doc.
define buffer bufc_ttc-fin-doc       for ttc-fin-doc.
define buffer buf_currency           for ub.currency.
define buffer buf_payer              for ub.clients.
define buffer buf_receiver           for ub.clients.
define buffer buf_fin-ob             for ub.fin-ob.
define buffer buf_sysconf            for ub.sysconf.
define buffer buf_curr_sysconf       for ub.sysconf.
define buffer buf_firm               for ub.firm.
define buffer buf_clients-host       for ub.clients.
define buffer buf_clients-obj        for ub.clients.
define buffer buf_payer-fin-schet    for ub.fin-schet.
define buffer buf_receiver-fin-schet for ub.fin-schet.
define buffer buf_payer-fin-bank     for ub.fin-bank.
define buffer buf_receiver-fin-bank  for ub.fin-bank.
define buffer buf_payer-firm         for ub.firm.
define buffer buf_payer-person       for ub.person.
define buffer buf_receiver-firm      for ub.firm.
define buffer buf_receiver-person    for ub.person.
define buffer buf_nc-tt-fin-doc      for nc-tt-fin-doc.
define buffer buf_a0-tt-fin-doc      for a0-tt-fin-doc.
define buffer buf_fin-code-cor-acc   for ub.fin-code-cor-acc.
define buffer buf_fin-code-cor-acc1  for ub.fin-code-cor-acc.
define buffer buf_fin-code-an-uchet  for ub.fin-code-an-uchet.
define buffer buf_fin-code-cel-nazn  for ub.fin-code-cel-nazn.
define buffer buf_contract-currency  for ub.currency.
define buffer locked_fin-doc         for ub.fin-doc.
do
  on error undo,
  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message( 1 ) )
  :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
    v-prefix-fin-doc = (if num-entries(p-mode, chr(4)) > 2
            then entry(3, p-mode, chr(4))
            else '':U)
    v-author = (if num-entries(p-mode, chr(4)) > 1
            then entry(2, p-mode, chr(4))
            else '':U)
    p-mode   = entry(1, p-mode, chr(4))
    .
  if p-mode <> 'КОПИРОВАНИЕ':U
    then
  do:
    for each tt-fin-doc:
      delete tt-fin-doc.
    end.
  end.
  if p-mode = 'КОПИРОВАНИЕ':U then
  do:
    for each tt0-fin-doc no-lock where
      tt0-fin-doc.host-code = p-host-code
      AND tt0-fin-doc.fin-doc-code = 0:
      create buf_tt-fin-doc.
      buffer-copy tt0-fin-doc to buf_tt-fin-doc.
      release buf_tt-fin-doc.
      create buf_a0-tt-fin-doc.
      buffer-copy tt0-fin-doc to buf_a0-tt-fin-doc.
      release buf_a0-tt-fin-doc.
    END.
    find first tt-fin-doc no-error .
    if not avail tt-fin-doc then
    do:
      return error substitute("Нет записи в заполняемом буфере для платежа с типом &1", p-fin-ext-doc-type).
    end.
    find first buf_a0-tt-fin-doc.
    run get-fin-code-descr in this-procedure (
      input 'ПРОСМОТР':U
      ,input buf_a0-tt-fin-doc.cor-acc1
      ,input buf_a0-tt-fin-doc.cor-acc
      ,input buf_a0-tt-fin-doc.an-uchet-code
      ,input buf_a0-tt-fin-doc.cel-nazn-code
      ,input-output buf_a0-tt-fin-doc.cor-acc1-value
      ,input-output buf_a0-tt-fin-doc.cor-acc-value
      ,input-output buf_a0-tt-fin-doc.an-uchet-value
      ,input-output buf_a0-tt-fin-doc.cel-nazn-value
      ,output fc-cor-acc1-descr
      ,output fc-cor-acc-descr
      ,output fc-an-uchet-descr
      ,output fc-cel-nazn-descr
      ).
  end.
  if p-mode <> 'ДОБАВЛЕНИЕ':U
    and p-mode <> 'КОПИРОВАНИЕ':U
    then
  do:
    for each tt0c-fin-doc no-lock where
      tt0c-fin-doc.host-code = p-host-code
      AND tt0c-fin-doc.fin-doc-code = p-fin-doc-code:
      create bufc_ttc-fin-doc.
      buffer-copy tt0c-fin-doc to bufc_ttc-fin-doc.
      v-fin-doc-code = tt0c-fin-doc.fin-doc-code.
      release bufc_ttc-fin-doc.
    END.
    find first ttc-fin-doc no-error .
    if not avail ttc-fin-doc then
    do:
      return error substitute("Нет записи в проверяемом буфере для платежа &1", p-fin-doc-code).
    end.
    create tt-fin-doc.
    if p-mode = 'ПРОСМОТР':U then
    do:
      buffer-copy ttc-fin-doc
        to
        tt-fin-doc.
    end.
    else
    do:
      buffer-copy ttc-fin-doc
        using
        host-code
        fin-doc-code
        fin-doc-type
        fin-ext-doc-type
        obj-type
        obj-code
        contract-code
        payer-type
        payer-code
        payer-code-schet
        receiver-type
        receiver-code
        receiver-code-schet
        curr-code
        status_
        to
        tt-fin-doc.
    end.
  end.
  CASE p-mode:
    when 'ПРОСМОТР':U then
      do:
        assign
          p-limit-access = 10
          .
      end.
    when 'ДОБАВЛЕНИЕ':U
    or
    when 'КОПИРОВАНИЕ':U
    then
      do:
        assign
          p-limit-access = 0.
      end.
    otherwise
    do:
      assign
        p-mode = 'ИЗМЕНЕНИЕ':U
        .
      if tt-fin-doc.status_ = 'разрешен':U  then
      do:
        assign
          p-limit-access = 1
          .
      end.
      if tt-fin-doc.status_ = 'банк':U  then
      do:
        assign
          p-limit-access = 2
          .
      end.
    end.
  end CASE.
  find first buf_sysconf no-lock where
    buf_sysconf.host-code = p-host-code.
  if (p-mode = 'ДОБАВЛЕНИЕ':U
    and p-obj-type <> "":U
    and p-obj-code <> 0)
    or  (p-mode <> 'ДОБАВЛЕНИЕ':U
    and tt-fin-doc.obj-type <> "":U
    and tt-fin-doc.obj-code <> 0)
    then
  do:
    find first buf_clients-obj no-lock where
      buf_clients-obj.obj-type = (if p-mode = 'ДОБАВЛЕНИЕ':U
      then p-obj-type
      else tt-fin-doc.obj-type)
      AND buf_clients-obj.obj-code = (if p-mode = 'ДОБАВЛЕНИЕ':U
      then p-obj-code
      else tt-fin-doc.obj-code)  no-error.
    if not available buf_clients-obj then
    do:
      undo, return error substitute ("&1 &2 &3&4Неверное значение параметров вызова p-obj-type или поля obj-type &5&4и/или p-obj-code или поля obj-code&6"
        ,vss-workfile
        ,vss-revision
        ,vss-description
        ,chr(10)
        ,(if p-mode = 'ДОБАВЛЕНИЕ':U then p-obj-type else tt-fin-doc.obj-type)
        ,(if p-mode = 'ДОБАВЛЕНИЕ':U then p-obj-code else tt-fin-doc.obj-code)).
    end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_clients-obj.obj-type
  ,input  buf_clients-obj.obj-code
  ,output v-obj-db-num
  )  .
  end.
  define variable v-cash-book-place as character no-undo .
  define variable v-cash-book       as integer   no-undo .
  if (p-mode = 'ДОБАВЛЕНИЕ':U
    and p-obj-type <> "":U
    and p-obj-code <> 0)
    or  (p-mode = 'КОПИРОВАНИЕ':U
    and tt-fin-doc.obj-type <> "":U
    and tt-fin-doc.obj-code <> 0)
    then
  do:
    if v-obj-db-num = v-cntxt-db-num then
    do:
      assign
        v-cash-book-place = buf_clients-obj.obj-type + string(buf_clients-obj.obj-code, "99999")
        .
    end.
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    define variable par-type        as character no-undo .
    define variable v-dpt-option    as character no-undo .
    define variable v-dpt-dflt-name as character no-undo .
    define variable v-dpt-dflt-type as character no-undo .
    define variable v-dpt-dflt-code as integer   no-undo .
    define variable v-hist-code     as character no-undo .
    define variable v-hist-name     as character no-undo .
    mCashBook = new ibs.th.ref.cashbookstorage () .
    v-dpt-option    = mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "Struct") .
    v-dpt-dflt-name = mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "DptName") .
    v-dpt-dflt-type = mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "DptType") .
    v-dpt-dflt-code = integer(mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "DptCode")) .
    o-uchet         = mCashBook:getSinglRule(p-cashbookId, buf_clients-obj.obj-type, buf_clients-obj.obj-code, "uchet") .
    delete object mCashBook no-error .
    case v-dpt-option:
      when "1" then
        do:
            run db-attr-value(INPUT v-cntxt-db-num,INPUT 'hist-code':U,OUTPUT v-hist-code ,OUTPUT par-type) .
            run db-attr-value(INPUT v-cntxt-db-num,INPUT 'hist-name':U,OUTPUT v-hist-name ,OUTPUT par-type) .
            if v-hist-code = "" then v-dpt-dflt-code = buf_clients-obj.obj-code .
            if v-hist-name = "" then v-dpt-dflt-name = buf_clients-obj.obj-name .
            v-dpt-dflt-type = buf_clients-obj.obj-type .
      end.
      when "0" then do:
      assign
        v-dpt-dflt-name = ''
        v-dpt-dflt-type = ''
        v-dpt-dflt-code = 0
        .
    end.
      otherwise do:
  assign
    v-dpt-dflt-name = v-dpt-dflt-name
    v-dpt-dflt-type = v-dpt-dflt-type
    v-dpt-dflt-code = v-dpt-dflt-code
    .
end.
end case.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then
do:
  v-cash-book-place = ttc-fin-doc.trn-doc-code.
end.
define variable v-log      as logical   no-undo .
define variable v-out-mess as character no-undo .
if p-mode <> 'ПРОСМОТР':U then
do:
  if not (p-obj-type = '' and p-obj-code = 0)
    and v-obj-db-num = v-cntxt-db-num then
  do:
    define variable l-shift-on as logical no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  end.
end.
find first buf_clients-host no-lock where
  buf_clients-host.obj-type = 'орг':U
  AND buf_clients-host.obj-code = p-host-code  no-error.
if not available buf_clients-host then
do:
  undo, return error substitute("&1 &2 &3&4Неверное значение параметра вызова p-host-code &5"
    ,vss-workfile
    ,vss-revision
    ,vss-description
    ,chr(10)
    ,p-host-code).
end.
find first buf_firm no-lock where
  buf_firm.firm-code = p-host-code.
if (p-mode = 'ДОБАВЛЕНИЕ':U
  and p-contract-code <> 0)
  or (p-mode <> 'ДОБАВЛЕНИЕ':U
  and tt-fin-doc.contract-code <> 0) then
do:
  find first buf_contract no-lock where
    buf_contract.contract-code = (if p-mode = 'ДОБАВЛЕНИЕ':U
    then p-contract-code
    else tt-fin-doc.contract-code)
    and buf_contract.host-code     = p-host-code   no-error .
  if error-status :error then
  do:
    undo, return error substitute("&1 &2 &3&4Неверное значение параметра P-contract-code или поля contract-code&4Не найден контракт с кодом &1 по фирме &2"
      ,(if p-mode = 'ДОБАВЛЕНИЕ':U then p-contract-code else tt-fin-doc.contract-code)
      ,p-host-code).
  end.
  v-contract-code = buf_contract.contract-code.
end.
if (p-mode = 'ДОБАВЛЕНИЕ':U
  and p-ob-doc-code <> "" )
  then
do:
  find first buf_fin-ob where
    buf_fin-ob.host-code = p-host-code
    AND buf_fin-ob.doc-code = p-ob-doc-code
    no-error .
  if not available buf_fin-ob then
  do:
    undo, return error substitute("&1 &2 &3&4Не найдено финобязательство с кодом &4 по фирме &5"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,chr(10)
      ,p-ob-doc-code
      ,p-host-code).
  end.
  find first buf_contract where
    buf_contract.host-code = p-host-code
    AND buf_contract.contract-code = buf_fin-ob.contract-code  no-error .
  if not available buf_contract
    or buf_contract.contract-code <> v-contract-code
    then
  do:
    undo, return error( substitute("&1 &2 &3&4Неверный параметр p-ob-doc-code или значение поля ob-doc-code &5&4&6"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,chr(10)
      ,p-ob-doc-code
      ,(if not available buf_contract
      then "Не найден договор для финобязательства"
      else substitute("Номер договора в платеже &1, номер договора для финобязательства &2"
      ,v-contract-code
      ,buf_contract.contract-code))
      )).
  end.
  assign
    v-curr-code = buf_fin-ob.curr-code
    .
end.
if (p-mode = 'ДОБАВЛЕНИЕ':U and p-curr-code <> ?)
  or p-mode <> 'ДОБАВЛЕНИЕ':U
  then
do:
  find first buf_currency no-lock where
    buf_currency.curr-code = (if p-mode = 'ДОБАВЛЕНИЕ':U
    then p-curr-code
    else tt-fin-doc.curr-code)  no-error .
  if not available buf_currency
    or (v-curr-code <> ? and buf_currency.curr-code <> v-curr-code and p-mode = 'ДОБАВЛЕНИЕ':U)
    then
  do:
    undo, return error substitute("&1 &2 &3&4Неверный параметр p-curr-code или значение поля curr-code&5&4&6"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,chr(10)
      ,(if p-mode = 'ДОБАВЛЕНИЕ':U then p-curr-code else tt-fin-doc.curr-code)
      ,(if not available buf_currency
      then "Не найден валюта с таким кодом"
      else substitute("Код валюты в платеже &1, код валюты для финобязательства &2"
      ,v-curr-code
      ,buf_currency.curr-code))
      ).
  end.
end.
if (p-mode = 'ДОБАВЛЕНИЕ':U
  and p-payer-type <> "":U
  AND p-payer-code <> 0)
  or (p-mode <> 'ДОБАВЛЕНИЕ':U
  and tt-fin-doc.payer-type <> '':U
  and tt-fin-doc.payer-code <> 0)
  then
do:
  FIND FIRST buf_payer NO-LOCK WHERE
    buf_payer.obj-type = (if p-mode = 'ДОБАВЛЕНИЕ':U
    then p-payer-type
    else tt-fin-doc.payer-type)
    AND buf_payer.obj-code = (if p-mode = 'ДОБАВЛЕНИЕ':U
    then p-payer-code
    else tt-fin-doc.payer-code)
    NO-ERROR .
  if not avail buf_payer then
  do:
    undo, return error substitute("&1& 2& 3&4 Неверные параметры p-payer-type или значение поля payer-type&5&4" +
      "И/ИЛИ p-payer-code или значение поля payer-code&6"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,chr(10)
      ,(if p-mode = 'ДОБАВЛЕНИЕ':U then p-payer-type else tt-fin-doc.payer-type)
      ,(if p-mode = 'ДОБАВЛЕНИЕ':U then p-payer-code else tt-fin-doc.payer-code)).
  end.
  if buf_payer.obj-type = 'орг':U then
  do:
    find first buf_payer-firm no-lock where
      buf_payer-firm.firm-code = buf_payer.obj-code no-error.
    if not avail buf_payer-firm then do:
      undo, return error substitute("&1 &2 &3&4 Не найдена запись с кодом &5 в справочнике организаций"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,string(buf_payer.obj-code)).
    end.
  end.
  else
  do:
    find first buf_payer-person no-lock where
      buf_payer-person.psn-code = buf_payer.obj-code no-error.
    if not avail buf_payer-person then do:
      undo, return error substitute("&1 &2 &3&4 Не найдена запись с кодом &5 в справочнике физических лиц"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,string(buf_payer.obj-code)).
    end.
  end.
end.
if (p-mode = 'ДОБАВЛЕНИЕ':U
  and p-receiver-type <> "":U
  AND p-receiver-code <> 0)
  or (p-mode <> 'ДОБАВЛЕНИЕ':U
  and
  tt-fin-doc.receiver-type <> '':U
  and
  tt-fin-doc.receiver-code <> 0)
  then
do:
  FIND FIRST buf_receiver WHERE
    buf_receiver.obj-type = (if p-mode = 'ДОБАВЛЕНИЕ':U
    then p-receiver-type
    else tt-fin-doc.receiver-type)
    AND buf_receiver.obj-code = (if p-mode = 'ДОБАВЛЕНИЕ':U
    then p-receiver-code
    else tt-fin-doc.receiver-code)
    NO-LOCK  no-error.
  if not avail buf_receiver then
  do:
    undo, return error substitute("Неверные параметры p-receiver-type или значение поля receiver-type &1 &2 И/ИЛИ p-receiver-code или значение поля receiver-code &3",
      (if p-mode = 'ДОБАВЛЕНИЕ':U then p-receiver-type else tt-fin-doc.receiver-type)
      ,chr(10)
      ,(if p-mode = 'ДОБАВЛЕНИЕ':U then p-receiver-code else tt-fin-doc.receiver-code)).
  end.
  if buf_receiver.obj-type = 'орг':U then
  do:
    find first buf_receiver-firm no-lock where
      buf_receiver-firm.firm-code = buf_receiver.obj-code no-error.
    if not avail buf_receiver-firm then do:
      undo, return error substitute("&1 &2 &3&4 Не найдена запись с кодом &5 в справочнике организаций"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,string(buf_receiver.obj-code)).
    end.
  end.
  else
  do:
    find first buf_receiver-person no-lock where
      buf_receiver-person.psn-code = buf_receiver.obj-code.
    if not avail buf_receiver-person then do:
      undo, return error substitute("&1 &2 &3&4 Не найдена запись с кодом &5 в справочнике физических лиц"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,string(buf_receiver.obj-code)).
    end.
  end.
end.
if p-fin-doc-type = 'ппп':U
  or p-fin-doc-type = 'рпп':U then
do:
  if (p-mode = 'ДОБАВЛЕНИЕ':U and p-payer-code-schet <> 0)
    or (p-mode <> 'ДОБАВЛЕНИЕ':U and tt-fin-doc.payer-code-schet <> 0)
    then
  do:
    run get-fin-schet  in this-procedure (
      buffer buf_payer-fin-schet
      ,buffer buf_receiver-fin-schet
      ,buffer buf_payer-fin-bank
      ,buffer buf_receiver-fin-bank
      ,input (if p-mode = 'ДОБАВЛЕНИЕ':U
      then p-payer-code-schet
      else tt-fin-doc.payer-code-schet)
      ,input (if p-mode = 'ДОБАВЛЕНИЕ':U
      then p-receiver-code-schet
      else tt-fin-doc.receiver-code-schet)
      ,input (if p-mode = 'ДОБАВЛЕНИЕ':U then p-payer-type else tt-fin-doc.payer-type)
      ,input (if p-mode = 'ДОБАВЛЕНИЕ':U then p-payer-code else tt-fin-doc.payer-code)
      ,input (if p-mode = 'ДОБАВЛЕНИЕ':U then p-receiver-type else tt-fin-doc.receiver-type)
      ,input (if p-mode = 'ДОБАВЛЕНИЕ':U then p-receiver-code else tt-fin-doc.receiver-code)
      ,input no
      ,input-output tt-fin-doc.payer-bank-name
      ,input-output tt-fin-doc.receiver-bank-name
      ,input-output tt-fin-doc.payer-bank-city
      ,input-output tt-fin-doc.receiver-bank-city
      ,input-output tt-fin-doc.payer-bik
      ,input-output tt-fin-doc.receiver-bik
      ,input-output tt-fin-doc.payer-r-schet
      ,input-output tt-fin-doc.receiver-r-schet
      ,input-output tt-fin-doc.payer-c-schet
      ,input-output tt-fin-doc.receiver-c-schet
      ) no-error .
    if error-status:error then
    do:
      undo, return error return-value .
    end.
  end.
  if  not avail buf_receiver-fin-schet
    and available buf_receiver
    then
  do:
    run get-single-schet in this-procedure(
      input p-host-code
      ,input buf_receiver.obj-type
      ,input buf_receiver.obj-code
      ,input v-curr-code
      ,output v-recid-schet
      ,output v-recid-bank
      ).
    if v-recid-schet <> ? then
    do:
      find first buf_receiver-fin-schet no-lock where
        recid(buf_receiver-fin-schet) = v-recid-schet.
      find first buf_receiver-fin-bank no-lock where
        recid(buf_receiver-fin-bank) = v-recid-bank.
    end.
  end.
  if not avail buf_payer-fin-schet
    and available buf_payer
    then
  do:
    run get-single-schet in this-procedure(
      input p-host-code
      ,input buf_payer.obj-type
      ,input buf_payer.obj-code
      ,input v-curr-code
      ,output v-recid-schet
      ,output v-recid-bank
      ).
    if v-recid-schet <> ? then
    do:
      find first buf_payer-fin-schet no-lock where
        recid(buf_payer-fin-schet) = v-recid-schet.
      find first buf_payer-fin-bank no-lock where
        recid(buf_payer-fin-bank) = v-recid-bank.
    end.
  end.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U
  or p-mode = 'КОПИРОВАНИЕ':U then
do:
  if p-mode = 'ДОБАВЛЕНИЕ':U then
  do:
    create tt-fin-doc.
  end.
  run gen-b-code in this-procedure ( input 'fdgb':U
    , output v-fd-code) no-error .
  if error-status:error then
  do:
    undo, return error substitute("Ошибка при генерации внутреннего номера фин. док-та:&1&2&1&3"
      , chr(10)
      , error-status:get-message(1)
      , return-value ).
  end.
  assign
    tt-fin-doc.host-code        = p-host-code
    tt-fin-doc.fin-doc-code     = v-fd-code
    v-fin-doc-code              = tt-fin-doc.fin-doc-code
    tt-fin-doc.fin-doc-type     = p-fin-doc-type
    tt-fin-doc.fin-ext-doc-type = p-fin-ext-doc-type
    tt-fin-doc.prn-doc-code     = v-prefix-fin-doc + "":U
    tt-fin-doc.status_          = 'новый':U
    tt-fin-doc.user-db-num-doc  = v-cntxt-db-num
    tt-fin-doc.user-name-doc    = v-cntxt-userid
    tt-fin-doc.curr-code        = v-curr-code
    tt-fin-doc.base-rate        = 1
    tt-fin-doc.base-scale       = 1
    tt-fin-doc.exch-rate        = 1
    tt-fin-doc.exch-scale       = 1
    tt-fin-doc.CashBookId       = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                then p-cashbookId
                                else tt-fin-doc.cashbookId)
    tt-fin-doc.contract-code    = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                then p-contract-code
                                else tt-fin-doc.contract-code)
    tt-fin-doc.contract-curr    = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                then (if available buf_contract
                                      then buf_contract.curr-code
                                      else 0)
                                else tt-fin-doc.contract-curr)
    tt-fin-doc.contract-rate    = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                then 1
                                else tt-fin-doc.contract-rate)
    tt-fin-doc.contract-scale   = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                 then 1
                                 else tt-fin-doc.contract-scale)
    tt-fin-doc.obj-type         = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                then p-obj-type
                                else tt-fin-doc.obj-type)
    tt-fin-doc.obj-code         = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                then p-obj-code
                                else tt-fin-doc.obj-code)
    tt-fin-doc.str-podr-name    = if v-hist-name = "" then v-dpt-dflt-name else v-hist-name
    tt-fin-doc.str-podr-type    = v-dpt-dflt-type
    tt-fin-doc.str-podr-code    = v-dpt-dflt-code
    tt-fin-doc.sum-doc          = (if p-mode = 'ДОБАВЛЕНИЕ':U
                           then (if available buf_fin-ob
                                 then buf_fin-ob.sum-doc
                                 else 0)
                           else tt-fin-doc.sum-doc)
    tt-fin-doc.doc-author       = v-author
    tt-fin-doc.shift-flag       = (if l-shift-on and v-cash-book-place <> ""
                                    and lookup(tt-fin-doc.fin-ext-doc-type, 'пко,рко':U) > 0
                                    and (tt-fin-doc.doc-author = 'manual':U or tt-fin-doc.doc-author = 'auto':U)
                                    then integer('1':U)
                                    else 0)
    tt-fin-doc.trn-doc-code     = (if p-mode = 'ДОБАВЛЕНИЕ':U
                               then v-cash-book-place
                               else tt-fin-doc.trn-doc-code)
    .
  if l-shift-on
    and tt-fin-doc.shift-flag = integer('1':U)
    then
  do:
    define variable v-fin-doc-shift-date      as date      no-undo .
    define variable v-fin-doc-shift-num       as integer   no-undo .
    define variable v-fin-doc-shift-name      as character no-undo .
    define variable v-fin-doc-shift-date-char as character no-undo .
    define variable v-fin-doc-shift-num-char  as character no-undo .
    define variable varobj-shift-date         as date      no-undo .
    define variable varobj-shift-num          as integer   no-undo .
    define variable varobj-shift-name         as character no-undo .
    define variable v-can-back-shift          as logical   no-undo .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-doc_create-back-shift':U
    ,input  'object':U
    ,input  tt-fin-doc.host-code
    ,input  tt-fin-doc.obj-type
    ,input  tt-fin-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-can-back-shift
    )  .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  tt-fin-doc.obj-type
  ,input  tt-fin-doc.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  ) no-error .
    if error-status :error then
    do:
      if not v-can-back-shift then
      do:
        return error substitute("Не найдена текущая смена на &1&2", tt-fin-doc.obj-type, tt-fin-doc.obj-code).
      end.
    end.
    assign
      v-fin-doc-shift-date = varobj-shift-date
      v-fin-doc-shift-num  = varobj-shift-num
      v-fin-doc-shift-name = varobj-shift-name
      .
    define variable v-date as date no-undo  .
    run cur-time in this-procedure(output v-date, output v-time).
    assign
      tt-fin-doc.shift-date = v-fin-doc-shift-date
      tt-fin-doc.shift-num  = v-fin-doc-shift-num
      tt-fin-doc.shift-name = v-fin-doc-shift-name
      .
      if o-uchet <> "0" then tt-fin-doc.doc-date = v-fin-doc-shift-date .
      else tt-fin-doc.doc-date = v-today .
  end.
  else
  do:
    assign
      tt-fin-doc.shift-date = ?
      tt-fin-doc.shift-num  = 0
      tt-fin-doc.shift-name = ''
      .
  end.
  if p-mode = 'КОПИРОВАНИЕ':U
    then
    assign
      p-mode      = 'ДОБАВЛЕНИЕ':U
      v-copy-mode = yes
      .
end.
run cur-time in this-procedure
  (output v-today
  ,output v-time
  ) no-error .
if tt-fin-doc.status_ <> 'факт':U then
do:
  if tt-fin-doc.obj-type <> ''then
  do:
    define variable o-head-position as character no-undo .
    define variable o-director      as character no-undo .
    define variable o-snr-accnt     as character no-undo .
    define variable o-cashier       as character no-undo .
    define variable v-head-position as character no-undo .
    define variable v-director      as character no-undo .
    define variable v-snr-accnt     as character no-undo .
    define variable v-cashier       as character no-undo .
    define buffer buf_shop  for ub.shop.
    define buffer buf_store for ub.store.
    define variable p-by-osnovanie    as character no-undo .
    define variable p-by-pril         as character no-undo .
    define variable p-by-cash-desk    as logical   no-undo .
    define variable p-by-petrol-goods as logical   no-undo .
    mCashBook = new ibs.th.ref.cashbookstorage () .
    o-head-position = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "ManagerPosition") .
    o-director      = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "ManagerFIO") .
    o-snr-accnt     = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BuhFIO") .
    delete object mCashBook no-error .
    case o-head-position:
      when '0':U then
        do:
          v-head-position = buf_sysconf.head-position.
        end.
      when '1':U then
        do:
          v-head-position = "Директор".
        end.
      when '2':U then
        do:
          v-head-position = "Управляющий".
        end.
      otherwise
      do :
        v-head-position = o-head-position.
      end.
    end case.
    case o-director:
      when '1':U then
        do:
          if p-obj-type = 'маг':U then
          do:
            find first buf_shop no-lock where
              buf_shop.obj-code = p-obj-code no-error .
            if available buf_shop then
            do:
              v-director = buf_shop.director.
            end.
          end.
          if p-obj-type = 'скл':U then
          do:
            find first buf_store no-lock where
              buf_store.obj-code = p-obj-code no-error .
            if available buf_store then
            do:
              v-director = buf_store.store-boss.
            end.
          end.
        end.
      when '0':U then
        do:
          v-director = buf_firm.director.
        end.
      otherwise
      do:
        v-director = o-director .
      end.
    end case.
    case o-snr-accnt:
      when '1':U then
        do:
          if p-obj-type = 'маг':U then
          do:
            find first buf_shop no-lock where
              buf_shop.obj-code = p-obj-code no-error .
            if available buf_shop then
            do:
              v-snr-accnt = entry(1,buf_shop.acct,"|").
            end.
          end.
          if p-obj-type = 'скл':U then
          do:
            v-snr-accnt = ''.
          end.
        end.
      when '2':U then
        do:
          v-snr-accnt = buf_sysconf.snr-accnt.
        end.
      otherwise
      do:
        v-snr-accnt = o-snr-accnt .
      end.
    end case.
    v-cashier = buf_sysconf.cashier.
    if v-cashier = "" then v-cashier = p-cashier .
  end.
  else
  do:
    assign
      v-head-position = buf_sysconf.head-position
      v-director      = buf_firm.director
      v-snr-accnt     = buf_sysconf.snr-accnt
      v-cashier       = buf_sysconf.cashier
      .
  end.
  FIND FIRST ub.shift-staff No-LOCK WHERE
    ub.shift-staff.obj-type   = p-obj-type AND
    ub.shift-staff.obj-code   = p-obj-code AND
    ub.shift-staff.shift-date = tt-fin-doc.shift-date AND
    ub.shift-staff.shift-num  = tt-fin-doc.shift-num AND
    ub.shift-staff.shift-name  = tt-fin-doc.shift-name AND
    ub.shift-staff.staff-role = no and
    ub.shift-staff.psn-num    >= 0 No-ERROR.
  assign
    v-cashier = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else  string(p-cashier, "X(30)") .
  .
  find first ub.CashBook no-lock where ub.CashBook.id = tt-fin-doc.cashbookid no-error .
  if not available ub.CashBook
    then
  do :
    find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
  end.
  if available ub.CashBook
    then
  do :
    p-by-cash-desk = ub.CashBook.FlagSepCash .
    p-by-petrol-goods = ub.CashBook.FlagSepFull .
  end.
  CASE p-fin-ext-doc-type:
    when 'пко':U then
      do:
        assign
          tt-fin-doc.receiver-type  = 'орг':U
          tt-fin-doc.receiver-code  = p-host-code
          tt-fin-doc.receiver-okpo  = buf_firm.okpo
          tt-fin-doc.receiver-name  = buf_clients-host.obj-name
          tt-fin-doc.doc-date       = v-today
          tt-fin-doc.receiver-sign1 = v-director
          tt-fin-doc.receiver-sign2 = v-snr-accnt
          tt-fin-doc.receiver-sign3 = v-cashier
          tt-fin-doc.payer-type     = (if available buf_payer then buf_payer.obj-type else 'орг':U)
          tt-fin-doc.payer-code     = (if available buf_payer then buf_payer.obj-code else 0)
          tt-fin-doc.payer-name     = (if available buf_payer then buf_payer.obj-name else "":U)
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-in-cash
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-in-cash
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-in-cash
            tt-fin-doc.cor-acc1      = buf_sysconf.cor-acc1-in-cash
            .
          if available (ub.CashBook)
          and ub.CashBook.CorrPko <> "" then
          do:
            for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.CorrPko
              and ub.fin-code-cor-acc.host-code = p-curr-host-code :
              tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
            end.
          end.
        end.
      end.
    when 'рко':U then
      do:
        assign
          tt-fin-doc.payer-type    = 'орг':U
          tt-fin-doc.payer-code    = p-host-code
          tt-fin-doc.payer-okpo    = buf_firm.okpo
          tt-fin-doc.payer-name    = buf_clients-host.obj-name
          tt-fin-doc.payer-sign1   = v-head-position + chr(4) + v-director
          tt-fin-doc.payer-sign2   = v-snr-accnt
          tt-fin-doc.payer-sign3   = v-cashier
          tt-fin-doc.receiver-type = (if available buf_receiver then buf_receiver.obj-type else 'орг':U)
          tt-fin-doc.receiver-code = (if available buf_receiver then buf_receiver.obj-code else 0)
          tt-fin-doc.receiver-name = (if available buf_receiver then buf_receiver.obj-name else "":U)
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-out-cash
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-out-cash
            .
          if available (ub.CashBook) then
          do:
            case ub.CashBook.RuleOsnRko :
              when "0" then
                tt-fin-doc.naznach-plat = "Выручка от реализации" .
              when "1" or
              when "2" then
                tt-fin-doc.naznach-plat = "" .
              otherwise
              tt-fin-doc.naznach-plat = ub.CashBook.RuleOsnRko .
            end case .
            if ub.CashBook.RulePril = "0" or ub.CashBook.RulePril = "1" then tt-fin-doc.enclosure = "" .
            else tt-fin-doc.enclosure = ub.CashBook.RulePril .
            if ub.CashBook.CorrRko <> "" then
            do:
              for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.CorrRko
                and ub.fin-code-cor-acc.host-code = p-curr-host-code :
                tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
              end.
            end.
            else
            do:
              for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = "57.01"
                and ub.fin-code-cor-acc.host-code = p-curr-host-code :
                tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
                tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
              end.
            end.
            if ub.CashBook.OsnAcct <> "" then
            do:
              for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.OsnAcct
                and ub.fin-code-cor-acc.host-code = p-curr-host-code :
                tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code .
              end.
            end.
          end.
        end.
      end.
    when 'ппп':U then
      do:
        assign
          tt-fin-doc.curr-code           = 0
          tt-fin-doc.receiver-type       = 'орг':U
          tt-fin-doc.receiver-code       = p-host-code
          tt-fin-doc.receiver-inn        = buf_firm.inn
          tt-fin-doc.receiver-kpp        = buf_firm.kpp
          tt-fin-doc.receiver-name       = buf_clients-host.obj-name
          tt-fin-doc.receiver-bank-name  = (if available buf_receiver-fin-bank
                                        then buf_receiver-fin-bank.bank-name
                                         else '':U)
          tt-fin-doc.receiver-bank-city  = (if available buf_receiver-fin-bank
                                        then buf_receiver-fin-bank.bank-city
                                        else '':U)
          tt-fin-doc.receiver-bik        = (if available buf_receiver-fin-bank
                                      then buf_receiver-fin-bank.bik
                                      else "":U)
          tt-fin-doc.receiver-code-schet = if available buf_receiver-fin-schet
                                      then buf_receiver-fin-schet.code-schet
                                      else 0
          tt-fin-doc.receiver-r-schet    = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.r-schet
                                    else "":U)
          tt-fin-doc.receiver-c-schet    = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.c-schet
                                    else "":U)
          tt-fin-doc.payer-sign1         = buf_firm.director
          tt-fin-doc.payer-sign2         = buf_sysconf.snr-accnt
          tt-fin-doc.ocher-pl            = "6":U
          tt-fin-doc.stat-pl             = "":U
          tt-fin-doc.payer-type          = (if available buf_payer then buf_payer.obj-type else 'орг':U)
          tt-fin-doc.payer-code          = (if available buf_payer then buf_payer.obj-code else 0)
          tt-fin-doc.payer-name          = (if available buf_payer then buf_payer.obj-name else "":U)
          tt-fin-doc.payer-inn           = (if available buf_payer
                                    then (if buf_payer.obj-type = 'орг':U
                                          then buf_payer-firm.inn
                                          else buf_payer-person.inn )
                                    else "":U)
          tt-fin-doc.payer-kpp           = (if available buf_payer
                                      then (if buf_payer.obj-type = 'орг':U
                                            then buf_payer-firm.kpp
                                            else buf_payer-person.kpp )
                                    else "":U)
          tt-fin-doc.payer-bank-name     = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bank-name
                                      else '':U)
          tt-fin-doc.payer-bank-city     = (if available buf_payer-fin-bank
                                        then buf_payer-fin-bank.bank-city
                                        else '':U)
          tt-fin-doc.payer-bik           = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bik
                                      else "":U)
          tt-fin-doc.payer-code-schet    = (if available buf_payer-fin-schet
                                       then buf_payer-fin-schet.code-schet
                                       else 0)
          tt-fin-doc.payer-r-schet       = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.r-schet
                                    else "":U)
          tt-fin-doc.payer-c-schet       = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.c-schet
                                    else "":U)
          tt-fin-doc.payer-sign1         = (if available buf_payer-firm then buf_payer-firm.director else '')
          tt-fin-doc.payer-sign2         = (if available buf_payer-firm then buf_payer-firm.gen-acct else '')
          tt-fin-doc.vid-plat            = 'электронно':U
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-in
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-in
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-in
            .
        end.
      end.
    when 'рпп':U then
      do:
        assign
          tt-fin-doc.curr-code           = 0
          tt-fin-doc.payer-type          = 'орг':U
          tt-fin-doc.payer-code          = p-host-code
          tt-fin-doc.payer-inn           = buf_firm.inn
          tt-fin-doc.payer-kpp           = buf_firm.kpp
          tt-fin-doc.payer-name          = buf_clients-host.obj-name
          tt-fin-doc.payer-bank-name     = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bank-name
                                      else '':U)
          tt-fin-doc.payer-bank-city     = (if available buf_payer-fin-bank
                                        then buf_payer-fin-bank.bank-city
                                        else '':U)
          tt-fin-doc.payer-bik           = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bik
                                      else "":U)
          tt-fin-doc.payer-code-schet    = if available buf_payer-fin-schet
                                      then buf_payer-fin-schet.code-schet
                                      else 0
          tt-fin-doc.payer-r-schet       = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.r-schet
                                    else "":U)
          tt-fin-doc.payer-c-schet       = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.c-schet
                                    else "":U)
          tt-fin-doc.payer-sign1         = buf_firm.director
          tt-fin-doc.payer-sign2         = buf_sysconf.snr-accnt
          tt-fin-doc.ocher-pl            = "6":U
          tt-fin-doc.stat-pl             = "":U
          tt-fin-doc.receiver-type       = (if available buf_receiver then buf_receiver.obj-type else 'орг':U)
          tt-fin-doc.receiver-code       = (if available buf_receiver then buf_receiver.obj-code else 0)
          tt-fin-doc.receiver-name       = (if available buf_receiver then buf_receiver.obj-name else "":U)
          tt-fin-doc.receiver-inn        = (if available buf_receiver
                                    then (if buf_receiver.obj-type = 'орг':U
                                          then buf_receiver-firm.inn
                                          else buf_receiver-person.inn )
                                    else "":U)
          tt-fin-doc.receiver-kpp        = (if available buf_receiver
                                      then (if buf_receiver.obj-type = 'орг':U
                                            then buf_receiver-firm.kpp
                                            else buf_receiver-person.kpp )
                                    else "":U)
          tt-fin-doc.receiver-bank-name  = (if available buf_receiver-fin-bank
                                        then buf_receiver-fin-bank.bank-name
                                        else '':U)
          tt-fin-doc.receiver-bank-city  = (if available buf_receiver-fin-bank
                                        then buf_receiver-fin-bank.bank-city
                                        else '':U)
          tt-fin-doc.receiver-bik        = (if available buf_receiver-fin-bank
                                      then buf_receiver-fin-bank.bik
                                      else "":U)
          tt-fin-doc.receiver-code-schet = (if available buf_receiver-fin-schet
                                          then buf_receiver-fin-schet.code-schet
                                          else 0)
          tt-fin-doc.receiver-r-schet    = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.r-schet
                                    else "":U)
          tt-fin-doc.receiver-c-schet    = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.c-schet
                                    else "":U)
          tt-fin-doc.vid-plat            = 'электронно':U
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-out
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-out
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-out
            .
        end.
      end.
    when 'апп':U then
      do:
        assign
          tt-fin-doc.receiver-type  = 'орг':U
          tt-fin-doc.receiver-code  = p-host-code
          tt-fin-doc.receiver-okpo  = buf_firm.okpo
          tt-fin-doc.receiver-name  = buf_clients-host.obj-name
          tt-fin-doc.receiver-sign1 = buf_sysconf.head-position + chr(4) + buf_firm.director
          tt-fin-doc.payer-sign1    = (if available buf_payer
                            and buf_payer.obj-type = 'орг':U
                            then buf_payer-firm.director
                            else (if available buf_payer
                                  then buf_payer.obj-name
                                  else "":U
                                )
                            )
          tt-fin-doc.payer-type     = (if available buf_payer then buf_payer.obj-type else 'орг':U)
          tt-fin-doc.payer-code     = (if available buf_payer then buf_payer.obj-code else 0)
          tt-fin-doc.payer-name     = (if available buf_payer then buf_payer.obj-name else "":U)
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-in-payoff
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-in-payoff
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-in-payoff
            tt-fin-doc.cor-acc1      = buf_sysconf.cor-acc1-in-payoff
            .
        end.
      end.
    when 'апр':U then
      do:
        assign
          tt-fin-doc.payer-type     = 'орг':U
          tt-fin-doc.payer-code     = p-host-code
          tt-fin-doc.payer-okpo     = buf_firm.okpo
          tt-fin-doc.payer-name     = buf_clients-host.obj-name
          tt-fin-doc.payer-sign1    = buf_sysconf.head-position + chr(4) + buf_firm.director
          tt-fin-doc.receiver-sign1 = (if available buf_receiver
                              and buf_receiver.obj-type = 'орг':U
                              then buf_receiver-firm.director
                              else (if available buf_receiver
                                    then buf_receiver.obj-name
                                    else "":U
                                    )
                            )
          tt-fin-doc.receiver-type  = (if available buf_receiver then buf_receiver.obj-type else 'орг':U)
          tt-fin-doc.receiver-code  = (if available buf_receiver then buf_receiver.obj-code else 0)
          tt-fin-doc.receiver-name  = (if available buf_receiver then buf_receiver.obj-name else "":U)
          .
        if o-uchet = "0" then         tt-fin-doc.doc-date      = v-today .
        if tt-fin-doc.contract-code = 0
          then
        do:
          assign
            tt-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-out-payoff
            tt-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-out-payoff
            tt-fin-doc.cor-acc       = buf_sysconf.cor-acc-out-payoff
            tt-fin-doc.cor-acc1      = buf_sysconf.cor-acc1-out-payoff
            .
        end.
      end.
  END CASE.
end.
run get-fin-code-descr in this-procedure (
  input 'ДОБАВЛЕНИЕ':U
  ,input tt-fin-doc.cor-acc1
  ,input tt-fin-doc.cor-acc
  ,input tt-fin-doc.an-uchet-code
  ,input tt-fin-doc.cel-nazn-code
  ,input-output tt-fin-doc.cor-acc1-value
  ,input-output tt-fin-doc.cor-acc-value
  ,input-output tt-fin-doc.an-uchet-value
  ,input-output tt-fin-doc.cel-nazn-value
  ,output f-cor-acc1-descr
  ,output f-cor-acc-descr
  ,output f-an-uchet-descr
  ,output f-cel-nazn-descr
  ).
if p-mode <> 'ДОБАВЛЕНИЕ':U then
do:
  run get-fin-code-descr in this-procedure (
    input 'ПРОСМОТР':U
    ,input ttc-fin-doc.cor-acc1
    ,input ttc-fin-doc.cor-acc
    ,input ttc-fin-doc.an-uchet-code
    ,input ttc-fin-doc.cel-nazn-code
    ,input-output ttc-fin-doc.cor-acc1-value
    ,input-output ttc-fin-doc.cor-acc-value
    ,input-output ttc-fin-doc.an-uchet-value
    ,input-output ttc-fin-doc.cel-nazn-value
    ,output fc-cor-acc1-descr
    ,output fc-cor-acc-descr
    ,output fc-an-uchet-descr
    ,output fc-cel-nazn-descr
    ).
end.
create buf_nc-tt-fin-doc.
if p-mode = 'ДОБАВЛЕНИЕ':U then
  buffer-copy tt-fin-doc to buf_nc-tt-fin-doc.
else
  buffer-copy ttc-fin-doc to buf_nc-tt-fin-doc.
if (p-mode = 'ДОБАВЛЕНИЕ':U
  and p-contract-code <> 0)
  or
  (p-mode <> 'ДОБАВЛЕНИЕ':U
  and tt-fin-doc.status_ <> 'факт':U
  and tt-fin-doc.contract-code <> 0)
  then
do:
  if p-mode = 'ДОБАВЛЕНИЕ':U then
  do:
    run ref/finfcont.p (
      input parparentproc
      ,input p-host-code
      ,input p-mode
      ,input tt-fin-doc.fin-doc-code
      ,input tt-fin-doc.fin-doc-type
      ,input tt-fin-doc.fin-ext-doc-type
      ,input (if p-mode = 'ДОБАВЛЕНИЕ':U
      then p-contract-code
      else tt-fin-doc.contract-code)
      ,input-output table tt-fin-doc )
      no-error .
  end.
  else
  do:
    run ref/finfcont.p (
      input parparentproc
      ,input p-host-code
      ,input p-mode
      ,input tt-fin-doc.fin-doc-code
      ,input tt-fin-doc.fin-doc-type
      ,input tt-fin-doc.fin-ext-doc-type
      ,input (if p-mode = 'ДОБАВЛЕНИЕ':U
      then p-contract-code
      else tt-fin-doc.contract-code)
      ,input-output table tt-fin-doc
      )
      no-error .
  end.
  if error-status:error then
  do:
    if p-mode = 'ДОБАВЛЕНИЕ':U
      and return-value = "exit":U then undo, return error "exit":U .
    else
    do:
      undo, return error ( substitute("Ошибка при заполнении реквизитов платежа согласно контракту&1&2 &3"
        , chr(10)
        ,(if return-value <> "":U then return-value else "":U)
        ,error-status:get-message(1))).
    end.
  end.
  if not avail tt-fin-doc then
  do:
    find first tt-fin-doc.
  end.
end.
if tt-fin-doc.contract-code <> 0 then
do:
  find first buf_contract where
    buf_contract.host-code = p-host-code
    AND buf_contract.contract-code = tt-fin-doc.contract-code  no-error .
  if not available buf_contract then
  do:
    undo, return error substitute ("&1 &2 &3&4Неверный параметр p-contract-code или значение поля contract-code &5"
      ,vss-workfile
      ,vss-revision
      ,vss-description
      ,chr(10)
      ,tt-fin-doc.contract-code).
  end.
  assign
    v-curr-code = buf_contract.curr-code
    .
  if (tt-fin-doc.payer-type <> '':U
    and tt-fin-doc.payer-code <> 0)
    then
  do:
    FIND FIRST buf_payer NO-LOCK WHERE
      buf_payer.obj-type = tt-fin-doc.payer-type
      AND buf_payer.obj-code = tt-fin-doc.payer-code NO-ERROR .
    if not avail buf_payer then
    do:
      undo, return error substitute("&1& 2& 3&4 Неверный ПЛАТЕЛЬЩИК &5&6 в контракте &7"
        ,vss-workfile
        ,vss-revision
        ,vss-description
        ,chr(10)
        ,tt-fin-doc.payer-type
        ,tt-fin-doc.payer-code
        ,buf_contract.contract-code
        ).
    end.
    if buf_payer.obj-type = 'орг':U then
    do:
      find first buf_payer-firm no-lock where
        buf_payer-firm.firm-code = buf_payer.obj-code.
    end.
    else
    do:
      find first buf_payer-person no-lock where
        buf_payer-person.psn-code = buf_payer.obj-code.
    end.
  end.
  if tt-fin-doc.receiver-type <> '':U
    and tt-fin-doc.receiver-code <> 0
    then
  do:
    FIND FIRST buf_receiver WHERE
      buf_receiver.obj-type = tt-fin-doc.receiver-type
      AND buf_receiver.obj-code = tt-fin-doc.receiver-code NO-LOCK .
    if not avail buf_receiver then
    do:
      undo, return error substitute("&1& 2& 3&4 Неверный ПОЛУЧАТЕЛЬ &5&6 в контракте &7"
        ,vss-workfile
        ,vss-revision
        ,vss-description
        ,chr(10)
        ,tt-fin-doc.receiver-type
        ,tt-fin-doc.receiver-code
        ,buf_contract.contract-code
        ).
    end.
    if buf_receiver.obj-type = 'орг':U then
    do:
      find first buf_receiver-firm no-lock where
        buf_receiver-firm.firm-code = buf_receiver.obj-code.
    end.
    else
    do:
      find first buf_receiver-person no-lock where
        buf_receiver-person.psn-code = buf_receiver.obj-code.
    end.
  end.
  if p-fin-doc-type = 'ппп':U
    or p-fin-doc-type = 'рпп':U then
  do:
    if tt-fin-doc.payer-code-schet <> 0
      then
    do:
      find first buf_payer-fin-schet no-lock where
        buf_payer-fin-schet.host-code = p-host-code
        AND  buf_payer-fin-schet.code-schet = tt-fin-doc.payer-code-schet no-error .
      if available buf_payer-fin-schet then
      do:
        find first buf_payer-fin-bank no-lock where
          buf_payer-fin-bank.host-code = p-host-code
          AND  buf_payer-fin-bank.code-bank = buf_payer-fin-schet.code-bank no-error .
        if not available buf_payer-fin-bank then
        do:
          undo, return error substitute("&1 &2 &3&4Неверный счет ПЛАТЕЛЬЩИКА &5 в контракте &6 &7"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,chr(10)
            ,buf_payer-fin-schet.code-schet
            ,buf_contract.contract-code
            ,(if not available buf_payer-fin-bank then "Не найден банк" else '':U)
            ).
        end.
      end.
      if not available buf_payer-fin-schet
        or not (buf_payer-fin-schet.cli-type = tt-fin-doc.payer-type
        and
        buf_payer-fin-schet.cli-code = tt-fin-doc.payer-code)
        or  (p-fin-doc-type = 'рпп':U
        and not(buf_payer-fin-schet.cli-type = 'орг':U
        AND
        buf_payer-fin-schet.cli-code = p-host-code)
        )
        then
      do:
        undo, return error substitute("&1 &2 &3&4Неверный счет ПОЛУЧАТЕЛЯ &5 в контракте &6 &7"
          ,vss-workfile
          ,vss-revision
          ,vss-description
          ,chr(10)
          ,buf_payer-fin-schet.code-schet
          ,buf_contract.contract-code
          ,(if not available buf_payer-fin-schet then "Не найден такой счет" else '':U)
          ).
      end.
      if p-mode = 'ДОБАВЛЕНИЕ':U
        and available buf_payer-fin-schet
        and buf_payer-fin-schet.status_ <> 'тек':U then
      do:
        undo, return error substitute("Статус счета с кодом &1 для ПЛАТЕЛЬЩИКА &2&3 &4"
          ,p-payer-code-schet
          ,buf_payer-fin-schet.cli-type
          ,buf_payer-fin-schet.cli-code
          ,buf_payer-fin-schet.status_
          ).
      end.
      if p-mode = 'ДОБАВЛЕНИЕ':U
        and available buf_payer-fin-bank
        and buf_payer-fin-bank.status_ <> 'тек':U then
      do:
        undo, return error substitute("Статус банка с кодом &1 &2"
          ,buf_payer-fin-bank.code-bank
          ,buf_payer-fin-bank.status_).
      end.
    end.
    if tt-fin-doc.receiver-code-schet <> 0
      then
    do:
      find first buf_receiver-fin-schet no-lock where
        buf_receiver-fin-schet.host-code = p-host-code
        AND  buf_receiver-fin-schet.code-schet = tt-fin-doc.receiver-code-schet no-error .
      if available buf_receiver-fin-schet then
      do:
        find first buf_receiver-fin-bank no-lock where
          buf_receiver-fin-bank.host-code = tt-fin-doc.host-code
          AND  buf_receiver-fin-bank.code-bank = buf_receiver-fin-schet.code-bank .
        if not available buf_receiver-fin-bank then
        do:
          undo, return error substitute("&1 &2 &3&4Неверный счет ПОЛУЧАТЕЛЯ &5 в контракте &6 &7"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,chr(10)
            ,buf_receiver-fin-schet.code-schet
            ,buf_payer-fin-bank.code-bank
            ,(if not available buf_receiver-fin-bank then "Не найден банк" else '':U)
            ).
        end.
      end.
      if not available buf_receiver-fin-schet
        OR (not (buf_receiver-fin-schet.cli-type = tt-fin-doc.receiver-type
        and
        buf_receiver-fin-schet.cli-code = tt-fin-doc.receiver-code)
        )
        or
        (p-fin-doc-type = 'ппп':U
        and not (
        buf_receiver-fin-schet.cli-type = 'орг':U
        AND
        buf_receiver-fin-schet.cli-code = p-host-code)
        )
        then
      do:
        undo, return error substitute("&1 &2 &3&4Неверный счет ПОЛУЧАТЕЛЯ &5 в контракте &6 &7"
          ,vss-workfile
          ,vss-revision
          ,vss-description
          ,chr(10)
          ,tt-fin-doc.receiver-code-schet
          ,buf_payer-fin-bank.code-bank
          ,(if not available buf_receiver-fin-schet then "Не найден такой счет" else '':U)
          ).
      end.
      if p-mode = 'ДОБАВЛЕНИЕ':U
        and available buf_receiver-fin-schet
        and buf_receiver-fin-schet.status_ <> 'тек':U then
      do:
        undo, return error substitute("Статус счета с кодом &1 для ПОЛУЧАТЕЛЯ &2&3 &4"
          ,p-receiver-code-schet
          ,buf_receiver-fin-schet.cli-type
          ,buf_receiver-fin-schet.cli-code
          ,buf_receiver-fin-schet.status_
          ).
      end.
      if p-mode = 'ДОБАВЛЕНИЕ':U
        and available buf_receiver-fin-bank
        and buf_receiver-fin-bank.status_ <> 'тек':U then
      do:
        undo, return error substitute("Статус банка с кодом &1 &2"
          ,buf_receiver-fin-bank.code-bank
          ,buf_receiver-fin-bank.status_).
      end.
    end.
  end.
  run get-fin-code-descr in this-procedure (
    input 'ДОБАВЛЕНИЕ':U
    ,input tt-fin-doc.cor-acc1
    ,input tt-fin-doc.cor-acc
    ,input tt-fin-doc.an-uchet-code
    ,input tt-fin-doc.cel-nazn-code
    ,input-output tt-fin-doc.cor-acc1-value
    ,input-output tt-fin-doc.cor-acc-value
    ,input-output tt-fin-doc.an-uchet-value
    ,input-output tt-fin-doc.cel-nazn-value
    ,output f-cor-acc1-descr
    ,output f-cor-acc-descr
    ,output f-an-uchet-descr
    ,output f-cel-nazn-descr
    ).
end.
if tt-fin-doc.status_ <> 'факт':U then
do:
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "payer-name"
    , input "ПЛАТЕЛЬЩИК"
    , input (p-limit-access < 1)
    , input '':U
    , input yes
    ).
  if tt-fin-doc.fin-ext-doc-type <> 'рко':U
    and tt-fin-doc.fin-ext-doc-type <> 'пко':U
    and tt-fin-doc.fin-ext-doc-type <> 'апп':U
    and tt-fin-doc.fin-ext-doc-type <> 'апр':U
    then
  do:
    run tempchgs-create-lable-record in this-procedure (
      input 'fin-doc':U
      , input "payer-inn"
      , input "ИНН ПЛАТЕЛЬЩИКА"
      , input (p-limit-access < 1)
      , input '':U
      , input yes
      ).
    run tempchgs-create-lable-record in this-procedure (
      input 'fin-doc':U
      , input "payer-kpp"
      , input "КПП ПЛАТЕЛЬЩИКА"
      , input (p-limit-access < 1)
      , input '':U
      , input yes
      ).
  end.
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "payer-bank-name"
    , input "БАНК ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "payer-bik"
    , input "БИК ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "payer-bank-city"
    , input "Город банка ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "payer-r-schet"
    , input "Р/С ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "payer-c-schet"
    , input "К/С ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input 'payer-code-schet'
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "payer-code-schet"
    , input "Внутр. код счета ПЛАТЕЛЬЩИКА"
    , input (p-limit-access < 1)
    , input '':U
    , input yes
    ).
  CASE tt-fin-doc.fin-ext-doc-type:
    when 'пко':U then
      do:
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "receiver-okpo"
          , input "ОКПО"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "receiver-sign2"
          , input "Гл. бухгалтер"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "receiver-sign3"
          , input "Кассир"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
      end.
    when 'рко':U then
      do:
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-okpo"
          , input "ОКПО"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-sign1"
          , input "Директор"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-sign2"
          , input "Гл.бухгалтер"
          , input (p-limit-access < 1)
          , input no
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-sign3"
          , input "Кассир"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
      end.
    when 'ппп':U then
      do:
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-sign1"
          , input "Подпись плательщика 1"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-sign2"
          , input "Подпись плательщика 2"
          , input (p-limit-access < 10)
          , input '':U
          , input yes
          ).
      end.
    when 'рпп':U then
      do:
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-sign1"
          , input "Подпись плательщика 1"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
      end.
    when 'апп':U then
      do:
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "receiver-okpo"
          , input "ОКПО (ПОЛУЧАТЕЛЯ)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-sign1"
          , input "Подпись ПЛАТЕЛЬЩИКА (Руководитель)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "receiver-sign1"
          , input "Подпись ПОЛУЧАТЕЛЯ (Руководитель)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
      end.
    when 'апр':U then
      do:
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-okpo"
          , input "ОКПО (ПЛАТЕЛЬЩИКА)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "payer-sign1"
          , input "Подпись ПЛАТЕЛЬЩИКА (Руководитель)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
        run tempchgs-create-lable-record in this-procedure (
          input 'fin-doc':U
          , input "receiver-sign1"
          , input "Подпись ПОЛУЧАТЕЛЯ (Руководитель)"
          , input (p-limit-access < 1)
          , input '':U
          , input yes
          ).
      end.
  END CASE.
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "receiver-name"
    , input "ПОЛУЧАТЕЛЬ"
    , input (p-limit-access < 1)
    , input '':U
    , input yes
    ).
  if tt-fin-doc.fin-ext-doc-type <> 'рко':U
    and tt-fin-doc.fin-ext-doc-type <> 'пко':U
    and tt-fin-doc.fin-ext-doc-type <> 'апп':U
    and tt-fin-doc.fin-ext-doc-type <> 'апр':U
    then
  do:
    run tempchgs-create-lable-record in this-procedure (
      input 'fin-doc':U
      , input "receiver-inn"
      , input "ИНН ПОЛУЧАТЕЛЯ"
      , input (p-limit-access < 1)
      , input '':U
      , input yes
      ).
    run tempchgs-create-lable-record in this-procedure (
      input 'fin-doc':U
      , input "receiver-kpp"
      , input "КПП ПОЛУЧАТЕЛЯ"
      , input (p-limit-access < 1)
      , input '':U
      , input yes
      ).
  end.
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "receiver-code-schet"
    , input "Внутр. код счета ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input '':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "receiver-bank-name"
    , input "Банк ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "receiver-bank-city"
    , input "Город банка ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "receiver-bik"
    , input "БИК ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "receiver-r-schet"
    , input "Р/С ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "receiver-c-schet"
    , input "К/С ПОЛУЧАТЕЛЯ"
    , input (p-limit-access < 1)
    , input 'receiver-code-schet':U
    , input yes
    ).
  if tt-fin-doc.fin-ext-doc-type <> 'рпп':U
    and  tt-fin-doc.fin-ext-doc-type <> 'ппп':U then
  do:
    run tempchgs-create-lable-record in this-procedure (
      input 'fin-doc':U
      , input "cor-acc1-value"
      , input "Корсчет касса"
      , input (p-limit-access < 10)
      , input 'cor-acc1':U
      , input yes
      ).
    run tempchgs-create-lable-record in this-procedure (
      input 'fin-doc':U
      , input "cor-acc1"
      , input "Корсчет касса (внутр. №)"
      , input (p-limit-access < 10)
      , input '':U
      , input yes
      ).
  end.
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "cor-acc-value"
    , input "Корсчет кредит"
    , input (p-limit-access < 10)
    , input 'cor-acc':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "cor-acc"
    , input "Корсчет кредит (внутр. №)"
    , input (p-limit-access < 10)
    , input '':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "an-uchet-value"
    , input "Код ан. учета"
    , input (p-limit-access < 10)
    , input 'an-uchet-code':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "an-uchet-code"
    , input "Код ан. учета (внутр. №)"
    , input (p-limit-access < 10)
    , input '':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "cel-nazn-value"
    , input "Код целевого назнач."
    , input (p-limit-access < 10)
    , input 'cel-nazn-code':U
    , input yes
    ).
  run tempchgs-create-lable-record in this-procedure (
    input 'fin-doc':U
    , input "cel-nazn-code"
    , input "Код целевого назнач. (внутр. №)"
    , input (p-limit-access < 10)
    , input '':U
    , input yes
    ).
  if p-mode = 'ИЗМЕНЕНИЕ':U
    or p-mode = 'ПРОСМОТР':U
    then
  do:
    run ref/view-chg.w ( input parparentproc
      ,input this-procedure:handle
      ,input 'fin-doc':U
      ,input buffer ttc-fin-doc:handle
      ,input buffer tt-fin-doc:handle
      ,input p-mode
      ,input p-limit-access
      ,input substitute("Несоответствия в реквизитах платежа &1, вызванные изменениями справочников системы и/или договора"
      , tt-fin-doc.fin-doc-code)
      ,input "В платеже"
      ,input "Текущ.рек-ты справочников(договора)"
      ,input '':U
      ,input (if p-mode = 'ИЗМЕНЕНИЕ':U
      then substitute("Вы можете подтвердить изменения, если они не противоречат статусу платежа (выделенные поля)&1" +
      "изменения реквизитов, которые не могут быть подтверждены в данном статусе, запрещены (серые поля)"
      , chr(10))
      else substitute("Увидеть какие изменения могут быть подтверждены в текущем статусе платежа,&1можно ТОЛЬКО в режиме редактирования"
      , chr(10))
      )
      ,output v-ok
      ) no-error .
    if error-status:error then
    do:
    end.
    if p-mode <> 'ПРОСМОТР':U
      and v-ok
      then
    do:
      for each temp-labels where temp-labels.f_update :
        if temp-labels.f_update then
          assign
            buffer ttc-fin-doc:buffer-field(temp-labels.f_name):buffer-value = buffer tt-fin-doc:buffer-field(temp-labels.f_name):buffer-value
            .
      end.
    end.
    run get-fin-schet  in this-procedure (
      buffer buf_payer-fin-schet
      ,buffer buf_receiver-fin-schet
      ,buffer buf_payer-fin-bank
      ,buffer buf_receiver-fin-bank
      ,input ttc-fin-doc.payer-code-schet
      ,input ttc-fin-doc.receiver-code-schet
      ,input ttc-fin-doc.payer-type
      ,input ttc-fin-doc.payer-code
      ,input ttc-fin-doc.receiver-type
      ,input ttc-fin-doc.receiver-code
      ,input p-mode <> 'ПРОСМОТР':U
      ,input-output ttc-fin-doc.payer-bank-name
      ,input-output ttc-fin-doc.receiver-bank-name
      ,input-output ttc-fin-doc.payer-bank-city
      ,input-output ttc-fin-doc.receiver-bank-city
      ,input-output ttc-fin-doc.payer-bik
      ,input-output ttc-fin-doc.receiver-bik
      ,input-output ttc-fin-doc.payer-r-schet
      ,input-output ttc-fin-doc.receiver-r-schet
      ,input-output ttc-fin-doc.payer-c-schet
      ,input-output ttc-fin-doc.receiver-c-schet
      ) no-error .
    if error-status:error then
    do:
      undo, return error return-value .
    end.
    run get-fin-code-descr in this-procedure (
      input p-mode
      ,input ttc-fin-doc.cor-acc1
      ,input ttc-fin-doc.cor-acc
      ,input ttc-fin-doc.an-uchet-code
      ,input ttc-fin-doc.cel-nazn-code
      ,input-output ttc-fin-doc.cor-acc1-value
      ,input-output ttc-fin-doc.cor-acc-value
      ,input-output ttc-fin-doc.an-uchet-value
      ,input-output ttc-fin-doc.cel-nazn-value
      ,output f-cor-acc1-descr
      ,output f-cor-acc-descr
      ,output f-an-uchet-descr
      ,output f-cel-nazn-descr
      ).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U
    and v-copy-mode = yes
    then
  do:
    run ref/view-chg.w ( input parparentproc
      ,input this-procedure:handle
      ,input 'fin-doc':U
      ,input buffer tt-fin-doc:handle
      ,input buffer buf_a0-tt-fin-doc:handle
      ,input p-mode
      ,input p-limit-access
      ,input substitute("Несоответствия в реквизитах платежа &1, вызванные изменениями в справочниках системы и/или договора"
      , tt-fin-doc.fin-doc-code)
      ,input "В платеже в соотв. с Текущ.рек-ми справочников(договора)"
      ,input substitute("В платеже-ОРИГИНАЛЕ")
      ,input "":U
      ,input  substitute("Вы можете подтвердить изменения, если они не противоречат статусу платежа (выделенные поля)&1" +
      "изменения реквизитов, которые не могут быть подтверждены в данном статусе, запрещены (серые поля)"
      , chr(10))
      ,output v-ok
      ) no-error .
    if v-ok then
    do:
      for each temp-labels where temp-labels.f_update = yes:
        assign
          buffer tt-fin-doc:buffer-field(temp-labels.f_name):buffer-value = buffer buf_a0-tt-fin-doc:buffer-field(temp-labels.f_name):buffer-value
          .
      end.
    end.
    run get-fin-schet  in this-procedure (
      buffer buf_payer-fin-schet
      ,buffer buf_receiver-fin-schet
      ,buffer buf_payer-fin-bank
      ,buffer buf_receiver-fin-bank
      ,input tt-fin-doc.payer-code-schet
      ,input tt-fin-doc.receiver-code-schet
      ,input tt-fin-doc.payer-type
      ,input tt-fin-doc.payer-code
      ,input tt-fin-doc.receiver-type
      ,input tt-fin-doc.receiver-code
      ,input yes
      ,input-output tt-fin-doc.payer-bank-name
      ,input-output tt-fin-doc.receiver-bank-name
      ,input-output tt-fin-doc.payer-bank-city
      ,input-output tt-fin-doc.receiver-bank-city
      ,input-output tt-fin-doc.payer-bik
      ,input-output tt-fin-doc.receiver-bik
      ,input-output tt-fin-doc.payer-r-schet
      ,input-output tt-fin-doc.receiver-r-schet
      ,input-output tt-fin-doc.payer-c-schet
      ,input-output tt-fin-doc.receiver-c-schet
      ) no-error .
    if error-status:error then
    do:
      undo, return error return-value .
    end.
    run get-fin-code-descr in this-procedure (
      input 'ИЗМЕНЕНИЕ':U
      ,input tt-fin-doc.cor-acc1
      ,input tt-fin-doc.cor-acc
      ,input tt-fin-doc.an-uchet-code
      ,input tt-fin-doc.cel-nazn-code
      ,input-output tt-fin-doc.cor-acc1-value
      ,input-output tt-fin-doc.cor-acc-value
      ,input-output tt-fin-doc.an-uchet-value
      ,input-output tt-fin-doc.cel-nazn-value
      ,output f-cor-acc1-descr
      ,output f-cor-acc-descr
      ,output f-an-uchet-descr
      ,output f-cel-nazn-descr
      ).
  end.
end.
if  tt-fin-doc.status_ = 'факт':U
  or (p-mode = 'ДОБАВЛЕНИЕ':U
  and v-copy-mode = no) then
do:
  run get-fin-schet  in this-procedure (
    buffer buf_payer-fin-schet
    ,buffer buf_receiver-fin-schet
    ,buffer buf_payer-fin-bank
    ,buffer buf_receiver-fin-bank
    ,input tt-fin-doc.payer-code-schet
    ,input tt-fin-doc.receiver-code-schet
    ,input tt-fin-doc.payer-type
    ,input tt-fin-doc.payer-code
    ,input tt-fin-doc.receiver-type
    ,input tt-fin-doc.receiver-code
    ,input (tt-fin-doc.status_ <> 'факт':U)
    ,input-output tt-fin-doc.payer-bank-name
    ,input-output tt-fin-doc.receiver-bank-name
    ,input-output tt-fin-doc.payer-bank-city
    ,input-output tt-fin-doc.receiver-bank-city
    ,input-output tt-fin-doc.payer-bik
    ,input-output tt-fin-doc.receiver-bik
    ,input-output tt-fin-doc.payer-r-schet
    ,input-output tt-fin-doc.receiver-r-schet
    ,input-output tt-fin-doc.payer-c-schet
    ,input-output tt-fin-doc.receiver-c-schet
    ).
  run get-fin-code-descr in this-procedure (
    input 'ДОБАВЛЕНИЕ':U
    ,input tt-fin-doc.cor-acc1
    ,input tt-fin-doc.cor-acc
    ,input tt-fin-doc.an-uchet-code
    ,input tt-fin-doc.cel-nazn-code
    ,input-output tt-fin-doc.cor-acc1-value
    ,input-output tt-fin-doc.cor-acc-value
    ,input-output tt-fin-doc.an-uchet-value
    ,input-output tt-fin-doc.cel-nazn-value
    ,output f-cor-acc1-descr
    ,output f-cor-acc-descr
    ,output f-an-uchet-descr
    ,output f-cel-nazn-descr
    ).
end.
if valid-handle(par-call-handle) then
  run set-buffers in par-call-handle(
    input recid(buf_clients-host)
    ,input recid(buf_firm)
    ,input recid(buf_sysconf)
    ,input recid(buf_fin-code-cor-acc)
    ,input recid(buf_fin-code-cor-acc1)
    ,input recid(buf_fin-code-an-uchet)
    ,input recid(buf_fin-code-cel-nazn)
    ,input recid(buf_currency)
    ,input recid(buf_contract-currency)
    ,input recid(buf_receiver)
    ,input recid(buf_payer)
    ,input recid(buf_curr_sysconf)
    ,input recid(buf_payer-fin-schet)
    ,input recid(buf_payer-fin-bank)
    ,input recid(buf_payer-firm)
    ,input recid(buf_payer-person)
    ,input recid(buf_receiver-fin-schet)
    ,input recid(buf_receiver-fin-bank)
    ,input recid(buf_receiver-firm)
    ,input recid(buf_receiver-person)
    ,input recid(buf_contract)
    ,input recid(buf_fin-ob)
    ,input recid(buf_clients-obj)
    ,input f-cor-acc1-descr
    ,input f-cor-acc-descr
    ,input f-an-uchet-descr
    ,input f-cel-nazn-descr
    ) no-error .
if p-mode = 'ДОБАВЛЕНИЕ':U then
do:
  for each buf_tt-fin-doc no-lock where
    buf_tt-fin-doc.host-code = p-host-code
    AND buf_tt-fin-doc.fin-doc-code = v-fin-doc-code:
    find first tt0-fin-doc where
      tt0-fin-doc.host-code = p-host-code
      AND tt0-fin-doc.fin-doc-code = 0 no-error.
    if not available tt0-fin-doc then
    do:
      create tt0-fin-doc.
    end.
    buffer-copy buf_tt-fin-doc to tt0-fin-doc.
    release tt0-fin-doc.
  END.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then
do:
  for each bufc_ttc-fin-doc no-lock where
    bufc_ttc-fin-doc.host-code = p-host-code
    AND bufc_ttc-fin-doc.fin-doc-code = v-fin-doc-code:
    find first tt0c-fin-doc where
      tt0c-fin-doc.host-code = p-host-code
      AND tt0c-fin-doc.fin-doc-code = v-fin-doc-code no-error.
    if not available tt0c-fin-doc then
    do:
      create tt0c-fin-doc.
    end.
    buffer-copy bufc_ttc-fin-doc to tt0c-fin-doc.
    release tt0c-fin-doc.
  END.
end.
end.
procedure get-fin-code-descr :
  define input parameter p-mode as character no-undo .
  define input parameter p-cor-acc1 like ub.fin-doc.cor-acc1 no-undo .
  define input parameter p-cor-acc like ub.fin-doc.cor-acc no-undo .
  define input parameter p-an-uchet-code like ub.fin-doc.an-uchet-code no-undo .
  define input parameter p-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo .
  define input-output parameter p-cor-acc1-value like ub.fin-doc.cor-acc1-value no-undo .
  define input-output parameter p-cor-acc-value like ub.fin-doc.cor-acc-value no-undo .
  define input-output parameter p-an-uchet-value like ub.fin-doc.an-uchet-value no-undo .
  define input-output parameter p-cel-nazn-value like ub.fin-doc.cel-nazn-value no-undo .
  define output parameter f-cor-acc1-descr as character no-undo .
  define output parameter f-cor-acc-descr as character no-undo .
  define output parameter f-an-uchet-descr as character no-undo .
  define output parameter f-cel-nazn-descr as character no-undo .
  define variable v-cor-acc1-value like ub.fin-doc.cor-acc1-value no-undo .
  define variable v-cor-acc-value  like ub.fin-doc.cor-acc-value no-undo .
  define variable v-an-uchet-value like ub.fin-doc.an-uchet-value no-undo .
  define variable v-cel-nazn-value like ub.fin-doc.cel-nazn-value no-undo .
  if p-cor-acc1 = ? then p-cor-acc1 = 0.
  if p-cor-acc = ? then p-cor-acc = 0.
  if p-an-uchet-code = ? then p-an-uchet-code = 0 .
  if p-cel-nazn-code = ? then p-cel-nazn-code = 0 .
  assign
    f-cor-acc1-descr = '':U
    f-cor-acc-descr  = '':U
    f-an-uchet-descr = '':U
    f-cel-nazn-descr = '':U
    .
  if tt-fin-doc.fin-ext-doc-type = 'пко':U
    or tt-fin-doc.fin-ext-doc-type = 'рко':U
    or tt-fin-doc.fin-ext-doc-type = 'апп':U
    or tt-fin-doc.fin-ext-doc-type = 'апр':U then
  do:
    if p-cor-acc1 <> 0 then
    do:
      find first buf_fin-code-cor-acc1 no-lock where
        buf_fin-code-cor-acc1.fin-code  = p-cor-acc1
        AND buf_fin-code-cor-acc1.host-code  = tt-fin-doc.host-code
        no-error.
      if available buf_fin-code-cor-acc1
        and buf_fin-code-cor-acc1.status_ = integer('0':U) then
      do:
        assign
          f-cor-acc1-descr = buf_fin-code-cor-acc1.descr
          v-cor-acc1-value = buf_fin-code-cor-acc1.code-value
          .
      end.
      if not available buf_fin-code-cor-acc1
        or (buf_fin-code-cor-acc1.code-value <> p-cor-acc1-value and p-mode <> 'ДОБАВЛЕНИЕ':U and p-cor-acc1-value = '':U)
        or buf_fin-code-cor-acc1.status_ <> integer('0':U)
        then
      do:
        assign
          f-cor-acc1-descr = "!!!Код больше не существует"
          .
      end.
      if p-mode <> 'ПРОСМОТР':U then
      do:
        p-cor-acc1-value = v-cor-acc1-value.
      end.
    end.
    else if p-mode <> 'ПРОСМОТР':U then
      do:
        p-cor-acc1-value = '':U.
      end.
  end.
  if p-cor-acc <> 0 then
  do:
    find first buf_fin-code-cor-acc no-lock where
      buf_fin-code-cor-acc.fin-code  = p-cor-acc
      AND buf_fin-code-cor-acc.host-code  = tt-fin-doc.host-code
      no-error.
    if available buf_fin-code-cor-acc
      and buf_fin-code-cor-acc.status_ = integer('0':U)
      then
    do:
      assign
        f-cor-acc-descr = buf_fin-code-cor-acc.descr
        v-cor-acc-value = buf_fin-code-cor-acc.code-value
        .
    end.
    if not available buf_fin-code-cor-acc
      or (buf_fin-code-cor-acc.code-value <> p-cor-acc-value and p-mode <> 'ДОБАВЛЕНИЕ':U and p-cor-acc-value = '':U)
      or buf_fin-code-cor-acc.status_ <> integer('0':U)
      then
    do:
      assign
        f-cor-acc-descr = "!!!Код больше не существует"
        .
    end.
    if p-mode <> 'ПРОСМОТР':U then
    do:
      p-cor-acc-value = v-cor-acc-value.
    end.
  end.
  else if p-mode <> 'ПРОСМОТР':U then
    do:
      p-cor-acc-value = '':U.
    end.
  if p-an-uchet-code <> 0 then
  do:
    find first buf_fin-code-an-uchet no-lock where
      buf_fin-code-an-uchet.fin-code  = p-an-uchet-code
      AND buf_fin-code-an-uchet.host-code  = tt-fin-doc.host-code
      no-error.
    if available buf_fin-code-an-uchet
      and buf_fin-code-an-uchet.status_ = integer('0':U)
      then
    do:
      assign
        f-an-uchet-descr = buf_fin-code-an-uchet.descr
        v-an-uchet-value = buf_fin-code-an-uchet.code-value
        .
    end.
    if not available buf_fin-code-an-uchet
      or (buf_fin-code-an-uchet.code-value <> p-an-uchet-value and p-mode <> 'ДОБАВЛЕНИЕ':U and p-an-uchet-value = '':U)
      or buf_fin-code-an-uchet.status_ <> integer('0':U)
      then
    do:
      assign
        f-an-uchet-descr = "!!!Код больше не существует".
      .
    end.
    if p-mode <> 'ПРОСМОТР':U then
    do:
      p-an-uchet-value = v-an-uchet-value.
    end.
  end.
  else if p-mode <> 'ПРОСМОТР':U then
    do:
      p-an-uchet-value = '':U.
    end.
  if p-cel-nazn-code <> 0 then
  do:
    find first buf_fin-code-cel-nazn no-lock where
      buf_fin-code-cel-nazn.fin-code  = p-cel-nazn-code
      AND buf_fin-code-cel-nazn.host-code  = tt-fin-doc.host-code
      no-error.
    if available buf_fin-code-cel-nazn
      and buf_fin-code-cel-nazn.status_ = integer('0':U)
      then
    do:
      assign
        f-cel-nazn-descr = buf_fin-code-cel-nazn.descr
        v-cel-nazn-value = Buf_fin-code-cel-nazn.code-value
        .
    end.
    if not available buf_fin-code-cel-nazn
      or (buf_fin-code-cel-nazn.code-value <> p-cel-nazn-value and p-mode <> 'ДОБАВЛЕНИЕ':U and p-cel-nazn-value = '':U)
      or buf_fin-code-cel-nazn.status_ <> integer('0':U)
      then
    do:
      assign
        f-cel-nazn-descr = "!!!Код больше не существует"
        .
    end.
    if p-mode <> 'ПРОСМОТР':U then
    do:
      p-cel-nazn-value = v-cel-nazn-value.
    end.
  end.
  else if p-mode <> 'ПРОСМОТР':U then
    do:
      p-cel-nazn-value = '':U.
    end.
end procedure.
procedure get-fin-schet :
  define parameter buffer buf_payer-fin-schet    for ub.fin-schet  .
  define parameter buffer buf_receiver-fin-schet for ub.fin-schet .
  define parameter buffer buf_payer-fin-bank     for ub.fin-bank  .
  define parameter buffer buf_receiver-fin-bank  for ub.fin-bank  .
  define input parameter p-payer-code-schet like ub.fin-schet.code-schet no-undo .
  define input parameter p-receiver-code-schet like ub.fin-schet.code-schet no-undo .
  define input parameter p-payer-type like ub.fin-doc.payer-type no-undo .
  define input parameter p-payer-code like ub.fin-doc.payer-code no-undo .
  define input parameter p-receiver-type like ub.fin-doc.receiver-type no-undo .
  define input parameter p-receiver-code like ub.fin-doc.receiver-code no-undo .
  define input parameter p-refill-if-nees as logical no-undo .
  define input-output parameter p-payer-bank-name like ub.fin-doc.payer-bank-name no-undo .
  define input-output parameter p-receiver-bank-name like ub.fin-doc.receiver-bank-name no-undo .
  define input-output parameter p-payer-bank-city like ub.fin-doc.payer-bank-city no-undo .
  define input-output parameter p-receiver-bank-city like ub.fin-doc.receiver-bank-city no-undo .
  define input-output parameter p-payer-bik like ub.fin-doc.payer-bik no-undo .
  define input-output parameter p-receiver-bik like ub.fin-doc.receiver-bik no-undo .
  define input-output parameter p-payer-r-schet like ub.fin-doc.payer-r-schet no-undo .
  define input-output parameter p-receiver-r-schet like ub.fin-doc.receiver-r-schet no-undo .
  define input-output parameter p-payer-c-schet like ub.fin-doc.payer-c-schet no-undo .
  define input-output parameter p-receiver-c-schet like ub.fin-doc.receiver-c-schet no-undo .
  define variable v-refill-payer    as logical no-undo .
  define variable v-refill-receiver as logical no-undo .
  do
    on error undo, return error
    :
    if p-fin-ext-doc-type <> 'ппп':U
      and p-fin-ext-doc-type <> 'рпп':U then return.
    if (not available buf_payer-fin-schet and  p-payer-code-schet <> 0 and p-payer-code-schet <> ?)
      or (available buf_payer-fin-schet and p-payer-code-schet <> buf_payer-fin-schet.code-schet) then
    do:
      if p-payer-code-schet = 0
        or p-payer-code-schet = ? then
      do:
        release buf_payer-fin-schet.
        release buf_payer-fin-bank.
        v-refill-payer = yes.
      end.
      else
      do:
        v-refill-payer = yes.
        find first buf_payer-fin-schet no-lock where
          buf_payer-fin-schet.host-code = p-host-code
          AND  buf_payer-fin-schet.code-schet = p-payer-code-schet  no-error .
        if available buf_payer-fin-schet then
        do:
          if not available buf_payer-fin-bank
            or buf_payer-fin-bank.code-bank <> buf_payer-fin-schet.code-bank then
          do:
            find first buf_payer-fin-bank no-lock where
              buf_payer-fin-bank.host-code = p-host-code
              AND  buf_payer-fin-bank.code-bank = buf_payer-fin-schet.code-bank no-error .
          end.
        end.
        if not available buf_payer-fin-schet
          or not available buf_payer-fin-bank
          or (
          (p-mode = 'ДОБАВЛЕНИЕ':U
          and
          NOT (p-payer-type = buf_payer-fin-schet.cli-type
          and
          p-payer-code = buf_payer-fin-schet.cli-code  )
          )
          OR (
          p-mode <> 'ДОБАВЛЕНИЕ':U
          AND
          not (buf_payer-fin-schet.cli-type = p-payer-type
          and
          buf_payer-fin-schet.cli-code = p-payer-code)
          )
          or
          (p-fin-doc-type = 'рпп':U
          and not(buf_payer-fin-schet.cli-type = 'орг':U
          AND
          buf_payer-fin-schet.cli-code = p-host-code)
          ))
          then
        do:
          undo, return error substitute("&1 &2 &3&4Неверный параметр p-payer-fin-schet или значение поля payer-code-schet &5&4&6"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,chr(10)
            ,buf_payer-fin-schet.code-schet
            ,(if not available buf_payer-fin-bank then "Не найден банк" else '':U)
            ).
        end.
      end.
      if p-mode = 'ДОБАВЛЕНИЕ':U
        and available buf_payer-fin-schet
        and buf_payer-fin-schet.status_ <> 'тек':U then
      do:
        undo, return error substitute("Статус счета с кодом &1 для ПЛАТЕЛЬЩИКА &2&3 &4"
          ,p-payer-code-schet
          ,buf_payer-fin-schet.cli-type
          ,buf_payer-fin-schet.cli-code
          ,buf_payer-fin-schet.status_
          ).
      end.
      if p-mode = 'ДОБАВЛЕНИЕ':U
        and available buf_payer-fin-bank
        and buf_payer-fin-bank.status_ <> 'тек':U then
      do:
        undo, return error substitute("Статус банка с кодом &1 &2"
          ,buf_payer-fin-bank.code-bank
          ,buf_payer-fin-bank.status_).
      end.
    end.
    if (not available buf_receiver-fin-schet and  p-receiver-code-schet <> 0 and p-receiver-code-schet <> ?)
      or (available buf_receiver-fin-schet and p-receiver-code-schet <> buf_receiver-fin-schet.code-schet) then
    do:
      if p-receiver-code-schet = 0
        or p-receiver-code-schet = ? then
      do:
        release buf_receiver-fin-schet.
        release buf_receiver-fin-bank.
        V-REFILL-receiver = yes.
      end.
      else
      do:
        v-refill-receiver = yes.
        find first buf_receiver-fin-schet no-lock where
          buf_receiver-fin-schet.host-code = p-host-code
          AND  buf_receiver-fin-schet.code-schet = p-receiver-code-schet  no-error .
        if available buf_receiver-fin-schet then
        do:
          if not available buf_receiver-fin-bank
            or buf_receiver-fin-bank.code-bank <> buf_receiver-fin-schet.code-bank then
          do:
            find first buf_receiver-fin-bank no-lock where
              buf_receiver-fin-bank.host-code = p-host-code
              AND  buf_receiver-fin-bank.code-bank = buf_receiver-fin-schet.code-bank no-error .
          end.
        end.
        if not available buf_receiver-fin-schet
          or not available buf_receiver-fin-bank
          or (
          (p-mode = 'ДОБАВЛЕНИЕ':U
          and
          NOT (p-receiver-type = buf_receiver-fin-schet.cli-type
          and
          p-receiver-code = buf_receiver-fin-schet.cli-code  )
          )
          OR (
          p-mode <> 'ДОБАВЛЕНИЕ':U
          AND
          not (buf_receiver-fin-schet.cli-type = p-receiver-type
          and
          buf_receiver-fin-schet.cli-code = p-receiver-code)
          )
          or
          (p-fin-doc-type = 'ппп':U
          and not (
          buf_receiver-fin-schet.cli-type = 'орг':U
          AND
          buf_receiver-fin-schet.cli-code = p-host-code)
          ))
          then
        do:
          undo, return error substitute("&1 &2 &3&4Неверный параметр p-receiver-fin-schet или значение поля receiver-code-schet &5&4&6"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,chr(10)
            ,buf_receiver-fin-schet.code-schet
            ,(if not available buf_receiver-fin-bank then "Не найден банк" else '':U)
            ).
        end.
      end.
      if p-mode = 'ДОБАВЛЕНИЕ':U
        and available buf_receiver-fin-schet
        and buf_receiver-fin-schet.status_ <> 'тек':U then
      do:
        undo, return error substitute("Статус счета с кодом &1 для ПОЛУЧАТЕЛЯ &2&3 &4"
          ,p-receiver-code-schet
          ,buf_receiver-fin-schet.cli-type
          ,buf_receiver-fin-schet.cli-code
          ,buf_receiver-fin-schet.status_
          ).
      end.
      if p-mode = 'ДОБАВЛЕНИЕ':U
        and available buf_receiver-fin-bank
        and buf_receiver-fin-bank.status_ <> 'тек':U then
      do:
        undo, return error substitute("Статус банка с кодом &1 &2"
          ,buf_receiver-fin-bank.code-bank
          ,buf_receiver-fin-bank.status_).
      end.
    end.
    if p-refill-if-nees then
    do:
      if v-refill-payer then
      do:
        assign
          p-payer-bank-name = (if available buf_payer-fin-bank
                            then buf_payer-fin-bank.bank-name
                            else '':U)
          p-payer-bank-city = (if available buf_payer-fin-bank
                             then buf_payer-fin-bank.bank-city
                             else '':U)
          p-payer-bik       = (if available buf_payer-fin-bank
                                      then buf_payer-fin-bank.bik
                                      else "":U)
          p-payer-r-schet   = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.r-schet
                                    else "":U)
          p-payer-c-schet   = (if available buf_payer-fin-schet
                                    then buf_payer-fin-schet.c-schet
                                    else "":U)
          .
      end.
      if v-refill-receiver then
      do:
        assign
          p-receiver-bank-name = (if available buf_receiver-fin-bank
                            then buf_receiver-fin-bank.bank-name
                            else '':U)
          p-receiver-bank-city = (if available buf_receiver-fin-bank
                             then buf_receiver-fin-bank.bank-city
                             else '':U)
          p-receiver-bik       = (if available buf_receiver-fin-bank
                                      then buf_receiver-fin-bank.bik
                                      else "":U)
          p-receiver-r-schet   = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.r-schet
                                    else "":U)
          p-receiver-c-schet   = (if available buf_receiver-fin-schet
                                    then buf_receiver-fin-schet.c-schet
                                    else "":U)
          .
      end.
    end.
  end.
end procedure.
