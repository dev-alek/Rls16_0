define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter v-mode as character no-undo .
define input  parameter G#type as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Методы расчета заказа " .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info11, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info11, return-value, chr(10), error-status :get-message (1)).
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
define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log        as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable is-abc       as character no-undo .
define variable par-type     as character no-undo .
define variable v-p-code as integer   no-undo .
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
run get-report-num  in parParentProc ( output g#report-num ).
define temp-table tt-date no-undo
field exch-date as date
index pi is unique primary   exch-date .
define buffer alt-obj-list for obj-list .
define temp-table temp-abc-day no-undo
field abc-type as character
field gar-day  as decimal
index pi abc-type
.
define temp-table temp-abc-day-empty no-undo
field abc-type as character
field gar-day  as decimal
index pi abc-type
.
define variable     str-obj#  as character no-undo .
define variable     str-obj2#  as character no-undo .
define variable     str-obj3#  as character no-undo .
define variable     rec-list  as character no-undo .
define var temp-param-obj as char no-undo.
define var temp-param-obj-type as char no-undo.
define buffer cli-obj  for ub.clients .
define variable ii as integer no-undo .
define variable  t-ret as log no-undo.
define variable d-Mond as log no-undo.
define variable rr as recid no-undo .
define buffer buf_usr-flt for ubflt.usr-flt .
DEFINE BUTTON B-1
     LABEL "Пн"
     SIZE 3 BY 1 TOOLTIP "Понедельник".
DEFINE BUTTON B-10
     LABEL "Очистить"
     SIZE 10.75 BY 1 TOOLTIP "Очистить список дат".
DEFINE BUTTON B-2
     LABEL "Вт"
     SIZE 3 BY 1 TOOLTIP "Вторник".
DEFINE BUTTON B-3
     LABEL "Ср"
     SIZE 3 BY 1 TOOLTIP "Среда".
DEFINE BUTTON B-4
     LABEL "Чт"
     SIZE 3 BY 1 TOOLTIP "Четверг".
DEFINE BUTTON B-5
     LABEL "Пт"
     SIZE 3 BY 1 TOOLTIP "Пятница".
DEFINE BUTTON B-6
     LABEL "Сб"
     SIZE 3 BY 1 TOOLTIP "Суббота".
DEFINE BUTTON B-7
     LABEL "Вс"
     SIZE 3 BY 1 TOOLTIP "Воскресенье".
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 3 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON B-save
     LABEL "Сохранить"
     SIZE 15 BY 1.13.
DEFINE BUTTON B-spis
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Выбор из списка темпов продаж"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка темпов продаж".
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "список объектов".
DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.
DEFINE VARIABLE v-round-m AS CHARACTER FORMAT "X(256)":U
     LABEL "Метод округления заказа"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE v-name AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 47 BY 2 NO-UNDO.
DEFINE VARIABLE date-p-1 AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE date-p-2 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 10.75 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-13 AS CHARACTER FORMAT "X(256)":C32 INITIAL "Объекты"
      VIEW-AS TEXT
     SIZE 32.13 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-14 AS CHARACTER FORMAT "X(256)":C21 INITIAL "Объем продаж включает"
      VIEW-AS TEXT
     SIZE 43.63 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-15 AS CHARACTER FORMAT "X(256)":C17 INITIAL "Количество дней"
      VIEW-AS TEXT
     SIZE 30.88 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-16 AS CHARACTER FORMAT "X(256)":U INITIAL "Список:"
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-17 AS CHARACTER FORMAT "X(256)":C20 INITIAL "Методы расчета темпа продаж"
      VIEW-AS TEXT
     SIZE 39.38 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":C12 INITIAL "Параметры товара"
      VIEW-AS TEXT
     SIZE 23 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL " до привоза товара"
      VIEW-AS TEXT
     SIZE 12 BY .5
     FONT 4 NO-UNDO.
DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL " заказ которого меньше"
      VIEW-AS TEXT
     SIZE 16 BY .67
     FONT 4 NO-UNDO.
DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL " минимального заказа"
      VIEW-AS TEXT
     SIZE 15.38 BY .67
     FONT 4 NO-UNDO.
DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "в статусах:"
      VIEW-AS TEXT
     SIZE 12.13 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE t-1 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.
DEFINE VARIABLE t-2 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.
DEFINE VARIABLE t-3 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.
DEFINE VARIABLE t-4 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.
DEFINE VARIABLE t-5 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.
DEFINE VARIABLE t-6 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.
DEFINE VARIABLE t-7 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.
DEFINE VARIABLE t-gar-1 AS CHARACTER FORMAT "X(256)":U INITIAL "остаток которого"
      VIEW-AS TEXT
     SIZE 12 BY .67
     FONT 4 NO-UNDO.
DEFINE VARIABLE t-gar-2 AS CHARACTER FORMAT "X(256)":U INITIAL "больше гарантийного запаса"
      VIEW-AS TEXT
     SIZE 25.5 BY .67
     FONT 4 NO-UNDO.
DEFINE VARIABLE t-min-ost-1 AS CHARACTER FORMAT "X(256)":U INITIAL "остаток которого"
      VIEW-AS TEXT
     SIZE 11.63 BY .67
     FONT 4 NO-UNDO.
DEFINE VARIABLE t-min-ost-2 AS CHARACTER FORMAT "X(256)":U INITIAL "больше минимального остатка"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FONT 4 NO-UNDO.
DEFINE VARIABLE v-round-base AS DECIMAL FORMAT "->>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE R-algoritm AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Среднесуточный", 1,
"Из списка", 2,
"Вероятностный по гарантийному запасу", 3,
"По максимуму объема продаж", 4,
"Заказ до максимального остатка", 5,
"По ABC-анализу", 6
     SIZE 39.25 BY 3.75 NO-UNDO.
DEFINE VARIABLE R-algoritm2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все за период", 1,
"Без дней без товара", 2,
"Выбранные по календарю", 3
     SIZE 30 BY 2 NO-UNDO.
DEFINE VARIABLE R-min-rest AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "На объекте", 1,
"На фирме", 2
     SIZE 23 BY 1.54 TOOLTIP "Используемый в расчете параметр товара со склада или с фирмы в целом" NO-UNDO.
DEFINE VARIABLE SelectObject AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все по фирме", "firm":U,
"Текущий", "currency":U,
"Выборочно", "choice":U,
"Все", "all":U,
"Из заказа", "order":U
     SIZE 15.13 BY 3.88 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.13 BY 4.79.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.88 BY 11.88.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 24 BY 4.79.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.63 BY 10.13.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.63 BY 5.29.
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45 BY 5.33.
DEFINE VARIABLE p-neg-sale AS LOGICAL INITIAL no
     LABEL "Запрет на продажу в минус"
     VIEW-AS TOGGLE-BOX
     SIZE 20.25 BY .5 TOOLTIP "Запрет на продажу в минус до привоза товара"
     FONT 4 NO-UNDO.
DEFINE VARIABLE p-prt-art AS LOGICAL INITIAL no
     LABEL "Печать артикула на всех строках"
     VIEW-AS TOGGLE-BOX
     SIZE 34.13 BY .83 TOOLTIP "Печать артикула на всех строках отчета"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE r-min-rest3 AS LOGICAL INITIAL no
     LABEL "Сезонный мин.остаток"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .83 TOOLTIP "использовать параметр товара мин.остаток = сезонный" NO-UNDO.
DEFINE VARIABLE T-clos AS LOGICAL INITIAL no
     LABEL "закрыто"
     VIEW-AS TOGGLE-BOX
     SIZE 12.13 BY .83
     FONT 4 NO-UNDO.
DEFINE VARIABLE T-DeadLine AS LOGICAL INITIAL no
     LABEL "Учитывать срок хранения"
     VIEW-AS TOGGLE-BOX
     SIZE 31 BY .83 TOOLTIP "Ограничивать размер заказ сроком хранения из карточки товара"
     FONT 4 NO-UNDO.
DEFINE VARIABLE T-gar AS LOGICAL INITIAL no
     LABEL "Не заказывать товар,"
     VIEW-AS TOGGLE-BOX
     SIZE 16.75 BY .83 TOOLTIP "Не заказывать товар, остаток которого больше гарантийного запаса"
     FONT 4 NO-UNDO.
DEFINE VARIABLE T-min-ost AS LOGICAL INITIAL no
     LABEL "Не заказывать товар,"
     VIEW-AS TOGGLE-BOX
     SIZE 17.5 BY .83 TOOLTIP "Не заказывать товар, остаток которого больше минимального запаса"
     FONT 4 NO-UNDO.
DEFINE VARIABLE T-min-zapas AS LOGICAL INITIAL no
     LABEL "Не заказывать товар,"
     VIEW-AS TOGGLE-BOX
     SIZE 16.63 BY .83 TOOLTIP "Не заказывать товар, заказ которого меньше минимального заказа"
     FONT 4 NO-UNDO.
DEFINE VARIABLE T-rcv AS LOGICAL INITIAL no
     LABEL "поставка"
     VIEW-AS TOGGLE-BOX
     SIZE 12.13 BY .83
     FONT 4 NO-UNDO.
DEFINE VARIABLE t-rv AS LOGICAL INITIAL no
     LABEL "Расход внешний"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.
DEFINE VARIABLE t-rvc AS LOGICAL INITIAL no
     LABEL "Расход внешний касса"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-rvz AS LOGICAL INITIAL no
     LABEL "Возврат внешний"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.
DEFINE VARIABLE T-rvzc AS LOGICAL INITIAL no
     LABEL "Возврат внешний касса"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE T-sp AS LOGICAL INITIAL no
     LABEL "Списание внешнее"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.
DEFINE VARIABLE T-sppv-2 AS LOGICAL INITIAL no
     LABEL "Списание пр-во"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.
DEFINE VARIABLE t-sppv-3 AS LOGICAL INITIAL no
     LABEL "Расход внутренний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE T-sppv-4 AS LOGICAL INITIAL no
     LABEL "Возврат внутр."
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE VARIABLE t-way AS LOGICAL INITIAL no
     LABEL "Учитывать предыдущие заказы"
     VIEW-AS TOGGLE-BOX
     SIZE 31.88 BY .83
     FONT 4 NO-UNDO.
DEFINE QUERY BR-obj-list FOR
      obj-list SCROLLING.
DEFINE QUERY BROWSE-1 FOR
      tt-date SCROLLING.
DEFINE QUERY BROWSE-abc-day FOR
      temp-abc-day SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tmp-sale SCROLLING.
DEFINE BROWSE BR-obj-list
  QUERY BR-obj-list DISPLAY
      obj-list.obj-code
      obj-list.obj-type
    WITH NO-BOX NO-LABELS NO-ROW-MARKERS SIZE 17.38 BY 3.88
         BGCOLOR 8 .
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      tt-date.exch-date column-label "Даты":C10 format "99/99/9999"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 13.25 BY 7.29.
DEFINE BROWSE BROWSE-abc-day
  QUERY BROWSE-abc-day DISPLAY
      temp-abc-day.abc-type COLUMN-LABEL "ABC" FORMAT "x(3)"
temp-abc-day.gar-day  COLUMN-LABEL "Гарант.запас!в днях  " FORMAT ">>>>>>>>>9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 18.5 BY 7.33 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     R-algoritm AT ROW 2 COL 2 NO-LABEL
     R-min-rest AT ROW 2.21 COL 43.13 NO-LABEL
     p-neg-sale AT ROW 2.3 COL 67.5
     T-gar AT ROW 3.1 COL 67.5
     r-min-rest3 AT ROW 3.92 COL 43.13
     T-min-ost AT ROW 4.45 COL 67.5 WIDGET-ID 2
     T-min-zapas AT ROW 5.9 COL 67.5
     R-algoritm2 AT ROW 7.25 COL 2.25 NO-LABEL
     SelectObject AT ROW 7.29 COL 34.13 NO-LABEL
     BR-obj-list AT ROW 7.29 COL 49.13
     T-DeadLine AT ROW 7.35 COL 67.5 WIDGET-ID 12
     BUTTON-obj AT ROW 8.75 COL 45.88
     date-p-1 AT ROW 9.33 COL 3.63 COLON-ALIGNED
     date-p-2 AT ROW 9.33 COL 19.25 COLON-ALIGNED
     t-way AT ROW 10.29 COL 67.5
     BROWSE-1 AT ROW 10.38 COL 6.88
     BROWSE-abc-day AT ROW 10.42 COL 1.5
     B-10 AT ROW 10.42 COL 21.25
     B-1 AT ROW 10.5 COL 1.5
     B-2 AT ROW 11.5 COL 1.5
     T-clos AT ROW 11.96 COL 79
     B-3 AT ROW 12.5 COL 1.5
     T-rcv AT ROW 12.71 COL 79
     t-rv AT ROW 12.75 COL 34.13
     t-rvc AT ROW 12.79 COL 53.25
     B-4 AT ROW 13.5 COL 1.5
     t-rvz AT ROW 13.67 COL 34.13
     T-rvzc AT ROW 13.67 COL 53.25
     B-5 AT ROW 14.5 COL 1.5
     T-sppv-4 AT ROW 14.5 COL 53.25
     T-sp AT ROW 14.54 COL 34.13
     T-sppv-2 AT ROW 15.42 COL 34.13
     t-sppv-3 AT ROW 15.42 COL 53.25
     B-6 AT ROW 15.5 COL 1.5
     B-7 AT ROW 16.5 COL 1.5
     v-round-m AT ROW 17 COL 58 COLON-ALIGNED
     v-round-base AT ROW 17 COL 84 COLON-ALIGNED NO-LABEL
     B-spis AT ROW 18.42 COL 9.75
     v-name AT ROW 19.5 COL 1 NO-LABEL
     p-prt-art AT ROW 19.67 COL 66 WIDGET-ID 8
     B-save AT ROW 20.5 COL 51.63
     Btn_OK AT ROW 20.5 COL 66.75
     Btn_Cancel AT ROW 20.5 COL 82
     B-Help AT ROW 20.5 COL 97.5
     i-exit AT ROW 20.71 COL 66.88 WIDGET-ID 10
     FILL-IN-2 AT ROW 1.21 COL 41.13 COLON-ALIGNED NO-LABEL
     FILL-IN-17 AT ROW 1.25 COL 1.88 NO-LABEL
     FILL-IN-3 AT ROW 2.25 COL 85.5 COLON-ALIGNED NO-LABEL
     t-gar-1 AT ROW 3.15 COL 82.38 COLON-ALIGNED NO-LABEL
     t-gar-2 AT ROW 3.75 COL 68 COLON-ALIGNED NO-LABEL
     t-min-ost-1 AT ROW 4.5 COL 82.38 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     t-min-ost-2 AT ROW 5.1 COL 68 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     FILL-IN-5 AT ROW 6 COL 82 COLON-ALIGNED NO-LABEL
     FILL-IN-15 AT ROW 6.25 COL 1.63 NO-LABEL
     FILL-IN-13 AT ROW 6.33 COL 32.25 COLON-ALIGNED NO-LABEL
     FILL-IN-7 AT ROW 6.55 COL 68 COLON-ALIGNED NO-LABEL
     t-1 AT ROW 10.58 COL 2.63 COLON-ALIGNED NO-LABEL
     FILL-IN-8 AT ROW 11.25 COL 77 COLON-ALIGNED NO-LABEL
     FILL-IN-14 AT ROW 11.54 COL 32.5 COLON-ALIGNED NO-LABEL
     t-2 AT ROW 11.67 COL 2.63 COLON-ALIGNED NO-LABEL
     t-3 AT ROW 12.54 COL 2.63 COLON-ALIGNED NO-LABEL
     t-4 AT ROW 13.67 COL 2.63 COLON-ALIGNED NO-LABEL
     t-5 AT ROW 14.71 COL 2.63 COLON-ALIGNED NO-LABEL
     t-6 AT ROW 15.67 COL 2.63 COLON-ALIGNED NO-LABEL
     t-7 AT ROW 16.58 COL 2.63 COLON-ALIGNED NO-LABEL
     FILL-IN-16 AT ROW 18.04 COL 1.75 NO-LABEL
     tmp-sale.desc_ AT ROW 18.21 COL 11 COLON-ALIGNED NO-LABEL FORMAT "X(120)"
           VIEW-AS TEXT
          SIZE 59.88 BY .67
          FGCOLOR 1
     tmp-sale.tmp-code AT ROW 19.04 COL 11 COLON-ALIGNED NO-LABEL FORMAT "X(120)"
           VIEW-AS TEXT
          SIZE 59.75 BY .67
     "Дополнительные условия расчета":C32 VIEW-AS TEXT
          SIZE 32 BY .67 AT ROW 1.25 COL 67.25
          BGCOLOR 8 FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         FGCOLOR 0
         CANCEL-BUTTON Btn_Cancel.
DEFINE FRAME Dialog-Frame
     RECT-1 AT ROW 1.08 COL 1
     RECT-3 AT ROW 6 COL 1.13
     RECT-5 AT ROW 1.08 COL 42.38
     RECT-6 AT ROW 1.13 COL 66.88
     RECT-7 AT ROW 6 COL 33.5
     RECT-8 AT ROW 11.42 COL 33.5
     SPACE(21.99) SKIP(4.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         FGCOLOR 0
         TITLE "Параметры расчета заказа"
         CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-save:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       v-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  run p-calc in this-procedure ( input-output t-1 , input 1) .
  display  BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
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
 display  BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  with frame Dialog-Frame.
  OPEN QUERY browse-1 FOR EACH tt-date .
END.
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  run p-calc in this-procedure (input-output t-2 ,input 2) .
  display  BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  with frame Dialog-Frame.
END.
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  run p-calc in this-procedure  (input-output t-3 ,input 3) .
  display  BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  with frame Dialog-Frame.
END.
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
  run p-calc in this-procedure (input-output t-4 ,input 4) .
  display  BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  with frame Dialog-Frame.
END.
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  run p-calc in this-procedure (input-output t-5 ,input 5) .
  display  BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  with frame Dialog-Frame.
END.
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  run p-calc in this-procedure (input-output t-6 ,input 6) .
  display  BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  with frame Dialog-Frame.
END.
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  run p-calc in this-procedure (input-output t-7 ,input 7) .
  display BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame.
END.
ON CHOOSE OF B-save IN FRAME Dialog-Frame
DO:
apply "choose" to btn_ok  in frame Dialog-Frame .
 find first buf_usr-flt  exclusive-lock  where
         buf_usr-flt.user-name    = g#userid and
         buf_usr-flt.call-point   = "all-ord":U   no-error .
     if NOT available buf_usr-flt then  create buf_usr-flt.
     find first ub.tmp-sale where recid(ub.tmp-sale) = rr  no-lock no-error .
       Assign
         buf_usr-flt.user-name    = g#userid
         buf_usr-flt.call-point   = "all-ord":U
         buf_usr-flt.list_ = "".
         run remember-screen ( input-output buf_usr-flt.list_ ).
t-ret =  session:SET-WAIT-STATE("") .
END.
ON CHOOSE OF B-spis IN FRAME Dialog-Frame
DO:
define variable t-recid as recid no-undo .
define variable s-recid as character no-undo .
    if r-algoritm = 6 then do:
      define buffer buf_abc-analysis for ub.abc-analysis  .
      define buffer buff_abc-analysis for ub.abc-analysis  .
      run cus/abc-run.p (input parparentproc, output s-recid ).
      if num-entries(s-recid) <> 2 THEN DO:
        message "Для данного метода расчета надо выбрать 2 анализа" view-as alert-box information .
        return no-apply.
      END.
      find first buff_abc-analysis  where recid(buff_abc-analysis) = int(entry(1,s-recid)) no-lock no-error .
      if available buff_abc-analysis and not error-status :error  then do:
        v-p-code = buff_abc-analysis.abc-id .
        display ( buff_abc-analysis.abc-name  + " от " +  string(buff_abc-analysis.abc-date-create, "99/99/9999")) @ ub.tmp-sale.desc_
                  with frame Dialog-Frame .
                  v-name = "1." + ( buff_abc-analysis.abc-name + " от " + string(buff_abc-analysis.abc-date-create, "99/99/9999")) .
       end.
      if num-entries(s-recid) > 1 then do:
          find first buf_abc-analysis  where recid(buf_abc-analysis) = int(entry(2,s-recid)) no-lock no-error .
          rr = ? .
          if available buf_abc-analysis and not error-status :error  then do:
            display ( buf_abc-analysis.abc-name  + " от " +  string(buf_abc-analysis.abc-date-create, "99/99/9999")) @  ub.tmp-sale.tmp-code
                      with frame Dialog-Frame .
                      v-name = v-name + " 2." + ( buf_abc-analysis.abc-name  + " от " +  string(buf_abc-analysis.abc-date-create, "99/99/9999")) .
            end.
      end.
  end.
  else do:
      run ref/tmp-sale.w
        (input parparentproc
        ,input "b-sel"
        ,output t-recid
        ).
      find first ub.tmp-sale  where recid(ub.tmp-sale) = int(t-recid) no-lock no-error .
      rr = t-recid.
      if available  ub.tmp-sale and not error-status :error  then
        display  ub.tmp-sale.tmp-code
                 ub.tmp-sale.desc_
                 with frame Dialog-Frame .
        else do:
        display "" @ ub.tmp-sale.tmp-code
                "" @ ub.tmp-sale.desc_
                 with frame Dialog-Frame .
        end.
      end.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
define variable p-code as character no-undo .
define variable p-desc as character no-undo .
define variable obj-jj as integer no-undo .
define variable Ret as logical no-undo .
define variable t-type as character no-undo .
define variable loc-sum-min as decimal no-undo .
Assign frame Dialog-Frame R-algoritm R-min-rest p-neg-sale T-gar r-min-rest3 T-min-ost T-min-zapas R-algoritm2 T-DeadLine date-p-1 date-p-2 t-way T-clos T-rcv t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 v-round-m p-prt-art FILL-IN-2 FILL-IN-17 FILL-IN-3 t-gar-1 t-gar-2 t-min-ost-1 t-min-ost-2 FILL-IN-5 FILL-IN-15 FILL-IN-13 FILL-IN-7 FILL-IN-8 FILL-IN-16  no-error .
Assign frame Dialog-Frame v-round-base no-error .
if date-p-1 <> ? and date-p-2 <> ? then do:
   if date-p-1 >  date-p-2 then do:
                                 message "Не верно задан интервал дат для расчета объема продаж !"
                                 view-as alert-box information.
                                 return no-apply .
                                end.
end.
if (t-rv      = false  and
    t-rvz     = false  and
    t-rvc     = false  and
    t-rvzc    = false  and
    t-sp      = false  and
    t-sppv-2  = false  and
    t-sppv-3  = false  and
    t-sppv-4  = false ) and
    ( R-algoritm <> 2  and R-algoritm <> 6  and  R-algoritm <> 5)  then do:
     message  " Не выбран ни один тип документа, по которым рассчитывается объем продаж !"
     view-as alert-box information.
     return no-apply .
end.
if v-round-m = 'Кол-во_в_коробке':U then do:
   for each  tmp#zakaz :
       if tmp#zakaz.cli-base-rate <> 1 then do:
        message
        substitute("При методе округления до числа в упаковке не учитывается ед.измерения Поставщика.
        &3Измените ед.изм. поставщика в заказе у товара &3артикул &1 код &2  &3на &4"
          , tmp#zakaz.artic, tmp#zakaz.gds-code, chr(10) , tmp#zakaz.unit-base)
          view-as alert-box information.
          return no-apply.
       end.
   end.
end.
if t-way:visible = false then t-way = false .
if t-way = false then
assign
  t-clos  = false
  t-rcv   = false
.
if NOT ( t-way = true and  ( t-clos  = true  or  t-rcv  = true  )
         or
         t-way = false )
then do:
message "При учете предыдущих заказов надо выбрать хотя бы один статус !"
  view-as alert-box information.
   return no-apply.
end.
if t-way:visible = false then t-way = false .
if R-algoritm2 = 3 and R-algoritm2:visible  and not can-find (  first  tt-date  )  then do:
message "При календарном методе расчета должна быть заполнена таблица - даты"
  view-as alert-box information.
return no-apply.
end.
if  R-algoritm = 2 then do:
if not available ub.tmp-sale then
   find ub.tmp-sale  where recid(ub.tmp-sale) = rr no-lock no-error  .
    if available ub.tmp-sale then
        assign
            p-code = ub.tmp-sale.tmp-code
            p-desc = ub.tmp-sale.desc_
            .
end.
if  R-algoritm = 2  and ( ub.tmp-sale.tmp-code:screen-value in frame Dialog-Frame = ? OR ub.tmp-sale.tmp-code:screen-value in frame Dialog-Frame = "" ) then do:
    message "Не выбран список темпов продаж!!!"
    view-as alert-box information.
    return no-apply.
end.
if  R-algoritm = 6  then do:
    assign
        p-code = ?
        p-desc = v-name
    .
end.
if v-mode <> "all-ord":U then dO:
   run ord-mm in this-procedure .
end.
e-method =  FILL-IN-17 + " : " + entry(R-algoritm * 2 - 1 , R-algoritm:RADIO-BUTTONS)   +
           (  if R-algoritm = 2 or R-algoritm = 6 then ( " : " +  p-desc   + chr(10)) else "" ) +  ";" .
if R-algoritm <> 2  and R-algoritm <> 5 and  R-algoritm <> 6 then
e-method =  e-method  +  FILL-IN-15 + " : " + entry(R-algoritm2 * 2 - 1 , R-algoritm2:RADIO-BUTTONS) +  ";" + chr(10) +
           (  if date-p-1 <> ? and R-algoritm <> 2 and R-algoritm <> 6 and R-algoritm <> 5 then "c  "  + string(date-p-1,"99/99/9999") else " " ) +
           (  if date-p-2 <> ? and R-algoritm <> 2 and R-algoritm <> 6 and R-algoritm <> 5 then " по " + string(date-p-2,"99/99/9999") else " " ) +  ";" +  chr(10) +
           (  if t-1 then " " + b-1:label   else "" ) +
           (  if t-2 then " " + b-2:label   else "" ) +
           (  if t-3 then " " + b-3:label   else "" ) +
           (  if t-4 then " " + b-4:label   else "" ) +
           (  if t-5 then " " + b-5:label   else "" ) +
           (  if t-6 then " " + b-6:label   else "" ) +
           (  if t-7 then " " + b-7:label   else "" ) .
e-method =  e-method  +      ";" +  chr(10) +
           FILL-IN-2 + " : " + entry(R-min-rest * 2 - 1 , R-min-rest:RADIO-BUTTONS)  .
 e-method = e-method +   chr(10) +
         ( if  r-min-rest3    then  " : " + r-min-rest3:label  else "" ) + ";" .
 e-method = e-method +   chr(10)   +
         ( if  FILL-IN-14:visible             then  FILL-IN-14 + " : "     else "" ) +
         ( if  t-rv     and t-rv:visible      then  " " + t-rv  :label     else "" ) +
         ( if  t-rvz    and t-rvz:visible     then  " " + t-rvz :label     else "" ) +
         ( if  t-rvc    and t-rvc:visible     then  " " + t-rvc :label     else "" ) +
         ( if  t-rvzc   and t-rvzc:visible    then  " " + t-rvzc:label     else "" ) +
         ( if  t-sp     and t-sp:visible      then  " " + t-sp  :label     else "" ) +
         ( if  t-sppv-2 and t-sppv-2:visible  then  " " + t-sppv-2:label   else "" ) +
         ( if  t-sppv-3 and t-sppv-3:visible  then  " " + t-sppv-3:label   else "" ) +
         ( if  t-sppv-4 and t-sppv-4:visible  then  " " + t-sppv-4:label   else "" )
           .
 e-method = e-method +   chr(10) +
         ( if  t-way    and t-way:visible   then  " " + t-way  :label + " : "    else "" ) +
         ( if  t-rcv    and t-rcv:visible   then  " " + t-rcv  :label            else "" ) +
         ( if  t-clos   and t-clos:visible  then  " " + t-clos :label            else "" ) + ";"
         .
 e-method = e-method +   chr(10) +
         ( if  p-neg-sale  and  p-neg-sale:visible   then  " " + p-neg-sale  :tooltip + " : "    else "" ) +
         ( if  t-gar       and  t-gar:visible        then  " " + t-gar  :tooltip            else "" ) +
         ( if  t-min-ost   and  t-min-ost:visible    then  " " + t-min-ost  :tooltip + " : "    else "" ) +
         ( if  t-DeadLine  and  t-DeadLine:visible    then  " " + t-DeadLine :tooltip + " : "    else "" ) +
         ( if  t-min-zapas and  t-min-zapas:visible  then  " " + t-min-zapas :tooltip            else "" ) + ";"
         .
 e-method = e-method +  chr(10) + "Объекты :&"  .
          for each obj-list :
                  e-method = e-method +  obj-list.obj-type + " " + string(obj-list.obj-code) + ","    .
          end.
 if v-mode <> "all-ord":U then dO:
      find first buf_usr-flt  exclusive-lock  where
              buf_usr-flt.user-name    = loc-ord-num and
              buf_usr-flt.call-point   = "ord-m":U + ( if v-mode <> ? then v-mode else "" )  no-error .
          if NOT available buf_usr-flt then  create buf_usr-flt.
          find first ub.tmp-sale where recid(ub.tmp-sale) = rr  no-lock no-error .
            Assign
              buf_usr-flt.user-name    = loc-ord-num
              buf_usr-flt.call-point   = "ord-m":U + ( if v-mode <> ? then v-mode else "" )
              buf_usr-flt.list_ = "".
              run remember-screen ( input-output buf_usr-flt.list_ ).
      find first buf_usr-flt  exclusive-lock  where
              buf_usr-flt.user-name    = g#userid and
              buf_usr-flt.call-point   = "ord-m":U  no-error .
          if NOT available buf_usr-flt then  create buf_usr-flt.
            Assign
              buf_usr-flt.user-name    = g#userid
              buf_usr-flt.call-point   = "ord-m":U
              buf_usr-flt.list_ = "".
              run remember-screen ( input-output buf_usr-flt.list_ ).
      t-ret =  session:SET-WAIT-STATE("GENERAL") .
          for each obj-list :
            obj-jj = obj-jj + 1.
          end.
          if g#type = 'ФП':U and R-min-rest = 1 then  do:
             if R-algoritm = 6  then do:
                run cus/qnty-obj.p
                (     input parParentProc,
                      input v-round-m ,
                      input v-round-base ,
                      input e-method ,
                      input v-mode,
                      input loc-ord-num ,
                      input date-p-1,
                      input date-p-2,
                      input "calc":U,
                      input no,
                      input 2  ,
                      input R-algoritm2,
                      input R-min-rest ,
                      input R-min-rest3,
                      input p-code     ,
                      input t-rv       ,
                      input t-rvz      ,
                      input t-rvc      ,
                      input t-rvzc  ,
                      input t-sp    ,
                      input t-sppv-2  ,
                      input t-sppv-2,
                      input t-sppv-3,
                      input t-sppv-4,
                      input t-way   ,
                      input t-rcv   ,
                      input t-clos  ,
                      input table tt-date ,
                      input table temp-abc-day ,
                      input p-neg-sale  ,
                      input t-gar       ,
                      input t-min-zapas ,
                      input t-min-ost   ,
                      input t-deadline   ,
                      input store-type  ,
                      input store-code  ,
                      input g#type      ,
                      input no
                      ) no-error .
             end.
             else do:
                run cus/qnty-obj.p
                (     input parParentProc,
                      input v-round-m ,
                      input v-round-base ,
                      input e-method ,
                      input v-mode,
                      input loc-ord-num ,
                      input date-p-1,
                      input date-p-2,
                      input "calc":U,
                      input no,
                      input R-algoritm  ,
                      input R-algoritm2,
                      input R-min-rest ,
                      input R-min-rest3,
                      input p-code     ,
                      input t-rv       ,
                      input t-rvz      ,
                      input t-rvc      ,
                      input t-rvzc  ,
                      input t-sp    ,
                      input t-sppv-2  ,
                      input t-sppv-2,
                      input t-sppv-3,
                      input t-sppv-4,
                      input t-way   ,
                      input t-rcv   ,
                      input t-clos  ,
                      input table tt-date ,
                      input table temp-abc-day-empty ,
                      input p-neg-sale    ,
                      input t-gar         ,
                      input t-min-zapas ,
                      input t-min-ost ,
                      input t-deadline ,
                      input store-type  ,
                      input store-code  ,
                      input g#type      ,
                      input no
                      ) no-error .
             end.
              if error-status :error then do:
                message  error-status :get-message(1) .
                error-status :error = false.
              end.
          end.
          else  do:
             if R-algoritm = 6  then do:
                run cus/qntysale.p
                  ( input parParentProc,
                    input v-round-m ,
                    input v-round-base ,
                    input e-method ,
                    input v-mode,
                    input loc-ord-num ,
                    input date-p-1,
                    input date-p-2,
                    input "calc":U,
                    input no,
                    input 2 ,
                    input R-algoritm2,
                    input R-min-rest,
                    input R-min-rest3,
                    input p-code,
                    input t-rv,
                    input t-rvz,
                    input t-rvc ,
                    input t-rvzc ,
                    input t-sp   ,
                    input t-sppv-2 ,
                    input t-sppv-2,
                    input t-sppv-3,
                    input t-sppv-4,
                    input t-way,
                    input t-rcv,
                    input t-clos,
                    input table tt-date ,
                    input table temp-abc-day ,
                    input p-neg-sale,
                    input t-gar,
                    input t-min-zapas ,
                    input t-min-ost ,
                    input t-deadline ,
                    input store-type  ,
                    input store-code  ,
                    input g#type      ,
                    input no
                    ) no-error .
             end.
             else do:
                run cus/qntysale.p
                  ( input parParentProc,
                    input v-round-m ,
                    input v-round-base ,
                    input e-method ,
                    input v-mode,
                    input loc-ord-num ,
                    input date-p-1,
                    input date-p-2,
                    input "calc":U,
                    input no,
                    input R-algoritm ,
                    input R-algoritm2,
                    input R-min-rest,
                    input R-min-rest3,
                    input p-code,
                    input t-rv,
                    input t-rvz,
                    input t-rvc ,
                    input t-rvzc ,
                    input t-sp   ,
                    input t-sppv-2 ,
                    input t-sppv-2,
                    input t-sppv-3,
                    input t-sppv-4,
                    input t-way,
                    input t-rcv,
                    input t-clos,
                    input table tt-date ,
                    input table temp-abc-day-empty ,
                    input p-neg-sale,
                    input t-gar,
                    input t-min-zapas ,
                    input t-min-ost ,
                    input t-deadline ,
                    input store-type  ,
                    input store-code  ,
                    input g#type      ,
                    input no
                    ) no-error .
             end.
              if error-status :error then do:
                message error-status :get-message(1) .
                error-status :error = false   .
              end.
          end.
          if  G#type <> 'ОО':U and
              G#type <> 'ОР':U
          then run calc-sum-vat in this-procedure .
          if v-mode = ? then do:
              for each tmp#zakaz:
                  find first shar_ord-line  exclusive-lock  where
                        shar_ord-line.doc-code  = loc-ord-num and
                        shar_ord-line.artic     = tmp#zakaz.artic and
                        shar_ord-line.prod-type = tmp#zakaz.prod-type and
                        shar_ord-line.prod-code = tmp#zakaz.prod-code no-error  .
                  if available shar_ord-line then do:
                    BUFFER-COPY tmp#zakaz  to  shar_ord-line .
                  end.
              end.
          end.
 end.
t-ret =  session:SET-WAIT-STATE("") .
END.
ON CHOOSE OF BUTTON-obj IN FRAME Dialog-Frame
DO:
  assign SelectObject.
  my-request = false .
  run select-objects-proc in this-procedure (input e-method).
END.
ON VALUE-CHANGED OF p-prt-art IN FRAME Dialog-Frame
DO:
assign
  p-prt-art
.
 v-show-all-goods = p-prt-art .
END.
ON VALUE-CHANGED OF R-algoritm IN FRAME Dialog-Frame
DO:
    run v-c-alg in this-procedure .
END.
ON VALUE-CHANGED OF R-algoritm2 IN FRAME Dialog-Frame
DO:
run v-c-2 in this-procedure .
END.
ON VALUE-CHANGED OF SelectObject IN FRAME Dialog-Frame
DO:
  Assign SelectObject.
run select-objects-proc in this-procedure (input e-method).
END.
ON VALUE-CHANGED OF t-rv IN FRAME Dialog-Frame
DO:
  DO:   assign frame Dialog-Frame   t-rv .   display t-rv  with FRAME Dialog-Frame  .  END.
END.
ON VALUE-CHANGED OF t-rvc IN FRAME Dialog-Frame
DO:
  DO:   assign frame Dialog-Frame   t-rvc .   display t-rvc  with FRAME Dialog-Frame  .  END.
END.
ON VALUE-CHANGED OF t-rvz IN FRAME Dialog-Frame
DO:
  DO:   assign frame Dialog-Frame   t-rvz .   display t-rvz  with FRAME Dialog-Frame  .  END.
END.
ON VALUE-CHANGED OF T-rvzc IN FRAME Dialog-Frame
DO:
  DO:   assign frame Dialog-Frame   T-rvzc .   display T-rvzc  with FRAME Dialog-Frame  .  END.
END.
ON VALUE-CHANGED OF T-sp IN FRAME Dialog-Frame
DO:
  DO:   assign frame Dialog-Frame   T-sp .   display T-sp  with FRAME Dialog-Frame  .  END.
END.
ON VALUE-CHANGED OF T-sppv-2 IN FRAME Dialog-Frame
DO:
  DO:   assign frame Dialog-Frame   T-sppv-2 .   display T-sppv-2  with FRAME Dialog-Frame  .  END.
END.
ON VALUE-CHANGED OF t-sppv-3 IN FRAME Dialog-Frame
DO:
  DO:   assign frame Dialog-Frame   t-sppv-3 .   display t-sppv-3  with FRAME Dialog-Frame  .  END.
END.
ON VALUE-CHANGED OF T-sppv-4 IN FRAME Dialog-Frame
DO:
  DO:   assign frame Dialog-Frame   T-sppv-4 .   display T-sppv-4  with FRAME Dialog-Frame  .  END.
END.
ON VALUE-CHANGED OF t-way IN FRAME Dialog-Frame
DO:
  run v-c-way in this-procedure .
END.
ON VALUE-CHANGED OF v-round-m IN FRAME Dialog-Frame
DO:
  ASSIGN v-round-m .
  if lookup ( v-round-m , 'Произвольно':U ) > 0 then do:
     enable  v-round-base with frame Dialog-Frame .
     display v-round-base with frame Dialog-Frame .
     end.
     else hide v-round-base in frame Dialog-Frame .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-obj-list :handle
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date19
    MENU-ITEM m-ed-date19-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date19-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date19-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date19-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-p-1 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date-p-1 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date19 :HANDLE
      date-p-1 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle19 as handle no-undo .
  assign
    v-label-handle19 = date-p-1 :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to date-p-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-2 in menu m-ed-date19 DO:
    apply "ctrl-d":U to date-p-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-3 in menu m-ed-date19 DO:
    apply "ctrl-e":U to date-p-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-4 in menu m-ed-date19 DO:
    apply "ctrl-f":U to date-p-1 in frame Dialog-Frame .
  END.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date21
    MENU-ITEM m-ed-date21-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date21-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date21-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date21-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-p-2 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date-p-2 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date21 :HANDLE
      date-p-2 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle21 as handle no-undo .
  assign
    v-label-handle21 = date-p-2 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle21)
  then do:
    if v-label-handle21 :tooltip = ""
    or v-label-handle21 :tooltip = ?
    then do:
      assign
        v-label-handle21 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date21-1 in menu m-ed-date21 DO:
    apply "ctrl-b":U to date-p-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-2 in menu m-ed-date21 DO:
    apply "ctrl-d":U to date-p-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-3 in menu m-ed-date21 DO:
    apply "ctrl-e":U to date-p-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-4 in menu m-ed-date21 DO:
    apply "ctrl-f":U to date-p-2 in frame Dialog-Frame .
  END.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ord-mm :
 do
 on error undo, return error return-value
 :
define variable loc-sum-min as decimal no-undo .
define variable t-type as character no-undo .
define variable v-grop-max-stock as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-obj-AssMin as logical   no-undo .
define variable v-obj-igt     as character no-undo .
define variable loc-host-code as integer   no-undo .
define variable loc-obj-type  as character no-undo .
define variable loc-obj-code  as integer   no-undo .
for each tmp#zakaz :
      assign
        loc-sum-min = 0
        tmp#zakaz.min-stock = 0
        tmp#zakaz.max-stock = 0
        tmp#zakaz.service-order = 0
        tmp#zakaz.min-order = 0
        .
        case R-min-rest :
        when 1   then do:
            for each obj-list :
                assign
                  loc-obj-type = obj-list.obj-type
                  loc-obj-code = obj-list.obj-code
                .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  loc-obj-type
  ,input  loc-obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  tmp#zakaz.gds-code
  ,output v-obj-AssMin
  ,output v-obj-igt
  ,output loc-sum-min
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
                if G#type = 'ФП':U or G#type = 'ОО':U then
                   tmp#zakaz.min-stock =  (if  loc-sum-min <> ? then  loc-sum-min else 0 ) .
                else tmp#zakaz.min-stock = tmp#zakaz.min-stock + (if  loc-sum-min <> ? then  loc-sum-min else 0 ) .
                if G#type = 'ФП':U or G#type = 'ОО':U then
                    tmp#zakaz.service-order = (if v-grop-level-always-presence <> ? then v-grop-level-always-presence else 0 ).
                else tmp#zakaz.service-order = tmp#zakaz.service-order + (if  v-grop-level-always-presence <> ? then  v-grop-level-always-presence else 0 ).
                if G#type = 'ФП':U or G#type = 'ОО':U then
                    tmp#zakaz.min-order = (if  v-grop-min-order <> ? then v-grop-min-order else 0 ).
                else tmp#zakaz.min-order = tmp#zakaz.min-order + (if v-grop-min-order <> ? then v-grop-min-order else 0 ).
                if G#type = 'ФП':U or G#type = 'ОО':U then
                     tmp#zakaz.max-stock =  (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .
                else tmp#zakaz.max-stock = tmp#zakaz.max-stock + (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .
            end.
          end.
        when 2  then do:
            for each obj-list :
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output loc-host-code
  )  .
                  assign
                  loc-obj-type = 'орг':U
                  loc-obj-code = loc-host-code
                .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  loc-obj-type
  ,input  loc-obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  tmp#zakaz.gds-code
  ,output v-obj-AssMin
  ,output v-obj-igt
  ,output loc-sum-min
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
                if G#type = 'ФП':U or G#type = 'ОО':U then
                   tmp#zakaz.min-stock =  (if  loc-sum-min <> ? then  loc-sum-min else 0 ) .
                else tmp#zakaz.min-stock = tmp#zakaz.min-stock + (if  loc-sum-min <> ? then  loc-sum-min else 0 ) .
                if G#type = 'ФП':U or G#type = 'ОО':U then
                    tmp#zakaz.service-order = (if v-grop-level-always-presence <> ? then v-grop-level-always-presence else 0 ).
                else tmp#zakaz.service-order = tmp#zakaz.service-order + (if  v-grop-level-always-presence <> ? then  v-grop-level-always-presence else 0 ).
                if G#type = 'ФП':U or G#type = 'ОО':U then
                    tmp#zakaz.min-order = (if  v-grop-min-order <> ? then v-grop-min-order else 0 ).
                else tmp#zakaz.min-order = tmp#zakaz.min-order + (if v-grop-min-order <> ? then v-grop-min-order else 0 ).
                if G#type = 'ФП':U or G#type = 'ОО':U then
                     tmp#zakaz.max-stock =  (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .
                else tmp#zakaz.max-stock = tmp#zakaz.max-stock + (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .
               leave.
            end.
          end.
    end case.
    if  r-min-rest3 then do:
      for each ub.season no-lock where
                  ub.season.sea-month-1 <= integer (DATE-sale-2) and
                  ub.season.sea-month-2 >= integer (DATE-sale-1):
        find first ub.season-attr where ub.season-attr.sea-code = ub.season.sea-code
          and ub.season-attr.db-num = ub.season.db-num
          and ub.season-attr.attr-code = 'sea-obj':U
          and ub.season-attr.attr-value = tmp#zakaz.obj-type + string (tmp#zakaz.obj-code) no-error.
                find first ub.gds-season no-lock where
                ub.gds-season.gds-code = tmp#zakaz.gds-code and
                ub.gds-season.sea-code = ub.season.sea-code and
                ub.gds-season.db-num   = ub.season.db-num
                no-error .
        if available ub.season-attr and available ub.gds-season
        then do:
          find first ub.gds-season-attr no-lock where ub.gds-season-attr.sea-code = ub.gds-season.sea-code
            and ub.gds-season-attr.db-num = ub.gds-season.db-num
            and ub.gds-season-attr.gds-code = ub.gds-season.gds-code
            and ub.gds-season-attr.attr-code = 'gdssea-season-coef':U
            no-error.
          if available ub.gds-season-attr then tmp#zakaz.season-coef = decimal (ub.gds-season-attr.attr-value).
          tmp#zakaz.min-stock = ub.gds-season.min-stock .
          leave.
        end.
        else do:
                if available ub.gds-season then do:
            find first ub.gds-season-attr no-lock where ub.gds-season-attr.sea-code = ub.gds-season.sea-code
              and ub.gds-season-attr.db-num = ub.gds-season.db-num
              and ub.gds-season-attr.gds-code = ub.gds-season.gds-code
              and ub.gds-season-attr.attr-code = 'gdssea-season-coef':U
              no-error.
            if available ub.gds-season-attr then tmp#zakaz.season-coef = decimal (ub.gds-season-attr.attr-value).
                  tmp#zakaz.min-stock = ub.gds-season.min-stock .
                end.
          end.
      end.
      if tmp#zakaz.season-coef = ? or tmp#zakaz.season-coef = 0 then assign tmp#zakaz.season-coef = 1.
    end.
end.
 end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-abc'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-abc
  ,output par-type
  ) no-error .
    if error-status :error then is-abc = "no" .
    run loc-enable-ui in this-procedure .
    v-round-m:list-items = 'Без-дробных,Произвольно,Отключено,Кол-во_в_коробке':U .
    if G#type = 'ОР':U then do:
    end.
    else do:
       pay-day = date-sale-2 - date-sale-1 + 1 .
    end.
    if pay-day = 0 or pay-day = ? then pay-day = 1 .
    g#log = SelectObject:disable( 'Из заказа' ) .
    SelectObject = SelectObject:screen-value in frame Dialog-Frame .
    run select-objects-proc in this-procedure  (input e-method).
    run loc-init in this-procedure .
    IF  v-mode <> ? then do:
      g#log = SelectObject:enable( 'Из заказа' ) .
      IF  v-mode = "all-ord":U THEN DO:
          assign frame Dialog-Frame:title = "Параметры для расчета заказа " + loc-ord-num + " /Расчет потребности/" .
          ENABLE b-save WITH FRAME Dialog-Frame.
          DISPLAY b-save WITH FRAME Dialog-Frame.
          HIDE btn_ok IN FRAME Dialog-Frame.
          HIDE i-exit IN FRAME Dialog-Frame.
      END.
      ELSE DO:
          assign frame Dialog-Frame:title = "Параметры для расчета заказа " + loc-ord-num + " /Экспорт/" .
      END.
    end.
    if date-sale-1 = ? and date-sale-2 = ? then do:
       t-way = false .
       hide t-way FILL-IN-8 T-clos T-rcv r-min-rest3 in frame Dialog-Frame .
    end.
  if is-abc <> "yes" then do:
     g#log = R-algoritm:disable(radio-label("6", R-algoritm:radio-buttons)).
   end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui in this-procedure .
PROCEDURE calc-sum-vat :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
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
for each  tmp#zakaz
    on error undo, return error :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   'zakaz':u
  ,input   loc-base-rate
  ,input   loc-base-scale
  ,input   loc-exch-rate
  ,input   loc-exch-scale
  ,input   vat_type
  ,input   slt_type
  ,input   tmp#zakaz.artic
  ,input   tmp#zakaz.prod-type
  ,input   tmp#zakaz.prod-code
  ,input   tmp#zakaz.price-cli
  ,input   tmp#zakaz.cli-base-rate
  ,input   tmp#zakaz.price-rubl
  ,input   tmp#zakaz.vat-pc
  ,input   tmp#zakaz.slt-pc
  ,input   tmp#zakaz.road-tax
  ,input   tmp#zakaz.transport-rubl
  ,input   tmp#zakaz.other-rubl
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
    if error-status:error then do:
      return error "Ошибка при пересчете НДС".
    end.
   assign
    tmp#zakaz.sum-vat    = varprice-vat-dt  * tmp#zakaz.cli-qnty
    tmp#zakaz.sum-slt    = varprice-slt-dt
    tmp#zakaz.road-tax   = if var-report-r-b = "rubl" then   varprice-road-tax-rubl-dt else varprice-road-tax-base-dt
    tmp#zakaz.other-base = varprice-other-exp-base-dt
    tmp#zakaz.other-rubl = varprice-other-exp-rubl-dt
    tmp#zakaz.price-rubl = varprice-rubl-dt
    tmp#zakaz.price-base = varprice-base-dt
    tmp#zakaz.price-cli  = varprice-cli-dt
     .
  end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tmp-sale NO-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY R-algoritm R-min-rest p-neg-sale T-gar r-min-rest3 T-min-ost
          T-min-zapas R-algoritm2 SelectObject T-DeadLine date-p-1 date-p-2
          t-way T-clos T-rcv t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2
          t-sppv-3 v-round-m v-round-base v-name p-prt-art FILL-IN-2 FILL-IN-17
          FILL-IN-3 t-gar-1 t-gar-2 t-min-ost-1 t-min-ost-2 FILL-IN-5 FILL-IN-15
          FILL-IN-13 FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4 t-5 t-6 t-7
          FILL-IN-16
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tmp-sale THEN
    DISPLAY tmp-sale.desc_ tmp-sale.tmp-code
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-3 RECT-5 RECT-6 RECT-7 RECT-8 R-algoritm R-min-rest
         p-neg-sale T-gar r-min-rest3 T-min-ost T-min-zapas R-algoritm2
         SelectObject BR-obj-list T-DeadLine BUTTON-obj date-p-1 date-p-2 t-way
         BROWSE-1 BROWSE-abc-day B-10 B-1 B-2 T-clos B-3 T-rcv t-rv t-rvc B-4
         t-rvz T-rvzc B-5 T-sppv-4 T-sp T-sppv-2 t-sppv-3 B-6 B-7 v-round-m
         v-round-base B-spis p-prt-art Btn_OK Btn_Cancel B-Help i-exit
         FILL-IN-17 FILL-IN-3 t-gar-1 t-gar-2 t-min-ost-1 t-min-ost-2 FILL-IN-5
         FILL-IN-15 FILL-IN-13 FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4
         t-5 t-6 t-7 FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-obj-list  FOR EACH obj-list .    OPEN QUERY browse-1 FOR EACH tt-date .    OPEN QUERY BROWSE-abc-day FOR EACH temp-abc-day .
END PROCEDURE.
PROCEDURE init-screen :
 do
 on error undo, return error return-value
 :
define input parameter p-val as character no-undo .
define variable i as integer no-undo .
  if g#type <> 'ФП':U then do:
      for each  obj-list : delete obj-list . end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input store-type ,
   input store-code )
   .
  end.
define variable v-nn as integer   no-undo .
  v-nn = num-entries(p-val) .
  do i = 1 to v-nn :
     case  entry(1,(entry(i,p-val)), "=" ) :
        when string( "v-round-m" )              then v-round-m =          entry(2,(entry(i,p-val)), "=" ).
        when string( "v-round-base" )           then v-round-base = decimal( entry(2,(entry(i,p-val)), "=" )).
        when string( "R-min-rest" )             then R-min-rest = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "R-algoritm" )             then R-algoritm = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "R-algoritm2" )            then R-algoritm2 = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "tmp-sale.tmp-code" )      then do:
             find first ub.tmp-sale no-lock where ub.tmp-sale.tmp-code = entry(2,(entry(i,p-val)), "=" ) no-error.
             if available ub.tmp-sale then do:
                rr = recid(ub.tmp-sale) .
                 display  ub.tmp-sale.tmp-code
                             ub.tmp-sale.desc_   with frame Dialog-Frame .
                 reposition Dialog-Frame to recid rr no-error  .
                 if error-status :error then error-status :get-message(1) .
             end.
             else do:
             find first ub.tmp-sale no-lock no-error .
                if available ub.tmp-sale then rr = recid(ub.tmp-sale) .
             end.
        end.
        when string( "SelectObject" ) then  do:
                SelectObject = string(entry(2,(entry(i,p-val)), "=" )) no-error .
                if error-status :error then SelectObject = "firm":U  .
                if SelectObject = "choice":U then SelectObject = "order":U .
                run select-objects-proc in this-procedure (input p-val).
             end.
        when string( "date-p-1" ) then  date-p-1 = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "date-p-2" ) then  date-p-2 = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "t-way"    )   then  t-way    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rcv"    )   then  t-rcv    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-clos"   )   then  t-clos    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rv"   )   then  t-rv    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rvz"  )   then  t-rvz   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rvc"  )   then  t-rvc   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-rvzc" )   then  t-rvzc  = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sp"   )   then  t-sp    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sppv-2")  then  t-sppv-2 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-sppv-3")  then  t-sppv-3 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sppv-4")  then  t-sppv-4 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "p-neg-sale")   then  p-neg-sale = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-gar")         then  t-gar = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-min-zapas") then  t-min-zapas = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-min-ost") then  t-min-ost = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-deadline") then  t-deadline = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "R-min-rest3")  then  R-min-rest3 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
    end case.
   g#log = SelectObject:disable(radio-label("all":U , SelectObject:radio-buttons)).
  end.
  if lookup ( v-round-m , 'Произвольно':U ) > 0 then do:
        enable  v-round-base with frame Dialog-Frame .
        display v-round-base with frame Dialog-Frame .
     end.
end.
END PROCEDURE.
PROCEDURE loc-enable-UI :
  OPEN QUERY Dialog-Frame FOR EACH tmp-sale NO-LOCK.
  GET FIRST Dialog-Frame.
  reposition Dialog-Frame to recid rr no-error  .
  find first ub.tmp-sale where rr = recid(ub.tmp-sale) no-lock no-error .
  DISPLAY R-algoritm R-min-rest p-neg-sale T-gar r-min-rest3 T-min-ost T-min-zapas R-algoritm2 SelectObject BR-obj-list T-DeadLine BUTTON-obj date-p-1 date-p-2 t-way BROWSE-1 B-10 B-1 B-2 T-clos B-3 T-rcv t-rv t-rvc B-4 t-rvz T-rvzc B-5 T-sppv-4 T-sp T-sppv-2 t-sppv-3 B-6 B-7 v-round-m p-prt-art Btn_OK Btn_Cancel B-Help i-exit FILL-IN-2 FILL-IN-17 FILL-IN-3 t-gar-1 t-gar-2 t-min-ost-1 t-min-ost-2 FILL-IN-5 FILL-IN-15 FILL-IN-13 FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4 t-5 t-6 t-7 FILL-IN-16
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.tmp-sale THEN do:
     DISPLAY  BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code    WITH FRAME Dialog-Frame.
     ENABLE  BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code  WITH FRAME Dialog-Frame.
     end.
  ENABLE RECT-1 RECT-3 RECT-5 RECT-6 RECT-7 RECT-8  R-algoritm R-min-rest p-neg-sale T-gar r-min-rest3 T-min-ost T-min-zapas R-algoritm2 SelectObject BR-obj-list T-DeadLine BUTTON-obj date-p-1 date-p-2 t-way BROWSE-1 B-10 B-1 B-2 T-clos B-3 T-rcv t-rv t-rvc B-4 t-rvz T-rvzc B-5 T-sppv-4 T-sp T-sppv-2 t-sppv-3 B-6 B-7 v-round-m p-prt-art Btn_OK Btn_Cancel B-Help i-exit FILL-IN-2 FILL-IN-17 FILL-IN-3 t-gar-1 t-gar-2 t-min-ost-1 t-min-ost-2 FILL-IN-5 FILL-IN-15 FILL-IN-13 FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4 t-5 t-6 t-7 FILL-IN-16
         WITH FRAME Dialog-Frame.
.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-obj-list  FOR EACH obj-list .    OPEN QUERY browse-1 FOR EACH tt-date .    OPEN QUERY BROWSE-abc-day FOR EACH temp-abc-day .
END PROCEDURE.
PROCEDURE loc-init :
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output to-day
  )  .
define variable i as integer no-undo .
if v-mode = ? then  do:
find first buf_usr-flt  no-lock where
         buf_usr-flt.user-name = loc-ord-num and
         buf_usr-flt.call-point   = "ord-m":U    no-error .
end.
else do:
   if v-mode = "all-ord":U then do:
        find first buf_usr-flt  no-lock where
                buf_usr-flt.user-name   = g#userid and
                buf_usr-flt.call-point  = "all-ord":U    no-error .
   end.
   else do:
          find first buf_usr-flt  no-lock where
                buf_usr-flt.user-name = loc-ord-num and
                buf_usr-flt.call-point   = "ord-m":U  + v-mode   no-error .
                if not available buf_usr-flt  then do:
                  find first buf_usr-flt  no-lock where
                          buf_usr-flt.user-name = loc-ord-num and
                          buf_usr-flt.call-point   = "ord-m":U  no-error .
                end.
   end.
end.
if not available buf_usr-flt  then do:
   find first buf_usr-flt  no-lock where
         buf_usr-flt.user-name    = g#userid and
         buf_usr-flt.call-point   = "ord-m":U    no-error .
end.
if available buf_usr-flt  then do:
  run init-screen ( buf_usr-flt.list_ ) .
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
  if v-round-m = "" or v-round-m = ? then v-round-m = 'Отключено':U .
  display v-round-m with frame Dialog-Frame .
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
    if available ub.tmp-sale then  rr = recid(ub.tmp-sale) .
end.
 display R-algoritm R-min-rest p-neg-sale T-gar r-min-rest3 T-min-ost T-min-zapas R-algoritm2 SelectObject BR-obj-list T-DeadLine BUTTON-obj date-p-1 date-p-2 t-way BROWSE-1 B-10 B-1 B-2 T-clos B-3 T-rcv t-rv t-rvc B-4 t-rvz T-rvzc B-5 T-sppv-4 T-sp T-sppv-2 t-sppv-3 B-6 B-7 v-round-m p-prt-art Btn_OK Btn_Cancel B-Help i-exit FILL-IN-2 FILL-IN-17 FILL-IN-3 t-gar-1 t-gar-2 t-min-ost-1 t-min-ost-2 FILL-IN-5 FILL-IN-15 FILL-IN-13 FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4 t-5 t-6 t-7 FILL-IN-16 with frame Dialog-Frame.
  if g#type = 'ФП':U then do:
        ENABLE
          SelectObject
          br-obj-list
          BUTTON-obj
          FILL-IN-13
          rect-7
          WITH FRAME Dialog-Frame.
  end.
  else do:
      hide  SelectObject  br-obj-list  BUTTON-obj  FILL-IN-13 rect-7            in frame Dialog-Frame .
      for each obj-list
          on error undo, return error :
          delete obj-list.
      end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input store-type ,
   input store-code )
   .
  end.
define variable v-value  as character no-undo .
define variable v-i      as integer   no-undo .
define variable v-dec as integer   no-undo .
define variable p-prop-code as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date    like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer like ub.thbj-attr.property-value-integer no-undo .
define variable v-type     as character no-undo .
define variable v-found as decimal no-undo .
 empty TEMP-TABLE  thbjattr_thbj-attr .
 empty TEMP-TABLE temp-abc-day .
 repeat v-i = 1 to 6:
    run adm/shattri.p (
      input "get":U
      ,input store-type
      ,input store-code
      ,input 'abc-sale-day':U
      ,input  chr ( 64 + v-i )
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
        v-dec = v-value-integer no-error .
        if v-dec = ? then v-dec = 0 .
        create temp-abc-day.
        assign
          temp-abc-day.abc-type = chr ( 64 + v-i )
          temp-abc-day.gar-day  = v-dec
        .
 end.
 run v-c-alg in this-procedure .
 run v-c-way in this-procedure .
END PROCEDURE.
PROCEDURE p-calc :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input-output parameter n-day as logical no-undo .
define input parameter n-i as integer no-undo .
define variable t-i as date no-undo.
define variable p-modulo as integer no-undo .
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
            if p-modulo = n-i
            then do:
                if not can-find ( first tt-date where tt-date.exch-date =  t-i ) then do:
                    create tt-date.
                    assign tt-date.exch-date =  t-i.
                    end.
            end.
         end.
  end.
   OPEN QUERY browse-1 FOR EACH tt-date .
  end.
 end.
END PROCEDURE.
PROCEDURE remember-screen :
 do
 on error undo, return error return-value
 :
define input-output parameter p-val as character no-undo .
         p-val =
            string( "v-round-m=" )  + string( v-round-m ) + "," +
            string( "v-round-base=" )  + string( v-round-base,">>>>>>>>>9.99" ) + "," +
            string( "R-algoritm=" )  + string( R-algoritm ) + "," +
            string( "R-algoritm2=" ) + string( R-algoritm2 ) + "," +
            string( "tmp-sale.tmp-code=" ) + (
            if available ub.tmp-sale and R-algoritm = 2
                  then   string( ub.tmp-sale.tmp-code )
                              else ( " " ) )                          + "," +
            string( "R-min-rest3=" ) + string( R-min-rest3,"yes/no" ) + "," +
            string( "R-min-rest=" )  + string( R-min-rest ) + "," +
            ( if date-p-1 = ?  then ""
                               else string( "date-p-1=" )    + string( date-p-1,"99/99/9999" )
                               )
                             + "," +
            ( if date-p-2 = ?  then ""
                               else string( "date-p-2=" )    + string( date-p-2,"99/99/9999" )
                               )
                             + "," +
            string( "t-way="    )    + string( t-way   ,"yes/no" ) + "," +
            string( "t-rcv="    )    + string( t-rcv   ,"yes/no" ) + "," +
            string( "t-clos="   )    + string( t-clos  ,"yes/no" ) + "," +
            string( "t-rv="     )    + string( t-rv    ,"yes/no" ) + "," +
            string( "t-rvz="    )    + string( t-rvz   ,"yes/no" ) + "," +
            string( "t-rvc="    )    + string( t-rvc   ,"yes/no" ) + "," +
            string( "t-rvzc="   )    + string( t-rvzc  ,"yes/no" ) + "," +
            string( "t-sp="     )    + string( t-sp    ,"yes/no" ) + "," +
            string( "t-sppv-2=" )    + string( t-sppv-2,"yes/no" ) + "," +
            string( "t-sppv-3=" )    + string( t-sppv-3,"yes/no" ) + "," +
            string( "t-sppv-4=" )    + string( t-sppv-4,"yes/no" ) + "," +
            string( "p-neg-sale=" )  + string( p-neg-sale,"yes/no" ) + "," +
            string( "t-gar=" )       + string( t-gar,"yes/no" ) + "," +
            string( "t-min-zapas=" ) + string( t-min-zapas,"yes/no" ) + "," +
            string( "t-min-ost=" ) + string( t-min-ost,"yes/no" ) + "," +
            string( "t-deadline=" ) + string( t-deadline,"yes/no" ) + "," +
            string( "SelectObject=" ) + string( SelectObject )
            .
  if g#type <> 'ФП':U then do:
      for each  obj-list : delete obj-list . end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input store-type ,
   input store-code )
   .
  end.
  p-val = p-val +  "," + "Объекты :&"  .
      for each obj-list :
              p-val = p-val +  obj-list.obj-type + " " + string(obj-list.obj-code) + ","    .
      end.
  end.
END PROCEDURE.
PROCEDURE select-objects-proc :
 do
 on error undo, return error return-value
 :
  define input parameter p-e-m as character no-undo .
  my-handle = parparentproc .
  define variable v-all-object as logical   no-undo .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-exist in this-procedure
  (output v-object-exist
  )  .
  if not params-only and v-object-exist = false then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define variable v-nn as integer   no-undo .
    str-pos = index (  p-e-m , "&" ) .
    str-pos2 = LENGTH ( p-e-m ) - str-pos .
    str-1 = substring (p-e-m , str-pos + 1 , str-pos2 ).
    v-nn = num-entries (str-1) .
    do i = 1 to v-nn :
        assign
          e1 = entry(1, (entry( i , str-1, "," )) , " ")
          e2 = integer(entry(2, (entry( i , str-1, "," )), " " ))
          no-error .
          if error-status :error then next.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input e1 ,
   input e2 )
   .
    end.
end.
OPEN QUERY br-obj-list  FOR EACH obj-list .
  end.
END PROCEDURE.
PROCEDURE sss :
  do
  on error undo, return error return-value
  :
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END PROCEDURE.
PROCEDURE v-c-2 :
  assign frame   Dialog-Frame   r-algoritm2.
  case  r-algoritm2:
  when 1 then do:
         enable  RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14      with frame Dialog-Frame .
         disable BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7    with frame Dialog-Frame .
         hide    BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7    in   frame Dialog-Frame .
         browse-1:bgcolor      in   frame Dialog-Frame  = 8 .
  end.
  when 2 then do:
        enable  RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14    with frame Dialog-Frame .
        disable BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  with frame Dialog-Frame .
        hide    BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  in   frame Dialog-Frame .
        browse-1:bgcolor    in   frame Dialog-Frame  = 8 .
  end.
  when 3 then do:
        enable   RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14  BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7   with frame Dialog-Frame .
        browse-1:bgcolor  in frame Dialog-Frame  = ? .
   end.
   otherwise do:
      message "Нет!!! " .
   end.
  end case.
END PROCEDURE.
PROCEDURE v-c-alg :
 do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
 define variable g#log  as logical   no-undo .
  assign frame   Dialog-Frame   r-algoritm.
  g#log = R-algoritm2:enable(radio-label("2", R-algoritm2:radio-buttons)) .
  case  r-algoritm:
  when 1 then do:
         enable  RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14 p-neg-sale r-min-rest3 T-min-zapas FILL-IN-3 FILL-IN-5 FILL-IN-7 with frame Dialog-Frame .
         disable BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7 BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code  T-gar t-gar-1 t-gar-2 with frame Dialog-Frame .
         hide    BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7 BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code  T-gar t-gar-1 t-gar-2 in frame Dialog-Frame .
         g#log = R-min-rest:enable( 'На фирме' ) .
         browse-1:bgcolor  in frame Dialog-Frame  = 8 .
  end.
  when 2 then do:
        enable  BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code p-neg-sale r-min-rest3 T-min-zapas FILL-IN-3 FILL-IN-5 FILL-IN-7 with frame Dialog-Frame .
        disable RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14 BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  T-gar t-gar-1 t-gar-2  with frame Dialog-Frame .
        hide    RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14 BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  T-gar t-gar-1 t-gar-2 browse-abc-day  in frame Dialog-Frame .
        browse-1:bgcolor  in frame Dialog-Frame  = 8 .
        g#log = R-min-rest:enable( 'На фирме' ) .
  end.
  when 3 then do:
        enable   RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14  p-neg-sale r-min-rest3 T-min-zapas FILL-IN-3 FILL-IN-5 FILL-IN-7   T-gar t-gar-1 t-gar-2   with frame Dialog-Frame .
        disable  BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7 with frame Dialog-Frame .
        hide     BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7   in  frame Dialog-Frame .
        browse-1:bgcolor  in frame Dialog-Frame  = ? .
        g#log = R-min-rest:enable( 'На фирме' ) .
   end.
   when 4 then do:
        enable   RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14 p-neg-sale r-min-rest3 T-min-zapas FILL-IN-3 FILL-IN-5 FILL-IN-7   with frame Dialog-Frame .
        disable  BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7 T-gar t-gar-1 t-gar-2  with frame Dialog-Frame .
        hide     BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7 T-gar t-gar-1 t-gar-2  in frame Dialog-Frame .
        g#log = R-min-rest:enable( 'На фирме' ) .
        browse-1:bgcolor  in frame Dialog-Frame  = ? .
        g#log = R-algoritm2:disable(radio-label("2", R-algoritm2:radio-buttons)) .
   end.
   when 5 then do:
        R-min-rest = 1.
        r-min-rest3 = false .
        g#log = R-min-rest:disable( 'На фирме' ) .
        display R-min-rest r-min-rest3 with frame Dialog-Frame .
        disable RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14 BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7 T-gar t-gar-1 t-gar-2 r-min-rest3  with frame Dialog-Frame .
        hide    RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14 BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7 T-gar t-gar-1 t-gar-2 r-min-rest3  in frame Dialog-Frame .
        browse-1:bgcolor  in frame Dialog-Frame  = 8 .
   end.
      when 6 then do:
        enable  BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code p-neg-sale r-min-rest3 T-min-zapas FILL-IN-3 FILL-IN-5 FILL-IN-7 with frame Dialog-Frame .
        disable RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14 BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  T-gar t-gar-1 t-gar-2  with frame Dialog-Frame .
        hide    RECT-3 RECT-8 R-algoritm2 date-p-1 date-p-2 t-rv t-rvc t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14 BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 t-3 t-4 t-5 t-6 t-7  T-gar t-gar-1 t-gar-2  in frame Dialog-Frame .
        browse-1:bgcolor  in frame Dialog-Frame  = 8 .
        g#log = R-min-rest:enable( 'На фирме' ) .
            OPEN QUERY BROWSE-abc-day FOR EACH temp-abc-day .
  end.
   otherwise do:
      message "Нет!!! " .
   end.
  end case.
  if date-sale-1 = ? and date-sale-2 = ? then do:
      t-way = false .
      hide t-way FILL-IN-8 T-clos T-rcv r-min-rest3 in frame Dialog-Frame .
  end.
  if r-algoritm <>  2 and
     r-algoritm <>  5 and
     r-algoritm <>  6
     then do:
     run v-c-2 in this-procedure .
     end.
 end.
END PROCEDURE.
PROCEDURE v-c-way :
  assign frame   Dialog-Frame   t-way.
  if  t-way then do:
      if loc-doc-type = 'ОО':U then do:
         T-rcv:label = 'запрос':U      .
         hide T-clos  in frame Dialog-Frame .
      end.
      display T-clos when loc-doc-type <> 'ОО':U
              T-rcv
              FILL-IN-8  with frame Dialog-Frame .
      enable T-clos  when loc-doc-type <> 'ОО':U
             T-rcv
             FILL-IN-8 with frame Dialog-Frame .
      end.
  else do:
        disable T-clos T-rcv FILL-IN-8 with frame Dialog-Frame .
        hide T-clos T-rcv FILL-IN-8 in frame Dialog-Frame .
        end.
END PROCEDURE.
PROCEDURE verify-check :
END PROCEDURE.
