using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.
define input parameter parParentProc        as widget-handle no-undo.
define input parameter t-action             as character no-undo .
define input parameter p-deliv-type-code    as integer   no-undo .
define input parameter p-point-obj-code     as integer   no-undo .
define input parameter p-point-cli-code     as integer   no-undo .
define input parameter p-point-obj-db-num   as integer   no-undo .
define input parameter p-point-cli-db-num   as integer   no-undo .
define input parameter p-transport-host-code     as integer   no-undo .
define input parameter p-transport-cli-type     as character no-undo .
define input parameter p-transport-cli-code     as integer   no-undo .
define input parameter p-transport-contract   as integer   no-undo .
define input parameter p-transport-condition  as integer   no-undo .
define input parameter p-transport-value      as decimal   no-undo .
define input parameter p-transport-sum        as decimal   no-undo .
define input parameter p-transport-vat        as decimal   no-undo .
define input parameter is-edoc-nn-doc         as logical   no-undo .
define input parameter is-edi-doc             as logical   no-undo .
define input parameter p-dm-edi               as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: e470dcf1e011, 295, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:38 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-save.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-save.p $":U .
define variable vss-description as character no-undo init "Сохранение данных введенных на экране в базу  ЗАКАЗЫ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table tmp#zakaz1 no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field local-mark    as character field max-stock     as decimal   field season-coef   as decimal   field min-stock-old as decimal   field gds-way       as decimal   index pi is unique primary artic prod-type prod-code  ascending index idx-ln line-num.
define shared temp-table tmp#zakaz-prn1 no-undo field artic         like ub.goods.artic      field prod-type     like ub.goods.prod-type  field prod-code     like ub.goods.prod-code  field obj-type      like ub.clients.obj-type field obj-code      like ub.clients.obj-code field prt-code      as   integer    field qnty-sale     as   decimal    field qnty-ord      as   decimal    index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.
define shared temp-table tmp#zakaz-dtl1 no-undo like ub.ord-dtl field prt-name as character index bi is unique primary artic prod-type prod-code node-code  ascending.
define  shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define  shared buffer buf-goods   for ub.goods     .
define  shared buffer sb-cli-gds  for ub.cli-gds   .
define  shared buffer sb-gds-obj  for ub.gds-obj   .
define  shared buffer tmp#zakaz     for tmp#zakaz1.
define  shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define  shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define  shared  buffer shar_ord-doc  for ub.ord-doc .
define  shared  buffer shar_ord-line for ub.ord-line.
define  shared  buffer shar_ord-dtl  for ub.ord-dtl .
define  shared variable chexcelapplication      as com-handle no-undo .
define  shared variable chworkbook              as com-handle no-undo .
define  shared variable chworksheet             as com-handle no-undo .
define  shared variable chrange                 as com-handle no-undo .
define  shared variable chworksheet2            as com-handle no-undo .
define  shared variable chworksheet3            as com-handle no-undo .
define  shared variable accum-zakaz             as decimal no-undo .
define  shared variable accum-sum-zakaz         as decimal no-undo .
define  shared variable accum-count             as integer no-undo .
define  shared buffer buf-cli for ub.clients.
define  shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.
define  shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.
define  shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.
define    shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define    shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define    shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.
define    shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.
define    shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.
define    shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.
define    shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.
define    shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
define    shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.
define   shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.
define   shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define   shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.
define  shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.
define    shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.
define  shared variable loc-status  as character  no-undo.
define  shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.
define  shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.
define  shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.
define  shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.
define  shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.
define  shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.
define  shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.
define  shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.
define  shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.
define  shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(руб.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(руб)"
     fgcolor 4
     no-undo.
define  shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.
define  shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.
define  shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.
define  shared var loc-print-rubl as logical no-undo .
define  shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define  shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define    shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.
define  shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define  shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define  shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define  shared  variable temp-e-method  as character no-undo .
define  shared  variable x-tog-artic as logical   no-undo .
define  shared  variable x-tog-grp    as logical   no-undo .
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
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-clients-calc :
define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-method   as character no-undo .
define output parameter p-error    as logical   no-undo .
define variable v-not-corr-op as character no-undo .
define variable v-type as character no-undo .
  do
  on error undo, return error return-value
  :
 p-error = false .
 v-not-corr-op  = 'no' .
 run clntattr-value (
    input   p-obj-type
  , input   p-obj-code
  , input   'not-corr-op':U
  , output  v-not-corr-op
  , output  v-type
  ) no-error .
  if error-status :error then v-not-corr-op  = 'no' .
  if v-not-corr-op = 'yes' and  p-method = ""  then do:
    assign v-not-corr-op = 'no' .
    run clntattr-value (
    input   p-cli-type
  , input   p-cli-code
  , input   'not-corr-op':U
  , output  v-not-corr-op
  , output  v-type
  ) no-error .
  if error-status :error then v-not-corr-op  = 'no' .
  if v-not-corr-op = 'yes'  and  p-method = ""  then p-error = true .
  end.
  end.
end procedure.
procedure ver-ord-line :
define input parameter  p-doc-code like ub.ord-doc.doc-code no-undo .
define output parameter p-error    as logical               no-undo .
define variable v-longchar          as longchar  no-undo .
define variable v-err-ext           as logical   no-undo .
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-event-code        as character no-undo .
define variable v-ok                as logical   no-undo .
define variable v-nabor             as logical   no-undo .
define buffer buf_ord-line for ub.ord-line.
define buffer buf_ord-doc  for ub.ord-doc.
v-err-ext  = false .
find first buf_ord-doc no-lock
  where buf_ord-doc.doc-code = p-doc-code no-error.
  if not available buf_ord-doc then do:
  end.
  else do:
for each buf_ord-line of buf_ord-doc
  break by buf_ord-line.cli-art :
    if buf_ord-doc.doc-type <> 'ПО':U  and
       buf_ord-doc.doc-type <> 'ФП':U  then do:
       var-ok-assort-pol = true .
       v-event-code = buf_ord-doc.doc-type + "-" .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol + chr(10) .
           end.
    end.
    if  buf_ord-doc.cli-type = 'маг':U or
           buf_ord-doc.cli-type = 'скл':U then do:
            var-ok-assort-pol = true .
            v-event-code = "cli_" + buf_ord-doc.doc-type + "-" .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.cli-type
  ,input  buf_ord-doc.cli-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol  + chr(10) .
           end.
       end.
    if buf_ord-doc.doc-type = 'ПО':U  then do:
        var-ok-assort-pol = true .
        v-event-code = buf_ord-doc.doc-type + "-" .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassmat in g#library2
  (input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  )  .
        if var-ok-assort-pol = false then do:
          v-err-ext  = true  .
          v-longchar = v-longchar + var-mess-assort-pol  + chr(10) .
        end.
    end.
  end.
  if v-err-ext = true  then do:
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Проверка строк заказа\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "4"
            view-as alert-box error
          .
          assign
          v-longchar = '':U.
      define variable vq as logical   no-undo init true .
      return error .
    end.
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-attr-name :
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
            when 'gds-grp-nabor':U then do:     assign     p-label = "Набор"     p-type = 'L':U      p-format = "yes/no"     p-label = "Набор"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-tooltip = "Набор - не товарные позиции"     p-label = "Набор" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-value :
do
on error undo, return error
:
define input  parameter p-node-code   as integer    no-undo.
define input  parameter p-code        as character  no-undo.
define input  parameter p-host-code   as integer    no-undo.
define input  parameter p-obj-type    as character  no-undo.
define input  parameter p-obj-code    as integer    no-undo.
define output parameter p-value       as character  no-undo.
define output parameter p-type        as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_gds-grp-attr for ub.gds-grp-attr.
    run grp-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-code
           and buf_gds-grp-attr.host-code = p-host-code
           and buf_gds-grp-attr.obj-type  = p-obj-type
           and buf_gds-grp-attr.obj-code  = p-obj-code
    no-error .
    if available buf_gds-grp-attr
    then do:
        assign
            p-value = buf_gds-grp-attr.attr-value
        .
    end.
    else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
    end.
end.
end procedure.
procedure grp-attr-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code      no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-value      like ub.gds-grp-attr.attr-value     no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    run grp-attr-name in this-procedure (
                      input  p-code
                    , output v-type
                    , output v-format
                    , output v-label
                    , output v-user-can-edit
                    , output v-output-display
                    , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        create buf_gds-grp-attr.
        assign
                buf_gds-grp-attr.node-code  = p-node-code
                buf_gds-grp-attr.attr-code  = p-code
                buf_gds-grp-attr.host-code  = p-host-code
                buf_gds-grp-attr.obj-type   = p-obj-type
                buf_gds-grp-attr.obj-code   = p-obj-code
                buf_gds-grp-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_gds-grp-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure grp-attr-delete :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code  no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code  no-undo.
define input parameter p-host-code  as integer                      no-undo.
define input parameter p-obj-type   like ub.clients.obj-type        no-undo.
define input parameter p-obj-code   like ub.clients.obj-code        no-undo.
define output parameter p-deleted   as logical                      no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run grp-attr-name in this-procedure
    ( input  p-code
    , output v-type
    , output v-format
    , output v-label
    , output v-user-can-edit
    , output v-output-display
    , output v-other
    ) no-error .
    if error-status :error then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
       delete buf_gds-grp-attr.
       assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure grp-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error "неизвестный атрибут товара на фирме" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure grp-attr-obj-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-attr-code as character    no-undo .
define output parameter p-attr-value     as character   no-undo.
define output parameter p-range     as integer      no-undo.
define output parameter p-exists    as logical      no-undo.
define variable v-host-code as integer      no-undo.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-attr      for ub.gds-grp-attr.
find first buf_gds-grp-attr no-lock
     where buf_gds-grp-attr.node-code = p-node-code
       and buf_gds-grp-attr.attr-code = p-attr-code
       and buf_gds-grp-attr.host-code = v-host-code
       and buf_gds-grp-attr.obj-type  = p-obj-type
       and buf_gds-grp-attr.obj-code  = p-obj-code
no-error .
if not available buf_gds-grp-attr
then do:
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-attr-code
           and buf_gds-grp-attr.host-code = v-host-code
           and buf_gds-grp-attr.obj-type  = ""
           and buf_gds-grp-attr.obj-code  = 0
    no-error .
    if not available buf_gds-grp-attr
    then do:
        find first buf_gds-grp-attr no-lock
            where buf_gds-grp-attr.node-code = p-node-code
            and buf_gds-grp-attr.attr-code = p-attr-code
            and buf_gds-grp-attr.host-code = 0
            and buf_gds-grp-attr.obj-type  = ""
            and buf_gds-grp-attr.obj-code  = 0
        no-error .
        if not available buf_gds-grp-attr
        then do:
            assign
                p-exists = no
            .
        end.
        else do:
            assign
                p-exists = yes
                p-range  = 1
            .
        end.
    end.
    else do:
        assign
            p-exists = yes
            p-range  = 2
        .
    end.
end.
else do:
    assign
        p-exists = yes
        p-range  = 3
    .
end.
if available buf_gds-grp-attr
then do:
  assign
  p-attr-value = buf_gds-grp-attr.attr-value
  .
end.
end.
end procedure.
procedure ver-gds-grp-nabor :
do
on error undo, return error return-value
:
define input  parameter p-gds-code as integer   no-undo .
define output parameter p-nabor as logical   no-undo .
define buffer buf_goods for ub.goods.
p-nabor = false .
find first  buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
if error-status :error then return error .
define variable v-value       as character  no-undo.
define variable v-type        as character  no-undo.
  run grp-attr-value (
     input   buf_goods.grp-code
    ,input   'gds-grp-nabor':U
    ,input   0
    ,input   ""
    ,input   0
    ,output  v-value
    ,output  v-type       ) no-error .
    if error-status :error then return error .
  if v-value = "yes" then p-nabor = true  .
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info13 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info13, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info13, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info13, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info13, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info13 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info13, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info13 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info13, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info13, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info13, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info13, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info13, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info13, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info13 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info13 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info13, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info13, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info13, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info13 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info13 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info13, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info13, v-inform, v-tbl-name ).
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION status-edoc-nn RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
define variable v-obj-db-num as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients  .
define buffer obj_clients for ub.clients  .
define buffer buf_ext-classif for ub.ext-classif  .
define buffer buf2_ext-classif for ub.ext-classif  .
define buffer buf_ext-system  for ub.ext-system  .
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  loc-o-doc.obj-type
  ,input  loc-o-doc.obj-code
  ,output v-obj-db-num
  )  .
find first  buf_clients no-lock where
            buf_clients.obj-type = loc-o-doc.cli-type and
            buf_clients.obj-code = loc-o-doc.cli-code
              no-error .
if not available buf_clients then do:
  p-color = ?.
  return "" .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'clients-edoc-nn':U no-error.
if available buf_ext-classif then do :
  assign
  p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
  no-error .
  return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
end.
else do :
  find first obj_clients no-lock where
            obj_clients.obj-type = loc-o-doc.obj-type
        and obj_clients.obj-code = loc-o-doc.obj-code no-error.
  if not available obj_clients then do:
    return ''.
  end.
  run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                    , input (buffer obj_clients:handle)
                                    , output v-obj-uniq-key-rec).
  for each buf_ext-classif no-lock
        where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
          and buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name    = 'exite-edi':U,
     first buf_ext-system no-lock
        where buf_ext-system.esys-id = buf_ext-classif.key#_one
          and buf_ext-system.db-num  = 0
          and buf_ext-system.esys-have-export = yes
          and buf_ext-system.esys-db-num-exp = v-obj-db-num,
     first buf2_ext-classif no-lock
              where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
                and buf2_ext-classif.classif-subject = 'clients':U
                and buf2_ext-classif.classif-name    = 'exite-edi':U
                and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end.
  return ''.
end.
return ''.
END FUNCTION.
FUNCTION status-is-edoc-nn RETURN logical ( input p-is-edoc-nn   as logical
                                             , input p-cli-type     as character
                                             , input p-cli-code     as integer
                                             , input p-obj-type     as character
                                             , input p-obj-code     as integer
                                             ) .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edoc-nn then do:
  return no.
end.
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
     where buf_ext-classif.uniq-key-rec    = v-uniq-key-rec
       and buf_ext-classif.classif-subject = 'clients':U
       and buf_ext-classif.classif-name    = 'clients-edoc-nn':U
       no-error.
if available buf_ext-classif then do :
  return yes .
end.
return no.
END FUNCTION.
FUNCTION status-is-edi RETURN logical ( input p-is-edi as logical
                                         , input p-cli-type as character
                                         , input p-cli-code as integer
                                         , input p-obj-type     as character
                                         , input p-obj-code     as integer
                                         , output p-dm-edi as integer
                                         ) .
define variable v-obj-db-num   as integer   no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer obj_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf2_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edi then do:
  return no.
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
find first obj_clients no-lock where
          obj_clients.obj-type = p-obj-type
      and obj_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer obj_clients:handle)
                                  , output v-obj-uniq-key-rec).
for each buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'exite-edi':U,
    first buf_ext-system no-lock
      where buf_ext-system.esys-id = buf_ext-classif.key#_one
        and buf_ext-system.db-num  = 0
        and buf_ext-system.esys-have-export = yes
        and (buf_ext-system.esys-db-num-exp = v-obj-db-num
        or buf_ext-system.esys-db-num-exp = 0),
    first buf2_ext-classif no-lock
            where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
              and buf2_ext-classif.classif-subject = 'clients':U
              and buf2_ext-classif.classif-name    = 'exite-edi':U
              and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
  leave.
end.
if available buf_ext-classif then do :
  p-dm-edi = buf_ext-system.whole-send-news.
  return yes .
end.
return no .
END FUNCTION.
FUNCTION get-gln returns character ( input p-obj-type as character
                                    ,input p-obj-code as integer):
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return chr(63).
end.
run gen-key-rec  in this-procedure ( input 'clients':U
                                    ,input (buffer buf_clients:handle)
                                    ,output v-uniq-key-rec) no-error.
if error-status:error then do:
   return chr(63).
end.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error .
if available buf_ext-classif then do:
  return buf_ext-classif.charkey_one.
end.
else do:
 return ''.
end.
END FUNCTION.
FUNCTION get-type-code-from-gln returns logical ( input  p-gln      as character
                                                    ,output p-obj-type as character
                                                    ,output p-obj-code as integer) :
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.charkey_one = p-gln no-error .
if available buf_ext-classif then do:
  assign v-uniq-key-rec = buf_ext-classif.uniq-key-rec.
end.
else do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
if v-uniq-key-rec <> '' then do:
    run gen-key-fv in this-procedure ( input  v-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
end.
assign
  p-obj-type = entry(lookup("obj-type":U
                          , v-field-list
                          , chr(3))
                          , v-value-list, chr(3))
  p-obj-code = integer(entry(lookup("obj-code":U
                                  , v-field-list
                                  , chr(3))
                                  , v-value-list, chr(3)))
no-error .
if error-status:error then do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
else do:
  return yes.
end.
END FUNCTION.
FUNCTION status-edoc-edi-light RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
case loc-o-doc.whole-send-news:
  when integer('1':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
  end.
  when integer('2':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end .
  otherwise do:
    p-color = ?.
    return ''.
  end.
end case.
end function.
procedure ord-savl_process-line :
define parameter buffer buf_ord-doc for ub.ord-doc.
define parameter buffer buf_ord-line for ub.ord-line.
define variable v-root-node like ub.gds-prt.node-code no-undo .
define variable l-goods-twounit as logical no-undo .
define variable rsrv-code       as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable return-AssMin   as logical   no-undo .
define variable return-igt      as character no-undo .
define variable gdop-min-stock  as decimal   no-undo .
define variable grop-max-stock  as decimal   no-undo .
define variable grop-level-always-presence  as decimal   no-undo .
define variable grop-min-order as decimal   no-undo .
define variable num_rec as integer no-undo .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable t-sum like ub.ord-line.qnty no-undo .
define variable v-str-ps as character no-undo .
define variable v-event-code as character no-undo .
define variable v-nabor       as logical   no-undo .
define variable is-edi-doc as logical no-undo .
define variable v-dm-edi  as integer no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_ord-dtl for ub.ord-dtl.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  num_rec   = num_rec + 1
  .
  if num_rec mod 10 = 0 then do:
    run display-line-process in this-procedure ( input num_rec , buffer buf_ord-line).
  end.
  find first buf_goods no-lock
    where buf_goods.artic     = buf_ord-line.artic
      and buf_goods.prod-type = buf_ord-line.prod-type
      and buf_goods.prod-code = buf_ord-line.prod-code
    no-error .
  if not available buf_goods then do:
    undo main-block, return error substitute("&1 &2 &3&4Не найден товар&4"  +
                                             "Заказ &5&4 Артикул &6 &7&8&4 gds-code &9&4"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,chr(10)
                                              ,buf_ord-line.doc-code
                                              ,buf_ord-line.artic
                                              ,buf_ord-line.prod-type
                                              ,buf_ord-line.prod-code
                                              ,buf_ord-line.gds-code ) +
                                  substitute("&1"
                                              ,(if g#db-num = 0
                                              then "Если товар был переименован, необходимо принять новости в УБД и переформировать пакеты"
                                              else "")).
   end.
  if buf_ord-doc.status_ = 'новый':U
  and buf_ord-doc.doc-type <> 'ПО':U
  and buf_ord-doc.doc-type <> 'ФП':U  then do:
     var-ok-assort-pol = true .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  buf_ord-doc.doc-type
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  if g#news then false else true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
    assign
    is-edi-doc = status-is-edi ( input yes
                        , input buf_ord-doc.cli-type
                        , input buf_ord-doc.cli-code
                        , input buf_ord-doc.obj-type
                        , input buf_ord-doc.obj-code
                        , output v-dm-edi
                        ) no-error.
    if var-ok-assort-pol = false and not g#news and not is-edi-doc then do:
      run ord-savl_del-str-info in this-procedure (  input buf_ord-doc.PS
                                                    , input var-mess-assort-pol
                                                    , output v-str-ps ) .
      buf_ord-doc.PS = v-str-ps .
      delete buf_ord-line .
      return .
    end.
    if buf_ord-doc.cli-type = 'маг':U or
      buf_ord-doc.cli-type = 'скл':U then do:
      var-ok-assort-pol = true .
      v-event-code = "cli_" + buf_ord-doc.doc-type .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.cli-type
  ,input  buf_ord-doc.cli-code
  ,input  if g#news then false else true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
       if var-ok-assort-pol = false and not g#news then do:
          run ord-savl_del-str-info in this-procedure ( input buf_ord-doc.PS
                                             , input var-mess-assort-pol
                                             , output v-str-ps ) .
          buf_ord-doc.PS = v-str-ps .
          delete buf_ord-line .
          return .
       end.
     end.
   end.
   if buf_ord-doc.status_ = 'новый':U
   and buf_ord-doc.doc-type = 'ПО':U  then do:
     var-ok-assort-pol = true .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassmat in g#library2
  (input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  if g#news then false else true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  )  .
     if var-ok-assort-pol = false and not g#news then do:
       run ord-savl_del-str-info in this-procedure ( input buf_ord-doc.PS
                                          , input var-mess-assort-pol
                                          , output v-str-ps ) .
        buf_ord-doc.PS = v-str-ps .
        delete buf_ord-line .
        return .
      end.
    end.
    run ord-savl_ver-gds-flor in this-procedure ( input buf_goods.gds-code
                                        , output v-nabor ) no-error .
    if v-nabor = true then do:
      undo main-block, return error substitute("&1 &2 &3&4"  +
                                              "Заказ &5&4 Артикул &6 &7&8&4 &9&4"  +
                                              "является набором (букет) !!!&4" +
                                              "Удалите его из списка товаров !"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,chr(10)
                                              ,buf_ord-line.doc-code
                                              ,buf_ord-line.artic
                                              ,buf_ord-line.prod-type
                                              ,buf_ord-line.prod-code
                                              ,buf_goods.gds-name ).
    end.
    if buf_goods.gds-type =  'у':U  then do:
      undo main-block, return error substitute("&1 &2 &3&4"  +
                                              "Заказ &5&4 Артикул &6 &7&8&4 &9&4"  +
                                              "является услугой !!!&4" +
                                              "Удалите его из списка товаров !"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,chr(10)
                                              ,buf_ord-line.doc-code
                                              ,buf_ord-line.artic
                                              ,buf_ord-line.prod-type
                                              ,buf_ord-line.prod-code
                                              ,buf_goods.gds-name ).
    end.
    assign
    buf_ord-line.obj-type = buf_ord-doc.obj-type
    buf_ord-line.obj-code = buf_ord-doc.obj-code
    buf_ord-line.status_  = buf_ord-doc.status_
    .
    if buf_ord-line.cli-base-rate = ?
    or buf_ord-line.cli-base-rate = 0 then do:
      assign
      buf_ord-line.cli-base-rate = buf_goods.cli-base-rate
     .
    end.
    if buf_ord-line.unit-cli = ?
    or buf_ord-line.unit-cli = "" then do:
      assign
      buf_ord-line.unit-cli = buf_goods.unit-cli
      .
    end.
  t-sum = 0.
  for each buf_ord-dtl no-lock where
      buf_ord-dtl.doc-code  = buf_ord-line.doc-code and
      buf_ord-dtl.artic     = buf_ord-line.artic and
      buf_ord-dtl.prod-type = buf_ord-line.prod-type and
      buf_ord-dtl.prod-code = buf_ord-line.prod-code  :
    t-sum = t-sum + buf_ord-dtl.qnty.
  end.
  if t-sum > buf_ord-line.qnty then do:
    undo main-block, return error substitute("&1 &2 &3&4Количество по признакам больше чем по строке товара&4" +
                                            "Заказ &5&4 Артикул &6 &7&8&4 &9&4"  +
                                            "является услугой !!!&4" +
                                            "Удалите его из списка товаров !"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,chr(10)
                                            ,buf_ord-line.doc-code
                                            ,buf_ord-line.artic
                                            ,buf_ord-line.prod-type
                                            ,buf_ord-line.prod-code
                                            ,buf_goods.gds-name ).
  end.
end.
end procedure .
procedure ord-savl_ver-gds-flor :
define input  parameter  p-gds-code as integer   no-undo .
define output parameter  p-nabor   as logical   no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  p-nabor = false .
  run ver-gds-grp-nabor in this-procedure ( input p-gds-code, output p-nabor) .
end.
end procedure.
procedure ord-savl_del-str-info :
define input   parameter p-str1    as character no-undo .
define input   parameter p-str-dop as character no-undo .
define output  parameter p-str2    as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  p-str1     = trim  (p-str1   ) .
  p-str-dop  = trim  (p-str-dop) .
  p-str1     = trim  (p-str1   ,chr(10) ) .
  p-str-dop  = trim  (p-str-dop,chr(10) ) .
  if length (p-str1) + length (p-str-dop )     >=  2000  then do:
    p-str2 = substitute ("&1 вся информация не умещается...." , p-str1 ) .
    return .
  end.
  p-str2  = substitute ("&1&3&2" , p-str1, p-str-dop ,chr(10) ) .
end.
end procedure.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
run get-report-num  in parParentProc ( output g#report-num ).
define variable k as int init 0 no-undo.
define variable ord-qnty    as decimal init 0 no-undo.
define variable ord-sum-cli as decimal init 0 no-undo.
define variable t-ret as logical no-undo .
define variable to-day as date no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output to-day
  )  .
define variable t-date  as date      no-undo .
define variable t-time  as integer   no-undo .
define variable t-log-3 as logical   no-undo .
run cur-time (output  t-date , output  t-time ).
t-ret =  session:set-wait-state("general") .
assign     k = 0
           ord-qnty    = 0
           ord-sum-cli = 0.
case t-action :
when "lkp" then do :
end.
when "chg" or when "add":u  or when "copy" then do :
   k = 0 .
   for each tmp#zakaz no-lock :
       assign k = k + 1 .
   end.
  for each shar_ord-dtl where shar_ord-dtl.doc-code = loc-ord-num exclusive-lock   :
      delete shar_ord-dtl .
  end.
  for each tmp#zakaz-dtl  :
      create shar_ord-dtl no-error.
      buffer-copy  tmp#zakaz-dtl to shar_ord-dtl
        assign
          shar_ord-dtl.doc-code  = loc-ord-num
          no-error .
  end.
  find first shar_ord-doc exclusive-lock where shar_ord-doc.doc-code = loc-ord-num   no-error  .
  if not available shar_ord-doc then do:
     create shar_ord-doc.
  end.
  assign
  shar_ord-doc.start-date   = date-1
  shar_ord-doc.end-date     = date-2
  shar_ord-doc.doc-code     = loc-ord-num
  shar_ord-doc.doc-date     = doc-date
  shar_ord-doc.cli-code     = loc-cli-code
  shar_ord-doc.cli-name     = loc-obj-name
  shar_ord-doc.cli-type     = loc-cli-type
  shar_ord-doc.agnt         = agnt
  shar_ord-doc.boss         = boss
  shar_ord-doc.status_      = loc-status
  shar_ord-doc.wrkr         = wrkr
  shar_ord-doc.host-code    = g#host-code
  shar_ord-doc.doc-type     = loc-doc-type
  shar_ord-doc.tot-lines    = k
  shar_ord-doc.fact-date    = ?
  shar_ord-doc.ship-date    = loc-date-ship
  shar_ord-doc.sum-service  = loc-service
  shar_ord-doc.deliv-type-code     = p-deliv-type-code
  shar_ord-doc.obj-point-code      = p-point-obj-code
  shar_ord-doc.cli-point-code      = p-point-cli-code
  shar_ord-doc.obj-point-db-num    = p-point-obj-db-num
  shar_ord-doc.cli-point-db-num    = p-point-cli-db-num
  shar_ord-doc.transport-host-code = p-transport-host-code
  shar_ord-doc.transport-cli-type  = p-transport-cli-type
  shar_ord-doc.transport-cli-code  = p-transport-cli-code
  shar_ord-doc.transport-contract  = p-transport-contract
  shar_ord-doc.transport-condition = p-transport-condition
  shar_ord-doc.transport-value     = p-transport-value
  shar_ord-doc.sum-ship            = p-transport-sum
  shar_ord-doc.transport-vat       = p-transport-vat
  shar_ord-doc.pay-code    =  paytype
  shar_ord-doc.order-type  =  tog-type
  shar_ord-doc.cycle-day   =  cycle-day
  shar_ord-doc.pay-day     =  pay-day
  shar_ord-doc.obj-type    =  loc-store-type
  shar_ord-doc.obj-code    =  loc-store-code
  shar_ord-doc.slt-type    =  slt_type
  shar_ord-doc.vat-type    =  vat_type
  shar_ord-doc.base-rate   =  loc-base-rate
  shar_ord-doc.base-scale  =  loc-base-scale
  shar_ord-doc.cli-qnty    =  loc-cli-qnty
  shar_ord-doc.exch-code   =  loc-exch-code
  shar_ord-doc.exch-date   =  t-date
  shar_ord-doc.exch-rate   =  loc-exch-rate
  shar_ord-doc.exch-scale  =  loc-exch-scale
  shar_ord-doc.out-code    =  loc-out-code
  shar_ord-doc.qnty        =  loc-qnty
  shar_ord-doc.sum-base    =  loc-sum-base
  shar_ord-doc.sum-cli     =  loc-sum-cli
  shar_ord-doc.sum-rubl    =  loc-sum-rubl
  shar_ord-doc.tot-lines   =  loc-tot-lines
  shar_ord-doc.e-method    =  e-method
  shar_ord-doc.date-sale-1  = date-sale-1
  shar_ord-doc.date-sale-2  = date-sale-2
  shar_ord-doc.cli-out-doc = loc-cli-out-doc + chr(4) +
                             (if t-action = "add"
                               or t-action = "copy"
                               or num-entries(shar_ord-doc.cli-out-doc, chr(4)) < 2
                               then string(iso-date(t-date))
                               else entry(2, shar_ord-doc.cli-out-doc, chr(4))
                               )   + chr(4) +
                             (if t-action = "add"
                               or t-action = "copy"
                               or num-entries(shar_ord-doc.cli-out-doc, chr(4)) < 3
                               then string(time, "HH:MM")
                               else entry(3, shar_ord-doc.cli-out-doc, chr(4))
                               )
        .
  find first ub.contract no-lock where
              ub.contract.contract-code = loc-contract  and
              ub.contract.host-code     = g#host-code
              no-error .
  if available ub.contract then
  do:
    shar_ord-doc.contract-code = ub.contract.contract-code .
  end.
  else do:
    shar_ord-doc.contract-code = 0.
  end.
  if shar_ord-doc.ship-date = ? then do:
    message
    "Не задана дата доставки!"
    view-as alert-box error .
    t-log-3 = true .
    undo, return error .
  end.
  assign
  shar_ord-doc.ship-time = ( loc-hour * 3600 ) + ( loc-min * 60 ) .
  if k = 0 then do:
    if shar_ord-doc.cli-code = 0 or shar_ord-doc.cli-code = ? then do:
      message "В заказе нет строк . Удаляем документ "
      view-as alert-box information .
      t-log-3 = true .
    end.
    else do:
      message "В заказе нет строк . Удаляем документ ? "
      view-as alert-box question
      buttons yes-no title "" update t-log-3 .
    end.
    if t-log-3 = true then do:
      delete shar_ord-doc.
      run proc-fin in this-procedure .
    end.
  end.
end.
end case.
define variable v-choice as integer   no-undo .
define variable g-log    as logical   no-undo .
if not available shar_ord-doc  or
   not can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  shar_ord-doc.doc-code ) or
       can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  shar_ord-doc.doc-code and ub.ord-line.qnty = 0 ) or
       can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  shar_ord-doc.doc-code and ub.ord-line.price-cli = 0 ) or
       can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  shar_ord-doc.doc-code and ub.ord-line.cli-art = "" )
   then do:
        run proc-fin in this-procedure .
   return .
end.
run waitfram-show in this-procedure ( input "Проверка строк ..." ).
for each ub.ord-line exclusive-lock
    where ub.ord-line.doc-code = shar_ord-doc.doc-code
on error undo , return error
on stop undo , return error
on end-key undo , return error
:
  run ord-savl_process-line in this-procedure ( buffer shar_ord-doc, buffer ub.ord-line) no-error .
  if error-status:error then do:
    run waitfram-hide in this-procedure .
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    return error.
  end.
  define buffer buf2_ord-line for ub.ord-line.
  if ( is-edi-doc     and shar_ord-doc.ord-int1 = integer('0':U)  ) and
 ( t-action = "chg" or t-action = "add") and
    shar_ord-doc.doc-type = 'ОП':U and
    shar_ord-doc.status_  = 'новый':U
  then do:
    find first buf2_ord-line no-lock where
              buf2_ord-line.doc-code = shar_ord-doc.doc-code
          and  buf2_ord-line.line-num = ub.ord-line.line-num
          and recid(buf2_ord-line) <> recid(ub.ord-line) no-error.
    if available buf2_ord-line then do:
      run waitfram-hide in this-procedure .
      run gbl/d-askw.w
        (input "Проверка заказа перед отсылкой по EDI"
        ,input "Обнаружены строки заказа с ОДИНАКОВЫМ ПОРЯДКОВЫМ НОМЕРОМ! Перенумеруйте строки заказа!!"
        ,input "|"
        ,input "Не отправлять"
        ,input "Заказ остается в текущем статусе. Его можно корректировать."
        ,input 1
        ,input 1
        ,output v-choice
        ).
      return error.
    end.
  end.
end.
run waitfram-hide in this-procedure .
if  t-action = "chg"  and
    shar_ord-doc.doc-type = 'ОП':U and
    shar_ord-doc.status_  = 'новый':U
   then do:
    define variable v-err as logical no-undo .
    run ver-clients-calc  (
          input shar_ord-doc.cli-type
        , input shar_ord-doc.cli-code
        , input shar_ord-doc.obj-type
        , input shar_ord-doc.obj-code
        , input shar_ord-doc.e-method
        , output v-err
                          ) .
    if v-err then return error 'Заказ не был рассчитан !!!'.
end.
if  ( is-edoc-nn-doc and shar_ord-doc.ord-int1 = integer('0':U) )
 or ( is-edi-doc     and shar_ord-doc.ord-int1 = integer('0':U)  ) and
 ( t-action = "chg" or t-action = "add") and
    shar_ord-doc.doc-type = 'ОП':U and
    shar_ord-doc.status_  = 'новый':U
  then do:
      if is-edoc-nn-doc then do :
      run gbl/d-askw.w
        (input "Решение по отправке заказа поставщику"
        ,input "Выберите один из пунктов "
        ,input "|"
        ,input "Отправить|Нет"
        ,input "Заказ отправляется ПОСТАВЩИКУ и ожидает подтверждения|"
             + "Заказ остается в текущем статусе. Его можно корректировать."
        ,input 1
        ,input 2
        ,output v-choice
        ).
      case v-choice :
        when 1 then do:
              assign
                shar_ord-doc.whole-send-news = integer('1':U)
              .
           run cus/edocsord.p (  input parParentProc
                               , input recid(shar_ord-doc)
                               , input 'ord-doc':U
                               , input yes
                               )  .
        end.
        when 2 then do:
        end.
      end case.
end.
      if is-edi-doc then do:
        define variable v-not-corr-op as character no-undo .
        define variable v-not-corr-op-type as character no-undo .
        run clntattr-value (
            input   shar_ord-doc.cli-type
          , input   shar_ord-doc.cli-code
          , input   'not-corr-op':U
          , output  v-not-corr-op
          , output  v-not-corr-op-type
          ) no-error .
       if logical(v-not-corr-op) = yes then do:
         v-choice = 2.
       end.
       else do:
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_send-bypass-EDI':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
        run gbl/d-askw.w
          (input "Выбор метода отправки заказа поставщику"
          ,input "Выберите один из пунктов "
          ,input "|"
          ,input "Вручную" + (if g-log then "" else "^disable") + "|EDI|Не отправлять"
          ,input "Заказ будет обработан вручную|"
               + "Заказ отправляется ПОСТАВЩИКУ по системе EDI и ожидает подтверждения|"
               + "Заказ остается в текущем статусе. Его можно корректировать."
          ,input 2
          ,input 1
          ,output v-choice
          ).
        end.
        case v-choice :
          when 1 then do:
              assign
                shar_ord-doc.whole-send-news = integer('0':U)
              .
          end.
          when 2 then do:
              assign
                shar_ord-doc.whole-send-news = integer('2':U)
              .
              if not can-find
                    ( first tmp#zakaz  no-lock    where
                      tmp#zakaz.qnty  <>  0 and
                      tmp#zakaz.qnty  <>  ?
                    )
              then do :
                message "В заказе все строки нерассчитанные. Нельзя отправлять через EDI." view-as alert-box.
                return no-apply.
              end.
              run cus/edocsord.p (  input parParentProc
                                  , input recid(shar_ord-doc)
                                  , input 'ord-doc':U
                                  , input yes
                                  )  .
          end.
          when 3 then do:
              assign
                shar_ord-doc.whole-send-news = integer('2':U)
              .
          end.
        end case.
    end.
end.
if t-action = "chg"   then do:
  if ( ( is-edoc-nn-doc and (shar_ord-doc.ord-int1 = int ('4':U)   or shar_ord-doc.ord-int1 = int ('3':U)))
  or ( is-edi-doc     and shar_ord-doc.ord-int1 = int ('3':U)))
  and shar_ord-doc.doc-type = 'ОП':U
  and shar_ord-doc.status_  = 'новый':U then do:
define variable v-buttons as character no-undo .
define variable v-descriptions as character no-undo .
    case shar_ord-doc.whole-send-news:
      when integer('1':U) then do:
          if can-find (first tmp#zakaz  where
                             tmp#zakaz.order-cli-qnty <> tmp#zakaz.cli-qnty or
                             tmp#zakaz.ord-dec1 <> tmp#zakaz.price-cli )
          then do:
            assign
            v-buttons =  "Подтверждаю^disable|На коррекцию|Отложить"
            v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                    + "Заказ возвращается в первоначальный статус. Его можно корректировать и снова отправить ПОСТАВЩИКУ на подтверждение.|"
                    + "Заказ остается в текущем статусе. Его можно корректировать."
            .
         end.
        else do:
          assign
          v-buttons =  "Подтверждаю|На коррекцию^disable|Отложить"
          v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                  + "Заказ возвращается в первоначальный статус. Его можно корректировать и снова отправить ПОСТАВЩИКУ на подтверждение.|"
                  + "Заказ остается в текущем статусе. Его можно корректировать."
          .
        end.
      end.
      when integer('2':U) then do:
          if p-dm-edi = integer('9':U) then do :
            if can-find (first tmp#zakaz  where
                                tmp#zakaz.ord-dec2 <> tmp#zakaz.cli-qnty )
            then do:
              assign
              v-buttons =  "Подтверждаю^disable|C коррекцией|Отложить"
              v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                      + "Заказ отправляется с отметкой об изменениях ПОСТАВЩИКУ на подтверждение.|"
                      + "Заказ остается в текущем статусе. Его можно корректировать."
              .
            end.
            else do:
              assign
              v-buttons =  "Подтверждаю|На коррекцию^disable|Отложить"
              v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                      + "Заказ отправляется с отметкой об изменениях ПОСТАВЩИКУ на подтверждение.|"
                      + "Заказ остается в текущем статусе. Его можно корректировать."
              .
            end.
          end.
          else do :
            if can-find (first tmp#zakaz  where
                                tmp#zakaz.ord-dec2 <> tmp#zakaz.cli-qnty or
                                tmp#zakaz.ord-dec3 <> tmp#zakaz.price-cli )
            then do:
              assign
              v-buttons =  "Подтверждаю^disable|C коррекцией|Отложить"
              v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                      + "Заказ отправляется с отметкой об изменениях ПОСТАВЩИКУ на подтверждение.|"
                      + "Заказ остается в текущем статусе. Его можно корректировать."
              .
            end.
            else do:
              assign
              v-buttons =  "Подтверждаю|На коррекцию^disable|Отложить"
              v-descriptions =  "Заказ отправляется ПОСТАВЩИКУ и переходит в статус ПОСТАВКА|"
                      + "Заказ отправляется с отметкой об изменениях ПОСТАВЩИКУ на подтверждение.|"
                      + "Заказ остается в текущем статусе. Его можно корректировать."
              .
            end.
          end.
      end.
      otherwise do:
      end.
    end case.
    run gbl/d-askw.w
                (input "Решение по ответу поставщика"
      ,input "Выберите один из пунктов для решения," + chr(10)
           + "что делать с заказом" + chr(10)
                ,input "|"
      ,input v-buttons
      ,input v-descriptions
                ,input 1
                ,input 3
                ,output v-choice
                ).
      case v-choice :
      when 1 then do:
        if is-edi-doc then do :
          if p-dm-edi = integer('9':U) then do :
            define variable p-cmd-code as integer no-undo init 0 .
            define variable v-last-error-message as character no-undo .
            define variable v-current-doc-code as character no-undo .
            define variable v-current-obj-type as character no-undo .
            define variable v-current-obj-code as integer no-undo .
            define variable p-parent-handle as handle no-undo.
            define variable p-log-handle as handle no-undo.
            define variable v-cli-out-doc as character no-undo .
            define variable v-desadv-DELIVERYNOTENUMBER as character no-undo.
            define variable v-desadv-DELIVERYNOTEDATE as date no-undo.
            define buffer temp-edi-status for ub.edi-status .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  variable garbcoll_ii as integer no-undo .
define  temp-table temp-gc no-undo
field ii as integer
field obj-r as handle
field cn as character
index pi is unique primary
ii
index icn
cn.
procedure garbcoll_create-gc-entry :
define input parameter p-cn as character no-undo .
define input parameter p-obj-r as handle no-undo .
  do
  on error undo, return error
  :
    create temp-gc.
    assign
    temp-gc.ii = garbcoll_ii
    garbcoll_ii = garbcoll_ii + 1
    temp-gc.cn = p-cn
    temp-gc.obj-r = p-obj-r
    .
  end.
end procedure.
procedure garbcoll_clear :
  do
  on error undo, return error
  :
    for each temp-gc:
      delete object temp-gc.obj-r.
      delete temp-gc.
    end.
  end.
end procedure.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define  temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.
define  temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
def var vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-gate-file-name :
define input parameter p-gate-rec as character no-undo .
define output  parameter p-gate-file-name as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
run gen-row-keyr in this-procedure ( input p-gate-rec
                                    ,input ?
                                    ,input "ub"
                                    ,input ?
                                    ,input no-lock
                                    ,output v-tbl-row
                                    ,output v-tbl-name) no-error.
if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                        ,vss-include-info27
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info27
                                                          ,p-gate-rec).
end.
p-gate-file-name = buf_clob-data.file-name.
end procedure.
procedure get-gate-rec :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info27, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info27 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info27 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
end.
end procedure.
procedure get-gate-by-name :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info27, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info27 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info27 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 из БД:&2&3", p-gate-name, chr(10), error-status:get-message(1) ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
      end.
    end.
end.
end procedure.
procedure get-gate-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define input-output parameter p-longchar  as longchar no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info27, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info27 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info27 )
:
  run gen-row-keyr in this-procedure (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1) .
    if p-longchar <> ? then do:
      p-longchar = v-longchar.
    end.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                   , p-gate-rec
                                   , p-gate-rec
                                   , v-esm
                                   ).
    end.
    p-dsh:private-data = buf_clob-data.file-name_ + chr(4) + p-gate-rec.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure get-gate-by-file :
define input  parameter p-schema-file-name as character no-undo .
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info27, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info27 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info27 )
:
    COPY-LOB
    FROM  FILE p-schema-file-name
    TO  OBJECT v-longchar
    no-convert
    NO-ERROR .
    if error-status :error then do:
        undo, return error substitute("Не удалось считать файл схемы &1 в память&2&3"
                                  , p-schema-file-name
                              , chr(10)
                              , error-status:get-message(1) ).
    end.
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, p-schema-file-name, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "longchar"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = ''.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему из файла &1&2&3"
                                   , p-schema-file-name
                                   ,chr(10)
                                   , error-status:get-message(1)
                                   ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1" and  uniq-gate-rec = "&2" '
                                   ,p-dsh:get-buffer-handle(v-ii):name
                                   ,p-gate-rec
                                   )) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):table
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure gate-clear :
define input  parameter p-dsh as handle no-undo .
define input  parameter p-xmlh as handle no-undo .
define variable v-dsh as handle no-undo .
define variable v-th as handle no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-dsh) then do:
      delete object p-dsh.
      v-dsh = p-dsh.
      p-dsh = ?.
    end.
    repeat while true:
      p-xmlh:find-first( substitute( " where gate-handle_ = &1 ", v-dsh)
                         , share-lock) no-error.
      if p-xmlh:available then do:
        assign
        v-th = p-xmlh:buffer-field("table-handle_"):buffer-value.
        if valid-handle(p-xmlh:buffer-field("table-handle_"))
        and valid-handle(v-th)
        and v-th:dynamic = yes
        then do:
          delete object p-xmlh:buffer-field("table-handle_"):buffer-value.
          p-xmlh:buffer-field("table-handle_"):buffer-value = ?.
        end.
        p-xmlh:buffer-delete().
      end.
      else do:
        leave.
      end.
    end.
    if p-xmlh:dynamic = yes
    and valid-handle(p-xmlh)
    then do:
      delete object p-xmlh:table-handle.
      p-xmlh = ?.
    end.
    v-dsh = ?.
  end.
end procedure.
procedure all-gates-clear :
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      if first-of(buf_temp-xml-tables.uniq-gate-rec) then do:
        delete object buf_temp-xml-tables.gate-handle_.
        buf_temp-xml-tables.gate-handle_ = ?.
      end.
      if valid-handle(buf_temp-xml-tables.table-handle_)
      and buf_temp-xml-tables.table-handle_:dynamic = no
      then do:
        delete object buf_temp-xml-tables.table-handle_.
        buf_temp-xml-tables.table-handle_ = ?.
      end.
      delete buf_temp-xml-tables.
  end.
end.
end procedure.
procedure fix-schemalocation :
define input-output  parameter p-longchar as longchar no-undo .
DEFINE VARIABLE hdoc AS HANDLE.
DEFINE VARIABLE hroot AS HANDLE.
DEFINE VARIABLE hnode-child AS HANDLE.
DEFINE VARIABLE hnode-attr AS HANDLE.
define variable v-jj as integer   no-undo .
define variable ok as logical   no-undo .
define variable v-path1                    as character                no-undo .
DEFINE VARIABLE v-full-path1               as character                no-undo .
DEFINE VARIABLE v-file-name1               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext1        as character                no-undo .
DEFINE VARIABLE v-file-name-ext1           as character                no-undo .
define variable v-schema-location          as character                no-undo .
do
on error undo, return error return-value
:
  CREATE X-DOCUMENT hdoc.
  CREATE X-noderef hroot.
  CREATE X-noderef hnode-child.
  CREATE X-noderef hnode-attr.
  hdoc:load("longchar", p-longchar, no) no-error.
  iF ERROR-STATUS:GET-MESSAGE(1) <> '' THEN message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box .
  hdoc:get-document-element(hroot).
  _repeat:
  REPEAT v-jj = 1 TO hroot:NUM-CHILDREN:
    ok = hroot:GET-CHILD(hNode-Child, v-jj).
    if not ok then next.
    if hNode-Child:local-name = "include"
    then do:
      ok = hNode-Child:GET-ATTRIBUTE-NODE( hnode-attr, "schemaLocation" ).
        v-schema-location = hnode-attr:node-value.
        run gbl/filename.p (
                        input "exe/" + hnode-attr:node-value
                      ,output v-full-path1
                      ,output v-path1
                      ,output v-file-name1
                      ,output v-file-name-no-ext1
                      ,output v-file-name-ext1
                      ) no-error .
        if error-status :error then do:
          delete object hnode-attr.
          delete object hnode-child.
          delete object hroot.
          delete object hdoc.
          undo, return error substitute("Не удалось определить расположение схемы &1", v-schema-location).
        end.
      ok = hNode-Child:sET-ATTRIBUTE(  "schemaLocation", v-full-path1 ).
      leave  _repeat.
    end.
  END.
  hdoc:save("longchar", p-longchar).
  delete object hnode-attr.
  delete object hnode-child.
  delete object hroot.
  delete object hdoc.
end.
end procedure.
procedure gate-clb_fill-xml-tables :
define input parameter p-dsh as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error
  :
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = entry(2, p-dsh:private-data, chr(4))
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
  end.
end procedure.
procedure all-gates-empty :
define buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-xml-tables.tbl-handle_) then do:
      buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end.
end.
end procedure.
def var vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ext-system-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-code in g#attr-lib
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
procedure ext-system-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-tooltip in g#attr-lib
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
procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
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
procedure ext-system-attr-write :
  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (input p-esys-id
      ,input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-exist in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-delete :
  define input  parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-delete in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ordlineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.ord-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if avail buf_ord-line-attr then do:
      assign
        p-value =  buf_ord-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure ordlineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.ord-line-attr.attr-value no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      undo, return error return-value .
    end.
    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if not available buf_ord-line-attr then do:
      create buf_ord-line-attr .
      assign
        buf_ord-line-attr.doc-code   = p-doc-code
        buf_ord-line-attr.gds-code   = p-gds-code
        buf_ord-line-attr.attr-code  = p-code
      .
    end.
    assign
      buf_ord-line-attr.attr-value = p-value
    .
end.
end procedure.
procedure ordlineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if  available buf_ord-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure ordlineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    define variable v-other          as character no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ord-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ord-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure ordlineattr-code :
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
    define output parameter p-proc           as character no-undo .
    define output parameter p-func           as character no-undo .
    define output parameter p-sort           as integer   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'cycle-cli-qnty':U then do:     assign     p-label          = "Количество"     p-type           = 'D':U      p-format         = ">>>>>>>>>>>>>>>9.999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Количество"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'ord-EAN13':U then do:     assign     p-label          = "EAN в EDI"     p-type           = 'C':U      p-format         = "X(13)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "EAN в EDI"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки заказа" + " " + p-code .
      end.
    end.
  end.
end procedure.
FUNCTION cr-edist_get-mess-mean returns character ( input p-mess as character):
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-mess as character no-undo .
do v-ii = 1 to num-entries(p-mess, chr(4) ):
  v-dop = entry(v-ii, p-mess, chr(4) ).
  case entry(1, v-dop, "="):
    when 'pack-num':U then do:
      v-dop1 =  substitute("&1 &2", 'Пакет', entry(2, v-dop, "=")).
    end.
    when 'route':U then do:
      v-dop1 =  substitute("&1 &2", 'Рут':U, entry(2, v-dop, "=")).
    end.
    when 'ediiterchangeid':U then do:
      v-dop1 =  substitute("&1 &2", 'ediiterchangeid':U, entry(2, v-dop, "=")).
    end.
    when 'price-up':U then do:
      v-dop1 =  substitute("&1 &2", 'Цена':U, entry(2, v-dop, "=")).
    end.
    when 'price-down':U then do:
      v-dop1 =  substitute("&1 &2", 'Цена':U, entry(2, v-dop, "=")).
    end.
    when 'vat-change':U then do:
      v-dop1 =  substitute("&1 &2", 'НДС':U, entry(2, v-dop, "=")).
    end.
    when 'ps':U then do:
      v-dop1 =  substitute("&1 &2", ' ':U, entry(2, v-dop, "=")).
    end.
    when 'info':U then do:
      v-dop1 =  substitute("&1 &2", 'Инф:':U, entry(2, v-dop, "=")).
    end.
    when 'qnty-up':U then do:
      v-dop1 =  substitute("&1 &2", 'Кол-во':U, entry(2, v-dop, "=")).
    end.
    when 'qnty-down':U then do:
      v-dop1 =  substitute("&1 &2", 'Кол-во':U, entry(2, v-dop, "=")).
    end.
    when 'bstr-change':U then do:
      v-dop1 =  substitute("&1 &2", 'Штрихкод:':U, entry(2, v-dop, "=")).
    end.
    when 'shipdate-change':U then do:
      v-dop1 =  substitute("&1 &2", 'Дата отгрузки:':U, entry(2, v-dop, "=")).
    end.
    when 'clioutdoc-change':U then do:
      v-dop1 =  substitute("&1 &2", '№ заказа по пост-ку:':U, entry(2, v-dop, "=")).
    end.
  end case.
  v-mess  = v-mess + (if v-mess = '' then '' else chr(32)) + v-dop1.
end.
return v-mess.
end function.
FUNCTION cr-edist_get-error-mean returns character ( input p-mess as character):
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-mess as character no-undo .
do v-ii = 1 to num-entries(p-mess, chr(4) ):
  v-dop = entry(v-ii, p-mess, chr(4) ).
  case entry(1, v-dop, "="):
    when 'pack-num':U then do:
      v-dop1 =  substitute("&1 &2", 'Пакет', entry(2, v-dop, "=")).
    end.
    when 'route':U then do:
      v-dop1 =  substitute("&1 &2", 'Рут':U, entry(2, v-dop, "=")).
    end.
    when 'ediiterchangeid':U then do:
      v-dop1 =  substitute("&1 &2", 'ediiterchangeid':U, entry(2, v-dop, "=")).
    end.
    when 'price-up':U then do:
      v-dop1 =  substitute("&1 &2", 'Цена':U, entry(2, v-dop, "=")).
    end.
    when 'price-down':U then do:
      v-dop1 =  substitute("&1 &2", 'Цена':U, entry(2, v-dop, "=")).
    end.
    when 'vat-change':U then do:
      v-dop1 =  substitute("&1 &2", 'НДС':U, entry(2, v-dop, "=")).
    end.
    when 'ps':U then do:
      v-dop1 =  substitute("&1 &2", ' ':U, entry(2, v-dop, "=")).
    end.
    when 'info':U then do:
      v-dop1 =  substitute("&1 &2", 'Инф:':U, entry(2, v-dop, "=")).
    end.
    when 'qnty-up':U then do:
      v-dop1 =  substitute("&1 &2", 'Кол-во':U, entry(2, v-dop, "=")).
    end.
    when 'qnty-down':U then do:
      v-dop1 =  substitute("&1 &2", 'Кол-во':U, entry(2, v-dop, "=")).
    end.
    when 'bstr-change':U then do:
      v-dop1 =  substitute("&1 &2", 'Штрихкод:':U, entry(2, v-dop, "=")).
    end.
    when 'shipdate-change':U then do:
      v-dop1 =  substitute("&1 &2", 'Дата отгрузки:':U, entry(2, v-dop, "=")).
    end.
    when 'clioutdoc-change':U then do:
      v-dop1 =  substitute("&1 &2", '№ заказа по пост-ку:':U, entry(2, v-dop, "=")).
    end.
  end case.
  v-mess  = v-mess + (if v-mess = '' then '' else chr(4)) + v-dop1.
end.
return v-mess.
end function.
FUNCTION cr-edist_get-mess-key-value returns character ( input p-mess as character, input p-key as character):
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-value as character no-undo .
do v-ii = 1 to num-entries(p-mess, chr(4) ):
  v-dop = entry(v-ii, p-mess, chr(4) ).
  if entry(1, v-dop, "=") = p-key then do:
    return entry(2, v-dop, "=").
  end.
end.
return v-value.
end function.
FUNCTION cr-edist_add-edist-mess returns character ( input p-mess as character
                                                     ,input p-key as character
                                                     ,input p-value as character):
define variable v-dop as character no-undo .
define variable v-modificator as character no-undo .
assign
v-modificator = entry(2, p-key, "-") no-error .
case v-modificator:
  when "up" then do:
    v-dop = substitute("&1=&2<&3", p-key, entry(1, p-value, chr(4)) , entry(2, p-value, chr(4))).
  end.
  when "down" then do:
    v-dop = substitute("&1=&2>&3", p-key, entry(1, p-value, chr(4)) , entry(2, p-value, chr(4))).
  end.
  when "change" then do:
    v-dop = substitute("&1=&2 ->&3", p-key, entry(1, p-value, chr(4)) , entry(2, p-value, chr(4))).
  end.
  otherwise do:
    v-dop = substitute("&1=&2", p-key, p-value).
  end.
end case.
if p-mess = ''
or p-mess = ? then do:
  return v-dop .
end.
else do:
  return substitute("&1&2&3", p-mess, chr(4), v-dop).
end.
end function.
procedure create-edi-state :
define input  parameter p-tbl-name   as character no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-cli-type   as character no-undo .
define input  parameter p-cli-code   as integer   no-undo .
define input  parameter p-act        as character no-undo .
define input  parameter p-state      as character no-undo .
define input  parameter p-err        as integer   no-undo .
define input  parameter p-des        as character no-undo .
define input  parameter p-mess       as character no-undo .
define input  parameter p-dm         as integer  no-undo .
define input-output parameter p-date       as date no-undo .
define input-output parameter p-time       as integer no-undo .
define buffer buf_EDI-status for ub.EDI-status  .
define variable v-time as integer   no-undo .
define variable v-date as date   no-undo .
do
on error undo, return error return-value
:
  if p-date = ? then do:
    run cur-time in this-procedure ( output v-date, output v-time).
  end.
  else do:
    assign
    v-date = p-date
    v-time = p-time
    .
  end.
  find first buf_edi-status exclusive-lock where
              buf_edi-status.date-status = v-date
          and buf_edi-status.time-status = v-time
          and buf_edi-status.tbl-name    = p-tbl-name
          and buf_edi-status.doc-code    = p-doc-code no-error .
  if not available buf_edi-status  then do:
    create buf_edi-status.
  end.
  assign
  buf_edi-status.act         = p-act        .
  buf_edi-status.cli-type    = p-cli-type   .
  buf_edi-status.cli-code    = p-cli-code   .
  buf_edi-status.des-err     = buf_edi-status.des-err + (if buf_edi-status.des-err = '' then '' else chr(4)) + p-des        .
  buf_edi-status.doc-code    = p-doc-code   .
  buf_edi-status.err-code    = p-err        .
  buf_edi-status.mess-id     = buf_edi-status.mess-id + (if buf_edi-status.mess-id = '' then '' else chr(4)) + p-mess       .
  buf_edi-status.state       = p-state      .
  buf_edi-status.tbl-name    = p-tbl-name   .
  buf_edi-status.date-status = v-date       .
  buf_edi-status.time-status = v-time       .
  buf_edi-status.whole-send-news = p-dm     .
  buf_edi-status.user-name   = (if g#news then (chr(4) +  'СПН':U)
                                    else (if g#esys
                                          then (chr(4) +  'ВС':U)
                                          else g#userid)
                                    )       .
  assign
  p-date = buf_edi-status.date-status
  p-time = buf_edi-status.time-status
  .
end.
end procedure.
procedure update-edi-state-light :
define input  parameter p-tbl-name   as character no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-date-status as date no-undo .
define input  parameter p-time-status as integer no-undo .
define input  parameter p-state      as character no-undo .
define input  parameter p-err        as integer   no-undo .
define input  parameter p-des        as character no-undo .
define input  parameter p-mess       as character no-undo .
define buffer buf_edi-status for ub.edi-status.
do
on error undo, return error
:
  find first buf_edi-status exclusive-lock where
              buf_edi-status.date-status = p-date-status
          and buf_edi-status.time-status = p-time-status
          and buf_edi-status.tbl-name    = p-tbl-name
          and buf_edi-status.doc-code    = p-doc-code no-error .
  if available buf_edi-status  then do:
    assign
    buf_edi-status.des-err     = p-des        .
    buf_edi-status.err-code    = p-err        .
    buf_edi-status.mess-id     = p-mess       .
    buf_edi-status.state       = p-state      .
  end.
end.
end procedure.
            assign
                shar_ord-doc.ord-int1 = integer('6':U)
            .
            assign
                v-current-doc-code = shar_ord-doc.doc-code
                v-current-obj-type = shar_ord-doc.obj-type
                v-current-obj-code = shar_ord-doc.obj-code
                p-parent-handle = this-procedure:handle
            .
define variable ExpData1 as class Route-data_ no-undo .
ExpData1 = new Route-data_( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle) .
define variable v-DATA as memptr no-undo.
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
function context_begin-esys-command return logical
(
    input p-esys-id-list as character
   ,input-output p-esys-cmd-proc-handle as handle
   ,output p-esys-cmd-code as integer
):
   if not valid-handle(p-esys-cmd-proc-handle )
   then do:
     run nws/cmd-bush.p persistent set p-esys-cmd-proc-handle no-error .
     if error-status :error
     then do:
        delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                           "&5&4&6"
                                           ,vss-workfile
                                           ,vss-revision
                                           ,vss-description
                                           ,chr(10)
                                           ,error-status:get-message(1)
                                           ,return-value )).
     end.
     run begin-create-command in p-esys-cmd-proc-handle
       (input 'cmd-esys-general':U
       ,input p-esys-id-list
       ,output p-esys-cmd-code
       ) no-error.
     if error-status :error
     then do:
       delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при создании команды &1&2&3&1&4"
                                                        , 'cmd-esys-general':U
                                                        , error-status:get-message(1)
                                                        , return-value
                                                        )).
       return no .
     end.
     return yes.
   end.
end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function context_send-esys-command return int64
(
    input p-esys-id-list as character
   ,input p-esys-cmd-proc-handle as handle
   ,input p-esys-cmd-code as integer
   ,input p-user-id as character
):
   define variable v-dmp-ord-int64 as int64 no-undo .
   if valid-handle(p-esys-cmd-proc-handle )
   then do:
      run send-command-esys in p-esys-cmd-proc-handle
          (input p-esys-cmd-code
          ,input p-esys-id-list
          ,input p-user-id
          ,output v-dmp-ord-int64
          ) no-error.
      if error-status :error
      then do:
         delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при отсылке во внешнюю систему &1 команды с кодом &2&3&4&3&5"
                                                        , p-esys-id-list
                                                        , p-cmd-code
                                                        , chr(10)
                                                        , error-status:get-message(1)
                                                        , return-value
                                                        )).
         return 0.
      end.
      delete procedure p-esys-cmd-proc-handle no-error.
      return v-dmp-ord-int64.
   end.
   else do:
      delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при отсылке во внешнюю систему &1 команды с кодом &2&3&4&3&5"
                                                    , p-esys-id-list
                                                    , p-cmd-code
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value
                                                    )).
      return 0 .
   end.
end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function context_set-custom-esys-pck-name return logical
(
    input p-esys-cmd-proc-handle as handle
   ,input p-esys-cmd-code as integer
   ,input p-custom-pck-name as character
):
   if valid-handle(p-esys-cmd-proc-handle )
   then do:
      run set-custom-esys-pck-name in p-esys-cmd-proc-handle (
                                                              input p-esys-cmd-code
                                                             ,input p-custom-pck-name) no-error .
      if error-status :error
      then do:
         delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при установке спец имени пакета для отсылки во внешнюю систему команды с кодом &1&2&3&2&4"
                                                     , p-cmd-code
                                                     , chr(10)
                                                     , error-status:get-message(1)
                                                     , return-value
                                                     )).
         return no .
      end.
      return yes.
   end.
   else do:
      delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при установке спец имени пакета для отсылки во внешнюю систему команды с кодом &1&2&3&2&4"
                                                    , p-cmd-code
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value
                                                    )).
      return no .
   end.
end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function context_delete-command return logical
(
    input p-esys-cmd-proc-handle as handle
   ,input p-esys-cmd-code as integer
):
   if valid-handle(p-esys-cmd-proc-handle )
   then do:
      run delete-command in p-esys-cmd-proc-handle
          (input p-esys-cmd-code
          ) no-error.
      if error-status :error
      then do:
         delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при удалении команды с кодом &1&2&3&2&4"
                                                           , p-cmd-code
                                                           , chr(10)
                                                           , error-status:get-message(1)
                                                           , return-value
                                                           )).
         return no .
      end.
      delete procedure p-esys-cmd-proc-handle no-error.
      return yes.
   end.
   else do:
      delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при удалении команды с кодом &1&2&3&2&4"
                                                    , p-cmd-code
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value
                                                    )).
      return no .
   end.
end.
procedure send-stat_contour :
  define input parameter p-doc-type as character no-undo .
  define input parameter p-state as character no-undo .
  define input parameter p-stage as character no-undo .
  define input parameter p-description as character no-undo .
  define input parameter p-messID as character no-undo .
  define variable v-ii as integer no-undo .
  define variable v-uniq-key-rec as character no-undo .
  define variable v-cli-uniq-key-rec as character no-undo .
  define variable v-err as logical no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-success as logical   no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-ord-int1 as integer no-undo .
  define variable v-obj-gln as character no-undo .
  define variable v-cli-gln as character no-undo .
  define variable v-gln-net as character no-undo .
  define variable v-type as character no-undo .
  define variable v-mess as character no-undo .
  define variable v-b-code as integer no-undo .
  define variable v-b-str as character no-undo .
  define variable v-jj as integer   no-undo .
  define variable v-cli-base-rate as decimal no-undo .
  define variable v-dump-ord-int64 as int64 no-undo .
  define variable v-rcv-code as character no-undo .
  define variable v-cli-rcv-code as character no-undo .
  define variable v-EDIINTERCHANGEID as character no-undo .
  define variable v-edist-mess as character no-undo .
  define variable v-date-status as character no-undo .
  define variable v-time-status as integer no-undo .
  define variable v-error as character no-undo .
  define variable v-stringdate as character no-undo .
  define variable v-documentNumber as character no-undo .
  define variable v-documentDate as character no-undo .
  define variable sw as handle no-undo .
  define buffer buf_ext-system for ub.ext-system.
  define buffer buf_ord-doc for ub.ord-doc.
  define buffer buf_ord-line for ub.ord-line.
  define buffer buf_object for ub.clients.
  define buffer buf_clients for ub.clients.
  define buffer buf_ext-classif for ub.ext-classif.
  define buffer esys_ext-classif for ub.ext-classif.
  define buffer buf_goods for ub.goods.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_currency for ub.currency.
  define buffer buf_ord-line-attr for ub.ord-line-attr.
  define buffer buf_edi-status for ub.edi-status.
_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), v-last-error-message)
on stop undo, return error substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), v-last-error-message)
:
  if retry then do:
        .
    undo _main, return error.
  end.
  else do:
    assign
    v-mess = ''
    .
    find first buf_ord-doc exclusive-lock where
              buf_ord-doc.doc-code = v-current-doc-code no-error .
    if not available buf_ord-doc then do:
      v-mess = substitute("Не найден заказ для поставки").
      v-err = yes.
      undo _main, retry _main.
    end.
    if p-doc-type = "DESADV" then do :
        find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.doc-code = v-current-doc-code no-error .
        if available buf_ord-doc-rcv then assign v-rcv-code = buf_ord-doc-rcv.rcv-code .
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_ord-doc.cli-type
          and buf_clients.obj-code = buf_ord-doc.cli-code no-error.
    if not available buf_clients then do:
      v-mess =  substitute("Не найден контрагент &1&2", buf_ord-doc.cli-type, buf_ord-doc.cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    run gen-key-rec in this-procedure ( input 'clients':U
                                      ,input (buffer buf_clients:handle)
                                      ,output v-cli-uniq-key-rec) no-error .
    if error-status:error then do:
      v-mess = substitute("gen-key-rec: &1&2&3&2(&4&5)"
                                , error-status:get-message(1)
                                , return-value
                                , chr(10)
                                , buf_ord-doc.cli-type
                                , buf_ord-doc.cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    find first esys_ext-classif no-lock where
        esys_ext-classif.classif-name = 'exite-edi':U
    and esys_ext-classif.classif-subject = 'clients':U
    and esys_ext-classif.db-num = -1
    and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec no-error .
    if not available esys_ext-classif then do:
      v-mess = substitute("Поставщик &1&2 заказа НЕ РАБОТАЕТ ПО СИСТЕМЕ EDI", buf_ord-doc.cli-type, buf_ord-doc.cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    find first buf_object no-lock where
              buf_object.obj-type = v-current-obj-type
          and buf_object.obj-code = v-current-obj-code no-error.
    if not available buf_object then do:
      v-mess =  substitute("Не найден объект &1&2", v-current-obj-type, v-current-obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    run gen-key-rec in this-procedure ( input 'clients':U
                                      ,input (buffer buf_object:handle)
                                      ,output v-uniq-key-rec) no-error .
    if error-status:error then do:
      v-mess =  substitute("gen-key-rec: &1&2&3&2(&4&5)"
                                , error-status:get-message(1)
                                , return-value
                                , chr(10)
                                , buf_object.obj-type
                                , buf_object.obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    assign
    v-obj-gln = get-gln( input buf_object.obj-type
                    ,input buf_object.obj-code) no-error.
    if error-status:error
    or v-obj-gln = chr(63)
    or v-obj-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , buf_object.obj-type
                                , buf_object.obj-code) .
      v-err = yes.
      undo _main, retry _main.
    end.
    v-cli-gln = get-gln( input buf_ord-doc.cli-type
                        ,input buf_ord-doc.cli-code) no-error.
    if error-status:error
    or v-cli-gln = chr(63)
    or v-cli-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , buf_object.obj-type
                                , buf_object.obj-code) .
      v-err = yes.
      undo _main, retry _main.
    end.
    for each esys_ext-classif no-lock where
        esys_ext-classif.classif-name = 'exite-edi':U
    and esys_ext-classif.classif-subject = 'clients':U
    and esys_ext-classif.db-num = -1
    and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec,
      first buf_ext-system no-lock where
                buf_ext-system.esys-id = esys_ext-classif.key#_one
            and buf_ext-system.db-num = 0
            and buf_ext-system.esys-have-export = yes,
      first buf_ext-classif no-lock where
        buf_ext-classif.classif-name = 'exite-edi':U
    and buf_ext-classif.classif-subject = 'clients':U
    and buf_ext-classif.db-num = -1
    and buf_Ext-classif.uniq-key-rec = v-uniq-key-rec
    and buf_Ext-classif.key#_one = esys_ext-classif.key#_one:
      leave.
    end.
    if not available buf_ext-system then do:
      v-mess = substitute("Для поставщика &1&2 не найдена ВС, у которой есть экспорт в текущей БД").
      v-err = yes.
      undo _main, retry _main.
    end.
    run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                 ,input buf_ext-system.db-num
                                                 ,input 'gln-net':U
                                                 ,output v-gln-net
                                                 ,output v-type) no-error.
    IF  context_begin-esys-command( input string(buf_ext-system.esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-stringdate = substring(string(NOW), 7, 4) + substring(string(NOW), 4, 2) + substring(string(NOW), 1, 2)
                 + substring(string(NOW), 12, 2) + substring(string(NOW), 15, 2) + substring(string(NOW), 18, 2).
    v-custom-pack-name = p-state + "_" + v-stringdate + "_" + p-doc-type + "_" + buf_ord-doc.doc-code + "_&pack-num.xml".
    if p-doc-type = "ORDRSP" then do :
        if p-stage = "Read" then
        assign
            v-documentNumber = entry(1, v-cli-out-doc, chr(4))
            v-documentDate = entry(2, v-cli-out-doc, chr(4))
        .
        else
        assign
            v-documentNumber = entry(1, buf_ord-doc.cli-out-doc, chr(4))
            v-documentDate = entry(2, buf_ord-doc.cli-out-doc, chr(4))
        .
        for each buf_edi-status no-lock where
                buf_edi-status.tbl-name = 'ord-doc':U
           and buf_edi-status.doc-code = v-current-doc-code
           and (buf_edi-status.state = '1':U or buf_edi-status.state = '12':U or buf_edi-status.state = '6':U or buf_edi-status.state = '3':U)
           and buf_edi-status.err-code < 3 :
          assign
            v-EDIINTERCHANGEID = cr-edist_get-mess-key-value(buf_edi-status.mess, 'ediiterchangeid':U)
          .
          if v-EDIINTERCHANGEID <> ? and trim(v-EDIINTERCHANGEID) <> "" then leave .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-doc':U
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-line':U
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
    end.
    if p-doc-type = "DESADV" then do :
        assign
            v-documentNumber = v-desadv-DELIVERYNOTENUMBER
            v-documentDate = iso-date(v-desadv-DELIVERYNOTEDATE)
        .
        for each buf_edi-status no-lock where
                buf_edi-status.tbl-name = 'ord-doc-rcv':U
           and buf_edi-status.doc-code = v-rcv-code
           and buf_edi-status.state = '8':U
           and buf_edi-status.err-code < 3 :
          assign
          v-EDIINTERCHANGEID = cr-edist_get-mess-key-value(buf_edi-status.mess, 'ediiterchangeid':U).
          if v-EDIINTERCHANGEID <> ? and trim(v-EDIINTERCHANGEID) <> "" then leave .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-doc':U
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-line':U
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-doc-rcv':U
           and temp-edi-status.doc-code begins v-rcv-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-line-rcv':U
           and temp-edi-status.doc-code begins v-rcv-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
    end.
    if v-EDIINTERCHANGEID <> ? and v-EDIINTERCHANGEID <> "" and p-messID = ? then p-messID = v-EDIINTERCHANGEID .
    if p-messID = ? then p-messID = "" .
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("memptr", v-DATA).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("statusReport") .
        sw:write-data-element ("reportDateTime", substring(iso-date(NOW), 1, 23) + "Z") .
        sw:write-data-element ("reportRecipient", v-cli-gln) .
        sw:start-element ("reportItem") .
            sw:write-data-element ("messageId", p-messID) .
            sw:write-data-element ("documentId", p-messID) .
            sw:write-data-element ("messageSender", v-cli-gln) .
            sw:write-data-element ("messageRecepient", v-gln-net) .
            sw:write-data-element ("documentType", p-doc-type) .
            sw:write-data-element ("documentNumber", v-documentNumber) .
            sw:write-data-element ("documentDate", v-documentDate) no-error .
            sw:start-element ("statusItem") .
                sw:write-data-element ("dateTime", substring(iso-date(NOW), 1, 23) + "Z") .
                sw:write-data-element ("stage", p-stage) .
                sw:write-data-element ("state", p-state) .
                sw:write-data-element ("description", p-description) .
                if p-stage = "Checking" and p-state = "Ok" and p-description = "Сообщение отклонено на стороне получателя" then
                do :
                    sw:write-data-element ("error", "Заказ УЖЕ в статусе Подтвержден или ПодтвержденОК") .
                end.
                else if p-stage = "Checking" and p-state = "Fail" and p-doc-type = "DESADV" and p-description = "Сообщение отклонено на стороне получателя в УБД" then
                do :
                    sw:write-data-element ("error", "Поставка уже в работе в УБД") .
                end.
                else if p-state = "Fail" then
                do :
                    v-error = replace(v-error, chr(4), " ") .
                    v-error = replace(v-error, ";", "; ") .
                    if trim(v-error) <> "" then
                    do v-ii = 1 to num-entries(v-error, chr(30) ):
                        if trim(entry(v-ii, v-error, chr(30) )) <> "" then
                        sw:write-data-element ("error", trim(entry(v-ii, v-error, chr(30)))) .
                    end.
                end.
                else do :
                end.
            sw:end-element ("statusItem") .
        sw:end-element ("reportItem") .
    sw:end-element ("statusReport") .
    sw:end-document () .
    delete object sw.
    IF ExpData1:esys-add-dump-data ( INPUT v-DATA, INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-dump-ord-int64 = context_send-esys-command( input string(buf_ext-system.esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid).
    if v-dump-ord-int64 = 0 THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-edist-mess = ''.
    v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'route':U, string(v-dump-ord-int64)).
    v-date-status = ?.
    run create-edi-state in this-procedure (
                                            input 'ord-doc-rcv':U
                                          , input v-rcv-code
                                          , input buf_ord-doc.cli-type
                                          , input buf_ord-doc.cli-code
                                          , input 'ИЗМЕНЕНИЕ':U
                                          , input buf_ord-doc.ord-int1
                                          , input integer('0':U)
                                          , input buf_ord-doc.PS
                                          , input v-edist-mess
                                          , input integer('2':U)
                                          , input-output v-date-status
                                          , input-output v-time-status
                                          ).
        ExpData1:Route-data_clear-data ( ) .
  end.
end.
end procedure.
            run send-stat_contour ( input "ORDRSP"
                                    ,input "OK"
                                    ,input "checking"
                                    ,input "Сообщение принято"
                                    ,input ?) .
          end.
          else
            assign
                shar_ord-doc.ord-int1 = integer('5':U)
            .
        end.
        run cus/ord-clos.p
          ( input  parParentProc
          , input  recid(shar_ord-doc)
          , input  shar_ord-doc.obj-type
          , input  shar_ord-doc.obj-code
          , input  v-cntxt-db-num
          , input  true
          , input  "no"
          ) no-error .
        if error-status :error or return-value <> "" then do:
            message return-value         skip
            error-status :get-message(1) skip
            view-as alert-box error
            title "Закрытие заказа"
          .
          return  .
        end.
        if p-dm-edi <> integer('9':U) then do :
            run cus/edocsord.p (  input parParentProc
                                  ,input recid(shar_ord-doc)
                                  ,input 'ord-doc':U
                                  ,input yes
                                  ) no-error  .
            if error-status :error or
            (shar_ord-doc.whole-send-news = integer('1':U)
            and shar_ord-doc.ord-int1 <> integer('5':U))
            or
            (shar_ord-doc.whole-send-news = integer('2':U)
            and p-dm-edi = integer('5':U)
            and not shar_ord-doc.ord-int1 = integer('5':U)
            )
            then do:
              message
              "Не удалось отправить заказ !" view-as alert-box information .
              shar_ord-doc.status_ = 'новый':U .
            end.
        end.
      end.
      when 2 then do:
        if is-edoc-nn-doc then do :
         assign
         shar_ord-doc.ord-int1 = integer('0':U)
         shar_ord-doc.ord-int2 = integer('1':U)
         .
        end.
        if is-edi-doc then do :
            if p-dm-edi = integer('9':U) then
                assign shar_ord-doc.ord-int1 = integer('1':U) .
            else
                assign
                  shar_ord-doc.ord-int1 = integer('4':U)
                  shar_ord-doc.ord-int2 = integer('1':U)
                .
          run cus/edocsord.p (  input parParentProc
                                ,input recid(shar_ord-doc)
                                ,input 'ord-doc':U
                                ,input yes
                                ) no-error  .
          if error-status :error or
            (shar_ord-doc.whole-send-news = integer('2':U)
            and p-dm-edi = integer('5':U)
            and shar_ord-doc.ord-int1 <> integer('4':U)
            )
          or (shar_ord-doc.whole-send-news = integer('2':U)
            and p-dm-edi = integer('9':U)
            and shar_ord-doc.ord-int1 <> integer('1':U)
            )
          then do:
            message
            "Не удалось отправить заказ !" view-as alert-box information .
            shar_ord-doc.status_ = 'новый':U .
          end.
        end.
      end.
      when 3 then do:
      end.
    end case.
  end.
end.
run proc-fin in this-procedure .
return .
 procedure proc-fin :
   do
   on error undo, return error return-value
   :
      for each tmp#zakaz      :   delete tmp#zakaz     . end .
      for each tmp#zakaz-dtl  :   delete tmp#zakaz-dtl . end .
      t-ret =  session:set-wait-state("") .
   end.
 end procedure.
procedure display-line-process :
define input parameter p-num-rec as integer no-undo .
define parameter buffer buf_ord-line for ub.ord-line.
do
on error undo, return error
:
  if  p-num-rec modulo 10 = 0 then do:
    run waitfram-show in this-procedure ( input "Просмотрено &1 строк", p-num-rec ).
  end.
end.
end procedure.
