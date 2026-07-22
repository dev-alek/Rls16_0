&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/* Parameters Definitions ---                                           */
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран работы с признаками в документе пересортица

Автор: Чернова Светлана Александровна
Дата создания: 09/12/07
Author: Svetlana Chernova
Creation date: 09/12/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 07/17/06


*/
{ cmp/str-glbl.i }
{ cmp/showinf.i }

DEFINE PARAMETER BUFFER bf_goods FOR ub.goods.
DEFINE INPUT PARAMETER pardoc-code AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER parobj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER parobj-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER parwrite-off AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER parmode AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER parstate AS LOGICAL INITIAL NO NO-UNDO.
DEFINE SHARED TEMP-TABLE tt-gds-prt NO-UNDO
FIELD prt-code LIKE ub.gds-dtl.prt-code
FIELD prt-name AS CHARACTER
FIELD write-off-doc-qnty AS DECIMAL FORMAT ">,>>>,>>>,>>9.9999"
FIELD income-doc-qnty AS DECIMAL FORMAT ">,>>>,>>>,>>9.9999"
FIELD write-off-qnty AS DECIMAL FORMAT ">,>>>,>>>,>>9.9999"
FIELD income-qnty AS DECIMAL FORMAT ">,>>>,>>>,>>9.9999"
FIELD fact-qnty AS DECIMAL FORMAT ">,>>>,>>>,>>9.9999"
INDEX pi IS UNIQUE PRIMARY prt-code.

DEFINE BUFFER bf_gds-obj FOR ub.gds-obj.
DEFINE VARIABLE varfree-brw-qnty AS DECIMAL NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-gds-dtl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES TT-gds-prt

/* Definitions for BROWSE b-gds-dtl                                     */
&Scoped-define FIELDS-IN-QUERY-b-gds-dtl tt-gds-prt.prt-name tt-gds-prt.fact-qnty tt-gds-prt.write-off-qnty tt-gds-prt.income-qnty tt-gds-prt.fact-qnty - tt-gds-prt.write-off-doc-qnty + tt-gds-prt.income-doc-qnty - tt-gds-prt.write-off-qnty + tt-gds-prt.income-qnty @ varfree-brw-qnty tt-gds-prt.write-off-doc-qnty tt-gds-prt.income-doc-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-gds-dtl tt-gds-prt.write-off-qnty tt-gds-prt.income-qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-b-gds-dtl tt-gds-prt
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-b-gds-dtl tt-gds-prt
&Scoped-define SELF-NAME b-gds-dtl
&Scoped-define QUERY-STRING-b-gds-dtl FOR EACH TT-gds-prt NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-b-gds-dtl OPEN QUERY {&SELF-NAME} FOR EACH TT-gds-prt NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-b-gds-dtl TT-gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-b-gds-dtl TT-gds-prt


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-gds-dtl}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help b-gds-dtl
&Scoped-Define DISPLAYED-OBJECTS varfact-qnty varwork-qnty varfree-qnty ~
varbrw-f-name

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

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE varbrw-f-name AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 94 BY 3.42 NO-UNDO.

DEFINE VARIABLE varfact-qnty AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Факт"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varfree-qnty AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Свободно"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varwork-qnty AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "По документу"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-gds-dtl FOR
      TT-gds-prt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-gds-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-gds-dtl Dialog-Frame _FREEFORM
  QUERY b-gds-dtl NO-LOCK DISPLAY
      tt-gds-prt.prt-name FORMAT "x(300)" COLUMN-LABEL "Шкала" WIDTH 40
      tt-gds-prt.fact-qnty FORMAT "->>,>>>,>>9.<<<":U  COLUMN-LABEL "Было"
      tt-gds-prt.write-off-qnty FORMAT ">>,>>>,>>9.<<<" COLUMN-LABEL "Списано"
      tt-gds-prt.income-qnty FORMAT ">>,>>>,>>9.<<<" COLUMN-LABEL "Оприходовано"
      tt-gds-prt.fact-qnty + (if parmode = {&add-def} then - tt-gds-prt.write-off-doc-qnty + tt-gds-prt.income-doc-qnty - tt-gds-prt.write-off-qnty + tt-gds-prt.income-qnty else - tt-gds-prt.write-off-qnty + tt-gds-prt.income-qnty)  @ varfree-brw-qnty FORMAT "->>,>>>,>>9.<<<" COLUMN-LABEL "Стало"
      tt-gds-prt.write-off-doc-qnty FORMAT ">>,>>>,>>9.<<<" COLUMN-LABEL "Списано в док"
      tt-gds-prt.income-doc-qnty FORMAT ">>,>>>,>>9.<<<" COLUMN-LABEL "Оприходовано в док"
      ENABLE tt-gds-prt.write-off-qnty tt-gds-prt.income-qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94 BY 13.5 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varfact-qnty AT ROW 2.5 COL 6.5 COLON-ALIGNED
     varwork-qnty AT ROW 2.5 COL 37.5 COLON-ALIGNED
     varfree-qnty AT ROW 2.5 COL 65 COLON-ALIGNED
     b-gds-dtl AT ROW 4 COL 1
     varbrw-f-name AT ROW 17.5 COL 1 NO-LABEL
     SPACE(0.37) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


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
/* BROWSE-TAB b-gds-dtl varfree-qnty Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR EDITOR varbrw-f-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varfact-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varfree-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwork-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-gds-dtl
/* Query rebuild information for BROWSE b-gds-dtl
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH TT-gds-prt NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE b-gds-dtl */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  ASSIGN
    parstate = YES.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-gds-dtl
&Scoped-define SELF-NAME b-gds-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds-dtl Dialog-Frame
ON GO OF b-gds-dtl IN FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds-dtl Dialog-Frame
ON RETURN OF b-gds-dtl IN FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds-dtl Dialog-Frame
ON ROW-LEAVE OF b-gds-dtl IN FRAME Dialog-Frame
DO:
ASSIGN
  BROWSE {&browse-name}
    tt-gds-prt.write-off-qnty tt-gds-prt.income-qnty.
  RUN disp-free-qnty IN THIS-PROCEDURE NO-ERROR.
  DISPLAY (if parmode = {&add-def} then tt-gds-prt.fact-qnty - tt-gds-prt.write-off-doc-qnty + tt-gds-prt.income-doc-qnty - tt-gds-prt.write-off-qnty + tt-gds-prt.income-qnty else tt-gds-prt.fact-qnty - tt-gds-prt.write-off-qnty + tt-gds-prt.income-qnty) @ varfree-brw-qnty WITH browse {&browse-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds-dtl Dialog-Frame
ON VALUE-CHANGED OF b-gds-dtl IN FRAME Dialog-Frame
DO:
  IF AVAILABLE tt-gds-prt THEN DO:
    ASSIGN
      varbrw-f-name = tt-gds-prt.prt-name.
    DISPLAY varbrw-f-name WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
ON return OF tt-gds-prt.write-off-qnty IN BROWSE {&browse-name}
DO:
  APPLY "value-changed" TO BROWSE {&browse-name}.
  RETURN NO-APPLY.
END.
ON return OF tt-gds-prt.income-qnty IN BROWSE {&browse-name}
DO:
  APPLY "value-changed" TO BROWSE {&browse-name}.
  RETURN NO-APPLY.
END.
ON GO OF tt-gds-prt.write-off-qnty IN BROWSE {&browse-name}
DO:
  RETURN NO-APPLY.
END.
ON GO OF tt-gds-prt.income-qnty IN BROWSE {&browse-name}
DO:
  RETURN NO-APPLY.
END.
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 ASSIGN
    frame {&FRAME-NAME}:TITLE = "Редактирование признаков для документа пересортица " + pardoc-code + " для товара " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code) + " " + bf_goods.gds-name.
  FIND FIRST bf_gds-obj WHERE bf_gds-obj.obj-type  = parobj-type        AND
                              bf_gds-obj.obj-code  = parobj-code        AND
                              bf_gds-obj.artic     = bf_goods.artic     AND
                              bf_gds-obj.prod-type = bf_goods.prod-type AND
                              bf_gds-obj.prod-code = bf_goods.prod-code NO-LOCK no-error .
  ASSIGN
    varfact-qnty = if available bf_gds-obj then bf_gds-obj.fact-qnty else 0.
  DISPLAY varfact-qnty WITH FRAME {&FRAME-NAME}.
  RUN make-tt-table IN THIS-PROCEDURE.
  RUN disp-free-qnty IN THIS-PROCEDURE.
  RUN enable_UI.
  IF parwrite-off = YES THEN DO:
    ASSIGN
      tt-gds-prt.income-qnty:READ-ONLY = YES.
  END.
  ELSE DO:
    ASSIGN
      tt-gds-prt.write-off-qnty:READ-ONLY = YES.
  END.
  IF parmode = {&LOOKUP} THEN DO:
    ASSIGN
      tt-gds-prt.income-qnty:READ-ONLY    = YES
      tt-gds-prt.write-off-qnty:READ-ONLY = YES.
    DISABLE b-exit WITH FRAME {&FRAME-NAME}.
  END.
  apply "VALUE-CHANGED" to {&browse-name} IN FRAME {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS {&BROWSE-NAME}.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-free-qnty Dialog-Frame
PROCEDURE disp-free-qnty :
DEFINE BUFFER bf_tt-gds-prt FOR tt-gds-prt.
  ASSIGN
    varwork-qnty = 0.00.
  FOR EACH bf_tt-gds-prt ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    ASSIGN
      varwork-qnty = varwork-qnty + (if parmode = {&add-def} then - bf_tt-gds-prt.write-off-doc-qnty + bf_tt-gds-prt.income-doc-qnty - bf_tt-gds-prt.write-off-qnty + bf_tt-gds-prt.income-qnty else - bf_tt-gds-prt.write-off-qnty + bf_tt-gds-prt.income-qnty).
  END.
  ASSIGN
    varfree-qnty = varfact-qnty + varwork-qnty.
  DISPLAY varwork-qnty varfree-qnty WITH FRAME {&FRAME-NAME}.
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
  DISPLAY varfact-qnty varwork-qnty varfree-qnty varbrw-f-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help b-gds-dtl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-tt-table Dialog-Frame
PROCEDURE make-tt-table :
DEFINE BUFFER bf_prt-obj      FOR ub.prt-obj.
DEFINE BUFFER bf_gds-dtl      FOR ub.gds-dtl.
DEFINE BUFFER bf-root_gds-prt FOR ub.gds-prt.
DEFINE BUFFER bf_gds-prt      FOR ub.gds-prt.
DEFINE BUFFER bf_parts        FOR ub.parts.
DEFINE VARIABLE varwrite-off-qnty AS DECIMAL NO-UNDO.
DEFINE VARIABLE varincome-qnty    AS DECIMAL NO-UNDO.
FOR EACH tt-gds-prt :
  DELETE tt-gds-prt.
END.
ASSIGN
  varwrite-off-qnty = 0.00
  varincome-qnty    = 0.00.
IF parwrite-off THEN DO:
 FOR EACH bf_prt-obj WHERE bf_prt-obj.obj-type  = parobj-type        AND
                           bf_prt-obj.obj-code  = parobj-code        AND
                           bf_prt-obj.artic     = bf_goods.artic     AND
                           bf_prt-obj.prod-type = bf_goods.prod-type AND
                           bf_prt-obj.prod-code = bf_goods.prod-code NO-LOCK ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    if bf_prt-obj.free-qnty <= 0 then next.
    FIND FIRST bf_gds-prt WHERE bf_gds-prt.node-code = bf_prt-obj.prt-code NO-LOCK .
    IF bf_gds-prt.is-term <> YES THEN DO:
      NEXT.
    END.
    FIND FIRST bf_gds-dtl WHERE bf_gds-dtl.doc-code  = pardoc-code          AND
                                bf_gds-dtl.artic     = bf_prt-obj.artic     AND
                                bf_gds-dtl.prod-type = bf_prt-obj.prod-type AND
                                bf_gds-dtl.prod-code = bf_prt-obj.prod-code AND
                                bf_gds-dtl.prt-code  = bf_prt-obj.prt-code  NO-LOCK NO-ERROR.

    CREATE tt-gds-prt.
    ASSIGN
      tt-gds-prt.prt-code              = bf_gds-prt.node-code
      tt-gds-prt.prt-name              = bf_gds-prt.f-name
      tt-gds-prt.fact-qnty             = bf_prt-obj.fact-qnty
      tt-gds-prt.write-off-doc-qnty    = (if available bf_gds-dtl and bf_gds-dtl.doc-qnty < 0 then - bf_gds-dtl.doc-qnty else 0)
      tt-gds-prt.income-doc-qnty       = (if available bf_gds-dtl and bf_gds-dtl.doc-qnty > 0 then   bf_gds-dtl.doc-qnty else 0)
      tt-gds-prt.write-off-qnty        = (if parmode = {&add-def} then 0 else tt-gds-prt.write-off-doc-qnty )
      tt-gds-prt.income-qnty           = (if parmode = {&add-def} then 0 else tt-gds-prt.income-doc-qnty    )

    .
  END.
END.
ELSE DO:
  FIND FIRST bf-root_gds-prt WHERE bf-root_gds-prt.upper-code = bf_goods.prt-root no-lock.
  FOR EACH bf_gds-prt WHERE bf_gds-prt.prt-root = bf-root_gds-prt.prt-root and
                            bf_gds-prt.is-term  = YES                      NO-LOCK ON ERROR UNDO, RETURN ERROR :

    FIND FIRST bf_prt-obj WHERE bf_prt-obj.obj-type  = parobj-type         AND
                                bf_prt-obj.obj-code  = parobj-code         AND
                                bf_prt-obj.artic     = bf_goods.artic      AND
                                bf_prt-obj.prod-type = bf_goods.prod-type  AND
                                bf_prt-obj.prod-code = bf_goods.prod-code  AND
                                bf_prt-obj.prt-code  = bf_gds-prt.node-code  NO-LOCK NO-ERROR.
    FIND FIRST bf_gds-dtl WHERE bf_gds-dtl.doc-code  = pardoc-code          AND
                                bf_gds-dtl.artic     = bf_goods.artic     AND
                                bf_gds-dtl.prod-type = bf_goods.prod-type AND
                                bf_gds-dtl.prod-code = bf_goods.prod-code AND
                                bf_gds-dtl.prt-code  = bf_gds-prt.node-code NO-LOCK NO-ERROR.
    CREATE tt-gds-prt.
    ASSIGN
      tt-gds-prt.prt-code           = bf_gds-prt.node-code
      tt-gds-prt.prt-name           = bf_gds-prt.f-name
      tt-gds-prt.fact-qnty          = (IF AVAILABLE bf_prt-obj THEN bf_prt-obj.fact-qnty ELSE 0)
      tt-gds-prt.write-off-doc-qnty = (if available bf_gds-dtl and bf_gds-dtl.doc-qnty < 0 then - bf_gds-dtl.doc-qnty else 0)
      tt-gds-prt.income-doc-qnty    = (if available bf_gds-dtl and bf_gds-dtl.doc-qnty > 0 then   bf_gds-dtl.doc-qnty else 0)
      tt-gds-prt.write-off-qnty     = (if parmode = {&add-def} then 0 else tt-gds-prt.write-off-doc-qnty)
      tt-gds-prt.income-qnty        = (if parmode = {&add-def} then 0 else tt-gds-prt.income-doc-qnty   )

    .
  END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME