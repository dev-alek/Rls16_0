&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-cli-hist FOR c-cli-hist.
DEFINE BUFFER X_c-staff FOR c-staff.
DEFINE BUFFER X_curr_clients FOR clients.
DEFINE BUFFER X_staff FOR staff.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории персонала

Автор: Бахтадзе Наталья Викторовна
Дата создания: 17/03/04
Author: Bakhtadze Natalya
Creation date: 17/03/04

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
/*one*/
define input parameter p-role           like ub.staff.role no-undo .
define input parameter p-role-level     like ub.staff.role-level no-undo .
define input parameter p-work-place     like ub.staff.work-place no-undo .
define input parameter p-staff-code     like ub.staff.staff-code no-undo .
define input parameter p-date-start     like ub.staff.date-start no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории персонала":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/getposit.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i  }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-rid-list as character no-undo .

&SCOPED-DEFINE role-level-code string(X_c-staff.role-level)

{ ref/tmpchgs.i " " " " "with-action" }

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-staff

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-cstaff                                     */
&Scoped-define FIELDS-IN-QUERY-br-cstaff mark-string(recid(X_c-staff), v-rid-list) usrfulnf(X_c-staff.corr-user-name) X_c-staff.corr-date string(X_c-staff.corr-time, "HH:MM") gbclcode-get-position ( input X_c-staff.role ,input X_c-staff.role-level ,input X_c-staff.work-place ,input X_c-staff.staff-code ) get-action-from-c-cli(X_c-staff.psn-code, X_c-staff.corr-user-db-num, X_c-staff.chip-num) X_c-staff.psn-code X_c-staff.date-start   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cstaff   
&Scoped-define SELF-NAME br-cstaff
&Scoped-define QUERY-STRING-br-cstaff FOR EACH X_c-staff NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-cstaff OPEN QUERY {&SELF-NAME} FOR EACH X_c-staff NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-cstaff X_c-staff
&Scoped-define FIRST-TABLE-IN-QUERY-br-cstaff X_c-staff


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-cstaff}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-Help br-cstaff ~
BR-changes mark-num 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame 
FUNCTION get-action RETURNS CHARACTER
  ( INPUT p-action AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action-from-c-cli Dialog-Frame 
FUNCTION get-action-from-c-cli RETURNS CHARACTER
  ( INPUT p-psn-code AS INTEGER, INPUT p-corr-user-db-num AS INTEGER, INPUT p-chip-num AS INTEGER )  FORWARD.

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

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY br-cstaff FOR 
      X_c-staff SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.04.

DEFINE BROWSE br-cstaff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cstaff Dialog-Frame _FREEFORM
  QUERY br-cstaff NO-LOCK DISPLAY
      mark-string(recid(X_c-staff), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
usrfulnf(X_c-staff.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
X_c-staff.corr-date COLUMN-LABEL "Дата!измен" FORMAT "99/99/9999":U
string(X_c-staff.corr-time, "HH:MM") COLUMN-LABEL "Время!измен" FORMAT "X(5)":U
gbclcode-get-position ( input X_c-staff.role
                        ,input X_c-staff.role-level
                        ,input X_c-staff.work-place
                         ,input X_c-staff.staff-code )
COLUMN-LABEL "Работает" FORMAT "X(34)":U WIDTH 34
get-action-from-c-cli(X_c-staff.psn-code, X_c-staff.corr-user-db-num, X_c-staff.chip-num) COLUMN-LABEL "Действие" FORMAT "X(10)":U
X_c-staff.psn-code COLUMN-LABEL "Код физ.лица" FORMAT ">>>>>>>>9"
X_c-staff.date-start FORMAT "99/99/9999":U COLUMN-LABEL "Работает с"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 61
     B-Help AT ROW 1 COL 95
     br-cstaff AT ROW 3 COL 1
     BR-changes AT ROW 13 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История персонала"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-cli-hist B "?" ? ub c-cli-hist
      TABLE: X_c-staff B "?" ? ub c-staff
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_staff B "?" ? ub staff
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-cstaff B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-cstaff Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-lookup IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       br-cstaff:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cstaff
/* Query rebuild information for BROWSE br-cstaff
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-staff NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-cstaff */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История персонала */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История персонала */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_c-staff then do:
    { gbl/markstrn.i X_c-staff v-rid-list }
    loc#log = br-cstaff:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-cstaff:select-next-row ().
        apply "VALUE-CHANGED" to br-cstaff in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-cstaff in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-staff ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-staff ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-cstaff
&Scoped-define SELF-NAME br-cstaff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cstaff Dialog-Frame
ON RETURN OF br-cstaff IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-cstaff IN FRAME Dialog-Frame
    DO:
    run proc-br-cstaff no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cstaff Dialog-Frame
ON VALUE-CHANGED OF br-cstaff IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-cstaff" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-staff). run OpenBr in this-procedure. reposition br-cstaff to recid v-doc-rec no-error. v-doc-rec = ?. ~
             apply 'value-changed' to br-cstaff. " }
{ gbl/srt-clmn.i
  &browse-name    = "br-cstaff"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-staff.corr-date"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
/*  find first X_curr_clients no-lock where                     */
/*            X_curr_clients.obj-type = p-curr-obj-type         */
/*       AND X_curr_clients.obj-code = p-curr-obj-code no-error.*/
/* if LOOKUP(p-mode, 'one':U,                                   */
/*                {&delim-par}) = 0                             */
/*     then dO:                                                 */
/*    message                                                   */
/*    vss-workfile vss-revision vss-description skip            */
/*    "Неверное значение параметров вызова p-mode"              */
/*    p-mode                                                    */
/*    view-as alert-box ERROR.                                  */
/*    return error .                                            */
/* end.                                                         */
 if p-mode = "one":U then do:
  find first X_staff no-lock where
                X_staff.role = p-role no-error.
    if not available X_staff then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-role"
        p-role
        view-as alert-box ERROR.
        return.
    end.
  end.
  v-rid-list = p-rid-list.
 { gbl/curdbnum.i v-db-num }
  RUN MyEnable.
  RUn OpenBR.
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-cstaff to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-cstaff"
    &frame-name = "{&frame-name}"
    &ext-col = 6
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6'"
    &prev-order-column-condition_1 = " p-mode = ~'one' "
    }
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
  run diasize_init in this-procedure .
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
  DISPLAY mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-Help br-cstaff BR-changes mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
assign
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
DISPLAY mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-Help
br-cstaff
mark-num
br-changes
with FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
CASE p-mode:
    WHEN 'one':U THEN DO:
      assign
      frame {&frame-name}:title = substitute("&1 &2"
                                              , frame {&frame-name}:title
                                              , gbclcode-get-position ( input p-role
                                                                       ,input p-role-level
                                                                       ,input p-work-place
                                                                       ,input p-staff-code ))
      .
      OPEN QUERY br-cstaff
      FOR EACH X_c-staff NO-LOCK where
          X_c-staff.role = p-role
      AND X_c-staff.role-level = p-role-level
      AND X_c-staff.work-place = p-work-place
      AND X_c-staff.staff-code = p-staff-code
      AND X_c-staff.date-start = p-date-start INDEXED-REPOSITION.
    END.
END CASE.
APPLY "VALUE-CHANGED" TO br-cstaff in frame {&frame-name}.
APPLY "ENTRY" TO br-cstaff.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-cstaff Dialog-Frame 
PROCEDURE proc-br-cstaff :
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
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer next_c-staff for ub.c-staff.
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-staff then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

find first buf_c-cli-hist no-lock where
          buf_c-cli-hist.obj-type = {&prs}
      and buf_c-cli-hist.obj-code = X_c-staff.psn-code
      and buf_c-cli-hist.corr-user-db-num = X_c-staff.corr-user-db-num
      and buf_c-cli-hist.chip-num = X_c-staff.chip-num no-error .
if not available buf_c-cli-hist then do:
  /*
  find first next_c-staff no-lock where
            next_c-staff.role = X_c-staff.role
        and next_c-staff.role-level = X_c-staff.role-level
        and next_c-staff.work-place = X_c-staff.work-place
        and next_c-staff.staff-code = X_c-staff.staff-code
        and next_c-staff.date-start = X_c-staff.date-start
        and next_c-staff.corr-user-db-num = X_c-staff.corr-user-db-num
        and next_c-staff.chip-num = X_c-staff.chip-num no-error
  find first buf_c-cli-hist no-lock where
            buf_c-cli-hist.obj-type = {&prs}
        and buf_c-cli-hist.obj-code = X_staff.psn-code
        and buf_c-cli-hist.corr-user-db-num = X_c-staff.corr-user-db-num
        and buf_c-cli-hist.chip-num = X_c-staff.chip-num no-error .*/
  message
  "Неверная ссылка на c-cli-hist в таблице c-staff"
  view-as alert-box error.
end.
else do:
  &scop fields-name-list "date-end"

  define variable v-label-param as character no-undo .

  v-label-param =
    "date-end" + {&delim-par} + "По" + {&delim-par} + ""  .
  run proc-full-temp-changes in this-procedure (
                                               input buf_c-cli-hist.action = integer({&hn-create})
                                              ,input buf_c-cli-hist.action = integer({&hn-delete})
                                              ,input  buffer X_c-staff:handle
                                              ,input  {&table_staff}
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end.

Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame 
FUNCTION get-action RETURNS CHARACTER
  ( INPUT p-action AS integer ) :

  &scop hn-action-code trim(string(p-action))
define variable dops as character no-undo.
assign dops = {&hn-action-name} no-error.

RETURN dops.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action-from-c-cli Dialog-Frame 
FUNCTION get-action-from-c-cli RETURNS CHARACTER
  ( INPUT p-psn-code AS INTEGER, INPUT p-corr-user-db-num AS INTEGER, INPUT p-chip-num AS INTEGER ) :
define buffer buf_c-cli-hist for ub.c-cli-hist.
find first buf_c-cli-hist no-lock where
          buf_c-cli-hist.obj-type = {&prs}
      and buf_c-cli-hist.obj-code = p-psn-code
      and buf_c-cli-hist.corr-user-db-num = p-corr-user-db-num
      and buf_c-cli-hist.chip-num = p-chip-num no-error .
IF AVAILABLE buf_c-cli-hist  THEN DO:
    RETURN get-action(buf_c-cli-hist.action).
END.
RETURN {&question-mark}.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

