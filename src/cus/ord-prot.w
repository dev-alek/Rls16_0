&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Протокол расчета заказа

Автор: Чернова Светлана Александровна
Дата создания: 09/13/07
Author: Svetlana Chernova
Creation date: 09/13/07

*/
/*-----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-ord-doc  as character no-undo .
define input  parameter p-gds-code as integer   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Протокол расчета заказа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

DEFINE TEMP-TABLE TT-protocol NO-UNDO
  field v-date as char
  field v-time as char
  field obj-type as char
  field obj-code as int
  field v-par as char
  field v-val as char
index pi
v-date desc
v-time desc
obj-type ASCENDING
obj-code ASCENDING
v-par  ASCENDING
.
define variable v-obj as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-3

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES TT-protocol

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 TT-protocol.v-date TT-protocol.v-time TT-protocol.obj-type + string(TT-protocol.obj-code ) @ v-obj TT-protocol.v-par TT-protocol.v-val
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH TT-protocol NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH TT-protocol NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-3 TT-protocol
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 TT-protocol


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-3}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-Help BROWSE-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR
      TT-protocol SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 NO-LOCK DISPLAY
      TT-protocol.v-date  column-label "Дата" Format "x(11)"
TT-protocol.v-time        column-label "Время"
TT-protocol.obj-type + string(TT-protocol.obj-code )  @ v-obj column-label "Объект"  Format "x(11)"
TT-protocol.v-par column-label "Параметр расчета"  Format "x(100)"
TT-protocol.v-val column-label "Значение"  Format "x(100)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 19.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-Help AT ROW 1 COL 72
     BROWSE-3 AT ROW 2.25 COL 1.5 WIDGET-ID 200
     SPACE(0.37) SKIP(1.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Протокол расчета заказа"
         CANCEL-BUTTON B-Cancel WIDGET-ID 100.


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
/* BROWSE-TAB BROWSE-3 B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH TT-protocol NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Протокол расчета заказа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Help */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-3 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-3 IN FRAME Dialog-Frame
DO:
      tt-protocol.v-par:bgcolor in browse {&browse-name}  = ?.
      tt-protocol.v-val:bgcolor in browse {&browse-name}  = ? .
      tt-protocol.v-date:bgcolor in browse {&browse-name}  = ?.
      tt-protocol.v-time:bgcolor in browse {&browse-name}  = ?.
      v-obj:bgcolor in browse {&browse-name}  = ? .
      tt-protocol.v-par:fgcolor in browse {&browse-name}  = ?.
      tt-protocol.v-val:fgcolor in browse {&browse-name}  = ? .
      tt-protocol.v-date:fgcolor in browse {&browse-name}  = ?.
      tt-protocol.v-time:fgcolor in browse {&browse-name}  = ?.
      v-obj:bgcolor in browse {&browse-name}  = ? .

  if tt-protocol.v-par begins "17" or
     tt-protocol.v-par begins "19" then do:
       tt-protocol.v-par:bgcolor in browse {&browse-name}  = 4 /* красный */  .
       tt-protocol.v-val:bgcolor in browse {&browse-name}  = 4 /* красный */  .
       tt-protocol.v-date:bgcolor in browse {&browse-name}  = 4 /* красный */  .
       tt-protocol.v-time:bgcolor in browse {&browse-name}  = 4 /* красный */  .
       v-obj:bgcolor in browse {&browse-name}  = 4 /* красный */  .
       tt-protocol.v-par:fgcolor in browse {&browse-name}  = 15   .
       tt-protocol.v-val:fgcolor in browse {&browse-name}  = 15  .
       tt-protocol.v-date:Fgcolor in browse {&browse-name}  = 15 .
       tt-protocol.v-time:Fgcolor in browse {&browse-name}  = 15 .
       v-obj:Fgcolor in browse {&browse-name}  = 15  .
  end.
  if index(tt-protocol.v-par ,"рассчитано заказа" ) > 0 then do:
       tt-protocol.v-par:fgcolor in browse {&browse-name}  = 1 /* синий */  .
       tt-protocol.v-val:fgcolor in browse {&browse-name}  = 1 /* синий */  .
       tt-protocol.v-date:Fgcolor in browse {&browse-name}  = 1 .
       tt-protocol.v-time:Fgcolor in browse {&browse-name}  = 1 .
       v-obj:Fgcolor in browse {&browse-name}  = 1  .
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
  run make-tt .
  RUN enable_UI.
  TT-protocol.v-par :resizable in browse {&browse-name} = true .
  TT-protocol.v-par :width     in browse {&browse-name} = 35 .
  define buffer buf_goods for ub.goods  .
    find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code .
  ASSIGN frame {&frame-name}:TITLE = "Протокол расчета заказа по товару " + buf_goods.gds-name + " Арт." + buf_goods.artic .
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
  ENABLE B-Cancel B-Help BROWSE-3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-tt Dialog-Frame
PROCEDURE make-tt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_ord-line-attr for ub.ord-line-attr  .
define variable i as integer   no-undo .

for each buf_ord-line-attr no-lock where
         buf_ord-line-attr.doc-code = p-ord-doc and
         buf_ord-line-attr.gds-code = p-gds-code and
         buf_ord-line-attr.attr-code begins "protocol"
         :
    repeat i = 1 to num-entries ( buf_ord-line-attr.attr-value,{&delim-par} ) :
    create TT-protocol.
    assign
      TT-protocol.obj-type =  entry( 2 , buf_ord-line-attr.attr-code ,{&delim-par})
      TT-protocol.obj-code =  int (entry( 3 , buf_ord-line-attr.attr-code ,{&delim-par}))
      TT-protocol.v-date =    entry( 4 , buf_ord-line-attr.attr-code ,{&delim-par})
      TT-protocol.v-time =    entry( 5 , buf_ord-line-attr.attr-code ,{&delim-par})
      TT-protocol.v-par  = trim (entry( 1 , entry( i , buf_ord-line-attr.attr-value ,{&delim-par}) , ":" ))
      TT-protocol.v-val  = trim (entry( 2 , entry( i , buf_ord-line-attr.attr-value ,{&delim-par}) , ":" ))
    .

end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME