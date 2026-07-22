DEFINE INPUT  PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter par-tmp as recid no-undo.
define input  parameter par-ord as recid no-undo.
define input  parameter p-line-mode as character no-undo .
define output parameter stp-cycle as log no-undo.
define output parameter stp-exit  as log no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "корректировка строки заказа ОО".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable p-curr-code   as integer no-undo .
define variable p-curr-date   as date no-undo .
define variable p-exch-rate   as decimal no-undo .
define variable p-exch-scale  as decimal no-undo .
define variable p-curr-abbr   as character no-undo .
define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
DEFINE BUTTON b-exit-cycl AUTO-GO
     LABEL "Стоп&Цикл"
     SIZE 11 BY 1.
DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON b-save AUTO-GO
     LABEL "Со&хранить"
     SIZE 11 BY 1.
DEFINE VARIABLE scr-artic AS CHARACTER FORMAT "X(16)"
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 17 BY .67.
DEFINE VARIABLE scr-cli-qnty AS DECIMAL FORMAT ">,>>>,>>9.999" INITIAL 0
     LABEL "Количество"
      VIEW-AS TEXT
     SIZE 13 BY .67 TOOLTIP "В ед.изм.поставщика".
DEFINE VARIABLE scr-gds-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-price-base AS DECIMAL FORMAT ">,>>>,>>9.99" INITIAL 0
     LABEL "Цена (вал)"
     VIEW-AS FILL-IN
     SIZE 23.25 BY 1.
DEFINE VARIABLE scr-price-rubl AS DECIMAL FORMAT ">,>>>,>>9.99" INITIAL 0
     LABEL "Цена (abbr_rub)"
     VIEW-AS FILL-IN
     SIZE 23 BY 1.
DEFINE VARIABLE scr-prod-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Производитель"
      VIEW-AS TEXT
     SIZE 10 BY .67.
DEFINE VARIABLE scr-prod-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-prod-type AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4.88 BY .67.
DEFINE VARIABLE scr-qnty AS DECIMAL FORMAT ">,>>>,>>9.999" INITIAL 0
     LABEL "Количество"
     VIEW-AS FILL-IN
     SIZE 13 BY 1.
DEFINE VARIABLE scr-sum-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма в баз.вал."
      VIEW-AS TEXT
     SIZE 22 BY .67.
DEFINE VARIABLE scr-sum-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма в abbr_rub"
      VIEW-AS TEXT
     SIZE 22 BY .67.
DEFINE VARIABLE scr-unit-base AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE scr-unit-cli AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE scr-val AS CHARACTER FORMAT "XXX":U
      VIEW-AS TEXT
     SIZE 4.75 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-cli-base-rate AS DECIMAL FORMAT ">>,>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Коэффициент пересчета баз.ед.изм. в ед.изм.поставщика"
     FGCOLOR 1  NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      ub.ord-line SCROLLING.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-quit AT ROW 1 COL 12
     b-exit-cycl AT ROW 1 COL 22
     B-help AT ROW 1 COL 78.38
     scr-qnty AT ROW 5.38 COL 17.38 COLON-ALIGNED
     scr-price-rubl AT ROW 8 COL 17.5 COLON-ALIGNED
     scr-price-base AT ROW 9 COL 17.5 COLON-ALIGNED
     scr-artic AT ROW 2.79 COL 17.38 COLON-ALIGNED
     scr-gds-name AT ROW 2.79 COL 36 COLON-ALIGNED NO-LABEL
     scr-prod-code AT ROW 3.83 COL 17.38 COLON-ALIGNED
     scr-prod-type AT ROW 3.88 COL 29 COLON-ALIGNED NO-LABEL
     scr-prod-name AT ROW 3.92 COL 35.75 COLON-ALIGNED NO-LABEL
     scr-unit-base AT ROW 5.54 COL 30.75 COLON-ALIGNED NO-LABEL
     v-cli-base-rate AT ROW 5.75 COL 37.5 COLON-ALIGNED NO-LABEL
     scr-val AT ROW 6.42 COL 76.75 COLON-ALIGNED NO-LABEL
     scr-unit-cli AT ROW 6.63 COL 30.75 COLON-ALIGNED NO-LABEL
     scr-cli-qnty AT ROW 6.67 COL 17.38 COLON-ALIGNED
     scr-sum-rubl AT ROW 8 COL 64.5 COLON-ALIGNED
     scr-sum-base AT ROW 8.83 COL 64.5 COLON-ALIGNED
     SPACE(1.12) SKIP(6.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit-cycl IN FRAME Dialog-Frame
DO:
   assign
     stp-cycle  =  true
     stp-exit  =  false.
     .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
if p-line-mode = 'ПРОСМОТР':U then do:
    stp-cycle  =  false.
    stp-exit  =  true .
    return.
end.
define variable compare-log as logical no-undo .
if p-line-mode <> "ЦИКЛ":u   then do:
    if compare-log = false then do:
        message "Вы действительно хотите выйти без сохранения изменений ?" view-as alert-box question
                buttons yes-no   update jjj as logical .
                if jjj = true then
    end.
end.
    stp-cycle  =  false.
    stp-exit  =  true .
    return "error".
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
    stp-cycle  =  false.
    stp-exit   =  false.
    assign frame Dialog-Frame scr-qnty .
    if scr-price-rubl:SENSITIVE then  assign frame Dialog-Frame scr-price-rubl .
    if scr-price-base:SENSITIVE then  assign frame Dialog-Frame scr-price-base .
    assign
      shar_ord-line.qnty       = scr-qnty
      shar_ord-line.cli-qnty   = scr-qnty
      shar_ord-line.cli-base-rate   = 1
      shar_ord-line.price-rubl = scr-price-rubl
      shar_ord-line.price-base = scr-price-base
      shar_ord-line.price-cli  = shar_ord-line.price-rubl
      shar_ord-line.sum-rubl = shar_ord-line.price-rubl * shar_ord-line.qnty
      shar_ord-line.sum-base = shar_ord-line.price-base * shar_ord-line.qnty
      shar_ord-line.sum-cli  = shar_ord-line.price-cli  * shar_ord-line.qnty
    .
END.
ON LEAVE OF scr-price-base IN FRAME Dialog-Frame
DO:
if scr-price-base:modified = false then return .
 assign  frame Dialog-Frame scr-price-base .
    scr-price-rubl = scr-price-base * ( p-exch-rate  / p-exch-scale )     .
    scr-sum-rubl =  scr-price-rubl * scr-qnty .
    scr-sum-base =  scr-price-base  * scr-qnty .
    display scr-price-rubl  scr-sum-base scr-sum-rubl with frame Dialog-Frame .
END.
ON return OF scr-price-base IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-price-base:handle ) .
  return no-apply .
END.
ON LEAVE OF scr-price-rubl IN FRAME Dialog-Frame
DO:
   if scr-price-rubl:modified = false then return .
    assign  frame Dialog-Frame  scr-price-rubl.
    scr-price-base = scr-price-rubl / ( p-exch-rate  * p-exch-scale )     .
    scr-sum-rubl =  scr-price-rubl * scr-qnty .
    scr-sum-base =  scr-price-base  * scr-qnty .
    display scr-price-base  scr-sum-base scr-sum-rubl with frame Dialog-Frame .
END.
ON return OF scr-price-rubl IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-price-rubl:handle ) .
  return no-apply .
END.
ON LEAVE OF scr-qnty IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame scr-qnty .
 IF CAN-FIND ( FIRST ub.units WHERE ub.units.unit-name = scr-unit-base
                    and LOOKUP('шту':U, ub.units.type) > 0   AND
                       TRUNC(scr-qnty, 0)   <>    scr-qnty         )
   THEN DO:
      MESSAGE "Базовая единица товара " scr-unit-base " - штучная." skip
              "Кол-во  должно быть целым."
      VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      RETURN no-apply.
  END.
    scr-sum-rubl =  scr-price-rubl * scr-qnty .
    scr-sum-base =  scr-price-base * scr-qnty .
    scr-cli-qnty =  scr-qnty / v-cli-base-rate .
 IF CAN-FIND ( FIRST ub.units WHERE ub.units.unit-name = scr-unit-cli
                    and LOOKUP('шту':U, ub.units.type) > 0   AND
                       TRUNC(scr-cli-qnty, 0)   <>    scr-cli-qnty         )
   THEN DO:
      MESSAGE
              "Единица товара поставщика" scr-unit-cli " - штучная." skip
              "Получается не полная единица измерения поставщика !!!."
      view-as alert-box information
      title "внимание".
  END.
    display  scr-cli-qnty  scr-sum-base scr-sum-rubl with frame Dialog-Frame .
END.
ON return OF scr-qnty IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  scr-qnty:handle ) .
  return no-apply .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
assign
  scr-price-rubl :label = "Цена (руб)"
  scr-sum-rubl   :label = "Сумма в руб"
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  g#host-code
  ,output p-curr-code
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-curr-code
  ,input  p-curr-date
  ,output p-exch-rate
  ,output p-exch-scale
  ,output p-curr-abbr
  )  .
    run init-proc.
    if p-line-mode = 'ПРОСМОТР':U then run lkp-enable.
                               else RUN my-enable.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.ord-line SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY scr-qnty scr-price-rubl scr-price-base scr-artic scr-gds-name
          scr-prod-code scr-prod-type scr-prod-name scr-unit-base
          v-cli-base-rate scr-val scr-unit-cli scr-cli-qnty scr-sum-rubl
          scr-sum-base
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-quit b-exit-cycl B-help scr-qnty scr-price-rubl
         scr-price-base scr-artic scr-gds-name scr-prod-code scr-prod-type
         scr-prod-name scr-unit-base scr-val scr-unit-cli scr-cli-qnty
         scr-sum-rubl scr-sum-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  define buffer buf_goods for ub.goods.
  define buffer buf_clients for ub.clients.
  if p-line-mode = 'ПРОСМОТР':U then
     find first shar_ord-line no-lock where recid(shar_ord-line) = par-ord no-error .
  else
     find first shar_ord-line  exclusive-lock  where recid(shar_ord-line) = par-ord no-error .
          if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
                "Ошибка  " skip
                  "p-line-mode" p-line-mode    skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error
          .
          return error .
          end.
   ASSIGN frame Dialog-Frame:TITLE = "Строка заказа  № " + shar_ord-line.doc-code  + " - " + caps(p-line-mode).
  find first buf_goods no-lock  WHERE
            buf_goods.artic     = shar_ord-line.artic      and
            buf_goods.prod-code = shar_ord-line.prod-code  and
            buf_goods.prod-type = shar_ord-line.prod-type no-error .
          if error-status :error then do:
             return error .
          end.
  find first buf_clients no-lock  WHERE
            buf_clients.obj-code = shar_ord-line.prod-code  and
            buf_clients.obj-type = shar_ord-line.prod-type no-error .
          if error-status :error then do:
             return error .
          end.
       assign
          scr-qnty       = shar_ord-line.qnty
          scr-price-rubl = shar_ord-line.price-rubl
          scr-price-base = shar_ord-line.price-base
          scr-artic      = shar_ord-line.artic
          scr-gds-name   = buf_goods.gds-name
          scr-prod-code  = shar_ord-line.prod-code
          scr-prod-type  = shar_ord-line.prod-type
          scr-prod-name  = buf_clients.obj-name
          scr-unit-base  = buf_goods.unit-base
          scr-val        = p-curr-abbr
          scr-cli-qnty   = scr-qnty / buf_goods.cli-base-rate
          scr-unit-cli   = shar_ord-line.unit-cli
          scr-sum-rubl   = scr-qnty  *  scr-price-rubl
          scr-sum-base   = scr-qnty  *  scr-price-base
          v-cli-base-rate = buf_goods.cli-base-rate
       .
  end.
END PROCEDURE.
PROCEDURE lkp-enable :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  DISPLAY scr-qnty scr-price-rubl scr-price-base scr-artic scr-gds-name
          scr-prod-code scr-prod-type scr-prod-name scr-unit-base scr-val
          scr-cli-qnty scr-unit-cli scr-sum-rubl scr-sum-base v-cli-base-rate
      WITH FRAME Dialog-Frame.
  ENABLE b-quit
         B-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame .
  end.
END PROCEDURE.
PROCEDURE my-enable :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable p-r-b-abbr as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output p-r-b-abbr
  )  .
  DISPLAY scr-qnty scr-price-rubl scr-price-base scr-artic scr-gds-name
          scr-prod-code scr-prod-type scr-prod-name scr-unit-base scr-val
          scr-cli-qnty scr-unit-cli scr-sum-rubl scr-sum-base v-cli-base-rate
      WITH FRAME Dialog-Frame.
  ENABLE b-save
         b-quit
         b-exit-cycl   when p-line-mode = "ЦИКЛ":u
         B-help
         scr-qnty
         scr-price-rubl when p-r-b-abbr = 'rubl':U
         scr-price-base when p-r-b-abbr <> 'rubl':U
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-line-mode <> "ЦИКЛ":u  then hide b-exit-cycl in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame focus scr-qnty .
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
  if  scr-qnty       :handle = p-widget-handle then do:  if scr-price-rubl     :sensitive then do:       apply "entry":u to scr-price-rubl   .        return . end.
                                                         if scr-price-base     :sensitive then do:       apply "entry":u to scr-price-base   .        return . end.
                                                    end.
  if  scr-price-rubl :handle = p-widget-handle then do:  if B-save    :sensitive then do:       apply "entry":u to B-save    .        return . end. end.
  if  scr-price-base :handle = p-widget-handle then do:  if B-save    :sensitive then do:       apply "entry":u to B-save    .        return . end. end.
  end.
  end.
END PROCEDURE.
