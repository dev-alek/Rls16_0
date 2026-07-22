&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Показ товаров по контрагентам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

Имеет семь точек входа

  в зависимости от list-mode = {&all}
                               {&client-cmp_balance-cmp}
                               {&client-cmp_stock-cmp}
                               {&prod-cmp_balance-cmp}
                               {&prod-cmp_stock-cmp}
                               {&goods-cmp_balance-cmp}
                               {&goods-cmp_stock-cmp}


    Данный файл не компилируется в версии ПРОГРЕССА 8.3a - ошибка 7955 - в определении
    броуза - после закоментаривания определения ENABLE sb-cli.clia-art уже компилиться - но
    файл так работатье НЕ МОЖЕТ

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-list-mode as character no-undo .
define input parameter p-gds-rec   as recid no-undo .
define input parameter p-rep-rec as recid no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Показ товаров по контрагентам " .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i  }
{ cmp/r-pril.i new }
{ gbl/color.i    }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ cmp/showinf.i }
{ gbl/fltopend.i defproc }
{ gbl/getsect.i def }

DEFINE BUFFER buf-cli for ub.clients.
DEFINE BUFFER buf-goods for ub.goods.
DEFINE new shared BUFFER sb-cli-gds FOR ub.cli-gds.
define buffer buf-ext-artic for ub.ext-artic.

DEFINE VAR last-curr-code like ub.currency.curr-abbr no-undo.
DEFINE VAR cli-name like ub.clients.obj-name no-undo.
DEFINE VAR gds-name like ub.goods.gds-name no-undo.
DEFINE VAR unit-base like ub.goods.unit-base no-undo.
define variable sym1   as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable producer as char.
define variable accum-count as integer.
define variable accum-in-qnty as decimal.
define variable accum-out-qnty as decimal.
define variable accum-ret-qnty  as decimal.
define variable accum-in-base  as decimal.
define variable accum-in-rubl  as decimal.
define variable accum-out-sum  as decimal.
define variable accum-ret-sum  as decimal.
define variable accum-out-discnt  as decimal.
define variable accum-ret-discnt  as decimal.
define variable accum-supp-qnty  as decimal.
define variable accum-supp-base  as decimal.
define variable accum-supp-rubl  as decimal.

define variable filter-point as character no-undo init "cli-gdss" .
define variable filter-point0 as character no-undo init "cli-gdss" .
define variable filter-label as character no-undo init "Товары_контрагентов" .
define variable filter-label0 as character no-undo init "Товары_контрагентов" .
define variable sort-column-name as character no-undo .

define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .


/*ОСНОВНАЯ ФОРМА*/
DEFINE FRAME CLi-Gds-List
sym1 COLUMn-LABEL ""
sb-cli-gds.artic COLUMN-LABEL "Артикул!произ-ля!(сортируется)"
gds-name FORMAT "X(20)"
unit-base
producer FORMAT "x(9)"
ub.clients.obj-name
cli-name COLUMN-LABEL "Контрагент" FORMAT "X(20)"
sb-cli-gds.cli-art COLUMN-LABEL "Артикул!контрагента"
sb-cli-gds.unit-cli COLUMN-LABEL "Ед.изм.!контр-!агента"
sb-cli-gds.in-qnty COLUMN-LABEL "Кол-во/приход"
sb-cli-gds.out-qnty COLUMN-LABEL "Кол-во/расход"
sb-cli-gds.ret-qnty COLUMN-LABEL "Кол-во/возврат"
sb-cli-gds.in-base COLUMN-LABEL  "Учетн.цены!баз.вал./!приход"
sb-cli-gds.in-rubl COLUMN-LABEL  "Учетн.цены!{&abbr_rub}./!приход"
sb-cli-gds.out-sum COLUMN-LABEL  "Продаж.цены!вал.продаж/!расход"
sb-cli-gds.ret-sum COLUMN-LABEL  "Продаж.цены!вал.продаж/!возврат"
sb-cli-gds.out-discnt COLUMN-LABEL "Скидки!вал.продаж/!расход"
sb-cli-gds.ret-discnt COLUMN-LABEL "Скидки!вал.продаж/!возврат"
sb-cli-gds.in-code COLUmn-LABEL "Последн. ПН"
last-curr-code COLUmn-LABEL "Валюта!посл.ПН"
sb-cli-gds.price-cli COLUmn-LABEL "Последн.цена!контр-агента"
sb-cli-gds.supp-qnty COLUMN-LABEL "Кол-во/остатки"
sb-cli-gds.supp-base COLUMN-LABEL "Учетн.цены!баз.вал./!остатки"
sb-cli-gds.supp-rubl COLUMN-LABEL "Учетн.цены!{&abbr_rub}./!остатки"
sym10 COLUMn-LABEL ""
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER AT 125 FORMAT ">>9" SKIP
Line format "X(177)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-DOCS

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES sb-cli-gds

/* Definitions for BROWSE BR-DOCS                                       */
&Scoped-define FIELDS-IN-QUERY-BR-DOCS sb-cli-gds.artic get-gds-name (buffer sb-cli-gds) get-unit-base (buffer sb-cli-gds) get-cli-name (buffer sb-cli-gds) get-ext-artic (buffer sb-cli-gds) sb-cli-gds.cli-art sb-cli-gds.unit-cli sb-cli-gds.in-qnty sb-cli-gds.out-qnty sb-cli-gds.ret-qnty sb-cli-gds.in-base sb-cli-gds.in-rubl sb-cli-gds.out-sum sb-cli-gds.ret-sum sb-cli-gds.out-discnt sb-cli-gds.ret-discnt sb-cli-gds.in-code get-last-curr-code (buffer sb-cli-gds) sb-cli-gds.price-cli sb-cli-gds.supp-qnty sb-cli-gds.supp-base sb-cli-gds.supp-rubl
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-DOCS sb-cli-gds.cli-art
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-DOCS sb-cli-gds
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-DOCS sb-cli-gds
&Scoped-define SELF-NAME BR-DOCS
&Scoped-define QUERY-STRING-BR-DOCS FOR EACH sb-cli-gds       WHERE sb-cli-gds.host-code = g#host-code
&Scoped-define OPEN-QUERY-BR-DOCS OPEN QUERY {&SELF-NAME} FOR EACH sb-cli-gds       WHERE sb-cli-gds.host-code = g#host-code.
&Scoped-define TABLES-IN-QUERY-BR-DOCS sb-cli-gds
&Scoped-define FIRST-TABLE-IN-QUERY-BR-DOCS sb-cli-gds


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-in RECT-out RECT-ret ~
RECT-left B-Help B-exit b-good b-producer b-supplier b-totals B-cliartic ~
b-sch b-print BR-DOCS PROD-NAME
&Scoped-Define DISPLAYED-OBJECTS F-IN-QNTY F-OUT-QNTY F-RET-QNTY ~
F-LEFT-QNTY F-IN-SUM-BASE F-OUT-SUM-BASE F-RET-SUM-BASE F-LEFT-SUM-BASE ~
F-IN-SUM-RUBL F-LEFT-SUM-RUBL F-OUT-DISCNT-BASE F-RET-DISCNT-BASE PROD-NAME

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-ext-artic Dialog-Frame
FUNCTION get-ext-artic RETURNS CHARACTER
    (buffer loc-cli-gds for sb-cli-gds) FORWARD.
    
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD Get-last-curr-code Dialog-Frame
FUNCTION Get-last-curr-code RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-unit-base Dialog-Frame
FUNCTION get-unit-base RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cliartic
     LABEL "&Внешний артикул"
     SIZE 17.13 BY 1.13.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-good
     LABEL "&Товар"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2.75 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 2.38 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-producer
     LABEL "Произв-ль"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3.13 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-supplier
     LABEL "&Контрагент"
     SIZE 12.13 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-totals
     LABEL "&Итоги"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE F-IN-QNTY AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-IN-SUM-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-IN-SUM-RUBL AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-LEFT-QNTY AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-LEFT-SUM-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-LEFT-SUM-RUBL AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-OUT-DISCNT-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-OUT-QNTY AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-OUT-SUM-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-RET-DISCNT-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-RET-QNTY AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE F-RET-SUM-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE PROD-NAME AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
      VIEW-AS TEXT
     SIZE 64 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-in
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.5 BY 5.

DEFINE RECTANGLE RECT-left
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.5 BY 5.

DEFINE RECTANGLE RECT-out
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.5 BY 5.

DEFINE RECTANGLE RECT-ret
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.5 BY 5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY BR-DOCS FOR
      sb-cli-gds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-DOCS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-DOCS Dialog-Frame _FREEFORM
  QUERY BR-DOCS NO-LOCK DISPLAY
      sb-cli-gds.artic COLUMN-LABEL "Артикул!произ-ля!(сортируется)"
      get-gds-name (buffer sb-cli-gds) FORMAT "X(20)" COLUMN-LABEL "Название"
      get-unit-base (buffer sb-cli-gds) COLUMN-LABEL "Изм" FORMAT "X(3)"
      get-cli-name (buffer sb-cli-gds) COLUMN-LABEL "Контрагент" FORMAT "X(20)"
      get-ext-artic (buffer sb-cli-gds) FORMAT "X(20)" COLUMN-LABEL "Артикул!контрагента!"
      sb-cli-gds.unit-cli COLUMN-LABEL "Изм.!контр!аг-та"
      sb-cli-gds.in-qnty COLUMN-LABEL "Кол-во/приход!(сортируется)"
      sb-cli-gds.out-qnty COLUMN-LABEL "Кол-во/расход!(сортируется)"
      sb-cli-gds.ret-qnty COLUMN-LABEL "Кол-во/возврат!(сортируется)"
      sb-cli-gds.in-base COLUMN-LABEL  "Учетн.цены!баз.вал./!приход"
      sb-cli-gds.in-rubl COLUMN-LABEL  "Учетн.цены!{&abbr_rub}./!приход"
      sb-cli-gds.out-sum COLUMN-LABEL  "Продаж.цены!вал.продаж/!расход"
      sb-cli-gds.ret-sum COLUMN-LABEL  "Продаж.цены!вал.продаж/!возврат"
      sb-cli-gds.out-discnt COLUMN-LABEL "Скидки!вал.продаж/!расход"
      sb-cli-gds.ret-discnt COLUMN-LABEL "Скидки!вал.продаж/!возврат"
      sb-cli-gds.in-code COLUmn-LABEL "Последн. ПН"
      get-last-curr-code (buffer sb-cli-gds) COLUmn-LABEL "Валюта!посл.ПН"
      sb-cli-gds.price-cli COLUmn-LABEL "Последн.цена!контр-агента"
      sb-cli-gds.supp-qnty COLUMN-LABEL "Кол-во/остатки!(сортируется)"
      sb-cli-gds.supp-base COLUMN-LABEL "Учетн.цены!баз.вал./!остатки"
      sb-cli-gds.supp-rubl COLUMN-LABEL "Учетн.цены!{&abbr_rub}./!остатки"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Help AT ROW 1.21 COL 97
     B-exit AT ROW 1.25 COL 1.38
     b-good AT ROW 1.25 COL 11.38
     b-producer AT ROW 1.25 COL 21.38
     b-supplier AT ROW 1.25 COL 31.38
     b-totals AT ROW 1.25 COL 43.5
     B-cliartic AT ROW 1.25 COL 53.5
     b-sch AT ROW 1.25 COL 91.5
     b-print AT ROW 1.25 COL 94.5
     BR-DOCS AT ROW 3.67 COL 1.38
     F-IN-QNTY AT ROW 18.5 COL 6.38 COLON-ALIGNED NO-LABEL
     F-OUT-QNTY AT ROW 18.5 COL 31.75 COLON-ALIGNED NO-LABEL
     F-RET-QNTY AT ROW 18.5 COL 55.75 COLON-ALIGNED NO-LABEL
     F-LEFT-QNTY AT ROW 18.5 COL 80.13 COLON-ALIGNED NO-LABEL
     F-IN-SUM-BASE AT ROW 19.63 COL 6.38 COLON-ALIGNED NO-LABEL
     F-OUT-SUM-BASE AT ROW 19.63 COL 31.63 COLON-ALIGNED NO-LABEL
     F-RET-SUM-BASE AT ROW 19.63 COL 55.75 COLON-ALIGNED NO-LABEL
     F-LEFT-SUM-BASE AT ROW 19.63 COL 80.13 COLON-ALIGNED NO-LABEL
     F-IN-SUM-RUBL AT ROW 20.79 COL 6.25 COLON-ALIGNED NO-LABEL
     F-LEFT-SUM-RUBL AT ROW 20.79 COL 80.13 COLON-ALIGNED NO-LABEL
     F-OUT-DISCNT-BASE AT ROW 21.63 COL 31.75 COLON-ALIGNED NO-LABEL
     F-RET-DISCNT-BASE AT ROW 21.63 COL 56 COLON-ALIGNED NO-LABEL
     PROD-NAME AT ROW 2.79 COL 2.13
     "Приход (учет.цены)" VIEW-AS TEXT
          SIZE 19.88 BY .71 AT ROW 17.63 COL 4.25
          FGCOLOR 4
     "Скидки" VIEW-AS TEXT
          SIZE 5.5 BY .71 AT ROW 21.79 COL 51.88
          FGCOLOR 4 FONT 4
     "Скидки" VIEW-AS TEXT
          SIZE 5.5 BY .71 AT ROW 21.79 COL 28
          FGCOLOR 4 FONT 4
     "." VIEW-AS TEXT
          SIZE 5.5 BY .71 AT ROW 20.96 COL 76.13
          FGCOLOR 4 FONT 4
     "." VIEW-AS TEXT
          SIZE 5.5 BY .71 AT ROW 20.96 COL 2.38
          FGCOLOR 4 FONT 4
     "Баз.вал." VIEW-AS TEXT
          SIZE 5.75 BY .71 AT ROW 19.83 COL 76.13
          FGCOLOR 4 FONT 4
     "Сумма" VIEW-AS TEXT
          SIZE 5.75 BY .71 AT ROW 19.83 COL 51.63
          FGCOLOR 4 FONT 4
     "Сумма" VIEW-AS TEXT
          SIZE 5.75 BY .71 AT ROW 19.83 COL 27.63
          FGCOLOR 4 FONT 4
     "Баз.вал." VIEW-AS TEXT
          SIZE 5.75 BY .71 AT ROW 19.83 COL 2.38
          FGCOLOR 4 FONT 4
     "Кол-во" VIEW-AS TEXT
          SIZE 5.38 BY .71 AT ROW 18.67 COL 76.13
          FGCOLOR 4 FONT 4
     "Кол-во" VIEW-AS TEXT
          SIZE 5.38 BY .71 AT ROW 18.67 COL 52
          FGCOLOR 4 FONT 4
     "Кол-во" VIEW-AS TEXT
          SIZE 5.38 BY .71 AT ROW 18.67 COL 27.63
          FGCOLOR 4 FONT 4
     "Кол-во" VIEW-AS TEXT
          SIZE 5.38 BY .71 AT ROW 18.67 COL 2.38
          FGCOLOR 4 FONT 4
     "Остатки (учет.цены)" VIEW-AS TEXT
          SIZE 19.75 BY .71 AT ROW 17.63 COL 77.5
          FGCOLOR 4
     "Возвр. (вал. продаж)" VIEW-AS TEXT
          SIZE 19.88 BY .71 AT ROW 17.63 COL 53
          FGCOLOR 4
     "Расх. (вал. продаж)" VIEW-AS TEXT
          SIZE 20.13 BY .71 AT ROW 17.63 COL 28.25
          FGCOLOR 4
     RECT-in AT ROW 17.79 COL 1.63
     RECT-out AT ROW 17.79 COL 27
     RECT-ret AT ROW 17.79 COL 51.25
     RECT-left AT ROW 17.79 COL 75.5
     SPACE(0.75) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары контрагентов по фирме".


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
/* BROWSE-TAB BR-DOCS b-print Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN F-IN-QNTY IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-IN-SUM-BASE IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-IN-SUM-RUBL IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-LEFT-QNTY IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-LEFT-SUM-BASE IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-LEFT-SUM-RUBL IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-OUT-DISCNT-BASE IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-OUT-QNTY IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-OUT-SUM-BASE IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-RET-DISCNT-BASE IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-RET-QNTY IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-RET-SUM-BASE IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN PROD-NAME IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-DOCS
/* Query rebuild information for BROWSE BR-DOCS
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH sb-cli-gds
      WHERE sb-cli-gds.host-code = g#host-code.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,"
     _Where[1]         = "cli-gds.host-code = g#host-code"
     _Query            is NOT OPENED
*/  /* BROWSE BR-DOCS */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары контрагентов по фирме */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cliartic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cliartic Dialog-Frame
ON CHOOSE OF B-cliartic IN FRAME Dialog-Frame /* Артик.контраг-та */
DO:
    /* редактирование ил просмотр внешнего артикула */
    define variable rid as recid no-undo.
    
    find first buf-goods no-lock
        where buf-goods.prod-code = sb-cli-gds.prod-code
        and buf-goods.prod-type = sb-cli-gds.prod-type
        and buf-goods.artic = sb-cli-gds.artic
        no-error.
        
    if not avail buf-goods then return.
    
    find first buf-ext-artic no-lock
        where buf-ext-artic.cli-type = sb-cli-gds.cli-type
        and buf-ext-artic.cli-code   = sb-cli-gds.cli-code
        and buf-ext-artic.gds-code = buf-goods.gds-code
        no-error.
            
    if avail buf-ext-artic then
        do:    
            rid = recid(buf-ext-artic).
    
            run ref/ea-form.w(
                input parparentproc ,
                input {&update} ,
                input buf-goods.gds-code,
                input-output rid,
                input recid(buf-cli)
            ).
        
        end.
    else
        do:
            rid = 0.
            
            run ref/ea-form.w(
                input parparentproc,
                input {&add-def},
                input buf-goods.gds-code,
                input-output rid,
                input recid(buf-cli)
            ).
        end.
       
    br-docs:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-good
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-good Dialog-Frame
ON CHOOSE OF b-good IN FRAME Dialog-Frame /* Товар */
DO:
    IF not avail sb-cli-gds then return no-apply.
    FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = sb-cli-gds.prod-type AND
                                                                    ub.goods.prod-code = sb-cli-gds.prod-code AND
                                                                    ub.goods.artic = sb-cli-gds.artic
     NO-ERROR.

    if not available ub.goods then return no-apply.
    run str/showgds.p ( input parparentproc
                       ,input ? /*p-call-handle*/
                       ,input ub.goods.gds-code
                       ,input {&lookup}).
    apply "entry" to br-docs in frame {&frame-name}.
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable glog as logical no-undo .
define variable v-doc-rec  as recid no-undo .
      if p-list-mode = {&all} and index(frame {&frame-name}:title,"ФИЛЬТР" ) = 0 then do:
           message "Вы хотите напечатать весь список товаров контрагентов" skip
           "при невключенном фильтре!" skip
           "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
           WARNING buttons YES-NO update glog.
           if NOT glog then return no-apply.
      end.
      v-doc-rec = recid( sb-cli-gds ).
      DO WHILE available sb-cli-gds :
            GET prev br-docs.
      END.
      if p-list-mode = {&all} then
      run Print-TotalProc("P").
      else
      run Print-List-Mode.
      reposition br-docs to recid v-doc-rec no-error.
      apply "entry" to br-docs in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-producer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-producer Dialog-Frame
ON CHOOSE OF b-producer IN FRAME Dialog-Frame /* Произв-ль */
DO:
    if not available sb-cli-gds then return no-apply.
    run ref/showcli.p
    (input parparentproc
    ,input sb-cli-gds.prod-type /* p-obj-type */
    ,input sb-cli-gds.prod-code /* p-obj-code */
    ).
    apply "entry" to br-docs in frame {&frame-name}.
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'cli-gds'
  join-tbl = 'sb-cli-gds'
  fld = '':U
  lab = '':U
  spr = '':U
  dim = '0':U
  .
  run fltfield-add in this-procedure('artic', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-art', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('unit-cli', '', 'unit',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-qnty', 'Кол-во/приход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-qnty', 'Кол-во/расход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ret-qnty', 'Кол-во/Возврат', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-base', 'Учетн.цены.(баз.вал.)/приход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-rubl', 'Учетн.цены.({&abbr_rub}.)/приход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-sum', 'Продаж.цены/расход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ret-sum', 'Продаж.цены/возврат', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-discnt', 'Скидки(вал.продаж)/расход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ret-discnt', 'Скидки(вал.продаж)/возврат', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-code', 'Последн.ПН', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-code', 'Валюта последн.ПН', 'curr',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-cli', 'Последн.цена', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-qnty', 'Кол-во/остатки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-base', 'Учетн.цены(баз.вал.)/остатки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-rubl', 'Учетн.цены({&abbr_rub}.)/остатки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
      run gbl/filter.w ( input parparentproc
                        , input (filter-point + {&delim-par} + filter-label)
                        , input tbl
                        , input join-tbl
                        , input fld
                        , input lab
                        , input spr
                        , input dim).
      RUN OpenBr in this-procedure .
  END .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-supplier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-supplier Dialog-Frame
ON CHOOSE OF b-supplier IN FRAME Dialog-Frame /* Контрагент */
DO:
    if not available sb-cli-gds then return no-apply.
    run ref/showcli.p
    (input parparentproc
    ,input sb-cli-gds.cli-type /* p-obj-type */
    ,input sb-cli-gds.cli-code /* p-obj-code */
    ).
    apply "entry" to br-docs in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-totals
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-totals Dialog-Frame
ON CHOOSE OF b-totals IN FRAME Dialog-Frame /* Итоги */
DO:
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
    if p-list-mode = {&all} AND index(frame {&frame-name}:title,"ФИЛЬТР" ) = 0 then do:
        message "Вы хотите рассчитать итоги по всему спискy товаров контрагентов" skip
        "при невключенном фильтре!" skip
        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
        WARNING buttons YES-NO update glog.
        if NOT glog then return no-apply.
  end.
  v-doc-rec = recid( sb-cli-gds ).
  DO WHILE available sb-cli-gds :
        GET prev br-docs.
  END.
  run Print-TotalProc("C":U).
  reposition br-docs to recid v-doc-rec no-error.
  apply "entry" to br-docs in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-DOCS
&Scoped-define SELF-NAME BR-DOCS


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-DOCS Dialog-Frame
ON VALUE-CHANGED OF BR-DOCS IN FRAME Dialog-Frame
DO:
DEFINE buffer for-cli for ub.clients.
  FIND FIRST for-cli No-LOCK WHERE for-cli.obj-type = sb-cli-gds.prod-type AND
                                   for-cli.obj-code = sb-cli-gds.prod-code No-ERROR.
    IF AVAIL for-cli then DO:
        DISPLAY for-cli.obj-name @ PROD-NAME WITH FRAME {&frame-name}.
    end.
    else do:
        DISPLAY "" @ PROD-NAME WITH FRAME {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "sb-cli-gds.artic"
  &sort-clmn_3    = "sb-cli-gds.in-qnty"
  &sort-clmn_4    = "sb-cli-gds.out-qnty"
  &sort-clmn_5    = "sb-cli-gds.ret-qnty"
  &sort-clmn_6    = "sb-cli-gds.supp-qnty"
  &open-query     = "run OpenBr in this-procedure ."
  &open-query-otherwise = "run OpenBr in this-procedure ."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  { gbl/hostname.i  v-cntxt-obj-type v-cntxt-obj-code v-host-code v-host-name }

{ gbl/getsect.i run {&cmp} v-host-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.

  frame {&frame-name}:TITLE = frame {&frame-name}:TITLE + " " + v-host-name.
  RUN enable_UI.
  RUN OpenBr in this-procedure .
  { gbl/mv-clmn.i
  &ext-col = 21
  &frame-name = "{&frame-name}"
  &browse-name = "br-docs"
  &start-column = "{&num-locked-columns-br-list} + 1"
  &prev-order-column_1 = "'1,2,3,7,8,9,10,11,12,13,14,15,5,6,16,17,18,19,20,21,4'"
  &prev-order-column-condition_1 = " p-list-mode = {&client-cmp_balance-cmp} "
  &prev-order-column_2 = "'1,2,3,19,20,21,5,6,7,8,9,10,11,12,13,14,15,16,17,18,4'"
  &prev-order-column-condition_2 = " p-list-mode = {&client-cmp_stock-cmp} "
  &prev-order-column_3 = "'1,2,3,4,7,8,9,10,11,12,13,14,15,5,6,16,17,18,19,20,21'"
  &prev-order-column-condition_3 = " p-list-mode = {&prod-cmp_balance-cmp} "
  &prev-order-column_4 = "'1,2,3,4,19,20,21,5,6,7,8,9,10,11,12,13,14,15,16,17,18'"
  &prev-order-column-condition_4 = " p-list-mode = {&prod-cmp_stock-cmp} "
  &prev-order-column_5 = "'4,7,8,9,10,11,12,13,14,15,5,6,16,17,18,19,20,21,1,2,3'"
  &prev-order-column-condition_5 = " p-list-mode = {&goods-cmp_balance-cmp} "
  &prev-order-column_6 = "'4,19,20,21,5,6,7,8,9,10,11,12,13,14,15,16,17,18,1,2,3'"
  &prev-order-column-condition_6 = " p-list-mode = {&goods-cmp_stock-cmp} "
   }
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
  DISPLAY F-IN-QNTY F-OUT-QNTY F-RET-QNTY F-LEFT-QNTY F-IN-SUM-BASE
          F-OUT-SUM-BASE F-RET-SUM-BASE F-LEFT-SUM-BASE F-IN-SUM-RUBL
          F-LEFT-SUM-RUBL F-OUT-DISCNT-BASE F-RET-DISCNT-BASE PROD-NAME
      WITH FRAME Dialog-Frame.
  ENABLE RECT-in RECT-out RECT-ret RECT-left B-Help B-exit b-good
         b-producer b-supplier b-totals B-cliartic b-sch b-print BR-DOCS
         PROD-NAME
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH sb-cli-gds

&scop flt-open-query-handle query br-docs:handle


&scop flt-open-dyn_open-query  FOR EACH sb-cli-gds

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-waitfram yes


CASE p-list-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "ТОВАРЫ КОНТРАГЕНТОВ ПО ФИРМЕ " + v-host-name
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = "sb-cli-gds.host-code = v-host-code"
            &dyn_where-cond = " substitute( 'sb-cli-gds.host-code = &1', v-host-code)"
            &use-ind = "  "
            &by = "  "
          }


    end.

    when {&client-cmp_balance-cmp} or when {&client-cmp_stock-cmp} then do:
        find first buf-cli WHERE recid(buf-cli) = p-rep-rec No-LOCK No-ERROR.
        ASSIGN frame {&frame-name}:TITLE =
        (IF can-do(p-list-mode, {&balance-cmp}) then
        "ОБОРОТЫ КОНТРАГЕНТА "
        else
        "ОСТАТКИ КОНТРАГЕНТА ")
         + string(buf-cli.obj-name, "X(20)") + " ПО ФИРМЕ " + v-host-name
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 &2"
                                 , filter-label0
                                 ,
                                  (IF can-do(p-list-mode, {&balance-cmp}) then
                                  "ОБОРОТЫ КОНТРАГЕНТА "
                                  else
                                  "ОСТАТКИ КОНТРАГЕНТА ")
                                 )
        .
          { gbl/fltopend.i
            &where-cond = "sb-cli-gds.host-code = v-host-code ~
             AND sb-cli-gds.cli-type = buf-cli.obj-type ~
             AND sb-cli-gds.cli-code = buf-cli.obj-code"
            &dyn_where-cond = " substitute('sb-cli-gds.host-code = &1 ~
             AND sb-cli-gds.cli-type = &2&3&2 ~
             AND sb-cli-gds.cli-code = &4', v-host-code, ~{&double-quote~}, buf-cli.obj-type, buf-cli.obj-code)"

            &use-ind = "  "
            &by = "  "
          }
    end.
    when {&prod-cmp_balance-cmp} or when {&prod-cmp_stock-cmp} then do:
        find first buf-cli WHERE recid(buf-cli) = p-rep-rec No-LOCK No-ERROR.
        ASSIGN frame {&frame-name}:TITLE =
       (IF can-do(p-list-mode, {&balance-cmp}) then
        "ОБОРОТЫ ТОВАРОВ ПРОИЗВОДИТЕЛЯ "
        else
        "ОСТАТКИ ТОВАРОВ ПРОИЗВОДИТЕЛЯ ")
        + string(buf-cli.obj-name, "X(20)") + " ВСЕХ КОНТРАГЕНТОВ ПО ФИРМЕ " + v-host-name
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 &2"
                                 , filter-label0
                                 ,
                                  (IF can-do(p-list-mode, {&balance-cmp}) then
                                    "ОБОРОТЫ ТОВАРОВ ПРОИЗВОДИТЕЛЯ "
                                    else
                                    "ОСТАТКИ ТОВАРОВ ПРОИЗВОДИТЕЛЯ "))
        .
          { gbl/fltopend.i
            &where-cond = "sb-cli-gds.host-code = v-host-code ~
             AND sb-cli-gds.prod-type = buf-cli.obj-type ~
             AND sb-cli-gds.prod-code = buf-cli.obj-code"
            &dyn_where-cond = " substitute( 'sb-cli-gds.host-code = &1 ~
             AND sb-cli-gds.prod-type = &2&3&2 ~
             AND sb-cli-gds.prod-code = &4', v-host-code, ~{&double-quote~}, buf-cli.obj-type, buf-cli.obj-code)"

            &use-ind = "  "
            &by = "  "
          }
    end.
    when {&goods-cmp_balance-cmp} or when {&goods-cmp_stock-cmp} then do:
        find first buf-goods WHERE recid(buf-goods) = p-gds-rec No-LOCK No-ERROR.
        ASSIGN frame {&frame-name}:TITLE =
        (IF can-do(p-list-mode, {&balance-cmp}) then
        "ОБОРОТЫ ТОВАРА "
        else
        "ОСТАТКИ ТОВАРА ")
        + buf-goods.artic +  " " + string(buf-goods.gds-name , "X(20)") +
        " ПРОИЗВОДИТЕЛЬ: " + buf-goods.prod-type +
        " " + string(buf-goods.prod-code) + " " + " ПО ФИРМЕ " + v-host-name
        c-point = " " + p-list-mode
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 &2"
                                 , filter-label0
                                 ,
                                  (IF can-do(p-list-mode, {&balance-cmp}) then
                                  "ОБОРОТЫ ТОВАРА "
                                  else
                                  "ОСТАТКИ ТОВАРА "))
        .
          { gbl/fltopend.i
            &where-cond = "sb-cli-gds.host-code = v-host-code ~
             AND sb-cli-gds.prod-type = buf-goods.prod-type ~
             AND sb-cli-gds.prod-code = buf-goods.prod-code ~
             AND sb-cli-gds.artic = buf-goods.artic"
            &dyn_where-cond = "  substitute('sb-cli-gds.host-code = &1 ~
             AND sb-cli-gds.prod-type = &2&3&2 ~
             AND sb-cli-gds.prod-code = &4 ~
             AND sb-cli-gds.artic = &2&5&2', v-host-code, ~{&double-quote~}, buf-goods.prod-type, buf-goods.prod-code, buf-goods.artic)"

            &use-ind = "  "
            &by = "  "
          }
    end.
END CASE.
run waitfram-hide in this-procedure .
    display
    ? @ F-IN-QNTY
    ? @ F-IN-SUM-BASE
    ? @ F-IN-SUM-RUBL
    ? @ F-LEFT-QNTY
    ? @ F-LEFT-SUM-BASE
    ? @ F-LEFT-SUM-RUBL
    ? @ F-OUT-DISCNT-BASE
    ? @ F-OUT-QNTY
    ? @ F-OUT-SUM-BASE
    ? @ F-RET-DISCNT-BASE
    ? @ F-RET-QNTY
    ? @ F-RET-SUM-BASE
    with frame {&frame-name}.
APPLY "VALUE-CHANGED" TO BR-DOCS.
APPLY "ENTRY" TO BR-DOCS.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Print-List-Mode Dialog-Frame
PROCEDURE Print-List-Mode :
DEFINE VARIABLE v-without-zero as logical no-undo .
DEFINE VARIABLE choice as integer no-undo .
run gbl/d-askw.w
                     (input "Печать остатков по контрагенту",
                      input "Выберите опцию печати",
                      input "|",
                      input "Печатать нулевые остатки|Не печатать нулевые остатки|Выход",
                      input "||",
                      input 2,
                      input 3,
                      output choice).
if choice = 3 then return.
assign
v-without-zero = (choice = 2)
.
 run ref/cli-gdsp.p (
                input parparentproc,
                input ENTRY(1, p-list-mode),
                input ENTRY(2, p-list-mode),
                input replace(FRAME {&frame-name}:TITLE, chr(34), chr(39)),
                input v-without-zero,
                output  accum-in-qnty ,
                output  accum-out-qnty ,
                output  accum-ret-qnty  ,
                output  accum-in-base  ,
                output  accum-in-rubl  ,
                output  accum-out-sum  ,
                output  accum-ret-sum  ,
                output  accum-out-discnt  ,
                output  accum-ret-discnt  ,
                output  accum-supp-qnty  ,
                output  accum-supp-base  ,
                output  accum-supp-rubl
                ).
/*
assign
     g#rep-tblname = ""
     g#rep-tblrid = -117
     g#rep-updflds = string( "Товары контрагентов|" ) .
*/
   display
    accum-in-qnty @ F-IN-QNTY
    accum-in-base @ F-IN-SUM-BASE
    accum-in-rubl @ F-IN-SUM-RUBL
    accum-supp-qnty @ F-LEFT-QNTY
    accum-supp-base @ F-LEFT-SUM-BASE
    accum-supp-rubl @ F-LEFT-SUM-RUBL
    accum-out-discnt @ F-OUT-DISCNT-BASE
    accum-out-qnty @ F-OUT-QNTY
    accum-out-sum @ F-OUT-SUM-BASE
    accum-ret-discnt @ F-RET-DISCNT-BASE
    accum-ret-qnty @ F-RET-QNTY
    accum-ret-sum @ F-RET-SUM-BASE
    with frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Print-TotalProc Dialog-Frame
PROCEDURE Print-TotalProc :
/*------------------------------------------------------------------------------
  Purpose:   Печатает броуз - work-mode = "P"
  или считает итоги - work-mode = "C"
  Parameters:  <none>work-mode as Char
  Notes:
------------------------------------------------------------------------------*/
Def Input Parameter work-mode as character format "X(1)" no-undo.
define variable v-process as logical no-undo .
define variable reportfilename as character no-undo .
if work-mode = "P" then do:
    Line = fill("-", 177).
    date_string = cur-time-print() .
   run prn-lib-open-exp in this-procedure (
                                            input parParentProc
                                           ,input yes /*p-is-stream */
                                           ,input no /*p-is-append    */
                                           ,output ReportFileName
                                           ,output v-process
                                            ) .
   if not v-process then return.
    PUT  STREAM PrnLibStream UNFORMATTED
    ( frame {&frame-name}:title )
    format "x(90)" SKIP(0)
    date_string skip(0) .
end.
run waitfram-show in this-procedure ("Ждите...").
if work-mode = "P" then do:
PUT STREAM PrnLibStream UNFORMATTED
"Артикул" p-XL-delim
"Название_товара" p-XL-delim
"Ед.изм." p-XL-delim
"Код производителя" p-XL-delim
"Производитель" p-XL-delim
"Контрагент" p-XL-delim
"Артикул_контрагента" p-XL-delim
"Ед.изм._контрагента" p-XL-delim
"Кол-во/приход" p-XL-delim
"Кол-во/расход" p-XL-delim
"Кол-во/возврат" p-XL-delim
"Учетн.цены(баз.вал.)/приход" p-XL-delim
"Учетн.цены({&abbr_rub}.)/приход" p-XL-delim
"Продаж.цены(вал.продаж)/расход" p-XL-delim
"Продаж.цены(вал.продаж)/возврат" p-XL-delim
"Скидки(вал.продаж)/расход" p-XL-delim
"Скидки(вал.продаж)/возврат" p-XL-delim
"Последняя_ПН" p-XL-delim
"Валюта_посл.ПН" p-XL-delim
"Последн.цена_контрагента" p-XL-delim
"Кол-во/остатки" p-XL-delim
"Учетн.цены(баз.вал.)/остатки" p-XL-delim
"Учетн.цены({&abbr_rub}.)/остатки" p-XL-delim
SKIP.
end. /*if "P"*/

    assign
    accum-count = 0
    accum-in-qnty = 0
    accum-out-qnty = 0
    accum-ret-qnty = 0
    accum-in-base = 0
    accum-in-rubl = 0
    accum-out-sum = 0
    accum-ret-sum = 0
    accum-out-discnt = 0
    accum-ret-discnt = 0
    accum-supp-qnty = 0
    accum-supp-base = 0
    accum-supp-rubl = 0.

GET next br-docs.
DO WHILE available sb-cli-gds :
    assign
    accum-count = accum-count + 1
    accum-in-qnty = accum-in-qnty + sb-cli-gds.in-qnty
    accum-out-qnty = accum-out-qnty + sb-cli-gds.out-qnty
    accum-ret-qnty = accum-ret-qnty + sb-cli-gds.ret-qnty
    accum-in-base = accum-in-base + sb-cli-gds.in-base
    accum-in-rubl = accum-in-rubl + sb-cli-gds.in-rubl
    accum-out-sum = accum-out-sum + sb-cli-gds.out-sum
    accum-ret-sum = accum-ret-sum + sb-cli-gds.ret-sum
    accum-out-discnt = accum-out-discnt + sb-cli-gds.out-discnt
    accum-ret-discnt = accum-ret-discnt + sb-cli-gds.ret-discnt
    accum-supp-qnty = accum-supp-qnty + sb-cli-gds.supp-qnty
    accum-supp-base = accum-supp-base + sb-cli-gds.supp-base
    accum-supp-rubl = accum-supp-rubl + sb-cli-gds.supp-rubl.

    if work-mode = "P" then do:
        FIND FIRST ub.currency NO-LOCK WHERE ub.currency.curr-code = sb-cli-gds.exch-code
        No-ERROR.
        FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = sb-cli-gds.prod-type AND
                                         ub.clients.obj-code = sb-cli-gds.prod-code
        No-ERROR.
        if avail ub.clients then
        cli-name = ub.clients.obj-name.
        else
        cli-name = "".
        FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = sb-cli-gds.prod-type AND
                                         ub.clients.obj-code = sb-cli-gds.prod-code
        No-ERROR.
        FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = sb-cli-gds.prod-type AND
                                                                    ub.goods.prod-code = sb-cli-gds.prod-code AND
                                                                    ub.goods.artic = sb-cli-gds.artic
        NO-ERROR.
        IF AVAIL ub.goods then
        assign
        gds-name = ub.goods.gds-name
        unit-base = ub.goods.unit-base.
        else
        assign
        gds-name = ""
        unit-base = "".
        PUT STREAM PrnLibStream UNFORMATTED
        sb-cli-gds.artic p-XL-delim
        REPLACE(gds-name, " ", "_") p-XL-delim
        unit-base p-XL-delim
        (clients.obj-type + "_" + string(clients.obj-code)) p-XL-delim
        REPLACE(clients.obj-name, " ", "_") p-XL-delim
        REPLACE(cli-name, " ", "_") p-XL-delim
        sb-cli-gds.cli-art p-XL-delim
        sb-cli-gds.unit-cli p-XL-delim
        sb-cli-gds.in-qnty p-XL-delim
        sb-cli-gds.out-qnty p-XL-delim
        sb-cli-gds.ret-qnty p-XL-delim
        sb-cli-gds.in-base p-XL-delim
        sb-cli-gds.in-rubl p-XL-delim
        sb-cli-gds.out-sum p-XL-delim
        sb-cli-gds.ret-sum p-XL-delim
        sb-cli-gds.out-discnt p-XL-delim
        sb-cli-gds.ret-discnt p-XL-delim
        sb-cli-gds.in-code p-XL-delim
        last-curr-code p-XL-delim
        sb-cli-gds.price-cli p-XL-delim
        sb-cli-gds.supp-qnty p-XL-delim
        sb-cli-gds.supp-base p-XL-delim
        sb-cli-gds.supp-rubl p-XL-delim
        skip.
    end. /*work-mode = "P"*/
    GET next br-docs.
    END.
    IF work-mode = "P" then do:
        /*Покажем ИТОГИ*/
        PUT STREAM PrnLibStream UNFORMATTED
        "ИТОГО_записей" p-XL-delim
        string(accum-count) p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        accum-in-qnty p-XL-delim
        accum-out-qnty p-XL-delim
        accum-ret-qnty p-XL-delim
        accum-in-base p-XL-delim
        accum-in-rubl p-XL-delim
        accum-out-sum p-XL-delim
        accum-ret-sum p-XL-delim
        accum-out-discnt p-XL-delim
        accum-ret-discnt p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        accum-supp-qnty p-XL-delim
        accum-supp-base p-XL-delim
        accum-supp-rubl p-XL-delim
        SKIP.
       output  STREAM PrnLibStream CLOSE.
       /*
       assign
             g#rep-tblname = ""
             g#rep-tblrid = -117
             g#rep-updflds = string( "Товары контрагентов|" ) .
      */
        run waitfram-hide in this-procedure .
   end. /*work-mode = "P"*/
   run waitfram-hide in this-procedure .
    display
    accum-in-qnty @ F-IN-QNTY
    accum-in-base @ F-IN-SUM-BASE
    accum-in-rubl @ F-IN-SUM-RUBL
    accum-supp-qnty @ F-LEFT-QNTY
    accum-supp-base @ F-LEFT-SUM-BASE
    accum-supp-rubl @ F-LEFT-SUM-RUBL
    accum-out-discnt @ F-OUT-DISCNT-BASE
    accum-out-qnty @ F-OUT-QNTY
    accum-out-sum @ F-OUT-SUM-BASE
    accum-ret-discnt @ F-RET-DISCNT-BASE
    accum-ret-qnty @ F-RET-QNTY
    accum-ret-sum @ F-RET-SUM-BASE
    with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-ext-artic Dialog-Frame
FUNCTION get-ext-artic RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
    
    /* Вызывается при получение значения Внешнего артикуля */

    find first buf-goods no-lock
        where buf-goods.prod-type = loc-cli-gds.prod-type
        and buf-goods.prod-code = loc-cli-gds.prod-code
        and buf-goods.artic = loc-cli-gds.artic
        no-error.
    
    if not avail buf-goods then return "".
    
    find first ub.ext-artic no-lock
        where ub.ext-artic.cli-type = loc-cli-gds.cli-type
        and ub.ext-artic.cli-code = loc-cli-gds.cli-code
        and ub.ext-artic.gds-code = buf-goods.gds-code
        no-error.
        
    if avail ub.ext-artic then
        return ub.ext-artic.ext-artic.
    else
        return "".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
/*------------------------------------------------------------------------------
  Purpose:  находит название контрагента
    Notes:
------------------------------------------------------------------------------*/
    define variable dop like ub.clients.obj-name.
    FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = loc-cli-gds.cli-type AND
                                     ub.clients.obj-code = loc-cli-gds.cli-code
    No-ERROR.
    IF avail ub.clients then dop = ub.clients.obj-name.
    ELSE dop = "".
  RETURN dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
/*------------------------------------------------------------------------------
  Purpose:  находит название контрагента
    Notes:
------------------------------------------------------------------------------*/
    define variable dop like ub.goods.gds-name.
    FIND FIRST ub.goods NO-LOCK WHERE ub.goods.prod-type = loc-cli-gds.prod-type AND
                                   ub.goods.prod-code = loc-cli-gds.prod-code AND
                                   ub.goods.artic = loc-cli-gds.artic
    No-ERROR.
    IF avail ub.goods then dop = ub.goods.gds-name.
    ELSE dop = "".
  RETURN dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION Get-last-curr-code Dialog-Frame
FUNCTION Get-last-curr-code RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
/*------------------------------------------------------------------------------
  Purpose:  находит аббревиатуру поледней приходной валюты
    Notes:
------------------------------------------------------------------------------*/
    define variable dop like ub.currency.curr-abbr.
    FIND FIRST ub.currency NO-LOCK WHERE ub.currency.curr-code = loc-cli-gds.exch-code
    No-ERROR.
    IF avail ub.currency then dop = ub.currency.curr-abbr.
    ELSE dop = "".
  RETURN dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-unit-base Dialog-Frame
FUNCTION get-unit-base RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
/*------------------------------------------------------------------------------
  Purpose:  находит название контрагента
    Notes:
------------------------------------------------------------------------------*/
    define variable dop like ub.goods.gds-name.
    FIND FIRST ub.goods NO-LOCK WHERE ub.goods.prod-type = loc-cli-gds.prod-type AND
                                   ub.goods.prod-code = loc-cli-gds.prod-code AND
                                   ub.goods.artic = loc-cli-gds.artic
    No-ERROR.
    IF avail ub.goods then dop = ub.goods.unit-base.
    ELSE dop = "".
  RETURN dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
