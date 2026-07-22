&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
&ANALYZE-RESUME
/* Connected Databases 
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



using ibs.th.str.alcohol.*.

{ str/inv-marks-tt.i }
{ibs/th/skt/ControlledClients/TSDTT.i}

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-trn-code as character no-undo.
define input parameter p-recid as recid no-undo.

define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_parts for ub.parts.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds for ub.goods.
/* Local Variable Definitions ---                                       */


{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable excMarks as class excisemarks no-undo.
define new shared variable g#auto-user-id as character no-undo .
define new shared variable g#LogStr       as character no-undo .

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-alc-qnty

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 tt-alc-qnty.exciseMark tt-alc-qnty.partId   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2   
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = false
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = false.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt-alc-qnty
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt-alc-qnty


/* Definitions for BROWSE BROWSE-5                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-5 tt-alc-qnty.exciseMark tt-alc-qnty.partId   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-5   
&Scoped-define SELF-NAME BROWSE-5
&Scoped-define QUERY-STRING-BROWSE-5 FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = true
&Scoped-define OPEN-QUERY-BROWSE-5 OPEN QUERY {&SELF-NAME} FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = true.
&Scoped-define TABLES-IN-QUERY-BROWSE-5 tt-alc-qnty
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-5 tt-alc-qnty


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}~
    ~{&OPEN-QUERY-BROWSE-5}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK btn_accept btn_imp BROWSE-2 BROWSE-5 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON btn_accept 
     LABEL "Сохр." 
     SIZE 6 BY 1.

DEFINE BUTTON btn_imp 
     LABEL "Импорт" 
     SIZE 7 BY 1.

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Выход" 
     SIZE 6 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
      tt-alc-qnty SCROLLING.

DEFINE QUERY BROWSE-5 FOR 
      tt-alc-qnty SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 DISPLAY
  tt-alc-qnty.artic
  tt-alc-qnty.alc-code
  tt-alc-qnty.qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 53 BY 23.5
         TITLE "Импортировано" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-5 Dialog-Frame _FREEFORM
  QUERY BROWSE-5 DISPLAY
  tt-alc-qnty.artic
  tt-alc-qnty.alc-code
  tt-alc-qnty.qnty 
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 53 BY 23.5
         TITLE "Текущее состояние" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.08 COL 1.25
     btn_accept AT ROW 1.08 COL 7.25 WIDGET-ID 2
     btn_imp AT ROW 1.08 COL 13.5 WIDGET-ID 4
     BROWSE-2 AT ROW 2.25 COL 1.5 WIDGET-ID 200
     BROWSE-5 AT ROW 2.25 COL 55.5 WIDGET-ID 300
     SPACE(0.49) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Марки по партии."
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.


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
/* BROWSE-TAB BROWSE-2 btn_imp Dialog-Frame */
/* BROWSE-TAB BROWSE-5 BROWSE-2 Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = false.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-5
/* Query rebuild information for BROWSE BROWSE-5
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = true.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-5 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Марки по партии. */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_accept
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_accept Dialog-Frame
ON CHOOSE OF btn_accept IN FRAME Dialog-Frame /* Ввод */
DO:

  define variable v-ok-doc as integer no-undo.
  define variable isClear  as logical no-undo.
  
  
  
  find first buf_trn-doc where buf_trn-doc.doc-code = p-trn-code no-lock.
  create TempTrnDoc.
  assign
    TempTrnDoc.doc-date = buf_trn-doc.doc-date 
    TempTrnDoc.ext-doc-type = buf_trn-doc.ext-doc-type
    TempTrnDoc.ext-doc-code = buf_trn-doc.doc-code  
    TempTrnDoc.cli-type = "" 
    TempTrnDoc.cli-code = -2
    TempTrnDoc.obj-type = buf_trn-doc.obj-type
    TempTrnDoc.obj-code = buf_trn-doc.obj-code
    TempTrnDoc.ps = string (isClear)
  .
  
  for each buf_doc-line no-lock where buf_doc-line.doc-code = p-trn-code:
    
    find first buf_gds no-lock where buf_gds.artic = buf_doc-line.artic
      and buf_gds.prod-type = buf_doc-line.prod-type
      and buf_gds.prod-code = buf_doc-line.prod-code
    . 
    create TempDocLine.
      
    assign
      TempDocLine.line-num  = buf_doc-line.line-num
      TempDocLine.gds-code  = buf_gds.gds-code
      TempDocLine.fact-qnty = buf_doc-line.fact-qnty
      .
      
  end.
  
  run ibs/th/skt/Adapters/AdapteeProcOra-i506.p
    (
      table TempTrnDoc,
      table TempDocLine,
      table tt-marks,
      v-cntxt-userid
    ) no-error.
  if error-status:error
  then do:
    message "Ошикба: " return-value view-as alert-box error.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_imp Dialog-Frame
ON CHOOSE OF btn_imp IN FRAME Dialog-Frame /* Импорт */
DO:

  run str/imp-marks-temp.p (output table tt-marks, output table tt-alc-qnty, p-trn-code).
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
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

  excMarks = new excisemarks (v-cntxt-obj-type, v-cntxt-obj-code).
  
  if p-recid = ?
  then do:
    for each buf_doc-line where buf_doc-line.doc-code = p-trn-code:
      for each buf_parts no-lock where
        buf_parts.obj-type = buf_doc-line.obj-type and 
        buf_parts.obj-code = buf_doc-line.obj-code and 
        buf_parts.artic = buf_doc-line.artic and
        buf_parts.prod-type = buf_doc-line.prod-type and
        buf_parts.prod-code = buf_doc-line.prod-code and
        buf_parts.out-code = buf_doc-line.doc-code:
          
        excMarks:GetTableMarksForPartsAppend(buffer buf_parts, input-output table tt-marks).
      end.
    end.
  end.
  

  RUN enable_UI.
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
  ENABLE Btn_OK btn_accept btn_imp BROWSE-2 BROWSE-5 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

