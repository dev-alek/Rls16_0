&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список счетов-фактур

Автор: Чернова Светлана Александровна
Дата создания: 10/10/05
Author: Svetlana Chernova
Creation date: 10/10/05

*/

/* Parameters Definitions */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code    as integer   no-undo .  /* надо передавать фирму */
define input  parameter p-cli-type     as character no-undo .  /* ? - все контрагенты, или указать */
define input  parameter p-cli-code     as integer   no-undo .  /* ? - все контрагенты, или указать */
define input  parameter p-doc-num      as integer   no-undo .  /* ? - все договора, или указать */
define input  parameter p-in-doc-type      as character no-undo .
define input  parameter p-in-ext-doc-type  as character no-undo .
define input  parameter p-in-doc-code      as character no-undo .
define input  parameter bttns          as character no-undo . /* кнопки для нажатия */
define input  parameter p-mode         as character no-undo . /* new ,fact, all, in-doc */
define input-output param p-rid-list   as character no-undo . /* recid выбранных договоров */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Список счетов-фактур" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ trg/factord.i  }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }

define buffer buf_schet-fact-doc  for ub.schet-fact-doc .

define variable p-type    as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable sort-column-name as character no-undo .
define variable f-name    as character no-undo .
define variable is-new    as logical  initial no  no-undo .
define variable is-new1   as logical  initial no  no-undo .
define variable v-res     as logical  initial no  no-undo .
define variable g-log     as logical   no-undo .
define variable b-code    as integer   no-undo .
define variable cli-list  as character no-undo .
define variable cont-list as character no-undo .
define variable  p-sys-date     as date      no-undo .
define variable  p-sys-time     as character no-undo .
define variable  p-sys-time-int as integer   no-undo .


define variable filter-point as character no-undo init "Список счетов-фактур" .

  DEFINE temp-table temp-conn no-undo
    field   ri             as  recid
/*    field   ind            as integer*/
    INDEX pi  IS PRIMARY   ri
  .


&scop col-l0  '*'
&scop col-l1  'Номер'
&scop col-l12 'БД'
&scop col-l11 '№ в книге'
&scop col-l2  'Дата'
&scop col-l3  'Статус'
&scop col-l31  'Дата факт'
&scop col-l4  'Поставщик'
&scop col-l5  'Сумма'
&scop col-l6  'Наим. поставщика'
&scop col-l7  'Тип'
&scop col-l8  'По док-ту'
&scop col-l9  'Вн.N договора'
&scop col-l10 'Оператор'

&scop cop-l0  mark-string(recid(buf_schet-fact-doc))
&scop cop-l1  buf_schet-fact-doc.doc-code
&scop cop-l12 buf_schet-fact-doc.db-num
&scop cop-l11 buf_schet-fact-doc.book-code
&scop cop-l2  buf_schet-fact-doc.doc-date
&scop cop-l3  buf_schet-fact-doc.status_
&scop cop-l31 buf_schet-fact-doc.fact-date
&scop cop-l4  string( buf_schet-fact-doc.cli-type + ' ' + string(buf_schet-fact-doc.cli-code))
&scop cop-l5  buf_schet-fact-doc.sum-rubl
&scop cop-l6  buf_schet-fact-doc.cli-name
&scop cop-l7  buf_schet-fact-doc.ext-doc-type
&scop cop-l8  buf_schet-fact-doc.in-doc-code
&scop cop-l9  buf_schet-fact-doc.contract-code
&scop cop-l10 usrfulnf(buf_schet-fact-doc.user-name)
&scop dyn_cop-l10 substitute('dynamic-function(&1usrfulnf&1, &1&2&1)', ~{&double-quote~}, buf_schet-fact-doc.user-name)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME Doc-List

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_schet-fact-doc

/* Definitions for BROWSE Doc-List                                      */
&Scoped-define FIELDS-IN-QUERY-Doc-List {&cop-l0} {&cop-l1} {&cop-l12} {&cop-l11} {&cop-l2} {&cop-l3} {&cop-l31} {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10}
&Scoped-define ENABLED-FIELDS-IN-QUERY-Doc-List {&cop-l2}
&Scoped-define SELF-NAME Doc-List
&Scoped-define QUERY-STRING-Doc-List FOR EACH buf_schet-fact-doc NO-LOCK indexed-reposition
&Scoped-define OPEN-QUERY-Doc-List OPEN QUERY {&SELF-NAME} FOR EACH buf_schet-fact-doc NO-LOCK indexed-reposition.
&Scoped-define TABLES-IN-QUERY-Doc-List buf_schet-fact-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Doc-List buf_schet-fact-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-add b-lkp b-chg B-del ~
B-close b-open b-gen B-Help b-exp B-print b-hist Sel-Client Sel-Contr sch-str sch-str-2 ~
Doc-List mark-num b-sch
&Scoped-Define DISPLAYED-OBJECTS Sel-Client Sel-Contr sch-str sch-str-2 mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1.

DEFINE BUTTON B-open
     LABEL "&Открыть"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-book
     LABEL "&Книга"
     SIZE 10 BY 1.

DEFINE BUTTON b-exp
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON b-gen
     LABEL "&Генерация"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE sch-str as character FORMAT "X(16)" INITIAL ""
     VIEW-AS FILL-IN
     SIZE 13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J> по номеру СФ" NO-UNDO.

DEFINE VARIABLE sch-str-2 as character FORMAT "X(16)" INITIAL ""
     VIEW-AS FILL-IN
     SIZE 13 BY 1 TOOLTIP "Поиск по номеру документа" NO-UNDO.

DEFINE VARIABLE Sel-Client AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE Sel-Contr AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 16.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Doc-List FOR  buf_schet-fact-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE Doc-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS Doc-List Dialog-Frame _FREEFORM
  QUERY Doc-List DISPLAY
      {&cop-l0}    COLUMN-LABEL {&col-l0}  Format "X(1)"
      {&cop-l1}    COLUMN-LABEL {&col-l1}  Format "X(10)"
      {&cop-l12}   COLUMN-LABEL {&col-l12} Format ">>9"
      {&cop-l11}   COLUMN-LABEL {&col-l11} Format "X(10)"
      {&cop-l2}    COLUMN-LABEL {&col-l2}
      {&cop-l3}    COLUMN-LABEL {&col-l3}
      {&cop-l31}   COLUMN-LABEL {&col-l31}
      {&cop-l4}    COLUMN-LABEL {&col-l4}  format "x(12)"
      {&cop-l5}    COLUMN-LABEL {&col-l5}  format "->>>,>>>,>>>,>>9.99"
      {&cop-l6}    COLUMN-LABEL {&col-l6}  Format "X(30)"
      {&cop-l7}    COLUMN-LABEL {&col-l7}  Format "X(3)"
      {&cop-l8}    COLUMN-LABEL {&col-l8}  Format "X(10)"
      {&cop-l9}    COLUMN-LABEL {&col-l9}
      {&cop-l10}   COLUMN-LABEL {&col-l10} Format "X(15)"
      enable {&cop-l2}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 19.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-add AT ROW 1 COL 20
     b-lkp AT ROW 1 COL 30
     b-chg AT ROW 1 COL 40
     B-del AT ROW 1 COL 50
     B-close AT ROW 1 COL 60
     B-open AT ROW 1 COL 70
     B-Help AT ROW 1 COL 90
     b-gen AT ROW 2 COL 20
     b-exp AT ROW 2 COL 30
     B-book AT ROW 2 COL 40
     B-print AT ROW 2 COL 50
     b-hist AT ROW 2 COL 60
     b-sch   AT ROW 2 COL 70
     sel-client at row 3 col 12.5 no-label
     sel-contr at row 3 col 41 no-label
     sch-str AT ROW 3 COL 71.13 COLON-ALIGNED NO-LABEL
     sch-str-2 AT ROW 3 COL 85 COLON-ALIGNED NO-LABEL
     Doc-List AT ROW 4.25 COL 1.38
     mark-num AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL
     "Поиск по № СФ:" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 3 COL 58.5
          FGCOLOR 4
     "Договоры:" VIEW-AS TEXT
          SIZE 9.5 BY 1 AT ROW 3 COL 30.5
          FGCOLOR 4
     "Поставщики:" VIEW-AS TEXT
          SIZE 11 BY 1 AT ROW 3 COL 1
          FGCOLOR 4
     SPACE(88.38) SKIP(19.46)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список счетов-фактур"
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB Doc-List sch-str sch-str Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE Doc-List
/* Query rebuild information for BROWSE Doc-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-ob NO-LOCK indexed-reposition.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE Doc-List */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_schet-fact-doc_add-def':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }

  if not g-log then  return .
  run str/s-f-doc.w (input parparentproc,input p-host-code, input v-cntxt-db-num, {&add-def}, input ?, input ?) .
  RUN OpenBr(yes, no, '':U).
  reposition doc-list to row 1 no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not available buf_schet-fact-doc then return no-apply.
  if buf_schet-fact-doc.status_ = {&fact} then do:
    if v-cntxt-db-num <> 0  then  do:
       message  "Счет-фактуру в статусе " {&fact} " на УБД изменять нельзя!" view-as alert-box.
       return no-apply.
    end.
  end.
  { gbl/chk-actg.i v-cntxt-db-num v-cntxt-userid {&action-head-code-main} 'actn_schet-fact-doc_update':U {&cntxt-firm} p-host-code '':U 0 0 0 0 true g-log }
  if not g-log then  return no-apply .

  if buf_schet-fact-doc.db-num <> v-cntxt-db-num and v-cntxt-db-num > 0 then do:
    message "Изменять счет-фактуру другой БД нельзя!" string(buf_schet-fact-doc.doc-code) " нельзя!" view-as alert-box.
    return no-apply.
  end.

  run str/s-f-doc.w (input parparentproc,input p-host-code, input buf_schet-fact-doc.db-num, {&update}, input buf_schet-fact-doc.doc-code, input ?) .
  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть */
DO:
  if not avail buf_schet-fact-doc then return no-apply.

  { gbl/chk-actg.i v-cntxt-db-num  v-cntxt-userid {&action-head-code-main} 'actn_schet-fact-doc_open':U {&cntxt-firm} p-host-code '':U 0 0 0 0 true g-log }
  if not g-log then  return .

  if  mark-num = 0 then do:
    message "Закрыть cчет-фактуру № " buf_schet-fact-doc.doc-code "?" view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.

    v-doc-rec = recid( buf_schet-fact-doc ).
    run proc-close in this-procedure (input v-doc-rec ) /*no-error*/ .
/*    if error-status:error then return no-apply.*/
  end.
  else do:
    message "Закрыть выбранные cчета-фактуры?" view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
    for each temp-conn :
      run proc-close in this-procedure (input temp-conn.ri ) no-error .
      if error-status:error then .
      else do:
        delete temp-conn .
        assign  mark-num = mark-num - 1 .
      end.
    end.
  end.
  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-open Dialog-Frame
ON CHOOSE OF B-open IN FRAME Dialog-Frame /* Закрыть */
DO:
  if not avail buf_schet-fact-doc then return no-apply.

  { gbl/chk-actg.i  v-cntxt-db-num  v-cntxt-userid   {&action-head-code-main}  'actn_schet-fact-doc_close':U  {&cntxt-firm}  p-host-code  '':U  0  0  0  0  true  g-log }
  if not g-log then  return .

  if  mark-num = 0 then do:
    message "Открыть cчет-фактуру № " buf_schet-fact-doc.doc-code "?" view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.

    v-doc-rec = recid( buf_schet-fact-doc ).
    run proc-open in this-procedure (input v-doc-rec ) no-error .
    if error-status:error then return no-apply.
  end.
  else do:
    message "Открыть выбранные cчета-фактуры?" view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
    for each temp-conn :
      run proc-open in this-procedure (input temp-conn.ri ) no-error .
      if error-status:error then .
      else do:
        delete temp-conn .
        assign  mark-num = mark-num - 1 .
      end.
    end.
  end.

  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  if not avail buf_schet-fact-doc then return no-apply.
  { gbl/chk-actg.i v-cntxt-db-num  v-cntxt-userid {&action-head-code-main} 'actn_schet-fact-doc_deletion':U {&cntxt-firm} p-host-code '':U 0 0 0 0 true g-log }
  if not g-log then return .

  if  mark-num = 0 then do:
    message  "Удалить счет-фактуру № " buf_schet-fact-doc.doc-code "?"  view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.

    v-doc-rec = recid( buf_schet-fact-doc ).
    run proc-del in this-procedure (input v-doc-rec ) no-error .
    if error-status:error then return no-apply.
  end.
  else do:
    message "Удалить выбранные cчета-фактуры?" view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
    for each temp-conn :
      run proc-del in this-procedure (input temp-conn.ri ) no-error .
      if error-status:error then .
      else do:
        delete temp-conn .
        assign  mark-num = mark-num - 1 .
      end.
    end.
  end.
  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-book
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-book Dialog-Frame
ON CHOOSE OF B-book IN FRAME Dialog-Frame /* Удалить */
DO:
  run rep/g-book.p ( input parparentproc ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exp Dialog-Frame
ON CHOOSE OF b-exp IN FRAME Dialog-Frame /* Экспорт */
DO:
  if not available buf_schet-fact-doc then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_schet-fact-doc_export':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  RUN proc-b-exp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gen Dialog-Frame
ON CHOOSE OF b-gen IN FRAME Dialog-Frame /* Генерация */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_schet-fact-doc_add-def':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .
  run str/gen-fact.w (input parparentproc,input p-host-code) .

  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  if available buf_schet-fact-doc then run str/s-f-hist.w (input parparentproc,input p-host-code, input buf_schet-fact-doc.doc-code) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not available buf_schet-fact-doc then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_schet-fact-doc_update':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .
  run str/s-f-doc.w (input parparentproc,input p-host-code, input buf_schet-fact-doc.db-num, {&lookup}, input buf_schet-fact-doc.doc-code, input ?) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  if not available buf_schet-fact-doc then return no-apply.

  find first temp-conn where temp-conn.ri = recid( buf_schet-fact-doc ) no-error  .
  if available temp-conn then do:
    delete temp-conn .
    assign  mark-num = mark-num - 1 .
  end.
  else do:
    create temp-conn .
    assign
      temp-conn.ri = recid( buf_schet-fact-doc )
      mark-num = mark-num + 1
    .
  end.
  g-log = Doc-List:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
    g-log = Doc-List:select-next-row ().
    apply "value-changed" to Doc-List in frame {&frame-name}.
  end.
  if mark-num = 0 then hide mark-num in frame {&frame-name}.
  else              display mark-num with frame {&frame-name}.
  display mark-num  with frame {&frame-name}.
  apply "entry" to Doc-List .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not available buf_schet-fact-doc then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_schet-fact-doc_update':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .
  run str/s-f-prn.p (input parparentproc, recid( buf_schet-fact-doc), input "") .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:  /* отказ - выход  */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Doc-List
&Scoped-define SELF-NAME Doc-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Doc-List Dialog-Frame
ON RETURN OF Doc-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Doc-List IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dialog-Frame
ON CTRL-J OF sch-str IN FRAME Dialog-Frame
DO:
  assign sch-str .
  run proc-find-code in this-procedure (yes, input sch-str) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dialog-Frame
ON RETURN OF sch-str IN FRAME Dialog-Frame
DO:
  assign sch-str .
  run proc-find-code in this-procedure (no, input sch-str) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-str-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str-2 Dialog-Frame
ON CTRL-J OF sch-str-2 IN FRAME Dialog-Frame
DO:
  assign sch-str-2 .
  run proc-find-doc-code in this-procedure (yes, input sch-str-2) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str-2 Dialog-Frame
ON RETURN OF sch-str-2 IN FRAME Dialog-Frame
DO:
  assign sch-str-2 .
  run proc-find-doc-code in this-procedure (no, input sch-str-2) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME Sel-Client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Sel-Client Dialog-Frame
ON VALUE-CHANGED OF Sel-Client IN FRAME Dialog-Frame
DO:
  assign Sel-Client .

/*  assign cli-list = "" .*/
  if Sel-Client = "sel" then do:
    run ref/cli-all.w (parParentProc, "b-sel", {&cmp}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output cli-list ) .
    if cli-list = "" then do:
      assign Sel-Client = "all" .
      disp Sel-Client with frame {&frame-name}.
    end.
    else do:
      define variable ii as integer   no-undo .
      do ii = 1 to num-entries (cli-list):
        find first ub.clients no-lock where recid(ub.clients) = integer (entry (ii, cli-list)) .
        assign
          p-cli-type = ub.clients.obj-type
          p-cli-code = ub.clients.obj-code
        .
      end.
    end.
  end .
  RUN OpenBr(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
    tbl = 'schet-fact-doc'
    join-tbl = 'buf_schet-fact-doc'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('doc-code', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-date', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('host-code', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Вн.Номер', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-type', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('base-rate', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('base-scale', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS',         '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('book-code', 'Номер в книге', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-address', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-inn', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-name', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-address', 'Адрес поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-inn', 'ИНН  поставщика', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type', 'Тип  поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-code', 'Код  поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-name', 'Имя  поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('Gruz-otprav', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('Gruz-poluch', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ext-doc-type', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('gtd', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('country', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-date', 'Дата прихода', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-doc-code', 'Номер док-та прих.', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-doc-date', 'Дата док-та прих.', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-code', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pay-date', 'Дата платежа', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-db-num', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-date', 'Сист. дата', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-time', 'Сист. время', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-time', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-user-db-num', 'Польз. база факт', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-user-name', 'Польз. факт', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('fact-order', 'порядок', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('sum-rubl', 'сумма {&abbr_rub}', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-base', 'сумма б.в.', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('sum-VAT-no-base', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('sum-VAT-no-rubl', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('sum-VAT-0-base', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('sum-VAT-0-rubl', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('VAT-10-base', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('VAT-10-rubl', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('sum-VAT-10-base', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('sum-VAT-10-rubl', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('VAT-20-base', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('VAT-20-rubl', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('sum-VAT-20-base', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('sum-VAT-20-rubl', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  RUN OpenBr(yes, no, '':U).
END. /* Filter-Block */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Sel-Contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Sel-Contr Dialog-Frame
ON VALUE-CHANGED OF Sel-Contr IN FRAME Dialog-Frame
DO:
  assign Sel-Contr .
/*  assign cont-list = "" .*/
  if Sel-Contr = "sel" then do:
/*    run str/cont-all.w ( parParentProc, p-host-code, "b-add,b-mark,b-sel", {&company}, ?, ?, ?, ?, "current":U, p-doc-type, input-output cont-list ) .*/
    run str/cont-all.w ( parParentProc, p-host-code, "b-sel", {&company}, ?, ?, ?, ?, "current":U, {&income}, input-output cont-list ) .
    if cont-list = "" then do:
      assign Sel-Contr = "all" .
      disp Sel-Contr with frame {&frame-name}.
    end.
    else do:
      define variable ii as integer   no-undo .
      do ii = 1 to num-entries (cont-list):
        find first ub.contract no-lock where recid(ub.contract) = integer (entry (ii, cont-list)) .
        assign p-doc-num = ub.contract.contract-code .
      end.
    end.
  end .
  RUN OpenBr(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
{ gbl/brwrefre.i " v-doc-rec = recid(buf_schet-fact-doc).  ~
  run OpenBR in this-procedure (yes, no, '':U). REPOSITION Doc-List to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to Doc-List. " }



/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/brwrepos.i  &line-num=15 }

/* сорт  колонок*/
{ gbl/srt-clmd.i
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &browse-name = "Doc-List"
  &frame-name = "{&frame-name}"
  &ext-col = 12
  &open-query     = "run OpenBr(yes, no, '':U)."
  &open-query-otherwise = "run OpenBr(yes, no, '':U)."
  &sort-column-name = "sort-column-name"
  &start-column         = "2"
  &label-clmn_1         = "{&col-l1}"
  &sort-clmn_1          = "{&cop-l1}"
  &label-clmn_2        = "{&col-l12}"
  &sort-clmn_2         = "{&cop-l12}"
  &label-clmn_3        = "{&col-l11}"
  &sort-clmn_3         = "{&cop-l11}"
  &label-clmn_4         = "{&col-l2}"
  &sort-clmn_4          = "{&cop-l2}"
  &label-clmn_5         = "{&col-l3}"
  &sort-clmn_5          = "{&cop-l3}"
  &label-clmn_6        = "{&col-l31}"
  &sort-clmn_6         = "{&cop-l31}"
  &label-clmn_7         = "{&col-l4}"
  &sort-clmn_7          = "{&cop-l4}"
  &label-clmn_8         = "{&col-l5}"
  &sort-clmn_8          = "{&cop-l5}"
  &label-clmn_9         = "{&col-l6}"
  &sort-clmn_9          = "{&cop-l6}"
  &label-clmn_10        = "{&col-l7}"
  &sort-clmn_10         = "{&cop-l7}"
  &label-clmn_11        = "{&col-l8}"
  &sort-clmn_11         = "{&cop-l8}"
  &label-clmn_12        = "{&col-l9}"
  &sort-clmn_12         = "{&cop-l9}"
  &label-clmn_13        = "{&col-l10}"
  &sort-clmn_13         = "{&cop-l10}"
  &dyn_sort-clmn_13     = "{&dyn_cop-l10}"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
 }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  assign
    Doc-List:num-locked-columns = 1
    {&cop-l2}:read-only in browse Doc-List = yes
  .

{ gbl/setfltnm.i }

/*  find first buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.contract-code = p-doc-num .*/
/*  find first ub.clients no-lock where ub.clients.obj-type = {&cmp} and ub.clients.obj-code = p-host-code .*/

  if p-mode = "new" then  assign p-type = {&fin-new} .
  else if p-mode = "fact" then assign p-type = {&fact} .

  if p-doc-num <> ? then do:
    find first ub.contract no-lock where ub.contract.contract-code = p-doc-num .
    assign cont-list = string(recid(ub.contract)) .
    assign Sel-Contr = "sel" .
  end.
  if p-cli-type <> ? and p-cli-code <> ? then do:
    find first ub.clients no-lock where ub.clients.obj-type = p-cli-type and ub.clients.obj-code = p-cli-code .
    assign cli-list = string(recid(ub.clients)) .
    assign Sel-Client = "sel" .
  end.

  RUN enable_UI.

  Run OpenBR(yes, no, '':U) .

  { gbl/mv-clmn.i   &browse-name = "Doc-List"    &frame-name = "{&frame-name}"    &ext-col = 12    &start-column = "2"  }

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
  DISPLAY Sel-Client Sel-Contr sch-str sch-str-2 mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-add b-lkp b-chg B-del B-book B-close b-gen B-Help b-exp B-open
         B-print b-hist Sel-Client Sel-Contr sch-str sch-str-2 Doc-List mark-num  b-sch
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .

  assign frame {&frame-name}:title =  " Фирма: (" + string(p-host-code) + ")":U + {&space-char} + "Счета-фактуры".

  if sort-column-name = "" then assign sort-column-phrase = "" .
  else                          assign sort-column-phrase = "by " + sort-column-name .

  &scop flt-open-open-query OPEN QUERY Doc-List FOR EACH buf_schet-fact-doc NO-LOCK
  &scop flt-open-dyn_open-query  FOR EACH buf_schet-fact-doc
  &scop flt-open-query-handle query Doc-List:handle
  &scop flt-open-waitfram true
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name set-filter-name
  &scop flt-open-query p-open-query
  &scop flt-open-table-name buf_schet-fact-doc
  &scop flt-open-search-option no-lock
  &scop flt-open-find-next p-find-next
  &scop flt-open-find-recid v-doc-rec
  &scop flt-open-find-condition p-find-condition
  &scop flt-open-find-buffer-name  buf_schet-fact-doc

  if available buf_schet-fact-doc then assign v-doc-rec = recid (buf_schet-fact-doc) .

  case p-mode:
  when "all" then do:
    if Sel-Contr = "all" then do:  /* все поставщики */
      if Sel-Client = "all" then do:  /* все договора */
        { gbl/fltopend.i
          &where-cond = " buf_schet-fact-doc.host-code = p-host-code "
          &DYN_where-cond = " substitute(' buf_schet-fact-doc.host-code = &1 ', p-host-code)"
          &use-ind    = "  "
          &by   = " by int(buf_schet-fact-doc.doc-code) descending "
        }
      end.
      else do:
        { gbl/fltopend.i
          &where-cond = " buf_schet-fact-doc.host-code = p-host-code and buf_schet-fact-doc.cli-type = p-cli-type and buf_schet-fact-doc.cli-code = p-cli-code "
          &DYN_where-cond = " substitute(' buf_schet-fact-doc.host-code = &1 and buf_schet-fact-doc.cli-type = &4&2&4 and buf_schet-fact-doc.cli-code = &3', p-host-code, p-cli-type, p-cli-code , ~{&double-quote~})"
          &use-ind    = "  "
          &by   = " by int(buf_schet-fact-doc.doc-code) descending "
        }
      end.
    end.
    else do:
      if Sel-Client = "all" then do:  /* все договора */
        { gbl/fltopend.i
          &where-cond = " buf_schet-fact-doc.host-code = p-host-code and buf_schet-fact-doc.contract-code = p-doc-num "
          &DYN_where-cond = " substitute(' buf_schet-fact-doc.host-code = &1 and buf_schet-fact-doc.contract-code = &2 ', p-host-code, p-doc-num)"
          &use-ind    = "  "
          &by   = " by int(buf_schet-fact-doc.doc-code) descending "
        }
      end.
      else do:
        { gbl/fltopend.i
          &where-cond = " buf_schet-fact-doc.host-code = p-host-code and buf_schet-fact-doc.contract-code = p-doc-num and buf_schet-fact-doc.cli-type = p-cli-type and buf_schet-fact-doc.cli-code = p-cli-code "
          &DYN_where-cond = " substitute(' buf_schet-fact-doc.host-code = &1 and buf_schet-fact-doc.contract-code = &2 and buf_schet-fact-doc.cli-type = &5&3&5 and buf_schet-fact-doc.cli-code = &4', p-host-code, p-doc-num, p-cli-type, p-cli-code , ~{&double-quote~})"
          &use-ind    = "  "
          &by   = " by int(buf_schet-fact-doc.doc-code) descending "
        }
      end.
    end.
  end.
  when "fact" or
  when "new"  then do:
    if Sel-Contr = "all" then do:  /* все договора  */
      if Sel-Client = "all" then do:  /* все поставщики */
        { gbl/fltopend.i
          &where-cond = " buf_schet-fact-doc.host-code = p-host-code and buf_schet-fact-doc.status_ = p-type "
          &DYN_where-cond = " substitute(' buf_schet-fact-doc.host-code = &1 and buf_schet-fact-doc.status_ = &3&2&3 ', p-host-code, p-type , ~{&double-quote~})"
          &use-ind    = "  "
          &by   = " by int(buf_schet-fact-doc.doc-code) descending "
        }
      end.
      else do:
        { gbl/fltopend.i
          &where-cond = " buf_schet-fact-doc.host-code = p-host-code and buf_schet-fact-doc.status_ = p-type and buf_schet-fact-doc.cli-type = p-cli-type and buf_schet-fact-doc.cli-code = p-cli-code "
          &DYN_where-cond = " substitute(' buf_schet-fact-doc.host-code = &1 and buf_schet-fact-doc.status_ = &5&2&5 and buf_schet-fact-doc.cli-type = &5&3&5 and buf_schet-fact-doc.cli-code = &4', p-host-code, p-type, p-cli-type, p-cli-code , ~{&double-quote~})"
          &use-ind    = "  "
          &by   = " by int(buf_schet-fact-doc.doc-code) descending "
        }
      end.
    end.
    else do:
      if Sel-Client = "all" then do:  /* все поставщики */
        { gbl/fltopend.i
          &where-cond = " buf_schet-fact-doc.host-code = p-host-code and buf_schet-fact-doc.status_ = p-type and buf_schet-fact-doc.contract-code = p-doc-num "
          &DYN_where-cond = " substitute(' buf_schet-fact-doc.host-code = &1 and buf_schet-fact-doc.status_ = &4&2&4 and buf_schet-fact-doc.contract-code = &3 ', p-host-code, p-type, p-doc-num , ~{&double-quote~})"
          &use-ind    = "  "
          &by   = " by int(buf_schet-fact-doc.doc-code) descending "
        }
      end.
      else do:
        { gbl/fltopend.i
          &where-cond = " buf_schet-fact-doc.host-code = p-host-code and buf_schet-fact-doc.status_ = p-type and buf_schet-fact-doc.contract-code = p-doc-num and buf_schet-fact-doc.cli-type = p-cli-type and buf_schet-fact-doc.cli-code = p-cli-code "
          &DYN_where-cond = " substitute(' buf_schet-fact-doc.host-code = &1 and buf_schet-fact-doc.status_ = &6&2&6 and buf_schet-fact-doc.contract-code = &3 and buf_schet-fact-doc.cli-type = &6&4&6 and buf_schet-fact-doc.cli-code = &5', p-host-code, p-type, p-doc-num, p-cli-type, p-cli-code , ~{&double-quote~})"
          &use-ind    = "  "
          &by   = " by int(buf_schet-fact-doc.doc-code) descending "
        }
      end.
    end.
  end.
  when "in-doc" then do:
    assign frame {&frame-name}:title = substitute("Счета-фактуры, порожденные по документу &1 ( &2 )" , p-in-doc-code , p-in-doc-type ) .
    disable b-add    Sel-Client    Sel-Contr    b-gen  with frame {&frame-name} .
   { gbl/fltopend.i
     &where-cond = " buf_schet-fact-doc.in-doc-type = p-in-doc-type and buf_schet-fact-doc.in-ext-doc-type = p-in-ext-doc-type and buf_schet-fact-doc.in-doc-code = p-in-doc-code "
     &DYN_where-cond = " substitute(' buf_schet-fact-doc.in-doc-type = &4&1&4 and buf_schet-fact-doc.in-ext-doc-type = &4&2&4 and buf_schet-fact-doc.in-doc-code = &4&3&4 ', p-in-doc-type, p-in-ext-doc-type, p-in-doc-code , ~{&double-quote~} )"
     &use-ind    = " use-index in_doc "
   }
  end.
  otherwise do:
    message "Не верно задан параметр p-mode = " p-mode view-as alert-box error .
  end.
  end case.

  REPOSITION Doc-List to recid v-doc-rec No-ERROR.
  display mark-num  with frame {&frame-name}.
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
  define input parameter p-code as character no-undo .

  assign p-code = {&double-quote} + p-code + {&double-quote}.
  run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_schet-fact-doc.doc-code = &1 ", p-code)).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-doc-code Dialog-Frame
PROCEDURE proc-find-doc-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .

  assign p-code = {&double-quote} + p-code + {&double-quote}.
  run OpenBr in this-procedure ( input false, input true , input substitute(" and buf_schet-fact-doc.in-doc-code = &1 ", p-code )).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable ret as character no-undo .
  assign ret = "" .

  find first temp-conn where temp-conn.ri = par-recid no-error .
  if available temp-conn then assign ret = "*" .

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION proc-del Dialog-Frame
procedure proc-del :
  define input  parameter p-ri as recid   no-undo .
  do on error undo, return error return-value :
    define buffer buf_factur-connect  for ub.factur-connect.
    define buffer buf_schet-fact-line for ub.schet-fact-line.

    do transaction :
      find first ub.schet-fact-doc exclusive-lock where recid(ub.schet-fact-doc) = p-ri no-error .
      if available ub.schet-fact-doc then do:
        if ub.schet-fact-doc.status_ = {&fact} then do:
          message "Удалять закрытый счет-фактуру " string(ub.schet-fact-doc.doc-code) " нельзя!" view-as alert-box.
          return error.
        end.
        if ub.schet-fact-doc.db-num <> v-cntxt-db-num and v-cntxt-db-num > 0 then do:
          message "Удалять счет-фактуру другой БД нельзя!" string(ub.schet-fact-doc.doc-code) " нельзя!" view-as alert-box.
          return error.
        end.
        define buffer buf_c-schet-fact-doc for ub.c-schet-fact-doc.
        create buf_c-schet-fact-doc .
        BUFFER-COPY ub.schet-fact-doc TO buf_c-schet-fact-doc .
        { gbl/curdburt.i  buf_c-schet-fact-doc.corr-user-db-num   buf_c-schet-fact-doc.corr-user-name   buf_c-schet-fact-doc.corr-date   p-sys-time   buf_c-schet-fact-doc.corr-time  }
        assign buf_c-schet-fact-doc.chip-num = next-value (s-corr-chip, {&db-name_schema}) .

        delete ub.schet-fact-doc .
      end.
    end.
  end.
end procedure. /* proc-del */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION proc-close Dialog-Frame
procedure proc-close :
  define input  parameter p-ri as recid   no-undo .
  do on error undo, return error return-value :
    define variable v-shift-end-fact-order as decimal   no-undo .
    define variable v-day-end-fact-order   as decimal   no-undo .
    do transaction :
      find first ub.schet-fact-doc exclusive-lock where recid(ub.schet-fact-doc) = p-ri no-error .
      if available ub.schet-fact-doc then do:
        if ub.schet-fact-doc.status_ = {&fact} then do:
          message "Счет-фактура " string(ub.schet-fact-doc.doc-code) " уже закрыт!" view-as alert-box.
          return error.
        end.
        { gbl/curdburt.i  ub.schet-fact-doc.fact-user-db-num   ub.schet-fact-doc.fact-user-name   ub.schet-fact-doc.fact-date   p-sys-time   ub.schet-fact-doc.fact-time   }
        run factord (
          input  ub.schet-fact-doc.fact-date
         ,input  ub.schet-fact-doc.fact-time
         ,input  int(ub.schet-fact-doc.doc-code)
         ,input  ?
         ,input  ?
         ,input  no
         ,output ub.schet-fact-doc.fact-order
         ,output v-shift-end-fact-order
         ,output v-day-end-fact-order
        ).
        assign ub.schet-fact-doc.status_ = {&fact}  .
      end.
    end.
  end.
end procedure. /* proc-del */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION proc-open Dialog-Frame
procedure proc-open :
  define input  parameter p-ri as recid   no-undo .
  do on error undo, return error return-value :

    do transaction :
      find first ub.schet-fact-doc exclusive-lock where recid(ub.schet-fact-doc) = p-ri no-error .
      if available ub.schet-fact-doc then do:
          if ub.schet-fact-doc.db-num <> 0 and
            v-cntxt-db-num = 0 then do:
            message "Открывать на изменение  счет-фактуру чужой БД нельзя! " view-as alert-box .
            return error.
          end.

         if ub.schet-fact-doc.status_ = {&fin-new} then do:
           message "Счет-фактура " string(ub.schet-fact-doc.doc-code) " уже открыт!" view-as alert-box.
           return error.
        end.
        { gbl/curdburt.i  ub.schet-fact-doc.fact-user-db-num   ub.schet-fact-doc.fact-user-name   p-sys-date   p-sys-time   p-sys-time-int  }
        assign
          ub.schet-fact-doc.status_    = {&fin-new}
          ub.schet-fact-doc.fact-date  = ?
          ub.schet-fact-doc.fact-order = ?
        .
      end.
    end.
  end.
end procedure. /* proc-open */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exp Dialog-Frame
PROCEDURE proc-b-exp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-file-name as character no-undo .
  define variable v-sys-key   as character         no-undo.
  { gbl/currsysk.i
    v-sys-key
    no-error
  }

  assign  v-file-name = /*"f":U + string(X_fin-doc.fin-doc-code) + ".xml"*/ ? .
  run str/xml-s-f.p (input parParentProc, input buf_schet-fact-doc.host-code, input  buf_schet-fact-doc.doc-code, input-output v-file-name, yes, yes) no-error .
  if error-status:error then do:
    message   "Ошибка при выгрузке счета-фактуры в XML-формате"  view-as alert-box .
    return error .
  end.

  if search ("exmldoc.bat") <> ? then do:
    os-command silent value(search ("exmldoc.bat") + " " + v-file-name + " " + v-sys-key).
  end.
  else do:
    if search (v-file-name ) <> ? then message "Документ " buf_schet-fact-doc.doc-code " выгружен в файл " v-file-name view-as alert-box.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME