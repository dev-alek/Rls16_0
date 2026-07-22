&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_inkas-pay-wth FOR ub.inkas-pay-wth.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Наличность в кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/18/08
Author: Bakhtadze Natalya
Creation date: 08/18/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-db-num    as integer no-undo .
DEFINE INPUT PARAMETER p-obj-type  LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code  LIKE ub.clients.obj-code NO-UNDO.
define input parameter p-pos-type  as character no-undo .
define input parameter p-cash-num  like ub.inkas-pay-wth.pay-desk no-undo .
DEFINE INPUT PARAMETER bttns AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Наличность в кассе ".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cd-attr.i interface parparentproc }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }

DEFINE VARIABLE v-obj-db-num AS INTEGER NO-UNDO.
DEFINE VARIABLE rr AS RECID NO-UNDO.
DEFINE VARIABLE v-curr-r-b AS CHARACTER NO-UNDO.
define buffer locked_inkas-pay-wth for ub.inkas-pay-wth.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cash-counter

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_inkas-pay-wth

/* Definitions for BROWSE BR-cash-counter                               */
&Scoped-define FIELDS-IN-QUERY-BR-cash-counter get-cdpay-name(X_inkas-pay-wth.pay-code, X_inkas-pay-wth.curr-code) X_inkas-pay-wth.curr-code X_inkas-pay-wth.tot-sum (if X_inkas-pay-wth.par-val = 0 then '' else string(X_inkas-pay-wth.par-val, ">>,>>9":U)) (if X_inkas-pay-wth.par-val = 0 then '' else string(X_inkas-pay-wth.doc-qnty, "->>>,>>>,>>9.99":U))   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-counter   
&Scoped-define SELF-NAME BR-cash-counter
&Scoped-define QUERY-STRING-BR-cash-counter FOR EACH X_inkas-pay-wth NO-LOCK where         X_inkas-pay-wth.obj-type = p-obj-type     AND X_inkas-pay-wth.obj-code = p-obj-code     AND X_inkas-pay-wth.pay-desk = p-cash-num     AND X_inkas-pay-wth.cashier = 0     AND X_inkas-pay-wth.pay-code > 0     AND X_inkas-pay-wth.wth-code = 0     AND X_inkas-pay-wth.par-code = 0 INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cash-counter OPEN QUERY {&SELF-NAME} FOR EACH X_inkas-pay-wth NO-LOCK where         X_inkas-pay-wth.obj-type = p-obj-type     AND X_inkas-pay-wth.obj-code = p-obj-code     AND X_inkas-pay-wth.pay-desk = p-cash-num     AND X_inkas-pay-wth.cashier = 0     AND X_inkas-pay-wth.pay-code > 0     AND X_inkas-pay-wth.wth-code = 0     AND X_inkas-pay-wth.par-code = 0 INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cash-counter X_inkas-pay-wth
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-counter X_inkas-pay-wth


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-cash-counter}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-Help BR-cash-counter 
&Scoped-Define DISPLAYED-OBJECTS f-total 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cdpay-name Dialog-Frame 
FUNCTION get-cdpay-name RETURNS CHARACTER
  (
  INPUT p-cdpay-code AS INTEGER
  ,INPUT p-curr-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-total AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Всего" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-counter FOR 
      X_inkas-pay-wth SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-counter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-counter Dialog-Frame _FREEFORM
  QUERY BR-cash-counter NO-LOCK DISPLAY
      get-cdpay-name(X_inkas-pay-wth.pay-code, X_inkas-pay-wth.curr-code) COLUMN-LABEL "Касс.платеж" FORMAT "X(30)"
X_inkas-pay-wth.curr-code COLUMN-LABEL "Код валюты"
X_inkas-pay-wth.tot-sum COLUMN-LABEL "Сумма в кассе" FORMAT "->>>,>>>,>>9.99":U
(if X_inkas-pay-wth.par-val = 0
then ''
else string(X_inkas-pay-wth.par-val, ">>,>>9":U)) COLUMN-LABEL  "Номинал" FORMAT "X(7)"
(if X_inkas-pay-wth.par-val = 0
then ''
else string(X_inkas-pay-wth.doc-qnty, "->>>,>>>,>>9.99":U)) COLUMN-LABEL "Кол-во" FORMAT "X(15)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.77 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-Help AT ROW 1 COL 95
     f-total AT ROW 2.07 COL 20.5 WIDGET-ID 2
     BR-cash-counter AT ROW 3.5 COL 1
     SPACE(0.00) SKIP(0.60)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Наличность в каcсе"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_inkas-pay-wth B "?" ? ub inkas-pay-wth
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-cash-counter f-total Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-total IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-counter
/* Query rebuild information for BROWSE BR-cash-counter
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_inkas-pay-wth NO-LOCK where
        X_inkas-pay-wth.obj-type = p-obj-type
    AND X_inkas-pay-wth.obj-code = p-obj-code
    AND X_inkas-pay-wth.pay-desk = p-cash-num
    AND X_inkas-pay-wth.cashier = 0
    AND X_inkas-pay-wth.pay-code > 0
    AND X_inkas-pay-wth.wth-code = 0
    AND X_inkas-pay-wth.par-code = 0
INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-cash-counter */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

/* OCX BINARY:FILENAME is: exe\wrx\ref\cda-cc.wrx */

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME Dialog-Frame:HANDLE
       ROW             = 2.07
       COLUMN          = 64.5
       HEIGHT          = 1.07
       WIDTH           = 3.5
       WIDGET-ID       = 4
       HIDDEN          = yes
       SENSITIVE       = yes.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: PSTimer */
      CtrlFrame:MOVE-AFTER(f-total:HANDLE IN FRAME Dialog-Frame).

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Наличность в каcсе */
OR ENDKEY OF FRAME {&frame-name} DO:
   APPLY "GO" TO FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Наличность в каcсе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CtrlFrame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CtrlFrame Dialog-Frame OCX.Tick
PROCEDURE CtrlFrame.PSTimer.Tick .
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  None required for OCX.
  Notes:
------------------------------------------------------------------------------*/
RUN init-proc IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-counter
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
  { gbl/getcntxt.i get }
  if p-pos-type <> {&cd-type-ibs-th} then do:
    message
    "Неверный тип POS "
    view-as alert-box error .
    undo, return error .
  end.
  { gbl/curr-r-b.i v-curr-r-b }
  run Myenable IN THIS-PROCEDURE.
  if p-rid-list <> "":U then do:
    assign
    rr = integer(p-rid-list) no-error .
    .
    if not error-status:error then do:
      reposition br-cash-counter to recid rr no-error .
    end.
    APPLY "ENTRY" to br-cash-counter.
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load Dialog-Frame  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "exe\wrx\ref\cda-cc.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "exe\wrx\ref\cda-cc.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

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
  RUN control_load.
  DISPLAY f-total 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help BR-cash-counter 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
find first locked_inkas-pay-wth no-lock where
          locked_inkas-pay-wth.obj-type = p-obj-type
       and locked_inkas-pay-wth.obj-code = p-obj-code
       and locked_inkas-pay-wth.pay-desk = p-cash-num
        and locked_inkas-pay-wth.pay-code = 0
        and locked_inkas-pay-wth.curr-code = 0
        and locked_inkas-pay-wth.wth-code = 0
        and locked_inkas-pay-wth.par-code = 0
        and locked_inkas-pay-wth.cashier = 0
        and locked_inkas-pay-wth.chk-type = 0
        no-error .
ASSIGN
f-total = (IF AVAILABLE LOCKED_inkas-pay-wth
           THEN (if v-curr-r-b = {&r-b-rubl}
                then LOCKED_inkas-pay-wth.tot-rubl
                else LOCKED_inkas-pay-wth.tot-base)
           ELSE 0.0)
.
DISPlay
f-total
WITH FRAME {&FRAME-NAME}.
{&OPEN-QUERY-br-cash-counter}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
RUN control_load IN THIS-PROCEDURE.
ASSIGN
f-total:LABEL IN FRAME {&FRAME-NAME} = substitute("Всего (в &1)", (IF v-curr-r-b = {&r-b-rubl} THEN "нац.вал." ELSE "баз.вал. "))
chCtrlFrame:PSTimer:ENABLED  = (p-pos-type = {&cd-type-ibs-th}
                               OR
                               p-pos-type = {&cd-type-ibs-th-mob}
                               )
                               /*AND
                               p-mode = {&LOOKUP} */
chCtrlFrame:PSTimer:INTERVAL = IF NOT (p-pos-type = {&cd-type-ibs-th}
                               OR
                               p-pos-type = {&cd-type-ibs-th-mob}
                               )
                               /*AND
                               p-mode = {&LOOKUP} */ THEN 0
                                ELSE 3000

.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = SUBSTITUTE ("&1 &2&3"
                                         , FRAME {&FRAME-NAME}:TITLE
                                        , p-obj-type
                                        , p-obj-code ).
ENABLE
b-quit
B-Help
br-cash-counter
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
RUN init-proc IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cdpay-name Dialog-Frame 
FUNCTION get-cdpay-name RETURNS CHARACTER
  (
  INPUT p-cdpay-code AS INTEGER
  ,INPUT p-curr-code AS INTEGER ) :
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
FIND FIRST buf_cash-pay NO-LOCK WHERE
        buf_cash-pay.cdpay-code = p-cdpay-code
       and buf_cash-pay.curr-code = p-curr-code NO-ERROR.
IF AVAILABLE buf_cash-pay THEN RETURN buf_cash-pay.obj-name.
RETURN "!!!Неизвестный тип кассового платежа".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

