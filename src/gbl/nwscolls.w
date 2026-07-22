&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buF_BatchProcess FOR ub.BatchProcess.
DEFINE BUFFER X_db FOR ub.db.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список неразобранных коллизий, возникших в СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-db-num like ub.db.db-num no-undo .
define input parameter p-subject as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input-output param p-rid-list    as  char no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список неразобранных коллизий, возникших в СПН".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

{ nws/db-rec.i }
/*включен потому, что там есть нужные нам функции*/
{ gbl/key-rec.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }


define variable sort-column-name as character no-undo .
define variable filter-pointr as character no-undo init "Неразобранные коллизии СПН" .
define variable filter-point0 as character no-undo init "nwscolls" .
define variable filter-point as character no-undo .

DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable v-tbl-row  as rowid     no-undo.
define variable v-tbl-name as character no-undo.
define variable v-coll-name as character no-undo.
define variable v-uniq-key-rec as character no-undo.

&SCOPED-DEFINE sort-clmn_2 subject-title-function(buF_BatchProcess.CharKey_two)
&SCOPED-DEFINE dyn_sort-clmn_2 substitute('dynamic-funciotn(&1subject-title-function&1, buF_BatchProcess.CharKey_two)', ~{&double-quote~})
&scoped-define label-clmn_2 'Тип коллизии'
&SCOPED-DEFINE sort-clmn_3 uniq-key-rec-string-f(buF_BatchProcess.CharKey_one)
&SCOPED-DEFINE dyn_sort-clmn_3 substitute('dynamic-function(&1uniq-key-rec-string-f&1, buF_BatchProcess.CharKey_one)', ~{&double-quote~})
&scoped-define label-clmn_3 'Запись'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-colls

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buF_BatchProcess

/* Definitions for BROWSE BR-colls                                      */
&Scoped-define FIELDS-IN-QUERY-BR-colls buF_BatchProcess.Key#_Two subject-title-function(buF_BatchProcess.CharKey_two) @ v-coll-name uniq-key-rec-string-f(buF_BatchProcess.CharKey_one) @ v-uniq-key-rec buF_BatchProcess.CharKey_Three buF_BatchProcess.Key#_One
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-colls
&Scoped-define SELF-NAME BR-colls
&Scoped-define QUERY-STRING-BR-colls FOR EACH buF_BatchProcess NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-colls OPEN QUERY {&SELF-NAME} FOR EACH buF_BatchProcess NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-colls buF_BatchProcess
&Scoped-define FIRST-TABLE-IN-QUERY-BR-colls buF_BatchProcess


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-solve B-sch B-Help BR-colls

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD subject-title-function Dialog-Frame
FUNCTION subject-title-function RETURNS CHARACTER
  (INPUT p-subject AS CHARACTER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-solve
     LABEL "Разобрать  коллизию"
     SIZE 20 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-colls FOR
      buF_BatchProcess SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-colls
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-colls Dialog-Frame _FREEFORM
  QUERY BR-colls NO-LOCK DISPLAY
      buF_BatchProcess.Key#_Two COLUMN-LABEL "Критич!ность" FORMAT ">9":U WIDTH 7
subject-title-function(buF_BatchProcess.CharKey_two) @ v-coll-name COLUMN-LABEL "Тип коллизии" FORMAT "X(20)"
uniq-key-rec-string-f(buF_BatchProcess.CharKey_one) @ v-uniq-key-rec COLUMN-LABEL "Запись" FORMAT "X(40)"
buF_BatchProcess.CharKey_Three COLUMN-LABEL "Значение!предмета!коллизии" FORMAT "X(20)":U
buF_BatchProcess.Key#_One COLUMN-LABEL "№ БД!источ-ка" FORMAT ">>>>>>9":U WIDTH 14
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-solve AT ROW 1 COL 31
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-colls AT ROW 3 COL 1
     SPACE(0.62) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Неразобранные коллизии, возникшие в СПН"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buF_BatchProcess B "?" ? ub BatchProcess
      TABLE: X_db B "?" ? ub db
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-colls B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-colls
/* Query rebuild information for BROWSE BR-colls
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buF_BatchProcess NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-colls */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Неразобранные коллизии, возникшие в СПН */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN this-procedure NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-solve
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-solve Dialog-Frame
ON CHOOSE OF B-solve IN FRAME Dialog-Frame /* Разобрать  коллизию */
DO:
  RUN proc-b-solve IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-colls
&Scoped-define SELF-NAME BR-colls
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-colls Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-colls IN FRAME Dialog-Frame
or RETURN OF br-colls IN FRAME {&frame-name} DO:
  APPLY "CHOOSE" TO b-solve.
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
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/setfltnm.i }
{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/brwrefre.i " run refresh in this-procedure no-error. " }

{ gbl/srt-clmd.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "buf_batchprocess"
&ext-col = 5
&start-column  = 1
&sort-clmn_1   = "buF_BatchProcess.Key#_Two"
&label-clmn_2  = "{&label-clmn_2}"
&sort-clmn_2   = "{&sort-clmn_2}"
&label-clmn_3  = "{&label-clmn_3}"
&sort-clmn_3   = "{&sort-clmn_3}"
&sort-clmn_4   = "buF_BatchProcess.CharKey_Three"
&sort-clmn_5   = "buF_BatchProcess.Key#_One"
&open-query = "RUn OpenBR IN THIS-PROCEDURE ( input yes, input no, input no)."
&open-query-otherwise = " RUn OpenBR IN THIS-PROCEDURE ( input yes, input no, input no)."
&re-move-clmn = "yes"
&mv-brw-default = "yes"
&sort-column-name = "sort-column-name"
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }

 if LOOKUP(p-mode, ({&all} + {&delim-par} +
                    "db-num":U + {&delim-par} +
                    "subject":U + {&delim-par} +
                    "uniq-key-rec":U),
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 IF p-mode = "db-num":U THEN DO:
   FIND FIRST X_db NO-LOCK WHERE X_db.db-num = p-db-num NO-ERROR.
   IF NOT AVAILABLE X_db THEN DO:
         message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметров вызова p-db-num"
         p-db-num
         view-as alert-box ERROR.
         return error .
    END.
  END.
  IF p-mode = "subject":U THEN DO:
    IF LOOKUP (p-subject, {&nws-coll_codes}) = 0 THEN DO:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-subject"
      p-subject
      view-as alert-box ERROR.
      return error .
    END.
  END.
  IF p-mode = "uniq-key-rec":U THEN DO:
    RUN gen-row-keyr IN THIS-PROCEDURE
      ( input  p-uniq-key-rec
       ,input  ?
       ,input  "ub":U
       ,input  ?
       ,input  share-lock
       ,output v-tbl-row
       ,output v-tbl-name
      ) NO-ERROR.
    IF error-status:error THEN DO:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-uniq-key-rec"
      p-uniq-key-rec
      view-as alert-box ERROR.
      return error .
    END.
  END.
  RUN Myenable IN THIS-PROCEDURE.
  RUn OpenBR IN THIS-PROCEDURE ( input yes, input no, input no).
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  { gbl/mv-clmn.i
  &browse-name = "br-colls"
  &frame-name = "{&frame-name}"
  &ext-col = 5
  &start-column = 1
  &prev-order-column_1 = "'1,2,3,4,5'"
  &prev-order-column-condition_1 = " p-mode = ~{&all~} "
  &prev-order-column_2 = "'1,2,3,4,5'"
  &prev-order-column-condition_2 = " p-mode = 'db-num':U "
  &prev-order-column_3 = "'1,3,4,5,2'"
  &prev-order-column-condition_3 = " p-mode = 'subject':U "
  &prev-order-column_4 = "'1,2,4,5б3'"
  &prev-order-column-condition_4 = " p-mode = 'uniq-key-rec':U "
  }

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
  ENABLE b-quit B-solve B-sch B-Help BR-colls
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ENABLE
b-quit
B-solve
B-sch
B-Help
BR-colls
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
define variable title0 as character no-undo.
title0 = "Неразобранные коллизии, возникшие в СПН" + {&space-char}.

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

&scop flt-open-open-query OPEN QUERY br-colls FOR EACH buf_batchprocess

&scop flt-open-dyn_open-query  FOR EACH buf_batchprocess

&scop flt-open-query-handle query br-colls:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_batchprocess

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name buf_batchprocess

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .


  CASE p-mode :
    WHEN {&all}        THEN DO:
     filter-point = filter-point0 + p-mode + {&delim-par}  + filter-pointr.
       ASSIGN
       frame {&frame-name}:TITLE = title0.

     { gbl/fltopend.i
        &where-cond = " buf_batchprocess.bp_type = ~{&btpr-type-nws-coll~}  and buf_batchprocess.bp_status = ~{&btpr-normal~} "
        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "db-num" THEN DO:
       filter-point = filter-point0 + p-mode + {&delim-par}  + filter-pointr.
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" ИСТОЧНИК БД № &1", p-db-num).
      { gbl/fltopend.i
        &where-cond = " buf_batchprocess.bp_type = ~{&btpr-type-nws-coll~}  and buf_batchprocess.bp_status = ~{&btpr-normal~} ~
                        AND buf_batchprocess.key#_one  = p-db-num    ~
                      "
        &dyn_where-cond = " substitute('buf_batchprocess.bp_type = &1&2&1 and buf_batchprocess.bp_status = &1&3&1 ~
                        AND buf_batchprocess.key#_one  = &4',  ~{&double-quote~}, ~{&btpr-type-nws-coll~}, ~{&btpr-normal~}, p-db-num)    ~
                      "

        &use-ind    = "  "
        &by         = "  " }
    END.
  WHEN "subject" THEN DO:
     filter-point = filter-point0 + p-mode + {&delim-par}  + filter-pointr.
     ASSIGN
     frame {&frame-name}:TITLE = title0 +
                                 substitute(" Тип коллизии &1", subject-title-function (p-subject)).
    { gbl/fltopend.i
      &where-cond = " buf_batchprocess.bp_type = ~{&btpr-type-nws-coll~}  and buf_batchprocess.bp_status = ~{&btpr-normal~} ~
                      AND buf_batchprocess.charkey_two  = p-subject    ~
                    "
      &dyn_where-cond = " substitute('buf_batchprocess.bp_type = &1&2&1  and buf_batchprocess.bp_status = &1&3&1 ~
                      AND buf_batchprocess.charkey_two  = &1&4&1', ~{&double-quote~}, ~{&btpr-type-nws-coll~}, ~{&btpr-normal~}, p-subject)    ~
                    "

      &use-ind    = "  "
      &by         = "  " }
  END.
WHEN "uniq-key-rec" THEN DO:
     filter-point = filter-point0 + p-mode + {&delim-par}  + filter-pointr.
     ASSIGN
     frame {&frame-name}:TITLE = title0 +
                                 substitute(" Запись: &1",  uniq-key-rec-string-f(p-uniq-key-rec)).
    { gbl/fltopend.i
      &where-cond = " buf_batchprocess.bp_type = ~{&btpr-type-nws-coll~}  and buf_batchprocess.bp_status = ~{&btpr-normal~} ~
                      AND buf_batchprocess.charkey_one  = p-uniq-key-rec    ~
                    "
      &dyn_where-cond = " substitute('buf_batchprocess.bp_type = &1&2&1  and buf_batchprocess.bp_status = &1&3&1 ~
                      AND buf_batchprocess.charkey_one  = &1&4&1', ~{&double-quote~}, ~{&btpr-type-nws-coll~}, ~{&btpr-normal~}, p-uniq-key-rec )   ~
                    "

      &use-ind    = "  "
      &by         = "  " }
  END.
END CASE.
if not p-open-query then
REPOSITION br-colls to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-colls:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-colls in frame {&frame-name}.
APPLY "ENTRY" TO br-colls.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
assign
  tbl = 'batchprocess'
  join-tbl = 'buf_batchprocess'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .

run fltfield-add in this-procedure('Key#_Two', 'Критичность', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('Key#_One', '№ БД источника', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('CharKey_Three', 'Значение предмета коллизии', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('CharKey_two', 'Тип коллизии', 'nws-coll_codes',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-solve Dialog-Frame 
PROCEDURE proc-b-solve :
define variable ri as recid no-undo.
define variable glog as logical no-undo .
define variable v-tbl-row as rowid no-undo .
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
define buffer buf_clients for ub.clients.

IF NOT AVAILABLE buf_batchprocess THEN UNDO, RETURN ERROR.
assign
v-doc-rec = recid(buf_batchprocess).
CASE buf_batchprocess.charkey_two:
    WHEN {&nws-coll_inn-uniq} THEN DO:
       /*проверим права*/
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_client-reference_update':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        true
        glog
      }
       if not glog then return .
       run  gen-row-keyr  in this-procedure
         ( input  buf_batchprocess.charkey_one
          ,input ?
          ,input "ub":U
          ,input ?
          ,input share-lock
          ,output v-tbl-row
          ,output v-tbl-name
         ).
       CASE v-tbl-name:
         when {&table_firm} then do:
           find first buf_firm no-lock where
                    rowid(buf_firm) = v-tbl-row .
           find first buf_clients no-lock where
                      buf_clients.obj-type = {&cmp}
                 and buf_clients.obj-code = buf_firm.firm-code .

         end.
         when {&table_person} then do:
           find first buf_person no-lock where
                    rowid(buf_person) = v-tbl-row .
           find first buf_clients no-lock where
                      buf_clients.obj-type = {&prs}
                 and buf_clients.obj-code = buf_person.psn-code .
         end.
       END CASE.
       ri = recid( buf_clients ) .
       MESSAGE
       substitute("Для разбора коллизии Вам необходимо изменить {&abbr_inn_allshift} КОНТРАГЕНТА &1&2"
                 , buf_clients.obj-type
                 , buf_clients.obj-code
                 )
      VIEW-AS ALERT-BOX.
       CASE buf_clients.obj-type:
         when {&cmp}  then
         run ref/firmi.w (
                   input parParentProc
                  ,input {&update}
                  ,input buf_clients.obj-code
                  ,input 0
                  ,input "cli-all"
                  ,input-output  ri) .
         when {&prs} then
          run ref/personi.w (
                     input parParentProc
                    ,input {&update}
                    ,input buf_Clients.obj-code
                    ,input 0
                    ,input "cli-all"
                    ,input-output  ri) .

        END CASE .
        if ri <> ? then do:
          run openbr in this-procedure ( input yes, input no, input "").
          reposition br-colls to recid v-doc-rec no-error.
          apply "ENTRY" to br-colls in frame {&frame-name} .
        end.
    END. /*inn-uniq*/
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh Dialog-Frame 
PROCEDURE refresh :
DEFINE VARIABLE v-doc-rec AS RECID no-undo.
IF NOT AVAILABLE buf_batchprocess THEN RETURN.
v-doc-rec = RECID(buf_batchprocess).
run openbr in this-procedure ( input yes, input no, input "").
reposition br-colls to recid v-doc-rec no-error.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION subject-title-function Dialog-Frame 
FUNCTION subject-title-function RETURNS CHARACTER
  (INPUT p-subject AS CHARACTER) :
define variable v-name as character no-undo .
&SCOPED-DEFINE nws-coll_code p-subject
assign
v-name = {&nws-coll_name} no-error .
RETURN v-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

