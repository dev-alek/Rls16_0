&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE TEMP-TABLE tt-cash-pay-omr NO-UNDO LIKE ub.cash-pay
       field omr-pay-code like ub.cash-pay.cdpay-code
       index pi is unique primary omr-pay-code.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "cd-type-omron"

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
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'cd-type-omron'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-host-code LIKE ub.shop.host-code NO-UNDO.
DEFINE VARIABLE v-base-code LIKE ub.sysconf.base-code NO-UNDO.
DEFINE VARIABLE v-r-b-code LIKE ub.currency.curr-code NO-UNDO.
DEFINE BUFFER buf_currency FOR ub.currency.
DEFINE BUFFER buf_cash-pay-nal FOR ub.cash-pay.
DEFINE BUFFER buf_cash-pay-ntnl FOR ub.cash-pay.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cash-pay

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cash-pay-omr

/* Definitions for BROWSE BR-cash-pay                                   */
&Scoped-define FIELDS-IN-QUERY-BR-cash-pay omr-pay-code ~
tt-cash-pay-omr.cdpay-code tt-cash-pay-omr.curr-code ~
tt-cash-pay-omr.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-pay
&Scoped-define QUERY-STRING-BR-cash-pay FOR EACH tt-cash-pay-omr NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cash-pay OPEN QUERY BR-cash-pay FOR EACH tt-cash-pay-omr NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cash-pay tt-cash-pay-omr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-pay tt-cash-pay-omr


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-omrbase f-ipcsbasc ~
b-curr b-cash-pay-nal b-cash-pay-ntnl BR-cash-pay for-curr-name l-omrnal ~
f-omrnal for-cash-pay-nal l-omrntnl f-omrntnl for-cash-pay-ntnl
&Scoped-Define DISPLAYED-OBJECTS f-omrbase f-ipcsbasc for-curr-name ~
l-omrnal f-omrnal for-cash-pay-nal l-omrntnl f-omrntnl for-cash-pay-ntnl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add  NO-FOCUS
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cash-pay-nal
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-cash-pay-ntnl
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-ipcsbasc AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код валюты, соответствующий баз. вал. КАССЫ"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE f-omrbase AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE f-omrnal AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "с кодом валюты равным коду баз. валюты НА КАССЕ"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE f-omrntnl AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "с кодом валюты равным коду баз. валюты НА КАССЕ"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE for-cash-pay-nal AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-cash-pay-ntnl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-curr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-omrnal AS CHARACTER FORMAT "X(256)":U INITIAL "Тип кассового платежа, соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ"
      VIEW-AS TEXT
     SIZE 65 BY .67 NO-UNDO.

DEFINE VARIABLE l-omrntnl AS CHARACTER FORMAT "X(256)":U INITIAL "Тип кассового платежа, соответствующий оплате БЕЗНАЛИЧНЫЕ НА КАССЕ"
      VIEW-AS TEXT
     SIZE 67 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-pay FOR
      tt-cash-pay-omr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-pay Dialog-Frame _STRUCTURED
  QUERY BR-cash-pay NO-LOCK DISPLAY
      omr-pay-code COLUMN-LABEL "Код оплаты!на кассе" FORMAT ">>>>9":U
      tt-cash-pay-omr.cdpay-code COLUMN-LABEL "Тип кассового!платежа (в BO)" FORMAT ">>>9":U
      tt-cash-pay-omr.curr-code COLUMN-LABEL "Код!валюты" FORMAT ">>9":U
      tt-cash-pay-omr.obj-name COLUMN-LABEL "Название типа кассового платежа" FORMAT "X(40)":U
            WIDTH 56.75
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.25
         TITLE "Соответствие кодов оплат НА КАССЕ типам кассовых платежей в BO" EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-add AT ROW 9.75 COL 1
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-omrbase AT ROW 2.5 COL 65 COLON-ALIGNED NO-LABEL
     f-ipcsbasc AT ROW 2.5 COL 65 COLON-ALIGNED
     b-curr AT ROW 2.5 COL 75
     b-cash-pay-nal AT ROW 4.75 COL 70.5
     b-cash-pay-ntnl AT ROW 6.75 COL 70.5
     B-del AT ROW 9.75 COL 11
     BR-cash-pay AT ROW 11.25 COL 1
     for-curr-name AT ROW 2.75 COL 76.5 COLON-ALIGNED NO-LABEL
     l-omrnal AT ROW 4 COL 2 NO-LABEL
     f-omrnal AT ROW 4.92 COL 61 COLON-ALIGNED
     for-cash-pay-nal AT ROW 4.92 COL 73.5 COLON-ALIGNED NO-LABEL
     l-omrntnl AT ROW 6 COL 2 NO-LABEL
     f-omrntnl AT ROW 6.92 COL 61 COLON-ALIGNED
     for-cash-pay-ntnl AT ROW 7 COL 73.5 COLON-ALIGNED NO-LABEL
     SPACE(3.24) SKIP(11.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры POS OMRON"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-cash-pay-omr T "?" NO-UNDO ub cash-pay
      ADDITIONAL-FIELDS:
          field omr-pay-code like ub.cash-pay.cdpay-code
          index pi is unique primary omr-pay-code
      END-FIELDS.
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-cash-pay B-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN l-omrnal IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-omrntnl IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-pay
/* Query rebuild information for BROWSE BR-cash-pay
     _TblList          = "Temp-Tables.tt-cash-pay-omr"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"omr-pay-code" "Код оплаты!на кассе" ">>>>9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.tt-cash-pay-omr.cdpay-code
"tt-cash-pay-omr.cdpay-code" "Тип кассового!платежа (в BO)" ">>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > Temp-Tables.tt-cash-pay-omr.curr-code
"tt-cash-pay-omr.curr-code" "Код!валюты" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   > Temp-Tables.tt-cash-pay-omr.obj-name
"tt-cash-pay-omr.obj-name" "Название типа кассового платежа" ? "character" ? ? ? ? ? ? no ? no no "56.75" yes no no "U" "" ""
     _Query            is NOT OPENED
*/  /* BROWSE BR-cash-pay */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры POS OMRON */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-log AS logical NO-UNDO.
  DEFINE variable v-rid AS RECID NO-UNDO.
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_tt-cash-pay-omr FOR tt-cash-pay-omr.
  DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
  define variable ii as integer no-undo .
  define variable ii-max as integer no-undo .
  find last buf_tt-cash-pay-omr use-index pi no-error .
  if available buf_tt-cash-pay-omr then do:
    assign
    ii-max = buf_tt-cash-pay-omr.omr-pay-code
    .
  end.
  do ii = 1 to MAX(ii-max, 12):
    find first buf_tt-cash-pay-omr where
              buf_tt-cash-pay-omr.omr-pay-code = ii no-error.
    if not available buf_tt-cash-pay-omr then leave.
  end.
  if available buf_tt-cash-pay-omr then do:
    message
    "Все соответствия уже заданы"
    view-as alert-box error .
    return no-apply.
  end.
   run ref/cashpays.w (
               input parparentproc
              ,input  "b-sel":U
              ,input {&all}
              ,input (if p-obj-type = {&cmp} then p-obj-code else v-host-code)
              ,input (if p-obj-type = {&cmp} then '':U else p-obj-type)
              ,input (if p-obj-type = {&cmp} then 0 else p-obj-code)
              ,OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR OR v-rid-list = "":U  THEN RETURN no-apply.
FIND FIRST buf_cash-pay NO-LOCK WHERE
        RECID(buf_cash-pay) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
IF NOT AVAILABLE buf_cash-pay  THEN RETURN NO-APPLY.
CREATE tt-cash-pay-omr.
BUFFER-COPY buf_cash-pay
   TO tt-cash-pay-omr
   ASSIGN
   tt-cash-pay-omr.omr-pay-code = ii
   v-rid = RECID(tt-cash-pay-omr)
   .
   RUN openbr IN THIS-PROCEDURE.
   REPOSITION br-cash-pay TO RECID v-rid.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cash-pay-nal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cash-pay-nal Dialog-Frame
ON CHOOSE OF b-cash-pay-nal IN FRAME Dialog-Frame
DO:
    define variable v-rid-list as character no-undo.
    DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
    run ref/cashpays.w ( input parparentproc
                  ,input "b-sel"
                  ,input {&all}
                  ,input (if p-obj-type = {&cmp} then p-obj-code else v-host-code)
                  ,input (if p-obj-type = {&cmp} then '':U else p-obj-type)
                  ,input (if p-obj-type = {&cmp} then 0 else p-obj-code)
                  ,output v-rid-list ).
    if v-rid-list <> "":U then do:
      FIND FIRST buf_cash-pay WHERE
                recid( buf_cash-pay ) = integer(entry(1, v-rid-list)) NO-LOCK .
      IF buf_cash-pay.curr-code <> v-r-b-code THEN DO:
          MESSAGE
          substitute("Нужно выбрать тип кассового платежа с валютой &1 - валюта продажи на фирме &2", buf_currency.curr-code, v-host-code)
          VIEW-AS ALERT-BOX ERROR.
          RETURN NO-APPLY.
      END.

      DISPLAY
      buf_cash-pay.cdpay-code @ f-omrnal
      buf_cash-pay.obj-name @ for-cash-pay-nal
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cash-pay-ntnl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cash-pay-ntnl Dialog-Frame
ON CHOOSE OF b-cash-pay-ntnl IN FRAME Dialog-Frame
DO:
    define variable v-rid-list as character no-undo.
    DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
    run ref/cashpays.w (
                   input parparentproc
                  ,input "b-sel"
                  ,input {&all}
                  ,input (if p-obj-type = {&cmp} then p-obj-code else v-host-code)
                  ,input (if p-obj-type = {&cmp} then '':U else p-obj-type)
                  ,input (if p-obj-type = {&cmp} then 0 else p-obj-code)
                  ,output v-rid-list ).
    if v-rid-list <> "":U then do:
      FIND FIRST buf_cash-pay WHERE
                recid( buf_cash-pay ) = integer(entry(1, v-rid-list)) NO-LOCK .
      IF buf_cash-pay.curr-code <> v-r-b-code THEN DO:
          MESSAGE
          substitute("Нужно выбрать тип кассового платежа с валютой &1 - валюта продажи на фирме &2", buf_currency.curr-code, v-host-code)
          VIEW-AS ALERT-BOX ERROR.
          RETURN NO-APPLY.
      END.

      DISPLAY
      buf_cash-pay.cdpay-code @ f-omrntnl
      buf_cash-pay.obj-name @ for-cash-pay-ntnl
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-curr Dialog-Frame
ON CHOOSE OF b-curr IN FRAME Dialog-Frame
DO:
    define variable rr as recid no-undo.
    DEFINE BUFFER buf_currency FOR ub.currency.
    rr = ? .
    run ref/currency.w (input parparentproc, "b-sel", input-output rr ).
    if rr <> ? then do:
      FIND FIRST buf_currency WHERE
                recid( buf_currency ) = rr NO-LOCK .
      DISPLAY
      buf_currency.curr-code @ f-omrbase
      buf_currency.curr-abbr @ for-curr-name
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-cash-pay-omr THEN RETURN NO-APPLY.
  DELETE tt-cash-pay-omr.
  RUN openbr IN THIS-PROCEDURE.
  REPOSITION br-cash-pay TO ROW 1.
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
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-omron}
        AND   locked_thbj-attr.prop-code = '':U  NO-WAIT NO-ERROR.
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
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-omron}
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
  DISPLAY f-omrbase f-ipcsbasc for-curr-name l-omrnal f-omrnal for-cash-pay-nal
          l-omrntnl f-omrntnl for-cash-pay-ntnl
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-omrbase f-ipcsbasc b-curr b-cash-pay-nal
         b-cash-pay-ntnl BR-cash-pay for-curr-name l-omrnal f-omrnal
         for-cash-pay-nal l-omrntnl f-omrntnl for-cash-pay-ntnl
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
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-omrcurl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-omrpayl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-omron-pay-code LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-cdpay-code LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-curr-code LIKE ub.cash-pay.curr-code NO-UNDO.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable ii as integer no-undo .
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
            , input {&attr-cd-type-omron}
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
  IF v-entry = {&attr-cd-type-omron_omrbase} THEN DO:
    ASSIGN
    f-omrbase = thbjattr_thbj-attr.property-value-integer
    f-omrbase:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-omron_omrnal} THEN DO:
    ASSIGN
    f-omrnal = thbjattr_thbj-attr.property-value-integer
    f-omrnal:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-omron_omrntnl} THEN DO:
    ASSIGN
    f-omrntnl = thbjattr_thbj-attr.property-value-integer
    f-omrntnl:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-omron_omrcurl} THEN DO:
    ASSIGN
    v-omrcurl = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-omron_omrpayl} THEN DO:
    ASSIGN
    v-omrpayl = thbjattr_thbj-attr.property-value-character.
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
IF v-omrcurl <> "":U  THEN DO:

_ii:
DO ii = 1 TO MIN(NUM-ENTRIES(v-omrcurl), NUM-ENTRIES(v-omrpayl)) :
   ASSIGN
   v-omron-pay-code = ii
   v-cdpay-code = INTEGER (ENTRY(ii, v-omrpayl))
   v-curr-code = INTEGER (ENTRY(ii, v-omrcurl))
   .
   FIND FIRST buf_cash-pay NO-LOCK WHERE
                buf_cash-pay.cdpay-code = v-cdpay-code
        AND buf_cash-pay.curr-code = v-curr-code  NO-ERROR.
   IF NOT AVAILABLE buf_cash-pay THEN NEXT _ii.

    CREATE tt-cash-pay-omr.
    BUFFER-COPY buf_cash-pay TO tt-cash-pay-omr
    ASSIGN
    tt-cash-pay-omr.omr-pay-code = ii
    .
END.
END.

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
FIND FIRST buf_currency NO-LOCK WHERE
          buf_currency.curr-code = f-omrbase NO-ERROR.
IF AVAILABLE buf_currency THEN DO:
    ASSIGN
    for-curr-name = buf_currency.curr-abbr.
END.
ELSE DO:
    ASSIGN
    for-curr-name = ?.
END.
FIND FIRST buf_cash-pay-nal NO-LOCK WHERE
          buf_cash-pay-nal.cdpay-code = f-omrnal
      AND buf_cash-pay-nal.curr-code = f-omrbase NO-ERROR.
IF AVAILABLE buf_cash-pay-nal THEN DO:
    ASSIGN
    for-cash-pay-nal = buf_cash-pay-nal.obj-name.
END.
ELSE DO:
    ASSIGN
    for-cash-pay-nal = ?.
END.
FIND FIRST buf_cash-pay-ntnl NO-LOCK WHERE
          buf_cash-pay-ntnl.cdpay-code = f-omrntnl
      AND buf_cash-pay-ntnl.curr-code = f-omrbase NO-ERROR.
IF AVAILABLE buf_cash-pay-ntnl THEN DO:
    ASSIGN
    for-cash-pay-ntnl = buf_cash-pay-ntnl.obj-name.
END.
ELSE DO:
    ASSIGN
    for-cash-pay-ntnl = ?.
END.

ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "f-omrbase,b-curr,b-cash-pay-nal,b-cash-pay-ntnl,b-add,b-del".
DISPLAY
f-omrbase
f-omrnal
f-omrntnl
l-omrnal
l-omrntnl
for-curr-name
for-cash-pay-nal
for-cash-pay-ntnl
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
br-cash-pay
b-cash-pay-nal WHEN p-mode = {&UPDATE}
b-cash-pay-ntnl WHEN p-mode = {&UPDATE}
f-omrbase WHEN p-mode = {&UPDATE}
b-add   WHEN p-mode = {&UPDATE}
b-del   WHEN p-mode = {&UPDATE}
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
RUN openbr IN THIS-PROCEDURE.
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
OPEN QUERY br-cash-pay FOR EACH tt-cash-pay-omr SHARE-LOCK.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-omrcurl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-omrpayl AS CHARACTER NO-UNDO.
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
DEFINE BUFFER buf_tt-cash-pay-omr FOR tt-cash-pay-omr.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
f-omrbase
f-omrnal
f-omrntnl
.
FOR EACH tt-cash-pay-omr BY tt-cash-pay-omr.omr-pay-code:
  ASSIGN
  v-omrcurl = v-omrcurl + (IF v-omrcurl = "":U THEN "":U ELSE {&comma-char}) + STRING(tt-cash-pay-omr.omr-pay-code)
  v-omrpayl = v-omrpayl + (IF v-omrpayl = "":U THEN "":U ELSE {&comma-char}) + STRING(tt-cash-pay-omr.cdpay-code)
  .

END.
assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  wh = wh:next-sibling.
end.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-omron_omrcurl}.
assign
thbjattr_thbj-attr.property-value-character = v-omrcurl.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-omron_omrpayl}.
assign
thbjattr_thbj-attr.property-value-character = v-omrpayl.
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
            , input {&attr-cd-type-omron}
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
      ,input {&attr-cd-type-omron}
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