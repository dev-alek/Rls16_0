&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Экран просмотра партий МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/22/07
Author: Polina Gridchina
Creation date: 05/22/07

Input:

Output:

*/
 /*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-coll-point     as character no-undo .  /*Справочник, Документ, Выбор, wth-ser*/
define input parameter p-edit-mode  as character no-undo . /*Редактирование, просмотр*/
define input parameter p-wth-code   as integer   no-undo.
define input parameter p-par-code   as INTEGER   no-undo.
define input parameter p-ser-code   as INTEGER   no-undo.
define input parameter p-db-num     as INTEGER no-undo.
define input parameter p-wth-doc    as character no-undo.
define input parameter p-w-p-code   as INTEGER no-undo.
define input parameter p-cli-type  like ub.clients.obj-type no-undo .
define input parameter p-cli-code  like ub.clients.obj-code no-undo .
define input parameter p-type      as character no-undo.


/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра партий МЦ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ str/wthparts.i }
{ cmp/mrk-strf.i }
{ cmp/str-glbl.i }
{ gbl/fltopend.i defproc }
{ gbl/usr-flt.i }
define variable filter-label as character no-undo init "Материальные_ценности" .
define variable filter-label0 as character no-undo init "Материальные_ценности" .
define variable filter-point0 as character no-undo init "Парти_МЦ" .
define variable filter-point as character no-undo init "Парти_МЦ" .
define variable sort-column-name as character no-undo .
define variable v-prt-rec  as recid no-undo .
DEFINE VARIABLE v-out-name AS CHAR NO-UNDO format 'x(12)':U.
define variable rid-list   as character no-undo .
define variable v-SerDb    as character    no-undo.
define variable v-SerName  as character    no-undo.
DEFINE VARIABLE v-w-p-name AS CHAR NO-UNDO .
define variable v-obj-name as char no-undo.



DEFINE BUFFER b-wth-doc   FOR ub.wth-doc.
DEFINE BUFFER b-wealth    FOR ub.wealth.
DEFINE BUFFER b-wth-par   FOR ub.wth-par.
DEFINE BUFFER b-goods     FOR ub.goods.
DEFINE BUFFER b-wth-ser   for ub.wth-ser.
DEFINE BUFFER buf_wth-ser for ub.wth-ser.
DEFINE BUFFER X_wth-parts FOR ub.wth-parts.
DEFINE BUFFER b-clients   FOR ub.clients.
define buffer buf_wth-place   for ub.wth-place.
DEFINE BUFFER b-wth-parts FOR ub.wth-parts.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-parts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_wth-parts

/* Definitions for BROWSE br-parts                                      */
&Scoped-define FIELDS-IN-QUERY-br-parts mark-string( recid(X_wth-parts), rid-list ) get-ser-name(X_wth-parts.ser-code,X_wth-parts.db-num) @ v-serName X_wth-parts.fact-rangeFrom X_wth-parts.fact-rangeTo X_wth-parts.fact-qnty get-cli-name(X_wth-parts.obj-type,X_wth-parts.obj-code ) @ v-obj-name get-w-p-name(X_wth-parts.w-p-code, X_wth-parts.obj-type,X_wth-parts.obj-code) @ v-w-p-name get-wthparts-out-code(X_wth-parts.out-code) @ v-out-name X_wth-parts.in-code X_wth-parts.price-rubl X_wth-parts.beg-dt X_wth-parts.end-dt get-cli-name(X_wth-parts.sale-obj-type,X_wth-parts.sale-obj-code ) get-cli-name(X_wth-parts.cli-type,X_wth-parts.cli-code ) get-cli-name(X_wth-parts.out-obj-type,X_wth-parts.out-obj-code ) X_wth-parts.fact-date X_wth-parts.shift-date X_wth-parts.shift-num get-cli-name(X_wth-parts.in-obj-type,X_wth-parts.out-obj-code ) get-cli-name(X_wth-parts.supp-type,X_wth-parts.supp-code ) X_wth-parts.doc-code X_wth-parts.doc-rangeFrom X_wth-parts.doc-rangeTo X_wth-parts.qnty-doc X_wth-parts.price-base X_wth-parts.VAT-pc X_wth-parts.host-code ENTRY(LOOKUP(X_wth-parts.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full}) X_wth-parts.fact-num X_wth-parts.fact-order X_wth-parts.wth-code X_wth-parts.par-code substitute('&1-&2',X_wth-parts.ser-code,X_wth-parts.db-num) @ v-SerDb X_wth-parts.stts X_wth-parts.TYPE
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-parts
&Scoped-define SELF-NAME br-parts
&Scoped-define QUERY-STRING-br-parts FOR EACH X_wth-parts NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-parts OPEN QUERY {&SELF-NAME} FOR EACH X_wth-parts NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-parts X_wth-parts
&Scoped-define FIRST-TABLE-IN-QUERY-br-parts X_wth-parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-parts}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-mark B-mark-all ~
B-cancel-mark B-sel b-lkp B-add B-chg B-del B-sch B-print B-hist B-Help ~
RECT-1 RECT-8 rsfl-obj br-parts bar-str fl-wth-name fl-par-val fl-par-price ~
fl-doc-code fl-doc-date fl-doc-ext-type text-sts Fn-rs-obj
&Scoped-Define DISPLAYED-OBJECTS rsfl-ch rsfl-obj bar-str fl-wth-name ~
fl-par-val fl-gds fl-par-price fl-doc-code fl-doc-date fl-doc-ext-type ~
text-sts Fn-rs-obj

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( f-cli-type AS CHAR, f-cli-code as int  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-ser-name Dialog-Frame
FUNCTION get-ser-name RETURNS CHARACTER
  ( pfser-code AS INT, pfser-db AS INT )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-w-p-name Dialog-Frame
FUNCTION get-w-p-name RETURNS CHARACTER
  ( vf-w-p-code AS int ,vf-obj-type as char, vf-obj-code as int )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-wthparts-out-code Dialog-Frame
FUNCTION get-wthparts-out-code RETURNS CHARACTER
  ( vf-out-code AS CHAR )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-cancel-mark
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все выделения".

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-doc-code
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "Документ"
     SIZE 3 BY 1 TOOLTIP "Документ, породивший партию".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 4 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3.5 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Выделить".

DEFINE BUTTON B-mark-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выделить все партии".

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 4.5 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE bar-str AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fl-doc-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Документ"
     VIEW-AS FILL-IN
     SIZE 10 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-doc-date AS DATE FORMAT "99/99/99":U
     LABEL "от"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-doc-ext-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 44 BY 1 NO-UNDO.

DEFINE VARIABLE fl-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 17.5 BY 1 NO-UNDO.

DEFINE VARIABLE fl-par-price AS CHARACTER FORMAT "X(256)":U
     LABEL "Цена"
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-par-val AS CHARACTER FORMAT "X(256)":U
     LABEL "Номинал"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE fl-wth-name AS CHARACTER FORMAT "X(256)":U
     LABEL "МЦ"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE Fn-rs-obj AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE text-sts AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rsfl-ch AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 0
     SIZE 83.5 BY .75 NO-UNDO.

DEFINE VARIABLE rsfl-obj AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущий объект", 1,
"Все объекты", 2
     SIZE 47.5 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 1.5.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 1.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-parts FOR
      X_wth-parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-parts Dialog-Frame _FREEFORM
  QUERY br-parts NO-LOCK DISPLAY
      mark-string( recid(X_wth-parts), rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      get-ser-name(X_wth-parts.ser-code,X_wth-parts.db-num) @ v-serName COLUMN-LABEL "Серия"  FORMAT "X(10)":U
      X_wth-parts.fact-rangeFrom  COLUMN-LABEL "Диапазон с" FORMAT "->>>>>>>>9":U
      X_wth-parts.fact-rangeTo  COLUMN-LABEL "по" FORMAT "->>>>>>>>9":U
      X_wth-parts.fact-qnty  FORMAT "->,>>>,>>9":U  COLUMN-LABEL "Колич." WIDTH 8
      get-cli-name(X_wth-parts.obj-type,X_wth-parts.obj-code ) @ v-obj-name   COLUMN-LABEL "Объект"     FORMAT "X(26)":U
      get-w-p-name(X_wth-parts.w-p-code, X_wth-parts.obj-type,X_wth-parts.obj-code) @ v-w-p-name COLUMN-LABEL "МХ"  FORMAT "X(12)":U
      get-wthparts-out-code(X_wth-parts.out-code) @ v-out-name COLUMN-LABEL "Документ\зона"
      X_wth-parts.in-code COLUMN-LABEL "Док. порожд." FORMAT "X(10)":U
      X_wth-parts.price-rubl FORMAT "->>>,>>9.99":U   COLUMN-LABEL "Цена талона"
      X_wth-parts.beg-dt   COLUMN-LABEL "Срок годн. с" format "99/99/99"
      X_wth-parts.end-dt   COLUMN-LABEL "Срок годн. по"  format "99/99/99"
      get-cli-name(X_wth-parts.sale-obj-type,X_wth-parts.sale-obj-code )  COLUMN-LABEL "Объект реализ."   FORMAT "X(14)":U
      get-cli-name(X_wth-parts.cli-type,X_wth-parts.cli-code )   COLUMN-LABEL "Покупатель"     FORMAT "X(14)":U
      get-cli-name(X_wth-parts.out-obj-type,X_wth-parts.out-obj-code )   COLUMN-LABEL "Объект погаш."   FORMAT "X(14)":U
      X_wth-parts.fact-date FORMAT "99/99/99":U  COLUMN-LABEL "Факт. дата"
      X_wth-parts.shift-date FORMAT "99/99/99":U
      X_wth-parts.shift-num FORMAT ">9":U
      get-cli-name(X_wth-parts.in-obj-type,X_wth-parts.out-obj-code )  COLUMN-LABEL "Объект нач. приобрет."   FORMAT "X(14)":U
      get-cli-name(X_wth-parts.supp-type,X_wth-parts.supp-code )    COLUMN-LABEL "Поставщик"    FORMAT "X(14)":U
      X_wth-parts.doc-code COLUMN-LABEL "Документ"
      X_wth-parts.doc-rangeFrom FORMAT "->,>>>,>>>,>>9":U  column-label 'Диапазон с (док.)'
      X_wth-parts.doc-rangeTo FORMAT "->,>>>,>>>,>>9":U    column-label 'Диапазон по (док.)'
      X_wth-parts.qnty-doc FORMAT "->>>,>>>,>>9":U   column-label 'Кол-во (док.)'
      X_wth-parts.price-base FORMAT "->>,>>>,>>9.99":U
      X_wth-parts.VAT-pc FORMAT ">9.9<%":U
      X_wth-parts.host-code COLUMN-LABEL "Код фирмы" FORMAT ">>>>>>>>9":U
      ENTRY(LOOKUP(X_wth-parts.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full}) FORMAT "X(18)":U   column-label 'Расш. тип'
      X_wth-parts.fact-num FORMAT "->,>>>,>>9":U
      X_wth-parts.fact-order FORMAT "9999999999999999999999.9999999999":U
      X_wth-parts.wth-code
      X_wth-parts.par-code
      substitute('&1-&2',X_wth-parts.ser-code,X_wth-parts.db-num) @ v-SerDb COLUMN-LABEL "Код серии"
      X_wth-parts.stts FORMAT ">9":U
      X_wth-parts.TYPE
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 12.25
         FONT 2 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 18
     b-quit AT ROW 1 COL 11 WIDGET-ID 20
     B-mark AT ROW 1 COL 21 WIDGET-ID 12
     B-mark-all AT ROW 1 COL 24 WIDGET-ID 316
     B-cancel-mark AT ROW 1 COL 27 WIDGET-ID 318
     B-sel AT ROW 1 COL 30 WIDGET-ID 16
     b-lkp AT ROW 1 COL 40 WIDGET-ID 22
     B-add AT ROW 1 COL 50 WIDGET-ID 2
     B-chg AT ROW 1 COL 60 WIDGET-ID 4
     B-del AT ROW 1 COL 70 WIDGET-ID 6
     B-sch AT ROW 1 COL 82 WIDGET-ID 60
     B-print AT ROW 1 COL 86.5 WIDGET-ID 14
     B-hist AT ROW 1 COL 90.5 WIDGET-ID 10
     B-Help AT ROW 1 COL 94 WIDGET-ID 8
     rsfl-ch AT ROW 2.25 COL 11 NO-LABEL WIDGET-ID 62
     rsfl-obj AT ROW 3 COL 11 NO-LABEL WIDGET-ID 292
     br-parts AT ROW 4 COL 1 WIDGET-ID 200
     bar-str AT ROW 16.38 COL 16.5 COLON-ALIGNED NO-LABEL WIDGET-ID 320
     fl-wth-name AT ROW 17.75 COL 4.5 COLON-ALIGNED WIDGET-ID 50
     fl-par-val AT ROW 17.75 COL 40 COLON-ALIGNED WIDGET-ID 52
     fl-gds AT ROW 17.75 COL 57 COLON-ALIGNED WIDGET-ID 58
     fl-par-price AT ROW 17.75 COL 82 COLON-ALIGNED WIDGET-ID 326
     b-doc-code AT ROW 19.25 COL 2.5 WIDGET-ID 308
     fl-doc-code AT ROW 19.25 COL 14.5 COLON-ALIGNED WIDGET-ID 304
     fl-doc-date AT ROW 19.25 COL 29 COLON-ALIGNED WIDGET-ID 324
     fl-doc-ext-type AT ROW 19.25 COL 42.5 COLON-ALIGNED NO-LABEL WIDGET-ID 302
     text-sts AT ROW 2.25 COL 1.13 COLON-ALIGNED NO-LABEL WIDGET-ID 314
     Fn-rs-obj AT ROW 3.17 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 312
     "Штрих-код:" VIEW-AS TEXT
          SIZE 10.5 BY .67 AT ROW 16.58 COL 6.63 WIDGET-ID 328
          FGCOLOR 4
     RECT-1 AT ROW 17.5 COL 1 WIDGET-ID 300
     RECT-8 AT ROW 19 COL 1 WIDGET-ID 310
     SPACE(0.00) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии серийных МЦ" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-parts rsfl-obj Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-doc-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-doc-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       fl-doc-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       fl-doc-ext-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN fl-gds IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET rsfl-ch IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       rsfl-ch:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-parts
/* Query rebuild information for BROWSE br-parts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_wth-parts NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-parts */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Партии серийных МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:

define variable glog as logical  no-undo .
/* { gbl/chk-actg.i
 v-cntxt-db-num
 v-cntxt-userid
 {&action-head-code-main}
 'actn_wealth_work':U
 {&cntxt-global}
 0
 '':U
 0
 0
 0
 0
 true
 glog
 }
 if NOT glog then return no-apply.   */
if not available b-wth-doc then return.
run proc-add in this-procedure.
RUn OpenBr in this-procedure .
apply "entry" to BR-parts in frame {&frame-name}.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cancel-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cancel-mark Dialog-Frame
ON CHOOSE OF B-cancel-mark IN FRAME Dialog-Frame /* - */
DO:
 rid-list = ''.
 br-parts:refresh() no-error.
 apply "entry" to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:

define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
If not available X_wth-parts then return.
/* { gbl/chk-actg.i                  */
/* v-cntxt-db-num                    */
/* v-cntxt-userid                    */
/* {&action-head-code-main}          */
/* 'actn_wealth_work':U              */
/* {&cntxt-global}                   */
/* 0                                 */
/* '':U                              */
/* 0                                 */
/* 0                                 */
/* 0                                 */
/* 0                                 */
/* true                              */
/* glog                              */
/* }                                 */
/* if NOT glog then return no-apply. */
rep-rec = recid(X_wth-parts).
run str/wthpartl.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,INPUT {&UPDATE}
                ,INPUT p-w-p-code
                ,INPUT X_wth-parts.wth-code
                ,INPUT X_wth-parts.par-code
                ,INPUT X_wth-parts.in-code
                ,INPUT p-wth-doc
                ,INPUT X_wth-parts.ser-code
                ,INPUT X_wth-parts.db-num
                ,INPUT X_wth-parts.fact-rangeFrom
                ,INPUT X_wth-parts.fact-rangeTo
                ,INPUT p-type
                ,input-output rep-rec).

if rep-rec <> ? then do:
  v-prt-rec = rep-rec.
  RUn OpenBr in this-procedure .
  apply "entry" to BR-parts in frame {&frame-name}.
end.
else do:
  apply "entry" to BR-parts in frame {&frame-name}.
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
 define variable del-rec as recid no-undo.
 define variable glog     as logical no-undo .
 define variable rep-rec as recid no-undo .
 define buffer buf_wth-ser for ub.wth-ser.
 if not available X_wth-parts then do:
   message "Неправильно выбрана строка.".
   return no-apply.
 end.

/* if lookup(X_wth-parts.out-code,{&WDEDT_List-Zone}) > 0 then do:
  message 'Партия не принадлежит документу. Удаление невозможно!' view-as alert-box error.
  return no-apply.
 end. */

/* { gbl/chk-actg.i
 v-cntxt-db-num
 v-cntxt-userid
 {&action-head-code-main}
 'actn_wealth_work':U
 {&cntxt-global}
 0
 '':U
 0
 0
 0
 0
 true
 glog
 }
 if NOT glog then return no-apply.   */
 run proc-del in this-procedure.
    RUn OpenBr in this-procedure .
    apply "entry" to BR-parts in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc-code Dialog-Frame
ON CHOOSE OF b-doc-code IN FRAME Dialog-Frame /* Документ */
DO:
  { gbl/stdbtn.i }
  run show-doc-code in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
   { gbl/stdbtn.i }
   if p-coll-point <> 'document':U then run save-position in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
/*   IF NOT AVAILABLE wth-ser THEN RETURN NO-APPLY.                       */
/*   define variable v-rid-list  as   character            no-undo .      */
/*   define variable v-host-code like ub.sysconf.host-code no-undo .      */
/*   run ref/cwthhist.w (                                                 */
/*                    input        parparentproc                          */
/*                  , input        p-curr-host-code                       */
/*                  , input        p-curr-obj-type                        */
/*                  , input        p-curr-obj-code                        */
/*                  , input        "":U          /* bttns */              */
/*                  , input        "one":U       /* p-mode */             */
/*                  , input        wth-ser.wth-code /*p-wth-code*/        */
/*                  , INPUT        0             /*p-par-code*/           */
/*                  , input        ?             /* p-host-code */        */
/*                  , input        ?             /* p-obj-type*/          */
/*                  , input        ?             /* p-obj-code*/          */
/*                  , input        ?             /* p-corr-user-db-num */ */
/*                  , input        "":U          /* p-corr-user-name */   */
/*                  , input        {&table_wth-ser}   /* p-subject */     */
/*                  , input        g#db-num      /* p-db-num */           */
/*                  , input-output v-rid-list                             */
/*                  ) no-error .                                          */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:

define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
/* { gbl/chk-actg.i                  */
/* v-cntxt-db-num                    */
/* v-cntxt-userid                    */
/* {&action-head-code-main}          */
/* 'actn_wealth_work':U              */
/* {&cntxt-global}                   */
/* 0                                 */
/* '':U                              */
/* 0                                 */
/* 0                                 */
/* 0                                 */
/* 0                                 */
/* true                              */
/* glog                              */
/* }                                 */
/* if NOT glog then return no-apply. */
rep-rec = recid(X_wth-parts).
        run str/wthpartl.w (
                         input parparentproc
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,INPUT {&LOOKUP}
                        ,INPUT X_wth-parts.w-p-code
                        ,INPUT X_wth-parts.wth-code
                        ,INPUT X_wth-parts.par-code
                        ,INPUT X_wth-parts.in-code /*?????????????????????????????*/
                        ,INPUT X_wth-parts.out-code /*?????????????????????????????*/
                        ,INPUT X_wth-parts.ser-code
                        ,INPUT X_wth-parts.db-num
                        ,INPUT X_wth-parts.fact-rangeFrom
                        ,INPUT X_wth-parts.fact-rangeTo
                        ,INPUT   X_wth-parts.type
                        ,input-output rep-rec).
if rep-rec <> ? then do:
  v-prt-rec = rep-rec.
  RUn OpenBr in this-procedure .
  apply "entry" to BR-parts in frame {&frame-name}.
end.
else do:
  apply "entry" to BR-parts in frame {&frame-name}.
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
 define variable glog as logical no-undo .
   if available X_wth-parts then do:
     { gbl/markstrn.i X_wth-parts rid-list }
     br-parts:refresh().
     if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
             glog = br-parts:select-next-row ().
             apply "iteration-changed" to br-parts in frame {&frame-name}.
         end.
   end.
   apply "entry" to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-all Dialog-Frame
ON CHOOSE OF B-mark-all IN FRAME Dialog-Frame /* + */
DO:
 define variable glog as logical no-undo .
 GET FIRST br-parts NO-LOCK.
 rid-list = ''.
 selectBlock:
 DO WHILE not QUERY-OFF-END("br-parts":U)  :
   if available X_wth-parts then do on error undo, leave selectBlock :
     { gbl/markstrn.i X_wth-parts rid-list }
        /*  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
             glog = br-parts:select-next-row ().
             apply "iteration-changed" to br-parts in frame {&frame-name}.
         end. */
   end.
   get next br-parts no-lock.
 END.
 br-parts:refresh() no-error.
 apply "entry" to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
 define variable doc-rec as recid no-undo .
     doc-rec = recid( X_wth-parts ).
/*     DO WHILE available X_wth-parts :
           GET prev br-parts.
     END.*/
   run PrintProc in this-procedure no-error.
   reposition br-parts to recid doc-rec no-error.
   apply "entry" to br-parts in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:

if p-coll-point <> 'document':U then run save-position in this-procedure.
/*   { gbl/stdbtn.i }                                                      */
/*                                                                         */
/*   define variable v-ok as logical no-undo .                             */
/*   assign                                                                */
/*     v-ok = false                                                        */
/*   .                                                                     */
/*   if v-data-changed = true                                              */
/*   then do:                                                              */
/*     message                                                             */
/*       "Данные были изменены" skip                                       */
/*       "Вы действительно хотите отказаться от ВСЕХ изменений" skip       */
/*       "с момента последнего открытия окна партий?" skip                 */
/*       view-as alert-box question buttons yes-no update v-ok .           */
/*     if v-ok <> true                                                     */
/*     then do:                                                            */
/*       return no-apply .                                                 */
/*     end.                                                                */
/*   end.                                                                  */
/*                                                                         */
/*   if  v-need-check-diff-qnty = true                                     */
/*   and v-chg-qnty <> 0                                                   */
/*   then do:                                                              */
/*     message                                                             */
/*       "Необходимо создать партии с общим количеством" v-chg-qnty skip   */
/*       "Отказ от редактирования партий приведет к тому," skip            */
/*       "что не будет зарезервировано необходимое количество товара" skip */
/*       "Вы действительно хотите отказаться от редактирования партий?"    */
/*       view-as alert-box question buttons yes-no update v-ok .           */
/*     if v-ok <> true                                                     */
/*     then do:                                                            */
/*       return no-apply .                                                 */
/*     end.                                                                */
/*   end.                                                                  */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'wth-parts'
  join-tbl = 'X_wth-parts'
  dim = '0':U
  fld = '':U
  lab = '':U
  spr = '':U
  .
  run fltfield-add in this-procedure('wth-code', 'Код МЦ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ser-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('gds-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-rangeFrom', 'Диапазон с', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-rangeTo', 'Диапазон по', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('w-p-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-code', 'Номер порожд. док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-code', 'Номер док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Номер договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Покупатель', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-type{&delim-flt}supp-code', 'Поставщик', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sale-obj-type{&delim-flt}sale-obj-code', 'Объект реализации', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-obj-type{&delim-flt}out-obj-code', 'Объект погашения', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('type', 'Тип док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ext-doc-type', 'Расш. тип док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('beg-dt', 'Дата начала срока годности', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-dt', 'Дата конца срока годности', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



    DO on stop undo, leave:
        run gbl/filter.w ( input parparentproc
                         , input filter-point
                         , input tbl
                         , input join-tbl
                         , input  fld
                         , input lab
                         , input spr
                         , input dim).
        RUN OpenBr in this-procedure .
    END .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if  available X_wth-parts AND (rid-list = ""  or
        b-mark:sensitive = no)
    then
    rid-list = string( recid( X_wth-parts ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bar-str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bar-str Dialog-Frame
ON RETURN OF bar-str IN FRAME Dialog-Frame
DO:
define variable v-ser-code  as integer      no-undo.
define variable v-db-num    as integer      no-undo.
define variable v-stts      as integer      no-undo.
define variable v-wth-code  as integer      no-undo.
define variable v-gds-code  as integer      no-undo.
define variable v-par-code  as integer      no-undo.
define variable v-zone      as character    no-undo.
define variable v-fromDate  as date         no-undo.
define variable v-ToDate    as date         no-undo.
define variable v-rangeNum  as integer      no-undo.
define variable parline-rec    as recid     no-undo.
define variable parparts-rec    as recid    no-undo.
define variable v-start-rec as integer      no-undo.
define variable v-qstrnum as int no-undo.   /*Переменная запоминающая номер строки позиционирования*/
define variable v-cur-recX as recid no-undo.
assign frame Dialog-Frame bar-str .

if not available x_wth-parts then return.

/*Идентифицируем введенный штрих-код*/
  run str/wthidnt.p ( input bar-str /*"КОД ТАЛОНА"*/
          ,output v-ser-code
          ,output v-db-num
          ,output v-stts
          ,output v-wth-code
          ,output v-gds-code
          ,output v-par-code
          ,output v-zone
          ,output v-FromDate
          ,output v-ToDate
          ,output v-rangeNum
          ) no-error.
if error-status:error then do:
   message error-status:get-message(1) + {&space-char} + return-value.
   undo, return .
end.
/*CASE p-coll-point:
when 'document' then do:  */
apply 'entry':U to br-parts.
v-cur-recX =  recid(x_wth-parts).
  get next br-parts .
  findBlock: do:
    do while available x_wth-parts and v-cur-recX  <>  recid(x_wth-parts):

        if  x_wth-parts.ser-code =  v-ser-code
        and x_wth-parts.db-num   =  v-db-num
        and x_wth-parts.wth-code =  v-wth-code
        and x_wth-parts.gds-code =  v-gds-code
        and x_wth-parts.par-code =  v-par-code
  /*     and x_wth-parts.out-code = p-wth-doc   */
        and x_wth-parts.fact-RangeFrom <= v-rangeNum
        and x_wth-parts.fact-RangeTo >= v-rangeNum
        then do:
         if not available x_wth-parts then message '2' view-as alert-box.

            reposition br-parts to recid  recid(x_wth-parts).
           /* apply 'entry':U to br-parts.
            bar-str:screen-value = '':U.  */
          /*  br-parts:SELECT-FOCUSED-ROW( )  no-error.     */
            leave findBlock.
        end.
       get next br-parts.
       if not available x_wth-parts then get first br-parts.
    end.
    if p-coll-point =   'document'  then
    message substitute( "В данном списке нет талона с указанным штрих-кодом: &1", bar-str ) view-as alert-box warning.
  /* end. */

  end. /*FindBlock*/
apply 'entry':U to br-parts.
bar-str:screen-value = '':U.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-parts
&Scoped-define SELF-NAME br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON MOUSE-SELECT-DBLCLICK, return OF br-parts IN FRAME Dialog-Frame
DO:
    IF b-chg:SENSITIVE THEN APPLY "choose":U TO b-chg.
  ELSE APPLY "choose":U TO b-lkp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON ROW-DISPLAY OF br-parts IN FRAME Dialog-Frame
DO:
def var v-font as integer no-undo init ?.
if available X_wth-parts then do:
  IF X_wth-parts.in-code = {&forged} and lookup(X_wth-parts.out-code,{&WDEDT_list-zone}) > 0 THEN
  v-font = 12.
  if /*p-coll-point = 'document' and */ lookup(X_wth-parts.out-code,{&WDEDT_list-zone}) = 0  then
  v-font = 7.
  ASSIGN v-SerDb:FGCOLOR IN BROWSE {&BROWSE-NAME} = v-font
       X_wth-parts.fact-rangeFrom:FGCOLOR IN BROWSE {&BROWSE-NAME} = v-font
       X_wth-parts.fact-rangeTo:FGCOLOR IN BROWSE {&BROWSE-NAME} = v-font
       X_wth-parts.fact-qnty:FGCOLOR IN BROWSE {&BROWSE-NAME} = v-font
       X_wth-parts.in-code:FGCOLOR IN BROWSE {&BROWSE-NAME} = v-font
       v-out-name:FGCOLOR IN BROWSE {&BROWSE-NAME} = v-font
       v-obj-name:FGCOLOR IN BROWSE {&BROWSE-NAME} = v-font
       v-w-p-name:FGCOLOR IN BROWSE {&BROWSE-NAME} = v-font
       v-serName :FGCOLOR IN BROWSE {&BROWSE-NAME} = v-font.
  if X_wth-parts.stts = 1 then do:
       X_wth-parts.fact-rangeFrom:screen-value IN BROWSE {&BROWSE-NAME} = '?'.
       X_wth-parts.fact-rangeTo:screen-value IN BROWSE {&BROWSE-NAME} = '?'.
       X_wth-parts.fact-qnty:screen-value IN BROWSE {&BROWSE-NAME} = '0'.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON VALUE-CHANGED OF br-parts IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_wth-parts THEN DO WITH FRAME {&FRAME-NAME}:
      FIND FIRST b-wealth WHERE b-wealth.wth-code = X_wth-parts.wth-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wealth THEN DISP b-wealth.wth-name @ fl-wth-name.
      ELSE fl-wth-name:SCREEN-VALUE = '?':U.
      FIND FIRST b-wth-par WHERE b-wth-par.wth-code =  X_wth-parts.wth-code AND b-wth-par.par-code = X_wth-parts.par-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wth-par THEN do:
          DISP SUBSTITUTE("&1 &2",b-wth-par.par-val,b-wth-par.par-unit) @ fl-par-val
                         (if X_wth-parts.price-rubl > 0 then  trim(string(X_wth-parts.price-rubl / b-wth-par.par-val,"->>>,>9.99")) else '':U)  @ fl-par-price.
      END.
      ELSE fl-par-val:SCREEN-VALUE = '?':U.
      FIND FIRST b-goods WHERE b-goods.gds-code = X_wth-parts.gds-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-goods THEN DO:
                                  /*   b-goods.prod-type @ fl-prodType
                                     b-goods.prod-code @ fl-prodCode   */
                                disp  b-goods.gds-name  @ fl-gds.
             /*fl-obj-name:SCREEN-VALUE = get-cli-name(b-goods.prod-type,b-goods.prod-code)*/
      END.
      ELSE   ASSIGN fl-gds:SCREEN-VALUE = '?':U.

      ENABLE b-lkp
             b-del WHEN p-coll-point = 'document':U AND p-edit-mode = {&UPDATE}
             b-chg WHEN p-coll-point = 'document':U AND p-edit-mode = {&UPDATE}.
      if lookup(X_wth-parts.out-code,{&WDEDT_list-zone}) > 0 then do:
               display  X_wth-parts.doc-code @ fl-doc-code
                        X_wth-parts.fact-date @ fl-doc-date
                     ENTRY(LOOKUP(X_wth-parts.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full}) @ fl-doc-ext-type
            .
      end.
      else do:
         display  X_wth-parts.out-code @ fl-doc-code
                  X_wth-parts.fact-date @ fl-doc-date
                  ENTRY(LOOKUP(X_wth-parts.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full}) @ fl-doc-ext-type
          no-error .
      end.
      if X_wth-parts.stts = 1 and p-edit-mode <> {&LOOKUP} then do:
        b-del:label = 'Восстанов'.
        /*b-chg:sensitive = no.  */
      end.
      else b-del:label = 'Удалить'.
  END.
  ELSE DO:
      DISABLE b-lkp b-chg b-del WITH FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsfl-ch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsfl-ch Dialog-Frame
ON VALUE-CHANGED OF rsfl-ch IN FRAME Dialog-Frame
DO:

  if self:screen-value = '2' then do:
    /*rsfl-obj:screen-value = '2'.*/
    hide rsfl-obj Fn-rs-obj in frame Dialog-Frame  .
    v-w-p-name:visible in browse br-parts = no.
    v-out-name:visible in browse br-parts = no.
    X_wth-parts.in-code:visible in browse br-parts = no.

  end.
  else do:
    if p-coll-point <> 'document' then view rsfl-obj Fn-rs-obj in frame Dialog-Frame  .
    v-w-p-name:visible in browse br-parts = yes.
    v-out-name:visible in browse br-parts = yes.
    X_wth-parts.in-code:visible in browse br-parts = yes.

  end.
    RUn OpenBr in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsfl-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsfl-obj Dialog-Frame
ON VALUE-CHANGED OF rsfl-obj IN FRAME Dialog-Frame
DO:
    RUn OpenBr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

 on "ANY-PRINTABLE":U of br-parts anywhere  do:
    bar-str:screen-value = bar-str:screen-value + last-event:label.
    apply "entry" to bar-str in frame {&frame-name}.
    apply "end" to bar-str in frame {&frame-name}.
 end.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/getcntxt.i get }
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }
{ gbl/brwrepos.i
&browse-name = "br-parts"
&line-num=5
}
/* ON  "DEFAULT-ACTION":U  of  br-parts do:               */
/* message '22'.                                          */
/*   if b-mark:sensitive then apply 'choose':U to b-mark. */
/* end.                                                   */
CASE p-coll-point:
    WHEN {&WTH-PAR} or when {&wth-ser} or when {&wth-place} THEN DO:
      if p-edit-mode = {&add-def} or  p-edit-mode = {&update} then do:
        message vss-workfile vss-revision vss-description skip
        substitute('Неверные параметры вызова (p-coll-point = "&2",p-edit-mode = "&3" ). Возможен только режим &1.',{&lookup},p-coll-point, p-edit-mode)
        view-as alert-box ERROR.
        return.
      end.
    END.
    WHEN "document":U THEN DO:
    END.
    OTHERWISE DO:
        message vss-workfile vss-revision vss-description skip
        "Неверный вызов - p-coll-point=" p-coll-point
        view-as alert-box ERROR.
        return.
    END.
END CASE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
if p-edit-mode = {&UPDATE} or p-edit-mode = {&add-def}
then do:
  /* режим редактирования - открываем транзакцию */
  TRANSACTION-MAIN-BLOCK:
  DO TRANSACTION
  ON ERROR   UNDO TRANSACTION-MAIN-BLOCK, LEAVE TRANSACTION-MAIN-BLOCK
  ON END-KEY UNDO TRANSACTION-MAIN-BLOCK, LEAVE TRANSACTION-MAIN-BLOCK
  :

    run main-block-procedure no-error .
    if error-status :error
    then do:
/*       if v-need-rsrv-gds                                            */
/*       then do:                                                      */
/*         undo transaction-main-block, leave transaction-main-block . */
/*       end.                                                          */
/*                                                                     */
/*            else do:                                                 */
        undo, return error .
/*       end. */
    end.
  END.
end.
ELSE if p-edit-mode = {&LOOKUP} THEN do:
  /* в режиме просмотра - не открываем транзакцию */
  MAIN-BLOCK:
  DO
  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  :

   run main-block-procedure no-error .
    if error-status :error
    then do:
      LEAVE MAIN-BLOCK .
    end.
  END.
end.
else do:
      message vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова - p-edit-mode=" p-edit-mode
      view-as alert-box error.
      return.
end.
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
  DISPLAY rsfl-ch rsfl-obj bar-str fl-wth-name fl-par-val fl-gds fl-par-price
          fl-doc-code fl-doc-date fl-doc-ext-type text-sts Fn-rs-obj
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-mark B-mark-all B-cancel-mark B-sel b-lkp B-add B-chg
         B-del B-sch B-print B-hist B-Help RECT-1 RECT-8 rsfl-obj br-parts
         bar-str fl-wth-name fl-par-val fl-par-price fl-doc-code fl-doc-date
         fl-doc-ext-type text-sts Fn-rs-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-position Dialog-Frame
PROCEDURE load-position :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-current-zone-string      as character    no-undo.
define variable v-current-obj-string       as character    no-undo.
define variable v-void-logical              as logical      no-undo.
define variable v-void-character            as character    no-undo.
define variable v-found                     as logical      no-undo.

do   with frame {&frame-name}
on error undo, return error
:
    run uf-get (

         input {&current-position-zone}
        , input v-cntxt-userid
        , output v-current-zone-string
        , output v-void-character
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
    ) no-error.
    if not error-status :error  then rsfl-ch:screen-value =  v-current-zone-string.
/*    message  v-found  rsfl-ch:screen-value   {&current-position-zone} v-cntxt-userid.  */
    run uf-get (
          input {&current-position-obj}
        , input v-cntxt-userid
        , output v-current-obj-string
        , output v-void-character
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
    ) no-error.
    if not error-status :error  then rsfl-obj:screen-value =  v-current-obj-string.
 end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main-block-procedure Dialog-Frame
PROCEDURE main-block-procedure :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

if p-wth-code > 0 or p-coll-point = {&wth-par} then do:
  find first b-wealth where b-wealth.wth-code = p-wth-code no-lock no-error.
  if not available b-wealth then do:
    message substitute("Не найдена МЦ с кодом &1!",p-wth-code)
    view-as alert-box error.
    return error.
  end.
end.

if p-par-code > 0 or p-coll-point = {&wth-par} then do:
  find first b-wth-par where b-wth-par.wth-code = p-wth-code
                          and  b-wth-par.par-code = p-par-code
  no-lock no-error.
  if not available b-wth-par then do:
    message substitute("Не найден номинал МЦ. Код номинала: &1, Код МЦ: &2!",p-par-code, p-wth-code)
    view-as alert-box error.
    return error.
  end.
end.

if p-ser-code > 0 or p-coll-point = {&wth-ser} then do:
  find first b-wth-ser where b-wth-ser.ser-code = p-ser-code
                           and b-wth-ser.db-num = p-db-num
  no-lock no-error.
  if not available b-wth-ser then do:
    message substitute("Не найдена серия МЦ. Код серии &1-&2!",p-ser-code, p-db-num)
    view-as alert-box error.
    return error.
  end.
end.

if p-coll-point = 'document':U then do:
  if p-edit-mode = {&lookup} then
  FIND FIRST b-wth-doc WHERE b-wth-doc.doc-code = p-wth-doc NO-LOCK NO-ERROR.
  ELSE FIND FIRST b-wth-doc WHERE b-wth-doc.doc-code = p-wth-doc exclusive-lock NO-ERROR.
  if not available b-wth-doc then do:
    message substitute("Не найден документ с номером &1!",p-wth-doc)
    view-as alert-box error.
    return error.
  end.

end.

run MyEnable.
apply "value-changed":U to rsfl-ch in frame {&frame-name}.
/*RUN openBr.    */
wait-for 'go' of frame    Dialog-Frame  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*MESSAGE p-wth-doc SKIP p-curr-obj-type SKIP p-curr-obj-code  VIEW-AS ALERT-BOX.*/
br-parts:NUM-LOCKED-COLUMNS IN FRAME  {&FRAME-NAME}  = 4 .
DEF VAR rs-list AS CHAR.
enable rsfl-obj with frame   {&FRAME-NAME}.
rsfl-ch:DELETE("все") IN FRAME {&FRAME-NAME}.
IF p-coll-point = 'document' THEN DO:
    FIND FIRST b-wth-doc WHERE b-wth-doc.doc-code = p-wth-doc NO-LOCK NO-ERROR.
    IF AVAILABLE b-wth-doc THEN do:
        CASE b-wth-doc.ext-doc-type:
            WHEN {&WDEDT_Inc_Ext} OR WHEN {&WDEDT_Inc_Int_Put} or when {&WDEDT_Inc_Int_Free}
            or WHEN {&WDEDT_Ret_Int_Put} or WHEN {&WDEDT_Ret_Int_Free}
            or when {&WDEDT_Inc_Obj_Free} or when {&WDEDT_Inc_Obj_Put}  THEN DO:
                rsfl-ch:ADD-LAST("Документ",0).

            END.
            WHEN {&WDEDT_Exp_Ext} or when {&WDEDT_Exp_Int_free} or when {&WDEDT_Exp_Obj_Free} THEN DO:
                rsfl-ch:ADD-LAST("Все",11).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Свободная зона ", 1).
            END.
            WHEN {&WDEDT_Exp_Int_Put} or when {&WDEDT_Exp_Obj_Put} THEN DO:
                rsfl-ch:ADD-LAST("Все",13).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона погашения", 3).
            END.
            WHEN {&WDEDT_Put_Cash} THEN DO:
                rsfl-ch:ADD-LAST("Все",12).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона покупателей", 2).

            END.
            WHEN {&WDEDT_Put_Sale} OR WHEN {&WDEDT_Put_Cli} OR WHEN {&WDEDT_Dst_Cli} THEN DO:
                rsfl-ch:ADD-LAST("Все",12).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона покупателей", 2).
            END.
            WHEN {&WDEDT_Dst_Free} THEN DO:
                rsfl-ch:ADD-LAST("Все",11).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Свободная. зона", 1).
            END.
            WHEN {&WDEDT_Dst_Put} THEN DO:
                rsfl-ch:ADD-LAST("Все",13).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона погашения", 3).
            END.
            WHEN {&WDEDT_exch} THEN DO:
              if p-type = {&income} then do:
                rsfl-ch:ADD-LAST("Все",12).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона покупателей", 2).
              end.
              else do:
                rsfl-ch:ADD-LAST("Все",11).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Свободная зона", 1).
              end.
            END.

            OTHERWISE DO:
                MESSAGE substitute("Неверный вызов - ext-doc-type =  :&1&2&3"
                                     , b-wth-doc.ext-doc-type
                                     , error-status:get-message(1)
                                     , return-value
                                   ) VIEW-AS ALERT-BOX ERROR.
                RETURN ERROR.
            END.
        END CASE.
        /*если документ внутреннего прихода, то переставляем колнки диапазона по документу*/
        if b-wth-doc.doc-type = {&income} and b-wth-doc.exter_ =  no then do:
          br-parts:MOVE-COLUMN(14,6).
          br-parts:MOVE-COLUMN(15,7).
          br-parts:MOVE-COLUMN(16,8).
        end.
    END.
END.
ELSE if p-coll-point = {&wth-place} THEN DO:
    rsfl-ch:ADD-LAST("Все", 0).
    rsfl-ch:ADD-LAST("Свободная зона", 1).
    rsfl-ch:ADD-LAST("Зона погашения", 3).
    rsfl-ch:ADD-LAST("Зона уничтожения", 4).
    view b-doc-code in frame  {&FRAME-NAME}.
    hide rsfl-obj
         Fn-rs-obj in frame  {&FRAME-NAME}.
END.
ELSE DO:
    rsfl-ch:ADD-LAST("Все", 0).
    rsfl-ch:ADD-LAST("Свободная зона", 1).
    rsfl-ch:ADD-LAST("Зона покупателей", 2).
    rsfl-ch:ADD-LAST("Зона погашения", 3).
    rsfl-ch:ADD-LAST("Зона уничтожения", 4).
    view b-doc-code in frame  {&FRAME-NAME}.
END.

ENABLE b-exit when not p-edit-mode = {&lookup} or p-coll-point ne 'document':U
    b-quit when  p-coll-point = 'document':U
    rsfl-ch
    b-lkp
    br-parts
    b-sch
    b-hist
    b-print
    b-help
    bar-str
    text-sts
    b-mark when p-coll-point = 'document':U and p-edit-mode  <> {&lookup}
    b-mark-all when p-coll-point = 'document':U and p-edit-mode  <> {&lookup}
    B-cancel-mark  when p-coll-point = 'document':U and p-edit-mode  <> {&lookup}
    b-add WHEN p-coll-point = 'document':U AND p-edit-mode <> {&lookup} and not( b-wth-doc.exter_ = no and  b-wth-doc.doc-type = {&income})
    b-chg WHEN p-coll-point = 'document':U AND p-edit-mode = {&UPDATE}
    b-del WHEN p-coll-point = 'document':U AND p-edit-mode = {&UPDATE}
    b-doc-code  WHEN  not p-coll-point = 'document':U
    rsfl-obj when p-coll-point <> {&wth-place}
WITH FRAME {&FRAME-NAME}.
text-sts:screen-value = 'Статус:'.

if p-coll-point = 'document':U then do:
    disable rsfl-ch when p-edit-mode = {&lookup}
            rsfl-obj
    with frame {&FRAME-NAME}.
    rsfl-ch:row = 2.7.
    text-sts:row = 2.7.
    text-sts:move-to-top().
    hide rsfl-obj in frame  {&FRAME-NAME}.
    if p-edit-mode = {&lookup} then  do:
      b-quit:label = 'Выход'.
      rsfl-ch:screen-value = '0'.
    end.
end.
else do:
  run load-position in this-procedure.
  Fn-rs-obj:screen-value = 'Объект:'.
  b-exit:label = 'Выход'.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable l-query-was-opened as logical no-undo .
DEF VAR rsfl-par  AS INT.
DEF VAR zone-list AS CHAR.

DEFINE VARIABLE cur-wth-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE cur-par-val AS INTEGER NO-UNDO.
DEFINE VARIABLE cur-par-unit AS CHARACTER NO-UNDO.
DEFINE VARIABLE cur-ser-name AS CHARACTER NO-UNDO.



DEFINE VARIABLE cur-wth-ext-doc-type AS character NO-UNDO.
DEFINE VARIABLE cur-wth-ext-doc-type-text AS character NO-UNDO.
DEFINE VARIABLE cur-wth-doc-code AS CHARACTER NO-UNDO.
zone-list = SUBSTITUTE('&1,&2,&3,&4',{&free-code},{&cli-zone},{&put-zone},{&output-code}).


ASSIGN FRAME Dialog-Frame rsfl-ch rsfl-obj.
rsfl-par =  rsfl-ch.


IF AVAILABLE b-wealth THEN cur-wth-name = b-wealth.wth-name.
ELSE cur-wth-name = '?':U.
IF AVAILABLE b-wth-par THEN assign cur-par-val  = b-wth-par.par-val
                                   cur-par-unit = b-wth-par.par-unit.
ELSE assign cur-par-val  = ?
            cur-par-unit = '':U.
IF AVAILABLE b-wth-doc THEN do:
    cur-wth-ext-doc-type = b-wth-doc.ext-doc-type.
    cur-wth-ext-doc-type-text = ENTRY (lookup(b-wth-doc.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full }).
    cur-wth-doc-code = b-wth-doc.doc-code.
END.
ELSE do:
    cur-wth-ext-doc-type = '?':U.
    cur-wth-doc-code = '?':U.
END.
if available b-wth-ser then  cur-ser-name = b-wth-ser.series.

run waitfram-show in this-procedure (  input "Ждите...").
define variable sort-column-phrase as character no-undo .

/* sort-column-name = " fact-rangefrom ". */

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


&scop flt-open-open-query OPEN QUERY br-parts FOR EACH X_wth-parts NO-LOCK

&scop flt-open-query-handle QUERY br-parts:handle

&scop flt-open-dyn_open-query FOR EACH X_wth-parts NO-LOCK

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes



CASE p-coll-point:
    when {&wth-par} then do:
         ASSIGN frame {&frame-name}:TITLE = substitute("Партии номинала &1 &2 материальной ценности &3", cur-par-val, cur-par-unit,cur-wth-name ).
         filter-label = substitute("&1", filter-label0).
          { gbl/fltopend.i
            &where-cond = " X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and (rsfl-par = 0 or X_wth-parts.out-code = entry(rsfl-par,zone-list)) ~
                             and (rsfl-obj = 2 or (X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code  ) ) "
            &dyn_where-cond = " SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.par-code = &2 and (&3 = 0 or X_wth-parts.out-code = &9&4&9) ~
                                            and (&5 = 2 or (X_wth-parts.obj-type = &9&6&9 and X_wth-parts.obj-code = &7 ) )'~
                                           , p-wth-code ~
                                           , p-par-code ~
                                           , rsfl-par ~
                                           , IF rsfl-par > 0 then entry(rsfl-par,zone-list) ELSE '':U  ~
                                           , rsfl-obj ~
                                           , p-curr-obj-type ~
                                           , p-curr-obj-code ~
                                           , {&cli-zone} ~
                                           , ~{&double-quote~} ~
                                           ) "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when {&wth-place} then do:
         ASSIGN frame {&frame-name}:TITLE = substitute("Партии серийных МЦ на МХ &1",p-w-p-code ).
         filter-label = substitute("&1", filter-label0).
          { gbl/fltopend.i
            &where-cond = " X_wth-parts.w-p-code = p-w-p-code  and (rsfl-par = 0 or X_wth-parts.out-code = entry(rsfl-par,zone-list)) ~
                          "
            &dyn_where-cond = " SUBSTITUTE( 'X_wth-parts.w-p-code = &1  and (&2 = 0 or X_wth-parts.out-code = &4&3&4)' ~
                                          , p-w-p-code ~
                                          , rsfl-par   ~
                                          , IF rsfl-par > 0 then entry(rsfl-par,zone-list) ELSE '':U  ~
                                          , ~{&double-quote~} ~
                                          ) "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when {&wth-ser} then do:
    filter-label = substitute("&1", filter-label0).
         ASSIGN frame {&frame-name}:TITLE = substitute("Партии серии &1 &2 &3 ",cur-ser-name,
                                                      if cur-par-val > 0 then (" номинала " + string(cur-par-val) + ' ' + cur-par-unit)  else "":U,
                                                      if cur-wth-name > '' then ("материальной ценности " + cur-wth-name) else "" ).
        { gbl/fltopend.i
            &where-cond = " X_wth-parts.wth-code = p-wth-code and X_wth-parts.ser-code = p-ser-code and X_wth-parts.db-num = p-db-num ~
                           and (IF rsfl-par ne 0 THEN X_wth-parts.out-code = entry(rsfl-par,zone-list)  else true ) ~
                           and (rsfl-obj = 2 or (X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code  )  ) "
            &dyn_where-cond = " SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.ser-code = &2 and X_wth-parts.db-num = &3'
                                          , p-wth-code ~
                                          , p-ser-code ~
                                          , p-db-num   ) ~
                                          + ~
                                SUBSTITUTE( ' and (IF &1 ne 0 THEN X_wth-parts.out-code = &7&2&7  else true ) ~
                                              and (&3 = 2 or (X_wth-parts.obj-type = &7&4&7 and X_wth-parts.obj-code = &5  )  )'
                                          , rsfl-par    ~
                                          , IF rsfl-par > 0 then entry(rsfl-par,zone-list) ELSE '':U  ~
                                          , rsfl-obj                  ~
                                          , p-curr-obj-type           ~
                                          , p-curr-obj-code           ~
                                          , {&cli-zone}               ~
                                          , ~{&double-quote~} ~
                                          ) "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when 'document' then do:
    filter-label = substitute("&1", filter-label0).
      ASSIGN frame {&frame-name}:TITLE = substitute("Партии номинала &1 &2 МЦ &3 Документ: &4 № &5 &6 " ,cur-par-val, cur-par-unit, cur-wth-name, cur-wth-ext-doc-type-text ,cur-wth-doc-code, if p-edit-mode = {&lookup} then {&lookup} else "":U).
      /*Документы погашения не учитывают объект и МХ*/
      if  lookup(cur-wth-ext-doc-type,{&WDEDT_List-Put}) > 0 or cur-wth-ext-doc-type = {&WDEDT_Dst_Cli} then do:
          { gbl/fltopend.i
            &where-cond = " X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and  (if cur-wth-ext-doc-type = {&WDEDT_Put_Cli} then X_wth-parts.cli-type = p-cli-type and X_wth-parts.cli-code = p-cli-code else true ) and (if rsfl-par >= 10 then  (X_wth-parts.out-code = p-wth-doc or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) "
            &dyn_where-cond = " SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.par-code = &2 and ~
                                            (if &7&3&7 = &7&4&7 then X_wth-parts.cli-type = &7&5&7 and X_wth-parts.cli-code = &6 else true )' ~
                                          , p-wth-code ~
                                          , p-par-code ~
                                          , cur-wth-ext-doc-type ~
                                          , {&WDEDT_Put_Cli}     ~
                                          , p-cli-type           ~
                                          , p-cli-code           ~
                                          , ~{&double-quote~} ~
                                          ) +                    ~
                                            SUBSTITUTE( 'and (if &1 >= 10 then  (X_wth-parts.out-code = &4&2&4 or X_wth-parts.out-code = &4&3&4) else  ~
                                            (if &1 = 0 then (X_wth-parts.out-code = &4&2&4) else (X_wth-parts.out-code = &4&3&4)) )' ~
                                          , rsfl-par  ~
                                          , p-wth-doc  ~
                                          , IF rsfl-par > 0 then entry(rsfl-par modulo 10,zone-list) ELSE '':U  ~
                                          , ~{&double-quote~} ~
                                          ) "
            &use-ind = "  "
            &by = " by X_wth-parts.fact-rangefrom "
            &dyn_by = " SUBSTITUTE( 'by &1', 'X_wth-parts.fact-rangefrom') "
          }
      end.
      else if  cur-wth-ext-doc-type = {&WDEDT_exch} and p-type = {&income} then do:
          { gbl/fltopend.i
            &where-cond = " X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and ~
                            X_wth-parts.cli-type = p-cli-type and X_wth-parts.cli-code = p-cli-code and  ~
                            (if rsfl-par >= 10 then  ((X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) ~
                            else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type ) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) "
            &dyn_where-cond = " SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.par-code = &2 and ~
                                             X_wth-parts.cli-type = &5&3&5 and X_wth-parts.cli-code = &4 and '  ~
                                          , p-wth-code ~
                                          , p-par-code ~
                                          , p-cli-type ~
                                          , p-cli-code ~
                                          , ~{&double-quote~} ~
                                          ) ~
                                          + ~
                                SUBSTITUTE( '(if &1 >= 10 then  ((X_wth-parts.out-code = &5&2&5 and X_wth-parts.type = &5&3&5) or X_wth-parts.out-code = &5&4&5) ~
                                             else (if &1 = 0 then (X_wth-parts.out-code = &5&2&5 and X_wth-parts.type = &5&3&5 ) else (X_wth-parts.out-code = &5&4&5)) )' ~
                                          , rsfl-par   ~
                                          , p-wth-doc  ~
                                          , p-type     ~
                                          , IF rsfl-par > 0 then entry(rsfl-par modulo 10 ,zone-list) ELSE '':U  ~
                                          , ~{&double-quote~} ~
                                          ) "
            &use-ind = "  "
            &by = " by X_wth-parts.fact-rangefrom "
            &dyn_by = " SUBSTITUTE( 'by &1', 'X_wth-parts.fact-rangefrom') "
          }
      end.
      else if  cur-wth-ext-doc-type = {&WDEDT_exch}         and p-type = {&expense} then do:
          { gbl/fltopend.i
            &where-cond = " X_wth-parts.wth-code = p-wth-code and X_wth-parts.w-p-code = p-w-p-code ~
            and X_wth-parts.par-code = p-par-code and X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code ~
            and (if rsfl-par >= 10 then  ((X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) ~
            else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) "
            &dyn_where-cond = " SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.w-p-code = &2 ~
                                             and X_wth-parts.par-code = &3 and X_wth-parts.obj-type = &6&4&6 and X_wth-parts.obj-code = &5 ' ~
                                          , p-wth-code ~
                                          , p-w-p-code ~
                                          , p-par-code ~
                                          , p-curr-obj-type ~
                                          , p-curr-obj-code ~
                                          , ~{&double-quote~} ~
                                          ) +

                                SUBSTITUTE( 'and (if &1 >= 10 then  ((X_wth-parts.out-code = &5&2&5 and X_wth-parts.type = &5&3&5) or X_wth-parts.out-code = &5&4&5) ~
                                             else (if &1 = 0 then (X_wth-parts.out-code = &5&2&5 and X_wth-parts.type = &5&3&5) else (X_wth-parts.out-code = &5&4&5)) )' ~
                                          , rsfl-par ~
                                          , p-wth-doc ~
                                          , p-type    ~
                                          , IF rsfl-par > 0 then entry(rsfl-par modulo 10,zone-list) ELSE '':U  ~
                                          , ~{&double-quote~} ~
                                          ) "
            &use-ind = "  "
            &by = " by X_wth-parts.fact-rangefrom "
            &dyn_by = " SUBSTITUTE( 'by &1', 'X_wth-parts.fact-rangefrom') "
          }
      end.

      else do:
/*      message  substitute('&1',34) skip   rsfl-par
      view-as alert-box.
      message zone-list skip
      SUBSTITUTE( ' and (if &1 >= 10 then  (X_wth-parts.out-code = &5&2&5 or X_wth-parts.out-code = &5&3&5) else (if &1 = 0 then (X_wth-parts.out-code = &5&2&5) else (X_wth-parts.out-code = &5&4&5)) ) '
                                          , rsfl-par   , p-wth-doc      ,  IF rsfl-par > 0 then entry(rsfl-par - 10,zone-list) ELSE '':U   , IF rsfl-par > 0 then entry(rsfl-par,zone-list) ELSE '':U  , '"'
                                          ) view-as alert-box.  */
      /*run gbl/inidebug.p. */
          { gbl/fltopend.i
            &where-cond = " X_wth-parts.wth-code = p-wth-code and X_wth-parts.w-p-code = p-w-p-code ~
            and X_wth-parts.par-code = p-par-code and X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code ~
            and (if rsfl-par >= 10 then  (X_wth-parts.out-code = p-wth-doc or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) "
            &dyn_where-cond = " SUBSTITUTE( ' X_wth-parts.wth-code = &1 and X_wth-parts.w-p-code = &2 ~
                                             and X_wth-parts.par-code = &3 and X_wth-parts.obj-type = &6&4&6 and X_wth-parts.obj-code = &5 ' ~
                                          , p-wth-code ~
                                          , p-w-p-code ~
                                          , p-par-code ~
                                          , p-curr-obj-type ~
                                          , p-curr-obj-code ~
                                          , ~{&double-quote~} ~
                                          ) ~
                                          + ~
                                SUBSTITUTE( ' and (if &1 >= 10 then  (X_wth-parts.out-code = &4&2&4 or X_wth-parts.out-code = &4&3&4) else (if &1 = 0 then (X_wth-parts.out-code = &4&2&4) else (X_wth-parts.out-code = &4&3&4)) )  ' ~
                                          , rsfl-par ~
                                          , p-wth-doc  ~
                                          , IF rsfl-par > 0 then entry(rsfl-par modulo 10,zone-list) ELSE '':U  ~
                                          , ~{&double-quote~} ~
                                          )  "
            &use-ind = "  "
            &by = " by X_wth-parts.fact-rangefrom "
            &dyn_by = " SUBSTITUTE( 'by &1', 'X_wth-parts.fact-rangefrom') "
          }
      end.
    end.
END CASE.


if v-prt-rec <> ? then reposition br-parts to recid v-prt-rec no-error.
apply "entry" to br-parts in frame {&frame-name}.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED":U to br-parts.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame
PROCEDURE PrintProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable v-obj    as character    no-undo.
define variable v-cli    as character    no-undo.
define variable v-sum-tot as integer     no-undo.
define variable v-price   as character no-undo.
DEFINE FRAME Wth-List
/*X_wth-parts.wth-code       column-label "Код МЦ" */
/*fl-wth-name                column-label "МЦ"  format 'x(15)'   */
v-serName                  column-label "Серия"  format "x(10)"
fl-par-val                 column-label "Номинал"  format "x(5)"
/*v-SerDb                    column-label "Код серии"  */
X_wth-parts.fact-rangeFrom column-label "Диапазон с"  format ">>>>>>>>"
X_wth-parts.fact-rangeTo   column-label "Диапазон по" format ">>>>>>>>"
/*X_wth-parts.par-code       column-label "Код номинала"   */
/*X_wth-parts.w-p-code       column-label "Код МХ"   */
v-w-p-name                 COLUMN-LABEL "MX"     FORMAT "X(14)":U
v-obj                      column-label "Объект"
v-obj-name                 COLUMN-LABEL "Объект"     FORMAT "X(14)":U
v-out-name                 column-label "Зона"
X_wth-parts.in-code        column-label "Накл. порожд."
v-cli                      column-label "Покупатель"  format 'x(20)'
v-price                    column-label "Цена за ед."  format 'x(12)'
X_wth-parts.beg-dt         column-label "Срок годн. с"
X_wth-parts.end-dt         column-label "Срок годн. по"
X_wth-parts.fact-date      column-label "Факт. дата"

HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(190)" AT 1
with width {&A4_LS} down stream-io use-text    .
Line = fill("-", 190).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_LS} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Wth-List  .
run waitfram-show in this-procedure ( input "Ждите...").
v-sum-tot = 0.
GET first BR-parts.
DO WHILE available X_wth-parts :
      FIND FIRST b-wealth WHERE b-wealth.wth-code = X_wth-parts.wth-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wealth THEN fl-wth-name =  b-wealth.wth-name.
      ELSE fl-wth-name = '?':U.
      FIND FIRST b-wth-par WHERE b-wth-par.wth-code =  X_wth-parts.wth-code AND b-wth-par.par-code = X_wth-parts.par-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wth-par THEN assign fl-par-val =  SUBSTITUTE("&1&2",b-wth-par.par-val,b-wth-par.par-unit).

  Display STREAM PrnLibStream
      /*X_wth-parts.wth-code */
    /*  fl-wth-name  */
      /*b-wth-par.par-val @*/ fl-par-val
     /* substitute('&1-&2',X_wth-parts.ser-code,X_wth-parts.db-num) @ v-SerDb */
      get-ser-name(X_wth-parts.ser-code,X_wth-parts.db-num) @ v-serName
      /*X_wth-parts.par-code    */
      X_wth-parts.fact-rangeFrom
      X_wth-parts.fact-rangeTo
           /* X_wth-parts.w-p-code    */
      get-w-p-name(X_wth-parts.w-p-code, X_wth-parts.obj-type,X_wth-parts.obj-code) @ v-w-p-name
      substitute('&1 &2',X_wth-parts.obj-type,X_wth-parts.obj-code) @ v-obj
      get-cli-name(X_wth-parts.obj-type,X_wth-parts.obj-code ) @ v-obj-name   COLUMN-LABEL "Объект"     FORMAT "X(14)":U
            get-wthparts-out-code(X_wth-parts.out-code) @ v-out-name
      X_wth-parts.in-code
      get-cli-name(X_wth-parts.cli-type,X_wth-parts.cli-code ) @ v-cli
      if X_wth-parts.price-rubl > 0 then trim(string((X_wth-parts.price-rubl / b-wth-par.par-val),"->>,>>9.99")) else '':U @ v-price
      X_wth-parts.beg-dt
      X_wth-parts.end-dt
      X_wth-parts.fact-date

  with FRAME Wth-List .
  v-sum-tot = v-sum-tot + X_wth-parts.fact-rangeTo - X_wth-parts.fact-rangeFrom + 1.
  DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
  GET next BR-parts.
END.
UNDERLINE  STREAM PrnLibStream
  /* X_wth-parts.wth-code  */
 /*  fl-wth-name */
    v-serName
   fl-par-val
/*   v-SerDb */
     X_wth-parts.fact-rangeFrom
   X_wth-parts.fact-rangeTo
    /*X_wth-parts.par-code
    X_wth-parts.w-p-code*/
    v-w-p-name
    v-obj
    v-obj-name
    v-out-name
    X_wth-parts.in-code
    v-cli
    v-price
    X_wth-parts.beg-dt
    X_wth-parts.end-dt
    X_wth-parts.fact-date

with FRAME Wth-List .
/*Печать ИТОГО*/
 put STREAM PrnLibStream
  "ИТОГО    " at 20 v-sum-tot at 30 .
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame
PROCEDURE proc-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable rep-rec as recid no-undo.
define variable v-i as int       no-undo.
define variable v-addrid-list as char no-undo.
if b-wth-doc.ext-doc-type = {&WDEDT_Inc_Ext} then do:
  run str/wthpartl.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,INPUT {&add-def}
                ,INPUT p-w-p-code
                ,INPUT p-wth-code
                ,INPUT p-par-code
                ,INPUT p-wth-doc
                ,INPUT p-wth-doc
                ,INPUT 0
                ,INPUT 0
                ,INPUT 0
                ,INPUT 0
                ,INPUT p-type
                ,input-output rep-rec).
  if rep-rec <> ? then
  v-prt-rec = rep-rec.
end.
else do:
    if  available X_wth-parts AND (rid-list = ""  or
        b-mark:sensitive in frame {&frame-name}= no)
    then
    rid-list = string( recid( X_wth-parts ) ) .
    v-addrid-list = rid-list.
    list-block:
    do v-i = 1 to num-entries(v-addrid-list,{&comma-char}):
      rep-rec = int(entry(v-i,v-addrid-list,{&comma-char})).
      for first b-wth-parts no-lock where recid(b-wth-parts) = rep-rec:
        RUN wth-parts-rezerv ( yes
                              ,b-wth-parts.fact-rangeFrom
                              ,b-wth-parts.fact-RangeTo
                              ,b-wth-parts.beg-dt
                              ,b-wth-parts.end-dt
                              ,b-wth-parts.ser-code
                              ,b-wth-parts.db-num
                              ,b-wth-parts.price-rubl
                              ,b-wth-parts.price-base
                              ,b-wth-parts.vat-pc
                              ,b-wth-doc.host-code
                              ,b-wth-doc.obj-type
                              ,b-wth-doc.obj-code
                              ,p-w-p-code
                              ,b-wth-parts.wth-code
                              ,b-wth-parts.par-code
                              ,b-wth-parts.in-code
                              ,b-wth-doc.doc-code
                              ,b-wth-doc.cli-type
                              ,b-wth-doc.cli-code
                              ,b-wth-doc.ext-doc-type
                              ,b-goods.gds-code
                              ,p-type
                              ,INPUT-OUTPUT rep-rec
                              ) no-error .
        if error-status:error then do:
          if v-i =  num-entries(v-addrid-list,{&comma-char}) then do:
            MESSAGE RETURN-VALUE
            VIEW-AS ALERT-BOX error.
            leave list-block.
          end.
          else do:
            MESSAGE RETURN-VALUE skip
                    "Продолжить добавление линий в документ?"
            VIEW-AS ALERT-BOX question buttons yes-no update choice as log.
            if choice then.
            else leave list-block.
          end.
        end.
        v-prt-rec = rep-rec.
      end.
      assign
        entry( lookup(string(rep-rec),rid-list),rid-list ) = "":U
        rid-list = trim( replace( rid-list , {&comma-char} + {&comma-char} , {&comma-char} ) , {&comma-char} )
      .

    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-del Dialog-Frame
PROCEDURE proc-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-i as int no-undo.
define variable v-delrid-list as char no-undo.
define variable rep-rec as recid no-undo.
if  available X_wth-parts AND (rid-list = ""  or
    b-mark:sensitive in frame {&frame-name} = no)
then
rid-list = string( recid( X_wth-parts ) ) .
v-delrid-list = rid-list.
if num-entries(v-delrid-list,{&comma-char}) = 1 then do:
    message
       substitute("Удалить партию из документа. Вы уверены?&1Партия:&1Код МЦ &2&1Код серии&3-&4&1Диапазон &5-&6",
                  {&new-line}
                 ,X_wth-parts.wth-code
                 ,X_wth-parts.ser-code
                 ,X_wth-parts.db-num
                 ,X_wth-parts.fact-rangeFrom
                 ,X_wth-parts.fact-rangeTo)
       view-as alert-box question buttons OK-Cancel update choice as log.
       if not choice then do:
         apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
         return no-apply.
       end.
end.
else do:
  message substitute('Вы действительно хотите удалить &1 партий из документа?',num-entries(v-delrid-list,{&comma-char}))
       view-as alert-box question buttons OK-Cancel update choice .
       if not choice then do:
         apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
         return no-apply.
       end.
end.
list-block:
do v-i = 1 to num-entries(v-delrid-list,{&comma-char}):
  rep-rec = int(entry(v-i,v-delrid-list,{&comma-char})).
  for first b-wth-parts no-lock where recid(b-wth-parts) = rep-rec:
    if b-wth-parts.stts = 0 then do:
        run  wth-doc-razrez ( input RECID(b-wth-parts),
                              input no ) no-error.
        if error-status:error then DO:
          if v-i = num-entries(v-delrid-list,{&comma-char}) then do:
            MESSAGE RETURN-VALUE skip
                  Error-status:get-message(1)
            VIEW-AS ALERT-BOX ERROR.
          end.
          else do:
            MESSAGE RETURN-VALUE skip
                  Error-status:get-message(1)  skip
                  'Продолжить удаление?'
            VIEW-AS ALERT-BOX question buttons yes-no update choice.
            if choice then.
            else leave list-block.
          end.
        end.
    end.
    else do:
      run str/wthpartp.p  ( INPUT  {&update},
                            INPUT  b-wth-parts.obj-type,
                            INPUT  b-wth-parts.obj-code,
                            INPUT  b-wth-parts.w-p-code,
                            INPUT  b-wth-parts.wth-code,
                            INPUT  b-wth-parts.par-code,
                            INPUT  b-wth-parts.in-code ,      /*in-code*/
                            INPUT  b-wth-parts.out-code,
                            INPUT  b-wth-parts.ser-code,
                            INPUT  b-wth-parts.db-num  ,
                            INPUT  b-wth-parts.Fact-RangeFrom ,
                            INPUT  b-wth-parts.fact-rangeTo   ,
                            INPUT  b-wth-parts.doc-RangeFrom ,
                            INPUT  b-wth-parts.doc-rangeTo  ,
                            INPUT  b-wth-parts.host-code     ,
                            INPUT  b-wth-parts.contract-code ,          /* p-contract-code   */
                            INPUT  b-wth-parts.price-rubl    ,
                            INPUT  b-wth-parts.price-base    ,
                            INPUT  b-wth-parts.supp-type,      /* p-supp-type       */
                            INPUT  b-wth-parts.supp-code,      /*p-supp-code        */
                            INPUT  b-wth-parts.in-obj-type      ,          /*p-in-obj-type     */
                            INPUT  b-wth-parts.in-obj-code      ,          /*p-in-obj-code     */
                            INPUT  b-wth-parts.ext-doc-type,  /*p-ext-doc-type    */
                            INPUT  b-wth-parts.gds-code,      /*p-gds-code        */
                            INPUT  0            ,          /*p-stts            */
                            INPUT  b-wth-parts.beg-dt        ,
                            INPUT  b-wth-parts.end-dt        ,
                            INPUT  b-wth-parts.vat-pc        ,
                            INPUT  b-wth-parts.cli-code,                         /*p-cli-code        */
                            INPUT  b-wth-parts.cli-type,                         /*p-cli-type        */
                            INPUT  b-wth-parts.out-obj-code,                         /*p-out-obj-code    */
                            INPUT  b-wth-parts.out-obj-type,                         /*p-out-obj-type    */
                            INPUT  b-wth-parts.sale-obj-code,                         /*p-sale-obj-code   */
                            INPUT  b-wth-parts.sale-obj-type,                         /*p-sale-obj-type   */
                            INPUT  b-wth-parts.doc-code ,
                            INPUT  yes,
                            INPUT   b-wth-parts.type ,
                            INPUT-OUTPUT rep-rec
                  ) no-error.
      if error-status:error then do:
        if v-i = num-entries(v-delrid-list,{&comma-char}) then do:
          MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
        end.
        else do:
          MESSAGE RETURN-VALUE  skip
                  'Продолжить удаление?'
            VIEW-AS ALERT-BOX question buttons yes-no update choice.
            if choice then.
            else leave list-block.
        end.
      end.
    end.
    v-prt-rec = rep-rec.

  end.

  assign
    entry( lookup(string(rep-rec),rid-list),rid-list ) = "":U
    rid-list = trim( replace( rid-list , {&comma-char} + {&comma-char} , {&comma-char} ) , {&comma-char} )
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-position Dialog-Frame
PROCEDURE save-position :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 do
with frame {&frame-name}
on error undo, return error
:
assign rsfl-ch rsfl-obj.
/* message 'save' {&current-position-zone} {&current-position-zone} = 'wthparts-zone'  v-cntxt-userid string( rsfl-ch ) . */

        run uf-set (
              input {&current-position-zone}
            , input v-cntxt-userid
            , input string( rsfl-ch )
            , input {&current-position-zone}
            , input no
            , input no
            , input no
            , input no
        ) no-error .
              run uf-set (
              input {&current-position-obj}
            , input v-cntxt-userid
            , input string( rsfl-obj )
            , input {&current-position-obj}
            , input no
            , input no
            , input no
            , input no
        )  no-error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-doc-code Dialog-Frame
PROCEDURE show-doc-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if not self:sensitive then return.

 for first b-wth-doc no-lock where b-wth-doc.doc-code = fl-doc-code:screen-value in frame Dialog-Frame:
  run str/wthd-lkp.p (INPUT parparentproc ,
                      input recid(b-wth-doc)) no-error.
  if error-status:error then do:
    message return-value skip
    error-status:get-message(1)
    view-as alert-box error.
  end.

 end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( f-cli-type AS CHAR, f-cli-code as int  ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

For FIRST b-clients WHERE b-clients.obj-type = f-cli-type AND
                       b-clients.obj-code = f-cli-code NO-LOCK:
  return   b-clients.obj-name.
end.
RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-ser-name Dialog-Frame
FUNCTION get-ser-name RETURNS CHARACTER
  ( pfser-code AS INT, pfser-db AS INT ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
FOR FIRST buf_wth-ser NO-LOCK WHERE buf_wth-ser.ser-code = pfser-code
                       AND  buf_wth-ser.db-num =  pfser-db:
    RETURN buf_wth-ser.series.
END.
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-w-p-name Dialog-Frame
FUNCTION get-w-p-name RETURNS CHARACTER
  ( vf-w-p-code AS int ,vf-obj-type as char, vf-obj-code as int ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
if vf-w-p-code = 0 or vf-w-p-code = ? then return "":U.
for first buf_wth-place no-lock where buf_wth-place.w-p-code = vf-w-p-code
                                  and buf_wth-place.obj-type = vf-obj-type
                                  and buf_wth-place.obj-code = vf-obj-code:
  return buf_wth-place.w-p-name.
end.
return string(vf-w-p-code).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-wthparts-out-code Dialog-Frame
FUNCTION get-wthparts-out-code RETURNS CHARACTER
  ( vf-out-code AS CHAR ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
CASE vf-out-code:
    WHEN {&free-code}   THEN RETURN 'свободно'.
    WHEN {&output-code} THEN RETURN 'списано'.
    WHEN {&put-zone}    THEN RETURN 'погашено'.
    WHEN {&cli-zone}    THEN RETURN 'у клиента'.
    WHEN {&forged}      THEN RETURN 'фальш.'.
END CASE.
RETURN vf-out-code.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME