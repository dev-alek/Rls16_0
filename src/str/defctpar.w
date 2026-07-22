&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER Buf_bar-code FOR ub.bar-code.
DEFINE BUFFER Buf_goods FOR ub.goods.
DEFINE TEMP-TABLE x_parts NO-UNDO LIKE ub.parts.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Управление Фальсифицированными и бракованными партиями товаров

Автор: Чернова Светлана Александровна
Дата создания: 11/25/09
Author: Svetlana Chernova
Creation date: 11/25/09

*/

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-handle      as handle no-undo .
define input  parameter p-obj-type    like ub.clients.obj-type no-undo.
define input  parameter p-obj-code    like ub.shop.obj-code no-undo.
define input  parameter p-mode        as character no-undo .
define input  parameter p-obj as integer   no-undo .
define output parameter table for x_parts .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление  Фальсифицированными и бракованными партиями товаров".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/library.i  }
{ gbl/thbjattr.i }
{ gbl/godendo.i  }
{ gbl/cur-time.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ gbl/waitfram.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/bb-list.i bb-list def " new shared " }
{ gbl/clntattr.i }

&scop col-l1  '*'
&scop col-l2  'Артикул! '
&scop col-l3  'Серия!№ партии'
&scop col-l4  'Бар-код!партии'
&scop col-l5  'Наименование!товара'
&scop col-l6  'Дата ПН! '
&scop col-l7  'Остатки!количество'
&scop col-l8  '№ ПН! '
&scop col-l9  'Последний срок!реализации'
&scop col-l10 'Цена!Производителя'
&scop col-l11 'ФиБ! '
&scop col-l12 'Цена!(вал.пост)'
&scop col-l13 'Цена уч!{&abbr_rub}'
&scop col-l14 'Объект!тип'
&scop col-l15 'Объект!код'
&scop col-l16 'Тип!НДС'
&scop col-l17 '%!НДС'
&scop col-l18 'Объект!Название'
&scop col-l19 'Контрагент!Название'


&scop cop-l1     mark-string(recid( x_parts), rid-list)
&scop dyn_cop-l1 substitute('dynamic-function(&1mark-string&1, recid(x_parts), &1&2&1)', ~{&double-quote~}, rid-list)
&scop cop-l2     x_parts.artic
&scop cop-l3     x_parts.part-code
&scop cop-l4     Buf_bar-code.b-code
&scop cop-l5     Buf_goods.gds-name
&scop cop-l6     x_parts.fact-date
&scop cop-l7     x_parts.fact-qnty
&scop cop-l8     x_parts.in-code
&scop cop-l9     x_parts.last-date
&scop cop-l10    x_parts.dop
&scop cop-l11    x_parts.defect
&scop cop-l12    x_parts.price-cli
&scop cop-l13    x_parts.price-rubl
&scop cop-l14    x_parts.obj-type
&scop cop-l15    x_parts.obj-code
&scop cop-l16    x_parts.vat-type
&scop cop-l17    x_parts.vat-pc
&scop cop-l18     f-obj-name(recid( x_parts))
&scop dyn_cop-l18 substitute('dynamic-function(&1f-obj-name&1, recid(x_parts))', ~{&double-quote~})
&scop cop-l19     f-cli-name(recid( x_parts))
&scop dyn_cop-l19 substitute('dynamic-function(&1f-cli-name&1, recid(x_parts))', ~{&double-quote~})



define variable rid-list as character no-undo .
define variable filter-point as character no-undo init "Специальный список партий" .
define variable filter-point0 as character no-undo init "СпецСписок_партий_" .
define variable sort-column-name as character no-undo .

define variable v-srok as integer   no-undo .
define variable v-srok-date as date no-undo .
define variable v-today as date      no-undo .
define variable v-time as integer   no-undo .
define variable doc-rec as recid no-undo .
define variable g-log as logical   no-undo .
define variable v-tth     as handle no-undo .
define temp-table temp-parts no-undo like ub.parts. /* из вне */
define variable v-host-code as integer   no-undo .
define variable gds-rec                     as recid no-undo.
define variable vf-obj-name as character no-undo .
define variable vf-cli-name as character no-undo .
define temp-table temp-obj no-undo
field obj-type as character
field obj-code as integer
index pi
obj-type
obj-code
.

{ gbl/hostcode.i
  p-obj-type
  p-obj-code
  v-host-code
  }

  DEFINE TEMP-TABLE xx_parts NO-UNDO LIKE ub.parts.


FUNCTION f-obj-name RETURN CHARACTER
( input p-recid as recid ).
define buffer bf_parts for x_parts  .

  find first  bf_parts no-lock where recid(bf_parts) = p-recid no-error .
  if not available bf_parts then RETURN "".
  find first  ub.clients no-lock where
              ub.clients.obj-code = bf_parts.obj-code and
              ub.clients.obj-type = bf_parts.obj-type no-error .
              if not available ub.clients then RETURN "".
  return ub.clients.obj-name .
END FUNCTION.

FUNCTION f-cli-name RETURN CHARACTER
( input p-recid as recid ).
define buffer bf_parts for x_parts  .

  find first  bf_parts no-lock where recid (bf_parts) = p-recid no-error .
  if not available bf_parts then RETURN "" .
  find first  ub.clients no-lock where
              ub.clients.obj-code = bf_parts.supp-code and
              ub.clients.obj-type = bf_parts.supp-type no-error .
              if not available ub.clients then RETURN "".
  return ub.clients.obj-name .
END FUNCTION.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x_parts Buf_goods Buf_bar-code

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 {&cop-l1} /*"* " */ {&cop-l2} /*"Артикул! " */ {&cop-l3} /*"Серия!№ партии"*/ {&cop-l4} /*"Бар-код!партии" */ {&cop-l5} /*"Наименование!товара"*/ {&cop-l6} /*"Дата ПН! " */ {&cop-l7} /*"Остатки!количество" */ {&cop-l8} /*"№ ПН! " */ {&cop-l9} /*"Последний срок!реализации" */ {&cop-l10} /*"Цена!Производителя" */ {&cop-l11} /*"ФиБ!" */ {&cop-l12} /*"Цена !(вал.пост)" */ {&cop-l13} /*"Цена уч!{&abbr_rub}" */ {&cop-l14} {&cop-l15} {&cop-l16} {&cop-l17}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 {&cop-l2}
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH x_parts NO-LOCK, ~
             EACH Buf_goods OF x_parts NO-LOCK, ~
             EACH Buf_bar-code WHERE            Buf_bar-code.gds-code  = Buf_goods.gds-code and            Buf_bar-code.in-code   = x_parts.in-code and            Buf_bar-code.part-code = x_parts.part-code            NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH x_parts NO-LOCK, ~
             EACH Buf_goods OF x_parts NO-LOCK, ~
             EACH Buf_bar-code WHERE            Buf_bar-code.gds-code  = Buf_goods.gds-code and            Buf_bar-code.in-code   = x_parts.in-code and            Buf_bar-code.part-code = x_parts.part-code            NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 x_parts Buf_goods Buf_bar-code
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 x_parts
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-2 Buf_goods
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-2 Buf_bar-code


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS BROWSE-2 b-Cancel b-add-2 b-add b-del-2 ~
b-del b-impotr-www b-make-trn b-report b-make-add b-clear b-sch b-print ~
b-help R-sort v-sort-pole R-obj b-mark b-mark-all FILL-IN-1 b-del-mark ~
FILL-IN-2 mark-num
&Scoped-Define DISPLAYED-OBJECTS R-sort v-sort-pole R-obj FILL-IN-1 ~
FILL-IN-2 mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-make-add
       MENU-ITEM m_pri          LABEL "По списку ПН"
       MENU-ITEM m_goods        LABEL "По списку товаров"
       MENU-ITEM m_b-code       LABEL "По списку кодов"
       MENU-ITEM m_serii        LABEL "По номеру серии".

DEFINE MENU POPUP-MENU-b-make-add-2
       MENU-ITEM m_pri-2        LABEL "По списку ПН"
       MENU-ITEM m_goods-2      LABEL "По списку товаров"
       MENU-ITEM m_b-code-2     LABEL "По списку кодов"
       MENU-ITEM m_serii-2      LABEL "По номеру серии2".

DEFINE MENU POPUP-MENU-b-make-trn
       MENU-ITEM m_ep           LABEL "Возврат поставщику"
       MENU-ITEM m_we           LABEL "Списание"
       MENU-ITEM m_ev           LABEL "Внутренний расход"
       MENU-ITEM m_iv           LABEL "Внутренний приход (запрос)".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     IMAGE-UP FILE "cmp/add.bmp":U
     IMAGE-DOWN FILE "cmp/add.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/add.bmp":U
     LABEL "&+"
     SIZE 2.88 BY .92 TOOLTIP "Добавить в список (Alt+)"
     BGCOLOR 8 .

DEFINE BUTTON b-add-2
     LABEL ".   Добавить"
     SIZE 12.75 BY 1 TOOLTIP "Добавить в список (Alt+)"
     BGCOLOR 8 .

DEFINE BUTTON b-Cancel AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-clear
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить из текущего списка"
     BGCOLOR 8 .

DEFINE BUTTON b-del
     IMAGE-UP FILE "cmp/deleterec.bmp":U
     IMAGE-DOWN FILE "cmp/deleterec.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/deleterec.bmp":U
     LABEL "&-"
     SIZE 2.88 BY .92 TOOLTIP "Удалить из списка (Alt-)"
     BGCOLOR 8 .

DEFINE BUTTON b-del-2
     LABEL ".   Удалить"
     SIZE 12 BY 1 TOOLTIP "Удалить из списка (Alt-)"
     BGCOLOR 8 .

DEFINE BUTTON b-del-mark
     LABEL "&="
     SIZE 3 BY 1 TOOLTIP "Снять все отметки в списке"
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&H"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-impotr-www
     IMAGE-UP FILE "cmp/www.bmp":U
     LABEL "&I"
     SIZE 6.5 BY 1 TOOLTIP "Импортировать из Excel ( Alt+I ) подготовленный файл программой ФАЛЬСИФИКАТ"
     BGCOLOR 8 .

DEFINE BUTTON b-make-add
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавление в список партии свободной зоны"
     BGCOLOR 8 .

DEFINE BUTTON b-make-trn
     LABEL "ГенНакл"
     SIZE 10 BY 1 TOOLTIP "Сделать по выделенным партия накладную"
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить записи в списке"
     BGCOLOR 8 .

DEFINE BUTTON b-mark-all
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Отметить ВСЕ записи в списке"
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "П"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-report
     LABEL "Отчет"
     SIZE 10 BY 1 TOOLTIP "Отчеты"
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Ф"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по:"
      VIEW-AS TEXT
     SIZE 9.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Объект:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-sort-pole AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1 NO-UNDO.

DEFINE VARIABLE R-obj AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "текущий", 0,
"все", 1
     SIZE 16 BY 1 TOOLTIP "Партии по всем объектам или по текущему"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE R-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "серии", 2,
"артикулу", 3,
"наименованию", 4
     SIZE 39.38 BY 1 TOOLTIP "Поиск по СЕРИИ (№ партии), артикулу или наименованию"
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      x_parts,
      Buf_goods,
      Buf_bar-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 NO-LOCK DISPLAY
      {&cop-l1} COLUMN-LABEL {&col-l1}  FORMAT "X(1)":U                   /*"* " */
      {&cop-l2} COLUMN-LABEL {&col-l2}  FORMAT "X(16)":U                  /*"Артикул! " */
      {&cop-l3} COLUMN-LABEL {&col-l3}  FORMAT "X(20)":U                  /*"Серия!№ партии"*/
      {&cop-l4} COLUMN-LABEL {&col-l4}  FORMAT "999999999":U              /*"Бар-код!партии"  */
      {&cop-l5} COLUMN-LABEL {&col-l5}  FORMAT "X(40)":U                  /*"Наименование!товара"*/
      {&cop-l18}   @ vf-obj-name  COLUMN-LABEL {&col-l18}  FORMAT "X(20)":U           /*"Название объекта! "                */
      {&cop-l6} COLUMN-LABEL {&col-l6}  FORMAT "99/99/9999":U             /*"Дата ПН! "            */
      {&cop-l7} COLUMN-LABEL {&col-l7}  FORMAT "->>,>>>,>>9.999":U        /*"Остатки!количество"   */
      {&cop-l8} COLUMN-LABEL {&col-l8}  FORMAT "X(14)":U                  /*"№ ПН! "                */
      {&cop-l9} COLUMN-LABEL {&col-l9}  FORMAT "99/99/9999":U             /*"Последний срок!реализации" */
      {&cop-l10} COLUMN-LABEL {&col-l10}  FORMAT "x(13)":U                /*"Цена!Производителя"      */
      {&cop-l11} COLUMN-LABEL {&col-l11}  FORMAT "9":U                    /*"ФиБ!"                    */
      {&cop-l12} COLUMN-LABEL {&col-l12}  FORMAT "->>,>>>,>>>,>>9.999":U  /*"Цена !(вал.пост)"         */
      {&cop-l13} COLUMN-LABEL {&col-l13}  FORMAT "->>,>>>,>>9.99":U       /*"Цена уч!{&abbr_rub}"       */
      {&cop-l14} COLUMN-LABEL {&col-l14}  FORMAT "X(3)":U
      {&cop-l15} COLUMN-LABEL {&col-l15}  FORMAT "99999":U
      {&cop-l16} COLUMN-LABEL {&col-l16}  FORMAT "X(6)":U
      {&cop-l17} COLUMN-LABEL {&col-l17}  FORMAT ">>9.99":U
      {&cop-l19}   @ vf-cli-name  COLUMN-LABEL {&col-l19}  FORMAT "X(30)":U           /*"Название Контрагента! "                */
      enable {&cop-l2}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.25 BY 17.54 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     BROWSE-2 AT ROW 4.75 COL 1.25 WIDGET-ID 200
     b-Cancel AT ROW 1 COL 1
     b-add-2 AT ROW 1 COL 11.13 WIDGET-ID 48
     b-add AT ROW 1.04 COL 11.63 WIDGET-ID 10
     b-del-2 AT ROW 1 COL 24 WIDGET-ID 50
     b-del AT ROW 1 COL 24 WIDGET-ID 12
     b-impotr-www AT ROW 1 COL 36 WIDGET-ID 16
     b-make-trn AT ROW 1 COL 42.63 WIDGET-ID 8
     b-report AT ROW 1 COL 52.63 WIDGET-ID 40
     b-make-add AT ROW 1 COL 62.75 WIDGET-ID 24
     b-clear AT ROW 1 COL 73 WIDGET-ID 20
     b-sch AT ROW 1 COL 90.5 WIDGET-ID 4
     b-print AT ROW 1 COL 92.5 WIDGET-ID 2
     b-help AT ROW 1 COL 94.5
     R-sort AT ROW 2.13 COL 11.25 NO-LABEL WIDGET-ID 30
     v-sort-pole AT ROW 2.13 COL 48.63 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     R-obj AT ROW 2.25 COL 81 NO-LABEL WIDGET-ID 42
     b-mark AT ROW 3.71 COL 1.75 WIDGET-ID 14
     b-mark-all AT ROW 3.71 COL 4.88 WIDGET-ID 28
     FILL-IN-1 AT ROW 2.25 COL 2 NO-LABEL WIDGET-ID 36
     b-del-mark AT ROW 3.71 COL 7.88 WIDGET-ID 26
     FILL-IN-2 AT ROW 2.38 COL 73.13 NO-LABEL WIDGET-ID 46
     mark-num AT ROW 4 COL 9.5 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     SPACE(82.37) SKIP(17.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Управление списком партий"
         CANCEL-BUTTON b-Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: Buf_bar-code B "?" ? ub bar-code
      TABLE: Buf_goods B "?" ? ub ub.goods
      TABLE: x_parts T "?" NO-UNDO ub parts
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB BROWSE-2 1 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-make-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-make-add:HANDLE.

ASSIGN
       b-make-trn:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-make-trn:HANDLE.

ASSIGN
       b-report:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-make-add-2:HANDLE.

ASSIGN
       BROWSE-2:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x_parts NO-LOCK,
      EACH Buf_goods OF x_parts NO-LOCK,
      EACH Buf_bar-code WHERE
           Buf_bar-code.gds-code  = Buf_goods.gds-code and
           Buf_bar-code.in-code   = x_parts.in-code and
           Buf_bar-code.part-code = x_parts.part-code
           NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Управление списком партий */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* + */
DO:
define variable i as integer   no-undo .
define variable ii as integer   no-undo .
define buffer buf_parts for ub.parts  .

empty temp-table temp-parts.

run str/defctpar.w
( parparentproc ,
  this-procedure,
  v-cntxt-obj-type,
  v-cntxt-obj-code,
  "add-new-fib" ,
  p-obj,
  output TABLE temp-parts)
  no-error .

run waitfram-show in this-procedure ("Отметка ФиБ на партиях") .
  for each temp-parts :
      find first x_parts no-lock  where
            x_parts.obj-code   = temp-parts.obj-code and
            x_parts.obj-type   = temp-parts.obj-type  and
            x_parts.artic      = temp-parts.artic  and
            x_parts.prod-type  = temp-parts.prod-type  and
            x_parts.prod-code  = temp-parts.prod-code  and
            x_parts.out-code   = temp-parts.out-code  and
            x_parts.in-code    = temp-parts.in-code  and
            x_parts.part-code  = temp-parts.part-code  no-error .
       if not available x_parts then do:
           i = i + 1 .
           ii = ii + 1 .
           create x_parts.
           buffer-copy temp-parts to x_parts
              assign
                 x_parts.defect = logical({&FiB})
           .
            run save-proc in this-procedure
            ( buffer x_parts ) .

            /* ?????  */
   /*         for each   buf_parts exclusive-lock  where
                        buf_parts.artic      = x_parts.artic      and
                        buf_parts.prod-type  = x_parts.prod-type  and
                        buf_parts.prod-code  = x_parts.prod-code  and
                        buf_parts.part-code  = x_parts.part-code  and
                        buf_parts.out-code   = {&free-code} and
                        buf_parts.defect = 0
                        :
                  buf_parts.defect = logical({&FiB}).
                  ii = ii + 1 .
              end.
              */

       end.
  end.
  run waitfram-hide in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).
  if r-obj = 1 then do:
     message substitute ( "Добавлено &1 партий в список ФиБ партий по всем объектам " , i , ii ) view-as alert-box .
  end.
  else do:
     message substitute ( "Добавлено &1 партий в список ФиБ партий по текущему объекту " , i , ii ) view-as alert-box .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-2 Dialog-Frame
ON CHOOSE OF b-add-2 IN FRAME Dialog-Frame /* .   Добавить */
DO:
  apply "CHOOSE" to b-add IN FRAME Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clear Dialog-Frame
ON CHOOSE OF b-clear IN FRAME Dialog-Frame /* Удалить */
DO:
define variable br-handle as handle no-undo .
define variable g#log as logical   no-undo .
define variable v-doc-rec as recid no-undo .

  find current x_parts no-error    .
  if not available x_parts then return .
  delete x_parts.

  br-handle = {&browse-name}:handle in frame {&frame-name} .
  if valid-handle (br-handle) then do:
    g#log = br-handle:select-next-row().
    if not g#log then g#log = br-handle:select-prev-row().
    v-doc-rec = recid (x_parts) .
  end.

   run OpenBr in this-procedure (yes, no, '':U).
   apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
   reposition {&browse-name} to recid v-doc-rec no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* - */
DO:
/* Если не отмечено */
define variable i as integer   no-undo .
define buffer buf_x_parts for x_parts  .
define buffer buf_parts for ub.parts  .


if num-entries ( rid-list ) = 0  then do:
  find current x_parts no-error    .
  if not available x_parts then return .
  assign
    x_parts.defect = false
  .
    /* И записать это в БД */
      run save-proc in this-procedure
      ( buffer x_parts ) .
    delete x_parts no-error .
end.
else do:
  do i = 1 to num-entries(rid-list) :
  find first buf_x_parts where recid(buf_x_parts) = int(entry(i,rid-list)) no-error.
  if not available buf_x_parts then next .
  assign
    buf_x_parts.defect = false
  .
    /* И записать это в БД */
      run save-proc in this-procedure
      ( buffer buf_x_parts ) .
      for each   buf_parts exclusive-lock  where
                  buf_parts.artic      = buf_x_parts.artic      and
                  buf_parts.prod-type  = buf_x_parts.prod-type  and
                  buf_parts.prod-code  = buf_x_parts.prod-code  and
                  buf_parts.part-code  = buf_x_parts.part-code  and
                  buf_parts.out-code   = {&free-code}           and
                  buf_parts.defect = logical({&FiB})
                  :
            buf_parts.defect = false   .
        end.
    delete buf_x_parts no-error .
  end.
  rid-list = "".
end.
run OpenBr in this-procedure (yes, no, '':U).



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-2 Dialog-Frame
ON CHOOSE OF b-del-2 IN FRAME Dialog-Frame /* .   Удалить */
DO:
  apply "CHOOSE" to b-del IN FRAME Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-mark Dialog-Frame
ON CHOOSE OF b-del-mark IN FRAME Dialog-Frame /* = */
DO:
rid-list = "".
g-log = BROWSE-2:refresh() .
apply "entry" to BROWSE-2 in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-impotr-www
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-impotr-www Dialog-Frame
ON CHOOSE OF b-impotr-www IN FRAME Dialog-Frame /* I */
DO:

define variable i as integer   no-undo .
define variable ii as integer   no-undo .
define buffer buf_parts for ub.parts  .

empty temp-table temp-parts.

run str/imp-fib.w
( parparentproc  ,
  this-procedure ,
  output TABLE temp-parts )
  no-error .
find first temp-parts no-error .
if not available temp-parts then return .

run waitfram-show in this-procedure ("Отметка ФиБ на партиях") .
  for each temp-parts :
      find first x_parts no-lock  where
            x_parts.obj-code   = temp-parts.obj-code and
            x_parts.obj-type   = temp-parts.obj-type  and
            x_parts.artic      = temp-parts.artic  and
            x_parts.prod-type  = temp-parts.prod-type  and
            x_parts.prod-code  = temp-parts.prod-code  and
            x_parts.out-code   = temp-parts.out-code  and
            x_parts.in-code    = temp-parts.in-code  and
            x_parts.part-code  = temp-parts.part-code  no-error .
       if not available x_parts then do:
           i = i + 1 .
           ii = ii + 1 .
           create x_parts.
           buffer-copy temp-parts to x_parts
              assign
                 x_parts.whole-send-news = int({&FiB})
           .
            run save-proc in this-procedure
            ( buffer x_parts ) .

       end.
  end.
  run waitfram-hide in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).
  if r-obj = 1 then do:
     message substitute ( "Добавлено &1 партий в список ФиБ партий по всем объектам " , i , ii ) view-as alert-box .
  end.
  else do:
     message substitute ( "Добавлено &1 партий в список ФиБ партий по текущему объекту " , i , ii ) view-as alert-box .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
      if available x_parts then do:
        { gbl/markstrn.i x_parts rid-list }

        g-log = BROWSE-2:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = BROWSE-2:select-next-row ().
            apply "VALUE-CHANGED" to BROWSE-2 in frame {&frame-name}.
        end.
        if num-entries( rid-list ) = 0
        then
            hide mark-num in frame {&frame-name}.
        else do:
           /*
            mark-num:screen-value in frame {&frame-name}  = string (num-entries( rid-list )) .
            enable mark-num with frame {&frame-name}.
            */
            end.
    end.
    apply "entry" to BROWSE-2 in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark-all Dialog-Frame
ON CHOOSE OF b-mark-all IN FRAME Dialog-Frame /* + */
DO:
       for each x_parts :
          if length (rid-list) >= 31000 then leave.
        { gbl/markstrn.i x_parts rid-list }
       end.
        g-log = BROWSE-2:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = BROWSE-2:select-next-row ().
            apply "VALUE-CHANGED" to BROWSE-2 in frame {&frame-name}.
        end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-report
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-report Dialog-Frame
ON CHOOSE OF b-report IN FRAME Dialog-Frame /* Отчет */
DO:
 case p-mode :
  when "srok" then do:
    run rep/g-sroki.p (parparentproc) .
  end.
  when "defect" then do:
    run rep/g-defect.p (parparentproc) .
  end.
 end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Ф */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_b-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_b-code Dialog-Frame
ON CHOOSE OF MENU-ITEM m_b-code /* По списку кодов */
DO:
define buffer doc_parts for ub.parts  .
run str/bb-list.w (
                   input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input '').

 for each bb-list :
        for each temp-obj,
            each doc_parts no-lock where
                 doc_parts.in-code    = bb-list.in-code and
                 doc_parts.part-code  = bb-list.part-code and
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.artic      = bb-list.artic and
                 doc_parts.prod-type  = bb-list.prod-type and
                 doc_parts.prod-code  = bb-list.prod-code and
                 doc_parts.out-code   = {&free-code}
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .

            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.

 end.
 run OpenBr in this-procedure (yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_b-code-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_b-code-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_b-code-2 /* По списку кодов */
DO:
define buffer doc_parts for ub.parts  .
run str/bb-list.w (
                   input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input '').

 for each bb-list :
       for each temp-obj ,
           each doc_parts no-lock where
                 doc_parts.in-code    = bb-list.in-code and
                 doc_parts.part-code  = bb-list.part-code and
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.artic      = bb-list.artic and
                 doc_parts.prod-type  = bb-list.prod-type and
                 doc_parts.prod-code  = bb-list.prod-code and
                 doc_parts.out-code   = {&free-code}
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .

            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.

 end.
 run OpenBr in this-procedure (yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ep Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ep /* Возврат поставщику */
DO:
  run make-xx-part .
  run str/epimport.p
  ( parparentproc ,
    this-procedure,
    {&TDEDT_Ras_Vnesh_VP},
    input TABLE xx_parts
    ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "от str/epimport.p"
         view-as alert-box error
       .
    end.
  message return-value view-as alert-box information .
  run ini-proc.
  run my_enable.
  run OpenBr in this-procedure (yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ev Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ev /* Внутренний расход */
DO:
  run make-xx-part .
  run str/epimport.p
  ( parparentproc ,
    this-procedure,
    {&TDEDT_Ras_Perem},
    input TABLE xx_parts
    ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "от str/epimport.p"
         view-as alert-box error
       .
    end.
  if return-value <> "" then do:
     message return-value view-as alert-box information .
  end.
  run ini-proc.
  run my_enable.
  run OpenBr in this-procedure (yes, no, '':U).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_goods Dialog-Frame
ON CHOOSE OF MENU-ITEM m_goods /* По списку товаров */
DO:
define buffer doc_parts for ub.parts  .

run str/gds-list.w ( input parparentproc , input v-host-code, input p-obj-type, input p-obj-code ).
for each gds-list :
       for each temp-obj,
           each doc_parts no-lock where
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.artic      = gds-list.artic and
                 doc_parts.prod-type  = gds-list.prod-type and
                 doc_parts.prod-code  = gds-list.prod-code and
                 doc_parts.out-code   = {&free-code}
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .

            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
end.
run OpenBr in this-procedure (yes, no, '':U).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_goods-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_goods-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_goods-2 /* По списку товаров */
DO:
define buffer doc_parts for ub.parts  .

run str/gds-list.w ( input parparentproc , input v-host-code, input p-obj-type, input p-obj-code ).
for each gds-list :
        for each temp-obj,
            each doc_parts no-lock where
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.artic      = gds-list.artic and
                 doc_parts.prod-type  = gds-list.prod-type and
                 doc_parts.prod-code  = gds-list.prod-code and
                 doc_parts.out-code   = {&free-code}
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .

            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
end.
run OpenBr in this-procedure (yes, no, '':U).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_iv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_iv Dialog-Frame
ON CHOOSE OF MENU-ITEM m_iv /* Внутренний приход (запрос) */
DO:
  run make-xx-part .
  run str/epimport.p
  ( parparentproc ,
    this-procedure,
    {&TDEDT_Pri_Perem},
    input TABLE xx_parts
    ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "от str/epimport.p"
         view-as alert-box error
       .
    end.
  if return-value <> "" then do:
     message return-value view-as alert-box information .
  end.

run ini-proc.
run my_enable.
run OpenBr in this-procedure (yes, no, '':U).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_pri
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_pri Dialog-Frame
ON CHOOSE OF MENU-ITEM m_pri /* По списку ПН */
DO:
  define variable loc-ref-list as character no-undo .
  run str/all-docs.w
 ( input  parparentproc
  ,input   v-host-code /*host-code*/
  ,input   p-obj-type  /*obj-type*/
  ,input   p-obj-code  /*obj-code*/
  ,input  "status-all":U
  ,input  {&fact}
  ,input  {&income}
  ,input  ?
  ,input  no
  ,input  "b-mark,b-sel":U
  ,input  {&TDEDT_Pri_Vnesh}
  ,input  false
  ,input  ?
  ,output loc-ref-list
  ).
if loc-ref-list = ?  or loc-ref-list = '' then return.

define buffer buf_trn-doc for ub.trn-doc  .
define buffer doc_parts for ub.parts  .
define buffer buf_doc-line for ub.doc-line  .
define variable i as integer   no-undo .

do i = 1 to num-entries(loc-ref-list) :
  for each buf_trn-doc no-lock where recid (buf_trn-doc) = int(entry(i,loc-ref-list)) :
      for each buf_doc-line no-lock where
               buf_doc-line.doc-code = buf_trn-doc.doc-code
        :
        for each doc_parts no-lock where
                 doc_parts.in-code    = buf_trn-doc.doc-code and
                 doc_parts.obj-type   = buf_trn-doc.obj-type and
                 doc_parts.obj-code   = buf_trn-doc.obj-code and
                 doc_parts.artic      = buf_doc-line.artic and
                 doc_parts.prod-type  = buf_doc-line.prod-type and
                 doc_parts.prod-code  = buf_doc-line.prod-code and
                 doc_parts.out-code   = {&free-code}
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .

            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
      end.
  end.
end.

run OpenBr in this-procedure (yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_pri-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_pri-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_pri-2 /* По списку ПН */
DO:
  define variable loc-ref-list as character no-undo .
  run str/all-docs.w
 ( input  parparentproc
  ,input   v-host-code /*host-code*/
  ,input   p-obj-type  /*obj-type*/
  ,input   p-obj-code  /*obj-code*/
  ,input  "status-all":U
  ,input  {&fact}
  ,input  {&income}
  ,input  ?
  ,input  no
  ,input  "b-mark,b-sel":U
  ,input  {&TDEDT_Pri_Vnesh}
  ,input  false
  ,input  ?
  ,output loc-ref-list
  ).
if loc-ref-list = ?  or loc-ref-list = '' then return.

define buffer buf_trn-doc for ub.trn-doc  .
define buffer doc_parts for ub.parts  .
define buffer buf_doc-line for ub.doc-line  .
define variable i as integer   no-undo .

do i = 1 to num-entries(loc-ref-list) :
  for each buf_trn-doc no-lock where recid (buf_trn-doc) = int(entry(i,loc-ref-list)) :
      for each buf_doc-line no-lock where
               buf_doc-line.doc-code = buf_trn-doc.doc-code
        :
        for each doc_parts no-lock where
                 doc_parts.in-code    = buf_trn-doc.doc-code and
                 doc_parts.obj-type   = buf_trn-doc.obj-type and
                 doc_parts.obj-code   = buf_trn-doc.obj-code and
                 doc_parts.artic      = buf_doc-line.artic and
                 doc_parts.prod-type  = buf_doc-line.prod-type and
                 doc_parts.prod-code  = buf_doc-line.prod-code and
                 doc_parts.out-code   = {&free-code}
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .

            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
      end.
  end.
end.

run OpenBr in this-procedure (yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_serii
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_serii Dialog-Frame
ON CHOOSE OF MENU-ITEM m_serii /* По номеру серии */
DO:

define variable v-parts-code as character no-undo .
define buffer doc_parts for ub.parts  .
      run gbl/d-prompt.w
        ( 'title=':U + "Введите номер серии партии" + '\':U
        + 'type=character':U
        ,input-output v-parts-code
        ).
      if return-value = 'false':U
      then do:
        return . /* --->>>--- */
      end.
  if v-parts-code = "" then do:
     message "Нельзя вводить пустое значение серии" view-as alert-box information .
     return .
  end.

   run waitfram-show in this-procedure ( substitute("Поиск товаров по серии  &1" ,v-parts-code )) .
      for each temp-obj,
         each doc_parts no-lock where
                 doc_parts.part-code  = v-parts-code and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.out-code   = {&free-code}
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .

            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
     run waitfram-hide.
run OpenBr in this-procedure (yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_we
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_we Dialog-Frame
ON CHOOSE OF MENU-ITEM m_we /* Списание */
DO:
  run make-xx-part .
  run str/epimport.p
  ( parparentproc ,
    this-procedure,
    {&TDEDT_Spi_Vnesh},
    input TABLE xx_parts
    ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "от str/epimport.p"
         view-as alert-box error
       .
    end.
  message return-value view-as alert-box information .
  run ini-proc.
  run my_enable.
  run OpenBr in this-procedure (yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-obj Dialog-Frame
ON VALUE-CHANGED OF R-obj IN FRAME Dialog-Frame
DO:
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-sort Dialog-Frame
ON VALUE-CHANGED OF R-sort IN FRAME Dialog-Frame
DO:
  assign r-sort.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-sort-pole
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-sort-pole Dialog-Frame
ON LEAVE OF v-sort-pole IN FRAME Dialog-Frame
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-sort-pole Dialog-Frame
ON RETURN OF v-sort-pole IN FRAME Dialog-Frame
DO:
 assign r-sort v-sort-pole.
  case r-sort:
  when 1 then do:
     run proc-find-b-code in this-procedure(no, v-sort-pole) no-error.
  end.
  when 2 then do:
     run proc-find-part-code in this-procedure(no, v-sort-pole) no-error.
  end.
  when 3 then do:
     run proc-find-artic in this-procedure(no, v-sort-pole) no-error.
  end.
  when 4 then do:
     run proc-find-name in this-procedure(no, v-sort-pole) no-error.
  end.
  end case.
  return no-apply.
END.

ON CTRL-J  OF v-sort-pole IN FRAME Dialog-Frame
do:
 assign r-sort v-sort-pole .
  case r-sort:
  when 1 then do:
    run proc-find-b-code in this-procedure(yes, v-sort-pole) no-error.
  end.
  when 2 then do:
    run proc-find-part-code in this-procedure(yes, v-sort-pole) no-error.
  end.
  when 3 then do:
    run proc-find-artic in this-procedure(yes, v-sort-pole) no-error.
  end.
  when 4 then do:
    run proc-find-name in this-procedure(yes, v-sort-pole) no-error.
  end.
  end case.
  if error-status:error then return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
b-make-trn:menu-mouse = 1.
b-make-add:menu-mouse = 1.
{ gbl/brwrefre.i  "run OpenBr in this-procedure (yes, no, '':U)." }
{ gbl/f2.i {&browse-name} goods-recid gds-rec-proc parparentproc  }
{ gbl/setfltnm.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

{ gbl/srt-clmd.i
  &browse-name      = "{&browse-name}"
  &frame-name       = "{&frame-name}"
  &table-name       = "x_parts"
  &label-clmn_1     = "{&col-l1}"
  &label-clmn_2     = "{&col-l2}"
  &label-clmn_3     = "{&col-l3}"
  &label-clmn_4     = "{&col-l4}"
  &label-clmn_5     = "{&col-l5}"
  &label-clmn_6     = "{&col-l6}"
  &label-clmn_7     = "{&col-l7}"
  &label-clmn_8     = "{&col-l8}"
  &label-clmn_9     = "{&col-l9}"
  &label-clmn_10    = "{&col-l10}"
  &label-clmn_11    = "{&col-l11}"
  &label-clmn_12    = "{&col-l12}"
  &label-clmn_13    = "{&col-l13}"
  &label-clmn_14    = "{&col-l14}"
  &label-clmn_15    = "{&col-l15}"
  &label-clmn_16    = "{&col-l16}"
  &label-clmn_17    = "{&col-l17}"
  &label-clmn_18    = "{&col-l18}"
  &sort-clmn_1      = "{&cop-l1}"
  &dyn_sort-clmn_1  = "{&dyn_cop-l1}"
  &sort-clmn_2      = "{&cop-l2}"
  &sort-clmn_3      = "{&cop-l3}"
  &sort-clmn_4      = "{&cop-l4}"
  &sort-clmn_5      = "{&cop-l5}"
  &sort-clmn_6      = "{&cop-l6}"
  &sort-clmn_7      = "{&cop-l7}"
  &sort-clmn_8      = "{&cop-l8}"
  &sort-clmn_9      = "{&cop-l9}"
  &sort-clmn_10     = "{&cop-l10}"
  &sort-clmn_11     = "{&cop-l11}"
  &sort-clmn_12     = "{&cop-l12}"
  &sort-clmn_13     = "{&cop-l13}"
  &sort-clmn_14     = "{&cop-l14}"
  &sort-clmn_15     = "{&cop-l15}"
  &sort-clmn_16     = "{&cop-l16}"
  &sort-clmn_17     = "{&cop-l17}"
  &sort-clmn_18     = "{&cop-l18}"
  &dyn_sort-clmn_18 = "{&dyn_cop-l18}"
&open-query           = "run OpenBr (yes, no, '':U)."
&open-query-otherwise = "run OpenBr (yes, no, '':U)."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "no"
&mv-brw-default       = "no" }



MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run ini-proc.
  run my_enable.
  run OpenBR in this-procedure (yes, no, '':U).
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_choice-obj Dialog-Frame
PROCEDURE cb_choice-obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define output parameter p-obj-type as character no-undo .
define output parameter p-obj-code as integer   no-undo .
define output parameter p-obj-name as character no-undo .

define buffer Post-clients for ub.clients  .
define variable rid-list as character no-undo .
define variable v-hostcode as integer   no-undo .

  run ref/cli-all.w ( input parParentProc, input "b-sel", {&g___object} , ?, ?, ?, ?, ?, output  rid-list ) no-error .
  if num-entries (rid-list) < 1 then return error return-value .
  find first post-clients no-lock  where recid (post-clients) = integer(rid-list)  no-error.
  if available post-clients then do:
      assign
          p-obj-code = Post-clients.obj-code
          p-obj-type = Post-clients.obj-type
          p-obj-name = post-clients.obj-name
      .

      { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-hostcode
        }
        if v-hostcode <> v-cntxt-host-code-obj then do:
            assign
                p-obj-code = ?
                p-obj-type = ?
                p-obj-name = ?
            .
          return error "Не верно выбран объект для перемещения, он должен быть той же фирмы " .
        end.
    end.
    else do:
          assign
              p-obj-code = ?
              p-obj-type = ?
              p-obj-name = ?
        .
        return error  "Не верно выбран объект" .
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY R-sort v-sort-pole R-obj FILL-IN-1 FILL-IN-2 mark-num
      WITH FRAME Dialog-Frame.
  ENABLE BROWSE-2 b-Cancel b-add-2 b-add b-del-2 b-del b-impotr-www b-make-trn
         b-report b-make-add b-clear b-sch b-print b-help R-sort v-sort-pole
         R-obj b-mark b-mark-all FILL-IN-1 b-del-mark FILL-IN-2 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gds-rec-proc Dialog-Frame
PROCEDURE gds-rec-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  gds-rec = recid (buf_goods) no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ini-proc Dialog-Frame
PROCEDURE ini-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-today as date      no-undo .
define variable v-time as integer   no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-pharm as character no-undo .
define variable var-type as character no-undo .
rid-list = "".
  r-obj = p-obj.
  display r-obj with frame {&frame-name} .

empty temp-table temp-obj.
if r-obj = 1 then do:
for each ub.clients no-lock where ub.clients.host-code <> 0 and ub.clients.host-code <> ? :
  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT ub.clients.obj-type,
     INPUT ub.clients.obj-code,
     input {&attr-pharm},
     OUTPUT v-pharm,
     OUTPUT var-type).
  IF v-pharm = "yes":u THEN DO:
    create temp-obj.
    assign
      temp-obj.obj-code = ub.clients.obj-code
      temp-obj.obj-type = ub.clients.obj-type
    .
  end.
end.
end.
else do:
    create temp-obj.
    assign
      temp-obj.obj-code = p-obj-code
      temp-obj.obj-type = p-obj-type
    .
end.


{&cop-l2}:read-only in browse {&browse-name} = true .
x_parts.artic:resizable in browse {&browse-name}   = true .
x_parts.part-code:resizable in browse {&browse-name}   = true .
buf_goods.gds-name:resizable in browse {&browse-name}   = true .
buf_goods.gds-name:width in browse {&browse-name}       = 20 .
vf-obj-name:resizable in browse {&browse-name}   = true .
vf-obj-name:width in browse {&browse-name}       = 14 .
vf-cli-name:resizable in browse {&browse-name}   = true .
vf-cli-name:width in browse {&browse-name}       = 25 .


  empty temp-table thbjattr_thbj-attr .

 v-srok = 0.
 case p-mode :
 when "defect" then do:
    if R-obj = 1 /*все*/ then do:
       frame {&frame-name}:TITLE = substitute("ВСЕ Фальсифицированные и бракованные партии ") .
    end.
    else do:
       frame {&frame-name}:TITLE = substitute("Фальсифицированные и бракованные партии на объекте &1&2",p-obj-type,p-obj-code) .
    end.
    run make-defect in this-procedure .
  end.
 when "add-new-fib" then do:
     if R-obj = 1 /*все*/ then do:
        frame {&frame-name}:TITLE = substitute("Создание  списка парий  по всем объектам") .
     end.
     else do:
        frame {&frame-name}:TITLE = substitute("Создание  списка парий   на объекте  &1&2",p-obj-type,p-obj-code) .
     end.
     run make-new in this-procedure .
  end.
  when "srok" then do:
    run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-ass-obj}
      ,input {&attr-Ass-obj_crit-srokgod}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-srok
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .

        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        run godendo-offset-to-date in this-procedure (
              input  v-today
            , input  v-srok
            , output v-srok-date
        ).
        if R-obj = 1 /*все*/ then do:
           frame {&frame-name}:TITLE = substitute ("Товары с истекающим сроком годности до &1 ", string (v-srok-date,"99/99/9999" )).
        end.
        else do:
           frame {&frame-name}:TITLE = substitute ("Товары с истекающим сроком годности до &3 на объекте &1&2", p-obj-type, p-obj-code, string (v-srok-date,"99/99/9999" )).
        end.
        run make-srok in this-procedure .
     end.
  end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-defect Dialog-Frame
PROCEDURE make-defect :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
empty temp-table x_parts.
define buffer buf_parts for ub.parts  .
for each temp-obj,
   each buf_parts no-lock where
           buf_parts.obj-type = temp-obj.obj-type and
           buf_parts.obj-code = temp-obj.obj-code and
           buf_parts.defect = logical({&FiB}) and
           buf_parts.out-code = {&free-code} :
      create x_parts.
      buffer-copy buf_parts to x_parts.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-new Dialog-Frame
PROCEDURE make-new :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
empty temp-table x_parts.
define buffer buf_parts for ub.parts  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-srok Dialog-Frame
PROCEDURE make-srok :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
empty temp-table x_parts.
define buffer buf_parts for ub.parts  .

 for each temp-obj,
     each buf_parts no-lock where
           buf_parts.obj-type = temp-obj.obj-type and
           buf_parts.obj-code = temp-obj.obj-code and
           buf_parts.last-date <= v-srok-date and
           buf_parts.out-code = {&free-code} :
      create x_parts.
      buffer-copy buf_parts to x_parts.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  display FILL-IN-1 FILL-IN-2 WITH FRAME Dialog-Frame.
  ENABLE b-Cancel b-mark b-add b-add-2 b-del b-del-2 b-impotr-www b-make-trn  b-sch
         b-print b-help BROWSE-2 b-mark-all b-del-mark
         r-sort v-sort-pole b-report
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

 /* КНОПОЧКИ*/
 case p-mode :
 when "defect" then do:
  hide b-clear b-make-add in frame {&frame-name} .
  end.
 when "add-new-fib" then do:
     hide b-del b-del-2 b-add b-add-2 b-make-trn b-impotr-www b-mark b-mark-all  b-del-mark b-sch b-print b-report  in frame {&frame-name} .
     enable b-clear b-make-add with frame {&frame-name} .
  end.
  when "srok" then do:
    hide b-del b-del-2 b-add b-add-2 b-make-trn b-impotr-www b-mark b-del-mark b-mark-all b-clear b-make-add   in frame {&frame-name} .
  end.
  end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable v-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
{&SetCursorWait}

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


&scop flt-open-open-query OPEN QUERY BROWSE-2 FOR EACH x_parts no-lock

&scop flt-open-dyn_open-query  FOR EACH x_parts

&scop flt-open-query-handle query BROWSE-2:handle

&scop flt-open-find-buffer-name x_parts

&scop flt-open-open-query-tail      , EACH Buf_goods OF x_parts NO-LOCK, ~
  EACH Buf_bar-code WHERE ~
  Buf_bar-code.gds-code  = Buf_goods.gds-code and  ~
  Buf_bar-code.in-code   = x_parts.in-code and  ~
  Buf_bar-code.part-code = x_parts.part-code

&scop flt-open-dyn_open-query-tail  substitute(', EACH Buf_goods OF x_parts NO-LOCK, ~
  EACH Buf_bar-code WHERE ~
  BUF_bar-code.gds-code  = BUF_goods.gds-code and  ~
  BUF_bar-code.in-code   = x_parts.in-code and  ~
  BUF_bar-code.part-code = x_parts.part-code   ~
  ' , ~{&double-quote~}  )


&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          x_parts

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer x_parts for x_parts.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .



  { gbl/fltopend.i
        &where-cond = " true = true  "
        &use-ind    = " "
        &by         = " " }


if not p-open-query then do:
 reposition {&browse-name}  to recid doc-rec no-error.
 end.
if not p-open-query and v-fltopend-rowid[1] <> ? then do:
   query {&browse-name}:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
end.

{&SetCursorNo}




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'parts'
  join-tbl = 'x_parts'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
  run fltfield-add in this-procedure('in-code', 'Номер ПН', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('part-code', 'Номер/Серия партии', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-type{&delim-flt}supp-code', 'Поставщик', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('qnty', 'Кол.док.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-qnty', 'Факт.кол.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', 'Дата', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pay-code', 'Код Оплаты', 'pay',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('whole-send-news', 'ФиБ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-base', 'Цена (вал)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-rubl', 'Цена ({&abbr_rub})', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-cli', 'Цена пост. (вал)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-code', 'Валюта пост.', 'curr',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('dop', 'Цена производителя', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cst-code', 'ГТД', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('last-date', 'Срок годности', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('vat-type', 'Тип НДС', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('vat-pc', '% НДС', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Договор', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pl-code', 'Место хранения', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run OpenBr in this-procedure (yes, no, '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-artic Dialog-Frame
PROCEDURE proc-find-artic :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter p-var    as char no-undo.
  doc-rec = ? .
  if par-next = true
  then find next   x_parts no-lock where  x_parts.artic = p-var no-error  .
  else find first  x_parts no-lock where  x_parts.artic = p-var no-error  .
  if available x_parts then doc-rec = recid(x_parts) .
  reposition {&browse-name} to recid doc-rec no-error .

  if not error-status :error then apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-b-code Dialog-Frame
PROCEDURE proc-find-b-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter p-var    as char no-undo.
define variable v-var1 as integer   no-undo .
v-var1 = int (p-var) no-error .

run OpenBr in this-procedure ( false  , par-next,  substitute(" and buf_bar-code.b-code = &1 " , v-var1 )) .
  /* substitute(', EACH Buf_goods OF x_parts NO-LOCK, ~
  EACH Buf_bar-code WHERE ~
  BUF_bar-code.gds-code  = BUF_goods.gds-code and  ~
  BUF_bar-code.in-code   = x_parts.in-code and  ~
  BUF_bar-code.part-code = x_parts.part-code  and buf_bar-code.b-code = &1  ' ,  v-var1 ) ). */


apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name Dialog-Frame
PROCEDURE proc-find-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter p-var    as character no-undo.
  doc-rec = ? .
  if par-next = true
  then find next
      x_parts no-lock where can-find
      ( first buf_goods no-lock  where
            buf_goods.artic     = x_parts.artic and
            buf_goods.prod-type = x_parts.prod-type and
            buf_goods.prod-code = x_parts.prod-code and
            buf_goods.gds-name begins p-var )
            no-error  .
  else find first
      x_parts no-lock where can-find (
      first buf_goods no-lock  where
            buf_goods.artic     = x_parts.artic and
            buf_goods.prod-type = x_parts.prod-type and
            buf_goods.prod-code = x_parts.prod-code and
            buf_goods.gds-name begins p-var )
            no-error  .
  if available x_parts then doc-rec = recid(x_parts) .
  reposition {&browse-name} to recid doc-rec no-error .

  if not error-status :error then apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-part-code Dialog-Frame
PROCEDURE proc-find-part-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter p-var    as char no-undo.

  doc-rec = ? .
  if par-next = true
  then find next   x_parts no-lock where  x_parts.part-code = p-var no-error  .
  else find first  x_parts no-lock where  x_parts.part-code = p-var no-error  .
  if available x_parts then doc-rec = recid(x_parts) .
  reposition {&browse-name} to recid doc-rec no-error .

  if not error-status :error then apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
DEFINE PARAMETER BUFFER bf_parts for x_parts.
define buffer buf_parts for ub.parts  .

if p-mode = "defect" or true  then do:

find first  buf_parts exclusive-lock where
            buf_parts.obj-code   = bf_parts.obj-code and
            buf_parts.obj-type   = bf_parts.obj-type  and
            buf_parts.artic      = bf_parts.artic  and
            buf_parts.prod-type  = bf_parts.prod-type  and
            buf_parts.prod-code  = bf_parts.prod-code  and
            buf_parts.out-code   = bf_parts.out-code  and
            buf_parts.in-code    = bf_parts.in-code  and
            buf_parts.part-code  = bf_parts.part-code  no-error .
  if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      return error return-value .
  end.

  if buf_parts.defect <> bf_parts.defect then do:
     buf_parts.defect = bf_parts.defect .
  end.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-xx-part W-Win
PROCEDURE make-xx-part :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
empty temp-table xx_parts.
  if num-entries ( rid-list ) = 0  then do:
     for each x_parts :
        create xx_parts.
        buffer-copy x_parts to  xx_parts.
     end.
  end.
  else do:
     for each x_parts :
       if lookup ( string(recid(x_parts)) , rid-list ) > 0 then do:
          create xx_parts .
          buffer-copy x_parts to  xx_parts .
       end.
     end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME