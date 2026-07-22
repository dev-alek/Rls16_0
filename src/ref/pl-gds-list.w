&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_goods FOR goods.
DEFINE BUFFER X_pl-gds FOR pl-gds.
DEFINE BUFFER X_place FOR place.

define temp-table tt-com-place
  field pl-code as integer
.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товары на складских местах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter in-pl-codes  as character   no-undo .
define output parameter out-pl-code  like ub.pl-gds.pl-code   no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Товары на складских местах" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ str/placelib.i }
define buffer b-goods for goods.
define buffer b-place for place.

define variable glog         as logical   no-undo .
define variable v-value      as character no-undo .
define variable v-ok         as logical   no-undo .
define variable ii           as integer   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-pl-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_pl-gds X_goods X_place

/* Definitions for BROWSE BR-pl-gds                                     */
&Scoped-define FIELDS-IN-QUERY-BR-pl-gds mark-string(RECID(X_pl-gds), v-rid-list) X_pl-gds.pl-code X_place.pl-name X_place.loc1 X_place.loc2 X_place.loc3 X_place.loc4 X_pl-gds.gds-code X_goods.artic X_goods.gds-name X_goods.prod-type X_goods.prod-code X_pl-gds.free-qnty X_pl-gds.fact-qnty X_pl-gds.cli-free-qnty X_pl-gds.cli-fact-qnty X_pl-gds.tolerance X_pl-gds.status_   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-pl-gds X_pl-gds.tolerance   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-pl-gds X_pl-gds
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-pl-gds X_pl-gds
&Scoped-define SELF-NAME BR-pl-gds
&Scoped-define QUERY-STRING-BR-pl-gds FOR EACH X_pl-gds NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK, ~
             EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-pl-gds OPEN QUERY {&SELF-NAME} FOR EACH X_pl-gds NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK, ~
             EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-pl-gds X_pl-gds X_goods X_place
&Scoped-define FIRST-TABLE-IN-QUERY-BR-pl-gds X_pl-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BR-pl-gds X_goods
&Scoped-define THIRD-TABLE-IN-QUERY-BR-pl-gds X_place


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-sel B-Help BR-pl-gds 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-pl-gds FOR
      tt-com-place,
      X_pl-gds,
      X_goods,
      X_place SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-pl-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-pl-gds Dialog-Frame _FREEFORM
  QUERY BR-pl-gds NO-LOCK DISPLAY
X_pl-gds.pl-code COLUMN-LABEL "Склд.место" FORMAT ">>>>>>>>>>9":U
X_place.pl-name FORMAT "X(40)":U
X_place.loc1 FORMAT "X(8)":U
X_place.loc2 FORMAT "X(8)":U
X_place.loc3 FORMAT "X(8)":U
X_place.loc4 FORMAT "X(8)":U
X_pl-gds.gds-code FORMAT "99999999999":U
X_goods.artic FORMAT "X(16)":U
X_goods.gds-name FORMAT "X(48)":U
X_goods.prod-type FORMAT "X(3)":U
X_goods.prod-code FORMAT ">>>>>>>>9":U
X_pl-gds.free-qnty FORMAT "->>,>>>,>>9.999":U
X_pl-gds.fact-qnty FORMAT "->>,>>>,>>9.999":U
X_pl-gds.cli-free-qnty FORMAT "->>,>>>,>>9.999":U
X_pl-gds.cli-fact-qnty FORMAT "->>,>>>,>>9.999":U
X_pl-gds.tolerance COLUMN-LABEL "Допуст.отклонение" FORMAT "->>,>>>,>>9.<<<":U
X_pl-gds.status_ FORMAT "X(8)":U
ENABLE
X_pl-gds.tolerance
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.2
     B-sel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     BR-pl-gds AT ROW 3.95 COL 1
     SPACE(0.00) SKIP(0.17)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Товары на складских местах"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_pl-gds B "?" ? ub pl-gds
      TABLE: X_place B "?" ? ub place
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-pl-gds B-Help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-pl-gds:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-pl-gds
/* Query rebuild information for BROWSE BR-pl-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_pl-gds NO-LOCK,
      EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK,
      EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code
  AND X_place.obj-type = X_pl-gds.obj-type
  AND X_place.pl-code = X_pl-gds.pl-code NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-pl-gds FOR
      X_pl-gds,
      X_goods,
      X_place SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BR-pl-gds */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Товары на складских местах */
DO:
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары на складских местах */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
DO:

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if available X_pl-gds
    then
      out-pl-code = X_pl-gds.pl-code
    .

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
  assign
  X_pl-gds.tolerance:read-only in browse {&BROWSE-NAME} = true.
  
  do ii = 1 to num-entries(in-pl-codes) :
    for first b-place no-lock where b-place.pl-code = integer(entry(ii, in-pl-codes)) :
      create tt-com-place .
      assign tt-com-place.pl-code = b-place.pl-code .
    end .
  end .  
    

  RUN MyENable.
  RUN OpenBR in this-procedure  ( input yes, input no, input '':U).
  APPLY "ENTRY" to br-pl-gds.
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
  ENABLE B-exit B-sel B-Help BR-pl-gds 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame 
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
br-pl-gds:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 1.

ENABLE
B-exit
B-sel
B-Help
BR-pl-gds
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define buffer buf_clients for ub.clients.

open query BR-pl-gds
for each tt-com-place,
    each X_pl-gds where X_pl-gds.pl-code = tt-com-place.pl-code no-lock,
    each X_goods where X_goods.gds-code = X_pl-gds.gds-code no-lock,
    each X_place where X_place.obj-code = X_pl-gds.obj-code 
                   and X_place.obj-type = X_pl-gds.obj-type
                   and X_place.pl-code  = X_pl-gds.pl-code
                   no-lock
.

if avail X_pl-gds then
APPLY "VALUE-CHANGED":U to br-pl-gds in frame Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

