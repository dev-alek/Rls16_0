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

def input param         parparentproc   as Widget-handle no-undo .
def input param         p-cd-doc-recid    as recid    no-undo.
def output param        p-ret-stat        as logical  no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Добавление в Путевой лист факта заправки. Документы->Путевые листы".

{ str/travel-sheets-inc.i }
{ str/travel-sheets-inc2.i }
{ cmp/vssrevis.i }
{ cmp/showinf.i }

p-ret-stat = false.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel volume rfn chk ~
BUTTON-sel-chk
&Scoped-Define DISPLAYED-OBJECTS volume rfn chk

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-sel-chk
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE chk AS CHARACTER FORMAT "X(256)":U
     LABEL "Чек"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE rfn AS CHARACTER FORMAT "X(256)":U
     LABEL "RFN"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE volume AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Объем"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 2
     Btn_Cancel AT ROW 1 COL 12
     volume AT ROW 2.91 COL 9 COLON-ALIGNED WIDGET-ID 2
     rfn AT ROW 4.33 COL 9 COLON-ALIGNED WIDGET-ID 8
     chk AT ROW 5.76 COL 9 COLON-ALIGNED WIDGET-ID 4
     BUTTON-sel-chk AT ROW 5.76 COL 32 WIDGET-ID 6
     SPACE(3.19) SKIP(0.94)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод заправки"
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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       chk:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ввод заправки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
    def var rid as recid no-undo.

    assign frame {&frame-name}
        volume
        rfn
        chk
    .

    run create-travel-sheet-line(
              p-cd-doc-recid
            , volume
            , chk
            , rfn
            , true /* фактич. осущ. налив */
            , output rid
    ) no-error.

    if error-status:ERROR then do:
        message return-value view-as alert-box.
        return no-apply.
    end.
    else
        p-ret-stat = true.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-sel-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-sel-chk Dialog-Frame
ON CHOOSE OF BUTTON-sel-chk IN FRAME Dialog-Frame
DO:
    def var rid-list as char no-undo.

    run str/chk-docs.w (
                 input parparentproc
                ,input "b-sel":U
                ,input {&g___object} /*par-mode*/
                ,input ?
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input ? /*parout-code*/
                ,input "":U /*pard-card*/
                ,input 0 /*p-pay-desk*/
                ,input ?
                ,input ?
                ,input 0
                ,output rid-list
                ).
    if num-entries(rid-list) = 0 then return.

    find first ub.chk-doc no-lock
        where recid(ub.chk-doc) = integer(rid-list).

    chk = ub.chk-doc.doc-code.
    disp chk with frame {&frame-name}.
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
  run my-init no-error.
  if error-status:ERROR then do:
      message return-value view-as alert-box.
      return.
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS volume.
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
  DISPLAY volume rfn chk
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel volume rfn chk BUTTON-sel-chk
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-init Dialog-Frame
PROCEDURE my-init :
find first ub.cd-doc no-lock
        where recid(ub.cd-doc) = p-cd-doc-recid
        no-error.
    if not avail ub.cd-doc then return error "Не удалось найти cd-doc с recid = " + string(p-cd-doc-recid).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
