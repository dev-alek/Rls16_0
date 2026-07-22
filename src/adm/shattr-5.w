&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR thbj-attr.
DEFINE BUFFER X_shop FOR shop.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "cd-inf-send"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'cd-inf-send'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ gbl/gdcstcod.i }
{ str/name-2cd.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/dct-algo.i }
{ gbl/key-rec.i }
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE l-name-2cd-init AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok            AS logical   NO-UNDO.
define variable v-tbl-row       as rowid     no-undo .
define variable v-tbl-name      as character no-undo .
define buffer buf_ext-system for ub.ext-system.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define temp-table br-thbj-attr no-undo like ub.thbj-attr
field prop-code-label as character
field prop-value-label as character
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-how-disc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES br-thbj-attr

/* Definitions for BROWSE br-how-disc                                   */
&Scoped-define FIELDS-IN-QUERY-br-how-disc br-thbj-attr.prop-code-label br-thbj-attr.prop-value-label   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-how-disc   
&Scoped-define SELF-NAME br-how-disc
&Scoped-define QUERY-STRING-br-how-disc FOR EACH br-thbj-attr where br-thbj-attr.prop-code begins "how"
&Scoped-define OPEN-QUERY-br-how-disc OPEN QUERY {&SELF-NAME} FOR EACH br-thbj-attr where br-thbj-attr.prop-code begins "how".
&Scoped-define TABLES-IN-QUERY-br-how-disc br-thbj-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-how-disc br-thbj-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-how-disc}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RECT-dopname RECT-name ~
t-tax-cass t-nam-2str t-nam-artc t-cod-pcod RS-name-2cd t-cp-is-use ~
RS-amntdisc code_system b-system b-chg br-how-disc l-no-chk-name l-chk-name ~
l-name-2cd l-no-part l-part l-amntdisc 
&Scoped-Define DISPLAYED-OBJECTS t-tax-cass t-nam-2str t-nam-artc ~
t-cod-pcod RS-name-2cd t-cp-is-use RS-amntdisc code_system l-no-chk-name ~
l-chk-name l-name-2cd l-no-part l-part l-amntdisc t-cp-is-use-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-system 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE VARIABLE code_system AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код внешней системы для передачи соответствий на кассу" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE l-amntdisc AS CHARACTER FORMAT "X(256)":U INITIAL "Тип скидки на товар на кассе" 
      VIEW-AS TEXT 
     SIZE 31.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-chk-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "задано назв. на чеке" 
      VIEW-AS TEXT 
     SIZE 24.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-name-2cd AS CHARACTER FORMAT "X(256)":U INITIAL "Что посылать на кассу как дополн. назв. товара" 
      VIEW-AS TEXT 
     SIZE 92 BY .67 NO-UNDO.

DEFINE VARIABLE l-no-chk-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "не задано название на чеке" 
      VIEW-AS TEXT 
     SIZE 18 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-no-part AS CHARACTER FORMAT "X(256)":U 
     LABEL "при продаже не по партиям" 
      VIEW-AS TEXT 
     SIZE 18 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-part AS CHARACTER FORMAT "X(256)":U 
     LABEL "при продаже по партиям" 
      VIEW-AS TEXT 
     SIZE 19 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-cp-is-use-2 AS CHARACTER FORMAT "X(256)":U INITIAL "касс.платежей с атриб-м ИСПОЛЬЗУЕТСЯ" 
      VIEW-AS TEXT 
     SIZE 37.5 BY .67 NO-UNDO.

DEFINE VARIABLE RS-amntdisc AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Категорийная", 0,
"Скидка на количество - POS IBM", 1,
"Категорийная и скидка на кол-во - POS IBM spool = 6", 2,
"Скидка на количество - POS NCR", 3
     SIZE 55.5 BY 3.5 NO-UNDO.

DEFINE VARIABLE RS-name-2cd AS CHARACTER INITIAL "name" 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Англ. название", "name",
"Локальный код/код партии ", "code",
"Код ГТД", "GTD",
"Страна|Код ГТД", "alpha1|GTD",
"PLU кассы", "PLU"
     SIZE 92.5 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-dopname
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 96 BY 5.88.

DEFINE RECTANGLE RECT-name
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 96 BY 4.42.

DEFINE VARIABLE t-cod-pcod AS LOGICAL INITIAL no 
     LABEL "Как дополн. назв. при передаче на кассу - локальный код товара или код партии" 
     VIEW-AS TOGGLE-BOX
     SIZE 79.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-cp-is-use AS LOGICAL INITIAL no 
     LABEL "На кассу передавать только типы касс. платежей с атрибутом ИСПОЛЬЗУЕТСЯ" 
     VIEW-AS TOGGLE-BOX
     SIZE 37 BY 1 NO-UNDO.

DEFINE VARIABLE t-nam-2str AS LOGICAL INITIAL no 
     LABEL "Передача основного названия товара на кассу в две строки" 
     VIEW-AS TOGGLE-BOX
     SIZE 83 BY 1 NO-UNDO.

DEFINE VARIABLE t-nam-artc AS LOGICAL INITIAL no 
     LABEL "Как основн. назв. при передаче на кассу - англ. название товара или артикул" 
     VIEW-AS TOGGLE-BOX
     SIZE 82 BY 1 NO-UNDO.

DEFINE VARIABLE t-tax-cass AS LOGICAL INITIAL no 
     LABEL "Передача налогов на кассу" 
     VIEW-AS TOGGLE-BOX
     SIZE 83 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-how-disc FOR 
      br-thbj-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-how-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-how-disc Dialog-Frame _FREEFORM
  QUERY br-how-disc DISPLAY
      br-thbj-attr.prop-code-label COLUMn-LABEL "Тип скидки" format "X(45)"
br-thbj-attr.prop-value-label COLUMn-LABEL "Способ задания" format "X(45)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 4.63 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     t-tax-cass AT ROW 2.25 COL 3.5
     t-nam-2str AT ROW 3.42 COL 3.5
     t-nam-artc AT ROW 4.5 COL 3.5
     t-cod-pcod AT ROW 8.08 COL 3.5
     RS-name-2cd AT ROW 10.08 COL 4.5 NO-LABEL
     t-cp-is-use AT ROW 14 COL 61
     RS-amntdisc AT ROW 14.92 COL 4 NO-LABEL
     code_system AT ROW 18.5 COL 58.13 COLON-ALIGNED WIDGET-ID 10
     b-system AT ROW 18.5 COL 80.75 WIDGET-ID 8
     b-chg AT ROW 18.58 COL 89 WIDGET-ID 4
     br-how-disc AT ROW 19.58 COL 1 WIDGET-ID 100
     l-no-chk-name AT ROW 6.58 COL 29.5 COLON-ALIGNED
     l-chk-name AT ROW 6.58 COL 70 COLON-ALIGNED
     l-name-2cd AT ROW 9.29 COL 2 COLON-ALIGNED NO-LABEL
     l-no-part AT ROW 12.58 COL 30 COLON-ALIGNED
     l-part AT ROW 12.58 COL 75 COLON-ALIGNED
     l-amntdisc AT ROW 13.92 COL 2.5 COLON-ALIGNED NO-LABEL
     t-cp-is-use-2 AT ROW 15 COL 59 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     "При данных настройках на кассу как допл. назв. товара будет передано" VIEW-AS TEXT
          SIZE 92 BY 1 AT ROW 11.08 COL 4.5
          FGCOLOR 4 
     "При данных настройках на кассу как основн. назв. товара будет передано" VIEW-AS TEXT
          SIZE 92 BY 1 AT ROW 5.42 COL 3.5
          FGCOLOR 4 
     RECT-dopname AT ROW 7.92 COL 2
     RECT-name AT ROW 3.25 COL 2
     SPACE(1.24) SKIP(16.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Опции передачи данных на кассу"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-how-disc b-chg Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN t-cp-is-use-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-how-disc
/* Query rebuild information for BROWSE br-how-disc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH br-thbj-attr where
br-thbj-attr.prop-code begins "how".
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-how-disc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Опции передачи данных на кассу */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable v-attr-codes as character no-undo.
define variable v-attr-labels as character no-undo.
define variable v-sel-codes as character no-undo.
define variable v-role-discnt as character no-undo.
define variable v-rec as recid no-undo.
define buffer buf_br-thbj-attr for br-thbj-attr.
if not available br-thbj-attr then do:
  return no-apply.
end.
assign
v-role-discnt = replace(br-thbj-attr.prop-code, "how-", "").
assign
v-attr-codes = v-role-discnt + {&delim-par} +
               v-role-discnt + "-pdf".
&scop dis-thbj-rule-code  (v-role-discnt + "-pdf")
&scop dis-gds-rule-code  v-role-discnt

assign
v-attr-labels = {&dis-gds-rule-name} + {&delim-par} + {&dis-thbj-rule-name}.
run gbl/d-list.w ( input "b-sel"
                  ,input "Выберите способ задания скидки на товар"
                  ,input v-attr-codes
                  ,input v-attr-labels
                  ,input {&delim-par}
                  ,input br-thbj-attr.property-value-character /*ppresel-codes*/
                  ,output v-sel-codes) no-error.
if error-status:error
or v-sel-codes = ''
then do:
  return no-apply.
end.
if v-sel-codes <> br-thbj-attr.property-value-character then do:
  v-rec = recid(br-thbj-attr).
  find first buf_br-thbj-attr where
          recid(buf_br-thbj-attr) = recid(br-thbj-attr).
  assign
  buf_br-thbj-attr.property-value-character = v-sel-codes.
  if index(buf_br-thbj-attr.property-value-character, "-pdf") > 0 then do:
    &scop dis-thbj-rule-code  buf_br-thbj-attr.property-value-character
    buf_br-thbj-attr.prop-value-label = {&dis-thbj-rule-name}.
  end.
  else do:
    &scop dis-gds-rule-code  buf_br-thbj-attr.property-value-character
    buf_br-thbj-attr.prop-value-label = {&dis-gds-rule-name}.
  end.
  {&OPEN-QUERY-br-how-disc}
  reposition br-how-disc to recid v-rec no-error.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-system
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-system Dialog-Frame
ON CHOOSE OF b-system IN FRAME Dialog-Frame
DO:
    define variable v-ii as integer no-undo .
    
    run bge/oxmlexts.p (
      input parparentproc,
      input 1,
      input substitute("esys-type > &1", {&openxml-type-ordinal}),
      input "",
      output v-rid-list,
      output v-ok).
    if v-rid-list = "" or v-ok <> true then message "Не была выбрана внешняя система." view-as alert-box.
    
    if v-ok = true then 
    do:
      code_system = "" .
      do v-ii = 1 to num-entries(v-rid-list):
        run gen-row-keyr in this-procedure
          ( input entry(v-ii, v-rid-list)
          ,input ?
          ,input "ub"
          ,input ?
          ,input no-lock
          ,output v-tbl-row
          ,output v-tbl-name
          ).
          
        find first buf_ext-system no-lock where
          rowid(buf_ext-system) = v-tbl-row.
      code_system = code_system + "," + entry(2,string(entry(v-ii, v-rid-list)),{&delim-key}) .
      end.
    end.
    else 
    do:
      undo, return no-apply .
    end.
    code_system = trim(code_system,",") .
    code_system:screen-value =  code_system no-error.

  /*        code_system = v-rid-list no-error.*/
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-name-2cd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-name-2cd Dialog-Frame
ON VALUE-CHANGED OF RS-name-2cd IN FRAME Dialog-Frame
DO:
    ASSIGN
  RS-name-2cd.
  run view-results-name2 IN THIS-PROCEDURE(t-cod-pcod, RS-name-2cd) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-cod-pcod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-cod-pcod Dialog-Frame
ON VALUE-CHANGED OF t-cod-pcod IN FRAME Dialog-Frame /* Как дополн. назв. при передаче на кассу - локальный код товара или код партии */
DO:
    ASSIGN
  t-cod-pcod.
  run view-results-name2 IN THIS-PROCEDURE(t-cod-pcod, RS-name-2cd) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-nam-2str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-nam-2str Dialog-Frame
ON VALUE-CHANGED OF t-nam-2str IN FRAME Dialog-Frame /* Передача основного названия товара на кассу в две строки */
DO:
  ASSIGN
  t-nam-2str.
  run view-results-name IN THIS-PROCEDURE(t-nam-artc, t-nam-2str) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-nam-artc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-nam-artc Dialog-Frame
ON VALUE-CHANGED OF t-nam-artc IN FRAME Dialog-Frame /* Как основн. назв. при передаче на кассу - англ. название товара или артикул */
DO:
  ASSIGN
  t-nam-artc.
  run view-results-name IN THIS-PROCEDURE(t-nam-artc, t-nam-2str) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-how-disc
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&cmp}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
  end.
  if p-obj-type = {&cmp} then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-inf-send}
        AND   Locked_thbj-attr.prop-code = '':U
        NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-inf-send}
    AND   locked_thbj-attr.prop-code = '':U
    NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.

  end.
  run FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.

  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

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
  DISPLAY t-tax-cass t-nam-2str t-nam-artc t-cod-pcod RS-name-2cd t-cp-is-use 
          RS-amntdisc code_system l-no-chk-name l-chk-name l-name-2cd l-no-part 
          l-part l-amntdisc t-cp-is-use-2 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RECT-dopname RECT-name t-tax-cass t-nam-2str 
         t-nam-artc t-cod-pcod RS-name-2cd t-cp-is-use RS-amntdisc code_system 
         b-system b-chg br-how-disc l-no-chk-name l-chk-name l-name-2cd 
         l-no-part l-part l-amntdisc 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-tooltip          as character no-undo .
define variable v-label          as character no-undo .
define variable v-tooltip-code          as character no-undo .
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p
  (input "init":U
  ,input p-obj-type
  ,input p-obj-code
  ,input {&attr-cd-inf-send}
  ,input "":U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output v-param-type
  ,INPUT-OUTPUT TABLE-handle v-tth
  )no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
for each thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  IF v-entry = {&attr-cd-inf-send_amntdisc} THEN DO:
    ASSIGN
    RS-amntdisc = thbjattr_thbj-attr.property-value-INTEGER
    rs-amntdisc:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
    IF v-entry = {&attr-cd-inf-send_code-system} THEN 
    DO:
      ASSIGN
        code_system                                     = thbjattr_thbj-attr.property-value-character
        code_system:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
    END.
  IF v-entry = {&attr-cd-inf-send_cod-pcod} THEN DO:
    ASSIGN
    t-cod-pcod = thbjattr_thbj-attr.property-value-logical
    t-cod-pcod:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-inf-send_nam-2str} THEN DO:
    ASSIGN
    t-nam-2str = thbjattr_thbj-attr.property-value-logical
    t-nam-2str:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-inf-send_nam-artc} THEN DO:
    ASSIGN
    t-nam-artc = thbjattr_thbj-attr.property-value-logical
    t-nam-artc:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-inf-send_tax-cass} THEN DO:
    ASSIGN
    t-tax-cass = thbjattr_thbj-attr.property-value-logical
    t-tax-cass:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-inf-send_name-2cd} THEN DO:
    ASSIGN
    RS-name-2cd = thbjattr_thbj-attr.property-value-character
    rs-name-2cd:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-inf-send_cp-is-use} THEN DO:
    ASSIGN
    t-cp-is-use = thbjattr_thbj-attr.property-value-logical
    t-cp-is-use:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  if v-entry begins "how-" then do:
    create br-thbj-attr.
    buffer-copy thbjattr_thbj-attr to br-thbj-attr.
    run thbjattr_tooltip in this-procedure (
                                          input  {&attr-cd-inf-send}
                                         ,input  thbjattr_thbj-attr.prop-code
                                         ,output v-tooltip
                                         ,output br-thbj-attr.prop-code-label
                                         ,output v-tooltip-code).
    br-thbj-attr.prop-code-label = (if num-entries(br-thbj-attr.prop-code-label, ":") > 1
                                    then entry(2, br-thbj-attr.prop-code-label, ":")
                                    else br-thbj-attr.prop-code-label).
    if index(br-thbj-attr.property-value-character, "-pdf") > 0 then do:
      &scop dis-thbj-rule-code  br-thbj-attr.property-value-character
      br-thbj-attr.prop-value-label = {&dis-thbj-rule-name}.
    end.
    else do:
      &scop dis-gds-rule-code  br-thbj-attr.property-value-character
      br-thbj-attr.prop-value-label = {&dis-gds-rule-name}.

    end.
  end.

  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable dflt-cd as character no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .

if p-obj-type = {&shop}
then do:
  run adm/shattri.p
    (input "get":u
    ,input p-obj-type
    ,input p-obj-code
    ,input  'cd-sending':u
    ,input  "dflt-cd":u /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output par-type
    ,input-output TABLE-handle v-tth
    ) no-error .
  if not error-status:error
  then do:
    assign
      dflt-cd = conf-par
    .
  end.
end.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "t-tax-cass,t-nam-2str,t-nam-artc,t-cod-pcod,RS-name-2cd,RS-amntdisc,t-cp-is-use,f-sum-id-output".
l-name-2cd-init = l-name-2cd.

DISPLAY
t-tax-cass
t-nam-2str
t-nam-artc
t-cod-pcod
RS-name-2cd
RS-amntdisc
l-name-2cd
l-amntdisc
t-cp-is-use
t-cp-is-use-2
b-system
    code_system
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
b-system
    WHEN p-mode = {&UPDATE}
    code_system
    WHEN p-mode = {&UPDATE}
t-tax-cass WHEN p-mode = {&UPDATE}
t-nam-2str WHEN p-mode = {&UPDATE}
t-nam-artc WHEN p-mode = {&UPDATE}
t-cod-pcod WHEN p-mode = {&UPDATE}
RS-name-2cd WHEN p-mode = {&UPDATE}
RS-amntdisc WHEN p-mode = {&UPDATE}
t-cp-is-use WHEN p-mode = {&UPDATE}
br-how-disc
b-chg WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
{&OPEN-QUERY-br-how-disc}
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    b-quit:col = 1
    .
END.
APPLY "VALUE-CHANGED" TO t-nam-2str.
APPLY "VALUE-CHANGED" TO t-cod-pcod.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .

IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
t-tax-cass
t-nam-2str
t-nam-artc
t-cod-pcod
RS-name-2cd
RS-amntdisc
t-cp-is-use
code_system
.
assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.upper-prop-code <> {&attr-cd-inf-send}:
  delete thbjattr_thbj-attr.
end.
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.prop-code begins "how-",
   first br-thbj-attr where
        br-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
  assign
  thbjattr_thbj-attr.property-value-character = br-thbj-attr.property-value-character.
end.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  wh = wh:next-sibling.
end.
release thbjattr_thbj-attr.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
/*проверим корректность*/
run adm/shattri.p (
              input "check":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-cd-inf-send}
            , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output TABLE-handle v-tth
             ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
do TRANSACTION
on error undo, return error return-value
:

  RUN thbjattr_set-section IN THIS-PROCEDURE (
       input p-obj-type
      ,input p-obj-code
      ,input {&attr-cd-inf-send}
      ,INPUT table thbjattr_thbj-attr
  ) NO-ERROR.
  IF ERROR-STATUS:error THEN do:
    MESSAGE ERROR-STATUS:get-message(1)  SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-results-name Dialog-Frame 
PROCEDURE view-results-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-nam-artc AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER p-nam-2str AS LOGICAL NO-UNDO.
l-no-chk-name = IF p-nam-artc
                          then "Артикул"
                          else "Название товара"
                .
 l-name-2cd = l-name-2cd-init + (IF p-nam-2str THEN ({&space-char} + "(На POS IBM посылаться не будет!!!)") ELSE "":U).
l-chk-name = IF p-nam-artc
                           then "Артикул"
             else "Название товара НА ЧЕКЕ".

DISPLAY
l-no-chk-name
l-name-2cd
l-chk-name
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-results-name2 Dialog-Frame 
PROCEDURE view-results-name2 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-cod-pcod AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER p-name-2cd AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-gtd AS CHARACTER NO-UNDO.
l-no-part = name-2cdf(
                      input p-name-2cd
                    , input NO /*p-mode yes для конкретного товара no - возвращает описание поля*/
                    , input p-cod-pcod
                    , input 0 /*p-b-code*/
                    , input 0 /*p-gds-code*/
                    , input "":U /*p-artic*/
                    , input "":U /*p-engl-name*/
                    , input "":U /*p-in-code*/
                    , input "":U /*p-part-code*/
                    , input "":U /*p-obj-type*/
                    , input 0 /*p-obj-code*/
                    , input '':U /*p-alpha1*/
                    , output v-gtd
                    ).
l-part = name-2cdf(
                        input p-name-2cd
                    , input NO /*p-mode yes для конкретного товара no - возвращает описание поля*/
                    , input p-cod-pcod
                    , input 0 /*p-b-code*/
                    , input 0 /*p-gds-code*/
                    , input "":U /*p-artic*/
                    , input "":U /*p-engl-name*/
                    , input "":U /*p-in-code*/
                    , input "XXX":U /*p-part-code*/
                    , input "":U /*p-obj-type*/
                    , input 0 /*p-obj-code*/
                    , input '':U /*p-alpha1*/
                    , output v-gtd
                    ).
DISPLAY
l-no-part
l-part
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

