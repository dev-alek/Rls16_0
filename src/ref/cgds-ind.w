&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-gds-hist FOR ub.c-gds-hist.
DEFINE BUFFER x_c-gds-obj-prop FOR ub.c-gds-obj-prop.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER x_gds-obj-prop FOR ub.gds-obj-prop.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории индикаторов товара на объекте

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/28/05
*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-gds-code like ub.gds-obj-prop.gds-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input-output param p-rid-list    as  char no-undo .
define variable bttns  as char   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории индикаторов товара на объекте":U.
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/usrfulnf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.



{ ref/tmpchgs.i "NEW SHARED"}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes X_c-gds-hist

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-gdsind                                     */
&Scoped-define FIELDS-IN-QUERY-br-gdsind get-subject(X_c-gds-hist.subject) x_c-gds-hist.corr-date string(X_c-gds-hist.corr-time, "HH:MM") x_c-gds-hist.corr-user-db-num usrfulnf(x_c-gds-hist.corr-user-name)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-gdsind   
&Scoped-define SELF-NAME br-gdsind
&Scoped-define QUERY-STRING-br-gdsind FOR EACH X_c-gds-hist NO-LOCK  INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-gdsind OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-hist NO-LOCK  INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-gdsind X_c-gds-hist
&Scoped-define FIRST-TABLE-IN-QUERY-br-gdsind X_c-gds-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-gdsind}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-Help br-gdsind BR-changes 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-subject Dialog-Frame 
FUNCTION get-subject RETURNS CHARACTER
    ( p-subject as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-c-gds-obj-prop FOR c-gds-obj-prop, input mark-list as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY br-gdsind FOR 
      X_c-gds-hist SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(255)" WIDTH 45
temp-changes.v_old COLUMn-LABEL "Было" format "X(255)" WIDTH 45
temp-changes.v_new COLUMn-LABEL "Стало" format "X(255)" WIDTH 45
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.53
         TITLE?.

DEFINE BROWSE br-gdsind
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-gdsind Dialog-Frame _FREEFORM
  QUERY br-gdsind NO-LOCK DISPLAY
      get-subject(X_c-gds-hist.subject) COLUMN-LABEL "Предмет изменений" FORMAT "X(45)":U 
  x_c-gds-hist.corr-date COLUMN-LABEL "Дата !изменения" FORMAT "99/99/99":U
        WIDTH 11
  string(X_c-gds-hist.corr-time, "HH:MM") COLUMN-LABEL "Время!измен" FORMAT "X(5)":U
  x_c-gds-hist.corr-user-db-num COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
        WIDTH 3
  usrfulnf(x_c-gds-hist.corr-user-name) COLUMN-LABEL "Кто!изменил" FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10 ROW-HEIGHT-CHARS .75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14
     B-lookup AT ROW 1 COL 35.5
     B-Help AT ROW 1 COL 95
     br-gdsind AT ROW 2.27 COL 1
     BR-changes AT ROW 12.5 COL 1
     SPACE(0.12) SKIP(0.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История индикаторов товаров на объекте"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-gds-hist B "?" ? ub c-gds-hist
      TABLE: x_c-gds-obj-prop B "?" ? ub c-gds-obj-prop
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: x_gds-obj-prop B "?" ? ub gds-obj-prop
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-gdsind B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-gdsind Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-lookup IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-mark:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-sel:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-gdsind
/* Query rebuild information for BROWSE br-gdsind
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-hist NO-LOCK  INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-gdsind */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История индикаторов товаров на объекте */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-gdsind
&Scoped-define SELF-NAME br-gdsind
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-gdsind Dialog-Frame
ON RETURN OF br-gdsind IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-gdsind IN FRAME Dialog-Frame
    DO:
    run proc-br-gdsind no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-gdsind Dialog-Frame
ON VALUE-CHANGED OF br-gdsind IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  find first X_gds-obj-prop no-lock where
             X_gds-obj-prop.obj-type = p-obj-type and
             X_gds-obj-prop.obj-code = p-obj-code and
             X_gds-obj-prop.gds-code = p-gds-code
             no-error.
    if not available X_gds-obj-prop then do:
        message
        "Нет истории по товару gds-code "  p-gds-code skip
        "на объекте " p-obj-type   p-obj-code
        view-as alert-box ERROR.
        return.
    end.

 { gbl/curdbnum.i v-db-num }
  RUN MyEnable.
  RUn OpenBR.
  if v-doc-rec <> ? then
  REPOSITION br-gdsind to recid v-doc-rec No-ERROR.

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
  ENABLE b-quit B-Help br-gdsind BR-changes 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
ASSIGN
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
 br-changes:TITLE IN FRAME {&FRAME-NAME}  = "":U
.
ENABLE
b-quit
B-Help
br-gdsind
with FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
OPEN QUERY br-gdsind 
FOR EACH X_c-gds-hist NO-LOCK WHERE X_c-gds-hist.gds-code = p-gds-code
   AND (X_c-gds-hist.subject = {&table_gds-obj-prop}
        OR
        X_c-gds-hist.subject = {&table_gds-obj-prop-attr}
        ) 
    BY X_c-gds-hist.gds-code
    BY X_c-gds-hist.corr-date
    BY X_c-gds-hist.corr-time
    INDEXED-REPOSITION
.        
        .
APPLY "VALUE-CHANGED" TO br-gdsind in frame {&frame-name}.
APPLY "ENTRY" TO br-gdsind.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-gdsind Dialog-Frame 
PROCEDURE proc-br-gdsind :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
DEFINE VARIABLE v-description AS CHARACTER NO-UNDO.
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-gds-hist then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
run ref/cgdshisv.p (
                   input X_c-gds-hist.gds-code
                  ,input X_c-gds-hist.chip-num
                  ,input X_c-gds-hist.corr-user-db-num
                  ,input X_c-gds-hist.host-code
                  ,input X_c-gds-hist.obj-type
                  ,input X_c-gds-hist.obj-code
                  ,input X_c-gds-hist.subject
                  ,input X_c-gds-hist.action
                  ,input no /*p-silent*/
                  ,input "":U /*p-log-file*/
                  ,output v-description
               ) no-error .

Open QUery br-changes for each temp-changes.

assign
br-changes:title in frame {&frame-name} = v-description
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-subject Dialog-Frame 
FUNCTION get-subject RETURNS CHARACTER
    ( p-subject as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-gds-hist-code p-subject
  RETURN {&hn-gds-hist-name}.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-c-gds-obj-prop FOR c-gds-obj-prop, input mark-list as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
RETURN ( IF LOOKUP( STRING( RECID( loc-c-gds-obj-prop ) ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

