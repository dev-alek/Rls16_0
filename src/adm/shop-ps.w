&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE SHARED TEMP-TABLE tt-shop NO-UNDO LIKE ub.shop.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибутов магазина

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

Author: Черных В.
Created: 17/09/97 -  5:03 pm

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentProc as widget-handle no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-obj-code like ub.shop.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибутов магазина".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }


/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-shop tt-clients

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-shop.acct tt-shop.store-boss ~
tt-shop.goods-man tt-shop.store-man tt-clients.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-shop.acct ~
tt-shop.store-boss tt-shop.goods-man tt-shop.store-man tt-clients.PS
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-shop tt-clients
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-shop
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-clients
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-shop SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.shop incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-shop SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.shop incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-shop tt-clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-shop
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame tt-clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-shop.acct tt-shop.store-boss ~
tt-shop.goods-man tt-shop.store-man tt-clients.PS
&Scoped-define ENABLED-TABLES tt-shop tt-clients
&Scoped-define FIRST-ENABLED-TABLE tt-shop
&Scoped-define SECOND-ENABLED-TABLE tt-clients
&Scoped-Define ENABLED-OBJECTS B-exit B-quit b-help RECT-1 StartTime ~
EndTime
&Scoped-Define DISPLAYED-FIELDS tt-shop.acct tt-shop.store-boss ~
tt-shop.goods-man tt-shop.store-man tt-clients.PS
&Scoped-define DISPLAYED-TABLES tt-shop tt-clients
&Scoped-define FIRST-DISPLAYED-TABLE tt-shop
&Scoped-define SECOND-DISPLAYED-TABLE tt-clients
&Scoped-Define DISPLAYED-OBJECTS StartTime EndTime

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EndTime AS DECIMAL FORMAT "99.99":U INITIAL 20
     LABEL "Окончание"
     VIEW-AS FILL-IN
     SIZE 6.13 BY .92
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE StartTime AS DECIMAL FORMAT "99.99":U INITIAL 8
     LABEL "Начало"
     VIEW-AS FILL-IN
     SIZE 6.38 BY .92
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71 BY 4.21.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-shop,
      tt-clients SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     tt-shop.acct AT ROW 2.46 COL 11.13 COLON-ALIGNED
          LABEL "Бухгалтер"
          VIEW-AS FILL-IN
          SIZE 24.5 BY .92
          BGCOLOR 15
     tt-shop.store-boss AT ROW 2.46 COL 50.25 COLON-ALIGNED
          LABEL "Зав. складом"
          VIEW-AS FILL-IN
          SIZE 23 BY .92
          BGCOLOR 15
     tt-shop.goods-man AT ROW 3.46 COL 11.13 COLON-ALIGNED
          LABEL "Товаровед"
          VIEW-AS FILL-IN
          SIZE 24.5 BY .92
          BGCOLOR 15
     tt-shop.store-man AT ROW 3.46 COL 50.25 COLON-ALIGNED
          LABEL "Кладовщик"
          VIEW-AS FILL-IN
          SIZE 23 BY .92
          BGCOLOR 15
     StartTime AT ROW 6.92 COL 13.5
     EndTime AT ROW 6.92 COL 47.75 COLON-ALIGNED
     tt-clients.PS AT ROW 11 COL 2.88 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          SIZE 71 BY 5.33
          BGCOLOR 15
     "Время работы ( при круглосуточной - указывайте : 00.00 и 00.00 ) :" VIEW-AS TEXT
          SIZE 63.75 BY 1 AT ROW 5.33 COL 6.63
          FGCOLOR 4
     "Примечание :" VIEW-AS TEXT
          SIZE 12.5 BY 1 AT ROW 9.63 COL 31.75
          FGCOLOR 4
     RECT-1 AT ROW 4.58 COL 2.88
     SPACE(4.10) SKIP(7.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 1 "Дополнительные сведения о магазине":L
         CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: tt-clients T "SHARED" NO-UNDO ub clients
      TABLE: tt-shop T "SHARED" NO-UNDO ub shop
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   UNDERLINE                                                            */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN tt-shop.acct IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.goods-man IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN StartTime IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-shop.store-boss IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.store-man IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-shop,Temp-Tables.tt-clients WHERE ub.shop ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод  */
DO:
    assign
        tt-clients.PS StartTime EndTime
        tt-shop.acct tt-shop.goods-man tt-shop.store-boss tt-shop.store-man
        .
    assign
    tt-shop.Work-hours = string( StartTime, "99.99" ) + "," + string( EndTime, "99.99" ) .
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

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode = {&add-def} then do:
    find first tt-shop .
    find first tt-clients .
  end.
  else do:
    find first tt-shop no-lock where
                    tt-shop.obj-code = p-obj-code .
    find first tt-clients no-lock where
                    tt-clients.obj-code = p-obj-code
                ANd tt-clients.obj-type = {&shop}.
  end.
    run Myenable in this-procedure.
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
  DISPLAY StartTime EndTime
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.PS
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-shop THEN
    DISPLAY tt-shop.acct tt-shop.store-boss tt-shop.goods-man tt-shop.store-man
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit b-help RECT-1 tt-shop.acct tt-shop.store-boss
         tt-shop.goods-man tt-shop.store-man StartTime EndTime tt-clients.PS
      WITH FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    assign
        StartTime = decimal( entry( 1, tt-shop.work-hours ) )
        EndTime = decimal( entry( 2, tt-shop.work-hours ) ) .

DISPLAY EndTime StartTime
      WITH FRAME {&frame-name}.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.PS
      WITH FRAME {&frame-name}.
  IF AVAILABLE tt-shop THEN
    DISPLAY tt-shop.store-man tt-shop.acct tt-shop.store-boss tt-shop.goods-man
      WITH FRAME {&frame-name}.
  ENABLE RECT-1 tt-clients.PS B-quit EndTime tt-shop.store-man B-exit
         tt-shop.acct tt-shop.store-boss b-help tt-shop.goods-man StartTime
      WITH FRAME {&frame-name}.
 if p-mode = {&lookup} then do:
    assign
    tt-clients.PS:read-only = yes
    b-quit:label = "&Выход".
    DISABLE
    B-exit
    StartTime
    EndTime
    tt-shop.acct
    tt-shop.goods-man
    tt-shop.store-boss
    tt-shop.store-man
    WITH FRAME {&frame-name}.
    hide
    b-exit in frame {&frame-name}.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME