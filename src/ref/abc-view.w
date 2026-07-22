&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_abc-analysis FOR abc-analysis.
DEFINE BUFFER buf_abc-analysis-gds-obj FOR abc-analysis-gds-obj.
DEFINE NEW SHARED BUFFER Buf_abc-analysis-goods FOR abc-analysis-goods.
DEFINE BUFFER Buf_abc-analysis-obj FOR abc-analysis-obj.
DEFINE BUFFER buf_assortment-matrix FOR assortment-matrix.
DEFINE BUFFER buf_assortment-matrix-goods FOR assortment-matrix-goods.
DEFINE BUFFER Buf_gds-obj-prop FOR gds-obj-prop.
DEFINE NEW SHARED BUFFER buf_goods FOR goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр результатов АВС анализа

Автор: Чернова Светлана Александровна
Дата создания: 04/26/05
Author: Svetlana Chernova
Creation date: 04/26/05

*/

define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter v-id          as integer   no-undo .
define input  parameter v-db-num      as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр результатов АВС анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ cmp/obj-list.i new  }

{ cmp/gds-list.i gds-list def "new shared"}
&undefine gds-list_i_def
{ cmp/gds-list.i gds-list-flt def "new shared"}
{ cmp/doc-list.i doc-list def "new shared" }
{ gbl/cur-time.i }
{ ref/def-hash.i }
{ cmp/r-pril.i   new }
{ gbl/prn-lib.i  }
{ rep/gn-extp.i  }  /*Процедуры для определения имени расширенного типа документов*/
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ gbl/fltopend.i defproc }
{ ref/gds-matl.i }
{ str/ascorrm.i  }
{ gbl/assmatat.i }   /* Библиотека для работы с атрибутами АМ */
{ gbl/thbj-def.i }
{ ref/ass-mat.i &DEF_PROC=YES}    /* Процедуры и функции для работы с АМ (по задаче "Процент отклонения матрицы от шаблона") */
{ rep/html-conv.i }


define variable filter-point as character no-undo init "Просмотр АВС анализа" .
define variable filter-point0 as character no-undo init "Просмотр_АВС_анализа" .
define variable sort-column-name as character no-undo .
define variable doc-rec as recid no-undo .

define new shared buffer temp-trn-doc for gds-list-flt  .
define variable r-2 as integer   no-undo init 1 .

create gds-list-flt.
gds-list-flt.gds-code = 0 .
release gds-list-flt .


define variable v-izt      as character no-undo .
define variable v-Acc-mat  as character no-undo .
define variable v-Amin     as character no-undo .
define variable v-obj-AssMin  as logical   no-undo .
define variable v-obj-igt     as character no-undo .

define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id              as character               no-undo .
define variable v-file-name-rep-htm as character no-undo .

define variable rid-list   as character no-undo .

/* для F9 */
define variable list-mode as char  no-undo.  /* специально для сохранения list-mode */
define variable doc-mode  as char  no-undo.  /* специально для сохранения doc-mode */
define variable line-rec  as recid no-undo.  /* специально для сохранения line-rec */
define variable gds-rec   as recid no-undo.  /* специально для сохранения gds-rec */
define variable prt-rec   as recid no-undo.  /* специально для сохранения prt-rec */
define variable line-mode as char  no-undo.  /* специально для сохранения line-mode */
define variable g#mainmenu-handle AS WIDGET-HANDLE NO-UNDO.
g#mainmenu-handle = parParentProc .

&scop col-p1    mark-string(recid( buf_abc-analysis-goods) , rid-list )
&scop dyn_col-p1    substitute('dynamic-function(&1mark-string&1, recid(buf_abc-analysis-goods), &1&2&1)', ~{&double-quote~}, rid-list)
&scop col-p2    buf_goods.artic
&scop col-p3    buf_goods.gds-name
&scop col-p4    buf_abc-analysis-goods.abcg-abc
&scop col-p5    buf_abc-analysis-goods.abcg-prcnt-for-estimate
&scop col-p6    buf_abc-analysis-goods.abcg-sum-for-estimate
&scop col-p7    buf_abc-analysis-goods.abcg-order-qnty
&scop col-p8    buf_abc-analysis-goods.abcg-qnty
&scop col-p9    buf_abc-analysis-goods.abcg-stock-qnty
&scop col-p10   buf_abc-analysis-goods.abcg-stock-price-acc
&scop col-p11   buf_abc-analysis-goods.abcg-stock-price-sale
&scop col-p12   buf_abc-analysis-goods.abcg-sum-acc
&scop col-p13   buf_abc-analysis-goods.abcg-sum-cur
&scop col-p14   buf_abc-analysis-goods.abcg-sum-doc
&scop col-p15   buf_abc-analysis-goods.abcg-temp-sale-goods
&scop col-p16   v-izt
&scop col-p17   v-Acc-mat
&scop col-p18   v-Amin
&scop col-p19   buf_abc-analysis-goods.abcg-prcnt-account


&scop col-l1  '*! ! '
&scop col-l2  'Артикул! ! '
&scop col-l3  'Название! ! '
&scop col-l4  'A!B!C'
&scop col-l5  '% по  !крите-!рию   '
&scop col-l6  'Сумма!для оценки!по критерию'
&scop col-l7  'Заказанное!количество!товара'
&scop col-l8  'Количество!по!реализации'
&scop col-l9  'Остаток!количество!текущий'
&scop col-l10 'Остаток!товара в!учет.ценах'
&scop col-l11 'Остаток!товара в!продаж.ценах'
&scop col-l12 'Сумма!реализации в!учет.ценах'
&scop col-l13 'Сумма!реализации в!прод.ценах'
&scop col-l14 'Сумма!реализации в!ценах докум.'
&scop col-l15 'Темп!продаж!среднесут.'
&scop col-l16  'ИЖТ! ! '
&scop col-l17  'Ассорт.!матрица! '
&scop col-l18  'Ассорт.!min! '
&scop col-l19  '%  !нараст!итогом'

&scop head-col ~
 {&col-l1} + '#' + ~
 {&col-l2} + '#' + ~
 {&col-l3} + '#' + ~
 {&col-l4} + '#' + ~
 {&col-l5} + '#' + ~
 {&col-l6} + '#' + ~
 {&col-l7} + '#' + ~
 {&col-l8} + '#' + ~
 {&col-l9} + '#' + ~
 {&col-l10} + '#' + ~
 {&col-l12} + '#' + ~
 {&col-l13} + '#' + ~
 {&col-l14} + '#' + ~
 {&col-l15} + '#' + ~
 {&col-l16}


define variable v-order-col as character no-undo .
define variable v-size-col1 as decimal   no-undo .
define variable v-size-col2 as decimal   no-undo .

run uf-get in this-procedure(
     input  {&uf-abc}
    ,input  g#userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .

  end.

if not error-status:error then do:
   v-order-col  = entry ( 1, v-uf-List_ ,{&delim-par} ) no-error.
   v-size-col1  = decimal (entry(2, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col2  = decimal (entry(3, v-uf-List_ ,{&delim-par})) no-error.
   if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1 = 10.
   if v-size-col2 = 0 or v-size-col2 = ? then v-size-col2 = 20.
   if v-order-col = "" or v-order-col = ? then v-order-col = "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16".
end.


find first buf_abc-analysis no-lock where
           buf_abc-analysis.abc-id = v-id and
           buf_abc-analysis.db-num = v-db-num
            no-error .
if not available  buf_abc-analysis then do:
   message vss-workfile vss-revision vss-description skip
          "Не найдена запись buf_abc-analysis"  v-id v-db-num
          return-value
          error-status :get-message(1) .
   return.
end.


define buffer buf_criterion-analysis for ub.criterion-analysis.
find first buf_criterion-analysis no-lock where
           buf_criterion-analysis.cral-id = buf_abc-analysis.cral-id no-error .
if not available  buf_criterion-analysis then do:
   message vss-workfile vss-revision vss-description skip
          "Не найдена запись buf_criterion-analysis"  buf_abc-analysis.cral-id
          return-value
          error-status :get-message(1) .
   return.
end.

DEFINE VARIABLE v-ass-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Ассортиментная матрица"
      VIEW-AS TEXT
     SIZE 69.5 BY .67
     NO-UNDO.

define variable g-log as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Buf_abc-analysis-goods buf_goods ~
temp-trn-doc Buf_abc-analysis-obj buf_abc-analysis-gds-obj Buf_gds-obj-prop ~
buf_assortment-matrix buf_assortment-matrix-goods

/* Definitions for BROWSE BROWSE-goods                                  */
&Scoped-define FIELDS-IN-QUERY-BROWSE-goods mark-string(buffer buf_abc-analysis-goods, rid-list) buf_goods.artic buf_goods.gds-name Buf_abc-analysis-goods.abcg-abc Buf_abc-analysis-goods.abcg-prcnt-for-estimate Buf_abc-analysis-goods.abcg-prcnt-account Buf_abc-analysis-goods.abcg-sum-for-estimate v-izt v-Amin v-Acc-mat Buf_abc-analysis-goods.abcg-qnty Buf_abc-analysis-goods.abcg-stock-qnty Buf_abc-analysis-goods.abcg-stock-price-acc Buf_abc-analysis-goods.abcg-stock-price-sale Buf_abc-analysis-goods.abcg-sum-acc Buf_abc-analysis-goods.abcg-sum-cur Buf_abc-analysis-goods.abcg-sum-doc Buf_abc-analysis-goods.abcg-temp-sale-goods Buf_abc-analysis-goods.abcg-order-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-goods buf_goods.artic ~
  Buf_abc-analysis-goods.abcg-abc
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-goods buf_goods ~
Buf_abc-analysis-goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-goods buf_goods
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-BROWSE-goods Buf_abc-analysis-goods
&Scoped-define SELF-NAME BROWSE-goods
&Scoped-define QUERY-STRING-BROWSE-goods FOR EACH Buf_abc-analysis-goods       WHERE Buf_abc-analysis-goods.abc-id = v-id and Buf_abc-analysis-goods.db-num = v-db-num NO-LOCK, ~
             EACH buf_goods OF ub.Buf_abc-analysis-goods NO-LOCK  , ~
             first temp-trn-doc where (r-2 = 1 or buf_goods.gds-code = temp-trn-doc.gds-code )       INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-goods OPEN QUERY {&SELF-NAME} FOR EACH Buf_abc-analysis-goods       WHERE Buf_abc-analysis-goods.abc-id = v-id and Buf_abc-analysis-goods.db-num = v-db-num NO-LOCK, ~
             EACH buf_goods OF ub.Buf_abc-analysis-goods NO-LOCK  , ~
             first temp-trn-doc where (r-2 = 1 or buf_goods.gds-code = temp-trn-doc.gds-code )       INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-goods Buf_abc-analysis-goods ~
buf_goods temp-trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-goods Buf_abc-analysis-goods
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-goods buf_goods
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-goods temp-trn-doc


/* Definitions for BROWSE BROWSE-obj                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-obj Buf_abc-analysis-obj.obj-type Buf_abc-analysis-obj.obj-code buf_abc-analysis-gds-obj.abog-qnty buf_abc-analysis-gds-obj.abog-temp-sale-goods buf_abc-analysis-gds-obj.abog-stock-qnty buf_abc-analysis-gds-obj.abog-price-crc buf_abc-analysis-gds-obj.abog-sum-acc buf_abc-analysis-gds-obj.abog-sum-cur buf_abc-analysis-gds-obj.abog-sum-doc buf_abc-analysis-gds-obj.abog-vat-acc buf_abc-analysis-gds-obj.abog-vat-cur buf_abc-analysis-gds-obj.abog-vat-doc buf_abc-analysis-gds-obj.abog-transport-acc buf_abc-analysis-gds-obj.abog-transport-cur buf_abc-analysis-gds-obj.abog-transport-doc buf_abc-analysis-gds-obj.abog-road-tax-acc buf_abc-analysis-gds-obj.abog-road-tax-cur buf_abc-analysis-gds-obj.abog-road-tax-doc buf_abc-analysis-gds-obj.abog-other-doc buf_abc-analysis-gds-obj.abog-other-cur buf_abc-analysis-gds-obj.abog-other-acc v-obj-igt v-obj-AssMin buf_assortment-matrix-goods.asmt-id
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-obj
&Scoped-define SELF-NAME BROWSE-obj
&Scoped-define QUERY-STRING-BROWSE-obj FOR EACH Buf_abc-analysis-obj WHERE                Buf_abc-analysis-obj.abc-id = v-id AND                Buf_abc-analysis-obj.db-num = v-db-num                NO-LOCK, ~
                 EACH buf_abc-analysis-gds-obj WHERE                buf_abc-analysis-gds-obj.obj-type = Buf_abc-analysis-obj.obj-type AND                buf_abc-analysis-gds-obj.obj-code = Buf_abc-analysis-obj.obj-code AND                buf_abc-analysis-gds-obj.gds-code = Buf_abc-analysis-goods.gds-code AND                buf_abc-analysis-gds-obj.abc-id   = v-id AND                buf_abc-analysis-gds-obj.db-num   = v-db-num                OUTER-JOIN NO-LOCK, ~
                 EACH Buf_gds-obj-prop WHERE                Buf_gds-obj-prop.obj-type =  Buf_abc-analysis-obj.obj-type AND                Buf_gds-obj-prop.obj-code =  Buf_abc-analysis-obj.obj-code AND                Buf_gds-obj-prop.gds-code =  Buf_abc-analysis-goods.gds-code                OUTER-JOIN NO-LOCK, ~
                first buf_assortment-matrix WHERE                buf_assortment-matrix.asmt-status        = 0  AND                buf_assortment-matrix.obj-type =  Buf_abc-analysis-obj.obj-type AND                buf_assortment-matrix.obj-code =  Buf_abc-analysis-obj.obj-code                OUTER-JOIN NO-LOCK, ~
                FIRST buf_assortment-matrix-goods WHERE                buf_assortment-matrix-goods.asmg-status        = 0  AND                buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND                buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND                buf_assortment-matrix-goods.gds-code =  buf_abc-analysis-goods.gds-code                OUTER-JOIN NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-obj OPEN QUERY {&SELF-NAME}       FOR EACH Buf_abc-analysis-obj WHERE                Buf_abc-analysis-obj.abc-id = v-id AND                Buf_abc-analysis-obj.db-num = v-db-num                NO-LOCK, ~
                 EACH buf_abc-analysis-gds-obj WHERE                buf_abc-analysis-gds-obj.obj-type = Buf_abc-analysis-obj.obj-type AND                buf_abc-analysis-gds-obj.obj-code = Buf_abc-analysis-obj.obj-code AND                buf_abc-analysis-gds-obj.gds-code = Buf_abc-analysis-goods.gds-code AND                buf_abc-analysis-gds-obj.abc-id   = v-id AND                buf_abc-analysis-gds-obj.db-num   = v-db-num                OUTER-JOIN NO-LOCK, ~
                 EACH Buf_gds-obj-prop WHERE                Buf_gds-obj-prop.obj-type =  Buf_abc-analysis-obj.obj-type AND                Buf_gds-obj-prop.obj-code =  Buf_abc-analysis-obj.obj-code AND                Buf_gds-obj-prop.gds-code =  Buf_abc-analysis-goods.gds-code                OUTER-JOIN NO-LOCK, ~
                first buf_assortment-matrix WHERE                buf_assortment-matrix.asmt-status        = 0  AND                buf_assortment-matrix.obj-type =  Buf_abc-analysis-obj.obj-type AND                buf_assortment-matrix.obj-code =  Buf_abc-analysis-obj.obj-code                OUTER-JOIN NO-LOCK, ~
                FIRST buf_assortment-matrix-goods WHERE                buf_assortment-matrix-goods.asmg-status        = 0  AND                buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND                buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND                buf_assortment-matrix-goods.gds-code =  buf_abc-analysis-goods.gds-code                OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-obj Buf_abc-analysis-obj ~
buf_abc-analysis-gds-obj Buf_gds-obj-prop buf_assortment-matrix ~
buf_assortment-matrix-goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-obj Buf_abc-analysis-obj
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-obj buf_abc-analysis-gds-obj
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-obj Buf_gds-obj-prop
&Scoped-define FOURTH-TABLE-IN-QUERY-BROWSE-obj buf_assortment-matrix
&Scoped-define FIFTH-TABLE-IN-QUERY-BROWSE-obj buf_assortment-matrix-goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-goods}~
    ~{&OPEN-QUERY-BROWSE-obj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-cancel B-mark B-save B-chg-izt B-add-AM ~
B-del-AM B-spis-ord b-filter-ext B-Help B-chg-ABC B-add-AMin B-del-AMin ~
B-ord B-print BROWSE-goods BROWSE-obj

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-buf FOR abc-analysis-goods, input mark-list as character  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-B-print
       MENU-ITEM m_goods        LABEL "По товарам"
       MENU-ITEM m_obj          LABEL "По объектам"   .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add-AM
     LABEL "Добавить в АМ"
     SIZE 16.5 BY 1 TOOLTIP "Добавить в ассортиментную матрицу по объекту".

DEFINE BUTTON B-add-AMin
     LABEL "Добавить в AMin"
     SIZE 16.5 BY 1 TOOLTIP "Добавить в ассортиментный минимум по объектам".

DEFINE BUTTON B-cancel AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-chg-ABC
     LABEL "Изменить ABC"
     SIZE 12.5 BY 1 TOOLTIP "Изменить группу АВС".

DEFINE BUTTON B-chg-izt
     LABEL "Изменить ИЖТ"
     SIZE 12.5 BY 1 TOOLTIP "Изменить ИЖТ".

DEFINE BUTTON B-del-AM
     LABEL "Удалить из АМ"
     SIZE 16 BY 1 TOOLTIP "Удалить из  ассортиментных матриц по объектам".

DEFINE BUTTON B-del-AMin
     LABEL "Удалить из AMin"
     SIZE 16 BY 1 TOOLTIP "Удалить из  ассортиментных минимумов по объектам".

DEFINE BUTTON b-filter-ext
     IMAGE-UP FILE "cmp/b-schef.bmp":U
     LABEL "b-filter-ext"
     SIZE 3 BY 1 TOOLTIP "Расширенный фильтр".

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 2.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON B-ord
     LABEL "Новый заказ"
     SIZE 13.5 BY 1 TOOLTIP "Сформировать заказ".

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save
     LABEL "Сохранить"
     SIZE 11.5 BY 1 TOOLTIP "Сохранить по умолчанию".

DEFINE BUTTON B-spis-ord
     LABEL "Заказы"
     SIZE 13.5 BY 1 TOOLTIP "Список открытых заказов по отмеченным товарам".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-goods FOR
      Buf_abc-analysis-goods,
      buf_goods,
      temp-trn-doc SCROLLING.


DEFINE QUERY BROWSE-obj FOR
      Buf_abc-analysis-obj,
      buf_abc-analysis-gds-obj,
      Buf_gds-obj-prop,
      buf_assortment-matrix,
      buf_assortment-matrix-goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-goods Dialog-Frame _FREEFORM
  QUERY BROWSE-goods NO-LOCK DISPLAY
      mark-string(buffer buf_abc-analysis-goods, rid-list) COLUMN-LABEL "*! ! " FORMAT "X(1)":U
      buf_goods.artic COLUMN-LABEL "Артикул! ! " FORMAT "X(16)":U            WIDTH 10
      buf_goods.gds-name COLUMN-LABEL "Название! ! " FORMAT "X(50)":U        WIDTH 20
      Buf_abc-analysis-goods.abcg-abc COLUMN-LABEL "A!B!C" FORMAT "X(1)":U
      Buf_abc-analysis-goods.abcg-prcnt-for-estimate COLUMN-LABEL "% по  !крите-!рию   " FORMAT "->>9.999":U       WIDTH 7
      Buf_abc-analysis-goods.abcg-prcnt-account      COLUMN-LABEL {&col-l19}  FORMAT ">>9.999":U       WIDTH 7
      Buf_abc-analysis-goods.abcg-sum-for-estimate COLUMN-LABEL "Сумма!для оценки!по критерию" FORMAT "->>>>>>>>9.<<<":U            WIDTH 12
      v-izt      COLUMN-LABEL "ИЖТ! ! "           FORMAT "X(20)":U                                                WIDTH 10
      v-Amin     COLUMN-LABEL "Ассорт.!min! "     FORMAT "X(9)":U                                                 wIDTH 9
      v-Acc-mat  COLUMN-LABEL "Ассорт.!матрица! " FORMAT "X(9)":U                                                 WIDTH 9
      Buf_abc-analysis-goods.abcg-qnty COLUMN-LABEL "Количество!по!реализации" FORMAT "->>>>>>9.<<<":U           WIDTH 12
      Buf_abc-analysis-goods.abcg-stock-qnty COLUMN-LABEL "Остаток!количество! " FORMAT "->>>>>>9.<<<":U          WIDTH 12
      Buf_abc-analysis-goods.abcg-stock-price-acc COLUMN-LABEL "Остаток!товара в!учет.ценах" FORMAT "->>>>>>>9.99":U
      Buf_abc-analysis-goods.abcg-stock-price-sale COLUMN-LABEL "Остаток!товара в!продаж.ценах" FORMAT "->>>>>>>9.99":U
      Buf_abc-analysis-goods.abcg-sum-acc COLUMN-LABEL "Сумма!реализации в!учет.ценах" FORMAT "->>>>>>>9.99":U
      Buf_abc-analysis-goods.abcg-sum-cur COLUMN-LABEL "Сумма!реализации в!прод.ценах" FORMAT "->>>>>>>9.99":U
      Buf_abc-analysis-goods.abcg-sum-doc COLUMN-LABEL "Сумма!реализации в!ценах докум." FORMAT "->>>>>>>9.99":U
      Buf_abc-analysis-goods.abcg-temp-sale-goods COLUMN-LABEL "Темп!продаж!среднесут." FORMAT "->>>>>9.<<<":U
      Buf_abc-analysis-goods.abcg-order-qnty COLUMN-LABEL "Заказанное!количество!товара" FORMAT ">>>>>>>>>9.<<<":U   WIDTH 11
      enable
          buf_goods.artic
          Buf_abc-analysis-goods.abcg-abc
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 12.25 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-obj Dialog-Frame _FREEFORM
  QUERY BROWSE-obj NO-LOCK DISPLAY
      Buf_abc-analysis-obj.obj-type COLUMN-LABEL "Тип! ! "     FORMAT "X(3)":U
      Buf_abc-analysis-obj.obj-code COLUMN-LABEL "Объект! ! "  FORMAT ">>>>>9":U
      buf_abc-analysis-gds-obj.abog-qnty            COLUMN-LABEL "Количество!по!реализации"          FORMAT "->>>>>>>>9.<<<":U  WIDTH 12
      buf_abc-analysis-gds-obj.abog-temp-sale-goods COLUMN-LABEL "Темп!продаж! "                      FORMAT "->>>>>>>>9.<<<":U  WIDTH 12
      buf_abc-analysis-gds-obj.abog-stock-qnty COLUMN-LABEL "Остаток!количество!текущий"             FORMAT "->>>>>>>>9.<<<":U  WIDTH 12
      buf_abc-analysis-gds-obj.abog-price-crc COLUMN-LABEL "Продаж.цена!в валюте!критерия"           FORMAT "->>>>>>>>9.99":U   WIDTH 12
      buf_abc-analysis-gds-obj.abog-sum-acc COLUMN-LABEL "Сумма!реализации в!учет.ценах"             FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-sum-cur COLUMN-LABEL "Сумма!реализации в!продаж.ценах"           FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-sum-doc COLUMN-LABEL "Сумма!реализации в!ценах докум."           FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-vat-acc COLUMN-LABEL "НДС по сумме!реализации в!учет.ценах"      FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-vat-cur COLUMN-LABEL "НДС по сумме!реализации в!продаж.ценах"    FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-vat-doc COLUMN-LABEL "НДС по сумме!реализации в!ценах докум."    FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-transport-acc COLUMN-LABEL "Транспорт.!расходы в!учет.ценах"     FORMAT "->>>>>>>>9.99":U   WIDTH 12
      buf_abc-analysis-gds-obj.abog-transport-cur COLUMN-LABEL "Транспорт.!расходы в!продаж.ценах"   FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-transport-doc COLUMN-LABEL "Транспорт.!расходы в!ценах докум."   FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-road-tax-acc COLUMN-LABEL "Налог 3 по!реализации в!учет.ценах"   FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-road-tax-cur COLUMN-LABEL "Налог 3 по!реализации в!продаж.ценах" FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-road-tax-doc COLUMN-LABEL "Налог 3 по!реализации в!ценах докум." FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-other-doc COLUMN-LABEL "Сумма прочих!расходов в!ценах докум."    FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-other-cur COLUMN-LABEL "Сумма прочих!расходов в!продаж.ценах"    FORMAT "->>>>>>>>9.99":U
      buf_abc-analysis-gds-obj.abog-other-acc COLUMN-LABEL "Сумма прочих!расходов в!учет.ценах"      FORMAT "->>>>>>>>9.99":U
      v-obj-igt                  COLUMN-LABEL "ИЖТ! ! "                                  FORMAT "x(20)":U        WIDTH 8
      v-obj-AssMin               COLUMN-LABEL "Aсс!min! "                                FORMAT "*/ ":U
      v-ass-name                              COLUMN-LABEL "Ассорт.!матрица! "                        FORMAT "x(20)":U   WIDTH 10
      buf_assortment-matrix-goods.asmt-id     COLUMN-LABEL "Код!Ассорт.!матрицы"                     FORMAT ">>>>>>>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 7 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 15
     B-save AT ROW 1 COL 18
     B-chg-izt AT ROW 1 COL 29.5
     B-add-AM AT ROW 1 COL 42
     B-del-AM AT ROW 1 COL 58.5
     B-spis-ord AT ROW 1 COL 74.5
     b-filter-ext AT ROW 1 COL 88.13 WIDGET-ID 2
     B-Help AT ROW 1 COL 95.5
     B-chg-ABC AT ROW 2 COL 29.5
     B-add-AMin AT ROW 2 COL 42
     B-del-AMin AT ROW 2 COL 58.5
     B-ord AT ROW 2 COL 74.5
     B-print AT ROW 2 COL 88
     BROWSE-goods AT ROW 3 COL 1
     BROWSE-obj AT ROW 15.25 COL 1
     SPACE(0.12) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр результатов АВС анализа"
         CANCEL-BUTTON B-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_abc-analysis B "?" ? ub abc-analysis
      TABLE: buf_abc-analysis-gds-obj B "?" ? ub abc-analysis-gds-obj
      TABLE: Buf_abc-analysis-goods B "NEW SHARED" ? ub abc-analysis-goods
      TABLE: Buf_abc-analysis-obj B "?" ? ub abc-analysis-obj
      TABLE: buf_assortment-matrix B "?" ? ub assortment-matrix
      TABLE: buf_assortment-matrix-goods B "?" ? ub assortment-matrix-goods
      TABLE: Buf_gds-obj-prop B "?" ? ub gds-obj-prop
      TABLE: buf_goods B "NEW SHARED" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-goods B-print Dialog-Frame */
/* BROWSE-TAB BROWSE-obj BROWSE-goods Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-B-print:HANDLE.

ASSIGN
       BROWSE-goods:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

ASSIGN
       BROWSE-obj:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-goods
/* Query rebuild information for BROWSE BROWSE-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH Buf_abc-analysis-goods
      WHERE Buf_abc-analysis-goods.abc-id = v-id and Buf_abc-analysis-goods.db-num = v-db-num NO-LOCK,
      EACH buf_goods OF ub.Buf_abc-analysis-goods NO-LOCK  ,
      first temp-trn-doc where (r-2 = 1 or buf_goods.gds-code = temp-trn-doc.gds-code )
      INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BROWSE-goods FOR
      Buf_abc-analysis-goods,
      buf_goods,
      temp-trn-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-goods */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-obj
/* Query rebuild information for BROWSE BROWSE-obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
      FOR EACH Buf_abc-analysis-obj WHERE
               Buf_abc-analysis-obj.abc-id = v-id AND
               Buf_abc-analysis-obj.db-num = v-db-num
               NO-LOCK,
          EACH buf_abc-analysis-gds-obj WHERE
               buf_abc-analysis-gds-obj.obj-type = Buf_abc-analysis-obj.obj-type AND
               buf_abc-analysis-gds-obj.obj-code = Buf_abc-analysis-obj.obj-code AND
               buf_abc-analysis-gds-obj.gds-code = Buf_abc-analysis-goods.gds-code AND
               buf_abc-analysis-gds-obj.abc-id   = v-id AND
               buf_abc-analysis-gds-obj.db-num   = v-db-num
               OUTER-JOIN NO-LOCK,
          EACH Buf_gds-obj-prop WHERE
               Buf_gds-obj-prop.obj-type =  Buf_abc-analysis-obj.obj-type AND
               Buf_gds-obj-prop.obj-code =  Buf_abc-analysis-obj.obj-code AND
               Buf_gds-obj-prop.gds-code =  Buf_abc-analysis-goods.gds-code
               OUTER-JOIN NO-LOCK,
         first buf_assortment-matrix WHERE
               buf_assortment-matrix.asmt-status        = 0  AND
               buf_assortment-matrix.obj-type =  Buf_abc-analysis-obj.obj-type AND
               buf_assortment-matrix.obj-code =  Buf_abc-analysis-obj.obj-code
               OUTER-JOIN NO-LOCK,
         FIRST buf_assortment-matrix-goods WHERE
               buf_assortment-matrix-goods.asmg-status        = 0  AND
               buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND
               buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND
               buf_assortment-matrix-goods.gds-code =  buf_abc-analysis-goods.gds-code
               OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ",, OUTER, OUTER, OUTER"
     _Where[1]         = "Buf_abc-analysis-obj.abc-id = v-id
 AND Buf_abc-analysis-obj.db-num = v-db-num"
     _Query            is OPENED
*/  /* BROWSE BROWSE-obj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Просмотр результатов АВС анализа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-AM
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-AM Dialog-Frame
ON CHOOSE OF B-add-AM IN FRAME Dialog-Frame /* Добавить в АМ */
DO:
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
    true
    v-log
  }
 if not v-log then return  .

  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-AM in this-procedure ( input true ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Am"
          view-as alert-box error .

  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-AMin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-AMin Dialog-Frame
ON CHOOSE OF B-add-AMin IN FRAME Dialog-Frame /* Добавить в AMin */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-Amin in this-procedure  ( input true ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Amin"
          view-as alert-box error .
   reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cancel Dialog-Frame
ON CHOOSE OF B-cancel IN FRAME Dialog-Frame /* Выход */
DO:
define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
define variable v-list as character no-undo .

  assign
    cur-clmn-loc  = 1
    column-handle = {&browse-name}:first-column
    v-list        = column-handle:label + "#"
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = {&browse-name}:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.

   v-list = trim(v-list, "#") .
   define variable v-i as integer   no-undo .
   define variable v-pos as integer   no-undo .
   define variable v-list-new as character no-undo .
   define variable v-elem as character no-undo .

   repeat v-i = 1 to {&browse-name}:num-columns :
      v-elem = entry( v-i, v-list , "#") .

      v-pos = lookup( v-elem , {&head-col} , "#") .
      v-list-new = v-list-new + string(v-pos) + "," .
   end.

   define variable v-list-str as character no-undo .

   v-list-str = "" .
   repeat v-i = 1 to num-entries(v-list-new) :
      v-elem = entry(v-i , v-list-new ) .
      if int(v-elem) > 1 then
      v-list-str  = v-list-str + v-elem + "," .
   end.

   v-list-new = trim(v-list-str ,",")  +  {&delim-par}
              + string(decimal( {&col-p2}:width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( {&col-p3}:width     in browse {&browse-name})) +  {&delim-par}  .

run uf-set in this-procedure(
    input  {&uf-abc}
    ,input g#userid
    ,input v-list-new
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "uf-set"
      view-as alert-box error
    .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg-ABC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg-ABC Dialog-Frame
ON CHOOSE OF B-chg-ABC IN FRAME Dialog-Frame /* Изменить ABC */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-chg-abc in this-procedure  no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-chg-abc"
          view-as alert-box error .
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg-izt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg-izt Dialog-Frame
ON CHOOSE OF B-chg-izt IN FRAME Dialog-Frame /* Изменить ИЖТ */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-chg-igt in this-procedure  no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-chg-igt"
          view-as alert-box error .
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-AM
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-AM Dialog-Frame
ON CHOOSE OF B-del-AM IN FRAME Dialog-Frame /* Удалить из АМ */
DO:
define variable v-log as logical   no-undo .
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

  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-AM  in this-procedure ( input false ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Am"
          view-as alert-box error .
   reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-AMin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-AMin Dialog-Frame
ON CHOOSE OF B-del-AMin IN FRAME Dialog-Frame /* Удалить из AMin */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-Amin in this-procedure  ( input false ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Amin"
          view-as alert-box error .
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-filter-ext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-filter-ext Dialog-Frame
ON CHOOSE OF b-filter-ext IN FRAME Dialog-Frame /* b-filter-ext */
DO:
    if r-2 = 1 then r-2 = 2 .
             else r-2 = 1.

  if r-2 = 2 then do:

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
     b-filter-ext:LOAD-IMAGE ("cmp/b-schef.bmp") .
     b-filter-ext:tooltip = "Расширенный фильтр не установлен" .

  end.
  run OpenBr in this-procedure ( yes, no, '':U ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
    if available Buf_abc-analysis-goods then do:
        { gbl/markstrn.i Buf_abc-analysis-goods rid-list }

        g-log = browse-goods:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = browse-goods:select-next-row ().
            apply "VALUE-CHANGED" to browse-goods in frame {&frame-name}.
        end.
        /*if num-entries( rid-list ) = 0
          then
              hide mark-num in frame {&frame-name}.
          else do:

          mark-num:screen-value in frame {&frame-name}  = string (num-entries( rid-list )) .
          enable mark-num with frame {&frame-name}.

        end.
        */
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ord Dialog-Frame
ON CHOOSE OF B-ord IN FRAME Dialog-Frame /* Новый заказ */
DO:
 define variable loc#log as logical no-undo.
/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ABC-XYZ_pmnt-ord-doc':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if not loc#log then return no-apply.


define variable v-ord-doc-code as character no-undo .
define variable v-recid as character no-undo .
define variable v-i as integer   no-undo .
if num-entries(rid-list) = 0 then do:
    message "Не отмечены товары! "
             view-as alert-box information .
    return no-apply.
end.
    run cus/oraskcli.w
   (input parParentProc ,
    input rid-list ,
    output v-recid ).
define variable v-nn as integer   no-undo .
v-nn = num-entries(v-recid).
    if v-nn > 0 then do:
       repeat v-i = 1 to v-nn :
          run cus/show-ord.p (parParentProc ,int(entry(v-i,v-recid))) .
       end.
    end.
    else do:
    message "Заказ не был сформирован!" view-as alert-box information .
    end.
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  /* создадим строку для сохранения */
  run proc-save in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-spis-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-spis-ord Dialog-Frame
ON CHOOSE OF B-spis-ord IN FRAME Dialog-Frame /* Заказы */
DO:
define variable v-recid as character no-undo .
for each doc-list : delete doc-list. end.
  run cus/mdoclist.p
     ( rid-list ) .
  run cus/dord-doc.w
  ( parParentProc
  ,""  /*bttns           */
  ,?   /*p-curr-obj-type */
  ,?   /*p-curr-obj-code */
  ,?   /*p-mode          */
  ,?   /*p-sts           */
  , input-output v-recid   /*p-rid-list      */
  ).
  /*  */
  if rid-list <> ? AND rid-list <> "" THEN DO:
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-goods
&Scoped-define SELF-NAME BROWSE-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-goods Dialog-Frame
ON ROW-DISPLAY OF BROWSE-goods IN FRAME Dialog-Frame
DO:
  if available  buf_abc-analysis-goods then do:
    run proc-disp-goods in this-procedure .
    if v-Amin = "входит" then  v-Amin:fgcolor  in browse browse-goods  = 4.
    if buf_abc-analysis-goods.abcg-abc = "A" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 12
         {&col-p3}:fgcolor  in browse browse-goods  = 12
         {&col-p4}:fgcolor  in browse browse-goods  = 12
         {&col-p5}:fgcolor  in browse browse-goods  = 12
         {&col-p19}:fgcolor in browse browse-goods  = 12
       .
    if buf_abc-analysis-goods.abcg-abc = "B" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 9
         {&col-p3}:fgcolor  in browse browse-goods  = 9
         {&col-p4}:fgcolor  in browse browse-goods  = 9
         {&col-p5}:fgcolor  in browse browse-goods  = 9
         {&col-p19}:fgcolor in browse browse-goods  = 9
       .
    if buf_abc-analysis-goods.abcg-abc = "D" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 3
         {&col-p3}:fgcolor  in browse browse-goods  = 3
         {&col-p4}:fgcolor  in browse browse-goods  = 3
         {&col-p5}:fgcolor  in browse browse-goods  = 3
         {&col-p19}:fgcolor in browse browse-goods  = 3
       .
    if buf_abc-analysis-goods.abcg-abc = "E" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 5
         {&col-p3}:fgcolor  in browse browse-goods  = 5
         {&col-p4}:fgcolor  in browse browse-goods  = 5
         {&col-p5}:fgcolor  in browse browse-goods  = 5
         {&col-p19}:fgcolor in browse browse-goods  = 5
       .
    if buf_abc-analysis-goods.abcg-abc = "F" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 7
         {&col-p3}:fgcolor  in browse browse-goods  = 7
         {&col-p4}:fgcolor  in browse browse-goods  = 7
         {&col-p5}:fgcolor  in browse browse-goods  = 7
         {&col-p19}:fgcolor in browse browse-goods  = 7
       .


  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-goods Dialog-Frame
ON VALUE-CHANGED OF BROWSE-goods IN FRAME Dialog-Frame
DO:

  if available  buf_abc-analysis-goods then do:
     {&OPEN-QUERY-BROWSE-OBJ}
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-obj
&Scoped-define SELF-NAME BROWSE-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-obj Dialog-Frame
ON ROW-DISPLAY OF BROWSE-obj IN FRAME Dialog-Frame
DO:
 RUN DISP-OBJ.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_goods Dialog-Frame
ON CHOOSE OF MENU-ITEM m_goods /* По товарам */
DO:
  run print-proc in this-procedure ( NO ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_obj Dialog-Frame
ON CHOOSE OF MENU-ITEM m_obj /* По объектам */
DO:
  run print-proc in this-procedure ( true  ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-goods
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


on leave of Buf_abc-analysis-goods.abcg-abc in browse browse-goods DO:
run chg-abc in this-procedure  no-error .
if error-status :error then return no-apply.

END.


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name="browse-goods" }
{ gbl/f2.i browse-goods goods-recid init-gds-rec parParentProc }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BROWSE-obj :handle
  ) .
run diasize_init in this-procedure .

{ gbl/srt-clmd.i
  &browse-name   =  "browse-goods"
  &frame-name    =  "{&frame-name}"
  &table-name    =  "abc-analysis-goods"
  &label-clmn_1  =  "{&col-l1}"
  &label-clmn_2  =  "{&col-l2}"
  &label-clmn_3  =  "{&col-l3}"
  &label-clmn_4  =  "{&col-l4}"
  &label-clmn_5  =  "{&col-l5}"
  &label-clmn_6  =  "{&col-l6}"
  &label-clmn_7  =  "{&col-l7}"
  &label-clmn_8  =  "{&col-l8}"
  &label-clmn_9  =  "{&col-l9}"
  &label-clmn_10 =  "{&col-l10}"
  &label-clmn_11 =  "{&col-l11}"
  &label-clmn_12 =  "{&col-l12}"
  &label-clmn_13 =  "{&col-l13}"
  &label-clmn_14 =  "{&col-l14}"
  &label-clmn_15 =  "{&col-l15}"
  &label-clmn_19 =  "{&col-l19}"
  &sort-clmn_1   =  "{&col-p1}"
  &dyn_sort-clmn_1   =  "{&dyn_col-p1}"
  &sort-clmn_2   =  "{&col-p2}"
  &sort-clmn_3   =  "{&col-p3}"
  &sort-clmn_4   =  "{&col-p4}"
  &sort-clmn_5   =  "{&col-p5}"
  &sort-clmn_6   =  "{&col-p6}"
  &sort-clmn_7   =  "{&col-p7}"
  &sort-clmn_8   =  "{&col-p8}"
  &sort-clmn_9   =  "{&col-p9}"
  &sort-clmn_10  =  "{&col-p10}"
  &sort-clmn_11  =  "{&col-p11}"
  &sort-clmn_12  =  "{&col-p12}"
  &sort-clmn_13  =  "{&col-p13}"
  &sort-clmn_14  =  "{&col-p14}"
  &sort-clmn_15  =  "{&col-p15}"
  &sort-clmn_19  =  "{&col-p19}"
  &open-query    =  "run OpenBr (yes, no, '':U)."
  &open-query-otherwise = "run OpenBr (yes, no, '':U)."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no"
  }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    /*{ gbl/mv-clmn.i
    &browse-name = "browse-goods"
    &frame-name = "{&frame-name}"
    &ext-col = 19
    &start-column = 1
    } */

   buf_goods.artic:resizable in browse BROWSE-goods = true .
   buf_goods.gds-name:resizable in browse BROWSE-goods = true .
   v-izt:resizable in browse BROWSE-goods = true .
   buf_goods.artic:read-only in browse BROWSE-goods = true .

   v-ass-name:resizable in browse BROWSE-obj = true .
   v-obj-igt:resizable in browse BROWSE-obj = true .

   buf_goods.artic:resizable in browse BROWSE-goods = true .
   buf_goods.artic:width     in browse BROWSE-goods = v-size-col1 .
   buf_goods.gds-name:resizable in browse BROWSE-goods = true .
   buf_goods.gds-name:width     in browse BROWSE-goods = v-size-col2 .

   buf_goods.artic:read-only in browse BROWSE-goods = true .
   Buf_abc-analysis-goods.abcg-stock-price-acc:visible in browse BROWSE-goods = false .
   Buf_abc-analysis-goods.abcg-stock-price-sale:visible in browse BROWSE-goods = false.
   /*Buf_abc-analysis-goods.abcg-prcnt-account:visible in browse BROWSE-goods = false. */

ASSIGN b-print:POPUP-MENU IN FRAME {&frame-name} = MENU POPUP-MENU-B-print:HANDLE.
ASSIGN b-print:MENU-MOUSE = 1.


  RUN my_enable.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-prc Dialog-Frame
PROCEDURE calc-prc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-old as character no-undo .
define input  parameter p-new as character no-undo .
define input  parameter p-type as character no-undo .
define input  parameter p-all-sum as decimal   no-undo .
define input  parameter p-all-qnty as decimal   no-undo .
define input-output parameter  abc-prc-qnty  as decimal   no-undo .
define input-output parameter  abc-qnty      as decimal   no-undo .
define input-output parameter  abc-sum-prc   as decimal   no-undo .
define input-output parameter  abc-sum       as decimal   no-undo .
define input  parameter p-sum as decimal   no-undo .

if p-old  <> p-type and p-new <> p-type then return .

if p-old  = p-type then do:
    assign
      abc-qnty        = abc-qnty      - 1
      abc-sum         = abc-sum       - p-sum
      abc-sum-prc     = abc-sum  * 100 / p-all-sum
      abc-prc-qnty    = abc-qnty * 100 / p-all-qnty
    .

end.

if p-new  = p-type then do:
    assign
      abc-qnty        = abc-qnty      + 1
      abc-sum         = abc-sum       + p-sum
      abc-sum-prc     = abc-sum  * 100 / p-all-sum
      abc-prc-qnty    = abc-qnty * 100 / p-all-qnty
    .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-abc Dialog-Frame
PROCEDURE chg-abc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable old-val as character no-undo .
define variable v-all-sum  as decimal   no-undo .
define variable v-all-qnty as decimal   no-undo .

   old-val  = Buf_abc-analysis-goods.abcg-abc .

   if lookup ((Buf_abc-analysis-goods.abcg-abc:screen-value  in browse  browse-goods),"A,B,C,D,E,F") = 0 then do:
      message "Значение группы может быть только A B C D E F (латинские буквы)" view-as alert-box information .
       find current Buf_abc-analysis-goods exclusive-lock no-error .
       assign
       Buf_abc-analysis-goods.abcg-abc  = old-val.
      display Buf_abc-analysis-goods.abcg-abc with browse browse-goods .
      return error.
   end.

   IF  Buf_abc-analysis-goods.abcg-abc:screen-value  in browse  browse-goods  <> Buf_abc-analysis-goods.abcg-abc then do:
       message "Вы изменили группу " Buf_abc-analysis-goods.abcg-abc "на"
                caps ( Buf_abc-analysis-goods.abcg-abc:screen-value  in browse  browse-goods) skip
                "Сохранить изменение ?"
       view-as alert-box question
       BUTTONS yes-no
       TITLE "Изменение группы ABC"
       UPDATE v-ok  as logical   .

    if v-ok = false  then do:
       find current Buf_abc-analysis-goods exclusive-lock no-error .
       assign
       Buf_abc-analysis-goods.abcg-abc  = old-val.
    end.

    if v-ok = true   then do:
       find current Buf_abc-analysis-goods exclusive-lock no-error .
       if available Buf_abc-analysis-goods then do:
            assign
              Buf_abc-analysis-goods.abcg-abc-old = old-val
              Buf_abc-analysis-goods.abcg-abc = caps (Buf_abc-analysis-goods.abcg-abc:screen-value  in browse  browse-goods)
              .
              find current buf_abc-analysis exclusive-lock no-error .
              if available buf_abc-analysis then do:
                  v-all-sum  = buf_abc-analysis.abc-a-sum  + buf_abc-analysis.abc-b-sum  + buf_abc-analysis.abc-c-sum  + buf_abc-analysis.abc-d-sum  + buf_abc-analysis.abc-e-sum  + buf_abc-analysis.abc-f-sum.
                  v-all-qnty = buf_abc-analysis.abc-a-qnty + buf_abc-analysis.abc-b-qnty + buf_abc-analysis.abc-c-qnty + buf_abc-analysis.abc-d-qnty + buf_abc-analysis.abc-e-qnty + buf_abc-analysis.abc-f-qnty.
                  run calc-prc in this-procedure  (
                   input        Buf_abc-analysis-goods.abcg-abc-old
                  ,input        Buf_abc-analysis-goods.abcg-ABC
                  ,input        "A"
                  ,input        v-all-sum
                  ,input        v-all-qnty
                  ,input-output buf_abc-analysis.abc-a-prc-qnty
                  ,input-output buf_abc-analysis.abc-a-qnty
                  ,input-output buf_abc-analysis.abc-a-sum-prc
                  ,input-output buf_abc-analysis.abc-a-sum
                  ,input        Buf_abc-analysis-goods.abcg-sum-for-estimate
                   ).
                  run calc-prc in this-procedure  (
                   input        Buf_abc-analysis-goods.abcg-abc-old
                  ,input        Buf_abc-analysis-goods.abcg-ABC
                  ,input        "B"
                  ,input        v-all-sum
                  ,input        v-all-qnty
                  ,input-output buf_abc-analysis.abc-b-prc-qnty
                  ,input-output buf_abc-analysis.abc-b-qnty
                  ,input-output buf_abc-analysis.abc-b-sum-prc
                  ,input-output buf_abc-analysis.abc-b-sum
                  ,input        Buf_abc-analysis-goods.abcg-sum-for-estimate
                   ).
                  run calc-prc in this-procedure  (
                   input        Buf_abc-analysis-goods.abcg-abc-old
                  ,input        Buf_abc-analysis-goods.abcg-ABC
                  ,input        "C"
                  ,input        v-all-sum
                  ,input        v-all-qnty
                  ,input-output buf_abc-analysis.abc-c-prc-qnty
                  ,input-output buf_abc-analysis.abc-c-qnty
                  ,input-output buf_abc-analysis.abc-c-sum-prc
                  ,input-output buf_abc-analysis.abc-c-sum
                  ,input        Buf_abc-analysis-goods.abcg-sum-for-estimate
                   ).
                  run calc-prc in this-procedure  (
                   input        Buf_abc-analysis-goods.abcg-abc-old
                  ,input        Buf_abc-analysis-goods.abcg-ABC
                  ,input        "D"
                  ,input        v-all-sum
                  ,input        v-all-qnty
                  ,input-output buf_abc-analysis.abc-d-prc-qnty
                  ,input-output buf_abc-analysis.abc-d-qnty
                  ,input-output buf_abc-analysis.abc-d-sum-prc
                  ,input-output buf_abc-analysis.abc-d-sum
                  ,input        Buf_abc-analysis-goods.abcg-sum-for-estimate
                   ).
                  run calc-prc in this-procedure  (
                   input        Buf_abc-analysis-goods.abcg-abc-old
                  ,input        Buf_abc-analysis-goods.abcg-ABC
                  ,input        "E"
                  ,input        v-all-sum
                  ,input        v-all-qnty
                  ,input-output buf_abc-analysis.abc-e-prc-qnty
                  ,input-output buf_abc-analysis.abc-e-qnty
                  ,input-output buf_abc-analysis.abc-e-sum-prc
                  ,input-output buf_abc-analysis.abc-e-sum
                  ,input        Buf_abc-analysis-goods.abcg-sum-for-estimate
                   ).
                  run calc-prc in this-procedure  (
                   input        Buf_abc-analysis-goods.abcg-abc-old
                  ,input        Buf_abc-analysis-goods.abcg-ABC
                  ,input        "F"
                  ,input        v-all-sum
                  ,input        v-all-qnty
                  ,input-output buf_abc-analysis.abc-f-prc-qnty
                  ,input-output buf_abc-analysis.abc-f-qnty
                  ,input-output buf_abc-analysis.abc-f-sum-prc
                  ,input-output buf_abc-analysis.abc-f-sum
                  ,input        Buf_abc-analysis-goods.abcg-sum-for-estimate
                   ).
              end.
       end.
    end.
   end.
   display Buf_abc-analysis-goods.abcg-abc with browse browse-goods no-error .
   apply "ROW-DISPLAY" to browse-goods in frame {&frame-name}.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DISP-OBJ Dialog-Frame
PROCEDURE DISP-OBJ :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf2_assortment-matrix for ub.assortment-matrix.
define variable         v-gdop-min-stock     as decimal   no-undo .
define variable         v-grop-max-stock     as decimal   no-undo .
define variable         v-grop-level-always-presence as decimal   no-undo .
define variable         v-grop-min-order             as decimal   no-undo .
      v-ass-name = "" .
      IF AVAILABLE buf_assortment-matrix-goods  THEN DO:
          find first buf2_assortment-matrix no-lock where
                     buf2_assortment-matrix.asmt-id  =  buf_assortment-matrix-goods.asmt-id AND
                     buf2_assortment-matrix.db-num   =  buf_assortment-matrix-goods.db-num no-error .
                     if available buf2_assortment-matrix
                        then  v-ass-name = buf2_assortment-matrix.asmt-name .
      END.

      if available buf_abc-analysis-obj and available buf_abc-analysis-goods then do:
          { gbl/gdsobjpr.i
            buf_abc-analysis-obj.obj-type
            buf_abc-analysis-obj.obj-code
            ?
            ?
            ?
            buf_abc-analysis-goods.gds-code
            v-obj-AssMin
            v-obj-igt
            v-gdop-min-stock
            v-grop-max-stock
            v-grop-level-always-presence
            v-grop-min-order
            }
      end.



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
  ENABLE B-cancel B-mark B-save B-chg-izt B-add-AM B-del-AM B-spis-ord
         b-filter-ext B-Help B-chg-ABC B-add-AMin B-del-AMin B-ord B-print
         BROWSE-goods BROWSE-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-gds-rec Dialog-Frame
PROCEDURE init-gds-rec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
gds-rec = recid (buf_goods) .
find first goods no-lock  where recid(goods)  = gds-rec no-error .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-gds-list Dialog-Frame
PROCEDURE make-gds-list :
do
  on error undo, return error return-value
  :
define buffer buf2_goods for ub.goods.
define buffer buf2_abc-analysis-goods for ub.abc-analysis-goods.
define variable v-kol as integer   no-undo .
define variable i as integer   no-undo .

  /* формирование gds-list */
run waitfram-show in this-procedure ( "Подготовка временных таблиц.... ") .
    for each gds-list : delete gds-list. end.
    v-kol = num-entries( rid-list ) .
    repeat i = 1 to v-kol :
      find first buf2_abc-analysis-goods no-lock where recid(buf2_abc-analysis-goods) = integer(entry(i,rid-list)) no-error .
      if available buf2_abc-analysis-goods then do:
          find first buf2_goods no-lock where buf2_goods.gds-code = buf2_abc-analysis-goods.gds-code no-error .
          if available buf2_goods then do:
              create gds-list.
              BUFFER-COPY buf2_goods TO gds-list .
          end.
      end.
    end.
 run waitfram-hide in this-procedure .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer Buf2_abc-analysis-obj for ub.abc-analysis-obj.
hide B-chg-ABC in frame {&frame-name} .
  ENABLE B-Cancel
         B-mark
         B-save
         B-chg-izt
         B-add-AM
         B-del-AM
         B-spis-ord
         B-Help
         B-add-AMin
         B-del-AMin
         B-ord
         B-print
         b-filter-ext
         BROWSE-goods
         BROWSE-obj
      WITH FRAME Dialog-Frame.
  view frame dialog-frame.
  FOR EACH Buf2_abc-analysis-obj WHERE
           Buf2_abc-analysis-obj.abc-id = v-id AND
           Buf2_abc-analysis-obj.db-num = v-db-num     NO-LOCK :
    run create_obj-list in this-procedure (Buf2_abc-analysis-obj.obj-type , Buf2_abc-analysis-obj.obj-code ) .
  end.
  run openbr in this-procedure (yes, no, '':u).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OPenbr Dialog-Frame
PROCEDURE OPenbr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define buffer buff_contract for contract.
define variable loc_contract-code as character no-undo .



{&SetCursorWait}
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


&scop flt-open-open-query OPEN QUERY browse-goods ~
FOR EACH Buf_abc-analysis-goods no-lock use-index sort-pcnt

&scop flt-open-dyn_open-query  FOR EACH Buf_abc-analysis-goods

&scop flt-open-query-handle query BROWSE-goods:handle

&scop flt-open-find-buffer-name Buf_abc-analysis-goods

&scop flt-open-open-query-tail      , EACH buf_goods OF ub.Buf_abc-analysis-goods NO-LOCK ~
, first temp-trn-doc where (r-2 = 1 or buf_goods.gds-code = temp-trn-doc.gds-code )

&scop flt-open-dyn_open-query-tail   substitute(' , EACH buf_goods OF ub.Buf_abc-analysis-goods NO-LOCK ~
, first temp-trn-doc where ( &1 = 1 or buf_goods.gds-code = temp-trn-doc.gds-code )',  r-2 )



&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          Buf_abc-analysis-goods

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer Buf_abc-analysis-goods for abc-analysis-goods.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .

      { gbl/fltopend.i
        &where-cond     = " Buf_abc-analysis-goods.abc-id = v-id  and Buf_abc-analysis-goods.db-num = v-db-num  "
        &dyn_where-cond = " substitute(' Buf_abc-analysis-goods.abc-id = &1 and Buf_abc-analysis-goods.db-num = &2 ' , v-id , v-db-num ) "
        &use-ind    = "  "
        &by         = "  " }

if not p-open-query AND  doc-rec <> ? then DO:
REPOSITION browse-goods to recid doc-rec No-ERROR.
END.


{&SetCursorNo}
{&OPEN-QUERY-BROWSE-obj}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-proc Dialog-Frame
PROCEDURE print-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-obj as logical   no-undo .

define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.

  
/*Печать HTML*/
           run get-report-num (
            output p-report-id
        ).
        
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
    /*шапка*/
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
    put stream OutStr-html unformatted
             "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip

                '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
                '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
                '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            .

 /*определяем кол-во колонок*/

    put stream OutStr-html unformatted
        '<body>' skip
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        '<TR class="set_columns">'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 150px;"></TD>'skip
            '<TD style="width: 30px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="17" STYLE="font-size: 14px;">Вн.Код     :' + string(buf_abc-analysis.abc-id) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="17" STYLE="font-size: 14px;">Название   :' + string(buf_abc-analysis.abc-name) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="17" STYLE="font-size: 14px;">Критерий   :' + string(buf_criterion-analysis.cral-name) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="17" STYLE="font-size: 14px;">Коментарии :' + string(buf_abc-analysis.abc-des) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="17" STYLE="font-size: 14px;">Создание анализа :' + string(buf_abc-analysis.abc-date-create,"99.99.9999") + '' + string(buf_abc-analysis.abc-time-create,"hh:mm") + '' + buf_abc-analysis.abc-who-create + '</TD>' skip
        '</TR>'skip
    .        
  
  
     
    define buffer bufp_abc-analysis-obj for ub.abc-analysis-obj.
    define VARIABLE v-obj as character no-undo .

    for each bufp_abc-analysis-obj no-lock where bufp_abc-analysis-obj.db-num = buf_abc-analysis.db-num and
                                                 bufp_abc-analysis-obj.abc-id = buf_abc-analysis.abc-id :
       v-obj = v-obj + "," + trim(bufp_abc-analysis-obj.obj-type) + " " + trim(string(bufp_abc-analysis-obj.obj-code)) . 
    end.

    v-obj = TRIM (v-obj,",") .
    
        put stream OutStr-html unformatted            
        '<TR>'skip
            '<TD colspan="17" STYLE="font-size: 14px;">Объекты    :' + string(v-obj) + '</TD>' skip
        '</TR>'skip       
        .
        
    define buffer bufp_abc-analysis-period for ub.abc-analysis-period.
    define VARIABLE v-period as character no-undo .

    for each bufp_abc-analysis-period no-lock where bufp_abc-analysis-period.db-num = buf_abc-analysis.db-num and
                                                    bufp_abc-analysis-period.abc-id = buf_abc-analysis.abc-id :
       v-period = v-period + "," + string(bufp_abc-analysis-period.abcp-start,"99.99.9999") + "-" + string(bufp_abc-analysis-period.abcp-end,"99.99.9999") .
    end.
        v-period = TRIM (v-period,",") .
    
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="17" STYLE="font-size: 14px;">Периоды    :' + string(v-period) + '</TD>' skip
        '</TR>'skip       
        .
        
    define buffer bufp_abc-analysis-doc for ub.abc-analysis-doc.
    define VARIABLE v-doc-type as character no-undo .

    for each bufp_abc-analysis-doc no-lock where bufp_abc-analysis-doc.db-num = buf_abc-analysis.db-num and
                                                 bufp_abc-analysis-doc.abc-id = buf_abc-analysis.abc-id :
       v-doc-type = v-doc-type + "," + func-get-name-from-ext-type( bufp_abc-analysis-doc.abcd-ext-doc-type , false ) .
    end.

        v-doc-type = TRIM (v-doc-type,",") .

        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="17" STYLE="font-size: 14px;">Типы документов  :' + string(v-doc-type) + '</TD>' skip
        '</TR>'skip
        .
        
        put stream OutStr-html unformatted                       
        '</thead>'skip
    .

       put stream OutStr-html unformatted
        '<tbody>'
        '<TR>'skip
            '<TH style="text-align: center;">Артикул</TH>'skip
            '<TH style="text-align: center;">Название</TH>'skip
            '<TH style="text-align: center;">ABC</TH>'skip
            '<TH style="text-align: center;">% по критерию</TH>'skip
            '<TH style="text-align: center;">Сумма для оценки по критерию</TH>'skip
            '<TH style="text-align: center;">ИЖТ</TH>'skip
            '<TH style="text-align: center;">Ассорт. min</TH>'skip
            '<TH style="text-align: center;">Ассорт. матрица</TH>'skip
            '<TH style="text-align: center;">Кол-во по реализац</TH>'skip
            '<TH style="text-align: center;">Остаток кол-во</TH>'skip
            '<TH style="text-align: center;">Остаток товара в учет.ценах</TH>'skip
            '<TH style="text-align: center;">Остаток товара в продаж.ценах</TH>'skip
            '<TH style="text-align: center;">Сумма реализ. в учет.ценах</TH>'skip
            '<TH style="text-align: center;">Сумма реализ. в прод.ценах</TH>'skip
            '<TH style="text-align: center;">Сумма реализ. в ценах докум.</TH>'skip
            '<TH style="text-align: center;">Темп продаж среднесут</TH>'skip
            '<TH style="text-align: center;">Заказ кол-во товара </TH>'skip
        '</TR>'skip
        .
    
    define variable ii as integer no-undo .
                if p-obj = true then do:
               {&OPEN-QUERY-BROWSE-obj}
                DO WHILE available Buf_abc-analysis-obj :
                    ii = ii + 1 .    
                get next browse-obj.
                end.
                end.            
                ii = ii + 1 .
                
     run OpenBR in this-procedure (yes, no, '':U).
     DO WHILE available Buf_abc-analysis-goods :

        run prt-goods in this-procedure .
        
             put stream OutStr-html unformatted
                              '<TR>'skip
                                  '<TD rowspan="' + string(ii) + '"> ' + string(buf_goods.artic) + '</TD>'skip
                                  '<TD> ' + string(buf_goods.gds-name) + '</TD>'skip
                                  '<TD rowspan="' + string(ii) + '"> ' + string(Buf_abc-analysis-goods.abcg-abc) + '</TD>'skip
                                  '<TD rowspan="' + string(ii) + '" num="0.000" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-prcnt-for-estimate,"->>>>>>>>>>>9.999",3) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-prcnt-for-estimate <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-prcnt-for-estimate,"->>>>>>>>>>>9.999",3) + '</TD>' else "" + '</td>' skip
                                  '<TD rowspan="' + string(ii) + '" num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-sum-for-estimate,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-sum-for-estimate <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-sum-for-estimate,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD> ' + string(v-izt) + '</TD>'skip
                                  '<TD> ' + string(v-Amin) + '</TD>'skip
                                  '<TD> ' + string(v-Acc-mat) + '</TD>'skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-qnty <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-stock-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-stock-qnty <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-stock-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD rowspan="' + string(ii) + '" num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-stock-price-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-stock-price-acc <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-stock-price-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-stock-price-sale,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-stock-price-sale <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-stock-price-sale,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-sum-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-sum-acc <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-sum-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-sum-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-sum-cur <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-sum-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-sum-doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-sum-doc <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-sum-doc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-temp-sale-goods <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                                  '<TD rowspan="' + string(ii) + '" num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-order-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-goods.abcg-order-qnty <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-goods.abcg-order-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                              '</TR>'skip    
                              .       
        

            if p-obj = true then do:
               /* расшифровка по объектам */
               {&OPEN-QUERY-BROWSE-obj}
                DO WHILE available Buf_abc-analysis-obj :
                    run disp-obj in this-procedure .

                    put stream OutStr-html unformatted
                              '<TR>'skip
                                  '<TD> ' + string(Buf_abc-analysis-obj.obj-type + " " + string(Buf_abc-analysis-obj.obj-code)) + '</TD>'skip
                                  '<TD> ' + string(v-obj-igt) + '</TD>'skip
                                  '<TD> ' + string( v-obj-AssMin , "да/нет" ) + '</TD>'skip
                                  '<TD> ' + string(v-ass-name) + '</TD>'skip
                                  .
                    if AVAILABLE buf_abc-analysis-gds-obj then do:
                    put stream OutStr-html unformatted              
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-gds-obj.abog-qnty <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-stock-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-gds-obj.abog-stock-qnty <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-stock-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(buf_abc-analysis-gds-obj.abog-price-crc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if buf_abc-analysis-gds-obj.abog-price-crc <> ? then fnc-convert-dot-to-colon(buf_abc-analysis-gds-obj.abog-price-crc,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-sum-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-gds-obj.abog-sum-acc <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-sum-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-sum-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-gds-obj.abog-sum-cur <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-sum-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-sum-doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-gds-obj.abog-sum-doc <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-sum-doc,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_abc-analysis-gds-obj.abog-temp-sale-goods <> ? then fnc-convert-dot-to-colon(Buf_abc-analysis-gds-obj.abog-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                              '</TR>'skip    
                              .
                    end.
                    else do:
                    put stream OutStr-html unformatted                        
                                  '<TD style="text-align: right">' + "?" + '</TD>'skip
                                  '<TD style="text-align: right">' + "?" + '</TD>'skip
                                  '<TD style="text-align: right">' + "?" + '</TD>' skip
                                  '<TD style="text-align: right">' + "?" + '</TD>' skip
                                  '<TD style="text-align: right">' + "?" + '</TD>' skip
                                  '<TD style="text-align: right">' + "?" + '</TD>' skip
                                  '<TD style="text-align: right">' + "?" + '</TD>' skip
                              '</TR>'skip    
                              .
                        
                    end.    

                        get next browse-obj.
                END.

            end.

            GET next BROWSE-goods.
      END.
   put stream OutStr-html unformatted
                                '</tbody>' skip
                                '</table>' skip
                                '</body>' skip
                                '</html>' skip
                                .
output stream OutStr-html close.                                
                                                          
  run prn-lib-reportviewer-report-name in this-procedure (
                                                          input parParentProc
                                                          ,input v-file-name-rep-htm
                                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cgh-Am Dialog-Frame
PROCEDURE proc-cgh-Am :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
    do
    on error undo, return error return-value
    :

define input  parameter v-new as logical   no-undo .

define buffer buf_matrix                  for  ub.assortment-matrix .
define buffer buf2_assortment-matrix-goods for ub.assortment-matrix-goods .

define buffer buf_gds-obj for ub.gds-obj.
define variable p-doc-rec as recid no-undo .
define variable v-sts as integer   no-undo .
/*  */
DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta as INTEGER   NO-UNDO INITIAL 0.
/*  */

v-err-ext = false  .
v-longchar = "" .
{ ref/clearlm.i }

 run make-gds-list in this-procedure .
 for each obj-list :
      Label-AM:
      for each  buf_matrix no-lock where
          buf_matrix.asmt-status = 0 and
          buf_matrix.obj-type = obj-list.obj-type and
          buf_matrix.obj-code = obj-list.obj-code :
           if v-new = true then do:
              run waitfram-show in this-procedure  ("Добавление товаров в ассортиментную матрицу  "  +
                                                  buf_matrix.asmt-name +
                                                  "  на объекте " +
                                                  string( obj-list.obj-code )) .
          end.
          else do:
              run waitfram-show in this-procedure  ("Удаление товаров из ассортиментную матрицу  "  +
                                                  buf_matrix.asmt-name +
                                                  "  на объекте " +
                                                  string( obj-list.obj-code )) .
          end.
          /* M - CT  Cюда добавляем проверку на % отклонения матрицы от шаблона !!!  */
          if v-new = true then do:
             /* Параметры снимаем общей процедурой  */
             RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
                 buf_matrix.asmt-id,
                 buf_matrix.db-num,
                 OUTPUT cError
                 ).
             if cError <> "" THEN DO:
                v-err-ext = true .
                v-longchar = v-longchar + cError + {&new-line}.
                NEXT Label-AM.
             END.
             /* Подсчет дельты от выбранных товаров  */
             { ref/ass-mat.i
                   &DEF_CALC_DELTA_BUF=YES
                   &BUF_LIST=gds-list
                   &VAR_ASMT-ID=buf_matrix.Asmt-id
                   &VAR_DB-NUM=buf_matrix.db-num
                   &VAR_DELTA=iDelta
             }
             /* Проверка допустимого % отклонения   */
             RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
                 iDelta,
                 OUTPUT cError
                 ).
             if cError <> "" THEN DO:
                v-err-ext = true .
                v-longchar = v-longchar + cError + {&new-line}.
                NEXT Label-AM.
             END.

          END.
          /*  */
          for each gds-list :
                if v-new = true then do:
                    { ref/gds-mat1.i
                      this-procedure
                      p-doc-rec
                      {&add-def}
                      buf_matrix.asmt-id
                      buf_matrix.db-num
                      gds-list.gds-code
                      "''"
                      no-error
                    }
                    if error-status :error then do:
                      v-err-ext = true .
                      v-longchar = v-longchar + return-value + {&new-line}.
                    end.
                end.
                else do:
                  find first buf2_assortment-matrix-goods no-lock where
                             buf2_assortment-matrix-goods.asmt-id  = buf_matrix.asmt-id and
                             buf2_assortment-matrix-goods.db-num   = buf_matrix.db-num  and
                             buf2_assortment-matrix-goods.gds-code = gds-list.gds-code  and
                             buf2_assortment-matrix-goods.asmg-status = 0
                             no-error .
                              if available buf2_assortment-matrix-goods then do:
                                  v-sts = int({&deleted-status-int}) .
                                  { ref/gds-mat2.i
                                    this-procedure
                                    recid(buf2_assortment-matrix-goods)
                                    v-sts
                                    no
                                    no-error
                                    }
                                  if error-status :error then dO:
                                      v-err-ext = true .
                                      v-longchar = v-longchar + return-value + {&new-line}.
                                  end.
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
      + 'title=При изменениях Ассортиментных матриц из ABC \':u
      + 'Editor_col=1\':u
      + 'Editor_width=96\':u
      + 'Editor_height=21\':u
      + 'readonly=yes\':u
    ,input-output v-longchar
    ,output v-ok ) no-error .
    v-longchar = "" .
    { ref/clearlm.i }

end.

run OpenBr in this-procedure (yes, no, '':U).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cgh-Amin Dialog-Frame
PROCEDURE proc-cgh-Amin :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
    do
    on error undo, return error return-value
    :
define input  parameter v-new as logical   no-undo .
  run make-gds-list in this-procedure  .
  run ref/chg-amin.p ( input v-new ) no-error  .
      if error-status :error then
          message vss-workfile vss-revision vss-description skip
          error-status :get-message(1)
          return-value
          .
  run OpenBr in this-procedure (yes, no, '':U).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chg-abc Dialog-Frame
PROCEDURE proc-chg-abc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:   измененме группы и пересчет итоговых количеств в шапке ABC
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chg-igt Dialog-Frame
PROCEDURE proc-chg-igt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
    do
    on error undo, return error return-value
    :
define variable  v-old as character no-undo .
define variable  v-new as character no-undo .

  run make-gds-list in this-procedure  .
  run ref/graf-igt.w
  ( output v-old, output v-new ).

  if not(v-old = "" and v-new = "")  then do:
      run ref/chg-igt.p
       ( input v-old, input v-new , input true ) no-error  .
          if error-status :error then
              message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              return-value
              .
  end.
run OpenBr in this-procedure (yes, no, '':U).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-disp-goods Dialog-Frame
PROCEDURE proc-disp-goods :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable   v-old-izt  as character no-undo .
define variable   v-old-amin  as character no-undo .
define variable   v-old-acc-mat  as character no-undo .
define variable   v-new-izt  as character no-undo .
define variable   v-new-amin  as character no-undo .
define variable   v-new-acc-mat  as character no-undo .

define variable vt-Amin as character no-undo .
    assign
    v-old-izt  = ""
    v-izt      = ""
    v-Amin     = ""
    v-old-Amin = ""
    v-acc-mat     =  ""
    v-old-acc-mat = ""
    .

{&OPEN-QUERY-BROWSE-obj}
    GET next BROWSE-obj.
    assign
    v-old-izt      =  if not available Buf_gds-obj-prop then "" else  Buf_gds-obj-prop.gdop-igt
    v-izt          =  if not available Buf_gds-obj-prop then "" else Buf_gds-obj-prop.gdop-igt
    v-Amin         =  if not available Buf_gds-obj-prop then "" else string (Buf_gds-obj-prop.gdop-assort-min)
    v-old-Amin     =  if not available Buf_gds-obj-prop then "" else string (Buf_gds-obj-prop.gdop-assort-min)
    v-acc-mat      =  if not available buf_assortment-matrix-goods then "" else string (buf_assortment-matrix-goods.asmt-id)
    v-old-acc-mat  =  if not available buf_assortment-matrix-goods then "" else string (buf_assortment-matrix-goods.asmt-id)
    no-error
    .
    if v-old-Amin = ?    or
        v-old-Amin = "no" or
        v-old-Amin = "?"  or
        v-old-Amin = ""   then v-old-Amin = "" .

    if v-izt = ? or v-izt = "" then v-izt = {&ass-izd-empty} .
    if v-old-izt = ? or v-old-izt = "" then v-old-izt = {&ass-izd-empty} .

    if v-Amin = ? or v-Amin = 'no' or v-Amin = "?" or v-Amin = "" then v-Amin = "не входит" .
       else v-Amin = "входит" .

    if v-acc-mat = ? or v-acc-mat = ""  then v-acc-mat = "не входит" .
       else v-acc-mat = "входит" .




    DO WHILE AVAILABLE(Buf_abc-analysis-obj):
    assign
        v-new-izt      =  if not available Buf_gds-obj-prop then {&ass-izd-empty} else  Buf_gds-obj-prop.gdop-igt
        v-new-Amin     =  if not available Buf_gds-obj-prop then "" else string (Buf_gds-obj-prop.gdop-assort-min)
        v-new-acc-mat  =  if not available buf_assortment-matrix-goods then "" else string (buf_assortment-matrix-goods.asmt-id)
        no-error.

        if v-new-izt <> ? then
        if v-old-izt     <> v-new-izt  then  v-izt = "разное" .

        vt-amin = v-new-amin .
        if vt-Amin = ?    or
           vt-Amin = 'no' or
           vt-Amin = "?"  or
           vt-Amin = "" then vt-Amin = "" .

        if v-old-Amin    <> vt-Amin  then  v-Amin = "разное" .
        if v-old-acc-mat <> v-new-acc-mat
          and (v-old-acc-mat = ? or v-new-acc-mat = ? or v-new-acc-mat = "" )
          then  v-acc-mat = "разное" .

      assign
        v-old-izt     = v-new-izt
        v-old-Amin    = v-new-Amin
        v-old-acc-mat = v-new-acc-mat
      .
        if v-old-Amin = ? or
           v-old-Amin = 'no' or
           v-old-Amin = "?" or
           v-old-Amin = "" then v-old-Amin = "" .
        if v-old-izt = ? or v-old-izt = "" then v-old-izt = {&ass-izd-empty} .

      GET NEXT BROWSE-obj.
    END. /* DO WHILE AVAIL(Buf_abc-analysis-obj) */



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-list-doc as character no-undo .
  define variable v-list-obj as character no-undo .
  define variable v-possb-keep-string-obj as logical   no-undo .
  define variable v-string-obj            as character no-undo .
  define variable v-hash-string-obj       as character no-undo .
  define variable v-recid as recid  no-undo .

  define buffer x-abc-analysis for ub.abc-analysis.
  define buffer x-abc-analysis-obj for ub.abc-analysis-obj .
  define buffer x-abc-analysis-doc for ub.abc-analysis-doc .
  run waitfram-show in this-procedure ( "Сохранение анализа по умолчанию ... ") .
  v-list-obj = "" .
  find first x-abc-analysis no-lock  where
             x-abc-analysis.abc-id  = v-id and
             x-abc-analysis.db-num  = v-db-num  no-error .
             if error-status :error then return .

  for each  x-abc-analysis-obj no-lock
      where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-obj.db-num = x-abc-analysis.db-num  :
            v-list-obj = v-list-obj + x-abc-analysis-obj.obj-type + string(x-abc-analysis-obj.obj-code) + "," .
  end.

  run find-from-hash  in this-procedure  (
     input v-list-obj
    ,input "rang-abc-def"
    ,input "raad-possb-keep-string-obj"
    ,input "raad-string-obj"
    ,input "raad-hash-string-obj"
    ,input "rang-abc-def-obj"
    ,output v-recid
    ).

  run update-rang-def  in this-procedure (
     input v-recid
    ,input v-list-obj
    ,input x-abc-analysis.abc-a
    ,input x-abc-analysis.abc-b
    ,input x-abc-analysis.abc-c
    ,input x-abc-analysis.abc-d
    ,input x-abc-analysis.abc-e
    ,input x-abc-analysis.abc-f

    ).

  v-list-doc = "".


  for each x-abc-analysis-doc no-lock
      where x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-doc.db-num = x-abc-analysis.db-num  :
            v-list-doc = v-list-doc + x-abc-analysis-doc.abcd-ext-doc-type  + "," .
  end.


  run find-from-hash in this-procedure   (
     input v-list-obj
    ,input "doc-abc-def"
    ,input "doad-possb-keep-string-obj"
    ,input "doad-string-obj"
    ,input "doad-hash-string-obj"
    ,input "doc-abc-def-obj"
    ,output v-recid
    ).

  run update-doc-def in this-procedure  (
     input v-recid
    ,input v-list-obj
    ,input v-list-doc
    ).
  run waitfram-hide in this-procedure  .
  define variable p-ok as logical   no-undo .

    run save-def-analysis-obj in this-procedure  (
      input "abc"
    , input x-abc-analysis.db-num
    , input x-abc-analysis.abc-id
    , output p-ok) .
   if p-ok then message
   "Интервалы ранжирования и типы документов запомнены для данного списка объектов по умолчанию" skip
   "Этот анализ будет использоваться в отчетах как анализ по умолчанию" skip
   x-abc-analysis.abc-id skip
   x-abc-analysis.abc-name
  view-as alert-box information .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prt-goods Dialog-Frame
PROCEDURE prt-goods :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable   v-old-izt  as character no-undo .
define variable   v-old-amin  as character no-undo .
define variable   v-old-acc-mat  as character no-undo .
define variable vt-Amin as character no-undo .
define variable t-izt as character no-undo .
define variable t-Amin as character no-undo .
define variable t-asm as character no-undo .
define variable         v-gdop-min-stock     as decimal   no-undo .
define variable         v-grop-max-stock     as decimal   no-undo .
define variable         v-grop-level-always-presence as decimal   no-undo .
define variable         v-grop-min-order             as decimal   no-undo .

    assign
    v-old-izt  = ""
    v-izt      = ""
    v-Amin     = ""
    v-old-Amin = ""
    v-acc-mat     =  ""
    v-old-acc-mat = ""
    .


define buffer buf2_abc-analysis-gds-obj for ub.abc-analysis-gds-obj   .
define buffer buf2_assortment-matrix for ub.assortment-matrix.
define buffer buf2_assortment-matrix-goods for ub.assortment-matrix-goods.
define variable fl as logical   no-undo .
fl = true .
for each buf_abc-analysis-obj where
         buf_abc-analysis-obj.abc-id = v-id and
         buf_abc-analysis-obj.db-num = v-db-num
         no-lock
            :
            find first buf2_abc-analysis-gds-obj where
                        buf2_abc-analysis-gds-obj.obj-type = buf_abc-analysis-obj.obj-type and
                        buf2_abc-analysis-gds-obj.obj-code = buf_abc-analysis-obj.obj-code and
                        buf2_abc-analysis-gds-obj.gds-code = buf_abc-analysis-goods.gds-code and
                        buf2_abc-analysis-gds-obj.abc-id   = v-id and
                        buf2_abc-analysis-gds-obj.db-num   = v-db-num
                        no-lock no-error .
                find first buf2_assortment-matrix where
                      buf2_assortment-matrix.asmt-status        = 0  and
                      buf2_assortment-matrix.obj-type =  buf_abc-analysis-obj.obj-type and
                      buf2_assortment-matrix.obj-code =  buf_abc-analysis-obj.obj-code
                      no-lock no-error .
                find first buf2_assortment-matrix-goods where
                      buf2_assortment-matrix-goods.asmg-status        = 0  and
                      buf2_assortment-matrix-goods.asmt-id  =  buf2_assortment-matrix.asmt-id and
                      buf2_assortment-matrix-goods.db-num   =  buf2_assortment-matrix.db-num  and
                      buf2_assortment-matrix-goods.gds-code =  buf_abc-analysis-goods.gds-code
                      no-lock no-error .
                if available buf_abc-analysis-goods and available buf_abc-analysis-obj then do:
                 { gbl/gdsobjpr.i
                 buf_abc-analysis-obj.obj-type
                 buf_abc-analysis-obj.obj-code
                 ?
                 ?
                 ?
                 Buf_abc-analysis-goods.gds-code
                 t-amin
                 t-izt
                  v-gdop-min-stock
                  v-grop-max-stock
                  v-grop-level-always-presence
                  v-grop-min-order
                 }
                 end.
             if not available buf2_assortment-matrix-goods then t-asm = "0" .
                                                           else t-asm = "1".

            if fl = true then do:
                  assign
                  fl = false
                  v-old-izt  =  t-izt
                  v-izt      =  t-izt
                  v-Amin     =  t-amin
                  v-old-Amin =  t-amin
                  v-acc-mat     =  t-asm
                  v-old-acc-mat =  t-asm
                  .

                  if  v-Amin = 'no'  then v-Amin = "не входит" .
                                     else v-Amin = "входит" .
                  if v-acc-mat = "0" then v-acc-mat = "не входит" .
                                     else v-acc-mat = "входит" .
            end.

        if v-old-izt     <> t-izt            then  v-izt = "разное" .
        if v-old-Amin    <> t-Amin           then  v-Amin = "разное" .
        if v-old-acc-mat <> t-asm            then  v-acc-mat = "разное" .

      assign
        v-old-izt     = t-izt
        v-old-Amin    = t-Amin
        v-old-acc-mat = t-asm
      .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-report-num automain
PROCEDURE get-report-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-report-num as integer no-undo .

  do
  on error undo, return error return-value
  :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-buf FOR abc-analysis-goods, input mark-list as character  ) :
    RETURN ( IF LOOKUP( STRING( RECID( loc-buf ) ), mark-list ) > 0 THEN "*" ELSE "":U ).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME