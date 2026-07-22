block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: indocka.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/indocka.p $":U .
define variable vss-description as character no-undo initial "Утилита импорта документов по датам":U .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#libbcrcn as handle no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define input parameter parparentproc as   handle              no-undo.
define input parameter parobj-type   like ub.clients.obj-type no-undo.
define input parameter parobj-code   like ub.clients.obj-code no-undo.
define input parameter parfile-cli   as   character           no-undo.
define input parameter parfile-doc   as   character           no-undo.
define input parameter parstatus     as   integer             no-undo.
define input parameter paragnt       as   integer             no-undo.
define input parameter parboss       as   integer             no-undo.
define input parameter parwrkr       as   integer             no-undo.
define stream str-cli.
define stream str-cli-log.
define stream str-err.
define stream str-doc.
define stream str-doc-log.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable varfatal-error        as logical initial no no-undo.
define variable vartemp-str-cli       as character no-undo.
define variable vartemp-str-doc       as character no-undo.
define variable varln                 as integer   no-undo.
define variable varopen-err-cli       as logical initial no no-undo.
define variable varopen-err-doc       as logical initial no no-undo.
define variable varuser-action        as character no-undo.
define variable varprinted            as logical   no-undo.
define variable varfile-name-cli-log  as character no-undo.
define variable varfile-name-cli-err  as character no-undo.
define variable varfile-name-doc-log  as character no-undo.
define variable varfile-name-doc-err  as character no-undo.
define variable varobj-type           as character no-undo.
define variable varid-supp            as character no-undo.
define variable varobj-code           as integer   no-undo.
define variable varhost-code          as integer   no-undo.
define variable varcontract-code      as integer   no-undo.
define variable vardate               as date      no-undo.
define variable varprod-bc            as character no-undo.
define variable varqnty               as decimal   no-undo.
define variable varprice              as decimal   no-undo.
define variable varvat-pc             as decimal   no-undo.
define variable varresult             as character no-undo.
define variable vartype-bc            as character no-undo.
define variable varweight             as decimal   no-undo.
define variable vardb-num             as integer   no-undo.
define variable vartoday              as date      no-undo.
define variable vartime               as integer   no-undo.
define variable varuserid             as character no-undo.
define variable varday-end-fact-order as decimal   no-undo.
define variable vardoc-code           as character no-undo.
define variable varin-pay             as integer   no-undo.
define variable n-c                   like ub.gds-prt.node-code no-undo.
define variable varr-b                as character no-undo.
define variable varbase-rate          as decimal   no-undo.
define variable varbase-scale         as decimal   no-undo.
define variable varchg-inv            as logical   no-undo.
define variable varbc-pfx             as character no-undo.
define variable varbc-frmt            as character no-undo.
define variable varpar-type           as character no-undo.
define variable varend-new-line       as logical   no-undo.
define variable varcur-date           as date      no-undo.
define temp-table tt-id no-undo
field supp-type          as character
field supp-code          as integer
field id-supl-old-system as character
field contract-code      as integer
field ln                 as integer
index pi is unique primary ln
index supp supp-type supp-code contract-code
index id-supl-old-system is unique id-supl-old-system.
define temp-table tt-parts no-undo
field id-supl-old-system as character
field fact-date          as date
field b-code             as character
field qnty               as decimal
field price-cli          as decimal
field vat-pc             as decimal
field artic              as character
field prod-type          as character
field prod-code          as integer
field price-sale         as decimal
field ln                 as integer
index pi is unique primary ln.
define temp-table tt-result-doc no-undo
field supp-type          as character
field supp-code          as integer
field supp-name          as character
field contract-code      as integer
field fact-date          as date
field count-doc          as integer
index pi is unique primary supp-type supp-code contract-code fact-date count-doc
index fact-date fact-date
.
define temp-table tt-result no-undo
field supp-type          as character
field supp-code          as integer
field contract-code      as integer
field fact-date          as date
field artic              as character
field prod-type          as character
field prod-code          as integer
field vat-pc             as decimal
field price-cli          as decimal
field price-sale         as decimal
field count-doc          as integer
field total-qnty         as decimal
index pi is unique primary supp-type supp-code contract-code fact-date artic prod-type prod-code vat-pc price-cli count-doc
index count-doc supp-type supp-code contract-code fact-date artic prod-type prod-code count-doc.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_clients  for ub.clients.
define buffer bf_contract for ub.contract.
define buffer bf_bar-code for ub.bar-code.
define buffer bf_prod-bc  for ub.prod-bc.
define buffer bf_place    for ub.place.
define buffer bf_goods    for ub.goods.
define buffer bf_obj-date for ub.obj-date.
define buffer bf_store    for ub.store.
define buffer bf_shop     for ub.shop.
define buffer bf_sysconf  for ub.sysconf.
do on error undo, return error return-value :
on write of ub.obj-date override do:
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output varhost-code
  )  .
find first bf_sysconf where bf_sysconf.host-code = varhost-code no-lock.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
run get-db-num in parparentproc (output vardb-num).
run get-userid in parparentproc (output varuserid).
case parobj-type :
  when 'скл':U then do:
    find bf_store where bf_store.obj-code = parobj-code no-lock.
    assign
      varin-pay = bf_store.in-pay.
  end.
  when 'маг':U then do:
    find bf_shop where bf_shop.obj-code = parobj-code no-lock.
    assign
      varin-pay = bf_shop.in-pay.
  end.
  otherwise do:
    message "Не верный тип объекта: " parobj-type view-as alert-box.
    return error.
  end.
end case.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output varcur-date
  ) no-error .
if error-status:error or varcur-date = ? then do:
  message "Нет текущей даты на объекте " parobj-type " " parobj-code view-as alert-box.
  return error.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'bc-frmt':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  yes
  ,output varbc-frmt
  ,output varpar-type
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'bc-pfx':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  yes
  ,output varbc-pfx
  ,output varpar-type
  ) no-error .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type14 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type14
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type14 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type14
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
run gbl/filnline.p (input  parfile-cli
               ,output varend-new-line).
if varend-new-line = no then do:
  output stream str-cli to value(parfile-cli) append.
  put stream str-cli unformatted skip(1).
  output stream str-cli close.
end.
input stream str-cli from value(parfile-cli).
assign
  varfile-name-cli-log = entry(1, parfile-cli, ".") + ".log"
  varfile-name-cli-err = entry(1, parfile-cli, ".") + ".err".
output stream str-cli-log to value(varfile-name-cli-log).
assign
  varln = 0.
repeat :
  import stream str-cli unformatted vartemp-str-cli.
  assign
    varln = varln + 1.
  put stream str-cli-log unformatted "Считана строка " vartemp-str-cli " № " varln.
  if vartemp-str-cli <> "":u then do:
    if num-entries(vartemp-str-cli,";") <> 4 and
       num-entries(vartemp-str-cli,";") <> 3 then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " количество параметров согласно формату 'Тип;Код;ID_поставщика;Договор' должен состоять из 4 или 3-х позиций. В строке " vartemp-str-cli " их " num-entries(vartemp-str-cli,";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varobj-type = TRIM(entry(1, vartemp-str-cli, ";"), '"').
    if varobj-type <> 'орг':U and
       varobj-type <> 'чел':U then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " первый параметр согласно формату 'Тип;Код;ID_поставщика;Договор' должен быть 'орг' или 'чел'. В строке " vartemp-str-cli " он " varobj-type skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varobj-code = integer(entry(2, vartemp-str-cli, ";")) no-error.
    if error-status:error then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " второй параметр согласно формату 'Тип;Код;ID_поставщика;Договор' должен быть целым числом. В строке " vartemp-str-cli " он " entry(2, vartemp-str-cli, ";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    if entry(4, vartemp-str-cli, ";") <> "":u then do:
      assign
        varcontract-code = integer(entry(4, vartemp-str-cli, ";")) no-error.
      if error-status:error then do:
        if varopen-err-cli <> yes then do:
          output stream str-err to value(varfile-name-cli-err).
          assign
            varopen-err-cli = yes.
        end.
        put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln " четвертый параметр согласно формату 'Тип;Код;ID_поставщика;Договор' должен быть целым числом. В строке " vartemp-str-cli " он " entry(4, vartemp-str-cli, ";") skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    else do:
      assign
        varcontract-code = 0.
    end.
    assign
      varid-supp = entry(3, vartemp-str-cli, ";").
    find first tt-id where tt-id.id-supl-old-system = varid-supp  no-error.
    if available tt-id then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln ". Уже есть строка № " tt-id.ln " где ID_поставщика " tt-id.id-supl-old-system " ." skip.
      assign
        varfatal-error = yes.
      next.
    end.
    find first bf_clients where bf_clients.obj-type = varobj-type and
                                bf_clients.obj-code = varobj-code no-lock no-error.
    if not available bf_clients then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln ". В справочнике нет клиента у которого тип " varobj-type " код " varobj-code skip.
      assign
        varfatal-error = yes.
      next.
    end.
    if varcontract-code <> 0 then do:
      find first bf_contract where bf_contract.host-code     = varhost-code     and
                                   bf_contract.contract-code = varcontract-code no-lock no-error.
      if not available bf_contract then do:
        if varopen-err-cli <> yes then do:
          output stream str-err to value(varfile-name-cli-err).
          assign
            varopen-err-cli = yes.
        end.
        put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln ". Объект " parobj-type " " parobj-code ".Фирма объекта " varhost-code " Нет договора с внутренним номером " varcontract-code " на данной фирме." skip.
        assign
          varfatal-error = yes.
        next.
      end.
      if bf_contract.cli-type <> bf_clients.obj-type or
         bf_contract.cli-code <> bf_clients.obj-code then do:
        if varopen-err-cli <> yes then do:
          output stream str-err to value(varfile-name-cli-err).
          assign
            varopen-err-cli = yes.
        end.
        put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln ". Объект " parobj-type " " parobj-code ".Фирма объекта " varhost-code " Договор с внутренним номером " entry(4, vartemp-str-cli, ";") " по поставщику. " bf_contract.cli-type " " bf_contract.cli-code " , но в строке указан поставщик " bf_clients.obj-type " " bf_clients.obj-code skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    create tt-id.
    assign
      tt-id.supp-type          = bf_clients.obj-type
      tt-id.supp-code          = bf_clients.obj-code
      tt-id.id-supl-old-system = varid-supp
      tt-id.contract-code      = varcontract-code
      tt-id.ln                 = varln
    no-error.
    if error-status:error then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln ". Ошибка при создании временной таблицы по поставщикам: " return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    put stream str-cli-log unformatted ". Считанная строка корректна. " skip.
  end.
end.
input  stream str-cli     close.
output stream str-cli-log close.
if varopen-err-cli = yes then do:
  output stream str-err close.
end.
if varfatal-error then do:
  message
    "Ошибка при импорте файла поставщиков." skip
    "Документы не загружались." skip
    view-as alert-box error.
  run gbl/prnfilen.w
    (input  "Ошибки при импорте файла поставщиков"
    ,input  0
    ,input  varfile-name-cli-err
    ,input  7
    ,output varuser-action
    ,output varprinted
    ).
  return error.
end.
run gbl/filnline.p (input  parfile-doc
               ,output varend-new-line).
if varend-new-line = no then do:
  output stream str-doc to value(parfile-doc) append.
  put stream str-doc unformatted skip(1).
  output stream str-doc close.
end.
input stream str-doc from value(parfile-doc).
assign
  varfile-name-doc-log = entry(1, parfile-doc, ".") + ".log"
  varfile-name-doc-err = entry(1, parfile-doc, ".") + ".err".
output stream str-doc-log to value(varfile-name-doc-log).
assign
  varln = 0.
repeat :
  import stream str-doc unformatted vartemp-str-doc.
  assign
    varln = varln + 1.
  put stream str-doc-log unformatted "Считана строка " vartemp-str-doc " № " varln.
  if vartemp-str-doc <> "":u then do:
    if num-entries(vartemp-str-doc,";") <> 6 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " количество параметров согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен состоять из 6 позиций. В строке " vartemp-str-doc " их " num-entries(vartemp-str-doc,";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varid-supp = entry (1, vartemp-str-doc, ";").
    find first tt-id where tt-id.id-supl-old-system = varid-supp no-error.
    if not available tt-id then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " В строке указан ID_поставщика " varid-supp " такого идентификатора не было в файле идентификации поставщиков." skip.
      assign
        varfatal-error = yes.
      next.
    end.
    if entry(2, vartemp-str-doc, ";") = "":u then do:
      assign
        vardate = varcur-date.
      put stream str-doc-log unformatted ". Дата в строке не установлена. Устанавливаем текущую дату " vardate " .".
    end.
    else do:
      assign
       vardate = date(entry(2, vartemp-str-doc, ";")) no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln " второй параметр согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен быть датой. В строке " vartemp-str-doc " он " entry(2, vartemp-str-doc, ";") skip.
        assign
          varfatal-error = yes.
        next.
      end.
      if vardate > varcur-date then do:
        if error-status:error then do:
          if varopen-err-doc <> yes then do:
            output stream str-err to value(varfile-name-doc-err).
            assign
              varopen-err-doc = yes.
          end.
          put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
          put stream str-err unformatted "Строка № " varln " Дата в файле " vardate " больше текущей даты объекта " varcur-date " ." skip.
          assign
            varfatal-error = yes.
          next.
        end.
      end.
    end.
    assign
      varprod-bc = entry(3, vartemp-str-doc, ";").
    if substring (varprod-bc, 1, length(varbc-pfx)) = varbc-pfx then do:
      if length (varprod-bc) = 13 and
         varbc-frmt = "EAN13":u or
         length (varprod-bc) = 8 and
         varbc-frmt = "EAN8":u then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln " Префикс штрих-кода является префиксом собственных бар-кодов. Строка " vartemp-str-doc " . Префикс " varbc-pfx skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    if lookup (substring (varprod-bc, 1, 2), varscales-pref) > 0 and
       length (varprod-bc) = 13                                 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " Префикс штрих-кода является префиксом весовых бар-кодов. Строка " vartemp-str-doc " . Префикс " varbc-pfx skip.
      assign
        varfatal-error = yes.
      next.
    end.
    define variable v-ii as integer no-undo .
    do v-ii = 1 to num-entries(varpgscales-pref):
      entry(v-ii, varpgscales-pref) = substring(entry(v-ii, varpgscales-pref), 1, 2).
    end.
    if lookup (substring (varprod-bc, 1, 2), varpgscales-pref) > 0 and
       length (varprod-bc) = 13                                 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " Префикс штрих-кода является префиксом штучных кодов для весов. Строка " vartemp-str-doc " . Префикс " varbc-pfx skip.
      assign
        varfatal-error = yes.
      next.
    end.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  varprod-bc
,input  ?
,input  parobj-type
,input  parobj-code
,input  no
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer bf_bar-code
,buffer bf_prod-bc
,buffer bf_place
) no-error.
    if not available bf_bar-code then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " в системе нет штрих-кода " varprod-bc  skip.
      assign
        varfatal-error = yes.
      next.
    end.
    find first bf_goods where bf_goods.gds-code = bf_bar-code.gds-code no-lock.
    assign
      varqnty = decimal(entry(4, vartemp-str-doc, ";")) no-error.
    if error-status:error or varqnty <= 0 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " четвертый параметр согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен быть decimal и быть больше нуля. В строке " vartemp-str-doc " он " entry(4, vartemp-str-doc, ";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varprice = decimal(entry(5, vartemp-str-doc, ";")) no-error.
    if error-status:error or varprice <= 0 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " пятый параметр согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен быть decimal и быть больше нуля. В строке " vartemp-str-doc " он " entry(5, vartemp-str-doc, ";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varvat-pc = decimal(entry(6, vartemp-str-doc, ";")) no-error.
    if error-status:error or varvat-pc < 0 or varvat-pc >= 100 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " шестой параметр согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен быть decimal, больше нуля и меньше ста. В строке " vartemp-str-doc " он " entry(4, vartemp-str-doc, ";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    create tt-parts.
    assign
      tt-parts.id-supl-old-system = varid-supp
      tt-parts.fact-date          = vardate
      tt-parts.b-code             = varprod-bc
      tt-parts.qnty               = varqnty
      tt-parts.vat-pc             = varvat-pc
      tt-parts.artic              = bf_goods.artic
      tt-parts.prod-type          = bf_goods.prod-type
      tt-parts.prod-code          = bf_goods.prod-code
      tt-parts.price-cli          = varprice
      tt-parts.price-sale         = varprice
      tt-parts.ln                 = varln       no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln ". Ошибка при создании временной таблицы по документам: " return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    put stream str-doc-log unformatted ". Считанная строка разобрана." skip.
  end.
end.
input  stream str-doc     close.
if varopen-err-doc = yes then do:
  output stream str-doc-log close.
  output stream str-err     close.
end.
if varfatal-error then do:
  message
    "Ошибка при импорте данных по документам." skip
    "Накладные в системе не создавались." skip
    view-as alert-box error.
  run gbl/prnfilen.w
    (input  "Ошибки при импорте данных по документам"
    ,input  0
    ,input  varfile-name-doc-err
    ,input  7
    ,output varuser-action
    ,output varprinted
    ).
  return error.
end.
for each tt-parts use-index pi on error undo, return error return-value :
  find first tt-id where tt-id.id-supl-old-system    = tt-parts.id-supl-old-system.
  find first tt-result where tt-result.supp-type     = tt-id.supp-type     and
                             tt-result.supp-code     = tt-id.supp-code     and
                             tt-result.contract-code = tt-id.contract-code and
                             tt-result.fact-date     = tt-parts.fact-date  and
                             tt-result.artic         = tt-parts.artic      and
                             tt-result.prod-type     = tt-parts.prod-type  and
                             tt-result.prod-code     = tt-parts.prod-code  and
                             tt-result.vat-pc        = tt-parts.vat-pc     and
                             tt-result.price-cli     = tt-parts.price-cli  no-error.
  if available tt-result then do:
    assign
      tt-result.total-qnty = tt-result.total-qnty + tt-parts.qnty.
  end.
  else do:
    find first tt-result where tt-result.supp-type     = tt-id.supp-type     and
                               tt-result.supp-code     = tt-id.supp-code     and
                               tt-result.contract-code = tt-id.contract-code and
                               tt-result.fact-date     = tt-parts.fact-date  and
                               tt-result.artic         = tt-parts.artic      and
                               tt-result.prod-type     = tt-parts.prod-type  and
                               tt-result.prod-code     = tt-parts.prod-code  no-error.
    if available tt-result then do:
      find last tt-result where tt-result.supp-type     = tt-id.supp-type     and
                                tt-result.supp-code     = tt-id.supp-code     and
                                tt-result.contract-code = tt-id.contract-code and
                                tt-result.fact-date     = tt-parts.fact-date  and
                                tt-result.artic         = tt-parts.artic      and
                                tt-result.prod-type     = tt-parts.prod-type  and
                                tt-result.prod-code     = tt-parts.prod-code  use-index count-doc.
      find first tt-result-doc where tt-result-doc.supp-type     = tt-id.supp-type         and
                                     tt-result-doc.supp-code     = tt-id.supp-code         and
                                     tt-result-doc.contract-code = tt-id.contract-code     and
                                     tt-result-doc.fact-date     = tt-parts.fact-date      and
                                     tt-result-doc.count-doc     = tt-result.count-doc + 1 no-error.
      if not available tt-result-doc then do:
        find first bf_clients where bf_clients.obj-type = tt-id.supp-type and
                                    bf_clients.obj-code = tt-id.supp-code no-lock.
        create tt-result-doc.
        assign
          tt-result-doc.supp-type     = tt-id.supp-type
          tt-result-doc.supp-code     = tt-id.supp-code
          tt-result-doc.supp-name     = bf_clients.obj-name
          tt-result-doc.contract-code = tt-id.contract-code
          tt-result-doc.fact-date     = tt-parts.fact-date
          tt-result-doc.count-doc     = tt-result.count-doc + 1 no-error
        .
        if error-status:error then do:
          if varopen-err-doc <> yes then do:
            output stream str-err to value(varfile-name-doc-err).
            assign
              varopen-err-doc = yes.
          end.
          put stream str-doc-log unformatted "Строка № " tt-parts.ln " имеет ошибки. " skip.
          put stream str-err unformatted "Строка № " tt-parts.ln ". Ошибка при создании результирующей временной таблицы по шапкам документов: " return-value error-status:get-message(1) skip.
          assign
            varfatal-error = yes.
          next.
        end.
      end.
      create tt-result.
      assign
        tt-result.supp-type      = tt-result-doc.supp-type
        tt-result.supp-code      = tt-result-doc.supp-code
        tt-result.contract-code  = tt-result-doc.contract-code
        tt-result.fact-date      = tt-parts.fact-date
        tt-result.artic          = tt-parts.artic
        tt-result.prod-type      = tt-parts.prod-type
        tt-result.prod-code      = tt-parts.prod-code
        tt-result.vat-pc         = tt-parts.vat-pc
        tt-result.price-cli      = tt-parts.price-cli
        tt-result.count-doc      = tt-result-doc.count-doc
        tt-result.total-qnty     = tt-parts.qnty
        tt-result.price-sale     = tt-parts.price-sale
        no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "Строка № " tt-parts.ln " имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " tt-parts.ln ". Ошибка при создании результирующей временной таблицы по документам: " return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    else do:
      find first tt-result-doc where tt-result-doc.supp-type     = tt-id.supp-type     and
                                     tt-result-doc.supp-code     = tt-id.supp-code     and
                                     tt-result-doc.contract-code = tt-id.contract-code and
                                     tt-result-doc.fact-date     = tt-parts.fact-date  and
                                     tt-result-doc.count-doc     = 1                   no-error.
      if not available tt-result-doc then do:
        find first bf_clients where bf_clients.obj-type = tt-id.supp-type and
                                    bf_clients.obj-code = tt-id.supp-code no-lock.
        create tt-result-doc.
        assign
          tt-result-doc.supp-type     = tt-id.supp-type
          tt-result-doc.supp-code     = tt-id.supp-code
          tt-result-doc.supp-name     = bf_clients.obj-name
          tt-result-doc.contract-code = tt-id.contract-code
          tt-result-doc.fact-date     = tt-parts.fact-date
          tt-result-doc.count-doc     = 1 no-error
        .
        if error-status:error then do:
          if varopen-err-doc <> yes then do:
            output stream str-err to value(varfile-name-doc-err).
            assign
              varopen-err-doc = yes.
          end.
          put stream str-doc-log unformatted "Строка № " tt-parts.ln " имеет ошибки. " skip.
          put stream str-err unformatted "Строка № " tt-parts.ln ". Ошибка при создании результирующей временной таблицы по шапкам документов: " return-value error-status:get-message(1) skip.
          assign
            varfatal-error = yes.
          next.
        end.
      end.
      create tt-result.
      assign
        tt-result.supp-type      = tt-result-doc.supp-type
        tt-result.supp-code      = tt-result-doc.supp-code
        tt-result.contract-code  = tt-result-doc.contract-code
        tt-result.fact-date      = tt-parts.fact-date
        tt-result.artic          = tt-parts.artic
        tt-result.prod-type      = tt-parts.prod-type
        tt-result.prod-code      = tt-parts.prod-code
        tt-result.vat-pc         = tt-parts.vat-pc
        tt-result.price-cli      = tt-parts.price-cli
        tt-result.count-doc      = 1
        tt-result.total-qnty     = tt-parts.qnty
        tt-result.price-sale     = tt-parts.price-sale no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "Строка № " tt-parts.ln " имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " tt-parts.ln ". Ошибка при создании результирующей временной таблицы по документам: " return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
  end.
  put stream str-doc-log unformatted "Строка № " tt-parts.ln " сохранена во временные таблицы. " skip.
end.
do transaction on error undo, return error return-value :
  for each tt-result-doc on error undo, return error return-value :
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  varhost-code
  ,input  tt-result-doc.fact-date
  ,output varbase-rate
  ,output varbase-scale
  ) no-error .
    if error-status :error then do:
       if varopen-err-doc <> yes then do:
         output stream str-err to value(varfile-name-doc-err).
         assign
           varopen-err-doc = yes.
       end.
       put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
       put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc ". Ошибка при поиске курса базовой валюты за дату." " " return-value " " error-status:get-message(1) skip.
       assign
         varfatal-error = yes.
       next.
    end.
    if varbase-rate  = ? or
       varbase-rate  = 0 or
       varbase-scale = ? or
       varbase-scale = 0 then do:
       if varopen-err-doc <> yes then do:
         output stream str-err to value(varfile-name-doc-err).
         assign
           varopen-err-doc = yes.
       end.
       put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
       put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc ". Неверный курс базовой валюты." skip.
       assign
         varfatal-error = yes.
       next.
    end.
    find first bf_obj-date where bf_obj-date.obj-type = parobj-type             and
                                 bf_obj-date.obj-code = parobj-code             and
                                 bf_obj-date.sys-date = tt-result-doc.fact-date no-lock no-error.
    if not available bf_obj-date then do:
      run cur-time in this-procedure ( output vartoday
                                     , output vartime
                                     ).
      run factord-end-day in this-procedure
        (input  tt-result-doc.fact-date
        ,output varday-end-fact-order
        ) no-error .
      if error-status :error
      or varday-end-fact-order = ?
      or varday-end-fact-order = 0 then do:
         if varopen-err-doc <> yes then do:
           output stream str-err to value(varfile-name-doc-err).
           assign
             varopen-err-doc = yes.
         end.
         put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
         put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc ". Ошибка при определении фактического номера даты на объекте. Объект" parobj-type " " parobj-code " " return-value " " error-status:get-message(1) skip.
         assign
           varfatal-error = yes.
         next.
      end.
      create bf_obj-date.
      assign
        bf_obj-date.obj-type   = parobj-type
        bf_obj-date.obj-code   = parobj-code
        bf_obj-date.sys-date   = tt-result-doc.fact-date
        bf_obj-date.open-id    = varuserid
        bf_obj-date.open-date  = vartoday
        bf_obj-date.open-time  = vartime
        bf_obj-date.close-id   = varuserid
        bf_obj-date.close-date = vartoday
        bf_obj-date.close-time = vartime
        bf_obj-date.fact-order = varday-end-fact-order
        bf_obj-date.host-code  = varhost-code
        bf_obj-date.status_    = 'зкр':U
        no-error
      .
      if error-status:error then do:
         if varopen-err-doc <> yes then do:
           output stream str-err to value(varfile-name-doc-err).
           assign
             varopen-err-doc = yes.
         end.
         put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
         put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  ". Ошибка при создании даты на объекте : " return-value error-status:get-message(1) skip.
         assign
           varfatal-error = yes.
         next.
      end.
      release bf_obj-date no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  ". Ошибка при создании даты на объекте : " return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    run doc-code in this-procedure
      (input  "main":u,
       input  parobj-type,
       input  parobj-code,
       input  ?,
       output vardoc-code) no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при генерации номера документа." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input varbase-rate
,input varbase-scale
,input tt-result-doc.supp-code
,input tt-result-doc.supp-type
,input tt-result-doc.supp-name
,input vardb-num
,input varuserid
,input ''
,input vardoc-code
,input tt-result-doc.fact-date
,input 'при':U
,input false
,input varhost-code
,input no
,input parobj-code
,input parobj-type
,input no
,input varin-pay
,input 'Документ создан утилитой по загрузке внешних данных'
,input no
,input 'нет':U
,input 'накл':U
,input 'в т. ч.':U
,input 'ie':U
,input '1':U
) no-error
.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  " Ошибка при создания шапки документа. " return-value " " error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code exclusive-lock.
    assign
      bf_trn-doc.agnt          = paragnt
      bf_trn-doc.boss          = parboss
      bf_trn-doc.wrkr          = parwrkr
      bf_trn-doc.contract-code = tt-result-doc.contract-code
      bf_trn-doc.exch-code     = 0
      bf_trn-doc.exch-rate     = 1
      bf_trn-doc.exch-scale    = 1
      bf_trn-doc.fact-date     = tt-result-doc.fact-date
      bf_trn-doc.fact-time     = 24 * 60 * 60 - 1
      bf_trn-doc.is-back-date  = (tt-result-doc.fact-date < vartoday)
      bf_trn-doc.print-rubl    = yes
      bf_trn-doc.user-db-num   = vardb-num
      bf_trn-doc.user-name     = varuserid
     no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при создания шапки документа, добавление полей." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    for each lib-trn_ret-doc       on error undo, return error return-value : delete lib-trn_ret-doc      . end.
    for each lib-trn_ret-line      on error undo, return error return-value : delete lib-trn_ret-line     . end.
    for each lib-trn_ret-line-attr on error undo, return error return-value : delete lib-trn_ret-line-attr. end.
    for each lib-trn_ret-dtl       on error undo, return error return-value : delete lib-trn_ret-dtl      . end.
    for each lib-trn_ret-parts     on error undo, return error return-value : delete lib-trn_ret-parts    . end.
    create lib-trn_ret-doc.
    buffer-copy bf_trn-doc to lib-trn_ret-doc no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при копировании документа во временную таблицу." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    for each tt-result where tt-result.supp-type     = tt-result-doc.supp-type     and
                             tt-result.supp-code     = tt-result-doc.supp-code     and
                             tt-result.contract-code = tt-result-doc.contract-code and
                             tt-result.fact-date     = tt-result-doc.fact-date     and
                             tt-result.count-doc     = tt-result-doc.count-doc     on error undo, return error return-value :
      find first bf_goods where bf_goods.artic     = tt-result.artic     and
                                bf_goods.prod-type = tt-result.prod-type and
                                bf_goods.prod-code = tt-result.prod-code no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  bf_goods.prt-root
  ,output n-c
  )  .
      create lib-trn_ret-line.
      assign
        lib-trn_ret-line.fact-qnty      = tt-result.total-qnty
        lib-trn_ret-line.price-rubl     = tt-result.price-cli
        lib-trn_ret-line.price-base     = tt-result.price-cli / bf_trn-doc.base-rate * bf_trn-doc.base-scale
        lib-trn_ret-line.price-cli      = tt-result.price-cli
        lib-trn_ret-line.unit-cli       = bf_goods.unit-base
        lib-trn_ret-line.cli-qnty       = tt-result.total-qnty
        lib-trn_ret-line.doc-qnty       = tt-result.total-qnty
        lib-trn_ret-line.obj-type       = bf_trn-doc.obj-type
        lib-trn_ret-line.obj-code       = bf_trn-doc.obj-code
        lib-trn_ret-line.prod-type      = tt-result.prod-type
        lib-trn_ret-line.prod-code      = tt-result.prod-code
        lib-trn_ret-line.artic          = tt-result.artic
        lib-trn_ret-line.doc-code       = bf_trn-doc.doc-code
        lib-trn_ret-line.cli-base-rate  = 1
        lib-trn_ret-line.prt-root       = bf_goods.prt-root
        lib-trn_ret-line.prt-OK         = yes
        lib-trn_ret-line.VAT-pc         = tt-result.vat-pc
        lib-trn_ret-line.status_        = bf_trn-doc.status_
        lib-trn_ret-line.SLT-pc         = 0
        lib-trn_ret-line.line-num       = 0
        lib-trn_ret-line.wt-brutto      = 0
        lib-trn_ret-line.num-place      = 0
        lib-trn_ret-line.road-tax       = 0
        lib-trn_ret-line.excise         = 0
        lib-trn_ret-line.doc-density    = 1
        lib-trn_ret-line.fact-density   = 1
        lib-trn_ret-line.temperature    = 0
        lib-trn_ret-line.transport-base = 0
        lib-trn_ret-line.transport-rubl = 0
        lib-trn_ret-line.other-base     = 0
        lib-trn_ret-line.other-rubl     = 0
        lib-trn_ret-line.ext-doc-type   = bf_trn-doc.ext-doc-type
        lib-trn_ret-line.fact-order     = bf_trn-doc.fact-order
        lib-trn_ret-line.cons-vat-pc    = bf_sysconf.cons-vat-pc
        lib-trn_ret-line.cons-slt-pc    = 0
        no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " Ошибка при создании временной таблицы строк." return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
      create lib-trn_ret-parts.
      assign
        lib-trn_ret-parts.prod-type      = tt-result.prod-type
        lib-trn_ret-parts.prod-code      = tt-result.prod-code
        lib-trn_ret-parts.artic          = tt-result.artic
        lib-trn_ret-parts.in-code        = bf_trn-doc.doc-code
        lib-trn_ret-parts.out-code       = bf_trn-doc.doc-code
        lib-trn_ret-parts.price-base     = tt-result.price-cli / bf_trn-doc.base-rate * bf_trn-doc.base-scale
        lib-trn_ret-parts.price-rubl     = tt-result.price-cli
        lib-trn_ret-parts.qnty           = tt-result.total-qnty
        lib-trn_ret-parts.obj-type       = bf_trn-doc.obj-type
        lib-trn_ret-parts.obj-code       = bf_trn-doc.obj-code
        lib-trn_ret-parts.fact-date      = bf_trn-doc.fact-date
        lib-trn_ret-parts.fact-num       = bf_trn-doc.fact-num
        lib-trn_ret-parts.VAT-pc         = tt-result.vat-pc
        lib-trn_ret-parts.part-code      = ""
        lib-trn_ret-parts.PS             = "Партия создана утилитой по загрузке информации из внешней системы"
        lib-trn_ret-parts.pay-code       = bf_trn-doc.pay-code
        lib-trn_ret-parts.status_        = no
        lib-trn_ret-parts.fact-qnty      = tt-result.total-qnty
        lib-trn_ret-parts.supp-type      = bf_trn-doc.cli-type
        lib-trn_ret-parts.supp-code      = bf_trn-doc.cli-code
        lib-trn_ret-parts.rsrv-free      = ?
        lib-trn_ret-parts.doc-type       = bf_trn-doc.doc-type
        lib-trn_ret-parts.cli-qnty       = tt-result.total-qnty
        lib-trn_ret-parts.pl-code        = ?
        lib-trn_ret-parts.VAT-type       = 'в т. ч.':U
        lib-trn_ret-parts.exch-code      = 0
        lib-trn_ret-parts.price-cli      = tt-result.price-cli
        lib-trn_ret-parts.cli-base-rate  = 1
        lib-trn_ret-parts.SLT-pc         = 0
        lib-trn_ret-parts.host-code      = bf_trn-doc.host-code
        lib-trn_ret-parts.is-supp        = yes
        lib-trn_ret-parts.SLT-type       = 'без':U
        lib-trn_ret-parts.cst-code       = ""
        lib-trn_ret-parts.last-date      = ?
        lib-trn_ret-parts.road-tax-base  = 0
        lib-trn_ret-parts.road-tax-rubl  = 0
        lib-trn_ret-parts.transport-base = 0
        lib-trn_ret-parts.transport-rubl = 0
        lib-trn_ret-parts.other-base     = 0
        lib-trn_ret-parts.other-rubl     = 0
        lib-trn_ret-parts.purch-code     = bf_trn-doc.purch-code
        lib-trn_ret-parts.contract-code  = bf_trn-doc.contract-code
      no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " Ошибка при создании временной таблицы партий." return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
      create lib-trn_ret-dtl.
      assign
        lib-trn_ret-dtl.prod-type   = tt-result.prod-type
        lib-trn_ret-dtl.prod-code   = tt-result.prod-code
        lib-trn_ret-dtl.artic       = tt-result.artic
        lib-trn_ret-dtl.obj-type    = bf_trn-doc.obj-type
        lib-trn_ret-dtl.obj-code    = bf_trn-doc.obj-code
        lib-trn_ret-dtl.prt-code    = n-c
        lib-trn_ret-dtl.fact-qnty   = tt-result.total-qnty
        lib-trn_ret-dtl.doc-qnty    = tt-result.total-qnty
        lib-trn_ret-dtl.doc-code    = bf_trn-doc.doc-code
        lib-trn_ret-dtl.price-rubl  = (if varr-b = "rubl":u then tt-result.price-sale else tt-result.price-sale * bf_trn-doc.base-rate / bf_trn-doc.base-scale)
        lib-trn_ret-dtl.price-base  = (if varr-b = "base":u then tt-result.price-sale else tt-result.price-sale / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
        lib-trn_ret-dtl.discnt-rubl = 0
        lib-trn_ret-dtl.discnt-base = 0
        lib-trn_ret-dtl.discnt-pc   = 0
        lib-trn_ret-dtl.discnt-type = yes
        lib-trn_ret-dtl.ov          = yes
        lib-trn_ret-dtl.cur-base    = tt-result.price-sale
      no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " Ошибка при создании временной таблицы признаков." return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input parparentproc
 ,input recid(bf_trn-doc)
 ,input table lib-trn_ret-doc
 ,input table lib-trn_ret-line
 ,input table lib-trn_ret-line-attr
 ,input table lib-trn_ret-dtl
 ,input table lib-trn_ret-parts
 ,input no
 ,input yes
 ,input yes
 ,input yes
 ,input this-procedure
  ) no-error .
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при запуске процедуры copy-in." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      bf_trn-doc.tot-cli = bf_trn-doc.tot-rubl.
    run gbl/calc-trn.p (input parparentproc, input recid(bf_trn-doc)) no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при пересчете шапки документа." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    put stream str-doc-log unformatted "Cоздан документ " bf_trn-doc.doc-code " по результирующей строка шапки документа " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  skip.
    if parstatus > 0 then do:
      run str/trn-stat.p (input  parparentproc,
                      input this-procedure  ,
                      input  '<закрытие документа>':U,
                      input  bf_trn-doc.doc-code,
                      input  no,
                      input  vardb-num,
                      input  ?,
                      input  ?,
                      input  ?,
                      input  ?,
                      input  no,
                      output varchg-inv,
                      output table gds-list) no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  " Ошибка при закрытии документа до накл+. " return-value " " error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
      put stream str-doc-log unformatted "Документ " bf_trn-doc.doc-code " закрыт до накл+. РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  skip.
    end.
    if parstatus > 1 then do:
      run str/trn-stat.p (input  parparentproc,
                      input this-procedure ,
                      input  '<закрытие документа>':U,
                      input  bf_trn-doc.doc-code,
                      input  no,
                      input  vardb-num,
                      input  ?,
                      input  ?,
                      input  ?,
                      input  ?,
                      input  no,
                      output varchg-inv,
                      output table gds-list) no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  " Ошибка при закрытии документа до факт. " return-value " " error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
      put stream str-doc-log unformatted "Документ " bf_trn-doc.doc-code " закрыт до факт. РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  skip.
    end.
  end.
  output stream str-doc-log close.
  if varfatal-error then do:
    output stream str-err close.
    message
    "Ошибка при создании документов в IBS Trade House." skip
    "Все загруженные документы откатываются." skip
    view-as alert-box error.
    run gbl/prnfilen.w
     (input  "Ошибки при создании документов в IBS Trade House."
     ,input  0
     ,input  varfile-name-doc-err
     ,input  7
     ,output varuser-action
     ,output varprinted
     ).
    return error.
  end.
end.
end.
