&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-db-hist


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-db FOR ub.c-db.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-db-hist 
/*------------------------------------------------------------------------
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр истории изменения записи БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/22/05
Author: Dmitry Ukhanov
Creation date: 11/22/05
------------------------------------------------------------------------*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as   widget-handle no-undo .
define input  parameter p-db-num      like ub.db.db-num  no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Просмотр истории изменения записи БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/usrfulnf.i }
{ ref/tmpchgs.i " " " " "with-action" }

{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }


define variable v-hist-rec         as recid no-undo.
define variable v-sort-column-name as character no-undo .
define variable v-filter-pointr as character no-undo init "Просмотр истории изменения записи БД" .
define variable v-filter-point0 as character no-undo init "db-hist" .
define variable v-filter-point as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-db-hist
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes X_c-db

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-db-hist                                    */
&Scoped-define FIELDS-IN-QUERY-br-db-hist X_c-db.corr-user-name usrfulnf(X_c-db.corr-user-name) X_c-db.corr-user-db-num X_c-db.corr-date string(X_c-db.corr-time,"HH:MM:SS") get-action(X_c-db.action) X_c-db.db-num X_c-db.db-name X_c-db.db-key   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-db-hist   
&Scoped-define SELF-NAME br-db-hist
&Scoped-define QUERY-STRING-br-db-hist FOR EACH X_c-db NO-LOCK     BY X_c-db.corr-date      BY X_c-db.corr-time       BY X_c-db.corr-user-db-num        BY X_c-db.chip-num
&Scoped-define OPEN-QUERY-br-db-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-db NO-LOCK     BY X_c-db.corr-date      BY X_c-db.corr-time       BY X_c-db.corr-user-db-num        BY X_c-db.chip-num.
&Scoped-define TABLES-IN-QUERY-br-db-hist X_c-db
&Scoped-define FIRST-TABLE-IN-QUERY-br-db-hist X_c-db


/* Definitions for DIALOG-BOX d-db-hist                                 */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sch b-help br-db-hist BR-changes 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action d-db-hist 
FUNCTION get-action RETURNS CHARACTER
    ( p-action as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY br-db-hist FOR X_c-db.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes d-db-hist _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 8.25.

DEFINE BROWSE br-db-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-db-hist d-db-hist _FREEFORM
  QUERY br-db-hist NO-LOCK DISPLAY
      X_c-db.corr-user-name column-label "Изменил" FORMAT "x(8)":U
      usrfulnf(X_c-db.corr-user-name) column-label "Изменил" FORMAT "x(15)":U
      X_c-db.corr-user-db-num COLUMN-LABEL "БД изм." FORMAT ">>>>9":U
      X_c-db.corr-date FORMAT "99/99/9999":U
      string(X_c-db.corr-time,"HH:MM:SS") COLUMN-LABEL "Время изм." FORMAT "x(8)":U
      get-action(X_c-db.action) COLUMN-LABEL "Действие" FORMAT "x(10)":U
      X_c-db.db-num 
      X_c-db.db-name
      X_c-db.db-key
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 97 BY 11 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-db-hist
     b-quit AT ROW 1 COL 2
     b-sch AT ROW 1 COL 93 WIDGET-ID 2
     b-help AT ROW 1 COL 96
     br-db-hist AT ROW 2.25 COL 2
     BR-changes AT ROW 14.25 COL 2
     SPACE(0.87) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История изменения параметров конфигурации"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-db B "?" ? ub c-db
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-db-hist
   FRAME-NAME                                                           */
/* BROWSE-TAB br-db-hist b-help d-db-hist */
/* BROWSE-TAB BR-changes br-db-hist d-db-hist */
ASSIGN 
       FRAME d-db-hist:SCROLLABLE       = FALSE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-db-hist
/* Query rebuild information for BROWSE br-db-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-db NO-LOCK
    BY X_c-db.corr-date
     BY X_c-db.corr-time
      BY X_c-db.corr-user-db-num
       BY X_c-db.chip-num.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-db-hist FOR X_c-db.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE br-db-hist */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-db-hist
/* Query rebuild information for DIALOG-BOX d-db-hist
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-db-hist */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-db-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-db-hist d-db-hist
ON WINDOW-CLOSE OF FRAME d-db-hist /* История изменения параметров конфигурации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-db-hist
ON CHOOSE OF b-quit IN FRAME d-db-hist /* Выход */
DO:
  define variable v-ok as logical   no-undo .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch d-db-hist
ON CHOOSE OF b-sch IN FRAME d-db-hist /* Фильтр */
DO:
  RUN proc-b-sch IN this-procedure NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-db-hist
&Scoped-define SELF-NAME br-db-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-db-hist d-db-hist
ON VALUE-CHANGED OF br-db-hist IN FRAME d-db-hist
DO:
  if available X_c-db then do:
    run proc-full-temp-changes in this-procedure
      ( input (X_c-db.action = {&bef-hn-create} )
       ,input (X_c-db.action = {&bef-hn-delete} )
       ,input (buffer X_c-db:handle)
       ,input {&table_db}
       ,input "":U
       ,input "":U
      ) no-error.
  end.
  else do:
    for each temp-changes
    :
      delete temp-changes .
    end.
  end.
  {&OPEN-QUERY-BR-changes}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-db-hist 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

{ gbl/app_help.i }

{ gbl/brwrepos.i
  &line-num=8
}
{ gbl/brwrefre.i "run OpenBR in this-procedure ( input yes, input no, input no ) ." }

{ gbl/mv-clmn.i
  &ext-col = 11
  &start-column = 1
  &frame-name = "{&frame-name}"
  &browse-name = "br-db-hist"
}

{ gbl/srt-clmd.i
  &browse-name    = "br-db-hist"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-db"
  &sort-clmn_1    = "X_c-db.corr-user-db-num"
  &sort-clmn_2    = "X_c-db.corr-date"
  &open-query     =  "run OpenBR in this-procedure ( input yes, input no, input no ) ."
  &open-query-otherwise = "run OpenBR in this-procedure ( input yes, input no, input no ) ."
  &sort-column-name = "v-sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}
{ gbl/setfltnm.i }

/*"OPEN QUERY br-db-hist FOR EACH X_c-db NO-LOCK by ~{&sort-clmn_~{&clmn_num~}~} ."*/

MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:

  RUN enable_UI.

  assign
    temp-changes.l_name:resizable in browse br-changes = true
    temp-changes.v_old:resizable in browse br-changes = true
    temp-changes.v_new:resizable in browse br-changes = true
    temp-changes.l_name:width in browse br-changes = 33
    temp-changes.v_old:width in browse br-changes = 30
    temp-changes.v_new:width in browse br-changes = 30
  .
  run OpenBR in this-procedure ( input yes, input no, input no) .

  wait-for go of frame {&frame-name}.

end.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-db-hist  _DEFAULT-DISABLE
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
  HIDE FRAME d-db-hist.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-db-hist  _DEFAULT-ENABLE
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
  ENABLE b-quit b-sch b-help br-db-hist BR-changes 
      WITH FRAME d-db-hist.
  {&OPEN-BROWSERS-IN-QUERY-d-db-hist}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBR d-db-hist 
PROCEDURE OpenBR :
/* приходится изголяться... */
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define variable v-sort-column-phrase as character no-undo .

  if available X_c-db then do:
    assign
      v-hist-rec = recid( X_c-db )
    .
  end.


  run waitfram-show in this-procedure ( input "Ждите...").

  case v-sort-column-name :
    when "" then do:
      assign
        v-sort-column-phrase = "by X_c-db.corr-date by X_c-db.corr-time by X_c-db.corr-user-db-num by X_c-db.chip-num":U
      .
    end.
    otherwise do:
      assign
        v-sort-column-phrase = substitute( "by &1", v-sort-column-name )
      .
    end.
  end case.

&scop flt-open-open-query OPEN QUERY br-db-hist FOR EACH X_c-db
&scop flt-open-dyn_open-query  FOR EACH X_c-db
&scop flt-open-query-handle query br-db-hist :handle
&scop flt-open-open-query-tail
&scop flt-open-query-was-opened  l-query-was-opened
&scop flt-open-sort-column-phrase v-sort-column-phrase
&scop flt-open-call-point v-filter-point
&scop flt-open-set-filter-name set-filter-name
&scop flt-open-indexed-reposition indexed-reposition
&scop flt-open-query p-open-query
&scop flt-open-table-name X_c-db
&scop flt-open-search-option no-lock
&scop flt-open-find-next p-find-next
&scop flt-open-find-recid v-hist-rec
&scop flt-open-find-condition p-find-condition
&scop flt-open-find-buffer-name X_c-db
&scop flt-open-waitfram false

  if p-db-num <> ? then do:
    assign
      v-filter-point = v-filter-point0 + "one-db":U + {&delim-par} + v-filter-pointr
      frame {&frame-name}:title = substitute( "История изменения БД &1", p-db-num ) + {&space-char}
    .
    { gbl/fltopend.i
      &where-cond = "X_c-db.db-num = p-db-num"
      &dyn_where-cond = "substitute(' X_c-db.db-num = &1 ', p-db-num  ) "
      &use-ind    = "  "
      &by         = "  "
    }
  end.
  else do:
    assign
      v-filter-point = v-filter-point0 + "all":U + {&delim-par} + v-filter-pointr
      frame {&frame-name}:title = "История изменения баз данных" + {&space-char}
    .
      { gbl/fltopend.i
        &where-cond = "true"
        &use-ind    = " "
        &by         = " "
      }
  end.

  if not p-open-query then do:
    reposition br-db-hist to recid v-hist-rec no-error.
  end.
  if not p-open-query and v-fltopend-rowid[1] <> ? then do:
    query br-db-hist:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
  end.

  run waitfram-hide in this-procedure.

  apply "value-changed" to br-db-hist in frame {&frame-name} .
  apply "entry" to br-db-hist .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch d-db-hist 
PROCEDURE proc-b-sch :
assign
  tbl = 'c-db'
  join-tbl = 'X_c-db'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .



run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', 'Дата изменения', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время изменения', 'time',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД Изменения', 'db',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num', 'Номер БД', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-name', 'Название', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('db-key', 'Ключ БД', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT v-filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run OpenBR in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action d-db-hist 
FUNCTION get-action RETURNS CHARACTER
    ( p-action as integer ) :
  /*------------------------------------------------------------------------------
    Purpose:
      Notes:
  ------------------------------------------------------------------------------*/


  define variable dops as character no-undo.

  &scop hn-action-code trim(string(p-action))
  assign
    dops = {&hn-action-name}
    no-error
  .
  return dops.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

