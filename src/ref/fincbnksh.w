&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-fin-bank FOR c-fin-bank.
DEFINE BUFFER X_c-fin-bank FOR c-fin-bank.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_fin-bank FOR fin-bank.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории банков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/15/03
Author: Bakhtadze Natalya
Creation date: 10/15/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.

define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .
/*может быть {&all} {&company} "one":U*/

define input parameter p-host-code  like ub.fin-bank.host-code no-undo .
define input parameter p-code-bank  like ub.fin-bank.code-bank no-undo .



/*банки в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории банков":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable filter-point as character no-undo init "fincbnks" .
define variable filter-point0 as character no-undo init "fincbnks" .
define variable filter-label as character no-undo init "Список истории изменения банков" .
define variable filter-label0 as character no-undo init "Список истории изменения банков" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

define buffer X_curr_sysconf for ub.sysconf.


{ ref/tmpchgs.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-bank

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-fin-bank temp-changes

/* Definitions for BROWSE BR-bank                                       */
&Scoped-define FIELDS-IN-QUERY-BR-bank mark-string(recid(X_c-fin-bank), v-rid-list) X_c-fin-bank.host-code X_c-fin-bank.code-bank X_c-fin-bank.bank-name X_c-fin-bank.bik X_c-fin-bank.status_ usrfulnf(X_c-fin-bank.corr-user-name) X_c-fin-bank.corr-date string(X_c-fin-bank.corr-time, "HH:MM")   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-bank X_c-fin-bank.corr-date   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-bank X_c-fin-bank
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-bank X_c-fin-bank
&Scoped-define SELF-NAME BR-bank
&Scoped-define QUERY-STRING-BR-bank FOR EACH X_c-fin-bank NO-LOCK
&Scoped-define OPEN-QUERY-BR-bank OPEN QUERY {&SELF-NAME} FOR EACH X_c-fin-bank NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-bank X_c-fin-bank
&Scoped-define FIRST-TABLE-IN-QUERY-BR-bank X_c-fin-bank


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
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel b-lkp B-sch B-Help ~
BR-bank ED-notes sch-code sch-BIK sch-name BR-changes mark-num 
&Scoped-Define DISPLAYED-OBJECTS ED-notes sch-code sch-BIK sch-name ~
mark-num 

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

DEFINE BUTTON b-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

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
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ED-notes AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-BIK AS CHARACTER FORMAT "X(9)":U 
     LABEL "БИК" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "коду" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-name AS CHARACTER FORMAT "X(35)":U 
     LABEL "нач.назв." 
     VIEW-AS FILL-IN 
     SIZE 41.88 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-bank FOR 
      X_c-fin-bank SCROLLING.

DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-bank Dialog-Frame _FREEFORM
  QUERY BR-bank DISPLAY
      mark-string(recid(X_c-fin-bank), v-rid-list) FORMAT "X(1)":U
      X_c-fin-bank.host-code COLUMN-LABEL "Фирма" FORMAT "999999999":U
      X_c-fin-bank.code-bank COLUMN-LABEL "Код!банка" FORMAT "9999999":U
      X_c-fin-bank.bank-name FORMAT "X(40)":U
      X_c-fin-bank.bik FORMAT "X(9)":U
      X_c-fin-bank.status_ FORMAT "X(8)":U
      usrfulnf(X_c-fin-bank.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-fin-bank.corr-date COLUMN-LABEL "Дата!измен" FORMAT "99/99/9999":U
      string(X_c-fin-bank.corr-time, "HH:MM") COLUMN-LABEL "Время!измен" FORMAT "X(5)":U
  ENABLE
      X_c-fin-bank.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10.04.

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
     b-sel AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 41
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-bank AT ROW 2.21 COL 1
     ED-notes AT ROW 12.42 COL 1.13 NO-LABEL
     sch-code AT ROW 14.5 COL 33.63 COLON-ALIGNED
     sch-BIK AT ROW 14.54 COL 14.5 COLON-ALIGNED
     sch-name AT ROW 14.54 COL 53.5 COLON-ALIGNED
     BR-changes AT ROW 16.04 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 14.58 COL 1.5
          FGCOLOR 4 
     SPACE(88.49) SKIP(6.46)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Список истории банков"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-fin-bank B "?" NO-UNDO ub c-fin-bank
      TABLE: X_c-fin-bank B "?" ? ub c-fin-bank
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_fin-bank B "?" ? ub fin-bank
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-bank B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes sch-name Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-bank:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

ASSIGN 
       ED-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-bank
/* Query rebuild information for BROWSE BR-bank
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-fin-bank NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-bank */
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
ON GO OF FRAME Dialog-Frame /* Список истории банков */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-fin-bank then do:
    { gbl/markstrn.i X_c-fin-bank v-rid-list }
    loc#log = br-bank:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-bank:select-next-row ().
        apply "VALUE-CHANGED" to br-bank in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-bank in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
      run gbl/markqwa.p (
                 input b-mark:sensitive
               , input v-rid-list) no-error.
  if error-status:error then return no-apply.
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
  if ( available X_c-fin-bank ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-fin-bank ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-bank
&Scoped-define SELF-NAME BR-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-bank Dialog-Frame
ON RETURN OF BR-bank IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Br-bank IN FRAME Dialog-Frame
DO:
  run proc-br-bank no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-bank Dialog-Frame
ON VALUE-CHANGED OF BR-bank IN FRAME Dialog-Frame
DO:
   DEFINE VARIABLE dops as character no-undo .
  dops = if available X_c-fin-bank then X_c-fin-bank.ps else '':U.
  ED-notes:screen-value = dops.
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_fin-bank for ub.fin-bank.
  if not available X_c-fin-bank then return no-apply.
   DO on stop undo, return no-apply:
      FIND PS_fin-bank where
           recid (ps_fin-bank) = recid(X_c-fin-bank) exclusive.
      if ps_fin-bank.PS <> input frame {&frame-name} ed-notes then
      assign
      ps_fin-bank.PS = input frame {&frame-name} ed-notes
      .
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-BIK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON CTRL-J OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure ( input yes, input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON RETURN OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure ( input no, input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON CTRL-J OF sch-name IN FRAME Dialog-Frame /* нач.назв. */
DO:
  run proc-find-name in this-procedure ( input yes, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON RETURN OF sch-name IN FRAME Dialog-Frame /* нач.назв. */
DO:
  run proc-find-name in this-procedure ( input no, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-bank" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-fin-bank). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-bank to recid v-doc-rec no-error. v-doc-rec = ?. " }
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-fin-bank.bank-name"
  &sort-clmn_2    = "X_c-fin-bank.bik"
  &sort-clmn_3    = "X_c-fin-bank.corr-date"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
/*{ gbl/hot-key.i b-lkp }*/
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode <> {&all}
 and p-mode <> {&company}
 and p-mode <> "one":U
 then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
/*find first X_curr_sysconf no-lock where                              */
/*                X_curr_sysconf.host-code = p-curr-host-code no-error.*/
/*if not available X_curr_sysconf then do:                             */
/*  message                                                            */
/*  vss-workfile vss-revision vss-description skip                     */
/*  "Неверное значение параметра вызова p-curr-host-code"              */
/*  p-curr-host-code                                                   */
/*  view-as alert-box ERROR.                                           */
/*  return.                                                            */
/*end.                                                                 */
/* if p-mode = {&company} then do:                                     */
/*  find first X_clients no-lock where                                 */
/*                X_clients.obj-type = {&cmp}                          */
/*            and X_clients.obj-code = p-host-code no-error.           */
/*    if not available X_clients then do:                              */
/*        message                                                      */
/*        vss-workfile vss-revision vss-description skip               */
/*        "Неверное значение параметра вызова p-host-code"             */
/*        p-curr-host-code                                             */
/*        view-as alert-box ERROR.                                     */
/*        return.                                                      */
/*    end.                                                             */
/*    find first X_sysconf no-lock where                               */
/*                    X_sysconf.host-code = p-host-code no-error.      */
/*    if not available X_sysconf then do:                              */
/*      message                                                        */
/*      vss-workfile vss-revision vss-description skip                 */
/*      "Неверное значение параметра вызова p-host-code"               */
/*      p-host-code                                                    */
/*      view-as alert-box ERROR.                                       */
/*      return.                                                        */
/*    end.                                                             */
/*  end.                                                               */
 if p-mode = "one":U then do:
  find first X_fin-bank no-lock where
                X_fin-bank.host-code = p-host-code
            and X_fin-bank.code-bank = p-code-bank no-error.
    if not available X_fin-bank then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code и/или p-code-bank "
        p-host-code p-code-bank
        view-as alert-box ERROR.
        return.
    end.
  end.
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-fin-bank No-LOCK where
                 recid(find_c-fin-bank) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-fin-bank then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-bank to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-bank"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,3,4,5,6,7,8,9,2'"
    &prev-order-column-condition_2 = " p-mode = {&company} "
    &prev-order-column_3 = "'1,4,5,6,7,8,9,2,3'"
    &prev-order-column-condition_3 = " p-mode = 'one':U "
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
  DISPLAY ED-notes sch-code sch-BIK sch-name mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel b-lkp B-sch B-Help BR-bank ED-notes sch-code 
         sch-BIK sch-name BR-changes mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
assign
  br-bank:num-locked-columns in frame {&frame-name} = 1
  X_c-fin-bank.corr-date:read-only in browse br-bank = yes
  temp-changes.l_name:resizable in browse br-changes = true
  temp-changes.v_old:resizable in browse br-changes = true
  temp-changes.v_new:resizable in browse br-changes = true
  temp-changes.l_name:width in browse br-changes = 30
  temp-changes.v_old:width in browse br-changes = 40
  temp-changes.v_new:width in browse br-changes = 40
  .
  DISPLAY
  ED-notes
  sch-code
  sch-BIK
  sch-name
  mark-num
  br-changes
  WITH FRAME {&FRAME-NAME}.
  ENABLE
  b-quit
  B-mark when lookup("b-mark":U, bttns) > 0
  b-sel when lookup("b-sel":U, bttns) > 0
  
  B-sch
  B-Help
  BR-bank
  sch-code
  sch-BIK
  sch-name
  mark-num
  br-changes
  WITH FRAME {&FRAME-NAME}.
  VIEW FRAME {&FRAME-NAME}.
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
title0 = "Список истории изменения банков" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-bank FOR EACH X_c-fin-bank

&scop flt-open-dyn_open-query FOR EACH X_c-fin-bank

&scop flt-open-query-handle QUERY br-bank:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-fin-bank

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-fin-bank

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


  CASE p-mode :
    WHEN {&all}        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1", filter-label0)
     .
     { gbl/fltopend.i
        &where-cond = " TRUE "
        &use-ind    = "  "
        &by         = "  " }
    END.
/*    WHEN {&company} THEN DO:                                                                                */
/*      assign                                                                                                */
/*      filter-point = filter-point0 + p-mode                                                                 */
/*      filter-label = substitute("&1 Одна фирма", filter-label0)                                             */
/*      .                                                                                                     */
/*      if p-open-query then do :                                                                             */
/*        ASSIGN                                                                                              */
/*        frame {&frame-name}:TITLE = title0 + substitute(" Фирма: (&1) &2", p-host-code, X_clients.obj-name).*/
/*       .                                                                                                    */
/*     end.                                                                                                   */
/*      { gbl/fltopend.i                                                                                      */
/*        &where-cond = " ~                                                                                   */
/*          X_c-fin-bank.host-code  = p-curr-host-code    ~                                                   */
/*                      "                                                                                     */
/*        &dyn_where-cond = " substitute(' X_c-fin-bank.host-code  = &1', p-curr-host-code )"                 */
/*                                                                                                            */
/*        &use-ind    = "  "                                                                                  */
/*        &by         = "  " }                                                                                */
/*    END.                                                                                                    */
    WHEN "one":u THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Один банк", filter-label0)
      .
      if p-open-query then do:
        ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Банк (&1): Фирма (&2) &3",
                                          X_fin-bank.code-bank, X_fin-bank.host-code, X_fin-bank.bank-name).
      end.
      { gbl/fltopend.i
        &where-cond = " ~
          X_c-fin-bank.host-code  = p-host-code AND X_c-fin-bank.code-bank = p-code-bank   ~
                      "
        &dyn_where-cond = " substitute('X_c-fin-bank.host-code  = &1 AND X_c-fin-bank.code-bank = &2', p-host-code, p-code-bank) "

        &use-ind    = "  "
        &by         = "  " }
    END.

END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-bank to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-bank:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-bank in frame {&frame-name}.
APPLY "ENTRY" TO br-bank.

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
  tbl = 'c-fin-bank'
  join-tbl = 'X_c-fin-bank'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('code-bank', 'Код в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('bank-name', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('bank-city', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cl-bank', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('bik', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('addres', 'Адрес юридический', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('addres1', 'Адрес почтовый', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('e-mail', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fax', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('inn', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('kpp', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('licenz', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okato', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okonx', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okpo', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('otdel', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('phone', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('short-name', 'Краткое название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    , INPUT (filter-point + {&delim-par} + filter-label)
                    , INPUT tbl
                    , INPUT join-tbl
                    , INPUT fld
                    , INPUT lab
                    , INPUT spr
                    , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-bank Dialog-Frame 
PROCEDURE proc-br-bank :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i b-lkp }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-bik Dialog-Frame 
PROCEDURE proc-find-bik :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-bik like ub.fin-bank.bik no-undo.
display
"0":U @ sch-code
with frame {&frame-name}.
assign
p-bik = replace(p-bik, {&double-quote}, "":U)
p-bik = replace(p-bik, {&single-quote}, {&single-quote} + {&single-quote})
p-bik = {&double-quote} + p-bik + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-bank.bik   begins &1 "
      , p-bik)
    ).
apply "entry":u to sch-bik in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame 
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-code-bank like ub.fin-bank.code-bank no-undo.
define variable v-code-bank as character no-undo.
display
"":U @ sch-BIK
with frame {&frame-name}.
assign
v-code-bank = string(p-code-bank).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-bank.code-bank = &1 "
      , v-code-bank)
    ).
apply "entry":u to sch-code in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name Dialog-Frame 
PROCEDURE proc-find-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-name as character no-undo.
display
"0":U @ sch-code
"":U @ sch-bik
with frame {&frame-name}.
assign
p-name = replace(p-name, {&double-quote}, {&double-quote} + {&double-quote})
p-name = replace(p-name, {&single-quote}, {&single-quote} + {&single-quote})
p-name = {&double-quote} + p-name + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-bank.bank-name   begins &1 "
      , p-name)
    ).
apply "entry":u to sch-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-fin-bank then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
&scop fields-name-list  "addres,addres1,bank-name,bank-city,cl-bank,bik,code-bank,cor-acc,rkc,e-mail,fax,host-code,inn,kpp,licenz,okato,okonx,okpo,otdel,phone,PS,short-name,status_"
define variable v-label-param as character no-undo .

v-label-param =
  "addres" + {&delim-par} + "Адрес юридический" + {&delim-par} + "" + {&delim-flf}
 + "addres1" + {&delim-par} + "Адрес почтовый" + {&delim-par} + "" + {&delim-flf}
 + "bank-name" + {&delim-par} + "Название" + {&delim-par} + "" + {&delim-flf}
 + "bank-city" + {&delim-par} + "Город" + {&delim-par} + "" + {&delim-flf}
 + "cl-bank" + {&delim-par} + "Система Клиент-Банк" + {&delim-par} + "" + {&delim-flf}
 + "bik" + {&delim-par} + "БИК" + {&delim-par} + "" + {&delim-flf}
 + "code-bank" + {&delim-par} + "Код банка" + {&delim-par} + "" + {&delim-flf}
 + "cor-acc" + {&delim-par} + "№ Корр.счета" + {&delim-par} + "" + {&delim-flf}
 + "rkc" + {&delim-par} + "РКЦ" + {&delim-par} + "" + {&delim-flf}
 + "e-mail" + {&delim-par} + "E-mail" + {&delim-par} + "" + {&delim-flf}
 + "fax" + {&delim-par} + "Факс" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "inn" + {&delim-par} + "{&abbr_inn_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "kpp" + {&delim-par} + "{&abbr_kpp_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "licenz" + {&delim-par} + "Лицензия" + {&delim-par} + "" + {&delim-flf}
 + "okato" + {&delim-par} + "ОКАТО" + {&delim-par} + "" + {&delim-flf}
 + "okonx" + {&delim-par} + "{&abbr_okonh_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "okpo" + {&delim-par} + "ОКПО" + {&delim-par} + "" + {&delim-flf}
 + "otdel" + {&delim-par} + "Отделение" + {&delim-par} + "" + {&delim-flf}
 + "phone" + {&delim-par} + "Телефон" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечания" + {&delim-par} + "" + {&delim-flf}
 + "short-name" + {&delim-par} + "Укороченное название" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-fin-bank:handle
                                            ,input  {&table_fin-bank}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


Open QUery br-changes for each temp-changes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

