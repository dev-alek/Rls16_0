&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER loc_fbr-prn FOR ub.fbr-prn.
DEFINE TEMP-TABLE tt-fbr-prn NO-UNDO LIKE ub.fbr-prn.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Принтер кухни

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/22/03
Author: Bakhtadze Natalya
Creation date: 08/22/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
define input parameter p-db-num like ub.fbr-prn.db-num no-undo.
define input parameter p-prn-num like ub.fbr-prn.prn-num no-undo.
define output parameter par-recid as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Принтер кухни".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define variable v-db-num like ub.db.db-num no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fbr-prn

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-fbr-prn.prn-num ~
tt-fbr-prn.prn-name tt-fbr-prn.prn-type tt-fbr-prn.fbr-obj-type ~
tt-fbr-prn.fbr-obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-fbr-prn.prn-num ~
tt-fbr-prn.prn-name tt-fbr-prn.prn-type tt-fbr-prn.fbr-obj-type ~
tt-fbr-prn.fbr-obj-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-fbr-prn
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-fbr-prn

&Scoped-define FIELD-PAIRS-IN-QUERY-Dialog-Frame~
 ~{&FP1}prn-num ~{&FP2}prn-num ~{&FP3}~
 ~{&FP1}prn-name ~{&FP2}prn-name ~{&FP3}~
 ~{&FP1}fbr-obj-type ~{&FP2}fbr-obj-type ~{&FP3}~
 ~{&FP1}fbr-obj-code ~{&FP2}fbr-obj-code ~{&FP3}
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-fbr-prn SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-fbr-prn
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-fbr-prn


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-fbr-prn.prn-num tt-fbr-prn.prn-name ~
tt-fbr-prn.prn-type tt-fbr-prn.fbr-obj-type tt-fbr-prn.fbr-obj-code
&Scoped-define FIELD-PAIRS~
 ~{&FP1}prn-num ~{&FP2}prn-num ~{&FP3}~
 ~{&FP1}prn-name ~{&FP2}prn-name ~{&FP3}~
 ~{&FP1}fbr-obj-type ~{&FP2}fbr-obj-type ~{&FP3}~
 ~{&FP1}fbr-obj-code ~{&FP2}fbr-obj-code ~{&FP3}
&Scoped-define ENABLED-TABLES tt-fbr-prn
&Scoped-define FIRST-ENABLED-TABLE tt-fbr-prn
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-Help B-shop fbr-obj-name
&Scoped-Define DISPLAYED-FIELDS tt-fbr-prn.prn-num tt-fbr-prn.prn-name ~
tt-fbr-prn.prn-type tt-fbr-prn.fbr-obj-type tt-fbr-prn.fbr-obj-code
&Scoped-Define DISPLAYED-OBJECTS fbr-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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

DEFINE BUTTON B-shop
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 2"
     SIZE 3 BY 1.

DEFINE VARIABLE fbr-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 32.38 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-fbr-prn SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     tt-fbr-prn.prn-num AT ROW 3.5 COL 16.75 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN
          SIZE 5.13 BY 1
     tt-fbr-prn.prn-name AT ROW 5.42 COL 17 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 46.25 BY 1
     B-shop AT ROW 7.42 COL 37.5
     tt-fbr-prn.prn-type AT ROW 10.38 COL 19.13 NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
          SIZE 17.38 BY 3.17
     tt-fbr-prn.fbr-obj-type AT ROW 7.54 COL 21.25 COLON-ALIGNED
          LABEL "Объект производства"
           VIEW-AS TEXT
          SIZE 4 BY .67
     tt-fbr-prn.fbr-obj-code AT ROW 7.58 COL 27 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 7 BY .67
     fbr-obj-name AT ROW 8.83 COL 16.75 COLON-ALIGNED NO-LABEL
     "Тип" VIEW-AS TEXT
          SIZE 7.38 BY .83 AT ROW 10.46 COL 10.5
     SPACE(53.11) SKIP(3.58)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Принтер кухни"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: loc_fbr-prn B "?" ? ub fbr-prn
      TABLE: tt-fbr-prn T "?" NO-UNDO ub fbr-prn
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-fbr-prn.fbr-obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fbr-prn.fbr-obj-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fbr-prn.prn-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fbr-prn.prn-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-fbr-prn"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Принтер кухни */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save-prn in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-shop Dialog-Frame
ON CHOOSE OF B-shop IN FRAME Dialog-Frame /* Btn 2 */
DO:
  define buffer b-clients for ub.clients .

  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
    return no-apply .
  end.

  find first b-clients no-lock
    where b-clients.obj-type = v-obj-type
      and b-clients.obj-code = v-obj-code
    no-error .
  if not available b-clients
  then do:
    return no-apply .
  end.
  assign
    fbr-obj-name:screen-value            = b-clients.obj-name
    tt-fbr-prn.fbr-obj-code:screen-value = string(b-clients.obj-code)
    tt-fbr-prn.fbr-obj-type:screen-value = string(b-clients.obj-type)
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
  { gbl/getcntxt.i get }
  { gbl/curdbnum.i v-db-num }
    if v-db-num <> p-db-num then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-db-num" p-db-num
        view-as alert-box error.
        return error.
    end.
  if par-mode <> {&update} and par-mode <> {&add-def} then do:
    message
    vss-workfile vss-revision vss-description skip
     "Неверный параметр вызова par-mode"
    view-as alert-box ERROR.
    return error.
  end.
  run fill-tables in this-procedure .
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY fbr-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fbr-prn THEN
    DISPLAY tt-fbr-prn.prn-num tt-fbr-prn.prn-name tt-fbr-prn.prn-type
          tt-fbr-prn.fbr-obj-type tt-fbr-prn.fbr-obj-code
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help tt-fbr-prn.prn-num tt-fbr-prn.prn-name B-shop
         tt-fbr-prn.prn-type tt-fbr-prn.fbr-obj-type tt-fbr-prn.fbr-obj-code
         fbr-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-prn-num like ub.fbr-prn.prn-num no-undo.
define buffer last_fbr-prn for ub.fbr-prn.
CASE par-mode:
    when {&add-def} then do:
        find last last_fbr-prn no-lock where
                     last_fbr-prn.db-num = p-db-num use-index pi no-error.
        if available last_fbr-prn then do:
            assign
            v-prn-num = last_fbr-prn.prn-num + 1
            .
        end.
        else do:
            assign
            v-prn-num = 1
            .
        end.
        create tt-fbr-prn.
        assign
        tt-fbr-prn.db-num = p-db-num
        tt-fbr-prn.prn-num = v-prn-num
        .
    end.
    when {&update} then do:
        find first loc_fbr-prn exclusive-lock where
                    loc_fbr-prn.db-num = p-db-num
                AND loc_fbr-prn.prn-num = p-prn-num no-error.
        if not available loc_fbr-prn then do:
            return error.
        end.
        assign
                par-recid = recid(loc_fbr-prn)
                .
        create tt-fbr-prn.
        buffer-copy loc_fbr-prn to tt-fbr-prn.
    end.

END CASE.

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
define buffer buf_clients for ub.clients.

find first buf_clients no-lock where
                     buf_clients.obj-type = loc_fbr-prn.fbr-obj-type
                AND buf_clients.obj-code = loc_fbr-prn.fbr-obj-code no-error.
if available buf_clients then do:
    assign
    fbr-obj-name = buf_clients.obj-name
    .
end.
assign
tt-fbr-prn.prn-type:list-items in frame {&frame-name} = "TM230"
.
assign
frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} + par-mode
.
if par-mode = {&update} then do:
  assign
  frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} + string(tt-fbr-prn.prn-num)
  .
end.

DISPLAY
fbr-obj-name
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-fbr-prn THEN
DISPLAY
tt-fbr-prn.prn-num
tt-fbr-prn.prn-name
tt-fbr-prn.prn-type
tt-fbr-prn.fbr-obj-type
tt-fbr-prn.fbr-obj-code
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-exit
B-Help
tt-fbr-prn.prn-num when par-mode = {&add-def}
tt-fbr-prn.prn-name
B-shop
tt-fbr-prn.prn-type
tt-fbr-prn.fbr-obj-type
tt-fbr-prn.fbr-obj-code
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-prn Dialog-Frame
PROCEDURE proc-save-prn :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if par-mode = {&add-def} then
assign
frame {&frame-name} tt-fbr-prn.prn-num
.
assign
tt-fbr-prn.fbr-obj-code = integer(tt-fbr-prn.fbr-obj-code:screen-value)
tt-fbr-prn.fbr-obj-type = tt-fbr-prn.fbr-obj-type:screen-value
tt-fbr-prn.prn-name
tt-fbr-prn.prn-type
.

run ref/fbrprn01.p (
                        input-output par-recid
                       ,input par-mode
                       ,input tt-fbr-prn.db-num
                       ,input tt-fbr-prn.prn-num
                       ,input tt-fbr-prn.prn-type
                       ,input tt-fbr-prn.prn-name
                       ,input tt-fbr-prn.fbr-obj-type
                       ,input tt-fbr-prn.fbr-obj-code
                       ) no-error.
if error-status:error then do:
    return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME