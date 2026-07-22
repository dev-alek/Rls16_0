DEFINE BUFFER b-c-b FOR bar-code.
DEFINE BUFFER buf_goods FOR ub.goods.
define buffer t-doc   for ub.trn-doc.
define buffer g-d-b   for ub.gds-dtl.
define buffer out-dtl for ub.gds-dtl.
define buffer bf_prod-bc for ub.prod-bc.
define buffer in_doc-line for ub.doc-line.
define buffer in_parts for ub.parts.
define buffer out_parts for ub.parts.
define buffer buf_gen-attr for ub.gen-attr .
define buffer buf_gds-obj for ub.gds-obj .
define buffer buf_marking for ub.marking .
define buffer buf_marking-child for ub.marking .
define buffer buf_marking-lines for ub.marking-lines .
define new shared temp-table tt-doc-pl no-undo
field pl-code as integer format "99999999999"
field pl-code2 as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code as integer format "99999999999"
field cli-qnty like ub.doc-pl.cli-qnty
field cli-fact-qnty like ub.doc-pl.cli-fact-qnty
field cli-doc-qnty like ub.doc-pl.cli-doc-qnty
field rest-af-qnty like ub.doc-pl.rest-af-qnty
field cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty
field rest-bf-qnty like ub.doc-pl.rest-bf-qnty
field cli-rest-bf-qnty like ub.doc-pl.cli-rest-bf-qnty
index pi obj-type obj-code pl-code out-code gds-code
index doc out-code gds-code obj-code obj-type pl-code
index gds-code gds-code
.
define input parameter ParParentProc as widget-handle no-undo .
define input parameter doc-rec       as recid         no-undo .
define input parameter line-rec      as recid         no-undo .
define input parameter gds-rec       as recid         no-undo .
define input parameter prt-mode      as character     no-undo .
define input parameter cur-rec       as recid         no-undo .
define input parameter node-type     as character     no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 81f7d91a817a, 3654, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2024/01/31 10:15:43 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: out-prt.w $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/out-prt.w $":U .
define variable vss-description as character no-undo initial "Задание док. и факт. количества по признаку или артикулу в рас, возврат, при, спи накладных (внешних и внутренних)":U .
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
      p-vss-parameters = substitute('&1|&2':u,cur-rec,node-type)
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
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fact-order-mpl :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-date as date     no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-fact-order as decimal   no-undo .
define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable shift-date as date      no-undo .
define variable shift-num  as integer   no-undo .
define variable shift-name as character no-undo .
define variable max-fact-order as decimal   no-undo .
define buffer buf_global-state for ub.global-state  .
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
  run cur-time in this-procedure
  ( output v-fact-date ,
    output v-fact-time  ).
if p-doc-date = ? then do:
if buf_global-state.pl-use-sys-date-time  = true then do:
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  ?
        ,input  ?
        ,input  false
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
else do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      if p-doc-date <> ? then do:
      end.
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error substitute(" Ошибка из factdate.p: &1 &2"  , return-value , error-status :get-message(1)   ) .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
end.
else do:
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error "Ошибка factdate.p " + return-value .
      v-fact-date = p-doc-date .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
  end.
end procedure.
DEFINE TEMP-TABLE tt_price-all NO-UNDO LIKE ub.price-all
field sale-qnty as decimal
field sale-sum  as decimal
field sale-tnv  as decimal
field price-sale-base as decimal
field price-sale-rubl as decimal
field road-tax-base   as decimal
field road-tax-rubl   as decimal
field excise-base as decimal
field excise-rubl as decimal
field date-1 as date
field date-2 as date
field shift-1 as int
field shift-2 as int
field time-1 as int
field time-2 as int
field grp-name as char
field interv-name as char
field pay-name as char
field unit-cli as char
index pi
plt-priority DESCENDING
fact-order DESCENDING
qnty-from asc
sum-from asc
turnover-from asc
date-1 DESCENDING
time-1 DESCENDING
date-2 DESCENDING
time-2 DESCENDING
type-price DESCENDING
.
procedure mpl-autoprice :
define input  parameter p-only-b-code as logical   no-undo .
define input  parameter p-cli-type    as character no-undo .
define input  parameter p-cli-code    as integer   no-undo .
define input  parameter p-main-b-code as integer   no-undo .
define input  parameter p-b-code      as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-qnty-doc    as decimal   no-undo .
define input  parameter p-sum-doc     as decimal   no-undo .
define input  parameter p-vid-pay        as character no-undo .
define input  parameter p-cash-pay-type  as character no-undo .
define input  parameter p-fact-order  as decimal   no-undo .
define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .
define output parameter p-road-tax-base as decimal   no-undo .
define output parameter p-road-tax-rubl as decimal   no-undo .
define output parameter p-excise-base   as decimal   no-undo .
define output parameter p-excise-rubl   as decimal   no-undo .
define variable v-cli-oborot-ALL as decimal   no-undo .
define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group  .
define buffer buf_turnover-buyer-main    for ub.turnover-buyer-main  .
define buffer buf1_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf2_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf_price-all              for ub.price-all  .
define buffer buf_goods                  for ub.goods      .
define buffer buf_global-state           for ub.global-state  .
define buffer buf_buyer-group            for ub.buyer-group  .
define buffer buf_turnover-group         for ub.turnover-group  .
define buffer buf_main-code              for ub.bar-code  .
define buffer buf_bar-code               for ub.bar-code  .
define buffer buf_pay-type               for ub.pay-type  .
define buffer buf_cash-pay               for ub.cash-pay  .
define variable to-day          as date      no-undo .
define variable v-base-rate0    as decimal   no-undo .
define variable v-base-scale0   as decimal   no-undo .
define variable v-exch-rate0    as decimal   no-undo .
define variable v-exch-scale0   as decimal   no-undo .
define variable v-base-rate     as decimal   no-undo .
define variable v-base-scale    as decimal   no-undo .
define variable v-exch-rate     as decimal   no-undo .
define variable v-exch-scale    as decimal   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-curr-abbr     as character no-undo .
define variable v-grp-name      as character no-undo .
define variable v-date-1        as date      no-undo .
define variable v-date-2        as date      no-undo .
define variable v-interv        as character no-undo .
define variable v-pay-name      as character no-undo .
define variable v-cli-oborot    as decimal   no-undo .
define variable v-trn-pay-code  as integer   no-undo .
define variable v-cash-pay-curr as integer   no-undo .
define variable v-cash-pay-code as integer   no-undo .
do
on error undo, return error return-value
:
find first buf_main-code no-lock where buf_main-code.b-code = p-main-b-code .
find first buf_goods no-lock where buf_goods.gds-code = buf_main-code.gds-code.
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ).
end.
if p-vid-pay <> "" then do:
   find first buf_pay-type no-lock where  buf_pay-type.obj-code = integer(p-vid-pay) no-error .
   if available buf_pay-type
      then v-trn-pay-code = buf_pay-type.obj-code.
      else v-trn-pay-code =  0.
end.
else v-trn-pay-code = 0 .
if p-cash-pay-type <> "" then do:
   find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer(p-cash-pay-type) no-error .
   if available buf_pay-type
      then
        assign
          v-cash-pay-curr = buf_cash-pay.curr-code
          v-cash-pay-code = buf_cash-pay.cdpay-code
        .
      else
        assign
          v-cash-pay-curr = 0
          v-cash-pay-code = 0
          .
end.
else
  assign
    v-cash-pay-curr = 0
    v-cash-pay-code = 0
    .
for each tt_price-all  : delete tt_price-all . end.
assign
  p-plt-id             = ?
  p-plt-db-num         = ?
  p-pdf-id             = ?
  p-pdf-db-num         = ?
  p-sale-price-base    = ?
  p-sale-price-rubl    = ?
  v-cli-oborot         = 0
.
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  to-day
  ,output v-base-rate0
  ,output v-base-scale0
  )  .
  v-cli-oborot-ALL  = 0 .
  for each buf_turnover-buyer-main no-lock  where
           buf_turnover-buyer-main.cli-type = p-cli-type  and
           buf_turnover-buyer-main.cli-code = p-cli-code
           :
           v-cli-oborot-ALL = v-cli-oborot-ALL + buf_turnover-buyer-main.sum-doc-rubl-itog .
  end.
for each buf_price-all no-lock where
         buf_price-all.obj-type = p-obj-type and
         buf_price-all.obj-code = p-obj-code and
         buf_price-all.gds-code = buf_goods.gds-code and
         buf_price-all.status_  = 'акт':U  and
       ( p-only-b-code = false   or
       ( buf_price-all.b-code = p-main-b-code or
         buf_price-all.b-code = p-b-code))    and
        ( p-only-b-code = true  or
          buf_price-all.b-code = p-b-code)
          and
          buf_price-all.fact-order-sys-from  <= p-fact-order  and
        ( buf_price-all.fact-order-sys-to = ? or
          buf_price-all.fact-order-sys-to    >= p-fact-order)
        :
         v-interv   = "" .
         v-grp-name = "" .
         v-pay-name = "" .
         if buf_price-all.fact-order = 0  and buf_price-all.plt-priority = 0  then next.
         if buf_price-all.bgr-id > 0 then do:
            find first buf_buyer-group no-lock where
                       buf_buyer-group.bgr-id     = buf_price-all.bgr-id  and
                       buf_buyer-group.bgr-db-num = buf_price-all.bgr-db-num  no-error .
            if available buf_buyer-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
               find first buf_buyer-in-buyer-group no-lock where
                          buf_buyer-in-buyer-group.stts         = 0 and
                          buf_buyer-in-buyer-group.bgr-id       = buf_buyer-group.bgr-id     and
                          buf_buyer-in-buyer-group.bgr-db-num   = buf_buyer-group.bgr-db-num  and
                          buf_buyer-in-buyer-group.bbg-obj-type = p-cli-type and
                          buf_buyer-in-buyer-group.bbg-obj-code = p-cli-code
                          no-error .
                          if not available buf_buyer-in-buyer-group then do:
                             v-grp-name = "".
                             next.
                          end.
                          v-grp-name = buf_buyer-group.name .
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.tog-id > 0 then do:
            find first buf_turnover-group no-lock where
                       buf_turnover-group.tog-id     = buf_price-all.tog-id      and
                       buf_turnover-group.tog-db-num = buf_price-all.tog-db-num  no-error .
            if available buf_turnover-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
                  v-cli-oborot = v-cli-oborot-all  .
                  find first buf1_tnv-in-turnover-group no-lock where
                             buf1_tnv-in-turnover-group.stts       =  0     and
                             buf1_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf1_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf1_tnv-in-turnover-group.ttg-summa  <=  v-cli-oborot no-error .
                  find first buf2_tnv-in-turnover-group no-lock where
                             buf2_tnv-in-turnover-group.stts       =  0     and
                             buf2_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf2_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf2_tnv-in-turnover-group.ttg-summa  >=  v-cli-oborot no-error .
                  if not (available buf1_tnv-in-turnover-group and
                          available buf2_tnv-in-turnover-group ) then do:
                          v-grp-name = "".
                          next .
                  end.
                  v-grp-name = buf_turnover-group.name.
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.plt-fix-cource-crc-base = true then
            assign
              v-base-rate  = buf_price-all.pdf-base-rate
              v-base-scale = buf_price-all.pdf-base-scale
            .
            else
            assign
              v-base-rate  = v-base-rate0
              v-base-scale = v-base-scale0
            .
         if buf_price-all.plt-fix-cource-crc-doc = true then
            assign
              v-exch-rate  = buf_price-all.pdf-exch-rate
              v-exch-scale = buf_price-all.pdf-exch-scale
            .
            else do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_price-all.curr-code
  ,input  to-day
  ,output v-exch-rate0
  ,output v-exch-scale0
  ,output v-curr-abbr
  )  .
            assign
              v-exch-rate  = v-exch-rate0
              v-exch-scale = v-exch-scale0
              .
           end.
           v-date-1 = date ( "" )  .
           if buf_price-all.fact-order-sys-from > 0 then do:
              if buf_price-all.start-sys-date <> ?   then  v-date-1 = buf_price-all.start-sys-date.
              if buf_price-all.start-shift-date <> ? then  v-date-1 = buf_price-all.start-shift-date.
              if buf_price-all.start-date <> ?       then  v-date-1 = buf_price-all.start-date.
           end.
           v-date-2 =  date ( "" )  .
           if buf_price-all.fact-order-sys-to > 0 then do:
              if buf_price-all.end-sys-date <> ?     then  v-date-2 = buf_price-all.end-sys-date.
              if buf_price-all.end-shift-date <> ?   then  v-date-2 = buf_price-all.end-shift-date.
              if buf_price-all.end-date <> ?         then  v-date-2 = buf_price-all.end-date.
           end.
           if buf_price-all.qnty-from <> ? then do :
              if not (
              ( p-qnty-doc  >= buf_price-all.qnty-from and buf_price-all.qnty-to = ? ) or
              ( p-qnty-doc  >= buf_price-all.qnty-from and p-qnty-doc <= buf_price-all.qnty-to and buf_price-all.qnty-to <> ?)
              ) then do:
                     v-interv = "".
                     next.
              end.
              v-interv = "К: " + string(buf_price-all.qnty-from) + " - " + ( if buf_price-all.qnty-to = ? then "и более" else string(buf_price-all.qnty-to)) .
           end.
           if buf_price-all.sum-from <> ? then do :
              if not (
              ( p-sum-doc  >= buf_price-all.sum-from and buf_price-all.sum-to = ? ) or
              ( p-sum-doc  >= buf_price-all.sum-from and p-sum-doc <= buf_price-all.sum-to and buf_price-all.sum-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "C: " +  string(buf_price-all.sum-from) + " - " + ( if buf_price-all.sum-to = ? then "и более" else string(buf_price-all.sum-to)) .
           end.
           if buf_price-all.turnover-from <> ? then do :
              if not (
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and buf_price-all.turnover-to = ? ) or
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and v-cli-oborot-ALL <= buf_price-all.turnover-to and buf_price-all.turnover-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "O: " +  string(buf_price-all.turnover-from) + " - " + ( if buf_price-all.turnover-to = ? then "и более" else string(buf_price-all.turnover-to)) .
           end.
           if buf_price-all.use-pay-type = 1 then do :
              if buf_price-all.pay-code <> v-trn-pay-code then do:
                 v-pay-name = "" .
                 next.
               end.
               v-pay-name = 'Оплата':U +  ":" + string(buf_price-all.pay-code) .
           end.
           if buf_price-all.use-cash-pay = 1 then do :
              if v-cash-pay-code <> 0 and  not ( buf_price-all.curr-pay-code = v-cash-pay-curr and
                                                 buf_price-all.cdpay-code    = v-cash-pay-code ) then do:
                v-pay-name = "" .
                next.
              end.
              v-pay-name = 'Касс.платеж':U + ":" + string(buf_price-all.cdpay-code) + "_" + string(buf_price-all.curr-pay-code).
           end.
          find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
          create tt_price-all .
          buffer-copy buf_price-all to tt_price-all
          assign
            tt_price-all.price-sale-rubl = buf_price-all.price-sale  * v-exch-rate / v-exch-scale
            tt_price-all.road-tax-rubl   = buf_price-all.road-tax    * v-exch-rate / v-exch-scale
            tt_price-all.excise-rubl     = buf_price-all.excise      * v-exch-rate / v-exch-scale
            tt_price-all.price-sale-base = tt_price-all.price-sale-rubl  / v-base-rate * v-base-scale
            tt_price-all.road-tax-base   = tt_price-all.road-tax-rubl    / v-base-rate * v-base-scale
            tt_price-all.excise-base     = tt_price-all.excise-rubl      / v-base-rate * v-base-scale
            tt_price-all.price-sale     = buf_price-all.price-sale
            tt_price-all.road-tax       = buf_price-all.road-tax
            tt_price-all.excise         = buf_price-all.excise
            tt_price-all.pdf-exch-rate   = v-exch-rate
            tt_price-all.pdf-exch-scale  = v-exch-scale
            tt_price-all.pdf-base-rate   = v-base-rate
            tt_price-all.pdf-base-scale  = v-base-scale
            tt_price-all.grp-name        = v-grp-name
            tt_price-all.date-1          = v-date-1
            tt_price-all.shift-1         = buf_price-all.start-shift-num
            tt_price-all.time-1          = buf_price-all.start-sys-time
            tt_price-all.date-2          = v-date-2
            tt_price-all.shift-2         = buf_price-all.end-shift-num
            tt_price-all.time-2          = buf_price-all.end-sys-time
            tt_price-all.interv-name     = v-interv
            tt_price-all.pay-name        = v-pay-name
            tt_price-all.unit-cli        = buf_bar-code.unit-cli
          .
end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = p-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = neos_price-all.price-sale-base
            p-sale-price-rubl  = neos_price-all.price-sale-rubl
            p-road-tax-base    = neos_price-all.road-tax-base
            p-road-tax-rubl    = neos_price-all.road-tax-rubl
            p-excise-base      = neos_price-all.excise-base
            p-excise-rubl      = neos_price-all.excise-rubl
            .
         end.
         else do:
              find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
              if error-status :error    then do:
                message "Не найден бар-код" p-b-code view-as alert-box error .
                return error return-value .
              end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
end.
end procedure.
procedure mpl-tpl-auto :
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-sale-price as decimal   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ) .
end.
assign
  p-pdf-id      = ?
  p-pdf-db-num  = ?
  p-sale-price  = ?
.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
if error-status :error then return error return-value .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
if error-status :error then return error return-value .
define variable v-main-b-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
define buffer buf_price-all for ub.price-all  .
for each tt_price-all : delete tt_price-all. end.
    for each buf_price-all no-lock where
            buf_price-all.plt-id     = p-plt-id                 and
            buf_price-all.plt-db-num = p-plt-db-num             and
            buf_price-all.obj-type   = p-obj-type               and
            buf_price-all.obj-code   = p-obj-code               and
            buf_price-all.gds-code   = buf_goods.gds-code       and
          ( buf_price-all.b-code = v-main-b-code or
            buf_price-all.b-code = p-b-code)    and
            buf_price-all.status_    = 'акт':U         and
            buf_price-all.fact-order-sys-from  <= p-fact-order  and
          ( buf_price-all.fact-order-sys-to = ? or
            buf_price-all.fact-order-sys-to >=  p-fact-order)
            :
              create tt_price-all .
              buffer-copy buf_price-all to tt_price-all
              assign
                tt_price-all.price-sale  = buf_price-all.price-sale
              .
    end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = v-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = neos_price-all.price-sale
            .
         end.
         else do:
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        if error-status :error    then do:
           message "Не найден бар-код" p-b-code view-as alert-box error .
           return error return-value .
        end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts-qnty no-undo
  field qnty      like ub.parts.qnty
  field fact-qnty like ub.parts.fact-qnty
  field cli-qnty  like ub.parts.cli-qnty
  field pl-code   like ub.parts.pl-code
  field parts-part-code like ub.parts.part-code
  field parts-recid as recid
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
define variable vss-include-info20 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define new global shared variable g#lib-rvs as handle no-undo.
  define temp-table tt-param no-undo
    field strfrfile as character
    field strasi    as character
    field flddb     as character
    index pi        as primary   unique strfrfile
    index asi strasi.
  define temp-table tt-param-pump no-undo
    field strfrfile as character
    field meaning   as character
    index pi        as primary   unique strfrfile.
  define temp-table tt-meas no-undo like ub.place
    field measure-qnty like ub.rvs-line.measure-qnty
    field brutto-qnty like ub.rvs-line.brutto-qnty
    field measure-cli-qnty like ub.rvs-line.measure-cli-qnty
    field brutto-cli-qnty like ub.rvs-line.brutto-cli-qnty
    field density like ub.rvs-line.density
    field temperature like ub.rvs-line.temperature
    field level-total like ub.rvs-line.level-total
    field level-petrol like ub.rvs-line.level-petrol
    field level-water like ub.rvs-line.level-water
    field temp-layer1 like ub.rvs-line.temp-layer1
    field temp-layer2 like ub.rvs-line.temp-layer2
    field temp-layer3 like ub.rvs-line.temp-layer3
    field measure-tc-qnty like ub.rvs-line.measure-tc-qnty
    field brutto-tc-qnty like ub.rvs-line.brutto-tc-qnty
    field meas-vol-oil   as logical initial no
    field meas-vol-water as logical initial no
    field water-qnty     like ub.rvs-line.measure-qnty
    field vapor-density like ub.rvs-line.density
    field vapor-pressure as decimal format ">>9.9<":U
    field log-brutto as logical
    field temp-not-null as logical
    field t1-not-null as logical
    field t2-not-null as logical
    field t3-not-null as logical
    field is-error    as logical
    index pi        as primary   loc1.
  define temp-table tt-meas-file no-undo like tt-meas.
  define temp-table tt-pump-nozzle no-undo like ub.pump-nozzle
    field gds-code    like ub.goods.gds-code
    field meas-el-cnt like ub.rvs-line-pump.meas-el-cnt
    field meas-am-cnt like ub.rvs-line-pump.meas-am-cnt
    field grade       as   character
    field meas-cf-cnt like ub.rvs-line-pump.meas-cf-cnt.
  define temp-table tt-pump-nozzle-file no-undo like tt-pump-nozzle.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function is-gas returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'metan':U) no-error.
return result.
end function.
function is-sug returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'lgas':U) no-error.
return result.
end function.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define variable v-prt-car-num          as character    no-undo .
    define variable v-prt-car-vol          as character    no-undo .
    define variable v-prt-tests            as character    no-undo .
    define variable v-prt-autoent-obj-type as character    no-undo .
    define variable v-prt-autoent-obj-code as character    no-undo .
    define variable v-prt-item-pour        as character    no-undo .
    define variable v-prt-time-pour        as character    no-undo .
    define variable v-prt-tank-vol         as character    no-undo .
    define variable v-prt-tank-temp        as character    no-undo .
    define variable v-prt-tank-water       as character    no-undo .
    define variable v-prt-tank-density     as character    no-undo .
    define variable v-prt-tank-weight      as character    no-undo .
    define variable v-prt-time-income      as character    no-undo .
    define variable v-prt-start-real-date  like ub.rvs-line.real-date    no-undo .
    define variable v-prt-start-real-time  like ub.rvs-line.real-time    no-undo .
    define variable v-prt-end-real-date    like ub.rvs-line.real-date    no-undo .
    define variable v-prt-end-real-time    like ub.rvs-line.real-time    no-undo .
    define variable v-prt-mouth            as character    no-undo .
    define variable v-prt-fio              as character    no-undo .
    define variable v-prt-ptbotype         as character    no-undo .
    define variable v-prt-ptbocode         as character    no-undo .
    define variable v-prt-a-b-tarir        as character    no-undo .
    define variable v-diameter             as character    no-undo .
    define variable v-place-si             as character    no-undo .
    define variable v-tank-density-pomi    as character    no-undo .
    define variable v-prt-certif-fuel      as character    no-undo .
    define variable v-prt-norm-doc         as character    no-undo .
    define variable v-prt-num-passport     as character    no-undo .
    define variable v-prt-validity-certif  as character    no-undo .
    define variable v-prt-passport-plotn   as character    no-undo .
    define variable v-prt-num-plotn        as character    no-undo .
    define variable v-prt-date-pov-plotn   as date    no-undo .
    define variable was_setting            as logical      no-undo initial no .
    define variable ptoldfilvalue          as character    no-undo.
    define variable ptoldfiltype           as character    no-undo.
    define variable stfactplvalue          as character    no-undo initial ? .
    define variable stfactpltype           as character    no-undo initial ? .
    define variable olddensvalue           as character    no-undo initial ? .
    define variable olddenstype            as character    no-undo initial ? .
    define variable varupd-fact-qnty       as logical      no-undo initial yes .
    define variable varrevision            as logical      no-undo initial no  .
    define variable varpercrev             as decimal      no-undo initial ?   .
    define variable varauto-tank           as logical      no-undo initial no  .
    define variable varpercauto            as decimal      no-undo initial ?   .
    define variable varinv                 as logical      no-undo initial no  .
    define variable varpercinv             as decimal      no-undo initial ?   .
    define variable varinv-set             as logical      no-undo initial no  .
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-ok as logical no-undo.
    procedure return-rvs-qnty :
      define  input parameter p-doc-code            like ub.trn-doc.doc-code            no-undo .
      define  input parameter p-gds-code            like ub.goods.gds-code              no-undo .
      define  input parameter p-pl-code             like ub.rvs-line.pl-code            no-undo .
      define output parameter p-rvs-qnty-before     like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-qnty-after      like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
      define output parameter p-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
      define buffer bf_bef_rvs-doc  for ub.rvs-doc  .
      define buffer bf_aft_rvs-doc  for ub.rvs-doc  .
      define buffer bf_bef_rvs-line for ub.rvs-line .
      define buffer bf_aft_rvs-line for ub.rvs-line .
      assign
        p-rvs-qnty-before     = 0.0
        p-rvs-qnty-after      = 0.0
        p-rvs-cli-qnty-before = 0.0
        p-rvs-cli-qnty-after  = 0.0
      .
      find first bf_bef_rvs-doc no-lock
        where bf_bef_rvs-doc.rvs-type = 'перед_док':U
          and bf_bef_rvs-doc.out-code = p-doc-code
        no-error .
      if available bf_bef_rvs-doc then do:
        for each bf_bef_rvs-line no-lock
          where bf_bef_rvs-line.rvs-code = bf_bef_rvs-doc.rvs-code
            and bf_bef_rvs-line.obj-type = bf_bef_rvs-doc.obj-type
            and bf_bef_rvs-line.obj-code = bf_bef_rvs-doc.obj-code
            and bf_bef_rvs-line.gds-code = p-gds-code
        :
          if p-pl-code <> ?
            and p-pl-code <> bf_bef_rvs-line.pl-code
          then do:
            next .
          end.
          assign
            p-rvs-qnty-before     = p-rvs-qnty-before     + bf_bef_rvs-line.state-measure-qnty
            p-rvs-cli-qnty-before = p-rvs-cli-qnty-before + bf_bef_rvs-line.state-measure-cli-qnty
          .
        end.
      end.
      find first bf_aft_rvs-doc no-lock
        where bf_aft_rvs-doc.rvs-type = 'после_док':U
          and bf_aft_rvs-doc.out-code = p-doc-code
        no-error .
      if available bf_aft_rvs-doc then do:
        for each bf_aft_rvs-line no-lock
          where bf_aft_rvs-line.rvs-code = bf_aft_rvs-doc.rvs-code
            and bf_aft_rvs-line.obj-type = bf_aft_rvs-doc.obj-type
            and bf_aft_rvs-line.obj-code = bf_aft_rvs-doc.obj-code
            and bf_aft_rvs-line.gds-code = p-gds-code
        :
          if p-pl-code <> ?
            and p-pl-code <> bf_aft_rvs-line.pl-code
          then do:
            next .
          end.
          assign
            p-rvs-qnty-after     = p-rvs-qnty-after     + bf_aft_rvs-line.state-measure-qnty
            p-rvs-cli-qnty-after = p-rvs-cli-qnty-after + bf_aft_rvs-line.state-measure-cli-qnty
          .
        end.
      end.
    end procedure.
    procedure check-before :
      define input  parameter p-doc-code like ub.trn-doc.doc-code no-undo .
      define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
      define input  parameter p-pl-code  like ub.doc-pl.pl-code   no-undo .
      define buffer buf_goods         for ub.goods .
      define buffer bf_after_rvs-doc  for ub.rvs-doc  .
      define buffer bf_after_rvs-line for ub.rvs-line .
      do
      on error undo, return error substitute( "&1 (check-before). &2&3&4", vss-include-info20, return-value, chr(10), error-status :get-message ( 1 ) )
      :
        find first buf_goods no-lock
          where buf_goods.gds-code = p-gds-code
          .
        find first bf_after_rvs-doc no-lock
          where bf_after_rvs-doc.rvs-type = 'после_док':U
            and bf_after_rvs-doc.out-code = p-doc-code
          no-error .
        if available bf_after_rvs-doc then do:
          for each tt-doc-pl no-lock
          :
            if p-pl-code <> ?
              and tt-doc-pl.pl-code <> p-pl-code
            then do:
              next.
            end.
            find first bf_after_rvs-line no-lock
              where bf_after_rvs-line.rvs-code = bf_after_rvs-doc.rvs-code
                and bf_after_rvs-line.obj-type = bf_after_rvs-doc.obj-type
                and bf_after_rvs-line.obj-code = bf_after_rvs-doc.obj-code
                and bf_after_rvs-line.pl-code  = tt-doc-pl.pl-code
                and bf_after_rvs-line.gds-code = p-gds-code
              no-error .
            if not available bf_after_rvs-line then do:
              message
                "По данному товару нет заготовки для сверки <<после налива топлива>>"
                "по резервуару" tt-doc-pl.pl-code "."
                view-as alert-box error .
              return error .
            end.
            if bf_after_rvs-line.state-measure-qnty <> ? then do:
              message
                "Уже задан фактический остаток в сверке <<после налива топлива>>"
                "по резервуару" tt-doc-pl.pl-code "."
                "Следует удалить сверки и создать их снова."
                view-as alert-box error .
              return error .
            end.
            if ptrlprop-olddens <> true
              and bf_after_rvs-line.state-density <> ?
              and buf_goods.unit-base <> buf_goods.unit-cli
            then do:
              message
                "Уже задана фактическая плотность в сверке <<после налива топлива>>"
                "по резервуару" tt-doc-pl.pl-code "."
                "Следует удалить сверки и создать их снова."
                view-as alert-box error .
              return error .
            end.
          end.
        end.
        else do:
          message "Не создана сверка <<после налива топлива>>." view-as alert-box error .
          return error .
        end.
      end.
    end procedure.
    procedure check-after :
      define input  parameter p-doc-code like ub.trn-doc.doc-code no-undo .
      define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
      define input  parameter p-pl-code  like ub.doc-pl.pl-code   no-undo .
      define buffer buf_before_rvs-doc  for ub.rvs-doc  .
      define buffer buf_before_rvs-line for ub.rvs-line .
      do
      on error undo, return error return-value
      :
        find first buf_before_rvs-doc no-lock
          where buf_before_rvs-doc.rvs-type = 'перед_док':U
            and buf_before_rvs-doc.out-code = p-doc-code
          no-error .
        if available buf_before_rvs-doc then do:
          for each tt-doc-pl no-lock
          on error undo, return error return-value
          :
            if p-pl-code <> ?
              and tt-doc-pl.pl-code <> p-pl-code
            then do:
              next.
            end.
            find first buf_before_rvs-line no-lock
              where buf_before_rvs-line.rvs-code = buf_before_rvs-doc.rvs-code
                and buf_before_rvs-line.obj-type = buf_before_rvs-doc.obj-type
                and buf_before_rvs-line.obj-code = buf_before_rvs-doc.obj-code
                and buf_before_rvs-line.pl-code  = tt-doc-pl.pl-code
                and buf_before_rvs-line.gds-code = p-gds-code
              no-error .
            if not available buf_before_rvs-line then do:
              message
                "По данному товару нет заготовки для сверки <<до налива топлива>>"
                "по резервуару" tt-doc-pl.pl-code "."
                view-as alert-box error .
              return error .
            end.
            if is-gas(buf_before_rvs-line.gds-code) then next.
            run placelib_get-attr(input "place-virtual"
                                 ,input tt-doc-pl.obj-code
                                 ,input tt-doc-pl.obj-type
                                 ,input tt-doc-pl.pl-code
                                 ,output v-value
                                 ,output v-ok) no-error.
            is-vir = if (v-ok and logical(v-value)) then true else false.
            if is-vir then next.
            if buf_before_rvs-line.state-measure-qnty = ?
            then do:
              message
                "Не задан фактический остаток в сверке <<до налива топлива>>"
                "по резервуару" tt-doc-pl.pl-code "." skip
                "Следует удалить сверки и создать их снова."
                view-as alert-box error .
              return error .
            end.
            if buf_before_rvs-line.state-density = ?
            then do:
              message
                "Не задана фактическая плотность в сверке <<до налива топлива>>"
                "по резервуару" tt-doc-pl.pl-code "." skip
                "Следует удалить сверки и создать их снова."
                view-as alert-box error .
              return error .
            end.
          end.
        end.
        else do:
          message "Не создана сверка <<до налива топлива>>." view-as alert-box error .
          return error .
        end.
      end.
    end procedure.
    procedure action-rvs-line :
      define input parameter p-action      as   character           no-undo .
      define input parameter p-action-type as   character           no-undo .
      define input parameter p-rvs-type    like ub.rvs-doc.rvs-type no-undo .
      block_tr:
      do transaction
      on error  undo block_tr, return error substitute( "&1 (action-rvs-line). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on stop   undo block_tr, return error substitute( "&1 (action-rvs-line). stop", vss-workfile )
      on endkey undo block_tr, return error substitute( "&1 (action-rvs-line). endkey", vss-workfile )
      :
        define variable v-pl-code      like ub.place.pl-code    no-undo .
        define variable v-rvs-code     like ub.rvs-doc.rvs-code no-undo .
        define variable v-act-name     as   character           no-undo .
        define variable v-log          as   logical             no-undo .
        define variable v-count-doc-pl as   integer             no-undo .
        define variable is-rvs-place   as   logical             no-undo .
        define variable varnum         as   integer             no-undo.
        define variable varcur-rvs     as   integer             no-undo.
        define variable v-today        as   date                no-undo.
        define variable v-time         as   integer             no-undo.
        define buffer buf_rvs-doc     for ub.rvs-doc .
        define buffer buf_rvs-line    for ub.rvs-line .
        define buffer buf_place       for ub.place .
        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-density         like ub.rvs-line.state-density          no-undo .
        define variable v-asi-ip  as character no-undo .
        define variable v-asi-port as character no-undo .
        define variable v-asi-type as character no-undo .
        define variable v-attr-type as character no-undo .
        assign
          v-pl-code = ?
        .
        find first buf_rvs-doc exclusive-lock
          where buf_rvs-doc.rvs-type = p-rvs-type
            and buf_rvs-doc.out-code = t-doc.doc-code
          no-error .
        if not available buf_rvs-doc then do:
          message
            "Не зафиксированы книжные кол-ва и не созданы документы сверки по складскому документу." skip
            view-as alert-box error .
          undo block_tr, return error .
        end.
        if p-rvs-type <> 'после_док':U
          and p-rvs-type <> 'перед_док':U
        then do:
          message
            "Ошибка задания параметров." skip
            "Неизвестный для документа прихода тип сверки." skip
            "Тип сверки" p-rvs-type skip
            "Код сверки" buf_rvs-doc.rvs-code skip
            view-as alert-box error .
          undo block_tr, return error .
        end.
        find first tt-doc-pl no-lock
          no-error .
        if not available tt-doc-pl then do:
          message
            substitute( "Товар &1 не распределен по местам хранения.", buf_goods.gds-code ) skip
            view-as alert-box error .
          undo block_tr, return error .
        end.
        assign
          v-count-doc-pl = 0
          v-pl-code      = ?
        .
        for each tt-doc-pl no-lock
        on error undo block_tr, return error return-value
        :
          find first buf_rvs-line no-lock
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
              and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
              and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
              and buf_rvs-line.pl-code  = tt-doc-pl.pl-code
              and buf_rvs-line.gds-code = tt-doc-pl.gds-code
            no-error .
          if not available buf_rvs-line then do:
            message
              "Не найдена строка сверки:" skip
              substitute( "товар &1", tt-doc-pl.gds-code ) skip
              substitute( "место хранения &1", tt-doc-pl.pl-code ) skip
              view-as alert-box error .
            undo block_tr, return error .
          end.
          assign
            v-count-doc-pl = v-count-doc-pl + 1
            v-pl-code      = buf_rvs-line.pl-code
          .
        end.
        if v-count-doc-pl > 1
          or v-pl-code = ?
        then do:
          run plgdsfnd in this-procedure
            ( input yes
            ,input buf_rvs-doc.obj-type
            ,input buf_rvs-doc.obj-code
            ,input buf_goods.gds-code
            ,output is-rvs-place
            ,output v-pl-code
            ) no-error .
          if error-status :error then do:
            message
              substitute( "Ошибка при выборе места хранения по товару &1.", buf_goods.gds-code ) skip
              return-value skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo block_tr, return error .
          end.
        end.
        find first buf_rvs-line
          where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
            and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
            and buf_rvs-line.pl-code  = v-pl-code
            and buf_rvs-line.gds-code = buf_goods.gds-code
          no-error.
        if not available buf_rvs-line then do:
          message
            substitute( "Не найдена строка сверки по резервуару &1", v-pl-code ) skip
            view-as alert-box error .
          undo block_tr, return error .
        end.
        case p-action :
          when 'ИЗМЕНЕНИЕ':U then do:
              find buf_place no-lock
              where buf_place.obj-type = t-doc.obj-type
                and buf_place.obj-code = t-doc.obj-code
                and buf_place.pl-code  = v-pl-code
              .
            if p-action-type = "meas" or buf_place.is-meas <> yes then
            do:
              assign
                v-act-name = 'actn_rvs-on-doc_cr-revision':U
              .
            end.
            else
            do:
              assign
                v-act-name = 'actn_rvs-on-doc_upd-revision':U
              .
            end.
            case p-rvs-type :
              when 'перед_док':U then do:
                run check-before in this-procedure
                  ( input t-doc.doc-code
                   ,input buf_goods.gds-code
                   ,input v-pl-code
                  ) no-error .
                if error-status :error then do:
                  undo block_tr, return error .
                end.
              end.
              when 'после_док':U then do:
                run check-after in this-procedure
                  ( input t-doc.doc-code
                   ,input buf_goods.gds-code
                   ,input v-pl-code
                  ) no-error .
                if error-status :error then do:
                  undo block_tr, return error .
                end.
              end.
            end case .
          end.
          when 'ПРОСМОТР':U then do:
            assign
              v-act-name = 'actn_rvs-on-doc_lookup':U
            .
          end.
        end case.
        if v-act-name <> "":U then do:
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  v-act-name
    ,input  'object':U
    ,input  buf_rvs-doc.host-code
    ,input  buf_rvs-doc.obj-type
    ,input  buf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    ) no-error .
end.
          if v-log <> yes then do:
            undo block_tr, return error .
          end.
        end.
        find first buf_rvs-line exclusive-lock
          where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            and buf_rvs-line.obj-type = t-doc.obj-type
            and buf_rvs-line.obj-code = t-doc.obj-code
            and buf_rvs-line.pl-code  = v-pl-code
            and buf_rvs-line.gds-code = buf_goods.gds-code
          .
        case p-action-type :
          when "meas":U then do:
            find buf_place no-lock
              where buf_place.obj-type = t-doc.obj-type
                and buf_place.obj-code = t-doc.obj-code
                and buf_place.pl-code  = v-pl-code
              .
            if buf_place.is-meas <> yes then do:
              message
                substitute( 'Резервуар &1 не измеряется приборами.', buf_place.pl-code)
                view-as alert-box error .
              undo block_tr, return error .
            end.
            if buf_place.loc1 = "":U
              or buf_place.loc1 = ?
            then do:
              message
                substitute( 'Не указан локальный код на складском месте &1 .', buf_place.pl-code )
                view-as alert-box error .
              undo block_tr, return error .
            end.
            for each tt-meas
            :
              delete tt-meas .
            end.
            create tt-meas .
            assign
              tt-meas.obj-type = t-doc.obj-type
              tt-meas.obj-code = t-doc.obj-code
              tt-meas.pl-code  = v-pl-code
            .
            find first sys-ctrl no-lock.
            run db-attr-value(sys-ctrl.db,"AsiIp",output v-asi-ip,output v-attr-type).
            run db-attr-value(sys-ctrl.db,"AsiPort",output v-asi-port,output v-attr-type).
            run db-attr-value(sys-ctrl.db,"AsiType",output v-asi-type,output v-attr-type).
            if trim(v-asi-ip) <> ''
            and trim(v-asi-port) <> ''
            and trim(v-asi-type) <> ''
            then do :
              case v-asi-type :
                when "1"
                then do :
                  varcur-rvs = 2 .
                end.
                when "2"
                then do :
                  varcur-rvs = 3 .
                end.
              end case .
            end.
            else do :
              if ptoldfilvalue = "yes":U then do:
                run gbl/d-askw.w
                  ( input "Выбор источника данных с информацией по резервуарам"
                  ,input "Будем читать текущие данные с резервуаров или возьмем данные из файла?"
                  ,input "|^"
                  ,input "Текущие данные|Из файлов|Отмена"
                  ,input "Запускается программа для обращения к датчикам резервуаров|Берутся уже сохраненные данные из файла|Ничего не делаем"
                  ,input 1
                  ,input 3
                  ,output varnum
                  ) .
                case varnum :
                  when 1 then do:
                    assign
                      varcur-rvs = 1
                    .
                  end.
                  when 2  then do:
                    assign
                      varcur-rvs = 0
                    .
                  end.
                  when 3 then do:
                    return .
                  end.
                end case.
              end.
              else do:
                assign
                  varcur-rvs = 1
                .
              end.
            end.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsplace in g#lib-rvs ( input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              yes ,
                      input              varcur-rvs ,
                      input              yes ,
                      input              no ,
                      input-output table tt-meas-file ,
                      input-output table tt-meas ) no-error .
            if error-status :error then do:
              message
                "Ошибка при получении данных с приборов на резервуарах." skip( 0 )
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo block_tr, return error .
            end.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_fill1plc in g#lib-rvs ( input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              v-pl-code ,
                      input              recid(buf_rvs-line) ,
                      input              buf_rvs-line.rvs-prev-code ,
                      input-output table tt-meas ) no-error .
            if error-status :error then do:
              message
                "Ошибка при заполнении данных с приборов на резервуарах." skip( 0 )
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo block_tr, return error .
            end.
            run cur-time in this-procedure
              ( output v-today
              , output v-time
              ) .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-today
  )  .
            assign
              buf_rvs-line.real-date = v-today
              buf_rvs-line.real-time = v-time
            .
            if p-rvs-type = 'перед_док':U  then do:
              if v-prt-start-real-date > buf_rvs-line.real-date
                or ( v-prt-start-real-date = buf_rvs-line.real-date
                    and v-prt-start-real-time > buf_rvs-line.real-time
                  )
              then do:
                assign
                  v-prt-start-real-date = buf_rvs-line.real-date
                  v-prt-start-real-time = buf_rvs-line.real-time
                .
              end.
            end.
            else do:
              if v-prt-end-real-date < buf_rvs-line.real-date
                or ( v-prt-end-real-date = buf_rvs-line.real-date
                    and v-prt-end-real-time < buf_rvs-line.real-time
                  )
              then do:
                assign
                  v-prt-end-real-date  = buf_rvs-line.real-date
                  v-prt-end-real-time  = buf_rvs-line.real-time
                .
              end.
            end.
          end.
          when "edit":U then do:
            if not error-status :error
               and is-gas(buf_goods.gds-code) then do:
                run str/rvs-lin-mask.w
                  (input  parparentproc
                  ,input  recid( buf_rvs-line )
                  ,input  p-action
                  ,input  substitute(" # &1 товар &2 &3 &4  складское место &5"
                                    ,buf_rvs-doc.rvs-code
                                    ,buf_goods.artic
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,v-pl-code)) no-error.
            end.
            else
            if not error-status :error
            and is-sug(buf_goods.gds-code) then do:
                run str/rvs-lin-sug.w
                  (input  parparentproc
                  ,input  recid( buf_rvs-line )
                  ,input  p-action
                  ,input  substitute(" # &1 товар &2 &3 &4  складское место &5"
                                    ,buf_rvs-doc.rvs-code
                                    ,buf_goods.artic
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,v-pl-code)) no-error.
            end.
            else do:
                run str/rvs-lin.w
                  (input  parparentproc
                  ,input  recid( buf_rvs-line )
                  ,input  p-action
                  ,input  substitute(" # &1 товар &2 &3 &4  складское место &5"
                                    ,buf_rvs-doc.rvs-code
                                    ,buf_goods.artic
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,v-pl-code)) no-error.
            end.
            if error-status :error then do:
              message
                "Ошибка при редактировании строки сверки." skip
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo block_tr, return error .
            end.
            if return-value = "cancel":U
              and p-action <> 'ПРОСМОТР':U
            then do:
              undo block_tr, return error .
            end.
          end.
        end case.
        run placelib_get-attr(input "place-virtual"
                                 ,input buf_rvs-line.obj-code
                                 ,input buf_rvs-line.obj-type
                                 ,input buf_rvs-line.pl-code
                                 ,output v-value
                                 ,output v-ok) no-error.
        is-vir = if (v-ok and logical(v-value)) then true else false.
        if not is-gas(buf_goods.gds-code) and not is-vir then do:
            if p-action = 'ИЗМЕНЕНИЕ':U then do:
              if p-action-type = "meas":U then do:
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclcln in g#lib-rvs ( input recid(buf_rvs-line) ) no-error .
                if error-status :error then do:
                  message
                    "Ошибка при пересчете строки документа сверки." skip
                    return-value skip
                    error-status :get-message(1) skip
                    view-as alert-box error .
                  undo block_tr, return error .
                end.
              end.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclchd in g#lib-rvs ( input recid(buf_rvs-doc) ,
                      input false ) no-error .
              if error-status :error then do:
                message
                  "Ошибка при пересчете документа сверки." skip
                  return-value skip
                  error-status :get-message(1) skip
                  view-as alert-box error .
                undo block_tr, return error .
              end.
              run return-rvs-qnty in this-procedure
                ( input t-doc.doc-code
                 ,input buf_goods.gds-code
                 ,input v-pl-code
                 ,output v-rvs-qnty-before
                 ,output v-rvs-qnty-after
                 ,output v-rvs-cli-qnty-before
                 ,output v-rvs-cli-qnty-after
                ) no-error .
              if error-status :error then do:
                undo block_tr, return error return-value .
              end.
              if p-rvs-type = 'после_док':U then do:
                if v-rvs-qnty-after = ?
                  or v-rvs-qnty-after = 0
                then do:
                  message
                    "Не задано количество по сверке <<после_док>>"
                    "по резервуару" v-pl-code "."
                    view-as alert-box error .
                  undo block_tr, return error .
                end.
                if v-rvs-cli-qnty-after = ?
                  or v-rvs-cli-qnty-after = 0
                then do:
                  message
                    "Не задана плотность в сверке <<после_док>>"
                    "по резервуару" v-pl-code "."
                    view-as alert-box error .
                  undo block_tr, return error .
                end.
              end.
              if v-rvs-qnty-after <> ?
                and v-rvs-qnty-after <> 0
              then do:
                if v-rvs-qnty-after - v-rvs-qnty-before <= 0
                  or v-rvs-qnty-after - v-rvs-qnty-before = ?
                then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", v-pl-code ) skip
                    substitute( "Количество залитого топлива: &1 (&2).", v-rvs-qnty-after - v-rvs-qnty-before, buf_goods.unit-base ) skip
                    view-as alert-box .
                  undo block_tr, return error .
                end.
                if v-rvs-cli-qnty-after - v-rvs-cli-qnty-before <= 0
                  or v-rvs-cli-qnty-after - v-rvs-cli-qnty-before = ?
                then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", v-pl-code ) skip
                    substitute( "Количество залитого топлива: &1 (&2).", v-rvs-cli-qnty-after - v-rvs-cli-qnty-before, buf_goods.unit-cli ) skip
                    view-as alert-box .
                  undo block_tr, return error .
                end.
                assign
                  v-rvs-density = (v-rvs-cli-qnty-after - v-rvs-cli-qnty-before) / (v-rvs-qnty-after - v-rvs-qnty-before)
                .
                if Valid-Density( v-rvs-density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", v-pl-code ) skip
                    substitute( "Плотность залитого топлива: &1.", v-rvs-density ) skip
                    view-as alert-box .
                  undo block_tr, return error .
                end.
              end.
            end.
        end.
      end.
    end procedure.
    procedure proc-b-addinfo :
      define input        parameter parParentProc          as   handle                   no-undo .
      define input        parameter p-mode                 as   character                no-undo .
      define input        parameter p-doc-code             like ub.doc-line.doc-code     no-undo .
      define input        parameter p-gds-code             like ub.goods.gds-code        no-undo .
      define input        parameter p-stfactplvalue        as   character                no-undo .
      define input        parameter p-auto-tank            as   logical                  no-undo .
      define input        parameter p-fact-edit            as   logical                  no-undo .
      define input        parameter p-doc-qnty             like ub.doc-line.doc-qnty     no-undo .
      define input        parameter p-doc-density          like ub.doc-line.doc-density  no-undo .
      define input-output parameter p-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
      define input-output parameter p-new-density          like ub.doc-line.fact-density no-undo .
      define input-output parameter p-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
      define input-output parameter p-prt-car-num          as   character                no-undo .
      define input-output parameter p-prt-car-vol          as   character                no-undo .
      define input-output parameter p-prt-tests            as   character                no-undo .
      define input-output parameter p-prt-autoent-obj-type as   character                no-undo .
      define input-output parameter p-prt-autoent-obj-code as   character                no-undo .
      define input-output parameter p-prt-item-pour        as   character                no-undo .
      define input-output parameter p-prt-time-pour        as   character                no-undo .
      define input-output parameter p-prt-tank-vol         as   character                no-undo .
      define input-output parameter p-prt-tank-temp        as   character                no-undo .
      define input-output parameter p-prt-tank-water       as   character                no-undo .
      define input-output parameter p-prt-tank-density     as   character                no-undo .
      define input-output parameter p-prt-tank-weight      as   character                no-undo .
      define input-output parameter p-prt-time-income      as   character                no-undo .
      define input-output parameter p-prt-start-real-date  like ub.rvs-line.real-date    no-undo .
      define input-output parameter p-prt-start-real-time  like ub.rvs-line.real-time    no-undo .
      define input-output parameter p-prt-end-real-date    like ub.rvs-line.real-date    no-undo .
      define input-output parameter p-prt-end-real-time    like ub.rvs-line.real-time    no-undo .
      define input-output parameter p-prt-mouth            as   character                no-undo .
      define input-output parameter p-prt-fio              as   character                no-undo .
      define input-output parameter p-prt-ptbotype         as   character                no-undo .
      define input-output parameter p-prt-ptbocode         as   character                no-undo .
      define input-output parameter p-prt-a-b-tarir        as   character                no-undo .
      define input-output parameter p-diameter             as   character                no-undo .
      define input-output parameter p-place-si             as   character                no-undo .
      define input-output parameter p-tank-density-pomi    as   character                no-undo .
      define input-output parameter p-prt-certif-fuel      as character    no-undo .
      define input-output parameter p-prt-norm-doc         as character    no-undo .
      define input-output parameter p-prt-num-passport     as character    no-undo .
      define input-output parameter p-prt-validity-certif  as character    no-undo .
      define input-output parameter p-prt-passport-plotn   as   character             no-undo .
      define input-output parameter p-prt-num-plotn        as   character             no-undo .
      define input-output parameter p-prt-date-pov-plotn   like ub.rvs-line.real-date no-undo .
      do
      on error  undo, return error substitute( "&1 (proc-b-addinfo). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1 (proc-b-addinfo). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (proc-b-addinfo). endkey", vss-workfile )
      :
        define buffer buf_rvs-doc  for ub.rvs-doc   .
        define buffer buf_rvs-line for ub.rvs-line  .
        define buffer buf_goods    for ub.goods .
        define variable v-new-fact-qnty     like ub.doc-line.fact-qnty    no-undo .
        define variable v-new-density       like ub.doc-line.fact-density no-undo .
        define variable v-new-cli-fact-qnty like ub.doc-line.fact-qnty    no-undo .
        define variable v-chg               as   logical                  no-undo .
        define variable v-log               as   logical                  no-undo .
        define variable v-st-doc            as   logical                  no-undo .
        define variable v-setting           as   logical                  no-undo .
        block_tr:
        do transaction
        on error  undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        on stop   undo block_tr, return error substitute( "&1. stop", vss-workfile )
        on endkey undo block_tr, return error substitute( "&1. endkey", vss-workfile )
        :
          find first buf_goods no-lock
            where buf_goods.gds-code = p-gds-code
            .
          if p-prt-start-real-date = ?
            or p-prt-start-real-time = ?
          then do:
            find first buf_rvs-doc
              where buf_rvs-doc.rvs-type = 'перед_док':U
                and buf_rvs-doc.out-code = p-doc-code
              no-error .
            if available buf_rvs-doc then do:
              for each buf_rvs-line
                where buf_rvs-line.gds-code = p-gds-code
                  and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-type
                  and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                  and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
              on error undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
              :
                if buf_rvs-line.real-date <> ?
                  and buf_rvs-line.real-time <> ?
                  and ( p-prt-start-real-date > buf_rvs-line.real-date
                        or ( p-prt-start-real-date = buf_rvs-line.real-date
                            and p-prt-start-real-time > buf_rvs-line.real-time
                          )
                      )
                then do:
                  assign
                    p-prt-start-real-date = buf_rvs-line.real-date
                    p-prt-start-real-time = buf_rvs-line.real-time
                  .
                end.
              end.
            end.
          end.
          if p-prt-end-real-date = ?
            or p-prt-end-real-time = ?
          then do:
            find first buf_rvs-doc
              where buf_rvs-doc.rvs-type = 'после_док':U
                and buf_rvs-doc.out-code = p-doc-code
              no-error .
            if available buf_rvs-doc then do:
              for each buf_rvs-line
                where buf_rvs-line.gds-code = p-gds-code
                  and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                  and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                  and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
              on error undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
              :
                if buf_rvs-line.real-date <> ?
                  and buf_rvs-line.real-time <> ?
                  and ( p-prt-end-real-date < buf_rvs-line.real-date
                        or ( p-prt-end-real-date = buf_rvs-line.real-date
                            and p-prt-end-real-time < buf_rvs-line.real-time
                          )
                      )
                then do:
                  assign
                    p-prt-end-real-date = buf_rvs-line.real-date
                    p-prt-end-real-time = buf_rvs-line.real-time
                  .
                end.
              end.
            end.
          end.
          run str/in-laddout.w
            ( input        parParentProc
             ,input        p-mode
             ,input        p-doc-code
             ,input        p-gds-code
             ,input-output p-prt-car-num
             ,input-output p-prt-car-vol
             ,input-output p-prt-tests
             ,input-output p-prt-autoent-obj-type
             ,input-output p-prt-autoent-obj-code
             ,input-output p-prt-item-pour
             ,input-output p-prt-time-pour
             ,input-output p-prt-tank-vol
             ,input-output p-prt-tank-temp
             ,input-output p-prt-tank-water
             ,input-output p-prt-tank-density
             ,input-output p-prt-tank-weight
             ,input-output p-prt-time-income
             ,input-output p-prt-start-real-date
             ,input-output p-prt-start-real-time
             ,input-output p-prt-end-real-date
             ,input-output p-prt-end-real-time
             ,input-output p-prt-mouth
             ,input-output p-prt-fio
             ,input-output p-prt-ptbotype
             ,input-output p-prt-ptbocode
             ,input-output p-prt-a-b-tarir
             ,input-output p-diameter
             ,input-output p-place-si
             ,input-output p-tank-density-pomi
             ,input-output p-prt-certif-fuel
             ,input-output p-prt-norm-doc
             ,input-output p-prt-num-passport
             ,input-output p-prt-validity-certif
             ,input-output p-prt-passport-plotn
             ,input-output p-prt-num-plotn
             ,input-output p-prt-date-pov-plotn
             ,      output v-setting
            ) no-error .
          if error-status :error then do:
            undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
          end.
          if v-setting = true
            and p-mode <> 'ПРОСМОТР':U
            and p-stfactplvalue <> "":U
            and p-auto-tank = true
          then do:
            assign
              v-new-fact-qnty = p-new-fact-qnty
            .
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_stfactqt in g#lib-calc
  ( input        p-stfactplvalue
  , input        p-doc-qnty
  , input        p-doc-density
  , input        0.00
  , input        0.00
  , input        p-prt-tank-vol
  , input        decimal(p-prt-tank-density)
  , input        no
  , input-output v-new-fact-qnty
  ,       output v-chg
  ,       output v-st-doc
  )              no-error
.
            if error-status :error then do:
              undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
            end.
            if p-new-fact-qnty <> v-new-fact-qnty
              or v-chg       =  yes
              or v-st-doc    =  yes
            then do:
              assign
                v-new-density = ( if v-st-doc = yes then p-doc-density else decimal( p-prt-tank-density ) )
                v-log         = yes
              .
              if decimal( p-prt-tank-vol ) <> p-new-fact-qnty
                or v-new-density <> p-new-density
              then do:
                if p-fact-edit = true then do:
                  message
                    substitute( "По результатам измерения автоцистерны фактическое кол-во необходимо изменить." ) skip
                    substitute( "Будем менять фактические" ) skip
                    substitute( "количество на &1 (&2),", v-new-fact-qnty, buf_goods.unit-base ) skip
                    substitute( "плотность на &1 ?", v-new-density ) skip
                    view-as alert-box question buttons yes-no update v-log .
                end.
                else do:
                  message
                    substitute( "По результатам измерения фактическое кол-во товара изменяется на &1 (&2),", v-new-fact-qnty, buf_goods.unit-base ) skip
                    substitute( "фактическая плотность на &1.", v-new-density ) skip
                    view-as alert-box information .
                end.
              end.
              if v-log = yes then do:
                assign
                  p-new-fact-qnty     = v-new-fact-qnty
                  p-new-density       = v-new-density
                  p-new-cli-fact-qnty = p-new-fact-qnty * p-new-density
                .
              end.
            end.
          end.
        end.
      end.
    end procedure.
    procedure chkdcrvs :
      define input  parameter p-doc-code like ub.trn-doc.doc-code no-undo .
      define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
      define output parameter p-ok       as   logical             no-undo .
      do
      on error undo, return error return-value
      :
        define buffer buf-before_rvs-doc  for ub.rvs-doc  .
        define buffer buf-before_rvs-line for ub.rvs-line .
        define buffer buf-after_rvs-doc   for ub.rvs-doc  .
        define buffer buf-after_rvs-line  for ub.rvs-line .
        assign
          p-ok = false
        .
        find first tt-doc-pl no-lock
          no-error .
        if not available tt-doc-pl then do:
          return error substitute( 'Документ "&1", товар &2: нет разбивки по местам хранения.', p-doc-code, p-gds-code ) .
        end.
        find first buf-before_rvs-doc no-lock
          where buf-before_rvs-doc.rvs-type = 'перед_док':U
            and buf-before_rvs-doc.out-code = p-doc-code
          no-error .
        if not available buf-before_rvs-doc then do:
          return substitute( 'По документу "&1" нет сверки <<до налива топлива>>.', p-doc-code ).
        end.
        find first buf-after_rvs-doc no-lock
          where buf-after_rvs-doc.rvs-type = 'после_док':U
            and buf-after_rvs-doc.out-code = p-doc-code
          no-error .
        if not available buf-after_rvs-doc then do:
          return substitute( 'По документу "&1" нет сверки <<после налива топлива>>.', p-doc-code ).
        end.
        for each tt-doc-pl no-lock
        on error undo, return error return-value
        :
          find first buf-before_rvs-line no-lock
            where buf-before_rvs-line.rvs-code = buf-before_rvs-doc.rvs-code
              and buf-before_rvs-line.obj-type = buf-before_rvs-doc.obj-type
              and buf-before_rvs-line.obj-code = buf-before_rvs-doc.obj-code
              and buf-before_rvs-line.pl-code  = tt-doc-pl.pl-code
              and buf-before_rvs-line.gds-code = tt-doc-pl.gds-code
            no-error .
          if not available buf-before_rvs-line then do:
            return substitute( 'По документу "&1" для товара &2 на месте хранения &3 нет строки сверки <<до налива топлива>>.'
                               ,p-doc-code
                               ,p-gds-code
                               ,tt-doc-pl.pl-code
                             ).
          end.
          find first buf-after_rvs-line no-lock
            where buf-after_rvs-line.rvs-code = buf-after_rvs-doc.rvs-code
              and buf-after_rvs-line.obj-type = buf-after_rvs-doc.obj-type
              and buf-after_rvs-line.obj-code = buf-after_rvs-doc.obj-code
              and buf-after_rvs-line.pl-code  = tt-doc-pl.pl-code
              and buf-after_rvs-line.gds-code = tt-doc-pl.gds-code
            no-error .
          if not available buf-after_rvs-line then do:
            return substitute( 'По документу "&1" для товара &2 на месте хранения &3 нет строки сверки <<после налива топлива>>.'
                               ,p-doc-code
                               ,p-gds-code
                               ,tt-doc-pl.pl-code
                             ).
          end.
          if is-gas(buf-after_rvs-line.gds-code) then next.
          run placelib_get-attr(input "place-virtual"
                                 ,input buf-after_rvs-line.obj-code
                                 ,input buf-after_rvs-line.obj-type
                                 ,input buf-after_rvs-line.pl-code
                                 ,output v-value
                                 ,output v-ok) no-error.
          is-vir = if (v-ok and logical(v-value)) then true else false.
          if is-vir then next.
          if buf-before_rvs-line.state-measure-qnty = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задан фактический остаток (&5) в сверке <<до налива топлива>>.'
                               ,p-doc-code
                               ,p-gds-code
                               ,tt-doc-pl.pl-code
                               ,chr(10)
                               ,buf_goods.unit-base
                             ).
          end.
          if buf-before_rvs-line.state-measure-cli-qnty = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задан фактический остаток (&5) в сверке <<до налива топлива>>.'
                               ,p-doc-code
                               ,p-gds-code
                               ,tt-doc-pl.pl-code
                               ,chr(10)
                               ,buf_goods.unit-cli
                             ).
          end.
          if buf-before_rvs-line.state-density = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задана плотность в сверке <<до налива топлива>>.'
                                    ,p-doc-code
                                    ,p-gds-code
                                    ,tt-doc-pl.pl-code
                                    ,chr(10)
                                  ).
          end.
          if buf-after_rvs-line.state-measure-qnty = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задан фактический остаток (&5) в сверке <<после налива топлива>>.'
                                    ,p-doc-code
                                    ,p-gds-code
                                    ,tt-doc-pl.pl-code
                                    ,chr(10)
                                    ,buf_goods.unit-base
                                  ).
          end.
          if buf-after_rvs-line.state-measure-cli-qnty = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задан фактический остаток (&5) в сверке <<после налива топлива>>.'
                                    ,p-doc-code
                                    ,p-gds-code
                                    ,tt-doc-pl.pl-code
                                    ,chr(10)
                                    ,buf_goods.unit-cli
                                  ).
          end.
          if buf-after_rvs-line.state-density = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задана плотность в сверке <<после налива топлива>>.'
                                    ,p-doc-code
                                    ,p-gds-code
                                    ,tt-doc-pl.pl-code
                                    ,chr(10)
                                  ).
          end.
        end.
        assign
          p-ok = true
        .
      end.
    end procedure.
    procedure local-state-fact-rvs :
      define input        parameter p-doc-code             like ub.trn-doc.doc-code      no-undo .
      define input        parameter p-gds-code             like ub.goods.gds-code        no-undo .
      define input        parameter p-stfactplvalue        as   character                no-undo .
      define input        parameter p-revision             as   logical                  no-undo .
      define input        parameter p-fact-edit            as   logical                  no-undo .
      define input        parameter p-doc-qnty             like ub.doc-line.doc-qnty     no-undo .
      define input        parameter p-doc-density          like ub.doc-line.doc-density  no-undo .
      define input-output parameter p-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
      define input-output parameter p-new-density          like ub.doc-line.fact-density no-undo .
      define input-output parameter p-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
      do
      on error undo, return error return-value
      :
        define variable v-new-fact-qnty       like ub.doc-line.fact-qnty              no-undo .
        define variable v-new-density         like ub.doc-line.doc-density            no-undo .
        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-log                 as   logical                            no-undo .
        define variable v-chg                 as   logical                            no-undo .
        define variable v-st-doc              as   logical                            no-undo .
        if p-stfactplvalue <> "":U
          and p-revision = true
        then do:
          assign
            v-new-fact-qnty = p-new-fact-qnty
          .
          run return-rvs-qnty in this-procedure
            (  input p-doc-code
              ,input p-gds-code
              ,input ?
              ,output v-rvs-qnty-before
              ,output v-rvs-qnty-after
              ,output v-rvs-cli-qnty-before
              ,output v-rvs-cli-qnty-after
            ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
          assign
            v-new-density = ( v-rvs-cli-qnty-after - v-rvs-cli-qnty-before ) / ( v-rvs-qnty-after - v-rvs-qnty-before )
          .
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_stfactqt in g#lib-calc
  ( input        p-stfactplvalue
  , input        p-doc-qnty
  , input        p-doc-density
  , input        v-rvs-qnty-before
  , input        v-rvs-qnty-after
  , input        0.00
  , input        0.00
  , input        no
  , input-output v-new-fact-qnty
  ,       output v-chg
  ,       output v-st-doc
  )              no-error
.
          if error-status :error then do:
            return error return-value .
          end.
          if v-new-fact-qnty <> p-new-fact-qnty
            or v-chg = true
            or v-st-doc = true
          then do:
            if v-st-doc = true
              or v-new-density = ?
            then do:
              assign
                v-new-density = p-doc-density
              .
            end.
            if v-new-fact-qnty <> p-new-fact-qnty
              or v-new-density <> p-new-density
            then do:
              assign
                v-log = true
              .
              if p-fact-edit = true then do:
                message
                  substitute( "По результатам измерения резервуаров фактическое кол-во необходимо изменить." ) skip
                  substitute( "Будем менять фактические" ) skip
                  substitute( "количество на &1 (&2),", v-new-fact-qnty, buf_goods.unit-base ) skip
                  substitute( "плотность на &1 ?", v-new-density ) skip
                  view-as alert-box question buttons yes-no update v-log .
              end.
              else do:
                message
                  substitute( "По результатам измерения фактическое кол-во товара изменяется на &1 (&2),", v-new-fact-qnty, buf_goods.unit-base ) skip
                  substitute( "фактическая плотность на &1.", v-new-density ) skip
                  view-as alert-box information .
              end.
              if v-log = true then do:
                assign
                  p-new-fact-qnty     = v-new-fact-qnty
                  p-new-density       = v-new-density
                  p-new-cli-fact-qnty = p-new-fact-qnty * p-new-density
                .
              end.
            end.
          end.
        end.
      end.
    end procedure.
    procedure eq-qnty-rvs-pl :
      define input        parameter p-doc-code             like ub.trn-doc.doc-code      no-undo .
      define input        parameter p-gds-code             like ub.goods.gds-code        no-undo .
      define input        parameter p-fact-edit            as   logical                  no-undo .
      define input-output parameter p-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
      define input-output parameter p-new-density          like ub.doc-line.fact-density no-undo .
      define input-output parameter p-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
      define output       parameter p-ok                   as   logical                  no-undo .
      do
      on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1. stop", vss-workfile )
      on endkey undo, return error substitute( "&1. endkey", vss-workfile )
      :
        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-count-pl      as integer   no-undo .
        define variable v-message       as character no-undo .
        define variable v-tot-qnty-pl   as decimal   no-undo .
        define variable v-tot-qnty-rvs  as decimal   no-undo .
        define variable v-add-option-bt as character no-undo .
        define variable v-add-option-ps as character no-undo .
        define variable v-answ-num      as integer   no-undo .
        define variable v-edit-doc-pl   as integer   no-undo .
        define variable v-set-doc-pl    as integer   no-undo .
        define buffer buf_goods for ub.goods .
        find first buf_goods no-lock
          where buf_goods.gds-code = p-gds-code
          .
        assign
          p-ok           = true
          v-message      = "":U
          v-count-pl     = 0
          v-tot-qnty-rvs = 0.0
          v-tot-qnty-pl  = 0.0
        .
        for each tt-doc-pl no-lock
        on error undo, return error return-value
        :
          run return-rvs-qnty in this-procedure
            ( input  p-doc-code
             ,input  p-gds-code
             ,input  tt-doc-pl.pl-code
             ,output v-rvs-qnty-before
             ,output v-rvs-qnty-after
             ,output v-rvs-cli-qnty-before
             ,output v-rvs-cli-qnty-after
            ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
          assign
            v-count-pl     = v-count-pl + 1
            v-tot-qnty-rvs = v-tot-qnty-rvs + ( v-rvs-qnty-after - v-rvs-qnty-before )
            v-tot-qnty-pl  = v-tot-qnty-pl  + tt-doc-pl.fact-qnty
          .
          if absolute( ( v-rvs-qnty-after - v-rvs-qnty-before ) - tt-doc-pl.fact-qnty ) > tt-doc-pl.fact-qnty * 0.0065 then do:
            if v-message = "":U then do:
              assign
                v-message = "Факт. кол-во по местам хранения и по сверкам:".
              .
            end.
            assign
              v-message = v-message
                          + chr(10)
                          + substitute( "по месту хр. &1 (&4): &2, по сверкам: &3"
                                      ,tt-doc-pl.pl-code
                                      ,tt-doc-pl.cli-fact-qnty
                                      ,( v-rvs-cli-qnty-after - v-rvs-cli-qnty-before )
                                      ,buf_goods.unit-cli
                                      ) .
            .
          end.
        end.
        if v-message <> "":U
          and ( v-count-pl > 1
                or ( v-count-pl = 1
                      and p-fact-edit = true
                    )
              )
        then do:
          assign
            v-edit-doc-pl = ?
            v-set-doc-pl  = ?
          .
          if p-fact-edit = true
            or ( p-fact-edit = false
                 and v-tot-qnty-pl  = p-new-fact-qnty
                 and v-tot-qnty-rvs = p-new-fact-qnty
               )
          then do:
            assign
              v-add-option-bt = v-add-option-bt + "|Редактировать"
              v-add-option-ps = v-add-option-ps + "|Редактировать товар на местах хранения"
              v-edit-doc-pl   = 3
            .
          end.
          if p-fact-edit = true
            or ( p-fact-edit = false
                 and v-tot-qnty-rvs = p-new-fact-qnty
                )
          then do:
            assign
              v-add-option-bt = v-add-option-bt + "|Установить"
              v-add-option-ps = v-add-option-ps + "|Установить по местам хранения кол-вo из сверок (плотность по документу)"
            .
            if v-edit-doc-pl = ? then do:
              assign
                v-set-doc-pl = 3
              .
            end.
            else do:
              assign
                v-set-doc-pl = 4
              .
            end.
          end.
          run gbl/d-askw.w
            ( input "Расхождение значений по местам хранения с показаниями сверок"
             ,input substitute( "&1", v-message ) + chr(10) + "Это вызовет расхождение фактических и расчетно-книжных остатков"
             ,input "|^"
             ,input "Сохранить|Отмена" + v-add-option-bt
             ,input "Сохранить, игнорируя это расхождение|Отмена сохранения" + v-add-option-ps
             ,input 1
             ,input 2
             ,output v-answ-num
            ) .
          if v-answ-num = 2 then do:
            return error .
          end.
          if v-edit-doc-pl <> ?
            and v-answ-num = v-edit-doc-pl
          then do:
            assign
              p-ok = false
            .
            run edit-doc-pl in this-procedure
              ( input 'ИЗМЕНЕНИЕ':U
              ).
            return .
          end.
          if v-set-doc-pl <> ?
            and v-answ-num = v-set-doc-pl
          then do:
            assign
              p-ok = false
              p-new-fact-qnty     = 0.0
              p-new-cli-fact-qnty = 0.0
            .
            for each tt-doc-pl
            on error undo, return error return-value
            :
              run return-rvs-qnty in this-procedure
                ( input  p-doc-code
                 ,input  p-gds-code
                 ,input  tt-doc-pl.pl-code
                 ,output v-rvs-qnty-before
                 ,output v-rvs-qnty-after
                 ,output v-rvs-cli-qnty-before
                 ,output v-rvs-cli-qnty-after
                ) no-error .
              if error-status :error then do:
                return error return-value .
              end.
              assign
                tt-doc-pl.fact-qnty     = v-rvs-qnty-after - v-rvs-qnty-before
                tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-new-density
                p-new-fact-qnty         = p-new-fact-qnty    + tt-doc-pl.fact-qnty
                p-new-cli-fact-qnty     = p-new-cli-fact-qnty + tt-doc-pl.cli-fact-qnty
              .
            end.
            assign
              p-new-density = p-new-cli-fact-qnty / p-new-fact-qnty
            .
            return .
          end.
        end.
      end.
    end procedure.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure find-new-price-sale :
define input  parameter  par-gm           as character no-undo .
define input  parameter  par-pr-nakl      as logical   no-undo .
define input  parameter  p-doc-code       as character no-undo .
define input  parameter  p-artic          as character no-undo .
define input  parameter  p-prod-type      as character no-undo .
define input  parameter  p-prod-code      as integer   no-undo .
define input  parameter  p-doc-price-rubl as decimal   no-undo .
define input  parameter  p-doc-price-base as decimal   no-undo .
define input  parameter  p-doc-vat-pc     as decimal   no-undo .
define input  parameter  p-doc-slt-pc     as decimal   no-undo .
define input-output parameter  p-new-price-sale as decimal   no-undo .
define buffer buf_trn-doc for ub.trn-doc  .
define variable is-petrolium as logical   no-undo .
define variable is-pieces    as logical   no-undo .
  do
  on error undo, return error return-value
  :
 find first buf_trn-doc no-lock where buf_trn-doc.doc-code =  p-doc-code no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrolium
  , output is-pieces
  ) .
if not (par-pr-nakl = yes and par-gm = 'before-margin':U and is-petrolium = false ) then return .
  run str/in-prno.p (
      input   parParentProc ,
      input   p-doc-code    ,
      input   p-artic       ,
      input   p-prod-type   ,
      input   p-prod-code   ,
      input   p-doc-price-rubl ,
      input   p-doc-price-base ,
      input   p-doc-vat-pc ,
      input   p-doc-slt-pc ,
      input-output  p-new-price-sale ) .
  end.
end procedure.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
def var vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info31 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info31, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info31, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info31, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info31, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info31 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info31, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info31 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info31, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info31, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info31, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info31, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info31, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info31, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info31 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info31 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info31, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info31, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info31, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info31 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info31 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info31, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info31, v-inform, v-tbl-name ).
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
def var vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info34 as character format "X(65)" no-undo
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
def var vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function AddUtdErrForTab returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         run gen-key-rec (input iTab,
                          input  iObj,
                          output vRecKey).
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
function AddUtdErr returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
function ClearUtdErrTypeCode returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
function ClearUtdErr returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
function GetMesError returns character
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
function GetTextErrorType returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
function GetTypeError returns integer
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
function GetTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
function GetErrForUtdStr returns character
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
function GetErrJsonForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetErrJsonForUtdReturn returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetCodeTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
function GetErrTxtForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
function GetErrForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
function GetErrComText returns longchar
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
function CheckTypeForMarkLineType returns logical
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
   run gen-key-rec (input "utd-marking-lines",
                    input  iObj,
                    output vRecKey-markLine).
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
function CheckErrForMarkLineType returns logical
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
function CheckErrForMarkLine returns logical
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
function CheckErrForLineTypeCode returns logical
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
function getErrForLineType returns character
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
function CheckErrForLineType returns logical
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
function CheckErrForLine returns logical
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
function CheckErrForUtd returns logical
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
function CheckMarkUtd-28rel return logical
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
function CheckMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
function CheckNotMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
function CheckMarkUtdLine return logical
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
function getMarkUtdLine return logical
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
function CheckMarking return logical
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
function CheckMarkForType return logical
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
function WeighedProd return logical
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
function WghProdVariable return logical
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
function MarkWeight return decimal
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
define variable chg-qnty     like ub.gds-dtl.doc-qnty no-undo initial ?.
define variable rec-inv-line as   recid               no-undo.
define variable v-work-with-qnty           as character no-undo .
define variable v-undo-all                 as logical   no-undo .
define variable is-petrolium               as logical   no-undo .
define variable is-pieces                  as logical   no-undo .
define variable v-ptrl-without-rvs         as character no-undo .
define variable v-attr-type                as character no-undo .
define variable v-hold-doc                 as logical   no-undo .
define variable varis-new                  as logical   no-undo .
define variable varroad-tax-label          as character no-undo .
define variable r-recid-petrol-kg          as recid     no-undo .
define variable add-def-mode               as logical   no-undo .
define variable changed-price              as character no-undo .
define variable g#host-name                as character no-undo .
define variable g#host-code                as integer   no-undo .
define variable g#log                      as logical   no-undo .
define variable base-code                  as integer   no-undo .
define variable base-type                  as character no-undo .
define variable prt-rec                    as recid     no-undo .
define variable v-place-rsrv               as logical   no-undo .
define variable par-1                      as character no-undo .
define variable par-0                      as logical   no-undo .
define variable v-gds-ptrl-densities       as character no-undo.
define variable v-min-dens                 as decimal   no-undo.
define variable v-max-dens                 as decimal   no-undo.
define variable v-old-doc-qnty             like ub.gds-dtl.doc-qnty no-undo .
define variable v-old-doc-cli-qnty         like ub.gds-dtl.doc-qnty no-undo .
define variable v-old-fact-qnty            like ub.gds-dtl.doc-qnty no-undo .
define variable v-old-fact-cli-qnty        like ub.gds-dtl.doc-qnty no-undo .
define variable pr-naklvalue               as logical   no-undo .
define variable pr-nakltype                as character initial ?         no-undo.
define variable pr-genmrg                  as character initial ?         no-undo.
define variable v-is-return                as logical   no-undo initial no  .
define variable in-part-rec                as integer   no-undo .
define variable v-new-qnty                 as decimal   no-undo .
define variable v-free-qnty                as decimal   no-undo .
define variable v-no-add-marks             as logical   no-undo initial no .
define variable vIsExemplarGoods           as logical   no-undo .
define variable v-mark-weight              as decimal   no-undo .
define variable v-isweighed                as logical   no-undo .
define variable vRightChngQntyCode         as character no-undo .
define variable vRightChngQnty             as logical   no-undo .
define variable vBackSale                  as logical   no-undo initial no.
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
define variable v-pack-qnty as integer no-undo .
define variable vScanMark   as character no-undo.
define variable varvalue as character no-undo .
define variable vartype  as character no-undo .
define temp-table tt-parts-all   no-undo like ub.parts .
define temp-table tt-parts-split no-undo like ub.parts
  index pi is unique primary
    obj-type
    obj-code
    artic
    prod-type
    prod-code
    in-code
    out-code
    part-code
    pl-code
.
DEFINE VARIABLE mImagePath     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageDir      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImagePreDir   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageTrash    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mPhotomgd      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mImagePh       AS LOGICAL     NO-UNDO.
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
RUN imagelist_loaddef IN THIS-PROCEDURE NO-ERROR.
PROCEDURE imagelist_loaddef:
    DEFINE VARIABLE vPar-val       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vPar-type      AS CHARACTER   NO-UNDO.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'photo':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output vPar-val
  ,output vPar-type
  ) no-error .
        mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
    IF mImagePh THEN .
    ELSE RETURN.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ph-dir':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  NO
  ,output vPar-val
  ,output vPar-type
  ) no-error .
    IF LENGTH (vPar-val) = 0 THEN
        RUN verify-ini-entry("ph-dir":U, "REP-SETS":U, "":U, YES, OUTPUT vPar-val) NO-ERROR.
    IF LENGTH (vPar-val) = 0 THEN vPar-val = "c:\temp\":U.
    ASSIGN
        mImagePath   = RIGHT-TRIM (vPar-val, "~\~/":U)
        mImagePath   = mImagePath + (IF LENGTH (mImagePath) > 0 THEN "\":U ELSE "":U)
        mImagePreDir = mImagePath
        mImageDir    = mImagePreDir
        mImageTrash  = mImagePath + "trash\":U
        .
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
            run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
        mPhotomgd = IF v-val-integer = 2 then yes else no.
END PROCEDURE.
PROCEDURE imagelist_decode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE INPUT  PARAMETER iImageGdsCode AS int    NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF SUBSTRING (vCh, 1, 2) = "~\~\":U THEN .
        ELSE
        DO:
            ASSIGN
                vCh = REPLACE (vCh, "~/":U, "\":U)
                vCh = REPLACE (vCh, "~\":U, "\":U)
                .
            IF SUBSTRING (vCh, 2, 2) = ":\":U OR vCh BEGINS mImageDir THEN .
            ELSE vCh = mImagePreDir + (if mPhotomgd then string(iImageGdsCode) + "\":U else '':U ) +  vCh.
            ENTRY (vInt, oImageList, ",":U) = vCh.
        END.
    END.
END PROCEDURE.
PROCEDURE imagelist_encode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vLen               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        vLen       = LENGTH (mImageDir)
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF LENGTH (vCh) > 0 AND vLen > 0 AND vCh BEGINS mImageDir THEN
            ENTRY (vInt, oImageList, ",":U) =
                SUBSTRING (vCh, vLen + 1).
    END.
END PROCEDURE.
DEFINE BUTTON b-addinf DEFAULT
     LABEL "Доп.ин&ф."
     SIZE 10 BY 1.
DEFINE BUTTON b-arch
     LABEL "Док.цены":L
     SIZE 10 BY 1.
DEFINE BUTTON b-corr-price-sale
     IMAGE-UP FILE "cmp/check.bmp":U
     IMAGE-DOWN FILE "cmp/check.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/check.bmp":U
     LABEL ""
     SIZE 3 BY .79 TOOLTIP "Выбор цены".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 10 BY 1 TOOLTIP "История изменения строки документа".
DEFINE BUTTON b-place
     LABEL "Место хр.":L
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON b-rvs-af DEFAULT
     LABEL "Св.после"
     SIZE 10 BY 1.
DEFINE BUTTON b-rvs-bf DEFAULT
     LABEL "Св.до"
     SIZE 10 BY 1.
DEFINE BUTTON r-price
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .79 TOOLTIP "Выбор цены".
DEFINE VARIABLE c-reason AS integer FORMAT "-999":U INITIAL 0
     LABEL "Причина списания"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "",0
     DROP-DOWN-LIST
     SIZE 38.25 BY 1 NO-UNDO.
DEFINE VARIABLE base-curr AS CHARACTER FORMAT "x(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE TEXT-1 AS CHARACTER FORMAT "x(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE tot-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 23 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-fact-qnty-kg LIKE inv-line.wast-cli-qnty
     LABEL "Факт,кг"
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-price-base-kg AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-price-rubl-kg AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Цена,кг"
     VIEW-AS FILL-IN
     SIZE 23 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-qnty-kg LIKE inv-line.wast-cli-qnty
     LABEL "По док,кг"
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varprod-bc-str AS CHARACTER FORMAT "X(40)"
     VIEW-AS FILL-IN
     SIZE 41 BY 1 NO-UNDO.
DEFINE IMAGE g-image
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 18.5 BY 3.75.
DEFINE RECTANGLE RECT-discnt
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 95.5 BY 6.
DEFINE RECTANGLE RECT-gds
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76 BY 3.75.
DEFINE RECTANGLE RECT-qnty
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.75 BY 4.5.
DEFINE RECTANGLE RECT-tot
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 95.5 BY 12.25.
DEFINE QUERY d-out-prt FOR
      price-list SCROLLING.
DEFINE FRAME d-out-prt
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-arch AT ROW 1 COL 21
     b-place AT ROW 1 COL 31 WIDGET-ID 2
     b-addinf AT ROW 1 COL 41
     b-rvs-bf AT ROW 1 COL 51 WIDGET-ID 6
     c-reason AT ROW 1 COL 51.25 COLON-ALIGNED WIDGET-ID 12
     b-rvs-af AT ROW 1 COL 61 WIDGET-ID 4
     b-history AT ROW 1 COL 78.5
     b-help AT ROW 1 COL 88.5
     gds-dtl.artic AT ROW 2.58 COL 3.75 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     buf_goods.gds-name AT ROW 2.58 COL 19.38 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
          FGCOLOR 4
     varprod-bc-str AT ROW 3.58 COL 3.75 NO-LABEL
     gds-dtl.prod-code AT ROW 4.58 COL 3.75 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     gds-dtl.prod-type AT ROW 4.58 COL 13.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     clients.obj-name AT ROW 4.58 COL 22.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
          FGCOLOR 4
     b-c-b.b-code AT ROW 6.46 COL 20 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     gds-prt.f-name AT ROW 6.46 COL 30.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 25 BY 1
          FGCOLOR 4
     prt-obj.free-qnty AT ROW 6.5 COL 70.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          FGCOLOR 4
     price-list.doc-num AT ROW 7.46 COL 20 COLON-ALIGNED
          LABEL "Переоценка"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     doc-line.temperature AT ROW 7.5 COL 70.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 7 BY 1
          FGCOLOR 4
     doc-line.road-tax AT ROW 8.46 COL 20 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     doc-line.doc-density AT ROW 8.5 COL 70.25 COLON-ALIGNED FORMAT "9.9999999999"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          FGCOLOR 4
     gds-dtl.discnt-rubl AT ROW 9.92 COL 10 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 23 BY 1
          FGCOLOR 4
     gds-dtl.discnt-base AT ROW 9.92 COL 34 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 19 BY 1
          FGCOLOR 4
     gds-dtl.discnt-pc AT ROW 9.92 COL 53 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 8 BY 1
          FGCOLOR 4
     gds-dtl.discnt-type AT ROW 9.92 COL 63.5
          VIEW-AS TOGGLE-BOX
          SIZE 11 BY 1
     gds-dtl.doc-qnty AT ROW 11.42 COL 80.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY 1
          FGCOLOR 4
     gds-dtl.price-rubl AT ROW 11.46 COL 10 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 23 BY 1
          FGCOLOR 4
     gds-dtl.price-base AT ROW 11.46 COL 34 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 19 BY 1
          FGCOLOR 4
     gds-dtl.fact-qnty AT ROW 12.42 COL 80.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY 1
          FGCOLOR 4
     r-price AT ROW 12.5 COL 31.88
     v-price-rubl-kg AT ROW 13.33 COL 10 COLON-ALIGNED
     v-price-base-kg AT ROW 13.33 COL 34 COLON-ALIGNED NO-LABEL
     v-qnty-kg AT ROW 13.42 COL 80.25 COLON-ALIGNED HELP
          ""
          LABEL "По док,кг"
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-exit.
DEFINE FRAME d-out-prt
     v-fact-qnty-kg AT ROW 14.42 COL 80.25 COLON-ALIGNED HELP
          ""
          LABEL "Факт,кг"
          FGCOLOR 4
     gds-dtl.new-price-sale AT ROW 14.54 COL 20.75 COLON-ALIGNED WIDGET-ID 8
          VIEW-AS FILL-IN
          SIZE 22 BY 1 TOOLTIP "Переоценка до закрытия документа"
     b-corr-price-sale AT ROW 14.63 COL 45 WIDGET-ID 10
     tot-rubl AT ROW 16 COL 10 COLON-ALIGNED
     tot-base AT ROW 16 COL 34 COLON-ALIGNED NO-LABEL
     buf_goods.qnty-cart AT ROW 16 COL 80.25 COLON-ALIGNED
          LABEL "В упаковке"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
          FGCOLOR 4
     TEXT-1 AT ROW 17.25 COL 10 COLON-ALIGNED NO-LABEL
     base-curr AT ROW 17.25 COL 34 COLON-ALIGNED NO-LABEL
     buf_goods.unit-base AT ROW 17.25 COL 80.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY 1
          BGCOLOR 3 FGCOLOR 15
     RECT-gds AT ROW 2.25 COL 2.5
     RECT-tot AT ROW 6.25 COL 2
     RECT-discnt AT ROW 9.75 COL 2
     RECT-qnty AT ROW 11.25 COL 55.75
     g-image AT ROW 2.25 COL 79 WIDGET-ID 8
     SPACE(1.12) SKIP(12.50)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME d-out-prt:SCROLLABLE       = FALSE.
ASSIGN
       b-addinf:HIDDEN IN FRAME d-out-prt           = TRUE.
ASSIGN
       b-rvs-af:HIDDEN IN FRAME d-out-prt           = TRUE.
ASSIGN
       b-rvs-bf:HIDDEN IN FRAME d-out-prt           = TRUE.
ON END-ERROR OF FRAME d-out-prt
DO:
  apply "CHOOSE":U to b-quit in frame d-out-prt.
  return no-apply.
END.
ON CHOOSE OF b-addinf IN FRAME d-out-prt
DO:
  define variable v-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
  define variable v-new-density          like ub.doc-line.fact-density no-undo .
  define variable v-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
  if t-doc.doc-type = 'при':U then do:
    assign
      v-new-fact-qnty     = ( input frame d-out-prt ub.gds-dtl.fact-qnty )
      v-new-density       = ub.doc-line.fact-density
      v-new-cli-fact-qnty = ( input frame d-out-prt v-fact-qnty-kg )
    .
    run proc-b-addinfo in this-procedure
      ( input        parparentproc
       ,input        ( if prt-mode <> 'ПРОСМОТР':U then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U )
       ,input        ub.doc-line.doc-code
       ,input        buf_goods.gds-code
       ,input        stfactplvalue
       ,input        varauto-tank
       ,input        varupd-fact-qnty
       ,input        input frame d-out-prt ub.gds-dtl.doc-qnty
       ,input        ub.doc-line.doc-density
       ,input-output v-new-fact-qnty
       ,input-output v-new-density
       ,input-output v-new-cli-fact-qnty
       ,input-output v-prt-car-num
       ,input-output v-prt-car-vol
       ,input-output v-prt-tests
       ,input-output v-prt-autoent-obj-type
       ,input-output v-prt-autoent-obj-code
       ,input-output v-prt-item-pour
       ,input-output v-prt-time-pour
       ,input-output v-prt-tank-vol
       ,input-output v-prt-tank-temp
       ,input-output v-prt-tank-water
       ,input-output v-prt-tank-density
       ,input-output v-prt-tank-weight
       ,input-output v-prt-time-income
       ,input-output v-prt-start-real-date
       ,input-output v-prt-start-real-time
       ,input-output v-prt-end-real-date
       ,input-output v-prt-end-real-time
       ,input-output v-prt-mouth
       ,input-output v-prt-fio
       ,input-output v-prt-ptbotype
       ,input-output v-prt-ptbocode
       ,input-output v-prt-a-b-tarir
       ,input-output v-diameter
       ,input-output v-place-si
       ,input-output v-tank-density-pomi
       ,input-output v-prt-certif-fuel
       ,input-output v-prt-norm-doc
       ,input-output v-prt-num-passport
       ,input-output v-prt-validity-certif
       ,input-output v-prt-passport-plotn
       ,input-output v-prt-num-plotn
       ,input-output v-prt-date-pov-plotn
      ) no-error .
    if error-status :error then do:
      message
        substitute("Ошибка при изменении дополнительной информации.") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply .
    end.
    if ( input frame d-out-prt ub.gds-dtl.fact-qnty ) <> v-new-fact-qnty
      or ( input frame d-out-prt v-fact-qnty-kg ) <> v-new-cli-fact-qnty
      or ub.doc-line.fact-density <> v-new-density
    then do:
      run correct-fact-qnty in this-procedure
        ( input v-new-fact-qnty
         ,input v-new-density
        ) no-error .
    end.
  end.
  else do:
    run str/out-ladd.w
      ( input ParParentProc
       ,input ( if prt-mode <> 'ПРОСМОТР':U then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U )
       ,input-output v-prt-car-num
       ,input-output v-prt-autoent-obj-type
       ,input-output v-prt-autoent-obj-code
      ) no-error.
    if error-status :error then do:
      message
          vss-workfile vss-revision vss-description
          skip(1)
          skip "Ошибка дополнительных данных строки."
          skip return-value
          skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
      view-as alert-box error.
      undo, return no-apply .
    end.
  end.
END.
ON CHOOSE OF b-arch IN FRAME d-out-prt
DO:
  define variable calc_price-base as decimal no-undo.
  define variable calc_price-rubl as decimal no-undo.
  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.doc-line.obj-type
  ,input  ub.doc-line.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  ub.doc-line.obj-type
    ,input  ub.doc-line.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if g#log <> yes then do: return no-apply. end.
  assign
    calc_price-base = ub.doc-line.price-base * ub.gds-dtl.fact-qnty
    calc_price-rubl = ub.doc-line.price-rubl * ub.gds-dtl.fact-qnty
  .
  message "Сумма в ценах документа:" skip
    string( calc_price-base,     "->>,>>>,>>>,>>9.99":U ) base-type skip
    string( calc_price-rubl, "->>,>>>,>>>,>>>,>>9.99":U ) "РУБ"     skip( 2 )
          "Сумма к оплате:" skip
    string( tot-base,     "->>,>>>,>>>,>>9.99":U ) base-type skip
    string( tot-rubl, "->>,>>>,>>>,>>>,>>9.99":U ) "РУБ"     skip( 2 )
          "Разница:" skip
    string( tot-base - calc_price-base,     "->>,>>>,>>>,>>9.99":U ) base-type skip
    string( tot-rubl - calc_price-rubl, "->>,>>>,>>>,>>>,>>9.99":U ) "РУБ"     skip( 2 )
          "Наценка:"
    string( ( tot-base - calc_price-base ) / calc_price-base * 100, "->>9.9<%":U )
  view-as alert-box title 'Товар: "' + buf_goods.gds-name + '".  Признак: "' + ub.gds-prt.f-name + '".'.
END.
ON CHOOSE OF b-corr-price-sale IN FRAME d-out-prt
DO:
END.
ON CHOOSE OF b-exit IN FRAME d-out-prt
DO:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable total_gds-dtl_doc-qnty  like ub.gds-dtl.doc-qnty      no-undo.
  define variable total_gds-dtl_fact-qnty like ub.gds-dtl.fact-qnty     no-undo.
  define variable t_qty                   like ub.gds-dtl.fact-qnty     no-undo.
  define variable varprt-obj_free-qnty    like ub.prt-obj.free-qnty     no-undo.
  define variable v-ok                    as   logical                  no-undo .
  define variable v-new-fact-qnty         like ub.doc-line.fact-qnty    no-undo .
  define variable v-new-density           like ub.doc-line.fact-density no-undo .
  define variable v-new-cli-fact-qnty     like ub.doc-line.fact-qnty    no-undo .
  if prt-mode = 'ПРОСМОТР':U then do:
    return no-apply.
  end.
      if t-doc.ext-doc-type = 'iv':U then
      do:
        if can-find(first buf_marking-lines where
                          buf_marking-lines.out-code = t-doc.doc-code
                      and buf_marking-lines.gds-code = buf_goods.gds-code) then
          return .
      end.
  run check-fact-qnty in this-procedure no-error .
  if error-status :error then return no-apply.
  block_save:
  do transaction
  on error undo block_save, return no-apply
  :
    if can-find( first ub.units where ub.units.unit-name = buf_goods.unit-base
                        and lookup( 'шту':U, ub.units.type) > 0 ) and
      truncate( input frame d-out-prt ub.gds-dtl.doc-qnty,  0 )
          <>    input frame d-out-prt ub.gds-dtl.doc-qnty
    then do:
      message "Базовая единица товара " buf_goods.unit-base " - штучная." skip
              "Кол-во по документу должно быть целым."
      view-as alert-box error.
      return no-apply.
    end.
    if t-doc.ext-doc-type = 'we':U then do:
      if c-reason > 0 then do:
        find first ub.doc-line-attr no-lock where ub.doc-line-attr.doc-code = t-doc.doc-code and
        ub.doc-line-attr.gds-code = buf_goods.gds-code and
        ub.doc-line-attr.attr-code = "reasonSpisan" no-error .
        if not available (ub.doc-line-attr) then do:
          create ub.doc-line-attr .
          assign
          ub.doc-line-attr.doc-code = t-doc.doc-code
          ub.doc-line-attr.gds-code = buf_goods.gds-code
          ub.doc-line-attr.attr-code = "reasonSpisan"
          .
        end.
        ub.doc-line-attr.attr-value = string (c-reason) .
      end.
    end.
    if t-doc.doc-type = 'рас':U
    and buf_goods.qnty-cart <> 0
    and not v-is-return
    and not v-isweighed
    then do:
      if (input frame d-out-prt ub.gds-dtl.doc-qnty / buf_goods.qnty-cart) - round (input frame d-out-prt ub.gds-dtl.doc-qnty / buf_goods.qnty-cart, 0) <> 0 then do:
        if available ub.prt-obj then do:
          assign
            varprt-obj_free-qnty = ub.prt-obj.free-qnty
          .
        end.
        else do:
          assign
            varprt-obj_free-qnty = 0
          .
        end.
        if t-doc.status_ = 'запрос':U or
          ( varprt-obj_free-qnty + ub.gds-dtl.doc-qnty > buf_goods.qnty-cart and
            varprt-obj_free-qnty + ub.gds-dtl.doc-qnty <> input frame d-out-prt ub.gds-dtl.doc-qnty ) then do:
          assign
            g#log = yes
          .
          message "Товар рекомендуется выписывать упаковками." skip( 2 )
                  "Округлить до целого числа упаковок ?"
          view-as alert-box question buttons YES-NO update g#log.
          if g#log then do:
            if round( input frame d-out-prt ub.gds-dtl.doc-qnty / buf_goods.qnty-cart, 0 ) = 0 then do:
              display
                buf_goods.qnty-cart @ ub.gds-dtl.doc-qnty
              with frame d-out-prt.
            end.
            else do:
              display
                round( input frame d-out-prt ub.gds-dtl.doc-qnty / buf_goods.qnty-cart, 0 ) *
                                                buf_goods.qnty-cart  @ ub.gds-dtl.doc-qnty
              with frame d-out-prt.
            end.
          end.
        end.
      end.
    end.
    if prt-mode = 'ШКАЛА':U or prt-mode = 'БЕЗ_ПРИЗНАКОВ':U then do:
      assign
        total_gds-dtl_doc-qnty  = 0
        total_gds-dtl_fact-qnty = 0
      .
      for each g-d-b where g-d-b.prod-code = ub.doc-line.prod-code
                      and g-d-b.prod-type = ub.doc-line.prod-type
                      and g-d-b.artic     = ub.doc-line.artic
                      and g-d-b.doc-code  = ub.doc-line.doc-code
                      and g-d-b.prt-code <> ub.gds-dtl.prt-code :
        assign
          total_gds-dtl_doc-qnty  = total_gds-dtl_doc-qnty  + g-d-b.doc-qnty
          total_gds-dtl_fact-qnty = total_gds-dtl_fact-qnty + g-d-b.fact-qnty
        .
      end.
      assign
        total_gds-dtl_doc-qnty  = total_gds-dtl_doc-qnty  + ( input frame d-out-prt ub.gds-dtl.doc-qnty  )
        total_gds-dtl_fact-qnty = total_gds-dtl_fact-qnty + ( input frame d-out-prt ub.gds-dtl.fact-qnty )
      .
    end.
    run re-calcpr in this-procedure .
    if is-petrolium = yes
      and is-pieces = no
      and not is-gas(buf_goods.gds-code)
    then do:
      if
  valid-density( ub.doc-line.doc-density, buf_goods.unit-base = buf_goods.unit-cli )
  <> true then do:
        message
          "Неверное значение плотности для топлива:" ub.doc-line.doc-density "." skip
          "Плотность топлива должна быть в диапазоне: больше 0 и меньше 1."
          view-as alert-box error title " ОШИБКА!!! ".
        apply "ENTRY":U to ub.doc-line.doc-density in frame d-out-prt.
        return no-apply.
      end.
      if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
        if (ub.doc-line.doc-density) < v-min-dens
        or (ub.doc-line.doc-density) > v-max-dens
        then do:
            message
              substitute("Введенное значение плотности находится вне заданного диапазона: &1.",
              v-gds-ptrl-densities )
              view-as alert-box error .
            apply "ENTRY":U to ub.doc-line.doc-density in frame d-out-prt.
            return no-apply .
        end.
      end.
      if t-doc.doc-type = 'при':U then do:
        if v-work-with-qnty = "fact":U
          or v-work-with-qnty = "fact-doc":U
        then do:
          assign
            v-ok = true
          .
          run chkdcrvs in this-procedure
            ( input  t-doc.doc-code
            ,input  buf_goods.gds-code
            ,output v-ok
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            return no-apply .
          end.
          if v-ok = true then do:
            assign
              v-new-fact-qnty     = (input frame d-out-prt ub.gds-dtl.fact-qnty)
              v-new-density       = ub.doc-line.fact-density
              v-new-cli-fact-qnty = (input frame d-out-prt v-fact-qnty-kg)
            .
            run local-state-fact-rvs in this-procedure
              ( input        t-doc.doc-code
              ,input        buf_goods.gds-code
              ,input        stfactplvalue
              ,input        varrevision
              ,input        varupd-fact-qnty
              ,input        (input frame d-out-prt ub.gds-dtl.doc-qnty)
              ,input        ub.doc-line.doc-density
              ,input-output v-new-fact-qnty
              ,input-output v-new-density
              ,input-output v-new-cli-fact-qnty
              ) no-error .
            if error-status :error then do:
              message
                "Ошибка при установке факт кол-ва (revision)." skip
                return-value
                view-as alert-box error .
              undo block_save, return no-apply .
            end.
            if ( input frame d-out-prt ub.gds-dtl.fact-qnty ) <> v-new-fact-qnty
              or ( input frame d-out-prt v-fact-qnty-kg ) <> v-new-cli-fact-qnty
              or ub.doc-line.fact-density <> v-new-density
            then do:
              run correct-fact-qnty in this-procedure
                ( input v-new-fact-qnty
                ,input v-new-density
                ) no-error .
            end.
            assign
              v-new-fact-qnty     = (input frame d-out-prt ub.gds-dtl.fact-qnty)
              v-new-density       = ub.doc-line.fact-density
              v-new-cli-fact-qnty = (input frame d-out-prt v-fact-qnty-kg)
            .
            run eq-qnty-rvs-pl in this-procedure
              ( input        t-doc.doc-code
              ,input        buf_goods.gds-code
              ,input        varupd-fact-qnty
              ,input-output v-new-fact-qnty
              ,input-output v-new-density
              ,input-output v-new-cli-fact-qnty
              ,      output v-ok
              ) no-error .
            if error-status :error then do:
              message
                "Ошибка при установке факт кол-ва по местам хранения." skip
                return-value
                view-as alert-box error .
              undo block_save, return no-apply .
            end.
            if ( input frame d-out-prt ub.gds-dtl.fact-qnty ) <> v-new-fact-qnty
              or ( input frame d-out-prt v-fact-qnty-kg ) <> v-new-cli-fact-qnty
              or ub.doc-line.fact-density <> v-new-density
            then do:
              assign
                ub.doc-line.fact-density = v-new-density
              .
              display
                v-new-fact-qnty @ ub.gds-dtl.fact-qnty
                v-new-fact-qnty * v-new-density when v-fact-qnty-kg :visible = true @ v-fact-qnty-kg
                with frame d-out-prt .
            end.
            if v-ok = false then do:
              return .
            end.
          end.
        end.
        run str/in-laddout.w
          ( input        parParentProc
          ,input        "set-attr":U
          ,input        t-doc.doc-code
          ,input        buf_goods.gds-code
          ,input-output v-prt-car-num
          ,input-output v-prt-car-vol
          ,input-output v-prt-tests
          ,input-output v-prt-autoent-obj-type
          ,input-output v-prt-autoent-obj-code
          ,input-output v-prt-item-pour
          ,input-output v-prt-time-pour
          ,input-output v-prt-tank-vol
          ,input-output v-prt-tank-temp
          ,input-output v-prt-tank-water
          ,input-output v-prt-tank-density
          ,input-output v-prt-tank-weight
          ,input-output v-prt-time-income
          ,input-output v-prt-start-real-date
          ,input-output v-prt-start-real-time
          ,input-output v-prt-end-real-date
          ,input-output v-prt-end-real-time
          ,input-output v-prt-mouth
          ,input-output v-prt-fio
          ,input-output v-prt-ptbotype
          ,input-output v-prt-ptbocode
          ,input-output v-prt-a-b-tarir
          ,input-output v-diameter
          ,input-output v-place-si
          ,input-output v-tank-density-pomi
          ,input-output v-prt-certif-fuel
          ,input-output v-prt-norm-doc
          ,input-output v-prt-num-passport
          ,input-output v-prt-validity-certif
          ,input-output v-prt-passport-plotn
          ,input-output v-prt-num-plotn
          ,input-output v-prt-date-pov-plotn
          ,      output was_setting
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при сохранении дополнительной информации!") skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return no-apply.
        end.
      end.
      else do:
        run write-doc-line-attr in this-procedure (
              input ub.doc-line.doc-code
            , input buf_goods.gds-code
            , input "car-num":U
            , input v-prt-car-num
        ).
        run write-doc-line-attr in this-procedure (
              input ub.doc-line.doc-code
            , input buf_goods.gds-code
            , input "autoent-obj-type":U
            , input v-prt-autoent-obj-type
        ).
        run write-doc-line-attr in this-procedure (
              input ub.doc-line.doc-code
            , input buf_goods.gds-code
            , input "autoent-obj-code":U
            , input v-prt-autoent-obj-code
        ).
      end.
    end.
    run check-place-rsrv in this-procedure
      no-error .
    if error-status :error then do:
      undo block_save, return no-apply.
    end.
    if ub.gds-dtl.fact-qnty :sensitive in frame d-out-prt = true
      and input frame d-out-prt ub.gds-dtl.fact-qnty = 0.0
      and ub.gds-dtl.doc-qnty = 0.0
    then do:
      message
        "Установлено факт количество = 0. Изменения игнорируются."
        view-as alert-box information.
      undo block_save, return no-apply.
    end.
    if input frame d-out-prt ub.gds-dtl.doc-qnty = 0.0 then do:
      if v-work-with-qnty = "doc":U then do:
        message
          "Установлено количество = 0. Изменения игнорируются."
          view-as alert-box information.
        undo block_save, return no-apply.
      end.
    end.
    else do:
      if ( ( input frame d-out-prt ub.gds-dtl.price-base = ? and not t-doc.print-rubl )
            or
            ( input frame d-out-prt ub.gds-dtl.price-rubl = ? and t-doc.print-rubl )
          )
        and t-doc.status_ <> 'запрос':U
        and t-doc.ext-doc-type <> 'ep':U
      then do:
        message
          "Указана неизвестная цена. Изменения игнорируются."
          view-as alert-box information.
        undo block_save, return no-apply.
      end.
    end.
    if v-is-return
    then do :
      if v-work-with-qnty = "doc":U then do:
        v-new-qnty = input frame d-out-prt ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty .
      end .
      else do :
        v-new-qnty = input frame d-out-prt ub.gds-dtl.fact-qnty - ub.gds-dtl.fact-qnty .
      end .
      find first in_parts no-lock where recid(in_parts) = in-part-rec no-error .
      if available in_parts
      then do :
        v-free-qnty = in_parts.fact-qnty .
        for each buf_gen-attr no-lock where buf_gen-attr.table-name = 'parts':U
                                        and buf_gen-attr.attr-code  = "in-part-key"
                                        and buf_gen-attr.attr-value =  "parts"                + chr(3) +
 in_parts.obj-type           + chr(3) +
 string(in_parts.obj-code)   + chr(3) +
 in_parts.artic              + chr(3) +
 in_parts.prod-type          + chr(3) +
 string(in_parts.prod-code)  + chr(3) +
 in_parts.In-code            + chr(3) +
 in_parts.Out-code           + chr(3) +
 in_parts.part-Code          + chr(3) +
 string(in_parts.prt-code)
 ,
        first out_parts no-lock where out_parts.obj-type  = entry(2, buf_gen-attr.p-key, chr(3))
                                  and out_parts.obj-code  = integer(entry(3, buf_gen-attr.p-key, chr(3)))
                                  and out_parts.artic     = entry(4, buf_gen-attr.p-key, chr(3))
                                  and out_parts.prod-type = entry(5, buf_gen-attr.p-key, chr(3))
                                  and out_parts.prod-code = integer(entry(6, buf_gen-attr.p-key, chr(3)))
                                  and out_parts.in-code   = entry(7, buf_gen-attr.p-key, chr(3))
                                  and out_parts.out-code  = entry(8, buf_gen-attr.p-key, chr(3))
                                  and out_parts.part-code = entry(9, buf_gen-attr.p-key, chr(3))
        :
          v-free-qnty = v-free-qnty - out_parts.fact-qnty .
        end .
        find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = t-doc.obj-type
                                         and buf_gds-obj.obj-code  = t-doc.obj-code
                                         and buf_gds-obj.artic     = buf_goods.artic
                                         and buf_gds-obj.prod-type = buf_goods.prod-type
                                         and buf_gds-obj.prod-code = buf_goods.prod-code
                                         no-error .
        if error-status :error
        then do:
          message
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo block_save, return no-apply.
        end.
        if buf_gds-obj.free-qnty < v-new-qnty
        then do :
          message substitute ("Возвращаемое количество превышает текущий остаток, равный &1. Возврат не возможен.", buf_gds-obj.free-qnty) view-as alert-box .
          display
            ub.gds-dtl.doc-qnty
          with frame d-out-prt.
          undo block_save, return no-apply.
        end .
        if v-new-qnty > v-free-qnty
        then do :
          if t-doc.reason-code = 25
          then do :
            v-no-add-marks = yes .
            message "Введенное количество превышает максимально допустимое к возврату по выбранной партии. Количество установлено максимально возможным" view-as alert-box .
            if node-type begins "scan-marks"
            then do :
              if v-work-with-qnty = "doc":U
              then do:
                display
                  ub.gds-dtl.doc-qnty
                with frame d-out-prt.
              end .
              else do :
                display
                  ub.gds-dtl.fact-qnty
                with frame d-out-prt.
              end .
            end .
            else do :
              if v-work-with-qnty = "doc":U
              then do:
                display
                  ub.gds-dtl.doc-qnty + v-free-qnty @ ub.gds-dtl.doc-qnty
                with frame d-out-prt.
              end .
              else do :
                display
                  ub.gds-dtl.fact-qnty + v-free-qnty @ ub.gds-dtl.fact-qnty
                with frame d-out-prt.
              end .
            end .
          end .
          if t-doc.reason-code = 23
          then do :
            if node-type begins "scan-marks"
            and v-free-qnty < 0
            then do : end .
            else do :
              message "Введенное количество превышает максимально допустимое к возврату по выбранной партии, продолжить оформление возврата указанного количества?"
              view-as alert-box question buttons yes-no update g#log .
              if not g#log
              then do :
                v-no-add-marks = yes .
                if node-type begins "scan-marks"
                then do :
                  display
                    ub.gds-dtl.doc-qnty
                  with frame d-out-prt.
                end .
                else do :
                  display
                    ub.gds-dtl.doc-qnty
                  with frame d-out-prt.
                  undo block_save, return no-apply.
                end .
              end .
            end .
          end .
        end .
        if buf_gds-obj.free-qnty < v-new-qnty
        then do :
          message substitute ("Возвращаемое количество превышает текущий остаток, равный &1. Возврат не возможен.", buf_gds-obj.free-qnty) view-as alert-box .
          display
            ub.gds-dtl.doc-qnty
          with frame d-out-prt.
          undo block_save, return no-apply.
        end .
        node-type = 'терм':U .
      end .
    end .
    run rsrv-out in this-procedure
      no-error .
    if error-status :error then do:
      message
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo block_save, return no-apply.
    end.
    if v-is-return
    and available in_parts
    then do :
      for each out_parts no-lock where out_parts.obj-type  = in_parts.obj-type
                                   and out_parts.obj-code  = in_parts.obj-code
                                   and out_parts.artic     = in_parts.artic
                                   and out_parts.prod-type = in_parts.prod-type
                                   and out_parts.prod-code = in_parts.prod-code
                                   and out_parts.out-code  = t-doc.doc-code
      :
        find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'parts':U
                                          and buf_gen-attr.p-key      =  "parts"                + chr(3) +
 out_parts.obj-type           + chr(3) +
 string(out_parts.obj-code)   + chr(3) +
 out_parts.artic              + chr(3) +
 out_parts.prod-type          + chr(3) +
 string(out_parts.prod-code)  + chr(3) +
 out_parts.In-code            + chr(3) +
 out_parts.Out-code           + chr(3) +
 out_parts.part-Code          + chr(3) +
 string(out_parts.prt-code)
                                          and buf_gen-attr.attr-code  = "in-part-key"
                                          no-error .
        if not available buf_gen-attr
        then do :
          create buf_gen-attr .
          assign
            buf_gen-attr.table-name = 'parts':U
            buf_gen-attr.p-key      =  "parts"                + chr(3) +
 out_parts.obj-type           + chr(3) +
 string(out_parts.obj-code)   + chr(3) +
 out_parts.artic              + chr(3) +
 out_parts.prod-type          + chr(3) +
 string(out_parts.prod-code)  + chr(3) +
 out_parts.In-code            + chr(3) +
 out_parts.Out-code           + chr(3) +
 out_parts.part-Code          + chr(3) +
 string(out_parts.prt-code)
            buf_gen-attr.attr-code  = "in-part-key"
            buf_gen-attr.attr-value =  "parts"                + chr(3) +
 in_parts.obj-type           + chr(3) +
 string(in_parts.obj-code)   + chr(3) +
 in_parts.artic              + chr(3) +
 in_parts.prod-type          + chr(3) +
 string(in_parts.prod-code)  + chr(3) +
 in_parts.In-code            + chr(3) +
 in_parts.Out-code           + chr(3) +
 in_parts.part-Code          + chr(3) +
 string(in_parts.prt-code)
          .
        end .
      end .
    end .
  end.
END.
ON CHOOSE OF b-history IN FRAME d-out-prt
DO:
  define variable v-list as character no-undo.
  run str/docclins.w (
      input        parparentproc,
      input        '':U,
      input        'one':U,
      input        ub.doc-line.obj-type,
      input        ub.doc-line.obj-code,
      input        ub.gds-dtl.doc-code,
      input        ub.gds-dtl.artic,
      input        ub.gds-dtl.prod-type ,
      input        ub.gds-dtl.prod-code ,
      input-output v-list
      ).
END.
ON CHOOSE OF b-place IN FRAME d-out-prt
DO:
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if v-place-rsrv <> true
    or b-place :sensitive in frame d-out-prt <> true
  then do:
    return .
  end.
  run edit-doc-pl in this-procedure
    ( input (if t-doc.ext-doc-type = 'iv':U then t-doc.ext-doc-type else if prt-mode = 'ПРОСМОТР':U then 'ПРОСМОТР':U else 'ИЗМЕНЕНИЕ':U )
    ).
END.
ON CHOOSE OF b-quit IN FRAME d-out-prt
DO:
  if prt-mode <> 'ПРОСМОТР':U then do:
    if add-def-mode = yes then do:
      delete ub.gds-dtl.
      assign
        prt-rec = ?
      .
    end.
    else do:
      if decimal(trim(ub.gds-dtl.doc-qnty:screen-value   )) <> decimal(trim(string (ub.gds-dtl.doc-qnty    ,ub.gds-dtl.doc-qnty:format ) )  )
        or decimal(trim(ub.gds-dtl.fact-qnty:screen-value  )) <> decimal(trim(string (ub.gds-dtl.fact-qnty   ,ub.gds-dtl.fact-qnty:format ))  )
        or decimal(trim(ub.gds-dtl.price-base:screen-value )) <> decimal(trim(string (ub.gds-dtl.price-base  ,ub.gds-dtl.price-base:format )) )
        or decimal(trim(ub.gds-dtl.price-rubl:screen-value )) <> decimal(trim(string (ub.gds-dtl.price-rubl  ,ub.gds-dtl.price-rubl:format )) )
        or decimal(trim(ub.gds-dtl.discnt-base:screen-value)) <> decimal(trim(string (ub.gds-dtl.discnt-base ,ub.gds-dtl.discnt-base:format) ))
        or decimal(trim(ub.doc-line.temperature:screen-value)) <> decimal(trim(string ( ub.doc-line.temperature , ub.doc-line.temperature:format )))
        or decimal(trim(ub.doc-line.doc-density    :screen-value)) <> decimal(trim(string ( ub.doc-line.doc-density     , ub.doc-line.doc-density    :format )))
        or decimal(trim(ub.gds-dtl.discnt-rubl:screen-value)) <> decimal(trim(string (ub.gds-dtl.discnt-rubl ,ub.gds-dtl.discnt-rubl:format )))
      then do:
        message
          "Сделанные изменения будут отменены." skip
          "Вы действительно хотите выйти без сохранения?"
          view-as alert-box question buttons yes-no update g#log .
        if g#log = false  then do:
          return no-apply .
        end.
      end.
    end.
    assign
      v-undo-all = true
    .
  end.
END.
ON LEAVE OF gds-dtl.discnt-base IN FRAME d-out-prt
DO:
    assign
    ub.gds-dtl.discnt-base
  .
END.
ON LEAVE OF gds-dtl.discnt-pc IN FRAME d-out-prt
DO:
    assign
    ub.gds-dtl.discnt-pc
  .
END.
ON LEAVE OF gds-dtl.discnt-rubl IN FRAME d-out-prt
DO:
    assign
    ub.gds-dtl.discnt-rubl
  .
END.
ON VALUE-CHANGED OF gds-dtl.discnt-type IN FRAME d-out-prt
DO:
    assign
    ub.gds-dtl.discnt-type
  .
  if ub.gds-dtl.discnt-type  then do:
    enable  ub.gds-dtl.discnt-pc                          with frame d-out-prt.
    disable ub.gds-dtl.discnt-base ub.gds-dtl.discnt-rubl with frame d-out-prt.
  end.
  else do:
    enable  ub.gds-dtl.discnt-rubl when     t-doc.print-rubl
            ub.gds-dtl.discnt-base when not t-doc.print-rubl
                                   with frame d-out-prt.
    disable ub.gds-dtl.discnt-pc   with frame d-out-prt.
  end.
END.
ON VALUE-CHANGED OF c-reason IN FRAME d-out-prt
DO:
    assign
    c-reason
  .
END.
ON LEAVE OF doc-line.doc-density IN FRAME d-out-prt
DO:
  define buffer buf_doc-pl for ub.doc-pl .
  if input frame d-out-prt ub.doc-line.doc-density <> ub.doc-line.doc-density then do:
    assign
      ub.doc-line.doc-density
    .
    if is-petrolium = yes
      and is-pieces = no
    then do:
      if
  valid-density( ub.doc-line.doc-density, buf_goods.unit-base = buf_goods.unit-cli )
  <> yes
      then do:
        message
          "Неверное значение плотности."
          view-as alert-box.
        apply "ENTRY":U to ub.doc-line.doc-density in frame d-out-prt.
        return no-apply.
      end.
      if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
        if ((ub.doc-line.doc-density) < v-min-dens or (ub.doc-line.doc-density) > v-max-dens)
        then do:
          message
            "Плотность не входит в диапазон."
            view-as alert-box.
          apply "ENTRY":U to ub.doc-line.doc-density in frame d-out-prt.
          return no-apply.
        end.
      end.
      assign
        ub.doc-line.cli-base-rate = 1.00 / ub.doc-line.doc-density
        ub.doc-line.fact-density  = ub.doc-line.doc-density
      .
      if v-price-rubl-kg :sensitive in frame d-out-prt = true
        and v-price-rubl-kg <> 0.0
        and v-price-rubl-kg <> ?
      then do:
        assign
          ub.gds-dtl.price-rubl = v-price-rubl-kg * ub.doc-line.doc-density
          ub.gds-dtl.price-base = v-price-base-kg * ub.doc-line.doc-density
        .
        display
          ub.gds-dtl.price-rubl
          ub.gds-dtl.price-base
          with frame d-out-prt.
      end.
      else do:
        assign
          v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.doc-density
          v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.doc-density
        .
        display
          v-price-rubl-kg
          v-price-base-kg
          with frame d-out-prt.
      end.
      if v-qnty-kg :sensitive in frame d-out-prt = true then do:
        display
          input frame d-out-prt v-qnty-kg / ub.doc-line.doc-density @ ub.gds-dtl.doc-qnty
          with frame d-out-prt.
      end.
      else do:
        display
          input frame d-out-prt ub.gds-dtl.doc-qnty * ub.doc-line.doc-density @ v-qnty-kg
          with frame d-out-prt.
      end.
      if v-place-rsrv = true
        and not ( last-event :event-type   = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
      then do:
        find first tt-doc-pl
          no-error .
        if available tt-doc-pl then do:
          run edit-doc-pl in this-procedure
            ( input 'АВТОИЗМЕНЕНИЕ':U + chr(4) + "update-dens":U
            ).
        end.
        else do:
          run edit-doc-pl in this-procedure
            ( input 'АВТОИЗМЕНЕНИЕ':U
            ).
        end.
      end.
    end.
  end.
END.
ON RETURN OF doc-line.doc-density IN FRAME d-out-prt
DO:
  if t-doc.doc-type = 'возврат':U then do:
    if v-price-rubl-kg :sensitive then do:
      apply "ENTRY":U to v-price-rubl-kg in frame d-out-prt.
      return no-apply.
    end.
    else do:
      if v-price-base-kg :sensitive then do:
        apply "ENTRY":U to v-price-base-kg in frame d-out-prt.
        return no-apply.
      end.
      else do:
        if ub.gds-dtl.price-rubl :sensitive then do:
          apply "ENTRY":U to ub.gds-dtl.price-rubl in frame d-out-prt.
          return no-apply.
        end.
        else do:
          if ub.gds-dtl.price-base :sensitive then do:
            apply "ENTRY":U to ub.gds-dtl.price-base in frame d-out-prt.
            return no-apply.
          end.
        end.
      end.
    end.
  end.
  else do:
    if v-price-rubl-kg :sensitive
      and ( (input frame d-out-prt v-price-rubl-kg ) = ?
            or (input frame d-out-prt v-price-rubl-kg ) = 0.0
          )
    then do:
      apply "ENTRY":U to v-price-rubl-kg in frame d-out-prt.
      return no-apply.
    end.
    else do:
      if v-price-base-kg :sensitive
        and ( (input frame d-out-prt v-price-base-kg ) = ?
              or (input frame d-out-prt v-price-base-kg ) = 0.0
            )
      then do:
        apply "ENTRY":U to v-price-base-kg in frame d-out-prt.
        return no-apply.
      end.
      else do:
        if ub.gds-dtl.price-rubl :sensitive
          and (input frame d-out-prt ub.gds-dtl.price-rubl ) = ?
        then do:
          apply "ENTRY":U to ub.gds-dtl.price-rubl in frame d-out-prt.
          return no-apply.
        end.
        else do:
          if ub.gds-dtl.price-base :sensitive
            and (input frame d-out-prt ub.gds-dtl.price-base ) = ?
          then do:
            apply "ENTRY":U to ub.gds-dtl.price-base in frame d-out-prt.
            return no-apply.
          end.
          else do:
            apply "leave":U to doc-line.doc-density in frame d-out-prt.
            apply "CHOOSE":U to b-exit in frame d-out-prt.
          end.
        end.
      end.
    end.
  end.
END.
ON ENTRY OF gds-dtl.doc-qnty IN FRAME d-out-prt
DO:
  assign
    v-old-doc-qnty = input frame d-out-prt ub.gds-dtl.doc-qnty
  .
END.
ON LEAVE OF gds-dtl.doc-qnty IN FRAME d-out-prt
DO:
  run l-doc-qnty in this-procedure no-error .
  if error-status :error then return no-apply.
END.
ON return OF gds-dtl.doc-qnty IN FRAME d-out-prt
DO:
  if t-doc.doc-type = 'возврат':U then do:
    if ub.gds-dtl.price-rubl :sensitive then do:
      apply "ENTRY":U to ub.gds-dtl.price-rubl in frame d-out-prt.
      return no-apply.
    end.
    else if ub.gds-dtl.price-base :sensitive then do:
      apply "ENTRY":U to ub.gds-dtl.price-base in frame d-out-prt.
      return no-apply.
    end.
  end.
  else do:
    if ub.doc-line.doc-density:sensitive then do:
      apply "entry" to ub.doc-line.doc-density in frame d-out-prt.
      return no-apply.
    end.
    else do:
      if ub.gds-dtl.price-rubl :sensitive
        and (input frame d-out-prt ub.gds-dtl.price-rubl ) = ?
      then do:
        apply "ENTRY":U to ub.gds-dtl.price-rubl in frame d-out-prt.
        return no-apply.
      end.
      else do:
        if ub.gds-dtl.price-base :sensitive
          and (input frame d-out-prt ub.gds-dtl.price-base ) = ?
        then do:
          apply "ENTRY":U to ub.gds-dtl.price-base in frame d-out-prt.
          return no-apply.
        end.
        else do:
          apply "leave":U to gds-dtl.doc-qnty in frame d-out-prt.
          apply "CHOOSE":U to b-exit in frame d-out-prt.
        end.
      end.
    end.
  end.
END.
ON ENTRY OF gds-dtl.fact-qnty IN FRAME d-out-prt
DO:
  assign
    v-old-fact-qnty = input frame d-out-prt ub.gds-dtl.fact-qnty
  .
END.
ON LEAVE OF gds-dtl.fact-qnty IN FRAME d-out-prt
DO:
  run l-fact-qnty in this-procedure no-error .
  if error-status :error then return no-apply.
END.
ON RETURN OF gds-dtl.fact-qnty IN FRAME d-out-prt
DO:
  apply "leave":U to gds-dtl.fact-qnty in frame d-out-prt.
  if error-status :error then do:
    return no-apply.
  end.
  apply "CHOOSE":U to b-exit in frame d-out-prt.
END.
ON mouse-select-dblclick OF g-image IN FRAME d-out-prt
DO:
   DEFINE VARIABLE v-main-code LIKE ub.bar-code.b-code NO-UNDO.
    IF AVAILABLE buf_goods THEN
    DO:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-code
  )  .
        RUN ref/imagelist.w (ParParentProc, "":U, v-main-code, 'ПРОСМОТР':U).
    END.
END.
ON LEAVE OF gds-dtl.new-price-sale IN FRAME d-out-prt
DO:
  if input frame d-out-prt ub.gds-dtl.new-price-sale   <>  ub.gds-dtl.new-price-sale  then do:
      run lineattr-write in this-procedure (
          t-doc.doc-code ,
          buf_goods.gds-code ,
          'corr-price-sale':U,
          string(ub.gds-dtl.new-price-sale)
          ).
      ub.gds-dtl.price-corr = 1.
     display b-corr-price-sale with frame d-out-prt .
     assign ub.gds-dtl.new-price-sale .
  end.
END.
ON LEAVE OF gds-dtl.price-base IN FRAME d-out-prt
DO:
  if input frame d-out-prt ub.gds-dtl.price-base > 5000
    and base-code = 1
  then do:
    message
      "Внимание !!!" skip( 2 )
      "ВАЛЮТНАЯ цена превышает 5,000 !" skip( 2 )
      chr(9) "Вы не ошиблись ?"
      view-as alert-box warning title " В Н И М А Н И Е  ! ! ! ".
  end.
  if ub.gds-dtl.price-base <> input frame d-out-prt ub.gds-dtl.price-base then do:
    assign
      ub.gds-dtl.price-base
    .
    assign
      ub.gds-dtl.ov = yes
      ub.gds-dtl.price-rubl = ub.gds-dtl.price-base * t-doc.base-rate / t-doc.base-scale
      tot-rubl = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
      tot-base = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
    .
    display
      ub.gds-dtl.price-rubl
      tot-rubl
      tot-base
      with frame d-out-prt.
    if is-petrolium = true
      and is-pieces = false
      and
  valid-density( ub.doc-line.doc-density, buf_goods.unit-base = buf_goods.unit-cli )
  = true
    then do:
      assign
        v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.fact-density
        v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.fact-density
      .
      display
        v-price-rubl-kg
        v-price-base-kg
      with frame d-out-prt.
    end.
  end.
  run re-calcpr in this-procedure .
END.
ON LEAVE OF gds-dtl.price-rubl IN FRAME d-out-prt
DO:
  if ub.gds-dtl.price-rubl <> input frame d-out-prt ub.gds-dtl.price-rubl then do:
    assign
      ub.gds-dtl.price-rubl
      .
    assign
      ub.gds-dtl.ov         = yes
      ub.gds-dtl.price-base = ub.gds-dtl.price-rubl / t-doc.base-rate * t-doc.base-scale
    .
    assign
      tot-rubl = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
      tot-base = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
    .
    display
      ub.gds-dtl.price-base
      tot-rubl
      tot-base
      with frame d-out-prt.
    if is-petrolium = true
      and is-pieces = false
      and
  valid-density( ub.doc-line.doc-density, buf_goods.unit-base = buf_goods.unit-cli )
  = true
    then do:
      assign
        v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.fact-density
        v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.fact-density
      .
      display
        v-price-rubl-kg
        v-price-base-kg
        with frame d-out-prt.
    end.
  end.
END.
ON CHOOSE OF r-price IN FRAME d-out-prt
DO:
  run ch-price in this-procedure .
END.
ON LEAVE OF doc-line.temperature IN FRAME d-out-prt
DO:
    assign
    ub.doc-line.temperature
  .
END.
ON ENTRY OF v-fact-qnty-kg IN FRAME d-out-prt
DO:
  assign
    v-old-fact-cli-qnty = input frame d-out-prt v-fact-qnty-kg
  .
END.
ON LEAVE OF v-fact-qnty-kg IN FRAME d-out-prt
DO:
  if ( lookup( t-doc.doc-type, 'при,возврат':U ) > 0 and t-doc.internal
    and ( ub.gds-prt.upper-code = buf_goods.prt-root  or
    can-find( out-dtl no-lock where out-dtl.doc-code  = t-doc.out-code    and
                                    out-dtl.artic     = ub.gds-dtl.artic     and
                                    out-dtl.prod-type = ub.gds-dtl.prod-type and
                                    out-dtl.prod-code = ub.gds-dtl.prod-code and
                                    out-dtl.prt-code  = ub.gds-dtl.prt-code  ) )
    or not lookup( t-doc.doc-type, 'при,возврат':U ) > 0
    or ( t-doc.doc-type = 'возврат':U and not t-doc.internal ) )
    and round (input frame d-out-prt v-fact-qnty-kg / ub.doc-line.fact-density, 1) > round(ub.gds-dtl.doc-qnty, 1)
  then do:
    message "Фактическое количество товара не может быть больше количества по накладной." view-as alert-box.
    apply "ENTRY":U to v-fact-qnty-kg in frame d-out-prt.
    return no-apply.
  end.
  if v-old-fact-cli-qnty <> input frame d-out-prt v-fact-qnty-kg then do:
      if is-petrolium = yes
      and is-pieces = no
      and
  valid-density( ub.doc-line.fact-density, buf_goods.unit-base = buf_goods.unit-cli )
  = yes
    then do:
      display
        input frame d-out-prt v-fact-qnty-kg / ub.doc-line.fact-density @ ub.gds-dtl.fact-qnty
      with frame d-out-prt.
    end.
    if v-place-rsrv = true
      and not ( last-event :event-type = "progress":u
                and last-event :widget-enter = b-place :handle
              )
    then do:
      run edit-doc-pl in this-procedure
        ( input 'АВТОИЗМЕНЕНИЕ':U
        ).
    end.
  end.
END.
ON RETURN OF v-fact-qnty-kg IN FRAME d-out-prt
DO:
  apply "leave":U to v-fact-qnty-kg in frame d-out-prt.
  apply "CHOOSE":U to b-exit in frame d-out-prt.
END.
ON LEAVE OF v-price-base-kg IN FRAME d-out-prt
DO:
  if input frame d-out-prt v-price-base-kg > 5000 and base-code = 1 then do:
    message "Внимание !!!" skip( 2 )
            "ВАЛЮТНАЯ цена превышает 5,000 !" skip( 2 )
            chr(9) "Вы не ошиблись ?"
    view-as alert-box warning title " В Н И М А Н И Е  ! ! ! ".
  end.
  if v-price-base-kg <> input frame d-out-prt v-price-base-kg then do:
    assign
      v-price-rubl-kg
    .
    assign
      ub.gds-dtl.ov   = yes
      v-price-rubl-kg = v-price-base-kg * t-doc.base-rate / t-doc.base-scale
    .
    display
      v-price-rubl-kg
      v-price-base-kg
      with frame d-out-prt.
    if
  valid-density( ub.doc-line.fact-density, buf_goods.unit-base = buf_goods.unit-cli )
  = yes then do:
      assign
        ub.gds-dtl.price-rubl = v-price-rubl-kg * ub.doc-line.fact-density
        ub.gds-dtl.price-base = v-price-base-kg * ub.doc-line.fact-density
        tot-rubl = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
        tot-base = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
      .
      display
        ub.gds-dtl.price-rubl
        ub.gds-dtl.price-base
        tot-rubl
        tot-base
        with frame d-out-prt.
    end.
  end.
END.
ON LEAVE OF v-price-rubl-kg IN FRAME d-out-prt
DO:
    define variable chg-price-rubl as logical no-undo.
  if v-price-rubl-kg <> input frame d-out-prt v-price-rubl-kg then do:
    assign
      v-price-rubl-kg
    .
    assign
      ub.gds-dtl.ov   = yes
      v-price-base-kg = v-price-rubl-kg / t-doc.base-rate * t-doc.base-scale
    .
    display
      v-price-rubl-kg
      v-price-base-kg
      with frame d-out-prt.
    if
  valid-density( ub.doc-line.fact-density, buf_goods.unit-base = buf_goods.unit-cli )
  = yes then do:
      assign
        ub.gds-dtl.price-rubl = v-price-rubl-kg * ub.doc-line.fact-density
        ub.gds-dtl.price-base = v-price-base-kg * ub.doc-line.fact-density
        tot-rubl = input frame d-out-prt ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
        tot-base = input frame d-out-prt ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
      .
      display
        ub.gds-dtl.price-rubl
        ub.gds-dtl.price-base
        tot-rubl
        tot-base
        with frame d-out-prt.
    end.
  end.
END.
ON ENTRY OF v-qnty-kg IN FRAME d-out-prt
DO:
  assign
    v-old-doc-cli-qnty = input frame d-out-prt v-qnty-kg
  .
END.
ON LEAVE OF v-qnty-kg IN FRAME d-out-prt
DO:
  define variable varprt-obj_free-qnty like ub.prt-obj.free-qnty no-undo.
  if v-old-doc-cli-qnty <> input frame d-out-prt v-qnty-kg then do:
    if
  valid-density( ub.doc-line.doc-density, buf_goods.unit-base = buf_goods.unit-cli )
  = yes then do:
      if ( v-price-rubl-kg       =  ? or  v-price-rubl-kg       =  0 ) and
        ( ub.gds-dtl.price-rubl <> ? and ub.gds-dtl.price-rubl <> 0 ) then do:
        assign
          v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.doc-density
        .
        display v-price-rubl-kg with frame d-out-prt.
      end.
      else do:
        assign
          ub.gds-dtl.price-rubl = v-price-rubl-kg * ub.doc-line.doc-density
        .
        display ub.gds-dtl.price-rubl with frame d-out-prt.
      end.
      if ( v-price-base-kg       =  ? or  v-price-base-kg       =  0 ) and
        ( ub.gds-dtl.price-base <> ? and ub.gds-dtl.price-base <> 0 ) then do:
        assign
          v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.doc-density
        .
        display v-price-base-kg with frame d-out-prt.
      end.
      else do:
        assign
          ub.gds-dtl.price-base = v-price-base-kg * ub.doc-line.doc-density
        .
        display ub.gds-dtl.price-rubl with frame d-out-prt.
      end.
      if input frame d-out-prt v-qnty-kg <> ? and input frame d-out-prt v-qnty-kg <> 0 then do:
        display input frame d-out-prt v-qnty-kg / ub.doc-line.doc-density @ ub.gds-dtl.doc-qnty with frame d-out-prt.
      end.
    end.
    if ( is-petrolium = yes
        and is-pieces = no
        and
  valid-density( ub.doc-line.doc-density, buf_goods.unit-base = buf_goods.unit-cli )
  = yes
      )
      or not ( is-petrolium = yes
                and is-pieces = no
              )
    then do:
      if v-place-rsrv = true
        and not ( last-event :event-type = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
      then do:
        run edit-doc-pl in this-procedure
          ( input 'АВТОИЗМЕНЕНИЕ':U
          ).
      end.
    end.
  end.
END.
ON RETURN OF v-qnty-kg IN FRAME d-out-prt
DO:
  if t-doc.doc-type = 'возврат':U then do:
    if v-price-rubl-kg :sensitive then do:
      apply "ENTRY":U to v-price-rubl-kg in frame d-out-prt.
      return no-apply.
    end.
    else do:
      if v-price-base-kg :sensitive then do:
        apply "ENTRY":U to v-price-base-kg in frame d-out-prt.
        return no-apply.
      end.
    end.
  end.
  else do:
    if ub.doc-line.doc-density :sensitive then do:
      apply "entry" to ub.doc-line.doc-density in frame d-out-prt.
      return no-apply.
    end.
    else do:
      if v-price-rubl-kg :sensitive
        and (input frame d-out-prt v-price-rubl-kg ) = ?
      then do:
        apply "ENTRY":U to v-price-rubl-kg in frame d-out-prt.
        return no-apply.
      end.
      else do:
        if v-price-base-kg :sensitive
          and (input frame d-out-prt v-price-base-kg ) = ?
        then do:
          apply "ENTRY":U to v-price-base-kg in frame d-out-prt.
          return no-apply.
        end.
        else do:
          apply "leave":U to v-qnty-kg in frame d-out-prt.
          apply "CHOOSE":U to b-exit in frame d-out-prt.
        end.
      end.
    end.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-out-prt:PARENT eq ?
THEN FRAME d-out-prt:PARENT = ACTIVE-WINDOW.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-out-prt
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
on choose of b-help in frame d-out-prt
do:
  apply "help":u to frame d-out-prt .
end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-out-prt:width - 0.3
                fh            = frame d-out-prt:first-child
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
IF CURRENT-WINDOW :WINDOW-STATE = WINDOW-MINIMIZED THEN DO: CURRENT-WINDOW :WINDOW-STATE = WINDOW-NORMAL. END.
ON WINDOW-CLOSE OF FRAME d-out-prt APPLY "END-ERROR":U TO SELF.
define menu m-rvs-af
    menu-item m-rvs-af-1 label "Сверка резервуара"  accelerator "alt-1"
    menu-item m-rvs-af-2 label "Просмотр"           accelerator "alt-2"
    menu-item m-rvs-af-3 label "Редактирование"     accelerator "alt-3".
define menu m-rvs-bf
    menu-item m-rvs-bf-1 label "Сверка резервуара"  accelerator "alt-1"
    menu-item m-rvs-bf-2 label "Просмотр"           accelerator "alt-2"
    menu-item m-rvs-bf-3 label "Редактирование"     accelerator "alt-3".
on choose of menu-item m-rvs-bf-1 in menu m-rvs-bf
do:
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-bf :type in frame d-out-prt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-out-prt skip
    "Тип" self :type in frame d-out-prt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-bf in frame d-out-prt .
  if focus :handle <> b-rvs-bf :handle in frame d-out-prt then do:
    return no-apply .
  end.
end.
  run action-rvs-line in this-procedure
    ( input 'ИЗМЕНЕНИЕ':U
     ,input "meas":U
     ,input 'перед_док':U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
end.
on choose of menu-item m-rvs-af-1 in menu m-rvs-af
do:
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-af :type in frame d-out-prt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-out-prt skip
    "Тип" self :type in frame d-out-prt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-af in frame d-out-prt .
  if focus :handle <> b-rvs-af :handle in frame d-out-prt then do:
    return no-apply .
  end.
end.
  run action-rvs-line in this-procedure
    ( input 'ИЗМЕНЕНИЕ':U
     ,input "meas":U
     ,input 'после_док':U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
end.
on choose of menu-item m-rvs-bf-2 in menu m-rvs-bf
or choose of b-rvs-bf in frame d-out-prt
do:
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-bf :type in frame d-out-prt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-out-prt skip
    "Тип" self :type in frame d-out-prt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-bf in frame d-out-prt .
  if focus :handle <> b-rvs-bf :handle in frame d-out-prt then do:
    return no-apply .
  end.
end.
  run action-rvs-line in this-procedure
    ( input 'ПРОСМОТР':U
     ,input "edit":U
     ,input 'перед_док':U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
end.
on choose of menu-item m-rvs-af-2 in menu m-rvs-af
or choose of b-rvs-af in frame d-out-prt
do:
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-af :type in frame d-out-prt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-out-prt skip
    "Тип" self :type in frame d-out-prt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-af in frame d-out-prt .
  if focus :handle <> b-rvs-af :handle in frame d-out-prt then do:
    return no-apply .
  end.
end.
  run action-rvs-line in this-procedure
    ( input 'ПРОСМОТР':U
     ,input "edit":U
     ,input 'после_док':U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
end.
on choose of menu-item m-rvs-bf-3 in menu m-rvs-bf
do:
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-bf :type in frame d-out-prt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-out-prt skip
    "Тип" self :type in frame d-out-prt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-bf in frame d-out-prt .
  if focus :handle <> b-rvs-bf :handle in frame d-out-prt then do:
    return no-apply .
  end.
end.
  run action-rvs-line in this-procedure
    ( input 'ИЗМЕНЕНИЕ':U
     ,input "edit":U
     ,input 'перед_док':U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
end.
on choose of menu-item m-rvs-af-3 in menu m-rvs-af
do:
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-af :type in frame d-out-prt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-out-prt skip
    "Тип" self :type in frame d-out-prt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-af in frame d-out-prt .
  if focus :handle <> b-rvs-af :handle in frame d-out-prt then do:
    return no-apply .
  end.
end.
  run action-rvs-line in this-procedure
    ( input 'ИЗМЕНЕНИЕ':U
     ,input "edit":U
     ,input 'после_док':U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :
  define buffer buf_doc-pl   for ub.doc-pl.
  define buffer buf_currency for ub.currency  .
  define buffer buf_doc-pl-attr for ub.doc-pl-attr .
  define buffer buf_contract    for ub.contract.
  define variable vGtin     as character no-undo.
  define variable vGtinQnty as integer no-undo.
  define variable vExistGdsDtl as logical no-undo init true.
  if num-entries(prt-mode, chr(4)) = 2
  then do :
    if entry(2, prt-mode, chr(4)) begins "return"
    then do :
      v-is-return = true .
      in-part-rec = integer(trim(entry(2, prt-mode, chr(4)), "return=")) no-error .
    end .
    prt-mode = entry(1, prt-mode, chr(4)) .
  end .
  assign
    v-undo-all = false
    TEXT-1 = "РУБ"
  .
  display TEXT-1 with frame d-out-prt .
  find first t-doc no-lock
    where recid(t-doc) = doc-rec
    .
  if v-is-return then
  do:
    for first buf_contract no-lock where
              buf_contract.host-code     = t-doc.host-code
          and buf_contract.contract-code = t-doc.contract-code
    :
      vBackSale = (buf_contract.spec-check = 23).
    end.
  end.
  find first ub.gds-prt no-lock
    where recid( ub.gds-prt ) = cur-rec
    .
  if prt-mode = 'ШКАЛА':U
    and node-type <> 'терм':U
  then do:
    message
      "В режиме ШКАЛА можно указывать количества только по терминальным признакам."
      view-as alert-box.
    undo main-block, return error.
  end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output g#host-code
  ,output g#host-name
  )  .
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  g#host-code
  ,output base-code
  )  .
  find first buf_currency no-lock
    where buf_currency.curr-code = base-code
    no-error.
  if available buf_currency then do:
    assign
      base-type = buf_currency.curr-abbr
    .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ptoldfil'
  ,input  t-doc.host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output ptoldfilvalue
  ,output ptoldfiltype
  ) no-error .
  pr-genmrg   =  "" .
  pr-naklvalue = false  .
if t-doc.ext-doc-type = 'iv':U then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplmrgn in g#library2
  (input  parparentproc
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output par-1
  ,output pr-genmrg
  ,output par-1
  ) no-error .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplpnakl in g#library2
  (input  parparentproc
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output par-0
  ,output pr-naklvalue
  ,output par-0
  ) no-error .
end.
  assign
    stfactplvalue    = "":U
    varupd-fact-qnty = false
  .
  if t-doc.ext-doc-type = 'iv':U then do:
     varupd-fact-qnty = true .
     if t-doc.status_ =  'запрос':U then do:
        assign
          v-work-with-qnty = "doc":U
         .
     end.
     else do:
        assign
          v-work-with-qnty = "fact-doc":U
        .
     end.
  end.
  else do:
    if t-doc.status_ <> 'факт':U
      and t-doc.status_ <> 'разрешен':U
      and t-doc.flag_ = false
    then do:
      assign
        v-work-with-qnty = "doc":U
      .
    end.
    else do:
      assign
        v-work-with-qnty = "fact":U
      .
      if t-doc.ext-doc-type <> 'rv':U then do:
        assign
          varupd-fact-qnty = true
        .
      end.
    end.
  end.
  find buf_goods   no-lock
    where recid( buf_goods ) = gds-rec
    .
  find ub.clients no-lock
    where ub.clients.obj-code = buf_goods.prod-code
      and ub.clients.obj-type = buf_goods.prod-type
    .
  find ub.prt-obj no-lock
    where ub.prt-obj.prt-code  = ub.gds-prt.node-code
      and ub.prt-obj.prod-code = buf_goods.prod-code
      and ub.prt-obj.prod-type = buf_goods.prod-type
      and ub.prt-obj.artic     = buf_goods.artic
      and ub.prt-obj.obj-code  = t-doc.obj-code
      and ub.prt-obj.obj-type  = t-doc.obj-type
    no-error.
  if prt-mode = 'ПРОСМОТР':U then do:
    find ub.doc-line no-lock
      where recid( ub.doc-line ) = line-rec
      .
    find ub.gds-dtl  no-lock
      where ub.gds-dtl.prt-code  = ub.gds-prt.node-code
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.artic     = ub.doc-line.artic
        and ub.gds-dtl.doc-code  = t-doc.doc-code
      no-error.
    find ub.inv-line no-lock
      where ub.inv-line.doc-code  = t-doc.doc-code
        and ub.inv-line.artic     = ub.doc-line.artic
        and ub.inv-line.prod-code = ub.doc-line.prod-code
        and ub.inv-line.prod-type = ub.doc-line.prod-type
      no-error.
  end.
  else do:
    find first t-doc
      where recid(t-doc) = doc-rec
      .
    find ub.doc-line exclusive-lock
      where recid( ub.doc-line ) = line-rec
      .
    find ub.gds-dtl  exclusive-lock
      where ub.gds-dtl.prt-code  = ub.gds-prt.node-code
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.artic     = ub.doc-line.artic
        and ub.gds-dtl.doc-code  = t-doc.doc-code
      no-error.
    find ub.inv-line exclusive-lock
      where ub.inv-line.doc-code  = ub.doc-line.doc-code
        and ub.inv-line.artic     = ub.doc-line.artic
        and ub.inv-line.prod-code = ub.doc-line.prod-code
        and ub.inv-line.prod-type = ub.doc-line.prod-type
      no-error.
  end.
  assign
    r-recid-petrol-kg = ( if available ub.inv-line then recid( ub.inv-line ) else ? )
  .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  t-doc.doc-code
  ,output v-hold-doc
  )  .
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'place-rsrv=request'
  ,output v-place-rsrv
  ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.
  if not available ub.gds-dtl then do:
    vExistGdsDtl = false.
    if ( lookup( t-doc.doc-type, 'при,возврат':U ) > 0
      and t-doc.internal
      and ( ub.gds-prt.upper-code = buf_goods.prt-root  or
        can-find( out-dtl no-lock where out-dtl.doc-code  = t-doc.out-code       and
                                        out-dtl.artic     = ub.gds-dtl.artic     and
                                        out-dtl.prod-type = ub.gds-dtl.prod-type and
                                        out-dtl.prod-code = ub.gds-dtl.prod-code and
                                        out-dtl.prt-code  = ub.gds-dtl.prt-code  ) )
      or lookup( t-doc.doc-type, 'при,возврат':U ) = 0 )
      and ( t-doc.flag_ or t-doc.status_ = 'разрешен':U ) or
      prt-mode = 'ПРОСМОТР':U
    then do:
      message "Товара с таким признаком нет в данной накладной." view-as alert-box.
      undo main-block, return error.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input t-doc.obj-code
   ,input t-doc.obj-type
   ,input t-doc.doc-code
   ,input ub.doc-line.artic
   ,input ub.doc-line.prod-code
   ,input ub.doc-line.prod-type
   ,input ub.gds-prt.node-code
   ,input yes
  ) no-error .
    if error-status :error then do:
      message
        "Ошибка при создании признака." skip
        return-value
        view-as alert-box error.
      undo main-block, return error.
    end.
    assign
      add-def-mode = true
    .
    find first ub.gds-dtl
      where ub.gds-dtl.doc-code  = t-doc.doc-code
        and ub.gds-dtl.artic     = ub.doc-line.artic
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.prt-code  = ub.gds-prt.node-code
      .
    assign
      ub.gds-dtl.price-base  = ?
      ub.gds-dtl.price-rubl  = ?
      v-price-base-kg        = ?
      v-price-rubl-kg        = ?
      ub.gds-dtl.discnt-type = yes
      ub.gds-dtl.discnt-base = 0
      ub.gds-dtl.discnt-rubl = 0
      ub.gds-dtl.discnt-pc   = 0
    .
    if t-doc.doc-type = 'при':U and prt-mode = 'ШКАЛА':U and not t-doc.internal then do:
      assign
        ub.gds-dtl.price-base = ub.doc-line.price-base
        ub.gds-dtl.price-rubl = ub.doc-line.price-rubl
      .
      for each g-d-b where g-d-b.prod-code = ub.doc-line.prod-code
                       and g-d-b.prod-type = ub.doc-line.prod-type
                       and g-d-b.artic     = ub.doc-line.artic
                       and g-d-b.doc-code  = ub.doc-line.doc-code :
        accumulate g-d-b.doc-qnty  ( total )
                   g-d-b.fact-qnty ( total ) .
      end.
      if v-work-with-qnty = "doc":U then do:
        if ub.doc-line.doc-qnty - ( accum total g-d-b.doc-qnty ) > 0 then do:
          display
            ub.doc-line.doc-qnty - ( accum total g-d-b.doc-qnty ) @ ub.gds-dtl.doc-qnty
          with frame d-out-prt.
        end.
        else do:
          display
            0 @ ub.gds-dtl.doc-qnty
          with frame d-out-prt.
        end.
      end.
      else do:
        if ub.doc-line.fact-qnty - ( accum total g-d-b.fact-qnty ) > 0 then do:
          display
            ub.doc-line.fact-qnty - ( accum total g-d-b.fact-qnty ) @ ub.gds-dtl.fact-qnty
          with frame d-out-prt.
        end.
        else do:
          display
            0 @ ub.gds-dtl.fact-qnty
          with frame d-out-prt.
        end.
      end.
    end.
    if lookup( t-doc.doc-type, 'при,возврат':U ) > 0 and prt-mode = 'ШКАЛА':U and t-doc.internal then do:
      find first g-d-b no-lock where g-d-b.doc-code  = ub.doc-line.doc-code
                                 and g-d-b.prod-type = ub.doc-line.prod-type
                                 and g-d-b.prod-code = ub.doc-line.prod-code
                                 and g-d-b.artic     = ub.doc-line.artic
                                 and g-d-b.prt-code  <> ub.gds-prt.node-code no-error.
      if available g-d-b then do:
        assign
          ub.gds-dtl.price-base = g-d-b.price-base
          ub.gds-dtl.price-rubl = g-d-b.price-rubl
        .
      end.
    end.
  end.
  if prt-mode <> 'ПРОСМОТР':U then do:
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(ub.gds-dtl)
  , input no
  , input ub.gds-dtl.doc-qnty
  ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "333"
        view-as alert-box error
      .
      undo main-block, return error return-value.
    end.
    find ub.gds-prt no-lock where recid( ub.gds-prt ) = cur-rec.
  end.
  if v-is-return and in-part-rec > 0
  and (not vExistGdsDtl or not vBackSale)
  then do :
    find first in_parts no-lock where recid(in_parts) = in-part-rec no-error .
    if available in_parts
    then do :
      assign
        ub.gds-dtl.price-base = in_parts.price-base
        ub.gds-dtl.price-rubl = in_parts.price-rubl
        ub.gds-dtl.ov         = yes
      .
    end .
  end.
  assign
    frame d-out-prt :title = "Документ №  " + t-doc.doc-code + "    " +  'строка':U + "     " + prt-mode
  .
  assign
    base-curr = base-type
  .
  if v-place-rsrv = yes then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
    if error-status :error then do:
      assign
        is-petrolium = no
        is-pieces    = no
      .
    end.
    if is-petrolium = true
      and is-pieces = false
    then do:
      if  v-hold-doc = true
      then do:
        message
          substitute( "Товар (код &1) топливный!", buf_goods.gds-code ) skip
          "Поэтому не может участвовать в межфирменном перемещении!" skip
          view-as alert-box.
        undo main-block, return error.
      end.
      run gds-attr-value in this-procedure
        ( input  buf_goods.gds-code
          ,input  'ptrl-without-rvs':U
          ,output v-ptrl-without-rvs
          ,output v-attr-type
        ) .
      run gds-attr-value in this-procedure
        ( input  buf_goods.gds-code
          ,input  'gds-ptrl-densities':U
          ,output v-gds-ptrl-densities
          ,output v-attr-type
        ) .
        if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
            assign
              v-min-dens = decimal(replace(entry(1, v-gds-ptrl-densities, "-":U ), "кг\л", "":U))
              v-max-dens = decimal(replace(entry(2, v-gds-ptrl-densities, "-":U ), "кг\л":U, "":U))
            no-error .
        end.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input t-doc.obj-type
  , input t-doc.obj-code
  ) .
      if t-doc.ext-doc-type = 'iv':U then do:
            assign
              varupd-fact-qnty = false
            .
      end.
      assign
        ub.gds-dtl.price-rubl :label in frame d-out-prt = substitute("Цена,&1", buf_goods.unit-base )
        v-price-rubl-kg       :label in frame d-out-prt = substitute("Цена,&1", buf_goods.unit-cli )
        ub.gds-dtl.doc-qnty   :label in frame d-out-prt = substitute("По док,&1", buf_goods.unit-base )
        ub.gds-dtl.fact-qnty  :label in frame d-out-prt = substitute("Факт,&1", buf_goods.unit-base )
        v-qnty-kg             :label in frame d-out-prt = substitute("По док,&1", buf_goods.unit-cli )
        v-fact-qnty-kg        :label in frame d-out-prt = substitute("Факт,&1", buf_goods.unit-cli )
      .
      if t-doc.status_ <> 'факт':U
        and prt-mode <> 'ПРОСМОТР':U
      then do:
        assign
          b-rvs-bf:popup-menu in frame d-out-prt = menu m-rvs-bf:handle
          b-rvs-bf:menu-mouse = 1
          b-rvs-af:popup-menu in frame d-out-prt = menu m-rvs-af:handle
          b-rvs-af:menu-mouse = 1
        .
      end.
      run str/in-laddout.w
        ( input        parParentProc
         ,input        "get-attr":U
         ,input        t-doc.doc-code
         ,input        buf_goods.gds-code
         ,input-output v-prt-car-num
         ,input-output v-prt-car-vol
         ,input-output v-prt-tests
         ,input-output v-prt-autoent-obj-type
         ,input-output v-prt-autoent-obj-code
         ,input-output v-prt-item-pour
         ,input-output v-prt-time-pour
         ,input-output v-prt-tank-vol
         ,input-output v-prt-tank-temp
         ,input-output v-prt-tank-water
         ,input-output v-prt-tank-density
         ,input-output v-prt-tank-weight
         ,input-output v-prt-time-income
         ,input-output v-prt-start-real-date
         ,input-output v-prt-start-real-time
         ,input-output v-prt-end-real-date
         ,input-output v-prt-end-real-time
         ,input-output v-prt-mouth
         ,input-output v-prt-fio
         ,input-output v-prt-ptbotype
         ,input-output v-prt-ptbocode
         ,input-output v-prt-a-b-tarir
         ,input-output v-diameter
         ,input-output v-place-si
         ,input-output v-tank-density-pomi
         ,input-output v-prt-certif-fuel
         ,input-output v-prt-norm-doc
         ,input-output v-prt-num-passport
         ,input-output v-prt-validity-certif
         ,input-output v-prt-passport-plotn
         ,input-output v-prt-num-plotn
         ,input-output v-prt-date-pov-plotn
         ,      output was_setting
        ) .
      if stfactplvalue <> "":U then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_chkqtpl in g#lib-calc
  (  input stfactplvalue
  , output varupd-fact-qnty
  , output varrevision
  , output varpercrev
  , output varauto-tank
  , output varpercauto
  , output varinv
  , output varpercinv
  , output varinv-set
  ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Разборе строки параметра stfactpl" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return error .
        end.
      end.
    end.
    else do:
      assign
        ptrlprop-expptrl = ?
      .
    end.
    for each tt-doc-pl
    on error undo main-block, return error error-status :get-message(1)
    :
      delete tt-doc-pl .
    end.
    for each buf_doc-pl no-lock
      where buf_doc-pl.obj-type = t-doc.obj-type
        and buf_doc-pl.obj-code = t-doc.obj-code
        and buf_doc-pl.out-code = t-doc.doc-code
        and buf_doc-pl.gds-code = buf_goods.gds-code
    on error undo main-block, return error error-status :get-message(1)
    :
      create tt-doc-pl .
      buffer-copy buf_doc-pl to tt-doc-pl .
      if t-doc.ext-doc-type = 'eo':U
      then
      for first buf_doc-pl-attr no-lock
          where buf_doc-pl-attr.obj-type    = buf_doc-pl.obj-type
            and buf_doc-pl-attr.obj-code    = buf_doc-pl.obj-code
            and buf_doc-pl-attr.pl-code     = buf_doc-pl.pl-code
            and buf_doc-pl-attr.out-code    = buf_doc-pl.out-code
            and buf_doc-pl-attr.gds-code    = buf_doc-pl.gds-code
            and buf_doc-pl-attr.attr-code   = 'place2' :
           assign tt-doc-pl.pl-code2 = integer(buf_doc-pl-attr.attr-value) .
      end.
      if t-doc.ext-doc-type = 'io':U
      then
      for first buf_doc-pl-attr no-lock
          where buf_doc-pl-attr.obj-type    = buf_doc-pl.obj-type
            and buf_doc-pl-attr.obj-code    = buf_doc-pl.obj-code
            and buf_doc-pl-attr.attr-value  = string(buf_doc-pl.pl-code)
            and buf_doc-pl-attr.out-code    = (replace(buf_doc-pl.out-code, '=', '-'))
            and buf_doc-pl-attr.gds-code    = buf_doc-pl.gds-code
            and buf_doc-pl-attr.attr-code   = 'place2' :
          assign tt-doc-pl.pl-code2 = buf_doc-pl-attr.pl-code .
      end.
    end.
    find first tt-doc-pl no-lock
      no-error.
    if not available tt-doc-pl
      and add-def-mode <> true
    then do:
      message
        substitute( "Товар &1", buf_goods.gds-code ) skip
        "не распределен по местам хранения."
        view-as alert-box.
    end.
  end.
  IF mImagePh THEN
  DO:
    IF AVAILABLE buf_goods THEN
    DO:
        DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
        DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
        RUN gds-attr-value (buf_goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
        RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, INPUT buf_goods.gds-code,OUTPUT vImageList).
        vCh = ENTRY (1, vImageList, ",":U).
    END.
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
  END.
  ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
  if t-doc.ext-doc-type = 'we':U then run init-temp in this-procedure no-error .
  run UI-on in this-procedure
    no-error .
  if error-status :error then do:
    undo main-block, return error return-value.
  end.
  if v-place-rsrv = yes then do:
    enable
      b-place
      with frame d-out-prt
    .
  end.
  else do:
    hide
      b-place
      in frame d-out-prt
    .
  end.
  if node-type begins "scan-marks" then
    vScanMark = entry(2,node-type,chr(3)).
  if prt-mode = 'ПРОСМОТР':U then do:
    if not is-petrolium then do:
      if ub.gds-dtl.fact-qnty:hidden = false
      then do:
        display
          v-fact-qnty-kg
        with frame d-out-prt.
      end.
      display
        v-qnty-kg
      with frame d-out-prt.
      v-qnty-kg             = ub.gds-dtl.doc-qnty / buf_goods.cli-base-rate.
      v-fact-qnty-kg        = ub.gds-dtl.fact-qnty / buf_goods.cli-base-rate.
      v-qnty-kg:screen-value = string (v-qnty-kg).
      v-fact-qnty-kg:screen-value = string (v-fact-qnty-kg).
      assign
        ub.gds-dtl.price-rubl :label in frame d-out-prt = substitute("Цена,&1", buf_goods.unit-base )
        v-price-rubl-kg       :label in frame d-out-prt = substitute("Цена,&1", buf_goods.unit-cli )
        ub.gds-dtl.doc-qnty   :label in frame d-out-prt = substitute("По док,&1", buf_goods.unit-base )
        ub.gds-dtl.fact-qnty  :label in frame d-out-prt = substitute("Факт,&1", buf_goods.unit-base )
        v-qnty-kg             :label in frame d-out-prt = substitute("По док,&1", buf_goods.unit-cli )
        v-fact-qnty-kg        :label in frame d-out-prt = substitute("Факт,&1", buf_goods.unit-cli )
      .
    end.
    wait-for go of frame d-out-prt focus b-exit.
  end.
  else do:
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
    RUN gds-attr-value (
                        INPUT buf_goods.gds-code,
                        INPUT 'mark-type':U,
                        OUTPUT varvalue,
                        OUTPUT vartype
                        ).
    if varvalue > ""
    and EDOParSec:GetIsMarkingForType(varvalue)
    then do :
      disable
        ub.gds-dtl.fact-qnty
        ub.gds-dtl.doc-qnty
      with frame d-out-prt .
    end .
    v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code) .
    if v-is-return
    and (EDOParSec:GetIsArticForType(varvalue)
     or EDOParSec:GetIsEDOForType(varvalue)
     or EDOParSec:GetIsMarkingForType(varvalue))
    then do :
      disable
        ub.gds-dtl.fact-qnty
        ub.gds-dtl.doc-qnty
      with frame d-out-prt .
      if node-type = "Transitional"
      then do :
        enable
          ub.gds-dtl.doc-qnty
        with frame d-out-prt .
      end .
    end .
    if v-work-with-qnty = "doc":U then do:
      if t-doc.doc-type = 'рас':U and input frame d-out-prt ub.gds-dtl.doc-qnty = 0 then do:
        if ptrlprop-expptrl = 'weight':U
          and v-qnty-kg :sensitive in frame d-out-prt
        then do:
          display
            1 @ v-qnty-kg
          with frame d-out-prt.
        end.
        else do:
          display
            1 @ ub.gds-dtl.doc-qnty
          with frame d-out-prt.
          if v-is-return
          then do :
            display
              0 @ ub.gds-dtl.doc-qnty
            with frame d-out-prt.
          end .
        end.
      end.
      if ptrlprop-expptrl = 'weight':U
        and v-qnty-kg :sensitive in frame d-out-prt
      then do:
        wait-for go of frame d-out-prt focus v-qnty-kg .
      end.
      else do:
        if not is-petrolium then do:
          display
            ub.gds-dtl.doc-qnty
            v-qnty-kg
          with frame d-out-prt.
          if ub.gds-dtl.fact-qnty:hidden = false
          then do:
            display
              v-fact-qnty-kg
            with frame d-out-prt.
          end.
          v-qnty-kg             = ub.gds-dtl.doc-qnty / buf_goods.cli-base-rate.
          v-fact-qnty-kg        = ub.gds-dtl.fact-qnty / buf_goods.cli-base-rate.
          v-qnty-kg:screen-value = string (v-qnty-kg).
          v-fact-qnty-kg:screen-value = string (v-fact-qnty-kg).
          assign
            ub.gds-dtl.price-rubl :label in frame d-out-prt = substitute("Цена,&1", buf_goods.unit-base )
            v-price-rubl-kg       :label in frame d-out-prt = substitute("Цена,&1", buf_goods.unit-cli )
            ub.gds-dtl.doc-qnty   :label in frame d-out-prt = substitute("По док,&1", buf_goods.unit-base )
            ub.gds-dtl.fact-qnty  :label in frame d-out-prt = substitute("Факт,&1", buf_goods.unit-base )
            v-qnty-kg             :label in frame d-out-prt = substitute("По док,&1", buf_goods.unit-cli )
            v-fact-qnty-kg        :label in frame d-out-prt = substitute("Факт,&1", buf_goods.unit-cli )
          .
          if t-doc.doc-type = 'рас':U and input frame d-out-prt ub.gds-dtl.doc-qnty = 0 then do:
            if ptrlprop-expptrl = 'weight':U
              and v-qnty-kg :sensitive in frame d-out-prt
            then do:
              display
                1 @ v-qnty-kg
              with frame d-out-prt.
            end.
            else do:
              display
                1 @ ub.gds-dtl.doc-qnty
              with frame d-out-prt.
              if v-is-return
              or v-isweighed
              then do :
                display
                  0 @ ub.gds-dtl.doc-qnty
                with frame d-out-prt.
              end .
            end.
          end.
        end.
        if t-doc.ext-doc-type = 'ev':U or
           t-doc.ext-doc-type = 'we':U then
        do:
            run isExemplarGoods in this-procedure
              (t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code, output vIsExemplarGoods).
            if vIsExemplarGoods
            or v-isweighed
            then do:
              if t-doc.ext-doc-type = 'ev':U and
                 can-find(first buf_marking-lines no-lock where
                                  buf_marking-lines.out-code = ub.gds-dtl.doc-code
                              and buf_marking-lines.gds-code = buf_goods.gds-code) then
              do:
                vRightChngQnty = false.
              end.
              else
              do:
                  vRightChngQntyCode = if t-doc.ext-doc-type = 'we':U
                      then 'actn_write-off_add-no-mark':U
                      else 'actn_tdedt-ras-perem_add-no-mark':U.
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  vRightChngQntyCode
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output vRightChngQnty
    )  .
end.
              end.
              if not vRightChngQnty then
                disable ub.gds-dtl.doc-qnty with frame d-out-prt.
            end.
        end.
        if node-type begins "scan-marks" then do:
          find first buf_marking no-lock where buf_marking.mark begins entry(2,node-type,chr(3)) no-error .
          if v-is-return
          then do :
            if available buf_marking
            then do :
              if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
              and EDOParSec:GetIsMarkingForType(varvalue)
              then do :
                message "Марка " buf_marking.mark " не в свободной зоне!" view-as alert-box .
                undo, return error .
              end .
              if v-isweighed
              then do :
                v-mark-weight = MarkWeight(buf_marking.mark).
                if v-mark-weight = 0
                or v-mark-weight = ?
                then do :
                  message "Марка не может быть добавлена, т.к. в БД отсутствует ее вес." view-as alert-box .
                  undo, return error .
                end .
                ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + v-mark-weight) .
              end .
              else do :
                ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + 1).
              end .
            end .
            else do :
              if v-isweighed
              then do :
                message "Марка не найдена в БД." view-as alert-box .
                undo, return error .
              end .
              else do :
                ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + 1).
              end .
            end .
          end .
          else do :
            if not available buf_marking
            then do :
              undo, return error return-value .
            end .
            if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB
            then do :
              message "Марка " buf_marking.mark " не в свободной зоне!" view-as alert-box .
              undo, return error .
            end .
            if buf_marking.box-qnty = 0 then
            do:
              vGtin     = getGtinByDM(buf_marking.mark) .
              vGtinQnty = getQntyCodeByGtin(vGtin).
            end.
            if v-isweighed
            then do :
              v-mark-weight = MarkWeight(buf_marking.mark).
              if v-mark-weight = 0
              or v-mark-weight = ?
              then do :
                message "Марка не может быть добавлена, т.к. в БД отсутствует ее вес." view-as alert-box .
                undo, return error .
              end .
              find first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking.mark-parent
                                                     and buf_marking-lines.out-code = ub.gds-dtl.doc-code
                                                     no-error .
              if not available buf_marking-lines
              then do :
                ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + v-mark-weight).
              end .
            end .
            else do :
              case buf_marking.unit-ext :
                when "LEVEL2"
                then do :
                  ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + if buf_marking.box-qnty <> 0 then buf_marking.box-qnty else vGtinQnty).
                end .
                when "LEVEL1"
                then do :
                  assign v-pack-qnty = 0 .
                  for each buf_marking-child no-lock where buf_marking-child.mark-parent = buf_marking.mark,
                  first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking-child.mark-parent
                                                    and buf_marking-lines.out-code = ub.gds-dtl.doc-code :
                    assign v-pack-qnty = v-pack-qnty + 1 .
                  end .
                  ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + buf_marking.box-qnty - v-pack-qnty).
                end .
                otherwise do :
                  find first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking.mark-parent
                                                         and buf_marking-lines.out-code = ub.gds-dtl.doc-code
                                                         no-error .
                  if not available buf_marking-lines
                  then do :
                    ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + if buf_marking.box-qnty <> 0 then buf_marking.box-qnty else vGtinQnty).
                  end .
                end .
              end case .
            end .
          end .
          apply "LEAVE":U to ub.gds-dtl.doc-qnty in frame d-out-prt.
          apply "CHOOSE":U to b-exit in frame d-out-prt.
        end.
        else do:
        wait-for go of frame d-out-prt focus ub.gds-dtl.doc-qnty .
        end.
      end.
    end.
    else do:
      if t-doc.ext-doc-type = 'iv':U then
      do:
        if can-find(first buf_marking-lines where
                          buf_marking-lines.out-code = ub.gds-dtl.doc-code
                      and buf_marking-lines.gds-code = buf_goods.gds-code) then
          disable ub.gds-dtl.fact-qnty with frame d-out-prt.
      end.
      if t-doc.ext-doc-type = 'ev':U or
         t-doc.ext-doc-type = 'we':U then
      do:
          run isExemplarGoods in this-procedure
            (t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code, output vIsExemplarGoods).
          if vIsExemplarGoods
          or v-isweighed
          then do:
            if t-doc.ext-doc-type = 'ev':U and
               can-find(first buf_marking-lines no-lock where
                                buf_marking-lines.out-code = ub.gds-dtl.doc-code
                            and buf_marking-lines.gds-code = buf_goods.gds-code) then
            do:
              vRightChngQnty = false.
            end.
            else
            do:
                vRightChngQntyCode = if t-doc.ext-doc-type = 'we':U
                    then 'actn_write-off_add-no-mark':U
                    else 'actn_tdedt-ras-perem_add-no-mark':U.
define variable vss-include-info61 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  vRightChngQntyCode
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output vRightChngQnty
    )  .
end.
            end.
            if not vRightChngQnty then
              disable ub.gds-dtl.fact-qnty with frame d-out-prt.
          end.
      end.
      if ptrlprop-expptrl = 'weight':U
        and v-fact-qnty-kg :sensitive in frame d-out-prt
      then do:
        wait-for go of frame d-out-prt focus v-fact-qnty-kg.
      end.
      else do:
        if ub.gds-dtl.fact-qnty :sensitive in frame d-out-prt then do:
          wait-for go of frame d-out-prt focus ub.gds-dtl.fact-qnty.
        end.
        else do:
          wait-for go of frame d-out-prt focus b-exit.
        end.
      end.
    end.
  end.
END.
RUN disable_UI IN THIS-PROCEDURE.
if v-no-add-marks
then do :
  return "no-add-marks" .
end .
if v-undo-all = true then do:
  undo, return error.
end.
PROCEDURE ch-price :
define variable v-cli-type    as character no-undo .
define variable v-cli-code    as integer   no-undo .
define variable v-main-b-code as integer   no-undo .
define variable v-b-code      as integer   no-undo .
define variable v-obj-type    as character no-undo .
define variable v-obj-code    as integer   no-undo .
define variable v-qnty-doc    as decimal   no-undo .
define variable v-sum-doc     as decimal   no-undo .
define variable v-fact-order  as decimal   no-undo .
define variable v-plt-id      as integer   no-undo .
define variable v-plt-db-num  as integer   no-undo .
define variable v-pdf-id      as integer   no-undo .
define variable v-pdf-db-num  as integer   no-undo .
define variable v-sale-price-base as decimal   no-undo .
define variable v-sale-price-rubl as decimal   no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  b-c-b.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
 run fact-order-mpl  in this-procedure (
     input t-doc.doc-date ,
     input t-doc.obj-type ,
     input t-doc.obj-code ,
     output v-fact-order )
     .
assign
  v-cli-type      = t-doc.cli-type
  v-cli-code      = t-doc.cli-code
  v-b-code        = b-c-b.b-code
  v-obj-type      = t-doc.obj-type
  v-obj-code      = t-doc.obj-code
  .
  if ub.gds-dtl.doc-qnty:visible in frame d-out-prt and ub.gds-dtl.doc-qnty:SENSITIVE then
     v-qnty-doc      = input frame d-out-prt ub.gds-dtl.doc-qnty.
  if ub.gds-dtl.fact-qnty:visible in frame d-out-prt and ub.gds-dtl.fact-qnty:SENSITIVE then
     v-qnty-doc      = input frame d-out-prt ub.gds-dtl.fact-qnty.
 v-sum-doc       = 0 .
 run str/chmpldoc.w
        (input parparentproc
        ,input  v-cli-type
        ,input  v-cli-code
        ,input  v-main-b-code
        ,input  v-b-code
        ,input  v-obj-type
        ,input  v-obj-code
        ,input  v-qnty-doc
        ,input  v-sum-doc
        ,input  string(t-doc.pay-code)
        ,input  ""
        ,input  v-fact-order
        ,output v-plt-id
        ,output v-plt-db-num
        ,output v-pdf-id
        ,output v-pdf-db-num
        ,output v-sale-price-base
        ,output v-sale-price-rubl
        ).
if v-plt-id = ? then return.
 if ub.gds-dtl.price-rubl:visible in frame d-out-prt and ub.gds-dtl.price-rubl:SENSITIVE then do:
    display v-sale-price-rubl @ ub.gds-dtl.price-rubl with frame d-out-prt .
    display v-sale-price-base @ ub.gds-dtl.price-base with frame  d-out-prt .
    apply "leave" to ub.gds-dtl.price-rubl in frame d-out-prt.
 end.
 else do:
    if ub.gds-dtl.price-base:visible and  ub.gds-dtl.price-base:SENSITIVE then do:
        ub.gds-dtl.price-base = v-sale-price-base .
        display ub.gds-dtl.price-base with frame d-out-prt .
        display v-sale-price-rubl @ ub.gds-dtl.price-rubl with frame d-out-prt .
        display v-sale-price-base @ ub.gds-dtl.price-base with frame  d-out-prt .
        apply "leave" to ub.gds-dtl.price-base in frame d-out-prt.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE check-place-rsrv :
define variable d_fact-qnty     as decimal no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal no-undo initial 0.00 .
  define variable d_cli-qnty      as decimal no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal no-undo initial 0.00 .
  define variable d_density       as decimal no-undo              .
  do
  on error undo, return error return-value
  :
    if v-place-rsrv <> true
      or b-place :sensitive in frame d-out-prt <> true
    then do:
      return .
    end.
    if v-work-with-qnty = "fact":U
      or v-work-with-qnty = "fact-doc":U
    then do:
      if input frame d-out-prt ub.gds-dtl.doc-qnty < input frame d-out-prt ub.gds-dtl.fact-qnty then do:
        message
          substitute( 'Фактическое количество в строке накладной (&1 &2) больше количества по документу (&3 &2).'
                      ,input frame d-out-prt ub.gds-dtl.fact-qnty
                      ,buf_goods.unit-base
                      ,input frame d-out-prt ub.gds-dtl.doc-qnty
                    )
          view-as alert-box error .
        undo, return error .
      end.
    end.
    assign
      d_fact-qnty     = 0.00
      d_doc-qnty      = 0.00
      d_cli-qnty      = 0.00
      d_cli-fact-qnty = 0.00
      d_cli-doc-qnty  = 0.00
    .
    for each tt-doc-pl no-lock
    on error undo, return error return-value
    :
      assign
        d_cli-qnty      = d_cli-qnty      + tt-doc-pl.cli-qnty
        d_fact-qnty     = d_fact-qnty     + tt-doc-pl.fact-qnty
        d_doc-qnty      = d_doc-qnty      + tt-doc-pl.doc-qnty
        d_cli-fact-qnty = d_cli-fact-qnty + tt-doc-pl.cli-fact-qnty
        d_cli-doc-qnty  = d_cli-doc-qnty  + tt-doc-pl.cli-doc-qnty
      .
    end.
    if input frame d-out-prt ub.gds-dtl.doc-qnty <> d_doc-qnty then do:
      message
        substitute( 'Количество по документу в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения: &2.&3'
                    , input frame d-out-prt ub.gds-dtl.doc-qnty
                    , d_doc-qnty
                    , chr(10)
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if ( v-qnty-kg :sensitive in frame d-out-prt = true
        and input frame d-out-prt v-qnty-kg <> d_cli-doc-qnty
      )
      or
      ( v-qnty-kg :sensitive in frame d-out-prt = false
        and absolute( input frame d-out-prt v-qnty-kg - d_cli-doc-qnty ) > 0.001
      )
    then do:
      message
        substitute( 'Количество в ед.пост-ка в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ с суммарным количеством в ед.пост-ка по местам хранения: &2.&3'
                    + 'Нажмите кнопку "&4" и исправьте количества по местам хранения&3'
                    + 'или исправьте количество в строке накладной.'
                    , input frame d-out-prt v-qnty-kg
                    , d_cli-doc-qnty
                    , chr(10)
                    , replace( b-place :label in frame d-out-prt, "&", "":U )
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if v-work-with-qnty = "fact":U
      or v-work-with-qnty = "fact-doc":U
    then do:
      if input frame d-out-prt ub.gds-dtl.fact-qnty <> d_fact-qnty then do:
        message
          substitute( 'Фактическое количество в строке накладной: &1 &3'
                      + 'НЕ СОВПАДАЕТ &3 с суммарным фактическим количеством по местам хранения: &2.&3'
                      , input frame d-out-prt ub.gds-dtl.fact-qnty
                      , d_fact-qnty
                      , chr(10)
                    )
          view-as alert-box error .
        undo, return error .
      end.
      if ( v-fact-qnty-kg :sensitive in frame d-out-prt = true
          and input frame d-out-prt v-fact-qnty-kg <> d_cli-fact-qnty
        )
        or
        ( v-fact-qnty-kg :sensitive in frame d-out-prt = false
          and absolute( input frame d-out-prt v-fact-qnty-kg - d_cli-fact-qnty ) > 0.001
        )
      then do:
        message
          substitute( 'Фактическое количество в ед.пост-ка в строке накладной: &1 &3'
                      + 'НЕ СОВПАДАЕТ &3 с суммарным фактическим количеством в ед.пост-ка по местам хранения: &2.&3'
                      + 'Нажмите кнопку "&4" и исправьте фактические количества в ед.пост-ка по местам хранения&3'
                      + 'или исправьте фактическое количество в ед.пост-ка в строке накладной.'
                      , input frame d-out-prt v-fact-qnty-kg
                      , d_cli-fact-qnty
                      , chr(10)
                      , replace( b-place :label in frame d-out-prt, "&", "":U )
                    )
          view-as alert-box error .
        undo, return error .
      end.
    end.
    if buf_goods.unit-base <> buf_goods.unit-cli
    and not is-gas(buf_goods.gds-code)
    then do:
      assign
        d_density = d_cli-doc-qnty / d_doc-qnty
      .
      if ( d_density <= 0.00 or d_density >= 1.00 )
        and ( ub.gds-dtl.doc-qnty :sensitive in frame d-out-prt
              or v-qnty-kg :sensitive in frame d-out-prt
            )
      then do:
        message
          substitute( 'Заявленная плотность топлива (&1) не соответствует ожидаемому. Кол-во: &2л и &3кг.'
                      , d_density
                      , d_doc-qnty
                      , d_cli-doc-qnty
                    )
          view-as alert-box error .
        undo, return error .
      end.
      assign
        d_density = d_cli-fact-qnty / d_fact-qnty
      .
      if ( d_density <= 0.00 or d_density >= 1.00 )
        and ub.gds-dtl.fact-qnty :sensitive in frame d-out-prt
      then do:
        message
          substitute( 'Фактическая плотность топлива (&1) не соответствует ожидаемому. Кол-во: &2л и &3кг.'
                    , d_density
                    , d_fact-qnty
                    , d_cli-fact-qnty
                    )
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
PROCEDURE correct-fact-qnty :
define input parameter p-newfact-qnty like ub.doc-line.fact-qnty   no-undo .
  define input parameter p-density      like ub.doc-line.doc-density no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf-next_tt-doc-pl for tt-doc-pl .
    assign
      ub.doc-line.fact-density = p-density
    .
    display
      p-newfact-qnty @ ub.gds-dtl.fact-qnty
      p-newfact-qnty * p-density when v-fact-qnty-kg :visible = true @ v-fact-qnty-kg
      with frame d-out-prt .
    find first tt-doc-pl no-lock
    .
    find first buf-next_tt-doc-pl no-lock
      where buf-next_tt-doc-pl.obj-type =  tt-doc-pl.obj-type
        and buf-next_tt-doc-pl.obj-code =  tt-doc-pl.obj-code
        and buf-next_tt-doc-pl.pl-code  <> tt-doc-pl.pl-code
      no-error .
    if available buf-next_tt-doc-pl then do:
      for each tt-doc-pl
      on error undo, return error return-value
      :
        assign
          tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-density
        .
      end.
      run edit-doc-pl in this-procedure
        ( input 'АВТОИЗМЕНЕНИЕ':U
        ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
    end.
    else do:
      assign
        tt-doc-pl.fact-qnty     = p-newfact-qnty
        tt-doc-pl.cli-fact-qnty = p-newfact-qnty * p-density
      .
    end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
HIDE FRAME d-out-prt NO-PAUSE.
END PROCEDURE.
PROCEDURE edit-doc-pl :
define input  parameter p-edit-doc-pl-mode as character no-undo .
  define variable d_fact-qnty     as decimal   no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal   no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal   no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal   no-undo initial 0.00 .
  define variable v-log           as logical   no-undo .
  define variable v-upd-units     as character no-undo .
  if v-qnty-kg :sensitive  in frame d-out-prt = true
    or v-fact-qnty-kg :sensitive  in frame d-out-prt = true
  then do:
    assign
      v-upd-units = "cli":U
    .
  end.
  else do:
    assign
      v-upd-units = "base":U
    .
  end.
  if v-place-rsrv = false then do:
    message
      substitute( "Товар &1 не привязывается к местам хранения.", buf_goods.gds-code )
      view-as alert-box.
    return .
  end.
  if prt-mode = 'ПРОСМОТР':U
    or t-doc.ext-doc-type = 'rv':U
  then do:
    assign
      p-edit-doc-pl-mode = 'ПРОСМОТР':U
    .
  end.
  else do:
    if is-petrolium = yes
      and is-pieces = no
      and v-work-with-qnty = "doc":U
    then do:
      if ub.doc-line.doc-density = 0
        or ub.doc-line.doc-density = ?
      then do:
        message
          "Не указана плотность"
          view-as alert-box information.
        if ub.doc-line.doc-density :sensitive in frame d-out-prt then do:
          apply "entry" to ub.doc-line.doc-density in frame d-out-prt .
        end.
        return error .
      end.
    end.
  end.
  run str/doc-pls.w
    ( input parparentproc
     ,input p-edit-doc-pl-mode
     ,input v-work-with-qnty
     ,input v-upd-units
     ,input t-doc.doc-code
     ,input buf_goods.gds-code
     ,input ub.doc-line.unit-cli
     ,input ub.doc-line.cli-base-rate
     ,input ub.doc-line.doc-density
     ,input ub.doc-line.fact-density
     ,input input frame d-out-prt v-qnty-kg
     ,input input frame d-out-prt ub.gds-dtl.doc-qnty
     ,input input frame d-out-prt ub.gds-dtl.fact-qnty
     ,input input frame d-out-prt v-qnty-kg
     ,input input frame d-out-prt v-fact-qnty-kg
     ,input ?
     ,input ?
     ,input ?
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при разбиении кол-ва по местам хранения." skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  if prt-mode <> 'ПРОСМОТР':U then do:
    for each tt-doc-pl no-lock
    on error undo, return error return-value
    :
      assign
        d_fact-qnty     = d_fact-qnty     + tt-doc-pl.fact-qnty
        d_doc-qnty      = d_doc-qnty      + tt-doc-pl.doc-qnty
        d_cli-fact-qnty = d_cli-fact-qnty + tt-doc-pl.cli-fact-qnty
        d_cli-doc-qnty  = d_cli-doc-qnty  + tt-doc-pl.cli-doc-qnty
      .
    end.
    assign
      v-log = true
    .
    if v-work-with-qnty = "doc":U
      and ( input frame d-out-prt ub.gds-dtl.doc-qnty <> d_doc-qnty
            or
            ( ub.gds-dtl.doc-qnty :sensitive in frame d-out-prt = true
              and absolute( input frame d-out-prt v-qnty-kg - d_cli-doc-qnty ) > 0.001
            )
            or
            ( v-qnty-kg :sensitive in frame d-out-prt = true
              and input frame d-out-prt v-qnty-kg <> d_cli-doc-qnty
            )
          )
    then do:
      message
        substitute( "Документарная сумма по местам хранения: &1 &2 (&3 &4)", d_doc-qnty, buf_goods.unit-base, d_cli-doc-qnty, buf_goods.unit-cli ) skip
        substitute( "Документарное кол-во по строке документа: &1 &2 (&3 &4)"
                   ,input frame d-out-prt ub.gds-dtl.doc-qnty
                   ,buf_goods.unit-base
                   ,input frame d-out-prt v-qnty-kg
                   ,buf_goods.unit-cli
                  ) skip(1)
        substitute( "Будем менять документарное количество по строке на &1 &2 (&3 &4)?", d_doc-qnty, buf_goods.unit-base, d_cli-doc-qnty, buf_goods.unit-cli )
        view-as alert-box question buttons yes-no update v-log.
      if v-log = true then do:
        .
        display
          d_doc-qnty @ ub.gds-dtl.doc-qnty
          d_doc-qnty * ub.doc-line.doc-density when v-qnty-kg :visible in frame d-out-prt = true @ v-qnty-kg
          with frame d-out-prt .
      end.
    end.
    if ( v-work-with-qnty = "fact":U
         or v-work-with-qnty = "fact-doc":U
       )
      and varupd-fact-qnty = true
      and ( input frame d-out-prt ub.gds-dtl.fact-qnty <> d_fact-qnty
            or
            ( v-fact-qnty-kg :sensitive in frame d-out-prt = true
              and input frame d-out-prt v-fact-qnty-kg <> d_cli-fact-qnty
            )
            or
            ( ub.gds-dtl.fact-qnty :sensitive in frame d-out-prt = true
              and absolute( input frame d-out-prt v-fact-qnty-kg - d_cli-fact-qnty ) > 0.001
            )
          )
    then do:
      message
        substitute( "Фактическая сумма по местам хранения: &1 &2 (&3 &4)", d_fact-qnty, buf_goods.unit-base, d_cli-fact-qnty, buf_goods.unit-cli ) skip
        substitute( "Фактическое кол-во по строке документа: &1 &2 (&3 &4)"
                    ,input frame d-out-prt ub.gds-dtl.fact-qnty
                    ,buf_goods.unit-base
                    ,input frame d-out-prt v-fact-qnty-kg
                    ,buf_goods.unit-cli ) skip(1)
        substitute( "Будем менять фактическое количество по строке на &1 &2 (&3 &4)?", d_fact-qnty, buf_goods.unit-base, d_cli-fact-qnty, buf_goods.unit-cli )
        view-as alert-box question buttons yes-no update v-log.
      if v-log = true then do:
        assign
          v-old-fact-qnty     = d_fact-qnty
          v-old-fact-cli-qnty = d_cli-fact-qnty
        .
        display
          d_fact-qnty @ ub.gds-dtl.fact-qnty
          d_cli-fact-qnty when v-fact-qnty-kg :visible in frame d-out-prt = true @ v-fact-qnty-kg
          with frame d-out-prt
        .
        if v-work-with-qnty = "fact-doc":U then do:
          run str/doc-pls.w
            ( input parparentproc
            ,input 'АВТОИЗМЕНЕНИЕ':U + chr(4) + "calc-qnty":U
            ,input v-work-with-qnty
            ,input v-upd-units
            ,input t-doc.doc-code
            ,input buf_goods.gds-code
            ,input ub.doc-line.unit-cli
            ,input ub.doc-line.cli-base-rate
            ,input ub.doc-line.doc-density
            ,input ub.doc-line.fact-density
            ,input input frame d-out-prt v-qnty-kg
            ,input input frame d-out-prt ub.gds-dtl.doc-qnty
            ,input input frame d-out-prt ub.gds-dtl.fact-qnty
            ,input input frame d-out-prt v-qnty-kg
            ,input input frame d-out-prt v-fact-qnty-kg
            ,input ?
            ,input ?
            ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
        end.
      end.
    end.
  end.
end procedure.
PROCEDURE l-doc-qnty :
  define variable vGtin     as character no-undo.
  define variable vGtinQnty as integer no-undo.
  define variable v-mark-weight as decimal no-undo .
  if v-isweighed
  then do :
    for each buf_marking-lines no-lock where
             buf_marking-lines.out-code = t-doc.doc-code
         and buf_marking-lines.obj-type = t-doc.obj-type
         and buf_marking-lines.obj-code = t-doc.obj-code
         and buf_marking-lines.gds-code = buf_goods.gds-code
         and buf_marking-lines.doc-level = 1,
        first buf_marking no-lock where
              buf_marking.mark = buf_marking-lines.mark
    :
      v-mark-weight = v-mark-weight + MarkWeight(buf_marking.mark).
    end.
    if v-mark-weight > input frame d-out-prt ub.gds-dtl.doc-qnty then
    do:
      message "Нельзя ввести количество меньше, чем просканировано марок по товару" view-as alert-box.
      ub.gds-dtl.doc-qnty:screen-value = string(v-mark-weight).
      apply "enrty" to ub.gds-dtl.doc-qnty in frame d-out-prt.
      return error.
    end.
  end .
  else
  if vIsExemplarGoods then
  do:
    for each buf_marking-lines no-lock where
             buf_marking-lines.out-code = t-doc.doc-code
         and buf_marking-lines.obj-type = t-doc.obj-type
         and buf_marking-lines.obj-code = t-doc.obj-code
         and buf_marking-lines.gds-code = buf_goods.gds-code
         and buf_marking-lines.doc-level = 1,
        first buf_marking no-lock where
              buf_marking.mark = buf_marking-lines.mark
    :
      assign
        vGtin     = getGtinByDM(buf_marking.mark)
        vGtinQnty = vGtinQnty  + getQntyCodeByGtin(vGtin)
      .
    end.
    if vGtinQnty > input frame d-out-prt ub.gds-dtl.doc-qnty then
    do:
      message "Нельзя ввести количество меньше, чем просканировано марок по товару" view-as alert-box.
      ub.gds-dtl.doc-qnty:screen-value = string(vGtinQnty).
      apply "enrty" to ub.gds-dtl.doc-qnty in frame d-out-prt.
      return error.
    end.
  end.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(ub.gds-dtl)
  , input yes
  , input input frame d-out-prt ub.gds-dtl.doc-qnty
  ) no-error.
  if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error
    .
  assign
    tot-rubl = input frame d-out-prt ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
    tot-base = input frame d-out-prt ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
  .
  display
    ub.gds-dtl.price-base
    ub.gds-dtl.price-rubl
    ub.gds-dtl.discnt-base
    ub.gds-dtl.discnt-rubl
    tot-rubl
    tot-base
    with frame d-out-prt.
  if is-petrolium = yes and is-pieces = no then do:
    if
  valid-density( ub.doc-line.doc-density, buf_goods.unit-base = buf_goods.unit-cli )
  = yes then do:
      assign
        v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.doc-density
        v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.doc-density
      .
      display
        v-price-rubl-kg
        v-price-base-kg
        input frame d-out-prt ub.gds-dtl.doc-qnty * ub.doc-line.doc-density @ v-qnty-kg
      with frame d-out-prt.
    end.
  end.
  else do:
    assign
      v-qnty-kg             = decimal (ub.gds-dtl.doc-qnty:screen-value) / buf_goods.cli-base-rate
      v-fact-qnty-kg        = decimal (ub.gds-dtl.fact-qnty:screen-value) / buf_goods.cli-base-rate
    no-error.
    v-qnty-kg:screen-value = string (v-qnty-kg).
    v-fact-qnty-kg:screen-value = string (v-fact-qnty-kg).
  end.
  if v-old-doc-qnty <> input frame d-out-prt ub.gds-dtl.doc-qnty then do:
    if ( is-petrolium = yes
        and is-pieces = no
        and
  valid-density( ub.doc-line.doc-density, buf_goods.unit-base = buf_goods.unit-cli )
  = yes
      )
      or not ( is-petrolium = yes
                and is-pieces = no
              )
    then do:
      if v-place-rsrv = true
        and not ( last-event :event-type = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
      then do:
        run edit-doc-pl in this-procedure
          ( input 'АВТОИЗМЕНЕНИЕ':U
          ).
      end.
    end.
  end.
  run re-calcpr in this-procedure .
END PROCEDURE.
PROCEDURE l-fact-qnty :
  run check-fact-qnty in this-procedure no-error .
  if error-status:error then return error.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(ub.gds-dtl)
  , input yes
  , input input frame d-out-prt ub.gds-dtl.fact-qnty
  ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error
    .
  end.
  assign
    tot-rubl = input frame d-out-prt ub.gds-dtl.fact-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
    tot-base = input frame d-out-prt ub.gds-dtl.fact-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
  .
  display
    ub.gds-dtl.price-base
    ub.gds-dtl.price-rubl
    ub.gds-dtl.discnt-base
    ub.gds-dtl.discnt-rubl
    tot-rubl
    tot-base
    with frame d-out-prt.
  if is-petrolium = true
    and is-pieces = false
    and
  valid-density( ub.doc-line.fact-density, buf_goods.unit-base = buf_goods.unit-cli )
  = true
  then do:
    display
      input frame d-out-prt ub.gds-dtl.fact-qnty * ub.doc-line.fact-density @ v-fact-qnty-kg
      with frame d-out-prt.
  end.
  if v-old-fact-qnty <> input frame d-out-prt ub.gds-dtl.fact-qnty then do:
    if v-place-rsrv = true
      and not ( last-event :event-type = "progress":u
                and last-event :widget-enter = b-place :handle
              )
    then do:
      run edit-doc-pl in this-procedure
        ( input 'АВТОИЗМЕНЕНИЕ':U
        ).
    end.
  end.
  run re-calcpr in this-procedure .
END PROCEDURE.
PROCEDURE check-fact-qnty :
  if can-find( first ub.units where ub.units.unit-name = buf_goods.unit-base
                      and lookup( 'шту':U, ub.units.type ) > 0 ) and
    truncate( input frame d-out-prt ub.gds-dtl.fact-qnty,  0 )
        <>    input frame d-out-prt ub.gds-dtl.fact-qnty
  then do:
    message "Базовая единица товара " buf_goods.unit-base " - штучная." skip
            "Кол-во по факту должно быть целым."
    view-as alert-box error.
    return error.
  end.
  if ( ( lookup( t-doc.doc-type, 'при,возврат':U ) > 0
         and t-doc.internal = true
         and ( ub.gds-prt.upper-code = buf_goods.prt-root
               or can-find( out-dtl no-lock
                            where out-dtl.doc-code  = t-doc.out-code
                              and out-dtl.artic     = ub.gds-dtl.artic
                              and out-dtl.prod-type = ub.gds-dtl.prod-type
                              and out-dtl.prod-code = ub.gds-dtl.prod-code
                              and out-dtl.prt-code  = ub.gds-dtl.prt-code
                           )
             )
       )
       or ( t-doc.doc-type = 'возврат':U
            and t-doc.internal = false
          )
       or lookup( t-doc.doc-type, 'при,возврат':U ) = 0
     )
    and input frame d-out-prt ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty > ( if is-petrolium = true and is-pieces = false then 0.001 else 0.0 )
  then do:
    message
      "Фактическое количество товара не может быть больше количества по накладной."
      view-as alert-box.
    apply "ENTRY":U to ub.gds-dtl.fact-qnty in frame d-out-prt.
    return error.
  end.
END PROCEDURE.
PROCEDURE leave-price-rubl :
      run re-calcpr in this-procedure .
END PROCEDURE.
PROCEDURE new-price-s :
  do
  on error undo, return error return-value
  :
if not ( pr-naklvalue = yes and pr-genmrg = 'before-margin':U ) then do:
   hide  ub.gds-dtl.new-price-sale  in frame d-out-prt
         b-corr-price-sale in frame d-out-prt
         .
   return.
end.
if prt-mode = 'ПРОСМОТР':U then do:
end.
else do:
  define variable l-ok as logical   no-undo .
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_price-sale':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output l-ok
    )  .
end.
    if l-ok = true
    then do:
      enable ub.gds-dtl.new-price-sale  with frame d-out-prt .
    end.
end.
define variable p-exist   as logical  no-undo .
run lineattr-exist in this-procedure (
    input t-doc.doc-code  ,
    input buf_goods.gds-code    ,
    input 'corr-price-sale':U ,
    output p-exist ) .
if p-exist then display b-corr-price-sale with frame d-out-prt .
           else hide    b-corr-price-sale in frame d-out-prt .
ub.gds-dtl.new-price-sale:tooltip = "Цена будет перенесена в переоценку до закрытия этой накладной до ФАКТ" .
display ub.gds-dtl.new-price-sale with frame d-out-prt .
  end.
end procedure.
PROCEDURE proc-case :
  define variable v-action-name as character no-undo .
  if is-petrolium = yes
    and is-pieces = no
  then do:
    if available ub.inv-line then do:
      assign
        v-price-rubl-kg   = ub.inv-line.wast-rubl
        v-price-base-kg   = ub.inv-line.wast-base
        v-fact-qnty-kg    = ub.inv-line.wast-cli-qnty
        v-qnty-kg         = ub.doc-line.cli-qnty
      .
    end.
    else do:
      if
  valid-density( ub.doc-line.doc-density, buf_goods.unit-base = buf_goods.unit-cli )
  = yes then do:
        assign
          v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.doc-density
          v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.doc-density
          v-qnty-kg       = ub.gds-dtl.doc-qnty   * ub.doc-line.doc-density
          v-fact-qnty-kg  = ub.gds-dtl.fact-qnty  * ub.doc-line.fact-density
        .
      end.
      else do:
        assign
          v-price-rubl-kg = 0.0
          v-price-base-kg = 0.0
          v-qnty-kg       = 0.0
          v-fact-qnty-kg  = 0.0
        .
      end.
    end.
    if prt-mode <> 'ПРОСМОТР':U
      and buf_goods.unit-base = buf_goods.unit-cli
      and ( ub.doc-line.doc-density = ?
            or ub.doc-line.doc-density = 0.0
          )
    then do:
      assign
        ub.doc-line.doc-density   = 1.0
        ub.doc-line.cli-base-rate = 1.0
        ub.doc-line.fact-density  = 1.0
      .
    end.
    display
      v-price-rubl-kg
      v-price-base-kg
      v-qnty-kg
      v-fact-qnty-kg
      ub.doc-line.doc-density
      ub.doc-line.temperature
      with frame d-out-prt.
    if (t-doc.flag_ = true or t-doc.status_ = 'факт':U)
    and t-doc.ext-doc-type <> 'io':U and t-doc.ext-doc-type <> 'eo':U
    then do:
      enable
        b-addinf
        with frame d-out-prt.
      if t-doc.doc-type = 'при':U
        and lookup(v-ptrl-without-rvs, 'true,yes':u) = 0
      then do:
        enable
          b-rvs-bf
          b-rvs-af
          with frame d-out-prt.
      end.
    end.
  end.
  else do:
    hide
      v-price-rubl-kg
      v-price-base-kg
      v-qnty-kg
      v-fact-qnty-kg
      ub.doc-line.doc-density
      ub.doc-line.temperature
      in frame d-out-prt
    .
  end.
  case t-doc.doc-type :
    when 'рас':U
    or when 'спи':U
    or when 'возврат':U
    then do:
      if prt-mode = 'БЕЗ_ПРИЗНАКОВ':U
        or prt-mode = 'ШКАЛА':U
      then do:
        if v-work-with-qnty = "doc":U then do:
          if t-doc.discnt-type = 'строка':U then do:
            if ub.gds-dtl.discnt-type  then do:
              assign
                ub.gds-dtl.discnt-base = ub.gds-dtl.price-base * ub.gds-dtl.discnt-pc / 100
                ub.gds-dtl.discnt-rubl = ub.gds-dtl.price-rubl * ub.gds-dtl.discnt-pc / 100
              .
              enable ub.gds-dtl.discnt-pc with frame d-out-prt.
            end.
            else do:
              if t-doc.print-rubl then do:
                assign
                  ub.gds-dtl.discnt-pc   = ub.gds-dtl.discnt-rubl * 100 / ub.gds-dtl.price-rubl
                  ub.gds-dtl.discnt-base = ub.gds-dtl.discnt-rubl       / t-doc.base-rate * t-doc.base-scale
                .
                if ub.gds-dtl.discnt-pc = ? then do:
                  assign
                    ub.gds-dtl.discnt-pc = 0.
                end.
                enable ub.gds-dtl.discnt-rubl with frame d-out-prt.
              end.
              else do:
                assign
                  ub.gds-dtl.discnt-pc   = ub.gds-dtl.discnt-base * 100 / ub.gds-dtl.price-base
                  ub.gds-dtl.discnt-rubl = ub.gds-dtl.discnt-base *       t-doc.base-rate / t-doc.base-scale
                .
                if ub.gds-dtl.discnt-pc = ? then do:
                  assign
                    ub.gds-dtl.discnt-pc = 0.
                end.
                enable ub.gds-dtl.discnt-base with frame d-out-prt.
              end.
            end.
            enable ub.gds-dtl.discnt-type with frame d-out-prt.
          end.
          if lookup( t-doc.doc-type, 'рас,спи':U ) > 0 then do:
            if available ub.prt-obj    then do: display ub.prt-obj.free-qnty  with frame d-out-prt. end.
            if available ub.price-list then do: display ub.price-list.doc-num with frame d-out-prt. end.
          end.
          if t-doc.internal = false then do:
            case t-doc.doc-type :
              when 'рас':U then do:
                assign
                  v-action-name = 'actn_expense_price':U
                .
              end.
              when 'спи':U then do:
                assign
                  v-action-name = 'actn_write-off_price':U
                .
              end.
              when 'возврат':U then do:
                assign
                  v-action-name = 'actn_return_price':U
                .
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" t-doc.doc-type skip
                  "Код документа" t-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  v-action-name
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g#log
    )  .
end.
          end.
          else do:
            assign
              g#log = no
            .
          end.
          if is-petrolium = true
            and is-pieces = false
            and ptrlprop-expptrl = 'weight':U
            and buf_goods.unit-base <> buf_goods.unit-cli
          then do:
            enable
              v-qnty-kg
              with frame d-out-prt.
          end.
          else do:
            enable
              ub.gds-dtl.doc-qnty
              with frame d-out-prt.
          end.
          if is-petrolium = true
            and is-pieces = false
            and buf_goods.unit-base <> buf_goods.unit-cli
          then do:
            enable
              ub.doc-line.temperature
              ub.doc-line.doc-density
              with frame d-out-prt.
          end.
          if ( g#log and t-doc.ext-doc-type <> 'ep':U )
            or ( t-doc.ext-doc-type = 'ep':U and t-doc.status_ = 'запрос':U )
          then do:
            if is-petrolium = true
              and is-pieces = false
              and ptrlprop-expptrl = 'weight':U
              and buf_goods.unit-base <> buf_goods.unit-cli
            then do:
              if t-doc.print-rubl = true then do:
                enable
                  v-price-rubl-kg
                  with frame d-out-prt.
              end.
              else do:
                enable
                  v-price-base-kg
                  with frame d-out-prt.
              end.
            end.
            else do:
              if t-doc.print-rubl = true then do:
                if not v-is-return
                then
                enable
                  ub.gds-dtl.price-rubl
                  with frame d-out-prt
                .
              end.
              else do:
                if not v-is-return
                then
                enable
                  ub.gds-dtl.price-base
                  with frame d-out-prt
                .
              end.
            end.
          end.
        end.
        else do:
          hide
            ub.prt-obj.free-qnty  in frame d-out-prt
            ub.price-list.doc-num in frame d-out-prt
          .
          if t-doc.ext-doc-type <> 'rv':U then do:
            if is-petrolium = yes
              and is-pieces = no
              and ptrlprop-expptrl = 'weight':U
              and buf_goods.unit-base <> buf_goods.unit-cli
            then do:
              enable
                v-fact-qnty-kg
                with frame d-out-prt.
            end.
            else do:
              enable
                ub.gds-dtl.fact-qnty
                with frame d-out-prt.
            end.
          end.
        end.
      end.
      if ub.gds-dtl.ov = yes then do: hide ub.price-list.doc-num in frame d-out-prt. end.
      if prt-mode = 'ПРОСМОТР':U then do: hide ub.prt-obj.free-qnty ub.price-list.doc-num in frame d-out-prt. end.
      if t-doc.discnt-type = 'строка':U then do:
        display ub.gds-dtl.discnt-type with frame d-out-prt.
      end.
      else do:
        hide ub.gds-dtl.discnt-type in frame d-out-prt.
      end.
      if ub.gds-dtl.ov and t-doc.status_ <> 'факт':U then do:
        assign
          ub.price-list.doc-num :fgcolor = 4
        .
        display "Не цена объекта" @ ub.price-list.doc-num with frame d-out-prt.
      end.
      display ub.gds-dtl.discnt-base ub.gds-dtl.discnt-rubl ub.gds-dtl.discnt-pc with frame d-out-prt.
      if t-doc.internal then do:
        hide ub.gds-dtl.discnt-base ub.gds-dtl.discnt-rubl ub.gds-dtl.discnt-pc
                ub.gds-dtl.discnt-type in frame d-out-prt.
      end.
    end.
    when 'при':U then do:
      if prt-mode = 'БЕЗ_ПРИЗНАКОВ':U or prt-mode = 'ШКАЛА':U then do:
        if v-work-with-qnty = "doc":U then do:
          if ptrlprop-expptrl = 'weight':U
            and buf_goods.unit-base <> buf_goods.unit-cli
          then do:
            enable
              v-qnty-kg
            with frame d-out-prt.
            if t-doc.status_ = 'запрос':U and t-doc.internal then do:
              if t-doc.print-rubl = yes then do:
                enable
                  v-price-rubl-kg
                with frame d-out-prt.
              end.
              else do:
                enable
                  v-price-base-kg
                with frame d-out-prt.
              end.
            end.
          end.
          else do:
            enable
              ub.gds-dtl.doc-qnty
            with frame d-out-prt.
            if t-doc.status_ = 'запрос':U and t-doc.internal then do:
              if t-doc.print-rubl = yes then do:
                enable
                  ub.gds-dtl.price-rubl
                with frame d-out-prt.
              end.
              else do:
                enable
                  ub.gds-dtl.price-base
                with frame d-out-prt.
              end.
            end.
          end.
        end.
        else do:
          if varupd-fact-qnty = true then do:
            if ptrlprop-expptrl = 'weight':U
              and buf_goods.unit-base <> buf_goods.unit-cli
            then do:
              enable
                v-fact-qnty-kg
                with frame d-out-prt.
            end.
            else do:
              enable
                ub.gds-dtl.fact-qnty
                with frame d-out-prt.
            end.
          end.
        end.
      end.
      hide ub.prt-obj.free-qnty ub.price-list.doc-num ub.gds-dtl.discnt-base ub.gds-dtl.discnt-rubl
           ub.gds-dtl.discnt-pc ub.gds-dtl.discnt-type in frame d-out-prt.
    end.
  end case.
END PROCEDURE.
PROCEDURE re-calcpr :
if pr-naklvalue = yes and pr-genmrg = 'before-margin':U and prt-mode <> 'ПРОСМОТР':U then do:
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run find-new-price-sale in this-procedure (
   input  pr-genmrg
  ,input  pr-naklvalue
  ,input  t-doc.doc-code
  ,input  ub.gds-dtl.artic
  ,input  ub.gds-dtl.prod-type
  ,input  ub.gds-dtl.prod-code
  ,input  ub.gds-dtl.price-rubl
  ,input  ub.gds-dtl.price-base
  ,input  ub.gds-dtl.price-rubl
  ,input  ub.gds-dtl.price-base
  ,input-output ub.gds-dtl.new-price-sale
    )
     .
end.
END PROCEDURE.
PROCEDURE read-doc-line-attr :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-attr-code      as character        no-undo.
define output parameter p-attr-value    as character        no-undo.
   define buffer buf_doc-line-attr       for ub.doc-line-attr.
do
for buf_doc-line-attr
on error undo, return error
:
    find first buf_doc-line-attr no-lock
         where buf_doc-line-attr.doc-code     = p-doc-code
           and buf_doc-line-attr.gds-code     = p-gds-code
           and buf_doc-line-attr.attr-code    = p-attr-code
    no-error.
    if available buf_doc-line-attr
    then do:
        assign
            p-attr-value = buf_doc-line-attr.attr-value
        .
    end.
    else do:
        assign
            p-attr-value = "":U
        .
    end.
end.
END PROCEDURE.
PROCEDURE rsrv-out :
define variable v-chg-qnty      as decimal   no-undo .
  define variable v-chg-doc-qnty  as decimal   no-undo .
  define variable v-chg-fact-qnty as decimal   no-undo .
  define variable v-density       as decimal   no-undo .
  define variable v-mem-qnty      as decimal   no-undo .
  define variable v-split-count   as integer   no-undo .
  define variable v-pl-code       like ub.pl-gds.pl-code no-undo .
  define buffer buf_doc-pl   for ub.doc-pl .
  define buffer buf_parts    for ub.parts  .
  define buffer buf_doc-pl-attr for ub.doc-pl-attr .
  do
  on error undo, return error return-value
  :
    if not( is-petrolium = yes
            and is-pieces = no
          )
    then do:
      if v-work-with-qnty = "doc":U then do:
        if vScanMark <> "" then do:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = input frame d-out-prt ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty
.
  run trg/rsrv-dtl.p
    ( input        ParParentProc
    , input        'reserv':U
    , buffer       ub.gds-dtl
    , input-output chg-qnty
    , input-output ub.doc-line.price-base
    , input-output ub.doc-line.price-rubl
    , input        -1
    , input         vScanMark) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "rsrv-dtl.p doc"
      view-as alert-box error
    .
    undo, return error return-value .
  end.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty + chg-qnty
      ub.doc-line.fact-qnty = ub.doc-line.doc-qnty
    .
    if ub.doc-line.doc-density <> ? and ub.doc-line.doc-density <> 0 then do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty * ub.doc-line.doc-density
      .
    end.
    else do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty / ub.doc-line.cli-base-rate
      .
    end.
  end.
  assign
    ub.gds-dtl.doc-qnty  = ub.gds-dtl.doc-qnty + chg-qnty
    ub.gds-dtl.fact-qnty = ub.gds-dtl.doc-qnty
  .
        end.
        else do:
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = input frame d-out-prt ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty
.
  run trg/rsrv-dtl.p
    ( input        ParParentProc
    , input        'reserv':U
    , buffer       ub.gds-dtl
    , input-output chg-qnty
    , input-output ub.doc-line.price-base
    , input-output ub.doc-line.price-rubl
    , input        -1
    , input         "" ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "rsrv-dtl.p doc"
      view-as alert-box error
.
    undo, return error return-value .
  end.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty + chg-qnty
      ub.doc-line.fact-qnty = ub.doc-line.doc-qnty
    .
    if ub.doc-line.doc-density <> ? and ub.doc-line.doc-density <> 0 then do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty * ub.doc-line.doc-density
      .
    end.
    else do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty / ub.doc-line.cli-base-rate
      .
    end.
  end.
  assign
    ub.gds-dtl.doc-qnty  = ub.gds-dtl.doc-qnty + chg-qnty
    ub.gds-dtl.fact-qnty = ub.gds-dtl.doc-qnty
  .
      end.
      end.
      else do:
        if vScanMark <> "" then do:
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = input frame d-out-prt ub.gds-dtl.fact-qnty - ub.gds-dtl.fact-qnty
.
  run trg/rsrv-dtl.p
    ( input        ParParentProc
    , input        'reserv':U
    , buffer       ub.gds-dtl
    , input-output chg-qnty
    , input-output ub.doc-line.price-base
    , input-output ub.doc-line.price-rubl
    , input        -1
    , input         vScanMark) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "rsrv-dtl.p fact"
      view-as alert-box error
    .
    undo, return error return-value .
  end.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty
    .
  end.
  assign
    ub.gds-dtl.fact-qnty = ub.gds-dtl.fact-qnty + chg-qnty
  .
        end.
      else do:
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = input frame d-out-prt ub.gds-dtl.fact-qnty - ub.gds-dtl.fact-qnty
.
  run trg/rsrv-dtl.p
    ( input        ParParentProc
    , input        'reserv':U
    , buffer       ub.gds-dtl
    , input-output chg-qnty
    , input-output ub.doc-line.price-base
    , input-output ub.doc-line.price-rubl
    , input        -1
    , input         "" ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "rsrv-dtl.p fact"
      view-as alert-box error
.
    undo, return error return-value .
  end.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty
    .
  end.
  assign
    ub.gds-dtl.fact-qnty = ub.gds-dtl.fact-qnty + chg-qnty
  .
      end.
      end.
    end.
    else do:
      if t-doc.ext-doc-type = 'iv':U then do:
          for each buf_parts exclusive-lock
              where buf_parts.out-code = t-doc.doc-code
              and buf_parts.obj-type = t-doc.obj-type
              and buf_parts.obj-code = t-doc.obj-code
              and buf_parts.artic = buf_goods.artic
              and buf_parts.prod-type = buf_goods.prod-type
              and buf_parts.prod-code = buf_goods.prod-code
              and buf_parts.fact-qnty = 0:
                buf_parts.fact-qnty = buf_parts.qnty.
          end.
      end.
      if v-work-with-qnty = "fact-doc":U then do:
        assign
          v-chg-qnty = 0.0
        .
        for each buf_parts
          where buf_parts.out-code  = t-doc.doc-code
            and buf_parts.obj-type  = t-doc.obj-type
            and buf_parts.obj-code  = t-doc.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
            and buf_parts.pl-code   = 0
        on error undo, return error substitute( "&1 (rsrv-doc-pl). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-work-with-qnty = "doc":U then do:
            assign
              v-chg-qnty = v-chg-qnty + (- buf_parts.qnty)
            .
          end.
          else do:
            assign
              v-chg-qnty = v-chg-qnty + (- buf_parts.fact-qnty)
            .
          end.
        end.
        if v-chg-qnty <> 0.0 then do:
          assign
            v-mem-qnty = v-chg-qnty
          .
          run trg/rsrv-dtl.p
            ( input        ParParentProc
            , input        substitute( '&1,&2=&3,&4=3'
                                      , 'reserv':U
                                      , 'plcode':U
                                      , 0
                                      , 'negative-check':U
                                      )
            , buffer       ub.gds-dtl
            , input-output v-chg-qnty
            , input-output ub.doc-line.price-base
            , input-output ub.doc-line.price-rubl
            , input        -1
            , input if node-type begins 'scan-mark' then entry(2,node-type,chr(3)) else vScanMark
            ) no-error .
          if error-status :error then do:
            undo, return error substitute( '&1&2&3', return-value, chr(10), error-status :get-message( 1 ) ) .
          end.
          if v-chg-qnty <> v-mem-qnty then do:
            undo, return error substitute( 'Не удалось снять резервы по товару &1 без места хранения.', buf_goods.gds-code ) .
          end.
        end.
      end.
      for each buf_doc-pl
        where buf_doc-pl.obj-type = t-doc.obj-type
          and buf_doc-pl.obj-code = t-doc.obj-code
          and buf_doc-pl.out-code = t-doc.doc-code
          and buf_doc-pl.gds-code = buf_goods.gds-code
      on error undo, return error substitute( "&1 (rsrv-doc-pl). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        if v-work-with-qnty = "doc":U then do:
          assign
            v-chg-qnty = (- buf_doc-pl.doc-qnty)
          .
        end.
        else do:
          assign
            v-chg-qnty = (- buf_doc-pl.fact-qnty)
          .
        end.
        if v-chg-qnty <> 0.0 then do:
          assign
            v-mem-qnty = v-chg-qnty
          .
          run trg/rsrv-dtl.p
            ( input        ParParentProc
            , input        substitute( '&1,&2=&3,&4=3'
                                      , 'reserv':U
                                      , 'plcode':U
                                      , buf_doc-pl.pl-code
                                      , 'negative-check':U
                                      )
            , buffer       ub.gds-dtl
            , input-output v-chg-qnty
            , input-output ub.doc-line.price-base
            , input-output ub.doc-line.price-rubl
            , input        -1
            , input if node-type begins 'scan-mark' then entry(2,node-type,chr(3)) else vScanMark
            ) no-error .
          if error-status :error then do:
            undo, return error substitute( '&1&2&3', return-value, chr(10), error-status :get-message( 1 ) ) .
          end.
          if v-chg-qnty <> v-mem-qnty then do:
            undo, return error substitute( 'Не удалось снять резервы по товару &1 на месте хранения &2 .', buf_goods.gds-code, buf_doc-pl.pl-code ) .
          end.
        end.
        delete buf_doc-pl .
      end.
      if v-work-with-qnty = "doc":U then do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = input frame d-out-prt ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty
.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty + chg-qnty
      ub.doc-line.fact-qnty = ub.doc-line.doc-qnty
    .
    if ub.doc-line.doc-density <> ? and ub.doc-line.doc-density <> 0 then do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty * ub.doc-line.doc-density
      .
    end.
    else do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty / ub.doc-line.cli-base-rate
      .
    end.
  end.
  assign
    ub.gds-dtl.doc-qnty  = ub.gds-dtl.doc-qnty + chg-qnty
    ub.gds-dtl.fact-qnty = ub.gds-dtl.doc-qnty
  .
      end.
      else do:
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = input frame d-out-prt ub.gds-dtl.fact-qnty - ub.gds-dtl.fact-qnty
.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty
    .
  end.
  assign
    ub.gds-dtl.fact-qnty = ub.gds-dtl.fact-qnty + chg-qnty
  .
      end.
      if v-work-with-qnty = "fact-doc":U then do:
        for each buf_parts
          where buf_parts.out-code  = t-doc.doc-code
            and buf_parts.obj-type  = t-doc.obj-type
            and buf_parts.obj-code  = t-doc.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
        on error undo, return error substitute( "&1 (rsrv-doc-pl). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if num-entries( buf_parts.part-code, '#':U ) > 1 then do:
            run trg/partjoin.p
              ( input buf_parts.obj-type
               ,input buf_parts.obj-code
               ,input buf_parts.artic
               ,input buf_parts.prod-type
               ,input buf_parts.prod-code
               ,input buf_parts.in-code
               ,input buf_parts.out-code
               ,input buf_parts.part-code
              ) no-error.
            if error-status :error then do:
              undo, return error substitute( "&1 (rsrv-out). Не удалось объединить партию с номером &2!&3&4&3&5", vss-workfile, buf_parts.part-code, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
            end.
          end.
        end.
        for each tt-parts-all
        on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          delete tt-parts-all .
        end.
        for each tt-parts-split
        on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          delete tt-parts-split .
        end.
        assign
          v-chg-doc-qnty = 0.0
        .
        for each buf_parts
          where buf_parts.out-code  = t-doc.doc-code
            and buf_parts.obj-type  = t-doc.obj-type
            and buf_parts.obj-code  = t-doc.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
        on error undo, return error substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          assign
            buf_parts.cli-qnty = buf_parts.qnty / buf_parts.cli-base-rate
            v-chg-doc-qnty     = v-chg-doc-qnty + buf_parts.qnty
          .
          create tt-parts-all .
          buffer-copy buf_parts to tt-parts-all .
        end.
        for each tt-doc-pl
        on error undo, return error substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          assign
            v-mem-qnty = tt-doc-pl.doc-qnty
          .
          block_parts-search:
          do while v-mem-qnty > 0
          on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            find first tt-parts-all no-error .
            if not available tt-parts-all then do:
              leave block_parts-search.
            end.
            find first buf_parts
              where buf_parts.obj-type  = tt-parts-all.obj-type
                and buf_parts.obj-code  = tt-parts-all.obj-code
                and buf_parts.artic     = tt-parts-all.artic
                and buf_parts.prod-type = tt-parts-all.prod-type
                and buf_parts.prod-code = tt-parts-all.prod-code
                and buf_parts.in-code   = tt-parts-all.in-code
                and buf_parts.out-code  = tt-parts-all.out-code
                and buf_parts.part-code = tt-parts-all.part-code
              .
            if tt-parts-all.qnty <= v-mem-qnty then do:
              create tt-parts-split .
              buffer-copy tt-parts-all to tt-parts-split
                assign
                  tt-parts-split.pl-code   = tt-doc-pl.pl-code
                  tt-parts-split.qnty      = tt-parts-all.qnty
                  tt-parts-split.cli-qnty  = tt-parts-all.cli-qnty
                .
              assign
                v-mem-qnty     = v-mem-qnty     - tt-parts-all.qnty
                v-chg-doc-qnty = v-chg-doc-qnty - tt-parts-all.qnty
              .
              delete tt-parts-all .
            end.
            else do:
              create tt-parts-split .
              buffer-copy tt-parts-all to tt-parts-split
                assign
                  tt-parts-split.pl-code   = tt-doc-pl.pl-code
                  tt-parts-split.qnty      = v-mem-qnty
                  tt-parts-split.cli-qnty  = tt-parts-split.qnty / buf_parts.cli-base-rate
              .
              assign
                tt-parts-all.qnty      = tt-parts-all.qnty      - tt-parts-split.qnty
                tt-parts-all.cli-qnty  = tt-parts-all.cli-qnty  - tt-parts-split.cli-qnty
                v-mem-qnty             = 0.0
                v-chg-doc-qnty         = v-chg-doc-qnty         - tt-parts-split.qnty
              .
            end.
          end.
        end.
        for each tt-parts-all
        on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          delete tt-parts-all .
        end.
        if v-chg-doc-qnty <> 0.0 then do:
          undo, return error substitute( '&1 (rsrv-out). &2 &3 не распределено по местам хранения!', vss-workfile, v-chg-doc-qnty, buf_goods.unit-base ).
        end.
        for each buf_parts exclusive-lock
          where buf_parts.out-code  = t-doc.doc-code
            and buf_parts.obj-type  = t-doc.obj-type
            and buf_parts.obj-code  = t-doc.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
        on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          for each temp-parts-qnty
          on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            delete temp-parts-qnty .
          end.
          assign
            v-split-count = 0
          .
          for each tt-parts-split
            where tt-parts-split.obj-type  = buf_parts.obj-type
              and tt-parts-split.obj-code  = buf_parts.obj-code
              and tt-parts-split.artic     = buf_parts.artic
              and tt-parts-split.prod-type = buf_parts.prod-type
              and tt-parts-split.prod-code = buf_parts.prod-code
              and tt-parts-split.in-code   = buf_parts.in-code
              and tt-parts-split.out-code  = buf_parts.out-code
              and tt-parts-split.part-code = buf_parts.part-code
          on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            assign
              v-split-count = v-split-count + 1
              v-pl-code     = tt-parts-split.pl-code
            .
            create temp-parts-qnty.
            assign
              temp-parts-qnty.cli-qnty  = tt-parts-split.cli-qnty
              temp-parts-qnty.qnty      = tt-parts-split.qnty
              temp-parts-qnty.fact-qnty = tt-parts-split.fact-qnty
              temp-parts-qnty.pl-code   = tt-parts-split.pl-code
            .
            delete tt-parts-split .
          end.
          if v-split-count >= 1 and not t-doc.doc-code matches "*=*" then do:
            run trg/partsplt.p
              ( input buf_parts.obj-type
               ,input buf_parts.obj-code
               ,input buf_parts.artic
               ,input buf_parts.prod-type
               ,input buf_parts.prod-code
               ,input buf_parts.in-code
               ,input buf_parts.out-code
               ,input buf_parts.part-code
               ,input table temp-parts-qnty
              ) no-error.
            if error-status :error then do:
              undo, return error substitute( "&1 (rsrv-out). Не удалось разбить партию с номером &2!&3&4&3&5", vss-workfile, buf_parts.part-code, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
            end.
          end.
        end.
        for each temp-parts-qnty
        on error undo, return error substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          delete temp-parts-qnty .
        end.
      end.
      for each tt-doc-pl
      on error undo, return error substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        create buf_doc-pl .
        buffer-copy tt-doc-pl to buf_doc-pl .
        if t-doc.ext-doc-type = 'eo':U
        then do :
            find first  buf_doc-pl-attr exclusive-lock
                  where buf_doc-pl-attr.obj-type    = tt-doc-pl.obj-type
                    and buf_doc-pl-attr.obj-code    = tt-doc-pl.obj-code
                    and buf_doc-pl-attr.pl-code     = tt-doc-pl.pl-code
                    and buf_doc-pl-attr.out-code    = tt-doc-pl.out-code
                    and buf_doc-pl-attr.gds-code    = tt-doc-pl.gds-code
                    and buf_doc-pl-attr.attr-code   = 'place2' no-error .
            if not available buf_doc-pl-attr then do :
                create buf_doc-pl-attr .
                assign
                    buf_doc-pl-attr.obj-type = tt-doc-pl.obj-type
                    buf_doc-pl-attr.obj-code = tt-doc-pl.obj-code
                    buf_doc-pl-attr.pl-code  = tt-doc-pl.pl-code
                    buf_doc-pl-attr.out-code = tt-doc-pl.out-code
                    buf_doc-pl-attr.gds-code = tt-doc-pl.gds-code
                    buf_doc-pl-attr.attr-code = 'place2'
                .
            end.
            assign
                buf_doc-pl-attr.attr-value = string(tt-doc-pl.pl-code2)
            .
        end.
        if v-work-with-qnty = "doc":U then do:
          assign
            v-chg-qnty = tt-doc-pl.doc-qnty
          .
        end.
        else do:
          assign
            v-chg-qnty = tt-doc-pl.fact-qnty
          .
        end.
        assign
          v-mem-qnty = v-chg-qnty
        .
        run trg/rsrv-dtl.p
          ( input        ParParentProc
          , input        substitute( '&1,&2=&3,&4=3'
                                    , 'reserv':U
                                    , 'plcode':U
                                    , tt-doc-pl.pl-code
                                    , 'negative-check':U
                                    )
          , buffer       ub.gds-dtl
          , input-output v-chg-qnty
          , input-output ub.doc-line.price-base
          , input-output ub.doc-line.price-rubl
          , input        -1
          , input if node-type begins 'scan-mark' then entry(2,node-type,chr(3)) else vScanMark
          ) no-error .
        if error-status :error then do:
          undo, return error substitute( '&1&2&3', return-value, chr(10), error-status :get-message( 1 ) ) .
        end.
        if v-chg-qnty <> v-mem-qnty then do:
          undo, return error substitute( 'По товару &1 на месте хранения &2 возможно зарезервировать только &3 &4.'
                                         ,buf_goods.gds-code
                                         ,tt-doc-pl.pl-code
                                         ,v-chg-qnty
                                         ,buf_goods.unit-base
                                       ) .
        end.
      end.
      if v-work-with-qnty = "doc":U then do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = input frame d-out-prt ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty
.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty + chg-qnty
      ub.doc-line.fact-qnty = ub.doc-line.doc-qnty
    .
    if ub.doc-line.doc-density <> ? and ub.doc-line.doc-density <> 0 then do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty * ub.doc-line.doc-density
      .
    end.
    else do:
      assign
        ub.doc-line.cli-qnty = ub.doc-line.doc-qnty / ub.doc-line.cli-base-rate
      .
    end.
  end.
  assign
    ub.gds-dtl.doc-qnty  = ub.gds-dtl.doc-qnty + chg-qnty
    ub.gds-dtl.fact-qnty = ub.gds-dtl.doc-qnty
  .
      end.
      else do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  chg-qnty = input frame d-out-prt ub.gds-dtl.fact-qnty - ub.gds-dtl.fact-qnty
.
  if lookup( t-doc.doc-type, 'рас,спи,возврат':U ) > 0 or
     ( t-doc.doc-type = 'при':U and
       t-doc.internal = yes )
  then do:
    assign
      ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty
    .
  end.
  assign
    ub.gds-dtl.fact-qnty = ub.gds-dtl.fact-qnty + chg-qnty
  .
      end.
      if v-work-with-qnty = "doc":U then do:
        assign
          v-qnty-kg = ub.gds-dtl.doc-qnty * ub.doc-line.doc-density
          v-density = ub.doc-line.doc-density
        .
      end.
      else do:
        assign
          v-fact-qnty-kg = ub.gds-dtl.fact-qnty * ub.doc-line.fact-density
          v-density      = ub.doc-line.fact-density
        .
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  ub.doc-line.doc-code
 ,input  ub.doc-line.artic
 ,input  ub.doc-line.prod-type
 ,input  ub.doc-line.prod-code
 ,input  v-price-rubl-kg
 ,input  v-price-base-kg
 ,input  0
 ,input  0
 ,input  ( if v-work-with-qnty = 'doc':U then v-qnty-kg else v-fact-qnty-kg )
 ,input  v-density
 ,output rec-inv-line
 ) .
    end.
  end.
END PROCEDURE.
PROCEDURE UI-on :
define variable v-data-type     as character no-undo.
  define variable calc_after-qnty as decimal no-undo.
  define variable isRightEditPrice as logical no-undo.
  disable all  with frame d-out-prt.
  if prt-mode <> 'ПРОСМОТР':U then do:
   enable  b-exit b-quit b-help b-arch b-history with frame d-out-prt.
  end.
  else do:
    hide    b-exit in frame d-out-prt.
    b-quit:label = "&Выход".
    b-quit:column = 1.
    enable  b-quit b-help b-arch b-history with frame d-out-prt.
  end.
  run tax-name in this-procedure ( input 'rdt':U, output varroad-tax-label ) no-error.
  assign
    ub.doc-line.road-tax :label in frame d-out-prt = varroad-tax-label
  .
  RUN proc-case .
  assign
    tot-rubl = ub.gds-dtl.fact-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
    tot-base = ub.gds-dtl.fact-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
  .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_goods.gds-code
  ,input  ub.gds-dtl.prt-code
  ,input  ''
  ,input  ''
  ,input  buf_goods.unit-base
  ,input  1
  ,output varis-new
  ,buffer b-c-b
  )  .
  display b-c-b.b-code with frame d-out-prt.
  find first bf_prod-bc where bf_prod-bc.b-code = b-c-b.b-code no-lock no-error.
  if available bf_prod-bc then do:
    assign
      varprod-bc-str = bf_prod-bc.b-str.
    display varprod-bc-str with frame d-out-prt.
  end.
  display tot-rubl tot-base base-curr ub.clients.obj-name ub.gds-prt.f-name
          ub.gds-dtl.artic ub.gds-dtl.prod-code ub.gds-dtl.prod-type
          ub.gds-dtl.price-rubl ub.gds-dtl.price-base
          buf_goods.gds-name buf_goods.unit-base buf_goods.qnty-cart ub.doc-line.road-tax with frame d-out-prt.
  if ptrlprop-expptrl = 'weight':U then do:
    display
      buf_goods.unit-cli @ buf_goods.unit-base
    with frame d-out-prt.
  end.
  if input frame d-out-prt ub.gds-dtl.doc-qnty = 0
    and input frame d-out-prt ub.gds-dtl.fact-qnty = 0
  then do:
    display
      ub.gds-dtl.doc-qnty
      ub.gds-dtl.fact-qnty
      with frame d-out-prt.
  end.
  if ub.gds-prt.upper-code = buf_goods.prt-root then do:
    hide
      ub.gds-prt.f-name in frame d-out-prt.
  end.
  if v-work-with-qnty = "doc":U then do:
    hide
      ub.gds-dtl.fact-qnty
      v-fact-qnty-kg
      in frame d-out-prt
    .
  end.
if t-doc.ext-doc-type = 'ee':U then do:
  IF ( ub.gds-dtl.price-rubl:VISIBLE AND ub.gds-dtl.price-rubl:sensitive ) OR
     ( ub.gds-dtl.price-base:VISIBLE AND ub.gds-dtl.price-base:sensitive )
     THEN
     ENABLE r-price with frame d-out-prt.
  if prt-mode <> 'ПРОСМОТР':U and v-is-return and vBackSale then
  do:
define variable vss-include-info76 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_price'
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output isRightEditPrice
    )  .
end.
    if isRightEditPrice then
      enable ub.gds-dtl.price-rubl with frame d-out-prt.
  end.
end.
else if prt-mode <> 'ПРОСМОТР':U and t-doc.ext-doc-type = 'iv':U and is-petrolium and not is-pieces then do:
    enable
        ub.gds-dtl.fact-qnty
        v-fact-qnty-kg
        with frame d-out-prt
    .
end.
else do:
   hide r-price in frame d-out-prt.
end.
if t-doc.ext-doc-type = 'we':U then do:
  if prt-mode <> 'ПРОСМОТР':U then enable c-reason with frame d-out-prt .
  else disable c-reason with frame d-out-prt .
end.
else do:
  c-reason:hidden in frame d-out-prt .
end.
g-image:SENSITIVE = g-image:VISIBLE.
if prt-mode <> 'ПРОСМОТР':U and ub.gds-dtl.price-corr = 0 then do :
  define variable v-pr as decimal   no-undo .
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run find-new-price-sale in this-procedure (
   input  pr-genmrg
  ,input  pr-naklvalue
  ,input  t-doc.doc-code
  ,input  ub.gds-dtl.artic
  ,input  ub.gds-dtl.prod-type
  ,input  ub.gds-dtl.prod-code
  ,input  ub.gds-dtl.price-rubl
  ,input  ub.gds-dtl.price-base
  ,input  ub.gds-dtl.price-rubl
  ,input  ub.gds-dtl.price-base
  ,input-output v-pr
    )
    no-error .
    display v-pr @ ub.gds-dtl.new-price-sale with frame d-out-prt .
    assign ub.gds-dtl.new-price-sale.
end.
run new-price-s in this-procedure .
END PROCEDURE.
PROCEDURE write-doc-line-attr :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-attr-code      as character        no-undo.
define input parameter p-attr-value     as character        no-undo.
define buffer buf_doc-line-attr       for ub.doc-line-attr.
do
for buf_doc-line-attr
on error undo, return error
:
    find first buf_doc-line-attr exclusive-lock
         where buf_doc-line-attr.doc-code     = p-doc-code
           and buf_doc-line-attr.gds-code     = p-gds-code
           and buf_doc-line-attr.attr-code    = p-attr-code
    no-error.
    if available buf_doc-line-attr
    then do:
        if p-attr-value = ?
        or p-attr-value = "":U
        then do:
            delete buf_doc-line-attr.
        end.
        else do:
            assign
                buf_doc-line-attr.attr-value = p-attr-value
            .
        end.
    end.
    else do:
        if p-attr-value = ?
        or p-attr-value = "":U
        then do:
          assign
            p-attr-value = '':U
          no-error .
        end.
        else do:
            create buf_doc-line-attr.
            assign
                buf_doc-line-attr.doc-code     = p-doc-code
                buf_doc-line-attr.gds-code     = p-gds-code
                buf_doc-line-attr.attr-code    = p-attr-code
                buf_doc-line-attr.attr-value   = p-attr-value
            no-error .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE init-temp :
  define variable ii          as integer   no-undo .
  define variable reason      as character no-undo .
  define variable reason-code as character no-undo .
  define variable reason-name as character no-undo .
  define buffer buf_trn-reason for ub.trn-reason .
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input t-doc.obj-type
  ,input t-doc.obj-code
  ,input 'nakl_par':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for first thbjattr_thbj-attr no-lock where thbjattr_thbj-attr.prop-code = 'reasons-write-off':U:
    reason-code  = thbjattr_thbj-attr.property-value-character .
  end.
  if reason-code <> "" then
  do:
    do ii = 1 to num-entries(reason-code):
      reason-name = "" .
      for first buf_trn-reason no-lock where buf_trn-reason.reason-code = integer(entry(ii,reason-code)):
        reason-name = buf_trn-reason.reason-name .
      end.
      reason = reason + chr(44) + reason-name + chr(44) + entry(ii,reason-code) .
    end.
    reason = trim(reason,chr(44)).
    ASSIGN
      c-reason:LIST-ITEM-PAIRS  in frame d-out-prt = reason .
  end.
  if prt-mode <> 'ДОБАВЛЕНИЕ':U then do:
        find first ub.doc-line-attr no-lock where ub.doc-line-attr.doc-code = t-doc.doc-code and
        ub.doc-line-attr.gds-code = buf_goods.gds-code and
        ub.doc-line-attr.attr-code = "reasonSpisan" no-error .
        if available (ub.doc-line-attr) then do:
          c-reason = integer (doc-line-attr.attr-value) .
          display c-reason with frame d-out-prt .
        end.
    end.
END PROCEDURE.
