&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Cпецификации по товару

Автор: Чернова Светлана Александровна
Дата создания: 05/27/09
Author: Svetlana Chernova
Creation date: 05/27/09


*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-gds-code     as integer   no-undo .
define input  parameter bttns as character no-undo .
define output parameter rid-list       as char      no-undo . /* список recid'ов выбранных записей */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Cпецификации по товару" .
define variable p-host-code     as integer   no-undo .
define variable p-doc-num       as integer   no-undo .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ ref/gds-matl.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ str/libbcrcn.i }
{ gbl/integerm.i }
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ ref/assgrpmt.i }
{ ref/spegrpmt.i }
{ str/spedlass.i }
{ str/specattr.i }
{ cmp/gds-list.i gds-list-flt def "new shared" }
{ str/ascorrm.i  }
{ gbl/assmatat.i }   /* Библиотека для работы с атрибутами АМ */
{ gbl/thbj-def.i }
{ ref/ass-mat.i &DEF_PROC=YES}    /* Процедуры и функции для работы с АМ (по задаче "Процент отклонения матрицы от шаблона") */

define buffer buf_contract-specif  for ub.contract-specif .
define buffer buf_contract         for ub.contract .
define buffer buf_ext-artic        for ub.ext-artic  .
define buffer buf_goods            for ub.goods.

define variable v-doc-rec        as recid     no-undo .
define variable sort-column-name as character no-undo .
define variable f-name           as character no-undo .
define variable is-new           as logical   no-undo initial no .
define variable is-new1          as logical   no-undo initial no .
define variable v-res            as logical   no-undo initial no .
define variable g-log            as logical   no-undo .
define variable b-code           as integer   no-undo .
define variable gds-rec          as recid     no-undo .
define variable v-price          as decimal   no-undo .
define variable v-prc            as decimal   no-undo .
define variable v-prc-2          as decimal   no-undo .
define variable v-VAT-type       as character no-undo .
define variable v-qnty           as decimal   no-undo .
define variable v-cli-base-rate  as decimal   no-undo .
define variable v-unit-cli       as character no-undo .
define variable v-vat-pc         as decimal   no-undo .
define variable v-bonus          as decimal   no-undo .
define variable old-bonus        as decimal   no-undo .
define variable v-contr-type     as character no-undo .
define variable filter-point     as character no-undo init "Товарная спецификация к договору" .
define variable filter-point0    as character no-undo init "Товарная спецификация к договору" .
define variable p-ask as logical   no-undo .
define variable v-ask as logical   no-undo .
define variable   v-list-mat as character no-undo .
define variable head-col        as character no-undo .
define variable v-order-column  as character no-undo .
define variable v-spis-size     as character no-undo .
define variable v-spis-vis      as character no-undo .
define variable hcolumn         as handle extent 100  no-undo.
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .

v-err-ext = false  .
v-longchar = "".
{ ref/clearlm.i }


define new shared buffer temp-trn-doc for gds-list-flt  .
define variable r-2 as integer   no-undo init 1 .

create gds-list-flt.
gds-list-flt.gds-code = 0 .
release gds-list-flt .

  define temp-table temp-conn no-undo
    field ri  as  recid
    index pi  is primary   ri
  .

  define temp-table tt-contract-specif no-undo
    field artic     like ub.contract-specif.artic
    field prod-type like ub.contract-specif.prod-type
    field prod-code like ub.contract-specif.prod-code
    field gds-name  like ub.goods.gds-name
    field price-cli like ub.contract-specif.price-cli
    field prc       like ub.contract-specif.prc
    field prc-2     as decimal
    field vat-pc    like ub.contract-specif.vat-pc
    field vat-type  like ub.contract-specif.vat-type
    field bonus     as decimal
    field line-num  as integer
  index pi is primary unique
    artic
    prod-type
    prod-code
  .

  define stream slog.

&scop col-l0  '*'
&scop col-l1  'Код !Договора'
&scop col-l2  'Код !Поставщика'
&scop col-l3  'Поставщик! '
&scop col-l4  'Фирма! '
&scop col-l5  'Цена !поставщика'
&scop col-l6  '% Отклон!в большую сторону'
&scop col-l7  '% Отклон!в меньшую сторону'
&scop col-l8  'Статус !договора'
&scop col-l9  'Количество'
&scop col-l10  'Е.И'
&scop col-l11 'Дата закрытия!договора'
&scop col-l12 'НДС'
&scop col-l13 'тип!НДС'
&scop col-l14 'Принято'
&scop col-l15 '%!Бонус'
&scop col-l16 'Внешний!Артикул'

head-col =
  {&col-l0}     + '#' +
  {&col-l1}     + '#' +
  {&col-l2}     + '#' +
  {&col-l3}     + '#' +
  {&col-l4}     + '#' +
  {&col-l5}     + '#' +
  {&col-l6}     + '#' +
  {&col-l7}     + '#' +
  {&col-l8}     + '#' +
  {&col-l9}     + '#' +
  {&col-l10}    + '#' +
  {&col-l11}    + '#' +
  {&col-l12}    + '#' +
  {&col-l13}    + '#' +
  {&col-l14}    + '#' +
  {&col-l15}    + '#' +
  {&col-l16}  .

&scop cop-l0  mark-string(recid(buf_contract-specif))
&scop cop-l1  buf_contract-specif.contract-num
&scop cop-l2  string(buf_contract.cli-type + ' ' + string(buf_contract.cli-code))
&scop cop-l3  buf_contract.cli-name
&scop cop-l4  buf_contract.host-code
&scop cop-l5  buf_contract-specif.price-cli
&scop cop-l6  buf_contract-specif.prc
&scop cop-l7  f-prc-min(recid(buf_contract-specif))
&scop dyn_cop-l7 substitute('dynamic-function(&1f-prc-min&1, recid(buf_contract-specif))', ~{&double-quote~} )
&scop cop-l8  status-contract(recid(buf_contract-specif))
&scop dyn_cop-l8  substitute('dynamic-function(&1status-contract&1, recid(buf_contract-specif))', ~{&double-quote~} )
&scop cop-l9  buf_contract-specif.qnty
&scop cop-l10  buf_contract-specif.unit-base
&scop cop-l11      close-contract(recid(buf_contract-specif))
&scop dyn_cop-l11  substitute('dynamic-function(&1close-contract&1, recid(buf_contract-specif))', ~{&double-quote~} )
&scop cop-l12 buf_contract-specif.vat-pc
&scop cop-l13 buf_contract-specif.vat-type
&scop cop-l14 buf_contract-specif.income-qnty
&scop cop-l15 f-bonus(recid(buf_contract-specif))
&scop dyn_cop-l15 substitute('dynamic-function(&1f-bonus&1, recid(buf_contract-specif))', ~{&double-quote~} )
&scop cop-l16  get-ext-artic(recid(buf_contract-specif))
&scop dyn_cop-l16 substitute('dynamic-function(&1get-ext-artic&1, recid(buf_contract-specif))', ~{&double-quote~} )

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME spec-List

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_contract-specif buf_contract ~
temp-trn-doc

/* Definitions for BROWSE spec-List                                     */
&Scoped-define FIELDS-IN-QUERY-spec-List {&cop-l0} {&cop-l1} {&cop-l2} {&cop-l3} {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10} {&cop-l11} {&cop-l12} {&cop-l13} {&cop-l14} {&cop-l15} {&cop-l16}
&Scoped-define ENABLED-FIELDS-IN-QUERY-spec-List {&cop-l8}
&Scoped-define SELF-NAME spec-List
&Scoped-define QUERY-STRING-spec-List FOR EACH buf_contract-specif NO-LOCK, ~
       first buf_contract NO-LOCK where       buf_contract.host-code = buf_contract-specif.host-code and       buf_contract.contract-code = buf_contract-specif.contract-num , ~
       first temp-trn-doc where (r-2 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code ) indexed-reposition
&Scoped-define OPEN-QUERY-spec-List OPEN QUERY {&SELF-NAME} FOR EACH buf_contract-specif NO-LOCK, ~
       first buf_contract NO-LOCK where       buf_contract.host-code = buf_contract-specif.host-code and       buf_contract.contract-code = buf_contract-specif.contract-num , ~
       first temp-trn-doc where (r-2 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code ) indexed-reposition.
&Scoped-define TABLES-IN-QUERY-spec-List buf_contract-specif buf_contract ~
temp-trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-spec-List buf_contract-specif
&Scoped-define SECOND-TABLE-IN-QUERY-spec-List buf_contract
&Scoped-define THIRD-TABLE-IN-QUERY-spec-List temp-trn-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel b-exp b-filter-ext b-uf ~
B-print b-hist B-Help B-allmark B-unmark B-add-AssMatr B-del-AssMatr b-prc ~
FILL-prc b-all b-prc-2 FILL-prc-2 b-all-2 b-prc-bonus FILL-prc-bonus ~
b-all-bonus RADIO-find sch-str spec-List mark-num
&Scoped-Define DISPLAYED-OBJECTS b-prc FILL-prc b-prc-2 FILL-prc-2 ~
b-prc-bonus FILL-prc-bonus RADIO-find sch-str mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD close-contract Dialog-Frame
FUNCTION close-contract RETURNS date
  ( input p-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-bonus Dialog-Frame
FUNCTION f-bonus RETURNS DECIMAL
  ( input par-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-b-code Dialog-Frame
FUNCTION get-b-code RETURNS CHARACTER
  ( input gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-ext-artic Dialog-Frame
FUNCTION get-ext-artic RETURNS CHARACTER
  ( input p-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  ( input p-gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD status-contract Dialog-Frame
FUNCTION status-contract RETURNS CHARACTER
  ( input p-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-prc-min Dialog-Frame
FUNCTION f-prc-min RETURNS DECIMAL
  ( input par-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add-AssMatr
     LABEL "Доб. в &АМ"
     SIZE 10 BY 1 TOOLTIP "Добавить в Ассортиментные матрицы выделенный товар".

DEFINE BUTTON b-all
     LABEL "&Применить"
     SIZE 10 BY 1 TOOLTIP "Применить ко всем выдимым строкам".

DEFINE BUTTON b-all-2
     LABEL "&Применить"
     SIZE 10 BY 1 TOOLTIP "Применить ко всем выдимым строкам".

DEFINE BUTTON b-all-bonus
     LABEL "Применить"
     SIZE 10 BY 1 TOOLTIP "Применить ко всем выдимым строкам".

DEFINE BUTTON B-allmark
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Отметить все".

DEFINE BUTTON B-del-AssMatr
     LABEL "Уд. из &АМ"
     SIZE 10 BY 1 TOOLTIP "Удалить из Ассортиментных матриц выбранные товары".

DEFINE BUTTON b-exp
     LABEL "&Договор"
     SIZE 10 BY 1.

DEFINE BUTTON b-filter-ext
     IMAGE-UP FILE "cmp/b-schef.bmp":U
     LABEL "Расширенный фильтр"
     SIZE 3 BY 1 TOOLTIP "Расширенный фильтр".

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "&Печать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-uf
     IMAGE-UP FILE "cmp/b-must.bmp":U
     LABEL "b-uf"
     SIZE 3 BY 1 TOOLTIP "Настройка колонок пользователем".

DEFINE BUTTON B-unmark
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все *".

DEFINE VARIABLE FILL-prc AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-prc-2 AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-prc-bonus AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 5.5 BY 1 NO-UNDO.

DEFINE VARIABLE sch-str AS CHARACTER FORMAT "X(256)"
     VIEW-AS FILL-IN
     SIZE 35 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RADIO-find AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Код поставщика", 1,
"N фирмы", 2,
"Название поставщика", 3
     SIZE 52.88 BY 1 NO-UNDO.

DEFINE VARIABLE b-prc AS LOGICAL INITIAL no
     LABEL "Допустимый % отклонения цены в приходе в большую сторону:"
     VIEW-AS TOGGLE-BOX
     SIZE 59.5 BY 1 NO-UNDO.

DEFINE VARIABLE b-prc-2 AS LOGICAL INITIAL no
     LABEL "Допустимый % отклонения цены в приходе в меньшую сторону:"
     VIEW-AS TOGGLE-BOX
     SIZE 59.5 BY 1 NO-UNDO.

DEFINE VARIABLE b-prc-bonus AS LOGICAL INITIAL no
     LABEL "Бонус %:"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY spec-List FOR
      buf_contract-specif,
      buf_contract,
      temp-trn-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE spec-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS spec-List Dialog-Frame _FREEFORM
  QUERY spec-List DISPLAY
      {&cop-l0}    COLUMN-LABEL {&col-l0}  Format "X(1)"
     {&cop-l1}    COLUMN-LABEL {&col-l1}
     {&cop-l2}    COLUMN-LABEL {&col-l2}
     {&cop-l3}    COLUMN-LABEL {&col-l3}
     {&cop-l4}    COLUMN-LABEL {&col-l4}  format ">>>>>>>>>9"
     {&cop-l5}    COLUMN-LABEL {&col-l5}  format ">,>>>,>>>,>>9.99"
     {&cop-l6}    COLUMN-LABEL {&col-l6}  Format "->>>>9.99"
     {&cop-l7}    COLUMN-LABEL {&col-l7}  Format "->>>>9.99"
     {&cop-l8}    COLUMN-LABEL {&col-l8}
     {&cop-l9}    COLUMN-LABEL {&col-l9}
     {&cop-l10}   COLUMN-LABEL {&col-l10}
     {&cop-l11}   COLUMN-LABEL {&col-l11} format "99/99/9999"
     {&cop-l12}   COLUMN-LABEL {&col-l12} Format ">>9.9"
     {&cop-l13}   COLUMN-LABEL {&col-l13}
     {&cop-l14}   COLUMN-LABEL {&col-l14}
     {&cop-l15}   COLUMN-LABEL {&col-l15}
     {&cop-l16}   COLUMN-LABEL {&col-l16} Format "X(16)"
     enable {&cop-l9}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 17.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 20
     b-exp AT ROW 1 COL 30
     b-filter-ext AT ROW 1 COL 84.5 WIDGET-ID 14
     b-uf AT ROW 1 COL 87.5 WIDGET-ID 12
     B-print AT ROW 1 COL 90.75
     b-hist AT ROW 1 COL 93.88
     B-Help AT ROW 1 COL 97.13
     B-allmark AT ROW 2 COL 11
     B-unmark AT ROW 2 COL 14.13
     B-add-AssMatr AT ROW 2 COL 20 WIDGET-ID 2
     B-del-AssMatr AT ROW 2 COL 30 WIDGET-ID 4
     b-prc AT ROW 3 COL 21
     FILL-prc AT ROW 3 COL 78.5 COLON-ALIGNED NO-LABEL
     b-all AT ROW 3 COL 89.13
     b-prc-2 AT ROW 4 COL 21 WIDGET-ID 18
     FILL-prc-2 AT ROW 4 COL 78.5 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     b-all-2 AT ROW 4 COL 89.13 WIDGET-ID 16
     b-prc-bonus AT ROW 5 COL 70 WIDGET-ID 8
     FILL-prc-bonus AT ROW 5 COL 78.5 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     b-all-bonus AT ROW 5 COL 89.13 WIDGET-ID 6
     RADIO-find AT ROW 6.5 COL 10.75 NO-LABEL
     sch-str AT ROW 6.5 COL 62.63 COLON-ALIGNED NO-LABEL
     spec-List AT ROW 7.5 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "Поиск по:" VIEW-AS TEXT
          SIZE 9 BY 1 AT ROW 6.5 COL 1.13
          FGCOLOR 4
     SPACE(90.24) SKIP(17.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товарная спецификация к договору"
         DEFAULT-BUTTON b-all CANCEL-BUTTON b-quit.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB spec-List sch-str Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE spec-List
/* Query rebuild information for BROWSE spec-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_contract-specif NO-LOCK,
first buf_contract NO-LOCK where
      buf_contract.host-code = buf_contract-specif.host-code and
      buf_contract.contract-code = buf_contract-specif.contract-num ,
first temp-trn-doc where
(r-2 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code )
indexed-reposition.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE spec-List */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товарная спецификация к договору */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-AssMatr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-AssMatr Dialog-Frame
ON CHOOSE OF B-add-AssMatr IN FRAME Dialog-Frame /* Доб. в АМ */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .
  run proc-add-Ass in this-procedure .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-all Dialog-Frame
ON CHOOSE OF b-all IN FRAME Dialog-Frame /* Применить */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  message "Вы действительно хотите изменить % по спецификации ?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
  if g-log = no then return no-apply.
  assign FILL-prc .

    do transaction :
    for each  contract-specif exclusive-lock where
              contract-specif.host-code    = p-host-code and
              contract-specif.contract-num = p-doc-num
    , first temp-trn-doc where  ( r-2 = 1 or contract-specif.gds-code = temp-trn-doc.gds-code )  :
      assign
        contract-specif.prc = FILL-prc
        .
    end.
    assign
     is-new = yes
     .
  end.

  run openbr in this-procedure (yes, no, '':u).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-all-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-all-2 Dialog-Frame
ON CHOOSE OF b-all-2 IN FRAME Dialog-Frame /* Применить */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  message "Вы действительно хотите изменить % по спецификации ?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
  if g-log = no then return no-apply.
  assign FILL-prc-2 .

    do transaction :
    for each  contract-specif exclusive-lock where
              contract-specif.host-code = p-host-code and
              contract-specif.contract-num = p-doc-num
    , first temp-trn-doc where  ( r-2 = 1 or contract-specif.gds-code = temp-trn-doc.gds-code ) :
      run write-prc-min in this-procedure (
          contract-specif.contract-num  ,
          contract-specif.host-code     ,
          contract-specif.gds-code      ,
          FILL-prc-2 ).
    end.
    assign
    is-new = yes
    .
  end.
  run openbr in this-procedure (yes, no, '':u).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-all-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-all-bonus Dialog-Frame
ON CHOOSE OF b-all-bonus IN FRAME Dialog-Frame /* Применить */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  message "Вы действительно хотите Бонус по спецификации ?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
  if g-log = no then return no-apply.

  assign FILL-prc .
  do transaction :
    for each  contract-specif exclusive-lock where
              contract-specif.host-code = p-host-code and
              contract-specif.contract-num = p-doc-num
    , first temp-trn-doc where  ( r-2 = 1 or contract-specif.gds-code = temp-trn-doc.gds-code )  :
    run write-bonus (
    contract-specif.contract-num,
    contract-specif.host-code,
    contract-specif.gds-code,
    FILL-prc-bonus).
    end.

    assign is-new = yes .
  end.
  run openbr in this-procedure (yes, no, '':u).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-allmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-allmark Dialog-Frame
ON CHOOSE OF B-allmark IN FRAME Dialog-Frame /* + */
DO:
  for each temp-conn: delete temp-conn . end.
  assign mark-num = 0 .
  GET FIRST spec-List NO-LOCK .

  DO WHILE AVAILABLE(buf_contract-specif):
    create temp-conn .
    assign
      temp-conn.ri = recid( buf_contract-specif )
      mark-num = mark-num + 1
    .
    GET next spec-List NO-LOCK .
  end.

  if mark-num = 0 then hide    mark-num in frame {&frame-name}.
  else                 display mark-num  with frame {&frame-name}.
  RUN OpenBr(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-AssMatr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-AssMatr Dialog-Frame
ON CHOOSE OF B-del-AssMatr IN FRAME Dialog-Frame /* Уд. из АМ */
DO:
   { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  run proc-del-AssMat in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exp Dialog-Frame
ON CHOOSE OF b-exp IN FRAME Dialog-Frame /* Договор */
DO:
    run str/sh-contr.p
        (input  parParentProc
        ,input recid( buf_contract )
        ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-filter-ext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-filter-ext Dialog-Frame
ON CHOOSE OF b-filter-ext IN FRAME Dialog-Frame /* Расширенный фильтр */
DO:
  if r-2 = 1 then r-2 = 2 .
             else r-2 = 1.

  if r-2 = 2 then do:
    /* установим расширенный фильтр красный */

     find first gds-list-flt where gds-list-flt.gds-code = 0 no-error .
     if available gds-list-flt then delete gds-list-flt.
     release gds-list-flt .
    run str/fext-gds.w
        ( parparentproc ,
        v-cntxt-host-code-obj,
        v-cntxt-obj-type,
        v-cntxt-obj-code
        ).
    if not can-find (first gds-list-flt ) then  do:
        create gds-list-flt.
        gds-list-flt.gds-code = 0 .
        release gds-list-flt .
        message "Расширенный фильтр пуст!" view-as alert-box information .
    end.
    b-filter-ext:LOAD-IMAGE ("cmp/b-sche.bmp") .
    find last gds-list-flt-hist.

     b-filter-ext:tooltip =  gds-list-flt-hist.des .

  end.
  else do:
  /* снять фильтр  синий */
     b-filter-ext:LOAD-IMAGE ("cmp/b-schef.bmp") .
     b-filter-ext:tooltip = "Расширенный фильтр не установлен" .
  end.
  run OpenBr in this-procedure ( yes, no, '':U ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  if available buf_contract-specif then DO:
     run str/contsp-c.w (
             input parparentproc,
             input buf_contract-specif.host-code,
             input buf_contract-specif.contract-num,
             input buf_contract-specif.gds-code
             ).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  if not available buf_contract-specif then return no-apply.

  find first temp-conn where temp-conn.ri = recid( buf_contract-specif ) no-error  .
  if available temp-conn then do:
    delete temp-conn .
    assign  mark-num = mark-num - 1 .
  end.
  else do:
    if b-sel:sensitive and mark-num >= 4000 then do:
      message "Превышено максимально допустимое количество выбранных строк." skip
              "Отбирайте необходимые товары по частям"
      view-as alert-box WARNING.
      apply "entry" to spec-List .
      return no-apply.
    end.
    create temp-conn .
    assign
      temp-conn.ri = recid( buf_contract-specif )
      mark-num = mark-num + 1
    .
  end.
  g-log = spec-List:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
    g-log = spec-List:select-next-row ().
    apply "value-changed" to spec-List in frame {&frame-name}.
  end.
  if mark-num = 0 then hide mark-num in frame {&frame-name}.
  else              display mark-num with frame {&frame-name}.

  apply "entry" to spec-List .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prc Dialog-Frame
ON VALUE-CHANGED OF b-prc IN FRAME Dialog-Frame /* Допустимый % отклонения цены в приходе в большую сторону: */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  assign b-prc .
  if b-prc then ENABLE FILL-prc b-all WITH FRAME Dialog-Frame.
  else  do:
    assign FILL-prc = 0 .
    DISABLE FILL-prc b-all WITH FRAME Dialog-Frame.
    if dec(FILL-prc:screen-value) <> FILL-prc then assign is-new1 = yes .
  end.
  display FILL-prc b-all WITH FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prc-2 Dialog-Frame
ON VALUE-CHANGED OF b-prc-2 IN FRAME Dialog-Frame /* Допустимый % отклонения цены в приходе в меньшую сторону: */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  assign b-prc-2 .
  if b-prc-2 then ENABLE FILL-prc-2 b-all-2 WITH FRAME Dialog-Frame.
  else  do:
    assign FILL-prc-2 = 0 .
    DISABLE FILL-prc-2 b-all-2 WITH FRAME Dialog-Frame.
    if dec(FILL-prc-2:screen-value) <> FILL-prc-2 then assign is-new1 = yes .
  end.
  display FILL-prc-2 b-all-2 WITH FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prc-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prc-bonus Dialog-Frame
ON VALUE-CHANGED OF b-prc-bonus IN FRAME Dialog-Frame /* Бонус %: */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  assign b-prc-bonus .
  if b-prc-bonus then ENABLE FILL-prc-bonus b-all-bonus WITH FRAME Dialog-Frame.
  else  do:
    assign FILL-prc-bonus = 0 .
    DISABLE FILL-prc-bonus b-all-bonus WITH FRAME Dialog-Frame.
    if dec(FILL-prc-bonus:screen-value) <> FILL-prc-bonus then assign is-new1 = yes .
  end.
  display FILL-prc-bonus b-all-bonus WITH FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-print in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:  /* отказ - выход  */

  /* Выдаем предупреждение, если есть отмеченные записи и доступна кнопка выбора */
  find first temp-conn no-error.
  if available temp-conn then do:
    run gbl/markqwa.p ( input b-sel:sensitive, input string(temp-conn.ri)) no-error.
    if error-status:error then do:
      apply "entry" to spec-List .
      return no-apply.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  rid-list = "".
  for each temp-conn :
    rid-list = rid-list + ( if rid-list = "":U then "":U else {&comma-char} ) + string(temp-conn.ri).
  end.

  if ( rid-list = "" ) and ( available buf_contract-specif ) then do:
    rid-list = string( recid( buf_contract-specif ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-uf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-uf Dialog-Frame
ON CHOOSE OF b-uf IN FRAME Dialog-Frame /* b-uf */
DO:
  run gbl/vi-coll.w ( input Parparentproc, input this-procedure , input {&uf-contspec-gds} , input  head-col ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-unmark Dialog-Frame
ON CHOOSE OF B-unmark IN FRAME Dialog-Frame /* - */
DO:
  GET FIRST spec-List NO-LOCK .
  if not available buf_contract-specif then return no-apply.

  for each temp-conn: delete temp-conn . end.
  assign mark-num = 0 .
  g-log = spec-List:refresh() .

  hide mark-num in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-prc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-prc Dialog-Frame
ON RETURN OF FILL-prc IN FRAME Dialog-Frame
OR LEAVE OF FILL-prc IN FRAME Dialog-Frame
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  assign FILL-prc .
  if b-prc and dec(FILL-prc:screen-value) <> FILL-prc then assign is-new1 = yes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-prc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-prc-2 Dialog-Frame
ON RETURN OF FILL-prc-2 IN FRAME Dialog-Frame
OR LEAVE OF FILL-prc IN FRAME Dialog-Frame
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  assign FILL-prc-2 .
  if b-prc-2 and dec(FILL-prc-2:screen-value) <> FILL-prc-2 then assign is-new1 = yes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-prc-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-prc-bonus Dialog-Frame
ON RETURN OF FILL-prc-bonus IN FRAME Dialog-Frame
OR LEAVE OF FILL-prc-bonus IN FRAME Dialog-Frame
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  assign FILL-prc-bonus .
  if b-prc-bonus and dec (FILL-prc-bonus:screen-value) <> FILL-prc-bonus then assign is-new1 = yes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-find
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-find Dialog-Frame
ON VALUE-CHANGED OF RADIO-find IN FRAME Dialog-Frame
DO:
  assign
     RADIO-find
     sch-str
     .

  if sch-str <> "" then do:
  /*
    run proc-find-code in this-procedure(no, input sch-str) no-error.
    if error-status:error then return no-apply.
  */
     RUN proc-find-code-n IN THIS-PROCEDURE(
         INPUT RADIO-find,
         INPUT sch-str,
         TRUE).


  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dialog-Frame
ON CTRL-J OF sch-str IN FRAME Dialog-Frame
DO:
  assign
     sch-str
     RADIO-find .
  /*
  run proc-find-code in this-procedure(yes, input sch-str) no-error.
  if error-status:error then return no-apply.
  */
  RUN proc-find-code-n IN THIS-PROCEDURE(
      INPUT RADIO-find,
      INPUT sch-str,
      FALSE).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dialog-Frame
ON RETURN OF sch-str IN FRAME Dialog-Frame
DO:
  assign
     sch-str
     RADIO-find
     .
  /*
  run proc-find-code in this-procedure(no, input sch-str) no-error.
  if error-status:error then return no-apply.
  */
  RUN proc-find-code-n IN THIS-PROCEDURE(
      INPUT RADIO-find,
      INPUT sch-str,
      TRUE).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME spec-List
&Scoped-define SELF-NAME spec-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL spec-List Dialog-Frame
ON RETURN OF spec-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF spec-List IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
{ gbl/getcntxt.i get }
{ gbl/brwrefre.i "run OpenBr(yes, no, '':U)." }

on F9 of frame {&frame-name} anywhere do:
  if not available buf_contract-specif then  return no-apply.
  find first goods no-lock where goods.gds-code = buf_contract-specif.gds-code .
  gds-rec = recid(goods) .
  run ref/gds-form.w
    (input  parParentProc
    ,input  {&lookup}
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input ? /*p-call-handle*/
    ,input-output gds-rec
    ).

  apply "entry" to spec-List in frame {&frame-name}.
  return no-apply.
end.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/brwrepos.i  &line-num=16 }

/* { gbl/f2.i spec-List goods-recid init-gds-rec parParentProc }*/

/* сорт  колонок*/

{ gbl/srt-clmd.i
  &table-name     = "buf_contract-specif"
  &browse-name = "spec-List"
  &frame-name = "{&frame-name}"
  &ext-col = 17
  &open-query     = "run OpenBr(yes, no, '':U)."
  &open-query-otherwise = "run OpenBr(yes, no, '':U)."
  &sort-column-name = "sort-column-name"
  &start-column         = "1"
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
  &label-clmn_6         = "{&col-l6}"
  &sort-clmn_6          = "{&cop-l6}"
  &label-clmn_7         = "{&col-l7}"
  &sort-clmn_7          = "{&cop-l7}"
  &dyn_sort-clmn_7     = "{&dyn_cop-l7}"
  &label-clmn_8         = "{&col-l8}"
  &sort-clmn_8          = "{&cop-l8}"
  &dyn_sort-clmn_8     = "{&dyn_cop-l8}"
  &label-clmn_9         = "{&col-l9}"
  &sort-clmn_9          = "{&cop-l9}"
  &label-clmn_10        = "{&col-l10}"
  &sort-clmn_10         = "{&cop-l10}"
  &label-clmn_11        = "{&col-l11}"
  &sort-clmn_11         = "{&cop-l11}"
  &dyn_sort-clmn_11     = "{&dyn_cop-l11}"
  &label-clmn_12        = "{&col-l12}"
  &sort-clmn_12         = "{&cop-l12}"
  &label-clmn_13        = "{&col-l13}"
  &sort-clmn_13         = "{&cop-l13}"
  &label-clmn_14        = "{&col-l14}"
  &sort-clmn_14         = "{&cop-l14}"
  &label-clmn_15        = "{&col-l15}"
  &sort-clmn_15         = "{&cop-l15}"
  &dyn_sort-clmn_15     = "{&dyn_cop-l15}"
  &label-clmn_16        = "{&col-l16}"
  &sort-clmn_16         = "{&cop-l16}"
  &dyn_sort-clmn_16     = "{&dyn_cop-l16}"
  &label-clmn_17        = "{&col-l0}"
  &sort-clmn_17         = "{&cop-l0}"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
 }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  assign
    spec-List:num-locked-columns = 1
    {&cop-l9}:read-only in browse spec-List = yes
  .

  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code.
  assign frame {&frame-name}:title = substitute(" Список спецификаций по товару &1 &2" , p-gds-code , buf_goods.gds-name ) .
  run myenable in this-procedure no-error .
  run openbr in this-procedure (yes, no, '':u) .
  run init-browse-p  in this-procedure .
  { gbl/mv-clmn.i
    &browse-name = "spec-List"
    &frame-name = "{&frame-name}"
    &ext-col = 17
    &start-column = "1"
    &prev-order-column_1 = v-order-column
    &prev-order-column-condition_1 = " true = true "
  }
  if v-cntxt-db-num = 0 and b-prc:SENSITIVE then  apply "VALUE-CHANGED" to b-prc IN FRAME Dialog-Frame .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-assmatr Dialog-Frame
PROCEDURE add-assmatr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-rid-list as character no-undo .
/*  */
DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
/*  */
if v-cntxt-db-num <> 0 then do :
   if not can-find ( first assortment-matrix no-lock where  assortment-matrix.asmt-status = integer ({&current-status-int}) and
                                                            assortment-matrix.db-num = v-cntxt-db-num )  then return .
end.
else do:
   if not can-find ( first assortment-matrix no-lock where  assortment-matrix.asmt-status = integer ({&current-status-int}))  then return .
end.
define variable v-kol as integer   no-undo .
v-kol = num-entries (p-rid-list).

if v-kol = 0  then do:
    /* message "Не выбрана ни одна ассортиментная матрица !"
      "Внести товар в Ассортиментную матрицу можно в одноименном справочнике ."
       view-as alert-box information . */
   return .
end.
define variable v-i as integer   no-undo .
define buffer buf_assortment-matrix for assortment-matrix.
define variable p-doc-rec  as recid no-undo .

v-err-ext = false .
v-longchar = "".
repeat v-i = 1 to v-kol :
  find first  buf_assortment-matrix no-lock where recid(buf_assortment-matrix) = integer (entry(v-i,p-rid-list )) no-error .
  if available buf_assortment-matrix then do:
  if buf_assortment-matrix.asmt-status <> integer ({&current-status-int})   then do: message substitute("АМ &1 - удалена , в нее добавлять товар нельзя !" ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj ) view-as alert-box information . next. end.
  if v-cntxt-db-num <> 0 and
     (( buf_assortment-matrix.asmt-type = {&type-assmatr-obj}     and buf_assortment-matrix.db-num-obj         <> v-cntxt-db-num ) or
      ( buf_assortment-matrix.asmt-type = {&type-assmatr-shablon} and buf_assortment-matrix.asmt-db-num-create <> v-cntxt-db-num ))
      then do:
          v-err-ext = true  .
          v-longchar = v-longchar + substitute("АМ &1 чужой БД &2 , в нее добавлять товар нельзя !" ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj ) + {&new-line}.
          next.
      end.

      /* Cюда добавляем проверку на % отклонения матрицы от шаблона !!!  */
      /* Проверку производимто только если товара нет в АМ  */
      IF NOT Is-Gds-In-AssMatr(p-gds-code,
                               buf_assortment-matrix.asmt-id,
                               buf_assortment-matrix.db-num) THEN DO:
         /* Снимаем параметры АМ   */
         RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
             buf_assortment-matrix.asmt-id,
             buf_assortment-matrix.db-num,
             OUTPUT cError
             ).
         if cError <> "" THEN DO:
             v-err-ext = true .
             v-longchar = v-longchar +
                          PROGRAM-NAME(1) + ":" + cError +
                          substitute("&1 &2 &3 " ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj, {&new-line})
                          .
             NEXT.
         END.

         /* Проверка допустимого % отклонения (Добавляется 1 товар )  */
         RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
            1,
            OUTPUT cError
            ).
         /*  */
         if cError <> "" THEN DO:
             v-err-ext = true .
             v-longchar = v-longchar +
                          PROGRAM-NAME(1) + ":" + cError +
                          substitute("&1 &2 &3 " ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj, {&new-line})
                          .
             NEXT.
         END.
      END.
      /*  */
      { ref/gds-mat1.i
        this-procedure
        p-doc-rec
        {&add-def}
        buf_assortment-matrix.asmt-id
        buf_assortment-matrix.db-num
        p-gds-code
        "''"
        no-error }
        if error-status :error then do:
          v-err-ext = true  .
          v-longchar = v-longchar + return-value  + {&new-line} .
        end.
  end.
end.

  if v-err-ext = true  then do:
  define variable v-ok as logical   no-undo .
    run gbl/d-longchar.w (
          ?,
          'Editor_row=2\':u
        + 'title=При корректировке в Ассортиментные матрицы\':u
        + 'Editor_col=1\':u
        + 'Editor_width=96\':u
        + 'Editor_height=21\':u
        + 'readonly=yes\':u
      ,input-output v-longchar
      ,output v-ok ) no-error .
        v-longchar = "" .
        { ref/clearlm.i }

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY b-prc FILL-prc b-prc-2 FILL-prc-2 b-prc-bonus FILL-prc-bonus
          RADIO-find sch-str mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel b-exp b-filter-ext b-uf B-print b-hist B-Help
         B-allmark B-unmark B-add-AssMatr B-del-AssMatr b-prc FILL-prc b-all
         b-prc-2 FILL-prc-2 b-all-2 b-prc-bonus FILL-prc-bonus b-all-bonus
         RADIO-find sch-str spec-List mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-browse-p Dialog-Frame
PROCEDURE init-browse-p :
/* Настройки экрана по пользователю */
  do
  on error undo, return error return-value
  :

  define variable cur-clmn-loc as integer   no-undo .
  define variable column-handle as handle no-undo .


  assign
    cur-clmn-loc  = 1
    column-handle = {&browse-name}:first-column   in frame {&frame-name}
    hcolumn [cur-clmn-loc] = column-handle
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = {&browse-name}:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      hcolumn [cur-clmn-loc] = column-handle
    .
  end.

run uf-get in this-procedure (
     input  {&uf-contspec-gds}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
    ) no-error  .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "e"
      view-as alert-box error
    .

v-order-column  =  (entry(1, v-uf-List_ ,{&delim-par})) no-error.
v-spis-size     =  (entry(2, v-uf-List_ ,{&delim-par})) no-error.
v-spis-vis      =  (entry(3, v-uf-List_ ,{&delim-par})) no-error.

/*
message 'проверим что в uf' {&uf-cli-zakz} + g#type v-cntxt-userid skip
'v-order-column ' v-order-column skip
'v-spis-size    ' v-spis-size    skip
'v-spis-vis     ' v-spis-vis     skip
"кол-во кол" {&browse-name} :NUM-COLUMNS  in frame {&frame-name}
.
*/

if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column  = {&contspec-g-ord} .
if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size     = {&contspec-g-siz} .
if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis      = {&bef-contspec-g-vis} .

define variable col-h as handle no-undo .
define variable ii as integer   no-undo .

repeat ii = 1 to cur-clmn-loc   :
    col-h = hcolumn [ ii ]  .
    if decimal(entry(ii,v-spis-size))  = 0 then message ii.
    col-h:width  = decimal(entry(ii,v-spis-size))   .
    col-h:visible  = logical(entry(ii,v-spis-vis))  .
 end.

  end.

end procedure. /* init-browse-p */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DISPLAY b-prc  b-prc-2 b-prc-bonus FILL-prc FILL-prc-2 sch-str RADIO-find mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit
         B-mark     when (lookup("B-mark":U, bttns) > 0)
         B-unmark   when (lookup("B-mark":U, bttns) > 0)
         B-allmark  when (lookup("B-mark":U, bttns) > 0)
         b-sel      when (lookup("b-sel":U, bttns) > 0)
         b-exp B-print B-Help
         b-hist sch-str RADIO-find spec-List mark-num
         b-filter-ext
         b-uf
      WITH FRAME Dialog-Frame.

  /* Отключаем фильтр b-filter-ext
     но на всякий случай весь код оставляем !!!  */
   ASSIGN
      b-filter-ext:HIDDEN  = TRUE
      b-filter-ext:VISIBLE = FALSE
      .

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
  {&SetCursorWait}

  define variable sort-column-phrase as character no-undo .
  case sort-column-name :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name .
  end case.

  /* определяем здесь общие параметры для процедуры открытия query fltopend.i */
  &scop flt-open-open-query           OPEN QUERY spec-List FOR EACH buf_contract-specif NO-LOCK
  &scop flt-open-dyn_open-query       FOR EACH buf_contract-specif
  &scop flt-open-query-handle         query spec-List:handle
  &scop flt-open-open-query-tail     ,  first buf_contract NO-LOCK where       buf_contract.host-code = buf_contract-specif.host-code and       buf_contract.contract-code = buf_contract-specif.contract-num , ~
  first temp-trn-doc where (r-2 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code )
  &scop flt-open-dyn_open-query-tail   substitute(' , first buf_contract NO-LOCK where       buf_contract.host-code = buf_contract-specif.host-code and       buf_contract.contract-code = buf_contract-specif.contract-num ,first temp-trn-doc where ( &1 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code )',  r-2 )

  &scop flt-open-waitfram            true
  &scop flt-open-query-was-opened    l-query-was-opened
  &scop flt-open-sort-column-phrase  sort-column-phrase
  &scop flt-open-call-point          filter-point
  &scop flt-open-query               p-open-query
  &scop flt-open-table-name          buf_contract-specif
  &scop flt-open-search-option       no-lock
  &scop flt-open-find-next           p-find-next
  &scop flt-open-find-recid          v-doc-rec
  &scop flt-open-find-condition      p-find-condition
  &scop flt-open-find-buffer-name    buf_contract-specif
  &scop flt-open-debug-file

  define variable l-open-query as logical  no-undo .

  filter-point = filter-point0 .

  if available buf_contract-specif then assign v-doc-rec = recid (buf_contract-specif) .
  { gbl/fltopend.i
    &where-cond = " buf_contract-specif.gds-code = p-gds-code "
    &DYN_where-cond = " substitute(' buf_contract-specif.gds-code = &1 ', p-gds-code ) "
    &use-ind = "  "
    &by = " "
  }

  if v-doc-rec <> ? THEN DO:
  REPOSITION spec-List to recid v-doc-rec No-ERROR.
  END.

  apply "entry" to spec-List in frame Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-del-assMat Dialog-Frame
PROCEDURE proc-del-assMat :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bb_contract-specif for ub.contract-specif  .
define buffer buf_assortment-matrix for ub.assortment-matrix  .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .

define variable v-ass-m     as logical   no-undo init false .
define variable v-log       as logical   no-undo .
define variable v-sts       as integer   no-undo .
define variable p-rid-list  as character no-undo .
define variable i           as integer   no-undo .

v-err-ext  = false  .
v-longchar = ""     .


if not can-find ( first temp-conn) then do:
    message "Не выделено ни одного товара !" view-as alert-box .
    return .
end.

if v-cntxt-db-num <> 0 then do :
   if can-find ( first assortment-matrix no-lock where  assortment-matrix.asmt-status = integer ({&current-status-int}) and
                                                        assortment-matrix.db-num = v-cntxt-db-num )  then v-ass-m = true  .
end.
else do:
   if can-find ( first assortment-matrix no-lock where  assortment-matrix.asmt-status = integer ({&current-status-int}))  then v-ass-m = true  .
end.

if v-ass-m = false  then return .

/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_deletion':U
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
 if not v-log then return  .


  message "Удалить Выбранные товары спецификации  из  Ассортиментных матриц ?"
          "Если ДА , укажите из каких."
          view-as alert-box question
                  buttons yes-no
                  update v-okk as logical
                  .
  if not v-okk then return .
      run ref/assmatr.w (
            input parParentProc
          ,input "b-sel,b-mark"
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input ?
          ,input ?
          ,input-output p-rid-list
      ) no-error  .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .

v-err-ext = false  .
v-longchar = "" .

run waitfram-show ("Удаление из Ассортиментных матриц")  .
for each temp-conn,
    first bb_contract-specif no-lock  where
    recid(bb_contract-specif) = temp-conn.ri :


repeat i = 1 to num-entries(p-rid-list) :
  find first buf_assortment-matrix no-lock where
             recid(buf_assortment-matrix) = int(entry(i,p-rid-list)) no-error .

  for each buf_assortment-matrix-goods no-lock where
           buf_assortment-matrix-goods.asmt-id  = buf_assortment-matrix.asmt-id and
           buf_assortment-matrix-goods.db-num   = buf_assortment-matrix.db-num  and
           buf_assortment-matrix-goods.gds-code = bb_contract-specif.gds-code
           :
    for each buf_gds-obj-prop exclusive-lock where
             buf_gds-obj-prop.obj-type = buf_assortment-matrix.obj-type and
             buf_gds-obj-prop.obj-code = buf_assortment-matrix.obj-code and
             buf_gds-obj-prop.gds-code = buf_assortment-matrix-goods.gds-code
             :
            if not (buf_gds-obj-prop.gdop-igt = {&ass-izd-empty} or
                    buf_gds-obj-prop.gdop-igt = {&ass-izd-del} ) then do:
                  v-err-ext = true  .
                  v-longchar = v-longchar +
                  substitute ( "Принудительная смена ИЖТ &1 на <<пусто>> товар &2 &3&4&5 " ,
                                buf_gds-obj-prop.gdop-igt ,
                                buf_assortment-matrix-goods.gds-code,
                                buf_assortment-matrix.obj-type,
                                buf_assortment-matrix.obj-code  ,
                                {&new-line} ) .

                assign
                  buf_gds-obj-prop.gdop-igt = {&ass-izd-empty}
                  .
            end.
    end.

    if buf_assortment-matrix-goods.asmg-status = int({&current-status-int}) then do:
        v-sts = int({&deleted-status-int}) .
        { ref/gds-mat2.i
          this-procedure
          recid(buf_assortment-matrix-goods)
          v-sts
          no
          no-error }
        if error-status :error then do:
           v-err-ext = true .
           v-longchar = v-longchar + return-value + {&new-line} .
        end.
    end.
  end.
end.
end.
run waitfram-hide .
if v-err-ext = true  then do:
define variable v-ok as logical   no-undo .
  run gbl/d-longchar.w (
        ?,
        'Editor_row=2\':u
      + 'title=При добавлении в Ассортиментные матрицы\':u
      + 'Editor_col=1\':u
      + 'Editor_width=96\':u
      + 'Editor_height=21\':u
      + 'readonly=yes\':u
    ,input-output v-longchar
    ,output v-ok ) no-error .
    v-longchar = "" .
    { ref/clearlm.i }

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-export-excel Dialog-Frame
PROCEDURE proc-export-excel :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_contract-specif for ub.contract-specif.

  define variable chExcelApplication as com-handle no-undo .
  define variable chWorkbook         as com-handle no-undo .
  define variable chWorksheet        as com-handle no-undo .
  define variable chRange            as com-handle no-undo .
  define variable v-cell             as char       no-undo .
  define variable v-sheets-count     as integer    no-undo .
  define variable v-i                as integer    no-undo .
  define variable v-filename         as character  no-undo .
  define variable v-log              as logical    no-undo .
  define variable v-bonus            as decimal    no-undo .
  define variable v-ext              as character no-undo .

do for buf_contract-specif
on error undo, return error return-value
:
  assign
    v-filename = string(p-doc-num) + ".xls"
    v-log      = yes
  .
  system-dialog get-file v-filename filters "Спецификации к договорам *.xls" "*.xls"
                         use-filename   SAVE-AS   ASK-OVERWRITE   update v-log   default-extension "xls".
  if not v-log then return .
  run waitfram-show in this-procedure ("Ждите...").

  { gbl/working.i }
  /**  Открытие Excel  **/
  create "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.  
  assign
      chExcelApplication:interactive     = false
      chExcelApplication:ScreenUpdating  = false
      chExcelApplication:visible         = false
      chExcelApplication:DisplayAlerts   = false
  .

  chExcelApplication:WorkBooks:Add().
  chWorkbook = chExcelApplication:WorkBooks:Item(1).


  chWorksheet = chWorkbook:ActiveSheet.
  /* меняем формат ячеек на текстовый */
  chWorkSheet:Columns("A:J"):Select.
  chExcelApplication:Selection:NumberFormat = "@".


  assign
    v-i = v-i + 1
    chWorkSheet:range("A" + string(v-i)):value = "Артикул":U
    chWorkSheet:range("B" + string(v-i)):value = "Наименование":u /*string(buf_contract-specif.gds-name  )*/
    chWorkSheet:range("C" + string(v-i)):value = "Цена поставщика":u /*string(buf_contract-specif.price-cli / buf_contract-specif.cli-base-rate , ">>>>>>>>>>>>9.99" )*/
    chWorkSheet:range("D" + string(v-i)):value = "% отклонения":u /*string(buf_contract-specif.prc       )*/
    chWorkSheet:range("E" + string(v-i)):value = "НДС":u /*if buf_contract-specif.VAT-pc = ? then "?" else string(buf_contract-specif.VAT-pc )*/
    chWorkSheet:range("F" + string(v-i)):value = "Тип НДС":u /*string(buf_contract-specif.VAT-type  )*/
    chWorkSheet:range("G" + string(v-i)):value = "Бонус":u /*string(v-bonus                       )*/
    chWorkSheet:range("H" + string(v-i)):value = "Тип производителя":u /*string(buf_contract-specif.prod-type )*/
    chWorkSheet:range("I" + string(v-i)):value = "Код производител ":u /*string(buf_contract-specif.prod-code )*/
    chWorkSheet:range("J" + string(v-i)):value = "Внешний Артикул":u
  .

  chWorkSheet:Rows(substitute("&1:&1", v-i)):Select.
  chExcelApplication:Selection:Font:Bold = True.

  for each buf_contract-specif no-lock
    where buf_contract-specif.gds-code    = p-gds-code

  :
    find first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code .
    v-ext = get-ext-artic ( recid(buf_contract-specif) ) .
    run read-bonus in this-procedure ( input buf_contract-specif.contract-num
                                     , input buf_contract-specif.host-code
                                     , input buf_contract-specif.gds-code
                                     , output v-bonus
                                     ) .
    assign
      v-i = v-i + 1
      chWorkSheet:range("A" + string(v-i)):value = string(buf_contract-specif.artic )
      chWorkSheet:range("B" + string(v-i)):value = string(buf_goods.gds-name  )
      chWorkSheet:range("C" + string(v-i)):value = string(buf_contract-specif.price-cli / buf_contract-specif.cli-base-rate , ">>>>>>>>>>>>9.99" )
      chWorkSheet:range("D" + string(v-i)):value = string(buf_contract-specif.prc )
      chWorkSheet:range("E" + string(v-i)):value = if buf_contract-specif.VAT-pc = ? then "?" else string(buf_contract-specif.VAT-pc )
      chWorkSheet:range("F" + string(v-i)):value = string(buf_contract-specif.VAT-type  )
      chWorkSheet:range("G" + string(v-i)):value = string(v-bonus                       )
      chWorkSheet:range("H" + string(v-i)):value = string(buf_contract-specif.prod-type )
      chWorkSheet:range("I" + string(v-i)):value = string(buf_contract-specif.prod-code )
      chWorkSheet:range("J" + string(v-i)):value = v-ext
    .

  end.

  chWorkSheet:Columns("C:E"):Select.
  chExcelApplication:Selection:HorizontalAlignment = -4152.
  chWorkSheet:Columns("G:G"):Select.
  chExcelApplication:Selection:HorizontalAlignment = -4152.
  chWorkSheet:Columns("J:J"):Select.
  chExcelApplication:Selection:HorizontalAlignment = -4152.


  /* автоподбор ширины колонок */
  chWorkSheet:Columns("A:J"):Select.
  chExcelApplication:Selection:Columns:AutoFit.

  /* Сохраняем */
  chWorkbook:SaveAs(v-filename , -4143 , "" , "", false, false , 1).
  /* Закрываем книгу */
  chWorkbook:Close().
  /* Освобождаем ресурсы */
  release object chWorksheet no-error.
  release object chWorkbook  no-error.
  chExcelApplication :quit().
  release object chExcelApplication no-error.
  run waitfram-hide.
  { gbl/stopwork.i }
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-export-text Dialog-Frame
PROCEDURE proc-export-text :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_contract for ub.contract  .

  define variable v-bonus as decimal   no-undo .
  define variable v-ext as character no-undo .

  assign
    f-name = string(p-doc-num) + ".spc"
    g-log = yes
  .
  system-dialog get-file f-name filters "Спецификации к договорам *.spc" "*.spc"
                         use-filename   SAVE-AS   ASK-OVERWRITE   update g-log   default-extension "spc".
  if not g-log then return .
  run waitfram-show("Ждите...").
  output to value (f-name).
  for each  contract-specif exclusive-lock where contract-specif.gds-code = p-gds-code :
      find first buf_contract no-lock  where
                  buf_contract.host-code =  contract-specif.host-code and
                  buf_contract.contract-code =  contract-specif.contract-num
                  no-error .

    run read-bonus in this-procedure ( input contract-specif.contract-num
                                     , input contract-specif.host-code
                                     , input contract-specif.gds-code
                                     , output v-bonus
                                     ).
    { gbl/gdsbcode.i contract-specif.gds-code ? b-code }
    v-ext = get-ext-artic ( recid(contract-specif) ) .
    find first prod-bc no-lock where prod-bc.b-code = b-code no-error .
    if available prod-bc then  EXPORT prod-bc.b-str  contract-specif.price-cli contract-specif.prc contract-specif.qnty contract-specif.cli-base-rate contract-specif.VAT-type contract-specif.VAT-pc v-bonus v-ext.
    else                       EXPORT string(b-code) contract-specif.price-cli contract-specif.prc contract-specif.qnty contract-specif.cli-base-rate contract-specif.VAT-type contract-specif.VAT-pc v-bonus v-ext.
  end.
  output close.
  run waitfram-hide.
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
  assign p-code = replace(p-code, {&single-quote}, {&single-quote} + {&single-quote}) .
  case RADIO-find :
    when 1 then do:
      define variable  p-value       as integer   no-undo .
      define variable p-data-valid  as logical   no-undo .
      define variable p-message     as character no-undo .
      run integerm ( p-code, false, false, output p-value, output p-data-valid, output p-message) .
      if p-data-valid then run OpenBr in this-procedure (input false, input p-next, input substitute('and buf_contract-specif.gds-code = &1 ', p-code)).
    end.
    when 2 then run OpenBr in this-procedure (input false, input p-next, input substitute('and buf_contract-specif.artic = "&1" ', p-code)).
    when 3 then run OpenBr in this-procedure (input false, input p-next, input substitute('and buf_contract-specif.gds-name begins "&1" ', p-code)).
    when 4 then do:
      assign p-code = lc (p-code) + "*" .
        run OpenBr in this-procedure (input false, input p-next, input substitute('and buf_contract-specif.gds-name contains "&1" ', p-code)).
    end.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Proc-find-code-n Dialog-Frame
PROCEDURE Proc-find-code-n :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes: Процедура которая должна заменить
         чистый Proc-find-code, со своим поиском и
         REPOSITION
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER iRadio AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER cSch   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER lFirst AS LOGICAL   NO-UNDO.
/* */
DEFINE VARIABLE lFound AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE iTmp   AS INTEGER NO-UNDO INITIAL 0.

CASE iRadio:
     WHEN 1 THEN DO:
          ASSIGN
             iTmp = INTEGER(cSch)
             NO-ERROR.
          IF ERROR-STATUS:ERROR THEN DO:
             MESSAGE
                 "Неверно задан код поставщика !"
                 VIEW-AS ALERT-BOX INFO BUTTONS OK.
             RETURN.
          END.
     END.
     WHEN 2 THEN DO:
          ASSIGN
             iTmp = INTEGER(cSch)
             NO-ERROR.
          IF ERROR-STATUS:ERROR THEN DO:
             MESSAGE
                 "Неверно задан номер фирмы !"
                 VIEW-AS ALERT-BOX INFO BUTTONS OK.
             RETURN.
          END.
     END.
END CASE.
/*  */
IF lFirst  THEN DO:
   GET FIRST {&BROWSE-NAME} NO-LOCK.
   GET PREV  {&BROWSE-NAME} NO-LOCK.
END.

GET NEXT {&BROWSE-NAME} NO-LOCK.

/*  */
Label-repeat:
REPEAT:
   /* */
   IF QUERY-OFF-END("{&BROWSE-NAME}") THEN DO:
      LEAVE LABEL-repeat.
   END.
   /*  */
   CASE iRadio:
        WHEN 1 THEN DO:
             IF buf_Contract.Cli-code = iTmp THEN DO:
                ASSIGN lFound = TRUE.
                LEAVE Label-repeat.
             END.
        END.
        WHEN 2 THEN DO:
             IF buf_Contract.Host-code = iTmp THEN DO:
                ASSIGN lFound = TRUE.
                LEAVE Label-repeat.
             END.
        END.
        WHEN 3 THEN DO:
             IF buf_Contract.Cli-name BEGINS cSch THEN DO:
                ASSIGN lFound = TRUE.
                LEAVE Label-repeat.
             END.
        END.
   END CASE.
   /*  */
   GET NEXT {&BROWSE-NAME} NO-LOCK.
END.
/* */
IF lFound THEN  DO:
   REPOSITION {&BROWSE-NAME}
      TO ROWID
      ROWID(buf_Contract-specif),
      ROWID(buf_Contract),
      ROWID(temp-trn-doc)
      NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      /* Ничего не делаем !!!  */
   END.
END.
/* */
RETURN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print Dialog-Frame
PROCEDURE proc-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  { gbl/working.i }

define variable Line as character no-undo .
assign
  Line = fill("-", 299)
   .
define variable sym1  as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym2  as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym3  as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym4  as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym5  as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym6  as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym7  as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym8  as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym9  as character no-undo format "x(1)":u initial ":":u column-label ":!:".

define variable b-code as character no-undo .
define variable b-prod as character no-undo .
define variable b-name as character no-undo .
define variable b-bonus as character no-undo .
define variable b-ext as character no-undo .

  DEFINE frame f-doc
    sym1 b-code       COLUMN-LABEL "Номер договора"  Format "X(12)"                          space(0)
    sym2 b-name       COLUMN-LABEL "Код Поставщика"  format "x(13)"                          space(0)
    sym6 b-prod       COLUMN-LABEL "Поставщик"  Format "x(40)"                          space(0)
    sym9 b-ext        COLUMN-LABEL "Внешний Артикул" Format "X(12)"                          space(0)
    sym3 {&cop-l5}    COLUMN-LABEL {&col-l5}  format ">>>,>>>,>>9.99"                 space(0)
    sym4 {&cop-l6}    COLUMN-LABEL {&col-l6}  Format "->>>9.99"                       space(0)
    sym7 b-bonus      COLUMN-LABEL {&col-l14}                                         space(0)
    sym8
  HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(90)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>9") ) AT 105 format "X(15)" SKIP
        Line format "X(129)" AT 1
  with width {&A4_CW0} down stream-io.

  run prn-lib-open-stream  in this-procedure (input parParentProc,input {&CS_PS},input yes,input no).

  FORM HEADER
      Line format "X(129)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME BottomFrame .

  FORM with FRAME f-doc .

  PUT stream PrnLibStream  SPACE(30) string("Товарные спецификации товара "   + string(  buf_goods.gds-code) + " " + buf_goods.gds-name ) format "X(160)"  SKIP .

  FOR EACH buf_contract-specif NO-LOCK where buf_contract-specif.gds-code = p-gds-code :
      find first buf_contract no-lock  where
                 buf_contract.host-code =  buf_contract-specif.host-code and
                 buf_contract.contract-code =  buf_contract-specif.contract-num
                 no-error .

    assign
      b-code = string(buf_contract.contract-code)
      b-name = buf_contract.cli-type + string(cli-code)
      b-ext  = get-ext-artic ( recid(buf_contract-specif))
      b-prod = buf_contract.cli-name
      .

    run read-bonus (
        input buf_contract-specif.contract-num ,
        input buf_contract-specif.host-code    ,
        input buf_contract-specif.gds-code     ,
        output b-bonus
        ) .

    display stream PrnLibStream  sym1    b-code
                              sym9   b-ext
                              sym2   b-name
                              sym3    {&cop-l5}
                              sym4    {&cop-l6}
                              sym6    b-prod
                              sym7    b-bonus
                              sym8
    with frame f-doc.
    down stream PrnLibStream with frame f-doc .
  end.
  PUT STREAM PrnLibStream Line format "X(129)".

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input parParentProc,input 0).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION close-contract Dialog-Frame
FUNCTION close-contract RETURNS date
  ( input p-recid as recid ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable ret    as date no-undo .
  define buffer bf_contract-specif for ub.contract-specif  .
  define buffer bf_contract        for ub.contract  .

  assign ret = ? .
  find first bf_contract-specif no-lock  where recid(bf_contract-specif)  =  p-recid no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
          .
        end.
  find first bf_contract no-lock  where
             bf_contract.host-code =  bf_contract-specif.host-code and
             bf_contract.contract-code =  bf_contract-specif.contract-num
             no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  ""
                  view-as alert-box error
                .
              end.

    if error-status :error then do:
    ret = ?  .
   end.
   else do:
    assign
      ret = bf_contract.contract-date-end
      .

   end.

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-bonus Dialog-Frame
FUNCTION f-bonus RETURNS DECIMAL
  ( input par-recid as recid ) :
  define buffer buf_contract-specif for ub.contract-specif  .
  define variable v-bonus as decimal   no-undo .
  find first buf_contract-specif no-lock where recid(buf_contract-specif) = par-recid no-error .
  if error-status :error then return 0.0 .
  v-bonus = 0.0 .
  run read-bonus
  ( buf_contract-specif.contract-num,
    buf_contract-specif.host-code ,
    buf_contract-specif.gds-code ,
    output v-bonus
  ) no-error .
  return v-bonus .   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-b-code Dialog-Frame
FUNCTION get-b-code RETURNS CHARACTER
  ( input gds-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable ret    as character no-undo .
  define variable b-code as integer   no-undo .

  assign ret = "" .

  { gbl/gdsbcode.i  gds-code  ?  b-code  no-error }
  if error-status :error then do:
  end.
  else assign ret = string(b-code) .

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-ext-artic Dialog-Frame
FUNCTION get-ext-artic RETURNS CHARACTER
  ( input p-recid as recid ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable ret    as character no-undo .
  define buffer bf_contract-specif for ub.contract-specif  .
  define buffer bf_contract        for ub.contract  .
  define buffer bf_ext-artic        for ub.ext-artic  .

  define buffer bf_goods for ub.goods  .

  assign ret = "" .
  find first bf_contract-specif no-lock  where recid(bf_contract-specif)  =  p-recid no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
          .
        end.
  find first bf_contract no-lock  where
             bf_contract.host-code =  bf_contract-specif.host-code and
             bf_contract.contract-code =  bf_contract-specif.contract-num
             no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  ""
                  view-as alert-box error
                .
              end.

   find first bf_ext-artic where bf_ext-artic.cli-type   = bf_contract.cli-type
                             and bf_ext-artic.cli-code   = bf_contract.cli-code
                             and bf_ext-artic.gds-code   = bf_contract-specif.gds-code
                             and bf_ext-artic.status_    <> {&deleted-status}
                             no-error .
    if error-status :error then do:
    ret = ''  .
    end.
   else do:
    assign
      ret = bf_ext-artic.ext-artic
      .
      if ret = ? then ret = "".
   end.

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  ( input p-gds-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable ret    as character no-undo .
  define buffer bf_goods for ub.goods  .

  assign ret = "" .
  find first bf_goods no-lock where bf_goods.gds-code = p-gds-code no-error  .
  if error-status :error then do:
  end.
  else assign ret = bf_goods.gds-name  .

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION status-contract Dialog-Frame
FUNCTION status-contract RETURNS CHARACTER
  ( input p-recid as recid ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable ret    as character no-undo .
  define buffer bf_contract-specif for ub.contract-specif  .
  define buffer bf_contract        for ub.contract  .

  assign ret = "" .
  find first bf_contract-specif no-lock  where recid(bf_contract-specif)  =  p-recid no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
          .
        end.
  find first bf_contract no-lock  where
             bf_contract.host-code =  bf_contract-specif.host-code and
             bf_contract.contract-code =  bf_contract-specif.contract-num
             no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  ""
                  view-as alert-box error
                .
              end.

    if error-status :error then do:
    ret = ''  .
   end.
   else do:
    assign
      ret = bf_contract.status_
      .
      if ret = ? then ret = "".
   end.

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-ass Dialog-Frame
PROCEDURE proc-add-ass :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bb_contract-specif for ub.contract-specif  .
define variable v-ass-m as logical   no-undo init false .
define variable v-log as logical   no-undo .
define variable p-rid-list as character no-undo .


if not can-find( first temp-conn) then do:
    message "Не выделено ни одного товара !" view-as alert-box .
    return .
end.

if v-cntxt-db-num <> 0 then do :
   if can-find ( first assortment-matrix no-lock where  assortment-matrix.asmt-status = integer ({&current-status-int}) and
                                                        assortment-matrix.db-num = v-cntxt-db-num )  then v-ass-m = true  .
end.
else do:
   if can-find ( first assortment-matrix no-lock where  assortment-matrix.asmt-status = integer ({&current-status-int}))  then v-ass-m = true  .
end.

if v-ass-m = false  then return .

/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_add-def':U
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
 if not v-log then return  .


  message "Добавлять Выбранные товары спецификации в Ассортиментные матрицы ?"
          "Если ДА , укажите в какие."
          view-as alert-box question
                  buttons yes-no
                  update v-okk as logical
                  .
  if not v-okk then return .
      run ref/assmatr.w (
            input parParentProc
          ,input "b-sel,b-mark"
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input ?
          ,input ?
          ,input-output p-rid-list
      ) no-error  .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .

    run waitfram-show ("Добавление в Ассортиментные матрицы")  .
    v-err-ext = false  .
    v-longchar = "" .
    for each temp-conn,
        first bb_contract-specif no-lock  where
        recid(bb_contract-specif) = temp-conn.ri :
        run add-assmatr in this-procedure (input bb_contract-specif.gds-code ,input p-rid-list) .
    end.
    run waitfram-hide .
    if v-err-ext = true  then do:
    define variable v-ok as logical   no-undo .
    run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
          + 'title=При добавлении в Ассортиментные матрицы\':u
          + 'Editor_col=1\':u
          + 'Editor_width=96\':u
          + 'Editor_height=21\':u
          + 'readonly=yes\':u
        ,input-output v-longchar
        ,output v-ok ) no-error .
        v-longchar = "" .
        { ref/clearlm.i }

    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-prc-min Dialog-Frame
FUNCTION f-prc-min RETURNS DECIMAL
  ( input par-recid as recid ) :
  define buffer buf_contract-specif for ub.contract-specif  .
  define variable v-prc-min as decimal   no-undo .
  find first buf_contract-specif no-lock where
           recid(buf_contract-specif) = par-recid no-error .
  if error-status :error then return 0.0 .
  v-prc-min = 0.0 .
  run read-prc-min in this-procedure
  ( buf_contract-specif.contract-num,
    buf_contract-specif.host-code ,
    buf_contract-specif.gds-code ,
    output v-prc-min
  ) no-error .
  return v-prc-min .   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME