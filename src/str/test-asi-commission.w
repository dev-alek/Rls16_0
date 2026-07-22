&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
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

define temp-table tt-commission no-undo
  field ii as integer
  field comp as character
  field FIO  as character
  field position_ as character
  index pi as primary unique
    ii
.

/* Parameters Definitions ---                                           */
define input parameter p-rvs-code as character no-undo .
define input parameter p-mode as character no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Состав комиссии (проверка корректности работы АСИ)":U.

{ cmp/vssrevis.i      }
{ cmp/showinf.i       }
{ cmp/str-glbl.i      }

define variable ii as integer no-undo .

define buffer buf_rvs-doc-attr for ub.rvs-doc-attr .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

&Scoped-define WIDGETID-FILE-NAME 

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-chg 

/* Definitions for BROWSE br-comm                                     */
&Scoped-define SELF-NAME br-comm
&Scoped-define QUERY-STRING-br-comm FOR EACH tt-commission
&Scoped-define OPEN-QUERY-br-comm OPEN QUERY {&SELF-NAME} FOR EACH tt-commission .
&Scoped-define TABLES-IN-QUERY-br-comm tt-commission
&Scoped-define FIRST-TABLE-IN-QUERY-br-comm tt-commission

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-comm}
    
/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg 
     LABEL "Изменить" 
     SIZE 15 BY 1.14.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "Выход" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

define query br-comm for tt-commission scrolling .
define browse br-comm query br-comm no-lock
display
  tt-commission.comp column-label "Состав комиссии" format "X(22)"
  tt-commission.FIO  column-label "ФИО" format "X(256)" width 30
  tt-commission.position_ column-label "Должность" format "X(256)" width 25
with size 80.25 by 6 separators.
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1.5 COL 2
     b-chg AT ROW 1.5 COL 26 WIDGET-ID 2
     br-comm AT ROW 2.7 COL 2 WIDGET-ID 2
     SPACE(2) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Состав комиссии"
         DEFAULT-BUTTON B-exit WIDGET-ID 100.


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
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-FIO as character no-undo .
  define variable v-position as character no-undo .
  if available tt-commission
  then do :
    assign
      v-FIO = tt-commission.FIO
      v-position = tt-commission.position_
    .
    run str/test-asi-commission-chg.w (input-output v-FIO,
                                       input-output v-position)
                                       .
    assign
      tt-commission.FIO = v-FIO
      tt-commission.position_ = v-position 
    .
  end .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
DO:
  for each tt-commission :
    if trim(tt-commission.FIO) > ""
    or trim(tt-commission.position_) > ""
    then do :
      find first buf_rvs-doc-attr exclusive-lock where buf_rvs-doc-attr.rvs-code = p-rvs-code
                                                   and buf_rvs-doc-attr.attr-code = ("test-asi-commission-" + string(tt-commission.ii))
                                                   no-error .
      if not available buf_rvs-doc-attr
      then do :
        create buf_rvs-doc-attr .
        assign
          buf_rvs-doc-attr.rvs-code = p-rvs-code
          buf_rvs-doc-attr.attr-code = ("test-asi-commission-" + string(tt-commission.ii))
        .
      end .
      assign buf_rvs-doc-attr.attr-value = tt-commission.FIO + {&delim-par} + tt-commission.position_ .
    end .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



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
  do ii = 1 to 5 :
    create tt-commission .
    assign
      tt-commission.ii = ii
      tt-commission.comp = (if ii = 1 then "Председатель комиссии" else "Участник комиссии")
    .
    find first buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = p-rvs-code
                                          and buf_rvs-doc-attr.attr-code = ("test-asi-commission-" + string(ii))
                                          no-error .
    if available buf_rvs-doc-attr
    and num-entries(buf_rvs-doc-attr.attr-value, {&delim-par}) = 2
    then do :
      assign
        tt-commission.FIO = entry(1, buf_rvs-doc-attr.attr-value, {&delim-par})
        tt-commission.position_ = entry(2, buf_rvs-doc-attr.attr-value, {&delim-par})
      .
    end .
  end .
  
  RUN enable_UI.
  if p-mode = {&lookup}
  then do :
    disable b-chg with FRAME {&FRAME-NAME}.
  end .
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
  ENABLE B-exit b-chg br-comm
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

