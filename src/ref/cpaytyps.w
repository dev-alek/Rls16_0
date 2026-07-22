&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-pay-type FOR ub.c-pay-type.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_pay-type FOR ub.pay-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории видов оплат

Автор: Бахтадзе Наталья Викторовна
Дата создания: 15/03/04
Author: Bakhtadze Natalya
Creation date: 15/03/04

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
define input parameter p-obj-code like ub.pay-type.obj-code no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории видов оплат":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-pay-type

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-cpay-type                                  */
&Scoped-define FIELDS-IN-QUERY-br-cpay-type mark-string(recid(X_c-pay-type), v-rid-list) get-action(X_c-pay-type.action) usrfulnf(X_c-pay-type.corr-user-name) X_c-pay-type.corr-date X_c-pay-type.obj-name X_c-pay-type.obj-code string(X_c-pay-type.corr-time, "HH:MM")
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cpay-type
&Scoped-define SELF-NAME br-cpay-type
&Scoped-define QUERY-STRING-br-cpay-type FOR EACH X_c-pay-type NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-cpay-type OPEN QUERY {&SELF-NAME} FOR EACH X_c-pay-type NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-cpay-type X_c-pay-type
&Scoped-define FIRST-TABLE-IN-QUERY-br-cpay-type X_c-pay-type


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-cpay-type}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-Help br-cpay-type ~
BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer )  FORWARD.

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

DEFINE QUERY br-cpay-type FOR
      X_c-pay-type SCROLLING.
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

DEFINE BROWSE br-cpay-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cpay-type Dialog-Frame _FREEFORM
  QUERY br-cpay-type NO-LOCK DISPLAY
      mark-string(recid(X_c-pay-type), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      get-action(X_c-pay-type.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      usrfulnf(X_c-pay-type.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-pay-type.corr-date COLUMN-LABEL "Дата!измен" FORMAT "99/99/9999":U
      X_c-pay-type.obj-name FORMAT "X(40)":U
      X_c-pay-type.obj-code COLUMN-LABEL "Код вида!оплаты" FORMAT "99999":U
      string(X_c-pay-type.corr-time, "HH:MM") COLUMN-LABEL "Время!измен" FORMAT "X(5)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 61
     B-Help AT ROW 1 COL 95
     br-cpay-type AT ROW 3 COL 1
     BR-changes AT ROW 13 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История видов оплат"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-pay-type B "?" ? ub c-pay-type
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_pay-type B "?" ? ub pay-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-cpay-type B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-cpay-type Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-lookup IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cpay-type
/* Query rebuild information for BROWSE br-cpay-type
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-pay-type NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-cpay-type */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История видов оплат */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История видов оплат */
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
  if available X_c-pay-type then do:
    { gbl/markstrn.i X_c-pay-type v-rid-list }
    loc#log = br-cpay-type:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-cpay-type:select-next-row ().
        apply "VALUE-CHANGED" to br-cpay-type in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-cpay-type in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-pay-type ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-pay-type ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-cpay-type
&Scoped-define SELF-NAME br-cpay-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cpay-type Dialog-Frame
ON RETURN OF br-cpay-type IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-cpay-type IN FRAME Dialog-Frame
    DO:
    run proc-br-cpay-type no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cpay-type Dialog-Frame
ON VALUE-CHANGED OF br-cpay-type IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-cpay-type" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_pay-type). run openbr in this-procedure. reposition br-cpay-type to recid v-doc-rec no-error. ~
              apply 'value-changed' to br-cpay-type.    " }

{ gbl/srt-clmn.i
  &browse-name    = "br-cpay-type"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-pay-type.obj-name"
  &sort-clmn_2    = "X_c-pay-type.corr-date"
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
 if LOOKUP(p-mode, 'one':U,
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 if p-mode = "one":U then do:
  find first X_pay-type no-lock where
                X_pay-type.obj-code = p-obj-code no-error.
    if not available X_pay-type then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-obj-code"
        p-obj-code
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
  REPOSITION br-cpay-type to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-cpay-type"
    &frame-name = "{&frame-name}"
    &ext-col = 7
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7'"
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
  ENABLE b-quit B-mark B-sel B-Help br-cpay-type BR-changes mark-num
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
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-Help
br-cpay-type mark-num
br-changes
with FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY br-cpay-type FOR EACH X_c-pay-type NO-LOCK where
                               X_c-pay-type.obj-code = p-obj-code
                           AND X_c-pay-type.corr-user-db-num = 0
                              INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO br-cpay-type in frame {&frame-name}.
APPLY "ENTRY" TO br-cpay-type.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-cpay-type Dialog-Frame
PROCEDURE proc-br-cpay-type :
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
define buffer new_c-pay-type for ub.c-pay-type.
define buffer current_pay-type for ub.pay-type.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .


for each temp-changes:
    delete temp-changes.
END.
if not available X_c-pay-type then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
&scop fields-name-list "obj-name,obj-code"

define variable v-label-param as character no-undo .

v-label-param =
  "obj-name" + {&delim-par} + "Название" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (X_c-pay-type.action = integer({&hn-create}))
                                            ,input  (X_c-pay-type.action = integer({&hn-delete}))
                                            ,input  buffer X_c-pay-type:handle
                                            ,input  {&table_pay-type}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame 
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  &scop hn-action-code trim(string(p-action))
define variable dops as character no-undo.
assign dops = {&hn-action-name} no-error.



END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

