&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-pay-type


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt_pay-type NO-UNDO LIKE ub.pay-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-pay-type
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма редактирования вида оплаты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

Created: 20/04/95 -  7:11 pm

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parparentproc as widget-handle no-undo .
define input        parameter ref-mode      as character     no-undo .
define input-output parameter rid           as recid         no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма редактирования вида оплаты".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }


/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-pay-type

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_pay-type

/* Definitions for DIALOG-BOX d-pay-type                                */
&Scoped-define FIELDS-IN-QUERY-d-pay-type tt_pay-type.obj-code ~
tt_pay-type.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-d-pay-type tt_pay-type.obj-code ~
tt_pay-type.obj-name
&Scoped-define ENABLED-TABLES-IN-QUERY-d-pay-type tt_pay-type
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-d-pay-type tt_pay-type
&Scoped-define QUERY-STRING-d-pay-type FOR EACH tt_pay-type SHARE-LOCK
&Scoped-define OPEN-QUERY-d-pay-type OPEN QUERY d-pay-type FOR EACH tt_pay-type SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-pay-type tt_pay-type
&Scoped-define FIRST-TABLE-IN-QUERY-d-pay-type tt_pay-type


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_pay-type.obj-code tt_pay-type.obj-name
&Scoped-define ENABLED-TABLES tt_pay-type
&Scoped-define FIRST-ENABLED-TABLE tt_pay-type
&Scoped-Define ENABLED-OBJECTS b-OK b-cancel B-hist B-help
&Scoped-Define DISPLAYED-FIELDS tt_pay-type.obj-code tt_pay-type.obj-name
&Scoped-define DISPLAYED-TABLES tt_pay-type
&Scoped-define FIRST-DISPLAYED-TABLE tt_pay-type


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY d-pay-type FOR
      tt_pay-type SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-pay-type
     b-OK AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     B-hist AT ROW 1 COL 31
     B-help AT ROW 1 COL 51
     tt_pay-type.obj-code AT ROW 2.5 COL 8.5 COLON-ALIGNED
          LABEL "&Код"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt_pay-type.obj-name AT ROW 3.75 COL 8.5 COLON-ALIGNED
          LABEL "О&плата"
          VIEW-AS FILL-IN
          SIZE 41 BY 1
     SPACE(11.12) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "О П Л А Т А".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Temp-Tables and Buffers:
      TABLE: tt_pay-type T "?" NO-UNDO ub pay-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-pay-type
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-pay-type:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN tt_pay-type.obj-code IN FRAME d-pay-type
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt_pay-type.obj-name IN FRAME d-pay-type
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-pay-type
/* Query rebuild information for DIALOG-BOX d-pay-type
     _TblList          = "Temp-Tables.tt_pay-type"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX d-pay-type */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist d-pay-type
ON CHOOSE OF B-hist IN FRAME d-pay-type /* История */
DO:
    define variable v-rid-list as character no-undo .
        run ref/cpaytyps.w (
                     INPUT parparentproc
                    ,INPUT '':U /*bttns*/
                    ,INPUT 'one':U
                    ,INPUT tt_pay-type.obj-code
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK d-pay-type
ON CHOOSE OF b-OK IN FRAME d-pay-type /* Ввод  */
DO:

  assign
    tt_pay-type.obj-code
    tt_pay-type.obj-name
    .

   run ref/paytype1.p
     ( input-output rid
     , input ref-mode
     , input no /* p-silent */
     , input tt_pay-type.obj-code
     , input tt_pay-type.obj-name
     ) no-error.
  if error-status:error then do:
    if return-value = "":U then do:
      return no-apply.
    end.
    case return-value:
      when "obj-code":U then do:
        APPLY "ENTRY" to tt_pay-type.obj-code .
      end.
      when "obj-name":U then do:
        APPLY "ENTRY" to tt_pay-type.obj-name .
      end.
    end.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-pay-type


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY  UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON STOP     UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define buffer buf_pay-type for ub.pay-type .

  create tt_pay-type.

  if ref-mode = {&add-def} then  do:
    assign
      rid = ?
    .
    find last buf_pay-type no-lock
      use-index pi
      no-error .
    if available buf_pay-type then do:
      assign
        tt_pay-type.obj-code = buf_pay-type.obj-code + 1
      .
    end.
    else do:
      assign
        tt_pay-type.obj-code = 1
      .
    end.
  end.
  else do:
    find first buf_pay-type exclusive-lock
      where recid( buf_pay-type ) = rid
      .
    buffer-copy buf_pay-type to tt_pay-type .
  end.

  session:data-entry-return = yes .
  RUN enable_UI.

  if ref-mode = {&add-def} then do:
    WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt_pay-type.obj-code .
  end.
  else do:
    WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt_pay-type.obj-name .
  end.

END.
RUN disable_UI.
session:data-entry-return = no .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-pay-type  _DEFAULT-DISABLE
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
  HIDE FRAME d-pay-type.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-pay-type
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
      tt_pay-type.obj-code
      tt_pay-type.obj-name
      WITH FRAME d-pay-type.
  ENABLE
      b-OK
      b-cancel
      b-hist               WHEN ref-mode <> {&add-def}
      tt_pay-type.obj-code WHEN ref-mode = {&add-def}
      tt_pay-type.obj-name
      WITH FRAME d-pay-type.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME