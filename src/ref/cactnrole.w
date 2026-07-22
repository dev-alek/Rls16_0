&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER for-c-action-role FOR ub.c-action-role.
DEFINE BUFFER X_c-action-role   FOR ub.c-action-role.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История групп прав

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/16/06
Author: Bakhtadze Natalya
Creation date: 01/16/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER bttns  as character  no-undo .
DEFINE INPUT PARAMETER parref-mode as character no-undo.
/*{&all} или "one":U или "one-subject"*/
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */
DEFINE INPUT PARAMETER pardb-num like ub.sys-ctrl.db-num no-undo.
define input parameter parhead-code like ub.action-role.action-head-code no-undo .
define input parameter parrole-code like ub.action-role.action-role-code no-undo .
define input parameter p-subject   like ub.c-action-role.subject no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "История групп прав" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new}
{ str/wth-lib.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i  }
{ gbl/fltopend.i defproc }
define variable log-res          as log       no-undo.
define variable rr               as recid     no-undo.
define variable jj               as integer   no-undo .
define variable str              as char      no-undo.
define variable conf-par         as char      no-undo.                  /* для чтения параметра конфигурации */
define variable par-type         as char      no-undo.
define variable vartbl-name      as char      no-undo.
define variable varact           as char      no-undo.
DEFINE VARIABLE parstock         like ub.wth-pobj.income-pl no-undo .
define variable filter-point0    as character no-undo init "cactnrole" .
define variable filter-point     as character no-undo init "cactnrole" .
define variable filter-label0    as character no-undo init "Справочник_истории_групп_прав" .
define variable filter-label     as character no-undo init "Справочник_истории_групп_прав" .
define variable v-rid-list       as character no-undo .
define variable sort-column-name as character no-undo .
define variable v-doc-rec        as recid     no-undo .
define buffer X_action-role for ub.c-action-role.
{ ref/tmpchgs.i "NEW SHARED" }

&SCOPED-DEFINE hn-action-role-hist-code X_c-action-role.subject

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-action-role

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-action-role temp-changes

/* Definitions for BROWSE BR-c-action-role                                */
&Scoped-define FIELDS-IN-QUERY-BR-c-action-role mark-string( recid(X_c-action-role), v-rid-list ) get-subject(X_c-action-role.subject) usrfulnf(X_c-action-role.corr-user-name) X_c-action-role.corr-date string(X_c-action-role.corr-time, "HH:MM")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-action-role
&Scoped-define SELF-NAME BR-c-action-role
&Scoped-define QUERY-STRING-BR-c-action-role FOR EACH X_c-action-role NO-LOCK
&Scoped-define OPEN-QUERY-BR-c-action-role OPEN QUERY {&SELF-NAME} FOR EACH X_c-action-role NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-c-action-role X_c-action-role
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-action-role X_c-action-role


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
BR-c-action-role BR-changes 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-subject Dialog-Frame 
FUNCTION get-subject RETURNS CHARACTER
    ( p-subject as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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
DEFINE QUERY BR-c-action-role FOR
    X_c-action-role SCROLLING.

DEFINE QUERY BR-changes FOR
    temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-action-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-action-role Dialog-Frame _FREEFORM
  QUERY BR-c-action-role DISPLAY
      mark-string( recid(X_c-action-role), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
    get-subject(X_c-action-role.subject) COLUMN-LABEL "Предмет изменений" FORMAT "X(25)":U
    get-action(X_c-action-role.action) COLUMN-LABEL "Действие" FORMAT "X(20)":U
    usrfulnf(X_c-action-role.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(28)":U
    X_c-action-role.corr-date COLUMN-LABEL "Дата измен" FORMAT "99/99/9999":U
    string(X_c-action-role.corr-time, "HH:MM") COLUMN-LABEL "Время измен":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.33.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
    QUERY BR-changes DISPLAY
    temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(25)"
    temp-changes.v_old COLUMn-LABEL "Было" format "X(40)"
    temp-changes.v_new COLUMn-LABEL "Стало" format "X(40)"
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
     BR-c-action-role AT ROW 3.42 COL 1
     BR-changes AT ROW 16.04 COL 1
     SPACE(0.24) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Справочник групп прав"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: for-c-cash-desk B "?" ? ub c-cash-desk
      TABLE: X_c-cash-desk B "?" ? ub c-cash-desk
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-action-role mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-c-action-role Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-c-action-role:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-action-role

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
ON GO OF FRAME Dialog-Frame /* Справочник групп прав */
DO:
        p-rid-list = v-rid-list.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник групп прав */
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
        if not available X_c-action-role then return no-apply.
        { gbl/markstrn.i X_c-action-role v-rid-list  }
        glog = br-c-action-role :refresh( )  in frame {&frame-name}.
        if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then 
        do:
            glog = br-c-action-role:select-next-row () in frame {&frame-name}.
            apply "value-changed" to br-c-action-role in frame {&frame-name}.
        end.
        if num-entries (v-rid-list) = 0 then
            hide mark-num in frame {&frame-name}.
        else
            disp num-entries (v-rid-list) @ mark-num
                with frame {&frame-name}.
        apply "entry" to br-c-action-role in frame {&frame-name}.

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
        if ( available X_c-action-role ) AND ( v-rid-list = "" ) then
            v-rid-list = string( recid( X_c-action-role ) ) .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-action-role
&Scoped-define SELF-NAME BR-c-action-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-action-role Dialog-Frame
ON RETURN OF BR-c-action-role IN FRAME Dialog-Frame
DO:
        apply "DEFAULT-ACTION":U to self.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-action-role Dialog-Frame
ON VALUE-CHANGED OF BR-c-action-role IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-c-action-role" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-action-role). run openbr in this-procedure. reposition br-c-action-role to recid v-doc-rec no-error. ~
              APPLY 'ENTRY' to br-c-action-role. APPLY 'VALUE-CHANGED' to br-c-action-role. " }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/srt-clmd.i
  &browse-name    = "br-c-action-role"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-action-role"
  &sort-clmn_1    = "X_c-action-role.corr-date"
  &open-query     = "run OpenBr in this-procedure."
  &open-query-otherwise = "run OpenBr in this-procedure."
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
    CASE parref-mode:
        WHEN {&all}        THEN 
            DO:
            END.
        WHEN "one":U THEN 
            DO:
                find first X_action-role no-lock where
                    X_action-role.db-num = pardb-num
                    AND  X_action-role.action-head-code = parhead-code
                    AND  X_action-role.action-role-code = parrole-code
                    no-error .
                if not available X_action-role then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Неверный значение параметров pardb-num parhead-code parrole-code "
                        view-as alert-box ERROR.
                    return.
                end.
            END.
        otherwise 
        do:
            message vss-workfile vss-revision vss-description skip
                "Неверный вызов - parref-mode=" parref-mode
                view-as alert-box ERROR.
            return.
        end.
    end case.
    RUN MyEnable in this-procedure .
    HIDE mark-num in frame {&frame-name} .
    run OpenBR in this-procedure.
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
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num BR-c-action-role 
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
    br-changes:title in frame {&frame-name}  = "":U.
    assign
        temp-changes.l_name:resizable in browse br-changes = true
        temp-changes.v_old:resizable in browse br-changes  = true
        temp-changes.v_new:resizable in browse br-changes  = true
        temp-changes.l_name:width in browse br-changes     = 30
        temp-changes.v_old:width in browse br-changes      = 40
        temp-changes.v_new:width in browse br-changes      = 40
        .
    DISPLAY
        mark-num
        br-changes
        WITH FRAME Dialog-Frame.
    ENABLE
        B-quit
        B-mark 
        when lookup('b-mark':U, bttns) >0
        B-sel 
        when lookup('b-sel':U, bttns) >0
        B-sch
        B-Help
        BR-c-action-role
        br-changes
        mark-num
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define variable l-query-was-opened as logical   no-undo .


    define variable sort-column-phrase as character no-undo .

    case sort-column-name :
        when "" then 
            do:
                assign
                    sort-column-phrase = ""
                    .
            end.
        otherwise 
        do:
            assign
                sort-column-phrase = "by " + sort-column-name
                .
        end.
    end case.

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-c-action-role FOR EACH X_c-action-role

&scop flt-open-open-query-tail

&scop flt-open-dyn_open-query  FOR EACH X_c-action-role

&scop flt-open-query-handle query br-c-action-role:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

    CASE parref-mode:
        when {&all} then 
            do:
                ASSIGN 
                    frame {&frame-name}:TITLE = "Справочник групп прав"
                    filter-point              = filter-point0 + parref-mode
                    filter-label              = substitute("&1", filter-label0)
                    .
                { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind = "  "
            &by = "  "
          }
            end.
        when "one":U then 
            do:
                ASSIGN 
                    frame {&frame-name}:TITLE = substitute("Справочник групп прав: БД &1 код права &2 код роли &3",
                                                       pardb-num, parhead-code, parrole-code)
                    filter-point              = filter-point0 + parref-mode
                    filter-label              = substitute("&1: Одна группа прав", filter-label0)
                    .
                { gbl/fltopend.i
            &where-cond = " X_c-action-role.db-num = pardb-num AND ~
                            X_c-action-role.action-head-code = parhead-code and X_c-action-role.action-role-code = parrole-code"
            &dyn_where-cond = " substitute('X_c-action-role.db-num = &1 AND ~
                            X_c-action-role.action-head-code = &3 and X_c-action-role.action-role-code = &4', pardb-num, ~{&double-quote~}, parhead-code, parrole-code)"

            &use-ind = "  "
            &by = "  "
          }
            end.
        when "one-subject":U then 
            do:
                ASSIGN 
                    frame {&frame-name}:TITLE = substitute("Справочник групп прав: БД &1 &2 &3 &4"
                                                       , pardb-num
                                                       , parhead-code
                                                       , parrole-code
                                                       , p-subject
                                                       )
                    filter-point              = filter-point0 + parref-mode
                    filter-label              = substitute("&1: Предмет изменений по группе прав", filter-label0)
                    .

            end.


    END CASE.
    apply "entry" to br-c-action-role in frame {&frame-name}.
    reposition br-c-action-role to row 1 no-error.

    if avail X_c-action-role then
        APPLY "VALUE-CHANGED":U to br-c-action-role.
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
        tbl      = 'c-action-role'
        join-tbl = 'X_c-action-role'
        fld      = ""
        lab      = ""
        spr      = ""
        dim      = '0'
        .
    run fltfield-add in this-procedure('db-num', 'БД', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('action-head-code', 'Код заголовка права', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('action-role-code', 'Код роли', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('action-role-context', 'Контекст роли', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('action-role-name', 'Имя роли', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('action-role-description', 'Описание роли', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('corr-date', 'Дата изменений', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('corr-time', 'Время изменений', 'time',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('corr-user-db-num', 'БД изменений', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('is-del', 'Удаленная запись', '',
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
        RUN OpenBr in this-procedure.
    END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define variable v-description as character no-undo .
    for each temp-changes:
        delete temp-changes.
    END.
    if not available X_c-action-role then 
    do:
        Open QUery br-changes for each temp-changes.
        return.
    end.

    run ref/cactnrolev.p (
        input X_c-action-role.db-num
        ,input X_c-action-role.action-head-code
        ,input X_c-action-role.action-role-code
        ,input X_c-action-role.corr-user-db-num
        ,input X_c-action-role.chip-num
        ,input X_c-action-role.subject
        ,input 0 /*c-cli-hist.action*/
        ,input no /*p-silent*/
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame 
FUNCTION get-action RETURNS CHARACTER
    ( p-action as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

   &scop hn-action-code trim(string(p-action))
    define variable dops as character no-undo.
    assign 
        dops = {&hn-action-name} no-error.

    RETURN dops.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-subject Dialog-Frame 
FUNCTION get-subject RETURNS CHARACTER
    ( p-subject as character ) :
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/

   
    define variable dops as character no-undo.
    case p-subject:
        when {&table_action-role} then 
            do:
                assign 
                    dops = "роль" no-error.       
            end.
        when {&table_action-role-item} then 
            do:
                assign 
                    dops = "право" no-error.       
            end.        
    end case .    

    RETURN dops.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

