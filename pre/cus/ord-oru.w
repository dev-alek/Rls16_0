DEFINE BUFFER X_goods FOR ub.goods.
DEFINE NEW SHARED BUFFER X_ord-line FOR ub.ord-line.
define input  parameter parparentproc as handle no-undo .
define input-output parameter p-ord-doc-recid as recid no-undo .
define input parameter p-mode as character no-undo .
define input-output parameter br-handle as handle  no-undo .
define input-output parameter next-prev as logical   no-undo .
define  shared buffer buf-or_ord-doc for ub.ord-doc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка заказов ОО".
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define new shared temp-table tmp#zakaz1 no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field local-mark    as character field max-stock     as decimal   field season-coef   as decimal   field min-stock-old as decimal   field gds-way       as decimal   index pi is unique primary artic prod-type prod-code  ascending index idx-ln line-num.
define new shared temp-table tmp#zakaz-prn1 no-undo field artic         like ub.goods.artic      field prod-type     like ub.goods.prod-type  field prod-code     like ub.goods.prod-code  field obj-type      like ub.clients.obj-type field obj-code      like ub.clients.obj-code field prt-code      as   integer    field qnty-sale     as   decimal    field qnty-ord      as   decimal    index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.
define new shared temp-table tmp#zakaz-dtl1 no-undo like ub.ord-dtl field prt-name as character index bi is unique primary artic prod-type prod-code node-code  ascending.
define new shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define new shared buffer buf-goods   for ub.goods     .
define new shared buffer sb-cli-gds  for ub.cli-gds   .
define new shared buffer sb-gds-obj  for ub.gds-obj   .
define new shared buffer tmp#zakaz     for tmp#zakaz1.
define new shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define new shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define new shared  buffer shar_ord-doc  for ub.ord-doc .
define new shared  buffer shar_ord-line for ub.ord-line.
define new shared  buffer shar_ord-dtl  for ub.ord-dtl .
define new shared variable chexcelapplication      as com-handle no-undo .
define new shared variable chworkbook              as com-handle no-undo .
define new shared variable chworksheet             as com-handle no-undo .
define new shared variable chrange                 as com-handle no-undo .
define new shared variable chworksheet2            as com-handle no-undo .
define new shared variable chworksheet3            as com-handle no-undo .
define new shared variable accum-zakaz             as decimal no-undo .
define new shared variable accum-sum-zakaz         as decimal no-undo .
define new shared variable accum-count             as integer no-undo .
define new shared buffer buf-cli for ub.clients.
define new shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.
define new shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.
define new shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.
define  new  shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define  new  shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define  new  shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define  new  shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define  new  shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.
define  new  shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.
define  new  shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.
define  new  shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.
define  new  shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.
define  new  shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
define  new  shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.
define new  shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.
define new  shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define new  shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define new  shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.
define new shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.
define  new  shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.
define new shared variable loc-status  as character  no-undo.
define new shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.
define new shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.
define new shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.
define new shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.
define new shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.
define new shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.
define new shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.
define new shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.
define new shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.
define new shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.
define new shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.
define new shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(руб.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(руб)"
     fgcolor 4
     no-undo.
define new shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.
define new shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.
define new shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.
define new shared var loc-print-rubl as logical no-undo .
define new shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define new shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define new shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define  new  shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.
define new shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define new shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define new shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define new shared  variable temp-e-method  as character no-undo .
define new shared  variable x-tog-artic as logical   no-undo .
define new shared  variable x-tog-grp    as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-deliv-type-code    as integer   no-undo .
define variable v-point-obj-code     as integer   no-undo .
define variable v-point-cli-code     as integer   no-undo .
define variable v-point-obj-db-num   as integer   no-undo .
define variable v-point-cli-db-num   as integer   no-undo .
define variable v-transport-host-code     as integer   no-undo .
define variable v-transport-cli-type     as character no-undo .
define variable v-transport-cli-code     as integer   no-undo .
define variable v-transport-contract   as integer   no-undo .
define variable v-transport-condition  as integer   no-undo .
define variable v-transport-value      as decimal   no-undo .
define variable v-transport-sum        as decimal   no-undo .
define variable v-transport-vat        as decimal   no-undo .
define variable flag as logical   no-undo init false .
define variable v-quest as logical   no-undo init true .
define variable v-update-price as integer   no-undo .
define variable choice   as      logical no-undo    init ?.
define variable g#ok        as logical   no-undo .
define variable g#log       as logical   no-undo .
define variable gds-rec     as recid no-undo .
define variable line-mode   as character no-undo .
define variable v-order-col as character no-undo .
define variable v-size-col1 as decimal   no-undo .
define variable v-size-col2 as decimal   no-undo .
define variable v-size-col3 as decimal   no-undo .
define variable v-size-col4 as decimal   no-undo .
define variable v-size-col5 as decimal   no-undo .
define variable v-size-col6 as decimal   no-undo .
define variable v-size-col7 as decimal   no-undo .
define variable v-size-col8 as decimal   no-undo .
define variable v-size-col9 as decimal   no-undo .
define variable v-size-col10 as decimal   no-undo .
define variable v-size-col11 as decimal   no-undo .
define variable v-size-col12 as decimal   no-undo .
define variable v-size-col13 as decimal   no-undo .
define variable v-size-col14 as decimal   no-undo .
define variable v-size-col15 as decimal   no-undo .
define variable v-size-col16 as decimal   no-undo .
run uf-get in this-procedure(
     input  'ord-rc-p':U
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  end.
if not error-status:error then do:
   v-order-col  = entry ( 1, v-uf-List_ ,chr(4) ) no-error.
   v-size-col1  = decimal (entry ( 2 , v-uf-List_ ,chr(4))) no-error.
   v-size-col2  = decimal (entry ( 3 , v-uf-List_ ,chr(4))) no-error.
   v-size-col3  = decimal (entry ( 4 , v-uf-List_ ,chr(4))) no-error.
   v-size-col4  = decimal (entry ( 5 , v-uf-List_ ,chr(4))) no-error.
   v-size-col5  = decimal (entry ( 6 , v-uf-List_ ,chr(4))) no-error.
   v-size-col6  = decimal (entry ( 7 , v-uf-List_ ,chr(4))) no-error.
   v-size-col7  = decimal (entry ( 8, v-uf-List_  ,chr(4))) no-error.
   v-size-col8  = decimal (entry ( 9, v-uf-List_ ,chr(4))) no-error.
   v-size-col9  = decimal (entry ( 10, v-uf-List_ ,chr(4))) no-error.
   v-size-col10 = decimal (entry ( 11, v-uf-List_ ,chr(4))) no-error.
   v-size-col11 = decimal (entry ( 12, v-uf-List_ ,chr(4))) no-error.
   v-size-col12 = decimal (entry ( 13, v-uf-List_ ,chr(4))) no-error.
   v-size-col13 = decimal (entry ( 14, v-uf-List_ ,chr(4))) no-error.
   v-size-col14 = decimal (entry ( 15 , v-uf-List_ ,chr(4))) no-error.
   v-size-col15 = decimal (entry ( 16 , v-uf-List_ ,chr(4))) no-error.
   v-size-col16 = decimal (entry ( 17 , v-uf-List_ ,chr(4))) no-error.
   if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1     = 4 .
   if v-size-col2 = 0 or v-size-col2 = ? then v-size-col2     = 10 .
   if v-size-col3 = 0 or v-size-col3 = ? then v-size-col3     = 16 .
   if v-size-col4 = 0 or v-size-col4 = ? then v-size-col4     = 10 .
   if v-size-col5 = 0 or v-size-col5 = ? then v-size-col5     = 6  .
   if v-size-col7  = 0 or v-size-col7  = ? then v-size-col7   = 3 .
   if v-size-col8  = 0 or v-size-col8  = ? then v-size-col8   = 8 .
   if v-size-col10 = 0 or v-size-col10 = ? then v-size-col10  = 6  .
   if v-size-col11 = 0 or v-size-col11 = ? then v-size-col11  = 6  .
   if v-size-col12 = 0 or v-size-col12 = ? then v-size-col12  = 6  .
   if v-size-col13 = 0 or v-size-col13 = ? then v-size-col13 = 10 .
   if v-size-col14 = 0 or v-size-col14 = ? then v-size-col14  = 10  .
   if v-size-col15 = 0 or v-size-col15 = ? then v-size-col15  = 10  .
   if v-size-col16 = 0 or v-size-col16 = ? then v-size-col16  = 6  .
   if v-size-col6 = 0 or v-size-col6 = ? then v-size-col6  = 10  .
   if v-size-col9 = 0 or v-size-col9 = ? then v-size-col9  = 10  .
   if v-order-col = "" or v-order-col = ? then v-order-col = "1,2,3,4,7,11,12,13,5,8,10,14,6,9,15,16".
end.
define buffer   buf_ord-doc for ub.ord-doc .
define buffer   buf_clients for ub.clients .
define variable loc-obj-code as integer no-undo .
define variable loc-obj-type as character no-undo .
define variable sort-column-name as character no-undo .
define variable v-recid-RC as recid no-undo .
define buffer cli#clients for ub.clients.
define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
DEFINE VARIABLE  v-rc-qnty AS DECIMAL NO-UNDO.
DEFINE VARIABLE  v-rc-qnty-free AS DECIMAL NO-UNDO.
define variable v-ord-askp as logical   no-undo .
define variable v-ord-obj-rc as character no-undo .
FUNCTION f-zapr-qnty RETURNS decimal
  ( buffer buf_ord-line for ub.ord-line , par-type as char )  FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-calc
     LABEL "&Рассчитать"
     SIZE 12 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Посмотреть договор".
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-delivery
     LABEL "Доставка"
     SIZE 10 BY 1 TOOLTIP "Условия доставки".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1.
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON b-renum
     LABEL "№ п/п"
     SIZE 10 BY 1 TOOLTIP "Перенумеровать список товаров".
DEFINE BUTTON B-spec
     IMAGE-UP FILE "cmp/image3.bmp":U
     IMAGE-DOWN FILE "cmp/image3.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/image3.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 2.5 BY 1 TOOLTIP "Спецификация к договору".
DEFINE BUTTON b-spec-gds
     LABEL "Специ&фикация"
     SIZE 13.5 BY 1 TOOLTIP "Добавление товаров по спецификации".
DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r boss 2"
     SIZE 3 BY .88.
DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 1"
     SIZE 3 BY .88.
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r boss 2"
     SIZE 3 BY 1.
DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r boss 2"
     SIZE 3 BY .88.
DEFINE VARIABLE scr-e-method AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.38 BY 6.04
     BGCOLOR 8 FONT 4 NO-UNDO.
DEFINE VARIABLE scr-agnt AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1 NO-UNDO.
DEFINE VARIABLE scr-agnt-name AS CHARACTER FORMAT "X(20)":U
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-boss AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1 NO-UNDO.
DEFINE VARIABLE scr-boss-name AS CHARACTER FORMAT "X(20)":U
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-cli AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "РЦ"
     VIEW-AS FILL-IN
     SIZE 4.13 BY 1 NO-UNDO.
DEFINE VARIABLE scr-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33.38 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-contract AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 20.5 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE scr-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "на Объект"
      VIEW-AS TEXT
     SIZE 39.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-pay-day AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "На дней продаж"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE scr-ship-date AS DATE FORMAT "99/99/9999":U
     LABEL "Заказ на"
     VIEW-AS FILL-IN
     SIZE 11.13 BY 1 TOOLTIP "Заказ на дату" NO-UNDO.
DEFINE VARIABLE scr-sum-base AS DECIMAL FORMAT ">>,>>>,>>9.99":U INITIAL 0
     LABEL "Итого сумма (вал)"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-sum-qnty AS DECIMAL FORMAT ">>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Итого кол-во"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-sum-rubl AS DECIMAL FORMAT ">>,>>>,>>9.99":U INITIAL 0
     LABEL "Итого сумма (abbr_rub)"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-wrkr AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1 NO-UNDO.
DEFINE VARIABLE scr-wrkr-name AS CHARACTER FORMAT "X(20)":U
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-auto AS LOGICAL INITIAL yes
     LABEL "авто"
     VIEW-AS TOGGLE-BOX
     SIZE 7 BY .83 NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      X_ord-line,
      X_goods SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 NO-LOCK DISPLAY
      X_ord-line.line-num   COLUMN-LABEL  'N/п'   FORMAT ">>>>9"
      X_goods.gds-code   COLUMN-LABEL  'Код'   FORMAT ">>>>>>>>9"
      X_ord-line.artic   COLUMN-LABEL  'Артикул'
      X_goods.gds-name   COLUMN-LABEL  'Название'   FORMAT "X(100)"
      X_ord-line.qnty   COLUMN-LABEL  'Кол-во'   FORMAT "->>,>>>,>>9.<<<"
      X_ord-line.initial-qnty   COLUMN-LABEL  'Рекомен-!довано  '   FORMAT "->>,>>>,>>9.<<<"
      X_goods.unit-base   COLUMN-LABEL  'ед.!изм'   FORMAT "X(3)"
      ( if X_ord-line.temp-rash <> 0 then X_ord-line.order-qnty / X_ord-line.temp-rash  else 0 )   COLUMN-LABEL  'Заказано!в днях'   FORMAT "->>>>>>>>9.99"
      X_ord-line.order-qnty   COLUMN-LABEL  'Заказано'   FORMAT "->>,>>>,>>9.<<<"
      v-rc-qnty  COLUMN-LABEL  'Текущий!остаток РЦ'  FORMAT "->>,>>>,>>9.<<<"
      (chr(int(X_ord-line.add-cli-qnty)) + string(X_ord-line.add-qnty))  COLUMN-LABEL  'ABC1'  FORMAT "x(6)"
      (chr(int(X_ord-line.cancel-cli-qnty)) + string(X_ord-line.cancel-qnty))  COLUMN-LABEL  'ABC2'  FORMAT "x(6)"
      X_ord-line.temp-rash  COLUMN-LABEL  'Темп'  FORMAT "->>,>>>,>>9.<<<"
      v-rc-qnty-free  COLUMN-LABEL  'Свободный!остаток РЦ'  FORMAT "->>,>>>,>>9.<<<"
      X_ord-line.qnty-stk  COLUMN-LABEL  'Остаток на!момент расчета'  FORMAT "->>,>>>,>>9.<<<"
      ( if X_ord-line.temp-rash <> 0 then X_ord-line.qnty-stk / X_ord-line.temp-rash  else 0 )  COLUMN-LABEL  'Остаток!в днях'  FORMAT "->,>>>,>>9.99"
      ENABLE
      X_ord-line.qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.5 BY 9.67.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-delivery AT ROW 1 COL 76.13
     B-help AT ROW 1 COL 86.13
     b-prev AT ROW 2 COL 1
     b-next AT ROW 2 COL 6
     B-spec AT ROW 2 COL 93.5 WIDGET-ID 2
     scr-cli AT ROW 2.04 COL 27 COLON-ALIGNED
     r-cli AT ROW 2.04 COL 33
     B-contract AT ROW 2.04 COL 90.25
     scr-wrkr AT ROW 3.17 COL 5.88 COLON-ALIGNED
     scr-ship-date AT ROW 3.17 COL 82.5 COLON-ALIGNED
     r-wrkr AT ROW 3.25 COL 18
     scr-pay-day AT ROW 4.17 COL 82.5 COLON-ALIGNED
     scr-agnt AT ROW 4.21 COL 5.75 COLON-ALIGNED
     r-agnt AT ROW 4.29 COL 17.88
     scr-boss AT ROW 5.33 COL 5.75 COLON-ALIGNED
     r-boss AT ROW 5.42 COL 17.88
     scr-e-method AT ROW 6.54 COL 1 NO-LABEL
     b-add AT ROW 12.83 COL 1
     B-chg AT ROW 12.83 COL 11
     B-del AT ROW 12.83 COL 21
     B-calc AT ROW 12.83 COL 31
     b-renum AT ROW 12.83 COL 43
     b-spec-gds AT ROW 12.83 COL 53 WIDGET-ID 4
     t-auto AT ROW 13.04 COL 88.25
     BROWSE-2 AT ROW 14 COL 1
     scr-obj-name AT ROW 1.21 COL 35.13 COLON-ALIGNED
     scr-cli-name AT ROW 2.04 COL 35.13 COLON-ALIGNED NO-LABEL
     scr-contract AT ROW 2.04 COL 68 COLON-ALIGNED NO-LABEL
     scr-wrkr-name AT ROW 3.33 COL 19.25 COLON-ALIGNED NO-LABEL
     scr-agnt-name AT ROW 4.46 COL 19.25 COLON-ALIGNED NO-LABEL
     scr-boss-name AT ROW 5.63 COL 19.25 COLON-ALIGNED NO-LABEL
     scr-sum-qnty AT ROW 6.29 COL 80.38 COLON-ALIGNED
     scr-sum-rubl AT ROW 7 COL 80.38 COLON-ALIGNED
     scr-sum-base AT ROW 7.79 COL 80.38 COLON-ALIGNED
     SPACE(0.24) SKIP(15.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заказ ОРЦ".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-prev:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       scr-sum-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       scr-sum-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
define buffer buf_ord-line for ub.ord-line.
define variable v-kol as integer init 0 no-undo .
define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
define variable v-list as character no-undo .
  assign
    cur-clmn-loc  = 1
    column-handle = BROWSE-2:first-column
    v-list        = column-handle:label + "#"
  .
  do while valid-handle(column-handle) :
    if cur-clmn-loc = BROWSE-2:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.
   v-list = trim(v-list, "#") .
   define variable v-i as integer   no-undo .
   define variable v-pos as integer   no-undo .
   define variable v-list-new as character no-undo .
   define variable v-elem as character no-undo .
   repeat v-i = 1 to BROWSE-2:num-columns :
      v-elem = entry( v-i, v-list , "#") .
      v-pos = lookup( v-elem , 'N/п' + '#' +  'Код' + '#' +  'Артикул' + '#' +  'Название' + '#' +  'Кол-во' + '#' +  'Рекомен-!довано  ' + '#' +  'ед.!изм' + '#' +  'Заказано!в днях' + '#' +  'Заказано' + '#' +  'Текущий!остаток РЦ' + '#' +  'ABC1' + '#' +  'ABC2' + '#' +  'Темп' + '#' +  'Свободный!остаток РЦ' + '#' +  'Остаток на!момент расчета' + '#' +  'Остаток!в днях' , "#") .
      v-list-new = v-list-new + string(v-pos) + "," .
   end.
   define variable v-list-str as character no-undo .
   define variable v-nn as integer   no-undo .
   v-nn = num-entries(v-list-new) .
   v-list-str = "" .
   repeat v-i = 1 to v-nn :
      v-elem = entry(v-i , v-list-new ) .
      if int(v-elem) > 0 then
      v-list-str  = v-list-str + v-elem + "," .
   end.
   v-list-new = trim ( v-list-str , ",")  +  chr(4)
              + string(decimal( X_ord-line.line-num:width in browse BROWSE-2   )) +  chr(4)
              + string(decimal( X_goods.gds-code:width in browse BROWSE-2   )) +  chr(4)
              + string(decimal( X_ord-line.artic:width in browse BROWSE-2   )) +  chr(4)
              + string(decimal( X_goods.gds-name:width in browse BROWSE-2   )) +  chr(4)
              + string(decimal( X_ord-line.qnty:width in browse BROWSE-2   )) +  chr(4)
              + string(decimal( X_ord-line.initial-qnty:width in browse BROWSE-2    )) +  chr(4)
              + string(decimal( X_goods.unit-base:width in browse BROWSE-2   )) +  chr(4)
              + string(10)  +  chr(4)
              + string(decimal( X_ord-line.order-qnty :width in browse BROWSE-2   )) +  chr(4)
              + string(decimal( v-rc-qnty:width  in browse BROWSE-2 )) +  chr(4)
              + string(8) +  chr(4)
              + string(8) +  chr(4)
              + string(decimal( X_ord-line.temp-rash:width in browse BROWSE-2   )) +  chr(4)
              + string(decimal( v-rc-qnty-free:width in browse BROWSE-2   )) +  chr(4)
              + string(decimal( X_ord-line.qnty-stk:width in browse BROWSE-2   )) +  chr(4)
              + string(10) +  chr(4)
              .
    run uf-set in this-procedure(
        input  'ord-rc-p':U
        ,input v-cntxt-userid
        ,input v-list-new
        ,input v-uf-Naim
        ,input v-uf-print-graft
        ,input v-uf-sort-gr
        ,input v-uf-type-price
        ,input v-uf-type-val
    ) no-error    .
        if error-status :error then
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "uf-set"
          view-as alert-box error
        .
  if p-mode =  'ПРОСМОТР':U then return.
  if p-mode <> 'ПРОСМОТР':U then do:
     assign frame Dialog-Frame
     scr-ship-date
     scr-e-method
     scr-wrkr
     scr-agnt
     scr-boss
     scr-cli
     scr-pay-day
     .
     loc-date-ship = scr-ship-date.
     pay-day = scr-pay-day.
  if loc-cli-code = 0 or loc-cli-code = ? then do:
      message "Не выбран РЦ ! "
      view-as alert-box error .
      return no-apply .
  end.
  if (loc-cli-code = loc-obj-code) and (loc-cli-type = loc-obj-type) then do:
      message "Не верно выбран РЦ ! "
      view-as alert-box error .
      return no-apply .
  end.
  if not (loc-cli-type = 'маг':U  or loc-cli-type = 'скл':U ) then do:
      message "РЦ  должен быть объектом ! "
      view-as alert-box error .
      return no-apply .
  end.
define variable o-host-code as integer   no-undo .
define variable c-host-code as integer   no-undo .
define variable o-base-code as integer   no-undo .
define variable c-base-code as integer   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  loc-obj-type
  ,input  loc-obj-code
  ,output o-host-code
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  loc-cli-type
  ,input  loc-cli-code
  ,output c-host-code
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  o-host-code
  ,output o-base-code
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  c-host-code
  ,output c-base-code
  )  .
if o-base-code <> c-base-code then do:
  message "Контрагенты имеют разную базовую валюту. Создание заказа не возможно ! " view-as alert-box error .
  return .
end.
      if can-find ( first buf_ord-line  no-lock    where
                          buf_ord-line.doc-code = loc-ord-num  and
                          buf_ord-line.qnty  =  0 ) then do:
          find first buf-or_ord-doc exclusive-lock where recid(buf-or_ord-doc) = p-ord-doc-recid  no-error.
          if buf-or_ord-doc.status_ = 'новый':U then do:
              message "В заказе есть нерассчитанные строки . Удаляем их ? " view-as alert-box question  buttons yes-no update g#log.
              if g#log then do:
                    for each buf_ord-line  exclusive-lock
                            where buf_ord-line.qnty = 0      and
                            buf_ord-line.doc-code = loc-ord-num
                            :
                            delete buf_ord-line .
                    end.
              end.
          end.
          else do:
            message "В заказе есть строки с нулевым количеством ! " view-as alert-box information .
          end.
      end.
   define variable v-del as integer   no-undo .
   v-del = 0 .
     for each  buf_ord-line  exclusive-lock    where
               buf_ord-line.doc-code = loc-ord-num :
            find first ub.goods WHERE ub.goods.artic = buf_ord-line.artic   AND
                                      ub.goods.prod-code = buf_ord-line.prod-code   AND
                                      ub.goods.prod-type = buf_ord-line.prod-type NO-LOCK.
              if ub.goods.gds-type =  'у':U  then do:
                  delete buf_ord-line .
                  v-del = v-del + 1.
              end.
     end.
     if v-del > 0  then message "Удалено " v-del  " услуг"  view-as alert-box information .
     define variable s-1 as decimal init 0 no-undo .
     define variable s-2 as decimal init 0 no-undo .
     define variable s-3 as decimal init 0 no-undo .
     for each  buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num  :
         s-1  = s-1  + buf_ord-line.sum-rubl .
         s-2  = s-2  + buf_ord-line.sum-base .
         s-3  = s-3  + buf_ord-line.qnty .
         v-kol = v-kol + 1 .
     end.
     if v-kol = 0 then do:
        message "В заказе нет строк . Удаляем документ ? " view-as alert-box question
        buttons yes-no title "" update t-log-3 as logical.
        if t-log-3 = true then do:
                find first buf-or_ord-doc exclusive-lock where recid(buf-or_ord-doc) = p-ord-doc-recid  no-error.
                if available buf-or_ord-doc then
                delete buf-or_ord-doc.
                return.
            end.
     end.
  end.
  find current buf_ord-doc exclusive-lock no-error .
  assign
    buf_ord-doc.sum-rubl = s-1
    buf_ord-doc.sum-base = s-2
    buf_ord-doc.qnty     = s-3
    buf_ord-doc.e-method = scr-e-method
    buf_ord-doc.ship-date = scr-ship-date
    buf_ord-doc.wrkr   = scr-wrkr
    buf_ord-doc.boss   = scr-boss
    buf_ord-doc.agnt   = scr-agnt
    buf_ord-doc.cli-code = loc-cli-code
    buf_ord-doc.cli-type = loc-cli-type
    buf_ord-doc.status_     = (if buf_ord-doc.status_ = 'запрос':U then 'запрос':U else  'новый':U)
    buf_ord-doc.cli-name = scr-cli-name
    buf_ord-doc.pay-day  = scr-pay-day
    buf_ord-doc.contract-code  = loc-contract
    buf_ord-doc.deliv-type-code    = v-deliv-type-code
    buf_ord-doc.obj-point-code     = v-point-obj-code
    buf_ord-doc.cli-point-code     = v-point-cli-code
    buf_ord-doc.obj-point-db-num   = v-point-obj-db-num
    buf_ord-doc.cli-point-db-num   = v-point-cli-db-num
    buf_ord-doc.transport-host-code     = v-transport-host-code
    buf_ord-doc.transport-cli-type     = v-transport-cli-type
    buf_ord-doc.transport-cli-code     = v-transport-cli-code
    buf_ord-doc.transport-contract = v-transport-contract
    buf_ord-doc.transport-condition= v-transport-condition
    buf_ord-doc.transport-value    = v-transport-value
    buf_ord-doc.sum-ship           = v-transport-sum
    buf_ord-doc.transport-vat      = v-transport-vat
  .
  if buf_ord-doc.status_ = 'новый':U and buf_ord-doc.flag_ = false then do:
      message "Закрываем заказ до статуса ЗАПРОС+ и отправляем по новостям ? " view-as alert-box question
            buttons yes-no title "Вопрос" update t-log-4 as logical.
            if t-log-4 = true then do:
              run cus/ordorcls.p ( parparentproc, recid(buf_ord-doc) , true   ) no-error .
              if error-status :error then do:
                 if return-value begins 'izt' then do:
                    message "Товары не прошедшие по Ассортиментной политике удаляются из заказа и прописываются в примечании"
                    return-value
                    view-as alert-box information .
                 end.
                 else do:
                 message
                   error-status :get-message(1) skip
                   return-value skip
                   "Ошибка при закрытии заказа"
                   view-as alert-box error
                 .
                 end.
                 return  .
              end.
            end.
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  run proc-b-add in this-procedure .
  run recalc-head in this-procedure .
END.
ON CHOOSE OF B-calc IN FRAME Dialog-Frame
DO:
define buffer buf_ord-line for ub.ord-line.
define buffer buf_goods for ub.goods.
assign frame Dialog-Frame scr-ship-date scr-pay-day .
loc-date-ship = scr-ship-date .
if loc-date-ship < today then do:
   message "Для расчета заказа ДАТА ЗАКАЗА должна быть больше текущей " view-as alert-box information .
   return no-apply.
end.
pay-day = scr-pay-day.
if pay-day = ? or pay-day = 0 then
    message  "ПРЕДУПРЕЖДЕНИЕ :  Не задано количество дней продаж !"
    view-as alert-box information
    title "Внимание!!!".
for each tmp#zakaz :
    delete tmp#zakaz  .
end.
for each  buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num  :
    find first buf_goods no-lock where
            buf_goods.artic     = buf_ord-line.artic     and
            buf_goods.prod-type = buf_ord-line.prod-type and
            buf_goods.prod-code = buf_ord-line.prod-code .
    create tmp#zakaz .
    BUFFER-COPY buf_ord-line to tmp#zakaz
  assign
    tmp#zakaz.gds-code        = buf_goods.gds-code
    tmp#zakaz.prod-type       = buf_goods.prod-type
    tmp#zakaz.prod-code       = buf_goods.prod-code
    tmp#zakaz.artic           = buf_goods.artic
    tmp#zakaz.gds-name        = buf_goods.gds-name
    tmp#zakaz.deadline        = buf_goods.deadline
    tmp#zakaz.unit-cli        = buf_goods.unit-cli
    tmp#zakaz.unit-base       = buf_goods.unit-base
    tmp#zakaz.negative-rest   = buf_goods.negative-rest
    tmp#zakaz.cli-base-rate   = 1
    tmp#zakaz.ms-cart         = buf_goods.qnty-cart
    .
end.
if not can-find (first tmp#zakaz )  then return.
if pay-day = 0 or pay-day = ? then pay-day = 1 .
loc-store-code = v-cntxt-obj-code .
loc-store-type = v-cntxt-obj-type .
loc-doc-type   = 'ОР':U     .
run cus/ord-m.w ( input parParentProc , input ? , 'ОР':U ) .
scr-e-method = e-method .
display scr-e-method with frame Dialog-Frame .
run openbr in this-procedure .
run recalc-head in this-procedure .
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
 define variable r-stop as logical no-undo .
 define variable r-exit as logical no-undo .
 define variable r-recid as recid no-undo.
  if p-mode =  'ПРОСМОТР':U then return.
 find current x_ord-line  exclusive-lock  no-error .
 if available x_ord-line then do:
     r-recid =  recid ( x_ord-line )  .
     run cus/ord-frmo.w
       ( input parParentProc ,
         input ?         ,
         input r-recid   ,
         input 'ИЗМЕНЕНИЕ':U ,
         output r-stop   ,
         output r-exit
         ) .
     g#log =  BROWSE-2:refresh() .
 end.
    run recalc-head in this-procedure  .
END.
ON return OF B-chg IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  B-chg:handle ) .
  return no-apply .
END.
ON CHOOSE OF B-contract IN FRAME Dialog-Frame
DO:
define variable o-host-code as integer   no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  loc-obj-type
  ,input  loc-obj-code
  ,output o-host-code
  )  .
define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = loc-contract and
                                     b_contract.host-code         = o-host-code
                                     no-error .
if error-status :error then return no-apply.
run str/sh-contr.p (
  input parParentProc ,
  input recid (b_contract))
  .
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
define variable v-ii as integer no-undo .
message "Удалить запись ?"
      view-as alert-box question
      buttons yes-no
      update g-log as logical .
      if g-log = false then return no-apply.
 find current x_ord-line  exclusive-lock  no-error .
 if available x_ord-line then do:
    run x-delete in this-procedure ( recid(x_ord-line) , input-output v-ii ) no-error .
    if error-status :error then
    message vss-workfile vss-revision vss-description skip
           "Ошибка удаление 1 " skip
            skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error
    .
    run openbr in this-procedure .
 end.
    run recalc-head in this-procedure .
END.
ON CHOOSE OF B-delivery IN FRAME Dialog-Frame
DO:
  run cus/pardeliv.w
      (input        parParentproc
      ,input        p-mode
      ,input        "ord" + 'ОР':U
      ,input        loc-obj-type
      ,input        loc-obj-code
      ,input        loc-cli-type
      ,input        loc-cli-code
      ,input-output v-deliv-type-code
      ,input-output v-point-obj-code
      ,input-output v-point-obj-db-num
      ,input-output v-point-cli-code
      ,input-output v-point-cli-db-num
      ,input-output v-transport-host-code
      ,input-output v-transport-cli-type
      ,input-output v-transport-cli-code
      ,input-output v-transport-contract
      ,input-output v-transport-condition
      ,input-output v-transport-value
      ,input-output v-transport-sum
      ,input-output v-transport-vat
         ) no-error  .
         if error-status :error then message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "Ошибка"
           view-as alert-box error
         .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    next-prev = ?.
END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
run step-next in this-procedure .
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
    else do:
      if p-mode  = 'ДОБАВЛЕНИЕ':U then do:
        find first buf-or_ord-doc exclusive-lock where recid(buf-or_ord-doc) = p-ord-doc-recid  no-error.
        if available buf-or_ord-doc then
        delete buf-or_ord-doc.
      end.
    end.
END.
ON CHOOSE OF b-renum IN FRAME Dialog-Frame
DO:
run proc-renum in this-procedure .
END.
ON CHOOSE OF B-spec IN FRAME Dialog-Frame
DO:
define variable o-host-code as integer   no-undo .
define variable v-rid-list as char no-undo.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  loc-obj-type
  ,input  loc-obj-code
  ,output o-host-code
  )  .
define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = loc-contract and
                                     b_contract.host-code         = o-host-code
                                     no-error .
if error-status :error then return no-apply.
  run str/contspec.w (
      input  parparentproc,
      input  "b-mark,b-add,b-del,b-chg",
      input  p-mode,
      input  o-host-code,
      input  loc-contract,
      output v-rid-list) .
END.
ON CHOOSE OF b-spec-gds IN FRAME Dialog-Frame
DO:
  run add-spec-gds  in this-procedure .
  run recalc-head in this-procedure .
END.
ON ROW-DISPLAY OF BROWSE-2 IN FRAME Dialog-Frame
DO:
define buffer buf_prt-obj for ub.prt-obj .
define variable p-node as integer   no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  x_ord-line.artic
  ,input  x_ord-line.prod-type
  ,input  x_ord-line.prod-code
  ,output p-node
  )  .
  find first buf_prt-obj no-lock where
            buf_prt-obj.prt-code  = p-node and
            buf_prt-obj.artic     = x_ord-line.artic     and
            buf_prt-obj.prod-type = x_ord-line.prod-type and
            buf_prt-obj.prod-code = x_ord-line.prod-code and
            buf_prt-obj.obj-type  = loc-cli-type and
            buf_prt-obj.obj-code  = loc-cli-code
            no-error .
   if available buf_prt-obj
      then
         assign
            v-rc-qnty = buf_prt-obj.fact-qnty
            v-rc-qnty-free = buf_prt-obj.free-qnty
         .
      else
         assign
            v-rc-qnty = 0
            v-rc-qnty-free = 0
         .
END.
ON MOUSE-SELECT-DBLCLICK OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  apply "CHOOSE" to B-chg .
END.
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
 define variable rid-list    as  char no-undo .
 define variable old-types as character no-undo .
    run ref/cli-all.w
        (input parparentproc,
         input "b-sel",
         'маг':U,
         ?,
         ?,
         ?,
         ?,
         ?,
         output  rid-list) no-error .
         if error-status :error or
         rid-list = "" or rid-list = ?
         then return no-apply .
    assign
      v-recid-RC = integer(rid-list)
      .
    find first cli#clients no-lock WHERE recid(cli#clients) = v-recid-RC  No-ERROR.
    if avail cli#clients then do:
          run ver-clients  (cli#clients.obj-type , cli#clients.obj-code , output g#log) .
          if g#log then return no-apply.
        Assign
            scr-cli = cli#clients.obj-code
            loc-cli-code = cli#clients.obj-code
            loc-cli-type = cli#clients.obj-type
            scr-cli-name = cli#clients.obj-name
            .
     end.
        else
          assign
              scr-cli-name = ""
              scr-cli      = ?
              loc-cli-code = ?
              loc-cli-type = ""
              .
display scr-cli scr-cli-name with frame Dialog-Frame .
 run p-cont .
END.
ON return OF scr-agnt IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-agnt:handle ) .
  return no-apply .
END.
ON return OF scr-agnt-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-agnt-name:handle ) .
  return no-apply .
END.
ON return OF scr-boss IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-boss:handle ) .
  return no-apply .
END.
ON return OF scr-boss-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-boss-name:handle ) .
  return no-apply .
END.
ON return OF scr-cli IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-cli:handle ) .
  return no-apply .
END.
ON return OF scr-ship-date IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  scr-ship-date:handle ) .
  return no-apply .
END.
ON return OF scr-wrkr IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-wrkr:handle ) .
  return no-apply .
END.
ON return OF scr-wrkr-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-wrkr-name:handle ) .
  return no-apply .
END.
ON VALUE-CHANGED OF t-auto IN FRAME Dialog-Frame
DO:
  assign   frame Dialog-Frame t-auto.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
assign
  scr-sum-rubl :label = "Итого сумма (руб)"
.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BROWSE-2 :SET-REPOSITIONED-ROW(8, "CONDITIONAL") .
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of scr-ship-date in frame Dialog-Frame
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
on delete-character of scr-ship-date in frame Dialog-Frame
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
on ctrl-d of scr-ship-date in frame Dialog-Frame
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
on ctrl-b of scr-ship-date in frame Dialog-Frame
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
on ctrl-e of scr-ship-date in frame Dialog-Frame
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
on ctrl-f of scr-ship-date in frame Dialog-Frame
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
  define MENU m-ed-date26
    MENU-ITEM m-ed-date26-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date26-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date26-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date26-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if scr-ship-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      scr-ship-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date26 :HANDLE
      scr-ship-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle26 as handle no-undo .
  assign
    v-label-handle26 = scr-ship-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle26)
  then do:
    if v-label-handle26 :tooltip = ""
    or v-label-handle26 :tooltip = ?
    then do:
      assign
        v-label-handle26 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date26-1 in menu m-ed-date26 DO:
    apply "ctrl-b":U to scr-ship-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-2 in menu m-ed-date26 DO:
    apply "ctrl-d":U to scr-ship-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-3 in menu m-ed-date26 DO:
    apply "ctrl-e":U to scr-ship-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-4 in menu m-ed-date26 DO:
    apply "ctrl-f":U to scr-ship-date in frame Dialog-Frame .
  END.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-2 :handle
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
def var sort-labelBROWSE-2   as character no-undo .
def var sort-clmnBROWSE-2    as handle    no-undo .
def var cur-clmnBROWSE-2     as handle    no-undo .
def var cur-clmn-locBROWSE-2 as integer   no-undo .
def var re-queryBROWSE-2     as logical   initial no no-undo .
on start-search, ctrl-o of BROWSE-2 in frame Dialog-Frame do:
   run sort-brBROWSE-2
     (input (if available X_ord-line
             then recid(X_ord-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brBROWSE-2 :
  define input parameter p-recid as recid no-undo .
  if re-queryBROWSE-2 = no then do:
    assign
       cur-clmnBROWSE-2 = BROWSE-2:current-column in frame Dialog-Frame
    .
    if sort-clmnBROWSE-2 <> ? then sort-clmnBROWSE-2:column-fgcolor = 0.
    if cur-clmnBROWSE-2 = sort-clmnBROWSE-2 then do:
      assign
         sort-labelBROWSE-2 = ""
         sort-clmnBROWSE-2 = ?
      .
     end.
     else do:
       assign
         sort-labelBROWSE-2 = cur-clmnBROWSE-2:label
         sort-clmnBROWSE-2  = cur-clmnBROWSE-2
         sort-clmnBROWSE-2:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBROWSE-2 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BROWSE-2:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBROWSE-2 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBROWSE-2 = cur-clmn-locBROWSE-2 + 1
    .
  end.
  case sort-labelBROWSE-2:
        when 'N/п'  then DO:   assign     sort-column-name = "X_ord-line.line-num"   .   Run OpenBr.   . END.
        when 'Код'  then DO:   assign     sort-column-name = "X_goods.gds-code"   .   Run OpenBr.   . END.
        when 'Артикул'  then DO:   assign     sort-column-name = "X_ord-line.artic"   .   Run OpenBr.   . END.
        when 'Название'  then DO:   assign     sort-column-name = "X_goods.gds-name"   .   Run OpenBr.   . END.
        when 'Кол-во'  then DO:   assign     sort-column-name = "X_ord-line.qnty"   .   Run OpenBr.   . END.
        when 'Рекомен-!довано  '  then DO:   assign     sort-column-name = "X_ord-line.initial-qnty"   .   Run OpenBr.   . END.
        when 'ед.!изм'  then DO:   assign     sort-column-name = "X_goods.unit-base"   .   Run OpenBr.   . END.
        when 'Заказано!в днях'  then DO:   assign     sort-column-name = "( if X_ord-line.temp-rash <> 0 then X_ord-line.order-qnty / X_ord-line.temp-rash  else 0 )"   .   Run OpenBr.   . END.
        when 'Заказано'  then DO:   assign     sort-column-name = "X_ord-line.order-qnty"   .   Run OpenBr.   . END.
        when 'Текущий!остаток РЦ'  then DO:   assign     sort-column-name = "v-rc-qnty"   .   Run OpenBr.   . END.
        when 'ABC1'  then DO:   assign     sort-column-name = "(chr(int(X_ord-line.add-cli-qnty)) + string(X_ord-line.add-qnty))"   .   Run OpenBr.   . END.
        when 'ABC2'  then DO:   assign     sort-column-name = "(chr(int(X_ord-line.cancel-cli-qnty)) + string(X_ord-line.cancel-qnty))"   .   Run OpenBr.   . END.
        when 'Темп'  then DO:   assign     sort-column-name = "X_ord-line.temp-rash"   .   Run OpenBr.   . END.
        when 'Свободный!остаток РЦ'  then DO:   assign     sort-column-name = "v-rc-qnty-free"   .   Run OpenBr.   . END.
        when 'Остаток на!момент расчета'  then DO:   assign     sort-column-name = "X_ord-line.qnty-stk"   .   Run OpenBr.   . END.
        when 'Остаток!в днях'  then DO:   assign     sort-column-name = "( if X_ord-line.temp-rash <> 0 then X_ord-line.qnty-stk / X_ord-line.temp-rash  else 0 )"   .   Run OpenBr.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      Run OpenBr.
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBROWSE-2') then do:
          run mv-brw-defaultBROWSE-2.
        end.
      if sort-labelBROWSE-2 <> "" then do:
        assign
          cur-clmnBROWSE-2:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBROWSE-2 = ?
      .
    end.
  end case.
    if cur-clmn-locBROWSE-2 <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBROWSE-2') then do:
        run ch-clmnBROWSE-2 in this-procedure (cur-clmn-locBROWSE-2).
      end.
    end.
  if p-recid <> ? then do:
    reposition BROWSE-2 to recid p-recid no-error.
    apply "value-changed" to BROWSE-2 in frame Dialog-Frame.
  end.
  apply "entry" to BROWSE-2 in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBROWSE-2:
if cur-clmnBROWSE-2 = ? then do:
   Run OpenBr.
end.
else do:
   assign re-queryBROWSE-2 = yes.
   run sort-brBROWSE-2
     (input (if available X_ord-line
             then recid(X_ord-line)
             else ?
            )
     ).
   assign re-queryBROWSE-2 = no.
end.
end.
X_ord-line.line-num:resizable in browse BROWSE-2   = true .
X_goods.gds-code:resizable in browse BROWSE-2   = true .
X_ord-line.artic:resizable in browse BROWSE-2   = true .
X_goods.gds-name:resizable in browse BROWSE-2   = true .
X_ord-line.qnty:resizable in browse BROWSE-2   = true .
X_goods.unit-base:resizable in browse BROWSE-2   = true .
X_ord-line.initial-qnty:resizable in browse BROWSE-2   = true .
X_ord-line.order-qnty:resizable in browse BROWSE-2   = true .
v-rc-qnty:resizable in browse BROWSE-2   = true .
X_ord-line.temp-rash:resizable in browse BROWSE-2   = true .
v-rc-qnty-free:resizable in browse BROWSE-2   = true .
X_ord-line.qnty-stk:resizable in browse BROWSE-2   = true .
X_ord-line.line-num:width     in browse BROWSE-2   = v-size-col1 .
X_goods.gds-code:width     in browse BROWSE-2   = v-size-col2 .
X_ord-line.artic:width     in browse BROWSE-2   = v-size-col3 .
X_goods.gds-name:width     in browse BROWSE-2   = v-size-col4 .
X_ord-line.qnty:width     in browse BROWSE-2   = v-size-col5 .
X_goods.unit-base:width     in browse BROWSE-2   = v-size-col7 .
v-rc-qnty:width     in browse BROWSE-2   = v-size-col10.
X_ord-line.temp-rash:width     in browse BROWSE-2   = v-size-col13.
v-rc-qnty-free:width     in browse BROWSE-2   = v-size-col14.
X_ord-line.qnty-stk:width     in browse BROWSE-2   = v-size-col15.
X_ord-line.initial-qnty:width      in browse BROWSE-2   = v-size-col6.
X_ord-line.order-qnty:width      in browse BROWSE-2   = v-size-col9.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  run init-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to browse-2 in frame Dialog-Frame.
  return no-apply.
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON CHOOSE OF r-boss IN FRAME Dialog-Frame
DO:
   run proc-r-boss in this-procedure .
END.
ON LEAVE OF scr-boss IN FRAME Dialog-Frame
DO:
run leave-proc-boss in this-procedure .
END.
ON  RETURN OF scr-boss IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  scr-boss:handle ) .
  return no-apply .
END.
ON MOUSE-SELECT-DBLCLICK OF scr-boss IN FRAME Dialog-Frame
DO:
  apply "choose" to r-boss in frame Dialog-Frame.
  return no-apply .
end.
Procedure proc-r-boss :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define variable rid-list    as  char no-undo .
 define variable v-recid as recid no-undo .
 define variable old-types as character no-undo .
 define buffer boss#clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc, input "b-sel", 'чел':U, ?, ?, ?, ?, ?, output  rid-list).
    Assign
      v-recid = integer(rid-list)
      .
    find first boss#clients no-lock WHERE recid(boss#clients) = v-recid  No-ERROR.
    if avail boss#clients then
        Assign
            scr-boss = boss#clients.obj-code
            scr-boss-name = boss#clients.obj-name
            .
    else
       Assign
          scr-boss-name = ""
          scr-boss = ?
          .
    Display scr-boss scr-boss-name with frame Dialog-Frame .
end.
end procedure.
procedure leave-proc-boss :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  def buffer buf_clients for ub.clients.
  Assign frame Dialog-Frame scr-boss .
  if scr-boss <> ? and scr-boss <> 0 then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = 'чел':U  and
                buf_clients.obj-code  = scr-boss no-error.
          if error-status :error or not available buf_clients then do:
              Message "Неправильно задан "  scr-boss:label in frame Dialog-Frame.
                Assign
                scr-boss-name = ""
                scr-boss = ?
                .
              Display  scr-boss scr-boss-name with frame Dialog-Frame.
              apply "CHOOSE" to r-boss in frame Dialog-Frame .
          end.
          if available buf_clients Then DO:
                scr-boss      = buf_clients.obj-code .
                scr-boss-name = buf_clients.obj-name .
          End.
 End.
 else do:
      Assign
        scr-boss-name = ""
        scr-boss = ?
        .
  end.
 Display  scr-boss scr-boss-name with frame Dialog-Frame.
 end.
end procedure.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON CHOOSE OF r-agnt IN FRAME Dialog-Frame
DO:
   run proc-r-agnt in this-procedure .
END.
ON LEAVE OF scr-agnt IN FRAME Dialog-Frame
DO:
run leave-proc-agnt in this-procedure .
END.
ON  RETURN OF scr-agnt IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  scr-agnt:handle ) .
  return no-apply .
END.
ON MOUSE-SELECT-DBLCLICK OF scr-agnt IN FRAME Dialog-Frame
DO:
  apply "choose" to r-agnt in frame Dialog-Frame.
  return no-apply .
end.
Procedure proc-r-agnt :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define variable rid-list    as  char no-undo .
 define variable v-recid as recid no-undo .
 define variable old-types as character no-undo .
 define buffer agnt#clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc, input "b-sel", 'чел':U, ?, ?, ?, ?, ?, output  rid-list).
    Assign
      v-recid = integer(rid-list)
      .
    find first agnt#clients no-lock WHERE recid(agnt#clients) = v-recid  No-ERROR.
    if avail agnt#clients then
        Assign
            scr-agnt = agnt#clients.obj-code
            scr-agnt-name = agnt#clients.obj-name
            .
    else
       Assign
          scr-agnt-name = ""
          scr-agnt = ?
          .
    Display scr-agnt scr-agnt-name with frame Dialog-Frame .
end.
end procedure.
procedure leave-proc-agnt :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  def buffer buf_clients for ub.clients.
  Assign frame Dialog-Frame scr-agnt .
  if scr-agnt <> ? and scr-agnt <> 0 then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = 'чел':U  and
                buf_clients.obj-code  = scr-agnt no-error.
          if error-status :error or not available buf_clients then do:
              Message "Неправильно задан "  scr-agnt:label in frame Dialog-Frame.
                Assign
                scr-agnt-name = ""
                scr-agnt = ?
                .
              Display  scr-agnt scr-agnt-name with frame Dialog-Frame.
              apply "CHOOSE" to r-agnt in frame Dialog-Frame .
          end.
          if available buf_clients Then DO:
                scr-agnt      = buf_clients.obj-code .
                scr-agnt-name = buf_clients.obj-name .
          End.
 End.
 else do:
      Assign
        scr-agnt-name = ""
        scr-agnt = ?
        .
  end.
 Display  scr-agnt scr-agnt-name with frame Dialog-Frame.
 end.
end procedure.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame
DO:
   run proc-r-wrkr in this-procedure .
END.
ON LEAVE OF scr-wrkr IN FRAME Dialog-Frame
DO:
run leave-proc-wrkr in this-procedure .
END.
ON  RETURN OF scr-wrkr IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  scr-wrkr:handle ) .
  return no-apply .
END.
ON MOUSE-SELECT-DBLCLICK OF scr-wrkr IN FRAME Dialog-Frame
DO:
  apply "choose" to r-wrkr in frame Dialog-Frame.
  return no-apply .
end.
Procedure proc-r-wrkr :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define variable rid-list    as  char no-undo .
 define variable v-recid as recid no-undo .
 define variable old-types as character no-undo .
 define buffer wrkr#clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc, input "b-sel", 'чел':U, ?, ?, ?, ?, ?, output  rid-list).
    Assign
      v-recid = integer(rid-list)
      .
    find first wrkr#clients no-lock WHERE recid(wrkr#clients) = v-recid  No-ERROR.
    if avail wrkr#clients then
        Assign
            scr-wrkr = wrkr#clients.obj-code
            scr-wrkr-name = wrkr#clients.obj-name
            .
    else
       Assign
          scr-wrkr-name = ""
          scr-wrkr = ?
          .
    Display scr-wrkr scr-wrkr-name with frame Dialog-Frame .
end.
end procedure.
procedure leave-proc-wrkr :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  def buffer buf_clients for ub.clients.
  Assign frame Dialog-Frame scr-wrkr .
  if scr-wrkr <> ? and scr-wrkr <> 0 then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = 'чел':U  and
                buf_clients.obj-code  = scr-wrkr no-error.
          if error-status :error or not available buf_clients then do:
              Message "Неправильно задан "  scr-wrkr:label in frame Dialog-Frame.
                Assign
                scr-wrkr-name = ""
                scr-wrkr = ?
                .
              Display  scr-wrkr scr-wrkr-name with frame Dialog-Frame.
              apply "CHOOSE" to r-wrkr in frame Dialog-Frame .
          end.
          if available buf_clients Then DO:
                scr-wrkr      = buf_clients.obj-code .
                scr-wrkr-name = buf_clients.obj-name .
          End.
 End.
 else do:
      Assign
        scr-wrkr-name = ""
        scr-wrkr = ?
        .
  end.
 Display  scr-wrkr scr-wrkr-name with frame Dialog-Frame.
 end.
end procedure.
on end-error, stop of frame Dialog-Frame  do:
  apply "choose" to b-exit in frame Dialog-Frame .
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable loc-order-type as integer no-undo .
define variable v-i-doc as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-int as integer   no-undo .
define variable v-value-logical as logical   no-undo .
define variable par-type as character no-undo .
define buffer bufc_clients for ub.clients  .
  if p-mode <> 'ПРОСМОТР':U then do:
  empty temp-table thbjattr_thbj-attr .
    run adm/shattri.p (
     input "get":U
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input 'ord-obj':U
    ,input ""
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-int
    ,output v-value-logical
    ,output par-type
    ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
    ) no-error .
    for each thbjattr_thbj-attr :
       if thbjattr_thbj-attr.prop-code = "ord-askp"    then v-ord-askp    =  thbjattr_thbj-attr.property-value-logical.
       if thbjattr_thbj-attr.prop-code = "ord-obj-rc"  then v-ord-obj-rc  =  thbjattr_thbj-attr.property-value-character.
    end.
    if p-mode  = 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
      if ( loc-cli-code = 0  or loc-cli-code = ? ) and v-ord-obj-rc <> ""  then  do:
          assign
          loc-cli-type = substring(v-ord-obj-rc,1,3)
          loc-cli-code = int(substring(v-ord-obj-rc,4,10))
          no-error
          .
          if not error-status :error then DO:
           find first bufc_clients no-lock where
                      bufc_clients.obj-code = loc-cli-code and
                      bufc_clients.obj-type = loc-cli-type no-error .
           if available bufc_clients then do:
           scr-cli-name = bufc_clients.obj-name .
           scr-cli = loc-cli-code               .
           end.
          display
            scr-cli
            scr-cli-name
            with frame Dialog-Frame .
            loc-obj-type = v-cntxt-obj-type .
            loc-obj-code = v-cntxt-obj-code .
            run p-cont .
          END.
      end.
      run create-ord-doc in this-procedure (
          input loc-ord-num  ,
          input loc-cli-code ,
          input loc-cli-type ,
          input ""           ,
          input ""           ,
          input v-cntxt-host-code-obj ,
          input v-cntxt-obj-code      ,
          input v-cntxt-obj-type      ,
          input 'ОР':U       ,
          input 'новый':U   ,
          input today        ,
          input today        ,
          input  loc-order-type ,
          input  loc-contract ,
          output p-ord-doc-recid )
          .
    end.
  do transaction on error undo, return error return-value :
    find first buf_ord-doc  exclusive-lock  where
         recid(buf_ord-doc) = p-ord-doc-recid no-error .
         if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
                "Ошибка  " skip
                 skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error
         .
         return error.
         end.
  end.
 loc-ord-num = buf_ord-doc.doc-code .
X_ord-line.qnty:read-only in browse BROWSE-2 = true .
scr-e-method:read-only in frame Dialog-Frame  = true .
    run recalc-head in this-procedure .
    run my-enable_ui in this-procedure .
  end.
  else do:
      find first buf_ord-doc  no-lock where
           recid(buf_ord-doc) = p-ord-doc-recid no-error .
         if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
                "Ошибка просмотра " skip
                 skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error
         .
         return error.
         end.
      loc-ord-num = buf_ord-doc.doc-code .
      run recalc-head in this-procedure .
      run my-enable-lkp in this-procedure .
  end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numBROWSE-2 as INT EXTENT 16 no-undo.
DEF VAR varmviBROWSE-2       as INT no-undo.
DEF VAR varmvjBROWSE-2       as INT no-undo.
DEF VAR varmvkBROWSE-2       as INT no-undo.
DEF VAR varmvlBROWSE-2       as INT no-undo.
DEF VAR move-elementBROWSE-2 as INT no-undo.
def var jjBROWSE-2           as int no-undo.
do varmviBROWSE-2 = 1 to EXTENT(cur-clmn-numBROWSE-2):
  ASSIGN cur-clmn-numBROWSE-2[varmviBROWSE-2] = varmviBROWSE-2.
END.
RUN start-mv-clmnBROWSE-2.
PROCEDURE start-mv-clmnBROWSE-2:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  true = true   THEN DO:
   DO jjBROWSE-2 = NUM-ENTRIES(v-order-col) TO 1 BY -1:
     RUN re-move-clmnBROWSE-2 ( cur-clmn-numBROWSE-2[INTEGER(ENTRY (jjBROWSE-2, v-order-col))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE BROWSE-2 do:
  RUN re-move-clmnBROWSE-2 ( 1, 16).
END.
ON ctrl-cursor-left OF BROWSE BROWSE-2 do:
  RUN re-move-clmnBROWSE-2 (16, 1).
END.
PROCEDURE re-move-clmnBROWSE-2:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviBROWSE-2 = 1 TO EXTENT(cur-clmn-numBROWSE-2):
    if cur-clmn-numBROWSE-2[varmviBROWSE-2] = source-column THEN cur-clmn-numBROWSE-2[varmviBROWSE-2] = -1.
  END.
  if BROWSE-2:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjBROWSE-2 = source-column - 1 to target-column BY -1:
    DO varmviBROWSE-2 = 1 TO EXTENT(cur-clmn-numBROWSE-2):
        if cur-clmn-numBROWSE-2[varmviBROWSE-2] = varmvjBROWSE-2 THEN DO:
          cur-clmn-numBROWSE-2[varmviBROWSE-2] = cur-clmn-numBROWSE-2[varmviBROWSE-2] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjBROWSE-2 = source-column + 1 to target-column:
    DO varmviBROWSE-2 = 1 TO EXTENT(cur-clmn-numBROWSE-2):
      if cur-clmn-numBROWSE-2[varmviBROWSE-2] = varmvjBROWSE-2 THEN DO:
        cur-clmn-numBROWSE-2[varmviBROWSE-2] = cur-clmn-numBROWSE-2[varmviBROWSE-2] - 1.
      END.
    END.
  END.
  DO varmviBROWSE-2 = 1 TO EXTENT(cur-clmn-numBROWSE-2):
    if cur-clmn-numBROWSE-2[varmviBROWSE-2] = -1 THEN cur-clmn-numBROWSE-2[varmviBROWSE-2] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnBROWSE-2:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmviBROWSE-2 = 1 TO EXTENT(cur-clmn-numBROWSE-2):
    if cur-clmn-numBROWSE-2[varmviBROWSE-2] = cur-clmn-loc THEN move-elementBROWSE-2 = varmviBROWSE-2.
  END.
  RUN re-move-clmnBROWSE-2 (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultBROWSE-2:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlBROWSE-2 = 1 to EXTENT(cur-clmn-numBROWSE-2):
    RUN re-move-clmnBROWSE-2 (cur-clmn-numBROWSE-2[varmvlBROWSE-2], varmvlBROWSE-2).
  END.
  RUN start-mv-clmnBROWSE-2.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
if  ( (buf_ord-doc.status_ = 'новый':U ) or
    (  buf_ord-doc.status_ = 'запрос':U and buf_ord-doc.flag_ = false )) then do:
       X_ord-line.order-qnty :visible  in browse BROWSE-2    =  false .
end.
else do:
   X_ord-line.order-qnty :visible  in browse BROWSE-2    =  true  .
end.
if p-mode  = 'ДОБАВЛЕНИЕ':U then X_ord-line.order-qnty :visible  in browse BROWSE-2    =  false .
if buf_ord-doc.status_ = 'запрос':U then
  disable b-add b-calc b-del r-cli
          scr-ship-date scr-pay-day
          scr-wrkr  r-wrkr
          scr-agnt  r-agnt
          scr-boss  r-boss
  with frame Dialog-Frame .
if p-mode <> 'ПРОСМОТР':U  then do:
  if p-mode  = 'ДОБАВЛЕНИЕ':U
  then
       wait-for go  of frame Dialog-Frame focus  scr-ship-date.
  else
      wait-for go  of frame Dialog-Frame focus browse-2.
end.
else do:
      wait-for go  of frame Dialog-Frame focus b-exit.
end.
END.
run disable_ui in this-procedure .
PROCEDURE add-spec-gds :
define variable ii as integer   no-undo .
define variable v-i as integer   no-undo .
define variable t-ret as logical   no-undo .
define variable r-tmp as recid no-undo .
define variable r-ord as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-choice as integer   no-undo .
define buffer buf_ord-line for ub.ord-line  .
define buffer bf_contract-specif for ub.contract-specif  .
  do
  on error undo, return error return-value
  :
if loc-contract = 0 or loc-contract = ? then return .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
if not available bf_contract-specif then return .
      run gbl/d-askw.w
        (input "Данные из спецификации"
        ,input "Выберите один из пунктов для добавления в заказ" + chr(10)
             + "товаров по спецификации к договору" + chr(10)
        ,input "|"
        ,input "Все|Выборочно|Обновить|Отказ"
        ,input "Все недобавленные товары по спецификации|"
             + "Выборочно товары по спецификации|"
             + "Обновить цены из спецификации|"
             + "Отказ от выполнения операции"
        ,input 1
        ,input 4
        ,output v-choice
        ).
      if v-choice = 4 then do:
        return.
      end.
t-ret =  session:set-wait-state("general") .
ii = 0.
case v-choice :
when 1 then do:
   line-mode = 'ДОБАВЛЕНИЕ':U .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
FOR EACH
    ub.contract-specif
     NO-LOCK
     WHERE
         ub.contract-specif.Host-code    = i-gl-Host-Code
     AND ub.contract-specif.Contract-num = i-gl-Contract-Code
     :
       find first  buf_ord-line  exclusive-lock      where
                buf_ord-line.gds-code = ub.contract-specif.gds-code  and
                buf_ord-line.doc-code = loc-ord-num
                no-error .
          if available buf_ord-line then do:
             run cus/ord-frmo.w (parParentProc , input ?  , input recid ( buf_ord-line)  , input 'ИЗМЕНЕНИЕ':U,  output r-stop , output r-exit ) no-error .
          end.
          else do:
              ii = ii + 1 .
              run create-tmp-contr-sp in this-procedure  ( input (recid(ub.contract-specif)) , output r-tmp , output r-ord).
              if not t-auto then do:
                    run cus/ord-frmo.w
                      ( input parParentProc ,
                        input r-tmp  ,
                        input r-ord  ,
                        input line-mode,
                        output r-stop ,
                        output r-exit ) .
                      if r-stop then do:
                          run p-delete in this-procedure
                            ( r-tmp , input-output ii).
                          leave.
                      end.
                      if r-exit then do:
                          run p-delete in this-procedure
                              ( r-tmp , input-output ii ) .
                      end.
              end.
          end.
   end.
end.
when 2 then do:
   run str/contspec.w (input parparentproc,
                      input "b-sel,b-mark",
                      input 'ПРОСМОТР':U,
                      input v-cntxt-host-code-obj,
                      input loc-contract,
                      output v-rid-list) .
      if v-rid-list = '':u then do:
        message "Нет выбранных товаров по спецификации."
          view-as alert-box.
      end.
    line-mode = 'ДОБАВЛЕНИЕ':U .
    do v-i = 1 to num-entries(v-rid-list) :
     find ub.contract-specif where recid(ub.contract-specif) = integer(entry(v-i, v-rid-list)) no-lock no-error.
     if error-status :error then next.
     ii = ii + 1 .
     run create-tmp-contr-sp in this-procedure  (input recid(ub.contract-specif), output r-tmp , output r-ord).
        find first tmp#zakaz where
                   tmp#zakaz.gds-code = ub.contract-specif.gds-code no-error .
        if not  error-status :error  and not t-auto then do:
            r-tmp = recid ( tmp#zakaz   ) .
            run cus/ord-frmo.w
              ( input parParentProc ,
                input r-tmp  ,
                input r-ord  ,
                input line-mode,
                output r-stop ,
                output r-exit ) .
            if r-stop then do:
              run p-delete ( r-tmp , input-output ii).
              leave.
            end.
            if r-exit then do:
               run p-delete( r-tmp ,input-output ii ) .
            end.
        end.
   end.
end.
when 3 then do:
   v-update-price = 0 .
   for each tmp#zakaz :
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST ub.contract-specif
           NO-LOCK
           WHERE
               ub.contract-specif.Host-code    = i-gl-Host-Code
           AND ub.contract-specif.Contract-num = i-gl-Contract-Code
           AND ub.contract-specif.Gds-code     = tmp#zakaz.gds-code
           NO-ERROR
           .
   if not available ub.contract-specif then next .
     ii = ii + 1 .
     run create-tmp-contr-sp in this-procedure  ( input recid(ub.contract-specif) , output r-tmp , output r-ord).
   end.
end.
end case.
choice = ?.
run openbr in this-procedure  .
t-ret =  session:set-wait-state("") .
message
( if v-choice = 3
  then substitute("Исправлено  &1 из " ,v-update-price )
  else  'Добавлено'  )
  ii 'товаров'
  view-as alert-box information
  .
  ii = 0.
  v-update-price = 0 .
end.
END PROCEDURE.
PROCEDURE create-ord-doc :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-code   like  ub.ord-doc.doc-code  no-undo .
define input parameter p-cli-code   like  ub.ord-doc.cli-code  no-undo .
define input parameter p-cli-type   like  ub.ord-doc.cli-type  no-undo .
define input parameter p-cli-name   like  ub.ord-doc.cli-name  no-undo .
define input parameter p-cons-code  like  ub.ord-doc.cons-code no-undo .
define input parameter p-host-code  like  ub.ord-doc.host-code no-undo .
define input parameter p-obj-code   like  ub.ord-doc.obj-code  no-undo .
define input parameter p-obj-type   like  ub.ord-doc.obj-type  no-undo .
define input parameter p-doc-type   like  ub.ord-doc.doc-type  no-undo .
define input parameter p-status_    like  ub.ord-doc.status_   no-undo .
define input parameter p-doc-date   like  ub.ord-doc.doc-date  no-undo .
define input parameter p-ship-date  like  ub.ord-doc.ship-date no-undo .
define input parameter p-order-type like  ub.ord-doc.order-type    no-undo .
define input parameter p-contract-code like  ub.ord-doc.contract-code    no-undo .
define output parameter p-recid as recid no-undo .
define variable v-i-doc as character no-undo .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
   create ub.ord-doc.
   assign
      ub.ord-doc.doc-code   = p-doc-code
      ub.ord-doc.cli-code   = p-cli-code
      ub.ord-doc.cli-type   = p-cli-type
      ub.ord-doc.cli-name   = p-cli-name
      ub.ord-doc.cons-code  = p-cons-code
      ub.ord-doc.host-code  = p-host-code
      ub.ord-doc.obj-code   = p-obj-code
      ub.ord-doc.obj-type   = p-obj-type
      ub.ord-doc.doc-type   = p-doc-type
      ub.ord-doc.status_    = p-status_
      ub.ord-doc.doc-date   = p-doc-date
      ub.ord-doc.ship-date  = p-ship-date
      ub.ord-doc.order-type = p-order-type
      ub.ord-doc.contract-code = p-contract-code
      p-recid = recid (ub.ord-doc)
      .
  end.
END PROCEDURE.
PROCEDURE create-tmp :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter tt     as char no-undo.
define input parameter t      as char no-undo.
define output parameter p-tmp as recid no-undo .
define output parameter p-ord as recid no-undo .
define variable prod-type#   like ub.ord-line.prod-type no-undo .
define variable prod-code#   like ub.ord-line.prod-code no-undo .
define variable artic#       like ub.ord-line.artic     no-undo .
define buffer ll-buf_ord-line for ub.ord-line .
define variable p-recid as recid no-undo .
      find first ub.goods where
            ub.goods.artic     = tt-gds-list.artic     and
            ub.goods.prod-type = tt-gds-list.prod-type and
            ub.goods.prod-code = tt-gds-list.prod-code no-lock no-error.
            if error-status :error  then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо ! tt-gds-list не = ub.goods !"
                1
                view-as alert-box error .
            end.
      find  first ub.gds-obj  where
            ub.gds-obj.obj-type  = v-cntxt-obj-type and
            ub.gds-obj.obj-code  = v-cntxt-obj-code and
            ub.gds-obj.artic     = tt-gds-list.artic      and
            ub.gds-obj.prod-type = tt-gds-list.prod-type  and
            ub.gds-obj.prod-code = tt-gds-list.prod-code  no-lock no-error.
define buffer bufff-units for ub.units.
define variable t-type as character no-undo .
find first tmp#zakaz   where
           tmp#zakaz.prod-type = ub.goods.prod-type and
           tmp#zakaz.prod-code = ub.goods.prod-code and
           tmp#zakaz.artic     = ub.goods.artic     no-error.
 if not available tmp#zakaz  then  create tmp#zakaz .
  assign
    tmp#zakaz.doc-code      = loc-ord-num
    tmp#zakaz.gds-code      = ub.goods.gds-code
    tmp#zakaz.prod-type     = ub.goods.prod-type
    tmp#zakaz.prod-code     = ub.goods.prod-code
    tmp#zakaz.artic         = ub.goods.artic
    tmp#zakaz.gds-name      = ub.goods.gds-name
    tmp#zakaz.deadline      = ub.goods.deadline
    tmp#zakaz.unit-cli      = ub.goods.unit-cli
    tmp#zakaz.unit-base     = ub.goods.unit-base
    tmp#zakaz.negative-rest = ub.goods.negative-rest
    tmp#zakaz.cli-base-rate = 1
    tmp#zakaz.cli-qnty = 1
    tmp#zakaz.qnty = 1
    tmp#zakaz.ms-cart       = ub.goods.qnty-cart
    .
    define variable max-num as integer no-undo .
    max-num = 0.
    for each  ll-buf_ord-line no-lock  where ll-buf_ord-line.doc-code = loc-ord-num :
        if max-num < ll-buf_ord-line.line-num then
           max-num = ll-buf_ord-line.line-num .
    end.
    tmp#zakaz.line-num = max-num + 1.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output tmp#zakaz.vat-pc
  ) no-error .
  .
  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-type       = bufff-units.type .
  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-cli-type       = bufff-units.type .
define variable v1-host-code as integer   no-undo .
define variable v1-obj-type as character no-undo .
define variable v1-obj-code as integer   no-undo .
if flag = false  then do:
    if v-ord-askp then
        message
          substitute ( "Цена берется с объекта РЦ &1&2 ? " , loc-cli-type , loc-cli-code )
          view-as alert-box question
          buttons yes-no
          update v-quest
          .
    else
      v-quest = false .
     flag = true .
end.
if v-quest then do:
    find first ub.gds-obj no-lock    where
        ub.gds-obj.obj-type   = loc-cli-type and
        ub.gds-obj.obj-code   = loc-cli-code and
        ub.gds-obj.prod-type  = ub.goods.prod-type and
        ub.gds-obj.prod-code  = ub.goods.prod-code and
        ub.gds-obj.artic      = ub.goods.artic
        no-error.
    if error-status :error then do:
      message  substitute( "Неизвестна ИНФОРМАЦИЯ по товару &4 &1 по объекту &2&3 берем с текущего", ub.goods.gds-name, loc-cli-type, loc-cli-code , ub.goods.artic )   view-as alert-box information .
      v1-obj-type = v-cntxt-obj-type.
      v1-obj-code = v-cntxt-obj-code.
    end.
    ELSE DO:
      v1-obj-type = loc-cli-type.
      v1-obj-code = loc-cli-code.
    END.
end.
else do:
  v1-obj-type = v-cntxt-obj-type.
  v1-obj-code = v-cntxt-obj-code.
end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v1-obj-type
  ,input  v1-obj-code
  ,output v1-host-code
  )  .
find first ub.gds-obj no-lock    where
    ub.gds-obj.obj-type        = v1-obj-type and
    ub.gds-obj.obj-code        = v1-obj-code and
    ub.gds-obj.prod-type       = ub.goods.prod-type and
    ub.gds-obj.prod-code       = ub.goods.prod-code and
    ub.gds-obj.artic           = ub.goods.artic
    no-error.
    if available ub.gds-obj then do:
        define variable v-baz-val     as integer no-undo .
        define variable v-base-rate   as decimal no-undo .
        define variable v-base-scale  as decimal no-undo .
        define variable p-r-b-abbr    as character no-undo .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v1-host-code
  ,output v-baz-val
  )  .
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output p-r-b-abbr
  )  .
        if p-r-b-abbr = 'rubl':U then do:
              if v-baz-val = 0 then
                  assign
                    tmp#zakaz.price-base = ub.gds-obj.price-sale
                    tmp#zakaz.price-rubl = ub.gds-obj.price-sale
                    tmp#zakaz.price-cli  = ub.gds-obj.price-sale
                  .
                else do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v1-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
                  assign
                    tmp#zakaz.price-rubl = ub.gds-obj.price-sale
                    tmp#zakaz.price-base = tmp#zakaz.price-rubl /( v-base-rate * v-base-scale )
                    tmp#zakaz.price-cli  = tmp#zakaz.price-rubl
                  .
                end.
          end.
          else do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v1-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
                  assign
                    tmp#zakaz.price-base = ub.gds-obj.price-sale
                    tmp#zakaz.price-rubl = tmp#zakaz.price-base * ( v-base-rate / v-base-scale )
                    tmp#zakaz.price-cli  = tmp#zakaz.price-base
                  .
          end.
   end.
   else do:
   assign
     tmp#zakaz.price-base = 0
     tmp#zakaz.price-rubl = 0
     tmp#zakaz.price-cli  = 0
   .
   end.
find first shar_ord-line   exclusive-lock   where
          shar_ord-line.doc-code        = loc-ord-num    and
          shar_ord-line.prod-type       = tmp#zakaz.prod-type and
          shar_ord-line.prod-code       = tmp#zakaz.prod-code and
          shar_ord-line.artic           = tmp#zakaz.artic     no-error.
 if not available shar_ord-line  then
       create shar_ord-line  .
 buffer-copy tmp#zakaz to shar_ord-line
       assign shar_ord-line.doc-code    = loc-ord-num
  .
  p-tmp = recid ( tmp#zakaz   ) .
  p-ord = recid ( shar_ord-line  ) .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY scr-cli scr-wrkr scr-ship-date scr-pay-day scr-agnt scr-boss
          scr-e-method t-auto scr-obj-name scr-cli-name scr-contract
          scr-wrkr-name scr-agnt-name scr-boss-name scr-sum-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-delivery B-help B-spec r-cli B-contract scr-wrkr
         scr-ship-date r-wrkr scr-pay-day scr-agnt r-agnt scr-boss r-boss
         scr-e-method b-add B-chg B-del B-calc b-renum t-auto BROWSE-2
         scr-obj-name scr-cli-name scr-contract scr-wrkr-name scr-agnt-name
         scr-boss-name scr-sum-qnty
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH X_ord-line       WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK,              EACH X_goods WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK.
END PROCEDURE.
PROCEDURE init-gds-rec :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  find current x_goods no-lock no-error .
  gds-rec = recid(x_goods) .
  end.
END PROCEDURE.
PROCEDURE init-proc :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define buffer buf_2clients for ub.clients  .
 find first buf_2clients no-lock where
            buf_2clients.obj-code = buf_ord-doc.cli-code and
            buf_2clients.obj-type = buf_ord-doc.cli-type
            no-error .
 find first buf_clients no-lock where
            buf_clients.obj-code = buf_ord-doc.obj-code and
            buf_clients.obj-type = buf_ord-doc.obj-type
            no-error .
            if error-status :error then do:
            message vss-workfile vss-revision vss-description skip
                   "Ошибка  " skip
                    skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error
            .
            return error .
            end.
 assign
  loc-contract     = buf_ord-doc.contract-code
  v-deliv-type-code     =  buf_ord-doc.deliv-type-code
  v-point-obj-code      =  buf_ord-doc.obj-point-code
  v-point-cli-code      =  buf_ord-doc.cli-point-code
  v-point-obj-db-num    =  buf_ord-doc.obj-point-db-num
  v-point-cli-db-num    =  buf_ord-doc.cli-point-db-num
  v-transport-host-code =  buf_ord-doc.transport-host-code
  v-transport-cli-type  =  buf_ord-doc.transport-cli-type
  v-transport-cli-code  =  buf_ord-doc.transport-cli-code
  v-transport-contract  =  buf_ord-doc.transport-contract
  v-transport-condition =  buf_ord-doc.transport-condition
  v-transport-value     =  buf_ord-doc.transport-value
  v-transport-sum       =  buf_ord-doc.sum-ship
  v-transport-vat       =  buf_ord-doc.transport-vat
  scr-contract     = if loc-contract = 0 then "" else  "Вн.№ дог. " + string(buf_ord-doc.contract-code)
  scr-ship-date    = buf_ord-doc.ship-date
  scr-pay-day      = buf_ord-doc.pay-day
  pay-day          = buf_ord-doc.pay-day
  loc-date-ship    = scr-ship-date
  scr-e-method     = buf_ord-doc.e-method
  e-method         = buf_ord-doc.e-method
  loc-obj-code     = buf_ord-doc.obj-code
  loc-obj-type     = buf_ord-doc.obj-type
  loc-cli-code     = buf_ord-doc.cli-code
  loc-cli-type     = buf_ord-doc.cli-type
  loc-doc-type     = buf_ord-doc.doc-type
  scr-obj-name     = buf_clients.obj-name
  loc-ord-num      = buf_ord-doc.doc-code
  scr-wrkr         = buf_ord-doc.wrkr
  scr-boss         = buf_ord-doc.boss
  scr-agnt         = buf_ord-doc.agnt
  scr-cli          = buf_ord-doc.cli-code
  scr-cli-name     = if available buf_2clients then buf_2clients.obj-name else ""
 .
 run leave-proc-wrkr in this-procedure .
 run leave-proc-boss in this-procedure .
 run leave-proc-agnt in this-procedure .
     ASSIGN frame Dialog-Frame:TITLE = "Заказ  № " + loc-ord-num
   + " Тип: " +     buf_ord-doc.doc-type
   + " Статус: "  +  buf_ord-doc.status_
   + " - " + caps(p-mode).
assign
  scr-agnt:label in frame Dialog-Frame    = "И&сп"
  scr-agnt:tooltip in frame Dialog-Frame  = "Код исполнителя"
  scr-wrkr:label in frame Dialog-Frame    = "К&л-к"
  scr-wrkr:tooltip in frame Dialog-Frame  = "Код кладовщика"
  scr-boss:label in frame Dialog-Frame    = "&М-р"
  scr-boss:tooltip in frame Dialog-Frame  = "Код менеджера"
  .
  end.
END PROCEDURE.
PROCEDURE my-enable-lkp :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  run init-proc in this-procedure .
  X_ord-line.qnty:read-only in browse BROWSE-2  = true .
  DISPLAY scr-ship-date scr-obj-name
          scr-e-method scr-sum-qnty
          scr-cli-name
          scr-cli
          scr-pay-day
          scr-contract
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-next b-prev B-delivery b-contract B-help BROWSE-2 scr-e-method
       b-spec
       WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
      hide  b-quit in FRAME Dialog-Frame.
      b-exit:label = "&Выход" .
  run openbr in this-procedure .
  end.
END PROCEDURE.
PROCEDURE my-enable_UI :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  run init-proc in this-procedure .
  display scr-ship-date scr-obj-name
          scr-e-method
          scr-sum-qnty
          scr-wrkr-name
          scr-agnt-name
          scr-boss-name
          scr-cli-name
          t-auto
          scr-cli
          scr-pay-day
          scr-contract
          with frame dialog-frame.
  enable b-exit b-quit b-help
      B-delivery b-contract
         b-spec
         scr-ship-date b-add b-chg b-del
         b-calc browse-2 b-renum t-auto
         scr-e-method
         scr-wrkr r-wrkr
         scr-agnt r-agnt
         scr-boss r-boss
         r-cli
         scr-pay-day
         b-spec-gds
         with frame dialog-frame.
  view frame dialog-frame.
  run openbr in this-procedure .
  end.
END PROCEDURE.
PROCEDURE next-focus :
do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
define input parameter p-widget-handle as handle no-undo .
define variable l-apply-entry as logical no-undo .
assign
  l-apply-entry =   true
.
do with frame Dialog-Frame :
  if scr-ship-date :handle = p-widget-handle then do:  if  scr-wrkr  :sensitive then do: apply "entry":u to scr-wrkr       . return . end. end.
  if scr-wrkr      :handle = p-widget-handle then do:  if  scr-agnt  :sensitive then do: apply "entry":u to scr-agnt       . return . end. end.
  if scr-agnt      :handle = p-widget-handle then do:  if  scr-boss  :sensitive then do: apply "entry":u to scr-boss       . return . end. end.
  if scr-boss      :handle = p-widget-handle then do:  if  b-add     :sensitive then do: apply "entry":u to b-add          . return . end. end.
  if b-add         :handle = p-widget-handle then do:  if  B-exit    :sensitive then do: apply "entry":u to B-exit    .      return . end. end.
  end.
  end.
END PROCEDURE.
PROCEDURE openbr :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
case sort-column-name :
  when "X_ord-line.line-num" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_ord-line.line-num .
  end.
  when "X_goods.gds-code" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_goods.gds-code .
  end.
  when "X_ord-line.artic" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_ord-line.artic .
  end.
  when "X_goods.gds-name" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_goods.gds-name .
  end.
  when "X_ord-line.qnty" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_ord-line.qnty .
  end.
  when "X_goods.unit-base" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_goods.unit-base .
  end.
  when "( if X_ord-line.temp-rash <> 0 then X_ord-line.order-qnty / X_ord-line.temp-rash  else 0 )" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by ( if X_ord-line.temp-rash <> 0 then X_ord-line.order-qnty / X_ord-line.temp-rash  else 0 ) .
  end.
  when "v-rc-qnty" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by v-rc-qnty .
  end.
  when "(chr(int(X_ord-line.add-cli-qnty)) + string(X_ord-line.add-qnty))" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by (chr(int(X_ord-line.add-cli-qnty)) + string(X_ord-line.add-qnty)) .
  end.
  when "(chr(int(X_ord-line.cancel-cli-qnty)) + string(X_ord-line.cancel-qnty))" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by (chr(int(X_ord-line.cancel-cli-qnty)) + string(X_ord-line.cancel-qnty)) .
  end.
  when "X_ord-line.temp-rash" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_ord-line.temp-rash .
  end.
  when "v-rc-qnty-free" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by v-rc-qnty-free .
  end.
  when "X_ord-line.qnty-stk" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_ord-line.qnty-stk .
  end.
  when "( if X_ord-line.temp-rash <> 0 then X_ord-line.qnty-stk / X_ord-line.temp-rash  else 0 )" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by ( if X_ord-line.temp-rash <> 0 then X_ord-line.qnty-stk / X_ord-line.temp-rash  else 0 ) .
  end.
  when "X_ord-line.initial-qnty" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_ord-line.initial-qnty .
  end.
  when "X_ord-line.order-qnty" then do:
        OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  WHERE X_ord-line.doc-code = loc-ord-num , EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type by X_ord-line.order-qnty .
  end.
otherwise do:
  OPEN QUERY BROWSE-2 FOR EACH X_ord-line       WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK,              EACH X_goods WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK.
end.
end case.
  end.
END PROCEDURE.
PROCEDURE p-cont :
define variable o-host-code as integer   no-undo .
define variable c-host-code as integer   no-undo .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  loc-obj-type
  ,input  loc-obj-code
  ,output o-host-code
  )  .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  loc-cli-type
  ,input  loc-cli-code
  ,output c-host-code
  )  .
   if o-host-code <> c-host-code  then do:
    run check-contract-code in this-procedure
     (input  "choose":u,
      input  o-host-code,
      input  'орг':U,
      input  c-host-code,
      input  ?,
      input  parparentproc,
      input  doc-date ,
      input  'при':U ,
      output loc-contract) no-error.
      if error-status :error then
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "Ошибка проверки договора"
            view-as alert-box error
          .
   end.
   else do:
     loc-contract = 0 .
   end.
  scr-contract = "".
  if loc-contract <> 0 then do:
     find first buf_contract no-lock where
                buf_contract.contract-code = loc-contract and
                buf_contract.host-code = o-host-code  no-error .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "не найден договор" skip
       "№договора "  loc-contract        skip
       "фирма " o-host-code         skip
       view-as alert-box error
     .
     scr-contract = "Вн.№ дог. " + string(loc-contract).
     assign
        v-transport-cli-code     =  buf_contract.transport-cli-code
        v-transport-cli-type     =  buf_contract.transport-cli-type
        v-transport-host-code    =  buf_contract.transport-host
        v-transport-contract     =  buf_contract.transport-contract
        v-transport-condition    =  buf_contract.transport-uslov
        v-transport-value        =  buf_contract.transport-value
        .
  end.
  display scr-contract with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE p-delete :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter tmp-recid as recid no-undo .
define input-output parameter ii as integer no-undo . .
    find first tmp#zakaz where recid(tmp#zakaz) = tmp-recid no-error .
    if not avail tmp#zakaz then return error.
    find first shar_ord-line  exclusive-lock    where
        shar_ord-line.doc-code        = loc-ord-num    and
        shar_ord-line.prod-type       = tmp#zakaz.prod-type and
        shar_ord-line.prod-code       = tmp#zakaz.prod-code and
        shar_ord-line.artic           = tmp#zakaz.artic     no-error.
    if not available shar_ord-line  then  return error .
    delete shar_ord-line .
    delete tmp#zakaz .
    ii = ii - 1 .
  end.
END PROCEDURE.
PROCEDURE proc-b-add :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable ii as int init 0 no-undo.
define variable r-tmp as recid no-undo .
define variable r-ord as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
define variable l-g#type as character no-undo .
define variable l-g#status as character no-undo .
define variable t-ret as logical no-undo .
define variable varschartic       like ub.price-list.artic initial " " no-undo.
define variable v-ref-list  as char                     no-undo.
define buffer buf_ord-line for ub.ord-line  .
    run str/chsgdsls.w
       (
        input parparentproc,
        input "order" + 'ОР':U ,
        input "Строка документа № " + loc-ord-num ,
        input ? ,
        input ? ,
        input v-cntxt-host-code-obj,
        input-output varschartic,
        output v-ref-list,
        output table tt-gds-list ,
        input false) no-error.
    if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
           "Ошибка procedure chsgdsls.w " skip
            skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error
    .
    return error  .
    end.
   t-ret =  session:set-wait-state("general") .
   line-mode = 'ДОБАВЛЕНИЕ':U .
   for each tt-gds-list no-lock :
     ii = ii + 1 .
     if ii > 1 then assign line-mode = "ЦИКЛ":u.
    find first  buf_ord-line  exclusive-lock      where
                buf_ord-line.gds-code = tt-gds-list.gds-code  and
                buf_ord-line.doc-code = loc-ord-num
                no-error .
          if available buf_ord-line then do:
              run cus/ord-frmp.w
                 (input parParentProc ,
                  input ?  ,
                  input recid ( buf_ord-line)  ,
                  input 'ИЗМЕНЕНИЕ':U,
                  output r-stop ,
                  output r-exit )
                  no-error .
          end.
          else do:
              run create-tmp in this-procedure  (input "tt-gds-list":u, "" , output r-tmp , output r-ord).
              if not t-auto then do:
                    run cus/ord-frmo.w
                      ( input parParentProc ,
                        input r-tmp  ,
                        input r-ord  ,
                        input line-mode,
                        output r-stop ,
                        output r-exit ) .
                      if r-stop then do:
                          run p-delete in this-procedure
                            ( r-tmp , input-output ii).
                          leave.
                          end.
                      if r-exit then do:
                          run p-delete in this-procedure
                              ( r-tmp , input-output ii ) .
                          end.
              end.
          end.
   end.
  run openbr in this-procedure .
  t-ret =  session:set-wait-state("") .
  message "Добавлено " + string(ii) + " товаров".
  end.
END PROCEDURE.
PROCEDURE proc-renum :
 do
 on error undo, return error return-value
 :
define variable g-ok as logical no-undo .
define variable g as integer no-undo .
define buffer buf_ord-line for ub.ord-line.
 message " Перенумеровать список товаров ? "
    view-as alert-box question
    buttons yes-no
    UPDATE g-ok
    .
    if g-ok = false then return.
    g = 0 .
    for each buf_ord-line  exclusive-lock  where buf_ord-line.doc-code = loc-ord-num  by buf_ord-line.line-num :
        g = g + 1.
        buf_ord-line.line-num = g.
    end.
    run openbr in this-procedure .
 end.
END PROCEDURE.
PROCEDURE recalc-head :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define buffer buf_ord-line for ub.ord-line.
define variable s-1 as decimal init 0 no-undo .
define variable s-2 as decimal init 0 no-undo .
define variable s-0 as decimal init 0 no-undo .
     assign frame Dialog-Frame
     scr-ship-date
     scr-e-method
.
for each  buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num  :
    s-1  = s-1  + buf_ord-line.sum-rubl .
    s-2  = s-2  + buf_ord-line.sum-base .
    s-0  = s-0  + buf_ord-line.qnty     .
end.
assign
  scr-sum-qnty = s-0
  scr-sum-rubl = s-1
  scr-sum-base = s-2
.
display
 scr-sum-qnty
 with frame Dialog-Frame .
  end.
END PROCEDURE.
PROCEDURE step-next :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  if valid-handle (br-handle) then do:
  g#log = br-handle:select-next-row () no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
     end.
  if not g#log then message "Это последний документ списка.".
end.
    p-ord-doc-recid = recid ( buf-or_ord-doc ).
    next-prev = yes.
  end.
END PROCEDURE.
PROCEDURE step-prev :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  if valid-handle (br-handle) then do:
  g#log = br-handle:select-prev-row() no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
  end.
  if not g#log then do: message "Это первый документ списка.".   end.
end.
p-ord-doc-recid = recid (buf-or_ord-doc).
next-prev = yes .
  end.
END PROCEDURE.
PROCEDURE x-delete :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-recid as recid no-undo .
define input-output parameter ii as integer no-undo . .
    find first shar_ord-line  exclusive-lock  where recid(shar_ord-line) = p-recid  .
    if not available shar_ord-line  then  return error .
    find first tmp#zakaz   where
                tmp#zakaz.prod-type = shar_ord-line.prod-type         and
                tmp#zakaz.prod-code = shar_ord-line.prod-code         and
                tmp#zakaz.artic     = shar_ord-line.artic             no-error.
    if  avail tmp#zakaz then delete tmp#zakaz .
    delete shar_ord-line .
    ii = ii - 1 .
  end.
END PROCEDURE.
FUNCTION f-zapr-qnty RETURNS decimal
  ( buffer buf_ord-line for ub.ord-line , par-type as char ) :
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv for ub.ord-line-rcv .
define buffer buf_doc-line          for ub.doc-line .
define buffer buf_trn-doc           for ub.trn-doc  .
define variable  res as decimal no-undo init 0 .
for each buf_ord-line-rcv no-lock
    where buf_ord-line-rcv.doc-code  = buf_ord-line.doc-code  and
          buf_ord-line-rcv.artic     = buf_ord-line.artic     and
          buf_ord-line-rcv.prod-type = buf_ord-line.prod-type and
          buf_ord-line-rcv.prod-code = buf_ord-line.prod-code
          on error undo, return error :
          find first buf_ord-doc-rcv no-lock where
                    buf_ord-doc-rcv.rcv-code  = buf_ord-line-rcv.rcv-code  and
                    buf_ord-doc-rcv.doc-code  = buf_ord-line-rcv.doc-code  no-error .
                    if error-status :error then next .
   for each ub.ord-chain no-lock where
            ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
            ub.ord-chain.doc-type = 'rcv'                  and
            ub.ord-chain.rel-doc-type = 'trn'
            :
          find first buf_trn-doc no-lock  where
                     buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code and
                     buf_trn-doc.doc-type = par-type
                              no-error .
          if not available buf_trn-doc then next .
          if buf_trn-doc.doc-type = 'при':U then
             if buf_trn-doc.status_ <>  'запрос':U then next.
          find first buf_doc-line no-lock where
                     buf_doc-line.doc-code  = buf_trn-doc.doc-code  and
                     buf_doc-line.artic     = buf_ord-line.artic     and
                     buf_doc-line.prod-type = buf_ord-line.prod-type and
                     buf_doc-line.prod-code = buf_ord-line.prod-code  no-error .
                     if error-status :error then next .
          res  = res  + buf_doc-line.fact-qnty .
         end.
end.
  RETURN res .
END FUNCTION.
PROCEDURE create-tmp-contr-sp :
define input  parameter p-recid as recid no-undo .
define output parameter p-tmp as recid no-undo .
define output parameter p-ord as recid no-undo .
define buffer buf_contract-specif for ub.contract-specif  .
define variable prod-type#   like ub.ord-line.prod-type no-undo .
define variable prod-code#   like ub.ord-line.prod-code no-undo .
define variable artic#       like ub.ord-line.artic     no-undo .
define variable v-base-rate   as decimal no-undo .
define variable v-base-scale  as decimal no-undo .
define buffer ll-buf_ord-line for ub.ord-line .
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 find first buf_contract-specif no-lock where
            recid(buf_contract-specif)  = p-recid no-error .
            if error-status :error then return error return-value .
find first ub.goods where
      ub.goods.gds-code  = buf_contract-specif.gds-code
      no-lock no-error.
      if error-status :error  then return error return-value .
define buffer bufff-units for ub.units.
define variable t-type as character no-undo .
find first tmp#zakaz   where
           tmp#zakaz.prod-type = ub.goods.prod-type and
           tmp#zakaz.prod-code = ub.goods.prod-code and
           tmp#zakaz.artic     = ub.goods.artic     no-error.
 if not available tmp#zakaz  then  create tmp#zakaz .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-cntxt-host-code-obj
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
  assign
    tmp#zakaz.doc-code      = loc-ord-num
    tmp#zakaz.gds-code      = ub.goods.gds-code
    tmp#zakaz.prod-type     = ub.goods.prod-type
    tmp#zakaz.prod-code     = ub.goods.prod-code
    tmp#zakaz.artic         = ub.goods.artic
    tmp#zakaz.gds-name      = ub.goods.gds-name
    tmp#zakaz.deadline      = ub.goods.deadline
    tmp#zakaz.unit-cli      = buf_contract-specif.unit-base
    tmp#zakaz.unit-base     = ub.goods.unit-base
    tmp#zakaz.negative-rest = ub.goods.negative-rest
    tmp#zakaz.cli-base-rate = ( if buf_contract-specif.cli-base-rate = 0 or buf_contract-specif.cli-base-rate = ? then 1 else buf_contract-specif.cli-base-rate)
    tmp#zakaz.ms-cart       = ub.goods.qnty-cart
    tmp#zakaz.vat-pc        = buf_contract-specif.vat-pc
    tmp#zakaz.price-cli     = buf_contract-specif.price-cli
    tmp#zakaz.price-rubl    = buf_contract-specif.price-cli / tmp#zakaz.cli-base-rate
    tmp#zakaz.price-base    = tmp#zakaz.price-rubl * v-base-rate / v-base-scale
    tmp#zakaz.cli-qnty      = ( if buf_contract-specif.qnty = 0 or buf_contract-specif.qnty = ? then 1 else buf_contract-specif.qnty)
    tmp#zakaz.qnty          = tmp#zakaz.cli-qnty * tmp#zakaz.cli-base-rate
    .
    define variable max-num as integer no-undo .
    max-num = 0.
    for each  ll-buf_ord-line no-lock  where ll-buf_ord-line.doc-code = loc-ord-num :
        if max-num < ll-buf_ord-line.line-num then
           max-num = ll-buf_ord-line.line-num .
    end.
    tmp#zakaz.line-num = max-num + 1.
  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-type       = bufff-units.type .
  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-cli-type       = bufff-units.type .
find first shar_ord-line   exclusive-lock   where
          shar_ord-line.doc-code        = loc-ord-num    and
          shar_ord-line.prod-type       = tmp#zakaz.prod-type and
          shar_ord-line.prod-code       = tmp#zakaz.prod-code and
          shar_ord-line.artic           = tmp#zakaz.artic     no-error.
 if not available shar_ord-line  then
       create shar_ord-line  .
 buffer-copy tmp#zakaz to shar_ord-line
       assign shar_ord-line.doc-code    = loc-ord-num
  .
  p-tmp = recid ( tmp#zakaz   ) .
  p-ord = recid ( shar_ord-line  ) .
  end.
END PROCEDURE.
