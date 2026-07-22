&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр удаленных документов

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as   widget-handle         no-undo.
define input parameter pardoc-code   like ub.c-trn-doc.doc-code no-undo.
define input parameter parchip-num   like ub.c-trn-doc.chip-num no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр удаленных документов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable  varr-b as character no-undo.

{ gbl/curr-r-b.i varr-b }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-doc-line

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES c-doc-line goods c-gds-dtl gds-prt bar-code ~
c-parts ub.c-trn-doc ub.currency

/* Definitions for BROWSE b-doc-line                                    */
&Scoped-define FIELDS-IN-QUERY-b-doc-line c-doc-line.artic goods.gds-name c-doc-line.doc-qnty c-doc-line.fact-qnty goods.unit-base c-doc-line.cli-qnty c-doc-line.unit-cli c-doc-line.price-base sum-base (buffer c-doc-line) c-doc-line.price-rubl sum-rubl (buffer c-doc-line) c-doc-line.price-cli sum-cli (buffer c-doc-line) c-doc-line.vat-pc ub.c-doc-line.cons-vat-pc c-doc-line.slt-pc c-doc-line.road-tax c-doc-line.excise c-doc-line.transport-base c-doc-line.transport-rubl c-doc-line.other-base c-doc-line.other-rubl ub.c-doc-line.doc-density ub.c-doc-line.fact-density ub.c-doc-line.temperature ub.c-doc-line.num-place ub.c-doc-line.wt-brutto
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-doc-line
&Scoped-define SELF-NAME b-doc-line
&Scoped-define QUERY-STRING-b-doc-line FOR EACH c-doc-line where c-doc-line.doc-code = pardoc-code and c-doc-line.chip-num = parchip-num NO-LOCK, ~
       first goods where goods.artic = c-doc-line.artic and goods.prod-type = c-doc-line.prod-type and goods.prod-code = c-doc-line.prod-code no-lock
&Scoped-define OPEN-QUERY-b-doc-line OPEN QUERY {&SELF-NAME} FOR EACH c-doc-line where c-doc-line.doc-code = pardoc-code and c-doc-line.chip-num = parchip-num NO-LOCK, ~
       first goods where goods.artic = c-doc-line.artic and goods.prod-type = c-doc-line.prod-type and goods.prod-code = c-doc-line.prod-code no-lock.
&Scoped-define TABLES-IN-QUERY-b-doc-line c-doc-line goods
&Scoped-define FIRST-TABLE-IN-QUERY-b-doc-line c-doc-line
&Scoped-define SECOND-TABLE-IN-QUERY-b-doc-line goods


/* Definitions for BROWSE b-gds-dtl                                     */
&Scoped-define FIELDS-IN-QUERY-b-gds-dtl bar-code.b-code c-gds-dtl.doc-qnty c-gds-dtl.fact-qnty c-gds-dtl.price-base sum-sale-base (buffer c-gds-dtl) sum-dsc-base (buffer c-gds-dtl) itogo-base (buffer c-gds-dtl) c-gds-dtl.discnt-pc sum-sale-rubl (buffer c-gds-dtl) sum-dsc-rubl (buffer c-gds-dtl) itogo-rubl (buffer c-gds-dtl) priznak (buffer gds-prt, buffer goods)
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-gds-dtl
&Scoped-define SELF-NAME b-gds-dtl
&Scoped-define QUERY-STRING-b-gds-dtl FOR EACH c-gds-dtl where c-gds-dtl.doc-code = c-doc-line.doc-code and c-gds-dtl.chip-num = c-doc-line.chip-num and c-gds-dtl.artic        = c-doc-line.artic        and c-gds-dtl.prod-type = c-doc-line.prod-type and c-gds-dtl.prod-code = c-doc-line.prod-code NO-LOCK , ~
       first gds-prt where gds-prt.node-code = c-gds-dtl.prt-code no-lock, ~
       first bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = ub.c-gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock
&Scoped-define OPEN-QUERY-b-gds-dtl OPEN QUERY {&SELF-NAME} FOR EACH c-gds-dtl where c-gds-dtl.doc-code = c-doc-line.doc-code and c-gds-dtl.chip-num = c-doc-line.chip-num and c-gds-dtl.artic        = c-doc-line.artic        and c-gds-dtl.prod-type = c-doc-line.prod-type and c-gds-dtl.prod-code = c-doc-line.prod-code NO-LOCK , ~
       first gds-prt where gds-prt.node-code = c-gds-dtl.prt-code no-lock, ~
       first bar-code where bar-code.gds-code = goods.gds-code                           and bar-code.node-code = ub.c-gds-dtl.prt-code                           and bar-code.part-code = ''                           and bar-code.in-code = ''                           and bar-code.unit-cli = goods.unit-base no-lock.
&Scoped-define TABLES-IN-QUERY-b-gds-dtl c-gds-dtl gds-prt bar-code
&Scoped-define FIRST-TABLE-IN-QUERY-b-gds-dtl c-gds-dtl
&Scoped-define SECOND-TABLE-IN-QUERY-b-gds-dtl gds-prt
&Scoped-define THIRD-TABLE-IN-QUERY-b-gds-dtl bar-code


/* Definitions for BROWSE b-parts                                       */
&Scoped-define FIELDS-IN-QUERY-b-parts ub.c-parts.in-code ub.c-parts.part-code ub.c-parts.supp-type ub.c-parts.supp-code ub.c-parts.qnty ub.c-parts.fact-qnty ub.c-parts.cli-qnty ub.c-parts.price-base ub.c-parts.price-rubl ub.c-parts.price-cli ub.c-parts.VAT-pc ub.c-parts.SLT-pc ub.c-parts.road-tax-base ub.c-parts.road-tax-rubl ub.c-parts.transport-base ub.c-parts.transport-rubl ub.c-parts.other-base ub.c-parts.other-rubl ub.c-parts.cst-code ub.c-parts.pay-code name-purch-code (buffer ub.c-parts)
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-parts
&Scoped-define SELF-NAME b-parts
&Scoped-define QUERY-STRING-b-parts FOR EACH c-parts where c-parts.obj-type = c-doc-line.obj-type   AND c-parts.obj-code = c-doc-line.obj-code   AND c-parts.out-code = c-doc-line.doc-code   and c-parts.chip-num = c-doc-line.chip-num   AND c-parts.artic = c-doc-line.artic   AND c-parts.prod-type = c-doc-line.prod-type   AND c-parts.prod-code = c-doc-line.prod-code NO-LOCK
&Scoped-define OPEN-QUERY-b-parts OPEN QUERY {&SELF-NAME} FOR EACH c-parts where c-parts.obj-type = c-doc-line.obj-type   AND c-parts.obj-code = c-doc-line.obj-code   AND c-parts.out-code = c-doc-line.doc-code   and c-parts.chip-num = c-doc-line.chip-num   AND c-parts.artic = c-doc-line.artic   AND c-parts.prod-type = c-doc-line.prod-type   AND c-parts.prod-code = c-doc-line.prod-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-b-parts c-parts
&Scoped-define FIRST-TABLE-IN-QUERY-b-parts c-parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ub.c-trn-doc.cli-code ~
ub.c-trn-doc.cli-type ub.c-trn-doc.cli-name ub.currency.curr-abbr ~
ub.c-trn-doc.exch-code ub.c-trn-doc.VAT-base ub.c-trn-doc.VAT-rubl ~
ub.c-trn-doc.exch-rate ub.c-trn-doc.exch-scale ub.c-trn-doc.d-card ~
ub.c-trn-doc.doc-qnty ub.c-trn-doc.discnt-type ub.c-trn-doc.discnt-pc ~
ub.c-trn-doc.fact-qnty
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-doc-line}~
    ~{&OPEN-QUERY-b-gds-dtl}~
    ~{&OPEN-QUERY-b-parts}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.c-trn-doc ~
      WHERE c-trn-doc.doc-code = pardoc-code ~
 AND c-trn-doc.chip-num = parchip-num SHARE-LOCK, ~
      EACH ub.currency WHERE currency.curr-code = c-trn-doc.exch-code SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.c-trn-doc ~
      WHERE c-trn-doc.doc-code = pardoc-code ~
 AND c-trn-doc.chip-num = parchip-num SHARE-LOCK, ~
      EACH ub.currency WHERE currency.curr-code = c-trn-doc.exch-code SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.c-trn-doc ub.currency
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.c-trn-doc
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame ub.currency


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-doc-line b-gds-dtl b-parts ~
b-suppcnt  b-Petrol b-Lines
&Scoped-Define DISPLAYED-FIELDS ub.c-trn-doc.cli-code ub.c-trn-doc.cli-type ~
ub.c-trn-doc.cli-name ub.currency.curr-abbr ub.c-trn-doc.exch-code ~
ub.c-trn-doc.VAT-base ub.c-trn-doc.VAT-rubl ub.c-trn-doc.exch-rate ~
ub.c-trn-doc.exch-scale ub.c-trn-doc.d-card ub.c-trn-doc.doc-qnty ~
ub.c-trn-doc.discnt-type ub.c-trn-doc.discnt-pc ub.c-trn-doc.fact-qnty
&Scoped-define DISPLAYED-TABLES ub.c-trn-doc ub.currency
&Scoped-define FIRST-DISPLAYED-TABLE ub.c-trn-doc
&Scoped-define SECOND-DISPLAYED-TABLE ub.currency
&Scoped-Define DISPLAYED-OBJECTS varfact-sum vardiscnt

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD itogo-base Dialog-Frame
FUNCTION itogo-base RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD itogo-rubl Dialog-Frame
FUNCTION itogo-rubl RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD name-purch-code Dialog-Frame
FUNCTION name-purch-code RETURNS CHARACTER
  ( buffer local-c-parts for c-parts )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD priznak Dialog-Frame
FUNCTION priznak RETURNS character
  ( buffer local-gds-prt for gds-prt,
    buffer local-goods   for goods )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sum-base Dialog-Frame
FUNCTION sum-base RETURNS DECIMAL
  ( buffer  local-c-doc-line for c-doc-line)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sum-cli Dialog-Frame
FUNCTION sum-cli RETURNS DECIMAL
 ( buffer  local-c-doc-line for c-doc-line)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sum-dsc-base Dialog-Frame
FUNCTION sum-dsc-base RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sum-dsc-rubl Dialog-Frame
FUNCTION sum-dsc-rubl RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sum-rubl Dialog-Frame
FUNCTION sum-rubl RETURNS DECIMAL
 ( buffer  local-c-doc-line for c-doc-line)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sum-sale-base Dialog-Frame
FUNCTION sum-sale-base RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sum-sale-rubl Dialog-Frame
FUNCTION sum-sale-rubl RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-Lines
     LABEL "&Строки"
     SIZE 10 BY 1.

DEFINE BUTTON b-Petrol
     LABEL "&Топливо"
     SIZE 10 BY 1.

DEFINE BUTTON b-suppcnt
     LABEL "&ДогП"
     SIZE 10 BY 1.

DEFINE VARIABLE vardiscnt AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Скидка"
     VIEW-AS FILL-IN NATIVE
     SIZE 23.88 BY .88.

DEFINE VARIABLE varfact-sum AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "К оплате"
     VIEW-AS FILL-IN NATIVE
     SIZE 23.63 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-doc-line FOR
      c-doc-line,
      goods SCROLLING.

DEFINE QUERY b-gds-dtl FOR
      c-gds-dtl,
      gds-prt,
      bar-code SCROLLING.

DEFINE QUERY b-parts FOR
      c-parts SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      ub.c-trn-doc,
      ub.currency SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-doc-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-doc-line Dialog-Frame _FREEFORM
  QUERY b-doc-line DISPLAY
      c-doc-line.artic column-label "Артикул"
goods.gds-name format "x(30)" column-label "Имя"
c-doc-line.doc-qnty column-label "Док. кол-во"
c-doc-line.fact-qnty column-label "Факт кол-во"
goods.unit-base column-label "Изм"
c-doc-line.cli-qnty column-label "Кол-во пост"
c-doc-line.unit-cli column-label "Изм"
c-doc-line.price-base column-label "Уч цена(вал)"
sum-base (buffer c-doc-line) column-label "Сумма уч (вал)" format "->>>>>>>>>>>>>9.99"
c-doc-line.price-rubl column-label "Уч цена({&abbr_rub})"
sum-rubl (buffer c-doc-line) column-label "Сумма уч ({&abbr_rub})" format "->>>>>>>>>>>>>9.99"
c-doc-line.price-cli column-label "Цена пост"
sum-cli (buffer c-doc-line) column-label "Сумма пост" format "->>>>>>>>>>>>>9.99"
c-doc-line.vat-pc column-label "НДС"
ub.c-doc-line.cons-vat-pc column-label "Конс. НДС"
c-doc-line.slt-pc column-label "НП"
c-doc-line.road-tax column-label "Доп. компонента"
c-doc-line.excise column-label "Акциз"
c-doc-line.transport-base column-label "Трансп. расходы (вал)"
c-doc-line.transport-rubl column-label "Трансп. расходы ({&abbr_rub})"
c-doc-line.other-base column-label "Прочие расходы (вал)"
c-doc-line.other-rubl column-label "Прочие расходы ({&abbr_rub})"
ub.c-doc-line.doc-density column-label "Плотность док"
ub.c-doc-line.fact-density column-label "Плотность факт"
ub.c-doc-line.temperature column-label "Температура"
ub.c-doc-line.num-place column-label "Кол-во мест"
ub.c-doc-line.wt-brutto column-label "Вес брутто"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.38 BY 5
         TITLE "Строки документа".

DEFINE BROWSE b-gds-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-gds-dtl Dialog-Frame _FREEFORM
  QUERY b-gds-dtl DISPLAY
      bar-code.b-code column-label "Бар-код"
c-gds-dtl.doc-qnty column-label "Док кол-во"
c-gds-dtl.fact-qnty column-label "Факт кол-во"
c-gds-dtl.price-base column-label "Цена (вал)"
sum-sale-base (buffer c-gds-dtl) column-label "Сумма (вал)"
sum-dsc-base (buffer c-gds-dtl) column-label "Скидка (вал)"
itogo-base (buffer c-gds-dtl) column-label "Итого (вал)"
c-gds-dtl.discnt-pc column-label "Скидка (%)"
sum-sale-rubl (buffer c-gds-dtl) column-label "Сумма ({&abbr_rub})"
sum-dsc-rubl (buffer c-gds-dtl) column-label "Скидка ({&abbr_rub})"
itogo-rubl (buffer c-gds-dtl) column-label "Итого ({&abbr_rub})"
priznak  (buffer gds-prt, buffer goods) column-label "Признак"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.38 BY 5
         TITLE "Продажные цены (признаки)".

DEFINE BROWSE b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-parts Dialog-Frame _FREEFORM
  QUERY b-parts DISPLAY
      ub.c-parts.in-code column-label "Документ"
ub.c-parts.part-code column-label "Код партии"
ub.c-parts.supp-type column-label "Поставщик"
ub.c-parts.supp-code column-label ""
ub.c-parts.qnty column-label "Док кол-во"
ub.c-parts.fact-qnty column-label "Факт кол-во"
ub.c-parts.cli-qnty column-label "Кол-во пост"
ub.c-parts.price-base column-label "Цена (вал)"
ub.c-parts.price-rubl column-label "Цена ({&abbr_rub})"
ub.c-parts.price-cli column-label "Цена пост"
ub.c-parts.VAT-pc column-label "НДС"
ub.c-parts.SLT-pc column-label "НП"
ub.c-parts.road-tax-base column-label "Доп. комп. (вал)"
ub.c-parts.road-tax-rubl column-label "Доп. комп. ({&abbr_rub})"
ub.c-parts.transport-base column-label "Транспортные расходы (вал)"
ub.c-parts.transport-rubl column-label "Транспортные расходы ({&abbr_rub})"
ub.c-parts.other-base column-label "Прочие расходы (вал)"
ub.c-parts.other-rubl column-label "Прочие расходы ({&abbr_rub})"
ub.c-parts.cst-code column-label "ГТД" FORMAT "X(31)"
ub.c-parts.pay-code column-label "Код оплаты"
name-purch-code (buffer ub.c-parts) column-label "Код приобретения"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.38 BY 5
         TITLE "Учетные цены (партии)".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 1.5
     b-help AT ROW 1.17 COL 11.63
     ub.c-trn-doc.cli-code AT ROW 1.17 COL 32.38 COLON-ALIGNED
          LABEL "Поставщик"
          VIEW-AS FILL-IN NATIVE
          SIZE 14 BY 1
     ub.c-trn-doc.cli-type AT ROW 1.17 COL 47.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 5 BY 1
     ub.c-trn-doc.cli-name AT ROW 1.21 COL 52.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 30 BY 1
     varfact-sum AT ROW 2.38 COL 38.63 COLON-ALIGNED
     ub.currency.curr-abbr AT ROW 2.42 COL 5.13 COLON-ALIGNED
          LABEL "Вал"
          VIEW-AS FILL-IN NATIVE
          SIZE 4 BY 1
     ub.c-trn-doc.exch-code AT ROW 2.42 COL 9.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 3 BY 1
     ub.c-trn-doc.VAT-base AT ROW 2.42 COL 72.63 COLON-ALIGNED
          LABEL "НДС(вал)"
          VIEW-AS FILL-IN NATIVE
          SIZE 23 BY 1
     ub.c-trn-doc.VAT-rubl AT ROW 3.63 COL 73 COLON-ALIGNED
          LABEL "НДС"
          VIEW-AS FILL-IN NATIVE
          SIZE 22.75 BY 1
     ub.c-trn-doc.exch-rate AT ROW 3.67 COL 1.5
          LABEL "Курс"
          VIEW-AS FILL-IN NATIVE
          SIZE 11 BY 1
     ub.c-trn-doc.exch-scale AT ROW 3.67 COL 16.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 4 BY 1
     vardiscnt AT ROW 3.75 COL 38.5 COLON-ALIGNED
     ub.c-trn-doc.d-card AT ROW 4.75 COL 18.25 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE
          SIZE 17.5 BY 1
     ub.c-trn-doc.doc-qnty AT ROW 4.79 COL 71.88 COLON-ALIGNED
          LABEL "Количество по документу"
          VIEW-AS FILL-IN NATIVE
          SIZE 23.75 BY 1
     ub.c-trn-doc.discnt-type AT ROW 5.79 COL 8.13 COLON-ALIGNED
          VIEW-AS FILL-IN NATIVE
          SIZE 16.63 BY 1
     ub.c-trn-doc.discnt-pc AT ROW 5.83 COL 25.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     ub.c-trn-doc.fact-qnty AT ROW 5.92 COL 72 COLON-ALIGNED
          LABEL "Фактическое количество"
          VIEW-AS FILL-IN NATIVE
          SIZE 23.5 BY 1
     b-doc-line AT ROW 6.92 COL 1.25
     b-gds-dtl AT ROW 12 COL 1
     b-parts AT ROW 17 COL 1
     b-suppcnt AT ROW 22.25 COL 1
     b-Petrol AT ROW 22.25 COL 31.13
     b-Lines AT ROW 22.25 COL 41.13
     SPACE(48.11) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB b-doc-line fact-qnty Dialog-Frame */
/* BROWSE-TAB b-gds-dtl b-doc-line Dialog-Frame */
/* BROWSE-TAB b-parts b-gds-dtl Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ub.c-trn-doc.cli-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.cli-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.cli-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.currency.curr-abbr IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.d-card IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.discnt-pc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.discnt-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.doc-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.exch-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.exch-rate IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.exch-scale IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.fact-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN vardiscnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varfact-sum IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.VAT-base IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.c-trn-doc.VAT-rubl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-doc-line
/* Query rebuild information for BROWSE b-doc-line
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH c-doc-line where c-doc-line.doc-code = pardoc-code and c-doc-line.chip-num = parchip-num NO-LOCK,
first goods where goods.artic = c-doc-line.artic and goods.prod-type = c-doc-line.prod-type and goods.prod-code = c-doc-line.prod-code no-lock.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-doc-line */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-gds-dtl
/* Query rebuild information for BROWSE b-gds-dtl
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH c-gds-dtl where c-gds-dtl.doc-code = c-doc-line.doc-code and
c-gds-dtl.chip-num = c-doc-line.chip-num and
c-gds-dtl.artic        = c-doc-line.artic        and
c-gds-dtl.prod-type = c-doc-line.prod-type and
c-gds-dtl.prod-code = c-doc-line.prod-code NO-LOCK
,
first gds-prt where gds-prt.node-code = c-gds-dtl.prt-code no-lock,
first bar-code where bar-code.gds-code = goods.gds-code
                          and bar-code.node-code = ub.c-gds-dtl.prt-code
                          and bar-code.part-code = ''
                          and bar-code.in-code = ''
                          and bar-code.unit-cli = goods.unit-base no-lock.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-gds-dtl */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-parts
/* Query rebuild information for BROWSE b-parts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH c-parts where c-parts.obj-type = c-doc-line.obj-type
  AND c-parts.obj-code = c-doc-line.obj-code
  AND c-parts.out-code = c-doc-line.doc-code
  and c-parts.chip-num = c-doc-line.chip-num
  AND c-parts.artic = c-doc-line.artic
  AND c-parts.prod-type = c-doc-line.prod-type
  AND c-parts.prod-code = c-doc-line.prod-code NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-parts */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.c-trn-doc,ub.currency WHERE ub.c-trn-doc ..."
     _Options          = "SHARE-LOCK"
     _Where[1]         = "c-trn-doc.doc-code = pardoc-code
 AND c-trn-doc.chip-num = parchip-num"
     _JoinCode[2]      = "currency.curr-code = c-trn-doc.exch-code"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-doc-line
&Scoped-define SELF-NAME b-doc-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc-line Dialog-Frame
ON VALUE-CHANGED OF b-doc-line IN FRAME Dialog-Frame /* Строки документа */
DO:
  {&OPEN-QUERY-b-gds-dtl}
  {&OPEN-QUERY-b-parts}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Lines Dialog-Frame
ON CHOOSE OF b-Lines IN FRAME Dialog-Frame /* Строки */
DO:
  define variable v-list as character no-undo.

  run str/docclins.w ( input        ParParentProc,
                   input        '*':U,
                   input        'doc':U,
                   input        ?,
                   input        ?,
                   input        c-trn-doc.doc-code,
                   input        ?,
                   input        ?,
                   input        ?,
                   input-output v-list              ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Petrol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Petrol Dialog-Frame
ON CHOOSE OF b-Petrol IN FRAME Dialog-Frame /* Топливо */
DO:
  define variable v-list as character no-undo.

  run str/invcline.w ( input        ParParentProc,
                   input        '':U,
                   input        'doc':U,
                   input        ?,
                   input        ?,
                   input        c-trn-doc.doc-code,
                   input        ?,
                   input        ?,
                   input        ?,
                   input-output v-list              ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-suppcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-suppcnt Dialog-Frame
ON CHOOSE OF b-suppcnt IN FRAME Dialog-Frame /* ДогП */
DO:
  define variable glog as logical no-undo.

  { gbl/stdbtn.i }

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    c-trn-doc.host-code
    c-trn-doc.obj-type
    c-trn-doc.obj-code
    0
    0
    0
    true
    glog
  }
  if not glog then return no-apply .
  run str/sccntdoc.w (INPUT c-trn-doc.doc-code, INPUT c-trn-doc.chip-num) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
/*
find first c-trn-doc where c-trn-doc.doc-code = pardoc-code and
                                     c-trn-doc.chip-num  = parchip-num no-lock.
find first currency where ub.currency.curr-code = c-trn-doc.exch-code no-lock.*/

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  RUN enable_UI.
  assign frame {&frame-name}:title = if ub.c-trn-doc.is-del then  "Удаленный документ: " + pardoc-code + " " + string(parchip-num)
  else "Документ: " + pardoc-code + "  :(" + string(parchip-num) + ")" .

  if not can-find (first ub.c-inv-line no-lock where ub.c-inv-line.doc-code = c-trn-doc.doc-code ) then disable b-Petrol with frame {&frame-name} .

  if ub.c-trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh} then do:
    hide currency.curr-abbr c-trn-doc.exch-code c-trn-doc.exch-rate c-trn-doc.exch-scale
    in frame {&frame-name}.
  end.
  else do:
    hide c-trn-doc.discnt-pc c-trn-doc.discnt-type c-trn-doc.d-card
    in frame {&frame-name}.
  end.
  if can-do ({&expense_write-off_return}, ub.c-trn-doc.doc-type) then do:
    assign
      vardiscnt = (if ub.c-trn-doc.print-rubl then ub.c-trn-doc.discnt-rubl else ub.c-trn-doc.tot-calc).
  end.
  else do:
    assign
      vardiscnt = 0.00.
  end.

  if ub.c-trn-doc.doc-type = {&income} and
     ub.c-trn-doc.internal = no        then do:
    assign
      varfact-sum = ub.c-trn-doc.tot-calc.
  end.
  else do:
    assign
      varfact-sum = ( if ub.c-trn-doc.print-rubl then ( ub.c-trn-doc.tot-sale - ub.c-trn-doc.discnt-rubl )
                                                 else ( ub.c-trn-doc.tot-fact - ub.c-trn-doc.tot-calc    ) ).
  end.
  display varfact-sum vardiscnt with frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY varfact-sum vardiscnt
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.c-trn-doc THEN
    DISPLAY ub.c-trn-doc.cli-code ub.c-trn-doc.cli-type ub.c-trn-doc.cli-name
          ub.c-trn-doc.exch-code ub.c-trn-doc.VAT-base ub.c-trn-doc.VAT-rubl
          ub.c-trn-doc.exch-rate ub.c-trn-doc.exch-scale ub.c-trn-doc.d-card
          ub.c-trn-doc.doc-qnty ub.c-trn-doc.discnt-type ub.c-trn-doc.discnt-pc
          ub.c-trn-doc.fact-qnty
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.currency THEN
    DISPLAY ub.currency.curr-abbr
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help b-doc-line b-gds-dtl b-parts b-suppcnt
         b-Petrol b-Lines
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION itogo-base Dialog-Frame
FUNCTION itogo-base RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl ) :
  RETURN (local-c-gds-dtl.price-base - local-c-gds-dtl.discnt-base) * local-c-gds-dtl.fact-qnty.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION itogo-rubl Dialog-Frame
FUNCTION itogo-rubl RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl ) :
  RETURN (local-c-gds-dtl.price-rubl - local-c-gds-dtl.discnt-rubl) * local-c-gds-dtl.fact-qnty.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION name-purch-code Dialog-Frame
FUNCTION name-purch-code RETURNS CHARACTER
  ( buffer local-c-parts for c-parts ) :
&scop purchase-code string(local-c-parts.purch-code)
return {&purchase-codes-name}.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION priznak Dialog-Frame
FUNCTION priznak RETURNS character
  ( buffer local-gds-prt for gds-prt,
    buffer local-goods   for goods ) :

  RETURN (if local-gds-prt.node-name = {&empty-scale} then '-' else if local-gds-prt.upper-code = local-goods.prt-root then '-------------------' else local-gds-prt.f-name).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sum-base Dialog-Frame
FUNCTION sum-base RETURNS DECIMAL
  ( buffer  local-c-doc-line for c-doc-line) :

  RETURN local-c-doc-line.price-base * local-c-doc-line.fact-qnty.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sum-cli Dialog-Frame
FUNCTION sum-cli RETURNS DECIMAL
 ( buffer  local-c-doc-line for c-doc-line) :

  RETURN local-c-doc-line.price-cli * local-c-doc-line.fact-qnty.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sum-dsc-base Dialog-Frame
FUNCTION sum-dsc-base RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl ) :
  RETURN local-c-gds-dtl.discnt-base * local-c-gds-dtl.fact-qnty.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sum-dsc-rubl Dialog-Frame
FUNCTION sum-dsc-rubl RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl ) :
  RETURN local-c-gds-dtl.discnt-rubl * local-c-gds-dtl.fact-qnty.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sum-rubl Dialog-Frame
FUNCTION sum-rubl RETURNS DECIMAL
 ( buffer  local-c-doc-line for c-doc-line) :

  RETURN local-c-doc-line.price-rubl * local-c-doc-line.fact-qnty.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sum-sale-base Dialog-Frame
FUNCTION sum-sale-base RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl ) :
  RETURN local-c-gds-dtl.price-base * local-c-gds-dtl.fact-qnty.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sum-sale-rubl Dialog-Frame
FUNCTION sum-sale-rubl RETURNS DECIMAL
  ( buffer local-c-gds-dtl for c-gds-dtl ) :
  RETURN local-c-gds-dtl.price-rubl * local-c-gds-dtl.fact-qnty.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME