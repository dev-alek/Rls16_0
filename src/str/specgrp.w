&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dlg-grp


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_contract-specif FOR ub.contract-specif.
DEFINE BUFFER buf_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dlg-grp
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Управление ассортиментной Спецификации  в разрезе групп

Автор: Чернова Светлана Александровна
Дата создания: 10/08/08
Author: Svetlana Chernova
Creation date: 10/08/08


*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */


define input parameter parparentproc        as handle           no-undo.
define input parameter p-host-code          as integer   no-undo .
define input parameter p-contract-num       as integer   no-undo .
define input parameter p-button-list        as character        no-undo. /* список включенных кнопок */
define input parameter p-current-obj-type   as character        no-undo.
define input parameter p-current-obj-code   as integer          no-undo.
define input-output parameter p-recid-list  as character        no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление деревом групп".
{ cmp/vssrevis.i     }
{ cmp/trg-def.i      }
{ cmp/showinf.i      }
{ ref/grplib.i       }
{ cmp/library.i      }
{ ref/gds-matl.i     }
{ gbl/cur-time.i     }
{ cmp/r-pril.i new   }
{ gbl/waitfram.i     }
{ gbl/usr-flt.i      }
{ ref/grp-attr.i     }
{ gbl/prn-lib.i      }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/fltopend.i defproc }
{ gbl/integerm.i }
{ cmp/mrk-strf.i }
{ ref/assgrpmt.i }
{ ref/spegrpmt.i }
{ str/spedlass.i }
{ str/specattr.i }
{ str/ascorrm.i  }
{ gbl/assmatat.i }   /* Библиотека для работы с атрибутами АМ */
{ gbl/thbj-def.i }
{ ref/ass-mat.i &DEF_PROC=YES}    /* Процедуры и функции для работы с АМ (по задаче "Процент отклонения матрицы от шаблона") */

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


/*
cli-type    - Ограничение по группе
min-marg    - ограничения по нижним
max-marg    - количество в группе
*/

define temp-table temp_cons no-undo
    field node-code     as integer
    field upper-code    as integer
    field full-name     as character
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
index pi is unique node-code
index uc upper-code
.

define temp-table temp-conn no-undo
  field ri  as  recid
  index pi  is primary   ri
.
/*  у-у-у !!!  */
FUNCTION mark-stringK RETURNS CHARACTER
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-prc-min Dialog-Frame
FUNCTION f-prc-min RETURNS DECIMAL
  ( input par-recid as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&scop col-l0  '*'
&scop col-l1  'БарКод'
&scop col-l2  'Артикул'
&scop col-l3  'Производитель'
&scop col-l4  'Наименование'
&scop col-l5  'Цена поставщика'
&scop col-l6  '% отклон. в большую сторону'
&scop col-l7  '% отклон. в меньшую сторону'
&scop col-l8  'Код товара'
&scop col-l9  'Количество'
&scop col-l10  'Е.И.'
&scop col-l11 'Сумма'
&scop col-l12 'НДС'
&scop col-l13 'тип НДС'
&scop col-l14 'Принято'

&scop cop-l0  mark-stringK(recid(buf_contract-specif))
&scop cop-l1  get-b-code(buf_contract-specif.gds-code)
&scop dyn_cop-l1 substitute('dynamic-function(&1get-b-code&1, &2)', ~{&double-quote~}, buf_contract-specif.gds-code)
&scop cop-l2  buf_contract-specif.artic
&scop cop-l3  string (buf_contract-specif.prod-type + ' ' + string(buf_contract-specif.prod-code))
&scop cop-l4  buf_contract-specif.gds-name
&scop cop-l5  buf_contract-specif.price-cli
&scop cop-l6  buf_contract-specif.prc
&scop cop-l7  f-prc-min(recid(buf_contract-specif))
&scop dyn_cop-l7 substitute('dynamic-function(&1f-prc-min&1, recid(buf_contract-specif))', ~{&double-quote~} )
&scop cop-l8  buf_contract-specif.gds-code
&scop cop-l9  buf_contract-specif.qnty
&scop cop-l10  buf_contract-specif.unit-base
&scop cop-l11 buf_contract-specif.sum-cli
&scop cop-l12 buf_contract-specif.vat-pc
&scop cop-l13 buf_contract-specif.vat-type
&scop cop-l14 buf_contract-specif.income-qnty

define variable g-log as logical   no-undo .
define variable is-new           as logical   no-undo initial no .
define variable is-new1          as logical   no-undo initial no .
define variable v-res            as logical   no-undo initial no .
define variable b-code           as integer   no-undo .

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
define variable old-prc-min        as decimal   no-undo .
define variable v-contr-type     as character no-undo .
define variable v-cli-base-rate-ord as decimal   no-undo .
define variable v-unit-cli-ord as character no-undo .
define variable v-cli-base-rate-rcv as decimal   no-undo .
define variable v-unit-cli-rcv as character no-undo .

define buffer buf_ext-artic        for ub.ext-artic  .
define variable p-ask as logical   no-undo .
define variable v-retro-bonus    as character no-undo .
define variable old-retro-bonus  as character no-undo .

v-err-ext = false  .
v-longchar = "".
{ ref/clearlm.i }

/* Запускаем инклудник переопределения Host-code и Contract code
  для подчиненных договоров  */
{
str/cont-spec-slave.i
&P_HOST_CODE = p-Host-Code
&P_CONTRACT_CODE = p-Contract-Num
}

define buffer buf_contract for ub.contract .

find first buf_contract no-lock where
           buf_contract.contract-code  = p-contract-num     and
           buf_contract.host-code   = p-host-code no-error .

if p-button-list <> {&buttons-for-move}
then do:
    define new shared temp-table tt-goods no-undo like ub.goods.
    define new shared temp-table tt-clients no-undo like ub.clients.
end.

define variable v-root-code                 as integer          no-undo.
define variable v-found-grp-num             as integer  init 0  no-undo.
define variable v-full-search-string        as character        no-undo.
define variable v-full-search-next          as logical  init no no-undo.
define variable v-full-search-start-code    as integer          no-undo.
define variable v-cli-name                  as character        no-undo.
define variable print-option as character no-undo.
define variable gds-grp-row as integer init 1 no-undo.  /* текущая запись gds-grp для перерисовки дерева */
define variable v-from-b-gds as logical no-undo .
define variable v-old-recid-list as character no-undo .
define variable v-old-recid as recid no-undo .

define variable v-current-arm-code          as character    no-undo.
define variable v-current-store-type        as character    no-undo.
define variable v-current-store-code        as integer      no-undo.
define variable v-current-host-code         as integer      no-undo.

define variable is-flora     as character no-undo .   /* для чтения параметра конфигурации */
define variable par-type     as character no-undo.    /* тип параметра конфигурации */
define variable v-obj-host-code as integer   no-undo . /* для чтения параметра конфигурации */

define variable p-sts   as integer   no-undo .
define variable p-rid-list                    as character no-undo .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-log as logical   no-undo .

define variable mark-str  as character no-undo.
define variable v-doc-rec as recid no-undo.
define variable filter-point as character no-undo init "Спецификация" .
define variable filter-point0 as character no-undo init "Состав_Спецификации" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .
define variable gds-rec as recid no-undo .
define variable v-indicator-life-gds like  ub.gds-obj-prop.gdop-igt        column-label "ИЖТ" format "x(25)" no-undo .
define variable v-assort-min         like  ub.gds-obj-prop.gdop-assort-min column-label "AMin" format "*/ " no-undo .
define variable p-name as character no-undo .
define variable v-ask as logical   no-undo .
define variable v-list-mat as character no-undo init "" .


define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define variable varschartic like ub.price-list.artic initial " " no-undo.
define variable ref-list    as character no-undo.
define buffer pos_contract for ub.contract.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_contract no-lock where ~
                                  recid(pos_contract) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи AM" skip~
                            string(if avail pos_contract ~
                                    then  substitute("Вн код AM: &1" ~
                                                    , pos_contract.contract-code) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dlg-grp
&Scoped-define BROWSE-NAME br-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_grplib_grp buf_contract-specif ~
buf_goods

/* Definitions for BROWSE br-list                                       */
&Scoped-define FIELDS-IN-QUERY-br-list temp_grplib_grp.name temp_grplib_grp.cli-type temp_grplib_grp.min-marg temp_grplib_grp.max-marg
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-list temp_grplib_grp.cli-type
&Scoped-define ENABLED-TABLES-IN-QUERY-br-list temp_grplib_grp
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-list temp_grplib_grp
&Scoped-define SELF-NAME br-list
&Scoped-define QUERY-STRING-br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name
&Scoped-define OPEN-QUERY-br-list OPEN QUERY {&SELF-NAME} FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
&Scoped-define TABLES-IN-QUERY-br-list temp_grplib_grp
&Scoped-define FIRST-TABLE-IN-QUERY-br-list temp_grplib_grp


/* Definitions for BROWSE spec-List                                     */
&Scoped-define FIELDS-IN-QUERY-spec-List {&cop-l0} {&cop-l1} {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l2} {&cop-l3} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10} {&cop-l11} {&cop-l12} {&cop-l13} {&cop-l14} buf_goods.grp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-spec-List {&cop-l2}
&Scoped-define SELF-NAME spec-List
&Scoped-define QUERY-STRING-spec-List FOR EACH buf_contract-specif NO-LOCK, ~
                                   first buf_goods no-lock where                             buf_goods.gds-code =  buf_contract-specif.gds-code and                             ( temp_grplib_grp.level = 0 OR                             ( buf_goods.grp-name begins temp_grplib_grp.full-name ))                             indexed-reposition
&Scoped-define OPEN-QUERY-spec-List OPEN QUERY {&SELF-NAME} FOR EACH buf_contract-specif NO-LOCK, ~
                                   first buf_goods no-lock where                             buf_goods.gds-code =  buf_contract-specif.gds-code and                             ( temp_grplib_grp.level = 0 OR                             ( buf_goods.grp-name begins temp_grplib_grp.full-name ))                             indexed-reposition.
&Scoped-define TABLES-IN-QUERY-spec-List buf_contract-specif buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-spec-List buf_contract-specif
&Scoped-define SECOND-TABLE-IN-QUERY-spec-List buf_goods


/* Definitions for DIALOG-BOX Dlg-grp                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dlg-grp ~
    ~{&OPEN-QUERY-br-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-verify b-recalc B-print b-help ~
b-expand b-expand-all fi-search b-find-by-full-name b-find-by-substring ~
b-search br-list b-mark B-add b-chg B-del B-add-AssMatr B-del-AssMatr b-all ~
b-prc FILL-prc b-all-2 b-prc-2 FILL-prc-2 RADIO-find sch-str spec-List ~
mark-num
&Scoped-Define DISPLAYED-OBJECTS fi-search b-prc FILL-prc b-prc-2 ~
FILL-prc-2 RADIO-find sch-str mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-add-AssMatr
     LABEL "Добав в &АМ"
     SIZE 11.5 BY 1 TOOLTIP "Добавить в Ассортиментные матрицы выделенный товар".

DEFINE BUTTON b-all
     LABEL "&Применить"
     SIZE 10 BY 1.

DEFINE BUTTON b-all-2
     LABEL "&Применить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del-AssMatr
     LABEL "Удал из &АМ"
     SIZE 11.5 BY 1 TOOLTIP "Удалить из Ассортиментных матриц выбранные товары".

DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход"
     BGCOLOR 8 .

DEFINE BUTTON b-expand
     LABEL ">>"
     SIZE 3.5 BY 1.13.

DEFINE BUTTON b-expand-all
     LABEL ">>-->>"
     SIZE 7.5 BY 1.13.

DEFINE BUTTON b-find-by-full-name
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Продолжить до полного имени (CTRL-D)"
     BGCOLOR 8 .

DEFINE BUTTON b-find-by-substring
     LABEL "?"
     SIZE 3 BY 1 TOOLTIP "Найти подстроку во всех группах (CTRL-S)"
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 3 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 2.5 BY 1.

DEFINE BUTTON b-recalc
     LABEL "Пе&ресчитать"
     SIZE 13.5 BY 1 TOOLTIP "Пересчитать количество товара по всем уровням"
     BGCOLOR 8 .

DEFINE BUTTON b-search
     LABEL "Поиск"
     SIZE 10 BY 1.04
     BGCOLOR 8 .

DEFINE BUTTON b-verify
     LABEL "Проверить"
     SIZE 13.5 BY 1 TOOLTIP "Проверить ограниечения по уровням групп"
     BGCOLOR 8 .

DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 69.75 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE FILL-prc AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-prc-2 AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 5.5 BY 1 NO-UNDO.

DEFINE VARIABLE sch-str AS CHARACTER FORMAT "X(256)"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RADIO-find AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "коду", 1,
"артикулу", 2,
"названию", 3,
"нач. слова", 4
     SIZE 43 BY 1 NO-UNDO.

DEFINE VARIABLE b-prc AS LOGICAL INITIAL no
     LABEL "Допустимый % отклонения цены в договоре:"
     VIEW-AS TOGGLE-BOX
     SIZE 43 BY 1 NO-UNDO.

DEFINE VARIABLE b-prc-2 AS LOGICAL INITIAL no
     LABEL "Допустимый % отклонения цены в договоре:"
     VIEW-AS TOGGLE-BOX
     SIZE 43 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-list FOR
      temp_grplib_grp SCROLLING.

DEFINE QUERY spec-List FOR
      buf_contract-specif,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-list Dlg-grp _FREEFORM
  QUERY br-list DISPLAY
      temp_grplib_grp.name          format "X(63)"       COLUMN-label "Наименование группы! "
      temp_grplib_grp.cli-type                           COLUMN-label "Ограничение!по группе"
      temp_grplib_grp.min-marg                           COLUMN-label "По нижним!уровням"
      temp_grplib_grp.max-marg                           COLUMN-label "Количество!в группе"
      ENABLE
      temp_grplib_grp.cli-type
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 7.63.

DEFINE BROWSE spec-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS spec-List Dlg-grp _FREEFORM
  QUERY spec-List DISPLAY
      {&cop-l0}    COLUMN-LABEL {&col-l0}  Format "X(1)"
     {&cop-l1}    COLUMN-LABEL {&col-l1}  Format "X(16)"
     {&cop-l4}    COLUMN-LABEL {&col-l4}  format "x(50)"
     {&cop-l5}    COLUMN-LABEL {&col-l5}  format ">,>>>,>>>,>>9.99"
     {&cop-l6}    COLUMN-LABEL {&col-l6}  Format "->>>>9.99"
     {&cop-l7}    COLUMN-LABEL {&col-l7}  Format "->>>>9.99"
     {&cop-l2}    COLUMN-LABEL {&col-l2}  Format "x(16)"
     {&cop-l3}    COLUMN-LABEL {&col-l3}  Format "x(18)"
     {&cop-l8}    COLUMN-LABEL {&col-l8}
     {&cop-l9}    COLUMN-LABEL {&col-l9}
     {&cop-l10}   COLUMN-LABEL {&col-l10}
     {&cop-l11}   COLUMN-LABEL {&col-l11} format ">>>,>>>,>>>,>>>,>>9.99"
     {&cop-l12}   COLUMN-LABEL {&col-l12} Format ">>9.9"
     {&cop-l13}   COLUMN-LABEL {&col-l13}
     {&cop-l14}   COLUMN-LABEL {&col-l14}
     buf_goods.grp-name  COLUMN-LABEL "Группа"
     enable {&cop-l2}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 99 BY 7.83.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dlg-grp
     b-exit AT ROW 1 COL 1
     b-verify AT ROW 1 COL 66.13 WIDGET-ID 22
     b-recalc AT ROW 1 COL 79.88 WIDGET-ID 14
     B-print AT ROW 1 COL 94 WIDGET-ID 12
     b-help AT ROW 1 COL 96.5
     b-expand AT ROW 2.08 COL 1.63
     b-expand-all AT ROW 2.08 COL 5.13
     fi-search AT ROW 2.08 COL 13.38 NO-LABEL
     b-find-by-full-name AT ROW 2.08 COL 83.38
     b-find-by-substring AT ROW 2.08 COL 86.38
     b-search AT ROW 2.08 COL 89.38
     br-list AT ROW 3.38 COL 1.88
     b-mark AT ROW 11.04 COL 1.63
     B-add AT ROW 11.04 COL 4.75 WIDGET-ID 24
     b-chg AT ROW 11.04 COL 14.75 WIDGET-ID 28
     B-del AT ROW 11.04 COL 24.75 WIDGET-ID 30
     B-add-AssMatr AT ROW 11.04 COL 34.88 WIDGET-ID 2
     B-del-AssMatr AT ROW 11.04 COL 46.38 WIDGET-ID 4
     b-all AT ROW 12.04 COL 52 WIDGET-ID 26
     b-prc AT ROW 12.08 COL 1.63 WIDGET-ID 32
     FILL-prc AT ROW 12.08 COL 42.13 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     b-all-2 AT ROW 13.25 COL 51.88 WIDGET-ID 48
     b-prc-2 AT ROW 13.29 COL 1.5 WIDGET-ID 50
     FILL-prc-2 AT ROW 13.29 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     RADIO-find AT ROW 14.58 COL 10.5 NO-LABEL WIDGET-ID 36
     sch-str AT ROW 14.58 COL 52 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     spec-List AT ROW 15.71 COL 1 WIDGET-ID 100
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     "Поиск по" VIEW-AS TEXT
          SIZE 9 BY 1 AT ROW 14.5 COL 1.63 WIDGET-ID 44
          FGCOLOR 4
     SPACE(89.36) SKIP(8.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Спецификация по группам товаров".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_contract-specif B "?" ? ub ub.contract-specif
      TABLE: buf_goods B "?" ? ub ub.goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dlg-grp
   FRAME-NAME                                                           */
/* BROWSE-TAB br-list b-search Dlg-grp */
/* BROWSE-TAB spec-List sch-str Dlg-grp */
ASSIGN
       FRAME Dlg-grp:SCROLLABLE       = FALSE
       FRAME Dlg-grp:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-search IN FRAME Dlg-grp
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-list
/* Query rebuild information for BROWSE br-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-list */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE spec-List
/* Query rebuild information for BROWSE spec-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_contract-specif NO-LOCK,
                            first buf_goods no-lock where
                            buf_goods.gds-code =  buf_contract-specif.gds-code and
                            ( temp_grplib_grp.level = 0 OR
                            ( buf_goods.grp-name begins temp_grplib_grp.full-name ))
                            indexed-reposition.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE spec-List */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dlg-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON ENDKEY OF FRAME Dlg-grp /* Спецификация по группам товаров */
DO:
    run gbl/markqwa.p (
                           input b-mark:visible
                          , input p-recid-list) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON WINDOW-CLOSE OF FRAME Dlg-grp /* Спецификация по группам товаров */
DO:
  apply "end-error":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dlg-grp
ON CHOOSE OF B-add IN FRAME Dlg-grp /* Добавить */
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
  run openbr in this-procedure (yes, no, '':u).
  run recalc-add.
  run recalc-marg-ass.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-AssMatr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-AssMatr Dlg-grp
ON CHOOSE OF B-add-AssMatr IN FRAME Dlg-grp /* Добав в АМ */
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


&Scoped-define SELF-NAME b-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-all Dlg-grp
ON CHOOSE OF b-all IN FRAME Dlg-grp /* Применить */
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

  message "Вы действительно хотите изменить % по всей спецификации ?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
  if g-log = no then return no-apply.

  assign FILL-prc .
  do transaction :
    for each  ub.contract-specif exclusive-lock where
              ub.contract-specif.host-code = p-host-code and
              ub.contract-specif.contract-num = p-contract-num :
      assign  ub.contract-specif.prc = FILL-prc .
    end.
    assign is-new = yes .
  end.
  run openbr in this-procedure (yes, no, '':u).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-all-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-all-2 Dlg-grp
ON CHOOSE OF b-all-2 IN FRAME Dlg-grp /* Применить */
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

  message "Вы действительно хотите изменить % по всей спецификации ?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
  if g-log = no then return no-apply.

  assign FILL-prc-2 .
  do transaction :
    for each  contract-specif exclusive-lock where
              contract-specif.host-code = p-host-code and
              contract-specif.contract-num = p-contract-num
     :
      run write-prc-min in this-procedure (
          contract-specif.contract-num  ,
          contract-specif.host-code     ,
          contract-specif.gds-code      ,
          FILL-prc-2 ).
    end.
    assign is-new = yes .
  end.
  run openbr in this-procedure (yes, no, '':u).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dlg-grp
ON CHOOSE OF b-chg IN FRAME Dlg-grp /* Изменить */
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

  if mark-num > 1 then do: /* выделено много */
    if b-prc then assign v-prc = FILL-prc .
    else          assign v-prc = 0 .
    if b-prc-2 then assign v-prc-2 = FILL-prc-2 .
    else          assign v-prc-2 = 0 .
    assign
      v-price    = 0
      v-vat-type = ?
      v-qnty     = 0
      v-cli-base-rate = 0
      v-cli-base-rate-ord = 0
      v-unit-cli-ord      = ""
      v-cli-base-rate-rcv = 0
      v-unit-cli-rcv      = ""
      v-unit-cli = ""
      v-vat-pc   = 0
      v-bonus    =  0
    .


    run str/contspc1.w
       ( input Parparentproc,
         input {&update},
         input 0, // gds-code для выбора v-unit-cli
         input "",
         input "",
         "Список товаров",
         ""   ,
         input-output v-price,
         input-output v-prc,
         input-output v-prc-2,
         input-output v-vat-type,
         input-output v-qnty,
         input-output v-cli-base-rate,
         input-output v-vat-pc,
         input-output v-unit-cli,
         input-output v-unit-cli-ord ,
         input-output v-cli-base-rate-ord ,
         input-output v-unit-cli-rcv,
         input-output v-cli-base-rate-rcv,
         input-output v-bonus,
         input-output v-retro-bonus,
output v-res ) .

    if v-res then do:
      do transaction :
        for each temp-conn :
          find first ub.contract-specif exclusive-lock where recid(ub.contract-specif) = temp-conn.ri .
        if v-cli-base-rate <> ? then do:
            find first buf_goods no-lock where buf_goods.gds-code = ub.contract-specif.gds-code .
            if v-cli-base-rate <> buf_goods.cli-base-rate and
                     v-unit-cli = buf_goods.unit-base then do:
              message "Товар: " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
                       "Единица измерения совпадает с базовой, а коэффициент нет. Изменение по товару не произведено." skip
              view-as alert-box error.
              next.
            end.
            assign
              ub.contract-specif.cli-base-rate = v-cli-base-rate.
          end.
          if v-cli-base-rate-ord <> ? then do:
            find first buf_goods no-lock where buf_goods.gds-code = ub.contract-specif.gds-code .
            if v-cli-base-rate-ord <> buf_goods.cli-base-rate and
                     v-unit-cli-ord = buf_goods.unit-base then do:
              message "Товар: " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
                       "Единица измерения заказа совпадает с базовой, а коэффициент нет. Изменение по товару не произведено." skip
              view-as alert-box error.
              next.
            end.
            assign
              ub.contract-specif.cli-base-rate-ord = v-cli-base-rate-ord.
          end.
          if v-cli-base-rate-rcv <> ? then do:
            find first buf_goods no-lock where buf_goods.gds-code = ub.contract-specif.gds-code .
            if v-cli-base-rate-rcv <> buf_goods.cli-base-rate and
                     v-unit-cli-ord = buf_goods.unit-base then do:
              message "Товар: " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
                       "Единица измерения поставки совпадает с базовой, а коэффициент нет. Изменение по товару не произведено." skip
              view-as alert-box error.
              next.
            end.
            assign
              ub.contract-specif.cli-base-rate-rcv = v-cli-base-rate-rcv.
          end.

          if v-price <> ? then do:
            assign
              ub.contract-specif.price-cli = v-price.
          end.
          if v-prc <> ? then do:
            assign
              ub.contract-specif.prc = v-prc.
          end.
          if v-vat-type <> ? then do:
            assign
              ub.contract-specif.vat-type  = v-vat-type.
          end.
          if v-qnty <> ? then do:
            assign
              ub.contract-specif.qnty      = v-qnty
              ub.contract-specif.sum-cli   = v-price * v-qnty.
          end.
          if v-vat-pc <> ? then do:
            assign
              ub.contract-specif.VAT-pc    = v-vat-pc.
          end.
          if v-unit-cli <> ? then do:
            assign
              ub.contract-specif.unit-cli          = v-unit-cli.
          end.
          if v-unit-cli-ord <> ? then do:
            assign
              ub.contract-specif.unit-cli-ord      = v-unit-cli-ord.
          end.
          if v-unit-cli-rcv <> ? then do:
            assign
              ub.contract-specif.unit-cli-rcv      = v-unit-cli-rcv.
          end.
          assign
            is-new = yes
          .
           run write-bonus (
                buf_contract.contract-code  ,
                buf_contract.host-code     ,
                ub.contract-specif.gds-code      ,
                v-bonus ).
           run write-prc-min in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               contract-specif.gds-code      ,
               v-prc-2 ).
           run write-retro-bonus in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               contract-specif.gds-code      ,
               v-retro-bonus ).
        end.
      end.
      run proc-sum .
      RUN OpenBr(yes, no, '':U).
    end.
  end.
  else do:
    if mark-num = 1 then do:
      find first temp-conn .
      find first buf_contract-specif no-lock where recid( buf_contract-specif) = temp-conn.ri .
    end.
    assign
      v-price    = buf_contract-specif.price-cli
      v-prc      = buf_contract-specif.prc
      v-vat-type = buf_contract-specif.vat-type
      v-qnty     = buf_contract-specif.qnty
      v-cli-base-rate = buf_contract-specif.cli-base-rate
      v-unit-cli      = buf_contract-specif.unit-base
      v-vat-pc        = buf_contract-specif.VAT-pc
      v-cli-base-rate-ord = buf_contract-specif.cli-base-rate-ord
      v-unit-cli-ord      = buf_contract-specif.unit-cli-ord
      v-cli-base-rate-rcv = buf_contract-specif.cli-base-rate-rcv
      v-unit-cli-rcv      = buf_contract-specif.unit-cli-rcv

    .
    run read-bonus (
        input  buf_contract.contract-code  ,
        input  buf_contract.host-code     ,
        input  buf_contract-specif.gds-code      ,
        output v-bonus  ) .
    run read-prc-min in this-procedure (
        contract-specif.contract-num  ,
        contract-specif.host-code     ,
        contract-specif.gds-code      ,
        v-prc-2 ).
    run read-retro-bonus in this-procedure (
        contract-specif.contract-num  ,
        contract-specif.host-code     ,
        contract-specif.gds-code      ,
        v-retro-bonus ).

    if b-prc then assign v-prc = FILL-prc .
    if b-prc-2 then assign v-prc-2 = FILL-prc-2 .
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
                       , output v-res) .
    if v-res then do:
run read-bonus (
        input  buf_contract.contract-code  ,
        input  buf_contract.host-code     ,
        input  buf_contract-specif.gds-code      ,
        output old-bonus  ) .
    run read-prc-min in this-procedure (
        buf_contract.contract-code  ,
        buf_contract.host-code     ,
        buf_contract-specif.gds-code      ,
        output old-prc-min ).
    run read-retro-bonus in this-procedure (
        buf_contract.contract-code  ,
        buf_contract.host-code     ,
        buf_contract-specif.gds-code      ,
        output old-retro-bonus ).

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
            find first buf_goods no-lock where buf_goods.gds-code = ub.contract-specif.gds-code .
            if v-cli-base-rate <> buf_goods.cli-base-rate and
                     v-unit-cli = buf_goods.unit-base then do:
              message "Товар: " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
                       "Единица измерения совпадает с базовой, а коэффициент нет. Изменение по товару не произведено." skip
              view-as alert-box error.
              undo, return no-apply.
            end.
            assign
              ub.contract-specif.cli-base-rate = v-cli-base-rate.
          end.
          if v-cli-base-rate-ord <> ? then do:
            find first buf_goods no-lock where buf_goods.gds-code = ub.contract-specif.gds-code .
            if v-cli-base-rate-ord <> buf_goods.cli-base-rate and
                     v-unit-cli-ord = buf_goods.unit-base then do:
              message "Товар: " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
                       "Единица измерения заказа совпадает с базовой, а коэффициент нет. Изменение по товару не произведено." skip
              view-as alert-box error.
              undo, return no-apply.
            end.
            assign
              ub.contract-specif.cli-base-rate-ord = v-cli-base-rate-ord.
          end.
          if v-cli-base-rate-rcv <> ? then do:
            find first buf_goods no-lock where buf_goods.gds-code = ub.contract-specif.gds-code .
            if v-cli-base-rate-rcv <> buf_goods.cli-base-rate and
                     v-unit-cli-ord = buf_goods.unit-base then do:
              message "Товар: " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name skip
                       "Единица измерения поставки совпадает с базовой, а коэффициент нет. Изменение по товару не произведено." skip
              view-as alert-box error.
              undo, return no-apply.
            end.
            assign
              ub.contract-specif.cli-base-rate-rcv = v-cli-base-rate-rcv.
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
           run write-bonus (
                ub.contract-specif.contract-num ,
                ub.contract-specif.host-code   ,
                ub.contract-specif.gds-code    ,
                v-bonus ) .
           run write-prc-min in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               contract-specif.gds-code      ,
               v-prc-2 ).
           run write-retro-bonus in this-procedure (
               buf_contract.contract-code ,
               buf_contract.host-code     ,
               contract-specif.gds-code      ,
               v-retro-bonus ).

        end.
      end.
      run proc-sum .
      RUN OpenBr(yes, no, '':U).
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dlg-grp
ON CHOOSE OF B-del IN FRAME Dlg-grp /* Удалить */
DO:
run save-attr in this-procedure .
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

  run proc-del .
  run proc-sum .
  run recalc-add.
  run recalc-marg-ass.
  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-AssMatr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-AssMatr Dlg-grp
ON CHOOSE OF B-del-AssMatr IN FRAME Dlg-grp /* Удал из АМ */
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


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dlg-grp
ON CHOOSE OF b-exit IN FRAME Dlg-grp /* Выход */
DO:
for each temp_grplib_grp :
    find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
        if available temp_cons then do:
        if temp_cons.max-marg <>  temp_grplib_grp.max-marg then do:
        assign
            temp_cons.full-name  = temp_grplib_grp.full-name
            temp_cons.node-code  = temp_grplib_grp.node-code
            temp_cons.upper-code = temp_grplib_grp.upper-code
            temp_cons.min-marg   = temp_grplib_grp.min-marg
            temp_cons.max-marg   = temp_grplib_grp.max-marg
            temp_cons.cli-type   = temp_grplib_grp.cli-type
        .
        end.
        end.
end.

define variable  v-str as character no-undo .
define variable v-i as integer   no-undo .

v-str = "".
v-i =0.
for each temp_cons where int(temp_cons.cli-type) < int(temp_cons.min-marg)
 and int(temp_cons.cli-type) <> ?
 and temp_cons.cli-type <> ""
 and int(temp_cons.min-marg) <> ?
:
  v-i = v-i + 1.
  v-str = v-str + trim(temp_cons.full-name) + " ограничение : " + temp_cons.cli-type + " (должно быть >= " + temp_cons.min-marg + ")" + {&new-line} .
end.

for each temp_cons where int(temp_cons.cli-type) < int(temp_cons.max-marg)
 and int(temp_cons.cli-type) <> ?
 and temp_cons.cli-type <> ""
 and int(temp_cons.max-marg) <> ?
:
  v-i = v-i + 1.
  v-str = v-str + trim(temp_cons.full-name) + " ограничение : " + temp_cons.cli-type + " (а товара в группе " + temp_cons.max-marg + " !)" + {&new-line} .
end.

if v-i <> 0 then do:
    message "Внимание ! Ограничения по Спецификации назначены некорректно !!!" view-as alert-box error .
    run gbl/notes.w ({&lookup},input-output v-str) .
    return no-apply .
end.

find first temp_grplib_grp no-error .
    define variable v-gds-grp-recid     as recid             no-undo.
    run get-current-recid in this-procedure (
          input temp_grplib_grp.node-code
        , output v-gds-grp-recid
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена группа для восстановления"
          skip "предыдущего состояния справочника групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.

    /* run gbl/markqwa.p (
            input b-mark:visible
          , input p-recid-list) no-error.
    if error-status:error then return no-apply.
    */
    assign
        gds-grp-row  = v-gds-grp-recid
        p-recid-list = ""
    .
    assign
    v-uf-List_ = (if gds-grp-row = ? then {&question-mark} else string(gds-grp-row))
    .
    run uf-set in this-procedure(
        input  {&uf-gds-grp-p}
        ,input  g#userid
        ,input v-uf-List_
        ,input v-uf-Naim
        ,input v-uf-print-graft
        ,input v-uf-sort-gr
        ,input v-uf-type-price
        ,input v-uf-type-val
    )  no-error .

/* Если корректировали Ограничения */
if temp_grplib_grp.cli-type:read-only in browse br-list = false then do:
    run save-alla in this-procedure  .
  end.
  apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-expand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-expand Dlg-grp
ON CHOOSE OF b-expand IN FRAME Dlg-grp /* >> */
DO:
    if temp_grplib_grp.node-code = v-root-code
    then do:
        run collapse-all-on-first-level in this-procedure no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка операции с деревом групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
    if temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_grplib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-expand-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-expand-all Dlg-grp
ON CHOOSE OF b-expand-all IN FRAME Dlg-grp /* >>-->> */
DO:
    { gbl/working.i }
    run expand-all-from-current in this-procedure (
        input temp_grplib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при раскрытии дерева групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        { gbl/stopwork.i }
        undo, return no-apply .
    end.
    { gbl/stopwork.i }
    RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-find-by-full-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name Dlg-grp
ON CHOOSE OF b-find-by-full-name IN FRAME Dlg-grp /* + */
DO:
    define variable v-new-name as character no-undo.

    run grplib-expand-name in this-procedure (
          input fi-search :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search :screen-value
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name Dlg-grp
ON LEAVE OF b-find-by-full-name IN FRAME Dlg-grp /* + */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-find-by-substring
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-substring Dlg-grp
ON CHOOSE OF b-find-by-substring IN FRAME Dlg-grp /* ? */
DO:
    define variable v-new-name      as character    no-undo.
    define variable v-new-code      as integer      no-undo.
    define variable v-err-message   as character    no-undo.

    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
    run grplib-analyze-grp-name in this-procedure (
          input v-full-search-string
        , input -1
        , output v-err-message
    ).
    if v-err-message = "":U
    then do:
        { gbl/working.i }
        run grplib-find-by-substring in this-procedure (
            input v-full-search-start-code
            , input v-full-search-string
            , output v-new-code
            , output v-new-name
        ) no-error.
        if error-status :error
        then do:
            { gbl/stopwork.i }
            message return-value.
            undo, return no-apply.
        end.
        { gbl/stopwork.i }
        if v-new-code = 0
        then do:
            message
                skip "Не найдена строка '" v-full-search-string "' в имени группы."
            view-as alert-box information
            title "Поиск завершен".
            assign
                v-new-name               = fi-search :screen-value
                v-full-search-string     = ""
                v-full-search-next       = no
                v-full-search-start-code = 0
            .
        end.
        else do:
            assign
                v-full-search-start-code = v-new-code
            .
        end.
        assign
            fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
            fi-search :cursor-offset = length( v-new-name ) + 1
        .
    end.        /* if v-err-message = "":U */
    else do:
        message
            v-err-message
            skip(1)
            "Поиск в названиях групп производится по подстроке,"
            skip "введённой в поле названия группы."
        view-as alert-box information.
    end.        /* if v-err-message <> "":U */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-substring Dlg-grp
ON LEAVE OF b-find-by-substring IN FRAME Dlg-grp /* ? */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dlg-grp
ON CHOOSE OF b-mark IN FRAME Dlg-grp /* * */
DO:
  if not available buf_contract-specif then return no-apply.

  find first temp-conn where temp-conn.ri = recid( buf_contract-specif ) no-error  .
  if available temp-conn then do:
    delete temp-conn .
    assign  mark-num = mark-num - 1 .
  end.
  else do:
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prc Dlg-grp
ON VALUE-CHANGED OF b-prc IN FRAME Dlg-grp /* Допустимый % отклонения цены в договоре: */
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

  assign b-prc .
  if b-prc then ENABLE FILL-prc b-all WITH FRAME Dlg-grp.
  else  do:
    assign FILL-prc = 0 .
    DISABLE FILL-prc b-all WITH FRAME Dlg-grp.
    if dec(FILL-prc:screen-value) <> FILL-prc then assign is-new1 = yes .
  end.
  display FILL-prc b-all WITH FRAME Dlg-grp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prc-2 Dlg-grp
ON VALUE-CHANGED OF b-prc-2 IN FRAME Dlg-grp /* Допустимый % отклонения цены в договоре: */
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

  assign b-prc-2 .
  if b-prc-2 then ENABLE FILL-prc-2 b-all-2 WITH FRAME Dlg-grp.
  else  do:
    assign FILL-prc-2 = 0 .
    DISABLE FILL-prc-2 b-all-2 WITH FRAME Dlg-grp.
    if dec(FILL-prc-2:screen-value) <> FILL-prc-2 then assign is-new1 = yes .
  end.
  display FILL-prc-2 b-all-2 WITH FRAME Dlg-grp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dlg-grp
ON CHOOSE OF B-print IN FRAME Dlg-grp /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-recalc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-recalc Dlg-grp
ON CHOOSE OF b-recalc IN FRAME Dlg-grp /* Пересчитать */
DO:
message "Запускать утилиту пересчета ассортимента по каждой группе ? Это займет время."
 view-as alert-box question
       BUTTONS yes-no
      update v-ok as logical.
  if not v-ok then return .

   run utl/uspemgrp.p ( input p-contract-num,input p-host-code ) no-error .
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
run recalc-marg-ass.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dlg-grp
ON CHOOSE OF b-search IN FRAME Dlg-grp /* Поиск */
DO:
    define variable v-found    as logical      no-undo.

    run find-grp-in-browse in this-procedure (
          input fi-search :screen-value
        , output v-found
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка поиска группы в списке."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply.
    end.
    if v-found = no
    then do:
        message
          skip "Группа не найдена."
        view-as alert-box information.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dlg-grp
ON LEAVE OF b-search IN FRAME Dlg-grp /* Поиск */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-verify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-verify Dlg-grp
ON CHOOSE OF b-verify IN FRAME Dlg-grp /* Проверить */
DO:

message "Запускать утилиту проверки проставленных ограничений по всем уровням ? "
 view-as alert-box question
       BUTTONS yes-no
      update v-ok as logical.
  if not v-ok then return .

/* 4444 */
define variable v-str as character no-undo .
define variable v-i as integer   no-undo .

v-str = "" .
v-i   = 0  .

for each temp_grplib_grp :
    find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
        if not available temp_cons then create temp_cons.
        assign
            temp_cons.full-name  = temp_grplib_grp.full-name
            temp_cons.node-code  = temp_grplib_grp.node-code
            temp_cons.upper-code = temp_grplib_grp.upper-code
            temp_cons.min-marg   = temp_grplib_grp.min-marg
            temp_cons.max-marg   = temp_grplib_grp.max-marg
            temp_cons.cli-type   = temp_grplib_grp.cli-type
        .
end.


  for each temp_cons where
          int(temp_cons.cli-type) < int(temp_cons.min-marg)
      and int(temp_cons.cli-type) <> ?
      and temp_cons.cli-type <> ""
      and int(temp_cons.min-marg) <> ?
      :
        v-i = v-i + 1.
        v-str = v-str + trim(temp_cons.full-name) + " ограничение : " + temp_cons.cli-type + " должно быть >= " + temp_cons.min-marg + {&new-line} .
  end.

for each temp_cons where
        int(temp_cons.cli-type) < int(temp_cons.max-marg)
    and int(temp_cons.cli-type) <> ?
    and temp_cons.cli-type <> ""
    and int(temp_cons.max-marg) <> ?
    :
  v-i = v-i + 1.
  v-str = v-str + trim(temp_cons.full-name) + " ограничение : " + temp_cons.cli-type + " (а товара в группе " + temp_cons.max-marg + " !)" + {&new-line} .
end.


   if v-i > 0 then
   run gbl/notes.w ({&lookup},input-output v-str) .
   else message "Все ОК!" view-as alert-box information .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-list
&Scoped-define SELF-NAME br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON + OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось раскрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.

END.

/*-------------------------------------------------------*/
on leave of temp_grplib_grp.cli-type in browse br-list do :
  define variable i as integer   no-undo .
  i = int (int (temp_grplib_grp.cli-type:screen-value in browse br-list ))  no-error .
  if error-status :error then return no-apply .
  if i < 0 then return no-apply .
  if i = 0 and lookup(temp_grplib_grp.cli-type:screen-value in browse br-list , "+,-,*" ) > 0 then return no-apply .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-grp_update':U
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
 if not v-log then do:
    temp_grplib_grp.cli-type:read-only in browse br-list = true .
    return no-apply .
 end.

   define variable loc#log as logical   no-undo .
    temp_grplib_grp.cli-type = temp_grplib_grp.cli-type:screen-value in browse {&browse-name} .

    if temp_grplib_grp.cli-type <> ? and
       temp_grplib_grp.cli-type <> ""  and
       int(temp_grplib_grp.min-marg) <> 0 and
           temp_grplib_grp.min-marg  <> ? and
           temp_grplib_grp.min-marg  <> "" and
       int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.min-marg) then do:
         message substitute(" Ограничение должно быть не меньше ограничения по нижним уровням &1" ,temp_grplib_grp.min-marg ) .
         return no-apply.
       end.

      find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
      assign
          temp_cons.cli-type  = temp_grplib_grp.cli-type
          temp_cons.full-name  = temp_grplib_grp.full-name
      .
    loc#log = BR-list:select-focused-row( ) IN FRAME {&FRAME-NAME}.
    loc#log = BR-list:refresh() .

/* Запись ограничения */
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp-obj-attr exclusive-lock where
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr} and
            buf_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
            buf_gds-grp-obj-attr.obj-code  = p-host-code and
            buf_gds-grp-obj-attr.host-code = 0 and
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
if not available buf_gds-grp-obj-attr then do:
    create buf_gds-grp-obj-attr.
          assign
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr}
            buf_gds-grp-obj-attr.obj-type  = string(p-contract-num)
            buf_gds-grp-obj-attr.obj-code  = p-host-code
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code
            .
 end.
 assign
    buf_gds-grp-obj-attr.attr-value = temp_grplib_grp.cli-type
    .
run recalc-lim.

end.

on return of temp_grplib_grp.cli-type in browse br-list do :
  define variable loc#log as logical   no-undo .
  define variable i as integer   no-undo .
  i = int (temp_grplib_grp.cli-type:screen-value in browse br-list)  no-error .
  if error-status :error then return no-apply .
  if i < 0 then return no-apply .
  if i = 0 and lookup(temp_grplib_grp.cli-type:screen-value in browse br-list , "+,-,*" ) > 0 then return no-apply .

    temp_grplib_grp.cli-type = temp_grplib_grp.cli-type:screen-value in browse {&browse-name} .
    if temp_grplib_grp.cli-type <> ? and
       temp_grplib_grp.cli-type <> ""  and
       int(temp_grplib_grp.min-marg) <> 0 and
           temp_grplib_grp.min-marg  <> ? and
           temp_grplib_grp.min-marg  <> "" and
       int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.min-marg) then do:
         message substitute(" Ограничение должно быть не меньше ограничения по нижним уровням &1" ,temp_grplib_grp.min-marg ) .
         return no-apply.
       end.

      find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
      assign
          temp_cons.cli-type  = temp_grplib_grp.cli-type
          temp_cons.full-name  = temp_grplib_grp.full-name
      .
/* Запись ограничения */
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp-obj-attr exclusive-lock where
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr} and
            buf_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
            buf_gds-grp-obj-attr.obj-code  = p-host-code and
            buf_gds-grp-obj-attr.host-code = 0 and
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
if not available buf_gds-grp-obj-attr then do:
    create buf_gds-grp-obj-attr.
          assign
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr}
            buf_gds-grp-obj-attr.obj-type  = string(p-contract-num)
            buf_gds-grp-obj-attr.obj-code  = p-host-code
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code
            .
 end.
 assign
    buf_gds-grp-obj-attr.attr-value = temp_grplib_grp.cli-type
    .
  run recalc-lim.
    loc#log = BR-list:refresh() IN FRAME {&FRAME-NAME}.
    loc#log = BR-list:select-next-row( ) .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON - OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark = {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось закрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON END OF br-list IN FRAME Dlg-grp
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure ( output v-row-amount ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при подсчете строк списка групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    reposition br-list to row v-row-amount.
    RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON HOME OF br-list IN FRAME Dlg-grp
DO:
    reposition br-list to row 1.
    RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dlg-grp
DO:
 if temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_grplib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON RETURN OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_grplib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON ROW-DISPLAY OF br-list IN FRAME Dlg-grp
DO:
  if int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.min-marg)
      and int(temp_grplib_grp.cli-type) <> ?
      and temp_grplib_grp.cli-type <> ""
      and int(temp_grplib_grp.min-marg) <> ?
  then do:
    temp_grplib_grp.cli-type:bgcolor in browse  br-list = 12 /* red */ .
  end.
  else do:
    temp_grplib_grp.cli-type:bgcolor in browse  br-list = ? .
  end.
  if int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.max-marg)
      and int(temp_grplib_grp.cli-type) <> ?
      and temp_grplib_grp.cli-type <> ""
      and int(temp_grplib_grp.max-marg) <> ?
  then do:
    temp_grplib_grp.max-marg:bgcolor in browse  br-list = 11 /* blue */ .
  end.
  else do:
    temp_grplib_grp.max-marg:bgcolor in browse  br-list = ? .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON VALUE-CHANGED OF br-list IN FRAME Dlg-grp
DO:
   RUN OpenBr(yes, no, '':U).

    if temp_grplib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( temp_grplib_grp.full-name, {&delim-grp} )
        .
    end.
    if error-status :error
    then do:
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON CTRL-D OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.

    run grplib-expand-name in this-procedure (
        input fi-search :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search :screen-value
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON CTRL-S OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.

    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
    { gbl/working.i }
    run grplib-find-by-substring in this-procedure (
                          input v-full-search-start-code
                        , input v-full-search-string
                        , output v-new-code
                        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        { gbl/stopwork.i }
        message return-value.
        undo, return no-apply.
    end.
    { gbl/stopwork.i }
    if v-new-code = 0
    then do:
        message
            skip "Не найдена строка '" v-full-search-string "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search :screen-value
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code = v-new-code
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON LEAVE OF fi-search IN FRAME Dlg-grp
DO:
    if fi-search :screen-value <> v-full-search-string
    then do:
        assign
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON RETURN OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-found    as logical      no-undo.

    if fi-search :screen-value = ""
    or fi-search :screen-value = ?
    then do:        /* Ничего не делать, если строка поиска пуста. */
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure (
          input fi-search :screen-value
        , output v-found
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка поиска группы."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-found = no
    then do:
        message
          skip "Группа не найдена."
        view-as alert-box information.
    end.
    apply "ENTRY" to b-search in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-prc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-prc Dlg-grp
ON RETURN OF FILL-prc IN FRAME Dlg-grp
OR LEAVE OF FILL-prc IN FRAME Dlg-grp
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

  assign FILL-prc .
  if b-prc and dec(FILL-prc:screen-value) <> FILL-prc then assign is-new1 = yes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-prc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-prc-2 Dlg-grp
ON RETURN OF FILL-prc-2 IN FRAME Dlg-grp
OR LEAVE OF FILL-prc-2 IN FRAME Dlg-grp
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

  assign FILL-prc-2 .
  if b-prc-2 and dec(FILL-prc-2:screen-value) <> FILL-prc-2 then assign is-new1 = yes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-find
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-find Dlg-grp
ON VALUE-CHANGED OF RADIO-find IN FRAME Dlg-grp
DO:
  assign RADIO-find .
  if sch-str <> "" then do:
    run proc-find-code in this-procedure(no, input sch-str) no-error.
    if error-status:error then return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dlg-grp
ON CTRL-J OF sch-str IN FRAME Dlg-grp
DO:
  assign sch-str .
  assign RADIO-find .
  run proc-find-code in this-procedure(yes, input sch-str) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-str Dlg-grp
ON RETURN OF sch-str IN FRAME Dlg-grp
DO:
  assign sch-str .
  assign RADIO-find .
  run proc-find-code in this-procedure(no, input sch-str) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME spec-List
&Scoped-define SELF-NAME spec-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL spec-List Dlg-grp
ON RETURN OF spec-List IN FRAME Dlg-grp
or MOUSE-SELECT-DBLCLICK OF spec-List IN FRAME Dlg-grp
DO:
  if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-list
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dlg-grp


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name=br-list }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse spec-list:handle
  ) .
run diasize_init in this-procedure .

on F9 of frame {&frame-name} anywhere do:
  if not available buf_contract-specif then  return no-apply.
  find first ub.goods no-lock where ub.goods.gds-code = buf_contract-specif.gds-code .
  gds-rec = recid(goods) .
  run ref/gds-form.w
    (input  parParentProc
    ,input  {&lookup}
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  ?
    ,input-output gds-rec
    ).

  apply "entry" to spec-List in frame {&frame-name}.
  return no-apply.
end.

{ gbl/srt-clmd.i
  &table-name     = "buf_contract-specif"
  &browse-name = "spec-List"
  &frame-name = "{&frame-name}"
  &ext-col = 13
  &open-query     = "run OpenBr(yes, no, '':U)."
  &open-query-otherwise = "run OpenBr(yes, no, '':U)."
  &sort-column-name = "sort-column-name"
  &start-column         = "2"
  &label-clmn_1         = "{&col-l1}"
  &sort-clmn_1          = "{&cop-l1}"
  &dyn_sort-clmn_1      = "{&dyn_cop-l1}"
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

run ver-db1 in this-procedure .
run ver-attr in this-procedure .
define variable v-size-col1 as decimal   no-undo .

run uf-get in this-procedure (
   input  {&uf-contspec}
  ,input  userid("ub")
  ,output v-uf-List_
  ,output v-uf-Naim
  ,output v-uf-print-graft
  ,output v-uf-sort-gr
  ,output v-uf-type-price
  ,output v-uf-type-val
)  no-error.
if error-status :error then message  vss-workfile vss-revision vss-description skip  error-status :get-message(1) skip  return-value skip  ""  view-as alert-box error .

if not error-status:error then do:
  v-size-col1  = decimal (entry(1, v-uf-List_ ,{&delim-par})) no-error.
  if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1 = 40.
end.
define variable v-int as integer   no-undo .
  v-int = int(v-size-col1 ) no-error .
  if error-status :error then v-size-col1 = 40.
  if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1 = 40.
  buf_contract-specif.gds-name:resizable in browse spec-List   = true .
  buf_contract-specif.gds-name:width     in browse spec-List  = v-size-col1  .

  frame {&frame-name}:TITLE = frame {&frame-name}:TITLE + " " + buf_contract.contract-prn-code .
  buf_contract-specif.artic:read-only in browse spec-List = yes .

    if p-current-obj-code = 0
    then do:
       assign
       v-current-store-type = v-cntxt-obj-type
       v-current-store-code = v-cntxt-obj-code
       v-current-host-code = v-cntxt-host-code-obj
       .
    end.
    else do:
        assign
            v-current-store-type = p-current-obj-type
            v-current-store-code = p-current-obj-code
        .
        { gbl/hostcode.i
            v-current-store-type
            v-current-store-code
            v-current-host-code
        }
    end.
    run grplib-get-parameters in this-procedure (
          input v-current-store-type
        , input v-current-store-code
    ) no-error.
    if error-status :error
    then do:
        message
            "Ошибка чтения параметров для списка групп товаров."
            skip (1)
            "Для параметров списка будут приняты значения по умолчанию."
        view-as alert-box warning.
    end.
    run UI-on-0 in this-procedure no-error .
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка при загрузке дерева групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    RUN OpenBr(yes, no, '':U).
  { gbl/mv-clmn.i
    &browse-name = "spec-List"
    &frame-name = "{&frame-name}"
    &ext-col = 13
    &start-column = "2"
  }
  if v-cntxt-db-num = 0 and b-prc:SENSITIVE then  apply "VALUE-CHANGED" to b-prc IN FRAME {&frame-name}  .
  if v-cntxt-db-num = 0 and b-prc-2:SENSITIVE then  apply "VALUE-CHANGED" to b-prc-2 IN FRAME {&frame-name} .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-assmatr Dlg-grp
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
     view-as alert-box information .
   */
   return .
end.
define variable v-i as integer   no-undo .
define buffer buf_assortment-matrix for ub.assortment-matrix.
define variable p-doc-rec  as recid no-undo .

v-err-ext  = false .
v-longchar = "".
{ ref/clearlm.i }
repeat v-i = 1 to v-kol :
  find first  buf_assortment-matrix no-lock where recid(buf_assortment-matrix) = integer (entry(v-i,p-rid-list )) no-error .
  if available buf_assortment-matrix then do:
  if buf_assortment-matrix.asmt-status <> integer ({&current-status-int})   then do: message substitute("АМ &1 - удалена , в нее добавлять товар нельзя !" ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj ) view-as alert-box information . next. end.
  if v-cntxt-db-num <> 0 and
     (( buf_assortment-matrix.asmt-type = {&type-assmatr-obj}     and buf_assortment-matrix.db-num-obj         <> v-cntxt-db-num ) or
      ( buf_assortment-matrix.asmt-type = {&type-assmatr-shablon} and buf_assortment-matrix.asmt-db-num-create <> v-cntxt-db-num ))
      then do:
         v-err-ext  = true .
         v-longchar = v-longchar +  substitute("АМ &1 чужой БД &2 , в нее добавлять товар нельзя ! &3" ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj , {&new-line}).
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
      no-error }
      if error-status :error then do:
           v-err-ext = true .
           v-longchar = v-longchar + return-value + {&new-line} .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-grp Dlg-grp
PROCEDURE add-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  input p-node-code - код группы для добавления подгруппы.
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.

    define variable v-gds-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-have-rights       as logical       no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    run check-rights-for-change-grp in this-procedure (
        input p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run grplib-have-goods in this-procedure (
          input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
        message "В данной группе есть товары. Добавить в нее подгруппу,"
                "включающую эти товары ?"
        view-as alert-box question
        buttons OK-Cancel
        update v-yesno as logical.
        if v-yesno = no
        then do:
            apply "entry" to br-list in frame {&frame-name}.
            return no-apply.
        end.
    end.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "add-grp: Не найдена группа в browse.".
    end.
    if buf_temp_grplib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( input p-node-code, input no ) no-error.
        if error-status :error
        then do:
            undo, return error "add-grp: Не удается раскрыть группу.".
        end.
    end.
    run ref/g-grp-f.w (
          input parparentproc
        , input v-current-store-type
        , input v-current-store-code
        , input {&add-def}
        , input p-node-code
        , input-output v-gds-grp-recid
    ) no-error .
    if v-gds-grp-recid = ?
    then do:
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    find first buf_gds-grp
         where recid ( buf_gds-grp ) =  v-gds-grp-recid
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "add-grp: Ошибка добавления группы.".
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input buf_temp_grplib_grp.level + 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input buf_temp_grplib_grp.full-name
        , input buf_temp_grplib_grp.sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка добавления строки в список групп.".
    end.
    if buf_temp_grplib_grp.level > 0
    then do:
        assign
            buf_temp_grplib_grp.mark = {&opened-noterminal-grp-mark}
            buf_temp_grplib_grp.name = substring( buf_temp_grplib_grp.name, 1, buf_temp_grplib_grp.level * {&tab-size} )
                                + {&opened-noterminal-grp-mark}
                                + substring( buf_temp_grplib_grp.name, buf_temp_grplib_grp.level * {&tab-size} + 2 )
        .
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
    RUN OpenBr(yes, no, '':U).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE bind-to-scales Dlg-grp
PROCEDURE bind-to-scales :
/*------------------------------------------------------------------------------
  Purpose:     Привязать группу товаров к весам
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-is-terminal   as logical           no-undo.

    run grplib-is-terminal (  input p-node-code
                            , output v-is-terminal
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка при определении типа группы (терм/корн)"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.

    if v-is-terminal = no
    then do:
        message
            "Требуется выбрать самую подробную группу товаров,"
            skip "в которой НЕТ других групп."
        view-as alert-box information .
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    run ref/scal-grp.w (
          input parparentproc
        , input 'b-add'
        , input v-current-store-type
        , input v-current-store-code
        , input ({&table_db} + {&comma-char} + {&table_gds-grp})
        , input g#db-num
        , input 0
        , input p-node-code
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value.
    end.
end.
END PROCEDURE. /* bind-to-scales */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-down-lim Dlg-grp
PROCEDURE calc-down-lim :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-node-code as integer   no-undo .
define output parameter kk  as integer   no-undo .
define variable  kk2 as integer   no-undo .
define buffer d_temp_grplib_grp for temp_cons  .
define buffer curr_temp_grplib_grp for temp_cons  .
define variable v-is-terminal as logical   no-undo .
  do
  on error undo, return error return-value
  :

    find first curr_temp_grplib_grp where curr_temp_grplib_grp.node-code =  p-node-code no-error .
    kk = 0 .
    for each d_temp_grplib_grp where
             d_temp_grplib_grp.upper-code = p-node-code :

           if not ( d_temp_grplib_grp.cli-type =  ?  or  trim(d_temp_grplib_grp.cli-type) = "" )
           then do:
                  kk = kk +  int(d_temp_grplib_grp.cli-type).
           end.
           else do:
              run grplib-is-terminal in this-procedure (
                  input d_temp_grplib_grp.node-code
                , output v-is-terminal ) .
                if v-is-terminal = true then kk = ? .
                else do:
                   run calc-down-lim (input d_temp_grplib_grp.node-code , output kk2) .
                   kk = kk + kk2.
                end.
           end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-rights-for-change-grp Dlg-grp
PROCEDURE check-rights-for-change-grp :
/*------------------------------------------------------------------------------
  Purpose:     Проверка прав
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input  parameter p-node-code     as integer      no-undo.
define output parameter p-have-rights   as logical      no-undo.

    define variable v-enable-change-grp as logical       no-undo.

    if g#db-num <> 0
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Операция определена только в ГБД."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        assign
            p-have-rights = no
        .
    end.
    else do:
        { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_reference_groups-edit':U
            {&cntxt-firm}
            v-cntxt-host-code-obj
            '':U
            0
            0
            p-node-code
            0
            no
            p-have-rights
        }
    end.
end.
END PROCEDURE. /* check-rights-for-change-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE collapse-all-on-first-level Dlg-grp
PROCEDURE collapse-all-on-first-level :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    for each buf_temp_grplib_grp no-lock
       where buf_temp_grplib_grp.upper-code = v-root-code
    :
        run collapse-item in this-procedure (
              input buf_temp_grplib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы "
                                + {&new-line} + "'" + buf_temp_grplib_grp.full-name + "'"
                                + {&new-line} + return-value.
        end.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
end.
END PROCEDURE. /* collapse-all-on-first-level */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE collapse-item Dlg-grp
PROCEDURE collapse-item :
/*------------------------------------------------------------------------------
  Purpose:     Свернуть поддерево выбранной группы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_del_temp_grplib_grp   for temp_grplib_grp.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "collapse-item: Неверно передан код группы. Нет группы с кодом " + string( p-node-code ).
    end.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .

    for each buf_del_temp_grplib_grp
       where buf_del_temp_grplib_grp.full-name begins buf_temp_grplib_grp.full-name
         and buf_del_temp_grplib_grp.full-name <> buf_temp_grplib_grp.full-name
         and buf_del_temp_grplib_grp.level     <> buf_temp_grplib_grp.level
    :
        delete buf_del_temp_grplib_grp.
    end.
    assign
        buf_temp_grplib_grp.mark = {&closed-noterminal-grp-mark}
        buf_temp_grplib_grp.name = replace( buf_temp_grplib_grp.name
                                        , {&opened-noterminal-grp-mark}
                                        , {&closed-noterminal-grp-mark}
                                        )
    .
    if p-refresh = yes
    then do:
        {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
        reposition br-list to row v-repositioned-row.
        RUN OpenBr(yes, no, '':U).
    end.
end.
END PROCEDURE. /* collapse-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-new-line Dlg-grp
PROCEDURE create-new-line :
/*------------------------------------------------------------------------------
  Purpose:     Создание линии в строке browse без перерисовки
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define input parameter p-upper-code     as integer      no-undo.
define input parameter p-level          as integer      no-undo.
define input parameter p-is-terminal    as logical          no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-increase-pc    as decimal      no-undo.
define input parameter p-calc-method    as character    no-undo.
define input parameter p-full-name      as character    no-undo.
define input parameter p-sort-name      as character    no-undo.

define variable v-margins-range     as integer           no-undo.
define variable v-margins-exists    as logical           no-undo.
define variable v-increase-range    as integer          no-undo.
define variable v-increase-exists   as logical          no-undo.
define variable v-min-marg          as decimal           no-undo.
define variable v-max-marg          as decimal           no-undo.
define variable v-increase-pc       as decimal           no-undo.
define variable v-round-method      as character         no-undo .
define variable v-base              as decimal           no-undo .
define variable v-rmethod-range     as integer           no-undo.
define variable v-rmethod-exists    as logical           no-undo.

define variable  v-cli-type         as character no-undo .
define variable  v-cli-code         as integer no-undo .
define variable  v-income-cli-range  as integer no-undo .
define variable  v-income-cli-exists as logical no-undo .


define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    create buf_temp_grplib_grp.
    assign
        buf_temp_grplib_grp.node-code   = p-node-code
        buf_temp_grplib_grp.upper-code  = p-upper-code
        buf_temp_grplib_grp.level       = p-level
        buf_temp_grplib_grp.full-name   = p-full-name + (if p-full-name <> "" then {&delim-grp}         else "") + p-node-name
        buf_temp_grplib_grp.sort-name   = p-sort-name + (if p-full-name <> "" then {&grplib-separator}  else "") + p-node-name
        buf_temp_grplib_grp.calc-method = p-calc-method
        buf_temp_grplib_grp.increase-pc = p-increase-pc
      .

    find first temp_cons where temp_cons.node-code = p-node-code no-error .
    if available temp_cons then do:
        assign
          buf_temp_grplib_grp.min-marg = temp_cons.min-marg
          buf_temp_grplib_grp.max-marg = temp_cons.max-marg
          buf_temp_grplib_grp.cli-type = temp_cons.cli-type
        .
    end.

    run get-first-char in this-procedure (
          input p-node-code
        , input p-is-terminal
        , input no
        , output buf_temp_grplib_grp.mark
    ) no-error.
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления первого символа для отображения группы." .
    end.
    assign
        buf_temp_grplib_grp.name = fill( " ", {&tab-size} * p-level )
                                        + buf_temp_grplib_grp.mark
                                        + " "
                                        + p-node-name
    .
end.
END PROCEDURE. /* create-new-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-grp Dlg-grp
PROCEDURE delete-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-gds-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-upper-code        as integer  no-undo.
    define variable v-answer            as logical  no-undo.
    define variable v-is-terminal       as logical  no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-counter           as integer  no-undo.
    define variable v-have-rights       as logical  no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_same_gds-grp      for ub.gds-grp.                      /* для проверки совпадения имен */
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    run check-rights-for-change-grp in this-procedure (
        input  p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    /*---START--------- Нельзя удалить корневую группу ---------------------*/
    if p-node-code = v-root-code
    then do:
        message
            "Нельзя удалить корневую группу."
        view-as alert-box.
        undo, return.
    end.
    /*---END----------- Нельзя удалить корневую группу ---------------------*/
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "Неверно выбрана группа." .
    end.
    /*---START--------- Нельзя удалить последнюю группу первого уровня ---------------------*/
    if buf_temp_grplib_grp.upper-code = v-root-code
    then do:
        assign
            v-counter = v-counter + 1
        .
        count-first-level-grp:
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = v-root-code
        :
            assign
                v-counter = v-counter + 1
            .
            if v-counter > 1
            then do:
                leave count-first-level-grp.
            end.
            else do:
                message
                    "Нельзя удалить последнюю группу первого уровня."
                view-as alert-box.
                return error.
            end.
        end.
    end.
    /*---END----------- Нельзя удалить последнюю группу первого уровня ---------------------*/
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Нет группы БД, соответствующей значению в списке.".
    end.
    assign
        v-upper-code    = buf_gds-grp.upper-code
        v-answer        = no
    .
    run grplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.

    if v-is-terminal = no
    then do:
    /* проверяем, не имеет ли одна из подгрупп такое же название, как и соседняя к удаляемой */
        for each buf_gds-grp
        where buf_gds-grp.upper-code = v-upper-code
          and buf_gds-grp.node-code <> p-node-code
        :
            find first buf_same_gds-grp no-lock
                where buf_same_gds-grp.upper-code  = p-node-code
                and buf_same_gds-grp.node-name   = buf_gds-grp.node-name
            no-error.
            if available buf_same_gds-grp
            then do:
                message
                    "Одна из подгрупп удаляемой группы имеет название:" buf_gds-grp.node-name "-" skip
                    "такое же, как одна из соседних к удаляемой групп." skip
                    "После удаления получились бы 2 группы на одном уровне, имеющие одинаковые названия, что запрещено."
                view-as alert-box error.
                return no-apply.
            end.
        end.
        message "Текущая группа будет удалена."
            skip "Ее подгруппы будут перенесены в вышестоящую группу."
            skip (1) "Слить группу с вышестоящей?"
        view-as alert-box question buttons yes-no update v-answer.
    end.
    if v-is-terminal = yes
    then do:
        run grplib-have-goods in this-procedure (
              input p-node-code
            , output v-have-goods
        ) no-error .
        if error-status :error
        then do:
            undo, return error "delete-grp: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
        end.
        if v-have-goods = yes
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-code <> p-node-code
            no-error .
            if available buf_gds-grp
            then do:
                message "В одной группе не могут быть одновременно подгруппы и товары."
                    skip "Эта группа не может быть слита с вышестоящей."
                view-as alert-box error.
                apply "entry" to br-list in frame {&frame-name}.
                return no-apply.
            end.
            message "Текущая группа будет удалена."
                skip "Товары будут перенесены в вышестоящую группу."
                skip (1) "Слить группу с вышестоящей?"
            view-as alert-box question buttons yes-no update v-answer.
        end.
        else do:
            message "Удалить группу ? Вы уверены ?"
            view-as alert-box question buttons yes-no update v-answer.
        end.
    end.
    if not v-answer
    then do:
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    delete-from-base:
    do
    ON ERROR UNDO delete-from-base, return no-apply
    ON stop UNDO delete-from-base, return no-apply:
        find first buf_gds-grp exclusive-lock
             where buf_gds-grp.node-code = p-node-code
        no-error.
        if error-status :error
        then do:
            undo, return error "change-grp: Нет группы БД, соответствующей значению в списке.".
        end.
        delete buf_gds-grp.
    end.
    if p-refresh = yes
    then do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "delete-grp: Не найдена группа в БД".
        end.
        assign
            p-recid-list = string( recid( buf_gds-grp ) )
            gds-grp-row  = recid( buf_gds-grp )
        .
/*        run expand-item in this-procedure ( input buf_gds-grp.node-code, input yes ) no-error.*/
/*        if error-status :error*/
/*        then do:*/
/*            undo, return error "delete-grp: Не удается раскрыть группу.".*/
/*        end.*/
        run UI-on in this-procedure no-error .
        if error-status :error
        then do:
            undo, return error "delete-grp: Ошибка при загрузке дерева групп.".
        end.
    end.
end.
END PROCEDURE. /* delete-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dlg-grp  _DEFAULT-DISABLE
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
  HIDE FRAME Dlg-grp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dlg-grp  _DEFAULT-ENABLE
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
  DISPLAY fi-search b-prc FILL-prc b-prc-2 FILL-prc-2 RADIO-find sch-str
          mark-num
      WITH FRAME Dlg-grp.
  ENABLE b-exit b-verify b-recalc B-print b-help b-expand b-expand-all
         fi-search b-find-by-full-name b-find-by-substring b-search br-list
         b-mark B-add b-chg B-del B-add-AssMatr B-del-AssMatr b-all b-prc
         FILL-prc b-all-2 b-prc-2 FILL-prc-2 RADIO-find sch-str spec-List
         mark-num
      WITH FRAME Dlg-grp.
  VIEW FRAME Dlg-grp.
  {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-all-from-current Dlg-grp
PROCEDURE expand-all-from-current :
/*------------------------------------------------------------------------------
  Purpose:     Раскрыть всю ветку дерева, начиная с текущей группы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-full-name         as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-grp-counter       as integer      no-undo.

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    assign
        v-grplib-no-warning-grp-amount = no
    .
    run expand-item in this-procedure (
          input p-node-code
        , input no
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Ошибка вычисления полного имени группы".
    end.
    assign      /* Загрузить первую порцию групп ( {&grplib-grp-amount-for-warning} ) */
        v-grplib-grp-amount-for-load = 1
    .
    load-grp-list:
    for each buf_temp_grplib_grp
       where buf_temp_grplib_grp.full-name begins v-full-name
    :
        assign
            v-grp-counter = v-grp-counter + 1
        .
        run expand-item in this-procedure (
              input buf_temp_grplib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
        end.
        if v-grp-counter > {&grplib-grp-amount-for-warning}
        and v-grplib-grp-amount-for-load <> 0
        then do:
            define variable v-choice    as integer      no-undo.
            run gbl/d-askw.w (
                  input "Большой список групп"
                , input substitute( "В список добавлено более &2 групп&1&1Вы можете добавить следующие &2 групп,&1заполнить весь список&1или остановить создание списка.", {&new-line}, {&grplib-grp-amount-for-warning} )
                , input "|^":U
                , input substitute( "Следующие &1|Заполнить все|Прервать", {&grplib-grp-amount-for-warning} )
                , input substitute( "Загрузить список следующих &1 групп|Загрузить список всех групп|Не загружать список полностью", {&grplib-grp-amount-for-warning} )
                , input 1
                , input 3
                , output v-choice
            ).
            case v-choice
            :
                when 1
                then do:
                    assign
                        v-grplib-grp-amount-for-load    = 1
                        v-grp-counter                   = 0

                    .
                end.        /* when 1 */
                when 2
                then do:
                    assign
                        v-grplib-grp-amount-for-load    = 0
                    .
                end.        /* when 2 */
                otherwise do:
                    leave load-grp-list.
                end.        /* otherwise */
            end case.       /* case v-choice */
        end.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
    RUN OpenBr(yes, no, '':U).

end.
END PROCEDURE. /* expand-all-from-current */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-item Dlg-grp
PROCEDURE expand-item :
/*------------------------------------------------------------------------------
  Purpose:     Раскрыть подуровни выбранной группы (должна быть не терминальной!)
  Parameters:   p-node-code - код узла для раскрытия.
                p-refresh   - надо ли обновлять browse после раскрытия узла
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.
    { gbl/working.i }
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "expand-item: Неверно задан код группы.".
    end.
    if buf_temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    then do:
        /* Не закрытая группа, открыть невозможно. */
    end.
    else do:
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-node-code
        on error undo, return error
        :
            run create-new-line in this-procedure (
                  input buf_gds-grp.node-code
                , input buf_gds-grp.upper-code
                , input buf_temp_grplib_grp.level + 1
                , input buf_gds-grp.is-term
                , input buf_gds-grp.node-name
                , input buf_gds-grp.increase-pc
                , input buf_gds-grp.calc-method
                , input buf_temp_grplib_grp.full-name
                , input buf_temp_grplib_grp.sort-name
            ) no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "expand-item: Ошибка добавления строки в список групп."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                { gbl/stopwork.i }
                undo, return error .
            end.
        end.        /* for each buf_gds-grp */
        assign
            buf_temp_grplib_grp.mark = {&opened-noterminal-grp-mark}
            buf_temp_grplib_grp.name = replace( buf_temp_grplib_grp.name
                                            , {&closed-noterminal-grp-mark}
                                            , {&opened-noterminal-grp-mark}
                                            )
        .
        if p-refresh = yes
        then do:
            {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
            if v-focused-row > br-list :height - 2
            then do:
                assign
                    v-focused-row       = br-list :height - 2
                .
            end.
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-list to row v-repositioned-row.
            RUN OpenBr(yes, no, '':U).
        end.
    end.
    { gbl/stopwork.i }
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-or-collapse-item Dlg-grp
PROCEDURE expand-or-collapse-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    case temp_grplib_grp.mark
    :
    when {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось раскрыть подуровни группы.".
        end.
    end.
    when {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы.".
        end.
    end.
    end case.
end.
END PROCEDURE. /* expand-or-collapse-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-tree-for-grp Dlg-grp
PROCEDURE expand-tree-for-grp :
/*------------------------------------------------------------------------------
  Purpose:     Раскрыть дерево групп для заданного узла
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code              as integer          no-undo.
define output parameter p-focused-row           as integer          no-undo.
define output parameter p-reposition-row        as integer          no-undo.
define output parameter p-reposition-to-recid   as logical init no  no-undo.

define variable v-full-name     as character    no-undo.
define variable v-found         as logical      no-undo.

define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    run grplib-get-full-name in this-procedure ( input p-node-code, output v-full-name ) no-error .
    if error-status :error
    then do:
        /* Не нашли полного имени - встаем на первую группу. */
    end.
    else do:
        run grplib-find-grp-by-full-name in this-procedure (
              input right-trim( v-full-name, {&delim-grp} )
            , input yes
            , output v-found
        ) no-error .
        if v-found = no
        then do:
            /* Не нашли по полному имени - встаем на первую группу. */
        end.
        else do:
            process-initial-grp:
            for each temp_grplib_found-grp
            break by temp_grplib_found-grp.level
            on error undo, leave process-initial-grp :
                if last ( temp_grplib_found-grp.level )
                then do:
                    assign
                        p-focused-row       = integer( br-list :height in frame {&frame-name} / 2 ) + 1
                    .
                    find first buf_temp_grplib_grp
                         where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_grplib_grp )
                        p-reposition-to-recid = yes
                    .
                    leave process-initial-grp.
                end.
                else do:
                    run expand-item in this-procedure ( input temp_grplib_found-grp.node-code, input no ) no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    find first buf_temp_grplib_grp
                            where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_grplib_grp )
                        p-reposition-to-recid = yes
                    .
                end.
            end.
        end.
    end.
end.
END PROCEDURE. /* expand-tree-for-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-db Dlg-grp
PROCEDURE fill-db :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter parnode-code like ub.gds-grp.node-code no-undo .
define input parameter parupper-code like ub.gds-grp.node-code no-undo .
  run ref/dtaxgrpu.p (input parnode-code,
                 input parupper-code,
                 input yes,
                 input v-current-host-code,
                 v-current-store-type,
                 v-current-store-code) no-error.
end.
END PROCEDURE. /* fill-db */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-marg Dlg-grp
PROCEDURE fill-marg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-margins-range     as integer  no-undo.
    define variable v-margins-exists    as logical  no-undo.
    define variable v-increase-range     as integer  no-undo.
    define variable v-increase-exists    as logical  no-undo.
    define variable v-min-marg          as decimal  no-undo.
    define variable v-max-marg          as decimal  no-undo.
    define variable v-increase-pc          as decimal  no-undo.
    define variable v-round-method      as character   no-undo .
    define variable v-base              as decimal     no-undo .
    define variable v-rmethod-range     as integer     no-undo.
    define variable v-rmethod-exists    as logical     no-undo.
    define variable v-cli-type           as character no-undo .
    define variable v-cli-code           as integer no-undo .
    define variable v-income-cli-range   as integer no-undo .
    define variable v-income-cli-exists  as logical no-undo .


    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run ref/pr-marg.w (
          input parparentproc
        , input p-node-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-marg: Ошибка при установке диапазона торговых наценок." + {&new-line} + return-value.
    end.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "fill-marg: Неверно задан код группы.".
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
    RUN OpenBr(yes, no, '':U).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-output-parameters-on-exit Dlg-grp
PROCEDURE fill-output-parameters-on-exit :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-selected      as logical  init no  no-undo.
    define variable v-is-terminal    as logical           no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    run grplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-output-parameters-on-exit: Не удается определить, корневая группа или терминальная." + {&new-line} + return-value.
    end.
    if lookup ( {&g#term}, p-button-list ) <> 0 and v-is-terminal = no
    then do:
            message "Требуется выбрать группу товаров, в которой нет других групп.".
            apply "entry" to br-list in frame {&frame-name}.
            undo, return "no-term".
    end.
    assign
        p-recid-list = ""
    .
    for each buf_temp_grplib_grp
       where buf_temp_grplib_grp.sel = {&selection-char}
    :
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_temp_grplib_grp.node-code
        no-error .
        if error-status :error
        then do:
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                                + "'" + buf_temp_grplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = p-recid-list + ( if p-recid-list = "" then "" else "," ) + string( recid( buf_gds-grp ) )
            v-selected = yes
        .
    end.
    if v-selected = no
    then do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = p-node-code
        no-error .
        if not available buf_gds-grp
        then do:
            find first buf_temp_grplib_grp
                 where buf_temp_grplib_grp.node-code = p-node-code
            no-error .
            if not available buf_temp_grplib_grp
            then do:
                undo, return error "fill-output-parameters-on-exit: Неверно выбрана группа с кодом "
                                    + string( p-node-code ).
            end.
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                            + buf_temp_grplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = string( recid( buf_gds-grp ) )
        .
    end.
    assign
        gds-grp-row  = integer( entry( 1, p-recid-list ) )
    .

assign
v-uf-List_ = (if gds-grp-row = ? then {&question-mark} else string(gds-grp-row))
.
run uf-set in this-procedure(
    input  {&uf-gds-grp-p}
    ,input  g#userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .

end.
END PROCEDURE. /* fill-output-parameters-on-exit */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt Dlg-grp
PROCEDURE fill-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter parnode-code like ub.gds-grp.node-code no-undo .
define input parameter parupper-code like ub.gds-grp.node-code no-undo .

run ref/dtaxgrps.p (parnode-code,
               parupper-code,
               v-current-host-code,
               v-current-store-type,
               v-current-store-code) no-error.
end.
END PROCEDURE. /* fill-tt */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-grp-in-browse Dlg-grp
PROCEDURE find-grp-in-browse :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-search-grp-full-name   as character        no-undo.
define output parameter p-found                 as logical          no-undo.

    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-level             as integer      no-undo.

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    assign
    v-level = num-entries( right-trim(p-search-grp-full-name, {&delim-grp} ) , {&delim-grp})
    .
    if v-found-grp-num  <> 0       /* группу уже нашли, temp-table уже заполнен. Берем следующую из темр-table.*/
    then do:
        assign
            v-counter = 0
        .
        find first temp_grplib_found-grp
             where temp_grplib_found-grp.level = v-level
        no-error .
        if not available temp_grplib_found-grp
        then do:
            undo, return error "Не найдено ни одной группы уровня " + string( v-level ).
        end.
        do v-counter = 1 to v-found-grp-num
        :
            find next temp_grplib_found-grp
                where temp_grplib_found-grp.level = v-level
            no-error .
            if not available temp_grplib_found-grp
            then do:
                undo, return error "Не найдена следующая группа уровня " + string( v-level ).
            end.
        end.
        find first buf_temp_grplib_grp
                where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
        no-error .
        if not available buf_temp_grplib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
        reposition br-list to recid recid( buf_temp_grplib_grp ).
        RUN OpenBr(yes, no, '':U).
    end.        /* v-found-grp-num  <> 0 */
    else do:        /* Первый поиск */
        run grplib-find-grp-by-full-name (
              input fi-search :screen-value in frame {&frame-name}
            , input yes
            , output p-found
        ).
        if p-found = yes
        then do:
            found-group:
            for each temp_grplib_found-grp no-lock
            by temp_grplib_found-grp.level
        /*       where temp_grplib_found-grp. =*/
            :
                if temp_grplib_found-grp.level = v-level
                then do:
                    leave.
                end.
                run expand-item in this-procedure (
                      input temp_grplib_found-grp.node-code
                    , input no
                ).
            end.
            find first temp_grplib_found-grp
                 where temp_grplib_found-grp.level = v-level
            no-error .
            if not available temp_grplib_found-grp
            then do:
                undo, return error "Нет последней найденной группы для уровня " + string( v-level ).
            end.
            find first buf_temp_grplib_grp
                 where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
            no-error .
            if not available buf_temp_grplib_grp
            then do:
                undo, return error "Найденной группы нет в списке групп".
            end.
            {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-list to recid recid( buf_temp_grplib_grp ).
            RUN OpenBr(yes, no, '':U).
        end.        /* p-found = yes */
    end.        /* v-found-grp-num  = 0, т.е. первый поиск */
    find next temp_grplib_found-grp     /* Можно ли искать дальше? Если можно, увеличиваем счетчик поиска */
        where temp_grplib_found-grp.level = v-level
    no-error .
    if available temp_grplib_found-grp
    then do:
        assign
            v-found-grp-num  = v-found-grp-num + 1
            b-search :label = "Далее"
        .
    end.
    else do:
        assign
            v-found-grp-num  = 0
            b-search :label = "Поиск"
        .
    end.
end.
END PROCEDURE. /* find-grp-in-browse */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-current-recid Dlg-grp
PROCEDURE get-current-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define output parameter p-gds-grp-recid as recid   no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.

    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error "get-current-recid: Не найдена группа." .
    end.
    assign
        p-gds-grp-recid = recid( buf_gds-grp )
    .
end.
END PROCEDURE. /* get-current-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-first-char Dlg-grp
PROCEDURE get-first-char :
/*------------------------------------------------------------------------------
  Purpose:     Определение первого символа в названии: '+', '-', ' '.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define input parameter p-terminal       as logical      no-undo.
define input parameter p-calc-terminal  as logical      no-undo.
define output parameter p-prefix        as character    no-undo.

define variable v-name          as character    no-undo.
define variable v-is-terminal   as logical      no-undo.
define variable v-have-goods    as logical      no-undo.

define buffer buf_gds-grp               for ub.gds-grp.
define buffer buf_temp_grplib_grp       for temp_grplib_grp.

if p-calc-terminal = yes
then do:
    run grplib-is-terminal in this-procedure (
          input p-node-code
        , output v-is-terminal
    ) no-error .
    if error-status :error
    then do:
        undo, return error "get-first-char: Ошибка при определении типа группы (терм/корн).".
    end.
end.        /* if p-calc-terminal = yes */
else do:
    assign
        v-is-terminal = p-terminal
    .
end.        /* NOT ( if p-calc-terminal = yes ) */
if v-is-terminal = yes
then do:                    /* Терминальная группа */
    run grplib-have-goods in this-procedure (
          input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "get-first-char: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
        assign
            p-prefix = {&terminal-with-goods-grp-mark}
        .
    end.
    else do:
        assign
            p-prefix = {&terminal-no-goods-grp-mark}
        .
    end.
end.        /* not available buf_gds-grp */
else do:
    find first buf_temp_grplib_grp no-lock
         where buf_temp_grplib_grp.upper-code = p-node-code
    no-error.
    if available buf_temp_grplib_grp
    then do:                /* группа в списке раскрыта */
        assign
            p-prefix = {&opened-noterminal-grp-mark}
        .
    end.
    else do:
        assign
            p-prefix = {&closed-noterminal-grp-mark}
        .
    end.
end.        /* available buf_gds-grp */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-row-amount Dlg-grp
PROCEDURE get-row-amount :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-row-amount as integer      no-undo.

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    for each buf_temp_grplib_grp
    :
        assign
            p-row-amount = p-row-amount + 1
        .
    end.
end.
END PROCEDURE. /* get-row-amount */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dlg-grp
PROCEDURE init-tt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 define buffer buf_gds-grp-obj-attr  for ub.gds-grp-obj-attr  .

    for each temp_grplib_grp :
        find first buf_gds-grp-obj-attr no-lock  where
                   buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr} and
                   buf_gds-grp-obj-attr.obj-type  = string(buf_contract.contract-code) and
                   buf_gds-grp-obj-attr.obj-code  = buf_contract.host-code and
                   buf_gds-grp-obj-attr.host-code = 0 and
                   buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
        if not available buf_gds-grp-obj-attr then temp_grplib_grp.cli-type  = "".
        else temp_grplib_grp.cli-type = buf_gds-grp-obj-attr.attr-value .
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE move-item Dlg-grp
PROCEDURE move-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.   /* Группа, которую перемещаем */
define input parameter p-upper-code as integer      no-undo.   /* Группа, к которой присоединяем */

    define variable v-node-full-name    as character    no-undo.
    define variable v-upper-full-name   as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-have-goods        as logical      no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_upper_gds-grp     for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    { gbl/working.i }

    run grplib-have-goods in this-procedure (
          input p-upper-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
            message
                "В эту группу переместить нельзя, т.к. в одной группе"
                skip "не могут быть одновременно подгруппы и товары.".
            apply "entry" to br-list in frame {&frame-name}.
            return no-apply.
    end.
    run grplib-get-full-name in this-procedure (
            input p-node-code
            , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени перемещаемой группы".
    end.
    run grplib-get-full-name in this-procedure (
            input p-upper-code
            , output v-upper-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени группы".
    end.
    if v-upper-full-name begins v-node-full-name
    then do:
        message
        "Группу нельзя переместить в ее собственную подгруппу."
        view-as alert-box.
        undo, return.
    end.

    do transaction
    on error undo, return error "move-item: Ошибка перемещения группы.".
        find first buf_gds-grp exclusive-lock
            where buf_gds-grp.node-code = p-node-code
        no-error .
        if not available buf_gds-grp
        then do:
            undo, return error "move-item: Не найдена группа для перемещения.".
        end.
        assign
            buf_gds-grp.upper-code = p-upper-code
        .
    end.
    assign
        p-recid-list = string( recid( buf_gds-grp ) )
        gds-grp-row  = recid( buf_gds-grp )
    .
    run UI-on in this-procedure no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка при загрузке дерева групп." + {&new-line} + return-value.
    end.
end.
END PROCEDURE. /* move-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dlg-grp
PROCEDURE openbr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
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
  &scop flt-open-open-query OPEN QUERY spec-List FOR EACH buf_contract-specif NO-LOCK

  &scop flt-open-dyn_open-query  FOR EACH buf_contract-specif

  &scop flt-open-query-handle query spec-List:handle

  &scop flt-open-open-query-tail , first buf_goods no-lock where ~
                    buf_goods.gds-code  = buf_contract-specif.gds-code   and ~
                    ( temp_grplib_grp.level = 0 OR ~
                    ( buf_goods.grp-name begins temp_grplib_grp.full-name ))

  &scop flt-open-dyn_open-query-tail  substitute(' , first buf_goods no-lock where ~
                    buf_goods.gds-code  = buf_contract-specif.gds-code   and ~
                    ( &1 = 0 OR ~
                    ( buf_goods.grp-name begins &2&3&2 )) ',temp_grplib_grp.level, ~{&double-quote~},temp_grplib_grp.full-name )


  &scop flt-open-waitfram true

  &scop flt-open-query-was-opened  l-query-was-opened

  &scop flt-open-sort-column-phrase sort-column-phrase

  &scop flt-open-call-point filter-point

  &scop flt-open-query p-open-query

  &scop flt-open-table-name buf_contract-specif

  &scop flt-open-search-option no-lock

  &scop flt-open-find-next p-find-next

  &scop flt-open-find-recid v-doc-rec

  &scop flt-open-find-condition p-find-condition

  &scop flt-open-find-buffer-name buf_contract-specif


  define variable l-open-query as logical   no-undo .
    filter-point = filter-point0 .
    if available buf_contract-specif then assign v-doc-rec = recid (buf_contract-specif) .
  { gbl/fltopend.i
    &where-cond = " buf_contract-specif.host-code = p-host-code and ~
                    buf_contract-specif.contract-num = p-contract-num "
    &DYN_where-cond = " substitute(' buf_contract-specif.host-code = &1 and buf_contract-specif.contract-num = &2', p-host-code, p-contract-num) "
    &use-ind = "  "
    &by = " "
  }
  if not p-open-query then do:
     REPOSITION spec-List to recid v-doc-rec No-ERROR.
     end.
  else do:
     REPOSITION spec-List to row 1 No-ERROR.
  end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-browse Dlg-grp
PROCEDURE print-browse :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable Line as character no-undo.
define variable v-vat-pc as decimal no-undo .
define variable v-bonus as decimal no-undo .
define variable v-slt-pc as decimal no-undo .
define variable date_string as character no-undo.
define buffer buf_temp_grplib_grp for temp_grplib_grp.
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.

DEFINE FRAME brFrame
buf_temp_grplib_grp.name          format "X(71)"      column-label " Наименование группы"
buf_temp_grplib_grp.calc-method   format "X(11)"      column-label " Исходная"
buf_temp_grplib_grp.increase-pc   format "->>>>9.99"  column-label " Наценка"
buf_temp_grplib_grp.min-marg      format "X(10)"  column-label " Мин.Нац."
buf_temp_grplib_grp.max-marg      format "X(10)"  column-label " Макс.Нац."
buf_temp_grplib_grp.round-method  format "X(22)"  column-label "Метод округл"
v-vat-pc                          format "99.99"  column-label "НДС"
v-bonus                           format "99.99"  column-label "Бонус"
v-slt-pc                          format "99.99"  column-label "НП"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 85 PAGE-NUMBER(PrnLibStream) AT 95 FORMAT ">>9" SKIP
Line format "X(150)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 150).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
      input parparentproc
    , input {&LS_PS_A4}
    , input yes /*p-is-stream*/
    , input no /*p-append*/
).
PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(90)" SKIP(1)
.
FORM HEADER
Line format "X(150)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .


FORM with FRAME BrFrame  .
run waitfram-show in this-procedure ("Ждите...").

FOR EACH buf_temp_grplib_grp :
  FIND LAST buf_tax-rate-gds-grp No-LOCK WHERE
            buf_tax-rate-gds-grp.node-code = buf_temp_grplib_grp.node-code AND
            buf_tax-rate-gds-grp.tax-code = integer({&vat-tax-code}) AND
            /*
            freeze
            ub.tax-rate-gds-grp.host-code = parhopst-code AND
            ub.tax-rate-gds-grp.obj-type = parobj-type AND
            ub.tax-rate-gds-grp.obj-code = parobj-code AND

            */
            buf_tax-rate-gds-grp.host-code = 0 AND
            buf_tax-rate-gds-grp.obj-type = "" AND
            buf_tax-rate-gds-grp.obj-code = 0 NO-ERROR.
  if avail buf_tax-rate-gds-grp then do:
     { gbl/pftaxval.i ? buf_tax-rate-gds-grp.tax-code buf_tax-rate-gds-grp.rate-code ? v-current-host-code v-current-store-type v-current-store-code v-vat-pc no-error }
  end.
  FIND LAST buf_tax-rate-gds-grp No-LOCK WHERE
            buf_tax-rate-gds-grp.node-code = buf_temp_grplib_grp.node-code AND
            buf_tax-rate-gds-grp.tax-code = integer({&slt-tax-code}) AND
            /*
            freeze
            ub.tax-rate-gds-grp.host-code = parhopst-code AND
            ub.tax-rate-gds-grp.obj-type = parobj-type AND
            ub.tax-rate-gds-grp.obj-code = parobj-code AND

            */
            buf_tax-rate-gds-grp.host-code = 0 AND
            buf_tax-rate-gds-grp.obj-type = "" AND
            buf_tax-rate-gds-grp.obj-code = 0 NO-ERROR.
  if avail buf_tax-rate-gds-grp then do:
     { gbl/pftaxval.i ? buf_tax-rate-gds-grp.tax-code buf_tax-rate-gds-grp.rate-code ? v-current-host-code v-current-store-type v-current-store-code v-slt-pc no-error }
  end.
  DISPLAY stream PrnLibStream
  buf_temp_grplib_grp.name
  buf_temp_grplib_grp.calc-method
  buf_temp_grplib_grp.increase-pc
  buf_temp_grplib_grp.min-marg
  buf_temp_grplib_grp.max-marg
  buf_temp_grplib_grp.round-method
  v-vat-pc
  v-bonus
  v-slt-pc
  with frame BrFrame.
  down stream PrnLibStream
  with frame BrFrame.
END. /*for each*/
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME BrFrame.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
      input parparentproc
    , input 8
).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dlg-grp
PROCEDURE proc-add :
/* -----------------------------------------------------------
  Purpose: добавление списка товаров
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
if v-cntxt-db-num <> 0 then do :
   if can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}) and
                                                        ub.assortment-matrix.db-num = v-cntxt-db-num )  then v-ass-m = true  .
end.
else do:
   if can-find ( first ub.assortment-matrix no-lock where  ub.assortment-matrix.asmt-status = integer ({&current-status-int}))  then v-ass-m = true  .
end.
define variable v-log as logical   no-undo .
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
    false
    v-log
  }
 if not v-log then v-ass-m = false .

if v-ass-m = true then do:
  message "Добавлять НОВЫЕ товары спецификации в Ассортиментные матрицы ?"
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
    find b_goods no-lock where recid(b_goods) = integer (entry (lns-cnt, ref-list)).
    run  SpecGr-gds-code-yes (
        input  b_goods.gds-code ,
        input  b_goods.grp-code ,
        input  p-contract-num   ,
        input  p-host-code      ,
        output p-ask        ) no-error .
        if error-status :error  or p-ask = false  then do:
            message substitute("Нельзя добавлять товар &1 &2 в Спецификацию из-за ограничения по ассортименту в группе", b_goods.gds-code , b_goods.gds-name) skip
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
        and ub.contract-specif.contract-num = p-contract-num
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
      if is-create then
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
      if b-prc then assign v-prc = FILL-prc .
      if b-prc-2 then assign v-prc-2 = FILL-prc-2 .

        run read-bonus (
        buf_contract.contract-code ,
        buf_contract.host-code ,
        b_goods.gds-code ,
        output v-bonus )
        .
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

      run str/contspc1.w ( input parParentProc
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
        if is-create then run add-assmatr in this-procedure (input b_goods.gds-code ,input p-rid-list) .

        do transaction :
          if is-create then do:
            create b_contract-specif .
            assign
              b_contract-specif.host-code     = p-host-code
              b_contract-specif.contract-num  = p-contract-num
              b_contract-specif.gds-code      = b_goods.gds-code
              b_contract-specif.gds-name      = b_goods.gds-name
              b_contract-specif.artic         = b_goods.artic
              b_contract-specif.prod-type     = b_goods.prod-type
              b_contract-specif.prod-code     = b_goods.prod-code
              b_contract-specif.unit-base     = b_goods.unit-base
              b_contract-specif.cli-base-rate = b_goods.cli-base-rate
              b_contract-specif.unit-base     = b_goods.unit-base
              b_contract-specif.VAT-type      = {&inc-vat}
              b_contract-specif.VAT-pc        = v-vat-pc
              b_contract-specif.prc           = buf_contract.spec-prc
              b_contract-specif.db-num        = v-cntxt-db-num
            .
      run write-bonus (
      buf_contract.contract-code ,
      buf_contract.host-code    ,
      b_goods.gds-code     ,
      v-bonus) .
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

            run recalc-gds-SpecGr
              (  /* пересчет после удаления или внесения товара в Спецификацию */
                input  '+'              ,
                input  b_goods.grp-code ,
                input  p-contract-num   ,
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
            run write-bonus (
                buf_contract.contract-code ,
                buf_contract.host-code     ,
                b_goods.gds-code           ,
                v-bonus ) .
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

        end.
      end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-ass Dlg-grp
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
    for each temp-conn,
        first bb_contract-specif no-lock  where
        recid(bb_contract-specif) = temp-conn.ri :
        run add-assmatr in this-procedure (input bb_contract-specif.gds-code ,input p-rid-list) .
    end.
    run waitfram-hide .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dlg-grp
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      character    no-undo.
define variable Line            as      character    no-undo.
define variable v-time-cr as character no-undo .
define variable v-time-up as character no-undo .
define variable v-st      as character no-undo .

DEFINE FRAME contract-list
      Buf_goods.artic FORMAT "X(16)":U
      Buf_goods.gds-name FORMAT "X(30)":U

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

FORM with FRAME contract-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(buf_contract-specif).
DO WHILE available buf_contract-specif :
  GET prev spec-list.
END.
GET next spec-list.
DO WHILE available buf_contract-specif :
  Display STREAM PrnLibStream
            Buf_goods.artic
            Buf_goods.gds-name
 with FRAME contract-list .
  DOWN STREAM PrnLibStream 1
  with FRAME contract-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next spec-list.
END.
UNDERLINE  STREAM PrnLibStream
    Buf_goods.artic
    Buf_goods.gds-name
with FRAME contract-list .

DISPLAY STREAM PrnLibStream
"ИТОГО"     @ Buf_goods.artic
accum-count @ Buf_goods.gds-name
with frame contract-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME contract-list.
output  STREAM PrnLibStream CLOSE.
REPOSITION spec-list to recid v-doc-rec no-error.
APPLY "entry" to spec-list.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-del Dlg-grp
PROCEDURE proc-del :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable is-con as logical no-undo .
define buffer b_goods for ub.goods  .
define variable v-recid as recid no-undo .
define buffer buf2_contract-specif for ub.contract-specif  .
v-err-ext = false  .
v-longchar = "".

if mark-num = 0 then do:
    if not available buf_contract-specif then return no-apply.
    message "Вы действительно хотите удалить спецификацию по товару " buf_contract-specif.gds-name "?"
    view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .
    if is-con = no then return no-apply.
    v-recid =  recid(buf_contract-specif) .
    do transaction :
      find first buf2_contract-specif exclusive-lock where recid(buf2_contract-specif) = v-recid .
      find b_goods no-lock where b_goods.gds-code = buf2_contract-specif.gds-code.
      run recalc-gds-SpecGr
        (  /* пересчет после удаления или внесения товара в Спецификацию */
          input  '-'                          ,
          input  b_goods.grp-code             ,
          input  buf2_contract-specif.contract-num ,
          input  buf2_contract-specif.host-code  )
          no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "1"
            view-as alert-box error
          .
      delete buf2_contract-specif .
      v-ask = true .
      run spedlass-proc in this-procedure
      ( input parParentProc    ,
        input b_goods.gds-code ,
        input p-contract-num   ,
        input p-host-code      ,
        input v-ask            ,
        input-output v-list-mat ,
        input-output v-err-ext ,
        input-output v-longchar

      ) no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "2"
          view-as alert-box error
        .
      assign is-new = yes .
    end.
  end.
  else do: /* удаляем списком */
    message "Вы действительно хотите удалить выбранные товары из спецификации?"
    view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .
    if is-con = no then return no-apply.

    do transaction :
      v-ask = true .
      for each temp-conn :
        find first buf2_contract-specif exclusive-lock where recid(buf2_contract-specif) = temp-conn.ri .
      find b_goods no-lock where b_goods.gds-code = buf2_contract-specif.gds-code.
      run recalc-gds-SpecGr
        (  /* пересчет после удаления или внесения товара в Спецификацию */
          input  '-'                          ,
          input  b_goods.grp-code             ,
          input  buf2_contract-specif.contract-num ,
          input  buf2_contract-specif.host-code  )
          no-error .
        delete buf2_contract-specif .
        delete temp-conn .
        /* проверка можно ли удалить в Ассортиментной матрице */
        run spedlass-proc in this-procedure
          ( input parParentProc    ,
            input b_goods.gds-code ,
            input p-contract-num   ,
            input p-host-code      ,
            input v-ask            ,
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

  define variable loc#log as logical   no-undo .
  loc#log = spec-list:select-next-row( ) IN FRAME {&FRAME-NAME}.
  apply "ENTRY" to spec-list.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-del-assMat Dlg-grp
PROCEDURE proc-del-assMat :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bb_contract-specif for ub.contract-specif  .
define buffer buf_assortment-matrix for ub.assortment-matrix  .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
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

define buffer buf_gds-obj-prop for ub.gds-obj-prop  .

run waitfram-show ("Удаление из Ассортиментных матриц")  .
v-err-ext = false  .
v-longchar = "" .
{ ref/clearlm.i }

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
              substitute ( "Принудительная смена ИЖТ &1 на <<&6>> товар &2 &3&4&5 " ,
                            buf_gds-obj-prop.gdop-igt ,
                            buf_assortment-matrix-goods.gds-code,
                            buf_assortment-matrix.obj-type,
                            buf_assortment-matrix.obj-code  ,
                            {&new-line} ,
                            {&ass-izd-empty}
                            ) .
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
          no-error
          }
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dlg-grp
PROCEDURE proc-find-code :
define input parameter p-next as logical no-undo.
define input parameter p-code as character no-undo .

define variable p-value       as integer   no-undo .
define variable p-data-valid  as logical   no-undo .
define variable p-message     as character no-undo .

  assign p-code = replace(p-code, {&single-quote}, {&single-quote} + {&single-quote}) .
  case RADIO-find :
    when 1 then do:
      run integerm ( p-code, false, false, output p-value, output p-data-valid, output p-message) .
      if p-data-valid then run OpenBr in this-procedure (input false, input p-next, input substitute('and buf_contract-specif.gds-code = &1 ', p-code)).
    end.
    when 2 then run OpenBr in this-procedure (input false, input p-next, input substitute('and buf_contract-specif.artic = "&1" ', p-code)).
    when 3 then run OpenBr in this-procedure (input false, input p-next, input substitute('and buf_contract-specif.gds-name begins "&1" ', p-code)).
    when 4 then do:
      assign p-code = lc (p-code) + "*" .
      run OpenBr in this-procedure (input false, input p-next, input substitute('and buf_contract-specif.gds-name contains "&1" ', p-code)).
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sum Dlg-grp
PROCEDURE proc-sum :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-add Dlg-grp
PROCEDURE recalc-add :
define variable v-qntySpecGr as integer  no-undo .
define variable ll as integer   no-undo .
define buffer buf2_goods for ub.goods  .
define buffer loc_temp_grplib_grp for temp_cons  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define variable v-recid as recid no-undo .
v-recid = recid (temp_grplib_grp) .
    for each loc_temp_grplib_grp :
        v-qntySpecGr = 0.
        find first buf1_gds-grp-obj-attr no-lock where
                   buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntySpecGr} and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
                   buf1_gds-grp-obj-attr.obj-code  = p-host-code and
                   buf1_gds-grp-obj-attr.host-code = 0 and
                   buf1_gds-grp-obj-attr.node-code = loc_temp_grplib_grp.node-code
        no-error .
        if available buf1_gds-grp-obj-attr then v-qntySpecGr = int(buf1_gds-grp-obj-attr.attr-value) .
        assign
          loc_temp_grplib_grp.max-marg = string(v-qntySpecGr) /* Количество товара в группе */
        .
    end.
find first temp_grplib_grp where recid(temp_grplib_grp)  = v-recid no-error .
{&OPEN-QUERY-br-list}
reposition BR-list to recid v-recid no-error.
RUN OpenBr(yes, no, '':U).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-lim Dlg-grp
PROCEDURE recalc-lim :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer loc_temp_grplib_grp for temp_grplib_grp  .
define variable v-recid as recid no-undo .

v-recid = recid (temp_grplib_grp) .
for each temp_cons :
  run calc-down-lim ( input temp_cons.node-code , output temp_cons.min-marg). /* Ограничения по ниж уровням*/
  find first loc_temp_grplib_grp where
             loc_temp_grplib_grp.node-code = temp_cons.node-code no-error .
      if available loc_temp_grplib_grp then loc_temp_grplib_grp.min-marg  = temp_cons.min-marg .
end.

find first temp_grplib_grp where recid (temp_grplib_grp)  = v-recid no-error .

{&OPEN-QUERY-br-list}
reposition BR-list to recid v-recid no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-marg-ass Dlg-grp
PROCEDURE recalc-marg-ass :
define variable v-qntyAssgrp as integer  no-undo .
define variable ll as integer   no-undo .
define buffer buf2_contract-specif for ub.contract-specif  .
define buffer buf2_goods for ub.goods  .
define buffer loc_temp_grplib_grp for temp_grplib_grp  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define variable v-recid as recid no-undo .
v-recid = recid (temp_grplib_grp) .

    for each loc_temp_grplib_grp :
      run calc-down-lim   (
          input loc_temp_grplib_grp.node-code ,
          output loc_temp_grplib_grp.min-marg). /* Ограничения по ниж уровням*/

        v-qntyAssgrp = 0.
        find first buf1_gds-grp-obj-attr no-lock where
                   buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntySpecGr} and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
                   buf1_gds-grp-obj-attr.obj-code  = p-host-code and
                   buf1_gds-grp-obj-attr.host-code = 0 and
                   buf1_gds-grp-obj-attr.node-code = loc_temp_grplib_grp.node-code
        no-error .
        if available buf1_gds-grp-obj-attr then v-qntyAssgrp = int(buf1_gds-grp-obj-attr.attr-value) .
        assign
          loc_temp_grplib_grp.max-marg = string(v-qntyAssgrp) /* Количество товара в группе */
        .

    end.

run init-tt.

find first temp_grplib_grp where recid(temp_grplib_grp)  = v-recid no-error .
{&OPEN-QUERY-br-list}
reposition BR-list to recid v-recid no-error.
RUN OpenBr(yes, no, '':U).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-alla Dlg-grp
PROCEDURE save-alla :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .
if temp_grplib_grp.cli-type:read-only in browse br-list = false then do:

  for each temp_cons :
        find first buf_gds-grp-obj-attr exclusive-lock where
                   buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr} and
                   buf_gds-grp-obj-attr.obj-type  = string(buf_contract.contract-code) and
                   buf_gds-grp-obj-attr.obj-code  = buf_contract.host-code and
                   buf_gds-grp-obj-attr.host-code = 0 and
                   buf_gds-grp-obj-attr.node-code = temp_cons.node-code no-error .
        if not available buf_gds-grp-obj-attr then create buf_gds-grp-obj-attr.
        assign
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr}
            buf_gds-grp-obj-attr.obj-type  = string(buf_contract.contract-code)
            buf_gds-grp-obj-attr.obj-code  = buf_contract.host-code
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code  = temp_cons.node-code
            buf_gds-grp-obj-attr.attr-value = temp_cons.cli-type
        .
  end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-attr Dlg-grp
PROCEDURE save-attr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

define buffer buf_gds-grp-obj-attr  for ub.gds-grp-obj-attr  .
if temp_grplib_grp.cli-type:read-only in browse br-list = false then do:
    if available  temp_grplib_grp then do:
        find first buf_gds-grp-obj-attr exclusive-lock where
                   buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr} and
                   buf_gds-grp-obj-attr.obj-type  = string(buf_contract.contract-code) and
                   buf_gds-grp-obj-attr.obj-code  = buf_contract.host-code and
                   buf_gds-grp-obj-attr.host-code = 0 and
                   buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
        if not available buf_gds-grp-obj-attr then create buf_gds-grp-obj-attr.
        assign
            buf_gds-grp-obj-attr.attr-code = {&ggoattr-LimSpecGr}
            buf_gds-grp-obj-attr.obj-type  = string(buf_contract.contract-code)
            buf_gds-grp-obj-attr.obj-code  = buf_contract.host-code
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code
            buf_gds-grp-obj-attr.attr-value = temp_grplib_grp.cli-type
        .
     end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-and-move-item Dlg-grp
PROCEDURE select-and-move-item :
/*------------------------------------------------------------------------------
  Purpose:     Перемещение группы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-upper-code        as integer           no-undo.
    define variable v-upper-recid-list  as character         no-undo.
    define variable v-yesno             as logical           no-undo.
    define variable v-node-full-name    as character         no-undo.
    define variable v-upper-full-name   as character         no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.

    if p-node-code = v-root-code
    then do:
        message
        "Корневую группу переместить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "select-and-move-item: Группа не найдена в базе данных.".
    end.
    assign
        v-upper-recid-list = string( recid( buf_gds-grp ) )
    .
    run ref/gds-grp.w (
          input parparentproc
        , input {&buttons-for-move}
        , input p-current-obj-type
        , input p-current-obj-code
        , input-output v-upper-recid-list
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора группы для перемещения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    find first buf_gds-grp no-lock
         where recid( buf_gds-grp ) = integer( entry( 1, v-upper-recid-list ) )
    no-error .
    if error-status :error
    then do:
        undo, return error "Группа не найдена.".
    end.
    run grplib-get-full-name in this-procedure (  input p-node-code
                                                , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени перемещаемой группы.".
    end.
    run grplib-get-full-name in this-procedure (  input buf_gds-grp.node-code
                                                , output v-upper-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени новой группы".
    end.

    message
        "Переместить группу"
        skip "    '" + v-node-full-name + "'"
        skip "в группу"
        skip "    '" + v-upper-full-name + "'"
    view-as alert-box question
    buttons yes-no
    title "Перемещение группы"
    update v-yesno.
    if v-yesno = no
    then do:
        /* Отказ от перемещения группы */
    end.
    else do:
        run move-item in this-procedure ( input p-node-code
                                        , input buf_gds-grp.node-code
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка перемещения группы."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
end.
END PROCEDURE. /* select-and-move-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on Dlg-grp
PROCEDURE UI-on :
/*------------------------------------------------------------------------------
  Purpose:     Заполнение temp_grplib_grp и инициализация при старте программы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define variable v-reposition-row        as integer          no-undo.
define variable v-focused-row           as integer          no-undo.
define variable v-reposition-to-recid   as logical init no  no-undo.
define variable v-enable-change-grp     as logical          no-undo.
define variable v-margins-range         as integer          no-undo.
define variable v-margins-exists        as logical          no-undo.
define variable v-increase-range         as integer          no-undo.
define variable v-increase-exists        as logical          no-undo.
define variable v-min-marg              as decimal          no-undo.
define variable v-max-marg              as decimal          no-undo.
define variable v-increase-pc              as decimal          no-undo.
define variable v-have-goods            as logical          no-undo.
define variable v-round-method      as character   no-undo .
define variable v-base                  as decimal no-undo .
define variable v-rmethod-range     as integer     no-undo.
define variable v-rmethod-exists    as logical     no-undo.
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer     no-undo.
define variable v-income-cli-range    as integer  no-undo.
define variable v-income-cli-exists   as logical  no-undo.
define variable v-dop                   as character no-undo .
define variable v-full-name             as character    no-undo.
define variable v-sort-name             as character    no-undo.


define buffer buf_gds-grp           for ub.gds-grp.
define buffer buf_temp_grplib_grp   for temp_grplib_grp.

{ gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_groups-edit':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    no
    v-enable-change-grp
}
run grplib-get-root-code in this-procedure ( output v-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + {&new-line} + return-value.
end.
if v-from-b-gds then do:
/*ВНИМАНИЕ!!!!*/
/*здесб обрабаотна ситуация когда пользователь зашел по кнопке ТОВАРЫ в справочник товаров*/
/*если он там переключался в другие группы товаров, то это происходило через справочник групп товаров и все настройки уже сменились*/
/*мы их получим через uf-get и на выходе из справочника ТОВАРОВ постараемся встать в ту группу товаров, в которой он там стоял*/
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  v-dop = string((if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_)))
  .
  /*если пользователь никуда не переключался по группам товаров в справочнике товаров нам не надо переоткрывать броуз - стоим на месте*/
  if v-dop = v-old-recid-list then do:
    assign
    gds-grp-row = v-old-recid
    .
  end.
  else do:
    assign
    gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
    .
  end.
  assign
      p-recid-list = string( gds-grp-row )
  .
  assign
  v-from-b-gds = no
  v-old-recid-list = "":U.


end.
else do:
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
  .
  assign
      p-recid-list = string( gds-grp-row )
  .
end.
find first buf_gds-grp no-lock
     where buf_gds-grp.node-code = v-root-code
no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не найдена запись корневого узла."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
if buf_gds-grp.is-term = yes
then do:
    run grplib-have-goods in this-procedure (
          input buf_gds-grp.node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
end.
for each buf_temp_grplib_grp
:
    delete buf_temp_grplib_grp.
end.
create buf_temp_grplib_grp.
assign
    buf_temp_grplib_grp.node-code   = buf_gds-grp.node-code
    buf_temp_grplib_grp.upper-code  = buf_gds-grp.upper-code
    buf_temp_grplib_grp.level       = 0
    buf_temp_grplib_grp.mark        = ( if v-have-goods = yes then {&terminal-with-goods-grp-mark} else {&terminal-no-goods-grp-mark} )
    buf_temp_grplib_grp.full-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.sort-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.name        = buf_gds-grp.node-name
    buf_temp_grplib_grp.increase-pc = buf_gds-grp.increase-pc
    buf_temp_grplib_grp.calc-method = buf_gds-grp.calc-method
.
for each buf_gds-grp no-lock
   where buf_gds-grp.upper-code = v-root-code
:
    run grplib-get-full-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run grplib-get-sort-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input "":U
        , input "":U
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "UI-on: Ошибка добавления строки в список групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
end.
if  p-recid-list <> "" and p-recid-list <> ?
then do:        /* Раскрыть ветку группы с recid-ом из списка */
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    find first buf_gds-grp no-lock
         where recid( buf_gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) )
    no-error .
    if not available buf_gds-grp
    then do:
        /* Не найдена группа, выбранная в прошлый раз. */
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
            input buf_gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + {&new-line} + return-value.
        end.
    end.
end.
run enable_UI.


hide
        b-mark      in frame {&frame-name}
     .
case p-button-list
:
when {&buttons-for-move}
then do:
    disable
        b-exit    with frame {&frame-name}
    .
end.
when {&buttons-for-admin}
then do:
end.
when {&buttons-sel-scales}
then do:
end.
when {&buttons-sel-term} or when {&button-sel-only}
then do:
end.
when {&buttons-sel-mark}
then do:
    view
        b-mark in frame {&frame-name}
    .
end.
end case.
if v-current-store-code = 0
or transaction
then do:
end.

br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.

run recalc-marg-ass.

if v-reposition-to-recid = no
then do:
    reposition br-list to row v-reposition-row.
end.
else do:
    reposition br-list to recid v-reposition-row.
end.
RUN OpenBr(yes, no, '':U).

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on-0 Dlg-grp
PROCEDURE UI-on-0 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
do
on error undo, return error
:
define variable v-reposition-row        as integer          no-undo.
define variable v-focused-row           as integer          no-undo.
define variable v-reposition-to-recid   as logical init no  no-undo.
define variable v-enable-change-grp     as logical          no-undo.
define variable v-margins-range         as integer          no-undo.
define variable v-margins-exists        as logical          no-undo.
define variable v-increase-range         as integer          no-undo.
define variable v-increase-exists        as logical          no-undo.
define variable v-min-marg              as decimal          no-undo.
define variable v-max-marg              as decimal          no-undo.
define variable v-increase-pc              as decimal          no-undo.
define variable v-have-goods            as logical          no-undo.
define variable v-round-method      as character   no-undo .
define variable v-base                  as decimal no-undo .
define variable v-rmethod-range     as integer     no-undo.
define variable v-rmethod-exists    as logical     no-undo.
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer     no-undo.
define variable v-income-cli-range    as integer  no-undo.
define variable v-income-cli-exists   as logical  no-undo.
define variable v-dop                   as character no-undo .
define variable v-full-name             as character    no-undo.
define variable v-sort-name             as character    no-undo.


define buffer buf_gds-grp           for ub.gds-grp.
define buffer buf_temp_grplib_grp   for temp_grplib_grp.

{ gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_groups-edit':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    no
    v-enable-change-grp
}
run grplib-get-root-code in this-procedure ( output v-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + {&new-line} + return-value.
end.
if v-from-b-gds then do:
/*ВНИМАНИЕ!!!!*/
/*здесб обрабаотна ситуация когда пользователь зашел по кнопке ТОВАРЫ в справочник товаров*/
/*если он там переключался в другие группы товаров, то это происходило через справочник групп товаров и все настройки уже сменились*/
/*мы их получим через uf-get и на выходе из справочника ТОВАРОВ постараемся встать в ту группу товаров, в которой он там стоял*/
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  v-dop = string((if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_)))
  .
  /*если пользователь никуда не переключался по группам товаров в справочнике товаров нам не надо переоткрывать броуз - стоим на месте*/
  if v-dop = v-old-recid-list then do:
    assign
    gds-grp-row = v-old-recid
    .
  end.
  else do:
    assign
    gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
    .
  end.
  assign
      p-recid-list = string( gds-grp-row )
  .
  assign
  v-from-b-gds = no
  v-old-recid-list = "":U.


end.
else do:
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
  .
  assign
      p-recid-list = string( gds-grp-row )
  .
end.

find first buf_gds-grp no-lock
     where buf_gds-grp.node-code = v-root-code
no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не найдена запись корневого узла."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
if buf_gds-grp.is-term = yes
then do:
    run grplib-have-goods in this-procedure (
          input buf_gds-grp.node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
end.
for each buf_temp_grplib_grp
:
    delete buf_temp_grplib_grp.
end.
create buf_temp_grplib_grp.
assign
    buf_temp_grplib_grp.node-code   = buf_gds-grp.node-code
    buf_temp_grplib_grp.upper-code  = buf_gds-grp.upper-code
    buf_temp_grplib_grp.level       = 0
    buf_temp_grplib_grp.mark        = ( if v-have-goods = yes then {&terminal-with-goods-grp-mark} else {&terminal-no-goods-grp-mark} )
    buf_temp_grplib_grp.full-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.sort-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.name        = buf_gds-grp.node-name
    buf_temp_grplib_grp.increase-pc = buf_gds-grp.increase-pc
    buf_temp_grplib_grp.calc-method = buf_gds-grp.calc-method
.
for each buf_gds-grp no-lock
   where buf_gds-grp.upper-code = v-root-code
:
    run grplib-get-full-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run grplib-get-sort-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input "":U
        , input "":U
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "UI-on: Ошибка добавления строки в список групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
end.


    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    for each buf_gds-grp no-lock
         /*where recid( buf_gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) ) */
         :
        run expand-tree-for-grp in this-procedure (
            input buf_gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + {&new-line} + return-value.
        end.
    end.


run enable_UI.

display b-mark with frame {&frame-name} .
enable  b-mark with frame {&frame-name} .

if v-current-store-code = 0
or transaction
then do:
end.

br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.

run recalc-marg-ass.

if v-reposition-to-recid = no
then do:
    reposition br-list to row v-reposition-row.
end.
else do:
    reposition br-list to recid v-reposition-row.
end.
RUN OpenBr(yes, no, '':U).

end.

for each temp_grplib_grp :
    find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
        if not available temp_cons then create temp_cons.
        assign
            temp_cons.full-name  = temp_grplib_grp.full-name
            temp_cons.node-code  = temp_grplib_grp.node-code
            temp_cons.upper-code = temp_grplib_grp.upper-code
            temp_cons.min-marg   = temp_grplib_grp.min-marg
            temp_cons.max-marg   = temp_grplib_grp.max-marg
            temp_cons.cli-type   = temp_grplib_grp.cli-type
        .
end.

run recalc-lim in this-procedure .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-attr Dlg-grp
PROCEDURE ver-attr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf1_gds-grp-obj-attr no-lock where
           buf1_gds-grp-obj-attr.attr-code = {&ggoattr-QntySpecGr} and
           buf1_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
           buf1_gds-grp-obj-attr.obj-code  = p-host-code and
           buf1_gds-grp-obj-attr.host-code = 0 no-error .
if not available buf1_gds-grp-obj-attr then do:
   run utl/uspemgrp.p ( input p-contract-num,input p-host-code ) no-error .
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-db Dlg-grp
PROCEDURE ver-db :
if v-cntxt-db-num <> 0 then do:
          message
            "Нельзя редактировать В УБД"
            view-as alert-box error.
            return  error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-db1 Dlg-grp
PROCEDURE ver-db1 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 /* Проверка прав */   /* "actn_fin-contract_grp_mod" для спецификации */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-grp_update':U
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
 if not v-log then temp_grplib_grp.cli-type:read-only in browse br-list = true .


if v-cntxt-db-num <> 0 then do:
   temp_grplib_grp.cli-type:read-only in browse br-list = true .
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