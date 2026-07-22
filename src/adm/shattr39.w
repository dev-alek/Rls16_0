/*
26/II-2019 не используется. Атрибуты финансовых документов перенесены в БПА

&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "fin-doc"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/29/10
Author: Bakhtadze Natalya
Creation date: 03/29/10

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
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'fin-doc'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
define variable v-obj-db-num as integer   no-undo .
define variable v-firm-db-num as integer   no-undo .
define variable v-host-code as integer   no-undo .
define variable v-no-save-counters as logical   no-undo .
define variable old-cash-book as integer   no-undo .
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_sysconf for ub.sysconf.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit rs-cash-book rs-uchet B-Help ~
f-suffix-pko f-prefix-pko f-current-pko f-suffix-rko f-prefix-rko ~
f-current-rko rs-head-position rs-director rs-snr-accnt rs-dpt-option ~
f-dpt-dflt-name f-dpt-dflt-type f-dpt-dflt-code 
&Scoped-Define DISPLAYED-OBJECTS rs-cash-book rs-uchet f-suffix-pko f-prefix-pko ~
f-current-pko f-suffix-rko f-prefix-rko f-current-rko rs-head-position ~
rs-director rs-snr-accnt rs-dpt-option f-dpt-dflt-name f-dpt-dflt-type ~
f-dpt-dflt-code 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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

DEFINE VARIABLE f-current-pko AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Текущий номер ПКО (без префикса и суффикса)" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-current-rko AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Текущий номер РКО (без префикса и суффикса)" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-dpt-dflt-code AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "Код" 
     VIEW-AS FILL-IN 
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dpt-dflt-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Название" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1 NO-UNDO.

DEFINE VARIABLE f-dpt-dflt-type AS CHARACTER FORMAT "X(3)":U 
     LABEL "Тип" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-prefix-pko AS CHARACTER FORMAT "X(256)":U 
     LABEL "Префикс при автом. генерации № ПКО" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-prefix-rko AS CHARACTER FORMAT "X(256)":U 
     LABEL "Префикс при автом. генерации № РКО" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE f-suffix-pko AS CHARACTER FORMAT "X(256)":U 
     LABEL "Суффикс при автом. генерации № ПКО" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-suffix-rko AS CHARACTER FORMAT "X(256)":U 
     LABEL "Суффикс при автом. генерации № РКО" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1.07 NO-UNDO.

DEFINE VARIABLE rs-cash-book AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", 0,
"Item 2", 1
     SIZE 42 BY 2 NO-UNDO.

DEFINE VARIABLE rs-uchet AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
               "по сменным датам", "smen",
"по календарным датам", "cal"
     SIZE 42 BY 2 NO-UNDO.

DEFINE VARIABLE rs-director AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2"
     SIZE 50.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-dpt-option AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2"
     SIZE 72 BY 1 NO-UNDO.

DEFINE VARIABLE rs-head-position AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 72 BY 1 NO-UNDO.

DEFINE VARIABLE rs-snr-accnt AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 71.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     rs-cash-book AT ROW 1 COL 46.5 NO-LABEL WIDGET-ID 36
     rs-uchet AT ROW 19.20 COL 17 NO-LABEL WIDGET-ID 60
     B-Help AT ROW 1 COL 96
     f-suffix-pko AT ROW 3.5 COL 41 COLON-ALIGNED WIDGET-ID 4
     f-prefix-pko AT ROW 5 COL 41 COLON-ALIGNED WIDGET-ID 8
     f-current-pko AT ROW 6.5 COL 47.5 COLON-ALIGNED
     f-suffix-rko AT ROW 8 COL 41.5 COLON-ALIGNED WIDGET-ID 6
     f-prefix-rko AT ROW 9.5 COL 41 COLON-ALIGNED WIDGET-ID 10
     f-current-rko AT ROW 11 COL 49 COLON-ALIGNED WIDGET-ID 2
     rs-head-position AT ROW 13 COL 25.5 NO-LABEL WIDGET-ID 18
     rs-director AT ROW 14.5 COL 25.5 NO-LABEL WIDGET-ID 22
     rs-snr-accnt AT ROW 15.93 COL 25.5 NO-LABEL WIDGET-ID 30
     rs-dpt-option AT ROW 17 COL 28 NO-LABEL WIDGET-ID 42
     f-dpt-dflt-name AT ROW 18.07 COL 10.5 COLON-ALIGNED WIDGET-ID 48
     f-dpt-dflt-type AT ROW 18.07 COL 70 COLON-ALIGNED WIDGET-ID 50
     f-dpt-dflt-code AT ROW 18.07 COL 86 COLON-ALIGNED WIDGET-ID 52
     "ФИО бухг-ра:" VIEW-AS TEXT
          SIZE 22 BY 1 AT ROW 16 COL 2.5 WIDGET-ID 34
          FGCOLOR 4 
     "ФИО рук-ля:" VIEW-AS TEXT
          SIZE 22 BY 1 AT ROW 14.5 COL 2.5 WIDGET-ID 28
          FGCOLOR 4 
     "Должность рук-ля:" VIEW-AS TEXT
          SIZE 22 BY 1 AT ROW 13 COL 2.5 WIDGET-ID 26
          FGCOLOR 4 
     "Кассовая книга ведется" VIEW-AS TEXT
          SIZE 23 BY 1.07 AT ROW 1 COL 22 WIDGET-ID 40
          FGCOLOR 4 
     "Учёт ведется" VIEW-AS TEXT
          SIZE 14 BY 1.07 AT ROW 19.15 COL 2.5 WIDGET-ID 62
          FGCOLOR 4
     "Поле <Структурн.подразд>:" VIEW-AS TEXT
          SIZE 25.5 BY 1 AT ROW 17 COL 2.5 WIDGET-ID 46
          FGCOLOR 4 
     SPACE(71.99) SKIP(3.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки фин. документов в контексте объекта"
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
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки фин. документов в контексте объекта */
DO:
  APPLY "END-ERROR":U TO SELF.
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


&Scoped-define SELF-NAME rs-cash-book
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-cash-book Dialog-Frame
ON VALUE-CHANGED OF rs-cash-book IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-cash-book.
  CASE rs-cash-book:
      WHEN integer({&cash-book-firm}) THEN DO:
        IF v-cntxt-db-num = v-firm-db-num
        OR v-to-create THEN DO:
          IF p-mode <> {&LOOKUP} THEN DO:
              ENABLE
              f-current-pko
              f-current-rko
              WITH FRAME {&FRAME-NAME}.
          END.
        END.
        ELSE DO:
            disable
            f-current-pko
            f-current-rko
            WITH FRAME {&FRAME-NAME}.

        END.
      END.
      WHEN integer({&cash-book-object}) THEN DO:
          IF v-cntxt-db-num = v-obj-db-num
          OR v-to-create THEN DO:
            IF p-mode <> {&LOOKUP} THEN DO:
                ENABLE
                f-current-pko
                f-current-rko
                WITH FRAME {&FRAME-NAME}.
            END.
          END.
          ELSE DO:
              disable
              f-current-pko
              f-current-rko
              WITH FRAME {&FRAME-NAME}.

          END.
   END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-dpt-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-dpt-option Dialog-Frame
ON VALUE-CHANGED OF rs-dpt-option IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-dpt-option.
  RUN proc-value-changed-dpt-option IN THIS-PROCEDURE ( INPUT rs-dpt-option).
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
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-obj-db-num }
    IF v-obj-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-obj-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    find first buf_sysconf no-lock where buf_sysconf.host-code = v-host-code.
    v-firm-db-num = buf_sysconf.firm-db-num.
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
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-fin-doc}
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
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-fin-doc}
    and   locked_thbj-attr.prop-code = '':U
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
  DISPLAY rs-cash-book rs-uchet f-suffix-pko f-prefix-pko f-current-pko f-suffix-rko
          f-prefix-rko f-current-rko rs-head-position rs-director rs-snr-accnt 
          rs-dpt-option f-dpt-dflt-name f-dpt-dflt-type f-dpt-dflt-code 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit rs-cash-book rs-uchet B-Help f-suffix-pko f-prefix-pko
         f-current-pko f-suffix-rko f-prefix-rko f-current-rko rs-head-position 
         rs-director rs-snr-accnt rs-dpt-option f-dpt-dflt-name f-dpt-dflt-type 
         f-dpt-dflt-code 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
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
            , input {&attr-fin-doc}
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
  IF v-entry = {&attr-fin-doc_cash-book} THEN DO:
    ASSIGN
    rs-cash-book = (IF thbjattr_thbj-attr.property-value-integer > 0 THEN 1 ELSE 0)
    rs-cash-book:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    old-cash-book = rs-cash-book
    .
  END.

  IF v-entry = {&attr-fin-doc_uchet} THEN DO:
    ASSIGN
    rs-uchet = thbjattr_thbj-attr.property-value-character
    rs-uchet:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.

  IF v-entry = {&attr-fin-doc_suffix-pko} THEN DO:
    ASSIGN
    f-suffix-pko = thbjattr_thbj-attr.property-value-character
    f-suffix-pko:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_suffix-rko} THEN DO:
    ASSIGN
    f-suffix-rko = thbjattr_thbj-attr.property-value-character
    f-suffix-rko:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_prefix-pko} THEN DO:
    ASSIGN
    f-prefix-pko = thbjattr_thbj-attr.property-value-character
    f-prefix-pko:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_prefix-rko} THEN DO:
    ASSIGN
    f-prefix-rko = thbjattr_thbj-attr.property-value-character
    f-prefix-rko:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_current-pko} THEN DO:
    ASSIGN
    f-current-pko = thbjattr_thbj-attr.property-value-integer
    f-current-pko:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_current-rko} THEN DO:
    ASSIGN
    f-current-rko = thbjattr_thbj-attr.property-value-integer
    f-current-rko:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_head-position} THEN DO:
    ASSIGN
    rs-head-position = thbjattr_thbj-attr.property-value-character
    rs-head-position:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_director} THEN DO:
    ASSIGN
    rs-director = thbjattr_thbj-attr.property-value-character
    rs-director:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_snr-accnt} THEN DO:
    ASSIGN
    rs-snr-accnt = thbjattr_thbj-attr.property-value-character
    rs-snr-accnt:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_dpt-option} THEN DO:
    ASSIGN
    rs-dpt-option = thbjattr_thbj-attr.property-value-character
    rs-dpt-option:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_dpt-dflt-name} THEN DO:
    ASSIGN
    f-dpt-dflt-name = thbjattr_thbj-attr.property-value-character
    f-dpt-dflt-name:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_dpt-dflt-type} THEN DO:
    ASSIGN
    f-dpt-dflt-type = thbjattr_thbj-attr.property-value-character
    f-dpt-dflt-type:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-fin-doc_dpt-dflt-code} THEN DO:
    ASSIGN
    f-dpt-dflt-code = thbjattr_thbj-attr.property-value-integer
    f-dpt-dflt-code:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.

  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "rs-cash-book,f-suffix-pko,f-prefix-pko,f-current-pko,f-suffix-rko,f-prefix-rko,f-current-rko," +
              "rs-head-position,rs-director,rs-snr-accnr,rs-dpt-option,f-dpt-dflt-name,f-dpt-dflt-type,f-dpt-dflt-code,rs-uchet".
ASSIGN
rs-cash-book:RADIO-BUTTONS = "В главной БД фирмы" + {&comma-char} + {&cash-book-firm} + {&comma-char} +
                             "Операционная - На БД объекта" + {&comma-char} + {&cash-book-object} .
ASSIGN
rs-dpt-option:RADIO-BUTTONS = "Заполняет оператор" + {&comma-char} + "blank" + {&comma-char} +
                              "Взять из объекта" + {&comma-char} + "object" + {&comma-char} +
                              "Значение по умолч." + {&comma-char} + "dflt"
                              .

case p-obj-type:
  when {&shop} then do:
    assign
    rs-head-position:radio-buttons = "Должность рук-ля фирмы" + {&comma-char} + "ruk_firm" + {&comma-char} +
                                    "Директор" + {&comma-char} + "director" + {&comma-char} +
                                    "Управляющий" + {&comma-char} + "upravl"
                                       .
    assign
    rs-director:radio-buttons = "ФИО рук-ля фирмы" + {&comma-char} + "ruk_firm" + {&comma-char} +
                                "ФИО рук-ля магазина" + {&comma-char} + "dir_obj"
                                 .
    assign
    rs-snr-accnt:radio-buttons = "ФИО гл.бухг-ра фирмы" + {&comma-char} + "glbuh_firm" + {&comma-char} +
                                "ФИО бухг-ра магазина" + {&comma-char} + "buh_obj"
    .

  end.
  when {&stock} then do:
    assign
    rs-head-position:radio-buttons = "Должность рук-ля фирмы" + {&comma-char} + "ruk_firm" + {&comma-char} +
                                    "Директор" + {&comma-char} + "director" + {&comma-char} +
                                    "Зав.складом" + {&comma-char} + "zavsklad" .
    assign
    rs-director:radio-buttons = "ФИО рук-ля фирмы" + {&comma-char} + "ruk_firm" + {&comma-char} +
                                "ФИО завскладом" + {&comma-char} + "dir_obj"
                                 .
    assign
    rs-snr-accnt:radio-buttons = "ФИО гл.бухг-ра фирмы" + {&comma-char} + "glbuh_firm"
    .

  end.
  when {&cmp} then do:
    assign
    rs-head-position:radio-buttons = "Должность рук-ля фирмы" + {&comma-char} + "ruk_firm"
    .                                    .
    assign
    rs-director:radio-buttons = "ФИО рук-ля фирмы" + {&comma-char} + "ruk_firm"
    .
    assign
    rs-snr-accnt:radio-buttons = "ФИО гл.бухг-ра фирмы" + {&comma-char} + "glbuh_firm"
    .

  end.
end case.

DISPLAY
rs-cash-book
rs-uchet
f-suffix-pko
f-prefix-pko
f-current-pko
f-suffix-rko
f-prefix-rko
f-current-rko
rs-head-position
rs-director
rs-snr-accnt
rs-dpt-option
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
rs-cash-book WHEN p-mode = {&UPDATE}
rs-uchet WHEN p-mode = {&UPDATE}
f-suffix-pko WHEN p-mode = {&UPDATE}
f-prefix-pko WHEN p-mode = {&UPDATE}
f-current-pko WHEN (p-mode = {&UPDATE} and (v-to-create or ((v-cntxt-db-num = v-firm-db-num and rs-cash-book = integer({&cash-book-firm}))
                                                         or
                                                         (v-cntxt-db-num = v-obj-db-num and rs-cash-book = integer({&cash-book-object}))
                                                         )))
f-current-rko WHEN (p-mode = {&UPDATE} and (v-to-create or ((v-cntxt-db-num = v-firm-db-num and rs-cash-book = integer({&cash-book-firm}))
                                                         or
                                                         (v-cntxt-db-num = v-obj-db-num and rs-cash-book = integer({&cash-book-object}))
                                                         )) )
f-prefix-rko WHEN p-mode = {&UPDATE}
f-suffix-rko WHEN p-mode = {&UPDATE}
rs-head-position WHEN p-mode = {&UPDATE}
rs-director WHEN p-mode = {&UPDATE}
rs-snr-accnt WHEN p-mode = {&UPDATE}
rs-dpt-option WHEN p-mode = {&UPDATE}
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
run proc-value-changed-dpt-option in this-procedure ( input rs-dpt-option).
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
define variable glog as logical no-undo .

IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
rs-cash-book
rs-uchet
f-suffix-pko
f-prefix-pko
f-suffix-rko
f-prefix-rko
f-current-pko
f-current-rko
rs-head-position
rs-director
rs-snr-accnt
rs-dpt-option
.
if rs-dpt-option = "dflt" then do:
  assign
  f-dpt-dflt-name
  f-dpt-dflt-type
  f-dpt-dflt-code
  .
end.
else do:
  assign
  f-dpt-dflt-name = ''
  f-dpt-dflt-type = ''
  f-dpt-dflt-code = 0
  .

end.
/*посмотрим можем менять счетчик - можем если */
if not ((
        (v-cntxt-db-num = v-firm-db-num and rs-cash-book = integer({&cash-book-firm}))
        or
        (v-cntxt-db-num = v-obj-db-num and rs-cash-book = integer({&cash-book-object}))
       ) or v-to-create
       or rs-cash-book <> old-cash-book
       )
then do:
  message
  substitute("Внимание!!! Значение текущего номера ПКО/РКО в данной БД изменить невозможно,&1"  +
             "так как кассовая книга ведется в &2 (БД &3)"
             , {&new-line}
             , (if rs-cash-book = integer({&cash-book-firm}) then "главной БД фирмы" else "БД объекта")
             , (if rs-cash-book = integer({&cash-book-firm}) then v-firm-db-num else v-obj-db-num )
             )
  view-as alert-box warning.
  v-no-save-counters = yes.
end.


assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')) no-error.
    if available thbjattr_thbj-attr then do:
      assign
      buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  wh = wh:next-sibling.
end.
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
   if v-same = no then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
run adm/shattri.p (
               input "check":U
             , input p-obj-type
             , input p-obj-code
             , input {&attr-fin-doc}
             , input '':U
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
if v-no-save-counters then do:
  for each  thbjattr_thbj-attr where
            thbjattr_thbj-attr.prop-code = {&attr-fin-doc_current-pko}.
    delete thbjattr_thbj-attr.
  end.
  for each thbjattr_thbj-attr where
            thbjattr_thbj-attr.prop-code = {&attr-fin-doc_current-rko}.
    delete thbjattr_thbj-attr.
  end.
end.
RUN thbjattr_set-section IN THIS-PROCEDURE (
     input p-obj-type
    ,input p-obj-code
    ,input {&attr-fin-doc}
    ,input table thbjattr_thbj-attr
) NO-ERROR.
IF ERROR-STATUS:error THEN do:
  MESSAGE ERROR-STATUS:get-message(1)  SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX.
  UNDO, RETURN ERROR.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-changed-dpt-option Dialog-Frame 
PROCEDURE proc-value-changed-dpt-option :
DEFINE INPUT PARAMETER p-dpt-option AS CHARACTER NO-UNDO.
case p-dpt-option:
  when "blank"
  or
  when  "object"
  then do:
    assign
    f-dpt-dflt-name = ''
    f-dpt-dflt-type = ''
    f-dpt-dflt-code = 0.
    display
    f-dpt-dflt-name
    f-dpt-dflt-type
    f-dpt-dflt-code
    with frame {&frame-name} .
    hide
    f-dpt-dflt-name
    f-dpt-dflt-type
    f-dpt-dflt-code
    in frame {&frame-name} .
  end.
  when "dflt" then do:
    display
    f-dpt-dflt-name
    f-dpt-dflt-type
    f-dpt-dflt-code
    with frame {&frame-name} .
    if p-mode <> {&lookup} then do:
      enable
      f-dpt-dflt-name
      f-dpt-dflt-type
      f-dpt-dflt-code
      with frame {&frame-name} .
    end.
  end.
end case. /*case p-dpt-option:*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

*/