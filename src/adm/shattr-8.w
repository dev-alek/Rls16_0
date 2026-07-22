&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE TEMP-TABLE tt-cash-pay-ipcs NO-UNDO LIKE ub.cash-pay
       field ipcs-pay-code like ub.cash-pay.cdpay-code
       index pi is unique primary ipcs-pay-code.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "cd-type-ipc-servispl"

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
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'cd-type-ipc-servispl'".
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
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
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

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cash-pay

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cash-pay-ipcs

/* Definitions for BROWSE BR-cash-pay                                   */
&Scoped-define FIELDS-IN-QUERY-BR-cash-pay ipcs-pay-code ~
tt-cash-pay-ipcs.cdpay-code tt-cash-pay-ipcs.curr-code ~
tt-cash-pay-ipcs.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-pay
&Scoped-define QUERY-STRING-BR-cash-pay FOR EACH tt-cash-pay-ipcs NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cash-pay OPEN QUERY BR-cash-pay FOR EACH tt-cash-pay-ipcs NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cash-pay tt-cash-pay-ipcs
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-pay tt-cash-pay-ipcs


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-ipcsbasc b-curr-base ~
b-cash-pay f-ipcsdobc b-curr RS-ipcscpfx RS-ipcpgpfx BR-cash-pay ~
for-curr-name-base l-ipcspayn f-ipcspayn for-cash-pay-name for-curr-name ~
l-ipcscpfx l-ipcpgpfx
&Scoped-Define DISPLAYED-OBJECTS f-ipcsbasc f-ipcsdobc RS-ipcscpfx ~
RS-ipcpgpfx for-curr-name-base l-ipcspayn f-ipcspayn for-cash-pay-name ~
for-curr-name l-ipcscpfx l-ipcpgpfx

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

DEFINE BUTTON b-cash-pay
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

DEFINE BUTTON b-curr-base
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
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-ipcsbasc AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код валюты, соответствующий баз. вал. КАССЫ"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE f-ipcsdobc AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код дополнительной валюты для прейскурантов на кассе"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE f-ipcspayn AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "с кодом валюты равным коду баз. валюты НА КАССЕ"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE for-cash-pay-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-curr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-curr-name-base AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-ipcpgpfx AS CHARACTER FORMAT "X(256)":U INITIAL "Префикс штучного бар-кода для весов:"
      VIEW-AS TEXT
     SIZE 35 BY .67 NO-UNDO.

DEFINE VARIABLE l-ipcscpfx AS CHARACTER FORMAT "X(256)":U INITIAL "Префикс весового бар-кода:"
      VIEW-AS TEXT
     SIZE 26 BY .67 NO-UNDO.

DEFINE VARIABLE l-ipcspayn AS CHARACTER FORMAT "X(256)":U INITIAL "Тип кассового платежа, соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ"
      VIEW-AS TEXT
     SIZE 65 BY .67 NO-UNDO.

DEFINE VARIABLE RS-ipcpgpfx AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "24", 24,
"28", 28
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE RS-ipcscpfx AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "21", 21,
"23", 23,
"25", 25
     SIZE 20.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-pay FOR
      tt-cash-pay-ipcs SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-pay Dialog-Frame _STRUCTURED
  QUERY BR-cash-pay NO-LOCK DISPLAY
      ipcs-pay-code COLUMN-LABEL "Код оплаты!по карте!на кассе" FORMAT ">>>>9":U
      tt-cash-pay-ipcs.cdpay-code COLUMN-LABEL "Тип кассового!платежа (в BO)" FORMAT ">>>9":U
      tt-cash-pay-ipcs.curr-code COLUMN-LABEL "Код!валюты" FORMAT ">>9":U
      tt-cash-pay-ipcs.obj-name COLUMN-LABEL "Название типа кассового платежа" FORMAT "X(40)":U
            WIDTH 56.8
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.27
         TITLE "Соответствие кодов оплат по платежным картам  на кассе типам кассовых платежей" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-add AT ROW 10.27 COL 1
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-ipcsbasc AT ROW 2.5 COL 65 COLON-ALIGNED
     b-curr-base AT ROW 2.5 COL 75
     b-cash-pay AT ROW 4.77 COL 70.5
     f-ipcsdobc AT ROW 6.5 COL 61 COLON-ALIGNED
     b-curr AT ROW 6.5 COL 71
     RS-ipcscpfx AT ROW 9 COL 28 NO-LABEL
     RS-ipcpgpfx AT ROW 9 COL 84 NO-LABEL WIDGET-ID 2
     B-del AT ROW 10.27 COL 11
     BR-cash-pay AT ROW 11.27 COL 1
     for-curr-name-base AT ROW 2.77 COL 77 COLON-ALIGNED NO-LABEL
     l-ipcspayn AT ROW 4 COL 2 NO-LABEL
     f-ipcspayn AT ROW 4.93 COL 61 COLON-ALIGNED
     for-cash-pay-name AT ROW 4.93 COL 73.5 COLON-ALIGNED NO-LABEL
     for-curr-name AT ROW 6.77 COL 74 COLON-ALIGNED NO-LABEL
     l-ipcscpfx AT ROW 9.27 COL 1 NO-LABEL
     l-ipcpgpfx AT ROW 9.27 COL 48 NO-LABEL WIDGET-ID 6
     "(если не используется - введите ?)" VIEW-AS TEXT
          SIZE 52 BY .77 AT ROW 7.5 COL 9.5
          FGCOLOR 4
     SPACE(37.74) SKIP(11.05)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры POS IPC-servis+"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-cash-pay-ipcs T "?" NO-UNDO ub cash-pay
      ADDITIONAL-FIELDS:
          field ipcs-pay-code like ub.cash-pay.cdpay-code
          index pi is unique primary ipcs-pay-code
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
/* BROWSE-TAB BR-cash-pay B-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN l-ipcpgpfx IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-ipcscpfx IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-ipcspayn IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-pay
/* Query rebuild information for BROWSE BR-cash-pay
     _TblList          = "Temp-Tables.tt-cash-pay-ipcs"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"ipcs-pay-code" "Код оплаты!по карте!на кассе" ">>>>9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-cash-pay-ipcs.cdpay-code
"tt-cash-pay-ipcs.cdpay-code" "Тип кассового!платежа (в BO)" ">>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-cash-pay-ipcs.curr-code
"tt-cash-pay-ipcs.curr-code" "Код!валюты" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-cash-pay-ipcs.obj-name
"tt-cash-pay-ipcs.obj-name" "Название типа кассового платежа" ? "character" ? ? ? ? ? ? no ? no no "56.8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BR-cash-pay */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры POS IPC-servis+ */
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
  DEFINE BUFFER buf_tt-cash-pay-ipcs FOR tt-cash-pay-ipcs.
  DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
    run gbl/d-prompt.w (
      'title=':u + "Добавить код оплаты по платежной карте НА КАССЕ" + '\':u
    + 'format=' + ">>>>9" + '\':u
    + 'type=' + {&type-int} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=7\':u
    + 'fillin_height=1\':u
    + 'max-chars=5\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output v-value
    ).
    if return-value = 'false':u then return NO-apply.

FIND FIRST buf_tt-cash-pay-ipcs NO-LOCK WHERE
          buf_tt-cash-pay-ipcs.ipcs-pay-code = INTEGER(v-value) NO-ERROR.
IF AVAILABLE buf_tt-cash-pay-ipcs THEN DO:
     MESSAGE
        "Вы уже задали соответствие для код оплаты" v-value
        VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
END.
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
CREATE tt-cash-pay-ipcs.
BUFFER-COPY buf_cash-pay
   TO tt-cash-pay-ipcs
   ASSIGN
   tt-cash-pay-ipcs.ipcs-pay-code = integer(v-value)
   v-rid = RECID(tt-cash-pay-ipcs)
   .
   RUN openbr IN THIS-PROCEDURE.
   REPOSITION br-cash-pay TO RECID v-rid.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cash-pay Dialog-Frame
ON CHOOSE OF b-cash-pay IN FRAME Dialog-Frame
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
      buf_cash-pay.cdpay-code @ f-ipcspayn
      buf_cash-pay.obj-name @ for-cash-pay-name
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
      buf_currency.curr-code @ f-ipcsdobc
      buf_currency.curr-abbr @ for-curr-name
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-curr-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-curr-base Dialog-Frame
ON CHOOSE OF b-curr-base IN FRAME Dialog-Frame
DO:
    define variable rr as recid no-undo.
    DEFINE BUFFER buf_currency FOR ub.currency.
    rr = ? .
    run ref/currency.w (input parparentproc, "b-sel", input-output rr ).
    if rr <> ? then do:
      FIND FIRST buf_currency WHERE
                recid( buf_currency ) = rr NO-LOCK .
      DISPLAY
      buf_currency.curr-code @ f-ipcsbasc
      buf_currency.curr-abbr @ for-curr-name-base
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-cash-pay-ipcs THEN RETURN NO-APPLY.
  DELETE tt-cash-pay-ipcs.
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


&Scoped-define SELF-NAME f-ipcsdobc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ipcsdobc Dialog-Frame
ON LEAVE OF f-ipcsdobc IN FRAME Dialog-Frame /* Код дополнительной валюты для прейскурантов на кассе */
DO:
    DEFINE BUFFER buf_currency FOR ub.currency.
    FIND FIRST buf_currency NO-LOCK WHERE
            buf_currency.curr-code = INPUT FRAME {&FRAME-NAME} f-ipcsdobc NO-ERROR.
  IF AVAIL buf_currency THEN DO:
    DISPLAY
    buf_currency.curr-abbr @ for-curr-name
    WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    IF INPUT FRAME {&FRAME-NAME} f-ipcsdobc = ? THEN DO:

    DISPLAY
    "Не задан" @ for-curr-name
    WITH FRAME {&FRAME-NAME}.
    END.
    ELSE RETURN NO-APPLY.
  END.

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
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ipc-servispl}
        AND   locked_thbj-attr.prop-code = '':U
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
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ipc-servispl}
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
  DISPLAY f-ipcsbasc f-ipcsdobc RS-ipcscpfx RS-ipcpgpfx for-curr-name-base
          l-ipcspayn f-ipcspayn for-cash-pay-name for-curr-name l-ipcscpfx
          l-ipcpgpfx
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-ipcsbasc b-curr-base b-cash-pay f-ipcsdobc
         b-curr RS-ipcscpfx RS-ipcpgpfx BR-cash-pay for-curr-name-base
         l-ipcspayn f-ipcspayn for-cash-pay-name for-curr-name l-ipcscpfx
         l-ipcpgpfx
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
DEFINE VARIABLE v-ipcsccrd AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ipcstcrd AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ipcscurc AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ipcs-pay-code LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-cdpay-code LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-curr-code LIKE ub.cash-pay.curr-code NO-UNDO.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
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
            , input {&attr-cd-type-ipc-servispl}
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
  IF v-entry = {&attr-cd-type-ipc-servispl_ipcsbasc} THEN DO:
    ASSIGN
    f-ipcsbasc = thbjattr_thbj-attr.property-value-INTEGER
    f-ipcsbasc:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-ipc-servispl_ipcspayn} THEN DO:
    ASSIGN
    f-ipcspayn = thbjattr_thbj-attr.property-value-INTEGER
    f-ipcspayn:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-ipc-servispl_ipcsdobc} THEN DO:
    ASSIGN
    f-ipcsdobc = IF thbjattr_thbj-attr.property-value-character = ""
                 THEN ?
                 ELSE integer(entry(1, thbjattr_thbj-attr.property-value-character, ";"))
    .
  END.
  IF v-entry = {&attr-cd-type-ipc-servispl_ipcscpfx} THEN DO:
    ASSIGN
    RS-ipcscpfx = thbjattr_thbj-attr.property-value-INTEGER
    rs-ipcscpfx:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-ipc-servispl_ipcpgpfx} THEN DO:
    ASSIGN
    RS-ipcpgpfx = thbjattr_thbj-attr.property-value-INTEGER
    rs-ipcpgpfx:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-ipc-servispl_ipcsccrd} THEN DO:
    ASSIGN
    v-ipcsccrd = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-ipc-servispl_ipcstcrd} THEN DO:
    ASSIGN
    v-ipcstcrd = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-ipc-servispl_ipcscurc} THEN DO:
    ASSIGN
    v-ipcscurc = thbjattr_thbj-attr.property-value-character.
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
_ii:
DO ii = 1 TO NUM-ENTRIES(v-ipcsccrd):
   ASSIGN
   v-ipcs-pay-code = INTEGER (ENTRY(ii, v-ipcsccrd))
   v-cdpay-code = INTEGER (ENTRY(ii, v-ipcstcrd))
   v-curr-code = INTEGER (ENTRY(ii, v-ipcscurc))
   .
   FIND FIRST buf_cash-pay NO-LOCK WHERE
                buf_cash-pay.cdpay-code = v-cdpay-code
        AND buf_cash-pay.curr-code = v-curr-code  NO-ERROR.
   IF NOT AVAILABLE buf_cash-pay THEN NEXT _ii.

    CREATE tt-cash-pay-ipcs.
    BUFFER-COPY buf_cash-pay TO tt-cash-pay-ipcs
    ASSIGN
    tt-cash-pay-ipcs.ipcs-pay-code = v-ipcs-pay-code
    .
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
DEFINE BUFFER buf_currency-base FOR ub.currency.
FIND FIRST buf_currency NO-LOCK WHERE
          buf_currency.curr-code = f-ipcsdobc NO-ERROR.
IF AVAILABLE buf_currency THEN DO:
    ASSIGN
    for-curr-name = buf_currency.curr-abbr.
END.
ELSE DO:
    ASSIGN
    for-curr-name = ?.
END.
FIND FIRST buf_currency-base NO-LOCK WHERE
          buf_currency-base.curr-code = f-ipcsbasc NO-ERROR.
IF AVAILABLE buf_currency-base THEN DO:
    ASSIGN
    for-curr-name-base = buf_currency-base.curr-abbr.
END.
ELSE DO:
    ASSIGN
    for-curr-name-base = ?.
END.
FIND FIRST buf_cash-pay NO-LOCK WHERE
          buf_cash-pay.cdpay-code = f-ipcspayn
      AND buf_cash-pay.curr-code = f-ipcsdobc NO-ERROR.
IF AVAILABLE buf_cash-pay THEN DO:
    ASSIGN
    for-cash-pay-name = buf_cash-pay.obj-name.
END.
ELSE DO:
    ASSIGN
    for-cash-pay-name = ?.
END.

ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "f-ipcsbasc,b-cash-pay,f-ipcsdobc,b-curr,RS-ipcscpfx,RS-ipcpgpfx,b-add,b-del".
DISPLAY
f-ipcsbasc
f-ipcspayn
f-ipcsdobc
RS-ipcscpfx
l-ipcscpfx
RS-ipcpgpfx
l-ipcpgpfx
for-curr-name
for-cash-pay-name
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
b-curr WHEN p-mode = {&UPDATE}
b-cash-pay WHEN p-mode = {&UPDATE}
f-ipcsbasc WHEN p-mode = {&UPDATE}
f-ipcsdobc WHEN p-mode = {&UPDATE}
RS-ipcscpfx WHEN p-mode = {&UPDATE}
RS-ipcpgpfx WHEN p-mode = {&UPDATE}
b-add   WHEN p-mode = {&UPDATE}
b-del   WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
{&OPEN-QUERY-BR-cash-pay}
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    .
END.
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
OPEN QUERY br-cash-pay FOR EACH tt-cash-pay-ipcs SHARE-LOCK.
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
DEFINE VARIABLE v-ipcsccrd AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ipcsbcrd AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ipcscurc AS CHARACTER NO-UNDO.
define variable v-shop-list as character no-undo .

DEFINE BUFFER buf_tt-cash-pay-ipcs FOR tt-cash-pay-ipcs.
define buffer buf_shop for ub.shop.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
f-ipcsbasc
f-ipcspayn
f-ipcsdobc
RS-ipcscpfx
RS-ipcpgpfx
.
FOR EACH tt-cash-pay-ipcs BY tt-cash-pay-ipcs.ipcs-pay-code:
  ASSIGN
  v-ipcsccrd = v-ipcsccrd + (IF v-ipcsccrd = "":U THEN "":U ELSE {&comma-char}) + STRING(tt-cash-pay-ipcs.ipcs-pay-code)
  v-ipcsbcrd = v-ipcsbcrd + (IF v-ipcsbcrd = "":U THEN "":U ELSE {&comma-char}) + STRING(tt-cash-pay-ipcs.cdpay-code)
  v-ipcscurc = v-ipcscurc + (IF v-ipcscurc = "":U THEN "":U ELSE {&comma-char}) + STRING(tt-cash-pay-ipcs.curr-code)
  .

END.
if p-obj-type = {&cmp} THEN DO:
  for each buf_shop no-lock where
          buf_shop.host-code  = P-OBJ-CODE:
    ASSIGN
    v-shop-list = v-shop-list + (if v-shop-list = "":U then "":U else {&comma-char}) + string(buf_shop.obj-code).
  END.
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
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ipc-servispl_ipcsdobc}.
assign
thbjattr_thbj-attr.property-value-character = (if f-ipcsdobc = ?
                                                then ";":U
                                                else (trim(STRING(f-ipcsdobc)) + ";":U + (if p-obj-type = {&cmp}
                                                                                          then v-shop-list
                                                                                          else string(p-obj-code)
                                                                                          )
                                                      )
                                                )
.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ipc-servispl_ipcsccrd}.
assign
thbjattr_thbj-attr.property-value-character = v-ipcsccrd.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ipc-servispl_ipcstcrd}.
assign
thbjattr_thbj-attr.property-value-character = v-ipcsbcrd.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ipc-servispl_ipcscurc} .
assign
thbjattr_thbj-attr.property-value-character = v-ipcscurc.
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
            , input {&attr-cd-type-ipc-servispl}
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
      ,input {&attr-cd-type-ipc-servispl}
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