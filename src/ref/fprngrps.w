&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_db FOR ub.db.
DEFINE BUFFER buf_fbr-prn FOR ub.fbr-prn.
DEFINE BUFFER buf_fbr-prn-grp FOR ub.fbr-prn-grp.
DEFINE BUFFER buf_gds-grp FOR ub.gds-grp.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Группы товаров на  принтере кухни

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
/*может быть {&all} или "db":U или "printer":U или "group"*/

define input parameter bttns as character no-undo.
define input parameter p-db-num like ub.fbr-prn.db-num no-undo.
define input parameter p-prn-num like ub.fbr-prn.prn-num no-undo.
define input parameter p-obj-type like ub.fbr-prn-gds.obj-type no-undo.
define input parameter p-obj-code like ub.fbr-prn-gds.obj-code no-undo.
define input parameter p-node-code like ub.fbr-prn-grp.node-code no-undo .
define input-output parameter par-recid as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Группы товаров на  принтере кухни".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ ref/grplibfn.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new}
{ gbl/prn-lib.i }
{ gbl/getcntxt.i def }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-prn-grp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_fbr-prn-grp

/* Definitions for BROWSE BR-prn-grp                                    */
&Scoped-define FIELDS-IN-QUERY-BR-prn-grp buf_fbr-prn-grp.prn-num get-fbr-obj-name(buf_fbr-prn-grp.db-num, buf_fbr-prn-grp.prn-num) get-grp-name(buf_fbr-prn-grp.node-code) buf_fbr-prn-grp.obj-type + string(buf_fbr-prn-grp.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-prn-grp
&Scoped-define SELF-NAME BR-prn-grp
&Scoped-define QUERY-STRING-BR-prn-grp FOR EACH buf_fbr-prn-grp NO-LOCK
&Scoped-define OPEN-QUERY-BR-prn-grp OPEN QUERY {&SELF-NAME} FOR EACH buf_fbr-prn-grp NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-prn-grp buf_fbr-prn-grp
&Scoped-define FIRST-TABLE-IN-QUERY-BR-prn-grp buf_fbr-prn-grp


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-add B-delete B-chg B-print B-help ~
BR-prn-grp

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-fbr-obj-name Dialog-Frame
FUNCTION get-fbr-obj-name RETURNS CHARACTER
  ( input p-db-num as integer, input p-prn-num as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-grp-name Dialog-Frame
FUNCTION get-grp-name RETURNS CHARACTER
  ( p-node-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-obj-name Dialog-Frame
FUNCTION get-obj-name RETURNS CHARACTER
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

DEFINE BUTTON B-delete
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "В&ыход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-prn-grp FOR
      buf_fbr-prn-grp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-prn-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-prn-grp Dialog-Frame _FREEFORM
  QUERY BR-prn-grp NO-LOCK DISPLAY
      buf_fbr-prn-grp.prn-num COLUMN-LABEL "N!пр-ра" FORMAT ">>9":U
      get-fbr-obj-name(buf_fbr-prn-grp.db-num, buf_fbr-prn-grp.prn-num) COLUMN-LABEL "Принтер!установлен" FORMAT "X(11)":U
            WIDTH 12
      get-grp-name(buf_fbr-prn-grp.node-code) COLUMN-LABEL "Группа" FORMAT "X(65)":U
      buf_fbr-prn-grp.obj-type + string(buf_fbr-prn-grp.obj-code) COLUMN-LABEL "Объект!товара" FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-add AT ROW 1 COL 21
     B-delete AT ROW 1 COL 31
     B-chg AT ROW 1 COL 41
     B-print AT ROW 1 COL 61
     B-help AT ROW 1 COL 71
     BR-prn-grp AT ROW 2.5 COL 1
     SPACE(0.24) SKIP(0.40)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы товаров на принтере кухни"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_db B "?" ? ub db
      TABLE: buf_fbr-prn B "?" ? ub fbr-prn
      TABLE: buf_fbr-prn-grp B "?" ? ub fbr-prn-grp
      TABLE: buf_gds-grp B "?" ? ub gds-grp
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-prn-grp B-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-prn-grp
/* Query rebuild information for BROWSE BR-prn-grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fbr-prn-grp NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BR-prn-grp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группы товаров на принтере кухни */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-add in this-procedure no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  run proc-chg in this-procedure no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-delete Dialog-Frame
ON CHOOSE OF B-delete IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical no-undo .
define variable glog as logical no-undo .
define buffer del_fbr-prn-grp for ub.fbr-prn-grp.

if not available buf_fbr-prn-grp then return no-apply.
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


glog = no.
message
"После удаления товары (блюда) данной группы НЕ БУДУТ" skip
"автоматически появляться в списке товаров" skip
"ЭТОГО принтера ( с номером " buf_fbr-prn-grp.prn-num " )" skip
"при появлении их в наличии на объекте" buf_fbr-prn-grp.obj-type buf_fbr-prn-grp.obj-code skip(1)
"Вы уверены ?" skip
" "
view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
FIND del_fbr-prn-grp WHERE recid( del_fbr-prn-grp ) = recid(buf_fbr-prn-grp) exclusive.
delete del_fbr-prn-grp .

RUN OpenBr in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-print in this-procedure no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-prn-grp
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
    CASE par-mode:
      when "printer":U or when "printer-object" then do:
        FIND FIRST buf_fbr-prn no-lock where
                  buf_fbr-prn.db-num = p-db-num
              AND buf_fbr-prn.prn-num = p-prn-num no-error.
        if not available buf_fbr-prn then do:
                  message
                  "Неверное значение параметров p-db-num и/или p-prn-num" p-db-num p-prn-num
                  view-as alert-box error.
                  return error.
        end.
      end.
      when "db":U then do:
        find first buf_db no-lock where
                  buf_db.db-num = p-db-num no-error.
        if not available buf_db then do:
          message
          "Неверное значение параметра p-db-num" p-db-num
          view-as alert-box error.
          return error.
        end.
      end.
      when "group" then do:
        find first buf_gds-grp no-lock where
                    buf_gds-grp.node-code = p-node-code no-error .
        if not available buf_gds-grp then do:
          message
          "Неверное значение параметра p-node-code" p-node-code
          view-as alert-box error.
          return error.
        end.
      end.
      when "object":U or when "printer-object":U then do:
        find first buf_clients no-lock where
                  buf_clients.obj-type = p-obj-type
              AND buf_clients.obj-code = p-obj-code
                    no-error .
        if not available buf_clients then do:
          message
          "Неверное значение параметров p-obj-type и/или p-obj-code" p-obj-type p-obj-code
          view-as alert-box error.
          return error.
        end.
      end.
    END CASE.
  RUN MyEnable in this-procedure .
  run OpenBr in this-procedure .
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
  ENABLE B-exit B-add B-delete B-chg B-print B-help BR-prn-grp
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
ENABLE
B-exit
B-add when par-mode = "printer":U or par-mode = "group"
B-delete when par-mode = "printer":U or par-mode = "group"
b-chg when par-mode = "group"
b-print
B-Help
BR-prn-grp
 WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.

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
define variable title0 as character no-undo .
title0 = "Группы товаров на принтере кухни".

CASE par-mode:
  when "printer":U then do:
    ASSIGN frame {&frame-name}:TITLE = title0 + " Принтер: "+  string(p-prn-num).

    OPEN QUERY BR-prn-grp
    FOR EACH buf_fbr-prn-grp NO-LOCK where
            buf_fbr-prn-grp.prn-num = p-prn-num and
            buf_fbr-prn-grp.db-num = p-db-num .
    end.
    when {&all} then do:
      ASSIGN frame {&frame-name}:TITLE = title0 .
      OPEN QUERY BR-prn-grp
      FOR EACH buf_fbr-prn-grp NO-LOCK .
    end.
    when "db":U then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + " БД: "+  string(p-db-num).
      OPEN QUERY BR-prn-grp
      FOR EACH buf_fbr-prn-grp NO-LOCK where buf_fbr-prn-grp.db-num = p-db-num.
    end.
    when "group":U then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + " Группа товаров: "+  string(p-node-code).
      OPEN QUERY BR-prn-grp
      FOR EACH buf_fbr-prn-grp NO-LOCK where
              buf_fbr-prn-grp.node-code = p-node-code .
    end.
    when "object":U then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + " Объект: "+ p-obj-type + string(p-obj-code).
      OPEN QUERY BR-prn-grp
      FOR EACH buf_fbr-prn-grp NO-LOCK where
              buf_fbr-prn-grp.obj-type = p-obj-type
          AND buf_fbr-prn-grp.obj-code = p-obj-code .
    end.
    when "printer-object":U then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + " Принтер: "+  string(p-prn-num) + " Объект: " + p-obj-type + string(p-obj-code).
      OPEN QUERY BR-prn-grp
      FOR EACH buf_fbr-prn-grp NO-LOCK where
              buf_fbr-prn-grp.prn-num = p-prn-num
          AND buf_fbr-prn-grp.db-num = p-db-num
          AND buf_fbr-prn-grp.obj-type = p-obj-type
          AND buf_fbr-prn-grp.obj-code = p-obj-code .
    end.


END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame
PROCEDURE proc-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-rec as recid no-undo.
define variable loc#log as logical no-undo .

define buffer loc_fbr-prn-grp for ub.fbr-prn-grp.
define buffer loc_gds-grp for ub.fbr-prn.
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

CASE par-mode:
  when "group":U then do:
    run ref/fprngrpi.w (
                   input parparentproc
                  ,input {&add-def}
                  ,input "group":U
                  ,input 0
                  ,input 0
                  ,input "":U
                  ,input 0
                  ,input p-node-code
                  ,input-output v-rec) no-error.
    if error-status:error then return error.
 end.
 when "printer":u then do:
    run ref/fprngrpi.w (
                   input parparentproc
                  ,input {&add-def}
                  ,input "printer":U
                  ,input 0
                  ,input p-prn-num
                  ,input "":U
                  ,input 0
                  ,input 0
                  ,input-output v-rec) no-error.
    if error-status:error then return error.
  end.
END CASE.
RUN OpenBr in this-procedure.
reposition BR-prn-grp to recid v-rec no-error.
APPLY "ENTRY" to br-prn-grp in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chg Dialog-Frame
PROCEDURE proc-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-rec as recid no-undo.
define variable loc#log as logical no-undo .
if not available buf_fbr-prn-grp then return error.
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

run ref/fprngrpi.w (
               input parparentproc
              ,input {&update}
              ,input "":U
              ,input buf_fbr-prn-grp.db-num
              ,input buf_fbr-prn-grp.prn-num
              ,input buf_fbr-prn-grp.obj-type
              ,input buf_fbr-prn-grp.obj-code
              ,input buf_fbr-prn-grp.node-code
              ,input-output v-rec) no-error.
if error-status:error then return error.
reposition BR-prn-grp to recid v-rec no-error.
APPLY "ENTRY" to br-prn-grp in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print Dialog-Frame
PROCEDURE proc-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-fbr-obj-name as character no-undo.
define variable v-obj-name as character no-undo.
define variable v-grp-full as character no-undo.
define variable v-rec as recid no-undo.
define variable LIne as character no-undo.
define variable ii as integer no-undo.
DEFINE FRAME List
buf_fbr-prn-grp.prn-num COLUMN-LABEL "Принтер"
v-fbr-obj-name column-label "Установлен на" format "X(121)"
v-grp-full column-label "Группа" format "X(65)"
v-obj-name column-label "Объект" format "x(8)"
 HEADER
    cur-time-print() AT 5 format "x(35)"
        string( "Страница " + string( PAGE-NUMBER( Prnlibstream ) , ">>9") )
            AT 66 format "X(15)" SKIP
    Line format "x(119)" AT 1
with width {&A4_CW} down use-text stream-io no-box .

if num-results( "BR-prn-grp" ) = 0 then  do:
    message "Список  П У С Т !" skip view-as alert-box information .
    return error .
end.

if session:set-wait-state( "compiler" ) then .
Line = fill( "-" , 1196 ) .
v-rec = recid( buf_fbr-prn-grp ) .
DO WHILE available buf_fbr-prn-grp :
    GET prev br-prn-grp NO-LOCK .
END.
GET next br-prn-grp NO-LOCK .
ii = 1 .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


FORM HEADER
Line format "X(116)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
VIEW stream Prnlibstream FRAME CliBottomFrame .
PUT stream Prnlibstream space(20) frame {&frame-name}:title format "X(80)" SKIP(2) .
FORM with frame List .
DO WHILE available buf_fbr-prn-grp :
    DISPLAY stream Prnlibstream
        buf_fbr-prn-grp.prn-num
        get-fbr-obj-name(buf_fbr-prn-grp.db-num, buf_fbr-prn-grp.prn-num) @ v-fbr-obj-name
        get-grp-name(buf_fbr-prn-grp.node-code) @ v-grp-full
        buf_fbr-prn-grp.obj-type + string(buf_fbr-prn-grp.obj-code) @ v-obj-name
       with frame List .
    DOWN stream Prnlibstream 1
    with frame List .
    ii =  ii + 1 .
    if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
    run waitfram-show in this-procedure ("Просмотрено строк : " + string( ii ) ) .
    GET next br-prn-grp .
END.
PUT stream Prnlibstream Line format "X(116)" SKIP.
HIDE stream Prnlibstream FRAME CliBottomFrame .
output stream Prnlibstream close .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
reposition br-prn-grp to recid v-rec NO-ERROR .
run waitfram-hide in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-fbr-obj-name Dialog-Frame
FUNCTION get-fbr-obj-name RETURNS CHARACTER
  ( input p-db-num as integer, input p-prn-num as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer loc_clients for ub.clients.

CASE par-mode:
    when "printer":U then do:
    end.
    when "db":U or when {&all} then do:
            find first buf_fbr-prn no-lock where
                        buf_fbr-prn.db-num = p-db-num
                    AND buf_fbr-prn.prn-num = p-prn-num no-error.
            if not available buf_fbr-prn then return ?.
    end.
END CASE.
return (buf_fbr-prn.fbr-obj-type + string(buf_fbr-prn.fbr-obj-code)).




END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-grp-name Dialog-Frame
FUNCTION get-grp-name RETURNS CHARACTER
  ( p-node-code as integer) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable v-grp-name as character no-undo.
run grplib-get-full-name in this-procedure(p-node-code, output v-grp-name) no-error.
if length(v-grp-name) >  65 then do:
    overlay( v-grp-name, length(v-grp-name) - 65 + 1, 3) = "...":U.
end.

  RETURN v-grp-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-obj-name Dialog-Frame
FUNCTION get-obj-name RETURNS CHARACTER
  ( input p-obj-type as character, input p-obj-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer loc_clients for ub.clients.
find first loc_clients no-lock where
        buf_clients.obj-type = p-obj-type
    AND loc_clients.obj-code = p-obj-code no-error.
    if available loc_clients then
  RETURN loc_clients.obj-name.   /* Function return value. */
  return (p-obj-type + string(p-obj-code)).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
