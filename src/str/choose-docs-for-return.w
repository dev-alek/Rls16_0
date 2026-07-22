&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-reason as integer no-undo .
define input parameter p-is-edo as logical no-undo .
define input parameter in-doc-code as character no-undo .
define output parameter p-doc-code as character no-undo .
/* Local Variable Definitions ---                                       */

define temp-table tt-trn-doc no-undo like ub.trn-doc .
define buffer buf_trn-doc for tt-trn-doc .
define buffer in_trn-doc for ub.trn-doc .
define buffer chs_trn-doc for ub.trn-doc .
define buffer buf_utd for ub.utd .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_trn-doc

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs buf_trn-doc.status_ buf_trn-doc.flag_ ~
buf_trn-doc.doc-code buf_trn-doc.doc-date buf_trn-doc.fact-date buf_trn-doc.shift-date ~
buf_trn-doc.shift-name buf_trn-doc.cli-name buf_trn-doc.doc-qnty buf_trn-doc.fact-qnty ~
buf_trn-doc.tot-doc buf_trn-doc.tot-fact 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs 
&Scoped-define QUERY-STRING-br-docs FOR EACH buf_trn-doc NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-docs OPEN QUERY br-docs FOR EACH buf_trn-doc no-lock by buf_trn-doc.fact-date desc INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-docs buf_trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs buf_trn-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel Btn_OK br-docs 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Выбор" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-docs FOR 
      buf_trn-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs Dialog-Frame _STRUCTURED
  QUERY br-docs NO-LOCK DISPLAY
      buf_trn-doc.status_ FORMAT "X(8)":U WIDTH 8.2
      buf_trn-doc.flag_ FORMAT "+/-":U
      buf_trn-doc.doc-code FORMAT "X(14)":U
      buf_trn-doc.doc-date FORMAT "99/99/99":U
      buf_trn-doc.fact-date FORMAT "99/99/99":U
      buf_trn-doc.shift-date FORMAT "99/99/99":U
      buf_trn-doc.shift-name FORMAT "X(2)":U
      buf_trn-doc.cli-name FORMAT "X(40)":U
      buf_trn-doc.doc-qnty FORMAT "->>,>>>,>>9.<<<":U
      buf_trn-doc.fact-qnty FORMAT "->>,>>>,>>9.<<<":U
      buf_trn-doc.tot-doc FORMAT "->>>,>>>,>>9.99":U
      buf_trn-doc.tot-fact FORMAT "->>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 14.05 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1.24 COL 2
     Btn_OK AT ROW 1.24 COL 17
     br-docs AT ROW 2.91 COL 3 WIDGET-ID 200
     SPACE(2.19) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выберите документ-источник"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-docs Btn_OK Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _TblList          = "ub.buf_trn-doc"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > ub.buf_trn-doc.status_
"status_" ? ? "character" ? ? ? ? ? ? no ? no no "8.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.buf_trn-doc.flag_
"flag_" ? "+/-" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = ub.buf_trn-doc.doc-code
     _FldNameList[4]   = ub.buf_trn-doc.doc-date
     _FldNameList[5]   = ub.buf_trn-doc.fact-date
     _FldNameList[6]   = ub.buf_trn-doc.shift-date
     _FldNameList[7]   = ub.buf_trn-doc.shift-name
     _FldNameList[8]   = ub.buf_trn-doc.cli-name
     _FldNameList[9]   = ub.buf_trn-doc.doc-qnty
     _FldNameList[10]   = ub.buf_trn-doc.fact-qnty
     _FldNameList[11]   = ub.buf_trn-doc.tot-doc
     _FldNameList[12]   = ub.buf_trn-doc.tot-fact
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выберите документ-источник */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выбор */
DO:
  if not available buf_trn-doc
  then return no-apply .
  
  p-doc-code = buf_trn-doc.doc-code .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-docs
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run fill-tt .   
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure fill-tt :
  empty temp-table tt-trn-doc .
  find first in_trn-doc no-lock where in_trn-doc.doc-code = in-doc-code .
  for each chs_trn-doc no-lock where chs_trn-doc.cli-type = in_trn-doc.cli-type
                                 and chs_trn-doc.cli-code = in_trn-doc.cli-code
                                 and chs_trn-doc.host-code = in_trn-doc.host-code
                                 and chs_trn-doc.ext-doc-type = "ie"
                                 and chs_trn-doc.contract-code = in_trn-doc.contract-code
                                 and chs_trn-doc.status_ = "факт"
                                 :
    if p-is-edo
    then do :
      if p-reason = 23 /* Обратная продажа */
      then do :
        create tt-trn-doc.
        buffer-copy chs_trn-doc to tt-trn-doc .
      end .
      if p-reason = 25 /* Корректировка поступления */
      then do :
        if can-find(first buf_utd no-lock where buf_utd.doc-code = chs_trn-doc.doc-code)
        then do :
          create tt-trn-doc.
          buffer-copy chs_trn-doc to tt-trn-doc .
        end .
      end .
    end .
    else do :
      if not can-find(first buf_utd no-lock where buf_utd.doc-code = chs_trn-doc.doc-code)
      then do :
        create tt-trn-doc.
        buffer-copy chs_trn-doc to tt-trn-doc .
      end .
    end .                               
  end .
end procedure .

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
  ENABLE Btn_Cancel Btn_OK br-docs 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

