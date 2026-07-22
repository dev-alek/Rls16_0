&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_fbr-prn FOR ub.fbr-prn.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список принтеров кухни

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/22/03
Author: Bakhtadze Natalya
Creation date: 08/22/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
/*может быть {&all} или "db":U */
define input parameter p-db-num like ub.fbr-prn.db-num no-undo.
define input parameter bttns as character no-undo.
define input-output parameter par-recid       as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список принтеров кухни".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

define variable v-db-num like ub.db.db-num no-undo.
define variable v-doc-rec as recid no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-prn

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_fbr-prn

/* Definitions for BROWSE BR-prn                                        */
&Scoped-define FIELDS-IN-QUERY-BR-prn buf_fbr-prn.prn-num buf_fbr-prn.db-num buf_fbr-prn.prn-name buf_fbr-prn.prn-type buf_fbr-prn.fbr-obj-type + string(buf_fbr-prn.fbr-obj-code) get-object-name(buf_fbr-prn.fbr-obj-type, buf_fbr-prn.fbr-obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-prn
&Scoped-define SELF-NAME BR-prn
&Scoped-define QUERY-STRING-BR-prn FOR EACH buf_fbr-prn NO-LOCK
&Scoped-define OPEN-QUERY-BR-prn OPEN QUERY {&SELF-NAME} FOR EACH buf_fbr-prn NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-prn buf_fbr-prn
&Scoped-define FIRST-TABLE-IN-QUERY-BR-prn buf_fbr-prn


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-sel B-add B-del B-chg B-grp B-gds ~
B-Help BR-prn

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-object-name Dialog-Frame
FUNCTION get-object-name RETURNS CHARACTER
  ( input p-obj-type as character, input p-obj-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-gds
     LABEL "&Товары"
     SIZE 10 BY 1.

DEFINE BUTTON B-grp
     LABEL "&Группы"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-prn FOR
      buf_fbr-prn SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-prn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-prn Dialog-Frame _FREEFORM
  QUERY BR-prn DISPLAY
      buf_fbr-prn.prn-num FORMAT ">>9":U
      buf_fbr-prn.db-num FORMAT ">>>>9":U
      buf_fbr-prn.prn-name FORMAT "X(40)":U
      buf_fbr-prn.prn-type FORMAT "X(8)":U
      buf_fbr-prn.fbr-obj-type + string(buf_fbr-prn.fbr-obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
      get-object-name(buf_fbr-prn.fbr-obj-type, buf_fbr-prn.fbr-obj-code) COLUMN-LABEL "производства" FORMAT "X(20)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.13 BY 18.42.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     B-del AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-grp AT ROW 1 COL 61
     B-gds AT ROW 1 COL 71
     B-Help AT ROW 1 COL 81
     BR-prn AT ROW 2.88 COL 1
     SPACE(0.11) SKIP(0.73)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Принтера кухни"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_fbr-prn B "?" ? ub fbr-prn
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-prn B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-prn
/* Query rebuild information for BROWSE BR-prn
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fbr-prn NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-prn */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Принтера кухни */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable v-recid as recid no-undo.
  define variable loc#log as logical no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fbr-prn_work':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  loc#log
  }
  if not loc#log then return no-apply.
  run ref/fbr-prni.w ( input parparentproc
                      ,input {&add-def}
                      ,input v-db-num
                      ,input 0
                      ,output v-recid).
  if v-recid <> ? then do:
      assign
      par-recid = v-recid.
      run openBr in this-procedure.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable v-recid as recid no-undo.
define variable loc#log as logical no-undo .
if not available buf_fbr-prn then return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_fbr-prn_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
loc#log
}

if not loc#log then return no-apply.
run ref/fbr-prni.w ( input parparentproc
                    ,input {&update}
                    ,input buf_fbr-prn.db-num
                    ,input buf_fbr-prn.prn-num
                    ,output v-recid).
run openBr in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define buffer del_fbr-prn for ub.fbr-prn.
define variable loc#log as logical no-undo .
if not available buf_fbr-prn then return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_fbr-prn_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
loc#log
}
if not loc#log then return no-apply.
find first del_fbr-prn exclusive-lock where
            recid(del_fbr-prn) = recid(buf_fbr-prn) no-error.
if not available del_fbr-prn then return no-apply.
delete del_fbr-prn.
run openbr in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dialog-Frame
ON CHOOSE OF B-gds IN FRAME Dialog-Frame /* Товары */
DO:
  define variable v-recid as recid no-undo.
  if not available buf_fbr-prn then return no-apply.
  run ref/fprngdss.w (
                  input parparentproc
                 ,input "printer":U
                 ,input bttns
                 ,input buf_fbr-prn.db-num
                 ,input buf_fbr-prn.prn-num
                 ,input "":U
                 ,input 0
                 ,input 0
                 ,input-output v-recid
                 ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-grp Dialog-Frame
ON CHOOSE OF B-grp IN FRAME Dialog-Frame /* Группы */
DO:
define variable v-recid as recid no-undo.
  if not available buf_fbr-prn then return no-apply.
  run ref/fprngrps.w (
                  input parparentproc
                 ,input "printer":U
                 ,input bttns
                 ,input buf_fbr-prn.db-num
                 ,input buf_fbr-prn.prn-num
                 ,input "":U
                 ,input 0
                 ,input 0
                 ,input-output v-recid
                 ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
      if ( available buf_fbr-prn ) then
        par-recid =  recid( buf_fbr-prn )  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-prn
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/brwrepos.i
&line-num=5 }
{ gbl/brwrefre.i "v-doc-rec = recid(buf_fbr-prn). run openbr in this-procedure. reposition br-prn to recid(v-doc-rec). v-doc-rec = ? . " }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN MyEnable.
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
  ENABLE B-exit B-sel B-add B-del B-chg B-grp B-gds B-Help BR-prn
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
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
{ gbl/curdbnum.i v-db-num no-error}
ENABLE
B-exit
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when v-db-num = p-db-num
B-del when v-db-num = p-db-num
B-chg when v-db-num = p-db-num
B-Help
b-grp
b-gds
BR-prn
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
run Openbr in this-procedure .

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
CASE par-mode:
    when {&all} then do:
    Open query br-prn for each buf_fbr-prn no-lock.
    end.
    when "db":U then do:
        Open query br-prn for each buf_fbr-prn no-lock where buf_fbr-prn.db-num = p-db-num.
    end.
END CASE.
if par-recid <> ? then do:
    reposition br-prn to recid par-recid no-error.
end.
APPLY "ENTRY" to br-prn in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-object-name Dialog-Frame
FUNCTION get-object-name RETURNS CHARACTER
  ( input p-obj-type as character, input p-obj-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
         AND buf_clients.obj-code = p-obj-code no-error.
if available buf_clients then do:
    return buf_clients.obj-name.
end.

  RETURN (p-obj-type + string(p-obj-code)).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
