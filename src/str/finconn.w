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

Связи фин. обязательств и платежей

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05
*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code    as integer   no-undo . /* надо передавать фирму */
define input  parameter p-doc-type     as character no-undo . /* "all", {&income} {&expense} */
define input  parameter p-doc          as character no-undo . /* "all", "fin-ob", "fin-doc" */
define input  parameter p-doc-num      as character no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":u .

def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Связи фин. обязательств и платежей" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ gbl/usrfulnf.i }

  define buffer buf_fin-connect  for ub.fin-connect .
  define buffer buf_fin-ob       for ub.fin-ob .
  define buffer buf_fin-doc      for ub.fin-doc .
  define buffer buf_contract     for ub.contract .

  define variable cont-list        as character no-undo .
  define variable g-log            as logical   no-undo .

  define variable v-doc-rec        as recid no-undo .
  define variable sort-column-name as character no-undo .

  define variable filter-point as character no-undo init "Связи фин. обязательств и платежей" .
  define variable filter-point0 as character no-undo init "Связи фин. обязательств и платежей" .

  define variable num as integer initial 0 no-undo .

  DEFINE temp-table temp-conn no-undo
    field   ri             as  recid
/*    field   ind            as integer*/
    INDEX pi  IS PRIMARY   ri
  .


&scop col-l0  '*'
&scop col-l1  'Дата'
&scop col-l2  'Время'
&scop col-l3  'Связал'
&scop col-l4  '№ фин.об.'
&scop col-l5  'Дата ф.об.'
&scop col-l51 'вн.н. ф.об.'
&scop col-l6  '№ платежа'
&scop col-l7  'Дата плат.'
&scop col-l71 'вн.н. пл.'
&scop col-l72 'Сумма в вал.дог.'
&scop col-l8  'Сумма в {&abbr_rubl}.'
&scop col-l9  'Сумма в Б.вал.'
&scop col-l10 'Договор'
&scop col-l11 'Дата дог.'
&scop col-l12 'Вн.N'
&scop col-l13 'Объект'

&scop cop-l0  mark-string(recid(buf_fin-connect))
&scop cop-l1  buf_fin-connect.fact-date
&scop cop-l2  string(buf_fin-connect.fact-time,'HH:MM')
&scop cop-l3  usrfulnf(buf_fin-connect.user-name)
&scop cop-l4  buf_fin-ob.prn-doc-code
&scop cop-l5  buf_fin-ob.pay-date
&scop cop-l51 buf_fin-connect.fin-ob-code
&scop cop-l6  buf_fin-doc.prn-doc-code
&scop cop-l7  buf_fin-doc.doc-date
&scop cop-l71 buf_fin-connect.fin-doc-code
&scop cop-l72 buf_fin-connect.sum-contr
&scop cop-l8  buf_fin-connect.sum-rubl
&scop cop-l9  buf_fin-connect.sum-base
&scop cop-l10 buf_contract.contract-prn-code
&scop cop-l11 buf_contract.contract-date
&scop cop-l12 buf_fin-connect.connect-code
&scop cop-l13 (if buf_fin-ob.obj-code = 0 then '' else (buf_fin-ob.obj-type + ' ' + string(buf_fin-ob.obj-code)))

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME Conn-List

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_fin-connect buf_fin-ob buf_fin-doc buf_contract

/* Definitions for BROWSE Conn-List                                     */
&Scoped-define FIELDS-IN-QUERY-Conn-List {&cop-l0} {&cop-l1} {&cop-l2} {&cop-l3} {&cop-l4} {&cop-l5} {&cop-l51} {&cop-l6} {&cop-l7} {&cop-l71}  {&cop-l72} {&cop-l8} {&cop-l9} {&cop-l10} {&cop-l11} {&cop-l12} {&cop-l13}
&Scoped-define ENABLED-FIELDS-IN-QUERY-Conn-List {&cop-l1}
&Scoped-define FIELD-PAIRS-IN-QUERY-Conn-List~
 ~{&FP1}{&cop-l1} ~{&FP2}{&cop-l1} ~{&FP3}
&Scoped-define SELF-NAME Conn-List
&Scoped-define OPEN-QUERY-Conn-List OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-connect NO-LOCK, first buf_fin-ob NO-LOCK where buf_fin-ob.host-code = buf_fin-connect.host-code and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code, first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = buf_fin-connect.host-code and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code, first buf_contract NO-LOCK where buf_contract.host-code = buf_fin-connect.host-code and buf_contract.contract-code = buf_fin-connect.contract-code .
&Scoped-define TABLES-IN-QUERY-Conn-List buf_fin-ob buf_fin-connect   buf_fin-doc  buf_contract
&Scoped-define FIRST-TABLE-IN-QUERY-Conn-List buf_fin-connect


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-del b-sch B-view-fo ~
B-view-doc Sel-Contr B-Help Conn-List sch-date sch-user sch-code ~
RADIO-find-doc mark-num
&Scoped-Define DISPLAYED-OBJECTS Sel-Contr sch-date sch-user sch-code ~
RADIO-find-doc mark-num

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
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.

DEFINE BUTTON B-view-doc
     LABEL "&Платеж"
     SIZE 10 BY 1.

DEFINE BUTTON B-view-fo
     LABEL "Фин.о&бяз."
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Вн. &номер"
     VIEW-AS FILL-IN
     SIZE 8.88 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/99"
     LABEL "&Дата связи"
     VIEW-AS FILL-IN
     SIZE 9.13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-user AS CHARACTER FORMAT "X(14)"
     LABEL "&Польз."
     VIEW-AS FILL-IN
     SIZE 8.88 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RADIO-find-doc AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Фин.обяз.", 1,
"Платеж", 2
     SIZE 23.25 BY 1 NO-UNDO.

DEFINE VARIABLE Sel-Contr AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 14 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Conn-List FOR buf_fin-connect, buf_fin-ob, buf_fin-doc, buf_contract SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE Conn-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS Conn-List Dialog-Frame _FREEFORM
  QUERY Conn-List DISPLAY
      {&cop-l0}    COLUMN-LABEL {&col-l0}  FORMAT "x(1)"
     {&cop-l1}    COLUMN-LABEL {&col-l1}  Format "99/99/99"
     {&cop-l2}    COLUMN-LABEL {&col-l2}  Format "x(5)"
     {&cop-l3}    COLUMN-LABEL {&col-l3}  Format "x(8)"
     {&cop-l4}    COLUMN-LABEL {&col-l4}  format "x(12)"
     {&cop-l5}    COLUMN-LABEL {&col-l5}  format "99/99/99"
     {&cop-l51}   COLUMN-LABEL {&col-l51}
     {&cop-l6}    COLUMN-LABEL {&col-l6}  Format "x(8)"
     {&cop-l7}    COLUMN-LABEL {&col-l7}  Format "99/99/99"
     {&cop-l71}   COLUMN-LABEL {&col-l71}
     {&cop-l72}   COLUMN-LABEL {&col-l72} Format "->,>>>,>>>,>>9.99"
     {&cop-l8}    COLUMN-LABEL {&col-l8}  Format "->,>>>,>>>,>>9.99"
     {&cop-l9}    COLUMN-LABEL {&col-l9}  format "->,>>>,>>>,>>9.99"
     {&cop-l10}   COLUMN-LABEL {&col-l10} Format "x(14)"
     {&cop-l11}   COLUMN-LABEL {&col-l11} Format "99/99/99"
     {&cop-l12}   COLUMN-LABEL {&col-l12}
     {&cop-l13}   COLUMN-LABEL {&col-l13} Format "x(14)"
     enable {&cop-l1}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 20.17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-del AT ROW 1 COL 21
     b-sch AT ROW 1 COL 31
     B-view-fo AT ROW 1 COL 41
     B-view-doc AT ROW 1 COL 51
     Sel-Contr AT ROW 1 COL 72.38 NO-LABEL
     B-Help AT ROW 1 COL 88
     Conn-List AT ROW 2.08 COL 1.25
     sch-date AT ROW 22.42 COL 18.75 COLON-ALIGNED
     sch-user AT ROW 22.42 COL 36.25 COLON-ALIGNED
     sch-code AT ROW 22.42 COL 63.63 COLON-ALIGNED
     RADIO-find-doc AT ROW 22.42 COL 74.75 NO-LABEL
     mark-num AT ROW 1 COL 14 NO-LABEL
     "Договоры:" VIEW-AS TEXT
          SIZE 9.5 BY 1 AT ROW 1 COL 62.5
          FGCOLOR 4
     "Поиск:" VIEW-AS TEXT
          SIZE 6.63 BY 1 AT ROW 22.42 COL 1.25
          FGCOLOR 4
     SPACE(90.61) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Связи фин. обязательств и платежей"
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
/* BROWSE-TAB Conn-List B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE Conn-List
/* Query rebuild information for BROWSE Conn-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-ob NO-LOCK indexed-reposition.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE Conn-List */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Связи фин. обязательств и платежей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable is-con as logical   no-undo .
  if num < 1 then do:
    if available buf_fin-connect then do:
      message "Вы действительно хотите удалить выбранную связь?"  view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .
      if is-con = no then return no-apply.

      do transaction :
        find first ub.fin-connect exclusive-lock where recid(ub.fin-connect) = recid(buf_fin-connect) .
        find first ub.fin-ob      exclusive-lock where ub.fin-ob.host-code = ub.fin-connect.host-code and ub.fin-ob.doc-code = ub.fin-connect.fin-ob-code .
        assign
          ub.fin-ob.con-sum-rubl  = ub.fin-ob.con-sum-rubl  - ub.fin-connect.sum-rubl
          ub.fin-ob.con-sum-base  = ub.fin-ob.con-sum-base  - ub.fin-connect.sum-base
          ub.fin-ob.con-sum-doc   = ub.fin-ob.con-sum-doc   - ub.fin-connect.sum-doc
          ub.fin-ob.con-sum-contr = ub.fin-ob.con-sum-contr - ub.fin-connect.sum-contr
        .
        if ub.fin-ob.con-sum-contr = 0 then assign ub.fin-ob.con-stat = 0 .
        else                             assign ub.fin-ob.con-stat = 1 .
        find first ub.fin-doc      exclusive-lock where ub.fin-doc.host-code = ub.fin-connect.host-code and ub.fin-doc.fin-doc-code = ub.fin-connect.fin-doc-code .
        if   ub.fin-doc.fin-doc-type = {&expense-cashless}
          or ub.fin-doc.fin-doc-type = {&expense-cash}
          or ub.fin-doc.fin-doc-type = {&expense-payoff} then do:
          assign
            ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  - ub.fin-connect.sum-rubl
            ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  - ub.fin-connect.sum-base
            ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   - ub.fin-connect.sum-doc
            ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr - ub.fin-connect.sum-contr
          .
        end.
        else do:
          assign
            ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  + ub.fin-connect.sum-rubl
            ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  + ub.fin-connect.sum-base
            ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   + ub.fin-connect.sum-doc
            ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr + ub.fin-connect.sum-contr
          .
        end.
        if ub.fin-doc.con-sum-contr = 0 then assign ub.fin-doc.con-stat = 0 .
        else                              assign ub.fin-doc.con-stat = 1 .
        delete ub.fin-connect .
      end.
    end.
    else do:
      message  "Нет выбранных связей!"  view-as alert-box.
      return no-apply.
    end.
  end.
  else do:
    message "Вы действительно хотите удалить выбранные связи?"  view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .
    if is-con = no then return no-apply.

    do transaction :
      for each temp-conn :
        find first ub.fin-connect exclusive-lock where recid(ub.fin-connect) = temp-conn.ri .
        find first ub.fin-ob      exclusive-lock where ub.fin-ob.host-code = ub.fin-connect.host-code and ub.fin-ob.doc-code = ub.fin-connect.fin-ob-code .
        assign
          ub.fin-ob.con-sum-rubl  = ub.fin-ob.con-sum-rubl  - ub.fin-connect.sum-rubl
          ub.fin-ob.con-sum-base  = ub.fin-ob.con-sum-base  - ub.fin-connect.sum-base
          ub.fin-ob.con-sum-doc   = ub.fin-ob.con-sum-doc   - ub.fin-connect.sum-doc
          ub.fin-ob.con-sum-contr = ub.fin-ob.con-sum-contr - ub.fin-connect.sum-contr
        .
        if ub.fin-ob.con-sum-contr = 0 then assign ub.fin-ob.con-stat = 0 .
        else                             assign ub.fin-ob.con-stat = 1 .
        find first ub.fin-doc      exclusive-lock where ub.fin-doc.host-code = ub.fin-connect.host-code and ub.fin-doc.fin-doc-code = ub.fin-connect.fin-doc-code .
        if   ub.fin-doc.fin-doc-type = {&expense-cashless}
          or ub.fin-doc.fin-doc-type = {&expense-cash}
          or ub.fin-doc.fin-doc-type = {&expense-payoff} then do:
          assign
            ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  - ub.fin-connect.sum-rubl
            ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  - ub.fin-connect.sum-base
            ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   - ub.fin-connect.sum-doc
            ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr - ub.fin-connect.sum-contr
          .
        end.
        else do:
          assign
            ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  + ub.fin-connect.sum-rubl
            ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  + ub.fin-connect.sum-base
            ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   + ub.fin-connect.sum-doc
            ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr + ub.fin-connect.sum-contr
          .
        end.
        if ub.fin-doc.con-sum-contr = 0 then assign ub.fin-doc.con-stat = 0 .
        else                              assign ub.fin-doc.con-stat = 1 .
        delete ub.fin-connect .
        assign num = num - 1 .
        delete temp-conn .
      end.
    end.
  end.
  if num = 0 then hide mark-num in frame {&frame-name}.
  else                   display num @ mark-num  with frame {&frame-name}.
  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  if available buf_fin-connect then do:
    find first temp-conn where temp-conn.ri = recid( buf_fin-connect ) no-error  .
    if available temp-conn then do:
      delete temp-conn .
      assign num = num - 1 .
    end.
    else do:
      create temp-conn .
      assign
        temp-conn.ri = recid( buf_fin-connect )
        num = num + 1
      .
    end.
    g-log = Conn-List:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      g-log = Conn-List:select-next-row ().
      apply "value-changed" to Conn-List in frame {&frame-name}.
    end.
    if num = 0 then hide mark-num in frame {&frame-name}.
    else                   display num @ mark-num  with frame {&frame-name}.
  end.
  apply "entry" to Conn-List .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
/*  run gbl/markqwa.p (input b-mark:sensitive, input p-rid-list) no-error.*/
/*  if error-status:error then return no-apply.*/
/*  if can-do( bttns, "b-sel") then p-rid-list = "" .*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
    tbl = 'fin-connect'
    join-tbl = 'buf_fin-connect'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .

  run fltfield-add in this-procedure('host-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', 'Дата', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-time', 'Время', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('connect-code', 'Вн.Номер', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fin-ob-code', 'Вн.номер фин.об.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fin-doc-code', 'Вн.номер платежа', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Номер', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Статус', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-db-num', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('curr-code', 'Валюта док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-curr', 'Валюта договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-rubl', 'Сумма в {&abbr_rubl}.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-base', 'Сумма в Б.вал.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-doc', 'Сумма в вал. док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-contr', 'Сумма в вал. договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS', 'Примечания', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

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


&Scoped-define SELF-NAME B-view-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-view-doc Dialog-Frame
ON CHOOSE OF B-view-doc IN FRAME Dialog-Frame /* Платеж */
DO:
  if not available buf_fin-ob then return.
  run ref/showfind.p (
                       input parParentProc
                      ,input p-host-code /*текущая фирма*/
                      ,input buf_fin-doc.host-code
                      ,input buf_fin-doc.fin-doc-code
                      ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-view-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-view-fo Dialog-Frame
ON CHOOSE OF B-view-fo IN FRAME Dialog-Frame /* Фин.обяз. */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_lookup':U
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
  define variable rr as recid no-undo .
  if not available buf_fin-ob then return.
  run str/sh-finob.p ( input parParentProc, input p-host-code, input recid(buf_fin-ob)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Conn-List
&Scoped-define SELF-NAME Conn-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Conn-List Dialog-Frame
ON RETURN OF Conn-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Conn-List IN FRAME Dialog-Frame
DO:
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-find-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-find-doc Dialog-Frame
ON VALUE-CHANGED OF RADIO-find-doc IN FRAME Dialog-Frame
DO:
  assign RADIO-find-doc .
  if sch-code <> ? and  sch-code <> 0 then apply "return" to sch-code in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* Вн. номер */
DO:
  run proc-find-code  in this-procedure(yes, input frame {&frame-name} sch-code ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* Вн. номер */
DO:
  run proc-find-code  in this-procedure(no, input frame {&frame-name} sch-code ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* Дата связи */
DO:
  run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* Дата связи */
DO:
  run proc-find-date in this-procedure(no, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-user
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-user Dialog-Frame
ON CTRL-J OF sch-user IN FRAME Dialog-Frame /* Польз. */
DO:
  run proc-find-user  in this-procedure(yes, input frame {&frame-name} sch-user ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-user Dialog-Frame
ON RETURN OF sch-user IN FRAME Dialog-Frame /* Польз. */
DO:
  run proc-find-user  in this-procedure(no, input frame {&frame-name} sch-user ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Sel-Contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Sel-Contr Dialog-Frame
ON VALUE-CHANGED OF Sel-Contr IN FRAME Dialog-Frame
DO:
  assign Sel-Contr .
  if Sel-Contr = "sel" then do:
    run str/cont-all.w ( parParentProc, p-host-code, "b-sel", {&company}, ?, ?, ?, ?, "current":U, p-doc-type, input-output cont-list ) .
    if cont-list = "" then do:
      assign Sel-Contr = "all" .
      disp Sel-Contr with frame {&frame-name}.
    end.
  end .
  RUN OpenBr(yes, no, '':U) .
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
{ gbl/brwrepos.i  &line-num=15 }

/* сорт  колонок*/
{ gbl/srt-clmd.i
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &browse-name = "Conn-List"
  &frame-name = "{&frame-name}"
  &ext-col = 15
  &open-query     = "run OpenBr(yes, no, '':U)."
  &open-query-otherwise = "run OpenBr(yes, no, '':U)."
  &sort-column-name = "sort-column-name"
  &start-column         = "2"
  &label-clmn_1         = "{&col-l1}"
  &sort-clmn_1          = "{&cop-l1}"
  &label-clmn_2         = "{&col-l2}"
  &sort-clmn_2          = "{&cop-l2}"
  &label-clmn_3         = "{&col-l3}"
  &sort-clmn_3          = "{&cop-l3}"
  &label-clmn_4         = "{&col-l4}"
  &sort-clmn_4          = "{&cop-l4}"
  &label-clmn_5         = "{&col-l5}"
  &sort-clmn_5          = "{&cop-l5}"
  &label-clmn_51        = "{&col-l51}"
  &sort-clmn_51         = "{&cop-l51}"
  &label-clmn_6         = "{&col-l6}"
  &sort-clmn_6          = "{&cop-l6}"
  &label-clmn_7         = "{&col-l7}"
  &sort-clmn_7          = "{&cop-l7}"
  &label-clmn_71        = "{&col-l71}"
  &sort-clmn_71         = "{&cop-l71}"
  &label-clmn_72        = "{&col-l72}"
  &sort-clmn_72         = "{&cop-l72}"
  &label-clmn_8         = "{&col-l8}"
  &sort-clmn_8          = "{&cop-l8}"
  &label-clmn_9         = "{&col-l9}"
  &sort-clmn_9          = "{&cop-l9}"
  &label-clmn_10        = "{&col-l10}"
  &sort-clmn_10         = "{&cop-l10}"
  &label-clmn_11        = "{&col-l11}"
  &sort-clmn_11         = "{&cop-l11}"
  &label-clmn_12        = "{&col-l12}"
  &sort-clmn_12         = "{&cop-l12}"
  &label-clmn_13        = "{&col-l13}"
  &sort-clmn_13         = "{&cop-l13}"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
 }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

 { gbl/getcntxt.i get }

 { gbl/ed_date.i sch-date }
 { gbl/setfltnm.i }

  assign
    Conn-List:num-locked-columns = 1
    {&cop-l1}:read-only in browse Conn-List = yes
  .
  if p-doc = "all" and p-doc-num <> "" then assign cont-list = string (p-doc-num) Sel-Contr = "sel" .

  RUN enable_UI.

  DISABLE  Sel-Contr  when (p-doc <> "all") WITH FRAME {&frame-name}.
  if mark-num = 0   then hide mark-num   in frame {&frame-name}.
  assign RADIO-find-doc .

  Run OpenBR(yes, no, '':U) .

  { gbl/mv-clmn.i   &browse-name = "Conn-List"    &frame-name = "{&frame-name}"    &ext-col = 12    &start-column = "1"  }

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
  DISPLAY Sel-Contr sch-date sch-user sch-code RADIO-find-doc mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-del b-sch B-view-fo B-view-doc Sel-Contr B-Help
         Conn-List sch-date sch-user sch-code RADIO-find-doc mark-num
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
  define variable title0 as character no-undo.
  define variable p-cont as integer   no-undo .
  title0 = "Связи фин. обязательств и платежей" + {&space-char}.
  {&SetCursorWait}

  define variable sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name .
  end case.

  find first ub.clients no-lock where ub.clients.obj-type = {&cmp} and ub.clients.obj-code = p-host-code .
  ASSIGN title0  = title0 + " Фирма: (" + string(p-host-code) + ")":U + {&space-char} + ub.clients.obj-name .

  /* определяем здесь общие параметры для процедуры открытия query fltopend.i */
  &scop flt-open-open-query OPEN QUERY Conn-List FOR EACH buf_fin-connect NO-LOCK
  &scop flt-open-dyn_open-query  FOR EACH buf_fin-connect
  &scop flt-open-query-handle query Conn-List:handle
  &scop flt-open-open-query-tail  , first buf_fin-ob NO-LOCK ~
               where buf_fin-ob.host-code = p-host-code ~
                 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code , ~
              first buf_fin-doc NO-LOCK ~
               where buf_fin-doc.host-code = p-host-code ~
                 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,   ~
              first buf_contract NO-LOCK  ~
               where buf_contract.host-code = p-host-code ~
                 and buf_contract.contract-code = buf_fin-connect.contract-code
  &scop flt-open-dyn_open-query-tail  substitute(', first buf_fin-ob NO-LOCK ~
               where buf_fin-ob.host-code = &1 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code , ~
              first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = &1 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,   ~
              first buf_contract NO-LOCK where buf_contract.host-code = &1 ~
                 and buf_contract.contract-code = buf_fin-connect.contract-code', p-host-code)
  &scop flt-open-waitfram true
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name set-filter-name
  &scop flt-open-query p-open-query
  &scop flt-open-table-name buf_fin-connect
  &scop flt-open-search-option no-lock
  &scop flt-open-find-next p-find-next
  &scop flt-open-find-recid v-doc-rec
  &scop flt-open-find-condition p-find-condition
  &scop flt-open-find-buffer-name buf_fin-connect

  define variable l-open-query as logical   no-undo .

  filter-point = filter-point0 .

  assign frame {&frame-name}:title = title0 .

  if p-doc = "all" then do:
    if Sel-Contr = "all" then do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-connect.host-code = p-host-code "
        &DYN_where-cond = " substitute(' buf_fin-connect.host-code = &1', p-host-code)"
        &use-ind    = "  "
        &by   = "by buf_fin-connect.fact-date descending by buf_fin-connect.fact-time descending"
        &DYN_by   = " substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time) "
      }
    end.
    else do:
      find first ub.contract no-lock where recid (ub.contract)  = int (cont-list) no-error .
      assign p-cont = ub.contract.contract-code .
      { gbl/fltopend.i
        &where-cond = " buf_fin-connect.host-code = p-host-code and buf_fin-connect.contract-code = p-cont "
        &DYN_where-cond = " substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.contract-code = &2', p-host-code, p-cont)"
        &use-ind = "  "
        &by = "by buf_fin-connect.fact-date descending by buf_fin-connect.fact-time descending"
        &DYN_by   = " substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time) "
      }
    end.
  end.
  else do:
    if p-doc = "fin-ob" then do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-ob-code = p-doc-num "
        &DYN_where-cond = " substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.contract-code = "&2"', p-host-code, p-doc-num)"
        &use-ind = "  "
        &by = "by buf_fin-connect.fact-date descending by buf_fin-connect.fact-time descending"
        &DYN_by   = " substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time) "
      }
    end.
    if p-doc = "fin-doc" then do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-doc-code = integer(p-doc-num) "
        &DYN_where-cond = " substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.fin-doc-code = &2', p-host-code, integer(p-doc-num))"
        &use-ind = "  "
        &by = "by buf_fin-connect.fact-date descending by buf_fin-connect.fact-time descending"
        &DYN_by   = " substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time) "
      }
    end.
  end.

  REPOSITION Conn-List to recid v-doc-rec No-ERROR.
  {&SetCursorNo}
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
  define input parameter p-code as integer no-undo .

  display "  /  /":U @ sch-date  "":U @ sch-user  with frame {&frame-name}.
/*  assign p-code = replace(p-code, {&single-quote}, {&single-quote} + {&single-quote}) .*/

  if RADIO-find-doc = 1 then run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-connect.fin-ob-code = &1 ", p-code)).
  else run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-connect.fin-doc-code = &1 ", p-code)).

  apply "entry":u to sch-code in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame
PROCEDURE proc-find-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-next as logical no-undo.
  define input parameter par-date as date    no-undo .

  display "":U @ sch-user  "":U @ sch-code  with frame {&frame-name}.

  define variable var-datechr as character no-undo .
  assign var-datechr = string(day(par-date)) + {&slash-char} + string(month(par-date)) + {&slash-char} + string(year(par-date)) .
  run OpenBr  in this-procedure (input false, input p-next,input substitute("and buf_fin-connect.fact-date = &1 ", var-datechr)) .
  apply "entry":u to sch-date in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-user Dialog-Frame
PROCEDURE proc-find-user :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .

  display  "  /  /":U @ sch-date   "":U @ sch-code  with frame {&frame-name}.
  assign p-code = replace(p-code, {&single-quote}, {&single-quote} + {&single-quote}) .

  run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-connect.user-name = '&1' ", p-code)).
  apply "entry":u to sch-user in frame {&frame-name} .
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