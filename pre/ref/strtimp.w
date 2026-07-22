define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER iOnlyfile     as logical no-undo.
DEFINE INPUT PARAMETER vattaxcd      as integer no-undo.
DEFINE INPUT PARAMETER slttaxcd      as integer no-undo.
define input parameter custvalue     as character no-undo .
define input parameter tnvedimp      as logical no-undo .
DEFINE OUTPUT PARAMETER v_os-file    AS CHAR    NO-UNDO INIT "".
DEFINE OUTPUT PARAMETER choice       AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-artic      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-prod       AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-name       AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-engl-name  AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-unit-base  AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-VAT-code   AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-SLT-code   AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-struct     AS integer NO-UNDO.
define output parameter p-tnved      as integer no-undo .
define output parameter p-attrib     as integer no-undo .
define output parameter p-destin     as integer no-undo .
define output parameter p-sert       as integer no-undo .
define output parameter p-user-rule  as integer no-undo .
define output parameter p-alpha1     as integer no-undo .
define output parameter p-grp-code   as integer no-undo .
define output parameter p-service    as integer no-undo .
define output parameter p-gds-code   as integer no-undo .
define output parameter p-mark       as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Параметры файла импорта товаров" .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable  conf-par as character no-undo.
define variable  par-type as character no-undo.
define variable v-init-dir as character no-undo .
DEFINE stream gds-file.
DEFINE BUTTON B-check
     LABEL "&Проверка"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл импорта"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE ii AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "Строчка N"
      VIEW-AS TEXT
     SIZE 16.25 BY .67
     FGCOLOR 10  NO-UNDO.
DEFINE VARIABLE text-string AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 61 BY .67
     FGCOLOR 10  NO-UNDO.
DEFINE VARIABLE RS-codir AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "1251", 1,
"KOI8-R", 2
     SIZE 15.25 BY 2.63 NO-UNDO.
DEFINE RECTANGLE RECT-atribut
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.75 BY 18.83.
DEFINE VARIABLE T-alpha1 AS LOGICAL INITIAL yes
     LABEL "Страна"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-artic AS LOGICAL INITIAL yes
     LABEL "Артикул"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-grp-code AS LOGICAL INITIAL yes
     LABEL "Код группы"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-service AS LOGICAL INITIAL yes
     LABEL "Услуга"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-gds-code AS LOGICAL INITIAL yes
     LABEL "Код товара"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-attrib AS LOGICAL INITIAL no
     LABEL "Характеристики товара"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-destin AS LOGICAL INITIAL no
     LABEL "Назначение товара"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-engl-name AS LOGICAL INITIAL yes
     LABEL "Англ. название"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-name AS LOGICAL INITIAL yes
     LABEL "Название"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-prod AS LOGICAL INITIAL yes
     LABEL "Произ-ль (например орг176)"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-sert AS LOGICAL INITIAL no
     LABEL "Сертификат товара"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-SLT-code AS LOGICAL INITIAL no
     LABEL "Код НП"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-struct AS LOGICAL INITIAL no
     LABEL "Состав сырья"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-tnved AS LOGICAL INITIAL no
     LABEL "Код ТНВЭД"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-unit-base AS LOGICAL INITIAL yes
     LABEL "Основная единица измерения"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-user-rule AS LOGICAL INITIAL no
     LABEL "Правила эксплуатации"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-VAT-code AS LOGICAL INITIAL yes
     LABEL "Код НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-Mark AS LOGICAL INITIAL yes
     LABEL "Тип маркировки"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-check AT ROW 1 COL 21
     B-Help AT ROW 1 COL 54.88
     B-file AT ROW 2.88 COL 43.13
     file-name AT ROW 2.92 COL 3.38
     T-artic AT ROW 5.08 COL 24.25
     RS-codir AT ROW 5.38 COL 3.38 NO-LABEL
     T-name AT ROW 6.08 COL 24.5
     T-engl-name AT ROW 7.08 COL 24.5
     T-unit-base AT ROW 8.08 COL 24.5
     T-VAT-code AT ROW 9.08 COL 24.5
     T-SLT-code AT ROW 10.08 COL 24.5
     T-struct AT ROW 11.08 COL 24.5
     T-tnved AT ROW 12.08 COL 24.5
     T-destin AT ROW 13.08 COL 24.5
     T-attrib AT ROW 14.08 COL 24.5
     T-user-rule AT ROW 15.08 COL 24.5
     T-sert AT ROW 16.08 COL 24.5
     T-prod AT ROW 17.08 COL 24.5
     T-alpha1 AT ROW 18.08 COL 24.5
     T-grp-code AT ROW 19.08 COL 24.5
     T-service AT ROW 20.08 COL 24.5
     T-gds-code AT ROW 21.08 COL 24.5
     T-Mark AT ROW 22.08 COL 24.5
     ii AT ROW 23.1 COL 2
     text-string AT ROW 24.1 COL 2.13 NO-LABEL
     "Кодировка" VIEW-AS TEXT
          SIZE 15.75 BY .92 AT ROW 4.21 COL 3.38
     "Импортируемые поля" VIEW-AS TEXT
          SIZE 19.25 BY .88 AT ROW 4 COL 26.25
          FGCOLOR 3
     RECT-atribut AT ROW 4.42 COL 21.13
     SPACE(2.24) SKIP(3.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры файла импорта"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ii:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-check IN FRAME Dialog-Frame
DO:
  define variable NEN as integer No-UNDO.
  define variable p-text as char no-undo.
  define variable p-int as integer no-undo.
  define variable vars as integer no-undo EXTENT 18.
  define variable lok as logical no-undo.
  define buffer buf_country for ub.country.
  define buffer buf_gds-grp for ub.gds-grp .
  assign
  file-name
  v_os-file = file-name
  RS-codir
  choice = RS-codir
  T-artic
  t-prod
  T-engl-name
  T-name
  T-SLT-code
  T-unit-base
  T-VAT-code
  T-struct
  T-tnved
  T-attrib
  T-destin
  T-sert
  T-user-rule
  T-alpha1
  T-grp-code
  T-service
  T-gds-code
  T-Mark
  NEN = NEN + integer(T-artic)
  vars[1] = NEN
  p-artic = vars[1]
  NEN = NEN + integer(T-name)
  vars[2] = if T-name then NEN else 0
  p-name = vars[2]
  NEN = NEN + integer(T-engl-name)
  vars[3] = if T-engl-name then NEN else 0
  p-engl-name = vars[3]
  NEN = NEN + integer(T-unit-base)
  vars[5] = if T-unit-base then NEN else 0
  p-unit-base = vars[5]
  NEN = NEN + integer(T-VAT-code)
  vars[6] = if T-VAT-code then NEN else 0
  p-VAT-code = vars[6]
  NEN = NEN + integer(T-SLT-code)
  vars[4] = if T-SLT-code then NEN else 0
  p-SLT-code = vars[4]
  NEN = NEN + integer(T-Struct)
    vars[7] = if T-struct then NEN else 0
    p-struct = vars[7]
  NEN = NEN + integer(T-Tnved)
    vars[8] = if T-tnved then NEN else 0
    p-tnved = vars[8]
  NEN = NEN + integer(T-destin)
    vars[10] = if T-destin then NEN else 0
    p-destin = vars[10]
  NEN = NEN + integer(T-attrib)
    vars[9] = if T-attrib then NEN else 0
    p-attrib = vars[9]
  NEN = NEN + integer(T-user-rule)
    vars[12] = if T-user-rule then NEN else 0
    p-user-rule = vars[12]
  NEN = NEN + integer(T-sert)
    vars[11] = if T-sert then NEN else 0
    p-sert = vars[11]
  NEN = NEN + integer(T-prod)
  vars[13] = if T-prod then NEN else 0
  p-prod = vars[13]
  NEN = NEN + integer(T-alpha1)
    vars[14] = if T-alpha1 then NEN else 0
    p-alpha1 = vars[14]
   NEN = NEN + integer(T-grp-code)
    vars[15] = if T-grp-code then NEN else 0
    p-grp-code = vars[15]
   NEN = NEN + integer(T-service)
    vars[16] = if T-service then NEN else 0
    p-service = vars[16]
   NEN = NEN + integer(T-gds-code)
    vars[17] = if T-gds-code then NEN else 0
    p-gds-code = vars[17]
 NEN = NEN + integer(T-mark)
    vars[18] = if T-mark then NEN else 0
    p-mark = vars[18]
  .
  IF v_os-file = "" or v_os-file = ? then do:
    message "Не определен файл импорта!" view-as alert-box ERROR.
    return no-apply.
  END.
  if substring(v_os-file, length(v_os-file) - 2) = "xls"
  or substring(v_os-file, length(v_os-file) - 3) = "xlsx"
  then do :
      message "Для файлов Excel проверка не возможна" view-as alert-box.
      return no-apply .
  end.
  IF (T-SLT-code OR T-VAt-code) AND NOT T-unit-base then do:
    message "Невозможно импортировать код НДС и/или код НП" SKIP
            "без импорта основной единицы измерения" view-as alert-box ERROR.
    return no-apply.
  end.
  CASE choice:
        WHEN 1 then do:
            input stream gds-file from value (v_os-file) convert source "1251".
        END.
        WHEN 2 then do:
            input stream gds-file from value (v_os-file) convert source "KOI8-R".
        END.
  END CASE.
  ii = 0.
  VIEW
  ii
  IN FRAME Dialog-Frame.
  _stroka:
    REPEAT:
    IMPORT stream gds-file UNFORMATTED text-string NO-ERROR.
    ii = ii + 1.
    DISPLAY
    text-string
    ii
    WITH frame Dialog-Frame.
    if NUm-ENTRIES(text-string, ";") <> NEN then do:
        message "В строчке N " ii "неверное кол-во полей - " NUm-ENTRIES(text-string, ";") skip
            "должно быть" NEN
        view-as alert-box ERROR
        buttons OK-Cancel update lok
        .
        if NOT lok then return no-apply.
        else NEXT _stroka.
    end.
    if vars[5] > 0 then do:
        FIND FIRST ub.units NO-LOCK where
                   ub.units.unit-name = ENTRY(vars[5], text-string, ";")
                   No-ERROR.
        IF NOT avail ub.units then do:
            message "Нет в БД единицы измерения "
                    ENTRY(vars[5], text-string, ";") skip
                    " - поле N " vars[5]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.
        END.
    end.
    if vars[4] > 0 then do:
        assign
        p-int = integer(ENTRY(vars[4], text-string, ";"))
        no-error.
        if error-status:error then do:
            message "Неверное значение кода ставки НП "
                    ENTRY(vars[4], text-string, ";") skip
                    " - поле N " vars[4]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.
        end.
        else do:
            FIND FIRST ub.tax-rate NO-LOCK where
                       ub.tax-rate.rate-code = p-int
                       No-ERROR.
            IF NOT avail ub.tax-rate then do:
                message "Нет в БД ставки налога с кодом "
                        ENTRY(vars[4], text-string, ";") skip
                        " - поле N " vars[4]
                        "   строчка N " ii
                view-as alert-box ERROR
                buttons OK-Cancel update lok
                .
                if NOT lok then return no-apply.
            END.
            ELSE DO:
                if tax-rate.tax-code <> slttaxcd then do:
                    message "Для ставки налога с кодом "
                            ENTRY(vars[4], text-string, ";")
                            "код налога отличается от кода НП" skip
                            " - поле N " vars[4]
                            "   строчка N " ii
                    view-as alert-box ERROR
                    buttons OK-Cancel update lok
                    .
                    if NOT lok then return no-apply.
                end.
            END.
        end.
    end.
    if vars[6] > 0 then do:
        assign
        p-int = integer(ENTRY(vars[6], text-string, ";"))
        no-error.
        if error-status:error then do:
            message "Неверное значение кода ставки НДС "
                    ENTRY(vars[6], text-string, ";") skip
                    " - поле N " vars[6]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.
        end.
        else do:
            FIND FIRST tax-rate NO-LOCK where
                       tax-rate.rate-code = p-int
                       No-ERROR.
            IF NOT avail tax-rate then do:
                message "Нет в БД ставки налога с кодом "
                        ENTRY(vars[6], text-string, ";") skip
                        " - поле N " vars[6]
                        "   строчка N " ii
                view-as alert-box ERROR
                buttons OK-Cancel update lok
                .
                if NOT lok then return no-apply.
            END.
            ELSE DO:
                if tax-rate.tax-code <> vattaxcd then do:
                    message "Для ставки налога с кодом "
                            ENTRY(vars[6], text-string, ";")
                            "код налога отличается от кода НДС" skip
                            " - поле N " vars[6]
                            "   строчка N " ii
                    view-as alert-box ERROR
                    buttons OK-Cancel update lok
                    .
                    if NOT lok then return no-apply.
                end.
            END.
        end.
    end.
    if vars[14] > 0 then do:
        FIND FIRST buf_country NO-LOCK where
                   buf_country.alpha1 = ENTRY(vars[14], text-string, ";")
                   No-ERROR.
        IF NOT avail buf_country then do:
            message "Нет в БД страны "
                    ENTRY(vars[14], text-string, ";") skip
                    " - поле N " vars[14]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.
        END.
    end.
    if vars[15] > 0 then do:
        FIND FIRST buf_gds-grp NO-LOCK where
                   buf_gds-grp.node-code = integer(ENTRY(vars[15], text-string, ";"))
                   No-ERROR.
        IF NOT avail buf_gds-grp then do:
            message "Нет в БД группы товаров с вн. номером "
                    ENTRY(vars[15], text-string, ";") skip
                    " - поле N " vars[15]
                    "   строчка N " ii
            view-as alert-box ERROR
            buttons OK-Cancel update lok
            .
            if NOT lok then return no-apply.
        END.
    end.
  END.
  HIDE
  ii
  text-string
  IN FRAME Dialog-Frame.
  input stream gds-file close.
  message "Проверка завершена" view-as alert-box.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  define variable NEN as integer No-UNDO.
  define variable vars as integer no-undo EXTENT 18.
  assign
  file-name
  v_os-file = file-name
  RS-codir
  choice = RS-codir
  T-artic
  T-prod
  T-engl-name
  T-name
  T-SLT-code
  T-unit-base
  T-VAT-code
  T-struct
  T-tnved
  T-attrib
  T-destin
  T-sert
  T-user-rule
  T-alpha1
  T-grp-code
  T-service
  T-gds-code
  T-mark
  NEN = NEN + integer(T-artic)
  vars[1] = NEN
  p-artic = vars[1]
  NEN = NEN + integer(T-name)
  vars[2] = if T-name then NEN else 0
  p-name = vars[2]
  NEN = NEN + integer(T-engl-name)
  vars[3] = if T-engl-name then NEN else 0
  p-engl-name = vars[3]
  NEN = NEN + integer(T-unit-base)
  vars[5] = if T-unit-base then NEN else 0
  p-unit-base = vars[5]
  NEN = NEN + integer(T-VAT-code)
  vars[6] = if T-VAT-code then NEN else 0
  p-VAT-code = vars[6]
  NEN = NEN + integer(T-SLT-code)
  vars[4] = if T-SLT-code then NEN else 0
  p-SLT-code = vars[4]
  NEN = NEN + integer(T-Struct)
  vars[7] = if T-Struct then NEN else 0
  p-Struct = vars[7]
  NEN = NEN + integer(T-tnved)
  vars[8] = if T-tnved then NEN else 0
  p-tnved = vars[8]
  NEN = NEN + integer(T-destin)
  vars[10] = if T-destin then NEN else 0
  p-destin = vars[10]
  NEN = NEN + integer(T-attrib)
  vars[9] = if T-attrib then NEN else 0
  p-attrib = vars[9]
  NEN = NEN + integer(T-user-rule)
  vars[12] = if T-user-rule then NEN else 0
  p-user-rule = vars[12]
  NEN = NEN + integer(T-sert)
  vars[11] = if T-sert then NEN else 0
  p-sert = vars[11]
  NEN = NEN + integer(T-prod)
  vars[13] = if T-prod then NEN else 0
  p-prod = vars[13]
  NEN = NEN + integer(T-alpha1)
  vars[14] = if T-alpha1 then NEN else 0
  p-alpha1 = vars[14]
  NEN = NEN + integer(T-grp-code)
  vars[15] = if T-grp-code then NEN else 0
  p-grp-code = vars[15]
  NEN = NEN + integer(T-service)
  vars[16] = if T-service then NEN else 0
  p-service = vars[16]
  NEN = NEN + integer(T-gds-code)
  vars[17] = if T-gds-code then NEN else 0
  p-gds-code = vars[17]
 NEN = NEN + integer(T-mark)
    vars[18] = if T-mark then NEN else 0
    p-mark = vars[18]
  .
  if vars[17] eq 0
     and  vars[13] eq 0
  then do:
      message
      "В загрузке обязательно должен быть код товара или производитель."
      view-as alert-box WARNING.
      return no-apply.
  end.
  if p-tnved > 0 then do:
    if custvalue = "no"  then do:
      message
      "В Вашей системе не включен настроечный параметр ТАМОЖНЯ," skip
      "поэтому проверить корректность импортируемых кодов ТНВЭД будет невозможно"
      view-as alert-box WARNING.
    end.
  end.
  IF v_os-file = "" or v_os-file = ? then do:
    message "Не определен файл импорта!" view-as alert-box ERROR.
    return no-apply.
  END.
  IF (T-SLT-code OR T-VAt-code) AND NOT T-unit-base then do:
    message "Невозможно импортировать код НДС и/или код НП" SKIP
            "без импорта основной единицы измерения" view-as alert-box ERROR.
    return no-apply.
  end.
  CASE choice:
        WHEN 1 then do:
            input stream gds-file from value (v_os-file) convert source "1251".
        END.
        WHEN 2 then do:
            input stream gds-file from value (v_os-file) convert source "KOI8-R".
        END.
  END CASE.
END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
        FILTERS
          " Текстовые файлы (*.gim) " "*.gim",
          " Текстовые файлы (*.txt) " "*.txt",
          " Текстовые файлы (*.csv) " "*.csv",
          " MS Excel (*.xls,*.xlsx) " "*.xls,*.xlsx",
          " Все файлы (*.*) "                      "*.*"
        INITIAL-DIR v-init-dir
        must-exist
        update ll_commit
        default-extension "gim"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name WITH FRAME Dialog-Frame.
  run gbl/filename.p (
                          input  file-name
                          ,output v-full-path
                          ,output v-path
                          ,output v-file-name
                          ,output v-file-name-no-ext
                          ,output v-file-name-ext
                          ) no-error .
  if not error-status:error then v-init-dir = v-path.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
    assign v_os-file = "".
END.
ON LEAVE OF file-name IN FRAME Dialog-Frame
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO file-name IN FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 run fill-by-usr-flt in this-procedure  no-error .
 RUN enable_UI.
 if not tnvedimp and custvalue <> "yes" then do:
    assign
    t-tnved = no.
    disable
    T-tnved
    with frame Dialog-Frame .
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
  assign
  v-uf-list_ =
               string(T-artic)       + chr(4) +
               string(T-name)        + chr(4) +
               string(t-engl-name )  + chr(4) +
               string(t-unit-base)   + chr(4) +
               string(t-VAT-code)    + chr(4) +
               string(t-SLT-code)    + chr(4) +
               string(t-struct)      + chr(4) +
               string(t-tnved)       + chr(4) +
               string(t-attrib)      + chr(4) +
               string(t-destin)      + chr(4) +
               string(t-sert)        + chr(4) +
               string(t-user-rule)   + chr(4) +
               string(t-prod)        + chr(4) +
               string(t-alpha1)      + chr(4) +
               string(t-grp-code)    + chr(4) +
               string(t-service)     + chr(4) +
               string(t-gds-code)    + chr(4) +
               string(t-mark)
  v-uf-Naim  = v-init-dir
 .
  run uf-set in this-procedure(
    input  'imp-goods':U
    ,input v-cntxt-userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY file-name T-artic RS-codir T-name T-engl-name T-unit-base T-VAT-code
          T-SLT-code T-struct T-tnved T-destin T-attrib T-user-rule T-sert
          T-prod T-alpha1 T-grp-code T-service T-gds-code t-mark text-string
      WITH FRAME Dialog-Frame.
  if iOnlyfile
  then
     ENABLE RECT-atribut B-exit b-quit B-check B-Help B-file file-name RS-codir
      WITH FRAME Dialog-Frame.
  else
     ENABLE RECT-atribut B-exit b-quit B-check B-Help B-file file-name RS-codir
         T-engl-name T-unit-base T-VAT-code T-SLT-code T-struct T-tnved
         T-destin T-attrib T-user-rule T-sert T-prod T-grp-code T-service T-gds-code t-mark text-string
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-by-usr-flt :
run uf-get in this-procedure(
     input  'imp-goods':U
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
  if num-entries(v-uf-List_, chr(4)) >= 12 then
  assign
  T-artic       =  logical(entry(1     ,      v-uf-list_, chr(4)))
  T-name        =  logical(entry(2      ,      v-uf-list_, chr(4)))
  t-engl-name   =  logical(entry(3 ,      v-uf-list_, chr(4)))
  t-unit-base   =  logical(entry(4  ,      v-uf-list_, chr(4)))
  t-VAT-code    =  logical(entry(5 ,      v-uf-list_, chr(4)))
  t-SLT-code    =  logical(entry(6  ,      v-uf-list_, chr(4)))
  t-struct      =  logical(entry(7    ,      v-uf-list_, chr(4)))
  t-tnved       =  logical(entry(8     ,      v-uf-list_, chr(4)))
  t-attrib      =  logical(entry(9    ,      v-uf-list_, chr(4)))
  t-destin      =  logical(entry(10    ,      v-uf-list_, chr(4)))
  t-sert        =  logical(entry(11      ,      v-uf-list_, chr(4)))
  t-user-rule   =  logical(entry(12 ,      v-uf-list_, chr(4)))
  no-error.
  if num-entries(v-uf-List_, chr(4)) >= 13 then
  assign
  T-prod       =  logical(entry(13     ,      v-uf-list_, chr(4)))
  no-error
  .
  if num-entries(v-uf-List_, chr(4)) >= 14 then
  assign
  T-alpha1       =  logical(entry(14     ,      v-uf-list_, chr(4)))
  no-error
  .
  if num-entries(v-uf-List_, chr(4)) >= 15 then
  assign
  T-grp-code     =  logical(entry(15     ,      v-uf-list_, chr(4)))
  no-error
  .
  if num-entries(v-uf-List_, chr(4)) >= 16 then
  assign
  T-service     =  logical(entry(16     ,      v-uf-list_, chr(4)))
  no-error
  .
  if num-entries(v-uf-List_, chr(4)) >= 17 then
  assign
  T-gds-code     =  logical(entry(17     ,      v-uf-list_, chr(4)))
  no-error
  .
  if num-entries(v-uf-List_, chr(4)) >= 18 then
  assign
  T-mark     =  logical(entry(18     ,      v-uf-list_, chr(4)))
  no-error
  .
  assign
  file-info:file-name = v-uf-naim
  .
  assign
  v-init-dir   = ( if file-info:file-type <> ?
                   and index( file-info:file-type, "D":U ) <> 0
                   then v-uf-naim
                   else ".")
  .
END PROCEDURE.
