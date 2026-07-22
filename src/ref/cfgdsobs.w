&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cli FOR ub.clients.
DEFINE BUFFER for-c-fbr-gds-obj FOR ub.c-fbr-gds-obj.
DEFINE BUFFER X_c-fbr-gds-obj FOR ub.c-fbr-gds-obj.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник истории АТРИБУТА ТОВАРА НА ОБЪЕКТЕ РЕСТОРАН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER bttns  as character  no-undo .
DEFINE INPUT PARAMETER p-mode as character no-undo.
define input parameter p-obj-type like ub.fbr-gds-obj.obj-type no-undo .
define input parameter p-obj-code like ub.fbr-gds-obj.obj-code no-undo .
define input parameter p-gds-code like ub.fbr-gds-obj.gds-code no-undo .
/*{&all} или "one":U*/
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории АТРИБУТА ТОВАРА РЕСТОРАН" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new}
{ str/wth-lib.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable v-rid-list as character no-undo .
define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable jj as integer no-undo .
define variable str as char no-undo.
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable vartbl-name as char no-undo.
define variable varact      as char no-undo.
define variable filter-point0 as character no-undo init "cfgdsobs" .
define variable filter-point as character no-undo init "cfgdsobs" .
define variable filter-label0 as character no-undo init "Справочник_истории_АТРИБУТА_ТОВАРА_РЕСТОРАН" .
define variable filter-label as character no-undo init "Справочник_истории_АТРИБУТА_ТОВАРА_РЕСТОРАН_" .

define variable sort-column-name as character no-undo .
define variable rep-rec as recid no-undo .
define NEW SHARED buffer c-fbr-gds-obj for ub.c-fbr-gds-obj .
define buffer X_fbr-gds-obj for ub.fbr-gds-obj.
{ ref/tmpchgs.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-fbr-gds-obj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-fbr-gds-obj temp-changes

/* Definitions for BROWSE BR-c-fbr-gds-obj                              */
&Scoped-define FIELDS-IN-QUERY-BR-c-fbr-gds-obj mark-string( recid(X_c-fbr-gds-obj), v-rid-list ) X_c-fbr-gds-obj.corr-date usrfulnf(X_c-fbr-gds-obj.corr-user-name) X_c-fbr-gds-obj.is-cd string(X_c-fbr-gds-obj.corr-time, "hh:mm") X_c-fbr-gds-obj.is-menu X_c-fbr-gds-obj.is-modificator X_c-fbr-gds-obj.is-null-price X_c-fbr-gds-obj.is-season X_c-fbr-gds-obj.is-semi-finished X_c-fbr-gds-obj.fbr-obj-code X_c-fbr-gds-obj.fbr-grp-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-fbr-gds-obj X_c-fbr-gds-obj.corr-date
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-c-fbr-gds-obj X_c-fbr-gds-obj
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-c-fbr-gds-obj X_c-fbr-gds-obj
&Scoped-define SELF-NAME BR-c-fbr-gds-obj
&Scoped-define QUERY-STRING-BR-c-fbr-gds-obj FOR EACH X_c-fbr-gds-obj NO-LOCK
&Scoped-define OPEN-QUERY-BR-c-fbr-gds-obj OPEN QUERY {&SELF-NAME} FOR EACH X_c-fbr-gds-obj NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-c-fbr-gds-obj X_c-fbr-gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-fbr-gds-obj X_c-fbr-gds-obj


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-sch B-Help mark-num ~
BR-c-fbr-gds-obj BR-changes
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-c-fbr-gds-obj FOR
      X_c-fbr-gds-obj SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-fbr-gds-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-fbr-gds-obj Dialog-Frame _FREEFORM
  QUERY BR-c-fbr-gds-obj DISPLAY
      mark-string( recid(X_c-fbr-gds-obj), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
X_c-fbr-gds-obj.corr-date COLUMN-LABEL "Дата корр." FORMAT "99/99/9999":U
usrfulnf(X_c-fbr-gds-obj.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
X_c-fbr-gds-obj.is-cd FORMAT "да/нет":U
string(X_c-fbr-gds-obj.corr-time, "hh:mm") COLUMN-LABEL "Время корр."
X_c-fbr-gds-obj.is-menu FORMAT "да/нет":U
X_c-fbr-gds-obj.is-modificator FORMAT "да/нет":U
X_c-fbr-gds-obj.is-null-price FORMAT "да/нет":U
X_c-fbr-gds-obj.is-season FORMAT "да/нет":U
X_c-fbr-gds-obj.is-semi-finished FORMAT "да/нет":U
X_c-fbr-gds-obj.fbr-obj-code FORMAT "99999":U
X_c-fbr-gds-obj.fbr-grp-code COLUMN-LABEL "Внутр код!группы меню" FORMAT "->,>>>,>>9":U
ENABLE
X_c-fbr-gds-obj.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.33.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     mark-num AT ROW 1.92 COL 9 COLON-ALIGNED NO-LABEL
     BR-c-fbr-gds-obj AT ROW 3.42 COL 1
     BR-changes AT ROW 16.04 COL 1
     SPACE(0.24) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник касс"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: for-c-fbr-gds-obj B "?" ? ub c-fbr-gds-obj
      TABLE: X_c-fbr-gds-obj B "?" ? ub c-fbr-gds-obj
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-fbr-gds-obj mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-c-fbr-gds-obj Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-fbr-gds-obj
/* Query rebuild information for BROWSE BR-c-fbr-gds-obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-fbr-gds-obj NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-c-fbr-gds-obj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Справочник касс */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник касс */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
 define variable glog as logical no-undo .
 if not available X_c-fbr-gds-obj then return no-apply.
 { gbl/markstrn.i X_c-fbr-gds-obj v-rid-list }
 glog = br-c-fbr-gds-obj :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
    glog = br-c-fbr-gds-obj:select-next-row () in frame {&frame-name}.
    apply "value-changed" to br-c-fbr-gds-obj in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-c-fbr-gds-obj in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-fbr-gds-obj ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_c-fbr-gds-obj ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-fbr-gds-obj
&Scoped-define SELF-NAME BR-c-fbr-gds-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-fbr-gds-obj Dialog-Frame
ON RETURN OF BR-c-fbr-gds-obj IN FRAME Dialog-Frame
DO:
      apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-fbr-gds-obj Dialog-Frame
ON VALUE-CHANGED OF BR-c-fbr-gds-obj IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-c-fbr-gds-obj" }
{ gbl/brwrefre.i "rep-rec = recid(X_c-fbr-gds-obj). run OpenBr in this-procedure  ( input yes, input no, input '':U). reposition br-c-fbr-gds-obj to recid rep-rec no-error. rep-rec = ?. ~
              APPLY 'ENTRY' to br-c-fbr-gds-obj. APPLY 'VALUE-CHANGED' to br-c-fbr-gds-obj. " }
{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/srt-clmd.i
  &browse-name    = "BR-c-fbr-gds-obj"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-fbr-gds-obj"
  &sort-clmn_1    = "X_c-fbr-gds-obj.corr-date"
  &open-query     = "run OpenBr in this-procedure  ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure  ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}
{ gbl/setfltnm.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  CASE p-mode:
   WHEN "one":U THEN DO:
     find first X_fbr-gds-obj no-lock where
                X_fbr-gds-obj.obj-type = p-obj-type
           AND  X_fbr-gds-obj.obj-code = p-obj-code
           AND  X_fbr-gds-obj.gds-code = p-gds-code
           no-error .
     if not available X_fbr-gds-obj then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров p-obj-type p-obj-code p-gds-code"
        view-as alert-box ERROR.
        return.
     end.
   END.
   otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - p-mode" p-mode
      view-as alert-box ERROR.
      return.
    end.
  end case.
  v-rid-list = p-rid-list.
  RUN MyEnable in this-procedure .
  HIDE mark-num in frame {&frame-name} .
  run OpenBR in this-procedure  ( input yes, input no, input '':U).
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
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num BR-c-fbr-gds-obj BR-changes
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
X_c-fbr-gds-obj.corr-date:READ-ONLY IN BROWSE br-c-fbr-gds-obj = YES
.
DISPLAY
mark-num
br-changes
WITH FRAME {&frame-name}.
ENABLE
B-quit
B-mark when lookup('b-mark':U, bttns) >0
B-sel when lookup('b-sel':U, bttns) >0
B-sch
B-Help
BR-c-fbr-gds-obj
br-changes
mark-num
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .


run waitfram-show in this-procedure ( input "Ждите...").

define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-c-fbr-gds-obj FOR EACH X_c-fbr-gds-obj no-lock

&scop flt-open-dyn_open-query  FOR EACH X_c-fbr-gds-obj

&scop flt-open-query-handle query br-c-fbr-gds-obj:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-mode:
    when "one":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории АТРИБУТА ТОВАРА РЕСТОРАН: объект &1&2 товар &3",
                                                       p-obj-type, p-obj-code, p-gds-code)
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-fbr-gds-obj.obj-code = p-obj-code AND X_c-fbr-gds-obj.obj-type = p-obj-type AND ~
                            X_c-fbr-gds-obj.gds-code = p-gds-code"
            &dyn_where-cond = " substitute('X_c-fbr-gds-obj.obj-code = &1 AND X_c-fbr-gds-obj.obj-type = &2&3&2 AND ~
                            X_c-fbr-gds-obj.gds-code = &4', p-obj-code, ~{&double-quote~}, p-obj-type, p-gds-code ) "
            &use-ind = "  "
            &by = "  "
          }
    end.
END CASE.
apply "entry" to br-c-fbr-gds-obj in frame {&frame-name}.
if rep-rec <> ? then reposition br-c-fbr-gds-obj to recid rep-rec no-error.
if error-status:error then do:
  reposition br-c-fbr-gds-obj to row 1 no-error.
end.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-fbr-gds-obj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .

run waitfram-hide in this-procedure .

APPLY "VALUE-CHANGED":U to br-c-fbr-gds-obj.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
tbl = 'c-fbr-gds-obj'
join-tbl = 'X_c-fbr-gds-obj'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('fbr-obj-code', 'Кухня', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-code', 'Группа меню', 'fbr-gds-grp',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-cd', 'Отсылать на кассу', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-menu', 'Блюдо меню', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-modificator', 'Модификатор блюда', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-null-price', 'Без цены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-season', 'Использовать сезонные коэфф.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-semi-finished', 'Полуфабрикат', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
  run gbl/filter.w ( input parparentproc
                    ,input filter-point + {&delim-par} + filter-label
                    ,input tbl
                    ,input join-tbl
                    ,input fld
                    ,input lab
                    ,input spr
                    ,input dim).
  RUN OpenBr in this-procedure  ( input yes, input no, input '':U).
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-fbr-gds-obj then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

&scop fields-name-list "fbr-grp-code,fbr-obj-code,is-cd,is-menu,is-modificator,is-null-price,is-season,is-semi-finished"


define variable v-label-param as character no-undo .

v-label-param =
  "fbr-grp-code" + {&delim-par} + "Внутр. код группы меню" + {&delim-par} + "" + {&delim-flf}
 + "fbr-obj-code" + {&delim-par} + "Кухня" + {&delim-par} + "" + {&delim-flf}
 + "is-cd" + {&delim-par} + "Отсылать на кассу" + {&delim-par} + "" + {&delim-flf}
 + "is-menu" + {&delim-par} + "Блюдо меню" + {&delim-par} + "" + {&delim-flf}
 + "is-modificator" + {&delim-par} + "Модификатор блюда" + {&delim-par} + "" + {&delim-flf}
 + "is-null-price" + {&delim-par} + "Без цены" + {&delim-par} + "" + {&delim-flf}
 + "is-season" + {&delim-par} + "Использовать сезонный коэфф." + {&delim-par} + "" + {&delim-flf}
 + "is-semi-finished" + {&delim-par} + "Полуфабрикат" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-fbr-gds-obj:handle
                                            ,input  {&table_fbr-gds-obj}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME