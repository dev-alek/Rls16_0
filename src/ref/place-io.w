&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-pl-list


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_place-io FOR ub.place-io.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-pl-list
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник мест приемки/отгрузки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/03/09
Author: Dmitry Ukhanov
Creation date: 02/03/09

Автор1: Кочетков Михаил Юрьевич
Дата создания1: 04/27/06

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input param bttns as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-type as character no-undo .
define input-output parameter rid-list as character no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "справочник мест приемки/отгрузки" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }


define variable filter-point as character no-undo init "Места приемки/отгрузки" .
define variable sort-column-name as character no-undo .
define variable mark as char no-undo.
define variable v-doc-rec as recid no-undo .
define variable  p-sys-time     as character no-undo .
  define variable glog as logical no-undo .

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
&Scoped-define INTERNAL-TABLES X_place-io

/* Definitions for BROWSE br-pl                                         */
&Scoped-define FIELDS-IN-QUERY-br-pl mark X_place-io.place-io-type ~
X_place-io.place-io-code X_place-io.place-io-name ~
substitute( "&1 &2", X_place-io.obj-type, X_place-io.obj-code ) ~
X_place-io.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pl X_place-io.place-io-name
&Scoped-define ENABLED-TABLES-IN-QUERY-br-pl X_place-io
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-pl X_place-io
&Scoped-define QUERY-STRING-br-pl FOR EACH X_place-io ~
      WHERE X_place-io.obj-type = p-obj-type and X_place-io.obj-code = p-obj-code NO-LOCK
&Scoped-define OPEN-QUERY-br-pl OPEN QUERY br-pl FOR EACH X_place-io ~
      WHERE X_place-io.obj-type = p-obj-type and X_place-io.obj-code = p-obj-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-pl X_place-io
&Scoped-define FIRST-TABLE-IN-QUERY-br-pl X_place-io


/* Definitions for DIALOG-BOX d-pl-list                                 */
&Scoped-define QUERY-STRING-d-pl-list FOR EACH X_place-io SHARE-LOCK
&Scoped-define OPEN-QUERY-d-pl-list OPEN QUERY d-pl-list FOR EACH X_place-io SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-pl-list X_place-io
&Scoped-define FIRST-TABLE-IN-QUERY-d-pl-list X_place-io


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel b-add b-chg b-del B-sch ~
B-hist b-print b-help RADIO-obj RADIO-type br-pl e_PS mark-num
&Scoped-Define DISPLAYED-OBJECTS RADIO-obj RADIO-type e_PS mark-num

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
     SIZE 10 BY 1.

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 10 BY 1.

DEFINE VARIABLE e_PS LIKE X_place-io.PS
     VIEW-AS EDITOR
     SIZE 98.5 BY 1.92 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4.38 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RADIO-obj AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущий", 1,
"Все", 2
     SIZE 19.75 BY .88 NO-UNDO.

DEFINE VARIABLE RADIO-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Отгрузки", 1,
"Приемки", 2,
"Все", 3
     SIZE 29 BY .88 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-pl FOR
      X_place-io SCROLLING.

DEFINE QUERY d-pl-list FOR
      X_place-io SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pl d-pl-list _STRUCTURED
  QUERY br-pl NO-LOCK DISPLAY
      mark COLUMN-LABEL "*" FORMAT "X(1)":U
      X_place-io.place-io-type COLUMN-LABEL "Место" FORMAT "X(8)":U
      X_place-io.place-io-code FORMAT "9999999":U
      X_place-io.place-io-name COLUMN-LABEL "Наименование" FORMAT "X(40)":U
      substitute( "&1 &2", X_place-io.obj-type, X_place-io.obj-code ) COLUMN-LABEL "Объект" FORMAT "X(13)":U
      X_place-io.status_ FORMAT "X(8)":U
  ENABLE
      X_place-io.place-io-name
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
     B-sch AT ROW 1 COL 59
     B-hist AT ROW 1 COL 69
     b-print AT ROW 1 COL 79
     b-help AT ROW 1 COL 89
     RADIO-obj AT ROW 2.13 COL 10.75 NO-LABEL
     RADIO-type AT ROW 2.13 COL 42.88 NO-LABEL
     br-pl AT ROW 3 COL 1
     e_PS AT ROW 20.5 COL 1 HELP
          "" NO-LABEL WIDGET-ID 8
     mark-num AT ROW 1.17 COL 12.13 COLON-ALIGNED NO-LABEL
     "Объект:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 2.25 COL 1.75
          FGCOLOR 4
     "Места:" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 2.25 COL 35.5
          FGCOLOR 4
     SPACE(57.00) SKIP(19.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Места отгрузки/приемки".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_place-io B "?" ? ub place-io
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

/* SETTINGS FOR EDITOR e_PS IN FRAME d-pl-list
   LIKE = Temp-Tables.X_place-io.PS                                     */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pl
/* Query rebuild information for BROWSE br-pl
     _TblList          = "X_place-io"
     _Options          = "NO-LOCK"
     _Where[1]         = "X_place-io.obj-type = p-obj-type and X_place-io.obj-code = p-obj-code"
     _FldNameList[1]   > "_<CALC>"
"mark" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.X_place-io.place-io-type
"X_place-io.place-io-type" "Место" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = Temp-Tables.X_place-io.place-io-code
     _FldNameList[4]   > Temp-Tables.X_place-io.place-io-name
"X_place-io.place-io-name" "Наименование" ? "character" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"substitute( ""&1 &2"", X_place-io.obj-type, X_place-io.obj-code )" "Объект" "X(13)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = Temp-Tables.X_place-io.status_
     _Query            is NOT OPENED
*/  /* BROWSE br-pl */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-pl-list
/* Query rebuild information for DIALOG-BOX d-pl-list
     _TblList          = "Temp-Tables.X_place-io"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX d-pl-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-pl-list
ON CHOOSE OF b-add IN FRAME d-pl-list /* Добавить */
DO:
  define variable v-rep-rec as recid no-undo .
  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_place-io-reference_add-def':U
    {&cntxt-object}
    v-chk-act-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    glog
  }
  if NOT glog then return no-apply.
  run ref/pl-io-fm.w ( input parparentproc, input p-obj-type, input p-obj-code, input {&add-def}, input-output v-rep-rec).
  if v-rep-rec <> ? then do:
    RUn OpenBr.
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
  if not available X_place-io then do:
    message "Неправильно выбрана строка.".
    return no-apply.
  end.
  v-rep-rec = recid (X_place-io).
  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_place-io-reference_update':U
    {&cntxt-object}
    v-chk-act-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    glog
  }
  if NOT glog then return no-apply.
  run ref/pl-io-fm.w ( input parparentproc, input p-obj-type, input p-obj-code, input {&update},input-output v-rep-rec).
  if v-rep-rec <> ? then do:
    RUn OpenBr.
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
  define buffer buf_place-io for ub.place-io .

  if not available X_place-io then return no-apply.

  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_place-io-reference_deletion':U
    {&cntxt-object}
    v-chk-act-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    glog
  }
  if NOT glog then return no-apply.

  v-doc-rec = recid (X_place-io).
  glog = no.
  message "Удалить место ? Вы уверены ?" view-as alert-box question buttons OK-Cancel update glog.
  if glog <> yes then return no-apply.

  glog = br-pl:select-next-row().
  if not glog then glog = br-pl:select-prev-row().

  del-rec = recid (X_place-io).

  find buf_place-io exclusive-lock
    where recid (buf_place-io) = v-doc-rec
  .

_deletion:
  do on stop undo _deletion, return no-apply:
    delete buf_place-io.
  end.
  v-doc-rec = del-rec.
  run OpenBr.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist d-pl-list
ON CHOOSE OF B-hist IN FRAME d-pl-list /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  if not available X_place-io then return no-apply.
  run ref/pliohist.w ( INPUT parParentProc
                     , input X_place-io.obj-type
                     , input X_place-io.obj-code
                     , input X_place-io.place-io-code
                     , input "":U /*bttns  */
                     , input-output v-rid-list
                     ) no-error .
    apply "entry" to br-pl.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark d-pl-list
ON CHOOSE OF B-mark IN FRAME d-pl-list /* * */
DO:
  if available X_place-io then do:
    { gbl/markstrn.i X_place-io rid-list }
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
  if available X_place-io then do:
    message "Еще не реализовано!" view-as alert-box.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch d-pl-list
ON CHOOSE OF B-sch IN FRAME d-pl-list /* Фильтр */
DO:

  assign
  tbl = 'place-io'
  join-tbl = 'X_place-io'
  fld = "":U
  lab = '':U
  spr = '':U
  dim = '0':U
  .
  run fltfield-add in this-procedure ('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('place-io-type', 'Тип места', '',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('place-io-code', 'Код места', '',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('place-io-name', 'Название места', '',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Статус', '',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS', 'Примечание', '',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
    run gbl/filter.w (parparentproc, filter-point, tbl, join-tbl, fld, lab, spr, dim).
    RUN OpenBr.
  END .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-pl-list
ON CHOOSE OF b-sel IN FRAME d-pl-list /* Выбор  */
DO:
  if ( available X_place-io AND rid-list = "" ) then rid-list = string( recid( X_place-io ) ) .
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
  if available X_place-io then do:
    assign
      e_PS = X_place-io.PS
    .
    display
      e_PS
      with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-obj d-pl-list
ON VALUE-CHANGED OF RADIO-obj IN FRAME d-pl-list
DO:
  assign RADIO-obj .

  if RADIO-obj = 1 then do:
    assign p-mode = {&g___object} .
    if can-do ("b-add", bttns) then  ENABLE b-add  b-chg  b-del with frame {&frame-name}.
  end.
  else do:
    assign p-mode = {&all} .
    DISABLE b-add  b-chg  b-del with frame {&frame-name}.
  end.
  RUN OpenBr.
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
    when 2 then assign p-type = {&place-in} .
    when 1 then assign p-type = {&place-out} .
  end.
  RUN OpenBr.
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
{ gbl/brwrefre.i "v-doc-rec = recid(X_place-io). run openbr in this-procedure. reposition br-pl to recid(v-doc-rec). v-doc-rec = ? . " }
{ gbl/brwrepos.i &line-num=5 }


{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &ext-col        = 6
  &start-column   = "2"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_place-io.place-io-type"
  &sort-clmn_2    = "X_place-io.place-io-code"
  &sort-clmn_3    = "X_place-io.place-io-name"
  &sort-clmn_5    = "X_place-io.status_"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


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
    when 'all'        then assign RADIO-type = 3 .
    when {&place-in}  then assign RADIO-type = 2 .
    when {&place-out} then assign RADIO-type = 1 .
  end.
  if p-mode = {&g___object} then assign RADIO-obj = 1 .
  else                           assign RADIO-obj = 2 .
  DISPLAY RADIO-obj RADIO-type  WITH FRAME {&frame-name}.

  RUN enable_UI.
  RUN OpenBR.

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
  X_place-io.place-io-name:read-only in browse {&BROWSE-NAME} = true.

ENABLE b-quit b-print b-help br-pl RADIO-obj RADIO-type
   b-sel when can-do ("b-sel", bttns)
   b-mark when can-do ("b-mark", bttns)
   b-add when can-do ("b-add", bttns)
   b-chg when can-do ("b-add", bttns)
   b-del when can-do ("b-add", bttns)
   b-sch
   b-hist
   with frame {&frame-name}.
   HIDE
   b-print
   in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr d-pl-list
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .

  define buffer buf_clients for ub.clients .

  run waitfram-show in this-procedure ("Ждите...").

  if sort-column-name = "" then assign sort-column-phrase = "" .
  else                          assign sort-column-phrase = "by " + sort-column-name .

  &scop flt-open-query-handle  QUERY br-pl:handle
  &scop flt-open-dyn_open-query  FOR EACH X_place-io
  &scop flt-open-open-query OPEN QUERY br-pl FOR EACH X_place-io
  &scop flt-open-open-query-tail
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-waitfram yes

  CASE p-mode :
    when {&g___object} then do:
      FIND FIRST buf_clients NO-LOCK WHERE buf_clients.obj-type = p-obj-type AND buf_clients.obj-code = p-obj-code NO-ERROR.
      if p-type = 'all' then do:
        ASSIGN frame {&frame-name}:TITLE = "Места приемки/отгрузки " + buf_clients.obj-name    filter-point = "Места приемки/отгрузки" + p-mode.
        { gbl/fltopend.i
           &where-cond = " X_place-io.obj-type = p-obj-type AND X_place-io.obj-code = p-obj-code "
           &DYN_where-cond = " substitute(' X_place-io.obj-type = &3&1&3 AND X_place-io.obj-code  = &2 ', p-obj-type, p-obj-code, ~{&double-quote~}) "
           &use-ind = "  "
           &by = "  "
         }
      end.
      else do:
        if p-type = {&place-in} then ASSIGN frame {&frame-name}:TITLE = "Места приемки " + buf_clients.obj-name   filter-point = "Места приемки " + p-mode .
        else                         ASSIGN frame {&frame-name}:TITLE = "Места отгрузки " + buf_clients.obj-name  filter-point = "Места отгрузки " + p-mode .
        { gbl/fltopend.i
          &where-cond = " X_place-io.obj-type = p-obj-type AND X_place-io.obj-code = p-obj-code and X_place-io.place-io-type = p-type "
          &DYN_where-cond = " substitute(' X_place-io.obj-type = &4&1&4 AND X_place-io.obj-code  = &2 and X_place-io.place-io-type = &4&3&4 ', p-obj-type, p-obj-code, p-type, ~{&double-quote~}) "
          &use-ind = "  "
          &by = "  "
        }
      end.
    end.
    when {&all} then do:
      if p-type = 'all' then do:
        ASSIGN frame {&frame-name}:TITLE = "Места приемки/отгрузки "    filter-point = "Места приемки/отгрузки" + p-mode .
        { gbl/fltopend.i
          &where-cond = " TRUE "
          &DYN_where-cond = " substitute(' TRUE ') "
          &use-ind = "  "
          &by = "  "
        }
      end.
      else do:
        if p-type = {&place-in} then ASSIGN frame {&frame-name}:TITLE = "Места приемки "   filter-point = "Места приемки " + p-mode .
        else                         ASSIGN frame {&frame-name}:TITLE = "Места отгрузки "  filter-point = "Места отгрузки " + p-mode .
        { gbl/fltopend.i
          &where-cond = " X_place-io.place-io-type = p-type "
          &DYN_where-cond = " substitute(' X_place-io.place-io-type = &2&1&2 ', p-type, ~{&double-quote~}) "
          &use-ind = "  "
          &by = "  "
        }
      end.
    end.
  END CASE.

  if v-doc-rec <> ? then reposition br-pl to recid v-doc-rec no-error.
  apply "entry" to br-pl in frame {&frame-name}.
  if avail X_place-io then APPLY "VALUE-CHANGED":U to br-pl.
  run waitfram-hide in this-procedure .
  apply "value-changed" to br-pl in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
