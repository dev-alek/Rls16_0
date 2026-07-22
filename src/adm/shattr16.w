&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE TEMP-TABLE tt-cash-pay-r-keeper NO-UNDO LIKE ub.cash-pay
       field r-keeper-cdpay-code like ub.cash-pay.cdpay-code
       index pi is unique primary r-keeper-cdpay-code.
DEFINE TEMP-TABLE tt-dis-rule-r-keeper NO-UNDO LIKE ub.dis-rule
       field r-keeper-sifr as integer
       index pi is primary r-keeper-sifr.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "cd-type-r-keeper"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/16/04
Author: Bakhtadze Natalya
Creation date: 12/16/04

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
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'cd-type-r-keeper'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ ref/cgrplbfn.i }
{ gbl/windtfrm.i }
{ gbl/getcntxt.i def }
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-host-code LIKE ub.shop.host-code NO-UNDO.
DEFINE VARIABLE v-base-code LIKE ub.sysconf.base-code NO-UNDO.
DEFINE VARIABLE v-r-b-code LIKE ub.currency.curr-code NO-UNDO.
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-date-format AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_currency FOR ub.currency.
DEFINE BUFFER buf_cash-pay-nal FOR ub.cash-pay.
DEFINE BUFFER buf_cash-pay-ntnl FOR ub.cash-pay.
define BUFFER buf_cli-grp FOR ub.cli-grp.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

&SCOPED-DEFINE discnt-type-code string(tt-dis-rule-r-keeper.discnt-type)
&SCOPED-DEFINE discnt-target-code STRING(tt-dis-rule-r-keeper.subject-type)
&SCOPED-DEFINE discnt-v-code STRING(tt-dis-rule-r-keeper.value-type)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cash-pay

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cash-pay-r-keeper tt-dis-rule-r-keeper

/* Definitions for BROWSE BR-cash-pay                                   */
&Scoped-define FIELDS-IN-QUERY-BR-cash-pay r-keeper-cdpay-code ~
tt-cash-pay-r-keeper.cdpay-code tt-cash-pay-r-keeper.curr-code ~
tt-cash-pay-r-keeper.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-pay
&Scoped-define QUERY-STRING-BR-cash-pay FOR EACH tt-cash-pay-r-keeper NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cash-pay OPEN QUERY BR-cash-pay FOR EACH tt-cash-pay-r-keeper NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cash-pay tt-cash-pay-r-keeper
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-pay tt-cash-pay-r-keeper


/* Definitions for BROWSE BR-dis-rule                                   */
&Scoped-define FIELDS-IN-QUERY-BR-dis-rule r-keeper-sifr ~
tt-dis-rule-r-keeper.rule-num tt-dis-rule-r-keeper.des {&discnt-type-name} ~
{&discnt-target-name} {&discnt-v-name}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-rule
&Scoped-define QUERY-STRING-BR-dis-rule FOR EACH tt-dis-rule-r-keeper NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-dis-rule OPEN QUERY BR-dis-rule FOR EACH tt-dis-rule-r-keeper NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-dis-rule tt-dis-rule-r-keeper
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-rule tt-dis-rule-r-keeper


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help BR-cash-pay ~
f-cdpay-code B-ok B-no-ok BR-dis-rule f-r-keeper-sifr s-datef
&Scoped-Define DISPLAYED-OBJECTS f-cdpay-code f-r-keeper-sifr s-datef FILL-IN-cdpay-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add-cash-pay  NO-FOCUS
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-add-dis-rule  NO-FOCUS
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del-cash-pay
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del-dis-rule
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-no-ok
     LABEL "Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON B-ok
     LABEL "Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE s-datef AS CHARACTER FORMAT "X(256)":U
     LABEL "Формат даты при экспорте на кассу"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 18.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-cdpay-code AS CHARACTER FORMAT "X(256)":U INITIAL "Код плат. на кассе"
     LABEL ""
     VIEW-AS TEXT
     SIZE 19 BY 1
     /*FGCOLOR 15*/  NO-UNDO.

DEFINE VARIABLE f-cdpay-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 15 BY 1 TOOLTIP "Код кассового платежа в ЧУЖОЙ системе" NO-UNDO.

DEFINE VARIABLE f-r-keeper-sifr AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Идентиф-р"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 TOOLTIP "Код кассового платежа в ЧУЖОЙ системе" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-pay FOR
      tt-cash-pay-r-keeper SCROLLING.

DEFINE QUERY BR-dis-rule FOR
      tt-dis-rule-r-keeper SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-pay Dialog-Frame _STRUCTURED
  QUERY BR-cash-pay NO-LOCK DISPLAY
      r-keeper-cdpay-code COLUMN-LABEL "Код платежа!R-KEEPER" FORMAT ">>>>9":U
      tt-cash-pay-r-keeper.cdpay-code COLUMN-LABEL "Код платежа!IBS TH" FORMAT ">>>9":U
      tt-cash-pay-r-keeper.curr-code COLUMN-LABEL "Код валюты!IBS TH" FORMAT ">>9":U
      tt-cash-pay-r-keeper.obj-name COLUMN-LABEL "Название типа кассового платежа" FORMAT "X(40)":U
            WIDTH 30.75
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 77.5 BY 5.77
         TITLE "Соответствие кодов типов кассовых платежей" FIT-LAST-COLUMN.

DEFINE BROWSE BR-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-rule Dialog-Frame _STRUCTURED
  QUERY BR-dis-rule NO-LOCK DISPLAY
      r-keeper-sifr COLUMN-LABEL "Идентификатор!скидки в R-KEEPER" FORMAT ">>>>>>>>9":U
      tt-dis-rule-r-keeper.rule-num COLUMN-LABEL "№ правила!скидки!в IBS TH" FORMAT ">>>>>>>>9":U
      tt-dis-rule-r-keeper.des FORMAT "X(20)":U
      {&discnt-type-name} COLUMN-LABEL "Тип скидки" FORMAT "X(10)":U
            WIDTH 20
      {&discnt-target-name} COLUMN-LABEL "Объект!приложения" FORMAT "X(10)":U
            WIDTH 20
      {&discnt-v-name} COLUMN-LABEL "Тип!знач." FORMAT "X(3)":U
            WIDTH 6.75
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 77.5 BY 5.77
         TITLE "Соответствие типов скидок" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     BR-cash-pay AT ROW 3 COL 1
     B-add-cash-pay AT ROW 3 COL 79
     B-del-cash-pay AT ROW 3 COL 89
     FILL-IN-cdpay-code AT ROW 5 COL 77.6 COLON-ALIGNED no-label
     f-cdpay-code AT ROW 6.25 COL 80 COLON-ALIGNED no-label
     B-ok AT ROW 7.75 COL 79
     B-no-ok AT ROW 7.75 COL 89
     BR-dis-rule AT ROW 9.75 COL 1
     B-del-dis-rule AT ROW 10 COL 89
     f-r-keeper-sifr AT ROW 12 COL 87.5 COLON-ALIGNED
     s-datef AT ROW 16 COL 35.5 COLON-ALIGNED
     B-add-dis-rule AT ROW 10 COL 79
     SPACE(10.24) SKIP(6.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры POS Касса R-KEEPER"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-cash-pay-r-keeper T "?" NO-UNDO ub cash-pay
      ADDITIONAL-FIELDS:
          field r-keeper-cdpay-code like ub.cash-pay.cdpay-code
          index pi is unique primary r-keeper-cdpay-code
      END-FIELDS.
      TABLE: tt-dis-rule-r-keeper T "?" NO-UNDO ub dis-rule
      ADDITIONAL-FIELDS:
          field r-keeper-sifr as integer
          index pi is primary r-keeper-sifr
      END-FIELDS.
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-cash-pay B-Help Dialog-Frame */
/* BROWSE-TAB BR-dis-rule B-no-ok Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add-cash-pay IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-add-dis-rule IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del-cash-pay IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del-dis-rule IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-no-ok:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-ok:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       f-cdpay-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       f-r-keeper-sifr:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       FILL-IN-cdpay-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.



/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-pay
/* Query rebuild information for BROWSE BR-cash-pay
     _TblList          = "Temp-Tables.tt-cash-pay-r-keeper"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"r-keeper-cdpay-code" "Код платежа!R-KEEPER" ">>>>9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-cash-pay-r-keeper.cdpay-code
"tt-cash-pay-r-keeper.cdpay-code" "Код платежа!IBS TH" ">>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-cash-pay-r-keeper.curr-code
"tt-cash-pay-r-keeper.curr-code" "Код валюты!IBS TH" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-cash-pay-r-keeper.obj-name
"tt-cash-pay-r-keeper.obj-name" "Название типа кассового платежа" ? "character" ? ? ? ? ? ? no ? no no "30.8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BR-cash-pay */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-rule
/* Query rebuild information for BROWSE BR-dis-rule
     _TblList          = "Temp-Tables.tt-dis-rule-r-keeper"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"r-keeper-sifr" "Идентификатор!скидки в R-KEEPER" ">>>>>>>>9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-dis-rule-r-keeper.rule-num
"tt-dis-rule-r-keeper.rule-num" "№ правила!скидки!в IBS TH" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-dis-rule-r-keeper.des
"tt-dis-rule-r-keeper.des" ? "X(20)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"{&discnt-type-name}" "Тип скидки" "X(10)" ? ? ? ? ? ? ? no ? no no "20" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"{&discnt-target-name}" "Объект!приложения" "X(10)" ? ? ? ? ? ? ? no ? no no "20" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"{&discnt-v-name}" "Тип!знач." "X(3)" ? ? ? ? ? ? ? no ? no no "6.8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BR-dis-rule */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры POS Касса R-KEEPER */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-cash-pay Dialog-Frame
ON CHOOSE OF B-add-cash-pay IN FRAME Dialog-Frame /* Добавить */
DO:
    { gbl/stdbtn.i }
  IF b-ok:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = "cash-pay"
  b-ok:ROW = 8
  b-no-ok:ROW = 8

  .
assign FILL-IN-cdpay-code:screen-value =  "Код плат. на кассе:".
ENABLE
b-ok
b-no-ok
f-cdpay-code
FILL-IN-cdpay-code
WITH FRAME {&FRAME-NAME}.
APPLY "ENTRY" TO f-cdpay-code.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-dis-rule Dialog-Frame
ON CHOOSE OF B-add-dis-rule IN FRAME Dialog-Frame /* Добавить */
DO:
    { gbl/stdbtn.i }
  IF b-ok:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = "dis-rule"
  b-ok:ROW = 14
  b-no-ok:ROW = 14

  .

ENABLE
b-ok
b-no-ok
f-r-keeper-sifr
WITH FRAME {&FRAME-NAME}.
APPLY "ENTRY" TO f-r-keeper-sifr.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-cash-pay Dialog-Frame
ON CHOOSE OF B-del-cash-pay IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }
IF b-ok:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
    BELL.
    RETURN NO-APPLY.
END.

  RUN proc-b-del IN THIS-PROCEDURE("cash-pay") NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-dis-rule Dialog-Frame
ON CHOOSE OF B-del-dis-rule IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }
IF b-ok:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
    BELL.
    RETURN NO-APPLY.
END.

  RUN proc-b-del IN THIS-PROCEDURE("dis-rule") NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-no-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-no-ok Dialog-Frame
ON CHOOSE OF B-no-ok IN FRAME Dialog-Frame /* Отмена */
DO:
    { gbl/stdbtn.i }
  RUN proc-b-no-ok IN THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ok Dialog-Frame
ON CHOOSE OF B-ok IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }
  RUN proc-b-ok IN THIS-PROCEDURE(add-option) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-pay
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
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
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
    v-host-code = p-obj-code.
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
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-r-keeper}
        AND   locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
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
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-r-keeper}
    AND   locked_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.

  end.
  { gbl/r-b-curr.i v-host-code v-r-b-code }
FIND FIRST buf_currency NO-LOCK WHERE
        buf_currency.curr-code = v-r-b-code .

  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.

  RUN Myenable.
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
  DISPLAY f-cdpay-code f-r-keeper-sifr s-datef FILL-IN-cdpay-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help BR-cash-pay f-cdpay-code B-ok B-no-ok BR-dis-rule 
         f-r-keeper-sifr s-datef 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cash-pay-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dis-rule-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cdpay-code LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-curr-code LIKE ub.cash-pay.curr-code NO-UNDO.
DEFINE VARIABLE v-cdpay-code-r-keeper LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-r-keeper-sifr-r-keeper LIKE tt-dis-rule-r-keeper.r-keeper-sifr NO-UNDO.
define variable v-rule-num like ub.dis-rule.rule-num no-undo .

DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-cd-type-r-keeper}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT TABLE-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  IF v-entry = {&attr-cd-type-r-keeper_cash-pay-list} THEN DO:
    ASSIGN
    v-cash-pay-list = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-r-keeper_dis-rule-list} THEN DO:
    ASSIGN
    v-dis-rule-list = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-r-keeper_date-format} THEN DO:
    ASSIGN
    v-date-format = thbjattr_thbj-attr.property-value-character
    s-datef = (IF lookup(v-date-format, {&enabled-windows-date-formats}) > 0
               THEN v-date-format
               ELSE {&default-windows-date-format}).
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.

END.
if v-cash-pay-list <> "":U then do:
_ii:
DO ii = 1 TO  NUM-ENTRIES(v-cash-pay-list, ";"):
   ASSIGN
   v-entry = entry(ii, v-cash-pay-list, ";":U)
   v-cdpay-code-r-keeper = integer(entry(1, entry(1, v-entry, {&slash-char}), {&comma-char}))
   v-cdpay-code = integer(entry(1, entry(2, v-entry, {&slash-char}), {&comma-char}))
   v-curr-code = integer(entry(2, entry(2, v-entry, {&slash-char}), {&comma-char}))
   .
   FIND FIRST buf_cash-pay NO-LOCK WHERE
                buf_cash-pay.cdpay-code = v-cdpay-code
        AND buf_cash-pay.curr-code = v-curr-code  NO-ERROR.
   IF NOT AVAILABLE buf_cash-pay THEN NEXT _ii.
    CREATE tt-cash-pay-r-keeper.
    BUFFER-COPY buf_cash-pay TO tt-cash-pay-r-keeper
    ASSIGN
    tt-cash-pay-r-keeper.r-keeper-cdpay-code = v-cdpay-code-r-keeper
    .
END.
end.
if v-dis-rule-list <> "":U then do:
_ii:
DO ii = 1 TO  NUM-ENTRIES(v-dis-rule-list, ";"):
   ASSIGN
   v-entry = entry(ii, v-dis-rule-list, ";":U)
   v-r-keeper-sifr-r-keeper = integer(entry(1, entry(1, v-entry, {&slash-char}), {&comma-char}))
   v-rule-num = integer(entry(1, entry(2, v-entry, {&slash-char}), {&comma-char}))
   .
   FIND FIRST buf_dis-rule NO-LOCK WHERE
                buf_dis-rule.rule-num = v-rule-num NO-ERROR.
   IF NOT AVAILABLE buf_dis-rule THEN NEXT _ii.
    CREATE tt-dis-rule-r-keeper.
    BUFFER-COPY buf_dis-rule TO tt-dis-rule-r-keeper
    ASSIGN
    tt-dis-rule-r-keeper.r-keeper-sifr = v-r-keeper-sifr-r-keeper
    .
  END.
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
DEFINE BUFFER buf_currency FOR ub.currency.

ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "b-add-cash-pay,b-del-cash-pay,b-add-rule,b-del-dis-rule,s-datef".
ASSIGN
s-datef:LIST-ITEMS = {&enabled-windows-date-formats}
s-datef =  v-date-format   .
DISPLAY s-datef
WITH FRAME {&FRAME-NAME}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
br-cash-pay
b-add-cash-pay   WHEN p-mode = {&UPDATE}
b-del-cash-pay   WHEN p-mode = {&UPDATE}
br-dis-rule
b-add-dis-rule   WHEN p-mode = {&UPDATE}
b-del-dis-rule   WHEN p-mode = {&UPDATE}
s-datef WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit

    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    .
END.
HIDE
b-ok
b-no-ok
f-cdpay-code
FILL-IN-cdpay-code
f-r-keeper-sifr
in FRAME {&FRAME-NAME}.
RUN openbrcash-pay IN THIS-PROCEDURE.
RUN openbrdis-rule IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrcash-pay Dialog-Frame 
PROCEDURE OpenBrcash-pay :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY br-cash-pay FOR EACH tt-cash-pay-r-keeper SHARE-LOCK.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrdis-rule Dialog-Frame 
PROCEDURE OpenBrdis-rule :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY br-dis-rule FOR EACH tt-dis-rule-r-keeper SHARE-LOCK.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame 
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-code1 AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-code2 AS integer NO-UNDO.
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-log AS logical NO-UNDO.
DEFINE variable v-rid AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-cash-pay-r-keeper FOR tt-cash-pay-r-keeper.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.

define variable ii as integer no-undo .
CASE p-mode:
    WHEN "cash-pay" THEN DO:
      APPLY "ENTRY" TO f-cdpay-code IN FRAME {&FRAME-NAME}.

     END.
    WHEN "dis-rule" THEN DO:
      APPLY "ENTRY" TO f-r-keeper-sifr IN FRAME {&FRAME-NAME}.
    END.

END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame 
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
CASE p-mode:
    WHEN "cash-pay" THEN DO:
        IF NOT AVAILABLE tt-cash-pay-r-keeper THEN RETURN NO-APPLY.
          DELETE tt-cash-pay-r-keeper.
          RUN openbrcash-pay IN THIS-PROCEDURE.
          REPOSITION br-cash-pay TO ROW 1.

    END.
    WHEN "dis-rule" THEN DO:
        IF NOT AVAILABLE tt-dis-rule-r-keeper THEN RETURN NO-APPLY.
          DELETE tt-dis-rule-r-keeper.
          RUN openbrdis-rule IN THIS-PROCEDURE.
          REPOSITION br-dis-rule TO ROW 1.

    END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-no-ok Dialog-Frame 
PROCEDURE proc-b-no-ok :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
HIDE
b-ok
IN FRAME {&FRAME-NAME}
b-no-ok
IN FRAME {&FRAME-NAME}
f-cdpay-code
FILL-IN-cdpay-code
f-r-keeper-sifr
IN FRAME {&FRAME-NAME}
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-ok Dialog-Frame 
PROCEDURE proc-b-ok :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-log AS logical NO-UNDO.
DEFINE variable v-rid AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-sts   like ub.dis-rule.sts no-undo init ?.
DEFINE BUFFER buf_tt-cash-pay-r-keeper FOR tt-cash-pay-r-keeper.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_tt-dis-rule-r-keeper FOR tt-dis-rule-r-keeper.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
ASSIGN
add-option = "":U.

CASE p-mode:
    WHEN "cash-pay" THEN DO:
        ASSIGN
        FRAME {&frame-name}
        f-cdpay-code.
        FIND FIRST buf_tt-cash-PAY-r-keeper NO-LOCK WHERE
                buf_tt-cash-pay-r-keeper.r-keeper-cdpay-code = f-cdpay-code NO-ERROR.
        IF AVAILABLE buf_tt-cash-pay-r-keeper THEN DO:
            MESSAGE
            SUBSTITUTE("Уже задано правило соответствия для типа кассового платежа,&1" +
                       "у которого код платежа &2"
                       , {&new-line}
                       , f-cdpay-code
                       )
            VIEW-AS ALERT-BOX ERROR.
            RETURN ERROR.
        END.
        run ref/cashpays.w (
                   input parparentproc
                  ,input  "b-sel":U
                  ,input {&all}
                  ,input (if p-obj-type = {&cmp} then p-obj-code else v-host-code)
                  ,input (if p-obj-type = {&cmp} then '':U else p-obj-type)
                  ,input (if p-obj-type = {&cmp} then 0 else p-obj-code)
                  ,OUTPUT v-rid-list) NO-ERROR.
        IF ERROR-STATUS:ERROR OR v-rid-list = "":U  THEN RETURN error.
        FIND FIRST buf_cash-pay NO-LOCK WHERE
                RECID(buf_cash-pay) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
        IF NOT AVAILABLE buf_cash-pay  THEN RETURN error.
        CREATE tt-cash-pay-r-keeper.
        BUFFER-COPY buf_cash-pay
           TO tt-cash-pay-r-keeper
           ASSIGN
           tt-cash-pay-r-keeper.r-keeper-cdpay-code = f-cdpay-code
            v-rid = RECID(tt-cash-pay-r-keeper)
           .
           RUN openbrcash-pay IN THIS-PROCEDURE.
           REPOSITION br-cash-pay TO RECID v-rid.
    END.
    WHEN "dis-rule" THEN DO:
        ASSIGN
        FRAME {&frame-name}
        f-r-keeper-sifr.
        if f-r-keeper-sifr = 0 then do:
          message
          "Нельзя ввести идентификатор скидки равный 0!"
          view-as alert-box error .
          undo, return error .
        end.
        FIND FIRST buf_tt-dis-rule-r-keeper NO-LOCK WHERE
                buf_tt-dis-rule-r-keeper.r-keeper-sifr = f-r-keeper-sifr NO-ERROR.
        IF AVAILABLE buf_tt-dis-rule-r-keeper THEN DO:
            MESSAGE
            SUBSTITUTE("Уже задано правило соответствия для скидки с идентификатором &1"
                        , f-r-keeper-sifr
                       )
            VIEW-AS ALERT-BOX ERROR.
            RETURN ERROR.
        END.

        run ref/dis-ruls.w (
                  input  parparentproc
                  ,input 0 /*p-host-code*/
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input "b-sel":U
                  ,input "cd-obj=R-KEEPER":U
                  ,input 0  /*p-upper-rule-num*/
                  ,input ? /*p-time-templ-rl-root*/
                  ,input 0 /*p-b-code*/
                  ,input-output v-sts /*p-sts*/
                  ,input-OUTPUT v-rid-list) NO-ERROR.
        IF ERROR-STATUS:ERROR OR v-rid-list = "":U  THEN RETURN error.
        FIND FIRST buf_dis-rule NO-LOCK WHERE
                RECID(buf_dis-rule) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
        IF NOT AVAILABLE buf_dis-rule  THEN RETURN error.
        CREATE tt-dis-rule-r-keeper.
        BUFFER-COPY buf_dis-rule
           TO tt-dis-rule-r-keeper
           ASSIGN
           tt-dis-rule-r-keeper.r-keeper-sifr = f-r-keeper-sifr
            v-rid = RECID(tt-dis-rule-r-keeper)
           .
           RUN openbrdis-rule IN THIS-PROCEDURE.
           REPOSITION br-dis-rule TO RECID v-rid.
    END.
END CASE.
HIDE
b-ok
IN FRAME {&FRAME-NAME}
b-no-ok
IN FRAME {&FRAME-NAME}
f-cdpay-code
IN FRAME {&FRAME-NAME}
FILL-IN-cdpay-code
IN FRAME {&FRAME-NAME}
f-r-keeper-sifr
IN FRAME {&FRAME-NAME}
.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-same as logical no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
DEFINE VARIABLE v-cash-pay-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dis-rule-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-cash-pay-r-keeper FOR tt-cash-pay-r-keeper.
DEFINE BUFFER buf_tt-dis-rule-r-keeper FOR tt-dis-rule-r-keeper.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
s-datef
.

FOR EACH tt-cash-pay-r-keeper BY tt-cash-pay-r-keeper.r-keeper-cdpay-code:
  ASSIGN
  v-cash-pay-list = v-cash-pay-list + (IF v-cash-pay-list = "":U THEN "":U ELSE ";") +
                    STRING(tt-cash-pay-r-keeper.r-keeper-cdpay-code) + {&slash-char} +
                    STRING(tt-cash-pay-r-keeper.cdpay-code) + {&comma-char} +
                    STRING(tt-cash-pay-r-keeper.curr-code)
  .
END.
FOR EACH tt-dis-rule-r-keeper BY tt-dis-rule-r-keeper.r-keeper-sifr:
  ASSIGN
  v-dis-rule-list = v-dis-rule-list + (IF v-dis-rule-list = "":U THEN "":U ELSE ";") +
                    STRING(tt-dis-rule-r-keeper.r-keeper-sifr) + {&slash-char} +
                    STRING(tt-dis-rule-r-keeper.rule-num)

  .
END.

find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-r-keeper_cash-pay-list}.
assign
thbjattr_thbj-attr.property-value-character = v-cash-pay-list.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-r-keeper_dis-rule-list}.
assign
thbjattr_thbj-attr.property-value-character = v-dis-rule-list.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-r-keeper_date-format}.
assign
thbjattr_thbj-attr.property-value-character = s-datef.

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
            , input {&attr-cd-type-r-keeper}
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
      ,input {&attr-cd-type-r-keeper}
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

