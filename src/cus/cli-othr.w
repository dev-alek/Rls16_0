&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Список других поставщиков по товару

Автор: Чернова Светлана Александровна
Дата создания: 03/21/06
Author: Svetlana Chernova
Creation date: 03/21/06


*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список других поставщиков по товару".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define Input Parameter xartic     like ub.cli-gds.artic no-undo.
define Input Parameter xprod-type like ub.cli-gds.prod-type no-undo.
define Input Parameter xprod-code like ub.cli-gds.prod-code no-undo.

define Input Parameter xcli-type like ub.cli-gds.cli-type no-undo.
define Input Parameter xcli-code like ub.cli-gds.cli-code no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.cli-gds ub.clients

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 ~
(ub.clients.obj-type + " " + String(ub.clients.obj-code)) @ ub.clients.obj-type ~
ub.clients.obj-name ub.cli-gds.price-cli ub.cli-gds.unit-cli ~
ub.cli-gds.cli-art 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH ub.cli-gds ~
      WHERE cli-gds.artic = xartic ~
 AND cli-gds.prod-code = xprod-code ~
 AND cli-gds.prod-type = xprod-type ~
 and cli-gds.price-cli > 0 ~
 AND NOT (cli-gds.cli-code =  xcli-code And cli-gds.cli-type =  xcli-type) ~
  NO-LOCK, ~
      EACH ub.clients WHERE clients.obj-code = cli-gds.cli-code ~
  AND clients.obj-type = cli-gds.cli-type ~
      AND (clients.sup-cons = TRUE ~
 OR clients.sup-gds = TRUE ~
 OR clients.sup-serv = TRUE) NO-LOCK ~
    BY ub.cli-gds.price-cli
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH ub.cli-gds ~
      WHERE cli-gds.artic = xartic ~
 AND cli-gds.prod-code = xprod-code ~
 AND cli-gds.prod-type = xprod-type ~
 and cli-gds.price-cli > 0 ~
 AND NOT (cli-gds.cli-code =  xcli-code And cli-gds.cli-type =  xcli-type) ~
  NO-LOCK, ~
      EACH ub.clients WHERE clients.obj-code = cli-gds.cli-code ~
  AND clients.obj-type = cli-gds.cli-type ~
      AND (clients.sup-cons = TRUE ~
 OR clients.sup-gds = TRUE ~
 OR clients.sup-serv = TRUE) NO-LOCK ~
    BY ub.cli-gds.price-cli.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 ub.cli-gds ub.clients
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 ub.cli-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-2 ub.clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-Help BROWSE-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-select 
     LABEL "Выбрать" 
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
      ub.cli-gds, 
      ub.clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      (ub.clients.obj-type + " " + String(ub.clients.obj-code)) @ ub.clients.obj-type COLUMN-LABEL "Код" FORMAT "X(8)":U
      ub.clients.obj-name COLUMN-LABEL "Поставщик" FORMAT "X(40)":U
      ub.cli-gds.price-cli FORMAT "->>,>>>,>>>,>>9.999":U
      ub.cli-gds.unit-cli COLUMN-LABEL "Ед.изм." FORMAT "X(3)":U
      ub.cli-gds.cli-art FORMAT "X(14)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94 BY 9.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-select AT ROW 1 COL 11
     B-Help AT ROW 1 COL 85
     BROWSE-2 AT ROW 2.75 COL 1.5
     SPACE(0.00) SKIP(0.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "У других поставщиков..."
         DEFAULT-BUTTON B-select CANCEL-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 B-Help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-select IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-select:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "ub.cli-gds,ub.clients WHERE ub.cli-gds ..."
     _Options          = "NO-LOCK"
     _TblOptList       = ","
     _OrdList          = "ub.cli-gds.price-cli|yes"
     _Where[1]         = "cli-gds.artic = xartic
 AND cli-gds.prod-code = xprod-code
 AND cli-gds.prod-type = xprod-type
 and cli-gds.price-cli > 0
 AND NOT (cli-gds.cli-code =  xcli-code And cli-gds.cli-type =  xcli-type)
 "
     _JoinCode[2]      = "clients.obj-code = cli-gds.cli-code
  AND clients.obj-type = cli-gds.cli-type"
     _Where[2]         = "(clients.sup-cons = TRUE
 OR clients.sup-gds = TRUE
 OR clients.sup-serv = TRUE)"
     _FldNameList[1]   > "_<CALC>"
"(ub.clients.obj-type + "" "" + String(ub.clients.obj-code)) @ ub.clients.obj-type" "Код" "X(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.clients.obj-name
"clients.obj-name" "Поставщик" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = ub.cli-gds.price-cli
     _FldNameList[4]   > ub.cli-gds.unit-cli
"cli-gds.unit-cli" "Ед.изм." ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = ub.cli-gds.cli-art
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* У других поставщиков... */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
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
  RUN enable_UI.
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
  ENABLE B-exit B-Help BROWSE-2 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

