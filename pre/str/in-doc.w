using ibs.th.gbl.storage.*.
using ibs.th.str.*.
DEFINE BUFFER t-doc FOR ub.trn-doc.
DEFINE BUFFER src-doc FOR ub.trn-doc.
define input        parameter parparentproc   as   handle                  no-undo.
define input-output parameter pardoc-rec      as   recid                   no-undo.
define input        parameter pardoc-mode     as   character               no-undo.
define input        parameter partype         as   character               no-undo.
define input        parameter parinternal     as   logical                 no-undo.
define input-output parameter parnext-prev    as   logical                 no-undo.
define input        parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input        parameter paris-hold      as   logical                 no-undo.
define input-output parameter line-rec        as   recid                   no-undo.
define input        parameter br-handle       as   handle                  no-undo.
define input        parameter bf-handle       as   handle                  no-undo.
define input        parameter parstat         as   character               no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Обработка приходной накладной (заведение, редактирование)":U .
define temp-table old-doc-line no-undo like ub.doc-line.
define buffer doc-line for ub.doc-line  .
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
      p-vss-parameters = substitute('&1|&2':u,parext-doc-type,paris-hold)
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
define variable trn-type as integer no-undo init 0.
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
define new global shared variable g#libbcrcn as handle no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define new shared temp-table sup-gds no-undo
    field artic          like ub.goods.artic
    field prod-type      like ub.clients.obj-type
    field prod-code      like ub.clients.obj-code
    field gds-name       like ub.goods.gds-name
    field unit-base      like ub.goods.unit-base
    field s-pay-type     as character
    field in-qnty        like ub.parts.fact-qnty
    field in-nds0-rubl   like ub.parts.price-rubl
    field in-nds0-base   like ub.parts.price-base
    field in-sum0-rubl   like ub.parts.price-rubl
    field in-sum0-base   like ub.parts.price-base
    field in-nds-rubl    like ub.parts.price-rubl
    field in-nds-base    like ub.parts.price-base
    field in-sum-rubl    like ub.parts.price-rubl
    field in-sum-base    like ub.parts.price-base
    field out-qnty       like ub.parts.fact-qnty
    field out-nds0-rubl  like ub.parts.price-rubl
    field out-nds0-base  like ub.parts.price-base
    field out-sum0-rubl  like ub.parts.price-rubl
    field out-sum0-base  like ub.parts.price-base
    field out-nds-rubl   like ub.parts.price-rubl
    field out-nds-base   like ub.parts.price-base
    field out-sum-rubl   like ub.parts.price-rubl
    field out-sum-base   like ub.parts.price-base
    field free-qnty      like ub.parts.fact-qnty
    field free-nds0-rubl like ub.parts.price-rubl
    field free-nds0-base like ub.parts.price-base
    field free-sum0-rubl like ub.parts.price-rubl
    field free-sum0-base like ub.parts.price-base
    field free-nds-rubl  like ub.parts.price-rubl
    field free-nds-base  like ub.parts.price-base
    field free-sum-rubl  like ub.parts.price-rubl
    field free-sum-base  like ub.parts.price-base
    field price-sale     as decimal
    field qnty-sale      as integer
    field fs-date        as date
    field ls-date        as date
    index art is primary artic prod-type prod-code s-pay-type ascending
    .
define new shared buffer suppl-gds for sup-gds.
define new shared temp-table sup-parts no-undo
    field artic             like ub.goods.artic
    field prod-type         like ub.clients.obj-type
    field prod-code         like ub.clients.obj-code
    field gds-code          like ub.goods.gds-code
    field gds-name          like ub.goods.gds-name
    field doc-type          like ub.parts.doc-type
    field in-code           like ub.parts.in-code
    field out-code          like ub.parts.out-code
    field fact-date         like ub.parts.fact-date
    field price-cli         like ub.parts.price-cli
    field price0-base       like ub.parts.price-base
    field price0-rubl       like ub.parts.price-rubl
    field price-base        like ub.parts.price-base
    field price-rubl        like ub.parts.price-rubl
    field obj-type          like ub.parts.obj-type
    field obj-code          like ub.parts.obj-code
    field part-code         like ub.parts.part-code
    field in-qnty           like ub.parts.fact-qnty
    field in-sum-cli        like ub.parts.price-cli
    field in-nds0-rubl      like ub.parts.price-rubl
    field in-nds0-base      like ub.parts.price-base
    field in-sum0-rubl      like ub.parts.price-rubl
    field in-sum0-base      like ub.parts.price-base
    field in-nds-rubl       like ub.parts.price-rubl
    field in-nds-base       like ub.parts.price-base
    field in-sum-rubl       like ub.parts.price-rubl
    field in-sum-base       like ub.parts.price-base
    field out-qnty          like ub.parts.fact-qnty
    field out-sum-cli       like ub.parts.price-cli
    field out-nds0-rubl     like ub.parts.price-rubl
    field out-nds0-base     like ub.parts.price-base
    field out-sum0-rubl     like ub.parts.price-rubl
    field out-sum0-base     like ub.parts.price-base
    field out-nds-rubl      like ub.parts.price-rubl
    field out-nds-base      like ub.parts.price-base
    field out-sum-rubl      like ub.parts.price-rubl
    field out-sum-base      like ub.parts.price-base
    field free-qnty         like ub.parts.fact-qnty
    field free-sum-cli      like ub.parts.price-cli
    field free-nds0-rubl    like ub.parts.price-rubl
    field free-nds0-base    like ub.parts.price-base
    field free-sum0-rubl    like ub.parts.price-rubl
    field free-sum0-base    like ub.parts.price-base
    field free-nds-rubl     like ub.parts.price-rubl
    field free-nds-base     like ub.parts.price-base
    field free-sum-rubl     like ub.parts.price-rubl
    field free-sum-base     like ub.parts.price-base
    field p-in-qnty         like ub.parts.fact-qnty
    field p-in-sum-cli      like ub.parts.price-cli
    field p-in-nds0-rubl    like ub.parts.price-rubl
    field p-in-nds0-base    like ub.parts.price-base
    field p-in-sum0-rubl    like ub.parts.price-rubl
    field p-in-sum0-base    like ub.parts.price-base
    field p-in-nds-rubl     like ub.parts.price-rubl
    field p-in-nds-base     like ub.parts.price-base
    field p-in-sum-rubl     like ub.parts.price-rubl
    field p-in-sum-base     like ub.parts.price-base
    field qnty-sale         as integer
    field fs-date           as date
    field ls-date           as date
    field num-doc           as character
    index f-date is primary fact-date ascending
    .
define new shared buffer suppl-parts for sup-parts.
define new shared buffer supplier    for ub.clients.
define new shared buffer b-parts     for ub.parts.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prescan:
define input parameter parrec-doc as recid no-undo.
define buffer ps_trn-doc  for ub.trn-doc.
define buffer ps_doc-line for ub.doc-line.
define buffer ps_gds-dtl  for ub.gds-dtl.
define buffer ps_parts    for ub.parts.
define variable to-null as logical no-undo.
define variable g-log   as logical no-undo.
do on error undo, return error return-value :
find first ps_trn-doc where recid (ps_trn-doc) = parrec-doc.
if (ps_trn-doc.doc-type = 'при':U and
    ps_trn-doc.status_  = 'накл':U   and
    ps_trn-doc.flag_)                     or
   (can-do ('рас,спи,возврат':U, ps_trn-doc.doc-type) and
    ps_trn-doc.status_ = 'разрешен':U                            ) then do:
  if can-find (first ps_doc-line where ps_doc-line.doc-code   = ps_trn-doc.doc-code and
                                       ps_doc-line.fact-qnty <> 0 no-lock)          then do:
    assign
      to-null = yes.
  end.
  else do:
    assign
      to-null = no.
  end.
  assign
    g-log = no.
  if to-null then do:
    message "Для приемки товара с использованием мобильного сканера"
            "фактические количества товара в документе должны быть обнулены." skip
            "При повторном использовании сканера для того же документа обнуление не требуется." skip (2)
            "Обнулить ФАКТ количества в документе ?"
    view-as alert-box question buttons yes-no update g-log.
  end.
  else do:
    message "В документе все ФАКТ количества нулевые."
             "Сделать их равными количествам товара по документу ?"
    view-as alert-box question buttons yes-no update g-log.
  end.
  if g-log then do:
    for each ps_doc-line where ps_doc-line.doc-code = ps_trn-doc.doc-code on error undo, return error return-value :
      assign
        ps_doc-line.fact-qnty = (if to-null then 0 else ps_doc-line.doc-qnty).
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_lnfactqt in g#lib-calc
(
 input parparentproc
,input recid(ps_doc-line)
,input no
,input ps_trn-doc.status_
,input ps_trn-doc.flag_       )
no-error.
      if error-status:error then do:
        undo, return error substitute("Ошибка при изменении &1 фактического количества по товару: &2 &3 &4 ",
                                      return-value,
                                      ps_doc-line.artic,
                                      ps_doc-line.prod-type,
                                      ps_doc-line.prod-code).
      end.
    end.
    for each ps_gds-dtl where ps_gds-dtl.doc-code = ps_trn-doc.doc-code:
      assign
        ps_gds-dtl.fact-qnty  = (if to-null then 0 else ps_gds-dtl.doc-qnty).
    end.
    for each ps_parts where ps_parts.out-code = ps_trn-doc.doc-code:
      assign
        ps_parts.fact-qnty = if to-null then 0 else ps_parts.qnty.
    end.
  end.
end.
end.
end procedure.
procedure renum :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
define variable varline-num as integer no-undo.
define query q-doc-line for bf_doc-line.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute("Не найден документ с номером &1", pardoc-code).
end.
open query q-doc-line preselect each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code use-index line-num exclusive-lock.
get first q-doc-line.
assign varline-num = 0.
do while available(bf_doc-line):
   assign varline-num = varline-num + 1.
   assign
     bf_doc-line.line-num = varline-num.
   get next q-doc-line.
end.
end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-bar-code-ne no-undo
field nm            as integer
field mark          as character
field b-c           as integer
field scn-qnty-doc  as decimal
field scn-qnty-file as decimal
field mem-qnty      as decimal
field bef-qnty      as decimal
field artic         like ub.goods.artic
field prod-type     like ub.goods.prod-type
field prod-code     like ub.goods.prod-code
field gds-name      like ub.goods.gds-name
field node-name     like ub.gds-prt.node-name
field part-code     like ub.bar-code.part-code
field in-code       like ub.bar-code.in-code
index pi is primary nm
index b-c is unique b-c.
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-upd-attr no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define temp-table tt-upd-attr-fuel no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define new global shared variable g#lib-rvs as handle no-undo.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
    define temp-table tt-place-sec
      field loc1    as character
      field secs    as character
      field own-rvs as logical
      field pl-code as integer
      index pi as primary unique
        loc1
    .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    PROCEDURE cr-rvs-doc :
      define input  parameter parparentproc as   handle              no-undo .
      define input  parameter p-doc-code    like ub.trn-doc.doc-code no-undo .
      tr:
      do transaction
      on error  undo, return error substitute( "&1 (cr-rvs-doc). &2&3&4", vss-include-info26, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1 (cr-rvs-doc). stop", vss-include-info26 )
      on endkey undo, return error substitute( "&1 (cr-rvs-doc). endkey", vss-include-info26 )
      :
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        define buffer buf_trn-doc    for ub.trn-doc .
        define buffer buf_doc-line   for ub.doc-line .
        define buffer buf_doc-line-attr for ub.doc-line-attr .
        define buffer buf_goods      for ub.goods .
        define buffer buf_place      for ub.place .
        define buffer buf_rvs-doc    for ub.rvs-doc .
        define buffer buf_rvs-line   for ub.rvs-line .
        define buffer cur_shift-obj  for ub.shift-obj.
        define buffer prev_shift-obj for ub.shift-obj.
        define buffer prev_rvs-doc   for ub.rvs-doc.
        define buffer prev_icnt-doc  for ub.icnt-doc.
        define buffer buf_doc-pl     for ub.doc-pl.
        define buffer sep_auto-tank-attr  for ub.auto-tank-attr.
        define variable is-petrolium       as logical   no-undo .
        define variable is-pieces          as logical   no-undo .
        define variable v-ptrl-without-rvs as character no-undo .
        define variable v-attr-type        as character no-undo .
        define variable v-ptrl-avail       as logical   no-undo .
        define variable v-doc-pl-avail     as logical   no-undo .
        define variable v-today            as date      no-undo .
        define variable v-value            as character no-undo .
        define variable v-ok               as logical   no-undo .
        define variable ii                 as integer   no-undo .
        define variable v-kpsecs           as character no-undo .
        define variable v-need-rvs-sec     as character no-undo .
        define variable v-rvs-code         as character no-undo .
        define variable v-no-need-main-rvs as logical   no-undo .
        define variable choice             as integer   no-undo .
        define variable varcar-num         as character no-undo .
        define variable vartype            as character no-undo .
        define variable varlog             as logical   no-undo .
        define variable infoSectionsTotal as class ibs.th.str.InfoSectionsTotal no-undo .
        define variable infoSecObj        as class ibs.th.str.InfoSection no-undo .
        v-kpsecs = "" .
        v-need-rvs-sec = "" .
        find first buf_trn-doc
          where buf_trn-doc.doc-code = p-doc-code
          .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'car-num':U ,
                       output varcar-num ,
                       output vartype )  .
        if trn-type = 1
        then do :
          find first sep_auto-tank-attr no-lock where sep_auto-tank-attr.auto-num = varcar-num
                                                  and sep_auto-tank-attr.attr-code = "auto-sep"
                                                  no-error.
          if available sep_auto-tank-attr
          and logical(sep_auto-tank-attr.attr-value)
          then do :
          end .
          else do :
            secs_ :
            for each buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
                                                 and buf_doc-line-attr.attr-code = "n",
            first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code
            :
              infoSectionsTotal = new ibs.th.str.InfoSectionsTotal().
              infoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_doc-line-attr.gds-code).
              infoSectionsTotal:GetDBAllAttr().
              do ii = 1 to infoSectionsTotal:SectionNum :
                infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
                if not infoSecObj:KPnoMeas
                and (not (infoSecObj:TankWeight > 0)
                or infoSecObj:TankWeight = ?
                or infoSecObj:TankDensity = ?)
                then do :
                  delete object infoSectionsTotal.
                  message
                    "Перед созданием документов сверки по накладной необходимо заполнить всю дополнительную информацию по приемке топлива!"
                  view-as alert-box .
                  return .
                end .
              end .
              delete object infoSectionsTotal.
            end .
          end .
          v-kpsecs = "" .
          v-need-rvs-sec = "" .
          v-no-need-main-rvs = no .
          empty temp-table tt-place-sec .
          kpsecs_ :
          for each buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
                                               and buf_doc-line-attr.attr-code = "n",
          first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code
          :
            infoSectionsTotal = new ibs.th.str.InfoSectionsTotal().
            infoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_doc-line-attr.gds-code).
            infoSectionsTotal:GetDBAllAttr().
            do ii = 1 to infoSectionsTotal:SectionNum :
              infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
              find first tt-place-sec where tt-place-sec.loc1 = infoSecObj:ListTank no-error .
              if not available tt-place-sec
              then do :
                create tt-place-sec .
                assign
                  tt-place-sec.loc1 = infoSecObj:ListTank
                  tt-place-sec.secs = infoSecObj:SectionName
                  tt-place-sec.own-rvs = no
                .
                for first buf_place no-lock where buf_place.obj-type = buf_trn-doc.obj-type
                                              and buf_place.obj-code = buf_trn-doc.obj-code
                                              and buf_place.loc1     = tt-place-sec.loc1
                                              and buf_place.status_  = ""
                :
                  assign tt-place-sec.pl-code = buf_place.pl-code .
                end .
              end .
              else do :
                assign
                  tt-place-sec.secs = tt-place-sec.secs + "," + infoSecObj:SectionName
                .
              end .
              if infoSecObj:isKP
              then do :
                v-kpsecs = v-kpsecs + infoSecObj:SectionName + " с " + buf_goods.gds-name + ", " .
              end .
            end .
            delete object infoSectionsTotal.
          end .
          v-kpsecs = trim(v-kpsecs, ", ") .
        end .
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_cr-revision':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    ) no-error .
end.
        if varlog <> yes then do:
          return error return-value .
        end.
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
          no-error.
        if available buf_rvs-doc then do:
          message "Прототипы документов сверки уже созданы." skip
                  "Можно задавать кол-ва по приборам."       skip
          view-as alert-box error.
          return error.
        end.
        find first cur_shift-obj
          where cur_shift-obj.obj-type = buf_trn-doc.obj-type
            and cur_shift-obj.obj-code = buf_trn-doc.obj-code
            and cur_shift-obj.status_  = 'тек':U
            use-index pi no-lock no-error .
        if not available cur_shift-obj then do:
          message "Нет открытой смены на объекте " buf_trn-doc.obj-type
                                                  buf_trn-doc.obj-code
          view-as alert-box error.
          return error.
        end.
        find last prev_shift-obj no-lock
          where prev_shift-obj.obj-type = cur_shift-obj.obj-type
            and prev_shift-obj.obj-code = cur_shift-obj.obj-code
            and prev_shift-obj.status_  = 'зкр':U
            and ( prev_shift-obj.shift-date < cur_shift-obj.shift-date
                  or prev_shift-obj.shift-date = cur_shift-obj.shift-date
                    and prev_shift-obj.shift-num  < cur_shift-obj.shift-num
                )
          use-index stts
          no-error.
        if available prev_shift-obj then do:
          find first prev_rvs-doc no-lock
            where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
              and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
              and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
              and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
              and prev_rvs-doc.status_    = 'факт':U
              and prev_rvs-doc.rvs-type   = 'смена':U
            no-error.
          if not available prev_rvs-doc then do:
              assign varlog = no.
              message "Объект " buf_trn-doc.obj-type " " buf_trn-doc.obj-code " ." skip
                      "Текущая смена " cur_shift-obj.shift-date " " cur_shift-obj.shift-num " ." skip
                      "Прошлая смена " prev_shift-obj.shift-date " " prev_shift-obj.shift-num " ." skip
                      "Нет сверки типа " 'смена':U " за прошлую смену." skip
                      "Торговли топливом не было. Продолжить?"
              view-as alert-box question buttons yes-no update varlog .
              if varlog <> yes then return error.
          end.
        end.
        if v-kpsecs > ""
        then do :
          kpsecs_ :
          for each buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
                                               and buf_doc-line-attr.attr-code = "n"
          :
            infoSectionsTotal = new ibs.th.str.InfoSectionsTotal().
            infoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_doc-line-attr.gds-code).
            infoSectionsTotal:GetDBAllAttr().
            do ii = 1 to infoSectionsTotal:SectionNum :
              infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
              if infoSecObj:isKP
              then do :
                for first tt-place-sec where tt-place-sec.loc1 = infoSecObj:ListTank
                                         and not tt-place-sec.own-rvs :
                  if num-entries(tt-place-sec.secs) >= 1
                  then do :
                    tt-place-sec.own-rvs = yes .
                    v-need-rvs-sec = v-need-rvs-sec + tt-place-sec.secs + "," .
                  end .
                end .
              end .
            end .
            delete object infoSectionsTotal.
          end .
        end .
        v-need-rvs-sec = trim(v-need-rvs-sec, ",") .
        find last prev_icnt-doc no-lock
          where prev_icnt-doc.obj-type = buf_trn-doc.obj-type
            and prev_icnt-doc.obj-code = buf_trn-doc.obj-code
            and prev_icnt-doc.doc-type = 'инв-сч-трк':U
            and prev_icnt-doc.status_  = 'факт':U
          use-index fact-order
          no-error.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-today
  )  .
        find first tt-place-sec where tt-place-sec.own-rvs = no no-error .
        run doc-code in this-procedure
          ( input "main":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input ?
          ,output v-rvs-code
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при генерации номера документа."
            view-as alert-box error.
          return error.
        end.
        if v-need-rvs-sec = ""
        or available tt-place-sec
        then do :
          create buf_rvs-doc.
          assign
            buf_rvs-doc.rvs-code  = v-rvs-code
            buf_rvs-doc.host-code = buf_trn-doc.host-code
            buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
            buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
            buf_rvs-doc.status_   = 'новый':U
            buf_rvs-doc.rvs-type  = 'перед_док':U
            buf_rvs-doc.out-code  = buf_trn-doc.doc-code
            buf_rvs-doc.creid     = v-cntxt-userid
            buf_rvs-doc.PS        = "@"
            buf_rvs-doc.is-full   = no
            buf_rvs-doc.doc-date  = v-today
          .
          find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error.
          if available (ub.user-account) and not (ub.user-account.psn-code = ? or ub.user-account.psn-code = 0)
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
            buf_rvs-doc.boss = ub.user-account.psn-code.
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          run gbl/factdate.p
            ( input        buf_rvs-doc.obj-type
            ,input        buf_rvs-doc.obj-code
            ,input-output buf_rvs-doc.fact-date
            ,input-output buf_rvs-doc.fact-time
            ,input-output buf_rvs-doc.shift-date
            ,input-output buf_rvs-doc.shift-num
            ,input-output buf_rvs-doc.shift-name
            ,input        yes
            ) no-error.
          if error-status :error then do:
            message
              "Ошибка при установке даты в документе " 'перед_док':U skip
              view-as alert-box error.
            undo tr, return error.
          end.
        end .
        do ii = 1 to num-entries(v-need-rvs-sec) :
          create buf_rvs-doc.
          assign
            buf_rvs-doc.rvs-code  = replace(v-rvs-code, "-", "-" + entry(ii, v-need-rvs-sec) + "-")
            buf_rvs-doc.host-code = buf_trn-doc.host-code
            buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
            buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
            buf_rvs-doc.status_   = 'новый':U
            buf_rvs-doc.rvs-type  = 'перед_док':U
            buf_rvs-doc.out-code  = buf_trn-doc.doc-code
            buf_rvs-doc.creid     = v-cntxt-userid
            buf_rvs-doc.PS        = "@"
            buf_rvs-doc.is-full   = no
            buf_rvs-doc.doc-date  = v-today
          .
          find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error.
          if available (ub.user-account) and not (ub.user-account.psn-code = ? or ub.user-account.psn-code = 0)
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
            buf_rvs-doc.boss = ub.user-account.psn-code.
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          run gbl/factdate.p
            ( input        buf_rvs-doc.obj-type
            ,input        buf_rvs-doc.obj-code
            ,input-output buf_rvs-doc.fact-date
            ,input-output buf_rvs-doc.fact-time
            ,input-output buf_rvs-doc.shift-date
            ,input-output buf_rvs-doc.shift-num
            ,input-output buf_rvs-doc.shift-name
            ,input        yes
            ) no-error.
          if error-status :error then do:
            message
              "Ошибка при установке даты в документе " 'перед_док':U skip
              view-as alert-box error.
            undo tr, return error.
          end.
        end .
        run doc-code in this-procedure
          ( input "main":U
            ,input buf_trn-doc.obj-type
            ,input buf_trn-doc.obj-code
            ,input ?
            ,output v-rvs-code
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при генерации номера документа."
            view-as alert-box error.
          return error.
        end.
        if v-need-rvs-sec = ""
        or available tt-place-sec
        then do :
          create buf_rvs-doc.
          assign
            buf_rvs-doc.rvs-code  = v-rvs-code
            buf_rvs-doc.host-code = buf_trn-doc.host-code
            buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
            buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
            buf_rvs-doc.status_   = 'новый':U
            buf_rvs-doc.rvs-type  = 'после_док':U
            buf_rvs-doc.out-code  = buf_trn-doc.doc-code
            buf_rvs-doc.creid     = v-cntxt-userid
            buf_rvs-doc.PS        = "@"
            buf_rvs-doc.is-full   = no
            buf_rvs-doc.doc-date  = v-today
          .
          find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error.
          if available (ub.user-account) and not (ub.user-account.psn-code = ? or ub.user-account.psn-code = 0)
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
            buf_rvs-doc.boss = ub.user-account.psn-code.
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          run gbl/factdate.p
            ( input        buf_rvs-doc.obj-type
              ,input        buf_rvs-doc.obj-code
              ,input-output buf_rvs-doc.fact-date
              ,input-output buf_rvs-doc.fact-time
              ,input-output buf_rvs-doc.shift-date
              ,input-output buf_rvs-doc.shift-num
              ,input-output buf_rvs-doc.shift-name
              ,input        yes
            ) no-error.
          if error-status :error then do:
            message
              "Ошибка при установке даты в документе " 'после_док':U skip
              view-as alert-box error.
            undo tr, return error.
          end.
        end .
        do ii = 1 to num-entries(v-need-rvs-sec) :
          create buf_rvs-doc.
          assign
            buf_rvs-doc.rvs-code  = replace(v-rvs-code, "-", "-" + entry(ii, v-need-rvs-sec) + "-")
            buf_rvs-doc.host-code = buf_trn-doc.host-code
            buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
            buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
            buf_rvs-doc.status_   = 'новый':U
            buf_rvs-doc.rvs-type  = 'после_док':U
            buf_rvs-doc.out-code  = buf_trn-doc.doc-code
            buf_rvs-doc.creid     = v-cntxt-userid
            buf_rvs-doc.PS        = "@"
            buf_rvs-doc.is-full   = no
            buf_rvs-doc.doc-date  = v-today
          .
          find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error.
          if available (ub.user-account) and not (ub.user-account.psn-code = ? or ub.user-account.psn-code = 0)
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
            buf_rvs-doc.boss = ub.user-account.psn-code.
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          run gbl/factdate.p
            ( input        buf_rvs-doc.obj-type
            ,input        buf_rvs-doc.obj-code
            ,input-output buf_rvs-doc.fact-date
            ,input-output buf_rvs-doc.fact-time
            ,input-output buf_rvs-doc.shift-date
            ,input-output buf_rvs-doc.shift-num
            ,input-output buf_rvs-doc.shift-name
            ,input        yes
            ) no-error.
          if error-status :error then do:
            message
              "Ошибка при установке даты в документе " 'перед_док':U skip
              view-as alert-box error.
            undo tr, return error.
          end.
        end .
        assign
          v-ptrl-avail = false
        .
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        ,first buf_goods no-lock
          where buf_goods.artic     = buf_doc-line.artic
            and buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code
        on error undo tr, return error return-value
        :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
          if error-status :error then do:
              message "Ошибка при вызове программы lib-trn_is-petrl." view-as alert-box .
              undo tr, return error .
          end.
          run gds-attr-value in this-procedure
            ( input  buf_goods.gds-code
             ,input  'ptrl-without-rvs':U
             ,output v-ptrl-without-rvs
             ,output v-attr-type
            ) .
          if is-petrolium = true
            and is-pieces = false
            and lookup(v-ptrl-without-rvs, 'true,yes':u) = 0
          then do:
            assign
              v-ptrl-avail   = true
              v-doc-pl-avail = false
            .
            for each buf_doc-pl no-lock
              where buf_doc-pl.obj-type = buf_doc-line.obj-type
                and buf_doc-pl.obj-code = buf_doc-line.obj-code
                and buf_doc-pl.out-code = buf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code
            on error undo tr, return error return-value
            :
              rvs-doc_ :
              for each buf_rvs-doc
                where buf_rvs-doc.out-code = buf_trn-doc.doc-code
              on error undo tr, return error return-value
              :
                if v-need-rvs-sec > ""
                then do :
                  for each tt-place-sec where tt-place-sec.pl-code = buf_doc-pl.pl-code
                  :
                    if (tt-place-sec.own-rvs and num-entries(buf_rvs-doc.rvs-code, "-") = 3 and lookup(entry(2, buf_rvs-doc.rvs-code, "-"), tt-place-sec.secs) > 0)
                    or (not tt-place-sec.own-rvs and num-entries(buf_rvs-doc.rvs-code, "-") = 2)
                    then do :
                      assign
                        v-doc-pl-avail = true
                      .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crrvslin in g#lib-rvs ( input buf_rvs-doc.obj-type ,
                      input buf_rvs-doc.obj-code ,
                      input buf_rvs-doc.rvs-code ,
                      input buf_rvs-doc.rvs-type ,
                      input buf_doc-pl.pl-code ,
                      input buf_doc-pl.gds-code ,
                      input ( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? ) ,
                      input buf_rvs-doc.shift-date ,
                      input buf_rvs-doc.shift-num )  .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crrvslnp in g#lib-rvs ( input  buf_rvs-doc.obj-type ,
                      input  buf_rvs-doc.obj-code ,
                      input  buf_rvs-doc.rvs-code ,
                      input  buf_rvs-doc.rvs-type ,
                      input  buf_doc-pl.pl-code ,
                      input  buf_doc-pl.gds-code ,
                      input  yes ,
                      input  ( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? ) ,
                      input  buf_rvs-doc.shift-date ,
                      input buf_rvs-doc.shift-num ,
                      input ( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? ) ,
                      input yes )  .
                    end .
                  end .
                end .
                else do :
                  assign
                    v-doc-pl-avail = true
                  .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crrvslin in g#lib-rvs ( input buf_rvs-doc.obj-type ,
                      input buf_rvs-doc.obj-code ,
                      input buf_rvs-doc.rvs-code ,
                      input buf_rvs-doc.rvs-type ,
                      input buf_doc-pl.pl-code ,
                      input buf_doc-pl.gds-code ,
                      input ( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? ) ,
                      input buf_rvs-doc.shift-date ,
                      input buf_rvs-doc.shift-num )  .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crrvslnp in g#lib-rvs ( input  buf_rvs-doc.obj-type ,
                      input  buf_rvs-doc.obj-code ,
                      input  buf_rvs-doc.rvs-code ,
                      input  buf_rvs-doc.rvs-type ,
                      input  buf_doc-pl.pl-code ,
                      input  buf_doc-pl.gds-code ,
                      input  yes ,
                      input  ( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? ) ,
                      input  buf_rvs-doc.shift-date ,
                      input buf_rvs-doc.shift-num ,
                      input ( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? ) ,
                      input yes )  .
                end .
              end.
              run placelib_get-attr  (
                 input "place-com-tanks"
                ,input buf_doc-pl.obj-code
                ,input buf_doc-pl.obj-type
                ,input buf_doc-pl.pl-code
                ,output v-value
                ,output v-ok      )
              no-error.
              if v-ok
              and v-value > ""
              then do ii = 1 to num-entries(v-value) :
                find first buf_place no-lock where buf_place.obj-type = buf_doc-pl.obj-type
                                               and buf_place.obj-code = buf_doc-pl.obj-code
                                               and buf_place.loc1     = entry(ii, v-value)
                                               and buf_place.status_  = ""
                                               no-error .
                if available buf_place
                then do :
                  for each buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_trn-doc.doc-code,
                     first buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                                  and buf_rvs-line.gds-code = buf_doc-pl.gds-code
                                                  and buf_rvs-line.pl-code <> buf_place.pl-code
                  on error undo tr, return error return-value
                  :
                    assign
                      v-doc-pl-avail = true
                    .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crrvslin in g#lib-rvs ( input buf_rvs-doc.obj-type ,
                      input buf_rvs-doc.obj-code ,
                      input buf_rvs-doc.rvs-code ,
                      input buf_rvs-doc.rvs-type ,
                      input buf_place.pl-code ,
                      input buf_doc-pl.gds-code ,
                      input ( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? ) ,
                      input buf_rvs-doc.shift-date ,
                      input buf_rvs-doc.shift-num )  .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crrvslnp in g#lib-rvs ( input  buf_rvs-doc.obj-type ,
                      input  buf_rvs-doc.obj-code ,
                      input  buf_rvs-doc.rvs-code ,
                      input  buf_rvs-doc.rvs-type ,
                      input  buf_place.pl-code ,
                      input  buf_doc-pl.gds-code ,
                      input  yes ,
                      input  ( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? ) ,
                      input  buf_rvs-doc.shift-date ,
                      input buf_rvs-doc.shift-num ,
                      input ( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? ) ,
                      input yes )  .
                  end.
                end .
              end .
            end.
            if v-doc-pl-avail = false then do:
              message
                substitute( 'В документе "&1" товар "&2" не распределен по местам хранения.', buf_doc-line.doc-code, buf_goods.gds-code ) skip
                "Сверки не созданны!"
                view-as alert-box information.
              undo tr, leave tr.
            end.
          end.
        end.
        if v-ptrl-avail <> true then do:
          message
            "В документе нет ни одного топливного товара требующего создание сверки."  skip
            "Сверки не созданны!"
            view-as alert-box information.
          undo tr, leave tr.
        end.
        for each buf_rvs-doc
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = 'перед_док':U
        :
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(buf_rvs-doc)
            ,input "close":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при закрытии документа сверки "&1" номер &2', 'перед_док':U, buf_rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(buf_rvs-doc)
            ,input "froze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', 'перед_док':U, buf_rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end .
        for each buf_rvs-doc
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = 'после_док':U
        :
          run str/rvs-stat.p
            ( input parparentproc
              ,input recid(buf_rvs-doc)
              ,input "close":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при закрытии документа сверки "&1" номер &2', 'после_док':U, buf_rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(buf_rvs-doc)
            ,input "froze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', 'после_док':U, buf_rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end .
      end.
      return .
    END PROCEDURE.
    PROCEDURE del-rvs-doc :
      define input  parameter parparentproc as   handle              no-undo .
      define input  parameter p-doc-code    like ub.trn-doc.doc-code no-undo .
      tr:
      do transaction
      on error   undo tr, return error
      on end-key undo tr, return error
      on stop    undo tr, return error
      :
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        define buffer buf_trn-doc for ub.trn-doc .
        define buffer bef-rvs-doc for ub.rvs-doc.
        define buffer aft-rvs-doc for ub.rvs-doc.
        define buffer buf_doc-line-attr for ub.doc-line-attr .
        define variable varlog           as logical   no-undo .
        define variable ii               as integer   no-undo .
        define variable infoSectionsTotal as class ibs.th.str.InfoSectionsTotal no-undo .
        define variable infoSectionObj as class ibs.th.str.InfoSection no-undo .
        find first buf_trn-doc
          where buf_trn-doc.doc-code = p-doc-code
          .
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_deletion':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    ) no-error .
end.
        if varlog <> yes then do:
          return error return-value .
        end.
        assign
          varlog = no
          .
        message
          "Вы хотите удалить документы сверки по приходу?"
          view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          return .
        end.
        run waitfram-show in this-procedure (input "Удаляем документы сверки по приходной накладной").
        for each buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
                                             and buf_doc-line-attr.attr-code = "n"
        :
          infoSectionsTotal = new ibs.th.str.InfoSectionsTotal().
          infoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_doc-line-attr.gds-code).
          infoSectionsTotal:GetDBAllAttr().
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionObj = infoSectionsTotal:GetInfoSectionProp(ii) .
            if infoSectionObj:AccMeth = 0
            then do :
              infoSectionObj:TankDensityPomi = ? .
              infoSectionObj:TankVolPomi = ? .
              infoSectionObj:TankWeight = ? .
              infoSectionObj:AccPomi = ? .
            end .
            if infoSectionObj:AccMeth = 1
            then do :
              infoSectionObj:TankVolPomiRvs = ? .
              infoSectionObj:TankWeightRvs = ? .
            end .
            infoSectionObj:AccMeth = ? .
            infoSectionObj:DateStart = ? .
            infoSectionObj:TimeStart = ? .
            infoSectionObj:DateEnd = ? .
            infoSectionObj:TimeEnd = ? .
            if not (infoSectionObj:KPnoMeas or infoSectionObj:alarm-SGDKK) then infoSectionObj:IsKP = no .
          end .
          infoSectionsTotal:SaveDB().
          delete object infoSectionsTotal.
        end .
        for each bef-rvs-doc
          where bef-rvs-doc.out-code = buf_trn-doc.doc-code
            and bef-rvs-doc.rvs-type = 'перед_док':U
        :
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(bef-rvs-doc)
            ,input "unfroze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', 'перед_док':U, bef-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(bef-rvs-doc)
            ,input "open":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', 'перед_док':U, bef-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          release bef-rvs-doc no-error .
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', 'перед_док':U, bef-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end.
        for each bef-rvs-doc
            where bef-rvs-doc.out-code = buf_trn-doc.doc-code
              and bef-rvs-doc.rvs-type = 'перед_док':U
        :
          delete bef-rvs-doc no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при удалении документа сверки "&1"', 'перед_док':U ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end .
        for each aft-rvs-doc
          where aft-rvs-doc.out-code = buf_trn-doc.doc-code
            and aft-rvs-doc.rvs-type = 'после_док':U
        :
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(aft-rvs-doc)
            ,input "unfroze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', 'после_док':U, aft-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(aft-rvs-doc)
            ,input "open":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', 'после_док':U, aft-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          release aft-rvs-doc no-error .
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', 'после_док':U, aft-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end.
        for each aft-rvs-doc
            where aft-rvs-doc.out-code = buf_trn-doc.doc-code
              and aft-rvs-doc.rvs-type = 'после_док':U
        :
          delete aft-rvs-doc no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при удалении документа сверки "&1"', 'после_док':U ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end .
      end.
      run waitfram-hide in this-procedure .
      return .
    END PROCEDURE.
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-gl-UVEDOMLENIE as CHARACTER NO-UNDO INITIAL "Uvedomlenie":U.
FUNCTION Get-Contract-Attr RETURN CHARACTER(
         INPUT iHost-Code AS INTEGER,
         INPUT iContract-Code  AS INTEGER,
         INPUT cAttr-code      AS CHARACTER):
   DEFINE BUFFER buf_Contract-Attr FOR ub.Contract-Attr.
   FIND FIRST buf_Contract-Attr WHERE
              buf_Contract-Attr.Host-code     = iHost-Code
          AND buf_Contract-Attr.Contract-code = iContract-Code
          AND buf_Contract-Attr.Attr-code     = cAttr-code
        NO-LOCK NO-ERROR.
   RETURN (IF AVAILABLE buf_Contract-Attr THEN buf_Contract-Attr.Attr-value ELSE ?).
END FUNCTION.
PROCEDURE Modify-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FIND FIRST buf_Contract-Attr WHERE
                 buf_Contract-Attr.Host-Code      = iHost-Code
             AND buf_Contract-Attr.Contract-Code  = iContract-Code
             AND buf_Contract-Attr.Attr-code      = cAttr-code
           NO-LOCK NO-ERROR.
      IF NOT AVAILABLE buf_Contract-Attr THEN DO:
         CREATE buf_Contract-Attr NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END. ELSE DO:
         FIND CURRENT buf_Contract-Attr EXCLUSIVE-LOCK NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Create-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      CREATE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
FUNCTION Is-MS-Contract RETURN LOGICAL(BUFFER buf_Master FOR ub.Contract, BUFFER buf_Slave  FOR ub.Contract) FORWARD.
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract) FORWARD.
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract) FORWARD.
PROCEDURE Delete-Contract-Specif:
   DEFINE PARAMETER BUFFER buf_Contract FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Specif      FOR ub.Contract-Specif.
   DEFINE BUFFER buf_Specif-Attr FOR ub.Contract-Specif-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Specif-Attr WHERE
               buf_Specif-Attr.Host-code     = buf_Contract.Host-code
           AND buf_Specif-Attr.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif-Attr NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
      FOR EACH buf_Specif WHERE
               buf_Specif.Host-code     = buf_Contract.Host-code
           AND buf_Specif.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Modify-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          BUFFER-COPY
            buf_Master
          EXCEPT
            Host-code                               Contract-code                           Own-name                                an-uchet-code-out                       cel-nazn-code-out                       cor-acc-out                             cor-acc1-out                            an-uchet-code-in                        cel-nazn-code-in                        cor-acc-in                              cor-acc1-in                             an-uchet-code-out-cash                  cel-nazn-code-out-cash                  cor-acc-out-cash                        cor-acc1-out-cash                       an-uchet-code-in-cash                   cel-nazn-code-in-cash                   cor-acc-in-cash                         cor-acc1-in-cash                        an-uchet-code-out-payoff                cel-nazn-code-out-payoff                cor-acc-out-payoff                      cor-acc1-out-payoff                     an-uchet-code-in-payoff                 cel-nazn-code-in-payoff                 cor-acc-in-payoff                       cor-acc1-in-payoff                      transport-cli-type                      transport-cli-code                      transport-host                          transport-contract                      transport-uslov                         transport-value                         own-code-schet-start                    own-sign-post                           own-sign                                contract-city                           fin-VAT-pc                              srok-opl                                gen-factur-srok                         own-addres                              own-inn                                 own-kpp
          TO buf_Slave
          NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
          RELEASE buf_Slave NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Change-Stat-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE INPUT PARAMETER cStatus  AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          ASSIGN
             buf_Slave.Status_ = cStatus
             NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
          RELEASE buf_Slave NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Delete-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   IF NOT Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами нет связи Master->Slave".
      RETURN.
   END.
   Tran:
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
         AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
       EXCLUSIVE-LOCK
       TRANSACTION
       ON ENDKEY UNDO Tran, RETRY Tran
       ON ERROR  UNDO Tran, RETRY Tran
       ON QUIT   UNDO Tran, RETRY Tran
       ON STOP   UNDO Tran, RETRY Tran:
       IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
       DELETE buf_Ext-Classif NO-ERROR.
       IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Create-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE VARIABLE cKeyRec AS CHARACTER NO-UNDO INITIAL "".
   IF Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами  уже есть связь Master->Slave".
      RETURN.
   END.
   RUN gen-key-rec IN THIS-PROCEDURE(
       INPUT  v-S_CONTRACT,
       INPUT  BUFFER buf_Master:HANDLE,
       OUTPUT cKeyRec
       ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      cError = PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.
      RETURN.
   END.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      CREATE buf_Ext-Classif NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      ASSIGN
         buf_Ext-Classif.Classif-name    = v-S_CONTRACT
         buf_Ext-Classif.Classif-subject = v-S_CONTRACT
         buf_Ext-Classif.CharKey_One     = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         buf_Ext-Classif.CharKey_Two     = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         buf_Ext-Classif.DB-num          = buf_Master.Db-num
         buf_Ext-Classif.Uniq-key-rec    = cKeyRec
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Ext-Classif NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
FUNCTION Is-MS-Contract-Int-2 RETURN INTEGER (
                              i-Host-Code AS INTEGER,
                              i-Contract-Code AS INTEGER):
   DEFINE BUFFER buf_Contract FOR ub.Contract.
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   FIND FIRST buf_Contract WHERE
              buf_Contract.Host-Code      = i-Host-Code
          AND buf_Contract.Contract-code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Contract THEN DO:
      ASSIGN
         iRet = Is-MS-Contract-Int(BUFFER buf_Contract).
   END.
   RETURN (iRet).
END FUNCTION.
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          iRet = 1.
       LEAVE.
   END.
   IF iRet <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             iRet = 2.
          LEAVE.
      END.
   END.
   RETURN (iRet).
END FUNCTION.
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          cRet = "+".
       LEAVE.
   END.
   IF cRet = "" THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             cRet = (IF buf_Cont.Contract-prn-code = "" THEN  STRING(buf_Cont.Contract-code) ELSE buf_Cont.Contract-prn-code).
          LEAVE.
      END.
   END.
   RETURN (cRet).
END FUNCTION.
FUNCTION Is-MS-Contract RETURN LOGICAL(
         BUFFER buf_Master FOR ub.Contract,
         BUFFER buf_Slave  FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   RETURN CAN-FIND ( FIRST buf_Ext-Classif WHERE
                       buf_Ext-Classif.Classif-name = v-S_CONTRACT
                   AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
                   AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
                   AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
                 NO-LOCK).
END FUNCTION.
FUNCTION Get-Num-Slave-Contract RETURN CHARACTER(
         BUFFER buf_Master FOR ub.Contract,
         INPUT iSlave-Host-Code AS INTEGER
         ):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Contract    FOR ub.Contract.
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   FIND FIRST buf_Ext-Classif WHERE
              buf_Ext-Classif.Classif-name = v-S_CONTRACT
          AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
          AND buf_Ext-Classif.CharKey_Two  BEGINS STRING(iSlave-Host-Code) + v-DELIM_CHR_3
          AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Ext-Classif THEN DO:
      IF CAN-FIND (FIRST buf_Contract WHERE
                         buf_Contract.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                     AND buf_Contract.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                    NO-LOCK) THEN DO:
         ASSIGN
            cRet = ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3).
      END. ELSE DO:
         ASSIGN
            cRet = "ERROR:" + "Ошибка связи мастер договора " +
                   STRING(buf_Master.Host-Code) + "," + STRING(buf_Master.Contract-code) + " " +
                   "c Host-code=" + STRING(iSlave-Host-Code).
      END.
   END.
   RETURN (cRet).
END FUNCTION.
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
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define temp-table tt-utd like ub.utd
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .
define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id
  .
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer
    field doc-id  as integer
    field linenum as integer
    field bar-code as character
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.
define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical
  field isVarWeight as logical
  field isSelect    as logical
  field markType    as character
  field PieceTTH    as character
  field PieceFact   as character
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
define temp-table tt-mark-line like ub.marking-lines
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
define temp-table tt-marking like ub.marking
  .
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .
define temp-table tt-inv-marking no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .
define temp-table tt-tech-mark no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .
define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field type_         as character        label "Основание"   format "X(35)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.
define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field part-code     like ub.parts.part-code     label "Партия"
    field doc-code      as character                label "№ накладной TH"
    field doc-date      like ub.trn-doc.fact-date   label "Дата TH"
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-A      as character                label "Справка А"               format "X(20)"
    field A-qnty        as decimal                  label "Кол-во в справке"
    field A-bottleDate  as date                     label "Дата розлива"
    field A-ttnNumber   as character                label "№ ТТН справки А"         format "X(15)"
    field A-ttnDate     as date                     label "Дата"
    field A-fixNumber   as character                label "№ фиксации в ЕГАИС"      format "X(20)"
    field A-fixDate     as date                     label "Дата фикс."
    field inform-B      as character                label "Справка Б"               format "X(20)"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        position_
    index code
        gds-code doc-code
.
define new shared temp-table tt-marks
    field num                 as character            label "№ акта"
    field gds-part-position_  as integer
    field mark                as character            label "Марка"          format "X(100)"
    field new_                as logical
    field gds-code            like ub.goods.gds-code  LABEL "Код товара"
    field gds-name            as character            LABEL "Наименование"   FORMAT "X(30)"
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"
    field impor-full-name     as character            LABEL "Импортер"       FORMAT "X(130)"
    field prod-full-name      as character            LABEL "Производитель"  FORMAT "X(130)"
    field flag                as logical              label "T"
    field reserv              as integer              label "R"
    field parts               as character            label "Партия"         format "X(130)"
    index pi as primary unique
        mark
.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
def var vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info46 as character format "X(65)" no-undo
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
define variable varprice-cli                like ub.doc-line.price-rubl        no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl        no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl        no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl        no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl        no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl        no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl        no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl        no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl        no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl        no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl        no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl        no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl        no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl        no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl        no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl        no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl        no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl        no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl        no-undo.
define variable varprice-base               like ub.doc-line.price-base        no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base        no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base        no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base        no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base        no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base        no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base        no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base        no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base        no-undo.
define variable varprice-cli-temp           like ub.doc-line.price-cli         no-undo.
define variable varprice-base-temp          like ub.doc-line.price-base        no-undo.
define variable varprice-rubl-temp          like ub.doc-line.price-rubl        no-undo.
define variable ref-list                    as   character                     no-undo.
define variable conf-par                    as   character                     no-undo.
define variable custvalue                   as   character initial ?           no-undo.
define variable custtype                    as   character initial ?           no-undo.
define variable prtvalue                    as   character initial ?           no-undo.
define variable prttype                     as   character initial ?           no-undo.
define variable curclivalue                 as   character initial ?           no-undo.
define variable curclitype                  as   character initial ?           no-undo.
define variable inv-shipvalue               as   logical   initial ?           no-undo.
define variable bcvalue                     as   character initial ?           no-undo.
define variable bctype                      as   character initial ?           no-undo.
define variable multdtypvalue               as   character initial ?           no-undo.
define variable multdtyptype                as   character initial ?           no-undo.
define variable is-ovvalue                  as   character initial ?           no-undo.
define variable is-ovtype                   as   character initial ?           no-undo.
define variable rdtaxcdvalue                as   character initial ?           no-undo.
define variable vattaxcdvalue               as   character initial ?           no-undo.
define variable exctaxcdvalue               as   character initial ?           no-undo.
define variable varhold                     as   character initial ?           no-undo.
define variable varhold-type                as   character initial ?           no-undo.
define variable convimpvalue                as   character initial ?           no-undo.
define variable convimptype                 as   character initial ?           no-undo.
define variable temp-sale                   like ub.price-list.price-sale      no-undo.
define variable add-sens                    as   logical                       no-undo.
define variable ret-mode                    as   character                     no-undo.
define variable add-scan                    as   logical initial no            no-undo.
define variable bar-str                     like ub.prod-bc.b-str              no-undo.
define variable rdtaxname                   as   character                     no-undo.
define variable varvat-pc                   like ub.doc-line.vat-pc            no-undo.
define variable varslt-pc                   like ub.doc-line.slt-pc            no-undo.
define variable varcli-base-rate            like ub.doc-line.cli-base-rate     no-undo.
define variable vardoc-qnty                 like ub.doc-line.doc-qnty          no-undo.
define variable varfact-qnty                like ub.doc-line.doc-qnty          no-undo.
define variable varroad-tax                 like ub.doc-line.road-tax          no-undo.
define variable varexcise                   like ub.doc-line.excise            no-undo.
define variable varother-base               like ub.doc-line.other-base        no-undo.
define variable varother-rubl               like ub.doc-line.other-base        no-undo.
define variable vartransport-rubl           like ub.doc-line.transport-base    no-undo.
define variable vartransport-base           like ub.doc-line.transport-base    no-undo.
define variable varartic                    like ub.doc-line.artic             no-undo.
define variable varprod-type                like ub.doc-line.prod-type         no-undo.
define variable varprod-code                like ub.doc-line.prod-code         no-undo.
define variable v-other                     as   character                     no-undo.
define variable m-outs-5                    as   widget-handle                 no-undo.
define variable varr-b                      as   character                     no-undo.
define variable varvat-type-int             as   integer   initial ?           no-undo.
define variable varvat-type-type            as   character initial ?           no-undo.
define variable varvat-type-def             as   character                     no-undo.
define variable varslt-type-int             as   integer   initial ?           no-undo.
define variable varslt-type-type            as   character initial ?           no-undo.
define variable varslt-type-def             as   character                     no-undo.
define variable varvalue                    as   character                     no-undo.
define variable vartype                     as   character                     no-undo.
define variable vartpsi                     as   character                     no-undo.
define variable vartpsi-type                as   character                     no-undo.
define variable v-is-tsd                    as   character                     no-undo.
define variable v-is-tsd-type               as   character                     no-undo.
define variable v-is-pharm                  as   character                     no-undo.
define variable v-is-pharm-type             as   character                     no-undo.
define variable varlog                      as   logical                       no-undo.
define variable gds-rec                     as   recid                         no-undo.
define variable ref-rec                     as   recid                         no-undo.
define variable base-type                   as   character                     no-undo.
define variable varlns-cnt                  as   integer                       no-undo.
define variable prt-rec                     as   recid                         no-undo.
define variable varnotes                    as   character                     no-undo.
define variable parext-doc-mode             as   character                     no-undo.
define variable varst-qnty-pl               as   logical                       no-undo.
define variable v-is-ptrl                   as   character                     no-undo.
define variable v-data-type                 as   character                     no-undo.
define variable is-doc-hold                 as   logical                       no-undo.
define variable d-reason                    as   character                     no-undo.
define variable ch-vsd as character no-undo .
define variable choice as integer no-undo.
define variable isEgais  as logical   no-undo .
define variable v-mercury-value as character no-undo .
define variable v-mercury-type  as character no-undo .
define variable v-is-mercury-value as logical no-undo .
define variable vsdstrObj as class vsdtostorage no-undo.
define variable bcol as handle extent no-undo.
define variable hBrowse as handle no-undo.
define variable ii as integer no-undo.
define variable is-copy as logical no-undo.
define variable docrec-src as recid no-undo.
define variable varattr as character no-undo.
define variable v-modeetc as character no-undo.
define variable d-kg-after-qnty like ub.doc-line.fact-qnty  no-undo.
define variable d-kg-price-rubl like ub.doc-line.price-rubl no-undo.
define variable d-kg-price-base like ub.doc-line.price-base no-undo.
define variable d-kg-fact-qnty  like ub.doc-line.fact-qnty  no-undo.
define buffer oldoc-line for ub.doc-line.
define buffer cli-buf    for ub.clients.
define buffer t-d-b      for ub.trn-doc.
define buffer d-l-b      for ub.doc-line.
define buffer bf-trn-doc for ub.trn-doc.
define buffer bf_parts for ub.parts.
define buffer l-doc-line for ub.doc-line.
define buffer bf_sysconf for ub.sysconf.
define buffer buf_marking for ub.marking.
define buffer buf_marking-lines for ub.marking-lines.
define variable sort-default       as logical   no-undo .
define variable del-list           as character no-undo .
define variable base-abbr          as character format "x(3)":u view-as TEXT size 4 by 1 no-undo.
define variable is-add-doc         as logical   no-undo .
define variable v-is-gtd-part      as character no-undo .
define variable v-is-gtd-part-type as character no-undo .
define variable d-gtd-add          as character no-undo .
define variable var-inp_sum        as logical   no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-not-ord   as logical   no-undo .
define variable v-edit-fact-wayb as logical   no-undo .
define variable v-fact-qnty as character no-undo.
define variable v-can-edit as logical init yes .
define variable v-trnscanqr as logical no-undo .
define variable v-by-utd as logical no-undo .
define new shared variable PrintScale   as logical init true no-undo.
define new shared variable CostPrice    as logical no-undo.
define new shared variable sort-name    as logical no-undo.
define new shared variable sort-gr      as logical no-undo.
define new shared variable print-graft  as logical no-undo.
define new shared variable PrintParts   as logical no-undo .
function get-name returns character
(buffer buf_doc-line for ub.doc-line,
 buffer buf_goods    for ub.goods,
 buffer buf_gds-prt    for ub.gds-prt) :
define buffer buf_gds-dtl for ub.gds-dtl.
if buf_gds-prt.node-name = '_Пустая шкала':U then return '-' .
else do:
  if can-find (first buf_gds-dtl where
        buf_gds-dtl.artic     = buf_goods.artic
    and buf_gds-dtl.prod-type = buf_goods.prod-type
    and buf_gds-dtl.prod-code = buf_goods.prod-code
    and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
    and buf_gds-dtl.doc-code  = buf_doc-line.doc-code no-lock)
        then return '--------------------'.
        else buf_gds-prt.node-name .
end.
end function.
assign
  parext-doc-mode =
    ( if num-entries( pardoc-mode, '*':U ) > 1 then entry( 2, pardoc-mode, '*':U ) else '':U )
  pardoc-mode     = entry( 1, pardoc-mode, '*':U )
.
run cr-tt-upd in this-procedure no-error.
if error-status :error then do: return error. end.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION title-mode RETURNS CHARACTER
  ( INPUT pmode as character ) :
DEFINE VARIABLE ptitle-mode as character no-undo.
CASE ENTRY(1, pmode) :
  when 'ДОБАВЛЕНИЕ':U then ptitle-mode = "ДОБАВЛЕНИЕ".
  when 'ИЗМЕНЕНИЕ':U  then ptitle-mode = "ИЗМЕНЕНИЕ".
  when 'ПРОСМОТР':U  then ptitle-mode = "ПРОСМОТР".
END CASE.
  RETURN ptitle-mode.
END FUNCTION.
FUNCTION deviation-price RETURNS DECIMAL
(buffer local-doc-line for ub.doc-line)  FORWARD.
FUNCTION get-kg-after-qnty RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line )  FORWARD.
FUNCTION get-kg-fact-qnty RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line )  FORWARD.
FUNCTION get-kg-sale-base RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line )  FORWARD.
FUNCTION get-kg-sale-rubl returns decimal
( buffer local-doc-line for ub.doc-line )  FORWARD.
FUNCTION get-mark RETURNS CHARACTER
(buffer local-doc-line for ub.doc-line ) FORWARD.
FUNCTION last-price RETURNS DECIMAL
(buffer local-doc-line for ub.doc-line)  FORWARD.
FUNCTION get-add-gtd RETURNS character
(buffer local-doc-line for ub.doc-line)  FORWARD.
FUNCTION get-vsdsts RETURNS CHARACTER
(buffer local-doc-line for doc-line ) FORWARD.
FUNCTION get-vat-sum RETURNS decimal
(buffer local-doc-line for doc-line ) FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добав":L
     SIZE 6 BY 1.
DEFINE BUTTON b-add-doc
     LABEL "  ДопРасх":L
     SIZE 12 BY 1 TOOLTIP "Документ дополнительных расходов".
DEFINE BUTTON b-add-doc-yes
     IMAGE-UP FILE "cmp/check.bmp":U
     IMAGE-DOWN FILE "cmp/check.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/check.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 2 BY 0.9 TOOLTIP "Есть документ дополнительных расходов".
DEFINE BUTTON b-arch
     LABEL "Уч&етЦены":L
     SIZE 10 BY 1 TOOLTIP "Просмотр в учетных ценах".
DEFINE BUTTON b-attr
     LABEL "А&трибуты"
     SIZE 10 BY 1.
DEFINE BUTTON b-in-attr-fuel
     LABEL "Доп. инфо"
     SIZE 10 BY 1 TOOLTIP "Дополнительные атрибуты по документы при приемке топлива".
DEFINE BUTTON b-bc
     LABEL "&БКод":L
     SIZE 5 BY 1 TOOLTIP "Добавить по бар-коду".
DEFINE BUTTON b-chg
     LABEL "&Изм":L
     SIZE 6 BY 1.
DEFINE BUTTON b-cnt
     LABEL "&Договоры":L
     SIZE 10 BY 1 TOOLTIP "Разбивка по договорам поставщика".
DEFINE BUTTON b-contr-lkp
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Посмотреть договор".
DEFINE BUTTON b-del
     LABEL "&Удал":L
     SIZE 6 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 6 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 2.75 BY 1.
DEFINE BUTTON b-history
     LABEL "&История"
     SIZE 3.5 BY 1.
DEFINE BUTTON b-live
     LABEL "С&удьба":L
     SIZE 7 BY 1 TOOLTIP "Жизненный путь пришедших партий".
DEFINE BUTTON b-lkp
     LABEL "&Просм":L
     SIZE 6 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>":L
     SIZE 3 BY 1.
DEFINE BUTTON b-notes
     LABEL "Примечание":L
     SIZE 11.5 BY 1.
DEFINE BUTTON b-calc-tp
     LABEL "ТП поставки"
     SIZE 12 BY 1.
DEFINE BUTTON b-parts
     LABEL "Па&рт":L
     SIZE 6 BY 1.
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1.
DEFINE BUTTON b-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     LABEL "&Печать":L
     SIZE 3 BY 1.
DEFINE BUTTON b-prt
     LABEL "&Шкала":L
     SIZE 6 BY 1.
DEFINE BUTTON b-renum
     LABEL "&№п/п"
     SIZE 6 BY 1.
DEFINE BUTTON b-revis
     LABEL "С&верки"
     SIZE 8 BY 1.
DEFINE BUTTON b-marks
     LABEL "&Марки"
     SIZE 6 BY 1.
DEFINE BUTTON r-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-outs
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 2.63 BY .88.
DEFINE BUTTON r-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-reas
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE VARIABLE m-inc AS CHARACTER FORMAT "X(256)":U INITIAL "1"
     LABEL "Включить пропорционально"
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "сумме приходных цен","1",
                     "количеству(в баз. ед.изм.)","2",
                     "количеству(в пост. ед.изм.)","3",
                     "весу","4"
     DROP-DOWN-LIST
     SIZE 27.5 BY 1 TOOLTIP "Включать трансп. и пр.расходы в учет.цену пропорционально -" NO-UNDO.
DEFINE VARIABLE varpurch-code-name AS CHARACTER FORMAT "x(22)":U
     VIEW-AS COMBO-BOX
     LIST-ITEMS "выкуп","консигнация","ответственное хранение","старая консигнация"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 TOOLTIP "Тип приобретения" NO-UNDO.
DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc-art AS CHARACTER FORMAT "x(16)"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 TOOLTIP "Начало артикула"
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-code AS CHARACTER FORMAT "x(13)":U
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 TOOLTIP "Бар-код (весь)"
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-name AS CHARACTER FORMAT "x(40)":U
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 TOOLTIP "Начало названия"
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE ov-pc AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     LABEL "&%"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Изменение цены поставщика: наценка, скидка" NO-UNDO.
DEFINE VARIABLE rsn-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 37.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varcontract-prn-code AS CHARACTER FORMAT "X(48)"
     LABEL "До&говор"
     VIEW-AS FILL-IN
     SIZE 29 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE IMAGE g-image
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 14.5 BY 3.25.
DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code"
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE varinplnsum AS LOGICAL INITIAL no
     LABEL "&Cум"
     VIEW-AS TOGGLE-BOX
     SIZE 6 BY .75
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY br-dtl FOR
      ub.doc-line,
      ub.goods,
      ub.gds-prt,
      ub.gds-obj SCROLLING.
DEFINE BROWSE br-dtl
  QUERY br-dtl DISPLAY
      get-mark  (BUFFER  ub.doc-line)                    column-label '*'  format "x(1)":U
      ub.doc-line.line-num                    column-label 'П/П'  format ">>>>9":U
      ub.doc-line.prt-OK                    column-label 'Ш'  format "+/-":U
      ub.doc-line.artic                    column-label 'Артикул'
      ub.goods.gds-name                    column-label 'Название'  format "x(150)"
      ub.doc-line.cli-qnty                    column-label 'По ТТН'
      ub.doc-line.unit-cli                    column-label 'Изм'  format "x(3)":U
      ub.doc-line.price-cli                    column-label 'Цена пост.'
      ( ub.doc-line.cli-qnty *  ub.doc-line.price-cli)                    column-label 'Сумма пост.'  format ">>,>>>,>>>,>>>,>>9.99":U
      ub.doc-line.doc-qnty                   column-label 'По док-ту' format ">,>>>,>>>,>>>,>>9.999":U
      ub.doc-line.fact-qnty                   column-label 'Факт' format ">,>>>,>>>,>>>,>>9.999":U
      ub.goods.unit-base                   column-label 'Изм.' format "x(3)":U
      (if varr-b = 'rubl':u then  ub.doc-line.price-rubl else  ub.doc-line.price-base)                   column-label 'Цена учет(прод.)'
      ub.gds-obj.price-sale                   column-label 'Цена продажи'
      (if varr-b = 'rubl':u then ((ub.gds-obj.price-sale -  ub.doc-line.price-rubl) /  ub.doc-line.price-rubl * 100) else ((ub.gds-obj.price-sale -  ub.doc-line.price-base) /  ub.doc-line.price-base * 100))                   column-label '%' format "->>>,>>9.<<":U
      get-name (BUFFER  ub.doc-line, buffer ub.goods, buffer ub.gds-prt)                   column-label 'Шкала' format "x(10)":U
      ub.doc-line.VAT-pc                   column-label 'НДС' format ">9.9%":U
      get-vat-sum( buffer ub.doc-line ) @ vat-sum         column-label 'Сумма НДС' format ">>,>>>,>>>,>>>,>>9.99"
      ub.goods.engl-name                   column-label 'Название англ.'
      ub.doc-line.num-place                   column-label 'Кол-во мест'
      ub.doc-line.wt-brutto                   column-label 'Вес брутто'
      ub.doc-line.fact-qnty * ub.goods.cst-base-rate                   column-label 'Кол в там. ед.'
      last-price (buffer  ub.doc-line)                   column-label 'Прих. цена' format ">,>>>,>>>,>>>,>>9.999":U
      deviation-price (buffer  ub.doc-line)                   column-label '% откл прих. цены'
      get-kg-fact-qnty(  buffer  ub.doc-line ) @ d-kg-fact-qnty  column-label 'Факт, кг' format ">>>,>>>,>>9.999":U
      get-kg-sale-base(  buffer  ub.doc-line ) @ d-kg-price-base column-label 'Цена за кг (вал.)' format "->>,>>>,>>>,>>9.999":U
      get-kg-sale-rubl(  buffer  ub.doc-line ) @ d-kg-price-rubl column-label 'Цена за кг (руб.)' format "->,>>>,>>>,>>>,>>9.999":U
      get-kg-after-qnty( buffer  ub.doc-line ) @ d-kg-after-qnty column-label 'Итого, кг' format "->,>>>,>>>,>>>,>>9.999":U
      get-add-gtd( buffer ub.doc-line ) @ d-gtd-add       column-label 'Доп. к ГТД' format "x(15)"
      lineattr-get-reason( buffer ub.doc-line ) @ d-reason        column-label 'Причина отклонения по РТ' format "x(25)"
      get-vsdsts( buffer ub.doc-line ) @ ch-vsd          column-label 'ВСД' format "x(3)"
      enable ub.doc-line.cli-qnty ub.doc-line.fact-qnty ub.doc-line.num-place ub.doc-line.wt-brutto
    WITH SEPARATORS SIZE 107.5 BY 10.
DEFINE FRAME d-in-doc
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 7
     b-next AT ROW 1 COL 10
     b-revis AT ROW 1 COL 13
     b-arch AT ROW 1 COL 21
     b-add-doc AT ROW 1 COL 31 WIDGET-ID 2
     b-cnt AT ROW 1 COL 43.13
     b-attr AT ROW 1 COL 53.13
     b-in-attr-fuel AT ROW 1 COL 63.25
     b-notes AT ROW 1 COL 73.25
     b-calc-tp AT ROW 1 COL 84.8
     b-history AT ROW 1 COL 89.5
     b-print AT ROW 1 COL 93
     b-help AT ROW 1 COL 96
     t-doc.cli-code AT ROW 2 COL 11 COLON-ALIGNED
          LABEL "П&оставщик"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     t-doc.cli-type AT ROW 2 COL 20 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.clients.obj-name AT ROW 2 COL 26.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 37 BY 1
          FGCOLOR 4
     varcontract-prn-code AT ROW 2 COL 74 COLON-ALIGNED
     b-contr-lkp AT ROW 2 COL 104.75
     r-clients AT ROW 2.04 COL 26
     r-currency AT ROW 3 COL 18.25
     t-doc.exch-code AT ROW 3.04 COL 7.13 COLON-ALIGNED
          LABEL "Ва&люта"
          VIEW-AS FILL-IN
          SIZE 4 BY .92
          FGCOLOR 4
     t-doc.exch-date AT ROW 3.04 COL 29.38 COLON-ALIGNED
          LABEL "ГТД"
          VIEW-AS FILL-IN
          SIZE 9 BY .92 TOOLTIP "Дата таможни"
          FGCOLOR 4
     t-doc.discnt-pc AT ROW 3.04 COL 52.13 COLON-ALIGNED
          LABEL "На&ценка ГТД"
          VIEW-AS FILL-IN
          SIZE 6 BY .92
          FGCOLOR 4
     t-doc.cst-code AT ROW 3.04 COL 65 COLON-ALIGNED
          LABEL "&ГТД№"
          Format "x(31)"
          VIEW-AS FILL-IN
          SIZE 32 BY .92
          FGCOLOR 4
     t-doc.exch-rate AT ROW 4 COL 10 COLON-ALIGNED
          LABEL "Курс п&-ка"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     t-doc.exch-scale AT ROW 4 COL 19 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5 BY 1
          FGCOLOR 4
     r-acc AT ROW 4 COL 26
     t-doc.tot-cli AT ROW 4 COL 87.88 COLON-ALIGNED
          LABEL "Сумма для проверки"
          VIEW-AS FILL-IN
          SIZE 18 BY .92
          FGCOLOR 4
     t-doc.base-rate AT ROW 5 COL 10 COLON-ALIGNED
          LABEL "Курс &б.в."
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     t-doc.base-scale AT ROW 5 COL 19 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     t-doc.out-code AT ROW 5 COL 29.5 COLON-ALIGNED
          LABEL "Ис&т"
          VIEW-AS FILL-IN
          SIZE 28 BY 1 TOOLTIP "Источник"
     r-outs AT ROW 5 COL 59.5
     t-doc.pay-code AT ROW 6 COL 7 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 7.5 BY 1
     r-pay AT ROW 6 COL 28.63
     varpurch-code-name AT ROW 6 COL 29.5 COLON-ALIGNED NO-LABEL
     t-doc.wrkr AT ROW 7 COL 5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
     r-wrkr AT ROW 7 COL 28.63
     t-doc.ord-num AT ROW 7 COL 43.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     t-doc.agnt AT ROW 8 COL 5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
     r-agnt AT ROW 8 COL 28.5
     t-doc.boss AT ROW 9 COL 5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
     r-boss AT ROW 9 COL 28.5
     t-doc.doc-date AT ROW 10 COL 5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME d-in-doc
     t-doc.fact-date AT ROW 10 COL 23 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.75 BY 1
          FGCOLOR 4
     t-doc.shift-date AT ROW 10 COL 39.5 COLON-ALIGNED
          LABEL "&Смена"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4
     t-doc.shift-name AT ROW 10 COL 53.25 COLON-ALIGNED
          LABEL "&№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1 TOOLTIP "Номер смены"
          FGCOLOR 4
     t-doc.shift-num AT ROW 10 COL 59.38 COLON-ALIGNED
          LABEL "П"
          VIEW-AS FILL-IN
          SIZE 3 BY 1 TOOLTIP "Порядок смен"
          FGCOLOR 4
     r-sht AT ROW 10 COL 64.38
     t-doc.SLT-type AT ROW 11 COL 5 COLON-ALIGNED
          VIEW-AS COMBO-BOX INNER-LINES 3
          LIST-ITEMS "без","нет","в т. ч."
          DROP-DOWN-LIST
          SIZE 9.75 BY 1
     t-doc.VAT-type AT ROW 11 COL 21.5 COLON-ALIGNED
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 9.75 BY 1
     ov-pc AT ROW 11 COL 38.75 COLON-ALIGNED
     b-add-doc-yes AT ROW 1 COL 31 WIDGET-ID 4
     t-doc.tot-transp AT ROW 11.33 COL 62.88 COLON-ALIGNED
          LABEL "Тр"
          VIEW-AS FILL-IN
          SIZE 15 BY .71 TOOLTIP "Транспортные расходы"
          FGCOLOR 4
     t-doc.tot-other AT ROW 11.25 COL 88.5 COLON-ALIGNED
          LABEL "Пр"
          VIEW-AS FILL-IN
          SIZE 15 BY .71 TOOLTIP "Прочие расходы"
          FGCOLOR 4
     m-inc AT ROW 12.25 COL 27 COLON-ALIGNED
     t-doc.ship-num AT ROW 13.5 COL 10 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10.5 BY 1 TOOLTIP "№ отгрузки"
          FGCOLOR 4
     t-doc.ship-date AT ROW 13.5 COL 21 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9.5 BY 1 TOOLTIP "Дата отгрузки"
          FGCOLOR 4
     r-reas AT ROW 13.5 COL 49.5
     a-n-c AT ROW 14.5 COL 72 NO-LABEL
     loc-name AT ROW 14.5 COL 82.5 COLON-ALIGNED NO-LABEL
     loc-art AT ROW 14.5 COL 82.63 COLON-ALIGNED NO-LABEL
     loc-code AT ROW 14.5 COL 82.75 COLON-ALIGNED NO-LABEL
     b-mark AT ROW 14.63 COL 1
     b-add AT ROW 14.63 COL 4
     b-bc AT ROW 14.63 COL 10
     b-prt AT ROW 14.63 COL 15
     b-parts AT ROW 14.63 COL 21
     b-lkp AT ROW 14.63 COL 27
     b-chg AT ROW 14.63 COL 33
     b-del AT ROW 14.63 COL 39
     b-live AT ROW 14.63 COL 45.13
     b-renum AT ROW 14.63 COL 52.25
     b-marks at row 14.63 col 58
     varinplnsum AT ROW 14.71 COL 65.38
     br-dtl AT ROW 15.75 COL 1
     ub.currency.curr-abbr AT ROW 3 COL 11.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY 1
          FGCOLOR 4
     t-doc.tot-calc AT ROW 4.92 COL 87.88 COLON-ALIGNED
          LABEL "По строкам док-та"
           VIEW-AS TEXT
          SIZE 18 BY .67
          FGCOLOR 4
     t-doc.road-tax AT ROW 5.63 COL 87.88 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 18 BY .67
          FGCOLOR 4
     ub.pay-type.obj-name AT ROW 6 COL 15 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 11.75 BY 1
          FGCOLOR 4
     t-doc.tot-sale AT ROW 6.33 COL 87.88 COLON-ALIGNED
          LABEL "Сумма rubl факт"
           VIEW-AS TEXT
          SIZE 18 BY .67
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME d-in-doc
     wrkr-name AT ROW 7 COL 15 COLON-ALIGNED NO-LABEL
     t-doc.tot-fact AT ROW 7 COL 87.88 COLON-ALIGNED
          LABEL "Сумма валюта факт"
           VIEW-AS TEXT
          SIZE 18 BY .67
          FGCOLOR 4
     t-doc.VAT-rubl AT ROW 7.71 COL 87.88 COLON-ALIGNED
          LABEL "НДС по УЧЕТ ценам(rub)"
           VIEW-AS TEXT
          SIZE 18 BY .71
          BGCOLOR 3 FGCOLOR 15
     agnt-name AT ROW 8 COL 15 COLON-ALIGNED NO-LABEL
     t-doc.VAT-base AT ROW 8.42 COL 87.88 COLON-ALIGNED
          LABEL "НДС по УЧЕТ ценам(вал)"
           VIEW-AS TEXT
          SIZE 18 BY .71
          BGCOLOR 3 FGCOLOR 15
     boss-name AT ROW 9 COL 15 COLON-ALIGNED NO-LABEL
     t-doc.cli-qnty AT ROW 9.17 COL 88.5 COLON-ALIGNED
          LABEL "КолТТН"
           VIEW-AS TEXT
          SIZE 12.5 BY .67
          FGCOLOR 4
     t-doc.doc-qnty AT ROW 9.92 COL 88.5 COLON-ALIGNED
          LABEL "Док.кол-во"
           VIEW-AS TEXT
          SIZE 12.5 BY .67
          FGCOLOR 4
     t-doc.fact-qnty AT ROW 10.58 COL 88.5 COLON-ALIGNED
          LABEL "Факт.кол-во"
           VIEW-AS TEXT
          SIZE 12.5 BY .67
          FGCOLOR 4
     t-doc.reason-code AT ROW 13.5 COL 43.5 COLON-ALIGNED
          LABEL "Основание" FORMAT ">>>>"
           VIEW-AS TEXT
          SIZE 4 BY .67 TOOLTIP "Основание заведения документа"
     rsn-name AT ROW 13.5 COL 51 COLON-ALIGNED NO-LABEL
     g-image AT ROW 12.25 COL 94 WIDGET-ID 6
     SPACE(0.49) SKIP(10.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>".
ASSIGN
       FRAME d-in-doc:SCROLLABLE       = FALSE
       FRAME d-in-doc:HIDDEN           = TRUE
       FRAME d-in-doc:SENSITIVE        = FALSE.
ON END-ERROR OF FRAME d-in-doc
or endkey    of frame d-in-doc anywhere
do:
  return no-apply.
end.
ON WINDOW-CLOSE OF FRAME d-in-doc
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME d-in-doc
DO:
 if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
 run add-doc-line-local in this-procedure.
 apply "entry" to b-add in frame d-in-doc.
END.
ON CHOOSE OF b-add-doc IN FRAME d-in-doc
DO:
  run local-add-doc in this-procedure.
END.
ON CHOOSE OF b-arch IN FRAME d-in-doc
DO:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if not varlog then do: return no-apply. end.
  run local-arh in this-procedure.
END.
ON CHOOSE OF b-attr IN FRAME d-in-doc
DO:
 if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run init-attr-general in this-procedure .
  if v-can-edit
  and not v-by-utd
  then do :
    if t-doc.status_ <> 'факт':U then do:
      run str/doc-attr.w (input ParParentproc, input "b-lkp,b-chg,b-add,b-del", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
    else do:
      run str/doc-attr.w (input ParParentproc, input "b-lkp,b-chg,b-add", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
  end .
  else do :
    run str/doc-attr.w (input ParParentproc, input "b-lkp", input t-doc.doc-code, input table tt-upd-attr) no-error.
  end .
END.
ON CHOOSE OF b-in-attr-fuel IN FRAME d-in-doc
DO:
    run init-attr-general in this-procedure .
    if t-doc.status_ <> 'факт':U then do:
      run str/in-laddtrn.w (input ParParentproc, input (if not v-can-edit then 'ПРОСМОТР':U else pardoc-mode), input t-doc.doc-code, input table tt-upd-attr-fuel) no-error.
    end.
    else do:
      run str/in-laddtrn.w (input ParParentproc, input (if not v-can-edit then 'ПРОСМОТР':U else pardoc-mode), input t-doc.doc-code, input table tt-upd-attr-fuel) no-error.
    end.
END.
ON CHOOSE OF b-calc-tp IN FRAME d-in-doc
DO:
  run str/in-laddsugtp.w (
    input ParParentproc,
    input if t-doc.reason-code <> 99 then 'ПРОСМОТР':U else pardoc-mode,
    input t-doc.doc-code,
    input table tt-upd-attr-fuel)
  no-error.
END.
ON CHOOSE OF b-bc IN FRAME d-in-doc
DO:
    if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run local-bc in this-procedure.
END.
ON CHOOSE OF b-chg IN FRAME d-in-doc
DO:
    if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run chg-line in this-procedure.
END.
ON CHOOSE OF b-cnt IN FRAME d-in-doc
DO:
    if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if not varlog then do: return no-apply. end.
  run str/scntdoc.w ( input t-doc.doc-code, input v-cntxt-db-num = bf_sysconf.firm-db-num ).
END.
ON CHOOSE OF b-contr-lkp IN FRAME d-in-doc
DO:
 define buffer buf_contract for ub.contract  .
 if t-doc.contract-code <> 0 then do:
 find first buf_contract no-lock where
            buf_contract.host-code     = t-doc.host-code  and
            buf_contract.contract-code = t-doc.contract-code no-error .
      if available buf_contract then do:
          run str/sh-contr.p
              ( input parParentProc ,
                input recid(buf_contract)
              ).
      end.
  end.
if pardoc-mode <> 'ПРОСМОТР':U then do:
    define variable varrid-list as character no-undo.
    define variable varrecid    as recid     no-undo.
    find first buf_contract where buf_contract.host-code = t-doc.host-code no-lock no-error .
    if available buf_contract then do:
            run str/cont-all.w (input parParentProc,
                      input t-doc.host-code,
                      input "b-sel",
                      input "firm-curr" ,
                      input t-doc.cli-type,
                      input t-doc.cli-code,
                      input ?,
                      input ?,
                      input "current":u,
                      input "all":u,
                      input-output varrid-list ) no-error.
      if error-status:error then do:
        message "Ошибка при вызове справочника договоров." skip
                return-value                skip
                error-status:get-message(1) skip
                error-status:get-message(2)
        view-as alert-box error.
        return no-apply.
      end.
      assign
        varrecid = integer(entry(1, varrid-list)).
    find first buf_contract where recid(buf_contract) = varrecid no-lock no-error.
    if available buf_contract then do:
       assign
    t-doc.contract-code = buf_contract.contract-code.
    end.
    for each bf_parts where bf_parts.out-code = t-doc.doc-code and bf_parts.contract-code <> t-doc.contract-code EXCLUSIVE-LOCK :
              bf_parts.contract-code = t-doc.contract-code .
     end.
    end.
    end.
    else do:
    if t-doc.status_ <> 'накл':U or t-doc.flag_ then return.
    define variable varis-fin        as   character                       no-undo.
    define variable varis-finby      as   character                       no-undo.
    define buffer bf_contract      for ub.contract.
    define buffer bf_currency      for ub.currency.
    define buffer bf-f_contract-specif    for ub.contract-specif.
    define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
    define variable v-value-date      like ub.thbj-attr.property-value-date    no-undo .
    define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
    define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
    define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
    define variable varcontract-type as   character                       no-undo.
    define variable varcontract      as   character                       no-undo.
    define variable varcontract-code as   integer                         no-undo.
    define variable v-tth1           as   handle                          no-undo.
    define variable varexch-rate      like ub.trn-doc.exch-rate           no-undo.
    define variable varexch-scale     like ub.trn-doc.exch-scale          no-undo.
    define variable varcurr-abbr     as   character                       no-undo.
    define variable v-master as character no-undo.
    if trn-type = 4 then do:
    run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input 'contr-in':U
      ,input ( if t-doc.ext-doc-type = 'ee':U  then  "contr-in-expense" else "contr-in-income" )
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE-handle v-tth1
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
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input 'contr-in':U
      ,input ( if t-doc.ext-doc-type = 'ee':U  then  "contr-in-expense-NP" else "contr-in-income-NP" )
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE-handle v-tth1
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
      delete object v-tth1.
      if v-value-logical = true then varcontract = "yes" .
                                else varcontract = "no" .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varis-fin
  ,output vartype
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-finby'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varis-finby
  ,output vartype
  ) no-error .
    if ( varis-fin = "yes":u
     and ( t-doc.ext-doc-type = 'ie':U or
           t-doc.ext-doc-type = 'ep':U or
         ( t-doc.ext-doc-type = 'ee':U     and paris-hold = true   ) or
         ( t-doc.ext-doc-type = 're':U and paris-hold = true   )))
      or ( varis-finby = "yes":u
      and ( t-doc.ext-doc-type = 'ee':U      or
            t-doc.ext-doc-type = 'ep':U or
            t-doc.ext-doc-type = 're':U  or
          ( t-doc.ext-doc-type = 'ee':U  and paris-hold = true )))
      then do:
        find first bf_contract where bf_contract.host-code = t-doc.host-code                          and
                                     bf_contract.cli-type  = input frame d-in-doc t-doc.cli-type and
                                     bf_contract.cli-code  = input frame d-in-doc t-doc.cli-code no-lock no-error.
        if not available bf_contract then do:
        end.
        else do:
          run check-contract-code in this-procedure (input  substitute("&1,&2=&3", "choose":u, "doc-type", t-doc.ext-doc-type),
                                                      input  t-doc.host-code,
                                                      input  input frame d-in-doc t-doc.cli-type,
                                                      input  input frame d-in-doc t-doc.cli-code,
                                                      input  ?,
                                                      input  parparentproc,
                                                      input  t-doc.doc-date,
                                                      input  (if ( t-doc.ext-doc-type = 'ie':U or t-doc.ext-doc-type = 'ep':U ) then 'при':U else 'рас':U) ,
                                                      output varcontract-code) no-error.
          if error-status :error    or
             varcontract-code = ?  or
             varcontract-code = 0  then do:
          end.
          else do:
            find first bf_contract where bf_contract.host-code     = t-doc.host-code  and
                                         bf_contract.contract-code = varcontract-code no-lock.
            find first bf_currency where bf_currency.curr-code = bf_contract.curr-code no-lock no-error.
            if not available bf_currency then do:
              message "В договоре указана валюта " bf_contract.curr-code "." skip
                      "Но этой валюты нет в справочнике валют."
              view-as alert-box error.
              apply "entry" to t-doc.cli-code in frame d-in-doc.
              return no-apply.
            end.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  bf_currency.curr-code
  ,input  t-doc.exch-date
  ,output varexch-rate
  ,output varexch-scale
  ,output varcurr-abbr
  ) no-error .
            if error-status :error then do:
              message "Ошибка при поиске курса валюты поставки по договору." skip
                      return-value skip
                      error-status :get-message( 1 ) skip
                      error-status :get-message( 2 )
              view-as alert-box error.
              return no-apply.
            end.
            assign
              t-doc.contract-code = varcontract-code
              t-doc.exch-code     = bf_contract.curr-code
              t-doc.exch-rate     = varexch-rate
              t-doc.exch-scale    = varexch-scale
            .
            v-master = Is-Master-Slave-Contract( buffer bf_contract) .
            if v-master  = "+" or v-master  = ""  then do :
              find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num = bf_contract.contract-code
                                                        and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
            end.
            else do :
              find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num =integer(v-master)
                                                        and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
            end.
            if available bf-f_contract-specif then do:
              t-doc.vat-type = bf-f_contract-specif.vat-type .
            end.
            for each bf_parts where bf_parts.out-code = t-doc.doc-code and bf_parts.contract-code <> t-doc.contract-code EXCLUSIVE-LOCK :
              bf_parts.contract-code = t-doc.contract-code .
            end.
            run chg-purch-contract in this-procedure.
          end.
        end.
      end.
      else do:
        assign
          t-doc.contract-code  = 0.
      end.
  end.
run UI-on in this-procedure ( input "enable" ).
END.
ON CHOOSE OF b-del IN FRAME d-in-doc
DO:
    if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run del-doc-line in this-procedure no-error.
END.
ON CHOOSE OF b-live IN FRAME d-in-doc
DO:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run live-loc in this-procedure no-error .
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
END.
ON CHOOSE OF b-lkp IN FRAME d-in-doc
DO:
    if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run local-lockup in this-procedure.
END.
ON CHOOSE OF b-mark IN FRAME d-in-doc
DO:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run proc-b-mark in this-procedure no-error.
END.
ON CHOOSE OF b-parts IN FRAME d-in-doc
DO:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run choose-b-parts in this-procedure no-error.
  run ui-on in this-procedure ( input "line" ).
END.
ON CHOOSE OF b-prt IN FRAME d-in-doc
DO:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run choose-b-prt in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  run ui-on in this-procedure ( input "line" ).
END.
ON CHOOSE OF b-marks IN FRAME d-in-doc
DO:
    define buffer buf_gen-attr for ub.gen-attr .
    define variable v-parts-uniq-key-rec    as character    no-undo .
    define buffer buf_tt-marks  for tt-marks .
    define variable v-alcohol-prod   as logical no-undo .
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  if not available (ub.goods)
    then return no-apply.
  for each buf_tt-marks:
    delete buf_tt-marks .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  ub.goods.gds-code
  ,input  'alcohol-prod=request':u
  ,output v-alcohol-prod
  )  .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута товара" skip
      "Код товара" ub.goods.gds-code skip
      'mercur_FGIS=request':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
  case true:
    when v-alcohol-prod then do:
      message "Вывести марки по всем линиям?"
        view-as alert-box question buttons YES-NO title "Вопрос" update varlog.
      for each bf_parts where bf_parts.out-code = t-doc.doc-code and
      (varlog or (bf_parts.artic = goods.artic and bf_parts.prod-code = goods.prod-code and bf_parts.prod-type = goods.prod-type)):
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
        ,input (buffer bf_parts:handle)
        ,output v-parts-uniq-key-rec).
        for each buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U and buf_gen-attr.p-key = v-parts-uniq-key-rec:
            find first buf_tt-marks where buf_tt-marks.mark = buf_gen-attr.attr-code no-error .
            if not AVAILABLE buf_tt-marks then
            do:
                create buf_tt-marks .
                ASSIGN
                    buf_tt-marks.mark               = buf_gen-attr.attr-code
                    buf_tt-marks.parts              = buf_gen-attr.p-key
                    buf_tt-marks.reserv             = buf_gen-attr.whole-send-news
                    buf_tt-marks.num                = ""
                    buf_tt-marks.gds-part-position_ = ?
                    buf_tt-marks.gds-code           =  goods.gds-code
                    .
            end.
          end.
        end.
        run ref/egais-marks_exp.w (
            input parparentproc,
            input t-doc.doc-code,
            input 'при':U  ,
            input-output table tt-marks) no-error.
      if error-status :error then do: return no-apply. end.
    end.
    when true then do:
      for each bf_parts no-lock where bf_parts.out-code = t-doc.doc-code and
      bf_parts.artic = goods.artic and bf_parts.prod-code = goods.prod-code and bf_parts.prod-type = goods.prod-type:
        for each ub.marking-lines no-lock where
              ub.marking-lines.obj-type = bf_parts.obj-type
          and ub.marking-lines.obj-code = bf_parts.obj-code
          and ub.marking-lines.in-code = bf_parts.in-code
          and ub.marking-lines.out-code = bf_parts.out-code
          and ub.marking-lines.gds-code = ub.goods.gds-code
          and ub.marking-lines.part-code = bf_parts.part-code
          and ub.marking-lines.prt-code = bf_parts.prt-code:
          create tt-marking-lines.
          buffer-copy ub.marking-lines to tt-marking-lines.
          find first ub.marking no-lock where ub.marking.mark = tt-marking-lines.mark no-error.
          if available (ub.marking)
          then do:
            tt-marking-lines.sts = ub.marking.sts.
            tt-marking-lines.stts = objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking.sts).
            tt-marking-lines.box-qnty = ub.marking.box-qnty .
            tt-marking-lines.unit = ub.marking.unit .
            tt-marking-lines.unit-ext = ub.marking.unit-ext .
            tt-marking-lines.doc-level = ub.marking-lines.doc-level.
            tt-marking-lines.gds-name = ub.goods.gds-name.
            tt-marking-lines.mark-parent = ub.marking.mark-parent.
            if tt-marking-lines.doc-level = 2
            then do:
              find first buf_marking-lines no-lock where ub.marking.mark-parent <> ""
                and buf_marking-lines.mark = ub.marking.mark-parent
                and buf_marking-lines.obj-type = bf_parts.obj-type
                and buf_marking-lines.obj-code = bf_parts.obj-code
                and buf_marking-lines.in-code = bf_parts.in-code
                and buf_marking-lines.out-code = bf_parts.out-code
                and buf_marking-lines.gds-code = ub.goods.gds-code
                and buf_marking-lines.part-code = bf_parts.part-code
                and buf_marking-lines.prt-code = bf_parts.prt-code no-error.
              if not available (buf_marking-lines)
              then do:
                find first tt-marking-lines no-lock where tt-marking-lines.mark = ub.marking.mark-parent
                  no-error.
                if not available (tt-marking-lines )
                then do:
                  find first buf_marking no-lock where buf_marking.mark = ub.marking.mark-parent.
                  create tt-marking-lines.
                  buffer-copy ub.marking-lines except ub.marking-lines.mark ub.marking-lines.sts to tt-marking-lines.
                  tt-marking-lines.mark = buf_marking.mark.
                  tt-marking-lines.sts = buf_marking.sts.
                  tt-marking-lines.box-qnty = buf_marking.box-qnty .
                  tt-marking-lines.unit = buf_marking.unit .
                  tt-marking-lines.unit-ext = buf_marking.unit-ext .
                  tt-marking-lines.doc-level = 1.
                  tt-marking-lines.gds-name = ub.goods.gds-name.
                  tt-marking-lines.mark-parent = buf_marking.mark-parent.
                  tt-marking-lines.stts = objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts).
                end.
              end.
            end.
          end.
          else do:
            if isMark(tt-marking-lines.mark) then
              message "Марка отсутсвует в справочнике марок - " + tt-marking-lines.mark view-as alert-box error.
          end.
        end.
      end.
      run str/mark_browse.w (input parparentproc, input-output table tt-marking-lines, input 'ПРОСМОТР':U, input "", input "", input "") .
      for each tt-marking-lines:
        delete tt-marking-lines.
      end.
    end.
    otherwise do:
      if not v-alcohol-prod
      then do:
        message "Товар не подлежит маркировке." view-as alert-box information title "Информация".
        undo, return no-apply .
      end.
    end.
  end case.
  run ui-on in this-procedure ( input "line" ).
END.
ON CHOOSE OF b-renum IN FRAME d-in-doc
DO:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  assign
    line-rec = ( if available ub.doc-line then recid( ub.doc-line ) else ? )
  .
  run renum in this-procedure ( input t-doc.doc-code ).
  sort-default = yes. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,       EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,       first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,       EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK BY  ub.doc-line.line-num.
  reposition br-dtl to recid line-rec no-error.
END.
ON ROW-LEAVE OF br-dtl IN FRAME d-in-doc
DO:
  run local-row-leave in this-procedure.
END.
ON row-display OF br-dtl IN FRAME d-in-doc
DO:
  run rowdisp .
END.
ON LEAVE OF t-doc.cst-code IN FRAME d-in-doc
DO:
  if not available t-doc then return .
  if input frame d-in-doc t-doc.cst-code <> t-doc.cst-code then do:
    run wr-cst-code in this-procedure.
  end.
END.
ON LEAVE OF t-doc.exch-code IN FRAME d-in-doc
or return of t-doc.exch-code in frame d-in-doc
do:
  if not available t-doc then return .
  if input frame d-in-doc t-doc.exch-code <> t-doc.exch-code then do:
    run choice-currency in this-procedure no-error.
    if error-status :error then do: return no-apply. end.
    run update-rate-doc in this-procedure no-error.
  end.
end.
ON LEAVE OF t-doc.exch-date IN FRAME d-in-doc
or return of t-doc.exch-date  in frame d-in-doc
do:
  if not available t-doc then return .
  if input frame d-in-doc t-doc.exch-date <> t-doc.exch-date then do:
    assign
      frame d-in-doc t-doc.exch-date
    .
  end.
end.
ON LEAVE OF t-doc.exch-rate IN FRAME d-in-doc
or return of t-doc.exch-rate in frame d-in-doc
or leave, return of t-doc.exch-scale in frame d-in-doc
or leave, return of t-doc.base-rate  in frame d-in-doc
or leave, return of t-doc.base-scale in frame d-in-doc
do:
if not available t-doc then return .
  run update-rate-doc in this-procedure no-error.
  if error-status :error then do:
    run disp-exch in this-procedure.
    return no-apply.
  end.
end.
ON LEAVE OF t-doc.fact-date IN FRAME d-in-doc
DO:
if not available t-doc then return .
  run chk-upd-date in this-procedure ( input self :name ).
END.
ON RETURN OF t-doc.fact-date IN FRAME d-in-doc
DO:
  if t-doc.fact-date:sensitive in frame d-in-doc then do:
    apply "entry" to t-doc.shift-date in frame d-in-doc.
  end.
  else do:
    apply "entry" to b-add in frame d-in-doc.
  end.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME d-in-doc
DO:
  RUN ref/imagelist.w (PARPARENTPROC, "":U, ub.goods.gds-code,'ПРОСМОТР':U).
END.
ON VALUE-CHANGED OF m-inc IN FRAME d-in-doc
DO:
  run local-upd-m-inc in this-procedure no-error.
END.
ON MOUSE-SELECT-DBLCLICK OF t-doc.out-code IN FRAME d-in-doc
OR return of t-doc.out-code in frame d-in-doc
do:
  run out-doc-rec in this-procedure no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка !"
    view-as alert-box error
  .
end.
ON LEAVE OF ov-pc IN FRAME d-in-doc
OR return of ov-pc in frame d-in-doc
do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  if input frame d-in-doc ov-pc <> ov-pc then do:
    run ov-pc in this-procedure.
  end.
end.
ON CHOOSE OF r-currency IN FRAME d-in-doc
DO:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run r-proc-currency in this-procedure.
END.
ON CHOOSE OF r-outs IN FRAME d-in-doc
DO:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  return no-apply.
END.
ON CHOOSE OF r-reas IN FRAME d-in-doc
DO:
    run select-reason in this-procedure.
END.
ON LEAVE OF t-doc.shift-date IN FRAME d-in-doc
do:
  if not available t-doc then return .
  if input frame d-in-doc t-doc.shift-date <> t-doc.shift-date then do:
    assign
      t-doc.shift-name = ""
      t-doc.shift-num  = 0.
    display t-doc.shift-name t-doc.shift-num with frame d-in-doc.
    apply "entry" to t-doc.shift-name in frame d-in-doc.
    return no-apply.
  end.
end.
on return of t-doc.shift-date in frame d-in-doc do:
  apply "entry" to t-doc.shift-name in frame d-in-doc.
  return no-apply.
end.
on return of t-doc.shift-name in frame d-in-doc do:
  apply "entry" to b-add in frame d-in-doc.
  return no-apply.
end.
on return of t-doc.shift-num in frame d-in-doc do:
  apply "entry" to b-add in frame d-in-doc.
  return no-apply.
end.
on choose of r-sht in frame d-in-doc do:
  run proc-sht.
end.
on leave of t-doc.shift-num  in frame d-in-doc do:
  if not available t-doc then return .
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of t-doc.shift-name in frame d-in-doc do:
if not available t-doc then return .
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
ON return OF t-doc.ship-num IN FRAME d-in-doc
or return of t-doc.ship-date in frame d-in-doc
or return of t-doc.exch-date in frame d-in-doc
or return of t-doc.tot-cli   in frame d-in-doc do:
   run apply-entry-next-field in this-procedure ( input self :name ) no-error.
   return no-apply.
end.
ON VALUE-CHANGED OF t-doc.SLT-type IN FRAME d-in-doc
DO:
run val-ch-type in this-procedure ( self:name ).
END.
ON LEAVE OF t-doc.tot-cli IN FRAME d-in-doc
or leave of t-doc.tot-transp in frame d-in-doc
or leave of t-doc.tot-other  in frame d-in-doc
or leave of t-doc.ord-num    in frame d-in-doc
or leave of t-doc.ship-num   in frame d-in-doc
or leave of t-doc.ship-date  in frame d-in-doc do:
  if not available t-doc then return .
  run ass-frame-light in this-procedure ( input self :name ).
end.
ON VALUE-CHANGED OF varinplnsum IN FRAME d-in-doc
DO:
  run local-upd-inplnsum in this-procedure no-error.
END.
ON VALUE-CHANGED OF varpurch-code-name IN FRAME d-in-doc
DO:
  run vc-purch-code in this-procedure.
END.
ON VALUE-CHANGED OF t-doc.VAT-type IN FRAME d-in-doc
DO:
  run val-ch-type in this-procedure ( self:name ).
END.
define menu m-print
    menu-item m-print-1   label "&Ценник"
    menu-item m-print-3   label "&Список кодов"
    menu-item m-print-2   label "&Торг-12"
    .
define menu m-ptrl
    menu-item m-ptrl-1   label "Создать документы сверки и зафиксировать  книжное кол-во"  accelerator "alt-1"
    menu-item m-ptrl-2   label "Удалить документы сверки и расфиксировать книжное кол-во"  accelerator "alt-2".
define menu m-outs
    menu-item m-outs-1 label "Документы по объекту"              accelerator "alt-1"
    menu-item m-outs-2 label "Мобильный сканер"                  accelerator "alt-2"
    menu-item m-outs-3 label "Импорт"                            accelerator "alt-3"
    menu-item m-outs-4 label "Импорт из файла"                   accelerator "alt-4"
    menu-item m-outs-6 label "Импорт артикул поставщик"          accelerator "alt-6"
    menu-item m-outs-7 label "Импорт акцизных марок"             accelerator "alt-7"
    .
ON choose OF MENU-ITEM m-outs-1 IN menu m-outs do:
  run proc-m-outs-1 in this-procedure no-error.
  if error-status :error then do:
    message
    "Ошибка при копировании из документа." skip
    error-status :get-message(1) skip
    return-value
    view-as alert-box.
 end.
 end.
on choose of menu-item m-outs-2 in menu m-outs do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  run proc-m-outs-2 in this-procedure.
end.
on choose of menu-item m-outs-3 in menu m-outs do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  if (t-doc.status_ = 'накл':U or t-doc.status_ = 'запрос':U) and
     not t-doc.flag_ then do:
    run disp-import in this-procedure ( input "import" ).
  end.
  else do:
    run err-status in this-procedure.
    return no-apply.
  end.
end.
on choose of menu-item m-outs-4 in menu m-outs do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  if (t-doc.status_ = 'накл':U or t-doc.status_ = 'запрос':U) and
     not t-doc.flag_ then do:
    run proc-m-outs-4 in this-procedure no-error.
  end.
  else do:
    run err-status in this-procedure.
    return no-apply.
  end.
end.
on choose of menu-item m-outs-6 in menu m-outs do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  if (t-doc.status_ = 'накл':U or t-doc.status_ = 'запрос':U) and
     not t-doc.flag_ then do:
    run proc-m-outs-6 in this-procedure no-error.
  end.
  else do:
    run err-status in this-procedure.
    return no-apply.
  end.
end.
on choose of menu-item m-outs-7 in menu m-outs do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  if (t-doc.status_ = 'накл':U or t-doc.status_ = 'запрос':U)
  then do:
    run proc-m-outs-7 in this-procedure no-error.
  end.
  else do:
    run err-status in this-procedure.
    return no-apply.
  end.
end.
on choose of menu-item m-print-1 in menu m-print do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  if not available t-doc then return .
  define variable v-user-action       as character    no-undo.
  define variable v-printed           as logical      no-undo.
  run rep/tick-doc.p (parparentproc , recid(t-doc), 'trn' , 1 , no, no ) .
end.
on choose of menu-item m-print-3 in menu m-print do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  if not available t-doc then return .
  define variable v-user-action       as character    no-undo.
  define variable v-printed           as logical      no-undo.
  run rep/mbb-doc.p (parparentproc , recid(t-doc), 'trn'  ) no-error .
  if error-status :error then message
    error-status :get-message(1) skip
    return-value skip
    "Вывод в список кодов"
    view-as alert-box error
  .
end.
on choose of menu-item m-print-2 in menu m-print do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
define variable v-user-action       as character    no-undo.
define variable v-printed           as logical      no-undo.
define variable g#report-num        as integer   no-undo .
if not available t-doc then return .
run get-report-num in parparentproc ( output g#report-num ).
run rep/torg-12.p (parparentproc , recid(t-doc), no,'all','no-round', no, no ) .
run gbl/prnfilen.w (
    input "":U
  , input 8
  , input string(
      session :temp-directory)
    + "rpt"
    + string( g#report-num )
    + ( "":U  )
  , input 7
  , output v-user-action
  , output v-printed
) .
end.
on choose of menu-item m-ptrl-1 in menu m-ptrl do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  apply "row-leave" to browse br-dtl.
  run cr-rvs-doc in this-procedure
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
  run UI-on in this-procedure ( input "line" ).
end.
on choose of menu-item m-ptrl-2 in menu m-ptrl do:
  if lookup( self :type in frame d-in-doc, 'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW' ) <> 0 then do:   apply "ENTRY":U to self in frame d-in-doc .   if focus :handle <> self :handle in frame d-in-doc then do:     return no-apply .   end. end.
  define variable v-Param-Type as character no-undo.
  define variable list-pl as character no-undo.
  apply "row-leave" to browse br-dtl.
  run del-rvs-doc in this-procedure
    ( input parparentproc
     ,input t-doc.doc-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при удалении документов сверок.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  else do:
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
      for each ub.doc-pl where
               ub.doc-pl.obj-type = t-doc.obj-type
           and ub.doc-pl.obj-code = t-doc.obj-code
           and ub.doc-pl.out-code = t-doc.doc-code
          no-lock,
          each ub.pl-gds-pump where ub.pl-gds-pump.gds-code = ub.doc-pl.gds-code and
         ub.pl-gds-pump.obj-code = ub.doc-pl.obj-code and
         ub.pl-gds-pump.obj-type = ub.doc-pl.obj-type and
         ub.pl-gds-pump.pl-code = ub.doc-pl.pl-code no-lock,
         each ub.pl-pump-nozzle where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
         ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
         ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
         ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code no-lock:
        list-pl = substitute("&1&2&3:&4:&5", list-pl,
                   if list-pl = "" then "" else ";",
                   ub.pl-pump-nozzle.nozzle-code,
                   ub.pl-pump-nozzle.pump-code,
                   ub.pl-pump-nozzle.pl-code).
      end.
      run unblock-nozzle( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
    end.
  end.
  run UI-on in this-procedure ( input "line" ).
end.
on end-error of  ub.doc-line.cli-qnty in browse br-dtl do:
   display  ub.doc-line.cli-qnty with browse br-dtl.
   return no-apply.
END.
on end-error of  ub.doc-line.fact-qnty in browse br-dtl do:
   display  ub.doc-line.fact-qnty with browse br-dtl.
   return no-apply.
END.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of t-doc.ship-date in frame d-in-doc
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
on delete-character of t-doc.ship-date in frame d-in-doc
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
on ctrl-d of t-doc.ship-date in frame d-in-doc
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
on ctrl-b of t-doc.ship-date in frame d-in-doc
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
on ctrl-e of t-doc.ship-date in frame d-in-doc
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
on ctrl-f of t-doc.ship-date in frame d-in-doc
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
  define MENU m-ed-date52
    MENU-ITEM m-ed-date52-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date52-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date52-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date52-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if t-doc.ship-date :POPUP-MENU in frame d-in-doc = ?
  then do:
    ASSIGN
      t-doc.ship-date :POPUP-MENU in frame d-in-doc = MENU m-ed-date52 :HANDLE
      t-doc.ship-date :MENU-MOUSE in frame d-in-doc = 3
    .
  end.
  define variable v-label-handle52 as handle no-undo .
  assign
    v-label-handle52 = t-doc.ship-date :side-label-handle in frame d-in-doc
  .
  if valid-handle (v-label-handle52)
  then do:
    if v-label-handle52 :tooltip = ""
    or v-label-handle52 :tooltip = ?
    then do:
      assign
        v-label-handle52 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date52-1 in menu m-ed-date52 DO:
    apply "ctrl-b":U to t-doc.ship-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date52-2 in menu m-ed-date52 DO:
    apply "ctrl-d":U to t-doc.ship-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date52-3 in menu m-ed-date52 DO:
    apply "ctrl-e":U to t-doc.ship-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date52-4 in menu m-ed-date52 DO:
    apply "ctrl-f":U to t-doc.ship-date in frame d-in-doc .
  END.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of t-doc.exch-date in frame d-in-doc
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
on delete-character of t-doc.exch-date in frame d-in-doc
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
on ctrl-d of t-doc.exch-date in frame d-in-doc
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
on ctrl-b of t-doc.exch-date in frame d-in-doc
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
on ctrl-e of t-doc.exch-date in frame d-in-doc
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
on ctrl-f of t-doc.exch-date in frame d-in-doc
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
  define MENU m-ed-date54
    MENU-ITEM m-ed-date54-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date54-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date54-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date54-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if t-doc.exch-date :POPUP-MENU in frame d-in-doc = ?
  then do:
    ASSIGN
      t-doc.exch-date :POPUP-MENU in frame d-in-doc = MENU m-ed-date54 :HANDLE
      t-doc.exch-date :MENU-MOUSE in frame d-in-doc = 3
    .
  end.
  define variable v-label-handle54 as handle no-undo .
  assign
    v-label-handle54 = t-doc.exch-date :side-label-handle in frame d-in-doc
  .
  if valid-handle (v-label-handle54)
  then do:
    if v-label-handle54 :tooltip = ""
    or v-label-handle54 :tooltip = ?
    then do:
      assign
        v-label-handle54 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date54-1 in menu m-ed-date54 DO:
    apply "ctrl-b":U to t-doc.exch-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date54-2 in menu m-ed-date54 DO:
    apply "ctrl-d":U to t-doc.exch-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date54-3 in menu m-ed-date54 DO:
    apply "ctrl-e":U to t-doc.exch-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date54-4 in menu m-ed-date54 DO:
    apply "ctrl-f":U to t-doc.exch-date in frame d-in-doc .
  END.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of t-doc.fact-date in frame d-in-doc
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
on delete-character of t-doc.fact-date in frame d-in-doc
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
on ctrl-d of t-doc.fact-date in frame d-in-doc
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
on ctrl-b of t-doc.fact-date in frame d-in-doc
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
on ctrl-e of t-doc.fact-date in frame d-in-doc
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
on ctrl-f of t-doc.fact-date in frame d-in-doc
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
  define MENU m-ed-date56
    MENU-ITEM m-ed-date56-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date56-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date56-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date56-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if t-doc.fact-date :POPUP-MENU in frame d-in-doc = ?
  then do:
    ASSIGN
      t-doc.fact-date :POPUP-MENU in frame d-in-doc = MENU m-ed-date56 :HANDLE
      t-doc.fact-date :MENU-MOUSE in frame d-in-doc = 3
    .
  end.
  define variable v-label-handle56 as handle no-undo .
  assign
    v-label-handle56 = t-doc.fact-date :side-label-handle in frame d-in-doc
  .
  if valid-handle (v-label-handle56)
  then do:
    if v-label-handle56 :tooltip = ""
    or v-label-handle56 :tooltip = ?
    then do:
      assign
        v-label-handle56 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date56-1 in menu m-ed-date56 DO:
    apply "ctrl-b":U to t-doc.fact-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date56-2 in menu m-ed-date56 DO:
    apply "ctrl-d":U to t-doc.fact-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date56-3 in menu m-ed-date56 DO:
    apply "ctrl-e":U to t-doc.fact-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date56-4 in menu m-ed-date56 DO:
    apply "ctrl-f":U to t-doc.fact-date in frame d-in-doc .
  END.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of t-doc.shift-date in frame d-in-doc
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
on delete-character of t-doc.shift-date in frame d-in-doc
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
on ctrl-d of t-doc.shift-date in frame d-in-doc
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
on ctrl-b of t-doc.shift-date in frame d-in-doc
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
on ctrl-e of t-doc.shift-date in frame d-in-doc
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
on ctrl-f of t-doc.shift-date in frame d-in-doc
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
  define MENU m-ed-date58
    MENU-ITEM m-ed-date58-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date58-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date58-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date58-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if t-doc.shift-date :POPUP-MENU in frame d-in-doc = ?
  then do:
    ASSIGN
      t-doc.shift-date :POPUP-MENU in frame d-in-doc = MENU m-ed-date58 :HANDLE
      t-doc.shift-date :MENU-MOUSE in frame d-in-doc = 3
    .
  end.
  define variable v-label-handle58 as handle no-undo .
  assign
    v-label-handle58 = t-doc.shift-date :side-label-handle in frame d-in-doc
  .
  if valid-handle (v-label-handle58)
  then do:
    if v-label-handle58 :tooltip = ""
    or v-label-handle58 :tooltip = ?
    then do:
      assign
        v-label-handle58 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date58-1 in menu m-ed-date58 DO:
    apply "ctrl-b":U to t-doc.shift-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date58-2 in menu m-ed-date58 DO:
    apply "ctrl-d":U to t-doc.shift-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date58-3 in menu m-ed-date58 DO:
    apply "ctrl-e":U to t-doc.shift-date in frame d-in-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date58-4 in menu m-ed-date58 DO:
    apply "ctrl-f":U to t-doc.shift-date in frame d-in-doc .
  END.
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-in-doc anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-in-doc. END.
  return no-apply.
end.
assign
  frame d-in-doc:scrollable                           = false
  br-dtl:num-locked-columns in frame d-in-doc = 5
  r-outs:popup-menu in frame d-in-doc                 = menu m-outs:handle
  r-outs:menu-mouse                                        = 1
  b-revis:popup-menu in frame d-in-doc                = menu m-ptrl:handle
  b-revis:menu-mouse                                       = 1
  rsn-name:tooltip in frame d-in-doc = "Основание (причина) создания документа"
.
 t-doc.SLT-type:LIST-ITEMS =  'без':U + "," + 'нет':U + "," + 'в т. ч.':U .
 t-doc.VAT-type:LIST-ITEMS =  'нет':U + "," + 'в т. ч.':U + "," + 'без':U .
run tax-name in this-procedure ( input 'rdt':U, output rdtaxname ).
assign
  t-doc.road-tax :label in frame d-in-doc = rdtaxname
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'mercuri':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-mercury-value
  ,output v-mercury-type
  ) no-error .
if v-mercury-value ne "no" and v-mercury-value ne "" and v-mercury-value ne ?
then do:
  v-is-mercury-value = true.
  vsdstrObj = new vsdtostorage ().
end.
hbrowse = browse br-dtl:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).
  bcol[ii] = hbrowse:get-browse-column (ii).
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-ptrl
  ,output v-data-type
  ) no-error .
if error-status :error or v-data-type <> "L" or lookup( v-is-ptrl, "yes,no" ) = 0 then do:
  assign
    v-is-ptrl = "no"
  .
end.
assign
  d-kg-after-qnty :visible in browse br-dtl = ( v-is-ptrl = "yes" )
  d-kg-fact-qnty  :visible in browse br-dtl = ( v-is-ptrl = "yes" )
  d-kg-price-base :visible in browse br-dtl = ( v-is-ptrl = "yes" )
  d-kg-price-rubl :visible in browse br-dtl = ( v-is-ptrl = "yes" )
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'gtd-part'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-gtd-part
  ,output v-is-gtd-part-type
  ) no-error .
assign
  d-gtd-add :visible in browse br-dtl = ( v-is-gtd-part = "yes" )
.
def var sort-labelbr-dtl   as character no-undo .
def var sort-clmnbr-dtl    as handle    no-undo .
def var cur-clmnbr-dtl     as handle    no-undo .
def var cur-clmn-locbr-dtl as integer   no-undo .
def var re-querybr-dtl     as logical   initial no no-undo .
on start-search, ctrl-o of br-dtl in frame d-in-doc do:
   run sort-brbr-dtl
     (input (if available doc-line
             then recid(doc-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-dtl :
  define input parameter p-recid as recid no-undo .
  if re-querybr-dtl = no then do:
    assign
       cur-clmnbr-dtl = br-dtl:current-column in frame d-in-doc
    .
    if sort-clmnbr-dtl <> ? then sort-clmnbr-dtl:column-fgcolor = 0.
    if cur-clmnbr-dtl = sort-clmnbr-dtl then do:
      assign
         sort-labelbr-dtl = ""
         sort-clmnbr-dtl = ?
      .
     end.
     else do:
       assign
         sort-labelbr-dtl = cur-clmnbr-dtl:label
         sort-clmnbr-dtl  = cur-clmnbr-dtl
         sort-clmnbr-dtl:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-dtl = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-dtl:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-dtl then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-dtl = cur-clmn-locbr-dtl + 1
    .
  end.
  case sort-labelbr-dtl:
        when '*'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by get-mark  (BUFFER  ub.doc-line) .   . END.
        when 'П/П'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.line-num .   . END.
        when 'Ш'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.prt-OK .   . END.
        when 'Артикул'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.artic .   . END.
        when 'Название'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.goods.gds-name .   . END.
        when 'По ТТН'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.cli-qnty .   . END.
        when 'Изм'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.unit-cli .   . END.
        when 'Цена пост.'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.price-cli .   . END.
        when 'Сумма пост.'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ( ub.doc-line.cli-qnty *  ub.doc-line.price-cli) .   . END.
        when 'По док-ту'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.doc-qnty .   . END.
        when 'Факт'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.fact-qnty .   . END.
        when 'Изм.'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.goods.unit-base .   . END.
        when 'Цена учет(прод.)'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by (if varr-b = 'rubl':u then  ub.doc-line.price-rubl else  ub.doc-line.price-base) .   . END.
        when 'Цена продажи'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.gds-obj.price-sale .   . END.
        when '%'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by (if varr-b = 'rubl':u then ((ub.gds-obj.price-sale -  ub.doc-line.price-rubl) /  ub.doc-line.price-rubl * 100) else ((ub.gds-obj.price-sale -  ub.doc-line.price-base) /  ub.doc-line.price-base * 100)) .   . END.
        when 'Шкала'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by get-name (BUFFER  ub.doc-line, buffer ub.goods, buffer ub.gds-prt) .   . END.
        when 'НДС'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.VAT-pc .   . END.
        when 'Название англ.'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.goods.engl-name .   . END.
        when 'Кол-во мест'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.num-place .   . END.
        when 'Вес брутто'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.wt-brutto .   . END.
        when 'Кол в там. ед.'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by ub.doc-line.fact-qnty * ub.goods.cst-base-rate .   . END.
        when 'Прих. цена'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by last-price (buffer  ub.doc-line) .   . END.
        when '% откл прих. цены'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by deviation-price (buffer  ub.doc-line) .   . END.
        when 'Факт, кг'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by get-kg-fact-qnty(  buffer  ub.doc-line ) .   . END.
        when 'Цена за кг (вал.)'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by get-kg-sale-base(  buffer  ub.doc-line ) .   . END.
        when 'Цена за кг (руб.)'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by get-kg-sale-rubl(  buffer  ub.doc-line ) .   . END.
        when 'Итого, кг'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by get-kg-after-qnty( buffer  ub.doc-line ) .   . END.
        when 'Доп. к ГТД'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by get-add-gtd( buffer ub.doc-line ) .   . END.
        when 'Причина отклонения по РТ'  then DO:   sort-default = no. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK by lineattr-get-reason( buffer ub.doc-line ) .   . END.
    otherwise do:
      sort-default = yes. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK BY  ub.doc-line.line-num. .
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-dtl') then do:
          run mv-brw-defaultbr-dtl.
        end.
      if sort-labelbr-dtl <> "" then do:
        assign
          cur-clmnbr-dtl:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-dtl = ?
      .
    end.
  end case.
    if cur-clmn-locbr-dtl <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-dtl') then do:
        run ch-clmnbr-dtl in this-procedure (cur-clmn-locbr-dtl).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-dtl to recid p-recid no-error.
    apply "value-changed" to br-dtl in frame d-in-doc.
  end.
  apply "entry" to br-dtl in frame d-in-doc.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-dtl:
if cur-clmnbr-dtl = ? then do:
   sort-default = yes. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK BY  ub.doc-line.line-num. .
end.
else do:
   assign re-querybr-dtl = yes.
   run sort-brbr-dtl
     (input (if available doc-line
             then recid(doc-line)
             else ?
            )
     ).
   assign re-querybr-dtl = no.
end.
end.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable result as LOGICAL NO-UNDO.
ON ctrl-cursor-up OF browse br-dtl do:
   RUN change-line-num("up", output result).
   IF result THEN DO:
      sort-default = yes. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK BY  ub.doc-line.line-num.
      reposition br-dtl to recid line-rec no-error.
   END.
END.
ON ctrl-cursor-down OF browse br-dtl do:
   RUN change-line-num("down", output result).
   IF result THEN DO:
      sort-default = yes. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK BY  ub.doc-line.line-num.
      reposition br-dtl to recid line-rec no-error.
   END.
END.
PROCEDURE change-line-num:
define input parameter par-up-down as char no-undo.
define output parameter parresult as log initial no no-undo.
define variable source-doc-line-num as integer   no-undo .
define buffer   source-doc-line     for ub.doc-line.
define variable varlog as logical no-undo.
IF AVAILABLE doc-line THEN DO:
   ASSIGN line-rec = RECID(doc-line).
   if sort-default = NO THEN DO:
        ASSIGN varlog = NO.
        MESSAGE "Отсортировано не по порядку ввода в накладную."
                "Отмените сортировку!"
        VIEW-AS ALERT-BOX ERROR TITLE "Ошибка при изменении порядка ввода в накладную".
   END.
   ASSIGN source-doc-line-num = doc-line.line-num.
   FIND FIRST source-doc-line WHERE RECID(source-doc-line) = RECID(doc-line)
   EXCLUSIVE-LOCK.
   if par-up-down = "up" then GET PREV br-dtl EXCLUSIVE-LOCK.
                         else GET NEXT br-dtl EXCLUSIVE-LOCK.
   IF AVAILABLE doc-line THEN DO:
      ASSIGN source-doc-line.line-num = doc-line.line-num
             doc-line.line-num        = source-doc-line-num.
      ASSIGN parresult = YES.
   END.
END.
ELSE MESSAGE "Линия выбрана неправильно."
     VIEW-AS ALERT-BOX INFO BUTTONS OK.
END PROCEDURE.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-dtl as INT EXTENT 29 no-undo.
DEF VAR varmvibr-dtl       as INT no-undo.
DEF VAR varmvjbr-dtl       as INT no-undo.
DEF VAR varmvkbr-dtl       as INT no-undo.
DEF VAR varmvlbr-dtl       as INT no-undo.
DEF VAR move-elementbr-dtl as INT no-undo.
def var jjbr-dtl           as int no-undo.
do varmvibr-dtl = 1 to EXTENT(cur-clmn-numbr-dtl):
  ASSIGN cur-clmn-numbr-dtl[varmvibr-dtl] = varmvibr-dtl.
END.
RUN start-mv-clmnbr-dtl.
PROCEDURE start-mv-clmnbr-dtl:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-dtl do:
  RUN re-move-clmnbr-dtl ( 5, 29).
END.
ON ctrl-cursor-left OF BROWSE br-dtl do:
  RUN re-move-clmnbr-dtl (29, 5).
END.
PROCEDURE re-move-clmnbr-dtl:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
    if cur-clmn-numbr-dtl[varmvibr-dtl] = source-column THEN cur-clmn-numbr-dtl[varmvibr-dtl] = -1.
  END.
  if br-dtl:MOVE-COLUMN(source-column, target-column) IN FRAME d-in-doc then.
  if source-column > target-column THEN
  DO varmvjbr-dtl = source-column - 1 to target-column BY -1:
    DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
        if cur-clmn-numbr-dtl[varmvibr-dtl] = varmvjbr-dtl THEN DO:
          cur-clmn-numbr-dtl[varmvibr-dtl] = cur-clmn-numbr-dtl[varmvibr-dtl] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-dtl = source-column + 1 to target-column:
    DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
      if cur-clmn-numbr-dtl[varmvibr-dtl] = varmvjbr-dtl THEN DO:
        cur-clmn-numbr-dtl[varmvibr-dtl] = cur-clmn-numbr-dtl[varmvibr-dtl] - 1.
      END.
    END.
  END.
  DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
    if cur-clmn-numbr-dtl[varmvibr-dtl] = -1 THEN cur-clmn-numbr-dtl[varmvibr-dtl] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-dtl:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 5 then do:
    return .
  end.
  DO varmvibr-dtl = 1 TO EXTENT(cur-clmn-numbr-dtl):
    if cur-clmn-numbr-dtl[varmvibr-dtl] = cur-clmn-loc THEN move-elementbr-dtl = varmvibr-dtl.
  END.
  RUN re-move-clmnbr-dtl (cur-clmn-loc, 5).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-dtl:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-dtl = 5 to EXTENT(cur-clmn-numbr-dtl):
    RUN re-move-clmnbr-dtl (cur-clmn-numbr-dtl[varmvlbr-dtl], varmvlbr-dtl).
  END.
  RUN start-mv-clmnbr-dtl.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-in-doc anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-dtl in frame d-in-doc.
  return no-apply.
end.
on F12 of frame d-in-doc anywhere do:
  if v-is-gtd-part = "yes" then run gtd-line in this-procedure .
  return no-apply.
END.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      vss-include-info64 skip
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
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-in-doc anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-in-doc. END.
  return no-apply.
end.
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-in-doc anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-in-doc. END.
  return no-apply.
end.
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-in-doc anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-in-doc. END.
  return no-apply.
end.
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-in-doc anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-in-doc. END.
  return no-apply.
end.
ON CHOOSE OF b-next IN FRAME d-in-doc
DO:
  RUN step-next in this-procedure .
END.
procedure step-next:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case t-doc.doc-type:
  when 'при':U then
    cur-form = if t-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-next-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это последний документ списка.".
end.
case new_trn-doc.doc-type:
  when 'при':U then
    new-form = if new_trn-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
    pardoc-rec   = bf-handle:recid
    parnext-prev = ( cur-form = new-form ) .
end procedure.
ON CHOOSE OF b-prev IN FRAME d-in-doc
DO:
  run step-prev in this-procedure .
END.
procedure step-prev:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case t-doc.doc-type:
  when 'при':U then if t-doc.internal then cur-form = 'рас':U. else cur-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-prev-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это первый документ списка.".
end.
case new_trn-doc.doc-type :
  when 'при':U then if new_trn-doc.internal then new-form = 'рас':U. else new-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then  new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
  pardoc-rec   = bf-handle:recid
  parnext-prev = (cur-form = new-form)
.
end procedure.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-clients :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .
define variable v-veto-man-doc as character no-undo .
define variable v-type        as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
run clntattr-value in this-procedure (
 input p-obj-type ,
 input p-obj-code ,
 input 'veto-man-doc':U     ,
 output v-veto-man-doc ,
 output v-type        ) no-error .
 if error-status :error then message
   error-status :get-message(1) skip
   return-value skip
   "Ошибка clntattr-veto-man-doc"
   view-as alert-box error
 .
  if v-veto-man-doc = 'ALL' then do:
      message "Запрещено создание документа на этого контрагента оператору вручную." view-as alert-box error  .
      p-error = true .
  end.
 end.
end procedure.
on end-error, stop of frame d-in-doc do:
  apply "choose" to b-exit in frame d-in-doc.
  return no-apply.
end.
on choose of b-notes in frame d-in-doc run notes-tr.
on choose of b-history   in frame d-in-doc do:
  run proc-history in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-exit  in frame d-in-doc
do:
  run proc-exit no-error.
  if error-status :error then do: return no-apply. end.
end.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.agnt IN FRAME d-in-doc
DO:
  run local-psn-chk ("agnt", "ret-mouse").
  apply "entry" to t-doc.boss in frame d-in-doc.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.boss IN FRAME d-in-doc
DO:
  RUN local-psn-chk ("boss", "ret-mouse").
  apply "entry" to b-exit in frame d-in-doc.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.wrkr IN FRAME d-in-doc
DO:
  RUN local-psn-chk ("wrkr", "ret-mouse").
  apply "entry" to t-doc.agnt in frame d-in-doc.
  return no-apply.
END.
ON CHOOSE OF r-agnt IN FRAME d-in-doc
DO:
  RUN local-psn-chk ("agnt", "button").
  apply "entry" to t-doc.boss in frame d-in-doc.
  return no-apply.
END.
ON CHOOSE OF r-boss IN FRAME d-in-doc
DO:
  RUN local-psn-chk ("boss", "button").
  apply "entry" to b-exit in frame d-in-doc.
  return no-apply.
END.
ON CHOOSE OF r-wrkr IN FRAME d-in-doc
DO:
  run local-psn-chk ("wrkr", "button").
  apply "entry" to t-doc.agnt in frame d-in-doc.
  return no-apply.
END.
on leave of t-doc.agnt in frame d-in-doc  do:
  if not available t-doc then return .
  if input frame d-in-doc t-doc.agnt <> t-doc.agnt then do:
    run local-psn-chk ("agnt", "leave").
  end.
end.
on leave of t-doc.boss in frame d-in-doc   do:
  if not available t-doc then return .
  if input frame d-in-doc t-doc.boss <> t-doc.boss then do:
    run local-psn-chk ("boss", "leave").
  end.
end.
on leave of t-doc.wrkr in frame d-in-doc  do:
  if not available t-doc then return .
  if input frame d-in-doc t-doc.wrkr <> t-doc.wrkr then do:
    run local-psn-chk ("wrkr", "leave").
  end.
end.
procedure local-psn-chk :
  define input parameter parman    as character no-undo.
  define input parameter paraction as character no-undo.
  if parman = "agnt" and paraction = "ret-mouse" then do:
  define variable v-ref-rec71   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-in-doc t-doc.agnt <> ""
       and input frame d-in-doc t-doc.agnt <> ? then
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
    assign v-ref-rec71 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-in-doc.
    assign frame d-in-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt
               ? @ agnt-name with frame d-in-doc.
  apply "entry" to t-doc.boss
                            in frame d-in-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-in-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-in-doc.
      return no-apply.
  end.
  if parman = "agnt" and paraction = "button" then do:
  define variable v-ref-rec72   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec72 = ( if available cli-buf then recid( cli-buf ) else ? ).
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
    assign v-ref-rec72 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-in-doc.
    assign frame d-in-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt
               ? @ agnt-name with frame d-in-doc.
  apply "entry" to t-doc.boss
                            in frame d-in-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-in-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-in-doc.
      return no-apply.
  end.
  if parman = "agnt" and paraction = "leave" then do:
  define variable v-ref-rec73   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-in-doc.
          assign frame d-in-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-in-doc.
  end.
  if parman = "boss" and paraction = "ret-mouse" then do:
  define variable v-ref-rec74   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-in-doc t-doc.boss <> ""
       and input frame d-in-doc t-doc.boss <> ? then
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
    assign v-ref-rec74 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.boss
            cli-buf.obj-name @ boss-name with frame d-in-doc.
    assign frame d-in-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss
               ? @ boss-name with frame d-in-doc.
  apply "entry" to  b-exit in frame d-in-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-in-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-in-doc.
      return no-apply.
  end.
  if parman = "boss" and paraction = "button" then do:
  define variable v-ref-rec75   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec75 = ( if available cli-buf then recid( cli-buf ) else ? ).
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
    assign v-ref-rec75 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.boss
            cli-buf.obj-name @ boss-name with frame d-in-doc.
    assign frame d-in-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss
               ? @ boss-name with frame d-in-doc.
  apply "entry" to  b-exit in frame d-in-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-in-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-in-doc.
      return no-apply.
  end.
  if parman = "boss" and paraction = "leave" then do:
  define variable v-ref-rec76   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-in-doc.
          assign frame d-in-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-in-doc.
  end.
  if parman = "wrkr" and paraction = "ret-mouse" then do:
  define variable v-ref-rec77   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-in-doc t-doc.wrkr <> ""
       and input frame d-in-doc t-doc.wrkr <> ? then
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
    assign v-ref-rec77 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-in-doc.
    assign frame d-in-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr
               ? @ wrkr-name with frame d-in-doc.
  apply "entry" to t-doc.agnt in frame d-in-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-in-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-in-doc.
      return no-apply.
  end.
  if parman = "wrkr" and paraction = "button" then do:
  define variable v-ref-rec78   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec78 = ( if available cli-buf then recid( cli-buf ) else ? ).
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
    assign v-ref-rec78 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-in-doc.
    assign frame d-in-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr
               ? @ wrkr-name with frame d-in-doc.
  apply "entry" to t-doc.agnt in frame d-in-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-in-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-in-doc.
      return no-apply.
  end.
  if parman = "wrkr" and paraction = "leave" then do:
  define variable v-ref-rec79   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-in-doc.
          assign frame d-in-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-in-doc.
  end.
end procedure.
on entry of t-doc.cli-code, r-clients in frame d-in-doc
DO:
if t-doc.ret-supp = yes and
  can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) then do:
    message "Уже есть строки возврата. Изменение контрагента невозможно."
    view-as alert-box error buttons ok.
    apply "entry" to browse br-dtl.
    return no-apply.
end.
if t-doc.cli-code <> ? then do:
  pardoc-mode = 'ДОБАВЛЕНИЕ':U.
  run UI-on ("enable").
end.
end.
on leave of t-doc.pay-code in frame d-in-doc
do:
if input frame d-in-doc t-doc.pay-code <> t-doc.pay-code then do:
  run leave-pay-code no-error.
  if error-status :error then return no-apply.
end.
end.
on leave of t-doc.doc-date in frame d-in-doc do:
if input frame d-in-doc t-doc.doc-date <> t-doc.doc-date then do:
  assign
    t-doc.doc-date = input frame d-in-doc t-doc.doc-date.
end.
end.
on mouse-select-dblclick, return of t-doc.pay-code in frame d-in-doc
do:
if input frame d-in-doc t-doc.pay-code <> t-doc.pay-code then do:
  run return-pay-code no-error.
  if error-status :error then return no-apply.
end.
apply "entry" to t-doc.wrkr in frame d-in-doc.
return no-apply.
end.
on choose of r-pay in frame d-in-doc
do:
  run choose-r-pay no-error.
  if error-status :error then return no-apply.
end.
on return, mouse-select-dblclick of br-dtl in frame d-in-doc
do:
  if b-chg:sensitive then do:
    apply "choose" to b-chg in frame d-in-doc.
  end.
  else do:
    apply "choose" to b-lkp in frame d-in-doc.
  end.
end.
on choose of r-acc in frame d-in-doc
do:
  run choose-r-acc no-error.
  if error-status :error then return no-apply.
end.
procedure choose-r-acc:
define variable v-today      as date    no-undo.
define variable varbase-code as integer no-undo.
run check-update no-error.
if error-status :error then return error.
run check-exch no-error.
if error-status :error then return error.
varlog = yes.
message "Подставить БИРЖЕВЫЕ курсы базовой валюты :" base-abbr "и валюты поставщика :"
        ub.currency.curr-abbr "на дату растаможивания ?"
view-as alert-box question buttons OK-Cancel update varlog.
if varlog <> true then do:
  return error.
end.
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output varbase-code
  )  .
find last ub.curr-accnt where ub.curr-accnt.curr-code = varbase-code and
                         ub.curr-accnt.exch-date <= input frame d-in-doc t-doc.exch-date use-index pi no-lock no-error.
if not available ub.curr-accnt then do:
  message "На эту дату неизвестен курс базовой валюты.".
  apply "entry" to t-doc.base-rate in frame d-in-doc.
  return error.
end.
disp ub.curr-accnt.exch-rate  @ t-doc.base-rate
     ub.curr-accnt.exch-scale @ t-doc.base-scale with frame d-in-doc.
run check-rate.
find last ub.curr-accnt where ub.curr-accnt.curr-code = input t-doc.exch-code
          and ub.curr-accnt.exch-date <= input t-doc.exch-date use-index pi no-lock no-error.
if not available ub.curr-accnt then do:
  message "На дату " + input t-doc.exch-date + " неизвестен курс валюты поставщика.".
  apply "entry" to t-doc.exch-rate.
  return error.
end.
display ub.curr-accnt.exch-rate  @ t-doc.exch-rate
        ub.curr-accnt.exch-scale @ t-doc.exch-scale with frame d-in-doc.
run check-rate.
run UI-on ("line").
end procedure.
on mouse-select-dblclick, return of t-doc.cli-code, t-doc.cli-type
  in frame d-in-doc
do:
  run choose-cli in this-procedure no-error.
  if error-status :error then do:
    display ? @ t-doc.cli-type ? @ t-doc.cli-code with frame d-in-doc.
  end.
  return no-apply.
end.
on choose of r-clients in frame d-in-doc
do:
define variable varfirm-code like ub.firm.firm-code no-undo.
define variable v-rid-list as character no-undo .
define variable v-types as character no-undo .
define buffer bf_clients for ub.clients.
if t-doc.internal then v-types = 'маг':U.
                  else v-types = 'все':U.
if (t-doc.ext-doc-type = 'ee':U or t-doc.ext-doc-type = 'ep':U) and
   varhold            = "yes"              and
   paris-hold         = yes                then do:
  assign
    varfirm-code = ?.
  run adm/sconfs.w ( input parparentproc
                   , input "b-sel":U
                   , input no
                   , input ?
                   , output varfirm-code
                   , input-output v-rid-list) no-error.
  if error-status :error or
     varfirm-code = ?   then do:
    return no-apply.
  end.
  find first bf_clients where bf_clients.obj-type = 'орг':U       and
                              bf_clients.obj-code = varfirm-code no-lock.
  assign ref-list = string(recid (bf_clients)).
  run check-base-code in this-procedure (recid(bf_clients)).
end.
else do:
  if transaction = yes then do:
    message "Критическая ошибка." skip
            "Вы находитесь в транзакции." skip
            "Работа со справочником клиентов невозможна."
    view-as alert-box error.
    return no-apply.
  end.
  def var supp-type as character no-undo.
  case trn-type:
    when 1 then supp-type = "supp-np".
    when 2 then supp-type = "supp-lgas".
    when 3 then supp-type = "supp-lgas".
  end case.
  run ref/cli-all.w (parparentproc
                , "b-sel,b-add"
                , v-types
                , ?
                , ?
                , ?
                , ?
                , supp-type
                , output ref-list) .
end.
if ref-list <> "" then do:
  ref-rec = integer (ref-list).
  find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
  disp ub.clients.obj-code @ t-doc.cli-code
          ub.clients.obj-name with frame d-in-doc.
  disp ub.clients.obj-type @ t-doc.cli-type with frame d-in-doc.
end.
if trn-type = 1
then do :
  define variable v-tmp-char like ub.thbj-attr.property-value-character no-undo .
  define variable v-tmp-date      like ub.thbj-attr.property-value-date    no-undo .
  define variable v-tmp-decimal   like ub.thbj-attr.property-value-decimal no-undo .
  define variable v-tmp-integer   like ub.thbj-attr.property-value-integer no-undo .
  define variable v-rvd-own-nb as logical no-undo .
  define variable v-rvd-own-nb-type as   character no-undo .
  find ub.clients where ub.clients.obj-code = input frame d-in-doc t-doc.cli-code
               and ub.clients.obj-type = input frame d-in-doc t-doc.cli-type no-error.
  if not available ub.clients then do:
    if input frame d-in-doc t-doc.cli-code <> ? and input t-doc.cli-type <> ? then
      message "Неправильный код или тип контрагента.".
    apply "entry" to t-doc.cli-code in frame d-in-doc.
    return no-apply .
  end.
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input 'petrol':U
      ,input  "rvd-own-nb"
      ,output v-tmp-char
      ,output v-tmp-date
      ,output v-tmp-decimal
      ,output v-tmp-integer
      ,output v-rvd-own-nb
      ,output v-rvd-own-nb-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  if error-status :error then v-rvd-own-nb = false .
  if v-rvd-own-nb = false
  then do :
    find first ub.clients-attr no-lock where ub.clients-attr.obj-type = ub.clients.obj-type
                                         and ub.clients-attr.obj-code = ub.clients.obj-code
                                         and ub.clients-attr.attr-code = 'owner-code':U
                                         no-error .
    if available ub.clients-attr
    and ub.clients-attr.attr-value > ""
    then do :
      if ub.clients-attr.attr-value = "орг" + string(t-doc.host-code)
      then do :
        message "Для данного поставщика документ может быть заполнен только в автоматическом режиме путем сканирования 2D кода. Просканируйте код с ТТН, при возникновении проблемы обратитесь в тех. поддержку".
        run str/trnscanqr.w (parparentproc, t-doc.doc-code, "", this-procedure).
        return no-apply .
      end .
    end .
  end .
end .
run check-cli no-error.
if error-status :error then return no-apply.
run fill-mol in this-procedure.
if error-status :error then return no-apply.
end.
procedure check-cli :
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_sysconf      for ub.sysconf.
define buffer buf_firm         for ub.firm.
define buffer in-cli           for ub.trn-doc.
define buffer buf-hold_clients for ub.clients.
define buffer buf-hold_shop    for ub.shop.
define buffer buf-hold_store   for ub.store.
define buffer bf_clients       for ub.clients.
define buffer bf_contract      for ub.contract.
define buffer buf_contract-attr for ub.contract-attr.
define buffer bf_currency      for ub.currency.
define buffer buf_trn-reason   for ub.trn-reason.
define variable varexch-rate     like ub.trn-doc.exch-rate            no-undo.
define variable varexch-scale    like ub.trn-doc.exch-scale           no-undo.
define variable varcurr-abbr     as   character                       no-undo.
define variable parhold-obj-type like ub.firm.main-obj-type           no-undo.
define variable parhold-obj-code like ub.firm.main-obj-code initial ? no-undo.
define variable varcontract-code like ub.contract.contract-code       no-undo.
define variable varr-b           as   character                       no-undo.
define variable varis-fin        as   character                       no-undo.
define variable varis-finby      as   character                       no-undo.
define variable vartype          as   character                       no-undo.
define variable varcontract      as   character                       no-undo.
define variable varcontract-cli  as   character                       no-undo.
define variable varcontract-type  as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date      like ub.thbj-attr.property-value-date    no-undo .
define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
define variable v-tth as handle no-undo .
define variable v-tth1 as handle no-undo .
define variable varintprmvq      as logical   no-undo .
define variable varintprmvq-type as   character                       no-undo.
define variable v-num            as   integer       initial 1         no-undo.
define variable varis-perm       as   logical       initial no        no-undo.
define buffer bf-f_contract-specif    for ub.contract-specif.
define variable v-master as character no-undo.
define variable trn-is-return          as logical   no-undo init no .
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
define buffer bf_shop for ub.shop.
do on error undo, return error return-value :
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varis-fin
  ,output vartype
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-finby'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varis-finby
  ,output vartype
  ) no-error .
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input 'nakl_par':U
      ,input  "intprmvq"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output varintprmvq
      ,output varintprmvq-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then varintprmvq = false .
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-today
  )  .
assign
  t-doc.exch-date     = v-today
  t-doc.exch-code     = 0
  t-doc.exch-rate     = 1
  t-doc.exch-scale    = 1
  t-doc.print-rubl    = yes.
if input frame d-in-doc t-doc.cli-type = ? or input frame d-in-doc t-doc.cli-type = "" then do:
  if t-doc.internal then do:
    if can-find (ub.clients where ub.clients.obj-code = input frame d-in-doc t-doc.cli-code
                                     and ub.clients.obj-type = 'скл':U no-lock) then do:
      disp 'скл':U @ t-doc.cli-type with frame d-in-doc.
    end.
    else do:
      disp 'маг':U @ t-doc.cli-type with frame d-in-doc.
    end.
  end.
  else do:
    if can-find (ub.clients where ub.clients.obj-code = input frame d-in-doc t-doc.cli-code
                                     and ub.clients.obj-type = 'орг':U no-lock) then do:
      disp 'орг':U @ t-doc.cli-type with frame d-in-doc.
    end.
    else do:
      disp 'чел':U @ t-doc.cli-type with frame d-in-doc.
    end.
  end.
end.
define variable conf-par as character no-undo.
define variable mode-erprn as logical no-undo.
define variable par-type as character no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
  else mode-erprn = no.
find ub.clients where ub.clients.obj-code = input frame d-in-doc t-doc.cli-code
               and ub.clients.obj-type = input frame d-in-doc t-doc.cli-type no-error.
if not available ub.clients then do:
  if input frame d-in-doc t-doc.cli-code <> ? and input t-doc.cli-type <> ? then
    message "Неправильный код или тип контрагента.".
  apply "entry" to t-doc.cli-code in frame d-in-doc.
  return error.
end.
disp ub.clients.obj-type @ t-doc.cli-type with frame d-in-doc.
if (ub.clients.obj-type = v-cntxt-obj-type and ub.clients.obj-code = v-cntxt-obj-code) or
   (ub.clients.obj-type = 'орг':U and ub.clients.obj-code = v-cntxt-host-code-obj) then do:
  release ub.clients no-error.
  message "Запрещенный код и тип контрагента.".
  apply "entry" to t-doc.cli-code in frame d-in-doc.
  return error.
end.
if ub.clients.stts <> 0 then do:
 message "Данный клиент имеет статус 'неактивный'.".
 apply "entry" to t-doc.cli-code in frame d-in-doc.
 return error.
end.
define variable v-err as logical   no-undo .
  run ver-clients  ( ub.clients.obj-type , ub.clients.obj-code , output v-err ) .
  if  v-err then do:
  apply "entry" to t-doc.cli-code in frame d-in-doc.
  return error.
  end.
if lookup(ub.clients.obj-type, 'скл':U + ',' + 'маг':U) > 0
then do:
  if t-doc.internal then do:
    if ub.clients.obj-type = 'скл':U then do:
      find ub.store where ub.store.obj-code = ub.clients.obj-code no-lock.
      if ub.store.host-code <> v-cntxt-host-code-obj then do:
        release ub.clients no-error.
        message "Выбран склад другой фирмы. Используйте внешний документ.".
        apply "entry" to t-doc.cli-code in frame d-in-doc.
        return error.
      end.
    end.
    else do:
      find ub.shop where ub.shop.obj-code = ub.clients.obj-code no-lock.
      if ub.shop.host-code <> v-cntxt-host-code-obj then do:
        release ub.clients no-error.
        message "Выбран магазин другой фирмы. Используйте внешний документ.".
        apply "entry" to t-doc.cli-code in frame d-in-doc.
        return error.
      end.
    end.
  end.
  else do:
    release ub.clients no-error.
    message "Это не внутреннее перемещение. Выберите организацию или человека.".
    apply "entry" to t-doc.cli-code in frame d-in-doc.
    return error.
  end.
end.
else do:
  if t-doc.internal then do:
    release ub.clients no-error.
    message "Вы заполняете внутреннее перемещение. Выберите склад или магазин.".
    apply "entry" to t-doc.cli-code in frame d-in-doc.
    return error.
  end.
end.
   if trn-type = 4 then varvalue = "yes" .
   else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'trn-is-gds':U ,
                       output varvalue ,
                       output vartype ) no-error .
      if varvalue = "no" then do:
      if can-find (FIRST ub.clients-attr no-lock where (ub.clients-attr.attr-code = 'supp-np':U or ub.clients-attr.attr-code = 'supp-lgas':U)
                                                and ub.clients-attr.attr-value = "yes") then varvalue = "no" . else varvalue = "yes" .
      end.
      end.
   if varvalue = "yes" or varvalue = "" then
   do:
      run adm/shattri.p (
         input "get":U
         ,input t-doc.obj-type
         ,input t-doc.obj-code
         ,input 'contr-in':U
         ,input ( if t-doc.ext-doc-type = 'ee':U  then  "contr-in-expense" else "contr-in-income" )
         ,output v-value-character
         ,output v-value-date
         ,output v-value-decimal
         ,output v-value-integer
         ,output v-value-logical
         ,output varcontract-type
         ,INPUT-OUTPUT TABLE-handle v-tth1
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
   else
   do:
      run adm/shattri.p (
         input "get":U
         ,input t-doc.obj-type
         ,input t-doc.obj-code
         ,input 'contr-in':U
         ,input ( if t-doc.ext-doc-type = 'ee':U  then  "contr-in-expense-NP" else "contr-in-income-NP" )
         ,output v-value-character
         ,output v-value-date
         ,output v-value-decimal
         ,output v-value-integer
         ,output v-value-logical
         ,output varcontract-type
         ,INPUT-OUTPUT TABLE-handle v-tth1
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
      delete object v-tth1.
      if v-value-logical = true then varcontract = "yes" .
                                else varcontract = "no" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-return':U ,
                       output varvalue ,
                       output vartype ) no-error .
if varvalue = "yes"
then do :
  trn-is-return = yes .
end .
if ( varis-fin = "yes":u
 and ( t-doc.ext-doc-type = 'ie':U or
       t-doc.ext-doc-type = 'ep':U or
   ( t-doc.ext-doc-type = 'ee':U and (paris-hold = true or mode-erprn = true or trn-is-return = true) ) or
     ( t-doc.ext-doc-type = 're':U and (paris-hold = true or mode-erprn = true)   )))
  or ( varis-finby = "yes":u
  and ( t-doc.ext-doc-type = 'ee':U      or
        t-doc.ext-doc-type = 'ep':U or
        t-doc.ext-doc-type = 're':U  or
      ( t-doc.ext-doc-type = 'ee':U  and paris-hold = true )))
  then do:
    find first bf_contract where bf_contract.host-code = t-doc.host-code                          and
                                 bf_contract.cli-type  = input frame d-in-doc t-doc.cli-type and
                                 bf_contract.cli-code  = input frame d-in-doc t-doc.cli-code no-lock no-error.
    if not available bf_contract then do:
      if (varcontract <> "yes":u or trn-type = 1) and
         not (t-doc.ext-doc-type = 'ee':U and trn-is-return)
      then do:
        assign
          t-doc.contract-code  = 0.
      end.
      else do:
        message "По клиенту " input frame d-in-doc t-doc.cli-code " " input frame d-in-doc t-doc.cli-type
                " на фирме " t-doc.host-code " нет ни одного договора. "
                func-get-name-from-ext-type ( t-doc.ext-doc-type , true ) " не может быть оформлен."
        view-as alert-box error.
        apply "entry" to t-doc.cli-code in frame d-in-doc.
        return error.
      end.
    end.
    else do:
        run check-contract-code in this-procedure (input  substitute("&1,&2=&3", "choose":u, "doc-type", t-doc.ext-doc-type),
                                                  input  t-doc.host-code,
                                                  input  input frame d-in-doc t-doc.cli-type,
                                                  input  input frame d-in-doc t-doc.cli-code,
                                                  input  ?,
                                                  input  parparentproc,
                                                  input  t-doc.doc-date,
                                                  input if paris-hold = yes then "all" else (if ( t-doc.ext-doc-type = 'ie':U or t-doc.ext-doc-type = 'ep':U or mode-erprn or (t-doc.ext-doc-type = 'ee':U and (logical(varcontract) or trn-is-return))) then 'при':U else 'рас':U) ,
                                                  output varcontract-code) no-error.
      if error-status :error    or
         varcontract-code = ?  or
         varcontract-code = 0  then do:
        if trn-is-return
        then do :
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end .
        if varcontract <> "yes":u or trn-type = 1 then do:
          message "Вы не выбрали договор. Вы хотите оформить "
            func-get-name-from-ext-type ( t-doc.ext-doc-type , false ) " без договора?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog = no then do:
            apply "entry" to t-doc.cli-code in frame d-in-doc.
            return error.
          end.
          else do:
            assign
              t-doc.contract-code = 0.
          end.
        end.
        else do:
          message "Вы не выбрали договор. "
          func-get-name-from-ext-type (t-doc.ext-doc-type, true ) " не может быть оформлен."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
      end.
      else do:
        find first bf_contract where bf_contract.host-code     = t-doc.host-code  and
                                     bf_contract.contract-code = varcontract-code no-lock.
        find first bf_currency where bf_currency.curr-code = bf_contract.curr-code no-lock no-error.
        if not available bf_currency then do:
          message "В договоре указана валюта " bf_contract.curr-code "." skip
                  "Но этой валюты нет в справочнике валют."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  bf_currency.curr-code
  ,input  t-doc.exch-date
  ,output varexch-rate
  ,output varexch-scale
  ,output varcurr-abbr
  ) no-error .
        if error-status :error then do:
          message "Ошибка при поиске курса валюты поставки по договору." skip
                  return-value skip
                  error-status :get-message( 1 ) skip
                  error-status :get-message( 2 )
          view-as alert-box error.
          return error.
        end.
        if t-doc.ext-doc-type = 'ie':U
        then do :
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
          find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                                 and buf_contract-attr.contract-code = bf_contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
          if EDOParSec:IsEdo
          and available buf_contract-attr
          and logical(buf_contract-attr.attr-value) = true
          then do :
            message "Договор рассчитан на поставки через ЭДО. Ручной приход по нему невозможен!" view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-in-doc.
            return error.
          end .
        end .
        if t-doc.ext-doc-type = 'ep':U
        then do :
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
          find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                                 and buf_contract-attr.contract-code = bf_contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
          if EDOParSec:IsEdo
          and available buf_contract-attr
          and logical(buf_contract-attr.attr-value) = true
          then do :
            message "По договору осуществляется ЭДО. Для возврата используйте документ Расход внешний." view-as alert-box .
            return error.
          end .
          else do :
            find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                                   and buf_contract-attr.contract-code = bf_contract.contract-code
                                                   and buf_contract-attr.attr-code = "contract-diadoc"
                                                   no-error .
            if EDOParSec:IsEdo
            and available buf_contract-attr
            and logical(buf_contract-attr.attr-value) = true
            then do :
              message "По договору осуществляется ЭДО. Для возврата используйте документ Расход внешний." view-as alert-box .
              return error.
            end .
          end .
        end .
        if t-doc.ext-doc-type = 'ee':U
        and trn-is-return
        then do :
          if (bf_contract.status_ = 'зкр':U
          or (bf_contract.contract-date-end <> ? and bf_contract.contract-date-end < t-doc.doc-date))
          then do:
            message "Выбранный договор поставки закрыт или истёк срок его действия, оформить возврат невозможно. Обратитесь в офис для корректировки договора." view-as alert-box .
            run check-cli no-error.
            if error-status :error
            then return error .
            else return .
          end .
          if bf_contract.spec-check = 0
          then do :
            message "Для выбранного договора поставки не определена схема возврата, оформить возврат невозможно. Обратитесь в офис для корректировки договора." view-as alert-box .
            run check-cli no-error.
            if error-status :error
            then return error .
            else return .
          end .
          if not can-find(first buf_trn-reason no-lock where buf_trn-reason.reason-code = bf_contract.spec-check) then
          do:
            message "Для выбранного договора поставки не определена схема возврата, оформить возврат невозможно. Обратитесь в офис для корректировки договора." view-as alert-box .
            run check-cli no-error.
            if error-status :error
            then return error .
            else return .
          end.
        end .
        assign
          t-doc.contract-code = varcontract-code
          t-doc.exch-code     = bf_contract.curr-code
          t-doc.exch-rate     = varexch-rate
          t-doc.exch-scale    = varexch-scale
        .
        v-master = Is-Master-Slave-Contract( buffer bf_contract) .
        if v-master  = "+" or v-master  = ""  then do :
          find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num = bf_contract.contract-code
                                                    and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
        end.
        else do :
          find first bf-f_contract-specif no-lock where bf-f_contract-specif.contract-num =integer(v-master)
                                                    and bf-f_contract-specif.host-code = bf_contract.host-code no-error.
        end.
        if available bf-f_contract-specif then do:
          t-doc.vat-type = bf-f_contract-specif.vat-type .
        end.
        run chg-purch-contract in this-procedure.
      end.
    end.
  end.
else do:
  assign
    t-doc.contract-code  = 0.
end.
if varhold = "yes" then do:
  if paris-hold and
    input frame d-in-doc t-doc.cli-type = 'чел':U then do:
    message "Вы работаете со своими фирмами. Физическое лицо не может являться контрагентом."
    view-as alert-box.
    apply "entry" to t-doc.cli-code in frame d-in-doc.
    return error.
  end.
  if input frame d-in-doc t-doc.cli-type = 'орг':U then do:
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = input frame d-in-doc t-doc.cli-code no-error.
  end.
  case t-doc.ext-doc-type :
    when 'ie':U then do:
      if paris-hold = yes then do:
        message "Критическая ошибка. Внешний приход между своими фирмами должен генериться автоматически."
        view-as alert-box error.
        apply "entry" to t-doc.cli-code in frame d-in-doc.
        return error.
      end.
      else do:
         if available buf_sysconf then do:
           message "Внешний приход оформляется от своей фирмы."
                   "Вы уверены?" view-as alert-box buttons yes-no update varlog.
           if varlog <> yes then do:
             apply "entry" to t-doc.cli-code in frame d-in-doc.
             return error.
           end.
define variable vss-include-info84 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_prepownfirmhold':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
           if varlog <> yes then do:
             apply "entry" to t-doc.cli-code in frame d-in-doc.
             return error.
           end.
           assign
             t-doc.hold-doc-code-child  = "no-hold":u
             t-doc.hold-doc-code-parent = "no-hold":u
           .
         end.
      end.
    end.
    when 'ee':U then do:
      if paris-hold = yes then do:
        if not available buf_sysconf then do:
          message
          "В данном пункте меню можно оформить расход только на свою фирму." skip
          view-as alert-box.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
        find first bf_clients where bf_clients.obj-type = 'орг':U         and
                                    bf_clients.obj-code = input frame d-in-doc t-doc.cli-code no-lock.
        run check-base-code in this-procedure (recid(bf_clients)).
        find first buf_firm where buf_firm.firm-code = buf_sysconf.host-code no-lock.
        run str/chshobj.w (input  input frame d-in-doc t-doc.cli-code,
                       input  buf_firm.main-obj-type,
                       input  buf_firm.main-obj-code,
                       output parhold-obj-type,
                       output parhold-obj-code ) no-error.
        if error-status :error then do:
          message
            "Ошибка при определении объекта при межфирменном перемещении."
            view-as alert-box.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
        if  parhold-obj-type = ""
        and parhold-obj-code = 0
        then do:
          message "Не выбран объект для межфирменного перемещения."
          view-as alert-box information.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
        find first buf-hold_clients where buf-hold_clients.obj-type = parhold-obj-type and
                                          buf-hold_clients.obj-code = parhold-obj-code no-lock no-error.
        if not available buf-hold_clients then do:
          message "Не верный объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
        if buf-hold_clients.obj-type <> 'маг':U  and
           buf-hold_clients.obj-type <> 'скл':U then do:
           message "Объект для межфирменном перемещения имеет тип " buf-hold_clients.obj-type " ." skip
                   "Он должен быть склад или магазин."
           view-as alert-box.
           apply "entry" to t-doc.cli-code in frame d-in-doc.
           return error.
        end.
        if buf-hold_clients.obj-type = 'маг':U then do:
          find first buf-hold_shop where buf-hold_shop.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_shop.host-code <> input frame d-in-doc t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame d-in-doc t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-in-doc.
            return error.
          end.
        end.
        if buf-hold_clients.obj-type = 'скл':U then do:
          find first buf-hold_store where buf-hold_store.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_store.host-code <> input frame d-in-doc t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame d-in-doc t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-in-doc.
            return error.
          end.
        end.
    run adm/shattri.p (
      input "get":U
      ,input parhold-obj-type
      ,input parhold-obj-code
      ,input 'contr-in':U
      ,input  "contr-in-income"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE-handle v-tth
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
      delete object v-tth.
      if v-value-logical = true then varcontract-cli = "yes" .
                                else varcontract-cli = "no" .
        assign
          t-doc.hold-obj-type        = parhold-obj-type
          t-doc.hold-obj-code        = parhold-obj-code
          t-doc.hold-doc-code-child  = "hold":u
          t-doc.hold-doc-code-parent = "hold":u.
        if varis-fin <> "yes" then do:
          assign
            t-doc.contract-code = 0.
        end.
        else do:
          if paris-hold = yes then do:
            if varcontract-code <> 0 then do:
              find first bf_contract where bf_contract.contract-code  = varcontract-code       no-lock no-error.
            end.
            else do:
            find first bf_contract where bf_contract.host-code = t-doc.host-code  and
                                        bf_contract.cli-type  = 'орг':U                                    and
                                        bf_contract.cli-code  = buf_sysconf.host-code                     no-lock no-error.
            end.
          if not available bf_contract then do:
            if varcontract-cli <> "yes" then do:
              assign
                t-doc.contract-code  = 0.
            end.
            else do:
              message "По клиенту " t-doc.host-code " " 'орг':U
                      " на фирме " input frame d-in-doc t-doc.cli-code " нет ни одного договора. Приход не может быть оформлен."
              view-as alert-box error.
              apply "entry" to t-doc.cli-code in frame d-in-doc.
              return error.
            end.
          end.
          else do:
            t-doc.contract-code = bf_contract.contract-code.
          end.
          end.
          else do:
          find first bf_contract where bf_contract.host-code = input frame d-in-doc t-doc.cli-code  and
                                       bf_contract.cli-type  = 'орг':U                                    and
                                       bf_contract.cli-code  = t-doc.host-code                           no-lock no-error.
          if not available bf_contract then do:
            if varcontract-cli <> "yes" then do:
              assign
                t-doc.contract-code  = 0.
            end.
            else do:
              message "По клиенту " t-doc.host-code " " 'орг':U
                      " на фирме " input frame d-in-doc t-doc.cli-code " нет ни одного договора. Приход не может быть оформлен."
              view-as alert-box error.
              apply "entry" to t-doc.cli-code in frame d-in-doc.
              return error.
            end.
          end.
          else do:
            run check-contract-code in this-procedure (input  "choose":u,
                                                       input  input frame d-in-doc t-doc.cli-code,
                                                       input  'орг':U,
                                                       input  t-doc.host-code,
                                                       input  ?,
                                                       input  parparentproc,
                                                       input  t-doc.doc-date,
                                                       input 'при':U,
                                                       output varcontract-code) no-error.
            if error-status :error    or
               varcontract-code = ?  or
               varcontract-code = 0  then do:
              if varcontract-cli <> "yes":u then do:
                message "Вы не выбрали договор. Вы хотите оформить внешний приход без договора?"
                view-as alert-box question buttons yes-no update varlog.
                if varlog = no then do:
                  return error.
                end.
                else do:
                  assign
                    t-doc.contract-code = 0.
                end.
              end.
              else do:
                message "Вы не выбрали договор. Приход не может быть оформлен."
                view-as alert-box error.
                apply "entry" to t-doc.cli-code in frame d-in-doc.
                return error.
              end.
            end.
            else do:
              assign
                t-doc.contract-code = varcontract-code.
            end.
          end.
          end.
        end.
      end.
      else do:
        if available buf_sysconf then do:
          message "В данном пункте меню можно оформить расход только на внешнего контрагента."
          "Вы хотите оформить расход на свою фирму, как на внешнего контрагента, без автоматической генерации прихода?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog <> yes then do:
            apply "entry" to t-doc.cli-code in frame d-in-doc.
            return error.
          end.
          else do:
define variable vss-include-info85 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_prepownfirmhold':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
            if varlog <> yes then do:
              apply "entry" to t-doc.cli-code in frame d-in-doc.
              return error.
            end.
            else do:
              assign
                t-doc.hold-doc-code-child  = "no-hold":u
                t-doc.hold-doc-code-parent = "no-hold":u .
            end.
          end.
        end.
      end.
    end.
    when 're':U then do:
      if available buf_sysconf then do:
        message "Вы хотите оформить возврат от своей фирмы, как от внешнего контрагента?"
        view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
        else do:
define variable vss-include-info86 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_prepownfirmhold':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          if varlog <> yes then do:
            apply "entry" to t-doc.cli-code in frame d-in-doc.
            return error.
          end.
        end.
      end.
    end.
    when 'ep':U then do:
      if paris-hold = yes then do:
        if not available buf_sysconf then do:
          message
          "В данном пункте меню можно оформить возврат поставщику только на свою фирму." skip
          view-as alert-box.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
        find first buf_firm where buf_firm.firm-code = buf_sysconf.host-code no-lock.
        find first bf_clients where bf_clients.obj-type = 'орг':U         and
                                    bf_clients.obj-code = input frame d-in-doc t-doc.cli-code no-lock.
        run check-base-code in this-procedure (recid(bf_clients)).
        run str/chshobj.w (input  input frame d-in-doc t-doc.cli-code,
                       input  buf_firm.main-obj-type,
                       input  buf_firm.main-obj-code,
                       output parhold-obj-type,
                       output parhold-obj-code ) no-error.
        if error-status :error then do:
          message
            "Ошибка при определении объекта при межфирменном перемещении."
            view-as alert-box.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
        if  parhold-obj-type = ""
        and parhold-obj-code = 0
        then do:
          message "Не выбран объект для межфирменного перемещения."
          view-as alert-box information.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
        find first buf-hold_clients where buf-hold_clients.obj-type = parhold-obj-type and
                                          buf-hold_clients.obj-code = parhold-obj-code no-lock no-error.
        if not available buf-hold_clients then do:
          message "Не верный объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения."
          view-as alert-box error.
          apply "entry" to t-doc.cli-code in frame d-in-doc.
          return error.
        end.
        if buf-hold_clients.obj-type <> 'маг':U  and
           buf-hold_clients.obj-type <> 'скл':U then do:
           message "Объект для межфирменном перемещения имеет тип " buf-hold_clients.obj-type " ." skip
                   "Он должен быть склад или магазин."
           view-as alert-box.
           apply "entry" to t-doc.cli-code in frame d-in-doc.
           return error.
        end.
        if buf-hold_clients.obj-type = 'маг':U then do:
          find first buf-hold_shop where buf-hold_shop.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_shop.host-code <> input frame d-in-doc t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame d-in-doc t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-in-doc.
            return error.
          end.
        end.
        if buf-hold_clients.obj-type = 'скл':U then do:
          find first buf-hold_store where buf-hold_store.obj-code = buf-hold_clients.obj-code no-lock.
          if buf-hold_store.host-code <> input frame d-in-doc t-doc.cli-code then do:
            message "Объект " parhold-obj-type " " parhold-obj-code " для межфирменного перемещения не принадлежит фирме " input frame d-in-doc t-doc.cli-code " ."
            view-as alert-box error.
            apply "entry" to t-doc.cli-code in frame d-in-doc.
            return error.
          end.
        end.
        assign
          t-doc.hold-obj-type        = parhold-obj-type
          t-doc.hold-obj-code        = parhold-obj-code
          t-doc.hold-doc-code-child  = "hold":u
          t-doc.hold-doc-code-parent = "hold":u.
      end.
      else do:
        if available buf_sysconf then do:
          message "В данном пункте меню можно оформить возврат поставщику только на внешнего контрагента."
          "Вы хотите оформить возврат поставщику на свою фирму, как на внешнего контрагента, без автоматической генерации возврата от покупателя?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog <> yes then do:
            apply "entry" to t-doc.cli-code in frame d-in-doc.
            return error.
          end.
          else do:
define variable vss-include-info87 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_prepownfirmhold':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
            if varlog <> yes then do:
              apply "entry" to t-doc.cli-code in frame d-in-doc.
              return error.
            end.
            else do:
              assign
                t-doc.hold-doc-code-child  = "no-hold":u
                t-doc.hold-doc-code-parent = "no-hold":u .
            end.
          end.
        end.
      end.
    end.
    otherwise do:
    end.
  end case.
end.
assign
  t-doc.cli-code = input frame d-in-doc t-doc.cli-code
  t-doc.cli-type = input frame d-in-doc t-doc.cli-type.
display ub.clients.obj-name with frame d-in-doc.
pardoc-mode = 'ИЗМЕНЕНИЕ':U.
if ub.clients.obj-type = 'орг':U then do:
  find ub.firm where ub.firm.firm-code = ub.clients.obj-code no-lock.
  find ub.clients where ub.clients.obj-type = 'чел':U
                        and ub.clients.obj-code = ub.firm.tobj-code no-lock no-error.
  if available ub.clients then
    display ub.clients.obj-code @ t-doc.boss
            ub.clients.obj-name @ boss-name with frame d-in-doc.
end.
release ub.clients.
run UI-on ("enable").
end.
end procedure.
procedure check-rate :
define variable varbase-code as integer no-undo.
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output varbase-code
  )  .
define variable flag-recount as logical initial no no-undo.
if input frame d-in-doc t-doc.exch-rate  <> t-doc.exch-rate  or
   input frame d-in-doc t-doc.exch-scale <> t-doc.exch-scale or
   input frame d-in-doc t-doc.base-rate  <> t-doc.base-rate  or
   input frame d-in-doc t-doc.base-scale <> t-doc.base-scale then flag-recount = yes.
if input frame d-in-doc t-doc.base-rate = ? or
   input frame d-in-doc t-doc.base-rate = 0 then do:
  message "Не задан курс базовой валюты.".
  apply "entry" to t-doc.base-rate in frame d-in-doc.
  return error.
end.
if input frame d-in-doc t-doc.base-scale = ? or
   input frame d-in-doc t-doc.base-scale = 0 then do:
  message "Не задан масштаб базовой валюты.".
  apply "entry" to t-doc.base-scale in frame d-in-doc.
  return error.
end.
assign frame d-in-doc
  t-doc.base-rate
  t-doc.base-scale.
if input frame d-in-doc t-doc.exch-rate = ? or
   input frame d-in-doc t-doc.exch-rate = 0 then do:
  message "Не задан курс валюты поставщика.".
  apply "entry" to t-doc.exch-rate in frame d-in-doc.
  return error.
end.
if input frame d-in-doc t-doc.exch-scale = ? or
   input frame d-in-doc t-doc.exch-scale = 0 then do:
  message "Не задан масштаб валюты поставщика.".
  apply "entry" to t-doc.exch-scale in frame d-in-doc.
  return error.
end.
assign
  frame d-in-doc
  t-doc.exch-rate
  t-doc.exch-scale.
run waitfram-show in this-procedure  ("ЖДИТЕ.  Пересчет документа ...").
if flag-recount then do:
   run full-recount.
end.
run waitfram-hide in this-procedure  .
end procedure.
procedure mode-on :
define variable varout-ret-supp like ub.trn-doc.ret-supp no-undo.
define variable varout-pay-code like ub.trn-doc.pay-code no-undo.
define variable vardoc-code     like ub.trn-doc.doc-code no-undo.
define variable v-today         as date                  no-undo.
define buffer cli_clients  for ub.clients.
define buffer cli_firm     for ub.firm.
define buffer main_clients for ub.clients.
define buffer cli_sysconf  for ub.sysconf.
define variable varpurch-code as integer   no-undo.
define variable varbase-code as integer no-undo.
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output varbase-code
  )  .
do on error undo, return error :
case pardoc-mode :
  when 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
    find last ub.curr-accnt where ub.curr-accnt.curr-code = varbase-code
        and ub.curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
    if not available ub.curr-accnt then do:
      message "На дату" v-today "неизвестен курс базовой валюты.".
      undo, return error.
    end.
    if parinternal = ? then do:
      message "Неизвестно, внутренний или внешний документ.".
      undo, return error.
    end.
    if parinternal and partype = 'возврат':U then do:
      message "Для внутреннего перемещения можно создать только расход."
                      "Остальные документы создаются автоматически.".
      undo, return error.
    end.
    if v-cntxt-obj-type = 'скл':U then do:
      find first ub.store where ub.store.obj-code = v-cntxt-obj-code no-lock.
      assign
        varpurch-code = ub.store.purch-code.
    end.
    else do:
      find first ub.shop where ub.shop.obj-code = v-cntxt-obj-code no-lock.
      assign
        varpurch-code = ub.shop.purch-code.
    end.
    if varpurch-code <> ? then do:
      if lookup (string(varpurch-code), '1,2,3,4':U) = 0 then do:
        message "Неверный код типа приобретения по умолчанию для объекта. " skip
                "Допустимые типы: "
        view-as alert-box error.
        return error.
      end.
    end.
    if varpurch-code = ? then do:
      find first ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock.
      if lookup (string(ub.sysconf.purch-code), '1,2,3,4':U) = 0 then do:
        message "Неверный код типа приобретения по умолчанию для фирмы. " skip
                "Допустимые типы: "
        view-as alert-box error.
        return error.
      end.
      assign
        varpurch-code = ub.sysconf.purch-code.
    end.
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
    run doc-code in this-procedure
      (input  "main",
       input  v-cntxt-obj-type,
       input  v-cntxt-obj-code,
       input  ?,
       output vardoc-code ) no-error.
    if error-status :error then do:
      message "Ошибка при генерации номера документа." return-value view-as alert-box.
      return error.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input ub.curr-accnt.exch-rate
,input ub.curr-accnt.exch-scale
,input ?
,input ?
,input ?
,input v-cntxt-db-num
,input v-cntxt-userid
,input   ''
,input vardoc-code
,input v-today
,input   'при':U
,input no
,input v-cntxt-host-code-obj
,input parinternal
,input v-cntxt-obj-code
,input v-cntxt-obj-type
,input no
,input   v-cntxp-in-pay
,input '@  '
,input   no
,input   varslt-type-def
,input  parstat
,input   varvat-type-def
,input parext-doc-type
,input
        varpurch-code
) no-error
.
    if error-status :error then do:
      undo, return error return-value.
    end.
    find t-doc where t-doc.doc-code = vardoc-code.
    assign
      pardoc-rec = recid (t-doc)
      .
       if not can-find(first ub.pay-type where ub.pay-type.obj-code = t-doc.pay-code no-lock) then do:
          message "В настройках текущего объекта указан вид оплаты прихода: " v-cntxp-in-pay ", которого нет в справочнике!"
                   view-as alert-box error buttons ok.
          undo, return error.
       end.
  end.
  when 'ПРОСМОТР':U then do:
    find t-doc no-lock where recid( t-doc ) = pardoc-rec no-error.
    if available t-doc then do:
      if t-doc.internal = ? then do:
        message "Документ был заведен неверно и удаляется!!!" view-as alert-box.
        find t-doc exclusive-lock where recid( t-doc ) = pardoc-rec.
        delete t-doc.
        return.
      end.
      if parext-doc-mode <> "":U then do:
        find t-doc exclusive-lock where recid( t-doc ) = pardoc-rec.
      end.
    end.
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    find t-doc where recid (t-doc) = pardoc-rec no-error.
    if available t-doc then do:
      if t-doc.cli-code = ? then do:
        message "Документ был заведен неверно и удаляется!!!" view-as alert-box.
        delete t-doc.
        return.
      end.
      if t-doc.flag_ = yes and t-doc.status_ = 'накл':U and t-doc.doc-type <> 'при':U and t-doc.ext-doc-type <> 'eo':U then do:
        find t-doc where recid (t-doc) = pardoc-rec.
        message "Факт. кол-во можно проставлять только в статусе разрешен.".
        undo, return error.
      end.
      if t-doc.status_ = 'касс':U then do:
        find t-doc where recid (t-doc) = pardoc-rec.
        message "Все действия с кассовыми отчетами выполняются из АРМ Магазин.".
        undo, return error.
      end.
      if t-doc.status_ = 'факт':U or
         (t-doc.flag_ = yes and t-doc.status_ = 'запрос':U) then do:
        find t-doc where recid (t-doc) = pardoc-rec.
        message "Документ уже закрыт. Изменение невозможно.".
        undo, return error.
      end.
      if  t-doc.flag_ = yes
      then do:
        define variable v-obj-active  as logical   no-undo .
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  'active=request':u
  ,output v-obj-active
  )  .
        if v-obj-active <> true
        then do:
          find t-doc
            where recid (t-doc) = pardoc-rec.
          message
            "Коррекция фактического количества допустима только в базе данных объекта" skip
            "Документ" t-doc.doc-code skip
            "Объект" t-doc.obj-type t-doc.obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
      end.
      find t-doc exclusive-lock
        where recid (t-doc) = pardoc-rec
        .
    end.
  end.
end.
if not available t-doc
then do:
  message "Неправильно выбран документ.".
  undo, return error.
end.
end.
end procedure.
procedure notes-tr:
define variable notes as character no-undo.
assign
  notes = t-doc.PS.
if pardoc-mode = 'ПРОСМОТР':U then do:
  run gbl/d-prompt.w (
      'title=Примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    + 'readonly=yes\'
    , input-output notes).
end.
else do:
   run gbl/d-prompt.w (
      'title=примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    , input-output notes).
    if return-value = 'false':u then return .
  if t-doc.PS <> notes then do:
  if pardoc-rec = ? then pardoc-rec = recid (t-doc).
    do transaction on error undo, return error return-value :
      find t-doc where recid (t-doc) = pardoc-rec exclusive.
      assign
        t-doc.PS = notes.
    end.
  end.
end.
end procedure.
procedure choose-cli:
define variable varfirm-code like ub.firm.firm-code no-undo.
define variable v-types as character no-undo .
define buffer bf_clients for ub.clients.
define variable ref-rec as recid no-undo.
define variable v-rid-list as character no-undo .
do on error undo, return error return-value :
run check-cli no-error.
if error-status :error then do:
  if t-doc.internal then v-types = 'маг':U.
                    else v-types = 'все':U.
  if (t-doc.ext-doc-type = 'ee':U or t-doc.ext-doc-type = 'ep':U) and
     varhold            = "yes"              and
     paris-hold         = yes                then do:
    assign
      varfirm-code = ?.
    run adm/sconfs.w ( input parparentproc
                    , input "b-sel":U
                    , input no
                    , input ?
                    , output varfirm-code
                    , input-output v-rid-list) no-error.
    if error-status :error or
       varfirm-code = ?   then do:
      return error.
    end.
    find first bf_clients where bf_clients.obj-type = 'орг':U       and
                                bf_clients.obj-code = varfirm-code no-lock.
    assign ref-list = string(recid (bf_clients)).
    run check-base-code in this-procedure (recid(bf_clients)).
  end.
  else do:
    if transaction = yes then do:
      message "Критическая ошибка." skip
              "Вы находитесь в транзакции." skip
              "Работа со справочником клиентов невозможна."
      view-as alert-box error.
      return error.
    end.
    run ref/cli-all.w ( parparentproc
                   , "b-sel,b-add"
                   , v-types
                   , ?
                   , ?
                   , ?
                   , ?
                   , ?
                  , output ref-list) .
  end.
  if ref-list <> "" then do:
    ref-rec = integer (ref-list).
    find ub.clients where recid ( ub.clients ) = ref-rec no-lock.
    disp ub.clients.obj-code @ t-doc.cli-code
            ub.clients.obj-name with frame d-in-doc.
    disp ub.clients.obj-type @ t-doc.cli-type with frame d-in-doc.
  end.
  run check-cli no-error.
  if error-status :error then do:
    return error return-value.
  end.
end.
end.
end procedure.
procedure state-pay-code:
do transaction on error undo, return error :
   if input frame d-in-doc t-doc.pay-code = v-cntxp-ret-sup-pay then do:
      message "Нельзя устанавливаться код возврата поставщику." skip
              "Возврат поставщику оформляется из отдельнего пункта меню."
      view-as alert-box error.
      undo, return error.
   end.
   assign t-doc.pay-code = input frame d-in-doc t-doc.pay-code no-error.
   for each ub.parts where ub.parts.out-code = t-doc.doc-code:
       assign ub.parts.pay-code = t-doc.pay-code.
   end.
end.
end procedure.
procedure return-pay-code:
if input frame d-in-doc t-doc.pay-code <> t-doc.pay-code then do:
   if input frame d-in-doc t-doc.pay-code = v-cntxp-ret-sup-pay then do:
      message "Нельзя устанавливаться код возврата поставщику." skip
              "Возврат поставщику оформляется из отдельнего пункта меню."
      view-as alert-box error.
      display t-doc.pay-code with frame d-in-doc.
      return error.
   end.
end.
find ub.pay-type where ub.pay-type.obj-code = input frame d-in-doc t-doc.pay-code no-lock no-error.
if not available ub.pay-type then apply "choose" to r-pay.
end procedure.
procedure choose-r-pay:
define variable varrecid-pay as recid no-undo.
define variable v-rid-list as character no-undo .
run ref/paytype.w (input parparentproc, "b-sel", output v-rid-list ).
find ub.pay-type where recid ( ub.pay-type ) = integer(v-rid-list) no-lock no-error.
if not available ub.pay-type then return no-apply.
if ub.pay-type.obj-code = v-cntxp-ret-sup-pay then do:
   message "Нельзя устанавливаться код возврата поставщику." skip
           "Возврат поставщику оформляется из отдельнего пункта меню."
   view-as alert-box error.
   display t-doc.pay-code with frame d-in-doc.
   return error.
end.
display ub.pay-type.obj-code @ t-doc.pay-code with frame d-in-doc.
assign varrecid-pay = recid(ub.pay-type).
run state-pay-code no-error.
if error-status :error then do:
  display t-doc.pay-code with frame d-in-doc.
  apply "entry" to t-doc.pay-code in frame d-in-doc.
  return error.
end.
find ub.pay-type where recid(ub.pay-type) = varrecid-pay no-lock.
display t-doc.pay-code ub.pay-type.obj-name with frame d-in-doc.
end procedure.
procedure leave-pay-code:
define variable varrecid-pay as recid no-undo.
if input frame d-in-doc t-doc.pay-code = v-cntxp-ret-sup-pay then do:
   message "Нельзя устанавливаться код возврата поставщику." skip
           "Возврат поставщику оформляется из отдельнего пункта меню."
   view-as alert-box error.
   display t-doc.pay-code with frame d-in-doc.
   return error.
end.
find ub.pay-type where ub.pay-type.obj-code = input frame d-in-doc t-doc.pay-code no-lock no-error.
if not available ub.pay-type then do:
  message "Нет вида оплаты с таким кодом.".
  display t-doc.pay-code with frame d-in-doc.
  apply "entry" to t-doc.pay-code in frame d-in-doc.
  return error.
end.
assign varrecid-pay = recid(ub.pay-type).
run state-pay-code no-error.
if error-status :error then do:
  display t-doc.pay-code with frame d-in-doc.
  apply "entry" to t-doc.pay-code in frame d-in-doc.
  return error.
end.
find ub.pay-type where recid(ub.pay-type) = varrecid-pay no-lock.
display ub.pay-type.obj-name with frame d-in-doc.
end procedure.
procedure proc-exit :
  define variable v-vat-pc   as decimal no-undo .
  define variable v-slt-pc   as decimal no-undo .
  define variable v-insalepr as logical no-undo .
  assign parnext-prev = ?.
  if lookup( pardoc-mode, 'ДОБАВЛЕНИЕ':U ) > 0 then do:
    if not can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) then do:
      delete t-doc.
      assign pardoc-rec = ?.
    end.
    return.
  end.
  if lookup( pardoc-mode, 'ИЗМЕНЕНИЕ':U ) > 0 then do:
    if not can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) and t-doc.is-flora = false then do:
      assign varlog = true .
      message "В документе нет строк, поэтому он удаляется." view-as alert-box question buttons OK-Cancel update varlog.
      if varlog = yes then do:
        if t-doc.is-flora = false then do:
            define variable varchip-code as decimal   no-undo .
                  run str/del-doc.p
                      ( input  parparentproc,
                        input  t-doc.doc-code,
                        input  v-cntxt-db-num,
                        input  "del-doc.err",
                        input  ?,
                        input  ?,
                        input  v-cntxt-userid,
                        input  t-doc.doc-code,
                        input  ?,
                        output varchip-code )
                        .
          assign pardoc-rec = ?.
          return.
        end.
        else do:
          assign varlog = false .
          message "ВНИМАНИЕ !!! Документ удалится, так как в нем НЕТ ТОВАРОВ!!!"
                     view-as alert-box  question buttons OK-Cancel update varlog .
          if varlog = yes then do:
            delete t-doc.
            assign pardoc-rec = ?.
            return.
          end.
          return error.
        end.
      end.
      else do: return error. end.
    end.
    assign frame d-in-doc t-doc.wrkr t-doc.agnt t-doc.boss .
    define variable v-err as logical   no-undo .
    run str/ver-fl.p ( input pardoc-mode, input t-doc.doc-code , output v-err ) no-error .
    if error-status :error then return error.
    define buffer buff_doc-line for ub.doc-line  .
    define variable v-mess as character no-undo .
    for each buff_doc-line no-lock  where buff_doc-line.doc-code = t-doc.doc-code :
    v-mess = "" .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_linesprc in g#lib-trn4
  (input  recid(buff_doc-line)
  ,output v-mess
  )  .
      if v-mess <> "" then do:
        message v-mess view-as alert-box error TITLE "Сверка количества со спецификацией".
        return error.
      end.
      if not v-cntxp-inout-price and  not t-doc.flag_ then do:
          find ub.goods where ub.goods.artic    = buff_doc-line.artic     and
                           ub.goods.prod-type = buff_doc-line.prod-type and
                           ub.goods.prod-code = buff_doc-line.prod-code no-lock.
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  t-doc.host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-vat-pc
  ) no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(ub.goods)
,input  recid(t-doc)
,input  bf_sysconf.cash-pay
,output v-slt-pc
)
.
            if  buff_doc-line.vat-pc <> v-vat-pc     or buff_doc-line.slt-pc <> v-slt-pc
            then do:
              v-mess = substitute(" В карточке товара &1 &2 установлены другие налоги !&7 НДС &3% НСП &4% , а в документе &5% и &6%" , ub.goods.gds-code, ub.goods.gds-name, buff_doc-line.vat-pc , buff_doc-line.slt-pc , v-vat-pc , v-slt-pc , chr(10) ) .
              message v-mess view-as alert-box error TITLE "Запрет на изменение налогов при приеме у поставщика".
              return error.
            end.
      end.
      find ub.goods where ub.goods.artic    = buff_doc-line.artic     and
                       ub.goods.prod-type = buff_doc-line.prod-type and
                       ub.goods.prod-code = buff_doc-line.prod-code no-lock.
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buff_doc-line.obj-type
  ,input  buff_doc-line.obj-code
  ,input  buff_doc-line.artic
  ,input  buff_doc-line.prod-type
  ,input  buff_doc-line.prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  )  .
      if v-insalepr <> ? and v-insalepr = true
      then do:
        t-doc.tot-cli = t-doc.tot-calc.
      end.
    end.
  end.
  if t-doc.ext-doc-type = 'ep':U  and pardoc-mode <> 'ПРОСМОТР':U then do:
     run str/ep-corrp.p (input parparentproc , input t-doc.doc-code ) no-error.
  end.
  run fill-mol in this-procedure.
end procedure.
procedure check-base-code :
define input parameter parrec-id as recid no-undo.
define variable varmy-host-code  like ub.sysconf.host-code no-undo.
define variable varmy-base-code  like ub.sysconf.base-code no-undo.
define variable varcli-base-code like ub.sysconf.base-code no-undo.
define buffer bf-my_currency  for ub.currency.
define buffer bf-cli_currency for ub.currency.
define buffer bf_clients for ub.clients.
do on error undo, return error return-value :
  find first bf_clients where recid(bf_clients) = parrec-id no-lock.
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output varmy-host-code
  ) no-error .
  if error-status :error then do:
    message "Ошибка при поиске фирмы для объекта " v-cntxt-obj-type " " v-cntxt-obj-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  varmy-host-code
  ,output varmy-base-code
  ) no-error .
  if error-status :error then do:
    message "Ошибка при поиске базовой валюты для фирмы " varmy-base-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  bf_clients.obj-code
  ,output varcli-base-code
  ) no-error .
  if error-status :error then do:
    message "Ошибка при поиске базовой валюты для фирмы " bf_clients.obj-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
  if varmy-base-code <> varcli-base-code then do:
    find first bf-my_currency  where bf-my_currency.curr-code  = varmy-base-code  no-lock.
    find first bf-cli_currency where bf-cli_currency.curr-code = varcli-base-code no-lock.
    message "Несоответствие базовых валют фирм при межфирменном перемещении." skip
            "У нашей фирмы " varmy-host-code " базовая валюта " bf-my_currency.curr-abbr " " bf-my_currency.curr-name " с кодом " bf-my_currency.curr-code " ." skip
            "У фирмы контрагента " bf_clients.obj-code " базовая валюта " bf-cli_currency.curr-abbr " " bf-cli_currency.curr-name " с кодом " bf-cli_currency.curr-code " ." skip
            "Межфирменное перемещение невозможно."
    view-as alert-box error.
    return error.
  end.
end.
end procedure.
procedure proc-history :
  define variable loc-ref-list as character no-undo.
  define variable loc-doc-save as recid     no-undo.
  define variable loc-mode     as character no-undo.
  define variable loc#stat     as character no-undo.
  define variable loc#type     as character no-undo.
  define variable loc#internal as logical   no-undo.
  define buffer buffer_trn-doc for ub.trn-doc.
  do on error undo, return error return-value :
    if not available t-doc then do:
      message "Неправильный выбор записи." view-as alert-box.
      return error.
    end.
    find buffer_trn-doc no-lock where buffer_trn-doc.doc-code = t-doc.doc-code.
    assign pardoc-rec      = recid( t-doc ).
define variable vss-include-info98 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_c-documents_all':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    if varlog <> yes then do: return no-apply. end.
    run str/calldocs.w (  input  parparentproc,
                      input  'doc':U,
                      input  buffer_trn-doc.status_,
                      input  buffer_trn-doc.doc-type,
                      input  buffer_trn-doc.flag_,
                      input  buffer_trn-doc.internal,
                      input  "":U,
                      input  buffer_trn-doc.doc-code,
                      input  paris-hold ,
                      input  recid(buffer_trn-doc),
                      input  t-doc.obj-type,
                      input  t-doc.obj-code,
                      output loc-ref-list ).
    apply "ENTRY":U to br-dtl in frame d-in-doc.
  end.
  end procedure.
procedure fill-mol:
  if pardoc-mode = 'ИЗМЕНЕНИЕ':U or pardoc-mode = 'ДОБАВЛЕНИЕ':U
  then
  do:
    find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid.
    if ub.user-account.psn-code <> 0 and ub.user-account.psn-code <> ?
      then
    do:
      if t-doc.boss = ? then do:
        t-doc.boss:screen-value in frame d-in-doc = string (ub.user-account.psn-code).
        apply "leave" to t-doc.boss in frame d-in-doc.
      end.
      if t-doc.wrkr = ?
      then do:
        t-doc.wrkr:screen-value in frame d-in-doc = string (ub.user-account.psn-code).
        apply "leave" to t-doc.wrkr in frame d-in-doc.
      end.
      t-doc.agnt:screen-value in frame d-in-doc = string (ub.user-account.psn-code).
      apply "leave" to t-doc.agnt in frame d-in-doc.
    end.
    release ub.user-account.
  end.
end.
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref99 as character no-undo .
define variable varpgscales-pref99 as character no-undo.
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type100 as character no-undo.
varscales-pref99  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref99
  ,output varscales-pref-type100
  ) no-error .
if varscales-pref99 = ? then do:
  assign
  varscales-pref99 = '21,23,25':U.
end.
define variable varpgscales-pref-type100 as character no-undo.
varpgscales-pref99  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref99
  ,output varpgscales-pref-type100
  ) no-error .
if varpgscales-pref99 = ? then do:
  assign
  varpgscales-pref99 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame d-in-doc do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-dtl in frame d-in-doc do:
  run proc-any-printable-br-dtl in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-dtl in frame d-in-doc do:
  run proc-backspace-br-dtl in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME d-in-doc do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME d-in-doc do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame d-in-doc a-n-c :
    when "art" then do:
      apply "entry" to br-dtl in frame d-in-doc.
      hide loc-name loc-code
      in frame d-in-doc.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame d-in-doc.
      disp loc-name with frame d-in-doc.
      hide loc-art loc-code
      in frame d-in-doc.
      apply "entry" to loc-name in frame d-in-doc.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame d-in-doc.
      disp loc-code with frame d-in-doc.
      hide loc-art loc-name
      in frame d-in-doc.
      apply "entry" to loc-code in frame d-in-doc.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-dtl :
  if input frame d-in-doc a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-doc-line where
               l-doc-line.doc-code = t-doc.doc-code and l-doc-line.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-doc-line then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame d-in-doc.
      line-rec = recid (l-doc-line).
      reposition br-dtl to recid line-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-dtl:
  if input frame d-in-doc a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-doc-line where
               l-doc-line.doc-code = t-doc.doc-code and l-doc-line.artic begins loc-art
               no-lock.
    disp loc-art with frame d-in-doc.
    line-rec = recid (l-doc-line).
    reposition br-dtl to recid line-rec no-error.
  end.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-loc-code:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
  assign
  frame d-in-doc
  loc-code
  a-n-c.
  if a-n-c = "datamatrix"
  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_dm-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  varscales-pref99
,input  varpgscales-pref99
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame d-in-doc = buf_prod-bc.b-str.
  end.
  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  varscales-pref99
,input  varpgscales-pref99
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
end.
  if available buf_bar-code then do:
        find first l-goods where
                  l-goods.gds-code =
  buf_bar-code.gds-code No-LOCK.
        find first l-doc-line where l-doc-line.doc-code = t-doc.doc-code and
                  l-doc-line.artic = l-goods.artic AND
                  l-doc-line.prod-type = l-goods.prod-type AND
                  l-doc-line.prod-code = l-goods.prod-code no-lock no-error.
    if available l-doc-line then do:
      line-rec = recid (l-doc-line).
      reposition br-dtl to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame d-in-doc.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame d-in-doc
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-doc-line where l-doc-line.doc-code = t-doc.doc-code and
                can-find (ub.goods where ub.goods.artic = l-doc-line.artic and
                ub.goods.prod-type = l-doc-line.prod-type and
                ub.goods.prod-code = l-doc-line.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-doc-line where l-doc-line.doc-code = t-doc.doc-code and
                can-find (ub.goods where ub.goods.artic = l-doc-line.artic and
                ub.goods.prod-type = l-doc-line.prod-type and
                ub.goods.prod-code = l-doc-line.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-doc-line then do:
      line-rec = recid (l-doc-line).
      reposition br-dtl to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame d-in-doc.
END PROCEDURE.
on value-changed of br-dtl in frame d-in-doc do:
if not available ub.doc-line or recid (ub.doc-line) <> line-rec then do:
    hide loc-art in frame d-in-doc.
    loc-art = "".
end.
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, ",":U).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-in-doc:PARENT eq ?
THEN FRAME d-in-doc:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-in-doc APPLY "END-ERROR":U TO SELF.
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-in-doc
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
on choose of b-help in frame d-in-doc
do:
  apply "help":u to frame d-in-doc .
end.
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-in-doc:width - 0.3
                fh            = frame d-in-doc:first-child
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
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-in-doc :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-in-doc :height-chars)
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
    if frame d-in-doc :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-in-doc :height-chars)
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
            frame d-in-doc :height = v-frame-height
          .
          if frame d-in-doc :scrollable = true
          then do:
            assign
              frame d-in-doc :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-in-doc :scrollable = true
          then do:
            assign
              frame d-in-doc :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-in-doc :height = v-frame-height
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
      v-frame-height = frame d-in-doc :height
      v-frame-virtual-height = frame d-in-doc :virtual-height
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
      v-field-group-handle = frame d-in-doc :first-child
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
    do with frame d-in-doc
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-in-doc :scrollable = true
      then do:
        assign
          frame d-in-doc :virtual-height = frame d-in-doc :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-in-doc :height = frame d-in-doc :height + p-change-value
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
        frame d-in-doc :height = frame d-in-doc :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-in-doc :scrollable = true
      then do:
        assign
          frame d-in-doc :virtual-height = frame d-in-doc :virtual-height + p-change-value
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
          ,input  string(frame d-in-doc :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-in-doc :height)
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
    if frame d-in-doc :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-in-doc :width
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
    if frame d-in-doc :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-in-doc :width
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
            frame d-in-doc :width = v-frame-width
          .
          if frame d-in-doc :scrollable = true
          then do:
            assign
              frame d-in-doc :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-in-doc :scrollable = true
          then do:
            assign
              frame d-in-doc :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-in-doc :width = v-frame-width
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
      v-frame-width = frame d-in-doc :width
      v-frame-virtual-width = frame d-in-doc :virtual-width
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
      v-field-group-handle = frame d-in-doc :first-child
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
    do with frame d-in-doc
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-in-doc :scrollable = true
      then do:
        assign
          frame d-in-doc :virtual-width = frame d-in-doc :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-in-doc :width = v-frame-width + p-change-value
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
        frame d-in-doc :width = frame d-in-doc :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-in-doc :scrollable = true
      then do:
        assign
          frame d-in-doc :virtual-width = frame d-in-doc :virtual-width + p-change-value
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
          ,input  string(frame d-in-doc :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-in-doc :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-in-doc
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-in-doc :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-in-doc :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-in-doc :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-in-doc :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-in-doc
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
      v-row-delta = v-new-row - frame d-in-doc :height
      v-col-delta = v-new-col - frame d-in-doc :width
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
            - frame d-in-doc :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-in-doc :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-in-doc :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-in-doc :height-chars
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
      v-diasize-current-frame-width  = frame d-in-doc :width
      v-diasize-current-frame-height = frame d-in-doc :height
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
    do with frame d-in-doc
    :
      assign
        v-diasize-orig-frame-height = frame d-in-doc :height
        v-diasize-orig-frame-width  = frame d-in-doc :width
        v-diasize-browse-handle     = browse br-dtl :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-in-doc :first-child
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
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-dtl :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
frame d-in-doc:visible = true .
hide t-doc.discnt-pc in frame d-in-doc .
run chk-is-addcharges in parparentproc ( output is-add-doc ) .
if not is-add-doc then hide b-add-doc in frame d-in-doc .
t-doc.tot-sale:label in frame d-in-doc = "Сумма рубли факт" .
t-doc.VAT-rubl:label in frame d-in-doc = "НДС по УЧЕТ ценам(руб)"   .
b-print:popup-menu in frame d-in-doc   = menu m-print:handle .
b-print:menu-mouse                          = 1 .
assign
  parnext-prev = yes
.
n-p:
do while parnext-prev :
main-block:
do on error undo main-block, leave main-block :
   assign
       br-dtl:column-resizable in frame d-in-doc = true.
   if pardoc-mode = 'КОПИРОВАНИЕ':U
    then
    assign
      is-copy = true
      pardoc-mode = 'ДОБАВЛЕНИЕ':U
      docrec-src = pardoc-rec
      pardoc-rec = ?
      .
define variable vss-include-info105 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  ) no-error .
   if error-status :error then do:
     assign
       parnext-prev = no.
     return error.
   end.
   run local-conf-rd in this-procedure no-error.
   if error-status :error then do:
     assign
       parnext-prev = no.
     return error.
   end.
   run mode-on in this-procedure no-error.
   if error-status :error then do:
     assign
       parnext-prev = no.
     return error.
   end.
define variable vss-include-info106 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  t-doc.doc-code
  ,output is-doc-hold
  ) no-error .
   if error-status :error or is-doc-hold = ? then do:
     assign
       is-doc-hold = no
     .
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'indoclnsum':U ,
                       output varvalue ,
                       output vartype ) no-error .
   if varvalue = "yes" then do:
     assign
       varinplnsum = yes.
   end.
   else do:
     assign
       varinplnsum = no.
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'm_inc':U ,
                       output varvalue ,
                       output vartype ) no-error .
   if int(varvalue) > 0 then do:
     assign
       m-inc = varvalue.
   end.
   else do:
     assign
       m-inc = "1".
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'negais':U ,
                       output varvalue ,
                       output vartype ) no-error .
   if varvalue <> "" and varvalue <> ? then do:
     assign
       isEgais = yes.
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-fuel':U ,
                       output varvalue ,
                       output vartype ) no-error .
   if varvalue = "yes" then do:
     assign
       trn-type = 1.
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-lgas':U ,
                       output varvalue ,
                       output vartype ) no-error .
   if varvalue = "yes" then do:
     assign
       trn-type = 2.
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'is-lgas-corr':U ,
                       output varvalue ,
                       output vartype ) no-error .
   if varvalue = "yes" then do:
     assign
       trn-type = 3.
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'trn-is-gds':U ,
                       output varvalue ,
                       output vartype ) no-error .
   if varvalue = "yes" then do:
     assign
       trn-type = 4.
   end.
   display varinplnsum m-inc with frame d-in-doc.
   if pardoc-mode <> 'ПРОСМОТР':U then line-rec = ?.
   if v-is-tsd = "no" then do: menu-item m-outs-2:sensitive in menu m-outs = no. end.
   if pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
     find first bf_sysconf where bf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .
   end.
   else do:
     find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock no-error .
   end.
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
    if error-status :error then.
    else v-edit-fact-wayb = v-value-logical.
    v-by-utd = false .
    define buffer buf_utd for ub.utd .
    if can-find(buf_utd no-lock where buf_utd.doc-code = t-doc.doc-code)
    and parext-doc-mode = ""
    then do :
      v-by-utd = true .
    end .
  end.
  if is-copy
  then do:
    for first src-doc where recid (src-doc) = docrec-src no-lock:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input src-doc.doc-code ,
                        input 'is-fuel':U ,
                       output varattr ,
                       output vartype ) no-error .
      if  varattr = "yes"
        then trn-type = 1.
    end.
  end.
   run UI-on in this-procedure ( input "enable" ) no-error.
   if error-status :error then do:
     assign
       parnext-prev = no.
     return error.
   end.
   if not is-copy and can-find (FIRST ub.clients-attr no-lock where (ub.clients-attr.attr-code = 'supp-np':U or ub.clients-attr.attr-code = 'supp-lgas':U)
                                                and ub.clients-attr.attr-value = "yes") and pardoc-mode = 'ДОБАВЛЕНИЕ':U
   then do :
    run gbl/d-askw.w (
                 input "Выбор типа приходного документа"
                ,input "Выберите тип товаров в приходной накладной"
                ,input "|"
                ,input "Топливо|Приход СУГ|Корр. СУГ|ТНП|Отмена"
                ,input "Приход топлива|Приход СУГ|Корректировка массы СУГ|Приход ТНП|Отказ от создания приходной накладной"
                ,input 4
                ,input 5
                ,output choice).
    case choice:
      when 1
      then do:
        trn-type = 1.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'is-fuel':U ,
                       input yes ) no-error .
        run adm/shattri.p (
            input "get":U
            ,input t-doc.obj-type
            ,input t-doc.obj-code
            ,input 'petrol':U
            ,input  "trnscanqr"
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output par-type
            ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
            ) no-error .
        if error-status :error
        then v-trnscanqr = false .
        else v-trnscanqr = v-value-logical .
        if v-trnscanqr
        then do :
          varlog = no.
          message "Читать QR код ПН?"
            view-as alert-box question buttons YES-NO update varlog.
          if varlog
          then do:
            run str/trnscanqr.w (parparentproc, t-doc.doc-code, "", this-procedure).
          end.
        end .
      end.
      when 2
      then do:
        trn-type = 2.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'is-lgas':U ,
                       input yes ) no-error .
      end.
      when 3
      then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'is-lgas-corr':U ,
                       input yes ) no-error .
        trn-type = 3.
        run add-lgas-corr no-error.
        if error-status :error then do:
          run proc-exit.
          return.
        end.
        run UI-on     in this-procedure ( input "line" ).
      end.
      when 4
      then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'trn-is-gds':U ,
                       input yes ) no-error .
        trn-type = 4.
      end.
      when 5 then do:
        run proc-exit.
        return.
      end.
    end.
   end.
   b-in-attr-fuel:sensitive = true.
   ub.goods.gds-name:width     in browse br-dtl   = 40.
  if not (trn-type = 2 or trn-type = 3 or trn-type = 1)
  then do:
    hide b-in-attr-fuel in frame d-in-doc.
  end.
  else do :
    t-doc.cli-qnty:label = "КолТТН(кг)" .
    t-doc.doc-qnty:label = "Док.кол-во(л)" .
    t-doc.fact-qnty:label = "Факт.кол-во(л)" .
  end .
  if trn-type = 2 then
  do:
    view b-calc-tp in frame d-in-doc .
    enable b-calc-tp with frame d-in-doc .
  end.
  else do:
    hide b-calc-tp in frame d-in-doc .
  end.
  IF mImagePh THEN
  DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
    if AVAILABLE goods then do:
      RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
      RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
      vCh = ENTRY (1, vImageList, ",":U).
      g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
      ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
    end.
  END.
  ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
  if is-copy
  then do:
    for first src-doc where recid (src-doc) = docrec-src no-lock:
      t-doc.cli-code = src-doc.cli-code.
      t-doc.cli-type = src-doc.cli-type.
      t-doc.cli-code:screen-value in frame d-in-doc = string (src-doc.cli-code).
      t-doc.cli-type:screen-value  in frame d-in-doc = src-doc.cli-type.
      find first ub.clients where ub.clients.obj-type = src-doc.cli-type and ub.clients.obj-code = src-doc.cli-code no-lock.
      disp ub.clients.obj-code @ t-doc.cli-code
              ub.clients.obj-name with frame d-in-doc.
      disp ub.clients.obj-type @ t-doc.cli-type with frame d-in-doc.
      run check-cli no-error.
      if error-status :error then return no-apply.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input src-doc.doc-code ,
                        input 'ptbobj':U ,
                       output varattr ,
                       output vartype ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'ptbobj':U ,
                       input varattr ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input src-doc.doc-code ,
                        input 'autoent':U ,
                       output varattr ,
                       output vartype ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'autoent':U ,
                       input varattr ) no-error .
      assign
        t-doc.contract-code = src-doc.contract-code
        t-doc.exch-code     = src-doc.exch-code
        t-doc.exch-rate     = src-doc.exch-rate
        t-doc.exch-scale    = src-doc.exch-scale
      .
      run fill-mol.
    end.
  end.
   if pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
     wait-for go of frame d-in-doc focus t-doc.cli-code.
   end.
   else do:
     browse br-dtl:SENSITIVE = true .
     menu-item m-outs-1:SENSITIVE = true .
     r-outs:SENSITIVE = true .
     wait-for go of frame d-in-doc focus br-dtl  .
   end.
end.
end.
run disable_ui in this-procedure.
PROCEDURE add-bc :
run corr-t-doc in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  run choose-bc  in this-procedure no-error.
  find t-doc where recid( t-doc ) = pardoc-rec.
  run UI-on in this-procedure ( input "line" ).
end procedure.
procedure proc-b-mark :
  run local-mark in this-procedure.
  assign varlog = br-dtl :select-next-row( ) in frame d-in-doc.
  apply "ENTRY":U to br-dtl in frame d-in-doc.
end procedure.
PROCEDURE add-doc-line-local :
define buffer bf_contract-specif for ub.contract-specif.
define buffer bf-hv_doc-line     for ub.doc-line.
define buffer bf_goods           for ub.goods.
define buffer buf_assortment-matrix for ub.assortment-matrix  .
define variable v-type-mode-spr as character no-undo .
define variable varschartic like doc-line.artic initial " " no-undo.
define variable v-choice    as   integer                    no-undo.
define variable v-rid       as   integer                    no-undo.
define variable v-rid-list  as   char                       no-undo.
define variable i           as   integer                    no-undo.
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
do on stop undo, return error return-value :
  run corr-t-doc in this-procedure no-error.
  if error-status:error then do:
    return error return-value.
  end.
  if trn-type = 2 or trn-type = 3 or trn-type = 1
  then do:
    if trn-type = 2 or trn-type = 3
    then do:
      run ref/gds-ref.p
      (
         input parparentproc
        ,input "b-sel"
        ,input 'все':U
        ,input "lgas"
        ,input 'все':U
        ,input ?
        ,input ?
        ,input t-doc.cli-type
        ,input t-doc.cli-code
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input ?
        ,output varnotes).
    end.
    else do:
      run ref/gds-ref.p
      (
         input parparentproc
        ,input "b-sel"
        ,input 'все':U
        ,input "ptrl"
        ,input 'все':U
        ,input ?
        ,input ?
        ,input t-doc.cli-type
        ,input t-doc.cli-code
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input ?
        ,output varnotes).
    end.
  end.
  else do:
    v-choice = 0.
    if t-doc.contract-code <> 0 then do:
define variable vss-include-info107 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  t-doc.host-code,
    INPUT  t-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = t-doc.host-code
      i-gl-Contract-Code  = t-doc.contract-code
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
      if available bf_contract-specif then do:
        run gbl/d-askw.w
          (input "Добавление товаров"
          ,input "Выберите один из пунктов для добавления в накладную" + chr(10)
               + "товаров по спецификации к договору" + chr(10)
          ,input "|"
          ,input "Все|Выборочно|По справочнику|Отказ"
          ,input "Все недобавленные товары по спецификации|"
               + "Выборочно товары по спецификации|"
               + "Выбор товаров из справочника|"
               + "Отказ от выполнения операции"
          ,input 1
          ,input 4
          ,output v-choice
          ).
        if v-choice = 4 then do:
          run UI-on in this-procedure ( input "line" ).
          return.
        end.
      end.
    end.
    if v-choice = 0 then
      v-choice = 3.
    assign
      varnotes = '':u
      varlns-cnt = 1.
    case v-choice:
      when 1 then do:
define variable vss-include-info108 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  t-doc.host-code,
    INPUT  t-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = t-doc.host-code
      i-gl-Contract-Code  = t-doc.contract-code
      .
END.
FOR EACH
    bf_contract-specif
     NO-LOCK
     WHERE
         bf_contract-specif.Host-code    = i-gl-Host-Code
     AND bf_contract-specif.Contract-num = i-gl-Contract-Code
            on error undo, return error return-value :
          find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
          find first bf-hv_doc-line where bf-hv_doc-line.doc-code  = t-doc.doc-code     and
                                          bf-hv_doc-line.artic     = bf_goods.artic     and
                                          bf-hv_doc-line.prod-type = bf_goods.prod-type and
                                          bf-hv_doc-line.prod-code = bf_goods.prod-code no-lock no-error.
          if not available bf-hv_doc-line then do:
            assign
              varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
          end.
        end.
        if varnotes = '':u then do:
          message "Вы добавили уже все товары по спецификации."
          view-as alert-box.
        end.
      end.
      when 2 then do:
        run str/contspec.w (input parparentproc,
                        input "b-sel,b-mark",
                        input 'ПРОСМОТР':U,
                        input t-doc.host-code,
                        input t-doc.contract-code,
                        output v-rid-list) .
        if v-rid-list = '':u then do:
          message "Нет выбранных товаров по спецификации."
            view-as alert-box.
        end.
        do i = 1 to num-entries(v-rid-list):
          v-rid = integer(entry(i, v-rid-list)).
          find bf_contract-specif where recid(bf_contract-specif) = v-rid no-lock no-error.
          if available bf_contract-specif then do:
            find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
            assign
              varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
          end.
        end.
      end.
      when 3 then do:
        find first buf_assortment-matrix no-lock where
                   buf_assortment-matrix.obj-code = v-cntxt-obj-code and
                   buf_assortment-matrix.obj-type = v-cntxt-obj-type and
                   buf_assortment-matrix.asmt-status = integer ('0':U) no-error .
                    if available buf_assortment-matrix then do:
                        v-type-mode-spr = 'объект':U .
                    end.
                    else do:
                        v-type-mode-spr = 'все':U .
                    end.
        run str/chs-gds.w ( input parparentproc
                      , input v-cntxt-obj-type
                      , input v-cntxt-obj-code
                      , input "":u
                      , input t-doc.status_
                      , input "Строка ПН № " + t-doc.doc-code + " " + t-doc.status_ + " " + string (t-doc.flag_, "+/-")
                      , input v-type-mode-spr
                      , input t-doc.cli-type
                      , input t-doc.cli-code
                      , input t-doc.host-code
                      , input t-doc.ext-doc-type
                      , input-output varschartic
                      , output varnotes) no-error.
      end.
    end case.
  end.
  run cycle-add in this-procedure.
  run UI-on     in this-procedure ( input "line" ).
end.
END PROCEDURE.
PROCEDURE after_qnty :
define  input parameter p-doc-line-rec as   recid                 no-undo.
  define output parameter p-out-qnty-kg  like ub.doc-line.fact-qnty no-undo initial 0.0.
  define variable p-inv-line-rec as recid   no-undo.
  define variable is-petrol      as logical no-undo.
  define variable is-pieces      as logical no-undo.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.
  do on error undo, return error return-value :
    find buf_doc-line       no-lock where recid( buf_doc-line ) = p-doc-line-rec no-error.
    if not available buf_doc-line then do:
      assign p-out-qnty-kg = ?.
      undo, return error "after_qnty: не найдена строка накладной".
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_price: &1 (произв. &2 &3) не топливный товар',
                                     buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ).
    end.
    find buf_inv-line          no-lock where
         buf_inv-line.doc-code  = buf_doc-line.doc-code  and
         buf_inv-line.artic     = buf_doc-line.artic     and
         buf_inv-line.prod-code = buf_doc-line.prod-code and
         buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
    if available buf_inv-line then do:
      assign
        p-inv-line-rec = recid( buf_inv-line )
      .
      find buf_doc-line exclusive-lock where recid( buf_doc-line ) = p-doc-line-rec.
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = p-inv-line-rec.
      assign
        p-out-qnty-kg = buf_inv-line.after-cli-qnty
      .
      find buf_inv-line        no-lock where recid( buf_inv-line ) = p-inv-line-rec.
      find buf_doc-line        no-lock where recid( buf_doc-line ) = p-doc-line-rec.
      release buf_inv-line.
      release buf_doc-line.
    end.
  end.
END PROCEDURE.
PROCEDURE apply-entry-next-field :
define input parameter parself-name as character no-undo.
  case parself-name:
  when "ship-num" then
       if t-doc.ship-date:sensitive in frame d-in-doc then apply "entry" to t-doc.ship-date in frame d-in-doc.
  when "ship-date" then
       if t-doc.tot-cli:sensitive in frame d-in-doc then apply "entry" to t-doc.tot-cli in frame d-in-doc.
  when "exch-date" then
       if t-doc.exch-code:sensitive in frame d-in-doc then apply "entry" to t-doc.exch-code in frame d-in-doc.
  when "tot-cli" then do:
       if b-add:sensitive  in frame d-in-doc then apply "entry" to b-add in frame d-in-doc.
  end.
  end case.
END PROCEDURE.
PROCEDURE ask-copy :
define variable v-num as integer initial 1 no-undo.
run gbl/d-askw.w
  (  input "Вопрос"
  ,  input "По каким количествам будем производить копирование?"
          + chr(10) + (if t-d-b.status_ <> 'запрос':U then "Внимание ! Если копировать из документарных количеств, то становится невозможным копирование с сохранением свойств партий документа источника." else "":U)
  ,  input "|^"
  ,  input "Фактическим|"
         + "Документарным|"
         + "Отмена"
  ,  input "Исходя из фактических количеств в признаках.|"
         + "Исходя из документарных количеств в признаках.|"
         + "Отменить копирование."
  ,  input 1
  ,  input 3
  , output v-num
  ).
  if v-num = 3 then do:
    return no-apply.
  end.
define variable vss-include-info109 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input parparentproc
 ,input recid(t-doc)
 ,input table lib-trn_ret-doc
 ,input table lib-trn_ret-line
 ,input table lib-trn_ret-line-attr
 ,input table lib-trn_ret-dtl
 ,input table lib-trn_ret-parts
 ,input yes
 ,input yes
 ,input no
 ,input (if v-num = 1 then yes else no)
 ,input this-procedure
  ) no-error .
if error-status:error then do:
assign
  pardoc-mode = 'ИЗМЕНЕНИЕ':U.
  run UI-on in this-procedure ( input "line" ) no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  return error return-value.
end.
assign
  pardoc-mode = 'ИЗМЕНЕНИЕ':U.
  run UI-on in this-procedure ( input "line" ).
END PROCEDURE.
PROCEDURE ass-frame-light :
define input parameter parself-name as character no-undo.
case parself-name:
  when "tot-cli"    then do: if input frame d-in-doc t-doc.tot-cli    <> t-doc.tot-cli    then assign frame d-in-doc t-doc.tot-cli    . end.
  when "tot-transp" then do: if input frame d-in-doc t-doc.tot-transp <> t-doc.tot-transp then assign frame d-in-doc t-doc.tot-transp . end.
  when "tot-other"  then do: if input frame d-in-doc t-doc.tot-other  <> t-doc.tot-other  then assign frame d-in-doc t-doc.tot-other  . end.
  when "ord-num"    then do: if input frame d-in-doc t-doc.ord-num    <> t-doc.ord-num    then assign frame d-in-doc t-doc.ord-num    . end.
  when "ship-num"   then do: if input frame d-in-doc t-doc.ship-num   <> t-doc.ship-num   then assign frame d-in-doc t-doc.ship-num   . end.
  when "ship-date"  then do: if input frame d-in-doc t-doc.ship-date  <> t-doc.ship-date  then assign frame d-in-doc t-doc.ship-date  . end.
end case.
END PROCEDURE.
PROCEDURE check-exch :
  if input frame d-in-doc t-doc.exch-date = ? then do:
    message "Не задана дата растаможивания.".
    apply "entry" to t-doc.exch-date in frame d-in-doc.
    return error.
  end.
  find ub.currency where ub.currency.curr-code = input t-doc.exch-code no-lock no-error.
  if not available ub.currency then do:
    message "Неправильная валюта поставщика - такой валюты нет.".
    apply "entry" to t-doc.exch-code in frame d-in-doc.
    return error.
  end.
  if t-doc.exch-code <> ub.currency.curr-code then do:
    if ub.currency.curr-code = 0 then do:
      if (t-doc.exch-rate <> ? and t-doc.exch-scale <> ? and
          (t-doc.exch-rate <> 1 or t-doc.exch-scale <> 1)) then do:
        varlog = no.
        message "Пересчитать цены поставщика в рубли по курсу поставщика ?"
                        view-as alert-box question buttons YES-NO update varlog.
        if varlog then do:
          run waitfram-show in this-procedure ( input "Пересчет цен поставщика в рубли. Ждите..." ).
          for each  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code:
             ub.doc-line.price-cli =  ub.doc-line.price-cli * t-doc.exch-rate / t-doc.exch-scale.
          end.
          run waitfram-hide in this-procedure .
        end.
      end.
      t-doc.print-rubl = yes.
      assign
        t-doc.exch-rate = 1
        t-doc.exch-scale = 1.
      disable t-doc.exch-rate t-doc.exch-scale r-acc with frame d-in-doc.
    end.
    else do:
      find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code
                             and ub.curr-accnt.exch-date <= input t-doc.exch-date use-index pi no-lock no-error.
      if available ub.curr-accnt then do:
        assign
          t-doc.exch-rate = ub.curr-accnt.exch-rate
          t-doc.exch-scale = ub.curr-accnt.exch-scale.
      end.
      else do:
        assign
          t-doc.exch-rate = ?
          t-doc.exch-scale = ?.
      end.
      if t-doc.exch-code = 0 and
        (t-doc.exch-rate  <> ? and
         t-doc.exch-scale <> ? and
         (t-doc.exch-rate <> 1 or t-doc.exch-scale <> 1)
        ) then do:
        varlog = no.
        message "Пересчитать цены поставщика в валюту ГТД по курсу ММВБ (справочника) ?"
                        view-as alert-box question buttons YES-NO update varlog.
        if varlog then do:
          run waitfram-show in this-procedure ( input "Пересчет цен поставщика в валюту ГТД. Ждите..." ).
            for each  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code:
             ub.doc-line.price-cli =  ub.doc-line.price-cli / t-doc.exch-rate * t-doc.exch-scale.
          end.
          run waitfram-hide in this-procedure  .
        end.
      end.
      t-doc.print-rubl = no.
      enable t-doc.exch-rate t-doc.exch-scale r-acc with frame d-in-doc.
    end.
    assign
      t-doc.exch-code = ub.currency.curr-code.
    display t-doc.exch-code ub.currency.curr-abbr
            t-doc.exch-rate t-doc.exch-scale with frame d-in-doc.
  end.
end procedure.
PROCEDURE check-reason :
define variable j_rsn-code like ub.trn-reason.reason-code no-undo.
  assign j_rsn-code = ( input frame d-in-doc t-doc.reason-code ).
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = j_rsn-code no-error.
  if not available ub.trn-reason then do:
    if j_rsn-code <> ? and j_rsn-code <> 0 then do:
      message "Неверно указано основание (причина) создания документа." view-as alert-box error.
    end.
    assign  rsn-name = "".
    display rsn-name with frame d-in-doc.
    if j_rsn-code = ? or j_rsn-code = 0 then do:
      assign t-doc.reason-code = 0.
      return.
    end.
    else do:
      return error.
    end.
  end.
  assign  rsn-name = ub.trn-reason.reason-name.
  display rsn-name with frame d-in-doc.
  assign frame d-in-doc t-doc.reason-code.
END PROCEDURE.
PROCEDURE check-update :
define buffer ch-doc-line for  ub.doc-line.
  define buffer ch-goods    for ub.goods.
  define variable p-same-price as logical   no-undo.
  define variable v-insalepr   as logical   no-undo .
  for each ch-doc-line where ch-doc-line.doc-code = t-doc.doc-code:
      find first ch-goods where ch-goods.artic     = ch-doc-line.artic     and
                                ch-goods.prod-type = ch-doc-line.prod-type and
                                ch-goods.prod-code = ch-doc-line.prod-code no-lock.
define variable vss-include-info110 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ch-doc-line.obj-type
  ,input  ch-doc-line.obj-code
  ,input  ch-doc-line.artic
  ,input  ch-doc-line.prod-type
  ,input  ch-doc-line.prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  )  .
      if v-insalepr = true then do:
         message "Товар " ch-goods.artic " " ch-goods.prod-type " " ch-goods.prod-code
                 " принимается по продажной цене. Смена цен в накладной недопустима."
                 view-as alert-box error.
         return error.
      end.
      run trg/doclnupd.p ( input  ch-doc-line.doc-code,
                       input  t-doc.obj-type,
                       input  t-doc.obj-code,
                       input  ch-doc-line.artic,
                       input  ch-doc-line.prod-type,
                       input  ch-doc-line.prod-code,
                       output p-same-price) no-error.
      if error-status :error then do:
         message "Ошибка при просмотре учетных цен в партиях." view-as alert-box error.
         return error.
      end.
      if p-same-price = false then do:
         message "Нельзя изменять цены в строках, т.к. имеются разные учетные цены в партиях." SKIP
                 "Товар " ch-doc-line.artic SKIP
                          ch-doc-line.prod-type SKIP
                          ch-doc-line.prod-code
         view-as alert-box error.
         return error.
     end.
  end.
END PROCEDURE.
PROCEDURE chg-line :
define variable line-doc     as recid   no-undo.
define variable varext-cycle as logical no-undo.
define buffer chg-goods for ub.goods.
if not available  ub.doc-line then do:
  message "Неправильный выбор строки.".
  return error.
end.
do on error undo, return error return-value :
find chg-goods where chg-goods.prod-code =  ub.doc-line.prod-code  and
                     chg-goods.prod-type =  ub.doc-line.prod-type  and
                     chg-goods.artic     =  ub.doc-line.artic    no-lock.
line-rec  = recid(ub.doc-line).
line-doc  = RECID(t-doc).
gds-rec   = RECID(chg-goods).
varlns-cnt = 1.
run str/in-line.w ( input  parparentproc,
                    input  'ИЗМЕНЕНИЕ':U,
                    input  pardoc-rec,
                    input-output line-rec,
                    input  gds-rec,
                    input  varlns-cnt,
                    output varext-cycle,
                    input  0,
                    input  ?,
                    input varinplnsum ) no-error.
FIND t-doc WHERE RECID(t-doc) = line-doc.
run UI-on in this-procedure ( input "line" ).
end.
END PROCEDURE.
PROCEDURE chg-purch-code :
define buffer bf_doc-line for ub.doc-line.
define buffer bf_goods    for ub.goods.
define buffer bf_pl-gds   for ub.pl-gds.
define input parameter parpurch-int-code like ub.trn-doc.purch-code no-undo.
do transaction on error undo, return error return-value :
if parpurch-int-code = 3 then do:
  for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code on error undo, return error return-value :
    find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                              bf_goods.prod-type = bf_doc-line.prod-type and
                              bf_goods.prod-code = bf_doc-line.prod-code no-lock.
    find first bf_pl-gds where bf_pl-gds.gds-code = bf_goods.gds-code and
                               bf_pl-gds.obj-type = t-doc.obj-type    and
                               bf_pl-gds.obj-code = t-doc.obj-code    no-lock no-error.
    if available bf_pl-gds then do:
      message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " резервируется по складским местам." skip
              "Его нельзя приходывать на ответственное хранение."
      view-as alert-box error.
      return error.
    end.
  end.
end.
assign
  t-doc.purch-code = parpurch-int-code.
for each ub.parts where ub.parts.out-code = t-doc.doc-code on error undo, return error return-value :
  assign ub.parts.purch-code = t-doc.purch-code.
end.
end.
END PROCEDURE.
PROCEDURE chk-upd-date :
define input parameter parself-name as character no-undo.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
if input frame d-in-doc t-doc.fact-date  <> t-doc.fact-date  or
   input frame d-in-doc t-doc.shift-date <> t-doc.shift-date or
   input frame d-in-doc t-doc.shift-num  <> t-doc.shift-num then do:
if parself-name = "fact-date" then do:
define variable vss-include-info111 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
  if input frame d-in-doc t-doc.fact-date > v-today then do:
     message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
     display t-doc.fact-date with frame d-in-doc.
     return error.
  end.
if input frame d-in-doc t-doc.fact-date < v-today then do:
define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
    if v-back-date <> true then do:
      message "Запрещено работать задним числом !" view-as alert-box information .
      display t-doc.fact-date with frame d-in-doc.
      return error.
    end.
end.
  if input frame d-in-doc t-doc.fact-date < v-today - 7 then do:
     varlog = yes.
     message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
             "Отказаться от заведения даты?" view-as alert-box question
             buttons yes-no update varlog.
     if varlog then do:
        display t-doc.fact-date with frame d-in-doc.
        return error.
     end.
  end.
  assign varlog = no.
define variable vss-include-info112 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if varlog = no then do:
     display t-doc.fact-date with frame d-in-doc.
     return error.
  end.
  assign varlog = no.
  message "Вы хотите изменить фактическую дату?" skip
          "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
  view-as alert-box question buttons yes-no update varlog.
  if not varlog then do:
     display t-doc.fact-date with frame d-in-doc.
     return error.
  end.
end.
assign frame d-in-doc
  t-doc.fact-date
  t-doc.shift-date
  t-doc.shift-num
  t-doc.shift-name.
if t-doc.fact-date <> today
then
  t-doc.fact-time = if (time < (12 * 60 * 60)) then time else (12 * 60 * 60) .
if t-doc.fact-date = ? then t-doc.fact-time = ? .
end.
END PROCEDURE.
PROCEDURE choice-currency :
find ub.currency where ub.currency.curr-code = input frame d-in-doc t-doc.exch-code no-error.
if not available ub.currency then do:
  run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do: return error. end.
  find ub.currency where recid ( ub.currency ) = ref-rec.
end.
RUN exch-rate in this-procedure.
END PROCEDURE.
PROCEDURE choose-b-parts :
define variable varline-mode      as character no-undo .
if not available  ub.doc-line then do:
  message "Неправильный выбор строки - партии недоступны.".
  return error.
end.
line-rec = recid ( ub.doc-line).
find ub.goods where ub.goods.prod-code =  ub.doc-line.prod-code
             and ub.goods.prod-type =  ub.doc-line.prod-type
             and ub.goods.artic     =  ub.doc-line.artic no-lock.
gds-rec = recid (ub.goods).
do transaction on error   undo, return error return-value :
   if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
     find t-doc where recid (t-doc) = pardoc-rec exclusive.
     find  ub.doc-line where recid ( ub.doc-line) = line-rec exclusive.
     varline-mode = 'ИЗМЕНЕНИЕ':U.
     FOR EACH old-doc-line: DELETE old-doc-line. END.
     CREATE old-doc-line.
     BUFFER-COPY  ub.doc-line to old-doc-line.
   end.
   else varline-mode = 'ПРОСМОТР':U.
   if v-by-utd
   then do :
     parext-doc-mode = "vsd_corr-parts" .
   end .
   if parext-doc-mode = "vsd_corr-parts"
   or parext-doc-mode = "vsd"
   or  parext-doc-mode = "corr-parts"
   then do :
     find t-doc where recid (t-doc) = pardoc-rec exclusive.
     find doc-line where recid (doc-line) = line-rec exclusive.
     varline-mode = parext-doc-mode.
   end .
   run str/parts-l.w
     (  input parparentproc
     ,  input t-doc.obj-type
     ,  input t-doc.obj-code
     ,  input ub.goods.gds-code
     ,  input t-doc.doc-code
     ,  input varline-mode
     ,  input 'документ':U
     ,  input 'текущий':U
     ,  input 'документ':U
     , output prt-rec
     ) .
   run str/chk-prt.p ( input line-rec, input no, buffer t-doc ).
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_chkwhole in g#lib-trn
  ( input ub.doc-line.doc-code
   ,input ub.doc-line.artic
   ,input ub.doc-line.prod-type
   ,input ub.doc-line.prod-code
   ,input ub.doc-line.cli-qnty
   ,input ub.doc-line.doc-qnty
   ,input ub.doc-line.fact-qnty
   ,input yes
  ) no-error .
   if error-status :error then do: undo, return error return-value. end.
   if pardoc-mode = 'ИЗМЕНЕНИЕ':U then DO:
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
  ) no-error.
      if error-status :error then do: undo, return error return-value. end.
      run full-recount in this-procedure no-error.
      if error-status :error then do: undo, return error return-value. end.
   END.
end.
END PROCEDURE.
PROCEDURE choose-b-prt :
  define variable j_pl-code         as integer no-undo .
  define variable is_reserv-pl-code as logical no-undo .
  define variable is-petrol         as logical no-undo .
  define variable is-pieces         as logical no-undo .
if not available  ub.doc-line then do:
  message "Неправильный выбор строки.".
  return error.
end.
define variable prt-mode as character no-undo.
line-rec = recid ( ub.doc-line).
find ub.goods where ub.goods.prod-code =  ub.doc-line.prod-code
             and ub.goods.prod-type =  ub.doc-line.prod-type
             and ub.goods.artic     =  ub.doc-line.artic no-lock.
gds-rec = recid (ub.goods).
find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
if ub.gds-prt.node-name = '_Пустая шкала':U then do:
  message "Товар :" ub.goods.artic ub.goods.gds-name
                  "не делится на признаки - шкала недоступна.".
  return error.
end.
do transaction on error undo, return error:
   if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
     find t-doc    where recid (t-doc)    = pardoc-rec exclusive no-error.
     if not available t-doc then do:
       message "Документ не найден. Возможно удален." view-as alert-box error.
       return error.
     end.
     find  ub.doc-line where recid ( ub.doc-line) = line-rec exclusive .
     assign
       prt-mode = 'ШКАЛА':U.
     for each old-doc-line:
       delete old-doc-line.
     end.
     create old-doc-line.
     buffer-copy  ub.doc-line to old-doc-line.
   end.
   else do:
     find t-doc    where recid (t-doc) = pardoc-rec no-lock no-error.
     if not available t-doc then do:
       message "Документ не найден. Возможно удален." view-as alert-box error.
       return error.
     end.
     prt-mode = 'ПРОСМОТР':U.
   end.
   prt-rec = ?.
   if (t-doc.status_ = 'накл':U and t-doc.flag_ = no) or t-doc.status_ = 'запрос':U then do:
     run str/doc-p.p
       ( input parparentproc
       , input pardoc-rec
       , input line-rec
       , input gds-rec
       , input prt-mode )
       .
   end.
   else do:
     run str/fac-p.p
       ( input parparentproc
       , input pardoc-rec
       , input line-rec
       , input gds-rec
       , input prt-mode     )
       .
   end.
   if line-rec <> ? then do:
      run str/chk-prt.p ( input line-rec, input no, buffer t-doc ).
   end.
   if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
      if line-rec <> ? then do:
        find first ub.goods no-lock
          where ub.goods.artic     =  ub.doc-line.artic
            and ub.goods.prod-type =  ub.doc-line.prod-type
            and ub.goods.prod-code =  ub.doc-line.prod-code
          .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
        if not error-status :error
          and v-is-ptrl = "yes"
          and is-petrol = true
          and is-pieces = false
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Топливный товар не разбивается по шкалам!!!!!" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        run plgdsfnd in this-procedure
          (  input no
          ,  input t-doc.obj-type
          ,  input t-doc.obj-code
          ,  input ub.goods.gds-code
          , output is_reserv-pl-code
          , output j_pl-code
          ) no-error .
        if error-status :error then do:
          message
            "Ошибка при выборе складского места." skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if is_reserv-pl-code = yes then do:
        end.
      end.
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
  ) no-error.
      if error-status :error then do: undo, return error. end.
      run full-recount in this-procedure no-error.
      if error-status :error then do: undo, return error return-value. end.
   end.
end.
END PROCEDURE.
PROCEDURE choose-bc :
define variable vss-include-info113 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-have-slt-pc   as logical                 no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
define variable b-c             as integer                 no-undo.
define variable b-c-char        as character               no-undo.
define variable rate            as decimal                 no-undo.
define variable temp-mes        as character               no-undo.
define variable is-petrolium    as logical                 no-undo.
define variable is-pieces       as logical                 no-undo.
define variable varext-cycle    as logical                 no-undo.
define variable v-part-code     as character               no-undo.
assign
  line-rec = ?
  prt-rec = ?
  varlns-cnt = 1
  add-sens = b-add:SENSITIVE  in frame d-in-doc
  b-c = 0
  gds-rec = ?
  pardoc-rec = RECID(t-doc)
  .
DO WHILE b-c <> ?:
   run str/chs-bc.w (parparentproc, "Строка накладной № " + t-doc.doc-code, add-sens, YES, YES, output b-c-char, output rate, output ret-mode, input-output add-scan, input-output bar-str).
   b-c = integer(b-c-char).
      IF b-c <> ? then DO:
      run checkTypeByBarCode in this-procedure (b-c, t-doc.ext-doc-type) no-error.
      if error-status:error then next.
      find ub.bar-code where ub.bar-code.b-code = b-c no-lock no-error.
      find ub.goods where ub.goods.gds-code  = ub.bar-code.gds-code no-lock.
      find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
      ASSIGN gds-rec = RECID(ub.goods).
      FIND ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code  and
                          ub.doc-line.artic     = ub.goods.artic     and
                          ub.doc-line.prod-type = ub.goods.prod-type and
                          ub.doc-line.prod-code = ub.goods.prod-code NO-LOCK NO-ERROR.
      IF AVAILABLE ub.doc-line THEN
         assign
         line-rec  = RECID(ub.doc-line).
      ELSE DO:
          IF t-doc.flag_ THEN DO:
             MESSAGE "Товар: " ub.goods.artic " " ub.goods.prod-type " " ub.goods.prod-code " не найден в документе."
             VIEW-AS ALERT-BOX ERROR BUTTONS OK.
             UNDO, return no-apply.
          END.
          assign
              line-rec = ?.
          assign prt-rec   = ?
                 varnotes = ''
                 varlns-cnt = 1.
      END.
      d-l:
      DO transaction ON ERROR   UNDO d-l, return error return-value :
         IF not add-scan THEN DO:
            if ub.gds-prt.node-name <> '_Пустая шкала':U and not can-find (first ub.gds-prt where ub.gds-prt.upper-code = bar-code.node-code) THEN DO:
               find ub.gds-prt where ub.gds-prt.node-code = ub.bar-code.node-code no-lock.
               if NOT AVAILABLE doc-line THEN do:
                 run str/in-line.w (input  parparentproc,
                                    input  'ИЗМЕНЕНИЕ':U,
                                    input  pardoc-rec,
                                    input-output  line-rec,
                                    input  gds-rec,
                                    input  varlns-cnt,
                                    output varext-cycle,
                                    0,
                                    ?,
                                    varinplnsum) no-error.
               end.
               ELSE DO:
                  run str/out-prt.w (
                       parparentproc ,
                       pardoc-rec    ,
                       line-rec      ,
                       gds-rec       ,
                       'ШКАЛА':U    ,
                       recid (gds-prt),
                       'терм':U)
                       no-error.
                  if error-status :error then do: undo d-l, leave. end.
                  run str/chk-prt.p (line-rec, no, buffer t-doc) no-error.
                  if error-status :error THEN do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Ошибка про проверке разнесения строки по признакам" skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error .
                    UNDO d-l, LEAVE.
                  end.
               END.
            END.
            ELSE do:
              run str/in-line.w (input  parparentproc,
                                 input  (if line-rec = ? then 'ДОБАВЛЕНИЕ':U else  'ИЗМЕНЕНИЕ':U ),
                                 input  pardoc-rec,
                                 input-output  line-rec,
                                 input  gds-rec,
                                 input  varlns-cnt,
                                 output varext-cycle,
                                 0,
                                 ?,
                                 varinplnsum) no-error.
            end.
         END.
         ELSE DO:
            if not can-find (first ub.gds-prt where ub.gds-prt.upper-code = bar-code.node-code) THEN DO:
               if NOT AVAILABLE doc-line THEN do:
                 run str/in-line.w (input  parparentproc,
                                    input  'ИЗМЕНЕНИЕ':U,
                                    input  pardoc-rec,
                                    input-output  line-rec,
                                    input  gds-rec,
                                    input  varlns-cnt,
                                    output varext-cycle,
                                    input  rate,
                                    input  "doc",
                                    input  varinplnsum ) no-error.
               end.
               ELSE DO:
                  run str/copy-tmp.p (input parparentproc, input pardoc-rec, input gds-rec, b-c, rate) no-error.
                  if error-status :error THEN do: UNDO d-l, LEAVE. end.
               END.
            END.
            ELSE DO:
               IF AVAILABLE ub.doc-line THEN DO:
                 run get-alc-part in this-procedure
                   (input recid(ub.doc-line),
                    output v-part-code
                   ).
                 IF NOT t-doc.flag_ THEN DO:
                    find ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                                     ub.goods.prod-type = ub.doc-line.prod-type and
                                     ub.goods.prod-code = ub.doc-line.prod-code no-lock.
                    find ub.units   where ub.units.unit-name    = ub.goods.unit-base no-lock.
                    run prev-cor-line in this-procedure
                      ( input ub.units.type
                      , input ub.doc-line.obj-type
                      , input ub.doc-line.obj-code
                      , input ub.doc-line.artic
                      , input ub.doc-line.prod-type
                      , input ub.doc-line.prod-code
                      ) no-error.
                    if error-status :error then do:
                       message return-value view-as alert-box error.
                       undo d-l, leave.
                    end.
                    run str/cor-line.p
                      (input parparentproc
                      ,input-output line-rec
                      ,input ub.doc-line.doc-code
                      ,input ub.doc-line.prod-type
                      ,input ub.doc-line.prod-code
                      ,input ub.doc-line.artic
                      ,input ub.doc-line.cli-qnty  + rate / ub.doc-line.cli-base-rate
                      ,input ub.doc-line.cli-base-rate
                      ,input (ub.doc-line.cli-qnty  + rate / ub.doc-line.cli-base-rate) * ub.doc-line.cli-base-rate
                      ,input (ub.doc-line.cli-qnty  + rate / ub.doc-line.cli-base-rate) * ub.doc-line.cli-base-rate
                      ,input ub.doc-line.unit-cli
                      ,input ub.doc-line.vat-pc
                      ,input ub.doc-line.slt-pc
                      ,input ub.doc-line.price-cli
                      ,input ub.doc-line.price-base
                      ,input ub.doc-line.price-rubl
                      ,input ub.doc-line.new-price-sale
                      ,input ub.doc-line.wt-brutto
                      ,input ub.doc-line.num-place
                      ,input ub.doc-line.road-tax
                      ,input ub.doc-line.excise
                      ,input ub.doc-line.doc-density
                      ,input ub.doc-line.temperature
                      ,input ?
                      ,input ?
                      ,input ub.doc-line.cli-qnty  + rate / ub.doc-line.cli-base-rate
                      ,input ub.doc-line.fact-density
                      ,input ?
                      ,input no
                      ,input v-part-code
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ) no-error.
                    if error-status :error then do:
                      if error-status :get-message(1) <> ""
                      then do:
                        message
                          vss-workfile vss-revision vss-description skip
                          "Ошибка при вызове процедуры cor-line.p" skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error .
                      end.
                      UNDO d-l, leave.
                    end.
                 END.
                 ELSE DO:
                    find ub.goods where ub.goods.artic  = ub.doc-line.artic     and
                                     ub.goods.prod-type = ub.doc-line.prod-type and
                                     ub.goods.prod-code = ub.doc-line.prod-code no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
                    if is-petrolium and not is-pieces then do:
                       MESSAGE "В жидком топливе нельзя редактировать фактическое количество".
                       display ub.doc-line.fact-qnty WITH BROWSE br-dtl.
                       return error.
                    end.
                    run str/cor-line.p
                      (input parparentproc
                      ,input-output line-rec
                      ,input ub.doc-line.doc-code
                      ,input ub.doc-line.prod-type
                      ,input ub.doc-line.prod-code
                      ,input ub.doc-line.artic
                      ,input ub.doc-line.cli-qnty
                      ,input ub.doc-line.cli-base-rate
                      ,input ub.doc-line.fact-qnty + rate
                      ,input ub.doc-line.doc-qnty
                      ,input ub.doc-line.unit-cli
                      ,input ub.doc-line.vat-pc
                      ,input ub.doc-line.slt-pc
                      ,input ub.doc-line.price-cli
                      ,input ub.doc-line.price-base
                      ,input ub.doc-line.price-rubl
                      ,input ub.doc-line.new-price-sale
                      ,input ub.doc-line.wt-brutto
                      ,input ub.doc-line.num-place
                      ,input ub.doc-line.road-tax
                      ,input ub.doc-line.excise
                      ,input ub.doc-line.doc-density
                      ,input ub.doc-line.temperature
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ub.doc-line.fact-density
                      ,input ?
                      ,input no
                      ,input v-part-code
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ) no-error.
                    if error-status :error
                    then do:
                      if error-status :get-message(1) <> ""
                      then do:
                        message
                          vss-workfile vss-revision vss-description skip
                          "Ошибка при вызове процедуры cor-line.p" skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error .
                      end.
                      UNDO d-l, leave.
                    end.
                 END.
                 run str/chk-prt.p (line-rec, no, buffer t-doc) no-error.
                 if error-status :error THEN do:
                   message
                     vss-workfile vss-revision vss-description skip
                     "Ошибка про проверке разнесения строки по признакам" skip
                     error-status :get-message(1) skip
                     return-value skip
                     view-as alert-box error .
                    UNDO d-l, leave.
                  end.
               END.
               ELSE DO:
                 IF t-doc.status_ = 'накл':U THEN DO:
                    run str/in-line.w (input  parparentproc,
                                       input  'ИЗМЕНЕНИЕ':U,
                                       input  pardoc-rec,
                                       input-output  line-rec,
                                       input  gds-rec,
                                       input  varlns-cnt,
                                       output varext-cycle,
                                       rate,
                                       "doc",
                                       varinplnsum) no-error.
                 END.
                 ELSE DO:
define variable vss-include-info114 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info115 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-vat-pc
  ) no-error .
                   ASSIGN varprice-cli-temp      = 0
                          varprice-base-temp     = 0
                          varprice-rubl-temp     = 0
                          varvat-pc         = v-vat-pc
                          varcli-base-rate  = ub.goods.cli-base-rate
                          vardoc-qnty       = 0
                          varfact-qnty      = 0
                          varroad-tax       = 0
                          varexcise         = 0
                          vartransport-base = 0
                          vartransport-rubl = 0
                          varother-base     = 0
                          varother-rubl     = 0
                          varartic          = ub.goods.artic
                          varprod-type      = ub.goods.prod-type
                          varprod-code      = ub.goods.prod-code
                   .
                   run cpprclig in this-procedure   (
                    input        t-doc.doc-code          ,
                    input        t-doc.cli-code          ,
                    input        t-doc.cli-type          ,
                    input        t-doc.host-code         ,
                    input        t-doc.base-rate         ,
                    input        t-doc.base-scale        ,
                    input        t-doc.exch-rate         ,
                    input        t-doc.exch-scale        ,
                    input        t-doc.vat-type          ,
                    input        t-doc.slt-type          ,
                    input        ub.goods.artic          ,
                    input        ub.goods.prod-type      ,
                    input        ub.goods.prod-code      ,
                    input        yes                     ,
                    input        varcli-base-rate        ,
                    input        vartransport-rubl       ,
                    input        varother-rubl           ,
                    output       varprice-cli            ,
                    output       varprice-base           ,
                    output       varprice-rubl           ,
                    input-output varvat-pc               ,
                    input-output varslt-pc               ,
                    input-output varroad-tax             ,
                    input-output varexcise               ) no-error.
define variable vss-include-info116 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
     ASSIGN varprice-cli  = d-l-b.price-cli
            varprice-rubl = d-l-b.price-rubl
            varprice-base = d-l-b.price-base.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   t-doc.doc-code
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,input   t-doc.vat-type
  ,input   t-doc.slt-type
  ,input   varartic
  ,input   varprod-type
  ,input   varprod-code
  ,input   varprice-cli
  ,input   varcli-base-rate
  ,input   varprice-rubl
  ,input   varvat-pc
  ,input   varslt-pc
  ,input   varroad-tax
  ,input   vartransport-rubl
  ,input   varother-rubl
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
       ASSIGN varprice-cli  = varprice-cli
              varprice-rubl = varprice-rubl
              varprice-base = varprice-base.
     leave.
end.
                   RUN tax-val in this-procedure
                     (input  ?
                     ,input  ?
                     ,input  ?
                     ,input  ?
                     ,input  ?
                     ,input  ?
                     ,input  recid(ub.goods)
                     ,input  no
                     ,input  rdtaxcdvalue
                     ,input  vattaxcdvalue
                     ,input  exctaxcdvalue
                     ,input  no
                     ,input  v-cntxt-host-code-obj
                     ,input  v-cntxt-obj-type
                     ,input  v-cntxt-obj-code
                     ,input  ?
                     ,input  ?
                     ,output temp-mes
                     ,input-output temp-sale
                     ) no-error.
                   if error-status :error
                   then do:
                     return no-apply.
                   end.
                   define buffer exc-tt-tax for tt-tax.
                   find tt-tax where tt-tax.tax-code = integer(rdtaxcdvalue) no-lock.
                   find exc-tt-tax where exc-tt-tax.tax-code = integer(exctaxcdvalue) no-lock.
                   find ub.units   where ub.units.unit-name    = ub.goods.unit-base no-lock.
                   run prev-cor-line in this-procedure
                     ( input ub.units.type
                     , input t-doc.obj-type
                     , input t-doc.obj-code
                     , input ub.goods.artic
                     , input ub.goods.prod-type
                     , input ub.goods.prod-code
                     ) no-error.
                   if error-status :error then do:
                      message return-value view-as alert-box error.
                      undo d-l, leave.
                   end.
define variable vss-include-info117 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info118 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-vat-pc
  ) no-error .
define variable vss-include-info119 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-slt-pc
  ) no-error .
                   run str/cor-line.p
                     (input parparentproc
                     ,input-output line-rec
                     ,input t-doc.doc-code
                     ,input ub.goods.prod-type
                     ,input ub.goods.prod-code
                     ,input ub.goods.artic
                     ,input rate / ub.goods.cli-base-rate
                     ,input ub.goods.cli-base-rate
                     ,input (rate / ub.goods.cli-base-rate) * ub.goods.cli-base-rate
                     ,input (rate / ub.goods.cli-base-rate) * ub.goods.cli-base-rate
                     ,input ub.goods.unit-cli
                     ,input v-vat-pc
                     ,input v-slt-pc
                     ,input varprice-cli-temp
                     ,input varprice-base-temp
                     ,input varprice-rubl-temp
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input if available tt-tax then tt-tax.rate-value else 0
                     ,input if available exc-tt-tax then exc-tt-tax.rate-value else 0
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input rate / ub.goods.cli-base-rate
                     ,input ?
                     ,input ?
                     ,input no
                     ,input v-part-code
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ) no-error.
                   if error-status :error then do:
                      if error-status :get-message(1) <> ""
                      then do:
                        message
                          vss-workfile vss-revision vss-description skip
                          "Ошибка при вызове процедуры cor-line.p" skip
                          error-status :get-message(1) skip
                          return-value skip
                          view-as alert-box error .
                      end.
                     UNDO d-l, leave.
                   end.
                   run str/chk-prt.p (line-rec, no, buffer t-doc) no-error.
                   if error-status :error THEN do:
                     message
                       vss-workfile vss-revision vss-description skip
                       "Ошибка про проверке разнесения строки по признакам" skip
                       error-status :get-message(1) skip
                       return-value skip
                       view-as alert-box error .
                     UNDO d-l, leave.
                   end.
                 END.
               END.
            END.
         END.
      END.
   END.
END.
END PROCEDURE.
PROCEDURE corr-t-doc :
find t-doc where recid (t-doc) = pardoc-rec exclusive.
run check-exch in this-procedure.
run check-rate in this-procedure.
END PROCEDURE.
PROCEDURE cr-tt-upd :
do on error undo, return error return-value :
for each tt-upd-attr: delete tt-upd-attr. end.
for each tt-upd-attr-fuel: delete tt-upd-attr-fuel. end.
define variable vvv as character no-undo init "".
define buffer x-doc for ub.trn-doc  .
find first x-doc no-lock where recid(x-doc) = pardoc-rec no-error .
if available x-doc then do:
   vvv = x-doc.rcv-code .
end.
 if vvv <> "not_delete" then do:
        create tt-upd-attr.  assign  tt-upd-attr.code =  'nids':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
 end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'dids':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'nsf':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'dsf':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'expense_own':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ndog':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ddog':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ndov':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ddov':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'print-num':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'idCountryContr':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'car-time':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  't_pass-fname':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  't_pass-position':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  't_accept-fname':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  't_accept-position':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'ndovwho':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'nosn':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'Shipper':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'othermoves':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
if v-is-pharm = "yes":U then do:
    create tt-upd-attr.  assign  tt-upd-attr.code =  'ser_on_pack':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'ptbobj':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'ptb-item-pour':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'autoent':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'car-num':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'fio-driver':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'time-income':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'inspection-cert':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'date-cert':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'condition':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'seals-condition':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'date-pour':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'time-pour':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'acc-ship':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'doc-not':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'spisok-not-doc':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'time-start':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'time-end':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'trdcattr-date-start':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'trdcattr-date-end':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'clear-ac':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'sugtpattr-massa-sug':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'sugtpattr-teh-loss':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'sugtpattr-err-allow':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'date-income':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'date-pasport':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr-fuel.  assign  tt-upd-attr-fuel.code =  'num-pasport':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-cod in g#trdcalib (  input tt-upd-attr-fuel.code ,
                       output tt-upd-attr-fuel.type-attr ,
                       output tt-upd-attr-fuel.format-attr ,
                       output tt-upd-attr-fuel.fillin_width ,
                       output tt-upd-attr-fuel.fillin_height ,
                       output tt-upd-attr-fuel.label-attr ,
                       output tt-upd-attr-fuel.user-can-edit ,
                       output tt-upd-attr-fuel.output-display ,
                       output v-other  ,
                       output tt-upd-attr-fuel.proc-attr ,
                       output tt-upd-attr-fuel.full-screen-val ,
                       output tt-upd-attr-fuel.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
end.
end procedure.
procedure err-status :
   message "Данное действие недопустимо в статусе: "
           t-doc.status_ string( t-doc.flag_, "+/-":U ) "."
   view-as alert-box error.
end procedure.
PROCEDURE create-record :
define  input parameter p-doc-code   like ub.trn-doc.doc-code    no-undo.
  define  input parameter p-attr-code  like ub.doc-attr.attr-code  no-undo.
  define  input parameter p-attr-value like ub.doc-attr.attr-value no-undo.
  define output parameter p-exist      as   logical                no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-xst in g#trdcalib (  input p-doc-code ,
                        input p-attr-code ,
                       output p-exist )  .
  if p-exist = no then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input p-attr-code ,
                       input p-attr-value ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message( 1 ) '"' + p-attr-code + '"'
      view-as alert-box error.
    end.
  end.
END PROCEDURE.
procedure set-cli-cust :
  def input parameter p-clitype as char no-undo.
  def input parameter p-clicode as int  no-undo.
  define variable v-tmp-char like ub.thbj-attr.property-value-character no-undo .
  define variable v-tmp-date      like ub.thbj-attr.property-value-date    no-undo .
  define variable v-tmp-decimal   like ub.thbj-attr.property-value-decimal no-undo .
  define variable v-tmp-integer   like ub.thbj-attr.property-value-integer no-undo .
  define variable v-rvd-own-nb as logical no-undo .
  define variable v-rvd-own-nb-type as   character no-undo .
  find first clients where clients.obj-type = p-clitype and clients.obj-code = p-clicode no-lock no-error.
  if not available (clients)
  then do:
    return error "Не найден клиент - " + p-clitype + string(p-clicode).
  end.
  disp clients.obj-code @ t-doc.cli-code
          clients.obj-name with frame d-in-doc.
  disp clients.obj-type @ t-doc.cli-type with frame d-in-doc.
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input 'petrol':U
      ,input  "rvd-own-nb"
      ,output v-tmp-char
      ,output v-tmp-date
      ,output v-tmp-decimal
      ,output v-tmp-integer
      ,output v-rvd-own-nb
      ,output v-rvd-own-nb-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  if error-status :error then v-rvd-own-nb = false .
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
        v-can-edit = no .
        disable b-add b-del with frame d-in-doc.
      end .
    end .
  end .
      run check-cli no-error.
      if error-status :error then return no-apply.
  run fill-mol in this-procedure no-error .
end.
procedure cycle-add-cust :
  def input parameter p-recgds-list as character no-undo.
  v-modeetc = ",autotrnqr2d".
  varnotes = p-recgds-list.
  run cycle-add in this-procedure.
  run ui-on in this-procedure ( input "line" ).
end.
PROCEDURE cycle-add :
define buffer bf_goods  for ub.goods.
define buffer bf_pl-gds for ub.pl-gds.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.
define variable varext-cycle    as logical no-undo.
define variable v-is-petrol     as logical no-undo.
define variable v-is-pieces     as logical no-undo.
define variable v-log           as logical no-undo.
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
assign
  varlns-cnt = 1.
cycle:
do while varlns-cnt <= num-entries (varnotes):
  def var varvalue as character no-undo.
  def var vartype as character no-undo.
  assign  gds-rec = integer (entry (varlns-cnt, varnotes)).
  if t-doc.purch-code = 3 then do:
    find first bf_goods where recid(bf_goods) = gds-rec no-lock.
    find first bf_pl-gds where bf_pl-gds.gds-code = bf_goods.gds-code and
                               bf_pl-gds.obj-type = t-doc.obj-type    and
                               bf_pl-gds.obj-code = t-doc.obj-code    no-lock no-error.
    if available bf_pl-gds then do:
      message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " резервируется по складским местам." skip
              "Его нельзя приходовать на ответственное хранение."
      view-as alert-box error.
      assign varlns-cnt = varlns-cnt + 1.
      next.
    end.
  end.
  if vartpsi = "yes":u then do:
    find first bf_goods where recid(bf_goods) = gds-rec no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_igdstpsi in g#lib-trn3
(input bf_goods.gds-code
,input t-doc.obj-type
,input t-doc.obj-code
) no-error.
    if error-status :error then do:
      message return-value
      view-as alert-box.
      ASSIGN varlns-cnt = varlns-cnt + 1.
      next.
    end.
  end.
  varvalue = "" .
  find first bf_goods where recid(bf_goods) = gds-rec no-lock.
  run gds-attr-value in this-procedure
    (  input bf_goods.gds-code
    ,  input 'fuel-type':U
    , output varvalue
    , output vartype
    ) no-error .
  if varvalue = "metan"
  then do:
    message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
            "нельзя приходовать в ручном режиме."
    view-as alert-box error.
    assign varlns-cnt = varlns-cnt + 1.
    next.
  end.
  if trn-type = 4
  then do:
    run gds-attr-value in this-procedure
      (  input bf_goods.gds-code
        ,input 'fuel-type':U
        ,output varvalue
        ,output vartype
       ) .
    if varvalue = "lgas" and not (trn-type = 2 or trn-type = 3)then
    do:
      message "Товар СУГ:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              'нельзя приходовать в накладной типа "ТНП" или "Топливо".'
      view-as alert-box error.
      assign varlns-cnt = varlns-cnt + 1.
      next.
    end.
    if varvalue = "petrol" and not (trn-type = 1)then
    do:
      message "Топливный товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              'нельзя приходовать в накладной типа "ТНП" или "СУГ".'
      view-as alert-box error.
      assign varlns-cnt = varlns-cnt + 1.
      next.
    end.
  end.
  varvalue = "" .
  EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
  RUN gds-attr-value (
                      INPUT bf_goods.gds-code,
                      INPUT 'mark-type':U,
                      OUTPUT varvalue,
                      OUTPUT vartype
                      ).
  if varvalue > "" then do:
   if EDOParSec:GetIsMarkingForType(varvalue)
  then do :
      if  t-doc.ext-doc-type = 'ie':U then
      do:
          message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              "нельзя добавлять в ручном режиме, так как он подлежит маркировке."
              view-as alert-box error.
          assign
              varlns-cnt = varlns-cnt + 1.
          next.
      end.
      else
      do:
          message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              "нельзя добавлять в ручном режиме, так как он подлежит маркировке и должен добавляться помарочно."
              view-as alert-box error.
          assign
              varlns-cnt = varlns-cnt + 1.
          next.
      end.
  end .
   if  EDOParSec:IsEdo
   and (EDOParSec:GetIsArticForType(varvalue) or EDOParSec:GetIsEdoForType(varvalue))
  then do :
      if  t-doc.ext-doc-type = 'ie':U then
      do:
          message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
              "нельзя добавлять в ручном режиме, так как он подлежит маркировке."
              view-as alert-box error.
          assign
              varlns-cnt = varlns-cnt + 1.
          next.
      end.
  end .
  end.
  if can-find (FIRST ub.clients-attr no-lock where (ub.clients-attr.attr-code = 'supp-np':U or ub.clients-attr.attr-code = 'supp-lgas':U)
                                               and ub.clients-attr.attr-value = "yes")
  then do :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) no-error.
    if v-is-petrol then do :
      if not can-find (FIRST ub.clients-attr no-lock where ub.clients-attr.obj-type   = t-doc.cli-type
                                                        and ub.clients-attr.obj-code   = t-doc.cli-code
                                                        and
                                                          (ub.clients-attr.attr-code  = 'supp-np':U
                                                          or ub.clients-attr.attr-code  = 'supp-lgas':U
                                                          )
                                                        and ub.clients-attr.attr-value = "yes")
      then do :
        message
        "Контрагент документа не является поставщиком НП или СУГ." skip
        "Продолжить ввод товара?"
        view-as alert-box question buttons yes-no update v-log.
        if not v-log then leave cycle.
      end.
    end.
  end.
  assign
    pardoc-rec = recid(t-doc).
  run str/in-line.w (input  parparentproc,
                     input  ((if varlns-cnt > 1 then "ЦИКЛ":U else 'ДОБАВЛЕНИЕ':U) + v-modeetc),
                     input  pardoc-rec,
                     input-output line-rec,
                     input  gds-rec,
                     input  varlns-cnt,
                     output varext-cycle,
                     0,
                     ?,
                     varinplnsum) no-error.
  if varext-cycle = yes then do:
    leave cycle.
  end.
  find t-doc where recid(t-doc) = pardoc-rec.
  ASSIGN varlns-cnt = varlns-cnt + 1.
end.
END PROCEDURE.
PROCEDURE del-doc-line :
define variable rep-rec as recid no-undo.
do transaction on error undo, return error return-value :
if del-list = "" then do:
  if not available  ub.doc-line then do:
    message "Неправильный выбор строки.".
    return error.
  end.
  varlog = no.
  message "Удалить строку накладной ?   Вы уверены ?"
                view-as alert-box question buttons OK-Cancel update varlog.
  if NOT varlog then return error.
  line-rec = recid ( ub.doc-line).
  del-list = string (recid ( ub.doc-line)).
  get next br-dtl.
  if available  ub.doc-line then rep-rec = recid ( ub.doc-line).
  else do:
    reposition br-dtl to recid line-rec no-error.
    get prev br-dtl.
    rep-rec = recid ( ub.doc-line).
  end.
end.
else do:
  varlog = ?.
  message "УДАЛЕНИЕ  ПО  ОТМЕТКАМ  строк накладной ?" skip (2)
          "YES - удалить все отмеченные строки" skip
          "NO - оставить только отмеченные строки и удалить все остальные" skip (2)
          "CANCEL - ничего не удалять"
  view-as alert-box question buttons yes-no-cancel update varlog.
  if varlog = ? then return error.
  rep-rec = ?.
end.
if varlog then do:
  assign
    varlns-cnt = 1.
  do while varlns-cnt <= num-entries (del-list):
    assign
      line-rec   = integer (entry (varlns-cnt, del-list))
      varlns-cnt = varlns-cnt + 1.
    find  ub.doc-line where recid ( ub.doc-line) = line-rec exclusive.
    if  ub.doc-line.doc-code <> t-doc.doc-code then undo, return error.
    if t-doc.flag_ and  ub.doc-line.doc-qnty <> 0 then do:
      message "Нельзя удалить строку, которая была добавлена в открытый документ.  Артикул:"  ub.doc-line.artic.
      next.
    end.
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
    if error-status :error then do:
      undo, return error return-value.
    end.
    delete  ub.doc-line.
  end.
end.
else do:
  for each  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code:
    if can-do (del-list, string (recid ( ub.doc-line))) then next.
    if t-doc.flag_ and  ub.doc-line.doc-qnty <> 0 then do:
      message "Нельзя удалить строку, которая была добавлена в открытый документ.  Артикул:"  ub.doc-line.artic.
      next.
    end.
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
    if error-status :error then do:
      undo, return error return-value.
    end.
    delete  ub.doc-line.
  end.
end.
assign
  line-rec = rep-rec.
if available t-doc
then do:
  run gbl/calc-trn.p
    ( input parparentproc
    , input recid( t-doc )
    ) no-error .
  if error-status :error
  then do:
    message return-value skip
            error-status :get-message( 1 )
    view-as alert-box error .
    undo, return error .
  end.
end.
run ui-on in this-procedure ( input "line" ).
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-in-doc.
END PROCEDURE.
PROCEDURE disp-exch :
display
 t-doc.exch-rate
 t-doc.exch-scale
 t-doc.base-rate
 t-doc.base-scale
 with frame d-in-doc.
end procedure.
procedure fnd-an-doc :
find t-d-b where t-d-b.doc-code = input frame d-in-doc t-doc.out-code no-lock no-error.
if not available t-d-b then return error.
end procedure.
procedure disp-import :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
APPLY "row-leave" to BROWSE br-dtl.
DISPLAY pardoc-code @ t-doc.out-code WITH FRAME d-in-doc.
APPLY "RETURN" to t-doc.out-code IN FRAME d-in-doc.
end procedure.
PROCEDURE enable_UI :
  DISPLAY varcontract-prn-code varpurch-code-name ov-pc m-inc a-n-c loc-art
          loc-name loc-code varinplnsum wrkr-name agnt-name boss-name rsn-name
      WITH FRAME d-in-doc.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-name
      WITH FRAME d-in-doc.
  IF AVAILABLE ub.currency THEN
    DISPLAY ub.currency.curr-abbr
      WITH FRAME d-in-doc.
  IF AVAILABLE ub.pay-type THEN
    DISPLAY ub.pay-type.obj-name
      WITH FRAME d-in-doc.
  IF AVAILABLE t-doc THEN
    DISPLAY t-doc.cli-code t-doc.cli-type t-doc.exch-code t-doc.exch-date
          t-doc.discnt-pc t-doc.cst-code t-doc.exch-rate t-doc.exch-scale
          t-doc.tot-cli t-doc.base-rate t-doc.base-scale t-doc.out-code
          t-doc.pay-code t-doc.wrkr t-doc.ord-num t-doc.agnt t-doc.boss
          t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-name
          t-doc.shift-num t-doc.SLT-type t-doc.VAT-type t-doc.tot-transp
          t-doc.tot-other t-doc.ship-num t-doc.ship-date t-doc.tot-calc
          t-doc.road-tax t-doc.tot-sale t-doc.tot-fact t-doc.VAT-rubl
          t-doc.VAT-base t-doc.cli-qnty t-doc.doc-qnty t-doc.fact-qnty
          t-doc.reason-code
      WITH FRAME d-in-doc.
  ENABLE b-exit b-prev b-next b-revis b-arch b-add-doc b-cnt b-attr b-in-attr-fuel b-notes
         b-history b-print b-help t-doc.cli-code t-doc.cli-type
         ub.clients.obj-name varcontract-prn-code b-contr-lkp r-clients r-currency
         t-doc.exch-code t-doc.exch-date t-doc.discnt-pc t-doc.cst-code
         t-doc.exch-rate t-doc.exch-scale r-acc t-doc.tot-cli t-doc.base-rate
         t-doc.base-scale t-doc.out-code r-outs t-doc.pay-code r-pay
         varpurch-code-name t-doc.wrkr r-wrkr t-doc.ord-num t-doc.agnt r-agnt
         t-doc.boss r-boss t-doc.doc-date t-doc.fact-date t-doc.shift-date
         t-doc.shift-name t-doc.shift-num r-sht t-doc.SLT-type t-doc.VAT-type
         ov-pc b-add-doc-yes t-doc.tot-transp t-doc.tot-other m-inc
         t-doc.ship-num t-doc.ship-date r-reas a-n-c loc-art loc-name loc-code
         b-mark b-add b-prt b-parts b-lkp b-chg b-del b-live b-renum b-marks
         varinplnsum br-dtl ub.currency.curr-abbr t-doc.tot-calc t-doc.road-tax
         ub.pay-type.obj-name t-doc.tot-sale wrkr-name t-doc.tot-fact
         t-doc.VAT-rubl agnt-name t-doc.VAT-base boss-name t-doc.cli-qnty
         t-doc.doc-qnty t-doc.fact-qnty t-doc.reason-code rsn-name b-calc-tp
      WITH FRAME d-in-doc.
  VIEW FRAME d-in-doc.
  FRAME d-in-doc:SENSITIVE = NO.
END PROCEDURE.
PROCEDURE exch-rate :
display ub.currency.curr-code @ t-doc.exch-code with frame d-in-doc.
do transaction on error   undo, return error :
   run check-exch   in this-procedure.
   run check-rate   in this-procedure.
   run full-recount in this-procedure.
end.
run UI-on in this-procedure ( input "line" ).
apply "entry" to t-doc.tot-cli.
END PROCEDURE.
PROCEDURE fill-tt private :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_doc-line      for ub.doc-line.
define buffer bf_doc-line-attr for ub.doc-line-attr.
define buffer bf_gds-dtl       for ub.gds-dtl.
define buffer bf_parts         for ub.parts.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
for each lib-trn_ret-doc:
  delete lib-trn_ret-doc.
end.
create lib-trn_ret-doc.
buffer-copy bf_trn-doc to lib-trn_ret-doc.
for each lib-trn_ret-line:
  delete lib-trn_ret-line.
end.
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock :
  create lib-trn_ret-line.
  buffer-copy bf_doc-line except road-tax to lib-trn_ret-line .
  assign
    lib-trn_ret-line.cst-code = bf_trn-doc.cst-code.
end.
for each lib-trn_ret-line-attr:
  delete lib-trn_ret-line-attr.
end.
for each bf_doc-line-attr where bf_doc-line-attr.doc-code = bf_trn-doc.doc-code
                            and bf_doc-line-attr.attr-code <> 'old_other-ras'
no-lock :
  create lib-trn_ret-line-attr.
  buffer-copy bf_doc-line-attr to lib-trn_ret-line-attr.
end.
for each lib-trn_ret-dtl :
  delete lib-trn_ret-dtl.
end.
for each bf_gds-dtl where bf_gds-dtl.doc-code = bf_trn-doc.doc-code :
  create lib-trn_ret-dtl.
  buffer-copy bf_gds-dtl to lib-trn_ret-dtl.
end.
for each lib-trn_ret-parts :
  delete lib-trn_ret-parts.
end.
for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code :
  create lib-trn_ret-parts.
  buffer-copy bf_parts to lib-trn_ret-parts.
end.
end.
END PROCEDURE.
PROCEDURE full-recount :
for each  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   t-doc.doc-code
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,input   t-doc.vat-type
  ,input   t-doc.slt-type
  ,input   ub.doc-line.artic
  ,input   ub.doc-line.prod-type
  ,input   ub.doc-line.prod-code
  ,input   ub.doc-line.price-cli
  ,input   ub.doc-line.cli-base-rate
  ,input   ub.doc-line.price-rubl
  ,input   ub.doc-line.vat-pc
  ,input   ub.doc-line.slt-pc
  ,input   ub.doc-line.road-tax
  ,input   ub.doc-line.transport-rubl
  ,input   ub.doc-line.other-rubl
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
  if error-status :error then do:
    return error "Ошибка при пересчете линии документа".
  end.
  assign  ub.doc-line.price-cli  = varprice-cli
          ub.doc-line.price-rubl = varprice-rubl
          ub.doc-line.price-base = varprice-base
         .
define variable vss-include-info120 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run find-new-price-sale in this-procedure (
   input  ?
  ,input  ?
  ,input  ub.doc-line.doc-code
  ,input  ub.doc-line.artic
  ,input  ub.doc-line.prod-type
  ,input  ub.doc-line.prod-code
  ,input  ub.doc-line.price-rubl
  ,input  ub.doc-line.price-base
  ,input  varprice-no-vat-slt-rubl
  ,input  varprice-no-vat-slt-base
  ,input-output ub.doc-line.new-price-sale
    )
    no-error .
      if error-status :error then message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи"
        view-as alert-box error
      .
end.
run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ) no-error.
if error-status :error then do:
  return error return-value.
end.
END PROCEDURE.
PROCEDURE get-alc-part :
define input  parameter p-doc-line-recid as recid no-undo.
  define output parameter op-part-code as character no-undo.
  define variable v-gds-code       as integer no-undo.
  define variable v-alcohol-prod   as logical no-undo .
  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_parts    for ub.parts.
  assign
    op-part-code = ?
  .
  do on error undo, return error return-value :
define variable vss-include-info121 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run doclicod in g#library
  (input  p-doc-line-recid
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  v-gds-code
  ,input  'alcohol-prod=request':u
  ,output v-alcohol-prod
  )  .
    if v-alcohol-prod then do:
      find bf_doc-line no-lock where recid(bf_doc-line) = p-doc-line-recid.
      find first bf_parts no-lock
        where bf_parts.obj-type  = bf_doc-line.obj-type  and
              bf_parts.obj-code  = bf_doc-line.obj-code  and
              bf_parts.prod-type = bf_doc-line.prod-type and
              bf_parts.prod-code = bf_doc-line.prod-code and
              bf_parts.artic     = bf_doc-line.artic     and
              bf_parts.out-code  = bf_doc-line.doc-code
        no-error.
      if available bf_parts then do:
        assign
          op-part-code = bf_parts.part-code
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE init-attr-general :
do on error undo, return error return-value :
run cr-tt-upd .
define variable varexist                  as logical   no-undo.
  run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'nids':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'dids':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'nsf':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'dsf':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'expense_own':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ndog':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ddog':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ndov':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ddov':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'print-num':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'idCountryContr':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'car-time':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 't_pass-fname':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 't_pass-position':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 't_accept-fname':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 't_accept-position':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ndovwho':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'nosn':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'Shipper':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'othermoves':U                                                         ,  input  ""                                                         , output varexist ) no-error.
if v-is-pharm = "yes":U then do:
    run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'ser_on_pack':U                                                         ,  input  ""                                                         , output varexist ) no-error.
end.
end.
END PROCEDURE.
PROCEDURE inv-line_price :
define  input parameter p-doc-line-rec as   recid                  no-undo.
  define  input parameter p-print-rubl   as   logical                no-undo.
  define output parameter p-out-price-kg like ub.doc-line.price-rubl no-undo initial 0.0.
  define variable p-inv-line-rec as recid   no-undo.
  define variable is-petrol      as logical no-undo.
  define variable is-pieces      as logical no-undo.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.
  do on error undo, return error return-value :
    find buf_doc-line       no-lock where recid( buf_doc-line ) = p-doc-line-rec no-error.
    if not available buf_doc-line then do:
      assign p-out-price-kg = ?.
      undo, return error "inv-line_price: не найдена строка накладной".
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_price: &1 (произв. &2 &3) не топливный товар',
                                     buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ).
    end.
    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = buf_doc-line.doc-code  and
         buf_inv-line.artic     = buf_doc-line.artic     and
         buf_inv-line.prod-code = buf_doc-line.prod-code and
         buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
    if available buf_inv-line then do:
      assign
        p-inv-line-rec = recid( buf_inv-line )
      .
      find buf_doc-line exclusive-lock where recid( buf_doc-line ) = p-doc-line-rec.
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = p-inv-line-rec.
      assign
        p-out-price-kg = ( if p-print-rubl = yes then buf_inv-line.wast-rubl else buf_inv-line.wast-base )
      .
      find buf_inv-line        no-lock where recid( buf_inv-line ) = p-inv-line-rec.
      find buf_doc-line        no-lock where recid( buf_doc-line ) = p-doc-line-rec.
      release buf_inv-line.
      release buf_doc-line.
    end.
  end.
END PROCEDURE.
PROCEDURE inv-line_qnty :
define  input parameter p-doc-line-rec as   recid                 no-undo.
  define output parameter p-out-qnty-kg  like ub.doc-line.fact-qnty no-undo initial 0.0.
  define variable is-petrol as logical no-undo.
  define variable is-pieces as logical no-undo.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.
  do on error undo, return error return-value :
    find buf_doc-line no-lock where recid( buf_doc-line ) = p-doc-line-rec no-error.
    if not available buf_doc-line then do:
      assign p-out-qnty-kg = ?.
      undo, return error "inv-line_qnty: не найдена строка накладной".
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_qnty: &1 (произв. &2 &3) не топливный товар',
                                     buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ).
    end.
    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = buf_doc-line.doc-code  and
         buf_inv-line.artic     = buf_doc-line.artic     and
         buf_inv-line.prod-code = buf_doc-line.prod-code and
         buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
    if available buf_inv-line then do: assign p-out-qnty-kg = buf_inv-line.wast-cli-qnty. end.
  end.
END PROCEDURE.
PROCEDURE live-loc :
define variable to-date as date no-undo.
define variable vss-include-info122 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtget in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output to-date
  ) no-error .
  if error-status :error then do:
    assign to-date = today.
  end.
  find first supplier no-lock where
             supplier.obj-code = t-doc.cli-code and
             supplier.obj-type = t-doc.cli-type no-error .
  run rep/vs-part1.w (
      input parparentproc,
      input v-cntxt-obj-type,
      input v-cntxt-obj-code,
      input t-doc.doc-date,
      input to-date,
      input 'все':U,
      input t-doc.doc-code)
      .
END PROCEDURE.
PROCEDURE local-add-doc :
define buffer buf_add-doc for ub.add-doc .
define buffer buf_add-trn for ub.add-trn .
define variable v-recid as recid no-undo .
define variable v-mode as character no-undo .
define variable v-doc-code-add as character no-undo .
define variable v-today as date  no-undo .
define variable v-m as character no-undo .
define variable v-new as logical   no-undo .
v-m =  'ПРОСМОТР':U .
v-new = false  .
if pardoc-mode = 'ПРОСМОТР':U then v-mode = pardoc-mode .
                           else v-mode = 'ИЗМЕНЕНИЕ':U .
find first buf_add-trn no-lock where buf_add-trn.trn-doc-code =  t-doc.doc-code no-error .
if not available buf_add-trn then do:
   if v-mode = 'ПРОСМОТР':U then return .
    define variable obj-db-num as integer   no-undo .
define variable vss-include-info123 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output obj-db-num
  )  .
         if obj-db-num <> v-cntxt-db-num then do:
            message 'Создание ДопРасхода  только на активной стороне' view-as alert-box information .
            return .
         end.
   message 'Создавать новый документ дополнительных расходов ?'
            view-as alert-box question
            buttons yes-no
            update v-ok as logical
            .
   if v-ok = false then return .
define variable vss-include-info124 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
   v-new = true .
   run doc-code in this-procedure
     ( input "main":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input ?
      ,output v-doc-code-add
     ) no-error.
  if error-status :error then do:
    message
      "Ошибка при генерации номера документа."
      view-as alert-box error.
    return error.
  end.
   create ub.add-doc.
   assign
     ub.add-doc.doc-code   = v-doc-code-add
     ub.add-doc.base-rate  = t-doc.base-rate
     ub.add-doc.base-scale = t-doc.base-scale
     ub.add-doc.cr-db-num  = v-cntxt-db-num
     ub.add-doc.doc-date   = v-today
     ub.add-doc.exch-code  = if t-doc.exch-code = ?  then 0 else t-doc.exch-code
     ub.add-doc.exch-date  = v-today
     ub.add-doc.exch-rate  = if t-doc.exch-rate = ? or t-doc.exch-rate = 0 then 1 else t-doc.exch-rate
     ub.add-doc.exch-scale = if t-doc.exch-scale = ? or t-doc.exch-scale = 0 then 1 else t-doc.exch-scale
     ub.add-doc.host-code  = v-cntxt-host-code-obj
     ub.add-doc.obj-code   = v-cntxt-obj-code
     ub.add-doc.obj-type   = v-cntxt-obj-type
     ub.add-doc.status_    = 'новый':U
     ub.add-doc.VAT-type   = t-doc.VAT-type
   .
   create buf_add-trn .
   assign
     buf_add-trn.doc-code = v-doc-code-add
     buf_add-trn.trn-doc-code = t-doc.doc-code
   .
end.
else do:
   v-doc-code-add = buf_add-trn.doc-code .
end.
find first buf_add-doc exclusive-lock where
           buf_add-doc.doc-code = v-doc-code-add
           no-error .
if available buf_add-doc then do:
    v-recid = recid (buf_add-doc) .
    v-m = if buf_add-doc.status_ <> 'новый':U then 'ПРОСМОТР':U else ( if pardoc-mode = 'ДОБАВЛЕНИЕ':U then 'ИЗМЕНЕНИЕ':U else pardoc-mode )  .
    run str/add-docu.w
      ( input parparentproc ,
        input-output  v-recid ,
        input v-m ,
        input t-doc.doc-code
        ).
  if v-new = true and v-recid = ? then do:
      find first buf_add-doc exclusive-lock where
                buf_add-doc.doc-code = v-doc-code-add no-error .
     delete buf_add-doc .
  end.
end.
release buf_add-doc .
if can-find (first ub.add-trn no-lock where
                      ub.add-trn.doc-code      = v-doc-code-add  and
                      ub.add-trn.trn-doc-code  = t-doc.doc-code )
                      then do:
    enable b-add-doc-yes with frame d-in-doc .
    display b-add-doc-yes with frame d-in-doc .
end.
else hide b-add-doc-yes in frame d-in-doc .
if v-m = 'ПРОСМОТР':U then return .
find first buf_add-doc no-lock where
           buf_add-doc.doc-code = v-doc-code-add no-error .
if not available buf_add-doc then return .
if buf_add-doc.status_  = 'новый':U
then do:
   if can-find (first ub.add-line no-lock where
                      ub.add-line.doc-code  = buf_add-doc.doc-code ) and
      can-find (first ub.add-trn no-lock where
                      ub.add-trn.doc-code      = buf_add-doc.doc-code  and
                      ub.add-trn.trn-doc-code  = t-doc.doc-code )
                      then do:
     message
      substitute("Закрыть  ДопРасх № &1 до статуса ЗАКРЫТО ? " ,buf_add-doc.doc-code  )
      view-as alert-box question
      buttons yes-no
      update vok as log
     .
     if vok = false then return .
        run str/addclos.p
            ( input Parparentproc,
              recid(buf_add-doc)
            ) .
         end.
end.
END PROCEDURE.
PROCEDURE local-arh :
  run str/docsuppn.w
    (input  parparentproc
    ,input  recid(t-doc)
    ).
END PROCEDURE.
PROCEDURE local-bc :
if t-doc.status_ = 'накл':U and
    t-doc.flag_   = no      then do:
    run add-bc in this-procedure no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if t-doc.status_ = 'накл':U and
    t-doc.flag_   = yes     then do:
    run fact-bc in this-procedure ( input t-doc.doc-code ) no-error.
    if error-status :error then do: return no-apply. end.
    sort-default = yes. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK BY  ub.doc-line.line-num.
    display t-doc.fact-qnty with frame d-in-doc.
  end.
END PROCEDURE.
PROCEDURE local-conf-rd :
do on error undo, return error return-value :
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
  )  .
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
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varhold
  ,output varhold-type
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'tpsi'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output vartpsi
  ,output vartpsi-type
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-tsd'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-tsd
  ,output v-is-tsd-type
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-pharm'
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-pharm
  ,output v-is-pharm-type
  ) no-error .
 .
if v-is-pharm <> "yes" then v-is-pharm = "no" .
else do:
define variable vss-include-info125 as character format "x(65)" no-undo initial "@(#)$workfile: $ $revision: $".
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
     v-is-pharm = "no"  .
  end.
end.
define variable vss-include-info126 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
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
varvat-type-int = 1 .
varslt-type-int = 3 .
v-not-ord = false .
v-back-date = false .
var-inp_sum  = false .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'type-vat' then varvat-type-int = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'type-slt' then varslt-type-int = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'inp_sum'  then var-inp_sum     = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'not-ord'  then v-not-ord       = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'back-date' then v-back-date    = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'inv-ship' then  inv-shipvalue  = thbjattr_thbj-attr.property-value-logical .
end.
define variable vss-include-info127 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if thbjattr_thbj-attr.prop-code = 'convimp'  then convimpvalue  = string (thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'is-ov'    then is-ovvalue    = string (thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'is-bcdoc' then bcvalue       = string (thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'multdtyp' then multdtypvalue = string (thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'curcli'   then curclivalue   = string (thbjattr_thbj-attr.property-value-logical) .
end.
empty temp-table thbjattr_thbj-attr.
if pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
    if v-not-ord = true then do:
      message "Запрещено заводить ПН вручную !" view-as alert-box information .
      return error.
    end.
end.
case varvat-type-int:
when 1 or when ? then do:
  assign
    varvat-type-def = 'в т. ч.':U.
end.
when 2 then do:
  assign
    varvat-type-def = 'нет':U.
end.
when 3 then do:
  assign
    varvat-type-def = 'без':U.
end.
otherwise do:
  message "Не верно задан атрибут 'Тип заведения НДС' (type-vat)."
          "Задано значение: " varvat-type-int
          "Допустимые значения: 1,2,3."
  view-as alert-box error.
  return error.
end.
end case.
case varslt-type-int:
when 1 then do:
  assign
    varslt-type-def = 'в т. ч.':U.
end.
when 2 then do:
  assign
    varslt-type-def = 'нет':U.
end.
when 3 or when ? then do:
  assign
    varslt-type-def = 'без':U.
end.
otherwise do:
  message "Не верно задан атрибут 'Тип заведения НП' (type-slt)."
          "Задано значение: " varslt-type-int
          "Допустимые значения: 1,2,3."
  view-as alert-box error.
  return error.
end.
end case.
assign
  rdtaxcdvalue  = '3':U
  vattaxcdvalue = '1':U
  exctaxcdvalue = '4':U.
end.
END PROCEDURE.
PROCEDURE local-lockup :
define variable varext-cycle as logical no-undo.
if not available  ub.doc-line then do:
  message "Неправильно выбрана строка.".
  return error.
end.
find ub.goods where ub.goods.artic     =  ub.doc-line.artic and
                 ub.goods.prod-type =  ub.doc-line.prod-type and
                 ub.goods.prod-code =  ub.doc-line.prod-code no-lock.
gds-rec = RECID(ub.goods).
pardoc-rec = RECID(t-doc).
assign
  line-rec = recid ( ub.doc-line)
  varlns-cnt = 1.
run str/in-line.w ( input  parparentproc,
                    input  'ПРОСМОТР':U,
                    input  pardoc-rec,
                    input-output  line-rec,
                    input  gds-rec,
                    input  varlns-cnt,
                    output varext-cycle,
                    input 0,
                    input ?, input varinplnsum ) no-error.
FIND t-doc WHERE RECID(t-doc) = pardoc-rec.
apply "entry" to br-dtl in frame d-in-doc.
END PROCEDURE.
PROCEDURE local-m-outs-5 :
define buffer   bf_trn-doc for ub.trn-doc.
  define variable vardoc-code like ub.trn-doc.doc-code no-undo.
  if (t-doc.status_ = 'накл':U or t-doc.status_ = 'запрос':U) and
      not t-doc.flag_
  then do:
define variable vss-include-info128 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_import':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    assign vardoc-code = "import-" + t-doc.doc-code.
    run utl/imp-allc.p ( input parparentproc,
                     input 2,
                     input ?,
                     input ?,
                     input t-doc.exch-code,
                     input vardoc-code,
                     input t-doc.cli-type,
                     input t-doc.cli-code,
                     input t-doc.host-code  ) no-error.
    if error-status :error then do:
      message "Ошибка при конвертации и формировании файла import." view-as alert-box error.
      return error.
    end.
    run disp-import in this-procedure ( input vardoc-code ) no-error.
    find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code.
    delete bf_trn-doc.
  end.
  else do:
    message "Данное действие недопустимо в статусе: "
            t-doc.status_ string( t-doc.flag_, "+/-":U ) "."
    view-as alert-box error.
    return error.
  end.
END PROCEDURE.
PROCEDURE local-mark :
if not available  ub.doc-line then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info129 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid130 as character no-undo .
define variable v-num-entry130 as integer   no-undo .
assign
  v-str-recid130 = trim( string( recid( ub.doc-line ) , "->>>>>>>>>>>9":U ) )
  v-num-entry130 = lookup( v-str-recid130 , del-list )
.
if v-num-entry130 > 0 then do:
  assign
    entry( v-num-entry130, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid130
  .
end.
  br-dtl:refresh() in frame d-in-doc .
END PROCEDURE.
PROCEDURE local-row-leave :
define variable var_is-petrol as logical no-undo .
  define variable var_is-pieces as logical no-undo .
if available  ub.doc-line then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.doc-line.artic
  ,  input ub.doc-line.prod-type
  ,  input ub.doc-line.prod-code
  , output var_is-petrol
  , output var_is-pieces
  ) no-error.
  if error-status :error
  then do:
    return .
  end.
  if var_is-petrol = yes and
     var_is-pieces = no
  then do:
    if decimal(  ub.doc-line.cli-qnty :screen-value in browse br-dtl ) <>  ub.doc-line.cli-qnty
    then do:
      display  ub.doc-line.cli-qnty with browse br-dtl .
      message substitute( 'В жидком топливе нельзя редактировать количество.&1'
                        , ( if b-chg :sensitive in frame d-in-doc
                            then substitute( '&1Воспользуйтесь кнопкой "&2".'
                                           , chr(10)
                                           , replace( b-chg :label in frame d-in-doc, "&", "":U )
                                           )
                            else '':U )
                        )
      view-as alert-box error .
    end.
    else
    if decimal(  ub.doc-line.fact-qnty :screen-value in browse br-dtl ) <>  ub.doc-line.fact-qnty
    then do:
      display  ub.doc-line.fact-qnty with browse br-dtl .
      message substitute( 'В жидком топливе нельзя редактировать фактическое количество.&1'
                        , ( if b-chg :sensitive in frame d-in-doc
                            then substitute( '&1Воспользуйтесь кнопкой "&2".'
                                           , chr(10)
                                           , replace( b-chg :label in frame d-in-doc, "&", "":U )
                                           )
                            else '':U )
                        )
      view-as alert-box error .
    end.
    return .
  end.
  define variable v-gds-code as integer   no-undo .
  define variable v-update-ok   as logical   no-undo .
  define variable v-err-message as character no-undo .
define variable vss-include-info131 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run doclicod in g#library
  (input  recid(ub.doc-line)
  ,output v-gds-code
  )  .
  v-fact-qnty = ub.doc-line.fact-qnty:screen-value in browse br-dtl.
  if dec ( ub.doc-line.cli-qnty:screen-value in browse br-dtl) <>  ub.doc-line.cli-qnty then do:
    if v-edit-fact-wayb and not t-doc.flag_ and dec (ub.doc-line.cli-qnty:screen-value in browse br-dtl) <> ub.doc-line.cli-qnty
    then do:
      if v-edit-fact-wayb and not t-doc.flag_
      then do:
        ub.doc-line.fact-qnty:screen-value in browse br-dtl = string (ub.doc-line.cli-base-rate * ub.doc-line.cli-qnty).
        t-doc.flag_ = true.
        run str/doclinfq.p
          (input  parparentproc
          ,buffer t-doc
          ,buffer  ub.doc-line
          ,input  decimal( ub.doc-line.fact-qnty:screen-value in browse br-dtl)
          ,output v-update-ok
          ,output v-err-message
          ) no-error .
        if error-status :error
        or v-update-ok = false
        then do:
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры doclinfq.p" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          else do:
            message
              v-err-message
              view-as alert-box information .
          end.
          display
             ub.doc-line.fact-qnty
            with browse br-dtl .
          t-doc.flag_ = false.
          return.
        end.
        t-doc.flag_ = false.
      end.
    end.
    run upd-cli-qnty in this-procedure no-error.
    if error-status :error then
    do:
      display  ub.doc-line.cli-qnty with browse br-dtl.
      return.
    end.
  end.
  if dec ( v-fact-qnty ) <>  ub.doc-line.fact-qnty then do:
    run str/doclinfq.p
      (input  parparentproc
      ,buffer t-doc
      ,buffer  ub.doc-line
      ,input  decimal( ub.doc-line.fact-qnty:screen-value in browse br-dtl)
      ,output v-update-ok
      ,output v-err-message
      ) no-error .
    if error-status :error
    or v-update-ok = false
    then do:
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры doclinfq.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      else do:
        message
          v-err-message
          view-as alert-box information .
      end.
      display
         ub.doc-line.fact-qnty
        with browse br-dtl .
      return.
    end.
    if v-edit-fact-wayb and not t-doc.flag_
    then do:
      t-doc.flag_ = true.
      ub.doc-line.fact-qnty:screen-value in browse br-dtl = v-fact-qnty.
      run str/doclinfq.p
        (input  parparentproc
        ,buffer t-doc
        ,buffer  ub.doc-line
        ,input  decimal( ub.doc-line.fact-qnty:screen-value in browse br-dtl)
        ,output v-update-ok
        ,output v-err-message
        ) no-error .
      if error-status :error
      or v-update-ok = false
      then do:
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры doclinfq.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        else do:
          message
            v-err-message
            view-as alert-box information .
        end.
        display
           ub.doc-line.fact-qnty
          with browse br-dtl .
        t-doc.flag_ = false.
        return.
      end.
      t-doc.flag_ = false.
    end.
    do
    on error undo, return error return-value
    :
      define buffer buf_doc-line for ub.doc-line .
      find first buf_doc-line exclusive-lock where
          recid( buf_doc-line ) = recid(  ub.doc-line ) .
      assign
        buf_doc-line.fact-qnty = decimal(  ub.doc-line.fact-qnty :screen-value in browse br-dtl )
      .
      find first buf_doc-line        no-lock where
          recid( buf_doc-line ) = recid(  ub.doc-line ) .
    end.
    run ui-on in this-procedure
      ( input "line"
      ) .
  end.
end.
END PROCEDURE.
PROCEDURE local-upd-inplnsum :
do on error undo, return error return-value :
if input frame d-in-doc varinplnsum <> varinplnsum then do:
  if input frame d-in-doc varinplnsum = yes then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'indoclnsum':U ,
                       input 'yes' ) no-error .
    if error-status :error then do:
      message "Ошибка при изменении атрибута " 'indoclnsum':U " в документе " t-doc.doc-code " ." skip
              error-status:get-message(1) skip
              return-value
      view-as alert-box error.
      undo, return error.
    end.
  end.
  else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'indoclnsum':U ,
                       input 'no' ) no-error .
    if error-status :error then do:
      message "Ошибка при изменении атрибута " 'indoclnsum':U " в документе " t-doc.doc-code " ." skip
              error-status:get-message(1) skip
              return-value
      view-as alert-box error.
      undo, return error.
    end.
  end.
  assign frame d-in-doc
    varinplnsum.
end.
end.
END PROCEDURE.
PROCEDURE local-upd-m-inc :
do on error undo, return error return-value :
    if input frame d-in-doc m-inc <> m-inc then do:
      define variable v-temp as character no-undo .
      assign v-temp = input frame d-in-doc m-inc .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'm_inc':U ,
                       input v-temp ) no-error .
      if error-status :error then do:
        message "Ошибка при изменении атрибута " 'm_inc':U " в документе " t-doc.doc-code " ." skip
                error-status :get-message( 1 ) skip
                return-value
        view-as alert-box error.
        undo, return error.
      end.
      assign frame d-in-doc
        m-inc.
    end.
  end.
END PROCEDURE.
PROCEDURE out-doc-rec :
  run fnd-an-doc in this-procedure no-error.
  if error-status :error then do:
     run proc-m-outs-1 in this-procedure.
  end.
  else do:
      run fill-tt in this-procedure ( input t-d-b.doc-code ) no-error.
      if error-status :error then  return error return-value.
      run ask-copy in this-procedure no-error .
      if error-status :error then return error return-value .
  end.
END PROCEDURE.
PROCEDURE ov-pc :
define buffer d-l-b for  ub.doc-line.
define buffer ov-goods for ub.goods.
define buffer ov-units for ub.units.
define variable v-ov-pc as decimal no-undo .
if input frame d-in-doc ov-pc <> 0 then do:
   run check-update in this-procedure no-error.
   if error-status :error then do: return error. end.
 end.
assign
  v-ov-pc = input frame d-in-doc ov-pc.
if v-ov-pc <> 0  then do:
  if v-ov-pc <= -100 then do:
    message
      "Вы ввели недопустимый процент скидки" v-ov-pc skip
      "Он не может быть меньше чем -100%" skip
      view-as alert-box error .
    return error .
  end.
  def var v-num             as integer no-undo .
  def var l-selection-exist as logical no-undo .
  assign
   l-selection-exist = (del-list <> "")
  .
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Пересчитать накладную по наценке/скидке на цену поставщика?" + chr(10)
        + (if v-ov-pc > 0
           then "Наценка: "
           else "Скидка: ")
        + string(abs(v-ov-pc)) + chr(10)
      + (if l-selection-exist then "Выбрано строк: " + string(num-entries(del-list)) + chr(10) else "" )
      + "Расчет производится по формуле:" + chr(10)
      + (if v-ov-pc > 0
         then "Новая цена = Старая цена * (1 + Наценка/ 100)" + chr(10)
         else "Новая цена = Старая цена * (1 - Скидка/ 100)" + chr(10)
        )
    ,input "|^"
    ,input "Все|"
         + "Выбранные" + (if l-selection-exist then "" else "^disable") + "|"
         + "Не выбранные" + (if l-selection-exist then "" else "^disable") + "|"
         + "Отмена"
    ,input "Все строки документа.|"
        + "Все отмеченные строки. Кнопка доступна при наличии выбранных строк.|"
        + "Все неотмеченные строки. Кнопка доступна при наличии выбранных строк.|"
        + "Ничего не пересчитывать."
    ,input 1
    ,input 4
    ,output v-num
    ).
  if v-num = 4 then do:
    return .
  end.
  tr:
  do transaction
  on error   undo tr, return error return-value
  :
    run waitfram-show in this-procedure ( input "Расчет новых цен. Ждите..." ).
    for each d-l-b
      where d-l-b.doc-code = t-doc.doc-code
    on error undo tr, return error
    :
      if (v-num = 1)
      or (v-num = 2
          and     can-do(del-list, string(recid(d-l-b)))
         )
      or (v-num = 3
          and not can-do(del-list, string(recid(d-l-b)))
         )
      then do:
        find first ov-goods where ov-goods.artic     = d-l-b.artic     and
                                  ov-goods.prod-type = d-l-b.prod-type and
                                  ov-goods.prod-code = d-l-b.prod-code no-lock.
        find ov-units where ov-units.unit-name    = ov-goods.unit-base no-lock.
        if lookup('2ед':U, ov-units.type) = 0 then
        assign
          d-l-b.price-cli = d-l-b.price-cli * (1 + v-ov-pc / 100) no-error.
        else
        assign
          d-l-b.price-rubl = d-l-b.price-rubl * (1 + v-ov-pc / 100) no-error.
        if error-status :error then do:
          run waitfram-hide in this-procedure .
          undo tr, return error .
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
  ,input   d-l-b.artic
  ,input   d-l-b.prod-type
  ,input   d-l-b.prod-code
  ,input   d-l-b.price-cli
  ,input   d-l-b.cli-base-rate
  ,input   d-l-b.price-rubl
  ,input   d-l-b.vat-pc
  ,input   d-l-b.slt-pc
  ,input   d-l-b.road-tax
  ,input   d-l-b.transport-rubl
  ,input   d-l-b.other-rubl
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
        if error-status :error then do:
          return error "Ошибка при пересчете линии документа".
        end.
        assign d-l-b.price-cli  = varprice-cli
               d-l-b.price-rubl = varprice-rubl
               d-l-b.price-base = varprice-base.
      end.
    end.
    run waitfram-show in this-procedure ( input "Проверка документа. Ждите..." ).
    run check-rate in this-procedure no-error .
    if error-status :error then do:
      run waitfram-hide in this-procedure .
      undo tr, return error .
    end.
    run waitfram-show in this-procedure ( input "Перерасчет документа в соответствии с новыми ценами. Ждите..." ).
    run gbl/calc-trn.p (input parparentproc, input recid( t-doc ) ) no-error.
    if error-status :error then do:
      message "Ошибка при пересчете документа." view-as alert-box error.
      run waitfram-hide in this-procedure .
      undo tr, return error .
    end.
  end.
  run waitfram-hide in this-procedure .
  run UI-on in this-procedure ( input "line" ).
  return .
end.
END PROCEDURE.
PROCEDURE prev-cor-line :
define input  parameter parunits-type like ub.units.type no-undo.
define input  parameter p-obj-type    like ub.clients.obj-type no-undo .
define input  parameter p-obj-code    like ub.clients.obj-code no-undo .
define input  parameter p-artic       like ub.goods.artic no-undo .
define input  parameter p-prod-type   like ub.goods.prod-type no-undo .
define input  parameter p-prod-code   like ub.goods.prod-code no-undo .
define variable v-insalepr as logical   no-undo .
define variable vss-include-info132 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  )  .
if v-insalepr = true then
   return error "Товар принимается по продажной цене. Изменение кол-ва допустимо лишь по кнопке <<Изм>>.".
if lookup('2ед':U, parunits-type) > 0  then
   return error "Товар c двумя единицами измерения. Изменение кол-ва допустимо лишь по кнопке <<Изм>>.".
END PROCEDURE.
PROCEDURE proc-m-outs-1 :
define variable loc-ref-list as character no-undo .
apply "row-leave" to browse br-dtl.
do on error undo, return error return-value :
if not ((t-doc.status_ = 'накл':U or t-doc.status_ = 'запрос':U) and not t-doc.flag_) then do:
  return error "Данное действие недопустимо в этом статусе.".
end.
if not b-add:sensitive in frame d-in-doc then do:
  message "Добавление строк из другого документа при этом статусе невозможно.".
  return error.
end.
run str/all-docs.w
  (  input parparentproc,
      input t-doc.host-code ,
      input t-doc.obj-type ,
      input t-doc.obj-code ,
      input 'выбор':U,
      input ?,
      input ?,
      input ?,
      input ?,
      input "b-sel":U,
      input ?,
      input ?,
      input ?,
      output loc-ref-list ).
find t-d-b where recid (t-d-b) = integer (loc-ref-list) no-lock no-error.
if not available t-d-b then do:
  display ? @ t-doc.out-code with frame d-in-doc.
  apply "entry" to b-add in frame d-in-doc.
  return error.
end.
display t-d-b.doc-code @ t-doc.out-code with frame d-in-doc.
run fill-tt in this-procedure ( input t-d-b.doc-code ) no-error.
   if error-status :error then  return error return-value.
run ask-copy in this-procedure no-error .
   if error-status :error then  return error return-value.
end.
END PROCEDURE.
PROCEDURE proc-m-outs-2 :
APPLY "row-leave" to BROWSE br-dtl.
do transaction on error   undo, return error:
if b-add:sensitive in frame d-in-doc then do:
  run check-exch in this-procedure.
  if not can-find (first  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code no-lock) then do:
    run check-rate in this-procedure.
   end.
end.
if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
  run prescan in this-procedure ( input recid( t-doc ) ) no-error.
  if error-status :error then do:
    message "Ошибка при установке фактического количества перед сканированием." skip
            return-value
    view-as alert-box error.
    undo, return error.
  end.
end.
run str/scan.p ( parParentproc, input b-add :sensitive , input recid(t-doc) , input ? ).
run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ) no-error.
if error-status :error then do:
  return error return-value.
end.
run UI-on in this-procedure ( input "line" ).
end.
END PROCEDURE.
PROCEDURE proc-m-outs-4 :
define buffer bf_trn-doc for ub.trn-doc.
define variable vardoc-code like ub.trn-doc.doc-code no-undo.
define variable vss-include-info133 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_import':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
assign vardoc-code = "import-" + t-doc.doc-code.
do transaction:
run utl/imp-all.p (parparentproc, 2, ?, ?, t-doc.exch-code, vardoc-code, t-doc.cli-type, t-doc.cli-code, t-doc.host-code) no-error .
if error-status :error then do:
   message "Ошибка при формировании файла import." view-as alert-box error.
   return error.
end.
run disp-import in this-procedure ( input vardoc-code ) no-error.
find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code.
if available bf_trn-doc then do:
   for each ub.parts exclusive-lock where
    ub.parts.out-code = bf_trn-doc.doc-code:
    delete ub.parts.
   end.
  delete bf_trn-doc.
end.
end.
END PROCEDURE.
PROCEDURE proc-m-outs-6 :
define buffer bf_trn-doc for ub.trn-doc.
define variable vardoc-code like ub.trn-doc.doc-code no-undo.
define variable vss-include-info134 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_import':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
assign vardoc-code = "import-" + t-doc.doc-code.
do transaction:
run str/imp-art.p (parparentproc, 2, ?, ?, t-doc.exch-code, vardoc-code, t-doc.cli-type, t-doc.cli-code, t-doc.host-code) no-error .
if error-status :error then do:
   message "Ошибка при формировании файла import." view-as alert-box error.
   return error.
end.
run disp-import in this-procedure (input vardoc-code) no-error.
find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code.
delete bf_trn-doc.
end.
END PROCEDURE.
PROCEDURE proc-m-outs-7 :
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line .
define buffer bf_goods for ub.goods .
define variable vardoc-code like ub.trn-doc.doc-code no-undo.
define variable par-alcohol as character no-undo .
define variable par-mark as character no-undo .
define variable par-type as character no-undo .
define variable v-is-alc as logical no-undo .
define variable v-mark-alchol     as logical no-undo .
define variable v-type as character no-undo .
delete object v-tth no-error.
run adm/shattri.p (
   input "get":U
  ,input t-doc.obj-type
  ,input t-doc.obj-code
  ,input 'nakl_par':U
  ,input  "mark-alchol"
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-mark-alchol
  ,output v-type
  ,INPUT-OUTPUT table-handle v-tth
  ) no-error .
  delete object v-tth no-error.
if error-status:error then do:
  message "Ошибка при получение параметра mark-alchol"
  view-as alert-box.
  return error.
end.
if not v-mark-alchol
then do :
    message "В системе не включен помарочный учёт. Импорт акцизных марок невозможен." view-as alert-box .
    return.
end.
v-is-alc = false .
for each bf_doc-line no-lock where bf_doc-line.doc-code = t-doc.doc-code :
    find first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic
                                  and bf_goods.prod-type = bf_doc-line.prod-type
                                  and bf_goods.prod-code = bf_doc-line.prod-code
                                  no-error .
    run gds-attr-value(
      bf_goods.gds-code,
      'alcohol-prod':U,
      output par-alcohol,
      output par-type
    ).
    if par-alcohol = "" or par-alcohol = "no" then next .
    run gds-attr-value(
      bf_goods.gds-code,
      'mark':U,
      output par-mark,
      output par-type
    ).
    if par-mark = "" or par-mark = "no" then next .
    v-is-alc = true .
end.
if not v-is-alc
then do :
    message "В накладной нет ни одного товара, подлежащего маркировке. Импорт акцизных марок не возможен" view-as alert-box.
    return .
end.
do transaction:
    run str/imp-marks.p (parparentproc, t-doc.doc-code, "in") .
end.
END PROCEDURE.
PROCEDURE proc-shift-num :
define buffer bf_shift-obj   for ub.shift-obj.
  if input frame d-in-doc t-doc.shift-num <> t-doc.shift-num then do:
    if input frame d-in-doc t-doc.shift-date <> ? then do:
      find first bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                    bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                    bf_shift-obj.shift-date = input frame d-in-doc t-doc.shift-date and
                                    bf_shift-obj.shift-num  = input frame d-in-doc t-doc.shift-num  no-lock no-error.
      if not available bf_shift-obj then do:
        message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame d-in-doc t-doc.shift-date " Порядок смены " input frame d-in-doc t-doc.shift-num " ."
        view-as alert-box error.
        display t-doc.shift-num with frame d-in-doc.
        run proc-sht no-error.
        if error-status:error then do:
          return error.
        end.
      end.
      else do:
        assign
          t-doc.shift-date = bf_shift-obj.shift-date
          t-doc.shift-num  = bf_shift-obj.shift-num
          t-doc.shift-name = bf_shift-obj.shift-name.
        display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-in-doc.
        if t-doc.fact-date = ? then do:
          t-doc.fact-time = ? .
          if bf_shift-obj.status_ = 'зкр':U
          then do :
            assign
              t-doc.fact-date = t-doc.shift-date
            .
            if t-doc.fact-date <> today
            then
              t-doc.fact-time = if (time < (12 * 60 * 60)) then time else (12 * 60 * 60) .
            display t-doc.fact-date with frame d-in-doc.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure proc-shift-name :
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.
  if input frame d-in-doc t-doc.shift-name <> t-doc.shift-name then do:
    if input frame d-in-doc t-doc.shift-date <> ? then do:
      for each  bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                   bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                   bf_shift-obj.shift-date = input frame d-in-doc t-doc.shift-date and
                                   bf_shift-obj.shift-name = input frame d-in-doc t-doc.shift-name no-lock on error undo, return error return-value :
        assign
          varfind-shift = varfind-shift + 1
          varshift-date = bf_shift-obj.shift-date
          varshift-num  = bf_shift-obj.shift-num.
      end.
      if varfind-shift = 0 or varfind-shift > 1 then do:
        if varfind-shift = 0 then do:
          message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                  " Дата " input frame d-in-doc t-doc.shift-date " Номер смены " input frame d-in-doc t-doc.shift-name " ."
          view-as alert-box error.
        end.
        else do:
          message "Найдено более одной смены с одним номером в сменном дне. Объект: " t-doc.obj-type " " t-doc.obj-code
                  " Дата " input frame d-in-doc t-doc.shift-date " Номер смены " input frame d-in-doc t-doc.shift-name " ."
          view-as alert-box error.
        end.
        display t-doc.shift-name with frame d-in-doc.
        run proc-sht no-error.
        if error-status:error then do: return error. end.
      end.
      else do:
        assign frame d-in-doc
          t-doc.shift-name.
        assign
          t-doc.shift-date = varshift-date
          t-doc.shift-num  = varshift-num.
        display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-in-doc.
        if t-doc.fact-date = ? then do:
          t-doc.fact-time = ? .
          if bf_shift-obj.status_ = 'зкр':U
          then do :
            assign
              t-doc.fact-date = t-doc.shift-date
            .
            if t-doc.fact-date <> today
            then
              t-doc.fact-time = if (time < (12 * 60 * 60)) then time else (12 * 60 * 60) .
            display t-doc.fact-date with frame d-in-doc.
          end.
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info135 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fact-bc:
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define variable g-log       as logical              no-undo.
define variable varnum      as integer              no-undo.
define variable varbar-code like ub.bar-code.b-code no-undo.
define variable varrecid    as   recid              no-undo.
define variable is-petrolium as logical no-undo.
define variable is-pieces    as logical no-undo.
define variable v-part-code  as character no-undo.
define variable v-alcohol-prod as logical no-undo .
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_gds-dtl  for ub.gds-dtl.
define buffer bf_goods    for ub.goods.
define buffer bf_gds-prt  for ub.gds-prt.
define buffer bf_units    for ub.units.
define buffer bf_parts    for ub.parts.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code.
for each tt-bar-code-ne:
  delete tt-bar-code-ne.
end.
assign
  g-log = yes.
if bf_trn-doc.doc-qnty <> bf_trn-doc.fact-qnty and
   bf_trn-doc.fact-qnty <> 0 then do:
  message "Начать заполнять фактическое количество с нуля?" view-as alert-box question
  buttons yes-no update g-log.
end.
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock by bf_doc-line.line-num :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_trn-doc.doc-code     and
                            bf_gds-dtl.artic     = bf_goods.artic     and
                            bf_gds-dtl.prod-type = bf_goods.prod-type and
                            bf_gds-dtl.prod-code = bf_goods.prod-code
                            no-lock :
    find first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-prt.node-code
  ,output varbar-code
  )  .
    assign
      varnum = varnum + 1.
    create tt-bar-code-ne.
    assign
     tt-bar-code-ne.nm             = varnum
     tt-bar-code-ne.mark           = (if bf_gds-dtl.fact-qnty < bf_gds-dtl.doc-qnty then "<" else "")
     tt-bar-code-ne.b-c            = varbar-code
     tt-bar-code-ne.scn-qnty-doc   = bf_gds-dtl.doc-qnty
     tt-bar-code-ne.scn-qnty-file  = (if g-log = yes then 0 else bf_gds-dtl.fact-qnty)
     tt-bar-code-ne.mem-qnty       = tt-bar-code-ne.scn-qnty-file
     tt-bar-code-ne.bef-qnty       = bf_gds-dtl.fact-qnty
     tt-bar-code-ne.artic          = bf_goods.artic
     tt-bar-code-ne.prod-type      = bf_goods.prod-type
     tt-bar-code-ne.prod-code      = bf_goods.prod-code
     tt-bar-code-ne.gds-name       = bf_goods.gds-name
     tt-bar-code-ne.node-name      = (if bf_gds-prt.node-name = '_Пустая шкала':U then "--------------------" else bf_gds-prt.node-name)
     tt-bar-code-ne.part-code      = ''
     tt-bar-code-ne.in-code        = ''.
  end.
end.
run str/scr-neb.w (input parparentproc, input-output table tt-bar-code-ne, input "in-doc", input yes, input v-cntxt-obj-type, input v-cntxt-obj-code).
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock by bf_doc-line.line-num :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_trn-doc.doc-code     and
                            bf_gds-dtl.artic     = bf_goods.artic     and
                            bf_gds-dtl.prod-type = bf_goods.prod-type and
                            bf_gds-dtl.prod-code = bf_goods.prod-code
                            no-lock on error undo, return error return-value :
    find first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-prt.node-code
  ,output varbar-code
  )  .
    find first tt-bar-code-ne where tt-bar-code-ne.b-c = varbar-code.
    if tt-bar-code-ne.scn-qnty-file <> bf_gds-dtl.fact-qnty then do :
      find bf_units where bf_units.unit-name = bf_goods.unit-base no-lock.
      if lookup('сер':U, bf_units.type) > 0 then do:
         message "В серийном товаре нельзя редактировать количество. Пропускаем.".
         next.
      end.
      if tt-bar-code-ne.scn-qnty-file > bf_gds-dtl.doc-qnty then do:
        message "По признаку " bf_gds-dtl.artic " "
                bf_gds-dtl.prod-type " "
                bf_gds-dtl.prod-code " "
                bf_gds-prt.f-name " "
                "количество факт уже больше чем по документу. Устанавливаем по документу."
        view-as alert-box.
        assign
          tt-bar-code-ne.scn-qnty-file = bf_gds-dtl.doc-qnty.
      end.
      assign varrecid = recid(bf_doc-line).
      if bf_trn-doc.doc-type = 'при':U and
         bf_trn-doc.internal = no        then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
        if is-petrolium and not is-pieces then do:
          MESSAGE "В жидком топливе нельзя редактировать фактическое количество" view-as alert-box.
          next.
        end.
        assign
          v-part-code = ?
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  bf_goods.gds-code
  ,input  'alcohol-prod=request':u
  ,output v-alcohol-prod
  )  .
        if v-alcohol-prod then do:
          find first bf_parts no-lock
            where bf_parts.obj-type  = bf_doc-line.obj-type  and
                  bf_parts.obj-code  = bf_doc-line.obj-code  and
                  bf_parts.prod-type = bf_doc-line.prod-type and
                  bf_parts.prod-code = bf_doc-line.prod-code and
                  bf_parts.artic     = bf_doc-line.artic     and
                  bf_parts.out-code  = bf_doc-line.doc-code
            no-error.
          if available bf_parts then do:
            assign
              v-part-code = bf_parts.part-code
            .
          end.
        end.
        run str/cor-line.p
          (input parparentproc
          ,input-output varrecid
          ,input bf_doc-line.doc-code
          ,input bf_doc-line.prod-type
          ,input bf_doc-line.prod-code
          ,input bf_doc-line.artic
          ,input bf_doc-line.cli-qnty
          ,input bf_doc-line.cli-base-rate
          ,input tt-bar-code-ne.scn-qnty-file
          ,input bf_doc-line.doc-qnty
          ,input bf_doc-line.unit-cli
          ,input bf_doc-line.vat-pc
          ,input bf_doc-line.slt-pc
          ,input bf_doc-line.price-cli
          ,input bf_doc-line.price-base
          ,input bf_doc-line.price-rubl
          ,input bf_doc-line.new-price-sale
          ,input bf_doc-line.num-place
          ,input bf_doc-line.wt-brutto
          ,input bf_doc-line.road-tax
          ,input bf_doc-line.excise
          ,input bf_doc-line.doc-density
          ,input bf_doc-line.temperature
          ,input ?
          ,input ?
          ,input ?
          ,input bf_doc-line.fact-density
          ,input ?
          ,input no
          ,input v-part-code
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ,input ?
          ) no-error.
        if error-status :error then do:
          return error return-value.
        end.
      end.
      else do:
        run str/out-add.p (parparentproc,
                       recid(bf_trn-doc),
                       recid(bf_doc-line),
                       recid(bf_gds-dtl),
                       recid(bf_goods),
                       "ch-fact-qnty",
                       tt-bar-code-ne.scn-qnty-file) no-error.
        if error-status :error then do:
          return error return-value.
        end.
      end.
    end.
  end.
end.
end.
end procedure.
procedure checkTypeByBarCode:
  define input parameter iBarCode    as integer no-undo.
  define input parameter iExtDocType as character no-undo.
  define variable vValue as character no-undo.
  define variable vType  as character no-undo.
  define buffer buf_bar-code for ub.bar-code.
  define buffer buf_goods    for ub.goods.
  if iExtDocType = ? or
     iExtDocType = 'ee':U or
     iExtDocType = 'ie':U or
     iExtDocType = 'iv':U or
     iExtDocType = 'ev':U or
     iExtDocType = 'we':U then
      find buf_bar-code where buf_bar-code.b-code = iBarCode no-lock.
      find buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock.
      RUN gds-attr-value (
         INPUT buf_goods.gds-code,
         INPUT 'mark-type':U,
         OUTPUT vValue,
         OUTPUT vType
      ).
      if vValue <> "" then
      do:
        message
          substitute("Товар: &1 &2", b-c, buf_goods.gds-name) skip
          "нельзя добавлять в ручном режиме, так как он подлежит маркировке."
          view-as alert-box error buttons ok.
        return error.
      end.
end procedure.
PROCEDURE proc-sht :
define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-sel', 'obj', t-doc.obj-type, t-doc.obj-code ,'':u, input-output varrid-list) no-error .
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-in-doc.
      if t-doc.fact-date = ? then do:
        t-doc.fact-time = ? .
        if bf_shift-obj.status_ = 'зкр':U
        then do :
          assign
            t-doc.fact-date = t-doc.shift-date
          .
          if t-doc.fact-date <> today
          then
            t-doc.fact-time = if (time < (12 * 60 * 60)) then time else (12 * 60 * 60) .
          display t-doc.fact-date with frame d-in-doc.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE r-proc-currency :
run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do: return no-apply. end.
  find ub.currency no-lock where recid( ub.currency ) = ref-rec no-error.
  if not available ub.currency then do: return no-apply. end.
  if ub.currency.curr-code <> t-doc.exch-code then do:
    run check-update in this-procedure no-error.
    if error-status :error then do: return no-apply. end.
  end.
  RUN exch-rate    in this-procedure.
  RUN full-recount in this-procedure.
END PROCEDURE.
PROCEDURE select-reason :
define variable j-rsn-code like ub.trn-reason.reason-code no-undo.
define variable vDeleted as logical no-undo.
  assign j-rsn-code = ( input frame d-in-doc t-doc.reason-code ).
  run str/trn-reas.w ( input ParParentProc, input 'выбор':U, input-output j-rsn-code ).
  find first ub.trn-reason no-lock where ub.trn-reason.reason-code = j-rsn-code no-error.
  if available ub.trn-reason then do:
    assign  rsn-name          = ub.trn-reason.reason-name
            t-doc.reason-code = ub.trn-reason.reason-code.
    display t-doc.reason-code rsn-name with frame d-in-doc.
    if trn-type = 2 and t-doc.reason-code <> 99 then
    do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-del in g#trdcalib (  input t-doc.doc-code ,
                        input 'sugtpattr-massa-sug':U ,
                       output vDeleted ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-del in g#trdcalib (  input t-doc.doc-code ,
                        input 'sugtpattr-teh-loss':U ,
                       output vDeleted ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-del in g#trdcalib (  input t-doc.doc-code ,
                        input 'sugtpattr-err-allow':U ,
                       output vDeleted ) no-error .
    end.
  end.
END PROCEDURE.
PROCEDURE ui-on :
define input parameter fnc as character no-undo.
define buffer d-l-b for  ub.doc-line.
define variable v-vat-pc        like  ub.doc-line.vat-pc    no-undo.
define variable v-slt-pc        like  ub.doc-line.slt-pc    no-undo.
define variable v-have-slt-pc   as logical              no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
define variable varadd-back-date        as   logical               no-undo.
define buffer bf_contract for ub.contract.
assign
  del-list = ""
  loc-art  = ""
.
if lookup( fnc, "enable" ) > 0 then do:
  assign
    frame d-in-doc:title = t-doc.obj-type + " " + string (t-doc.obj-code, ">>>>9") +
    " :   ПРИХОД - " + t-doc.status_ + " № " + t-doc.doc-code + "      - ".
  assign frame d-in-doc :title = frame d-in-doc :title +
    ( if parext-doc-mode = ""            then title-mode( pardoc-mode ) else ( caps( 'редакт-факт':U ) +
    ( if parext-doc-mode = "reason-code" then " кода основания"         else "":U ) ) ).
  disable all with frame d-in-doc.
  if not is-add-doc then hide b-add-doc in frame d-in-doc .
  else enable b-add-doc with frame d-in-doc .
  find first ub.add-trn no-lock where ub.add-trn.trn-doc-code =  t-doc.doc-code no-error .
  if available ub.add-trn then do:
    enable b-add-doc-yes with frame d-in-doc .
    display b-add-doc-yes with frame d-in-doc .
  end.
  else do:
     hide b-add-doc-yes in frame d-in-doc .
  end.
  enable b-print b-exit b-help b-lkp br-dtl b-history a-n-c b-notes b-attr b-arch b-live b-cnt b-contr-lkp with frame d-in-doc.
  hide loc-art in frame d-in-doc loc-name loc-code in frame d-in-doc.
  assign ub.goods.gds-name:resizable in browse br-dtl = yes
         ub.goods.gds-name:width-chars in browse br-dtl = 30  .
          if t-doc.status_ <> 'накл':U then do:
            assign
               ub.doc-line.cli-qnty  :read-only in browse br-dtl = yes
               ub.doc-line.fact-qnty :read-only in browse br-dtl = yes
               ub.doc-line.wt-brutto :read-only in browse br-dtl = yes
               ub.doc-line.num-place :read-only in browse br-dtl = yes
            .
          end.
          else do:
            if t-doc.flag_ = yes then do: assign  ub.doc-line.cli-qnty  :read-only in browse br-dtl = yes. end.
                                  else do: assign  ub.doc-line.fact-qnty :read-only in browse br-dtl = yes. end.
            if v-edit-fact-wayb
              then assign doc-line.fact-qnty :read-only in browse br-dtl = no.
          end.
          if isEgais
            then doc-line.cli-qnty  :read-only in browse br-dtl = yes.
  case pardoc-mode :
    when 'ДОБАВЛЕНИЕ':U then do:
         enable t-doc.cli-code t-doc.cli-type r-clients with frame d-in-doc.
         enable b-marks with frame d-in-doc.
    end.
    when 'ПРОСМОТР':U then do:
      if parext-doc-mode = "":U then do:
            if br-handle = ? then hide b-prev b-next in frame d-in-doc .
                             else enable b-prev b-next with frame d-in-doc.
      end.
      if  parext-doc-mode = "reason-code" then do:
          enable r-reas t-doc.reason-code with frame d-in-doc.
      end.
      if prtvalue   = "yes" and v-cntxp-doc-prt = yes then do:
         enable b-prt   with frame d-in-doc.
      end.
      enable b-parts with frame d-in-doc.
          enable b-marks with frame d-in-doc.
      assign
         ub.doc-line.cli-qnty  :read-only in browse br-dtl = yes
         ub.doc-line.fact-qnty :read-only in browse br-dtl = yes
         ub.doc-line.wt-brutto :read-only in browse br-dtl = yes
         ub.doc-line.num-place :read-only in browse br-dtl = yes
      .
      if parext-doc-mode = "vsd_corr-parts"
      or parext-doc-mode = "vsd"
      or parext-doc-mode = "corr-parts"
      then do :
        enable t-doc.cst-code with frame d-in-doc.
      end .
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
      if not v-cntxp-inout-price and
         not t-doc.flag_ then do:
        do transaction on error   undo, return error return-value :
           for each old-doc-line:
               delete old-doc-line.
           end.
           for each d-l-b where d-l-b.doc-code = t-doc.doc-code on error undo, return error return-value :
               create old-doc-line.
               buffer-copy d-l-b to old-doc-line.
               find ub.goods where ub.goods.artic     = d-l-b.artic     and
                                ub.goods.prod-type = d-l-b.prod-type and
                                ub.goods.prod-code = d-l-b.prod-code no-lock.
define variable vss-include-info136 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output t-doc.host-code
  )  .
define variable vss-include-info137 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  t-doc.host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-vat-pc
  ) no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(ub.goods)
,input  recid(t-doc)
,input  bf_sysconf.cash-pay
,output v-slt-pc
)
.
                  if  d-l-b.vat-pc <> v-vat-pc
                    or d-l-b.slt-pc <> v-slt-pc
                  then do:
                      assign
                            d-l-b.vat-pc = v-vat-pc
                            d-l-b.slt-pc = v-slt-pc
                      .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   t-doc.doc-code
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,input   t-doc.vat-type
  ,input   t-doc.slt-type
  ,input   d-l-b.artic
  ,input   d-l-b.prod-type
  ,input   d-l-b.prod-code
  ,input   d-l-b.price-cli
  ,input   d-l-b.cli-base-rate
  ,input   d-l-b.price-rubl
  ,input   d-l-b.vat-pc
  ,input   d-l-b.slt-pc
  ,input   d-l-b.road-tax
  ,input   d-l-b.transport-rubl
  ,input   d-l-b.other-rubl
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
                        if error-status :error then do:
                          message
                            error-status :get-message(1) skip
                            return-value skip
                            "Ошибка при пересчете линии документа"
                            view-as alert-box error
                          .
                          return error "Ошибка при пересчете линии документа".
                        end.
                      assign
                        d-l-b.price-cli  = varprice-cli
                        d-l-b.price-rubl = varprice-rubl
                        d-l-b.price-base = varprice-base
                      .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(d-l-b)
  ,input d-l-b.doc-code
  ,input d-l-b.artic
  ,input d-l-b.prod-type
  ,input d-l-b.prod-code
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
  ) no-error.
                        if error-status :error then do: undo, return no-apply. end.
                        delete old-doc-line.
                  end.
           end.
        end.
      end.
      if prtvalue   = "yes" and v-cntxp-doc-prt then enable b-prt with frame d-in-doc.
      enable b-parts with frame d-in-doc.
      if convimpvalue = "yes" then do:
       if not valid-handle(m-outs-5) then do:
          create menu-item m-outs-5
          assign
            label  = "Импорт из файла с конвертацией"
          .
          on choose of m-outs-5 persistent
             run local-m-outs-5 in this-procedure.
          assign
            m-outs-5:parent = menu m-outs:handle
          .
       end.
      end.
      enable b-chg b-renum r-outs
             t-doc.wrkr t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss r-outs m-inc
             with frame d-in-doc.
      if not t-doc.flag_ then do:
        if inv-shipvalue = true then do:
           enable t-doc.ship-num t-doc.ship-date with frame d-in-doc.
        end.
        else do:
          hide t-doc.ship-num t-doc.ship-date  in frame d-in-doc.
        end.
        if curclivalue <> "no" then do:
           if NOT t-doc.flag_ and
                  t-doc.exch-code <> 0 then do:
             enable r-acc t-doc.exch-rate t-doc.exch-scale with frame d-in-doc.
           end.
           if t-doc.contract-code = 0 then do:
             enable t-doc.exch-date t-doc.exch-code r-currency with frame d-in-doc.
           end.
        end.
        else do:
          hide r-acc r-currency in frame d-in-doc.
        end.
        enable t-doc.cst-code t-doc.ord-num with frame d-in-doc.
        enable b-marks with frame d-in-doc.
        if pardoc-mode <> 'ПРОСМОТР':U then do:
           enable r-reas t-doc.reason-code with frame d-in-doc.
        end.
        enable t-doc.pay-code r-pay t-doc.doc-date
               varpurch-code-name when t-doc.contract-code = 0
               varinplnsum   when var-inp_sum = false
               b-mark t-doc.tot-cli
               t-doc.out-code m-inc
               with frame d-in-doc.
        if isEgais
          then disable b-add b-del with frame d-in-doc.
          else enable b-add b-del with frame d-in-doc.
        enable t-doc.base-rate t-doc.base-scale with frame d-in-doc.
        if is-ovvalue <> "no" then enable ov-pc with frame d-in-doc.
                              else hide   ov-pc in   frame d-in-doc.
        enable t-doc.tot-other t-doc.tot-transp with frame d-in-doc.
        if multdtypvalue <> "no" then enable t-doc.VAT-type t-doc.slt-type with frame d-in-doc.
                                 else disable t-doc.VAT-type t-doc.slt-type with frame d-in-doc.
      end.
      else do:
         define variable varhold-doc as logical no-undo.
define variable vss-include-info138 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  t-doc.doc-code
  ,output varhold-doc
  )  .
         if varhold-doc then do:
           enable t-doc.cst-code with frame d-in-doc.
         end.
         enable b-revis t-doc.ord-num with frame d-in-doc.
      end.
      if v-by-utd
      then do :
        disable
          b-add b-del b-chg
          t-doc.pay-code r-pay t-doc.doc-date t-doc.fact-date
          varpurch-code-name varinplnsum
          t-doc.out-code m-inc r-outs
          t-doc.tot-cli
          t-doc.base-rate t-doc.base-scale
          t-doc.shift-date t-doc.shift-num r-sht
          t-doc.tot-transp t-doc.tot-other
          t-doc.SLT-type t-doc.VAT-type ov-pc
        with frame d-in-doc.
        assign
          doc-line.cli-qnty  :read-only in browse br-dtl = yes
          doc-line.fact-qnty :read-only in browse br-dtl = yes
          doc-line.wt-brutto :read-only in browse br-dtl = yes
          doc-line.num-place :read-only in browse br-dtl = yes
        .
      end .
      define variable v-tmp-char like ub.thbj-attr.property-value-character no-undo .
      define variable v-tmp-date      like ub.thbj-attr.property-value-date    no-undo .
      define variable v-tmp-decimal   like ub.thbj-attr.property-value-decimal no-undo .
      define variable v-tmp-integer   like ub.thbj-attr.property-value-integer no-undo .
      define variable v-rvd-own-nb as logical no-undo .
      define variable v-rvd-own-nb-type as   character no-undo .
      run adm/shattri.p (
          input "get":U
          ,input t-doc.obj-type
          ,input t-doc.obj-code
          ,input 'petrol':U
          ,input  "rvd-own-nb"
          ,output v-tmp-char
          ,output v-tmp-date
          ,output v-tmp-decimal
          ,output v-tmp-integer
          ,output v-rvd-own-nb
          ,output v-rvd-own-nb-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
          ) no-error .
      if error-status :error then v-rvd-own-nb = false .
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
            v-can-edit = no .
            disable b-add b-del with frame d-in-doc.
          end .
        end .
      end .
    end.
  end case.
end.
find ub.clients where ub.clients.obj-type = t-doc.cli-type and ub.clients.obj-code = t-doc.cli-code no-lock no-error.
if available ub.clients then display ub.clients.obj-name with frame d-in-doc.
   else display ? @ ub.clients.obj-name with frame d-in-doc.
find ub.currency where ub.currency.curr-code = bf_sysconf.base-code NO-LOCK.
assign
  base-type = ub.currency.curr-abbr
  base-abbr = base-type.
define variable vss-include-info139 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varadd-back-date
    )  .
end.
if t-doc.status_ = 'запрос':U then do:
   hide t-doc.fact-date t-doc.fact-qnty in frame d-in-doc.
end.
else do:
 if (t-doc.status_ = 'накл':U and not t-doc.flag_) then do:
   display t-doc.fact-date with frame d-in-doc.
   if t-doc.status_ = 'накл':U and
       t-doc.flag_   = no     and
       pardoc-mode = 'ИЗМЕНЕНИЕ':U   and
       varadd-back-date = yes and
       not v-by-utd
   then do:
     enable t-doc.fact-date with frame d-in-doc.
   end.
define variable vss-include-info140 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  'shift-on=request'
  ,output varlog
  ) no-error .
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при запуске процедуры objat" skip
       error-status :get-message(1) skip
       return-value skip
       view-as alert-box error .
     return error.
   end.
   if varlog then do:
     display t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame d-in-doc.
     if t-doc.status_ = 'накл':U and
        t-doc.flag_   = no      and
        pardoc-mode = 'ИЗМЕНЕНИЕ':U and
        varadd-back-date = yes  and
        not v-by-utd
     then do:
       enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame d-in-doc.
     end.
   end.
 end.
 else do:
   display t-doc.fact-date t-doc.fact-qnty t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame d-in-doc.
 end.
end.
assign
  varpurch-code-name = entry (lookup (string(t-doc.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
display t-doc.tot-calc
     t-doc.tot-sale
     t-doc.tot-fact
     t-doc.road-tax
     t-doc.tot-cli
     t-doc.doc-date
     t-doc.fact-date
     t-doc.doc-qnty
     t-doc.cli-qnty
     t-doc.ord-num
     t-doc.cli-code
     t-doc.cli-type
     t-doc.pay-code
     t-doc.VAT-base
     t-doc.VAT-rubl
     t-doc.exch-date
     t-doc.exch-code
     t-doc.exch-rate
     t-doc.exch-scale
     t-doc.base-rate
     t-doc.base-scale
     t-doc.tot-transp
     t-doc.tot-other
     varpurch-code-name
     varinplnsum
     with frame d-in-doc.
display t-doc.ship-num   when inv-shipvalue  = true
     t-doc.ship-date  when inv-shipvalue  = true
     ov-pc            when is-ovvalue     <> "no"
     t-doc.VAT-type
     t-doc.slt-type
     t-doc.cst-code
     t-doc.wrkr
     t-doc.agnt
     t-doc.boss
     with frame d-in-doc.
find first bf_contract where bf_contract.host-code     = t-doc.host-code and
                             bf_contract.contract-code = t-doc.contract-code no-lock no-error.
if available bf_contract then do:
  assign
    varcontract-prn-code = bf_contract.contract-prn-code.
end.
else do:
  assign
    varcontract-prn-code = "БЕЗ ДОГОВОРА".
end.
display varcontract-prn-code with frame d-in-doc.
  define variable v-ref-rec141   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.wrkr with frame d-in-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-in-doc t-doc.wrkr
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-in-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-in-doc.
  define variable v-ref-rec142   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.agnt with frame d-in-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-in-doc t-doc.agnt
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-in-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-in-doc.
  define variable v-ref-rec143   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-in-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.boss with frame d-in-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-in-doc t-doc.boss
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-in-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-in-doc.
find ub.pay-type where ub.pay-type.obj-code = input frame d-in-doc t-doc.pay-code no-lock no-error.
if available ub.pay-type then display ub.pay-type.obj-name with frame d-in-doc.
                      else display ? @ ub.pay-type.obj-name with frame d-in-doc.
if curclivalue <> "no" then do:
   find ub.currency where ub.currency.curr-code = t-doc.exch-code no-lock no-error.
   if available ub.currency then display ub.currency.curr-abbr with frame d-in-doc.
                         else display ? @ ub.currency.curr-abbr with frame d-in-doc.
end.
else hide ub.currency.curr-abbr in frame d-in-doc.
if t-doc.out-code <> ? or t-doc.out-code:sensitive then display t-doc.out-code with frame d-in-doc.
                                                   else hide t-doc.out-code in frame d-in-doc.
  find ub.trn-reason no-lock where
       ub.trn-reason.reason-code = t-doc.reason-code no-error.
  assign
    rsn-name = ( if available ub.trn-reason then ub.trn-reason.reason-name else "":U )
  .
  display t-doc.reason-code rsn-name with frame d-in-doc.
sort-default = yes. OPEN QUERY br-dtl    FOR EACH  ub.doc-line WHERE  ub.doc-line.doc-code = t-doc.doc-code NO-LOCK,            EACH ub.goods WHERE ub.goods.artic =  ub.doc-line.artic                                       AND ub.goods.prod-code =  ub.doc-line.prod-code                                       AND ub.goods.prod-type =  ub.doc-line.prod-type NO-LOCK,            first ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK,            EACH ub.gds-obj outer-join WHERE ub.gds-obj.artic     =  ub.doc-line.artic                           AND ub.gds-obj.prod-code =  ub.doc-line.prod-code                           AND ub.gds-obj.prod-type =  ub.doc-line.prod-type                           AND ub.gds-obj.obj-type  = t-doc.obj-type                           AND ub.gds-obj.obj-code  = t-doc.obj-code NO-LOCK BY  ub.doc-line.line-num.
if pardoc-mode = 'ПРОСМОТР':U then do:
  if line-rec <> ? then reposition br-dtl to recid line-rec no-error.
  apply "entry" to br-dtl in frame d-in-doc.
end.
if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
  if not can-find (first  ub.doc-line where  ub.doc-line.doc-code = t-doc.doc-code no-lock) then
    apply "entry" to t-doc.tot-cli in frame d-in-doc.
  else do:
    if line-rec <> ? then reposition br-dtl to recid line-rec no-error.
    apply "entry" to br-dtl in frame d-in-doc.
    if t-doc.flag_ = no then do:
       apply "entry" to  ub.doc-line.cli-qnty in browse br-dtl.
    end.
    else do:
       apply "entry" to  ub.doc-line.fact-qnty in browse br-dtl.
    end.
  end.
end.
b-in-attr-fuel:sensitive = true.
b-calc-tp:sensitive = true.
if num-results('br-dtl') > 0 then do:
   if br-dtl:refresh() then.
end.
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, ",":U).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.
else
      ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
END PROCEDURE.
PROCEDURE upd-cli-qnty :
define variable v-part-code  as character no-undo.
if available  ub.doc-line then do:
  if dec( ub.doc-line.cli-qnty:screen-value in browse br-dtl) <>  ub.doc-line.cli-qnty then do:
    if (dec( ub.doc-line.cli-qnty:screen-value in browse br-dtl) = 0.00 or
        dec( ub.doc-line.cli-qnty:screen-value in browse br-dtl) = ?) and not t-doc.flag_ then do:
      message "Не указано количество в единицах поставщика.".
      display  ub.doc-line.cli-qnty with browse br-dtl.
      return error.
    end.
    find ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.
    if t-doc.flag_ and not v-edit-fact-wayb then do:
       message "В данном статусе нельзя редактировать количество по ТТН".
       display  ub.doc-line.cli-qnty with browse br-dtl.
       return error.
    end.
    if lookup('сер':U, ub.units.type) > 0  then do:
       message "В серийном товаре нельзя редактировать количество по ТТН".
       display  ub.doc-line.cli-qnty with browse br-dtl.
       return error.
    end.
    run prev-cor-line in this-procedure
      ( input ub.units.type
      , input ub.doc-line.obj-type
      , input ub.doc-line.obj-code
      , input ub.doc-line.artic
      , input ub.doc-line.prod-type
      , input ub.doc-line.prod-code
      ) no-error.
    if error-status :error then do:
       message return-value view-as alert-box error.
       display  ub.doc-line.cli-qnty with browse br-dtl.
       return error.
    end.
    run get-alc-part in this-procedure
      (input recid(ub.doc-line),
       output v-part-code
      ).
    do transaction on error undo, return error return-value :
       assign line-rec = recid(ub.doc-line).
       run str/cor-line.p
         (input parparentproc
         ,input-output line-rec
         ,input  ub.doc-line.doc-code
         ,input  ub.doc-line.prod-type
         ,input  ub.doc-line.prod-code
         ,input  ub.doc-line.artic
         ,input dec( ub.doc-line.cli-qnty:screen-value in browse br-dtl)
         ,input  ub.doc-line.cli-base-rate
         ,input  ub.doc-line.fact-qnty
         ,input  ub.doc-line.cli-base-rate * dec( ub.doc-line.cli-qnty:screen-value in browse br-dtl)
         ,input  ub.doc-line.unit-cli
         ,input  ub.doc-line.vat-pc
         ,input  ub.doc-line.slt-pc
         ,input  ub.doc-line.price-cli
         ,input  ub.doc-line.price-base
         ,input  ub.doc-line.price-rubl
         ,input  ub.doc-line.new-price-sale
         ,input  ub.doc-line.num-place
         ,input  ub.doc-line.wt-brutto
         ,input  ub.doc-line.road-tax
         ,input  ub.doc-line.excise
         ,input  ub.doc-line.doc-density
         ,input  ub.doc-line.temperature
         ,input ?
         ,input ?
         ,input dec( ub.doc-line.cli-qnty:screen-value in browse br-dtl)
         ,input  ub.doc-line.fact-density
         ,input ?
         ,input no
         ,input v-part-code
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ) no-error.
       if error-status :error
       then do:
         if error-status :get-message(1) <> ""
         then do:
           message
             vss-workfile vss-revision vss-description skip
             "Ошибка при вызове процедуры cor-line.p" skip
             "Точка вызова 1" skip
             error-status :get-message(1) skip
             return-value skip
             view-as alert-box error .
         end.
         undo, return error.
       end.
       find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = t-doc.doc-code and
                                         ub.doc-line-attr.gds-code  = ub.goods.gds-code and
                                         ub.doc-line-attr.attr-code = "tot-cli"      no-error.
       if not available ub.doc-line-attr then do:
         create ub.doc-line-attr.
         assign
         ub.doc-line-attr.doc-code  = t-doc.doc-code
         ub.doc-line-attr.gds-code  = ub.goods.gds-code
         ub.doc-line-attr.attr-code = "tot-cli"        .
       end.
       assign ub.doc-line-attr.attr-value = string( ub.doc-line.cli-qnty *  ub.doc-line.price-cli).
       assign line-rec = recid ( ub.doc-line ).
       run str/chk-prt.p ( input line-rec, input no, buffer t-doc).
       do
       on error undo, return error return-value
       :
         define buffer buf_doc-line for ub.doc-line .
         define buffer buf_inv-line for ub.inv-line .
         find first buf_doc-line exclusive-lock where
             recid( buf_doc-line ) = recid(  ub.doc-line ) .
         if decimal(  ub.doc-line.cli-qnty :screen-value in browse br-dtl ) <>  ub.doc-line.cli-qnty
         then do:
           assign
             buf_doc-line.cli-qnty = decimal(  ub.doc-line.cli-qnty :screen-value in browse br-dtl )
           .
         end.
         find first buf_doc-line        no-lock where
             recid( buf_doc-line ) = recid(  ub.doc-line ) .
       end.
       run ui-on in this-procedure
         ( input "line"
         ) .
    end.
  end.
end.
END PROCEDURE.
PROCEDURE update-rate-doc :
if input frame d-in-doc t-doc.exch-rate  <> t-doc.exch-rate  or
   input frame d-in-doc t-doc.exch-scale <> t-doc.exch-scale or
   input frame d-in-doc t-doc.base-rate  <> t-doc.base-rate  or
   input frame d-in-doc t-doc.base-scale <> t-doc.base-scale then
   do transaction on error undo, return error return-value :
     run check-exch   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-update in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-rate   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
    end.
    run UI-on in this-procedure ( input "line" ).
END PROCEDURE.
PROCEDURE val-ch-slt-type :
define buffer d-l-b for  ub.doc-line.
define buffer bf-goods for ub.goods.
define variable old-slt         like ub.trn-doc.slt-type .
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
do transaction on error undo, return error return-value :
  run check-update in this-procedure no-error.
  if error-status :error then do: return error. end.
define variable vss-include-info144 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
  assign old-slt = t-doc.slt-type.
  assign frame d-in-doc t-doc.SLT-type.
  find first d-l-b where d-l-b.doc-code = t-doc.doc-code no-lock no-error.
  if available d-l-b then do:
     if t-doc.slt-type = 'без':U and
        old-slt <> 'без':U then do:
        message "Налог с продаж в строках устанавливаем в 0" view-as alert-box information.
        for each d-l-b where d-l-b.doc-code = t-doc.doc-code:
            assign d-l-b.slt-pc = 0.
        end.
     end.
     else if t-doc.slt-type <> 'без':U and
             old-slt = 'без':U then do:
        message "Налог с продаж в строках устанавливаем из товара" view-as alert-box information.
        for each d-l-b where d-l-b.doc-code = t-doc.doc-code,
                 first bf-goods where bf-goods.artic     = d-l-b.artic and
                                      bf-goods.prod-type = d-l-b.prod-type and
                                      bf-goods.prod-code = d-l-b.prod-code:
define variable vss-include-info145 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-slt-pc
  ) no-error .
            assign d-l-b.slt-pc = v-slt-pc.
        end.
     end.
     run check-rate   in this-procedure no-error.
     if error-status :error then do: undo, return error. end.
     run full-recount in this-procedure no-error.
     if error-status :error then do: undo, return error. end.
  end.
end.
run UI-on in this-procedure ( input "line" ).
END PROCEDURE.
PROCEDURE val-ch-type :
define input parameter parself-name as character no-undo.
if parself-name = "slt-type" then do: run val-ch-slt-type in this-procedure no-error. end.
else do:
   if parself-name = "vat-type" then do: run val-ch-vat-type in this-procedure no-error. end.
                                else do:
                                   message "Неверный self:name " parself-name
                                           " при передаче в процедуру val-ch-type."
                                   view-as alert-box error.
                                   return error.
                                end.
end.
if error-status :error then do:
      display t-doc.vat-type with frame d-in-doc.
      display t-doc.slt-type with frame d-in-doc.
      return no-apply.
end.
END PROCEDURE.
PROCEDURE val-ch-vat-type :
define buffer d-l-b for  ub.doc-line.
define variable old-vat as character no-undo.
define variable vd-price-cli   like ub.doc-line.price-cli  no-undo.
define variable vd-price-base  like ub.doc-line.price-base no-undo.
define variable vd-price-rubl  like ub.doc-line.price-rubl no-undo.
define variable vd-vat-pc      like ub.doc-line.vat-pc     no-undo.
define variable vd-slt-pc      like ub.doc-line.slt-pc     no-undo.
define variable vd-road-tax    like ub.doc-line.road-tax   no-undo.
define variable vd-excise      like ub.doc-line.excise     no-undo.
define buffer bf-goods for ub.goods.
run check-update in this-procedure no-error.
 if error-status :error then do: return error. end.
do transaction on error   undo, return error
               on end-key undo, return error
               on stop    undo, return error :
  assign
    old-vat = t-doc.vat-type.
  ASSIGN frame d-in-doc t-doc.VAT-type.
  if t-doc.vat-type  = 'без':U and
     old-vat        <> 'без':U then do:
      message "НДС в строках устанавливаем в 0" view-as alert-box information.
      for each d-l-b where d-l-b.doc-code = t-doc.doc-code:
          assign d-l-b.vat-pc = 0.
      end.
  end.
  else do:
    if t-doc.vat-type <> 'без':U and
           old-vat = 'без':U then do:
      message "НДС в строках устанавливаем из последней поставки поставщика по данному товару. Если таковой не имеется, то из карточки товара." view-as alert-box information.
      for each d-l-b where d-l-b.doc-code = t-doc.doc-code,
               first bf-goods where bf-goods.artic     = d-l-b.artic and
                                    bf-goods.prod-type = d-l-b.prod-type and
                                    bf-goods.prod-code = d-l-b.prod-code:
        assign
          vd-vat-pc = ?.
        run cpprclig in this-procedure   (
          input        t-doc.doc-code             ,
          input        t-doc.cli-code             ,
          input        t-doc.cli-type             ,
          input        t-doc.host-code            ,
          input        t-doc.base-rate            ,
          input        t-doc.base-scale           ,
          input        t-doc.exch-rate            ,
          input        t-doc.exch-scale           ,
          input        t-doc.vat-type             ,
          input        t-doc.slt-type             ,
          input        d-l-b.artic                ,
          input        d-l-b.prod-type            ,
          input        d-l-b.prod-code            ,
          input        yes                        ,
          input        d-l-b.cli-base-rate        ,
          input        d-l-b.transport-rubl       ,
          input        d-l-b.other-rubl           ,
          output       vd-price-cli               ,
          output       vd-price-base              ,
          output       vd-price-rubl              ,
          input-output vd-vat-pc                  ,
          input-output vd-slt-pc                  ,
          input-output vd-road-tax                ,
          input-output vd-excise                  ) no-error.
          if vd-vat-pc = ? then do:
define variable vss-include-info146 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  t-doc.host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output vd-vat-pc
  ) no-error .
            if vd-vat-pc = ? then do:
              message "Нет НДС в карточке товара по товару: " d-l-b.artic " " d-l-b.prod-type " " d-l-b.prod-code "." skip
                      "НДС остается равным 0." view-as alert-box.
            end.
          end.
          assign d-l-b.vat-pc = vd-vat-pc.
      end.
    end.
  end.
  run check-rate in this-procedure no-error.
  if error-status :error then do: undo, return error. end.
  run full-recount in this-procedure no-error.
  if error-status :error then do: undo, return error. end.
end.
run UI-on in this-procedure ( input "line" ).
END PROCEDURE.
PROCEDURE vc-purch-code :
define variable varpurch-int-code like ub.trn-doc.purch-code no-undo.
  assign
    varpurch-int-code = lookup( input frame d-in-doc varpurch-code-name, 'выкуп,консигнация,ответственное хранение,старая консигнация':U ).
  if t-doc.purch-code <> varpurch-int-code then do:
    run chg-purch-code in this-procedure ( input varpurch-int-code ) no-error.
    if error-status :error then do:
      message "Ошибка при смене кода приобретения." skip
              return-value skip
              error-status :get-message( 1 )
              error-status :get-message( 2 )
      view-as alert-box error.
      display varpurch-code-name with frame d-in-doc.
    end.
        assign
      varpurch-code-name = entry (lookup (string(t-doc.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
    display varpurch-code-name with frame d-in-doc.
  end.
END PROCEDURE.
procedure chg-purch-contract :
  define buffer bf_contract for ub.contract.
  do on error undo, return error return-value :
    define variable v-purch-code as character no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_purchcon in g#lib-trn3
( input t-doc.host-code
, input t-doc.contract-code
, output v-purch-code
, output varpurch-code-name
) .
    display varpurch-code-name with frame d-in-doc.
    run vc-purch-code in this-procedure no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
end procedure.
PROCEDURE wr-cst-code :
define variable v-num as integer no-undo.
define buffer cst-parts for ub.parts.
define buffer buf_doc-line for  ub.doc-line.
do on error undo, return error return-value :
  if can-find(first cst-parts where cst-parts.out-code = t-doc.doc-code no-lock) then do:
    run gbl/d-askw.w ("Замена номера ГТД в партиях документа",
                  "Изменить номера ГТД в партиях документа?",
                  "|^",
                  "Все партии|Тот же № ГТД|Отмена",
                  "Проходим по всем партиям документа и заменяем номер ГТД|Идем по партиям, где номер был "
                  + "'" + t-doc.cst-code + "'" + "|Ничего не делаем",
                  2,
                  3,
                  output v-num
                 ).
    case v-num:
    when 3 then do:
      display t-doc.cst-code with frame d-in-doc.
      return.
    end.
    when 2 then do:
      if v-is-gtd-part = "yes" then do:
        for each cst-parts where cst-parts.obj-type = t-doc.obj-type and                                     cst-parts.obj-code = t-doc.obj-code and                                     cst-parts.out-code = t-doc.doc-code and                                     cst-parts.cst-code begins t-doc.cst-code:
          if LENGTH( input frame d-in-doc t-doc.cst-code ) > 0 then do:
            if SUBSTRING( cst-parts.cst-code, LENGTH( t-doc.cst-code ) + 1 ,1 ) = '/' or cst-parts.cst-code = t-doc.cst-code then
              assign cst-parts.cst-code = input frame d-in-doc t-doc.cst-code + SUBSTRING( cst-parts.cst-code, LENGTH( t-doc.cst-code ) + 1 )  .
          end.
          else assign cst-parts.cst-code = "" .
        end.
      end.
      else do:
        for each cst-parts where cst-parts.obj-type = t-doc.obj-type and                                     cst-parts.obj-code = t-doc.obj-code and                                     cst-parts.out-code = t-doc.doc-code and                                     cst-parts.cst-code = t-doc.cst-code:
          assign cst-parts.cst-code = input frame d-in-doc t-doc.cst-code.
        end.
      end.
    end.
    when 1 then do:
      for each cst-parts where cst-parts.obj-type = t-doc.obj-type and                                     cst-parts.obj-code = t-doc.obj-code and                                     cst-parts.out-code = t-doc.doc-code:
         assign cst-parts.cst-code = input frame d-in-doc t-doc.cst-code.
      end.
    end.
    end case.
  end.
  assign t-doc.cst-code = input frame d-in-doc t-doc.cst-code.
end.
  if v-is-gtd-part = "yes" then run UI-on in this-procedure ( input "line" ) .
END PROCEDURE.
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
procedure gtd-line :
  do on error undo, return error return-value :
    if pardoc-mode <> 'ДОБАВЛЕНИЕ':U and pardoc-mode <> 'ИЗМЕНЕНИЕ':U then return.
    if not available  ub.doc-line then  return.
    define variable v-res as logical   no-undo .
    define buffer buf_doc-line for  ub.doc-line.
    define buffer buf_parts for ub.parts.
    find first buf_parts no-lock
      where buf_parts.obj-type  =  ub.doc-line.obj-type
        and buf_parts.obj-code  =  ub.doc-line.obj-code
        and buf_parts.artic     =  ub.doc-line.artic
        and buf_parts.prod-type =  ub.doc-line.prod-type
        and buf_parts.prod-code =  ub.doc-line.prod-code
        and buf_parts.out-code  =  ub.doc-line.doc-code
    no-error .
    if available buf_parts then do:
      if buf_parts.cst-code  BEGINS t-doc.cst-code and (SUBSTRING( buf_parts.cst-code, LENGTH( t-doc.cst-code ) + 1 ,1 ) = '/' or buf_parts.cst-code = t-doc.cst-code) then do:
        if LENGTH( t-doc.cst-code ) > 0 then assign d-gtd-add = SUBSTRING( buf_parts.cst-code, LENGTH( t-doc.cst-code ) + 2 ) .
        else do:
          message "ГТД документа не заполнен! Ввод дополнения невозможен."  view-as alert-box.
          return.
        end.
      end.
      else do:
        message "Префикс ГТД строки не совпадает с ГТД документа! Ввод дополнения невозможен."  view-as alert-box.
        return.
      end.
    end.
    run str/gtd-add.w (input ub.goods.artic, input (ub.goods.prod-type + string(ub.goods.prod-code)),goods.gds-name, input t-doc.cst-code, input-output d-gtd-add, output v-res) .
    if v-res then do:
      for each buf_parts
        where buf_parts.obj-type  = t-doc.obj-type
          and buf_parts.obj-code  = t-doc.obj-code
          and buf_parts.artic     =  ub.doc-line.artic
          and buf_parts.prod-type =  ub.doc-line.prod-type
          and buf_parts.prod-code =  ub.doc-line.prod-code
          and buf_parts.out-code  = t-doc.doc-code
        :
        if d-gtd-add = "" then assign buf_parts.cst-code = t-doc.cst-code .
        else assign buf_parts.cst-code = t-doc.cst-code + "/" + d-gtd-add .
      end.
      display d-gtd-add with browse br-dtl .
    end.
  end.
end procedure.
FUNCTION deviation-price RETURNS DECIMAL
(buffer local-doc-line for ub.doc-line) :
define buffer bf_doc-line for ub.doc-line.
define buffer bf_trn-doc  for ub.trn-doc.
if local-doc-line.fact-order = 0 then do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type           and
                              bf_doc-line.obj-code     = t-doc.obj-code           and
                              bf_doc-line.prod-type    = local-doc-line.prod-type and
                              bf_doc-line.prod-code    = local-doc-line.prod-code and
                              bf_doc-line.artic        = local-doc-line.artic     and
                              bf_doc-line.ext-doc-type = 'ie':U       and
                              bf_doc-line.status_      = 'факт':U                  and
                              bf_doc-line.fact-order   > 0                        and
                              can-find(first bf_trn-doc where
                                             bf_trn-doc.doc-code = bf_doc-line.doc-code
                                         and bf_trn-doc.ext-doc-type = 'ie':U)
                              use-index dt-fo no-lock no-error.
  if available bf_doc-line then do:
    return (local-doc-line.price-rubl - bf_doc-line.price-rubl) / bf_doc-line.price-rubl * 100.
  end.
  else do:
    return ?.
  end.
end.
else do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type            and
                              bf_doc-line.obj-code     = t-doc.obj-code            and
                              bf_doc-line.prod-type    = local-doc-line.prod-type  and
                              bf_doc-line.prod-code    = local-doc-line.prod-code  and
                              bf_doc-line.artic        = local-doc-line.artic      and
                              bf_doc-line.ext-doc-type = 'ie':U        and
                              bf_doc-line.status_      = 'факт':U                   and
                              bf_doc-line.fact-order   < local-doc-line.fact-order and
                              can-find(first bf_trn-doc where
                                             bf_trn-doc.doc-code = bf_doc-line.doc-code
                                         and bf_trn-doc.ext-doc-type = 'ie':U)
                              use-index dt-fo no-lock no-error.
  if available bf_doc-line then do:
    return (local-doc-line.price-rubl - bf_doc-line.price-rubl) / bf_doc-line.price-rubl * 100.
  end.
  else do:
    return ?.
  end.
end.
end function.
FUNCTION get-kg-after-qnty RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg like ub.doc-line.fact-qnty no-undo.
  run after_qnty in this-procedure    ( input recid( local-doc-line ),
                                        output d_out-qnty-kg        )
                                        no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.
FUNCTION get-kg-fact-qnty RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg like ub.doc-line.fact-qnty no-undo.
  run inv-line_qnty in this-procedure ( input recid( local-doc-line ),             output d_out-qnty-kg       ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.
FUNCTION get-kg-sale-base RETURNS DECIMAL
( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-kg-sale-price like ub.doc-line.price-rubl no-undo.
  run inv-line_price in this-procedure ( input recid( local-doc-line ), input  no, output d_out-kg-sale-price ) no-error.
  return ( if error-status :error then ? else d_out-kg-sale-price ).
end function.
FUNCTION get-kg-sale-rubl returns decimal
( buffer local-doc-line for ub.doc-line ) :
define variable d_out-kg-sale-price like ub.doc-line.price-rubl no-undo.
run inv-line_price in this-procedure ( input recid( local-doc-line ), input yes, output d_out-kg-sale-price ) no-error.
return ( if error-status :error then ? else d_out-kg-sale-price ).
end function.
FUNCTION get-mark RETURNS CHARACTER
(buffer local-doc-line for  ub.doc-line ):
if lookup (string (recid (local-doc-line)), del-list) > 0  then return "*".
                                                           else return "".
end function.
FUNCTION last-price RETURNS DECIMAL
(buffer local-doc-line for ub.doc-line) :
define buffer bf_doc-line for ub.doc-line.
define buffer bf_trn-doc for ub.trn-doc.
if local-doc-line.fact-order = 0 then do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type           and
                              bf_doc-line.obj-code     = t-doc.obj-code           and
                              bf_doc-line.prod-type    = local-doc-line.prod-type and
                              bf_doc-line.prod-code    = local-doc-line.prod-code and
                              bf_doc-line.artic        = local-doc-line.artic     and
                              bf_doc-line.ext-doc-type = 'ie':U       and
                              bf_doc-line.status_      = 'факт':U                  and
                              bf_doc-line.fact-order   > 0                        and
                              can-find(first bf_trn-doc where
                                             bf_trn-doc.doc-code = bf_doc-line.doc-code
                                         and bf_trn-doc.ext-doc-type = 'ie':U)
                              use-index dt-fo no-lock no-error.
  if available bf_doc-line then do:
    return bf_doc-line.price-rubl.
  end.
  else do:
    return ?.
  end.
end.
else do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type            and
                              bf_doc-line.obj-code     = t-doc.obj-code            and
                              bf_doc-line.prod-type    = local-doc-line.prod-type  and
                              bf_doc-line.prod-code    = local-doc-line.prod-code  and
                              bf_doc-line.artic        = local-doc-line.artic      and
                              bf_doc-line.ext-doc-type = 'ie':U        and
                              bf_doc-line.status_      = 'факт':U                   and
                              bf_doc-line.fact-order   < local-doc-line.fact-order and
                              can-find(first bf_trn-doc where
                                             bf_trn-doc.doc-code = bf_doc-line.doc-code
                                         and bf_trn-doc.ext-doc-type = 'ie':U)
                              use-index dt-fo no-lock no-error.
  if available bf_doc-line then do:
    return bf_doc-line.price-rubl.
  end.
  else do:
    return ?.
  end.
end.
end function.
function get-add-gtd returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-gtd as character no-undo .
  define buffer buf_parts for ub.parts.
  if v-is-gtd-part = "yes" then do:
    find first buf_parts no-lock
      where buf_parts.obj-type  = local-doc-line.obj-type
        and buf_parts.obj-code  = local-doc-line.obj-code
        and buf_parts.artic     = local-doc-line.artic
        and buf_parts.prod-type = local-doc-line.prod-type
        and buf_parts.prod-code = local-doc-line.prod-code
        and buf_parts.out-code  = local-doc-line.doc-code
    no-error .
    if available buf_parts then do:
      if length(t-doc.cst-code) > 0 and (buf_parts.cst-code  BEGINS t-doc.cst-code) then do:
        if SUBSTRING( buf_parts.cst-code, LENGTH( t-doc.cst-code ) + 1 ,1 ) = '/' then
          assign d_out-gtd = SUBSTRING( buf_parts.cst-code, LENGTH( t-doc.cst-code ) + 2 ) .
      end.
    end.
  end.
  return d_out-gtd .
end function.
FUNCTION get-vsdsts RETURNS CHARACTER
(buffer local-doc-line for doc-line ):
  def var v-mercury-prod as logical no-undo.
  if v-is-mercury-value
  then do:
    def buffer bf_gds for ub.goods.
    find first bf_gds where
          local-doc-line.artic = bf_gds.artic
      and local-doc-line.prod-type = bf_gds.prod-type
      and local-doc-line.prod-code = bf_gds.prod-code.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  bf_gds.gds-code
  ,input  'mercur_FGIS=request':u
  ,output v-mercury-prod
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Код товара" bf_gds.gds-code skip
        'mercur_FGIS=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-mercury-prod
    then do:
      if vsdstrObj:exsistvsd( buffer local-doc-line )
      then do:
        return "+".
      end.
      else do with frame d-in-doc:
        return "-".
      end.
    end.
  end.
  return "".
end function.
FUNCTION get-vat-sum RETURNS decimal
(buffer local-doc-line for doc-line ):
  def var v-vat-sum as decimal no-undo.
  v-vat-sum = (ub.doc-line.cli-qnty *  ub.doc-line.price-cli * doc-line.VAT-pc) / (100 + doc-line.VAT-pc) .
  return v-vat-sum.
end function.
procedure rowdisp :
  def var v-vsdsts-fail as logical no-undo.
  assign
    v-vsdsts-fail = (get-vsdsts(buffer ub.doc-line) = "-").
  if v-vsdsts-fail
  then do ii = 1 to extent (bcol):
    if valid-handle (bcol[ii])
    then do:
      assign
        bcol[ii]:bgcolor = RED_COLOR.
    end.
  end.
end procedure.
procedure add-lgas-corr :
  def var loc-ref-list as character no-undo.
  def var v-gds-code as integer no-undo.
  run str/all-docs.w
    (  input parparentproc,
        input t-doc.host-code ,
        input t-doc.obj-type ,
        input t-doc.obj-code ,
        input 'статус':U,
        input 'факт':U,
        input 'при':U,
        input ?,
        input no,
        input "b-sel,":U + 'is-lgas-corr':U,
        input 'ie':U,
        input false,
        input ?,
        output loc-ref-list ).
    find t-d-b where recid (t-d-b) = integer (loc-ref-list) no-lock no-error.
    if not available t-d-b then do:
      message "Не выбран документ-источник для корр. СУГ." view-as alert-box.
      return error.
    end.
    if not t-d-b.status_ = 'факт':U
    then do:
      message "Неверный выбор документа-источника для корр. СУГ."
        skip "Документ не закрыт на факт." view-as alert-box.
      return error.
    end.
    find clients where clients.obj-type = t-d-b.cli-type and clients.obj-code = t-d-b.cli-code no-lock.
    disp clients.obj-code @ t-doc.cli-code
            clients.obj-name with frame d-in-doc.
    disp clients.obj-type @ t-doc.cli-type with frame d-in-doc.
        run check-cli no-error.
        if error-status :error then return no-apply.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-d-b.doc-code ,
                        input 'is-lgas':U ,
                       output varvalue ,
                       output vartype ) no-error .
     if not varvalue = "yes" then do:
      message "Неверный выбор документа-источника для корр. СУГ."
        skip "Документ не является приходной накладной СУГ." view-as alert-box.
      return error.
   end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'trn-lgas-corr':U ,
                       input t-d-b.doc-code ) no-error .
  find first ub.doc-line no-lock where ub.doc-line.doc-code = t-d-b.doc-code no-error.
  if available (ub.doc-line)
  then do:
define variable vss-include-info147 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run doclicod in g#library
  (input  recid(ub.doc-line)
  ,output v-gds-code
  )  .
    find first ub.goods no-lock where ub.goods.gds-code = v-gds-code no-error.
    if available (ub.goods)
    then do:
      varnotes = string (recid (ub.goods)).
      run cycle-add in this-procedure.
    end.
  end.
  def buffer buf_doc-attr for ub.doc-attr.
  for each tt-upd-attr-fuel :
    find first ub.doc-attr where ub.doc-attr.doc-code = t-d-b.doc-code and ub.doc-attr.attr-code = tt-upd-attr-fuel.code no-lock no-error.
    if available (ub.doc-attr)
    then do:
      find first buf_doc-attr
        where buf_doc-attr.doc-code = t-doc.doc-code
          and buf_doc-attr.attr-code = tt-upd-attr-fuel.code no-error.
      if not available (buf_doc-attr)
      then do:
        create buf_doc-attr.
        buf_doc-attr.doc-code = t-doc.doc-code.
      end.
      buffer-copy ub.doc-attr except ub.doc-attr.doc-code
      to buf_doc-attr.
    end.
  end.
  find first ub.doc-attr where ub.doc-attr.doc-code = t-d-b.doc-code and ub.doc-attr.attr-code = 'nids':U no-lock no-error.
  if available (ub.doc-attr)
  then do:
    find first buf_doc-attr
      where buf_doc-attr.doc-code = t-doc.doc-code
        and buf_doc-attr.attr-code = tt-upd-attr-fuel.code no-error.
    if not available (buf_doc-attr)
    then do:
      create buf_doc-attr.
      buf_doc-attr.doc-code = t-doc.doc-code.
    end.
    buffer-copy ub.doc-attr except ub.doc-attr.doc-code
    to buf_doc-attr.
  end.
  find first ub.doc-attr where ub.doc-attr.doc-code = t-d-b.doc-code and ub.doc-attr.attr-code = 'dids':U no-lock no-error.
  if available (ub.doc-attr)
  then do:
    find first buf_doc-attr
      where buf_doc-attr.doc-code = t-doc.doc-code
        and buf_doc-attr.attr-code = tt-upd-attr-fuel.code no-error.
    if not available (buf_doc-attr)
    then do:
      create buf_doc-attr.
      buf_doc-attr.doc-code = t-doc.doc-code.
    end.
    buffer-copy ub.doc-attr except ub.doc-attr.doc-code
    to buf_doc-attr.
  end.
end procedure.
