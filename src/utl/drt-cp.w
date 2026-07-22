&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование свойства Run-params

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/08/08
Author: Bakhtadze Natalya
Creation date: 05/08/09

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-param-num AS CHARACTER NO-UNDO.
DEFINE INPUT-output PARAMETER p-param-value AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование свойства Run-params".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/dr-flddf.i }
DEFINE VARIABLE v-param-value AS character NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-param-num ~
f-param-name cb-data-type Cb-param-mode f-param-descr cb-fields
&Scoped-Define DISPLAYED-OBJECTS f-param-num f-param-name cb-data-type ~
Cb-param-mode f-param-descr cb-fields

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

DEFINE VARIABLE cb-data-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип данных параметра"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE cb-fields AS CHARACTER FORMAT "X(256)":U
     LABEL "Поле привязки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE Cb-param-mode AS CHARACTER FORMAT "X(256)":U
     LABEL "Мода параметра"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-param-descr AS CHARACTER FORMAT "X(256)":U
     LABEL "Описание"
     VIEW-AS FILL-IN
     SIZE 37 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-param-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название параметра"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-param-num AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "№ параметра"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-param-num AT ROW 3 COL 22 COLON-ALIGNED WIDGET-ID 4
     f-param-name AT ROW 5 COL 22 COLON-ALIGNED WIDGET-ID 2
     cb-data-type AT ROW 7.13 COL 22 COLON-ALIGNED WIDGET-ID 6
     Cb-param-mode AT ROW 9.53 COL 22 COLON-ALIGNED WIDGET-ID 10
     f-param-descr AT ROW 11.67 COL 22 COLON-ALIGNED WIDGET-ID 12
     cb-fields AT ROW 13.53 COL 22 COLON-ALIGNED WIDGET-ID 16
     SPACE(50.70) SKIP(9.02)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Свойства параметра правила скидки или расписания"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
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





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Свойства параметра правила скидки или расписания */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN NO-APPLY.
  ASSIGN
  p-param-value = v-param-value.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Свойства параметра правила скидки или расписания */
DO:
  APPLY "END-ERROR":U TO SELF.
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
  IF NOT (p-mode = {&LOOKUP}
          OR p-mode = {&add-def}
          OR p-mode = {&UPDATE}) THEN DO:
     MESSAGE
     substitute("Неверное значение параметра p-mode = &1", p-mode)
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
  IF p-mode <> {&add-def}
  AND NUM-ENTRIES(p-param-value) < 5 THEN DO:
     MESSAGE
     "Не все поля определены!"
     VIEW-AS ALERT-BOX ERROR.
  END.
  v-param-value = p-param-value.
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
  DISPLAY f-param-num f-param-name cb-data-type Cb-param-mode f-param-descr
          cb-fields
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-param-num f-param-name cb-data-type
         Cb-param-mode f-param-descr cb-fields
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
cb-data-type:LIST-ITEMS IN FRAME {&frame-name} = {&ABL-simple-datatype-list} + {&comma-char} + {&abl-datatype-handle}
cb-param-mode:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&script-parmode-list} .
cb-fields:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&dr-flddf_doc-fields} + {&comma-char} +
                                              {&dr-flddf_gline-fields} + {&comma-char} +
                                              {&dr-flddf_dline-fields} + {&comma-char} +
                                              {&dr-flddf_cntxt-fields} + {&comma-char} +
                                              {&dr-flddf_pline-fields}

.

ASSIGN
f-param-num = INTEGER(p-param-num)
f-param-name = ENTRY(1, p-param-value)
cb-data-type = (IF NUM-ENTRIES(p-param-value) > 1
                  THEN ENTRY(2, p-param-value)
                  ELSE '')
cb-param-mode = (IF NUM-ENTRIES(p-param-value) > 2
                 THEN ENTRY(3, p-param-value)
                 ELSE '')
f-param-descr = (IF NUM-ENTRIES(p-param-value) > 3
                THEN ENTRY(4, p-param-value)
                ELSE '')
cb-fields = (IF NUM-ENTRIES(p-param-value) > 4
                THEN ENTRY(5, p-param-value)
                ELSE '')
.
DISPLAY
f-param-num
f-param-name
cb-data-type
Cb-param-mode
f-param-descr
cb-fields
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
f-param-num WHEN p-mode <> {&lookup}
f-param-name WHEN p-mode <> {&lookup}
cb-data-type WHEN p-mode <> {&lookup}
Cb-param-mode WHEN p-mode <> {&lookup}
f-param-descr WHEN p-mode <> {&lookup}
cb-fields WHEN p-mode <> {&lookup}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  assign
  b-quit:column = 1
  .
  hide
  b-exit in frame {&frame-name} .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
IF p-mode = {&LOOKUP} THEN UNDO, RETURN ERROR.
ASSIGN frame {&frame-name}
f-param-name
cb-data-type
Cb-param-mode
f-param-descr
cb-fields
v-param-value = f-param-name + {&comma-char} +
                cb-data-type + {&comma-char} +
                cb-param-mode + {&comma-char} +
                f-param-descr + {&comma-char} +
                cb-fields.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME