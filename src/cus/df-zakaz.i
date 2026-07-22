/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Шареные переменные и таблицы для заказов

Автор: Чернова Светлана Александровна
Дата создания: 08/20/01
Author: Svetlana Chernova
Creation date: 08/20/01

*/

/*
 add-cli-qnty    это  (chr(int(X_ord-line.add-cli-qnty))      ABCDEF
,add-qnty
,cancel-cli-qnty
,cancel-qnty
,initial-cli-qnty
,initial-qnty     - рассчитано ОР или автоматически рассчитано ОП и ФП
,order-cli-qnty   - отправлено на подтверждение ОП кол-во edoc-nn
,ord-dec1         - отправлено на подтверждение ОП цена в ед пост. edoc-nn
,order-qnty       - заказано ОР  или автоматически рассчитано ОП и ФП
,receive-cli-qnty
,receive-qnty
,temp-rash
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&glob def-tt-zakaz define ~{&def-tt-option~} temp-table tmp#zakaz1 no-undo ~
like ub.ord-line ~
field sum       as decimal   ~
field all-day   as integer   ~
field qnty-sale as decimal   ~
field negative-rest as logical    ~
field gds-name  as character ~
field unit-base as character ~
field unit-type as character ~
field unit-cli-type as character ~
field min-order     as decimal   ~
field service-order as decimal ~
field local-mark    as character ~
field max-stock     as decimal   ~
field season-coef   as decimal   ~
field min-stock-old as decimal   ~
field gds-way       as decimal   ~
index pi is unique primary artic prod-type prod-code  ascending ~
index idx-ln line-num.

&glob def-tt-option {1} shared
{&def-tt-zakaz}

&glob def-tt-zakaz-prn define ~{&def-tt-option~} temp-table tmp#zakaz-prn1 no-undo ~
field artic         like ub.goods.artic      ~
field prod-type     like ub.goods.prod-type  ~
field prod-code     like ub.goods.prod-code  ~
field obj-type      like ub.clients.obj-type ~
field obj-code      like ub.clients.obj-code ~
field prt-code      as   integer    ~
field qnty-sale     as   decimal    ~
field qnty-ord      as   decimal    ~
index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.

&glob def-tt-option {1} shared
{&def-tt-zakaz-prn}

&glob def-tt-zakaz-dtl define ~{&def-tt-option~} temp-table tmp#zakaz-dtl1 no-undo ~
like ub.ord-dtl ~
field prt-name as character ~
index bi is unique primary artic prod-type prod-code node-code  ascending.

{&def-tt-zakaz-dtl}

define {1} shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define {1} shared buffer buf-goods   for ub.goods     .
define {1} shared buffer sb-cli-gds  for ub.cli-gds   .
define {1} shared buffer sb-gds-obj  for ub.gds-obj   .
define {1} shared buffer tmp#zakaz     for tmp#zakaz1.
define {1} shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define {1} shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define {1} shared  buffer shar_ord-doc  for ub.ord-doc .
define {1} shared  buffer shar_ord-line for ub.ord-line.
define {1} shared  buffer shar_ord-dtl  for ub.ord-dtl .

define {1} shared variable chexcelapplication      as com-handle no-undo .
define {1} shared variable chworkbook              as com-handle no-undo .
define {1} shared variable chworksheet             as com-handle no-undo .
define {1} shared variable chrange                 as com-handle no-undo .
define {1} shared variable chworksheet2            as com-handle no-undo .
define {1} shared variable chworksheet3            as com-handle no-undo .
define {1} shared variable accum-zakaz             as decimal no-undo .
define {1} shared variable accum-sum-zakaz         as decimal no-undo .
define {1} shared variable accum-count             as integer no-undo .
define {1} shared buffer buf-cli for ub.clients.

define {1} shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.

define {1} shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.

define {1} shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.


define  {1}  shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.

define  {1}  shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.

define  {1}  shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.

define  {1}  shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.


define  {1}  shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.


define  {1}  shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.

define  {1}  shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.

define  {1}  shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.

define  {1}  shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.

define  {1}  shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
/*
define  {1}  shared  variable loc-ship as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть доста&вки"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость доставки" no-undo.
*/

define  {1}  shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.

define {1}  shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.


define {1}  shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.

define {1}  shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.


define {1}  shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.

define {1} shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.


define  {1}  shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.

define {1} shared variable loc-status  as character  no-undo.


define {1} shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.

define {1} shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.


define {1} shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.



define {1} shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.

define {1} shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.

define {1} shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.


define {1} shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.

define {1} shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.


define {1} shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.


define {1} shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.

define {1} shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.

define {1} shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа({&abbr_rub}.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа({&abbr_rub})"
     fgcolor 4
     no-undo.


define {1} shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text /*fill-in*/
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.

define {1} shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.


define {1} shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.

define {1} shared var loc-print-rubl as logical no-undo .

define {1} shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        {&without-slt},
        {&no-slt},
        {&inc-slt}
     size 9.75 by 1
     no-undo.

define {1} shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        {&without-vat},
        {&no-vat},
        {&inc-vat}
     size 9.75 by 1
     no-undo.

define {1} shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define  {1}  shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.

define {1} shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define {1} shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define {1} shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define {1} shared  variable temp-e-method  as character no-undo .
define {1} shared  variable x-tog-artic as logical   no-undo .
define {1} shared  variable x-tog-grp    as logical   no-undo .

/* $Workfile$ e n d */