&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-codes NO-UNDO LIKE ub.gds-obj
       field gds-name like ub.goods.gds-name
       field b-code like ub.bar-code.b-code
       field prod-name like ub.clients.obj-name
       field max-fact-qnty like ub.gds-obj.fact-qnty
       field max-fact-qnty-obj-type like ub.gds-obj.obj-type
       field max-fact-qnty-obj-code like ub.gds-obj.obj-code
       field b-str like ub.prod-bc.b-str
       field is-mark as logical
       field bc-on-type as character
       field is-glob as logical
       field plu-type as character
       field bc-on as logical
       field cr-db-num as integer
       index pi is unique
       gds-code ASCENDING
       index iin-date
       in-date ASCENDING
       index ib-str is primary
       b-str ASCENDING
       index ibcontype bc-on-type
       index iis-glob is-glob
       index iplu-type plu-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Неиспользуемые коды для весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Неиспользуемые коды для весов" .

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ ref/gdsoattr.i }
{ cmp/obj-list.i new }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/gds-list.i gds-list def " new shared" }
{ gbl/waitfram.i }
{ gbl/usr-flt.i }
{ gbl/getcntxt.i def }
define variable v-db-num like ub.db.db-num no-undo.
define variable v-title-0 as character no-undo.
define variable off-option as character no-undo.
define variable print-option as character no-undo.
define variable v-log-file as character no-undo init "oldscode.log".
define variable v-err-file as character no-undo init "oldscode.err".
define variable loc#log as logical no-undo.
define variable gds-rec as recid no-undo .
define temp-table temp-mark no-undo
field gds-code like ub.goods.gds-code
index pi is primary unique
gds-code.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-codes

/* Definitions for BROWSE BR-goods                                      */
&Scoped-define FIELDS-IN-QUERY-BR-goods b-str temp-codes.bc-on ~
temp-codes.is-mark temp-codes.is-glob temp-codes.plu-type temp-codes.artic ~
temp-codes.gds-code temp-codes.in-date temp-codes.fact-qnty ~
temp-codes.gds-name temp-codes.free-qnty ~
temp-codes.prod-type + string(temp-codes.prod-code) temp-codes.prod-name ~
temp-codes.obj-type + string(temp-codes.obj-code) temp-codes.max-fact-qnty ~
temp-codes.max-fact-qnty-obj-type + string(temp-codes.max-fact-qnty-obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-goods
&Scoped-define QUERY-STRING-BR-goods FOR EACH temp-codes NO-LOCK
&Scoped-define OPEN-QUERY-BR-goods OPEN QUERY BR-goods FOR EACH temp-codes NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-goods temp-codes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-goods temp-codes


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit RECT-b-query B-query b-mark B-off ~
B-goods B-codes B-print B-Help rs-on-off-state v-in-date v-fact-qnty v-tocd ~
BR-goods F-log-file
&Scoped-Define DISPLAYED-OBJECTS rs-on-off-state v-in-date v-fact-qnty ~
v-tocd v-all-count F-log-file v-mark-count

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-title Dialog-Frame
FUNCTION get-title RETURNS CHARACTER
  ( p-in-date as date, p-fact-qnty as decimal, p-on-off-state as logical )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-off
       MENU-ITEM m-one          LABEL "Один код"
       MENU-ITEM m-all          LABEL "Все коды в этом списке"
       MENU-ITEM m-mark         LABEL "Отмеченные коды в этом списке".

DEFINE MENU MENU-B-print
       MENU-ITEM m-list         LABEL "Список неиспользуемых кодов для весов"
       MENU-ITEM m-protocol     LABEL "Протокол результатов работы"
       MENU-ITEM m-errors       LABEL "Протокол ошибок".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-codes
     LABEL "&Коды"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-goods
     LABEL "&Товар"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-off
     LABEL "В&ыключить и/или Удалить"
     SIZE 30 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON B-query
     LABEL "&Отобрать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-log-file AS CHARACTER FORMAT "X(256)":U
     LABEL "Лог"
      VIEW-AS TEXT
     SIZE 50.9 BY .67 NO-UNDO.

DEFINE VARIABLE v-all-count AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Всего"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Количество найденных кодов, удовлетворяющих заданному условию"
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE v-fact-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Max факт.кол-во на объекте <="
     VIEW-AS FILL-IN
     SIZE 10 BY 1 TOOLTIP "Факт.кол-во товара по всем объектам текущей БД" NO-UNDO.

DEFINE VARIABLE v-in-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата посл.прихода<="
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Дата посл.прихода на объект текущей БД" NO-UNDO.

DEFINE VARIABLE v-mark-count AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Отмечено к выключению"
      VIEW-AS TEXT
     SIZE 14.3 BY .67 TOOLTIP "Количество отмеченных кодов"
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE rs-on-off-state AS LOGICAL INITIAL yes
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Включенные", yes,
"Выключенные", no,
"Все", ?
     SIZE 13 BY 2 NO-UNDO.

DEFINE RECTANGLE RECT-b-query
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 12 BY 1
     BGCOLOR 12 FGCOLOR 12 .

DEFINE VARIABLE v-tocd AS LOGICAL INITIAL yes
     LABEL "На кассу"
     VIEW-AS TOGGLE-BOX
     SIZE 14.8 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-goods FOR
      temp-codes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-goods Dialog-Frame _STRUCTURED
  QUERY BR-goods DISPLAY
      b-str COLUMN-LABEL "Код" FORMAT "X(6)":U
      temp-codes.bc-on COLUMN-LABEL "Вкл" FORMAT "+/":U
      temp-codes.is-mark COLUMN-LABEL "*" FORMAT "*/-":U
      temp-codes.is-glob COLUMN-LABEL "Глоб" FORMAT "+/":U
      temp-codes.plu-type COLUMN-LABEL "Тип" FORMAT "X(3)":U
      temp-codes.artic FORMAT "X(16)":U
      temp-codes.gds-code FORMAT "999999999":U
      temp-codes.in-date COLUMN-LABEL "Посл.ПН!в тек.БД" FORMAT "99/99/9999":U
      temp-codes.fact-qnty COLUMN-LABEL "Факт (кол-во)!на всех объ. БД" FORMAT "->>,>>>,>>9.<<<":U
      temp-codes.gds-name COLUMN-LABEL "Название" FORMAT "X(20)":U
      temp-codes.free-qnty COLUMN-LABEL "Свободно (кол-во)!на всех объ. БД" FORMAT "->>,>>>,>>9.<<<":U
      temp-codes.prod-type + string(temp-codes.prod-code) COLUMN-LABEL "П-ль" FORMAT "X(12)":U
      temp-codes.prod-name COLUMN-LABEL "Производитель" FORMAT "X(20)":U
      temp-codes.obj-type + string(temp-codes.obj-code) COLUMN-LABEL "Объект!посл.ПН" FORMAT "X(8)":U
      temp-codes.max-fact-qnty COLUMN-LABEL "Max факт (кол-во)!на объекте БД" FORMAT "->>,>>>,>>9.<<<":U
      temp-codes.max-fact-qnty-obj-type + string(temp-codes.max-fact-qnty-obj-code) COLUMN-LABEL "Объект max!факт кол." FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.77.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-query AT ROW 1 COL 12
     b-mark AT ROW 1 COL 32
     B-off AT ROW 1 COL 41
     B-goods AT ROW 1 COL 71
     B-codes AT ROW 1 COL 81
     B-print AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     rs-on-off-state AT ROW 2 COL 80 NO-LABEL WIDGET-ID 4
     v-in-date AT ROW 4 COL 3.3
     v-fact-qnty AT ROW 4 COL 41.3
     v-tocd AT ROW 4 COL 83.8
     BR-goods AT ROW 5.27 COL 1
     v-all-count AT ROW 2 COL 22.3 COLON-ALIGNED
     F-log-file AT ROW 3 COL 5 COLON-ALIGNED
     v-mark-count AT ROW 3 COL 22.3 COLON-ALIGNED
     RECT-b-query AT ROW 1 COL 11
     SPACE(76.24) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Неиспользуемые коды для весов"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-codes T "?" NO-UNDO ub gds-obj
      ADDITIONAL-FIELDS:
          field gds-name like ub.goods.gds-name
          field b-code like ub.bar-code.b-code
          field prod-name like ub.clients.obj-name
          field max-fact-qnty like ub.gds-obj.fact-qnty
          field max-fact-qnty-obj-type like ub.gds-obj.obj-type
          field max-fact-qnty-obj-code like ub.gds-obj.obj-code
          field b-str like ub.prod-bc.b-str
          field is-mark as logical
          field bc-on-type as character
          field is-glob as logical
          field plu-type as character
          field bc-on as logical
          field cr-db-num as integer
          index pi is unique
          gds-code ASCENDING
          index iin-date
          in-date ASCENDING
          index ib-str is primary
          b-str ASCENDING
          index ibcontype bc-on-type
          index iis-glob is-glob
          index iplu-type plu-type
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-goods v-tocd Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-mark:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-off:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-off:HANDLE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

ASSIGN
       RECT-b-query:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN v-all-count IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-fact-qnty IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-in-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-mark-count IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-goods
/* Query rebuild information for BROWSE BR-goods
     _TblList          = "Temp-Tables.temp-codes"
     _FldNameList[1]   > "_<CALC>"
"b-str" "Код" "X(6)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"temp-codes.bc-on" "Вкл" "+/" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"temp-codes.is-mark" "*" "*~~/-" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"temp-codes.is-glob" "Глоб" "+/" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"temp-codes.plu-type" "Тип" "X(3)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = Temp-Tables.temp-codes.artic
     _FldNameList[7]   = Temp-Tables.temp-codes.gds-code
     _FldNameList[8]   > Temp-Tables.temp-codes.in-date
"temp-codes.in-date" "Посл.ПН!в тек.БД" "99/99/9999" "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > Temp-Tables.temp-codes.fact-qnty
"temp-codes.fact-qnty" "Факт (кол-во)!на всех объ. БД" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > "_<CALC>"
"temp-codes.gds-name" "Название" "X(20)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > Temp-Tables.temp-codes.free-qnty
"temp-codes.free-qnty" "Свободно (кол-во)!на всех объ. БД" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > "_<CALC>"
"temp-codes.prod-type + string(temp-codes.prod-code)" "П-ль" "X(12)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > "_<CALC>"
"temp-codes.prod-name" "Производитель" "X(20)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[14]   > "_<CALC>"
"temp-codes.obj-type + string(temp-codes.obj-code)" "Объект!посл.ПН" "X(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[15]   > "_<CALC>"
"temp-codes.max-fact-qnty" "Max факт (кол-во)!на объекте БД" "->>,>>>,>>9.<<<" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[16]   > "_<CALC>"
"temp-codes.max-fact-qnty-obj-type + string(temp-codes.max-fact-qnty-obj-code)" "Объект max!факт кол." "X(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BR-goods */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Неиспользуемые коды для весов */
OR ENDKEY OF FRAME {&frame-name} DO:
   run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input (if v-mark-count = 0 then "":U else string(v-mark-count))) no-error.
    if error-status:error then return no-apply.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Неиспользуемые коды для весов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-codes Dialog-Frame
ON CHOOSE OF B-codes IN FRAME Dialog-Frame /* Коды */
DO:
 define variable v-main-b-code like ub.bar-code.b-code no-undo.
 if not available temp-codes then return no-apply.
 { gbl/gdsbcode.i temp-codes.gds-code ? v-main-b-code no-error }
 if error-status:error then return no-apply.
 run ref/alt-bc.w (input parparentproc, input v-cntxt-obj-type, v-cntxt-obj-code, v-main-b-code).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-goods Dialog-Frame
ON CHOOSE OF B-goods IN FRAME Dialog-Frame /* Товар */
DO:
  APPLY "F9" to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  run proc-b-mark in this-procedure no-error.
    if error-status:error then do:
        return no-apply.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-off
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-off Dialog-Frame
ON CHOOSE OF B-off IN FRAME Dialog-Frame /* Выключить и/или Удалить */
DO:
  run proc-b-off in this-procedure  no-error.
  if error-status:error then return no-apply.
  run openBr in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
   if error-status:error then do:
    assign
    print-option = "":U
    .
    return no-apply.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-query
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-query Dialog-Frame
ON CHOOSE OF B-query IN FRAME Dialog-Frame /* Отобрать */
DO:
  assign
  v-in-date
  v-fact-qnty
  rs-on-off-state
  .
  run assign-filter in this-procedure ( input v-in-date
                                       ,input v-fact-qnty
                                       ,input rs-on-off-state) no-error.
  run set-query in this-procedure (no).
  run openBr in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-goods
&Scoped-define SELF-NAME BR-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-goods Dialog-Frame
ON INSERT-MODE OF BR-goods IN FRAME Dialog-Frame
DO:
  run proc-b-mark in this-procedure no-error.
    if error-status:error then do:
        return no-apply.
    end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-all Dialog-Frame
ON CHOOSE OF MENU-ITEM m-all /* Все коды в этом списке */
DO:
    assign
   off-option = "all":U.
   run proc-b-off in this-procedure no-error.
   if error-status:error then do:
    assign
    off-option = "":U
    .
    return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-errors
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-errors Dialog-Frame
ON CHOOSE OF MENU-ITEM m-errors /* Протокол ошибок */
DO:
   assign
   print-option = "errors":U.
   run proc-b-print in this-procedure no-error.
   if error-status:error then do:
    assign
    print-option = "":U
    .
    return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-list Dialog-Frame
ON CHOOSE OF MENU-ITEM m-list /* Список неиспользуемых кодов для весов */
DO:
   assign
   print-option = "list":U.
   run proc-b-print in this-procedure no-error.
   if error-status:error then do:
    assign
    print-option = "":U
    .
    return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-mark Dialog-Frame
ON CHOOSE OF MENU-ITEM m-mark /* Отмеченные коды в этом списке */
DO:
  assign
   off-option = "mark":U.
   run proc-b-off in this-procedure no-error.
   if error-status:error then do:
    assign
    off-option = "":U
    .
    return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-one Dialog-Frame
ON CHOOSE OF MENU-ITEM m-one /* Один код */
DO:
  assign
   off-option = "one":U.
   run proc-b-off in this-procedure no-error.
   if error-status:error then do:
    assign
    off-option = "":U
    .
    return no-apply.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-protocol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-protocol Dialog-Frame
ON CHOOSE OF MENU-ITEM m-protocol /* Протокол результатов работы */
DO:
  assign
   print-option = "protocol":U.
   run proc-b-print in this-procedure no-error.
   if error-status:error then do:
    assign
    print-option = "":U
    .
    return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-on-off-state
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-on-off-state Dialog-Frame
ON VALUE-CHANGED OF rs-on-off-state IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-on-off-state.
  run Set-Query in this-procedure (yes).
  run assign-filter in this-procedure ( input v-in-date
                                        ,input v-fact-qnty
                                        ,input rs-on-off-state
                                        ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-fact-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-fact-qnty Dialog-Frame
ON LEAVE OF v-fact-qnty IN FRAME Dialog-Frame /* Max факт.кол-во на объекте <= */
DO:
 if
    v-fact-qnty:screen-value <> string(v-fact-qnty) then do:
        run Set-Query in this-procedure(yes).
    end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-fact-qnty Dialog-Frame
ON RETURN OF v-fact-qnty IN FRAME Dialog-Frame /* Max факт.кол-во на объекте <= */
DO:
   assign
   v-fact-qnty.
   run assign-filter in this-procedure ( input v-in-date
                                        ,input v-fact-qnty
                                        ,input rs-on-off-state
                                        ) no-error.
   if error-status:error then return no-apply.
 Run OpenBr.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-in-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-in-date Dialog-Frame
ON LEAVE OF v-in-date IN FRAME Dialog-Frame /* Дата посл.прихода<= */
DO:
  if
    v-in-date:screen-value <> string(v-in-date) then do:
        run Set-Query in this-procedure (yes).
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-in-date Dialog-Frame
ON RETURN OF v-in-date IN FRAME Dialog-Frame /* Дата посл.прихода<= */
DO:
  assign
   v-in-date.
   run assign-filter in this-procedure ( input v-in-date
                                        ,input v-fact-qnty
                                        ,input rs-on-off-state
                                        ) no-error.
   if error-status:error then return no-apply.
 Run OpenBr.
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
{ gbl/getcntxt.i get }

{ gbl/f2.i br-goods goods-recid get-goods  parparentproc }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first ub.sys-ctrl no-lock.
  assign
  v-db-num =  ub.sys-ctrl.db-num
  .
  RUN MyEnable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-filter Dialog-Frame
PROCEDURE assign-filter :
define input parameter p-in-date as date no-undo .
define input parameter p-fact-qnty as decimal no-undo .
define input parameter p-on-off-state as logical no-undo .
run uf-set in this-procedure(
    input  {&uf-oldscode}
    ,input  v-cntxt-userid
    ,input ("in-date=":U +
            string(p-in-date , "99/99/9999") +   ";" +
            "fact-qnty=":U + string(p-fact-qnty) + ";" +
            "on-off-state=" + (if p-on-off-state = ? then {&question-mark} else string(p-on-off-state))
            )
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-temp Dialog-Frame
PROCEDURE create-temp :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define parameter buffer b_goods for ub.goods.
define parameter buffer b_gds-obj for ub.gds-obj.
define parameter buffer b_gds-obj-attr for ub.gds-obj-attr.
define parameter buffer buf_prod-bc for ub.prod-bc.
define input parameter v-main-b-code as integer no-undo.
define input-output parameter jj as integer   no-undo .
define input-output parameter jj-mark as integer   no-undo .

define variable l-prod-bc-global as logical   no-undo .
define variable l-prod-bc-weight as logical  no-undo .
define buffer b_clients for ub.clients.
Find first temp-codes where
               temp-codes.gds-code = b_goods.gds-code no-error.
 if not available temp-codes then do:
   find first b_clients no-lock where
                       b_clients.obj-type = b_goods.prod-type
                   AND b_clients.obj-code = b_goods.prod-code no-error.
   create temp-codes.
   assign
   temp-codes.bc-on = buf_prod-bc.bc-on
   temp-codes.cr-db-num = buf_prod-bc.cr-db-num
   temp-codes.gds-code = b_goods.gds-code
   temp-codes.b-code = v-main-b-code
   temp-codes.artic = b_goods.artic
   temp-codes.prod-type = b_goods.prod-type
   temp-codes.prod-code = b_goods.prod-code
   temp-codes.gds-name = b_goods.gds-name
   temp-codes.in-date = (if available b_gds-obj then b_gds-obj.in-date else ?)
   temp-codes.obj-type = p-obj-type
   temp-codes.obj-code = p-obj-code
   temp-codes.max-fact-qnty = (if available b_gds-obj then  b_gds-obj.fact-qnty else 0)
   temp-codes.max-fact-qnty-obj-type = p-obj-type
   temp-codes.max-fact-qnty-obj-code = p-obj-code
   temp-codes.b-str = buf_prod-bc.b-str
   temp-codes.free-qnty = (if available b_gds-obj then  b_gds-obj.free-qnty else 0)
   temp-codes.fact-qnty = (if available b_gds-obj then   b_gds-obj.fact-qnty else 0)
   temp-codes.prod-name = (if available b_clients then b_clients.obj-name else "":U)
   temp-codes.bc-on-type = (if available buf_prod-bc
                            then buf_prod-bc.bc-on-type
                            else {&question-mark})
   jj = jj + 1
   .
   if temp-codes.bc-on-type = ''
   then do:
        { gbl/prodbcat.i
          buf_prod-bc
          "'global=request':u"
          l-prod-bc-global
          no-error
        }
        { gbl/prodbcat.i
          buf_prod-bc
          "'weight=request':u"
          l-prod-bc-weight
          no-error
        }
    if error-status:error then do:
      assign
      temp-codes.bc-on-type = {&question-mark}
      .
    end.
    else do:
       if l-prod-bc-global
       and l-prod-bc-weight then do:
         assign
         temp-codes.bc-on-type = {&gbl-sc-code}.
       end.
       if not l-prod-bc-global
       and l-prod-bc-weight then do:
         assign
         temp-codes.bc-on-type = {&loc-sc-code}.
       end.
       if not l-prod-bc-global
       and not l-prod-bc-weight then do:
         assign
         temp-codes.bc-on-type = {&QUESTION-MARK}.

       end.
    end.
   end.
    if temp-codes.bc-on-type <> {&question-mark} then do:
       if temp-codes.bc-on-type = {&gbl-sc-code} then do:
          temp-codes.is-glob = yes.
       end.
       if temp-codes.bc-on-type = {&loc-pg-code} then do:
&scop sc-gds-type ~{&sc-gds-pieces~}
          temp-codes.plu-type = {&sc-gds-type-name}.
       end.
       else do:
&scop sc-gds-type ~{&sc-gds-weight~}
          temp-codes.plu-type = {&sc-gds-type-name}.
       end.
    end.

   find first temp-mark no-lock where
              temp-mark.gds-code = temp-codes.gds-code no-error.
   if avail temp-mark then do:
     assign
     temp-codes.is-mark = yes
     jj-mark = jj-mark + 1
     .
   end.
 end.
 else do:
   if available b_gds-obj then do:
   assign
   temp-codes.obj-type = if b_gds-obj.in-date > temp-codes.in-date
                                      then  b_gds-obj.obj-type
                                      else temp-codes.obj-type
   temp-codes.obj-code = if b_gds-obj.in-date > temp-codes.in-date
                                       then b_gds-obj.obj-code
                                       else temp-codes.obj-code
   temp-codes.in-date = if b_gds-obj.in-date > temp-codes.in-date
                                       then b_gds-obj.in-date
                                       else temp-codes.in-date
   temp-codes.max-fact-qnty-obj-type = if b_gds-obj.fact-qnty > temp-codes.max-fact-qnty
                                      then  b_gds-obj.obj-type
                                      else temp-codes.obj-type
   temp-codes.max-fact-qnty-obj-code = if b_gds-obj.fact-qnty > temp-codes.max-fact-qnty
                                       then b_gds-obj.obj-code
                                       else temp-codes.obj-code
   temp-codes.max-fact-qnty = if b_gds-obj.fact-qnty > temp-codes.max-fact-qnty
                                       then b_gds-obj.fact-qnty
                                       else temp-codes.fact-qnty
   temp-codes.free-qnty = temp-codes.free-qnty +  b_gds-obj.free-qnty
   temp-codes.fact-qnty = temp-codes.free-qnty +  b_gds-obj.fact-qnty
   .
 end.
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
  DISPLAY rs-on-off-state v-in-date v-fact-qnty v-tocd v-all-count F-log-file
          v-mark-count
      WITH FRAME Dialog-Frame.
  ENABLE b-quit RECT-b-query B-query b-mark B-off B-goods B-codes B-print
         B-Help rs-on-off-state v-in-date v-fact-qnty v-tocd BR-goods
         F-log-file
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-goods Dialog-Frame
PROCEDURE get-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_goods for ub.goods .

if not available temp-codes then do:
    gds-rec = ?.
    return.
 end.
find first buf_goods no-lock where
             buf_goods.gds-code = temp-codes.gds-code no-error.
if avail buf_goods then do:
    assign
    gds-rec = recid(buf_goods)
    .
end.


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
run set-filter in this-procedure.

for each ub.clients no-lock where
            ub.clients.db-num = v-db-num:
    { cmp/cr-objls.i ub.clients.obj-type ub.clients.obj-code no-error}
end.
assign
b-print:MENU-MOUSE in frame {&frame-name} = 1
b-off:MENU-MOUSE in frame {&frame-name} = 1
v-title-0 = frame {&frame-name}:title
rs-on-off-state = yes
frame {&frame-name}:title = v-title-0 + get-title(v-in-date, v-fact-qnty, rs-on-off-state).
DISPLAY
v-in-date
v-fact-qnty
v-all-count v-tocd
rs-on-off-state
WITH FRAME {&frame-name} .
ENABLE
b-codes
b-goods
b-print
b-quit
RECT-b-query
B-query
B-off
B-Help
b-mark
BR-goods
v-in-date
v-fact-qnty
v-tocd
rs-on-off-state
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
  run Set-Query in this-procedure (no).
  RUn Openbr in This-Procedure.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define variable v-main-b-code like ub.bar-code.b-code no-undo.
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE jj-mark as integer no-undo .
define variable v-gds-code as integer no-undo .
define buffer b_goods for ub.goods.
define buffer b_units for ub.units.
define buffer b_gds-obj for ub.gds-obj.
define buffer b_gds-obj-attr for ub.gds-obj-attr.
define buffer b_code-range for ub.code-range.
define buffer b_scales-gds for ub.scales-gds.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.

run waitfram-show in this-procedure ("Ждите...Идет поиск товаров").
for each temp-mark:
  delete temp-mark.
end.
for each temp-codes:
  if temp-codes.is-mark then do:
    find first temp-mark where
               temp-mark.gds-code = temp-codes.gds-code no-error.
    if not avail temp-mark then do:
      create
      temp-mark.
      assign
      temp-mark.gds-code = temp-codes.gds-code.
    end.
  end.
  delete temp-codes.
end.
_prod-bc:
for each buf_prod-bc no-lock where
        buf_prod-bc.b-str >= "00100"
     and buf_prod-bc.b-str <= "99999"
     /*and buf_prod-bc.b-str = "00101"*/
     and length(buf_prod-bc.b-str) = 5
     and (rs-on-off-state = ? or buf_prod-bc.bc-on = rs-on-off-state),
    first buf_bar-code no-lock where
        buf_bar-code.b-code = buf_prod-bc.b-code,
    first b_goods No-LOCK where b_goods.gds-code = buf_bar-code.gds-code:
   { gbl/gdsbcode.i b_goods.gds-code ? v-main-b-code  }
  for each obj-list:
    find first b_gds-obj-attr No-LOCK WHERE
              b_gds-obj-attr.gds-code = b_goods.gds-code
          and b_gds-obj-attr.obj-type = obj-list.obj-type
          and b_gds-obj-attr.obj-code = obj-list.obj-code
          AND b_gds-obj-attr.attr-code = {&attr-scales-code-o} no-error.
    if (available b_gds-obj-attr
    and buf_prod-bc.b-str = b_gds-obj-attr.attr-value)
    or not available b_gds-obj-attr then do:
      find first b_scales-gds no-lock where
                b_scales-gds.b-code = v-main-b-code
            and b_scales-gds.obj-type = obj-list.obj-type
            and b_scales-gds.obj-code = obj-list.obj-code  no-error.
      if available b_scales-gds then do:
        NEXT _prod-bc.
      end.
    end. /*if (available b_gds-obj-attr*/
  end. /*  for each obj-list,*/
  for each obj-list:
    find first b_gds-obj no-lock where
              b_gds-obj.obj-type = obj-list.obj-type
          and b_gds-obj.obj-code = obj-list.obj-code
          and b_gds-obj.gds-code = b_goods.gds-code
          no-error.
    if available b_gds-obj then do:
   if b_gds-obj.in-date > v-in-date    then do:
     v-gds-code = b_goods.gds-code.
        NEXT _prod-bc.
   end.
   if b_gds-obj.fact-qnty > v-fact-qnty then do:
     v-gds-code = b_goods.gds-code.
        NEXT _prod-bc.
      end. /*if b_gds-obj.fact-qnty > v-fact-qnty then do:*/
    end. /*if available b_gds-obj then do:*/
    run create-temp in this-procedure ( input obj-list.obj-type
                                      ,input obj-list.obj-code
                                      ,buffer b_goods
                                      ,buffer b_gds-obj
                                      ,buffer b_gds-obj-attr
                                      ,buffer buf_prod-bc
                                      ,input v-main-b-code
                                      ,input-output jj
                                      ,input-output jj-mark).
  end. /*  for each obj-list,*/
  run waitfram-show in this-procedure (("Ждите...Идет поиск товаров. Найдено") + {&space-char} + string(jj)).
END. /*for each buf_prod-bc no-lock where*/
   assign
frame {&frame-name}:title = v-title-0 + get-title(v-in-date, v-fact-qnty, rs-on-off-state)
  v-all-count = jj
  v-mark-count = jj-mark
  .
if v-mark-count > 0 then do:
    display
    v-mark-count with frame {&frame-name}.
end.
else do:
    HIDE
    v-mark-count in frame {&frame-name}.
end.
display
v-all-count
with frame {&frame-name}.
run waitfram-hide in this-procedure .
{&OPEN-QUERY-BR-goods}
reposition br-goods to row 1.
APPLY "ENTRY" to br-goods.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame
PROCEDURE proc-b-mark :
define variable glog as logical no-undo .
define buffer buf_temp-codes for temp-codes.
    if not avail temp-codes then do:
        return error.
    end.
  find first buf_temp-codes where recid(buf_temp-codes) = recid(temp-codes) no-error.
    if not avail buf_temp-codes then do:
      return error.
  end.
  assign
    v-mark-count = v-mark-count + (if  not buf_temp-codes.is-mark then 1 else (  - 1))
  buf_temp-codes.is-mark = not buf_temp-codes.is-mark
  .
  display
  temp-codes.is-mark with browse br-goods.
  if v-mark-count > 0 then
  display v-mark-count with frame {&frame-name}.
  else do:
        hide
        v-mark-count in frame {&frame-name}.
  end.
    glog = br-goods:select-next-row () in frame {&frame-name}.
    apply "VALUE-changed" to br-goods in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-off Dialog-Frame
PROCEDURE proc-b-off :
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE v-ii as integer no-undo .
define variable choice as integer no-undo .
define variable v-msg as character no-undo .
define variable glog as logical no-undo.
define buffer buf_temp-codes for temp-codes.
define buffer buf_prod-bc for ub.prod-bc.
do
on error undo, return error
:
if off-option = "":U then do:
   run gbl/pop-up.p (b-off:handle in frame {&frame-name}, no) no-error.
end.
if off-option = "":U then do:
    return error.
end.
.
if not available temp-codes then do:
  assign
  off-option = "":U
  .
  return error.
end.
if temp-codes.is-glob then do:
  message
  "Пока нет возможности выключить ГЛОБАЛЬНЫЙ код для весов"
  view-as alert-box error.
  undo, return error.
end.
assign
frame {&frame-name}
v-tocd.
run gbl/d-askw.w (input "Вопрос"
                ,input  substitute("Выберите действие, которое Вы хотите произвести над кодами&1"+
                                   "Удаление рекомендуется выбирать ТОЛЬКО в том случае,&1если предполагается в дальнейшем удалить ДИАПАЗОН кодов"
                                  , {&new-line})
                ,input "|"
                ,input "Выключить|Выключить (если включен) и Удалить|Отменить"
                ,input "||"
                ,input 1
                ,input 3
                ,output choice).
if choice = 3 then do:
  undo, return .
end.

CASE off-option:
    when "one":U then do:
      message
      substitute("Вы действительно хотите &7 локальный код для весов &2&1" +
                 "для товара &3 &4&5 &6 ?":U
                  ,{&new-line}
                  ,temp-codes.b-str
                  ,temp-codes.artic
                  ,temp-codes.prod-type
                  ,temp-codes.prod-code
                  ,temp-codes.gds-name
                  ,(if choice = 1 then "выключить" else "выключить и удалить")
                  )
      view-as alert-box QUESTION buttons YES-NO update loc#log.
      if not loc#log then do:
        assign
        off-option = "":U
        .
        return error.
      end.
      run set-file-title in this-procedure (v-log-file, output F-log-file) .
      display
      f-log-file
      with frame {&frame-name}.
      run waitfram-show in this-procedure ("Ждите...").
      if temp-codes.plu-type = "Весовой" then do :
        find first ub.goods no-lock
             where ub.goods.gds-code = temp-codes.gds-code no-error.
        if available ub.goods then do :
          { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_alt-barcode_loc-pg-code':U
          {&cntxt-global}
          0
          '':U
          0
          0
          ub.goods.grp-code
          0
          false
          glog
          }
        end.
        else do :
         glog = false.
        end.
        if not glog then do :
          v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБК &5 : недоступно право actn_alt-barcode_loc-pg-code - добавление лок. шт. кода для весов  "
                            ,temp-codes.artic
                            ,temp-codes.prod-type
                            ,temp-codes.prod-code
                            ,temp-codes.gds-code
                            ,temp-codes.b-str)

          .
          run write-file in this-procedure ( input v-msg).
        end.
      end.
      if temp-codes.plu-type = "Штучный" then do :
        find first ub.goods no-lock
             where ub.goods.gds-code = temp-codes.gds-code no-error.
        if available ub.goods then do :
          { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_alt-barcode_loc-sc-code':U
          {&cntxt-global}
          0
          '':U
          0
          0
          ub.goods.grp-code
          0
          false
          glog
          }
        end.
        else do :
         glog = false.
        end.
        if not glog then do :
          v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБК &5 : недоступно право actn_alt-barcode_loc-sc-code - выключение лок. вес. кодов  "
                            ,temp-codes.artic
                            ,temp-codes.prod-type
                            ,temp-codes.prod-code
                            ,temp-codes.gds-code
                            ,temp-codes.b-str)

          .
          run write-file in this-procedure ( input v-msg).
        end.
      end.
      if glog then do :
        do transaction:
        if temp-codes.bc-on = yes then do:
        run trg/bc-upd.p (
                                  input parparentproc
                                  ,input temp-codes.b-code
                                  ,input temp-codes.b-str
                                  ,input no /*action - выкл*/
                                  ,input no  /*mute*/
                                  ,input v-tocd /*send-ref*/
                                  ,input ? /*same-recid */
                                  ,input this-procedure:handle
                                  ) no-error.
        if error-status:error then do:
            run waitfram-hide in this-procedure .
            assign
            off-option = "":U
            .
              undo, return error.
            end. /*          if error-status:error then do:*/
          end. /*if temp-codes.bc-on = yes then do:*/
          if choice = 2 then do:
            find first buf_prod-bc exclusive-lock
                  where buf_prod-bc.b-str = temp-codes.b-str
                    and buf_prod-bc.b-code = temp-codes.b-code no-error.
            if not available buf_prod-bc then do:
              assign
              v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБК &5 не найден при попытке удаления"
                                ,temp-codes.artic
                                ,temp-codes.prod-type
                                ,temp-codes.prod-code
                                ,temp-codes.gds-code
                                ,temp-codes.b-str)
              .
              run write-file in this-procedure ( input v-msg).
              run waitfram-hide in this-procedure .
              assign
              off-option = "":U
              .
              undo, return error.
            end. /*if not available buf_prod-bc then do:*/
            if not (buf_prod-bc.bc-on = no) then do:
              assign
              v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБК &5 все еще включен - удалить невозможно"
                                ,temp-codes.artic
                                ,temp-codes.prod-type
                                ,temp-codes.prod-code
                                ,temp-codes.gds-code
                                ,temp-codes.b-str)
              .
              run write-file in this-procedure ( input v-msg).
              run waitfram-hide in this-procedure .
              assign
              off-option = "":U
              .
              undo, return error.
            end. /*if not (buf_prod-bc.bc-on = no) then do:*/
            if buf_prod-bc.cr-db-num <> v-cntxt-db-num then do:
              assign
              v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБК &5 создан в другой БД (&6) - удалить невозможно"
                                ,temp-codes.artic
                                ,temp-codes.prod-type
                                ,temp-codes.prod-code
                                ,temp-codes.gds-code
                                ,temp-codes.b-str
                                ,temp-codes.cr-db-num
                                )
              .
              run write-file in this-procedure ( input v-msg).
              run waitfram-hide in this-procedure .
              assign
              off-option = "":U
              .
              undo, return error.
            end.
            delete buf_prod-bc no-error.
            if error-status:error then do:
              assign
              v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБК &5 ошибка при удалении:&6&7&6&8"
                                ,temp-codes.artic
                                ,temp-codes.prod-type
                                ,temp-codes.prod-code
                                ,temp-codes.gds-code
                                ,temp-codes.b-str
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )
              .
              run write-file in this-procedure ( input v-msg).
              run waitfram-hide in this-procedure .
              assign
              off-option = "":U
              .
              undo, return error.
        end.
          end. /*if choice = 2 then do:*/
        end. /*do transaction*/
        run waitfram-hide in this-procedure .
        find first buf_temp-codes where
                      buf_temp-codes.gds-code = temp-codes.gds-code no-error.
        if available buf_temp-codes then do:
            delete buf_temp-codes.
        end.
      end.
    end. /*when "one":U then do:*/
    when "all":U or when "mark":U then do:
      if off-option = "all":U then do:
        if choice = 1 then do:
        message
        "Вы действительно хотите выключить все коды для весов, входящие в список?"
        view-as alert-box QUESTION buttons YES-NO update loc#log.
     end.
      else do:
        message
          "Вы действительно хотите выключить и удалить все коды для весов, входящие в список?"
          view-as alert-box QUESTION buttons YES-NO update loc#log.
        end.
     end.
      else do:
        if choice = 1 then do:
          message
        "Вы действительно хотите выключить все отмеченные коды для весов?"
        view-as alert-box QUESTION buttons YES-NO update loc#log.
      end.
        else do:
          message
          "Вы действительно хотите выключить и удалить все отмеченные коды для весов?"
          view-as alert-box QUESTION buttons YES-NO update loc#log.
        end.
      end.
      if not loc#log then do:
        assign
        off-option = "":U
        .
        return error.
      end.
      run set-file-title in this-procedure (v-log-file, output F-log-file) .
      display
      f-log-file
      with frame {&frame-name}.
      _temp-codes:
      for each buf_temp-codes :
        if temp-codes.plu-type = "Весовой" then do :
          find first ub.goods no-lock
              where ub.goods.gds-code = temp-codes.gds-code no-error.
          if available ub.goods then do :
            { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_alt-barcode_loc-pg-code':U
            {&cntxt-global}
            0
            '':U
            0
            0
            ub.goods.grp-code
            0
            false
            glog
            }
          end.
          else do :
          glog = false.
          end.
          if not glog then do :
            v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБК &5 : недоступно право actn_alt-barcode_loc-pg-code - добавление лок. шт. кода для весов  "
                              ,temp-codes.artic
                              ,temp-codes.prod-type
                              ,temp-codes.prod-code
                              ,temp-codes.gds-code
                              ,temp-codes.b-str)

            .
            run write-file in this-procedure ( input v-msg).
          end.
        end.
        if temp-codes.plu-type = "Штучный" then do :
          find first ub.goods no-lock
              where ub.goods.gds-code = temp-codes.gds-code no-error.
          if available ub.goods then do :
            { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_alt-barcode_loc-sc-code':U
            {&cntxt-global}
            0
            '':U
            0
            0
            ub.goods.grp-code
            0
            false
            glog
            }
          end.
          else do :
          glog = false.
          end.
          if not glog then do :
            v-msg = substitute("Товар: &1&2&3 код товара &4 ДопБК &5 : недоступно право actn_alt-barcode_loc-sc-code - выключение лок. вес. кодов  "
                              ,temp-codes.artic
                              ,temp-codes.prod-type
                              ,temp-codes.prod-code
                              ,temp-codes.gds-code
                              ,temp-codes.b-str)

            .
            run write-file in this-procedure ( input v-msg).
          end.
        end.
        if glog then do :
        if off-option = "mark":U and buf_temp-codes.is-mark = no then NEXT.
        assign
        v-ii = v-ii + 1
        .
        run waitfram-show in this-procedure ("Обработано" + {&space-char} + string(v-ii)).
        run trg/bc-upd.p (
                                 input parparentproc
                                ,input buf_temp-codes.b-code
                                ,input buf_temp-codes.b-str
                                ,input no /*action - выкл*/
                                ,input yes  /*mute*/
                                ,input v-tocd /*send-ref*/
                                ,input ? /*same-recid */
                                ,input this-procedure:handle
                                ) no-error.
        if not error-status:error then do:
          if choice = 2 then do:
            find first buf_prod-bc exclusive-lock
                  where buf_prod-bc.b-str = temp-codes.b-str
                    and buf_prod-bc.b-code = temp-codes.b-code no-error.
            if not available buf_prod-bc then do:
              next _temp-codes.
            end. /*if not available buf_prod-bc then do:*/
            if not (buf_prod-bc.bc-on = no) then do:
              next _temp-codes.
        end.
            delete buf_prod-bc no-error.
            if error-status:error then do:
              next _temp-codes.
      end.
          end. /*if not error-status:error then do:*/
          delete buf_temp-codes.
        end.  /*if glog*/
        end. /*      for each buf_temp-codes :*/
      end. /*when "all":U or when "mark":U then do:*/
     run waitfram-hide in this-procedure .
  end.
END CASE.
end.
run openbr in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
define variable v-today as date no-undo.
define variable v-time as integer no-undo.
define variable v-user-action   as character no-undo .
define variable v-printed       as logical   no-undo .
define variable accum-count as integer no-undo.
define variable for-prod   as character no-undo .
define variable for-obj   as character no-undo .
define variable for-max-fact-qnty-obj   as character no-undo .
define variable date_string   as character no-undo .
define variable Line   as character no-undo .
define variable v-doc-rec as recid no-undo .


DEFINE FRAME B-str-List
temp-codes.b-str       column-label "Код"                format "X(6)"
temp-codes.bc-on     column-label "Вкл" format "+/"
temp-codes.is-glob  column-label "Глоб" format "+/"
temp-codes.plu-type  column-label "Тип" format "X(3)"
temp-codes.artic
temp-codes.gds-code
temp-codes.gds-name COLUMN-LABEL "Название" FORMAT "X(20)"
for-prod /*temp-codes.prod-type + string(temp-codes.prod-code)*/  COLUMN-LABEL "П-ль" FORMAT "X(12)"
temp-codes.prod-name COLUMN-LABEL "Производитель" FORMAT "X(20)"
temp-codes.in-date COLUMN-LABEL "Посл.ПН!в тек.БД" FORMAT "99/99/9999"
for-obj /*temp-codes.obj-type + string(temp-codes.obj-code) */ COLUMN-LABEL "Объект!посл.ПН" FORMAT "X(8)"
temp-codes.fact-qnty COLUMN-LABEL "Факт (кол-во)!на всех объ. БД"
temp-codes.free-qnty COLUMN-LABEL "Свободно (кол-во)!на всех объ. БД"
temp-codes.max-fact-qnty COLUMN-LABEL "Max факт. (кол-во)!на объ. БД"
for-max-fact-qnty-obj /*temp-codes.max-fact-qnty-obj-type + string(temp-codes.max-fact-qnty-obj-code) */
                     COLUMN-LABEL "Объект max!факт (кол.)" FORMAT "X(8)"
HEADER  date_string format "X(50)" AT 5
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(148)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .
run cur-time in this-procedure(output v-today, output v-time).
assign
date_String = cur-time-print()
Line = fill("-", 179).
.
define buffer buf_temp-codes for temp-codes.
if print-option = "":U then do:
   run gbl/pop-up.p (b-print:handle in frame {&frame-name}, no) no-error.
end.
if print-option = "":U then do:
    return error.
end.

CASE print-option:
    when "protocol":U then do:
       file-info:file-name = v-log-file.
       if file-info:full-pathname = ? then do:
         message
         substitute("Не найден или еще не создавался файла протокола &1", v-log-file)
         view-as alert-box error .
         undo, return error .
       end.
       run gbl/prnfilen.w
         (input  "Протокол"
         ,input  0
         ,input  v-log-file
         ,input  7
         ,output v-user-action
         ,output v-printed
         ).
    end.
    when "errors":U then do:
       file-info:file-name = v-err-file.
       if file-info:full-pathname = ? then do:
         message
         substitute("Не найден или еще не создавался файл ошибок &1", v-err-file)
         view-as alert-box error .
         undo, return error .
       end.
       run gbl/prnfilen.w
         (input  "Ошибки"
         ,input  0
         ,input  v-err-file
         ,input  7
         ,output v-user-action
         ,output v-printed
         ).
    end.
    when "list":U then do:
      v-doc-rec = recid( temp-codes ).
      DO WHILE available temp-codes :
            GET prev br-goods.
      END.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
        Line format "X(179)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME B-str-list  .
    run waitfram-show in this-procedure ("Ждите...").
    GET next br-goods.
    DO WHILE available temp-codes :
      Display STREAM PrnLibStream
      temp-codes.bc-on
      temp-codes.b-str
      temp-codes.artic
      temp-codes.gds-code
      temp-codes.gds-name
      temp-codes.prod-type + string(temp-codes.prod-code) @ for-prod
      temp-codes.prod-name
      temp-codes.in-date
      temp-codes.obj-type + string(temp-codes.obj-code) @ for-obj
      temp-codes.fact-qnty
      temp-codes.free-qnty
      temp-codes.max-fact-qnty
      temp-codes.max-fact-qnty-obj-type + string(temp-codes.max-fact-qnty-obj-code) @ for-max-fact-qnty-obj
      with FRAME B-str-list .
      DOWN STREAM PrnLibStream 1 with FRAME B-str-list  .
      assign
      accum-count = accum-count + 1
      .
      GET next br-goods.
  END.
    UNDERLINE  STREAM PrnLibStream
    temp-codes.bc-on
    temp-codes.b-str
    temp-codes.artic
    temp-codes.gds-code
    temp-codes.gds-name
    for-prod
    temp-codes.prod-name
    temp-codes.in-date
    for-obj
    temp-codes.fact-qnty
    temp-codes.free-qnty
    temp-codes.max-fact-qnty
    for-max-fact-qnty-obj
     with FRAME B-str-list .
     DISPLAY STREAM PrnLibStream
     "ИТОГО"  @ temp-codes.b-str
     accum-count @ temp-codes.gds-code
     with frame B-str-list.
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.

    reposition br-goods to recid v-doc-rec no-error.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 8
                                              ).

  end.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-file-title Dialog-Frame
PROCEDURE set-file-title :
define input parameter p-filename as character no-undo.
define output parameter p-full-path as character no-undo.

define variable v-today as date no-undo.
define variable v-time as integer no-undo.
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .


output stream PrnLibStream to value(p-filename) append.
run cur-time in this-procedure(output v-today, output v-time).
Put stream PrnLibStream unformatted
"**************************************************" skip
"USER:":U v-cntxt-userid skip
string(v-today, "99/99/9999") {&space-char} string(v-time, "HH:MM:SS")
skip.
output stream PrnLibStream close.

run gbl/filename.p (
                         input p-filename
                        ,output p-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter Dialog-Frame
PROCEDURE set-filter :
define variable v-today as date no-undo.
define variable v-time as integer no-undo.
define variable v-dop as character no-undo.
run cur-time in this-procedure(output v-today, output v-time).

run uf-get in this-procedure(
    input  {&uf-oldscode}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and num-entries(v-uf-List_, ";") >= 2 then do:
 assign
 v-dop = entry(2, entry(1, v-uf-list_, ";"), "=")
 v-in-date = date(integer(entry(2, v-dop, {&slash-char})),
                  integer(entry(1, v-dop, {&slash-char})),
                  integer(entry(3, v-dop, {&slash-char}))
                 )
 v-dop = entry(2, entry(2, v-uf-list_, ";"), "=")
 v-fact-qnty = decimal(v-dop)
 v-dop = (if num-entries(v-uf-List_, ";") > 2
          then entry(2, entry(3, v-uf-list_, ";"), "=")
          else string(yes))
 rs-on-off-state = logical(v-dop)
.
end.
else do:
  run uf-set in this-procedure(
      input  {&uf-oldscode}
      ,input  v-cntxt-userid
      ,input  ("in-date=":U +
            string(date(Month(v-today), day(v-today), Year(v-today) - 1) , "99/99/9999") +
                   ";" + "fact-qnty=":U + string(0.5) +
                   ";" + "on-off-state=" + string(yes))
      ,input v-uf-Naim
      ,input v-uf-print-graft
      ,input v-uf-sort-gr
      ,input v-uf-type-price
      ,input v-uf-type-val
  )  no-error .
 assign
 v-in-date = v-today
 v-fact-qnty = 0.5
 rs-on-off-state = yes
 .
end.
display
v-in-date
v-fact-qnty
rs-on-off-state
with frame {&frame-name}
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Set-Query Dialog-Frame
PROCEDURE Set-Query :
define input parameter p-l as logical no-undo.
CASE p-l:
    when yes then do:
        Display
        RECT-b-query with frame {&frame-name}.
    end.
    when no then do:
        HIDE
        RECT-b-query in frame {&frame-name}.
    end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-file Dialog-Frame
PROCEDURE write-file :
define input parameter p-message as character no-undo.
output stream PrnLibstream to value(v-log-file) append.
put stream PrnLibStream unformatted p-message skip.
output stream Prnlibstream close.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-title Dialog-Frame
FUNCTION get-title RETURNS CHARACTER
  ( p-in-date as date, p-fact-qnty as decimal, p-on-off-state as logical ) :
define variable v-str as character no-undo.
  assign
    v-str = {&space-char} + "Посл. дата ПН" + {&space-char} + string(p-in-date) + {&comma-char} +
            {&space-char} + "Max факт.кол-во на объекте<=" + {&space-char} + string(p-fact-qnty) + {&comma-char} +
            {&space-char} + "Вкл/выкл=" + {&space-char} + string(p-on-off-state)
               .


  RETURN v-str.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
