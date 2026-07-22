&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE x_add-doc NO-UNDO LIKE add-doc.
DEFINE BUFFER x_add-line FOR add-line.
DEFINE BUFFER x_add-trn FOR add-trn.
DEFINE BUFFER x_gds-add-charges FOR gds-add-charges.
DEFINE BUFFER x_goods FOR goods.
DEFINE BUFFER x_trn-doc FOR trn-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Документ Дополнительных расходов

Автор: Чернова Светлана Александровна
Дата создания: 06/18/07
Author: Svetlana Chernova
Creation date: 06/18/07


*/
/*------------------------------------------------------------------------
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter        parparentproc  as widget-handle no-undo.
define input-output parameter p-recid        as recid     no-undo . /* recid add-doc */
define input parameter        p-mode         as character no-undo .
define input parameter        p-doc-code     as character no-undo . /* trn-doc.doc-code для создания из ПН */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Документ Дополнительных расходов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ str/adddocfn.i }
{ gbl/getsect.i def }
define variable v-doc-code as character no-undo . /* № add-doc */
define variable v-curr-abbr as character no-undo .
define variable ref-rec as recid no-undo.
define variable varvat-type  as integer   no-undo .
define variable varvat-type-type            as   character initial ?    no-undo.
define variable varvat-type-def             as   character              no-undo.
define variable v-recid as recid no-undo .
define variable v-mode-exit  as character no-undo .
DEFINE TEMP-TABLE old_add-line NO-UNDO LIKE ub.add-line.

empty temp-table old_add-line.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-docsa

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x_add-line x_goods x_gds-add-charges ~
x_add-trn x_trn-doc x_add-doc

/* Definitions for BROWSE BR-docsa                                      */
&Scoped-define FIELDS-IN-QUERY-BR-docsa x_goods.artic x_add-line.gds-code x_goods.gds-name x_add-line.cli-type + string(x_add-line.cli-code) x_add-line.contract-code x_add-line.sum-base x_add-line.sum-rubl x_add-line.vat-pc alg-name( buffer x_gds-add-charges)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docsa
&Scoped-define SELF-NAME BR-docsa
&Scoped-define QUERY-STRING-BR-docsa FOR EACH x_add-line OF x_add-doc NO-LOCK, ~
             EACH x_goods OF x_add-line NO-LOCK, ~
             EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-docsa OPEN QUERY {&SELF-NAME} FOR EACH x_add-line OF x_add-doc NO-LOCK, ~
             EACH x_goods OF x_add-line NO-LOCK, ~
             EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-docsa x_add-line x_goods ~
x_gds-add-charges
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docsa x_add-line
&Scoped-define SECOND-TABLE-IN-QUERY-BR-docsa x_goods
&Scoped-define THIRD-TABLE-IN-QUERY-BR-docsa x_gds-add-charges


/* Definitions for BROWSE BROWSE-7                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-7 x_add-trn.trn-doc-code (SUBSTRING(x_trn-doc.status_,1,4) + STRING(x_trn-doc.flag_,"+/-")) x_trn-doc.doc-date x_trn-doc.cli-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-7
&Scoped-define SELF-NAME BROWSE-7
&Scoped-define QUERY-STRING-BROWSE-7 FOR EACH x_add-trn OF x_add-doc NO-LOCK, ~
             EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-7 OPEN QUERY {&SELF-NAME} FOR EACH x_add-trn OF x_add-doc NO-LOCK, ~
             EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-7 x_add-trn x_trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-7 x_add-trn
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-7 x_trn-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame x_add-doc.base-rate ~
x_add-doc.base-scale x_add-doc.doc-date x_add-doc.fact-date ~
x_add-doc.shift-date x_add-doc.shift-name x_add-doc.shift-num ~
x_add-doc.VAT-type x_add-doc.obj-type x_add-doc.obj-code x_add-doc.doc-code ~
x_add-doc.sum-base x_add-doc.VAT-base x_add-doc.sum-rubl x_add-doc.VAT-rubl
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame x_add-doc.base-rate ~
x_add-doc.base-scale x_add-doc.doc-date x_add-doc.fact-date ~
x_add-doc.shift-date x_add-doc.shift-name x_add-doc.shift-num ~
x_add-doc.VAT-type x_add-doc.obj-type
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame x_add-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame x_add-doc
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-docsa}~
    ~{&OPEN-QUERY-BROWSE-7}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH x_add-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH x_add-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame x_add-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame x_add-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS x_add-doc.base-rate x_add-doc.base-scale ~
x_add-doc.doc-date x_add-doc.fact-date x_add-doc.shift-date ~
x_add-doc.shift-name x_add-doc.shift-num x_add-doc.VAT-type ~
x_add-doc.obj-type
&Scoped-define ENABLED-TABLES x_add-doc
&Scoped-define FIRST-ENABLED-TABLE x_add-doc
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-print B-Help B-trn B-trn-del ~
B-trn-sel BROWSE-7 r-sht B-add B-lkp B-chg B-del BR-docsa f-summa f-vat
&Scoped-Define DISPLAYED-FIELDS x_add-doc.base-rate x_add-doc.base-scale ~
x_add-doc.doc-date x_add-doc.fact-date x_add-doc.shift-date ~
x_add-doc.shift-name x_add-doc.shift-num x_add-doc.VAT-type ~
x_add-doc.obj-type x_add-doc.obj-code x_add-doc.doc-code x_add-doc.sum-base ~
x_add-doc.VAT-base x_add-doc.sum-rubl x_add-doc.VAT-rubl
&Scoped-define DISPLAYED-TABLES x_add-doc
&Scoped-define FIRST-DISPLAYED-TABLE x_add-doc
&Scoped-Define DISPLAYED-OBJECTS v-obj-name f-summa f-vat

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить Дополнительный расход"
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "&p"
     SIZE 3 BY 1 TOOLTIP "Печать документа"
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-trn
     LABEL "&+ПН"
     SIZE 5.5 BY 1 TOOLTIP "Добавить Приходные накладные в список"
     BGCOLOR 8 .

DEFINE BUTTON B-trn-del
     LABEL "&-ПН"
     SIZE 5.5 BY 1 TOOLTIP "Удалить приходные накладные из списка"
     BGCOLOR 8 .

DEFINE BUTTON B-trn-sel
     LABEL "Просмотр ПН"
     SIZE 13.5 BY 1 TOOLTIP "Просмотр приходной накладной"
     BGCOLOR 8 .

DEFINE BUTTON r-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON r-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON r-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE VARIABLE f-summa AS CHARACTER FORMAT "X(256)":U INITIAL " Сумма"
      VIEW-AS TEXT
     SIZE 7.5 BY .79
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-vat AS CHARACTER FORMAT "X(256)":U INITIAL " НДС"
      VIEW-AS TEXT
     SIZE 5 BY .79
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE scr-curr-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY .79
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 26 BY .79
     FGCOLOR 1  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-docsa FOR
      x_add-line,
      x_goods,
      x_gds-add-charges SCROLLING.

DEFINE QUERY BROWSE-7 FOR
      x_add-trn,
      x_trn-doc SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      x_add-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docsa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docsa Dialog-Frame _FREEFORM
  QUERY BR-docsa NO-LOCK DISPLAY
      x_goods.artic FORMAT "X(16)":U
      x_add-line.gds-code FORMAT "999999999":U
      x_goods.gds-name FORMAT "X(48)":U
      x_add-line.cli-type + string(x_add-line.cli-code) FORMAT "X(11)":U
      x_add-line.contract-code FORMAT ">>>>>>>>>>":U  label "Договор"
      x_add-line.sum-base FORMAT "->>>,>>>,>>9.99":U
      x_add-line.sum-rubl FORMAT "->>>,>>>,>>9.99":U
      x_add-line.vat-pc FORMAT "->>,>>9.99":U
      alg-name( buffer x_gds-add-charges) label "Алгоритм" format "x(30)":u
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.5 BY 10 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-7 Dialog-Frame _FREEFORM
  QUERY BROWSE-7 NO-LOCK DISPLAY
      x_add-trn.trn-doc-code FORMAT "X(14)"
      (SUBSTRING(x_trn-doc.status_,1,4) + STRING(x_trn-doc.flag_,"+/-")) FORMAT "X(5)":U COLUMN-LABEL "Статус"
      x_trn-doc.doc-date FORMAT "99/99/99":U
      x_trn-doc.cli-name FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 43 BY 9 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-print AT ROW 1 COL 91.38 WIDGET-ID 72
     B-Help AT ROW 1 COL 94.5
     x_add-doc.exch-rate AT ROW 3 COL 32.5 COLON-ALIGNED WIDGET-ID 14
          VIEW-AS FILL-IN
          SIZE 10 BY 1 TOOLTIP "Курс валюты документа"
          FGCOLOR 4
     x_add-doc.exch-scale AT ROW 3 COL 42.63 COLON-ALIGNED NO-LABEL WIDGET-ID 16
          VIEW-AS FILL-IN
          SIZE 5 BY 1
          FGCOLOR 4
     r-acc AT ROW 3 COL 49.63 WIDGET-ID 54
     B-trn AT ROW 3 COL 54 WIDGET-ID 50
     B-trn-del AT ROW 3 COL 59.5 WIDGET-ID 66
     B-trn-sel AT ROW 3 COL 65 WIDGET-ID 68
     x_add-doc.exch-code AT ROW 3.25 COL 8.5 COLON-ALIGNED WIDGET-ID 10
          LABEL "Валюта"
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "Валюта документа"
          FGCOLOR 4
     r-currency AT ROW 3.25 COL 14.5 WIDGET-ID 52
     x_add-doc.exch-date AT ROW 3.25 COL 19.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
          VIEW-AS FILL-IN
          SIZE 9 BY 1 TOOLTIP "Дата курса"
     BROWSE-7 AT ROW 4.21 COL 53.75 WIDGET-ID 300
     x_add-doc.base-rate AT ROW 4.33 COL 8.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Баз.вал"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     x_add-doc.base-scale AT ROW 4.33 COL 18.63 COLON-ALIGNED NO-LABEL WIDGET-ID 4
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     x_add-doc.doc-date AT ROW 5.38 COL 8.5 COLON-ALIGNED WIDGET-ID 8
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     x_add-doc.fact-date AT ROW 6.42 COL 8.38 COLON-ALIGNED WIDGET-ID 18
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     x_add-doc.shift-date AT ROW 6.42 COL 25.88 COLON-ALIGNED WIDGET-ID 26
          LABEL "Смена"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     x_add-doc.shift-name AT ROW 6.42 COL 38.13 COLON-ALIGNED WIDGET-ID 28
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     x_add-doc.shift-num AT ROW 6.42 COL 44.38 COLON-ALIGNED WIDGET-ID 30
          LABEL "П"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     r-sht AT ROW 6.42 COL 49.88 WIDGET-ID 56
     x_add-doc.VAT-type AT ROW 11 COL 30 COLON-ALIGNED WIDGET-ID 70
          LABEL "НДС" FORMAT "X(8)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 13.5 BY 1
     B-add AT ROW 12.13 COL 1.75 WIDGET-ID 42
     B-lkp AT ROW 12.13 COL 11.75 WIDGET-ID 44
     B-chg AT ROW 12.13 COL 21.75 WIDGET-ID 46
     B-del AT ROW 12.13 COL 31.75 WIDGET-ID 48
     BR-docsa AT ROW 13.25 COL 1.5 WIDGET-ID 200
     x_add-doc.obj-type AT ROW 2.13 COL 7.25 COLON-ALIGNED WIDGET-ID 22
          LABEL "Объект" FORMAT "X(3)"
           VIEW-AS TEXT
          SIZE 4 BY .79
          FGCOLOR 1
     x_add-doc.obj-code AT ROW 2.13 COL 11.88 COLON-ALIGNED NO-LABEL WIDGET-ID 20 FORMAT ">>>>9"
           VIEW-AS TEXT
          SIZE 6 BY .79
          FGCOLOR 1
     v-obj-name AT ROW 2.13 COL 18.75 COLON-ALIGNED NO-LABEL WIDGET-ID 58
     x_add-doc.doc-code AT ROW 2.13 COL 49.13 COLON-ALIGNED WIDGET-ID 6
          LABEL "№" FORMAT "X(14)"
           VIEW-AS TEXT
          SIZE 15 BY .79
     scr-curr-abbr AT ROW 3.29 COL 15.5 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     f-summa AT ROW 8.42 COL 8.5 COLON-ALIGNED NO-LABEL WIDGET-ID 62
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     f-vat AT ROW 8.42 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     x_add-doc.sum-base AT ROW 9.33 COL 10 COLON-ALIGNED WIDGET-ID 32
          LABEL "Сумма"
           VIEW-AS TEXT
          SIZE 21 BY .67
     x_add-doc.VAT-base AT ROW 9.33 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 36
           VIEW-AS TEXT
          SIZE 20.5 BY .67
     x_add-doc.sum-rubl AT ROW 10.33 COL 10 COLON-ALIGNED WIDGET-ID 34
           VIEW-AS TEXT
          SIZE 20.5 BY .67
     x_add-doc.VAT-rubl AT ROW 10.33 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 38
           VIEW-AS TEXT
          SIZE 20.5 BY .67
     SPACE(45.12) SKIP(12.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ Дополнительных расходов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x_add-doc T "?" NO-UNDO ub add-doc
      TABLE: x_add-line B "?" ? ub add-line
      TABLE: x_add-trn B "?" ? ub add-trn
      TABLE: x_gds-add-charges B "?" NO-UNDO ub gds-add-charges
      TABLE: x_goods B "?" NO-UNDO ub goods
      TABLE: x_trn-doc B "?" ? ub trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-7 exch-date Dialog-Frame */
/* BROWSE-TAB BR-docsa B-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN x_add-doc.base-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN x_add-doc.doc-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN x_add-doc.exch-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN
       x_add-doc.exch-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN x_add-doc.exch-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       x_add-doc.exch-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN x_add-doc.exch-rate IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       x_add-doc.exch-rate:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN x_add-doc.exch-scale IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       x_add-doc.exch-scale:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN x_add-doc.obj-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN x_add-doc.obj-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR BUTTON r-acc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       r-acc:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON r-currency IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       r-currency:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN scr-curr-abbr IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       scr-curr-abbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN x_add-doc.shift-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN x_add-doc.shift-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN x_add-doc.shift-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN x_add-doc.sum-base IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN x_add-doc.sum-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-obj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN x_add-doc.VAT-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN x_add-doc.VAT-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX x_add-doc.VAT-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docsa
/* Query rebuild information for BROWSE BR-docsa
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x_add-line OF x_add-doc NO-LOCK,
      EACH x_goods OF x_add-line NO-LOCK,
      EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-docsa */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-7
/* Query rebuild information for BROWSE BROWSE-7
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x_add-trn OF x_add-doc NO-LOCK,
      EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _JoinCode[2]      = "x_trn-doc.doc-code = Temp-Tables.x_add-trn.trn-doc-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-7 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.x_add-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Документ Дополнительных расходов */
DO:
  if  p-mode <> {&lookup} then do:
      run proc-save in this-procedure no-error.
      if error-status :error then return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Документ Дополнительных расходов */
DO:
  APPLY "choose":U TO b-quit.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:

define variable v-rid-list as character no-undo .
define variable v-cnt      as integer   no-undo .
define variable v-vat-pc   as decimal   no-undo .

define variable v-mode as character no-undo .

define buffer buf_goods for ub.goods  .
define buffer buf_add-line for ub.add-line  .
  run ref/addchls.w
    ( input parParentProc ,
      input 'b-mark,b-sel',
      output v-rid-list
    ) no-error .
    if error-status :error then return .

  do while v-cnt <= num-entries (v-rid-list):
    assign
      v-cnt = v-cnt + 1
      .
    find first buf_goods no-lock where recid(buf_goods) = integer (entry (v-cnt, v-rid-list)) no-error .
    if error-status :error then do:
    next.
    end.
     run str/add-dlu.w
     (  input parParentProc ,
        input this-procedure  ,
        input {&add-def} ,
        input  x_add-doc.doc-code ,
        input  buf_goods.gds-code ,
        input-output v-recid ,
        output       v-mode-exit )
        no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "Ошибка"
            view-as alert-box error
          .
          undo, return .
        end.

        if v-mode-exit <> "" then do:
              find first buf_add-line exclusive-lock where recid ( buf_add-line ) = v-recid no-error .
              if available buf_add-line then do:
                if v-mode-exit = "stop-cycle" then do:
                    leave.
                end.
                if v-mode-exit = "cancel" then do:
                    next.
                end.
              end.
        end.

  end.
  {&OPEN-QUERY-BR-docsa} .
  reposition {&BROWSE-NAME} to recid v-recid no-error .
  apply "entry" to {&browse-name}  in frame {&frame-name} .
  run redisp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  IF NOT AVAILABLE  x_add-line THEN RETURN NO-APPLY.
  v-recid = recid (x_add-line) .

     run str/add-dlu.w
     (  input parParentProc ,
        input this-procedure  ,
        input {&update} ,
        input  x_add-doc.doc-code ,
        input  x_add-line.gds-code ,
        input-output v-recid ,
        output       v-mode-exit )
        no-error .
        if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
          undo, return .
        end.
  {&OPEN-QUERY-BR-docsa} .
  reposition {&BROWSE-NAME} to recid v-recid no-error .
  apply "entry" to {&browse-name}  in frame {&frame-name} .
    run redisp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE  x_add-line THEN RETURN NO-APPLY.
   message "Удалить запись ?"
      view-as alert-box question
      buttons yes-no
      update g-log as log.
  if g-log = false then return no-apply.

  find current x_add-line exclusive-lock   .
  delete x_add-line.
  {&OPEN-QUERY-BR-docsa}
  {&OPEN-QUERY-BROWSE-7}
  apply "entry" to {&browse-name}  in frame {&frame-name} .
   run redisp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
find current x_add-line no-lock no-error .
IF NOT AVAILABLE  x_add-line THEN RETURN NO-APPLY.
  v-recid = recid (x_add-line) .
  run str/add-dlu.w
     (  input parParentProc ,
        input this-procedure  ,
        input {&lookup} ,
        input  x_add-doc.doc-code ,
        input  x_add-line.gds-code ,
        input-output v-recid ,
        output       v-mode-exit )
        no-error .
        if error-status :error then do:
          undo, return .
        end.

  reposition {&browse-name} to recid v-recid no-error .
  apply "entry" to {&browse-name}  in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* p */
DO:
  /* */

  if not available x_add-doc then return .
  run rep/r-addu.p ( parparentproc, x_add-doc.doc-code ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отмена */
DO:
if p-mode = {&lookup} then return .
define variable v-k as integer   no-undo .
  message "Вы действительно хотите отменить все изменения ?"
  view-as alert-box question
  button yes-no
  update v-ok as log
  .
  if v-ok = false then return no-apply.

  if p-mode = {&update} then do:
      for each ub.add-line exclusive-lock where
              ub.add-line.doc-code  = v-doc-code :
          delete ub.add-line .
      end.

      for each old_add-line where
            old_add-line.doc-code  = v-doc-code :
            create  ub.add-line .
            buffer-copy old_add-line to ub.add-line .
      end.
      p-recid = ?.
  end.
  if p-mode = {&add-def} then do:
      for each ub.add-line exclusive-lock where
              ub.add-line.doc-code  = v-doc-code :
          delete ub.add-line .
      end.
      for each ub.add-doc exclusive-lock where
              ub.add-doc.doc-code  = v-doc-code :
          delete ub.add-doc .
      end.

  end.
APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn Dialog-Frame
ON CHOOSE OF B-trn IN FRAME Dialog-Frame /* +ПН */
DO:
  define buffer buf_trn-doc for ub.trn-doc  .
  define variable loc-ref-list as character no-undo .
  run str/all-docs.w
 ( input  parparentproc
 ,input   x_add-doc.host-code /*host-code*/
 ,input   x_add-doc.obj-type  /*obj-type*/
 ,input   x_add-doc.obj-code  /*obj-code*/
 ,input  "status-all":U
 ,input  {&wayb}
 ,input  {&income}
 ,input  ?
 ,input  no
 ,input  "b-sel":U
 ,input  {&TDEDT_Pri_Vnesh}
 ,input  false
 ,input  ?
 ,output loc-ref-list
 ).
if loc-ref-list = ?  or loc-ref-list = '' then return.

  find first   buf_trn-doc no-lock where recid(buf_trn-doc) = int(loc-ref-list) no-error .
  if error-status :error then return .

  define buffer buf_add-trn for ub.add-trn  .

  find first buf_add-trn where
    buf_add-trn.trn-doc-code = buf_trn-doc.doc-code
    no-error .
    if available buf_add-trn then do:
    message substitute(" Накладная &1 уже привязана к документу доп.расхода &2" , buf_trn-doc.doc-code , buf_add-trn.doc-code ) .
       return no-apply.
    end.

  find first x_add-trn where
    x_add-trn.trn-doc-code = buf_trn-doc.doc-code and
    x_add-trn.doc-code     = v-doc-code  no-error .

  if not available x_add-trn then do:
    create x_add-trn .
    assign
      x_add-trn.trn-doc-code = buf_trn-doc.doc-code
      x_add-trn.doc-code     = v-doc-code
    .
    release x_add-trn.
  end.
  else do:
   message substitute(" Накладная &1 уже привязана к документу доп.расхода" , buf_trn-doc.doc-code ) .
  end.

  {&OPEN-QUERY-BR-docsa} .
  {&OPEN-QUERY-BROWSE-7}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn-del Dialog-Frame
ON CHOOSE OF B-trn-del IN FRAME Dialog-Frame /* -ПН */
DO:
  if not available x_add-trn then return .
  find current x_add-trn exclusive-lock no-error .
  delete x_add-trn.
  {&OPEN-QUERY-BR-docsa} .
  {&OPEN-QUERY-BROWSE-7}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn-sel Dialog-Frame
ON CHOOSE OF B-trn-sel IN FRAME Dialog-Frame /* Просмотр ПН */
DO:
    IF NOT AVAILABLE  x_add-trn THEN RETURN NO-APPLY.
    run str/showdoc.p
    ( input parparentproc
     ,input x_add-trn.trn-doc-code
     ,input ?
     ,input ?
     ,input ?
     ,input true
    ) .
END.

on leave of x_add-doc.base-rate  in frame {&frame-name} or
   leave of x_add-doc.base-scale in frame {&frame-name} do:
  if input frame {&frame-name} x_add-doc.base-rate  <> x_add-doc.base-rate  or
     input frame {&frame-name} x_add-doc.base-scale <> x_add-doc.base-scale then do:
    run check-rate no-error.
    if error-status :error then do:
       message
        "Ошибка при проверке курса" skip
        return-value
        view-as alert-box error.
       return no-apply.
    end.
  end.
end.

on choose of r-acc in frame {&frame-name}
do:
  run choose-r-acc no-error.
  if error-status :error then return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_add-doc.exch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_add-doc.exch-code Dialog-Frame
ON LEAVE OF x_add-doc.exch-code IN FRAME Dialog-Frame /* Валюта */
or return of x_add-doc.exch-code in frame {&frame-name}
do:
  if input frame {&frame-name}  x_add-doc.exch-code <> x_add-doc.exch-code then do:
    run choice-currency in this-procedure no-error.
    if error-status :error then do: return no-apply. end.
    run update-rate-doc in this-procedure no-error.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_add-doc.exch-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_add-doc.exch-rate Dialog-Frame
ON LEAVE OF x_add-doc.exch-rate IN FRAME Dialog-Frame /* Курс */
or return of x_add-doc.exch-rate in frame {&frame-name}
or leave, return of x_add-doc.exch-scale in frame {&frame-name}
or leave, return of x_add-doc.base-rate  in frame {&frame-name}
or leave, return of x_add-doc.base-scale in frame {&frame-name}
do:
  run update-rate-doc in this-procedure no-error.
  if error-status :error then do:
    run disp-exch in this-procedure.
    return no-apply.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_add-doc.fact-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_add-doc.fact-date Dialog-Frame
ON LEAVE OF x_add-doc.fact-date IN FRAME Dialog-Frame /* Факт */
DO:
  run chk-upd-date in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-currency
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-currency Dialog-Frame
ON CHOOSE OF r-currency IN FRAME Dialog-Frame
DO:
  run r-proc-currency in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_add-doc.shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_add-doc.shift-date Dialog-Frame
ON LEAVE OF x_add-doc.shift-date IN FRAME Dialog-Frame /* Смена */
do: /* Секция триггеров обработки смены */
  if input frame {&frame-name} x_add-doc.shift-date <> x_add-doc.shift-date then do:
    assign
      x_add-doc.shift-name = ""
      x_add-doc.shift-num  = 0.
    display x_add-doc.shift-name x_add-doc.shift-num with frame {&frame-name}.
    apply "entry" to x_add-doc.shift-name in frame {&frame-name}.
    return no-apply.
  end.
end.

on return of x_add-doc.shift-date in frame {&frame-name} do:
  apply "entry" to x_add-doc.shift-name in frame {&frame-name}.
  return no-apply.
end.

on return of x_add-doc.shift-name in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.

on return of x_add-doc.shift-num in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.

on choose of r-sht in frame {&frame-name} do:
  run proc-sht.
end.

on leave of x_add-doc.shift-num  in frame {&frame-name} do:
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

on leave of x_add-doc.shift-name in frame {&frame-name} do:
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_add-doc.VAT-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_add-doc.VAT-type Dialog-Frame
ON VALUE-CHANGED OF x_add-doc.VAT-type IN FRAME Dialog-Frame /* НДС */
DO:
  /* */
  assign x_add-doc.VAT-type.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docsa
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/ed_date.i x_add-doc.doc-date   }
{ gbl/ed_date.i x_add-doc.fact-date  }
{ gbl/ed_date.i x_add-doc.shift-date }

{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

define variable curclivalue      as character no-undo .
define variable curclitype       as character no-undo .
define variable base-abbr as character no-undo .
define variable exch-abbr as character no-undo .

{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-nakl-glob} }

for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'curcli'   then curclivalue   = string (thbjattr_thbj-attr.property-value-logical) .
end.

x_goods.gds-name:resizable in browse {&browse-name}   = true .
x_goods.gds-name:width     in browse {&browse-name}   = 15 .

define variable varbase-code as integer no-undo.
{ gbl/basecode.i v-cntxt-host-code-obj varbase-code }

run init-proc in this-procedure .
run  get-var-2 in this-procedure
    ( output base-abbr
       ) .
x_add-doc.sum-base:label in frame {&frame-name}  = "Сумма,"  + base-abbr .
x_add-doc.sum-rubl:label in frame {&frame-name}  = "Сумма,{&abbr_rub}"  .

  if p-mode = {&lookup}
     then run enable_lkp in this-procedure .
     else run enable_my  in this-procedure .
  disable x_add-doc.VAT-type
  r-currency
  x_add-doc.exch-code
  with frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-exch Dialog-Frame
PROCEDURE check-exch :
/* -----------------------------------------------------------
    Purpose:     проверка правильности даты таможни и валюты поставщика
  -------------------------------------------------------------*/
    x_add-doc.exch-date  = today .
    x_add-doc.exch-code = 0 .

  find currency where currency.curr-code = x_add-doc.exch-code  no-lock no-error.
  if not available currency then do:
    message "Неправильная валюта  - такой валюты нет.".
    apply "entry" to x_add-doc.exch-code in frame {&frame-name}.
    return error.
  end.
  if x_add-doc.exch-code <> currency.curr-code then do:
    if currency.curr-code = 0 then do:
      /*Если курс был задан и отличался от 1*/
      if (x_add-doc.exch-rate <> ? and x_add-doc.exch-scale <> ? and
          (x_add-doc.exch-rate <> 1 or x_add-doc.exch-scale <> 1)) then do:
      end.

      assign
        x_add-doc.exch-rate = 1
        x_add-doc.exch-scale = 1.
      disable x_add-doc.exch-rate x_add-doc.exch-scale r-acc with frame {&frame-name}.
    end.
    else do:
      find last curr-accnt where curr-accnt.curr-code = currency.curr-code
                             and curr-accnt.exch-date <= input x_add-doc.exch-date use-index pi no-lock no-error.
      if available curr-accnt then do:
        assign
          x_add-doc.exch-rate = curr-accnt.exch-rate
          x_add-doc.exch-scale = curr-accnt.exch-scale.
      end.
      else do:
        assign
          x_add-doc.exch-rate = ?
          x_add-doc.exch-scale = ?.
      end.
      if x_add-doc.exch-code = 0 and
        /*Если курс задается и отличается от 1*/
        (x_add-doc.exch-rate  <> ? and
         x_add-doc.exch-scale <> ? and
         (x_add-doc.exch-rate <> 1 or x_add-doc.exch-scale <> 1)
        ) then do:
      end.
      enable x_add-doc.exch-rate x_add-doc.exch-scale r-acc with frame {&frame-name}.
    end.
    assign
      x_add-doc.exch-code = currency.curr-code.
    /*display x_add-doc.exch-code currency.curr-abbr @ scr-curr-abbr
            x_add-doc.exch-rate x_add-doc.exch-scale with frame {&frame-name}.*/
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-rate Dialog-Frame
PROCEDURE check-rate :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable flag-recount as logical initial no no-undo.
/*Если курс изменился, то в конце пересчитаем накладную*/
if

   input frame {&frame-name} x_add-doc.base-rate  <> x_add-doc.base-rate  or
   input frame {&frame-name} x_add-doc.base-scale <> x_add-doc.base-scale then flag-recount = yes.
if input frame {&frame-name} x_add-doc.base-rate = ? or
   input frame {&frame-name} x_add-doc.base-rate = 0 then do:
  message "Не задан курс базовой валюты.".
  apply "entry" to x_add-doc.base-rate in frame {&frame-name}.
  return error.
end.
if input frame {&frame-name} x_add-doc.base-scale = ? or
   input frame {&frame-name} x_add-doc.base-scale = 0 then do:
  message "Не задан масштаб базовой валюты.".
  apply "entry" to x_add-doc.base-scale in frame {&frame-name}.
  return error.
end.
assign frame {&frame-name}
  x_add-doc.base-rate
  x_add-doc.base-scale.

run waitfram-show in this-procedure  ("ЖДИТЕ.  Пересчет документа ...").
if flag-recount then do:
   run full-recount.
end.
run waitfram-hide in this-procedure  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-update Dialog-Frame
PROCEDURE check-update :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-upd-date Dialog-Frame
PROCEDURE chk-upd-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choice-currency Dialog-Frame
PROCEDURE choice-currency :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
find currency where currency.curr-code = input frame {&frame-name} x_add-doc.exch-code no-error.
if not available currency then do:
  run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do: return error. end.
  find currency where recid ( currency ) = ref-rec.
end.
RUN exch-rate in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-r-acc Dialog-Frame
PROCEDURE choose-r-acc :
define variable v-today      as date    no-undo.
run check-update no-error.
if error-status :error then return error.
run check-exch no-error.
if error-status :error then return error.
define variable varlog as logical   no-undo .
varlog = yes.
message "Подставить БИРЖЕВЫЕ курсы базовой валюты и валюты документа :"
        currency.curr-abbr "на дату растаможивания ?"
view-as alert-box question buttons OK-Cancel update varlog.
if varlog <> true then do:
  return error.
end.

find last curr-accnt where curr-accnt.curr-code = varbase-code and
                         curr-accnt.exch-date <= input frame {&frame-name} x_add-doc.exch-date use-index pi no-lock no-error.
if not available curr-accnt then do:
  message "На эту дату неизвестен курс базовой валюты.".
  apply "entry" to x_add-doc.base-rate in frame {&frame-name}.
  return error.
end.
disp curr-accnt.exch-rate  @ x_add-doc.base-rate
     curr-accnt.exch-scale @ x_add-doc.base-scale with frame {&frame-name}.
run check-rate.
find last curr-accnt where curr-accnt.curr-code = input x_add-doc.exch-code
          and curr-accnt.exch-date <= input x_add-doc.exch-date use-index pi no-lock no-error.
if not available curr-accnt then do:
  message "На дату " + input x_add-doc.exch-date + " неизвестен курс валюты поставщика.".
  apply "entry" to x_add-doc.exch-rate.
  return error.
end.
display curr-accnt.exch-rate  @ x_add-doc.exch-rate
        curr-accnt.exch-scale @ x_add-doc.exch-scale with frame {&frame-name}.
run check-rate.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-exch Dialog-Frame
PROCEDURE disp-exch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_lkp Dialog-Frame
PROCEDURE enable_lkp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY v-obj-name  f-summa f-vat
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x_add-doc THEN
    DISPLAY x_add-doc.base-rate x_add-doc.base-scale
          x_add-doc.doc-date x_add-doc.fact-date x_add-doc.shift-date
          x_add-doc.shift-name x_add-doc.shift-num x_add-doc.VAT-type
          x_add-doc.obj-type x_add-doc.obj-code x_add-doc.doc-code
          x_add-doc.sum-base x_add-doc.VAT-base x_add-doc.sum-rubl
          x_add-doc.VAT-rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  hide B-exit in frame {&frame-name} .
  enable B-trn-sel B-quit B-lkp BROWSE-7 BR-docsa b-help B-print with frame {&frame-name} .
  B-quit:label = "Выход" .
  B-quit:column = 1 .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_my Dialog-Frame
PROCEDURE enable_my :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY v-obj-name  f-summa f-vat
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x_add-doc THEN
    DISPLAY
          x_add-doc.base-rate x_add-doc.base-scale
          x_add-doc.doc-date x_add-doc.fact-date x_add-doc.shift-date
          x_add-doc.shift-name x_add-doc.shift-num x_add-doc.VAT-type
          x_add-doc.obj-type x_add-doc.obj-code x_add-doc.doc-code
          x_add-doc.sum-base x_add-doc.VAT-base x_add-doc.sum-rubl
          x_add-doc.VAT-rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help B-trn B-trn-del B-trn-sel
 BROWSE-7
         x_add-doc.base-rate x_add-doc.base-scale
         x_add-doc.doc-date x_add-doc.VAT-type
         B-add B-lkp B-chg B-del BR-docsa  f-summa f-vat
         B-print
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}


  if curclivalue <> "no" then do:
      if  x_add-doc.exch-code <> 0 then do:
        enable r-acc x_add-doc.exch-rate x_add-doc.exch-scale with frame {&frame-name}.
      end.
  end.
  else do:
    hide r-acc r-currency in frame {&frame-name}.
  end.
  if x_add-doc.exch-rate = 1 and  x_add-doc.exch-scale = 1 then
     disable x_add-doc.exch-rate x_add-doc.exch-scale r-acc with frame {&frame-name}.

  define variable l-shift-on as logical no-undo .
  { gbl/objat.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    "'shift-on=request'"
    l-shift-on
  }
  if l-shift-on = false then hide
     x_add-doc.shift-date
     x_add-doc.shift-num
     x_add-doc.shift-name
     r-sht in frame {&frame-name} .
   if varbase-code = 0 then disable x_add-doc.base-rate x_add-doc.base-scale with frame {&frame-name} .
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
  DISPLAY v-obj-name f-summa f-vat
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x_add-doc THEN
    DISPLAY x_add-doc.base-rate x_add-doc.base-scale x_add-doc.doc-date
          x_add-doc.fact-date x_add-doc.shift-date x_add-doc.shift-name
          x_add-doc.shift-num x_add-doc.VAT-type x_add-doc.obj-type
          x_add-doc.obj-code x_add-doc.doc-code x_add-doc.sum-base
          x_add-doc.VAT-base x_add-doc.sum-rubl x_add-doc.VAT-rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-print B-Help B-trn B-trn-del B-trn-sel BROWSE-7
         x_add-doc.base-rate x_add-doc.base-scale x_add-doc.doc-date
         x_add-doc.fact-date x_add-doc.shift-date x_add-doc.shift-name
         x_add-doc.shift-num r-sht x_add-doc.VAT-type B-add B-lkp B-chg B-del
         BR-docsa x_add-doc.obj-type f-summa f-vat
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE exch-rate Dialog-Frame
PROCEDURE exch-rate :
display currency.curr-code @ x_add-doc.exch-code with frame {&frame-name}.
do transaction on error   undo, return error :
   run check-exch   in this-procedure.
   run check-rate   in this-procedure.
   run full-recount in this-procedure.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE f-curr Dialog-Frame
PROCEDURE f-curr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable   vdoc-date   as date no-undo .
  define variable vexch-rate  as decimal   no-undo .
  define variable vexch-scale as decimal   no-undo .


  assign
  vdoc-date    =    x_add-doc.doc-date
  vexch-rate   =    x_add-doc.exch-rate
  vexch-scale  =    x_add-doc.exch-scale

  .

    { gbl/exchrate.i
      x_add-doc.exch-code
      vdoc-date
      vexch-rate
      vexch-scale
      scr-curr-abbr
    }
/*display  scr-curr-abbr with frame {&frame-name} .*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE full-recount Dialog-Frame
PROCEDURE full-recount :
for each x_add-line exclusive-lock  where
           x_add-line.doc-code = x_add-doc.doc-code
           :
           x_add-line.sum-base = x_add-line.sum-rubl / x_add-doc.base-rate * x_add-doc.base-scale.
           x_add-line.vat-base = x_add-line.vat-rubl / x_add-doc.base-rate * x_add-doc.base-scale.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-var Dialog-Frame
PROCEDURE get-var :
define output parameter pbase-rate  as decimal   no-undo .
define output parameter pbase-scale as decimal   no-undo .
define output parameter pvat-type   as character no-undo .

find first  x_add-doc.
assign frame {&frame-name}
{&ENABLED-FIELDS}
.

assign
pbase-rate  = x_add-doc.base-rate
pbase-scale = x_add-doc.base-scale
pvat-type   = x_add-doc.vat-type
.


END PROCEDURE.

PROCEDURE get-var-2 :
define output parameter base-code-abbr as character no-undo .

define variable v-base-code    as integer   no-undo .
define variable vv-exch-rate   as decimal   no-undo .
define variable vv-exch-scale  as integer   no-undo .

find first  x_add-doc .
assign frame {&frame-name}
{&ENABLED-FIELDS}
.

{ gbl/basecode.i
  x_add-doc.host-code
  v-base-code
 }

{ gbl/exchrate.i
  v-base-code
  today
  vv-exch-rate
  vv-exch-scale
  base-code-abbr
}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
x_add-doc.VAT-type:LIST-ITEMS in frame {&frame-name} =  {&no-vat} + "," + {&inc-vat} + "," + {&without-vat} .

if p-mode = {&add-def} then do:
   run doc-code in this-procedure (
     input   "main":u
    ,input   v-cntxt-obj-type
    ,input   v-cntxt-obj-code
    ,input   ""
    ,output  v-doc-code ) .

   if p-doc-code <> "" then do:
      message "Из накладной" view-as alert-box information .
        create x_add-trn .
        assign
          x_add-trn.trn-doc-code = p-doc-code
          x_add-trn.doc-code     = v-doc-code
        .
      release x_add-trn.
   end.

   create x_add-doc.
   assign
     x_add-doc.doc-code   = v-doc-code
     x_add-doc.doc-date   = today
     x_add-doc.exch-code  = 0
     x_add-doc.exch-date  = x_add-doc.doc-date
     x_add-doc.host-code  = v-cntxt-host-code-obj
     x_add-doc.obj-code   = v-cntxt-obj-code
     x_add-doc.obj-type   = v-cntxt-obj-type
     x_add-doc.status_    = {&g___new}
     x_add-doc.cr-db-num  = v-cntxt-db-num
     x_add-doc.creid      = v-cntxt-userid
     x_add-doc.doc-type   = {&income}

   .
    { gbl/baserate.i
      x_add-doc.host-code
      x_add-doc.doc-date
      x_add-doc.base-rate
      x_add-doc.base-scale
      }
    { gbl/exchrate.i
      x_add-doc.exch-code
      x_add-doc.doc-date
      x_add-doc.exch-rate
      x_add-doc.exch-scale
      v-curr-abbr
    }
  define variable l-shift-on as logical no-undo .
  { gbl/objat.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    "'shift-on=request'"
    l-shift-on
  }
  if l-shift-on = true then do:
    { gbl/curshift.i
     v-cntxt-obj-type
     v-cntxt-obj-code
     x_add-doc.shift-date
     x_add-doc.shift-num
     x_add-doc.shift-name
     }
  end.
  run adm/shattri.p (
      input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-nakl_par}
      ,input  "type-vat"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output varvat-type
      ,output v-value-logical
      ,output varvat-type-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then varvat-type = 1 .

    case varvat-type:
    when 1 or when ? then do:
      assign
        x_add-doc.vat-type = {&inc-vat}.
    end.
    when 2 then do:
      assign
        x_add-doc.vat-type = {&no-vat}.
    end.
    when 3 then do:
       assign
        x_add-doc.vat-type = {&without-vat}.
    end.
    otherwise do:
      message "Не верно задан атрибут 'Тип заведения НДС' (type-vat)."
              "Задано значение: " varvat-type
              "Допустимые значения: 1,2,3."
      view-as alert-box error.
      return error.
    end.
    end case.
end.
else do:
   if p-mode = {&lookup} then find first ub.add-doc no-lock where recid(ub.add-doc) = p-recid no-error .
      else  find first ub.add-doc exclusive-lock where recid(ub.add-doc) = p-recid no-error .
   if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка"
        view-as alert-box error
      .
      return .
   end.
   create x_add-doc.
   buffer-copy ub.add-doc to x_add-doc .
   v-doc-code = ub.add-doc.doc-code .
end.
if p-mode = {&update} then do:
/*Запомним с чем зашли */
 for each ub.add-line where
          ub.add-line.doc-code  = v-doc-code :
  create  old_add-line .
  buffer-copy ub.add-line to old_add-line .
 end.
end.

define buffer obj_clients for ub.clients  .
find first obj_clients no-lock where
           obj_clients.obj-code = v-cntxt-obj-code and
           obj_clients.obj-type = v-cntxt-obj-type  .
v-obj-name = obj_clients.obj-name .
display v-obj-name with frame {&frame-name} .
run f-curr in this-procedure .
{&OPEN-QUERY-BROWSE-7}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/* -----------------------------------------------------------
  Purpose: save
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-sum-rubl as decimal   no-undo .
define variable v-sum-base as decimal   no-undo .
define variable v-vat-rubl as decimal   no-undo .
define variable v-vat-base as decimal   no-undo .

  assign frame {&frame-name}
    {&ENABLED-FIELDS}
  .

  assign
    v-sum-rubl = 0
    v-sum-base = 0
    v-vat-rubl = 0
    v-vat-base = 0
  .
define variable v-kol-l as integer   no-undo .
 v-kol-l = 0 .
  for each x_add-line no-lock  where
           x_add-line.doc-code = x_add-doc.doc-code
           :
      assign
        v-sum-rubl = v-sum-rubl + x_add-line.sum-rubl
        v-sum-base = v-sum-base + x_add-line.sum-base
        v-vat-rubl = v-vat-rubl + x_add-line.vat-rubl
        v-vat-base = v-vat-base + x_add-line.vat-base
        v-kol-l = v-kol-l + 1
        .

  end.

  for EACH x_trn-doc no-lock  WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code :
        v-kol-l = v-kol-l + 1 .
  end.

  if v-kol-l = 0 then do:
     p-recid = ? .
     message  "Документ не содержит ни одной строки и ни одной связки с ПН , ДопРасход будет удален !"  view-as alert-box information .
     delete x_add-doc .
     return.
  end.
  assign
    x_add-doc.sum-rubl = v-sum-rubl
    x_add-doc.sum-base = v-sum-base
    x_add-doc.vat-rubl = v-vat-rubl
    x_add-doc.vat-base = v-vat-base
  .

  if p-mode = {&add-def} then do:
    create ub.add-doc.
  end.

  buffer-copy x_add-doc to ub.add-doc .
  p-recid = recid (ub.add-doc) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-num Dialog-Frame
PROCEDURE proc-shift-num :
define buffer bf_shift-obj   for ub.shift-obj.
  if input frame {&frame-name} x_add-doc.shift-num <> x_add-doc.shift-num then do:
    if input frame {&frame-name} x_add-doc.shift-date <> ? then do:
      find first bf_shift-obj where bf_shift-obj.obj-type   = x_add-doc.obj-type                             and
                                    bf_shift-obj.obj-code   = x_add-doc.obj-code                             and
                                    bf_shift-obj.shift-date = input frame {&frame-name} x_add-doc.shift-date and
                                    bf_shift-obj.shift-num  = input frame {&frame-name} x_add-doc.shift-num  no-lock no-error.
      if not available bf_shift-obj then do:
        message "Не найдена смена: " x_add-doc.obj-type " " x_add-doc.obj-code
                " Дата " input frame {&frame-name} x_add-doc.shift-date " Порядок смены " input frame {&frame-name} x_add-doc.shift-num " ."
        view-as alert-box error.
        display x_add-doc.shift-num with frame {&frame-name}.
        run proc-sht no-error.
        if error-status:error then do:
          return error.
        end.
      end.
      else do:
        assign
          x_add-doc.shift-date = bf_shift-obj.shift-date
          x_add-doc.shift-num  = bf_shift-obj.shift-num
          x_add-doc.shift-name = bf_shift-obj.shift-name.
        display x_add-doc.shift-date x_add-doc.shift-num x_add-doc.shift-name with frame {&frame-name}.
        if x_add-doc.fact-date = ? then do:
          assign
            x_add-doc.fact-date = x_add-doc.shift-date
            x_add-doc.fact-time = (24 * 60 * 60).
          display x_add-doc.fact-date with frame {&frame-name}.
        end.
      end.
    end.
  end.
end procedure.

procedure proc-shift-name :
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.

  if input frame {&frame-name} x_add-doc.shift-name <> x_add-doc.shift-name then do:
    if input frame {&frame-name} x_add-doc.shift-date <> ? then do:

      for each  bf_shift-obj where bf_shift-obj.obj-type   = x_add-doc.obj-type                             and
                                   bf_shift-obj.obj-code   = x_add-doc.obj-code                             and
                                   bf_shift-obj.shift-date = input frame {&frame-name} x_add-doc.shift-date and
                                   bf_shift-obj.shift-name = input frame {&frame-name} x_add-doc.shift-name no-lock on error undo, return error return-value :
        assign
          varfind-shift = varfind-shift + 1
          varshift-date = bf_shift-obj.shift-date
          varshift-num  = bf_shift-obj.shift-num.
      end.

      if varfind-shift = 0 or varfind-shift > 1 then do:
        if varfind-shift = 0 then do:
          message "Не найдена смена: " x_add-doc.obj-type " " x_add-doc.obj-code
                  " Дата " input frame {&frame-name} x_add-doc.shift-date " Номер смены " input frame {&frame-name} x_add-doc.shift-name " ."
          view-as alert-box error.
        end.
        else do:
          message "Найдено более одной смены с одним номером в сменном дне. Объект: " x_add-doc.obj-type " " x_add-doc.obj-code
                  " Дата " input frame {&frame-name} x_add-doc.shift-date " Номер смены " input frame {&frame-name} x_add-doc.shift-name " ."
          view-as alert-box error.
        end.
        display x_add-doc.shift-name with frame {&frame-name}.
        run proc-sht no-error.
        if error-status:error then do: return error. end.
      end.
      else do:
        assign frame {&frame-name}
          x_add-doc.shift-name.
        assign
          x_add-doc.shift-date = varshift-date
          x_add-doc.shift-num  = varshift-num.
        display x_add-doc.shift-date x_add-doc.shift-num x_add-doc.shift-name with frame {&frame-name}.
        if x_add-doc.fact-date = ? then do: assign x_add-doc.fact-date = x_add-doc.shift-date x_add-doc.fact-time = (24 * 60 * 60). display x_add-doc.fact-date with frame {&frame-name}. end.
      end.
    end.
  end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sht Dialog-Frame
PROCEDURE proc-sht :
define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-sel', 'obj', x_add-doc.obj-type, x_add-doc.obj-code ,'':u, input-output varrid-list) no-error.
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        x_add-doc.shift-date = bf_shift-obj.shift-date
        x_add-doc.shift-num  = bf_shift-obj.shift-num
        x_add-doc.shift-name = bf_shift-obj.shift-name.
      display x_add-doc.shift-date x_add-doc.shift-num x_add-doc.shift-name with frame {&frame-name}.
      if x_add-doc.fact-date = ? then do:
        assign
          x_add-doc.fact-date = x_add-doc.shift-date
          x_add-doc.fact-time = (24 * 60 * 60).
        display x_add-doc.fact-date with frame {&frame-name}.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE r-proc-currency Dialog-Frame
PROCEDURE r-proc-currency :
run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do:
     return no-apply.
  end.
  find ub.currency no-lock where recid( ub.currency ) = ref-rec no-error.
  if not available ub.currency then do:
     return no-apply.
  end.
  if ub.currency.curr-code <> x_add-doc.exch-code then do:
   display ub.currency.curr-code @ x_add-doc.exch-code with frame {&frame-name} .
  end.
  RUN exch-rate    in this-procedure.
  RUN full-recount in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE redisp Dialog-Frame
PROCEDURE redisp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-sum-rubl as decimal   no-undo .
define variable v-sum-base as decimal   no-undo .
define variable v-vat-rubl as decimal   no-undo .
define variable v-vat-base as decimal   no-undo .

  assign
    v-sum-rubl = 0
    v-sum-base = 0
    v-vat-rubl = 0
    v-vat-base = 0
  .

  for each x_add-line no-lock  where
           x_add-line.doc-code = x_add-doc.doc-code
           :
      assign
        v-sum-rubl = v-sum-rubl + x_add-line.sum-rubl
        v-sum-base = v-sum-base + x_add-line.sum-base
        v-vat-rubl = v-vat-rubl + x_add-line.vat-rubl
        v-vat-base = v-vat-base + x_add-line.vat-base
        .
  end.

 display v-sum-rubl @ x_add-doc.sum-rubl
         v-sum-base @ x_add-doc.sum-base
         v-vat-rubl @ x_add-doc.vat-rubl
         v-vat-base @ x_add-doc.vat-base
         with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-rate-doc Dialog-Frame
PROCEDURE update-rate-doc :
if input frame {&frame-name} x_add-doc.exch-rate  <> x_add-doc.exch-rate  or
   input frame {&frame-name} x_add-doc.exch-scale <> x_add-doc.exch-scale or
   input frame {&frame-name} x_add-doc.base-rate  <> x_add-doc.base-rate  or
   input frame {&frame-name} x_add-doc.base-scale <> x_add-doc.base-scale then
   do transaction on error undo, return error return-value :
     run check-exch   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-update in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-rate   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME