&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_assortment-matrix FOR ub.assortment-matrix.
DEFINE BUFFER buf_assortment-matrix-goods FOR ub.assortment-matrix-goods.
DEFINE BUFFER Buf_gds-obj-prop FOR ub.gds-obj-prop.
DEFINE NEW SHARED BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_XYZ-analysis FOR ub.XYZ-analysis.
define buffer buf_XYZ-analysis-attr FOR ub.xyz-analysis-attr.
DEFINE BUFFER buf_XYZ-analysis-gds-obj FOR ub.XYZ-analysis-gds-obj.
DEFINE NEW SHARED BUFFER Buf_XYZ-analysis-goods FOR ub.XYZ-analysis-goods.
DEFINE BUFFER Buf_XYZ-analysis-obj FOR ub.XYZ-analysis-obj.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр результатов XYZ анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 04/26/05
*/
define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter v-id as integer   no-undo .
define input  parameter v-db-num as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр результатов XYZ анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i   }
{ gbl/waitfram.i }
{ cmp/obj-list.i  new  }
{ cmp/gds-list.i gds-list def "new shared"}
{ cmp/doc-list.i doc-list def "new shared" }
{ gbl/cur-time.i }
{ ref/def-hash.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ rep/gn-extp.i  }  /*Процедуры для определения имени расширенного типа документов*/
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ ref/gds-matl.i }
{ str/ascorrm.i  }
{ gbl/assmatat.i }   /* Библиотека для работы с атрибутами АМ */
{ gbl/thbj-def.i }
{ ref/ass-mat.i &DEF_PROC=YES}    /* Процедуры и функции для работы с АМ (по задаче "Процент отклонения матрицы от шаблона") */
{ rep/html-conv.i }


define variable filter-point as character no-undo init "Просмотр XYZ анализа" .
define variable filter-point0 as character no-undo init "Просмотр_XYZ_анализа" .
define variable sort-column-name as character no-undo .
define variable doc-rec as recid no-undo .


define variable v-izt      as character no-undo .
define variable v-Acc-mat  as character no-undo .
define variable v-Amin     as character no-undo .
define variable v-obj-AssMin  as logical   no-undo .
define variable v-obj-igt     as character no-undo .

 define variable v-gdop-min-stock              as decimal   no-undo .
 define variable v-grop-max-stock              as decimal   no-undo .
 define variable v-grop-level-always-presence  as decimal   no-undo .
 define variable v-grop-min-order              as decimal   no-undo .


define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id              as character               no-undo .
define variable v-file-name-rep-htm as character no-undo .


v-err-ext = false  .
v-longchar = "".
{ ref/clearlm.i }


define variable rid-list   as character no-undo .

/* для F9 */
def var list-mode as char  no-undo.  /* специально для сохранения list-mode */
def var doc-mode  as char  no-undo.  /* специально для сохранения doc-mode */
def var line-rec  as recid no-undo.  /* специально для сохранения line-rec */
def var gds-rec   as recid no-undo.  /* специально для сохранения gds-rec */
def var prt-rec   as recid no-undo.  /* специально для сохранения prt-rec */
def var line-mode as char  no-undo.  /* специально для сохранения line-mode */
define variable g#mainmenu-handle AS WIDGET-HANDLE NO-UNDO.
g#mainmenu-handle = parParentProc .

&scop col-p1    mark-string(recid( buf_XYZ-analysis-goods),rid-list)
&scop dyn_col-p1  substitute('dynamic-function(&1mark-string&1, recid(buf_XYZ-analysis-goods), &1&2&1)', ~{&double-quote~}, rid-list)
&scop col-p2    buf_goods.artic
&scop col-p3    buf_goods.gds-name
&scop col-p4    buf_XYZ-analysis-goods.XYZg-XYZ
&scop col-p5    buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate
&scop col-p6    buf_XYZ-analysis-goods.XYZg-sum-for-estimate
&scop col-p7    buf_XYZ-analysis-goods.XYZg-order-qnty
&scop col-p8    buf_XYZ-analysis-goods.XYZg-qnty
&scop col-p9    buf_XYZ-analysis-goods.XYZg-stock-qnty
&scop col-p10   buf_XYZ-analysis-goods.XYZg-stock-price-acc
&scop col-p11   buf_XYZ-analysis-goods.XYZg-stock-price-sale
&scop col-p12   buf_XYZ-analysis-goods.XYZg-sum-acc
&scop col-p13   buf_XYZ-analysis-goods.XYZg-sum-cur
&scop col-p14   buf_XYZ-analysis-goods.XYZg-sum-doc
&scop col-p15   buf_XYZ-analysis-goods.XYZg-temp-sale-goods
&scop col-p16   v-izt
&scop col-p17   v-Acc-mat
&scop col-p18   v-Amin


&scop col-l1  '*! !'
&scop col-l2  'Артикул! !'
&scop col-l3  'Название! !'
&scop col-l4  'X!Y!Z'
&scop col-l5  '% по  !крите-!рию   '
&scop col-l6  'Сумма!для оценки!по критерию'
&scop col-l7  'Заказанное!количество!товара'
&scop col-l8  'Количество!по!реализации'
&scop col-l9  'Остаток!количество!'
&scop col-l10 'Остаток!товара в!учет.ценах'
&scop col-l11 'Остаток!товара в!продаж.ценах'
&scop col-l12 'Сумма!реализации в!учет.ценах'
&scop col-l13 'Сумма!реализации в!прод.ценах'
&scop col-l14 'Сумма!реализации в!ценах докум.'
&scop col-l15 'Темп!продаж!'
&scop col-l16  'ИЖТ! !'
&scop col-l17  'Ассорт.!матрица!'
&scop col-l18  'Ассорт.!min!'

find first buf_XYZ-analysis no-lock where
           buf_XYZ-analysis.XYZ-id = v-id and
           buf_XYZ-analysis.db-num = v-db-num
            no-error .
if not available  buf_XYZ-analysis then do:
   message vss-workfile vss-revision vss-description skip
          "Не найдена запись buf_XYZ-analysis"  v-id v-db-num
          return-value
          error-status :get-message(1) .
   return.
end.


define buffer buf_criterion-analysis for ub.criterion-analysis.
find first buf_criterion-analysis no-lock where
           buf_criterion-analysis.cral-id = buf_XYZ-analysis.cral-id no-error .
if not available  buf_criterion-analysis then do:
   message vss-workfile vss-revision vss-description skip
          "Не найдена запись buf_criterion-analysis"  buf_XYZ-analysis.cral-id
          return-value
          error-status :get-message(1) .
   return.
end.

DEFINE VARIABLE v-ass-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Ассортиментная матрица"
      VIEW-AS TEXT
     SIZE 69.5 BY .67
     FGCOLOR 4  NO-UNDO.

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
&Scoped-define INTERNAL-TABLES Buf_XYZ-analysis-goods buf_goods ~
Buf_XYZ-analysis-obj buf_XYZ-analysis-gds-obj Buf_gds-obj-prop ~
buf_assortment-matrix buf_assortment-matrix-goods

/* Definitions for BROWSE BROWSE-goods                                  */
&Scoped-define FIELDS-IN-QUERY-BROWSE-goods mark-string(recid( buf_XYZ-analysis-goods), rid-list) buf_goods.artic buf_goods.gds-name buf_xyz-analysis-goods.xyzg-xyz buf_xyz-analysis-goods.xyzg-prcnt-for-estimate buf_xyz-analysis-goods.kol-period buf_xyz-analysis-goods.average-qnty buf_xyz-analysis-goods.sigma v-izt v-amin v-acc-mat buf_xyz-analysis-goods.xyzg-qnty buf_xyz-analysis-goods.xyzg-stock-qnty buf_xyz-analysis-goods.xyzg-stock-price-acc buf_xyz-analysis-goods.xyzg-stock-price-sale buf_xyz-analysis-goods.xyzg-sum-acc buf_xyz-analysis-goods.xyzg-sum-cur buf_xyz-analysis-goods.xyzg-sum-doc buf_xyz-analysis-goods.xyzg-temp-sale-goods buf_xyz-analysis-goods.xyzg-order-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-goods buf_goods.artic
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-goods buf_goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-goods buf_goods
&Scoped-define SELF-NAME BROWSE-goods
&Scoped-define QUERY-STRING-BROWSE-goods FOR EACH Buf_XYZ-analysis-goods       WHERE Buf_XYZ-analysis-goods.XYZ-id = v-id and Buf_XYZ-analysis-goods.db-num = v-db-num NO-LOCK, ~
             EACH buf_goods OF ub.Buf_XYZ-analysis-goods NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-goods OPEN QUERY {&SELF-NAME} FOR EACH Buf_XYZ-analysis-goods       WHERE Buf_XYZ-analysis-goods.XYZ-id = v-id and Buf_XYZ-analysis-goods.db-num = v-db-num NO-LOCK, ~
             EACH buf_goods OF ub.Buf_XYZ-analysis-goods NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-goods Buf_XYZ-analysis-goods ~
buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-goods Buf_XYZ-analysis-goods
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-goods buf_goods


/* Definitions for BROWSE BROWSE-obj                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-obj Buf_XYZ-analysis-obj.obj-type Buf_XYZ-analysis-obj.obj-code buf_XYZ-analysis-gds-obj.XYog-qnty buf_XYZ-analysis-gds-obj.XYog-temp-sale-goods buf_XYZ-analysis-gds-obj.XYog-stock-qnty buf_XYZ-analysis-gds-obj.XYog-price-crc buf_XYZ-analysis-gds-obj.XYog-sum-acc buf_XYZ-analysis-gds-obj.XYog-sum-cur buf_XYZ-analysis-gds-obj.XYog-sum-doc buf_XYZ-analysis-gds-obj.XYog-vat-acc buf_XYZ-analysis-gds-obj.XYog-vat-cur buf_XYZ-analysis-gds-obj.XYog-vat-doc buf_XYZ-analysis-gds-obj.XYog-transport-acc buf_XYZ-analysis-gds-obj.XYog-transport-cur buf_XYZ-analysis-gds-obj.XYog-transport-doc buf_XYZ-analysis-gds-obj.XYog-road-tax-acc buf_XYZ-analysis-gds-obj.XYog-road-tax-cur buf_XYZ-analysis-gds-obj.XYog-road-tax-doc buf_XYZ-analysis-gds-obj.XYog-other-doc buf_XYZ-analysis-gds-obj.XYog-other-cur buf_XYZ-analysis-gds-obj.XYog-other-acc v-obj-igt v-obj-AssMin buf_assortment-matrix-goods.asmt-id
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-obj
&Scoped-define SELF-NAME BROWSE-obj
&Scoped-define QUERY-STRING-BROWSE-obj FOR EACH Buf_XYZ-analysis-obj WHERE                Buf_XYZ-analysis-obj.XYZ-id = v-id AND                Buf_XYZ-analysis-obj.db-num = v-db-num                NO-LOCK, ~
                 EACH buf_XYZ-analysis-gds-obj WHERE                buf_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND                buf_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND                buf_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND                buf_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND                buf_XYZ-analysis-gds-obj.db-num   = v-db-num                OUTER-JOIN NO-LOCK, ~
                 EACH Buf_gds-obj-prop WHERE                Buf_gds-obj-prop.obj-type = ub.buf_XYZ-analysis-obj.obj-type AND                Buf_gds-obj-prop.obj-code = ub.buf_XYZ-analysis-obj.obj-code AND                Buf_gds-obj-prop.gds-code = ub.buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK, ~
                first buf_assortment-matrix WHERE                buf_assortment-matrix.asmt-status        = 0  AND                buf_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND                buf_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code                OUTER-JOIN NO-LOCK, ~
                FIRST buf_assortment-matrix-goods WHERE                buf_assortment-matrix-goods.asmg-status        = 0  AND                buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND                buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND                buf_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-obj OPEN QUERY {&SELF-NAME}       FOR EACH Buf_XYZ-analysis-obj WHERE                Buf_XYZ-analysis-obj.XYZ-id = v-id AND                Buf_XYZ-analysis-obj.db-num = v-db-num                NO-LOCK, ~
                 EACH buf_XYZ-analysis-gds-obj WHERE                buf_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND                buf_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND                buf_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND                buf_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND                buf_XYZ-analysis-gds-obj.db-num   = v-db-num                OUTER-JOIN NO-LOCK, ~
                 EACH Buf_gds-obj-prop WHERE                Buf_gds-obj-prop.obj-type = ub.buf_XYZ-analysis-obj.obj-type AND                Buf_gds-obj-prop.obj-code = ub.buf_XYZ-analysis-obj.obj-code AND                Buf_gds-obj-prop.gds-code = ub.buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK, ~
                first buf_assortment-matrix WHERE                buf_assortment-matrix.asmt-status        = 0  AND                buf_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND                buf_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code                OUTER-JOIN NO-LOCK, ~
                FIRST buf_assortment-matrix-goods WHERE                buf_assortment-matrix-goods.asmg-status        = 0  AND                buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND                buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND                buf_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-obj Buf_XYZ-analysis-obj ~
buf_XYZ-analysis-gds-obj Buf_gds-obj-prop buf_assortment-matrix ~
buf_assortment-matrix-goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-obj Buf_XYZ-analysis-obj
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-obj buf_XYZ-analysis-gds-obj
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-obj Buf_gds-obj-prop
&Scoped-define FOURTH-TABLE-IN-QUERY-BROWSE-obj buf_assortment-matrix
&Scoped-define FIFTH-TABLE-IN-QUERY-BROWSE-obj buf_assortment-matrix-goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-goods}~
    ~{&OPEN-QUERY-BROWSE-obj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-cancel B-mark B-save B-chg-izt B-add-AM ~
B-del-AM B-spis-ord B-Help B-add-AMin B-del-AMin B-ord B-print BROWSE-goods ~
BROWSE-obj

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add-AM
     LABEL "Добавить в АМ"
     SIZE 16.5 BY 1 TOOLTIP "Добавить в ассортиментную матрицу по объекту".

DEFINE BUTTON B-add-AMin
     LABEL "Добавить в АМin"
     SIZE 16.5 BY 1 TOOLTIP "Добавить в ассортиментный минимум по объектам".

DEFINE BUTTON B-cancel AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-chg-izt
     LABEL "Изменить ИЖТ"
     SIZE 12.5 BY 1 TOOLTIP "Изменить ИЖТ".

DEFINE BUTTON B-del-AM
     LABEL "Удалить из АМ"
     SIZE 16 BY 1 TOOLTIP "Удалить из  ассортиментных матриц по объектам".

DEFINE BUTTON B-del-AMin
     LABEL "Удалить из АМin"
     SIZE 16 BY 1 TOOLTIP "Удалить из  ассортиментных минимумов по объектам".

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "*"
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
DEFINE new shared QUERY BROWSE-goods FOR
      Buf_XYZ-analysis-goods,
      buf_goods SCROLLING.

DEFINE QUERY BROWSE-obj FOR
      Buf_XYZ-analysis-obj,
      buf_XYZ-analysis-gds-obj,
      Buf_gds-obj-prop,
      buf_assortment-matrix,
      buf_assortment-matrix-goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-goods Dialog-Frame _FREEFORM
  QUERY BROWSE-goods NO-LOCK DISPLAY
      mark-string(recid( buf_XYZ-analysis-goods), rid-list) COLUMN-LABEL "*! ! " FORMAT "X(1)":U
      buf_goods.artic COLUMN-LABEL "Артикул! ! " FORMAT "X(16)":U            WIDTH 10
      buf_goods.gds-name COLUMN-LABEL "Название! ! " FORMAT "X(50)":U        WIDTH 20
      buf_xyz-analysis-goods.xyzg-xyz column-label "X!Y!Z" format "x(1)":u
      buf_xyz-analysis-goods.xyzg-prcnt-for-estimate column-label "Коэфф.!вариации!%" format ">>9.9999":u       width 8
      buf_xyz-analysis-goods.kol-period   column-label "Кол!пер! " format ">>9":u
      buf_xyz-analysis-goods.average-qnty column-label "Среднее!по!критерию" format "->>>>>>9.<<<":u             width 8
      buf_xyz-analysis-goods.sigma        column-label "Средне-!квадратическое!отклонение" format ">>>>>>>>>>9.99":u
      v-izt      column-label "ИЖТ! ! "           format "x(20)":u                                                width 10
      v-amin     column-label "Ассорт.!min! "     format "x(9)":u                                                 width 9
      v-acc-mat  column-label "Ассорт.!матрица! " format "x(9)":u                                                 width 9
      buf_xyz-analysis-goods.xyzg-qnty column-label "Количество!по!реализации" format "->>>>>>9.<<<":u           width 12
      buf_xyz-analysis-goods.xyzg-stock-qnty column-label "Остаток!количество! " format "->>>>>>9.<<<":u          width 12
      buf_xyz-analysis-goods.xyzg-stock-price-acc column-label "Остаток!товара в!учет.ценах" format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-stock-price-sale column-label "Остаток!товара в!продаж.ценах" format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-sum-acc column-label "Сумма!реализации в!учет.ценах" format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-sum-cur column-label "Сумма!реализации в!прод.ценах" format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-sum-doc column-label "Сумма!реализации в!ценах докум." format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-temp-sale-goods column-label "Темп!продаж!среднесут." format "->>>>>9.<<<":u
      buf_xyz-analysis-goods.xyzg-order-qnty COLUMN-LABEL "Заказанное!количество!товара" FORMAT ">>>>>>9.<<<":U   WIDTH 11
      enable buf_goods.artic
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 12.25 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-obj Dialog-Frame _FREEFORM
  QUERY BROWSE-obj NO-LOCK DISPLAY
      Buf_XYZ-analysis-obj.obj-type COLUMN-LABEL "Тип! ! "     FORMAT "X(3)":U
      Buf_XYZ-analysis-obj.obj-code COLUMN-LABEL "Объект! ! "  FORMAT ">>>>>9":U
      buf_XYZ-analysis-gds-obj.XYog-qnty            COLUMN-LABEL "Количество!по!реализации"          FORMAT "->>>>9.<<<":U  WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-temp-sale-goods COLUMN-LABEL "Темп!продаж! "                      FORMAT "->>>>9.<<<":U  WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-stock-qnty COLUMN-LABEL "Остаток!количество! "                    FORMAT "->>>>9.<<<":U  WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-price-crc COLUMN-LABEL "Продаж.цена!в валюте!критерия"           FORMAT "->>>>9.99":U   WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-sum-acc COLUMN-LABEL "Сумма!реализации в!учет.ценах"             FORMAT "->>>>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-sum-cur COLUMN-LABEL "Сумма!реализации в!продаж.ценах"           FORMAT "->>>>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-sum-doc COLUMN-LABEL "Сумма!реализации в!ценах докум."           FORMAT "->>>>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-vat-acc COLUMN-LABEL "НДС по сумме!реализации в!учет.ценах"      FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-vat-cur COLUMN-LABEL "НДС по сумме!реализации в!продаж.ценах"    FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-vat-doc COLUMN-LABEL "НДС по сумме!реализации в!ценах докум."    FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-transport-acc COLUMN-LABEL "Транспорт.!расходы в!учет.ценах"     FORMAT "->>>>9.99":U   WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-transport-cur COLUMN-LABEL "Транспорт.!расходы в!продаж.ценах"   FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-transport-doc COLUMN-LABEL "Транспорт.!расходы в!ценах докум."   FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-road-tax-acc COLUMN-LABEL "Налог 3 по!реализации в!учет.ценах"   FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-road-tax-cur COLUMN-LABEL "Налог 3 по!реализации в!продаж.ценах" FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-road-tax-doc COLUMN-LABEL "Налог 3 по!реализации в!ценах докум." FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-other-doc COLUMN-LABEL "Сумма прочих!расходов в!ценах докум."    FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-other-cur COLUMN-LABEL "Сумма прочих!расходов в!продаж.ценах"    FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-other-acc COLUMN-LABEL "Сумма прочих!расходов в!учет.ценах"      FORMAT "->>>>9.99":U
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
     B-Help AT ROW 1 COL 88
     B-add-AMin AT ROW 2 COL 42
     B-del-AMin AT ROW 2 COL 58.5
     B-ord AT ROW 2 COL 74.5
     B-print AT ROW 2 COL 88
     BROWSE-goods AT ROW 3 COL 1
     BROWSE-obj AT ROW 15.25 COL 1
     SPACE(0.12) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр результатов XYZ анализа"
         CANCEL-BUTTON B-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_assortment-matrix B "?" ? ub assortment-matrix
      TABLE: buf_assortment-matrix-goods B "?" ? ub assortment-matrix-goods
      TABLE: Buf_gds-obj-prop B "?" ? ub gds-obj-prop
      TABLE: buf_goods B "NEW SHARED" ? ub goods
      TABLE: buf_XYZ-analysis B "?" ? ub XYZ-analysis
      TABLE: buf_XYZ-analysis-gds-obj B "?" ? ub XYZ-analysis-gds-obj
      TABLE: Buf_XYZ-analysis-goods B "NEW SHARED" ? ub XYZ-analysis-goods
      TABLE: Buf_XYZ-analysis-obj B "?" ? ub XYZ-analysis-obj
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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-goods
/* Query rebuild information for BROWSE BROWSE-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH Buf_XYZ-analysis-goods
      WHERE Buf_XYZ-analysis-goods.XYZ-id = v-id and Buf_XYZ-analysis-goods.db-num = v-db-num NO-LOCK,
      EACH buf_goods OF ub.Buf_XYZ-analysis-goods NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "Buf_XYZ-analysis-goods.XYZ-id = v-id and Buf_XYZ-analysis-goods.db-num = v-db-num"
     _Query            is OPENED
*/  /* BROWSE BROWSE-goods */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-obj
/* Query rebuild information for BROWSE BROWSE-obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
      FOR EACH Buf_XYZ-analysis-obj WHERE
               Buf_XYZ-analysis-obj.XYZ-id = v-id AND
               Buf_XYZ-analysis-obj.db-num = v-db-num
               NO-LOCK,
          EACH buf_XYZ-analysis-gds-obj WHERE
               buf_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND
               buf_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND
               buf_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND
               buf_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND
               buf_XYZ-analysis-gds-obj.db-num   = v-db-num
               OUTER-JOIN NO-LOCK,
          EACH Buf_gds-obj-prop WHERE
               Buf_gds-obj-prop.obj-type = ub.buf_XYZ-analysis-obj.obj-type AND
               Buf_gds-obj-prop.obj-code = ub.buf_XYZ-analysis-obj.obj-code AND
               Buf_gds-obj-prop.gds-code = ub.buf_XYZ-analysis-goods.gds-code
               OUTER-JOIN NO-LOCK,
         first buf_assortment-matrix WHERE
               buf_assortment-matrix.asmt-status        = 0  AND
               buf_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND
               buf_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code
               OUTER-JOIN NO-LOCK,
         FIRST buf_assortment-matrix-goods WHERE
               buf_assortment-matrix-goods.asmg-status        = 0  AND
               buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND
               buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND
               buf_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code
               OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ",, OUTER, OUTER, OUTER"
     _Where[1]         = "Buf_XYZ-analysis-obj.XYZ-id = v-id
 AND Buf_XYZ-analysis-obj.db-num = v-db-num"
     _Query            is OPENED
*/  /* BROWSE BROWSE-obj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Просмотр результатов XYZ анализа */
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
  run proc-cgh-AM ( input true ) no-error .
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
ON CHOOSE OF B-add-AMin IN FRAME Dialog-Frame /* Добавить в АМin */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-Amin ( input true ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Amin"
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
  run proc-chg-igt no-error .
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
  run proc-cgh-AM ( input false ) no-error .
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
ON CHOOSE OF B-del-AMin IN FRAME Dialog-Frame /* Удалить из АМin */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-Amin ( input false ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Amin"
          view-as alert-box error .
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
    if available Buf_XYZ-analysis-goods then do:
        { gbl/markstrn.i Buf_XYZ-analysis-goods rid-list }

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

    apply "entry" to browse-goods in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ord Dialog-Frame
ON CHOOSE OF B-ord IN FRAME Dialog-Frame /* Новый заказ */
DO:
    /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:

  run print-proc ( true  ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  /* создадим строку для сохранения */
  run proc-save.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-spis-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-spis-ord Dialog-Frame
ON CHOOSE OF B-spis-ord IN FRAME Dialog-Frame /* Заказы */
DO:
define variable v-recid as character no-undo .
for each doc-list : delete doc-list. end.
  run cus/mdoclist.p ( rid-list ) .
  run cus/dord-doc.w (
  parParentProc
  ,""  /*bttns           */
  ,?   /*p-curr-obj-type */
  ,?   /*p-curr-obj-code */
  ,?   /*p-mode          */
  ,?   /*p-sts           */
  , input-output v-recid   /*p-rid-list      */
  ).
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-goods
&Scoped-define SELF-NAME BROWSE-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-goods Dialog-Frame
ON ROW-DISPLAY OF BROWSE-goods IN FRAME Dialog-Frame
DO:
  if available  buf_XYZ-analysis-goods then do:
    run proc-disp-goods in this-procedure .
    if v-Amin = "входит" then  v-Amin:fgcolor  in browse browse-goods  = 4.
    if buf_xyz-analysis-goods.xyzg-xyz = "X" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 12
         {&col-p3}:fgcolor  in browse browse-goods  = 12
         {&col-p4}:fgcolor  in browse browse-goods  = 12
         {&col-p5}:fgcolor  in browse browse-goods  = 12
       .
    if buf_xyz-analysis-goods.xyzg-xyz = "Y" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 9
         {&col-p3}:fgcolor  in browse browse-goods  = 9
         {&col-p4}:fgcolor  in browse browse-goods  = 9
         {&col-p5}:fgcolor  in browse browse-goods  = 9
       .

  END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-goods Dialog-Frame
ON VALUE-CHANGED OF BROWSE-goods IN FRAME Dialog-Frame
DO:

  if available  buf_XYZ-analysis-goods then do:
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
 run disp-obj in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-goods
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name="browse-goods" }
{ gbl/f2.i browse-goods goods-recid init-gds-rec }
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BROWSE-obj :handle
  ) .
run diasize_init in this-procedure .

{ gbl/srt-clmd.i
  &browse-name   =  "browse-goods"
  &frame-name    =  "{&frame-name}"
  &table-name    =  "XYZ-analysis-goods"
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
    &ext-col = 15
    &start-column = 1
    } */

   buf_goods.artic:resizable in browse BROWSE-goods = true .
   buf_goods.gds-name:resizable in browse BROWSE-goods = true .
   v-izt:resizable in browse BROWSE-goods = true .
   buf_goods.artic:read-only in browse BROWSE-goods = true .

   v-ass-name:resizable in browse BROWSE-obj = true .
   v-obj-igt:resizable in browse BROWSE-obj = true .

  run my_enable.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DISP-OBJ Dialog-Frame
PROCEDURE DISP-OBJ :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 define buffer   buf2_assortment-matrix for ub.assortment-matrix .
      v-ass-name = "" .
      if available buf_assortment-matrix-goods  then do:
          find first buf2_assortment-matrix no-lock where
                     buf2_assortment-matrix.asmt-id  =  buf_assortment-matrix-goods.asmt-id and
                     buf2_assortment-matrix.db-num   =  buf_assortment-matrix-goods.db-num no-error .
                     if available buf2_assortment-matrix
                        then  v-ass-name = buf2_assortment-matrix.asmt-name .
      end.

      if available buf_XYZ-analysis-obj then do:
          { gbl/gdsobjpr.i
            buf_XYZ-analysis-obj.obj-type
            buf_XYZ-analysis-obj.obj-code
            ?
            ?
            ?
            buf_XYZ-analysis-goods.gds-code
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
  ENABLE B-cancel B-mark B-save B-chg-izt B-add-AM B-del-AM B-spis-ord B-Help
         B-add-AMin B-del-AMin B-ord B-print BROWSE-goods BROWSE-obj
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
if available buf_goods then
gds-rec = recid(buf_goods) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-gds-list Dialog-Frame
PROCEDURE make-gds-list :
do
  on error undo, return error return-value
  :
define buffer buf2_goods for ub.goods.
define buffer buf2_XYZ-analysis-goods for ub.XYZ-analysis-goods.
define variable v-kol as integer   no-undo .
define variable i as integer   no-undo .

  /* формирование gds-list */
run waitfram-show ( "Подготовка временных таблиц.... ") .
    for each gds-list : delete gds-list. end.
    v-kol = num-entries( rid-list ) .
    repeat i = 1 to v-kol :
      find first buf2_XYZ-analysis-goods no-lock where recid(buf2_XYZ-analysis-goods) = integer(entry(i,rid-list)) no-error .
      if available buf2_XYZ-analysis-goods then do:
          find first buf2_goods no-lock where buf2_goods.gds-code = buf2_XYZ-analysis-goods.gds-code no-error .
          if available buf2_goods then do:
              create gds-list.
              BUFFER-COPY buf2_goods TO gds-list .
          end.
      end.
    end.
 run waitfram-hide.

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
define buffer Buf2_XYZ-analysis-obj for ub.XYZ-analysis-obj.
hide b-ord in frame {&frame-name} .
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
         /*B-ord */
         B-print
         BROWSE-goods
         BROWSE-obj
      WITH FRAME Dialog-Frame.
  view frame dialog-frame.
  FOR EACH Buf2_XYZ-analysis-obj WHERE
           Buf2_XYZ-analysis-obj.XYZ-id = v-id AND
           Buf2_XYZ-analysis-obj.db-num = v-db-num     NO-LOCK :
    run create_obj-list (Buf2_XYZ-analysis-obj.obj-type , Buf2_XYZ-analysis-obj.obj-code ) .
  end.
  run openbr ( yes, no, '':u).
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
def var l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define buffer buff_contract for contract.
define variable loc_contract-code as character no-undo .



{&SetCursorWait}
def var sort-column-phrase as character no-undo .

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



&scop flt-open-open-query OPEN QUERY browse-goods FOR EACH Buf_XYZ-analysis-goods use-index sort-pcnt

&scop flt-open-dyn_open-query  FOR EACH Buf_XYZ-analysis-goods

&scop flt-open-query-handle query browse-goods:handle

&scop flt-open-find-buffer-name Buf_XYZ-analysis-goods


&scop flt-open-open-query-tail , EACH buf_goods OF ub.Buf_XYZ-analysis-goods NO-LOCK

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          Buf_XYZ-analysis-goods

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer Buf_XYZ-analysis-goods for XYZ-analysis-goods.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .

  { gbl/fltopend.i
    &where-cond     = " Buf_XYZ-analysis-goods.XYZ-id = v-id  and Buf_XYZ-analysis-goods.db-num = v-db-num  "
    &dyn_where-cond = " substitute ( ' Buf_XYZ-analysis-goods.XYZ-id = &1  and Buf_XYZ-analysis-goods.db-num = &2 ', v-id, v-db-num ) "
    &use-ind        = "  "
    &by             = "  " }

if not p-open-query then
REPOSITION browse-goods to recid doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query browse-goods:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

/*
APPLY "ENTRY" TO BROWSE-goods in frame {&frame-name}.
APPLY "VALUE-CHANGED" TO BROWSE-goods in frame {&frame-name}.
*/


{&SetCursorNo}
  if available  buf_XYZ-analysis-goods then do:
     {&OPEN-QUERY-BROWSE-OBJ}
  end.

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


def var date_string     as      char    no-undo.
def var Line                as      char    no-undo.
def var for-time as char.

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
            '<TD colspan="18" STYLE="font-size: 14px;">Вн.Код     :' + string(buf_XYZ-analysis.XYZ-id) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Название   :' + string(buf_XYZ-analysis.XYZ-name) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Критерий   :' + string(buf_criterion-analysis.cral-name) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Коментарии :' + string(buf_XYZ-analysis.XYZ-des) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Создание анализа :' + string(buf_XYZ-analysis.XYZ-date-create,"99.99.9999") + '' + string(buf_XYZ-analysis.XYZ-time-create,"hh:mm") + '' + buf_XYZ-analysis.XYZ-who-create + '</TD>' skip
        '</TR>'skip
    .
    define buffer bufp_XYZ-analysis-obj for ub.XYZ-analysis-obj.
    define VARIABLE v-obj as character no-undo .

    for each bufp_XYZ-analysis-obj no-lock where bufp_XYZ-analysis-obj.db-num = buf_XYZ-analysis.db-num and
                                                 bufp_XYZ-analysis-obj.XYZ-id = buf_XYZ-analysis.XYZ-id :
       v-obj = v-obj + "," + trim(bufp_XYZ-analysis-obj.obj-type) + " " + trim(string(bufp_XYZ-analysis-obj.obj-code)) . 
    end.

    v-obj = TRIM (v-obj,",") .
    
        put stream OutStr-html unformatted            
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Объекты    :' + string(v-obj) + '</TD>' skip
        '</TR>'skip       
        .
        
    define buffer bufp_XYZ-analysis-period for ub.XYZ-analysis-period.
    define VARIABLE v-period as character no-undo .

    for each bufp_XYZ-analysis-period no-lock where bufp_XYZ-analysis-period.db-num = buf_XYZ-analysis.db-num and
                                                    bufp_XYZ-analysis-period.XYZ-id = buf_XYZ-analysis.XYZ-id :
       v-period = v-period + "," + string(bufp_XYZ-analysis-period.XYZp-start,"99.99.9999") + "-" + string(bufp_XYZ-analysis-period.XYZp-end,"99.99.9999") .
    end.
        v-period = TRIM (v-period,",") .
    
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Периоды    :' + string(v-period) + '</TD>' skip
        '</TR>'skip       
        .
        
    define buffer bufp_XYZ-analysis-doc for ub.XYZ-analysis-doc.
    define VARIABLE v-doc-type as character no-undo .

    for each bufp_XYZ-analysis-doc no-lock where bufp_XYZ-analysis-doc.db-num = buf_XYZ-analysis.db-num and
                                                 bufp_XYZ-analysis-doc.XYZ-id = buf_XYZ-analysis.XYZ-id :
       v-doc-type = v-doc-type + "," + func-get-name-from-ext-type( bufp_XYZ-analysis-doc.XYZd-ext-doc-type , false ) .
    end.

        v-doc-type = TRIM (v-doc-type,",") .

        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Типы документов  :' + string(v-doc-type) + '</TD>' skip
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
            '<TH style="text-align: center;">XYZ</TH>'skip
            '<TH style="text-align: center;">Коэфф-т вариац %</TH>'skip
            '<TH style="text-align: center;">Кол-во период продаж</TH>'skip
            '<TH style="text-align: center;">Сумма для оценки по критер</TH>'skip
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


    run OpenBR in this-procedure (yes, no, '':U).                
    DO WHILE available Buf_XYZ-analysis-goods :
        run prt-goods in this-procedure .

                    
/*                define variable ii as integer no-undo .                                                       */
/*                ii = 0.                                                                                       */
/*                if AVAILABLE Buf_XYZ-analysis-gds-obj then                                                    */
/*                do:                                                                                           */
/*                    if Buf_XYZ-analysis-gds-obj.XYog-qnty <> ? or Buf_XYZ-analysis-gds-obj.XYog-qnty <> 0 then*/
/*                    do:                                                                                       */
/*                        ii = ii + 1 .                                                                         */
/*                    end.                                                                                      */
/*                end.                                                                                          */
/*                ii = ii + 1 .                                                                                 */
                put stream OutStr-html unformatted
                    '<TR>'skip
                    '<TD> ' + string(buf_goods.artic) + '</TD>'skip
                    '<TD> ' + string(buf_goods.gds-name) + '</TD>'skip
                    '<TD> ' + string(Buf_XYZ-analysis-goods.XYZg-XYZ) + '</TD>'skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.kol-period,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.kol-period <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.kol-period,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-for-estimate,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-for-estimate <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-for-estimate,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD> ' + string(v-izt) + '</TD>'skip
                    '<TD> ' + string(v-Amin) + '</TD>'skip
                    '<TD> ' + string(v-Acc-mat) + '</TD>'skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-stock-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-stock-price-acc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-sale,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-stock-price-sale <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-sale,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-acc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-cur <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-doc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-doc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-temp-sale-goods <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-order-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-order-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-order-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '</TR>'skip    
                    .                  
/*                put stream OutStr-html unformatted                                                                                                                                                                                                                                                                                                                                                    */
/*                    '<TR>'skip                                                                                                                                                                                                                                                                                                                                                                        */
/*                    '<TD rowspan="' + string(ii) + '"> ' + string(buf_goods.artic) + '</TD>'skip                                                                                                                                                                                                                                                                                                      */
/*                    '<TD> ' + string(buf_goods.gds-name) + '</TD>'skip                                                                                                                                                                                                                                                                                                                                */
/*                    '<TD rowspan="' + string(ii) + '"> ' + string(Buf_XYZ-analysis-goods.XYZg-XYZ) + '</TD>'skip                                                                                                                                                                                                                                                                                      */
/*                    '<TD rowspan="' + string(ii) + '" num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip*/
/*                    '<TD rowspan="' + string(ii) + '" num="0" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.kol-period,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.kol-period <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.kol-period,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip                                                */
/*                    '<TD rowspan="' + string(ii) + '" num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-for-estimate,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-for-estimate <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-for-estimate,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip      */
/*                    '<TD> ' + string(v-izt) + '</TD>'skip                                                                                                                                                                                                                                                                                                                                             */
/*                    '<TD> ' + string(v-Amin) + '</TD>'skip                                                                                                                                                                                                                                                                                                                                            */
/*                    '<TD> ' + string(v-Acc-mat) + '</TD>'skip                                                                                                                                                                                                                                                                                                                                         */
/*                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip                                                                       */
/*                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-stock-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip                                                     */
/*                    '<TD rowspan="' + string(ii) + '" num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-stock-price-acc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip         */
/*                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-sale,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-stock-price-sale <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-sale,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip                                   */
/*                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-acc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip                                                              */
/*                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-cur <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip                                                              */
/*                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-doc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-doc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip                                                              */
/*                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-temp-sale-goods <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip                                      */
/*                    '<TD rowspan="' + string(ii) + '" num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-order-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-order-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-order-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip                        */
/*                    '</TR>'skip                                                                                                                                                                                                                                                                                                                                                                       */
/*                    .                                                                                                                                                                                                                                                                                                                                                                                 */
                              
        if p-obj = true then 
        do:
            /* расшифровка по объектам */
            {&OPEN-QUERY-BROWSE-obj}
            DO WHILE available Buf_XYZ-analysis-obj :
                run disp-obj in this-procedure .    
                    if AVAILABLE Buf_XYZ-analysis-gds-obj then 
                    do:
                        if Buf_XYZ-analysis-gds-obj.XYog-qnty <> ? or Buf_XYZ-analysis-gds-obj.XYog-qnty <> 0 then 
                        do: 
                            put stream OutStr-html unformatted
                                '<TR>'skip
                                '<TD></TD>'skip
                                '<TD> ' + string(Buf_XYZ-analysis-obj.obj-type + " " + string(Buf_XYZ-analysis-obj.obj-code)) + '</TD>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD> ' + string(v-obj-igt) + '</TD>'skip
                                '<TD> ' + string( v-obj-AssMin , "да/нет" ) + '</TD>'skip
                                '<TD> ' + string(v-ass-name) + '</TD>'skip
                                .
                            put stream OutStr-html unformatted              
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-stock-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-stock-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-stock-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                '<TD></TD>'skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((Buf_XYZ-analysis-gds-obj.XYog-stock-qnty * buf_XYZ-analysis-gds-obj.XYog-price-crc ),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if (Buf_XYZ-analysis-gds-obj.XYog-stock-qnty * buf_XYZ-analysis-gds-obj.XYog-price-crc ) <> ? then fnc-convert-dot-to-colon((Buf_XYZ-analysis-gds-obj.XYog-stock-qnty * buf_XYZ-analysis-gds-obj.XYog-price-crc ),"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-sum-acc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-sum-cur <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-sum-doc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-doc,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-temp-sale-goods <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD></TD>'skip
                              '</TR>'skip    
                                .
                        end.
                    end.
                    /*                    else do:                                                           */
                    /*                    put stream OutStr-html unformatted                                 */
                    /*                                  '<TD style="text-align: right">' + "?" + '</TD>'skip */
                    /*                                  '<TD style="text-align: right">' + "?" + '</TD>'skip */
                    /*                                  '<TD style="text-align: right">' + "?" + '</TD>' skip*/
                    /*                                  '<TD style="text-align: right">' + "?" + '</TD>' skip*/
                    /*                                  '<TD style="text-align: right">' + "?" + '</TD>' skip*/
                    /*                                  '<TD style="text-align: right">' + "?" + '</TD>' skip*/
                    /*                                  '<TD style="text-align: right">' + "?" + '</TD>' skip*/
                    /*                              '</TR>'skip                                              */
                    /*                              .                                                        */
                    /*                                                                                       */
                    /*                    end.                                                               */
                    get next browse-obj.
                END.
/*            end.*/
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

v-err-ext = false  .
v-longchar = "".

 run make-gds-list .
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
                   find first buf_gds-obj no-lock where
                        buf_gds-obj.obj-type = obj-list.obj-type and
                        buf_gds-obj.obj-code = obj-list.obj-code and
                        buf_gds-obj.gds-code = gds-list.gds-code no-error .
                        if available buf_gds-obj then do:
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
                              no-error }
                              if error-status :error then do:
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
run OpenBr (yes, no, '':U).
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
  run make-gds-list .
  run ref/chg-amin.p ( input v-new ) no-error  .
      if error-status :error then
          message vss-workfile vss-revision vss-description skip
          error-status :get-message(1)
          return-value
          .
  run OpenBr (yes, no, '':U).

    end.
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

  run make-gds-list in this-procedure .
  run ref/graf-igt.w ( output v-old, output v-new ).

  if not(v-old = "" and v-new = "")  then do:
      run ref/chg-igt.p ( input v-old, input v-new , input true ) no-error  .
          if error-status :error then
              message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              return-value
              .
  end.
run OpenBr ( yes, no, '':U).

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
    v-old-izt  =  Buf_gds-obj-prop.gdop-igt
    v-izt      =  Buf_gds-obj-prop.gdop-igt
    v-Amin     =  string(Buf_gds-obj-prop.gdop-assort-min)
    v-old-Amin =  string(Buf_gds-obj-prop.gdop-assort-min)
    v-acc-mat     =  string(buf_assortment-matrix-goods.asmt-id)
    v-old-acc-mat =  string(buf_assortment-matrix-goods.asmt-id)
    no-error
    .
        if v-old-Amin = ? or
          v-old-Amin = 'no' or
          v-old-Amin = "?" or
          v-old-Amin = "" then v-old-Amin = "" .

    if v-izt = ? or v-izt = "" then v-izt = {&ass-izd-empty} .
    if v-old-izt = ? or v-old-izt = "" then v-old-izt = {&ass-izd-empty} .

    if v-Amin = ? or v-Amin = 'no' or v-Amin = "?" or v-Amin = "" then v-Amin = "не входит" .
       else v-Amin = "входит" .
    if v-acc-mat = ? or v-acc-mat = ""  then v-acc-mat = "не входит" .
       else v-acc-mat = "входит" .


    DO WHILE AVAILABLE(Buf_XYZ-analysis-obj):
        if Buf_gds-obj-prop.gdop-igt <> ? then
        if v-old-izt     <> Buf_gds-obj-prop.gdop-igt                then  v-izt = "разное" .
           vt-amin = string(Buf_gds-obj-prop.gdop-assort-min) .
        if vt-Amin = ?    or
           vt-Amin = 'no' or
           vt-Amin = "?"  or
           vt-Amin = "" then vt-Amin = "" .

        if v-old-Amin    <> vt-Amin  then  v-Amin = "разное" .
        if v-old-acc-mat <> string(buf_assortment-matrix-goods.asmt-id)
          and (v-old-acc-mat = ? or string(buf_assortment-matrix-goods.asmt-id) = ?  )
          then  v-acc-mat = "разное" .



      assign
        v-old-izt     = Buf_gds-obj-prop.gdop-igt
        v-old-Amin    = string(Buf_gds-obj-prop.gdop-assort-min)
        v-old-acc-mat = string(buf_assortment-matrix-goods.asmt-id)
        no-error
      .
        if v-old-Amin = ? or
           v-old-Amin = 'no' or
           v-old-Amin = "?" or
           v-old-Amin = "" then v-old-Amin = "" .
        if v-old-izt = ? or v-old-izt = "" then v-old-izt = {&ass-izd-empty} .

      GET NEXT BROWSE-obj.
    END. /* DO WHILE AVAIL(Buf_XYZ-analysis-obj) */



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

  define buffer x-XYZ-analysis for ub.XYZ-analysis.
  define buffer x-XYZ-analysis-obj for ub.XYZ-analysis-obj .
  define buffer x-XYZ-analysis-doc for ub.XYZ-analysis-doc .
  run waitfram-show ( "Сохранение анализа по умолчанию ... ") .
  v-list-obj = "" .
  find first x-XYZ-analysis no-lock  where
             x-XYZ-analysis.XYZ-id  = v-id and
             x-XYZ-analysis.db-num  = v-db-num  no-error .
             if error-status :error then return .

  for each  x-XYZ-analysis-obj no-lock
      where x-XYZ-analysis-obj.XYZ-id = x-XYZ-analysis.XYZ-id and
            x-XYZ-analysis-obj.db-num = x-XYZ-analysis.db-num  :
            v-list-obj = v-list-obj + x-XYZ-analysis-obj.obj-type + string(x-XYZ-analysis-obj.obj-code) + "," .
  end.

  run find-from-hash  (
     input v-list-obj
    ,input "rang-XYZ-def"
    ,input "raxd-possb-keep-string-obj"
    ,input "raxd-string-obj"
    ,input "raxd-hash-string-obj"
    ,input "rang-XYZ-def-obj"
    ,output v-recid
    ).

  run update-rang-xyz-def (
     input v-recid
    ,input v-list-obj
    ,input x-XYZ-analysis.XYZ-x
    ,input x-XYZ-analysis.XYZ-y
    ,input x-XYZ-analysis.XYZ-z
    ).

  v-list-doc = "".


  for each x-XYZ-analysis-doc no-lock
      where x-XYZ-analysis-doc.XYZ-id = x-XYZ-analysis.XYZ-id and
            x-XYZ-analysis-doc.db-num = x-XYZ-analysis.db-num  :
            v-list-doc = v-list-doc + x-XYZ-analysis-doc.XYZd-ext-doc-type  + "," .
  end.


  run find-from-hash  (
     input v-list-obj
    ,input "doc-XYZ-def"
    ,input "doxd-possb-keep-string-obj"
    ,input "doxd-string-obj"
    ,input "doxd-hash-string-obj"
    ,input "doc-XYZ-def-obj"
    ,output v-recid
    ).

  run update-doc-def (
     input v-recid
    ,input v-list-obj
    ,input v-list-doc
    ).
  run waitfram-hide in this-procedure .
  define variable p-ok as logical   no-undo .
    run save-def-analysis-obj (
      input  "xyz"
    , input  x-xyz-analysis.db-num
    , input  x-xyz-analysis.xyz-id
    , output p-ok
    ) .
    if p-ok then
   message
   "Интервалы ранжирования и типы документов запомнены для данного списка объектов по умолчанию" skip
   "Этот анализ будет использоваться в отчетах как анализ по умолчанию" skip
   x-xyz-analysis.xyz-id skip
   x-xyz-analysis.xyz-name
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
define variable v-old-izt  as character no-undo .
define variable v-old-amin  as character no-undo .
define variable v-old-acc-mat  as character no-undo .
define variable vt-Amin as character no-undo .
define variable t-izt   as character no-undo .
define variable t-Amin  as character no-undo .
define variable t-asm   as character no-undo .
define variable fl      as logical   no-undo .
fl = true .

    assign
    v-old-izt  = ""
    v-izt      = ""
    v-Amin     = ""
    v-old-Amin = ""
    v-acc-mat     =  ""
    v-old-acc-mat = ""
    .


define buffer buf2_XYZ-analysis-gds-obj for ub.XYZ-analysis-gds-obj   .
define buffer buf2_assortment-matrix for ub.assortment-matrix.
define buffer buf2_assortment-matrix-goods for ub.assortment-matrix-goods.


FOR EACH Buf_XYZ-analysis-obj WHERE
         Buf_XYZ-analysis-obj.XYZ-id = v-id AND
         Buf_XYZ-analysis-obj.db-num = v-db-num
         NO-LOCK
         :
        find first buf2_XYZ-analysis-gds-obj WHERE
                   buf2_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND
                   buf2_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND
                   buf2_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND
                   buf2_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND
                   buf2_XYZ-analysis-gds-obj.db-num   = v-db-num
                   NO-LOCK  no-error .

                find first buf2_assortment-matrix WHERE
                      buf2_assortment-matrix.asmt-status        = 0  AND
                      buf2_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND
                      buf2_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code
                      NO-LOCK no-error .
                find first buf2_assortment-matrix-goods WHERE
                      buf2_assortment-matrix-goods.asmg-status        = 0  AND
                      buf2_assortment-matrix-goods.asmt-id  =  buf2_assortment-matrix.asmt-id AND
                      buf2_assortment-matrix-goods.db-num   =  buf2_assortment-matrix.db-num  AND
                      buf2_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code
                      NO-LOCK no-error .

                 { gbl/gdsobjpr.i
                    Buf_XYZ-analysis-obj.obj-type
                    Buf_XYZ-analysis-obj.obj-code
                    ?
                    ?
                    ?
                    Buf_XYZ-analysis-goods.gds-code
                    t-amin
                    t-izt
                    v-gdop-min-stock
                    v-grop-max-stock
                    v-grop-level-always-presence
                    v-grop-min-order
                 }

             if not available buf2_assortment-matrix-goods then t-asm = "0" .
                                                           else t-asm = "1".

             if fl = true then do:
                  assign
                  fl =  false
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
