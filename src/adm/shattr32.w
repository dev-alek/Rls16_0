&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE BUFFER X_db FOR ub.db.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута (thbj-attr) "code-range"

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
DEFINE INPUT PARAMETER p-obj-type as character.
DEFINE INPUT PARAMETER p-obj-code as integer.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута (thbj-attr) 'code-range'".
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

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-cdrgbcgb f-cdrgscgb ~
f-cdrgsclc f-cdrgssgb f-cdrgsslc f-cdrgpglc f-cdrgctgb f-cdrgdcgb ~
f-cdrgdrgb f-cdrgfmgb f-cdrgpngb f-cdrgcagb f-cdrgfdgb
&Scoped-Define DISPLAYED-OBJECTS f-cdrgbcgb f-cdrgscgb f-cdrgsclc ~
f-cdrgssgb f-cdrgsslc f-cdrgpglc f-cdrgctgb f-cdrgdcgb f-cdrgdrgb ~
f-cdrgfmgb f-cdrgpngb f-cdrgcagb f-cdrgfdgb

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

DEFINE VARIABLE f-cdrgbcgb AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 100000
     LABEL "Размер диапазона для собственных кодов товаров"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgcagb AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 5000
     LABEL "Размер диапазона для кодов точек привязки"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgctgb AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 2000
     LABEL "Размер диапазона для кодов договоров"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgdcgb AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 100000
     LABEL "Размер диапазона для кодов ДК"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgdrgb AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 1000
     LABEL "Размер диапазона для кодов скидок и расписаний"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgfdgb AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 1000
     LABEL "Размер диапазона для кодов финансовых документов"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgfmgb AS INTEGER FORMAT ">>,>>>,>>9":U INITIAL 10000
     LABEL "Размер диапазона для кодов организаций"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgpglc AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 1000
     LABEL "Размер диапазона для лок. штучных кодов для весов"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgpngb AS INTEGER FORMAT ">>,>>>,>>9":U INITIAL 5000
     LABEL "Размер диапазона для кодов физ.лиц"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgscgb AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 1000
     LABEL "Размер диапазона для глобальных весовых кодов"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgsclc AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 1000
     LABEL "Размер диапазона для локальных весовых кодов"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgssgb AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 1000
     LABEL "Размер диапазона для глобальных взвешиваемых кодов"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-cdrgsslc AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 1000
     LABEL "Размер диапазона для локальных взвешиваемых кодов"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-cdrgbcgb AT ROW 3 COL 52 COLON-ALIGNED
     f-cdrgscgb AT ROW 4 COL 52 COLON-ALIGNED WIDGET-ID 12
     f-cdrgsclc AT ROW 5 COL 52 COLON-ALIGNED WIDGET-ID 14
     f-cdrgssgb AT ROW 6 COL 52 COLON-ALIGNED WIDGET-ID 18
     f-cdrgsslc AT ROW 7 COL 52 COLON-ALIGNED WIDGET-ID 16
     f-cdrgpglc AT ROW 8 COL 52 COLON-ALIGNED WIDGET-ID 22
     f-cdrgctgb AT ROW 9 COL 52 COLON-ALIGNED WIDGET-ID 2
     f-cdrgdcgb AT ROW 10 COL 52 COLON-ALIGNED WIDGET-ID 4
     f-cdrgdrgb AT ROW 11 COL 52 COLON-ALIGNED WIDGET-ID 6
     f-cdrgfmgb AT ROW 12 COL 52 COLON-ALIGNED WIDGET-ID 8
     f-cdrgpngb AT ROW 13 COL 52 COLON-ALIGNED WIDGET-ID 10
     f-cdrgcagb AT ROW 14 COL 52 COLON-ALIGNED WIDGET-ID 20
     f-cdrgfdgb AT ROW 15 COL 52 COLON-ALIGNED WIDGET-ID 24
     SPACE(33.24) SKIP(2.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Опции работы с диапазонами кодов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: X_db B "?" ? ub db
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Опции работы с диапазонами кодов */
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
  IF p-obj-type <> {&db}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&db} then do:
    FIND FIRST X_db NO-LOCK WHERE X_db.db-num = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_db THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
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
  if p-obj-type = {&db} then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    and X_db.db-num <> v-cntxt-db-num
    then do:
        MESSAGE
        "Нельзя менять параметры в чужой УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-code-range}
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
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-code-range}
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
  DISPLAY f-cdrgbcgb f-cdrgscgb f-cdrgsclc f-cdrgssgb f-cdrgsslc f-cdrgpglc
          f-cdrgctgb f-cdrgdcgb f-cdrgdrgb f-cdrgfmgb f-cdrgpngb f-cdrgcagb
          f-cdrgfdgb
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-cdrgbcgb f-cdrgscgb f-cdrgsclc f-cdrgssgb
         f-cdrgsslc f-cdrgpglc f-cdrgctgb f-cdrgdcgb f-cdrgdrgb f-cdrgfmgb
         f-cdrgpngb f-cdrgcagb f-cdrgfdgb
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
            , input {&attr-code-range}
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
  IF v-entry = {&attr-code-range_cdrgbcgb} THEN DO:
    ASSIGN
    f-cdrgbcgb = thbjattr_thbj-attr.property-value-integer
    f-cdrgbcgb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgctgb} THEN DO:
    ASSIGN
    f-cdrgctgb = thbjattr_thbj-attr.property-value-integer
    f-cdrgctgb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgdcgb} THEN DO:
    ASSIGN
    f-cdrgdcgb = thbjattr_thbj-attr.property-value-integer
    f-cdrgdcgb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgdrgb} THEN DO:
    ASSIGN
    f-cdrgdrgb = thbjattr_thbj-attr.property-value-integer
    f-cdrgdrgb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgfmgb} THEN DO:
    ASSIGN
    f-cdrgfmgb = thbjattr_thbj-attr.property-value-integer
    f-cdrgfmgb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgpngb} THEN DO:
    ASSIGN
    f-cdrgpngb = thbjattr_thbj-attr.property-value-integer
    f-cdrgpngb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgscgb} THEN DO:
    ASSIGN
    f-cdrgscgb = thbjattr_thbj-attr.property-value-integer
    f-cdrgscgb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgsclc} THEN DO:
    ASSIGN
    f-cdrgsclc = thbjattr_thbj-attr.property-value-integer
    f-cdrgsclc:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgssgb} THEN DO:
    ASSIGN
    f-cdrgssgb = thbjattr_thbj-attr.property-value-integer
    f-cdrgssgb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgsslc} THEN DO:
    ASSIGN
    f-cdrgsslc = thbjattr_thbj-attr.property-value-integer
    f-cdrgsslc:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgcagb} THEN DO:
    ASSIGN
    f-cdrgcagb = thbjattr_thbj-attr.property-value-integer
    f-cdrgcagb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgpglc} THEN DO:
    ASSIGN
    f-cdrgpglc = thbjattr_thbj-attr.property-value-integer
    f-cdrgpglc:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-code-range_cdrgfdgb} THEN DO:
    ASSIGN
    f-cdrgfdgb = thbjattr_thbj-attr.property-value-integer
    f-cdrgfdgb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
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
FRAME {&FRAME-NAME}:TITLE = substitute("&1 &2 &3"
                                        ,(FRAME {&FRAME-NAME}:TITLE)
                                        ,(if p-obj-type = {&db} then "БД" else "")
                                        ,(if p-obj-type = {&db} then string(p-obj-code) else "")
                                        )
v-tab-order = "f-cdrgbcgb,f-cdrgscgb,f-cdrgsclc,f-cdrgssgb,f-cdrgsslc,f-cdrgpglc,f-cdrgctgb,f-cdrgdcgb,f-cdrgdrgb,f-cdrgfmgb,f-cdrgpngb,f-cdrgcagb.f-cdrgfdgb".
DISPLAY
f-cdrgbcgb
f-cdrgscgb
f-cdrgsclc
f-cdrgssgb
f-cdrgsslc
f-cdrgpglc
f-cdrgctgb
f-cdrgdcgb
f-cdrgdrgb
f-cdrgfmgb
f-cdrgpngb
f-cdrgcagb
f-cdrgfdgb
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
f-cdrgbcgb WHEN p-mode = {&UPDATE}
f-cdrgscgb WHEN p-mode = {&UPDATE}
f-cdrgsclc WHEN p-mode = {&UPDATE}
f-cdrgssgb WHEN p-mode = {&UPDATE}
f-cdrgsslc WHEN p-mode = {&UPDATE}
f-cdrgpglc WHEN p-mode = {&UPDATE}
f-cdrgctgb WHEN p-mode = {&UPDATE}
f-cdrgdcgb WHEN p-mode = {&UPDATE}
f-cdrgdrgb WHEN p-mode = {&UPDATE}
f-cdrgfmgb WHEN p-mode = {&UPDATE}
f-cdrgpngb WHEN p-mode = {&UPDATE}
f-cdrgcagb WHEN p-mode = {&UPDATE}
f-cdrgfdgb WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    b-quit:column = 1
    .
END.
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
f-cdrgbcgb
f-cdrgscgb
f-cdrgsclc
f-cdrgssgb
f-cdrgsslc
f-cdrgpglc
f-cdrgctgb
f-cdrgdcgb
f-cdrgdrgb
f-cdrgfmgb
f-cdrgpngb
f-cdrgcagb
f-cdrgfdgb
.
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
             , input {&attr-code-range}
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
RUN thbjattr_set-section IN THIS-PROCEDURE (
     input p-obj-type
    ,input p-obj-code
    ,input {&attr-code-range}
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
