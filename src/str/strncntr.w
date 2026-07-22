&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Документы по договору

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 10/19/05

Автор назвал это  -  Экран просмотра финансовых архивов по складским документам

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parhost-code     LIKE ub.contract.host-code     NO-UNDO.
DEFINE INPUT PARAMETER parcontract-code LIKE ub.contract.contract-code NO-UNDO.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра финансовых архивов по складским документам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/libtfarh.i }
{ cmp/showinf.i }

DEFINE TEMP-TABLE tt-trn-contract no-undo
    FIELD doc-code          LIKE ub.trn-doc.doc-code
    FIELD full-ext-doc-type AS   CHARACTER
    FIELD fact-order        LIKE ub.trn-doc.fact-order
    FIELD fact-date         AS   DATE
    FIELD sum-base          AS   DECIMAL
    FIELD sum-rubl          AS   DECIMAL
    FIELD shift-date        AS   DATE
    FIELD shift-num         AS   INTEGER
    FIELD shift-name        AS   CHARACTER
    INDEX pi IS UNIQUE PRIMARY doc-code
    INDEX vi fact-date DESCENDING fact-order DESCENDING.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-trn-contract

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 doc-code full-ext-doc-type sum-base sum-rubl fact-date shift-date shift-num shift-name fact-order
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH tt-trn-contract BY fact-order
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH tt-trn-contract BY fact-order.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-trn-contract
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-trn-contract


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help BROWSE-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      tt-trn-contract SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      doc-code COLUMN-LABEL "Номер документа"
 full-ext-doc-type FORMAT "x(15)" COLUMN-LABEL "Тип документа"
 sum-base FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма (вал)"
 sum-rubl FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма (abbr_rub)"
 fact-date COLUMN-LABEL "Дата факт"
 shift-date COLUMN-LABEL "Дата смена"
 shift-name COLUMN-LABEL "Номер смены"
 shift-num COLUMN-LABEL "Порядок смены"
 fact-order format ">>>>>>>>>>>>>>>>>>>>>9.9999999999" COLUMN-LABEL "Номер факт"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 11
     BROWSE-1 AT ROW 2.25 COL 1
     SPACE(0.00) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документы по договору"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-trn-contract BY fact-order.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Документы по договору */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
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
   run calc-table in this-procedure no-error.
  if error-status:error then do:
    message return-value error-status:get-message(1) error-status:get-message(2)
    view-as alert-box.

  end.
  assign
  sum-rubl:label in browse BROWSE-1 = "Сумма ({&abbr_rub})"
  .
  RUN enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-table Dialog-Frame
PROCEDURE calc-table :
DEFINE VARIABLE varcount AS INTEGER NO-UNDO.
DEFINE VARIABLE varext-doc-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE varinc-exp AS INTEGER NO-UNDO.
DEFINE BUFFER bf_arh-trn-doc-contract FOR ub.arh-trn-doc-contract.
DEFINE BUFFER bf-prev_arh-trn-doc-contract FOR ub.arh-trn-doc-contract.
DEFINE BUFFER bf_clients FOR ub.clients.
DEFINE BUFFER bf_sysconf FOR ub.sysconf.
DEFINE BUFFER bf_contract FOR ub.contract.
FIND FIRST bf_Contract WHERE bf_contract.host-code     = parhost-code     AND
                             bf_contract.contract-code = parcontract-code NO-LOCK.
FIND FIRST bf_sysconf WHERE bf_sysconf.host-code = parhost-code NO-LOCK.
FOR EACH bf_clients WHERE bf_clients.host-code = bf_sysconf.host-code NO-LOCK ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  cycle-do:
  DO varcount = 1 TO NUM-ENTRIES({&TDEDT_List}):
    ASSIGN
      varext-doc-type = ENTRY (varcount, {&TDEDT_List}).
    { str/finincex.i varext-doc-type varinc-exp }
    IF varinc-exp <> 1 AND
       varinc-exp <> 2 THEN DO:
      NEXT cycle-do.
    END.
    FOR EACH bf_arh-trn-doc-contract WHERE bf_arh-trn-doc-contract.host-code     = parhost-code         AND
                                           bf_arh-trn-doc-contract.contract-code = parcontract-code     AND
                                           bf_arh-trn-doc-contract.cli-type      = bf_contract.cli-type AND
                                           bf_arh-trn-doc-contract.cli-code      = bf_contract.cli-code AND
                                           bf_arh-trn-doc-contract.obj-type      = bf_clients.obj-type  AND
                                           bf_arh-trn-doc-contract.obj-code      = bf_clients.obj-code  AND
                                           bf_arh-trn-doc-contract.ext-doc-type  = varext-doc-type      AND
                                           bf_arh-trn-doc-contract.sum-type      = "":u                 NO-LOCK ON ERROR UNDO, RETURN ERROR:
    if bf_arh-trn-doc-contract.doc-code = "остаток" then next .
    FIND LAST bf-prev_arh-trn-doc-contract WHERE bf-prev_arh-trn-doc-contract.host-code     = parhost-code         AND
                                                 bf-prev_arh-trn-doc-contract.contract-code = parcontract-code     AND
                                                 bf-prev_arh-trn-doc-contract.cli-type      = bf_contract.cli-type AND
                                                 bf-prev_arh-trn-doc-contract.cli-code      = bf_contract.cli-code AND
                                                 bf-prev_arh-trn-doc-contract.obj-type      = bf_clients.obj-type  AND
                                                 bf-prev_arh-trn-doc-contract.obj-code      = bf_clients.obj-code  AND
                                                 bf-prev_arh-trn-doc-contract.ext-doc-type  = varext-doc-type      AND
                                                 bf-prev_arh-trn-doc-contract.sum-type      = "":u                 and
                                                 bf-prev_arh-trn-doc-contract.fact-order    < bf_arh-trn-doc-contract.fact-order use-index pi NO-lock no-error.
    CREATE tt-trn-contract.
    ASSIGN
      tt-trn-contract.doc-code          = bf_arh-trn-doc-contract.doc-code
      tt-trn-contract.full-ext-doc-type = entry(lookup(varext-doc-type, {&tdedt_list}), {&tdedt_list-full})
      tt-trn-contract.fact-order        = bf_arh-trn-doc-contract.fact-order
      tt-trn-contract.fact-date         = bf_arh-trn-doc-contract.fact-date
      tt-trn-contract.sum-base          = (IF varinc-exp = 1 THEN bf_arh-trn-doc-contract.inc-sum-base - (if available bf-prev_arh-trn-doc-contract then bf-prev_arh-trn-doc-contract.inc-sum-base else 0) ELSE bf_arh-trn-doc-contract.exp-sum-base - (if available bf-prev_arh-trn-doc-contract then bf-prev_arh-trn-doc-contract.exp-sum-base else 0))
      tt-trn-contract.sum-rubl          = (IF varinc-exp = 1 THEN bf_arh-trn-doc-contract.inc-sum-rubl - (if available bf-prev_arh-trn-doc-contract then bf-prev_arh-trn-doc-contract.inc-sum-rubl else 0) ELSE bf_arh-trn-doc-contract.exp-sum-rubl - (if available bf-prev_arh-trn-doc-contract then bf-prev_arh-trn-doc-contract.exp-sum-rubl else 0))
      tt-trn-contract.shift-date        = bf_arh-trn-doc-contract.shift-date
      tt-trn-contract.shift-num         = bf_arh-trn-doc-contract.shift-num
      tt-trn-contract.shift-name        = bf_arh-trn-doc-contract.shift-name

     .
    END.
  END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  ENABLE b-exit b-help BROWSE-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME