&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-alc-sale-lic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-alc-sale-lic
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник лицензий на продажу алкогольной продукции.

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc  as widget-handle no-undo .
/*
DEFINE INPUT  PARAMETER p-cli-type     LIKE ub.alc-sale-lic.cli-type no-undo.
DEFINE INPUT  PARAMETER p-cli-code     LIKE ub.alc-sale-lic.cli-code no-undo.
*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник лицензий на продажу алкогольной продукции".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ cmp/showinf.i  }

define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable v-log as logical   no-undo .
define variable RowID-list as  character no-undo .
define variable v-ok    as logical      no-undo.

DEFINE variable p-cli-type     LIKE ub.alc-sale-lic.cli-type no-undo.
DEFINE variable p-cli-code     LIKE ub.alc-sale-lic.cli-code no-undo.

define stream ListStream .

define variable sort-column-name as character no-undo .

define buffer buf_alc-sale-lic for ub.alc-sale-lic.
define buffer host_clients for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-alc-sale-lic
&Scoped-define BROWSE-NAME br-alc-sale-lic

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_alc-sale-lic

/* Definitions for BROWSE br-alc-sale-lic                               */
&Scoped-define FIELDS-IN-QUERY-br-alc-sale-lic buf_alc-sale-lic.date-from buf_alc-sale-lic.date-to buf_alc-sale-lic.number buf_alc-sale-lic.seria buf_alc-sale-lic.date-get buf_alc-sale-lic.who-are-got IF buf_alc-sale-lic.all-type > 0 THEN "+" ELSE "-"
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-alc-sale-lic
&Scoped-define SELF-NAME br-alc-sale-lic
&Scoped-define OPEN-QUERY-br-alc-sale-lic /* OPEN QUERY {&SELF-NAME} FOR EACH buf_alc-sale-lic       WHERE buf_alc-sale-lic.cli-type = p-cli-type  AND buf_alc-sale-lic.cli-code = p-cli-code NO-LOCK.  */   run refresh-query in this-procedure.
&Scoped-define TABLES-IN-QUERY-br-alc-sale-lic buf_alc-sale-lic
&Scoped-define FIRST-TABLE-IN-QUERY-br-alc-sale-lic buf_alc-sale-lic


/* Definitions for DIALOG-BOX f-alc-sale-lic                            */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-alc-sale-lic ~
    ~{&OPEN-QUERY-br-alc-sale-lic}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-print b-hist b-help b-add b-upd b-del ~
br-alc-sale-lic

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-print 
     LABEL "Пе&чать" 
     SIZE 3 BY .95.

DEFINE BUTTON b-upd
     LABEL "&Изменить":L
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-alc-sale-lic FOR
      buf_alc-sale-lic SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-alc-sale-lic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-alc-sale-lic f-alc-sale-lic _FREEFORM
  QUERY br-alc-sale-lic NO-LOCK DISPLAY
      buf_alc-sale-lic.date-from COLUMN-LABEL "c" FORMAT "99/99/9999":U
      buf_alc-sale-lic.date-to COLUMN-LABEL "по" FORMAT "99/99/9999":U
      buf_alc-sale-lic.number FORMAT "x(16)":U
      buf_alc-sale-lic.seria FORMAT "x(16)":U
      buf_alc-sale-lic.date-get FORMAT "99/99/9999":U
      buf_alc-sale-lic.who-are-got FORMAT "x(30)":U
      IF buf_alc-sale-lic.all-type > 0 THEN "+" ELSE "-" COLUMN-LABEL "На все типы"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 54.6 BY 18.48
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-alc-sale-lic
     b-exit AT ROW 1 COL 1
     b-print AT ROW 1 COL 33 WIDGET-ID 2
     b-hist AT ROW 1 COL 36
     b-help AT ROW 1 COL 46
     b-add AT ROW 2 COL 1
     b-upd AT ROW 2 COL 11
     b-del AT ROW 2 COL 21
     br-alc-sale-lic AT ROW 3.25 COL 1.63
     SPACE(0.11) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Лицензии на продажу алкогольной продукции":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-alc-sale-lic
   FRAME-NAME                                                           */
/* BROWSE-TAB br-alc-sale-lic b-del f-alc-sale-lic */
ASSIGN
       FRAME f-alc-sale-lic:SCROLLABLE       = FALSE.

ASSIGN
       br-alc-sale-lic:NUM-LOCKED-COLUMNS IN FRAME f-alc-sale-lic     = 3.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-alc-sale-lic
/* Query rebuild information for BROWSE br-alc-sale-lic
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_alc-sale-lic
      WHERE buf_alc-sale-lic.cli-type = p-cli-type
 AND buf_alc-sale-lic.cli-code = p-cli-code NO-LOCK.
 */

 run refresh-query in this-procedure.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "buf_alc-sale-lic.cli-type = p-cli-type
 AND buf_alc-sale-lic.cli-code = p-cli-code"
     _Query            is OPENED
*/  /* BROWSE br-alc-sale-lic */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX f-alc-sale-lic
/* Query rebuild information for DIALOG-BOX f-alc-sale-lic
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX f-alc-sale-lic */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add f-alc-sale-lic
ON CHOOSE OF b-add IN FRAME f-alc-sale-lic /* Добавить */
DO:
/*!!!    'actn_alc-sale-lic_add-def':U
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_season_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return no-apply .
 */
 assign
   rr = ?
 .

 run ref/licsalei.w ( parParentProc , {&add-def}, input-output rr ).
 if rr <> ? then
    do:
        run refresh-query in this-procedure no-error.
         IF ERROR-STATUS:ERROR THEN DO:
            MESSAGE
               "Пользователь не создан" skip
               vss-workfile vss-revision vss-description skip
               error-status :get-message(1) skip
               return-value skip
            view-as alert-box error .
            undo, return NO-APPLY .
         END.
        reposition br-alc-sale-lic to recid rr.
        log-res  = br-alc-sale-lic:select-focused-row( ).
        /*
        apply "ENTRY":U to br-alc-sale-lic.
        apply "home"    to br-alc-sale-lic.
        */
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del f-alc-sale-lic
ON CHOOSE OF b-del IN FRAME f-alc-sale-lic /* Удалить */
DO:

define variable g-log as logical   no-undo .
define variable v-recid as integer no-undo .
define variable ii as integer no-undo .
define buffer del_alc-sale-lic for ub.alc-sale-lic.
/*!!!    'actn_alc-sale-lic_deletion':U
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_season_deletion:U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
if not available alc-sale-lic or v-log = false then  return no-apply.
*/
if available buf_alc-sale-lic then do:
   message substitute("Удалить лицензию серия &1 №&2 ?", buf_alc-sale-lic.seria, buf_alc-sale-lic.number)
            view-as alert-box question
            buttons yes-no
            update g-log.
            if g-log = false then return no-apply.
   do transaction
      :
      find first del_alc-sale-lic
         where recid(del_alc-sale-lic)  = recid(buf_alc-sale-lic)
         exclusive-lock no-error .
      if available del_alc-sale-lic then do:
         delete del_alc-sale-lic.
      end.
   end.
end.

run refresh-query in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist f-alc-sale-lic
ON CHOOSE OF b-hist IN FRAME f-alc-sale-lic /* История */
DO:
   if available buf_alc-sale-lic THEN do:
      run ref/licsaleh.w
      ( input parParentProc ,
        input buf_alc-sale-lic.alc-sale-lic-code,
        input buf_alc-sale-lic.create-user-db-num
        ).
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print f-alc-sale-lic
ON CHOOSE OF b-print IN FRAME f-alc-sale-lic /* Печать */
DO:
    run ref/p-licsa.p(input parparentproc, input p-cli-type, input p-cli-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd f-alc-sale-lic
ON CHOOSE OF b-upd IN FRAME f-alc-sale-lic /* Изменить */
DO:
/*!!!    'actn_alc-sale-lic_update':U
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_season_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
*/
   if not available buf_alc-sale-lic
   /* or v-log = false */
   then do:
      return no-apply.
   end.
   rr = recid( buf_alc-sale-lic ).
   run ref/licsalei.w ( parParentProc
                     , {&update}
                     , input-output rr
                     ) .
   run refresh-query in this-procedure.
   reposition br-alc-sale-lic to recid rr .
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-alc-sale-lic
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-alc-sale-lic


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/getcntxt.i get }

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_lic-sale-lookup':U"
      {&cntxt-object}
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      TRUE
      v-ok
    }
    IF NOT v-ok then do:
       return.
    end.

{ gbl/app_help.i &browse-name="br-alc-sale-lic" }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    /*
    find first host_clients
         where host_clients.obj-type = {&firm}
           and host_clients.obj-code = v-cntxt-host-code-obj
         no-lock
         .
    */
    assign
      p-cli-type = {&cmp}
      p-cli-code = v-cntxt-host-code-obj
    .

    run enable_ui.
    run post_enable_ui in this-procedure.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-alc-sale-lic  _DEFAULT-DISABLE
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
  HIDE FRAME f-alc-sale-lic.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-alc-sale-lic
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
    ENABLE
        br-alc-sale-lic
        b-exit
        b-add  /* WHEN (lookup ( "b-add" , bttns) > 0 ) */
        b-upd  /* WHEN (lookup ( "b-add" , bttns) > 0 ) */
        b-del  /* WHEN (lookup ( "b-add" , bttns) > 0 ) */
        b-hist
        b-help
        b-print
        WITH FRAME  {&frame-name}.
    {&OPEN-BROWSERS-IN-QUERY-d-alc-sale-lic}
    if available buf_alc-sale-lic then
        log-res  = br-alc-sale-lic:select-focused-row( ) in frame {&frame-name}.


     {&open-query-br-alc-sale-lic}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_UI f-alc-sale-lic
PROCEDURE post_enable_UI :
do
on error undo, return error
:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_lic-sale-update':U"
      {&cntxt-object}
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      false
      v-ok
    }
    IF NOT v-ok then do:
      DISABLE
         b-add
         b-upd
         b-del
      WITH FRAME  {&frame-name}.
    end.
end.
END PROCEDURE. /* post_enable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query f-alc-sale-lic
PROCEDURE refresh-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if p-cli-type = ?
or p-cli-code = ?
then do:
 OPEN QUERY {&browse-name} FOR EACH buf_alc-sale-lic NO-LOCK.
end.
else do:
 OPEN QUERY {&browse-name} FOR EACH buf_alc-sale-lic
      WHERE buf_alc-sale-lic.cli-type = p-cli-type
        AND buf_alc-sale-lic.cli-code = p-cli-code NO-LOCK.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
