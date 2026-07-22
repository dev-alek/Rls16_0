&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_cash-pay-attr FOR ub.cash-pay-attr.
DEFINE TEMP-TABLE tt-cash-desk NO-UNDO LIKE ub.cash-desk.
DEFINE TEMP-TABLE tt-cash-pay-attr NO-UNDO LIKE ub.cash-pay-attr.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание атрибута ИСПОЛЬЗУЕТСЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/19/05
Author: Bakhtadze Natalya
Creation date: 09/19/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
/* Parameters Definitions ---                                           */
define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
define INPUT parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
define INPUT parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
define INPUT parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-attr-value AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.
/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Задание атрибута ИСПОЛЬЗУЕТСЯ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }

DEFINE VARIABLE v-obj-db-num LIKE ub.db.db-num NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cash-desk

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cash-desk

/* Definitions for BROWSE BR-cash-desk                                  */
&Scoped-define FIELDS-IN-QUERY-BR-cash-desk tt-cash-desk.cash-num ~
tt-cash-desk.pos-type 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-desk 
&Scoped-define QUERY-STRING-BR-cash-desk FOR EACH tt-cash-desk NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cash-desk OPEN QUERY BR-cash-desk FOR EACH tt-cash-desk NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cash-desk tt-cash-desk
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-desk tt-cash-desk


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-cash-desk}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit RECT-region b-quit B-Help RS-region ~
BR-cash-desk Rs-cash-desk B-cash-desk Rs-is-use var-region v-host-name ~
for-obj-name 
&Scoped-Define DISPLAYED-OBJECTS RS-region Rs-cash-desk Rs-is-use ~
var-region v-host-name for-obj-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cash-desk 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE for-obj-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 37.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-host-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 51.5 BY 1 NO-UNDO.

DEFINE VARIABLE var-region AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE Rs-cash-desk AS CHARACTER INITIAL "*" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все кассы", "*",
"Выборочно", "N"
     SIZE 20 BY 2.25 NO-UNDO.

DEFINE VARIABLE Rs-is-use AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Используется", "*",
"Не используется", "-"
     SIZE 24 BY 3
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-region AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Глобально", 0,
"Фирма", 1,
"Объект", 2
     SIZE 63 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-region
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 72 BY 6.46.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-desk FOR 
      tt-cash-desk SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-desk Dialog-Frame _STRUCTURED
  QUERY BR-cash-desk NO-LOCK DISPLAY
      tt-cash-desk.cash-num FORMAT ">>>9":U
      tt-cash-desk.pos-type FORMAT "X(20)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 46 BY 6.75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     RS-region AT ROW 2.75 COL 3 NO-LABEL
     BR-cash-desk AT ROW 9 COL 27.5
     Rs-cash-desk AT ROW 9.25 COL 1.5 NO-LABEL
     B-cash-desk AT ROW 10.5 COL 22
     Rs-is-use AT ROW 12.5 COL 2 NO-LABEL
     var-region AT ROW 4.5 COL 18 COLON-ALIGNED NO-LABEL
     v-host-name AT ROW 6 COL 18 COLON-ALIGNED NO-LABEL
     for-obj-name AT ROW 7.5 COL 20.5 COLON-ALIGNED NO-LABEL
     RECT-region AT ROW 2.5 COL 1.5
     SPACE(3.62) SKIP(6.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Области использования типа кассового платежа"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_cash-pay-attr B "?" ? ub cash-pay-attr
      TABLE: tt-cash-desk T "?" NO-UNDO ub cash-desk
      TABLE: tt-cash-pay-attr T "?" NO-UNDO ub cash-pay-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-cash-desk RS-region Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-desk
/* Query rebuild information for BROWSE BR-cash-desk
     _TblList          = "Temp-Tables.tt-cash-desk"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = Temp-Tables.tt-cash-desk.cash-num
     _FldNameList[2]   = Temp-Tables.tt-cash-desk.pos-type
     _Query            is OPENED
*/  /* BROWSE BR-cash-desk */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Области использования типа кассового платежа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cash-desk Dialog-Frame
ON CHOOSE OF B-cash-desk IN FRAME Dialog-Frame /* Btn 1 */
DO:
  RUN proc-cash-desk IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      ASSIGN
      rs-cash-desk = '*':U.
      DISPLAY
      rs-cash-desk
      WITH FRAME {&frame-name}.
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-cash-desk Dialog-Frame
ON VALUE-CHANGED OF Rs-cash-desk IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-cash-desk.
  CASE rs-cash-desk:
      WHEN '*':U THEN DO:
          DISABLE
          b-cash-desk
          WITH FRAME {&FRAME-NAME}
          .

      END.
      WHEN 'N':U THEN DO:
          ENABLE
          b-cash-desk
          WITH FRAME {&FRAME-NAME}
          .
          APPLY 'CHOSE' TO b-cash-desk.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-desk
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

  RUN fill-table IN THIS-PROCEDURE.
  RUN Myenable.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-region Dialog-Frame 
PROCEDURE display-region :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE buffer buf_clients FOR ub.clients.
DEFINE buffer buf_objects FOR ub.clients.
    assign
    var-region = "Глобально"
    v-host-name = "":U
    for-obj-name = "":U.

    if p-host-code <> 0 then do:
        find first buf_clients No-LOCK WHERE
                buf_clients.obj-type = {&cmp} and
                buf_clients.obj-code = p-host-code No-ERROR.
        ASSIGN
        var-region = "Фирма: "
        v-host-name = buf_Clients.obj-name
        .
    end.
    if p-obj-code <> 0 then do:
        find first buf_objects No-LOCK WHERE
                buf_objects.obj-type = p-obj-type and
                buf_objects.obj-code = p-obj-code No-ERROR.
        ASSIGN
        var-region = "Объект: "
        for-obj-name = buf_objects.obj-name
        .
 end.
 DISPLAY
 var-region
 WITH FRAME {&FRAME-NAME}.
 IF p-host-code <> 0 THEN DO:
     DISPLAY
     v-host-name
     WITH FRAME {&FRAME-NAME}.
 END.
 ELSE DO:
     HIDE
     v-host-name
     IN FRAME {&FRAME-NAME}.
END.
 IF p-obj-code <> 0 THEN DO:
     DISPLAY
     for-obj-name
     WITH FRAME {&FRAME-NAME}.
 END.
 ELSE DO:
     HIDE
     for-obj-name
     IN FRAME {&FRAME-NAME}.
END.

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
  DISPLAY RS-region Rs-cash-desk Rs-is-use var-region v-host-name for-obj-name 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-region b-quit B-Help RS-region BR-cash-desk Rs-cash-desk 
         B-cash-desk Rs-is-use var-region v-host-name for-obj-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame 
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
IF p-host-code = 0
OR p-obj-code = 0 THEN DO:     
    rs-is-use = p-attr-value.
END.
ELSE DO:
    { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
    DO ii = 1 TO NUM-ENTRIES(p-attr-value, {&delim-par}):
        CREATE tt-cash-desk.
        ASSIGN
        rs-is-use = (IF integer(ENTRY(1, ENTRY(ii, p-attr-value, {&delim-par}))) < 0 
                      THEN '-'
                      ELSE '*')
        tt-cash-desk.cash-num = ABS(integer(ENTRY(1, ENTRY(ii, p-attr-value, {&delim-par}))))
        tt-cash-desk.db-num = v-obj-db-num
        tt-cash-desk.obj-code = p-obj-code
        tt-cash-desk.pos-type = ENTRY(2, ENTRY(ii, p-attr-value, {&delim-par}))
        .
   END.
END.

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
rs-region = (if p-host-code = 0
             then 0
             else (if p-obj-type = '':U then 1 else 2)
             )
.

display 
rs-region
rs-is-use
with frame {&frame-name} .
IF rs-region = 2 THEN DO:
  IF CAN-FIND(FIRST tt-cash-desk) THEN DO:
      ASSIGN
      rs-cash-desk= 'N'.
  END.
  ELSE DO:
      ASSIGN
      rs-cash-desk= '*'.
  END.
  DISPLAY
  rs-cash-desk
  WITH FRAME {&FRAME-NAME}.
  ENABLE
  rs-cash-desk
  b-cash-desk
  WITH FRAME {&FRAME-NAME}.
END.
ELSE DO:
  ASSIGN
  rs-cash-desk = '*':U
  .
  DISPLAY
  rs-cash-desk
  WITH FRAME {&FRAME-NAME}.
  DISABLE
  rs-cash-desk
  WITH FRAME {&FRAME-NAME}.

END.
 ENABLE
 B-exit
 RECT-region
 rs-is-use
 b-quit
 B-Help
 BR-cash-desk
 WITH FRAME {&frame-name}.
 VIEW FRAME {&frame-name}.
 RUN display-region IN THIS-PROCEDURE.
 {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cash-desk Dialog-Frame 
PROCEDURE proc-cash-desk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable ii as integer no-undo .
  define buffer buf_cash-desk for ub.cash-desk.
  define buffer buf_tt-cash-desk for tt-cash-desk.
  run ref/cashlist.w (input parparentproc
                ,INPUT "b-sel,b-mark"
                ,INPUT {&g___object}
                ,INPUT v-obj-db-num
                ,INPUT p-host-code
                ,INPUT {&shop}
                ,INPUT p-obj-code
                ,INPUT ?
                ,OUTPUT v-rid-list) NO-ERROR.
  IF error-status:error
  OR v-rid-list = '':U THEN DO:
      RETURN ERROR.
  END.
  for each buf_tt-cash-desk:
    delete buf_tt-cash-desk.
  end.
  do ii = 1 to num-entries(v-rid-list):
    find first buf_cash-desk no-lock where
            recid(buf_cash-desk) = integer(entry(ii, v-rid-list)) no-error .
    if available buf_cash-desk then do:
      if buf_cash-desk.autonomy = integer({&cd-slave}) then do:
        message
        substitute("Касса &1 типа &2 является подчиненной кассой - для нее нельзя установить атрибут&3" +
                   "Пропускаем"
                   , buf_cash-desk.cash-num
                   , buf_cash-desk.pos-type
                   , {&new-line}
                   )
        view-as alert-box WARNING.
      end.
      CREATE buf_tt-cash-desk.
      buffer-copy buf_cash-desk to buf_tt-cash-desk.
    end.
  end.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-dop AS character NO-UNDO.
ASSIGN
FRAME {&frame-name}
rs-region
rs-cash-desk
rs-is-use    
.
IF rs-region = 2
AND rs-cash-desk = 'N':U THEN DO:
    FOR EACH tt-cash-desk:
        ASSIGN
        v-dop = v-dop + (IF v-dop = '':U THEN '':U ELSE {&delim-par}) +
                (IF rs-is-use = '-' THEN '-' ELSE '':U) + string(tt-cash-desk.cash-num) + {&comma-char} + tt-cash-desk.pos-type.
    END.
    if v-dop = '':U then do:
      message
      "Не выбрано ни одной кассы"
      view-as alert-box ERROR.
      undo, return error .
    end.
    assign
    p-attr-value = v-dop
    p-ok = yes
    .
END.
ELSE DO:
    ASSIGN
    p-attr-value = rs-is-use
    p-ok = yes
    .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

