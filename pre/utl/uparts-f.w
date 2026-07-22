using ibs.th.str.alcohol.*.
DEFINE TEMP-TABLE x_parts NO-UNDO LIKE parts.
define input  parameter parparentproc       as widget-handle no-undo.
define input  parameter h-call-prog         as handle    no-undo .
define input  parameter p-doc-code          as character no-undo .
define input  parameter p-gds-code          as integer   no-undo .
define input  parameter p-pl-code           as integer   no-undo .
define input  parameter p-in-code   as character no-undo .
define input  parameter p-part-code as character no-undo .
define input  parameter p-out-code  as character no-undo .
define input-output  parameter table for x_parts.
define variable chg-qnty      as   decimal no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование партии документа ВнешПН факт".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|':u,h-call-prog,p-doc-code,p-gds-code,p-pl-code)
    .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info4 as character format "x(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
procedure partscr :
  define input  parameter parparentproc      as widget-handle no-undo.
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-supp-type        as character no-undo .
  define input  parameter p-supp-code        as integer   no-undo .
  define input  parameter p-part-code        as character no-undo .
  define input  parameter p-cst-code         as character no-undo .
  define input  parameter p-ps               as character no-undo .
  define input  parameter p-dop              as character no-undo .
  define input  parameter p-part-reserv-base as decimal   no-undo .
  define input  parameter p-part-reserv-rubl as decimal   no-undo .
  define input  parameter p-vat-type         as character no-undo .
  define input  parameter p-vat-pc           as decimal   no-undo .
  define input  parameter p-slt-type         as character no-undo .
  define input  parameter p-slt-pc           as decimal   no-undo .
  define input  parameter p-change-qnty      as decimal   no-undo .
  define input  parameter p-action           as character no-undo .
  define input  parameter p-cli-qnty         as decimal   no-undo .
  define input  parameter p-last-date        as date      no-undo .
  define input  parameter p-hold-date        as date      no-undo .
  define input  parameter p-pl-code          as integer   no-undo .
  define parameter buffer buf_doc-line       for ub.doc-line .
  define parameter buffer buf_parts          for ub.parts .
  define variable vss-description as character no-undo initial "$Workfile$ $Revision$ Процедура создания партии".
  define variable v-price-cli                like ub.doc-line.price-rubl no-undo.
  define variable v-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
  define variable v-price-road-tax           like ub.doc-line.price-rubl no-undo.
  define variable v-price-other-exp          like ub.doc-line.price-rubl no-undo.
  define variable v-price-transport-exp      like ub.doc-line.price-rubl no-undo.
  define variable v-price-without-abs        like ub.doc-line.price-rubl no-undo.
  define variable v-price-slt                like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-slt             like ub.doc-line.price-rubl no-undo.
  define variable v-price-vat                like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
  define variable v-price-rubl               like ub.doc-line.price-rubl no-undo.
  define variable v-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
  define variable v-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
  define variable v-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
  define variable v-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
  define variable v-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
  define variable v-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
  define variable v-price-base               like ub.doc-line.price-base no-undo.
  define variable v-price-road-tax-base      like ub.doc-line.price-base no-undo.
  define variable v-price-other-exp-base     like ub.doc-line.price-base no-undo.
  define variable v-price-transport-exp-base like ub.doc-line.price-base no-undo.
  define variable v-price-without-abs-base   like ub.doc-line.price-base no-undo.
  define variable v-price-slt-base           like ub.doc-line.price-base no-undo.
  define variable v-price-no-slt-base        like ub.doc-line.price-base no-undo.
  define variable v-price-vat-base           like ub.doc-line.price-base no-undo.
  define variable v-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.
  define variable l-fact-qnty              as logical   no-undo .
  define variable v-action                 as character no-undo .
  define variable l-need-create-old-return as logical   no-undo init false .
  define variable l-create-old-return      as logical   no-undo init false .
  define variable v-izlcstpr        as character no-undo .
  define variable l-goods-serial           as logical   no-undo .
  define variable l-goods-twounit          as logical   no-undo .
  define variable l-reserv-pl-code         as logical   no-undo .
  define variable l-goods-bottle           as logical   no-undo .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_goods    for ub.goods .
  define variable v-prompt-price       as character no-undo .
  define variable v-check-right        as logical   no-undo .
  define variable v-ind                as integer   no-undo .
  define variable v-num-entries-action as integer   no-undo .
  define variable v-option             as character no-undo .
  define variable v-type as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-check-right = true
    .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка документа" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-supp-type = ?
    or p-supp-type = ''
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-supp-type имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-supp-code = ?
    or p-supp-code = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-supp-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-cst-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-cst-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-ps = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-ps имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-base = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-base имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-base < 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-base имеет отрицательное значение" skip
        "p-part-reserv-base" p-part-reserv-base skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-rubl = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-rubl имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-rubl < 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-rubl имеет отрицательное значение" skip
        "p-part-reserv-rubl" p-part-reserv-rubl skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-change-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-change-qnty имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-pl-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-pl-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-num-entries-action = num-entries(p-action, chr(44))
    .
    do v-ind = 1 to v-num-entries-action
    :
      assign
        v-option = entry(v-ind, p-action, chr(44))
      .
      if num-entries(v-option, '=':u) <> 2
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Количество входений в опцию отлично от двух"
          "p-action" p-action skip
          "v-option" v-option skip
          view-as alert-box error .
        undo, return error .
      end.
      case entry(1, v-option, '=':u)
      :
        when 'prompt':u
        then do:
          assign
            v-prompt-price = v-option
          .
        end.
        when 'check-right':u
        then do:
          assign
            v-check-right = logical(entry(2, v-option, '=':u))
          .
        end.
        when 'izlcstpr':u
        then do :
            assign
                v-izlcstpr = v-option
            .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Неизвестная опция"
            "p-action" p-action skip
            "v-option" v-option skip
            view-as alert-box error .
          undo, return error .
        end.
      end case .
    end.
    if lookup(v-prompt-price, 'prompt=enable,prompt=disable-reject,prompt=disable-create':u ) > 0
    then do:
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "v-prompt-price" v-prompt-price skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      .
define variable v-negparts as character no-undo .
define variable v-negmanuf as character no-undo .
define variable v-prcshrs0 as character no-undo .
define variable v-prcshrs1 as character no-undo .
define variable v-prdocrs0 as character no-undo .
define variable v-prdocrs1 as character no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
  ,input 'rezerv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = 'negparts'  then  v-negparts  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'negmanuf'  then  v-negmanuf  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prcshrs0'  then  v-prcshrs0  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prcshrs1'  then  v-prcshrs1  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prdocrs0'  then  v-prdocrs0  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prdocrs1'  then  v-prdocrs1  = thbjattr_thbj-attr.property-value-character.
end.
    if p-cst-code = ?
    then do:
      assign
        p-cst-code = (if buf_trn-doc.cst-code <> ?
                      then buf_trn-doc.cst-code
                      else "")
      .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка поиска товара" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'serial=request':u
  ,output l-goods-serial
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'serial=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'twounit=request':u
  ,output l-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'bottle=request':u
  ,output l-goods-bottle
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'bottle=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  buf_trn-doc.doc-type = 'при':U
    and buf_trn-doc.internal = false
    then do:
      if buf_trn-doc.flag_ = no
      then do:
        assign
          l-fact-qnty = false
        .
      end.
      else do:
        assign
          l-fact-qnty = true
        .
      end.
    end.
    else do:
      define variable conf-par as character no-undo .
      define variable par-type as character no-undo .
      define variable lok      as logical no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'place-rsrv=request'
  ,output l-reserv-pl-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара на объекте" skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "place-rsrv=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if l-reserv-pl-code
      then do:
        return
          "Товар на объекте резервируется по складским местам" + chr(10)
          + "Создание партий запрещено " + chr(10)
          + "Объект " + string(buf_doc-line.obj-type)
              + " " + string(buf_doc-line.obj-code) + chr(10)
          + "Артикул " + string(buf_doc-line.artic)
              + " " + string(buf_doc-line.prod-type)
              + " " + string(buf_doc-line.prod-code) + chr(10)
          .
      end.
      if buf_trn-doc.ext-doc-type = 'im':U
      then do:
      end.
      else do:
        conf-par  =  v-negparts .
        if buf_trn-doc.ext-doc-type = 're':U
        or buf_trn-doc.ext-doc-type = 'rs':U
        or buf_trn-doc.ext-doc-type = 'vt':U
        or buf_trn-doc.ext-doc-type = 'vp':U
        then do:
          if conf-par = "disable"
          or buf_goods.negative-rest = false
          then do:
            if v-prompt-price = 'prompt=enable':u and v-izlcstpr <> 'izlcstpr=enable':u
            then do:
              assign
                l-need-create-old-return = true
              .
            end.
          end.
        end.
        else do:
          if conf-par = "disable"
          then do:
            return
              "Порождение отрицательных партий для объекта "
              + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
              + " запрещено (negparts)"
              .
          end.
          if buf_goods.negative-rest = false
          then do:
            return
              "Для товара " + string(buf_doc-line.artic)
              + " " + string(buf_doc-line.prod-type)
              + " " + string(buf_doc-line.prod-code)
              + " запрещены отрицательные остатки"
              .
          end.
        end.
      end.
      if buf_trn-doc.ext-doc-type = 'ep':U
      then do:
        return
          "Недопустимо создавать порожденные партии для данного типа документа"
          .
      end.
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      then do:
        conf-par = v-negmanuf.
        if conf-par = "disable"
        then do:
          return
            "Для документа производства порождение отрицательных партий для объекта "
            + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
            + " запрещено (negmanuf)"
            .
        end.
      end.
      define variable v-reason as character no-undo .
      run partscr_check-valid-supp in this-procedure
        (input  p-supp-type
        ,input  p-supp-code
        ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
        ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
        ,input  buf_trn-doc.ext-doc-type
        ,output l-create-old-return
        ,output v-reason
        ).
      if v-reason <> ""
      then do:
        return
          v-reason
          .
      end.
      if l-goods-serial = true
      then do:
        if not(buf_trn-doc.doc-type = 'при':U
              and buf_trn-doc.internal = false
              and v-prompt-price = 'prompt=disable-create':u
              )
        then do:
          return
            "Порождение партий серийного товара допустимо только во внешнем приходе в интерфейсе партий."
            .
        end.
      end.
      if l-goods-twounit = true
      then do:
        if l-create-old-return
        then do:
          if l-create-old-return
          then do:
            assign
              p-cli-qnty = 1
            .
          end.
        end.
        else do:
          return
            "Для товара с двумя единицами измерения допустимо создание партий во внешнем приходе или партий старого возврата"
            .
        end.
      end.
      if buf_trn-doc.doc-type = 'инв':U
      then do:
        assign
          l-fact-qnty = false
        .
      end.
      else do:
        if buf_trn-doc.doc-type = 'при':U
        and buf_trn-doc.internal = true
        and buf_trn-doc.discnt-type = 'прво':U
        then do:
          assign
            l-fact-qnty = false
          .
        end.
        else do:
          if buf_trn-doc.status_ = 'разрешен':U
          or (buf_trn-doc.doc-type = 'при':U
              and buf_trn-doc.internal = true
            )
          then do:
            assign
              l-fact-qnty = true
            .
          end.
          else do:
            assign
              l-fact-qnty = false
            .
          end.
        end.
      end.
    end.
    find buf_parts
      where buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
        and buf_parts.in-code   = buf_doc-line.doc-code
        and buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.part-code = p-part-code
      no-error.
    if not available buf_parts
    then do:
      assign
        v-action = ""
      .
      if  ( buf_trn-doc.doc-type = 'при':U
            and buf_trn-doc.internal = false
          )
      or  ( buf_trn-doc.doc-type = 'при':U
            and buf_trn-doc.internal = true
            and buf_trn-doc.discnt-type = 'прво':U
          )
      then do:
        assign
          v-action = "exit":u
        .
      end.
      else do:
        if v-check-right = true
        then do:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  p-user-id
    ,input  0
    ,input  'actn_parts_createneg':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_doc-line.obj-type
    ,input  buf_doc-line.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output lok
    )  .
end.
          if lok <> true
          then do:
            return "Отсутствуют права на создание порожденных партий" .
          end.
        end.
        if l-need-create-old-return
        or l-create-old-return
        then do:
        end.
        else do:
          define variable v-parameter-name as character no-undo .
          define variable v-document-name  as character no-undo .
          if p-part-reserv-base = 0
          or p-part-reserv-rubl = 0
          then do:
            run trg/partplas.p
              (input  buf_doc-line.obj-type
              ,input  buf_doc-line.obj-code
              ,input  buf_goods.gds-code
              ,input  buf_trn-doc.base-rate
              ,input  buf_trn-doc.base-scale
              ,output p-part-reserv-base
              ,output p-part-reserv-rubl
              ) .
          end.
          if buf_trn-doc.discnt-type = 'касс':U
          then do:
            assign
              v-action         = "exit":u
              v-document-name  = "продажи"
            .
            if  p-part-reserv-base = 0
            and p-part-reserv-rubl = 0
            then do:
              assign
                v-parameter-name = 'prcshrs0':U
                conf-par  = v-prcshrs0
              .
            end.
            else do:
              assign
                v-parameter-name = 'prcshrs1':U
                conf-par  = v-prcshrs1
              .
            end.
          end.
          else do:
            assign
              v-action         = ""
              v-document-name  = "документа"
            .
            if  p-part-reserv-base = 0
            and p-part-reserv-rubl = 0
            then do:
              assign
                v-parameter-name = 'prdocrs0':U
                conf-par  = v-prdocrs0
              .
            end.
            else do:
              assign
                v-parameter-name = 'prdocrs1':U
                conf-par  = v-prdocrs1
              .
            end.
          end.
          if conf-par = ""
          or conf-par = ?
          then do:
            assign
              conf-par = "disable"
            .
          end.
          case conf-par :
            when "disable"
            then do:
              return
                "Для " + v-document-name + " " + buf_doc-line.doc-code + " порождение отрицательных партий для объекта "
                + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
                + " c учетной ценой "
                + ( if p-part-reserv-base <> 0 then "не равной 0" else "равной 0")
                + " запрещено." + chr(10)
                + "Параметр " + v-parameter-name + "=" + conf-par + "."
                .
            end.
            when "enable"
            then do:
              assign
                v-action = "exit":u
              .
            end.
            when "prompt"
            then do:
              if v-prompt-price = 'prompt=disable-reject':u
              then do:
                return
                  "Требуется ручное редактирование партий" + chr(10)
                  + "В данном режиме резервирования ручное редактирование невозможно" + chr(10)
                  + "Параметр " + v-parameter-name + "=" + conf-par + "." + chr(10)
                  .
              end.
              assign
                v-action = ""
              .
            end.
            when "manual"
            then do:
              if v-prompt-price = 'prompt=disable-reject':u
              then do:
                return
                  "Требуется ручное редактирование партий" + chr(10)
                  + "В данном режиме резервирования ручное редактирование невозможно" + chr(10)
                  + "Параметр " + v-parameter-name + "=" + conf-par + "." + chr(10)
                  .
              end.
              assign
                v-action = "chg":u
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестное значение параметра" v-parameter-name skip
                "conf-par" conf-par skip
                view-as alert-box error .
              return
                "Неизвестное значение параметра " + v-parameter-name
                + " conf-par = " + conf-par
                .
            end.
          end.
        end.
      end.
      if l-need-create-old-return
      then do:
        assign
          v-action = "chg":u
        .
      end.
      if v-prompt-price = 'prompt=disable-create':u
      then do:
        assign
          v-action = "exit":u
        .
      end.
      if v-action = ""
      then do:
        assign
          v-action = "exit":u
        .
        run trg/in-price.w
          (input parparentproc
          ,input-output p-part-reserv-base
          ,input-output p-part-reserv-rubl
          ,output v-action
          ,input  buf_doc-line.obj-type
          ,input  buf_doc-line.obj-code
          ,input  buf_doc-line.artic
          ,input  buf_doc-line.prod-type
          ,input  buf_doc-line.prod-code
          ,input  p-supp-type
          ,input  p-supp-code
          ,input  buf_trn-doc.base-rate
          ,input  buf_trn-doc.base-scale
          ,input  p-change-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запросе учетной цены" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return error .
        end.
      end.
      case v-action :
        when "chg":u
        then do:
          run str/partsedt.p
            (input parparentproc
            ,buffer buf_doc-line
            ,input  true
            ,input  false
            ,input  p-change-qnty
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при редактировании партий" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            undo, return error .
          end.
        end.
        when "exit":u
        then do:
          define variable v-doc-num    like ub.price-list.doc-num    no-undo .
          define variable v-price-sale like ub.price-list.price-sale no-undo .
          define variable v-road-tax   like ub.price-list.road-tax   no-undo .
          define variable v-excise     like ub.price-list.excise     no-undo .
          if  buf_trn-doc.doc-type = 'при':U
          and buf_trn-doc.internal = false
          then do:
          end.
          else do:
            if l-goods-bottle
            then do:
              define variable v-gds-code    like ub.goods.gds-code  no-undo .
              define variable v-root-b-code like ub.bar-code.b-code no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  ?
  ,output v-root-b-code
  )  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  v-root-b-code
  ,input  v-root-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
              if v-price-sale = ?
              then do:
                return
                  "Для товара " + string(buf_doc-line.artic)
                  + " " + string(buf_doc-line.prod-type)
                  + " " + string(buf_doc-line.prod-code)
                  + " типа стеклопосуда не задана продажная цена"
                  .
              end.
            end.
            else do:
              assign
                v-road-tax = 0
                v-excise   = 0
              .
            end.
          end.
          define variable v-curr-r-b as character no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
          if p-dop = "" or p-dop = ? then do:
             if buf_trn-doc.ext-doc-type = 'ie':U then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  )  .
                define variable  v-dop1 as character no-undo .
                define variable  v-dop2 as character no-undo .
                run lineattr-value in this-procedure (
                    input   buf_trn-doc.doc-code  ,
                    input   v-gds-code  ,
                    input   'price-prod':U ,
                    output  v-dop1      ,
                    output  v-type )
                    no-error .
                run lineattr-value in this-procedure (
                    input   buf_trn-doc.doc-code  ,
                    input   v-gds-code  ,
                    input   'price-prodvat':U ,
                    output  v-dop2   ,
                    output  v-type )
                    no-error .
                    p-dop = substitute("&1;&2" , v-dop1, v-dop2) .
             end.
             if p-dop = ? then p-dop = "" .
          end.
          create buf_parts .
          assign
            buf_parts.obj-type       = buf_doc-line.obj-type
            buf_parts.obj-code       = buf_doc-line.obj-code
            buf_parts.artic          = buf_doc-line.artic
            buf_parts.prod-type      = buf_doc-line.prod-type
            buf_parts.prod-code      = buf_doc-line.prod-code
            buf_parts.in-code        = buf_doc-line.doc-code
            buf_parts.out-code       = buf_doc-line.doc-code
            buf_parts.part-code      = p-part-code
            buf_parts.cst-code       = p-cst-code
            buf_parts.pl-code        = p-pl-code
            buf_parts.ps             = p-ps
            buf_parts.dop            = p-dop
            buf_parts.doc-type       = buf_trn-doc.doc-type
            buf_parts.status_        = no
            buf_parts.qnty           = 0
            buf_parts.fact-qnty      = 0
            buf_parts.cli-qnty       = 0
            buf_parts.real-qnty      = 0
            buf_parts.transport-base = 0
            buf_parts.transport-rubl = 0
            buf_parts.other-base     = 0
            buf_parts.other-rubl     = 0
            buf_parts.supp-type      = p-supp-type
            buf_parts.supp-code      = p-supp-code
            buf_parts.host-code      = buf_trn-doc.host-code
            buf_parts.last-date      = p-last-date
            buf_parts.hold-date      = p-hold-date
            buf_parts.vat-type       = p-vat-type
            buf_parts.vat-pc         = p-vat-pc
            buf_parts.slt-type       = p-slt-type
            buf_parts.slt-pc         = p-slt-pc
            buf_parts.contract-code  = buf_trn-doc.contract-code
          .
          if buf_trn-doc.ext-doc-type = 'ie':U
          or buf_trn-doc.ext-doc-type = 'im':U
          then do:
            if buf_trn-doc.ext-doc-type = 'ie':U
            then do:
              assign
                buf_parts.is-supp       = yes
              .
            end.
            else do:
              assign
                buf_parts.is-supp       = no
              .
            end.
            assign
              buf_parts.rsrv-free     = ?
              buf_parts.pay-code      = buf_trn-doc.pay-code
              buf_parts.purch-code    = buf_trn-doc.purch-code
              buf_parts.exch-code     = buf_trn-doc.exch-code
              buf_parts.cli-base-rate = buf_doc-line.cli-base-rate
              buf_parts.price-cli     = buf_doc-line.price-cli
              buf_parts.price-base    = buf_doc-line.price-base
              buf_parts.price-rubl    = buf_doc-line.price-rubl
            .
            if v-curr-r-b = 'base':U
            then do:
              assign
                buf_parts.road-tax-base = buf_doc-line.road-tax
              .
              assign
                buf_parts.road-tax-rubl = buf_parts.road-tax-base
                                        * buf_trn-doc.base-rate
                                        / buf_trn-doc.base-scale
              .
            end.
            else do:
              assign
                buf_parts.road-tax-rubl = buf_doc-line.road-tax
              .
              assign
                buf_parts.road-tax-base = buf_parts.road-tax-rubl
                                        / buf_trn-doc.base-rate
                                        * buf_trn-doc.base-scale
              .
            end.
            if  l-goods-twounit = false
            and buf_trn-doc.ext-doc-type = 'ie':U
            then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   buf_trn-doc.doc-code
  ,input   buf_trn-doc.base-rate
  ,input   buf_trn-doc.base-scale
  ,input   buf_trn-doc.exch-rate
  ,input   buf_trn-doc.exch-scale
  ,input   buf_trn-doc.vat-type
  ,input   buf_trn-doc.slt-type
  ,input   buf_parts.artic
  ,input   buf_parts.prod-type
  ,input   buf_parts.prod-code
  ,input   buf_parts.price-cli
  ,input   buf_parts.cli-base-rate
  ,input   buf_parts.price-rubl
  ,input   buf_parts.vat-pc
  ,input   buf_parts.slt-pc
  ,input   buf_doc-line.road-tax
  ,input   buf_parts.transport-rubl
  ,input   buf_parts.other-rubl
  ,output  v-price-cli
  ,output  v-price-cli-unit-base
  ,output  v-price-road-tax
  ,output  v-price-other-exp
  ,output  v-price-transport-exp
  ,output  v-price-without-abs
  ,output  v-price-slt
  ,output  v-price-no-slt
  ,output  v-price-vat
  ,output  v-price-no-vat-slt
  ,output  v-price-rubl
  ,output  v-price-road-tax-rubl
  ,output  v-price-other-exp-rubl
  ,output  v-price-transport-exp-rubl
  ,output  v-price-without-abs-rubl
  ,output  v-price-slt-rubl
  ,output  v-price-no-slt-rubl
  ,output  v-price-vat-rubl
  ,output  v-price-no-vat-slt-rubl
  ,output  v-price-base
  ,output  v-price-road-tax-base
  ,output  v-price-other-exp-base
  ,output  v-price-transport-exp-base
  ,output  v-price-without-abs-base
  ,output  v-price-slt-base
  ,output  v-price-no-slt-base
  ,output  v-price-vat-base
  ,output  v-price-no-vat-slt-base
  ) no-error.
              if error-status :error
              then do:
                return error "Ошибка при пересчете линии документа".
              end.
              assign
                buf_parts.price-cli  = v-price-cli
                buf_parts.price-rubl = v-price-rubl
                buf_parts.price-base = v-price-base
              .
            end.
          end.
          else do:
            define variable v-curr-r-b-code as integer no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  buf_trn-doc.host-code
  ,output v-curr-r-b-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры basecode.i" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.rsrv-free     = (if can-do('рас,спи':U, buf_trn-doc.doc-type)
                                          or (can-do('инв':U, buf_trn-doc.doc-type)
                                              and (buf_parts.qnty + p-change-qnty) < 0
                                              )
                                        then yes
                                        else no
                                      )
              buf_parts.is-supp       = ( if l-create-old-return then yes else no )
              buf_parts.pay-code      = buf_trn-doc.pay-code
              buf_parts.purch-code    = integer('1':U)
              buf_parts.price-base    = p-part-reserv-base
              buf_parts.price-rubl    = p-part-reserv-rubl
              buf_parts.road-tax-base = 0
              buf_parts.road-tax-rubl = 0
              buf_parts.cli-base-rate = buf_doc-line.cli-base-rate
              buf_parts.exch-code     = 0
              buf_parts.price-cli     = buf_parts.price-rubl
            .
          end.
          validate buf_parts .
        end.
        when "quit":u
        then do:
        end.
      end case .
    end.
    if available buf_parts
    then do:
      if l-fact-qnty
      then do:
        assign
          buf_parts.fact-qnty = buf_parts.fact-qnty + p-change-qnty
        .
      end.
      else do:
        assign
          buf_parts.qnty      = buf_parts.qnty + p-change-qnty
          buf_parts.fact-qnty = buf_parts.qnty
        .
        if buf_trn-doc.doc-type = 'инв':U
        then do:
          assign
            buf_parts.rsrv-free     = ( if buf_parts.qnty < 0
                                        then true
                                        else false
                                      )
          .
        end.
      end.
      if l-goods-twounit = true
      then do:
        if p-cli-qnty <> 0
        then do:
          assign
            buf_parts.cli-qnty = p-cli-qnty
          .
          assign
            buf_parts.cli-base-rate = buf_parts.qnty / buf_parts.cli-qnty
          .
        end.
      end.
      else do:
        if buf_parts.cli-base-rate <> 0
        then do:
          assign
            buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
          .
        end.
        else do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
        if abs(buf_parts.cli-qnty - p-cli-qnty) < 0.0011
        then do :
          assign
            buf_parts.cli-qnty = p-cli-qnty
          .
        end .
      end.
      if l-goods-twounit = false
      then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run qntycalc in g#library
  (input  'cli-qnty'
  ,input  buf_parts.cli-base-rate
  ,input  buf_parts.cli-qnty
  ,input  buf_parts.qnty
  ,output buf_parts.cli-qnty
  ,output buf_parts.qnty
  ) no-error .
        if error-status :error
        then do:
          message
            "Невозможно пересчитать количество по ТТН" skip
            "Документ" buf_parts.out-code skip
            'Артикул':U buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
            "Партия" + string(buf_parts.part-code) skip
            return-value skip
            view-as alert-box .
          undo, return error .
        end.
      end.
      if l-goods-serial
      then do:
        if  buf_parts.qnty <> 0
        and buf_parts.qnty <> 1
        then do:
          message
            "Товар серийный." skip
            "Невозможно порождение партии с количеством, отличным от 1."
            view-as alert-box .
          undo, return error .
        end.
      end.
    end.
    return .
  end.
end procedure.
procedure partscr_check-valid-supp :
  define input parameter  p-supp-type         like ub.parts.supp-type no-undo .
  define input parameter  p-supp-code         like ub.parts.supp-code no-undo .
  define input parameter  p-trn-doc-supp-type like ub.parts.supp-type no-undo .
  define input parameter  p-trn-doc-supp-code like ub.parts.supp-code no-undo .
  define input parameter  p-extended-doc-type as character no-undo .
  define output parameter p-old-return        as logical no-undo .
  define output parameter p-reason            as character no-undo .
  assign
    p-old-return = false
    p-reason     = ""
  .
  if p-supp-type <> p-trn-doc-supp-type
  or p-supp-code <> p-trn-doc-supp-code
  then do:
    if p-extended-doc-type = 're':U
    or p-extended-doc-type = 'rs':U
    or p-extended-doc-type = 'vt':U
    or p-extended-doc-type = 'vp':U
    then do:
      if p-supp-type = 'чел':U
      or p-supp-type = 'орг':U
      then do:
        assign
          p-old-return = true
        .
      end.
      else do:
        assign
          p-reason = "Поставщиком партии старого возврата может быть только человек или организация"
        .
        return .
      end.
    end.
    else do:
      assign
        p-reason = "Поставщиком порожденной партии может быть только объект документа"
      .
      return .
    end.
  end.
  return .
end procedure.
procedure partscr_get-default-values :
  define parameter buffer buf_doc-line for ub.doc-line .
  define output parameter p-vat-type   as character no-undo .
  define output parameter p-vat-pc     as decimal   no-undo .
  define output parameter p-slt-type   as character no-undo .
  define output parameter p-slt-pc     as decimal   no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods for ub.goods .
  define variable v-vat-pc as decimal   no-undo .
  define variable v-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка документа" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден документ" skip
        "Код документа" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка поиска товара" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_trn-doc.ext-doc-type = 'ie':U
    or buf_trn-doc.ext-doc-type = 'im':U
    then do:
      assign
        p-vat-type = buf_trn-doc.vat-type
        p-vat-pc   = buf_doc-line.vat-pc
        p-slt-type = buf_trn-doc.slt-type
        p-slt-pc   = buf_doc-line.slt-pc
      .
    end.
    else do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
      assign
        p-vat-type = 'в т. ч.':U
        p-vat-pc   = v-vat-pc
        p-slt-type = 'без':U
        p-slt-pc   = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure partrqst :
  define input  parameter p-doc-code                   like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type                   like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code                   like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                      like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type                  like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code                  like ub.doc-line.prod-code no-undo .
  define output parameter p-total-parts-qnty           like ub.parts.qnty         no-undo .
  define output parameter p-total-parts-fact-qnty      like ub.parts.fact-qnty    no-undo .
  define output parameter p-total-parts-cli-qnty       like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-fact-cli-qnty  like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-price-cli      as decimal                 no-undo .
  define output parameter p-total-parts-price-base     as decimal                 no-undo .
  define output parameter p-total-parts-price-rubl     as decimal                 no-undo .
  define output parameter p-total-parts-transport-base as decimal                 no-undo .
  define output parameter p-total-parts-transport-rubl as decimal                 no-undo .
  define output parameter p-total-parts-other-base     as decimal                 no-undo .
  define output parameter p-total-parts-other-rubl     as decimal                 no-undo .
  define variable vss-description as character no-undo init "partrqst: Суммарная информация по всем зарезервированным партиям строки документа".
  do
  on error undo, return error return-value
  :
    assign
      p-total-parts-qnty           = 0
      p-total-parts-fact-qnty      = 0
      p-total-parts-cli-qnty       = 0
      p-total-parts-fact-cli-qnty  = 0
      p-total-parts-price-cli      = 0
      p-total-parts-price-base     = 0
      p-total-parts-price-rubl     = 0
      p-total-parts-transport-base = 0
      p-total-parts-transport-rubl = 0
      p-total-parts-other-base     = 0
      p-total-parts-other-rubl     = 0
    .
    define buffer buf_parts for ub.parts .
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      define variable v-parts-fact-multiplier as decimal   no-undo .
      assign
        v-parts-fact-multiplier = 1
      .
      if buf_parts.qnty <> 0 then do:
        assign
          v-parts-fact-multiplier = buf_parts.fact-qnty / buf_parts.qnty
        .
      end.
      assign
        p-total-parts-qnty            = p-total-parts-qnty       + buf_parts.qnty
        p-total-parts-fact-qnty       = p-total-parts-fact-qnty  + buf_parts.fact-qnty
        p-total-parts-cli-qnty        = p-total-parts-cli-qnty   + buf_parts.cli-qnty
        p-total-parts-fact-cli-qnty   = p-total-parts-fact-cli-qnty
                                      + buf_parts.cli-qnty * v-parts-fact-multiplier
        p-total-parts-price-cli       = p-total-parts-price-cli  + buf_parts.cli-qnty  * buf_parts.price-cli
        p-total-parts-price-base      = p-total-parts-price-base + buf_parts.fact-qnty * buf_parts.price-base
        p-total-parts-price-rubl      = p-total-parts-price-rubl + buf_parts.fact-qnty * buf_parts.price-rubl
        p-total-parts-transport-base  = p-total-parts-transport-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-base <> ?
                                          then buf_parts.transport-base
                                          else 0
                                          )
        p-total-parts-transport-rubl  = p-total-parts-transport-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-rubl <> ?
                                          then buf_parts.transport-rubl
                                          else 0
                                          )
        p-total-parts-other-base      = p-total-parts-other-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-base <> ?
                                          then buf_parts.other-base
                                          else 0
                                          )
        p-total-parts-other-rubl      = p-total-parts-other-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-rubl <> ?
                                          then buf_parts.other-rubl
                                          else 0
                                          )
      .
    end.
  end.
end procedure.
procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo .
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo .
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo .
  define output parameter p-reserv-pl-code as   logical             no-undo .
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo .
  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods
  then do:
    return error "Не найден товар. Первичный бар-код " + string( p-gds-code ) .
  end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'place-rsrv=request'
  ,output p-reserv-pl-code
  ) no-error .
  if error-status :error
  then do:
    return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.
  if p-reserv-pl-code = no
  then do:
    return .
  end.
  if p-chk-and-chs <> yes
  then do:
    return .
  end.
  find first buf_pl-gds no-lock where
             buf_pl-gds.obj-type = p-obj-type and
             buf_pl-gds.obj-code = p-obj-code and
             buf_pl-gds.gds-code = p-gds-code no-error .
  if not available buf_pl-gds
  then do:
    return error "К товару не привязано ни одного места хранения" .
  end.
  find first buf_second_pl-gds no-lock where
             buf_second_pl-gds.obj-type  = p-obj-type          and
             buf_second_pl-gds.obj-code  = p-obj-code          and
             buf_second_pl-gds.gds-code  = p-gds-code          and
             recid( buf_second_pl-gds ) <> recid( buf_pl-gds ) no-error .
  if not available buf_second_pl-gds
  then do:
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do:
    if not valid-handle( parparentproc )
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
    run str/plgdssel.p
      (
         input parparentproc
      ,  input p-obj-type
      ,  input p-obj-code
      ,  input p-gds-code
      , output p-pl-code
      ) no-error .
    if error-status :error
    then do:
      return error substitute( 'Ошибка при вызове программы &1&2&3&2&4&2'
                             , 'plgdssel.p':U
                             , chr(10)
                             , error-status :get-message( 1 )
                             , return-value
                             ) .
    end.
    if p-pl-code = ? or
       p-pl-code = 0
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
  end.
end procedure.
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info20 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info20, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info20, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info20, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info20, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info20 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info20, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info20 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info20, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info20, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info20, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info20, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info20, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info20, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info20 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info20 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info20, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info20, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info20, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info20 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info20 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info20, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info20, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
def var vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure partcopy :
  define input parameter  p-free-output-copy as logical   no-undo .
  define input parameter  p-out-code         like ub.parts.out-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf_parts          for ub.parts .
  define input parameter  p-mark             as character no-undo .
  define variable vss-description as character no-undo init "partcopy-01: процедура копирования партии".
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable part-key-rec      as character no-undo .
  define variable orig-part-key-rec as character no-undo .
  define variable del-part-key-rec  as character no-undo .
  define variable objMarks as class excisemarks  no-undo .
  define variable v-parent-mark-sts as integer   no-undo .
  define variable v-mark-sts-list   as character no-undo .
  define variable oMarkSts as class ibs.th.str.marking.sts.mark .
  oMarkSts = objSrv:Env:Marking:Sts:Mark.
  define buffer buf_gen-attr for ub.gen-attr .
  define buffer buf1_gen-attr for ub.gen-attr .
  define buffer buf_doc-line  for ub.doc-line .
  define buffer buf_marking for ub.marking .
  define buffer buf_marking-childs for ub.marking .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer orig_marking-lines-childs for ub.marking-lines .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_marking-lines-childs for ub.marking-lines .
  define buffer buf_marking-pack for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer buf_goods for ub.goods .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer pri_trn-doc for ub.trn-doc .
  define buffer buf_chk-doc for ub.chk-doc .
  do
  on error undo, return error return-value
  :
    if p-free-output-copy = true
    then do:
      if  p-out-code <> 'free-zone':U
      and p-out-code <> 'out-zone':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info23 skip
          "Ошибка задания входных параметров процедуры partcopy" skip
          "p-free-output-copy" p-free-output-copy skip
          "p-out-code" p-out-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    if buf_orig_parts.out-code <> p-out-code
    then do:
      find first buf_parts exclusive-lock
        where buf_parts.obj-type  = buf_orig_parts.obj-type
          and buf_parts.obj-code  = buf_orig_parts.obj-code
          and buf_parts.artic     = buf_orig_parts.artic
          and buf_parts.prod-type = buf_orig_parts.prod-type
          and buf_parts.prod-code = buf_orig_parts.prod-code
          and buf_parts.in-code   = buf_orig_parts.in-code
          and buf_parts.out-code  = p-out-code
          and buf_parts.part-code = buf_orig_parts.part-code
        no-error.
      if not available buf_parts
      then do:
        define variable v-rsrv-free as logical   no-undo .
        if p-out-code = 'free-zone':U
        or p-out-code = 'out-zone':U
        then do:
          assign
            v-rsrv-free =
       (if p-out-code = 'free-zone':U then yes else no)
          .
        end.
        else do:
          assign
            v-rsrv-free = ?
          .
        end.
        create buf_parts .
        buffer-copy buf_orig_parts to buf_parts
        assign
          buf_parts.out-code  = p-out-code
          buf_parts.status_   = no
          buf_parts.rsrv-free = v-rsrv-free
          buf_parts.qnty      = 0
          buf_parts.fact-qnty = 0
          buf_parts.real-qnty = 0
          buf_parts.cli-qnty  = 0
        .
        validate buf_parts .
      end.
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_orig_parts:handle)
                                        ,output orig-part-key-rec).
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
            and ub.gen-attr.p-key =  orig-part-key-rec:
          if not valid-object (objMarks)
            then objMarks = new excisemarks (buf_parts.obj-type, buf_parts.obj-code).
            if p-out-code = 'free-zone':U
            and (entry(7,orig-part-key-rec,chr(3)) = entry(8,orig-part-key-rec,chr(3)) )
             then
            do:
                objMarks:CrFreeMarkForParts(buffer buf_orig_parts, buffer buf_parts, ub.gen-attr.attr-code) .
                if objMarks:StatusErr
                    then
                do:
                    message objMarks:ReturnMsg view-as alert-box error.
                    delete object objMarks no-error.
                    undo, return error.
                end.
            end.
          if (entry(7,orig-part-key-rec,chr(3)) <> entry(8,orig-part-key-rec,chr(3)) ) then
          do:
              if p-mark <> "" then do:
              if p-out-code = 'free-zone':U then do:
                objMarks:RezervMarkForParts(buffer buf_parts, buffer buf_orig_parts, p-mark) .
              end.
              else do:
                objMarks:RezervMarkForParts(buffer buf_orig_parts, buffer buf_parts, p-mark) .
              end.
              if objMarks:StatusErr
                then
              do:
                message objMarks:ReturnMsg view-as alert-box error.
                delete object objMarks no-error.
                undo, return error.
              end.
            end.
          end.
          if p-out-code = 'out-zone':U then
          do:
              objMarks:CrOutMarkForParts(buffer buf_orig_parts, buffer buf_parts, ub.gen-attr.attr-code) .
              if objMarks:StatusErr
                  then
              do:
                  message objMarks:ReturnMsg view-as alert-box error.
                  delete object objMarks no-error.
                  undo, return error.
              end.
          end.
      end.
      delete object objMarks no-error.
      if p-mark = "news" then return .
      find first pri_trn-doc no-lock where pri_trn-doc.doc-code = buf_orig_parts.out-code no-error .
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-out-code no-error.
      if not available buf_trn-doc
      then
         find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_orig_parts.out-code no-error .
      if (
          p-out-code = 'free-zone':U
          and buf_orig_parts.in-code = buf_orig_parts.out-code
         )
      or
         (
          p-out-code = 'free-zone':U
          and available pri_trn-doc
          and (pri_trn-doc.ext-doc-type = 'iv':U or pri_trn-doc.ext-doc-type = 'rv':U)
         )
      or
         (
          available buf_trn-doc
          and p-out-code = buf_trn-doc.doc-code
          and buf_trn-doc.ext-doc-type = 'vt':U
         )
      or
         (
          p-mark = ""
          and available buf_trn-doc
          and p-out-code = 'free-zone':U
          and buf_trn-doc.ext-doc-type = 'vt':U
         )
      or
         (
          p-mark = ""
          and available buf_trn-doc
          and p-out-code = 'free-zone':U
          and buf_trn-doc.ext-doc-type = 'rs':U
         )
      then do :
        find first ub.goods no-lock where ub.goods.artic = buf_parts.artic
          and ub.goods.prod-type = buf_parts.prod-type
          and ub.goods.prod-code = buf_parts.prod-code.
        def buffer buf_orig_ml for ub.marking-lines.
        for each buf_orig_ml where buf_orig_ml.gds-code = ub.goods.gds-code
          and buf_orig_ml.obj-type = buf_orig_parts.obj-type
          and buf_orig_ml.obj-code = buf_orig_parts.obj-code
          and buf_orig_ml.in-code = buf_orig_parts.in-code
          and buf_orig_ml.out-code = buf_orig_parts.out-code
          and buf_orig_ml.part-code = buf_orig_parts.part-code
          and buf_orig_ml.prt-code = buf_orig_parts.prt-code:
          if available pri_trn-doc
          and pri_trn-doc.ext-doc-type = 'iv':U
          and buf_orig_ml.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
          then do :
            for first buf_marking exclusive-lock where buf_marking.mark = buf_orig_ml.mark :
              assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB .
            end .
            next .
          end .
          find first ub.marking-lines no-lock where ub.marking-lines.mark     = buf_orig_ml.mark
                                                and ub.marking-lines.gds-code = buf_orig_ml.gds-code
                                                and ub.marking-lines.obj-type = buf_orig_ml.obj-type
                                                and ub.marking-lines.obj-code = buf_orig_ml.obj-code
                                                and ub.marking-lines.in-code  = buf_orig_ml.in-code
                                                and ub.marking-lines.out-code = p-out-code
                                                and ub.marking-lines.part-code = buf_orig_ml.part-code
                                                and ub.marking-lines.prt-code = buf_orig_ml.prt-code
                                                no-error .
          if not available ub.marking-lines
          then do :
            create ub.marking-lines.
            buffer-copy buf_orig_ml to ub.marking-lines
            assign
              ub.marking-lines.out-code  = p-out-code
              ub.marking-lines.fact-order = pri_trn-doc.fact-order when available pri_trn-doc
            .
            validate ub.marking-lines.
          end .
          if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U then do:
          for first buf_marking exclusive-lock where buf_marking.mark = buf_orig_ml.mark
            and not (buf_marking.sts = oMarkSts:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U):
            if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB and
               not can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) and
               not can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
            then do:
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              validate buf_marking.
            end.
          end .
        end .
        end.
      end .
      define variable v-doc-type  as character no-undo .
      define variable   v-status    as character no-undo .
      define variable v-fact-qnty   as  decimal no-undo .
      define variable ii    as integer no-undo .
      find first buf_goods no-lock where buf_goods.artic = buf_orig_parts.artic
                                     and buf_goods.prod-type = buf_orig_parts.prod-type
                                     and buf_goods.prod-code = buf_orig_parts.prod-code
                                     .
      if available pri_trn-doc
      and pri_trn-doc.ext-doc-type = 'rs':U
      then do :
        if p-mark <> ""
        then do :
        end .
        else do :
        end .
      end .
      else do :
        if buf_orig_parts.in-code <> buf_orig_parts.out-code
        and p-mark <> ""
        then do :
          if p-out-code = 'free-zone':U
          then do:
              if chg-qnty < 0
              then do :
                find first orig_marking-lines no-lock where orig_marking-lines.mark       = p-mark
                                                        and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                        and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                        and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                        and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                        and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                        and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                        and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                        no-error .
                if available orig_marking-lines
                then do :
                  find first buf_marking-lines no-lock where buf_marking-lines.mark       = p-mark
                                                         and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                         and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                         and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                         and buf_marking-lines.in-code    = buf_parts.in-code
                                                         and buf_marking-lines.out-code   = buf_parts.out-code
                                                         and buf_marking-lines.part-code  = buf_parts.part-code
                                                         and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                         no-error .
                  if not available buf_marking-lines
                  then do :
                    create buf_marking-lines .
                    assign
                      buf_marking-lines.mark       = p-mark
                      buf_marking-lines.doc-level  = orig_marking-lines.doc-level
                      buf_marking-lines.gds-code   = buf_goods.gds-code
                      buf_marking-lines.obj-type   = buf_parts.obj-type
                      buf_marking-lines.obj-code   = buf_parts.obj-code
                      buf_marking-lines.in-code    = buf_parts.in-code
                      buf_marking-lines.out-code   = buf_parts.out-code
                      buf_marking-lines.part-code  = buf_parts.part-code
                      buf_marking-lines.prt-code   = buf_parts.prt-code
                    .
                    validate buf_marking-lines.
                  end .
                  for first buf_marking exclusive-lock where buf_marking.mark = p-mark :
                    assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                    for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                      for first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_marking-chk.doc-code
                                                      and buf_chk-doc.out-code = buf_orig_parts.out-code
                                                      :
                        assign buf_marking-chk.sts = 0 .
                        validate buf_marking-chk.
                      end .
                    end .
                    if buf_marking.unit-ext <> "UNIT" or
                       (buf_marking.unit-ext = ? and buf_marking.box-qnty > 1)
                    then do :
                      run addChildMarkingLines in this-procedure (
                        buf_marking.mark,
                        objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB,
                        buffer buf_marking-lines,
                        buffer buf_parts,
                        buffer orig_marking-lines,
                        buffer buf_orig_parts,
                        buffer buf_goods
                      ).
                    end .
                  end.
                  find current orig_marking-lines exclusive-lock .
                  delete orig_marking-lines .
                end .
              end .
          end.
          else do:
            find first orig_marking-lines exclusive-lock where orig_marking-lines.mark       = p-mark
                                                           and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                           and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                           and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                           and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                           and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                           and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                           and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                           no-error .
              find first buf_marking-lines no-lock where  buf_marking-lines.mark       = p-mark
                                                      and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                      and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                      and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                      and buf_marking-lines.in-code    = buf_parts.in-code
                                                      and buf_marking-lines.out-code   = buf_parts.out-code
                                                      and buf_marking-lines.part-code  = buf_parts.part-code
                                                      and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                      no-error .
              if not available buf_marking-lines
              then do :
                create buf_marking-lines .
                assign
                  buf_marking-lines.mark       = p-mark
                  buf_marking-lines.doc-level  = 1
                  buf_marking-lines.gds-code   = buf_goods.gds-code
                  buf_marking-lines.obj-type   = buf_parts.obj-type
                  buf_marking-lines.obj-code   = buf_parts.obj-code
                  buf_marking-lines.in-code    = buf_parts.in-code
                  buf_marking-lines.out-code   = buf_parts.out-code
                  buf_marking-lines.part-code  = buf_parts.part-code
                  buf_marking-lines.prt-code   = buf_parts.prt-code
                  buf_marking-lines.sts        = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                .
                validate buf_marking-lines.
              end .
              for first buf_marking exclusive-lock where buf_marking.mark = p-mark :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB .
                validate buf_marking.
                for first buf_marking-childs exclusive-lock where
                          buf_marking-childs.mark = buf_marking.mark-parent:
                  buf_marking-childs.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB .
                  validate buf_marking-childs.
                end.
                for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                  for first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_marking-chk.doc-code
                                                  and buf_chk-doc.out-code = buf_parts.out-code
                                                  :
                    if buf_marking-chk.sts <> 2 then
                    do:
                       assign buf_marking-chk.sts = 1 .
                       validate buf_marking-chk.
                    end.
                  end .
                end .
                if buf_marking.unit-ext <> "UNIT" or
                   (buf_marking.unit-ext = ? and buf_marking.box-qnty > 1)
                then do :
                  run addChildMarkingLines in this-procedure (
                    buf_marking.mark,
                    buf_marking.sts,
                    buffer buf_marking-lines,
                    buffer buf_parts,
                    buffer orig_marking-lines,
                    buffer buf_orig_parts,
                    buffer buf_goods
                  ).
                end .
              end.
              if available orig_marking-lines then
                delete orig_marking-lines .
          end.
        end.
      end .
      if p-out-code = 'out-zone':U
      and trim(p-mark) = ""
      then do :
        for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                              and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                              and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                              and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                              and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                              and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                              and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                              :
          find first buf_marking-lines no-lock where  buf_marking-lines.mark       = orig_marking-lines.mark
                                                  and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                  and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                  and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                  and buf_marking-lines.out-code   = p-out-code
                                                  no-error .
          if available buf_marking-lines
          then do :
            find current buf_marking-lines exclusive-lock .
            delete buf_marking-lines .
            for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
              if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
              then do :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                validate buf_marking.
              end.
            end .
          end .
          else do :
            if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U and buf_parts.out-code <> 'out-zone':U then do:
            create buf_marking-lines .
            assign
              buf_marking-lines.mark       = orig_marking-lines.mark
              buf_marking-lines.doc-level  = orig_marking-lines.doc-level
              buf_marking-lines.gds-code   = buf_goods.gds-code
              buf_marking-lines.obj-type   = buf_parts.obj-type
              buf_marking-lines.obj-code   = buf_parts.obj-code
              buf_marking-lines.in-code    = buf_parts.in-code
              buf_marking-lines.out-code   = buf_parts.out-code
              buf_marking-lines.part-code  = buf_parts.part-code
              buf_marking-lines.prt-code   = buf_parts.prt-code
            .
            validate buf_marking-lines.
            if buf_parts.out-code <> buf_parts.in-code
            and buf_parts.out-code <> 'free-zone':U
            and buf_parts.out-code <> 'out-zone':U
            then do :
              find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code no-error .
              if available buf_trn-doc then buf_marking-lines.fact-order = buf_trn-doc.fact-order .
            end .
            end.
          end .
          release buf_marking-lines no-error .
        end.
      end .
      if p-mark <> "" and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U
      then do:
        for each orig_marking-lines no-lock where orig_marking-lines.mark         = p-mark
                                                and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                .
          find first buf_marking-lines no-lock where buf_marking-lines.mark       = p-mark
                                                 and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                 and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                 and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                 and buf_marking-lines.in-code    = buf_parts.in-code
                                                 and buf_marking-lines.out-code   = buf_orig_parts.out-code
                                                 and buf_marking-lines.part-code  = buf_parts.part-code
                                                 no-error .
          for each ub.marking where ub.marking.mark = buf_marking-lines.mark:
            if p-out-code = 'free-zone':U and not ub.marking.sts = oMarkSts:MarkError:KeyIntDB
              then assign ub.marking.sts = oMarkSts:FreeZone:KeyIntDB.
            if p-out-code = 'out-zone':U and not ub.marking.sts = oMarkSts:MarkError:KeyIntDB
              then assign ub.marking.sts = oMarkSts:OutZone:KeyIntDB.
            validate ub.marking.
          end.
          run partcopy-to-childs-mark (buffer buf_marking-lines, buffer orig_marking-lines, input buf_parts.out-code, oMarkSts).
          if available (buf_marking-lines)
          then do:
            assign
              buf_marking-lines.mark       = p-mark
              buf_marking-lines.doc-level  = orig_marking-lines.doc-level
              buf_marking-lines.gds-code   = buf_goods.gds-code
              buf_marking-lines.obj-type   = buf_parts.obj-type
              buf_marking-lines.obj-code   = buf_parts.obj-code
              buf_marking-lines.in-code    = buf_parts.in-code
              buf_marking-lines.out-code   = buf_parts.out-code
              buf_marking-lines.part-code  = buf_parts.part-code
            .
            validate buf_marking-lines.
          end.
        end.
      end.
    end.
    else do:
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(buf_orig_parts)
        .
    end.
    if p-out-code = 'free-zone':U
    or p-out-code = 'out-zone':U
    then do:
      if buf_parts.rsrv-free <>
       (if buf_parts.out-code = 'free-zone':U then yes else no)
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info23 skip
          "Ошибка типа резерва партии" skip
          "Объект" buf_parts.obj-type buf_parts.obj-code  skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Партия" buf_parts.in-code buf_parts.part-code skip
          "Резерв" buf_parts.out-code skip
          "Статус" buf_parts.status_ skip
          "Тип резерва" buf_parts.rsrv-free skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure partcopy-to-childs-mark :
  define parameter buffer buf_ml for ub.marking-lines .
  define parameter buffer buf_orig-ml for ub.marking-lines .
  define input parameter p-out-code as character no-undo .
  define input parameter THMarkSts as class ibs.th.str.marking.sts.mark no-undo .
  define buffer buf_ml-childs for ub.marking-lines .
  for each ub.marking where ub.marking.mark-parent = buf_ml.mark:
    if p-out-code = 'free-zone':U and not ub.marking.sts = THMarkSts:MarkError:KeyIntDB
      then assign ub.marking.sts = THMarkSts:FreeZone:KeyIntDB.
    if p-out-code = 'out-zone':U and not ub.marking.sts = THMarkSts:MarkError:KeyIntDB
      then assign ub.marking.sts = THMarkSts:OutZone:KeyIntDB.
    for each buf_ml-childs exclusive-lock where buf_ml-childs.mark = ub.marking.mark
      and buf_ml-childs.obj-type  = buf_orig-ml.obj-type
      and buf_ml-childs.obj-code  = buf_orig-ml.obj-code
      and buf_ml-childs.in-code   = buf_orig-ml.in-code
      and buf_ml-childs.out-code  = buf_orig-ml.out-code
      and buf_ml-childs.part-code = buf_orig-ml.part-code
      and buf_ml-childs.prt-code  = buf_orig-ml.prt-code
      :
      assign
        buf_ml-childs.out-code  = p-out-code
      .
      run partcopy-to-childs-mark (buffer buf_ml-childs, buffer buf_orig-ml, input p-out-code, input THMarkSts).
    end.
  end.
end.
procedure partcopy-update-parts :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type  like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable vss-description as character no-undo init "partcopy-update-parts-01: процедура обработки партий при закрытии документа".
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer archive_parts for ub.parts .
  define buffer buf_parts   for ub.parts .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer buf_marking for ub.marking .
  define buffer buf_goods for ub.goods .
  define variable v-rsrv-code     as character no-undo .
  define variable v-goods-twounit as logical   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock where buf_goods.artic = p-artic
                                   and buf_goods.prod-type = p-prod-type
                                   and buf_goods.prod-code = p-prod-code
                                   no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define query partcopy-select-parts for archive_parts .
    open query partcopy-select-parts preselect each archive_parts
      where archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
        and archive_parts.out-code  = p-doc-code
      .
    get first partcopy-select-parts .
    if buf_trn-doc.doc-type = 'при':U
    then do:
      do while available archive_parts
      on error undo, return error return-value
      :
        if can-do('рас,спи':U, buf_trn-doc.doc-type)
        or (buf_trn-doc.doc-type = 'инв':U
            and archive_parts.fact-qnty < 0)
        then do:
          assign
            v-rsrv-code = 'out-zone':U
          .
        end.
        else do:
          assign
            v-rsrv-code = 'free-zone':U
          .
        end.
        assign
          archive_parts.status_   = yes
          archive_parts.rsrv-free = ?
        .
        if archive_parts.in-code = p-doc-code
        then do:
          assign
            archive_parts.fact-num  = buf_trn-doc.fact-num
            archive_parts.fact-date = buf_trn-doc.fact-date
            archive_parts.doc-type  = buf_trn-doc.doc-type
          .
        end.
        if archive_parts.fact-qnty <> 0
        then do:
          run partcopy in this-procedure
            (input  true
            ,input  v-rsrv-code
            ,buffer archive_parts
            ,buffer buf_parts
            ,input  ""
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info23 skip
              "Ошибка при создании партии" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Партия" archive_parts.in-code archive_parts.part-code skip
              "Резерв" v-rsrv-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty     + archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + archive_parts.cli-qnty
            .
            case buf_trn-doc.ext-doc-type :
              when 'ie':U
              then do:
                if archive_parts.cli-qnty <> truncate(archive_parts.cli-qnty, 0 )
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info23 skip
                    "Клиентское количество для товара," skip
                    "который учитывается по двум единицам измерения" skip
                    "должно равняться единице" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" archive_parts.in-code archive_parts.part-code skip
                    "Количество по документу" archive_parts.qnty skip
                    "Фактическое количество" archive_parts.fact-qnty skip
                    "Клиентское количество" archive_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              when 'iv':U
              then do:
                if archive_parts.cli-qnty <> 1
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info23 skip
                    "Клиентское количество для товара," skip
                    "который учитывается по двум единицам измерения" skip
                    "должно равняться единице" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" archive_parts.in-code archive_parts.part-code skip
                    "Количество по документу" archive_parts.qnty skip
                    "Фактическое количество" archive_parts.fact-qnty skip
                    "Клиентское количество" archive_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Товар учитывается по двум единицам измерения" skip
                  "Для приходов разрешен только внешний приход или приход перемещение" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type archive_parts.prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            delete buf_parts .
          end.
        end.
        else do :
          if buf_trn-doc.ext-doc-type = 'iv':U
          then
          for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                and orig_marking-lines.in-code    = archive_parts.in-code
                                                and orig_marking-lines.out-code   = archive_parts.out-code
                                                and orig_marking-lines.part-code  = archive_parts.part-code,
          first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB .
          end .
        end .
        get next partcopy-select-parts .
      end.
    end.
    if buf_trn-doc.doc-type = 'рас':U
    or buf_trn-doc.doc-type = 'спи':U
    or buf_trn-doc.doc-type = 'возврат':U
    or buf_trn-doc.doc-type = 'инв':U
    then do:
      do while available archive_parts
      on error undo, return error return-value
      :
        assign
          archive_parts.status_   = yes
          archive_parts.rsrv-free = ?
        .
        if archive_parts.fact-qnty <> archive_parts.qnty
        then do:
          define variable v-is-hold as logical   no-undo .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info23
              "Ошибка при определении типа документа hold-doc.i" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          if buf_trn-doc.ext-doc-type = 'vt':U
          or (buf_trn-doc.ext-doc-type = 're':U and v-is-hold = true)
          or buf_trn-doc.ext-doc-type = 'ap':U
          or buf_trn-doc.ext-doc-type = 'pc':U
          or buf_trn-doc.ext-doc-type = 'mp':U
          or  buf_trn-doc.ext-doc-type = 'vp':U
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info23 skip
              "Фактическое количество не может отличаться от количества по документу" skip
              "для документов инвентаризации, внутреннего возврата и автоматического возврата между фирмами" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Партия" archive_parts.in-code archive_parts.part-code skip
              "Количество по документу" archive_parts.qnty skip
              "Фактическое количество" archive_parts.fact-qnty skip
              "Клиентское количество" archive_parts.cli-qnty skip
              view-as alert-box error .
            undo, return error .
          end.
          if archive_parts.in-code <> archive_parts.out-code
          then do:
            if can-do('рас,спи':U,buf_trn-doc.doc-type)
            or (buf_trn-doc.doc-type = 'инв':U
                and archive_parts.fact-qnty < 0)
            then do:
              assign
                v-rsrv-code = 'free-zone':U
              .
            end.
            else do:
              assign
                v-rsrv-code = 'out-zone':U
              .
            end.
            run partcopy in this-procedure
              (input  true
              ,input  v-rsrv-code
              ,buffer archive_parts
              ,buffer buf_parts
              ,input  ""
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Ошибка при создании партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Резерв" v-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.qnty      = buf_parts.qnty + (archive_parts.qnty - archive_parts.fact-qnty)
              buf_parts.fact-qnty = buf_parts.qnty
            .
            if v-goods-twounit = true
            then do:
              if archive_parts.cli-qnty <> 1
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Клиентское количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться единице" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              if archive_parts.fact-qnty = 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.cli-qnty + archive_parts.cli-qnty
                .
              end.
              else do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Фактическое количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться нулю или количеству по документу" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            else do:
              if buf_parts.cli-base-rate <> 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                .
              end.
              else do:
                assign
                  buf_parts.cli-qnty = 0
                .
              end.
            end.
          end.
          if  available buf_parts
          and buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            delete buf_parts .
          end.
        end.
        if archive_parts.in-code = buf_trn-doc.doc-code
        then do:
          assign
            archive_parts.fact-num  = buf_trn-doc.fact-num
            archive_parts.fact-date = buf_trn-doc.fact-date
            archive_parts.doc-type  = buf_trn-doc.doc-type
          .
        end.
        if archive_parts.fact-qnty <> 0
        then do:
          if can-do('рас,спи':U, buf_trn-doc.doc-type)
          or (buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
            )
          then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23
                "Ошибка при определении типа документа hold-doc.i" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              v-rsrv-code = 'out-zone':U
            .
            if buf_trn-doc.ext-doc-type  = 'ep':U
            or (buf_trn-doc.ext-doc-type = 'ap':U )
            or (buf_trn-doc.ext-doc-type = 'pc':U )
            then do:
              assign
                v-rsrv-code = ""
              .
              for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                    and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                    and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                    and orig_marking-lines.in-code    = archive_parts.in-code
                                                    and orig_marking-lines.out-code   = archive_parts.out-code
                                                    and orig_marking-lines.part-code  = archive_parts.part-code,
              first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB .
              end .
            end.
          end.
          else do:
            assign
              v-rsrv-code = 'free-zone':U
            .
          end.
          if v-rsrv-code <> ""
          then do:
            run partcopy in this-procedure
              (input  true
              ,input  v-rsrv-code
              ,buffer archive_parts
              ,buffer buf_parts
              ,input  ""
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Ошибка при создании партии" skip
                "Документ" buf_trn-doc.doc-code skip
                "Объект" archive_parts.obj-type archive_parts.obj-code skip
                "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Резерв" v-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.qnty      = buf_parts.qnty + abs(archive_parts.fact-qnty)
              buf_parts.fact-qnty = buf_parts.qnty
            .
            if v-goods-twounit = true
            then do:
              define variable v-qnty-sign as integer   no-undo .
              assign
                v-qnty-sign = 1
              .
              if  buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
              then do:
                assign
                  v-qnty-sign = - 1
                .
              end.
              if archive_parts.cli-qnty <> v-qnty-sign
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Клиентское количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться" v-qnty-sign skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              if archive_parts.fact-qnty = archive_parts.qnty
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.cli-qnty + abs(archive_parts.cli-qnty)
                .
              end.
              else do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Фактическое количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться нулю или количеству по документу" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            else do:
              if buf_parts.cli-base-rate <> 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                .
              end.
              else do:
                assign
                  buf_parts.cli-qnty = 0
                .
              end.
            end.
            if  buf_parts.qnty      = 0
            and buf_parts.fact-qnty = 0
            then do:
              if v-goods-twounit = true
              then do:
                if buf_parts.cli-qnty <> 0
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info23 skip
                    "Ошибка при удалении партии" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" buf_parts.in-code buf_parts.part-code skip
                    "Резерв" buf_parts.out-code skip
                    "qnty" buf_parts.qnty skip
                    "fact-qnty" buf_parts.fact-qnty skip
                    "cli-qnty" buf_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              delete buf_parts .
            end.
          end.
        end.
        if  ( archive_parts.in-code = buf_trn-doc.doc-code
        and archive_parts.supp-type =
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
        and archive_parts.supp-code =
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
        )
        or buf_trn-doc.ext-doc-type = 'rv':U
        then do:
          if can-do('рас,спи':U,buf_trn-doc.doc-type)
          or (buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
            )
          then do:
            assign
              v-rsrv-code = 'free-zone':U
            .
          end.
          else do:
            assign
              v-rsrv-code = 'out-zone':U
            .
          end.
          if not v-izlcstpr
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-rsrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Резерв" v-rsrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              assign
                buf_parts.qnty      = buf_parts.qnty - abs(archive_parts.fact-qnty)
                buf_parts.fact-qnty = buf_parts.qnty
              .
              if buf_trn-doc.ext-doc-type = 'rv':U
              then
              for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                    and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                    and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                    and orig_marking-lines.in-code    = archive_parts.in-code
                                                    and orig_marking-lines.out-code   = archive_parts.out-code
                                                    and orig_marking-lines.part-code  = archive_parts.part-code
                                                    and orig_marking-lines.prt-code   = archive_parts.prt-code,
              first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
                if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
                then
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              end .
              if v-goods-twounit = true
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Запрещено порождение партий," skip
                  "который учитывается по двум единицам измерения" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              else do:
                if buf_parts.cli-base-rate <> 0
                then do:
                  assign
                    buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                  .
                end.
                else do:
                  assign
                    buf_parts.cli-qnty = 0
                  .
                end.
              end.
          end.
        end.
        get next partcopy-select-parts .
      end.
    end.
  end.
end procedure.
procedure partcopy-update-parts-delete :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type  like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable objMarks as class excisemarks no-undo.
  define variable vss-description as character no-undo init "partcopy-update-parts-delete-01: процедура обработки партий при удалении документа".
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer archive_parts  for ub.parts .
  define buffer buf_parts      for ub.parts .
  define buffer buf_parts-attr for ub.parts-attr .
  define variable v-rsrv-code as character no-undo .
  define variable v-unrv-code as character no-undo .
  define variable v-need-rsrv as logical   no-undo .
  define variable v-need-unrv as logical   no-undo .
  define variable v-rsrv-sign as integer   no-undo .
  define variable v-unrv-sign as integer   no-undo .
  define variable v-goods-twounit as logical   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer del_marking-lines for ub.marking-lines .
  define buffer free_marking-lines for ub.marking-lines .
  define buffer buf_marking for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer buf_chk-doc for ub.chk-doc .
  define variable part-key-rec as character no-undo .
  define variable part-key-rec_arhive   as character no-undo .
  define buffer buf1_gen-attr for ub.gen-attr .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-gds-code as integer   no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
    for each archive_parts
      where archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
        and archive_parts.out-code  = p-doc-code
    on error undo, return error return-value
    :
      if archive_parts.fact-qnty <> 0
      then do:
        define variable v-create-part as logical   no-undo .
        define variable v-old-return  as logical   no-undo .
        assign
          v-create-part = false
          v-old-return  = false
        .
        if archive_parts.in-code = buf_trn-doc.doc-code
        then do:
          assign
            v-create-part = true
          .
          if archive_parts.supp-type <>
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
          or archive_parts.supp-code <>
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
          then do:
            assign
              v-old-return = true
            .
          end.
        end.
        define variable v-is-hold as logical   no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info23
            "Ошибка при определении типа документа hold-doc.i" skip
            "Документ" p-doc-code skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partcond in g#library
  (input  buf_trn-doc.ext-doc-type
  ,input  v-is-hold
  ,input  archive_parts.fact-qnty
  ,input  v-create-part
  ,input  v-old-return
  ,output v-rsrv-code
  ,output v-unrv-code
  ,output v-need-rsrv
  ,output v-need-unrv
  ,output v-rsrv-sign
  ,output v-unrv-sign
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info23
            "Ошибка при определении параметров резервирования партии" skip
            "Документ" p-doc-code skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-izlcstpr and archive_parts.fact-qnty > 0 then v-need-unrv = false .
        if v-need-rsrv = true
        then do:
          release buf_parts no-error .
          if archive_parts.out-code <> v-rsrv-code and v-rsrv-sign = -1 and v-izlcstpr
          then do:
              find first buf_parts exclusive-lock
                where buf_parts.obj-type  = archive_parts.obj-type
                  and buf_parts.obj-code  = archive_parts.obj-code
                  and buf_parts.artic     = archive_parts.artic
                  and buf_parts.prod-type = archive_parts.prod-type
                  and buf_parts.prod-code = archive_parts.prod-code
                  and buf_parts.in-code   = archive_parts.out-code
                  and buf_parts.out-code  = v-rsrv-code
                  and buf_parts.part-code = archive_parts.part-code
                no-error.
          end .
          if not available  buf_parts
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-rsrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Необходимо резервировать" v-need-rsrv skip
                  "Резерв" v-rsrv-code skip
                  "Необходимо снятие резервов" v-need-unrv skip
                  "Снятие резервов" v-unrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
          end.
          if new(buf_parts)
          then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Ошибка при определении кода товара" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
              no-error .
            if not available buf_parts-attr
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Не найден атрибут партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            define variable v-fact-num as integer   no-undo .
            define variable v-doc-type as character no-undo .
            run factord-to-fact-num in this-procedure
              (input  buf_parts-attr.fact-order
              ,output v-fact-num
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Ошибка при определении порядкового номера партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnextdt in g#library
  (input  buf_parts-attr.ext-doc-type
  ,output v-doc-type
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Ошибка при определении типа документа" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.fact-date = buf_parts-attr.fact-date
              buf_parts.fact-num  = v-fact-num
              buf_parts.doc-type  = v-doc-type
            .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty  + v-rsrv-sign * archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
          if buf_parts.out-code = 'free-zone':U
          then
          for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                      and buf_marking-lines.obj-type = archive_parts.obj-type
                                                      and buf_marking-lines.obj-code = archive_parts.obj-code
                                                      and buf_marking-lines.in-code  = archive_parts.in-code
                                                      and buf_marking-lines.out-code = archive_parts.out-code
                                                      and buf_marking-lines.part-code = archive_parts.part-code
                                                      and buf_marking-lines.prt-code = archive_parts.prt-code:
            for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
              find first free_marking-lines exclusive-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                            and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                            and free_marking-lines.obj-type   = buf_parts.obj-type
                                                            and free_marking-lines.obj-code   = buf_parts.obj-code
                                                            and free_marking-lines.in-code    = buf_parts.in-code
                                                            and free_marking-lines.out-code   = buf_parts.out-code
                                                            and free_marking-lines.part-code  = buf_parts.part-code
                                                            and free_marking-lines.prt-code   = buf_parts.prt-code
                                                            no-error .
              if available free_marking-lines
              then do :
                delete free_marking-lines .
              end .
              if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB and
                 not can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts))
              then do:
                buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB .
              end.
            end .
          end.
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + v-rsrv-sign * archive_parts.cli-qnty
            .
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer archive_parts:handle)
                                        ,output part-key-rec_arhive).
            for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                                  and ub.gen-attr.p-key =  part-key-rec
            :
              if not valid-object (objMarks)
                then objMarks = new excisemarks (buf_parts.obj-type, buf_parts.obj-code).
              objMarks:DelMarkForParts(buffer buf_parts, buffer archive_parts, ub.gen-attr.attr-code) .
              if objMarks:StatusErr
                  then
              do:
                  message objMarks:ReturnMsg view-as alert-box error.
                  delete object objMarks no-error.
                  undo, return error.
              end.
            end.
            for each del_marking-lines exclusive-lock where del_marking-lines.gds-code = v-gds-code
                                                        and del_marking-lines.obj-type = buf_parts.obj-type
                                                        and del_marking-lines.obj-code = buf_parts.obj-code
                                                        and del_marking-lines.in-code = buf_parts.in-code
                                                        and del_marking-lines.out-code = buf_parts.out-code
                                                        and del_marking-lines.part-code = buf_parts.part-code
                                                        and del_marking-lines.prt-code = buf_parts.prt-code:
              delete del_marking-lines .
            end.
            delete buf_parts .
          end.
        end.
        delete object objMarks no-error.
        if v-need-unrv = true
        then do:
          release buf_parts no-error .
          if archive_parts.out-code <> v-unrv-code and v-unrv-sign = -1 and v-izlcstpr
          then do:
              find first buf_parts exclusive-lock
                where buf_parts.obj-type  = archive_parts.obj-type
                  and buf_parts.obj-code  = archive_parts.obj-code
                  and buf_parts.artic     = archive_parts.artic
                  and buf_parts.prod-type = archive_parts.prod-type
                  and buf_parts.prod-code = archive_parts.prod-code
                  and buf_parts.in-code   = archive_parts.out-code
                  and buf_parts.out-code  = v-unrv-code
                  and buf_parts.part-code = archive_parts.part-code
                no-error.
          end .
          if not available  buf_parts
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-unrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Необходимо резервировать" v-need-rsrv skip
                  "Резерв" v-rsrv-code skip
                  "Необходимо снятие резервов" v-need-unrv skip
                  "Снятие резервов" v-unrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
          end.
          if new(buf_parts)
          then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Ошибка при определении кода товара" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
              no-error .
            if not available buf_parts-attr
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Не найден атрибут партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            run factord-to-fact-num in this-procedure
              (input  buf_parts-attr.fact-order
              ,output v-fact-num
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Ошибка при определении порядкового номера партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnextdt in g#library
  (input  buf_parts-attr.ext-doc-type
  ,output v-doc-type
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info23 skip
                "Ошибка при определении типа документа" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.fact-date = buf_parts-attr.fact-date
              buf_parts.fact-num  = v-fact-num
              buf_parts.doc-type  = v-doc-type
            .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty  + v-unrv-sign * archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
          if buf_parts.out-code = 'free-zone':U
          then
          for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                      and buf_marking-lines.obj-type = archive_parts.obj-type
                                                      and buf_marking-lines.obj-code = archive_parts.obj-code
                                                      and buf_marking-lines.in-code  = archive_parts.in-code
                                                      and buf_marking-lines.out-code = archive_parts.out-code
                                                      and buf_marking-lines.part-code = archive_parts.part-code
                                                      and buf_marking-lines.prt-code = archive_parts.prt-code:
            for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
              find first free_marking-lines no-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                      and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                      and free_marking-lines.obj-type   = buf_parts.obj-type
                                                      and free_marking-lines.obj-code   = buf_parts.obj-code
                                                      and free_marking-lines.in-code    = buf_parts.in-code
                                                      and free_marking-lines.out-code   = buf_parts.out-code
                                                      and free_marking-lines.part-code  = buf_parts.part-code
                                                      and free_marking-lines.prt-code   = buf_parts.prt-code
                                                      no-error .
              if not available free_marking-lines
              then do :
                create free_marking-lines .
                assign
                  free_marking-lines.mark       = buf_marking-lines.mark
                  free_marking-lines.doc-level  = buf_marking-lines.doc-level
                  free_marking-lines.gds-code   = buf_marking-lines.gds-code
                  free_marking-lines.obj-type   = buf_parts.obj-type
                  free_marking-lines.obj-code   = buf_parts.obj-code
                  free_marking-lines.in-code    = buf_parts.in-code
                  free_marking-lines.out-code   = buf_parts.out-code
                  free_marking-lines.part-code  = buf_parts.part-code
                  free_marking-lines.prt-code   = buf_parts.prt-code
                .
              end .
              if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U and buf_trn-doc.doc-type <> 'спи':U and
                 not (buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U)
                then assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              if buf_trn-doc.ext-doc-type = 'es':U
              then do :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB .
              end .
              for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                assign buf_marking-chk.sts = 0 .
              end .
            end .
            delete buf_marking-lines .
          end.
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + v-unrv-sign * archive_parts.cli-qnty
            .
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info23 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            for each del_marking-lines exclusive-lock where del_marking-lines.gds-code = v-gds-code
                                                        and del_marking-lines.obj-type = buf_parts.obj-type
                                                        and del_marking-lines.obj-code = buf_parts.obj-code
                                                        and del_marking-lines.in-code = buf_parts.in-code
                                                        and del_marking-lines.out-code = buf_parts.out-code
                                                        and del_marking-lines.part-code = buf_parts.part-code
                                                        and del_marking-lines.prt-code = buf_parts.prt-code:
              delete del_marking-lines .
            end.
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
            for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                     and ub.gen-attr.p-key =  part-key-rec
            :
              find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
              find current buf1_gen-attr exclusive-lock.
              delete buf1_gen-attr .
            end.
            delete buf_parts .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure partcopy-rsrv-parts :
  define input  parameter p-doc-code-rowid as rowid no-undo .
  define input  parameter p-parts-rowid    as rowid no-undo .
  define input  parameter p-rsrv-direction as logical   no-undo .
  define input  parameter p-goods-twounit  as logical   no-undo .
  define input  parameter p-is-hold        as logical   no-undo .
  define variable vss-description as character no-undo init "partcopy-rsrv-parts-01: процедура обработки партий при удалении документа".
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer archive_parts for ub.parts .
  define buffer buf_parts   for ub.parts .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_marking   for ub.marking .
  define buffer buf_goods for ub.goods .
  define variable v-rsrv-code as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where rowid(buf_trn-doc) = p-doc-code-rowid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" string(p-doc-code-rowid) skip
        "Партия" string(p-parts-rowid) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find first archive_parts
      where rowid(archive_parts) = p-parts-rowid
      no-error .
    if not available archive_parts
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка задания входных параметров" skip
        "Не найдена партия" skip
        "Документ" string(p-doc-code-rowid) skip
        "Партия" string(p-parts-rowid) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  archive_parts.out-code <> archive_parts.in-code
    and archive_parts.qnty <> 0
    and (buf_trn-doc.doc-type = 'при':U and buf_trn-doc.internal = yes ) = false
    and (buf_trn-doc.doc-type = 'возврат':U and p-is-hold = true  ) = false
    then do:
      assign
        v-rsrv-code =
        ( if (lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (buf_trn-doc.doc-type = 'инв':U and archive_parts.qnty < 0)
      then 'free-zone':U
      else 'out-zone':U )
      .
      run partcopy in this-procedure
        (input  true
        ,input  v-rsrv-code
        ,buffer archive_parts
        ,buffer buf_parts
        ,input  "news"
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info23 skip
          "Ошибка при создании партии" skip
          "Документ" buf_trn-doc.doc-code skip
          "Объект" archive_parts.obj-type archive_parts.obj-code skip
          "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
          "Партия" archive_parts.in-code archive_parts.part-code skip
          "Количество" archive_parts.qnty skip
          "Резерв" v-rsrv-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        buf_parts.qnty      = buf_parts.qnty     - abs(archive_parts.qnty)
                                                  * (if p-rsrv-direction = true
                                                    then 1
                                                    else -1
                                                    )
        buf_parts.fact-qnty = buf_parts.qnty
      .
      find first buf_goods no-lock where buf_goods.artic = archive_parts.artic
                                     and buf_goods.prod-type = archive_parts.prod-type
                                     and buf_goods.prod-code = archive_parts.prod-code
                                     .
      for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                            and orig_marking-lines.obj-type   = archive_parts.obj-type
                                            and orig_marking-lines.obj-code   = archive_parts.obj-code
                                            and orig_marking-lines.in-code    = archive_parts.in-code
                                            and orig_marking-lines.out-code   = archive_parts.out-code
                                            and orig_marking-lines.part-code  = archive_parts.part-code
                                            and orig_marking-lines.prt-code   = archive_parts.prt-code
                                            :
        find first buf_marking-lines no-lock where  buf_marking-lines.mark       = orig_marking-lines.mark
                                                and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                and buf_marking-lines.in-code    = buf_parts.in-code
                                                and buf_marking-lines.out-code   = buf_parts.out-code
                                                and buf_marking-lines.part-code  = buf_parts.part-code
                                                and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                no-error .
        if available buf_marking-lines
        then do :
          find current buf_marking-lines exclusive-lock .
          delete buf_marking-lines .
          for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB .
          end .
        end .
        else do :
          create buf_marking-lines .
          assign
            buf_marking-lines.mark       = orig_marking-lines.mark
            buf_marking-lines.doc-level  = orig_marking-lines.doc-level
            buf_marking-lines.gds-code   = buf_goods.gds-code
            buf_marking-lines.obj-type   = buf_parts.obj-type
            buf_marking-lines.obj-code   = buf_parts.obj-code
            buf_marking-lines.in-code    = buf_parts.in-code
            buf_marking-lines.out-code   = buf_parts.out-code
            buf_marking-lines.part-code  = buf_parts.part-code
            buf_marking-lines.prt-code   = buf_parts.prt-code
          .
          if buf_parts.out-code <> buf_parts.in-code
          and buf_parts.out-code <> 'free-zone':U
          and buf_parts.out-code <> 'out-zone':U
          then do :
            find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code no-error .
            if available buf_trn-doc then buf_marking-lines.fact-order = buf_trn-doc.fact-order .
          end .
          for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB when buf_parts.out-code = 'free-zone':U
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB when buf_parts.out-code = 'out-zone':U
            .
          end .
        end .
        release buf_marking-lines no-error .
      end.
      if p-goods-twounit = true
      then do:
        assign
          buf_parts.cli-qnty = buf_parts.cli-qnty - abs(archive_parts.cli-qnty)
                                                  * (if p-rsrv-direction = true
                                                    then 1
                                                    else -1
                                                    )
        .
      end.
      if  buf_parts.qnty      = 0
      and buf_parts.fact-qnty = 0
      then do:
        if p-goods-twounit = true
        then do:
          if buf_parts.cli-qnty <> 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info23 skip
              "Ошибка при удалении партии" skip
              "Документ" buf_trn-doc.doc-code skip
              "Объект" buf_parts.obj-type buf_parts.obj-code skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "Партия" buf_parts.in-code buf_parts.part-code skip
              "Резерв" buf_parts.out-code skip
              "qnty" buf_parts.qnty skip
              "fact-qnty" buf_parts.fact-qnty skip
              "cli-qnty" buf_parts.cli-qnty skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
        delete buf_parts .
      end.
    end.
  end.
end procedure.
procedure partcopy-update-doc-line-tot-fact :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable vss-description as character no-undo init "partcopy-update-doc-line-tot-fact-01: процедура обновления средней учетной цены в строке документа".
    define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
  define buffer buf_doc-line for ub.doc-line .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line exclusive-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run partrqst in this-procedure
      (input buf_doc-line.doc-code
      ,input buf_doc-line.obj-type
      ,input buf_doc-line.obj-code
      ,input buf_doc-line.artic
      ,input buf_doc-line.prod-type
      ,input buf_doc-line.prod-code
            ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка при сборе информации по партиям" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-total-parts-fact-qnty <> 0
    then do:
      assign
        buf_doc-line.price-base      = v-total-parts-price-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.price-rubl      = v-total-parts-price-rubl
                                     / v-total-parts-fact-qnty
        buf_doc-line.transport-base  = v-total-parts-transport-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.transport-rubl  = v-total-parts-transport-rubl
                                     / v-total-parts-fact-qnty
        buf_doc-line.other-base      = v-total-parts-other-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.other-rubl      = v-total-parts-other-rubl
                                     / v-total-parts-fact-qnty
      .
    end.
    else do:
    end.
  end.
end procedure.
procedure partcopy-change-purch-code :
  define input parameter  p-in-code          like ub.parts.in-code no-undo .
  define input parameter  p-dest-purch-code  like ub.parts.purch-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf1_parts         for ub.parts .
  define parameter buffer buf2_parts         for ub.parts .
  define variable vss-description as character no-undo init "partcopy-change-purch-code01: процедура копирования партии при смене purch-code".
  define variable var-out-code  like ub.parts.out-code no-undo .
  define variable var-part-code like ub.parts.part-code no-undo .
  define buffer buf_goods        for ub.goods .
  define buffer buf_parts-root   for ub.parts-root.
  define buffer buf_trn-doc      for ub.trn-doc.
  define buffer buf-orig_trn-doc for ub.trn-doc.
  define buffer buf_units        for ub.units .
  do
  on error undo, return error return-value
  :
    if buf_orig_parts.out-code = p-in-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info23 skip
        "Ошибка задания входных параметров процедуры partcopy" skip
        "buf_orig_parts.out-code" buf_orig_parts.out-code skip
        "p-in-code" p-in-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-in-code
      .
    find first buf-orig_trn-doc where buf-orig_trn-doc.doc-code = buf_orig_parts.out-code.
    find first buf_goods no-lock
      where buf_goods.artic = buf_orig_parts.artic
        and buf_goods.prod-type = buf_orig_parts.prod-type
        and buf_goods.prod-code = buf_orig_parts.prod-code
      .
    find first buf_units where buf_units.unit-name = buf_goods.unit-base no-lock.
    find first buf1_parts exclusive-lock
      where buf1_parts.obj-type  = buf_orig_parts.obj-type
        and buf1_parts.obj-code  = buf_orig_parts.obj-code
        and buf1_parts.artic     = buf_orig_parts.artic
        and buf1_parts.prod-type = buf_orig_parts.prod-type
        and buf1_parts.prod-code = buf_orig_parts.prod-code
        and buf1_parts.in-code   = buf_orig_parts.in-code
        and buf1_parts.out-code  = p-in-code
        and buf1_parts.part-code = buf_orig_parts.part-code
      no-error.
    if not available buf1_parts
    then do:
      create buf1_parts .
      buffer-copy buf_orig_parts to buf1_parts
      assign
        buf1_parts.in-code    = buf_orig_parts.in-code
        buf1_parts.out-code   = p-in-code
        buf1_parts.status_    = no
        buf1_parts.qnty       = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.fact-qnty else - buf_orig_parts.fact-qnty )
        buf1_parts.fact-qnty  = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.fact-qnty else - buf_orig_parts.fact-qnty )
        buf1_parts.cli-qnty   = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.cli-qnty  else - buf_orig_parts.cli-qnty  )
        buf1_parts.purch-code = buf_orig_parts.purch-code
        buf1_parts.rsrv-free  = ?
        buf1_parts.status_    = yes
      .
      validate buf1_parts .
    end.
    if  lookup('сер':U, buf_units.type) > 0
    then do:
       var-part-code = buf_orig_parts.part-code.
    end.
    else do:
        run holdprts-get-part-code in this-procedure
          (input  p-in-code
          ,output var-part-code
          ) no-error .
        if error-status :error
        then dO:
          undo, return error return-value.
        end.
    end.
    find first buf2_parts exclusive-lock
      where buf2_parts.obj-type  = buf_orig_parts.obj-type
        and buf2_parts.obj-code  = buf_orig_parts.obj-code
        and buf2_parts.artic     = buf_orig_parts.artic
        and buf2_parts.prod-type = buf_orig_parts.prod-type
        and buf2_parts.prod-code = buf_orig_parts.prod-code
        and buf2_parts.in-code   = p-in-code
        and buf2_parts.out-code  = p-in-code
        and buf2_parts.part-code = var-part-code
      no-error.
    if not available buf2_parts
    then do:
      create buf2_parts .
      buffer-copy buf_orig_parts to buf2_parts
      assign
        buf2_parts.in-code   = p-in-code
        buf2_parts.out-code  = p-in-code
        buf2_parts.qnty      = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.fact-qnty else buf_orig_parts.fact-qnty )
        buf2_parts.fact-qnty = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.fact-qnty else buf_orig_parts.fact-qnty )
        buf2_parts.cli-qnty  = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.cli-qnty  else buf_orig_parts.cli-qnty  )
        buf2_parts.purch-code = p-dest-purch-code
        buf2_parts.part-code  = var-part-code
        buf2_parts.rsrv-free  = ?
        buf2_parts.status_    = yes
      .
      validate buf2_parts .
    end.
    assign
      buf_orig_parts.in-code    = p-in-code
      buf_orig_parts.part-code  = buf2_parts.part-code
      buf_orig_parts.purch-code = buf2_parts.purch-code
    .
    find first buf_parts-root
      where buf_parts-root.doc-code       = p-in-code
        and buf_parts-root.in-code        = p-in-code
        and buf_parts-root.gds-code       = buf_goods.gds-code
        and buf_parts-root.part-code      = buf2_parts.part-code
        and buf_parts-root.orig-in-code   = buf1_parts.in-code
        and buf_parts-root.orig-gds-code  = buf_goods.gds-code
        and buf_parts-root.orig-part-code = buf1_parts.part-code
      no-error .
    if not available buf_parts-root
    then do:
      create buf_parts-root.
      assign
      buf_parts-root.doc-code       = p-in-code
      buf_parts-root.in-code        = p-in-code
      buf_parts-root.gds-code       = buf_goods.gds-code
      buf_parts-root.part-code      = buf2_parts.part-code
      buf_parts-root.orig-in-code   = buf1_parts.in-code
      buf_parts-root.orig-gds-code  = buf_goods.gds-code
      buf_parts-root.orig-part-code = buf1_parts.part-code
      .
    end.
  end.
end procedure.
procedure addChildMarkingLines:
  define input parameter iMark as character no-undo.
  define input parameter iSts  as integer   no-undo.
  define parameter buffer buf_marking-lines  for ub.marking-lines.
  define parameter buffer buf_parts          for ub.parts.
  define parameter buffer orig_marking-lines for ub.marking-lines.
  define parameter buffer buf_orig_parts     for ub.parts.
  define parameter buffer buf_goods          for ub.goods.
  define buffer buf_marking-childs        for ub.marking.
  define buffer buf_marking-lines-childs  for ub.marking-lines.
  define buffer buf_marking-chk           for ub.marking-chk.
  define buffer buf_chk-doc               for ub.chk-doc.
  define buffer orig_marking-lines-childs for ub.marking-lines.
  for each buf_marking-childs exclusive-lock where
           buf_marking-childs.mark-parent = iMark :
      find first buf_marking-lines-childs no-lock where
                 buf_marking-lines-childs.mark       = buf_marking-childs.mark
             and buf_marking-lines-childs.gds-code   = buf_marking-lines.gds-code
             and buf_marking-lines-childs.obj-type   = buf_marking-lines.obj-type
             and buf_marking-lines-childs.obj-code   = buf_marking-lines.obj-code
             and buf_marking-lines-childs.in-code    = buf_marking-lines.in-code
             and buf_marking-lines-childs.out-code   = buf_marking-lines.out-code
             and buf_marking-lines-childs.part-code  = buf_marking-lines.part-code
             and buf_marking-lines-childs.prt-code   = buf_marking-lines.prt-code
      no-error .
      if not available buf_marking-lines-childs then
      do:
        create buf_marking-lines-childs .
        assign
          buf_marking-lines-childs.mark       = buf_marking-childs.mark
          buf_marking-lines-childs.gds-code   = buf_marking-lines.gds-code
          buf_marking-lines-childs.obj-type   = buf_marking-lines.obj-type
          buf_marking-lines-childs.obj-code   = buf_marking-lines.obj-code
          buf_marking-lines-childs.in-code    = buf_marking-lines.in-code
          buf_marking-lines-childs.out-code   = buf_marking-lines.out-code
          buf_marking-lines-childs.part-code  = buf_marking-lines.part-code
          buf_marking-lines-childs.prt-code   = buf_marking-lines.prt-code
          buf_marking-lines-childs.fact-order = buf_marking-lines.fact-order
          buf_marking-lines-childs.doc-level  = buf_marking-lines.doc-level + 1
        .
        validate buf_marking-childs.
      end .
      buf_marking-childs.sts = iSts .
      for each buf_marking-chk exclusive-lock where
               buf_marking-chk.mark begins buf_marking-childs.mark
      :
        for first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = buf_marking-chk.doc-code
              and buf_chk-doc.out-code = buf_parts.out-code
        :
          buf_marking-chk.sts = 0 .
          validate buf_marking-chk.
        end .
      end .
      if available orig_marking-lines
      then do :
        find first orig_marking-lines-childs exclusive-lock where
                   orig_marking-lines-childs.mark       = buf_marking-childs.mark
               and orig_marking-lines-childs.gds-code   = buf_goods.gds-code
               and orig_marking-lines-childs.obj-type   = buf_orig_parts.obj-type
               and orig_marking-lines-childs.obj-code   = buf_orig_parts.obj-code
               and orig_marking-lines-childs.in-code    = buf_orig_parts.in-code
               and orig_marking-lines-childs.out-code   = buf_orig_parts.out-code
               and orig_marking-lines-childs.part-code  = buf_orig_parts.part-code
               and orig_marking-lines-childs.prt-code   = buf_orig_parts.prt-code
        no-error .
        if available orig_marking-lines-childs then
          delete orig_marking-lines-childs .
      end.
      run addChildMarkingLines in this-procedure (
        buf_marking-childs.mark,
        iSts,
        buffer buf_marking-lines,
        buffer buf_parts,
        buffer orig_marking-lines,
        buffer buf_orig_parts,
        buffer buf_goods
      ).
  end .
end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
function stsMarkWhenDeleteGoods returns integer
    (input iDocCode as character,
     input iMark as character):
  define variable vValue as character no-undo.
  define variable vType as character no-undo.
  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_c-marking for ub.c-marking.
  if iDocCode <> ? then
  do:
      find first buf_trn-doc no-lock where
                 buf_trn-doc.doc-code = iDocCode no-error.
      if avail buf_trn-doc then
      do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'is-return':U ,
                       output vValue ,
                       output vType ) no-error .
         if buf_trn-doc.ext-doc-type = 'we':U or
            buf_trn-doc.ext-doc-type = 'ev':U or
            vValue = "yes" then
         do:
           find last buf_c-marking no-lock where
                     buf_c-marking.mark = iMark
                use-index pi-2 no-error.
           if avail buf_c-marking and
                   (buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB) then
             return buf_c-marking.sts .
         end.
      end.
  end.
  return objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
end function.
procedure partrsrv :
  define input parameter  p-chg-qnty      as decimal   no-undo .
  define input parameter  p-goods-serial  as logical   no-undo .
  define input parameter  p-goods-twounit as logical   no-undo .
  define input parameter  p-unreserv-only as logical   no-undo .
  define parameter buffer buf_orig_parts  for ub.parts .
  define parameter buffer buf_trn-doc     for ub.trn-doc .
  define output parameter p-real-chg-qnty as decimal   no-undo .
  define output parameter p-parts-recid   as recid     no-undo .
  define input  parameter p-mark          as character  no-undo .
  define variable vss-description as character no-undo init "$Workfile$ Резервирование и снятие резервов по одной партии".
  define buffer buf_parts  for ub.parts .
  define buffer rsrv-parts for ub.parts .
  define buffer unrsrv-parts for ub.parts .
  define buffer buf_parts-attr for ub.parts-attr .
  define buffer free_marking-lines for ub.marking-lines .
  define variable lok                as logical   no-undo .
  define variable v-sign-chg-qnty    as integer   no-undo .
  define variable v-sign-rsrv-qnty   as integer   no-undo .
  define variable v-rsrv-qnty        as decimal   no-undo .
  define variable v-orig-unrsrv-code as character no-undo .
  define variable v-new-rsrv-code    as character no-undo .
  define variable v-new-unrsrv-code  as character no-undo .
  define variable v-unrsrv-qnty      as decimal   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable part-key-rec      as character no-undo .
  define variable v-part-code-int   as integer no-undo .
  define variable v-old-part-code   as character no-undo .
  define variable v-part-gds-code   as integer   no-undo .
  do transaction
  on error undo, return error
  :
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_orig_parts.obj-type
          ,input buf_orig_parts.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
    assign
      p-parts-recid = ?
    .
    if p-chg-qnty = 0 then do:
      assign
        p-parts-recid = recid(buf_orig_parts)
      .
      return .
    end.
    assign
      v-sign-chg-qnty = 0
    .
    if p-chg-qnty < 0 then do:
      assign
        v-sign-chg-qnty = -1
      .
    end.
    if p-chg-qnty > 0 then do:
      assign
        v-sign-chg-qnty = 1
      .
    end.
    assign
      v-sign-rsrv-qnty = v-sign-chg-qnty
    .
    if lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 then do:
      assign
        v-sign-rsrv-qnty = - v-sign-chg-qnty
      .
    end.
    run partcopy in this-procedure
      (input  false
      ,input  buf_trn-doc.doc-code
      ,buffer buf_orig_parts
      ,buffer buf_parts
      ,input  p-mark
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании партии" skip
        "Объект" buf_orig_parts.obj-type buf_orig_parts.obj-code skip
        "Артикул" buf_orig_parts.artic buf_orig_parts.prod-type buf_orig_parts.prod-code skip
        "Партия" buf_orig_parts.in-code buf_orig_parts.part-code skip
        "Резерв" buf_trn-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_parts.in-code = buf_parts.out-code then do:
      assign
        v-rsrv-qnty = abs(p-chg-qnty)
      .
      if buf_trn-doc.doc-type <> 'инв':U then do:
        if buf_parts.qnty < 0
        or buf_parts.fact-qnty < 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Резервирование невозможно" skip
            "Партия зарезервированная за обычным документом имеет отрицательное количество" skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-sign-rsrv-qnty < 0 then do:
          assign
            v-rsrv-qnty = min(abs(buf_parts.qnty), v-rsrv-qnty)
          .
        end.
      end.
      assign
        buf_parts.qnty      = buf_parts.qnty      + v-rsrv-qnty * v-sign-rsrv-qnty
        buf_parts.fact-qnty = buf_parts.fact-qnty + v-rsrv-qnty * v-sign-rsrv-qnty
      .
      if p-goods-twounit = true
      then do:
        if buf_parts.qnty < 0 then do:
          message
            "Порожденная партия ювелирных изделий не может иметь отрицательное количество" skip
            "Количество" buf_parts.qnty skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_parts.qnty = 0 then do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
        if  buf_parts.qnty <> 0
        and buf_parts.cli-qnty <> 1
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Порожденная партия ювелирных изделий должна иметь определенное клиентское количество" skip
            "qnty" buf_parts.qnty skip
            "cli-qnty" buf_parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        if buf_parts.cli-base-rate <> 0
        then do:
          assign
            buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
          .
        end.
        else do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
      end.
      assign
        p-chg-qnty      = p-chg-qnty      - v-rsrv-qnty * v-sign-chg-qnty
        p-real-chg-qnty = p-real-chg-qnty + v-rsrv-qnty * v-sign-chg-qnty
      .
    end.
    else do:
      assign
        v-orig-unrsrv-code =
        ( if (lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (buf_trn-doc.doc-type = 'инв':U and buf_parts.qnty < 0)
      then 'free-zone':U
      else 'out-zone':U )
        v-new-rsrv-code    =  ( if p-chg-qnty > 0
                                then 'free-zone':U
                                else 'out-zone':U
                              )
        v-new-unrsrv-code  =  ( if p-chg-qnty > 0
                                then 'out-zone':U
                                else 'free-zone':U
                              )
      .
      if v-new-rsrv-code = v-orig-unrsrv-code then do:
        assign
          v-rsrv-qnty = min(abs(buf_parts.qnty), abs(p-chg-qnty) )
        .
        if v-izlcstpr and buf_parts.out-code <> v-new-rsrv-code and p-chg-qnty > 0
        then do :
            find first rsrv-parts exclusive-lock
                where rsrv-parts.obj-type  = buf_parts.obj-type
                  and rsrv-parts.obj-code  = buf_parts.obj-code
                  and rsrv-parts.artic     = buf_parts.artic
                  and rsrv-parts.prod-type = buf_parts.prod-type
                  and rsrv-parts.prod-code = buf_parts.prod-code
                  and rsrv-parts.in-code   = buf_parts.out-code
                  and rsrv-parts.out-code  = v-new-rsrv-code
                  and rsrv-parts.part-code = buf_parts.part-code
                no-error.
        end.
        if not available rsrv-parts
        then do :
            run partcopy in this-procedure
              (input  true
              ,input  v-new-rsrv-code
              ,buffer buf_parts
              ,buffer rsrv-parts
              ,input p-mark
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании партии" skip
                "Объект" buf_parts.obj-type buf_parts.obj-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "Резерв" v-new-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
        end.
        if not v-izlcstpr or (v-izlcstpr and p-chg-qnty > 0)
        then
        assign
          rsrv-parts.qnty      = rsrv-parts.qnty      + v-rsrv-qnty
          rsrv-parts.fact-qnty = rsrv-parts.fact-qnty + v-rsrv-qnty
        .
        if p-goods-twounit = true then do:
          assign
            rsrv-parts.cli-qnty = rsrv-parts.cli-qnty + abs(buf_parts.cli-qnty)
          .
        end.
        else do:
          if rsrv-parts.cli-base-rate <> 0
          then do:
            assign
              rsrv-parts.cli-qnty = rsrv-parts.fact-qnty / rsrv-parts.cli-base-rate
            .
          end.
          else do:
            assign
              rsrv-parts.cli-qnty = 0
            .
          end.
        end.
        assign
          buf_parts.qnty      = buf_parts.qnty      + v-rsrv-qnty * v-sign-rsrv-qnty
          buf_parts.fact-qnty = buf_parts.fact-qnty + v-rsrv-qnty * v-sign-rsrv-qnty
        .
        if p-goods-twounit = true then do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
        else do:
          if buf_parts.cli-base-rate <> 0
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
            .
          end.
          else do:
            assign
              buf_parts.cli-qnty = 0
            .
          end.
        end.
        assign
          p-chg-qnty      = p-chg-qnty      - v-rsrv-qnty * v-sign-chg-qnty
          p-real-chg-qnty = p-real-chg-qnty + v-rsrv-qnty * v-sign-chg-qnty
        .
      end.
      if p-chg-qnty <> 0
      and (
           (buf_trn-doc.doc-type = 'инв':U
           and p-unreserv-only = false
           )
          or v-new-unrsrv-code = v-orig-unrsrv-code
          )
      then do:
        if v-izlcstpr and buf_parts.out-code <> v-new-unrsrv-code and p-chg-qnty < 0
        then do :
            find first unrsrv-parts exclusive-lock
                where unrsrv-parts.obj-type  = buf_parts.obj-type
                  and unrsrv-parts.obj-code  = buf_parts.obj-code
                  and unrsrv-parts.artic     = buf_parts.artic
                  and unrsrv-parts.prod-type = buf_parts.prod-type
                  and unrsrv-parts.prod-code = buf_parts.prod-code
                  and unrsrv-parts.in-code   = buf_parts.in-code
                  and unrsrv-parts.out-code  = v-new-unrsrv-code
                  and unrsrv-parts.part-code = buf_parts.part-code
                no-error.
        end.
        if not available unrsrv-parts
        then do :
            run partcopy in this-procedure
              (input  true
              ,input  v-new-unrsrv-code
              ,buffer buf_parts
              ,buffer unrsrv-parts
              ,input  p-mark
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании партии" skip
                "Объект" buf_parts.obj-type buf_parts.obj-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "Резерв" v-new-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
        end.
        assign
          v-unrsrv-qnty = min( (if unrsrv-parts.qnty > 0
                                then unrsrv-parts.qnty
                                else 0
                                )
                          , abs(p-chg-qnty))
        .
        assign
          buf_parts.qnty      = buf_parts.qnty      + v-unrsrv-qnty * v-sign-rsrv-qnty
          buf_parts.fact-qnty = buf_parts.fact-qnty + v-unrsrv-qnty * v-sign-rsrv-qnty
        .
        if p-goods-twounit = true then do:
          assign
            buf_parts.cli-qnty = buf_parts.cli-qnty + unrsrv-parts.cli-qnty * v-sign-rsrv-qnty
          .
        end.
        else do:
          if buf_parts.cli-base-rate <> 0
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
            .
          end.
          else do:
            assign
              buf_parts.cli-qnty = 0
            .
          end.
        end.
        if num-entries(buf_parts.part-code, "_") = 2
        and buf_parts.qnty > 0
        and buf_parts.out-code <> 'free-zone':U
        and buf_parts.out-code <> 'out-zone':U
        and buf_trn-doc.ext-doc-type = 'vt':U
        then do :
          v-old-part-code = buf_parts.part-code .
          v-part-code-int = 0 .
          buf_parts.part-code = entry(2, buf_parts.part-code, "_") no-error .
          do while error-status:error :
            v-part-code-int = v-part-code-int + 1 .
            buf_parts.part-code = string(integer(entry(2, buf_parts.part-code, "_")) + v-part-code-int) no-error .
          end .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-part-gds-code
  )  .
          find first buf_parts-attr exclusive-lock where buf_parts-attr.in-code   = buf_parts.in-code
                                                     and buf_parts-attr.gds-code  = v-part-gds-code
                                                     and buf_parts-attr.part-code = buf_parts.part-code
                                                     no-error.
          if not available buf_parts-attr then do:
            find first ub.parts-attr no-lock where ub.parts-attr.in-code   = buf_parts.in-code
                                               and ub.parts-attr.gds-code  = v-part-gds-code
                                               and ub.parts-attr.part-code = v-old-part-code
                                               no-error.
            if available ub.parts-attr then do:
              create buf_parts-attr.
              buffer-copy ub.parts-attr to buf_parts-attr
              assign
                buf_parts-attr.part-code = buf_parts.part-code
              .
            end.
          end.
        end .
        if not v-izlcstpr or (v-izlcstpr and p-chg-qnty < 0)
        then
        assign
          unrsrv-parts.qnty      = unrsrv-parts.qnty      - v-unrsrv-qnty
          unrsrv-parts.fact-qnty = unrsrv-parts.fact-qnty - v-unrsrv-qnty
        .
        if p-goods-twounit = true
        then do:
          assign
            unrsrv-parts.cli-qnty = 0
          .
        end.
        else do:
          if unrsrv-parts.cli-base-rate <> 0
          then do:
            assign
              unrsrv-parts.cli-qnty = unrsrv-parts.fact-qnty / unrsrv-parts.cli-base-rate
            .
          end.
          else do:
            assign
              unrsrv-parts.cli-qnty = 0
            .
          end.
        end.
        assign
          p-chg-qnty      = p-chg-qnty      - v-unrsrv-qnty * v-sign-chg-qnty
          p-real-chg-qnty = p-real-chg-qnty + v-unrsrv-qnty * v-sign-chg-qnty
        .
      end.
    end.
    if available unrsrv-parts
    and unrsrv-parts.qnty      = 0
    and unrsrv-parts.fact-qnty = 0
    then do:
      if p-goods-twounit = true then do:
        if unrsrv-parts.cli-qnty <> 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении партии" skip
            "Объект" unrsrv-parts.obj-type unrsrv-parts.obj-code skip
            "Артикул" unrsrv-parts.artic unrsrv-parts.prod-type unrsrv-parts.prod-code skip
            "Партия" unrsrv-parts.in-code unrsrv-parts.part-code skip
            "Резерв" unrsrv-parts.out-code skip
            "qnty" unrsrv-parts.qnty skip
            "fact-qnty" unrsrv-parts.fact-qnty skip
            "cli-qnty" unrsrv-parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      define variable origpart-key-rec as character no-undo .
      define buffer buf_gen-attr for ub.gen-attr .
      define buffer buf1_gen-attr for ub.gen-attr .
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer unrsrv-parts:handle)
                                        ,output part-key-rec).
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output origpart-key-rec).
      if  v-new-rsrv-code <> 'out-zone':U then do:
        for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                            and ub.gen-attr.p-key =  part-key-rec :
          find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U
                                            and buf_gen-attr.p-key =  origpart-key-rec
                                            and buf_gen-attr.attr-code = ub.gen-attr.attr-code no-error .
        if not available (buf_gen-attr) then do:
            create buf_gen-attr .
            buffer-copy ub.gen-attr to buf_gen-attr
            assign
                buf_gen-attr.p-key = origpart-key-rec
            no-error .
        end.
          find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
          find current buf1_gen-attr exclusive-lock.
          delete buf1_gen-attr .
      end.
      end.
      define variable v-gds-code as integer   no-undo .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  unrsrv-parts.artic
  ,input  unrsrv-parts.prod-type
  ,input  unrsrv-parts.prod-code
  ,output v-gds-code
  ) no-error .
      for each ub.marking-lines where ub.marking-lines.gds-code = v-gds-code
        and ub.marking-lines.obj-type = unrsrv-parts.obj-type
        and ub.marking-lines.obj-code = unrsrv-parts.obj-code
        and ub.marking-lines.in-code = unrsrv-parts.in-code
        and ub.marking-lines.out-code = unrsrv-parts.out-code
        and ub.marking-lines.part-code = unrsrv-parts.part-code
        and ub.marking-lines.prt-code = unrsrv-parts.prt-code:
          delete ub.marking-lines.
      end.
      delete unrsrv-parts .
    end.
    else do:
      assign
        p-parts-recid = recid(unrsrv-parts)
      .
    end.
    if available rsrv-parts
    and rsrv-parts.qnty      = 0
    and rsrv-parts.fact-qnty = 0
    then do:
      if p-goods-twounit = true then do:
        if rsrv-parts.cli-qnty <> 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении партии" skip
            "Объект" rsrv-parts.obj-type rsrv-parts.obj-code skip
            "Артикул" rsrv-parts.artic rsrv-parts.prod-type rsrv-parts.prod-code skip
            "Партия" rsrv-parts.in-code rsrv-parts.part-code skip
            "Резерв" rsrv-parts.out-code skip
            "qnty" rsrv-parts.qnty skip
            "fact-qnty" rsrv-parts.fact-qnty skip
            "cli-qnty" rsrv-parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer rsrv-parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                            and ub.gen-attr.p-key =  part-key-rec :
            find first buf_gen-attr no-lock where recid (buf_gen-attr) = recid (ub.gen-attr).
            find current buf_gen-attr exclusive-lock.
            delete buf_gen-attr.
      end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  rsrv-parts.artic
  ,input  rsrv-parts.prod-type
  ,input  rsrv-parts.prod-code
  ,output v-gds-code
  ) no-error .
      for each ub.marking-lines where ub.marking-lines.gds-code = v-gds-code
        and ub.marking-lines.obj-type = rsrv-parts.obj-type
        and ub.marking-lines.obj-code = rsrv-parts.obj-code
        and ub.marking-lines.in-code = rsrv-parts.in-code
        and ub.marking-lines.out-code = rsrv-parts.out-code
        and ub.marking-lines.part-code = rsrv-parts.part-code
        and ub.marking-lines.prt-code = rsrv-parts.prt-code:
          delete ub.marking-lines.
      end.
      delete rsrv-parts .
    end.
    else do:
      assign
        p-parts-recid = recid(rsrv-parts)
      .
    end.
    if  buf_parts.qnty      = 0
    and buf_parts.fact-qnty = 0 then do:
      if p-goods-twounit = true then do:
        if buf_parts.cli-qnty <> 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении партии" skip
            "Объект" buf_parts.obj-type buf_parts.obj-code skip
            "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
            "Партия" buf_parts.in-code buf_parts.part-code skip
            "Резерв" buf_parts.out-code skip
            "qnty" buf_parts.qnty skip
            "fact-qnty" buf_parts.fact-qnty skip
            "cli-qnty" buf_parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      define variable part-key-rec_free as character no-undo .
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                            and ub.gen-attr.p-key =  part-key-rec :
        if (entry (8,part-key-rec,chr(3)) <> 'free-zone':U) and (entry (8,part-key-rec,chr(3)) <> entry (7,part-key-rec,chr(3))) then do:
        part-key-rec_free = part-key-rec .
        entry (8,part-key-rec_free,chr(3)) = 'free-zone':U .
        find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U
                    and buf_gen-attr.attr-code = ub.gen-attr.attr-code
                    and num-entries (buf_gen-attr.p-key, chr(3)) >= 8
                    and entry(8, buf_gen-attr.p-key, chr(3)) = 'free-zone':U
                    no-error .
                if not available (buf_gen-attr) then
                do:
                    create buf_gen-attr.
                    buffer-copy ub.gen-attr except ub.gen-attr.p-key to buf_gen-attr .
                    assign
                        buf_gen-attr.p-key = part-key-rec_free
                        .
                end.
        end.
        find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
        find current buf1_gen-attr exclusive-lock.
        delete buf1_gen-attr .
      end.
      release buf_gen-attr.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
      for each ub.marking-lines where ub.marking-lines.gds-code = v-gds-code
        and ub.marking-lines.obj-type = buf_parts.obj-type
        and ub.marking-lines.obj-code = buf_parts.obj-code
        and ub.marking-lines.in-code = buf_parts.in-code
        and ub.marking-lines.out-code = buf_parts.out-code
        and ub.marking-lines.part-code = buf_parts.part-code
        and ub.marking-lines.prt-code = buf_parts.prt-code:
          if chg-qnty < 0
          then do :
            for first ub.marking exclusive-lock where ub.marking.mark = ub.marking-lines.mark :
              find first free_marking-lines no-lock where free_marking-lines.mark       = ub.marking-lines.mark
                                                      and free_marking-lines.gds-code   = ub.marking-lines.gds-code
                                                      and free_marking-lines.obj-type   = ub.marking-lines.obj-type
                                                      and free_marking-lines.obj-code   = ub.marking-lines.obj-code
                                                      and free_marking-lines.in-code    = ub.marking-lines.in-code
                                                      and free_marking-lines.out-code   = 'free-zone':U
                                                      and free_marking-lines.part-code  = ub.marking-lines.part-code
                                                      and free_marking-lines.prt-code   = ub.marking-lines.prt-code
                                                      no-error .
              if not available free_marking-lines
              then do :
                create free_marking-lines .
                assign
                  free_marking-lines.mark       = ub.marking-lines.mark
                  free_marking-lines.doc-level  = ub.marking-lines.doc-level
                  free_marking-lines.gds-code   = ub.marking-lines.gds-code
                  free_marking-lines.obj-type   = ub.marking-lines.obj-type
                  free_marking-lines.obj-code   = ub.marking-lines.obj-code
                  free_marking-lines.in-code    = ub.marking-lines.in-code
                  free_marking-lines.out-code   = 'free-zone':U
                  free_marking-lines.part-code  = ub.marking-lines.part-code
                  free_marking-lines.prt-code   = ub.marking-lines.prt-code
                .
              end .
              ub.marking.sts = stsMarkWhenDeleteGoods(if avail buf_trn-doc then buf_trn-doc.doc-code else ?,
                                                      ub.marking-lines.mark).
            end .
          end .
          delete ub.marking-lines.
      end.
      delete buf_parts .
    end.
    else do:
      assign
        buf_parts.rsrv-free =
        ( (lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (buf_trn-doc.doc-type = 'инв':U and buf_parts.qnty < 0))
      .
      if  buf_trn-doc.doc-type <> 'инв':U
      and (buf_parts.qnty < 0
           or buf_parts.fact-qnty < 0
          )
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Партии с отрицательным количеством допустимы" skip
          "только для документа инвентаризации" skip
          "Объект" buf_parts.obj-type buf_parts.obj-code skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Партия" buf_parts.in-code buf_parts.part-code skip
          "Резерв" buf_trn-doc.doc-code skip
          "Количество по документу" buf_parts.qnty skip
          "Фактическое количество" buf_parts.fact-qnty skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        p-parts-recid = recid(buf_parts)
      .
    end.
  end.
end procedure.
procedure partrsrv-need-rsrv :
  define input  parameter p-parts-in-code   as character no-undo .
  define input  parameter p-parts-out-code  as character no-undo .
  define output parameter p-need-rsrv-parts as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-parts-out-code <> p-parts-in-code
    then do:
      assign
        p-need-rsrv-parts = true
      .
    end.
    else do:
      assign
        p-need-rsrv-parts = false
      .
    end.
  end.
end procedure.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-parts-part-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-alcohol-prod AS LOGICAL
  ) :
  define variable v-show-part-code as character no-undo .
  if (p-goods-alcohol-prod = false) and (buf_parts.part-code = '':u)
  then do:
    return '------':u .
  end.
  run partsfnc_get-parts-show-code in this-procedure
    (input  buf_parts.part-code
    ,input  buf_parts.mark-db-num
    ,input  buf_parts.mark-code
    ,input  buf_parts.alc-bottling-date
    ,input  p-goods-alcohol-prod
    ,output v-show-part-code
    ) .
  return v-show-part-code .
END FUNCTION.
procedure partsfnc_get-parts-show-code :
  define input  parameter p-part-code          as character no-undo .
  define input  parameter p-mark-db-num        as integer   no-undo .
  define input  parameter p-mark-code          as integer   no-undo .
  define input  parameter p-alc-bottling-date  as date      no-undo .
  define input  parameter p-goods-alcohol-prod as logical   no-undo .
  define output parameter p-show-code          as character no-undo .
  define variable v-alc-mark-name as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-show-code = '':u
    .
    if p-goods-alcohol-prod = true
    then do:
      run alc-lib_mark-name in this-procedure
        (input  p-mark-db-num
        ,input  p-mark-code
        ,output v-alc-mark-name
        ) .
      assign
        p-show-code = substitute('&1,&2':u
                                ,v-alc-mark-name
                                ,string(p-alc-bottling-date,'99/99/9999':u)
                                )
      .
    end.
    else do:
      assign
        p-show-code = p-part-code
      .
    end.
    return '':u .
  end.
end procedure.
FUNCTION get-parts-out-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR ub.parts ) :
  case buf_parts.out-code :
    when 'free-zone':U then do:
      return "свободно" .
    end.
    when 'out-zone':U then do:
      return "расход" .
    end.
    otherwise do:
      if buf_parts.doc-type = 'акт':U then do:
        return caps("ЦН") + " № " + buf_parts.out-code .
      end.
      else do:
        define variable v-ext-name       as character no-undo .
        define variable v-trn-doc-status as character no-undo .
        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if available buf_trn-doc then do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  buf_parts.out-code
  ,output v-ext-name
  )  .
          assign
            v-trn-doc-status = (if buf_trn-doc.status_ = 'факт':U then 'факт':U else "")
          .
        end.
        else do:
          assign
            v-ext-name       = caps(substring(buf_parts.doc-type, 1, 1))
            v-trn-doc-status = (if buf_parts.status_ = ? then 'факт':U else "")
          .
        end.
        return substitute("&1 № &2 &3"
           ,v-ext-name
           ,buf_parts.out-code
           ,v-trn-doc-status
           ) .
      end.
    end.
  end case .
  return "".
END FUNCTION.
FUNCTION get-parts-cli-qnty RETURNS DECIMAL
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-twounit AS LOGICAL
  ) :
  if p-goods-twounit then do:
    RETURN buf_parts.cli-qnty .
  end.
  else do:
    RETURN buf_parts.fact-qnty / buf_parts.cli-base-rate .
  end.
  RETURN ? .
END FUNCTION.
FUNCTION get-parts-cli-base-rate RETURNS DECIMAL
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-twounit AS LOGICAL
  ) :
  if p-goods-twounit then do:
    RETURN buf_parts.fact-qnty / buf_parts.cli-qnty .
  end.
  else do:
    RETURN buf_parts.cli-base-rate .
  end.
  RETURN ? .
END FUNCTION.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function chkleave returns logical
(input p-widget-enter as handle
,input p-button-list  as character
).
  if  valid-handle(p-widget-enter)
  and can-query(p-widget-enter, "name":u)
  and lookup(p-widget-enter :name, p-button-list) > 0
  then do:
    return false .
  end.
  return true .
end function.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
procedure check-contract-code :
define input  parameter parmode           as   character                     no-undo.
define input  parameter parhost-code      like ub.trn-doc.host-code          no-undo.
define input  parameter parcli-type       like ub.trn-doc.cli-type           no-undo.
define input  parameter parcli-code       like ub.trn-doc.cli-code           no-undo.
define input  parameter parframe-value    as   character                     no-undo.
define input  parameter parmenu-handle    as   handle                        no-undo.
define input  parameter parobj-date       as   date                          no-undo.
define input  parameter partype-contract  as   character                     no-undo .
define output parameter parcontract-code  like ub.contract.contract-code     no-undo.
define buffer bf_contract     for ub.contract.
define buffer bf-oth_contract for ub.contract.
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.
define variable varlog      as logical   no-undo.
define variable var-args    as char      no-undo.
define variable var-ext-doc-type as char     no-undo.
do on error undo, return error return-value :
var-args = parmode.
parmode = entry(1, parmode).
run cntrcode-get-arg-val(var-args, "doc-type", output var-ext-doc-type).
if partype-contract = "" or partype-contract = ? then
   partype-contract = 'при':U .
assign
  parcontract-code = 0
.
if parmode = "input":u
then do:
  if parframe-value = ""
  then do:
    assign
      parcontract-code = 0
    .
  end.
  else do:
    find first bf_contract no-lock
      where bf_contract.host-code         = parhost-code
        and bf_contract.cli-type          = parcli-type
        and bf_contract.cli-code          = parcli-code
        and bf_contract.contract-prn-code = parframe-value
      no-error.
    if available bf_contract
    then do:
      find first bf-oth_contract no-lock
        where bf-oth_contract.host-code          = parhost-code
          and bf-oth_contract.contract-prn-code  = parframe-value
          and bf-oth_contract.cli-type           = parcli-type
          and bf-oth_contract.cli-code           = parcli-code
          and rowid(bf_contract)                 <> rowid(bf-oth_contract)
        no-error .
      if available bf-oth_contract
      then do:
        message
          "На фирме " parhost-code skip
          "у контрагента" parcli-type parcli-code skip
          "имеются два контракта с номером" parframe-value skip
        view-as alert-box .
      end.
      else do:
        assign
          parcontract-code = bf_contract.contract-code
        .
      end.
    end.
  end.
end.
if parmode <> "input":u
or parcontract-code = 0
then do:
  run str/cont-all.w (input parmenu-handle,
                  input parhost-code,
                  input "b-sel",
                  input if var-ext-doc-type = 'ee':U then 'фирма':U else "firm-curr" ,
                  input parcli-type,
                  input parcli-code,
                  input ?,
                  input ?,
                  input "current":u,
                  input partype-contract,
                  input-output varrid-list ) no-error.
  if error-status:error then do:
    message "Ошибка при вызове справочника договоров." skip
            return-value                skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    return error.
  end.
  assign
    varrecid = integer(entry(1, varrid-list)).
  find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
  if available bf_contract then do:
    assign
      parcontract-code = bf_contract.contract-code.
  end.
end.
if parcontract-code <> 0
then do:
  if (bf_contract.status_ = 'зкр':U or
      (bf_contract.contract-date-end <> ? and bf_contract.contract-date-end < parobj-date)) then do:
    if lookup(var-ext-doc-type, 'ep,re,rs,ee') = 0
    then do:
        assign
          varlog = no.
        message "Договор с номером " bf_contract.contract-prn-code " закрыт." skip
        view-as alert-box.
        assign
          parcontract-code = 0
        .
    end.
  end.
  if bf_contract.contract-date-beg > parobj-date then do:
    assign
      varlog = no.
    message "Дата открытия договора " bf_contract.contract-date-beg " . Договор с номером " bf_contract.contract-prn-code " еще не открыт." skip
    view-as alert-box.
    assign
      parcontract-code = 0
    .
  end.
  if parcontract-code <> 0
  then do:
    if bf_contract.cli-type <> parcli-type
    or bf_contract.cli-code <> parcli-code
    then do:
       message "По договору " bf_contract.contract-code
               ( if bf_contract.doc-type =  'при':U
                 then " поставщиком является "
                 else " покупателем является " )
               bf_contract.cli-type " " bf_contract.cli-code " ." skip
               "По документу контрагент " parcli-type " " parcli-code " ." skip
       view-as alert-box error.
       assign
         parcontract-code = 0.
    end.
    if parcontract-code <> ? then do:
      if not ( bf_contract.doc-type =  'при':U or bf_contract.doc-type =  'рас':U ) then do:
        message "Контракт имеет недопустимый тип." view-as alert-box.
        assign
          parcontract-code = 0.
      end.
    end.
  end.
end.
end.
end procedure.
procedure cntrcode-get-arg-val:
    def input param p-args as char no-undo.
    def input param p-key as char no-undo.
    def output param p-val as char no-undo.
    def var i as int no-undo.
    def var nums as int no-undo.
    def var key-val as char no-undo.
    nums = num-entries(p-args).
    do i = 1 to nums:
        key-val = entry(i, p-args).
        if key-val begins (p-key + "=") then do:
            p-val = entry(2, key-val, "=").
            return.
        end.
    end.
    p-val = "".
end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure godendo-date-to-offset :
  define input  parameter p-today  as date      no-undo .
  define input  parameter p-date   as date      no-undo .
  define output parameter p-offset as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-date  = ?
    or p-today = ?
    then do:
      assign
        p-offset = ?
      .
    end.
    else do:
      assign
        p-offset = p-date - p-today + 1
      .
    end.
  end.
end procedure.
procedure godendo-offset-to-date :
  define input  parameter p-today  as date      no-undo .
  define input  parameter p-offset as integer   no-undo .
  define output parameter p-date   as date      no-undo .
  do
  on error undo, return error return-value
  :
    if p-today  = ?
    or p-offset = ?
    then do:
      assign
        p-date = ?
      .
    end.
    else do:
      assign
        p-date = p-offset + p-today - 1
      .
    end.
  end.
end procedure.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
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
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alc-lib_mark-name :
  define input  parameter p-mark-db-num   as integer   no-undo .
  define input  parameter p-mark-code     as integer   no-undo .
  define output parameter p-mark-name     as character no-undo .
  define buffer buf_ex-mark for ub.ex-mark .
  do
  on error undo, return error return-value
  :
    if p-mark-db-num = ?
    or p-mark-code   = ?
    then do:
      assign
        p-mark-name = '?':u
      .
      return .
    end.
    if  p-mark-db-num = 0
    and p-mark-code   = 0
    then do:
      assign
        p-mark-name = ""
      .
      return .
    end.
    find first buf_ex-mark no-lock
      where buf_ex-mark.db-num    = p-mark-db-num
        and buf_ex-mark.mark-code = p-mark-code
      no-error .
    if available buf_ex-mark
    then do:
      assign
        p-mark-name = substitute('&1':u
                                ,buf_ex-mark.mark-name
                                )
      .
    end.
  end.
end procedure.
procedure alc-lib_get-new-part-code :
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-prod-type      as character no-undo .
  define input  parameter p-prod-code      as integer   no-undo .
  define input  parameter p-artic          as character no-undo .
  define input  parameter p-doc-code       as character no-undo .
  define output parameter p-new-part-code  as character no-undo .
  define variable v-cur-part-code as integer no-undo.
  define variable v-max-part-code as integer no-undo.
  define variable i               as integer no-undo.
  define buffer bf_parts for ub.parts .
  do
  on error undo, return error return-value
  :
    assign
      v-max-part-code = 0
    .
    for each bf_parts no-lock
          where bf_parts.obj-type  = p-obj-type  and
                bf_parts.obj-code  = p-obj-code  and
                bf_parts.prod-type = p-prod-type and
                bf_parts.prod-code = p-prod-code and
                bf_parts.artic     = p-artic     and
                bf_parts.out-code  = p-doc-code
      :
      assign
        v-cur-part-code = integer(bf_parts.part-code)
        no-error.
      if error-status:error = no and v-cur-part-code > v-max-part-code then do:
        assign
          v-max-part-code = v-cur-part-code
        .
      end.
    end.
    assign
      p-new-part-code = string (v-max-part-code + 1)
    .
  end.
end procedure.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info48, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info48, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable v-enable-qnty          as character no-undo .
define variable v-curr-r-b             as character no-undo .
define variable v-display-price-cli    as logical   no-undo .
define variable v-enable-price-cli     as logical   no-undo .
define variable v-enable-cli-exch-code as logical   no-undo .
define variable v-enable-contract      as logical   no-undo .
define variable v-is-fin               as logical   no-undo .
define variable v-contract             as logical   no-undo .
define variable v-create-part              as logical   no-undo .
define variable v-goods-serial             as logical   no-undo .
define variable v-goods-twounit            as logical   no-undo .
define variable v-goods-petroleum          as logical   no-undo .
define variable v-alcohol-prod             as logical   no-undo .
define variable v-can-change-part-code     as logical   no-undo .
define variable v-can-change-supp          as logical   no-undo .
define variable v-new-parts-part-code      as character no-undo .
define variable v-same-currency            as logical   no-undo .
define variable v-fields-enabled           as logical   no-undo .
define variable v-undo-last                as logical   no-undo init false .
define variable v-price-cli                like ub.doc-line.price-rubl no-undo.
define variable v-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable v-price-road-tax           like ub.doc-line.price-rubl no-undo.
define variable v-price-other-exp          like ub.doc-line.price-rubl no-undo.
define variable v-price-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable v-price-without-abs        like ub.doc-line.price-rubl no-undo.
define variable v-price-slt                like ub.doc-line.price-rubl no-undo.
define variable v-price-no-slt             like ub.doc-line.price-rubl no-undo.
define variable v-price-vat                like ub.doc-line.price-rubl no-undo.
define variable v-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable v-price-rubl               like ub.doc-line.price-rubl no-undo.
define variable v-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable v-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable v-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable v-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable v-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable v-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable v-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable v-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable v-price-base               like ub.doc-line.price-base no-undo.
define variable v-price-road-tax-base      like ub.doc-line.price-base no-undo.
define variable v-price-other-exp-base     like ub.doc-line.price-base no-undo.
define variable v-price-transport-exp-base like ub.doc-line.price-base no-undo.
define variable v-price-without-abs-base   like ub.doc-line.price-base no-undo.
define variable v-price-slt-base           like ub.doc-line.price-base no-undo.
define variable v-price-no-slt-base        like ub.doc-line.price-base no-undo.
define variable v-price-vat-base           like ub.doc-line.price-base no-undo.
define variable v-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define variable v-supp-type                like x_parts.supp-type no-undo .
define variable v-supp-code                like x_parts.supp-code no-undo .
define variable v-modified-contract-code   as logical   no-undo .
define variable v-contract-code            like ub.contract.contract-code no-undo .
define variable v-modified-exch-code       as logical   no-undo .
define variable v-exch-code                like x_parts.exch-code no-undo .
define variable v-enable-price-rubl        as logical   no-undo .
define variable v-enable-price-base        as logical   no-undo .
define variable v-price-base-source        as character no-undo .
define variable v-alc-mark-db-num          as integer   no-undo .
define variable v-alc-mark-code            as integer   no-undo .
define variable v-alc-bottling-date        as date      no-undo .
define variable v-alc-ref-ab-path          as character no-undo .
define variable v-alc-quality-certif-path  as character no-undo .
define variable v-alc-certif-path          as character no-undo .
define variable v-alc-imp-type             as character no-undo.
define variable v-alc-imp-code             as integer   no-undo.
define variable v-parts-recid              as recid no-undo .
DEFINE BUTTON b-alc-attr
     LABEL "АлкАтр"
     SIZE 10 BY 1 TOOLTIP "Атрибуты алкогольной продукции".
DEFINE BUTTON b-choose-last-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-last-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".
DEFINE BUTTON b-edit-price
     LABEL "<->"
     SIZE 4.5 BY 1 TOOLTIP "Пересчет Сумм".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 9 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1.
DEFINE BUTTON b-next
     LABEL "&>>"
     SIZE 4.5 BY 1.
DEFINE BUTTON b-prev
     LABEL "&<<"
     SIZE 4.5 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 9 BY 1.
DEFINE BUTTON b-rest
     LABEL "Восс&тановить"
     SIZE 13 BY 1.
DEFINE BUTTON b-save
     LABEL "&Сохранить"
     SIZE 11 BY 1.
DEFINE BUTTON r-contract
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-supp"
     SIZE 3 BY .88 TOOLTIP "Список договоров по фирме".
DEFINE BUTTON r-exch-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-supp"
     SIZE 3 BY .88 TOOLTIP "Список валют".
DEFINE BUTTON r-supp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-supp"
     SIZE 3 BY .88 TOOLTIP "Список контрагентов".
DEFINE VARIABLE FI-b-code AS INTEGER FORMAT "999999999" INITIAL 0
     LABEL "Бар-код"
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI-clients-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-contract-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-contract-prn-code AS CHARACTER FORMAT "X(16)":U
     LABEL "Договор"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE fi-gds-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI-goods-artic AS CHARACTER FORMAT "X(40)":U
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 18.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI-goods-prod-type-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
      VIEW-AS TEXT
     SIZE 18.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI-label-cena AS CHARACTER FORMAT "X(256)":U INITIAL "Цена"
      VIEW-AS TEXT
     SIZE 29.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FI-label-ed-izm AS CHARACTER FORMAT "X(256)":U INITIAL "Ед. Изм."
      VIEW-AS TEXT
     SIZE 10.75 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FI-label-koefficient AS CHARACTER FORMAT "X(256)":U INITIAL "Коэффициент"
      VIEW-AS TEXT
     SIZE 12.75 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FI-label-kolichestvo AS CHARACTER FORMAT "X(256)":U INITIAL "Количество"
      VIEW-AS TEXT
     SIZE 17.25 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FI-label-summa AS CHARACTER FORMAT "X(256)":U INITIAL "Сумма"
      VIEW-AS TEXT
     SIZE 23.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FI-label-val AS CHARACTER FORMAT "X(256)":U INITIAL "Вал."
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE fi-last-date-offset AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE fi-out-code AS CHARACTER FORMAT "X(40)":U
     LABEL "Статус"
      VIEW-AS TEXT
     SIZE 41 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-slt-pc AS DECIMAL FORMAT ">>9.9999999999":U INITIAL 0
     LABEL "%"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 TOOLTIP "% НП"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-slt-type AS CHARACTER FORMAT "X(256)":U
     LABEL "НП"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-supp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 36.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-unit AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-unit-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-unit-cli AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-vat-pc AS DECIMAL FORMAT ">>9.9999999999":U INITIAL 0
     LABEL "%"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 TOOLTIP "% НДС"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-vat-type AS CHARACTER FORMAT "X(256)":U
     LABEL "НДС"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-price-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 22 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-price-cli AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 22 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-price-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 22 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE val-base-code AS INTEGER FORMAT ">>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE val-price-base AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 10.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE val-price-cli AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 10.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE val-price-rubl AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 10.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE val-rubl-code AS INTEGER FORMAT ">>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 88.75 BY 3.5.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 56.5 BY 4.58.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 88.88 BY 6.25.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 88.75 BY 4.67.
DEFINE QUERY Dialog-Frame FOR
      x_parts SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 10
     b-prev AT ROW 1 COL 19
     b-next AT ROW 1 COL 23.5
     b-save AT ROW 1 COL 28
     b-rest AT ROW 1 COL 39
     b-alc-attr AT ROW 1 COL 52.13
     b-help AT ROW 1 COL 87
     x_parts.PS AT ROW 5.92 COL 59 NO-LABEL
          VIEW-AS EDITOR
          SIZE 30.75 BY 4.17
     x_parts.cli-qnty AT ROW 6.92 COL 13.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     x_parts.cli-base-rate AT ROW 6.92 COL 41 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.5 BY 1
          FGCOLOR 4
     x_parts.qnty AT ROW 8 COL 13.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     x_parts.fact-qnty AT ROW 9.08 COL 13.25 COLON-ALIGNED HELP
          "Укажите фактическое количество товара в учетных единицах"
          LABEL "Факт"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     x_parts.part-code AT ROW 10.83 COL 13.5 COLON-ALIGNED FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     fi-vat-pc AT ROW 11 COL 65.5 COLON-ALIGNED
     x_parts.cst-code AT ROW 12 COL 13.5 COLON-ALIGNED
          FORMAT "x(31)"
          VIEW-AS FILL-IN
          SIZE 32 BY 1
     fi-slt-pc AT ROW 12.08 COL 65.5 COLON-ALIGNED
     x_parts.supp-type AT ROW 13.17 COL 13.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.25 BY 1
     x_parts.supp-code AT ROW 13.17 COL 23 COLON-ALIGNED NO-LABEL FORMAT "9999999999"
          VIEW-AS FILL-IN
          SIZE 13.5 BY 1
     r-supp AT ROW 13.25 COL 39.13
     x_parts.last-date AT ROW 14.38 COL 13.63 COLON-ALIGNED
          LABEL "Годен до"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     b-choose-last-date AT ROW 14.38 COL 27.13
     fi-last-date-offset AT ROW 14.38 COL 29 COLON-ALIGNED NO-LABEL
     fi-contract-prn-code AT ROW 15.67 COL 13.38 COLON-ALIGNED
     r-contract AT ROW 15.75 COL 33.5
     x_parts.price-cli AT ROW 18.5 COL 13.5 COLON-ALIGNED
          LABEL "По ТТН" FORMAT "->>,>>>,>>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 23.25 BY 1
     tot-price-cli AT ROW 18.5 COL 43 COLON-ALIGNED NO-LABEL
     x_parts.exch-code AT ROW 18.5 COL 66 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
          FGCOLOR 4
     r-exch-code AT ROW 18.5 COL 73
     x_parts.price-rubl AT ROW 19.58 COL 13.5 COLON-ALIGNED
          LABEL "Учет" FORMAT ">>,>>>,>>>,>>9.9999999999"
          VIEW-AS FILL-IN
          SIZE 23.25 BY 1
     tot-price-rubl AT ROW 19.58 COL 43 COLON-ALIGNED NO-LABEL
     b-edit-price AT ROW 20.25 COL 39.5
     x_parts.price-base AT ROW 20.71 COL 13.5 COLON-ALIGNED
          LABEL "Учет" FORMAT ">>,>>>,>>>,>>9.9999999999"
          VIEW-AS FILL-IN
          SIZE 23.25 BY 1
     tot-price-base AT ROW 20.71 COL 43 COLON-ALIGNED NO-LABEL
     FI-goods-artic AT ROW 2.42 COL 14.5 COLON-ALIGNED
     fi-gds-name AT ROW 2.42 COL 36.75 COLON-ALIGNED NO-LABEL
     FI-goods-prod-type-code AT ROW 3.5 COL 14.5 COLON-ALIGNED
     FI-clients-name AT ROW 3.5 COL 36.75 COLON-ALIGNED NO-LABEL
     FI-b-code AT ROW 4.67 COL 14.5 COLON-ALIGNED
     fi-out-code AT ROW 4.67 COL 45.5 COLON-ALIGNED
     FI-label-kolichestvo AT ROW 6.08 COL 13.25 COLON-ALIGNED NO-LABEL
     FI-label-ed-izm AT ROW 6.08 COL 30.5 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME Dialog-Frame
     FI-label-koefficient AT ROW 6.08 COL 41.25 COLON-ALIGNED NO-LABEL
     fi-unit-cli AT ROW 7.08 COL 30.63 COLON-ALIGNED NO-LABEL
     fi-unit AT ROW 8.21 COL 30.75 COLON-ALIGNED NO-LABEL
     fi-unit-2 AT ROW 9.29 COL 30.75 COLON-ALIGNED NO-LABEL
     fi-vat-type AT ROW 11.17 COL 54 COLON-ALIGNED
     fi-slt-type AT ROW 12.21 COL 54 COLON-ALIGNED
     fi-supp AT ROW 13.38 COL 40.88 COLON-ALIGNED NO-LABEL
     fi-contract-name AT ROW 15.83 COL 35.88 COLON-ALIGNED NO-LABEL
     FI-label-cena AT ROW 17.46 COL 13.5 COLON-ALIGNED NO-LABEL
     FI-label-summa AT ROW 17.46 COL 43 COLON-ALIGNED NO-LABEL
     FI-label-val AT ROW 17.46 COL 66.5 COLON-ALIGNED NO-LABEL
     val-price-cli AT ROW 18.63 COL 75.5 COLON-ALIGNED NO-LABEL
     val-rubl-code AT ROW 19.75 COL 66.25 COLON-ALIGNED NO-LABEL
     val-price-rubl AT ROW 19.75 COL 75.38 COLON-ALIGNED NO-LABEL
     val-base-code AT ROW 20.71 COL 66.25 COLON-ALIGNED NO-LABEL
     val-price-base AT ROW 20.96 COL 75.25 COLON-ALIGNED NO-LABEL
     RECT-2 AT ROW 5.83 COL 1
     RECT-3 AT ROW 10.58 COL 1
     RECT-4 AT ROW 17.21 COL 1.25
     RECT-1 AT ROW 2.17 COL 1
     SPACE(1.37) SKIP(16.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партия товара".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-prev:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       x_parts.PS:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON ESC OF FRAME Dialog-Frame
DO:
  assign
    v-undo-last = true
  .
  apply "go":u to self .
  return no-apply .
END.
ON GO OF FRAME Dialog-Frame
DO:
  define variable v-close-window as logical no-undo .
  if v-undo-last = true
  then do:
    return .
  end.
  run validate-qnty in this-procedure no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
  run update-record in this-procedure
    ( output v-close-window
    ) no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-alc-attr IN FRAME Dialog-Frame
DO:
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-save-flag           as logical   no-undo .
  if v-alcohol-prod = true then do:
    run str/in-alc.w
      (input        parparentproc
      ,input        'ИЗМЕНЕНИЕ':U
      ,input p-gds-code
      ,input-output v-alc-mark-db-num
      ,input-output v-alc-mark-code
      ,input-output v-alc-bottling-date
      ,input-output v-alc-ref-ab-path
      ,input-output v-alc-quality-certif-path
      ,input-output v-alc-certif-path
      ,input-output v-alc-imp-type
      ,input-output v-alc-imp-code
      ,output       v-save-flag
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':u
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры in-alc.w" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return no-apply .
    end.
    define variable v-display-part-code as character no-undo .
    run partsfnc_get-parts-show-code in this-procedure
      (input  v-new-parts-part-code
      ,input  v-alc-mark-db-num
      ,input  v-alc-mark-code
      ,input  v-alc-bottling-date
      ,input  v-alcohol-prod
      ,output v-display-part-code
      ) .
    assign
      x_parts.part-code :screen-value = string(v-display-part-code
                                            ,x_parts.part-code :format
                                            )
    .
      run trg/partps.p ( input p-gds-code
                       , input x_parts.in-code
                       , input x_parts.part-code
                       , input v-alc-mark-db-num
                       , input v-alc-mark-code
                       , input v-alc-bottling-date
                       , input v-alc-ref-ab-path
                       , input v-alc-quality-certif-path
                       , input v-alc-certif-path
                       , input v-alc-imp-type
                       , input v-alc-imp-code
                       ) no-error .
  end.
END.
ON CHOOSE OF b-edit-price IN FRAME Dialog-Frame
DO:
  define variable v-parts-price-base      as decimal   no-undo .
  define variable v-parts-price-rubl      as decimal   no-undo .
  define variable v-orig-parts-price-base as decimal   no-undo .
  define variable v-orig-parts-price-rubl as decimal   no-undo .
  define variable v-action                as character no-undo .
  define variable v-parts-chg-qnty        as decimal   no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods   for ub.goods .
  define buffer buf_clients for ub.clients .
  if v-can-change-supp = false
  then do:
    assign
      v-parts-price-base = decimal(x_parts.price-base :screen-value)
      v-parts-price-rubl = decimal(x_parts.price-rubl :screen-value)
    .
  end.
  else do:
    if v-enable-price-rubl = true
    then do:
      assign
        v-parts-price-rubl = decimal(x_parts.price-rubl :screen-value)
      .
    end.
    else do:
      if  v-enable-price-cli = true
      and v-exch-code        = 0
      then do:
        assign
          v-parts-price-rubl = decimal(x_parts.price-cli :screen-value)
        .
      end.
    end.
    if v-enable-price-base = true
    then do:
      assign
        v-parts-price-base = decimal(x_parts.price-base :screen-value)
      .
    end.
    else do:
      if  v-enable-price-cli = true
      and v-exch-code        = (input frame Dialog-Frame val-base-code)
      then do:
        assign
          v-parts-price-base = decimal(x_parts.price-cli :screen-value)
        .
      end.
    end.
  end.
  assign
    v-orig-parts-price-base = v-parts-price-base
    v-orig-parts-price-rubl = v-parts-price-rubl
  .
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  find first buf_clients no-lock
    where buf_clients.obj-type = x_parts.supp-type :screen-value
      and buf_clients.obj-code = integer(x_parts.supp-code :screen-value)
    no-error .
  if not available buf_clients
  then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = buf_trn-doc.obj-type
        and buf_clients.obj-code = buf_trn-doc.obj-code
      .
  end.
  assign
    v-parts-chg-qnty = decimal(x_parts.qnty :screen-value)
  .
  run trg/in-price.w
    (input parparentproc
    ,input-output v-parts-price-base
    ,input-output v-parts-price-rubl
    ,output v-action
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  buf_goods.artic
    ,input  buf_goods.prod-type
    ,input  buf_goods.prod-code
    ,input  buf_clients.obj-type
    ,input  buf_clients.obj-code
    ,input  buf_trn-doc.base-rate
    ,input  buf_trn-doc.base-scale
    ,input  v-parts-chg-qnty
    ) no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
  if v-parts-price-rubl  <> v-orig-parts-price-rubl
  then do:
    if v-enable-price-rubl = true
    then do:
      assign
        x_parts.price-rubl :screen-value = string(v-parts-price-rubl
                                                 ,x_parts.price-rubl :format
                                                )
      .
    end.
    else do:
      if  v-enable-price-cli = true
      and v-exch-code        = 0
      then do:
        assign
          x_parts.price-cli :screen-value = string(v-parts-price-rubl
                                                ,x_parts.price-cli :format
                                                )
        .
      end.
    end.
  end.
  if v-parts-price-base  <> v-orig-parts-price-base
  then do:
    if v-enable-price-base = true
    then do:
      assign
        x_parts.price-base :screen-value = string(v-parts-price-base
                                              ,x_parts.price-base :format
                                              )
      .
    end.
    else do:
      if  v-enable-price-cli = true
      and v-exch-code        = (input frame Dialog-Frame val-base-code)
      then do:
        assign
          x_parts.price-cli :screen-value = string(v-parts-price-base
                                                ,x_parts.price-cli :format
                                                )
        .
      end.
    end.
  end.
  run update-dependent-price in this-procedure .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run check-current-modified in this-procedure
    no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
  run reposition-parts in this-procedure
    (input 'next':U
    ).
END.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run check-current-modified in this-procedure
    no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
  run reposition-parts in this-procedure
    (input 'prev':U
    ).
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
define variable vss-include-info54 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    v-undo-last = true
  .
END.
ON CHOOSE OF b-rest IN FRAME Dialog-Frame
DO:
define variable vss-include-info55 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable lok               as logical no-undo init true .
  define variable v-record-modified as logical no-undo .
  run record-modified in this-procedure
    (output v-record-modified
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры record-modified" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
  if v-record-modified
  then do:
    message
      "Запись была изменена." skip
      "Вы действительно хотите восстановить первоначалное значение?" skip
      view-as alert-box question buttons yes-no update lok .
  end.
  if lok
  then do:
    run disable-fields in this-procedure .
    run display-fields in this-procedure .
    run enable-fields  in this-procedure .
  end.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-close-window as logical no-undo .
  run update-record in this-procedure
    (output v-close-window
    ) no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
  if v-close-window
  then do:
    run close-window .
    return .
  end.
  run disable-fields in this-procedure .
  run display-fields in this-procedure .
  run enable-fields  in this-procedure .
END.
ON LEAVE OF x_parts.cli-qnty IN FRAME Dialog-Frame
DO:
  run display-dependent-info in this-procedure .
END.
ON RETURN OF x_parts.cli-qnty IN FRAME Dialog-Frame
DO:
  if v-create-part
  then do:
    run apply-focus-next-entry in this-procedure
      (input x_parts.cli-qnty:handle
      ).
    return no-apply .
  end.
  else do:
    apply 'entry':u to b-exit .
    return no-apply .
  end.
END.
ON RETURN OF x_parts.cst-code IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input x_parts.cst-code:handle
    ).
  return no-apply .
END.
ON LEAVE OF x_parts.exch-code IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "r-exch-code,r-contract,b-quit,b-rest,b-help":u
    )
  then do:
    run validate-exch-code in this-procedure no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return no-apply .
    end.
  end.
END.
ON RETURN OF x_parts.exch-code IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input x_parts.exch-code:handle
    ).
  return no-apply .
END.
ON LEAVE OF x_parts.fact-qnty IN FRAME Dialog-Frame
DO:
  run display-dependent-info in this-procedure .
END.
ON RETURN OF x_parts.fact-qnty IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input x_parts.fact-qnty:handle
    ).
  return no-apply .
END.
ON LEAVE OF fi-contract-prn-code IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "r-contract,b-quit,b-rest,b-help":u
    )
  then do:
    if input frame Dialog-Frame fi-contract-prn-code <> fi-contract-prn-code
    then do:
      run validate-contract in this-procedure
        no-error .
      if error-status :error
      then do:
        message
          "Неправильный номер контракта" skip
          "" (input frame Dialog-Frame fi-contract-prn-code) skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
    end.
  end.
END.
ON RETURN OF fi-contract-prn-code IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input fi-contract-prn-code:handle
    ).
  return no-apply .
END.
ON LEAVE OF fi-last-date-offset IN FRAME Dialog-Frame
DO:
  define variable v-last-date as date      no-undo .
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .
  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .
  run godendo-offset-to-date in this-procedure
    (input  v-today
    ,input  (input frame Dialog-Frame fi-last-date-offset)
    ,output v-last-date
    ) .
  assign
    x_parts.last-date     :screen-value = string(v-last-date
                                              ,x_parts.last-date :format)
  .
END.
ON RETURN OF fi-last-date-offset IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input fi-last-date-offset:handle
    ).
  return no-apply .
END.
ON RETURN OF fi-slt-pc IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input fi-slt-pc:handle
    ).
  return no-apply .
END.
ON RETURN OF fi-vat-pc IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input fi-vat-pc:handle
    ).
  return no-apply .
END.
ON LEAVE OF x_parts.last-date IN FRAME Dialog-Frame
DO:
  run update-last-date-offset in this-procedure .
END.
ON RETURN OF x_parts.last-date IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input x_parts.last-date:handle
    ).
  return no-apply .
END.
ON LEAVE OF x_parts.part-code IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "b-quit,b-rest,b-help":u
    )
    and v-alcohol-prod <> true
  then do:
    define variable v-part-code like x_parts.part-code no-undo .
    assign
      v-part-code = input frame Dialog-Frame x_parts.part-code
    .
    run validate-part-code
      (input v-part-code
      ,input v-parts-recid
      ,input p-doc-code
      ,input p-gds-code
      ,input v-goods-serial
      ) no-error .
    if error-status :error
    then do:
      apply 'entry':u to x_parts.part-code .
      return no-apply .
    end.
    assign
      v-new-parts-part-code = v-part-code
    .
  end.
END.
ON RETURN OF x_parts.part-code IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input x_parts.part-code:handle
    ).
  return no-apply .
END.
ON LEAVE OF x_parts.price-base IN FRAME Dialog-Frame
DO:
  if v-same-currency
  then do:
    assign
      x_parts.price-rubl :screen-value = x_parts.price-base :screen-value
    .
  end.
  run display-dependent-info in this-procedure .
END.
ON RETURN OF x_parts.price-base IN FRAME Dialog-Frame
DO:
  define variable v-new-price-cli  like x_parts.price-cli  no-undo .
  define variable v-new-price-base like x_parts.price-rubl no-undo .
  define variable v-new-price-rubl like x_parts.price-rubl no-undo .
  if v-can-change-supp <> true
  then do:
    do with frame Dialog-Frame:
      run trg/prc-calc.p
        (input  "price-base":U
        ,input  p-doc-code
        ,input  p-gds-code
        ,input  decimal(x_parts.price-cli  :screen-value )
        ,input  decimal(x_parts.price-base :screen-value )
        ,input  decimal(x_parts.price-rubl :screen-value )
        ,output v-new-price-cli
        ,output v-new-price-base
        ,output v-new-price-rubl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове программы пересчета цены prc-calc.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return .
      end.
      run display-price in this-procedure
        (input v-new-price-cli
        ,input v-new-price-base
        ,input v-new-price-rubl
        ).
    end.
  end.
  run apply-focus-next-entry in this-procedure
    (input x_parts.price-base:handle
    ).
  return no-apply .
END.
ON LEAVE OF x_parts.price-cli IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "b-quit,b-rest,b-help":u
    )
  then do:
    define variable v-new-price-cli  like x_parts.price-cli  no-undo .
    define variable v-new-price-base like x_parts.price-rubl no-undo .
    define variable v-new-price-rubl like x_parts.price-rubl no-undo .
    if v-can-change-supp <> true
    then do:
      do with frame Dialog-Frame:
        run trg/prc-calc.p
          (input  "price-cli":U
          ,input  p-doc-code
          ,input  p-gds-code
          ,input  decimal(x_parts.price-cli  :screen-value )
          ,input  decimal(x_parts.price-base :screen-value )
          ,input  decimal(x_parts.price-rubl :screen-value )
          ,output v-new-price-cli
          ,output v-new-price-base
          ,output v-new-price-rubl
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове программы пересчета цены prc-calc.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return .
        end.
        run display-price in this-procedure
          (input v-new-price-cli
          ,input v-new-price-base
          ,input v-new-price-rubl
          ).
      end.
    end.
    else do:
      run update-dependent-price in this-procedure .
    end.
  end.
  run display-dependent-info in this-procedure .
END.
ON RETURN OF x_parts.price-cli IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input x_parts.price-cli:handle
    ).
  return no-apply .
END.
ON LEAVE OF x_parts.price-rubl IN FRAME Dialog-Frame
DO:
  if v-can-change-supp = true
  then do:
    run update-dependent-price in this-procedure .
  end.
  run display-dependent-info in this-procedure .
END.
ON RETURN OF x_parts.price-rubl IN FRAME Dialog-Frame
DO:
  define variable v-new-price-cli  like x_parts.price-cli  no-undo .
  define variable v-new-price-base like x_parts.price-rubl no-undo .
  define variable v-new-price-rubl like x_parts.price-rubl no-undo .
  if v-can-change-supp <> true
  then do:
    do with frame Dialog-Frame:
      run trg/prc-calc.p
        (input  "price-rubl":U
        ,input  p-doc-code
        ,input  p-gds-code
        ,input  decimal(x_parts.price-cli  :screen-value )
        ,input  decimal(x_parts.price-base :screen-value )
        ,input  decimal(x_parts.price-rubl :screen-value )
        ,output v-new-price-cli
        ,output v-new-price-base
        ,output v-new-price-rubl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове программы пересчета цены prc-calc.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return .
      end.
      run display-price in this-procedure
        (input v-new-price-cli
        ,input v-new-price-base
        ,input v-new-price-rubl
        ).
    end.
  end.
  run apply-focus-next-entry in this-procedure
    (input x_parts.price-rubl:handle
    ).
  return no-apply .
END.
ON RETURN OF x_parts.PS IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input x_parts.PS:handle
    ).
  return no-apply .
END.
ON LEAVE OF x_parts.qnty IN FRAME Dialog-Frame
DO:
  run display-dependent-info in this-procedure .
END.
ON RETURN OF x_parts.qnty IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input x_parts.qnty:handle
    ).
  return no-apply .
END.
ON CHOOSE OF r-contract IN FRAME Dialog-Frame
DO:
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run validate-supp in this-procedure
    (input (input frame Dialog-Frame x_parts.supp-type)
    ,input (input frame Dialog-Frame x_parts.supp-code)
    ) no-error .
  if error-status :error
  then do:
    message
      "Неправильно задан поставщик" skip
      "" (input frame Dialog-Frame x_parts.supp-type)
         (input frame Dialog-Frame x_parts.supp-code) skip
      view-as alert-box error .
    undo, return no-apply .
  end.
  run choose-contract in this-procedure
    (input (input frame Dialog-Frame x_parts.supp-type)
    ,input (input frame Dialog-Frame x_parts.supp-code)
    ).
END.
ON LEAVE OF r-contract IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "fi-contract-prn-code,r-contract,b-quit,b-rest,b-help":u
    )
  then do:
    if input frame Dialog-Frame fi-contract-prn-code <> fi-contract-prn-code
    then do:
      run validate-contract in this-procedure
        no-error .
      if error-status :error
      then do:
        message
          "Неправильный номер контракта" skip
          "" (input frame Dialog-Frame fi-contract-prn-code) skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
    end.
  end.
END.
ON CHOOSE OF r-exch-code IN FRAME Dialog-Frame
DO:
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run choose-exch-code in this-procedure
    (input (input frame Dialog-Frame x_parts.exch-code)
    ).
END.
ON LEAVE OF r-exch-code IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "exch-code,r-contract,b-quit,b-rest,b-help":u
    )
  then do:
    run validate-exch-code in this-procedure no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return no-apply .
    end.
  end.
END.
ON CHOOSE OF r-supp IN FRAME Dialog-Frame
DO:
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-select-supp-type as character no-undo .
  define variable v-select-supp-code as integer   no-undo .
  assign
    v-select-supp-type = input frame Dialog-Frame x_parts.supp-type
    v-select-supp-code = input frame Dialog-Frame x_parts.supp-code
  .
  run str/clisel.p
    (input parparentproc
    ,input-output v-select-supp-type
    ,input-output v-select-supp-code
    ) no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
  assign
    x_parts.supp-type :screen-value = string(v-select-supp-type
                                          , x_parts.supp-type :format )
    x_parts.supp-code :screen-value = string(v-select-supp-code
                                          , x_parts.supp-code :format )
  .
  run validate-supp in this-procedure
    (input (input frame Dialog-Frame x_parts.supp-type)
    ,input (input frame Dialog-Frame x_parts.supp-code)
    ) no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
END.
ON LEAVE OF r-supp IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "supp-type,supp-code,r-supp,b-quit,b-rest,b-help":u
    )
  then do:
    if  input frame Dialog-Frame x_parts.supp-code <> 0
    and input frame Dialog-Frame x_parts.supp-code <> ?
    then do:
      run validate-supp in this-procedure
        (input (input frame Dialog-Frame x_parts.supp-type)
        ,input (input frame Dialog-Frame x_parts.supp-code)
        ) no-error .
      if error-status :error
      then do:
        apply 'entry':u to x_parts.supp-code.
        return no-apply .
      end.
    end.
  end.
END.
ON LEAVE OF x_parts.supp-code IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "supp-type,supp-code,r-supp,b-quit,b-rest,b-help":u
    )
  then do:
    if  input frame Dialog-Frame x_parts.supp-code <> 0
    and input frame Dialog-Frame x_parts.supp-code <> ?
    then do:
      run validate-supp in this-procedure
        (input (input frame Dialog-Frame x_parts.supp-type)
        ,input (input frame Dialog-Frame x_parts.supp-code)
        ) no-error .
      if error-status :error
      then do:
        apply 'entry':u to x_parts.supp-code.
        return no-apply .
      end.
    end.
  end.
END.
ON RETURN OF x_parts.supp-code IN FRAME Dialog-Frame
DO:
  define variable v-seleck-ok as logical   no-undo .
  define variable v-obj-type like x_parts.obj-type no-undo .
  define variable v-obj-code like x_parts.obj-code no-undo .
  if input frame Dialog-Frame x_parts.supp-code = ?
  or input frame Dialog-Frame x_parts.supp-code = 0
  then do:
    run ref/selcli.p
      (input  parparentproc
      ,input  ?
      ,input  'все':U
      ,input no
      ,output v-seleck-ok
      ,output v-obj-type
      ,output v-obj-code
      ) .
    if v-seleck-ok = true
    then do:
      assign
        x_parts.supp-type :screen-value = string(v-obj-type)
        x_parts.supp-code :screen-value = string(v-obj-code)
      .
    end.
  end.
  run apply-focus-next-entry in this-procedure
    (input x_parts.supp-code:handle
    ).
  return no-apply .
END.
ON LEAVE OF x_parts.supp-type IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "supp-type,supp-code,r-supp,b-quit,b-rest,b-help":u
    )
  then do:
    if  input frame Dialog-Frame x_parts.supp-code <> 0
    and input frame Dialog-Frame x_parts.supp-code <> ?
    then do:
      run validate-supp in this-procedure
        (input (input frame Dialog-Frame x_parts.supp-type)
        ,input (input frame Dialog-Frame x_parts.supp-code)
        ) no-error .
      if error-status :error
      then do:
        apply 'entry':u to x_parts.supp-code .
        return no-apply .
      end.
    end.
  end.
END.
ON RETURN OF x_parts.supp-type IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input x_parts.supp-type:handle
    ).
  return no-apply .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of x_parts.last-date in frame Dialog-Frame
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
on delete-character of x_parts.last-date in frame Dialog-Frame
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
on ctrl-d of x_parts.last-date in frame Dialog-Frame
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
on ctrl-b of x_parts.last-date in frame Dialog-Frame
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
on ctrl-e of x_parts.last-date in frame Dialog-Frame
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
on ctrl-f of x_parts.last-date in frame Dialog-Frame
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
  define MENU m-ed-date63
    MENU-ITEM m-ed-date63-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date63-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date63-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date63-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if x_parts.last-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      x_parts.last-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date63 :HANDLE
      x_parts.last-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle63 as handle no-undo .
  assign
    v-label-handle63 = x_parts.last-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle63)
  then do:
    if v-label-handle63 :tooltip = ""
    or v-label-handle63 :tooltip = ?
    then do:
      assign
        v-label-handle63 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date63-1 in menu m-ed-date63 DO:
    apply "ctrl-b":U to x_parts.last-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date63-2 in menu m-ed-date63 DO:
    apply "ctrl-d":U to x_parts.last-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date63-3 in menu m-ed-date63 DO:
    apply "ctrl-e":U to x_parts.last-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date63-4 in menu m-ed-date63 DO:
    apply "ctrl-f":U to x_parts.last-date in frame Dialog-Frame .
  END.
on choose of b-choose-last-date in frame Dialog-Frame
do:
  run sel-date in this-procedure
    (input x_parts.last-date :handle
    ,input "Годен до &1 (для партии товара)"
    ) .
end.
MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run init-proc no-error .
  if error-status :error
  then do:
    undo MAIN-BLOCK, LEAVE MAIN-BLOCK .
  end.
END.
RUN disable_UI.
PROCEDURE apply-focus-next-entry :
  define input parameter p-widget-handle as handle no-undo .
  define variable v-apply-entry as logical no-undo .
  assign
    v-apply-entry = false
  .
  do with frame Dialog-Frame
  :
        if v-apply-entry   then do:     if x_parts.cli-qnty :sensitive     then do:       apply 'entry':u to x_parts.cli-qnty .       return .     end.   end.   if x_parts.cli-qnty :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.qnty :sensitive     then do:       apply 'entry':u to x_parts.qnty .       return .     end.   end.   if x_parts.qnty :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.fact-qnty :sensitive     then do:       apply 'entry':u to x_parts.fact-qnty .       return .     end.   end.   if x_parts.fact-qnty :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.part-code :sensitive     then do:       apply 'entry':u to x_parts.part-code .       return .     end.   end.   if x_parts.part-code :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.cst-code :sensitive     then do:       apply 'entry':u to x_parts.cst-code .       return .     end.   end.   if x_parts.cst-code :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.supp-type :sensitive     then do:       apply 'entry':u to x_parts.supp-type .       return .     end.   end.   if x_parts.supp-type :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.supp-code :sensitive     then do:       apply 'entry':u to x_parts.supp-code .       return .     end.   end.   if x_parts.supp-code :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.last-date :sensitive     then do:       apply 'entry':u to x_parts.last-date .       return .     end.   end.   if x_parts.last-date :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if fi-last-date-offset :sensitive     then do:       apply 'entry':u to fi-last-date-offset .       return .     end.   end.   if fi-last-date-offset :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if fi-contract-prn-code :sensitive     then do:       apply 'entry':u to fi-contract-prn-code .       return .     end.   end.   if fi-contract-prn-code :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.price-cli :sensitive     then do:       apply 'entry':u to x_parts.price-cli .       return .     end.   end.   if x_parts.price-cli :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.exch-code :sensitive     then do:       apply 'entry':u to x_parts.exch-code .       return .     end.   end.   if x_parts.exch-code :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.price-rubl :sensitive     then do:       apply 'entry':u to x_parts.price-rubl .       return .     end.   end.   if x_parts.price-rubl :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if x_parts.price-base :sensitive     then do:       apply 'entry':u to x_parts.price-base .       return .     end.   end.   if x_parts.price-base :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if fi-vat-pc :sensitive     then do:       apply 'entry':u to fi-vat-pc .       return .     end.   end.   if fi-vat-pc :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if fi-slt-pc :sensitive     then do:       apply 'entry':u to fi-slt-pc .       return .     end.   end.   if fi-slt-pc :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
        if v-apply-entry   then do:     if b-exit :sensitive     then do:       apply 'entry':u to b-exit .       return .     end.   end.   if b-exit :handle = p-widget-handle   then do:     assign       v-apply-entry = true     .   end.
    assign
      v-apply-entry = true
    .
    if v-apply-entry = true
    then do:
      apply 'entry':u to b-exit .
    end.
  end.
END PROCEDURE.
PROCEDURE check-current-modified :
  define variable lok as logical no-undo .
  define variable v-record-modified as logical no-undo .
  if v-fields-enabled
  then do:
    run record-modified in this-procedure
      (output v-record-modified
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры record-modified" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-record-modified = false
    then do:
      return .
    end.
    message
      "Партия была изменена." skip
      "ДА"     chr(9) "сохранить изменения и перейти к другой записи." skip
      "НЕТ"    chr(9) "не сохранять изменения и перейти к другой записи." skip
      "ОТМЕНА" chr(9) "не переходить к другой записи." skip
      view-as alert-box question button yes-no-cancel update lok .
    if lok = true
    then do:
      define variable v-close-window as logical no-undo .
      run update-record in this-procedure
        (output v-close-window
        ) no-error .
      if error-status :error
      then do:
        undo, return error .
      end.
      return .
    end.
    if lok = false
    then do:
      return .
    end.
    if lok = ?
    then do:
      undo, return error .
    end.
  end.
END PROCEDURE.
PROCEDURE choose-contract :
  define input  parameter v-supp-type as character no-undo .
  define input  parameter v-supp-code as integer   no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  define variable v-host-code as integer   no-undo .
  do
  transaction on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      .
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
    define buffer buf_contract for ub.contract .
    run check-contract-code in this-procedure
      (input  "choose":u
      ,input  v-host-code
      ,input  v-supp-type
      ,input  v-supp-code
      ,input  ?
      ,input  parparentproc
      ,input  buf_trn-doc.doc-date
      ,input  ""
      ,output v-contract-code
      ) no-error .
    if error-status :error
    or v-contract-code = ?
    or v-contract-code = 0
    then do:
      if return-value <> ""
      or error-status :get-message(1) <> ""
      then do:
        message
          "Ошибка при заведении номера договора." skip
          return-value skip
          error-status :get-message(1) skip
          view-as alert-box error.
      end.
      return error.
    end.
    assign
      v-modified-contract-code = true
    .
    find first buf_contract no-lock
      where buf_contract.host-code     = v-host-code
        and buf_contract.contract-code = v-contract-code
      .
    display
      buf_contract.contract-prn-code @ fi-contract-prn-code
      substitute("&1 Вн.н. &2"
                ,string(buf_contract.contract-date,'99/99/9999':u)
                ,v-contract-code) @ fi-contract-name
      with frame Dialog-Frame .
    assign
      fi-contract-prn-code
    .
    assign
      v-modified-exch-code = true
      v-exch-code          = buf_contract.curr-code
    .
    run update-exch-code-dependent in this-procedure .
    assign
      v-display-price-cli    = true
      v-enable-price-cli     = true
      v-enable-cli-exch-code = false
    .
    run update-enable-price-cli in this-procedure .
    run update-exch-code-enable in this-procedure .
  end.
END PROCEDURE.
PROCEDURE choose-exch-code :
  define input  parameter v-exch-code as integer   no-undo .
  define buffer buf_currency for ub.currency .
  define variable v-repos-recid as recid     no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_currency no-lock
      where buf_currency.curr-code = v-exch-code
      no-error .
    if available buf_currency
    then do:
      assign
        v-repos-recid = recid(buf_currency)
      .
    end.
    else do:
      assign
        v-repos-recid = ?
      .
    end.
    run ref/currency.w
      (input parparentproc
      ,input "b-sel"
      ,input-output v-repos-recid
      ).
    if v-repos-recid <> ?
    then do:
      find first buf_currency no-lock
        where recid( buf_currency ) = v-repos-recid
        no-error .
      if available buf_currency
      then do:
        do with frame Dialog-Frame
        :
          assign
            x_parts.exch-code :screen-value = string(buf_currency.curr-code
                                                  ,x_parts.exch-code :format
                                                  )
            val-price-cli   :screen-value = string(buf_currency.curr-abbr
                                                  ,val-price-cli  :format
                                                  )
          .
        end.
      end.
      run validate-exch-code in this-procedure no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return no-apply .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE clear-contract-value :
  define buffer buf_currency for ub.currency .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-modified-contract-code           = true
        v-contract-code                    = 0
        fi-contract-prn-code               = ""
        fi-contract-prn-code :screen-value = ""
        fi-contract-name     :screen-value = ""
        x_parts.price-cli      :screen-value = ""
        v-modified-exch-code               = true
        v-exch-code                        = 0
      .
      find first buf_currency no-lock
        where buf_currency.curr-code = v-exch-code
        no-error .
      if available buf_currency
      then do:
        assign
          x_parts.exch-code :screen-value = string(buf_currency.curr-code
                                                ,x_parts.exch-code :format
                                                )
          val-price-cli   :screen-value = string(buf_currency.curr-abbr
                                                ,val-price-cli  :format
                                                )
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE close-window :
  assign
    v-undo-last = true
  .
  apply "go":u to frame Dialog-Frame .
END PROCEDURE.
PROCEDURE determine-enable-qnty :
define output parameter p-enable-qnty  as character no-undo .
    assign
     p-enable-qnty = "cli-qnty":u
    .
END PROCEDURE.
PROCEDURE disable-fields :
  do with frame Dialog-Frame:
    assign
      x_parts.PS         :read-only = true
    .
    assign
      b-alc-attr :sensitive = false
      b-alc-attr :visible   = false
    .
    assign
      x_parts.part-code      :sensitive = false
      x_parts.cst-code       :sensitive = false
      x_parts.last-date      :sensitive = false
      b-choose-last-date   :sensitive = false
      fi-last-date-offset  :sensitive = false
      x_parts.price-cli      :sensitive = false
      x_parts.price-base     :sensitive = false
      x_parts.price-rubl     :sensitive = false
      b-edit-price         :sensitive = false
      fi-vat-pc            :sensitive = false
      fi-slt-pc            :sensitive = false
      x_parts.qnty           :sensitive = false
      x_parts.fact-qnty      :sensitive = false
      x_parts.cli-qnty       :sensitive = false
      x_parts.supp-type      :sensitive = false
      x_parts.supp-code      :sensitive = false
      r-supp               :sensitive = false
      fi-contract-prn-code :sensitive = false
      r-contract           :sensitive = false
      x_parts.exch-code      :sensitive = false
      r-exch-code          :sensitive = false
    .
    assign
      fi-vat-pc :fgcolor = ?
      fi-slt-pc :fgcolor = ?
    .
    assign
      b-exit :label in frame Dialog-Frame = "&Выход"
    .
    assign
      b-save               :sensitive = false
      b-quit               :sensitive = false
      b-rest               :sensitive = false
    .
    assign
      v-fields-enabled = false
    .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-dependent-info :
  define variable v-fact-qnty as decimal no-undo .
  do with frame Dialog-Frame:
    if v-goods-twounit = false
    then do:
      if x_parts.cli-qnty :sensitive
      then do:
        assign
          x_parts.fact-qnty :screen-value = string( decimal(x_parts.cli-qnty :screen-value)
                                                * decimal(x_parts.cli-base-rate :screen-value)
                                              , x_parts.fact-qnty :format )
          x_parts.qnty :screen-value = x_parts.fact-qnty :screen-value
        .
      end.
      if x_parts.qnty :sensitive
      then do:
        if x_parts.cli-qnty :visible = true
        then do:
          assign
            x_parts.cli-qnty :screen-value = string( decimal(x_parts.qnty :screen-value)
                                                  / decimal(x_parts.cli-base-rate :screen-value)
                                                , x_parts.cli-qnty :format )
          .
        end.
        if x_parts.fact-qnty :visible
        then do:
          assign
            x_parts.fact-qnty :screen-value = x_parts.qnty :screen-value
          .
        end.
      end.
    end.
    assign
      fi-label-summa :screen-value = string("Сумма " + x_parts.fact-qnty :label)
      tot-price-rubl :screen-value = string(decimal(x_parts.fact-qnty :screen-value)
                                            * decimal(x_parts.price-rubl :screen-value)
                                           , tot-price-cli :format )
      tot-price-base :screen-value = string(decimal(x_parts.fact-qnty :screen-value)
                                            * decimal(x_parts.price-base :screen-value)
                                           , tot-price-cli :format )
    .
    if tot-price-cli :visible
    then do:
      assign
        tot-price-cli  :screen-value = string(decimal(x_parts.cli-qnty :screen-value)
                                              * decimal(x_parts.price-cli :screen-value)
                                             , tot-price-cli :format )
      .
    end.
  end.
END PROCEDURE.
PROCEDURE display-fields :
  define variable v-frame-title as character no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  define variable v-base-code like ub.sysconf.base-code no-undo .
  define buffer buf_parts        for x_parts .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_goods        for ub.goods .
  define buffer buf_clients      for ub.clients .
  define buffer buf_currency     for ub.currency .
  define buffer buf_supp-clients for ub.clients .
  do with frame Dialog-Frame:
    define variable v-old-immediate-display as logical no-undo .
    assign
      v-old-immediate-display = session:immediate-display
    .
    if v-old-immediate-display = yes
    then do:
      assign
        session:immediate-display = no
      .
    end.
    assign
      x_parts.price-cli         :screen-value = ""
      x_parts.price-base        :screen-value = ""
      x_parts.price-rubl        :screen-value = ""
      x_parts.cli-qnty          :screen-value = ""
      x_parts.qnty              :screen-value = ""
      x_parts.fact-qnty         :screen-value = ""
      x_parts.cli-base-rate     :screen-value = ""
      x_parts.part-code         :screen-value = ""
      x_parts.cst-code          :screen-value = ""
      x_parts.last-date         :screen-value = ""
      fi-last-date-offset       :screen-value = ""
      x_parts.PS                :screen-value = ""
      fi-vat-type             :screen-value = ""
      fi-vat-pc               :screen-value = ""
      fi-slt-type             :screen-value = ""
      fi-slt-pc               :screen-value = ""
      fi-unit-cli             :screen-value = ""
      val-price-cli           :screen-value = ""
      val-price-base          :screen-value = ""
      val-base-code           :screen-value = ""
      val-price-rubl          :screen-value = ""
      val-rubl-code           :screen-value = ""
      FI-goods-artic          :screen-value = ""
      FI-goods-prod-type-code :screen-value = ""
      fi-gds-name             :screen-value = ""
      fi-unit                 :screen-value = ""
      fi-unit-2               :screen-value = ""
      fi-clients-name         :screen-value = ""
      FI-b-code               :screen-value = ""
    .
    assign
      v-supp-type                           = ""
      v-supp-code                           = ?
      x_parts.supp-type         :screen-value = ""
      x_parts.supp-code         :screen-value = ""
      v-contract-code                       = 0
      fi-contract-prn-code                  = ""
      fi-contract-prn-code    :screen-value = ""
      fi-contract-name        :screen-value = ""
      v-exch-code                           = 0
      v-alc-mark-db-num                     = 0
      v-alc-mark-code                       = 0
      v-alc-bottling-date                   = ?
      v-alc-ref-ab-path                     = ""
      v-alc-quality-certif-path             = ""
      v-alc-certif-path                     = ""
    .
    find first buf_currency no-lock
      where buf_currency.curr-code = v-exch-code
      no-error .
    if available buf_currency
    then do:
      assign
        x_parts.exch-code :screen-value = string(buf_currency.curr-code
                                              ,x_parts.exch-code :format
                                              )
        val-price-cli   :screen-value = string(buf_currency.curr-abbr
                                              ,val-price-cli  :format
                                              )
      .
    end.
    find first buf_goods no-lock where
               buf_goods.gds-code = p-gds-code no-error .
               if error-status :error then do:
                  return error return-value .
               end.
    find first buf_parts no-lock where
               buf_parts.artic = buf_goods.artic and
               buf_parts.prod-type = buf_goods.prod-type and
               buf_parts.prod-code = buf_goods.prod-code and
               buf_parts.in-code   = p-in-code and
               buf_parts.part-code = p-part-code and
               buf_parts.out-code  = p-out-code
      no-error .
    if available buf_parts
    then do:
      v-parts-recid = recid(buf_parts)  .
      define variable v-root-node   as integer no-undo .
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-root-node
  )  .
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_parts.obj-type
  ,input  buf_parts.obj-code
  ,output v-host-code
  )  .
      define variable v-b-code like ub.bar-code.b-code no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer buf_parts
  ,output v-b-code
  ) no-error .
      find first buf_clients no-lock
        where buf_clients.obj-type = buf_parts.prod-type
          and buf_clients.obj-code = buf_parts.prod-code
        no-error .
      define variable v-display-cli-info as logical no-undo .
      assign
        v-display-cli-info = (buf_parts.in-code = buf_parts.out-code
                              and buf_parts.is-supp
                             )
      .
      assign
        fi-unit-cli          :visible = v-display-cli-info
        val-price-cli        :visible = v-display-cli-info
        x_parts.cli-base-rate  :visible = v-display-cli-info
        x_parts.exch-code      :visible = v-display-cli-info
        r-exch-code          :visible = v-display-cli-info
        x_parts.price-cli      :visible = v-display-cli-info
        x_parts.cli-qnty       :visible = v-display-cli-info
        tot-price-cli        :visible = v-display-cli-info
        FI-label-koefficient :visible = v-display-cli-info
      .
      if v-display-cli-info
      then do:
        assign
          x_parts.price-cli     :screen-value = string(buf_parts.price-cli
                                                        ,x_parts.price-cli:format)
          x_parts.cli-qnty      :screen-value = string(buf_parts.cli-qnty
                                                        ,x_parts.cli-qnty:format)
        .
        find first buf_doc-line no-lock
          where buf_doc-line.doc-code  = buf_parts.out-code
            and buf_doc-line.artic     = buf_parts.artic
            and buf_doc-line.prod-type = buf_parts.prod-type
            and buf_doc-line.prod-code = buf_parts.prod-code
          no-error .
        if available buf_doc-line
        then do:
          assign
            fi-unit-cli         :screen-value = string(buf_doc-line.unit-cli
                                                          ,fi-unit-cli:format)
          .
        end.
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if available buf_trn-doc
        then do:
          assign
            v-frame-title = "Документ №  " + buf_trn-doc.doc-code
          .
        end.
      end.
      assign
        x_parts.price-base    :screen-value = string(buf_parts.price-base
                                                      ,x_parts.price-base :format)
        x_parts.price-rubl    :screen-value = string(buf_parts.price-rubl
                                                      ,x_parts.price-rubl :format)
        x_parts.qnty          :screen-value = string(buf_parts.qnty
                                                      ,x_parts.qnty :format)
        x_parts.fact-qnty     :screen-value = string(buf_parts.fact-qnty
                                                      ,x_parts.fact-qnty :format)
        x_parts.cli-base-rate :screen-value = string(buf_parts.cli-base-rate
                                                      ,x_parts.cli-base-rate :format)
        x_parts.cst-code      :screen-value = string(buf_parts.cst-code
                                                      ,x_parts.cst-code :format)
        x_parts.last-date     :screen-value = string(buf_parts.last-date
                                                      ,x_parts.last-date :format)
        fi-vat-type         :screen-value = string(buf_parts.vat-type
                                                      ,fi-vat-type :format)
        fi-vat-pc           :screen-value = string(buf_parts.VAT-pc
                                                      ,fi-vat-pc :format)
        fi-slt-type         :screen-value = string(buf_parts.slt-type
                                                      ,fi-slt-type :format)
        fi-slt-pc           :screen-value = string(buf_parts.SLT-pc
                                                      ,fi-slt-pc :format)
        x_parts.PS            :screen-value = string(buf_parts.PS )
        fi-out-code         :screen-value = (if buf_parts.out-code = 'free-zone':U
                                             then "свободно"
                                             else
                                               ( if buf_parts.out-code = 'out-zone':U
                                                 then "расход"
                                                 else "резерв"
                                               )
                                            )
        v-alc-mark-db-num                 = buf_parts.mark-db-num
        v-alc-mark-code                   = buf_parts.mark-code
        v-alc-bottling-date               = buf_parts.alc-bottling-date
        v-alc-ref-ab-path                 = buf_parts.alc-ref-ab-path
        v-alc-quality-certif-path         = buf_parts.alc-quality-certif-path
        v-alc-certif-path                 = buf_parts.alc-certif-path
      .
      define variable v-display-part-code as character no-undo .
      run partsfnc_get-parts-show-code in this-procedure
        (input  buf_parts.part-code
        ,input  buf_parts.mark-db-num
        ,input  buf_parts.mark-code
        ,input  buf_parts.alc-bottling-date
        ,input  v-alcohol-prod
        ,output v-display-part-code
        ) .
      assign
        x_parts.part-code :screen-value = string(v-display-part-code
                                              ,x_parts.part-code :format
                                              )
      .
      run update-last-date-offset in this-procedure .
      assign
        v-supp-type = buf_parts.supp-type
        v-supp-code = buf_parts.supp-code
      .
      assign
        x_parts.supp-type     :screen-value = string(v-supp-type
                                                      , x_parts.supp-type :format )
        x_parts.supp-code     :screen-value = string(v-supp-code
                                                      , x_parts.supp-code :format )
      .
      assign
        v-contract-code = buf_parts.contract-code
      .
      if v-contract-code <> 0
      then do:
        define buffer buf_contract for ub.contract .
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = v-contract-code
          no-error .
        if not available buf_contract
        then do:
          message
            "Не найден контракт" skip
            "Объект" buf_parts.obj-type buf_parts.obj-code skip
            "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
            "Партия" buf_parts.in-code buf_parts.part-code skip
            "Документ" buf_parts.out-code skip
            "Код фирмы" v-host-code skip
            "Код контракта" v-contract-code skip
            view-as alert-box error .
        end.
        else do:
          assign
            fi-contract-prn-code               = buf_contract.contract-prn-code
            fi-contract-prn-code :screen-value = string(buf_contract.contract-prn-code
                                                       , fi-contract-prn-code :format )
            fi-contract-name     :screen-value =
              substitute("&1 Вн.н. &2"
                        ,string(buf_contract.contract-date,'99/99/9999':u)
                        ,v-contract-code)
          .
        end.
      end.
      find buf_currency no-lock
        where buf_currency.curr-code = buf_parts.exch-code
        no-error .
      if available buf_currency
      then do:
        assign
          v-exch-code = buf_parts.exch-code
        .
        run update-exch-code-dependent in this-procedure .
      end.
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        .
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
        .
      find first buf_supp-clients no-lock
        where buf_supp-clients.obj-type = string(x_parts.supp-type :screen-value)
          and buf_supp-clients.obj-code = integer(x_parts.supp-code :screen-value)
        no-error .
      if available buf_supp-clients
      then do:
        assign
          fi-supp :screen-value = buf_supp-clients.obj-name
        .
      end.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении кода базовой валюты для фирмы" v-host-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      find first buf_currency no-lock
        where buf_currency.curr-code = v-base-code
        no-error .
      if available buf_currency
      then do:
        assign
          val-price-base :screen-value = buf_currency.curr-abbr
          val-base-code  :screen-value = string(buf_currency.curr-code
                                               ,val-base-code :format
                                               )
        .
      end.
      assign
        v-same-currency = (v-base-code = 0)
      .
      find first buf_currency no-lock
        where buf_currency.curr-code = 0
        .
      assign
        val-price-rubl :screen-value = buf_currency.curr-abbr
        val-rubl-code  :screen-value = string(buf_currency.curr-code
                                             ,val-rubl-code :format
                                             )
      .
      assign
        FI-goods-artic          :screen-value  = string(buf_parts.artic)
        FI-goods-prod-type-code :screen-value  = string(buf_parts.prod-type) + " "
                                               + string(buf_parts.prod-code)
      .
      if available buf_goods
      then do:
        assign
          fi-gds-name         :screen-value = buf_goods.gds-name
          fi-unit             :screen-value = string(buf_goods.unit-base
                                                        ,fi-unit:format)
          fi-unit-2           :screen-value = string(buf_goods.unit-base
                                                        ,fi-unit-2:format)
        .
      end.
      if available buf_clients
      then do:
        assign
          fi-clients-name :screen-value = buf_clients.obj-name
        .
      end.
      assign
        FI-b-code :screen-value = string(v-b-code, FI-b-code :format)
      .
    end.
    else do:
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        .
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        no-error .
      if available buf_doc-line
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_doc-line.doc-code
          .
        if available buf_trn-doc
        then do:
          assign
            v-frame-title = "Документ №  " + buf_trn-doc.doc-code
          .
        end.
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_doc-line.prod-type
            and buf_clients.obj-code = buf_doc-line.prod-code
          no-error .
        assign
          v-display-cli-info = true
        .
        assign
          fi-unit-cli          :visible = v-display-cli-info
          val-price-cli        :visible = v-display-cli-info
          x_parts.cli-base-rate  :visible = v-display-cli-info
          x_parts.exch-code      :visible = v-display-cli-info
          r-exch-code          :visible = v-display-cli-info
          x_parts.price-cli      :visible = v-display-cli-info
          x_parts.cli-qnty       :visible = v-display-cli-info
          tot-price-cli        :visible = v-display-cli-info
          FI-label-koefficient :visible = v-display-cli-info
        .
        if v-display-cli-info
        then do:
          assign
            x_parts.price-cli     :screen-value = string(buf_doc-line.price-cli
                                                          ,x_parts.price-cli:format)
            x_parts.cli-base-rate :screen-value = string(buf_doc-line.cli-base-rate
                                                          ,x_parts.cli-base-rate:format)
            fi-unit-cli         :screen-value = string(buf_doc-line.unit-cli
                                                          ,fi-unit-cli:format)
          .
          if v-is-fin = true
          then do:
            find first buf_contract no-lock
              where buf_contract.host-code     = buf_trn-doc.host-code
                and buf_contract.contract-code = buf_trn-doc.contract-code
              no-error .
            if available buf_contract
            then do:
              display
                buf_contract.contract-prn-code @ fi-contract-prn-code
                substitute("&1 Вн.н. &2"
                          ,string(buf_contract.contract-date,'99/99/9999':u)
                          ,buf_contract.contract-code) @ fi-contract-name
                with frame Dialog-Frame .
            end.
          end.
          if available buf_trn-doc
          then do:
            find buf_currency no-lock
              where buf_currency.curr-code = buf_trn-doc.exch-code
              no-error .
            if available buf_currency
            then do:
              assign
                v-exch-code = buf_trn-doc.exch-code
              .
              run update-exch-code-dependent in this-procedure .
            end.
          end.
        end.
        if v-alcohol-prod = true then do:
          run alc-lib_get-new-part-code in this-procedure
            (input  buf_trn-doc.obj-type
            ,input  buf_trn-doc.obj-code
            ,input  buf_doc-line.prod-type
            ,input  buf_doc-line.prod-code
            ,input  buf_doc-line.artic
            ,input  p-doc-code
            ,output v-new-parts-part-code
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры alc-lib_get-new-part-code" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
        assign
          x_parts.price-base    :screen-value = string(buf_doc-line.price-base
                                                        ,x_parts.price-base:format)
          x_parts.price-rubl    :screen-value = string(buf_doc-line.price-rubl
                                                        ,x_parts.price-rubl:format)
          x_parts.cst-code      :screen-value = string(buf_trn-doc.cst-code
                                                        ,x_parts.cst-code:format)
          x_parts.last-date     :screen-value = string(?
                                                        ,x_parts.cst-code:format)
          x_parts.supp-type     :screen-value = string(
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
                                                        , x_parts.supp-type :format )
          x_parts.supp-code     :screen-value = string(
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
                                                        , x_parts.supp-code :format )
          fi-out-code         :screen-value = "резерв"
        .
        define variable v-vat-type  as character no-undo .
        define variable v-vat-pc    as decimal   no-undo .
        define variable v-slt-type  as character no-undo .
        define variable v-slt-pc    as decimal   no-undo .
        run partscr_get-default-values in this-procedure
          (buffer buf_doc-line
          ,output v-vat-type
          ,output v-vat-pc
          ,output v-slt-type
          ,output v-slt-pc
          ) .
        assign
          fi-vat-type :screen-value = string(v-vat-type
                                            ,fi-vat-type :format )
          fi-vat-pc   :screen-value = string(v-vat-pc
                                            ,fi-vat-pc :format)
          fi-slt-type :screen-value = string(v-slt-type
                                            ,fi-slt-type :format)
          fi-slt-pc   :screen-value = string(v-slt-pc
                                            ,fi-slt-pc :format)
        .
        run update-last-date-offset in this-procedure .
        find first buf_supp-clients no-lock
          where buf_supp-clients.obj-type = string (x_parts.supp-type :screen-value)
            and buf_supp-clients.obj-code = integer(x_parts.supp-code :screen-value)
          no-error .
        if available buf_supp-clients
        then do:
          assign
            fi-supp :screen-value = buf_supp-clients.obj-name
          .
        end.
        if v-goods-serial = true
        then do:
          if buf_trn-doc.flag_ = no
          then do:
            if buf_doc-line.cli-base-rate <> 1
            then do:
              message
                "Коэффициент пересчета для серийных товаров должен быть 1"
                view-as alert-box error .
              undo, return error .
            end.
            assign
              x_parts.cli-qnty  :screen-value = '1'
              x_parts.qnty      :screen-value = '1'
              x_parts.fact-qnty :screen-value = '1'
            .
          end.
        end.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении кода базовой валюты для фирмы" v-host-code skip
            view-as alert-box error .
        end.
        find first buf_currency no-lock
          where buf_currency.curr-code = v-base-code
          no-error .
        if available buf_currency
        then do:
          assign
            val-price-base :screen-value = buf_currency.curr-abbr
            val-base-code  :screen-value = string(buf_currency.curr-code
                                                ,val-base-code :format
                                                )
          .
        end.
        find first buf_currency no-lock
          where buf_currency.curr-code = 0
          .
        assign
          val-price-rubl :screen-value = buf_currency.curr-abbr
          val-rubl-code  :screen-value = string(buf_currency.curr-code
                                              ,val-rubl-code :format
                                              )
        .
        assign
          v-same-currency = (v-base-code = 0)
        .
        assign
          FI-goods-artic          :screen-value  = string(buf_doc-line.artic)
          FI-goods-prod-type-code :screen-value  = string(buf_doc-line.prod-type)
                                                 + " "
                                                 + string(buf_doc-line.prod-code)
        .
        if available buf_goods
        then do:
          assign
            fi-gds-name         :screen-value = buf_goods.gds-name
            fi-unit             :screen-value = string(buf_goods.unit-base
                                                          ,fi-unit:format)
            fi-unit-2           :screen-value = string(buf_goods.unit-base
                                                          ,fi-unit-2:format)
          .
        end.
        if available buf_clients
        then do:
          assign
            fi-clients-name :screen-value = buf_clients.obj-name
          .
        end.
      end.
    end.
    run display-dependent-info in this-procedure .
    assign
      session:immediate-display = v-old-immediate-display
    .
  end.
END PROCEDURE.
PROCEDURE display-price :
  define input parameter v-new-price-cli  like x_parts.price-cli  no-undo .
  define input parameter v-new-price-base like x_parts.price-rubl no-undo .
  define input parameter v-new-price-rubl like x_parts.price-rubl no-undo .
  do with frame Dialog-Frame:
    if x_parts.price-cli :visible
    then do:
      if string(decimal(x_parts.price-cli :screen-value)
               ,x_parts.price-cli :format )
      <> string(v-new-price-cli
               ,x_parts.price-cli :format )
      then do:
        assign
          x_parts.price-cli :screen-value = string(v-new-price-cli
                                                ,x_parts.price-cli :format )
        .
      end.
    end.
    if x_parts.price-base :visible
    then do:
      if string(decimal(x_parts.price-base :screen-value)
               ,x_parts.price-base :format )
      <> string(v-new-price-base
               ,x_parts.price-base :format )
      then do:
        assign
          x_parts.price-base :screen-value = string(v-new-price-base
                                                ,x_parts.price-base :format )
        .
      end.
    end.
    if x_parts.price-rubl :visible
    then do:
      if string(decimal(x_parts.price-rubl :screen-value)
               ,x_parts.price-rubl :format )
      <> string(v-new-price-rubl
               ,x_parts.price-rubl :format )
      then do:
        assign
          x_parts.price-rubl :screen-value = string(v-new-price-rubl
                                                ,x_parts.price-rubl :format )
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE enable-fields :
  define buffer buf_parts    for x_parts .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_goods    for ub.goods .
  do with frame Dialog-Frame:
      assign
        v-fields-enabled = true
      .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        .
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        .
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        .
      find first buf_parts no-lock
        where recid(buf_parts) = v-parts-recid
        no-error .
      assign
        x_parts.PS :read-only = false
      .
      define variable l-external-income as logical no-undo .
      assign
        l-external-income = true
      .
      if  l-external-income = true
      and v-goods-petroleum = true
      then do:
        message
          "Во внешнем приходе топливо нельзя редактировать через партии" skip
          view-as alert-box information .
        undo, return error .
      end.
      assign
        v-can-change-part-code = false
      .
      run determine-enable-qnty in this-procedure
        (output v-enable-qnty
        ).
      assign
        v-can-change-supp = false
      .
      define variable v-can-change-price as logical no-undo .
      assign
        v-can-change-price = true
      .
        define variable confvalue     as character initial ? no-undo.
        define variable conftype      as character initial ? no-undo.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
        for each thbjattr_thbj-attr :
            if thbjattr_thbj-attr.prop-code = 'part-prc' then v-can-change-price = thbjattr_thbj-attr.property-value-logical  .
        end.
      v-can-change-part-code = true .
      assign
        x_parts.part-code     :sensitive =  false
      .
      if v-alcohol-prod = true
      then do:
        assign
          b-alc-attr :visible   = true
          b-alc-attr :sensitive = true
        .
      end.
      assign
        x_parts.cst-code    :sensitive = v-can-change-part-code
        x_parts.last-date   :sensitive = v-can-change-part-code
        b-choose-last-date  :sensitive = v-can-change-part-code
        fi-last-date-offset :sensitive = v-can-change-part-code
        x_parts.price-cli  :sensitive = (v-can-change-part-code
                                      and x_parts.price-cli :visible
                                      and v-can-change-price
                                      and l-external-income )
        x_parts.price-base :sensitive = (v-can-change-part-code
                                      and v-can-change-price )
        x_parts.price-rubl :sensitive = (v-can-change-part-code
                                      and v-can-change-price
                                       )
        b-edit-price     :sensitive =
                                      false
        x_parts.qnty       :sensitive = ( (v-enable-qnty = "qnty":u)     and not (v-goods-serial and v-create-part)
                                      )
                                      or ( (v-goods-twounit = true)
                                          and (v-enable-qnty = "cli-qnty":u )
                                        )
        x_parts.fact-qnty  :sensitive = (v-enable-qnty = "fact-qnty":u)
        x_parts.cli-qnty   :sensitive = (v-enable-qnty = "cli-qnty":u) and not (v-goods-serial and v-create-part)
        fi-slt-pc        :sensitive = (v-can-change-part-code
                                      and v-can-change-price
                                      )
        fi-vat-pc        :sensitive = (v-can-change-part-code
                                      and v-can-change-price
                                      )
      .
      if fi-slt-pc :sensitive = true
      then do:
        assign
          fi-slt-pc :fgcolor = ?
        .
      end.
      else do:
        assign
          fi-slt-pc :fgcolor = 4
        .
      end.
      if fi-vat-pc :sensitive = true
      then do:
        assign
          fi-vat-pc :fgcolor = ?
        .
      end.
      else do:
        assign
          fi-vat-pc :fgcolor = 4
        .
      end.
      if v-create-part
      then do:
        define variable v-new-qnty as decimal no-undo .
        run guess-parts-qnty in this-procedure
          (buffer buf_doc-line
          ,output v-new-qnty
          ).
        if x_parts.qnty :sensitive
        then do:
          assign
            x_parts.qnty  :screen-value = string(v-new-qnty
                                              ,x_parts.qnty :format )
          .
        end.
        if x_parts.fact-qnty :sensitive
        then do:
          assign
            x_parts.fact-qnty :screen-value = string(v-new-qnty
                                                  ,x_parts.fact-qnty :format )
          .
        end.
        if x_parts.cli-qnty :sensitive
        then do:
          assign
            x_parts.cli-qnty  :screen-value = string(v-new-qnty
                                                  ,x_parts.cli-qnty :format )
          .
        end.
        run display-dependent-info in this-procedure .
      end.
      if v-can-change-supp
      then do:
        assign
          x_parts.supp-type :sensitive = true
          x_parts.supp-code :sensitive = true
          r-supp :sensitive          = true
        .
        if v-create-part
        then do:
          if x_parts.supp-type :sensitive
          then do:
            assign
              x_parts.supp-type :screen-value = 'орг':U
            .
          end.
          if x_parts.supp-code :sensitive
          then do:
            assign
              x_parts.supp-code :screen-value = ?
            .
          end.
        end.
      end.
      define variable v-is-hold as logical   no-undo .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
      if v-can-change-supp = true
      then do:
        if available buf_parts
        then do:
          define variable v-create-old-return as logical no-undo .
          define variable v-reason as character no-undo .
          run partscr_check-valid-supp in this-procedure
            (input  buf_parts.supp-type
            ,input  buf_parts.supp-code
            ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
            ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
            ,input  buf_trn-doc.ext-doc-type
            ,output v-create-old-return
            ,output v-reason
            ).
          if v-create-old-return = true
          then do:
            assign
              v-display-price-cli    = true
              v-enable-price-cli     = true
            .
            if  v-is-fin = true
            then do:
              assign
                v-enable-contract      = true
              .
              if buf_parts.contract-code <> 0
              then do:
                assign
                  v-enable-cli-exch-code = false
                .
              end.
              else do:
                assign
                  v-enable-cli-exch-code = true
                .
              end.
            end.
            else do:
              assign
                v-enable-cli-exch-code = true
                v-enable-contract      = false
              .
            end.
          end.
          else do:
            assign
              v-display-price-cli    = false
              v-enable-price-cli     = false
              v-enable-cli-exch-code = false
              v-enable-contract      = false
            .
          end.
        end.
        else do:
          assign
            v-display-price-cli    = true
            v-enable-price-cli     = true
            v-enable-cli-exch-code = true
            v-enable-contract      = false
          .
        end.
        run update-enable-price-cli in this-procedure .
        run update-exch-code-enable in this-procedure .
        run display-dependent-info in this-procedure .
      end.
      assign
        x_parts.part-code      :modified = false
        x_parts.cst-code       :modified = false
        x_parts.last-date      :modified = false
        fi-last-date-offset  :modified = false
        x_parts.price-base     :modified = false
        x_parts.price-rubl     :modified = false
        fi-vat-pc            :modified = false
        fi-slt-pc            :modified = false
        x_parts.qnty           :modified = false
        x_parts.fact-qnty      :modified = false
        x_parts.cli-qnty       :modified = false
        x_parts.PS             :modified = false
        x_parts.supp-type      :modified = false
        x_parts.supp-code      :modified = false
        fi-contract-prn-code :modified = false
        v-modified-contract-code       = false
        v-modified-exch-code           = false
      .
      if available buf_parts
      and buf_parts.out-code <> buf_trn-doc.doc-code
      then do:
        if x_parts.qnty :sensitive
        then do:
          assign
            x_parts.qnty      :modified = true
          .
        end.
        if x_parts.fact-qnty :sensitive
        then do:
          assign
            x_parts.fact-qnty :modified = true
          .
        end.
      end.
      define variable l-enable-button as logical no-undo .
      assign
        b-exit :label in frame Dialog-Frame = "&Ввод"
      .
      assign
        b-save :sensitive = true
        b-quit :sensitive = true
        b-rest :sensitive = true
      .
      if x_parts.cli-qnty :sensitive
      then do:
        apply 'entry':u to x_parts.cli-qnty.
      end.
      else do:
        if x_parts.fact-qnty:sensitive
        then do:
          apply 'entry':u to x_parts.fact-qnty.
        end.
        else do:
          if x_parts.qnty:sensitive
          then do:
            apply 'entry':u to x_parts.qnty.
          end.
        end.
      end.
      if v-alcohol-prod = true
      then do:
        assign
          b-alc-attr :visible   = true
          b-alc-attr :sensitive = true
        .
      end.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH x_parts SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY fi-vat-pc fi-slt-pc fi-last-date-offset fi-contract-prn-code
          tot-price-cli tot-price-rubl tot-price-base FI-goods-artic fi-gds-name
          FI-goods-prod-type-code FI-clients-name FI-b-code fi-out-code
          FI-label-kolichestvo FI-label-ed-izm FI-label-koefficient fi-unit-cli
          fi-unit fi-unit-2 fi-vat-type fi-slt-type fi-supp fi-contract-name
          FI-label-cena FI-label-summa FI-label-val val-price-cli val-rubl-code
          val-price-rubl val-base-code val-price-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x_parts THEN
    DISPLAY x_parts.PS x_parts.cli-qnty x_parts.cli-base-rate x_parts.qnty
          x_parts.fact-qnty x_parts.part-code x_parts.cst-code x_parts.supp-type
          x_parts.supp-code x_parts.last-date x_parts.price-cli
          x_parts.exch-code x_parts.price-rubl x_parts.price-base
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-prev b-next b-alc-attr b-help RECT-2 RECT-3 RECT-4
         RECT-1 x_parts.PS fi-vat-pc fi-slt-pc x_parts.supp-type
         x_parts.supp-code r-supp x_parts.last-date b-choose-last-date
         fi-last-date-offset fi-contract-prn-code r-contract b-edit-price
         FI-goods-artic fi-gds-name FI-goods-prod-type-code FI-clients-name
         FI-b-code fi-out-code FI-label-kolichestvo FI-label-ed-izm
         FI-label-koefficient fi-unit-cli fi-unit fi-unit-2 fi-vat-type
         fi-slt-type fi-supp fi-contract-name FI-label-cena FI-label-summa
         FI-label-val val-price-cli val-rubl-code val-price-rubl val-base-code
         val-price-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE guess-parts-qnty :
  define parameter buffer buf_doc-line for ub.doc-line .
  define buffer buf_trn-doc for ub.trn-doc .
  define output parameter p-guess-qnty as decimal no-undo .
    define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
  run partrqst in this-procedure
    (input  buf_doc-line.doc-code
    ,input  buf_doc-line.obj-type
    ,input  buf_doc-line.obj-code
    ,input  buf_doc-line.artic
    ,input  buf_doc-line.prod-type
    ,input  buf_doc-line.prod-code
        ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
    ).
  case v-enable-qnty :
    when "qnty":u
    then do:
      define variable v-chg-qnty as decimal   no-undo .
      if valid-handle(h-call-prog)
      then do:
        run get-attr-chg-qnty in h-call-prog
          (output v-chg-qnty).
      end.
      define variable v-doc-line-qnty as decimal   no-undo .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
        .
      if buf_trn-doc.doc-type = 'инв':U
      then do:
        assign
          v-doc-line-qnty = buf_doc-line.fact-qnty
        .
      end.
      else do:
        assign
          v-doc-line-qnty = buf_doc-line.doc-qnty
        .
      end.
      assign
        p-guess-qnty = max(0, v-doc-line-qnty + v-chg-qnty  - v-total-parts-qnty)
      .
    end.
    when "fact-qnty":u
    then do:
      assign
        p-guess-qnty = max(0, buf_doc-line.fact-qnty - v-total-parts-fact-qnty)
      .
    end.
    when "cli-qnty":u
    then do:
      assign
        p-guess-qnty = max(0, buf_doc-line.cli-qnty  - v-total-parts-cli-qnty)
      .
    end.
  end.
END PROCEDURE.
PROCEDURE init-proc :
  define variable v-host-code as integer   no-undo .
  do
  on error   undo , return error
  on end-key undo , return error
  :
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_goods    for ub.goods .
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    define variable v-attr-value as character no-undo .
    define variable v-attr-type  as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-attr-value
  ,output v-attr-type
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка чтения конфигурационного параметра" 'is-fin' skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    else do:
      assign
        v-is-fin = lookup(v-attr-value, "true,yes") > 0
      .
    end.
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,output v-host-code
  )  .
define variable varcontract       as character no-undo .
define variable varcontract-type  as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date      like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
define variable v-mastc           as logical   no-undo init false .
         define variable varvalue as character no-undo.
         define variable vartype  as character no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_doc-line.doc-code ,
                        input 'trn-is-gds':U ,
                       output varvalue ,
                       output vartype ) no-error .
         if varvalue = "yes" then
         do:
    run adm/shattri.p (
      input "get":U
      ,input buf_doc-line.obj-type
      ,input buf_doc-line.obj-code
      ,input 'contr-in':U
      ,input  "contr-in-income"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-contract
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
end.
else do:
    run adm/shattri.p (
      input "get":U
      ,input buf_doc-line.obj-type
      ,input buf_doc-line.obj-code
      ,input 'contr-in':U
      ,input  "contr-in-income-NP"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-contract
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
end.
    RUN enable_UI.
    assign
      v-create-part = false
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  p-gds-code
  ,input  'serial=request':u
  ,output v-goods-serial
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при получении атрибута товара" skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "serial=request" skip
        view-as alert-box .
      undo, return error .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  p-gds-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-alcohol-value as character no-undo .
    define variable v-alcohol-type  as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol':u
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-alcohol-value
  ,output v-alcohol-type
  ) no-error .
    if  not error-status :error
    and lookup(v-alcohol-value, 'true,yes':u) > 0
    then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  p-gds-code
  ,input  'alcohol-prod=request':u
  ,output v-alcohol-prod
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          'alcohol-prod=request':u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    else do:
      assign
        v-alcohol-prod = false
      .
    end.
    define variable v-petroleum as logical   no-undo .
    define variable v-pieces    as logical   no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-petroleum
  , output v-pieces
  ) .
    assign
      v-goods-petroleum = ((v-petroleum = true)
                           and (v-pieces = false)
                          )
    .
    run disable-fields .
    run display-fields .
    run enable-fields  .
    hide b-prev in frame Dialog-Frame
         b-next b-save in frame Dialog-Frame .
    wait-for go of frame Dialog-Frame .
  end.
END PROCEDURE.
PROCEDURE record-modified :
  define output parameter p-record-modified as logical no-undo .
  define buffer buf_parts    for x_parts .
  do with frame Dialog-Frame
  :
    if x_parts.part-code :sensitive
    then do:
      if x_parts.part-code :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.cst-code :sensitive
    then do:
      if x_parts.cst-code :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.last-date :sensitive
    then do:
      if x_parts.last-date :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if fi-last-date-offset :sensitive
    then do:
      if fi-last-date-offset :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.price-cli :sensitive
    then do:
      if x_parts.price-cli :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.price-base :sensitive
    then do:
      if x_parts.price-base :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.price-rubl :sensitive
    then do:
      if x_parts.price-rubl :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if fi-vat-pc :sensitive
    then do:
      if fi-vat-pc :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if fi-slt-pc :sensitive
    then do:
      if fi-slt-pc :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.qnty :sensitive
    then do:
      if x_parts.qnty :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.fact-qnty :sensitive
    then do:
      if x_parts.fact-qnty :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.cli-qnty :sensitive
    then do:
      if x_parts.cli-qnty :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.PS :read-only = false
    then do:
      if x_parts.PS :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.supp-type :sensitive
    then do:
      if x_parts.supp-type :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if x_parts.supp-code :sensitive
    then do:
      if x_parts.supp-code :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if v-can-change-supp = true
    then do:
      if v-modified-exch-code = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if  v-can-change-supp = true
    and v-is-fin          = true
    then do:
      if v-modified-contract-code = true
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
    if v-alcohol-prod = true
    then do:
      find first buf_parts no-lock
        where recid(buf_parts) = v-parts-recid
        no-error .
      if available buf_parts and
        (v-alc-mark-db-num         <> buf_parts.mark-db-num             or
         v-alc-mark-code           <> buf_parts.mark-code               or
         v-alc-bottling-date       <> buf_parts.alc-bottling-date       or
         v-alc-ref-ab-path         <> buf_parts.alc-ref-ab-path         or
         v-alc-quality-certif-path <> buf_parts.alc-quality-certif-path or
         v-alc-certif-path         <> buf_parts.alc-certif-path
        )
      then do:
        assign
          p-record-modified = true
        .
        return .
      end.
    end.
  end.
  assign
    p-record-modified = false
  .
  return .
END PROCEDURE.
PROCEDURE reopen-query :
  define input parameter v-new-parts-recid as recid no-undo .
  if valid-handle(h-call-prog)
  then do:
    run reopen-query in h-call-prog
      .
    run reposition-parts in h-call-prog
      (input  string(v-new-parts-recid)
      ,output v-new-parts-recid
      ).
    apply 'entry':u to b-exit in frame Dialog-Frame .
    if v-new-parts-recid <> ?
    then do:
      define buffer buf_parts for x_parts .
      find first buf_parts no-lock
        where recid(buf_parts) = v-new-parts-recid
        no-error .
      assign
        v-parts-recid = v-new-parts-recid
      .
      if available buf_parts
      then do:
        run disable-fields .
        run display-fields .
        run enable-fields .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE reposition-parts :
  define input parameter v-direction as character no-undo .
  define variable v-new-parts-recid as recid no-undo .
  if valid-handle(h-call-prog)
  then do:
    run reposition-parts in h-call-prog
      (input  v-direction
      ,output v-new-parts-recid
      ).
    if v-new-parts-recid <> ?
    then do:
      define buffer buf_parts for x_parts .
      find first buf_parts no-lock
        where recid(buf_parts) = v-new-parts-recid
        no-error .
      assign
        v-parts-recid = v-new-parts-recid
      .
      if available buf_parts
      then do:
        run disable-fields .
        run display-fields .
        run enable-fields .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE update-dependent-price :
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      if v-can-change-supp = true
      then do:
        if v-enable-price-rubl = false
        then do:
          assign
            x_parts.price-rubl :screen-value = x_parts.price-cli :screen-value
          .
        end.
        if v-enable-price-base = false
        then do:
          case v-price-base-source
          :
            when 'price-cli':u
            then do:
              assign
                x_parts.price-base :screen-value = x_parts.price-cli :screen-value
              .
            end.
            when 'price-rubl':u
            then do:
              assign
                x_parts.price-base :screen-value = x_parts.price-rubl :screen-value
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Неизвестное значение v-price-base-source" v-price-base-source skip
                view-as alert-box error .
            end.
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE update-enable-price-cli :
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        fi-contract-prn-code :sensitive = v-enable-contract
        r-contract           :sensitive = v-enable-contract
      .
      if v-display-price-cli = true
      then do:
        assign
          x_parts.cli-base-rate :screen-value = "1"
        .
        assign
          fi-unit-cli          :visible = true
          val-price-cli        :visible = true
          x_parts.cli-base-rate  :visible = true
          x_parts.exch-code      :visible = true
          r-exch-code          :visible = true
          x_parts.price-cli      :visible = true
          x_parts.cli-qnty       :visible = true
          tot-price-cli        :visible = true
          FI-label-koefficient :visible = true
        .
        assign
          fi-unit-cli          :sensitive = false
          val-price-cli        :sensitive = false
          x_parts.cli-base-rate  :sensitive = false
          x_parts.exch-code      :sensitive = v-enable-cli-exch-code
          r-exch-code          :sensitive = v-enable-cli-exch-code
          x_parts.price-cli      :sensitive = v-enable-price-cli
          x_parts.cli-qnty       :sensitive = false
          tot-price-cli        :sensitive = false
          FI-label-koefficient :sensitive = false
        .
        if v-curr-r-b = 'base':U
        then do:
          assign
            x_parts.price-cli :screen-value = x_parts.price-base :screen-value
          .
        end.
        else do:
          assign
            x_parts.price-cli :screen-value = x_parts.price-rubl :screen-value
          .
        end.
        assign
          x_parts.cli-qnty :screen-value = x_parts.fact-qnty :screen-value
        .
      end.
      else do:
        assign
          fi-unit-cli          :sensitive = false
          val-price-cli        :sensitive = false
          x_parts.cli-base-rate  :sensitive = false
          x_parts.exch-code      :sensitive = false
          r-exch-code          :sensitive = false
          x_parts.price-cli      :sensitive = false
          x_parts.cli-qnty       :sensitive = false
          tot-price-cli        :sensitive = false
          FI-label-koefficient :sensitive = false
        .
        assign
          fi-unit-cli          :visible = false
          val-price-cli        :visible = false
          x_parts.cli-base-rate  :visible = false
          x_parts.exch-code      :visible = false
          r-exch-code          :visible = false
          x_parts.price-cli      :visible = false
          x_parts.cli-qnty       :visible = false
          tot-price-cli        :visible = false
          FI-label-koefficient :visible = false
        .
      end.
      if x_parts.exch-code :sensitive
      then do:
        assign
          x_parts.exch-code :fgcolor = ?
        .
      end.
      else do:
        assign
          x_parts.exch-code :fgcolor = 4
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE update-exch-code-dependent :
  define buffer buf_currency for ub.currency .
  do
  on error undo, return error return-value
  :
    find first buf_currency no-lock
      where buf_currency.curr-code = v-exch-code
      no-error .
    if not available buf_currency then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Неизвестный код валюты" v-exch-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    else do:
      do with frame Dialog-Frame
      :
        assign
          x_parts.exch-code :screen-value = string(buf_currency.curr-code
                                                ,x_parts.exch-code :format
                                                )
          val-price-cli   :screen-value = string(buf_currency.curr-abbr
                                                ,val-price-cli  :format
                                                )
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE update-exch-code-enable :
  do
  on error undo, return error return-value
  :
      assign
        v-price-base-source = '':u
        v-enable-price-rubl = true
        v-enable-price-base = true
      .
      if v-enable-price-cli = true
      then do:
        if v-exch-code = 0
        then do:
          assign
            v-enable-price-rubl = false
          .
        end.
        else do:
          assign
            v-enable-price-rubl = true
          .
        end.
        if v-exch-code = (input frame Dialog-Frame val-base-code)
        then do:
          assign
            v-enable-price-base = false
            v-price-base-source = 'price-cli':u
          .
        end.
        else do:
          assign
            v-enable-price-base = true
          .
        end.
      end.
      if (input frame Dialog-Frame val-base-code) = 0
      then do:
        assign
          v-enable-price-base = false
          v-price-base-source = 'price-rubl':u
        .
      end.
    if v-enable-price-rubl = true
    then do:
      assign
        x_parts.price-rubl :sensitive = true
      .
    end.
    else do:
      assign
        x_parts.price-rubl :sensitive = false
      .
    end.
    if v-enable-price-base = true
    then do:
      assign
        x_parts.price-base :sensitive = true
      .
    end.
    else do:
      assign
        x_parts.price-base :sensitive = false
      .
    end.
    run update-dependent-price in this-procedure .
  end.
END PROCEDURE.
PROCEDURE update-last-date-offset :
  do with frame Dialog-Frame
  :
    define variable v-last-date-offset as integer   no-undo .
    define variable v-today     as date      no-undo .
    define variable v-time      as integer   no-undo .
    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ) .
    run godendo-date-to-offset in this-procedure
      (input  v-today
      ,input  (input frame Dialog-Frame x_parts.last-date)
      ,output v-last-date-offset
      ) .
    assign
      fi-last-date-offset :screen-value = string(v-last-date-offset
                                                ,fi-last-date-offset :format
                                                )
    .
  end.
END PROCEDURE.
PROCEDURE update-record :
  define output parameter v-close-window    as logical no-undo .
  define variable v-ok as logical   no-undo .
  define variable v-record-modified as logical no-undo .
  define variable l-edit-reserv     as logical no-undo .
  assign
    v-close-window = false
  .
  run record-modified in this-procedure
    (output v-record-modified
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры record-modified" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if  v-record-modified = false
  and v-create-part = false
  then do:
    return .
  end.
  define variable v-root-node as integer no-undo .
  define buffer buf_parts    for x_parts .
  define buffer buf_goods    for ub.goods .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_trn-doc  for ub.trn-doc .
  do
  transaction
  on error undo, return error
  :
    if v-can-change-part-code
    then do:
      run validate-part-code in this-procedure
        (input v-new-parts-part-code
        ,input v-parts-recid
        ,input p-doc-code
        ,input p-gds-code
        ,input v-goods-serial
        ) no-error .
      if error-status :error
      then do:
        apply 'entry':u to x_parts.part-code in frame Dialog-Frame .
        undo, return error .
      end.
    end.
    if  x_parts.price-base :sensitive
    then do:
      if decimal(x_parts.price-base :screen-value) = ?
      then do:
        message
          substitute("Не задана учётная цена (&1)"
                    ,val-price-base :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to x_parts.price-base .
        undo, return error .
      end.
      if decimal(x_parts.price-base :screen-value) = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Учётная цена (&1) равна нулю"
                    ,val-price-base :screen-value
                    ) skip
          "Партия будет сохранена с нулевой учётной ценой." skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to x_parts.price-base .
          undo, return error .
        end.
      end.
    end.
    if  x_parts.price-rubl :sensitive
    then do:
      if decimal(x_parts.price-rubl :screen-value) = ?
      then do:
        message
          substitute("Не задана учётная цена (&1)"
                    ,val-price-rubl :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to x_parts.price-rubl .
        undo, return error .
      end.
      if decimal(x_parts.price-rubl :screen-value) = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Учётная цена (&1) равна нулю"
                    ,val-price-rubl :screen-value
                    ) skip
          "Партия будет сохранена с нулевой учётной ценой." skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to x_parts.price-rubl .
          undo, return error .
        end.
      end.
    end.
    if  x_parts.price-cli :sensitive
    then do:
      if decimal(x_parts.price-cli :screen-value) = ?
      then do:
        message
          substitute("Не задана цена поставщика (&1)"
                    ,val-price-cli :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to x_parts.price-cli .
        undo, return error .
      end.
      if decimal(x_parts.price-cli :screen-value) = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Цена поставщика (&1) равна нулю"
                    ,val-price-cli :screen-value
                    ) skip
          "Партия будет сохранена с нулевой ценой поставщика." skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to x_parts.price-cli .
          undo, return error .
        end.
      end.
    end.
    find first buf_trn-doc
      where buf_trn-doc.doc-code = p-doc-code
      .
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
      .
      find first buf_parts
        where recid(buf_parts) = v-parts-recid
        .
    assign
      l-edit-reserv = (buf_parts.out-code = buf_trn-doc.doc-code)
    .
    if buf_parts.in-code = buf_parts.out-code
    then do:
      if x_parts.part-code :sensitive
      then do:
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-root-node
  )  .
        if v-goods-twounit = true
        then do:
          if length(buf_parts.part-code) > 10
          or index(buf_parts.part-code, '#':U ) > 0
          then do:
            message
              "Код партии ювелирных изделий должен быть меньше или равен 10 символов" skip
              "И не должен содержать знак" '#':U skip
              view-as alert-box error .
            apply 'entry':u to x_parts.part-code .
            undo, return error .
          end.
        end.
        assign
          buf_parts.part-code = string(x_parts.part-code :screen-value)
        .
      end.
      if v-can-change-part-code
      then do:
        if x_parts.price-cli :sensitive
        then do:
          assign
            buf_parts.price-cli = decimal(x_parts.price-cli :screen-value)
          .
        end.
        if fi-vat-pc :sensitive
        then do:
          assign
            buf_parts.vat-pc = decimal(fi-vat-pc :screen-value)
          .
        end.
        if fi-slt-pc :sensitive
        then do:
          assign
            buf_parts.slt-pc = decimal(fi-slt-pc :screen-value)
          .
        end.
        assign
          buf_parts.price-base = decimal(x_parts.price-base :screen-value)
        .
        assign
          buf_parts.price-rubl = decimal(x_parts.price-rubl :screen-value)
        .
        if not( buf_trn-doc.doc-type     = 'при':U
                and buf_trn-doc.internal = false)
        then do:
          if  buf_parts.cli-base-rate = 1
          and buf_parts.exch-code     = 0
          then do:
            assign
              buf_parts.price-cli = buf_parts.price-rubl
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при создании партии" skip
              "Документ" buf_doc-line.price-base skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              "Для порожденной партии cli-base-rate отличен от 1" skip
              "cli-base-rate" buf_parts.cli-base-rate skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
      define variable v-create-old-return as logical no-undo .
      define variable v-reason as character no-undo .
      assign
        v-create-old-return = false
      .
      if x_parts.cst-code :sensitive
      then do:
        assign
          buf_parts.cst-code = string(x_parts.cst-code :screen-value)
        .
      end.
      if x_parts.last-date :sensitive
      then do:
        assign
          buf_parts.last-date = date(x_parts.last-date :screen-value)
        .
      end.
      if  v-can-change-supp = true
      and v-is-fin          = true
      then do:
        assign
          buf_parts.contract-code = v-contract-code
        .
      end.
      if v-can-change-supp = true
      then do:
        assign
          buf_parts.exch-code = v-exch-code
        .
        if x_parts.price-cli :sensitive
        then do:
          assign
            buf_parts.price-cli = input frame Dialog-Frame x_parts.price-cli
          .
        end.
      end.
      if buf_parts.contract-code = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка заведения партии" skip
          "Номер контракта имеет неопределённое значение" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  v-is-fin = false
      and buf_parts.contract-code <> 0
      then do:
        message
          "В системе отсутствует АРМ взаиморасчёты" skip
          "Нельзя задавать контракт для партии" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  v-is-fin   = true
      and v-contract = true
      and v-create-old-return = true
      and buf_parts.contract-code = 0
      then do:
        message
          "Необходимо указать контракт для партии старого возврата," skip
          "так как в системе включён АРМ взаиморасчёты" skip
          "и включён параметр обязательного заведения контракта" skip
          view-as alert-box information .
        apply 'entry':u to fi-contract-prn-code .
        undo, return error return-value .
      end.
      if  v-create-part = true
      and buf_parts.contract-code <> 0
      then do:
        define variable v-host-code as integer   no-undo .
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_parts.obj-type
  ,input  buf_parts.obj-code
  ,output v-host-code
  )  .
        define buffer buf_contract for ub.contract .
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = buf_parts.contract-code
          no-error .
        if not available buf_contract
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании контракта партии" skip
            "Код фирмы" v-host-code skip
            "Код контракта" buf_parts.contract-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        define variable v-contract-purch-code as integer   no-undo .
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cntpurch in g#library
  (input  buf_contract.contract-type
  ,output v-contract-purch-code
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении типа поставки для контракта" skip
            "Код фирмы" v-host-code skip
            "Код контракта" buf_contract.contract-code skip
            "Тип контракта" buf_contract.contract-type skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          buf_parts.exch-code  = buf_contract.curr-code
          buf_parts.purch-code = v-contract-purch-code
        .
      end.
    end.
    if x_parts.PS :read-only = false
    then do:
      assign
        buf_parts.PS = x_parts.PS :screen-value
      .
    end.
    if v-alcohol-prod = true
    then do:
      assign
        buf_parts.mark-db-num             = v-alc-mark-db-num
        buf_parts.mark-code               = v-alc-mark-code
        buf_parts.alc-bottling-date       = v-alc-bottling-date
        buf_parts.alc-ref-ab-path         = v-alc-ref-ab-path
        buf_parts.alc-quality-certif-path = v-alc-quality-certif-path
        buf_parts.alc-certif-path         = v-alc-certif-path
        buf_parts.alc-imp-type = v-alc-imp-type
        buf_parts.alc-imp-code = v-alc-imp-code
      .
    end.
    define variable v-chg-cli-qnty  like x_parts.cli-qnty  no-undo .
    define variable v-chg-qnty      like x_parts.qnty      no-undo .
    define variable v-chg-fact-qnty like x_parts.fact-qnty no-undo .
    assign
      v-chg-cli-qnty  = 0
      v-chg-qnty      = 0
      v-chg-fact-qnty = 0
    .
    case v-enable-qnty :
      when "cli-qnty":u
      then do:
        assign
          v-chg-cli-qnty = input frame Dialog-Frame x_parts.cli-qnty - buf_parts.cli-qnty
        .
        if v-goods-twounit = true
        then do:
          assign
            v-chg-qnty = input frame Dialog-Frame x_parts.qnty - buf_parts.qnty
          .
        end.
      end.
      when "qnty":u
      then do:
        case buf_parts.out-code :
          when 'free-zone':U
          then do:
            assign
              v-chg-qnty = - input frame Dialog-Frame x_parts.qnty
            .
          end.
          when 'out-zone':U
          then do:
            assign
              v-chg-qnty = input frame Dialog-Frame x_parts.qnty
            .
          end.
          when buf_trn-doc.doc-code
          then do:
            if lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0
            then do:
              assign
                v-chg-qnty = (buf_parts.qnty - input frame Dialog-Frame x_parts.qnty)
              .
            end.
            else do:
              assign
                v-chg-qnty = - (buf_parts.qnty - input frame Dialog-Frame x_parts.qnty)
              .
            end.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Попытка изменить партию, не принадлежащую документу" skip
              "Партия зарезервирована за документом" buf_parts.out-code skip
              "Текущий документ" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error .
          end.
        end case .
        define variable l-process-part      as logical   no-undo .
        define variable v-purch-code-list      as character no-undo .
        define variable v-purch-code-list-type as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'purchcodelist':U ,
                       output v-purch-code-list ,
                       output v-purch-code-list-type )  .
        if v-purch-code-list = '1,2,3,4':U
        then do:
          assign
            v-purch-code-list = "":u
          .
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run part-prc in g#library
  (buffer buf_parts
  ,buffer buf_trn-doc
  ,input  false
  ,input  '':u
  ,input  '':u
  ,input  p-pl-code
  ,input  v-goods-twounit
  ,input  v-purch-code-list
  ,input  v-chg-qnty
  ,input  true
  ,output v-reason
  ,output l-process-part
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении возможности резервирования партии" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if  l-process-part <> true
        and input frame Dialog-Frame x_parts.qnty <> 0
        then do:
          message
            v-reason
            view-as alert-box information .
          undo, return error .
        end.
      end.
      when "fact-qnty":u
      then do:
        case buf_parts.out-code :
          when buf_trn-doc.doc-code
          then do:
            assign
              v-chg-fact-qnty = input frame Dialog-Frame x_parts.fact-qnty - buf_parts.fact-qnty
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Попытка редактирования фактических количеств, не принадлежащую документу" skip
              "Партия зарезервирована за документом" buf_parts.out-code skip
              "Текущий документ" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error .
          end.
        end case .
      end.
      otherwise do:
      end.
    end case .
    if v-chg-cli-qnty  <> 0
    or v-chg-qnty      <> 0
    or v-chg-fact-qnty <> 0
    then do:
      case v-enable-qnty :
        when "cli-qnty":u
        then do:
          if v-goods-twounit = false
          then do:
            assign
              buf_parts.cli-qnty  = buf_parts.cli-qnty + v-chg-cli-qnty
              buf_parts.qnty      = buf_parts.cli-qnty * buf_parts.cli-base-rate
              buf_parts.fact-qnty = buf_parts.qnty
            .
          end.
          else do:
            assign
              buf_parts.cli-qnty  = buf_parts.cli-qnty + v-chg-cli-qnty
              buf_parts.qnty      = buf_parts.qnty     + v-chg-qnty
              buf_parts.fact-qnty = buf_parts.qnty
              buf_parts.cli-base-rate = buf_parts.qnty / buf_parts.cli-qnty
            .
            define variable v-road-tax as decimal   no-undo .
            if v-curr-r-b = 'base':U
            then do:
              assign
                v-road-tax = buf_parts.road-tax-base
              .
            end.
            else do:
              assign
                v-road-tax = buf_parts.road-tax-rubl
              .
            end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   buf_trn-doc.doc-code
  ,input   buf_trn-doc.base-rate
  ,input   buf_trn-doc.base-scale
  ,input   buf_trn-doc.exch-rate
  ,input   buf_trn-doc.exch-scale
  ,input   buf_trn-doc.vat-type
  ,input   buf_trn-doc.slt-type
  ,input   buf_parts.artic
  ,input   buf_parts.prod-type
  ,input   buf_parts.prod-code
  ,input   buf_parts.price-cli
  ,input   buf_parts.cli-base-rate
  ,input   buf_parts.price-rubl
  ,input   buf_parts.vat-pc
  ,input   buf_parts.slt-pc
  ,input   v-road-tax
  ,input   buf_parts.transport-rubl
  ,input   buf_parts.other-rubl
  ,output  v-price-cli
  ,output  v-price-cli-unit-base
  ,output  v-price-road-tax
  ,output  v-price-other-exp
  ,output  v-price-transport-exp
  ,output  v-price-without-abs
  ,output  v-price-slt
  ,output  v-price-no-slt
  ,output  v-price-vat
  ,output  v-price-no-vat-slt
  ,output  v-price-rubl
  ,output  v-price-road-tax-rubl
  ,output  v-price-other-exp-rubl
  ,output  v-price-transport-exp-rubl
  ,output  v-price-without-abs-rubl
  ,output  v-price-slt-rubl
  ,output  v-price-no-slt-rubl
  ,output  v-price-vat-rubl
  ,output  v-price-no-vat-slt-rubl
  ,output  v-price-base
  ,output  v-price-road-tax-base
  ,output  v-price-other-exp-base
  ,output  v-price-transport-exp-base
  ,output  v-price-without-abs-base
  ,output  v-price-slt-base
  ,output  v-price-no-slt-base
  ,output  v-price-vat-base
  ,output  v-price-no-vat-slt-base
  ) no-error.
            if error-status :error
            then do:
              return error "Ошибка при пересчете линии документа".
            end.
            assign
              buf_parts.price-cli  = v-price-cli
              buf_parts.price-base = v-price-base
              buf_parts.price-rubl = v-price-rubl
            .
          end.
          if buf_parts.qnty < 0
          then do:
            message
              "Количество по документу не может быть отрицательным"
              view-as alert-box .
            undo, return error .
          end.
        end.
        when "fact-qnty":u
        then do:
          assign
            buf_parts.fact-qnty = buf_parts.fact-qnty + v-chg-fact-qnty
          .
          if buf_parts.fact-qnty < 0
          then do:
            message
              "Фактическое количество не может быть отрицательным"
              view-as alert-box.
            apply 'entry':u to x_parts.fact-qnty.
            undo, return error .
          end.
          if buf_parts.fact-qnty > buf_parts.qnty
          then do:
            message
              "Фактическое количество не может превышать количества по документу"
              view-as alert-box.
            apply 'entry':u to x_parts.fact-qnty.
            undo, return error .
          end.
          if v-goods-serial = true
          and buf_parts.fact-qnty <> buf_parts.qnty
          and buf_parts.fact-qnty <> 0
          then do:
            message
              "Для серийных товаров фактическое количество" skip
              "должно равняться 1 или 0" skip
              view-as alert-box .
            apply 'entry':u to x_parts.fact-qnty.
            undo, return error .
          end.
          if v-goods-twounit = true
          then do:
            if buf_parts.fact-qnty <> buf_parts.qnty
            and buf_parts.fact-qnty <> 0
            then do:
              message
                "Для ювелирных изделий фактическое количество" skip
                "должно равняться" buf_parts.qnty "или 0" skip
                view-as alert-box .
              apply 'entry':u to x_parts.fact-qnty.
              undo, return error .
            end.
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
        end.
        when "qnty":u
        then do:
          define variable v-real-chg-qnty like x_parts.qnty no-undo .
          run partrsrv in this-procedure
            (input  v-chg-qnty
            ,input  v-goods-serial
            ,input  v-goods-twounit
            ,input  false
            ,buffer buf_parts
            ,buffer buf_trn-doc
            ,output v-real-chg-qnty
            ,output v-parts-recid
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при резервировании партии" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          if v-parts-recid = ?
          then do:
            assign
              v-close-window = true
            .
          end.
          if v-chg-qnty <> v-real-chg-qnty
          then do:
            message
              "Запрошенное количество недоступно." skip
              "Была произведена автоматическая коррекция запрошенного количества." skip
              "Запрошено" v-chg-qnty skip
              "Зарезервировано" v-real-chg-qnty skip
              view-as alert-box .
          end.
        end.
      end case .
    end.
      if (buf_trn-doc.flag_ = no  and buf_parts.qnty <= 0)
      or (buf_trn-doc.flag_ = yes and buf_parts.qnty <= 0 and buf_parts.fact-qnty <= 0)
      then do:
        delete buf_parts .
        message
          "Количество в партиии нулевое !" skip
          "Партия удаляется" skip
          view-as alert-box.
        return .
      end.
    if available buf_parts
    then do:
      if v-goods-twounit = true
      then do:
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitqnty in g#library
  (input buf_goods.unit-cli
  ,input buf_parts.artic
  ,input buf_parts.prod-type
  ,input buf_parts.prod-code
  ,input 'Ед.изм. поставщика'
  ,input buf_parts.cli-qnty
  ) no-error .
        if error-status :error
        then do:
          message
            "Не прошел контроль количества товара" skip
            "Попробуйте ввести другое количество" skip
            view-as alert-box information .
          undo, return error .
        end.
      end.
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitqnty in g#library
  (input buf_goods.unit-base
  ,input buf_parts.artic
  ,input buf_parts.prod-type
  ,input buf_parts.prod-code
  ,input ''
  ,input buf_parts.fact-qnty
  ) no-error .
      if error-status :error
      then do:
        message
          "Не прошел контроль количества товара" skip
          "Попробуйте ввести другое количество" skip
          view-as alert-box information .
        undo, return error .
      end.
    end.
  end.
  assign
    v-create-part = false
  .
  if valid-handle(h-call-prog)
  then do:
    run data-changed in h-call-prog .
  end.
.
END PROCEDURE.
PROCEDURE validate-contract :
  define variable v-host-code as integer   no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_contract for ub.contract .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      .
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
    if input frame Dialog-Frame fi-contract-prn-code <> fi-contract-prn-code
    then do:
      run validate-supp in this-procedure
        (input (input frame Dialog-Frame x_parts.supp-type)
        ,input (input frame Dialog-Frame x_parts.supp-code)
        ) no-error .
      if error-status :error
      then do:
        message
          "Неправильно задан поставщик" skip
          "" (input frame Dialog-Frame x_parts.supp-type)
            (input frame Dialog-Frame x_parts.supp-code) skip
          view-as alert-box error .
        undo, return no-apply .
      end.
      run check-contract-code in this-procedure
        (input  "input":u
        ,input  v-host-code
        ,input  (input frame Dialog-Frame x_parts.supp-type)
        ,input  (input frame Dialog-Frame x_parts.supp-code)
        ,input  input frame Dialog-Frame fi-contract-prn-code
        ,input  parparentproc
        ,input  buf_trn-doc.doc-date
        ,input  ""
        ,output v-contract-code
        ) no-error .
      if error-status :error
      or v-contract-code = ?
      then do:
        if return-value <> ""
        or error-status :get-message(1) <> ""
        then do:
          message
            "Ошибка при заведении номера договора." skip
            return-value skip
            error-status :get-message(1)
          view-as alert-box error .
        end.
        return error .
      end.
      assign
        v-modified-contract-code = true
      .
      if v-contract-code <> 0
      then do:
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = v-contract-code
          .
        display
          buf_contract.contract-prn-code @ fi-contract-prn-code
          substitute("&1 Вн.н. &2"
                    ,string(buf_contract.contract-date,'99/99/9999':u)
                    ,v-contract-code) @ fi-contract-name
          with frame Dialog-Frame .
        assign
          v-enable-cli-exch-code = false
          v-modified-exch-code   = true
          v-exch-code            = buf_contract.curr-code
        .
        run update-exch-code-dependent in this-procedure .
        run update-enable-price-cli    in this-procedure .
        run update-exch-code-enable    in this-procedure .
      end.
      else do:
        display
          "" @ fi-contract-prn-code
          "" @ fi-contract-name
          with frame Dialog-Frame .
        assign
          v-enable-cli-exch-code = true
          v-modified-exch-code   = true
          v-exch-code            = 0
        .
        run update-exch-code-dependent in this-procedure .
        run update-enable-price-cli    in this-procedure .
        run update-exch-code-enable    in this-procedure .
      end.
      assign
        fi-contract-prn-code
      .
    end.
  end.
END PROCEDURE.
PROCEDURE validate-exch-code :
  define buffer buf_currency for ub.currency .
  do
  on error undo, return error return-value
  :
    if input frame Dialog-Frame x_parts.exch-code <> v-exch-code
    then do:
      find first buf_currency no-lock
        where buf_currency.curr-code = input frame Dialog-Frame x_parts.exch-code
        no-error .
      if not available buf_currency
      then do:
        message
          "Неизвестный код валюты" skip
          "Код валюты" input frame Dialog-Frame x_parts.exch-code skip
          view-as alert-box error .
        apply 'entry':u to x_parts.exch-code in frame Dialog-Frame .
        undo, return error return-value .
      end.
      else do:
        assign
          v-modified-exch-code          = true
          v-exch-code                   = buf_currency.curr-code
        .
        run update-exch-code-dependent in this-procedure .
        run update-exch-code-enable    in this-procedure .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE validate-part-code :
  define input parameter p-new-part-code  as character no-undo .
  define input parameter p-parts-recid    as recid     no-undo .
  define input parameter p-doc-code       as character no-undo .
  define input parameter p-gds-code       as integer   no-undo .
  define input parameter p-goods-serial   as logical   no-undo .
  define buffer buf_goods    for ub.goods .
  define buffer buf_doc-line for ub.doc-line .
  define buffer lookup_parts for x_parts .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  find first buf_doc-line no-lock
    where buf_doc-line.doc-code  = p-doc-code
      and buf_doc-line.artic     = buf_goods.artic
      and buf_doc-line.prod-type = buf_goods.prod-type
      and buf_doc-line.prod-code = buf_goods.prod-code
    .
  find first lookup_parts no-lock
    where lookup_parts.obj-type  = buf_doc-line.obj-type
      and lookup_parts.obj-code  = buf_doc-line.obj-code
      and lookup_parts.artic     = buf_doc-line.artic
      and lookup_parts.prod-type = buf_doc-line.prod-type
      and lookup_parts.prod-code = buf_doc-line.prod-code
      and lookup_parts.in-code   = buf_doc-line.doc-code
      and lookup_parts.out-code  = buf_doc-line.doc-code
      and lookup_parts.part-code = p-new-part-code
      and recid (lookup_parts) <> p-parts-recid
    no-error .
  if available lookup_parts
  then do:
    define variable v-show-part-code as character no-undo .
    if p-new-part-code = '':u
    then do:
      assign
        v-show-part-code = '------':u
      .
    end.
    else do:
      assign
        v-show-part-code = p-new-part-code
      .
    end.
    message
      "Партия с номером <<" + v-show-part-code + ">> уже есть"
      view-as alert-box error .
    undo, return error .
  end.
  if  p-goods-serial  = true
  and p-new-part-code = ""
  then do:
    message
      "Для серийных товаров - серийный номер обязателен"
      view-as alert-box error .
    undo, return error .
  end.
END PROCEDURE.
PROCEDURE validate-qnty :
define buffer bufr_parts for ub.parts  .
define buffer free_parts for ub.parts  .
define buffer ras_parts for ub.parts  .
define buffer rez_parts for ub.parts  .
define buffer buf_goods  for ub.goods  .
define variable v-delta as decimal   no-undo .
define variable v-rashod as decimal   no-undo .
define variable v-rezerv as decimal   no-undo .
define variable v-qnty  as decimal   no-undo .
v-qnty = decimal ( x_parts.cli-qnty :screen-value in frame Dialog-Frame ) *
         decimal ( x_parts.cli-base-rate :screen-value in frame Dialog-Frame ) .
find first buf_goods no-lock
  where buf_goods.gds-code = p-gds-code no-error .
    find first bufr_parts no-lock where
               bufr_parts.artic = buf_goods.artic and
               bufr_parts.prod-type = buf_goods.prod-type and
               bufr_parts.prod-code = buf_goods.prod-code and
               bufr_parts.in-code   = p-in-code and
               bufr_parts.part-code = p-part-code and
               bufr_parts.out-code  = p-out-code
      no-error .
  if bufr_parts.fact-qnty < v-qnty then do:
     message
     "Изменить Количество можно только в меньшую сторону !!!"
     view-as alert-box information .
     return error .
  end.
  v-delta = bufr_parts.cli-qnty - v-qnty .
    v-rashod =  0 .
    find first ras_parts no-lock where
               ras_parts.artic     = buf_goods.artic and
               ras_parts.prod-type = buf_goods.prod-type and
               ras_parts.prod-code = buf_goods.prod-code and
               ras_parts.in-code   = p-in-code and
               ras_parts.part-code = p-part-code and
               ras_parts.out-code  = 'out-zone':U and
               ras_parts.rsrv-free = no
      no-error .
  if available ras_parts  then do:
      v-rashod = ras_parts.fact-qnty .
  end.
    v-rezerv = 0 .
    for each rez_parts no-lock where
            rez_parts.artic     = buf_goods.artic and
            rez_parts.prod-type = buf_goods.prod-type and
            rez_parts.prod-code = buf_goods.prod-code and
            rez_parts.in-code   = p-in-code and
            rez_parts.part-code = p-part-code and
            rez_parts.out-code <> p-in-code and
            rez_parts.out-code <> 'free-zone':U and
            rez_parts.status_    = false  and
            rez_parts.rsrv-free = true :
        v-rezerv = v-rezerv + rez_parts.fact-qnty .
    end.
   v-rashod = v-rashod + v-rezerv .
  if v-rashod > v-qnty then do:
     message
     "Израсходовано больше чем в приходе "  skip
     "Израсходовано и зарезервировано :" v-rashod "(" v-rezerv ")"
     view-as alert-box information .
     return error .
  end.
END PROCEDURE.
PROCEDURE validate-supp :
  define input parameter p-supp-type like x_parts.supp-type no-undo .
  define input parameter p-supp-code like x_parts.supp-code no-undo .
  def buffer buf_supp-clients for clients .
  define variable v-create-old-return as logical   no-undo .
  define variable v-reason            as character no-undo .
  do
  on error undo, return error return-value
  :
    if  v-supp-type = p-supp-type
    and v-supp-code = p-supp-code
    then do:
      return .
    end.
    find buf_supp-clients  no-lock
      where buf_supp-clients.obj-type = p-supp-type
        and buf_supp-clients.obj-code = p-supp-code
      no-error.
    if not available buf_supp-clients
    then do:
      if p-supp-type = ""
      or p-supp-type = ?
      or p-supp-code = 0
      or p-supp-code = ?
      then do:
        message
          "Не задан тип или код поставщика" skip
          p-supp-type p-supp-code skip
          view-as alert-box information .
      end.
      else do:
        message
          "Неправильный код или тип поставщика" skip
          p-supp-type p-supp-code skip
          view-as alert-box information .
      end.
      apply 'entry':u to x_parts.supp-type in frame Dialog-Frame.
      return error.
    end.
    if buf_supp-clients.stts <> 0
    then do:
      message
        "Клиент" buf_supp-clients.obj-name "удален" skip
        "Выберите другого клиента" skip
        view-as alert-box information .
      return error .
    end.
    define buffer buf_trn-doc for ub.trn-doc .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      .
    run partscr_check-valid-supp in this-procedure
      (input  p-supp-type
      ,input  p-supp-code
      ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
      ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
      ,input  buf_trn-doc.ext-doc-type
      ,output v-create-old-return
      ,output v-reason
      ).
    if v-reason <> ""
    then do:
      message
        v-reason
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-supp-type = p-supp-type
      v-supp-code = p-supp-code
    .
    run clear-contract-value in this-procedure .
    assign
      fi-supp :screen-value = buf_supp-clients.obj-name
      fi-supp :modified     = false
    .
    if v-create-old-return = true
    then do:
      assign
        v-display-price-cli    = true
        v-enable-price-cli     = true
        v-enable-cli-exch-code = true
      .
      if v-is-fin = true
      then do:
        assign
          v-enable-contract    = true
        .
      end.
      else do:
        assign
          v-enable-contract    = false
        .
      end.
    end.
    else do:
      assign
        v-display-price-cli    = false
        v-enable-price-cli     = false
        v-enable-cli-exch-code = false
        v-enable-contract      = false
      .
    end.
    run update-enable-price-cli in this-procedure .
    run update-exch-code-enable in this-procedure .
  end.
END PROCEDURE.
