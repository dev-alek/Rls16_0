&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE TEMP-TABLE tt-cancell NO-UNDO LIKE ub.sum-grp
       field return-write-off as logical
       field object_ as character
       field object_-name as character
       .
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "cd-type-magia-xml"

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
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'cd-type-magia-xml'".
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
DEFINE VARIABLE v-host-code LIKE ub.sysconf.host-code NO-UNDO.
DEFINE VARIABLE v-r-b-code LIKE ub.currency.curr-code NO-UNDO.
DEFINE BUFFER buf_currency FOR ub.currency.
DEFINE BUFFER buf_cash-pay-bnal FOR ub.cash-pay.
DEFINE BUFFER buf_cash-pay-nopay FOR ub.cash-pay.
DEFINE BUFFER buf_cash-pay-vip FOR ub.cash-pay.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
&scop  get-name entry(lookup(tt-cancell.object_,  (~{&table_chk-gds~} + ~{&comma-char~} + ~{&table_chk-doc~} + ~{&comma-char~} + ~{&table_ord-doc~})), ~
                     "Блюдо/товар,Чек,Заказ")

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cancell

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cancell

/* Definitions for BROWSE BR-cancell                                    */
&Scoped-define FIELDS-IN-QUERY-BR-cancell tt-cancell.grp-code tt-cancell.grp-name tt-cancell.return-write-off tt-cancell.object_-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cancell
&Scoped-define SELF-NAME BR-cancell
&Scoped-define QUERY-STRING-BR-cancell FOR EACH tt-cancell NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cancell OPEN QUERY {&SELF-NAME} FOR EACH tt-cancell NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cancell tt-cancell
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cancell tt-cancell


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help b-mag-bnal b-magnopay ~
b-mag-VIP BR-cancell f-mag-bnal for-cash-pay-mag-bnal f-magnopay ~
for-cash-pay-magnopay f-mag-VIP for-cash-pay-mag-VIP
&Scoped-Define DISPLAYED-OBJECTS f-mag-bnal for-cash-pay-mag-bnal ~
f-magnopay for-cash-pay-magnopay f-mag-VIP for-cash-pay-mag-VIP

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

DEFINE BUTTON b-mag-bnal
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-mag-VIP
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-magnopay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-mag-bnal AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Тип касс. платежа для безналичной оплаты НА КАССЕ"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE f-mag-VIP AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Тип касс. платежа для чеков VIP и представит. расходов"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE f-magnopay AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Тип касс. платежа для НЕОПЛАЧЕННОГО  НА КАССЕ"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.

DEFINE VARIABLE for-cash-pay-mag-bnal AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-cash-pay-mag-VIP AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-cash-pay-magnopay AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cancell FOR
      tt-cancell SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cancell
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cancell Dialog-Frame _FREEFORM
  QUERY BR-cancell NO-LOCK DISPLAY
      tt-cancell.grp-code COLUMN-LABEL "Код списания!возврата!на кассе" FORMAT ">>>>9":U
      tt-cancell.grp-name COLUMN-LABEL "Описание" FORMAT "X(30)":U
      tt-cancell.return-write-off COLUMN-LABEL "Возврат!Списание" FORMAT "Возврат/Списание"
      tt-cancell.object_-name COLUMN-LABEL "Действует на" FORMAT "X(10)"
            WIDTH 61.75
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.25
         TITLE "Коды списания и возврата" ROW-HEIGHT-CHARS .58 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-add AT ROW 6 COL 1
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     b-mag-bnal AT ROW 3 COL 66
     b-magnopay AT ROW 4 COL 66
     b-mag-VIP AT ROW 5 COL 66
     B-del AT ROW 6 COL 11
     BR-cancell AT ROW 7 COL 1
     f-mag-bnal AT ROW 3.17 COL 55 COLON-ALIGNED
     for-cash-pay-mag-bnal AT ROW 3.17 COL 67 COLON-ALIGNED NO-LABEL
     f-magnopay AT ROW 4.17 COL 55 COLON-ALIGNED
     for-cash-pay-magnopay AT ROW 4.17 COL 67 COLON-ALIGNED NO-LABEL
     f-mag-VIP AT ROW 5.17 COL 55 COLON-ALIGNED
     for-cash-pay-mag-VIP AT ROW 5.17 COL 67 COLON-ALIGNED NO-LABEL
     SPACE(9.74) SKIP(10.48)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры POS MAGIA-XML"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-cancell T "?" NO-UNDO ub sum-grp
      ADDITIONAL-FIELDS:
          field return-write-off as logical
          field object_-name as character
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
/* BROWSE-TAB BR-cancell B-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cancell
/* Query rebuild information for BROWSE BR-cancell
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-cancell NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-cancell */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры POS MAGIA-XML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE v-code AS integer NO-UNDO.
  define variable v-name as character no-undo.
  define variable v-return-write-off as logical no-undo.
  define variable v-object as character no-undo.
  DEFINE VARIABLE v-log AS logical NO-UNDO.
  DEFINE variable v-rid AS RECID NO-UNDO.
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_tt-cancell FOR tt-cancell.

run adm/wromagia.w (output v-code
            ,output v-name
            ,output v-return-write-off
            ,output v-object
            ,output v-log) no-error .
if error-status:error
or not v-log then return no-apply.
FIND FIRST buf_tt-cancell NO-LOCK WHERE
          buf_tt-cancell.grp-code = v-code NO-ERROR.
IF AVAILABLE buf_tt-cancell THEN DO:
     MESSAGE
        "Вы уже задали соответствие для кода возврата/списания" v-code
        VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
END.
CREATE tt-cancell.
ASSIGN
tt-cancell.grp-code = v-code
tt-cancell.grp-name = v-name
tt-cancell.return-write-off = v-return-write-off
tt-cancell.object_ = v-object
tt-cancell.object_-name = {&get-name}.
v-rid = RECID(tt-cancell)
.
{&OPEN-QUERY-BR-cancell}
REPOSITION br-cancell TO RECID v-rid.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-cancell THEN RETURN NO-APPLY.
  DELETE tt-cancell.
  {&OPEN-QUERY-BR-cancell}
  REPOSITION br-cancell TO ROW 1.
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


&Scoped-define SELF-NAME b-mag-bnal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mag-bnal Dialog-Frame
ON CHOOSE OF b-mag-bnal IN FRAME Dialog-Frame
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
      buf_cash-pay.cdpay-code @ f-mag-bnal
      buf_cash-pay.obj-name @ for-cash-pay-mag-bnal
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mag-VIP
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mag-VIP Dialog-Frame
ON CHOOSE OF b-mag-VIP IN FRAME Dialog-Frame
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
      buf_cash-pay.cdpay-code @ f-mag-vip
      buf_cash-pay.obj-name @ for-cash-pay-mag-vip
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-magnopay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-magnopay Dialog-Frame
ON CHOOSE OF b-magnopay IN FRAME Dialog-Frame
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
      buf_cash-pay.cdpay-code @ f-magnopay
      buf_cash-pay.obj-name @ for-cash-pay-magnopay
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cancell
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
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-magia-xml}
        AND   locked_thbj-attr.prop-code = '':U NO-ERROR.
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
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-magia-xml}
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
  DISPLAY f-mag-bnal for-cash-pay-mag-bnal f-magnopay for-cash-pay-magnopay
          f-mag-VIP for-cash-pay-mag-VIP
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help b-mag-bnal b-magnopay b-mag-VIP BR-cancell
         f-mag-bnal for-cash-pay-mag-bnal f-magnopay for-cash-pay-magnopay
         f-mag-VIP for-cash-pay-mag-VIP
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
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable ret-item as character no-undo .
define variable wro-item as character no-undo .
define variable ret-chk as character no-undo .
define variable wro-chk as character no-undo .
define variable ret-ord as character no-undo .
define variable wro-ord as character no-undo .
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
            , input {&attr-cd-type-magia-xml}
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
  IF v-entry = {&attr-cd-type-magia-xml_mag-bnal} THEN DO:
    ASSIGN
    f-mag-bnal = thbjattr_thbj-attr.property-value-INTEGER
    f-mag-bnal:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-magia-xml_magnopay} THEN DO:
    ASSIGN
    f-magnopay = thbjattr_thbj-attr.property-value-INTEGER
    f-magnopay:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-magia-xml_mag-vip} THEN DO:
    ASSIGN
    f-mag-vip = thbjattr_thbj-attr.property-value-INTEGER
    f-mag-vip:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-magia-xml_ret-item} THEN DO:
    ASSIGN
    ret-item = thbjattr_thbj-attr.property-value-character
    .
  END.
  IF v-entry = {&attr-cd-type-magia-xml_wro-item} THEN DO:
    ASSIGN
    wro-item = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-magia-xml_ret-chk} THEN DO:
    ASSIGN
    ret-chk = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-magia-xml_wro-chk} THEN DO:
    ASSIGN
    wro-chk = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-magia-xml_ret-ord} THEN DO:
    ASSIGN
    ret-ord = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-magia-xml_wro-ord} THEN DO:
    ASSIGN
    wro-ord = thbjattr_thbj-attr.property-value-character.
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
for each tt-cancell:
  delete tt-cancell.
end.
DO ii = 1 TO NUM-ENTRIES (ret-item, ';':U):
  CREATE tt-cancell.
  ASSIGN
  tt-cancell.grp-code = integer(ENTRY(1, ENTRY(ii, ret-item, ';':U)))
  tt-cancell.grp-name = ENTRY(2, ENTRY(ii, ret-item, ';':U))
  tt-cancell.return-write-off = yes
  tt-cancell.object_ = {&table_chk-gds}
  tt-cancell.object_-name = {&get-name}
  .
  release tt-cancell.
END.

DO ii = 1 TO NUM-ENTRIES( wro-item, ';':U):
  CREATE tt-cancell.
  ASSIGN
  tt-cancell.grp-code = integer(ENTRY(1, ENTRY(ii, wro-item, ';':U)))
  tt-cancell.grp-name = ENTRY(2, ENTRY(ii, wro-item, ';':U))
  tt-cancell.return-write-off = NO
  tt-cancell.object_ = {&table_chk-gds}
  tt-cancell.object_-name = {&get-name}
  .
  release tt-cancell.
END.
DO ii = 1 TO NUM-ENTRIES( ret-chk, ';':U):
  CREATE tt-cancell.
  ASSIGN
  tt-cancell.grp-code = integer(ENTRY(1, ENTRY(ii, ret-chk, ';':U)))
  tt-cancell.grp-name = ENTRY(2, ENTRY(ii, ret-chk, ';':U))
  tt-cancell.return-write-off = yes
  tt-cancell.object_ = {&table_chk-doc}
  tt-cancell.object_-name = {&get-name}
  .
  release tt-cancell.
END.
DO ii = 1 TO NUM-ENTRIES( wro-chk, ';':U):
  CREATE tt-cancell.
  ASSIGN
  tt-cancell.grp-code = integer(ENTRY(1, ENTRY(ii, wro-chk, ';':U)))
  tt-cancell.grp-name = ENTRY(2, ENTRY(ii, wro-chk, ';':U))
  tt-cancell.return-write-off = NO
  tt-cancell.object_ = {&table_chk-doc}
  tt-cancell.object_-name = {&get-name}
  .
  release tt-cancell.
END.
DO ii = 1 TO NUM-ENTRIES( ret-ord, ';':U):
  CREATE tt-cancell.
  ASSIGN
  tt-cancell.grp-code = integer(ENTRY(1, ENTRY(ii, ret-ord, ';':U)))
  tt-cancell.grp-name = ENTRY(2, ENTRY(ii, ret-ord, ';':U))
  tt-cancell.return-write-off = yes
  tt-cancell.object_ = {&table_ord-doc}
  tt-cancell.object_-name = {&get-name}
  .
  release tt-cancell.
END.
DO ii = 1 TO NUM-ENTRIES( wro-ord, ';':U):
  CREATE tt-cancell.
  ASSIGN
  tt-cancell.grp-code = integer(ENTRY(1, ENTRY(ii, wro-ord, ';':U)))
  tt-cancell.grp-name = ENTRY(2, ENTRY(ii, wro-ord, ';':U))
  tt-cancell.return-write-off = NO
  tt-cancell.object_ = {&table_ord-doc}
  tt-cancell.object_-name = {&get-name}
  .
  release tt-cancell.
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
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "b-mag-bnal,b-magnopay,b-mag-vip,b-add,b-del".
FIND FIRST buf_cash-pay-bnal WHERE
        buf_cash-pay-bnal.cdpay-code = f-mag-bnal
    AND buf_cash-pay-bnal.curr = v-r-b-code NO-ERROR.
FIND FIRST buf_cash-pay-nopay WHERE
        buf_cash-pay-nopay.cdpay-code = f-magnopay
    AND buf_cash-pay-nopay.curr = v-r-b-code NO-ERROR.
FIND FIRST buf_cash-pay-vip WHERE
        buf_cash-pay-vip.cdpay-code = f-mag-vip
    AND buf_cash-pay-vip.curr = v-r-b-code NO-ERROR.
DISPLAY
f-mag-bnal
f-magnopay
f-mag-vip
(IF AVAILABLE buf_cash-pay-bnal THEN buf_cash-pay-bnal.obj-name ELSE ?) @ for-cash-pay-mag-bnal
(IF AVAILABLE buf_cash-pay-nopay THEN buf_cash-pay-nopay.obj-name ELSE ?) @ for-cash-pay-magnopay
(IF AVAILABLE buf_cash-pay-vip THEN buf_cash-pay-vip.obj-name ELSE ?) @ for-cash-pay-mag-vip
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
b-mag-bnal WHEN p-mode = {&UPDATE}
b-magnopay WHEN p-mode = {&UPDATE}
b-mag-vip WHEN p-mode = {&UPDATE}
b-add when p-mode = {&update}
b-del when p-mode = {&update}
br-cancell
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

{&OPEN-QUERY-BR-cancell}
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
define variable ret-item as character no-undo .
define variable wro-item as character no-undo .
define variable ret-chk as character no-undo .
define variable wro-chk as character no-undo .
define variable ret-ord as character no-undo .
define variable wro-ord as character no-undo .


IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
f-mag-bnal
f-magnopay
f-mag-vip
.
for each tt-cancell:
  if tt-cancell.return-write-off = yes
  and tt-cancell.object_ = {&table_chk-gds} then
  assign
  ret-item = ret-item + (if ret-item = '':u then '':U else ';':U) +
            string(tt-cancell.grp-code) + {&comma-char} +
            string(tt-cancell.grp-name)
  .
  if tt-cancell.return-write-off = no
  and tt-cancell.object_ = {&table_chk-gds} then
  assign
  wro-item = wro-item + (if wro-item = '':u then '':U else ';':U) +
            string(tt-cancell.grp-code) +  {&comma-char} +
            string(tt-cancell.grp-name)
  .
  if tt-cancell.return-write-off = yes
  and tt-cancell.object_ = {&table_chk-doc} then
  assign
  ret-chk = ret-chk + (if ret-chk = '':u then '':U else ';':U) +
            string(tt-cancell.grp-code) +  {&comma-char} +
            string(tt-cancell.grp-name)
  .
  if tt-cancell.return-write-off = no
  and tt-cancell.object_ = {&table_chk-doc} then
  assign
  wro-chk = wro-chk + (if wro-chk = '':u then '':U else ';':U) +
            string(tt-cancell.grp-code) + {&comma-char} +
            string(tt-cancell.grp-name)
  .
  if tt-cancell.return-write-off = yes
  and tt-cancell.object_ = {&table_ord-doc} then
  assign
  ret-ord = ret-ord + (if ret-ord = '':u then '':U else ';':U) +
            string(tt-cancell.grp-code) + {&comma-char} +
            string(tt-cancell.grp-name)
  .
  if tt-cancell.return-write-off = no
  and tt-cancell.object_ = {&table_ord-doc} then
  assign
  wro-ord = wro-ord + (if wro-ord = '':u then '':U else ';':U) +
            string(tt-cancell.grp-code) + {&comma-char} +
            string(tt-cancell.grp-name)
  .

end.
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
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-magia-xml_ret-item}.
assign
thbjattr_thbj-attr.property-value-character = ret-item.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-magia-xml_wro-item}.
assign
thbjattr_thbj-attr.property-value-character = wro-item.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-magia-xml_ret-chk}.
assign
thbjattr_thbj-attr.property-value-character = ret-chk.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-magia-xml_wro-chk}.
assign
thbjattr_thbj-attr.property-value-character = wro-chk.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-magia-xml_ret-ord}.
assign
thbjattr_thbj-attr.property-value-character = ret-ord.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-magia-xml_wro-ord}.
assign
thbjattr_thbj-attr.property-value-character = wro-ord.
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
            , input {&attr-cd-type-magia-xml}
            , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output table-handle v-tth
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
      ,input {&attr-cd-type-magia-xml}
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