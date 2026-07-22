&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Заведение НДС и типов приобретени

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define output parameter parold-vat-pc   like ub.doc-line.vat-pc no-undo.
define output parameter parvat-pc       like ub.doc-line.vat-pc no-undo.
define output parameter parpurch-list   as   character          no-undo.
define output parameter parchange-price as   logical            no-undo.
define output parameter paris-ok        as   logical            no-undo.

define temp-table tt-purch no-undo
field purch-code as integer
field mark as logical format "*/" label "*"
field purch-name as character format "x(30)" label "Тип приобретения"
index pi is unique primary purch-code.

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
define variable varcount as integer no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-purch

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 tt-purch.mark tt-purch.purch-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH tt-purch.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-purch
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-purch


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-mark b-help varold-vat-pc ~
varvat-pc varchange-price BROWSE-1
&Scoped-Define DISPLAYED-OBJECTS varold-vat-pc varvat-pc varchange-price

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4.38 BY 1.

DEFINE VARIABLE varold-vat-pc AS DECIMAL FORMAT ">9.99" INITIAL ?
     LABEL "&Старый НДС"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varvat-pc AS DECIMAL FORMAT ">9.99" INITIAL ?
     LABEL "&Новый НДС"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varchange-price AS LOGICAL INITIAL no
     LABEL "Пересчитать цену"
     VIEW-AS TOGGLE-BOX
     SIZE 20.13 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      tt-purch SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      tt-purch.mark tt-purch.purch-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 34.88 BY 6.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.13 COL 1
     b-cancel AT ROW 1.13 COL 11.38
     b-mark AT ROW 1.13 COL 21.75
     b-help AT ROW 1.13 COL 26.5
     varold-vat-pc AT ROW 2.5 COL 11 COLON-ALIGNED
     varvat-pc AT ROW 2.5 COL 28.38 COLON-ALIGNED
     varchange-price AT ROW 3.88 COL 1.25
     BROWSE-1 AT ROW 5.21 COL 1.25
     SPACE(0.74) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заведение НДС и типов приобретения"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


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
/* BROWSE-TAB BROWSE-1 varchange-price Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-purch.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заведение НДС и типов приобретения */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }
  assign
    paris-ok = no.
  apply "go" to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  { gbl/stdbtn.i }
  if varold-vat-pc = ? then do:
    message "Вы не установили старый процент НДС." view-as alert-box error.
    apply "entry" to varold-vat-pc in frame {&frame-name}.
    return no-apply.
  end.
  if varvat-pc = ? then do:
    message "Вы не установили новый процент НДС." view-as alert-box error.
    apply "entry" to varvat-pc in frame {&frame-name}.
    return no-apply.
  end.
  find first tt-purch where tt-purch.mark = yes no-error.
  if not available tt-purch then do:
    message "Вы не выбрали типы приобретения товара." view-as alert-box error.
    return no-apply.
  end.
  assign
    parold-vat-pc = varold-vat-pc
    parvat-pc     = varvat-pc
    parchange-price     = varchange-price
    paris-ok      = yes.
  for each tt-purch on error undo, return no-apply :
    if tt-purch.mark = yes then do:
      assign
        parpurch-list = parpurch-list + min (parpurch-list, ",") + string(tt-purch.purch-code).
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  { gbl/stdbtn.i }
  if available tt-purch then do:
    assign
      tt-purch.mark = not tt-purch.mark.
     display tt-purch.mark with browse {&browse-name}.
     get next {&browse-name}.
     if available tt-purch then do:
       reposition {&browse-name} to recid recid(tt-purch).
     end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varchange-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varchange-price Dialog-Frame
ON VALUE-CHANGED OF varchange-price IN FRAME Dialog-Frame /* Пересчитать цену */
DO:
  assign
       frame {&frame-name} varchange-price.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varold-vat-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varold-vat-pc Dialog-Frame
ON LEAVE OF varold-vat-pc IN FRAME Dialog-Frame /* Старый НДС */
DO:
  assign
    frame {&frame-name}
    varold-vat-pc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varvat-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varvat-pc Dialog-Frame
ON LEAVE OF varvat-pc IN FRAME Dialog-Frame /* Новый НДС */
DO:
  assign
    frame {&frame-name}
    varvat-pc.
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/app_help.i }
  {&browse-name} :SET-REPOSITIONED-ROW(2, "CONDITIONAL") .
  do varcount = 1 to num-entries({&purchase-codes}):
    create tt-purch.
    assign
      tt-purch.purch-code = varcount
      tt-purch.mark = no
      tt-purch.purch-name = entry (varcount, {&purchase-codes-full}).
  end.
  RUN enable_UI.
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
  DISPLAY varold-vat-pc varvat-pc varchange-price
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-mark b-help varold-vat-pc varvat-pc varchange-price
         BROWSE-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME