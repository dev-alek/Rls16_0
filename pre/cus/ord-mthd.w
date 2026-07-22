define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Методы расчета темпа, размазывание по объектам" .
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable gdsgrp_recids      as character no-undo.
define  shared variable fin-schet-recid    as character no-undo.
define  shared variable v-d-report-handle  as handle    no-undo .
define  shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table gds-list no-undo like ub.goods
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
define   shared  temp-table gds-list-hist no-undo
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
def
 shared
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
define  shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define   shared variable str1   as character  no-undo.
define   shared variable str2   as character  no-undo.
define   shared variable str3   as character  no-undo.
define   shared variable str4   as character  no-undo.
define   shared variable ReportNAme   as character  no-undo.
define   shared variable ReportProc   as character  no-undo.
define   shared variable ReportHeader as character  no-undo.
define   shared variable ReportPageWidth  as integer no-undo.
define   shared variable ReportPageHeight as integer no-undo.
define   shared variable ReportFontNum    as integer no-undo.
define   shared variable my-request as logical  init false no-undo.
define   shared variable v-delim as character no-undo .
define   shared variable v-sdate as character no-undo initial "/":U.
define   shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define   shared variable my-handle  as handle no-undo .
define   shared variable parent-handle  as handle no-undo .
define   shared variable v-show-all-goods as logical  no-undo .
define   shared variable params-only      as logical   no-undo .
define   shared variable params-only-mode as character no-undo .
define   shared variable place-call       as character no-undo .
define   shared variable x-Goods-Editor   as character  no-undo .
define   shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define   shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define   shared variable x-Shift-End      as integer format ">9":u         no-undo .
define   shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define   shared variable x-SelectGood     as integer                      no-undo .
define   shared variable x-SelectObject   as character                          no-undo .
define   shared variable x-SET_PAY_TYPE   as integer  no-undo .
define   shared variable x-SET_val_TYPE   as integer  no-undo .
define   shared variable x-TOG-Shift      as logical  no-undo .
define   shared variable x-Radio-Task     as integer  no-undo .
define   shared variable x-TOG-Excel      as logical  no-undo .
define   shared variable x-TOG-list-hist  as logical  no-undo .
define   shared variable x-text-1 as character  no-undo .
define   shared variable x-text-2 as character  no-undo .
define   shared variable x-text-3 as character  no-undo .
define   shared variable x-text-4 as character  no-undo .
define   shared variable init-date-start  like x-date-start  no-undo .
define   shared variable init-date-end    like x-date-end    no-undo .
define   shared variable init-date-alone  like x-date-alone  no-undo .
define   shared variable init-shift-alone like x-shift-alone no-undo .
define   shared variable init-shift-start like x-shift-start no-undo .
define   shared variable init-shift-end   like x-shift-end   no-undo .
define   shared variable init-set_pay_type like x-set_pay_type   no-undo .
define   shared variable init-set_val_type like x-set_val_type   no-undo .
define   shared variable ref_date-start    as character   no-undo .
define   shared variable ref_date-end      as character   no-undo .
define   shared variable ref_date-alone    as character   no-undo .
define   shared work-table TDEDT  no-undo
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
define   shared variable str-obj-type as character  no-undo.
define   shared variable str-obj-code as character  no-undo.
define   shared variable str-obj-name as character  no-undo.
define   shared variable str-obj      as character  no-undo.
define   shared variable link#        as logical  no-undo init false.
define   shared variable  Verify-Arc-ot      as logical  no-undo init false.
define   shared variable  Verify-Arc-stk     as logical  no-undo init false.
define   shared variable  Verify-Arc-supp    as logical  no-undo init false.
define   shared variable  Verify-Arc-hold    as logical  no-undo init false.
define   shared variable  Verify-Arc-aht     as logical  no-undo init false.
define   shared variable  Verify-send-check  as logical  no-undo init false.
define   shared variable  Verify-Arc-fin     as logical  no-undo init false.
define   shared variable  Verify-Arc-strong  as logical  no-undo init false.
define   shared variable  Show-Crsa         as logical  no-undo init false.
define   shared variable  Show-Cost         as logical  no-undo init false.
define   shared variable  Show-Sale         as logical  no-undo init false.
define   shared variable  Name-Sale-price   as character no-undo .
define   shared variable  Format-Folder     as logical no-undo .
define   shared variable  Print-List-Hist   as logical no-undo init false.
define   shared variable Make-Excel     as logical  no-undo init false.
define   shared variable Make-Excel-com as logical  no-undo init false.
define   shared stream ForExcel.
define   shared variable Use-column   as logical extent 256 no-undo .
define   shared variable right-column as logical extent 256 no-undo .
define shared  temp-table Sheetf no-undo
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
find first sheetf where sheet-num = 1 no-error.
define variable l-stroka as character no-undo .
define   shared  variable ch#ExcelApplication as com-handle no-undo .
define   shared  variable ch#Workbook         as com-handle no-undo .
define   shared  variable ch#Worksheet        as com-handle no-undo .
define   shared  variable Num#Str#            as integer no-undo.
define   shared  variable Number-List         as integer no-undo init 1.
define   shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define input  parameter parParentProc   as widget-handle no-undo.
define input  parameter v-mode-recid    as recid no-undo .
define input  parameter g#type          as character no-undo .
my-handle  = parParentProc .
define variable g#host-code  as integer   no-undo .
define variable g#host-name  as character no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
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
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
DEFINE TEMP-TABLE tt-date NO-UNDO
field exch-date as date
index pi is unique primary   exch-date .
define variable     str-obj#  as character no-undo .
define variable     str-obj2#  as character no-undo .
define variable     str-obj3#  as character no-undo .
define variable     rec-list  as character no-undo .
define variable     temp-param-obj as char no-undo.
define variable    temp-param-obj-type as char no-undo.
define buffer cli-obj      for ub.clients .
define buffer alt-obj-list for obj-list .
define variable ii as integer no-undo .
define variable  t-ret as log no-undo.
define variable d-Mond as log no-undo.
define variable rr as recid no-undo .
run loc-init in this-procedure .
DEFINE BUTTON B-1
     LABEL "Пн"
     SIZE 3.75 BY 1.13 TOOLTIP "Понедельник".
DEFINE BUTTON B-10
     LABEL "Очистить"
     SIZE 9.5 BY 1 TOOLTIP "Очистить список дат".
DEFINE BUTTON B-12
     LABEL "Удалить"
     SIZE 9.5 BY 1 TOOLTIP "Удалить из списка дат  по календарю".
DEFINE BUTTON B-2
     LABEL "Вт"
     SIZE 3.75 BY 1.13 TOOLTIP "Вторник".
DEFINE BUTTON B-3
     LABEL "Ср"
     SIZE 3.75 BY 1.13 TOOLTIP "Среда".
DEFINE BUTTON B-4
     LABEL "Чт"
     SIZE 3.75 BY 1.13 TOOLTIP "Четверг".
DEFINE BUTTON B-5
     LABEL "Пт"
     SIZE 3.75 BY 1.13 TOOLTIP "Пятница".
DEFINE BUTTON B-6
     LABEL "Сб"
     SIZE 3.75 BY 1.13 TOOLTIP "Суббота".
DEFINE BUTTON B-7
     LABEL "Вс"
     SIZE 3.75 BY 1.13 TOOLTIP "Воскресенье".
DEFINE BUTTON B-8
     LABEL "Сохранить"
     SIZE 9.5 BY 1 TOOLTIP "Сохранить список дат".
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-spis
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Выбор из списка темпов продаж"
     SIZE 2.75 BY .96 TOOLTIP "Пересчитать темп продаж за указанный период".
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выполнить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE date-p-1 AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE date-p-2 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Методы расчета Темпа продаж"
      VIEW-AS TEXT
     SIZE 28 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Включать в расчет объема продаж"
      VIEW-AS TEXT
     SIZE 31.88 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-1 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-2 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-3 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-4 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-5 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-6 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-7 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE R-algoritm AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
"За период времени", 1,
"За период был в наличие", 4,
"Из списка", 2,
"Календарный метод", 3
     SIZE 27.63 BY 2.88 TOOLTIP "Методы расчета темпов продаж" NO-UNDO.
DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 57.5 BY 11.75
     BGCOLOR 8 .
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 57.5 BY 1.25.
DEFINE VARIABLE t-rv AS LOGICAL INITIAL no
     LABEL "Расход внешний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-rvc AS LOGICAL INITIAL no
     LABEL "Расход внешний касса"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-rvz AS LOGICAL INITIAL no
     LABEL "Возврат внешний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-rvzc AS LOGICAL INITIAL no
     LABEL "Возврат внешний касса"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-sp AS LOGICAL INITIAL no
     LABEL "Списание внешнее"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-sppv AS LOGICAL INITIAL no
     LABEL "Списание пр-во"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-sppv-2 AS LOGICAL INITIAL no
     LABEL "Расход пр-во"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-sppv-3 AS LOGICAL INITIAL no
     LABEL "Расход внутренний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-sppv-4 AS LOGICAL INITIAL no
     LABEL "Возврат внутренний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .75 NO-UNDO.
DEFINE VARIABLE SelectObject AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
"Все по фирме", "firm":U,
"Текущий", "currency":U,
"Выборочно", "choice":U,
"Все", 'все':U,
'Из заказа' , 'order':U
     SIZE 14.88 BY 3.42 NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Объекты"
     VIEW-AS TEXT
     SIZE 27.63 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE BUTTON BUTTON-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-obj"
     SIZE 3 BY .88.
DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.13 BY 3.67.
DEFINE VARIABLE t-way AS LOGICAL INITIAL no
     LABEL "Учитывать предыдущие заказы"
     VIEW-AS TOGGLE-BOX
     SIZE 30.5 BY .75 NO-UNDO.
DEFINE VARIABLE T-clos AS LOGICAL INITIAL no
     LABEL "закрыто"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE VARIABLE T-rcv AS LOGICAL INITIAL no
     LABEL "поставка"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      tt-date SCROLLING.
DEFINE QUERY BR-obj-list FOR
      obj-list SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      ub.tmp-sale SCROLLING.
DEFINE BROWSE BR-obj-list
  QUERY BR-obj-list DISPLAY
      obj-list.obj-code
      obj-list.obj-type
      WITH NO-BOX NO-LABELS SIZE 15.38 BY 3.5
      BGCOLOR 8
      .
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      tt-date.exch-date COLUMN-LABEL "Даты" FORMAT "99/99/9999"
      WITH NO-ROW-MARKERS SEPARATORS SIZE 13.63 BY 11.
DEFINE FRAME Dialog-Frame
     BR-obj-list  AT ROW 2.44 COL 47.13
     R-algoritm   AT ROW 2.5  COL 2.63  NO-LABEL
     SelectObject AT ROW 2.54 COL 32 NO-LABEL
     BUTTON-obj   AT ROW 3.83 COL 43.88 NO-LABEL
     ub.tmp-sale.tmp-code AT ROW 6.21 COL 4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 9 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.tmp-sale.desc_ AT ROW 6.21 COL 13.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 43.13 BY 1
          BGCOLOR 8 FGCOLOR 4
     B-spis AT ROW 6.25 COL 2.75
     t-rv AT ROW 6.75 COL 66.75
     BROWSE-1 AT ROW 7.5 COL 39.63
     date-p-1 AT ROW 7.54 COL 3.63 COLON-ALIGNED
     date-p-2 AT ROW 7.54 COL 22.5 COLON-ALIGNED
     t-rvz AT ROW 7.58 COL 66.75
     t-rvc AT ROW 8.54 COL 66.75
     B-1 AT ROW 8.71 COL 2.75
     B-2 AT ROW 8.71 COL 6.63
     B-3 AT ROW 8.71 COL 10.38
     B-4 AT ROW 8.71 COL 14.25
     B-5 AT ROW 8.71 COL 18.13
     B-6 AT ROW 8.71 COL 22
     B-7 AT ROW 8.71 COL 25.63
     t-rvzc AT ROW 9.38 COL 66.75
     t-sp AT ROW 10.29 COL 66.75
     B-8 AT ROW 10.88 COL 2.25
     t-sppv AT ROW 11.21 COL 66.75
     t-sppv-2 AT ROW 12.13 COL 66.75
     t-sppv-3 AT ROW 13 COL 66.75
     B-10 AT ROW 13.21 COL 2.25
     t-sppv-4 AT ROW 13.88 COL 66.75
     B-12 AT ROW 15.5 COL 2.25
     t-way AT ROW 15.21 COL 66.63
     T-rcv AT ROW 16.75 COL 68.63
     T-clos AT ROW 17.75 COL 68.63
     B-Help AT ROW 19 COL 88.13
     Btn_OK AT ROW 19.04 COL 59.13
     Btn_Cancel AT ROW 19.04 COL 70
     FILL-IN-1 AT ROW 1.21 COL 2.75 NO-LABEL
     FILL-IN-3 AT ROW 6.08 COL 66.75 NO-LABEL
     FILL-IN-4 AT ROW 1.21 COL 32 NO-LABEL
     t-1 AT ROW 10 COL 3.88 NO-LABEL
     t-2 AT ROW 10 COL 7.75 NO-LABEL
     t-3 AT ROW 10 COL 11.38 NO-LABEL
     t-4 AT ROW 10 COL 15.13 NO-LABEL
     t-5 AT ROW 10 COL 19 NO-LABEL
     t-6 AT ROW 10 COL 23.13 NO-LABEL
     t-7 AT ROW 10 COL 26.5 NO-LABEL
     RECT-8 AT ROW 6.04 COL 1.5
     RECT-11 AT ROW 7.38 COL 1.5
     RECT-12 AT ROW 2.40 COL 31.75
     SPACE(40.99) SKIP(1.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры расчета заказа"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  run p-calc in this-procedure (input-output t-1 ,input 1) .
  display R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
END.
ON CHOOSE OF B-10 IN FRAME Dialog-Frame
DO:
   for each tt-date :
         delete tt-date.
   end.
   assign
    t-1 = false
    t-2 = false
    t-3 = false
    t-4 = false
    t-5 = false
    t-6 = false
    t-7 = false
 .
 display R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH tt-date NO-LOCK.
END.
ON CHOOSE OF B-12 IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF BROWSE-1 in frame Dialog-Frame
DO:
  find current tt-date no-error.
  if error-status :error then return no-apply.
  if available    tt-date then   delete tt-date.
  OPEN QUERY BROWSE-1 FOR EACH tt-date NO-LOCK.
END.
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
    run p-calc in this-procedure (input-output t-2 ,input 2) .
   display R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
END.
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
    run p-calc in this-procedure (input-output t-3 ,input 3) .
   display R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
END.
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
    run p-calc in this-procedure ( input-output t-4 ,input 4) .
   display R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
END.
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
    run p-calc in this-procedure ( input-output t-5 ,input 5) .
   display R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
END.
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
    run p-calc in this-procedure ( input-output t-6 ,input 6) .
   display R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
END.
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
    run p-calc in this-procedure ( input-output t-7 , input 0) .
   display R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
END.
ON CHOOSE OF B-8 IN FRAME Dialog-Frame
DO:
     message  'Режим отключен'.
END.
ON CHOOSE OF B-spis IN FRAME Dialog-Frame
DO:
define variable t-recid as recid no-undo .
  run ref/tmp-sale.w
     ( parParentProc ,
      input "b-sel",
      output t-recid
      ).
  rr = t-recid.
  find first ub.tmp-sale  where recid( ub.tmp-sale) = int(t-recid) no-lock no-error .
     if available  ub.tmp-sale and not error-status :error  then
     display  ub.tmp-sale.tmp-code
              ub.tmp-sale.desc_
              with frame Dialog-Frame .
END.
ON CHOOSE OF BUTTON-obj IN FRAME Dialog-Frame
DO:
  assign SelectObject.
  my-request = false .
  run select-objects-proc in this-procedure ( e-method ) .
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
define variable p-code as character no-undo .
define variable p-desc as character no-undo .
define variable t-type as character no-undo .
define variable loc-sum-min as decimal no-undo .
Assign frame Dialog-Frame R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 SelectObject
date-p-1
date-p-2
no-error .
assign
date-p-1 = date(date-p-1:screen-value)
date-p-2 = date(date-p-2:screen-value)
SelectObject    = SelectObject:screen-value
t-way  = if t-way:screen-value  = "no" then false else true  .
t-clos = if t-clos:screen-value = "no" then false else true  .
t-rcv  = if t-rcv:screen-value  = "no" then false else true  .
.
if error-status :error then error-status :error = false  .
if t-way = false then
assign
  t-clos  = false
  t-rcv   = false
.
display t-clos
        t-rcv  with frame Dialog-Frame .
if NOT ( t-way = true and  ( t-clos  = true  or  t-rcv  = true  )
         or
         t-way = false )
then do:
message "При учете предыдущих заказов надо выбрать хотя бы один статус !"
  view-as alert-box information.
   return no-apply.
end.
if R-algoritm = 3 and R-algoritm:visible and  not can-find (  first  tt-date  )  then do:
message "При календарном методе расчета должна быть заполнена таблица - даты"
  view-as alert-box information.
return no-apply.
end.
assign
    p-code = ub.tmp-sale.tmp-code
    p-desc = ub.tmp-sale.desc_
    no-error .
for each tmp#zakaz :
   loc-sum-min = 0 .
   tmp#zakaz.min-stock = 0 .
end.
e-method =  fill-in-1 + " : " + entry(R-algoritm * 2 - 1 , R-algoritm:RADIO-BUTTONS) +  ";" + chr(10) +
           (  if R-algoritm = 2 then ( p-desc   + chr(10)) else "" ) +
           (  if date-p-1 <> ? and R-algoritm <> 2 then "c  "  + string(date-p-1,"99/99/9999") else " " ) +
           (  if date-p-2 <> ? and R-algoritm <> 2 then " по " + string(date-p-2,"99/99/9999") else " " ) +  ";" +  chr(10) +
           (  if t-1 then " " + b-1:label   else "") +
           (  if t-2 then " " + b-2:label   else "") +
           (  if t-3 then " " + b-3:label   else "") +
           (  if t-4 then " " + b-4:label   else "") +
           (  if t-5 then " " + b-5:label   else "") +
           (  if t-6 then " " + b-6:label   else "") +
           (  if t-7 then " " + b-7:label   else "") +
            chr(10) +
            FILL-IN-3 + " : " .
 e-method = e-method +
         ( if  t-rv     then  " " + t-rv  :label     else "" ) +
         ( if  t-rvz    then  " " + t-rvz :label     else "" ) +
         ( if  t-rvc    then  " " + t-rvc :label     else "" ) +
         ( if  t-rvzc   then  " " + t-rvzc:label     else "" ) +
         ( if  t-sp     then  " " + t-sp  :label     else "" ) +
         ( if  t-sppv   then  " " + t-sppv:label     else "" ) +
         ( if  t-sppv-2 then  " " + t-sppv-2:label   else "" ) +
         ( if  t-sppv-3 then  " " + t-sppv-3:label   else "" ) +
         ( if  t-sppv-4 then  " " + t-sppv-4:label   else "" )
           .
 e-method = e-method +   chr(10) +
         ( if  t-way    then  " " + t-way  :label + " : "    else "" ) +
         ( if  t-rcv    then  " " + t-rcv  :label            else "" ) +
         ( if  t-clos   then  " " + t-clos :label            else "" ) + ";"
         .
 e-method = e-method +  chr(10) + "Объекты :&"  .
          for each obj-list :
                  e-method = e-method +  obj-list.obj-type + " " + string(obj-list.obj-code) + ","    .
          end.
    define variable Ret as logical no-undo .
     t-ret =  session:SET-WAIT-STATE("GENERAL") .
     define variable obj-jj as integer no-undo .
     for each obj-list :
       obj-jj = obj-jj + 1.
     end.
        run cus/make-rcv.p
                   ( input parParentProc,
                     input v-mode-recid ,
                     input date-p-1,
                     input date-p-2,
                     input "calc":U,
                     input no,
                     input R-algoritm,
                     input p-code,
                     input t-rv,
                     input t-rvz,
                     input t-rvc ,
                     input t-rvzc ,
                     input t-sp   ,
                     input t-sppv ,
                     input t-sppv-2,
                     input t-sppv-3,
                     input t-sppv-4,
                     input t-way,
                     input t-rcv,
                     input t-clos,
                     input table tt-date     ).
END.
ON VALUE-CHANGED OF R-algoritm IN FRAME Dialog-Frame
DO:
  run v-c-alg in this-procedure .
END.
ON VALUE-CHANGED OF SelectObject IN FRAME Dialog-Frame
DO:
Assign SelectObject.
run select-objects-proc in this-procedure (e-method).
END.
ON VALUE-CHANGED OF t-rv IN FRAME Dialog-Frame
DO:   assign frame Dialog-Frame   t-rv .   display t-rv  with FRAME Dialog-Frame  .  END.
ON VALUE-CHANGED OF t-way IN FRAME Dialog-Frame
run v-c-way in this-procedure .
ON VALUE-CHANGED OF t-rvc IN FRAME Dialog-Frame
DO:   assign frame Dialog-Frame   t-rvc .   display t-rvc  with FRAME Dialog-Frame  .  END.
ON VALUE-CHANGED OF t-rvz IN FRAME Dialog-Frame
DO:   assign frame Dialog-Frame   t-rvz .   display t-rvz  with FRAME Dialog-Frame  .  END.
ON VALUE-CHANGED OF t-rvzc IN FRAME Dialog-Frame
DO:   assign frame Dialog-Frame   t-rvzc .   display t-rvzc  with FRAME Dialog-Frame  .  END.
ON VALUE-CHANGED OF t-sp IN FRAME Dialog-Frame
DO:   assign frame Dialog-Frame   t-sp .   display t-sp  with FRAME Dialog-Frame  .  END.
ON VALUE-CHANGED OF t-sppv IN FRAME Dialog-Frame
DO:   assign frame Dialog-Frame   t-sppv .   display t-sppv  with FRAME Dialog-Frame  .  END.
ON VALUE-CHANGED OF t-sppv-2 IN FRAME Dialog-Frame
DO:   assign frame Dialog-Frame   t-sppv-2 .   display t-sppv-2  with FRAME Dialog-Frame  .  END.
ON VALUE-CHANGED OF t-sppv-3 IN FRAME Dialog-Frame
DO:   assign frame Dialog-Frame   t-sppv-3 .   display t-sppv-3  with FRAME Dialog-Frame  .  END.
ON VALUE-CHANGED OF t-sppv-4 IN FRAME Dialog-Frame
DO:   assign frame Dialog-Frame   t-sppv-4 .   display t-sppv-4  with FRAME Dialog-Frame  .  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-p-1 in frame Dialog-Frame
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
on delete-character of date-p-1 in frame Dialog-Frame
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
on ctrl-d of date-p-1 in frame Dialog-Frame
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
on ctrl-b of date-p-1 in frame Dialog-Frame
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
on ctrl-e of date-p-1 in frame Dialog-Frame
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
on ctrl-f of date-p-1 in frame Dialog-Frame
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
  define MENU m-ed-date17
    MENU-ITEM m-ed-date17-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date17-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date17-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date17-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-p-1 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date-p-1 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date17 :HANDLE
      date-p-1 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle17 as handle no-undo .
  assign
    v-label-handle17 = date-p-1 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle17)
  then do:
    if v-label-handle17 :tooltip = ""
    or v-label-handle17 :tooltip = ?
    then do:
      assign
        v-label-handle17 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date17-1 in menu m-ed-date17 DO:
    apply "ctrl-b":U to date-p-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date17-2 in menu m-ed-date17 DO:
    apply "ctrl-d":U to date-p-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date17-3 in menu m-ed-date17 DO:
    apply "ctrl-e":U to date-p-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date17-4 in menu m-ed-date17 DO:
    apply "ctrl-f":U to date-p-1 in frame Dialog-Frame .
  END.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-p-2 in frame Dialog-Frame
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
on delete-character of date-p-2 in frame Dialog-Frame
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
on ctrl-d of date-p-2 in frame Dialog-Frame
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
on ctrl-b of date-p-2 in frame Dialog-Frame
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
on ctrl-e of date-p-2 in frame Dialog-Frame
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
on ctrl-f of date-p-2 in frame Dialog-Frame
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
  define MENU m-ed-date19
    MENU-ITEM m-ed-date19-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date19-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date19-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date19-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-p-2 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date-p-2 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date19 :HANDLE
      date-p-2 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle19 as handle no-undo .
  assign
    v-label-handle19 = date-p-2 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle19)
  then do:
    if v-label-handle19 :tooltip = ""
    or v-label-handle19 :tooltip = ?
    then do:
      assign
        v-label-handle19 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date19-1 in menu m-ed-date19 DO:
    apply "ctrl-b":U to date-p-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-2 in menu m-ed-date19 DO:
    apply "ctrl-d":U to date-p-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-3 in menu m-ed-date19 DO:
    apply "ctrl-e":U to date-p-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-4 in menu m-ed-date19 DO:
    apply "ctrl-f":U to date-p-2 in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_ui in this-procedure .
  hide b-12 in frame Dialog-Frame .
  pay-day = date-sale-2 - date-sale-1 + 1 .
  frame Dialog-Frame:title = "Параметры расчета темпов продаж на объектах для формирования поставок ".
  SelectObject = SelectObject:screen-value in frame Dialog-Frame .
  run select-objects-proc in this-procedure ( e-method ).
  run v-c-alg in this-procedure .
  run v-c-way in this-procedure .
  hide t-way in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.tmp-sale SHARE-LOCK.
  GET FIRST Dialog-Frame.
  reposition Dialog-Frame to recid rr no-error  .
  find first ub.tmp-sale where rr = recid( ub.tmp-sale) no-lock no-error .
  DISPLAY  R-algoritm t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp
          t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1
          FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 t-way t-clos t-rcv
      WITH FRAME Dialog-Frame.
     if g#type = 'ФП':U then display   FILL-IN-4 SelectObject  br-obj-list  BUTTON-obj
        WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.tmp-sale THEN
    DISPLAY ub.tmp-sale.tmp-code ub.tmp-sale.desc_
      WITH FRAME Dialog-Frame.
  ENABLE RECT-8 RECT-11  R-algoritm t-rv date-p-1 date-p-2 t-rvz
         t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 B-Help Btn_OK
         Btn_Cancel FILL-IN-1 FILL-IN-3 t-way t-clos t-rcv
      WITH FRAME Dialog-Frame.
  if g#type = 'ФП':U then ENABLE SelectObject  br-obj-list  BUTTON-obj WITH FRAME Dialog-Frame.
                     else   hide  SelectObject  br-obj-list rect-12  BUTTON-obj in frame Dialog-Frame .
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-obj-list FOR EACH obj-list  NO-LOCK.    OPEN QUERY BROWSE-1 FOR EACH tt-date NO-LOCK.
  hide t-sppv-2  in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE Loc-init :
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output to-day
  )  .
define variable i as integer no-undo .
define buffer buf-fp_ord-doc for ub.ord-doc.
find first  buf-fp_ord-doc where recid ( buf-fp_ord-doc ) = v-mode-recid no-lock no-error .
find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name = buf-fp_ord-doc.doc-code and
         ubflt.usr-flt.call-point   = "ord-m":U    no-error .
if avail ubflt.usr-flt  then do:
  run init-screen in this-procedure ( ubflt.usr-flt.list_ ) .
end.
else do:
    assign
        date-p-1  = to-day - 30
        date-p-2  = to-day
        t-rv   = true
        t-rvz  = true
        t-rvc  = true
        t-rvzc = true
        r-algoritm = 1
    .
    find first ub.tmp-sale no-lock no-error .
    if error-status :error then do:
          create  ub.tmp-sale.
          assign  ub.tmp-sale.tmp-code = "1"
                  ub.tmp-sale.desc_    = "Пустой"
                  .
    end.
    find current ub.tmp-sale no-lock no-error .
    if available ub.tmp-sale then
        display  ub.tmp-sale.tmp-code
                  ub.tmp-sale.desc_   with frame Dialog-Frame .
end.
 rr = recid(ub.tmp-sale) .
 display R-algoritm ub.tmp-sale.tmp-code ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
 run v-c-alg in this-procedure .
END PROCEDURE.
procedure v-c-alg :
 do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  assign frame   Dialog-Frame   r-algoritm.
  case  r-algoritm:
  when 1 or when 4 then do:
         enable date-p-1 date-p-2
        t-rv  t-rvz t-rvc t-rvzc t-sp t-sppv
        t-sppv-2 t-sppv-3 t-sppv-4
         with frame Dialog-Frame .
         disable RECT-11 BROWSE-1 B-1 B-2 B-3 B-4 B-5 B-6 B-7 B-8  B-10 B-12 t-1 t-2 t-3 t-4 t-5 t-6 t-7 RECT-8 ub.tmp-sale.tmp-code ub.tmp-sale.desc_ B-spis  with frame Dialog-Frame .
         BROWSE-1:bgcolor  in frame Dialog-Frame  = 8 .
  end.
  when 2 then do:
        enable  RECT-8 ub.tmp-sale.tmp-code ub.tmp-sale.desc_ B-spis with frame Dialog-Frame .
        disable  date-p-1 date-p-2 RECT-11 BROWSE-1 B-1 B-2 B-3 B-4 B-5 B-6 B-7 B-8  B-10 B-12 t-1 t-2 t-3 t-4 t-5 t-6 t-7
        t-rv  t-rvz t-rvc t-rvzc t-sp t-sppv
        t-sppv-2 t-sppv-3 t-sppv-4
        with frame Dialog-Frame .
        BROWSE-1:bgcolor  in frame Dialog-Frame  = 8 .
  end.
  when 3 then do:
        enable   date-p-1 date-p-2 RECT-11 BROWSE-1 B-1 B-2 B-3 B-4 B-5 B-6 B-7 B-8  B-10 B-12 t-1 t-2 t-3 t-4 t-5 t-6 t-7
        t-rv  t-rvz t-rvc t-rvzc t-sp t-sppv
        t-sppv-2 t-sppv-3 t-sppv-4
          with frame Dialog-Frame .
        disable  RECT-8 ub.tmp-sale.tmp-code ub.tmp-sale.desc_ B-spis with frame Dialog-Frame .
        BROWSE-1:bgcolor  in frame Dialog-Frame  = ? .
   end.
   otherwise do:
   end.
  end case.
 display  RECT-11 BROWSE-1 B-1 B-2 B-3 B-4 B-5 B-6 B-7 B-8  B-10 B-12 t-1 t-2 t-3 t-4 t-5 t-6 t-7 RECT-8 ub.tmp-sale.tmp-code ub.tmp-sale.desc_ B-spis date-p-1 date-p-2 with frame Dialog-Frame .
 hide t-sppv-2 in frame Dialog-Frame .
 end.
end procedure.
PROCEDURE p-calc :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input-output parameter n-day as logical no-undo .
define input parameter n-i as integer no-undo .
define variable p-modulo as integer no-undo .
define variable t-i as date no-undo.
assign frame Dialog-Frame
   date-p-1 date-p-2.
  if date-p-1 = ? or  date-p-2 = ? then
  apply "entry " to date-p-1 .
if date-p-1 <> ? and  date-p-2 <> ? then do:
  if n-day = true then do:
        n-day = false.
         repeat t-i = date-p-1 To date-p-2 :
         p-modulo = if (integer(t-i) MODULO 7 ) = 0 then 7 else (integer(t-i) MODULO 7 ).
            if p-modulo = n-i then do:
                 find first tt-date where  tt-date.exch-date =  t-i no-error.
                    if available  tt-date then delete tt-date.
            end.
         end.
  end.
  else do:
        n-day = true.
         repeat t-i = date-p-1 To date-p-2 :
         p-modulo = if (integer(t-i) MODULO 7 ) = 0 then 7 else (integer(t-i) MODULO 7 ).
            if p-modulo = n-i then do:
                if not can-find ( first tt-date where tt-date.exch-date =  t-i ) then do:
                    create tt-date.
                    assign tt-date.exch-date =  t-i.
                    end.
            end.
         end.
  end.
   OPEN QUERY BROWSE-1 FOR EACH tt-date NO-LOCK.
  end.
 end.
end procedure.
PROCEDURE select-objects-proc :
 do
 on error undo, return error return-value
 :
define input parameter p-m as character no-undo .
define variable n-vv as integer   no-undo .
define variable v-all-object as logical   no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each obj-list :
 delete obj-list.
end.
str-obj#  = "" .
str-obj2# = "" .
str-obj3# = "" .
case selectobject :
when "currency":U then do:
 run verify-check.
end.
when 'все':U then   do:
 run sss.
end.
when "all" then   do:
 run sss.
end.
when "firm":U then   do:
 run sss.
end.
when "choice":U then do:
  for each obj-list :
      delete obj-list.
  end.
  define variable v-object-exist as logical   no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-exist in this-procedure
  (output v-object-exist
  )  .
  if not params-only and v-object-exist = false then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  )  .
     v-object-exist = true .
  end.
  if my-request     = false
  or v-object-exist = false
  then do:
    define variable v-user-select as logical   no-undo .
    define variable v-recids as character no-undo .
    if params-only then do:
    run ref/thobjs.w
        ( input my-handle
        , input this-procedure:handle
        , input (if params-only-mode = 'ПРОСМОТР':U then "b-mark-hidden" else "b-mark,b-sel")
        , input 'все':U
        , input ''
        , input ?
        , input ?
        , input-output v-recids ) no-error .
     end.
     else do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  my-handle
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
     end.
  end.
  my-request = true .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-exist in this-procedure
  (output v-object-exist
  )  .
  if v-object-exist = false
  then do:
    if temp-param-obj-type = 'shop':u or temp-param-obj-type = 'stock':u then do:
      assign selectobject = "firm":U .
    end.
    else do:
      assign selectobject =  "currency":u .
    end.
    display selectobject with frame Dialog-Frame .
    disable button-obj   with frame Dialog-Frame .
    find cli-obj where cli-obj.obj-type = v-cntxt-obj-type and
                        cli-obj.obj-code = v-cntxt-obj-code no-lock .
    if temp-param-obj-type = 'shop':u or temp-param-obj-type = 'stock':u
    then do:
      run sss.
    end.
    else do:
      run verify-check.
    end.
  end.
  else do:
      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
      define buffer buf_clients for ub.clients .
      define buffer buf_db for ub.db .
      define buffer buf_shop for ub.shop .
      define buffer buf_store for ub.store .
      define buffer buf_sysconf for ub.sysconf .
      for each buf_userobjs_temp-user-obj
      :
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
            and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
          .
          if verify-send-check  and buf_clients.db-num <> v-cntxt-db-num  and v-all-object = false then do:
                find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
                if buf_db.send-check = false then do:
                  str-obj2# = str-obj2#  + " " + buf_clients.obj-name + ",".
                  next.
                end.
          end.
          if temp-param-obj-type = 'shop':u and v-all-object = false then do:
              if buf_userobjs_temp-user-obj.obj-type = 'скл':U then do:
                  str-obj# = str-obj#  +  " " +  buf_clients.obj-name  .
                  next.
                end.
          end.
          if temp-param-obj-type = 'stock':u and v-all-object = false then do:
              if buf_userobjs_temp-user-obj.obj-type = 'маг':U then do:
                  str-obj# = str-obj#  +  " " +  buf_clients.obj-name  .
                  next.
              end.
          end.
          case buf_userobjs_temp-user-obj.obj-type:
              when 'скл':U then
                  do:
                      find buf_store where buf_store.obj-code = buf_userobjs_temp-user-obj.obj-code no-lock.
                      find first buf_sysconf no-lock where buf_sysconf.host-code = buf_store.host-code no-error.
                      find first buf_clients no-lock where
                                  buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type and
                                  buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
                          .
                      if buf_sysconf.base-code = base-code or v-all-object = true
                          then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_userobjs_temp-user-obj.obj-type ,
   input buf_userobjs_temp-user-obj.obj-code )
   .
                          end.
                          else do:
                            str-obj# = str-obj#  +  " " +  buf_clients.obj-name + "," .
                          end.
                  end.
              when 'маг':U then
                  do:
                      find first buf_shop where buf_shop.obj-code = buf_userobjs_temp-user-obj.obj-code no-lock.
                      find first buf_sysconf no-lock where buf_sysconf.host-code = buf_shop.host-code no-error.
                      find first buf_clients no-lock where
                                  buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type and
                                  buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code no-error.
                      if buf_sysconf.base-code = base-code or v-all-object = true
                            then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_userobjs_temp-user-obj.obj-type ,
   input buf_userobjs_temp-user-obj.obj-code )
   .
                          end.
                          else do:
                            str-obj# = str-obj#  +  " " +  buf_clients.obj-name + "," .
                          end.
                  end.
          end case.
        end.
    end.
end.
end case.
if SelectObject = "currency":U  or g#type <> 'ФП':U then do:
    for each  obj-list : delete obj-list . end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input store-type ,
   input store-code )
   .
end.
if SelectObject = 'order':U then do:
    for each  obj-list : delete obj-list . end.
    define variable str-pos as integer no-undo .
    define variable str-pos2 as integer no-undo .
    define variable str-1 as character no-undo .
    define variable i as integer no-undo .
    define variable e1 as character no-undo .
    define variable e2 as integer no-undo .
    str-pos = index (  p-m , "&" ) .
    str-pos2 = LENGTH ( p-m ) - str-pos .
    str-1 = substring (p-m , str-pos + 1 , str-pos2 ).
    n-vv = num-entries (str-1) .
    do i = 1 to n-vv :
        assign
          e1 = entry(1, (entry( i , str-1, "," )) , " ")
          e2 = integer(entry(2, (entry( i , str-1, "," )), " " ))
          no-error .
          if error-status :error then next.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input e1 ,
   input e2 )
   .
    end.
end.
OPEN QUERY BR-obj-list FOR EACH obj-list  NO-LOCK.
  end.
END PROCEDURE.
procedure verify-check :
 do
 on error undo, return error return-value
 :
 end.
end procedure.
procedure sss :
  do
  on error undo, return error return-value
  :
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  for each obj-list :  delete obj-list.  end.
  assign
    str-obj#  = ''
    str-obj2# = ''
    str-obj3# = ''.
  define buffer buf_user-obj for ub.user-obj .
  for each buf_user-obj no-lock
    where buf_user-obj.db-num  = v-cntxt-db-num
      and buf_user-obj.user-id = v-cntxt-userid
  ,each cli-obj no-lock
    where cli-obj.obj-type = buf_user-obj.obj-type
      and cli-obj.obj-code = buf_user-obj.obj-code
      and ( ( cli-obj.db-num = g#db-num ) or g#db-num = 0 )
  :
          find first ub.clients no-lock
            where ub.clients.obj-type = buf_user-obj.obj-type
              and ub.clients.obj-code = buf_user-obj.obj-code
            no-error .
          if verify-send-check  and ub.clients.db-num <> g#db-num  then do:
             find first ub.db where ub.db.db-num = ub.clients.db-num no-lock.
             if ub.db.send-check = false
             then do:
               assign
                 str-obj2# = str-obj2#  + " " + ub.clients.obj-name + ","
               .
               next.
             end.
          end.
          if temp-param-obj-type = 'shop':u
          then do:
            if buf_user-obj.obj-type = 'скл':U
            then do:
              assign
                str-obj# = str-obj#  +  " " + ub.clients.obj-name + ","
              .
              next.
            end.
          end.
          if temp-param-obj-type = 'stock':u
          then do:
            if buf_user-obj.obj-type = 'маг':U then do:
              assign
                str-obj# = str-obj#  +  " " +  ub.clients.obj-name + ","
              .
              next.
            end.
          end.
                case buf_user-obj.obj-type
                :
                    when 'скл':U then
                        do:
                            find ub.store where ub.store.obj-code = buf_user-obj.obj-code no-lock.
                            if selectobject = "firm":U then do:
                              if ub.store.host-code <> g#host-code then do:
                                  str-obj3# = str-obj3#  + " " + ub.clients.obj-name + ",".
                                  next.
                                  end.
                            end.
                            find first ub.sysconf no-lock where ub.sysconf.host-code = ub.store.host-code no-error.
                            find first ub.clients no-lock
                              where ub.clients.obj-type = buf_user-obj.obj-type
                                and ub.clients.obj-code = buf_user-obj.obj-code
                              no-error .
                            if ub.sysconf.base-code = base-code then
                                do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_user-obj.obj-type ,
   input buf_user-obj.obj-code )
   .
                                end.
                                else str-obj# = str-obj#  +  " " +   ub.clients.obj-name + "," .
                        end.
                    when 'маг':U then
                        do:
                            find ub.shop where ub.shop.obj-code = buf_user-obj.obj-code no-lock.
                            if selectobject = "firm":U then do:
                              if ub.shop.host-code <> g#host-code then do:
                                  str-obj3# = str-obj3#  + " " + ub.clients.obj-name + ",".
                                  next.
                                  end.
                            end.
                            find first ub.sysconf no-lock where ub.sysconf.host-code = ub.shop.host-code no-error.
                            find first ub.clients no-lock where
                                        ub.clients.obj-type = buf_user-obj.obj-type and
                                        ub.clients.obj-code = buf_user-obj.obj-code no-error.
                            if ub.sysconf.base-code = base-code
                            then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_user-obj.obj-type ,
   input buf_user-obj.obj-code )
   .
                            end.
                            else do:
                              assign
                                str-obj# = str-obj#  +  " " +  ub.clients.obj-name +  ","
                              .
                            end.
                        end.
                end case.
  end.
  end.
end procedure.
PROCEDURE init-screen :
 do
 on error undo, return error return-value
 :
define input parameter p-val as character no-undo .
define variable i as integer no-undo .
define variable R-algoritm2 as integer init 0 no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries (p-val) .
  do i = 1 to v-nn :
     case  entry(1,(entry(i,p-val)), "=" ) :
        when string( "R-algoritm" )             then do:
              if  integer(entry(2,(entry(i,p-val)), "=" )) = 2 then
                  R-algoritm2 = 2.
              end.
        when string( "R-algoritm2" )            then do:
             case integer(entry(2,(entry(i,p-val)), "=" ))  :
                when 1 then  R-algoritm =  1  .
                when 2 then  R-algoritm =  4  .
                when 3 then  R-algoritm =  3  .
             end case.
             if R-algoritm2 = 2 then  R-algoritm = 2.
             end.
        when string( "tmp-sale.tmp-code" )      then do:
             find first ub.tmp-sale no-lock where ub.tmp-sale.tmp-code = entry(2,(entry(i,p-val)), "=" ) no-error.
             if available ub.tmp-sale then do:
                rr = recid( ub.tmp-sale) .
                 display  ub.tmp-sale.tmp-code
                             ub.tmp-sale.desc_   with frame Dialog-Frame .
                 reposition Dialog-Frame to recid rr no-error  .
                 if error-status :error then error-status :get-message(1) .
             end.
             else do:
             find first ub.tmp-sale no-lock  .
                if available ub.tmp-sale then rr = recid(ub.tmp-sale) .
             end.
        end.
        when string( "SelectObject" ) then  do:
             SelectObject = string(entry(2,(entry(i,p-val)), "=" )).
                if SelectObject = "choice":U then SelectObject = "order":U .
                run select-objects-proc in this-procedure ( input p-val ).
             end.
        when string( "date-p-1" ) then  date-p-1 = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "date-p-2" ) then  date-p-2 = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "t-way"   )   then  t-way    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rcv"   )   then  t-rcv    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-clos"   )   then  t-clos    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rv"   )   then  t-rv    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rvz"  )   then  t-rvz   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rvc"  )   then  t-rvc   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-rvzc" )   then  t-rvzc  = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sp"   )   then  t-sp    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sppv" )   then  t-sppv  = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sppv-2")  then  t-sppv-2 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-sppv-3")  then  t-sppv-3 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sppv-4")  then  t-sppv-4 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
    end case.
    g#log = SelectObject:disable(radio-label('все':U , SelectObject:radio-buttons)).
  end.
end.
END PROCEDURE.
procedure v-c-way :
  do
  on error undo, return error return-value
  :
assign frame Dialog-Frame
  t-way
  t-rcv
  t-clos
 .
        if t-way  then do:
            enable
              t-rcv
              t-clos
              with frame Dialog-Frame .
            display
              t-rcv
              t-clos
              with frame Dialog-Frame .
        end.
        else do:
          hide
            t-rcv
            t-clos
            in frame Dialog-Frame .
        end.
  end.
end procedure.
