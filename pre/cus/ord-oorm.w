DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER X_doc-line FOR ub.doc-line.
DEFINE BUFFER X_gds-obj FOR ub.gds-obj.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER x_ord-chain FOR ub.ord-chain.
DEFINE BUFFER X_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER X_ord-line FOR ub.ord-line.
DEFINE BUFFER X_trn-doc FOR ub.trn-doc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Распределение ручное".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      vss-include-info8 skip
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
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info13, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info13, return-value, chr(10), error-status :get-message (1)).
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
define input        parameter parParentProc   as widget-handle no-undo.
define input-output parameter p-ord-doc-recid as recid no-undo .
define  shared variable br-handle as handle  no-undo .
define  shared buffer buf-oo_ord-doc for ub.ord-doc.
define buffer   buf_ord-doc for ub.ord-doc .
define buffer   buf_clients for ub.clients .
define variable loc-obj-code as integer no-undo .
define variable loc-obj-type as character no-undo .
define variable sort-column-name as character no-undo .
define variable  rid-list         as  char no-undo .
define variable r-gener as integer init 1  no-undo .
define variable v-poisk as character no-undo .
define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define variable var-zapros-qnty-all as decimal no-undo.
define variable var-zapros-qnty as decimal no-undo.
define variable  g-log  as logical no-undo .
define variable  par-ord-oobj as logical no-undo .
define variable  t-log-4 as logical no-undo init false .
define variable varpurch-code as integer no-undo.
define variable p-host-code     as integer no-undo .
define variable p-host-name as character no-undo .
define new shared variable  next-prev as logical   no-undo .
define variable gds-rec as recid no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#db-remote as logical   no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  g#db-remote   =(v-cntxt-db-num <> 0)
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output p-host-code
  ,output p-host-name
  )  .
FUNCTION f-zapr-qnty RETURNS decimal
  ( buffer buf_ord-line for ub.ord-line )  FORWARD.
FUNCTION mark-string RETURNS CHARACTER
(buffer fl for x_ord-line, input m as char) FORWARD.
DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 9 BY 1.
DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 8 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.
DEFINE BUTTON B-grp
     LABEL "&Группы"
     SIZE 8 BY 1 TOOLTIP "Отметить товары по группам".
DEFINE BUTTON B-hand
     LABEL "Генерация"
     SIZE 14 BY 1 TOOLTIP "Создать запросы".
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON B-lkp
     LABEL "Просмотр"
     SIZE 9 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить товары".
DEFINE VARIABLE FI-all-str AS CHARACTER FORMAT "X(16)":U INITIAL "на объект"
      VIEW-AS TEXT
     SIZE 8.38 BY .67
     FONT 4 NO-UNDO.
DEFINE VARIABLE FI-all-str-3 AS CHARACTER FORMAT "X(16)":U INITIAL "запрошено"
      VIEW-AS TEXT
     SIZE 8.13 BY .67
     FONT 4 NO-UNDO.
DEFINE VARIABLE FILL-IN-22 AS CHARACTER FORMAT "X(256)":U INITIAL "Товары заказа"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-23 AS CHARACTER FORMAT "X(256)":U INITIAL "Остатки по объектам"
      VIEW-AS TEXT
     SIZE 20 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-26 AS CHARACTER FORMAT "X(256)":U INITIAL "Запросы"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-27 AS CHARACTER FORMAT "X(256)":U INITIAL "Товары запроса"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE scr-all-qnty AS DECIMAL FORMAT ">>>>>>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 11.75 BY .67 TOOLTIP "Запрошено по запросам"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-main-num AS CHARACTER FORMAT "X(16)":U
     LABEL "По заказу и его щепкам"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Головной заказ и его щепки"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-obj AS CHARACTER FORMAT "X(9)":U
      VIEW-AS TEXT
     SIZE 8.38 BY .67
     FGCOLOR 4 FONT 4 NO-UNDO.
DEFINE VARIABLE scr-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Заказывает"
      VIEW-AS TEXT
     SIZE 24 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE src-ext-doc-type AS CHARACTER FORMAT "x(30)"
      VIEW-AS TEXT
     SIZE 33.75 BY .67
     FGCOLOR 4 FONT 4 NO-UNDO.
DEFINE VARIABLE src-gds-name AS CHARACTER FORMAT "x(40)"
      VIEW-AS TEXT
     SIZE 40 BY .67
     FGCOLOR 4 FONT 4 NO-UNDO.
DEFINE VARIABLE src-obj-list-name AS CHARACTER FORMAT "x(24)"
      VIEW-AS TEXT
     SIZE 24.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 26 BY .92
     BGCOLOR 4 .
DEFINE QUERY BR-gds-obj FOR
      X_gds-obj SCROLLING.
DEFINE QUERY BR-goods FOR
      X_ord-line,
      X_goods SCROLLING.
DEFINE QUERY BR-line-trn FOR
      X_doc-line,
      buf_goods SCROLLING.
DEFINE QUERY BR-obj-list FOR
      obj-list SCROLLING.
DEFINE QUERY BR-rcv FOR
      X_ord-doc-rcv,
      X_ord-chain,
      X_trn-doc SCROLLING.
DEFINE BROWSE BR-gds-obj
  QUERY BR-gds-obj DISPLAY
      SUBSTRING (X_gds-obj.obj-type,1,1) COLUMN-LABEL "T" FORMAT "x(1)"
      X_gds-obj.obj-code
      X_gds-obj.fact-qnty COLUMN-LABEL "Факт"         FORMAT "->>>>>>>>9.<<<"
      X_gds-obj.free-qnty COLUMN-LABEL "Свободно" FORMAT "->>>>>>>>9.<<<"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 34.25 BY 8.5.
DEFINE BROWSE BR-goods
  QUERY BR-goods NO-LOCK DISPLAY
      mark-string(buffer X_ord-line, rid-list)                  COLUMN-LABEL  '*' FORMAT "X(1)"
      X_ord-line.artic         COLUMN-LABEL  'Артикул' FORMAT "X(16)"
      X_goods.gds-name   COLUMN-LABEL  'Название'  FORMAT "X(18)"
      X_ord-line.qnty     COLUMN-LABEL  'Количество'  FORMAT ">>>>>>>9.<<<"
      f-zapr-qnty (buffer X_ord-line )    COLUMN-LABEL "Запрошено" FORMAT ">>>>>>>>.<<<"
  ENABLE
      X_ord-line.qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 59.75 BY 8.5.
DEFINE BROWSE BR-line-trn
  QUERY BR-line-trn NO-LOCK DISPLAY
      X_doc-line.artic
      buf_goods.gds-name FORMAT "X(20)"
      X_doc-line.fact-qnty FORMAT "->>>>>>>9.<<<" column-label "Количество"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.38 BY 7.67.
DEFINE BROWSE BR-obj-list
  QUERY BR-obj-list DISPLAY
      substring(obj-list.obj-type,1,1) format "x(1)"
      string(obj-list.obj-code)  Column-label "Объект" format "x(5)"
      string(obj-list.db-num)  Column-label "БД"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 10.38 BY 7.67 TOOLTIP "Выбор объекта; Поиск по номеру объекта, BACKSPACE - очистить поиск".
DEFINE BROWSE BR-rcv
  QUERY BR-rcv DISPLAY
      substring(X_ord-doc-rcv.cli-type,1,1) COLUMN-LABEL "Т" format "x(1)"
      X_ord-doc-rcv.cli-code COLUMN-LABEL "Объект" Format "99999"
      X_trn-doc.doc-code format "x(14)"
      substring(X_trn-doc.status_,1,4) + string(X_trn-doc.flag_ ,"+/-") COLUMN-LABEL "Статус" Format "x(6)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 33.5 BY 7.67.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11.13
     B-grp AT ROW 1 COL 14.25
     B-hand AT ROW 1 COL 22.25
     B-help AT ROW 1 COL 36.38
     BR-goods AT ROW 3.79 COL 1
     BR-gds-obj AT ROW 3.79 COL 61.13
     B-del AT ROW 14.13 COL 1
     B-lkp AT ROW 14.13 COL 9
     B-chg AT ROW 14.13 COL 18
     BR-rcv AT ROW 15.25 COL 1
     BR-line-trn AT ROW 15.25 COL 34.75
     BR-obj-list AT ROW 15.25 COL 85
     scr-obj-name AT ROW 1.21 COL 63.5 COLON-ALIGNED
     src-obj-list-name AT ROW 2.13 COL 89.88 RIGHT-ALIGNED NO-LABEL
     FILL-IN-22 AT ROW 3 COL 1.75 NO-LABEL
     FILL-IN-23 AT ROW 3 COL 61.38 NO-LABEL
     src-gds-name AT ROW 12.38 COL 1.38 NO-LABEL
     scr-main-num AT ROW 12.42 COL 79 COLON-ALIGNED
     FI-all-str AT ROW 13.17 COL 55.5 COLON-ALIGNED NO-LABEL
     scr-obj AT ROW 13.17 COL 64.13 COLON-ALIGNED NO-LABEL
     FI-all-str-3 AT ROW 13.17 COL 72.63 COLON-ALIGNED NO-LABEL
     scr-all-qnty AT ROW 13.17 COL 81.25 COLON-ALIGNED NO-LABEL
     FILL-IN-26 AT ROW 13.42 COL 1.75 NO-LABEL
     FILL-IN-27 AT ROW 13.79 COL 34.88 NO-LABEL
     src-ext-doc-type AT ROW 22.92 COL 1 NO-LABEL
     RECT-1 AT ROW 2 COL 65.5
     SPACE(5.62) SKIP(20.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Распределение заказа по запросам на объекты".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
   run exit-proc in this-procedure .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
   if available x_trn-doc and
                x_trn-doc.doc-type = 'при':U and
                x_trn-doc.status_  = 'запрос':U      then do:
        run gbl/calc-trn.p ( input parParentProc , input recid(x_trn-doc)).
        run cus/ord-outu.p ( input parParentProc , input recid(x_trn-doc)).
        OPEN QUERY BR-line-trn FOR EACH X_doc-line NO-LOCK where      X_doc-line.doc-code =X_trn-doc.doc-code ,        EACH buf_goods OF X_doc-line NO-LOCK.
        OPEN QUERY BR-goods FOR EACH X_ord-line       WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK,              EACH X_goods WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK.
  end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  run del-trn in this-procedure .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    next-prev = ?.
END.
ON CHOOSE OF B-grp IN FRAME Dialog-Frame
DO:
    message "Отметить товары по группам ?"
           view-as alert-box question
            buttons yes-no
           update g-log
           .
  if g-log = false then return.
   run grp-num in this-procedure .
   run OpenBr in this-procedure .
END.
ON CHOOSE OF B-hand IN FRAME Dialog-Frame
DO:
define variable g-ok as logical no-undo .
define variable v-rowid as integer no-undo .
  find current x_ord-line no-lock no-error .
  find current obj-list no-error .
  if error-status :error then do:
        message "Подтвердите Объект заказа !"
        view-as alert-box .
        return .
     end.
  if r-gener = 1 then do:
     if num-entries (rid-list) = 0 then do:
        message "Не отмечены товары в заказе !"
        view-as alert-box .
        return .
     end.
     if obj-list.obj-code = buf_ord-doc.obj-code and
        obj-list.obj-type = buf_ord-doc.obj-type then do:
        message "Нельзя перемещать на тот же объект "  obj-list.obj-name "!"
        view-as alert-box .
        return .
     end.
      message "Сформировать запрос на объект"  obj-list.obj-name " ? "
              view-as alert-box question
              buttons yes-no
              update g-ok
              .
  end.
  if g-ok = false then return.
  .
  run make-trn-doc in this-procedure .
  run OpenBr in this-procedure .
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
   if available x_trn-doc then
      run str/showdoc.p
          (input parparentproc
          ,input x_trn-doc.doc-code
          ,input ""
          ,input ""
          ,input 0
          ,input true
          ) .
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
        if available x_ord-line then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid18 as character no-undo .
define variable v-num-entry18 as integer   no-undo .
assign
  v-str-recid18 = trim( string( recid( x_ord-line ) , "->>>>>>>>>>>9":U ) )
  v-num-entry18 = lookup( v-str-recid18 , rid-list )
.
if v-num-entry18 > 0 then do:
  assign
    entry( v-num-entry18, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid18
  .
end.
        g-log = br-goods:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = br-goods:select-next-row ().
            apply "VALUE-CHANGED" to br-goods in frame Dialog-Frame.
        end.
    end.
    apply "entry" to br-goods in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF BR-gds-obj IN FRAME Dialog-Frame
DO:
run proc-gds-obj in this-procedure .
END.
ON VALUE-CHANGED OF BR-goods IN FRAME Dialog-Frame
DO:
src-gds-name = "" .
if available x_goods then do:
   src-gds-name = x_goods.gds-name .
   OPEN QUERY BR-gds-obj FOR EACH X_gds-obj NO-LOCK where x_gds-obj.artic = x_ord-line.artic and x_gds-obj.prod-code = x_ord-line.prod-code and x_gds-obj.prod-type = x_ord-line.prod-type and x_gds-obj.host-code = p-host-code and not ( x_gds-obj.fact-qnty = 0 and x_gds-obj.free-qnty = 0 )  .
   run proc-gds-obj in this-procedure .
end.
display src-gds-name  with frame Dialog-Frame.
END.
ON ANY-PRINTABLE OF BR-obj-list IN FRAME Dialog-Frame
DO:
  v-poisk = v-poisk + last-event:label.
  find first obj-list where string(obj-list.obj-code ) begins v-poisk  no-error .
  if available  obj-list then
     reposition BR-obj-list to recid recid(obj-list) no-error .
  apply "VALUE-CHANGED" TO BR-obj-list IN FRAME Dialog-Frame.
END.
ON BACKSPACE OF BR-obj-list IN FRAME Dialog-Frame
DO:
  v-poisk = "".
END.
ON VALUE-CHANGED OF BR-obj-list IN FRAME Dialog-Frame
DO:
  if available obj-list then do:
    src-obj-list-name = "у " + obj-list.obj-name.
    display src-obj-list-name with frame Dialog-Frame.
    run proc-gds-obj in this-procedure .
  end.
END.
ON VALUE-CHANGED OF BR-rcv IN FRAME Dialog-Frame
DO:
  OPEN QUERY BR-line-trn FOR EACH X_doc-line NO-LOCK where      X_doc-line.doc-code =X_trn-doc.doc-code ,        EACH buf_goods OF X_doc-line NO-LOCK.
if available x_trn-doc  then do:
   src-ext-doc-type = func-get-name-from-ext-type (x_trn-doc.ext-doc-type,no) .
end.
display src-ext-doc-type with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-gds-obj :handle
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  run init-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to BR-goods in frame Dialog-Frame.
  return no-apply.
end.
on end-error, stop of frame Dialog-Frame  do:
  apply "choose" to b-exit in frame Dialog-Frame .
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
X_ord-line.qnty:read-only in browse br-goods = true .
  run init-proc in this-procedure .
  run enable_UI in this-procedure .
  run openbr in this-procedure .
  wait-for go of frame Dialog-Frame.
End.
run disable_UI in this-procedure .
PROCEDURE del-trn :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define buffer x_ord-doc-line-rcv for ub.ord-line-rcv.
define variable varchip-code as integer no-undo.
    if available x_ord-doc-rcv then do:
       find current x_ord-doc-rcv exclusive-lock no-error.
            if avail x_ord-doc-rcv then do:
               for each ub.ord-chain no-lock where
                      ub.ord-chain.doc-code = x_ord-doc-rcv.rcv-code and
                      ub.ord-chain.doc-type = 'rcv'                  and
                      ub.ord-chain.rel-doc-type = 'trn'
                      :
                    find first x_trn-doc  no-lock  where
                          x_trn-doc.doc-code = ub.ord-chain.rel-doc-code no-error .
                      if available x_trn-doc then do:
                            if not ( x_trn-doc.status_ = 'запрос':U  and
                                    x_trn-doc.flag_   = false )  then do :
                                      message "Статус " x_trn-doc.status_   + string( x_trn-doc.flag_ , "+/-")  " удалять нельзя! "
                                              view-as alert-box error .
                                              return.
                            end.
                            message "Удалить накладную №"  x_trn-doc.doc-code "?" view-as alert-box
                                    question buttons yes-no title "Вопрос" update g-log.
                          if g-log then do:
                              run str/del-doc.p
                                  ( input  parParentProc,
                                    input  x_trn-doc.doc-code,
                                    input  v-cntxt-db-num,
                                    input  "del-doc.err",
                                    input  ?,
                                    input  ?,
                                    input  v-cntxt-userid,
                                    input  x_trn-doc.doc-code,
                                    input  ?,
                                    output varchip-code )
                                    .
                              if x_ord-doc-rcv.status_ <> 'новый':U then do :
                                  for each  x_ord-doc-line-rcv  exclusive-lock  where
                                            x_ord-doc-line-rcv.doc-code = x_ord-doc-rcv.doc-code and
                                            x_ord-doc-line-rcv.rcv-code = x_ord-doc-rcv.rcv-code
                                            on error undo, return error :
                                            delete x_ord-doc-line-rcv.
                                  end.
                                  assign
                                    x_ord-doc-rcv.status_ = 'факт':U
                                  .
                              end.
                              else do:
                                delete  x_ord-doc-rcv .
                              end.
                              run Openbr in this-procedure .
                          end.
                    end.
                 end.
              end.
              else do:
                message "Удалить запись ?" view-as alert-box
                      question buttons yes-no title "Вопрос" update g-log.
                      if g-log then
                        delete  x_ord-doc-rcv .
              end.
  end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY scr-obj-name src-obj-list-name FILL-IN-22 FILL-IN-23 src-gds-name
          scr-main-num FI-all-str scr-obj FI-all-str-3 scr-all-qnty FILL-IN-26
          FILL-IN-27 src-ext-doc-type
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-1 B-mark B-grp B-hand B-help BR-goods BR-gds-obj B-del
         B-lkp B-chg BR-rcv BR-line-trn BR-obj-list scr-obj-name
         src-obj-list-name FILL-IN-22 FILL-IN-23 src-gds-name scr-main-num
         FI-all-str scr-obj FI-all-str-3 scr-all-qnty FILL-IN-26 FILL-IN-27
         src-ext-doc-type
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-gds-obj FOR EACH X_gds-obj NO-LOCK where x_gds-obj.artic = x_ord-line.artic and x_gds-obj.prod-code = x_ord-line.prod-code and x_gds-obj.prod-type = x_ord-line.prod-type and x_gds-obj.host-code = p-host-code and not ( x_gds-obj.fact-qnty = 0 and x_gds-obj.free-qnty = 0 )  .    OPEN QUERY BR-goods FOR EACH X_ord-line       WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK,              EACH X_goods WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK.    OPEN QUERY BR-line-trn FOR EACH X_doc-line NO-LOCK where      X_doc-line.doc-code =X_trn-doc.doc-code ,        EACH buf_goods OF X_doc-line NO-LOCK.    OPEN QUERY BR-obj-list FOR EACH obj-list NO-LOCK WHERE BY obj-list.obj-code .    OPEN QUERY BR-rcv FOR EACH X_ord-doc-rcv NO-LOCK where X_ord-doc-rcv.doc-code = loc-ord-num ,        each X_ord-chain NO-LOCK where     x_ord-chain.doc-code = X_ord-doc-rcv.rcv-code and     x_ord-chain.doc-type = 'rcv'                  and     x_ord-chain.rel-doc-type = 'trn'    ,        each X_trn-doc NO-LOCK         where X_trn-doc.doc-code = x_ord-chain.rel-doc-code  .
END PROCEDURE.
PROCEDURE exit-proc :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable glob-gen as logical init false  no-undo .
define variable v-kk as integer no-undo .
define buffer buf_ver_ord-doc-rcv  for ub.ord-doc-rcv.
define buffer buf_ver_doc-line for ub.doc-line.
define buffer buf_ver_trn-doc  for ub.trn-doc.
define variable varchip-code as integer no-undo.
for each buf_ver_ord-doc-rcv no-lock where
         buf_ver_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
         on error undo, return error :
        v-kk = 0 .
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ver_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :
              for each buf_ver_doc-line no-lock where
                       buf_ver_doc-line.doc-code = ub.ord-chain.rel-doc-code
                       on error undo, return error :
                       v-kk = v-kk + 1 .
              end.
        end.
        if v-kk = 0 then do:
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ver_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :
           find first buf_ver_trn-doc no-lock where buf_ver_trn-doc.doc-code = ub.ord-chain.rel-doc-code no-error .
           if available buf_ver_trn-doc then
              run str/del-doc.p
                ( input  parParentProc,
                  input  buf_ver_trn-doc.doc-code,
                  input  v-cntxt-db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  v-cntxt-userid,
                  input  buf_ver_trn-doc.doc-code,
                  input  ?,
                  output varchip-code ) .
           find x_ord-doc-rcv  exclusive-lock where recid(x_ord-doc-rcv) = recid(buf_ver_ord-doc-rcv) no-error .
           if available x_ord-doc-rcv then
              delete x_ord-doc-rcv.
        end.
        end.
end.
if buf_ord-doc.status_ = 'запрос':U and buf_ord-doc.flag_ = false  then do:
    if can-find(first X_ord-doc-rcv no-lock where X_ord-doc-rcv.doc-code = buf_ord-doc.doc-code ) = true
      then glob-gen = true .
    if  glob-gen = true  then do:
      message "Закрываем заказ до статуса " + caps( 'запрос':U ) +  "+ ? " view-as alert-box question
            buttons yes-no title "" update t-log-4 .
            if t-log-4 = true then do:
              run cus/ordoocls.p
                ( input parParentProc ,
                  input recid(buf_ord-doc) ,
                  input true )
                   .
            end.
    end.
end.
  end.
END PROCEDURE.
PROCEDURE grp-num :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define variable v-grp-recid as character no-undo .
 define buffer buf_gds-grp for ub.gds-grp .
 define buffer buf_goods   for ub.goods .
 define buffer buf_ord-line for ub.ord-line.
 rid-list = "" .
 run ref/gds-grp.w ( parParentProc, "b-sel,b-mark", store-type, store-code, input-output v-grp-recid ).
 if num-entries( v-grp-recid ) = 0  then do :
    message "Ни чего не выбрано !"  view-as alert-box .
    return .
 end.
define variable v-ind as integer   no-undo .
define variable  Grp_Name as character no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries( v-grp-recid ) .
    repeat v-ind = 1 to v-nn
    :
      FIND buf_gds-grp no-lock  WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,v-grp-recid )) .
      run grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output Grp_Name ).
            for each buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num ,
                each buf_goods no-lock where buf_goods.artic = buf_ord-line.artic   and
                                    buf_goods.prod-code = buf_ord-line.prod-code   and
                                    buf_goods.prod-type = buf_ord-line.prod-type   and
                                    buf_goods.grp-name begins grp_name
                on error undo, return error :
                find first x_ord-line no-lock where
                      recid(x_ord-line) = recid(buf_ord-line) no-error .
                      if available  x_ord-line then
                          apply "CHOOSE" to b-mark in frame Dialog-Frame .
            end.
    end.
end.
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
  scr-obj-name     = buf_clients.obj-name
  loc-ord-num      = buf_ord-doc.doc-code
 .
     ASSIGN frame Dialog-Frame:TITLE = frame  Dialog-Frame:TITLE + " Заказ  № " + loc-ord-num  .
  for each obj-list   :
     delete obj-list .
  end.
  for each ub.shop where ub.shop.host-code   = p-host-code:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input 'маг':U ,
   input ub.shop.obj-code )
  no-error .
  end.
  for each ub.store where ub.store.host-code  = p-host-code:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input 'скл':U ,
   input ub.store.obj-code )
  no-error .
  end.
run main-ord (  input loc-ord-num  ,  output scr-main-num  ) .
define variable par-type     as char no-undo.
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'ord-global':U
  ,input 'ord-oobj':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-oobj
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then par-ord-oobj = false .
  end.
END PROCEDURE.
PROCEDURE main-ord :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter   p-in-ord-num as character no-undo .
define output parameter  p-out-ord-num as character no-undo .
if num-entries(p-in-ord-num , "." ) = 1 then
   p-out-ord-num = p-in-ord-num .
   else do:
     p-out-ord-num = entry(1, entry( 1 , p-in-ord-num , "." ) , "-" )  + "-" + entry( 2 , p-in-ord-num , "."  ) .
   end.
  end.
END PROCEDURE.
PROCEDURE make-rcv :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define output parameter  r-rec as recid no-undo.
define variable l-recid as recid no-undo.
define variable v-root-node as integer no-undo .
define variable ks          as  integer no-undo .
define variable loc-rcv-num as  character no-undo .
define variable ii          as  integer no-undo .
define buffer   b-goods     for ub.goods .
define buffer   bfp-ord-doc for ub.ord-doc .
define buffer   buf2-ord-line-rcv for ub.ord-line-rcv.
define buffer   buf2-ord-doc-rcv  for ub.ord-doc-rcv .
define buffer   buf2-doc-line     for ub.doc-line     .
define buffer   buf_gds-obj       for ub.gds-obj.
define variable last-all-rcv as decimal no-undo .
define buffer buf_ord-doc-rcv  for  ub.ord-doc-rcv.
define buffer buf_ord-line     for ub.ord-line.
define buffer buf_ord-line-rcv for ub.ord-line-rcv.
define buffer buf_ord-dtl-rcv  for ub.ord-dtl-rcv.
ks = 0.
define variable v-i-doc as character no-undo .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-rcv-num
 ) .
  find first bfp-ord-doc where bfp-ord-doc.doc-code = loc-ord-num no-lock no-error.
       if error-status :error  then return.
   if not( bfp-ord-doc.status_  = 'запрос':U and
           bfp-ord-doc.flag_    = false  )
   then do:
        message "Нелязя делать ЗАПРОС по   Заказу в статусе " caps(bfp-ord-doc.status_) string(bfp-ord-doc.flag_,"+/-") " !"
                 view-as alert-box information .
        return.
   end.
create buf_ord-doc-rcv.
buffer-copy bfp-ord-doc to buf_ord-doc-rcv
   assign
      buf_ord-doc-rcv.rcv-code  = loc-rcv-num
      buf_ord-doc-rcv.doc-type  = 'запрос':U
      buf_ord-doc-rcv.doc-date  = today
      buf_ord-doc-rcv.status_   = 'новый':U
      buf_ord-doc-rcv.cli-code = p-cli-code
      buf_ord-doc-rcv.cli-type = p-cli-type
   .
   for each buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num  and
       lookup( string( recid( buf_ord-line ) ) , rid-list ) > 0   :
        ks = ks + 1 .
        if not can-find  (first buf_ord-line-rcv where
          buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code and
          buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code and
          buf_ord-line-rcv.artic     = buf_ord-line.artic and
          buf_ord-line-rcv.prod-code = buf_ord-line.prod-code and
          buf_ord-line-rcv.prod-type = buf_ord-line.prod-type no-lock ) then do:
          last-all-rcv = 0 .
        for each buf2-ord-line-rcv where
          buf2-ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code and
          buf2-ord-line-rcv.artic     = buf_ord-line.artic and
          buf2-ord-line-rcv.prod-code = buf_ord-line.prod-code and
          buf2-ord-line-rcv.prod-type = buf_ord-line.prod-type no-lock ,
            first buf2-ord-doc-rcv no-lock where
                   buf2-ord-doc-rcv.rcv-code =  buf2-ord-line-rcv.rcv-code and
                   buf2-ord-doc-rcv.doc-code =  buf2-ord-line-rcv.doc-code    ,
           each ub.ord-chain no-lock where
                    ub.ord-chain.doc-code = buf2-ord-doc-rcv.rcv-code and
                    ub.ord-chain.doc-type = 'rcv'                  and
                    ub.ord-chain.rel-doc-type = 'trn' ,
            first buf2-doc-line no-lock where
                   buf2-doc-line.doc-code     =  ub.ord-chain.rel-doc-code  and
                   buf2-doc-line.artic        =  buf2-ord-line-rcv.artic    and
                   buf2-doc-line.prod-code    =  buf2-ord-line-rcv.prod-code and
                   buf2-doc-line.prod-type    =  buf2-ord-line-rcv.prod-type
             :
              last-all-rcv =  last-all-rcv + buf2-doc-line.fact-qnty .
        end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_ord-line.artic
  ,input  buf_ord-line.prod-type
  ,input  buf_ord-line.prod-code
  ,output v-root-node
  )  .
         create buf_ord-line-rcv.
         buffer-copy buf_ord-line to buf_ord-line-rcv
         assign
           buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code
           buf_ord-line-rcv.line-num  = ks
           buf_ord-line-rcv.qnty      = if (buf_ord-line.qnty - last-all-rcv) < 0 then 0
                                                                                  else  (buf_ord-line.qnty - last-all-rcv)
           buf_ord-line-rcv.cli-qnty  = buf_ord-line-rcv.qnty / buf_ord-line-rcv.cli-base-rate
         .
         if par-ord-oobj  = true then do :
              find first buf_gds-obj no-lock
                      where buf_gds-obj.artic     = buf_ord-line.artic and
                            buf_gds-obj.prod-code = buf_ord-line.prod-code and
                            buf_gds-obj.prod-type = buf_ord-line.prod-type and
                            buf_gds-obj.obj-code  = buf_ord-doc-rcv.cli-code and
                            buf_gds-obj.obj-type  = buf_ord-doc-rcv.cli-type and
                            buf_gds-obj.host-code = p-host-code no-error .
              if available buf_gds-obj and buf_gds-obj.free-qnty > 0 then do:
                  if buf_ord-line-rcv.qnty > buf_gds-obj.free-qnty then do:
                      assign
                        buf_ord-line-rcv.qnty = buf_gds-obj.free-qnty
                      .
                  end.
                  buf_ord-line-rcv.cli-qnty  = buf_ord-line-rcv.qnty / buf_ord-line-rcv.cli-base-rate    .
              end.
              else do:
                assign
                    buf_ord-line-rcv.qnty = 0
                    buf_ord-line-rcv.cli-qnty = 0
                .
              end.
         end.
         create buf_ord-dtl-rcv.
         buffer-copy buf_ord-line-rcv to buf_ord-dtl-rcv
            assign
              buf_ord-dtl-rcv.node-code = v-root-node
            .
            define variable l-terminal-prt as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  buf_ord-dtl-rcv.node-code
  ,input  'terminal-prt=request':u
  ,output l-terminal-prt
  )  .
         if not l-terminal-prt then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_ord-dtl-rcv.node-code
  ,output buf_ord-dtl-rcv.node-code
  )  .
         end.
         l-recid = recid(buf_ord-line-rcv).
         end.
end.
if ks > 0 then do:
    r-rec = recid(buf_ord-doc-rcv).
    run cus/ord-trnz.p (parParentProc ,
                    input r-rec ,
                    input 'при':U,
                    input "" ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
             "Ошибка ord-trnz.p " skip
              skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error
      .
      delete buf_ord-doc-rcv .
      return error .
    end.
   end.
 else do:
   find first buf_ord-doc-rcv where buf_ord-doc-rcv.rcv-code  = loc-ord-num  exclusive-lock  .
   delete buf_ord-doc-rcv .
   r-rec = ?.
end.
rid-list = "" .
end.
END PROCEDURE.
PROCEDURE make-rcv-avto :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  end.
END PROCEDURE.
PROCEDURE make-trn-doc :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable p-recid as recid no-undo .
run waitfram-show in this-procedure ("Формирование связки заказ - запрос....") .
if r-gener = 1 then do:
    run make-rcv in this-procedure (
      input obj-list.obj-type ,
      input obj-list.obj-code ,
      output p-recid )
      .
 end.
OPEN QUERY BR-rcv FOR EACH X_ord-doc-rcv NO-LOCK where X_ord-doc-rcv.doc-code = loc-ord-num ,        each X_ord-chain NO-LOCK where     x_ord-chain.doc-code = X_ord-doc-rcv.rcv-code and     x_ord-chain.doc-type = 'rcv'                  and     x_ord-chain.rel-doc-type = 'trn'    ,        each X_trn-doc NO-LOCK         where X_trn-doc.doc-code = x_ord-chain.rel-doc-code  .
  apply "VALUE-CHANGED" TO BR-rcv IN FRAME Dialog-Frame.
  apply "entry" TO BR-rcv IN FRAME Dialog-Frame.
OPEN QUERY BR-line-trn FOR EACH X_doc-line NO-LOCK where      X_doc-line.doc-code =X_trn-doc.doc-code ,        EACH buf_goods OF X_doc-line NO-LOCK.
run waitfram-hide in this-procedure .
  end.
END PROCEDURE.
PROCEDURE openbr :
  OPEN QUERY BR-gds-obj FOR EACH X_gds-obj NO-LOCK where x_gds-obj.artic = x_ord-line.artic and x_gds-obj.prod-code = x_ord-line.prod-code and x_gds-obj.prod-type = x_ord-line.prod-type and x_gds-obj.host-code = p-host-code and not ( x_gds-obj.fact-qnty = 0 and x_gds-obj.free-qnty = 0 )  .    OPEN QUERY BR-goods FOR EACH X_ord-line       WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK,              EACH X_goods WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK.    OPEN QUERY BR-line-trn FOR EACH X_doc-line NO-LOCK where      X_doc-line.doc-code =X_trn-doc.doc-code ,        EACH buf_goods OF X_doc-line NO-LOCK.    OPEN QUERY BR-obj-list FOR EACH obj-list NO-LOCK WHERE BY obj-list.obj-code .    OPEN QUERY BR-rcv FOR EACH X_ord-doc-rcv NO-LOCK where X_ord-doc-rcv.doc-code = loc-ord-num ,        each X_ord-chain NO-LOCK where     x_ord-chain.doc-code = X_ord-doc-rcv.rcv-code and     x_ord-chain.doc-type = 'rcv'                  and     x_ord-chain.rel-doc-type = 'trn'    ,        each X_trn-doc NO-LOCK         where X_trn-doc.doc-code = x_ord-chain.rel-doc-code  .
  apply "VALUE-CHANGED" TO BR-goods IN FRAME Dialog-Frame.
  apply "VALUE-CHANGED" TO BR-gds-obj IN FRAME Dialog-Frame.
  apply "VALUE-CHANGED" TO BR-rcv IN FRAME Dialog-Frame.
  apply "VALUE-CHANGED" TO BR-obj-list IN FRAME Dialog-Frame.
  apply "entry" TO BR-gds-obj IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-gds-obj :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define buffer buf_all-ord-doc for ub.ord-doc .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv for ub.ord-line-rcv .
define buffer buf_doc-line          for ub.doc-line .
define buffer buf_trn-doc for ub.trn-doc.
define variable temp-number as character no-undo .
define variable v-doc-rec as recid no-undo .
scr-obj = "" .
 if not available x_gds-obj then return.
   find current obj-list no-error .
   if available  obj-list then do:
      v-doc-rec = recid(obj-list) .
      reposition br-obj-list to recid v-doc-rec no-error .
      apply "value-changed" to br-obj-list in frame Dialog-Frame .
      apply "entry" to br-obj-list in frame Dialog-Frame    .
      scr-obj = obj-list.obj-type + " " + string(obj-list.obj-code) .
      scr-all-qnty = 0.
          for each buf_all-ord-doc no-lock
              where buf_all-ord-doc.doc-code begins entry( 1 , loc-ord-num , "-" ) and
                    buf_all-ord-doc.obj-type =  store-type and
                    buf_all-ord-doc.obj-code =  store-code
              on error undo, return error :
                run main-ord in this-procedure (  input buf_all-ord-doc.doc-code  ,  output  temp-number ) .
                if temp-number <> scr-main-num then next .
                for each buf_ord-line-rcv no-lock
                    where buf_ord-line-rcv.doc-code  = buf_all-ord-doc.doc-code  and
                          buf_ord-line-rcv.artic     = x_gds-obj.artic     and
                          buf_ord-line-rcv.prod-type = x_gds-obj.prod-type and
                          buf_ord-line-rcv.prod-code = x_gds-obj.prod-code
                          on error undo, return error :
                          find first buf_ord-doc-rcv no-lock where
                                    buf_ord-doc-rcv.rcv-code  = buf_ord-line-rcv.rcv-code  and
                                    buf_ord-doc-rcv.doc-code  = buf_ord-line-rcv.doc-code  no-error .
                                    if error-status :error then return error .
                          for each ub.ord-chain no-lock where
                                    ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                                    ub.ord-chain.doc-type = 'rcv'                  and
                                    ub.ord-chain.rel-doc-type = 'trn'
                                    :
                                  find first buf_trn-doc no-lock where
                                          buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code  and
                                          buf_trn-doc.doc-type = 'при':U           and
                                          buf_trn-doc.cli-type =  x_gds-obj.obj-type and
                                          buf_trn-doc.cli-code =  x_gds-obj.obj-code no-error .
                                if not available buf_trn-doc then next.
                                find first buf_doc-line no-lock where
                                          buf_doc-line.doc-code  = buf_trn-doc.doc-code  and
                                          buf_doc-line.artic     = buf_ord-line-rcv.artic     and
                                          buf_doc-line.prod-type = buf_ord-line-rcv.prod-type and
                                          buf_doc-line.prod-code = buf_ord-line-rcv.prod-code
                                          no-error .
                                if available buf_doc-line then do:
                                  scr-all-qnty  = scr-all-qnty  + buf_doc-line.fact-qnty .
                                end.
                          end.
                end.
          end.
   end.
display scR-obj scr-all-qnty  with frame Dialog-Frame.
  end.
END PROCEDURE.
FUNCTION f-zapr-qnty RETURNS decimal
  ( buffer buf_ord-line for ub.ord-line ) :
define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv for ub.ord-line-rcv .
define buffer buf_doc-line     for ub.doc-line .
define buffer buf_trn-doc      for ub.trn-doc  .
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
                    if error-status :error then next.
          for each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn'
                   :
          find first buf_trn-doc no-lock  where
                     buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code  and
                     buf_trn-doc.doc-type = 'при':U and
                     buf_trn-doc.status_  = 'запрос':U
                     no-error .
          if not available buf_trn-doc then next .
          find first buf_doc-line no-lock where
                     buf_doc-line.doc-code = ub.ord-chain.rel-doc-code  and
                     buf_doc-line.artic     = buf_ord-line.artic       and
                     buf_doc-line.prod-type = buf_ord-line.prod-type   and
                     buf_doc-line.prod-code = buf_ord-line.prod-code   no-error .
                     if error-status :error then next .
          res  = res  + buf_doc-line.fact-qnty .
         end.
end.
  RETURN res .
END FUNCTION.
FUNCTION mark-string RETURNS CHARACTER
(buffer fl for x_ord-line, input m as char):
if lookup(string(recid(fl)),m) > 0 then return chr(42).
else return chr(32).
END FUNCTION.
