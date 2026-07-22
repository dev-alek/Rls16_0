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

Тескт поля СОСТАВ СЫРЬЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mode as character no-undo .
DEFINE INPUT PARAMETER p-gds-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-spr-param AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-attr-value AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-setted AS LOGICAL NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тескт поля СОСТАВ СЫРЬЯ - формат".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ rep/frmlib.i }

DEFINE TEMP-TABLE temp-widget
FIELD NAME_ AS CHARACTER
FIELD LENGTH_ AS DECIMAL
FIELD index_ AS INTEGER
FIELD HANDLE_ AS HANDLE
FIELD format_ AS CHARACTER
FIELD width_ AS DECIMAL
INDEX pi IS UNIQUE PRIMARY
NAME_
INDEX iindex
INDEX_.

DEFINE VARIABLE v-struct AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help e-struct
&Scoped-Define DISPLAYED-OBJECTS e-struct

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

DEFINE VARIABLE e-struct AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 72 BY 3.2 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     e-struct AT ROW 2 COL 28 NO-LABEL WIDGET-ID 2
     "(текст из карточки товара)" VIEW-AS TEXT
          SIZE 26 BY 1.07 AT ROW 3.13 COL 1 WIDGET-ID 6
          FGCOLOR 12
     "Состав сырья" VIEW-AS TEXT
          SIZE 13 BY 1.07 AT ROW 2.07 COL 1 WIDGET-ID 4
     SPACE(85.70) SKIP(20.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тескт поля СОСТАВ СЫРЬЯ - формат поля"
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

ASSIGN
       e-struct:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE
       e-struct:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тескт поля СОСТАВ СЫРЬЯ - формат поля */
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
  RUN Myenable NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
FOR EACH temp-widget:
  delete widget temp-widget.handle_.
  delete temp-widget.

END.

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
  DISPLAY e-struct
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help e-struct
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE variable v-ii AS INTEGER NO-UNDO.
DEFINE variable v-num-rows AS integer NO-UNDO.
DEFINE variable v-length AS DECIMAL NO-UNDO.
DEFINE variable output-num-lines AS integer NO-UNDO.
DEFINE variable v-num-entries AS integer NO-UNDO.
define variable v-uh as handle no-undo .
define variable v-struct as character no-undo .
define variable v-setted as logical no-undo .

DEFINE BUFFER buf_goods FOR ub.goods.
  assign
  v-uh = this-procedure:instantiating-procedure.
  do while valid-handle(v-uh):
    if lookup("cb-for-struct-i", v-uh:internal-entries) > 0 then do:
      run cb-for-struct-i in v-uh ( output v-struct) no-error.
      ASSIGN
      e-struct:SCREEN-VALUE IN FRAME {&frame-name} = v-struct
      v-setted = yes
      .
      if p-mode = {&add-def}
      then do:
        case p-spr-param:
          when {&attr-15x80} then do:
            p-attr-value = Break-n-line
            ( INPUT v-struct
              ,INPUT right-trim(fill(string(80) + {&comma-char}, 15), {&comma-char})
              ,OUTPUT output-num-lines
              ) .
          end.
          when {&attr-8x50} then do:
            p-attr-value = Break-n-line
            ( INPUT v-struct
              ,INPUT right-trim(fill(string(50) + {&comma-char}, 8), {&comma-char})
              ,OUTPUT output-num-lines
              ) .
          end.
          when {&attr-6x50} then do:
            p-attr-value = Break-n-line
            ( INPUT v-struct
              ,INPUT right-trim(fill(string(50) + {&comma-char}, 6), {&comma-char})
              ,OUTPUT output-num-lines
              ) .
          end.
        end case.
      end.
      leave.
    end.
    v-uh = v-uh:instantiating-procedure.
  end.
IF p-gds-code > 0 THEN DO:
  if v-struct = ''
  then do:
    FIND FIRST buf_goods NO-LOCK WHERE
              buf_goods.gds-code = p-gds-code.
    if not v-setted then
    ASSIGN
    e-struct:SCREEN-VALUE IN FRAME {&frame-name} = buf_goods.struct.
  end.
END.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = substitute("&1 &2"
                                       , FRAME {&frame-name}:TITLE
                                       , p-spr-param).

ASSIGN
v-num-rows = integer(ENTRY(1, p-spr-param, "x"))
v-length = decimal(ENTRY(2, p-spr-param, "x"))
NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
   substitute("Неверный формат для задания поля СОСТАВ СЫРЬЯ = &1"
              , p-spr-param)
  VIEW-AS ALERT-BOX ERROR.
  RETURN ERROR.
END.
ASSIGN
v-num-entries = num-entries(p-attr-value, {&delim-par})
.
DO v-ii = 1 TO v-num-rows:
   CREATE temp-widget.
   ASSIGN
   temp-widget.NAME_ = SUBSTITUTE("fill-in-&1", v-ii)
   temp-widget.LENGTH_  = v-length
   temp-widget.index_  = v-ii
   temp-widget.format_  = substitute("X(&1)", v-length)
   temp-widget.width_  = v-length + 2
   .
   CREATE FILL-IN temp-widget.HANDLE_
   ASSIGN ROW = 6 + v-ii
   COLUMN = 1
   FORMAT = temp-widget.format_
   WIDTH = temp-widget.WIDTH_
   FRAME = FRAME {&FRAME-name}:HANDLE
   SENSITIVE = (p-mode <> {&lookup})
   VISIBLE = TRUE
   SCREEN-VALUE = (IF v-num-entries >= v-ii
                   THEN ENTRY(v-ii, p-attr-value, {&delim-par})
                   ELSE '')
   .
END.
ENABLE
B-exit when p-mode <> {&lookup}
b-quit
B-Help
e-struct
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  hide
  b-exit
  in frame {&frame-name} .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-struct AS CHARACTER NO-UNDO.
if p-mode = {&lookup} then return.
FOR each temp-widget by index_:
  ASSIGN
  v-struct = v-struct + (IF temp-widget.INDEX_ = 1 THEN '':U ELSE {&delim-par}) + temp-widget.HANDLE_:SCREEN-VALUE.
END.
ASSIGN
p-attr-value = v-struct
p-setted = YES
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME