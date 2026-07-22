&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME trn-rsna


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt_trn-reason NO-UNDO LIKE ub.trn-reason.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS trn-rsna
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка основания (причины) создания документа

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter parParentProc as widget-handle no-undo.
define input        parameter p-mode        as character     no-undo.
define input-output parameter p-rid         as recid         no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Карточка основания (причины) создания документа":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME trn-rsna

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_trn-reason

/* Definitions for DIALOG-BOX trn-rsna                                  */
&Scoped-define FIELDS-IN-QUERY-trn-rsna tt_trn-reason.reason-code ~
tt_trn-reason.reason-name tt_trn-reason.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-trn-rsna tt_trn-reason.reason-name ~
tt_trn-reason.PS
&Scoped-define ENABLED-TABLES-IN-QUERY-trn-rsna tt_trn-reason
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-trn-rsna tt_trn-reason
&Scoped-define QUERY-STRING-trn-rsna FOR EACH tt_trn-reason SHARE-LOCK
&Scoped-define OPEN-QUERY-trn-rsna OPEN QUERY trn-rsna FOR EACH tt_trn-reason SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-trn-rsna tt_trn-reason
&Scoped-define FIRST-TABLE-IN-QUERY-trn-rsna tt_trn-reason


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_trn-reason.reason-name tt_trn-reason.PS
&Scoped-define ENABLED-TABLES tt_trn-reason
&Scoped-define FIRST-ENABLED-TABLE tt_trn-reason
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-history b-help
&Scoped-Define DISPLAYED-FIELDS tt_trn-reason.reason-code ~
tt_trn-reason.reason-name tt_trn-reason.PS
&Scoped-define DISPLAYED-TABLES tt_trn-reason
&Scoped-define FIRST-DISPLAYED-TABLE tt_trn-reason


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-attr DEFAULT
     LABEL "&Атрибуты"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "&Ввод "
     SIZE 10 BY 1.

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON b-history DEFAULT
     LABEL "Истори&я"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY trn-rsna FOR
      tt_trn-reason SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME trn-rsna
     b-exit AT ROW 1 COL 1 WIDGET-ID 4
     b-quit AT ROW 1 COL 11 WIDGET-ID 10
     b-attr AT ROW 1 COL 21 WIDGET-ID 2
     b-history AT ROW 1 COL 80.5 WIDGET-ID 8
     b-help AT ROW 1 COL 90.75 WIDGET-ID 6
     tt_trn-reason.reason-code AT ROW 2.25 COL 21.5 COLON-ALIGNED WIDGET-ID 14
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 15.5 BY 1
     tt_trn-reason.reason-name AT ROW 3.25 COL 2.5 WIDGET-ID 16
          LABEL "Основание (причина)"
          VIEW-AS FILL-IN
          SIZE 77.25 BY 1
     tt_trn-reason.PS AT ROW 4.25 COL 2.5 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR
          SIZE 98.25 BY 3.42
          BGCOLOR 15 FGCOLOR 4
     SPACE(0.62) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt_trn-reason T "?" NO-UNDO ub trn-reason
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX trn-rsna
   FRAME-NAME                                                           */
ASSIGN
       FRAME trn-rsna:SCROLLABLE       = FALSE
       FRAME trn-rsna:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-attr IN FRAME trn-rsna
   NO-ENABLE                                                            */
ASSIGN
       b-attr:HIDDEN IN FRAME trn-rsna           = TRUE.

/* SETTINGS FOR FILL-IN tt_trn-reason.reason-code IN FRAME trn-rsna
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt_trn-reason.reason-name IN FRAME trn-rsna
   ALIGN-L EXP-LABEL                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX trn-rsna
/* Query rebuild information for DIALOG-BOX trn-rsna
     _TblList          = "Temp-Tables.tt_trn-reason"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX trn-rsna */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME trn-rsna
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL trn-rsna trn-rsna
ON WINDOW-CLOSE OF FRAME trn-rsna /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-attr trn-rsna
ON CHOOSE OF b-attr IN FRAME trn-rsna /* Атрибуты */
DO:
  { gbl/stdbtn.i }
  run str/trsnatrs.w ( input parParentProc, input p-mode, input tt_trn-reason.reason-code ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit trn-rsna
ON CHOOSE OF b-exit IN FRAME trn-rsna /* Ввод  */
DO:
  { gbl/stdbtn.i }

  assign
    tt_trn-reason.reason-code
    tt_trn-reason.reason-name
    tt_trn-reason.PS
  .
  run ref/trn-rsn1.p
    ( input-output p-rid
    , input p-mode
    , input no /* p-silent */
    , input tt_trn-reason.reason-code
    , input tt_trn-reason.reason-name
    , input tt_trn-reason.PS
    ) no-error.
  if error-status:error then do:
    if return-value = "":U then do:
      return no-apply.
    end.
    case return-value :
      when "reason-code":U then do:
        apply "entry" to tt_trn-reason.reason-code .
      end.
      when "reason-name":u then do:
        apply "entry" to tt_trn-reason.reason-name .
      end.
      when "ps":u then do:
        apply "entry" to tt_trn-reason.ps .
      end.
    end.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history trn-rsna
ON CHOOSE OF b-history IN FRAME trn-rsna /* История */
DO:
  define variable v-list as character no-undo.

  { gbl/stdbtn.i }
  run str/trncrsns.w ( input parParentProc, input "":U, input "one":U, input tt_trn-reason.reason-code, input-output v-list ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit trn-rsna
ON CHOOSE OF b-quit IN FRAME trn-rsna /* Отмена */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK trn-rsna


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/hot-key.i b-help }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define buffer buf_trn-reason for ub.trn-reason .

  assign
    frame {&FRAME-NAME} :title = "Карточка основания (причины) создания документа  -- " + p-mode
    .

  create tt_trn-reason .

  if p-mode = {&add-def} then do:
    assign
      tt_trn-reason.reason-code = dynamic-next-value( "s-trn-reason":U, "{&db-name_schema}":U )
    .
  end.
  else do:
    case p-mode :
      when {&update} then do:
        find first buf_trn-reason exclusive-lock
          where recid( buf_trn-reason ) = p-rid
          no-error .
      end.
      when {&lookup} then do:
        find first buf_trn-reason no-lock
          where recid( buf_trn-reason ) = p-rid
          no-error.
      end.
    end case.
    if not available buf_trn-reason then do:
      message
        "Карточка основания (причины) создания документа не найдена!"
        view-as alert-box error.
      undo Main-Block, leave Main-Block.
    end.
    else do:
      buffer-copy buf_trn-reason to tt_trn-reason .
    end.
  end.


  RUN enable_UI.

  case p-mode :
    when {&add-def} then do:
      enable
        tt_trn-reason.reason-code
        with frame {&FRAME-NAME}.
    end.
    when {&lookup} then do:
      disable
        all
        with frame {&frame-name}.
      enable
        b-quit
        b-history
        with frame {&frame-name}.
    end.
  end case.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.

for each tt_trn-reason
:
  delete tt_trn-reason.
end.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI trn-rsna  _DEFAULT-DISABLE
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
  HIDE FRAME trn-rsna.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI trn-rsna  _DEFAULT-ENABLE
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
  IF AVAILABLE tt_trn-reason THEN
    DISPLAY tt_trn-reason.reason-code tt_trn-reason.reason-name tt_trn-reason.PS
      WITH FRAME trn-rsna.
  ENABLE b-exit b-quit b-history b-help tt_trn-reason.reason-name
         tt_trn-reason.PS
      WITH FRAME trn-rsna.
  VIEW FRAME trn-rsna.
  {&OPEN-BROWSERS-IN-QUERY-trn-rsna}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
