&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-FBR-DOC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-FBR-DOC 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Документ производства.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Output:

Поправить после UIB!!!  Должно быть:

DEFINE new shared QUERY br-comp FOR
      buf_comp_fbr-line except SCROLLING.

DEFINE new shared QUERY br-ingr FOR
      buf_ingr_fbr-line except SCROLLING.

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc             as handle    no-undo .
define input  parameter p-fbrhist-handle          as handle    no-undo .
define input  parameter p-doc-mode                as character no-undo .
define input  parameter p-fbr-doc-recid           as recid     no-undo .
define output parameter p-new-fbr-doc-recid       as recid     no-undo .
define input-output parameter p-fbr-doc-next-prev as logical   no-undo .
{ gbl/objsrv.i }

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Документ производства.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ str/doc-code.i }
{ gbl/color.i    }
{ str/writelog.i def "'fbr.log'" no-create }
{ trg/partslib.i }
{ str/temp_upd.i }
{ str/fbrcode.i  }
{ str/fbrlib.i   }
{ str/fbrrest.i  }
{ str/fbradd.i   }
{ cmp/showinf.i  }
{ gbl/userobjs.i }
{ gbl/fltopend.i defproc }
{ ref/gds-attr.i }
{ ref/gdsoattr.i   }
{ gbl/ggoattr.i  }
{ utl/gtin.i }
{ str/utd-typemark.i }

define shared variable br-handle as handle no-undo.
define shared buffer f-doc for ub.fbr-doc.
define shared query br-docs     for f-doc scrolling.

define new shared buffer buf_comp_fbr-line for ub.fbr-line.
define new shared buffer buf_ingr_fbr-line for ub.fbr-line.
define variable ref-list                   as character no-undo.                    /* для вызова справочника */

define variable v-fbr-doc-fbroperator-code as integer   no-undo.

define variable v-price-sale-obj-type      as character no-undo.
define variable v-price-sale-obj-code      as integer   no-undo.
define variable v-artic                    as character initial " " no-undo. /* вспомогательная */
define variable current-browse             as handle    no-undo. /* текущий browse */

define variable comp-OK                    as logical   no-undo.    /* для вычисляемого поля в browse */
define variable comp-prod                  as logical   no-undo.    /* для вычисляемого поля в browse */
define variable comp-name                  as character no-undo.    /* для вывода поля goods в browse */
define variable comp-unit                  as character no-undo.    /* для вывода поля goods в browse */
define variable ingr-OK                    as logical   no-undo.    /* для вычисляемого поля в browse */
define variable ingr-prod                  as logical   no-undo.    /* для вычисляемого поля в browse */
define variable ingr-name                  as character no-undo.    /* для вывода поля goods в browse */
define variable ingr-unit                  as character no-undo.    /* для вывода поля goods в browse */
define variable ingr-netto                 as decimal   no-undo.
define variable comp-sort-column-name      as character no-undo .   /* имя сортируемой колонки */
define variable ingr-sort-column-name      as character no-undo .   /* имя сортируемой колонки */
define variable v-close-enabled            as logical   init no no-undo.
define variable v-need-refresh             as logical   init no no-undo.
define variable v-fbr-doc-line-rec         as recid     no-undo.
define variable v-fbr-doc-g-log            as logical   no-undo.
define variable v-fbr-doc-rep-rec          as recid     no-undo.
define variable gds-rec                    as recid     no-undo.


define variable v-ban-recipes   as logical      no-undo .
define variable v-ban-altr      as logical      no-undo .
define variable v-base                     as logical   init no no-undo.

define variable bcol as handle extent no-undo.
define variable hBrowse as handle no-undo.
define variable bcol_comp as handle extent no-undo.
define variable hBrowse_comp as handle no-undo.
define variable ii as integer no-undo.

define new shared buffer flt-gds      for ub.goods.                                /* для режима ТОВАР */

define            buffer buf_parts    for ub.parts.


define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-tth             as handle    no-undo .
define variable v-back-date       as logical   no-undo . /* включено ли закрытие задним числом */
define variable v-back-date-type  as character no-undo .

define variable is-shift-on       as logical   no-undo. /* включены ли смены на объекте */

define variable v-mark-weight as decimal no-undo .
define variable v-isweighed as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME D-FBR-DOC
&Scoped-define BROWSE-NAME br-comp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_comp_fbr-line buf_ingr_fbr-line

/* Definitions for BROWSE br-comp                                       */
&Scoped-define FIELDS-IN-QUERY-br-comp buf_comp_fbr-line.artic get-goods-name(recid(buf_comp_fbr-line)) @ comp-name buf_comp_fbr-line.trn-type get-line-OK(recid(buf_comp_fbr-line)) @ comp-OK buf_comp_fbr-line.fact-qnty get-unit-base(recid(buf_comp_fbr-line)) @ comp-unit buf_comp_fbr-line.is-calc buf_comp_fbr-line.price-sale buf_comp_fbr-line.fix-cost buf_comp_fbr-line.price-base buf_comp_fbr-line.price-sum-base buf_comp_fbr-line.price-sum-vat-base buf_comp_fbr-line.price-rubl buf_comp_fbr-line.price-sum-rubl buf_comp_fbr-line.price-sum-vat-rubl buf_comp_fbr-line.rsrv-qnty get-prod-ref(recid(buf_comp_fbr-line)) @ comp-prod   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-comp buf_comp_fbr-line.is-calc ~
buf_comp_fbr-line.fix-cost ~
buf_comp_fbr-line.price-rubl ~
buf_comp_fbr-line.price-sum-vat-rubl   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-comp buf_comp_fbr-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-comp buf_comp_fbr-line
&Scoped-define SELF-NAME br-comp
&Scoped-define QUERY-STRING-br-comp FOR EACH buf_comp_fbr-line NO-LOCK
&Scoped-define OPEN-QUERY-br-comp OPEN QUERY {&SELF-NAME} FOR EACH buf_comp_fbr-line NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-comp buf_comp_fbr-line
&Scoped-define FIRST-TABLE-IN-QUERY-br-comp buf_comp_fbr-line


/* Definitions for BROWSE br-ingr                                       */
&Scoped-define FIELDS-IN-QUERY-br-ingr buf_ingr_fbr-line.artic buf_ingr_fbr-line.recipe-code get-goods-name(recid(buf_ingr_fbr-line)) @ ingr-name buf_ingr_fbr-line.trn-type get-line-OK(recid(buf_comp_fbr-line)) @ ingr-OK buf_ingr_fbr-line.fact-qnty get-unit-base(recid(buf_ingr_fbr-line)) @ ingr-unit buf_ingr_fbr-line.is-calc buf_ingr_fbr-line.price-sale buf_ingr_fbr-line.fix-cost buf_ingr_fbr-line.coeff-waste buf_ingr_fbr-line.coeff-value get-netto-qnty(recid(buf_comp_fbr-line)) @ ingr-netto buf_ingr_fbr-line.price-base buf_ingr_fbr-line.price-sum-base buf_ingr_fbr-line.price-sum-vat-base buf_ingr_fbr-line.price-rubl buf_ingr_fbr-line.price-sum-rubl buf_ingr_fbr-line.price-sum-vat-rubl buf_ingr_fbr-line.rsrv-qnty get-prod-ref(recid(buf_comp_fbr-line)) @ ingr-prod   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ingr buf_ingr_fbr-line.is-calc ~
buf_ingr_fbr-line.fix-cost ~
buf_ingr_fbr-line.fact-qnty ~
buf_ingr_fbr-line.price-sale ~
buf_ingr_fbr-line.price-base ~
buf_ingr_fbr-line.price-rubl ~
buf_ingr_fbr-line.price-sum-vat-base ~
buf_ingr_fbr-line.price-sum-vat-rubl   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-ingr buf_ingr_fbr-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-ingr buf_ingr_fbr-line
&Scoped-define SELF-NAME br-ingr
&Scoped-define QUERY-STRING-br-ingr FOR EACH buf_ingr_fbr-line NO-LOCK
&Scoped-define OPEN-QUERY-br-ingr OPEN QUERY {&SELF-NAME} FOR EACH buf_ingr_fbr-line NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-ingr buf_ingr_fbr-line
&Scoped-define FIRST-TABLE-IN-QUERY-br-ingr buf_ingr_fbr-line


/* Definitions for DIALOG-BOX D-FBR-DOC                                 */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS fbr-recipe.recipe-code ~
fbr-recipe-gds.is-waste fbr-recipe.recipe-name fbr-recipe.qnty 
&Scoped-define ENABLED-TABLES fbr-recipe fbr-recipe-gds
&Scoped-define FIRST-ENABLED-TABLE fbr-recipe
&Scoped-define SECOND-ENABLED-TABLE fbr-recipe-gds
&Scoped-Define ENABLED-OBJECTS br-comp br-ingr fi-pay-code b-exit b-prev ~
b-next b-rsrv b-gds b-parts out-code r-outs obj-price r-price b-help ~
b-recipe b-lkp b-add b-chg b-del rs-one-all obj-fbroperator r-fbroperator ~
r-pay shift-sel b-add-marks
&Scoped-Define DISPLAYED-FIELDS fbr-recipe.recipe-code ~
fbr-recipe.recipe-type fbr-recipe-gds.is-waste fbr-recipe.recipe-name ~
fbr-recipe.qnty 
&Scoped-define DISPLAYED-TABLES fbr-recipe fbr-recipe-gds
&Scoped-define FIRST-DISPLAYED-TABLE fbr-recipe
&Scoped-define SECOND-DISPLAYED-TABLE fbr-recipe-gds
&Scoped-Define DISPLAYED-OBJECTS fi-pay-code fi-pay-type-name out-code ~
obj-price rs-one-all effect obj-fbroperator fact-date shift 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-goods-name D-FBR-DOC 
FUNCTION get-goods-name RETURNS CHARACTER
   ( p-fbr-line-recid AS RECID )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-line-OK D-FBR-DOC 
FUNCTION get-line-OK RETURNS logical
   ( p-fbr-line-recid AS RECID /* buffer buf_fbr-line for ub.fbr-line */)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-netto-qnty D-FBR-DOC 
FUNCTION get-netto-qnty RETURNS DECIMAL
   ( p-fbr-line-recid AS RECID /* buffer buf_fbr-line for ub.fbr-line */)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-prod-ref D-FBR-DOC 
FUNCTION get-prod-ref RETURNS CHARACTER
   ( p-fbr-line-recid AS RECID /* buffer buf_fbr-line for ub.fbr-line*/ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-unit-base D-FBR-DOC 
FUNCTION get-unit-base RETURNS CHARACTER
   (  p-fbr-line-recid AS RECID /*buffer buf_fbr-line for ub.fbr-line*/ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD need-marks D-FBR-DOC 
FUNCTION need-marks RETURNS logical
   (  buffer local-fbr-line for ub.fbr-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-add 
   MENU-ITEM m-rcp-add      LABEL "Товар с &рецептом"
   MENU-ITEM m-all-add      LABEL "Товары по в&сем связанным рецептам"
   MENU-ITEM m-comp-add     LABEL "Товар без рецепта в &верхний список"
   MENU-ITEM m-ingr-add     LABEL "Товар без рецепта в &нижний список".

DEFINE MENU m-del 
   MENU-ITEM m-rcp-del      LABEL "Товар с &рецептом"
   MENU-ITEM m-all-del      LABEL "Товары по в&сем связанным рецептам"
   MENU-ITEM m-all-doc-del  LABEL "Вс&е товары документа"
   MENU-ITEM m-comp-del     LABEL "Товар без рецепта в &верхнем списке"
   MENU-ITEM m-ingr-del     LABEL "Товар без рецепта в &нижнем списке".

DEFINE MENU m-outs 
   MENU-ITEM m-sale         LABEL "&Продажа"      
   MENU-ITEM m-doc          LABEL "&Накладная"    
   MENU-ITEM m-ord          LABEL "&Заказ"        .

DEFINE MENU POPUP-MENU-b-rsrv 
   MENU-ITEM m-doc-rsrv     LABEL "По всему &документу"
   MENU-ITEM m-rcp-rsrv     LABEL "По текущему &рецепту".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
   LABEL "&Добавить" 
   SIZE 10 BY 1 TOOLTIP "Добавление строк по рецепту (или без него)".
   
DEFINE BUTTON b-add-marks 
   LABEL "Доб. &марки" 
   SIZE 12 BY 1 TOOLTIP "Добавление марок по текущей строке".

DEFINE BUTTON b-calc-comp 
   LABEL "С&ост" 
   SIZE 6 BY 1 TOOLTIP "Расчет полученного товара от строк ингредиентов по рецепту".

DEFINE BUTTON b-calc-ingr 
   LABEL "Ин&гр" 
   SIZE 6 BY 1 TOOLTIP "Расчет строк ингредиентов от полученного товара по рецепту".

DEFINE BUTTON b-chg 
   LABEL "&Изменить" 
   SIZE 10 BY 1 TOOLTIP "Изменение строки составного товара".

DEFINE BUTTON b-del 
   LABEL "&Удалить" 
   SIZE 10 BY 1 TOOLTIP "Удаление строк по рецепту (или без него)".

DEFINE BUTTON b-exit 
   LABEL "&Выход " 
   SIZE 10 BY 1 TOOLTIP "Выход из документа с сохранением состояния"
   BGCOLOR 8 .

DEFINE BUTTON b-gds 
   LABEL "Товар&ы" 
   SIZE 10 BY 1 TOOLTIP "Просмотр документа производства по товарам"
   BGCOLOR 8 .

DEFINE BUTTON b-help 
   LABEL "Помо&щь" 
   SIZE 10 BY 1 TOOLTIP "Помощь"
   BGCOLOR 8 .

DEFINE BUTTON b-lkp 
   LABEL "&Просмотр" 
   SIZE 10 BY 1 TOOLTIP "Просмотр строки составного товара".

DEFINE BUTTON b-next AUTO-GO 
   LABEL "&>>" 
   SIZE 3 BY 1 TOOLTIP "Переход к просмотру следующего документа списка".

DEFINE BUTTON b-parts 
   LABEL "&Партии" 
   SIZE 10 BY 1 TOOLTIP "Просмотр или редактирование партий товара"
   BGCOLOR 8 .

DEFINE BUTTON b-prev AUTO-GO 
   LABEL "&<<" 
   SIZE 3 BY 1 TOOLTIP "Переход к просмотру предыдущего документа списка".

DEFINE BUTTON b-recipe 
   LABEL "&Рецепт" 
   SIZE 10 BY 1 TOOLTIP "Просмотр или исправление рецепта для текущей строки".

DEFINE BUTTON b-rsrv 
   LABEL "Ре&зерв" 
   SIZE 10 BY 1 TOOLTIP "Резервирование списываемого товара"
   BGCOLOR 8 .

DEFINE BUTTON r-fbroperator 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-price" 
   SIZE 3 BY .88 TOOLTIP "Выбор ответственного за операции производства".

DEFINE BUTTON r-outs 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-outs" 
   SIZE 3 BY .88 TOOLTIP "Список накладных по объекту".

DEFINE BUTTON r-pay 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-pay" 
   SIZE 3 BY .88 TOOLTIP "Выбор объекта, с которого берутся цены продажи".

DEFINE BUTTON r-price 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-price" 
   SIZE 3 BY .88 TOOLTIP "Выбор объекта, с которого берутся цены продажи".

DEFINE BUTTON shift-sel 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "" 
   SIZE 3 BY .88.

DEFINE VARIABLE effect           AS DECIMAL   FORMAT "->>,>>9.99%":U INITIAL 0 
   LABEL "Эфф" 
   VIEW-AS FILL-IN 
   SIZE 8.25 BY 1 TOOLTIP "Эффективность: увеличение суммы продажных цен в процентах"
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE fact-date        AS DATE      FORMAT "99/99/99":U 
   LABEL "Факт" 
   VIEW-AS FILL-IN 
   SIZE 9.75 BY 1 TOOLTIP "Факт дата закрытия"
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE fi-pay-code      AS INTEGER   FORMAT "99999":U INITIAL 0 
   LABEL "&Опл" 
   VIEW-AS FILL-IN 
   SIZE 6.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-pay-type-name AS CHARACTER FORMAT "X(40)":U 
   VIEW-AS FILL-IN 
   SIZE 12.5 BY 1
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE ingr-goods-type  AS CHARACTER FORMAT "X(1)":U 
   VIEW-AS FILL-IN 
   SIZE 2.38 BY 1 TOOLTIP "Буква У появляется, если это услуга"
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE ingr-long        AS CHARACTER FORMAT "X(256)":U 
   LABEL "Товар" 
   VIEW-AS FILL-IN 
   SIZE 66 BY 1 TOOLTIP "Полное название товара из нижнего списка"
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE obj-fbroperator  AS CHARACTER FORMAT "X(256)":U 
   LABEL "Ответственный" 
   VIEW-AS FILL-IN 
   SIZE 13 BY 1 TOOLTIP "Ответственный за операции производства"
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE obj-price        AS CHARACTER FORMAT "X(256)":U 
   LABEL "Цены" 
   VIEW-AS FILL-IN 
   SIZE 12.38 BY 1 TOOLTIP "Объект, с которого берутся цены продажи"
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE out-code         AS CHARACTER FORMAT "X(16)":U 
   LABEL "Ис&т" 
   VIEW-AS FILL-IN 
   SIZE 16.13 BY 1 TOOLTIP "Номер накладной для добавления строк из нее" NO-UNDO.

DEFINE VARIABLE shift            AS CHARACTER FORMAT "X(256)":U 
   LABEL "Смена" 
   VIEW-AS FILL-IN 
   SIZE 11 BY 1
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE tot-qnty         AS DECIMAL   FORMAT "->,>>>,>>9.99":U INITIAL 0 
   LABEL "Сумма по фракциям" 
   VIEW-AS FILL-IN 
   SIZE 13.5 BY 1.08 NO-UNDO.

DEFINE VARIABLE rs-one-all       AS CHARACTER 
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS 
   "В&се", "all",
   "Ре&цепт", "recipe",
   "&Тип", "type",
   "Тов&ар", "goods"
   SIZE 28.63 BY .88 TOOLTIP "Строки по всем или для текущего рецепта, по типам, по товару" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-comp FOR 
   buf_comp_fbr-line SCROLLING.

DEFINE QUERY br-ingr FOR 
   buf_ingr_fbr-line SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-comp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-comp D-FBR-DOC _FREEFORM
   QUERY br-comp NO-LOCK DISPLAY
   buf_comp_fbr-line.artic                                   format "x(16)"              column-label "Артикул"
   get-goods-name(recid(buf_comp_fbr-line)) @ comp-name      format "x(25)"              column-label "Название"
   buf_comp_fbr-line.trn-type                                format "x(3)"               column-label "Тип"
   get-line-OK(recid(buf_comp_fbr-line)) @ comp-OK           format "+/-"                column-label "OK"
   buf_comp_fbr-line.fact-qnty                               format ">>>>>9.999"         column-label "Количество"
   get-unit-base(recid(buf_comp_fbr-line)) @ comp-unit       format "x(3)"               column-label "Изм"
   buf_comp_fbr-line.is-calc                                 format "*/-"                column-label "Ф"
   buf_comp_fbr-line.price-sale                              format ">>>,>>9.<<"         column-label "Цена продажи"
   buf_comp_fbr-line.fix-cost                                format "*/-"                column-label "Ф"
   buf_comp_fbr-line.price-base                              format "->>>,>>>,>>9.<<<"   column-label "Уч.ц.(б.в)"
   buf_comp_fbr-line.price-sum-base                          format "->,>>>,>>>,>>9.<<<" column-label "Сумма (б.в)"
   buf_comp_fbr-line.price-sum-vat-base                      format "->,>>>,>>>,>>9.<<<" column-label "НДС (б.в)"
   buf_comp_fbr-line.price-rubl                              format "->>>,>>>,>>9.<<<"   column-label "Уч.ц.({&abbr_rub})"
   buf_comp_fbr-line.price-sum-rubl                          format "->,>>>,>>>,>>9.<<<" column-label "Сумма ({&abbr_rub})"
   buf_comp_fbr-line.price-sum-vat-rubl                      format "->,>>>,>>>,>>9.<<<" column-label "НДС ({&abbr_rub})"
   buf_comp_fbr-line.rsrv-qnty                               format ">>,>>>,>>9.<<<" column-label "Допустимо"
   get-prod-ref(recid(buf_comp_fbr-line)) @ comp-prod        format "x(14)"          column-label "Производитель"
ENABLE
      buf_comp_fbr-line.is-calc
      buf_comp_fbr-line.fix-cost
      buf_comp_fbr-line.price-rubl
      buf_comp_fbr-line.price-sum-vat-rubl
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 7.13.

DEFINE BROWSE br-ingr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ingr D-FBR-DOC _FREEFORM
   QUERY br-ingr DISPLAY
   buf_ingr_fbr-line.artic                                   format "X(16)"              column-label "Артикул"
   buf_ingr_fbr-line.recipe-code                             format "X(10)"              column-label "    Рецепт"
   get-goods-name(recid(buf_ingr_fbr-line)) @ ingr-name      format "X(24)"              column-label "Название"
   buf_ingr_fbr-line.trn-type                                format "X(3)"               column-label "Тип"
   get-line-OK(recid(buf_comp_fbr-line)) @ ingr-OK           format "+/-"                column-label "OK"
   buf_ingr_fbr-line.fact-qnty                               format ">>>>>9.999"         column-label "Брутто"
   get-unit-base(recid(buf_ingr_fbr-line)) @ ingr-unit       format "X(3)"               column-label "Изм"
   buf_ingr_fbr-line.is-calc                                 format "*/-"                column-label "Ф"
   buf_ingr_fbr-line.price-sale                              format ">>,>>>,>>9.<<"      column-label "Цена продажи"
   buf_ingr_fbr-line.fix-cost                                format "*/-"                column-label "Ф"
   buf_ingr_fbr-line.coeff-waste                             format "->,>>9.<<<"         column-label "%потерь"
   buf_ingr_fbr-line.coeff-value                             format "->,>>9.<<<"         column-label "%сезонн"
   get-netto-qnty(recid(buf_ingr_fbr-line)) @ ingr-netto     format ">>>>>9.999"         column-label "Нетто"
   buf_ingr_fbr-line.price-base                              format "->>>,>>>,>>9.<<<"   column-label "Уч.ц.(б.в)"
   buf_ingr_fbr-line.price-sum-base                          format "->,>>>,>>>,>>9.<<<" column-label "Сумма (б.в)"
   buf_ingr_fbr-line.price-sum-vat-base                      format "->,>>>,>>>,>>9.<<<" column-label "НДС (б.в)"
   buf_ingr_fbr-line.price-rubl                              format "->>>,>>>,>>9.<<<"   column-label "Уч.ц.({&abbr_rub})"
   buf_ingr_fbr-line.price-sum-rubl                          format "->,>>>,>>>,>>9.<<<" column-label "Сумма ({&abbr_rub})"
   buf_ingr_fbr-line.price-sum-vat-rubl                      format "->,>>>,>>>,>>9.<<<" column-label "НДС ({&abbr_rub})"
   buf_ingr_fbr-line.rsrv-qnty                               format ">>,>>>,>>9.<<<"     column-label "Допустимо"
   get-prod-ref(recid(buf_comp_fbr-line)) @ ingr-prod        format "X(14)"              column-label "Производитель"
ENABLE
      buf_ingr_fbr-line.is-calc
      buf_ingr_fbr-line.fix-cost
      buf_ingr_fbr-line.fact-qnty
      buf_ingr_fbr-line.price-sale
      buf_ingr_fbr-line.price-base
      buf_ingr_fbr-line.price-rubl
      buf_ingr_fbr-line.price-sum-vat-base
      buf_ingr_fbr-line.price-sum-vat-rubl
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 8.63.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-FBR-DOC
   br-comp AT ROW 5.25 COL 2
   br-ingr AT ROW 15.13 COL 2
   fi-pay-code AT ROW 2.5 COL 76.5 COLON-ALIGNED
   fi-pay-type-name AT ROW 2.5 COL 83.5 COLON-ALIGNED NO-LABEL
   b-exit AT ROW 1.21 COL 2
   b-prev AT ROW 1.21 COL 12
   b-next AT ROW 1.21 COL 15
   b-rsrv AT ROW 1.21 COL 18
   b-gds AT ROW 1.21 COL 28
   b-parts AT ROW 1.21 COL 38
   out-code AT ROW 1.21 COL 43.25 COLON-ALIGNED
   r-outs AT ROW 1.21 COL 61.88
   obj-price AT ROW 1.21 COL 70 COLON-ALIGNED
   r-price AT ROW 1.21 COL 84.38
   b-help AT ROW 1.21 COL 88.25
   b-recipe AT ROW 3.83 COL 2
   b-lkp AT ROW 12.71 COL 2
   b-add AT ROW 12.71 COL 12
   b-chg AT ROW 12.71 COL 22
   b-del AT ROW 12.71 COL 32
   b-calc-ingr AT ROW 12.71 COL 42
   b-calc-comp AT ROW 12.71 COL 48
   b-add-marks AT ROW 12.71 COL 54
   rs-one-all AT ROW 12.71 COL 67.75 NO-LABEL
   fbr-recipe.recipe-code AT ROW 3.75 COL 13.38 COLON-ALIGNED NO-LABEL
   VIEW-AS FILL-IN 
   SIZE 12.63 BY 1.08 TOOLTIP "Номер рецепта текущей строки"
   FGCOLOR 4 
   fbr-recipe.recipe-type AT ROW 3.75 COL 10.63 COLON-ALIGNED NO-LABEL FORMAT "X(1)"
   VIEW-AS FILL-IN 
   SIZE 2.5 BY 1.08 TOOLTIP "Тип рецепта: к - комплектация, а - альтернатива, п - производство, р - разделка"
   FGCOLOR 4 
   fbr-recipe-gds.qnty AT ROW 13.96 COL 87.63 COLON-ALIGNED
   LABEL "Коэф"
   VIEW-AS FILL-IN 
   SIZE 6.5 BY 1 TOOLTIP "Количество текущего ингредиента по рецепту"
   FGCOLOR 4 
   fbr-recipe-gds.is-waste AT ROW 13.96 COL 78.75 COLON-ALIGNED NO-LABEL FORMAT "*/."
   VIEW-AS FILL-IN 
   SIZE 2.5 BY 1 TOOLTIP "Звездочка зажигается, если это ОТХОДЫ"
   FGCOLOR 4 
   fbr-recipe.recipe-name AT ROW 3.75 COL 24.5 COLON-ALIGNED NO-LABEL
   VIEW-AS FILL-IN 
   SIZE 43.75 BY 1.08 TOOLTIP "Название рецепта текущей строки"
   FGCOLOR 4 
   ingr-goods-type AT ROW 13.96 COL 76.5 COLON-ALIGNED NO-LABEL
   fbr-recipe.qnty AT ROW 3.79 COL 88.25 COLON-ALIGNED
   LABEL "Коэф"
   VIEW-AS FILL-IN 
   SIZE 6.5 BY 1 TOOLTIP "Количество составного товара по рецепту"
   FGCOLOR 4 
   effect AT ROW 3.79 COL 73.63 COLON-ALIGNED
   tot-qnty AT ROW 20.25 COL 37.5 COLON-ALIGNED
   ingr-long AT ROW 13.96 COL 10.5 COLON-ALIGNED
   obj-fbroperator AT ROW 2.5 COL 15 COLON-ALIGNED
   r-fbroperator AT ROW 2.5 COL 30.5
   r-pay AT ROW 2.5 COL 98
   fact-date AT ROW 2.5 COL 38 COLON-ALIGNED WIDGET-ID 2
   shift AT ROW 2.5 COL 55.5 COLON-ALIGNED WIDGET-ID 4
   shift-sel AT ROW 2.5 COL 69 WIDGET-ID 6
   SPACE(29.37) SKIP(20.36)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
   TITLE "".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-FBR-DOC
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB br-comp 1 D-FBR-DOC */
/* BROWSE-TAB br-ingr br-comp D-FBR-DOC */
ASSIGN 
   FRAME D-FBR-DOC:SCROLLABLE = FALSE
   FRAME D-FBR-DOC:HIDDEN     = TRUE.

ASSIGN 
   b-add:POPUP-MENU IN FRAME D-FBR-DOC = MENU m-add:HANDLE.

/* SETTINGS FOR BUTTON b-calc-comp IN FRAME D-FBR-DOC
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-calc-ingr IN FRAME D-FBR-DOC
   NO-ENABLE                                                            */
ASSIGN 
   b-del:POPUP-MENU IN FRAME D-FBR-DOC = MENU m-del:HANDLE.

ASSIGN 
   b-rsrv:POPUP-MENU IN FRAME D-FBR-DOC = MENU POPUP-MENU-b-rsrv:HANDLE.

/* SETTINGS FOR FILL-IN effect IN FRAME D-FBR-DOC
   NO-ENABLE                                                            */
ASSIGN 
   effect:HIDDEN IN FRAME D-FBR-DOC = TRUE.

/* SETTINGS FOR FILL-IN fact-date IN FRAME D-FBR-DOC
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-pay-type-name IN FRAME D-FBR-DOC
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ingr-goods-type IN FRAME D-FBR-DOC
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN ingr-long IN FRAME D-FBR-DOC
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN fbr-recipe-gds.is-waste IN FRAME D-FBR-DOC
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN fbr-recipe-gds.qnty IN FRAME D-FBR-DOC
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
/* SETTINGS FOR FILL-IN fbr-recipe.qnty IN FRAME D-FBR-DOC
   EXP-LABEL                                                            */
ASSIGN 
   r-outs:POPUP-MENU IN FRAME D-FBR-DOC = MENU m-outs:HANDLE.

/* SETTINGS FOR FILL-IN fbr-recipe.recipe-code IN FRAME D-FBR-DOC
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN fbr-recipe.recipe-name IN FRAME D-FBR-DOC
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN fbr-recipe.recipe-type IN FRAME D-FBR-DOC
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN shift IN FRAME D-FBR-DOC
   NO-ENABLE                                                            */
ASSIGN 
   shift:READ-ONLY IN FRAME D-FBR-DOC = TRUE.

/* SETTINGS FOR FILL-IN tot-qnty IN FRAME D-FBR-DOC
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
   tot-qnty:HIDDEN IN FRAME D-FBR-DOC = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-comp
/* Query rebuild information for BROWSE br-comp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_comp_fbr-line NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE br-comp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ingr
/* Query rebuild information for BROWSE br-ingr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_ingr_fbr-line NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-ingr */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-FBR-DOC
/* Query rebuild information for DIALOG-BOX D-FBR-DOC
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-FBR-DOC */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-FBR-DOC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-FBR-DOC D-FBR-DOC
ON END-ERROR OF FRAME D-FBR-DOC
   OR ENDKEY OF FRAME D-FBR-DOC ANYWHERE 
   DO:

      APPLY "CHOOSE":U TO b-exit.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-FBR-DOC D-FBR-DOC
ON GO OF FRAME D-FBR-DOC
   DO:
      define variable v-today as date    no-undo.
      define variable v-time  as integer no-undo.

      find first ub.fbr-line no-lock
         where ub.fbr-line.doc-code = f-doc.doc-code
         no-error.
      if not available ub.fbr-line
         and p-doc-mode <> {&lookup}
         then 
      do:
         message
            "В документе нет ни одной строки. Документ удаляется."
            view-as alert-box information.
         delete f-doc.
         assign
            p-fbr-doc-recid     = ?
            p-new-fbr-doc-recid = ?
            .
      end.
      else 
      do:
         if p-doc-mode <> {&lookup}
            then 
         do:
            run cur-time in this-procedure (
               output v-today
               , output v-time
               ).
            assign
               f-doc.sys-date     = v-today
               f-doc.sys-time     = string( v-time, "HH:MM:SS":U )
               f-doc.sys-time-int = v-time
               .
         end.
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-FBR-DOC D-FBR-DOC
ON WINDOW-CLOSE OF FRAME D-FBR-DOC
   DO:
      if v-close-enabled = no
         then 
      do:
         undo, return no-apply.
      end.
      APPLY "END-ERROR":U TO SELF.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc-comp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-comp D-FBR-DOC
ON CHOOSE OF b-calc-comp IN FRAME D-FBR-DOC /* Сост */
   DO:
      { gbl/stdbtn.i }
      /* расчет полученных продуктов по ингредиенту в соответствии с рецептом */
      define variable v-comp-fbr-v-fbr-doc-line-recid as recid   no-undo.
      define variable v-comp-qnty                     as decimal no-undo.
      define variable v-comp-price-sale               as decimal no-undo.

      if not available buf_ingr_fbr-line
         then 
      do:
         message "Неправильно выбрана строка.".
         return no-apply.
      end.
      run calc-comp-from-ingr in this-procedure (
         input recid( buf_ingr_fbr-line )
         , input buf_ingr_fbr-line.fact-qnty
         , output v-comp-fbr-v-fbr-doc-line-recid
         , output v-comp-qnty
         ).
      run set-comp-qnty in this-procedure (
         input v-comp-fbr-v-fbr-doc-line-recid
         , input v-comp-qnty
         ).
      run UI-on ("line").
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc-ingr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-ingr D-FBR-DOC
ON CHOOSE OF b-calc-ingr IN FRAME D-FBR-DOC /* Ингр */
   DO:     /* расчет ингредиентов по полученным продуктам в соответствии с рецептом */
      { gbl/stdbtn.i }

      define variable v-need-goods           as logical   no-undo.
      define variable v-need-goods-list      as character no-undo.
      define variable v-need-goods-qnty-list as character no-undo.

      if not available buf_comp_fbr-line
         then 
      do:
         message "Неправильно выбрана строка.".
         return no-apply.
      end.
      /*    assign*/
      /*        v-fbr-doc-line-rec = recid (buf_comp_fbr-line)*/
      /*    .*/
      run str/fbr-qnty.p (
         input parparentproc
         , input p-fbrhist-handle
         , input recid( f-doc )
         , input recid( buf_comp_fbr-line )
         , input yes
         , input "ingr"
         , input no
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         , input no                          /* p-new-algorithm */
         , input no                          /* p-autofbr       */
         , input no                          /* p-have-store    */
         , output v-need-goods
         , output v-need-goods-list
         , output v-need-goods-qnty-list
         ) no-error.
      if error-status:error then 
      do:
         message
            substitute("Ошибка при расчете ингридиентов&1&2&1&3"
            , {&new-line}
            , error-status:get-message(1)
            , return-value )
            view-as alert-box error .
      end.
      run UI-on in this-procedure ( input "line" ).
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg D-FBR-DOC
ON CHOOSE OF b-chg IN FRAME D-FBR-DOC /* Изменить */
   DO:
      { gbl/stdbtn.i }
      define variable v-cancel   as logical no-undo.
      define variable v-old-qnty as decimal no-undo.
      define variable v-mark-qnty as decimal no-undo init ? .
      
      define variable v-attr-value as character no-undo .
      define variable v-attr-type as character no-undo .

      define buffer buf_goods for ub.goods .
      define buffer buf_fbr-recipe for ub.fbr-recipe.
      define buffer buf_fbr-line   for ub.fbr-line.
      define buffer buf_marking-lines for ub.marking-lines .
      define buffer buf_marking for ub.marking .

      if not available buf_comp_fbr-line then 
      do:
         message "Неправильно выбрана строка.".
         return no-apply.
      end.
      do
         on stop undo, return no-apply
         on error undo, return no-apply
         :
         assign
           v-old-qnty = buf_comp_fbr-line.fact-qnty
         .
         for first buf_goods no-lock where buf_goods.artic     = buf_comp_fbr-line.artic
                                       and buf_goods.prod-type = buf_comp_fbr-line.prod-type
                                       and buf_goods.prod-code = buf_comp_fbr-line.prod-code
         :
           v-isweighed = WghProdVariable(v-cntxt-obj-type, v-cntxt-obj-code, buf_goods.gds-code) .
           for each buf_marking-lines where buf_marking-lines.gds-code = buf_goods.gds-code
                                    and buf_marking-lines.obj-type = f-doc.obj-type
                                    and buf_marking-lines.obj-code = f-doc.obj-code
                                    and buf_marking-lines.in-code  = "manufacturing"
                                    and buf_marking-lines.out-code = buf_comp_fbr-line.doc-code
                                    and buf_marking-lines.part-code = buf_comp_fbr-line.recipe-code
                                    and buf_marking-lines.prt-code = 0
           :
             if v-mark-qnty = ? then assign v-mark-qnty = 0 .
             if v-isweighed
             then do :
               for first buf_marking no-lock where buf_marking.mark begins buf_marking-lines.mark :
                 v-mark-weight = MarkWeight(buf_marking.mark) .
                 assign v-mark-qnty = v-mark-qnty + v-mark-weight .
               end .
             end .
             else do :
               assign v-mark-qnty = v-mark-qnty + 1 .
             end .
           end .
         end .
         run str/fbr-line.w (
            input p-fbrhist-handle
            , input {&update}
            , input buf_comp_fbr-line.doc-code
            , input recid (buf_comp_fbr-line)
            , input v-mark-qnty
            , output v-cancel
            ) no-error.
         if error-status :error
            then 
         do:
            message
               vss-workfile vss-revision vss-description
               skip 
               "Ошибка изменения количества составного товара."
               skip return-value
               skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               view-as alert-box error.
            undo, return no-apply .
         end.
         if buf_comp_fbr-line.recipe-code <> ""
            then 
         do:
            define variable v-need-goods           as logical   no-undo.
            define variable v-need-goods-list      as character no-undo.
            define variable v-need-goods-qnty-list as character no-undo.
            if v-old-qnty > buf_comp_fbr-line.fact-qnty
               then 
            do:
               find first buf_fbr-recipe no-lock
                  where buf_fbr-recipe.doc-code    = buf_comp_fbr-line.doc-code
                  and buf_fbr-recipe.recipe-code = buf_comp_fbr-line.recipe-code
                  .
               if buf_fbr-recipe.recipe-type = {&alternative}
                  then 
               do:
                  do transaction
                     :
                     for each buf_fbr-line exclusive-lock
                        where buf_fbr-line.doc-code    = buf_comp_fbr-line.doc-code
                        and buf_fbr-line.is-comp     = no
                        and buf_fbr-line.recipe-code = buf_comp_fbr-line.recipe-code
                        :
                        delete buf_fbr-line.
                     end.        /* for each buf_fbr-line */
                  end.        /* do transaction */
               end.
            end.
            run str/fbr-qnty.p (
               input parparentproc
               , input p-fbrhist-handle
               , input recid( f-doc )
               , input recid( buf_comp_fbr-line )
               , no
               , "ingr"
               , no
               , v-price-sale-obj-type
               , v-price-sale-obj-code
               , input no                          /* p-new-algorithm */
               , input no                          /* p-autofbr       */
               , input no                          /* p-have-store    */
               , output v-need-goods
               , output v-need-goods-list
               , output v-need-goods-qnty-list
               ) no-error.
            if error-status :error
               then 
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip 
                  "Ошибка расчета количества ингредиентов"
                  skip 
                  "при изменении количества составного товара"
                  skip return-value
                  skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
                  view-as alert-box error.
               undo, return no-apply .
            end.
         end.
      end.
      run UI-on ("line").
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit D-FBR-DOC
ON CHOOSE OF b-exit IN FRAME D-FBR-DOC /* Выход  */
   DO:
      { gbl/stdbtn.i }

      define variable v-can-continue as logical no-undo.

      define buffer buf_fbr-line for ub.fbr-line.

      if f-doc.is-free = no
         and p-doc-mode <> {&lookup}
         then 
      do:
         for each buf_fbr-line no-lock
            where buf_fbr-line.doc-code = f-doc.doc-code
            and buf_fbr-line.is-comp  = yes
            :
            run check-and-correct-fbr-recipe in this-procedure (
               input f-doc.doc-code
               , input buf_fbr-line.recipe-code
               , output v-can-continue
               ) no-error.
            if error-status :error
               then 
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip 
                  "Ошибка проверки соответствия"
                  skip 
                  "строк рецепта документа и строк документа."
                  skip(1)
                  skip 
                  "Рецепт:" buf_fbr-line.recipe-code
                  skip return-value
                  skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
                  view-as alert-box error.
               undo, return no-apply.
            end.
            if v-can-continue = no
               then 
            do:
               undo, return no-apply.
            end.
         end.        /* for each buf_fbr-line */
         assign
            fi-pay-code
            .
         assign
            f-doc.pay-code = fi-pay-code
            .
      end.        /* f-doc.is-free = no */
      assign
         p-fbr-doc-next-prev = ?
         v-close-enabled     = yes
         .
      apply "GO" to frame {&frame-name}.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds D-FBR-DOC
ON CHOOSE OF b-gds IN FRAME D-FBR-DOC /* Товары */
   DO:
      run assign-current-goods .
      run str/fbr-igds.w (
         input parparentproc
         , input recid( f-doc )
         , input-output gds-rec
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip 
            "Ошибка просмотра документа производства по товарам."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
            trim( error-status :get-message( 2 ) )
            trim( error-status :get-message( 3 ) )
            view-as alert-box error.
         undo, return no-apply.
      end.
      if gds-rec <> ? then 
      do:
         rs-one-all = "goods".
         run UI-on ("enable").
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp D-FBR-DOC
ON CHOOSE OF b-lkp IN FRAME D-FBR-DOC /* Просмотр */
   DO:
      { gbl/stdbtn.i }
      define variable v-cancel as logical no-undo.
      if not available buf_comp_fbr-line then 
      do:
         message "Неправильно выбрана строка.".
         undo, return no-apply.
      end.
      run str/fbr-line.w (
         input p-fbrhist-handle
         , input {&lookup}
         , input buf_comp_fbr-line.doc-code
         , input recid (buf_comp_fbr-line)
         , input ?
         , output v-cancel
         ).
      return no-apply.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next D-FBR-DOC
ON CHOOSE OF b-next IN FRAME D-FBR-DOC /* >> */
   DO:
      assign
         v-close-enabled = yes
         v-need-refresh  = yes
         .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-parts D-FBR-DOC
ON CHOOSE OF b-parts IN FRAME D-FBR-DOC /* Партии */
   DO:
      { gbl/stdbtn.i }
      case current-browse
         :
         when br-comp :handle
         then 
            do:
               if buf_comp_fbr-line.trn-type = {&write-off}
                  then 
               do:
                  run process-parts in this-procedure (
                     input buf_comp_fbr-line.doc-code
                     , input buf_comp_fbr-line.trn-type
                     , input buf_comp_fbr-line.recipe-code
                     , input buf_comp_fbr-line.artic
                     , input buf_comp_fbr-line.prod-type
                     , input buf_comp_fbr-line.prod-code
                     ) no-error.
                  if error-status :error
                     then 
                  do:
                     message
                        vss-workfile vss-revision vss-description
                        skip 
                        "Ошибка обработки партий."
                        skip return-value
                        skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                        view-as alert-box error.
                     undo, return no-apply .
                  end.
                  apply "entry" to br-comp in frame {&frame-name} .
               end.        /* if buf_comp_fbr-line.trn-type = {&write-off}  */
               else 
               do:
                  message
                     "Выберите строку списания."
                     view-as alert-box information.
               end.
            end.        /* when br-comp :handle */
         when br-ingr :handle
         then 
            do:
               if buf_ingr_fbr-line.trn-type = {&write-off}
                  then 
               do:
                  run process-parts in this-procedure (
                     input buf_ingr_fbr-line.doc-code
                     , input buf_ingr_fbr-line.trn-type
                     , input buf_ingr_fbr-line.recipe-code
                     , input buf_ingr_fbr-line.artic
                     , input buf_ingr_fbr-line.prod-type
                     , input buf_ingr_fbr-line.prod-code
                     ) no-error.
                  if error-status :error
                     then 
                  do:
                     message
                        vss-workfile vss-revision vss-description
                        skip 
                        "Ошибка обработки партий."
                        skip return-value
                        skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                        view-as alert-box error.
                     undo, return no-apply .
                  end.
                  apply "entry" to br-ingr in frame {&frame-name} .
               end.        /* if buf_ingr_fbr-line.trn-type = {&write-off}  */
               else 
               do:
                  message
                     "Выберите строку списания."
                     view-as alert-box information.
               end.
            end.        /* when br-ingr :handle */
      end case.       /* case current-browse */
      run UI-on in this-procedure ( input "line" ).
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev D-FBR-DOC
ON CHOOSE OF b-prev IN FRAME D-FBR-DOC /* << */
   DO:
      assign
         v-close-enabled = yes
         v-need-refresh  = yes
         .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-recipe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-recipe D-FBR-DOC
ON CHOOSE OF b-recipe IN FRAME D-FBR-DOC /* Рецепт */
   DO:
      define variable ri             as recid   no-undo.
      define variable v-cancel       as logical no-undo.
      define variable v-can-continue as logical no-undo.
      define variable v-goods-recid  as recid   no-undo.

      { gbl/stdbtn.i }
      define buffer buf_recipe for ub.fbr-recipe.
      define buffer buf_goods  for ub.goods.

      if not available buf_comp_fbr-line
         then 
      do:
         message
            "Неправильно выбрана строка."
            view-as alert-box error.
         undo, return no-apply.
      end.
      if buf_comp_fbr-line.recipe-code = ""
         then 
      do:
         message
            "Данная строка не имеет рецепта."
            view-as alert-box error.
         undo, return no-apply.
      end.
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_recipe-reference_input-deletion-updating':U
      {&cntxt-object}
      f-doc.host-code
      f-doc.obj-type
      f-doc.obj-code
      0
      0
      0
      true
      v-fbr-doc-g-log
    }

      if not v-fbr-doc-g-log
         then 
      do:
         undo, return no-apply .
      end.
      find first buf_recipe no-lock
         where buf_recipe.doc-code      = f-doc.doc-code
         and buf_recipe.recipe-code   = buf_comp_fbr-line.recipe-code
         .
      find first buf_goods no-lock
         where buf_goods.artic      = buf_recipe.artic
         and buf_goods.prod-type  = buf_recipe.prod-type
         and buf_goods.prod-code  = buf_recipe.prod-code
         no-error.
      if not available buf_goods
         then 
      do:
         message
            skip 
            "Не найден товар рецепта."
            view-as alert-box error.
         undo, return no-apply .
      end.
      assign
         ri = recid( buf_recipe )
         .
      if p-doc-mode <> {&lookup}
         then 
      do:
         run check-and-correct-fbr-recipe in this-procedure (
            input f-doc.doc-code
            , input buf_comp_fbr-line.recipe-code
            , output v-can-continue
            ).
         if v-can-continue = no
            then 
         do:
            undo, return no-apply.
         end.
      end.
      run ref/recips.w (
         input parparentproc
         , input ( if f-doc.status_ = {&g___new} then p-doc-mode else {&lookup} )
         , input buf_comp_fbr-line.doc-code
         , input recid( buf_goods )
         , input buf_recipe.recipe-type
         , input buf_recipe.recipe-code
         , output v-cancel
         ).
      if v-cancel = no
         and p-doc-mode <> {&lookup}
         then 
      do:
         run fbrlib_adjust-doc-lines in this-procedure (
            input parparentproc
            , input p-fbrhist-handle
            , input buf_comp_fbr-line.doc-code
            , input buf_recipe.recipe-code
            , input v-price-sale-obj-type
            , input v-price-sale-obj-code
            ).
      end.
      /* для перерисовки полей Коэффициент в прямоугольниках */
      apply "value-changed" to br-comp in frame {&frame-name}.
      apply "value-changed" to br-ingr in frame {&frame-name}.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-comp
&Scoped-define SELF-NAME br-comp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-comp D-FBR-DOC
ON ENTRY OF br-comp IN FRAME D-FBR-DOC
   DO:
      /* запоминаем текущий browse */
      current-browse = br-comp:handle.
      if available buf_comp_fbr-line
         then 
      do:
         run fill-recipe-fields in this-procedure (
            input buf_comp_fbr-line.recipe-code
            ).
      end.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-comp D-FBR-DOC
ON MOUSE-SELECT-DBLCLICK OF br-comp IN FRAME D-FBR-DOC
   DO:
      if p-doc-mode = {&lookup} or f-doc.status_ <> {&g___new} then
         apply "choose" to b-lkp.
      else
         apply "choose" to b-chg.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-comp D-FBR-DOC
ON RETURN OF br-comp IN FRAME D-FBR-DOC
   DO:
      if p-doc-mode = {&lookup} then
         apply "choose" to b-lkp.
      else
         apply "choose" to b-chg.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-comp D-FBR-DOC
ON ROW-DISPLAY OF br-comp IN FRAME D-FBR-DOC
   DO:
      define buffer local_ingr_fbr-line for ub.fbr-line .
      
      if buf_comp_fbr-line.is-waste = yes
         then 
      do:
         assign
            buf_comp_fbr-line.artic                 :bgcolor in browse br-comp = gray_color
            comp-name                               :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.trn-type              :bgcolor in browse br-comp = gray_color
            comp-OK                                 :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.fact-qnty             :bgcolor in browse br-comp = gray_color
            comp-unit                               :bgcolor in browse br-comp = gray_color
            comp-prod                               :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.is-calc               :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sale            :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.fix-cost              :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-rubl            :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-base            :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sum-rubl        :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sum-base        :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sum-vat-rubl    :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.price-sum-vat-base    :bgcolor in browse br-comp = gray_color
            buf_comp_fbr-line.rsrv-qnty             :bgcolor in browse br-comp = gray_color
            .
      end.
      
      for first local_ingr_fbr-line no-lock where local_ingr_fbr-line.doc-code = f-doc.doc-code
                                              and local_ingr_fbr-line.is-comp = no
                                              and local_ingr_fbr-line.recipe-code = buf_comp_fbr-line.recipe-code
      :
        if need-marks(buffer local_ingr_fbr-line)
        then do ii = 1 to extent (bcol_comp):  
          if valid-handle (bcol_comp[ii]) 
          then do:
            assign
              bcol_comp[ii]:bgcolor = RED_COLOR.
          end.
        end.
      end .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-comp D-FBR-DOC
ON ROW-LEAVE OF br-comp IN FRAME D-FBR-DOC
   DO:
      if not available buf_comp_fbr-line
         then 
      do:
         return .
      end.
      if not browse br-comp:current-row-modified
         then 
      do:
         return .
      end.
      run change-current-comp-line in this-procedure (
         input recid( buf_comp_fbr-line )
         , input f-doc.status_
         , input f-doc.host-code
         ) no-error.
      display
         buf_comp_fbr-line.price-sale
         buf_comp_fbr-line.is-calc
         buf_comp_fbr-line.fix-cost
         buf_comp_fbr-line.price-base
         buf_comp_fbr-line.price-rubl
         buf_comp_fbr-line.price-sum-base
         buf_comp_fbr-line.price-sum-rubl
         buf_comp_fbr-line.price-sum-vat-base
         buf_comp_fbr-line.price-sum-vat-rubl
         with browse br-comp.
      if error-status :error
         then 
      do:
         undo, return no-apply.
      end.
   END.        /* ON ROW-LEAVE */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-comp D-FBR-DOC
ON VALUE-CHANGED OF br-comp IN FRAME D-FBR-DOC
   DO:
      display
         ? @ ub.fbr-recipe.recipe-code
         ? @ ub.fbr-recipe.recipe-type
         ? @ ub.fbr-recipe.recipe-name
         ? @ ub.fbr-recipe.qnty
         ? @ effect
         with frame {&frame-name}.
      if available buf_comp_fbr-line
         then 
      do:
         assign      /* для reposition */
            v-fbr-doc-line-rec = recid (buf_comp_fbr-line)
            .
         run fill-recipe-fields in this-procedure (
            input buf_comp_fbr-line.recipe-code
            ) .
         run get-effect in this-procedure (
            input buf_comp_fbr-line.recipe-code
            , input f-doc.doc-code
            , output effect
            ).
         display
            effect
            with frame {&frame-name}.
      end.
      if lookup (rs-one-all, "all,type,goods") > 0
         then 
      do:
      /* содержимое нижнего browse не зависит от верхнего - не надо его переоткрывать */
      end.
      else 
      do:
         run open-ingr in this-procedure (
            input ( if available buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ? )
            ) .
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ingr
&Scoped-define SELF-NAME br-ingr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ingr D-FBR-DOC
ON ENTRY OF br-ingr IN FRAME D-FBR-DOC
   DO:
      /* запоминаем текущий browse */
      current-browse = br-ingr:handle.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ingr D-FBR-DOC
ON ROW-DISPLAY OF br-ingr IN FRAME D-FBR-DOC
   DO:
      if buf_ingr_fbr-line.is-waste = yes
         then 
      do:
         assign
            buf_ingr_fbr-line.artic                 :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.recipe-code           :bgcolor in browse br-ingr = gray_color
            ingr-name                               :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.trn-type              :bgcolor in browse br-ingr = gray_color
            ingr-OK                                 :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.fact-qnty             :bgcolor in browse br-ingr = gray_color
            ingr-unit                               :bgcolor in browse br-ingr = gray_color
            ingr-prod                               :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.is-calc               :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sale            :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.fix-cost              :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.coeff-waste           :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.coeff-value           :bgcolor in browse br-ingr = gray_color
            ingr-netto                              :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-rubl            :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-base            :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sum-rubl        :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sum-base        :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sum-vat-rubl    :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.price-sum-vat-base    :bgcolor in browse br-ingr = gray_color
            buf_ingr_fbr-line.rsrv-qnty             :bgcolor in browse br-ingr = gray_color
            .
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ingr D-FBR-DOC
ON ROW-LEAVE OF br-ingr IN FRAME D-FBR-DOC
   DO:

      if available buf_ingr_fbr-line
         and browse br-ingr:current-row-modified
         then 
      do:
         run assign-ingr-line in this-procedure (
            rowid( buf_ingr_fbr-line )
            , input browse br-ingr buf_ingr_fbr-line.fact-qnty
            , input browse br-ingr buf_ingr_fbr-line.is-calc
            , input browse br-ingr buf_ingr_fbr-line.price-sale
            , input browse br-ingr buf_ingr_fbr-line.fix-cost
            , input browse br-ingr buf_ingr_fbr-line.price-rubl
            , input browse br-ingr buf_ingr_fbr-line.price-base
            , input browse br-ingr buf_ingr_fbr-line.price-sum-vat-rubl
            , input browse br-ingr buf_ingr_fbr-line.price-sum-vat-base
            ) no-error.
         if error-status :error
            then 
         do:
            message
               vss-workfile vss-revision vss-description
               skip(1)
               skip 
               "Ошибка записи строки ингредиента"
               skip 
               "документа производства"
               skip return-value
               skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               view-as alert-box error.
            undo, return no-apply .
         end.
         display
            buf_ingr_fbr-line.is-calc
            buf_ingr_fbr-line.price-sale
            buf_ingr_fbr-line.price-base
            buf_ingr_fbr-line.price-rubl
            buf_ingr_fbr-line.price-sum-base
            buf_ingr_fbr-line.price-sum-rubl
            buf_ingr_fbr-line.price-sum-vat-base
            buf_ingr_fbr-line.price-sum-vat-rubl
            buf_ingr_fbr-line.fix-cost
            with browse br-ingr.

         browse br-ingr :refresh().

      /*    if buf_ingr_fbr-line.trn-type = {&income}*/
      /*    then do:*/
      /*        run calc-no-fixed-lines in this-procedure (*/
      /*              input buf_ingr_fbr-line.doc-code*/
      /*            , input buf_ingr_fbr-line.recipe-code*/
      /*        ) no-error.*/
      /*        if error-status :error*/
      /*        then do:*/
      /*            undo, return no-apply.*/
      /*        end.*/
      /*    end.        /* if buf_ingr_fbr-line.trn-type = {&income} */*/
      end.
   END.
/*---E------- br-ingr | ON ROW-LEAVE ---------------------------*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ingr D-FBR-DOC
ON VALUE-CHANGED OF br-ingr IN FRAME D-FBR-DOC
   /*---S------- br-ingr | ON VALUE-CHANGED -----------------------*/
   DO:
      define variable v-gds-name           as character no-undo.
      define variable v-gds-type           as character no-undo.
      define variable v-recipe-type        as character no-undo.
      define variable v-recipe-qnty        as decimal   no-undo.
      define variable v-recipe-brutto-qnty as decimal   no-undo.
      define variable v-recipe-coeff-value as decimal   no-undo.
      define variable v-recipe-coeff-waste as decimal   no-undo.
      define variable v-recipe-waste       as logical   no-undo.

      display
         ?   @ ingr-long
         ?   @ ub.fbr-recipe-gds.qnty
         no  @ ub.fbr-recipe-gds.is-waste
         ""  @ ingr-goods-type
         with frame {&frame-name}.
      if available buf_ingr_fbr-line
         then 
      do:
         run get-ingr-line-parameters in this-procedure (
            input buf_ingr_fbr-line.recipe-code
            , input buf_ingr_fbr-line.artic
            , input buf_ingr_fbr-line.prod-type
            , input buf_ingr_fbr-line.prod-code
            , output v-gds-name
            , output v-gds-type
            , output v-recipe-type
            , output v-recipe-qnty
            , output v-recipe-brutto-qnty
            , output v-recipe-coeff-value
            , output v-recipe-coeff-waste
            , output v-recipe-waste
            ) .
         if v-recipe-type = {&dressing}
            and v-recipe-waste = no
            then 
         do:
            if v-base = yes
               then 
            do:
               assign
                  buf_ingr_fbr-line.price-base:read-only          in browse br-ingr = no
                  .
            end.
            else 
            do:
               assign
                  buf_ingr_fbr-line.price-rubl:read-only          in browse br-ingr = no
                  .
            end.
         end.
         else 
         do:
            assign
               buf_ingr_fbr-line.price-rubl:read-only          in browse br-ingr = yes
               buf_ingr_fbr-line.price-base:read-only          in browse br-ingr = yes
               .
         end.
                       
         /* Если объект не активный и удалённый */
         if not( v-cntxt-db-num-obj = v-cntxt-db-num )
            and ( v-cntxt-db-num-obj <> 0 )
            then 
         do:
            assign
               buf_ingr_fbr-line.price-rubl:read-only          in browse br-ingr = yes
               .
         end.
        
         run fill-recipe-fields in this-procedure (
            input buf_ingr_fbr-line.recipe-code
            ).
         display
            v-gds-name              @ ingr-long
            v-gds-type              @ ingr-goods-type
            /*            v-recipe-qnty           @ fbr-recipe-gds.qnty*/
            v-recipe-brutto-qnty    @ fbr-recipe-gds.qnty
            /*            v-recipe-coeff-value    @ fbr-recipe-gds.coeff-value*/
            /*            v-recipe-coeff-waste    @ fbr-recipe-gds.coeff-waste*/
            v-recipe-waste          @ fbr-recipe-gds.is-waste
            with frame {&frame-name}.
      end.
   END.
/*---E------- br-ingr | ON VALUE-CHANGED -----------------------*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-pay-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-pay-code D-FBR-DOC
ON LEAVE OF fi-pay-code IN FRAME D-FBR-DOC /* Опл */
   DO:
      define buffer buf_pay-type for ub.pay-type.

      find first buf_pay-type no-lock
         where buf_pay-type.obj-code = integer( fi-pay-code :screen-value )
         no-error.
      if not available buf_pay-type
         then 
      do:
         message
            "Введите код оплаты, определённый в справочнике"
            skip 
            "кодов оплат."
            view-as alert-box.
         undo, return no-apply.
      end.
      else 
      do:
         assign
            fi-pay-code
            .
         run get-pay-type-name in this-procedure (
            input fi-pay-code
            , output fi-pay-type-name
            ).
         display
            fi-pay-type-name
            with frame {&frame-name}.
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-add-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-marks D-FBR-DOC
ON CHOOSE OF b-add-marks in frame D-FBR-DOC
do :
  if available buf_ingr_fbr-line
  then do :
    run str/fbr-doc-ingr-marks-add.w (input parparentproc,
                                 input recid(buf_ingr_fbr-line)) .
    br-ingr:refresh () .
  end .
end .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-all-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-all-add D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-all-add /* Товары по всем связанным рецептам */
   DO:
      { gbl/stdbtn.i b-add "in frame d-fbr-doc" }
      run add-proc in this-procedure (
         input "rcp-all"
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка добавления товаров по всем связанным рецептам."
            skip return-value
            skip trim( error-status :get-message(1) )
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return no-apply .
      end.
      assign
         f-doc.is-free = no
         .
      run hide-not-avail-menu-items in this-procedure ( input no ).
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-all-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-all-del D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-all-del /* Товары по всем связанным рецептам */
   DO:
      define variable v-deleted as logical no-undo.
      { gbl/stdbtn.i b-del "in frame d-fbr-doc" }
      run del-proc in this-procedure ( input "all", output v-deleted ).
      if v-deleted = yes
         then 
      do:
         run UI-on ("line").
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-all-doc-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-all-doc-del D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-all-doc-del /* Все товары документа */
   DO:
      define variable v-deleted as logical no-undo.
      { gbl/stdbtn.i b-del "in frame d-fbr-doc" }
      run del-proc in this-procedure ( input "all-doc", output v-deleted ).
      if v-deleted = yes
         then 
      do:
         run UI-on ("line").
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-comp-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-comp-add D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-comp-add /* Товар без рецепта в верхний список */
   DO:
      { gbl/stdbtn.i b-add "in frame d-fbr-doc" }
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_manufacturing_free':U
      {&cntxt-object}
      f-doc.host-code
      f-doc.obj-type
      f-doc.obj-code
      0
      0
      0
      true
      v-fbr-doc-g-log
    }
      if v-fbr-doc-g-log <> yes
         then 
      do:
         undo, return no-apply.
      end.
      run add-proc in this-procedure (
         input "up"
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка добавления товара без рецепта в верхний список."
            skip return-value
            skip trim( error-status :get-message(1) )
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return no-apply .
      end.
      assign
         f-doc.is-free = yes
         .
      run hide-not-avail-menu-items in this-procedure ( input yes ).
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-comp-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-comp-del D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-comp-del /* Товар без рецепта в верхнем списке */
   DO:
      define variable v-deleted as logical no-undo.
      { gbl/stdbtn.i b-del "in frame d-fbr-doc" }
      run del-proc in this-procedure ( input "up", output v-deleted ).
      if v-deleted = yes
         then 
      do:
         run UI-on ("line").
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-doc D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-doc /* Накладная */
   /*---S------ MENU-ITEM m-doc | ON CHOOSE -----------------------*/
   DO:
      define variable loc-ref-list as character no-undo.
      define variable i            as integer   no-undo .


      run str/all-docs.w (
         input parparentproc,
         input v-cntxt-host-code-obj ,
         input v-cntxt-obj-type ,
         input v-cntxt-obj-code ,
         input {&choose},
         input ?,
         input ?,
         input ?,
         input ?,
         input "b-sel,b-mark":U,
         input ?,
         input ?,
         input ?,
         output loc-ref-list ) NO-ERROR.


      if loc-ref-list = ""  then 
      do:
         message
            "Ничего не отметили в списке заказов !"
            view-as alert-box information .

         display
            ? @ out-code
            with frame {&frame-name}.

         apply "entry" to b-add in frame {&frame-name}.
         return no-apply.
      end.
      if num-entries( loc-ref-list ) = 0
         or loc-ref-list = ""
         or error-status:error
         then 
      do:
         display
            ? @ out-code
            with frame {&frame-name}.
         apply "entry" to b-add in frame {&frame-name}.
         return no-apply.
      end.
      else 
      do:
         { gbl/working.i }
         repeat i = 1 to  num-entries( loc-ref-list ) :
            find first ub.trn-doc no-lock
               where recid( ub.trn-doc ) = integer( entry( i , loc-ref-list ) )  no-error.
            display
               ub.trn-doc.doc-code @ out-code
               with frame {&frame-name}.
            run str/fbr-copy.p (
               input parparentproc
               , input f-doc.doc-code
               , input trn-doc.doc-code
               , input f-doc.obj-type
               , input f-doc.obj-code
               , input v-price-sale-obj-type
               , input v-price-sale-obj-code
               , input p-fbrhist-handle
               ) no-error.
            if error-status :error
               then 
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip(1)
                  skip 
                  "Ошибка копирования накладной в документ производства."
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
                  view-as alert-box error.
               undo, return no-apply.
            end.

         end.
      end.
      assign
         f-doc.is-free = no
         .
      run hide-not-avail-menu-items in this-procedure ( input no ).
      run UI-on in this-procedure ( input "line" ).
      { gbl/stopwork.i }
      return no-apply.
   END.
/*---E------ MENU-ITEM m-doc | ON CHOOSE -----------------------*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-doc-rsrv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-doc-rsrv D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-doc-rsrv /* По всему документу */
   DO:
      define variable v-reserved as logical no-undo.
      { gbl/stdbtn.i b-rsrv "in frame d-fbr-doc" }
      run str/fbr-rsrv.p (
         input parparentproc
         , input ?
         , input recid( f-doc )
         , input no /*p-silent*/
         , input no              /* autofbr */
         , input no
         , input no
         , output v-reserved
         ) no-error.
      if error-status:error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка резервирования товара по всему документу."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         undo, return no-apply.
      end.
      if v-reserved = yes
         then 
      do:
         assign
            f-doc.status_ = {&permitted}
            .
      end.
      run UI-on in this-procedure ( input "line" ).
      { gbl/stopwork.i }
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-ingr-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-ingr-add D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-ingr-add /* Товар без рецепта в нижний список */
   DO:
      { gbl/stdbtn.i b-add "in frame d-fbr-doc" }
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_manufacturing_free':U
      {&cntxt-object}
      f-doc.host-code
      f-doc.obj-type
      f-doc.obj-code
      0
      0
      0
      true
      v-fbr-doc-g-log
    }
      if v-fbr-doc-g-log <> yes
         then 
      do:
         undo, return no-apply.
      end.
      run add-proc in this-procedure (
         input "down"
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка добавления товара без рецепта в нижний список."
            skip return-value
            skip trim( error-status :get-message(1) )
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return no-apply .
      end.
      assign
         f-doc.is-free = yes
         .
      run hide-not-avail-menu-items in this-procedure ( input yes ).
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-ingr-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-ingr-del D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-ingr-del /* Товар без рецепта в нижнем списке */
   DO:
      define variable v-deleted as logical no-undo.
      { gbl/stdbtn.i b-del "in frame d-fbr-doc" }
      run del-proc in this-procedure ( input "down", output v-deleted ).
      if v-deleted = yes
         then 
      do:
         run UI-on ("line").
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-ord D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-ord /* Заказ */
   DO:

      define variable i            as integer   no-undo .
      define variable loc-ref-list as character no-undo.

      run ref/all-zakz.w
         ( input   parParentProc
         ,input   ?
         ,input   ?
         ,input   "firmord"
         ,input   ""
         ,input   "b-sel,b-mark"
         ,input   ""
         ,output  loc-ref-list ) no-error .
      if loc-ref-list = ""  then 
      do:
         message "Ни чего не отметили в списке заказов !"
            view-as alert-box information .
         display
            ? @ out-code
            with frame {&frame-name}.
         apply "entry" to b-add in frame {&frame-name}.
         return no-apply.
      end.
      if num-entries( loc-ref-list ) = 0
         or loc-ref-list                = ""
         or error-status :error
         then 
      do:
         display
            ? @ out-code
            with frame {&frame-name}.
         apply "entry" to b-add in frame {&frame-name}.
         return no-apply.
      end.
      else 
      do:
         { gbl/working.i }
         repeat i = 1 to  num-entries( loc-ref-list ) :
            find first ub.ord-doc no-lock
               where recid( ub.ord-doc ) = integer( entry( i , loc-ref-list ) )  no-error.
            display
               ub.ord-doc.doc-code @ out-code
               with frame {&frame-name}.

            run cus/ord-copy.p (
               input parparentproc
               , input f-doc.doc-code
               , input ub.ord-doc.doc-code
               , input f-doc.obj-type
               , input f-doc.obj-code
               , input v-price-sale-obj-type
               , input v-price-sale-obj-code
               , input p-fbrhist-handle
               ) no-error.
            if error-status :error
               then 
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip(1)
                  skip 
                  "Ошибка копирования заказа в документ производства."
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
                  view-as alert-box error.
               undo, return no-apply.
            end.

         end.
      end.
      assign
         f-doc.is-free = no
         .
      run hide-not-avail-menu-items in this-procedure ( input no ).
      run UI-on in this-procedure ( input "line" ).
      { gbl/stopwork.i }
      return no-apply.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-rcp-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-rcp-add D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-rcp-add /* Товар с рецептом */
   DO:
      { gbl/stdbtn.i b-add "in frame d-fbr-doc" }
      run add-proc in this-procedure (
         input "rcp"
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка добавления товара с рецептом."
            skip return-value
            skip trim( error-status :get-message(1) )
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return no-apply .
      end.
      do transaction
         on error undo, return no-apply
         :
         assign
            f-doc.is-free = no
            .
      end.        /* do transaction */
      run hide-not-avail-menu-items in this-procedure (
         input no
         ).
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-rcp-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-rcp-del D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-rcp-del /* Товар с рецептом */
   DO:
      define variable v-deleted as logical no-undo.
      { gbl/stdbtn.i b-del "in frame d-fbr-doc" }
      run del-proc in this-procedure ( input "rcp", output v-deleted ).
      if v-deleted = yes
         then 
      do:
         run UI-on ("line").
      end.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-rcp-rsrv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-rcp-rsrv D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-rcp-rsrv /* По текущему рецепту */
   DO:
      { gbl/stdbtn.i b-rsrv "in frame d-fbr-doc" }
      if not available buf_comp_fbr-line
         then 
      do:
         message
            "Неправильно выбрана строка составного товара."
            view-as alert-box error.
         return no-apply.
      end.
      run str/fbr-rcp.p (
         input parparentproc
         , input p-fbrhist-handle
         , input p-fbr-doc-recid
         , input no /*p-silent*/
         , input buf_comp_fbr-line.recipe-code
         , input no
         , input no
         ) no-error.
      if error-status:error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка расчета рецепта. "
            skip 
            "Рецепт: " buf_comp_fbr-line.recipe-code
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         return no-apply.
      end.
      /* считаем шапку предварительно */
      run fbrlib-fill-sum-fbr-doc in this-procedure (
         input p-fbr-doc-recid
         , input {&rsrv-dtl_action_reserv}
         ) no-error.
      if error-status:error then 
      do:
         message
            substitute("Ошибка при расчете шапки документа пр-ва&1&2&1&3"
            , {&new-line}
            , error-status:get-message(1)
            , return-value )
            view-as alert-box error .
      end.
      run UI-on in this-procedure ( input "line" ).
      { gbl/stopwork.i }
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-sale D-FBR-DOC
ON CHOOSE OF MENU-ITEM m-sale /* Продажа */
   DO:

      define variable v-user-select as logical   no-undo .
      define variable v-obj-type    as character no-undo .
      define variable v-obj-code    as integer   no-undo .
      define variable v-rid-list    as character no-undo .

      { gbl/stdbtn.i r-outs }
      assign
         v-fbr-doc-g-log = yes
         .
      message
         "Выберите объект для поиска незакрытой продажи" skip
         view-as alert-box question
         buttons OK-Cancel
         update v-fbr-doc-g-log.
      if not v-fbr-doc-g-log
         then 
      do:
         return no-apply.
      end.

      { gbl/uobjsone.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
      v-obj-type
      v-obj-code
    }
      if v-user-select <> true
         then 
      do:
         return no-apply .
      end.


      run str/salelist.w
         (input  parparentproc
         ,input  "b-sel"
         ,input  {&g___new}
         ,input  0
         ,input  v-obj-type
         ,input  v-obj-code
         ,input-output v-rid-list
         ).
      if v-rid-list = ""
         then 
      do:
         return no-apply.
      end.
      find first ub.inkas no-lock
         where recid(ub.inkas) = integer(v-rid-list)
         no-error.
      if not available ub.inkas
         then 
      do:
         message
            "На выбранном объекте не найдена незакрытая продажа."
            view-as alert-box error.
         return no-apply.
      end.
      display ub.inkas.inkas-code @ out-code with frame {&frame-name}.
      apply "entry" to out-code in frame {&frame-name}.
      apply 'Return':U to out-code in frame {&frame-name}.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME out-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL out-code D-FBR-DOC
ON RETURN OF out-code IN FRAME D-FBR-DOC /* Ист */
   /*---S----- out-code | ON RETURN -----------------------*/
   DO:
      { gbl/stdbtn.i }
      find first ub.trn-doc no-lock
         where ub.trn-doc.doc-code = input frame {&frame-name} out-code
         no-error.
      if not available ub.trn-doc
         then 
      do:
         apply "choose" to r-outs in frame {&frame-name}.
         return no-apply.
      end.
      run str/fbr-copy.p (
         input parparentproc
         , input f-doc.doc-code
         , input ub.trn-doc.doc-code
         , input f-doc.obj-type
         , input f-doc.obj-code
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         , input p-fbrhist-handle
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip 
            "Ошибка копирования накладной в документ производства."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
            trim( error-status :get-message( 2 ) )
            trim( error-status :get-message( 3 ) )
            view-as alert-box error.
         undo, return no-apply.
      end.
      assign
         f-doc.is-free = no
         .
      run hide-not-avail-menu-items in this-procedure (
         input no
         ).
      run UI-on in this-procedure ( input "line" ).
      return no-apply.
   END.
/*---E----- out-code | ON RETURN -----------------------*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-fbroperator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-fbroperator D-FBR-DOC
ON CHOOSE OF r-fbroperator IN FRAME D-FBR-DOC /* r-price */
   DO:
      { gbl/stdbtn.i }
      /* установка режима справочника */
      run select-fbroperator in this-procedure (
         output obj-fbroperator
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip 
            "Ошибка выбора оператора документа производства."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         undo, return no-apply .
      end.
      display
         obj-fbroperator
         with frame {&frame-name}.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-pay D-FBR-DOC
ON CHOOSE OF r-pay IN FRAME D-FBR-DOC /* r-pay */
   DO:
      { gbl/stdbtn.i }
      /* установка режима справочника */
      run select-fbrpaycode in this-procedure (
         input fi-pay-code
         , output fi-pay-code
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip 
            "Ошибка выбора кода оплаты документа производства."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         undo, return no-apply .
      end.
      run get-pay-name in this-procedure (
         input fi-pay-code
         , output fi-pay-type-name
         ).
      display
         fi-pay-code
         fi-pay-type-name
         with frame {&frame-name}.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-ingr
&Scoped-define SELF-NAME br-ingr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ingr D-FBR-DOC
ON row-display OF br-ingr IN FRAME D-FBR-DOC
DO:

  run rowdisp .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME r-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-price D-FBR-DOC
ON CHOOSE OF r-price IN FRAME D-FBR-DOC /* r-price */
   DO:
      define variable v-user-select as logical   no-undo .
      define variable v-obj-type    as character no-undo .
      define variable v-obj-code    as integer   no-undo .

      { gbl/stdbtn.i }

      { gbl/uobjsone.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
      v-obj-type
      v-obj-code
    }
      if v-user-select <> true
         then 
      do:
         return no-apply .
      end.

      assign
         v-price-sale-obj-type = v-obj-type
         v-price-sale-obj-code = v-obj-code
         .
      run UI-on in this-procedure ( input "line" ).
      return no-apply.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-one-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-one-all D-FBR-DOC
ON VALUE-CHANGED OF rs-one-all IN FRAME D-FBR-DOC
   DO:
      assign
         rs-one-all
         .
      run assign-current-goods.
      run UI-on ("enable").
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME shift-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL shift-sel D-FBR-DOC
ON CHOOSE OF shift-sel IN FRAME D-FBR-DOC
   DO:
      run proc-sht.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-comp
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-FBR-DOC 


/*{ gbl/f2gds.i br-comp get-current-goods-recid parparentproc }*/
{ gbl/f2.i {&browse-name} "goods-recid" "get-goods-recid" parparentproc  }

/* ***************************  Main Block  *************************** */
{ gbl/getcntxt.i get }

   if objSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true . 
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanAltr then v-ban-altr = true .

ON CHOOSE OF b-next IN FRAME {&frame-name}
   DO:
      if valid-handle (br-handle) then 
      do:
         v-fbr-doc-g-log = br-handle:select-next-row().
         if not v-fbr-doc-g-log then message "Это последний документ списка.".
      end.
      assign
         p-fbr-doc-recid     = recid( f-doc )
         p-new-fbr-doc-recid = p-fbr-doc-recid
         p-fbr-doc-next-prev = yes
         .
   END.

ON CHOOSE OF b-prev IN FRAME {&frame-name}
   DO:
      if valid-handle (br-handle) then 
      do:
         v-fbr-doc-g-log = br-handle:select-prev-row().
         if not v-fbr-doc-g-log then message "Это первый документ списка.".
      end.
      assign
         p-fbr-doc-recid     = recid( f-doc )
         p-new-fbr-doc-recid = p-fbr-doc-recid
         p-fbr-doc-next-prev = yes
         .
   END.

on return, mouse-select-dblclick of buf_comp_fbr-line.is-calc in browse br-comp 
   do:
      /* инвертируем значение на экране */
      buf_comp_fbr-line.is-calc:screen-value in browse br-comp =
         string ((buf_comp_fbr-line.is-calc:screen-value in browse br-comp = "-"), buf_comp_fbr-line.is-calc:format in browse br-comp).
      return no-apply.
   end.

on return, mouse-select-dblclick of buf_ingr_fbr-line.is-calc in browse br-ingr 
   do:
      /* инвертируем значение на экране */
      buf_ingr_fbr-line.is-calc:screen-value in browse br-ingr =
         string ((buf_ingr_fbr-line.is-calc:screen-value in browse br-ingr = "-"), buf_ingr_fbr-line.is-calc:format in browse br-ingr).
      return no-apply.
   end.

on return, mouse-select-dblclick of buf_comp_fbr-line.fix-cost in browse br-comp 
   do:
      /* инвертируем значение на экране */
      buf_comp_fbr-line.fix-cost:screen-value in browse br-comp =
         string ((buf_comp_fbr-line.fix-cost:screen-value in browse br-comp = "-"), buf_comp_fbr-line.fix-cost:format in browse br-comp).
      return no-apply.
   end.

on return, mouse-select-dblclick of buf_ingr_fbr-line.fix-cost in browse br-ingr 
   do:
      /* инвертируем значение на экране */
      buf_ingr_fbr-line.fix-cost:screen-value in browse br-ingr =
         string ((buf_ingr_fbr-line.fix-cost:screen-value in browse br-ingr = "-"), buf_ingr_fbr-line.fix-cost:format in browse br-ingr).
      return no-apply.
   end.

on value-changed of fact-date in frame {&FRAME-NAME} 
   do:
      assign frame {&FRAME-NAME} fact-date no-error.
      f-doc.fact-date = fact-date.
   end.

PROCEDURE proc-sht :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define buffer bf_shift-obj for ub.shift-obj.
   define variable varrid-list as character no-undo.
   define variable varrecid    as recid     no-undo.
   assign
      varrid-list = "".
   run str/sht-all.w (parparentproc, f-doc.obj-type, f-doc.obj-code, 'b-sel', 'obj',f-doc.obj-type, f-doc.obj-code, '':u, input-output varrid-list) no-error.
   if error-status:error or varrid-list = "":u then 
   do:
      return.
   end.
   else 
   do:
      assign
         varrecid = integer (entry(1, varrid-list)).
      find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
      if available bf_shift-obj then 
      do:
         assign
            f-doc.shift-date = bf_shift-obj.shift-date
            f-doc.shift-num  = bf_shift-obj.shift-num
            f-doc.shift-name = bf_shift-obj.shift-name.
         shift = subst("&1 &2 &3", f-doc.shift-date, f-doc.shift-num, f-doc.shift-name ).
         display shift f-doc.shift-date f-doc.shift-num f-doc.shift-name with frame {&frame-name}.
         assign
            f-doc.fact-date = f-doc.shift-date
            fact-date       = f-doc.shift-date.
         display fact-date with frame {&frame-name}.
      end.
   end.

END PROCEDURE.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
   THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

assign
   p-new-fbr-doc-recid = p-fbr-doc-recid
   .
{ gbl/getcntxt.i get }
{ gbl/rbisbase.i
  v-base
}
{ gbl/app_help.i &disable_diasize=true }
{ gbl/srt-clmd.i
  &browse-name          = "br-comp"
  &frame-name           = "{&frame-name}"
  &table-name           = "buf_comp_fbr-line"
  &sort-clmn_1          = "comp-name"
  &dyn_sort-clmn_1      = "substitute('dynamic-function(&1get-goods-name&1,recid(buf_comp_fbr-line))',~{&double-quote~})"
  &sort-clmn_2          = "buf_comp_fbr-line.trn-type"
  &sort-clmn_3          = "comp-OK"
  &dyn_sort-clmn_3      = "substitute('dynamic-function(&1get-line-OK&1,recid(buf_comp_fbr-line))',~{&double-quote~})"
  &sort-clmn_4          = "buf_comp_fbr-line.fact-qnty"
  &sort-clmn_5          = "comp-unit"
  &dyn_sort-clmn_5      = "substitute('dynamic-function(&1get-unit-base&1,recid(buf_comp_fbr-line))',~{&double-quote~})"
  &sort-clmn_6          = "buf_comp_fbr-line.is-calc"
  &sort-clmn_7          = "buf_comp_fbr-line.price-sale"
  &sort-clmn_8          = "buf_comp_fbr-line.fix-cost"
  &sort-clmn_9          = "buf_comp_fbr-line.price-base"
  &sort-clmn_10         = "buf_comp_fbr-line.price-rubl"
  &sort-clmn_11         = "buf_comp_fbr-line.rsrv-qnty"
  &sort-clmn_12         = "comp-prod"
  &dyn_sort-clmn_12     = "substitute('dynamic-function(&1get-prod-ref&1,recid(buf_comp_fbr-line))',~{&double-quote~})"
  &open-query           = "run open-comp."
  &open-query-otherwise = "run open-comp."
  &sort-column-name     = "comp-sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no"
}
{ gbl/srt-clmd.i
  &browse-name          = "br-ingr"
  &frame-name           = "{&frame-name}"
  &table-name           = "buf_ingr_fbr-line"
  &sort-clmn_1          = "ingr-name"
  &dyn_sort-clmn_1      = "substitute('dynamic-function(&1get-goods-name&1,recid(buf_ingr_fbr-line))',~{&double-quote~})"
  &sort-clmn_2          = "buf_ingr_fbr-line.trn-type"
  &sort-clmn_3          = "ingr-OK"
  &dyn_sort-clmn_3      = "substitute('dynamic-function(&1get-line-OK&1,recid(buf_ingr_fbr-line))',~{&double-quote~})"
  &sort-clmn_4          = "buf_ingr_fbr-line.fact-qnty"
  &sort-clmn_5          = "ingr-unit"
  &dyn_sort-clmn_5      = "substitute('dynamic-function(&1get-unit-base&1,recid(buf_ingr_fbr-line))',~{&double-quote~})"
  &sort-clmn_6          = "buf_ingr_fbr-line.is-calc"
  &sort-clmn_7          = "buf_ingr_fbr-line.price-sale"
  &sort-clmn_8          = "buf_ingr_fbr-line.fix-cost"
  &sort-clmn_9          = "buf_ingr_fbr-line.price-base"
  &sort-clmn_10         = "buf_ingr_fbr-line.price-rubl"
  &sort-clmn_11         = "buf_ingr_fbr-line.rsrv-qnty"
  &sort-clmn_12         = "ingr-prod"
  &dyn_sort-clmn_12     = "substitute('dynamic-function(&1get-prod-ref&1,recid(buf_ingr_fbr-line))',~{&double-quote~})"
  &open-query           = "run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?)."
  &open-query-otherwise = "run open-ingr (if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ?)."
  &sort-column-name     = "ingr-sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no"
}
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

/* закрытие документа задним числом возможно? */

delete object v-tth no-error.
run adm/shattri.p (
   input "get":U
   ,input v-cntxt-obj-type
   ,input v-cntxt-obj-code
   ,input {&attr-nakl_par}
   ,input  "back-date"
   ,output v-value-character
   ,output v-value-date
   ,output v-value-decimal
   ,output v-value-integer
   ,output v-back-date
   ,output v-back-date-type
   ,INPUT-OUTPUT table-handle v-tth
   ) no-error .
if error-status :error  then v-back-date = false .
delete object v-tth no-error.
if error-status:error then v-back-date = false.

{ gbl/objat.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    "'shift-on=request'"
    is-shift-on
    no-error
}

{ gbl/ed_date.i fact-date }

hbrowse = browse br-ingr:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).  
  bcol[ii] = hbrowse:get-browse-column (ii).
end.

hbrowse_comp = browse br-comp:handle.
extent (bcol_comp) = hbrowse_comp:num-columns.
bcol_comp[1] = hbrowse_comp:first-column.
do ii = 1 to extent (bcol_comp).  
  bcol_comp[ii] = hbrowse_comp:get-browse-column (ii).
end.

/* зацикливание формы */
assign
   p-fbr-doc-next-prev = yes
   .
n-p:
do while p-fbr-doc-next-prev
   :
   MAIN-BLOCK:
   DO
      ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      :
      run writelog in this-procedure (log-file-name, 0, "&DLine").
      run writelog in this-procedure (log-file-name, 1, "Запуск блока Производства").
      if p-doc-mode <> {&add-def}
         then 
      do:
         define variable v-fbroperator-string as character no-undo.
         define variable v-fbrpaycode-string  as character no-undo.
         run str/fbrattrv.p (
            input f-doc.doc-code
            , input {&trdcattr-fbroperator}
            , output v-fbroperator-string
            ) no-error.
         if error-status :error
            then 
         do:
            message
               vss-workfile vss-revision vss-description
               skip(1)
               skip 
               "Ошибка определения оператора производства."
               skip(1)
               skip 
               "Выберите ответственного за операции производства."
               skip return-value
               skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               view-as alert-box warning.
            assign
               v-fbr-doc-fbroperator-code = 0
               .
         end.
         assign
            v-fbr-doc-fbroperator-code = integer( v-fbroperator-string )
            no-error.
         if error-status :error
            then 
         do:
            assign
               v-fbr-doc-fbroperator-code = 0
               .
         end.
         else 
         do:
            define buffer buf_clients for ub.clients.

            find first buf_clients no-lock
               where buf_clients.obj-type = {&prs}
               and buf_clients.obj-code = v-fbr-doc-fbroperator-code
               no-error.
            if not available buf_clients
               then 
            do:
               assign
                  v-fbr-doc-fbroperator-code = 0
                  .
            end.
         end.
         if f-doc.pay-code = ?
            or f-doc.pay-code = 0
            then 
         do:
            { gbl/objdnpay.i
                    f-doc.obj-type
                    f-doc.obj-code
                    fi-pay-code
                }
         end.
         else 
         do:
            assign
               fi-pay-code = f-doc.pay-code
               .
         end.
      end.
      run mode-on no-error.
      if error-status:error
         then 
      do:
         undo, return error.
      end.
      if p-doc-mode = {&update}
         then 
      do:
         run hide-not-avail-menu-items in this-procedure (
            input f-doc.is-free
            ).
      end.
      if p-doc-mode = {&add-def}
         then 
      do:
         assign
            p-doc-mode = {&update}
            .
      end.
      assign
         rs-one-all            = "recipe":U
         v-fbr-doc-rep-rec     = ?                 /* чтобы не пыталась встать на строку в нижнем browse */
         v-price-sale-obj-type = v-cntxt-obj-type
         v-price-sale-obj-code = v-cntxt-obj-code
         .
        
      display f-doc.fact-date @ fact-date with frame {&FRAME-NAME}.
      shift = subst("&1 &2 &3", f-doc.shift-date, f-doc.shift-num, f-doc.shift-name).
      if f-doc.shift-date <> ? then
         display shift with frame {&FRAME-NAME}.
        
      run get-pay-type-name in this-procedure (
         input fi-pay-code
         , output fi-pay-type-name
         ).
      run UI-on in this-procedure (
         input "enable":U
         ).
      if v-fbr-doc-line-rec <> ?
         and p-doc-mode = {&lookup}
         then 
      do:
         reposition br-comp to recid v-fbr-doc-line-rec no-error.
      end.
      WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-comp.
   END.
end. /* Зацикливания */
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-free-fbr-line D-FBR-DOC 
PROCEDURE add-free-fbr-line :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   do
      on error undo, return error
      :
      define input parameter p-browse         as character                no-undo. /* up - верхний браус, down - нижний */
      define input parameter p-price-obj-type like ub.clients.obj-type       no-undo. /* тип объекта для поиска прод цены */
      define input parameter p-price-obj-code like ub.clients.obj-code       no-undo. /* код объекта для поиска прод цены */

      define variable vss-description            as character no-undo init "Добавление строк без рецепта.".
      define variable v-trn-type                 as character no-undo.  /* тип добавляемой строки */
      define variable v-fbr-v-fbr-doc-line-recid as recid     no-undo.  /* ссылка на добавляемую строку */
      define variable v-cancel                   as logical   no-undo.

      define buffer buf_goods    for ub.goods.
      define buffer buf_gds-prt  for ub.gds-prt.
      define buffer buf_fbr-line for ub.fbr-line.

      if p-browse = "up"
         then 
      do:
         assign
            v-trn-type = {&income}
            .
      end.
      else 
      do:
         assign
            v-trn-type = {&write-off}
            .
      end.
      find first buf_goods no-lock
         where recid( buf_goods ) = gds-rec
         .
      find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
         .
      if buf_goods.gds-type = {&gds-office}
         and v-trn-type = {&income}
         then 
      do:
         message
            "Невозможно добавить услугу в приход."
            skip(1) "Услуга:" buf_goods.artic buf_goods.gds-name
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return error.
      end.
      if buf_goods.stts <> 0
         then 
      do:
         message
            "Невозможно добавить в документ удаленный товар."
            skip(1) "Товар:" buf_goods.artic buf_goods.gds-name
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return error.
      END.
      /* ищем противоположную строку для товара с пустым номером рецепта */
      find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code    = f-doc.doc-code
         and buf_fbr-line.trn-type    <> v-trn-type
         and buf_fbr-line.recipe-code = ""
         and buf_fbr-line.artic       = buf_goods.artic
         and buf_fbr-line.prod-type   = buf_goods.prod-type
         and buf_fbr-line.prod-code   = buf_goods.prod-code
         no-error.
      if available buf_fbr-line
         then 
      do:
         assign
            v-fbr-doc-g-log = no
            .
         message
            "Выбранный для добавления товар уже есть в этом документе."
            skip 
            "Ингредиенты не могут совпадать с получаемыми товарами !"
            skip(1) "Товар:" buf_goods.artic buf_goods.gds-name
            view-as alert-box error
            title "Ошибка добавления товара".
         undo, return error.
      end.
      /* добавляем строку для товара с пустым номером рецепта */
      run str/fbr-crln.p (
         input parparentproc
         , input p-fbr-doc-recid
         , input gds-rec
         , input ""                  /* код рецепта */
         , input v-trn-type          /* тип добавляемой строки */
         , input ( p-browse = "up" ) /* составная / ингредиент */
         , input no                  /* recursive-recipe */
         , input p-price-obj-type
         , input p-price-obj-code
         , output v-fbr-v-fbr-doc-line-recid
         ).
      if p-browse = "up"
         then 
      do:
         find first buf_fbr-line no-lock
            where recid (buf_fbr-line) = v-fbr-v-fbr-doc-line-recid
            .
         assign
            v-fbr-doc-line-rec = recid( buf_fbr-line )
            .
         run str/fbr-line.w (
            input p-fbrhist-handle
            , input {&update}
            , input buf_fbr-line.doc-code
            , input v-fbr-doc-line-rec
            , input ?
            , output v-cancel
            ).
      /*        assign*/
      /*            buf_fbr-line.fact-qnty = buf_fbr-line.fact-qnty + p-qnty*/
      /*        .*/
      end.
      else 
      do:
         do transaction
            on error undo, return error
            :
            find first buf_fbr-line exclusive-lock
               where recid (buf_fbr-line) = v-fbr-v-fbr-doc-line-recid
               .
            assign
               v-fbr-doc-rep-rec      = recid( buf_fbr-line )
               buf_fbr-line.fact-qnty = 0
               .
         end.        /* do transaction */
      end.
   end.
END PROCEDURE. /* add-free-fbr-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-proc D-FBR-DOC 
PROCEDURE add-proc :
   /*------------------------------------------------------------------------------
     Purpose:     добавление строки по рецепту и без
   ------------------------------------------------------------------------------*/
   do transaction
      on error undo, return error
      :
      define input parameter p-mode                   as character    no-undo.
      define input parameter p-price-sale-obj-type    as character    no-undo.
      define input parameter p-price-sale-obj-code    as integer      no-undo.

      define variable v-goods-recid-list as character no-undo.
      define variable vss-description    as character no-undo init "add-proc: ".
      define variable v-value            as character no-undo .
      define variable v-type             as character no-undo .
      define variable v-attr-value as character no-undo .
      define variable v-attr-value-rec as character no-undo .
      define variable v-attr-type as character no-undo .

      define buffer buf_goods    for ub.goods.
      define buffer buf_fbr-line for ub.fbr-line.

      run str/chs-gds.w (
         input parparentproc
         , input f-doc.obj-type
         , input f-doc.obj-code
         , input '':U
         , input '':U
         , input "Строка документа № " + f-doc.doc-code
         , input {&g___object}            /* режим вызова справочника */
         , input ?
         , input ?
         , input ?
         , input ?
         , input-output v-artic
         , output v-goods-recid-list
         ) .
      if v-goods-recid-list <> ''
         then 
      do:
         define variable v-line-counter as integer no-undo.
         assign
            v-fbr-doc-line-rec = ?
            v-line-counter     = 1
            .
         do while v-line-counter <= num-entries ( v-goods-recid-list )
            :
            assign
               gds-rec        = integer( entry ( v-line-counter, v-goods-recid-list ) )
               v-line-counter = v-line-counter + 1
               .
            find first buf_goods no-lock
               where recid( buf_goods ) = gds-rec
               .
            
            case p-mode
               :
               when "rcp"
               then 
                  do:
                     run writelog in this-procedure (log-file-name, 1, substitute( "Добавление товара с артикулом &1 по рецепту.", buf_goods.artic ) ).
                     RUN gds-attr-value (
                          INPUT buf_goods.gds-code,
                          INPUT {&attr-mark-type},
                          OUTPUT v-attr-value,
                          OUTPUT v-attr-type
                          ).
                     v-isweighed = WghProdVariable(v-cntxt-obj-type, v-cntxt-obj-code, buf_goods.gds-code) .
                     if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsEDOForType(v-attr-value)
                     or v-isweighed
                     then do : 
                       empty temp-table tt-marking-lines .
                       run str/fbr-doc-dish-marks-add.w (input parparentproc,
                                                         input gds-rec,
                                                         output table tt-marking-lines) .
                     end . 
                     run add-recipe in this-procedure (
                        input f-doc.doc-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                        , input no  /* не раскручивать */
                        ) no-error.
                     if error-status :error
                     then do:
                       undo, return error.
                     end.
                  end.
               when "rcp-all"
               then 
                  do:
                     run writelog in this-procedure (log-file-name, 1, substitute( "Добавление товара с артикулом &1 по рецепту. Раскрутка.", buf_goods.artic ) ).
                     run add-recipe in this-procedure (
                        input f-doc.doc-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                        , input yes /* раскручивать */
                        ) .
                  end.
               when "up"
               then 
                  do:
                     run writelog in this-procedure (log-file-name, 1, substitute( "Добавление товара с артикулом &1 без рецепта в верхний список.", buf_goods.artic ) ).
                     run add-free-fbr-line in this-procedure (
                        input p-mode  /* в какой браус добавляется */
                        , input p-price-sale-obj-type
                        , input p-price-sale-obj-code
                        ) .
                  end.
               when "down"
               then 
                  do:
                     if v-ban-recipes then 
                     do:
                        /*Проверка на маркировку*/
                        run gds-attr-value in this-procedure  ( input  buf_goods.gds-code
                           , input  {&attr-mark-type}
                           , output v-attr-value
                           , output v-attr-type
                           ) no-error .
                        if v-attr-value <> "" and v-attr-value <> "not-type" then
                        do:
                           message "Добавление маркированного товара в ингридиенты, запрещено"
                              view-as alert-box.
                           return .
                        end.   
                     end.
                     run writelog in this-procedure (log-file-name, 1, substitute( "Добавление товара с артикулом &1 без рецепта в нижний список.", buf_goods.artic ) ).
                     run add-free-fbr-line in this-procedure (
                        input p-mode        /* в какой браус добавляется */
                        , input p-price-sale-obj-type
                        , input p-price-sale-obj-code
                        ) .
                     if rs-one-all = "recipe"
                        then 
                     do:
                        find first buf_comp_fbr-line no-lock
                           where buf_comp_fbr-line.is-comp = yes
                           and buf_comp_fbr-line.doc-code = f-doc.doc-code
                           and buf_comp_fbr-line.recipe-code = ""
                           no-error.
                        if available buf_comp_fbr-line
                           then 
                        do:    /* встаем в верхнем браусе на строку с пустым рецептом и показаваем все такие строки */
                           assign
                              v-fbr-doc-line-rec = recid (buf_comp_fbr-line)
                              .
                        end.
                        else 
                        do:    /* для включения всех строк в нижнем браусе и reposition на новую - она в v-fbr-doc-rep-rec */
                           assign
                              v-fbr-doc-line-rec = ?
                              .
                        end.
                     end.
                  end.
            end.
         end.
         run UI-on ("line").
      end.        /* if v-goods-recid-list <> '' */
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-recipe D-FBR-DOC 
PROCEDURE add-recipe :
   /*------------------------------------------------------------------------------
     Purpose:     Добавление в документ товара с рецептом
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   do
      on error undo, return error
      :
      define input parameter p-fbr-doc-doc-code   as character    no-undo.
      define input parameter p-artic              as character    no-undo.
      define input parameter p-prod-type          as character    no-undo.
      define input parameter p-prod-code          as integer      no-undo.
      define input parameter p-add-childs         as logical      no-undo.

      define variable v-same-good          as logical no-undo.
      define variable v-same-good-old-qnty as decimal no-undo.

      run create-initial-temp-goods in this-procedure (
         input p-fbr-doc-doc-code
         , input p-artic
         , input p-prod-type
         , input p-prod-code
         , input /*{&income}*/ ?
         , input ?
         , input ?
         , input ?
         , output v-same-good
         , output v-same-good-old-qnty
         ).
      run calc-not-calculated-goods in this-procedure (
         input parparentproc
         , input p-fbrhist-handle
         , input p-fbr-doc-doc-code
         , input v-same-good
         , input v-same-good-old-qnty
         , input no
         , input p-add-childs
         , input v-price-sale-obj-type
         , input v-price-sale-obj-code
         , input no
         , input no
         ) no-error.
      if error-status :error
      then do:
        undo, return error.
      end.
      run writelog in this-procedure ( log-file-name, 2, "Добавление товаров завершено." ).
   end.
END PROCEDURE. /* add-recipe */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adjust-changed-ingr-line D-FBR-DOC 
PROCEDURE adjust-changed-ingr-line :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-doc-code               as character        no-undo.
   define input parameter p-recipe-code            as character        no-undo.
   define input parameter p-artic                  as character        no-undo.
   define input parameter p-prod-type              as character        no-undo.
   define input parameter p-prod-code              as integer          no-undo.
   define input parameter p-old-fact-qnty          as decimal          no-undo.
   define input parameter p-old-price-sale         as decimal          no-undo.
   define input parameter p-old-cost-base          as decimal          no-undo.
   define input parameter p-old-cost-rubl          as decimal          no-undo.
   define input parameter p-old-cost-sum-vat-base  as decimal          no-undo.
   define input parameter p-old-cost-sum-vat-rubl  as decimal          no-undo.
   define input parameter p-old-vat-coeff          as decimal          no-undo.

   define variable v-price-sale as decimal no-undo.
   define variable v-base-rate  as decimal no-undo.
   define variable v-base-scale as decimal no-undo.
   define variable v-today      as date    no-undo.
   define variable v-time       as integer no-undo.

   define buffer buf_fbr-line       for ub.fbr-line.
   define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
   do
      for buf_fbr-line
      with frame {&frame-name}
      on error undo, return error
      :
      find first buf_fbr-line exclusive-lock
         where buf_fbr-line.doc-code    = p-doc-code
         and buf_fbr-line.is-comp     = no
         and buf_fbr-line.recipe-code = p-recipe-code
         and buf_fbr-line.artic       = p-artic
         and buf_fbr-line.prod-type   = p-prod-type
         and buf_fbr-line.prod-code   = p-prod-code
         .
      if p-old-fact-qnty <> buf_fbr-line.fact-qnty
         then 
      do:
         assign
            buf_fbr-line.calc-method = 1
            .
         display
            get-netto-qnty(recid(buf_fbr-line)) @ ingr-netto
            with browse br-ingr .
      end.
      case f-doc.status_
         :
         when {&g___new}
         then 
            do:
               if buf_fbr-line.price-sale <> p-old-price-sale
                  then 
               do:      /* изменилась цена - ставим отметку */
                  assign
                     buf_fbr-line.is-calc = yes
                     .
               end.
               run fbrlib-calc-prices in this-procedure (
                  input recid( buf_fbr-line )
                  , input v-price-sale-obj-type
                  , input v-price-sale-obj-code
                  , output v-price-sale
                  ) no-error.
               if error-status:error then 
               do:
                  message substitute("Ошибка при расчете цен по док-ту&1&2&1&3"
                     , {&new-line}
                     , error-status:get-message(1)
                     , return-value )
                     view-as alert-box error .
                  undo, return error .
               end.
               /* if v-price-sale <> ?
               then do: */   /* нулевую цену не ставим, чтобы можно было задать вручную */
               assign
                  buf_fbr-line.price-sale = v-price-sale
                  .
               if v-price-sale-obj-type <> v-cntxt-obj-type
                  or v-price-sale-obj-code <> v-cntxt-obj-code
                  then 
               do:    /* цена с другого объекта - фиксируем */
                  assign
                     buf_fbr-line.is-calc = yes
                     .
               end.
            /*end.*/       /* if v-price-sale <> ? */
            end.        /* when f-doc.status_ = {&g___new} */
         when {&permitted}
         then 
            do:
               find first ub.fbr-recipe no-lock
                  where ub.fbr-recipe.recipe-code = buf_fbr-line.recipe-code
                  no-error.
               if buf_fbr-line.trn-type = {&write-off}
                  or buf_fbr-line.is-comp
                  or buf_fbr-line.rsrv-qnty = ?
                  then 
               do:
                  assign      /* редактирование учетных цен запрещено */
                     buf_fbr-line.fix-cost = no
                     .
               end.
               else 
               do:        /* редактирование учетных цен разрешено */
                  if ( v-base = yes and ( buf_fbr-line.price-base <> p-old-cost-base or buf_fbr-line.price-sum-vat-base <> p-old-cost-sum-vat-base ) )
                     or ( v-base = no  and ( buf_fbr-line.price-rubl <> p-old-cost-rubl or buf_fbr-line.price-sum-vat-rubl <> p-old-cost-sum-vat-rubl ) )
                     then 
                  do:        /* изменилась цена или сумма НДС - ставим отметку */
                     assign
                        buf_fbr-line.fix-cost       = yes
                        buf_fbr-line.price-sum-rubl = buf_fbr-line.price-rubl * buf_fbr-line.fact-qnty
                        buf_fbr-line.price-sum-base = buf_fbr-line.price-base * buf_fbr-line.fact-qnty
                        .
                     if ( v-base = yes and buf_fbr-line.price-base <> p-old-cost-base )
                        or ( v-base = no  and buf_fbr-line.price-rubl <> p-old-cost-rubl )
                        then 
                     do:        /* изменилась цена - пересчитать НДС */
                        assign
                           buf_fbr-line.price-sum-vat-rubl = p-old-vat-coeff * buf_fbr-line.price-sum-rubl
                           buf_fbr-line.price-sum-vat-base = p-old-vat-coeff * buf_fbr-line.price-sum-base
                           .
                     end.
                  end.
                  run cur-time in this-procedure ( output v-today
                     , output v-time
                     ).
                  { gbl/baserate.i
                    f-doc.host-code
                    v-today
                    v-base-rate
                    v-base-scale
                    no-error
                }
                  if error-status :error
                     then 
                  do:
                     message
                        vss-workfile vss-revision vss-description
                        skip 
                        "Ошибка вычисления курса базовой валюты."
                        skip return-value
                        skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                        view-as alert-box error.
                     undo, return error .
                  end.
                  if v-base = yes
                     then 
                  do:
                     assign
                        buf_fbr-line.price-rubl         = buf_fbr-line.price-base
                                                                * ( if v-base-rate = 0 then 1 else v-base-rate )
                                                                / ( if v-base-scale = 0 then 1 else v-base-scale )
                        buf_fbr-line.price-sum-rubl     = buf_fbr-line.price-rubl * buf_fbr-line.fact-qnty
                        buf_fbr-line.price-sum-vat-rubl = buf_fbr-line.price-sum-vat-base
                                                                * ( if v-base-rate = 0 then 1 else v-base-rate )
                                                                / ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
                  else 
                  do:
                     assign
                        buf_fbr-line.price-base         = buf_fbr-line.price-rubl
                                                                / ( if v-base-rate = 0 then 1 else v-base-rate )
                                                                * ( if v-base-scale = 0 then 1 else v-base-scale )
                        buf_fbr-line.price-sum-base     = buf_fbr-line.price-base * buf_fbr-line.fact-qnty
                        buf_fbr-line.price-sum-vat-base = buf_fbr-line.price-sum-vat-rubl
                                                                / ( if v-base-rate = 0 then 1 else v-base-rate )
                                                                * ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
                  if buf_fbr-line.price-base <> p-old-cost-base
                     or buf_fbr-line.price-rubl <> p-old-cost-rubl
                     then 
                  do:
                     run str/fbrclcin.p (
                        input buf_fbr-line.doc-code
                        , input buf_fbr-line.recipe-code
                        , input v-base
                        , input v-base-rate
                        , input v-base-scale
                        ).
                  end.
               end.                /* редактирование учетных цен разрешено */
            end.                /* when f-doc.status_ = {&permitted} */
      end case.       /* case f-doc.status_ */
   end.
END PROCEDURE. /* adjust-changed-ingr-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-current-goods D-FBR-DOC 
PROCEDURE assign-current-goods :
   /*------------------------------------------------------------------------------
     Purpose: определить recid текущего товара
   ------------------------------------------------------------------------------*/
   do
      on error undo, return error
      :
      define buffer buf_goods for ub.goods.

      if current-browse = br-ingr :handle in frame {&frame-name}
         or not available( buf_comp_fbr-line )
         then 
      do:
         find first buf_goods no-lock
            where buf_goods.artic     = buf_ingr_fbr-line.artic
            and buf_goods.prod-type = buf_ingr_fbr-line.prod-type
            and buf_goods.prod-code = buf_ingr_fbr-line.prod-code
            no-error.
      end.
      else 
      do:
         find first buf_goods no-lock
            where buf_goods.artic     = buf_comp_fbr-line.artic
            and buf_goods.prod-type = buf_comp_fbr-line.prod-type
            and buf_goods.prod-code = buf_comp_fbr-line.prod-code
            no-error.
      end.
      if available buf_goods
         then 
      do:
         assign
            gds-rec = recid( buf_goods )
            .
      end.
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-ingr-line D-FBR-DOC 
PROCEDURE assign-ingr-line :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-ingr-fbr-line-rowid    as rowid            no-undo.
   define input parameter p-fact-qnty              as decimal          no-undo.
   define input parameter p-is-calc                as logical          no-undo.
   define input parameter p-price-sale             as decimal          no-undo.
   define input parameter p-fix-cost               as logical          no-undo.
   define input parameter p-price-rubl             as decimal          no-undo.
   define input parameter p-price-base             as decimal          no-undo.
   define input parameter p-price-sum-vat-rubl     as decimal          no-undo.
   define input parameter p-price-sum-vat-base     as decimal          no-undo.

   define variable old-fact-qnty         as decimal no-undo .
   define variable old-price-sale        like ub.fbr-line.price-sale no-undo .
   define variable old-cost-base         like ub.fbr-line.price-base no-undo .
   define variable old-cost-rubl         like ub.fbr-line.price-rubl no-undo .
   define variable old-cost-sum-vat-base like ub.fbr-line.price-base no-undo .
   define variable old-cost-sum-vat-rubl like ub.fbr-line.price-rubl no-undo .
   define variable old-vat-coeff         as decimal no-undo.

   define buffer buf_loc_ingr_fbr-line for ub.fbr-line.
   do
      for buf_loc_ingr_fbr-line
      on error undo, return error
      :
      find first buf_loc_ingr_fbr-line exclusive-lock
         where rowid( buf_loc_ingr_fbr-line ) = p-ingr-fbr-line-rowid
         .
      assign
         old-fact-qnty         = buf_loc_ingr_fbr-line.fact-qnty
         old-price-sale        = buf_loc_ingr_fbr-line.price-sale
         old-cost-rubl         = buf_loc_ingr_fbr-line.price-rubl
         old-cost-base         = buf_loc_ingr_fbr-line.price-base
         old-cost-sum-vat-rubl = buf_loc_ingr_fbr-line.price-sum-vat-rubl
         old-cost-sum-vat-base = buf_loc_ingr_fbr-line.price-sum-vat-base
         .
      if v-base = yes
         then 
      do:
         assign
            old-vat-coeff = ( if old-cost-base = 0
                                or old-cost-base = ?
                                then 0
                                else old-cost-sum-vat-base / ( old-cost-base * buf_loc_ingr_fbr-line.fact-qnty ) )
            .
      end.
      else 
      do:
         assign
            old-vat-coeff = ( if old-cost-rubl = 0
                                or old-cost-rubl = ?
                                then 0
                                else old-cost-sum-vat-rubl / ( old-cost-rubl * buf_loc_ingr_fbr-line.fact-qnty ) )
            .
      end.
      assign
         buf_loc_ingr_fbr-line.fact-qnty          = p-fact-qnty
         buf_loc_ingr_fbr-line.is-calc            = p-is-calc
         buf_loc_ingr_fbr-line.price-sale         = p-price-sale
         buf_loc_ingr_fbr-line.fix-cost           = p-fix-cost
         buf_loc_ingr_fbr-line.price-rubl         = p-price-rubl
         buf_loc_ingr_fbr-line.price-base         = p-price-base
         buf_loc_ingr_fbr-line.price-sum-vat-rubl = p-price-sum-vat-rubl
         buf_loc_ingr_fbr-line.price-sum-vat-base = p-price-sum-vat-base
         .
      run adjust-changed-ingr-line in this-procedure (
         input buf_loc_ingr_fbr-line.doc-code
         , input buf_loc_ingr_fbr-line.recipe-code
         , input buf_loc_ingr_fbr-line.artic
         , input buf_loc_ingr_fbr-line.prod-type
         , input buf_loc_ingr_fbr-line.prod-code
         , input old-fact-qnty
         , input old-price-sale
         , input old-cost-base
         , input old-cost-rubl
         , input old-cost-sum-vat-base
         , input old-cost-sum-vat-rubl
         , input old-vat-coeff
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip 
            "Ошибка пересчета измененной строки"
            skip 
            "документа производства"
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
         undo, return error .
      end.
   end.
END PROCEDURE. /* assign-ingr-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-obj-fbroperator D-FBR-DOC 
PROCEDURE assign-obj-fbroperator :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define buffer buf_clients for ub.clients.
   do
      for buf_clients
      on error undo, return error
      :
      if v-fbr-doc-fbroperator-code = 0
         then 
      do:
         assign
            obj-fbroperator = "":U
            .
      end.
      else 
      do:
         find first buf_clients no-lock
            where buf_clients.obj-type = {&prs}
            and buf_clients.obj-code = v-fbr-doc-fbroperator-code
            no-error.
         if available buf_clients
            then 
         do:
            assign
               obj-fbroperator = buf_clients.obj-name
               .
         end.
         else 
         do:
            assign
               obj-fbroperator = "":U
               .
         end.
      end.
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-current-comp-line D-FBR-DOC 
PROCEDURE change-current-comp-line :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   do
      on error undo, return error
      :
      define input parameter p-comp-fbr-v-fbr-doc-line-recid    as recid        no-undo.
      define input parameter p-fbr-doc-status         as character    no-undo.
      define input parameter p-host-code              as integer      no-undo.

      define variable old-cost-base         like ub.fbr-line.price-base no-undo .
      define variable old-cost-rubl         like ub.fbr-line.price-rubl no-undo .
      define variable old-cost-sum-vat-base like ub.fbr-line.price-sum-vat-base no-undo .
      define variable old-cost-sum-vat-rubl like ub.fbr-line.price-sum-vat-rubl no-undo .
      define variable v-price-sale          as decimal no-undo.

      define variable v-today               as date    no-undo.
      define variable v-time                as integer no-undo.
      define variable v-base-rate           as decimal no-undo.
      define variable v-base-scale          as decimal no-undo.

      define buffer buf_fbr-doc  for ub.fbr-doc.
      define buffer buf_fbr-line for ub.fbr-line.
      define buffer buf_recipe   for ub.fbr-recipe.

      find first buf_fbr-line exclusive-lock
         where recid( buf_fbr-line ) = p-comp-fbr-v-fbr-doc-line-recid
         .
      if p-fbr-doc-status = {&g___new}
         then 
      do:        /* для статуса Новый может измениться только цена продажи или ее фиксированность */
         /* подстановка в строку документа производства цены, если она не фиксирована */
         assign
            browse br-comp
            buf_comp_fbr-line.is-calc
            .
         run fbrlib-calc-prices in this-procedure (
            input p-comp-fbr-v-fbr-doc-line-recid
            , input v-price-sale-obj-type
            , input v-price-sale-obj-code
            , output v-price-sale
            ) no-error.
         if error-status:error then 
         do:
            message substitute("Ошибка при расчете цен по док-ту&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
               view-as alert-box error .
            undo, return error .
         end.
         if v-price-sale <> ?
            then 
         do:    /* нулевую цену не ставим, чтобы можно было задать вручную */
            assign
               buf_fbr-line.price-sale = v-price-sale
               .
            if v-price-sale-obj-type <> v-cntxt-obj-type
               or v-price-sale-obj-code <> v-cntxt-obj-code
               then 
            do:    /* цена с другого объекта - фиксируем */
               assign
                  buf_fbr-line.is-calc = yes
                  .
            end.
         end.        /* if v-price-sale <> ? */
      /* заново выводим перевычисленное или фиксированное значение */
      end.        /* if p-fbr-doc-status = {&g___new} */
      if p-fbr-doc-status = {&permitted}
         then 
      do:        /* для статуса Разрешен может измениться только учетная цена или ее фиксированность */
         /* нельзя редактировать учетные цены, когда это:
             строка списания.
             учетная цена составного вычисляется через рецепт как сумма
                 цен ингридиентов (много-в-один). Редактирование учетных цен
                 запрещено, кроме пустого рецепта. Для пустого рецепта также
                 возможен вариант производства много-в-один, но он здесь
                 не отслеживается и не запрещается.
             строка с отходами.
         */
         find first buf_recipe no-lock
            where buf_recipe.doc-code      = f-doc.doc-code
            and buf_recipe.recipe-code   = buf_fbr-line.recipe-code
            no-error.
         if buf_fbr-line.trn-type = {&write-off}
            or available buf_recipe
            or buf_fbr-line.rsrv-qnty = ?
            then 
         do:
            assign
               buf_fbr-line.fix-cost = no
               .
         end.      /* редактирование учетных цен НЕ разрешено */
         else 
         do:
            assign
               old-cost-base         = buf_fbr-line.price-base
               old-cost-rubl         = buf_fbr-line.price-rubl
               old-cost-sum-vat-base = buf_fbr-line.price-sum-vat-base
               old-cost-sum-vat-rubl = buf_fbr-line.price-sum-vat-rubl
               browse br-comp
               /* Если отметка снимается, то ничего с ценой не происходит, она не пересчитывается.
               Просто при контроле учетных цен она будет проверяться и не пройдет проверку (скорее всего) */
               buf_comp_fbr-line.fix-cost
               buf_comp_fbr-line.price-rubl
               buf_comp_fbr-line.price-base
               buf_comp_fbr-line.price-sum-vat-rubl
               buf_comp_fbr-line.price-sum-vat-base
               .
            if ( v-base = yes
               and ( buf_fbr-line.price-base <> old-cost-base
               or buf_fbr-line.price-sum-vat-base <> old-cost-sum-vat-base ) )
               or ( v-base = no
               and ( buf_fbr-line.price-rubl <> old-cost-rubl
               or buf_fbr-line.price-sum-vat-rubl <> old-cost-sum-vat-rubl ) )
               then 
            do:        /* изменилась цена - ставим отметку, что она зафиксирована */
               assign
                  buf_fbr-line.fix-cost = yes
                  .
               run cur-time in this-procedure ( output v-today
                  , output v-time
                  ).
               { gbl/baserate.i
                    p-host-code
                    v-today
                    v-base-rate
                    v-base-scale
                    no-error
                }
               if error-status :error
                  then 
               do:
                  message
                     vss-workfile vss-revision vss-description
                     skip 
                     "Ошибка вычисления курса базовой валюты."
                     skip return-value
                     skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
                     view-as alert-box error.
                  undo, return no-apply .
               end.
               if v-base = yes
                  then 
               do:
                  if buf_fbr-line.price-sum-vat-base <> old-cost-sum-vat-base
                     then 
                  do:
                     assign
                        buf_fbr-line.price-sum-vat-rubl = buf_fbr-line.price-sum-vat-base
                                                            * ( if v-base-rate = 0 then 1 else v-base-rate )
                                                            / ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
                  if buf_fbr-line.price-base <> old-cost-base
                     then 
                  do:
                     assign
                        buf_fbr-line.price-rubl = buf_fbr-line.price-base
                                                            * ( if v-base-rate = 0 then 1 else v-base-rate )
                                                            / ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
               end.
               else 
               do:
                  if buf_fbr-line.price-sum-vat-rubl <> old-cost-sum-vat-rubl
                     then 
                  do:
                     assign
                        buf_fbr-line.price-sum-vat-base = buf_fbr-line.price-sum-vat-rubl
                                                            / ( if v-base-rate = 0 then 1 else v-base-rate )
                                                            * ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
                  if buf_fbr-line.price-rubl <> old-cost-rubl
                     then 
                  do:
                     assign
                        buf_fbr-line.price-base = buf_fbr-line.price-rubl
                                                            / ( if v-base-rate = 0 then 1 else v-base-rate )
                                                            * ( if v-base-scale = 0 then 1 else v-base-scale )
                        .
                  end.
               end.
               assign
                  buf_fbr-line.price-sum-rubl = buf_fbr-line.price-rubl * buf_fbr-line.fact-qnty
                  buf_fbr-line.price-sum-base = buf_fbr-line.price-base * buf_fbr-line.fact-qnty
                  buf_fbr-line.rsrv-qnty      = buf_fbr-line.fact-qnty
                  .
            end.
            if buf_comp_fbr-line.price-sum-vat-rubl >= buf_comp_fbr-line.price-sum-rubl
               or buf_comp_fbr-line.price-sum-vat-base >= buf_comp_fbr-line.price-sum-base
               then 
            do:
               assign
                  buf_comp_fbr-line.price-sum-vat-rubl = old-cost-sum-vat-rubl
                  buf_comp_fbr-line.price-sum-vat-base = old-cost-sum-vat-base
                  buf_comp_fbr-line.price-sum-rubl     = old-cost-rubl
                  buf_comp_fbr-line.price-sum-base     = old-cost-base
                  .
               message
                  skip 
                  "Сумма НДС учетных цен не может быть"
                  skip 
                  "больше или равна сумме учетных цен"
                  skip(1)
                  skip 
                  "Введите верные данные."
                  view-as alert-box error.
               undo, return error .
            end.
         end.        /* редактирование учетных цен разрешено */
      end.        /* if p-fbr-doc-status = {&permitted} */
   end.
END PROCEDURE. /* change-current-comp-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-and-correct-fbr-recipe D-FBR-DOC 
PROCEDURE check-and-correct-fbr-recipe :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-fbr-doc-code       as character        no-undo.
   define input parameter p-fbr-recipe-code    as character        no-undo.
   define output parameter p-can-continue      as logical          no-undo.

   define variable v-is-correct as logical no-undo.
   define variable v-yesno      as logical no-undo.
   do
      on error undo, return error
      :
      assign
         p-can-continue = yes
         .
      run fbrlib-check-fbr-recipe in this-procedure (
         input p-fbr-doc-code
         , input p-fbr-recipe-code
         , output v-is-correct
         ).
      if v-is-correct = no
         then 
      do:
         assign
            v-yesno = no
            .
         message
            "Рецепт документа не соответствует строкам документа."
            skip(1)
            "Номер рецепта:" p-fbr-recipe-code
            skip(1)
            skip 
            "Вы можете:"
            skip 
            "    Изменить рецепт документа в соответствии"
            skip 
            "        с введенными значениями количеств ингредиентов."
            skip 
            "    или вернуться к редактированию документа,"
            skip 
            "        чтобы привести строки в соответствие рецепту"
            skip 
            "        кнопками Составной и Ингредиенты"
            skip(1)
            skip 
            "Изменить рецепт документа?"
            view-as alert-box question
            buttons ok-cancel
            title "Изменение рецепта документа"
            update v-yesno.
         if v-yesno = yes
            then 
         do:
            run fbrlib_adjust-recipe in this-procedure (
               input parparentproc
               , input p-fbrhist-handle
               , input p-fbr-doc-code
               , input p-fbr-recipe-code
               , input v-price-sale-obj-type
               , input v-price-sale-obj-code
               ).
         end.
         else 
         do:
            assign
               p-can-continue = no
               .
            undo, return.
         end.
      end.
   end.
END PROCEDURE. /* check-and-correct-fbr-recipe */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE del-proc D-FBR-DOC 
PROCEDURE del-proc :
   /*------------------------------------------------------------------------------
     Purpose:     удаление строки по рецепту и без
   ------------------------------------------------------------------------------*/
   do
      on error undo, return error
      :
      define input parameter p-mode as character no-undo.
      define output parameter p-deleted as logical      no-undo.

      define variable v-rcp-list as character no-undo.        /* номера рецептов для удаления */
      define variable v-count    as integer   no-undo.

      define buffer buf_fbr-line           for ub.fbr-line.
      define buffer buf_del_fbr-line       for ub.fbr-line.
      define buffer buf_del_fbr-recipe     for ub.fbr-recipe.
      define buffer buf_del_fbr-recipe-gds for ub.fbr-recipe-gds.
      
      define buffer buf_goods              for ub.goods .
      define buffer buf_marking            for ub.marking .
      define buffer buf_marking-lines      for ub.marking-lines .

      assign
         p-deleted = no
         .
      case p-mode:
         when "down"
         then 
            do:
               if not available buf_ingr_fbr-line
                  then 
               do:
                  message "Неправильно выбрана строка нижнего списка.".
               end.
               else 
               do:
                  if buf_ingr_fbr-line.recipe-code <> ""
                     then 
                  do:
                     message "Строка нижнего списка может быть удалена только по рецепту.".
                  end.
                  else 
                  do:
                     assign
                        v-fbr-doc-g-log = no
                        .
                     message
                        "Удалить строку нижнего списка?"
                        view-as alert-box question
                        buttons yes-no
                        title "Удаление строки"
                        update v-fbr-doc-g-log.
                     if v-fbr-doc-g-log = yes
                        then 
                     do:
                        assign
                           v-fbr-doc-line-rec = recid( buf_ingr_fbr-line )
                           .
                        get next br-ingr.
                        if available buf_ingr_fbr-line
                           then 
                        do:
                           assign
                              v-fbr-doc-rep-rec = recid( buf_ingr_fbr-line )
                              .
                        end.
                        else 
                        do:
                           reposition br-ingr to recid v-fbr-doc-line-rec no-error.
                           get prev br-ingr.
                           assign
                              v-fbr-doc-rep-rec = recid( buf_ingr_fbr-line )
                              .
                        end.
                        del-ingr:
                        do transaction
                           on stop  undo del-ingr, return no-apply
                           on error undo del-ingr, return no-apply
                           :
                           find first buf_ingr_fbr-line exclusive-lock
                              where recid( buf_ingr_fbr-line ) = v-fbr-doc-line-rec
                              .
                           for first buf_goods no-lock where buf_goods.artic      = buf_ingr_fbr-line.artic
                                                         and buf_goods.prod-type  = buf_ingr_fbr-line.prod-type
                                                         and buf_goods.prod-code  = buf_ingr_fbr-line.prod-code,
                           each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                                   and buf_marking-lines.obj-type = f-doc.obj-type
                                                                   and buf_marking-lines.obj-code = f-doc.obj-code
                                                                   and buf_marking-lines.in-code  = "manufacturing"
                                                                   and buf_marking-lines.out-code = buf_ingr_fbr-line.doc-code
                                                                   and buf_marking-lines.part-code = buf_ingr_fbr-line.recipe-code
                                                                   and buf_marking-lines.prt-code = 0
                           :
                             for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                             end .
                             delete buf_marking-lines.
                           end .
                           delete buf_ingr_fbr-line.
                        end.
                        assign
                           v-fbr-doc-line-rec = recid( buf_comp_fbr-line )
                           p-deleted          = yes
                           .
                     end.        /* v-fbr-doc-g-log = yes */
                  end.        /* buf_ingr_fbr-line.recipe-code = "" */
               end.        /* available buf_ingr_fbr-line */
            end.        /* when "down" */
         when "up"
         then 
            do:
               if not available buf_comp_fbr-line
                  then 
               do:
                  message
                     "Неправильно выбрана строка верхнего списка."
                     view-as alert-box.
               end.
               else 
               do:
                  if buf_comp_fbr-line.recipe-code <> ""
                     then 
                  do:
                     message
                        "Строка верхнего списка может быть удалена только по рецепту."
                        view-as alert-box information
                        title "Удаление строки".
                  end.
                  else 
                  do:
                     assign
                        v-fbr-doc-g-log = no
                        .
                     message
                        "Удалить строку верхнего списка?"
                        view-as alert-box question
                        buttons yes-no
                        title "Удаление строки"
                        update v-fbr-doc-g-log.
                     if v-fbr-doc-g-log = yes
                        then 
                     do:
                        assign
                           v-fbr-doc-line-rec = recid (buf_comp_fbr-line)
                           .
                        get next br-comp.
                        if available buf_comp_fbr-line
                           then 
                        do:
                           assign
                              v-fbr-doc-rep-rec = recid (buf_comp_fbr-line)
                              .
                        end.
                        else 
                        do:
                           reposition br-comp to recid v-fbr-doc-line-rec no-error.
                           get prev br-comp.
                           assign
                              v-fbr-doc-rep-rec = recid (buf_comp_fbr-line)
                              .
                        end.
                        del-comp:
                        do transaction
                           on stop undo del-comp, return no-apply
                           on error undo del-comp, return no-apply
                           :
                           find first buf_comp_fbr-line exclusive-lock
                              where recid (buf_comp_fbr-line) = v-fbr-doc-line-rec
                              .
                           for first buf_goods no-lock where buf_goods.artic      = buf_comp_fbr-line.artic
                                                         and buf_goods.prod-type  = buf_comp_fbr-line.prod-type
                                                         and buf_goods.prod-code  = buf_comp_fbr-line.prod-code,
                           each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                                   and buf_marking-lines.obj-type = f-doc.obj-type
                                                                   and buf_marking-lines.obj-code = f-doc.obj-code
                                                                   and buf_marking-lines.in-code  = "manufacturing"
                                                                   and buf_marking-lines.out-code = buf_comp_fbr-line.doc-code
                                                                   and buf_marking-lines.part-code = buf_comp_fbr-line.recipe-code
                                                                   and buf_marking-lines.prt-code = 0
                           :
                             for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB .
                             end .
                             delete buf_marking-lines.
                           end .
                           delete buf_comp_fbr-line.
                        end.
                        assign
                           v-fbr-doc-line-rec = v-fbr-doc-rep-rec
                           p-deleted          = yes
                           .
                     end.        /* v-fbr-doc-g-log = yes */
                  end.        /* buf_comp_fbr-line.recipe-code = "" */
               end.        /* available buf_comp_fbr-line */
            end.        /* when "up" */
         when "all-doc"
         then 
            do:
               assign
                  v-fbr-doc-g-log = no
                  .
               message
                  "Удалить все строки документа?"
                  view-as alert-box question
                  buttons yes-no
                  update v-fbr-doc-g-log.
               if v-fbr-doc-g-log = yes
                  then 
               do:
                  for each buf_fbr-line no-lock
                     where buf_fbr-line.doc-code      = f-doc.doc-code
                     on error undo, return error
                     :
                     do transaction
                        on error undo, return error
                        :
                        if buf_fbr-line.is-comp = yes
                           then 
                        do:
                           find first buf_del_fbr-recipe exclusive-lock
                              where buf_del_fbr-recipe.doc-code    = f-doc.doc-code
                              and buf_del_fbr-recipe.recipe-code = buf_fbr-line.recipe-code
                              no-error.
                           if available buf_del_fbr-recipe
                              then 
                           do:
                              delete buf_del_fbr-recipe.
                           end.
                        end.
                        else 
                        do:
                           find first buf_del_fbr-recipe-gds exclusive-lock
                              where buf_del_fbr-recipe-gds.doc-code    = f-doc.doc-code
                              and buf_del_fbr-recipe-gds.recipe-code = buf_fbr-line.recipe-code
                              and buf_del_fbr-recipe-gds.prod-type   = buf_fbr-line.prod-type
                              and buf_del_fbr-recipe-gds.prod-code   = buf_fbr-line.prod-code
                              and buf_del_fbr-recipe-gds.artic       = buf_fbr-line.artic
                              no-error.
                           if available buf_del_fbr-recipe-gds
                              then 
                           do:
                              delete buf_del_fbr-recipe-gds.
                           end.
                        end.
                        find first buf_del_fbr-line exclusive-lock
                           where recid( buf_del_fbr-line ) = recid( buf_fbr-line )
                           .
                        for first buf_goods no-lock where buf_goods.artic      = buf_del_fbr-line.artic
                                                      and buf_goods.prod-type  = buf_del_fbr-line.prod-type
                                                      and buf_goods.prod-code  = buf_del_fbr-line.prod-code,
                        each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                                and buf_marking-lines.obj-type = f-doc.obj-type
                                                                and buf_marking-lines.obj-code = f-doc.obj-code
                                                                and buf_marking-lines.in-code  = "manufacturing"
                                                                and buf_marking-lines.out-code = buf_del_fbr-line.doc-code
                                                                and buf_marking-lines.part-code = buf_del_fbr-line.recipe-code
                                                                and buf_marking-lines.prt-code = 0
                        :
                          for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                             assign
                               buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB when not buf_del_fbr-line.is-comp
                               buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB when buf_del_fbr-line.is-comp
                             .
                          end .
                          delete buf_marking-lines.
                        end .
                        delete buf_del_fbr-line.
                     end.        /* do transaction */
                  end.
                  assign
                     p-deleted = yes
                     .
               end.
            end.
         when "rcp"
         or 
         when "all"
         then 
            do:
               if not available buf_comp_fbr-line
                  then 
               do:
                  message "Неправильно выбрана строка документа (из верхнего списка).".
               end.
               else 
               do:
                  assign
                     v-fbr-doc-g-log = no
                     .
                  if p-mode = "rcp"
                     then 
                  do:
                     message
                        "Удалить все строки документа, соответствующие текущему рецепту?"
                        view-as alert-box question
                        buttons yes-no
                        update v-fbr-doc-g-log.
                  end.
                  else 
                  do:
                     message
                        "Удалить строки документа, соответствующие текущему рецепту, а также рецептам для ингредиентов?"
                        view-as alert-box question
                        buttons yes-no
                        update v-fbr-doc-g-log.
                  end.
                  if v-fbr-doc-g-log = yes
                     then 
                  do:
                     assign
                        v-rcp-list         = buf_comp_fbr-line.recipe-code
                        v-fbr-doc-line-rec = recid (buf_comp_fbr-line)
                        v-fbr-doc-rep-rec  = ?
                        .
                     get next br-comp .
                     if available buf_comp_fbr-line then 
                     do :
                        v-fbr-doc-line-rec = recid (buf_comp_fbr-line) .
                        get prev br-comp .
                     end.   
                     if p-mode = "all"
                        then 
                     do:
                        run fill-del-list in this-procedure (
                           input buf_comp_fbr-line.recipe-code
                           , output v-rcp-list
                           ).
                     end.
                     do v-count = 1 to num-entries( v-rcp-list )
                        :
                        for each buf_fbr-line no-lock
                           where buf_fbr-line.doc-code      = f-doc.doc-code
                           and buf_fbr-line.recipe-code   = entry( v-count, v-rcp-list )
                           on error undo, return error
                           :
                           do transaction
                              on error undo, return error
                              :
                              if buf_fbr-line.is-comp = yes
                                 then 
                              do:
                                 find first buf_del_fbr-recipe exclusive-lock
                                    where buf_del_fbr-recipe.doc-code    = f-doc.doc-code
                                    and buf_del_fbr-recipe.recipe-code = buf_fbr-line.recipe-code
                                    no-error.
                                 if available buf_del_fbr-recipe
                                    then 
                                 do:
                                    delete buf_del_fbr-recipe.
                                 end.
                              end.
                              else 
                              do:
                                 find first buf_del_fbr-recipe-gds exclusive-lock
                                    where buf_del_fbr-recipe-gds.doc-code    = f-doc.doc-code
                                    and buf_del_fbr-recipe-gds.recipe-code = buf_fbr-line.recipe-code
                                    and buf_del_fbr-recipe-gds.prod-type   = buf_fbr-line.prod-type
                                    and buf_del_fbr-recipe-gds.prod-code   = buf_fbr-line.prod-code
                                    and buf_del_fbr-recipe-gds.artic       = buf_fbr-line.artic
                                    no-error.
                                 if available buf_del_fbr-recipe-gds
                                    then 
                                 do:
                                    delete buf_del_fbr-recipe-gds.
                                 end.
                              end.
                              find first buf_del_fbr-line exclusive-lock
                                 where recid( buf_del_fbr-line ) = recid( buf_fbr-line )
                                 .
                              for first buf_goods no-lock where buf_goods.artic      = buf_del_fbr-line.artic
                                                            and buf_goods.prod-type  = buf_del_fbr-line.prod-type
                                                            and buf_goods.prod-code  = buf_del_fbr-line.prod-code,
                              each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = buf_goods.gds-code
                                                                      and buf_marking-lines.obj-type = f-doc.obj-type
                                                                      and buf_marking-lines.obj-code = f-doc.obj-code
                                                                      and buf_marking-lines.in-code  = "manufacturing"
                                                                      and buf_marking-lines.out-code = buf_del_fbr-line.doc-code
                                                                      and buf_marking-lines.part-code = buf_del_fbr-line.recipe-code
                                                                      and buf_marking-lines.prt-code = 0
                              :
                                for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                                   assign
                                     buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB when not buf_del_fbr-line.is-comp
                                     buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UsedInProduction:KeyIntDB when buf_del_fbr-line.is-comp
                                   .
                                end .
                                delete buf_marking-lines.
                              end .
                              delete buf_del_fbr-line.
                           end.        /* do transaction */
                        end.
                     end.
                     assign
                        /*                    v-fbr-doc-line-rec = v-fbr-doc-rep-rec*/
                        p-deleted = yes
                        .
                  end.        /* v-fbr-doc-g-log = yes */
               end.        /* available buf_comp_fbr-line */
            end.        /* when "rcp" or when "all" */
      end case.

   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-FBR-DOC  _DEFAULT-DISABLE
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
   HIDE FRAME D-FBR-DOC.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-del-list D-FBR-DOC 
PROCEDURE fill-del-list :
   define input parameter r-code       like ub.fbr-recipe.recipe-code no-undo.
   define output parameter p-rcp-list  as character    no-undo.

   define buffer buf_ingr_fbr-line for ub.fbr-line.
   define buffer buf_comp_fbr-line for ub.fbr-line.

   assign
      p-rcp-list = string( r-code )
      .
   for each buf_ingr_fbr-line no-lock
      where buf_ingr_fbr-line.doc-code = f-doc.doc-code
      and buf_ingr_fbr-line.is-comp = no
      and buf_ingr_fbr-line.recipe-code = r-code
      :
      for each buf_comp_fbr-line no-lock
         where buf_comp_fbr-line.doc-code = buf_ingr_fbr-line.doc-code
         and buf_comp_fbr-line.is-comp = yes
         and buf_comp_fbr-line.artic = buf_ingr_fbr-line.artic
         and buf_comp_fbr-line.prod-type = buf_ingr_fbr-line.prod-type
         and buf_comp_fbr-line.prod-code = buf_ingr_fbr-line.prod-code
         :
         assign
            p-rcp-list = p-rcp-list + "," + buf_comp_fbr-line.recipe-code
            .
      end.
   end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-recipe-fields D-FBR-DOC 
PROCEDURE fill-recipe-fields :
   do
      on error undo, return error
      :
      define input parameter p-recipe-code as character    no-undo.

      define buffer buf_recipe for ub.fbr-recipe.

      find first buf_recipe no-lock
         where buf_recipe.doc-code = f-doc.doc-code
         and buf_recipe.recipe-code = p-recipe-code
         no-error.
      if available buf_recipe
         then 
      do:
         display
            buf_recipe.recipe-code  @ ub.fbr-recipe.recipe-code
            buf_recipe.recipe-name  @ ub.fbr-recipe.recipe-name
            buf_recipe.recipe-type  @ ub.fbr-recipe.recipe-type
            buf_recipe.qnty         @ ub.fbr-recipe.qnty
            with frame {&frame-name}.
      end.
      else 
      do:
         display
            "" @ ub.fbr-recipe.recipe-code
            "" @ ub.fbr-recipe.recipe-name
            "" @ ub.fbr-recipe.recipe-type
            "" @ ub.fbr-recipe.qnty
            with frame {&frame-name}.
      end.
   end.
END PROCEDURE. /* fill-recipe-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-current-goods-recid D-FBR-DOC 
PROCEDURE get-current-goods-recid :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define output parameter p-gds-rec as recid            no-undo.
   do
      on error undo, return error
      :
      define buffer buf_goods for ub.goods.

      if current-browse = br-ingr :handle in frame {&frame-name}
         or not available( buf_comp_fbr-line )
         then 
      do:
         find first buf_goods no-lock
            where buf_goods.artic     = buf_ingr_fbr-line.artic
            and buf_goods.prod-type = buf_ingr_fbr-line.prod-type
            and buf_goods.prod-code = buf_ingr_fbr-line.prod-code
            no-error.
      end.
      else 
      do:
         find first buf_goods no-lock
            where buf_goods.artic     = buf_comp_fbr-line.artic
            and buf_goods.prod-type = buf_comp_fbr-line.prod-type
            and buf_goods.prod-code = buf_comp_fbr-line.prod-code
            no-error.
      end.
      if available buf_goods
         then 
      do:
         assign
            p-gds-rec = recid( buf_goods )
            .
      end.
      else 
      do:
         assign
            p-gds-rec = ?
            .
      end.
   end.
END PROCEDURE. /* get-current-goods-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-effect D-FBR-DOC 
PROCEDURE get-effect :
   do
      on error undo, return error
      :
      define input parameter p-recipe-code    as character    no-undo.
      define input parameter p-doc-code       as character    no-undo.
      define output parameter p-effect        as decimal      no-undo.

      define variable v-sum-cost-rubl as decimal no-undo.
      define variable v-sum-cost-base as decimal no-undo.
      define variable v-sum-sale      as decimal no-undo.

      define buffer buf_fbr-line for ub.fbr-line.

      assign
         v-sum-cost-rubl = 0
         v-sum-cost-base = 0
         v-sum-sale      = 0
         .
      for each buf_fbr-line no-lock
         where buf_fbr-line.recipe-code   = p-recipe-code
         and buf_fbr-line.doc-code      = p-doc-code
         and buf_fbr-line.rsrv-qnty     <> ?                /* отходы не считаем */
         :
         if buf_fbr-line.trn-type = {&write-off}
            then 
         do:        /* учетные цены */
            assign
               v-sum-cost-rubl = v-sum-cost-rubl + buf_fbr-line.price-sum-rubl + buf_fbr-line.price-sum-vat-rubl
               v-sum-cost-base = v-sum-cost-base + buf_fbr-line.price-sum-base + buf_fbr-line.price-sum-vat-base
               .
         end.
         else 
         do:        /* цены продажи */
            assign
               v-sum-sale = v-sum-sale      + ( buf_fbr-line.fact-qnty * buf_fbr-line.price-sale )
               .
         end.
      end.
      if v-base = yes
         then 
      do:
         assign
            p-effect = ( v-sum-sale - v-sum-cost-base ) / v-sum-cost-base * 100.
         .
      end.
      else 
      do:
         assign
            p-effect = ( v-sum-sale - v-sum-cost-rubl ) / v-sum-cost-rubl * 100.
         .
      end.

   end.
END PROCEDURE. /* get-effect */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-goods-name-proc D-FBR-DOC 
PROCEDURE get-goods-name-proc :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-gds-name          as character        no-undo.

   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then 
      do:
         { gbl/gds-arnm.i
            buf_fbr-line.artic
            buf_fbr-line.prod-type
            buf_fbr-line.prod-code
            p-gds-name
            no-error
        }
         if error-status :error
            then 
         do:
            assign
               p-gds-name = "":U
               .
         end.
      end.
      else 
      do:
         assign
            p-gds-name = "":U
            .
      end.
   end.
END PROCEDURE. /* get-goods-name-proc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-goods-recid D-FBR-DOC 
PROCEDURE get-goods-recid :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define buffer buf_goods for ub.goods.
   do
      for buf_goods
      with frame {&frame-name}
      on error undo, return error
      :
      case current-browse
         :
         when br-comp :handle
         then 
            do:
               if available buf_comp_fbr-line
                  then 
               do:
                  find first buf_goods no-lock
                     where buf_goods.artic     = buf_comp_fbr-line.artic
                     and buf_goods.prod-type = buf_comp_fbr-line.prod-type
                     and buf_goods.prod-code = buf_comp_fbr-line.prod-code
                     no-error.
                  if available buf_goods
                     then 
                  do:
                     assign
                        gds-rec = recid( buf_goods )
                        .
                  end.
               end.
            end.        /* when br-comp :handle */
         when br-ingr :handle
         then 
            do:
               if available buf_ingr_fbr-line
                  then 
               do:
                  find first buf_goods no-lock
                     where buf_goods.artic     = buf_ingr_fbr-line.artic
                     and buf_goods.prod-type = buf_ingr_fbr-line.prod-type
                     and buf_goods.prod-code = buf_ingr_fbr-line.prod-code
                     no-error.
                  if available buf_goods
                     then 
                  do:
                     assign
                        gds-rec = recid( buf_goods )
                        .
                  end.
               end.
            end.        /* when br-ingr :handle */
      end case.       /* case current-browse */
   end.
END PROCEDURE. /* get-goods-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-ingr-line-parameters D-FBR-DOC 
PROCEDURE get-ingr-line-parameters :
   define input parameter p-recipe-code            as character        no-undo.
   define input parameter p-artic                  as character        no-undo.
   define input parameter p-prod-type              as character        no-undo.
   define input parameter p-prod-code              as integer          no-undo.
   define output parameter p-gds-name              as character        no-undo.
   define output parameter p-gds-type              as character        no-undo.
   define output parameter p-recipe-type           as character        no-undo.
   define output parameter p-recipe-qnty           as decimal          no-undo.
   define output parameter p-recipe-brutto-qnty    as decimal          no-undo.
   define output parameter p-recipe-coeff-value    as decimal          no-undo.
   define output parameter p-recipe-coeff-waste    as decimal          no-undo.
   define output parameter p-recipe-waste          as logical          no-undo.

   define buffer buf_goods      for ub.goods.
   define buffer buf_recipe     for ub.recipe.
   define buffer buf_recipe-gds for ub.fbr-recipe-gds.
   do
      for buf_goods
      , buf_recipe
      , buf_recipe-gds
      on error undo, return error
      :
      find first buf_goods no-lock
         where buf_goods.artic      = p-artic
         and buf_goods.prod-type  = p-prod-type
         and buf_goods.prod-code  = p-prod-code
         no-error.
      assign
         p-gds-name = ( if available buf_goods then buf_goods.gds-name else "":U )
         p-gds-type = ( if available buf_goods
                     then ( if buf_goods.gds-type = {&gds-goods} then "" else {&gds-office} )
                     else "":U
                     )
         .
      find first buf_recipe-gds no-lock
         where buf_recipe-gds.doc-code     = f-doc.doc-code
         and buf_recipe-gds.recipe-code  = p-recipe-code
         and buf_recipe-gds.artic        = p-artic
         and buf_recipe-gds.prod-type    = p-prod-type
         and buf_recipe-gds.prod-code    = p-prod-code
         no-error.
      if available buf_recipe-gds
         then 
      do:
         assign
            p-recipe-qnty        = buf_recipe-gds.qnty
            p-recipe-brutto-qnty = buf_recipe-gds.brutto-qnty
            p-recipe-coeff-value = buf_recipe-gds.coeff-value
            p-recipe-coeff-waste = buf_recipe-gds.coeff-waste
            p-recipe-waste       = buf_recipe-gds.is-waste
            .
      end.
      else 
      do:
         assign
            p-recipe-qnty        = ?
            p-recipe-brutto-qnty = ?
            p-recipe-coeff-value = ?
            p-recipe-coeff-waste = ?
            p-recipe-waste       = no
            .
      end.
      find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
         no-error.
      if available buf_recipe
         then 
      do:
         assign
            p-recipe-type = buf_recipe.recipe-type
            .
      end.
   end.
END PROCEDURE. /* get-ingr-line-parameters */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-line-OK-proc D-FBR-DOC 
PROCEDURE get-line-OK-proc :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-line-ok           as logical          no-undo.

   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then 
      do:
         assign
            p-line-ok = ( buf_fbr-line.fact-qnty = buf_fbr-line.rsrv-qnty
                       or buf_fbr-line.rsrv-qnty = ? )
            .
      end.
      else 
      do:
         assign
            p-line-ok = no
            .
      end.
   end.
END PROCEDURE. /* get-line-OK-proc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-netto-qnty-proc D-FBR-DOC 
PROCEDURE get-netto-qnty-proc :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-netto-qnty        as decimal          no-undo.

   define variable v-void-decimal as decimal   no-undo.
   define variable v-void-integer as integer   no-undo.
   define variable v-recipe-type  as character no-undo.

   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then 
      do:
         run fbrlib-get-recipe-type in this-procedure (
            input buf_fbr-line.doc-code
            , input buf_fbr-line.recipe-code
            , output v-recipe-type
            ).
         run fbrlib-calc-brutto in this-procedure (
            input v-recipe-type
            , input 0
            , input buf_fbr-line.coeff-value
            , input buf_fbr-line.coeff-waste
            , input buf_fbr-line.fact-qnty
            , input 1
            , output p-netto-qnty
            , output v-void-decimal
            , output v-void-decimal
            , output v-void-integer
            ) NO-ERROR.
         if error-status :error
            then 
         do:
            assign
               p-netto-qnty = 0.0
               .
         end.
      end.
      else 
      do:
         assign
            p-netto-qnty = 0.0
            .
      end.
   end.
END PROCEDURE. /* get-netto-qnty-proc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-pay-name D-FBR-DOC 
PROCEDURE get-pay-name :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-pay-code   as integer          no-undo.
   define output parameter p-pay-name  as character        no-undo.

   define buffer buf_pay-type for ub.pay-type.
   do
      for buf_pay-type
      on error undo, return error
      :
      find first buf_pay-type no-lock
         where buf_pay-type.obj-code = p-pay-code
         no-error.
      if available buf_pay-type
         then 
      do:
         assign
            p-pay-name = buf_pay-type.obj-name
            .
      end.
      else 
      do:
         assign
            p-pay-name = "":U
            .
      end.
   end.
END PROCEDURE. /* get-pay-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-pay-type-name D-FBR-DOC 
PROCEDURE get-pay-type-name :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-pay-code       as integer          no-undo.
   define output parameter p-pay-type-name as character        no-undo.

   define buffer buf_pay-type for ub.pay-type.
   do
      on error undo, return error
      :
      find first buf_pay-type no-lock
         where buf_pay-type.obj-code = p-pay-code
         no-error.
      if available buf_pay-type
         then 
      do:
         assign
            p-pay-type-name = buf_pay-type.obj-name
            .
      end.
      else 
      do:
         assign
            p-pay-type-name = "":U
            .
      end.
   end.
END PROCEDURE. /* get-pay-type-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-prod-ref-proc D-FBR-DOC 
PROCEDURE get-prod-ref-proc :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-prod-string       as character        no-undo.

   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then 
      do:
         assign
            p-prod-string = buf_fbr-line.prod-type + " " + string ( buf_fbr-line.prod-code )
            .
         if error-status :error
            then 
         do:
            assign
               p-prod-string = "":U
               .
         end.
      end.
      else 
      do:
         assign
            p-prod-string = "":U
            .
      end.
   end.
END PROCEDURE. /* get-prod-ref-proc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-unit-base-proc D-FBR-DOC 
PROCEDURE get-unit-base-proc :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-fbr-line-recid     as recid            no-undo.
   define output parameter p-unit-base         as character        no-undo.

   define variable v-gds-code as integer no-undo.

   define buffer buf_fbr-line for ub.fbr-line.
   do
      for buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-fbr-line-recid
         no-error.
      if available buf_fbr-line
         then 
      do:
         { gbl/gds-code.i
            buf_fbr-line.artic
            buf_fbr-line.prod-type
            buf_fbr-line.prod-code
            v-gds-code
            no-error
        }
         if error-status :error
            then 
         do:
            assign
               p-unit-base = "":U
               .
         end.
         else 
         do:
            { gbl/unitbase.i
                v-gds-code
                p-unit-base
                no-error
            }
            if error-status :error
               then 
            do:
               assign
                  p-unit-base = "":U
                  .
            end.
         end.
      end.
      else 
      do:
         assign
            p-unit-base = "":U
            .
      end.
   end.
END PROCEDURE. /* get-unit-base-proc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-not-avail-menu-items D-FBR-DOC 
PROCEDURE hide-not-avail-menu-items :
   do
      on error undo, return error
      :
      define input parameter p-fbr-doc-is-free as logical      no-undo.

      case p-fbr-doc-is-free
         :
         when yes
         then 
            do:
               assign
                  menu-item m-rcp-add :sensitive in menu m-add = no
                  menu-item m-all-add :sensitive in menu m-add = no
                  menu-item m-rcp-del :sensitive in menu m-del = no
                  menu-item m-all-del :sensitive in menu m-del = no
                  .
            end.
         when no
         then 
            do:
               assign
                  menu-item m-comp-add :sensitive in menu m-add = no
                  menu-item m-ingr-add :sensitive in menu m-add = no
                  menu-item m-comp-del :sensitive in menu m-del = no
                  menu-item m-ingr-del :sensitive in menu m-del = no
                  .
            end.
      end case.

   end.
END PROCEDURE. /* hide-not-avail-menu-items */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mode-on D-FBR-DOC 
PROCEDURE mode-on :
   do
      on error undo, return error
      :

      case p-doc-mode :
         when {&add-def} then 
            do:
               define variable v-doc-code as character no-undo.
               run fbrlib_create-fbr-doc ( input v-cntxt-obj-type
                  , input  v-cntxt-obj-code
                  ,input v-cntxt-userid
                  , output v-doc-code
                  ,output p-fbr-doc-recid) no-error.
               if error-status:error then 
               do:
                  undo, return error substitute("Ошибка при создании нового документа производства:&1&2&1&3"
                     , {&new-line}
                     , error-status:get-message(1)
                     , return-value ).
               end.
               assign
                  p-new-fbr-doc-recid = p-fbr-doc-recid
                  .
               find first f-doc exclusive-lock where
                  recid(f-doc) = p-fbr-doc-recid no-error.
               fi-pay-code = f-doc.pay-code.
            end.
         when {&update} then 
            do:
               find first f-doc
                  where recid (f-doc) = p-fbr-doc-recid
                  no-error.
               if available f-doc
                  then 
               do:
                  find first f-doc exclusive-lock
                     where recid (f-doc) = p-fbr-doc-recid no-error
                     .
               end.
            end.
      end case.
      if not available f-doc
         then 
      do:
         message
            "Неправильно выбран документ."
            view-as alert-box error.
         undo, return error.
      end.

   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-comp D-FBR-DOC 
PROCEDURE open-comp :
   /*------------------------------------------------------------------------------
     Purpose: reopen query br-comp
   ------------------------------------------------------------------------------*/
   define variable comp-sort-column-phrase as character no-undo .
   define variable filter-point            as character no-undo init "buf_comp_fbr-line" .
/* определяем здесь общие параметры для процедуры открытия query fltopend.i */

&scoped-define flt-open-open-query open query br-comp for each buf_comp_fbr-line no-lock
&scoped-define flt-open-query-handle query br-comp:handle
&scoped-define flt-open-dyn_open-query for each buf_comp_fbr-line

&scoped-define flt-open-query-was-opened l-query-was-opened
&scoped-define flt-open-query-was-opened

&scoped-define flt-open-sort-column-phrase comp-sort-column-phrase

&scoped-define flt-open-call-point filter-point

&scoped-define flt-open-set-filter-name

&scoped-define flt-open-indexed-reposition indexed-reposition

&scoped-define flt-open-debug-file

   case comp-sort-column-name :
      when ""
      then 
         do:
            assign
               comp-sort-column-phrase = ""
               .
         end.
      when "comp-unit"
      then 
         do:
            assign
               comp-sort-column-phrase = "by (recid(buf_comp_fbr-line))"
               .
         end.
      when "comp-name"
      then 
         do:
            assign
               comp-sort-column-phrase = "by get-goods-name(recid(buf_comp_fbr-line))"
               .
         end.
      when "comp-OK"
      then 
         do:
            assign
               comp-sort-column-phrase = "by get-line-OK(recid(buf_comp_fbr-line))"
               .
         end.
      when "comp-prod"
      then 
         do:
            assign
               comp-sort-column-phrase = "by get-prod-ref(recid(buf_comp_fbr-line))"
               .
         end.
      otherwise 
      do:
         assign
            comp-sort-column-phrase = "by " + comp-sort-column-name
            .
      end.
   end case.

   case rs-one-all :
      when "type"
      then 
         do:
            { gbl/fltopend.i
            &where-cond = "buf_comp_fbr-line.doc-code = f-doc.doc-code and ~
                            buf_comp_fbr-line.trn-type = {&income} "
            &dyn_where-cond = " substitute('buf_comp_fbr-line.doc-code = &1&2&1 and buf_comp_fbr-line.trn-type = &1&3&1', {&double-quote}, f-doc.doc-code, {&income} ) "
            &use-ind = " "
            &by = " "
        }
         end.
      when "goods" then 
         do:
            { gbl/fltopend.i
            &where-cond = "buf_comp_fbr-line.doc-code = f-doc.doc-code and ~
                            buf_comp_fbr-line.is-comp = yes and ~
                            buf_comp_fbr-line.artic = flt-gds.artic and ~
                            buf_comp_fbr-line.prod-type = flt-gds.prod-type and ~
                            buf_comp_fbr-line.prod-code = flt-gds.prod-code "
            &dyn_where-cond = " substitute('buf_comp_fbr-line.doc-code = &1&2&1 and ~
                            buf_comp_fbr-line.is-comp = yes and ~
                            buf_comp_fbr-line.artic = &1&3&1 and ~
                            buf_comp_fbr-line.prod-type = &1&4&1 and ~
                            buf_comp_fbr-line.prod-code = &5' ~
                            , {&double-quote}, f-doc.doc-code, flt-gds.artic, flt-gds.prod-type, flt-gds.prod-code)"
            &use-ind = " "
            &by = " "
        }
         end.
      otherwise 
      do:   /* recipe, all */
         { gbl/fltopend.i
            &where-cond = "buf_comp_fbr-line.doc-code = f-doc.doc-code and ~
                            buf_comp_fbr-line.is-comp = yes "
            &dyn_where-cond = " substitute('buf_comp_fbr-line.doc-code = &1&2&1 and ~
                            buf_comp_fbr-line.is-comp = yes', {&double-quote}, f-doc.doc-code )"
            &use-ind = " "
            &by = " "
        }
      end.
   end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-ingr D-FBR-DOC 
PROCEDURE open-ingr :
   /*------------------------------------------------------------------------------
     Purpose: reopen query br-ingr
   ------------------------------------------------------------------------------*/
   define input parameter cur-recipe-code  as character no-undo.

   define variable ingr-sort-column-phrase as character no-undo .
   define variable filter-point            as character no-undo init "buf_ingr_fbr-line" .

/* определяем здесь общие параметры для процедуры открытия query fltopend.i */

&scoped-define flt-open-open-query open query br-ingr for each buf_ingr_fbr-line no-lock
&scoped-define flt-open-query-handle query br-ingr:handle
&scoped-define flt-open-dyn_open-query for each buf_ingr_fbr-line no-lock

&scoped-define flt-open-query-was-opened l-query-was-opened
&scoped-define flt-open-query-was-opened

&scoped-define flt-open-sort-column-phrase ingr-sort-column-phrase

&scoped-define flt-open-call-point filter-point

&scoped-define flt-open-set-filter-name

&scoped-define flt-open-indexed-reposition indexed-reposition

&scoped-define flt-open-debug-file

   case ingr-sort-column-name :
      when ""
      then 
         do:
            assign
               ingr-sort-column-phrase = ""
               .
         end.
      when "ingr-unit"
      then 
         do:
            assign
               ingr-sort-column-phrase = "by (recid(buf_ingr_fbr-line))"
               .
         end.
      when "ingr-name"
      then 
         do:
            assign
               ingr-sort-column-phrase = "by get-goods-name(recid(buf_ingr_fbr-line))"
               .
         end.
      when "ingr-OK"
      then 
         do:
            assign
               ingr-sort-column-phrase = "by get-line-OK(recid(buf_ingr_fbr-line))"
               .
         end.
      when "ingr-prod"
      then 
         do:
            assign
               ingr-sort-column-phrase = "by get-prod-ref(recid(buf_ingr_fbr-line))"
               .
         end.
      otherwise 
      do:
         assign
            ingr-sort-column-phrase = "by " + ingr-sort-column-name
            .
      end.
   end case.
   case rs-one-all :
      when "type"
      then 
         do:
            open query br-ingr for each buf_ingr_fbr-line no-lock
               where buf_ingr_fbr-line.trn-type = {&write-off}
               and buf_ingr_fbr-line.doc-code = f-doc.doc-code
               .
            { gbl/fltopend.i
            &where-cond = "buf_ingr_fbr-line.doc-code = f-doc.doc-code and ~
                            buf_ingr_fbr-line.trn-type = {&write-off} "
            &dyn_where-cond = " substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and ~
                            buf_ingr_fbr-line.trn-type = &1&3&1', {&double-quote}, f-doc.doc-code, {&write-off} )"
            &use-ind = " "
            &by = " "
        }
         end.
      when "goods"
      then 
         do:
            { gbl/fltopend.i
            &where-cond = "buf_ingr_fbr-line.doc-code = f-doc.doc-code and ~
                            buf_ingr_fbr-line.is-comp = no and ~
                            buf_ingr_fbr-line.artic = flt-gds.artic and ~
                            buf_ingr_fbr-line.prod-type = flt-gds.prod-type and ~
                            buf_ingr_fbr-line.prod-code = flt-gds.prod-code"
            &dyn_where-cond = " substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and ~
                            buf_ingr_fbr-line.is-comp = no and ~
                            buf_ingr_fbr-line.artic = &1&3&1 and ~
                            buf_ingr_fbr-line.prod-type = &1&4&1 and ~
                            buf_ingr_fbr-line.prod-code = &5'~
                            , {&double-quote}, f-doc.doc-code, flt-gds.artic, flt-gds.prod-type, flt-gds.prod-code )"
            &use-ind = " "
            &by = " "
        }
         end.
      when "recipe"
      then 
         do:
            if can-find (first ub.fbr-line where ub.fbr-line.is-comp = yes
               and ub.fbr-line.doc-code = f-doc.doc-code no-lock)
               then 
            do:    /* верхний браус не пуст - нижний по рецепту будет работать правильно */
               if available buf_comp_fbr-line
                  then 
               do:
                  { gbl/fltopend.i
                    &where-cond = "buf_ingr_fbr-line.doc-code = f-doc.doc-code and ~
                                    buf_ingr_fbr-line.is-comp = no and ~
                                    buf_ingr_fbr-line.recipe-code = cur-recipe-code "
                    &dyn_where-cond = " substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and ~
                                    buf_ingr_fbr-line.is-comp = no and ~
                                    buf_ingr_fbr-line.recipe-code = &1&3&1'~
                                    , {&double-quote}, f-doc.doc-code, cur-recipe-code )"
                    &use-ind = " "
                    &by = " "
                }
               end.
               else 
               do:
                  message
                     "Недоступна запись составного товара."
                     view-as alert-box error.
               end.
            end.
            else 
            do:
               /* верхний браус пуст - нижний может работать только для строк без рецепта */
               { gbl/fltopend.i
            &where-cond = "buf_ingr_fbr-line.doc-code = f-doc.doc-code and ~
                        buf_ingr_fbr-line.is-comp = no and ~
                        buf_ingr_fbr-line.recipe-code = '' "
            &dyn_where-cond = " substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and ~
                        buf_ingr_fbr-line.is-comp = no and ~
                        buf_ingr_fbr-line.recipe-code = &1&3&1'~
                        , {&double-quote}, f-doc.doc-code, '':U)"
            &use-ind = " "
            &by = " "
        }
            end.
         end.
      when "all"
      then 
         do:
            { gbl/fltopend.i
            &where-cond = "buf_ingr_fbr-line.doc-code = f-doc.doc-code and ~
                            buf_ingr_fbr-line.is-comp = no "
            &dyn_where-cond = " substitute('buf_ingr_fbr-line.doc-code = &1&2&1 and ~
                            buf_ingr_fbr-line.is-comp = no' ~
                            , {&double-quote}, f-doc.doc-code )"
            &use-ind = " "
            &by = " "
        }
         end.
      otherwise 
      do:
         message
            "Неизвестный режим:" rs-one-all
            view-as alert-box error.
      end.
   end case.
   apply "value-changed" to br-ingr in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-parts D-FBR-DOC 
PROCEDURE process-parts :
   do
      on error undo, return error
      :
      define input parameter p-doc-code       as character    no-undo.
      define input parameter p-trn-type       as character    no-undo.
      define input parameter p-recipe-code    as character    no-undo.
      define input parameter p-artic          as character    no-undo.
      define input parameter p-prod-type      as character    no-undo.
      define input parameter p-prod-code      as integer      no-undo.

      define variable v-gds-code    as integer   no-undo .
      define variable v-parts-recid as recid     no-undo.
      define variable v-status      as character no-undo.
      define variable v-doc-qnty    as decimal   no-undo.

      define variable v-void        as decimal   no-undo.
      define variable v-sum-base    as decimal   no-undo.
      define variable v-sum-rubl    as decimal   no-undo.
      define variable v-vat-base    as decimal   no-undo.
      define variable v-vat-rubl    as decimal   no-undo.

      define buffer buf_doc-line for ub.doc-line.
      define buffer buf_trn-doc  for ub.trn-doc.
      define buffer buf_fbr-line for ub.fbr-line.
      define buffer buf_fbr-doc  for ub.fbr-doc.

      { gbl/working.i }
      { gbl/gds-code.i
        p-artic
        p-prod-type
        p-prod-code
        v-gds-code
    }
      do transaction
         on error undo, return error
         :
         find first buf_fbr-doc no-lock
            where buf_fbr-doc.doc-code = p-doc-code
            .
         find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = p-doc-code
            .
         find first buf_doc-line exclusive-lock
            where buf_doc-line.doc-code    = buf_trn-doc.doc-code
            and buf_doc-line.artic       = p-artic
            and buf_doc-line.prod-type   = p-prod-type
            and buf_doc-line.prod-code   = p-prod-code
            no-error.
         if not available buf_doc-line
            then 
         do:
            message
               "При списании товара по выбранной строке документа производства"
               skip 
               "не была создана соответствующая строка в складском документе списания."
               skip(1)
               skip 
               "Просмотр партий невозможен."
               view-as alert-box warning.
            undo, return error.
         end.
         assign
            v-doc-qnty          = buf_doc-line.doc-qnty
            v-status            = buf_trn-doc.status_
            buf_trn-doc.status_ = {&wayb}
            .
         run str/parts-l.w (
            input parparentproc
            , input f-doc.obj-type              /* v-obj-type   */
            , input f-doc.obj-code              /* v-obj-code   */
            , input v-gds-code                  /* p-gds-code   */
            , input p-doc-code                  /* p-doc-code   */
            , input ( if p-doc-mode = {&lookup} /* p-edit-mode  */
            then {&lookup}
            else {&update}
            )
            , input {&parts-l_parts-document}
            , input {&parts-l_object-current} /* p-one-all    */
            , input {&parts-l_call-document}  /* p-call-point */
            , output v-parts-recid            /* part-recid   */
            ) no-error.
         if error-status :error
            then 
         do:
            if error-status :get-message(1) <> ""
               then 
            do:
               message
                  vss-workfile vss-revision vss-description
                  skip 
                  "Ошибка при вызове интерфейса работы с партиями товара."
                  skip return-value
                  skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
                  view-as alert-box error.
               undo, return error .
            end.
         end.
         { gbl/working.i }
         find current buf_doc-line exclusive-lock.
         if buf_doc-line.doc-qnty <> v-doc-qnty
            then 
         do:
            message
               "При изменении количества по партиям списанного товара"
               skip 
               "было изменено общее количество товара в документе."
               skip(1)
               skip 
               "Произвести такое изменение количеств по партиям невозможно."
               skip 
               "Операция будет отменена."
               view-as alert-box error.
            undo, return error.
         end.
         assign
            buf_trn-doc.status_ = v-status
            .
         run str/fbrclcln.p (
            input buf_doc-line.doc-code
            , input p-doc-code
            , input p-trn-type
            , input p-recipe-code
            , input p-artic
            , input p-prod-type
            , input p-prod-code
            , input buf_fbr-doc.is-free
            ) no-error .
         if error-status:error then 
         do:
            undo, return error substitute("Ошибка при расчете строки (&5 &6&7) для документа производства &1&2&3&2&4"
               , buf_doc-line.doc-code
               , {&new-line}
               , error-status:get-message(1)
               , return-value
               , p-artic
               , p-prod-type
               , p-prod-code
               ).
         end.
      end.        /* do transaction */
      apply "entry" to br-ingr in frame {&frame-name}.
      { gbl/stopwork.i }
   end.
END PROCEDURE. /* process-parts */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-fbroperator D-FBR-DOC 
PROCEDURE select-fbroperator :
   define output parameter p-obj-fbroperator   as character        no-undo.

   define variable v-fbroperator       as integer no-undo.
   define variable v-clients-recid-int as integer no-undo.
   define variable v-clients-recid     as recid   no-undo.

   define buffer buf_clients for ub.clients.
   do
      for buf_clients
      on error undo, return error
      :
      if v-fbr-doc-fbroperator-code <> 0
         then 
      do:
         find first buf_clients no-lock
            where buf_clients.obj-type = {&prs}
            and buf_clients.obj-code = v-fbr-doc-fbroperator-code
            no-error.
         if available buf_clients
            then 
         do:
            assign
               v-clients-recid = recid( buf_clients )
               .
         end.
      end.
      run ref/cli-all.w (
         input parparentproc
         , input "b-sel":U
         , input {&prs}
         , input {&all}
         , input {&current}
         , input v-clients-recid
         , input ",,,,,,NO,,":U
         , input "":U
         , output ref-list
         ).
      assign
         v-clients-recid-int = integer( ref-list )
    no-error.
      if error-status :error
         then 
      do:
         assign
            v-fbr-doc-fbroperator-code = 0
            p-obj-fbroperator          = "":U
            .
      end.
      else 
      do:
         find first buf_clients no-lock
            where recid( buf_clients ) = v-clients-recid-int
            no-error.
         if not available buf_clients
            then 
         do:
            assign
               v-fbr-doc-fbroperator-code = 0
               p-obj-fbroperator          = "":U
               .
         end.
         else 
         do:
            assign
               v-fbr-doc-fbroperator-code = buf_clients.obj-code
               p-obj-fbroperator          = buf_clients.obj-name
               .
         end.
      end.
      run str/fbrattrw.p (
         input f-doc.doc-code
         , input {&trdcattr-fbroperator}
         , input string( v-fbr-doc-fbroperator-code )
         ) no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip 
            "Не удалось записать оператора производства."
            skip(1)
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box warning.
      end.
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-vsdsts d-in-doc 
FUNCTION need-marks RETURNS logical
(buffer local-fbr-line for ub.fbr-line ):
  
  define buffer bf_gds for ub.goods.
  define buffer buf_marking-lines      for ub.marking-lines .
  define buffer buf_marking      for ub.marking .
  
  define variable varvalue as character no-undo .
  define variable vartype as character no-undo .
  define variable v-marks-qnty as decimal no-undo init 0.0 .
  define variable v-GTIN as character no-undo .
  define variable v-GTIN-qnty as decimal no-undo .
    
  find first bf_gds where bf_gds.artic      = local-fbr-line.artic
                      and bf_gds.prod-type  = local-fbr-line.prod-type
                      and bf_gds.prod-code  = local-fbr-line.prod-code
                      .
  v-isweighed = WghProdVariable(v-cntxt-obj-type, v-cntxt-obj-code, bf_gds.gds-code) .
  RUN gds-attr-value (
      INPUT bf_gds.gds-code,
      INPUT {&attr-mark-type},
      OUTPUT varvalue,
      OUTPUT vartype
      ).
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsEDOForType(varvalue)
  or v-isweighed
  then do :
    for each buf_marking-lines no-lock where buf_marking-lines.gds-code = bf_gds.gds-code
                                         and buf_marking-lines.obj-type = f-doc.obj-type
                                         and buf_marking-lines.obj-code = f-doc.obj-code
                                         and buf_marking-lines.in-code  = "manufacturing"
                                         and buf_marking-lines.out-code = local-fbr-line.doc-code
                                         and buf_marking-lines.part-code = local-fbr-line.recipe-code
                                         and buf_marking-lines.prt-code = 0
    :
      if v-isweighed
      then do :
        for first buf_marking no-lock where buf_marking.mark begins buf_marking-lines.mark :
          v-mark-weight = MarkWeight(buf_marking.mark) .
          assign v-marks-qnty = v-marks-qnty + v-mark-weight .
        end .
      end .
      else do :
        v-GTIN = getGtinByDM(buf_marking-lines.mark) .
        v-GTIN-qnty = getQntyCodeByGtin(v-GTIN) .
        if v-GTIN-qnty = 1
        then do :
          v-marks-qnty = v-marks-qnty + v-GTIN-qnty .
        end .
      end .
    end .
    if v-marks-qnty <> local-fbr-line.fact-qnty
    then return yes .
    else return no .
  end .
  else return no .
  
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rowdisp D-FBR-DOC 
procedure rowdisp :
  
  if need-marks(buffer buf_ingr_fbr-line)
  then do ii = 1 to extent (bcol):  
    if valid-handle (bcol[ii]) 
    then do:
      assign
        bcol[ii]:bgcolor = RED_COLOR.
    end.
  end.
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-fbrpaycode D-FBR-DOC 
PROCEDURE select-fbrpaycode :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-fbrpaycode         as integer          no-undo.
   define output parameter p-new-fbrpaycode    as integer          no-undo.

   define variable v-pay-type-recid as character no-undo .

   define buffer buf_pay-type for ub.pay-type.
   do
      for buf_pay-type
      on error undo, return error
      :
      run ref/paytype.w (
         input parparentproc
         , "b-sel":U
         , output v-pay-type-recid
         ).
      if v-pay-type-recid = ""
         then 
      do:
         assign
            p-new-fbrpaycode = p-fbrpaycode
            .
      end.
      else 
      do:
         find first buf_pay-type no-lock
            where recid( buf_pay-type ) = integer(v-pay-type-recid)
            .
         assign
            p-new-fbrpaycode = buf_pay-type.obj-code
            .
      end.
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-comp-qnty D-FBR-DOC 
PROCEDURE set-comp-qnty :
   /* Установить количество и продажную цену в строке составного товара. */
   do
      on error undo, return error
      :
      define input parameter p-comp-v-fbr-doc-line-recid    as recid        no-undo.
      define input parameter p-comp-qnty          as decimal      no-undo.

      define variable v-doc-code    as character no-undo.
      define variable v-recipe-code as character no-undo.
      define variable v-is-fixed    as logical   init no no-undo.

      define buffer buf_fbr-doc         for ub.fbr-doc.
      define buffer buf_fbr-line        for ub.fbr-line.
      define buffer buf_recipe_fbr-line for ub.fbr-line.

      find first buf_recipe_fbr-line exclusive-lock
         where recid( buf_recipe_fbr-line ) = p-comp-v-fbr-doc-line-recid
         .
      assign
         buf_recipe_fbr-line.fact-qnty = p-comp-qnty
         v-doc-code                    = buf_recipe_fbr-line.doc-code
         v-recipe-code                 = buf_recipe_fbr-line.recipe-code
         .
      find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = v-doc-code
         .
      if buf_fbr-doc.obj-type <> v-price-sale-obj-type
         or buf_fbr-doc.obj-code <> v-price-sale-obj-code
         then 
      do:
         assign
            v-is-fixed = yes
            .
      end.
      for each buf_fbr-line no-lock
         where buf_fbr-line.doc-code      = v-doc-code
         and buf_fbr-line.recipe-code   = v-recipe-code
         on error undo, return error
         :
         find first buf_recipe_fbr-line exclusive-lock
            where recid( buf_recipe_fbr-line ) = recid( buf_fbr-line )
            .
         if buf_recipe_fbr-line.is-calc = no
            then 
         do:
            run fbrlib-calc-prices in this-procedure (
               input recid( buf_recipe_fbr-line )
               , input v-price-sale-obj-type
               , input v-price-sale-obj-code
               , output buf_recipe_fbr-line.price-sale
               ) no-error.
            if error-status:error then 
            do:
               message substitute("Ошибка при расчете цен по док-ту&1&2&1&3"
                  , {&new-line}
                  , error-status:get-message(1)
                  , return-value )
                  view-as alert-box error .
               undo, return error .
            end.

            assign
               buf_recipe_fbr-line.is-calc = v-is-fixed
               .
         end.        /* buf_recipe_fbr-line.is-calc = no */
      end.        /* for each buf_fbr-line */
   end.
END PROCEDURE. /* set-comp-qnty */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-line-and-recipe D-FBR-DOC 
PROCEDURE show-line-and-recipe :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-comp-v-fbr-doc-line-recid    as recid            no-undo.

   define variable v-out-string as character no-undo.

   define buffer buf_fbr-line       for ub.fbr-line.
   define buffer buf_i_fbr-line     for ub.fbr-line.
   define buffer buf_fbr-recipe     for ub.fbr-recipe.
   define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
   do
      for buf_fbr-line
      , buf_i_fbr-line
      , buf_fbr-recipe
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where recid( buf_fbr-line ) = p-comp-v-fbr-doc-line-recid
         no-error.
      if available buf_fbr-line
         then 
      do:
         find first buf_fbr-recipe no-lock
            where buf_fbr-recipe.doc-code    = buf_fbr-line.doc-code
            and buf_fbr-recipe.recipe-code = buf_fbr-line.recipe-code

            .
         assign
            v-out-string = substitute(  "Составной товар: &2&1    &4  &5 &6 &7"
                                        , {&new-line}
                                        , buf_fbr-line.artic
                                        , buf_fbr-line.fact-qnty
                                        , buf_fbr-line.price-sum-rubl
                                        , buf_fbr-line.price-sum-base
                                        , buf_fbr-line.price-sum-vat-rubl
                                        , buf_fbr-line.price-sum-vat-base
                                     )
            v-out-string = v-out-string
                            + substitute(  "&1Рецепт: &2&1    &3 &4&1&1Ингредиенты:"
                                        , {&new-line}
                                        , buf_fbr-recipe.recipe-code
                                        , buf_fbr-recipe.qnty
                                        , buf_fbr-recipe.recipe-qnty
                                     )
            .
         for each buf_i_fbr-line no-lock
            where buf_i_fbr-line.doc-code    = buf_fbr-line.doc-code
            and buf_i_fbr-line.is-comp     = no
            and buf_i_fbr-line.recipe-code = buf_fbr-line.recipe-code
            on error undo, return error
            :
            assign
               v-out-string = v-out-string
                                + substitute(  "&1&2:  &3 &4 &5 &6 &7 &8 &9"
                                            , {&new-line}
                                            , buf_i_fbr-line.artic
                                            , buf_i_fbr-line.fact-qnty
                                            , buf_i_fbr-line.coeff-value
                                            , buf_i_fbr-line.coeff-waste
                                            , buf_i_fbr-line.price-sum-rubl
                                            , buf_i_fbr-line.price-sum-base
                                            , buf_i_fbr-line.price-sum-vat-rubl
                                            , buf_i_fbr-line.price-sum-vat-base
                                        )
               .
            find first buf_fbr-recipe-gds no-lock
               where buf_fbr-recipe-gds.doc-code      = buf_i_fbr-line.doc-code
               and buf_fbr-recipe-gds.recipe-code   = buf_i_fbr-line.recipe-code
               and buf_fbr-recipe-gds.prod-type     = buf_i_fbr-line.prod-type
               and buf_fbr-recipe-gds.prod-code     = buf_i_fbr-line.prod-code
               and buf_fbr-recipe-gds.artic         = buf_i_fbr-line.artic
               .
            assign
               v-out-string = v-out-string
                                + substitute(  "&1 &2 &3 &4 &5 &6 &7 &8"
                                            , {&new-line}
                                            , buf_fbr-recipe-gds.qnty
                                            , buf_fbr-recipe-gds.calc-method
                                            , buf_fbr-recipe-gds.coeff-value
                                            , buf_fbr-recipe-gds.coeff-waste
                                            , buf_fbr-recipe-gds.brutto-qnty
                                            , buf_fbr-recipe-gds.recipe-qnty
                                            , buf_fbr-recipe-gds.recipe-brutto-qnty
                                          )
               .
         end.        /* for each buf_i_fbr-line */
      end.        /* if available buf_fbr-line */
      message
         v-out-string
         view-as alert-box information
         title "Строки документа производства."
         .
   end.
END PROCEDURE. /* show-line-and-recipe */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on D-FBR-DOC 
PROCEDURE UI-on :
   def input param fnc as character no-undo.
   /* -------------------------------------------------------------------------------------------
     Purpose:     включение интерфейса в нужном режиме
   ----------------------------------------------------------------------------------------------- */
   define variable v-have-rights as logical no-undo.
   do
      on error undo, return error
      :
      run assign-obj-fbroperator in this-procedure no-error.
      if error-status :error
         then 
      do:
         message
            vss-workfile vss-revision vss-description
            skip(1)
            skip 
            "Невозможно отобразить имя оператора производства."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box warning.
      end.
      display
         obj-fbroperator
         with frame {&frame-name}.
      find first flt-gds no-lock            /* для режима ТОВАР */
         where recid (flt-gds) = gds-rec
         no-error.
      if fnc = "enable"
         then 
      do:
         VIEW FRAME D-FBR-DOC.
         enable
            b-exit
            b-lkp
            b-help
            b-recipe
            b-gds
            br-comp
            br-ingr
            rs-one-all
            with frame {&frame-name}.
         assign
            b-add:MENU-MOUSE          = 1
            b-del:MENU-MOUSE          = 1
            b-rsrv:MENU-MOUSE         = 1
            r-outs:MENU-MOUSE         = 1
            frame {&frame-name}:title = substitute( "&1 &2 : &3   № &4  - &5"
                                            , f-doc.obj-type
                                            , string (f-doc.obj-code, ">>>>9")
                                            , f-doc.status_
                                            , f-doc.doc-code
                                            , p-doc-mode
                                        )
            .
         case rs-one-all :
            when "goods"
            then 
               do:        /* проверяем доступность товара для фильтрации */
                  if available flt-gds
                     then 
                  do:
                  /*                assign*/
                  /*                    browse br-comp:title = "Составные - товар: " + flt-gds.artic + " " + flt-gds.gds-name*/
                  /*                    browse br-ingr:title = "Ингредиенты - товар: " + flt-gds.artic + " " + flt-gds.gds-name*/
                  /*                .*/
                  end.
                  else 
                  do:
                     message
                        "Нет текущего товара для фильтрации ни в верхнем, ни в нижнем списке."
                        view-as alert-box.
                     assign
                        rs-one-all = "all"
                        .
                     /* поскольку проверяется на = goods, зациклиться не должно */
                     run UI-on ("enable").
                  end.
               end.
         end case.
         assign
            v-have-rights = yes
            .
         if f-doc.is-free = yes
            then 
         do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_manufacturing_free-update':U
              {&cntxt-object}
              f-doc.host-code
              f-doc.obj-type
              f-doc.obj-code
              0
              0
              0
              false
              v-have-rights
            }
         end.        /* if p-fbr-doc-is-free = yes */
         if f-doc.is-free = no
            or f-doc.status_ = {&fact}
            or v-have-rights = no
            or p-doc-mode      = {&lookup}
            then 
         do:
            assign
               buf_comp_fbr-line.price-rubl :read-only         in browse br-comp = yes
               buf_comp_fbr-line.price-sum-vat-rubl :read-only in browse br-comp = yes
               .
         end.
         case p-doc-mode :
            when {&lookup}
            then 
               do:
                  enable
                     b-prev
                     b-next
                     with frame {&frame-name}.
               end.
            when {&update}
            then 
               do:
                  if f-doc.status_ = {&g___new}
                     then 
                  do:
                     enable
                        b-add
                        b-chg
                        b-del
                        out-code
                        r-outs
                        b-calc-comp
                        b-calc-ingr
                        r-price
                        r-fbroperator
                        fi-pay-code
                        r-pay
                        b-add-marks
                        with frame {&frame-name}.
                     hide
                        b-parts
                        in frame {&frame-name}.
                  end.
                  if f-doc.status_ = {&permitted}
                     then 
                  do:
                     enable
                        b-rsrv
                        b-parts
                        with frame {&frame-name}.
                  end.
                  if f-doc.status_ <> {&fact} AND v-back-date then 
                  do:
                     enable
                        fact-date
                        shift-sel 
                        when is-shift-on
                        with frame {&frame-name}.
                  end.
               end.
         end case.
         if rs-one-all = "type"
            then 
         do:
            disable
               b-add
               b-chg
               b-del
               out-code
               r-outs
               b-calc-comp
               b-calc-ingr
               b-rsrv
               r-fbroperator
               fi-pay-code
               fi-pay-type-name
               r-pay
               with frame {&frame-name}.
            assign
               buf_ingr_fbr-line.fact-qnty:read-only           in browse br-ingr = yes
               buf_ingr_fbr-line.price-base:read-only          in browse br-ingr = yes
               buf_ingr_fbr-line.price-rubl:read-only          in browse br-ingr = yes
               buf_ingr_fbr-line.price-sum-vat-base:read-only  in browse br-ingr = yes
               buf_ingr_fbr-line.price-sum-vat-rubl:read-only  in browse br-ingr = yes
               buf_ingr_fbr-line.price-sale:read-only          in browse br-ingr = yes
               buf_ingr_fbr-line.is-calc:read-only             in browse br-ingr = yes
               buf_ingr_fbr-line.fix-cost:read-only            in browse br-ingr = yes
               buf_comp_fbr-line.is-calc:read-only             in browse br-comp = yes
               buf_comp_fbr-line.fix-cost:read-only            in browse br-comp = yes
               /*            buf_ingr_fbr-line.price-sum-base:read-only      in browse br-ingr = yes*/
               /*            buf_ingr_fbr-line.price-sum-rubl:read-only      in browse br-ingr = yes*/
               .
         end.        /* rs-one-all = "type" */
         else 
         do:
            assign
               buf_ingr_fbr-line.fact-qnty:read-only in browse br-ingr          = (p-doc-mode = {&lookup} or f-doc.status_ <> {&g___new})
               buf_ingr_fbr-line.price-base:read-only in browse br-ingr         = yes
               buf_ingr_fbr-line.price-rubl:read-only in browse br-ingr         = yes
               buf_ingr_fbr-line.price-sum-vat-base:read-only in browse br-ingr = yes
               buf_ingr_fbr-line.price-sum-vat-rubl:read-only in browse br-ingr = yes
               /*            buf_ingr_fbr-line.price-sum-base:read-only in browse br-ingr = yes*/
               /*            buf_ingr_fbr-line.price-sum-rubl:read-only in browse br-ingr = yes*/
               buf_ingr_fbr-line.fix-cost:read-only in browse br-ingr           = (p-doc-mode = {&lookup} or f-doc.status_ <> {&permitted})
               buf_ingr_fbr-line.price-sale:read-only in browse br-ingr         = (p-doc-mode = {&lookup} or f-doc.status_ <> {&g___new})
               buf_ingr_fbr-line.is-calc:read-only in browse br-ingr            = buf_ingr_fbr-line.price-sale:read-only in browse br-ingr
               buf_comp_fbr-line.is-calc:read-only in browse br-comp            = buf_ingr_fbr-line.price-sale:read-only in browse br-ingr
               buf_comp_fbr-line.fix-cost:read-only in browse br-comp           = buf_ingr_fbr-line.fix-cost:read-only in browse br-ingr
               .
         end.        /* rs-one-all <> "type" */
         if rs-one-all = "goods"
            then 
         do:        /* не знаю, какие запрещать, закрою на всякий случай эти */
            disable
               b-add
               b-del
               with frame {&frame-name}.
         end.
         { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_manufacturing_price-sale-ingr':U
          {&cntxt-object}
          f-doc.host-code
          f-doc.obj-type
          f-doc.obj-code
          0
          0
          0
          false
          v-have-rights
        }
         if v-have-rights = no
            then 
         do:
            assign
               buf_ingr_fbr-line.price-sale :read-only         in browse br-ingr = yes
               .
         end.
      end.        /* if fnc = "enable" */
      if f-doc.status_ = {&permitted}
         then 
      do:
         enable
            b-parts
            with frame {&frame-name}.
      end.
      display
         rs-one-all
         fi-pay-code
         fi-pay-type-name
         with frame {&frame-name}.
      /* поля только для задания параметров редактирования, просто так не показываем */
      if r-outs:sensitive
         then 
      do:
         display
            "" @ out-code
            with frame {&frame-name}.
      end.
      else 
      do:
         hide
            out-code
            r-outs
            in frame {&frame-name}.
      end.
      if r-price:sensitive
         then 
      do:
         display
            v-price-sale-obj-type + " " + string( v-price-sale-obj-code ) @ obj-price
            with frame {&frame-name}.
      end.
      else 
      do:
         hide
            obj-price
            r-price
            in frame {&frame-name}.
      end.
      run open-comp in this-procedure.
      run open-ingr in this-procedure ( input ( if avail buf_comp_fbr-line then buf_comp_fbr-line.recipe-code else ? ) ).
      if v-fbr-doc-line-rec = ?
         then 
      do:
         if v-fbr-doc-rep-rec <> ?
            and rs-one-all <> "all"
            then 
         do:      /* требуется встать на строчку в нижнем browse для пустого рецепта - в верхнем может */
            assign      /*  быть пусто, если строка для пустого рецепта добавлялась в нижний - нужен режим "все" */
               rs-one-all = "all"
               .
            run UI-on ("enable").   /* поскольку проверяется на <> all, зациклиться не должно */
         end.
      end.
      else 
      do:
         reposition br-comp to recid (v-fbr-doc-line-rec) no-error.
      end.
      apply "value-changed" to br-comp in frame {&frame-name}.
      apply "value-changed" to br-ingr in frame {&frame-name}.
      apply "entry" to br-comp in frame {&frame-name}.
      if available buf_comp_fbr-line then 
      do:
         current-browse = br-comp :handle.
      end.
      else 
      do:
         apply "entry" to br-ingr.
         if available buf_ingr_fbr-line then 
         do:
            current-browse = br-ingr :handle.
         end.
      end.
      if v-fbr-doc-rep-rec <> ?
         then 
      do:
         reposition br-ingr to recid( v-fbr-doc-rep-rec ) no-error.
      end.
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-goods-name D-FBR-DOC 
FUNCTION get-goods-name RETURNS CHARACTER
   ( p-fbr-line-recid AS RECID ) :
   /*------------------------------------------------------------------------------
     Purpose: ищет название товара для любой строки документа производства
   ------------------------------------------------------------------------------*/

   define variable v-gds-name as character no-undo.

   RUN get-goods-name-proc in this-procedure (
      input p-fbr-line-recid
      , output v-gds-name
      ).
   return ( v-gds-name ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-line-OK D-FBR-DOC 
FUNCTION get-line-OK RETURNS logical
   ( p-fbr-line-recid AS RECID /* buffer buf_fbr-line for ub.fbr-line */) :
   /*------------------------------------------------------------------------------
     Purpose: вычисляет значение для колонки ОК
   ------------------------------------------------------------------------------*/
   define variable v-line-ok as logical no-undo.

   run get-line-OK-proc in this-procedure (
      input p-fbr-line-recid
      , output v-line-ok
      ).
   return v-line-ok.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-netto-qnty D-FBR-DOC 
FUNCTION get-netto-qnty RETURNS DECIMAL
   ( p-fbr-line-recid AS RECID /* buffer buf_fbr-line for ub.fbr-line */) :
   /*------------------------------------------------------------------------------
     Purpose:
       Notes:
   ------------------------------------------------------------------------------*/
   define variable v-netto-qnty as decimal no-undo.

   run get-netto-qnty-proc in this-procedure (
      input p-fbr-line-recid
      , output v-netto-qnty
      ).
   return v-netto-qnty.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-prod-ref D-FBR-DOC 
FUNCTION get-prod-ref RETURNS CHARACTER
   ( p-fbr-line-recid AS RECID /* buffer buf_fbr-line for ub.fbr-line*/ ) :
   /*------------------------------------------------------------------------------
     Purpose: вычисляет тип и код производителя товара
   ------------------------------------------------------------------------------*/
   define variable v-prog-string as character no-undo.

   run get-prod-ref-proc in this-procedure (
      input p-fbr-line-recid
      , output v-prog-string
      ).
   return v-prog-string.
  
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-unit-base D-FBR-DOC 
FUNCTION get-unit-base RETURNS CHARACTER
   (  p-fbr-line-recid AS RECID /*buffer buf_fbr-line for ub.fbr-line*/ ) :
   /*------------------------------------------------------------------------------
     Purpose: ищет едизм товара для любой строки документа производства
   ------------------------------------------------------------------------------*/
   define variable v-unit-base as character no-undo.

   run get-unit-base-proc in this-procedure (
      input p-fbr-line-recid
      , output v-unit-base
      ).
   return v-unit-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

