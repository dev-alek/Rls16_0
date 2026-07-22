&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Нормы естественной убыли

Автор: Шкляр Елена
Дата создания: 08/29/03
Author: Shklyar Elena
Creation date: 08/29/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-gds-code like ub.goods.gds-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input-output parameter p-value as character no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Нормы естественной убыли".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-Help f-norm-summer ~
f-norm-winter f-norm-summer-2 f-norm-winter-2 
&Scoped-Define DISPLAYED-OBJECTS f-norm-summer f-norm-winter ~
f-norm-summer-2 f-norm-winter-2 

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

DEFINE VARIABLE f-norm-summer AS DECIMAL FORMAT "->>,>>9.999" INITIAL 0 
     LABEL "Норма убыли для лета" 
     VIEW-AS FILL-IN 
     SIZE 10.63 BY 1.

DEFINE VARIABLE f-norm-summer-2 AS DECIMAL FORMAT "->>,>>9.999" INITIAL 0 
     LABEL "Норма убыли для лета" 
     VIEW-AS FILL-IN 
     SIZE 10.63 BY 1.

DEFINE VARIABLE f-norm-winter AS DECIMAL FORMAT "->>,>>9.999" INITIAL 0 
     LABEL "Норма убыли для зимы" 
     VIEW-AS FILL-IN 
     SIZE 10.63 BY 1.

DEFINE VARIABLE f-norm-winter-2 AS DECIMAL FORMAT "->>,>>9.999" INITIAL 0 
     LABEL "Норма убыли для зимы" 
     VIEW-AS FILL-IN 
     SIZE 10.63 BY 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-norm-summer AT ROW 3.04 COL 51.38 RIGHT-ALIGNED
     f-norm-winter AT ROW 4.21 COL 51.38 RIGHT-ALIGNED
     f-norm-summer-2 AT ROW 6.58 COL 51.38 RIGHT-ALIGNED WIDGET-ID 2
     f-norm-winter-2 AT ROW 7.75 COL 51.38 RIGHT-ALIGNED WIDGET-ID 4
     "Транспортировка:" VIEW-AS TEXT
          SIZE 16.5 BY 1 AT ROW 3.04 COL 1.75 WIDGET-ID 6
     "Хранение:" VIEW-AS TEXT
          SIZE 9.5 BY 1 AT ROW 6.58 COL 17.25 RIGHT-ALIGNED WIDGET-ID 8
     "в месяц" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 6.58 COL 53 WIDGET-ID 10
     "в месяц" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 7.75 COL 53 WIDGET-ID 12
     SPACE(5.12) SKIP(0.78)
    WITH VIEW-AS DIALOG-BOX 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Норма естественной убыли"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub goods
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

/* SETTINGS FOR FILL-IN f-norm-summer IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-norm-summer-2 IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-norm-winter IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-norm-winter-2 IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR TEXT-LITERAL "Хранение:"
          SIZE 9.5 BY 1 AT ROW 6.58 COL 17.25 RIGHT-ALIGNED             */

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Норма естественной убыли */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
   { gbl/stdbtn.i }
  assign
     f-norm-summer 
     f-norm-winter
     f-norm-summer-2 
     f-norm-winter-2
  .   
  run proc-go in this-procedure (f-norm-summer, f-norm-winter, f-norm-summer-2, f-norm-winter-2) no-error.
  if error-status:error then return no-apply.

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
  find first buf_goods no-lock where
                 buf_goods.gds-code = p-gds-code no-error.
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
  DISPLAY f-norm-summer f-norm-winter f-norm-summer-2 f-norm-winter-2 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help f-norm-summer f-norm-winter f-norm-summer-2 
         f-norm-winter-2 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyeNABLe Dialog-Frame 
PROCEDURE MyeNABLe :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF AVAILABLE buf_goods then do:
assign
frame {&frame-name}:title = frame {&frame-name}:title + substitute(" код товара &1", p-gds-code).
end.
  assign
  f-norm-summer = decimal(entry(1, p-value, ";":U ))
  f-norm-winter = decimal(entry(2, p-value, ";":U ))
  f-norm-summer-2 = decimal(entry(3, p-value, ";":U ))
  f-norm-winter-2 = decimal(entry(4, p-value, ";":U ))
  no-error .
  DISPLAY f-norm-summer f-norm-winter f-norm-summer-2 f-norm-winter-2
      WITH FRAME {&FRAME-NAME}.
  ENABLE b-quit B-exit B-Help f-norm-summer f-norm-winter f-norm-summer-2 f-norm-winter-2
      WITH FRAME {&FRAME-NAME}.
  VIEW FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-go Dialog-Frame 
PROCEDURE proc-go :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter v-norm-summer as decimal no-undo.
define input parameter v-norm-winter as decimal no-undo.
define input parameter v-norm-summer-2 as decimal no-undo.
define input parameter v-norm-winter-2 as decimal no-undo.
assign
p-value = string(v-norm-summer, "->>>>9.999") + ";" + string(v-norm-winter, "->>>>9.999") + ";" + string(v-norm-summer-2, "->>>>9.999") + ";" + string(v-norm-winter-2, "->>>>9.999")
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

