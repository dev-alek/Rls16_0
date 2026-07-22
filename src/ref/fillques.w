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

Ввести строку, которая начинается с вопросительного знака

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/11/06
Author: Bakhtadze Natalya
Creation date: 04/11/06

Цель - требуется ввести строку, которая начинается с вопросительного знака.
Если попробовать воспользоваться стандартным FILL-IN то он
при нажатии вопросительного знака в первой позиции производит очистку пол
и его инициализацию неопределенным значением.

Один из вариантов решения приводится ниже в прикрепленном файле.
FILL-IN не разрешен для ввода и нажатия клавиш обрабатываются в триггере фрейма

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-field AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-label AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-length AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-validchars AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-field-new AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS LOGICAL NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ввести строку, которая начинается с вопросительного знака".
{ cmp/vssrevis.i }


/* Local Variable Definitions ---                                       */

DEFINE VARIABLE v-pos-ind AS INTEGER NO-UNDO.
{ cmp/showinf.i }
{ gbl/color.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-value v-pos EDITOR-1 
&Scoped-Define DISPLAYED-OBJECTS f-value v-pos EDITOR-1 

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
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 74.5 BY 3.75 NO-UNDO.

DEFINE VARIABLE f-value AS CHARACTER FORMAT "X(19)" 
     LABEL "Значение" 
     VIEW-AS FILL-IN 
     SIZE 21.5 BY 1.

DEFINE VARIABLE v-pos AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 21.5 BY .42
     BGCOLOR 8 FGCOLOR 12  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-value AT ROW 4.21 COL 15.5 COLON-ALIGNED
     v-pos AT ROW 5.25 COL 15.5 COLON-ALIGNED NO-LABEL
     EDITOR-1 AT ROW 6.25 COL 3.5 NO-LABEL
     SPACE(6.37) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Редактирование поля с вопросительным знаком"
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
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

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
ON GO OF FRAME Dialog-Frame /* Редактирование поля с вопросительным знаком */
DO:
  ASSIGN
  f-value
  p-ok = YES
  p-field-new = f-value
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Редактирование поля с вопросительным знаком */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-pos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-pos Dialog-Frame
ON ENTRY OF v-pos IN FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
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


on ANY-KEY OF FRAME {&FRAME-NAME}
OR ANY-KEY OF b-quit
OR ANY-KEY OF b-exit
OR ANY-KEY OF b-help
do:
  define variable v-length as integer no-undo .


  assign
    v-length = length(f-value)
  .

  if index(p-validchars, last-event :label) > 0
  then do:
    if v-length < 20
    then do:
      assign
        f-value = substring(f-value, 1, v-pos-ind - 1) + last-event :label
                 + substring(f-value, v-pos-ind, v-length - v-pos-ind + 1)
      .
      assign
        v-pos-ind = v-pos-ind + 1
      .
    end.
  end.
  if last-event :label = "backspace" then do:
    assign
      v-length = length(f-value)
    .
    if  v-length > 0
    and v-pos-ind > 1
    then do:
      assign
        f-value = substring(f-value, 1, v-pos-ind - 2)
                 + substring(f-value, v-pos-ind, v-length - v-pos-ind + 1)
      .
      assign
        v-pos-ind = v-pos-ind - 1
      .
    end.
  end.
  if last-event :label = "del" then do:
    assign
      v-length = length(f-value)
    .
    if  v-length > 0
    and v-pos-ind < v-length + 1
    and v-pos-ind > 0
    then do:
      assign
        f-value = substring(f-value, 1, v-pos-ind - 1)
                 + substring(f-value, v-pos-ind + 1, v-length - v-pos-ind + 1)
      .
    end.
  end.

  if last-event :label = "home" then do:
    assign
      v-pos-ind = 1
    .
  end.
  if last-event :label = "end" then do:
    assign
      v-pos-ind = v-length + 1
    .
  end.
  if last-event :label = "cursor-left"
  then do:
    if v-pos-ind > 1
    then do:
      assign
        v-pos-ind = v-pos-ind - 1
      .
    end.
  end.
  if last-event :label = "cursor-right"
  then do:
    if v-pos-ind < length(f-value) + 1
    then do:
      assign
        v-pos-ind = v-pos-ind + 1
      .
    end.
  end.
  assign
    v-pos = fill(" ", v-pos-ind - 1) + "|"
    .
  display f-value v-pos with frame {&frame-name} .

end.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN MYenable.
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
  DISPLAY f-value v-pos EDITOR-1 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-value v-pos EDITOR-1 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
v-pos-ind = Length(p-field)  + 1
f-value = p-field
f-value:BGCOLOR IN FRAME {&FRAME-NAME} = white_color
v-pos = fill(" ", v-pos-ind - 1) + "|"
frame {&frame-name}:title  = p-title
f-value:label = p-label
f-value:format = "X(" + string(p-length) + ")"
editor-1:SCREEN-VALUE = SUBSTITUTE("Для ввода &1 следует использовать клавиши &2, ", p-label, p-validchars) +
          "для редактирования следует использовать клавиши BACK-SPACE, DELETE, HOME, END, ->, <-"
.
DISPLAY f-value v-pos
      WITH FRAME Dialog-Frame.

  ENABLE B-exit b-quit B-Help v-pos
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

