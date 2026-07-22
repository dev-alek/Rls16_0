using ibs.th.str.*.
using ibs.th.str.ptrl.forms.* from propath.
define  input parameter parparentproc   as   handle               no-undo .
define  input parameter parline-mode    as   character            no-undo .
define  input parameter pardoc-rec      as   recid                no-undo .
define  input-output parameter line-rec as   recid                no-undo .
define  input parameter pargds-rec      as   recid                no-undo .
define  input parameter parlns-cnt      as   integer              no-undo .
define output parameter parexit-cycle   as   logical              no-undo .
define  input parameter parqnty         like ub.doc-line.doc-qnty no-undo .
define  input parameter kind-qnty       as   character            no-undo .
define  input parameter parinplnsum     as   logical              no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Редактирование строки ПН":U .
define buffer t-doc     for ub.trn-doc.
define buffer buf_goods for ub.goods .
define buffer buf_contract-specif for ub.contract-specif .
define buffer bf_place-attr for ub.place-attr .
define temp-table tt-fr-doc-line no-undo like ub.doc-line
  field price-prod              like ub.doc-line.price-cli
  field price-prod-vat          like ub.doc-line.price-cli
  field price-sale              like ub.doc-line.price-cli
  field curr-abbr               like ub.currency.curr-abbr
  field unit-type               like ub.units.type
  field unit-base               like ub.units.unit-name
  field cli-art                 as character
  field gds-name                like ub.goods.gds-name
  field pl-code                 like ub.pl-gds.pl-code
  field state-measure-qnty      like ub.doc-line.doc-qnty
  field measure-qnty            like ub.doc-line.doc-qnty
  field state-measure-cli-qnty  like ub.doc-line.doc-qnty
  field measure-cli-qnty        like ub.doc-line.doc-qnty
  field trk-cli-qnty            like ub.doc-line.doc-qnty
  field obj-name                like ub.clients.obj-name
  field cst-code                like ub.parts.cst-code
  field last-num-day            as   integer
  field last-date               like ub.parts.last-date
  field contract-code           like ub.contract.contract-code
  field contract-prn-code       like ub.contract.contract-prn-code
  field type-inp-vat            as   logical
  field wt-place                as   decimal
  field froze-fact-qnty         as   logical  initial no
  field type-inp-sum            as   logical
  field tot-cli                 like ub.doc-line.price-cli
  field country-code            like ub.parts-attr.country-code
  field alpha1                  like ub.country.alpha1
  field short-name              like ub.country.short-name
  field fact-qnty-kg            like ub.doc-line.fact-qnty
  field alc-prod                as   logical
  field alc-part-code           as   character
  field alc-multi-parts         as   logical
  field alc-update              as   logical
  field alc-mark-db-num         as   integer
  field alc-mark-code           as   integer
  field alc-bottling-date       as   date
  field alc-ref-ab-path         as   character
  field alc-quality-certif-path as   character
  field alc-certif-path         as   character
  field alc-imp-type            as   character
  field alc-imp-code            as   integer
  field propan-perc             as   decimal format ">>9.9<<"
.
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
define  variable v-is-looksec as logical no-undo .
if lookup ("autotrnqr2d", parline-mode, ",") > 0
then do:
  v-is-looksec = true.
  parline-mode = replace (parline-mode, ",autotrnqr2d", "").
end.
define temp-table tt-old-list-tank no-undo like ub.doc-line-attr .
define stream outstream.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table  tt-tax no-undo
  field tax-code    like ub.tax.tax-code
  field individual  like ub.tax.individual
  field tax-name    like ub.tax.tax-name format "x(12)" column-label "Налог"
  field rate-code   like ub.tax-rate.rate-code
  field rate-name   like ub.tax-rate.rate-name format "x(12)"
  field tax-type    like ub.tax.tax-type
  field rate-value  like ub.tax-rate-value.rate-value
  field tax-rate-gds-rc  as recid
  field to-cashdesk like ub.tax.to-cashdesk
  index tax-code is unique primary tax-code
  .
procedure tax-val :
  define input  parameter       parartic      like ub.doc-line.artic     no-undo.
  define input  parameter       parprod-type  like ub.doc-line.prod-type no-undo.
  define input  parameter       parprod-code  like ub.doc-line.prod-code no-undo.
  define input  parameter       parunit-base  like ub.goods.unit-base    no-undo.
  define input  parameter       parnode-code  like ub.gds-prt.node-code  no-undo.
  define input  parameter       parunits-type like ub.units.type         no-undo.
  define input  parameter       parrec-id     as recid                   no-undo.
  define input  parameter       paris-log     as logical                 no-undo.
  define input  parameter       rdtaxcdvalue  as integer                 no-undo.
  define input  parameter       vattaxcdvalue as integer                 no-undo.
  define input  parameter       exctaxcdvalue as integer                 no-undo.
  define input  parameter       only-check    as logical                 no-undo.
  define input  parameter       parhost-code  like ub.sysconf.host-code  no-undo.
  define input  parameter       parobj-type   like ub.clients.obj-type   no-undo.
  define input  parameter       parobj-code   like ub.clients.obj-code   no-undo.
  define input  parameter       parroad-tax   like ub.doc-line.road-tax  no-undo.
  define input  parameter       parexcise     like ub.doc-line.excise    no-undo.
  define output parameter       parerr-mes    as character               no-undo.
  define input-output parameter parprice-sale like ub.price-list.price-sale no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
    define buffer buf_tax          for ub.tax .
    define buffer buf_tax-rate     for ub.tax-rate .
    define buffer buf_tax-units    for ub.tax-units .
    define buffer buf_tax-rate-gds for ub.tax-rate-gds .
    define buffer buf_goods        for ub.goods .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_prod-bc      for ub.prod-bc .
    define buffer buf_units        for ub.units .
    define buffer buf_shop         for ub.shop .
    define buffer buf_store        for ub.store .
    define buffer buf_gds-prt      for ub.gds-prt .
    define buffer buf_tt-tax       for tt-tax .
    define variable varrate-value    as decimal   initial ? no-undo.
    define variable pr-list-recid    as recid     initial ? no-undo.
    define variable varmes           as character no-undo.
    define variable varfactorrtvalue as char      initial ? no-undo.
    define variable varfactorrttype  as char      initial ? no-undo.
    define variable is-petrolium     as logical no-undo.
    define variable is-pieces        as logical no-undo.
    define variable vargds-code      like ub.goods.gds-code no-undo.
    define variable pargds-code      like ub.goods.gds-code no-undo.
    define variable var-fact-order   as decimal no-undo .
    define variable currate-code     like buf_tax-rate.rate-code no-undo .
    define variable currate-name     like buf_tax-rate.rate-name no-undo .
    define variable currate-gds-rc   as recid no-undo .
    define variable v-today          as date no-undo .
    define variable v-time           as integer no-undo .
    for each buf_tt-tax:
      delete buf_tt-tax.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    run factord-end-day in this-procedure (input v-today, output var-fact-order).
    if parartic     = ?
    or parprod-type = ?
    or parprod-code = ?
    or parunit-base = ?
    then do:
      find first buf_goods no-lock
        where recid(buf_goods) = parrec-id
        no-error .
    end.
    else do:
      find first buf_goods no-lock
        where buf_goods.artic = parartic
          and buf_goods.prod-type = parprod-type
          and buf_goods.prod-code = parprod-code
        no-error .
    end.
    if not available buf_goods then do:
      assign varmes = "Ошибка при поиске товара. Программа tax-val.i" + chr(10) .
      if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
    end.
    assign
      parartic     = buf_goods.artic
      parprod-type = buf_goods.prod-type
      parprod-code = buf_goods.prod-code
      parunit-base = buf_goods.unit-base
      pargds-code  = buf_goods.gds-code
    .
    if parunits-type = ?
    then do:
      find buf_units no-lock
        where buf_units.unit-name = parunit-base
        no-error .
      if not available buf_units then do:
        assign
          varmes =  varmes + "Ошибка при поиске единицы измерения. Программа tax-val.i" + chr(10)
        .
        if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
      end.
      assign
        parunits-type = buf_units.type
      .
    end.
    if parhost-code = ?
    or parhost-code = 0
    then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  abs(parobj-code)
  ,output parhost-code
  ) no-error .
      if error-status :error then do:
        assign
          varmes =  varmes + substitute("Ошибка при определении фирмы для объекта &1 &2. Программа tax-val.i"
            ,string(parobj-type)
            ,string(parobj-code)
            ) + chr(10)
        .
        if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
      end.
    end.
    assign
      vargds-code = buf_goods.gds-code
    .
    for each buf_tax-units no-lock
      where LOOKUP(buf_tax-units.type, parunits-type) > 0
    ,first buf_tax no-lock
      where buf_tax.tax-code = buf_tax-units.tax-code
    :
      find first buf_tt-tax where
                 buf_tt-tax.tax-code = buf_tax.tax-code no-error .
      if not available buf_tt-tax then do:
        create buf_tt-tax .
      end.
      assign
        buf_tt-tax.tax-code = buf_tax.tax-code
      .
      if buf_tax.individual = false then do:
        assign
          currate-gds-rc = ?
        .
        _tax-rate-gds:
        for each buf_tax-rate-gds no-lock where
                buf_tax-rate-gds.gds-code = pargds-code and
                buf_tax-rate-gds.tax-code = buf_tax.tax-code,
        first buf_tax-rate where
              buf_tax-rate.tax-code  = buf_tax-rate-gds.tax-code and
              buf_tax-rate.rate-code = buf_tax-rate-gds.rate-code no-lock
        by buf_tax-rate-gds.host-code
        by buf_tax-rate-gds.obj-type
        by buf_tax-rate-gds.obj-code
        by buf_tax-rate-gds.fact-order
        :
          if buf_tax-rate-gds.fact-order > var-fact-order then do:
            next _tax-rate-gds.
          end.
          if buf_tax-rate-gds.host-code = 0 or
            ((buf_tax-rate-gds.host-code = parhost-code) or
            (buf_tax-rate-gds.obj-type = parobj-type AND
            buf_tax-rate-gds.obj-code = parobj-code))
          then do:
            assign
            currate-code = buf_tax-rate.rate-code
            currate-name = buf_tax-rate.rate-name
            currate-gds-rc = recid(buf_tax-rate)
            .
          end.
          else do:
            next _tax-rate-gds.
          end.
        end.
        if currate-gds-rc = ? then do:
          assign varmes = "Не найдена ставка налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          chr(10).
          if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
        end.
      end.
      assign
        buf_tt-tax.rate-code   = currate-code
        buf_tt-tax.individual  = buf_tax.individual
        buf_tt-tax.tax-name    = buf_tax.tax-name
        buf_tt-tax.rate-name   = currate-name
        buf_tt-tax.tax-type    = buf_tax.tax-type
        buf_tt-tax.to-cashdesk = buf_tax.to-cashdesk
        buf_tt-tax.tax-rate-gds-rc  = currate-gds-rc
      .
    end.
    if parprice-sale = ?
    or parexcise     = ?
    or parroad-tax   = ?
    then do:
      if parnode-code = ? then do:
          FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
          parnode-code = buf_gds-prt.node-code.
      end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  vargds-code
  ,input  parnode-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
      assign
        parprice-sale = gp-price-sale
        parexcise     = gp-excise
        parroad-tax   = gp-road-tax
      .
    end.
    if only-check then do:
      return .
    end.
    for each buf_tt-tax no-lock
    on error undo, return error
    :
      if buf_tt-tax.tax-rate-gds-rc = ? then NEXT.
      if not buf_tt-tax.individual then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  buf_tt-tax.tax-code
  ,input  buf_tt-tax.rate-code
  ,input  ?
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,output varrate-value
  ) no-error .
        if error-status:error or varrate-value = ? then do:
          assign varmes = "Не найдена величина ставки налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name + " " + string(buf_tt-tax.rate-code) +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          " фирма: " + string(parhost-code) +
                          " объект: " + parobj-type + " " + string(parobj-code) + chr(10).
          if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
        end.
        assign
        buf_tt-tax.rate-value  = varrate-value
        .
      end.
      else do:
        if not avail buf_gds-prt then
        FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
        if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U then do:
          find FIRST buf_prod-bc where
                      buf_prod-bc.b-code     = buf_goods.gds-code     and
                      buf_prod-bc.bc-on = yes no-lock no-error.
          if not available buf_prod-bc then do:
            assign varmes = "Не найден ДОП.бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
          end.
        end.
        else do:
          find buf_bar-code where
                buf_bar-code.gds-code  = vargds-code     and
                buf_bar-code.node-code = buf_gds-prt.node-code and
                buf_bar-code.part-code = ""           and
                buf_bar-code.in-code   = ""           and
                buf_bar-code.unit-cli  = parunit-base  no-lock no-error.
          if not available buf_bar-code then do:
            assign varmes = "Не найден бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
          end.
        end.
        if buf_tt-tax.tax-code = rdtaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U
                                then integer(buf_prod-bc.b-str)
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parroad-tax
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.
        if buf_tt-tax.tax-code = exctaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U
                                then integer(buf_prod-bc.b-str)
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parexcise
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable vss-include-info13 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
procedure cpprclig :
  define input        parameter pardoc-code       as   character                  no-undo.
  define input        parameter parcli-code       like ub.trn-doc.cli-code        no-undo.
  define input        parameter parcli-type       like ub.trn-doc.cli-type        no-undo.
  define input        parameter parhost-code      like ub.trn-doc.host-code       no-undo.
  define input        parameter parbase-rate      like ub.trn-doc.base-rate       no-undo.
  define input        parameter parbase-scale     like ub.trn-doc.base-scale      no-undo.
  define input        parameter parexch-rate      like ub.trn-doc.exch-rate       no-undo.
  define input        parameter parexch-scale     like ub.trn-doc.exch-scale      no-undo.
  define input        parameter parvat-type       like ub.trn-doc.vat-type        no-undo.
  define input        parameter parslt-type       like ub.trn-doc.slt-type        no-undo.
  define input        parameter parartic          like ub.doc-line.artic          no-undo.
  define input        parameter parprod-type      like ub.doc-line.prod-type      no-undo.
  define input        parameter parprod-code      like ub.doc-line.prod-code      no-undo.
  define input        parameter paris-cli-tax     as   logical                    no-undo.
  define input        parameter parcli-base-rate  like ub.doc-line.cli-base-rate  no-undo.
  define input        parameter partransport-rubl like ub.doc-line.transport-rubl no-undo.
  define input        parameter parother-rubl     like ub.doc-line.other-rubl     no-undo.
  define output       parameter parprice-cli      like ub.doc-line.price-cli      no-undo.
  define output       parameter parprice-base     like ub.doc-line.price-base     no-undo.
  define output       parameter parprice-rubl     like ub.doc-line.price-rubl     no-undo.
  define input-output parameter parvat-pc         like ub.doc-line.vat-pc         no-undo.
  define input-output parameter parslt-pc         like ub.doc-line.slt-pc         no-undo.
  define input-output parameter parroad-tax       like ub.doc-line.road-tax       no-undo.
  define input-output parameter parexcise         like ub.doc-line.excise         no-undo.
  define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
  define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
  define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
  define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
  define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
  define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
  define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
  define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
  define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
  define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
  define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
  define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
  define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
  define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
  define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
  define variable varprice-base               like ub.doc-line.price-base no-undo.
  define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
  define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
  define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
  define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
  define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
  define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
  define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
  define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
  define variable v-specif-found              as   logical                no-undo.
  define variable v-rcv-found                 as   logical                no-undo .
  define buffer bf_cli-gds         for ub.cli-gds .
  define buffer bf_doc-line        for ub.doc-line.
  define buffer bf_trn-doc         for ub.trn-doc.
  define buffer bf_goods           for ub.goods.
  define buffer bf_contract-specif for ub.contract-specif.
  define buffer buf_ord-chain      for ub.ord-chain .
  define buffer buf_ord-doc-rcv    for ub.ord-doc-rcv .
  define buffer buf_ord-line-rcv   for ub.ord-line-rcv .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info13, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info13 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info13 )
  :
    assign
      v-rcv-found    = false
      v-specif-found = false
    .
    find first buf_ord-chain no-lock
      where buf_ord-chain.rel-doc-code =  pardoc-code
        and buf_ord-chain.rel-doc-type = 'trn':u
      no-error .
    if available buf_ord-chain then do:
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code
      no-error .
      if available buf_ord-doc-rcv then do:
        find first buf_ord-line-rcv no-lock
          where buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
            and buf_ord-line-rcv.artic     = parartic
            and buf_ord-line-rcv.prod-type = parprod-type
            and buf_ord-line-rcv.prod-code = parprod-code
          no-error .
        if available buf_ord-line-rcv then do:
          find first bf_trn-doc  no-lock
            where bf_trn-doc.doc-code = pardoc-code
          .
          assign
            parprice-cli = buf_ord-line-rcv.price-cli
            parroad-tax  = buf_ord-line-rcv.road-tax
            parexcise    = buf_ord-line-rcv.excise
            v-rcv-found  = true
            .
          if parslt-type <> 'без':U then do:
            if bf_trn-doc.slt-type <> 'без':U then do:
              assign
                parslt-pc = buf_ord-line-rcv.slt-pc
              .
            end.
          end.
          else do:
            assign
              parslt-pc = 0
            .
          end.
          if parvat-type <> 'без':U then do:
            if bf_trn-doc.vat-type <> 'без':U then do:
              assign
                parvat-pc = buf_ord-line-rcv.vat-pc
              .
            end.
          end.
          else do:
            assign
              parvat-pc = 0
            .
          end.
        end.
      end.
    end.
    if v-rcv-found = false then do:
      find first bf_trn-doc no-lock
        where bf_trn-doc.doc-code = pardoc-code
        no-error.
      if available bf_trn-doc
        and bf_trn-doc.contract-code <> 0
      then do:
        find first bf_goods no-lock
          where bf_goods.artic     = parartic
            and bf_goods.prod-code = parprod-code
            and bf_goods.prod-type = parprod-type
          no-error.
        if available bf_goods then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  bf_trn-doc.host-code,
    INPUT  bf_trn-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = bf_trn-doc.host-code
      i-gl-Contract-Code  = bf_trn-doc.contract-code
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           AND bf_contract-specif.Gds-code     = bf_goods.gds-code
           NO-ERROR
           .
          if available bf_contract-specif then do:
            assign
              parprice-cli   = (bf_contract-specif.price-cli / bf_contract-specif.cli-base-rate)  * parcli-base-rate
              parvat-type    = bf_contract-specif.vat-type
              parvat-pc      = bf_contract-specif.vat-pc
              v-specif-found = yes
            .
          end.
        end.
      end.
      find first bf_cli-gds no-lock
        where bf_cli-gds.cli-code  = parcli-code
          and bf_cli-gds.cli-type  = parcli-type
          and bf_cli-gds.host-code = parhost-code
          and bf_cli-gds.artic     = parartic
          and bf_cli-gds.prod-code = parprod-code
          and bf_cli-gds.prod-type = parprod-type
        no-error.
      if available bf_cli-gds then do:
        if v-specif-found = false then do:
          assign
            parprice-cli = bf_cli-gds.price-cli
          .
        end.
        if paris-cli-tax then do:
          find first bf_doc-line no-lock
            where bf_doc-line.doc-code  = bf_cli-gds.in-code
              and bf_doc-line.artic     = bf_cli-gds.artic
              and bf_doc-line.prod-type = bf_cli-gds.prod-type
              and bf_doc-line.prod-code = bf_cli-gds.prod-code
            no-error.
          if available bf_doc-line then do:
            find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
            assign
              parroad-tax = bf_doc-line.road-tax
              parexcise   = bf_doc-line.excise
            .
            if parslt-type <> 'без':U then do:
              if bf_trn-doc.slt-type <> 'без':U then do:
                assign
                  parslt-pc = bf_doc-line.slt-pc
                .
              end.
            end.
            else do:
              assign
                parslt-pc = 0
              .
            end.
            if parvat-type <> 'без':U then do:
              if bf_trn-doc.vat-type <> 'без':U then do:
                if v-specif-found = false then do:
                  assign
                    parvat-pc = bf_doc-line.vat-pc
                  .
                end.
              end.
            end.
            else do:
              assign
                parvat-pc = 0
              .
            end.
          end.
        end.
      end.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   pardoc-code
  ,input   parbase-rate
  ,input   parbase-scale
  ,input   parexch-rate
  ,input   parexch-scale
  ,input   parvat-type
  ,input   parslt-type
  ,input   parartic
  ,input   parprod-type
  ,input   parprod-code
  ,input   parprice-cli
  ,input   parcli-base-rate
  ,input   parprice-rubl
  ,input   parvat-pc
  ,input   parslt-pc
  ,input   parroad-tax
  ,input   partransport-rubl
  ,input   parother-rubl
  ,output  varprice-cli
  ,output  varprice-cli-unit-base
  ,output  varprice-road-tax
  ,output  varprice-other-exp
  ,output  varprice-transport-exp
  ,output  varprice-without-abs
  ,output  varprice-slt
  ,output  varprice-no-slt
  ,output  varprice-vat
  ,output  varprice-no-vat-slt
  ,output  varprice-rubl
  ,output  varprice-road-tax-rubl
  ,output  varprice-other-exp-rubl
  ,output  varprice-transport-exp-rubl
  ,output  varprice-without-abs-rubl
  ,output  varprice-slt-rubl
  ,output  varprice-no-slt-rubl
  ,output  varprice-vat-rubl
  ,output  varprice-no-vat-slt-rubl
  ,output  varprice-base
  ,output  varprice-road-tax-base
  ,output  varprice-other-exp-base
  ,output  varprice-transport-exp-base
  ,output  varprice-without-abs-base
  ,output  varprice-slt-base
  ,output  varprice-no-slt-base
  ,output  varprice-vat-base
  ,output  varprice-no-vat-slt-base
  ) no-error.
    if error-status:error then do:
      return error "Ошибка при пересчете линии документа".
    end.
    assign
      parprice-cli  = varprice-cli
      parprice-rubl = varprice-rubl
      parprice-base = varprice-base
    .
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure integerm :
  define input  parameter p-string      as character no-undo .
  define input  parameter p-allow-sign  as logical   no-undo .
  define input  parameter p-allow-comma as logical   no-undo .
  define output parameter p-value       as integer   no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
  define variable v-replace-string as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-string = ?
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Не задана строка для преобразования"
      .
      return .
    end.
    if p-string = ""
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Задана пустая строка для преобразования"
      .
      return .
    end.
    assign
      p-value = integer(p-string) no-error
    .
    if error-status :error = true
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'"
                                 ,p-string
                                 )
      .
      return .
    end.
    if index(p-string, ' ':u) > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит символы пробела"
                                 ,p-string
                                 )
      .
      return .
    end.
    assign
      v-replace-string = p-string
      v-replace-string = replace(v-replace-string, '0':u, '9':u)
      v-replace-string = replace(v-replace-string, '1':u, '9':u)
      v-replace-string = replace(v-replace-string, '2':u, '9':u)
      v-replace-string = replace(v-replace-string, '3':u, '9':u)
      v-replace-string = replace(v-replace-string, '4':u, '9':u)
      v-replace-string = replace(v-replace-string, '5':u, '9':u)
      v-replace-string = replace(v-replace-string, '6':u, '9':u)
      v-replace-string = replace(v-replace-string, '7':u, '9':u)
      v-replace-string = replace(v-replace-string, '8':u, '9':u)
    .
    if p-allow-sign = true
    then do:
      if index('+-':u, substring(v-replace-string, 1, 1)) > 0
      then do:
        assign
          v-replace-string = substring(v-replace-string, 2)
        .
      end.
    end.
    else do:
      if substring(v-replace-string, 1, 1) = '+':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ плюс. "
                                  ,p-string
                                  )
        .
        return .
      end.
      if substring(v-replace-string, 1, 1) = '-':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ минус. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if p-allow-comma = true
    then do:
      assign
        v-replace-string = replace(v-replace-string, ',', '')
      .
    end.
    else do:
      if index(v-replace-string, ',') > 0
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака разделителя тысяч."
                                  + "Строка содержит знак разделителя тысяч. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if index(p-string, '.') > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит знак десятичной точки"
                                 ,p-string
                                 )
      .
      return .
    end.
    if v-replace-string <> fill('9', length(v-replace-string))
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Встречены символы, недопустимые для целого числа '&2'"
                                 ,p-string
                                 ,replace(v-replace-string, '9', '')
                                 )
      .
      return .
    end.
    assign
      p-data-valid = true
      p-message    = ""
    .
  end.
end procedure.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info30 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define temp-table tt-rvs-line-pump-delta no-undo like ub.rvs-line-pump
      field deltaVol as decimal
      field density as decimal
      field is-err as logical
      field find-pair as logical
    .
    define variable infoSectionsTotal       as class InfoSectionsTotal no-undo.
    define variable tanksForm               as class ibs.th.str.ptrl.forms.tanksections no-undo.
    define variable v-prt-autoent-obj-type as character    no-undo .
    define variable v-prt-autoent-obj-code as character    no-undo .
    define variable v-prt-start-real-date  like ub.rvs-line.real-date    no-undo .
    define variable v-prt-start-real-time  like ub.rvs-line.real-time    no-undo .
    define variable v-prt-end-real-date    like ub.rvs-line.real-date    no-undo .
    define variable v-prt-end-real-time    like ub.rvs-line.real-time    no-undo .
    define variable v-prt-fio              as character    no-undo .
    define variable v-prt-ptbotype         as character    no-undo .
    define variable v-prt-ptbocode         as character    no-undo .
    define variable was_setting            as logical      no-undo initial no .
    define variable ptoldfilvalue          as character    no-undo.
    define variable ptoldfiltype           as character    no-undo.
    define variable stfactplvalue          as character    no-undo initial ? .
    define variable stfactpltype           as character    no-undo initial ? .
    define variable varupd-fact-qnty       as logical      no-undo initial yes .
    define variable varrevision            as logical      no-undo initial no  .
    define variable varpercrev             as decimal      no-undo initial ?   .
    define variable varauto-tank           as logical      no-undo initial no  .
    define variable varpercauto            as decimal      no-undo initial ?   .
    define variable varinv                 as logical      no-undo initial no  .
    define variable varpercinv             as decimal      no-undo initial ?   .
    define variable varinv-set             as logical      no-undo initial no  .
    define variable varrn-algo             as logical      no-undo initial no  .
    define variable varrn-acc-ship         as decimal      no-undo .
    define variable varcar-num             as character    no-undo .
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-value2 as character no-undo.
    define variable v-ok as logical no-undo.
    define variable pl-rvd-dens as logical no-undo .
    define variable pl-rvd-lvl as logical no-undo .
    define variable pl-rvd-temp as logical no-undo .
    procedure return-rvs-qnty :
      define  input parameter p-doc-code            like ub.trn-doc.doc-code            no-undo .
      define  input parameter p-gds-code            like ub.goods.gds-code              no-undo .
      define  input parameter p-pl-code             like ub.rvs-line.pl-code            no-undo .
      define output parameter p-rvs-qnty-before     like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-qnty-after      like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
      define output parameter p-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
      define output parameter p-delta-mass-qnty     as decimal no-undo .
      define output parameter p-trk-err             as logical no-undo .
      define buffer bf_bef_rvs-doc  for ub.rvs-doc  .
      define buffer bf_aft_rvs-doc  for ub.rvs-doc  .
      define buffer bf_bef_rvs-line for ub.rvs-line .
      define buffer bf_aft_rvs-line for ub.rvs-line .
      define buffer bf_rvs-line-attr for ub.rvs-line-attr .
      define buffer buf_rvs-line-pump for ub.rvs-line-pump .
      assign
        p-rvs-qnty-before     = 0.0
        p-rvs-qnty-after      = 0.0
        p-rvs-cli-qnty-before = 0.0
        p-rvs-cli-qnty-after  = 0.0
      .
      empty temp-table tt-rvs-line-pump-delta .
      for each bf_bef_rvs-doc no-lock
        where bf_bef_rvs-doc.rvs-type = 'перед_док':U
          and bf_bef_rvs-doc.out-code = p-doc-code
      :
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
          for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bf_bef_rvs-line.rvs-code
                                               and buf_rvs-line-pump.obj-type = bf_bef_rvs-line.obj-type
                                               and buf_rvs-line-pump.obj-code = bf_bef_rvs-line.obj-code
                                               and buf_rvs-line-pump.pl-code  = bf_bef_rvs-line.pl-code
                                               and buf_rvs-line-pump.gds-code = bf_bef_rvs-line.gds-code
          :
            create tt-rvs-line-pump-delta .
            buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
            assign
              tt-rvs-line-pump-delta.rvs-code = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
              tt-rvs-line-pump-delta.density = (bf_bef_rvs-line.state-density / 2)
            .
            if tt-rvs-line-pump-delta.state-el-cnt = ?
            or tt-rvs-line-pump-delta.state-el-cnt <= 0
            then do :
              tt-rvs-line-pump-delta.is-err = yes .
            end .
          end.
        end.
      end.
      for each bf_aft_rvs-doc no-lock
        where bf_aft_rvs-doc.rvs-type = 'после_док':U
          and bf_aft_rvs-doc.out-code = p-doc-code
      :
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
          find first bf_rvs-line-attr no-lock
            where bf_rvs-line-attr.rvs-code = bf_aft_rvs-line.rvs-code
              and bf_rvs-line-attr.obj-type = bf_aft_rvs-line.obj-type
              and bf_rvs-line-attr.obj-code = bf_aft_rvs-line.obj-code
              and bf_rvs-line-attr.pl-code = bf_aft_rvs-line.pl-code
              and bf_rvs-line-attr.gds-code = p-gds-code
              and bf_rvs-line-attr.attr-code = "delta-mass-qnty"
              no-error.
          if available (bf_rvs-line-attr)
          then p-delta-mass-qnty = decimal (bf_rvs-line-attr.attr-value).
          else p-delta-mass-qnty = 0.65.
          assign
            p-rvs-qnty-after     = p-rvs-qnty-after     + bf_aft_rvs-line.state-measure-qnty
            p-rvs-cli-qnty-after = p-rvs-cli-qnty-after + bf_aft_rvs-line.state-measure-cli-qnty
          .
          release bf_rvs-line-attr.
          for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bf_aft_rvs-line.rvs-code
                                               and buf_rvs-line-pump.obj-type = bf_aft_rvs-line.obj-type
                                               and buf_rvs-line-pump.obj-code = bf_aft_rvs-line.obj-code
                                               and buf_rvs-line-pump.pl-code  = bf_aft_rvs-line.pl-code
                                               and buf_rvs-line-pump.gds-code = bf_aft_rvs-line.gds-code
          :
            find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                                                and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                no-error .
            if not available tt-rvs-line-pump-delta
            then do :
              create tt-rvs-line-pump-delta .
              buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
              assign
                tt-rvs-line-pump-delta.rvs-code = "after-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                tt-rvs-line-pump-delta.is-err = yes
              .
            end .
            else do :
              tt-rvs-line-pump-delta.find-pair = yes .
              if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
              then do :
                tt-rvs-line-pump-delta.is-err = yes .
              end .
              else do :
                tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (bf_aft_rvs-line.state-density / 2) .
              end .
            end .
          end .
        end.
      end.
      p-trk-err = no .
      find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.is-err no-error .
      if available tt-rvs-line-pump-delta
      then do :
        p-trk-err = yes .
        return .
      end .
      for each tt-rvs-line-pump-delta :
        assign
          p-rvs-qnty-after     = p-rvs-qnty-after     + tt-rvs-line-pump-delta.deltaVol
          p-rvs-cli-qnty-after = p-rvs-cli-qnty-after + (tt-rvs-line-pump-delta.deltaVol * tt-rvs-line-pump-delta.density)
        .
      end .
    end procedure.
    procedure return-rvs-sec-qnty :
      define  input parameter p-doc-code            like ub.trn-doc.doc-code            no-undo .
      define  input parameter p-gds-code            like ub.goods.gds-code              no-undo .
      define  input parameter p-sec-name            as character                        no-undo .
      define  input parameter p-loc1                as character                        no-undo .
      define output parameter p-rvs-qnty-before     like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-qnty-after      like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
      define output parameter p-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
      define buffer bf_bef_rvs-doc  for ub.rvs-doc  .
      define buffer bf_aft_rvs-doc  for ub.rvs-doc  .
      define buffer bf_bef_rvs-line for ub.rvs-line .
      define buffer bf_aft_rvs-line for ub.rvs-line .
      define buffer bf_place        for ub.place .
      assign
        p-rvs-qnty-before     = 0.0
        p-rvs-qnty-after      = 0.0
        p-rvs-cli-qnty-before = 0.0
        p-rvs-cli-qnty-after  = 0.0
      .
      find first bf_bef_rvs-doc no-lock where bf_bef_rvs-doc.rvs-type = 'перед_док':U
                                          and bf_bef_rvs-doc.out-code = p-doc-code
                                          and num-entries(bf_bef_rvs-doc.rvs-code, "-") = 3
                                          and entry(2, bf_bef_rvs-doc.rvs-code, "-") = p-sec-name
                                          no-error .
      if not available bf_bef_rvs-doc
      then do :
        find first bf_bef_rvs-doc no-lock where bf_bef_rvs-doc.rvs-type = 'перед_док':U
                                            and bf_bef_rvs-doc.out-code = p-doc-code
                                            and num-entries(bf_bef_rvs-doc.rvs-code, "-") = 2
                                            no-error .
      end .
      if available bf_bef_rvs-doc
      then do :
        for first bf_place no-lock where bf_place.obj-type = bf_bef_rvs-doc.obj-type
                                     and bf_place.obj-code = bf_bef_rvs-doc.obj-code
                                     and bf_place.loc1     = p-loc1
                                     and bf_place.status_  = "",
        each bf_bef_rvs-line no-lock
          where bf_bef_rvs-line.rvs-code = bf_bef_rvs-doc.rvs-code
            and bf_bef_rvs-line.obj-type = bf_bef_rvs-doc.obj-type
            and bf_bef_rvs-line.obj-code = bf_bef_rvs-doc.obj-code
            and bf_bef_rvs-line.gds-code = p-gds-code
            and bf_bef_rvs-line.pl-code  = bf_place.pl-code
        :
          assign
            p-rvs-qnty-before     = p-rvs-qnty-before     + bf_bef_rvs-line.state-measure-qnty
            p-rvs-cli-qnty-before = p-rvs-cli-qnty-before + bf_bef_rvs-line.state-measure-cli-qnty
          .
        end.
      end.
      find first bf_aft_rvs-doc no-lock where bf_aft_rvs-doc.rvs-type = 'после_док':U
                                          and bf_aft_rvs-doc.out-code = p-doc-code
                                          and num-entries(bf_aft_rvs-doc.rvs-code, "-") = 3
                                          and entry(2, bf_aft_rvs-doc.rvs-code, "-") = p-sec-name
                                          no-error .
      if not available bf_aft_rvs-doc
      then do :
        find first bf_aft_rvs-doc no-lock where bf_aft_rvs-doc.rvs-type = 'после_док':U
                                            and bf_aft_rvs-doc.out-code = p-doc-code
                                            and num-entries(bf_aft_rvs-doc.rvs-code, "-") = 2
                                            no-error .
      end .
      if available bf_aft_rvs-doc
      then do :
        for first bf_place no-lock where bf_place.obj-type = bf_aft_rvs-doc.obj-type
                                     and bf_place.obj-code = bf_aft_rvs-doc.obj-code
                                     and bf_place.loc1     = p-loc1
                                     and bf_place.status_  = "",
        each bf_aft_rvs-line no-lock
          where bf_aft_rvs-line.rvs-code = bf_aft_rvs-doc.rvs-code
            and bf_aft_rvs-line.obj-type = bf_aft_rvs-doc.obj-type
            and bf_aft_rvs-line.obj-code = bf_aft_rvs-doc.obj-code
            and bf_aft_rvs-line.gds-code = p-gds-code
            and bf_aft_rvs-line.pl-code  = bf_place.pl-code
        :
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
      on error undo, return error substitute( "&1 (check-before). &2&3&4", vss-include-info30, return-value, chr(10), error-status :get-message ( 1 ) )
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
      define buffer buf_place           for ub.place .
      define variable ii as integer no-undo .
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
            if is-gas(p-gds-code) then next.
            run placelib_get-attr(input "place-virtual"
                                 ,input tt-doc-pl.obj-code
                                 ,input tt-doc-pl.obj-type
                                 ,input tt-doc-pl.pl-code
                                 ,output v-value
                                 ,output v-ok) no-error.
            is-vir = if (v-ok and logical(v-value)) then true else false.
            if is-vir then next.
            find first buf_place no-lock where buf_place.obj-type = tt-doc-pl.obj-type
                                           and buf_place.obj-code = tt-doc-pl.obj-code
                                           and buf_place.pl-code  = tt-doc-pl.pl-code
                                           no-error .
            run placelib_get-attr  (
               input "place-com-tanks"
              ,input tt-doc-pl.obj-code
              ,input tt-doc-pl.obj-type
              ,input tt-doc-pl.pl-code
              ,output v-value
              ,output v-ok      )
            no-error.
            if  v-ok
            and v-value > ""
            then do :
              v-value = v-value + "," + buf_place.loc1 .
              do ii = 1 to num-entries(v-value) :
                find first buf_place no-lock where buf_place.obj-type = tt-doc-pl.obj-type
                                               and buf_place.obj-code = tt-doc-pl.obj-code
                                               and buf_place.loc1     = entry(ii, v-value)
                                               and buf_place.status_  = ""
                                               no-error .
                if available buf_place
                then do :
                  find first buf_before_rvs-line no-lock
                    where buf_before_rvs-line.rvs-code = buf_before_rvs-doc.rvs-code
                      and buf_before_rvs-line.obj-type = buf_before_rvs-doc.obj-type
                      and buf_before_rvs-line.obj-code = buf_before_rvs-doc.obj-code
                      and buf_before_rvs-line.pl-code  = buf_place.pl-code
                      and buf_before_rvs-line.gds-code = p-gds-code
                    no-error .
                  if not available buf_before_rvs-line then do:
                    message
                      "По данному товару нет заготовки для сверки <<до налива топлива>>"
                      "по резервуару" buf_place.pl-code "."
                      view-as alert-box error .
                    return error .
                  end.
                  if buf_before_rvs-line.state-measure-qnty = ?
                  then do:
                    message
                      "Не заполнены данные по резервуару №" buf_place.loc1
                      " в документе сверки «До»!"
                      view-as alert-box error .
                    return error .
                  end.
                end .
              end .
            end .
            else do :
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
            end .
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
      define output parameter p-pl-code      like ub.place.pl-code    no-undo .
      define buffer buf_doc-line for ub.doc-line.
      block_tr:
      do transaction
      on error  undo block_tr, return error substitute( "&1 (action-rvs-line). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on stop   undo block_tr, return error substitute( "&1 (action-rvs-line). stop", vss-workfile )
      on endkey undo block_tr, return error substitute( "&1 (action-rvs-line). endkey", vss-workfile )
      :
        define variable v-rvs-code     like ub.rvs-doc.rvs-code no-undo .
        define variable v-act-name     as   character           no-undo .
        define variable v-log          as   logical             no-undo .
        define variable is-rvs-place   as   logical             no-undo .
        define variable varnum         as   integer             no-undo.
        define variable varcur-rvs     as   integer             no-undo.
        define variable v-today        as   date                no-undo.
        define variable v-time         as   integer             no-undo.
        define variable v-value        as character no-undo .
        define variable v-value2       as character no-undo .
        define variable v-ok           as logical   no-undo .
        define variable ii             as integer   no-undo .
        define variable v-com-vessel-rvs as logical no-undo init no .
        define variable v-com-vessel-is-meas as logical no-undo init no .
        define variable v-code         as character    no-undo.
        define variable is-com-tanks   as logical no-undo init no .
        define variable v-pump-err     as character no-undo init "":U .
        define variable v-pl-list      as character no-undo init "":U .
        define buffer buf_rvs-doc       for ub.rvs-doc .
        define buffer buf_rvs-line      for ub.rvs-line .
        define buffer buf_rvs-line-pump for ub.rvs-line-pump .
        define buffer buf_place         for ub.place .
        define buffer bf_pump-nozzle    for ub.pump-nozzle.
        define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
        define buffer bf_pl-gds         for ub.pl-gds.
        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-density         like ub.rvs-line.state-density          no-undo .
        define variable v-com-tank-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-com-tank-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-com-tank-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-com-tank-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-attr-type           as character no-undo .
        define variable v-attr-value          as character   no-undo .
        define variable v-delta-mass-qnty as decimal   no-undo .
        define variable v-com-tank-delta-mass-qnty as decimal   no-undo .
        define variable v-asi-ip  as character no-undo .
        define variable v-asi-port as character no-undo .
        define variable v-asi-type as character no-undo .
        define variable infoSecObj        as class InfoSection no-undo .
        define variable v-KPrvs-secs      as character no-undo .
        define variable v-KPrvs-doc-pl    as logical   no-undo .
        define variable v-trk-err         as logical   no-undo .
        define variable v-com-tanks-not-filled as logical no-undo init no .
        assign
          p-pl-code = ?
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
          p-pl-code      = ?
        .
        if p-action = 'ПРОСМОТР':U
        then do :
          for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                          and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                          and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                          and buf_rvs-line.gds-code = tt-doc-pl.gds-code
          :
            assign
              p-pl-code      = buf_rvs-line.pl-code
              v-pl-list      = v-pl-list + string(buf_rvs-line.pl-code) + ","
            .
          end .
          if p-pl-code = ?
          then do :
            message
              "Не найдена строка сверки:" skip
              substitute( "товар &1", tt-doc-pl.gds-code ) skip
              substitute( "место хранения &1", tt-doc-pl.pl-code ) skip
              view-as alert-box error .
            undo block_tr, return error .
          end .
        end .
        else do :
          tt-doc-pl_ :
          for each tt-doc-pl no-lock
          on error undo block_tr, return error return-value
          :
            if not is-sug(tt-doc-pl.gds-code)
            then do :
              v-KPrvs-secs = "" .
              v-KPrvs-doc-pl = no .
              find first buf_place no-lock where buf_place.obj-type = t-doc.obj-type
                                             and buf_place.obj-code = t-doc.obj-code
                                             and buf_place.pl-code  = tt-doc-pl.pl-code
                                             .
              do ii = 1 to infoSectionsTotal:SectionNum :
                infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
                if infoSecObj:ListTank = buf_place.loc1
                then do :
                  if infoSecObj:IsKP
                  then do :
                    v-KPrvs-doc-pl = yes .
                  end .
                  v-KPrvs-secs = v-KPrvs-secs + "," + infoSecObj:SectionName .
                end .
              end .
              v-KPrvs-secs = trim(v-KPrvs-secs, ",") .
              if v-KPrvs-doc-pl
              and num-entries(v-KPrvs-secs) >= 1
              then do :
                next tt-doc-pl_ .
              end .
            end .
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
              p-pl-code      = buf_rvs-line.pl-code
              v-pl-list      = v-pl-list + string(buf_rvs-line.pl-code) + "," .
            .
            run placelib_get-attr  (
               input "place-com-tanks"
              ,input t-doc.obj-code
              ,input t-doc.obj-type
              ,input tt-doc-pl.pl-code
              ,output v-value
              ,output v-ok      )
            no-error.
            if  v-ok
            and v-value > ""
            and p-action-type = "edit"
            then do :
              is-com-tanks = yes .
              find first buf_place no-lock
                where buf_place.obj-type = t-doc.obj-type
                  and buf_place.obj-code = t-doc.obj-code
                  and buf_place.pl-code  = tt-doc-pl.pl-code
              .
              do ii = 1 to num-entries(v-value) :
                find first buf_place no-lock where buf_place.obj-type = tt-doc-pl.obj-type
                                               and buf_place.obj-code = tt-doc-pl.obj-code
                                               and buf_place.loc1     = entry(ii, v-value)
                                               and buf_place.status_  = ""
                                               no-error .
                if available buf_place
                then do :
                  find first buf_rvs-line no-lock
                    where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                      and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                      and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                      and buf_rvs-line.pl-code  = buf_place.pl-code
                      and buf_rvs-line.gds-code = tt-doc-pl.gds-code
                    no-error .
                  if not available buf_rvs-line
                  then do:
                    if t-doc.status_ <> 'факт':U
                    then do :
                      message
                        "Не найдена строка сверки:" skip
                        substitute( "товар &1", tt-doc-pl.gds-code ) skip
                        substitute( "место хранения &1", buf_place.pl-code ) skip
                        view-as alert-box error .
                      undo block_tr, return error .
                    end .
                  end.
                  else do :
                    assign
                      p-pl-code      = buf_rvs-line.pl-code
                      v-pl-list      = v-pl-list + string(buf_rvs-line.pl-code) + ","
                    .
                  end .
                end .
              end .
            end .
          end.
        end .
        assign v-pl-list = trim(v-pl-list, ",") .
        if num-entries(v-pl-list) > 1
        or p-pl-code = ?
        then do:
          run ref/pl-gds-list.w
            ( input v-pl-list
            , output p-pl-code
            ) no-error .
          if p-pl-code = ?
          or p-pl-code = 0
          then do:
            message "Не выбрано место хранения " view-as alert-box .
            undo block_tr, return error .
          end.
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
            and buf_rvs-line.pl-code  = p-pl-code
            and buf_rvs-line.gds-code = buf_goods.gds-code
          no-error.
        if not available buf_rvs-line then do:
          message
            substitute( "Не найдена строка сверки по резервуару &1", p-pl-code ) skip
            view-as alert-box error .
          undo block_tr, return error .
        end.
        case p-action :
          when 'ИЗМЕНЕНИЕ':U then
          do:
            find buf_place no-lock
            where buf_place.obj-type = t-doc.obj-type
              and buf_place.obj-code = t-doc.obj-code
              and buf_place.pl-code  = p-pl-code
            .
            if p-action-type = "meas" or buf_place.is-meas <> yes then
            do:
              assign
                v-act-name = 'actn_rvs-on-doc_cr-revision':U
              .
            end.
            else
            do:
              run placelib_get-attr  ( input "place-rvd-dnsty"
                                        ,input buf_place.obj-code
                                        ,input buf_place.obj-type
                                        ,input buf_place.pl-code
                                        ,output v-value
                                        ,output v-ok      ) no-error.
              if not v-ok then pl-rvd-dens = no.
              else pl-rvd-dens = logical(v-value) .
              run placelib_get-attr  ( input "place-rvd-lvl"
                                        ,input buf_place.obj-code
                                        ,input buf_place.obj-type
                                        ,input buf_place.pl-code
                                        ,output v-value
                                        ,output v-ok      ) no-error.
              if not v-ok then pl-rvd-lvl = no.
              else pl-rvd-lvl = logical(v-value) .
              run placelib_get-attr  ( input "place-rvd-tmp"
                                        ,input buf_place.obj-code
                                        ,input buf_place.obj-type
                                        ,input buf_place.pl-code
                                        ,output v-value
                                        ,output v-ok      ) no-error.
              if not v-ok then pl-rvd-temp = no.
              else pl-rvd-temp = logical(v-value) .
              if buf_place.is-meas
              and not pl-rvd-dens
              and not pl-rvd-lvl
              and not pl-rvd-temp
              then do :
                assign
                  v-act-name = 'actn_rvs-on-doc_upd-revision':U
                .
              end .
              else do :
                assign
                  v-act-name = 'actn_rvs-control_upd-immeas':U
                .
              end .
            end.
            case p-rvs-type :
              when 'перед_док':U then do:
                run check-before in this-procedure
                  ( input t-doc.doc-code
                   ,input buf_goods.gds-code
                   ,input p-pl-code
                  ) no-error .
                if error-status :error then do:
                  undo block_tr, return error .
                end.
              end.
              when 'после_док':U then do:
                run check-after in this-procedure
                  ( input t-doc.doc-code
                   ,input buf_goods.gds-code
                   ,input p-pl-code
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
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
            if infoSectionsTotal:IsKP
            and p-action = 'ИЗМЕНЕНИЕ':U
            then do :
              message "По накладной установлен флаг комиссионного приема. Работа со сверками запрещена!" view-as alert-box .
            end .
            undo block_tr, return error .
          end.
        end.
        find first buf_rvs-line exclusive-lock
          where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            and buf_rvs-line.obj-type = t-doc.obj-type
            and buf_rvs-line.obj-code = t-doc.obj-code
            and buf_rvs-line.pl-code  = p-pl-code
            and buf_rvs-line.gds-code = buf_goods.gds-code
          .
        case p-action-type :
          when "meas":U then do:
            for each tt-meas
            :
              delete tt-meas .
            end.
            for each tt-pump-nozzle
            :
              delete tt-pump-nozzle .
            end.
            find buf_place no-lock
              where buf_place.obj-type = t-doc.obj-type
                and buf_place.obj-code = t-doc.obj-code
                and buf_place.pl-code  = p-pl-code
              .
            run placelib_get-attr  (
               input "place-com-tanks"
              ,input buf_rvs-doc.obj-code
              ,input buf_rvs-doc.obj-type
              ,input p-pl-code
              ,output v-value
              ,output v-ok      )
            no-error.
            if  v-ok
            and v-value > ""
            then do :
              v-com-vessel-rvs = yes .
              v-com-vessel-is-meas = no .
              v-value = v-value + "," + buf_place.loc1 .
              do ii = 1 to num-entries(v-value) :
                find first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
                                               and buf_place.obj-code = buf_rvs-doc.obj-code
                                               and buf_place.loc1     = entry(ii, v-value)
                                               and buf_place.status_  = ""
                                               no-error .
                if available buf_place
                then do :
                  if buf_place.is-meas
                  then do :
                    v-com-vessel-is-meas = yes .
                    create tt-meas .
                    assign
                      tt-meas.obj-type = buf_rvs-doc.obj-type
                      tt-meas.obj-code = buf_rvs-doc.obj-code
                      tt-meas.pl-code  = buf_place.pl-code
                      tt-meas.loc1     = buf_place.loc1
                    .
                    for each bf_pl-pump-nozzle no-lock where bf_pl-pump-nozzle.obj-type = buf_place.obj-type
                                                         and bf_pl-pump-nozzle.obj-code = buf_place.obj-code
                                                         and bf_pl-pump-nozzle.pl-code  = buf_place.pl-code,
                    first bf_pump-nozzle no-lock where bf_pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
                                                   and bf_pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
                                                   and bf_pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                                                   and bf_pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
                    :
                      create tt-pump-nozzle.
                      assign
                        tt-pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
                        tt-pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
                        tt-pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                        tt-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
                        tt-pump-nozzle.gds-code    = buf_goods.gds-code
                      .
                    end .
                  end .
                end .
              end .
              if not v-com-vessel-is-meas
              then do :
                message
                  substitute( 'Ни один из сообщающихся резервуаров не измеряется приборами.', buf_place.pl-code)
                  view-as alert-box error .
                undo block_tr, return error .
              end .
            end .
            else do :
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
              create tt-meas .
              assign
                tt-meas.obj-type = t-doc.obj-type
                tt-meas.obj-code = t-doc.obj-code
                tt-meas.pl-code  = p-pl-code
              .
              for each bf_pl-pump-nozzle no-lock where bf_pl-pump-nozzle.obj-type = tt-meas.obj-type
                                                   and bf_pl-pump-nozzle.obj-code = tt-meas.obj-code
                                                   and bf_pl-pump-nozzle.pl-code  = tt-meas.pl-code,
              first bf_pump-nozzle no-lock where bf_pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
                                             and bf_pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
                                             and bf_pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                                             and bf_pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
              :
                create tt-pump-nozzle.
                assign
                  tt-pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
                  tt-pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
                  tt-pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                  tt-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
                  tt-pump-nozzle.gds-code    = buf_goods.gds-code
                .
              end .
            end .
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
            if v-com-vessel-rvs
            then do :
              for each buf_rvs-line exclusive-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                                     and buf_rvs-line.obj-type = t-doc.obj-type
                                                     and buf_rvs-line.obj-code = t-doc.obj-code
                                                     and buf_rvs-line.gds-code = buf_goods.gds-code,
              first tt-meas where tt-meas.pl-code = buf_rvs-line.pl-code
              :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_fill1plc in g#lib-rvs ( input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              buf_rvs-line.pl-code ,
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
                find first rvs-line-attr exclusive-lock
                     where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                       and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                       and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                       and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                       and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                       and rvs-line-attr.attr-code = "input-type-p" no-error.
                if not available rvs-line-attr then do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    rvs-line-attr.attr-code = "input-type-p"
                  .
                end.
                if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
                else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
                find first rvs-line-attr exclusive-lock
                     where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                       and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                       and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                       and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                       and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                       and rvs-line-attr.attr-code = "input-type-t" no-error.
                if not available rvs-line-attr then do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    rvs-line-attr.attr-code = "input-type-t"
                  .
                end.
                if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
                else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
                find first rvs-line-attr exclusive-lock
                     where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                       and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                       and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                       and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                       and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                       and rvs-line-attr.attr-code = "input-type-l" no-error.
                if not available rvs-line-attr then do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    rvs-line-attr.attr-code = "input-type-l"
                  .
                end.
                if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
                else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
                release rvs-line-attr no-error .
                run cur-time in this-procedure
                  ( output v-today
                  , output v-time
                  ) .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-today
  )  .
                assign
                  buf_rvs-line.real-date = v-today
                  buf_rvs-line.real-time = v-time
                .
                if p-rvs-type = 'перед_док':U
                then do:
                  v-prt-start-real-date = buf_rvs-line.real-date .
                  v-prt-start-real-time = buf_rvs-line.real-time .
                end.
                else do:
                  v-prt-end-real-date = buf_rvs-line.real-date .
                  v-prt-end-real-time = buf_rvs-line.real-time .
                end.
                find first tt-pump-nozzle no-error .
                if available tt-pump-nozzle
                then do :
                  if varcur-rvs = 1
                  or ptoldfilvalue <> "yes":u
                  then do :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_anls-pmp in g#lib-rvs ( input              parParentProc ,
                      input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              yes ,
                      input-output table tt-pump-nozzle-file ,
                      input-output table tt-pump-nozzle ,
                      input              yes ,
                      input              ? ,
                      input              no) no-error .
                  end.
                  else do :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_anls-pmp in g#lib-rvs ( input              parParentProc ,
                      input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              yes ,
                      input-output table tt-pump-nozzle-file ,
                      input-output table tt-pump-nozzle ,
                      input              no ,
                      input              ? ,
                      input              no) no-error .
                  end.
                end .
                for each tt-pump-nozzle :
                  find first tt-pump-nozzle-file where
                             tt-pump-nozzle-file.obj-type    = tt-pump-nozzle.obj-type    and
                             tt-pump-nozzle-file.obj-code    = tt-pump-nozzle.obj-code    and
                             tt-pump-nozzle-file.pump-code   = tt-pump-nozzle.pump-code   and
                             tt-pump-nozzle-file.nozzle-code = tt-pump-nozzle.nozzle-code no-error .
                  if available tt-pump-nozzle-file
                  then
                  assign
                    tt-pump-nozzle.meas-el-cnt = tt-pump-nozzle-file.meas-el-cnt
                    tt-pump-nozzle.meas-am-cnt = tt-pump-nozzle-file.meas-am-cnt
                    tt-pump-nozzle.meas-cf-cnt = tt-pump-nozzle-file.meas-cf-cnt
                  .
                end.
                for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                     and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                     and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                     and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                     and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
                :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_fill1pmp in g#lib-rvs ( input       recid( buf_rvs-line-pump ) ,
                      input table tt-pump-nozzle )  .
                end .
                for each buf_rvs-line-pump exclusive-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                            and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                            and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                            and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                            and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
                :
                  assign
                    buf_rvs-line-pump.state-el-cnt    = 0 when buf_rvs-line-pump.state-el-cnt = ?
                    buf_rvs-line-pump.state-mh-cnt    = 0 when buf_rvs-line-pump.state-mh-cnt = ?
                  .
                end .
              end .
            end .
            else do :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_fill1plc in g#lib-rvs ( input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              p-pl-code ,
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
              find first rvs-line-attr exclusive-lock
                   where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                     and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                     and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                     and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                     and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                     and rvs-line-attr.attr-code = "input-type-p" no-error.
              if not available rvs-line-attr then do :
                create rvs-line-attr.
                assign
                  rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                  rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                  rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                  rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                  rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                  rvs-line-attr.attr-code = "input-type-p"
                .
              end.
              if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
              else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
              find first rvs-line-attr exclusive-lock
                   where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                     and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                     and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                     and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                     and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                     and rvs-line-attr.attr-code = "input-type-t" no-error.
              if not available rvs-line-attr then do :
                create rvs-line-attr.
                assign
                  rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                  rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                  rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                  rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                  rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                  rvs-line-attr.attr-code = "input-type-t"
                .
              end.
              if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
              else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
              find first rvs-line-attr exclusive-lock
                   where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                     and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                     and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                     and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                     and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                     and rvs-line-attr.attr-code = "input-type-l" no-error.
              if not available rvs-line-attr then do :
                create rvs-line-attr.
                assign
                  rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                  rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                  rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                  rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                  rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                  rvs-line-attr.attr-code = "input-type-l"
                .
              end.
              if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
              else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
              release rvs-line-attr no-error .
              run cur-time in this-procedure
                ( output v-today
                , output v-time
                ) .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-today
  )  .
              assign
                buf_rvs-line.real-date = v-today
                buf_rvs-line.real-time = v-time
              .
              find first tt-pump-nozzle no-error .
              if available tt-pump-nozzle
              then do :
                if varcur-rvs = 1
                or ptoldfilvalue <> "yes":u
                then do :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_anls-pmp in g#lib-rvs ( input              parParentProc ,
                      input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              yes ,
                      input-output table tt-pump-nozzle-file ,
                      input-output table tt-pump-nozzle ,
                      input              yes ,
                      input              ? ,
                      input              no) no-error .
                end.
                else do :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_anls-pmp in g#lib-rvs ( input              parParentProc ,
                      input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              yes ,
                      input-output table tt-pump-nozzle-file ,
                      input-output table tt-pump-nozzle ,
                      input              no ,
                      input              ? ,
                      input              no) no-error .
                end.
              end .
              for each tt-pump-nozzle :
                find first tt-pump-nozzle-file where
                           tt-pump-nozzle-file.obj-type    = tt-pump-nozzle.obj-type    and
                           tt-pump-nozzle-file.obj-code    = tt-pump-nozzle.obj-code    and
                           tt-pump-nozzle-file.pump-code   = tt-pump-nozzle.pump-code   and
                           tt-pump-nozzle-file.nozzle-code = tt-pump-nozzle.nozzle-code no-error .
                if available tt-pump-nozzle-file
                then
                assign
                  tt-pump-nozzle.meas-el-cnt = tt-pump-nozzle-file.meas-el-cnt
                  tt-pump-nozzle.meas-am-cnt = tt-pump-nozzle-file.meas-am-cnt
                  tt-pump-nozzle.meas-cf-cnt = tt-pump-nozzle-file.meas-cf-cnt
                .
              end.
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_fill1pmp in g#lib-rvs ( input       recid( buf_rvs-line-pump ) ,
                      input table tt-pump-nozzle )  .
              end .
              for each buf_rvs-line-pump exclusive-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                          and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                          and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                          and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                          and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                assign
                  buf_rvs-line-pump.state-el-cnt    = 0 when buf_rvs-line-pump.state-el-cnt = ?
                  buf_rvs-line-pump.state-mh-cnt    = 0 when buf_rvs-line-pump.state-mh-cnt = ?
                .
              end .
            end .
            if not available buf_rvs-line
            then do :
              find first buf_rvs-line exclusive-lock
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = t-doc.obj-type
                and buf_rvs-line.obj-code = t-doc.obj-code
                and buf_rvs-line.pl-code  = p-pl-code
                and buf_rvs-line.gds-code = buf_goods.gds-code
              .
            end .
            infoSectionsTotal:CalculateTotal().
            if p-rvs-type = 'перед_док':U  then do:
              v-prt-start-real-date = buf_rvs-line.real-date .
              v-prt-start-real-time = buf_rvs-line.real-time .
            end.
            else do:
              v-prt-end-real-date = buf_rvs-line.real-date .
              v-prt-end-real-time = buf_rvs-line.real-time .
            end.
          end.
          when "edit":U then do:
            if not available buf_rvs-line
            then do :
              find first buf_rvs-line exclusive-lock
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = t-doc.obj-type
                and buf_rvs-line.obj-code = t-doc.obj-code
                and buf_rvs-line.pl-code  = p-pl-code
                and buf_rvs-line.gds-code = buf_goods.gds-code
              .
            end .
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
                                    ,p-pl-code)) no-error.
            end.
            else do:
              if available buf_goods
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
                                      ,p-pl-code)) no-error.
              end.
              else do :
                run str/rvs-lin.w
                  (input  parparentproc
                  ,input  recid( buf_rvs-line )
                  ,input  p-action
                  ,input  substitute(" # &1 товар &2 &3 &4  складское место &5"
                                    ,buf_rvs-doc.rvs-code
                                    ,buf_goods.artic
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,p-pl-code)) no-error.
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
              if p-action <> 'ПРОСМОТР':U
              then do :
                run cur-time in this-procedure
                  ( output v-today
                  , output v-time
                  ) .
                assign
                  buf_rvs-line.real-date = v-today
                  buf_rvs-line.real-time = v-time
                .
                infoSectionsTotal:CalculateTotal().
                if p-rvs-type = 'перед_док':U  then do:
                  v-prt-start-real-date = buf_rvs-line.real-date .
                  v-prt-start-real-time = buf_rvs-line.real-time .
                end.
                else do:
                  v-prt-end-real-date = buf_rvs-line.real-date .
                  v-prt-end-real-time = buf_rvs-line.real-time .
                end.
                for each tt-pump-nozzle
                :
                  delete tt-pump-nozzle .
                end.
                for each bf_pl-pump-nozzle no-lock where bf_pl-pump-nozzle.obj-type = buf_rvs-line.obj-type
                                                     and bf_pl-pump-nozzle.obj-code = buf_rvs-line.obj-code
                                                     and bf_pl-pump-nozzle.pl-code  = buf_rvs-line.pl-code,
                first bf_pump-nozzle no-lock where bf_pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
                                               and bf_pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
                                               and bf_pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                                               and bf_pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
                :
                  create tt-pump-nozzle.
                  assign
                    tt-pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
                    tt-pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
                    tt-pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                    tt-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
                    tt-pump-nozzle.gds-code    = buf_goods.gds-code
                  .
                end .
                find first tt-pump-nozzle no-error .
                if not available tt-pump-nozzle
                then do :
                  assign
                    varcur-rvs = 3
                    error-status:error = no
                  .
                end .
                else do :
                  if ptoldfilvalue = "yes":U then do:
                    run gbl/d-askw.w
                      ( input "Выбор источника данных с информацией по ТРК"
                      ,input "Будем читать текущие данные с ТРК или возьмем данные из файла?"
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
                        assign
                          varcur-rvs = 3
                        .
                      end.
                    end case.
                  end.
                  else do:
                    assign
                      varcur-rvs = 1
                    .
                  end.
                end .
                if varcur-rvs <> 3
                then do :
                  if varcur-rvs = 1
                  or ptoldfilvalue <> "yes":u
                  then do :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_anls-pmp in g#lib-rvs ( input              parParentProc ,
                      input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              yes ,
                      input-output table tt-pump-nozzle-file ,
                      input-output table tt-pump-nozzle ,
                      input              yes ,
                      input              ? ,
                      input              no) no-error .
                  end.
                  else do :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_anls-pmp in g#lib-rvs ( input              parParentProc ,
                      input              t-doc.obj-type ,
                      input              t-doc.obj-code ,
                      input              yes ,
                      input-output table tt-pump-nozzle-file ,
                      input-output table tt-pump-nozzle ,
                      input              no ,
                      input              ? ,
                      input              no) no-error .
                  end.
                  for each tt-pump-nozzle :
                    find first tt-pump-nozzle-file where
                               tt-pump-nozzle-file.obj-type    = tt-pump-nozzle.obj-type    and
                               tt-pump-nozzle-file.obj-code    = tt-pump-nozzle.obj-code    and
                               tt-pump-nozzle-file.pump-code   = tt-pump-nozzle.pump-code   and
                               tt-pump-nozzle-file.nozzle-code = tt-pump-nozzle.nozzle-code no-error .
                    if available tt-pump-nozzle-file
                    then
                    assign
                      tt-pump-nozzle.meas-el-cnt = tt-pump-nozzle-file.meas-el-cnt
                      tt-pump-nozzle.meas-am-cnt = tt-pump-nozzle-file.meas-am-cnt
                      tt-pump-nozzle.meas-cf-cnt = tt-pump-nozzle-file.meas-cf-cnt
                    .
                  end.
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                       and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
                  :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_fill1pmp in g#lib-rvs ( input       recid( buf_rvs-line-pump ) ,
                      input table tt-pump-nozzle )  .
                  end .
                end .
                for each buf_rvs-line-pump exclusive-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                            and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                            and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                            and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                            and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
                :
                  assign
                    buf_rvs-line-pump.state-el-cnt    = 0 when buf_rvs-line-pump.state-el-cnt = ?
                    buf_rvs-line-pump.state-mh-cnt    = 0 when buf_rvs-line-pump.state-mh-cnt = ?
                  .
                end .
              end .
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
        if not p-action = 'ПРОСМОТР':U
        then do :
          find first buf_place no-lock
              where buf_place.obj-type = t-doc.obj-type
                and buf_place.obj-code = t-doc.obj-code
                and buf_place.pl-code  = p-pl-code
            .
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp(ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> buf_place.loc1 then next .
            if p-rvs-type = 'перед_док':U
            then do:
              infoSectionsTotal:InfoSectionCurr:DateStart = v-prt-start-real-date .
              infoSectionsTotal:InfoSectionCurr:TimeStart = v-prt-start-real-time .
            end .
            else do :
              infoSectionsTotal:InfoSectionCurr:DateEnd   = v-prt-end-real-date .
              infoSectionsTotal:InfoSectionCurr:TimeEnd   = v-prt-end-real-time .
            end .
            infoSectionsTotal:InfoSectionCurr:TankWeightRvs = ? .
            infoSectionsTotal:InfoSectionCurr:TankVolPomiRvs = ? .
            infoSectionsTotal:InfoSectionCurr:AvgTempRvs = ? .
          end.
        infoSectionsTotal:SaveDB().
        end .
        run placelib_get-attr(input "place-virtual"
                             ,input t-doc.obj-code
                             ,input t-doc.obj-type
                             ,input p-pl-code
                             ,output v-value
                             ,output v-ok) no-error.
        is-vir = if (v-ok and logical(v-value)) then true else false.
        if not is-gas(buf_goods.gds-code)
        and not is-vir then do:
            if not available buf_rvs-line
            then do :
              find first buf_rvs-line exclusive-lock
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = t-doc.obj-type
                and buf_rvs-line.obj-code = t-doc.obj-code
                and buf_rvs-line.pl-code  = p-pl-code
                and buf_rvs-line.gds-code = buf_goods.gds-code
              .
            end .
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
                 ,input p-pl-code
                 ,output v-rvs-qnty-before
                 ,output v-rvs-qnty-after
                 ,output v-rvs-cli-qnty-before
                 ,output v-rvs-cli-qnty-after
                 ,output v-delta-mass-qnty
                 ,output v-trk-err
                ) no-error .
              if error-status :error then do:
                undo block_tr, return error return-value .
              end.
              run placelib_get-attr  (
                 input "place-com-tanks"
                ,input t-doc.obj-code
                ,input t-doc.obj-type
                ,input p-pl-code
                ,output v-value
                ,output v-ok      )
              no-error.
              if v-ok
              and v-value > ""
              then do :
                do ii = 1 to num-entries(v-value) :
                  find first buf_place no-lock where buf_place.obj-type = t-doc.obj-type
                                                 and buf_place.obj-code = t-doc.obj-code
                                                 and buf_place.loc1     = entry(ii, v-value)
                                                 and buf_place.status_  = ""
                                                 no-error .
                  if available buf_place
                  then do :
                    run return-rvs-qnty in this-procedure
                      ( input t-doc.doc-code
                       ,input buf_goods.gds-code
                       ,input buf_place.pl-code
                       ,output v-com-tank-rvs-qnty-before
                       ,output v-com-tank-rvs-qnty-after
                       ,output v-com-tank-rvs-cli-qnty-before
                       ,output v-com-tank-rvs-cli-qnty-after
                       ,output v-com-tank-delta-mass-qnty
                       ,output v-trk-err
                      ) no-error .
                    if error-status :error then do:
                      undo block_tr, return error return-value .
                    end.
                    if v-com-tank-rvs-qnty-after = ?
                    then do :
                      assign
                        v-com-tank-rvs-qnty-after = 0
                        v-com-tank-rvs-cli-qnty-after = 0
                        v-com-tanks-not-filled = yes
                      .
                    end .
                    assign
                      v-rvs-qnty-before     = v-rvs-qnty-before     + v-com-tank-rvs-qnty-before
                      v-rvs-qnty-after      = v-rvs-qnty-after      + v-com-tank-rvs-qnty-after
                      v-rvs-cli-qnty-before = v-rvs-cli-qnty-before + v-com-tank-rvs-cli-qnty-before
                      v-rvs-cli-qnty-after  = v-rvs-cli-qnty-after  + v-com-tank-rvs-cli-qnty-after
                    .
                  end.
                end .
              end .
              if p-rvs-type = 'после_док':U then do:
                if v-rvs-qnty-after = ?
                  or v-rvs-qnty-after = 0
                then do:
                  message
                    "Не задано количество по сверке <<после_док>>"
                    "по резервуару" p-pl-code "."
                    view-as alert-box error .
                  undo block_tr, return error .
                end.
                if v-rvs-cli-qnty-after = ?
                  or v-rvs-cli-qnty-after = 0
                then do:
                  if is-sug(buf_goods.gds-code)
                  then do :
                    message
                      "Не задана масса в сверке <<после_док>>"
                      "по резервуару" p-pl-code "."
                      view-as alert-box error .
                  end.
                  else do :
                    message
                      "Масса не рассчитана. Не задана плотность в сверке <<после_док>>"
                      "по резервуару" p-pl-code "."
                      view-as alert-box error .
                  end.
                  undo block_tr, return error .
                end.
              end.
              if v-rvs-qnty-after <> ?
              and v-rvs-qnty-after <> 0
              and not v-com-tanks-not-filled
              then do:
                if v-rvs-qnty-after - v-rvs-qnty-before <= 0
                  or v-rvs-qnty-after - v-rvs-qnty-before = ?
                then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", p-pl-code ) skip
                    substitute( "Количество залитого топлива: &1 (&2).", v-rvs-qnty-after - v-rvs-qnty-before, buf_goods.unit-base ) skip
                    substitute( "Объем в сверке до: &1 ", v-rvs-qnty-before ) skip
                    substitute( "Объем в сверке после: &1 ", v-rvs-qnty-after ) skip
                    view-as alert-box .
                  undo block_tr, return error .
                end.
                if v-rvs-cli-qnty-after - v-rvs-cli-qnty-before <= 0
                  or v-rvs-cli-qnty-after - v-rvs-cli-qnty-before = ?
                then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", p-pl-code ) skip
                    substitute( "Количество залитого топлива: &1 (&2).", v-rvs-cli-qnty-after - v-rvs-cli-qnty-before, buf_goods.unit-cli ) skip
                    substitute( "Масса в сверке до: &1 ", v-rvs-cli-qnty-before ) skip
                    substitute( "Масса в сверке после: &1 ", v-rvs-cli-qnty-after ) skip
                    view-as alert-box .
                  undo block_tr, return error .
                end.
                if not is-sug(buf_goods.gds-code)
                then do :
                  assign
                    v-rvs-density = (v-rvs-cli-qnty-after - v-rvs-cli-qnty-before) / (v-rvs-qnty-after - v-rvs-qnty-before)
                  .
                  if Valid-Density( v-rvs-density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true then do:
                    message
                      substitute( "Ошибка по результатам сверки." ) skip
                      substitute( "Место хранения: &1 .", p-pl-code ) skip
                      substitute( "Плотность залитого топлива: &1.", v-rvs-density ) skip
                      view-as alert-box .
                    undo block_tr, return error .
                  end.
                end.
                if is-sug(buf_goods.gds-code) then
                do:
                  def var dmdop as decimal no-undo.
                  def var dM    as decimal no-undo.
                  define variable v-value-character as character no-undo .
                  define variable v-value-date as date no-undo .
                  define variable v-value-integer as integer no-undo .
                  define variable v-value-logical as logical no-undo .
                  define variable v-param-type as character no-undo .
                  define variable v-tth as handle no-undo .
                  def var v-cardifLgas as decimal no-undo.
                  def var infoSectionObj as class infosection no-undo.
                  find first buf_doc-line no-lock where buf_doc-line.doc-code = t-doc.doc-code
                      and buf_goods.artic = buf_doc-line.artic
                      and buf_goods.prod-type = buf_doc-line.prod-type
                      and buf_goods.prod-code = buf_doc-line.prod-code no-error.
                  run adm/shattri.p (
                      input "get":U
                      ,input  buf_doc-line.obj-type
                      ,input  buf_doc-line.obj-code
                      ,input  'petrol':U
                      ,input  'CriticalDifInLgas':U
                      ,output v-value-character
                      ,output v-value-date
                      ,output v-cardifLgas
                      ,output v-value-integer
                      ,output v-value-logical
                      ,output v-param-type
                      ,INPUT-OUTPUT table-handle v-tth
                  ) no-error .
                  if v-cardifLgas = ?
                    then v-cardifLgas = 0.
                  dM = buf_doc-line.cli-qnty - (v-rvs-cli-qnty-after - v-rvs-cli-qnty-before).
                  dmdop = SQRT ((v-rvs-cli-qnty-after *  v-cardifLgas) * (v-rvs-cli-qnty-after *  v-cardifLgas) + (v-rvs-cli-qnty-before *  v-cardifLgas) * (v-rvs-cli-qnty-before *  v-cardifLgas)) / 100.
                  if absolute (dM) <= dmdop
                  then do:
                    infoSectionObj = infoSectionsTotal:GetInfoSectionProp(1).
                    infoSectionObj:AccPOMI = dmdop.
                    infoSectionObj:FactKgQnty = buf_doc-line.doc-qnty * buf_doc-line.doc-density.
                    infoSectionObj:FactQnty = (v-rvs-qnty-after - v-rvs-qnty-before).
                    infoSectionObj:FactDensity = infoSectionObj:FactKgQnty / infoSectionObj:FactQnty.
                    infoSectionsTotal:SaveDB().
                    run correct-fact-qnty in this-procedure
                      ( input buf_doc-line.doc-qnty
                       ,input buf_doc-line.doc-density
                      ) no-error .
                  end.
                  else do:
                    infoSectionObj = infoSectionsTotal:GetInfoSectionProp(1).
                    infoSectionObj:FactKgQnty = (v-rvs-cli-qnty-after - v-rvs-cli-qnty-before).
                    infoSectionObj:FactQnty = (v-rvs-qnty-after - v-rvs-qnty-before).
                    infoSectionObj:FactDensity = infoSectionObj:FactKgQnty / infoSectionObj:FactQnty.
                    infoSectionsTotal:SaveDB().
                    run correct-fact-qnty in this-procedure
                      ( input infoSectionObj:FactQnty
                       ,input infoSectionObj:FactDensity
                      ) no-error.
                    message
                      substitute( "По результатам слива Газовоза фактическое кол-во товара изменяется на &1 (&2),", infoSectionObj:FactQnty, buf_goods.unit-base ) skip
                      substitute( "фактическая плотность на &1.", infoSectionObj:FactDensity ) skip
                      view-as alert-box information
                    .
                    run save-action in this-procedure
                      ( input "hard":U
                      ) no-error .
                    if error-status :error then do:
                      message return-value view-as alert-box error .
                      undo block_tr, return error .
                    end.
                  end.
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
      define input-output parameter p-infoSectionsTotal    as class InfoSectionsTotal    no-undo .
      define input-output parameter p-prt-start-real-date  like ub.rvs-line.real-date    no-undo .
      define input-output parameter p-prt-start-real-time  like ub.rvs-line.real-time    no-undo .
      define input-output parameter p-prt-end-real-date    like ub.rvs-line.real-date    no-undo .
      define input-output parameter p-prt-end-real-time    like ub.rvs-line.real-time    no-undo .
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
        define variable v-need-message      as   logical                  no-undo init yes .
        block_tr:
        do transaction
        on error  undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        on stop   undo block_tr, return error substitute( "&1. stop", vss-workfile )
        on endkey undo block_tr, return error substitute( "&1. endkey", vss-workfile )
        :
          find first buf_goods no-lock
            where buf_goods.gds-code = p-gds-code
            .
          p-infoSectionsTotal:CalculateTotal().
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
          tanksForm = new ibs.th.str.ptrl.forms.tanksections(infoSectionsTotal).
          wait-for tanksForm:ShowDialog().
          def var ii as int no-undo.
          def var infoSectionObj as class InfoSection no-undo.
          if p-infoSectionsTotal:RdcDnstvalue = 'not'
          then do:
            do ii = 1 to p-infoSectionsTotal:SectionNum :
              infoSectionObj = p-infoSectionsTotal:GetInfoSectionProp(ii).
              if p-mode ne 'ПРОСМОТР':U
              then do:
                 infoSectionObj:FactQnty = infoSectionObj:TankVol.
                 infoSectionObj:FactDensity = infoSectionObj:TankDensity.
                 p-infoSectionsTotal:SaveDb().
              end.
              p-infoSectionsTotal:GetDBAllAttr().
              p-infoSectionsTotal:CalculateTotal().
            end.
          end.
          if p-infoSectionsTotal:WasSetting = false then p-infoSectionsTotal:GetDBAllAttr().
            if p-infoSectionsTotal:WasSetting = true
              and p-mode <> 'ПРОСМОТР':U
              and p-stfactplvalue <> "":U
              and (p-auto-tank = true or p-infoSectionsTotal:IsRNAlgo)
              then
            do:
              assign
                v-new-fact-qnty = p-new-fact-qnty
                .
            do ii = 1 to p-infoSectionsTotal:SectionNum :
              define variable v-calc-density like ub.rvs-line.state-density no-undo .
              define variable v-new-sec-fact-qnty         as decimal no-undo.
              define variable v-new-sec-fact-qnty-kg      as decimal no-undo.
              define variable v-chg-temp                  as logical no-undo.
              define variable v-st-doc-temp               as logical no-undo.
              define variable v-rvs-sec-qnty-before       as decimal no-undo.
              define variable v-rvs-sec-qnty-after        as decimal no-undo.
              define variable v-rvs-sec-cli-qnty-before   as decimal no-undo.
              define variable v-rvs-sec-cli-qnty-after    as decimal no-undo.
              infoSectionObj = p-infoSectionsTotal:GetInfoSectionProp(ii).
              v-new-sec-fact-qnty = if infoSectionObj:FactQnty = 0 or infoSectionObj:FactQnty = ? then infoSectionObj:DocQnty else infoSectionObj:FactQnty.
              v-calc-density = ? .
              if infoSectionObj:TankWeight > 0
              and infoSectionObj:TankVol > 0
              then
                v-calc-density = infoSectionObj:TankWeight / infoSectionObj:TankVol
              .
              if infoSectionObj:AccMeth = 1
              and infoSectionObj:TankWeightRvs > 0
              and infoSectionObj:TankVolPomiRvs > 0
              then
                v-calc-density = infoSectionObj:TankWeightRvs / infoSectionObj:TankVolPomiRvs
              .
              if not p-infoSectionsTotal:IsSGDKK
              then do :
                if p-infoSectionsTotal:IsRNAlgo
                then do:
                  assign
                    v-calc-density = infoSectionObj:TankDensityPomi when not p-infoSectionsTotal:RdcDnstvalue = 'not'
                    v-calc-density = infoSectionObj:TankDensity when p-infoSectionsTotal:RdcDnstvalue = 'not'
                  .
                  if infoSectionObj:AccMeth = 1
                  then do :
                    assign v-calc-density = infoSectionObj:TankWeightRvs / infoSectionObj:TankVolPomiRvs .
                  end .
                  if (v-calc-density = ? or v-calc-density <= 0 or v-calc-density > 1)
                  and infoSectionObj:KPnoMeas
                  then do :
                    assign v-need-message = no .
                  end .
                  p-infoSectionsTotal:RNAlgo (integer(infoSectionObj:SectionName), output v-new-sec-fact-qnty-kg).
                  if v-new-sec-fact-qnty-kg <> infoSectionObj:DocQnty * infoSectionObj:DocDensity
                  then do:
                    v-new-sec-fact-qnty = v-new-sec-fact-qnty-kg / v-calc-density.
                    v-chg-temp = true.
                    v-st-doc-temp = false.
                  end.
                  else do:
                    v-st-doc-temp = true.
                    v-chg-temp = false.
                  end.
                end.
                else do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_stfactqt in g#lib-calc
  ( input        p-stfactplvalue
  , input        infoSectionObj:DocQnty
  , input        infoSectionObj:DocDensity
  , input        0.00
  , input        0.00
  , input        infoSectionObj:TankVol
  , input        v-calc-density
  , input        no
  , input-output v-new-sec-fact-qnty
  ,       output v-chg-temp
  ,       output v-st-doc-temp
  )              no-error
.
                  if error-status :error then do:
                    undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
                  end.
                end.
              end .
              else do :
                if infoSectionObj:IsKP
                then do :
                  if p-infoSectionsTotal:IsRNAlgo
                  then do:
                    assign
                      v-calc-density = infoSectionObj:TankDensityPomi when not p-infoSectionsTotal:RdcDnstvalue = 'not'
                      v-calc-density = infoSectionObj:TankDensity when p-infoSectionsTotal:RdcDnstvalue = 'not'
                    .
                    if infoSectionObj:AccMeth = 1
                    then do :
                      assign v-calc-density = infoSectionObj:TankWeightRvs / infoSectionObj:TankVolPomiRvs .
                    end .
                    if (v-calc-density = ? or v-calc-density <= 0 or v-calc-density > 1)
                    and infoSectionObj:Alarm-SGDKK
                    then do :
                      assign v-need-message = no .
                    end .
                    p-infoSectionsTotal:RNAlgo (integer(infoSectionObj:SectionName), output v-new-sec-fact-qnty-kg).
                    if v-new-sec-fact-qnty-kg <> infoSectionObj:DocQnty * infoSectionObj:DocDensity
                    then do:
                      v-new-sec-fact-qnty = v-new-sec-fact-qnty-kg / v-calc-density.
                      v-chg-temp = true.
                      v-st-doc-temp = false.
                    end.
                    else do:
                      v-st-doc-temp = true.
                      v-chg-temp = false.
                    end.
                  end.
                  else do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_stfactqt in g#lib-calc
  ( input        p-stfactplvalue
  , input        infoSectionObj:DocQnty
  , input        infoSectionObj:DocDensity
  , input        0.00
  , input        0.00
  , input        infoSectionObj:TankVol
  , input        v-calc-density
  , input        no
  , input-output v-new-sec-fact-qnty
  ,       output v-chg-temp
  ,       output v-st-doc-temp
  )              no-error
.
                    if error-status :error then do:
                      undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
                    end.
                  end.
                end .
                else do :
                  p-infoSectionsTotal:CalcTP() .
                  v-st-doc-temp = true.
                  v-chg-temp = false.
                end .
              end .
              if v-chg-temp
              then do:
                infoSectionObj:FactQnty = v-new-sec-fact-qnty.
                v-chg = v-chg-temp.
                if v-st-doc-temp
                then do:
                  infoSectionObj:FactDensity = infoSectionObj:DocDensity.
                  v-st-doc = v-st-doc-temp.
                end.
                else do:
                  infoSectionObj:FactDensity = v-calc-density.
                end.
              end.
              else do:
                infoSectionObj:FactQnty = infoSectionObj:DocQnty.
                infoSectionObj:FactDensity = infoSectionObj:DocDensity.
              end.
            end.
            if p-mode ne 'ПРОСМОТР':U
            then
               p-infoSectionsTotal:SaveDb().
            p-infoSectionsTotal:GetDBAllAttr().
            p-infoSectionsTotal:CalculateTotal().
            v-calc-density = p-infoSectionsTotal:FactKgQntyTotal / p-infoSectionsTotal:FactQntyTotal.
            v-new-fact-qnty = p-infoSectionsTotal:FactQntyTotal.
            if p-new-fact-qnty <> v-new-fact-qnty
            and absolute(p-new-fact-qnty - v-new-fact-qnty) < 0.0011
            then do :
              p-infoSectionsTotal:FactQntyTotal = p-new-fact-qnty .
              v-new-fact-qnty = p-infoSectionsTotal:FactQntyTotal .
              v-calc-density = p-new-density .
              p-infoSectionsTotal:FactKgQntyTotal = p-infoSectionsTotal:FactQntyTotal * v-calc-density .
            end .
            if (absolute (v-calc-density - p-new-density ) > 0.0000000001
              or absolute (p-infoSectionsTotal:FactQntyTotal - p-new-fact-qnty ) > 0.001)
              or ((v-calc-density = ? and p-new-density <> ?) or (p-infoSectionsTotal:FactQntyTotal = ? and p-new-fact-qnty <> ?))
            then do:
              v-chg =  yes.
            end.
            if v-calc-density = ?
            and not infoSectionsTotal:isFlagKPChg
            then do:
              return.
            end.
            if (p-new-fact-qnty <> v-new-fact-qnty
              or v-chg       =  yes
              or v-st-doc    =  yes) and not infoSectionsTotal:isFlagKPChg
            then do:
              assign
                v-new-density = v-calc-density
                v-log         = yes
              .
              if v-new-fact-qnty <> p-new-fact-qnty
                or v-new-density <> p-new-density
              then do:
                if p-fact-edit = true then do:
                  if infoSectionsTotal:isKPrvs
                  then do :
                    message
                      substitute( "По результатам измерения в резервуаре фактическое кол-во необходимо изменить." ) skip
                      substitute( "Будем менять фактические" ) skip
                      substitute( "количество на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
                      substitute( "плотность на &1 ?", v-new-density ) skip
                    view-as alert-box question buttons yes-no update v-log .
                  end .
                  else do :
                    message
                      substitute( "По результатам измерения автоцистерны фактическое кол-во необходимо изменить." ) skip
                      substitute( "Будем менять фактические" ) skip
                      substitute( "количество на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
                      substitute( "плотность на &1 ?", v-new-density ) skip
                    view-as alert-box question buttons yes-no update v-log .
                  end .
                end.
                else do:
                  if infoSectionsTotal:isKPrvs
                  then do :
                    message
                      substitute( "По результатам измерения в резервуаре фактическое кол-во товара изменяется на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
                      substitute( "фактическая плотность на &1.", v-new-density ) skip
                    view-as alert-box information .
                  end .
                  else do :
                    message
                      substitute( "По результатам измерения автоцистерны фактическое кол-во товара изменяется на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
                      substitute( "фактическая плотность на &1.", v-new-density ) skip
                    view-as alert-box information .
                  end .
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
        define variable v-found as logical no-undo .
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
            assign v-found = no .
            for each buf-before_rvs-doc no-lock
              where buf-before_rvs-doc.rvs-type = 'перед_док':U
                and buf-before_rvs-doc.out-code = p-doc-code
            :
              find first buf-before_rvs-line no-lock
                where buf-before_rvs-line.rvs-code = buf-before_rvs-doc.rvs-code
                  and buf-before_rvs-line.obj-type = buf-before_rvs-doc.obj-type
                  and buf-before_rvs-line.obj-code = buf-before_rvs-doc.obj-code
                  and buf-before_rvs-line.pl-code  = tt-doc-pl.pl-code
                  and buf-before_rvs-line.gds-code = tt-doc-pl.gds-code
                no-error .
              if available buf-before_rvs-line
              then do :
                assign v-found = yes .
                leave .
              end .
            end .
            if not v-found
            then
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
            assign v-found = no .
            for each buf-after_rvs-doc no-lock
              where buf-after_rvs-doc.rvs-type = 'после_док':U
                and buf-after_rvs-doc.out-code = p-doc-code
            :
              find first buf-after_rvs-line no-lock
                where buf-after_rvs-line.rvs-code = buf-after_rvs-doc.rvs-code
                  and buf-after_rvs-line.obj-type = buf-after_rvs-doc.obj-type
                  and buf-after_rvs-line.obj-code = buf-after_rvs-doc.obj-code
                  and buf-after_rvs-line.pl-code  = tt-doc-pl.pl-code
                  and buf-after_rvs-line.gds-code = tt-doc-pl.gds-code
                no-error .
              if available buf-after_rvs-line
              then do :
                assign v-found = yes .
                leave .
              end .
            end .
            if not v-found
            then
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
        define variable v-delta-mass-qnty as decimal   no-undo .
        define variable v-trk-err         as logical   no-undo .
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
              ,output v-delta-mass-qnty
              ,output v-trk-err
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
                  substitute( "По результатам измерения в резервуаре фактическое кол-во необходимо изменить." ) skip
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
        define buffer buf-after_rvs-doc   for ub.rvs-doc  .
        define buffer buf_place           for ub.place .
        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-count-pl      as integer   no-undo .
        define variable v-message       as character no-undo .
        define variable v-tot-qnty-pl   as decimal   no-undo .
        define variable v-tot-qnty-rvs  as decimal   no-undo .
        define variable v-tot-cli-qnty-rvs  as decimal   no-undo .
        define variable v-add-option-bt as character no-undo .
        define variable v-add-option-ps as character no-undo .
        define variable v-answ-num      as integer   no-undo .
        define variable v-edit-doc-pl   as integer   no-undo .
        define variable v-set-doc-pl    as integer   no-undo .
        define variable v-delta-mass-qnty as decimal no-undo.
        define variable rdc-dnstvalue   as character no-undo.
        define variable rdc-dnsttype    as character no-undo.
        define variable v-attr-type     as character no-undo .
        define variable v-attr-value    as character no-undo .
        define variable v-place-trk-err as character no-undo .
        define variable v-trk-err       as logical no-undo .
        define variable ii              as integer no-undo .
        define buffer buf_goods for ub.goods .
        run gds-attr-value in this-procedure
          (  input p-gds-code
            ,input 'fuel-type':U
            ,output v-attr-value
            ,output v-attr-type
           ) .
        if v-attr-value = "lgas"
        then do:
          p-ok = true.
          return.
        end.
        find first buf_goods no-lock
          where buf_goods.gds-code = p-gds-code
          .
        assign
          p-ok           = true
          v-message      = "":U
          v-count-pl     = 0
          v-tot-qnty-rvs = 0.0
          v-tot-qnty-pl  = 0.0
          v-tot-cli-qnty-rvs = 0.0
        .
        for each tt-doc-pl no-lock
        on error undo, return error return-value
        :
          v-place-trk-err = "" .
          run return-rvs-qnty in this-procedure
            ( input  p-doc-code
             ,input  p-gds-code
             ,input  tt-doc-pl.pl-code
             ,output v-rvs-qnty-before
             ,output v-rvs-qnty-after
             ,output v-rvs-cli-qnty-before
             ,output v-rvs-cli-qnty-after
             ,output v-delta-mass-qnty
             ,output v-trk-err
            ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
          if v-trk-err
          then do :
            assign v-place-trk-err = v-place-trk-err + string(tt-doc-pl.pl-code) + ',' .
          end .
          assign
            v-count-pl     = v-count-pl + 1
            v-tot-qnty-rvs = v-tot-qnty-rvs + ( v-rvs-qnty-after - v-rvs-qnty-before )
            v-tot-cli-qnty-rvs = v-tot-cli-qnty-rvs + ( v-rvs-cli-qnty-after - v-rvs-cli-qnty-before )
            v-tot-qnty-pl  = v-tot-qnty-pl  + tt-doc-pl.fact-qnty
          .
          run placelib_get-attr  (
             input "place-com-tanks"
            ,input t-doc.obj-code
            ,input t-doc.obj-type
            ,input tt-doc-pl.pl-code
            ,output v-value
            ,output v-ok      )
          no-error.
          if  v-ok
          and v-value > ""
          then do :
            do ii = 1 to num-entries(v-value) :
              find first buf_place no-lock where buf_place.obj-type = tt-doc-pl.obj-type
                                             and buf_place.obj-code = tt-doc-pl.obj-code
                                             and buf_place.loc1     = entry(ii, v-value)
                                             and buf_place.status_  = ""
                                             no-error .
              if available buf_place
              then do :
                run return-rvs-qnty in this-procedure
                  ( input  p-doc-code
                   ,input  p-gds-code
                   ,input  buf_place.pl-code
                   ,output v-rvs-qnty-before
                   ,output v-rvs-qnty-after
                   ,output v-rvs-cli-qnty-before
                   ,output v-rvs-cli-qnty-after
                   ,output v-delta-mass-qnty
                   ,output v-trk-err
                  ) no-error .
                if error-status :error then do:
                  return error return-value .
                end.
                if v-trk-err
                then do :
                  assign v-place-trk-err = v-place-trk-err + string(buf_place.pl-code) + ',' .
                end .
                assign
                  v-count-pl     = v-count-pl + 1
                  v-tot-qnty-rvs = v-tot-qnty-rvs + ( v-rvs-qnty-after - v-rvs-qnty-before )
                  v-tot-cli-qnty-rvs = v-tot-cli-qnty-rvs + ( v-rvs-cli-qnty-after - v-rvs-cli-qnty-before )
                .
              end .
            end .
          end .
          assign v-place-trk-err = trim(v-place-trk-err, ",") .
          if v-place-trk-err > ""
          then do :
            assign v-trk-err = yes .
          end .
          run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.
          if error-status:error
          then do:
            rdc-dnstvalue = 'not'.
          end.
          else do:
            rdc-dnstvalue = rdc-dnstvalue.
          end.
          if not (varauto-tank and rdc-dnstvalue = "pomi-rn")
          then do:
            if absolute( v-tot-qnty-rvs - tt-doc-pl.fact-qnty ) > tt-doc-pl.fact-qnty * 0.0065 then do:
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
                                        ,tt-doc-pl.fact-qnty
                                        ,v-tot-qnty-rvs
                                        ,buf_goods.unit-base
                                        )
              .
              if v-trk-err
              then do :
                v-message = substitute("Масса реализации при расчете расхождения не была учтена из-за ошибок при получении данных с ТРК по месту хр. &1", tt-doc-pl.pl-code)
                          + chr(10)
                          + v-message
                .
              end .
            end.
          end.
          else do:
            v-delta-mass-qnty = tt-doc-pl.cli-fact-qnty * v-delta-mass-qnty / 100.
            if absolute( v-tot-cli-qnty-rvs - tt-doc-pl.cli-fact-qnty ) > v-delta-mass-qnty
            then do:
              if v-message = "":U then do:
                assign
                  v-message = substitute ("Факт. кол-во по сверкам не совпадает с факт. кол-вом по местам хранения :").
                .
              end.
              assign
                v-message = v-message
                            + chr(10)
                            + substitute( "по месту хр. &1 (&4): &2, по сверкам: &3, погрешность измерения: &5."
                                        ,tt-doc-pl.pl-code
                                        ,tt-doc-pl.cli-fact-qnty
                                        ,v-tot-cli-qnty-rvs
                                        ,buf_goods.unit-cli
                                        ,round (v-delta-mass-qnty, 3)
                                        )
              .
              if v-trk-err
              then do :
                v-message = substitute("Масса реализации при расчете расхождения не была учтена из-за ошибок при получении данных с ТРК по месту хр. &1", tt-doc-pl.pl-code)
                          + chr(10)
                          + v-message
                .
              end .
              message v-message view-as alert-box warning title "Внимание!".
              v-message = "".
            end.
          end.
        end.
        if v-message <> "":U
          then return.
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
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input t-doc.obj-type
  , input t-doc.obj-code
  ) .
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
                 ,output v-delta-mass-qnty
                 ,output v-trk-err
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
    PROCEDURE block-nozzle:
      define input parameter parparentproc  as handle    no-undo.
      define input parameter obj-type       as character no-undo.
      define input parameter obj-code       as integer   no-undo.
      define input parameter list-pl        as character no-undo.
      run str/diallog.w ( input parparentproc
         ,input this-procedure
         ,input 'str/get-block-nozzle.p':U
         ,input (obj-type + chr(4) +
         string(obj-code) + chr(4) +
         string(0) + chr(4) +
         string(0) + chr(4) +
         chr(4) +
         chr(4) +
         chr(4) +
         substitute("&1,&2"
         ,"block"
         ,list-pl))
         ,input yes
         ,input ''
         ,input 'Блокировка пистолетов') .
      if not error-status:error then
      do:
         if return-value begins "Для кассы" then
         do:
            message return-value
               view-as alert-box question buttons yes-no update v-ok as logical  .
            if v-ok then run block-nozzle ( parparentproc, obj-type, obj-code, list-pl ).
            else message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
                  view-as alert-box.
         end.
         else
         do:
            message "Блокировка пистолетов прошла успешно"
               view-as alert-box.
         end.
      end.
      else
      do:
         message return-value
            view-as alert-box question buttons yes-no update v-ok .
         if v-ok then run block-nozzle .
         else                   message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
               view-as alert-box.
      end.
    END PROCEDURE .
    PROCEDURE unblock-nozzle:
      define input parameter parparentproc  as handle    no-undo.
      define input parameter obj-type       as character no-undo.
      define input parameter obj-code       as integer   no-undo.
      define input parameter list-pl        as character no-undo.
      run str/diallog.w ( input parparentproc
        ,input this-procedure
        ,input 'str/get-block-nozzle.p':U
        ,input (obj-type + chr(4) +
        string(obj-code) + chr(4) +
        string(0) + chr(4) +
        string(0) + chr(4) +
        chr(4) +
        chr(4) +
        chr(4) +
        substitute("&1,&2"
        ,"unblock"
        ,list-pl))
        ,input yes
        ,input ''
        ,input 'Разблокировка пистолетов') .
      if not error-status:error then
      do:
         if return-value begins "Для кассы" then
         do:
            message return-value
               view-as alert-box question buttons yes-no update v-ok as logical  .
            if v-ok then run unblock-nozzle( parparentproc, obj-type, obj-code, list-pl ).
            else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
                  view-as alert-box.
         end.
         else
         do:
            message "Разблокировка пистолетов прошла успешно"
               view-as alert-box.
         end.
      end.
      else
      do:
        message return-value
           view-as alert-box question buttons yes-no update v-ok .
        if v-ok then run unblock-nozzle .
        else                   message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
              view-as alert-box.
         end.
    END PROCEDURE.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
def var vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
def var vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info41 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info41, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info41, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info41, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info41, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info41 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info41, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info41 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info41, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info41, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info41, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info41, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info41, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info41, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info41 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info41 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info41, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info41, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info41, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info41 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info41 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info41, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info41, v-inform, v-tbl-name ).
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
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
function MM6 returns logical
  (
  input H as decimal,
  input H_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input P0 as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input ToolType as integer,
  input DeltaOtn_K as decimal,
  input DeadZone_Reservoir as decimal,
  input A_Reservoir as decimal,
  input A_LevelMeasurementTool as decimal,
  input ToolAutomationLevel_H as integer,
  input ToolAutomationLevel_H_Water as integer,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_H_CalcType as integer,
  input DeltaAbs_H_Water_CalcType as integer,
  input DeltaAbs_H as decimal,
  input DeltaAbs_H_Water as decimal,
  input DeltaAbs_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total as decimal,
  output V_water as decimal,
  output DeltaV as decimal,
  output V_product as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output DeltaOtn_Vm as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output VolumetricExpansion as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt6"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 56
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", H_water).
  hCall:SET-PARAMETER(6, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(7, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", P0).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(13, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", DeadZone_Reservoir).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", A_LevelMeasurementTool).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolAutomationLevel_H).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolAutomationLevel_H_Water).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", DeltaAbs_H_CalcType).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", DeltaAbs_H_Water_CalcType).
  hCall:SET-PARAMETER(25, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(26, "DOUBLE", "INPUT", DeltaAbs_H_Water).
  hCall:SET-PARAMETER(27, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(28, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(29, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(30, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", V_total).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", V_water).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", V_product).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(50, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(51, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", DeltaOtn_Vm).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM7 returns logical
  (
  input M1 as decimal,
  input M2 as decimal,
  input H1 as decimal,
  input H2 as decimal,
  input H1_water as decimal,
  input H2_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input Tv1 as decimal,
  input Tv2 as decimal,
  input Tr1 as decimal,
  input Tr2 as decimal,
  input R1 as decimal,
  input R2 as decimal,
  input ToolType1 as integer,
  input ToolType2 as integer,
  input DeltaOtn_K as decimal,
  input OperDirection as integer,
  input ToolAutomationLevel_H1 as integer,
  input ToolAutomationLevel_H2 as integer,
  input ToolAutomationLevel_H_Water1 as integer,
  input ToolAutomationLevel_H_Water2 as integer,
  input ToolAutomationLevel_R1 as integer,
  input ToolAutomationLevel_R2 as integer,
  input ToolAutomationLevel_Tv1 as integer,
  input ToolAutomationLevel_Tv2 as integer,
  input ToolAutomationLevel_Tr1 as integer,
  input ToolAutomationLevel_Tr2 as integer,
  input DeltaAbs_H_CalcType1 as integer,
  input DeltaAbs_H_CalcType2 as integer,
  input DeltaAbs_H_Water_CalcType1 as integer,
  input DeltaAbs_H_Water_CalcType2 as integer,
  input DeltaAbs_H1 as decimal,
  input DeltaAbs_H2 as decimal,
  input DeltaAbs_H_Water1 as decimal,
  input DeltaAbs_H_Water2 as decimal,
  input DeltaAbs_R1 as decimal,
  input DeltaAbs_R2 as decimal,
  input DeltaAbs_Tv1 as decimal,
  input DeltaAbs_Tv2 as decimal,
  input DeltaAbs_Tr1 as decimal,
  input DeltaAbs_Tr2 as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total1 as decimal,
  output V_total2 as decimal,
  output V_water1 as decimal,
  output V_water2 as decimal,
  output Delta_V1 as decimal,
  output Delta_V2 as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt7"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 59
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", M1).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M2).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", H1).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", H2).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H1_water).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H2_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tv1).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Tv2).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tr1).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr2).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R1).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", R2).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType1).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolType2).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", OperDirection).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_H1).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H2).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water1).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_H_Water2).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_R1).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_R2).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", ToolAutomationLevel_Tv1).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", ToolAutomationLevel_Tv2).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", ToolAutomationLevel_Tr1).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", ToolAutomationLevel_Tr2).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", DeltaAbs_H_CalcType1).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", DeltaAbs_H_CalcType2).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", DeltaAbs_H_Water_CalcType1).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", DeltaAbs_H_Water_CalcType2).
  hCall:SET-PARAMETER(36, "DOUBLE", "INPUT", DeltaAbs_H1).
  hCall:SET-PARAMETER(37, "DOUBLE", "INPUT", DeltaAbs_H2).
  hCall:SET-PARAMETER(38, "DOUBLE", "INPUT", DeltaAbs_H_Water1).
  hCall:SET-PARAMETER(39, "DOUBLE", "INPUT", DeltaAbs_H_Water2).
  hCall:SET-PARAMETER(40, "DOUBLE", "INPUT", DeltaAbs_R1).
  hCall:SET-PARAMETER(41, "DOUBLE", "INPUT", DeltaAbs_R2).
  hCall:SET-PARAMETER(42, "DOUBLE", "INPUT", DeltaAbs_Tv1).
  hCall:SET-PARAMETER(43, "DOUBLE", "INPUT", DeltaAbs_Tv2).
  hCall:SET-PARAMETER(44, "DOUBLE", "INPUT", DeltaAbs_Tr1).
  hCall:SET-PARAMETER(45, "DOUBLE", "INPUT", DeltaAbs_Tr2).
  hCall:SET-PARAMETER(46, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(47, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(48, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(49, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(50, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(51, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", V_total1).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", V_total2).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", V_water1).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", V_water2).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Delta_V1).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", Delta_V2).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM13 returns logical
 (
  input Mpokr as decimal,
  input Rprov as decimal,
  input Vdisp as decimal,
  input CoverFloatingHeight as decimal,
  input H as decimal,
  input H_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input P0 as decimal,
  input Pv as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input ToolType as integer,
  input DeltaOtn_K as decimal,
  input DeadZone_Reservoir as decimal,
  input A_Reservoir as decimal,
  input A_LevelMeasurementTool as decimal,
  input ToolAutomationLevel_H as integer,
  input ToolAutomationLevel_H_Water as integer,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_H_CalcType as integer,
  input DeltaAbs_H_Water_CalcType as integer,
  input DeltaAbs_H as decimal,
  input DeltaAbs_H_Water as decimal,
  input DeltaAbs_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total as decimal,
  output V_water as decimal,
  output DeltaV as decimal,
  output V_product as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output DeltaOtn_Vm as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output VolumetricExpansion as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt13"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 61
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", Mpokr).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", Rprov).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", Vdisp).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", CoverFloatingHeight).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", P0).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Pv).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(19, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeadZone_Reservoir).
  hCall:SET-PARAMETER(21, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(22, "DOUBLE", "INPUT", A_LevelMeasurementTool).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", DeltaAbs_H_CalcType).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", DeltaAbs_H_Water_CalcType).
  hCall:SET-PARAMETER(30, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(31, "DOUBLE", "INPUT", DeltaAbs_H_Water).
  hCall:SET-PARAMETER(32, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(33, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(34, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(35, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(36, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(37, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(38, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(39, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(40, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", V_total).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", V_water).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", V_product).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(50, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(51, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", DeltaOtn_Vm).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(60, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(61, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM14 returns logical
  (
  input M1 as decimal,
  input M2 as decimal,
  input H1 as decimal,
  input H2 as decimal,
  input H1_water as decimal,
  input H2_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input Tv1 as decimal,
  input Tv2 as decimal,
  input Tr1 as decimal,
  input Tr2 as decimal,
  input R1 as decimal,
  input R2 as decimal,
  input ToolType1 as integer,
  input ToolType2 as integer,
  input DeltaOtn_K as decimal,
  input OperDirection as integer,
  input ToolAutomationLevel_H1 as integer,
  input ToolAutomationLevel_H2 as integer,
  input ToolAutomationLevel_H_Water1 as integer,
  input ToolAutomationLevel_H_Water2 as integer,
  input ToolAutomationLevel_R1 as integer,
  input ToolAutomationLevel_R2 as integer,
  input ToolAutomationLevel_Tv1 as integer,
  input ToolAutomationLevel_Tv2 as integer,
  input ToolAutomationLevel_Tr1 as integer,
  input ToolAutomationLevel_Tr2 as integer,
  input DeltaAbs_H_CalcType1 as integer,
  input DeltaAbs_H_CalcType2 as integer,
  input DeltaAbs_H_Water_CalcType1 as integer,
  input DeltaAbs_H_Water_CalcType2 as integer,
  input DeltaAbs_H1 as decimal,
  input DeltaAbs_H2 as decimal,
  input DeltaAbs_H_Water1 as decimal,
  input DeltaAbs_H_Water2 as decimal,
  input DeltaAbs_R1 as decimal,
  input DeltaAbs_R2 as decimal,
  input DeltaAbs_Tv1 as decimal,
  input DeltaAbs_Tv2 as decimal,
  input DeltaAbs_Tr1 as decimal,
  input DeltaAbs_Tr2 as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total1 as decimal,
  output V_total2 as decimal,
  output V_water1 as decimal,
  output V_water2 as decimal,
  output Delta_V1 as decimal,
  output Delta_V2 as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt14"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 59
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", M1).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M2).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", H1).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", H2).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H1_water).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H2_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tv1).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Tv2).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tr1).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr2).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R1).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", R2).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType1).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolType2).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", OperDirection).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_H1).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H2).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water1).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_H_Water2).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_R1).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_R2).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", ToolAutomationLevel_Tv1).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", ToolAutomationLevel_Tv2).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", ToolAutomationLevel_Tr1).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", ToolAutomationLevel_Tr2).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", DeltaAbs_H_CalcType1).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", DeltaAbs_H_CalcType2).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", DeltaAbs_H_Water_CalcType1).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", DeltaAbs_H_Water_CalcType2).
  hCall:SET-PARAMETER(36, "DOUBLE", "INPUT", DeltaAbs_H1).
  hCall:SET-PARAMETER(37, "DOUBLE", "INPUT", DeltaAbs_H2).
  hCall:SET-PARAMETER(38, "DOUBLE", "INPUT", DeltaAbs_H_Water1).
  hCall:SET-PARAMETER(39, "DOUBLE", "INPUT", DeltaAbs_H_Water2).
  hCall:SET-PARAMETER(40, "DOUBLE", "INPUT", DeltaAbs_R1).
  hCall:SET-PARAMETER(41, "DOUBLE", "INPUT", DeltaAbs_R2).
  hCall:SET-PARAMETER(42, "DOUBLE", "INPUT", DeltaAbs_Tv1).
  hCall:SET-PARAMETER(43, "DOUBLE", "INPUT", DeltaAbs_Tv2).
  hCall:SET-PARAMETER(44, "DOUBLE", "INPUT", DeltaAbs_Tr1).
  hCall:SET-PARAMETER(45, "DOUBLE", "INPUT", DeltaAbs_Tr2).
  hCall:SET-PARAMETER(46, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(47, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(48, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(49, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(50, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(51, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", V_total1).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", V_total2).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", V_water1).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", V_water2).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Delta_V1).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", Delta_V2).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM26A returns logical
  (
  input Type as integer,
  input Diameter as decimal,
  input Length as decimal,
  input Width as decimal,
  input Circumference as decimal,
  input Wall as decimal,
  output Area as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt26A"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 12
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "LONG", "INPUT", Type).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", Diameter).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", Length).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", Width).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", Circumference).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Wall).
  hCall:SET-PARAMETER(10, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(11, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(12, "DOUBLE", "OUTPUT", Area).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM31N returns logical
  (
  input V_real as decimal,
  input DeltaCorrectionType as integer,
  input CalibrationTable as character,
  input DeltaH as decimal,
  input NeckArea as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input Pr as decimal,
  input Pv as decimal,
  input ToolType as integer,
  input A_Reservoir as decimal,
  input DeltaOtn_V as decimal,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_R as decimal,
  input DeltaOtn_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output DeltaV_GT as decimal,
  output DeltaV as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output Rcy20 as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output VolumetricExpansion as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt31N"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 49
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", V_real).
  hCall:SET-PARAMETER(5, "LONG", "INPUT", DeltaCorrectionType).
  hCall:SET-PARAMETER(6, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", DeltaH).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", NeckArea).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Pr).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Pv).
  hCall:SET-PARAMETER(15, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", DeltaOtn_V).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(21, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(22, "DOUBLE", "INPUT", DeltaOtn_R).
  hCall:SET-PARAMETER(23, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(24, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(25, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(31, "DOUBLE", "OUTPUT", DeltaV_GT).
  hCall:SET-PARAMETER(32, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(33, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(34, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(35, "DOUBLE", "OUTPUT", Rcy20).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM53 returns logical
  (
  input H as decimal,
  input CalibrationTable as character,
  input T as decimal,
  input R_liquid as decimal,
  input R_gas as decimal,
  input A_Reservoir as decimal,
  input DeltaOtn_K as decimal,
  input DeltaOtn_K_full as decimal,
  input DeltaAbs_H as decimal,
  input DeltaAbs_R_liquid as decimal,
  input DeltaAbs_R_gas as decimal,
  input Use_DeltaOtn_R_liquid_IN as integer,
  input DeltaOtn_R_liquid_IN as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output C_HN as decimal,
  output C_HN_delta as decimal,
  output C_full as decimal,
  output V_liquid as decimal,
  output V_gas as decimal,
  output M_liquid as decimal,
  output M_gas as decimal,
  output M as decimal,
  output Kf as decimal,
  output DeltaOtn_H as decimal,
  output DeltaOtn_R_liquid as decimal,
  output DeltaOtn_R_gas as decimal,
  output DeltaOtn_M_liquid as decimal,
  output DeltaOtn_M_gas as decimal,
  output DeltaOtn_M as decimal,
  output H_min_liquid as decimal,
  output H_min as decimal,
  output A as decimal,
  output B as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt53"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 41
  .
  if DeltaOtn_R_liquid_IN = 0.42
  then
    DeltaOtn_R_liquid_IN = DeltaOtn_R_liquid_IN - 0.0000000001
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", R_liquid).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", R_gas).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", DeltaOtn_K_full).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", DeltaAbs_R_liquid).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", DeltaAbs_R_gas).
  hCall:SET-PARAMETER(15, "SHORT", "INPUT", Use_DeltaOtn_R_liquid_IN).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", DeltaOtn_R_liquid_IN).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(23, "DOUBLE", "OUTPUT", C_HN).
  hCall:SET-PARAMETER(24, "DOUBLE", "OUTPUT", C_HN_delta).
  hCall:SET-PARAMETER(25, "DOUBLE", "OUTPUT", C_full).
  hCall:SET-PARAMETER(26, "DOUBLE", "OUTPUT", V_liquid).
  hCall:SET-PARAMETER(27, "DOUBLE", "OUTPUT", V_gas).
  hCall:SET-PARAMETER(28, "DOUBLE", "OUTPUT", M_liquid).
  hCall:SET-PARAMETER(29, "DOUBLE", "OUTPUT", M_gas).
  hCall:SET-PARAMETER(30, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(31, "DOUBLE", "OUTPUT", Kf).
  hCall:SET-PARAMETER(32, "DOUBLE", "OUTPUT", DeltaOtn_H).
  hCall:SET-PARAMETER(33, "DOUBLE", "OUTPUT", DeltaOtn_R_liquid).
  hCall:SET-PARAMETER(34, "DOUBLE", "OUTPUT", DeltaOtn_R_gas).
  hCall:SET-PARAMETER(35, "DOUBLE", "OUTPUT", DeltaOtn_M_liquid).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", DeltaOtn_M_gas).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", H_min_liquid).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", H_min).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", A).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", B).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM55 returns logical
  (
  input R15 as decimal,
  input T as decimal,
  input Round_R as integer,
  input Round_T as integer,
  output R as decimal,
  output CTL as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt55"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 11
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", R15).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(6, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(8, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(9, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(10, "DOUBLE", "OUTPUT", R).
  hCall:SET-PARAMETER(11, "DOUBLE", "OUTPUT", CTL).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM56 returns logical
  (
  input M_type as integer,
  input M as decimal extent 16,
  input T as decimal,
  input P_type as integer,
  input P_extra as decimal,
  input P_atmosphere as decimal,
  input M_pseudo as decimal,
  input R_pseudo as decimal,
  input Round_T as integer,
  input Round_R as integer,
  output R as decimal,
  output P_vapor as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt56"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 17
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "LONG", "INPUT", M_type).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", P_type).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", P_extra).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", P_atmosphere).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", M_pseudo).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R_pseudo).
  hCall:SET-PARAMETER(12, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(13, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(14, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(15, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(16, "DOUBLE", "OUTPUT", R).
  hCall:SET-PARAMETER(17, "DOUBLE", "OUTPUT", P_vapor).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM57 returns logical
  (
  input H as decimal,
  input ToolType as integer,
  output DeltaAbs_H as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt57"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 8
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(6, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(8, "DOUBLE", "OUTPUT", DeltaAbs_H).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function getCalibrationBelt returns character
  (
  input iObjType as character,
  input iObjCode as integer,
  input iPlCode  as integer,
  input iLevelNP as decimal,
  input iLevelWater as decimal
  )
:
  define variable vCalibBelt      as  character         no-undo.
  define buffer   buf_pl-level-mm for ub.pl-level-mm.
  for each buf_pl-level-mm where
           buf_pl-level-mm.obj-type = iObjType
       and buf_pl-level-mm.obj-code = iObjCode
       and buf_pl-level-mm.pl-code  = iPlCode
       and ((buf_pl-level-mm.min-level <= iLevelNP and buf_pl-level-mm.max-level >= iLevelNP) or
            (buf_pl-level-mm.min-level <= iLevelWater and buf_pl-level-mm.max-level >= iLevelWater))
      no-lock
      break by buf_pl-level-mm.zone by buf_pl-level-mm.level:
    if first-of(buf_pl-level-mm.zone) then do:
      vCalibBelt = substitute("&1&2;&3=",vCalibBelt, buf_pl-level-mm.min-level,buf_pl-level-mm.max-level).
    end.
    vCalibBelt = substitute("&1&2&3",vCalibBelt, if buf_pl-level-mm.level = 1 then "" else ";", trim(string(buf_pl-level-mm.capacity / 1000, ">>>>>9.999"))).
    if last-of(buf_pl-level-mm.zone) and not last(buf_pl-level-mm.zone) then
      vCalibBelt = substitute("&1&2",vCalibBelt, chr(10)).
  end.
  return vCalibBelt.
end.
procedure calc-pomi-rvs :
  define input parameter p-sec-num as integer no-undo .
  define input parameter p-doc-code as character no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input-output parameter infoSectionTotal as class ibs.th.str.InfoSectionsTotal    no-undo .
  define output parameter p-tank-weight-rvs as decimal no-undo .
  define output parameter p-tank-vol-pomi-rvs as decimal no-undo .
  define buffer buf_place             for ub.place .
  define buffer buf2_place            for ub.place .
  define buffer buf_clob-bind         for ub.clob-bind .
  define buffer bf_goods              for ub.goods .
  define buffer bf_bef_rvs-doc        for ub.rvs-doc  .
  define buffer bf_aft_rvs-doc        for ub.rvs-doc  .
  define buffer bf_bef_rvs-line       for ub.rvs-line .
  define buffer bf_aft_rvs-line       for ub.rvs-line .
  define buffer bf_rvs-line-attr      for ub.rvs-line-attr .
  define buffer buf_sr-izmerenia      for sr-izmerenia .
  define buffer dens_sr-izmerenia     for sr-izmerenia .
  define buffer temp_sr-izmerenia     for sr-izmerenia .
  define buffer level_sr-izmerenia    for sr-izmerenia .
  define buffer temp-dens_sr-izmerenia for sr-izmerenia .
  define buffer water1_pl-level       for ub.pl-level .
  define buffer water2_pl-level       for ub.pl-level .
  define buffer total1_pl-level       for ub.pl-level .
  define buffer total2_pl-level       for ub.pl-level .
  define buffer buf_pl-level-attr     for ub.pl-level-attr .
  define buffer buf_pl-level          for ub.pl-level .
  define variable CalibTable               as character no-undo initial "".
  define variable CalibBelt                as character no-undo initial "".
  define variable DeltaOtn_K               as decimal no-undo.
  define variable DeltaOtn_N               as decimal no-undo init 0.05 .
  define variable ToolType1                as integer no-undo.
  define variable LevelToolType1           as integer no-undo.
  define variable DeltaAbs_H1              as decimal no-undo.
  define variable DeltaAbs_H_Water1        as decimal no-undo.
  define variable DeltaAbs_R1              as decimal no-undo.
  define variable DeltaAbs_Tv1             as decimal no-undo.
  define variable DeltaAbs_Tr1             as decimal no-undo.
  define variable DeltaOtn_H1              as decimal no-undo.
  define variable DeltaOtn_H_Water1        as decimal no-undo.
  define variable DeltaOtn_R1              as decimal no-undo.
  define variable ToolAutomationLevel_H1   as integer no-undo.
  define variable ToolAutomationLevel_H_Water1 as integer no-undo.
  define variable ToolAutomationLevel_R1   as integer no-undo.
  define variable ToolAutomationLevel_Tv1  as integer no-undo.
  define variable ToolAutomationLevel_Tr1  as integer no-undo.
  define variable DeltaAbs_H_CalcType1     as integer no-undo.
  define variable DeltaAbs_H_Water_CalcType1   as integer no-undo.
  define variable ToolType2                as integer no-undo.
  define variable LevelToolType2           as integer no-undo.
  define variable DeltaAbs_H2              as decimal no-undo.
  define variable DeltaAbs_H_Water2        as decimal no-undo.
  define variable DeltaAbs_R2              as decimal no-undo.
  define variable DeltaAbs_Tv2             as decimal no-undo.
  define variable DeltaAbs_Tr2             as decimal no-undo.
  define variable DeltaOtn_H2              as decimal no-undo.
  define variable DeltaOtn_H_Water2        as decimal no-undo.
  define variable DeltaOtn_R2              as decimal no-undo.
  define variable ToolAutomationLevel_H2   as integer no-undo.
  define variable ToolAutomationLevel_H_Water2 as integer no-undo.
  define variable ToolAutomationLevel_R2   as integer no-undo.
  define variable ToolAutomationLevel_Tv2  as integer no-undo.
  define variable ToolAutomationLevel_Tr2  as integer no-undo.
  define variable DeltaAbs_H_CalcType2     as integer no-undo.
  define variable DeltaAbs_H_Water_CalcType2   as integer no-undo.
  define variable v-temp-izm-vol1         as decimal no-undo .
  define variable v-temp-izm-vol2         as decimal no-undo .
  define variable place-SI                as integer no-undo .
  define variable v-place-type            as integer no-undo .
  define variable pl-rvd-dens-1           as logical no-undo .
  define variable pl-rvd-lvl-1            as logical no-undo .
  define variable pl-rvd-temp-1           as logical no-undo .
  define variable pl-rvd-dens-2           as logical no-undo .
  define variable pl-rvd-lvl-2            as logical no-undo .
  define variable pl-rvd-temp-2           as logical no-undo .
  define variable v-mi-lvl-1              as integer no-undo .
  define variable v-mi-lvl-2              as integer no-undo .
  define variable v-mi-dnst-1             as integer no-undo .
  define variable v-mi-dnst-2             as integer no-undo .
  define variable v-mi-tmp-1              as integer no-undo .
  define variable v-mi-tmp-2              as integer no-undo .
  define variable v-mi-tmp-dnst-1         as integer no-undo .
  define variable v-mi-tmp-dnst-2         as integer no-undo .
  define variable DeltaV1                 as decimal no-undo .
  define variable DeltaV2                 as decimal no-undo .
  define variable WaterDeltaV1            as decimal no-undo .
  define variable WaterDeltaV2            as decimal no-undo .
  define variable Tv1                     as decimal no-undo .
  define variable Tr1                     as decimal no-undo .
  define variable R1                      as decimal no-undo .
  define variable Tv2                     as decimal no-undo .
  define variable Tr2                     as decimal no-undo .
  define variable R2                      as decimal no-undo .
  define variable temp-for-pomi           as integer no-undo.
  define variable error-string            as character no-undo.
  define variable v-is-meas               as logical no-undo.
  define variable v-mm-density            as decimal no-undo.
  define variable v-proc as character no-undo.
  define variable vAutomationDegree as integer no-undo extent 3 init [2,1,3].
  define variable v-com-tanks    as character no-undo init "":U .
  define variable v-pl-code-list as character no-undo init "":U .
  define variable ii             as integer   no-undo .
  define variable v-avg-temp     as decimal   no-undo .
  define variable v-ok as logical no-undo .
  define variable v-sec as character no-undo .
  define variable infoSecObj as class ibs.th.str.InfoSection no-undo .
  define variable v-value as character no-undo .
  define variable vErr as character no-undo .
  define variable vWrn as character no-undo .
  define variable vDllVersion as character no-undo .
  define variable V_total1   as decimal no-undo .
  define variable V_total2   as decimal no-undo .
  define variable V_water1   as decimal no-undo .
  define variable V_water2   as decimal no-undo .
  define variable Delta_V1   as decimal no-undo .
  define variable Delta_V2   as decimal no-undo .
  define variable M          as decimal no-undo .
  define variable DeltaOtn_M as decimal no-undo .
  define variable v-warnings as character no-undo .
  _trpomi :
  do on error undo, return error :
    infoSecObj = infoSectionTotal:GetInfoSectionProp(p-sec-num) .
    v-sec = infoSecObj:SectionName .
    find first bf_bef_rvs-doc no-lock where bf_bef_rvs-doc.rvs-type = 'перед_док':U
                                        and bf_bef_rvs-doc.out-code = p-doc-code
                                        and num-entries(bf_bef_rvs-doc.rvs-code, "-") = 3
                                        and entry(2, bf_bef_rvs-doc.rvs-code, "-") = v-sec
                                        no-error .
    if not available bf_bef_rvs-doc
    then do :
      find first bf_bef_rvs-doc no-lock where bf_bef_rvs-doc.rvs-type = 'перед_док':U
                                          and bf_bef_rvs-doc.out-code = p-doc-code
                                          and num-entries(bf_bef_rvs-doc.rvs-code, "-") = 2
                                          no-error .
    end .
    find first bf_aft_rvs-doc no-lock where bf_aft_rvs-doc.rvs-type = 'после_док':U
                                        and bf_aft_rvs-doc.out-code = p-doc-code
                                        and num-entries(bf_aft_rvs-doc.rvs-code, "-") = 3
                                        and entry(2, bf_aft_rvs-doc.rvs-code, "-") = v-sec
                                        no-error .
    if not available bf_aft_rvs-doc
    then do :
      find first bf_aft_rvs-doc no-lock where bf_aft_rvs-doc.rvs-type = 'после_док':U
                                          and bf_aft_rvs-doc.out-code = p-doc-code
                                          and num-entries(bf_aft_rvs-doc.rvs-code, "-") = 2
                                          no-error .
    end .
    if not available bf_bef_rvs-doc
    or not available bf_aft_rvs-doc
    then do :
      if infoSecObj:AccMeth = 1
      and index(this-procedure:name, "in-ladd") > 0
      then do :
        message "Не найдены сверки по документу!" view-as alert-box error .
      end .
      undo _trpomi, return error .
    end .
    find first buf_place no-lock where buf_place.obj-type = infoSectionTotal:ObjType
                                   and buf_place.obj-code = infoSectionTotal:ObjCode
                                   and buf_place.loc1     = infoSecObj:ListTank
                                   and buf_place.status_  = ""
                                   no-error .
    if not available buf_place
    then do :
      message substitute("Не найден текущий резервуар с кодом &1!", infoSecObj:ListTank) view-as alert-box error .
      undo _trpomi, return error .
    end .
    assign v-pl-code-list = v-pl-code-list + string(buf_place.pl-code) + "," .
    run placelib_get-attr  ( input "place-com-tanks"
                            ,input buf_place.obj-code
                            ,input buf_place.obj-type
                            ,input buf_place.pl-code
                            ,output v-value
                            ,output v-ok      )
                            no-error.
    if v-ok then v-com-tanks = v-value .
    if v-com-tanks > ""
    then do :
      do ii = 1 to num-entries(v-com-tanks) :
        find first buf2_place no-lock where buf2_place.obj-type = buf_place.obj-type
                                        and buf2_place.obj-code = buf_place.obj-code
                                        and buf2_place.loc1     = entry(ii, v-com-tanks)
                                        and buf2_place.status_  = ""
                                        no-error .
        if available buf2_place
        then do :
          assign v-pl-code-list = v-pl-code-list + string(buf2_place.pl-code) + "," .
        end .
      end .
    end .
    assign v-pl-code-list = trim(v-pl-code-list, ",") .
    assign
      p-tank-weight-rvs   = 0.0
      p-tank-vol-pomi-rvs = 0.0
    .
    place_ :
    do ii = 1 to num-entries(v-pl-code-list) :
      find first buf_place no-lock where buf_place.pl-code = integer(entry(ii, v-pl-code-list)) no-error .
      if not available buf_place
      then do :
        undo _trpomi, return error .
      end .
      run placelib_get-attr  ( input "place-type"
                              ,input buf_place.obj-code
                              ,input buf_place.obj-type
                              ,input buf_place.pl-code
                              ,output v-value
                              ,output v-ok      )
                              no-error.
      if v-ok then v-place-type = integer(v-value) .
      assign
        v-proc = "CMethodOfMetering7"
      .
      if v-ok
      and v-place-type = 1
      then
      assign
        v-proc = "CMethodOfMetering14"
      .
      run placelib_get-attr  ( input "place-SI"
                              ,input buf_place.obj-code
                              ,input buf_place.obj-type
                              ,input buf_place.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      if v-ok
      then place-si = integer(v-value) .
      else place-si = ? .
      find first bf_bef_rvs-line no-lock where bf_bef_rvs-line.rvs-code = bf_bef_rvs-doc.rvs-code
                                           and bf_bef_rvs-line.obj-type = bf_bef_rvs-doc.obj-type
                                           and bf_bef_rvs-line.obj-code = bf_bef_rvs-doc.obj-code
                                           and bf_bef_rvs-line.pl-code  = buf_place.pl-code
                                           and bf_bef_rvs-line.gds-code = p-gds-code
                                           no-error .
      if not available bf_bef_rvs-line
      then do :
        if infoSecObj:AccMeth = 1
        and index(this-procedure:name, "in-ladd") > 0
        then do :
          message "Не заполнена сверка До!" view-as alert-box error .
        end .
        undo _trpomi, return error .
      end .
      if bf_bef_rvs-line.state-measure-qnty = ?
      or bf_bef_rvs-line.state-measure-qnty <= 0
      or bf_bef_rvs-line.state-measure-cli-qnty = ?
      or bf_bef_rvs-line.state-measure-cli-qnty <= 0
      or bf_bef_rvs-line.state-level-total = ?
      or bf_bef_rvs-line.state-level-total <= 0
      or bf_bef_rvs-line.state-level-water = ?
      or bf_bef_rvs-line.state-temperature = ?
      then do :
        if infoSecObj:AccMeth = 1
        and index(this-procedure:name, "in-ladd") > 0
        then do :
          message "Не заполнена сверка До!" view-as alert-box error .
        end .
        undo _trpomi, return error .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "temp-izm-vol"
      :
        v-temp-izm-vol1 = decimal(bf_rvs-line-attr.attr-value) .
      end .
      find first bf_aft_rvs-line no-lock where bf_aft_rvs-line.rvs-code = bf_aft_rvs-doc.rvs-code
                                           and bf_aft_rvs-line.obj-type = bf_aft_rvs-doc.obj-type
                                           and bf_aft_rvs-line.obj-code = bf_aft_rvs-doc.obj-code
                                           and bf_aft_rvs-line.pl-code  = buf_place.pl-code
                                           and bf_aft_rvs-line.gds-code = p-gds-code
                                           no-error .
      if not available bf_aft_rvs-line
      then do :
        if infoSecObj:AccMeth = 1
        and index(this-procedure:name, "in-ladd") > 0
        then do :
          message "Не заполнена сверка После!" view-as alert-box error .
        end .
        undo _trpomi, return error .
      end .
      if bf_aft_rvs-line.state-measure-qnty = ?
      or bf_aft_rvs-line.state-measure-qnty <= 0
      or bf_aft_rvs-line.state-measure-cli-qnty = ?
      or bf_aft_rvs-line.state-measure-cli-qnty <= 0
      or bf_aft_rvs-line.state-level-total = ?
      or bf_aft_rvs-line.state-level-total <= 0
      or bf_aft_rvs-line.state-level-water = ?
      or bf_aft_rvs-line.state-temperature = ?
      then do :
        if infoSecObj:AccMeth = 1
        and index(this-procedure:name, "in-ladd") > 0
        then do :
          message "Не заполнена сверка После!" view-as alert-box error .
        end .
        undo _trpomi, return error .
      end .
      if bf_bef_rvs-line.state-measure-cli-qnty = bf_aft_rvs-line.state-measure-cli-qnty
      then do :
        next place_ .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "temp-izm-vol"
      :
        v-temp-izm-vol2 = decimal(bf_rvs-line-attr.attr-value) .
      end .
      if bf_bef_rvs-line.state-level-water > 0
      then do :
        find last water1_pl-level no-lock where water1_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                            and water1_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                            and water1_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                            and water1_pl-level.pl-level <= bf_bef_rvs-line.state-level-water
                                            no-error .
        if available water1_pl-level
        then do :
          WaterDeltaV1 = ? .
          for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water1_pl-level.pl-code
                                                and buf_pl-level-attr.obj-code = water1_pl-level.obj-code
                                                and buf_pl-level-attr.obj-type = water1_pl-level.obj-type
                                                and buf_pl-level-attr.pl-level = water1_pl-level.pl-level
                                                and buf_pl-level-attr.attr-code = "deltaV"
                                                :
            WaterDeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
          end .
        end .
        if (available water1_pl-level
        and water1_pl-level.pl-level <> bf_bef_rvs-line.state-level-water)
        or bf_bef_rvs-line.state-level-water < 1
        then do :
          find first water2_pl-level no-lock where water2_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                               and water2_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                               and water2_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                               and water2_pl-level.pl-level >= bf_bef_rvs-line.state-level-water
                                               no-error .
          if available water2_pl-level
          then do :
            WaterDeltaV2 = ? .
            for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water2_pl-level.pl-code
                                                  and buf_pl-level-attr.obj-code = water2_pl-level.obj-code
                                                  and buf_pl-level-attr.obj-type = water2_pl-level.obj-type
                                                  and buf_pl-level-attr.pl-level = water2_pl-level.pl-level
                                                  and buf_pl-level-attr.attr-code = "deltaV"
                                                  :
              WaterDeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
            end .
          end .
        end .
      end .
      find last total1_pl-level no-lock where total1_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                          and total1_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                          and total1_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                          and total1_pl-level.pl-level <= bf_bef_rvs-line.state-level-total
                                          no-error .
      if not available total1_pl-level
      then do :
        if bf_bef_rvs-line.state-level-total >= 1
        then do :
          find first bf_goods no-lock where bf_goods.gds-code = bf_bef_rvs-line.gds-code no-error .
          message
            substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                       ,(if available buf_place then buf_place.loc1 else "?")
                       ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                       ,(if available bf_goods then bf_goods.gds-name else "?") )
          view-as alert-box .
          undo _trpomi, return .
        end .
      end .
      DeltaOtn_K = ? .
      for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                            and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                            and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                            and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                            and buf_pl-level-attr.attr-code = "tarir-delta"
                                            :
        DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) .
      end .
      if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .
      DeltaV1 = ? .
      for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                            and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                            and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                            and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                            and buf_pl-level-attr.attr-code = "deltaV"
                                            :
        DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
      end .
      find first total2_pl-level no-lock where total2_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                          and total2_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                          and total2_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                          and total2_pl-level.pl-level > bf_bef_rvs-line.state-level-total
                                          no-error .
      if not available total2_pl-level
      then do :
        find first bf_goods no-lock where bf_goods.gds-code = bf_bef_rvs-line.gds-code no-error .
        message
          substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                     ,(if available buf_place then buf_place.loc1 else "?")
                     ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                     ,(if available bf_goods then bf_goods.gds-name else "?") )
        view-as alert-box .
        undo _trpomi, return .
      end .
      DeltaV2 = ? .
      for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total2_pl-level.pl-code
                                            and buf_pl-level-attr.obj-code = total2_pl-level.obj-code
                                            and buf_pl-level-attr.obj-type = total2_pl-level.obj-type
                                            and buf_pl-level-attr.pl-level = total2_pl-level.pl-level
                                            and buf_pl-level-attr.attr-code = "deltaV"
                                            :
        DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
      end .
      if available water2_pl-level
      then do :
        CalibTable = Substitute("&1=&2", water2_pl-level.pl-level, (water2_pl-level.pl-qnty / 1000)) + (if WaterDeltaV2 > 0 then ("=" + trim(string(WaterDeltaV2, ">>9.9999"))) else "") + chr(10) + CalibTable .
      end .
      if available water1_pl-level
      then do :
        CalibTable = Substitute("&1=&2", water1_pl-level.pl-level, (water1_pl-level.pl-qnty / 1000)) + (if WaterDeltaV1 > 0 then ("=" + trim(string(WaterDeltaV1, ">>9.9999"))) else "") + chr(10) + CalibTable .
      end .
      if available total1_pl-level
      then do :
        CalibTable = CalibTable + Substitute("&1=&2", total1_pl-level.pl-level, (total1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + chr(10) .
      end .
      CalibTable = CalibTable + Substitute("&1=&2", total2_pl-level.pl-level, (total2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") + chr(10) .
      if bf_bef_rvs-line.state-level-total < 1
      or bf_bef_rvs-line.state-level-water < 1
      then do :
        find first buf_pl-level no-lock where buf_pl-level.pl-code  = bf_bef_rvs-line.pl-code
                                         and buf_pl-level.obj-code = bf_bef_rvs-line.obj-code
                                         and buf_pl-level.obj-type = bf_bef_rvs-line.obj-type
                                         and buf_pl-level.pl-level = 0
                                         no-error .
        if not available buf_pl-level
        then do :
          CalibTable = "0=0" + chr(10) + CalibTable .
        end .
      end .
      if bf_aft_rvs-line.state-level-water > 0
      and bf_aft_rvs-line.state-level-water <> bf_bef_rvs-line.state-level-water
      then do :
        find last water1_pl-level no-lock where water1_pl-level.pl-code  = bf_aft_rvs-line.pl-code
                                            and water1_pl-level.obj-code = bf_aft_rvs-line.obj-code
                                            and water1_pl-level.obj-type = bf_aft_rvs-line.obj-type
                                            and water1_pl-level.pl-level <= bf_aft_rvs-line.state-level-water
                                            no-error .
        if available water1_pl-level
        then do :
          WaterDeltaV1 = ? .
          for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water1_pl-level.pl-code
                                                and buf_pl-level-attr.obj-code = water1_pl-level.obj-code
                                                and buf_pl-level-attr.obj-type = water1_pl-level.obj-type
                                                and buf_pl-level-attr.pl-level = water1_pl-level.pl-level
                                                and buf_pl-level-attr.attr-code = "deltaV"
                                                :
            WaterDeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
          end .
        end .
        if (available water1_pl-level
        and water1_pl-level.pl-level <> bf_aft_rvs-line.state-level-water)
        or bf_aft_rvs-line.state-level-water < 1
        then do :
          find first water2_pl-level no-lock where water2_pl-level.pl-code  = bf_aft_rvs-line.pl-code
                                               and water2_pl-level.obj-code = bf_aft_rvs-line.obj-code
                                               and water2_pl-level.obj-type = bf_aft_rvs-line.obj-type
                                               and water2_pl-level.pl-level >= bf_aft_rvs-line.state-level-water
                                               no-error .
          if available water2_pl-level
          then do :
            WaterDeltaV2 = ? .
            for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water2_pl-level.pl-code
                                                  and buf_pl-level-attr.obj-code = water2_pl-level.obj-code
                                                  and buf_pl-level-attr.obj-type = water2_pl-level.obj-type
                                                  and buf_pl-level-attr.pl-level = water2_pl-level.pl-level
                                                  and buf_pl-level-attr.attr-code = "deltaV"
                                                  :
              WaterDeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
            end .
          end .
        end .
      end .
      find last total1_pl-level no-lock where total1_pl-level.pl-code  = bf_aft_rvs-line.pl-code
                                          and total1_pl-level.obj-code = bf_aft_rvs-line.obj-code
                                          and total1_pl-level.obj-type = bf_aft_rvs-line.obj-type
                                          and total1_pl-level.pl-level <= bf_aft_rvs-line.state-level-total
                                          no-error .
      if not available total1_pl-level
      then do :
        if bf_aft_rvs-line.state-level-total >= 1
        then do :
          find first bf_goods no-lock where bf_goods.gds-code = bf_aft_rvs-line.gds-code no-error .
          message
            substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                       ,(if available buf_place then buf_place.loc1 else "?")
                       ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                       ,(if available bf_goods then bf_goods.gds-name else "?") )
          view-as alert-box .
          undo _trpomi, return .
        end .
      end .
      DeltaOtn_K = ? .
      for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                            and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                            and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                            and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                            and buf_pl-level-attr.attr-code = "tarir-delta"
                                            :
        DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) .
      end .
      if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .
      DeltaV1 = ? .
      for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                            and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                            and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                            and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                            and buf_pl-level-attr.attr-code = "deltaV"
                                            :
        DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
      end .
      find first total2_pl-level no-lock where total2_pl-level.pl-code  = bf_aft_rvs-line.pl-code
                                          and total2_pl-level.obj-code = bf_aft_rvs-line.obj-code
                                          and total2_pl-level.obj-type = bf_aft_rvs-line.obj-type
                                          and total2_pl-level.pl-level > bf_aft_rvs-line.state-level-total
                                          no-error .
      if not available total2_pl-level
      then do :
        find first bf_goods no-lock where bf_goods.gds-code = bf_aft_rvs-line.gds-code no-error .
        message
          substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                     ,(if available buf_place then buf_place.loc1 else "?")
                     ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                     ,(if available bf_goods then bf_goods.gds-name else "?") )
        view-as alert-box .
        undo _trpomi, return .
      end .
      DeltaV2 = ? .
      for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total2_pl-level.pl-code
                                            and buf_pl-level-attr.obj-code = total2_pl-level.obj-code
                                            and buf_pl-level-attr.obj-type = total2_pl-level.obj-type
                                            and buf_pl-level-attr.pl-level = total2_pl-level.pl-level
                                            and buf_pl-level-attr.attr-code = "deltaV"
                                            :
        DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
      end .
      if available water2_pl-level
      then do :
        CalibTable = Substitute("&1=&2", water2_pl-level.pl-level, (water2_pl-level.pl-qnty / 1000)) + (if WaterDeltaV2 > 0 then ("=" + trim(string(WaterDeltaV2, ">>9.9999"))) else "") + chr(10) + CalibTable .
      end .
      if available water1_pl-level
      then do :
        CalibTable = Substitute("&1=&2", water1_pl-level.pl-level, (water1_pl-level.pl-qnty / 1000)) + (if WaterDeltaV1 > 0 then ("=" + trim(string(WaterDeltaV1, ">>9.9999"))) else "") + chr(10) + CalibTable .
      end .
      if available total1_pl-level
      then do :
        CalibTable = CalibTable + Substitute("&1=&2", total1_pl-level.pl-level, (total1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + chr(10) .
      end .
      CalibTable = CalibTable + Substitute("&1=&2", total2_pl-level.pl-level, (total2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "input-type-p"
      :
        if bf_rvs-line-attr.attr-value = "р"
        or bf_rvs-line-attr.attr-value = "ак"
        or bf_rvs-line-attr.attr-value = "фк"
        then do :
          pl-rvd-dens-1 = yes .
        end .
        else do :
          pl-rvd-dens-1 = no .
        end .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "input-type-p"
      :
        if bf_rvs-line-attr.attr-value = "р"
        or bf_rvs-line-attr.attr-value = "ак"
        or bf_rvs-line-attr.attr-value = "фк"
        then do :
          pl-rvd-dens-2 = yes .
        end .
        else do :
          pl-rvd-dens-2 = no .
        end .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "input-type-t"
      :
        if bf_rvs-line-attr.attr-value = "р"
        or bf_rvs-line-attr.attr-value = "ак"
        or bf_rvs-line-attr.attr-value = "фк"
        then do :
          pl-rvd-temp-1 = yes .
        end .
        else do :
          pl-rvd-temp-1 = no .
        end .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "input-type-t"
      :
        if bf_rvs-line-attr.attr-value = "р"
        or bf_rvs-line-attr.attr-value = "ак"
        or bf_rvs-line-attr.attr-value = "фк"
        then do :
          pl-rvd-temp-2 = yes .
        end .
        else do :
          pl-rvd-temp-2 = no .
        end .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "input-type-l"
      :
        if bf_rvs-line-attr.attr-value = "р"
        or bf_rvs-line-attr.attr-value = "ак"
        or bf_rvs-line-attr.attr-value = "фк"
        then do :
          pl-rvd-lvl-1 = yes .
        end .
        else do :
          pl-rvd-lvl-1 = no .
        end .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "input-type-l"
      :
        if bf_rvs-line-attr.attr-value = "р"
        or bf_rvs-line-attr.attr-value = "ак"
        or bf_rvs-line-attr.attr-value = "фк"
        then do :
          pl-rvd-lvl-2 = yes .
        end .
        else do :
          pl-rvd-lvl-2 = no .
        end .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "mi-lvl"
      :
        v-mi-lvl-1 = integer(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "mi-lvl"
      :
        v-mi-lvl-2 = integer(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "mi-dnst"
      :
        v-mi-dnst-1 = integer(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "mi-dnst"
      :
        v-mi-dnst-2 = integer(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "mi-tmp"
      :
        v-mi-tmp-1 = integer(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "mi-tmp"
      :
        v-mi-tmp-2 = integer(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "mi-tmp-dnst"
      :
        v-mi-tmp-dnst-1 = integer(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "mi-tmp-dnst"
      :
        v-mi-tmp-dnst-2 = integer(bf_rvs-line-attr.attr-value) .
      end .
      if pl-rvd-lvl-1 and v-mi-lvl-1 > 0 and pl-rvd-lvl-2 and v-mi-lvl-2 > 0
      and pl-rvd-dens-1 and v-mi-dnst-1 > 0 and pl-rvd-dens-2 and v-mi-dnst-2 > 0
      and pl-rvd-temp-1 and v-mi-tmp-1 > 0 and pl-rvd-temp-2 and v-mi-tmp-2 > 0
      then do : end .
      else do :
        if place-si = 0
        or place-si = ?
        then do :
          message
            substitute ("Для складского места &1 не заданно средство измерения",buf_place.pl-code)
          view-as alert-box error.
          undo _trpomi, return error.
        end.
        else do :
          find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si no-error.
          if not available buf_sr-izmerenia then do :
            message
            "Ошибка работы с библиотекой ПОкМИ"
            substitute( 'Не найдено средство измерения с кодом &1', place-si ) skip
            view-as alert-box error.
            undo _trpomi, return error.
          end.
          else do :
            assign
              ToolType1               = buf_sr-izmerenia.sr-type-id
              LevelToolType1          = buf_sr-izmerenia.sr-type-level-measuring
              ToolAutomationLevel_H1  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              ToolAutomationLevel_H_Water1 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_H1             = buf_sr-izmerenia.sr-abs-err-neft-water
              DeltaAbs_H_Water1       = buf_sr-izmerenia.sr-abs-err-water
              ToolAutomationLevel_R1  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_R1             = buf_sr-izmerenia.sr-abs-err-dens
              ToolAutomationLevel_Tv1 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_Tv1            = buf_sr-izmerenia.sr-abs-err-temp-vol
              ToolAutomationLevel_Tr1 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_Tr1            = buf_sr-izmerenia.sr-abs-err-temp-dens
              DeltaOtn_H1             = buf_sr-izmerenia.sr-relative-err-neft-water
              DeltaOtn_H_Water1       = buf_sr-izmerenia.sr-relative-err-water
              DeltaOtn_R1             = buf_sr-izmerenia.sr-relative-err-dens
              DeltaAbs_H_CalcType1    = buf_sr-izmerenia.sr-type-level-measuring + 1
              DeltaAbs_H_Water_CalcType1 = buf_sr-izmerenia.sr-type-level-measuring + 1
              ToolType2               = buf_sr-izmerenia.sr-type-id
              LevelToolType2          = buf_sr-izmerenia.sr-type-level-measuring
              ToolAutomationLevel_H2  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              ToolAutomationLevel_H_Water2 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_H2             = buf_sr-izmerenia.sr-abs-err-neft-water
              DeltaAbs_H_Water2       = buf_sr-izmerenia.sr-abs-err-water
              ToolAutomationLevel_R2  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_R2             = buf_sr-izmerenia.sr-abs-err-dens
              ToolAutomationLevel_Tv2 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_Tv2            = buf_sr-izmerenia.sr-abs-err-temp-vol
              ToolAutomationLevel_Tr2 = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
              DeltaAbs_Tr2            = buf_sr-izmerenia.sr-abs-err-temp-dens
              DeltaOtn_H2             = buf_sr-izmerenia.sr-relative-err-neft-water
              DeltaOtn_H_Water2       = buf_sr-izmerenia.sr-relative-err-water
              DeltaOtn_R2             = buf_sr-izmerenia.sr-relative-err-dens
              DeltaAbs_H_CalcType2    = buf_sr-izmerenia.sr-type-level-measuring + 1
              DeltaAbs_H_Water_CalcType2 = buf_sr-izmerenia.sr-type-level-measuring + 1
              DeltaOtn_N              = 0.05
            .
          end.
        end.
      end.
      if (pl-rvd-lvl-1
      and v-mi-lvl-1 > 0
      and v-mi-lvl-1 <> place-si)
      or not available buf_sr-izmerenia
      then do :
        find first level_sr-izmerenia no-lock where level_sr-izmerenia.node-code = v-mi-lvl-1 no-error.
        if not available level_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-lvl-1 ) skip
          view-as alert-box error.
          undo _trpomi, return error.
        end.
        else do :
          assign
            DeltaAbs_H1                  = level_sr-izmerenia.sr-abs-err-neft-water
            DeltaAbs_H_Water1            = level_sr-izmerenia.sr-abs-err-water
            DeltaOtn_H1                  = level_sr-izmerenia.sr-relative-err-neft-water
            DeltaOtn_H_Water1            = level_sr-izmerenia.sr-relative-err-water
            LevelToolType1               = level_sr-izmerenia.sr-type-level-measuring
            ToolAutomationLevel_H1       = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
            ToolAutomationLevel_H_Water1 = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_H_CalcType1         = level_sr-izmerenia.sr-type-level-measuring + 1
            DeltaAbs_H_Water_CalcType1   = level_sr-izmerenia.sr-type-level-measuring + 1
          .
        end.
      end .
      if (pl-rvd-lvl-2
      and v-mi-lvl-2 > 0
      and v-mi-lvl-2 <> place-si)
      or not available buf_sr-izmerenia
      then do :
        find first level_sr-izmerenia no-lock where level_sr-izmerenia.node-code = v-mi-lvl-2 no-error.
        if not available level_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-lvl-2 ) skip
          view-as alert-box error.
          undo _trpomi, return error.
        end.
        else do :
          assign
            DeltaAbs_H2                  = level_sr-izmerenia.sr-abs-err-neft-water
            DeltaAbs_H_Water2            = level_sr-izmerenia.sr-abs-err-water
            DeltaOtn_H2                  = level_sr-izmerenia.sr-relative-err-neft-water
            DeltaOtn_H_Water2            = level_sr-izmerenia.sr-relative-err-water
            LevelToolType2               = level_sr-izmerenia.sr-type-level-measuring
            ToolAutomationLevel_H2       = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
            ToolAutomationLevel_H_Water2 = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_H_CalcType2         = level_sr-izmerenia.sr-type-level-measuring + 1
            DeltaAbs_H_Water_CalcType2   = level_sr-izmerenia.sr-type-level-measuring + 1
          .
        end.
      end .
      if (pl-rvd-dens-1
      and v-mi-dnst-1 > 0
      and v-mi-dnst-1 <> place-si)
      or not available buf_sr-izmerenia
      then do :
        find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst-1 no-error.
        if not available dens_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-dnst-1 ) skip
          view-as alert-box error.
          undo _trpomi, return error.
        end.
        else do :
          assign
            ToolType1               = dens_sr-izmerenia.sr-type-id
            DeltaAbs_R1             = dens_sr-izmerenia.sr-abs-err-dens
            DeltaOtn_R1             = dens_sr-izmerenia.sr-relative-err-dens
            ToolAutomationLevel_R1  = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1]
          .
        end.
      end .
      if (pl-rvd-dens-2
      and v-mi-dnst-2 > 0
      and v-mi-dnst-2 <> place-si)
      or not available buf_sr-izmerenia
      then do :
        find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst-2 no-error.
        if not available dens_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-dnst-2 ) skip
          view-as alert-box error.
          undo _trpomi, return error.
        end.
        else do :
          assign
            ToolType2               = dens_sr-izmerenia.sr-type-id
            DeltaAbs_R2             = dens_sr-izmerenia.sr-abs-err-dens
            DeltaOtn_R2             = dens_sr-izmerenia.sr-relative-err-dens
            ToolAutomationLevel_R2  = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1]
          .
        end.
      end .
      if (pl-rvd-temp-1
      and v-mi-tmp-1 > 0
      and v-mi-tmp-1 <> place-si)
      or not available buf_sr-izmerenia
      then do :
        find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = v-mi-tmp-1 no-error.
        if not available temp_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-tmp-1 ) skip
          view-as alert-box error.
          undo _trpomi, return error.
        end.
        else do :
          assign
            DeltaAbs_Tv1            = temp_sr-izmerenia.sr-abs-err-temp-vol
            DeltaAbs_Tr1            = temp_sr-izmerenia.sr-abs-err-temp-dens
            ToolAutomationLevel_Tr1 = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
            ToolAutomationLevel_Tv1 = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
          .
        end.
      end .
      if (pl-rvd-temp-2
      and v-mi-tmp-2 > 0
      and v-mi-tmp-2 <> place-si)
      or not available buf_sr-izmerenia
      then do :
        find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = v-mi-tmp-2 no-error.
        if not available temp_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-tmp-2 ) skip
          view-as alert-box error.
          undo _trpomi, return error.
        end.
        else do :
          assign
            DeltaAbs_Tv2            = temp_sr-izmerenia.sr-abs-err-temp-vol
            DeltaAbs_Tr2            = temp_sr-izmerenia.sr-abs-err-temp-dens
            ToolAutomationLevel_Tr2 = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
            ToolAutomationLevel_Tv2 = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
          .
        end.
      end .
      if v-mi-tmp-dnst-1 > 0
      and v-mi-tmp-dnst-1 <> v-mi-tmp-1
      then do :
        for first temp-dens_sr-izmerenia no-lock where temp-dens_sr-izmerenia.node-code = v-mi-tmp-dnst-1 :
          assign
            DeltaAbs_Tr1 = temp-dens_sr-izmerenia.sr-abs-err-temp-dens when temp-dens_sr-izmerenia.sr-abs-err-temp-dens > 0
            ToolAutomationLevel_Tr1 = vAutomationDegree[temp-dens_sr-izmerenia.sr-type-izm + 1]
          .
        end .
      end .
      if v-mi-tmp-dnst-2 > 0
      and v-mi-tmp-dnst-2 <> v-mi-tmp-2
      then do :
        for first temp-dens_sr-izmerenia no-lock where temp-dens_sr-izmerenia.node-code = v-mi-tmp-dnst-2 :
          assign
            DeltaAbs_Tr2 = temp-dens_sr-izmerenia.sr-abs-err-temp-dens when temp-dens_sr-izmerenia.sr-abs-err-temp-dens > 0
            ToolAutomationLevel_Tr2 = vAutomationDegree[temp-dens_sr-izmerenia.sr-type-izm + 1]
          .
        end .
      end .
      CalibBelt = getCalibrationBelt( buf_place.obj-type,
                                      buf_place.obj-code,
                                      buf_place.pl-code,
                                      bf_bef_rvs-line.state-level-total,
                                      bf_bef_rvs-line.state-level-water
                                     ).
      CalibBelt = CalibBelt + chr(10) + getCalibrationBelt( buf_place.obj-type,
                                                                buf_place.obj-code,
                                                                buf_place.pl-code,
                                                                bf_aft_rvs-line.state-level-total,
                                                                bf_aft_rvs-line.state-level-water
                                                               ).
      if DeltaAbs_H1       = ? then DeltaAbs_H1 = 0 .
      if DeltaAbs_H_Water1 = ? then DeltaAbs_H_Water1 = 0 .
      if DeltaAbs_R1       = ? then DeltaAbs_R1 = 0 .
      if DeltaAbs_Tv1      = ? then DeltaAbs_Tv1 = 0 .
      if DeltaAbs_Tr1      = ? then DeltaAbs_Tr1 = 0 .
      if DeltaOtn_H1       = ? then DeltaOtn_H1 = 0 .
      if DeltaOtn_H_Water1 = ? then DeltaOtn_H_Water1 = 0 .
      if DeltaOtn_R1       = ? then DeltaOtn_R1 = 0 .
      if LevelToolType1    = ? then LevelToolType1 = 0 .
      if ToolType1         = ? then ToolType1 = 0 .
      if ToolAutomationLevel_Tr1      = ? then ToolAutomationLevel_Tr1 =0.
      if ToolAutomationLevel_H1       = ? then ToolAutomationLevel_H1 = 0.
      if ToolAutomationLevel_H_Water1 = ? then ToolAutomationLevel_H_Water1 = 0.
      if ToolAutomationLevel_Tv1      = ? then ToolAutomationLevel_Tv1 = 0.
      if ToolAutomationLevel_R1       = ? then ToolAutomationLevel_R1 = 0.
      if DeltaAbs_H_CalcType1         = ? then DeltaAbs_H_CalcType1 = 0.
      if DeltaAbs_H_Water_CalcType1   = ? then DeltaAbs_H_Water_CalcType1 = 0.
      if DeltaAbs_H2       = ? then DeltaAbs_H2 = 0 .
      if DeltaAbs_H_Water2 = ? then DeltaAbs_H_Water2 = 0 .
      if DeltaAbs_R2       = ? then DeltaAbs_R2 = 0 .
      if DeltaAbs_Tv2      = ? then DeltaAbs_Tv2 = 0 .
      if DeltaAbs_Tr2      = ? then DeltaAbs_Tr2 = 0 .
      if DeltaOtn_H2       = ? then DeltaOtn_H2 = 0 .
      if DeltaOtn_H_Water2 = ? then DeltaOtn_H_Water2 = 0 .
      if DeltaOtn_R2       = ? then DeltaOtn_R2 = 0 .
      if LevelToolType2    = ? then LevelToolType2 = 0 .
      if ToolType2         = ? then ToolType2 = 0 .
      if ToolAutomationLevel_Tr2      = ? then ToolAutomationLevel_Tr2 =0.
      if ToolAutomationLevel_H2       = ? then ToolAutomationLevel_H2 = 0.
      if ToolAutomationLevel_H_Water2 = ? then ToolAutomationLevel_H_Water2 = 0.
      if ToolAutomationLevel_Tv2      = ? then ToolAutomationLevel_Tv2 = 0.
      if ToolAutomationLevel_R2       = ? then ToolAutomationLevel_R2 = 0.
      if DeltaAbs_H_CalcType2         = ? then DeltaAbs_H_CalcType2 = 0.
      if DeltaAbs_H_Water_CalcType2   = ? then DeltaAbs_H_Water_CalcType2 = 0.
      if bf_bef_rvs-line.state-level-water = 0
      then do :
        ToolAutomationLevel_H_Water1 = 0 .
        DeltaAbs_H_Water_CalcType1 = 0 .
        DeltaAbs_H_Water1 = 0 .
      end .
      if bf_aft_rvs-line.state-level-water = 0
      then do :
        ToolAutomationLevel_H_Water2 = 0 .
        DeltaAbs_H_Water_CalcType2 = 0 .
        DeltaAbs_H_Water2 = 0 .
      end .
      if LevelToolType1 > 0
      then do :
        MM57
          (input bf_bef_rvs-line.state-level-total * 10,
           input LevelToolType1,
           output DeltaAbs_H1,
           output vErr,
           output vWrn,
           output vDllVersion)
        .
        OUTPUT stream outstream to value ("pomi.log") append.
        PUT STREAM outstream unformatted
                    "    " SKIP
                    "    " SKIP
                    cur-time-string()           FORMAT "x(16)"    SKIP
                    'Процедура             "CMethodOfMetering57"'       SKIP
                    'Версия dll: '            vDllVersion   skip
                    'CODE_PL                = ' buf_place.pl-code                           SKIP
                    'H                      = ' bf_bef_rvs-line.state-level-total * 10                  SKIP
                    'ToolType               = ' LevelToolType1                                      SKIP
                        SKIP SKIP
        .
        output stream outstream close.
        if trim(vErr) > "" then do :
          output stream outstream to value ("pomi.log")  append.
          put stream outstream vErr format "X(1024)" skip.
          output stream outstream close.
          message substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) view-as alert-box .
          undo _trpomi, return error .
        end.
        else do :
          OUTPUT stream outstream to value ("pomi.log")  append.
          PUT STREAM outstream unformatted
              "DeltaAbs_H = " DeltaAbs_H1  SKIP
          .
          OUTPUT stream outstream close.
        end .
      end .
      if LevelToolType2 > 0
      then do :
        MM57
          (input bf_aft_rvs-line.state-level-total * 10,
           input LevelToolType2,
           output DeltaAbs_H2,
           output vErr,
           output vWrn,
           output vDllVersion)
        .
        OUTPUT stream outstream to value ("pomi.log") append.
        PUT STREAM outstream unformatted
                    "    " SKIP
                    "    " SKIP
                    cur-time-string()           FORMAT "x(16)"    SKIP
                    'Процедура             "CMethodOfMetering57"'       SKIP
                    'Версия dll: '            vDllVersion   skip
                    'CODE_PL                = ' buf_place.pl-code                           SKIP
                    'H                      = ' bf_aft_rvs-line.state-level-total * 10                  SKIP
                    'ToolType               = ' LevelToolType2                                      SKIP
                        SKIP SKIP
        .
        output stream outstream close.
        if trim(vErr) > "" then do :
          output stream outstream to value ("pomi.log")  append.
          put stream outstream vErr format "X(1024)" skip.
          output stream outstream close.
          message substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) view-as alert-box .
          undo _trpomi, return error .
        end.
        else do :
          OUTPUT stream outstream to value ("pomi.log")  append.
          PUT STREAM outstream unformatted
              "DeltaAbs_H = " DeltaAbs_H2  SKIP
          .
          OUTPUT stream outstream close.
        end .
      end .
      assign
        Tr1 = bf_bef_rvs-line.state-temperature
        Tv1 = if v-temp-izm-vol1 <> ? then v-temp-izm-vol1 else bf_bef_rvs-line.state-temperature
        R1  = ( bf_bef_rvs-line.state-density * 1000 )
        Tr2 = bf_aft_rvs-line.state-temperature
        Tv2 = if v-temp-izm-vol2 <> ? then v-temp-izm-vol2 else bf_aft_rvs-line.state-temperature
        R2  = ( bf_aft_rvs-line.state-density * 1000 )
      .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "Tr"
      :
        assign Tr1 = decimal(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "Tv"
      :
        assign Tv1 = decimal(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_bef_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_bef_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_bef_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_bef_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_bef_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "R"
      :
        assign R1 = decimal(bf_rvs-line-attr.attr-value) * 1000 .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "Tr"
      :
        assign Tr2 = decimal(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "Tv"
      :
        assign Tv2 = decimal(bf_rvs-line-attr.attr-value) .
      end .
      for first bf_rvs-line-attr no-lock where bf_rvs-line-attr.rvs-code  = bf_aft_rvs-line.rvs-code
                                           and bf_rvs-line-attr.obj-code  = bf_aft_rvs-line.obj-code
                                           and bf_rvs-line-attr.obj-type  = bf_aft_rvs-line.obj-type
                                           and bf_rvs-line-attr.gds-code  = bf_aft_rvs-line.gds-code
                                           and bf_rvs-line-attr.pl-code   = bf_aft_rvs-line.pl-code
                                           and bf_rvs-line-attr.attr-code = "R"
      :
        assign R2 = decimal(bf_rvs-line-attr.attr-value) * 1000 .
      end .
      if v-proc = "CMethodOfMetering14"
      then do :
        MM14
        (input bf_bef_rvs-line.state-measure-cli-qnty,
         input bf_aft_rvs-line.state-measure-cli-qnty,
         input bf_bef_rvs-line.state-level-total * 10,
         input bf_aft_rvs-line.state-level-total * 10,
         input if bf_bef_rvs-line.state-level-water <> ? then bf_bef_rvs-line.state-level-water * 10 else 0.0,
         input if bf_aft_rvs-line.state-level-water <> ? then bf_aft_rvs-line.state-level-water * 10 else 0.0,
         input CalibTable,
         input CalibBelt,
         input Tv1,
         input Tv2,
         input Tr1,
         input Tr2,
         input R1,
         input R2,
         input ToolType1,
         input ToolType2,
         input DeltaOtn_K,
         input 2,
         input ToolAutomationLevel_H1,
         input ToolAutomationLevel_H2,
         input ToolAutomationLevel_H_Water1,
         input ToolAutomationLevel_H_Water2,
         input ToolAutomationLevel_R1,
         input ToolAutomationLevel_R2,
         input ToolAutomationLevel_Tv1,
         input ToolAutomationLevel_Tv2,
         input ToolAutomationLevel_Tr1,
         input ToolAutomationLevel_Tr2,
         input DeltaAbs_H_CalcType1,
         input DeltaAbs_H_CalcType2,
         input DeltaAbs_H_Water_CalcType1,
         input DeltaAbs_H_Water_CalcType2,
         input DeltaAbs_H1,
         input DeltaAbs_H2,
         input DeltaAbs_H_Water1,
         input DeltaAbs_H_Water2,
         input DeltaAbs_R1,
         input DeltaAbs_R2,
         input DeltaAbs_Tv1,
         input DeltaAbs_Tv2,
         input DeltaAbs_Tr1,
         input DeltaAbs_Tr2,
         input DeltaOtn_N,
         input 1,
         input 2,
         input 2,
         output V_total1,
         output V_total2,
         output V_water1,
         output V_water2,
         output Delta_V1,
         output Delta_V2,
         output M,
         output DeltaOtn_M,
         output vErr,
         output vWrn,
         output vDllVersion)
        no-error .
      end .
      else do :
        MM7
        (input bf_bef_rvs-line.state-measure-cli-qnty,
         input bf_aft_rvs-line.state-measure-cli-qnty,
         input bf_bef_rvs-line.state-level-total * 10,
         input bf_aft_rvs-line.state-level-total * 10,
         input if bf_bef_rvs-line.state-level-water <> ? then bf_bef_rvs-line.state-level-water * 10 else 0.0,
         input if bf_aft_rvs-line.state-level-water <> ? then bf_aft_rvs-line.state-level-water * 10 else 0.0,
         input CalibTable,
         input CalibBelt,
         input Tv1,
         input Tv2,
         input Tr1,
         input Tr2,
         input R1,
         input R2,
         input ToolType1,
         input ToolType2,
         input DeltaOtn_K,
         input 2,
         input ToolAutomationLevel_H1,
         input ToolAutomationLevel_H2,
         input ToolAutomationLevel_H_Water1,
         input ToolAutomationLevel_H_Water2,
         input ToolAutomationLevel_R1,
         input ToolAutomationLevel_R2,
         input ToolAutomationLevel_Tv1,
         input ToolAutomationLevel_Tv2,
         input ToolAutomationLevel_Tr1,
         input ToolAutomationLevel_Tr2,
         input DeltaAbs_H_CalcType1,
         input DeltaAbs_H_CalcType2,
         input DeltaAbs_H_Water_CalcType1,
         input DeltaAbs_H_Water_CalcType2,
         input DeltaAbs_H1,
         input DeltaAbs_H2,
         input DeltaAbs_H_Water1,
         input DeltaAbs_H_Water2,
         input DeltaAbs_R1,
         input DeltaAbs_R2,
         input DeltaAbs_Tv1,
         input DeltaAbs_Tv2,
         input DeltaAbs_Tr1,
         input DeltaAbs_Tr2,
         input DeltaOtn_N,
         input 1,
         input 2,
         input 2,
         output V_total1,
         output V_total2,
         output V_water1,
         output V_water2,
         output Delta_V1,
         output Delta_V2,
         output M,
         output DeltaOtn_M,
         output vErr,
         output vWrn,
         output vDllVersion)
        no-error .
      end .
      output stream outstream to value ("pomi.log") append.
      put stream outstream unformatted
        "    " SKIP
        "    " SKIP
        cur-time-string()           FORMAT "x(16)"    SKIP
        'Процедура'                 v-proc                      FORMAT "x(128)"    SKIP
        'Версия dll: '              vDllVersion                            SKIP
        'CODE_PL                      = ' buf_place.pl-code                        SKIP
        'M1                           = ' bf_bef_rvs-line.state-measure-cli-qnty  SKIP
        'M2                           = ' bf_aft_rvs-line.state-measure-cli-qnty  SKIP
        'H1                           = ' bf_bef_rvs-line.state-level-total * 10  SKIP
        'H2                           = ' bf_aft_rvs-line.state-level-total * 10  SKIP
        'H1_water                     = ' if bf_bef_rvs-line.state-level-water <> ? then bf_bef_rvs-line.state-level-water * 10 else 0.0 SKIP
        'H2_water                     = ' if bf_aft_rvs-line.state-level-water <> ? then bf_aft_rvs-line.state-level-water * 10 else 0.0 SKIP
        'CalibrationTable             = ' CalibTable                    SKIP
        'CalibrationBelt              = ' CalibBelt                     SKIP
        'Tv1                          = ' Tv1                                 SKIP
        'Tv2                          = ' Tv2                                 SKIP
        'Tr1                          = ' Tr1                                 SKIP
        'Tr2                          = ' Tr2                                 skip
        'R1                           = ' trim(string(R1, ">>>9.9<"))         SKIP
        'R2                           = ' trim(string(R2, ">>>9.9<"))         SKIP
        'ToolType1                    = ' ToolType1                           SKIP
        'ToolType2                    = ' ToolType2                           SKIP
        'DeltaOtn_K                   = ' DeltaOtn_K                          SKIP
        'OperDirection                = ' 2                                   SKIP
        'ToolAutomationLevel_H1       = ' ToolAutomationLevel_H1              SKIP
        'ToolAutomationLevel_H2       = ' ToolAutomationLevel_H2              SKIP
        'ToolAutomationLevel_H_Water1 = ' ToolAutomationLevel_H_Water1        SKIP
        'ToolAutomationLevel_H_Water2 = ' ToolAutomationLevel_H_Water2        SKIP
        'ToolAutomationLevel_R1       = ' ToolAutomationLevel_R1              SKIP
        'ToolAutomationLevel_R2       = ' ToolAutomationLevel_R2              SKIP
        'ToolAutomationLevel_Tv1      = ' ToolAutomationLevel_Tv1             SKIP
        'ToolAutomationLevel_Tv2      = ' ToolAutomationLevel_Tv2             SKIP
        'ToolAutomationLevel_Tr1      = ' ToolAutomationLevel_Tr1             SKIP
        'ToolAutomationLevel_Tr2      = ' ToolAutomationLevel_Tr2             SKIP
        'DeltaAbs_H_CalcType1         = ' DeltaAbs_H_CalcType1                SKIP
        'DeltaAbs_H_CalcType2         = ' DeltaAbs_H_CalcType2                SKIP
        'DeltaAbs_H_Water_CalcType1   = ' DeltaAbs_H_Water_CalcType1          SKIP
        'DeltaAbs_H_Water_CalcType2   = ' DeltaAbs_H_Water_CalcType2          SKIP
        'DeltaAbs_H1                  = ' DeltaAbs_H1                         SKIP
        'DeltaAbs_H2                  = ' DeltaAbs_H2                         SKIP
        'DeltaAbs_H_Water1            = ' DeltaAbs_H_Water1                   SKIP
        'DeltaAbs_H_Water2            = ' DeltaAbs_H_Water2                   SKIP
        'DeltaAbs_R1                  = ' DeltaAbs_R1                         SKIP
        'DeltaAbs_R2                  = ' DeltaAbs_R2                         SKIP
        'DeltaAbs_Tv1                 = ' DeltaAbs_Tv1                        SKIP
        'DeltaAbs_Tv2                 = ' DeltaAbs_Tv2                        SKIP
        'DeltaAbs_Tr1                 = ' DeltaAbs_Tr1                        SKIP
        'DeltaAbs_Tr2                 = ' DeltaAbs_Tr2                        SKIP
        'DeltaOtn_N                   = ' DeltaOtn_N                          SKIP
      .
      output stream outstream close.
      if trim(vErr) > "" then do :
        error-string = vErr .
        output stream outstream to value ("pomi.log")  append.
        put stream outstream error-string format "X(1024)" skip.
        error-string = replace(error-string, ";", (";" + chr(10))) .
        message
        substitute('Ошибка работы библиотеки ПОкМИ. &1&2', chr(10), error-string)
        view-as alert-box error.
        output stream outstream close .
        undo _trpomi, return error .
      end.
      output stream outstream to value ("pomi.log") append.
      if not (M = 0.0)
      then do :
        put stream outstream unformatted
          'V_total1                   = ' V_total1                          SKIP
          'V_total2                   = ' V_total2                          SKIP
          'V_water1                   = ' V_water1                          SKIP
          'V_water2                   = ' V_water2                          SKIP
          'Delta_V1                   = ' Delta_V1                          SKIP
          'Delta_V2                   = ' Delta_V2                          SKIP
          'M                          = ' M                                 SKIP
          'DeltaOtn_M                 = ' DeltaOtn_M                        SKIP
          'Warnings                   = ' vWrn                              SKIP
        .
      end .
      else do :
        put stream outstream unformatted
          'V_total1                   = ' V_total1                          SKIP
          'V_total2                   = ' V_total2                          SKIP
          'V_water1                   = ' V_water1                          SKIP
          'V_water2                   = ' V_water2                          SKIP
          'Delta_V1                   = ' Delta_V1                          SKIP
          'Delta_V2                   = ' Delta_V2                          SKIP
          'M                          = ' M                                 SKIP
          'DeltaOtn_M                 = ' "?"                               SKIP
          'Warnings                   = ' vWrn                              SKIP
        .
      end .
      output stream outstream close.
      assign
        p-tank-weight-rvs   = p-tank-weight-rvs + M
        p-tank-vol-pomi-rvs = p-tank-vol-pomi-rvs + (((V_total2 - V_water2) - (V_total1 - V_water1)) * 1000)
        v-avg-temp          = v-avg-temp + ((bf_bef_rvs-line.state-temperature + bf_aft_rvs-line.state-temperature) / 2)
      .
      assign v-warnings = (if v-warnings = "" then vWrn else v-warnings + chr(10) + vWrn) .
    end .
    assign v-avg-temp = v-avg-temp / num-entries(v-pl-code-list) .
    infoSecObj:TankWeightRvs = p-tank-weight-rvs .
    infoSecObj:TankVolPomiRvs = p-tank-vol-pomi-rvs .
    infoSecObj:AvgTempRvs = v-avg-temp .
    infoSecObj:PokmiWarningsRVS = v-warnings .
  end .
end procedure .
define buffer type-inp-vat-attr for ub.doc-line-attr.
define buffer bf_sysconf        for ub.sysconf.
define buffer buf_rvs-doc   for ub.rvs-doc .
define buffer d-l-b         for ub.doc-line.
define buffer bf-trn-doc    for ub.trn-doc.
define buffer next_doc-pl   for ub.doc-pl.
define buffer sep_auto-tank-attr  for ub.auto-tank-attr.
define buffer bf_place for ub.place .
define temp-table old-doc-line no-undo like ub.doc-line.
define temp-table tt-rvs-line  no-undo like ub.rvs-line.
define variable chg-qnty                    like ub.gds-dtl.doc-qnty         no-undo.
define variable custvalue                   as   character initial ?         no-undo.
define variable custtype                    as   character initial ?         no-undo.
define variable prtvalue                    as   character initial ?         no-undo.
define variable prttype                     as   character initial ?         no-undo.
define variable vat-sumvalue                as   character initial ?         no-undo.
define variable vat-sumtype                 as   character initial ?         no-undo.
define variable v-insalepr                  as   logical   initial ?         no-undo.
define variable v-attr-type                 as   character                   no-undo.
define variable v-attr-value                as   character                   no-undo.
define variable rdtaxcdvalue                as   character initial ?         no-undo.
define variable exctaxcdvalue               as   character initial ?         no-undo.
define variable vattaxcdvalue               as   character initial ?         no-undo.
define variable pr-genmrg                   as   character initial ?         no-undo.
define variable pr-naklvalue                as   logical                     no-undo.
define variable pr-nakltype                 as   character initial ?         no-undo.
define variable temp-mes                    as   character initial ?         no-undo.
define variable varroad-tax-label           as   character                   no-undo.
define variable is-petrolium                as   logical                     no-undo.
define variable is-pieces                   as   logical                     no-undo.
define variable v-ptrl-without-rvs          as   character                   no-undo.
define variable v-gds-ptrl-densities        as   character                   no-undo.
define variable v-min-dens                  as   decimal                     no-undo.
define variable v-max-dens                  as   decimal                     no-undo.
define variable dops                        as   character                   no-undo format "x(250)":U.
define variable dopst                       as   character                   no-undo format "x(1)":U.
define variable dop-slt                     as   character                   no-undo format "x(250)":U.
define variable dop-slt-st                  as   character                   no-undo format "x(1)":U.
define variable sum-vat                     like ub.doc-line.price-rubl      no-undo format "->>>,>>>,>>>,>>>,>>9.99":U.
define variable varrvs-place                as   logical                     no-undo.
define variable var-code-temp               like ub.place.pl-code            no-undo.
define variable rvs-recid                   as   recid                       no-undo.
define variable road-tax-cli                like ub.doc-line.road-tax        no-undo initial 0.
define variable parprice-sale               like ub.price-list.price-sale    no-undo.
define variable parprice-prod               as   decimal                     no-undo.
define variable parprice-prod-vat           as   decimal                     no-undo.
define variable varext-gds-type             as   character      initial ?    no-undo.
define variable varcli-qnty-input           as   logical        initial ?    no-undo.
define variable vardensity-input            as   logical        initial ?    no-undo.
define variable varcli-base-rate-input      as   logical        initial ?    no-undo.
define variable vardoc-qnty-input           as   logical        initial ?    no-undo.
define variable varfact-qnty-input          as   logical        initial ?    no-undo.
define variable varprice-cli-input          as   logical        initial ?    no-undo.
define variable varbase-price-input         as   logical        initial ?    no-undo.
define variable vartax-3-input              as   logical        initial ?    no-undo.
define variable varcli-qnty-calc            as   character      initial ?    no-undo.
define variable vardensity-calc             as   character      initial ?    no-undo.
define variable varcli-base-rate-calc       as   character      initial ?    no-undo.
define variable vardoc-qnty-calc            as   character      initial ?    no-undo.
define variable varfact-qnty-calc           as   character      initial ?    no-undo.
define variable vardensity-ist              as   decimal        initial ?    no-undo.
define variable varprice-cli-calc           as   character      initial ?    no-undo.
define variable varbase-price-calc          as   character      initial ?    no-undo.
define variable vartax-3-calc               as   character      initial ?    no-undo.
define variable varround                    as   integer        initial 3    no-undo.
define variable varprice-cli                like ub.doc-line.price-rubl      no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl      no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl      no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl      no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl      no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl      no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl      no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl      no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl      no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl      no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl      no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl      no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl      no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl      no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl      no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl      no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl      no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl      no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl      no-undo.
define variable varprice-base               like ub.doc-line.price-base      no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base      no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base      no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base      no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base      no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base      no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base      no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base      no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base      no-undo.
define variable v-clcdoc-vat-pc             like ub.doc-line.vat-pc          no-undo.
define variable v-clcdoc-slt-pc             like ub.doc-line.slt-pc          no-undo.
define variable v-clcdoc-have-slt-pc        like ub.doc-line.slt-pc          no-undo.
define variable v-clcdoc-host-code          like ub.sysconf.host-code        no-undo.
define variable vargds-obj-fact-qnty        like ub.gds-obj.fact-qnty        no-undo label "Остаток".
define variable vargds-obj-price-sale       like ub.gds-obj.price-sale       no-undo label "ПродЦена".
define variable vargds-obj-pc-ov            as   decimal label "Наценка"     no-undo format "->>>,>>9.99%":U.
define variable vargds-obj-last-rubl        like ub.gds-obj.last-rubl        no-undo label "ПрихЦена".
define variable vargds-obj-cli-type         like ub.clients.obj-type         no-undo label "Последний поставщик".
define variable vargds-obj-cli-code         like ub.clients.obj-code         no-undo.
define variable vargds-obj-cli-name         as   character format "x(50)":U  no-undo.
define variable varr-b                      as   character                   no-undo.
define variable par-type                    as   character                   no-undo.
define variable rec-inv-line                as   recid                       no-undo.
define variable varlog                      as   logical                     no-undo.
define variable prt-mode                    as   character                   no-undo.
define variable varalc-prod                 as   character                   no-undo.
define variable is-density-ok               as   logical                     no-undo.
define variable v-hold-doc                  as   logical                     no-undo.
define variable v-change                    as   logical                     no-undo.
define variable v-car-num                   as   character                   no-undo.
define variable v-car-vol                   as   character                   no-undo.
define variable v-autoent-obj-type          as   character                   no-undo.
define variable v-autoent-obj-code          as   character                   no-undo.
define variable v-fio                       as   character                   no-undo.
define variable v-ptbotype                  as   character                   no-undo.
define variable v-ptbocode                  as   character                   no-undo.
define variable v-value-character           as   character                   no-undo.
define variable v-value-date                as   date                        no-undo.
define variable v-value-decimal             as   decimal                     no-undo.
define variable v-value-integer             as   integer                     no-undo.
define variable v-value-logical             as   logical                     no-undo.
define variable v-vat-goods                 as   logical                     no-undo.
define variable v-round-vat-sum             as logical                       no-undo .
define variable v-goods-ms-base             as decimal format ">>,>>9.999"   no-undo .
define variable rvslog                      as logical                       no-undo.
define variable varvalue                    as character                     no-undo .
define variable vartype                     as character                     no-undo .
define variable isEgais                     as logical                       no-undo .
define variable v-vid-action                as integer                       no-undo .
define variable v-vid-param                 as longchar                      no-undo .
define variable v-edit-fact-wayb            as logical                       no-undo .
define variable fq                          as character                     no-undo.
define variable cq                          as character                     no-undo.
define variable v-gds-null-price            as logical                       no-undo .
define variable is-fuel                     as logical                       no-undo .
define variable v-specif-unit-list          as character no-undo .
define variable v-specif-cli-base-rate      as decimal no-undo .
define variable l-repeat-asi                as logical                       no-undo .
define variable m-repeat-asi                as character                     no-undo.
define variable v-is-lgas                   as logical                       no-undo.
define variable v-is-lgas-corr              as logical                       no-undo.
define variable v-lgas-gds                  as logical                       no-undo.
define variable v-tth             as handle    no-undo.
define variable v-Param-Type      as character no-undo.
define variable list-pl           as character no-undo.
define variable infoSecObj        as class ibs.th.str.InfoSection no-undo .
define variable l-ok as logical   no-undo .
define variable ii as integer no-undo .
define variable disable-rvs as logical no-undo init no .
define variable isKPrvs as logical no-undo .
define variable v-KPrvs-secs      as character no-undo .
define variable v-KPrvs-doc-pl    as logical   no-undo .
define rectangle rect-tot  edge-pixels 2 graphic-edge size 99 by 1.5 bgcolor 8 dcolor 5.
define rectangle rect-tax1 edge-pixels 2 graphic-edge size 40 by 2.9 bgcolor 8 dcolor 5.
define rectangle rect-tax2 edge-pixels 2 graphic-edge size 61 by 2.9 bgcolor 8 dcolor 5.
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
DEFINE IMAGE g-image
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 18.75 BY 6.25.
DEFINE BUTTON b-choose-last-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-last-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".
DEFINE BUTTON b-corr-price-sale
     IMAGE-UP FILE "cmp/check.bmp":U
     IMAGE-DOWN FILE "cmp/check.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/check.bmp":U
     LABEL ""
     SIZE 2 BY 1 TOOLTIP "Была корректировка продажной цены".
define button b-save auto-go
     label "&Сохранить":l
     size 10 by 1.
define button b-quit auto-end-key
     label "Отмена":l
     size 10 by 1.
define button b-prt
     label "&Шкала":l
     size 10 by 1.
define button b-parts
   label "Пар&тии":l
   size 10 by 1.
define button b-help
   label "Помо&щь":l
   size 3 by 1.
define button b-exit-cycl
    label "СтопЦикл":l
    size 10 by 1.
define button b-rvs-bf
    label "Св.до"
    size 12 by 1.2.
define button b-rvs-af
    label "Св.после"
    size 12 by 1.2.
define menu m-rvs-bf
    menu-item m-rvs-bf-1 label "Сверка резервуара"  accelerator "alt-1"
    menu-item m-rvs-bf-2 label "Просмотр"           accelerator "alt-2"
    menu-item m-rvs-bf-3 label "Редактирование"     accelerator "alt-3".
define button b-addinf
    label "Доп.инф."
    size 10 by 1.
define button b-docsec
    label "По сек."
    size 9 by 1.
define button b-alc-attr
    label "АлкАтр"
    size 9 by 1 TOOLTIP "Атрибуты алкогольной продукции".
define button b-place label "Место &хр."
    size 10 by 1 tooltip "Список мест хранения".
define button r-dog
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.
define button r-country
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88  TOOLTIP "Выбрать страну".
define menu m-rvs-af
    menu-item m-rvs-af-1 label "Сверка резервуара"  accelerator "alt-1"
    menu-item m-rvs-af-2 label "Просмотр"           accelerator "alt-2"
    menu-item m-rvs-af-3 label "Редактирование"     accelerator "alt-3".
define button r-units
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.
define variable tot-base as decimal format "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 30 by 1 no-undo.
define variable tot-rubl as decimal format "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 30 by 1 no-undo.
define variable prt-doc as decimal format "->>,>>>,>>9.999":u initial 0
     label "Шкала"
     view-as fill-in
     size 16 by 1 no-undo.
define variable prt-fact as decimal format "->>,>>>,>>9.999":u initial 0
     label "Факт"
     view-as fill-in
     size 16 by 1 no-undo.
define variable cb-connect-hoses as character init ""
   LABEL "Подключение рукавов при приеме СУГ"
   VIEW-AS COMBO-BOX INNER-LINES 3
   LIST-ITEM-PAIRS "","empty",
   "Подключение рукавов было","yes",
   "Подключение рукавов не было","no"
   DROP-DOWN-LIST
   SIZE 31.5 BY 1 NO-UNDO.
define variable abr-rb as character format "x(3)":u no-undo .
define variable abr-rb2 as character format "x(3)":u no-undo .
define frame d-in-line
  tt-fr-doc-line.artic                 at row 1    col 15    colon-aligned label "&Артикул"           view-as fill-in size 18    by 1
  tt-fr-doc-line.gds-name              at row 1    col 35    colon-aligned no-label                   view-as text    size 48    by 1 fgcolor 4
  varalc-prod                          at row 1    col 86                  no-label                   view-as text    size 2     by 1 fgcolor 4
  tt-fr-doc-line.prod-code             at row 2    col 16    colon-aligned label "&Производитель"     view-as fill-in size 7     by 1
  tt-fr-doc-line.prod-type             at row 2    col 22    colon-aligned no-label                   view-as fill-in size 11.63 by 1
  tt-fr-doc-line.obj-name              at row 2    col 30    colon-aligned format "x(30)" no-label                   view-as text    size 35    by 1 fgcolor 4
  tt-fr-doc-line.last-date             at row 2    col 70    colon-aligned format "99/99/9999" label "Годен до"
  b-choose-last-date                   AT ROW 2    COL 83
  tt-fr-doc-line.last-num-day          at row 2    col 86    format "->>>>9" no-label
  tt-fr-doc-line.cli-art               at row 3    col 21    colon-aligned label "Артикул поставщика"   format "x(16)"
  v-goods-ms-base                      at row 3    col 42    label "Объем штуки"                                               fgcolor 4
  tt-fr-doc-line.alpha1                at row 3    col 77    colon-aligned label "Страна"             view-as text    size 4    by 0.7
  r-country                            at row 3    col 83
  tt-fr-doc-line.short-name            at row 3    col 85    colon-aligned no-label                   view-as text    size 10    by 0.7 fgcolor 4
  tt-fr-doc-line.cli-qnty              at row 5    col 10.5  colon-aligned label "По &ТТН"            view-as fill-in size 16    by 1 fgcolor 4 format "->>,>>>,>>9.999":U
  tt-fr-doc-line.unit-cli              at row 5    col 26.5  colon-aligned no-label                   view-as fill-in size 7     by 1 fgcolor 4
  r-units                              at row 5    col 35.5                no-label
  tt-fr-doc-line.cst-code              at row 5    col 55    colon-aligned label "ГТД" FORMAT "X(31)"
  tt-fr-doc-line.doc-density           at row 6    col 10.5  colon-aligned format    ">>9.9999999999" label "Плотность"          VIEW-AS FILL-IN SIZE 16 BY 1 fgcolor 4
  tt-fr-doc-line.temperature           at row 6    col 30    colon-aligned format    "->9.99"         label "Т"                  VIEW-AS FILL-IN SIZE 7  BY 1 fgcolor 4
  tt-fr-doc-line.cli-base-rate         at row 6    col 40    colon-aligned format ">>,>>9.9999999999" no-label                   VIEW-AS FILL-IN SIZE 18 BY 1
  tt-fr-doc-line.doc-qnty  format ">>>,>>>,>>9.<<<"  at row 7    col 10.5  colon-aligned label "По &накл"           view-as fill-in size 16    by 1
  tt-fr-doc-line.unit-base             at row 7    col 26.5  colon-aligned no-label                   view-as text    size 7     by 1
  b-docsec                             at row 7    col 32
  tt-fr-doc-line.fact-qnty    format ">>>,>>>,>>9.<<<"  at row 8    col 10.5  colon-aligned    label "&Факт"           view-as fill-in size 16    by 1
  tt-fr-doc-line.fact-density format ">>9.9999999999"   at row 8    col 27.0  colon-aligned no-label                   view-as fill-in size 16    by 1
  tt-fr-doc-line.fact-qnty-kg format ">>>,>>>,>>9.<<<"  at row 8    col 42.5  colon-aligned no-label                   view-as fill-in size 16    by 1
  tt-fr-doc-line.vat-pc                 at row 8    col 64    colon-aligned
  tt-fr-doc-line.type-inp-vat           at row 8    col 73    no-label                   view-as toggle-box size 2 by 1
  tt-fr-doc-line.slt-pc                 at row 9    col 50    colon-aligned
  tt-fr-doc-line.price-cli              at row 12   col 15    colon-aligned label "П&о ТТН" format "->>,>>>,>>>,>>9.9999999999" view-as fill-in size 20 by 1  fgcolor 4
  tt-fr-doc-line.price-base             at row 13   col 15    colon-aligned label "Учет"    format ">>,>>>,>>>,>>9.999"           view-as fill-in size 20    by 1
  tt-fr-doc-line.price-rubl             at row 14   col 15    colon-aligned label "Учет"               view-as fill-in size 20    by 1
  tt-fr-doc-line.new-price-sale         at row 15   col 50    colon-aligned label "Новая цена продажи" format ">>>,>>>,>>>,>>9.99" view-as fill-in size 15    by 1  fgcolor 4
  tt-fr-doc-line.price-prod             at row 16   col 21    colon-aligned label "Цена Производителя" format ">>>,>>>,>>>,>>9.99" view-as fill-in size 18    by 1  fgcolor 4
  tt-fr-doc-line.price-prod-vat         at row 16   col 52    colon-aligned label "Цена с НДС" format ">>>,>>>,>>>,>>9.99" view-as fill-in size 18    by 1  fgcolor 4
  tt-fr-doc-line.num-place              at row 16.2 col 1.5                 label "Кол-во мест"
  tt-fr-doc-line.wt-brutto              at row 16.2 col 68
  tt-fr-doc-line.road-tax               at row 16   col 2 fgcolor 4
  tt-fr-doc-line.excise                 at row 17   col 3 label "Акциз"                                               fgcolor 4
  tt-fr-doc-line.transport-base         at row 16   col 50    colon-aligned label "Тр.расх."                                    fgcolor 4
  tt-fr-doc-line.other-base             at row 17   col 50    colon-aligned label "Пр.расх."                                    fgcolor 4
  tt-fr-doc-line.transport-rubl         at row 16   col 80    colon-aligned label "Тр.расх."                                    fgcolor 4
  tt-fr-doc-line.other-rubl             at row 17   col 80    colon-aligned label "Пр.расх."                                    fgcolor 4
  tt-fr-doc-line.propan-perc            at row 18.5 col 3     label "Массовая доля пропана в смеси, %"  view-as fill-in size 8    by 1
  cb-connect-hoses                      at row 19.5 col 3
  prt-doc                               at row 9    col 10.5  colon-aligned
  prt-fact                              at row 10   col 10.5  colon-aligned
  "Сумма НДС(вал.постав.)"              at row 7    col 60                                             view-as text                     bgcolor 3 fgcolor 15
  sum-vat                               at row 8    col 73    colon-aligned no-label
  b-save                                at row 4.5  col 90
  b-quit                                at row 6    col 90
  b-prt                                 at row 9    col 90
  b-parts                               at row 10.5 col 90
  b-exit-cycl                           at row 12   col 90
  b-help                                at row 1    col 90
  b-addinf                              at row 12   col 90
  b-alc-attr                            at row 15   col 90
  "Сумма"                               at row 11   col 37  view-as text    size 23    by 1  bgcolor 3 fgcolor 15
  tt-fr-doc-line.tot-cli                at row 12   col 35.5  colon-aligned  no-label format "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.99" VIEW-AS FILL-IN SIZE 30 BY 1
  tot-base                              at row 13   col 35.5  colon-aligned no-label
  tot-rubl                              at row 14   col 35.5  colon-aligned no-label
  road-tax-cli                          at row 15   col 17 colon-aligned  view-as fill-in size 20 by 1 fgcolor 4
  rect-tot                              at row 16   col 1
  tt-fr-doc-line.wt-place               at row 16.2 col 40  label "Вес 1 места"
  rect-tax1                             at row 15.5 col 1
  rect-tax2                             at row 15.5 col 38
  "Вал"                                 at row 15.3 col 55                                    view-as text                     bgcolor 3 fgcolor 15
  "Руб"              at row 15.3 col 85                                    view-as text                     bgcolor 3 fgcolor 15
  b-place                               at row 20.5 col 2
  tt-fr-doc-line.pl-code                at row 20.5 col 2                   label "Место хр."
  tt-fr-doc-line.measure-qnty           at row 20.5 col 27.5  colon-aligned label "Изм."
  tt-fr-doc-line.state-measure-qnty     at row 20.5 col 49    colon-aligned label "Кол-во"
  tt-fr-doc-line.state-measure-cli-qnty at row 20.5 col 67.5  colon-aligned label "Вес"
  b-rvs-bf                              at row 18.6 col 87
  b-rvs-af                              at row 20.1 col 87
  vargds-obj-fact-qnty                  at row 21.5 col 2
  vargds-obj-price-sale                 at row 21.5 col 24.5
  vargds-obj-pc-ov                      at row 21.5 col 51
  vargds-obj-last-rubl                  at row 21.5 col 73
  vargds-obj-cli-type                   at row 22.5 col 2
  vargds-obj-cli-code                   at row 22.5 col 28 no-label
  vargds-obj-cli-name                   at row 22.5 col 39 no-label  view-as text    size 30   by 1
  tt-fr-doc-line.trk-cli-qnty           at row 22.5 col 69  label "Масса реал-и"
  "Количество"                          at row 4    col 12.5                                           view-as text    size 17    by 1  bgcolor 3 fgcolor 15
  "Ед. изм."                            at row 4    col 28.5                                           view-as text    size 11    by 1  bgcolor 3 fgcolor 15
  "Коэффициент"                         at row 4    col 38.5                                           view-as text    size 16    by 1  bgcolor 3 fgcolor 15
  "Цена"                                at row 11   col 17                                             view-as text    size 20    by 1  bgcolor 3 fgcolor 15
  "Вал."                                at row 11   col 60.0                                           view-as text    size 7.5   by 1  bgcolor 3 fgcolor 15
  tt-fr-doc-line.curr-abbr              at row 12   col 60.0                no-label                   view-as text    size 7.5   by 1  bgcolor 4 fgcolor 15
  "Б.вал."                              at row 13   col 60.0                                           view-as text    size 7.5   by 1  bgcolor 3 fgcolor 15
  "РУБ"                at row 14   col 60.0                                           view-as text    size 7.5   by 1  bgcolor 3 fgcolor 15
  abr-rb                                at row 15   col 60.0                no-label                   view-as text    size 7.5   by 1  bgcolor 1 fgcolor 15
  abr-rb2                               at row 16   col 60.0                no-label                   view-as text    size 7.5   by 1  bgcolor 1 fgcolor 15
  b-corr-price-sale                     at row 15   col 66
  g-image                               AT ROW 11   COL 68
with keep-tab-order view-as dialog-box
         side-labels three-d scrollable
         default-button b-save
         cancel-button  b-quit
.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-fr-doc-line.last-date in frame d-in-line
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
on delete-character of tt-fr-doc-line.last-date in frame d-in-line
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
on ctrl-d of tt-fr-doc-line.last-date in frame d-in-line
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
on ctrl-b of tt-fr-doc-line.last-date in frame d-in-line
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
on ctrl-e of tt-fr-doc-line.last-date in frame d-in-line
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
on ctrl-f of tt-fr-doc-line.last-date in frame d-in-line
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
      v-description = 'Годен до (для товара)'
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
  define MENU m-ed-date45
    MENU-ITEM m-ed-date45-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date45-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date45-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date45-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if tt-fr-doc-line.last-date :POPUP-MENU in frame d-in-line = ?
  then do:
    ASSIGN
      tt-fr-doc-line.last-date :POPUP-MENU in frame d-in-line = MENU m-ed-date45 :HANDLE
      tt-fr-doc-line.last-date :MENU-MOUSE in frame d-in-line = 3
    .
  end.
  define variable v-label-handle45 as handle no-undo .
  assign
    v-label-handle45 = tt-fr-doc-line.last-date :side-label-handle in frame d-in-line
  .
  if valid-handle (v-label-handle45)
  then do:
    if v-label-handle45 :tooltip = ""
    or v-label-handle45 :tooltip = ?
    then do:
      assign
        v-label-handle45 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date45-1 in menu m-ed-date45 DO:
    apply "ctrl-b":U to tt-fr-doc-line.last-date in frame d-in-line .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date45-2 in menu m-ed-date45 DO:
    apply "ctrl-d":U to tt-fr-doc-line.last-date in frame d-in-line .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date45-3 in menu m-ed-date45 DO:
    apply "ctrl-e":U to tt-fr-doc-line.last-date in frame d-in-line .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date45-4 in menu m-ed-date45 DO:
    apply "ctrl-f":U to tt-fr-doc-line.last-date in frame d-in-line .
  END.
assign frame d-in-line:scrollable                       = false .
function f-chekval RETURNS logical (input p-canval as char, input p-chkval as dec ):
  def var i as int.
  do i = 1 to num-entries(p-canval):
    if round(decimal(entry(i,p-canval)),1) = round(p-chkval,1) then return true.
  end.
  return no.
end function.
FUNCTION chk-asi-polling RETURNS logical
  ( is-bef as log ) :
  def buffer bf_rvs-doc for ub.rvs-doc .
  find first bf_rvs-doc no-lock
    where bf_rvs-doc.rvs-type = (if is-bef then 'перед_док':U else 'после_док':U)
      and bf_rvs-doc.out-code = t-doc.doc-code
      and num-entries(bf_rvs-doc.rvs-code, "-") = 2
      and bf_rvs-doc.state-measure-qnty <> ?
      no-error .
  if available (bf_rvs-doc) and not l-repeat-asi
    then
  do:
    message
      m-repeat-asi
      view-as alert-box information title "".
    return no .
  end.
  else return yes.
end.
ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME d-in-line
DO:
    DEFINE VARIABLE v-main-code LIKE ub.bar-code.b-code NO-UNDO.
    IF AVAILABLE buf_goods THEN
    DO:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-code
  )  .
        RUN ref/imagelist.w (parparentproc, "":U, v-main-code, 'ПРОСМОТР':U).
    END.
END.
on choose of b-choose-last-date in frame d-in-line
do:
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run sel-date in this-procedure
    ( input tt-fr-doc-line.last-date :handle
    , input "Годен до &1"
    ) .
end.
on choose of b-place in frame d-in-line
do:
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if varrvs-place <> true
    or b-place :sensitive in frame d-in-line <> true
  then do:
    return .
  end.
  run edit-doc-pl in this-procedure
    ( input parline-mode
    ).
end.
on return of tt-fr-doc-line.cli-qnty in frame d-in-line
do:
  if tt-fr-doc-line.doc-density :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.doc-density in frame d-in-line .
    return no-apply .
  end.
  if tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.doc-qnty in frame d-in-line .
    return no-apply .
  end.
  if tt-fr-doc-line.price-cli :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.price-cli in frame d-in-line .
    return no-apply .
  end.
  if tt-fr-doc-line.tot-cli :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.tot-cli in frame d-in-line .
    return no-apply .
  end.
  if tt-fr-doc-line.temperature :sensitive in frame d-in-line
  then do:
   apply "entry" to tt-fr-doc-line.temperature   in frame d-in-line.
   return no-apply.
  end.
  apply "entry" to b-save in frame d-in-line .
  return no-apply .
end.
on leave of tt-fr-doc-line.cli-qnty in frame d-in-line
do:
  define variable v-edit-doc-pl-mode as character no-undo .
  if keyfunction(lastkey) <> "end-error"
    and not ( last-event :event-type   = "progress":u
              and (last-event :widget-enter = b-quit :handle
                  or last-event :widget-enter = b-docsec :handle)
            )
  then do:
    if input frame d-in-line tt-fr-doc-line.cli-qnty <> tt-fr-doc-line.cli-qnty then do:
      assign
        frame d-in-line tt-fr-doc-line.cli-qnty
      .
      run calc-all    in this-procedure ( input varcli-qnty-calc ) no-error .
      if error-status :error then return no-apply.
      run calc-vat-pc in this-procedure.
      if varrvs-place = true
        and not ( last-event :event-type = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
        and tt-fr-doc-line.cli-base-rate <> ?
        and tt-fr-doc-line.cli-base-rate <> 0
        then do:
        assign
          v-edit-doc-pl-mode = 'АВТОИЗМЕНЕНИЕ':U
        .
        if is-petrolium = yes
          and is-pieces = no
          and tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line
          and tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line
        then do:
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + chr(4) + "update-dens-cli":U
          .
        end.
        run edit-doc-pl in this-procedure
          ( input v-edit-doc-pl-mode
          ).
      end.
    end.
  end.
  if vardensity-ist <> 0 and vardensity-ist <> ?
  then do:
    tt-fr-doc-line.doc-density:screen-value = string (vardensity-ist).
    apply "leave" to tt-fr-doc-line.doc-density in frame d-in-line .
    tt-fr-doc-line.doc-density:sensitive = false.
  end.
end.
on return of tt-fr-doc-line.doc-qnty in frame d-in-line
do:
  if tt-fr-doc-line.doc-density :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.doc-density in frame d-in-line .
    return no-apply .
  end.
  if tt-fr-doc-line.temperature :sensitive in frame d-in-line
  then do:
   apply "entry" to tt-fr-doc-line.temperature   in frame d-in-line.
   return no-apply.
  end.
  if tt-fr-doc-line.price-cli :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.price-cli in frame d-in-line .
    return no-apply .
  end.
  if tt-fr-doc-line.tot-cli :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.tot-cli in frame d-in-line .
    return no-apply .
  end.
  if tt-fr-doc-line.price-rubl :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.price-rubl in frame d-in-line .
    return no-apply .
  end.
  apply "entry" to b-save in frame d-in-line .
  return no-apply .
end.
on leave of tt-fr-doc-line.doc-qnty in frame d-in-line
do:
  define variable v-edit-doc-pl-mode as character no-undo .
  if keyfunction(lastkey) <> "end-error" and
     not ( last-event :event-type   = "progress":u and
           (last-event :widget-enter = b-quit :handle or
           last-event :widget-enter = b-docsec :handle))
  then do:
    if input frame d-in-line tt-fr-doc-line.doc-qnty = 0 or
       input frame d-in-line tt-fr-doc-line.doc-qnty = ?
    then do:
      message "Не указано количество по документу." view-as alert-box error .
      apply "entry" to tt-fr-doc-line.doc-qnty in frame d-in-line .
      return no-apply .
    end.
    if input frame d-in-line tt-fr-doc-line.doc-qnty <> tt-fr-doc-line.doc-qnty then do:
      assign
        frame d-in-line tt-fr-doc-line.doc-qnty
      .
      run calc-all in this-procedure
        ( input vardoc-qnty-calc
        ) no-error.
      if error-status :error then do:
        return no-apply .
      end.
      if varrvs-place = true
        and not ( last-event :event-type = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
        and tt-fr-doc-line.cli-base-rate <> ?
        and tt-fr-doc-line.cli-base-rate <> 0
      then do:
        assign
          v-edit-doc-pl-mode = 'АВТОИЗМЕНЕНИЕ':U
        .
        if is-petrolium = yes
          and is-pieces = no
          and tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line
          and tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line
        then do:
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + chr(4) + "update-dens-base":U
          .
        end.
        run edit-doc-pl in this-procedure
          ( input v-edit-doc-pl-mode
          ).
      end.
    end.
  end.
end.
on return of tt-fr-doc-line.fact-qnty in frame d-in-line
do:
  if tt-fr-doc-line.price-cli :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.price-cli in frame d-in-line .
    return no-apply .
  end.
  if tt-fr-doc-line.tot-cli :sensitive in frame d-in-line
  then do:
    apply "entry" to tt-fr-doc-line.tot-cli in frame d-in-line .
    return no-apply .
  end.
  apply "entry" to b-save in frame d-in-line .
  return no-apply .
end.
on leave of tt-fr-doc-line.fact-qnty in frame d-in-line
do:
  if keyfunction(lastkey) <> "end-error" and
     not ( last-event :event-type   = "progress":u and
           (last-event :widget-enter = b-quit :handle
           or last-event :widget-enter = b-docsec :handle) )
  then do:
    if input frame d-in-line tt-fr-doc-line.fact-qnty < 0
      or input frame d-in-line tt-fr-doc-line.fact-qnty = ?
    then do:
      message "Неправильное факт. количество в учетных единицах." view-as alert-box error .
      apply "entry" to tt-fr-doc-line.fact-qnty in frame d-in-line .
      return no-apply .
    end.
    if input frame d-in-line tt-fr-doc-line.fact-qnty <> tt-fr-doc-line.fact-qnty then do:
      assign
        frame d-in-line tt-fr-doc-line.fact-qnty
      .
      assign
        tt-fr-doc-line.fact-qnty-kg = tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
      .
      display
        tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
        tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
        with frame d-in-line .
      run disp-total in this-procedure .
      if varrvs-place = true
        and not ( last-event :event-type   = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
      then do:
        run edit-doc-pl in this-procedure
          ( input 'АВТОИЗМЕНЕНИЕ':U
          ).
      end.
    end.
  end.
end.
on return of tt-fr-doc-line.num-place in frame d-in-line do:
   apply "entry" to tt-fr-doc-line.wt-brutto in frame d-in-line.
   return no-apply.
end.
on leave of tt-fr-doc-line.num-place in frame d-in-line do:
  if keyfunction(lastkey) <> "end-error"
    and not ( last-event:event-type   = "progress":u
              and last-event:widget-enter = b-quit:handle
            )
  then do:
    if input frame d-in-line tt-fr-doc-line.num-place <> tt-fr-doc-line.num-place then do:
      assign
        frame d-in-line tt-fr-doc-line.num-place
      .
      assign
        tt-fr-doc-line.wt-brutto = tt-fr-doc-line.num-place * tt-fr-doc-line.wt-place
      .
      display
        tt-fr-doc-line.wt-brutto
        with frame d-in-line.
    end.
  end.
end.
on return of tt-fr-doc-line.wt-brutto in frame d-in-line do:
   apply "entry" to b-save in frame d-in-line.
   return no-apply.
end.
on leave of tt-fr-doc-line.wt-brutto in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame d-in-line tt-fr-doc-line.wt-brutto <> tt-fr-doc-line.wt-brutto then do:
      assign frame d-in-line tt-fr-doc-line.wt-brutto.
      assign tt-fr-doc-line.wt-place = tt-fr-doc-line.wt-brutto / tt-fr-doc-line.num-place.
      display tt-fr-doc-line.wt-place with frame d-in-line.
   end.
end.
end.
on return of tt-fr-doc-line.wt-place in frame d-in-line do:
   apply "entry" to tt-fr-doc-line.wt-brutto in frame d-in-line.
   return no-apply.
end.
on leave of tt-fr-doc-line.wt-place in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame d-in-line tt-fr-doc-line.wt-place <> tt-fr-doc-line.wt-place then do:
      assign frame d-in-line tt-fr-doc-line.wt-place.
      assign  tt-fr-doc-line.wt-brutto = tt-fr-doc-line.num-place * tt-fr-doc-line.wt-place.
      display tt-fr-doc-line.wt-brutto with frame d-in-line.
   end.
end.
end.
on return of road-tax-cli in frame d-in-line do:
   apply "entry" to b-save in frame d-in-line.
   return no-apply.
end.
on leave of road-tax-cli in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame d-in-line road-tax-cli <> road-tax-cli then do:
      run check-price in this-procedure no-error.
      if error-status :error then do:
         display road-tax-cli with frame d-in-line.
         return no-apply.
      end.
      assign frame d-in-line road-tax-cli.
      run calc-all in this-procedure ( input vartax-3-calc ) no-error.
      if error-status :error then return no-apply.
   end.
end.
end.
on return of tt-fr-doc-line.doc-density in frame d-in-line do:
   apply "entry" to tt-fr-doc-line.temperature   in frame d-in-line.
   return no-apply.
end.
on leave of tt-fr-doc-line.doc-density in frame d-in-line do:
  if keyfunction(lastkey) <> "end-error"
    and not ( last-event :event-type   = "progress":u
              and (last-event :widget-enter = b-quit :handle
              or last-event :widget-enter = b-docsec :handle)
            )
  then do:
    if input frame d-in-line tt-fr-doc-line.doc-density = 0 or
       input frame d-in-line tt-fr-doc-line.doc-density = ?
    then do:
      message "Укажите плотность вещества." view-as alert-box error .
      return no-apply .
    end.
    if Valid-Density( input frame d-in-line tt-fr-doc-line.doc-density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true then do:
      message
        "Плотность должна быть в диапазоне больше 0 и меньше 1."
        view-as alert-box error .
      return no-apply .
    end.
    if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
       if (input frame d-in-line tt-fr-doc-line.doc-density) < v-min-dens
       or (input frame d-in-line tt-fr-doc-line.doc-density) > v-max-dens
       then do:
          message
            substitute("Введенное значение плотности находится вне заданного диапазона: &1.",
            v-gds-ptrl-densities )
            view-as alert-box error .
          return no-apply .
       end.
    end.
    if input frame d-in-line tt-fr-doc-line.doc-density <> tt-fr-doc-line.doc-density then do:
      assign
        frame d-in-line tt-fr-doc-line.doc-density
      .
      assign
        tt-fr-doc-line.fact-density  = tt-fr-doc-line.doc-density
        tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
      .
      run calc-all in this-procedure
        ( input vardensity-calc
        ) no-error .
      if error-status :error then do:
        return no-apply .
      end.
      if varrvs-place = true
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
end.
on return of tt-fr-doc-line.temperature in frame d-in-line do:
  if tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line then do:
    apply "entry" to tt-fr-doc-line.doc-qnty in frame d-in-line .
    return no-apply .
  end.
  if tt-fr-doc-line.price-cli:sensitive then do:
    apply "entry" to tt-fr-doc-line.price-cli in frame d-in-line.
    return no-apply.
  end.
  if tt-fr-doc-line.price-rubl :sensitive in frame d-in-line then do:
    apply "entry" to tt-fr-doc-line.price-rubl in frame d-in-line .
    return no-apply .
  end.
   if tt-fr-doc-line.tot-cli:sensitive then do:
     apply "entry" to tt-fr-doc-line.tot-cli in frame d-in-line.
     return no-apply.
   end.
  apply "entry" to b-save in frame d-in-line.
  return no-apply.
end.
on leave of tt-fr-doc-line.temperature in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   assign frame d-in-line tt-fr-doc-line.temperature.
end.
end.
on return of tt-fr-doc-line.unit-cli in frame d-in-line do:
  apply "entry" to tt-fr-doc-line.cli-base-rate in frame d-in-line.
  return no-apply.
end.
on leave of tt-fr-doc-line.unit-cli in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
  if input frame d-in-line tt-fr-doc-line.unit-cli <> tt-fr-doc-line.unit-cli then do:
    run chg-unit in this-procedure no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end .
end.
end.
on choose of r-units in frame d-in-line
do:
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-units in this-procedure .
  run chg-unit in this-procedure no-error.
  if error-status :error then do:
    return no-apply.
  end.
  else do :
    apply "entry":U to tt-fr-doc-line.cli-base-rate .
    apply "leave":U to tt-fr-doc-line.cli-base-rate . // чтобы пересчиталась закупочная цена
  end .
end.
on return of tt-fr-doc-line.cli-base-rate in frame d-in-line do:
  if tt-fr-doc-line.price-cli:sensitive in frame d-in-line then do:
    apply "entry" to tt-fr-doc-line.price-cli.
    return no-apply.
  end.
  if tt-fr-doc-line.tot-cli:sensitive in frame d-in-line then do:
    apply "entry" to tt-fr-doc-line.price-cli.
    return no-apply.
  end.
end.
on leave of tt-fr-doc-line.cli-base-rate in frame d-in-line do:
  if keyfunction(lastkey) <> "end-error"
    and not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle)
  then do:
    if input frame d-in-line tt-fr-doc-line.cli-base-rate = 0
      or input frame d-in-line tt-fr-doc-line.cli-base-rate = ?
    then do:
      message "Не указан коэффициент пересчета единиц измерения." view-as alert-box.
      apply "entry" to tt-fr-doc-line.cli-base-rate in frame d-in-line.
      return no-apply.
    end.
    assign
      frame d-in-line tt-fr-doc-line.cli-base-rate
    .
    assign
      tt-fr-doc-line.doc-density = 1 / tt-fr-doc-line.cli-base-rate
    .
    run calc-all in this-procedure
      ( input varcli-base-rate-calc
      ) no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end.
end.
on return of tt-fr-doc-line.vat-pc in frame d-in-line do:
  apply "entry" to b-save in frame d-in-line.
  return no-apply.
end.
on return of tt-fr-doc-line.slt-pc in frame d-in-line do:
  apply "entry" to b-save in frame d-in-line.
  return no-apply.
end.
on leave of tt-fr-doc-line.vat-pc or
   leave of tt-fr-doc-line.slt-pc in frame d-in-line do:
define variable v-new-vat-pc as decimal no-undo .
if keyfunction( lastkey ) <> "end-error" and
   not ( last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
  v-new-vat-pc = input frame d-in-line tt-fr-doc-line.vat-pc .
  if v-new-vat-pc <> tt-fr-doc-line.vat-pc or
     input frame d-in-line tt-fr-doc-line.slt-pc <> tt-fr-doc-line.slt-pc then do:
   if vat-sumvalue <> "yes" then do:
      run p-chk-vat in this-procedure (v-new-vat-pc) no-error .
      if error-status :error then do:
     display tt-fr-doc-line.vat-pc tt-fr-doc-line.slt-pc with frame d-in-line.
     apply "entry" to self in frame d-in-line.
     return no-apply.
      end.
   end.
   assign frame d-in-line tt-fr-doc-line.vat-pc
          frame d-in-line tt-fr-doc-line.slt-pc.
   run calc-all in this-procedure ( input ( if varprice-cli-input = yes then varprice-cli-calc
                                                                        else varbase-price-calc ) ) no-error.
   if error-status :error then do:
     display tt-fr-doc-line.vat-pc tt-fr-doc-line.slt-pc with frame d-in-line.
     apply "entry" to self in frame d-in-line.
     return no-apply.
   end.
  end.
end.
end.
on return of tt-fr-doc-line.new-price-sale in frame d-in-line do:
  apply "entry" to tt-fr-doc-line.new-price-sale in frame d-in-line.
  return no-apply.
end.
on return of tt-fr-doc-line.price-prod in frame d-in-line do:
  apply "entry" to tt-fr-doc-line.price-prod in frame d-in-line.
  return no-apply.
end.
on return of tt-fr-doc-line.price-prod-vat in frame d-in-line do:
  apply "entry" to tt-fr-doc-line.price-prod-vat in frame d-in-line.
  return no-apply.
end.
on leave of tt-fr-doc-line.new-price-sale in frame d-in-line do:
if keyfunction( lastkey ) <> "end-error" and
   not ( last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
  if input frame d-in-line tt-fr-doc-line.new-price-sale   <>  tt-fr-doc-line.new-price-sale  then do:
      run lineattr-write in this-procedure (
          t-doc.doc-code ,
          buf_goods.gds-code ,
          'corr-price-sale':U,
          string(tt-fr-doc-line.new-price-sale)
          ).
      tt-fr-doc-line.price-corr = 1.
     display b-corr-price-sale with frame d-in-line .
     assign tt-fr-doc-line.new-price-sale .
  end.
end.
end.
on leave of tt-fr-doc-line.price-prod in frame d-in-line do:
if keyfunction( lastkey ) <> "end-error" and
   not ( last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
  if input frame d-in-line tt-fr-doc-line.price-prod  <>  tt-fr-doc-line.price-prod  then do:
      run lineattr-write in this-procedure (
          t-doc.doc-code ,
          buf_goods.gds-code ,
          'price-prod':U,
          string(tt-fr-doc-line.price-prod)
          ).
     assign tt-fr-doc-line.price-prod .
  end.
end.
end.
on leave of tt-fr-doc-line.price-prod-vat in frame d-in-line do:
if keyfunction( lastkey ) <> "end-error" and
   not ( last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
  if input frame d-in-line tt-fr-doc-line.price-prod-vat  <>  tt-fr-doc-line.price-prod-vat  then do:
      run lineattr-write in this-procedure (
          t-doc.doc-code ,
          buf_goods.gds-code ,
          'price-prodvat':U,
          string(tt-fr-doc-line.price-prod-vat)
          ).
     assign tt-fr-doc-line.price-prod-vat .
  end.
end.
end.
on return of sum-vat in frame d-in-line do:
   apply "entry" to b-save in frame d-in-line.
   return no-apply.
end.
on leave of sum-vat in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame d-in-line sum-vat <> sum-vat and sum-vat <> ? then do:
     if tt-fr-doc-line.price-cli <> 0 and
        input frame d-in-line sum-vat >=
        (tt-fr-doc-line.cli-qnty * tt-fr-doc-line.price-cli -
         (if t-doc.vat-type = 'в т. ч.':U then input frame d-in-line sum-vat else 0))
        then do:
        message "НДС не может быть больше 99.999...%" skip
                "НДС:" input frame d-in-line sum-vat skip
                "Сумма:" tt-fr-doc-line.cli-qnty * tt-fr-doc-line.price-cli
                view-as alert-box error.
        display sum-vat with frame d-in-line.
        return no-apply.
     end.
     else do:
       if input frame d-in-line sum-vat = 0.00 then do:
          varlog = no.
          message "Вы хотите установить НДС в 0?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog = yes then do:
             assign frame d-in-line sum-vat.
             run calc-vat-pc in this-procedure.
             run calc-all in this-procedure ( input ( if varprice-cli-input = yes then varprice-cli-calc
                                                                                  else varbase-price-calc ) ) no-error.
             if error-status :error then return no-apply.
          end.
          else do:
              display sum-vat with frame d-in-line.
              return no-apply.
          end.
       end.
       else do:
          assign frame d-in-line sum-vat.
          run calc-vat-pc in this-procedure.
          run p-chk-vat  in this-procedure (tt-fr-doc-line.vat-pc) .
          run calc-all in this-procedure ( input ( if varprice-cli-input = yes then varprice-cli-calc
                                                                               else varbase-price-calc ) ) no-error.
          if error-status :error then do:
            return no-apply.
          end.
       end.
     end.
   end.
end.
end.
on return of tt-fr-doc-line.price-cli  in frame d-in-line or
   return of tt-fr-doc-line.price-rubl in frame d-in-line or
   return of tt-fr-doc-line.tot-cli    in frame d-in-line
   do:
  if b-prt:sensitive in frame d-in-line then apply "entry" to b-prt in frame d-in-line.
  else do:
    if lookup('сер':U, tt-fr-doc-line.unit-type) > 0 and
       b-parts:sensitive in frame d-in-line     then
       apply "entry" to b-parts in frame d-in-line.
    else do:
      if custvalue = "yes" then
         apply "entry" to tt-fr-doc-line.wt-brutto in frame d-in-line.
         else do:
             if road-tax-cli:sensitive in frame d-in-line then apply "entry" to road-tax-cli in frame d-in-line.
                                                              else apply "entry" to b-save       in frame d-in-line.
         end.
    end.
  end.
  return no-apply.
end.
on leave of tt-fr-doc-line.price-cli in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
  if input frame d-in-line tt-fr-doc-line.price-cli <> tt-fr-doc-line.price-cli then do:
     run check-price in this-procedure no-error.
     if error-status :error then return no-apply.
     assign frame d-in-line tt-fr-doc-line.price-cli.
     run calc-all in this-procedure ( input varprice-cli-calc ) no-error.
     if error-status :error then return no-apply.
  end.
end.
end.
on leave of tt-fr-doc-line.tot-cli in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
  if input frame d-in-line tt-fr-doc-line.tot-cli <> tt-fr-doc-line.tot-cli then do:
     run check-price in this-procedure no-error.
     if error-status :error then return no-apply.
     assign frame d-in-line tt-fr-doc-line.tot-cli.
     assign
     tt-fr-doc-line.price-cli = tt-fr-doc-line.tot-cli / tt-fr-doc-line.cli-qnty.
     run calc-all in this-procedure ( input varprice-cli-calc ) no-error.
     if error-status :error then return no-apply.
  end.
end.
end.
on leave of tt-fr-doc-line.price-rubl in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
  if input frame d-in-line tt-fr-doc-line.price-rubl <> tt-fr-doc-line.price-rubl then do:
     run check-price in this-procedure no-error.
     if error-status :error then return no-apply.
     assign frame d-in-line tt-fr-doc-line.price-rubl.
     run calc-all in this-procedure ( input varbase-price-calc ) no-error.
     if error-status :error then return no-apply.
  end.
end.
end.
on leave of tt-fr-doc-line.cst-code in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame d-in-line tt-fr-doc-line.cst-code <> tt-fr-doc-line.cst-code then do:
      assign frame d-in-line tt-fr-doc-line.cst-code.
   end.
end.
end.
on leave of tt-fr-doc-line.last-date in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame d-in-line tt-fr-doc-line.last-date <> tt-fr-doc-line.last-date then do:
      assign frame d-in-line tt-fr-doc-line.last-date.
      run godendo-date-to-offset in this-procedure (  input today,
                                                      input tt-fr-doc-line.last-date,
                                                     output tt-fr-doc-line.last-num-day ).
      display tt-fr-doc-line.last-num-day with frame d-in-line.
   end.
end.
end.
on leave of tt-fr-doc-line.last-num-day in frame d-in-line do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame d-in-line tt-fr-doc-line.last-num-day <> tt-fr-doc-line.last-num-day then do:
      assign frame d-in-line tt-fr-doc-line.last-num-day.
      run godendo-offset-to-date in this-procedure (  input today,
                                                      input tt-fr-doc-line.last-num-day,
                                                     output tt-fr-doc-line.last-date ).
      display tt-fr-doc-line.last-date with frame d-in-line.
   end.
end.
end.
on choose of r-country in frame d-in-line
do:
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-country-code in this-procedure no-error.
end.
on value-changed of tt-fr-doc-line.type-inp-vat in frame d-in-line do:
if keyfunction( lastkey ) <> "end-error" and
   not (last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
   run v-c-type-inp-vat in this-procedure no-error.
   if error-status :error then do:
     display tt-fr-doc-line.type-inp-vat with frame d-in-line.
     return no-apply.
   end.
end.
end.
on choose of b-prt in frame d-in-line
do:
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
  run save-action in this-procedure
    ( input "light":U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
tr:
do transaction on error undo, leave:
   if parline-mode <> 'ПРОСМОТР':U then do:
      find first ub.doc-line where recid(ub.doc-line) = line-rec.
      for each old-doc-line:
          delete old-doc-line.
      end.
      create old-doc-line.
      buffer-copy ub.doc-line to old-doc-line.
      release ub.doc-line.
   end.
   if t-doc.flag_ = no and t-doc.status_ <> 'факт':U then
        run str/doc-p.p
            (parparentproc
            ,pardoc-rec
            ,line-rec
            ,recid(buf_goods)
            ,prt-mode )
            no-error.
      else run str/fac-p.p
            (parparentproc
            ,pardoc-rec
            ,line-rec
            ,recid(buf_goods)
            ,prt-mode )
            no-error.
   if error-status :error then undo tr, return no-apply.
   if parline-mode <> 'ПРОСМОТР':U then do:
    run update-doc-line in this-procedure no-error.
    if error-status :error then undo tr, return no-apply.
   end.
end.
run ui-on in this-procedure.
if parline-mode <> 'ПРОСМОТР':U then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run find-new-price-sale in this-procedure (
   input  pr-genmrg
  ,input  pr-naklvalue
  ,input  t-doc.doc-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  tt-fr-doc-line.price-rubl
  ,input  tt-fr-doc-line.price-base
  ,input  tt-fr-doc-line.price-rubl
  ,input  tt-fr-doc-line.price-base
  ,input-output tt-fr-doc-line.new-price-sale
    )
    no-error .
      if error-status :error then
      message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи"
        view-as alert-box error
      .
      run disp-total in this-procedure .
end.
if b-save :sensitive then apply "entry" to b-save in frame d-in-line.
else apply "entry" to b-quit in frame d-in-line.
end.
on choose of b-addinf in frame d-in-line
do:
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
  define buffer bf_rvs-doc     for ub.rvs-doc .
  define buffer bf_rvs-line    for ub.rvs-line .
  define variable v-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
  define variable v-new-density          like ub.doc-line.fact-density no-undo .
  define variable v-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
  define variable ii as integer no-undo .
  define variable choice as integer no-undo .
  define variable v-kpsecs as character no-undo .
  define variable v-kpsecs-nomeas as character no-undo .
  define variable vAccMethChoosed as logical no-undo .
  define variable v-need-measure as logical no-undo init no .
  assign
    v-new-fact-qnty     = tt-fr-doc-line.fact-qnty
    v-new-density       = tt-fr-doc-line.fact-density
    v-new-cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg
  .
  infoSectionsTotal:DocQntyLine = tt-fr-doc-line.doc-qnty.
  infoSectionsTotal:DocDensLine = tt-fr-doc-line.doc-density.
  infoSectionsTotal:DocCliLine = tt-fr-doc-line.cli-qnty.
  infoSectionsTotal:FlagTrn = t-doc.flag_.
  if infoSectionsTotal:IsKP
  and parline-mode <> 'ПРОСМОТР':U
  then do :
    vAccMethChoosed = yes .
    do ii = 1 to infoSectionsTotal:SectionNum :
      infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
      if infoSecObj:IsKP
      then do :
        if infoSecObj:AccMeth = ?
        then do :
          vAccMethChoosed = no .
        end .
        assign v-kpsecs = v-kpsecs + infoSecObj:SectionName + " с " + buf_goods.gds-name + ", " .
      end .
      if infoSecObj:KPnoMeas
      then do :
        assign v-kpsecs-nomeas = v-kpsecs-nomeas + infoSecObj:SectionName + " с " + buf_goods.gds-name + ", " .
      end .
      if infoSectionsTotal:IsSGDKK
      then do :
        v-need-measure = no .
      end .
      else do :
        if not infoSecObj:KPnoMeas
        and (not (infoSecObj:TankWeight > 0)
        or infoSecObj:TankWeight = ?
        or infoSecObj:TankDensity = ?)
        then do :
          v-need-measure = yes .
        end .
      end .
    end .
    assign
      v-kpsecs = trim(v-kpsecs, ", ")
      v-kpsecs-nomeas = trim(v-kpsecs-nomeas, ", ")
    .
    if not vAccMethChoosed
    and infoSectionsTotal:IsActnComm
    then do :
      if v-kpsecs > ""
      then do :
        run gbl/d-askw.w (
           input "Выбор способа выполнения комиссионного приёма"
          ,input ("Для секций " + v-kpsecs + " требуется комиссионный прием. Каким способом будет выполняться комиссионный прием?")
          ,input "|^"
          ,input "Замеры в АЦ" + (if v-kpsecs-nomeas > "" then "^disable" else "") + "|По сверкам|Отмена"
          ,input "Выполнение комиссионного приёма стандартным способом по замерам в автоцистерне|Выполнение комиссионного приёма по данным сверок в резервуаре|Отказ от выбора способа"
          ,input 1
          ,input 3
          ,output choice).
        case choice :
          when 1
          then do :
            kpsecs_ :
            do ii = 1 to infoSectionsTotal:SectionNum :
              infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
              if infoSecObj:isKP
              then do :
                infoSecObj:AccMeth = 0 .
              end .
            end .
          end .
          when 2
          then do :
            kpsecs_ :
            do ii = 1 to infoSectionsTotal:SectionNum :
              infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
              if infoSecObj:isKP
              then do :
                infoSecObj:AccMeth = 1 .
                infoSectionsTotal:IsKPrvs = yes .
              end .
            end .
          end .
          when 3
          then do :
            return no-apply .
          end .
        end case .
      end .
      infoSectionsTotal:SaveDB() .
      find first buf_rvs-doc no-lock where buf_rvs-doc.out-code = t-doc.doc-code no-error.
      if not available buf_rvs-doc
      and not v-need-measure
      then do :
        run cr-rvs-doc in this-procedure:instantiating-procedure
          ( input parparentproc
           ,input t-doc.doc-code
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при создании документов сверок.") skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      end .
    end .
  end .
  run proc-b-addinfo in this-procedure
    ( input        parparentproc
     ,input        ( if parline-mode <> 'ПРОСМОТР':U then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U )
     ,input        tt-fr-doc-line.doc-code
     ,input        buf_goods.gds-code
     ,input        stfactplvalue
     ,input        varauto-tank
     ,input        varupd-fact-qnty
     ,input        tt-fr-doc-line.doc-qnty
     ,input        tt-fr-doc-line.doc-density
     ,input-output v-new-fact-qnty
     ,input-output v-new-density
     ,input-output v-new-cli-fact-qnty
     ,input-output infoSectionsTotal
     ,input-output v-prt-start-real-date
     ,input-output v-prt-start-real-time
     ,input-output v-prt-end-real-date
     ,input-output v-prt-end-real-time
    ) no-error .
  if error-status :error then do:
    message
      substitute("Ошибка при изменении дополнительной информации.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return no-apply .
  end.
  if tt-fr-doc-line.fact-qnty <> v-new-fact-qnty
    or tt-fr-doc-line.fact-qnty-kg <> v-new-cli-fact-qnty
  then do:
    run correct-fact-qnty in this-procedure
      ( input v-new-fact-qnty
       ,input v-new-density
      ) no-error .
  end.
  run display-b-rvs in this-procedure
    no-error .
  run display-measure in this-procedure
    no-error .
  display
    tt-fr-doc-line.fact-qnty
    tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
    tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
    with frame d-in-line .
end.
on choose of b-docsec in frame d-in-line
do:
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
  define variable v-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
  define variable v-new-density          like ub.doc-line.fact-density no-undo .
  define variable v-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
  define variable v-edit-doc-pl-mode as character no-undo .
  define variable d_fact-qnty     as decimal   no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal   no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal   no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal   no-undo initial 0.00 .
  define variable pl_fact-qnty     as decimal   no-undo initial 0.00 .
  define variable pl_doc-qnty      as decimal   no-undo initial 0.00 .
  define variable pl_cli-qnty      as decimal   no-undo initial 0.00 .
  define variable pl_doc-density   as decimal   no-undo initial 0.00 .
  define variable pl_fact-density  as decimal   no-undo initial 0.00 .
  define variable pl-list          as character no-undo initial "" .
  define variable v-log            as logical   no-undo .
  define variable pl-setted        as logical no-undo init false .
  define variable ii               as integer no-undo .
  define variable pl               as integer no-undo .
  define buffer tmp_doc-line-attr for ub.doc-line-attr .
  assign
    v-new-fact-qnty     = tt-fr-doc-line.fact-qnty
    v-new-density       = tt-fr-doc-line.fact-density
    v-new-cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg
  .
  if parline-mode <> 'ДОБАВЛЕНИЕ':U
  or v-is-looksec
  then
    infoSectionsTotal:GetDBAllAttr().
  empty temp-table tt-old-list-tank .
  for each tmp_doc-line-attr no-lock where tmp_doc-line-attr.doc-code = t-doc.doc-code
                                       and tmp_doc-line-attr.gds-code = buf_goods.gds-code
                                       and tmp_doc-line-attr.attr-code begins "list-tank" :
    create tt-old-list-tank .
    buffer-copy tmp_doc-line-attr to tt-old-list-tank .
  end .
  infoSectionsTotal:PlChanged = no .
  if not valid-object(tanksForm)
  then
    tanksForm = new ibs.th.str.ptrl.forms.tanksections(infoSectionsTotal).
  wait-for tanksForm:ShowDialog().
  if v-is-looksec
  then do :
    if parline-mode ne 'ПРОСМОТР':U
    then
       infoSectionsTotal:SaveDBNoCheck() .
    infoSectionsTotal:WasSetting = true .
  end .
  if infoSectionsTotal:WasSetting = false
  then infoSectionsTotal:GetDBAllAttr().
  else do:
    do ii = 1 to infoSectionsTotal:SectionNum :
      infoSectionsTotal:GetInfoSectionProp (ii).
      if infoSectionsTotal:FlagTrn = no
      then do :
        infoSectionsTotal:InfoSectionCurr:FactQnty = infoSectionsTotal:InfoSectionCurr:DocQnty.
        infoSectionsTotal:InfoSectionCurr:FactDensity = infoSectionsTotal:InfoSectionCurr:DocDensity.
      end .
      if lookup(infoSectionsTotal:InfoSectionCurr:ListTank, pl-list) = 0
      then do :
        pl-list = pl-list + "," + infoSectionsTotal:InfoSectionCurr:ListTank .
      end .
    end .
    pl-list = trim(pl-list, ",") .
    if infoSectionsTotal:PlChanged
    then do :
      for each tt-doc-pl :
        delete tt-doc-pl .
      end .
    end .
    infoSectionsTotal:CalculateTotal().
    if not infoSectionsTotal:CliQntyInput then do:
      tt-fr-doc-line.doc-density:screen-value = string (infoSectionsTotal:DocDensityAvg).
      tt-fr-doc-line.doc-qnty:screen-value = string (infoSectionsTotal:DocQntyTotal).
      if input frame d-in-line tt-fr-doc-line.doc-qnty <> tt-fr-doc-line.doc-qnty
      then do:
        assign
          frame d-in-line tt-fr-doc-line.doc-qnty
        .
        run calc-all in this-procedure
          ( input vardoc-qnty-calc
          ) no-error.
        if error-status :error then do:
          return no-apply .
        end.
        if trim(pl-list) = ""
        then do :
          run str/doc-pls.w
            ( input parparentproc
             ,input ('АВТОИЗМЕНЕНИЕ':U)
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
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
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
            assign
              pl_cli-qnty   = pl_cli-qnty + (infoSectionsTotal:InfoSectionCurr:DocDensity * infoSectionsTotal:InfoSectionCurr:DocQnty)
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end .
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          run str/doc-pls.w
            ( input parparentproc
             ,input ('АВТОИЗМЕНЕНИЕ':U + chr(4) + chr(4) + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input pl_doc-density
             ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
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
          pl-setted = yes .
        end .
      end .
      if input frame d-in-line tt-fr-doc-line.doc-density <> tt-fr-doc-line.doc-density
      then do:
        assign
          frame d-in-line tt-fr-doc-line.doc-density
        .
        assign
          tt-fr-doc-line.fact-density  = tt-fr-doc-line.doc-density
          tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
        .
        run calc-all in this-procedure
          ( input vardensity-calc
          ) no-error .
        if error-status :error then do:
          return no-apply .
        end.
        if trim(pl-list) = ""
        then do :
          run str/doc-pls.w
            ( input parparentproc
             ,input ('АВТОИЗМЕНЕНИЕ':U + chr(4) + "update-dens":U)
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
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
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
            assign
              pl_cli-qnty   = pl_cli-qnty + (infoSectionsTotal:InfoSectionCurr:DocDensity * infoSectionsTotal:InfoSectionCurr:DocQnty)
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end .
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          run str/doc-pls.w
            ( input parparentproc
             ,input ('АВТОИЗМЕНЕНИЕ':U + chr(4) + "update-dens":U + chr(4) + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
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
          pl-setted = yes .
        end .
      end .
    end.
    if not infoSectionsTotal:DensityInput then do:
      tt-fr-doc-line.doc-qnty:screen-value = string (infoSectionsTotal:DocQntyTotal).
      tt-fr-doc-line.cli-qnty:screen-value = string (infoSectionsTotal:CliQntyTotal).
      if input frame d-in-line tt-fr-doc-line.doc-qnty <> tt-fr-doc-line.doc-qnty
      then do:
        assign
          frame d-in-line tt-fr-doc-line.doc-qnty
        .
        run calc-all in this-procedure
          ( input vardoc-qnty-calc
          ) no-error.
        if error-status :error then do:
          return no-apply .
        end.
        if trim(pl-list) = ""
        then do :
          run str/doc-pls.w
            ( input parparentproc
             ,input ('АВТОИЗМЕНЕНИЕ':U)
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
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
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
            assign
              pl_cli-qnty   = pl_cli-qnty + infoSectionsTotal:InfoSectionCurr:CliQnty
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end .
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          run str/doc-pls.w
            ( input parparentproc
             ,input ('АВТОИЗМЕНЕНИЕ':U + chr(4) + chr(4) + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input pl_doc-density
             ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
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
          pl-setted = yes .
        end .
      end .
      if input frame d-in-line tt-fr-doc-line.cli-qnty <> tt-fr-doc-line.cli-qnty
      then do:
        assign
          frame d-in-line tt-fr-doc-line.cli-qnty
        .
        run calc-all    in this-procedure ( input varcli-qnty-calc ) no-error .
        if error-status :error then return no-apply.
        run calc-vat-pc in this-procedure.
        assign
          v-edit-doc-pl-mode = 'АВТОИЗМЕНЕНИЕ':U
        .
        if is-petrolium = yes
          and is-pieces = no
          and tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line
          and tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line
        then do:
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + chr(4) + "update-dens-cli":U
          .
        end.
        else do :
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + chr(4)
          .
        end .
        if trim(pl-list) = ""
        then do :
          v-edit-doc-pl-mode = trim(v-edit-doc-pl-mode, chr(4)) .
          run str/doc-pls.w
            ( input parparentproc
             ,input (v-edit-doc-pl-mode)
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
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
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
            assign
              pl_cli-qnty   = pl_cli-qnty + infoSectionsTotal:InfoSectionCurr:CliQnty
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end .
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          run str/doc-pls.w
            ( input parparentproc
             ,input (v-edit-doc-pl-mode + chr(4) + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input pl_doc-density
             ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
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
          pl-setted = yes .
        end .
      end .
    end.
    if not infoSectionsTotal:DocQntyInput then do:
      tt-fr-doc-line.doc-density:screen-value = string (infoSectionsTotal:DocDensityAvg).
      tt-fr-doc-line.cli-qnty:screen-value = string (infoSectionsTotal:CliQntyTotal).
      if input frame d-in-line tt-fr-doc-line.cli-qnty <> tt-fr-doc-line.cli-qnty
      then do:
        assign
          frame d-in-line tt-fr-doc-line.cli-qnty
        .
        run calc-all    in this-procedure ( input varcli-qnty-calc ) no-error .
        if error-status :error then return no-apply.
        run calc-vat-pc in this-procedure.
        assign
          v-edit-doc-pl-mode = 'АВТОИЗМЕНЕНИЕ':U
        .
        if is-petrolium = yes
          and is-pieces = no
          and tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line
          and tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line
        then do:
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + chr(4) + "update-dens-cli":U
          .
        end.
        else do :
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + chr(4)
          .
        end .
        if trim(pl-list) = ""
        then do :
          v-edit-doc-pl-mode = trim(v-edit-doc-pl-mode, chr(4)) .
          run str/doc-pls.w
            ( input parparentproc
             ,input (v-edit-doc-pl-mode)
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
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
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
            assign
              pl_cli-qnty   = pl_cli-qnty + infoSectionsTotal:InfoSectionCurr:CliQnty
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end .
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          run str/doc-pls.w
            ( input parparentproc
             ,input (v-edit-doc-pl-mode + chr(4) + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input pl_doc-density
             ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
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
          pl-setted = yes .
        end.
      end.
      if input frame d-in-line tt-fr-doc-line.doc-density <> tt-fr-doc-line.doc-density
      then do:
        assign
          frame d-in-line tt-fr-doc-line.doc-density
        .
        assign
          tt-fr-doc-line.fact-density  = tt-fr-doc-line.doc-density
          tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
        .
        run calc-all in this-procedure
          ( input vardensity-calc
          ) no-error .
        if error-status :error then do:
          return no-apply .
        end.
        if trim(pl-list) = ""
        then do :
          run str/doc-pls.w
            ( input parparentproc
             ,input ('АВТОИЗМЕНЕНИЕ':U + chr(4) + "update-dens":U)
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
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
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
            assign
              pl_cli-qnty   = pl_cli-qnty + infoSectionsTotal:InfoSectionCurr:CliQnty
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end .
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          run str/doc-pls.w
            ( input parparentproc
             ,input ('АВТОИЗМЕНЕНИЕ':U + chr(4) + "update-dens":U + chr(4) + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
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
          pl-setted = yes .
        end .
      end .
    end.
    if infoSectionsTotal:PlChanged
    and not pl-setted
    and trim(pl-list) > ""
    then do :
      do pl = 1 to num-entries(pl-list) :
        assign
          pl_cli-qnty   = 0
          pl_doc-qnty   = 0
          pl_fact-qnty  = 0
        .
        sect_ :
        do ii = 1 to infoSectionsTotal:SectionNum :
          infoSectionsTotal:GetInfoSectionProp (ii).
          if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
          then
            next sect_ .
          assign
            pl_cli-qnty   = pl_cli-qnty + (infoSectionsTotal:InfoSectionCurr:DocDensity * infoSectionsTotal:InfoSectionCurr:DocQnty)
            pl_doc-qnty   = pl_doc-qnty + (infoSectionsTotal:InfoSectionCurr:DocDensity * infoSectionsTotal:InfoSectionCurr:DocQnty / tt-fr-doc-line.doc-density)
            pl_fact-qnty  = pl_fact-qnty + (infoSectionsTotal:InfoSectionCurr:FactDensity * infoSectionsTotal:InfoSectionCurr:FactQnty / tt-fr-doc-line.fact-density)
          .
        end .
        pl_doc-density = pl_cli-qnty / pl_doc-qnty .
        pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
        run str/doc-pls.w
          ( input parparentproc
           ,input ('АВТОИЗМЕНЕНИЕ':U + chr(4) + chr(4) + "place=" + entry(pl, pl-list))
           ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
           ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
           ,input t-doc.doc-code
           ,input infoSectionsTotal:GdsCode
           ,input tt-fr-doc-line.unit-cli
           ,input tt-fr-doc-line.cli-base-rate
           ,input pl_doc-density
           ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
           ,input pl_cli-qnty
           ,input pl_doc-qnty
           ,input pl_fact-qnty
           ,input pl_doc-qnty * pl_doc-density
           ,input pl_fact-qnty * pl_fact-density
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
        pl-setted = yes .
      end .
    end .
    if parline-mode <> 'ПРОСМОТР':U then do:
      for each tt-doc-pl no-lock
      on error undo, return no-apply
      :
        assign
          d_fact-qnty     = d_fact-qnty     + tt-doc-pl.fact-qnty
          d_doc-qnty      = d_doc-qnty      + tt-doc-pl.doc-qnty
          d_cli-fact-qnty = d_cli-fact-qnty + tt-doc-pl.cli-fact-qnty
          d_cli-doc-qnty  = d_cli-doc-qnty  + tt-doc-pl.cli-doc-qnty
        .
      end.
      if tt-fr-doc-line.doc-qnty <> d_doc-qnty
        or
        ( tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line = true
           and absolute( tt-fr-doc-line.cli-qnty - d_cli-doc-qnty ) < 0.0011
        )
        or
        ( tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line = true
          and tt-fr-doc-line.cli-qnty <> d_cli-doc-qnty
        )
      then do:
          assign
            tt-fr-doc-line.doc-qnty = d_doc-qnty
            tt-fr-doc-line.cli-qnty = d_cli-doc-qnty
            tt-fr-doc-line.doc-density = tt-fr-doc-line.cli-qnty / tt-fr-doc-line.doc-qnty
          .
          display
            tt-fr-doc-line.doc-qnty
            tt-fr-doc-line.cli-qnty
            tt-fr-doc-line.doc-density
            with frame d-in-line .
      end.
      if varupd-fact-qnty = true
        and not( t-doc.status_ = 'накл':U
                 and t-doc.flag_ = false
               )
        and ( tt-fr-doc-line.fact-qnty <> d_fact-qnty
              or absolute( tt-fr-doc-line.fact-qnty-kg - d_cli-fact-qnty ) < 0.0011
            )
      then do:
          assign
            tt-fr-doc-line.fact-qnty    = d_fact-qnty
            tt-fr-doc-line.fact-qnty-kg = d_cli-fact-qnty
            tt-fr-doc-line.fact-density = tt-fr-doc-line.fact-qnty-kg / tt-fr-doc-line.fact-qnty
          .
          display
            tt-fr-doc-line.fact-qnty
            tt-fr-doc-line.fact-qnty-kg
            tt-fr-doc-line.fact-density
            with frame d-in-line
          .
      end.
      run check-place-rsrv in this-procedure
        no-error .
      if error-status :error
      then do:
        tanksForm:dispose() .
        if valid-object(tanksForm)
        and tanksForm:isDisposed
        then
          delete object tanksForm .
        return no-apply  .
      end.
    end.
  end.
  tanksForm:dispose() .
  if valid-object(tanksForm)
  and tanksForm:isDisposed
  then
    delete object tanksForm .
end.
on choose of b-alc-attr in frame d-in-line do:
  define variable save-flag  as logical   no-undo.
  define buffer buf_parts for ub.parts .
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
  if tt-fr-doc-line.alc-multi-parts then do:
    message "Данная строка накладной содержит несколько партий." skip
            "Используйте режим корректировки партий для просмотра/изменения " +
            "атрибутов алкогольной продукции."
    view-as alert-box information.
    return no-apply.
  end.
find first buf_parts where buf_parts.obj-type  = t-doc.obj-type           and
                          buf_parts.obj-code  = t-doc.obj-code           and
                          buf_parts.prod-type = tt-fr-doc-line.prod-type and
                          buf_parts.prod-code = tt-fr-doc-line.prod-code and
                          buf_parts.artic     = tt-fr-doc-line.artic     and
                          buf_parts.out-code  = t-doc.doc-code           no-lock no-error.
  do on error undo, return no-apply:
    run str/in-alc.w
      (input        parParentProc
      ,input        (if parline-mode <> 'ПРОСМОТР':U then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
      ,input buf_goods.gds-code
      ,buffer buf_parts
      ,input-output tt-fr-doc-line.alc-mark-db-num
      ,input-output tt-fr-doc-line.alc-mark-code
      ,input-output tt-fr-doc-line.alc-bottling-date
      ,input-output tt-fr-doc-line.alc-ref-ab-path
      ,input-output tt-fr-doc-line.alc-quality-certif-path
      ,input-output tt-fr-doc-line.alc-certif-path
      ,input-output tt-fr-doc-line.alc-imp-type
      ,input-output tt-fr-doc-line.alc-imp-code
      ,output       save-flag
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
  end.
end.
on choose of menu-item m-rvs-bf-1 in menu m-rvs-bf
do:
define variable vss-include-info55 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-bf :type in frame d-in-line
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-in-line skip
    "Тип" self :type in frame d-in-line skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-bf in frame d-in-line .
  if focus :handle <> b-rvs-bf :handle in frame d-in-line then do:
    return no-apply .
  end.
end.
  assign
      rvslog = no.
  find first buf_rvs-doc
    where buf_rvs-doc.rvs-type = 'перед_док':U
      and buf_rvs-doc.out-code = t-doc.doc-code
      and num-entries(buf_rvs-doc.rvs-code, "-") = 2
      and buf_rvs-doc.state-measure-qnty <> ?
      no-error .
  if available buf_rvs-doc then
  do:
    if not chk-asi-polling (yes)
      then return no-apply .
    message
        "Сверка до уже выполнена. Вы уверены, что хотите ее изменить?"  skip
        view-as alert-box question buttons YES-NO update rvslog.
    if not rvslog then
      return no-apply.
  end.
  disable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame d-in-line.
  end .
  run action-rvs-line in this-procedure
      ( input 'ИЗМЕНЕНИЕ':U
      ,input "meas":U
      ,input 'перед_док':U
      ,output var-code-temp
      ) no-error .
  if error-status :error then
  do:
    enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
    if v-is-lgas or v-is-lgas-corr
    then do:
      hide b-addinf in frame d-in-line.
    end .
    return.
  end.
  run adm/shattri.p (
     input "get":U
     ,input  v-cntxt-obj-type
     ,input  v-cntxt-obj-code
     ,input  'petrol':U
     ,input  'block-nozzle':U
     ,output v-value-character
     ,output v-value-date
     ,output v-value-decimal
     ,output v-value-integer
     ,output v-value-logical
     ,output v-param-type
     ,INPUT-OUTPUT table-handle v-tth
     ) no-error .
  if v-value-logical then
  do:
    list-pl = "" .
    for each tt-doc-pl where tt-doc-pl.pl-code = var-code-temp,
        each ub.pl-gds-pump no-lock where ub.pl-gds-pump.gds-code = tt-doc-pl.gds-code and
             ub.pl-gds-pump.obj-code = tt-doc-pl.obj-code and
             ub.pl-gds-pump.obj-type = tt-doc-pl.obj-type and
             ub.pl-gds-pump.pl-code = tt-doc-pl.pl-code,
        each ub.pl-pump-nozzle  no-lock where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
             ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
             ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
             ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code:
      list-pl = substitute("&1&2&3:&4:&5", list-pl,
                 if list-pl = "" then "" else ";",
                 ub.pl-pump-nozzle.nozzle-code,
                 ub.pl-pump-nozzle.pump-code,
                 ub.pl-pump-nozzle.pl-code).
    end.
    run str/diallog.w ( input parparentproc
        ,input this-procedure
        ,input 'str/get-block-nozzle.p':U
        ,input (v-cntxt-obj-type + chr(4) +
        string(v-cntxt-obj-code) + chr(4) +
        string(0) + chr(4) +
        string(0) + chr(4) +
        chr(4) +
        chr(4) +
        chr(4) +
        substitute("&1,&2"
        ,"block"
        ,list-pl))
        ,input yes
        ,input ''
        ,input 'Блокировка пистолетов')
        no-error.
    if error-status :error then
    do:
      enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
      if v-is-lgas or v-is-lgas-corr
      then do:
        hide b-addinf in frame d-in-line.
      end .
      return no-apply .
    end.
    if return-value begins "Для кассы" then
    do:
      message return-value
      view-as alert-box question buttons yes-no update v-ok as logical  .
      if v-ok then run block-nozzle ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
      else do:
        message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
        view-as alert-box.
        enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
        if v-is-lgas or v-is-lgas-corr
        then do:
          hide b-addinf in frame d-in-line.
        end .
        return no-apply.
      end.
    end.
    else
    do:
      message "Блокировка пистолетов прошла успешно"
      view-as alert-box.
    end.
  end.
  run display-measure in this-procedure
    no-error .
  enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame d-in-line.
  end .
  if b-save :sensitive in frame d-in-line then do:
    apply "ENTRY":U to b-save in frame d-in-line .
  end.
  else do:
    apply "ENTRY":U to b-quit in frame d-in-line .
  end.
end.
on choose of menu-item m-rvs-af-1 in menu m-rvs-af
do:
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-af :type in frame d-in-line
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-in-line skip
    "Тип" self :type in frame d-in-line skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-af in frame d-in-line .
  if focus :handle <> b-rvs-af :handle in frame d-in-line then do:
    return no-apply .
  end.
end.
  if not chk-asi-polling (no)
    then return no-apply .
  disable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame d-in-line.
  end .
  run action-rvs-line in this-procedure
    ( input 'ИЗМЕНЕНИЕ':U
     ,input "meas":U
     ,input 'после_док':U
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
    if v-is-lgas or v-is-lgas-corr
    then do:
      hide b-addinf in frame d-in-line.
    end .
    return no-apply .
  end.
  run adm/shattri.p (
     input "get":U
     ,input  v-cntxt-obj-type
     ,input  v-cntxt-obj-code
     ,input  'petrol':U
     ,input  'block-nozzle':U
     ,output v-value-character
     ,output v-value-date
     ,output v-value-decimal
     ,output v-value-integer
     ,output v-value-logical
     ,output v-param-type
     ,INPUT-OUTPUT table-handle v-tth
     ) no-error .
  if v-value-logical then
  do:
    list-pl = "" .
    for each tt-doc-pl where tt-doc-pl.pl-code = var-code-temp,
      each ub.pl-gds-pump no-lock where ub.pl-gds-pump.gds-code = tt-doc-pl.gds-code and
      ub.pl-gds-pump.obj-code = tt-doc-pl.obj-code and
      ub.pl-gds-pump.obj-type = tt-doc-pl.obj-type and
      ub.pl-gds-pump.pl-code = tt-doc-pl.pl-code,
      each ub.pl-pump-nozzle  no-lock where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
      ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
      ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
      ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code:
        list-pl = substitute("&1&2&3:&4:&5", list-pl,
                   if list-pl = "" then "" else ";",
                   ub.pl-pump-nozzle.nozzle-code,
                   ub.pl-pump-nozzle.pump-code,
                   ub.pl-pump-nozzle.pl-code).
    end.
    run str/diallog.w ( input parparentproc
      ,input this-procedure
      ,input 'str/get-block-nozzle.p':U
      ,input (v-cntxt-obj-type + chr(4) +
      string(v-cntxt-obj-code) + chr(4) +
      string(0) + chr(4) +
      string(0) + chr(4) +
      chr(4) +
      chr(4) +
      chr(4) +
      substitute("&1,&2"
      ,"unblock"
      ,list-pl))
      ,input yes
      ,input ''
      ,input 'Разблокировка выбранных пистолетов') .
    if not error-status:error then
    do:
      if return-value begins "Для кассы" then
      do:
         message return-value
            view-as alert-box question buttons yes-no update v-ok as logical  .
         if v-ok then run unblock-nozzle ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
         else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
               view-as alert-box.
      end.
      else
      do:
         message if return-value begins "Ошибка" then return-value else "Разблокировка пистолетов прошла успешно"
           view-as alert-box.
      end.
    end.
    else
    do:
      enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
      if v-is-lgas or v-is-lgas-corr
      then do:
        hide b-addinf in frame d-in-line.
      end .
      return no-apply .
    end.
  end.
  run display-measure in this-procedure
    no-error .
  enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame d-in-line.
  end .
  if b-save :sensitive in frame d-in-line then do:
    apply "entry" to b-save in frame d-in-line .
  end.
  else do:
    apply "entry" to b-quit in frame d-in-line .
  end.
end.
on choose of menu-item m-rvs-bf-2 in menu m-rvs-bf
or choose of b-rvs-bf in frame d-in-line
do:
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-bf :type in frame d-in-line
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-in-line skip
    "Тип" self :type in frame d-in-line skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-bf in frame d-in-line .
  if focus :handle <> b-rvs-bf :handle in frame d-in-line then do:
    return no-apply .
  end.
end.
  run action-rvs-line in this-procedure
    ( input 'ПРОСМОТР':U
     ,input "edit":U
     ,input 'перед_док':U
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
end.
on choose of menu-item m-rvs-af-2 in menu m-rvs-af
or choose of b-rvs-af in frame d-in-line
do:
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-af :type in frame d-in-line
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-in-line skip
    "Тип" self :type in frame d-in-line skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-af in frame d-in-line .
  if focus :handle <> b-rvs-af :handle in frame d-in-line then do:
    return no-apply .
  end.
end.
  run action-rvs-line in this-procedure
    ( input 'ПРОСМОТР':U
     ,input "edit":U
     ,input 'после_док':U
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
end.
on choose of menu-item m-rvs-bf-3 in menu m-rvs-bf
do:
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-bf :type in frame d-in-line
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-in-line skip
    "Тип" self :type in frame d-in-line skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-bf in frame d-in-line .
  if focus :handle <> b-rvs-bf :handle in frame d-in-line then do:
    return no-apply .
  end.
end.
  disable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame d-in-line.
  end .
  run action-rvs-line in this-procedure
    ( input 'ИЗМЕНЕНИЕ':U
     ,input "edit":U
     ,input 'перед_док':U
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
    if v-is-lgas or v-is-lgas-corr
    then do:
      hide b-addinf in frame d-in-line.
    end .
    return no-apply .
  end.
  run adm/shattri.p (
      input "get":U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'petrol':U
      ,input  'block-nozzle':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  if v-value-logical then
  do:
    list-pl = "" .
    for each tt-doc-pl where tt-doc-pl.pl-code = var-code-temp,
       each ub.pl-gds-pump no-lock where ub.pl-gds-pump.gds-code = tt-doc-pl.gds-code and
       ub.pl-gds-pump.obj-code = tt-doc-pl.obj-code and
       ub.pl-gds-pump.obj-type = tt-doc-pl.obj-type and
       ub.pl-gds-pump.pl-code = tt-doc-pl.pl-code,
       each ub.pl-pump-nozzle  no-lock where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
       ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
       ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
       ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code:
      list-pl = substitute("&1&2&3:&4:&5", list-pl,
                 if list-pl = "" then "" else ";",
                 ub.pl-pump-nozzle.nozzle-code,
                 ub.pl-pump-nozzle.pump-code,
                 ub.pl-pump-nozzle.pl-code).
    end.
    run str/diallog.w ( input parparentproc
       ,input this-procedure
       ,input 'str/get-block-nozzle.p':U
       ,input (v-cntxt-obj-type + chr(4) +
       string(v-cntxt-obj-code) + chr(4) +
       string(0) + chr(4) +
       string(0) + chr(4) +
       chr(4) +
       chr(4) +
       chr(4) +
       substitute("&1,&2"
       ,"block"
       ,list-pl))
       ,input yes
       ,input ''
       ,input 'Блокировка пистолетов') .
    if not error-status:error then
    do:
      if return-value begins "Для кассы" then
      do:
        message return-value
           view-as alert-box question buttons yes-no update v-ok as logical  .
        if v-ok then run block-nozzle  in this-procedure ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
        else message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
              view-as alert-box.
      end.
      else
      do:
        message if return-value begins "Ошибка" then return-value else "Блокировка пистолетов прошла успешно"
        view-as alert-box.
      end.
    end.
    else
    do:
      enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
      if v-is-lgas or v-is-lgas-corr
      then do:
        hide b-addinf in frame d-in-line.
      end .
      return no-apply .
    end.
  end.
  run display-measure in this-procedure
    no-error .
  enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame d-in-line.
  end .
end.
on choose of menu-item m-rvs-af-3 in menu m-rvs-af
do:
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-rvs-af :type in frame d-in-line
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-in-line skip
    "Тип" self :type in frame d-in-line skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-rvs-af in frame d-in-line .
  if focus :handle <> b-rvs-af :handle in frame d-in-line then do:
    return no-apply .
  end.
end.
  disable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame d-in-line.
  end .
  run action-rvs-line in this-procedure
    ( input 'ИЗМЕНЕНИЕ':U
     ,input "edit":U
     ,input 'после_док':U
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
    if v-is-lgas or v-is-lgas-corr
    then do:
      hide b-addinf in frame d-in-line.
    end .
    return no-apply .
  end.
  run adm/shattri.p (
      input "get":U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'petrol':U
      ,input  'block-nozzle':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  if v-value-logical then
  do:
    list-pl = "" .
    for each tt-doc-pl where tt-doc-pl.pl-code = var-code-temp,
       each ub.pl-gds-pump no-lock where ub.pl-gds-pump.gds-code = tt-doc-pl.gds-code and
       ub.pl-gds-pump.obj-code = tt-doc-pl.obj-code and
       ub.pl-gds-pump.obj-type = tt-doc-pl.obj-type and
       ub.pl-gds-pump.pl-code = tt-doc-pl.pl-code,
       each ub.pl-pump-nozzle  no-lock where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
       ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
       ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
       ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code:
      list-pl = substitute("&1&2&3:&4:&5", list-pl,
                 if list-pl = "" then "" else ";",
                 ub.pl-pump-nozzle.nozzle-code,
                 ub.pl-pump-nozzle.pump-code,
                 ub.pl-pump-nozzle.pl-code).
    end.
    run str/diallog.w ( input parparentproc
       ,input this-procedure
       ,input 'str/get-block-nozzle.p':U
       ,input (v-cntxt-obj-type + chr(4) +
       string(v-cntxt-obj-code) + chr(4) +
       string(0) + chr(4) +
       string(0) + chr(4) +
       chr(4) +
       chr(4) +
       chr(4) +
       substitute("&1,&2"
       ,"unblock"
       ,list-pl))
       ,input yes
       ,input ''
       ,input 'Разблокировка выбранных пистолетов') .
    if not error-status:error then
    do:
      if return-value begins "Для кассы" then
      do:
        message return-value
           view-as alert-box question buttons yes-no update v-ok as logical  .
        if v-ok then run unblock-nozzle ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
        else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
              view-as alert-box.
      end.
      else
      do:
        message if return-value begins "Ошибка" then return-value else "Разблокировка пистолетов прошла успешно"
          view-as alert-box.
      end.
    end.
    else
    do:
      enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
      if v-is-lgas or v-is-lgas-corr
      then do:
        hide b-addinf in frame d-in-line.
      end .
      return no-apply .
    end.
  end.
  run display-measure in this-procedure
    no-error .
  enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame d-in-line .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame d-in-line.
  end .
end.
on choose of b-parts in frame d-in-line  do:
  define variable varprt-rec as recid no-undo.
  define buffer buf_doc-line for ub.doc-line .
define variable vss-include-info61 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if tt-fr-doc-line.price-cli :sensitive then apply "leave" to tt-fr-doc-line.price-cli in frame d-in-line.
  if tt-fr-doc-line.tot-cli   :sensitive then apply "leave" to tt-fr-doc-line.tot-cli   in frame d-in-line.
  run save-action in this-procedure
    ( input "light":U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
tr:
do transaction on error undo, leave :
   if parline-mode <> 'ПРОСМОТР':U then do:
      for each old-doc-line: delete old-doc-line. end.
      find first ub.doc-line where recid(ub.doc-line) = line-rec.
      create old-doc-line.
      buffer-copy ub.doc-line to old-doc-line.
      release ub.doc-line.
   end.
   find first buf_doc-line no-lock
     where recid(buf_doc-line) = line-rec
     .
   run str/parts-l.w
     (input  parparentproc
     ,input  buf_doc-line.obj-type
     ,input  buf_doc-line.obj-code
     ,input  buf_goods.gds-code
     ,input  buf_doc-line.doc-code
     ,input  parline-mode
     ,input  'документ':U
     ,input  'текущий':U
     ,input  'документ':U
     ,output varprt-rec
     ) no-error.
   if error-status :error then undo tr, return no-apply.
   if parline-mode <> 'ПРОСМОТР':U then do:
      if parline-mode = "ЦИКЛ":u or
         parline-mode = 'ДОБАВЛЕНИЕ':U then do:
         assign
           parline-mode = 'ИЗМЕНЕНИЕ':U.
      end.
      run update-doc-line-without-parts in this-procedure no-error.
      if error-status :error then undo tr, return no-apply.
   end.
end.
run ui-on in this-procedure.
if parline-mode <> 'ПРОСМОТР':U then do:
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run find-new-price-sale in this-procedure (
   input  pr-genmrg
  ,input  pr-naklvalue
  ,input  t-doc.doc-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  tt-fr-doc-line.price-rubl
  ,input  tt-fr-doc-line.price-base
  ,input  tt-fr-doc-line.price-rubl
  ,input  tt-fr-doc-line.price-base
  ,input-output tt-fr-doc-line.new-price-sale
    )
    no-error .
      if error-status :error then
      message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи(1)"
        view-as alert-box error
      .
      run disp-total in this-procedure .
end.
if b-save:sensitive then apply "entry" to b-save in frame d-in-line.
else apply "entry" to b-quit in frame d-in-line.
end.
on go of frame d-in-line
do:
  if valid-object (infoSectionsTotal)
  then do:
    define variable ii as integer no-undo .
    define variable v-pokmi-dll-version as character no-undo .
    define variable rdc-dnstvalue as character no-undo.
    define variable rdc-dnsttype  as character no-undo.
    define variable v-tank-weight-rvs     like ub.doc-line.fact-qnty    no-undo .
    define variable v-tank-vol-pomi-rvs   like ub.doc-line.fact-density no-undo .
    define variable v-new-fact-qnty       like ub.doc-line.fact-qnty    no-undo .
    define variable v-new-density         like ub.doc-line.fact-density no-undo .
    define variable v-new-cli-fact-qnty   like ub.doc-line.fact-qnty    no-undo .
    define variable v-new-sec-fact-qnty-kg as decimal no-undo .
    define variable v-calc-density as decimal no-undo .
    define variable v-log as logical no-undo .
    define variable v-need-save as logical no-undo .
    define buffer bf_rvs-doc for ub.rvs-doc .
    define variable infoSectionObj as class InfoSection no-undo.
    run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.
    if infoSectionsTotal:FlagTrn
    and rdc-dnstvalue = "pomi-rn"
    and not v-lgas-gds
    then do :
      v-need-save = no .
      do ii = 1 to infoSectionsTotal:SectionNum :
        infoSectionObj = infoSectionsTotal:GetInfoSectionProp(ii) .
        find first bf_rvs-doc no-lock where bf_rvs-doc.out-code = infoSectionsTotal:TrnDocNum no-error .
        if (infoSectionObj:TankWeightRvs = ? or infoSectionObj:TankWeightRvs <= 0)
        and available bf_rvs-doc
        then do :
          run calc-pomi-rvs (input ii,
                             input t-doc.doc-code,
                             input buf_goods.gds-code,
                             input-output infoSectionsTotal,
                             output v-tank-weight-rvs,
                             output v-tank-vol-pomi-rvs)
                             no-error .
          if infoSectionObj:AccMeth = 1
          then do :
            v-need-save = yes .
            v-calc-density = v-tank-weight-rvs / v-tank-vol-pomi-rvs .
            if v-calc-density = ?
            or v-calc-density <= 0
            or v-calc-density >= 1
            then do :
              message substitute("По результатам расчёта модуля ПОкМИ плотность выходит за допустимые значения!&1Масса, кг: &2&1Объём, л: &3", chr(10), v-tank-weight-rvs, v-tank-vol-pomi-rvs)
              view-as alert-box error .
              return no-apply .
            end .
            infoSectionsTotal:RNAlgo (integer(infoSectionObj:SectionName), output v-new-sec-fact-qnty-kg).
            infoSectionObj:FactQnty = v-new-sec-fact-qnty-kg / v-calc-density .
            infoSectionObj:FactDensity = v-calc-density .
          end .
        end .
      end .
      if v-need-save
      then do :
        infoSectionsTotal:SaveDB() .
        infoSectionsTotal:GetDBAllAttr().
        infoSectionsTotal:CalculateTotal().
        v-new-density = infoSectionsTotal:FactKgQntyTotal / infoSectionsTotal:FactQntyTotal.
        v-new-fact-qnty = infoSectionsTotal:FactQntyTotal.
        v-log = yes .
        if v-new-fact-qnty <> tt-fr-doc-line.fact-qnty
        or v-new-density <> tt-fr-doc-line.fact-density
        then do :
          if varupd-fact-qnty
          then do :
            message
              substitute( "По результатам измерения в резервуаре фактическое кол-во необходимо изменить." ) skip
              substitute( "Будем менять фактические" ) skip
              substitute( "количество на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
              substitute( "плотность на &1 ?", v-new-density ) skip
            view-as alert-box question buttons yes-no update v-log .
          end .
          else do :
            message
              substitute( "По результатам измерения в резервуаре фактическое кол-во товара изменяется на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
              substitute( "фактическая плотность на &1.", v-new-density ) skip
            view-as alert-box information .
          end .
        end .
        if v-log
        then do :
          run correct-fact-qnty in this-procedure
            ( input v-new-fact-qnty
             ,input v-new-density
            ) no-error .
        end .
        else do :
          return no-apply .
        end .
      end.
    end .
    if infoSectionsTotal:FlagTrn
    and infoSectionsTotal:IsSGDKK
    then do :
      define variable v-sec-fields as character no-undo .
      run adm/shattri.p (
        input "get":U
        ,input t-doc.obj-type
        ,input t-doc.obj-code
        ,input 'petrol':U
        ,input 'sec-fields':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output par-type
        ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if not error-status:error
      then do :
        v-sec-fields = v-value-character .
      end .
      do ii = 1 to infoSectionsTotal:SectionNum :
        if not infoSectionsTotal:GetInfoSectionProp(ii):alarm-SGDKK
        then do :
          if v-sec-fields > ''
          and lookup("accessIDLowerLevel", v-sec-fields) > 0
          and length(trim(infoSectionsTotal:GetInfoSectionProp(ii):AukKey)) < 4
          then do :
            message substitute( "Некорректная длина идентификатора доступа (ключа) нижнего уровня. Проверьте введенное в секции &1 значение и скорректируйте." , infoSectionsTotal:GetInfoSectionProp(ii):SectionName)
            view-as alert-box .
            return no-apply .
          end .
        end .
        else do :
          if length(trim(infoSectionsTotal:GetInfoSectionProp(ii):AukKey)) < 4
          and infoSectionsTotal:IsActnComm
          then do :
            message substitute( "Некорректная длина идентификатора доступа (ключа) верхнего уровня или одноразового кода для разблокировки API-адаптера. Проверьте введенное в секции &1 значение и скорректируйте." , infoSectionsTotal:GetInfoSectionProp(ii):SectionName)
            view-as alert-box .
            return no-apply .
          end .
        end .
      end .
    end .
  end .
  run save-action in this-procedure
    ( input "hard":U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
  if valid-object (infoSectionsTotal)
  then do:
    if parline-mode ne 'ПРОСМОТР':U
    then
       infoSectionsTotal:SaveDB().
    if infoSectionsTotal:isFlagKPChg
    then do:
      define variable varobj-shift-date as date      no-undo.
      define variable varobj-shift-num  as integer   no-undo.
      define variable varobj-shift-name as character no-undo.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  bf-trn-doc.obj-type
  ,input  bf-trn-doc.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  ) no-error .
      v-vid-action = 68 .
      v-vid-param = "Initiator=" + "User" + chr(4) +
                    "ResponsiblePerson=" + bf-trn-doc.cli-name + chr(4) +
                    "SHOP_NUM=" + string(bf-trn-doc.obj-code) + chr(4) +
                    "Contractor=" + bf-trn-doc.cli-name + chr(4) +
                    "DocNum=" + string(bf-trn-doc.doc-code) + chr(4) +
                    "FactDate=" + (if string(bf-trn-doc.fact-date) = ? then '' else string(bf-trn-doc.fact-date)) + chr(4) +
                    "DocType=" + string(bf-trn-doc.doc-type) + chr(4) +
                    "SHIFT_NUM_DOC=" + (if string(bf-trn-doc.shift-num) = ? then '' else string(bf-trn-doc.shift-num)) + (if string(bf-trn-doc.shift-date) = ? then '' else string(bf-trn-doc.shift-date)) + chr(4) +
                    "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + chr(4) +
                    "Status=" + string(bf-trn-doc.status_) + (if bf-trn-doc.flag then "+" else "-" ) + chr(4) +
                    "RESULT=1" + chr(4) +
                    "Description=" + "Включен комиссионный прием нефтепродукта" no-error.
      if available (bf-trn-doc)
      then do:
        run trg/userlog.p (
              input 'update_err':U
            , input 'trn-doc':U
            , input ( buffer bf-trn-doc :handle )
            , input v-vid-param
            , input v-vid-param
        ) no-error.
      end.
    end.
  end.
  delete object infoSecObj no-error .
  delete object infoSectionsTotal no-error.
  tanksForm:Dispose() no-error .
  delete object tanksForm no-error.
  if v-lgas-gds
  then do :
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t-doc.doc-code
                                                  and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                                  and buf_doc-line-attr.attr-code = "propan-perc"
                                                  no-error .
    if not available buf_doc-line-attr
    then do :
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code = t-doc.doc-code
        buf_doc-line-attr.gds-code = buf_goods.gds-code
        buf_doc-line-attr.attr-code = "propan-perc"
      .
    end .
    assign
      buf_doc-line-attr.attr-value = string(tt-fr-doc-line.propan-perc)
    .
    for first tt-doc-pl :
      find first bf_place-attr no-lock where bf_place-attr.obj-type  = tt-doc-pl.obj-type
                                         and bf_place-attr.obj-code  = tt-doc-pl.obj-code
                                         and bf_place-attr.pl-code   = tt-doc-pl.pl-code
                                         and bf_place-attr.attr-code = "place-gate-valve"
                                         no-error .
      if available bf_place-attr
      and logical(bf_place-attr.attr-value)
      then do :
        find first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t-doc.doc-code
                                                      and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                                      and buf_doc-line-attr.attr-code = "connect-hoses"
                                                      no-error .
        if not available buf_doc-line-attr
        then do :
          create buf_doc-line-attr .
          assign
            buf_doc-line-attr.doc-code = t-doc.doc-code
            buf_doc-line-attr.gds-code = buf_goods.gds-code
            buf_doc-line-attr.attr-code = "connect-hoses"
          .
        end .
        assign
          buf_doc-line-attr.attr-value = cb-connect-hoses
          buf_doc-line-attr.attr-value = ? when cb-connect-hoses = "empty"
        .
      end .
      else do :
        find first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t-doc.doc-code
                                                      and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                                      and buf_doc-line-attr.attr-code = "connect-hoses"
                                                      no-error .
        if available buf_doc-line-attr
        then do :
          delete buf_doc-line-attr .
        end .
      end .
    end .
  end .
end.
on choose of b-save in frame d-in-line
do:
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
end.
on choose of b-exit-cycl in frame d-in-line do:
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   assign parexit-cycle = yes.
  apply "end-error" to frame d-in-line.
  return no-apply.
end.
on end-error, stop of frame d-in-line do:
  apply "choose" to b-quit in frame d-in-line.
  return no-apply.
end.
on choose of b-quit in frame d-in-line
do:
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-quit in this-procedure.
end.
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F7, CTRL-S, CTRL-Ы of frame d-in-line anywhere do:
  if b-save :sensitive then DO: apply "CHOOSE":U to b-save in frame d-in-line. END.
  return no-apply.
end.
if valid-handle(active-window) and frame d-in-line:parent eq ?
then frame d-in-line:parent = active-window.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-in-line
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
on choose of b-help in frame d-in-line
do:
  apply "help":u to frame d-in-line .
end.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-in-line:width - 0.3
                fh            = frame d-in-line:first-child
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
on window-close of frame d-in-line apply "end-error":u to self.
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop    undo main-block, leave main-block :
   vargds-obj-fact-qnty:tooltip =  "Текущий остаток"  .
   find t-doc where recid( t-doc ) = pardoc-rec.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-lgas':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if varvalue = "yes"
      then v-is-lgas = true.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-lgas-corr':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if varvalue = "yes"
      then v-is-lgas-corr = true.
   find first buf_goods no-lock
     where recid(buf_goods) = pargds-rec
   .
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  t-doc.doc-code
  ,output v-hold-doc
  )  .
    run gds-attr-value in this-procedure
      (  input buf_goods.gds-code
        ,input 'fuel-type':U
        ,output v-attr-value
        ,output v-attr-type
       ) .
    if v-attr-value = "lgas" then
    do:
      v-lgas-gds = true.
    end.
   find first bf_sysconf no-lock
     where bf_sysconf.host-code = t-doc.host-code
   .
   if parline-mode = "ЦИКЛ":u or
      parline-mode = 'ДОБАВЛЕНИЕ':U then do:
      find ub.doc-line where ub.doc-line.prod-code = buf_goods.prod-code and
                          ub.doc-line.prod-type = buf_goods.prod-type and
                          ub.doc-line.artic     = buf_goods.artic     and
                          ub.doc-line.doc-code  = t-doc.doc-code  no-error.
      if available ub.doc-line then do:
         varlog = no.
         message 'Товар "' + buf_goods.artic + ' ' + buf_goods.gds-name + '"' +
                 ' производителя "' + buf_goods.prod-type + ' ' + string(buf_goods.prod-code) + '"' +
                 ' уже есть в этой накладной. Вы хотите изменить его ?'
              view-as alert-box question buttons yes-no update varlog.
         if not varlog then return error.
         assign parline-mode = 'ИЗМЕНЕНИЕ':U
                line-rec  = recid(ub.doc-line).
      end.
      else assign parline-mode = 'ДОБАВЛЕНИЕ':U
                  line-rec = ? .
   end.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-custm'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output custvalue
  ,output custtype
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output prtvalue
  ,output prttype
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'stfactpl'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output stfactplvalue
  ,output stfactpltype
  ) no-error .
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
define variable vss-include-info72 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_repeat-asi':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output l-repeat-asi
    )  .
end.
m-repeat-asi = return-value.
define variable par-1 as character no-undo .
define variable par-0 as logical   no-undo .
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplmrgn in g#library2
  (input  parparentproc
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output pr-genmrg
  ,output par-1
  ,output par-1
  ) no-error .
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplpnakl in g#library2
  (input  parparentproc
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output pr-naklvalue
  ,output par-0
  ,output par-0
  ) no-error .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if thbjattr_thbj-attr.prop-code = 'vat-ext'   then  dops        = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'slt-ext'   then  dop-slt     = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'vat-sum'   then  vat-sumvalue= string(thbjattr_thbj-attr.property-value-logical, "yes/no") .
end.
empty temp-table thbjattr_thbj-attr.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
   if is-petrolium = yes
     and is-pieces = no
   then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input t-doc.obj-type
  , input t-doc.obj-code
  ) .
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
   end.
   else do:
    if t-doc.ext-doc-type = 'ie':U and not t-doc.flag_ and t-doc.status_ = 'накл':U
    then do:
      run adm/shattri.p (
          input "get":U
          ,input t-doc.obj-type
          ,input t-doc.obj-code
          ,input 'nakl_par':U
          ,input  "edit-fact-wayb"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output par-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
        ) no-error .
        if error-status :error then .
        else v-edit-fact-wayb = v-value-logical.
    end.
   end.
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  )  .
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
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'vat-goods' then v-vat-goods = thbjattr_thbj-attr.property-value-logical .
        if thbjattr_thbj-attr.prop-code = 'round-vat-sum' then v-round-vat-sum = thbjattr_thbj-attr.property-value-logical .
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'negais':U ,
                       output varvalue ,
                       output vartype )  .
     if varvalue <> ? and varvalue <> ""
       then isEgais = true.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-fuel':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if varvalue = "yes"
      then is-fuel = true.
   assign
     rdtaxcdvalue  = '3':U
     exctaxcdvalue = '4':U
     vattaxcdvalue = '1':U.
   case parline-mode :
     when 'ИЗМЕНЕНИЕ':U then do:
       find ub.doc-line where recid (ub.doc-line) = line-rec no-error.
       if not available ub.doc-line then do:
          message "Неправильный выбор строки." view-as alert-box.
          return error.
       end.
     end.
     when 'ПРОСМОТР':U then do:
       b-quit:label = "Выход" .
       find ub.doc-line where recid (ub.doc-line) = line-rec no-lock no-error.
       if not available ub.doc-line then do:
          message "Неправильный выбор строки." view-as alert-box.
          return error.
       end.
     end.
   end.
   assign frame d-in-line:title = "Строка накладной № " + t-doc.doc-code + "    - " + parline-mode.
  if t-doc.contract-code > 0 and not is-petrolium then do :
    find first buf_contract-specif no-lock
         where buf_contract-specif.host-code    = t-doc.host-code
           and buf_contract-specif.contract-num = t-doc.contract-code
           and buf_contract-specif.gds-code     = buf_goods.gds-code no-error .
    if available buf_contract-specif then assign
      v-specif-unit-list     = buf_contract-specif.unit-cli
      v-specif-cli-base-rate = buf_contract-specif.cli-base-rate
    .
    else assign
      v-specif-unit-list     = ""
      v-specif-cli-base-rate = 1
    .
  end .
   run ui-on in this-procedure no-error.
   if error-status :error then do:
     message "Ошибка " skip
             return-value
     view-as alert-box error.
     return error.
   end.
   if v-is-looksec
   then do :
     define variable v-rvd-own-nb as logical no-undo .
     run adm/shattri.p (
          input "get":U
          ,input t-doc.obj-type
          ,input t-doc.obj-code
          ,input 'petrol':U
          ,input  "rvd-own-nb"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output par-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
        ) no-error .
     if error-status :error then v-rvd-own-nb = false .
     else v-rvd-own-nb = v-value-logical.
     if v-rvd-own-nb = false
     and t-doc.cli-code > 0
     then do :
       find first ub.clients-attr no-lock where ub.clients-attr.obj-type = t-doc.cli-type
                                            and ub.clients-attr.obj-code = t-doc.cli-code
                                            and ub.clients-attr.attr-code = 'owner-code':U
                                            no-error .
       if available ub.clients-attr
       and ub.clients-attr.attr-value > ""
       then do :
         if ub.clients-attr.attr-value = "орг" + string(t-doc.host-code)
         then do :
           disable b-quit with frame d-in-line.
         end .
       end .
     end .
     apply "choose" to b-docsec.
   end .
   case parline-mode:
     when 'ПРОСМОТР':U then wait-for go of frame d-in-line focus b-quit.
     otherwise do:
       if not t-doc.flag_ and not isEgais then do:
         if tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line then do:
           if tt-fr-doc-line.cli-qnty <> ?
             and tt-fr-doc-line.cli-qnty <> 0.0
             and tt-fr-doc-line.doc-density :sensitive in frame d-in-line
             and ( tt-fr-doc-line.doc-density = 0.0
                   or tt-fr-doc-line.doc-density = ?
                 )
           then do:
             wait-for go of frame d-in-line focus tt-fr-doc-line.doc-density.
           end.
           else do:
             wait-for go of frame d-in-line focus tt-fr-doc-line.cli-qnty.
           end.
         end.
         else do:
           if tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line then do:
             if tt-fr-doc-line.doc-qnty <> ?
               and tt-fr-doc-line.doc-qnty <> 0.0
               and tt-fr-doc-line.doc-density :sensitive in frame d-in-line
               and ( tt-fr-doc-line.doc-density = 0.0
                     or tt-fr-doc-line.doc-density = ?
                   )
             then do:
               wait-for go of frame d-in-line focus tt-fr-doc-line.doc-density.
             end.
             else do:
               wait-for go of frame d-in-line focus tt-fr-doc-line.doc-qnty.
             end.
           end.
           else do:
             if tt-fr-doc-line.doc-density :sensitive in frame d-in-line
               and ( tt-fr-doc-line.doc-density = 0.0
                     or tt-fr-doc-line.doc-density = ?
                   )
             then do:
               wait-for go of frame d-in-line focus tt-fr-doc-line.doc-density.
             end.
             else do:
               wait-for go of frame d-in-line.
             end.
           end.
         end.
       end.
       else do:
         if isEgais
         then do:
           disable tt-fr-doc-line.unit-cli r-units tt-fr-doc-line.cli-qnty tt-fr-doc-line.doc-qnty tt-fr-doc-line.cli-base-rate with frame d-in-line.
         end.
         if varupd-fact-qnty = no then do:
           wait-for go of frame d-in-line focus b-save.
         end.
         else do:
           wait-for go of frame d-in-line focus tt-fr-doc-line.fact-qnty.
         end.
       end.
     end.
   end case.
end.
run disable_ui in this-procedure.
procedure disable_ui :
  disable all with frame d-in-line.
  hide frame d-in-line.
end procedure.
procedure ui-on :
define buffer cst-parts         for ub.parts.
define buffer cst-parts-another for ub.parts.
define buffer last-line         for ub.doc-line.
define buffer gold-line         for ub.doc-line.
define buffer bf_units          for ub.units.
define buffer bf_doc-line-attr  for ub.doc-line-attr.
define buffer bf_parts          for ub.parts.
define buffer bf-another_parts  for ub.parts.
define buffer bf_contract       for ub.contract.
define buffer bf_gds-obj        for ub.gds-obj.
define buffer bf_trn-doc        for ub.trn-doc.
define buffer bf_trn-ist        for ub.trn-doc.
define buffer bf_doc-line-ist   for ub.doc-line.
define buffer bf_clients        for ub.clients.
define buffer bf_doc-line       for ub.doc-line.
define buffer buf_country       for ub.country.
do on error undo, return error return-value :
case parline-mode :
  when 'ПРОСМОТР':U  then prt-mode = 'ПРОСМОТР':U.
  when 'ИЗМЕНЕНИЕ':U  then prt-mode = 'ШКАЛА':U.
  when 'ДОБАВЛЕНИЕ':U then prt-mode = 'ШКАЛА':U.
end.
disable all with frame d-in-line.
assign
  tt-fr-doc-line.doc-density            :visible = no
  tt-fr-doc-line.temperature            :visible = no
  tt-fr-doc-line.fact-density           :visible = no
  tt-fr-doc-line.num-place              :visible = no
  tt-fr-doc-line.wt-brutto              :visible = no
  tt-fr-doc-line.pl-code                :visible = no
  b-place                               :visible = no
  tt-fr-doc-line.measure-qnty           :visible = no
  tt-fr-doc-line.state-measure-qnty     :visible = no
  tt-fr-doc-line.state-measure-cli-qnty :visible = no
  tt-fr-doc-line.trk-cli-qnty           :visible = no
  road-tax-cli                          :visible = no
  rect-tot                              :visible = no
  tt-fr-doc-line.wt-place               :visible = no
  b-rvs-bf                              :visible = no
  b-rvs-af                              :visible = no
  b-addinf                              :visible = no
  b-docsec                              :visible = no
  b-alc-attr                            :visible = no
.
hide tt-fr-doc-line.propan-perc cb-connect-hoses in frame d-in-line.
find t-doc where recid(t-doc) = pardoc-rec.
find first tt-fr-doc-line no-error.
if not available tt-fr-doc-line then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_kndinpin in g#lib-calc
  (
   input  buf_goods.gds-code
  ,input  t-doc.cli-type
  ,input  t-doc.cli-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output varext-gds-type
  ,output varcli-qnty-input
  ,output vardensity-input
  ,output varcli-base-rate-input
  ,output vardoc-qnty-input
  ,output varfact-qnty-input
  ,output varprice-cli-input
  ,output varbase-price-input
  ,output vartax-3-input
  ,output varcli-qnty-calc
  ,output vardensity-calc
  ,output varcli-base-rate-calc
  ,output vardoc-qnty-calc
  ,output varfact-qnty-calc
  ,output varprice-cli-calc
  ,output varbase-price-calc
  ,output vartax-3-calc
  ,output varround
  ) no-error.
   if error-status :error then return error "Ошибка при вызове процедуры kndinpin(in-line.w)" + return-value.
   if parline-mode = 'ДОБАВЛЕНИЕ':U then do:
     run cr-tt-fr-doc-line in this-procedure
       ( input "create"
        ,input ?
       ) no-error.
     if error-status :error then return error.
   end.
   else do:
     run cr-tt-fr-doc-line in this-procedure
       ( input "no-create"
        ,input line-rec
       ) no-error.
     if error-status :error then return error.
   end.
end.
if v-is-lgas-corr
then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'trn-lgas-corr':U ,
                       output varvalue ,
                       output vartype )  .
  find first bf_trn-ist no-lock where bf_trn-ist.doc-code = varvalue no-error.
  if not available (bf_trn-ist)
    then return error "Не найден документ-источник: " + varvalue.
  find first bf_doc-line-ist where bf_doc-line-ist.doc-code = bf_trn-ist.doc-code and
    buf_goods.artic     = bf_doc-line-ist.artic     and
    buf_goods.prod-type = bf_doc-line-ist.prod-type and
    buf_goods.prod-code = bf_doc-line-ist.prod-code no-lock no-error.
  if not available (bf_trn-ist)
    then return error "Не найден товар в документе-источника: " + string (buf_goods.gds-code).
  vardensity-ist = bf_doc-line-ist.fact-density.
end.
run tax-name in this-procedure
  ( input 'rdt':U
   ,output varroad-tax-label
  ) no-error.
assign
  tt-fr-doc-line.road-tax :label in frame d-in-line = varroad-tax-label
  road-tax-cli :label            in frame d-in-line = varroad-tax-label
.
if
   parline-mode = 'ДОБАВЛЕНИЕ':U then do:
   if v-insalepr = true then do:
     run calc-price-sale  in this-procedure no-error.
     if error-status :error then do:
        message "Ошибка при установке продажной цены." skip
                return-value
                view-as alert-box.
        return error.
     end.
   end.
   else do:
     if not( is-petrolium = yes  and is-pieces = no )
     then do:
       run cpprclig in this-procedure   (
       input        t-doc.doc-code                      ,
       input        t-doc.cli-code                      ,
       input        t-doc.cli-type                      ,
       input        t-doc.host-code                     ,
       input        t-doc.base-rate                     ,
       input        t-doc.base-scale                    ,
       input        t-doc.exch-rate                     ,
       input        t-doc.exch-scale                    ,
       input        t-doc.vat-type                      ,
       input        t-doc.slt-type                      ,
       input        tt-fr-doc-line.artic                ,
       input        tt-fr-doc-line.prod-type            ,
       input        tt-fr-doc-line.prod-code            ,
       input        yes                                 ,
       input        tt-fr-doc-line.cli-base-rate        ,
       input        tt-fr-doc-line.transport-rubl       ,
       input        tt-fr-doc-line.other-rubl           ,
       output       tt-fr-doc-line.price-cli            ,
       output       tt-fr-doc-line.price-base           ,
       output       tt-fr-doc-line.price-rubl           ,
       input-output tt-fr-doc-line.vat-pc               ,
       input-output tt-fr-doc-line.slt-pc               ,
       input-output tt-fr-doc-line.road-tax             ,
       input-output tt-fr-doc-line.excise               ) no-error.
       if v-vat-goods = true
       and t-doc.vat-type <> 'без':U
       then do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  t-doc.host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output tt-fr-doc-line.vat-pc
  ) no-error .
       end.
       if tt-fr-doc-line.vat-pc = ?        and
          t-doc.vat-type <> 'без':U then do:
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  t-doc.host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output tt-fr-doc-line.vat-pc
  ) no-error .
       end.
          if  dops > '' and  not f-chekval(input dops, input tt-fr-doc-line.vat-pc)   then do:
             message "Неверное значение НДС:" tt-fr-doc-line.vat-pc  skip
                 "Разрешенные значения: " dops "."
                 view-as alert-box error.
             return error.
          end.
          if dop-slt > '' and not f-chekval(input dop-slt , input tt-fr-doc-line.slt-pc) then do:
             message "Неверное значение НсП:" tt-fr-doc-line.slt-pc  skip
                 "Разрешенные значения: " dop-slt "."
                 view-as alert-box error.
             return error.
          end.
       if tt-fr-doc-line.slt-pc = ? and
         t-doc.slt-type <> 'без':U then do:
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  t-doc.host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output tt-fr-doc-line.slt-pc
  ) no-error .
       end.
       display
         tt-fr-doc-line.price-cli
         tt-fr-doc-line.price-base
         tt-fr-doc-line.price-rubl
         tt-fr-doc-line.vat-pc
         tt-fr-doc-line.slt-pc
         tt-fr-doc-line.road-tax
         tt-fr-doc-line.excise
       with frame d-in-line.
       if can-do('запрос':U, t-doc.status_ ) and
           (not t-doc.flag_) then do:
           find first ub.goods no-lock where recid(ub.goods)  = recid(buf_goods) .
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each ub.gds-obj where ub.gds-obj.prod-type = ub.goods.prod-type
                   and ub.gds-obj.prod-code = ub.goods.prod-code
                   and ub.gds-obj.artic     = ub.goods.artic
                   and ub.gds-obj.host-code = t-doc.host-code
                   and ub.gds-obj.obj-type  = t-doc.obj-type
                   and ub.gds-obj.obj-code  = t-doc.obj-code no-lock,
  first bf-trn-doc where bf-trn-doc.doc-code = ub.gds-obj.in-code no-lock,
  first d-l-b where d-l-b.doc-code  = ub.gds-obj.in-code
                and d-l-b.artic     = ub.goods.artic
                and d-l-b.prod-type = ub.goods.prod-type
                and d-l-b.prod-code = ub.goods.prod-code no-lock
  by bf-trn-doc.fact-order descending:
     ASSIGN tt-fr-doc-line.price-cli  = d-l-b.price-cli
            tt-fr-doc-line.price-rubl = d-l-b.price-rubl
            tt-fr-doc-line.price-base = d-l-b.price-base.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   t-doc.doc-code
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,input   t-doc.vat-type
  ,input   t-doc.slt-type
  ,input   tt-fr-doc-line.artic
  ,input   tt-fr-doc-line.prod-type
  ,input   tt-fr-doc-line.prod-code
  ,input   tt-fr-doc-line.price-cli
  ,input   tt-fr-doc-line.cli-base-rate
  ,input   tt-fr-doc-line.price-rubl
  ,input   tt-fr-doc-line.vat-pc
  ,input   tt-fr-doc-line.slt-pc
  ,input   tt-fr-doc-line.road-tax
  ,input   tt-fr-doc-line.transport-rubl
  ,input   tt-fr-doc-line.other-rubl
  ,output  varprice-cli
  ,output  varprice-cli-unit-base
  ,output  varprice-road-tax
  ,output  varprice-other-exp
  ,output  varprice-transport-exp
  ,output  varprice-without-abs
  ,output  varprice-slt
  ,output  varprice-no-slt
  ,output  varprice-vat
  ,output  varprice-no-vat-slt
  ,output  varprice-rubl
  ,output  varprice-road-tax-rubl
  ,output  varprice-other-exp-rubl
  ,output  varprice-transport-exp-rubl
  ,output  varprice-without-abs-rubl
  ,output  varprice-slt-rubl
  ,output  varprice-no-slt-rubl
  ,output  varprice-vat-rubl
  ,output  varprice-no-vat-slt-rubl
  ,output  varprice-base
  ,output  varprice-road-tax-base
  ,output  varprice-other-exp-base
  ,output  varprice-transport-exp-base
  ,output  varprice-without-abs-base
  ,output  varprice-slt-base
  ,output  varprice-no-slt-base
  ,output  varprice-vat-base
  ,output  varprice-no-vat-slt-base
  ) no-error.
       if error-status:error then do:
         return error "Ошибка при пересчете линии документа".
       end.
       ASSIGN tt-fr-doc-line.price-cli  = varprice-cli
              tt-fr-doc-line.price-rubl = varprice-rubl
              tt-fr-doc-line.price-base = varprice-base.
     leave.
end.
       end.
     end.
   end.
   run calc-all in this-procedure ( input ( if varprice-cli-input = yes then varprice-cli-calc
                                                                        else varbase-price-calc ) ) no-error.
   if error-status :error then return no-apply.
   if custvalue = "yes" then do:
     assign tt-fr-doc-line.num-place = 1.
     display tt-fr-doc-line.num-place with frame d-in-line.
   end.
   assign
     tt-fr-doc-line.alpha1 = buf_goods.alpha1 .
   find first buf_country no-lock where buf_country.alpha1 = tt-fr-doc-line.alpha1 no-error .
   if available buf_country then do:
    assign
      tt-fr-doc-line.country-code = buf_country.num-code
      tt-fr-doc-line.short-name   = buf_country.short-name
    .
   end.
   if is-petrolium = yes
     and is-pieces = no
     and buf_goods.unit-base = buf_goods.unit-cli
   then do:
     assign
       tt-fr-doc-line.doc-density   = 1.0
       tt-fr-doc-line.cli-base-rate = 1.0
     .
     display
       tt-fr-doc-line.doc-density
     with frame d-in-line.
   end.
end.
else do:
  find ub.doc-line where recid( ub.doc-line ) = line-rec.
  find ub.inv-line where
       ub.inv-line.doc-code  = ub.doc-line.doc-code  and
       ub.inv-line.artic     = ub.doc-line.artic     and
       ub.inv-line.prod-type = ub.doc-line.prod-type and
       ub.inv-line.prod-code = ub.doc-line.prod-code no-error.
  assign
     tt-fr-doc-line.cli-qnty       = ub.doc-line.cli-qnty
     tt-fr-doc-line.doc-qnty       = ub.doc-line.doc-qnty
     tt-fr-doc-line.fact-qnty      = ub.doc-line.fact-qnty
     tt-fr-doc-line.fact-qnty-kg   = ub.doc-line.fact-qnty * ub.doc-line.fact-density
     tt-fr-doc-line.price-base     = ub.doc-line.price-base
     tt-fr-doc-line.price-rubl     = ub.doc-line.price-rubl
     tt-fr-doc-line.doc-density    = ub.doc-line.doc-density
     tt-fr-doc-line.fact-density   = ub.doc-line.fact-density
     tt-fr-doc-line.temperature    = ub.doc-line.temperature
     tt-fr-doc-line.road-tax       = ub.doc-line.road-tax
     tt-fr-doc-line.excise         = ub.doc-line.excise
     tt-fr-doc-line.transport-base = ub.doc-line.transport-base
     tt-fr-doc-line.other-base     = ub.doc-line.other-base
     tt-fr-doc-line.transport-rubl = ub.doc-line.transport-rubl
     tt-fr-doc-line.other-rubl     = ub.doc-line.other-rubl
     tt-fr-doc-line.wt-brutto      = ub.doc-line.wt-brutto
     tt-fr-doc-line.num-place      = ub.doc-line.num-place
     tt-fr-doc-line.wt-place       = ( tt-fr-doc-line.wt-brutto / tt-fr-doc-line.num-place )
  .
  if tt-fr-doc-line.doc-qnty  = tt-fr-doc-line.fact-qnty
    and tt-fr-doc-line.cli-qnty  = tt-fr-doc-line.fact-qnty-kg
    and tt-fr-doc-line.doc-density  <> tt-fr-doc-line.fact-density
  then do:
    assign
      tt-fr-doc-line.fact-density = tt-fr-doc-line.doc-density
    .
  end.
  if v-lgas-gds
  then do :
    find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = tt-fr-doc-line.doc-code and
                                      bf_doc-line-attr.gds-code  = buf_goods.gds-code and
                                      bf_doc-line-attr.attr-code = "propan-perc"
                                      no-error.
    if available bf_doc-line-attr
    then do :
      tt-fr-doc-line.propan-perc = decimal(bf_doc-line-attr.attr-value) no-error .
    end .
    find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = tt-fr-doc-line.doc-code and
                                      bf_doc-line-attr.gds-code  = buf_goods.gds-code and
                                      bf_doc-line-attr.attr-code = "connect-hoses"
                                      no-error.
    if available bf_doc-line-attr
    then do :
      if bf_doc-line-attr.attr-value = ?
      then cb-connect-hoses = "empty" .
      else cb-connect-hoses = bf_doc-line-attr.attr-value .
      display cb-connect-hoses with frame d-in-line.
    end .
  end .
  if parinplnsum = yes then do:
    find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = tt-fr-doc-line.doc-code and
                                      bf_doc-line-attr.gds-code  = buf_goods.gds-code and
                                      bf_doc-line-attr.attr-code = "tot-cli"               no-error.
    if not available bf_doc-line-attr then do:
     create bf_doc-line-attr.
     assign
     bf_doc-line-attr.doc-code  = t-doc.doc-code
     bf_doc-line-attr.gds-code  = buf_goods.gds-code
     bf_doc-line-attr.attr-code = "tot-cli".
     bf_doc-line-attr.attr-value = string(doc-line.cli-qnty * ub.doc-line.price-cli).
    end.
    assign
      tt-fr-doc-line.type-inp-sum = yes
      tt-fr-doc-line.tot-cli      = decimal (bf_doc-line-attr.attr-value)
      tt-fr-doc-line.price-cli    = tt-fr-doc-line.tot-cli / tt-fr-doc-line.cli-qnty.
  end.
  else do:
    assign
      tt-fr-doc-line.type-inp-sum = no
      tt-fr-doc-line.price-cli    = ub.doc-line.price-cli.
  end.
  display
   tt-fr-doc-line.cli-qnty
   tt-fr-doc-line.doc-qnty
   tt-fr-doc-line.price-cli
   tt-fr-doc-line.price-base
   tt-fr-doc-line.price-rubl
   tt-fr-doc-line.transport-base
   tt-fr-doc-line.other-base
   tt-fr-doc-line.transport-rubl
   tt-fr-doc-line.other-rubl
   with frame d-in-line.
  if custvalue = "yes" then display tt-fr-doc-line.wt-brutto
                                    tt-fr-doc-line.num-place
                                    tt-fr-doc-line.wt-place  with frame d-in-line.
  if t-doc.flag_ = yes or t-doc.status_ = 'факт':U or v-edit-fact-wayb then do:
    display tt-fr-doc-line.fact-qnty with frame d-in-line.
    if is-petrolium = yes and is-pieces = no then do:
      display tt-fr-doc-line.fact-qnty-kg with frame d-in-line.
      display tt-fr-doc-line.fact-density with frame d-in-line.
    end.
  end.
  else do:
    hide
      tt-fr-doc-line.fact-qnty    in frame d-in-line
      tt-fr-doc-line.fact-qnty-kg in frame d-in-line
      tt-fr-doc-line.fact-density in frame d-in-line.
    .
  end.
  if is-petrolium = yes then do:
     if is-pieces = no then do:
        display
          tt-fr-doc-line.doc-density
          tt-fr-doc-line.temperature
        with frame d-in-line.
     end.
     display
       tt-fr-doc-line.excise
     with frame d-in-line.
  end.
  if hvrdtax (recid(buf_goods)) then do:
     display
        tt-fr-doc-line.road-tax
        with frame d-in-line.
     if varr-b = "rubl":u then do:
       assign  road-tax-cli = tt-fr-doc-line.road-tax / t-doc.exch-rate * t-doc.exch-scale * tt-fr-doc-line.cli-base-rate                             .
     end.
     else do:
       assign  road-tax-cli = tt-fr-doc-line.road-tax / t-doc.exch-rate * t-doc.exch-scale * tt-fr-doc-line.cli-base-rate
                              * t-doc.base-rate / t-doc.base-scale.
     end.
     display road-tax-cli with frame d-in-line.
  end.
end.
IF mImagePh THEN
DO:
    IF AVAILABLE buf_goods THEN
    DO:
        DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
        DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
        RUN gds-attr-value (buf_goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
        RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, INPUT buf_goods.gds-code ,OUTPUT vImageList).
        vCh = ENTRY (1, vImageList, ",":U).
    END.
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
END.
IF mImagePh THEN
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
run plgdsfnd in this-procedure
  ( input  no
   ,input  t-doc.obj-type
   ,input  t-doc.obj-code
   ,input  buf_goods.gds-code
   ,output varrvs-place
   ,output var-code-temp
  ) no-error.
if error-status :error then do:
  message
    "Ошибка при проверке привязки товара к складскому месту: " skip
    tt-fr-doc-line.artic " " tt-fr-doc-line.prod-type " " tt-fr-doc-line.prod-code skip
    return-value "." view-as alert-box error.
  return error.
end.
if varrvs-place = yes then do:
  run init-tt-doc-pl in this-procedure
    no-error .
  enable
    b-place
    with frame d-in-line
  .
  find first tt-doc-pl no-lock
    no-error.
  if not available tt-doc-pl
    and not ( parline-mode = "ЦИКЛ":u
              or parline-mode = 'ДОБАВЛЕНИЕ':U
            )
  then do:
      message
        substitute( "Товар &1 &2 &3", tt-fr-doc-line.artic, tt-fr-doc-line.prod-type, tt-fr-doc-line.prod-code ) skip
        "не распределен по местам хранения."
        view-as alert-box.
  end.
  if is-petrolium = yes
    and is-pieces = no
  then do:
    if parline-mode <> 'ПРОСМОТР':U then
    do:
      assign
        b-rvs-bf:popup-menu in frame d-in-line = menu m-rvs-bf:handle
        b-rvs-bf:menu-mouse = 1
        b-rvs-af:popup-menu in frame d-in-line = menu m-rvs-af:handle
        b-rvs-af:menu-mouse = 1
      .
    end.
    if not v-lgas-gds
    then
      enable
        b-docsec
        with frame d-in-line.
    infoSectionsTotal = new InfoSectionsTotal(t-doc.doc-code, buf_goods.gds-code, parline-mode).
    if infoSectionsTotal:Mode = "ДОБАВЛЕНИЕ" and infoSectionsTotal:SectionNum = 0 then do:
      infoSectionsTotal:NewSection().
    end.
    if not (v-is-lgas or v-is-lgas-corr)
    then do:
define variable vss-include-info83 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_petrol-сommission':U
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
          infoSectionsTotal:IsActnComm = true.
        end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'car-num':U ,
                       output varcar-num ,
                       output vartype )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'acc-ship':U ,
                       output varvalue ,
                       output vartype )  .
      varrn-acc-ship = decimal (varvalue) no-error.
      if varrn-acc-ship = ?
        then varrn-acc-ship = 0.
    end.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input t-doc.obj-type
  , input t-doc.obj-code
  ) .
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-rvs)
    then run str/lib-rvs.p persistent no-error .
    assign
      infoSectionsTotal:CliQntyInput = varcli-qnty-input
      infoSectionsTotal:DensityInput = vardensity-input
      infoSectionsTotal:DocQntyInput = vardoc-qnty-input
      infoSectionsTotal:IsRNAlgo = if ptrlprop-algoincome = 2 then true else false
      infoSectionsTotal:PercAcc = varpercauto
      infoSectionsTotal:AccShip = varrn-acc-ship
      infoSectionsTotal:CarNum = varcar-num
      infoSectionsTotal:IsSGDKK = no
      infoSectionsTotal:FlagTrn = t-doc.flag_
      infoSectionsTotal:Sts = t-doc.status_
      infoSectionsTotal:Parentproc = parparentproc
      infoSectionsTotal:lRepeatAsi = l-repeat-asi
      infoSectionsTotal:mRepeatAsi = m-repeat-asi
      infoSectionsTotal:petrol_block-nozzle = ptrlprop-block-nozzle
      infoSectionsTotal:in-line-handle = this-procedure
    .
    find first sep_auto-tank-attr no-lock where sep_auto-tank-attr.auto-num = varcar-num
                                            and sep_auto-tank-attr.attr-code = "auto-sep"
                                            no-error.
    if available sep_auto-tank-attr
    and logical(sep_auto-tank-attr.attr-value)
    then do :
      infoSectionsTotal:IsSGDKK = yes .
    end .
    if parline-mode <> 'ДОБАВЛЕНИЕ':U then do:
      infoSectionsTotal:GetDBAllAttr().
      v-prt-start-real-date = infoSectionsTotal:StartRealDate.
      v-prt-start-real-time = infoSectionsTotal:StartRealTime.
      v-prt-end-real-date = infoSectionsTotal:EndRealDate.
      v-prt-end-real-time = infoSectionsTotal:EndRealTime.
    end.
    if parline-mode <> 'ДОБАВЛЕНИЕ':U
    then do :
      infoSectionsTotal:GetDBAllAttr().
      do ii = 1 to infoSectionsTotal:SectionNum :
        if infoSectionsTotal:GetInfoSectionProp(ii):IsKP
        then do :
          infoSectionsTotal:IsKP = yes .
          if infoSectionsTotal:GetInfoSectionProp(ii):AccMeth = 1
          then do :
            infoSectionsTotal:IsKPrvs = yes .
          end .
        end .
      end .
    end .
    run display-measure in this-procedure
    no-error .
    if t-doc.flag_ = true
      or t-doc.status_ = 'факт':U
    then do:
      hide
        b-docsec
        in frame d-in-line.
      run display-b-rvs in this-procedure
        no-error .
      enable
        b-addinf
        with frame d-in-line.
      run display-measure in this-procedure
        no-error .
    end.
    else do:
      if parline-mode <> 'ПРОСМОТР':U then do:
        if vardensity-input = true then do:
          enable
            tt-fr-doc-line.doc-density
            with frame d-in-line.
        end.
        enable
          tt-fr-doc-line.temperature
          with frame d-in-line.
      end.
    end.
    define variable NormWast as class ibs.th.ref.normwastsub no-undo.
    if stfactplvalue <> ""  then
    do:
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
      if error-status :error then
      do:
        message
          vss-workfile vss-revision vss-description skip
          "Разборе строки параметра stfactpl" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return error .
      end.
    end.
    NormWast = new ibs.th.ref.normwastsub ().
    NormWast:ParGdsOAttr:GdsCode = buf_goods.gds-code.
    NormWast:ParGdsOAttr:ObjType = t-doc.obj-type.
    NormWast:ParGdsOAttr:ObjCode = t-doc.obj-code.
    NormWast:ParGdsOAttr:OnDate = today.
    run gds-o-normal-wastage-value in this-procedure
    ( input-output NormWast).
    infoSectionsTotal:NormalWastage = NormWast:NormalWastageTransDate .
    if v-is-lgas or v-is-lgas-corr
    then do:
      hide
        b-docsec
        b-addinf
        in frame d-in-line.
      display tt-fr-doc-line.propan-perc with frame d-in-line.
      if parline-mode <> 'ПРОСМОТР':U
      and not t-doc.flag_
      then do:
        enable tt-fr-doc-line.propan-perc with frame d-in-line.
        for first tt-doc-pl :
          find first bf_place-attr no-lock where bf_place-attr.obj-type  = tt-doc-pl.obj-type
                                             and bf_place-attr.obj-code  = tt-doc-pl.obj-code
                                             and bf_place-attr.pl-code   = tt-doc-pl.pl-code
                                             and bf_place-attr.attr-code = "place-gate-valve"
                                             no-error .
          if available bf_place-attr
          and logical(bf_place-attr.attr-value)
          then do :
            enable cb-connect-hoses with frame d-in-line .
          end .
          else do :
            disable cb-connect-hoses with frame d-in-line .
          end .
        end .
      end .
    end.
    else do :
      hide tt-fr-doc-line.propan-perc cb-connect-hoses in frame d-in-line.
    end .
    if parline-mode <> 'ДОБАВЛЕНИЕ':U then infoSectionsTotal:GetDBAllAttr().
    tanksForm = new ibs.th.str.ptrl.forms.tanksections(infoSectionsTotal).
     if stfactplvalue <> ""  then do:
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
end.
run new-price-s in this-procedure .
run new-price-prod in this-procedure .
find first bf_gds-obj where bf_gds-obj.obj-type  = t-doc.obj-type           and
                            bf_gds-obj.obj-code  = t-doc.obj-code           and
                            bf_gds-obj.artic     = tt-fr-doc-line.artic     and
                            bf_gds-obj.prod-type = tt-fr-doc-line.prod-type and
                            bf_gds-obj.prod-code = tt-fr-doc-line.prod-code no-lock no-error.
if t-doc.fact-order = 0 then do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type           and
                              bf_doc-line.obj-code     = t-doc.obj-code           and
                              bf_doc-line.prod-type    = tt-fr-doc-line.prod-type and
                              bf_doc-line.prod-code    = tt-fr-doc-line.prod-code and
                              bf_doc-line.artic        = tt-fr-doc-line.artic     and
                              bf_doc-line.ext-doc-type = 'ie':U       and
                              bf_doc-line.status_      = 'факт':U                  and
                              bf_doc-line.fact-order   > 0                        use-index dt-fo no-lock no-error.
end.
else do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type            and
                              bf_doc-line.obj-code     = t-doc.obj-code            and
                              bf_doc-line.prod-type    = tt-fr-doc-line.prod-type  and
                              bf_doc-line.prod-code    = tt-fr-doc-line.prod-code  and
                              bf_doc-line.artic        = tt-fr-doc-line.artic      and
                              bf_doc-line.ext-doc-type = 'ie':U        and
                              bf_doc-line.status_      = 'факт':U                   and
                              bf_doc-line.fact-order   < t-doc.fact-order          use-index dt-fo no-lock no-error.
end.
if available bf_doc-line then do:
  assign
    vargds-obj-last-rubl  = bf_doc-line.price-rubl.
  if available bf_gds-obj then do:
    assign
      vargds-obj-fact-qnty  = bf_gds-obj.fact-qnty
      vargds-obj-price-sale = bf_gds-obj.price-sale
      vargds-obj-pc-ov      = (if varr-b = "base" then (vargds-obj-price-sale / bf_gds-obj.last-base * 100 - 100) else (vargds-obj-price-sale / bf_gds-obj.last-rubl * 100 - 100)).
  end.
  else do:
    assign
      vargds-obj-fact-qnty  = ?
      vargds-obj-price-sale = ?
      vargds-obj-pc-ov      = ? .
  end.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock no-error.
  if available bf_trn-doc then do:
    assign
      vargds-obj-cli-type = bf_trn-doc.cli-type
      vargds-obj-cli-code = bf_trn-doc.cli-code.
    find first bf_clients where bf_clients.obj-type = bf_trn-doc.cli-type and
                                bf_clients.obj-code = bf_trn-doc.cli-code no-lock no-error.
    if available bf_clients then do:
      assign vargds-obj-cli-name = bf_clients.obj-name.
    end.
  end.
  else do:
    assign
      vargds-obj-cli-type = ""
      vargds-obj-cli-code = ?
      vargds-obj-cli-name = ""
    .
  end.
end.
else do:
  assign
    vargds-obj-fact-qnty  = ?
    vargds-obj-last-rubl  = ?
    vargds-obj-price-sale = ?
    vargds-obj-pc-ov      = ?
    vargds-obj-cli-type   = ""
    vargds-obj-cli-code   = ?
    vargds-obj-cli-name   = ""
    .
  if available bf_gds-obj then do:
    assign
      vargds-obj-fact-qnty  = bf_gds-obj.fact-qnty
      vargds-obj-price-sale = bf_gds-obj.price-sale
      vargds-obj-pc-ov      = (if varr-b = "base" then (vargds-obj-price-sale / bf_gds-obj.last-base * 100 - 100) else (vargds-obj-price-sale / bf_gds-obj.last-rubl * 100 - 100)).
  end.
  else do:
    assign
      vargds-obj-fact-qnty  = ?
      vargds-obj-price-sale = ?
      vargds-obj-pc-ov      = ? .
  end.
end.
display vargds-obj-fact-qnty
        vargds-obj-price-sale
        vargds-obj-pc-ov
        vargds-obj-last-rubl
        vargds-obj-cli-name
        vargds-obj-cli-type
        vargds-obj-cli-code
        with frame d-in-line.
find first cst-parts where cst-parts.obj-type  = t-doc.obj-type        and
                           cst-parts.obj-code  = t-doc.obj-code        and
                           cst-parts.prod-type = tt-fr-doc-line.prod-type and
                           cst-parts.prod-code = tt-fr-doc-line.prod-code and
                           cst-parts.artic     = tt-fr-doc-line.artic     and
                           cst-parts.out-code  = t-doc.doc-code  no-lock no-error.
if not available cst-parts then do:
   assign tt-fr-doc-line.cst-code = t-doc.cst-code.
   display tt-fr-doc-line.cst-code with frame d-in-line.
end.
else do:
  find first cst-parts-another where cst-parts-another.obj-type  =  t-doc.obj-type         and
                                     cst-parts-another.obj-code  =  t-doc.obj-code         and
                                     cst-parts-another.prod-type =  tt-fr-doc-line.prod-type  and
                                     cst-parts-another.prod-code =  tt-fr-doc-line.prod-code  and
                                     cst-parts-another.artic     =  tt-fr-doc-line.artic      and
                                     cst-parts-another.out-code  =  t-doc.doc-code         and
                                     cst-parts-another.cst-code  <> cst-parts.cst-code     no-lock no-error.
  if available cst-parts-another then do:
    assign tt-fr-doc-line.cst-code = ?.
    display tt-fr-doc-line.cst-code with frame d-in-line.
  end.
  else do:
    assign tt-fr-doc-line.cst-code = cst-parts.cst-code.
    display tt-fr-doc-line.cst-code with frame d-in-line.
  end.
end.
find first bf_parts where bf_parts.obj-type  = t-doc.obj-type           and
                          bf_parts.obj-code  = t-doc.obj-code           and
                          bf_parts.prod-type = tt-fr-doc-line.prod-type and
                          bf_parts.prod-code = tt-fr-doc-line.prod-code and
                          bf_parts.artic     = tt-fr-doc-line.artic     and
                          bf_parts.out-code  = t-doc.doc-code           no-lock no-error.
if not available bf_parts then do:
  find first bf_contract where bf_contract.contract-code = t-doc.contract-code no-lock no-error.
  if available bf_contract then do:
    assign
      tt-fr-doc-line.contract-code     = bf_contract.contract-code
      tt-fr-doc-line.contract-prn-code = bf_contract.contract-prn-code.
  end.
end.
else do:
  find first bf-another_parts where bf-another_parts.obj-type        = t-doc.obj-type           and
                                    bf-another_parts.obj-code        = t-doc.obj-code           and
                                    bf-another_parts.prod-type       = tt-fr-doc-line.prod-type and
                                    bf-another_parts.prod-code       = tt-fr-doc-line.prod-code and
                                    bf-another_parts.artic           = tt-fr-doc-line.artic     and
                                    bf-another_parts.out-code        = t-doc.doc-code           and
                                    bf-another_parts.contract-code  <> bf_parts.contract-code   no-lock no-error.
  if available bf-another_parts then do:
    assign tt-fr-doc-line.contract-code     = ?
           tt-fr-doc-line.contract-prn-code = ?.
  end.
  else do:
    find first bf_contract where bf_contract.contract-code = bf_parts.contract-code no-lock no-error.
    if available bf_contract then do:
      assign
        tt-fr-doc-line.contract-code     = bf_contract.contract-code
        tt-fr-doc-line.contract-prn-code = bf_contract.contract-prn-code.
    end.
  end.
end.
find first bf_parts where bf_parts.obj-type  = t-doc.obj-type           and
                          bf_parts.obj-code  = t-doc.obj-code           and
                          bf_parts.prod-type = tt-fr-doc-line.prod-type and
                          bf_parts.prod-code = tt-fr-doc-line.prod-code and
                          bf_parts.artic     = tt-fr-doc-line.artic     and
                          bf_parts.out-code  = t-doc.doc-code           no-lock no-error.
if available bf_parts then do:
  find first bf-another_parts where bf-another_parts.obj-type     = t-doc.obj-type           and
                                    bf-another_parts.obj-code     = t-doc.obj-code           and
                                    bf-another_parts.prod-type    = tt-fr-doc-line.prod-type and
                                    bf-another_parts.prod-code    = tt-fr-doc-line.prod-code and
                                    bf-another_parts.artic        = tt-fr-doc-line.artic     and
                                    bf-another_parts.out-code     = t-doc.doc-code           and
                                    bf-another_parts.last-date   <> bf_parts.last-date       no-lock no-error.
  if available bf-another_parts then do:
    assign tt-fr-doc-line.last-date    = ?
           tt-fr-doc-line.last-num-day = ?.
    display tt-fr-doc-line.last-date tt-fr-doc-line.last-num-day with frame d-in-line.
  end.
  else do:
    assign
      tt-fr-doc-line.last-date    = bf_parts.last-date
      tt-fr-doc-line.last-num-day = bf_parts.last-date - today + 1.
    display tt-fr-doc-line.last-date tt-fr-doc-line.last-num-day with frame d-in-line.
  end.
end.
if tt-fr-doc-line.alc-prod then do:
  if available bf_parts then do:
    find first bf-another_parts where bf-another_parts.obj-type   = t-doc.obj-type           and
                                      bf-another_parts.obj-code   = t-doc.obj-code           and
                                      bf-another_parts.prod-type  = tt-fr-doc-line.prod-type and
                                      bf-another_parts.prod-code  = tt-fr-doc-line.prod-code and
                                      bf-another_parts.artic      = tt-fr-doc-line.artic     and
                                      bf-another_parts.out-code   = t-doc.doc-code           and
                                      recid(bf-another_parts)    <> recid(bf_parts) no-lock no-error.
    if available bf-another_parts then do:
      assign
        tt-fr-doc-line.alc-multi-parts = yes
        tt-fr-doc-line.alc-update      = no
        tt-fr-doc-line.alc-part-code   = bf_parts.part-code
      .
    end.
    else do:
      assign
        tt-fr-doc-line.alc-multi-parts         = no
        tt-fr-doc-line.alc-update              = yes
        tt-fr-doc-line.alc-part-code           = bf_parts.part-code
        tt-fr-doc-line.alc-mark-db-num         = bf_parts.mark-db-num
        tt-fr-doc-line.alc-mark-code           = bf_parts.mark-code
        tt-fr-doc-line.alc-bottling-date       = bf_parts.alc-bottling-date
        tt-fr-doc-line.alc-ref-ab-path         = bf_parts.alc-ref-ab-path
        tt-fr-doc-line.alc-quality-certif-path = bf_parts.alc-quality-certif-path
        tt-fr-doc-line.alc-certif-path         = bf_parts.alc-certif-path
        tt-fr-doc-line.alc-imp-type            = bf_parts.alc-imp-type
        tt-fr-doc-line.alc-imp-code            = bf_parts.alc-imp-code
      .
    end.
  end.
  else do:
    assign
      tt-fr-doc-line.alc-multi-parts = no
      tt-fr-doc-line.alc-update      = yes
      tt-fr-doc-line.alc-part-code   = ?
    .
  end.
end.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-exist as logical   no-undo .
run lineattr-exist in this-procedure (
    input   t-doc.doc-code  ,
    input   buf_goods.gds-code  ,
    input   'country-code':U ,
    output  v-exist       )
    no-error .
    if error-status :error then do:
       message vss-workfile vss-revision vss-description skip
               error-status :get-message( 1 )
               return-value
       view-as alert-box error .
       return error.
    end.
if not v-exist then do:
   find first buf_country no-lock where  buf_country.alpha1 = buf_goods.alpha1  no-error .
   if available buf_country then do:
    assign
      tt-fr-doc-line.alpha1       = buf_country.alpha1
      tt-fr-doc-line.country-code = buf_country.num-code
      tt-fr-doc-line.short-name   = buf_country.short-name
    .
   end.
end.
else do:
  run lineattr-value in this-procedure (
      input   t-doc.doc-code  ,
      input   buf_goods.gds-code  ,
      input   'country-code':U ,
      output  v-value      ,
      output  v-type       )
      no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip
                error-status :get-message( 1 )
                return-value
        view-as alert-box error .
        return error.
      end.
   find first buf_country no-lock where  buf_country.num-code = int(v-value)  no-error .
   if available buf_country then do:
    assign
      tt-fr-doc-line.alpha1       = buf_country.alpha1
      tt-fr-doc-line.country-code = buf_country.num-code
      tt-fr-doc-line.short-name   = buf_country.short-name
    .
   end.
   else do:
      find first buf_country no-lock where  buf_country.alpha1 = buf_goods.alpha1  no-error .
      if available buf_country then do:
        assign
          tt-fr-doc-line.alpha1       = buf_country.alpha1
          tt-fr-doc-line.country-code = buf_country.num-code
          tt-fr-doc-line.short-name   = buf_country.short-name
        .
      end.
   end.
end.
display tt-fr-doc-line.alpha1
        tt-fr-doc-line.short-name
        with frame d-in-line.
if parline-mode <> 'ПРОСМОТР':U and
   parqnty   <> 0         then do:
   if line-rec <> ? then do:
     if kind-qnty = "doc" then do:
        assign  tt-fr-doc-line.cli-qnty = tt-fr-doc-line.cli-qnty + parqnty / tt-fr-doc-line.cli-base-rate
                tt-fr-doc-line.doc-qnty = tt-fr-doc-line.cli-qnty * tt-fr-doc-line.cli-base-rate.
     end.
     else do:
        assign  tt-fr-doc-line.fact-qnty = tt-fr-doc-line.fact-qnty + parqnty.
        if is-petrolium = yes and is-pieces = no then do:
          assign  tt-fr-doc-line.fact-qnty-kg = tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density.
        end.
     end.
   end.
   else do:
     if kind-qnty = "doc" then do:
        assign tt-fr-doc-line.cli-qnty = parqnty / tt-fr-doc-line.cli-base-rate
               tt-fr-doc-line.doc-qnty = tt-fr-doc-line.cli-qnty * tt-fr-doc-line.cli-base-rate.
     end.
     else do:
        assign  tt-fr-doc-line.fact-qnty = parqnty.
        if is-petrolium = yes and is-pieces = no then do:
          assign  tt-fr-doc-line.fact-qnty-kg = tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density.
        end.
     end.
   end.
   if kind-qnty = "doc" then do:
      display tt-fr-doc-line.cli-qnty tt-fr-doc-line.doc-qnty with frame d-in-line.
      hide    tt-fr-doc-line.fact-qnty    in frame d-in-line
              tt-fr-doc-line.fact-qnty-kg in frame d-in-line
              tt-fr-doc-line.fact-density in frame d-in-line
              .
   end.
   else do:
      display tt-fr-doc-line.fact-qnty with frame d-in-line.
      if is-petrolium = yes and is-pieces = no then do:
        display tt-fr-doc-line.fact-qnty-kg
        tt-fr-doc-line.fact-density
        with frame d-in-line.
      end.
   end.
   assign kind-qnty = ?
          parqnty   = 0.
end.
if is-petrolium = yes
  and is-pieces = no
then do:
  display tt-fr-doc-line.doc-density with frame d-in-line.
end.
find ub.gds-prt where ub.gds-prt.upper-code = tt-fr-doc-line.prt-root no-lock.
for each ub.gds-dtl where ub.gds-dtl.prod-type = tt-fr-doc-line.prod-type and
                       ub.gds-dtl.prod-code = tt-fr-doc-line.prod-code and
                       ub.gds-dtl.artic     = tt-fr-doc-line.artic     and
                       ub.gds-dtl.doc-code  = t-doc.doc-code        and
                       ub.gds-dtl.prt-code <> ub.gds-prt.node-code
                       :
   accumulate ub.gds-dtl.doc-qnty (total) ub.gds-dtl.fact-qnty (total).
end.
assign
  prt-doc =  (accum total ub.gds-dtl.doc-qnty)
  prt-fact = (accum total ub.gds-dtl.fact-qnty).
if prtvalue  = "yes"                   and
   ub.gds-prt.node-name <> '_Пустая шкала':U and
   v-cntxp-doc-prt                     then enable b-prt with frame d-in-line.
if b-prt:sensitive and t-doc.status_ <> 'факт':U then do:
  disp prt-doc with frame d-in-line.
  if t-doc.flag_ then disp prt-fact with frame d-in-line.
                 else hide prt-fact in   frame d-in-line.
end.
enable b-parts with frame d-in-line.
if parlns-cnt > 1 then enable b-exit-cycl with frame d-in-line.
if tt-fr-doc-line.alc-prod then enable b-alc-attr with frame d-in-line.
if parline-mode <> 'ПРОСМОТР':U then do:
  enable b-save  with frame d-in-line.
  if not t-doc.flag_ then do:
     enable tt-fr-doc-line.cst-code r-country  tt-fr-doc-line.last-date b-choose-last-date tt-fr-doc-line.last-num-day with frame d-in-line.
     if v-cntxp-inout-price = true
       and v-insalepr = false
     then do:
        if not cross-list('2ед':U, tt-fr-doc-line.unit-type, ?) and
           vat-sumvalue = "yes" then do:
            enable tt-fr-doc-line.type-inp-vat when t-doc.vat-type <> 'без':U with frame d-in-line.
            if tt-fr-doc-line.type-inp-vat then do:
              enable tt-fr-doc-line.vat-pc when t-doc.vat-type <> 'без':U with frame d-in-line.
            end.
            else do:
              enable sum-vat when t-doc.vat-type <> 'без':U with frame d-in-line.
              apply "leave" to sum-vat in frame d-in-line.
            end.
         end.
         else do:
           enable tt-fr-doc-line.vat-pc when t-doc.vat-type <> 'без':U with frame d-in-line.
         end.
         enable tt-fr-doc-line.slt-pc when t-doc.slt-type <> 'без':U with frame d-in-line.
     end.
     if custvalue = "yes" then do:
        enable tt-fr-doc-line.wt-brutto tt-fr-doc-line.wt-place tt-fr-doc-line.num-place with frame d-in-line.
     end.
     if varprice-cli-input = true
       and v-insalepr = false
     then do:
        if tt-fr-doc-line.type-inp-sum = yes then do:
          enable tt-fr-doc-line.tot-cli  with frame d-in-line.
        end.
        else do:
          enable tt-fr-doc-line.price-cli  with frame d-in-line.
        end.
     end.
     if varbase-price-input = true
       and v-insalepr = false
     then do:
       enable tt-fr-doc-line.price-rubl with frame d-in-line.
     end.
     if v-cntxp-unit-cli-perm then do:
        if varcli-base-rate-input then do:
          enable tt-fr-doc-line.cli-base-rate with frame d-in-line.
        end.
        if varext-gds-type <> 'bg':U and
           varext-gds-type <> 'gg':U   and
           varext-gds-type <> 'pp':U and
           varext-gds-type <> 'kp':U and
           varext-gds-type <> 'lp':U  and
           varext-gds-type <> 'sg':U then do:
             enable tt-fr-doc-line.unit-cli r-units with frame d-in-line.
        end.
     end.
     if is-petrolium = yes
       and is-pieces = no
     then do:
       enable tt-fr-doc-line.temperature with frame d-in-line.
     end.
     if varcli-qnty-input   then enable tt-fr-doc-line.cli-qnty with frame d-in-line.
     if vardensity-input    then enable tt-fr-doc-line.doc-density with frame d-in-line.
     if vardoc-qnty-input   then enable tt-fr-doc-line.doc-qnty with frame d-in-line.
     if vartax-3-input      then enable road-tax-cli with frame d-in-line.
     if varcli-qnty-input then do:
       apply "entry" to tt-fr-doc-line.cli-qnty in frame d-in-line.
     end.
     else do:
        if varcli-base-rate-input then apply "entry" to tt-fr-doc-line.cli-base-rate in frame d-in-line.
        else do:
           if vardensity-input then apply "entry" to tt-fr-doc-line.doc-density in frame d-in-line.
           else do:
              if vardoc-qnty-input then do:
                apply "entry" to tt-fr-doc-line.doc-qnty  in frame d-in-line.
              end.
              else do:
                if tt-fr-doc-line.price-cli:sensitive in frame d-in-line then do:
                  apply "entry" to tt-fr-doc-line.price-cli in frame d-in-line.
                end.
                if tt-fr-doc-line.tot-cli:sensitive in frame d-in-line then do:
                  apply "entry" to tt-fr-doc-line.tot-cli in frame d-in-line.
                end.
              end.
           end.
        end.
     end.
  end.
  else do:
     if varfact-qnty-input then enable tt-fr-doc-line.fact-qnty with frame d-in-line.
  end.
end.
if v-edit-fact-wayb
  then enable tt-fr-doc-line.fact-qnty with frame d-in-line.
enable b-quit b-help with frame d-in-line.
      assign
        frame d-in-line tt-fr-doc-line.fact-qnty
      .
run disp-total in this-procedure.
end.
if is-petrolium = yes and is-pieces = no and not v-lgas-gds then do:
  disable
    tt-fr-doc-line.doc-density
    tt-fr-doc-line.fact-qnty
    tt-fr-doc-line.fact-qnty-kg
    tt-fr-doc-line.doc-qnty
    tt-fr-doc-line.cli-qnty
    tt-fr-doc-line.temperature
    tt-fr-doc-line.doc-density
    tt-fr-doc-line.fact-density
    with frame d-in-line.
  hide tt-fr-doc-line.cli-base-rate tt-fr-doc-line.temperature tt-fr-doc-line.doc-density in frame d-in-line.
end.
end procedure.
procedure check-frame:
define input parameter kind-check as character no-undo.
if tt-fr-doc-line.cli-art          :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.cli-art         <> tt-fr-doc-line.cli-art        then apply "leave" to tt-fr-doc-line.cli-art        in frame d-in-line.
if tt-fr-doc-line.cst-code         :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.cst-code        <> tt-fr-doc-line.cst-code       then apply "leave" to tt-fr-doc-line.cst-code       in frame d-in-line.
if tt-fr-doc-line.cli-qnty         :sensitive in frame d-in-line then do :
  if input frame d-in-line tt-fr-doc-line.cli-qnty = 0
  or input frame d-in-line tt-fr-doc-line.cli-qnty = ?
  then do:
    message "Не указано количество в единицах измерения поставщика." view-as alert-box error .
    display tt-fr-doc-line.type-inp-vat with frame d-in-line .
    apply "entry" to tt-fr-doc-line.cli-qnty in frame d-in-line .
    return error .
  end.
  if input frame d-in-line tt-fr-doc-line.cli-qnty <> tt-fr-doc-line.cli-qnty then
    apply "leave" to tt-fr-doc-line.cli-qnty       in frame d-in-line.
end .
if tt-fr-doc-line.unit-cli         :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.unit-cli        <> tt-fr-doc-line.unit-cli       then apply "leave" to tt-fr-doc-line.unit-cli       in frame d-in-line.
if tt-fr-doc-line.doc-density      :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.doc-density     <> tt-fr-doc-line.doc-density    then apply "leave" to tt-fr-doc-line.doc-density    in frame d-in-line.
if tt-fr-doc-line.temperature      :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.temperature     <> tt-fr-doc-line.temperature    then apply "leave" to tt-fr-doc-line.temperature    in frame d-in-line.
if tt-fr-doc-line.cli-base-rate    :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.cli-base-rate   <> tt-fr-doc-line.cli-base-rate  then apply "leave" to tt-fr-doc-line.cli-base-rate  in frame d-in-line.
if tt-fr-doc-line.doc-qnty         :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.doc-qnty        <> tt-fr-doc-line.doc-qnty       then apply "leave" to tt-fr-doc-line.doc-qnty       in frame d-in-line.
if tt-fr-doc-line.fact-qnty        :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.doc-qnty        <> tt-fr-doc-line.doc-qnty       then apply "leave" to tt-fr-doc-line.doc-qnty       in frame d-in-line.
if tt-fr-doc-line.unit-base        :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.unit-base       <> tt-fr-doc-line.unit-base      then apply "leave" to tt-fr-doc-line.unit-base      in frame d-in-line.
if tt-fr-doc-line.fact-qnty        :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.fact-qnty       <> tt-fr-doc-line.fact-qnty      then apply "leave" to tt-fr-doc-line.fact-qnty      in frame d-in-line.
if tt-fr-doc-line.vat-pc           :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.vat-pc          <> tt-fr-doc-line.vat-pc         then apply "leave" to tt-fr-doc-line.vat-pc         in frame d-in-line.
if tt-fr-doc-line.slt-pc           :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.slt-pc          <> tt-fr-doc-line.slt-pc         then apply "leave" to tt-fr-doc-line.slt-pc         in frame d-in-line.
if tt-fr-doc-line.price-cli        :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.price-cli       <> tt-fr-doc-line.price-cli      then apply "leave" to tt-fr-doc-line.price-cli      in frame d-in-line.
if tt-fr-doc-line.tot-cli          :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.tot-cli         <> tt-fr-doc-line.tot-cli        then apply "leave" to tt-fr-doc-line.tot-cli        in frame d-in-line.
if tt-fr-doc-line.num-place        :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.num-place       <> tt-fr-doc-line.num-place      then apply "leave" to tt-fr-doc-line.num-place      in frame d-in-line.
if tt-fr-doc-line.wt-brutto        :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.wt-brutto       <> tt-fr-doc-line.wt-brutto      then apply "leave" to tt-fr-doc-line.wt-brutto      in frame d-in-line.
if tt-fr-doc-line.road-tax         :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.road-tax        <> tt-fr-doc-line.road-tax       then apply "leave" to tt-fr-doc-line.road-tax       in frame d-in-line.
if tt-fr-doc-line.excise           :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.excise          <> tt-fr-doc-line.excise         then apply "leave" to tt-fr-doc-line.excise         in frame d-in-line.
if road-tax-cli                    :sensitive in frame d-in-line and input frame d-in-line road-tax-cli                   <> road-tax-cli                  then apply "leave" to road-tax-cli                  in frame d-in-line.
if tt-fr-doc-line.last-date        :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.last-date       <> tt-fr-doc-line.last-date      then apply "leave" to tt-fr-doc-line.last-date      in frame d-in-line.
if tt-fr-doc-line.last-num-day     :sensitive in frame d-in-line and input frame d-in-line tt-fr-doc-line.last-num-day    <> tt-fr-doc-line.last-num-day   then apply "leave" to tt-fr-doc-line.last-num-day   in frame d-in-line.
define buffer bf-units-cli for ub.units.
  if not (kind-check begins "light" and lookup('сер':U, tt-fr-doc-line.unit-type) > 0) and
     (tt-fr-doc-line.cli-qnty = 0 or tt-fr-doc-line.cli-qnty = ?) and not t-doc.flag_ then do:
    if kind-check <> "light-super" then
       message "Не указано количество в единицах поставщика." view-as alert-box error.
    if tt-fr-doc-line.cli-qnty:sensitive then apply "entry" to tt-fr-doc-line.cli-qnty in frame d-in-line.
                                      else apply "entry" to b-quit               in frame d-in-line.
    return error.
  end.
  if not (kind-check begins "light" and lookup('сер':U, tt-fr-doc-line.unit-type) > 0) and
     (tt-fr-doc-line.doc-qnty = 0 or tt-fr-doc-line.doc-qnty = ?) and not t-doc.flag_ then do:
    if kind-check <> "light-super" then
    message "Не указано количество по накладной в учетных единицах." view-as alert-box error.
    return error.
  end.
  if (tt-fr-doc-line.fact-qnty < 0 or tt-fr-doc-line.fact-qnty = ?) and t-doc.flag_ then do:
    if kind-check <> "light-super" then
    message "Неправильное факт. количество в учетных единицах." view-as alert-box error.
    apply "entry" to tt-fr-doc-line.fact-qnty in frame d-in-line.
    return error.
  end.
  if (tt-fr-doc-line.fact-qnty > tt-fr-doc-line.doc-qnty and
      v-hold-doc = true  ) then do:
    message "Данный документ был автоматически создан по перемещению от своей фирмы." skip
            "Нельзя указывать фактическое количество больше документарного."
    view-as alert-box error.
    apply "entry" to tt-fr-doc-line.fact-qnty in frame d-in-line.
    return error.
  end.
  find t-doc where recid( t-doc ) = pardoc-rec.
  if t-doc.flag_ = yes                                          and
     lookup( 'шту':U, tt-fr-doc-line.unit-type ) > 0          and
     truncate( tt-fr-doc-line.fact-qnty, 0 ) <> tt-fr-doc-line.fact-qnty
  then do:
      message "Базовая единица товара " tt-fr-doc-line.unit-base " - штучная." skip
              "Кол-во по факту должно быть целым."
      view-as alert-box error buttons ok.
      return error.
  end.
  find bf-units-cli where bf-units-cli.unit-name = tt-fr-doc-line.unit-cli no-lock no-error.
  if not available bf-units-cli then do:
    message "Неправильная единица измерения." view-as alert-box error.
    return error.
  end.
  if lookup('шту':U, bf-units-cli.type) > 0  and
      trunc(tt-fr-doc-line.cli-qnty, 0) <> tt-fr-doc-line.cli-qnty then do:
      message "Единица поставщика " tt-fr-doc-line.unit-cli " - штучная." skip
              "Должно быть указано целое количество в единицах поставщика."
      view-as alert-box error buttons ok.
      return error.
  end.
  release bf-units-cli.
  if tt-fr-doc-line.cli-base-rate = 0 or tt-fr-doc-line.cli-base-rate = ? then do:
    message "Не указан коэффициент пересчета единиц измерения." view-as alert-box error.
    return error.
  end.
  if tt-fr-doc-line.unit-cli = tt-fr-doc-line.unit-base and tt-fr-doc-line.cli-base-rate <> 1 then do:
    message "Коэффициент пересчета единиц измерения должен быть 1, т.к. единицы совпадают." view-as alert-box error.
    return error.
  end.
  if lookup('шту':U, tt-fr-doc-line.unit-type) > 0           and
     trunc(tt-fr-doc-line.doc-qnty, 0) <> tt-fr-doc-line.doc-qnty then do:
     message "Базовая единица товара " tt-fr-doc-line.unit-base " - штучная." skip
             "Кол-во по документу должно быть целым."
     view-as alert-box error buttons ok.
     return error.
  end.
  run gds-attr-value in this-procedure (input  buf_goods.gds-code
                                         ,input 'null-price':U
                                         ,output v-gds-null-price
                                         ,output v-attr-type ) no-error .
  if t-doc.status_ <> 'запрос':U and  not v-gds-null-price then do:
    if tt-fr-doc-line.price-cli = 0 or tt-fr-doc-line.price-cli = ? then do:
      message "Не указана цена в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if tt-fr-doc-line.price-base = 0 or tt-fr-doc-line.price-base = ? then do:
      message "Не указана цена в базовой валюте." view-as alert-box error.
      return error.
    end.
    if tt-fr-doc-line.price-rubl = 0 or tt-fr-doc-line.price-rubl = ? then do:
      message "Не указана цена в рублях." view-as alert-box error.
      return error.
    end.
  end.
  if v-lgas-gds
  then do :
    assign tt-fr-doc-line.propan-perc cb-connect-hoses .
    if tt-fr-doc-line.propan-perc <= 0
    or tt-fr-doc-line.propan-perc >= 100
    or tt-fr-doc-line.propan-perc = ?
    then do :
      message "Укажите массовую долю пропана в смеси, % из паспорта качества. Данная информация является обязательной!"
      view-as alert-box .
      return error .
    end .
    for first tt-doc-pl :
      find first bf_place-attr no-lock where bf_place-attr.obj-type  = tt-doc-pl.obj-type
                                         and bf_place-attr.obj-code  = tt-doc-pl.obj-code
                                         and bf_place-attr.pl-code   = tt-doc-pl.pl-code
                                         and bf_place-attr.attr-code = "place-gate-valve"
                                         no-error .
      if available bf_place-attr
      and logical(bf_place-attr.attr-value)
      then do :
        if cb-connect-hoses = "empty"
        then do :
          message "Внимание! Укажите Подключение рукавов при приеме СУГ!"
          view-as alert-box .
          return error .
        end .
      end .
    end .
  end .
end procedure.
procedure check-price:
  define variable p-same-price as  logical no-undo.
  run trg/doclnupd.p ( input  tt-fr-doc-line.doc-code,
                   input  t-doc.obj-type,
                   input  t-doc.obj-code,
                   input  tt-fr-doc-line.artic,
                   input  tt-fr-doc-line.prod-type,
                   input  tt-fr-doc-line.prod-code,
                   output p-same-price) no-error.
  if error-status :error then do:
     message "Ошибка при просмотре учетных цен в партиях." view-as alert-box error.
     display tt-fr-doc-line.price-rubl with frame d-in-line.
     return error.
  end.
  if p-same-price = false then do:
     message "Нельзя изменять цены в строке, т.к. имеются разные учетные в партиях."
     view-as alert-box error.
     return error.
  end.
end procedure.
procedure delete-doc-line:
do transaction
   on error   undo , return error
   on end-key undo , return error
   on stop    undo , return error :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input ?
  ,input ub.doc-line.doc-code
  ,input ub.doc-line.artic
  ,input ub.doc-line.prod-type
  ,input ub.doc-line.prod-code
  ,input ub.doc-line.price-cli
  ,input ub.doc-line.price-rubl
  ,input ub.doc-line.price-base
  ,input ub.doc-line.cli-qnty
  ,input ub.doc-line.cli-base-rate
  ,input ub.doc-line.fact-qnty
  ,input ub.doc-line.doc-qnty
  ,input ub.doc-line.vat-pc
  ,input ub.doc-line.slt-pc
  ,input ub.doc-line.road-tax
  ,input ub.doc-line.excise
  ,input ub.doc-line.transport-rubl
  ,input ub.doc-line.other-rubl
  ,input 'delete'
  ,input ''
  ) no-error.
end.
end procedure.
procedure update-doc-line:
do transaction  on error   undo , return error
   :
   find ub.doc-line where recid(ub.doc-line) = line-rec.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(ub.doc-line)
  ,input ub.doc-line.doc-code
  ,input ub.doc-line.artic
  ,input ub.doc-line.prod-type
  ,input ub.doc-line.prod-code
  ,input old-doc-line.price-cli
  ,input old-doc-line.price-rubl
  ,input old-doc-line.price-base
  ,input old-doc-line.cli-qnty
  ,input old-doc-line.cli-base-rate
  ,input old-doc-line.fact-qnty
  ,input old-doc-line.doc-qnty
  ,input old-doc-line.vat-pc
  ,input old-doc-line.slt-pc
  ,input old-doc-line.road-tax
  ,input old-doc-line.excise
  ,input old-doc-line.transport-rubl
  ,input old-doc-line.other-rubl
  ,input 'update'
  ,input ''
  ) .
   release ub.doc-line.
end.
end procedure.
procedure update-doc-line-without-parts:
do transaction
   on error   undo , return error :
   find ub.doc-line where recid(ub.doc-line) = line-rec.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(doc-line)
  ,input ub.doc-line.doc-code
  ,input ub.doc-line.artic
  ,input ub.doc-line.prod-type
  ,input ub.doc-line.prod-code
  ,input old-doc-line.price-cli
  ,input old-doc-line.price-rubl
  ,input old-doc-line.price-base
  ,input old-doc-line.cli-qnty
  ,input old-doc-line.cli-base-rate
  ,input old-doc-line.fact-qnty
  ,input old-doc-line.doc-qnty
  ,input old-doc-line.vat-pc
  ,input old-doc-line.slt-pc
  ,input old-doc-line.road-tax
  ,input old-doc-line.excise
  ,input old-doc-line.transport-rubl
  ,input old-doc-line.other-rubl
  ,input 'update'
  ,input ''
  ) .
   release ub.doc-line.
end.
end procedure.
procedure disp-total:
define variable varprice-cli-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-dt          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-dt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-dt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl-dt               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl-dt     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl-dt like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl-dt   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl-dt    like ub.doc-line.price-rubl no-undo.
define variable varprice-base-dt               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base-dt      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base-dt     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base-dt like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base-dt   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base-dt        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base-dt    like ub.doc-line.price-base no-undo.
  assign
  tot-base = tt-fr-doc-line.price-base * (if t-doc.flag_ or t-doc.status_ = 'факт':U then tt-fr-doc-line.fact-qnty else tt-fr-doc-line.doc-qnty)
  tot-rubl = tt-fr-doc-line.price-rubl * (if t-doc.flag_ or t-doc.status_ = 'факт':U then tt-fr-doc-line.fact-qnty else tt-fr-doc-line.doc-qnty).
  display tot-rubl tot-base with frame d-in-line.
  if tt-fr-doc-line.type-inp-sum = no then do:
    assign
      tt-fr-doc-line.tot-cli  = tt-fr-doc-line.cli-qnty   * tt-fr-doc-line.price-cli.
    display tt-fr-doc-line.tot-cli with frame d-in-line.
  end.
  else do:
    assign
      tt-fr-doc-line.price-cli = tt-fr-doc-line.tot-cli / tt-fr-doc-line.cli-qnty.
    display tt-fr-doc-line.tot-cli tt-fr-doc-line.price-cli with frame d-in-line.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   t-doc.doc-code
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,input   t-doc.vat-type
  ,input   t-doc.slt-type
  ,input   tt-fr-doc-line.artic
  ,input   tt-fr-doc-line.prod-type
  ,input   tt-fr-doc-line.prod-code
  ,input   tt-fr-doc-line.price-cli
  ,input   tt-fr-doc-line.cli-base-rate
  ,input   tt-fr-doc-line.price-rubl
  ,input   tt-fr-doc-line.vat-pc
  ,input   tt-fr-doc-line.slt-pc
  ,input   tt-fr-doc-line.road-tax
  ,input   tt-fr-doc-line.transport-rubl
  ,input   tt-fr-doc-line.other-rubl
  ,output  varprice-cli-dt
  ,output  varprice-cli-unit-base-dt
  ,output  varprice-road-tax-dt
  ,output  varprice-other-exp-dt
  ,output  varprice-transport-exp-dt
  ,output  varprice-without-abs-dt
  ,output  varprice-slt-dt
  ,output  varprice-no-slt-dt
  ,output  varprice-vat-dt
  ,output  varprice-no-vat-slt-dt
  ,output  varprice-rubl-dt
  ,output  varprice-road-tax-rubl-dt
  ,output  varprice-other-exp-rubl-dt
  ,output  varprice-transport-exp-rubl-dt
  ,output  varprice-without-abs-rubl-dt
  ,output  varprice-slt-rubl-dt
  ,output  varprice-no-slt-rubl-dt
  ,output  varprice-vat-rubl-dt
  ,output  varprice-no-vat-slt-rubl-dt
  ,output  varprice-base-dt
  ,output  varprice-road-tax-base-dt
  ,output  varprice-other-exp-base-dt
  ,output  varprice-transport-exp-base-dt
  ,output  varprice-without-abs-base-dt
  ,output  varprice-slt-base-dt
  ,output  varprice-no-slt-base-dt
  ,output  varprice-vat-base-dt
  ,output  varprice-no-vat-slt-base-dt
  ) no-error.
  if error-status :error then do:
    return error substitute ("Ошибка при пересчете линии документа: &1", return-value).
  end.
  assign sum-vat = varprice-vat-dt * tt-fr-doc-line.cli-qnty.
  display sum-vat with frame d-in-line.
  if vat-sumvalue = "yes" then do:
    if v-round-vat-sum and sum-vat <> 0 then do:
      assign
        sum-vat = round(varprice-vat-dt * tt-fr-doc-line.cli-qnty, 2 )
      .
      run calc-vat-pc in this-procedure.
    end.
  end.
  run new-price-s in this-procedure .
  run new-price-prod in this-procedure .
end procedure.
procedure save-action:
  define input parameter partype-check as character no-undo.
  zap:
  do transaction
  on error  undo zap, return error return-value
  on stop   undo zap, return error return-value
  on endkey undo zap, return error return-value
  :
    define variable v-ok as logical   no-undo .
    if parline-mode <> 'ПРОСМОТР':U then do:
      assign
        frame d-in-line
        tt-fr-doc-line.price-prod
        tt-fr-doc-line.price-prod-vat
        tt-fr-doc-line.new-price-sale
      .
      assign
        v-ok = false
      .
      block_save:
      do while v-ok <> true
      on error  undo zap, return error return-value
      on stop   undo zap, return error return-value
      on endkey undo zap, return error return-value
      :
        run save-price-prod in this-procedure
          no-error.
        if error-status :error then do:
          undo zap, return error return-value.
        end.
        run check-frame in this-procedure
          ( input partype-check
          ) no-error.
        if error-status :error then do:
          undo zap, return error return-value.
        end.
        run save-place-rsrv in this-procedure
          ( input partype-check
           ,output v-ok
          ) no-error.
        if error-status :error then do:
          undo zap, return error return-value.
        end.
        if v-ok = true then do:
          run local-cor-line in this-procedure
            no-error.
          if error-status :error then do:
            undo zap, return error return-value.
          end.
          run save-country-code in this-procedure
            no-error.
          if error-status :error then do:
            undo zap, return error return-value.
          end.
          run init-tt-doc-pl in this-procedure
            no-error.
          if error-status :error then do:
            undo zap, return error return-value.
          end.
        end.
      end.
    end.
  end.
  if parline-mode <> 'ПРОСМОТР':U then do: assign parline-mode = 'ИЗМЕНЕНИЕ':U. end.
  find t-doc where recid( t-doc ) = pardoc-rec.
end procedure.
procedure local-cor-line:
  define variable v-part-code as character no-undo.
  define buffer lc_doc-line for ub.doc-line.
  if tt-fr-doc-line.alc-prod and
    (tt-fr-doc-line.alc-part-code = ?)
  then do:
    run alc-lib_get-new-part-code in this-procedure
      (input  t-doc.obj-type
      ,input  t-doc.obj-code
      ,input  tt-fr-doc-line.prod-type
      ,input  tt-fr-doc-line.prod-code
      ,input  tt-fr-doc-line.artic
      ,input  t-doc.doc-code
      ,output v-part-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры alc-lib_get-new-part-code" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error.
    end.
    assign
      tt-fr-doc-line.alc-part-code = v-part-code
    .
  end.
  if v-edit-fact-wayb
  then do:
    fq = tt-fr-doc-line.fact-qnty:screen-value in frame d-in-line.
  end.
  def var ndq as character no-undo.
  if v-edit-fact-wayb and not t-doc.flag_
  then do:
    t-doc.flag_ = true.
    ndq = tt-fr-doc-line.doc-qnty:screen-value in frame d-in-line.
    tt-fr-doc-line.fact-qnty:screen-value in frame d-in-line = string (dec (cq) * tt-fr-doc-line.cli-base-rate).
    tt-fr-doc-line.cli-qnty:screen-value in frame d-in-line = cq.
    assign
      tt-fr-doc-line.fact-qnty
      tt-fr-doc-line.cli-qnty
      .
    run calc-all in this-procedure
      ( input varcli-qnty-calc
      ) no-error .
    if error-status :error then do:
      return no-apply.
    end.
if not t-doc.flag_ then do:
  find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = t-doc.doc-code          and
                                 ub.doc-line-attr.gds-code  = buf_goods.gds-code      and
                                 ub.doc-line-attr.attr-code = "type-inp-vat"                   no-error.
  if not available ub.doc-line-attr and
     STRING(tt-fr-doc-line.type-inp-vat) <> ?    and
     STRING(tt-fr-doc-line.type-inp-vat) <> ""   then do:
     CREATE ub.doc-line-attr.
     ASSIGN
     ub.doc-line-attr.doc-code  = t-doc.doc-code
     ub.doc-line-attr.gds-code  = buf_goods.gds-code
     ub.doc-line-attr.attr-code = "type-inp-vat".
  end.
  if available ub.doc-line-attr then ASSIGN ub.doc-line-attr.attr-value = STRING(tt-fr-doc-line.type-inp-vat).
  find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = t-doc.doc-code          and
                                 ub.doc-line-attr.gds-code  = buf_goods.gds-code      and
                                 ub.doc-line-attr.attr-code = "tot-cli"                   no-error.
  if not available ub.doc-line-attr and
     STRING(tt-fr-doc-line.tot-cli) <> ?    and
     STRING(tt-fr-doc-line.tot-cli) <> ""   then do:
     CREATE ub.doc-line-attr.
     ASSIGN
     ub.doc-line-attr.doc-code  = t-doc.doc-code
     ub.doc-line-attr.gds-code  = buf_goods.gds-code
     ub.doc-line-attr.attr-code = "tot-cli".
  end.
  if available ub.doc-line-attr then ASSIGN ub.doc-line-attr.attr-value = STRING(tt-fr-doc-line.tot-cli).
end.
run str/cor-line.p
(input        parparentproc,
 input-output line-rec,
  tt-fr-doc-line.doc-code                  ,
  tt-fr-doc-line.prod-type                 ,
  tt-fr-doc-line.prod-code                 ,
  tt-fr-doc-line.artic                     ,
  tt-fr-doc-line.cli-qnty                  ,
  tt-fr-doc-line.cli-base-rate             ,
  tt-fr-doc-line.fact-qnty                 ,
  tt-fr-doc-line.doc-qnty                  ,
  tt-fr-doc-line.unit-cli                  ,
  tt-fr-doc-line.vat-pc                    ,
  tt-fr-doc-line.slt-pc                    ,
  tt-fr-doc-line.price-cli                 ,
  tt-fr-doc-line.price-base                ,
  tt-fr-doc-line.price-rubl                ,
  tt-fr-doc-line.new-price-sale            ,
  tt-fr-doc-line.num-place                 ,
  tt-fr-doc-line.wt-brutto                 ,
  tt-fr-doc-line.road-tax                  ,
  tt-fr-doc-line.excise                    ,
  tt-fr-doc-line.doc-density               ,
  tt-fr-doc-line.temperature               ,
  tt-fr-doc-line.contract-code             ,
  tt-fr-doc-line.last-date                 ,
  tt-fr-doc-line.fact-qnty-kg              ,
  tt-fr-doc-line.fact-density              ,
  tt-fr-doc-line.cst-code                  ,
  tt-fr-doc-line.alc-update                ,
  tt-fr-doc-line.alc-part-code             ,
  tt-fr-doc-line.alc-mark-db-num           ,
  tt-fr-doc-line.alc-mark-code             ,
  tt-fr-doc-line.alc-bottling-date         ,
  tt-fr-doc-line.alc-ref-ab-path           ,
  tt-fr-doc-line.alc-quality-certif-path   ,
  tt-fr-doc-line.alc-imp-type              ,
  tt-fr-doc-line.alc-imp-code              ,
  tt-fr-doc-line.alc-certif-path           ) no-error. if error-status:error then do: return error return-value. end.
    if error-status :error then do:
       message "Ошибка при вызове процедуры сохранения линии."
               return-value
               view-as alert-box.
       t-doc.flag_ = false.
       return error.
    end.
    t-doc.flag_ = false.
    tt-fr-doc-line.cli-qnty:screen-value in frame d-in-line = ndq.
    assign
      tt-fr-doc-line.cli-qnty.
    run calc-all in this-procedure
      ( input varcli-qnty-calc
      ) no-error .
    if error-status :error then do:
      return no-apply.
    end.
  end.
if not t-doc.flag_ then do:
  find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = t-doc.doc-code          and
                                 ub.doc-line-attr.gds-code  = buf_goods.gds-code      and
                                 ub.doc-line-attr.attr-code = "type-inp-vat"                   no-error.
  if not available ub.doc-line-attr and
     STRING(tt-fr-doc-line.type-inp-vat) <> ?    and
     STRING(tt-fr-doc-line.type-inp-vat) <> ""   then do:
     CREATE ub.doc-line-attr.
     ASSIGN
     ub.doc-line-attr.doc-code  = t-doc.doc-code
     ub.doc-line-attr.gds-code  = buf_goods.gds-code
     ub.doc-line-attr.attr-code = "type-inp-vat".
  end.
  if available ub.doc-line-attr then ASSIGN ub.doc-line-attr.attr-value = STRING(tt-fr-doc-line.type-inp-vat).
  find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = t-doc.doc-code          and
                                 ub.doc-line-attr.gds-code  = buf_goods.gds-code      and
                                 ub.doc-line-attr.attr-code = "tot-cli"                   no-error.
  if not available ub.doc-line-attr and
     STRING(tt-fr-doc-line.tot-cli) <> ?    and
     STRING(tt-fr-doc-line.tot-cli) <> ""   then do:
     CREATE ub.doc-line-attr.
     ASSIGN
     ub.doc-line-attr.doc-code  = t-doc.doc-code
     ub.doc-line-attr.gds-code  = buf_goods.gds-code
     ub.doc-line-attr.attr-code = "tot-cli".
  end.
  if available ub.doc-line-attr then ASSIGN ub.doc-line-attr.attr-value = STRING(tt-fr-doc-line.tot-cli).
end.
run str/cor-line.p
(input        parparentproc,
 input-output line-rec,
  tt-fr-doc-line.doc-code                  ,
  tt-fr-doc-line.prod-type                 ,
  tt-fr-doc-line.prod-code                 ,
  tt-fr-doc-line.artic                     ,
  tt-fr-doc-line.cli-qnty                  ,
  tt-fr-doc-line.cli-base-rate             ,
  tt-fr-doc-line.fact-qnty                 ,
  tt-fr-doc-line.doc-qnty                  ,
  tt-fr-doc-line.unit-cli                  ,
  tt-fr-doc-line.vat-pc                    ,
  tt-fr-doc-line.slt-pc                    ,
  tt-fr-doc-line.price-cli                 ,
  tt-fr-doc-line.price-base                ,
  tt-fr-doc-line.price-rubl                ,
  tt-fr-doc-line.new-price-sale            ,
  tt-fr-doc-line.num-place                 ,
  tt-fr-doc-line.wt-brutto                 ,
  tt-fr-doc-line.road-tax                  ,
  tt-fr-doc-line.excise                    ,
  tt-fr-doc-line.doc-density               ,
  tt-fr-doc-line.temperature               ,
  tt-fr-doc-line.contract-code             ,
  tt-fr-doc-line.last-date                 ,
  tt-fr-doc-line.fact-qnty-kg              ,
  tt-fr-doc-line.fact-density              ,
  tt-fr-doc-line.cst-code                  ,
  tt-fr-doc-line.alc-update                ,
  tt-fr-doc-line.alc-part-code             ,
  tt-fr-doc-line.alc-mark-db-num           ,
  tt-fr-doc-line.alc-mark-code             ,
  tt-fr-doc-line.alc-bottling-date         ,
  tt-fr-doc-line.alc-ref-ab-path           ,
  tt-fr-doc-line.alc-quality-certif-path   ,
  tt-fr-doc-line.alc-imp-type              ,
  tt-fr-doc-line.alc-imp-code              ,
  tt-fr-doc-line.alc-certif-path           ) no-error. if error-status:error then do: return error return-value. end.
  if error-status :error then do:
     message "Ошибка при вызове процедуры сохранения линии."
             return-value
             view-as alert-box.
     return error.
  end.
  if v-edit-fact-wayb and not t-doc.flag_
  then do:
    tt-fr-doc-line.fact-qnty:screen-value in frame d-in-line = fq.
    assign
      tt-fr-doc-line.fact-qnty.
    t-doc.flag_ = true.
if not t-doc.flag_ then do:
  find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = t-doc.doc-code          and
                                 ub.doc-line-attr.gds-code  = buf_goods.gds-code      and
                                 ub.doc-line-attr.attr-code = "type-inp-vat"                   no-error.
  if not available ub.doc-line-attr and
     STRING(tt-fr-doc-line.type-inp-vat) <> ?    and
     STRING(tt-fr-doc-line.type-inp-vat) <> ""   then do:
     CREATE ub.doc-line-attr.
     ASSIGN
     ub.doc-line-attr.doc-code  = t-doc.doc-code
     ub.doc-line-attr.gds-code  = buf_goods.gds-code
     ub.doc-line-attr.attr-code = "type-inp-vat".
  end.
  if available ub.doc-line-attr then ASSIGN ub.doc-line-attr.attr-value = STRING(tt-fr-doc-line.type-inp-vat).
  find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = t-doc.doc-code          and
                                 ub.doc-line-attr.gds-code  = buf_goods.gds-code      and
                                 ub.doc-line-attr.attr-code = "tot-cli"                   no-error.
  if not available ub.doc-line-attr and
     STRING(tt-fr-doc-line.tot-cli) <> ?    and
     STRING(tt-fr-doc-line.tot-cli) <> ""   then do:
     CREATE ub.doc-line-attr.
     ASSIGN
     ub.doc-line-attr.doc-code  = t-doc.doc-code
     ub.doc-line-attr.gds-code  = buf_goods.gds-code
     ub.doc-line-attr.attr-code = "tot-cli".
  end.
  if available ub.doc-line-attr then ASSIGN ub.doc-line-attr.attr-value = STRING(tt-fr-doc-line.tot-cli).
end.
run str/cor-line.p
(input        parparentproc,
 input-output line-rec,
  tt-fr-doc-line.doc-code                  ,
  tt-fr-doc-line.prod-type                 ,
  tt-fr-doc-line.prod-code                 ,
  tt-fr-doc-line.artic                     ,
  tt-fr-doc-line.cli-qnty                  ,
  tt-fr-doc-line.cli-base-rate             ,
  tt-fr-doc-line.fact-qnty                 ,
  tt-fr-doc-line.doc-qnty                  ,
  tt-fr-doc-line.unit-cli                  ,
  tt-fr-doc-line.vat-pc                    ,
  tt-fr-doc-line.slt-pc                    ,
  tt-fr-doc-line.price-cli                 ,
  tt-fr-doc-line.price-base                ,
  tt-fr-doc-line.price-rubl                ,
  tt-fr-doc-line.new-price-sale            ,
  tt-fr-doc-line.num-place                 ,
  tt-fr-doc-line.wt-brutto                 ,
  tt-fr-doc-line.road-tax                  ,
  tt-fr-doc-line.excise                    ,
  tt-fr-doc-line.doc-density               ,
  tt-fr-doc-line.temperature               ,
  tt-fr-doc-line.contract-code             ,
  tt-fr-doc-line.last-date                 ,
  tt-fr-doc-line.fact-qnty-kg              ,
  tt-fr-doc-line.fact-density              ,
  tt-fr-doc-line.cst-code                  ,
  tt-fr-doc-line.alc-update                ,
  tt-fr-doc-line.alc-part-code             ,
  tt-fr-doc-line.alc-mark-db-num           ,
  tt-fr-doc-line.alc-mark-code             ,
  tt-fr-doc-line.alc-bottling-date         ,
  tt-fr-doc-line.alc-ref-ab-path           ,
  tt-fr-doc-line.alc-quality-certif-path   ,
  tt-fr-doc-line.alc-imp-type              ,
  tt-fr-doc-line.alc-imp-code              ,
  tt-fr-doc-line.alc-certif-path           ) no-error. if error-status:error then do: return error return-value. end.
    if error-status :error then do:
      t-doc.flag_ = false.
       message "Ошибка при вызове процедуры сохранения линии."
               return-value
               view-as alert-box.
       return error.
    end.
    t-doc.flag_ = false.
  end.
  find first lc_doc-line where lc_doc-line.doc-code  = t-doc.doc-code           and
                               lc_doc-line.artic     = tt-fr-doc-line.artic     and
                               lc_doc-line.prod-type = tt-fr-doc-line.prod-type and
                               lc_doc-line.prod-code = tt-fr-doc-line.prod-code no-error.
  if available lc_doc-line then do:
    assign line-rec = recid( lc_doc-line ).
  end.
  if line-rec = ? then return .
  run str/chk-prt.p ( input line-rec, input (if last-event :widget-enter = b-save :handle in frame d-in-line then yes else no), buffer t-doc ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка про проверке разнесения строки по признакам" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.
end procedure.
procedure calc-vat-pc:
  if tt-fr-doc-line.tot-cli:sensitive in frame d-in-line then do:
    if  integer(tt-fr-doc-line.tot-cli:screen-value) <> 0
    then do :
        assign tt-fr-doc-line.vat-pc = (sum-vat / (tt-fr-doc-line.tot-cli
                 * ( 1 - (if t-doc.slt-type = 'в т. ч.':U then (tt-fr-doc-line.slt-pc / (100 + tt-fr-doc-line.slt-pc)) else 0))
                - (if t-doc.vat-type =  'в т. ч.':U then sum-vat else 0))) * 100.
        if tt-fr-doc-line.vat-pc = ? then
        assign
          tt-fr-doc-line.vat-pc = v-clcdoc-vat-pc
          sum-vat = 0
        .
    end.
  end.
  else do:
    assign tt-fr-doc-line.vat-pc = (sum-vat / (tt-fr-doc-line.cli-qnty * tt-fr-doc-line.price-cli
             * ( 1 - (if t-doc.slt-type = 'в т. ч.':U then (tt-fr-doc-line.slt-pc / (100 + tt-fr-doc-line.slt-pc)) else 0))
            - (if t-doc.vat-type =  'в т. ч.':U then sum-vat else 0))) * 100.
    if tt-fr-doc-line.vat-pc = ? then tt-fr-doc-line.vat-pc = v-clcdoc-vat-pc.
  end.
  display tt-fr-doc-line.vat-pc sum-vat with frame d-in-line.
end procedure.
procedure cr-tt-fr-doc-line private:
  define input parameter parmode        as character no-undo.
  define input parameter parrecdoc-line as recid     no-undo.
  define variable v-alcohol-prod        as logical   no-undo.
  define variable v-alcohol-value       as character no-undo.
  define variable v-alcohol-type        as character no-undo.
  define variable v-new-price-sale      as decimal   no-undo.
  define variable v-price-prod          as decimal   no-undo.
  define variable v-price-prod-vat      as decimal   no-undo.
  define buffer bf-doc-line   for ub.doc-line.
  define buffer prev_doc-line for ub.doc-line.
  if parmode <> "create" then do:
    find first bf-doc-line no-lock
      where recid(bf-doc-line) = parrecdoc-line
    .
  end.
  if parline-mode <> 'ПРОСМОТР':U then do:
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_goods-tr in g#lib-trn3
(input recid(t-doc)
,input recid(buf_goods)
) no-error
.
     if error-status :error then do:
       message
         error-status :get-message( 1 ) skip
         return-value
         view-as alert-box.
       return error.
     end.
  end.
  find ub.units where ub.units.unit-name  = buf_goods.unit-base no-lock.
  create tt-fr-doc-line.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(buf_goods)
,input  recid(t-doc)
,input  bf_sysconf.cash-pay
,output v-clcdoc-slt-pc
)
.
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-clcdoc-host-code
  )  .
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-clcdoc-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-clcdoc-vat-pc
  ) no-error .
  assign
    tt-fr-doc-line.doc-code      = t-doc.doc-code
    tt-fr-doc-line.obj-type      = t-doc.obj-type
    tt-fr-doc-line.obj-code      = t-doc.obj-code
    tt-fr-doc-line.artic         = buf_goods.artic
    tt-fr-doc-line.prod-type     = buf_goods.prod-type
    tt-fr-doc-line.prod-code     = buf_goods.prod-code
    tt-fr-doc-line.gds-name      = buf_goods.gds-name
    v-goods-ms-base              = buf_goods.ms-base
    tt-fr-doc-line.unit-base     = buf_goods.unit-base
    tt-fr-doc-line.unit-type     = ub.units.type
    tt-fr-doc-line.prt-root      = buf_goods.prt-root
    tt-fr-doc-line.type-inp-sum  = (if parinplnsum = yes then yes else no)
  .
  if parmode = "create" then do:
    assign
      tt-fr-doc-line.unit-cli      = (if v-specif-unit-list > "" then v-specif-unit-list     else buf_goods.unit-cli)
      tt-fr-doc-line.cli-base-rate = (if v-specif-unit-list > "" then (v-specif-cli-base-rate) else buf_goods.cli-base-rate)
      tt-fr-doc-line.doc-density   = ?
      tt-fr-doc-line.fact-density  = ?
      tt-fr-doc-line.temperature   = ?
    .
    if is-petrolium = true
      and is-pieces = false
    then do:
      assign
        tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
      .
      if ptrlprop-olddens = true
        and vardensity-input = true
      then do:
        find last prev_doc-line
          where prev_doc-line.obj-type     = t-doc.obj-type
            and prev_doc-line.obj-code     = t-doc.obj-code
            and prev_doc-line.prod-type    = buf_goods.prod-type
            and prev_doc-line.prod-code    = buf_goods.prod-code
            and prev_doc-line.artic        = buf_goods.artic
            and prev_doc-line.ext-doc-type = t-doc.ext-doc-type
            and prev_doc-line.status_      = 'факт':U
          no-lock
        use-index dt-fo no-error.
        if available prev_doc-line then do:
          assign
            tt-fr-doc-line.doc-density   = prev_doc-line.fact-density
            tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
            tt-fr-doc-line.fact-density  = tt-fr-doc-line.doc-density
            tt-fr-doc-line.temperature   = prev_doc-line.temperature
          .
          display
            tt-fr-doc-line.doc-density
            tt-fr-doc-line.temperature
            with frame d-in-line.
        end.
      end.
    end.
  end.
  else do:
    assign
      tt-fr-doc-line.cli-base-rate = bf-doc-line.cli-base-rate
      tt-fr-doc-line.unit-cli      = bf-doc-line.unit-cli
    .
  end.
  assign
    tt-fr-doc-line.vat-pc = (if t-doc.vat-type = 'без':U then 0 else (if parmode = "create" then v-clcdoc-vat-pc else bf-doc-line.vat-pc))
    tt-fr-doc-line.slt-pc = (if t-doc.slt-type = 'без':U then 0 else (if parmode = "create" then v-clcdoc-slt-pc else bf-doc-line.slt-pc))
  .
  .
   if parmode = "create" then do:
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run find-new-price-sale in this-procedure (
   input  pr-genmrg
  ,input  pr-naklvalue
  ,input  t-doc.doc-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  tt-fr-doc-line.price-rubl
  ,input  tt-fr-doc-line.price-base
  ,input  tt-fr-doc-line.price-rubl
  ,input  tt-fr-doc-line.price-base
  ,input-output tt-fr-doc-line.new-price-sale
    )
    no-error .
      if error-status :error then
      message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи(2)"
        view-as alert-box error
      .
   end.
   else do:
    assign
      tt-fr-doc-line.new-price-sale = bf-doc-line.new-price-sale
    .
   end.
define variable v-type as character no-undo .
  run lineattr-value in this-procedure (
      input   t-doc.doc-code  ,
      input   buf_goods.gds-code  ,
      input   'price-prod':U ,
      output  tt-fr-doc-line.price-prod ,
      output  v-type       )
      no-error .
  run lineattr-value in this-procedure (
      input   t-doc.doc-code  ,
      input   buf_goods.gds-code  ,
      input   'price-prodvat':U ,
      output  tt-fr-doc-line.price-prod-vat ,
      output  v-type       )
      no-error .
  v-alcohol-prod = no.
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
  if lookup(v-alcohol-value, 'true,yes':u) > 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_goods.gds-code
  ,input  'alcohol-prod=request':u
  ,output v-alcohol-prod
  )  .
  end.
  assign
    tt-fr-doc-line.alc-prod = v-alcohol-prod
    varalc-prod             = string (v-alcohol-prod,
                                      substring("Алкоголь", 1, 1) + "/")
  .
  release buf_goods.
  find first buf_goods no-lock
    where recid(buf_goods) = pargds-rec
  .
  release ub.units.
  find ub.clients where ub.clients.obj-type = tt-fr-doc-line.prod-type
                    and ub.clients.obj-code = tt-fr-doc-line.prod-code no-lock.
  assign tt-fr-doc-line.obj-name = ub.clients.obj-name.
  release ub.clients.
  find first  ub.ext-artic where  ub.ext-artic.cli-type   = t-doc.cli-type
                        and  ub.ext-artic.cli-code   = t-doc.cli-code
                        and  ub.ext-artic.gds-code   = buf_goods.gds-code
                        and  ub.ext-artic.status_    <> 'удал':U
                        no-lock no-error.
  assign tt-fr-doc-line.cli-art = (if available  ub.ext-artic then  ub.ext-artic.ext-artic else ?).
  if available  ub.ext-artic then release  ub.ext-artic.
  find first ub.currency where ub.currency.curr-code = t-doc.exch-code no-lock.
  assign tt-fr-doc-line.curr-abbr = ub.currency.curr-abbr.
  release ub.currency.
  if parmode <> "create" then release bf-doc-line.
  if parmode = "create" then do:
    assign
      tt-fr-doc-line.type-inp-vat = yes
    .
  end.
  else do:
    find first type-inp-vat-attr no-lock
      where type-inp-vat-attr.doc-code   = t-doc.doc-code
        and type-inp-vat-attr.gds-code   = buf_goods.gds-code
        and type-inp-vat-attr.attr-code  = "type-inp-vat"
      no-error.
    if available type-inp-vat-attr then do:
      assign
        tt-fr-doc-line.type-inp-vat = (if type-inp-vat-attr.attr-value = "yes" then yes else no)
      .
    end.
    else do:
      assign
        tt-fr-doc-line.type-inp-vat = yes
      .
    end.
  end.
  display
    tt-fr-doc-line.artic
    tt-fr-doc-line.prod-type
    tt-fr-doc-line.prod-code
    tt-fr-doc-line.gds-name
    v-goods-ms-base
    tt-fr-doc-line.obj-name
    tt-fr-doc-line.unit-base
    tt-fr-doc-line.unit-cli
    tt-fr-doc-line.cli-art
    tt-fr-doc-line.curr-abbr
    tt-fr-doc-line.unit-cli
    tt-fr-doc-line.cli-base-rate
    tt-fr-doc-line.vat-pc
    tt-fr-doc-line.slt-pc
    varalc-prod
    with frame d-in-line.
 if v-cntxp-inout-price = true
   and v-insalepr = false
   and vat-sumvalue = "yes"
 then do:
   display
     tt-fr-doc-line.type-inp-vat
     with frame d-in-line.
 end.
end procedure.
procedure proc-quit:
  define buffer bf_doc-pl for ub.doc-pl.
  define buffer tmp_doc-line-attr for ub.doc-line-attr .
  do transaction
  on error undo, return error
  :
    find first ub.doc-line
      where recid( ub.doc-line ) = line-rec
      no-error .
    if available ub.doc-line
      and ( ub.doc-line.cli-qnty = 0
            or ub.doc-line.cli-qnty = ?
          )
    then do:
      run delete-doc-line in this-procedure no-error .
      if error-status :error
      then do:
        undo, return error .
      end.
      message
        "Строка имеет нулевое кол-во по ТТН и удаляется!!!"
        view-as alert-box information .
      assign
        pardoc-rec = recid( t-doc )
      .
      delete ub.doc-line .
      find first t-doc where
          recid( t-doc ) = pardoc-rec .
    end.
    if parline-mode = "ЦИКЛ":U
      or parline-mode = 'ДОБАВЛЕНИЕ':U
    then do:
      find first t-doc
        where recid( t-doc ) = pardoc-rec
      .
      for each tt-doc-pl
      :
        for each bf_doc-pl
          where bf_doc-pl.obj-type = t-doc.obj-type
            and bf_doc-pl.obj-code = t-doc.obj-code
            and bf_doc-pl.out-code = t-doc.doc-code
            and bf_doc-pl.gds-code = buf_goods.gds-code
        :
          delete bf_doc-pl.
        end.
        delete tt-doc-pl.
      end.
    end.
    if valid-object(infoSectionsTotal)
    and infoSectionsTotal:PlChanged
    then do :
      for each tmp_doc-line-attr exclusive-lock where tmp_doc-line-attr.doc-code = t-doc.doc-code
                                                  and tmp_doc-line-attr.gds-code = buf_goods.gds-code
                                                  and tmp_doc-line-attr.attr-code begins "list-tank" :
        delete tmp_doc-line-attr .
      end .
      for each tt-old-list-tank :
        create tmp_doc-line-attr .
        buffer-copy tt-old-list-tank to tmp_doc-line-attr .
      end .
      empty temp-table tt-old-list-tank .
    end .
  end.
end procedure.
procedure calc-all :
  define input parameter parmode-on as character no-undo .
  define variable varbase-rate-ca                like ub.trn-doc.base-rate    no-undo .
  define variable varbase-scale-ca               like ub.trn-doc.base-scale   no-undo .
  define variable varexch-rate-ca                like ub.trn-doc.exch-rate    no-undo .
  define variable varexch-scale-ca               like ub.trn-doc.exch-scale   no-undo .
  define variable varvat-type-ca                 like ub.parts.vat-type       no-undo .
  define variable varslt-type-ca                 like ub.parts.slt-type       no-undo .
  define variable varartic-ca                    like ub.parts.artic          no-undo .
  define variable varprod-type-ca                like ub.parts.prod-type      no-undo .
  define variable varprod-code-ca                like ub.parts.prod-code      no-undo .
  define variable varpr-cli-ca                   like ub.parts.price-cli      no-undo .
  define variable varcli-base-rate-ca            like ub.parts.cli-base-rate  no-undo .
  define variable varpr-rubl-ca                  like ub.parts.price-rubl     no-undo .
  define variable varvat-pc-ca                   like ub.parts.slt-pc         no-undo .
  define variable varslt-pc-ca                   like ub.parts.slt-pc         no-undo .
  define variable varroad-tax-ca                 like ub.parts.road-tax-rubl  no-undo .
  define variable vartransport-rubl-ca           like ub.parts.transport-rubl no-undo .
  define variable varother-rubl-ca               like ub.parts.other-rubl     no-undo .
  define variable varprice-cli-ca                like ub.doc-line.price-rubl  no-undo .
  define variable varprice-cli-unit-base-ca      like ub.doc-line.price-rubl  no-undo .
  define variable varprice-road-tax-ca           like ub.doc-line.price-rubl  no-undo .
  define variable varprice-other-exp-ca          like ub.doc-line.price-rubl  no-undo .
  define variable varprice-transport-exp-ca      like ub.doc-line.price-rubl  no-undo .
  define variable varprice-without-abs-ca        like ub.doc-line.price-rubl  no-undo .
  define variable varprice-slt-ca                like ub.doc-line.price-rubl  no-undo .
  define variable varprice-no-slt-ca             like ub.doc-line.price-rubl  no-undo .
  define variable varprice-vat-ca                like ub.doc-line.price-rubl  no-undo .
  define variable varprice-no-vat-slt-ca         like ub.doc-line.price-rubl  no-undo .
  define variable varprice-rubl-ca               like ub.doc-line.price-rubl  no-undo .
  define variable varprice-road-tax-rubl-ca      like ub.doc-line.price-rubl  no-undo .
  define variable varprice-other-exp-rubl-ca     like ub.doc-line.price-rubl  no-undo .
  define variable varprice-transport-exp-rubl-ca like ub.doc-line.price-rubl  no-undo .
  define variable varprice-without-abs-rubl-ca   like ub.doc-line.price-rubl  no-undo .
  define variable varprice-slt-rubl-ca           like ub.doc-line.price-rubl  no-undo .
  define variable varprice-no-slt-rubl-ca        like ub.doc-line.price-rubl  no-undo .
  define variable varprice-vat-rubl-ca           like ub.doc-line.price-rubl  no-undo .
  define variable varprice-no-vat-slt-rubl-ca    like ub.doc-line.price-rubl  no-undo .
  define variable varprice-base-ca               like ub.doc-line.price-base  no-undo .
  define variable varprice-road-tax-base-ca      like ub.doc-line.price-base  no-undo .
  define variable varprice-other-exp-base-ca     like ub.doc-line.price-base  no-undo .
  define variable varprice-transport-exp-base-ca like ub.doc-line.price-base  no-undo .
  define variable varprice-without-abs-base-ca   like ub.doc-line.price-base  no-undo .
  define variable varprice-slt-base-ca           like ub.doc-line.price-base  no-undo .
  define variable varprice-no-slt-base-ca        like ub.doc-line.price-base  no-undo .
  define variable varprice-vat-base-ca           like ub.doc-line.price-base  no-undo .
  define variable varprice-no-vat-slt-base-ca    like ub.doc-line.price-base  no-undo .
  define variable varcli-base-rate like ub.doc-line.cli-base-rate no-undo .
  define variable vardensity       like ub.doc-line.doc-density   no-undo .
  define variable varcli-qnty      like ub.doc-line.cli-qnty      no-undo .
  define variable vardoc-qnty      like ub.doc-line.doc-qnty      no-undo .
  define variable varroad-tax      like ub.doc-line.road-tax      no-undo .
  define variable varmode-on       as   character                 no-undo .
  define variable vari             as   integer                   no-undo .
  do vari = 1 to num-entries( parmode-on ) :
    assign
      varmode-on = entry( vari, parmode-on )
    .
    if varmode-on <> "doc-qnty":u      and
       varmode-on <> "acc-price":u     and
       varmode-on <> "density":u       and
       varmode-on <> "cli-base-rate":u and
       varmode-on <> "cli-price":u     and
       varmode-on <> "road-tax":u      and
       varmode-on <> "cli-qnty":u
    then do:
      message "Неверный параметр пересчета для процедуры calc-all: "
              parmode-on " ."
      view-as alert-box error .
      return error .
    end.
  end.
  if lookup( "cli-qnty", parmode-on ) > 0
  then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_clccliqt in g#lib-calc
  (
   input   varext-gds-type
  ,input   tt-fr-doc-line.doc-qnty
  ,input   tt-fr-doc-line.cli-base-rate
  ,input   tt-fr-doc-line.doc-density
  ,input   varround
  ,output  varcli-qnty
  ) no-error.
    if error-status :error
    then do:
      message "Ошибка при пересчете клиентского количества." skip( 0 )
              return-value                                   skip( 0 )
              error-status :get-message( 1 )                 skip( 0 )
              error-status :get-message( 2 )
      view-as alert-box error .
      return error .
    end.
    assign
      tt-fr-doc-line.cli-qnty = varcli-qnty
    .
    display tt-fr-doc-line.cli-qnty with frame d-in-line .
  end.
  if lookup( "density", parmode-on ) > 0
  then do:
    if tt-fr-doc-line.cli-qnty <> ?
      and tt-fr-doc-line.doc-qnty <> ?
    then do:
define variable vss-include-info89 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_clcdens in g#lib-calc
  (
   input   varext-gds-type
  ,input   tt-fr-doc-line.cli-qnty
  ,input   tt-fr-doc-line.doc-qnty
  ,output  vardensity
  ) no-error.
      if error-status :error
      then do:
        message "Ошибка при пересчете плотности." skip( 0 )
                return-value                                   skip( 0 )
                error-status :get-message( 1 )                 skip( 0 )
                error-status :get-message( 2 )
        view-as alert-box error .
        return error .
      end.
      assign
        tt-fr-doc-line.doc-density  = vardensity
        tt-fr-doc-line.fact-density = tt-fr-doc-line.doc-density
      .
      display tt-fr-doc-line.doc-density with frame d-in-line .
    end.
  end.
  if lookup( "doc-qnty", parmode-on ) > 0
  then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_clcdocqt in g#lib-calc
  ( input  varext-gds-type
   ,input  tt-fr-doc-line.cli-qnty
   ,input  tt-fr-doc-line.cli-base-rate
   ,input  tt-fr-doc-line.doc-density
   ,output vardoc-qnty
  ) no-error.
    if error-status :error
    then do:
      message "Ошибка при пересчете количества в базовых единицах." skip( 0 )
              return-value                                          skip( 0 )
              error-status :get-message( 1 )                        skip( 0 )
              error-status :get-message( 2 )
      view-as alert-box .
      return error .
    end.
    assign
      tt-fr-doc-line.doc-qnty = vardoc-qnty
    .
    display tt-fr-doc-line.doc-qnty with frame d-in-line .
  end.
  if lookup( "cli-base-rate", parmode-on ) > 0
  then do:
    if ( ( varext-gds-type = 'lp':U
           or varext-gds-type = 'kp':U
         )
        and tt-fr-doc-line.doc-density <> ?
       )
      or ( varext-gds-type <> 'lp':U
           and varext-gds-type <> 'kp':U
         )
    then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_clcclirt in g#lib-calc
  (
   input  varext-gds-type
  ,input  tt-fr-doc-line.cli-qnty
  ,input  tt-fr-doc-line.doc-qnty
  ,input  tt-fr-doc-line.doc-density
  ,input  varround
  ,output varcli-base-rate
  ) no-error.
      if error-status :error
      then do:
        message "Ошибка при расчете коэффициента поставщика." skip( 0 )
                return-value                                  skip( 0 )
                error-status :get-message( 1 )                skip( 0 )
                error-status :get-message( 2 )
        view-as alert-box error .
        return error .
      end.
      assign
        tt-fr-doc-line.cli-base-rate = varcli-base-rate
      .
      if tt-fr-doc-line.doc-density = ?
      then
      display tt-fr-doc-line.cli-base-rate with frame d-in-line .
    end.
  end.
  if lookup( "road-tax", parmode-on ) > 0
  then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_clcrdtax in g#lib-calc
  (
   input   buf_goods.gds-code
  ,input   varext-gds-type
  ,input   tt-fr-doc-line.cli-base-rate
  ,input   tt-fr-doc-line.doc-qnty
  ,input   tt-fr-doc-line.doc-density
  ,input   road-tax-cli
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,output  varroad-tax
  ) no-error .
    if error-status :error
    then do:
      message "Ошибка при пересчете дорожного налога" skip( 0 )
              return-value                            skip( 0 )
              error-status :get-message( 1 )          skip( 0 )
              error-status :get-message( 2 )
      view-as alert-box error .
      return error .
    end.
    assign
      tt-fr-doc-line.road-tax = varroad-tax
    .
    display tt-fr-doc-line.road-tax with frame d-in-line .
  end.
  if ( lookup( "cli-price", parmode-on ) > 0
      or lookup( "acc-price", parmode-on ) > 0
     )
     and tt-fr-doc-line.cli-base-rate <> ?
  then do:
    if v-insalepr = true then do:
      run calc-price-sale in this-procedure no-error .
      if error-status :error
      then do:
        message "Ошибка при установке продажной цены." skip( 0 )
                return-value
        view-as alert-box .
        return error .
      end.
    end.
    else do:
      if varbase-price-input = true then do:
        assign
          tt-fr-doc-line.price-cli = tt-fr-doc-line.price-rubl / t-doc.exch-rate * t-doc.exch-scale * tt-fr-doc-line.cli-base-rate
        .
      end.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   t-doc.doc-code
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,input   t-doc.vat-type
  ,input   t-doc.slt-type
  ,input   tt-fr-doc-line.artic
  ,input   tt-fr-doc-line.prod-type
  ,input   tt-fr-doc-line.prod-code
  ,input   tt-fr-doc-line.price-cli
  ,input   tt-fr-doc-line.cli-base-rate
  ,input   tt-fr-doc-line.price-rubl
  ,input   tt-fr-doc-line.vat-pc
  ,input   tt-fr-doc-line.slt-pc
  ,input   tt-fr-doc-line.road-tax
  ,input   tt-fr-doc-line.transport-rubl
  ,input   tt-fr-doc-line.other-rubl
  ,output  varprice-cli-ca
  ,output  varprice-cli-unit-base-ca
  ,output  varprice-road-tax-ca
  ,output  varprice-other-exp-ca
  ,output  varprice-transport-exp-ca
  ,output  varprice-without-abs-ca
  ,output  varprice-slt-ca
  ,output  varprice-no-slt-ca
  ,output  varprice-vat-ca
  ,output  varprice-no-vat-slt-ca
  ,output  varprice-rubl-ca
  ,output  varprice-road-tax-rubl-ca
  ,output  varprice-other-exp-rubl-ca
  ,output  varprice-transport-exp-rubl-ca
  ,output  varprice-without-abs-rubl-ca
  ,output  varprice-slt-rubl-ca
  ,output  varprice-no-slt-rubl-ca
  ,output  varprice-vat-rubl-ca
  ,output  varprice-no-vat-slt-rubl-ca
  ,output  varprice-base-ca
  ,output  varprice-road-tax-base-ca
  ,output  varprice-other-exp-base-ca
  ,output  varprice-transport-exp-base-ca
  ,output  varprice-without-abs-base-ca
  ,output  varprice-slt-base-ca
  ,output  varprice-no-slt-base-ca
  ,output  varprice-vat-base-ca
  ,output  varprice-no-vat-slt-base-ca
  ) no-error.
    if error-status :error
    then do:
      message "Ошибка при расчете цен."      skip( 0 )
              return-value                   skip( 0 )
              error-status :get-message( 1 ) skip( 0 )
              error-status :get-message( 2 )
      view-as alert-box error .
      return error .
    end.
    assign
      tt-fr-doc-line.price-cli  = varprice-cli-ca
      tt-fr-doc-line.price-base = varprice-base-ca
      tt-fr-doc-line.price-rubl = varprice-rubl-ca
    .
    display tt-fr-doc-line.price-cli
            tt-fr-doc-line.price-base
            tt-fr-doc-line.price-rubl
    with frame d-in-line .
  end.
  if parmode-on = vardensity-calc then do:
    for each tt-doc-pl
    on error undo, return error return-value
    :
      if tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line then do:
        assign
          tt-doc-pl.cli-qnty      = tt-doc-pl.doc-qnty  / tt-fr-doc-line.cli-base-rate
          tt-doc-pl.cli-doc-qnty  = tt-doc-pl.doc-qnty  * tt-fr-doc-line.doc-density
          tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * tt-fr-doc-line.fact-density
        .
      end.
      if tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line then do:
        assign
          tt-doc-pl.doc-qnty      = tt-doc-pl.cli-doc-qnty  / tt-fr-doc-line.doc-density
          tt-doc-pl.fact-qnty     = tt-doc-pl.cli-fact-qnty / tt-fr-doc-line.fact-density
        .
      end.
      if tt-fr-doc-line.fact-qnty :sensitive in frame d-in-line then do:
        assign
          tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * tt-fr-doc-line.fact-density
        .
      end.
      if tt-fr-doc-line.fact-qnty-kg :sensitive in frame d-in-line then do:
        assign
          tt-doc-pl.fact-qnty     = tt-doc-pl.cli-fact-qnty / tt-fr-doc-line.fact-density
        .
      end.
    end.
  end.
 if  pr-naklvalue = true  and pr-genmrg = 'before-margin':U and is-petrolium = false  then do:
  if not (( tt-fr-doc-line.price-rubl = 0  or tt-fr-doc-line.price-rubl = ? ) and
        ( parmode-on = "cli-qnty " or parmode-on = "doc-qnty" )) then do:
    run save-action in this-procedure
      ( input "light-super":U
      ) no-error .
    if error-status :error then do:
      return no-apply .
    end.
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run find-new-price-sale in this-procedure (
   input  pr-genmrg
  ,input  pr-naklvalue
  ,input  t-doc.doc-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  tt-fr-doc-line.price-rubl
  ,input  tt-fr-doc-line.price-base
  ,input  varprice-no-vat-slt-rubl-ca
  ,input  varprice-no-vat-slt-base-ca
  ,input-output tt-fr-doc-line.new-price-sale
    )
    no-error .
      if error-status :error then
      message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи(4)"
        view-as alert-box error
      .
   end.
  end.
  run disp-total in this-procedure no-error .
  if error-status :error
  then do:
    return error .
  end.
end procedure.
procedure proc-units:
// 20/IX-2018 в приходе и в спецификации можно указывать любую ЕИ, для которой на товаре задан коэфф.пересчёта к базовой ЕИ
// 28/IX-2018 в приходе по договору можно указать либо базовую ЕИ, либо ЕИ из спецификации договора
define buffer bf-r-units for ub.units.
define variable v-ret-unit-name  as character no-undo .
define variable v-ret-unit-coeff as decimal no-undo .
  run ref/alt-units.w (input parparentproc,
                       input 'ВЫБОР':U,
                       input buf_goods.gds-code,
                       input v-specif-unit-list,
                      output v-ret-unit-name,
                      output v-ret-unit-coeff) .
  if v-ret-unit-name > "" then do :
    if can-find (first bf-r-units where bf-r-units.unit-name = v-ret-unit-name) then do :
      tt-fr-doc-line.unit-cli      = v-ret-unit-name .
      tt-fr-doc-line.cli-base-rate = v-ret-unit-coeff .
      display
        tt-fr-doc-line.unit-cli
        tt-fr-doc-line.cli-base-rate
      with frame d-in-line.
    end .
  end .
  else return error .
end procedure.
procedure v-c-type-inp-vat:
do on error undo, return error return-value:
assign frame d-in-line tt-fr-doc-line.type-inp-vat.
if tt-fr-doc-line.type-inp-vat = yes then do:
   enable  tt-fr-doc-line.vat-pc when t-doc.vat-type <> 'без':U with frame d-in-line.
   disable sum-vat with frame d-in-line.
   apply "leave" to tt-fr-doc-line.vat-pc in frame d-in-line.
end.
else do:
   enable sum-vat when t-doc.vat-type <> 'без':U with frame d-in-line.
   disable tt-fr-doc-line.vat-pc with frame d-in-line.
   apply "leave" to sum-vat in frame d-in-line.
end.
end.
end procedure.
procedure chg-unit:
define variable v-unit-name as character no-undo .
define buffer buf_units    for ub.units .
define buffer buf_contract for ub.contract .
define buffer buf_contract-specif for ub.contract-specif .
  v-unit-name = input frame d-in-line tt-fr-doc-line.unit-cli .
  if not can-find (first buf_units where buf_units.unit-name = v-unit-name) then do:
    message
      substitute("Единица измерения поставщика [&1] отсутствует в справочнике единиц измерения", v-unit-name)
      view-as alert-box.
    display tt-fr-doc-line.unit-cli with frame d-in-line.
    apply "choose" to r-units.
    return no-apply.
  end.
  // 28/IX-2018 при создании ПН с договором можно указывать только базовую или ед. измерения по договору
  if t-doc.contract-code > 0 then do :
    if (buf_goods.unit-base = v-unit-name) or (v-specif-unit-list  = v-unit-name) then .
    else do :
      message
      substitute("Единицей измерения поставщика [&1] может быть или [&2] - базовая для товара, или [&3] - указанная в договоре",
                 v-unit-name, buf_goods.unit-base, v-specif-unit-list)
      view-as alert-box.
    display tt-fr-doc-line.unit-cli with frame d-in-line.
    apply "choose" to r-units.
    return no-apply.
    end .
  end .
  assign frame d-in-line tt-fr-doc-line.unit-cli.
end procedure.
procedure chs-dog :
do on error undo, return error return-value :
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.
define buffer bf_contract for ub.contract.
run str/cont-all.w (input parparentproc,
                input t-doc.host-code,
                input "b-sel",
                input "firm-curr" ,
                input t-doc.cli-type,
                input t-doc.cli-code,
                input ?,
                input ?,
                input "current":u,
                input 'при':U,
                input-output varrid-list ) no-error.
assign
  varrecid = integer(entry(1, varrid-list)).
find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
if available bf_contract then do:
  if bf_contract.doc-type <> 'при':U then do:
    message "Неверный тип контракта." view-as alert-box.
    return error.
  end.
  if bf_contract.cli-type <> t-doc.cli-type or
     bf_contract.cli-code <> t-doc.cli-code then do:
    message "Накладная оформляется на контрагента: " t-doc.cli-type " " t-doc.cli-code " ." skip
            "Договор по контрагенту: " bf_contract.cli-type " " bf_contract.cli-code " ."
    view-as alert-box error.
    return error.
  end.
  assign tt-fr-doc-line.contract-prn-code = bf_contract.contract-prn-code.
  assign tt-fr-doc-line.contract-code = bf_contract.contract-code.
end.
end.
end procedure.
procedure calc-price-sale:
  assign parprice-sale = ?.
  run tax-val in this-procedure
    (input tt-fr-doc-line.artic,
    input tt-fr-doc-line.prod-type,
    input tt-fr-doc-line.prod-code,
    input tt-fr-doc-line.unit-base,
    input ?,
    input tt-fr-doc-line.unit-type,
    input ?,
    input no,
    input integer(rdtaxcdvalue),
    input integer(vattaxcdvalue),
    input integer(exctaxcdvalue),
    input no,
    input t-doc.host-code,
    input t-doc.obj-type,
    input t-doc.obj-code,
    input ?,
    input ?,
    output temp-mes,
    input-output parprice-sale) no-error.
  if error-status :error or return-value = "error" then do:
     message "Ошибка при вызове процедуры налогов." view-as alert-box.
     return error.
  end.
  if parprice-sale = ? then do:
     message "Нельзя найти продажную цену товара по объекту. " +
             "Артикул " +  tt-fr-doc-line.artic + " Производитель " +
             tt-fr-doc-line.prod-type + " " + string(tt-fr-doc-line.prod-code) " ."
     view-as alert-box.
     return error.
  end.
  find first tt-tax where tt-tax.tax-code = integer(rdtaxcdvalue) no-error.
  if available tt-tax then do:
     assign  tt-fr-doc-line.road-tax = tt-tax.rate-value.
     display tt-fr-doc-line.road-tax with frame d-in-line.
  end.
  find first tt-tax where tt-tax.tax-code = integer(exctaxcdvalue) no-error.
  if available tt-tax then do:
     assign tt-fr-doc-line.excise = tt-tax.rate-value.
     display tt-fr-doc-line.excise with frame d-in-line.
  end.
  if varr-b = "rubl":u then do:
    assign
      tt-fr-doc-line.price-rubl = parprice-sale
      tt-fr-doc-line.price-base = tt-fr-doc-line.price-rubl / t-doc.base-rate * t-doc.base-scale
    .
  end.
  else do:
    assign
      tt-fr-doc-line.price-base = parprice-sale
      tt-fr-doc-line.price-rubl = tt-fr-doc-line.price-base * t-doc.base-rate /  t-doc.base-scale
    .
  end.
  assign
    tt-fr-doc-line.price-cli  = tt-fr-doc-line.price-rubl / t-doc.exch-rate * t-doc.exch-scale * tt-fr-doc-line.cli-base-rate
    tt-fr-doc-line.type-inp-sum = no
  .
  display
    tt-fr-doc-line.price-cli
    tt-fr-doc-line.price-base
    tt-fr-doc-line.price-rubl
    with frame d-in-line.
end.
procedure proc-country-code :
  do
  on error undo, return error return-value
  :
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.
define buffer bf_country for ub.country.
run ref/countris.w  (  input parparentproc
                 , input "b-sel"
                 , input-output varrid-list ) no-error.
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
             error-status :get-message( 1 )
     view-as alert-box.
     return .
     end.
if varrid-list = '' then return no-apply.
assign
  varrecid = integer(entry(1, varrid-list)).
find first bf_country no-lock where recid(bf_country) = varrecid no-error.
if available bf_country then do:
  assign tt-fr-doc-line.country-code  = bf_country.num-code
         tt-fr-doc-line.alpha1        = bf_country.alpha1
         tt-fr-doc-line.short-name    = bf_country.short-name
         .
  display
     tt-fr-doc-line.alpha1
     tt-fr-doc-line.short-name
     with frame d-in-line.
end.
  end.
end procedure.
procedure save-country-code :
  do
  on error undo, return error return-value
  :
run lineattr-write in this-procedure (
  input   t-doc.doc-code  ,
  input   buf_goods.gds-code  ,
  input   'country-code':U ,
  input   string(tt-fr-doc-line.country-code) )
  no-error .
    if error-status :error then do:
       message vss-workfile vss-revision vss-description skip
               error-status :get-message( 1 )
               return-value
       view-as alert-box error .
       return error.
    end.
end.
end procedure.
procedure edit-doc-pl :
  define input  parameter p-edit-doc-pl-mode as character no-undo .
  define variable d_fact-qnty     as decimal   no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal   no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal   no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal   no-undo initial 0.00 .
  define variable v-log           as logical   no-undo .
  define variable v-tmp-pl-code as integer no-undo .
  if varrvs-place = false then do:
    message
      substitute( "Товар &1 не привязывается к местам хранения.", buf_goods.gds-code )
      view-as alert-box.
    return .
  end.
  if parline-mode = 'ПРОСМОТР':U then do:
    assign
      p-edit-doc-pl-mode = 'ПРОСМОТР':U
    .
  end.
  else do:
    if t-doc.status_ = 'накл':U
      and t-doc.flag_ = false
    then do:
      if tt-fr-doc-line.cli-base-rate = 0
        or tt-fr-doc-line.cli-base-rate = ?
        or tt-fr-doc-line.doc-density = 0
        or tt-fr-doc-line.doc-density = ?
      then do:
        if tt-fr-doc-line.doc-density :sensitive in frame d-in-line then do:
          message
            "Не указана плотность"
            view-as alert-box information.
          apply "entry" to tt-fr-doc-line.doc-density in frame d-in-line .
          return error .
        end.
        else do:
          if tt-fr-doc-line.cli-base-rate :sensitive in frame d-in-line then do:
            message
              "Не указан коэффициент единиц измерения поставщика."
              view-as alert-box information.
              apply "entry" to tt-fr-doc-line.cli-base-rate in frame d-in-line .
            return error .
          end.
        end.
      end.
    end.
  end.
  if v-lgas-gds
  then
    for first tt-doc-pl :
      assign v-tmp-pl-code = tt-doc-pl.pl-code no-error .
    end .
  run str/doc-pls.w
    ( input parparentproc
     ,input p-edit-doc-pl-mode
     ,input (if t-doc.status_ = 'накл':U and t-doc.flag_ = false then "doc":U else "fact":U )
     ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
     ,input t-doc.doc-code
     ,input buf_goods.gds-code
     ,input tt-fr-doc-line.unit-cli
     ,input tt-fr-doc-line.cli-base-rate
     ,input tt-fr-doc-line.doc-density
     ,input tt-fr-doc-line.fact-density
     ,input tt-fr-doc-line.cli-qnty
     ,input tt-fr-doc-line.doc-qnty
     ,input tt-fr-doc-line.fact-qnty
     ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
     ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
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
  if parline-mode <> 'ПРОСМОТР':U then do:
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
    if tt-fr-doc-line.doc-qnty <> d_doc-qnty
      or
      ( tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line = true
         and absolute( tt-fr-doc-line.cli-qnty - d_cli-doc-qnty ) > 0.001
      )
      or
      ( tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line = true
        and tt-fr-doc-line.cli-qnty <> d_cli-doc-qnty
      )
    then do:
      message
        substitute( "Документарная сумма по местам хранения: &1 &2 (&3 &4)", d_doc-qnty, buf_goods.unit-base, d_cli-doc-qnty, buf_goods.unit-cli ) skip
        substitute( "Документарное кол-во по строке документа: &1 &2 (&3 &4)", tt-fr-doc-line.doc-qnty, buf_goods.unit-base, tt-fr-doc-line.doc-qnty * tt-fr-doc-line.doc-density, buf_goods.unit-cli ) skip(1)
        substitute( "Будем менять документарное количество по строке на &1 &2 (&3 &4)?", d_doc-qnty, buf_goods.unit-base, d_cli-doc-qnty, buf_goods.unit-cli )
        view-as alert-box question buttons yes-no update v-log.
      if v-log = true then do:
        assign
          tt-fr-doc-line.doc-qnty = d_doc-qnty
          tt-fr-doc-line.cli-qnty = d_cli-doc-qnty
          tt-fr-doc-line.doc-density = tt-fr-doc-line.cli-qnty / tt-fr-doc-line.doc-qnty
        .
        display
          tt-fr-doc-line.doc-qnty
          tt-fr-doc-line.cli-qnty
          tt-fr-doc-line.doc-density
          with frame d-in-line .
      end.
    end.
    if varupd-fact-qnty = true
      and not( t-doc.status_ = 'накл':U
               and t-doc.flag_ = false
             )
    then do :
      if absolute( tt-fr-doc-line.fact-qnty - d_fact-qnty ) <= 0.001
      then do :
        tt-fr-doc-line.fact-qnty = d_fact-qnty .
      end .
    end .
    if varupd-fact-qnty = true
      and not( t-doc.status_ = 'накл':U
               and t-doc.flag_ = false
             )
      and ( tt-fr-doc-line.fact-qnty <> d_fact-qnty
            or absolute( tt-fr-doc-line.fact-qnty-kg - d_cli-fact-qnty ) > 0.001
          )
    then do:
      message
        substitute( "Фактическая сумма по местам хранения: &1 &2 (&3 &4)", d_fact-qnty, buf_goods.unit-base, d_cli-fact-qnty, buf_goods.unit-cli ) skip
        substitute( "Фактическое кол-во по строке документа: &1 &2 (&3 &4)", tt-fr-doc-line.fact-qnty, buf_goods.unit-base, tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density, buf_goods.unit-cli ) skip(1)
        substitute( "Будем менять фактическое количество по строке на &1 &2 (&3 &4)?", d_fact-qnty, buf_goods.unit-base, d_cli-fact-qnty, buf_goods.unit-cli )
        view-as alert-box question buttons yes-no update v-log.
      if v-log = true then do:
        assign
          tt-fr-doc-line.fact-qnty    = d_fact-qnty
          tt-fr-doc-line.fact-qnty-kg = d_cli-fact-qnty
          tt-fr-doc-line.fact-density = tt-fr-doc-line.fact-qnty-kg / tt-fr-doc-line.fact-qnty
        .
        display
          tt-fr-doc-line.fact-qnty
          tt-fr-doc-line.fact-qnty-kg
          tt-fr-doc-line.fact-density
          with frame d-in-line
        .
      end.
    end.
    run check-place-rsrv in this-procedure
      no-error .
    if error-status :error then do:
      return error  .
    end.
    if v-lgas-gds
    then do :
      for first tt-doc-pl :
        if v-tmp-pl-code <> tt-doc-pl.pl-code
        then do :
          assign
            cb-connect-hoses = "empty"
          .
          display cb-connect-hoses with frame d-in-line .
        end .
        find first bf_place-attr no-lock where bf_place-attr.obj-type  = tt-doc-pl.obj-type
                                           and bf_place-attr.obj-code  = tt-doc-pl.obj-code
                                           and bf_place-attr.pl-code   = tt-doc-pl.pl-code
                                           and bf_place-attr.attr-code = "place-gate-valve"
                                           no-error .
        if available bf_place-attr
        and logical(bf_place-attr.attr-value)
        then do :
          enable cb-connect-hoses with frame d-in-line .
        end .
        else do :
          disable cb-connect-hoses with frame d-in-line .
        end .
      end .
    end .
  end.
end procedure.
procedure check-place-rsrv :
  define variable d_fact-qnty     as decimal no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal no-undo initial 0.00 .
  define variable d_cli-qnty      as decimal no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal no-undo initial 0.00 .
  define variable d_density       as decimal no-undo              .
  define variable j_pl-code       as integer no-undo              .
  do
  on error undo, return error return-value
  :
    if varrvs-place <> true
      or b-place :sensitive in frame d-in-line <> true
    then do:
      return .
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
    if tt-fr-doc-line.doc-qnty <> d_doc-qnty then do:
      message
        substitute( 'Количество по документу в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения: &2.&3'
                    , tt-fr-doc-line.doc-qnty
                    , d_doc-qnty
                    , chr(10)
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if ( tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line = true
         and tt-fr-doc-line.cli-qnty <> d_cli-doc-qnty
       )
       or
       ( tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line = false
         and absolute( tt-fr-doc-line.cli-qnty - d_cli-doc-qnty ) > 0.001
       )
    then do:
      message
        substitute( 'Количество по ТТН в ед.пост-ка в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ с суммарным количеством в ед.пост-ка по местам хранения: &2.&3'
                    + 'Нажмите кнопку "&4" и исправьте количества по местам хранения&3'
                    + 'или исправьте количество по ТТН в строке накладной.'
                    , tt-fr-doc-line.cli-qnty
                    , d_cli-doc-qnty
                    , chr(10)
                    , replace( b-place :label in frame d-in-line, "&", "":U )
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if not( t-doc.status_ = 'накл':U
            and t-doc.flag_ = false
          )
      and tt-fr-doc-line.fact-qnty <> d_fact-qnty
    then do:
      message
        substitute( 'Фактическое количество в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ &3 с суммарным фактическим количеством по местам хранения: &2.&3'
                    + 'Нажмите кнопку "&4" и исправьте количества по местам хранения&3'
                    + 'или исправьте фактическое количество в строке накладной.'
                    , tt-fr-doc-line.fact-qnty
                    , d_fact-qnty
                    , chr(10)
                    , replace( b-place :label in frame d-in-line, "&", "":U )
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if not( t-doc.status_ = 'накл':U
            and t-doc.flag_ = false
          )
      and absolute( tt-fr-doc-line.fact-qnty-kg - d_cli-fact-qnty ) > 0.001
    then do:
      message
        substitute( 'Фактическое количество в ед.пост-ка в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ &3 с суммарным фактическим количеством в ед.пост-ка по местам хранения: &2.&3'
                    + 'Нажмите кнопку "&4" и исправьте фактические количества в ед.пост-ка по местам хранения&3'
                    + 'или исправьте фактическое количество в ед.пост-ка в строке накладной.'
                    , tt-fr-doc-line.fact-qnty-kg
                    , d_cli-fact-qnty
                    , chr(10)
                    , replace( b-place :label in frame d-in-line, "&", "":U )
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if buf_goods.unit-base <> buf_goods.unit-cli then do:
      assign
        d_density = d_cli-doc-qnty / d_doc-qnty
      .
      if Valid-Density( d_density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true
        and ( tt-fr-doc-line.doc-qnty :sensitive in frame d-in-line
              or tt-fr-doc-line.cli-qnty :sensitive in frame d-in-line
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
      if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
        if d_density < v-min-dens
        or d_density > v-max-dens
        then do:
            message
              substitute("Заявленная плотность топлива (&1) находится вне заданного диапазона: &2."
              , d_density
              , v-gds-ptrl-densities )
              view-as alert-box error .
            undo, return error .
        end.
      end.
      assign
        d_density = d_cli-fact-qnty / d_fact-qnty
      .
      if Valid-Density( d_density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true
        and tt-fr-doc-line.fact-qnty :sensitive in frame d-in-line
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
      if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
        if d_density < v-min-dens
        or d_density > v-max-dens
        then do:
            message
              substitute("Фактическая плотность топлива (&1) находится вне заданного диапазона: &2."
              , d_density
              , v-gds-ptrl-densities )
              view-as alert-box error .
            undo, return error .
        end.
      end.
    end.
  end.
end procedure.
procedure display-b-rvs :
  if lookup(v-ptrl-without-rvs, 'true,yes':u) = 0 and not v-is-lgas-corr then do:
    enable
      b-rvs-bf
      b-rvs-af
      with frame d-in-line.
    if infoSectionsTotal:IsKP
    then do :
      for each tt-doc-pl,
        first bf_place no-lock where bf_place.pl-code = tt-doc-pl.pl-code
      :
        v-KPrvs-secs = "" .
        v-KPrvs-doc-pl = no .
        disable-rvs = no .
        do ii = 1 to infoSectionsTotal:SectionNum :
          if infoSectionsTotal:GetInfoSectionProp(ii):ListTank = bf_place.loc1
          then do :
            if infoSectionsTotal:GetInfoSectionProp(ii):IsKP
            then do :
              v-KPrvs-doc-pl = yes .
            end .
            v-KPrvs-secs = v-KPrvs-secs + "," + infoSectionsTotal:GetInfoSectionProp(ii):SectionName .
          end .
        end .
        v-KPrvs-secs = trim(v-KPrvs-secs, ",") .
        if not v-KPrvs-doc-pl
        then do :
          disable-rvs = no .
          leave .
        end .
        if v-KPrvs-doc-pl
        and num-entries(v-KPrvs-secs) >= 1
        then do :
          disable-rvs = yes .
        end .
      end .
      if disable-rvs
      then do :
        disable
          b-rvs-bf
          b-rvs-af
        with frame d-in-line.
      end .
    end .
  end.
end procedure .
procedure display-measure :
  do
  on error undo, return error return-value
  :
    define buffer bef_rvs-doc  for ub.rvs-doc  .
    define buffer aft_rvs-doc  for ub.rvs-doc  .
    define buffer bef_rvs-line for ub.rvs-line .
    define buffer aft_rvs-line for ub.rvs-line .
    define buffer bef2_rvs-line for ub.rvs-line .
    define buffer aft2_rvs-line for ub.rvs-line .
    define buffer buf_rvs-line-pump for ub.rvs-line-pump .
    define buffer bf2_place    for ub.place .
    define buffer buf_c-place-attr for ub.c-place-attr .
    define buffer buf2_c-place-attr for ub.c-place-attr .
    define buffer buf_pl-gds-pump   for ub.pl-gds-pump .
    define buffer buf_c-pl-gds-pump for ub.c-pl-gds-pump .
    define buffer buf2_c-pl-gds-pump for ub.c-pl-gds-pump .
    define variable v-old-qnty as decimal no-undo .
    define variable v-old-cli-qnty as decimal no-undo .
    define variable v-trk-err as logical no-undo .
    define variable jj as integer no-undo .
    define variable v-pl-gds-pump-status_ as character no-undo .
    assign
      v-old-qnty = tt-fr-doc-line.state-measure-qnty
      v-old-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty
    .
    assign
      tt-fr-doc-line.state-measure-qnty     = 0.00
      tt-fr-doc-line.measure-qnty           = 0.00
      tt-fr-doc-line.state-measure-cli-qnty = 0.00
      tt-fr-doc-line.measure-cli-qnty       = 0.00
      tt-fr-doc-line.trk-cli-qnty           = 0.00
    .
    empty temp-table tt-rvs-line-pump-delta .
    if infoSectionsTotal:IsKP
    then do :
      block-clc-rvs:
      for each tt-doc-pl
      on error undo, return error return-value
      :
        for each bef_rvs-doc no-lock
          where bef_rvs-doc.out-code  = t-doc.doc-code
            and bef_rvs-doc.rvs-type  = 'перед_док':U
        :
          for each bef_rvs-line no-lock
            where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
              and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
              and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
              and bef_rvs-line.pl-code  = tt-doc-pl.pl-code
              and bef_rvs-line.gds-code = tt-doc-pl.gds-code
          :
            assign
              tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     - bef_rvs-line.state-measure-qnty
              tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           - bef_rvs-line.measure-qnty
              tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty - bef_rvs-line.state-measure-cli-qnty
              tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       - bef_rvs-line.measure-cli-qnty
            .
            for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bef_rvs-line.rvs-code
                                                 and buf_rvs-line-pump.obj-type = bef_rvs-line.obj-type
                                                 and buf_rvs-line-pump.obj-code = bef_rvs-line.obj-code
                                                 and buf_rvs-line-pump.pl-code  = bef_rvs-line.pl-code
                                                 and buf_rvs-line-pump.gds-code = bef_rvs-line.gds-code
            :
              if t-doc.status_ = 'факт':U
              then do :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                      no-error .
              end .
              else do :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                        or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                      no-error .
              end .
              if available buf_c-pl-gds-pump
              then do :
                find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                        and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                        and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                        and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                        and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                        and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                        no-error .
                if available buf2_c-pl-gds-pump
                then do :
                  v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
              end .
              else do :
                for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                :
                  v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                end .
              end .
              if v-pl-gds-pump-status_ = 'тек':U
              then do :
                create tt-rvs-line-pump-delta .
                buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                assign
                  tt-rvs-line-pump-delta.rvs-code = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                  tt-rvs-line-pump-delta.density = (bef_rvs-line.state-density / 2)
                .
                if tt-rvs-line-pump-delta.state-el-cnt = ?
                or tt-rvs-line-pump-delta.state-el-cnt <= 0
                then do :
                  tt-rvs-line-pump-delta.is-err = yes .
                end .
              end .
            end.
          end .
          if t-doc.status_ = 'факт':U
          then do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = "place-com-tanks"
                                                 and (buf_c-place-attr.corr-date < t-doc.fact-date
                                                   or buf_c-place-attr.corr-date = t-doc.fact-date and buf_c-place-attr.corr-time < t-doc.fact-time)
                                                 no-error .
          end .
          else do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = "place-com-tanks"
                                                 and (buf_c-place-attr.corr-date < t-doc.sys-date
                                                   or buf_c-place-attr.corr-date = t-doc.sys-date and buf_c-place-attr.corr-time < t-doc.sys-time-int)
                                                 no-error .
          end .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign
                  v-ok = yes
                  varvalue = buf2_c-place-attr.attr-value
                .
              end .
            end .
            else do :
              run placelib_get-attr  ( input "place-com-tanks"
                ,input tt-doc-pl.obj-code
                ,input tt-doc-pl.obj-type
                ,input tt-doc-pl.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
            end .
          end .
          else do :
            run placelib_get-attr  ( input "place-com-tanks"
              ,input tt-doc-pl.obj-code
              ,input tt-doc-pl.obj-type
              ,input tt-doc-pl.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
          end .
          if v-ok
          and varvalue > ""
          then do :
            do jj = 1 to num-entries(varvalue) :
              find first bf2_place no-lock where bf2_place.obj-type = tt-doc-pl.obj-type
                                             and bf2_place.obj-code = tt-doc-pl.obj-code
                                             and bf2_place.loc1     = entry(jj, varvalue)
                                             no-error .
              if available bf2_place
              then do :
                find first bef2_rvs-line no-lock
                  where bef2_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                    and bef2_rvs-line.obj-type = bef_rvs-doc.obj-type
                    and bef2_rvs-line.obj-code = bef_rvs-doc.obj-code
                    and bef2_rvs-line.pl-code  = bf2_place.pl-code
                    and bef2_rvs-line.gds-code = tt-doc-pl.gds-code
                  no-error .
                if available bef2_rvs-line
                then do:
                  assign
                    tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     - bef2_rvs-line.state-measure-qnty
                    tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           - bef2_rvs-line.measure-qnty
                    tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty - bef2_rvs-line.state-measure-cli-qnty
                    tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       - bef2_rvs-line.measure-cli-qnty
                  .
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bef2_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.obj-type = bef2_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = bef2_rvs-line.obj-code
                                                       and buf_rvs-line-pump.pl-code  = bef2_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = bef2_rvs-line.gds-code
                  :
                    if t-doc.status_ = 'факт':U
                    then do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                            no-error .
                    end .
                    else do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                            no-error .
                    end .
                    if available buf_c-pl-gds-pump
                    then do :
                      find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                              and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                              and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                              and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                              and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                              and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                              no-error .
                      if available buf2_c-pl-gds-pump
                      then do :
                        v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                      end .
                      else do :
                        for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                        :
                          v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                        end .
                      end .
                    end .
                    else do :
                      for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                          and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                          and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                          and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                          and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                      :
                        v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                      end .
                    end .
                    if v-pl-gds-pump-status_ = 'тек':U
                    then do :
                      create tt-rvs-line-pump-delta .
                      buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                      assign
                        tt-rvs-line-pump-delta.rvs-code = "before-doc"
                        tt-rvs-line-pump-delta.density = (bef2_rvs-line.state-density / 2)
                      .
                      if tt-rvs-line-pump-delta.state-el-cnt = ?
                      or tt-rvs-line-pump-delta.state-el-cnt <= 0
                      then do :
                        tt-rvs-line-pump-delta.is-err = yes .
                      end .
                    end .
                  end.
                end .
              end .
            end .
          end .
        end .
        for each aft_rvs-doc no-lock
          where aft_rvs-doc.out-code  = t-doc.doc-code
            and aft_rvs-doc.rvs-type  = 'после_док':U
        :
          for each aft_rvs-line no-lock
            where aft_rvs-line.rvs-code = aft_rvs-doc.rvs-code
              and aft_rvs-line.obj-type = aft_rvs-doc.obj-type
              and aft_rvs-line.obj-code = aft_rvs-doc.obj-code
              and aft_rvs-line.pl-code  = tt-doc-pl.pl-code
              and aft_rvs-line.gds-code = tt-doc-pl.gds-code
          :
            assign
              tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     + aft_rvs-line.state-measure-qnty
              tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           + aft_rvs-line.measure-qnty
              tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty + aft_rvs-line.state-measure-cli-qnty
              tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       + aft_rvs-line.measure-cli-qnty
            .
            for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = aft_rvs-line.rvs-code
                                                 and buf_rvs-line-pump.obj-type = aft_rvs-line.obj-type
                                                 and buf_rvs-line-pump.obj-code = aft_rvs-line.obj-code
                                                 and buf_rvs-line-pump.pl-code  = aft_rvs-line.pl-code
                                                 and buf_rvs-line-pump.gds-code = aft_rvs-line.gds-code
            :
              if t-doc.status_ = 'факт':U
              then do :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                      no-error .
              end .
              else do :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                        or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                      no-error .
              end .
              if available buf_c-pl-gds-pump
              then do :
                find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                        and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                        and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                        and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                        and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                        and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                        no-error .
                if available buf2_c-pl-gds-pump
                then do :
                  v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
              end .
              else do :
                for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                :
                  v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                end .
              end .
              if v-pl-gds-pump-status_ = 'тек':U
              then do :
                find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                                                    and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                    and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                    and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                    and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                    and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                    and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                    no-error .
                if not available tt-rvs-line-pump-delta
                then do :
                  create tt-rvs-line-pump-delta .
                  buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                  assign
                    tt-rvs-line-pump-delta.rvs-code = "after-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                    tt-rvs-line-pump-delta.is-err = yes
                  .
                end .
                else do :
                  tt-rvs-line-pump-delta.find-pair = yes .
                  if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                  then do :
                    tt-rvs-line-pump-delta.is-err = yes .
                  end .
                  else do :
                    tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                    tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (aft_rvs-line.state-density / 2) .
                  end .
                end .
              end .
            end .
          end .
          if t-doc.status_ = 'факт':U
          then do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = "place-com-tanks"
                                                 and (buf_c-place-attr.corr-date < t-doc.fact-date
                                                   or buf_c-place-attr.corr-date = t-doc.fact-date and buf_c-place-attr.corr-time < t-doc.fact-time)
                                                 no-error .
          end .
          else do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = "place-com-tanks"
                                                 and (buf_c-place-attr.corr-date < t-doc.sys-date
                                                   or buf_c-place-attr.corr-date = t-doc.sys-date and buf_c-place-attr.corr-time < t-doc.sys-time-int)
                                                 no-error .
          end .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign
                  v-ok = yes
                  varvalue = buf2_c-place-attr.attr-value
                .
              end .
            end .
            else do :
              run placelib_get-attr  ( input "place-com-tanks"
                ,input tt-doc-pl.obj-code
                ,input tt-doc-pl.obj-type
                ,input tt-doc-pl.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
            end .
          end .
          else do :
            run placelib_get-attr  ( input "place-com-tanks"
              ,input tt-doc-pl.obj-code
              ,input tt-doc-pl.obj-type
              ,input tt-doc-pl.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
          end .
          if v-ok
          and varvalue > ""
          then do :
            do jj = 1 to num-entries(varvalue) :
              find first bf2_place no-lock where bf2_place.obj-type = tt-doc-pl.obj-type
                                             and bf2_place.obj-code = tt-doc-pl.obj-code
                                             and bf2_place.loc1     = entry(jj, varvalue)
                                             and bf2_place.status_  = ""
                                             no-error .
              if available bf2_place
              then do :
                find first aft2_rvs-line no-lock
                  where aft2_rvs-line.rvs-code = aft_rvs-doc.rvs-code
                    and aft2_rvs-line.obj-type = aft_rvs-doc.obj-type
                    and aft2_rvs-line.obj-code = aft_rvs-doc.obj-code
                    and aft2_rvs-line.pl-code  = bf2_place.pl-code
                    and aft2_rvs-line.gds-code = tt-doc-pl.gds-code
                  no-error .
                if available aft2_rvs-line
                then do:
                  assign
                    tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     + aft2_rvs-line.state-measure-qnty
                    tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           + aft2_rvs-line.measure-qnty
                    tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty + aft2_rvs-line.state-measure-cli-qnty
                    tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       + aft2_rvs-line.measure-cli-qnty
                  .
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = aft2_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.obj-type = aft2_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = aft2_rvs-line.obj-code
                                                       and buf_rvs-line-pump.pl-code  = aft2_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = aft2_rvs-line.gds-code
                  :
                    if t-doc.status_ = 'факт':U
                    then do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                            no-error .
                    end .
                    else do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                            no-error .
                    end .
                    if available buf_c-pl-gds-pump
                    then do :
                      find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                              and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                              and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                              and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                              and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                              and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                              no-error .
                      if available buf2_c-pl-gds-pump
                      then do :
                        v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                      end .
                      else do :
                        for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                        :
                          v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                        end .
                      end .
                    end .
                    else do :
                      for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                          and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                          and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                          and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                          and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                      :
                        v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                      end .
                    end .
                    if v-pl-gds-pump-status_ = 'тек':U
                    then do :
                      find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc"
                                                          and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                          and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                          and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                          and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                          and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                          and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                          no-error .
                      if not available tt-rvs-line-pump-delta
                      then do :
                        create tt-rvs-line-pump-delta .
                        buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                        assign
                          tt-rvs-line-pump-delta.rvs-code = "after-doc"
                          tt-rvs-line-pump-delta.is-err = yes
                        .
                      end .
                      else do :
                        tt-rvs-line-pump-delta.find-pair = yes .
                        if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                        then do :
                          tt-rvs-line-pump-delta.is-err = yes .
                        end .
                        else do :
                          tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                          tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (aft2_rvs-line.state-density / 2) .
                        end .
                      end .
                    end .
                  end .
                end .
              end .
            end .
          end .
        end .
        assign
          tt-fr-doc-line.state-measure-qnty     = ? when tt-fr-doc-line.state-measure-qnty <= 0
          tt-fr-doc-line.measure-qnty           = ? when tt-fr-doc-line.measure-qnty <= 0
          tt-fr-doc-line.state-measure-cli-qnty = ? when tt-fr-doc-line.state-measure-cli-qnty <= 0
          tt-fr-doc-line.measure-cli-qnty       = ? when tt-fr-doc-line.measure-cli-qnty <= 0
        .
      end .
    end .
    else do :
      find first bef_rvs-doc no-lock
        where bef_rvs-doc.out-code  = t-doc.doc-code
          and bef_rvs-doc.rvs-type  = 'перед_док':U
        no-error .
      find first aft_rvs-doc no-lock
        where aft_rvs-doc.out-code  = t-doc.doc-code
          and aft_rvs-doc.rvs-type  = 'после_док':U
        no-error .
      block-clc-rvs:
      for each tt-doc-pl
      on error undo, return error return-value
      :
        find first bef_rvs-line no-lock
          where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
            and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
            and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
            and bef_rvs-line.pl-code  = tt-doc-pl.pl-code
            and bef_rvs-line.gds-code = tt-doc-pl.gds-code
          no-error .
        find first aft_rvs-line no-lock
          where aft_rvs-line.rvs-code = aft_rvs-doc.rvs-code
            and aft_rvs-line.obj-type = aft_rvs-doc.obj-type
            and aft_rvs-line.obj-code = aft_rvs-doc.obj-code
            and aft_rvs-line.pl-code  = tt-doc-pl.pl-code
            and aft_rvs-line.gds-code = tt-doc-pl.gds-code
          no-error .
        if available aft_rvs-line
        and available bef_rvs-line
        then do:
          assign
            tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     + aft_rvs-line.state-measure-qnty      - bef_rvs-line.state-measure-qnty
            tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           + aft_rvs-line.measure-qnty            - bef_rvs-line.measure-qnty
            tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty + aft_rvs-line.state-measure-cli-qnty  - bef_rvs-line.state-measure-cli-qnty
            tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       + aft_rvs-line.measure-cli-qnty        - bef_rvs-line.measure-cli-qnty
          .
          for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bef_rvs-line.rvs-code
                                               and buf_rvs-line-pump.obj-type = bef_rvs-line.obj-type
                                               and buf_rvs-line-pump.obj-code = bef_rvs-line.obj-code
                                               and buf_rvs-line-pump.pl-code  = bef_rvs-line.pl-code
                                               and buf_rvs-line-pump.gds-code = bef_rvs-line.gds-code
          :
            if t-doc.status_ = 'факт':U
            then do :
              find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                    and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                      or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                    no-error .
            end .
            else do :
              find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                    and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                      or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                    no-error .
            end .
            if available buf_c-pl-gds-pump
            then do :
              find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                      and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                      and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                      and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                      and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                      and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                      no-error .
              if available buf2_c-pl-gds-pump
              then do :
                v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
              end .
              else do :
                for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                :
                  v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                end .
              end .
            end .
            else do :
              for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                  and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                  and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                  and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                  and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
              :
                v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
              end .
            end .
            if v-pl-gds-pump-status_ = 'тек':U
            then do :
              create tt-rvs-line-pump-delta .
              buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
              assign
                tt-rvs-line-pump-delta.rvs-code = "before-doc"
                tt-rvs-line-pump-delta.density = (bef_rvs-line.state-density / 2)
              .
              if tt-rvs-line-pump-delta.state-el-cnt = ?
              or tt-rvs-line-pump-delta.state-el-cnt <= 0
              then do :
                tt-rvs-line-pump-delta.is-err = yes .
              end .
            end .
          end.
          for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = aft_rvs-line.rvs-code
                                               and buf_rvs-line-pump.obj-type = aft_rvs-line.obj-type
                                               and buf_rvs-line-pump.obj-code = aft_rvs-line.obj-code
                                               and buf_rvs-line-pump.pl-code  = aft_rvs-line.pl-code
                                               and buf_rvs-line-pump.gds-code = aft_rvs-line.gds-code
          :
            if t-doc.status_ = 'факт':U
            then do :
              find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                    and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                      or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                    no-error .
            end .
            else do :
              find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                    and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                      or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                    no-error .
            end .
            if available buf_c-pl-gds-pump
            then do :
              find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                      and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                      and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                      and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                      and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                      and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                      no-error .
              if available buf2_c-pl-gds-pump
              then do :
                v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
              end .
              else do :
                for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                :
                  v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                end .
              end .
            end .
            else do :
              for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                  and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                  and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                  and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                  and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
              :
                v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
              end .
            end .
            if v-pl-gds-pump-status_= 'тек':U
            then do :
              find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc"
                                                  and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                  and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                  and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                  and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                  and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                  and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                  no-error .
              if not available tt-rvs-line-pump-delta
              then do :
                create tt-rvs-line-pump-delta .
                buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                assign
                  tt-rvs-line-pump-delta.rvs-code = "after-doc"
                  tt-rvs-line-pump-delta.is-err = yes
                .
              end .
              else do :
                tt-rvs-line-pump-delta.find-pair = yes .
                if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                then do :
                  tt-rvs-line-pump-delta.is-err = yes .
                end .
                else do :
                  tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                  tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (aft_rvs-line.state-density / 2) .
                end .
              end .
            end .
          end .
          if t-doc.status_ = 'факт':U
          then do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = "place-com-tanks"
                                                 and (buf_c-place-attr.corr-date < t-doc.fact-date
                                                   or buf_c-place-attr.corr-date = t-doc.fact-date and buf_c-place-attr.corr-time < t-doc.fact-time)
                                                 no-error .
          end .
          else do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = "place-com-tanks"
                                                 and (buf_c-place-attr.corr-date < t-doc.sys-date
                                                   or buf_c-place-attr.corr-date = t-doc.sys-date and buf_c-place-attr.corr-time < t-doc.sys-time-int)
                                                 no-error .
          end .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign
                  v-ok = yes
                  varvalue = buf2_c-place-attr.attr-value
                .
              end .
            end .
            else do :
              run placelib_get-attr  ( input "place-com-tanks"
                ,input tt-doc-pl.obj-code
                ,input tt-doc-pl.obj-type
                ,input tt-doc-pl.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
            end .
          end .
          else do :
            run placelib_get-attr  ( input "place-com-tanks"
              ,input tt-doc-pl.obj-code
              ,input tt-doc-pl.obj-type
              ,input tt-doc-pl.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
          end .
          if v-ok
          and varvalue > ""
          then do :
            do jj = 1 to num-entries(varvalue) :
              find first bf2_place no-lock where bf2_place.obj-type = tt-doc-pl.obj-type
                                             and bf2_place.obj-code = tt-doc-pl.obj-code
                                             and bf2_place.loc1     = entry(jj, varvalue)
                                             and bf2_place.status_  = ""
                                             no-error .
              if available bf2_place
              then do :
                find first bef2_rvs-line no-lock
                  where bef2_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                    and bef2_rvs-line.obj-type = bef_rvs-doc.obj-type
                    and bef2_rvs-line.obj-code = bef_rvs-doc.obj-code
                    and bef2_rvs-line.pl-code  = bf2_place.pl-code
                    and bef2_rvs-line.gds-code = tt-doc-pl.gds-code
                  no-error .
                find first aft2_rvs-line no-lock
                  where aft2_rvs-line.rvs-code = aft_rvs-doc.rvs-code
                    and aft2_rvs-line.obj-type = aft_rvs-doc.obj-type
                    and aft2_rvs-line.obj-code = aft_rvs-doc.obj-code
                    and aft2_rvs-line.pl-code  = bf2_place.pl-code
                    and aft2_rvs-line.gds-code = tt-doc-pl.gds-code
                  no-error .
                if available aft2_rvs-line
                and available bef2_rvs-line
                then do:
                  assign
                    tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     + aft2_rvs-line.state-measure-qnty      - bef2_rvs-line.state-measure-qnty
                    tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           + aft2_rvs-line.measure-qnty            - bef2_rvs-line.measure-qnty
                    tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty + aft2_rvs-line.state-measure-cli-qnty  - bef2_rvs-line.state-measure-cli-qnty
                    tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       + aft2_rvs-line.measure-cli-qnty        - bef2_rvs-line.measure-cli-qnty
                  .
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bef2_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.obj-type = bef2_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = bef2_rvs-line.obj-code
                                                       and buf_rvs-line-pump.pl-code  = bef2_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = bef2_rvs-line.gds-code
                  :
                    if t-doc.status_ = 'факт':U
                    then do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                            no-error .
                    end .
                    else do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                            no-error .
                    end .
                    if available buf_c-pl-gds-pump
                    then do :
                      find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                              and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                              and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                              and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                              and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                              and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                              no-error .
                      if available buf2_c-pl-gds-pump
                      then do :
                        v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                      end .
                      else do :
                        for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                        :
                          v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                        end .
                      end .
                    end .
                    else do :
                      for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                          and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                          and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                          and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                          and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                      :
                        v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                      end .
                    end .
                    if v-pl-gds-pump-status_ = 'тек':U
                    then do :
                      create tt-rvs-line-pump-delta .
                      buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                      assign
                        tt-rvs-line-pump-delta.rvs-code = "before-doc"
                        tt-rvs-line-pump-delta.density = (bef_rvs-line.state-density / 2)
                      .
                      if tt-rvs-line-pump-delta.state-el-cnt = ?
                      or tt-rvs-line-pump-delta.state-el-cnt <= 0
                      then do :
                        tt-rvs-line-pump-delta.is-err = yes .
                      end .
                    end .
                  end.
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = aft2_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.obj-type = aft2_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = aft2_rvs-line.obj-code
                                                       and buf_rvs-line-pump.pl-code  = aft2_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = aft2_rvs-line.gds-code
                  :
                    if t-doc.status_ = 'факт':U
                    then do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                            no-error .
                    end .
                    else do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                            no-error .
                    end .
                    if available buf_c-pl-gds-pump
                    then do :
                      find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                              and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                              and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                              and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                              and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                              and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                              no-error .
                      if available buf2_c-pl-gds-pump
                      then do :
                        v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                      end .
                      else do :
                        for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                        :
                          v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                        end .
                      end .
                    end .
                    else do :
                      for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                          and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                          and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                          and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                          and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                      :
                        v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                      end .
                    end .
                    if v-pl-gds-pump-status_ = 'тек':U
                    then do :
                      find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc"
                                                          and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                          and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                          and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                          and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                          and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                          and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                          no-error .
                      if not available tt-rvs-line-pump-delta
                      then do :
                        create tt-rvs-line-pump-delta .
                        buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                        assign
                          tt-rvs-line-pump-delta.rvs-code = "after-doc"
                          tt-rvs-line-pump-delta.is-err = yes
                        .
                      end .
                      else do :
                        tt-rvs-line-pump-delta.find-pair = yes .
                        if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                        then do :
                          tt-rvs-line-pump-delta.is-err = yes .
                        end .
                        else do :
                          tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                          tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (aft_rvs-line.state-density / 2) .
                        end .
                      end .
                    end .
                  end .
                end .
              end .
            end .
          end .
        end.
        else do:
          assign
            tt-fr-doc-line.state-measure-qnty     = ?
            tt-fr-doc-line.measure-qnty           = ?
            tt-fr-doc-line.state-measure-cli-qnty = ?
            tt-fr-doc-line.measure-cli-qnty       = ?
          .
          if available bef_rvs-doc
            and available aft_rvs-doc
            and lookup(v-ptrl-without-rvs, 'true,yes':u) = 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Сверки по документу созданы неверно!" skip
              "Необходимо удалить сверки и создать из заново." skip
              view-as alert-box error .
          end.
          leave block-clc-rvs .
        end.
      end.
    end .
    v-trk-err = no .
    find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.is-err no-error .
    if available tt-rvs-line-pump-delta
    then do :
      v-trk-err = yes .
      tt-fr-doc-line.trk-cli-qnty = ? .
    end .
    else do :
      for each tt-rvs-line-pump-delta :
        assign
          tt-fr-doc-line.trk-cli-qnty = tt-fr-doc-line.trk-cli-qnty + (tt-rvs-line-pump-delta.deltaVol * tt-rvs-line-pump-delta.density)
        .
      end .
    end .
    display
      tt-fr-doc-line.state-measure-qnty
      tt-fr-doc-line.measure-qnty
      tt-fr-doc-line.state-measure-cli-qnty
      tt-fr-doc-line.trk-cli-qnty
    with frame d-in-line .
  end.
end procedure.
procedure init-tt-doc-pl :
  define buffer buf_doc-pl for ub.doc-pl .
  for each tt-doc-pl
  on error undo, return error error-status :get-message(1)
  :
    delete tt-doc-pl .
  end.
  for each buf_doc-pl no-lock
    where buf_doc-pl.obj-type = t-doc.obj-type
      and buf_doc-pl.obj-code = t-doc.obj-code
      and buf_doc-pl.out-code = t-doc.doc-code
      and buf_doc-pl.gds-code = buf_goods.gds-code
  on error undo, return error error-status :get-message(1)
  :
    create tt-doc-pl .
    buffer-copy buf_doc-pl to tt-doc-pl .
  end.
end procedure.
procedure new-price-s :
  do
  on error undo, return error return-value
  :
if not ( pr-naklvalue = yes and pr-genmrg = 'before-margin':U and is-petrolium = false  ) then do:
   hide  tt-fr-doc-line.new-price-sale  in frame d-in-line
         abr-rb in frame d-in-line
         b-corr-price-sale in frame d-in-line
         .
   return.
end.
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-abbr in g#library
  (input  t-doc.host-code
  ,output abr-rb
  )  .
if parline-mode = 'ПРОСМОТР':U then do:
end.
else do:
  define variable l-ok as logical   no-undo .
define variable vss-include-info92 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      enable tt-fr-doc-line.new-price-sale  with frame d-in-line .
    end.
end.
define variable p-exist   as logical  no-undo .
run lineattr-exist in this-procedure (
    input t-doc.doc-code  ,
    input buf_goods.gds-code    ,
    input 'corr-price-sale':U ,
    output p-exist ) .
if p-exist then display b-corr-price-sale with frame d-in-line .
           else hide    b-corr-price-sale in frame d-in-line .
tt-fr-doc-line.new-price-sale:tooltip = "Цена будет перенесена в переоценку до закрытия этой накладной до ФАКТ" .
display tt-fr-doc-line.new-price-sale abr-rb with frame d-in-line .
  end.
end procedure.
procedure save-place-rsrv :
  define input  parameter kind-check as character no-undo.
  define output parameter p-ok       as logical   no-undo .
  do
  on error  undo, return error substitute( "&1 (save-place-rsrv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (save-place-rsrv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (save-place-rsrv). endkey", vss-workfile )
  :
    define buffer buf_doc-pl for ub.doc-pl .
    define variable v-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
    define variable v-new-density          like ub.doc-line.fact-density no-undo .
    define variable v-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
    assign
      p-ok = true
    .
    if is-petrolium = yes
      and is-pieces = no
      and kind-check = "hard":U
      and not( t-doc.status_ = 'накл':U
               and t-doc.flag_ = false
             )
    then do:
      run chkdcrvs in this-procedure
        ( input  tt-fr-doc-line.doc-code
         ,input  buf_goods.gds-code
         ,output p-ok
        ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
      if p-ok = true then do:
        assign
          v-new-fact-qnty     = tt-fr-doc-line.fact-qnty
          v-new-density       = tt-fr-doc-line.fact-density
          v-new-cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg
        .
        run local-state-fact-rvs in this-procedure
          ( input        tt-fr-doc-line.doc-code
           ,input        buf_goods.gds-code
           ,input        stfactplvalue
           ,input        varrevision
           ,input        varupd-fact-qnty
           ,input        tt-fr-doc-line.doc-qnty
           ,input        tt-fr-doc-line.doc-density
           ,input-output v-new-fact-qnty
           ,input-output v-new-density
           ,input-output v-new-cli-fact-qnty
          ) no-error .
        if error-status :error then do:
          message
            "Ошибка при установке факт кол-ва (revision)." skip
            return-value
            view-as alert-box error .
          undo, return error .
        end.
        if tt-fr-doc-line.fact-qnty <> v-new-fact-qnty
          or tt-fr-doc-line.fact-qnty-kg <> v-new-cli-fact-qnty
        then do:
          run correct-fact-qnty in this-procedure
            ( input v-new-fact-qnty
             ,input v-new-density
            ) no-error .
        end.
        display
          tt-fr-doc-line.fact-qnty
          tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
          tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
          with frame d-in-line .
        run eq-qnty-rvs-pl in this-procedure
          ( input        tt-fr-doc-line.doc-code
           ,input        buf_goods.gds-code
           ,input        varupd-fact-qnty
           ,input-output v-new-fact-qnty
           ,input-output v-new-density
           ,input-output v-new-cli-fact-qnty
           ,output p-ok
          ) no-error .
        if error-status :error then do:
          message
            "Ошибка при установке факт кол-ва по местам хранения." skip
            return-value
            view-as alert-box error .
          undo, return error .
        end.
        if tt-fr-doc-line.fact-qnty <> v-new-fact-qnty
          or tt-fr-doc-line.fact-qnty-kg <> v-new-cli-fact-qnty
        then do:
          assign
            tt-fr-doc-line.fact-qnty    = v-new-fact-qnty
            tt-fr-doc-line.fact-density = v-new-density
            tt-fr-doc-line.fact-qnty-kg = v-new-cli-fact-qnty
          .
          display
            tt-fr-doc-line.fact-qnty
            tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
            tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
            with frame d-in-line .
        end.
        if p-ok = false then do:
          return .
        end.
      end.
      else do:
        assign
          p-ok = true
        .
      end.
    end.
    run check-place-rsrv in this-procedure
      no-error.
    if error-status :error then do:
      return error substitute( "&1 (save-place-rsrv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
    end.
    for each buf_doc-pl
      where buf_doc-pl.obj-type = tt-fr-doc-line.obj-type
        and buf_doc-pl.obj-code = tt-fr-doc-line.obj-code
        and buf_doc-pl.out-code = tt-fr-doc-line.doc-code
        and buf_doc-pl.gds-code = buf_goods.gds-code
    on error undo, return error substitute( "&1 (save-place-rsrv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete buf_doc-pl .
    end.
    for each tt-doc-pl
    on error undo, return error substitute( "&1 (save-place-rsrv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      create buf_doc-pl .
      buffer-copy tt-doc-pl to buf_doc-pl .
    end.
    if b-addinf :sensitive in frame d-in-line = true then do:
    end.
  end.
  return .
end procedure.
procedure correct-fact-qnty :
  define input parameter p-newfact-qnty like ub.doc-line.fact-qnty   no-undo .
  define input parameter p-density      like ub.doc-line.doc-density no-undo .
  define variable infoSecObj  as class ibs.th.str.InfoSection no-undo .
  define variable ii          as integer no-undo .
  define variable v-correct-cli-fact-qnty as decimal no-undo .
  define variable v-correct-fact-qnty as decimal no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf-next_tt-doc-pl for tt-doc-pl .
    define buffer buf_place for ub.place .
    assign
      tt-fr-doc-line.fact-qnty    = p-newfact-qnty
      tt-fr-doc-line.fact-density = p-density
      tt-fr-doc-line.fact-qnty-kg = p-newfact-qnty * p-density
    .
    display
      tt-fr-doc-line.fact-qnty
      tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
      tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
      with frame d-in-line .
    find first tt-doc-pl no-lock
    .
    find first buf-next_tt-doc-pl no-lock
      where buf-next_tt-doc-pl.obj-type =  tt-doc-pl.obj-type
        and buf-next_tt-doc-pl.obj-code =  tt-doc-pl.obj-code
        and buf-next_tt-doc-pl.pl-code  <> tt-doc-pl.pl-code
      no-error .
    if available buf-next_tt-doc-pl then do:
      for each tt-doc-pl,
      first buf_place no-lock where buf_place.pl-code = tt-doc-pl.pl-code
      on error undo, return error return-value
      :
        tt-doc-pl.fact-qnty = 0 .
        tt-doc-pl.cli-fact-qnty = 0 .
        do ii = 1 to infoSectionsTotal:SectionNum :
          infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
          if infoSecObj:ListTank = buf_place.loc1
          then do :
            tt-doc-pl.fact-qnty = tt-doc-pl.fact-qnty + infoSecObj:FactQnty .
            tt-doc-pl.cli-fact-qnty = tt-doc-pl.cli-fact-qnty + (infoSecObj:FactQnty * infoSecObj:FactDensity) .
          end .
        end .
      end.
      v-correct-cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg .
      v-correct-fact-qnty = tt-fr-doc-line.fact-qnty .
      for each tt-doc-pl :
        assign
          v-correct-cli-fact-qnty = v-correct-cli-fact-qnty - tt-doc-pl.cli-fact-qnty
          v-correct-fact-qnty = v-correct-fact-qnty - tt-doc-pl.fact-qnty
        .
        if absolute( v-correct-cli-fact-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.cli-fact-qnty = tt-doc-pl.cli-fact-qnty + v-correct-cli-fact-qnty
          .
        end.
        if absolute( v-correct-fact-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.fact-qnty = tt-doc-pl.fact-qnty + v-correct-fact-qnty
          .
        end.
      end .
      run edit-doc-pl in this-procedure
        ( input 'АВТОИЗМЕНЕНИЕ':U
        ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
    end.
    else do:
      assign
        tt-doc-pl.fact-qnty     = tt-fr-doc-line.fact-qnty
        tt-doc-pl.cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg
      .
    end.
  end.
end procedure.
procedure new-price-prod :
define variable par-is-pharm  as character no-undo .
define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-pharm'
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-pharm
  ,output par-type
  ) no-error .
  .
if par-is-pharm <> "yes"  then par-is-pharm = "no" .
else do:
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$workfile: $ $revision: $".
define variable v-o-pharm    as character no-undo .
define variable v-o-var-type as character no-undo .
  run clntattr-value in this-procedure
    ( input   v-cntxt-obj-type ,
      input   v-cntxt-obj-code ,
      input  'pharm':U,
      output v-o-pharm    ,
      output v-o-var-type )
     no-error .
  if v-o-pharm <> "yes":u or error-status :error then do:
     par-is-pharm = "no"  .
  end.
end.
if par-is-pharm <> "yes"   then do:
   hide  tt-fr-doc-line.price-prod     in frame d-in-line
         tt-fr-doc-line.price-prod-vat in frame d-in-line
         abr-rb2 in frame d-in-line
         .
   return.
end.
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-abbr in g#library
  (input  t-doc.host-code
  ,output abr-rb2
  )  .
if parline-mode = 'ПРОСМОТР':U then do:
end.
else do:
  define variable l-ok as logical   no-undo .
define variable vss-include-info95 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_price-prod':U
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
      enable tt-fr-doc-line.price-prod  tt-fr-doc-line.price-prod-vat with frame d-in-line .
    end.
end.
   tt-fr-doc-line.price-prod:tooltip = "Цена Производителя товаров медицинского назначения" .
   tt-fr-doc-line.price-prod-vat:tooltip = "Цена Производителя С НДС товаров медицинского назначения" .
display tt-fr-doc-line.price-prod tt-fr-doc-line.price-prod-vat abr-rb2 with frame d-in-line .
  end.
end procedure.
procedure save-price-prod :
  do
  on error undo, return error return-value
  :
run lineattr-write in this-procedure (
  input   t-doc.doc-code  ,
  input   buf_goods.gds-code  ,
  input   'price-prod':U ,
  input   string(tt-fr-doc-line.price-prod) )
  no-error .
    if error-status :error then do:
       message vss-workfile vss-revision vss-description skip
               error-status :get-message( 1 ) skip
               return-value skip
               "№1"
       view-as alert-box error .
       return error.
    end.
run lineattr-write in this-procedure (
  input   t-doc.doc-code  ,
  input   buf_goods.gds-code  ,
  input   'price-prodvat':U ,
  input   string(tt-fr-doc-line.price-prod-vat) )
  no-error .
    if error-status :error then do:
       message vss-workfile vss-revision vss-description skip
               error-status :get-message( 1 ) skip
               return-value skip
               "№2"
       view-as alert-box error .
       return error.
    end.
end.
end procedure.
procedure p-chk-vat private:
define input parameter p-new-vat-pc as decimal no-undo .
      if dops > '' and not f-chekval(input dops, input p-new-vat-pc) then do:
         message "Неверное значение НДС:" p-new-vat-pc skip
                 "Разрешенные значения: " replace(dops, ",", "%, ") + "%."
                 view-as alert-box.
         display tt-fr-doc-line.vat-pc with frame d-in-line.
         return error.
      end.
      if  dop-slt > '' and not f-chekval(input dop-slt , input tt-fr-doc-line.slt-pc) then do:
         message "Неверное значение НсП."   skip
                 "Разрешенные значения: " dop-slt "."
                 view-as alert-box.
         display tt-fr-doc-line.slt-pc with frame d-in-line.
         return error.
      end.
end procedure.
