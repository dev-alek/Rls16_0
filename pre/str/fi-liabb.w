DEFINE TEMP-TABLE tt_fin-ob-tax-before NO-UNDO LIKE ub.fin-ob-tax-before.
define input parameter parParentProc   AS WIDGET-HANDLE NO-UNDO.
define input parameter ref-mode        as character no-undo .
define input-output parameter ri       as recid no-undo.
define input parameter par-host-code as integer no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-status_  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма просмотра ПредФинОбязательства".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable tcode as character no-undo .
define variable loc_contract-code-id  like fin-ob-before.contract-code        no-undo .
define variable pp-modif              as logical init false  no-undo .
define variable p-doc-date            like fin-ob-before.doc-date             no-undo .
define variable p-payer-name          like fin-ob-before.payer-name             no-undo .
define variable p-receiver-name       like fin-ob-before.receiver-name             no-undo .
define variable p-curr-code           like fin-ob-before.curr-code            no-undo .
define variable p-sum-doc             like fin-ob-before.sum-doc              no-undo .
define variable p-user-db-num-doc     like fin-ob-before.user-db-num-doc      no-undo .
define variable p-user-name-doc       like fin-ob-before.user-name-doc        no-undo .
define variable p-base-rate           like fin-ob-before.base-rate            no-undo .
define variable p-base-scale          like fin-ob-before.base-scale           no-undo .
define variable p-receiver-code       like fin-ob-before.receiver-code             no-undo .
define variable p-receiver-type       like fin-ob-before.receiver-type             no-undo .
define variable p-contract-code       like fin-ob-before.contract-code        no-undo .
define variable p-contract-curr       like fin-ob-before.contract-curr        no-undo .
define variable p-contract-rate       like fin-ob-before.contract-rate        no-undo .
define variable p-contract-scale      like fin-ob-before.contract-scale      no-undo .
define variable p-exch-rate           like fin-ob-before.exch-rate            no-undo .
define variable p-exch-scale          like fin-ob-before.exch-scale           no-undo .
define variable p-fact-date           like fin-ob-before.fact-date            no-undo .
define variable p-fact-order          like fin-ob-before.fact-order           no-undo .
define variable p-host-code           like fin-ob-before.host-code            no-undo .
define variable p-payer-code          like fin-ob-before.payer-code         no-undo .
define variable p-payer-type          like fin-ob-before.payer-type         no-undo .
define variable p-pay-date            like fin-ob-before.pay-date            no-undo .
define variable p-prn-doc-code        like fin-ob-before.prn-doc-code         no-undo .
define variable p-sum-base-orig       like fin-ob-before.sum-base-orig        no-undo .
define variable p-sum-base            like fin-ob-before.sum-base             no-undo .
define variable p-sum-doc-orig        like fin-ob-before.sum-doc-orig         no-undo .
define variable p-sum-rubl-orig       like fin-ob-before.sum-rubl-orig        no-undo .
define variable p-sum-rubl            like fin-ob-before.sum-rubl             no-undo .
define variable p-sum-contract        like fin-ob-before.sum-contract         no-undo .
define variable p-trn-doc-code        like fin-ob-before.trn-doc-code         no-undo .
define variable p-user-db-num-fact    like fin-ob-before.user-db-num-fact     no-undo .
define variable p-user-db-num-pay     like fin-ob-before.user-db-num-pay      no-undo .
define variable p-user-name-fact      like fin-ob-before.user-name-fact       no-undo .
define variable p-user-name-pay       like fin-ob-before.user-name-pay        no-undo .
define variable p-in-type             like fin-ob-before.in-type              no-undo .
define variable p-sum-tax-rubl        like fin-ob-before.sum-tax-rubl         no-undo .
define variable p-sum-tax-base        like fin-ob-before.sum-tax-base         no-undo .
define variable p-sum-tax-doc         like fin-ob-before.sum-tax-doc          no-undo .
define variable p-sum-tax-contract    like fin-ob-before.sum-tax-contract     no-undo .
define variable loc_doc-type as character no-undo .
define variable loc_status_  as character no-undo .
define variable loc_in-type as integer no-undo .
define variable glob-vat-pc as decimal no-undo .
define variable glob-slt-pc as decimal no-undo .
define variable p-basecode as integer no-undo .
define variable g#log as logical no-undo .
DEFINE  SHARED variable br-handle as handle  no-undo .
DEFINE  SHARED variable next-prev as logical no-undo .
DEFINE  SHARED buffer   buf_fin-liab-before for ub.fin-ob-before .
FUNCTION sel-abbr RETURNS CHARACTER
  ( p-curr-code as int )  FORWARD.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить налог".
DEFINE BUTTON B-contract
     LABEL "До&говор"
     SIZE 10 BY 1 TOOLTIP "Просмотр атрибутов договора".
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить налог".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.
DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-ins
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить налог".
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1.
DEFINE BUTTON B-payer
     LABEL "П&лательщик"
     SIZE 13.25 BY 1 TOOLTIP "Просмотр атрибутов Платильщика".
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON B-receiver
     LABEL "П&олучатель"
     SIZE 13.25 BY 1 TOOLTIP "Просмотр атрибутов Получателя".
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-con
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-con"
     SIZE 3 BY 1 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-cur
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-cur-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Подстановка курса договора из справочника".
DEFINE BUTTON r-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-obj"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
DEFINE VARIABLE loc_PS AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 25.13 BY 6.92 TOOLTIP "Основание для фин.обязательства или примечание"
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-contract-curr AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:"
      VIEW-AS TEXT
     SIZE 9.5 BY .67 TOOLTIP "Валюта договора" NO-UNDO.
DEFINE VARIABLE f-payer AS CHARACTER FORMAT "X(256)":U INITIAL "Плательщик:"
      VIEW-AS TEXT
     SIZE 11.25 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-receiver AS CHARACTER FORMAT "X(256)":U INITIAL "Получатель:"
      VIEW-AS TEXT
     SIZE 11.25 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":C20 INITIAL "ВАЛЮТА"
      VIEW-AS TEXT
     SIZE 19.13 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":C17 INITIAL "КУРС"
      VIEW-AS TEXT
     SIZE 17.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":C23 INITIAL "СУММА"
      VIEW-AS TEXT
     SIZE 22 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":C22 INITIAL "НАЛОГ"
      VIEW-AS TEXT
     SIZE 22 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE loc_abbr-base AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 19.13 BY 1 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_abbr-contract AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4.13 BY .67 TOOLTIP "Валюта договора"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_abbr-doc AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4.13 BY .67 TOOLTIP "Валюта платежа"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_abbr-rubl AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 19.13 BY 1 TOOLTIP "Национальная валюта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_base-rate AS DECIMAL FORMAT "->>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 12 BY 1.
DEFINE VARIABLE loc_base-scale AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1.
DEFINE VARIABLE loc_contract-code AS CHARACTER FORMAT "X(20)"
     LABEL "№ договора"
     VIEW-AS FILL-IN
     SIZE 18.75 BY 1.
DEFINE VARIABLE loc_contract-curr AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Валюта договора".
DEFINE VARIABLE loc_contract-rate AS DECIMAL FORMAT "->>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 12 BY 1.
DEFINE VARIABLE loc_contract-scale AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1.
DEFINE VARIABLE loc_curr-code AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Платеж"
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Валюта платежа".
DEFINE VARIABLE loc_doc-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата док-та"
      VIEW-AS TEXT
     SIZE 11 BY .67.
DEFINE VARIABLE loc_exch-rate AS DECIMAL FORMAT "->>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.
DEFINE VARIABLE loc_exch-scale AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.
DEFINE VARIABLE loc_fact-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата факт"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE loc_pay-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата платежа"
     VIEW-AS FILL-IN
     SIZE 11.13 BY 1 TOOLTIP "Дата платежа".
DEFINE VARIABLE loc_payer-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1.
DEFINE VARIABLE loc_payer-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 40 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE loc_payer-type AS CHARACTER FORMAT "X(3)" INITIAL "~{&cmp}"
      VIEW-AS TEXT
     SIZE 2.88 BY 1.
DEFINE VARIABLE loc_prn-doc-code AS CHARACTER FORMAT "X(16)"
     LABEL "Номер"
     VIEW-AS FILL-IN
     SIZE 17 BY .88.
DEFINE VARIABLE loc_receiver-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1.
DEFINE VARIABLE loc_receiver-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 40 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE loc_receiver-type AS CHARACTER FORMAT "X(3)" INITIAL "~{&cmp}"
      VIEW-AS TEXT
     SIZE 2.88 BY 1.
DEFINE VARIABLE loc_sum-base AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1.
DEFINE VARIABLE loc_sum-contract AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1.
DEFINE VARIABLE loc_sum-doc AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1.
DEFINE VARIABLE loc_sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1.
DEFINE VARIABLE loc_sum-tax-base AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1.
DEFINE VARIABLE loc_sum-tax-contract AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1.
DEFINE VARIABLE loc_sum-tax-doc AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1.
DEFINE VARIABLE loc_sum-tax-rubl AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1.
DEFINE VARIABLE loc_trn-doc-code AS CHARACTER FORMAT "X(14)"
     LABEL "№ ПН"
      VIEW-AS TEXT
     SIZE 15.88 BY .67.
DEFINE VARIABLE p-doc-code AS character FORMAT "X(16)" init ""
     LABEL "Внут.№"
      VIEW-AS TEXT
     SIZE 15.75 BY .67 TOOLTIP "Внутренний код документа"
     FGCOLOR 7 .
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 20.5 BY 5.13.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.63 BY 5.13.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 4.88 BY 5.13.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 19 BY 5.13.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 24 BY 5.13.
DEFINE VARIABLE T-base AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY .83 TOOLTIP "Ввод суммы в базовой валюте" NO-UNDO.
DEFINE VARIABLE T-contract AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY .83 TOOLTIP "Ввод суммы в валюте договора" NO-UNDO.
DEFINE VARIABLE T-doc AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY .83 TOOLTIP "Ввод суммы в валюте документа" NO-UNDO.
DEFINE VARIABLE T-rubl AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY .83 TOOLTIP "Ввод суммы в нац.валюте" NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      tt_fin-ob-tax-before SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 NO-LOCK DISPLAY
      tt_fin-ob-tax-before.sum-line-doc COLUMN-LABEL "Сумма(налог в т.ч)!в вал.док-та" FORMAT "->>>>>>>>>>>9.99":U
      tt_fin-ob-tax-before.with-slt COLUMN-LABEL "НП" FORMAT "  /без":U
      tt_fin-ob-tax-before.slt-pc COLUMN-LABEL "Ставка!НП" FORMAT ">9.9<%":U
      tt_fin-ob-tax-before.sum-slt-line-doc COLUMN-LABEL "Сумма НП!в вал.док-та" FORMAT "->>>>>>>>9.99":U
      tt_fin-ob-tax-before.with-vat COLUMN-LABEL "НДС" FORMAT " /без":U
      tt_fin-ob-tax-before.vat-pc COLUMN-LABEL "Ставка!НДС" FORMAT ">9.9<%":U
      tt_fin-ob-tax-before.sum-vat-line-doc COLUMN-LABEL "Сумма НДС!в вал.док-та" FORMAT "->>>>>>>>>9.99":U
    WITH SEPARATORS SIZE 68.88 BY 4.2
         BGCOLOR 15 .
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 11
     b-next AT ROW 1 COL 16
     b-quit AT ROW 1 COL 21
     B-contract AT ROW 1 COL 51
     B-receiver AT ROW 1 COL 61.13
     B-payer AT ROW 1 COL 74.5
     B-help AT ROW 1 COL 88
     loc_prn-doc-code AT ROW 2 COL 16.88 COLON-ALIGNED
     loc_contract-code AT ROW 3.17 COL 11 COLON-ALIGNED
     r-con AT ROW 3.17 COL 32.25
     loc_pay-date AT ROW 3.96 COL 84.88 COLON-ALIGNED
     loc_receiver-code AT ROW 4.17 COL 11 COLON-ALIGNED NO-LABEL
     r-cli AT ROW 4.21 COL 26.5
     loc_payer-code AT ROW 5.25 COL 11 COLON-ALIGNED NO-LABEL
     r-obj AT ROW 5.25 COL 26.13
     r-cur AT ROW 9.5 COL 12.88
     loc_exch-rate AT ROW 9.5 COL 20 COLON-ALIGNED NO-LABEL
     loc_exch-scale AT ROW 9.5 COL 32.38 COLON-ALIGNED NO-LABEL
     loc_sum-doc AT ROW 9.5 COL 42.88 COLON-ALIGNED NO-LABEL
     loc_sum-tax-doc AT ROW 9.5 COL 66.63 COLON-ALIGNED NO-LABEL
     T-doc AT ROW 9.5 COL 92.63
     loc_sum-tax-rubl AT ROW 10.46 COL 66.63 COLON-ALIGNED NO-LABEL
     T-rubl AT ROW 10.46 COL 92.63
     loc_sum-rubl AT ROW 10.5 COL 42.88 COLON-ALIGNED NO-LABEL
     loc_base-rate AT ROW 11.33 COL 20 COLON-ALIGNED NO-LABEL
     loc_base-scale AT ROW 11.33 COL 32.5 COLON-ALIGNED NO-LABEL
     loc_sum-tax-base AT ROW 11.46 COL 66.63 COLON-ALIGNED NO-LABEL
     T-base AT ROW 11.46 COL 92.63
     loc_sum-base AT ROW 11.5 COL 42.88 COLON-ALIGNED NO-LABEL
     loc_contract-rate AT ROW 12.38 COL 20 COLON-ALIGNED NO-LABEL
     loc_contract-scale AT ROW 12.38 COL 32.5 COLON-ALIGNED NO-LABEL
     loc_sum-contract AT ROW 12.38 COL 42.88 COLON-ALIGNED NO-LABEL
     loc_sum-tax-contract AT ROW 12.38 COL 66.63 COLON-ALIGNED NO-LABEL
     T-contract AT ROW 12.38 COL 92.63
     r-cur-contr AT ROW 12.5 COL 40.75
     BROWSE-1 AT ROW 14.08 COL 1.13
     loc_PS AT ROW 14.08 COL 70.88 NO-LABEL
     B-ins AT ROW 20.17 COL 1
     B-chg AT ROW 20.17 COL 11
     B-del AT ROW 20.17 COL 21
     loc_doc-date AT ROW 3 COL 85 COLON-ALIGNED
     loc_receiver-type AT ROW 4.21 COL 21.38 COLON-ALIGNED NO-LABEL
     loc_receiver-name AT ROW 4.21 COL 27.13 COLON-ALIGNED NO-LABEL
     f-receiver AT ROW 4.33 COL 1 NO-LABEL
     loc_fact-date AT ROW 5 COL 84.5 COLON-ALIGNED
     loc_payer-type AT ROW 5.25 COL 21.5 COLON-ALIGNED NO-LABEL
     loc_payer-name AT ROW 5.25 COL 26.88 COLON-ALIGNED NO-LABEL
     f-payer AT ROW 5.42 COL 1 NO-LABEL
     loc_trn-doc-code AT ROW 5.67 COL 80 COLON-ALIGNED
     p-doc-code AT ROW 6.38 COL 80 COLON-ALIGNED
     FILL-IN-4 AT ROW 8.75 COL 1.75 NO-LABEL
     FILL-IN-5 AT ROW 8.75 COL 22 NO-LABEL
     FILL-IN-6 AT ROW 8.75 COL 44.88 NO-LABEL
     FILL-IN-7 AT ROW 8.75 COL 68.63 NO-LABEL
     loc_curr-code AT ROW 9.5 COL 7.88 COLON-ALIGNED
     loc_abbr-doc AT ROW 9.5 COL 14.38 COLON-ALIGNED NO-LABEL
     loc_abbr-rubl AT ROW 10.33 COL 1.75 NO-LABEL
     loc_abbr-base AT ROW 11.33 COL 1.75 NO-LABEL
     loc_contract-curr AT ROW 12.58 COL 10.88 COLON-ALIGNED NO-LABEL
     loc_abbr-contract AT ROW 12.58 COL 14.88 COLON-ALIGNED NO-LABEL
     f-contract-curr AT ROW 12.63 COL 1.75 NO-LABEL
     RECT-1 AT ROW 8.58 COL 1
     RECT-2 AT ROW 8.54 COL 44.25
     RECT-3 AT ROW 8.54 COL 91.5
     RECT-4 AT ROW 8.54 COL 21.38
     RECT-5 AT ROW 8.54 COL 67.88
     SPACE(6.36) SKIP(7.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ПредФинОбязательства "
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-prev:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       loc_pay-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  if input loc_prn-doc-code = ""
        or loc_prn-doc-code = ?
  then do:
      message "Номер документа  не может быть не задан" view-as alert-box.
      apply "ENTRY":U to loc_prn-doc-code.
      return no-apply.
  end.
  if ref-mode =  'ДОБАВЛЕНИЕ':U then do:
  end.
  if ref-mode <> 'ПРОСМОТР':U then do:
      assign
      loc_prn-doc-code loc_contract-code loc_pay-date loc_receiver-code loc_payer-code loc_exch-rate loc_exch-scale loc_sum-doc T-doc T-rubl loc_base-rate loc_base-scale T-base loc_contract-rate loc_contract-scale T-contract loc_PS loc_receiver-type loc_payer-type loc_curr-code loc_contract-curr
      .
  end.
 run save-p in this-procedure  no-error .
 if error-status :error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable p-recid            as  recid   no-undo .
define variable p-res              as  logical no-undo .
define variable v-slt-pc           like fin-ob-tax-before.slt-pc           no-undo.
define variable v-loc_sum-doc      like fin-ob-tax-before.sum-line-doc     no-undo.
define variable v-sum-vat-line-doc like fin-ob-tax-before.sum-vat-line-doc no-undo.
define variable v-sum-slt-line-doc like fin-ob-tax-before.sum-slt-line-doc no-undo.
define variable v-vat-pc           like fin-ob-tax-before.vat-pc           no-undo.
define variable v-with-slt         like fin-ob-tax-before.with-slt         no-undo.
define variable v-with-vat         like fin-ob-tax-before.with-vat         no-undo.
  find current tt_fin-ob-tax-before no-error .
  if not available tt_fin-ob-tax-before then find first tt_fin-ob-tax-before.
    if not available tt_fin-ob-tax-before then return no-apply.
    assign
      p-recid            = recid(tt_fin-ob-tax-before)
      v-slt-pc           = tt_fin-ob-tax-before.slt-pc
      v-loc_sum-doc      = tt_fin-ob-tax-before.sum-line-doc
      v-sum-vat-line-doc = tt_fin-ob-tax-before.sum-vat-line-doc
      v-sum-slt-line-doc = tt_fin-ob-tax-before.sum-slt-line-doc
      v-vat-pc           = tt_fin-ob-tax-before.vat-pc
      v-with-slt         = tt_fin-ob-tax-before.with-slt
      v-with-vat         = tt_fin-ob-tax-before.with-vat
    .
run str/fi-txli.w (
 input  parParentProc ,
 input  par-host-code   ,
 input  'ИЗМЕНЕНИЕ':U             ,
 input  par-host-code         ,
 input  p-doc-code            ,
 input  'рас':U           ,
 input  loc_sum-doc           ,
 input  loc_curr-code ,
 input  loc_base-rate ,
 input  loc_base-scale,
 input  loc_exch-rate ,
 input  loc_exch-scale,
 input-output v-slt-pc          ,
 input-output v-loc_sum-doc     ,
 input-output v-sum-vat-line-doc,
 input-output v-sum-slt-line-doc,
 input-output v-vat-pc          ,
 input-output v-with-slt        ,
 input-output v-with-vat        ,
 input table tt_fin-ob-tax-before      ,
 input recid (tt_fin-ob-tax-before)     ,
 input ?      ,
 output p-res
  ) no-error .
if p-res = true then do:
    assign
      tt_fin-ob-tax-before.slt-pc           = v-slt-pc
      tt_fin-ob-tax-before.sum-line-doc     = v-loc_sum-doc
      tt_fin-ob-tax-before.sum-vat-line-doc = v-sum-vat-line-doc
      tt_fin-ob-tax-before.sum-slt-line-doc = v-sum-slt-line-doc
      tt_fin-ob-tax-before.vat-pc           = v-vat-pc
      tt_fin-ob-tax-before.with-slt         = v-with-slt
      tt_fin-ob-tax-before.with-vat         = v-with-vat
    .
    OPEN QUERY BROWSE-1 FOR EACH tt_fin-ob-tax-before NO-LOCK.
    reposition BROWSE-1 TO RECID p-recid NO-ERROR .
    run calc-tax in this-procedure  .
end.
END.
ON return OF B-chg IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  B-chg:handle ) .
  return no-apply .
END.
ON CHOOSE OF B-contract IN FRAME Dialog-Frame
DO:
assign
   loc_contract-code
.
define variable ri as recid no-undo .
define buffer b_contract for contract.
find first b_contract no-lock  where b_contract.contract-prn-code = loc_contract-code and
                                     b_contract.host-code         = par-host-code
                                     no-error .
if error-status :error then return no-apply.
ri = recid (b_contract) .
run str/sh-contr.p (
  input   parParentProc ,
  input  ri      )
  .
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
find current tt_fin-ob-tax-before   no-error .
if not available tt_fin-ob-tax-before  then return .
define variable g-log as log no-undo.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_deletion':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then  return .
  else do:
      message "Удалить запись ?"
      view-as alert-box question
      buttons yes-no
      update g-log.
      if g-log = false then return no-apply.
  end.
  define variable v-code as integer no-undo .
  delete tt_fin-ob-tax-before .
  run calc-tax in this-procedure .
  OPEN QUERY BROWSE-1 FOR EACH tt_fin-ob-tax-before NO-LOCK.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    next-prev = ?.
END.
ON CHOOSE OF B-ins IN FRAME Dialog-Frame
DO:
define variable p-recid            as  recid   no-undo .
define variable p-res              as  logical no-undo .
define variable v-slt-pc           like fin-ob-tax-before.slt-pc           no-undo.
define variable v-loc_sum-doc      like fin-ob-tax-before.sum-line-doc      no-undo.
define variable v-sum-vat-line-doc like fin-ob-tax-before.sum-vat-line-doc no-undo.
define variable v-sum-slt-line-doc like fin-ob-tax-before.sum-slt-line-doc no-undo.
define variable v-vat-pc           like fin-ob-tax-before.vat-pc           no-undo.
define variable v-with-slt         like fin-ob-tax-before.with-slt         no-undo.
define variable v-with-vat         like fin-ob-tax-before.with-vat         no-undo.
run str/fi-txli.w (
 INPUT  parParentProc ,
 input  par-host-code   ,
 input  'ДОБАВЛЕНИЕ':U            ,
 input  par-host-code         ,
 input  p-doc-code            ,
 input 'рас':U             ,
 input  loc_sum-doc           ,
 input  loc_curr-code ,
 input  loc_base-rate ,
 input  loc_base-scale,
 input  loc_exch-rate ,
 input  loc_exch-scale,
 input-output v-slt-pc          ,
 input-output v-loc_sum-doc     ,
 input-output v-sum-vat-line-doc,
 input-output v-sum-slt-line-doc,
 input-output v-vat-pc          ,
 input-output v-with-slt        ,
 input-output v-with-vat        ,
 INPUT TABLE tt_fin-ob-tax-before ,
 input ?      ,
 input ?      ,
 output p-res
  ).
define variable l-num as integer no-undo .
l-num = 0.
if p-res = true then do:
  find last tt_fin-ob-tax-before use-index pi no-error .
     if not available tt_fin-ob-tax-before
            then l-num = 0.
            else l-num = tt_fin-ob-tax-before.line-num.
    l-num = l-num + 1.
    create tt_fin-ob-tax-before.
    assign
      tt_fin-ob-tax-before.before-code      = p-doc-code
      tt_fin-ob-tax-before.host-code        = par-host-code
      tt_fin-ob-tax-before.line-num         = l-num
      tt_fin-ob-tax-before.slt-pc           = v-slt-pc
      tt_fin-ob-tax-before.sum-line-doc     = v-loc_sum-doc
      tt_fin-ob-tax-before.sum-vat-line-doc = v-sum-vat-line-doc
      tt_fin-ob-tax-before.sum-slt-line-doc = v-sum-slt-line-doc
      tt_fin-ob-tax-before.vat-pc           = v-vat-pc
      tt_fin-ob-tax-before.with-slt         = v-with-slt
      tt_fin-ob-tax-before.with-vat         = v-with-vat
    .
end.
run calc-tax in this-procedure .
OPEN QUERY BROWSE-1 FOR EACH tt_fin-ob-tax-before NO-LOCK.
reposition BROWSE-1 TO RECID p-recid NO-ERROR .
END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
run step-next in this-procedure .
END.
ON CHOOSE OF B-payer IN FRAME Dialog-Frame
DO:
assign loc_payer-code loc_payer-type .
run lookup-cli in this-procedure (loc_payer-code , loc_payer-type) no-error .
    if error-status :error then return no-apply.
END.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
   run step-prev in this-procedure .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
    next-prev = ?.
    message "Выходим без сохранения изменений ?" view-as alert-box question
            buttons yes-no
            update ll as log
            .
    if ll = no then return no-apply.
END.
ON CHOOSE OF B-receiver IN FRAME Dialog-Frame
DO:
   assign loc_receiver-code loc_receiver-type .
   run lookup-cli in this-procedure  (loc_receiver-code , loc_receiver-type) no-error .
       if error-status :error then return no-apply.
END.
ON LEAVE OF loc_base-rate IN FRAME Dialog-Frame
OR "LEAVE" Of loc_base-scale
OR "LEAVE" Of loc_exch-rate
OR "LEAVE" Of loc_exch-scale
OR "LEAVE" Of loc_contract-rate
OR "LEAVE" Of loc_contract-scale
DO:
  assign loc_base-rate loc_base-scale loc_exch-rate loc_exch-scale
  loc_contract-rate
  loc_contract-scale
  .
   if T-doc  then apply "leave" to loc_sum-doc  in frame Dialog-Frame .
   if T-rubl then apply "leave" to loc_sum-rubl in frame Dialog-Frame .
   if T-base then apply "leave" to loc_sum-base in frame Dialog-Frame .
   if T-contract then apply "leave" to loc_sum-contract in frame Dialog-Frame .
END.
ON return OF loc_base-rate IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_base-rate:handle ) .
  return no-apply .
END.
ON return OF loc_base-scale IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_base-scale:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_contract-code IN FRAME Dialog-Frame
DO:
 define variable old-p  like loc_contract-code no-undo.
 define variable p-quest as logical no-undo .
 define variable v-mess as logical no-undo init false .
 define buffer buf_contract for contract.
 old-p = input frame Dialog-Frame loc_contract-code .
 if (old-p  <> loc_contract-code or pp-modif = true)  then do:
    v-mess = true .
 end.
  assign
    loc_contract-code
    pp-modif = false
  .
  find first buf_contract where buf_contract.contract-prn-code = loc_contract-code
                            and buf_contract.host-code         = par-host-code
                        no-lock no-error .
  if not available buf_contract then do:
     message "Не верно введен Номер договора!!! " view-as alert-box .
     return no-apply.
  end.
  p-quest = true .
  if   v-mess = true  then do :
   message "Изменился договор! Изменить все значения финобязательства по договору "  loc_contract-code " ? " skip
      view-as alert-box question
      buttons YES-NO
      update p-quest .
   end.
      case p-quest :
      when true  then do:
         run from-contract in this-procedure (
              input buf_contract.contract-code ,
              input buf_contract.host-code                 ) no-error .
         if error-status :error then return no-apply.
      end.
      when false   then do:
      end.
      otherwise do:
        loc_contract-code = old-p.
        display loc_contract-code with frame Dialog-Frame .
      end.
      end case.
END.
ON return OF loc_contract-code IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  loc_contract-code:handle ) .
  return no-apply .
END.
ON return OF loc_contract-curr IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  loc_contract-curr:handle ) .
  return no-apply .
END.
ON return OF loc_contract-rate IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_contract-rate:handle ) .
  return no-apply .
END.
ON return OF loc_contract-scale IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_contract-scale:handle ) .
  return no-apply .
END.
ON return OF loc_curr-code IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  loc_curr-code:handle ) .
  return no-apply .
END.
ON return OF loc_exch-rate IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_exch-rate:handle ) .
  return no-apply .
END.
ON return OF loc_exch-scale IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_exch-scale:handle ) .
  return no-apply .
END.
ON return OF loc_pay-date IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  loc_pay-date:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_payer-code IN FRAME Dialog-Frame
DO:
assign loc_payer-code loc_payer-type.
define buffer b#clients for clients.
 find first b#clients WHERE
    b#clients.obj-code = loc_payer-code  and
    b#clients.obj-type = loc_payer-type
     No-LOCK No-ERROR.
    if not available b#clients then dO:
       message "Не верно введен код !!!"  view-as alert-box information .
    end.
    if avail b#clients then dO:
        Assign
            loc_payer-code = b#clients.obj-code
            loc_payer-type = b#clients.obj-type
            loc_payer-name = b#clients.obj-name .
    Display  loc_payer-code loc_payer-name loc_payer-type
    with frame Dialog-Frame .
    Enable  loc_payer-code  loc_payer-type
    with frame Dialog-Frame .
    end.
    else
      apply "CHOOSE" to r-obj IN FRAME Dialog-Frame        .
END.
ON RETURN OF loc_payer-code IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_payer-code:handle ) .
  return no-apply .
END.
ON return OF loc_prn-doc-code IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_prn-doc-code:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_receiver-code IN FRAME Dialog-Frame
DO:
    assign loc_receiver-code loc_receiver-type.
define buffer b#clients for clients.
 find first b#clients WHERE
    loc_receiver-code = b#clients.obj-code and
    loc_receiver-type = b#clients.obj-type
     No-LOCK No-ERROR.
    if not available b#clients then dO:
       message "Не верно введен код !!!"  view-as alert-box information .
    end.
    if avail b#clients then do:
        Assign
            loc_receiver-code = b#clients.obj-code
            loc_receiver-type = b#clients.obj-type
            loc_receiver-name = b#clients.obj-name
            .
    Display  loc_receiver-code loc_receiver-name loc_receiver-type
    with frame Dialog-Frame .
    Enable  loc_receiver-code  loc_receiver-type
    with frame Dialog-Frame .
end.
else   apply "CHOOSE" to r-cli IN FRAME Dialog-Frame        .
END.
ON return OF loc_receiver-code IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  loc_receiver-code:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-base IN FRAME Dialog-Frame
DO:
define variable v-mod as logical no-undo .
 v-mod = loc_sum-base:MODIFIED.
assign loc_sum-base loc_sum-tax-base
 loc_base-rate loc_base-scale
 loc_exch-rate loc_exch-scale
 loc_contract-rate loc_contract-scale
 .
  loc_sum-rubl    = ( loc_base-rate  / loc_base-scale) * loc_sum-base .
  loc_sum-doc   = (  loc_exch-scale   / loc_exch-rate) * loc_sum-rubl .
  loc_sum-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-rubl .
  if v-mod  then
     run create-tax in this-procedure (
          input loc_sum-doc ,
          input loc_sum-rubl  ,
          input loc_sum-base   ,
          input loc_sum-contract ,
          input "base":U ,
          output loc_sum-tax-base) .
  loc_sum-tax-rubl    = ( loc_base-rate  / loc_base-scale) * loc_sum-tax-base .
  loc_sum-tax-doc   = (  loc_exch-scale   / loc_exch-rate) * loc_sum-tax-rubl .
  loc_sum-tax-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-tax-rubl .
  display
    loc_sum-doc          when loc_sum-doc          :visible
    loc_sum-base         when loc_sum-base         :visible
    loc_sum-rubl         when loc_sum-rubl         :visible
    loc_sum-contract     when loc_sum-contract     :visible
    loc_sum-tax-doc      when loc_sum-tax-doc      :visible
    loc_sum-tax-rubl     when loc_sum-tax-rubl     :visible
    loc_sum-tax-contract when loc_sum-tax-contract :visible
    loc_sum-tax-base     when loc_sum-tax-base     :visible
    with frame Dialog-Frame.
END.
ON return OF loc_sum-base IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_sum-base:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-contract IN FRAME Dialog-Frame
DO:
define variable v-mod as logical no-undo .
 v-mod = loc_sum-contract:MODIFIED.
 assign loc_sum-contract loc_sum-tax-contract
 loc_base-rate loc_base-scale
 loc_exch-rate loc_exch-scale
 loc_contract-rate loc_contract-scale
 .
  loc_sum-rubl  =  ( loc_contract-rate  / loc_contract-scale) * loc_sum-contract .
  loc_sum-base   = (  loc_base-scale   / loc_base-rate) * loc_sum-rubl .
  loc_sum-doc   = (  loc_exch-scale   / loc_exch-rate) * loc_sum-rubl .
  if v-mod  then
     run create-tax in this-procedure (
          input loc_sum-doc   ,
          input loc_sum-rubl  ,
          input loc_sum-base  ,
          input loc_sum-contract ,
          input "contract":U ,
          output loc_sum-tax-contract) .
  loc_sum-tax-rubl  =  ( loc_contract-rate  / loc_contract-scale) * loc_sum-tax-contract .
  loc_sum-tax-base   = (  loc_base-scale   / loc_base-rate) * loc_sum-tax-rubl .
  loc_sum-tax-doc   = (  loc_exch-scale   / loc_exch-rate) * loc_sum-tax-rubl .
  display
  loc_sum-base           when loc_sum-base         :visible
  loc_sum-rubl           when loc_sum-rubl         :visible
  loc_sum-tax-base       when loc_sum-tax-base     :visible
  loc_sum-tax-rubl       when loc_sum-tax-rubl     :visible
  loc_sum-contract       when loc_sum-contract     :visible
  loc_sum-tax-contract   when loc_sum-tax-contract :visible
  loc_sum-doc            when loc_sum-doc          :visible
  loc_sum-tax-doc        when loc_sum-tax-doc      :visible
  loc_sum-tax-contract   when loc_sum-tax-contract :visible
  with frame Dialog-Frame.
 END.
ON return OF loc_sum-contract IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  loc_sum-contract:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-doc IN FRAME Dialog-Frame
DO:
define variable v-mod as logical no-undo .
 v-mod = loc_sum-doc:MODIFIED.
 assign loc_sum-doc loc_sum-tax-doc
 loc_base-rate loc_base-scale
 loc_exch-rate loc_exch-scale
 loc_contract-rate loc_contract-scale
 .
  loc_sum-rubl    =  ( loc_exch-rate  / loc_exch-scale) * loc_sum-doc .
  loc_sum-base    = (  loc_base-scale   / loc_base-rate) * loc_sum-rubl .
  loc_sum-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-rubl .
  if v-mod  then
     run create-tax in this-procedure (
          input loc_sum-doc ,
          input loc_sum-rubl  ,
          input loc_sum-base   ,
          input loc_sum-contract ,
          input "doc":U ,
          output loc_sum-tax-doc) .
  loc_sum-tax-rubl       = ( loc_exch-rate        / loc_exch-scale)    * loc_sum-tax-doc .
  loc_sum-tax-base       = (  loc_base-scale      / loc_base-rate)     * loc_sum-tax-rubl .
  loc_sum-tax-contract   = (  loc_contract-scale  / loc_contract-rate) * loc_sum-tax-rubl .
  display
      loc_sum-base          when loc_sum-base         :visible
      loc_sum-rubl          when loc_sum-rubl         :visible
      loc_sum-contract      when loc_sum-contract     :visible
      loc_sum-tax-base      when loc_sum-tax-base     :visible
      loc_sum-tax-rubl      when loc_sum-tax-rubl     :visible
      loc_sum-tax-contract  when loc_sum-tax-contract :visible
      loc_sum-tax-doc       when loc_sum-tax-doc      :visible
      with frame Dialog-Frame
      .
 END.
ON return OF loc_sum-doc IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  loc_sum-doc:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-rubl IN FRAME Dialog-Frame
DO:
define variable v-mod as logical no-undo .
 v-mod = loc_sum-rubl:MODIFIED.
assign loc_sum-rubl loc_sum-tax-rubl
 loc_base-rate loc_base-scale
 loc_exch-rate loc_exch-scale
 loc_contract-rate loc_contract-scale
 .
  loc_sum-base    = ( loc_base-scale  / loc_base-rate) * loc_sum-rubl .
  loc_sum-doc      = (  loc_exch-scale    / loc_exch-rate) * loc_sum-rubl .
  loc_sum-contract      = (  loc_contract-scale    / loc_contract-rate) * loc_sum-rubl .
  if v-mod  then
     run create-tax in this-procedure (
          input loc_sum-doc   ,
          input loc_sum-rubl  ,
          input loc_sum-base  ,
          input loc_sum-contract ,
          input "rubl":U ,
          output loc_sum-tax-rubl) .
  loc_sum-tax-base     = ( loc_base-scale  / loc_base-rate) * loc_sum-tax-rubl .
  loc_sum-tax-doc      = (  loc_exch-scale    / loc_exch-rate) * loc_sum-tax-rubl .
  loc_sum-tax-contract = (  loc_contract-scale    / loc_contract-rate) * loc_sum-tax-rubl .
  display
  loc_sum-base            when loc_sum-base         :visible
  loc_sum-doc             when loc_sum-doc          :visible
  loc_sum-tax-base        when loc_sum-tax-base     :visible
  loc_sum-tax-doc         when loc_sum-tax-doc      :visible
  loc_sum-contract        when loc_sum-contract     :visible
  loc_sum-tax-contract    when loc_sum-tax-contract :visible
  loc_sum-tax-rubl        when loc_sum-tax-rubl     :visible
  with frame Dialog-Frame.
END.
ON return OF loc_sum-rubl IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_sum-rubl:handle ) .
  return no-apply .
END.
ON return OF p-doc-code IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  p-doc-code:handle ) .
  return no-apply .
END.
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
  define variable rid-list    as  char no-undo .
  define variable rep-rec2 as recid no-undo .
  define buffer b#clients for clients.
    run ref/cli-all.w ( parParentProc, input "b-sel", 'орг':U, ?, ?, ?, ?, ?, output  rid-list).
    Assign rep-rec2 = integer(rid-list) no-error.
    find first b#clients WHERE recid(b#clients) = rep-rec2 No-LOCK No-ERROR.
    if avail b#clients then do:
        Assign
            loc_receiver-code = b#clients.obj-code
            loc_receiver-type = b#clients.obj-type
            loc_receiver-name = b#clients.obj-name .
    end.
    Display  loc_receiver-code loc_receiver-name loc_receiver-type
    with frame Dialog-Frame .
    Enable  loc_receiver-code  loc_receiver-type
    with frame Dialog-Frame .
END.
ON CHOOSE OF r-con IN FRAME Dialog-Frame
DO:
define variable   p-rid-list   as character no-undo .
define buffer buf_contract for contract.
 pp-modif = false .
  run str/cont-all.w (
      input   parParentProc   ,
      input   par-host-code   ,
      input   "b-sel"         ,
      input   'фирма':U      ,
      input   ?               ,
      input   ?               ,
      input   ?               ,
      input   ?               ,
      input   "current"       ,
      input   'при':U       ,
      input-output p-rid-list )
      .
find first buf_contract no-lock where recid(buf_contract) = integer(p-rid-list) no-error .
if available buf_contract then do:
   if loc_contract-code <> buf_contract.contract-prn-code then pp-modif = true .
   if loc_contract-code = "" then pp-modif = false .
   loc_contract-code = buf_contract.contract-prn-code.
   display loc_contract-code with frame Dialog-Frame.
         run from-contract in this-procedure (
              input buf_contract.contract-code ,
              input buf_contract.host-code
              ) no-error .
    if error-status :error then do:
        if error-status :get-message(1) <> "" then
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Ошибка при проверке договора"
          view-as alert-box error
        .
        return no-apply.
    end.
    run next-focus in this-procedure  (input loc_contract-code:handle ) .
end.
END.
ON CHOOSE OF r-cur IN FRAME Dialog-Frame
DO:
define variable ref-rec as recid no-undo.
run ref/currency.w (input parparentproc, "b-sel", input-output ref-rec ).
if ref-rec = ? then return no-apply.
find currency where recid ( currency ) = ref-rec no-lock.
loc_curr-code  = currency.curr-code .
loc_abbr-doc   = currency.curr-abbr .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  loc_curr-code
  ,input  loc_doc-date
  ,output loc_exch-rate
  ,output loc_exch-scale
  ,output loc_abbr-doc
  )  .
display
  loc_curr-code
  loc_abbr-doc
  loc_exch-rate
  loc_exch-scale
  with frame Dialog-Frame .
 apply "LEAVE" to loc_exch-rate  in frame Dialog-Frame .
 run hide-curr in this-procedure ( input "pay":U ) .
END.
ON CHOOSE OF r-cur-contr IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  loc_contract-curr
  ,input  loc_doc-date
  ,output loc_contract-rate
  ,output loc_contract-scale
  ,output loc_abbr-contract
  )  .
display
  loc_contract-curr
  loc_abbr-contract
  loc_contract-rate
  loc_contract-scale
  with frame Dialog-Frame .
 apply "LEAVE" to loc_contract-rate  in frame Dialog-Frame .
END.
ON CHOOSE OF r-obj IN FRAME Dialog-Frame
DO:
define variable rid-list    as  char no-undo .
define variable rep-rec2 as recid no-undo .
define buffer b#clients for clients.
    run ref/cli-all.w ( parParentProc, input "b-sel", 'орг':U, ?, ?, ?, ?, ?, output  rid-list).
    Assign rep-rec2 = integer(rid-list) no-error.
    find first b#clients WHERE recid(b#clients) = rep-rec2 No-LOCK No-ERROR.
    if avail b#clients then do:
        Assign
            loc_payer-code = b#clients.obj-code
            loc_payer-type = b#clients.obj-type
            loc_payer-name = b#clients.obj-name .
    end.
    Display  loc_payer-code loc_payer-name loc_payer-type
    with frame Dialog-Frame .
    Enable  loc_payer-code  loc_payer-type with frame Dialog-Frame .
END.
ON VALUE-CHANGED OF T-base IN FRAME Dialog-Frame
DO:
 assign t-base.
  if t-base = yes then do:
      enable
        loc_sum-base
        with frame Dialog-Frame.
      disable
        loc_sum-rubl     loc_sum-doc      loc_sum-contract
        with frame Dialog-Frame.
      t-rubl = no.
      t-doc = no.
      t-contract = no.
      display
          t-rubl      when t-rubl:visible
          t-doc
          t-contract  when t-contract:visible
          with frame  Dialog-Frame.
    end.
        else do:
         t-base = yes.
         display t-base with frame  Dialog-Frame.
         end.
loc_in-type            = 1.
END.
ON VALUE-CHANGED OF T-contract IN FRAME Dialog-Frame
DO:
  assign t-contract.
  if t-contract = yes then do:
      enable
         loc_sum-contract
         with frame Dialog-Frame.
      disable
         loc_sum-rubl     loc_sum-base     loc_sum-doc
         with frame Dialog-Frame.
      t-rubl = no.
      t-base = no.
      t-doc = no.
      display
         t-rubl   when t-rubl:visible
         t-base   when t-base:visible
         t-doc
         with frame  Dialog-Frame.
    end.
    else do:
         t-contract = yes.
         display t-contract with frame  Dialog-Frame.
         end.
  loc_in-type = 3.
END.
ON VALUE-CHANGED OF T-doc IN FRAME Dialog-Frame
DO:
  assign t-doc.
  if t-doc = yes then do:
      enable
         loc_sum-doc
         with frame Dialog-Frame.
      disable
         loc_sum-rubl     loc_sum-base     loc_sum-contract
         with frame Dialog-Frame.
      t-rubl = no.
      t-base = no.
      t-contract = no.
      display
         t-rubl  when t-rubl:visible
         t-base  when t-base:visible
         t-contract  when t-contract:visible
         with frame  Dialog-Frame.
    end.
    else do:
         t-doc = yes.
         display t-doc with frame  Dialog-Frame.
         end.
  loc_in-type = 0.
END.
ON VALUE-CHANGED OF T-rubl IN FRAME Dialog-Frame
DO:
  assign t-rubl.
  if t-rubl = yes then do:
      enable
         loc_sum-rubl
         with frame Dialog-Frame.
      disable
        loc_sum-doc     loc_sum-base     loc_sum-contract
        with frame Dialog-Frame.
      t-doc = no.
      t-base = no.
      t-contract = no.
      display
      t-doc
      t-base      when t-base:visible
      t-contract  when t-contract:visible
      with frame  Dialog-Frame.
    end.
    else do:
         t-rubl = yes.
         display t-rubl with frame  Dialog-Frame.
         end.
  loc_in-type            = 2.
END.
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_file for ub.fin-ob .
procedure current-db :
 do
 on error undo, return error return-value
 :
define input parameter  p-host-code as integer no-undo .
define input parameter  c-host-code as integer no-undo .
define output parameter ret         as logical no-undo .
define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .
find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .
find first ub.sysconf where ub.sysconf.host-code = p-host-code no-lock no-error .
if not( ub.sysconf.firm-db-num = v-current-db or
        ub.sysconf.firm-db-num = 0 )
  then do:
  ret = false .
  message "Нельзя добавлять запись в  справочнике  для фирмы с не главной БД !!!" view-as alert-box information .
  return .
end.
 end.
end procedure.
procedure ver-db :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter  c-host-code as integer no-undo .
define input parameter  par-ver-db  as integer no-undo .
define input parameter  p-mess as logical no-undo .
define output parameter ret         as logical no-undo .
define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .
find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .
if not( par-ver-db = v-current-db or
        par-ver-db = 0 )
  then do:
  ret = false .
  if p-mess = true then message "База , на которой мы работаем не является главной базой данных текущей фирмы!!!" view-as alert-box information .
  return .
end.
 end.
end procedure.
procedure fin-ob-code :
 do
 on error undo, return error return-value
 :
  define input  parameter p-db-num as integer no-undo .
  define output parameter p-fin-ob-code  as character no-undo .
  if p-db-num = 0 then
      p-fin-ob-code = string( next-value(s-fin-ob, ub)) .
      else
      p-fin-ob-code = string( next-value(s-fin-ob, ub)) + "-" + string(p-db-num).
 end.
end procedure.
procedure create-fin-liab :
 do
 on error undo, return error return-value
 :
define input parameter p-ver as logical no-undo .
define input parameter p-doc-code            like ub.fin-ob.doc-code             no-undo .
define input parameter p-doc-date            like ub.fin-ob.doc-date             no-undo .
define input parameter p-doc-type            like ub.fin-ob.doc-type             no-undo .
define input parameter p-payer-name            like ub.fin-ob.payer-name             no-undo .
define input parameter p-receiver-name            like ub.fin-ob.receiver-name             no-undo .
define input parameter p-curr-code           like ub.fin-ob.curr-code            no-undo .
define input parameter p-sum-doc             like ub.fin-ob.sum-doc              no-undo .
define input parameter p-user-db-num-doc     like ub.fin-ob.user-db-num-doc      no-undo .
define input parameter p-user-name-doc       like ub.fin-ob.user-name-doc        no-undo .
define input parameter p-base-rate           like ub.fin-ob.base-rate            no-undo .
define input parameter p-base-scale          like ub.fin-ob.base-scale           no-undo .
define input parameter p-receiver-code            like ub.fin-ob.receiver-code             no-undo .
define input parameter p-receiver-type            like ub.fin-ob.receiver-type             no-undo .
define input parameter p-contract-code       like ub.fin-ob.contract-code        no-undo .
define input parameter p-exch-rate           like ub.fin-ob.exch-rate            no-undo .
define input parameter p-exch-scale          like ub.fin-ob.exch-scale           no-undo .
define input parameter p-contract-curr           like ub.fin-ob.contract-curr            no-undo .
define input parameter p-contract-rate           like ub.fin-ob.contract-rate            no-undo .
define input parameter p-contract-scale          like ub.fin-ob.contract-scale           no-undo .
define input parameter p-fact-date           like ub.fin-ob.fact-date            no-undo .
define input parameter p-fact-order          like ub.fin-ob.fact-order           no-undo .
define input parameter p-host-code           like ub.fin-ob.host-code            no-undo .
define input parameter p-payer-code          like ub.fin-ob.payer-code           no-undo .
define input parameter p-payer-type          like ub.fin-ob.payer-type           no-undo .
define input parameter p-pay-date            like ub.fin-ob.pay-date             no-undo .
define input parameter p-prn-doc-code        like ub.fin-ob.prn-doc-code         no-undo .
define input parameter p-status_             like ub.fin-ob.status_              no-undo .
define input parameter p-sum-base-orig       like ub.fin-ob.sum-base-orig        no-undo .
define input parameter p-sum-base            like ub.fin-ob.sum-base             no-undo .
define input parameter p-sum-doc-orig        like ub.fin-ob.sum-doc-orig         no-undo .
define input parameter p-sum-rubl-orig       like ub.fin-ob.sum-rubl-orig        no-undo .
define input parameter p-sum-rubl            like ub.fin-ob.sum-rubl             no-undo .
define input parameter p-sum-contract        like ub.fin-ob.sum-contract         no-undo .
define input parameter p-trn-doc-code        like ub.fin-ob.trn-doc-code         no-undo .
define input parameter p-user-db-num-fact    like ub.fin-ob.user-db-num-fact     no-undo .
define input parameter p-user-db-num-pay     like ub.fin-ob.user-db-num-pay     no-undo .
define input parameter p-user-name-fact      like ub.fin-ob.user-name-fact       no-undo .
define input parameter p-user-name-pay       like ub.fin-ob.user-name-pay       no-undo .
define input parameter p-in-type             like ub.fin-ob.in-type              no-undo .
define input parameter p-sum-tax-base         like ub.fin-ob.sum-tax-base     no-undo .
define input parameter p-sum-tax-doc          like ub.fin-ob.sum-tax-doc      no-undo .
define input parameter p-sum-tax-rubl         like ub.fin-ob.sum-tax-rubl     no-undo .
define input parameter p-sum-tax-contract     like ub.fin-ob.sum-tax-contract no-undo .
define input parameter p-ps                   like ub.fin-ob.ps               no-undo .
define output parameter p-rec-id as recid no-undo .
if p-ver then do:
    find first  buf_file no-lock  where buf_file.host-code = p-host-code and
                                        buf_file.doc-code  = p-doc-code no-error .
    if available buf_file then return error .
end.
define variable p-ret as logical no-undo .
run current-db in this-procedure (
    input p-host-code,
    input p-host-code,
    output p-ret ) .
 if p-ret = no then return.
p-rec-id = ? .
 create ub.fin-ob.
 assign
   ub.fin-ob.host-code     =     p-host-code
   ub.fin-ob.doc-code      =     p-doc-code
   ub.fin-ob.status_       =     p-status_
   ub.fin-ob.doc-date      =     p-doc-date
   ub.fin-ob.doc-type      =     p-doc-type
   ub.fin-ob.payer-name    =     p-payer-name
   ub.fin-ob.receiver-name =     p-receiver-name
   ub.fin-ob.curr-code     =     p-curr-code
   ub.fin-ob.user-db-num-doc =   p-user-db-num-doc
   ub.fin-ob.user-name-doc   =   p-user-name-doc
   ub.fin-ob.base-rate     =     p-base-rate
   ub.fin-ob.base-scale    =     p-base-scale
   ub.fin-ob.receiver-code =     p-receiver-code
   ub.fin-ob.receiver-type =     p-receiver-type
   ub.fin-ob.contract-code =     p-contract-code
   ub.fin-ob.exch-rate     =     p-exch-rate
   ub.fin-ob.exch-scale    =     p-exch-scale
   ub.fin-ob.contract-curr =     p-contract-curr
   ub.fin-ob.contract-rate =     p-contract-rate
   ub.fin-ob.contract-scale =    p-contract-scale
   ub.fin-ob.fact-date     =     p-fact-date
   ub.fin-ob.fact-order    =     p-fact-order
   ub.fin-ob.host-code     =     p-host-code
   ub.fin-ob.payer-code    =     p-payer-code
   ub.fin-ob.payer-type    =     p-payer-type
   ub.fin-ob.pay-date      =     p-pay-date
   ub.fin-ob.prn-doc-code  =     p-prn-doc-code
   ub.fin-ob.status_       =     p-status_
   ub.fin-ob.sum-doc       =     p-sum-doc
   ub.fin-ob.sum-base      =     p-sum-base
   ub.fin-ob.sum-contract  =     p-sum-contract
   ub.fin-ob.sum-rubl      =     p-sum-rubl
   ub.fin-ob.sum-tax-doc   =     p-sum-tax-doc
   ub.fin-ob.sum-tax-base  =     p-sum-tax-base
   ub.fin-ob.sum-tax-contract =  p-sum-tax-contract
   ub.fin-ob.sum-tax-rubl  =     p-sum-tax-rubl
   ub.fin-ob.sum-doc-orig  =     p-sum-doc-orig
   ub.fin-ob.sum-rubl-orig =     p-sum-rubl-orig
   ub.fin-ob.sum-base-orig =     p-sum-base-orig
   ub.fin-ob.trn-doc-code  =     p-trn-doc-code
   ub.fin-ob.user-db-num-fact =  p-user-db-num-fact
   ub.fin-ob.user-db-num-pay  =  p-user-db-num-pay
   ub.fin-ob.user-name-fact   =  p-user-name-fact
   ub.fin-ob.user-name-pay    =  p-user-name-pay
   ub.fin-ob.in-type          =  p-in-type
   ub.fin-ob.ps               =  p-PS
  no-error .
  if error-status :error then do:
      message vss-include-info6 skip
              error-status :get-message(1)
              view-as alert-box error .
      return error .
  end.
  if ub.fin-ob.status_ = 'факт':U then
    run str/calc-bal.p (input "finob", input yes, input ub.fin-ob.doc-type, input ub.fin-ob.host-code, input ub.fin-ob.contract-code, input ub.fin-ob.sum-contract, input ub.fin-ob.sum-rubl, input ub.fin-ob.sum-base) .
  p-rec-id = recid(fin-ob) .
 end.
end procedure.
procedure create-fin-ob-before :
 do
 on error undo, return error return-value
 :
define input parameter p-ver as logical no-undo .
define input parameter p-doc-id              like ub.fin-ob-before.before-code             no-undo .
define input parameter p-doc-code            like ub.fin-ob.doc-code             no-undo .
define input parameter p-doc-date            like ub.fin-ob.doc-date             no-undo .
define input parameter p-doc-type            like ub.fin-ob.doc-type             no-undo .
define input parameter p-payer-name            like ub.fin-ob.payer-name             no-undo .
define input parameter p-receiver-name            like ub.fin-ob.receiver-name             no-undo .
define input parameter p-curr-code           like ub.fin-ob.curr-code            no-undo .
define input parameter p-sum-doc             like ub.fin-ob.sum-doc              no-undo .
define input parameter p-user-db-num-doc     like ub.fin-ob.user-db-num-doc      no-undo .
define input parameter p-user-name-doc       like ub.fin-ob.user-name-doc        no-undo .
define input parameter p-base-rate           like ub.fin-ob.base-rate            no-undo .
define input parameter p-base-scale          like ub.fin-ob.base-scale           no-undo .
define input parameter p-receiver-code            like ub.fin-ob.receiver-code             no-undo .
define input parameter p-receiver-type            like ub.fin-ob.receiver-type             no-undo .
define input parameter p-contract-code       like ub.fin-ob.contract-code        no-undo .
define input parameter p-exch-rate           like ub.fin-ob.exch-rate            no-undo .
define input parameter p-exch-scale          like ub.fin-ob.exch-scale           no-undo .
define input parameter p-contract-curr           like ub.fin-ob.contract-curr            no-undo .
define input parameter p-contract-rate           like ub.fin-ob.contract-rate            no-undo .
define input parameter p-contract-scale          like ub.fin-ob.contract-scale           no-undo .
define input parameter p-fact-date           like ub.fin-ob.fact-date            no-undo .
define input parameter p-fact-order          like ub.fin-ob.fact-order           no-undo .
define input parameter p-host-code           like ub.fin-ob.host-code            no-undo .
define input parameter p-payer-code          like ub.fin-ob.payer-code           no-undo .
define input parameter p-payer-type          like ub.fin-ob.payer-type           no-undo .
define input parameter p-pay-date            like ub.fin-ob.pay-date             no-undo .
define input parameter p-prn-doc-code        like ub.fin-ob.prn-doc-code         no-undo .
define input parameter p-status_             like ub.fin-ob.status_              no-undo .
define input parameter p-sum-base-orig       like ub.fin-ob.sum-base-orig        no-undo .
define input parameter p-sum-base            like ub.fin-ob.sum-base             no-undo .
define input parameter p-sum-doc-orig        like ub.fin-ob.sum-doc-orig         no-undo .
define input parameter p-sum-rubl-orig       like ub.fin-ob.sum-rubl-orig        no-undo .
define input parameter p-sum-rubl            like ub.fin-ob.sum-rubl             no-undo .
define input parameter p-sum-contract        like ub.fin-ob.sum-contract         no-undo .
define input parameter p-trn-doc-code        like ub.fin-ob.trn-doc-code         no-undo .
define input parameter p-trn-doc-code-orig   like ub.fin-ob.trn-doc-code         no-undo .
define input parameter p-user-db-num-fact    like ub.fin-ob.user-db-num-fact     no-undo .
define input parameter p-user-db-num-pay     like ub.fin-ob.user-db-num-pay     no-undo .
define input parameter p-user-name-fact      like ub.fin-ob.user-name-fact       no-undo .
define input parameter p-user-name-pay       like ub.fin-ob.user-name-pay       no-undo .
define input parameter p-in-type             like ub.fin-ob.in-type              no-undo .
define input parameter p-sum-tax-base         like ub.fin-ob.sum-tax-base     no-undo .
define input parameter p-sum-tax-doc          like ub.fin-ob.sum-tax-doc      no-undo .
define input parameter p-sum-tax-rubl         like ub.fin-ob.sum-tax-rubl     no-undo .
define input parameter p-sum-tax-contract     like ub.fin-ob.sum-tax-contract no-undo .
define input parameter p-ps                   like ub.fin-ob.ps               no-undo .
define output parameter p-rec-id as recid no-undo .
define buffer buf_file for ub.fin-ob-before .
if p-ver then do:
    find first  buf_file no-lock  where buf_file.host-code = p-host-code and
                                        buf_file.doc-code  = p-doc-code  and
                                        buf_file.before-code =  p-doc-id
                                        no-error .
    if available buf_file then return error .
end.
define variable p-ret as logical no-undo .
run current-db in this-procedure  (
    input p-host-code,
    input p-host-code,
    output p-ret ) .
 if p-ret = no then return.
p-rec-id = ? .
 create ub.fin-ob-before.
 assign
   ub.fin-ob-before.before-code   =  p-doc-id
   ub.fin-ob-before.host-code     =     p-host-code
   ub.fin-ob-before.doc-code      =     p-doc-code
   ub.fin-ob-before.status_       =     p-status_
   ub.fin-ob-before.doc-date      =     p-doc-date
   ub.fin-ob-before.doc-type      =     p-doc-type
   ub.fin-ob-before.payer-name    =     p-payer-name
   ub.fin-ob-before.receiver-name =     p-receiver-name
   ub.fin-ob-before.curr-code     =     p-curr-code
   ub.fin-ob-before.user-db-num-doc =   p-user-db-num-doc
   ub.fin-ob-before.user-name-doc   =   p-user-name-doc
   ub.fin-ob-before.base-rate     =     p-base-rate
   ub.fin-ob-before.base-scale    =     p-base-scale
   ub.fin-ob-before.receiver-code =     p-receiver-code
   ub.fin-ob-before.receiver-type =     p-receiver-type
   ub.fin-ob-before.contract-code =     p-contract-code
   ub.fin-ob-before.exch-rate     =     p-exch-rate
   ub.fin-ob-before.exch-scale    =     p-exch-scale
   ub.fin-ob-before.contract-curr =     p-contract-curr
   ub.fin-ob-before.contract-rate =     p-contract-rate
   ub.fin-ob-before.contract-scale =    p-contract-scale
   ub.fin-ob-before.fact-date     =     p-fact-date
   ub.fin-ob-before.fact-order    =     p-fact-order
   ub.fin-ob-before.host-code     =     p-host-code
   ub.fin-ob-before.payer-code    =     p-payer-code
   ub.fin-ob-before.payer-type    =     p-payer-type
   ub.fin-ob-before.pay-date      =     p-pay-date
   ub.fin-ob-before.prn-doc-code  =     p-prn-doc-code
   ub.fin-ob-before.status_       =     p-status_
   ub.fin-ob-before.sum-doc       =     p-sum-doc
   ub.fin-ob-before.sum-base      =     p-sum-base
   ub.fin-ob-before.sum-contract  =     p-sum-contract
   ub.fin-ob-before.sum-rubl      =     p-sum-rubl
   ub.fin-ob-before.sum-tax-doc   =     p-sum-tax-doc
   ub.fin-ob-before.sum-tax-base  =     p-sum-tax-base
   ub.fin-ob-before.sum-tax-contract =  p-sum-tax-contract
   ub.fin-ob-before.sum-tax-rubl  =     p-sum-tax-rubl
   ub.fin-ob-before.sum-doc-orig  =     p-sum-doc-orig
   ub.fin-ob-before.sum-rubl-orig =     p-sum-rubl-orig
   ub.fin-ob-before.sum-base-orig =     p-sum-base-orig
   ub.fin-ob-before.trn-doc-code  =     p-trn-doc-code
   ub.fin-ob-before.trn-doc-code-orig  =     p-trn-doc-code-orig
   ub.fin-ob-before.user-db-num-fact =  p-user-db-num-fact
   ub.fin-ob-before.user-db-num-pay  =  p-user-db-num-pay
   ub.fin-ob-before.user-name-fact   =  p-user-name-fact
   ub.fin-ob-before.user-name-pay    =  p-user-name-pay
   ub.fin-ob-before.in-type          =  p-in-type
   ub.fin-ob-before.ps               =  p-ps
  no-error .
  if error-status :error then do:
      message vss-include-info6 skip
              error-status :get-message(1)
              view-as alert-box error .
      return error .
  end.
  p-rec-id = recid(fin-ob-before) .
 end.
end procedure.
procedure make-tax :
 do
 on error undo, return error return-value
 :
define input parameter p-doc-code  like ub.fin-ob.doc-code no-undo .
define input parameter p-host-code as integer no-undo .
define buffer buf_fin-gds-part for  ub.fin-gds-part .
define buffer buf_fin-ob-tax   for  ub.fin-ob-tax .
define buffer buf_fin-ob       for  ub.fin-ob     .
define variable v-line              as integer no-undo .
define variable v-sum               as decimal no-undo .
define variable v-sum-rubl          as decimal no-undo .
define variable v-sum-base          as decimal no-undo .
define variable v-sum-contract      as decimal no-undo .
define variable v-sum-slt           as decimal no-undo .
define variable v-sum-rubl-slt      as decimal no-undo .
define variable v-sum-base-slt      as decimal no-undo .
define variable v-sum-contract-slt  as decimal no-undo .
define variable v-sum-vat           as decimal no-undo .
define variable v-sum-rubl-vat      as decimal no-undo .
define variable v-sum-base-vat      as decimal no-undo .
define variable v-sum-contract-vat  as decimal no-undo .
define variable v-tax-sum           as decimal no-undo .
define variable v-tax-sum-rubl      as decimal no-undo .
define variable v-tax-sum-base      as decimal no-undo .
define variable v-tax-sum-contr     as decimal no-undo .
define variable v-tax-sum-doc       as decimal no-undo .
define variable var-doc             as decimal no-undo .
define variable var-doc-slt         as decimal no-undo .
define variable var-doc-vat         as decimal no-undo .
define variable v-basecode as integer no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-basecode
  )  .
for each buf_fin-ob  exclusive-lock  where  buf_fin-ob.host-code = p-host-code and
                                            buf_fin-ob.doc-code  = p-doc-code
                                            on error undo, return error :
   assign
    v-tax-sum-rubl  = 0
    v-tax-sum-base  = 0
    v-tax-sum-contr = 0
    v-tax-sum-doc   = 0
    v-sum           = 0
    v-sum-rubl      = 0
    v-sum-base      = 0
    v-sum-contract  = 0
    v-sum-vat       = 0
    v-sum-rubl-vat  = 0
    v-sum-base-vat  = 0
    v-sum-contract-vat  = 0
    v-sum-slt           = 0
    v-sum-rubl-slt      = 0
    v-sum-base-slt      = 0
    v-sum-contract-slt  = 0
    v-line = 0
    .
    for each buf_fin-gds-part no-lock where
             buf_fin-gds-part.host-code   = buf_fin-ob.host-code and
             buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code
             break  by buf_fin-gds-part.SLT-pc
                    by buf_fin-gds-part.vat-pc
             on error undo, return error :
              case buf_fin-ob.curr-code:
                when 0 then do :
                assign
                var-doc      =  buf_fin-gds-part.sum-rubl
                var-doc-slt  =  buf_fin-gds-part.slt-rubl
                var-doc-vat  =  buf_fin-gds-part.vat-rubl
                .
                end.
                when v-basecode then do :
                assign
                var-doc      =  buf_fin-gds-part.sum-base
                var-doc-slt  =  buf_fin-gds-part.slt-base
                var-doc-vat  =  buf_fin-gds-part.vat-base
                .
                end.
                when buf_fin-ob.contract-curr then do :
                assign
                var-doc      =  buf_fin-gds-part.sum-contract
                var-doc-slt  =  buf_fin-gds-part.slt-contract
                var-doc-vat  =  buf_fin-gds-part.vat-contract
                .
                end.
              end case.
             assign
               v-sum           = v-sum          + var-doc
               v-sum-rubl      = v-sum-rubl     + buf_fin-gds-part.sum-rubl
               v-sum-base      = v-sum-base     + buf_fin-gds-part.sum-base
               v-sum-contract  = v-sum-contract + buf_fin-gds-part.sum-contract
               v-sum-slt           = v-sum-slt          + var-doc-slt
               v-sum-rubl-slt      = v-sum-rubl-slt     + buf_fin-gds-part.slt-rubl
               v-sum-base-slt      = v-sum-base-slt     + buf_fin-gds-part.slt-base
               v-sum-contract-slt  = v-sum-contract-slt + buf_fin-gds-part.slt-contract
               v-sum-vat           = v-sum-vat          + var-doc-vat
               v-sum-rubl-vat      = v-sum-rubl-vat     + buf_fin-gds-part.vat-rubl
               v-sum-base-vat      = v-sum-base-vat     + buf_fin-gds-part.vat-base
               v-sum-contract-vat  = v-sum-contract-vat + buf_fin-gds-part.vat-contract
             .
             if last-of(buf_fin-gds-part.vat-pc) then do:
                v-line = v-line + 1.
                create buf_fin-ob-tax.
                assign
                    buf_fin-ob-tax.doc-code           = buf_fin-ob.doc-code
                    buf_fin-ob-tax.host-code          = buf_fin-ob.host-code
                    buf_fin-ob-tax.line-num           = v-line
                    buf_fin-ob-tax.slt-pc             = buf_fin-gds-part.slt-pc
                    buf_fin-ob-tax.vat-pc             = buf_fin-gds-part.vat-pc
                    buf_fin-ob-tax.with-slt           = true
                    buf_fin-ob-tax.with-vat           = true
                    buf_fin-ob-tax.sum-line-rubl      = v-sum-rubl
                    buf_fin-ob-tax.sum-slt-line-rubl  = v-sum-rubl-slt
                    buf_fin-ob-tax.sum-vat-line-rubl  = v-sum-rubl-vat
                    buf_fin-ob-tax.sum-line-base       = v-sum-base
                    buf_fin-ob-tax.sum-line-contr      = v-sum-contract
                    buf_fin-ob-tax.sum-line-doc        = v-sum
                    buf_fin-ob-tax.sum-slt-line-base    = v-sum-base-slt
                    buf_fin-ob-tax.sum-slt-line-contr   = v-sum-contract-slt
                    buf_fin-ob-tax.sum-slt-line-doc     = v-sum-slt
                    buf_fin-ob-tax.sum-vat-line-base    = v-sum-base-vat
                    buf_fin-ob-tax.sum-vat-line-contr   = v-sum-contract-vat
                    buf_fin-ob-tax.sum-vat-line-doc     = v-sum-vat
                    .
                    assign
                        buf_fin-ob-tax.with-slt-orig            = buf_fin-ob-tax.with-slt
                        buf_fin-ob-tax.slt-pc-orig              = buf_fin-ob-tax.slt-pc
                        buf_fin-ob-tax.vat-pc-orig              = buf_fin-ob-tax.vat-pc
                        buf_fin-ob-tax.sum-slt-line-doc-orig    = buf_fin-ob-tax.sum-slt-line-doc
                        buf_fin-ob-tax.sum-slt-line-base-orig   = buf_fin-ob-tax.sum-slt-line-base
                        buf_fin-ob-tax.sum-slt-line-contr-orig  = buf_fin-ob-tax.sum-slt-line-contr
                        buf_fin-ob-tax.sum-slt-line-rubl-orig   = buf_fin-ob-tax.sum-slt-line-rubl
                        buf_fin-ob-tax.with-vat-orig            = buf_fin-ob-tax.with-vat
                        buf_fin-ob-tax.sum-vat-line-doc-orig    = buf_fin-ob-tax.sum-vat-line-doc
                        buf_fin-ob-tax.sum-vat-line-base-orig   = buf_fin-ob-tax.sum-vat-line-base
                        buf_fin-ob-tax.sum-vat-line-contr-orig  = buf_fin-ob-tax.sum-vat-line-contr
                        buf_fin-ob-tax.sum-vat-line-rubl-orig   = buf_fin-ob-tax.sum-vat-line-rubl
                    .
                    assign
                       v-tax-sum-rubl   = v-tax-sum-rubl  + v-sum-rubl-slt  + v-sum-rubl-vat
                       v-tax-sum-base   = v-tax-sum-base  + v-sum-base-slt  + v-sum-base-vat
                       v-tax-sum-contr  = v-tax-sum-contr + v-sum-contract-slt + v-sum-contract-vat
                       v-tax-sum-doc    = v-tax-sum-doc   + v-sum-slt   + v-sum-vat
                    .
                    assign
                    v-sum  = 0
                    v-sum-rubl      = 0
                    v-sum-base      = 0
                    v-sum-contract  = 0
                    v-sum-slt           =0
                    v-sum-rubl-slt      =0
                    v-sum-base-slt      =0
                    v-sum-contract-slt  =0
                    v-sum-vat           =0
                    v-sum-rubl-vat      =0
                    v-sum-base-vat      =0
                    v-sum-contract-vat  =0
                    .
              end.
    end.
    assign
      buf_fin-ob.sum-tax-doc      = v-tax-sum-doc
      buf_fin-ob.sum-tax-rubl     = v-tax-sum-rubl
      buf_fin-ob.sum-tax-base     = v-tax-sum-base
      buf_fin-ob.sum-tax-contract = v-tax-sum-contr
      buf_fin-ob.base-rate        = if buf_fin-ob.base-rate <> 0 then buf_fin-ob.base-rate else round ( buf_fin-ob.sum-rubl / buf_fin-ob.sum-base , 4)
      buf_fin-ob.exch-rate        = round ( buf_fin-ob.sum-rubl / buf_fin-ob.sum-doc  , 4)
      buf_fin-ob.contract-rate    = round ( buf_fin-ob.sum-rubl / buf_fin-ob.sum-contract , 4)
      buf_fin-ob.base-scale       = 1
      buf_fin-ob.exch-scale       = 1
      buf_fin-ob.contract-scale   = 1
    .
    assign
    v-tax-sum-rubl  = 0
    v-tax-sum-base  = 0
    v-tax-sum-contr = 0
    v-tax-sum-doc   = 0
    v-sum-vat          = 0
    v-sum-rubl-vat     = 0
    v-sum-base-vat     = 0
    v-sum-contract-vat    = 0
    v-sum-slt          = 0
    v-sum-rubl-slt     = 0
    v-sum-base-slt     = 0
    v-sum-contract-slt    = 0
    .
end.
 end.
end procedure.
procedure update-fin-ob_obj :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-code  like ub.fin-ob.doc-code no-undo .
define input parameter p-host-code as integer no-undo .
define buffer buf_fin-gds-part for  ub.fin-gds-part .
define buffer buf_fin-ob       for  ub.fin-ob     .
define variable v-obj-code as integer no-undo init 0 .
define variable v-obj-type as character no-undo init "" .
define variable var-fin-calc as integer no-undo .
find first ub.sysconf no-lock where ub.sysconf.host-code = p-host-code no-error .
var-fin-calc = ub.sysconf.fin-calc   .
if var-fin-calc = 0 then return.
for each buf_fin-ob  exclusive-lock  where  buf_fin-ob.host-code = p-host-code and
                                            buf_fin-ob.doc-code = p-doc-code
                                            on error undo, return error :
    for each buf_fin-gds-part no-lock where
             buf_fin-gds-part.host-code   = buf_fin-ob.host-code and
             buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code
             on error undo, return error :
          assign
             v-obj-code  =  buf_fin-gds-part.obj-code
             v-obj-type  =  buf_fin-gds-part.obj-type
             .
           leave.
    end.
    assign
      buf_fin-ob.obj-code  =   v-obj-code
      buf_fin-ob.obj-type  =   v-obj-type
    .
end.
 end.
end procedure.
procedure make-tax-rubl :
 do
 on error undo, return error return-value
 :
define input parameter p-doc-code like ub.fin-ob.doc-code no-undo .
define input parameter p-host-code as integer no-undo .
define buffer buf_fin-gds-part for  ub.fin-gds-part .
define buffer buf_fin-ob-tax   for  ub.fin-ob-tax .
define buffer buf_fin-ob       for  ub.fin-ob     .
define variable v-line    as integer no-undo .
define variable v-sum         as decimal no-undo .
define variable v-tax-sum       as decimal no-undo .
define variable v-tax-sum-rubl  as decimal no-undo .
define variable v-tax-sum-base  as decimal no-undo .
define variable v-tax-sum-contr as decimal no-undo .
define variable v-tax-sum-doc   as decimal no-undo .
for each buf_fin-ob  exclusive-lock  where  buf_fin-ob.host-code = p-host-code and
                                            buf_fin-ob.doc-code = p-doc-code
                                            on error undo, return error :
   assign
    v-tax-sum-rubl = 0
    v-tax-sum-base = 0
    v-tax-sum-contr = 0
    v-tax-sum-doc  = 0
    v-sum          = 0
    v-line = 0
    .
    for each buf_fin-gds-part no-lock where
             buf_fin-gds-part.host-code   = buf_fin-ob.host-code and
             buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code
             break  by buf_fin-gds-part.SLT-pc
                    by buf_fin-gds-part.vat-pc
             on error undo, return error :
             assign
               v-sum       = v-sum + buf_fin-gds-part.sum-rubl
             .
             if last-of(buf_fin-gds-part.vat-pc) then do:
                v-line = v-line + 1.
                create buf_fin-ob-tax.
                assign
                    buf_fin-ob-tax.doc-code           = buf_fin-ob.doc-code
                    buf_fin-ob-tax.host-code          = buf_fin-ob.host-code
                    buf_fin-ob-tax.line-num           = v-line
                    buf_fin-ob-tax.slt-pc             = buf_fin-gds-part.slt-pc
                    buf_fin-ob-tax.vat-pc             = buf_fin-gds-part.vat-pc
                    buf_fin-ob-tax.with-slt           = true
                    buf_fin-ob-tax.with-vat           = true
                    buf_fin-ob-tax.sum-line-rubl      = v-sum
                    buf_fin-ob-tax.sum-slt-line-rubl  = buf_fin-ob-tax.slt-PC *  buf_fin-ob-tax.sum-line-rubl  / ( 100 + buf_fin-ob-tax.slt-PC )
                    buf_fin-ob-tax.sum-vat-line-rubl  = buf_fin-ob-tax.vat-PC * (( buf_fin-ob-tax.sum-line-rubl  - buf_fin-ob-tax.sum-slt-line-rubl  ) / ( 100  + buf_fin-ob-tax.vat-PC))
                    buf_fin-ob-tax.sum-line-base       = ( buf_fin-ob.base-scale     / buf_fin-ob.base-rate)     * buf_fin-ob-tax.sum-line-rubl
                    buf_fin-ob-tax.sum-line-doc        = ( buf_fin-ob.exch-scale     / buf_fin-ob.exch-rate)     * buf_fin-ob-tax.sum-line-rubl
                    buf_fin-ob-tax.sum-line-contr      = ( buf_fin-ob.contract-scale / buf_fin-ob.contract-rate) * buf_fin-ob-tax.sum-line-rubl
                    buf_fin-ob-tax.sum-slt-line-base    = ( buf_fin-ob.base-scale     / buf_fin-ob.base-rate)     * buf_fin-ob-tax.sum-slt-line-rubl
                    buf_fin-ob-tax.sum-slt-line-doc     = ( buf_fin-ob.exch-scale     / buf_fin-ob.exch-rate)     * buf_fin-ob-tax.sum-slt-line-rubl
                    buf_fin-ob-tax.sum-slt-line-contr   = ( buf_fin-ob.contract-scale / buf_fin-ob.contract-rate) * buf_fin-ob-tax.sum-slt-line-rubl
                    buf_fin-ob-tax.sum-vat-line-base    = ( buf_fin-ob.base-scale     / buf_fin-ob.base-rate)     * buf_fin-ob-tax.sum-vat-line-rubl
                    buf_fin-ob-tax.sum-vat-line-doc     = ( buf_fin-ob.exch-scale     / buf_fin-ob.exch-rate)     * buf_fin-ob-tax.sum-vat-line-rubl
                    buf_fin-ob-tax.sum-vat-line-contr   = ( buf_fin-ob.contract-scale / buf_fin-ob.contract-rate) * buf_fin-ob-tax.sum-vat-line-rubl
                    .
                    assign
                        buf_fin-ob-tax.with-slt-orig            = buf_fin-ob-tax.with-slt
                        buf_fin-ob-tax.slt-pc-orig              = buf_fin-ob-tax.slt-pc
                        buf_fin-ob-tax.vat-pc-orig              = buf_fin-ob-tax.vat-pc
                        buf_fin-ob-tax.sum-slt-line-doc-orig    = buf_fin-ob-tax.sum-slt-line-doc
                        buf_fin-ob-tax.sum-slt-line-base-orig   = buf_fin-ob-tax.sum-slt-line-base
                        buf_fin-ob-tax.sum-slt-line-contr-orig  = buf_fin-ob-tax.sum-slt-line-contr
                        buf_fin-ob-tax.sum-slt-line-rubl-orig   = buf_fin-ob-tax.sum-slt-line-rubl
                        buf_fin-ob-tax.with-vat-orig            = buf_fin-ob-tax.with-vat
                        buf_fin-ob-tax.sum-vat-line-doc-orig    = buf_fin-ob-tax.sum-vat-line-doc
                        buf_fin-ob-tax.sum-vat-line-base-orig   = buf_fin-ob-tax.sum-vat-line-base
                        buf_fin-ob-tax.sum-vat-line-contr-orig  = buf_fin-ob-tax.sum-vat-line-contr
                        buf_fin-ob-tax.sum-vat-line-rubl-orig   = buf_fin-ob-tax.sum-vat-line-rubl
                    .
                    assign
                       v-tax-sum-rubl   = v-tax-sum-rubl  + buf_fin-ob-tax.sum-slt-line-rubl  + buf_fin-ob-tax.sum-vat-line-rubl
                       v-tax-sum-base   = v-tax-sum-base  + buf_fin-ob-tax.sum-slt-line-base  + buf_fin-ob-tax.sum-vat-line-base
                       v-tax-sum-contr  = v-tax-sum-contr + buf_fin-ob-tax.sum-slt-line-contr + buf_fin-ob-tax.sum-vat-line-contr
                       v-tax-sum-doc    = v-tax-sum-doc   + buf_fin-ob-tax.sum-slt-line-doc   + buf_fin-ob-tax.sum-vat-line-doc
                    .
                    v-sum  = 0 .
              end.
    end.
    buf_fin-ob.sum-tax-doc   = v-tax-sum-doc   .
    buf_fin-ob.sum-tax-rubl  = v-tax-sum-rubl  .
    buf_fin-ob.sum-tax-base  = v-tax-sum-base  .
    buf_fin-ob.sum-tax-contract = v-tax-sum-contr .
    v-tax-sum-rubl  = 0 .
    v-tax-sum-base  = 0 .
    v-tax-sum-contr = 0 .
    v-tax-sum-doc   = 0 .
end.
 end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-1 :handle
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of loc_pay-date in frame Dialog-Frame
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
on delete-character of loc_pay-date in frame Dialog-Frame
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
on ctrl-d of loc_pay-date in frame Dialog-Frame
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
on ctrl-b of loc_pay-date in frame Dialog-Frame
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
on ctrl-e of loc_pay-date in frame Dialog-Frame
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
on ctrl-f of loc_pay-date in frame Dialog-Frame
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
  define MENU m-ed-date12
    MENU-ITEM m-ed-date12-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date12-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date12-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date12-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if loc_pay-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      loc_pay-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date12 :HANDLE
      loc_pay-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle12 as handle no-undo .
  assign
    v-label-handle12 = loc_pay-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle12)
  then do:
    if v-label-handle12 :tooltip = ""
    or v-label-handle12 :tooltip = ?
    then do:
      assign
        v-label-handle12 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date12-1 in menu m-ed-date12 DO:
    apply "ctrl-b":U to loc_pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-2 in menu m-ed-date12 DO:
    apply "ctrl-d":U to loc_pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-3 in menu m-ed-date12 DO:
    apply "ctrl-e":U to loc_pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-4 in menu m-ed-date12 DO:
    apply "ctrl-f":U to loc_pay-date in frame Dialog-Frame .
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
next-prev = yes.
n-p: do while next-prev :
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   run init-p in this-procedure .
     if ref-mode = 'ПРОСМОТР':U then do:
        run myenable_lkp in this-procedure .
        run hide-curr in this-procedure ( input "lookup":u ) .
        wait-for go of frame Dialog-Frame focus b-exit.
     end.
     else do:
        run myenable_chg.
        if ref-mode = 'ДОБАВЛЕНИЕ':U
            then do:
                 run hide-curr ( input "init":u ) .
                 wait-for go of frame Dialog-Frame focus loc_prn-doc-code .
            end.
            else do:
                 run hide-curr ( input "pay":u ) .
                 wait-for go of frame Dialog-Frame focus loc_contract-code .
            end.
   end.
END.
end.
RUN disable_UI.
PROCEDURE attr-bank :
 do
 on error undo, return error return-value
 :
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define input parameter p-curr-code as integer no-undo .
define output parameter   p-bank-name   like ub.fin-bank.bank-name   no-undo .
define output parameter   p-bik         like ub.fin-bank.bik         no-undo .
define output parameter   p-c-schet     like ub.fin-schet.c-schet    no-undo .
define output parameter   p-r-schet     like ub.fin-schet.r-schet    no-undo .
define output parameter   p-code-schet  like ub.fin-schet.code-schet no-undo .
define variable v-rid-list as character no-undo.
define variable ref-rec as recid no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo init 'тек':U.
define buffer buf_fin-schet for ub.fin-schet .
define buffer buf_fin-bank for fin-bank.
run ref/finschts.w (
              INPUT parParentProc
              ,par-host-code
              ,input "b-sel":U
              ,input "cmp-host":U
              ,input p-cli-type
              ,input p-cli-code
              ,input p-curr-code
              ,input par-host-code
              ,input 0
              ,input-output v-status_
              ,input-output v-rid-list
) no-error.
if v-rid-list = "" then   do:
  return .
end.
 ref-rec = integer( v-rid-list ).
FIND FIRST buf_fin-schet no-lock  WHERE
      recid (buf_fin-schet) = ref-rec no-error .
      if error-status :error then return.
if buf_fin-schet.curr-code <> p-curr-code then do:
  message
  "Валюта выбранного Вами счета"  "не совпадает с валютой платежа"
  view-as alert-box information  .
end.
if buf_fin-schet.status_ <> 'тек':U then do:
  message
  "Статус выбранного Вами счета"  buf_fin-schet.status_ " - нельзя работать с таким счетом"
  view-as alert-box error .
  return error.
end.
find first buf_fin-bank no-lock where
          buf_fin-bank.host-code = par-host-code
      AND buf_fin-bank.code-bank = buf_fin-schet.code-bank no-error .
  if available buf_fin-bank and available buf_fin-schet then
  assign
    p-bank-name =  buf_fin-bank.bank-name
    p-bik       =  buf_fin-bank.bik
    p-c-schet   =  buf_fin-schet.c-schet
    p-r-schet   =  buf_fin-schet.r-schet
    p-code-schet = buf_fin-schet.code-schet
  .
  end.
END PROCEDURE.
PROCEDURE attr-bank-code-schet :
do
 on error undo, return error return-value
 :
define input-output parameter par-code-schet as integer no-undo .
define input parameter par-code-schet-start as integer no-undo .
define output parameter par-bank-name as character no-undo .
define output parameter par-bik        like   fin-bank.bik       no-undo .
define output parameter par-c-schet    like   fin-schet.c-schet  no-undo .
define output parameter par-r-schet    like   fin-schet.r-schet  no-undo .
define buffer buf_fin-schet for fin-schet.
define buffer buf_fin-bank  for fin-bank.
FIND FIRST buf_fin-schet no-lock  WHERE
      buf_fin-schet.code-schet = par-code-schet and
      buf_fin-schet.host-code  = par-host-code  no-error .
if not available buf_fin-schet then do:
    FIND FIRST buf_fin-schet no-lock  WHERE
          buf_fin-schet.code-schet = par-code-schet-start and
          buf_fin-schet.host-code  = par-host-code  no-error .
  if error-status :error then return.
end.
 par-code-schet = buf_fin-schet.code-schet .
find first buf_fin-bank no-lock where
          buf_fin-bank.host-code = par-host-code
      AND buf_fin-bank.code-bank = buf_fin-schet.code-bank no-error .
  if available buf_fin-bank and available buf_fin-schet then
  assign
    par-bank-name =  buf_fin-bank.bank-name
    par-bik       =  buf_fin-bank.bik
    par-c-schet   =  buf_fin-schet.c-schet
    par-r-schet   =  buf_fin-schet.r-schet
    par-code-schet = buf_fin-schet.code-schet
  .
  end.
END PROCEDURE.
PROCEDURE attr-firm :
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define output parameter p-inn  like ub.firm.inn no-undo .
define output parameter p-kpp  like ub.firm.kpp no-undo .
define output parameter p-okpo like ub.firm.okpo no-undo .
define buffer buf_firm   for firm .
define buffer buf_person for person .
 do
 on error undo, return error return-value
 :
 assign
   p-inn  = ""
   p-kpp  = ""
   p-okpo = ""
 .
 if p-cli-type = 'орг':U then do:
  find first buf_firm no-lock where buf_firm.firm-code = p-cli-code no-error .
  if available buf_firm then
      assign
        p-inn  = buf_firm.inn
        p-kpp  = buf_firm.kpp
        p-okpo = buf_firm.okpo
      .
 end.
 if p-cli-type = 'чел':U then do:
  find first buf_person no-lock where buf_person.psn-code = p-cli-code no-error .
  if available buf_person then
      assign
        p-inn  = buf_person.inn
        p-kpp  = buf_person.kpp
        p-okpo = buf_person.okpo
      .
 end.
  end.
END PROCEDURE.
PROCEDURE calc-tax :
 do
 on error undo, return error return-value
 :
define variable v-nalog  as decimal no-undo .
  v-nalog = 0 .
  for each  tt_fin-ob-tax-before :
     v-nalog = v-nalog + ( tt_fin-ob-tax-before.sum-vat-line-doc + tt_fin-ob-tax-before.sum-slt-line-doc ) .
  end.
  loc_sum-tax-doc       = v-nalog .
  loc_sum-tax-rubl      = (  loc_exch-rate       / loc_exch-scale   ) * loc_sum-tax-doc  .
  loc_sum-tax-base      = (  loc_base-scale      / loc_base-rate    ) * loc_sum-tax-rubl .
  loc_sum-tax-contract  = (  loc_contract-scale  / loc_contract-rate) * loc_sum-tax-rubl .
  display
    loc_sum-tax-doc      when loc_sum-tax-doc:visible
    loc_sum-tax-base     when loc_sum-tax-base     :visible
    loc_sum-tax-rubl     when loc_sum-tax-rubl     :visible
    loc_sum-tax-contract when loc_sum-tax-contract :visible
    with frame Dialog-Frame
    .
  end.
END PROCEDURE.
PROCEDURE chg-radio-mode :
 do
 on error undo, return error return-value
 :
  end.
END PROCEDURE.
PROCEDURE create-tax :
define input parameter  v-sum-doc    as decimal no-undo .
define input parameter  v-sum-rubl   as decimal no-undo .
define input parameter  v-sum-base   as decimal no-undo .
define input parameter  v-sum-contr  as decimal no-undo .
define input parameter  v-type as character no-undo .
define output parameter v-tax  as decimal no-undo .
define variable v-1 as decimal no-undo .
define variable  v-col as integer init 0  no-undo .
define variable v-ok as logical init true no-undo .
define variable v-vat-pc-init as decimal init ? no-undo .
define variable v-slt-pc-init as decimal init ? no-undo .
for each tt_fin-ob-tax-before :
    v-col = v-col + 1 .
    v-vat-pc-init = tt_fin-ob-tax-before.vat-pc .
    v-slt-pc-init = tt_fin-ob-tax-before.slt-pc .
end.
if v-vat-pc-init = ? then v-vat-pc-init = glob-vat-pc .
if v-slt-pc-init = ? then v-slt-pc-init = glob-slt-pc .
    if v-col > 1 then do:
        message "Вы уже ввели больше одной строки по налогам ! "  skip
                "Удалить и создать автоматически новую строку ?" skip "" skip
                "(Иначе Вам придется вручную пересчитать налоги !) "
                view-as alert-box question
                buttons yes-no
                update v-ok .
    end.
    if not v-ok then return .
if v-col = 1 then do:
   find first  tt_fin-ob-tax-before no-error .
end.
if v-col > 1  or v-col = 0 then do:
  for each tt_fin-ob-tax-before : delete tt_fin-ob-tax-before. end.
  v-vat-pc-init = glob-vat-pc .
  v-slt-pc-init = glob-slt-pc .
  create tt_fin-ob-tax-before.
end.
assign
    tt_fin-ob-tax-before.before-code                =  p-doc-code
    tt_fin-ob-tax-before.host-code               =  par-host-code
    tt_fin-ob-tax-before.line-num                =  1
    tt_fin-ob-tax-before.sum-line-doc            = v-sum-doc
    tt_fin-ob-tax-before.sum-line-base           = v-sum-base
    tt_fin-ob-tax-before.sum-line-contr          = v-sum-contr
    tt_fin-ob-tax-before.sum-line-rubl           = v-sum-rubl
    tt_fin-ob-tax-before.with-slt                = true
    tt_fin-ob-tax-before.slt-pc                  = v-slt-pc-init
    tt_fin-ob-tax-before.sum-slt-line-doc        = tt_fin-ob-tax-before.slt-PC *  tt_fin-ob-tax-before.sum-line-doc   / ( 100 + tt_fin-ob-tax-before.slt-PC )
    tt_fin-ob-tax-before.sum-slt-line-base       = tt_fin-ob-tax-before.slt-PC *  tt_fin-ob-tax-before.sum-line-base  / ( 100 + tt_fin-ob-tax-before.slt-PC )
    tt_fin-ob-tax-before.sum-slt-line-contr      = tt_fin-ob-tax-before.slt-PC *  tt_fin-ob-tax-before.sum-line-contr / ( 100 + tt_fin-ob-tax-before.slt-PC )
    tt_fin-ob-tax-before.sum-slt-line-rubl       = tt_fin-ob-tax-before.slt-PC *  tt_fin-ob-tax-before.sum-line-rubl  / ( 100 + tt_fin-ob-tax-before.slt-PC )
    tt_fin-ob-tax-before.with-vat                = true
    tt_fin-ob-tax-before.vat-pc                  = v-vat-pc-init
    tt_fin-ob-tax-before.sum-vat-line-doc        = tt_fin-ob-tax-before.vat-PC * (( tt_fin-ob-tax-before.sum-line-doc   - tt_fin-ob-tax-before.sum-slt-line-doc   ) / ( 100  + tt_fin-ob-tax-before.vat-PC))
    tt_fin-ob-tax-before.sum-vat-line-base       = tt_fin-ob-tax-before.vat-PC * (( tt_fin-ob-tax-before.sum-line-base  - tt_fin-ob-tax-before.sum-slt-line-base  ) / ( 100  + tt_fin-ob-tax-before.vat-PC))
    tt_fin-ob-tax-before.sum-vat-line-contr      = tt_fin-ob-tax-before.vat-PC * (( tt_fin-ob-tax-before.sum-line-contr - tt_fin-ob-tax-before.sum-slt-line-contr ) / ( 100  + tt_fin-ob-tax-before.vat-PC))
    tt_fin-ob-tax-before.sum-vat-line-rubl       = tt_fin-ob-tax-before.vat-PC * (( tt_fin-ob-tax-before.sum-line-rubl  - tt_fin-ob-tax-before.sum-slt-line-rubl  ) / ( 100  + tt_fin-ob-tax-before.vat-PC))
.
case v-type :
when "doc":U then do:
      v-tax = tt_fin-ob-tax-before.sum-slt-line-doc + tt_fin-ob-tax-before.sum-vat-line-doc.
end.
when "rubl":U then do:
      v-tax = tt_fin-ob-tax-before.sum-slt-line-rubl + tt_fin-ob-tax-before.sum-vat-line-rubl.
end.
when "base":U then do:
      v-tax = tt_fin-ob-tax-before.sum-slt-line-base + tt_fin-ob-tax-before.sum-vat-line-base.
end.
when "contract":U then do:
      v-tax = tt_fin-ob-tax-before.sum-slt-line-contr + tt_fin-ob-tax-before.sum-vat-line-contr.
end.
end case.
OPEN QUERY BROWSE-1 FOR EACH tt_fin-ob-tax-before NO-LOCK.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY loc_prn-doc-code loc_contract-code loc_receiver-code loc_payer-code
          loc_exch-rate loc_exch-scale loc_sum-doc loc_sum-tax-doc T-doc
          loc_sum-tax-rubl T-rubl loc_sum-rubl loc_base-rate loc_base-scale
          loc_sum-tax-base T-base loc_sum-base loc_contract-rate
          loc_contract-scale loc_sum-contract loc_sum-tax-contract T-contract
          loc_PS loc_doc-date loc_receiver-type loc_receiver-name f-receiver
          loc_fact-date loc_payer-type loc_payer-name f-payer loc_trn-doc-code
          p-doc-code FILL-IN-4 FILL-IN-5 FILL-IN-6 FILL-IN-7 loc_curr-code
          loc_abbr-doc loc_abbr-rubl loc_abbr-base loc_contract-curr
          loc_abbr-contract f-contract-curr
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-contract B-receiver B-payer B-help RECT-1 RECT-2
         RECT-3 RECT-4 RECT-5 loc_prn-doc-code loc_contract-code r-con
         loc_receiver-code r-cli loc_payer-code r-obj r-cur loc_exch-rate
         loc_exch-scale loc_sum-doc T-doc T-rubl loc_base-rate loc_base-scale
         T-base loc_contract-rate loc_contract-scale loc_sum-contract
         T-contract r-cur-contr BROWSE-1 loc_PS B-ins B-chg B-del loc_doc-date
         loc_receiver-type loc_receiver-name f-receiver loc_fact-date
         loc_payer-type loc_payer-name f-payer loc_trn-doc-code FILL-IN-4
         FILL-IN-5 FILL-IN-6 FILL-IN-7 loc_curr-code loc_abbr-doc loc_abbr-rubl
         loc_abbr-base loc_contract-curr loc_abbr-contract f-contract-curr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH tt_fin-ob-tax-before NO-LOCK.
END PROCEDURE.
PROCEDURE from-contract :
 do
 on error undo, return error return-value
 :
define input parameter p-code like contract.contract-code no-undo .
define input parameter p-host-code like contract.host-code no-undo .
define buffer buf_contract for contract.
define variable loc_payer-code-schet-start    as integer no-undo .
define variable loc_receiver-code-schet-start as integer no-undo .
if loc_contract-code:MODIFIED in frame Dialog-Frame = false then return  .
  find first buf_contract no-lock where buf_contract.contract-code = p-code
                                        and buf_contract.host-code     = p-host-code
                                        no-error .
if error-status :error then do:
   message error-status :get-message(1) "from-contract".
   return error .
   end.
define variable v-num as integer no-undo .
define variable v-buttons as character no-undo .
define variable v-desc as character no-undo .
define variable v-t as character no-undo .
if p-doc-type = 'при':U then assign
  v-t = "Плательщика"
.
else assign
  v-t = "Получателя"
.
v-num = 1.
if not( buf_contract.posr-name = "" and
        buf_contract.agnt-name = "" ) then do:
    v-buttons  = "Контрагент" + "|" +
                (if buf_contract.posr-name <> "" then "Посредник" else "Посредник^disable") + "|" +
                (if buf_contract.agnt-name <> "" then "Агент"     else "Агент^disable" )    + "|" +
                "Отмена"
    .
    v-desc     = buf_contract.cli-name + "|" +
                buf_contract.posr-name + "|" +
                buf_contract.agnt-name + "|" +
                "Не выбираем ни кого"
      .
    run gbl/d-askw.w
      (input "Внимание!"
      ,input "Выберите " + v-t + " по фин.обязательству."
      ,input "|^"
      ,input v-buttons
      ,input v-desc
      ,input 1
      ,input 4
      ,output v-num
      ).
end.
if v-num = 4 then do:
   return error .
end.
  case p-doc-type :
  when 'при':U then do:
   case v-num :
     when 1 then do:
      assign
        loc_payer-code       =  buf_contract.cli-code
        loc_payer-type       =  buf_contract.cli-type
        loc_payer-name       =  buf_contract.cli-name
        .
     end.
     when 2 then do:
      assign
        loc_payer-code       =  buf_contract.posr-code
        loc_payer-type       =  buf_contract.posr-type
        loc_payer-name       =  buf_contract.posr-name
        .
     end.
     when 3 then do:
      assign
        loc_payer-code       =  buf_contract.agnt-code
        loc_payer-type       =  buf_contract.agnt-type
        loc_payer-name       =  buf_contract.agnt-name
        .
     end.
     end case.
       assign
        loc_receiver-code       =  par-host-code
        loc_receiver-type       =  'орг':U
        loc_receiver-name       =  buf_contract.own-name
      .
  end.
  when 'рас':U then do:
     case v-num :
     when 1 then do:
          assign
              loc_receiver-code       =  buf_contract.cli-code
              loc_receiver-type       =  buf_contract.cli-type
              loc_receiver-name       =  buf_contract.cli-name
              .
     end.
     when 2 then do:
          assign
              loc_receiver-code       =  buf_contract.posr-code
              loc_receiver-type       =  buf_contract.posr-type
              loc_receiver-name       =  buf_contract.posr-name
              .
     end.
     when 3 then do:
          assign
              loc_receiver-code       =  buf_contract.agnt-code
              loc_receiver-type       =  buf_contract.agnt-type
              loc_receiver-name       =  buf_contract.agnt-name
              .
     end.
     end case.
        assign
        loc_payer-code       =  par-host-code
        loc_payer-type       =  'орг':U
        loc_payer-name       =  buf_contract.own-name
              .
  end.
  end case.
  assign
    loc_contract-code-id   =  buf_contract.contract-code
    loc_contract-curr      =  buf_contract.curr-code
    .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  loc_contract-curr
  ,input  loc_doc-date
  ,output loc_contract-rate
  ,output loc_contract-scale
  ,output loc_abbr-contract
  )  .
    display
      loc_receiver-code
      loc_receiver-name
      loc_receiver-type
      loc_abbr-contract
      loc_payer-code
      loc_payer-name
      loc_payer-type
      loc_contract-curr
      loc_contract-rate
      loc_contract-scale
    with frame Dialog-Frame .
 apply "LEAVE" to loc_sum-contract in frame Dialog-Frame .
 run hide-curr ( input "contract":U ) .
  end.
END PROCEDURE.
PROCEDURE hide-curr :
 define input parameter p-mode as character no-undo .
 do
 on error undo, return error return-value
 with frame Dialog-Frame :
if loc_curr-code = 0 then do:
  disable loc_exch-rate  loc_exch-scale  .
end.
else do:
  if  p-mode <> "lookup" then
      enable  loc_exch-rate  loc_exch-scale  .
end.
 case p-mode :
 when "init" then do:
      if loc_curr-code = 0 then do:
        hide loc_sum-tax-rubl T-rubl loc_sum-rubl loc_abbr-rubl in frame Dialog-Frame .
      end.
      if p-basecode = 0 then do:
        hide loc_base-rate loc_base-scale loc_sum-tax-base T-base loc_sum-base loc_abbr-base in frame Dialog-Frame .
      end.
      if loc_contract-curr = 0  or
          loc_contract-curr = p-basecode  then do:
          hide loc_contract-rate loc_contract-scale loc_sum-contract loc_sum-tax-contract T-contract r-cur-contr loc_contract-curr loc_abbr-contract f-contract-curr in frame Dialog-Frame .
      end.
 end.
 when "contract" then do:
      if  loc_contract-curr = 0  or
          loc_contract-curr = p-basecode or
          loc_contract-curr = loc_curr-code  then do:
          hide loc_contract-rate loc_contract-scale loc_sum-contract loc_sum-tax-contract T-contract r-cur-contr loc_contract-curr loc_abbr-contract f-contract-curr in frame Dialog-Frame .
      end.
      else do:
         display  loc_contract-rate loc_contract-scale loc_sum-contract loc_sum-tax-contract T-contract r-cur-contr loc_contract-curr loc_abbr-contract f-contract-curr .
         enable   T-contract r-cur-contr .
      end.
 end.
 when "pay" then do:
      if loc_curr-code <> 0 then do:
        display loc_sum-tax-rubl T-rubl loc_sum-rubl loc_abbr-rubl  .
        enable t-rubl .
      end.
      else do:
          hide loc_sum-tax-rubl T-rubl loc_sum-rubl loc_abbr-rubl .
      end.
      if p-basecode = loc_curr-code or
         p-basecode = 0   then do:
        hide loc_base-rate loc_base-scale loc_sum-tax-base T-base loc_sum-base loc_abbr-base in frame Dialog-Frame .
      end.
      else do:
         display  loc_base-rate loc_base-scale loc_sum-tax-base T-base loc_sum-base loc_abbr-base .
         enable   T-base .
      end.
      if  loc_contract-curr = 0  or
          loc_contract-curr = p-basecode or
          loc_contract-curr = loc_curr-code  then do:
          hide loc_contract-rate loc_contract-scale loc_sum-contract loc_sum-tax-contract T-contract r-cur-contr loc_contract-curr loc_abbr-contract f-contract-curr in frame Dialog-Frame .
      end.
      else do:
         display  loc_contract-rate loc_contract-scale loc_sum-contract loc_sum-tax-contract T-contract r-cur-contr loc_contract-curr loc_abbr-contract f-contract-curr .
         enable   T-contract r-cur-contr .
      end.
 end.
 when "lookup" then do:
      if loc_curr-code <> 0 then do:
        display loc_sum-tax-rubl T-rubl loc_sum-rubl loc_abbr-rubl  .
      end.
      else do:
          hide loc_sum-tax-rubl T-rubl loc_sum-rubl loc_abbr-rubl .
      end.
      if p-basecode = loc_curr-code or
         p-basecode = 0   then do:
        hide loc_base-rate loc_base-scale loc_sum-tax-base T-base loc_sum-base loc_abbr-base in frame Dialog-Frame .
      end.
      else do:
         display  loc_base-rate loc_base-scale loc_sum-tax-base T-base loc_sum-base loc_abbr-base .
      end.
      if  loc_contract-curr = 0  or
          loc_contract-curr = p-basecode or
          loc_contract-curr = loc_curr-code  then do:
          hide loc_contract-rate loc_contract-scale loc_sum-contract loc_sum-tax-contract T-contract r-cur-contr loc_contract-curr loc_abbr-contract f-contract-curr in frame Dialog-Frame .
      end.
      else do:
         display  loc_contract-rate loc_contract-scale loc_sum-contract loc_sum-tax-contract T-contract r-cur-contr loc_contract-curr loc_abbr-contract f-contract-curr .
      end.
      hide b-quit in frame Dialog-Frame .
 end.
end case .
  end.
END PROCEDURE.
PROCEDURE init-p :
 do
 on error undo, return error return-value
 :
define buffer buff_contract for contract.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  par-host-code
  ,output p-basecode
  )  .
    find first sysconf no-lock where sysconf.host-code = par-host-code no-error .
    glob-vat-pc = sysconf.fin-vat-pc.
    glob-slt-pc = sysconf.fin-slt-pc.
    define variable g-log as logical no-undo.
    define variable v-view as character no-undo .
    run uf-get in this-procedure(
        input  ('fin-obi':U )
        ,input  g#userid
        ,output v-uf-List_
        ,output v-uf-Naim
        ,output v-uf-print-graft
        ,output v-uf-sort-gr
        ,output v-uf-type-price
        ,output v-uf-type-val
    )  no-error.
    if not error-status:error
    and not v-uf-LIst_ = "":U
    then do:
        assign
        v-view =  entry(1, v-uf-List_, chr(4))
        .
    end.
    if ref-mode =  'ДОБАВЛЕНИЕ':U
        then  do:
            ri = ?.
            run fin-ob-code (input g#db-num , output p-doc-code) .
            assign
                  p-prn-doc-code     = p-doc-code
                  p-host-code        = par-host-code
                  p-doc-date         = today
                  p-status_          = 'новый':U
                  p-payer-name       = ""
                  p-receiver-name    = ""
                  p-payer-code       = 0
                  p-receiver-code    = 0
                  p-payer-type       = 'орг':U
                  p-receiver-type    = 'орг':U
                  p-in-type          = 0
                  p-sum-doc          = 0
                  p-user-db-num-doc  = g#db-num
                  p-user-name-doc    = g#userid
            .
                  define buffer b#clients for clients.
                  find first b#clients WHERE
                        b#clients.obj-code = par-host-code and
                        b#clients.obj-type = 'орг':U
                        No-LOCK No-ERROR.
                  if p-doc-type <> 'при':U then do:
                      if avail b#clients then
                          Assign
                              p-payer-code = b#clients.obj-code
                              p-payer-type = b#clients.obj-type
                              p-payer-name = b#clients.obj-name .
                  end.
                  else do:
                      if avail b#clients then
                          Assign
                              p-receiver-code = b#clients.obj-code
                              p-receiver-type = b#clients.obj-type
                              p-receiver-name = b#clients.obj-name .
                  end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  par-host-code
  ,input  today
  ,output p-base-rate
  ,output p-base-scale
  )  .
              p-curr-code  = 0.
              p-exch-rate  = 1.
              p-exch-scale = 1.
              p-contract-curr  = p-basecode  .
              p-contract-rate  = p-base-rate .
              p-contract-scale = p-base-scale.
            assign
              loc_base-rate          =  p-base-rate
              loc_base-scale         =  p-base-scale
              loc_receiver-code      =  p-receiver-code
              loc_receiver-name      =  p-receiver-name
              loc_receiver-type      =  p-receiver-type
              loc_contract-code-id   =  p-contract-code
              loc_curr-code          =  p-curr-code
              loc_doc-date           =  p-doc-date
              loc_exch-rate          =  p-exch-rate
              loc_exch-scale         =  p-exch-scale
              loc_fact-date          =  p-fact-date
              loc_payer-code         =  p-payer-code
              loc_payer-name         =  p-payer-name
              loc_payer-type         =  p-payer-type
              loc_pay-date           =  p-pay-date
              loc_prn-doc-code       =  p-prn-doc-code
              loc_sum-base           =  p-sum-base
              loc_sum-doc            =  p-sum-doc
              loc_sum-rubl           =  p-sum-rubl
              loc_trn-doc-code       =  p-trn-doc-code
              loc_doc-type           =  p-doc-type
              loc_status_            =  p-status_
              loc_in-type            =  p-in-type
              loc_sum-tax-rubl       =  p-sum-tax-rubl
              loc_sum-tax-base       =  p-sum-tax-base
              loc_sum-tax-doc        =  p-sum-tax-doc
              loc_contract-curr     = p-contract-curr
              loc_contract-rate     = p-contract-rate
              loc_contract-scale    = p-contract-scale
              loc_sum-contract      = p-sum-contract
              loc_sum-tax-contract  = p-sum-tax-contract
              loc_contract-code   = ""
              loc_abbr-contract   = ""
              .
    end.
    else dO:
       find fin-ob-before where recid( fin-ob-before ) = ri no-error .
       if error-status :error then return  error .
            assign
              p-doc-code             =  fin-ob-before.before-code
              loc_base-rate          =  fin-ob-before.base-rate
              loc_base-scale         =  fin-ob-before.base-scale
              loc_receiver-code      =  fin-ob-before.receiver-code
              loc_receiver-name      =  fin-ob-before.receiver-name
              loc_receiver-type      =  fin-ob-before.receiver-type
              loc_contract-code-id   =  fin-ob-before.contract-code
              loc_curr-code          =  fin-ob-before.curr-code
              loc_doc-date           =  fin-ob-before.doc-date
              loc_exch-rate          =  fin-ob-before.exch-rate
              loc_exch-scale         =  fin-ob-before.exch-scale
              loc_fact-date          =  fin-ob-before.fact-date
              loc_payer-code         =  fin-ob-before.payer-code
              loc_payer-name         =  fin-ob-before.payer-name
              loc_payer-type         =  fin-ob-before.payer-type
              loc_pay-date           =  fin-ob-before.pay-date
              loc_prn-doc-code       =  fin-ob-before.prn-doc-code
              loc_sum-base           =  fin-ob-before.sum-base
              loc_sum-doc            =  fin-ob-before.sum-doc
              loc_sum-rubl           =  fin-ob-before.sum-rubl
              loc_trn-doc-code       =  fin-ob-before.trn-doc-code
              loc_doc-type           =  fin-ob-before.doc-type
              loc_status_            =  fin-ob-before.status_
              loc_in-type            =  fin-ob-before.in-type
              loc_sum-tax-rubl       =  fin-ob-before.sum-tax-rubl
              loc_sum-tax-base       =  fin-ob-before.sum-tax-base
              loc_sum-tax-doc        =  fin-ob-before.sum-tax-doc
              loc_contract-curr      =  fin-ob-before.contract-curr
              loc_contract-rate      =  fin-ob-before.contract-rate
              loc_contract-scale     =  fin-ob-before.contract-scale
              loc_sum-contract       =  fin-ob-before.sum-contract
              loc_sum-tax-contract   =  fin-ob-before.sum-tax-contract
              loc_ps                   =  fin-ob-before.ps
              .
    find first buff_contract no-lock where buff_contract.host-code = fin-ob-before.host-code and
                                           buff_contract.contract-code = fin-ob-before.contract-code no-error .
    if available buff_contract then
       loc_contract-code        =  buff_contract.contract-prn-code .
       else loc_contract-code   = "".
    loc_abbr-contract  = sel-abbr(loc_contract-curr) .
end.
    loc_abbr-base = "Баз.вал "  + sel-abbr(p-basecode) .
    loc_abbr-doc  = sel-abbr(loc_curr-code) .
    case loc_in-type :
      when 0 then do:
        t-doc = yes.
      end.
      when 1 then do:
        t-base = yes.
      end.
      when 2 then do:
        t-rubl = yes.
      end.
      when 3 then do:
        t-contract = yes.
      end.
    end case.
   define buffer buf_fin-ob-tax-before for fin-ob-tax-before.
   for each tt_fin-ob-tax-before : delete tt_fin-ob-tax-before. end.
   for each buf_fin-ob-tax-before no-lock where
            buf_fin-ob-tax-before.host-code = par-host-code and
            buf_fin-ob-tax-before.before-code  = p-doc-code
   :
      create tt_fin-ob-tax-before.
      BUFFER-COPY buf_fin-ob-tax-before to tt_fin-ob-tax-before .
   end.
   OPEN QUERY BROWSE-1 FOR EACH tt_fin-ob-tax-before NO-LOCK.
   ASSIGN frame Dialog-Frame:TITLE = "ПредФинОбязательство  "  + " № " + loc_prn-doc-code
   + " Тип: " +    loc_doc-type
   + " Статус: "  +  loc_status_
   + " - " + caps(ref-mode).
  end.
END PROCEDURE.
PROCEDURE lookup-cli :
do
on error undo, return error return-value
:
define input parameter loc_cli-code as integer no-undo .
define input parameter loc_cli-type as character no-undo .
  run ref/showcli.p (
    input parParentProc
    ,input loc_cli-type
    ,input loc_cli-code
    ).
end.
END PROCEDURE.
PROCEDURE myenable_chg :
 do
 on error undo, return error return-value
 :
  DISPLAY loc_prn-doc-code  loc_payer-code loc_payer-type
          loc_contract-code loc_receiver-code loc_receiver-type  loc_sum-doc
          T-doc
          T-contract
          loc_contract-rate loc_contract-scale
          loc_exch-rate loc_exch-scale
          loc_base-rate loc_sum-rubl
          loc_sum-base
          T-rubl
          T-base
          loc_base-scale loc_doc-date
          loc_fact-date
          loc_payer-name loc_receiver-name loc_trn-doc-code
          loc_curr-code loc_abbr-doc loc_abbr-base
          p-doc-code
          loc_contract-code
          loc_sum-tax-doc
          loc_sum-tax-rubl
          loc_sum-tax-base
          loc_sum-tax-contract
          loc_sum-contract
          loc_contract-curr
          loc_abbr-contract
           b-prev b-next loc_abbr-rubl
          FILL-IN-4 FILL-IN-5 FILL-IN-6 FILL-IN-7
          loc_PS
          f-payer
          f-receiver
          B-contract
          B-payer
          B-receiver
          f-contract-curr
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help b-quit
         loc_prn-doc-code
         r-obj
         r-con
         r-cli
         r-cur
         r-cur-contr
         loc_payer-code
         loc_payer-type
         loc_receiver-code
         loc_receiver-type
         T-doc T-rubl T-base t-contract
         loc_exch-rate
         loc_exch-scale
         loc_contract-rate
         loc_contract-scale
         loc_base-rate
         loc_base-scale
         BROWSE-1
         B-ins B-chg B-del
         loc_doc-date
         loc_fact-date
         loc_curr-code
         loc_abbr-doc
         loc_abbr-base
        loc_sum-doc       when t-doc      = yes
        loc_sum-rubl      when t-rubl     = yes
        loc_sum-base      when t-base     = yes
        loc_sum-contract  when t-contract = yes
        loc_contract-code
        B-contract
        B-payer
        B-receiver
      WITH FRAME Dialog-Frame.
      run chg-radio-mode.
      b-exit:label in frame Dialog-Frame  = "&Ввод" .
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH tt_fin-ob-tax-before NO-LOCK.
  end.
END PROCEDURE.
PROCEDURE myenable_lkp :
  IF AVAILABLE fin-ob-before THEN
    DISPLAY
    loc_base-rate
    loc_base-scale
    loc_receiver-code
    loc_receiver-name
    loc_receiver-type
    loc_contract-code
    loc_contract-rate
    loc_contract-scale
    loc_curr-code
    loc_doc-date loc_exch-rate loc_exch-scale loc_fact-date loc_payer-code loc_payer-name loc_payer-type
    loc_prn-doc-code
    loc_sum-base
    loc_sum-doc
    loc_sum-rubl
    loc_trn-doc-code
    loc_abbr-base
    loc_abbr-doc
    p-doc-code
    loc_sum-tax-doc
    loc_sum-tax-rubl
    loc_sum-tax-base
    b-prev
    b-next
    T-base T-contract T-doc T-rubl
    loc_sum-contract
    loc_sum-tax-contract
    loc_contract-curr
    loc_abbr-contract
        loc_abbr-rubl
    FILL-IN-4 FILL-IN-5 FILL-IN-6 FILL-IN-7
          loc_PS
          f-payer
          f-receiver
          B-contract
          B-payer
          B-receiver
          f-contract-curr
          loc_ps
      WITH FRAME Dialog-Frame.
   enable b-exit b-help BROWSE-1 b-next  b-prev
          B-contract
          B-payer
          B-receiver
      WITH FRAME Dialog-Frame.
      disable  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH tt_fin-ob-tax-before NO-LOCK.
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
    if  loc_prn-doc-code   :handle = p-widget-handle then do:  if loc_payer-code    :sensitive then do: apply "entry":u to loc_contract-code .  return . end. end.
    if  loc_contract-code  :handle = p-widget-handle then do:  if loc_pay-date      :sensitive then do: apply "entry":u to loc_pay-date      .  return . end. end.
    if  loc_pay-date       :handle = p-widget-handle then do:  if loc_receiver-code :sensitive then do: apply "entry":u to loc_receiver-code .  return . end. end.
    if  loc_receiver-code  :handle = p-widget-handle then do:  if loc_payer-code    :sensitive then do: apply "entry":u to loc_payer-code    .  return . end. end.
    if  loc_payer-code     :handle = p-widget-handle then do:
        if loc_sum-doc      :sensitive then do: apply "entry":u to loc_sum-doc      .  return . end.
        if loc_sum-base     :sensitive then do: apply "entry":u to loc_sum-base     .  return . end.
        if loc_sum-rubl     :sensitive then do: apply "entry":u to loc_sum-rubl     .  return . end.
        if loc_sum-contract :sensitive then do: apply "entry":u to loc_sum-contract .  return . end.
    end.
    if  loc_sum-doc        :handle = p-widget-handle then do:  if B-chg     :sensitive then do:       apply "entry":u to B-chg     .        return . end. end.
    if  loc_sum-base       :handle = p-widget-handle then do:  if B-chg     :sensitive then do:       apply "entry":u to B-chg     .        return . end. end.
    if  loc_sum-rubl       :handle = p-widget-handle then do:  if B-chg     :sensitive then do:       apply "entry":u to B-chg     .        return . end. end.
    if  loc_sum-contract   :handle = p-widget-handle then do:  if B-chg     :sensitive then do:       apply "entry":u to B-chg     .        return . end. end.
    if  b-chg              :handle = p-widget-handle then do:  if B-exit    :sensitive then do:       apply "entry":u to B-exit    .        return . end. end.
    end.
  end.
END PROCEDURE.
PROCEDURE save-p :
do
 on error undo, return error return-value
 :
if ref-mode <> 'ПРОСМОТР':U then do:
        if loc_sum-doc  = 0 or loc_sum-doc  = ?  or
          loc_sum-base = 0 or loc_sum-base = ?  or
          loc_sum-rubl = 0 or loc_sum-rubl = ?  then do:
          message "Не задана сумма финансового обязательства !" view-as alert-box information  title "Ошибка при вводе".
          return error.
      end.
      if loc_receiver-code = 0 or loc_receiver-code = ? then do:
        message "Не задан код получателя !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.
      if loc_payer-code = 0 or loc_payer-code = ? then do:
        message "Не задан код плательщика !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.
      if loc_receiver-code = loc_payer-code  and
         loc_receiver-type = loc_payer-type then do:
        message "Код получателя равен коду плательщика !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.
      if not can-find (first clients where clients.obj-code = loc_receiver-code
                                      and clients.obj-type = loc_receiver-type no-lock )
        then do:
        message "Не верно выбран получатель !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.
      if not can-find (first clients where clients.obj-code = loc_payer-code
                                      and clients.obj-type = loc_payer-type no-lock )
        then do:
        message "Не верно выбран плательшик !"  view-as alert-box information  title "Ошибка при вводе".
        return error .
      end.
      define variable v-sum1 as decimal no-undo .
      v-sum1 = 0 .
      for each tt_fin-ob-tax-before :
          v-sum1  = v-sum1 + tt_fin-ob-tax-before.sum-line-doc .
      end.
      if  v-sum1 = 0  then do:
        message
         "Не введены налоги !!! "
        view-as alert-box information  title "Ошибка при вводе налогов".
        return error .
      end.
      if loc_sum-doc <> v-sum1      then do:
        message
        substitute ( "Общая сумма документа &1, а сумма всех компонент , по которым исчислялся налог = &2", loc_sum-doc, v-sum1 )
        view-as alert-box information  title "Ошибка при вводе налогов".
        return error .
      end.
define buffer buf_contract for contract.
  find first buf_contract where buf_contract.contract-prn-code = loc_contract-code
                            and buf_contract.host-code         = par-host-code
                        no-lock no-error .
  if not available buf_contract then do:
     message "Не верно введен Номер договора!!! " view-as alert-box error  .
     return error .
  end.
  define variable v-ok as logical no-undo .
  case p-doc-type :
  when 'при':U then do:
    if not ((
        ( loc_payer-code       =  buf_contract.cli-code  and loc_payer-type       =  buf_contract.cli-type  ) or
        ( loc_payer-code       =  buf_contract.posr-code and loc_payer-type       =  buf_contract.posr-type ) or
        ( loc_payer-code       =  buf_contract.agnt-code and loc_payer-type       =  buf_contract.agnt-type ))
        and
        ( loc_receiver-code       =  par-host-code       and loc_receiver-type       =  'орг':U))
        then do:
         message
         "Внимание !!!"  skip
         "Данные по ПЛАТЕЛЬЩИКУ или ПОЛУЧАТЕЛЮ взяты не из договора ! "  skip
         "Сохраняем фин.обязательство  ? "          skip
         view-as alert-box question
         buttons yes-no
         update v-ok
          .
         if v-ok = false then return error .
        end.
  end.
  when 'рас':U then do:
    if not ((
        ( loc_receiver-code       =  buf_contract.cli-code  and loc_receiver-type       =  buf_contract.cli-type  ) or
        ( loc_receiver-code       =  buf_contract.posr-code and loc_receiver-type       =  buf_contract.posr-type ) or
        ( loc_receiver-code       =  buf_contract.agnt-code and loc_receiver-type       =  buf_contract.agnt-type ))
        and
        ( loc_payer-code       =  par-host-code       and loc_payer-type       =  'орг':U))
        then do:
         message
         "Внимание !!!"  skip
         "Данные по ПЛАТЕЛЬЩИКУ или ПОЛУЧАТЕЛЮ взяты не из договора ! "  skip
         "Сохраняем фин.обязательство  ? "          skip
         view-as alert-box question
         buttons yes-no
         update v-ok
          .
         if v-ok = false then return error .
        end.
  end.
  end case.
if ref-mode = 'ДОБАВЛЕНИЕ':U then do:
       run create-fin-ob-before (
                input no ,
        input  p-doc-code            ,
        input  0                     ,
        input  p-doc-date            ,
        input  p-doc-type            ,
        input  p-payer-name          ,
        input  p-receiver-name       ,
        input  p-curr-code           ,
        input  p-sum-doc             ,
        input  p-user-db-num-doc     ,
        input  p-user-name-doc       ,
        input  p-base-rate           ,
        input  p-base-scale          ,
        input  p-receiver-code       ,
        input  p-receiver-type       ,
        input  p-contract-code       ,
        input  p-exch-rate           ,
        input  p-exch-scale          ,
        input  p-contract-curr       ,
        input  p-contract-rate       ,
        input  p-contract-scale      ,
        input  p-fact-date           ,
        input  p-fact-order          ,
        input  p-host-code           ,
        input  p-payer-code          ,
        input  p-payer-type          ,
        input  p-pay-date            ,
        input  p-prn-doc-code        ,
        input  p-status_             ,
        input  p-sum-base-orig       ,
        input  p-sum-base            ,
        input  p-sum-doc-orig        ,
        input  p-sum-rubl-orig       ,
        input  p-sum-rubl            ,
        input  p-sum-contract        ,
        input  p-trn-doc-code        ,
        input  p-trn-doc-code        ,
        input  p-user-db-num-fact    ,
        input  p-user-db-num-pay        ,
        input  p-user-name-fact         ,
        input  p-user-name-pay          ,
        input  p-in-type                ,
        input  p-sum-tax-base           ,
        input  p-sum-tax-doc            ,
        input  p-sum-tax-rubl           ,
        input  p-sum-tax-contract       ,
        input  ""                       ,
        output ri ).
end.
    find current fin-ob-before  exclusive-lock   no-error.
    if available fin-ob-before then do:
      assign
        fin-ob-before.contract-code        = loc_contract-code-id
        fin-ob-before.receiver-code        = loc_receiver-code
        fin-ob-before.receiver-name        = loc_receiver-name
        fin-ob-before.receiver-type        = loc_receiver-type
        fin-ob-before.doc-date             = loc_doc-date
        fin-ob-before.trn-doc-code         = loc_trn-doc-code
        fin-ob-before.base-rate            = loc_base-rate
        fin-ob-before.base-scale           = loc_base-scale
        fin-ob-before.curr-code            = loc_curr-code
        fin-ob-before.exch-rate            = loc_exch-rate
        fin-ob-before.exch-scale           = loc_exch-scale
        fin-ob-before.fact-date            = loc_fact-date
        fin-ob-before.payer-code           = loc_payer-code
        fin-ob-before.payer-name           = loc_payer-name
        fin-ob-before.payer-type           = loc_payer-type
        fin-ob-before.pay-date             = loc_pay-date
        fin-ob-before.prn-doc-code         = loc_prn-doc-code
        fin-ob-before.sum-base             = loc_sum-base
        fin-ob-before.sum-doc              = loc_sum-doc
        fin-ob-before.sum-rubl             = loc_sum-rubl
        fin-ob-before.sum-contract         = loc_sum-contract
        fin-ob-before.sum-tax-base             = loc_sum-tax-base
        fin-ob-before.sum-tax-doc              = loc_sum-tax-doc
        fin-ob-before.sum-tax-rubl             = loc_sum-tax-rubl
        fin-ob-before.sum-tax-contract         = loc_sum-tax-contract
        fin-ob-before.contract-curr        = loc_contract-curr
        fin-ob-before.contract-rate        = loc_contract-rate
        fin-ob-before.contract-scale       = loc_contract-scale
       fin-ob-before.ps                   =  loc_ps
      .
      if t-doc      then fin-ob-before.in-type  = 0 .
      if t-base     then fin-ob-before.in-type  = 1 .
      if t-rubl     then fin-ob-before.in-type  = 2 .
      if t-contract then fin-ob-before.in-type  = 3 .
          for each fin-ob-tax-before  exclusive-lock  where  fin-ob-tax-before.host-code = fin-ob-before.host-code and
                                                             fin-ob-tax-before.before-code  = fin-ob-before.before-code :
              delete fin-ob-tax-before .
          end .
          for each tt_fin-ob-tax-before :
              create fin-ob-tax-before .
              BUFFER-COPY tt_fin-ob-tax-before to fin-ob-tax-before
              assign
                fin-ob-tax-before.host-code = fin-ob-before.host-code
                fin-ob-tax-before.before-code  = fin-ob-before.before-code
            .
          end.
end.
else do:
 message "Ошибка при сохранении данных "  skip vss-workfile vss-revision vss-description skip
         error-status :get-message(1) .
 return no-apply.
end.
end.
  end.
END PROCEDURE.
PROCEDURE step-next :
 do
 on error undo, return error return-value
 :
if valid-handle (br-handle) then do:
  g#log = br-handle:select-next-row() no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
     end.
  if not g#log then message "Это последний документ списка.".
end.
    ri = recid ( buf_fin-liab-before ).
    next-prev = yes.
  end.
END PROCEDURE.
PROCEDURE step-prev :
 do
 on error undo, return error return-value
 :
if valid-handle (br-handle) then do:
  g#log = br-handle:select-prev-row() no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
  end.
  if not g#log then do: message "Это первый документ списка.".   end.
end.
ri = recid (buf_fin-liab-before).
next-prev = yes .
  end.
END PROCEDURE.
FUNCTION sel-abbr RETURNS CHARACTER
  ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first currency no-lock where  currency.curr-code  = p-curr-code no-error.
  rr = currency.curr-abbr .
  RETURN rr.
END FUNCTION.
