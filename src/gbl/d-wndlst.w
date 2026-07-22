&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список всех окон сессии

Автор: Перваков Михаил Сергеевич
Дата создания: 06/26/01
Author: Mikhail Pervakov
Creation date: 06/26/01

Originally was created as copy of s r c / p r o t o o l s / _ w a l k e r . w
  Author: Wm. T. Wood, Gerry Seidl
  Created: Sept. 1994
*/

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список всех окон сессии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */
DEFINE VAR show_levels AS INTEGER NO-UNDO.
DEFINE VAR save_recid  AS RECID   NO-UNDO.
DEFINE VAR mode        AS CHAR    NO-UNDO INITIAL "ALL".
/* NO-ADE   ALL */

/* Temp-Table/Browser Definitions ---                                   */
DEFINE TEMP-TABLE tt NO-UNDO
  FIELD handle       AS HANDLE
  FIELD name         AS CHAR
  FIELD level        AS INTEGER
  FIELD parent-recid AS RECID
  FIELD expanded     AS LOGICAL
  FIELD visible      AS LOGICAL
  .
DEFINE BUFFER x_tt FOR tt.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME D-Dialog
&Scoped-define BROWSE-NAME wlist

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt

/* Definitions for BROWSE wlist                                         */
&Scoped-define FIELDS-IN-QUERY-wlist FILL(" ",tt.level - 1) + (IF NOT CAN-FIND (FIRST x_tt WHERE x_tt.parent-recid eq RECID(tt)) THEN " " ELSE (IF tt.expanded THEN "- " ELSE "+ " )) + tt.name
&Scoped-define ENABLED-FIELDS-IN-QUERY-wlist
&Scoped-define FIELD-PAIRS-IN-QUERY-wlist
&Scoped-define SELF-NAME wlist
&Scoped-define OPEN-QUERY-wlist OPEN QUERY {&SELF-NAME} FOR EACH tt   WHERE tt.level <= show_levels AND tt.visible .
&Scoped-define TABLES-IN-QUERY-wlist tt
&Scoped-define FIRST-TABLE-IN-QUERY-wlist tt


/* Definitions for DIALOG-BOX D-Dialog                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-D-Dialog ~
    ~{&OPEN-QUERY-wlist}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS btn_expand btn_collapse btn_level-1 ~
btn_level-2 btn_level-3 btn_level-4 btn_level-5 btn_level-all wlist levels
&Scoped-Define DISPLAYED-OBJECTS levels

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON btn_collapse
     LABEL "-":L
     SIZE 4 BY 1.

DEFINE BUTTON btn_expand
     LABEL "+":L
     SIZE 4 BY 1.

DEFINE BUTTON btn_level-1
     LABEL "1":L
     SIZE 4 BY 1.

DEFINE BUTTON btn_level-2
     LABEL "2":L
     SIZE 4 BY 1.

DEFINE BUTTON btn_level-3
     LABEL "3":L
     SIZE 4 BY 1.

DEFINE BUTTON btn_level-4
     LABEL "4":L
     SIZE 4 BY 1.

DEFINE BUTTON btn_level-5
     LABEL "5":L
     SIZE 4 BY 1.

DEFINE BUTTON btn_level-all
     LABEL "...":L
     SIZE 4 BY 1.

DEFINE VARIABLE levels AS CHARACTER FORMAT "X(21)":U
      VIEW-AS TEXT
     SIZE 17 BY .96.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY wlist FOR
      tt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE wlist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS wlist D-Dialog _FREEFORM
  QUERY wlist DISPLAY
      FILL("     ",tt.level - 1) +
                (IF NOT CAN-FIND (FIRST x_tt WHERE x_tt.parent-recid eq RECID(tt))
                 THEN "  "
                 ELSE (IF tt.expanded THEN "- " ELSE "+ " )) +
                tt.name FORMAT "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79.63 BY 14.83.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     btn_expand AT ROW 1.5 COL 4.38
     btn_collapse AT ROW 1.5 COL 8.38
     btn_level-1 AT ROW 1.5 COL 30.38
     btn_level-2 AT ROW 1.5 COL 34.38
     btn_level-3 AT ROW 1.5 COL 38.38
     btn_level-4 AT ROW 1.5 COL 42.38
     btn_level-5 AT ROW 1.5 COL 46.38
     btn_level-all AT ROW 1.5 COL 50.38
     wlist AT ROW 2.75 COL 4.25
     levels AT ROW 1.54 COL 11.38 COLON-ALIGNED NO-LABEL
     SPACE(56.36) SKIP(15.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert SmartDialog title>".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
                                                                        */
/* BROWSE-TAB wlist btn_level-all D-Dialog */
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE wlist
/* Query rebuild information for BROWSE wlist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt
  WHERE tt.level <= show_levels AND tt.visible
.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE wlist */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* <insert SmartDialog title> */
DO:
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_collapse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_collapse D-Dialog
ON CHOOSE OF btn_collapse IN FRAME D-Dialog /* - */
DO:
  DEFINE BUFFER child_tt FOR tt.
  IF AVAILABLE tt AND tt.expanded THEN DO:
    /* Don't collapse something that has no children */
    IF CAN-FIND (FIRST child_tt WHERE child_tt.parent-recid eq RECID(tt))
    THEN DO:
      /* Store the current recid */
      save_recid = RECID(tt).
      RUN set_expansion (RECID(tt), NO).
      RUN reopen_query.
    END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_expand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_expand D-Dialog
ON CHOOSE OF btn_expand IN FRAME D-Dialog /* + */
DO:
  IF AVAILABLE tt AND tt.expanded eq NO THEN DO:
    /* Store the current recid */
    save_recid = RECID(tt).
    RUN set_expansion (RECID(tt), YES).
    RUN reopen_query.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_level-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_level-1 D-Dialog
ON CHOOSE OF btn_level-1 IN FRAME D-Dialog /* 1 */
DO:
  /* Store the current recid, change the display level, and reopen the query. */
  ASSIGN save_recid = IF AVAILABLE tt THEN RECID(tt) ELSE ?
         show_levels = integer(self:LABEL)
         levels:SCREEN-VALUE = "Level 1"   /* Show user what levels are shown */
         .
  RUN reopen_query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_level-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_level-2 D-Dialog
ON CHOOSE OF btn_level-2 IN FRAME D-Dialog /* 2 */
DO:
  /* Store the current recid, change the display level, and reopen the query. */
  ASSIGN save_recid = IF AVAILABLE tt THEN RECID(tt) ELSE ?
         show_levels = integer(self:LABEL)
         /* Show user what levels are shown */
         levels:SCREEN-VALUE = "Levels 1 - " + SELF:LABEL
         .
  RUN reopen_query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_level-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_level-3 D-Dialog
ON CHOOSE OF btn_level-3 IN FRAME D-Dialog /* 3 */
DO:
  /* Store the current recid, change the display level, and reopen the query. */
  ASSIGN save_recid = IF AVAILABLE tt THEN RECID(tt) ELSE ?
         show_levels = integer(self:LABEL)
         /* Show user what levels are shown */
         levels:SCREEN-VALUE = "Levels 1 - " + SELF:LABEL
         .
  RUN reopen_query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_level-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_level-4 D-Dialog
ON CHOOSE OF btn_level-4 IN FRAME D-Dialog /* 4 */
DO:
  /* Store the current recid, change the display level, and reopen the query. */
  ASSIGN save_recid = IF AVAILABLE tt THEN RECID(tt) ELSE ?
         show_levels = integer(self:LABEL)
         /* Show user what levels are shown */
         levels:SCREEN-VALUE = "Levels 1 - " + SELF:LABEL
         .
  RUN reopen_query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_level-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_level-5 D-Dialog
ON CHOOSE OF btn_level-5 IN FRAME D-Dialog /* 5 */
DO:
  /* Store the current recid, change the display level, and reopen the query. */
  ASSIGN save_recid = IF AVAILABLE tt THEN RECID(tt) ELSE ?
         show_levels = integer(self:LABEL)
         /* Show user what levels are shown */
         levels:SCREEN-VALUE = "Levels 1 - " + SELF:LABEL
         .
  RUN reopen_query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_level-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_level-all D-Dialog
ON CHOOSE OF btn_level-all IN FRAME D-Dialog /* ... */
DO:
  /* Store the current recid, change the display level, and reopen the query. */
  ASSIGN save_recid = IF AVAILABLE tt THEN RECID(tt) ELSE ?
         show_levels = 1000000
         /* Show user what levels are shown */
         levels:SCREEN-VALUE = "All Levels"
         .
  RUN reopen_query.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME wlist
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i &disable-button=yes }

do:
  wlist :set-repositioned-row( 5, "conditional" ) .
end.

/* Add a call to request the Default-Action when an item is dbl-clicked */
ON DEFAULT-ACTION OF wlist IN FRAME {&FRAME-NAME} DO:
  DEFINE BUFFER child_tt FOR tt.
  IF AVAILABLE tt THEN DO:
    /* Don't expand/collapse something that has no children */
    IF CAN-FIND (FIRST child_tt WHERE child_tt.parent-recid eq RECID(tt))
    THEN DO:
      /* Store the current recid */
      save_recid = RECID(tt).
      RUN set_expansion (RECID(tt), NOT tt.expanded).
      RUN reopen_query.
    END.
  END.
END.

def var l-user-defined-objects as logical   no-undo .
def var l-all-objects          as logical   no-undo .

assign
  l-user-defined-objects = false
  l-all-objects          = true
.

RUN create_list (SESSION, 1, ?).
/* Show user what levels are shown */
ASSIGN show_levels = 1000000
        levels:SCREEN-VALUE = "All Levels".
.

{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create_list D-Dialog
PROCEDURE create_list :
/* -----------------------------------------------------------
  Purpose: create the temp-table containing all the items in
           that parent to a widget.
  Parameters:  phParent - Pointer to the aggregate
               pLevel   - the level
               prParent - Parent Recid
  Notes:
-------------------------------------------------------------*/
  DEF INPUT PARAMETER phParent AS WIDGET  NO-UNDO.
  DEF INPUT PARAMETER pLevel   AS INTEGER NO-UNDO.
  DEF INPUT PARAMETER prParent AS RECID   NO-UNDO.

  DEF VAR elist AS CHARACTER     NO-UNDO INITIAL "User Interface Builder,PROGRESS,PRO*Tools,Data Dictionary,Procedure Editor,Data Administration,Librarian,Results,Translation Manager,Application Compiler,Control Hierarchy,Run Procedure,Color Changer,PRO*Spy".
  DEF VAR h     AS WIDGET-HANDLE NO-UNDO.

  /* Make a record in the temp-table */
  h = phParent:FIRST-CHILD.
  DO WHILE VALID-HANDLE(h):
     IF h:TYPE = "WINDOW" AND mode = "NO-ADE" THEN
       IF CAN-DO(elist,TRIM(h:TITLE))        OR
         h:TITLE = ?                         OR
         h:TITLE BEGINS "Procedure -"        OR
         h:TITLE BEGINS "Procedure Editor -" OR
         h:TITLE BEGINS "User Interface Builder -" THEN DO:
           ASSIGN h = h:NEXT-SIBLING. /* skip it */
           NEXT.
       END.
    /* Create a record for this thing */
    CREATE tt.
    ASSIGN tt.level = pLevel
           tt.parent-recid = prParent
           tt.expanded = YES
           tt.visible = YES
           tt.handle = h
           tt.name =  LC(h:TYPE) + ": "
           .
    /* Make the name more descriptive. */
    CASE h:TYPE:
      WHEN "WINDOW":U OR WHEN "DIALOG-BOX":U THEN
        tt.name = tt.name + (IF h:TITLE EQ ? THEN STRING(h) ELSE h:TITLE).
      WHEN "FRAME":U THEN DO:
        tt.name = tt.name + IF h:TITLE eq ? THEN STRING(h) ELSE h:TITLE.
        END.
      WHEN "FIELD-GROUP":U THEN
        tt.name = tt.name + STRING(h).
      OTHERWISE DO:
        IF CAN-QUERY(h, "LABEL":U) AND h:LABEL ne ? AND h:LABEL ne "":U THEN
          tt.name = tt.name + h:LABEL.
        ELSE IF CAN-QUERY(h, "NAME-":U) AND h:NAME ne ? THEN
          tt.name = tt.name + h:NAME.
        ELSE IF CAN-QUERY(h, "SCREEN-VALUE":U) AND h:SCREEN-VALUE ne ? THEN
          tt.name = tt.name + "'":U + h:SCREEN-VALUE + "'":U.
        ELSE tt.name = tt.name + "@ X=" + STRING(h:X) + ", Y=" + STRING(h:Y).
      END.
    END CASE.
    /* Call recursively, if necessary */
    IF CAN-QUERY(h,"FIRST-CHILD") THEN RUN create_list (h, pLevel + 1, RECID(tt)).

    /* Get the next sibling. */
    h = h:NEXT-SIBLING.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog _DEFAULT-DISABLE
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
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog _DEFAULT-ENABLE
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
  DISPLAY levels
      WITH FRAME D-Dialog.
  ENABLE btn_expand btn_collapse btn_level-1 btn_level-2 btn_level-3
         btn_level-4 btn_level-5 btn_level-all wlist levels
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Refresh D-Dialog
PROCEDURE Refresh :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DEF VAR xname LIKE tt.name.

  run adecomm/_setcurs.p ("WAIT").
  /* save off old name */
  IF save_recid <> ? THEN DO:
      FIND x_tt WHERE RECID(x_tt) = save_recid NO-ERROR.
      IF AVAILABLE x_tt THEN xname = x_tt.name.
      ELSE save_recid = ?.
  END.
  /* clear original widget list */
  FOR EACH tt: DELETE tt. END.

  /* Create the list of widgets. */
  RUN create_list (SESSION, 1, ?).

  IF xname <> "" AND save_recid <> ? THEN DO:
      /* try to maintain previous position */
      FIND FIRST tt WHERE tt.name = xname NO-ERROR.
      IF NOT AVAILABLE tt THEN DO:
          FIND FIRST tt NO-ERROR.
          IF AVAILABLE tt THEN save_recid = RECID(tt).
      END.
      ELSE save_recid = RECID(tt).
  END.
  RUN reopen_query.
  run adecomm/_setcurs.p ("").
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen_query D-Dialog
PROCEDURE reopen_query :
/* -----------------------------------------------------------
  Purpose:  Remember where we are in the query, reopen the query
            and reposition to that point.
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* Reopen query */
  {&OPEN-QUERY-wlist}
  /* Repositon query */
  IF save_recid NE ? THEN DO:
      FIND FIRST x_tt WHERE RECID(x_tt) = save_recid NO-ERROR.
      IF AVAILABLE x_tt THEN DO:
          DO WHILE x_tt.level > show_levels: /* if wrong level, find parent that is*/
              save_recid = x_tt.parent-recid.
              FIND x_tt WHERE RECID(x_tt) = save_recid.
          END.
          REPOSITION wlist TO RECID save_recid.
      END.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set_expansion D-Dialog
PROCEDURE set_expansion :
/* -----------------------------------------------------------
  Purpose: If a list record is selected, then mark it as
           expanded (or collapsed).  Mark its descendends as
           visible (or not).
           it and all its descendants.
  Parameters:  pRecid  - Recid to expand
               pExpand - TRUE if we want to expand, FALSE for collapse
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER pRecid  AS RECID   NO-UNDO.
  DEFINE INPUT PARAMETER pExpand AS LOGICAL NO-UNDO.

  DEFINE BUFFER child_tt FOR tt.

  FIND tt WHERE RECID(tt) eq pRECID NO-ERROR.
  IF AVAILABLE tt THEN DO:
    tt.expanded = pExpand.
    FOR EACH child_tt WHERE child_tt.parent-recid eq pRecid:
      RUN set_visible (RECID(child_tt), pExpand).
    END.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set_visible D-Dialog
PROCEDURE set_visible :
/* -----------------------------------------------------------
  Purpose: Mark the current record as visible (or not), if it
           is set the wrong way.
           visible (or not).
           it and all its descendants.
  Parameters: pRecid   - Recid to expand
              pVisible - TRUE if we want to expand, FALSE for collapse
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER pRecid   AS RECID   NO-UNDO.
  DEFINE INPUT PARAMETER pVisible AS LOGICAL NO-UNDO.

  DEFINE BUFFER child_tt FOR tt.

  FIND tt WHERE RECID(tt) eq pRECID NO-ERROR.
  IF AVAILABLE tt THEN DO:
    tt.visible = pVisible.
    FOR EACH child_tt WHERE child_tt.parent-recid eq pRecid:
      IF NOT pVisible OR (tt.expanded AND pVisible)
      THEN RUN set_visible (RECID(child_tt), pVisible).
    END.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
