&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Объекты для ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 04/22/08
Author: Svetlana Chernova
Creation date: 04/22/08


*/

/* ***************************  Definitions  ************************** */

define temp-table tt-table no-undo
field f1 as character format "x(10)"
field f2 as character format "x(80)"
field f3 as character format "x(80)"
field f4 as character format "x(80)"
.
/* Parameters Definitions ---    */

define input  parameter table for tt-table .
define input  parameter p-title as character no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Объекты для ДНЦ ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ str/pdf-attr.i }

define variable p-exist as logical   no-undo .
define variable v-recid as recid no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-4

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-table

/* Definitions for BROWSE BROWSE-4                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-4 tt-table.f3 tt-table.f1 tt-table.f2 tt-table.f4
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-4
&Scoped-define SELF-NAME BROWSE-4
&Scoped-define QUERY-STRING-BROWSE-4 FOR EACH tt-table
&Scoped-define OPEN-QUERY-BROWSE-4 OPEN QUERY {&SELF-NAME} FOR EACH tt-table .
&Scoped-define TABLES-IN-QUERY-BROWSE-4 tt-table
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-4 tt-table


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-4}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-ins B-ins-2 B-del B-del-2 B-Help ~
BROWSE-4

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-del
     LABEL "Включить"
     SIZE 11 BY 1 TOOLTIP "Вернуть объект в список и создавать цены для него".

DEFINE BUTTON B-del-2
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Вернуть все объекты в список".

DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 12 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 3.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-ins
     LABEL "Исключить"
     SIZE 11 BY 1 TOOLTIP "Не создавать цены для объекта".

DEFINE BUTTON B-ins-2
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Исключить все объекты из списка".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-4 FOR
      tt-table SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-4 Dialog-Frame _FREEFORM
  QUERY BROWSE-4 DISPLAY
      tt-table.f3 format "x(1)"
tt-table.f1 format "x(10)"
tt-table.f2 format "x(25)"
tt-table.f4
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 64.13 BY 15 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-ins AT ROW 1 COL 13 WIDGET-ID 4
     B-ins-2 AT ROW 1 COL 24 WIDGET-ID 8
     B-del AT ROW 1 COL 27 WIDGET-ID 2
     B-del-2 AT ROW 1 COL 38 WIDGET-ID 6
     B-Help AT ROW 1 COL 61
     BROWSE-4 AT ROW 2 COL 1
     SPACE(0.00) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "объекты ДНЦ"
         CANCEL-BUTTON B-exit.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-4 B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-4
/* Query rebuild information for BROWSE BROWSE-4
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-table .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-4 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* объекты ДНЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Включить */
DO:
  /* удаляем атрибут*/
 find current tt-table no-error.
 if not available tt-table then return .
 tt-table.f3 = "*" .
 v-recid = recid(tt-table) .
 run del-pdf-attr-objdel in this-procedure
 (  input   p-pdf-id     ,
    input   p-pdf-db-num ,
    input   p-plt-id     ,
    input   p-plt-db-num ,
    input   entry(1,tt-table.f1," " )  ,
    input   integer(entry(2,tt-table.f1," " ))
     ) .
     {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
     reposition {&browse-name} to recid v-recid no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-2 Dialog-Frame
ON CHOOSE OF B-del-2 IN FRAME Dialog-Frame /* + */
DO:
  /* удаляем атрибут*/
 find current tt-table no-error.
 if not available tt-table then return .
  v-recid = recid(tt-table) .
  for each tt-table :
 tt-table.f3 = "*" .
 run del-pdf-attr-objdel in this-procedure
 (  input   p-pdf-id     ,
    input   p-pdf-db-num ,
    input   p-plt-id     ,
    input   p-plt-db-num ,
    input   entry(1,tt-table.f1," " )  ,
    input   integer(entry(2,tt-table.f1," " ))
     ) .
  end.   
     {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
     reposition {&browse-name} to recid v-recid no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
DO:
  if p-mode <> {&lookup} then do:
     run save-proc.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ins Dialog-Frame
ON CHOOSE OF B-ins IN FRAME Dialog-Frame /* Исключить */
DO:
  /* Добавляем атрибут */
  find current tt-table .
 if not available tt-table then return .
 tt-table.f3 = " " .
 v-recid = recid(tt-table) .
 run ins-pdf-attr-objdel in this-procedure
 (  input   p-pdf-id     ,
    input   p-pdf-db-num ,
    input   p-plt-id     ,
    input   p-plt-db-num ,
    input   entry(1,tt-table.f1," " )  ,
    input   integer(entry(2,tt-table.f1," " ))
     ) .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame} .
  reposition {&browse-name} to recid v-recid no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ins-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ins-2 Dialog-Frame
ON CHOOSE OF B-ins-2 IN FRAME Dialog-Frame /* - */
DO:
  /* Добавляем атрибут */
  find current tt-table .
 if not available tt-table then return .
 v-recid = recid(tt-table) .
 for each tt-table :
 tt-table.f3 = " " .
 
 run ins-pdf-attr-objdel in this-procedure
 (  input   p-pdf-id     ,
    input   p-pdf-db-num ,
    input   p-plt-id     ,
    input   p-plt-db-num ,
    input   entry(1,tt-table.f1," " )  ,
    input   integer(entry(2,tt-table.f1," " ))
     ) .
 end.    
 
 {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame} .
  reposition {&browse-name} to recid v-recid no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-4
&Scoped-define SELF-NAME BROWSE-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-4 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-4 IN FRAME Dialog-Frame
dO:
/* если есть в списке объект на удаление */
 p-exist = false  .
 run ex-pdf-attr-objdel in this-procedure
 (  input   p-pdf-id     ,
    input   p-pdf-db-num ,
    input   p-plt-id     ,
    input   p-plt-db-num ,
    input   entry(1,tt-table.f1," " )  ,
    input   integer(entry(2,tt-table.f1," " ))   ,
    output  p-exist ) .
 if p-exist =  true then do:
    assign
        tt-table.f1:fgcolor  in browse {&browse-name} = 8
        tt-table.f2:fgcolor = 8
        tt-table.f3:fgcolor = 8
        tt-table.f3 = '*'
    .
 end.
 else do:
      assign
        tt-table.f1:fgcolor = ?
        tt-table.f2:fgcolor = ?
        tt-table.f3:fgcolor = ?
        tt-table.f3 = ' '
      .
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

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   find first tt-table no-error .
   if not available tt-table then do:
      message "Нет данных !!! "  view-as alert-box information .
      return .
   end.
   if tt-table.f4 = "" then  tt-table.f4:visible  in browse {&browse-name} = false .

   frame {&frame-name}:TITLE  = entry(1 , p-title , {&delim-par} ) + " " + string(p-pdf-id) + " БД:" + string( p-pdf-db-num) .
   tt-table.f1 :label  = entry( 2 , p-title , {&delim-par} ).
   tt-table.f2 :label  = entry( 3 , p-title , {&delim-par} ).
   tt-table.f3 :label  = entry( 4 , p-title , {&delim-par} ).
   if tt-table.f4 <> "" then tt-table.f4 :label  = entry( 5 , p-title , {&delim-par} ).

  run enable_UI in this-procedure .
  if p-mode = {&lookup}  then  disable b-del b-ins b-del-2 b-ins-2 with frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

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
  ENABLE B-exit B-ins B-ins-2 B-del B-del-2 B-Help BROWSE-4 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
Сохраним список объектов по которым не нужно создавать цены
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

