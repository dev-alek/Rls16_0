&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER x-criterion-analysis FOR ub.criterion-analysis.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Критерии анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/30/05
*/
/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter bttns         as char   no-undo  .
define input  parameter p-mode        as char   no-undo .
define output parameter p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Критерии анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
define variable p-mark as character no-undo .
define variable ok# as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-5

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x-criterion-analysis

/* Definitions for BROWSE BROWSE-5                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-5 ~
mark-string(buffer x-criterion-analysis , p-rid-list) @ p-mark ~
x-criterion-analysis.cral-id x-criterion-analysis.cral-name ~
IF (x-criterion-analysis.cral-status = 0 ) THEN ("Активен") ELSE ("Не активен")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-5 ~
x-criterion-analysis.cral-id
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-5 x-criterion-analysis
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-5 x-criterion-analysis
&Scoped-define QUERY-STRING-BROWSE-5 FOR EACH x-criterion-analysis NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-5 OPEN QUERY BROWSE-5 FOR EACH x-criterion-analysis NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-5 x-criterion-analysis
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-5 x-criterion-analysis


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define BUFFER-FIELDS-IN-QUERY-Dialog-Frame x-criterion-analysis.cral-des ~

&Scoped-define ENABLED-BUFFER-FIELDS-IN-QUERY-Dialog-Frame x-criterion-analysis.cral-des ~

&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-5}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH x-criterion-analysis SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH x-criterion-analysis SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame x-criterion-analysis
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame x-criterion-analysis


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.x-criterion-analysis.cral-des
&Scoped-define ENABLED-TABLES ub.x-criterion-analysis
&Scoped-define FIRST-ENABLED-TABLE ub.x-criterion-analysis
&Scoped-Define ENABLED-OBJECTS BROWSE-5 b-quit B-act B-not-act B-print ~
B-Help mark-num
&Scoped-Define DISPLAYED-FIELDS ub.x-criterion-analysis.cral-des
&Scoped-define DISPLAYED-TABLES ub.x-criterion-analysis
&Scoped-define FIRST-DISPLAYED-TABLE ub.x-criterion-analysis
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
( BUFFER loc-table FOR x-criterion-analysis, input mark-list as CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-act
     LABEL "&Активен"
     SIZE 12 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 14 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-not-act
     LABEL "&Не активен"
     SIZE 14 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 12 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-5 FOR
      x-criterion-analysis SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      x-criterion-analysis SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-5 Dialog-Frame _STRUCTURED
  QUERY BROWSE-5 NO-LOCK DISPLAY
      mark-string(buffer x-criterion-analysis , p-rid-list) @ p-mark COLUMN-LABEL "*" FORMAT "x(1)":U
      x-criterion-analysis.cral-id COLUMN-LABEL "Код" FORMAT ">>9":U
      x-criterion-analysis.cral-name COLUMN-LABEL "Название" FORMAT "X(35)":U
      IF (x-criterion-analysis.cral-status = 0 ) THEN ("Активен") ELSE ("Не активен") COLUMN-LABEL "Статус" FORMAT "x(10)":U
  ENABLE
      x-criterion-analysis.cral-id
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 57 BY 14.25 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     BROWSE-5 AT ROW 3 COL 1.5
     B-sel AT ROW 1 COL 17
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-act AT ROW 1 COL 32.5
     B-not-act AT ROW 1 COL 44.5
     B-print AT ROW 2 COL 32.5
     B-Help AT ROW 2 COL 44.5
     ub.x-criterion-analysis.cral-des AT ROW 17.5 COL 1.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 57 BY 4
     mark-num AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL
     SPACE(41.50) SKIP(19.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Критерии анализа"
         DEFAULT-BUTTON B-sel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x-criterion-analysis B "?" ? ub criterion-analysis
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   Custom                                                               */
/* BROWSE-TAB BROWSE-5 1 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       x-criterion-analysis.cral-id:COLUMN-READ-ONLY IN BROWSE BROWSE-5 = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-5
/* Query rebuild information for BROWSE BROWSE-5
     _TblList          = "x-criterion-analysis"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(buffer x-criterion-analysis , p-rid-list) @ p-mark" "*" "x(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.x-criterion-analysis.cral-id
"x-criterion-analysis.cral-id" "Код" ">>9" "integer" ? ? ? ? ? ? yes ? no no ? yes no yes "U" "" ""
     _FldNameList[3]   > Temp-Tables.x-criterion-analysis.cral-name
"x-criterion-analysis.cral-name" "Название" "X(35)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   > "_<CALC>"
"IF (x-criterion-analysis.cral-status = 0 ) THEN (""Активен"") ELSE (""Не активен"")" "Статус" "x(10)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BROWSE-5 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.x-criterion-analysis"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Критерии анализа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-act
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-act Dialog-Frame
ON CHOOSE OF B-act IN FRAME Dialog-Frame /* Активен */
DO:

find current x-criterion-analysis exclusive-lock no-error .
if available x-criterion-analysis then do:
  x-criterion-analysis.cral-status = 0 .
  ok# = {&browse-name}:refresh() .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}  then do:
    { gbl/markstrn.i {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} p-rid-list }
    loc#log = {&BROWSE-NAME}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&BROWSE-NAME}:select-next-row ().
        apply "VALUE-CHANGED" to {&BROWSE-NAME} in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-not-act
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-not-act Dialog-Frame
ON CHOOSE OF B-not-act IN FRAME Dialog-Frame /* Не активен */
DO:

find current x-criterion-analysis exclusive-lock no-error .
if available x-criterion-analysis then do:
  x-criterion-analysis.cral-status = 1 .
  ok# = {&browse-name}:refresh() .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
   IF  p-rid-list = "" THEN DO:
      IF AVAILABLE x-criterion-analysis  THEN p-rid-list = string(RECID(x-criterion-analysis )).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-5
&Scoped-define SELF-NAME BROWSE-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-5 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BROWSE-5 IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE":U TO B-sel in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-5 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-5 IN FRAME Dialog-Frame
DO:


  IF AVAILABLE x-criterion-analysis THEN
     DISPLAY x-criterion-analysis.cral-des WITH FRAME Dialog-Frame.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  x-criterion-analysis.cral-id:READ-ONLY IN browse {&browse-name}      = TRUE.
  run enable_ui.
  run my_enable .
  wait-for go of frame {&frame-name} focus {&browse-name} .
end.
run disable_ui.

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-criterion-analysis THEN
    DISPLAY x-criterion-analysis.cral-des
      WITH FRAME Dialog-Frame.
  ENABLE BROWSE-5 b-quit B-act B-not-act B-print B-Help
         x-criterion-analysis.cral-des mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-criterion-analysis THEN
    DISPLAY x-criterion-analysis.cral-des
      WITH FRAME Dialog-Frame.
x-criterion-analysis.cral-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

  ENABLE b-quit
          B-mark  when LOOKUP("b-mark":U, bttns) > 0
          B-sel   when LOOKUP("b-sel":U, bttns) > 0
          B-act
          B-not-act
          B-print
          B-Help
          BROWSE-5
          x-criterion-analysis.cral-des

      WITH FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
( BUFFER loc-table FOR x-criterion-analysis, input mark-list as CHARACTER ) :
RETURN ( IF LOOKUP( STRING( RECID( loc-table ) ), mark-list ) > 0 THEN "*" ELSE "":U ).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print W-Win
PROCEDURE proc-b-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  message "Не используется"  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME