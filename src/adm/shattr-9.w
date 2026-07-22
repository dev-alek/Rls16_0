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

Редактирование атрибута магазина (thbj-attr) "cd-type-ncr-gm"

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
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'cd-type-ncr-gm'".
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
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

define temp-table temp-xtd no-undo
field id as integer format "99"
field f-value AS CHARACTER
field f-label AS CHARACTER
index pi is unique
primary
id
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-xtd

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-xtd

/* Definitions for BROWSE BR-xtd                                        */
&Scoped-define FIELDS-IN-QUERY-BR-xtd temp-xtd.id temp-xtd.f-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-xtd
&Scoped-define SELF-NAME BR-xtd
&Scoped-define QUERY-STRING-BR-xtd FOR EACH temp-xtd
&Scoped-define OPEN-QUERY-BR-xtd OPEN QUERY {&SELF-NAME} FOR EACH temp-xtd.
&Scoped-define TABLES-IN-QUERY-BR-xtd temp-xtd
&Scoped-define FIRST-TABLE-IN-QUERY-BR-xtd temp-xtd


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-xtd}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RS-ncrpgpfx RS-ncrscpfx ~
RS-save-param BR-xtd B-up B-down E-save-param l-ncrpgpfx l-ncrscpfx ~
l-save-param l-save-param-2 l-ncrdrank l-ncrdrank-2
&Scoped-Define DISPLAYED-OBJECTS RS-ncrpgpfx RS-ncrscpfx RS-save-param ~
E-save-param l-ncrpgpfx l-ncrscpfx l-save-param l-save-param-2 l-ncrdrank ~
l-ncrdrank-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-down
     LABEL "В&низ"
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

DEFINE BUTTON B-up
     LABEL "Вв&ерх"
     SIZE 10 BY 1.

DEFINE VARIABLE E-save-param AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 49 BY 9 NO-UNDO.

DEFINE VARIABLE l-ncrdrank AS CHARACTER FORMAT "X(256)":U INITIAL "Приоритет скидки на товар"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-ncrdrank-2 AS CHARACTER FORMAT "X(256)":U INITIAL "при наличии скидок неск. типов:"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-ncrpgpfx AS CHARACTER FORMAT "X(256)":U INITIAL "Префикс штучного бар-кода для весов:"
      VIEW-AS TEXT
     SIZE 35 BY .67 NO-UNDO.

DEFINE VARIABLE l-ncrscpfx AS CHARACTER FORMAT "X(256)":U INITIAL "Префикс весового бар-кода:"
      VIEW-AS TEXT
     SIZE 26 BY .67 NO-UNDO.

DEFINE VARIABLE l-save-param AS CHARACTER FORMAT "X(256)":U INITIAL "Расположение резервных копий неизменяемых"
      VIEW-AS TEXT
     SIZE 46.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-save-param-2 AS CHARACTER FORMAT "X(256)":U INITIAL "'ручных настроек' для кассы"
      VIEW-AS TEXT
     SIZE 45.5 BY .67 NO-UNDO.

DEFINE VARIABLE RS-ncrpgpfx AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "24", 24,
"28", 28
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE RS-ncrscpfx AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "23", 23,
"25", 25
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE RS-save-param AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Не используется", "no",
"В директории файлов кассовых настроек", "NCR",
"В директории кодов IBS TH", "IBS"
     SIZE 45.5 BY 3.77 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-xtd FOR
      temp-xtd SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-xtd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-xtd Dialog-Frame _FREEFORM
  QUERY BR-xtd DISPLAY
      temp-xtd.id COLUMN-LABEL "Приоритет"
temp-xtd.f-label COLUMN-LABEL "Тип скидки" FORMAT "X(20)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 34 BY 9.2 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     RS-ncrpgpfx AT ROW 2 COL 78 NO-LABEL WIDGET-ID 4
     RS-ncrscpfx AT ROW 2.27 COL 27 NO-LABEL
     RS-save-param AT ROW 4.77 COL 49.5 NO-LABEL
     BR-xtd AT ROW 5.77 COL 2
     B-up AT ROW 5.77 COL 37
     B-down AT ROW 6.77 COL 37
     E-save-param AT ROW 8.77 COL 49.5 NO-LABEL
     l-ncrpgpfx AT ROW 2 COL 40 NO-LABEL WIDGET-ID 2
     l-ncrscpfx AT ROW 2.5 COL 1 NO-LABEL
     l-save-param AT ROW 3 COL 49.5 NO-LABEL
     l-save-param-2 AT ROW 3.77 COL 49.5 NO-LABEL
     l-ncrdrank AT ROW 4 COL 2.5 NO-LABEL
     l-ncrdrank-2 AT ROW 4.77 COL 2.5 NO-LABEL
     SPACE(65.24) SKIP(12.31)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры POS NCR-GM"
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
                                                                        */
/* BROWSE-TAB BR-xtd RS-save-param Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       E-save-param:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN l-ncrdrank IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-ncrdrank-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-ncrpgpfx IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-ncrscpfx IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-save-param IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-save-param-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-xtd
/* Query rebuild information for BROWSE BR-xtd
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-xtd.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-xtd */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры POS NCR-GM */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-down Dialog-Frame
ON CHOOSE OF B-down IN FRAME Dialog-Frame /* Вниз */
DO:
{ gbl/stdbtn.i }
 DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf_temp-xtd FOR temp-xtd.
 IF NOT AVAILABLE temp-xtd THEN RETURN NO-APPLY.
FIND last buf_temp-xtd WHERE
            USE-INDEX pi .
 IF temp-xtd.id = buf_temp-xtd.id THEN DO:
     BELL.
     RETURN NO-APPLY.
 END.
 ASSIGN
 v-old = temp-xtd.Id
 v-new = temp-xtd.id + 1
 .
 FIND FIRST buf_temp-xtd WHERE
            buf_temp-xtd.id = v-new NO-ERROR.
 ASSIGN
 temp-xtd.id = 0.
 RELEASE temp-xtd.
 buf_temp-xtd.id = v-old.
 RELEASE buf_temp-xtd.
 FIND FIRST buf_temp-xtd WHERE
            buf_temp-xtd.id = 0.
 ASSIGN
 buf_temp-xtd.id = v-new.
 RELEASE buf_temp-xtd.
 {&OPEN-QUERY-br-xtd}
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


&Scoped-define SELF-NAME B-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-up Dialog-Frame
ON CHOOSE OF B-up IN FRAME Dialog-Frame /* Вверх */
DO:
{ gbl/stdbtn.i }
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf_temp-xtd FOR temp-xtd.
 IF NOT AVAILABLE temp-xtd THEN RETURN NO-APPLY.
 IF temp-xtd.id = 1 THEN DO:
     BELL.
     RETURN NO-APPLY.
 END.
 ASSIGN
 v-old = temp-xtd.Id
 v-new = temp-xtd.id - 1
 .
 FIND FIRST buf_temp-xtd WHERE
            buf_temp-xtd.id = v-new NO-ERROR.
 ASSIGN
 temp-xtd.id = 0.
 RELEASE temp-xtd.
 buf_temp-xtd.id = v-old.
 RELEASE buf_temp-xtd.
 FIND FIRST buf_temp-xtd WHERE
            buf_temp-xtd.id = 0.
 ASSIGN
 buf_temp-xtd.id = v-new.
 RELEASE buf_temp-xtd.
 {&OPEN-QUERY-br-xtd}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-save-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-save-param Dialog-Frame
ON VALUE-CHANGED OF RS-save-param IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-save-param.
  CASE rs-save-param:
      WHEN 'no':U THEN DO:
          ASSIGN
          e-save-param:SCREEN-VALUE = "При передаче на кассы различных типов скидок " +
                                     "(на итог чека, скидок для различных категорий покупателей и т.д.)," +
                                     " хранящихся в файлах кассовых настроек P_REGPAR.DAT, " +
                                     "НЕ ИСПОЛЬЗУЕТСЯ дополнительная проверка, " +
                                     "можно ли данный тип скидки задавать пересылкой через IBS TH " +
                                     "или же данная скидка может быть изменена ТОЛЬКО администратором вручную - " +
                                     "РЕЗЕРВНЫЕ КОПИИ для данных файлов НЕ ХРАНЯТСЯ".
      END.
      WHEN 'IBS':U THEN DO:
          ASSIGN
          e-save-param:SCREEN-VALUE = "При передаче на кассы различных типов скидок " +
                                     "(на итог чека, скидок для различных категорий покупателей и т.д.)," +
                                     " хранящихся в файлах кассовых настроек P_REGPAR.DAT, " +
                                     "ИСПОЛЬЗУЕТСЯ дополнительная проверка, " +
                                     "можно ли данный тип скидки задавать пересылкой через IBS TH " +
                                     "или же данная скидка может быть изменена ТОЛЬКО администратором вручную - " +
                                     "РЕЗЕРВНЫЕ КОПИИ для данных файлов (с расширением .sav) ХРАНЯТСЯ в директориях системы IBS TH".
      END.
      WHEN 'NCR':U THEN DO:
          ASSIGN
          e-save-param:SCREEN-VALUE = "При передаче на кассы различных типов скидок " +
                                     "(на итог чека, скидок для различных категорий покупателей и т.д.)," +
                                     " хранящихся в файлах кассовых настроек P_REGPAR.DAT, " +
                                     "ИСПОЛЬЗУЕТСЯ дополнительная проверка, " +
                                     "можно ли данный тип скидки задавать пересылкой через IBS TH " +
                                     "или же данная скидка может быть изменена ТОЛЬКО администратором вручную - " +
                                     "РЕЗЕРВНЫЕ КОПИИ для данных файлов (с расширением .sav) ХРАНЯТСЯ " +
                                     "рядом с основными файлами - в директории, " +
                                     "задаваемых настройками out3 секции [kassa-ncr-gm] ini-файла системы IBS TH".
      END.

  ENd CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-xtd
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
    { gbl/hostcode.i {&shop} p-obj-code v-host-code }
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
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ncr-gm}
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
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ncr-gm}
    AND   locked_thbj-attr.prop-code = '':u NO-ERROR.
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
  DISPLAY RS-ncrpgpfx RS-ncrscpfx RS-save-param E-save-param l-ncrpgpfx
          l-ncrscpfx l-save-param l-save-param-2 l-ncrdrank l-ncrdrank-2
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RS-ncrpgpfx RS-ncrscpfx RS-save-param BR-xtd B-up
         B-down E-save-param l-ncrpgpfx l-ncrscpfx l-save-param l-save-param-2
         l-ncrdrank l-ncrdrank-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-kat-id as integer no-undo.
define variable v-dop as character no-undo.
define variable v-pcnt as decimal no-undo.
define variable v-ncrgmdsc as character no-undo.
define variable v-ncrdrank as character no-undo.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable ii as integer no-undo .
FOR EACH temp-xtd:
  DELETE temp-xtd.
END.
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
            , input {&attr-cd-type-ncr-gm}
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
  IF v-entry = {&attr-cd-type-ncr-gm_ncrscpfx} THEN DO:
    ASSIGN
    RS-ncrscpfx = thbjattr_thbj-attr.property-value-integer.
  END.
  IF v-entry = {&attr-cd-type-ncr-gm_ncrpgpfx} THEN DO:
    ASSIGN
    RS-ncrpgpfx = thbjattr_thbj-attr.property-value-integer.
  END.
  IF v-entry = {&attr-cd-type-ncr-gm_ncrdrank} THEN DO:
    ASSIGN
    v-ncrdrank = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-ncr-gm_save-param} THEN DO:
    ASSIGN
    RS-save-param = thbjattr_thbj-attr.property-value-character.
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
 DO ii = 1 TO LENGTH(v-ncrdrank):
     CREATE temp-xtd.
     ASSIGN
     temp-xtd.id = ii
     temp-xtd.f-value = SUBSTRING(v-ncrdrank, ii, 1)
     temp-xtd.f-label = (IF substring(v-ncrdrank, ii, 1) = "X":u
                         THEN "Скидка на кол-во"
                         ELSE (IF substring(v-ncrdrank, ii, 1) = "T":u
                               THEN "Скидка по времени"
                               ELSE "Скидка по дате")
                          )
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
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "RS-ncrscpfx,RS-bcrpgpfx,br-xtd,b-up,b-down,rs-save-param,e-save-param"
.
DISPLAY
RS-save-param
RS-ncrscpfx
l-ncrscpfx
RS-ncrpgpfx
l-ncrpgpfx
l-ncrdrank
l-ncrdrank-2
l-save-param
l-save-param-2
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
br-xtd
RS-ncrscpfx WHEN p-mode = {&UPDATE}
RS-ncrpgpfx WHEN p-mode = {&UPDATE}
b-up   WHEN p-mode = {&UPDATE}
b-down   WHEN p-mode = {&UPDATE}
rs-save-param WHEN p-mode = {&UPDATE}
e-save-param WHEN p-mode = {&UPDATE}
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
{&OPEN-QUERY-br-xtd}
{&OPEN-QUERY-br-kat-id}
APPLY "value-changed" TO rs-save-param.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-ncrgmdsc as character no-undo.
define variable v-ncrdrank as character no-undo.
define variable v-same as logical no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
RS-ncrscpfx
RS-ncrpgpfx
RS-save-param
.
for each temp-xtd no-lock:
    assign
    v-ncrdrank = v-ncrdrank + temp-xtd.f-value
    .

end.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ncr-gm_ncrscpfx}.
assign
thbjattr_thbj-attr.property-value-integer = RS-ncrscpfx.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ncr-gm_ncrpgpfx}.
assign
thbjattr_thbj-attr.property-value-integer = RS-ncrpgpfx.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ncr-gm_ncrdrank}.
assign
thbjattr_thbj-attr.property-value-character = v-ncrdrank.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ncr-gm_save-param}.
assign
thbjattr_thbj-attr.property-value-character = rs-save-param.
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
            , input {&attr-cd-type-ncr-gm}
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
      ,input {&attr-cd-type-ncr-gm}
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
