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

Товарная спецификация к договору

Автор: Чернова Светлана Александровна
Дата создания: 03/20/09
Author: Svetlana Chernova
Creation date: 09/14/05


*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter bttns          as char      no-undo . /* список доступных кнопок */
define input  parameter ref-mode       as character no-undo .   /* {&add-def}, {&update}, {&lookup}, "history" */
define input  parameter p-host-code    as integer   no-undo . /* надо передавать фирму */
define input  parameter p-doc-num      as integer   no-undo .
define output parameter rid-list       as char      no-undo . /* список recid'ов выбранных записей */
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Товарная спецификация к договору" .
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
{ str/contrcth.i }
{ str/libbcrcn.i }   /* Библиотека поиска по бар коду !!! */
{ str/sclspref.i }   /* Снять префиксы и форматы бар кодов, (нужно для инклудника str/bc-rcnz.i) */
{ gbl/assmatat.i }   /* Библиотека для работы с атрибутами АМ */
{ gbl/thbj-def.i }
{ ref/ass-mat.i &DEF_PROC=YES}    /* Процедуры и функции для работы с АМ (по задаче "Процент отклонения матрицы от шаблона") */

define buffer buf_contract-specif  for ub.contract-specif .
define buffer buf_contract         for ub.contract .
define buffer buf_ext-artic        for ub.ext-artic  .
define buffer buf_goods            for ub.goods.
define buffer buf_contract-attr    for ub.contract-attr .


define variable v-doc-rec        as recid     no-undo .
DEFINE VARIABLE v-doc-rec-tmp    as RECID     NO-UNDO .
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
define variable old-prc-min      as decimal   no-undo .
define variable v-contr-type     as character no-undo .
define variable filter-point     as character no-undo init "Товарная спецификация к договору" .
define variable filter-point0    as character no-undo init "Товарная спецификация к договору" .
define variable p-ask           as logical   no-undo .
define variable v-ask           as logical   no-undo .
define variable v-list-mat      as character no-undo .
define variable head-col        as character no-undo .
define variable v-order-column  as character no-undo .
define variable v-spis-size     as character no-undo .
define variable v-spis-vis      as character no-undo .
define variable hcolumn         as handle extent 100  no-undo.
define variable v-retro-bonus   as character no-undo .
define variable old-retro-bonus as character no-undo .
define variable v-change-fields as character no-undo .

v-err-ext = false  .
v-longchar = "".
{ ref/clearlm.i }


/* Запускаем инклудник переопределения Host-code и Contract code
  для подчиненных договоров  */
{
str/cont-spec-slave.i
&P_HOST_CODE = p-Host-Code
&P_CONTRACT_CODE = p-Doc-Num
}

define new shared buffer temp-trn-doc for gds-list-flt  .
define variable r-2 as integer   no-undo init 1 .
define variable v-mark-seq as integer no-undo.
define variable p-bcode as character no-undo .
define variable p-prod as character no-undo .
define variable p-grp as character no-undo .
define variable p-bonus as decimal   no-undo .
define variable v-cli-base-rate-ord as decimal   no-undo .
define variable v-unit-cli-ord as character no-undo .
define variable v-cli-base-rate-rcv as decimal   no-undo .
define variable v-unit-cli-rcv as character no-undo .

create gds-list-flt.
gds-list-flt.gds-code = 0 .
release gds-list-flt .

define temp-table temp-conn no-undo
field ri  as  recid
field mark-seq as integer
index pi  is primary   ri
.

define temp-table tt-contract-specif no-undo
field artic     like ub.contract-specif.artic
field prod-type like ub.contract-specif.prod-type
field prod-code like ub.contract-specif.prod-code
field gds-name  like ub.goods.gds-name
field price-cli like ub.contract-specif.price-cli
field prc       like ub.contract-specif.prc
field vat-pc    like ub.contract-specif.vat-pc
field vat-type  like ub.contract-specif.vat-type
field bonus     as decimal
field line-num  as integer
field have-prod as logical
index pi is primary unique
artic
prod-type
prod-code
.

define stream slog.
define stream stream-err.

&scop col-l0  '*'
&scop col-l1  'Код'
&scop col-l2  'Артикул'
&scop col-l3  'Произво-!дитель'
&scop col-l4  'Наименование'
&scop col-l5  'Цена!поставщика'
&scop col-l6  '% Отклон в!большую сторону'
&scop col-l7  '% Отклон в!меньшую сторону'
&scop col-l8  'Ед.!изм'
&scop col-l9  'Количество'
&scop col-l10  'Коэф.'
&scop col-l11 'Сумма'
&scop col-l12 'НДС'
&scop col-l13 'тип!НДС'
&scop col-l14 'Принято'
&scop col-l15 'Группа товара'
&scop col-l16  'Ед.!изм!пост'
&scop col-l17  'Ед.изм!пост в!заказе'
&scop col-l18  'Коэф.!в!заказе'
&scop col-l19  'Ед.изм!пост в!поставке'
&scop col-l20  'Коэф.!в!поставке'
&scop col-l21  '%!Бонус'
&scop col-l22 'Внешний!Артикул'

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
  {&col-l16}    + '#' +
  {&col-l17}    + '#' +
  {&col-l18}    + '#' +
  {&col-l19}    + '#' +
  {&col-l20}    + '#' +
  {&col-l21}    + '#' +
  {&col-l22}
  .



&scop cop-l0  mark-string(recid(buf_contract-specif))
&scop cop-l1  get-b-code(buf_contract-specif.gds-code)
&scop dyn_cop-l1 substitute('dynamic-function(&1get-b-code&1, &2)', ~{&double-quote~}, buf_contract-specif.gds-code)
&scop cop-l2  buf_contract-specif.artic
&scop cop-l3  string (buf_contract-specif.prod-type + ' ' + string(buf_contract-specif.prod-code))
&scop cop-l4  buf_contract-specif.gds-name
&scop cop-l5  buf_contract-specif.price-cli
&scop cop-l6  buf_contract-specif.prc
&scop cop-l7  f-prc-min(recid(buf_contract-specif))
&scop dyn_cop-l7 substitute('dynamic-function(&1f-prc-min&1, recid(buf_contract-specif))', ~{&double-quote~} )
&scop cop-l8  buf_contract-specif.unit-base
&scop cop-l9  buf_contract-specif.qnty
&scop cop-l10  buf_contract-specif.cli-base-rate
&scop cop-l11 buf_contract-specif.sum-cli
&scop cop-l12 buf_contract-specif.vat-pc
&scop cop-l13 buf_contract-specif.vat-type
&scop cop-l14 buf_contract-specif.income-qnty
&scop cop-l15  get-grp(buf_contract-specif.gds-code)
&scop dyn_cop-l15 substitute('dynamic-function(&1get-grp&1, &2)', ~{&double-quote~}, buf_contract-specif.gds-code)
&scop cop-l16  buf_contract-specif.unit-cli
&scop cop-l17  buf_contract-specif.unit-cli-ord
&scop cop-l18  buf_contract-specif.cli-base-rate-ord
&scop cop-l19  buf_contract-specif.unit-cli-rcv
&scop cop-l20  buf_contract-specif.cli-base-rate-rcv
&scop cop-l21  f-bonus(recid(buf_contract-specif))
&scop dyn_cop-l21 substitute('dynamic-function(&1f-bonus&1, &2)', ~{&double-quote~}, recid(buf_contract-specif))
&scop cop-l22  get-ext-artic(recid(buf_contract-specif))
&scop dyn_cop-l22 substitute('dynamic-function(&1get-ext-artic&1, recid(buf_contract-specif))', ~{&double-quote~} )

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
&Scoped-define INTERNAL-TABLES buf_contract-specif temp-trn-doc

/* Definitions for BROWSE spec-List                                     */
&Scoped-define FIELDS-IN-QUERY-spec-List {&cop-l0} {&cop-l1} @ p-bcode {&cop-l2} {&cop-l3} @ p-prod {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10} {&cop-l11} {&cop-l12} {&cop-l13} {&cop-l14} {&cop-l15} @ p-grp {&cop-l16} {&cop-l17} {&cop-l18} {&cop-l19} {&cop-l20} {&cop-l21} {&cop-l22}
&Scoped-define ENABLED-FIELDS-IN-QUERY-spec-List {&cop-l2}
&Scoped-define SELF-NAME spec-List
&Scoped-define QUERY-STRING-spec-List FOR EACH buf_contract-specif NO-LOCK, ~
       first temp-trn-doc where (r-2 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code ) indexed-reposition
&Scoped-define OPEN-QUERY-spec-List OPEN QUERY {&SELF-NAME} FOR EACH buf_contract-specif NO-LOCK, ~
       first temp-trn-doc where (r-2 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code ) indexed-reposition.
&Scoped-define TABLES-IN-QUERY-spec-List buf_contract-specif temp-trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-spec-List buf_contract-specif
&Scoped-define SECOND-TABLE-IN-QUERY-spec-List temp-trn-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-add b-chg B-del b-exp ~
b-imp b-filter-ext b-uf b-sch1 B-print b-hist B-Help B-allmark ~
B-unmark B-add-AssMatr b-func B-del-AssMatr ~
b-all-2 RADIO-find ~
sch-str spec-List mark-num all-qnty all-sum
&Scoped-Define DISPLAYED-OBJECTS  ~
RADIO-find sch-str mark-num all-qnty all-sum

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-bonus Dialog-Frame
FUNCTION f-bonus RETURNS DECIMAL
  ( input par-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-prc-min Dialog-Frame
FUNCTION f-prc-min RETURNS DECIMAL
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-grp Dialog-Frame
FUNCTION get-grp RETURNS CHARACTER
  ( input gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-export
       MENU-ITEM m-export-text  LABEL "Текст":U
       MENU-ITEM m-export-excel LABEL "Excel":U         .

DEFINE MENU m-func
       MENU-ITEM m-func-all-values LABEL "Установить значения всем товарам спецификации":U
       MENU-ITEM m-func-vat-all LABEL "Проставить НДС у всей спецификации из карточки товара":U         .

DEFINE MENU m-import
       MENU-ITEM m-import-text  LABEL "Текст":U
       MENU-ITEM m-import-excel LABEL "Excel":U         .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-add-AssMatr
     LABEL "Доб. в &АМ"
     SIZE 10 BY 1 TOOLTIP "Добавить в Ассортиментные матрицы выделенный товар".

DEFINE BUTTON B-allmark
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Отметить все".

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del-AssMatr
     LABEL "Уд. из &АМ"
     SIZE 10 BY 1 TOOLTIP "Удалить из Ассортиментных матриц выбранные товары".

DEFINE BUTTON b-exp
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON b-filter-ext
     IMAGE-UP FILE "cmp/b-schef.bmp":U
     LABEL "Расширенный фильтр"
     SIZE 3 BY 1 TOOLTIP "Расширенный фильтр".

DEFINE BUTTON b-func
     LABEL "&Функции"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-imp
     LABEL "&Импорт"
     SIZE 10 BY 1.

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

DEFINE BUTTON b-sch1
     LABEL "&Фильтр"
     SIZE 3 BY 1.

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

DEFINE VARIABLE all-qnty AS DECIMAL FORMAT ">>>,>>>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Всего кол-во"
      VIEW-AS TEXT
     SIZE 20 BY .79
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE all-sum AS DECIMAL FORMAT ">>>,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Всего сумма"
      VIEW-AS TEXT
     SIZE 22 BY .79
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 5.5 BY 1 NO-UNDO.

DEFINE VARIABLE sch-str AS CHARACTER FORMAT "X(256)"
     VIEW-AS FILL-IN
     SIZE 44.38 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RADIO-find AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "коду", 1,
"артикулу", 2,
"названию", 3,
"началу слова", 4
     SIZE 44 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY spec-List FOR
      buf_contract-specif,
      temp-trn-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE spec-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS spec-List Dialog-Frame _FREEFORM
  QUERY spec-List DISPLAY
      {&cop-l0}    COLUMN-LABEL {&col-l0}  Format "X(1)"
     {&cop-l1} @ p-bcode  COLUMN-LABEL {&col-l1}  Format "X(16)"
     {&cop-l2}    COLUMN-LABEL {&col-l2}  Format "x(16)"
     {&cop-l3} @ p-prod  COLUMN-LABEL {&col-l3}  Format "x(18)"
     {&cop-l4}    COLUMN-LABEL {&col-l4}  format "x(112)"
     {&cop-l5}    COLUMN-LABEL {&col-l5}  format ">,>>>,>>>,>>9.99"
     {&cop-l6}    COLUMN-LABEL {&col-l6}  Format "->>>>9.99"
     {&cop-l7}    COLUMN-LABEL {&col-l7}  Format "->>>>9.99"
     {&cop-l8}    COLUMN-LABEL {&col-l8}
     {&cop-l9}    COLUMN-LABEL {&col-l9}
     {&cop-l10}    COLUMN-LABEL {&col-l0}
     {&cop-l11}   COLUMN-LABEL {&col-l11}
     {&cop-l12}   COLUMN-LABEL {&col-l12} Format ">>9.9"
     {&cop-l13}   COLUMN-LABEL {&col-l13}
     {&cop-l14}   COLUMN-LABEL {&col-l14}
     {&cop-l15} @ p-grp COLUMN-LABEL {&col-l15}  Format "x(100)"
     {&cop-l16}   COLUMN-LABEL {&col-l16}
     {&cop-l17}   COLUMN-LABEL {&col-l17}
     {&cop-l18}   COLUMN-LABEL {&col-l18}
     {&cop-l19}   COLUMN-LABEL {&col-l19}
     {&cop-l20}   COLUMN-LABEL {&col-l20}
     {&cop-l21}   COLUMN-LABEL {&col-l21} Format "->>9.99"
     {&cop-l22}   COLUMN-LABEL {&col-l22} Format "X(16)"

     enable {&cop-l2}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 17.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 20
     B-add AT ROW 1 COL 30
     b-chg AT ROW 1 COL 40
     B-del AT ROW 1 COL 50
     b-exp AT ROW 1 COL 60
     b-imp AT ROW 1 COL 70
     b-filter-ext AT ROW 1 COL 80 WIDGET-ID 14
     b-uf AT ROW 1 COL 83 WIDGET-ID 12
     b-sch1 AT ROW 1 COL 88.75
     B-print AT ROW 1 COL 91.88
     b-hist AT ROW 1 COL 94.88
     B-Help AT ROW 1 COL 97.88
     B-allmark AT ROW 2 COL 11
     B-unmark AT ROW 2 COL 14.13
     B-add-AssMatr AT ROW 2 COL 20 WIDGET-ID 2
     B-del-AssMatr AT ROW 2 COL 30 WIDGET-ID 4
     b-func AT ROW 2 COL 40 WIDGET-ID 26
     RADIO-find AT ROW 3.38 COL 12 NO-LABEL
     sch-str AT ROW 3.38 COL 54.5 COLON-ALIGNED NO-LABEL
     spec-List AT ROW 4.55 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     all-qnty AT ROW 21.9 COL 13 COLON-ALIGNED
     all-sum AT ROW 21.9 COL 48.5 COLON-ALIGNED
     "Поиск по" VIEW-AS TEXT
          SIZE 9 BY 1 AT ROW 3.38 COL 1
          FGCOLOR 4
     SPACE(91.37) SKIP(18.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товарная спецификация к договору"
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
   FRAME-NAME                                                           */
/* BROWSE-TAB spec-List sch-str Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-exp:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-export:HANDLE.

ASSIGN
       b-func:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-func:HANDLE.

ASSIGN
       b-imp:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-import:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE spec-List
/* Query rebuild information for BROWSE spec-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_contract-specif NO-LOCK,
first temp-trn-doc where (r-2 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code )
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


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
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

  run proc-add in this-procedure .
  run proc-sum in this-procedure .
  run openbr in this-procedure ( input yes, input no, input '':u).
  /* Позиционируем на добавленную запись  */
  if v-doc-rec-tmp <> ? THEN DO:
     REPOSITION spec-List to RECID v-doc-rec-tmp NO-ERROR.
     ASSIGN
        v-doc-rec-tmp = ?.
  END.
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
  run proc-add-Ass in this-procedure .
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
/*      v-mark-seq = v-mark-seq + 1 */
/*    temp-conn.mark-seq = v-mark-seq */
    .
    GET next spec-List NO-LOCK .
  end.

  if mark-num = 0 then hide    mark-num in frame {&frame-name}.
  else                 display mark-num  with frame {&frame-name}.
  RUN OpenBr in this-procedure ( input yes, input no, input '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
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
  if not g-log then return .

  if not available buf_contract-specif then return no-apply.

  assign g-log = no .
  if mark-num > 0 then do:
    message "Вы действительно хотите изменить все выделенные спецификации?"
    view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
    if g-log = no then return no-apply.
  end.

  /*  */
  IF AVAILABLE buf_contract-specif THEN DO:
     ASSIGN
        v-Doc-rec-tmp = RECID(buf_Contract-Specif)
        .
  END.

  if mark-num > 1 then do: /* выделено много */
    assign
      v-price    = ?
      v-vat-type = ?
      v-qnty     = ?
      v-vat-pc   = ?
      v-cli-base-rate = ?
      v-unit-cli = ?
      v-cli-base-rate-ord = ?
      v-unit-cli-ord = ?
      v-cli-base-rate-rcv = ?
      v-unit-cli-rcv = ?
      v-bonus   = 0
      v-retro-bonus = ""
    .
    run str/contspc1.w
                       ( input parParentProc
                       , input {&update}
                       , input 0 // gds-code для выбора v-unit-cli
                       , input ""
                       , input ""
                       , input "?????? ???????"
                       , input ""
                       , input-output v-price
                       , input-output v-prc
                       , input-output v-prc-2
                       , input-output v-vat-type
                       , input-output v-qnty
                       , input-output v-cli-base-rate
                       , input-output v-vat-pc
                       , input-output v-unit-cli
                       , input-output v-unit-cli-ord
                       , input-output v-cli-base-rate-ord
                       , input-output v-unit-cli-rcv
                       , input-output v-cli-base-rate-rcv
                       , input-output v-bonus
                       , input-output v-retro-bonus
                       , output v-res ) .
    if v-res then do:
      do transaction :
        for each temp-conn :
          find first ub.contract-specif exclusive-lock where recid(ub.contract-specif) = temp-conn.ri .
        if v-cli-base-rate <> ? then do:
            find first buf_goods no-lock where
                     buf_goods.gds-code = contract-specif.gds-code .
            if v-cli-base-rate <> 1 and
                     v-unit-cli = buf_goods.unit-base then do:
              message
              substitute("Товар: &1 &2&3 &4&5" +
                        "Единица измерения совпадает с базовой, а коэффициент <> 1. Изменение по товару не произведено.&5"
                       ,buf_goods.artic
                       ,buf_goods.prod-type
                       ,buf_goods.prod-code
                       ,buf_goods.gds-name
                       ,{&new-line}
                       )
              view-as alert-box error.
              next.
            end.
            if v-cli-base-rate <> buf_goods.cli-base-rate and
                     v-unit-cli = buf_goods.unit-cli then do:
              message
              substitute("Товар: &1 &2&3 &4&5" +
                       "Единица измерения совпадает с ед.изм.поставщика, а коэффициент нет. Изменение по товару не произведено.&5"
                       ,buf_goods.artic
                       ,buf_goods.prod-type
                       ,buf_goods.prod-code
                       ,buf_goods.gds-name
                       ,{&new-line}
                       )
              view-as alert-box error.
              next.
            end.
            assign
              ub.contract-specif.cli-base-rate-rcv = v-cli-base-rate-rcv
              ub.contract-specif.cli-base-rate     = v-cli-base-rate
            .
        end.
        
        assign
          ub.contract-specif.price-cli    = v-price        when (v-price <> ?)
          ub.contract-specif.prc          = v-prc          when (v-prc <> ?)
          ub.contract-specif.vat-type     = v-vat-type     when (v-vat-type <> ?)
          ub.contract-specif.qnty         = v-qnty         when (v-qnty <> ?)
          ub.contract-specif.sum-cli      = ub.contract-specif.price-cli * ub.contract-specif.qnty
          ub.contract-specif.VAT-pc       = v-vat-pc       when (v-vat-pc <> ?)
          ub.contract-specif.unit-cli     = v-unit-cli     when (v-unit-cli <> ?)
          ub.contract-specif.unit-cli-ord = v-unit-cli-ord when (v-unit-cli-ord <> ?)
          ub.contract-specif.unit-cli-rcv = v-unit-cli-rcv when (v-unit-cli-rcv <> ?)
        .

           run write-bonus in this-procedure (
               buf_contract.contract-code  ,
               buf_contract.host-code     ,
               ub.contract-specif.gds-code      ,
               v-bonus ).
           run write-prc-min in this-procedure (
               buf_contract.contract-code  ,
               buf_contract.host-code     ,
               contract-specif.gds-code      ,
               v-prc-2 ).

           run write-retro-bonus in this-procedure (
               buf_contract.contract-code  ,
               buf_contract.host-code     ,
               contract-specif.gds-code      ,
               v-retro-bonus ).

          assign
            is-new = yes
          .
        end.
      end.
      run proc-sum in this-procedure .
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    end.
  end.
  else do:
    if mark-num = 1 then do:
      find first temp-conn .
      find first buf_contract-specif no-lock where recid(buf_contract-specif) = temp-conn.ri .
    end.
    assign
      v-price    = buf_contract-specif.price-cli
      v-prc      = buf_contract-specif.prc
      v-vat-type = buf_contract-specif.vat-type
      v-qnty     = buf_contract-specif.qnty
      v-cli-base-rate = buf_contract-specif.cli-base-rate
      v-vat-pc   = buf_contract-specif.VAT-pc
      v-unit-cli = buf_contract-specif.unit-cli
      v-cli-base-rate-ord = buf_contract-specif.cli-base-rate-ord
      v-unit-cli-ord = buf_contract-specif.unit-cli-ord
      v-cli-base-rate-rcv = buf_contract-specif.cli-base-rate-rcv
      v-unit-cli-rcv = buf_contract-specif.unit-cli-rcv
    .
    run read-bonus  in this-procedure (
        buf_contract.contract-code  ,
        buf_contract.host-code     ,
        buf_contract-specif.gds-code      ,
        output v-bonus ).
    run read-prc-min in this-procedure (
        buf_contract.contract-code  ,
        buf_contract.host-code     ,
        buf_contract-specif.gds-code      ,
        output v-prc-2 ).

    run read-retro-bonus in this-procedure (
        buf_contract.contract-code ,
        buf_contract.host-code     ,
        buf_contract-specif.gds-code   ,
        output v-retro-bonus ) .

 /*   if b-prc then assign v-prc = FILL-prc .
    if b-prc-2 then assign v-prc-2 = FILL-prc-2 .  */
    find first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code .
    run str/contspc1.w
                       ( input parParentProc
                       , input {&update}
                       , input buf_contract-specif.gds-code
                       , input buf_contract-specif.artic
                       , input (buf_contract-specif.prod-type + string(buf_contract-specif.prod-code))
                       , input buf_contract-specif.gds-name
                       , input buf_contract-specif.unit-base
                       , input-output v-price
                       , input-output v-prc
                       , input-output v-prc-2
                       , input-output v-vat-type
                       , input-output v-qnty
                       , input-output v-cli-base-rate
                       , input-output v-vat-pc
                       , input-output  v-unit-cli
                       , input-output v-unit-cli-ord
                       , input-output v-cli-base-rate-ord
                       , input-output v-unit-cli-rcv
                       , input-output v-cli-base-rate-rcv
                       , input-output v-bonus
                       , input-output v-retro-bonus
                       , output v-res ) .

    if v-res then do:
      run read-bonus in this-procedure (
          buf_contract.contract-code  ,
          buf_contract.host-code     ,
          buf_contract-specif.gds-code      ,
          output old-bonus ).
      run read-prc-min in this-procedure (
          buf_contract.contract-code  ,
          buf_contract.host-code     ,
          buf_contract-specif.gds-code      ,
          output old-prc-min ).
      run read-retro-bonus in this-procedure (
          buf_contract.contract-code ,
          buf_contract.host-code     ,
          buf_contract-specif.gds-code   ,
          output old-retro-bonus ) .

      if   v-price <> buf_contract-specif.price-cli
        or v-prc <> buf_contract-specif.prc
        or v-qnty <> buf_contract-specif.qnty
        or v-vat-pc <> buf_contract-specif.vat-pc
        or v-vat-type <> buf_contract-specif.vat-type
        or v-cli-base-rate <> buf_contract-specif.cli-base-rate
        or v-unit-cli <> buf_contract-specif.unit-cli
        or v-cli-base-rate-ord <> buf_contract-specif.cli-base-rate-ord
        or v-unit-cli-ord <> buf_contract-specif.unit-cli-ord
        or v-cli-base-rate-rcv <> buf_contract-specif.cli-base-rate-rcv
        or v-unit-cli-rcv <> buf_contract-specif.unit-cli-rcv
        or v-bonus <> old-bonus
        or v-prc-2 <> old-prc-min
        or v-retro-bonus <> old-retro-bonus
      then do:
        do transaction :
          find first ub.contract-specif exclusive-lock where recid (ub.contract-specif) = recid(buf_contract-specif) .
          if v-cli-base-rate <> ? then do:
            find first buf_goods no-lock where buf_goods.gds-code = contract-specif.gds-code .
            if v-cli-base-rate <> 1 and
                     v-unit-cli = buf_goods.unit-base then do:
              message
              substitute("Товар: &1 &2&3 &4&5" +
                        "Единица измерения совпадает с базовой, а коэффициент <> 1. Изменение по товару не произведено.&5"
                       ,buf_goods.artic
                       ,buf_goods.prod-type
                       ,buf_goods.prod-code
                       ,buf_goods.gds-name
                       ,{&new-line}
                       )
              view-as alert-box error.
              undo, return no-apply.
            end.
            if v-cli-base-rate <> buf_goods.cli-base-rate and
                     v-unit-cli = buf_goods.unit-cli then do:
              message
              substitute("Товар: &1 &2&3 &4&5" +
                       "Единица измерения совпадает с ед.изм.поставщика, а коэффициент нет. Изменение по товару не произведено.&5"
                       ,buf_goods.artic
                       ,buf_goods.prod-type
                       ,buf_goods.prod-code
                       ,buf_goods.gds-name
                       ,{&new-line}
                       )
              view-as alert-box error.
              undo, return no-apply.
            end.
            assign
              ub.contract-specif.cli-base-rate-rcv = v-cli-base-rate-rcv
              ub.contract-specif.cli-base-rate     = v-cli-base-rate
            .
          end.


          assign
            ub.contract-specif.price-cli    = v-price
            ub.contract-specif.prc          = v-prc
            ub.contract-specif.vat-type     = v-vat-type
            ub.contract-specif.qnty         = v-qnty
            ub.contract-specif.sum-cli      = v-price * v-qnty
            ub.contract-specif.VAT-pc       = v-vat-pc
            ub.contract-specif.unit-cli     = v-unit-cli
            ub.contract-specif.unit-cli-ord = v-unit-cli-ord
            ub.contract-specif.unit-cli-rcv = v-unit-cli-rcv
            is-new = yes
          .
           run write-bonus in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               ub.contract-specif.gds-code      ,
               v-bonus ).
           run write-prc-min in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               contract-specif.gds-code      ,
               v-prc-2 ).

           run write-retro-bonus in this-procedure (
               buf_contract.contract-code  ,
               buf_contract.host-code     ,
               contract-specif.gds-code      ,
               v-retro-bonus ).

        end.
      end.
      run proc-sum in this-procedure .
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    end.
  end.
  /* Позиционируем на исходную запись !!! */
  if v-doc-rec-tmp <> ? THEN DO:
     REPOSITION spec-List to RECID v-doc-rec-tmp NO-ERROR.
     ASSIGN
        v-doc-rec-tmp = ?.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
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
  run proc-del in this-procedure .
  run proc-sum in this-procedure .
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  /* Позиционируем на добавленную запись  */
  if v-doc-rec-tmp <> ? THEN DO:
     REPOSITION spec-List to RECID v-doc-rec-tmp NO-ERROR.
     ASSIGN
        v-doc-rec-tmp = ?.
  END.
  /*  */
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
  run proc-del-AssMat in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exp Dialog-Frame
ON CHOOSE OF b-exp IN FRAME Dialog-Frame /* Экспорт */
DO:
  assign
    f-name = string(p-doc-num) + ".spc"
    g-log = yes
  .
  system-dialog get-file f-name filters "Спецификации к договорам *.spc" "*.spc"
                         use-filename   SAVE-AS   ASK-OVERWRITE   update g-log   default-extension "spc".
  if not g-log then return .
  run waitfram-show in this-procedure ( input "Ждите...").
  output to value (f-name).
  for each  ub.contract-specif exclusive-lock where ub.contract-specif.host-code = p-host-code and ub.contract-specif.contract-num = p-doc-num :
    { gbl/gdsbcode.i
      ub.contract-specif.gds-code
      ?
      b-code }
    find first ub.prod-bc no-lock where ub.prod-bc.b-code = b-code no-error .
    if available ub.prod-bc then
       EXPORT ub.prod-bc.b-str
              ub.contract-specif.price-cli
              ub.contract-specif.prc
              ub.contract-specif.qnty
              ub.contract-specif.VAT-type
              ub.contract-specif.VAT-pc
              .
    else
      EXPORT string(b-code)
             ub.contract-specif.price-cli
             ub.contract-specif.prc
             ub.contract-specif.qnty
             ub.contract-specif.VAT-type
             ub.contract-specif.VAT-pc
             .
  end.
  output close.
  run waitfram-hide in this-procedure .
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
        ( input parparentproc
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ).
    if not can-find (first gds-list-flt ) then  do:
        create gds-list-flt.
        gds-list-flt.gds-code = 0 .
        release gds-list-flt .
        message "Расширенный фильтр пуст!" view-as alert-box information .

        /* Ничего не делать !!!  */
        ASSIGN
           r-2 = 1.
        RETURN NO-APPLY.

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
  run OpenBr in this-procedure ( input yes, input no, input '':U ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  if available buf_contract-specif then do:
    run str/contsp-c.w ( input parparentproc
                        ,input p-host-code
                        ,input buf_contract-specif.contract-num
                        ,input buf_contract-specif.gds-code
                        ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp Dialog-Frame
ON CHOOSE OF b-imp IN FRAME Dialog-Frame /* Импорт */
DO:
  system-dialog get-file f-name
  filters "Спецификации к договорам *.spc" "*.spc" ,
          "Текстовые файлы  *.txt" "*.txt",
          "Все файлы"  "*.*"
  update g-log   default-extension "spc".
  if not g-log then return .

  run proc-imp in this-procedure .
  run proc-sum in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable v-num-entry as integer no-undo .

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
/*    temp-conn.ri = temp-conn.ri + ( if temp-conn.ri = "":U then "":U else {&comma-char} ) + string( recid( buf_contract-specif) ).*/
    temp-conn.ri = recid( buf_contract-specif )
    mark-num = mark-num + 1
    rid-list = rid-list + ( if rid-list = "":U then "":U else {&comma-char} ) + string(temp-conn.ri).
/*	v-mark-seq = v-mark-seq + 1 */
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

  if is-new or is-new1 then do:
    run proc-write in this-procedure .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch1 Dialog-Frame
ON CHOOSE OF b-sch1 IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
    tbl = 'contract-specif'
    join-tbl = 'buf_contract-specif'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
/*  run fltfield-add in this-procedure('host-code', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('contract-num', 'Вн. номер договора', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('db-num', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('gds-name', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('artic', '', '',    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('prod-type', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('prod-code', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('unit-base', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('unit-cli', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('VAT-pc', '', '',    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('VAT-type', 'тип НДС', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('is-qnty', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('is-sum', '', '',    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('qnty', '', '',      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('prc', '', '',       input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('price-rubl', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('price-base', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('price-cli', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('sum-base', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('sum-cli', '', '',    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('sum-rubl', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('income-qnty', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('income-sum-base', 'Сумма по накл в б.в.', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('income-sum-rubl', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('cli-base-rate', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
/*  run fltfield-add in this-procedure('type-charges', '', '',    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  run OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
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
  run gbl/vi-coll.w ( input Parparentproc
                    , input this-procedure
                    , input {&uf-contspec}
                    , input  head-col ) .
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


&Scoped-define SELF-NAME m-export-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-export-excel Dialog-Frame
ON CHOOSE OF MENU-ITEM m-export-excel /* Excel */
DO:
  run proc-export-excel in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-func-all-values
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-func-all-values Dialog-Frame
ON CHOOSE OF MENU-ITEM m-func-all-values
DO:
 define variable v-user-action as character    no-undo.
 define variable v-printed     as logical      no-undo.
 define variable is-ok-all     as logical      no-undo.
 define variable v-file-err    as character    no-undo.
   { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
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
  
 v-file-err = string(session:TEMP-DIRECTORY) + '/writeSpec.err':U .
 if search (v-file-err) <> ? then do:
   os-delete value(v-file-err).
 end.

 run str\contspc2.w (input parParentProc,
                     output v-prc,
                     output v-prc-2,
                     output v-bonus,
                     output v-vat-pc,
                     output v-vat-type,
                     output v-retro-bonus,
                     output v-change-fields) .

  if v-change-fields <> ? and v-change-fields <> "" then do :
      output stream stream-err to value(v-file-err) append .
      put stream stream-err unformatted "Товары из спецификации, для которых не удалось проставить параметры ретро-бонуса (из-за пересекающихся периодов) :" skip.

      is-ok-all = true.
      for each  contract-specif exclusive-lock where
                contract-specif.host-code = p-host-code and
                contract-specif.contract-num = p-doc-num
      , first temp-trn-doc where  ( r-2 = 1 or contract-specif.gds-code = temp-trn-doc.gds-code ) :
        if lookup("prc", v-change-fields) > 1 then
          assign
            contract-specif.prc = v-prc
          .
        if lookup("prc-2", v-change-fields) > 1 then
          run write-prc-min in this-procedure (
              contract-specif.contract-num  ,
              contract-specif.host-code     ,
              contract-specif.gds-code      ,
              v-prc-2 ).
        if lookup("bonus", v-change-fields) > 1 then
          run write-bonus in this-procedure (
              contract-specif.contract-num,
              contract-specif.host-code,
              contract-specif.gds-code,
              v-bonus).
        if lookup("vat-pc", v-change-fields) > 1 then
          assign
              contract-specif.VAT-pc = v-vat-pc
              contract-specif.vat-type = v-vat-type
          .
        if lookup("retro-bonus", v-change-fields) > 1 then do :
          find first ub.contract-specif-attr exclusive-lock  where
                     ub.contract-specif-attr.contract-num = contract-specif.contract-num  and
                     ub.contract-specif-attr.host-code    = contract-specif.host-code     and
                     ub.contract-specif-attr.gds-code     = contract-specif.gds-code      and
                     ub.contract-specif-attr.attr-code    = "retro-bonus"
                     no-error .
             if not available ub.contract-specif-attr then do:
               create ub.contract-specif-attr .
               assign
                     ub.contract-specif-attr.contract-num = contract-specif.contract-num
                     ub.contract-specif-attr.host-code    = contract-specif.host-code
                     ub.contract-specif-attr.gds-code     = contract-specif.gds-code
                     ub.contract-specif-attr.attr-code    = "retro-bonus"
                     ub.contract-specif-attr.attr-value  = v-retro-bonus
               .
             end.
             else do:
               define variable i as integer no-undo .
               define variable is-ok as logical no-undo .
               is-ok = true.
               do i = 1 to num-entries(ub.contract-specif-attr.attr-value, ';') - 1 :  /*  Проверка на пересекающиеся периоды   */
                 if ( date(entry(1, v-retro-bonus)) <= date(entry(2, entry(i, ub.contract-specif-attr.attr-value, ';')))   and
                      date(entry(1, v-retro-bonus)) >= date(entry(1, entry(i, ub.contract-specif-attr.attr-value, ';'))) ) or
                    ( date(entry(2, v-retro-bonus)) <= date(entry(2, entry(i, ub.contract-specif-attr.attr-value, ';')))   and
                      date(entry(2, v-retro-bonus)) >= date(entry(1, entry(i, ub.contract-specif-attr.attr-value, ';'))) ) or
                    ( date(entry(1, v-retro-bonus)) <= date(entry(1, entry(i, ub.contract-specif-attr.attr-value, ';')))   and
                      date(entry(2, v-retro-bonus)) >= date(entry(2, entry(i, ub.contract-specif-attr.attr-value, ';'))) ) then do :
                   is-ok = false.
                   is-ok-all = false.
                 end.
               end.
               if not is-ok then do :

                   put stream stream-err unformatted
                      substitute ("Код: &1   артикул: &2   наименование: &3"
                                   , contract-specif.gds-code
                                   , contract-specif.artic
                                   , contract-specif.gds-name
                                 ) skip.

               end.
               else do :
                  ub.contract-specif-attr.attr-value = ub.contract-specif-attr.attr-value + v-retro-bonus no-error.
                  if error-status:error then
                      message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
               end.
             end.
        end.
      end. /* for each  contract-specif */
      assign
        is-new = yes
      .
      output stream stream-err close .
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
      if not is-ok-all then do :
         MESSAGE
          "Для некоторых товаров из данной спецификации не удалось установить параметры 'ретро-бонуса'" skip
          "Хотите просмотреть отчет?"
          VIEW-AS ALERT-BOX QUESTION buttons YES-NO update glog as logical.
          if not glog then    RETURN NO-APPLY.
          else do :
            run gbl/prnfilen.w
                (input  "Ошибки при установки 'ретро-бонуса'"
                ,input  0
                ,input  v-file-err
                ,input  7
                ,output v-user-action
                ,output v-printed
                ).
          end.
      end.
  end. /* if v-change-fields */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-export-text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-export-text Dialog-Frame
ON CHOOSE OF MENU-ITEM m-export-text /* Текст */
DO:
  run proc-export-text in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-func-vat-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-func-vat-all Dialog-Frame
ON CHOOSE OF MENU-ITEM m-func-vat-all
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
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
  GET FIRST spec-List NO-LOCK .
  if not available buf_contract-specif then return no-apply.
  message "Вы действительно хотите изменить %НДС по всей спецификации по карточке товара ?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
  if g-log = no then return no-apply.

  run utl/ssetvat.p (  input buf_contract-specif.contract-num
                     , input buf_contract-specif.host-code ) .
  run openbr in this-procedure ( input yes, input no, input '':u).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-import-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-import-excel Dialog-Frame
ON CHOOSE OF MENU-ITEM m-import-excel /* Excel */
DO:
  run proc-import-excel in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-import-text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-import-text Dialog-Frame
ON CHOOSE OF MENU-ITEM m-import-text /* Текст */
DO:
  run proc-import-text in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-find
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-find Dialog-Frame
ON VALUE-CHANGED OF RADIO-find IN FRAME Dialog-Frame
DO:
  assign RADIO-find .
  if sch-str <> "" then do:
    run proc-find-code in this-procedure ( input no, input sch-str) no-error.
    if error-status:error then return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dialog-Frame
ON CTRL-J OF sch-str IN FRAME Dialog-Frame
DO:
  assign sch-str .
  assign RADIO-find .
  run proc-find-code in this-procedure ( input yes, input sch-str) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dialog-Frame
ON RETURN OF sch-str IN FRAME Dialog-Frame
DO:
  assign sch-str .
  assign RADIO-find .
  run proc-find-code in this-procedure ( input no, input sch-str) no-error.
  if error-status:error then return no-apply.
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
ASSIGN b-imp:POPUP-MENU IN FRAME {&frame-name} = MENU m-import:HANDLE.
ASSIGN b-imp:MENU-MOUSE = 1.
ASSIGN b-exp:POPUP-MENU IN FRAME {&frame-name} = MENU m-export:HANDLE.
ASSIGN b-exp:MENU-MOUSE = 1.
ASSIGN b-func:POPUP-MENU IN FRAME {&frame-name} = MENU m-func:HANDLE.
ASSIGN b-func:MENU-MOUSE = 1.

{ gbl/app_help.i }
{ gbl/getcntxt.i get }
{ gbl/brwrefre.i "run OpenBr  in this-procedure ( input yes, input no, input '':U)." }

on F9 of frame {&frame-name} anywhere do:
  if not available buf_contract-specif then  return no-apply.
  find first ub.goods no-lock where ub.goods.gds-code = buf_contract-specif.gds-code .
  gds-rec = recid (ub.goods) .
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

/*{ gbl/f2.i spec-List goods-recid init-gds-rec parParentProc }*/

/* сорт  колонок*/
{ gbl/srt-clmd.i
  &table-name  = "{&first-table-in-query-{&browse-name}}"
  &browse-name = "spec-List"
  &frame-name  = "{&frame-name}"
  &ext-col = 23
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &start-column         = 1
  &label-clmn_16        = "{&col-l0}"
  &sort-clmn_16         = "{&cop-l0}"
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
  &dyn_sort-clmn_7      = "{&dyn_cop-l7}"
  &label-clmn_8         = "{&col-l8}"
  &sort-clmn_8          = "{&cop-l8}"
  &label-clmn_9         = "{&col-l9}"
  &sort-clmn_9          = "{&cop-l9}"
  &label-clmn_10         = "{&col-l10}"
  &sort-clmn_10          = "{&cop-l10}"
  &label-clmn_11        = "{&col-l11}"
  &sort-clmn_11         = "{&cop-l11}"
  &label-clmn_12        = "{&col-l12}"
  &sort-clmn_12         = "{&cop-l12}"
  &label-clmn_13        = "{&col-l13}"
  &sort-clmn_13         = "{&cop-l13}"
  &label-clmn_14        = "{&col-l14}"
  &sort-clmn_14         = "{&cop-l14}"
  &label-clmn_15        = "{&col-l15}"
  &sort-clmn_15         = "{&cop-l15}"
  &label-clmn_16        = "{&col-l16}"
  &sort-clmn_16         = "{&cop-l16}"
  &label-clmn_17        = "{&col-l17}"
  &sort-clmn_17         = "{&cop-l17}"
  &label-clmn_18        = "{&col-l18}"
  &sort-clmn_18         = "{&cop-l18}"
  &label-clmn_19        = "{&col-l19}"
  &sort-clmn_19         = "{&cop-l19}"
  &label-clmn_20        = "{&col-l20}"
  &sort-clmn_20         = "{&cop-l20}"
  &label-clmn_21        = "{&col-l21}"
  &sort-clmn_21         = "{&cop-l21}"
  &label-clmn_22         = "{&col-l0}"
  &sort-clmn_22          = "{&cop-l0}"
  &dyn_sort-clmn_1      = "{&dyn_cop-l1}"
  &dyn_sort-clmn_15     = "{&dyn_cop-l15}"
  &dyn_sort-clmn_21     = "{&dyn_cop-l21}"
  &dyn_sort-clmn_23     = "{&dyn_cop-l22}"
  &label-clmn_23        = "{&col-l22}"
  &sort-clmn_23         = "{&cop-l22}"

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
    {&cop-l2}:read-only in browse spec-List = yes
  .

  find first buf_contract no-lock where
            buf_contract.host-code = p-host-code
        and buf_contract.contract-code = p-doc-num .
  find first ub.clients no-lock where
            ub.clients.obj-type = {&cmp}
        and ub.clients.obj-code = p-host-code .
  assign frame {&frame-name}:title =  substitute(" Фирма: (&1) &2 Товарная спецификация к договору &3 от &4"
                                                  ,p-host-code
                                                  ,ub.clients.obj-name
                                                  ,buf_contract.contract-prn-code
                                                  ,string(buf_contract.contract-date,"99/99/9999") ).

/*
  Подключили возможность изменять спецификации в УБД
  if v-cntxt-db-num > 0 then assign ref-mode = {&lookup} .
*/
  assign
 /* FILL-prc     = buf_contract.spec-prc */
  v-contr-type = buf_contract.contract-type
  .

  if v-contr-type = {&contr-addch} then assign frame {&frame-name}:title =
     substitute("Список дополнительных расходов по Фирме: (&1) &2 по договору &3 от &4" ,p-host-code, ub.clients.obj-name , buf_contract.contract-prn-code , string(buf_contract.contract-date,"99/99/9999")) .

/*  if buf_contract.spec-prc <> 0 and buf_contract.spec-prc <> ? then assign b-prc = yes .  */

/*  find first buf_contract-attr no-lock
       where buf_contract-attr.attr-code = {&contract-specif-prc-min}
         and buf_contract-attr.host-code = p-host-code
         and buf_contract-attr.contract-code = p-doc-num no-error.
  if available buf_contract-attr then assign FILL-prc-2 = decimal(buf_contract-attr.attr-value) .
                                 else assign FILL-prc-2 = 0 .    */
/*  if FILL-prc-2 <> 0 then assign b-prc-2 = yes .   */


  run myenable in this-procedure no-error .
  if error-status:error then  return .


  run openbr in this-procedure ( input yes, input no, input '':u) .
  run proc-sum in this-procedure .
  run init-browse-p  in this-procedure  no-error .

  { gbl/mv-clmn.i
    &browse-name = "spec-List"
    &frame-name = "{&frame-name}"
    &ext-col = 23
    &start-column = 1
    &prev-order-column_1 = v-order-column
    &prev-order-column-condition_1 = " true = true "
  }

/*  if v-cntxt-db-num = 0 and b-prc:SENSITIVE then  apply "VALUE-CHANGED" to b-prc IN FRAME {&frame-name} .
  if v-cntxt-db-num = 0 and b-prc-2:SENSITIVE then  apply "VALUE-CHANGED" to b-prc-2 IN FRAME {&frame-name} .  */

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
   if not can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}) and
                                                            ub.assortment-matrix.db-num = v-cntxt-db-num )  then return .
end.
else do:
   if not can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}))  then return .
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
define buffer buf_assortment-matrix for ub.assortment-matrix.
define variable p-doc-rec  as recid no-undo .

repeat v-i = 1 to v-kol :
  find first  buf_assortment-matrix no-lock where recid(buf_assortment-matrix) = integer (entry(v-i,p-rid-list )) no-error .
  if available buf_assortment-matrix then do:
  if buf_assortment-matrix.asmt-status <> integer ({&current-status-int})   then do: message substitute("АМ &1 - удалена , в нее добавлять товар нельзя !" ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj ) view-as alert-box information . next. end.
  if v-cntxt-db-num <> 0 and
     (( buf_assortment-matrix.asmt-type = {&type-assmatr-obj}     and buf_assortment-matrix.db-num-obj         <> v-cntxt-db-num ) or
      ( buf_assortment-matrix.asmt-type = {&type-assmatr-shablon} and buf_assortment-matrix.asmt-db-num-create <> v-cntxt-db-num ))
      then do:
        v-err-ext = true .
        v-longchar = v-longchar +  substitute("АМ &1 чужой БД &2 , в нее добавлять товар нельзя ! &3" ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj , {&new-line} )         .
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

    { ref/gds-mat1.i
      this-procedure
      p-doc-rec
        {&add-def}
        buf_assortment-matrix.asmt-id
        buf_assortment-matrix.db-num
        p-gds-code
        "''"
        no-error
        }
        if error-status :error then do:
           v-err-ext = true .
           v-longchar = v-longchar +  return-value + {&new-line} .
        end.
  end.
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
  DISPLAY RADIO-find sch-str mark-num all-qnty all-sum
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-add b-chg B-del b-exp b-imp b-filter-ext b-uf
         b-sch1 B-print b-hist B-Help B-allmark B-unmark B-add-AssMatr
         B-del-AssMatr b-func RADIO-find sch-str spec-List
         mark-num all-qnty all-sum
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
     input  {&uf-contspec}
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


if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column  = {&contspec-p-ord} .
if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size     = {&contspec-p-siz} .
if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis      = {&bef-contspec-p-vis} .

define variable col-h as handle no-undo .
define variable ii as integer   no-undo .

repeat ii = 1 to cur-clmn-loc   :
    col-h = hcolumn [ ii ]  .
    if decimal(entry(ii,v-spis-size)) = 0 then message ii.
    col-h:width  = decimal(entry(ii,v-spis-size))  .
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
hide b-sch1 in frame {&frame-name} .

DISPLAY
/* b-prc
b-prc-2
b-prc-bonus
FILL-prc
FILL-prc-2  */
sch-str
RADIO-find
mark-num
all-qnty
all-sum
WITH FRAME {&frame-name} .
ENABLE
b-quit
B-mark     when (lookup("B-mark":U, bttns) > 0)
B-unmark   when (lookup("B-mark":U, bttns) > 0)
B-allmark  when (lookup("B-mark":U, bttns) > 0)
b-sel      when (lookup("b-sel":U, bttns) > 0)
b-exp
B-print
B-Help
b-hist
sch-str
RADIO-find
spec-List
mark-num
all-qnty
all-sum
b-filter-ext
b-uf
WITH FRAME {&frame-name} .
if ref-mode = {&update} then do:
  ENABLE
  b-func
  B-add
  B-add-AssMatr
  B-del-AssMatr
  b-chg
  B-del
  b-exp
  b-imp
/*  b-prc
  b-prc-2
  b-prc-bonus
  FILL-prc
  FILL-prc-2
  b-all
  b-all-2  */
  WITH FRAME {&frame-name} .
  if buf_contract.cr-fo = yes then do:
    assign g-log = no.
    message
      substitute("По этой спецификации было создано ФО от &1 . Изменение спецификации приведет к его некорректности! Продолжить?"
                , string(buf_contract.fo-date, "99/99/9999")
                )
    view-as alert-box question buttons yes-no update g-log.
    if g-log <> yes then  return error.
  end.
end.
VIEW FRAME {&frame-name} .
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
  &scop flt-open-open-query-tail     , first temp-trn-doc where (r-2 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code )
  &scop flt-open-dyn_open-query-tail   substitute(' , first temp-trn-doc where ( &1 = 1 or buf_contract-specif.gds-code = temp-trn-doc.gds-code )',  r-2 )

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

  IF AVAILABLE buf_contract-specif THEN DO:
     ASSIGN
        v-doc-rec = recid (buf_contract-specif) .
  END.

  { gbl/fltopend.i
    &where-cond = " buf_contract-specif.host-code = p-host-code and buf_contract-specif.contract-num = p-doc-num "
    &DYN_where-cond = " substitute(' buf_contract-specif.host-code = &1 and buf_contract-specif.contract-num = &2 ', p-host-code, p-doc-num ) "
    &use-ind = "  "
    &by = " "
  }
  /*  */
  IF v-doc-rec <> ? THEN DO:
     /* Позиционируем куда надо !!! */
     REPOSITION spec-List to RECID v-doc-rec NO-ERROR.
  END.
  /* */
  APPLY
     "entry" to spec-List in frame {&frame-name}.
  /*  */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame
PROCEDURE proc-add :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable varschartic  like ub.doc-line.artic initial " " no-undo.
  define variable ref-list  as character no-undo .
  define variable lns-cnt   as integer initial 1  no-undo .
  define buffer b_goods for ub.goods .
  define buffer b_contract-specif for ub.contract-specif .
  define variable is-con as logical   no-undo .
  define variable is-create as logical   no-undo .
  define variable v-gds-recid as recid no-undo .

  if buf_contract.contract-type =  {&contr-addch} then do:
      run ref/addchls.w (
      input parparentproc ,

      input "b-sel,b-mark",
      output ref-list )
      no-error .
      if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "ref/addchls.w"
            view-as alert-box error
          .
      end.
  end.
  else do:
      run str/chs-gds.w (
                   input parparentproc
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input '':U
                  ,input '':U
                  ,input "Строка товар. специф. к договору " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
                  ,input {&all} /*режим вызова справочника товаров*/
                  ,input buf_contract.cli-type
                  ,input buf_contract.cli-code
                  ,input v-cntxt-host-code-obj
                  ,input ? /* ext-doc-type */
                  ,input-output varschartic
                  ,output ref-list)
                  no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "chs-gds.w"
          view-as alert-box error
        .
      end.
  end.


if ref-list = "" then  return .

/* MATRIX */
define variable v-ass-m as logical   no-undo init false .
if ibs.th.gbl.gbl-var:g#db-num <> 0 then do :
   if can-find ( first ub.assortment-matrix where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}) and
                                                   ub.assortment-matrix.db-num = ibs.th.gbl.gbl-var:g#db-num )  then v-ass-m = true  .
end.
else do:
   if can-find ( first ub.assortment-matrix where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}))  then v-ass-m = true  .
end.
define variable v-log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    ibs.th.gbl.gbl-var:g#db-num
    ibs.th.gbl.gbl-var:g#userid
    {&action-head-code-main}
    'actn_assort-matr-gds_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    false
    v-log
  }
 if not v-log then v-ass-m = false .

if v-ass-m = true then do:
  message "Добавить НОВЫЕ товары спецификации в Ассортиментные матрицы ?"
          "Если ДА , укажите в какие."
          view-as alert-box question
                  buttons yes-no
                  update v-okk as logical
                  .
  if v-okk then do:
       define variable p-rid-list as character no-undo .
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
  end.
end.


  do while lns-cnt <= num-entries (ref-list):
    v-gds-recid = integer (entry (lns-cnt, ref-list)) no-error .
    find b_goods no-lock where recid(b_goods) = v-gds-recid no-error .
    if not available b_goods then next .
    
      run  SpecGr-gds-code-yes in this-procedure (
          input  b_goods.gds-code ,
          input  b_goods.grp-code ,
          input  p-doc-num   ,
          input  p-host-code      ,
          output p-ask        ) no-error .
          if error-status :error  or p-ask = false  then do:
            message substitute("Нельзя добавлять товар &1 &2 в Спецификацию из-за ограничения по ассортименту в группе", b_goods.gds-code  ,b_goods.gds-name) skip
              return-value skip error-status :get-message(1)
              view-as alert-box information .
              return .
          end.

    { gbl/pftxvalg.i
      b_goods.gds-code
      {&vat-tax-code}
      ?
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-vat-pc
      no-error
    }

    ASSIGN lns-cnt = lns-cnt + 1 .
    find first ub.contract-specif no-lock
      where ub.contract-specif.host-code    = p-host-code
        and ub.contract-specif.contract-num = p-doc-num
        and ub.contract-specif.gds-code     = b_goods.gds-code
    no-error .
    if available ub.contract-specif then do:
      message "Спецификация по товару " b_goods.gds-name " уже есть. Вы хотите изменить спецификацию?"
      view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .
      assign  is-create = no .
    end.
    else do:
      assign
        is-create = yes
        is-con = yes
        is-new = yes
      .
    end.
    if is-con = yes then do:
      if is-create then do:
        assign
          v-price         = 0
          v-qnty          = ?
          v-prc           = buf_contract.spec-prc
          v-vat-type      = {&inc-vat}
          v-cli-base-rate = b_goods.cli-base-rate
          v-unit-cli      = b_goods.unit-cli
        .
        find first buf_ext-artic no-lock
          where buf_ext-artic.gds-code = b_goods.gds-code
            and buf_ext-artic.cli-type = buf_contract.cli-type
            and buf_ext-artic.cli-code = buf_contract.cli-code
        no-error .
        if available buf_ext-artic then do:
          assign
            v-unit-cli          = buf_ext-artic.unit-cli
            v-cli-base-rate     = buf_ext-artic.cli-base-rate
            v-unit-cli-ord      = buf_ext-artic.unit-cli-ord
            v-cli-base-rate-ord = buf_ext-artic.cli-base-rate-ord
            v-unit-cli-rcv      = buf_ext-artic.unit-cli-rcv
            v-cli-base-rate-rcv = buf_ext-artic.cli-base-rate-rcv
          .
        end.
        else do:
          assign
            v-unit-cli          = b_goods.unit-cli
            v-cli-base-rate     = b_goods.cli-base-rate
            v-unit-cli-ord      = b_goods.unit-cli
            v-cli-base-rate-ord = b_goods.cli-base-rate
            v-unit-cli-rcv      = b_goods.unit-cli
            v-cli-base-rate-rcv = b_goods.cli-base-rate
          .
        end.
      end.
      else do:
        assign
          v-price         = ub.contract-specif.price-cli
          v-qnty          = ub.contract-specif.qnty
          v-prc           = ub.contract-specif.prc
          v-vat-type      = ub.contract-specif.vat-type
          v-cli-base-rate = ub.contract-specif.cli-base-rate
          v-unit-cli      = ub.contract-specif.unit-cli
          v-cli-base-rate-ord = ub.contract-specif.cli-base-rate-ord
          v-unit-cli-ord      = ub.contract-specif.unit-cli-ord
          v-cli-base-rate-rcv = ub.contract-specif.cli-base-rate-rcv
          v-unit-cli-rcv      = ub.contract-specif.unit-cli-rcv
        .
      end.
 /*     if b-prc then assign v-prc = FILL-prc .
      if b-prc-2 then assign v-prc-2 = FILL-prc-2 .  */
run read-bonus in this-procedure (
          buf_contract.contract-code ,
          buf_contract.host-code     ,
          b_goods.gds-code   ,
          output v-bonus ) .
      run read-prc-min in this-procedure (
          buf_contract.contract-code ,
          buf_contract.host-code     ,
          b_goods.gds-code   ,
          output v-prc-2 ) .

      run read-retro-bonus in this-procedure (
          buf_contract.contract-code ,
          buf_contract.host-code     ,
          b_goods.gds-code   ,
          output v-retro-bonus ) .

      run str/contspc1.w
                         ( input parParentProc
                         , input {&update}
                         , input b_goods.gds-code
                         , input b_goods.artic
                         , input ( b_goods.prod-type + string(b_goods.prod-code))
                         , input b_goods.gds-name
                         , input b_goods.unit-base
                         , input-output v-price
                         , input-output v-prc
                         , input-output v-prc-2
                         , input-output v-vat-type
                         , input-output v-qnty
                         , input-output v-cli-base-rate
                         , input-output v-vat-pc
                         , input-output v-unit-cli
                         , input-output v-unit-cli-ord
                         , input-output v-cli-base-rate-ord
                         , input-output v-unit-cli-rcv
                         , input-output v-cli-base-rate-rcv
                         , input-output v-bonus
                         , input-output v-retro-bonus
                         , output v-res) .

      if v-res then do:
        if is-create then do:
          run add-assmatr in this-procedure (input b_goods.gds-code ,input p-rid-list) .
        end.

        do transaction :
          if is-create then do:
            create b_contract-specif .
            assign
              b_contract-specif.host-code     = p-host-code
              b_contract-specif.contract-num  = p-doc-num
              b_contract-specif.gds-code      = b_goods.gds-code
              b_contract-specif.gds-name      = b_goods.gds-name
              b_contract-specif.artic         = b_goods.artic
              b_contract-specif.prod-type     = b_goods.prod-type
              b_contract-specif.prod-code     = b_goods.prod-code
              b_contract-specif.cli-base-rate = b_goods.cli-base-rate
              b_contract-specif.unit-base     = b_goods.unit-base
              b_contract-specif.VAT-type      = {&inc-vat}
              b_contract-specif.VAT-pc        = v-vat-pc
              b_contract-specif.prc           = buf_contract.spec-prc
              b_contract-specif.db-num        = v-cntxt-db-num
            .
           run write-bonus in this-procedure (
                buf_contract.contract-code  ,
                buf_contract.host-code     ,
                b_goods.gds-code      ,
                v-bonus ).
           run write-prc-min in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               b_goods.gds-code   ,
               v-prc-2 ) .
           run write-retro-bonus in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               b_goods.gds-code   ,
               v-retro-bonus ) .

            run recalc-gds-SpecGr in this-procedure
              (  /* пересчет после удаления или внесения товара в Спецификацию */
                input  '+'              ,
                input  b_goods.grp-code ,
                input  p-doc-num   ,
                input  p-host-code  )
                no-error .

          end.
          else do:
            find first b_contract-specif exclusive-lock where recid(b_contract-specif) = recid (ub.contract-specif) .
          end.
          assign
            b_contract-specif.price-cli = v-price
            b_contract-specif.prc       = v-prc
            b_contract-specif.vat-type  = v-vat-type
            b_contract-specif.qnty      = v-qnty
            b_contract-specif.sum-cli   = v-price * v-qnty
            b_contract-specif.cli-base-rate = v-cli-base-rate
            b_contract-specif.unit-cli  = v-unit-cli
            b_contract-specif.VAT-pc    = v-vat-pc
            b_contract-specif.cli-base-rate-ord = v-cli-base-rate-ord
            b_contract-specif.unit-cli-ord      = v-unit-cli-ord
            b_contract-specif.cli-base-rate-rcv = v-cli-base-rate-rcv
            b_contract-specif.unit-cli-rcv      = v-unit-cli-rcv
            is-new = yes
          .
           run write-bonus in this-procedure (
                buf_contract.contract-code ,
                buf_contract.host-code     ,
                b_goods.gds-code      ,
                v-bonus ).
           run write-prc-min in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               b_goods.gds-code   ,
               v-prc-2 ) .
           run write-retro-bonus in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               b_goods.gds-code   ,
               v-retro-bonus ) .

          /* Будем позиционировать на последний, или если один то на первый */
          ASSIGN
             v-doc-rec-tmp = RECID(b_Contract-specif)
             .
          /*  */
        end.
      end.
    end.
  end.

END PROCEDURE.

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
   if can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}) and
                                                        ub.assortment-matrix.db-num = v-cntxt-db-num )  then v-ass-m = true  .
end.
else do:
   if can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}))  then v-ass-m = true  .
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


  message "Добавить выбранные товары спецификации в Ассортиментные матрицы ?"
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

    run waitfram-show in this-procedure ( input "Добавление в Ассортиментные матрицы")  .
    v-err-ext = false  .
    v-longchar = "" .
    for each temp-conn,
        first bb_contract-specif no-lock  where
        recid(bb_contract-specif) = temp-conn.ri :
        run add-assmatr in this-procedure ( input bb_contract-specif.gds-code
                                           ,input p-rid-list) .
    end.
    run waitfram-hide in this-procedure .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-del Dialog-Frame
PROCEDURE proc-del :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
v-err-ext = false  .
v-longchar = "".

define variable is-con as logical   no-undo .
define buffer b_goods for ub.goods  .
find buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code.
  if mark-num = 0 then do:
    if not available buf_contract-specif then return no-apply.
    message "Вы действительно хотите удалить спецификацию по товару "
             buf_goods.artic
             buf_goods.gds-name "?"
    view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .
    if is-con = no then return no-apply.

    do transaction :
      find first ub.contract-specif exclusive-lock where recid (ub.contract-specif) = recid(buf_contract-specif) .
      find b_goods no-lock where b_goods.gds-code = ub.contract-specif.gds-code.
      run recalc-gds-SpecGr in this-procedure
        (  /* пересчет после удаления или внесения товара в Спецификацию */
          input  '-'                          ,
          input  b_goods.grp-code             ,
          input  ub.contract-specif.contract-num ,
          input  ub.contract-specif.host-code    )
          no-error .

      delete ub.contract-specif .
      v-ask = true .
      run spedlass-proc in this-procedure
          ( input parParentProc,
            input b_goods.gds-code ,
            input p-doc-num ,
            input p-host-code ,
            input v-ask ,
            input-output v-list-mat ,
            input-output v-err-ext ,
            input-output v-longchar
          ) no-error .
      assign is-new = yes .
    end.
    /*  */
    /* Позиционируем следующую запись после удаленной, если получится  */
    FIND NEXT contract-specif NO-LOCK NO-ERROR.
    if AVAILABLE contract-specif THEN DO:
       ASSIGN
          v-doc-rec-tmp =RECID(contract-specif)
          .
    END.
    /*  */
  end.
  else do: /* удаляем списком */
    message "Вы действительно хотите удалить выбранные товары из спецификации ?"
    view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .
    if is-con = no then return no-apply.
    v-ask = true .
    do transaction :
      for each temp-conn :
        find first ub.contract-specif exclusive-lock where recid (ub.contract-specif) = temp-conn.ri .
      find b_goods no-lock where b_goods.gds-code = ub.contract-specif.gds-code.
      run recalc-gds-SpecGr in this-procedure
        (  /* пересчет после удаления или внесения товара в Спецификацию */
          input  '-'                          ,
          input  b_goods.grp-code             ,
          input  ub.contract-specif.contract-num ,
          input  ub.contract-specif.host-code  )
          no-error .

        delete ub.contract-specif .
        delete temp-conn .
        run spedlass-proc in this-procedure
           (input parParentProc ,
            input b_goods.gds-code ,
            input p-doc-num ,
            input p-host-code ,
            input v-ask ,
            input-output v-list-mat ,
            input-output v-err-ext ,
            input-output v-longchar
            ) no-error .
        v-ask = false .
      end.
      assign
        is-new = yes
        mark-num = 0
      .
    end.
    display mark-num  with frame {&frame-name}.
    /*  */
    /* Позиционируем следующую запись после удаленной, если получится  */
    FIND NEXT contract-specif NO-LOCK NO-ERROR.
    if AVAILABLE contract-specif THEN DO:
       ASSIGN
          v-doc-rec-tmp =RECID(contract-specif)
          .
    END.
  end.

if v-err-ext = true  then do:
define variable v-ok as logical   no-undo .
  run gbl/d-longchar.w (
        ?,
        'Editor_row=2\':u
      + 'title=При удалении из Ассортиментных матриц\':u
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
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .

define variable v-ass-m as logical   no-undo init false .
define variable v-log as logical   no-undo .
define variable v-sts as integer   no-undo .
define variable p-rid-list as character no-undo .
define variable i as integer   no-undo .


if not can-find( first temp-conn) then do:
    message "Не выделено ни одного товара !" view-as alert-box .
    return .
end.

if v-cntxt-db-num <> 0 then do :
   if can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}) and
                                                        ub.assortment-matrix.db-num = v-cntxt-db-num )  then v-ass-m = true  .
end.
else do:
   if can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}))  then v-ass-m = true  .
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


  message "Удалить выбранные товары спецификации  из  Ассортиментных матриц ?"
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
run waitfram-show in this-procedure ( input "Удаление из Ассортиментных матриц")  .
v-err-ext = false .
v-longchar = "".
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
              v-err-ext = true  .
              v-longchar = v-longchar +  return-value + {&new-line} .
          end.
    end.
  end.
end.
end.

run waitfram-hide in this-procedure .
if v-err-ext = true  then do:
define variable v-ok as logical   no-undo .
  run gbl/d-longchar.w (
        ?,
        'Editor_row=2\':u
      + 'title=При удалении из Ассортиментных матриц\':u
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
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input ("utl/thbjrumr.w":U + {&delim-par}
                                + {&delim-par}   /*error-message-option*/
              + string(2)       + {&delim-par}   /*auto-go-option*/
            )
    , input ({&edoc} + {&delim-par} +
            /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
          {&edoc-proc_excel-export_specif} + {&delim-par} +
          string(buf_contract.contract-code)
          )     /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input ""
  , input substitute("Экспорт спецификации в EXCEL") ) no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-export-text Dialog-Frame
PROCEDURE proc-export-text :
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input ("utl/thbjrumr.w":U + {&delim-par}
                                + {&delim-par}   /*error-message-option*/
              + string(2)       + {&delim-par}   /*auto-go-option*/
            )
    , input ({&edoc} + {&delim-par} +
            /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
          {&edoc-proc_text-export_specif} + {&delim-par} +
          string(buf_contract.contract-code)
          )     /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
  , input substitute("Экспорт спецификации в текстовый файл") ) no-error .

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
  /*  */
  DEFINE BUFFER buf_bar-code FOR  ub.bar-code .
  DEFINE BUFFER buf_prod-bc  FOR  ub.prod-bc.
  DEFINE BUFFER buf_place    FOR  ub.place.
  /*  */
  DEFINE VARIABLE v-cResult  AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE v-cType-bc AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE v-dWeight  AS DECIMAL   NO-UNDO INITIAL 0.
  /*  */
  assign p-code = replace(p-code, {&single-quote}, {&single-quote} + {&single-quote}) .
  case RADIO-find :
    when 1 then do:
        /* Поиск по бар коду  */
         { str/bc-rcnz.i
           parparentproc
           p-Code
           ?
           v-cntxt-obj-type
           v-cntxt-obj-code
           yes
           no
           varscales-pref
           varpgscales-pref
           v-cResult
           v-cType-bc
           v-dWeight
           buf_bar-code
           buf_prod-bc
           buf_place
           no-error
         }
         /*  */
         IF AVAILABLE buf_bar-code THEN DO:
            RUN OpenBr in this-procedure (
                input false,
                input FALSE,  /* Всегда как при первоначальном поиске */
                input substitute('and buf_contract-specif.gds-code = &1 ', buf_bar-code.gds-code)
                ).
         END. ELSE DO:
            MESSAGE "Бар код =" p-code "не найден !"
                VIEW-AS ALERT-BOX INFO BUTTONS OK.

         END.
         /*  */
    end.
    when 2 then run OpenBr in this-procedure ( input false, input p-next, input substitute('and buf_contract-specif.artic = "&1" ', p-code)).
    when 3 then run OpenBr in this-procedure ( input false, input p-next, input substitute('and buf_contract-specif.gds-name begins "&1" ', p-code)).
    when 4 then do:
      assign p-code = lc (p-code) + "*" .
      run OpenBr in this-procedure ( input false, input p-next, input substitute('and buf_contract-specif.gds-name contains "&1" ', p-code)).
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-imp Dialog-Frame
PROCEDURE proc-imp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_modernization':U
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

  define buffer bf_bar-code      for ub.bar-code.
  define buffer bf_prod-bc       for ub.prod-bc.
  define buffer bf_place         for ub.place.
  define buffer bf_goods         for ub.goods .
  define variable b-str as character no-undo .
  define variable parresult   as character                no-undo.
  define variable partype-bc  as character                no-undo.
  define variable parweight   as decimal                  no-undo.
  define variable v-bonus     as decimal                  no-undo .

  { str/sclspref.i }
  run waitfram-show in this-procedure ( input "Ждите...").
  input from value (f-name).
  REPEAT :
    assign
      b-str = ""
      v-price          = 0
      v-prc            = 0
      v-VAT-type       = {&inc-vat}
      v-qnty           = ?
      v-cli-base-rate  = 1
      v-unit-cli       = ""
      v-VAT-pc         = buf_contract.fin-VAT-pc
      v-bonus          = 0
    .

    IMPORT b-str v-price v-prc v-qnty v-cli-base-rate v-VAT-type  v-VAT-pc v-bonus NO-ERROR.
    IF ERROR-STATUS :ERROR THEN NEXT.

    { str/bc-rcnz.i
      parparentproc
      b-str
      ?
      "''"
      ?
      no
      no
      varscales-pref
      varpgscales-pref
      parresult
      partype-bc
      parweight
      bf_bar-code
      bf_prod-bc
      bf_place
      no-error }
    if not available bf_bar-code then do:
      message "Бар-код не найден " b-str view-as alert-box.
      NEXT.
    end.
    else do:
      do transaction :
        find first ub.contract-specif exclusive-lock
          where ub.contract-specif.host-code    = p-host-code
            and ub.contract-specif.contract-num = p-doc-num
            and ub.contract-specif.gds-code     = bf_bar-code.gds-code
        no-error .
        if not available  ub.contract-specif then do:
          find bf_goods no-lock where bf_goods.gds-code = bf_bar-code.gds-code .
  run  SpecGr-gds-code-yes in this-procedure (
              input  bf_goods.gds-code ,
              input  bf_goods.grp-code ,
              input  p-doc-num   ,
              input  p-host-code      ,
              output p-ask        ) no-error .
              if error-status :error  or p-ask = false  then do:
                 message substitute("Нельзя добавлять товар &1 &2 в Спецификацию из-за ограничения по ассортименту в группе", bf_goods.gds-code  ,bf_goods.gds-name) skip
                 view-as alert-box information .
                 next.
              end.
          create ub.contract-specif .

          assign
            ub.contract-specif.host-code     = p-host-code
            ub.contract-specif.contract-num  = p-doc-num
            ub.contract-specif.gds-code      = bf_bar-code.gds-code
            ub.contract-specif.gds-name      = bf_goods.gds-name
            ub.contract-specif.artic         = bf_goods.artic
            ub.contract-specif.prod-type     = bf_goods.prod-type
            ub.contract-specif.prod-code     = bf_goods.prod-code
            ub.contract-specif.cli-base-rate = bf_bar-code.cli-base-rate
            ub.contract-specif.unit-cli      = bf_bar-code.unit-cli
            ub.contract-specif.cli-base-rate-ord = bf_bar-code.cli-base-rate
            ub.contract-specif.unit-cli-ord      = bf_bar-code.unit-cli
            ub.contract-specif.cli-base-rate-rcv = bf_bar-code.cli-base-rate
            ub.contract-specif.unit-cli-rcv      = bf_bar-code.unit-cli
            ub.contract-specif.unit-base     = bf_goods.unit-base
            ub.contract-specif.db-num        = v-cntxt-db-num
          .
        end.
        assign
          ub.contract-specif.price-cli     = v-price
          ub.contract-specif.prc           = v-prc
          ub.contract-specif.qnty          = v-qnty
          ub.contract-specif.sum-cli       = v-price * v-qnty
          ub.contract-specif.VAT-type      = v-VAT-type
          ub.contract-specif.VAT-pc        = v-VAT-pc
          is-new = yes
        .
        run write-bonus in this-procedure ( input buf_contract.contract-code
                                          , input buf_contract.host-code
                                          , input ub.contract-specif.gds-code
                                          , input v-bonus
                                          ).
        run write-prc-min in this-procedure (
            buf_contract.contract-code ,
            buf_contract.host-code     ,
            ub.contract-specif.gds-code   ,
            v-prc-2 ) .

        run recalc-gds-SpecGr in this-procedure
          (  /* пересчет после удаления или внесения товара в Спецификацию */
            input  '+'              ,
            input  bf_goods.grp-code ,
            input  p-doc-num   ,
            input  p-host-code  )
            no-error .
      end.
    end.
  END.

  input close.
  run waitfram-hide in this-procedure .
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-import-excel Dialog-Frame
PROCEDURE proc-import-excel :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-contract_modernization':U
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
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input ("utl/thbjrumr.w":U + {&delim-par}
                                + {&delim-par}   /*error-message-option*/
              + string(2)       + {&delim-par}   /*auto-go-option*/
            )
    , input ({&edoc} + {&delim-par} +
             /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
           {&edoc-proc_excel-import_specif} + {&delim-par} +
           string(buf_contract.contract-code)
           )     /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Импорт спецификации из EXCEL") ) no-error .
run proc-sum in this-procedure .
run openbr in this-procedure ( input yes, input no, input '':u).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-import-text Dialog-Frame
PROCEDURE proc-import-text :
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-contract_modernization':U
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
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input ("utl/thbjrumr.w":U + {&delim-par}
                                + {&delim-par}   /*error-message-option*/
              + string(2)       + {&delim-par}   /*auto-go-option*/
            )
    , input ({&edoc} + {&delim-par} +
             /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
           {&edoc-proc_text-import_specif} + {&delim-par} +
           string(buf_contract.contract-code)
           )     /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Импорт спецификации из текстового файла") ) no-error .
run proc-sum in this-procedure .
run openbr in this-procedure ( input yes, input no, input '':u).
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
    sym1 b-code       COLUMN-LABEL {&col-l1}  Format "X(12)"                          space(0)
    sym9 b-ext        COLUMN-LABEL {&col-l16} Format "X(12)"                          space(0)
    sym2 b-name       COLUMN-LABEL {&col-l4}  format "x(30)"                          space(0)
    sym3 {&cop-l5}    COLUMN-LABEL {&col-l5}  format ">>>,>>>,>>9.99"                 space(0)
    sym4 {&cop-l6}    COLUMN-LABEL {&col-l6}  Format "->>>9.99"                       space(0)
    sym5 {&cop-l2}    COLUMN-LABEL {&col-l2}  Format "x(16)"                          space(0)
    sym6 b-prod       COLUMN-LABEL {&col-l3}  Format "x(12)"                          space(0)
    sym7 b-bonus      COLUMN-LABEL {&col-l15}                                         space(0)
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

  PUT stream PrnLibStream  SPACE(30) string("Товарная спецификация к договору " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")) format "X(100)"  SKIP .

  FOR EACH buf_contract-specif NO-LOCK where buf_contract-specif.host-code = p-host-code and buf_contract-specif.contract-num = p-doc-num :
    assign
      b-code = get-b-code(buf_contract-specif.gds-code)
      b-name = get-gds-name (buf_contract-specif.gds-code)
      b-ext = get-ext-artic ( recid(buf_contract-specif) )
      b-prod = string( buf_contract-specif.prod-type + ' ' + string(buf_contract-specif.prod-code))
    .
    run read-bonus  in this-procedure (
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
                              sym5    {&cop-l2}
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sum Dialog-Frame
PROCEDURE proc-sum :
define buffer b_contract-specif for contract-specif .
  assign
    all-sum = 0
    all-qnty = 0
  .
  for each b_contract-specif no-lock where
          b_contract-specif.host-code = p-host-code
      and b_contract-specif.contract-num = p-doc-num :
    if b_contract-specif.sum-cli <> ? then   do:
      assign
      all-sum  = all-sum  + b_contract-specif.sum-cli .
    end.
    if b_contract-specif.qnty    <> ? then  do:
      assign
      all-qnty = all-qnty + b_contract-specif.qnty    .
    end.
  end.
  DISPLAY
  all-qnty
  all-sum
  WITH FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-write Dialog-Frame
PROCEDURE proc-write :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
do transaction :
  run contrcth_write-hist in this-procedure ( input p-host-code
                                             ,input p-doc-num).

  find first buf_contract exclusive-lock where
              buf_contract.host-code = p-host-code
          and buf_contract.contract-code = p-doc-num .

 /* if b-prc then assign  buf_contract.spec-prc = FILL-prc .
  else          assign  buf_contract.spec-prc = 0 .
  if b-prc-2 then do :
    find first buf_contract-attr exclusive-lock where
               buf_contract-attr.host-code = p-host-code
           and buf_contract-attr.contract-code = p-doc-num
           and buf_contract-attr.attr-code = {&contract-specif-prc-min} no-error.
    if not available buf_contract-attr then do :
      create buf_contract-attr.
      assign
        buf_contract-attr.attr-value    = string(FILL-prc-2)
        buf_contract-attr.host-code     = p-host-code
        buf_contract-attr.contract-code = p-doc-num
        buf_contract-attr.attr-code     = {&contract-specif-prc-min}
      .
    end.
    else do :
      buf_contract-attr.attr-value    = string(FILL-prc-2) .
    end.
  end .
  else do :
    find first buf_contract-attr exclusive-lock where
               buf_contract-attr.host-code = p-host-code
           and buf_contract-attr.contract-code = p-doc-num
           and buf_contract-attr.attr-code = {&contract-specif-prc-min} no-error.
    if available buf_contract-attr then buf_contract-attr.attr-value    = string(FILL-prc-2) .
  end.  */
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-bonus Dialog-Frame
FUNCTION f-bonus RETURNS DECIMAL
  ( input par-recid as recid ) :
  define buffer buf_contract-specif for ub.contract-specif  .
  define variable v-bonus as decimal   no-undo .
  find first buf_contract-specif no-lock where
           recid(buf_contract-specif) = par-recid no-error .
  if error-status :error then return 0.0 .
  v-bonus = 0.0 .
  run read-bonus in this-procedure
  ( buf_contract-specif.contract-num,
    buf_contract-specif.host-code ,
    buf_contract-specif.gds-code ,
    output v-bonus
  ) no-error .
  return v-bonus .   /* Function return value. */
END FUNCTION.

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
  find first bf_goods no-lock where
            bf_goods.gds-code = p-gds-code no-error  .
  if error-status :error then do:
  end.
  else assign ret = bf_goods.gds-name  .

  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-grp Dialog-Frame
FUNCTION get-grp RETURNS CHARACTER
  ( input gds-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define buffer buf_goods for ub.goods.
  find first buf_goods no-lock where buf_goods.gds-code = gds-code .
  RETURN buf_goods.grp-name .
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