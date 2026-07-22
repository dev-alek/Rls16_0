&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-contract FOR ub.c-contract.
DEFINE BUFFER X_contract FOR ub.contract.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории договоров

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code    as integer   no-undo .
define input parameter p-contract-code as integer   no-undo .
define input parameter bttns  as char   no-undo .
define input-output param p-rid-list    as  char no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список истории договоров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/flt-def.i  }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }

define variable filter-point as character no-undo init "Список истории договоров" .
define variable filter-point0 as character no-undo init "Список истории договоров" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable title0 as character no-undo.

define temp-table temp-changes no-undo
  field f_name as character
  field l_name as character
  field v_old as character
  field v_new as character
index pi is unique primary f_name.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

&Scoped-define line-num 7

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME brc-contract

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-contract temp-changes

/* Definitions for BROWSE brc-contract                                 */
&Scoped-define FIELDS-IN-QUERY-brc-contract (mark-string(recid(X_c-contract), p-rid-list)) X_c-contract.status_ X_c-contract.contract-prn-code X_c-contract.contract-date X_c-contract.contract-name if X_c-contract.cli-type = "" then "" else TRIM (X_c-contract.cli-type + " " + STRING (X_c-contract.cli-code)) X_c-contract.cli-name X_c-contract.contract-type X_c-contract.usl-opl if X_c-contract.srok-opl > 0 then string(X_c-contract.srok-opl) else "" X_c-contract.contract-city X_c-contract.contract-date-beg X_c-contract.contract-date-end (get-currency(X_c-contract.curr-code)) if X_c-contract.posr-type = "" then "" else TRIM (X_c-contract.posr-type + " " + STRING (X_c-contract.posr-code)) X_c-contract.posr-name if X_c-contract.agnt-type = "" then "" else TRIM (X_c-contract.agnt-type + " " + STRING (X_c-contract.agnt-code)) X_c-contract.agnt-name (get-agent( {&prs} ,X_c-contract.mngr-code)) X_c-contract.doc-type
&Scoped-define ENABLED-FIELDS-IN-QUERY-brc-contract ~
X_c-contract.prn-doc-code
&Scoped-define FIELD-PAIRS-IN-QUERY-brc-contract~
 ~{&FP1}prn-doc-code ~{&FP2}prn-doc-code ~{&FP3}
&Scoped-define ENABLED-TABLES-IN-QUERY-brc-contract X_c-contract
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brc-contract X_c-contract
&Scoped-define OPEN-QUERY-brc-contract OPEN QUERY brc-contract FOR EACH X_c-contract NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brc-contract X_c-contract
&Scoped-define FIRST-TABLE-IN-QUERY-brc-contract X_c-contract


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel B-lookup B-sch B-Help ~
brc-contract BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-agent Dialog-Frame
FUNCTION get-agent RETURNS CHARACTER
  ( input agnt-type as character , input agnt-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE  QUERY brc-contract FOR X_c-contract SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brc-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brc-contract Dialog-Frame _STRUCTURED
  QUERY brc-contract DISPLAY
      (mark-string(recid(X_c-contract), p-rid-list)) COLUMN-LABEL "*" FORMAT "x(1)"
      X_c-contract.corr-date                    COLUMN-LABEL "Дата!изменения"  FORMAT "99/99/99"
      string(X_c-contract.corr-time,"HH:MM")    COLUMN-LABEL "Время!изменения" FORMAT "X(5)"
      usrfulnf(X_c-contract.corr-user-name)               COLUMN-LABEL "Оператор"        FORMAT "X(18)"
      X_c-contract.status_                      COLUMN-LABEL "Статус"          FORMAT "X(4)"
      X_c-contract.contract-prn-code            COLUMN-LABEL "Номер"           FORMAT "X(16)"
      X_c-contract.contract-date                COLUMN-LABEL "Дата!договора"  FORMAT "99/99/99"
      X_c-contract.contract-name                COLUMN-LABEL "Заголовок"       FORMAT "X(22)"
      if X_c-contract.cli-type = "" then "" else TRIM (X_c-contract.cli-type + " " + STRING (X_c-contract.cli-code)) COLUMN-LABEL "Тип/код!контрагента" FORMAT "x(10)"
      X_c-contract.cli-name                     COLUMN-LABEL "Контрагент"      FORMAT "x(40)"
      X_c-contract.contract-type                COLUMN-LABEL "Тип договора"    FORMAT "X(23)"
      X_c-contract.usl-opl                      COLUMN-LABEL "Условия!оплаты"  FORMAT "X(32)"
      if X_c-contract.srok-opl > 0 then string(X_c-contract.srok-opl) else ""    COLUMN-LABEL "Отс-!роч."    FORMAT "X(4)"
      X_c-contract.contract-city                COLUMN-LABEL "Город"  FORMAT "X(20)"
      X_c-contract.contract-date-beg            COLUMN-LABEL "Начало!действия"     FORMAT "99/99/99"
      X_c-contract.contract-date-end            COLUMN-LABEL "Окончание!действия"      FORMAT "99/99/99"
      (get-currency(X_c-contract.curr-code))    COLUMN-LABEL "вал" FORMAT "x(3)"
      if X_c-contract.posr-type = "" then "" else TRIM (X_c-contract.posr-type + " " + STRING (X_c-contract.posr-code)) COLUMN-LABEL "Тип/код!посредника" FORMAT "x(10)"
      X_c-contract.posr-name                    COLUMN-LABEL "Посредник"       FORMAT "x(40)"
      if X_c-contract.agnt-type = "" then "" else TRIM (X_c-contract.agnt-type + " " + STRING (X_c-contract.agnt-code)) COLUMN-LABEL "Тип/код!агента" FORMAT "x(10)"
      X_c-contract.agnt-name                    COLUMN-LABEL "Агент"           FORMAT "x(40)"
      (get-agent( {&prs} ,X_c-contract.mngr-code))  COLUMN-LABEL "Исполнитель" FORMAT "x(50)"
      X_c-contract.doc-type
    ENABLE
      X_c-contract.contract-prn-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 13.71.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(35)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(40)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.88 BY 5.83.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31
     B-sch AT ROW 1 COL 41
     B-Help AT ROW 1 COL 86.25
     brc-contract AT ROW 2 COL 1.38
     BR-changes AT ROW 16.04 COL 1.38
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(77.49) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список договоров"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-contract B "?" ? ub ub.c-contract
      TABLE: X_contract B "?" ? ub ub.contract
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB brc-contract B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes brc-contract Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       brc-contract:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brc-contract
/* Query rebuild information for BROWSE brc-contract
*/  /* BROWSE brc-contract */
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
ON ENDKEY OF FRAME Dialog-Frame /* Список платежей */
DO:
    run gbl/markqwa.p ( input b-mark:sensitive, input p-rid-list) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not available X_c-contract then return no-apply.
/*  run str/contr-c1.w (input recid(X_c-contract)).*/

  define variable g-log  as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_lookup':U
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

  define variable ri as recid no-undo .
  ri = recid( X_c-contract ).

  run str/contr.w ( input parParentProc,input p-host-code, input "history", input X_c-contract.doc-type, input-output ri) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-contract then do:
      if can-do( p-rid-list, string( recid( X_c-contract ) ) ) then do:
          p-rid-list = replace( p-rid-list, {&comma-char} + string( recid( X_c-contract ) ), "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-contract ) ) + {&comma-char}, "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-contract ) ), "") .
      end.
      else
      p-rid-list = p-rid-list + ( if p-rid-list = "" then "" else {&comma-char} ) + string( recid( X_c-contract ) ) .
      loc#log = brc-contract:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = brc-contract:select-next-row ().
          apply "VALUE-CHANGED" to brc-contract in frame {&frame-name}.
      end.
      if num-entries( p-rid-list ) = 0 then hide mark-num in frame {&frame-name}.
      else disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to brc-contract in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
    tbl = 'ub.c-contract'
    join-tbl = 'X_c-contract'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('host-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date', 'Дата', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-prn-code', 'Номер', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-type', 'Тип', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('usl-opl', 'Условия генерации', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('auto-pay', 'Статус генерации', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('str-uslov-oplat', 'Условия оплаты', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('srok-opl', 'Отсрочка', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Статус', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-name', 'Заголовок', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-city', 'Город', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date-beg', 'Дата начала договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date-end', 'Дата конца договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('curr-code', 'Валюта', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-db-num', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', 'Имя оператора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type', 'Тип контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-code', 'Код контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-name', 'Контрагент', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-addres', 'Адрес контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-inn', '{&abbr_inn_allshift} контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-kpp', '{&abbr_kpp_allshift} контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-bank-name', 'Банк контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-bik', 'БИК контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-r-schet', 'Рас.счет контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-c-schet', 'Кор.счет контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-sign-post', 'Должность контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-sign', 'Подпись контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-name', 'Наименование фирмы', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-addres', 'Адрес', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-inn', '{&abbr_inn_allshift}', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-kpp', '{&abbr_kpp_all-shift}', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-bank-name', 'Банк', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-bik', 'БИК', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-r-schet', 'Рас.счет', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-c-schet', 'Кор.счет', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-sign-post', 'Должность', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-sign', 'Подпись', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-type', 'Тип посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-code', 'Код посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-name', 'Посредник', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-addres', 'Адрес посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-inn', '{&abrr_inn_allshift} посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-kpp', '{&abbr_kpp_allshift} посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-bank-name', 'Банк посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-bik', 'БИК посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-r-schet', 'Рас.счет посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-c-schet', 'Кор.счет посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-sign-post', 'Должность посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-sign', 'Подпись посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-type', 'Тип агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-code', 'Код агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-name', 'Агент', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-addres', 'Адрес агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-inn', '{&abbr_inn_allshift} агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-kpp', '{&abbr_kpp_allshift} агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-bank-name', 'Банк агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-bik', 'БИК агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-r-schet', 'Рас.счет агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-c-schet', 'Кор.счет агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-sign-post', 'Должность агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-sign', 'Подпись агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('mngr-code', 'Код исполнителя', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-out', 'Кор. счет РПП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-out', 'Кор. счет касса РПП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-out', 'Аналит. учет РПП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-out', 'Целев. назн РПП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-in', 'Кор. счет ППП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-in', 'Кор. счет касса ППП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-in', 'Аналит. учет ППП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-in', 'Целев. назн ППП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-out-cash', 'Кор. счет РКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-out-cash', 'Кор. счет касса РКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-out-cash', 'Аналит. учет РКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-out-cash', 'Целев. назн РКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-in-cash', 'Кор. счет ПКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-in-cash', 'Кор. счет касса ПКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-in-cash', 'Аналит. учет ПКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-in-cash', 'Целев. назн ПКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-out-payoff', 'Кор. счет Р.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-out-payoff', 'Кор. счет касса Р.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-out-payoff', 'Аналит. учет Р.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-out-payoff', 'Целев. назн Р.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-in-payoff', 'Кор. счет П.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-in-payoff', 'Кор. счет касса П.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-in-payoff', 'Аналит. учет П.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-in-payoff', 'Целев. назн П.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
  DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
     ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
     ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
    run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
    RUN OpenBr(yes, no, '':U).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-contract ) AND ( p-rid-list = "" ) then  p-rid-list = string( recid( X_c-contract ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brc-contract
&Scoped-define SELF-NAME brc-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brc-contract Dialog-Frame
ON RETURN OF brc-contract IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF brc-contract IN FRAME Dialog-Frame
DO:
  if b-sel:sensitive in frame {&frame-name} then
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
    else                     apply "choose" to b-sel in frame {&frame-name}.
  else if b-lookup:sensitive then apply "choose" to b-lookup in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brc-contract Dialog-Frame
ON VALUE-CHANGED OF brc-contract IN FRAME Dialog-Frame
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
{ gbl/app_help.i }
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-contract.contract-prn-code"
  &open-query     = "run OpenBr(yes, no, no)."
  &open-query-otherwise = "run OpenBr(yes, no, no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn = "no"
  &mv-brw-default = "no"
}
/*  &sort-clmn_2    = "X_c-contract.corr-user-name"*/


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  find first X_contract no-lock  where X_contract.host-code = p-host-code and X_contract.contract-code = p-contract-code no-error .
  if not available X_contract then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-host-code и/или p-contract-code"  p-host-code p-contract-code
    view-as alert-box ERROR.
    return.
  end.

  assign
    brc-contract:num-locked-columns = 1
    X_c-contract.contract-prn-code:read-only in browse brc-contract = yes
  .

  find first ub.clients no-lock where ub.clients.obj-code = p-host-code and ub.clients.obj-type = {&cmp} .
  title0 = "Список истории договоров" + {&space-char}  + substitute(" Фирма: (&1) &2 Договор : &3 от &4", p-host-code, ub.clients.obj-name,  X_contract.contract-prn-code, string(X_contract.contract-date,"99/99/9999")) .

  RUN MyEnable.

  DISABLE
    b-sel   when  NOT can-do( bttns, "b-sel" )
    b-mark  when  NOT can-do( bttns, "b-mark")
  WITH FRAME {&frame-name}.

  RUn OpenBR(yes, no, '':U).
  HIDE mark-num in frame {&frame-name} .
  if p-rid-list <> "":U then assign v-doc-rec = integer(entry(1, p-rid-list)) .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY mark-num      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-sel B-lookup B-sch B-Help brc-contract BR-changes mark-num    WITH FRAME Dialog-Frame.
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
  DISPLAY mark-num WITH FRAME Dialog-Frame.
  ENABLE  b-quit  B-lookup  b-sel  B-mark  B-sch  B-Help  mark-num  brc-contract  BR-changes WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

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

  def var l-query-was-opened as logical no-undo .
  {&SetCursorWait}
  def var sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then assign sort-column-phrase = ""  .
    otherwise    assign sort-column-phrase = "by " + sort-column-name  .
  end case.

  /* определяем здесь общие параметры для процедуры открытия query fltopend.i */

  &scop flt-open-open-query OPEN QUERY brc-contract FOR EACH X_c-contract
  &scop flt-open-dyn_open-query  FOR EACH X_c-contract
  &scop flt-open-query-handle query brc-contract:handle
  &scop flt-open-open-query-tail
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-query p-open-query
  &scop flt-open-table-name X_c-contract
  &scop flt-open-search-option no-lock
  &scop flt-open-find-next p-find-next
  &scop flt-open-find-recid v-doc-rec
  &scop flt-open-find-condition p-find-condition
  &scop flt-open-find-buffer-name X_c-contract

  define variable l-open-query as logical   no-undo .
  filter-point = filter-point0 .

  ASSIGN frame {&frame-name}:TITLE = title0 .
  { gbl/fltopend.i
    &where-cond = " X_c-contract.host-code = p-host-code AND X_c-contract.contract-code  = p-contract-code "
    &DYN_where-cond = " substitute(' X_c-contract.host-code = &1 and X_c-contract.contract-code = &2', p-host-code, p-contract-code)"
    &use-ind    = "  "
    &by         = "  "
  }

  REPOSITION brc-contract to recid v-doc-rec No-ERROR.
  if error-status:error then REPOSITION brc-contract to row 1 No-ERROR.
  else  REPOSITION brc-contract to row {&line-num} No-ERROR.
/*  brc-contract:SET-REPOSITIONED-ROW({&line-num}, "CONDITIONAL") .*/
/*    { gbl/brwrepos.i }*/
/*  end.*/
  {&SetCursorNo}

  run proc-view-changes in this-procedure no-error.
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
  define buffer new_c-contract for ub.c-contract.
  define buffer current_contract for ub.contract.
  define variable v-chg-fields as character no-undo.
  define variable v-old-fields as character no-undo.
  define variable v-new-fields as character no-undo.
  define variable ii as integer no-undo.

  for each temp-changes:  delete temp-changes.  END.

  find first new_c-contract no-lock
    where new_c-contract.host-code     = X_c-contract.host-code
      and new_c-contract.contract-code = X_c-contract.contract-code
      and new_c-contract.chip-num      > X_c-contract.chip-num
    no-error.

  if not available new_c-contract then do:
    find first current_contract no-lock
      where current_contract.host-code = X_c-contract.host-code
       and current_contract.contract-code = X_c-contract.contract-code
    no-error.
    if not available current_contract then return error.
    buffer-compare current_contract to X_c-contract save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_c-contract except chip-num corr-date corr-time corr-doc-code corr-user-name corr-user-db-num to X_c-contract save result in v-chg-fields.
  end.

  &scop  disp-field ~
    when "~{&field-name~}":U then do: ~
    create temp-changes. ~
    assign ~
    temp-changes.f_name = "~{&field-name~}":U ~
    temp-changes.l_name = ~{&field-label~} ~
    temp-changes.v_old = string(X_c-contract.~{&field-name~}) ~
    temp-changes.v_new = (if available new_c-contract  ~
                             then string(new_c-contract.~{&field-name~})  ~
                             else string(current_contract.~{&field-name~})) ~
    . ~
    end. ~

  do ii = 1 to num-entries(v-chg-fields):
    CASE entry(ii, v-chg-fields):
      &scop field-name contract-prn-code
      &scop field-label "Номер"
      {&disp-field}
      &scop field-name contract-date
      &scop field-label "Дата договора"
      {&disp-field}
      &scop field-name contract-type
      &scop field-label "Тип договора"
      {&disp-field}
      &scop field-name str-uslov-oplat
      &scop field-label "Условия оплаты"
      {&disp-field}
      &scop field-name usl-opl
      &scop field-label "Условия генерации"
      {&disp-field}
      &scop field-name auto-pay
      &scop field-label "Статус генерации"
      {&disp-field}
      &scop field-name srok-opl
      &scop field-label "Срок оплаты"
      {&disp-field}
      &scop field-name status_
      &scop field-label "Статус"
      {&disp-field}
      &scop field-name contract-name
      &scop field-label "Наименование договора"
      {&disp-field}
      &scop field-name contract-city
      &scop field-label "Город"
      {&disp-field}
      &scop field-name contract-date-beg
      &scop field-label "Дата начала договора"
      {&disp-field}
      &scop field-name contract-date-end
      &scop field-label "Дата конца договора"
      {&disp-field}
      &scop field-name curr-code
      &scop field-label "Код валюты"
      {&disp-field}
      &scop field-name own-name
      &scop field-label "Фирма"
      {&disp-field}
      &scop field-name own-addres
      &scop field-label "Фирма - Адрес"
      {&disp-field}
      &scop field-name own-inn
      &scop field-label "Фирма - ~{&abbr_inn_allshift~}"
      {&disp-field}
      &scop field-name own-kpp
      &scop field-label "Фирма - ~{&abbr_kpp_allshift~}"
      {&disp-field}
      &scop field-name own-bank-name
      &scop field-label "Фирма - Банк"
      {&disp-field}
      &scop field-name own-bik
      &scop field-label "Фирма - БИК банка"
      {&disp-field}
      &scop field-name own-r-schet
      &scop field-label "Фирма - Рас.счет"
      {&disp-field}
      &scop field-name own-c-schet
      &scop field-label "Фирма - Кор.счет"
      {&disp-field}
      &scop field-name own-sign-post
      &scop field-label "Фирма - должность подпис-го лица"
      {&disp-field}
      &scop field-name own-sign-post
      &scop field-label "Фирма - ФИО подпис-го лица"
      {&disp-field}
      &scop field-name own-code-schet
      &scop field-label "Внутр. номер текущего счета фирмы"
      {&disp-field}
      &scop field-name cli-type
      &scop field-label "Тип контрагента"
      {&disp-field}
      &scop field-name cli-code
      &scop field-label "Код контрагента"
      {&disp-field}
      &scop field-name cli-name
      &scop field-label "Наименование контрагента"
      {&disp-field}
      &scop field-name cli-addres
      &scop field-label "Адрес контрагента"
      {&disp-field}
      &scop field-name cli-inn
      &scop field-label "~{&abbr_inn_allshift~} контрагента"
      {&disp-field}
      &scop field-name cli-kpp
      &scop field-label "~{&abbr_kpp_allshift~} контрагента"
      {&disp-field}
      &scop field-name cli-bank-name
      &scop field-label "Банк контрагента"
      {&disp-field}
      &scop field-name cli-bik
      &scop field-label "БИК банка контрагента"
      {&disp-field}
      &scop field-name cli-r-schet
      &scop field-label "Рас.счет контрагента"
      {&disp-field}
      &scop field-name cli-c-schet
      &scop field-label "Кор.счет контрагента"
      {&disp-field}
      &scop field-name cli-sign-post
      &scop field-label "Контрагент - должность подпис-го лица"
      {&disp-field}
      &scop field-name cli-sign-post
      &scop field-label "Контрагент - ФИО подпис-го лица"
      {&disp-field}
      &scop field-name cli-code-schet
      &scop field-label "Внутр. номер тек. счета контрагента"
      {&disp-field}
      &scop field-name posr-type
      &scop field-label "Тип посредника"
      {&disp-field}
      &scop field-name posr-code
      &scop field-label "Код посредника"
      {&disp-field}
      &scop field-name posr-name
      &scop field-label "Наименование посредника"
      {&disp-field}
      &scop field-name posr-addres
      &scop field-label "Адрес посредника"
      {&disp-field}
      &scop field-name posr-inn
      &scop field-label "{&abbr_inn_allshift} посредника"
      {&disp-field}
      &scop field-name posr-kpp
      &scop field-label "{&abbr_kpp_allshift} посредника"
      {&disp-field}
      &scop field-name posr-bank-name
      &scop field-label "Банк посредника"
      {&disp-field}
      &scop field-name posr-bik
      &scop field-label "БИК банка посредника"
      {&disp-field}
      &scop field-name posr-r-schet
      &scop field-label "Рас.счет посредника"
      {&disp-field}
      &scop field-name posr-c-schet
      &scop field-label "Кор.счет посредника"
      {&disp-field}
      &scop field-name posr-sign-post
      &scop field-label "посредник - должность подпис-го лица"
      {&disp-field}
      &scop field-name posr-sign-post
      &scop field-label "посредник - ФИО подпис-го лица"
      {&disp-field}
      &scop field-name posr-code-schet
      &scop field-label "Внутр. номер тек. счета посредника"
      {&disp-field}
      &scop field-name agnt-type
      &scop field-label "Тип агента"
      {&disp-field}
      &scop field-name agnt-code
      &scop field-label "Код агента"
      {&disp-field}
      &scop field-name agnt-name
      &scop field-label "Наименование агента"
      {&disp-field}
      &scop field-name agnt-addres
      &scop field-label "Адрес агента"
      {&disp-field}
      &scop field-name agnt-inn
      &scop field-label "{&abbr_inn_allshift} агента"
      {&disp-field}
      &scop field-name agnt-kpp
      &scop field-label "{&abbr_kpp_allshift} агента"
      {&disp-field}
      &scop field-name agnt-bank-name
      &scop field-label "Банк агента"
      {&disp-field}
      &scop field-name agnt-bik
      &scop field-label "БИК банка агента"
      {&disp-field}
      &scop field-name agnt-r-schet
      &scop field-label "Рас.счет агента"
      {&disp-field}
      &scop field-name agnt-c-schet
      &scop field-label "Кор.счет агента"
      {&disp-field}
      &scop field-name agnt-sign-post
      &scop field-label "агент - должность подпис-го лица"
      {&disp-field}
      &scop field-name agnt-sign-post
      &scop field-label "агент - ФИО подпис-го лица"
      {&disp-field}
      &scop field-name agnt-code-schet
      &scop field-label "Внутр. номер тек. счета агента"
      {&disp-field}
      &scop field-name mngr-code
      &scop field-label "Код исполнителя"
      {&disp-field}
      &scop field-name doc-type
      &scop field-label "Вид договора"
      {&disp-field}
      &scop field-name fin-VAT-pc
      &scop field-label "НДС"
      {&disp-field}
      &scop field-name kredit-limit
      &scop field-label "Ограничение кредита"
      {&disp-field}
      &scop field-name kredit-sum
      &scop field-label "Сумма кредита"
      {&disp-field}
      &scop field-name usl-opl
      &scop field-label "Условия оплаты ФО"
      {&disp-field}
      &scop field-name srok-opl
      &scop field-label "Срок оплаты ФО"
      {&disp-field}
      &scop field-name gen-factur-srok
      &scop field-label "Срок генерации счет-фактур"
      {&disp-field}
      &scop field-name gen-factur-srok
      &scop field-label "Конечный статус сгенеренного счета-фактуры"
      {&disp-field}
      &scop field-name fin-SLT-pc
      &scop field-label "НП"
      {&disp-field}
      &scop field-name pay-nal
      &scop field-label "нал"
      {&disp-field}
      &scop field-name cor-acc-out
      &scop field-label "Кор.счет РПП"
      {&disp-field}
      &scop field-name an-uchet-code-out
      &scop field-label "Код аналит. учета РПП"
      {&disp-field}
      &scop field-name cel-nazn-code-out
      &scop field-label "Код целев. назн. РПП"
      {&disp-field}
      &scop field-name cor-acc1-out
      &scop field-label "Касса РПП"
      {&disp-field}
      &scop field-name cor-acc-in
      &scop field-label "Кор.счет ППП"
      {&disp-field}
      &scop field-name an-uchet-code-in
      &scop field-label "Код аналит. учета ППП"
      {&disp-field}
      &scop field-name cel-nazn-code-in
      &scop field-label "Код целев. назн. ППП"
      {&disp-field}
      &scop field-name cor-acc1-in
      &scop field-label "Касса ППП"
      {&disp-field}
      &scop field-name cor-acc-out
      &scop field-label "Кор.счет РКО"
      {&disp-field}
      &scop field-name an-uchet-code-out
      &scop field-label "Код аналит. учета РКО"
      {&disp-field}
      &scop field-name cel-nazn-code-out
      &scop field-label "Код целев. назн. РКО"
      {&disp-field}
      &scop field-name cor-acc1-out
      &scop field-label "Касса РКО"
      {&disp-field}
      &scop field-name cor-acc-in
      &scop field-label "Кор.счет ПКО"
      {&disp-field}
      &scop field-name an-uchet-code-in
      &scop field-label "Код аналит. учета ПКО"
      {&disp-field}
      &scop field-name cel-nazn-code-in
      &scop field-label "Код целев. назн. ПКО"
      {&disp-field}
      &scop field-name cor-acc1-in
      &scop field-label "Касса ПКО"
      {&disp-field}
      &scop field-name cor-acc-out
      &scop field-label "Кор.счет Р.АПЗ"
      {&disp-field}
      &scop field-name an-uchet-code-out
      &scop field-label "Код аналит. учета Р.АПЗ"
      {&disp-field}
      &scop field-name cel-nazn-code-out
      &scop field-label "Код целев. назн. Р.АПЗ"
      {&disp-field}
      &scop field-name cor-acc1-out
      &scop field-label "Касса Р.АПЗ"
      {&disp-field}
      &scop field-name cor-acc-in
      &scop field-label "Кор.счет П.АПЗ"
      {&disp-field}
      &scop field-name an-uchet-code-in
      &scop field-label "Код аналит. учета П.АПЗ"
      {&disp-field}
      &scop field-name cel-nazn-code-in
      &scop field-label "Код целев. назн. П.АПЗ"
      {&disp-field}
      &scop field-name cor-acc1-in
      &scop field-label "Касса П.АПЗ"
      {&disp-field}
    END CASE.
  end.

  Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-agent Dialog-Frame
FUNCTION get-agent RETURNS CHARACTER
  ( input agnt-type as character , input agnt-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable var-cli-name as character no-undo.
define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = agnt-type and buf_clients.obj-code = agnt-code no-error .
  if available buf_clients then assign var-cli-name = STRING (agnt-code) + "   " + TRIM (buf_clients.obj-name) .

  RETURN var-cli-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable var-curr-name as character no-undo.
define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where buf_currency.curr-code = curr-code no-error .
  if available buf_currency then assign var-curr-name = buf_currency.curr-abbr .

RETURN var-curr-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME