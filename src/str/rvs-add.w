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

Добавление документа сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define  input parameter parparentproc as handle    no-undo.
define  input parameter pardoc-mode   as character no-undo.
define output parameter parrvs-rec    as recid     no-undo.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Добавление документа сверки":U.

/* Common Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */
define variable varlog     as logical   no-undo.
define variable was_found  as logical   no-undo initial no.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-ok RECT-1 r-type
&Scoped-Define DISPLAYED-OBJECTS r-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-ok AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .


DEFINE VARIABLE r-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
     {&rvs-control}, 1,
     {&rvs-shift}, 2
     SIZE 30.88 BY 3 NO-UNDO.
DEFINE VARIABLE varall-place AS LOGICAL LABEL "полный"
     VIEW-AS TOGGLE-BOX SIZE 10 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.38 BY 4.04.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-cancel     AT ROW 1.5  COL 11.88
     b-ok         AT ROW 1.5  COL 1.88
     b-help       at row 1.5  col 21.88
     r-type       AT ROW 4.38 COL 2.63 NO-LABEL
     varall-place AT ROW 4.6 COL 15.63
     RECT-1       AT ROW 3.88 COL 1.38
     SPACE(0.48) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тип документа сверки"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тип документа сверки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
ON VALUE-CHANGED OF r-type IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} r-type = 1 then do:
     enable varall-place with frame {&frame-name}.
     display varall-place with frame {&frame-name}.
  end.
  else do:
    hide varall-place in frame {&frame-name}.
  end.
END.

&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok Dialog-Frame
ON CHOOSE OF b-ok IN FRAME Dialog-Frame /* Ввод */
DO:
  assign frame {&frame-name} r-type
                             varall-place.
  if r-type = 1 then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_rvs-control_cr-revision':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      varlog
    }
     if varlog <> yes then do:
        apply "go" to frame {&frame-name}.
        return no-apply.
     end.
     run str/rvs-doc.w
       ( input        parparentproc
        ,input        pardoc-mode
        ,input        {&rvs-control}
        ,input        varall-place
        ,input-output parrvs-rec
       ) no-error.
     if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         "Ошибка при создании документа сверки." skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
       return no-apply.
     end.
  end.
  else do:
     { str/rvschtrn.i
         v-cntxt-obj-type
         v-cntxt-obj-code
         ?
         ?
         ?
         no
         no
         was_found
         no-error
     }
     if error-status :error then do:
       message "Ошибка поиска незакрытых документов (rvschtrn)." skip return-value view-as alert-box error.
      return no-apply.
    end.
    if was_found = yes then do:
      message
        "Невозможно создать сверку." skip
        return-value
        view-as alert-box error.
      return no-apply.
    end.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_rvs-shift_cr-revision':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      varlog
    }
     if varlog <> yes then do:
        apply "go" to frame {&frame-name}.
        return no-apply.
     end.
     run str/rvs-doc.w
       ( input        parparentproc
        ,input        pardoc-mode
        ,input        {&rvs-shift}
        ,input        varall-place
        ,input-output parrvs-rec
       ) no-error.
     if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         "Ошибка при создании документа сверки." skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
       return no-apply.
     end.
  end.
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
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  RUN enable_UI IN THIS-PROCEDURE.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  ASSIGN  r-type       = 1
          varall-place = yes.
  DISPLAY r-type varall-place
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-ok RECT-1 r-type varall-place b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME