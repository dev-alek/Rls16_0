&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r10 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME    DIALOG-1
&Scoped-define FRAME-NAME     DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование границ в фильтре

Автор: Хныкин Павел Андреевич
Дата создания: 06/10/95
Author: Pavel Khnykin
Creation date: 06/10/95

no_app_help.i
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def input param type as char no-undo.
def output param down_ as char no-undo.
def output param up_ as char no-undo.
def output param incl as logical no-undo.

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Редактирование границ в фильтре".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/cur-time.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/* ********************  Preprocessor Definitions  ******************** */

/* Name of first Frame and/or Browse (alphabetically)                   */
&Scoped-define FRAME-NAME  DIALOG-1

/* Custom List Definitions                                              */
&Scoped-define LIST-1
&Scoped-define LIST-2
&Scoped-define LIST-3

/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define FIELDS-IN-QUERY-DIALOG-1

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена":L
     SIZE 7 BY 1.17
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохр.":L
     SIZE 7 BY 1.17
     BGCOLOR 8 .

DEFINE VARIABLE in-char AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-char-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE in-date-2 AS DATE FORMAT "99/99/9999":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE in-dec AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-dec-2 AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-int AS INTEGER FORMAT "->>,>>>,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-int-2 AS INTEGER FORMAT "->>,>>>,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE togl AS LOGICAL INITIAL no
     LABEL "Включительно":L
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     in-dec AT ROW 2 COL 2.5 NO-LABEL
     in-date AT ROW 2 COL 2.5 NO-LABEL
     in-char AT ROW 2 COL 2.5 NO-LABEL
     in-int AT ROW 2 COL 2.5 NO-LABEL
     in-date-2 AT ROW 4.25 COL 2.5 NO-LABEL
     in-char-2 AT ROW 4.25 COL 2.5 NO-LABEL
     in-dec-2 AT ROW 4.25 COL 2.5 NO-LABEL
     in-int-2 AT ROW 4.25 COL 2.5 NO-LABEL
     togl AT ROW 5.5 COL 2.5
     Btn_OK AT ROW 6.5 COL 2.5
     Btn_Cancel AT ROW 6.5 COL 11
     "Введите нижнюю границу :" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 1.25 COL 2.5
     "Введите верхнюю границу :" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 3.5 COL 2.5
     SPACE(8.51) SKIP(3.76)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.




/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
  VISIBLE,L                                                             */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN in-char IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-char-2 IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-date IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-date-2 IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-dec IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-dec-2 IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-int IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-int-2 IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, return error
   ON END-KEY UNDO MAIN-BLOCK, return error:
  RUN UI_on.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  incl = input frame {&frame-name} togl.
  case type:
     when "character" then
        assign
          down_ = input frame {&frame-name} in-char
          up_ = input in-char-2.
     when "date" then
        assign
          down_ = string(input frame {&frame-name} in-date)
          up_ = string(input in-date-2).
     when "decimal" then
        assign
          down_ = string(input frame {&frame-name} in-dec)
          up_ = string(input in-dec-2).
     when "integer" then
       assign
          down_ = string(input frame {&frame-name} in-int)
          up_ = string(input in-int-2).
  end case.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1 _DEFAULT-DISABLE
PROCEDURE disable_UI :
/* --------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
   -------------------------------------------------------------------- */
  /* Hide all frames. */
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1 _DEFAULT-ENABLE
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
  DISPLAY
        in-int in-dec in-date in-char in-date-2 in-int-2 in-char-2 in-dec-2 togl
      WITH FRAME DIALOG-1.
  ENABLE
        in-int in-dec in-date in-char in-date-2 in-int-2 in-char-2 in-dec-2 togl Btn_OK Btn_Cancel
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI_on DIALOG-1
PROCEDURE UI_on :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

  case type:
          when "character" then do:
               frame {&frame-name}:title = "Введите символьные значения".
               disp in-char in-char-2 togl with frame {&frame-name}.
               enable in-char  in-char-2 togl Btn_OK Btn_Cancel with frame {&frame-name}.
               in-date:visible = no.
               in-dec:visible = no.
               in-int:visible = no.
               in-date-2:visible = no.
               in-dec-2:visible = no.
               in-int-2:visible = no.
          end.
          when "date" then do:
               frame {&frame-name}:title = "Введите даты".
               run cur-time in this-procedure (output v-today, output v-time).
               in-date = v-today. in-date-2 = v-today.
               disp in-date in-date-2 togl with frame {&frame-name}.
               enable in-date in-date-2 togl Btn_OK Btn_Cancel with frame {&frame-name}.
               in-char:visible = no.
               in-dec:visible = no.
               in-int:visible = no.
               in-char-2:visible = no.
               in-dec-2:visible = no.
               in-int-2:visible = no.
          end.
          when "decimal" then do:
               frame {&frame-name}:title = "Введите десятичные значения".
               disp in-dec in-dec-2 togl with frame {&frame-name}.
               enable in-dec in-dec-2 togl Btn_OK Btn_Cancel with frame {&frame-name}.
               in-date:visible = no.
               in-char:visible = no.
               in-int:visible = no.
               in-date-2:visible = no.
               in-char-2:visible = no.
               in-int-2:visible = no.
          end.
          when "integer" then do:
               frame {&frame-name}:title = "Введите целые значения".
               disp in-int in-int-2 togl with frame {&frame-name}.
               enable in-int in-int-2 togl Btn_OK Btn_Cancel with frame {&frame-name}.
               in-date:visible = no.
               in-dec:visible = no.
               in-char:visible = no.
               in-date-2:visible = no.
               in-dec-2:visible = no.
               in-char-2:visible = no.
          end.
  end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME
