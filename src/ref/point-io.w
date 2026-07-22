&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-pl-list


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_point-io FOR ub.point-io.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-pl-list
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник пунктов отгрузки/доставки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/09
Author: Bakhtadze Natalya
Creation date: 09/29/09

Кочетков Михаил Юрьевич

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns         as character no-undo.
define input parameter p-db-num      as integer   no-undo .
define input parameter p-cli-type like ub.clients.obj-type no-undo .
define input parameter p-cli-code like ub.clients.obj-code no-undo .
define input parameter p-mode        as character no-undo .
define input parameter p-type        as character no-undo .
define input-output parameter rid-list as character no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "справочник пунктов отгрузки/доставки" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }

define variable filter-point0 as character no-undo init "pointios" .
define variable filter-label0 as character no-undo init "Пункты отгрузки/доставки" .
define variable filter-point as character no-undo init "pointios" .
define variable filter-label as character no-undo init "Пункты отгрузки/доставки" .
define variable sort-column-name as character no-undo .
define variable mark as char no-undo.
define variable v-doc-rec as recid no-undo .
define variable  p-sys-time     as character no-undo .
define variable glog as logical no-undo .
define variable v-cli-type like ub.clients.obj-type no-undo .
define variable v-cli-code like ub.clients.obj-code no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-pl-list
&Scoped-define BROWSE-NAME br-pl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_point-io

/* Definitions for BROWSE br-pl                                         */
&Scoped-define FIELDS-IN-QUERY-br-pl mark X_point-io.point-type X_point-io.db-num X_point-io.point-code X_point-io.cli-type + STRING(X_point-io.cli-code) X_point-io.point-name X_point-io.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pl X_point-io.point-name
&Scoped-define ENABLED-TABLES-IN-QUERY-br-pl X_point-io
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-pl X_point-io
&Scoped-define SELF-NAME br-pl
&Scoped-define QUERY-STRING-br-pl FOR EACH X_point-io  WHERE          X_point-io.cli-type = p-cli-type        and X_point-io.cli-code = p-cli-code NO-LOCK
&Scoped-define OPEN-QUERY-br-pl OPEN QUERY {&SELF-NAME} FOR EACH X_point-io  WHERE          X_point-io.cli-type = p-cli-type        and X_point-io.cli-code = p-cli-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-pl X_point-io
&Scoped-define FIRST-TABLE-IN-QUERY-br-pl X_point-io


/* Definitions for DIALOG-BOX d-pl-list                                 */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel b-add b-chg b-del b-lkp ~
B-sch B-hist b-print b-help RADIO-cli RADIO-DB RADIO-type br-pl E-ps ~
mark-num
&Scoped-Define DISPLAYED-OBJECTS RADIO-cli RADIO-DB RADIO-type E-ps ~
mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 3 BY 1.

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 10 BY 1.

DEFINE VARIABLE E-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 1.87 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4.4 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RADIO-cli AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Выбор", 2
     SIZE 16.8 BY .87 NO-UNDO.

DEFINE VARIABLE RADIO-DB AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущая", 1,
"Все", 2
     SIZE 16.8 BY .87 NO-UNDO.

DEFINE VARIABLE RADIO-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Отгрузки", 1,
"Приемки", 2,
"Все", 3
     SIZE 29 BY .87 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-pl FOR
      X_point-io SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pl d-pl-list _FREEFORM
  QUERY br-pl NO-LOCK DISPLAY
      mark COLUMN-LABEL "*" FORMAT "X(1)":U
      X_point-io.point-type FORMAT "X(8)":U
      X_point-io.db-num FORMAT ">>>>9":U
      X_point-io.point-code FORMAT "9999999":U
      X_point-io.cli-type + STRING(X_point-io.cli-code)
      X_point-io.point-name FORMAT "X(40)":U
      X_point-io.status_ FORMAT "X(8)":U
          enable
          X_point-io.point-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-pl-list
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 19
     b-add AT ROW 1 COL 29
     b-chg AT ROW 1 COL 39
     b-del AT ROW 1 COL 49
     b-lkp AT ROW 1 COL 59 WIDGET-ID 4
     B-sch AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     b-print AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     RADIO-cli AT ROW 2.03 COL 81.5 NO-LABEL
     RADIO-DB AT ROW 2.17 COL 5.8 NO-LABEL
     RADIO-type AT ROW 2.17 COL 33.9 NO-LABEL
     br-pl AT ROW 3 COL 1
     E-ps AT ROW 20.47 COL 1 NO-LABEL WIDGET-ID 2
     mark-num AT ROW 1.17 COL 12.1 COLON-ALIGNED NO-LABEL
     "Пункты:" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 2.27 COL 26
          FGCOLOR 4
     "Контрагенты:" VIEW-AS TEXT
          SIZE 14 BY .67 AT ROW 2.27 COL 66.1
          FGCOLOR 4
     "БД:" VIEW-AS TEXT
          SIZE 4 BY .67 AT ROW 2.27 COL 1.8
          FGCOLOR 4
     SPACE(93.69) SKIP(19.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Пункты отгрузки/приемки".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_point-io B "?" ? ub point-io
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-pl-list
   FRAME-NAME                                                           */
/* BROWSE-TAB br-pl RADIO-type d-pl-list */
ASSIGN
       FRAME d-pl-list:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pl
/* Query rebuild information for BROWSE br-pl
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_point-io  WHERE
         X_point-io.cli-type = p-cli-type
       and X_point-io.cli-code = p-cli-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "point-io.cli-type = p-cli-type and point-io.cli-code = p-cli-code"
     _Query            is NOT OPENED
*/  /* BROWSE br-pl */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-pl-list
/* Query rebuild information for DIALOG-BOX d-pl-list
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-pl-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-pl-list
ON CHOOSE OF b-add IN FRAME d-pl-list /* Добавить */
DO:
  define variable v-rep-rec as recid no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_point-io-reference_add-def':U
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
  if NOT glog then return no-apply.
  run ref/pt-io-fm.w ( input parparentproc
                     , input p-db-num
                     , input p-cli-type
                     , input p-cli-code
                     , input {&add-def}
                     , input-output v-rep-rec).
  if v-rep-rec <> ? then do:
    RUn OpenBr in this-procedure ( input yes, input no, input no).
    apply "entry" to br-pl in frame {&frame-name}.
  end.
  else do:
    apply "entry" to br-pl in frame {&frame-name}.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-pl-list
ON CHOOSE OF b-chg IN FRAME d-pl-list /* Изменить */
DO:
  define variable v-rep-rec as recid no-undo .
  if not available X_point-io then do:
    message "Неправильно выбрана строка.".
    return no-apply.
  end.
  v-rep-rec = recid (X_point-io).
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_point-io-reference_update':U
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

  if NOT glog then return no-apply.
  run ref/pt-io-fm.w ( input parparentproc
                     , input p-db-num
                     , input p-cli-type
                     , input p-cli-code
                     , input {&update}
                     , input-output v-rep-rec).
  if v-rep-rec <> ? then do:
    RUn OpenBr in this-procedure ( input yes, input no, input no).
    apply "entry" to br-pl in frame {&frame-name}.
  end.
  else do:
    apply "entry" to br-pl in frame {&frame-name}.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-pl-list
ON CHOOSE OF b-del IN FRAME d-pl-list /* Удалить */
DO:
  define variable del-rec as recid no-undo.
  if not available X_point-io then return no-apply.
  define buffer buf_point-io for ub.point-io.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_point-io-reference_deletion':U
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
  if NOT glog then return no-apply.

  v-doc-rec = recid (X_point-io).
  glog = no.
  message
  "Удалить(Восстановить) пункт ? Вы уверены ?"
  view-as alert-box question buttons OK-Cancel update glog.
  if glog <> yes then return no-apply.

  glog = br-pl:select-next-row().
  if not glog then glog = br-pl:select-prev-row().

  del-rec = recid (X_point-io).

  find buf_point-io where recid (buf_point-io) = v-doc-rec.

_deletion:
  do on stop undo _deletion, return no-apply:
    assign
    buf_point-io.status_ = (if buf_point-io.status_ = {&deleted-status}
                        then {&current-status}
                        else {&deleted-status}).
  end.
  v-doc-rec = del-rec.
  run OpenBr in this-procedure ( input yes, input no, input no).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist d-pl-list
ON CHOOSE OF B-hist IN FRAME d-pl-list /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  if not available X_point-io then return no-apply.
  run ref/ptiohist.w ( INPUT parParentProc
                     , input X_point-io.db-num
                     , input X_point-io.point-code
                     , input "":U /*bttns  */
                     , input-output v-rid-list
                     ) no-error .
    apply "entry" to br-pl.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-pl-list
ON CHOOSE OF b-lkp IN FRAME d-pl-list /* Просмотр */
DO:
  define variable v-rep-rec as recid no-undo .
  if not available X_point-io then do:
    message "Неправильно выбрана строка.".
    return no-apply.
  end.
  v-rep-rec = recid (X_point-io).
  run ref/pt-io-fm.w ( input parparentproc
                     , input X_point-io.db-num
                     , input X_point-io.cli-type
                     , input X_point-io.cli-code
                     , input {&lookup}
                     , input-output v-rep-rec) NO-ERROR.
  apply "entry" to br-pl in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark d-pl-list
ON CHOOSE OF B-mark IN FRAME d-pl-list /* * */
DO:
  if available X_point-io then do:
    { gbl/markstrn.i X_point-io rid-list }
    br-pl:refresh().
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-pl:select-next-row ().
      apply "iteration-changed" to br-pl in frame {&frame-name}.
    end.
    if num-entries( rid-list ) = 0 then hide mark-num in frame {&frame-name}.
    else                                disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-pl in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-pl-list
ON CHOOSE OF b-print IN FRAME d-pl-list /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-pl.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch d-pl-list
ON CHOOSE OF B-sch IN FRAME d-pl-list /* Фильтр */
DO:

  assign
  tbl = 'point-io'
  join-tbl = 'X_point-io'
  fld = "":U
  lab = '':U
  spr = '':U
  dim = '0':U
  .
  run fltfield-add in this-procedure('point-type', 'Тип места', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('db-num', 'БД', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('point-code', 'Код места', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-code', 'Код контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type', 'Тип контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('point-name', 'Название места', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('address', 'Адрес', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('dist', 'Километраж', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Статус', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS', 'Примечание', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
    run gbl/filter.w (parparentproc, filter-point, tbl, join-tbl, fld, lab, spr, dim).
    RUN OpenBr in this-procedure ( input yes, input no, input no).
  END .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-pl-list
ON CHOOSE OF b-sel IN FRAME d-pl-list /* Выбор  */
DO:
  if ( available X_point-io AND rid-list = "" ) then rid-list = string( recid( X_point-io ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-pl
&Scoped-define SELF-NAME br-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-pl d-pl-list
ON MOUSE-SELECT-DBLCLICK OF br-pl IN FRAME d-pl-list
DO:
  apply "CHOOSE" to b-sel in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-pl d-pl-list
ON VALUE-CHANGED OF br-pl IN FRAME d-pl-list
DO:
  if available X_point-io then
  e-ps:SCREEN-VALUE = X_point-io.PS .
  ELSE e-ps:SCREEN-VALUE = ''.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-cli d-pl-list
ON VALUE-CHANGED OF RADIO-cli IN FRAME d-pl-list
DO:
 define variable  v-rid-list as character no-undo .
 define buffer buf_clients for ub.clients.
  assign RADIO-cli .

  if RADIO-cli = 1 then do:
    assign
      v-cli-type = ''
      v-cli-code = 0
    .
  end.
  else do:

    run ref/cli-all.w ( input parParentProc
                       ,input "b-sel"
                       ,input {&all}
                       ,input {&all}
                       ,input {&current}
                       ,input ?
                       ,input ",,,,,,NO,,":u
                       ,input "without-obj":U
                       ,output v-rid-list ) .
    if v-rid-list <> "" then do:
      find first buf_clients no-lock where
             RECID(buf_clients) = int (v-rid-list) no-error.
      assign
      v-cli-type = buf_clients.obj-type
      v-cli-code = buf_clients.obj-code
      .
    end.
    else  assign RADIO-cli = 1 .
  end.
  display RADIO-cli    with frame {&frame-name}.
  RUN OpenBr in this-procedure ( input yes, input no, input no).
  apply "entry" to br-pl .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-DB
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-DB d-pl-list
ON VALUE-CHANGED OF RADIO-DB IN FRAME d-pl-list
DO:
  assign RADIO-DB .

  if RADIO-DB = 1 then do:
    assign p-mode = {&g___object} .
    if lookup("b-add", bttns) > 0 then do:
       ENABLE
       b-add
       b-chg
       b-del
       with frame {&frame-name}.
    end.
  end.
  else do:
    assign p-mode = {&all} .
    DISABLE
    b-add
    b-chg
    b-del
    with frame {&frame-name}.
  end.
  RUN OpenBr in this-procedure ( input yes, input no, input no).
  apply "entry" to br-pl .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-type d-pl-list
ON VALUE-CHANGED OF RADIO-type IN FRAME d-pl-list
DO:
  assign RADIO-type .
  case RADIO-type :
    when 3 then assign p-type = 'all' .
    when 2 then assign p-type = {&point-in} .
    when 1 then assign p-type = {&point-out} .
  end.
  RUN OpenBr in this-procedure ( input yes, input no, input no).
  apply "entry" to br-pl .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-pl-list


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/brwrefre.i "v-doc-rec = recid(X_point-io). run openbr in this-procedure ( input yes, input no, input no). reposition br-pl to recid(v-doc-rec). v-doc-rec = ? . " }
{ gbl/brwrepos.i &line-num=5 }


{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &ext-col        = 6
  &start-column   = "2"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_point-io.point-type"
  &sort-clmn_2    = "X_point-io.point-code"
  &sort-clmn_3    = "X_point-io.point-name"
  &sort-clmn_5    = "X_point-io.status_"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  if rid-list <> "":U then assign v-doc-rec = integer(entry(1, rid-list)).

  case p-type :
    when 'all'         then assign RADIO-type = 3 .
    when {&point-in }  then assign RADIO-type = 2 .
    when {&point-out } then assign RADIO-type = 1 .
  end.
  if p-mode = {&g___object} then assign RADIO-db = 1 .
  else                           assign RADIO-db = 2 .

  if p-cli-code > 0 then do: /* конкретный клиент */
    assign
      v-cli-type = p-cli-type
      v-cli-code = p-cli-code
    .
    assign RADIO-cli = 2 .
  end.
  else do:
    assign RADIO-cli = 1 .
    ENABLE RADIO-cli with frame {&frame-name}.
  end.

  DISPLAY RADIO-db RADIO-type RADIO-cli WITH FRAME {&frame-name}.

  RUN enable_UI.
  RUN OpenBR in this-procedure ( input yes, input no, input no).

  { gbl/mv-clmn.i
    &browse-name = "br-pl"
    &frame-name = "{&frame-name}"
    &start-column = "2"
    &prev-order-column_1 = "'1,2,3,4,5,6'"
    &prev-order-column-condition_1 = " p-mode = {&g___object} "
    &prev-order-column_2 = "'1,2,5,6,3,4'"
    &prev-order-column-condition_2 = " p-mode = {&all} "
    &ext-col = 6
  }
  APPLY "ENTRY" to br-pl.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-pl.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-pl-list  _DEFAULT-DISABLE
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
  HIDE FRAME d-pl-list.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-pl-list
PROCEDURE enable_UI :
assign
X_point-io.point-name:read-only in browse {&BROWSE-NAME} = true.
ENABLE
b-quit
b-print
b-help
br-pl
E-ps
RADIO-db
RADIO-type
b-sel  when lookup("b-sel", bttns ) > 0
b-mark when lookup("b-mark", bttns) > 0
b-add  when lookup("b-add", bttns ) > 0
b-chg  when lookup("b-add", bttns ) > 0
b-del  when lookup("b-add", bttns ) > 0
b-lkp
b-sch
b-hist
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr d-pl-list
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define buffer buf_clients for ub.clients.

run waitfram-show in this-procedure ("Ждите...").

if sort-column-name = "" then assign sort-column-phrase = "" .
else                          assign sort-column-phrase = "by " + sort-column-name .

&scop flt-open-query-handle  QUERY br-pl:handle

&scop flt-open-dyn_open-query  FOR EACH X_point-io

&scop flt-open-open-query OPEN QUERY br-pl FOR EACH X_point-io

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-waitfram yes
assign
filter-point = filter-point0 + p-mode
filter-label = filter-label0 + p-mode
.

if v-cli-code > 0 then do: /* конкретный клиент */
  FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = v-cli-type
        AND buf_clients.obj-code = v-cli-code NO-ERROR.
  if p-type = 'all' then do:
    ASSIGN
    frame {&frame-name}:TITLE = substitute("&1 &2"
                                           , filter-label0
                                           , buf_clients.obj-name)
    .
    if p-mode = {&g___object} then do:    /* текущая БД  */
      { gbl/fltopend.i
        &where-cond = " X_point-io.cli-type = p-cli-type AND X_point-io.cli-code = p-cli-code and X_point-io.db-num = p-db-num "
        &DYN_where-cond = " substitute(' X_point-io.cli-type = &4&1&4 AND X_point-io.cli-code  = &2 AND X_point-io.db-num  = &3 ', p-cli-type, p-cli-code, p-db-num, ~{&double-quote~}) "
        &use-ind = "  "
        &by = "  "
      }
    end.
    else do:
      { gbl/fltopend.i
        &where-cond = " X_point-io.cli-type = p-cli-type AND X_point-io.cli-code = p-cli-code "
        &DYN_where-cond = " substitute(' X_point-io.cli-type = &3&1&3 AND X_point-io.cli-code  = &2 ', p-cli-type, p-cli-code, ~{&double-quote~}) "
        &use-ind = "  "
        &by = "  "
      }
    end.
  end.
  else do:
    if p-type = {&point-in} then do:
      ASSIGN
      frame {&frame-name}:TITLE = substitute("Пункты доставки  - &1"
                                            , buf_clients.obj-name)
      .
    end.
    else do:
      ASSIGN
      frame {&frame-name}:TITLE = substitute("Пункты отгрузки  - &1"
                                              , buf_clients.obj-name  )
      .
    end.
    if p-mode = {&g___object} then do:    /* текущая БД  */
      { gbl/fltopend.i
        &where-cond = " X_point-io.cli-type = p-cli-type AND X_point-io.cli-code = p-cli-code and X_point-io.point-type = p-type and X_point-io.db-num = p-db-num "
        &DYN_where-cond = " substitute(' X_point-io.cli-type = &5&1&5 AND X_point-io.cli-code  = &2 and X_point-io.point-type = &5&3&5 AND X_point-io.db-num  = &4 ', p-cli-type, p-cli-code, p-type, p-db-num, ~{&double-quote~}) "
        &use-ind = "  "
        &by = "  "
      }
    end.
    else do:
      { gbl/fltopend.i
        &where-cond = " X_point-io.cli-type = p-cli-type AND X_point-io.cli-code = p-cli-code and X_point-io.point-type = p-type "
        &DYN_where-cond = " substitute(' X_point-io.cli-type = &4&1&4 AND X_point-io.cli-code  = &2 and X_point-io.point-type = &4&3&4 ', p-cli-type, p-cli-code, p-type, ~{&double-quote~}) "
        &use-ind = "  "
        &by = "  "
      }
    end.
  end.
end.
else do:
  if p-type = 'all' then do:
    ASSIGN
    frame {&frame-name}:TITLE = substitute("&1", filter-label0)
    .
    if p-mode = {&g___object} then do:    /* текущая БД  */
      { gbl/fltopend.i
        &where-cond = "  X_point-io.db-num = p-db-num "
        &DYN_where-cond = " substitute(' X_point-io.db-num  = &1 ', p-db-num) "
        &use-ind = "  "
        &by = "  "
      }
    end.
    else do:
      { gbl/fltopend.i
        &where-cond = " TRUE "
        &DYN_where-cond = " substitute(' TRUE ') "
        &use-ind = "  "
        &by = "  "
      }
    end.
  end.
  else do:
    if p-type = {&point-in} then do:
       ASSIGN
       frame {&frame-name}:TITLE = "Пункты доставки"
       .
    end .
    else do:
      ASSIGN
      frame {&frame-name}:TITLE = "Пункты отгрузки "
      .
    end.
    if p-mode = {&g___object} then do:    /* текущая БД  */
      { gbl/fltopend.i
        &where-cond = " X_point-io.point-type = p-type and X_point-io.db-num = p-db-num "
        &DYN_where-cond = " substitute(' X_point-io.point-type = &3&1&3 AND X_point-io.db-num  = &2 ', p-type, p-db-num, ~{&double-quote~}) "
        &use-ind = "  "
        &by = "  "
      }
    end.
    else do:
      { gbl/fltopend.i
        &where-cond = " X_point-io.point-type = p-type "
        &DYN_where-cond = " substitute(' X_point-io.point-type = &2&1&2 ', p-type, ~{&double-quote~}) "
        &use-ind = "  "
        &by = "  "
      }
    end.
  end.
end.

if v-doc-rec <> ? then reposition br-pl to recid v-doc-rec no-error.
apply "entry" to br-pl in frame {&frame-name}.
if avail X_point-io then APPLY "VALUE-CHANGED":U to br-pl.
run waitfram-hide in this-procedure .
apply "value-changed" to br-pl in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print d-pl-list
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
DEFINE VARIABLE v-cli-type AS CHARACTER NO-UNDO.

DEFINE FRAME point-io-list
X_point-io.point-type FORMAT "X(8)":U
X_point-io.db-num FORMAT ">>>>9":U
X_point-io.point-code FORMAT "9999999":U
v-cli-type column-label "Контрагент" format "X(12)"
X_point-io.point-name FORMAT "X(40)":U
X_point-io.status_ FORMAT "X(8)":U
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME point-io-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_point-io).
DO WHILE available X_point-io :
  GET prev br-pl.
END.
GET next br-pl.
DO WHILE available X_point-io :
  Display STREAM PrnLibStream
  X_point-io.point-type
  X_point-io.db-num
  X_point-io.point-code
  X_point-io.cli-type + STRING(X_point-io.cli-code) @ v-cli-type
  X_point-io.point-name
  X_point-io.status_
  with FRAME point-io-list .
  DOWN STREAM PrnLibStream 1
  with FRAME point-io-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-pl.
END.
UNDERLINE  STREAM PrnLibStream
X_point-io.point-type
X_point-io.db-num
X_point-io.point-code
v-cli-type
X_point-io.point-name
X_point-io.status_
with FRAME point-io-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_point-io.point-name
accum-count @ X_point-io.point-code
with frame point-io-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME point-io-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-pl to recid v-doc-rec no-error.
APPLY "entry" to br-pl.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
