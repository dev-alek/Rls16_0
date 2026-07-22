&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

using ibs.th.str.alcohol.*.
/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE x_parts NO-UNDO LIKE parts.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование партии документа внешнего прихода закрытого на факт .

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc       as widget-handle no-undo.
define input  parameter h-call-prog         as handle    no-undo .
define input  parameter p-doc-code          as character no-undo .
define input  parameter p-gds-code          as integer   no-undo .
define input  parameter p-pl-code           as integer   no-undo .
define input  parameter p-in-code   as character no-undo .
define input  parameter p-part-code as character no-undo .
define input  parameter p-out-code  as character no-undo .
define input-output  parameter table for x_parts.

define variable chg-qnty      as   decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование партии документа ВнешПН факт".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|':u,h-call-prog,p-doc-code,p-gds-code,p-pl-code)"}
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }
{ gbl/cur-time.i }
{ str/lib-trn.i  }
{ trg/partscr.i  }
{ trg/partrqst.i }
{ str/plgdsfnd.i }
{ str/hvrdtax.i  }
{ gbl/key-rec.i  }
{ trg/partcopy.i }
{ trg/partrsrv.i }
{ trg/partsfnc.i }
{ gbl/chkleave.i }
{ cmp/strcodec.i }
{ str/cntrcode.i }
{ gbl/godendo.i  }
{ gbl/sel-date.i }
{ str/trdcalib.i }
{ gbl/alc-lib.i  }
{ gbl/thbjattr.i }

/* поле, разрешенное для изменения */
define variable v-enable-qnty          as character no-undo .
/* список возможных значений "cli-qnty,qnty,fact-qnty" */

define variable v-curr-r-b             as character no-undo .
define variable v-display-price-cli    as logical   no-undo .
define variable v-enable-price-cli     as logical   no-undo .
define variable v-enable-cli-exch-code as logical   no-undo .
define variable v-enable-contract      as logical   no-undo .

/* конфигурационные параметры */
define variable v-is-fin               as logical   no-undo .
define variable v-contract             as logical   no-undo .

define variable v-create-part              as logical   no-undo .
define variable v-goods-serial             as logical   no-undo .
define variable v-goods-twounit            as logical   no-undo .
define variable v-goods-petroleum          as logical   no-undo .
define variable v-alcohol-prod             as logical   no-undo .
define variable v-can-change-part-code     as logical   no-undo .
define variable v-can-change-supp          as logical   no-undo .

define variable v-new-parts-part-code      as character no-undo .
define variable v-same-currency            as logical   no-undo .
define variable v-fields-enabled           as logical   no-undo .
define variable v-undo-last                as logical   no-undo init false .
define variable v-price-cli                like ub.doc-line.price-rubl no-undo.
define variable v-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable v-price-road-tax           like ub.doc-line.price-rubl no-undo.
define variable v-price-other-exp          like ub.doc-line.price-rubl no-undo.
define variable v-price-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable v-price-without-abs        like ub.doc-line.price-rubl no-undo.
define variable v-price-slt                like ub.doc-line.price-rubl no-undo.
define variable v-price-no-slt             like ub.doc-line.price-rubl no-undo.
define variable v-price-vat                like ub.doc-line.price-rubl no-undo.
define variable v-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable v-price-rubl               like ub.doc-line.price-rubl no-undo.
define variable v-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable v-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable v-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable v-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable v-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable v-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable v-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable v-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable v-price-base               like ub.doc-line.price-base no-undo.
define variable v-price-road-tax-base      like ub.doc-line.price-base no-undo.
define variable v-price-other-exp-base     like ub.doc-line.price-base no-undo.
define variable v-price-transport-exp-base like ub.doc-line.price-base no-undo.
define variable v-price-without-abs-base   like ub.doc-line.price-base no-undo.
define variable v-price-slt-base           like ub.doc-line.price-base no-undo.
define variable v-price-no-slt-base        like ub.doc-line.price-base no-undo.
define variable v-price-vat-base           like ub.doc-line.price-base no-undo.
define variable v-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define variable v-supp-type                like x_parts.supp-type no-undo .
define variable v-supp-code                like x_parts.supp-code no-undo .
define variable v-modified-contract-code   as logical   no-undo .
define variable v-contract-code            like ub.contract.contract-code no-undo .
define variable v-modified-exch-code       as logical   no-undo .
define variable v-exch-code                like x_parts.exch-code no-undo .
define variable v-enable-price-rubl        as logical   no-undo .
define variable v-enable-price-base        as logical   no-undo .
define variable v-price-base-source        as character no-undo .
define variable v-alc-mark-db-num          as integer   no-undo .
define variable v-alc-mark-code            as integer   no-undo .
define variable v-alc-bottling-date        as date      no-undo .
define variable v-alc-ref-ab-path          as character no-undo .
define variable v-alc-quality-certif-path  as character no-undo .
define variable v-alc-certif-path          as character no-undo .
define variable v-alc-imp-type             as character no-undo.
define variable v-alc-imp-code             as integer   no-undo.
define variable v-parts-recid              as recid no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x_parts

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH x_parts SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH x_parts SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame x_parts
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame x_parts


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS x_parts.PS x_parts.supp-type ~
x_parts.supp-code x_parts.last-date
&Scoped-define ENABLED-TABLES x_parts
&Scoped-define FIRST-ENABLED-TABLE x_parts
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-prev b-next b-alc-attr ~
b-help RECT-2 RECT-3 RECT-4 RECT-1 fi-vat-pc fi-slt-pc r-supp ~
b-choose-last-date fi-last-date-offset fi-contract-prn-code r-contract ~
b-edit-price FI-goods-artic fi-gds-name FI-goods-prod-type-code ~
FI-clients-name FI-b-code fi-out-code FI-label-kolichestvo FI-label-ed-izm ~
FI-label-koefficient fi-unit-cli fi-unit fi-unit-2 fi-vat-type fi-slt-type ~
fi-supp fi-contract-name FI-label-cena FI-label-summa FI-label-val ~
val-price-cli val-rubl-code val-price-rubl val-base-code val-price-base
&Scoped-Define DISPLAYED-FIELDS x_parts.PS x_parts.cli-qnty ~
x_parts.cli-base-rate x_parts.qnty x_parts.fact-qnty x_parts.part-code ~
x_parts.cst-code x_parts.supp-type x_parts.supp-code x_parts.last-date ~
x_parts.price-cli x_parts.exch-code x_parts.price-rubl x_parts.price-base
&Scoped-define DISPLAYED-TABLES x_parts
&Scoped-define FIRST-DISPLAYED-TABLE x_parts
&Scoped-Define DISPLAYED-OBJECTS fi-vat-pc fi-slt-pc fi-last-date-offset ~
fi-contract-prn-code tot-price-cli tot-price-rubl tot-price-base ~
FI-goods-artic fi-gds-name FI-goods-prod-type-code FI-clients-name ~
FI-b-code fi-out-code FI-label-kolichestvo FI-label-ed-izm ~
FI-label-koefficient fi-unit-cli fi-unit fi-unit-2 fi-vat-type fi-slt-type ~
fi-supp fi-contract-name FI-label-cena FI-label-summa FI-label-val ~
val-price-cli val-rubl-code val-price-rubl val-base-code val-price-base

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-alc-attr
     LABEL "АлкАтр"
     SIZE 10 BY 1 TOOLTIP "Атрибуты алкогольной продукции".

DEFINE BUTTON b-choose-last-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-last-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".

DEFINE BUTTON b-edit-price
     LABEL "<->"
     SIZE 4.5 BY 1 TOOLTIP "Пересчет Сумм".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 9 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1.

DEFINE BUTTON b-next
     LABEL "&>>"
     SIZE 4.5 BY 1.

DEFINE BUTTON b-prev
     LABEL "&<<"
     SIZE 4.5 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 9 BY 1.

DEFINE BUTTON b-rest
     LABEL "Восс&тановить"
     SIZE 13 BY 1.

DEFINE BUTTON b-save
     LABEL "&Сохранить"
     SIZE 11 BY 1.

DEFINE BUTTON r-contract
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-supp"
     SIZE 3 BY .88 TOOLTIP "Список договоров по фирме".

DEFINE BUTTON r-exch-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-supp"
     SIZE 3 BY .88 TOOLTIP "Список валют".

DEFINE BUTTON r-supp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-supp"
     SIZE 3 BY .88 TOOLTIP "Список контрагентов".

DEFINE VARIABLE FI-b-code AS INTEGER FORMAT "999999999" INITIAL 0
     LABEL "Бар-код"
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI-clients-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-contract-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-contract-prn-code AS CHARACTER FORMAT "X(16)":U
     LABEL "Договор"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE fi-gds-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI-goods-artic AS CHARACTER FORMAT "X(40)":U
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 18.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI-goods-prod-type-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
      VIEW-AS TEXT
     SIZE 18.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FI-label-cena AS CHARACTER FORMAT "X(256)":U INITIAL "Цена"
      VIEW-AS TEXT
     SIZE 29.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FI-label-ed-izm AS CHARACTER FORMAT "X(256)":U INITIAL "Ед. Изм."
      VIEW-AS TEXT
     SIZE 10.75 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FI-label-koefficient AS CHARACTER FORMAT "X(256)":U INITIAL "Коэффициент"
      VIEW-AS TEXT
     SIZE 12.75 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FI-label-kolichestvo AS CHARACTER FORMAT "X(256)":U INITIAL "Количество"
      VIEW-AS TEXT
     SIZE 17.25 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FI-label-summa AS CHARACTER FORMAT "X(256)":U INITIAL "Сумма"
      VIEW-AS TEXT
     SIZE 23.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FI-label-val AS CHARACTER FORMAT "X(256)":U INITIAL "Вал."
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-last-date-offset AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-out-code AS CHARACTER FORMAT "X(40)":U
     LABEL "Статус"
      VIEW-AS TEXT
     SIZE 41 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-slt-pc AS DECIMAL FORMAT ">>9.9999999999":U INITIAL 0
     LABEL "%"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 TOOLTIP "% НП"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-slt-type AS CHARACTER FORMAT "X(256)":U
     LABEL "НП"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-supp AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 36.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-unit AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-unit-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-unit-cli AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-vat-pc AS DECIMAL FORMAT ">>9.9999999999":U INITIAL 0
     LABEL "%"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 TOOLTIP "% НДС"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-vat-type AS CHARACTER FORMAT "X(256)":U
     LABEL "НДС"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-price-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 22 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-price-cli AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 22 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-price-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 22 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE val-base-code AS INTEGER FORMAT ">>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE val-price-base AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 10.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE val-price-cli AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 10.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE val-price-rubl AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 10.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE val-rubl-code AS INTEGER FORMAT ">>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 88.75 BY 3.5.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 56.5 BY 4.58.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 88.88 BY 6.25.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 88.75 BY 4.67.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      x_parts SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 10
     b-prev AT ROW 1 COL 19
     b-next AT ROW 1 COL 23.5
     b-save AT ROW 1 COL 28
     b-rest AT ROW 1 COL 39
     b-alc-attr AT ROW 1 COL 52.13
     b-help AT ROW 1 COL 87
     x_parts.PS AT ROW 5.92 COL 59 NO-LABEL
          VIEW-AS EDITOR
          SIZE 30.75 BY 4.17
     x_parts.cli-qnty AT ROW 6.92 COL 13.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     x_parts.cli-base-rate AT ROW 6.92 COL 41 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.5 BY 1
          FGCOLOR 4
     x_parts.qnty AT ROW 8 COL 13.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     x_parts.fact-qnty AT ROW 9.08 COL 13.25 COLON-ALIGNED HELP
          "Укажите фактическое количество товара в учетных единицах"
          LABEL "Факт"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     x_parts.part-code AT ROW 10.83 COL 13.5 COLON-ALIGNED FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     fi-vat-pc AT ROW 11 COL 65.5 COLON-ALIGNED
     x_parts.cst-code AT ROW 12 COL 13.5 COLON-ALIGNED
          FORMAT "x(31)"
          VIEW-AS FILL-IN
          SIZE 32 BY 1
     fi-slt-pc AT ROW 12.08 COL 65.5 COLON-ALIGNED
     x_parts.supp-type AT ROW 13.17 COL 13.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9.25 BY 1
     x_parts.supp-code AT ROW 13.17 COL 23 COLON-ALIGNED NO-LABEL FORMAT "9999999999"
          VIEW-AS FILL-IN
          SIZE 13.5 BY 1
     r-supp AT ROW 13.25 COL 39.13
     x_parts.last-date AT ROW 14.38 COL 13.63 COLON-ALIGNED
          LABEL "Годен до"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     b-choose-last-date AT ROW 14.38 COL 27.13
     fi-last-date-offset AT ROW 14.38 COL 29 COLON-ALIGNED NO-LABEL
     fi-contract-prn-code AT ROW 15.67 COL 13.38 COLON-ALIGNED
     r-contract AT ROW 15.75 COL 33.5
     x_parts.price-cli AT ROW 18.5 COL 13.5 COLON-ALIGNED
          LABEL "По ТТН" FORMAT "->>,>>>,>>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 23.25 BY 1
     tot-price-cli AT ROW 18.5 COL 43 COLON-ALIGNED NO-LABEL
     x_parts.exch-code AT ROW 18.5 COL 66 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
          FGCOLOR 4
     r-exch-code AT ROW 18.5 COL 73
     x_parts.price-rubl AT ROW 19.58 COL 13.5 COLON-ALIGNED
          LABEL "Учет" FORMAT ">>,>>>,>>>,>>9.9999999999"
          VIEW-AS FILL-IN
          SIZE 23.25 BY 1
     tot-price-rubl AT ROW 19.58 COL 43 COLON-ALIGNED NO-LABEL
     b-edit-price AT ROW 20.25 COL 39.5
     x_parts.price-base AT ROW 20.71 COL 13.5 COLON-ALIGNED
          LABEL "Учет" FORMAT ">>,>>>,>>>,>>9.9999999999"
          VIEW-AS FILL-IN
          SIZE 23.25 BY 1
     tot-price-base AT ROW 20.71 COL 43 COLON-ALIGNED NO-LABEL
     FI-goods-artic AT ROW 2.42 COL 14.5 COLON-ALIGNED
     fi-gds-name AT ROW 2.42 COL 36.75 COLON-ALIGNED NO-LABEL
     FI-goods-prod-type-code AT ROW 3.5 COL 14.5 COLON-ALIGNED
     FI-clients-name AT ROW 3.5 COL 36.75 COLON-ALIGNED NO-LABEL
     FI-b-code AT ROW 4.67 COL 14.5 COLON-ALIGNED
     fi-out-code AT ROW 4.67 COL 45.5 COLON-ALIGNED
     FI-label-kolichestvo AT ROW 6.08 COL 13.25 COLON-ALIGNED NO-LABEL
     FI-label-ed-izm AT ROW 6.08 COL 30.5 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     FI-label-koefficient AT ROW 6.08 COL 41.25 COLON-ALIGNED NO-LABEL
     fi-unit-cli AT ROW 7.08 COL 30.63 COLON-ALIGNED NO-LABEL
     fi-unit AT ROW 8.21 COL 30.75 COLON-ALIGNED NO-LABEL
     fi-unit-2 AT ROW 9.29 COL 30.75 COLON-ALIGNED NO-LABEL
     fi-vat-type AT ROW 11.17 COL 54 COLON-ALIGNED
     fi-slt-type AT ROW 12.21 COL 54 COLON-ALIGNED
     fi-supp AT ROW 13.38 COL 40.88 COLON-ALIGNED NO-LABEL
     fi-contract-name AT ROW 15.83 COL 35.88 COLON-ALIGNED NO-LABEL
     FI-label-cena AT ROW 17.46 COL 13.5 COLON-ALIGNED NO-LABEL
     FI-label-summa AT ROW 17.46 COL 43 COLON-ALIGNED NO-LABEL
     FI-label-val AT ROW 17.46 COL 66.5 COLON-ALIGNED NO-LABEL
     val-price-cli AT ROW 18.63 COL 75.5 COLON-ALIGNED NO-LABEL
     val-rubl-code AT ROW 19.75 COL 66.25 COLON-ALIGNED NO-LABEL
     val-price-rubl AT ROW 19.75 COL 75.38 COLON-ALIGNED NO-LABEL
     val-base-code AT ROW 20.71 COL 66.25 COLON-ALIGNED NO-LABEL
     val-price-base AT ROW 20.96 COL 75.25 COLON-ALIGNED NO-LABEL
     RECT-2 AT ROW 5.83 COL 1
     RECT-3 AT ROW 10.58 COL 1
     RECT-4 AT ROW 17.21 COL 1.25
     RECT-1 AT ROW 2.17 COL 1
     SPACE(1.37) SKIP(16.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партия товара".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x_parts T "?" NO-UNDO ub parts
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       b-prev:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-rest IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-save IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN x_parts.cli-base-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN x_parts.cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN x_parts.cst-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN x_parts.exch-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN x_parts.fact-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-HELP                                         */
/* SETTINGS FOR FILL-IN x_parts.last-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN x_parts.part-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN x_parts.price-base IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN x_parts.price-cli IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN x_parts.price-rubl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
ASSIGN
       x_parts.PS:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN x_parts.qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-exch-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN x_parts.supp-code IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN tot-price-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-price-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-price-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "x_parts"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ESC OF FRAME Dialog-Frame /* Партия товара */
DO:
  /* предотвращаем откат транзакции редактирования всех партий */
  assign
    v-undo-last = true
  .
  apply "go":u to self .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Партия товара */
DO:
  define variable v-close-window as logical no-undo .

  if v-undo-last = true
  then do:
    return .
  end.

  run validate-qnty in this-procedure no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.

  run update-record in this-procedure
    ( output v-close-window
    ) no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Партия товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-alc-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-alc-attr Dialog-Frame
ON CHOOSE OF b-alc-attr IN FRAME Dialog-Frame /* АлкАтр */
DO:
  { gbl/stdbtn.i }

  define variable v-save-flag           as logical   no-undo .

  if v-alcohol-prod = true then do:
    run str/in-alc.w
      (input        parparentproc
      ,input        {&update}
      ,input p-gds-code
      ,input-output v-alc-mark-db-num
      ,input-output v-alc-mark-code
      ,input-output v-alc-bottling-date
      ,input-output v-alc-ref-ab-path
      ,input-output v-alc-quality-certif-path
      ,input-output v-alc-certif-path
      ,input-output v-alc-imp-type
      ,input-output v-alc-imp-code
      ,output       v-save-flag
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':u
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры in-alc.w" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return no-apply .
    end.

    define variable v-display-part-code as character no-undo .

    run partsfnc_get-parts-show-code in this-procedure
      (input  v-new-parts-part-code
      ,input  v-alc-mark-db-num
      ,input  v-alc-mark-code
      ,input  v-alc-bottling-date
      ,input  v-alcohol-prod
      ,output v-display-part-code
      ) .
    assign
      x_parts.part-code :screen-value = string(v-display-part-code
                                            ,x_parts.part-code :format
                                            )
    .

    /* todo  внести в транзакцию на выполнение */
      run trg/partps.p ( input p-gds-code
                       , input x_parts.in-code
                       , input x_parts.part-code
                       , input v-alc-mark-db-num
                       , input v-alc-mark-code
                       , input v-alc-bottling-date
                       , input v-alc-ref-ab-path
                       , input v-alc-quality-certif-path
                       , input v-alc-certif-path
                       , input v-alc-imp-type
                       , input v-alc-imp-code
                       ) no-error .

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-edit-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-edit-price Dialog-Frame
ON CHOOSE OF b-edit-price IN FRAME Dialog-Frame /* <-> */
DO:
  /* редактировать учётную цену партии */
  define variable v-parts-price-base      as decimal   no-undo .
  define variable v-parts-price-rubl      as decimal   no-undo .
  define variable v-orig-parts-price-base as decimal   no-undo .
  define variable v-orig-parts-price-rubl as decimal   no-undo .
  define variable v-action                as character no-undo .
  define variable v-parts-chg-qnty        as decimal   no-undo .

  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods   for ub.goods .
  define buffer buf_clients for ub.clients .

  if v-can-change-supp = false
  then do:
    assign
      v-parts-price-base = decimal(x_parts.price-base :screen-value)
      v-parts-price-rubl = decimal(x_parts.price-rubl :screen-value)
    .
  end.
  else do:
    if v-enable-price-rubl = true
    then do:
      assign
        v-parts-price-rubl = decimal(x_parts.price-rubl :screen-value)
      .
    end.
    else do:
      if  v-enable-price-cli = true
      and v-exch-code        = 0
      then do:
        assign
          v-parts-price-rubl = decimal(x_parts.price-cli :screen-value)
        .
      end.
    end.

    if v-enable-price-base = true
    then do:
      assign
        v-parts-price-base = decimal(x_parts.price-base :screen-value)
      .
    end.
    else do:
      if  v-enable-price-cli = true
      and v-exch-code        = (input frame {&frame-name} val-base-code)
      then do:
        assign
          v-parts-price-base = decimal(x_parts.price-cli :screen-value)
        .
      end.
    end.
  end.

  assign
    v-orig-parts-price-base = v-parts-price-base
    v-orig-parts-price-rubl = v-parts-price-rubl
  .

  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .

  find first buf_clients no-lock
    where buf_clients.obj-type = x_parts.supp-type :screen-value
      and buf_clients.obj-code = integer(x_parts.supp-code :screen-value)
    no-error .
  if not available buf_clients
  then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = buf_trn-doc.obj-type
        and buf_clients.obj-code = buf_trn-doc.obj-code
      .
  end.

  /* определяем редактируемое количество */
  assign
    v-parts-chg-qnty = decimal(x_parts.qnty :screen-value)
  .

  run trg/in-price.w
    (input parparentproc
    ,input-output v-parts-price-base /* p-price-base */
    ,input-output v-parts-price-rubl /* p-price-rubl */
    ,output v-action                 /* p-action     */
    ,input  buf_trn-doc.obj-type     /* p-obj-type   */
    ,input  buf_trn-doc.obj-code     /* p-obj-code   */
    ,input  buf_goods.artic          /* p-artic      */
    ,input  buf_goods.prod-type      /* p-prod-type  */
    ,input  buf_goods.prod-code      /* p-prod-code  */
    ,input  buf_clients.obj-type     /* p-supp-type  */
    ,input  buf_clients.obj-code     /* p-supp-code  */
    ,input  buf_trn-doc.base-rate    /* p-base-rate  */
    ,input  buf_trn-doc.base-scale   /* p-base-scale */
    ,input  v-parts-chg-qnty         /* p-parts-qnty */
    ) no-error .
  if error-status :error
  then do:
    return no-apply .
  end.

  if v-parts-price-rubl  <> v-orig-parts-price-rubl
  then do:
    if v-enable-price-rubl = true
    then do:
      assign
        x_parts.price-rubl :screen-value = string(v-parts-price-rubl
                                                 ,x_parts.price-rubl :format
                                                )
      .
    end.
    else do:
      if  v-enable-price-cli = true
      and v-exch-code        = 0
      then do:
        assign
          x_parts.price-cli :screen-value = string(v-parts-price-rubl
                                                ,x_parts.price-cli :format
                                                )
        .
      end.
    end.
  end.

  if v-parts-price-base  <> v-orig-parts-price-base
  then do:
    if v-enable-price-base = true
    then do:
      assign
        x_parts.price-base :screen-value = string(v-parts-price-base
                                              ,x_parts.price-base :format
                                              )
      .
    end.
    else do:
      if  v-enable-price-cli = true
      and v-exch-code        = (input frame {&frame-name} val-base-code)
      then do:
        assign
          x_parts.price-cli :screen-value = string(v-parts-price-base
                                                ,x_parts.price-cli :format
                                                )
        .
      end.
    end.
  end.

  run update-dependent-price in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
  { gbl/stdbtn.i }

  run check-current-modified in this-procedure
    no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
  run reposition-parts in this-procedure
    (input 'next':U
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
  { gbl/stdbtn.i }

  run check-current-modified in this-procedure
    no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.

  run reposition-parts in this-procedure
    (input 'prev':U
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }

  assign
    v-undo-last = true
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rest
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rest Dialog-Frame
ON CHOOSE OF b-rest IN FRAME Dialog-Frame /* Восстановить */
DO:
  { gbl/stdbtn.i }

  define variable lok               as logical no-undo init true .
  define variable v-record-modified as logical no-undo .

  run record-modified in this-procedure
    (output v-record-modified
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры record-modified" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.

  if v-record-modified
  then do:
    message
      "Запись была изменена." skip
      "Вы действительно хотите восстановить первоначалное значение?" skip
      view-as alert-box question buttons yes-no update lok .
  end.

  if lok
  then do:
    run disable-fields in this-procedure .
    run display-fields in this-procedure .
    run enable-fields  in this-procedure .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  { gbl/stdbtn.i }
  define variable v-close-window as logical no-undo .

  run update-record in this-procedure
    (output v-close-window
    ) no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.

  if v-close-window
  then do:
    run close-window .
    return .
  end.

  run disable-fields in this-procedure .
  run display-fields in this-procedure .
  run enable-fields  in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.cli-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.cli-qnty Dialog-Frame
ON LEAVE OF x_parts.cli-qnty IN FRAME Dialog-Frame /* По ТТН */
DO:
  run display-dependent-info in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.cli-qnty Dialog-Frame
ON RETURN OF x_parts.cli-qnty IN FRAME Dialog-Frame /* По ТТН */
DO:
  if v-create-part
  then do:
    run apply-focus-next-entry in this-procedure
      (input {&self-name}:handle
      ).
    return no-apply .
  end.
  else do:
    apply 'entry':u to b-exit .
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.cst-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.cst-code Dialog-Frame
ON RETURN OF x_parts.cst-code IN FRAME Dialog-Frame /* Номер ГТД */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.exch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.exch-code Dialog-Frame
ON LEAVE OF x_parts.exch-code IN FRAME Dialog-Frame /* exch-code */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "r-exch-code,r-contract,b-quit,b-rest,b-help":u /* p-button-list  */
    )
  then do:
    run validate-exch-code in this-procedure no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return no-apply .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.exch-code Dialog-Frame
ON RETURN OF x_parts.exch-code IN FRAME Dialog-Frame /* exch-code */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.fact-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.fact-qnty Dialog-Frame
ON LEAVE OF x_parts.fact-qnty IN FRAME Dialog-Frame /* Факт */
DO:

  run display-dependent-info in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.fact-qnty Dialog-Frame
ON RETURN OF x_parts.fact-qnty IN FRAME Dialog-Frame /* Факт */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-contract-prn-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-contract-prn-code Dialog-Frame
ON LEAVE OF fi-contract-prn-code IN FRAME Dialog-Frame /* Договор */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "r-contract,b-quit,b-rest,b-help":u /* p-button-list  */
    )
  then do:
    if input frame {&frame-name} fi-contract-prn-code <> fi-contract-prn-code
    then do:
      run validate-contract in this-procedure
        no-error .
      if error-status :error
      then do:
        message
          "Неправильный номер контракта" skip
          "" (input frame {&frame-name} fi-contract-prn-code) skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-contract-prn-code Dialog-Frame
ON RETURN OF fi-contract-prn-code IN FRAME Dialog-Frame /* Договор */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-last-date-offset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-last-date-offset Dialog-Frame
ON LEAVE OF fi-last-date-offset IN FRAME Dialog-Frame
DO:
  define variable v-last-date as date      no-undo .

  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .

  run godendo-offset-to-date in this-procedure
    (input  v-today                                         /* p-today  */
    ,input  (input frame {&frame-name} fi-last-date-offset) /* p-offset */
    ,output v-last-date                                     /* p-date   */
    ) .
  assign
    x_parts.last-date     :screen-value = string(v-last-date
                                              ,x_parts.last-date :format)
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-last-date-offset Dialog-Frame
ON RETURN OF fi-last-date-offset IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-slt-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-slt-pc Dialog-Frame
ON RETURN OF fi-slt-pc IN FRAME Dialog-Frame /* % */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-vat-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-vat-pc Dialog-Frame
ON RETURN OF fi-vat-pc IN FRAME Dialog-Frame /* % */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.last-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.last-date Dialog-Frame
ON LEAVE OF x_parts.last-date IN FRAME Dialog-Frame /* Годен до */
DO:
  run update-last-date-offset in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.last-date Dialog-Frame
ON RETURN OF x_parts.last-date IN FRAME Dialog-Frame /* Годен до */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.part-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.part-code Dialog-Frame
ON LEAVE OF x_parts.part-code IN FRAME Dialog-Frame /* Номер партии */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "b-quit,b-rest,b-help":u /* p-button-list  */
    )
    and v-alcohol-prod <> true
  then do:
    define variable v-part-code like x_parts.part-code no-undo .

    assign
      v-part-code = input frame {&frame-name} x_parts.part-code
    .

    run validate-part-code
      (input v-part-code      /* p-new-part-code  */
      ,input v-parts-recid    /* p-parts-recid    */
      ,input p-doc-code       /* p-doc-code       */
      ,input p-gds-code       /* p-gds-code       */
      ,input v-goods-serial   /* p-goods-serial   */
      ) no-error .
    if error-status :error
    then do:
      apply 'entry':u to x_parts.part-code .
      return no-apply .
    end.

    assign
      v-new-parts-part-code = v-part-code
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.part-code Dialog-Frame
ON RETURN OF x_parts.part-code IN FRAME Dialog-Frame /* Номер партии */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.price-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.price-base Dialog-Frame
ON LEAVE OF x_parts.price-base IN FRAME Dialog-Frame /* Учет */
DO:

  if v-same-currency
  then do:
    assign
      x_parts.price-rubl :screen-value = x_parts.price-base :screen-value
    .
  end.

  run display-dependent-info in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.price-base Dialog-Frame
ON RETURN OF x_parts.price-base IN FRAME Dialog-Frame /* Учет */
DO:
  define variable v-new-price-cli  like x_parts.price-cli  no-undo .
  define variable v-new-price-base like x_parts.price-rubl no-undo .
  define variable v-new-price-rubl like x_parts.price-rubl no-undo .

  if v-can-change-supp <> true
  then do:
    do with frame {&frame-name}:
      run trg/prc-calc.p
        (input  "price-base":U
        ,input  p-doc-code
        ,input  p-gds-code
        ,input  decimal(x_parts.price-cli  :screen-value )
        ,input  decimal(x_parts.price-base :screen-value )
        ,input  decimal(x_parts.price-rubl :screen-value )
        ,output v-new-price-cli
        ,output v-new-price-base
        ,output v-new-price-rubl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове программы пересчета цены prc-calc.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return .
      end.

      run display-price in this-procedure
        (input v-new-price-cli
        ,input v-new-price-base
        ,input v-new-price-rubl
        ).
    end. /* do with frame */
  end.


  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.price-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.price-cli Dialog-Frame
ON LEAVE OF x_parts.price-cli IN FRAME Dialog-Frame /* По ТТН */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "b-quit,b-rest,b-help":u /* p-button-list  */
    )
  then do:
    define variable v-new-price-cli  like x_parts.price-cli  no-undo .
    define variable v-new-price-base like x_parts.price-rubl no-undo .
    define variable v-new-price-rubl like x_parts.price-rubl no-undo .

    if v-can-change-supp <> true
    then do:
      do with frame {&frame-name}:
        run trg/prc-calc.p
          (input  "price-cli":U
          ,input  p-doc-code
          ,input  p-gds-code
          ,input  decimal(x_parts.price-cli  :screen-value )
          ,input  decimal(x_parts.price-base :screen-value )
          ,input  decimal(x_parts.price-rubl :screen-value )
          ,output v-new-price-cli
          ,output v-new-price-base
          ,output v-new-price-rubl
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове программы пересчета цены prc-calc.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return .
        end.

        run display-price in this-procedure
          (input v-new-price-cli
          ,input v-new-price-base
          ,input v-new-price-rubl
          ).
      end. /* do with frame */
    end.
    else do:
      run update-dependent-price in this-procedure .
    end.
  end.

  run display-dependent-info in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.price-cli Dialog-Frame
ON RETURN OF x_parts.price-cli IN FRAME Dialog-Frame /* По ТТН */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.price-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.price-rubl Dialog-Frame
ON LEAVE OF x_parts.price-rubl IN FRAME Dialog-Frame /* Учет */
DO:
  if v-can-change-supp = true
  then do:
    run update-dependent-price in this-procedure .
  end.

  run display-dependent-info in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.price-rubl Dialog-Frame
ON RETURN OF x_parts.price-rubl IN FRAME Dialog-Frame /* Учет */
DO:
  define variable v-new-price-cli  like x_parts.price-cli  no-undo .
  define variable v-new-price-base like x_parts.price-rubl no-undo .
  define variable v-new-price-rubl like x_parts.price-rubl no-undo .

  if v-can-change-supp <> true
  then do:
    do with frame {&frame-name}:
      run trg/prc-calc.p
        (input  "price-rubl":U
        ,input  p-doc-code
        ,input  p-gds-code
        ,input  decimal(x_parts.price-cli  :screen-value )
        ,input  decimal(x_parts.price-base :screen-value )
        ,input  decimal(x_parts.price-rubl :screen-value )
        ,output v-new-price-cli
        ,output v-new-price-base
        ,output v-new-price-rubl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове программы пересчета цены prc-calc.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return .
      end.

      run display-price in this-procedure
        (input v-new-price-cli
        ,input v-new-price-base
        ,input v-new-price-rubl
        ).
    end. /* do with frame */
  end.

  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.PS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.PS Dialog-Frame
ON RETURN OF x_parts.PS IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.qnty Dialog-Frame
ON LEAVE OF x_parts.qnty IN FRAME Dialog-Frame /* По док-ту */
DO:
  run display-dependent-info in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.qnty Dialog-Frame
ON RETURN OF x_parts.qnty IN FRAME Dialog-Frame /* По док-ту */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-contract Dialog-Frame
ON CHOOSE OF r-contract IN FRAME Dialog-Frame /* r-supp */
DO:
  { gbl/stdbtn.i }

  run validate-supp in this-procedure
    (input (input frame {&frame-name} x_parts.supp-type)
    ,input (input frame {&frame-name} x_parts.supp-code)
    ) no-error .
  if error-status :error
  then do:
    message
      "Неправильно задан поставщик" skip
      "" (input frame {&frame-name} x_parts.supp-type)
         (input frame {&frame-name} x_parts.supp-code) skip
      view-as alert-box error .
    undo, return no-apply .
  end.

  run choose-contract in this-procedure
    (input (input frame {&frame-name} x_parts.supp-type)
    ,input (input frame {&frame-name} x_parts.supp-code)
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-contract Dialog-Frame
ON LEAVE OF r-contract IN FRAME Dialog-Frame /* r-supp */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "fi-contract-prn-code,r-contract,b-quit,b-rest,b-help":u /* p-button-list  */
    )
  then do:
    if input frame {&frame-name} fi-contract-prn-code <> fi-contract-prn-code
    then do:
      run validate-contract in this-procedure
        no-error .
      if error-status :error
      then do:
        message
          "Неправильный номер контракта" skip
          "" (input frame {&frame-name} fi-contract-prn-code) skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-exch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-exch-code Dialog-Frame
ON CHOOSE OF r-exch-code IN FRAME Dialog-Frame /* r-supp */
DO:
  { gbl/stdbtn.i }

  run choose-exch-code in this-procedure
    (input (input frame {&frame-name} x_parts.exch-code)
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-exch-code Dialog-Frame
ON LEAVE OF r-exch-code IN FRAME Dialog-Frame /* r-supp */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "exch-code,r-contract,b-quit,b-rest,b-help":u /* p-button-list  */
    )
  then do:
    run validate-exch-code in this-procedure no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return no-apply .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-supp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-supp Dialog-Frame
ON CHOOSE OF r-supp IN FRAME Dialog-Frame /* r-supp */
DO:
  { gbl/stdbtn.i }

  define variable v-select-supp-type as character no-undo .
  define variable v-select-supp-code as integer   no-undo .

  assign
    v-select-supp-type = input frame {&frame-name} x_parts.supp-type
    v-select-supp-code = input frame {&frame-name} x_parts.supp-code
  .

  run str/clisel.p
    (input parparentproc
    ,input-output v-select-supp-type /* p-supp-type */
    ,input-output v-select-supp-code /* p-supp-code */
    ) no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.

  assign
    x_parts.supp-type :screen-value = string(v-select-supp-type
                                          , x_parts.supp-type :format )
    x_parts.supp-code :screen-value = string(v-select-supp-code
                                          , x_parts.supp-code :format )
  .

  run validate-supp in this-procedure
    (input (input frame {&frame-name} x_parts.supp-type)
    ,input (input frame {&frame-name} x_parts.supp-code)
    ) no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-supp Dialog-Frame
ON LEAVE OF r-supp IN FRAME Dialog-Frame /* r-supp */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "supp-type,supp-code,r-supp,b-quit,b-rest,b-help":u /* p-button-list  */
    )
  then do:
    if  input frame {&frame-name} x_parts.supp-code <> 0
    and input frame {&frame-name} x_parts.supp-code <> ?
    then do:
      run validate-supp in this-procedure
        (input (input frame {&frame-name} x_parts.supp-type)
        ,input (input frame {&frame-name} x_parts.supp-code)
        ) no-error .
      if error-status :error
      then do:
        apply 'entry':u to x_parts.supp-code.
        return no-apply .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.supp-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.supp-code Dialog-Frame
ON LEAVE OF x_parts.supp-code IN FRAME Dialog-Frame /* supp-code */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "supp-type,supp-code,r-supp,b-quit,b-rest,b-help":u /* p-button-list  */
    )
  then do:
    if  input frame {&frame-name} x_parts.supp-code <> 0
    and input frame {&frame-name} x_parts.supp-code <> ?
    then do:
      run validate-supp in this-procedure
        (input (input frame {&frame-name} x_parts.supp-type)
        ,input (input frame {&frame-name} x_parts.supp-code)
        ) no-error .
      if error-status :error
      then do:
        apply 'entry':u to x_parts.supp-code.
        return no-apply .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.supp-code Dialog-Frame
ON RETURN OF x_parts.supp-code IN FRAME Dialog-Frame /* supp-code */
DO:
  define variable v-seleck-ok as logical   no-undo .
  define variable v-obj-type like x_parts.obj-type no-undo .
  define variable v-obj-code like x_parts.obj-code no-undo .

  if input frame {&frame-name} x_parts.supp-code = ?
  or input frame {&frame-name} x_parts.supp-code = 0
  then do:
    run ref/selcli.p
      (input  parparentproc /* parparentproc  */
      ,input  ?             /* h-call-prog    */
      ,input  {&all}        /* p-client-types */
      ,input no /*lock-cli-type*/
      ,output v-seleck-ok   /* p-select-ok    */
      ,output v-obj-type    /* p-cli-type     */
      ,output v-obj-code    /* p-cli-code     */
      ) .
    if v-seleck-ok = true
    then do:
      assign
        x_parts.supp-type :screen-value = string(v-obj-type)
        x_parts.supp-code :screen-value = string(v-obj-code)
      .
    end.
  end.

  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME x_parts.supp-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.supp-type Dialog-Frame
ON LEAVE OF x_parts.supp-type IN FRAME Dialog-Frame /* Поставщик */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "supp-type,supp-code,r-supp,b-quit,b-rest,b-help":u /* p-button-list  */
    )
  then do:
    if  input frame {&frame-name} x_parts.supp-code <> 0
    and input frame {&frame-name} x_parts.supp-code <> ?
    then do:
      run validate-supp in this-procedure
        (input (input frame {&frame-name} x_parts.supp-type)
        ,input (input frame {&frame-name} x_parts.supp-code)
        ) no-error .
      if error-status :error
      then do:
        apply 'entry':u to x_parts.supp-code .
        return no-apply .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL x_parts.supp-type Dialog-Frame
ON RETURN OF x_parts.supp-type IN FRAME Dialog-Frame /* Поставщик */
DO:
  run apply-focus-next-entry in this-procedure
    (input {&self-name}:handle
    ).
  return no-apply .

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

{ gbl/ed_date.i
  x_parts.last-date
  " "
  " "
  "'Годен до &1 (для партии товара, включительно)'"
}

on choose of b-choose-last-date in frame {&frame-name}
do:
  run sel-date in this-procedure
    (input x_parts.last-date :handle
    ,input "Годен до &1 (для партии товара)"
    ) .
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

/* не открываем транзакцию */
/* для того, чтобы кнопка Отказ отменяла изменения последней партии */
MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  { gbl/getcntxt.i get }

  run init-proc no-error .
  if error-status :error
  then do:
    undo MAIN-BLOCK, LEAVE MAIN-BLOCK .
  end.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE apply-focus-next-entry Dialog-Frame
PROCEDURE apply-focus-next-entry :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-widget-handle as handle no-undo .

  define variable v-apply-entry as logical no-undo .

  assign
    v-apply-entry = false
  .

  &scop apply_focus ~
  if v-apply-entry ~
  then do: ~
    if ~{&widget~} :sensitive ~
    then do: ~
      apply 'entry':u to ~{&widget~} . ~
      return . ~
    end. ~
  end. ~
  if ~{&widget~} :handle = p-widget-handle ~
  then do: ~
    assign ~
      v-apply-entry = true ~
    . ~
  end.

  do with frame {&frame-name}
  :
    &scop widget x_parts.cli-qnty
    {&apply_focus}
    &scop widget x_parts.qnty
    {&apply_focus}
    &scop widget x_parts.fact-qnty
    {&apply_focus}
    &scop widget x_parts.part-code
    {&apply_focus}
    &scop widget x_parts.cst-code
    {&apply_focus}
    &scop widget x_parts.supp-type
    {&apply_focus}
    &scop widget x_parts.supp-code
    {&apply_focus}
    &scop widget x_parts.last-date
    {&apply_focus}
    &scop widget fi-last-date-offset
    {&apply_focus}
    &scop widget fi-contract-prn-code
    {&apply_focus}
    &scop widget x_parts.price-cli
    {&apply_focus}
    &scop widget x_parts.exch-code
    {&apply_focus}
    &scop widget x_parts.price-rubl
    {&apply_focus}
    &scop widget x_parts.price-base
    {&apply_focus}
    &scop widget fi-vat-pc
    {&apply_focus}
    &scop widget fi-slt-pc
    {&apply_focus}
    &scop widget b-exit
    {&apply_focus}

    assign
      v-apply-entry = true
    .
    if v-apply-entry = true
    then do:
      apply 'entry':u to b-exit .
    end.
  end. /* do with frame */

  &undef widget
  &undef apply_focus

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-current-modified Dialog-Frame
PROCEDURE check-current-modified :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable lok as logical no-undo .
  define variable v-record-modified as logical no-undo .

  if v-fields-enabled
  then do:

    run record-modified in this-procedure
      (output v-record-modified
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры record-modified" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-record-modified = false
    then do:
      /* запись не менялась */
      return . /* --->>>--- */
    end.

    message
      "Партия была изменена." skip
      "ДА"     {&tabulation} "сохранить изменения и перейти к другой записи." skip
      "НЕТ"    {&tabulation} "не сохранять изменения и перейти к другой записи." skip
      "ОТМЕНА" {&tabulation} "не переходить к другой записи." skip
      view-as alert-box question button yes-no-cancel update lok .

    if lok = true
    then do:
      define variable v-close-window as logical no-undo .
      run update-record in this-procedure
        (output v-close-window
        ) no-error .
      if error-status :error
      then do:
        undo, return error .
      end.

      /* запись сохранена, можно переместиться к другой записи */
      return .
    end.

    if lok = false
    then do:
      /* запись не сохранена, можно переместиться к другой записи */
      return .
    end.

    if lok = ?
    then do:
      /* запись не сохранена, не перемещаемся к другой записи */
      undo, return error .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-contract Dialog-Frame
PROCEDURE choose-contract :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter v-supp-type as character no-undo .
  define input  parameter v-supp-code as integer   no-undo .

  define buffer buf_trn-doc for ub.trn-doc .

  define variable v-host-code as integer   no-undo .

  do
  transaction on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      .

    { gbl/hostcode.i
      buf_trn-doc.obj-type
      buf_trn-doc.obj-code
      v-host-code
    }

    define buffer buf_contract for ub.contract .
    run check-contract-code in this-procedure
      (input  "choose":u
      ,input  v-host-code
      ,input  v-supp-type
      ,input  v-supp-code
      ,input  ?
      ,input  parparentproc
      ,input  buf_trn-doc.doc-date
      ,input  ""
      ,output v-contract-code
      ) no-error .
    if error-status :error
    or v-contract-code = ?
    or v-contract-code = 0
    then do:
      if return-value <> ""
      or error-status :get-message(1) <> ""
      then do:
        message
          "Ошибка при заведении номера договора." skip
          return-value skip
          error-status :get-message(1) skip
          view-as alert-box error.
      end.
      return error.
    end.

    assign
      v-modified-contract-code = true
    .

    find first buf_contract no-lock
      where buf_contract.host-code     = v-host-code
        and buf_contract.contract-code = v-contract-code
      .
    display
      buf_contract.contract-prn-code @ fi-contract-prn-code
      substitute("&1 Вн.н. &2"
                ,string(buf_contract.contract-date,'99/99/9999':u)
                ,v-contract-code) @ fi-contract-name
      with frame {&frame-name} .
    assign
      fi-contract-prn-code
    .

    assign
      v-modified-exch-code = true
      v-exch-code          = buf_contract.curr-code
    .
    run update-exch-code-dependent in this-procedure .

    assign
      v-display-price-cli    = true
      v-enable-price-cli     = true
      v-enable-cli-exch-code = false
    .
    run update-enable-price-cli in this-procedure .
    run update-exch-code-enable in this-procedure .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-exch-code Dialog-Frame
PROCEDURE choose-exch-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter v-exch-code as integer   no-undo .

  define buffer buf_currency for ub.currency .

  define variable v-repos-recid as recid     no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_currency no-lock
      where buf_currency.curr-code = v-exch-code
      no-error .
    if available buf_currency
    then do:
      assign
        v-repos-recid = recid(buf_currency)
      .
    end.
    else do:
      assign
        v-repos-recid = ?
      .
    end.

    run ref/currency.w
      (input parparentproc
      ,input "b-sel"
      ,input-output v-repos-recid
      ).
    if v-repos-recid <> ?
    then do:
      find first buf_currency no-lock
        where recid( buf_currency ) = v-repos-recid
        no-error .
      if available buf_currency
      then do:
        do with frame {&frame-name}
        :
          assign
            x_parts.exch-code :screen-value = string(buf_currency.curr-code
                                                  ,x_parts.exch-code :format
                                                  )
            val-price-cli   :screen-value = string(buf_currency.curr-abbr
                                                  ,val-price-cli  :format
                                                  )
          .
        end. /* do with frame */
      end.

      run validate-exch-code in this-procedure no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return no-apply .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear-contract-value Dialog-Frame
PROCEDURE clear-contract-value :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_currency for ub.currency .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      assign
        v-modified-contract-code           = true
        v-contract-code                    = 0
        fi-contract-prn-code               = ""
        fi-contract-prn-code :screen-value = ""
        fi-contract-name     :screen-value = ""
        x_parts.price-cli      :screen-value = ""
        v-modified-exch-code               = true
        v-exch-code                        = 0
      .

      find first buf_currency no-lock
        where buf_currency.curr-code = v-exch-code
        no-error .
      if available buf_currency
      then do:
        assign
          x_parts.exch-code :screen-value = string(buf_currency.curr-code
                                                ,x_parts.exch-code :format
                                                )
          val-price-cli   :screen-value = string(buf_currency.curr-abbr
                                                ,val-price-cli  :format
                                                )
        .
      end.
    end. /* do with frame */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE close-window Dialog-Frame
PROCEDURE close-window :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  assign
    v-undo-last = true
  .

  apply "go":u to frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE determine-enable-qnty Dialog-Frame
PROCEDURE determine-enable-qnty :
define output parameter p-enable-qnty  as character no-undo .
    assign
     /* p-enable-qnty = "fact-qnty":u */
     p-enable-qnty = "cli-qnty":u
    .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-fields Dialog-Frame
PROCEDURE disable-fields :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do with frame {&frame-name}:
    assign
      x_parts.PS         :read-only = true
    .

    assign
      b-alc-attr :sensitive = false
      b-alc-attr :visible   = false
    .

    assign
      x_parts.part-code      :sensitive = false
      x_parts.cst-code       :sensitive = false
      x_parts.last-date      :sensitive = false
      b-choose-last-date   :sensitive = false
      fi-last-date-offset  :sensitive = false

      x_parts.price-cli      :sensitive = false
      x_parts.price-base     :sensitive = false
      x_parts.price-rubl     :sensitive = false
      b-edit-price         :sensitive = false
      fi-vat-pc            :sensitive = false
      fi-slt-pc            :sensitive = false

      x_parts.qnty           :sensitive = false
      x_parts.fact-qnty      :sensitive = false
      x_parts.cli-qnty       :sensitive = false

      x_parts.supp-type      :sensitive = false
      x_parts.supp-code      :sensitive = false
      r-supp               :sensitive = false
      fi-contract-prn-code :sensitive = false
      r-contract           :sensitive = false
      x_parts.exch-code      :sensitive = false
      r-exch-code          :sensitive = false
    .

    assign
      fi-vat-pc :fgcolor = ?
      fi-slt-pc :fgcolor = ?
    .

    assign
      b-exit :label in frame {&frame-name} = "&Выход"
    .

    assign
      b-save               :sensitive = false
      b-quit               :sensitive = false
      b-rest               :sensitive = false
    .

    assign
      v-fields-enabled = false
    .

  end. /* do with frame */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-dependent-info Dialog-Frame
PROCEDURE display-dependent-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-fact-qnty as decimal no-undo .

  /* обновление зависимой информации */
  do with frame {&frame-name}:

    if v-goods-twounit = false
    then do:
      if x_parts.cli-qnty :sensitive
      then do:
        assign
          x_parts.fact-qnty :screen-value = string( decimal(x_parts.cli-qnty :screen-value)
                                                * decimal(x_parts.cli-base-rate :screen-value)
                                              , x_parts.fact-qnty :format )
          x_parts.qnty :screen-value = x_parts.fact-qnty :screen-value
        .
      end.

      if x_parts.qnty :sensitive
      then do:
        if x_parts.cli-qnty :visible = true
        then do:
          assign
            x_parts.cli-qnty :screen-value = string( decimal(x_parts.qnty :screen-value)
                                                  / decimal(x_parts.cli-base-rate :screen-value)
                                                , x_parts.cli-qnty :format )
          .
        end.
        if x_parts.fact-qnty :visible
        then do:
          assign
            x_parts.fact-qnty :screen-value = x_parts.qnty :screen-value
          .
        end.
      end.
    end.

    assign
      fi-label-summa :screen-value = string("Сумма " + x_parts.fact-qnty :label)
      tot-price-rubl :screen-value = string(decimal(x_parts.fact-qnty :screen-value)
                                            * decimal(x_parts.price-rubl :screen-value)
                                           , tot-price-cli :format )
      tot-price-base :screen-value = string(decimal(x_parts.fact-qnty :screen-value)
                                            * decimal(x_parts.price-base :screen-value)
                                           , tot-price-cli :format )
    .
    if tot-price-cli :visible
    then do:
      assign
        tot-price-cli  :screen-value = string(decimal(x_parts.cli-qnty :screen-value)
                                              * decimal(x_parts.price-cli :screen-value)
                                             , tot-price-cli :format )
      .
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-fields Dialog-Frame
PROCEDURE display-fields :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-frame-title as character no-undo .

  define variable v-host-code like ub.sysconf.host-code no-undo .
  define variable v-base-code like ub.sysconf.base-code no-undo .

  define buffer buf_parts        for x_parts .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_goods        for ub.goods .
  define buffer buf_clients      for ub.clients .
  define buffer buf_currency     for ub.currency .
  define buffer buf_supp-clients for ub.clients .

  do with frame {&frame-name}:

    define variable v-old-immediate-display as logical no-undo .
    assign
      v-old-immediate-display = session:immediate-display
    .
    if v-old-immediate-display = yes
    then do:
      assign
        session:immediate-display = no
      .
    end.

    assign
      x_parts.price-cli         :screen-value = ""
      x_parts.price-base        :screen-value = ""
      x_parts.price-rubl        :screen-value = ""
      x_parts.cli-qnty          :screen-value = ""
      x_parts.qnty              :screen-value = ""
      x_parts.fact-qnty         :screen-value = ""
      x_parts.cli-base-rate     :screen-value = ""
      x_parts.part-code         :screen-value = ""
      x_parts.cst-code          :screen-value = ""
      x_parts.last-date         :screen-value = ""
      fi-last-date-offset       :screen-value = ""
      x_parts.PS                :screen-value = ""
      fi-vat-type             :screen-value = ""
      fi-vat-pc               :screen-value = ""
      fi-slt-type             :screen-value = ""
      fi-slt-pc               :screen-value = ""
      fi-unit-cli             :screen-value = ""
      val-price-cli           :screen-value = ""
      val-price-base          :screen-value = ""
      val-base-code           :screen-value = ""
      val-price-rubl          :screen-value = ""
      val-rubl-code           :screen-value = ""
      FI-goods-artic          :screen-value = ""
      FI-goods-prod-type-code :screen-value = ""
      fi-gds-name             :screen-value = ""
      fi-unit                 :screen-value = ""
      fi-unit-2               :screen-value = ""
      fi-clients-name         :screen-value = ""
      FI-b-code               :screen-value = ""
    .

    assign
      v-supp-type                           = ""
      v-supp-code                           = ?
      x_parts.supp-type         :screen-value = ""
      x_parts.supp-code         :screen-value = ""
      v-contract-code                       = 0
      fi-contract-prn-code                  = ""
      fi-contract-prn-code    :screen-value = ""
      fi-contract-name        :screen-value = ""
      v-exch-code                           = 0
      v-alc-mark-db-num                     = 0
      v-alc-mark-code                       = 0
      v-alc-bottling-date                   = ?
      v-alc-ref-ab-path                     = ""
      v-alc-quality-certif-path             = ""
      v-alc-certif-path                     = ""
    .

    find first buf_currency no-lock
      where buf_currency.curr-code = v-exch-code
      no-error .
    if available buf_currency
    then do:
      assign
        x_parts.exch-code :screen-value = string(buf_currency.curr-code
                                              ,x_parts.exch-code :format
                                              )
        val-price-cli   :screen-value = string(buf_currency.curr-abbr
                                              ,val-price-cli  :format
                                              )
      .
    end.

    find first buf_goods no-lock where
               buf_goods.gds-code = p-gds-code no-error .
               if error-status :error then do:
                  return error return-value .
               end.

    find first buf_parts no-lock where
               buf_parts.artic = buf_goods.artic and
               buf_parts.prod-type = buf_goods.prod-type and
               buf_parts.prod-code = buf_goods.prod-code and
               buf_parts.in-code   = p-in-code and
               buf_parts.part-code = p-part-code and
               buf_parts.out-code  = p-out-code
      no-error .
    if available buf_parts
    then do:
      v-parts-recid = recid(buf_parts)  .
      define variable v-root-node   as integer no-undo .

      /* корневой узел шкалы */
      { gbl/rootnode.i
        buf_parts.artic
        buf_parts.prod-type
        buf_parts.prod-code
        v-root-node
      }

      { gbl/hostcode.i
        buf_parts.obj-type
        buf_parts.obj-code
        v-host-code
      }

      /* бар-код партии */
      define variable v-b-code like ub.bar-code.b-code no-undo .
      { gbl/partbcod.i
        buf_parts
        v-b-code
        no-error
      }

      /* производитель */
      find first buf_clients no-lock
        where buf_clients.obj-type = buf_parts.prod-type
          and buf_clients.obj-code = buf_parts.prod-code
        no-error .

      define variable v-display-cli-info as logical no-undo .

      assign
        v-display-cli-info = (buf_parts.in-code = buf_parts.out-code
                              and buf_parts.is-supp
                             )
      .

      assign
        fi-unit-cli          :visible = v-display-cli-info
        val-price-cli        :visible = v-display-cli-info
        x_parts.cli-base-rate  :visible = v-display-cli-info
        x_parts.exch-code      :visible = v-display-cli-info
        r-exch-code          :visible = v-display-cli-info
        x_parts.price-cli      :visible = v-display-cli-info
        x_parts.cli-qnty       :visible = v-display-cli-info
        tot-price-cli        :visible = v-display-cli-info
        FI-label-koefficient :visible = v-display-cli-info
      .

      if v-display-cli-info
      then do:
        assign
          x_parts.price-cli     :screen-value = string(buf_parts.price-cli
                                                        ,x_parts.price-cli:format)
          x_parts.cli-qnty      :screen-value = string(buf_parts.cli-qnty
                                                        ,x_parts.cli-qnty:format)

        .

        find first buf_doc-line no-lock
          where buf_doc-line.doc-code  = buf_parts.out-code
            and buf_doc-line.artic     = buf_parts.artic
            and buf_doc-line.prod-type = buf_parts.prod-type
            and buf_doc-line.prod-code = buf_parts.prod-code
          no-error .

        if available buf_doc-line
        then do:
          assign
            fi-unit-cli         :screen-value = string(buf_doc-line.unit-cli
                                                          ,fi-unit-cli:format)
          .
        end.

        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if available buf_trn-doc
        then do:
          assign
            v-frame-title = "Документ №  " + buf_trn-doc.doc-code
          .
        end.
      end.

      assign
        x_parts.price-base    :screen-value = string(buf_parts.price-base
                                                      ,x_parts.price-base :format)
        x_parts.price-rubl    :screen-value = string(buf_parts.price-rubl
                                                      ,x_parts.price-rubl :format)
        x_parts.qnty          :screen-value = string(buf_parts.qnty
                                                      ,x_parts.qnty :format)
        x_parts.fact-qnty     :screen-value = string(buf_parts.fact-qnty
                                                      ,x_parts.fact-qnty :format)
        x_parts.cli-base-rate :screen-value = string(buf_parts.cli-base-rate
                                                      ,x_parts.cli-base-rate :format)
        x_parts.cst-code      :screen-value = string(buf_parts.cst-code
                                                      ,x_parts.cst-code :format)
        x_parts.last-date     :screen-value = string(buf_parts.last-date
                                                      ,x_parts.last-date :format)
        fi-vat-type         :screen-value = string(buf_parts.vat-type
                                                      ,fi-vat-type :format)
        fi-vat-pc           :screen-value = string(buf_parts.VAT-pc
                                                      ,fi-vat-pc :format)
        fi-slt-type         :screen-value = string(buf_parts.slt-type
                                                      ,fi-slt-type :format)
        fi-slt-pc           :screen-value = string(buf_parts.SLT-pc
                                                      ,fi-slt-pc :format)
        x_parts.PS            :screen-value = string(buf_parts.PS )

        fi-out-code         :screen-value = (if buf_parts.out-code = {&free-code}
                                             then "свободно"
                                             else
                                               ( if buf_parts.out-code = {&output-code}
                                                 then "расход"
                                                 else "резерв"
                                               )
                                            )
        v-alc-mark-db-num                 = buf_parts.mark-db-num
        v-alc-mark-code                   = buf_parts.mark-code
        v-alc-bottling-date               = buf_parts.alc-bottling-date
        v-alc-ref-ab-path                 = buf_parts.alc-ref-ab-path
        v-alc-quality-certif-path         = buf_parts.alc-quality-certif-path
        v-alc-certif-path                 = buf_parts.alc-certif-path
      .

      /* Для алкогольной продукции в коде партии показываем
         код акцизной марки и дату разлива*/
      define variable v-display-part-code as character no-undo .

      run partsfnc_get-parts-show-code in this-procedure
        (input  buf_parts.part-code
        ,input  buf_parts.mark-db-num
        ,input  buf_parts.mark-code
        ,input  buf_parts.alc-bottling-date
        ,input  v-alcohol-prod
        ,output v-display-part-code
        ) .
      assign
        x_parts.part-code :screen-value = string(v-display-part-code
                                              ,x_parts.part-code :format
                                              )
      .

      run update-last-date-offset in this-procedure .


      /* показываем поставщика партии */
      assign
        v-supp-type = buf_parts.supp-type
        v-supp-code = buf_parts.supp-code
      .
      assign
        x_parts.supp-type     :screen-value = string(v-supp-type
                                                      , x_parts.supp-type :format )
        x_parts.supp-code     :screen-value = string(v-supp-code
                                                      , x_parts.supp-code :format )
      .

      /* показываем контракт партии */
      assign
        v-contract-code = buf_parts.contract-code
      .
      if v-contract-code <> 0
      then do:
        define buffer buf_contract for ub.contract .
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = v-contract-code
          no-error .
        if not available buf_contract
        then do:
          message
            "Не найден контракт" skip
            "Объект" buf_parts.obj-type buf_parts.obj-code skip
            "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
            "Партия" buf_parts.in-code buf_parts.part-code skip
            "Документ" buf_parts.out-code skip
            "Код фирмы" v-host-code skip
            "Код контракта" v-contract-code skip
            view-as alert-box error .
        end.
        else do:
          assign
            fi-contract-prn-code               = buf_contract.contract-prn-code
            fi-contract-prn-code :screen-value = string(buf_contract.contract-prn-code
                                                       , fi-contract-prn-code :format )
            fi-contract-name     :screen-value =
              substitute("&1 Вн.н. &2"
                        ,string(buf_contract.contract-date,'99/99/9999':u)
                        ,v-contract-code)
          .
        end.
      end.

      find buf_currency no-lock
        where buf_currency.curr-code = buf_parts.exch-code
        no-error .
      if available buf_currency
      then do:
        assign
          v-exch-code = buf_parts.exch-code
        .
        run update-exch-code-dependent in this-procedure .
      end.

      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        .
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
        .

      find first buf_supp-clients no-lock
        where buf_supp-clients.obj-type = string(x_parts.supp-type :screen-value)
          and buf_supp-clients.obj-code = integer(x_parts.supp-code :screen-value)
        no-error .
      if available buf_supp-clients
      then do:
        assign
          fi-supp :screen-value = buf_supp-clients.obj-name
        .
      end.

      { gbl/basecode.i
        v-host-code
        v-base-code
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении кода базовой валюты для фирмы" v-host-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.

      find first buf_currency no-lock
        where buf_currency.curr-code = v-base-code
        no-error .
      if available buf_currency
      then do:
        assign
          val-price-base :screen-value = buf_currency.curr-abbr
          val-base-code  :screen-value = string(buf_currency.curr-code
                                               ,val-base-code :format
                                               )
        .
      end.

      /* определяем совпадение базовой и р_у_блевой учетных валют */
      assign
        v-same-currency = (v-base-code = 0)
      .

      /* ищем название р_у_блевой валюты */
      find first buf_currency no-lock
        where buf_currency.curr-code = 0
        .
      assign
        val-price-rubl :screen-value = buf_currency.curr-abbr
        val-rubl-code  :screen-value = string(buf_currency.curr-code
                                             ,val-rubl-code :format
                                             )
      .

      /* артикул, производитель */
      assign
        FI-goods-artic          :screen-value  = string(buf_parts.artic)
        FI-goods-prod-type-code :screen-value  = string(buf_parts.prod-type) + " "
                                               + string(buf_parts.prod-code)
      .

      if available buf_goods
      then do:
        assign
          fi-gds-name         :screen-value = buf_goods.gds-name
          fi-unit             :screen-value = string(buf_goods.unit-base
                                                        ,fi-unit:format)
          fi-unit-2           :screen-value = string(buf_goods.unit-base
                                                        ,fi-unit-2:format)
        .
      end.

      if available buf_clients
      then do:
        assign
          fi-clients-name :screen-value = buf_clients.obj-name
        .
      end.

      assign
        FI-b-code :screen-value = string(v-b-code, FI-b-code :format)
      .
    end.
    else do:
      /* not available buf_parts */
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        .
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        no-error .
      if available buf_doc-line
      then do:
        /* создается новая партия, доступен только doc-line */
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_doc-line.doc-code
          .

        if available buf_trn-doc
        then do:
          assign
            v-frame-title = "Документ №  " + buf_trn-doc.doc-code
          .
        end.

        /* производитель */
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_doc-line.prod-type
            and buf_clients.obj-code = buf_doc-line.prod-code
          no-error .

        assign
          v-display-cli-info = true
        .

        assign
          fi-unit-cli          :visible = v-display-cli-info
          val-price-cli        :visible = v-display-cli-info
          x_parts.cli-base-rate  :visible = v-display-cli-info
          x_parts.exch-code      :visible = v-display-cli-info
          r-exch-code          :visible = v-display-cli-info
          x_parts.price-cli      :visible = v-display-cli-info
          x_parts.cli-qnty       :visible = v-display-cli-info
          tot-price-cli        :visible = v-display-cli-info
          FI-label-koefficient :visible = v-display-cli-info
        .

        if v-display-cli-info
        then do:
          assign
            x_parts.price-cli     :screen-value = string(buf_doc-line.price-cli
                                                          ,x_parts.price-cli:format)
            x_parts.cli-base-rate :screen-value = string(buf_doc-line.cli-base-rate
                                                          ,x_parts.cli-base-rate:format)
/*            x_parts.cli-qnty      :screen-value = string(buf_doc-line.cli-qnty*/
/*                                                          ,x_parts.cli-qnty:format)*/
            fi-unit-cli         :screen-value = string(buf_doc-line.unit-cli
                                                          ,fi-unit-cli:format)
          .

          if v-is-fin = true
          then do:
            find first buf_contract no-lock
              where buf_contract.host-code     = buf_trn-doc.host-code
                and buf_contract.contract-code = buf_trn-doc.contract-code
              no-error .
            if available buf_contract
            then do:
              display
                buf_contract.contract-prn-code @ fi-contract-prn-code
                substitute("&1 Вн.н. &2"
                          ,string(buf_contract.contract-date,'99/99/9999':u)
                          ,buf_contract.contract-code) @ fi-contract-name
                with frame {&frame-name} .
            end.
          end.

          if available buf_trn-doc
          then do:
            find buf_currency no-lock
              where buf_currency.curr-code = buf_trn-doc.exch-code
              no-error .
            if available buf_currency
            then do:
              assign
                v-exch-code = buf_trn-doc.exch-code
              .
              run update-exch-code-dependent in this-procedure .
            end.
          end.
        end.

        /* Сгенерируем код партии для алкогольной продукции */
        if v-alcohol-prod = true then do:
          run alc-lib_get-new-part-code in this-procedure
            (input  buf_trn-doc.obj-type
            ,input  buf_trn-doc.obj-code
            ,input  buf_doc-line.prod-type
            ,input  buf_doc-line.prod-code
            ,input  buf_doc-line.artic
            ,input  p-doc-code
            ,output v-new-parts-part-code
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры alc-lib_get-new-part-code" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
        end.

        assign
          x_parts.price-base    :screen-value = string(buf_doc-line.price-base
                                                        ,x_parts.price-base:format)
          x_parts.price-rubl    :screen-value = string(buf_doc-line.price-rubl
                                                        ,x_parts.price-rubl:format)
/*          x_parts.qnty          :screen-value = string(buf_doc-line.qnty*/
/*                                                        ,x_parts.qnty:format)*/
/*          x_parts.fact-qnty     :screen-value = string(buf_doc-line.fact-qnty*/
/*                                                        ,x_parts.fact-qnty:format)*/
/*          x_parts.part-code     :screen-value = string(buf_parts.part-code*/
/*                                                        ,x_parts.part-code:format)*/
          x_parts.cst-code      :screen-value = string(buf_trn-doc.cst-code
                                                        ,x_parts.cst-code:format)
          x_parts.last-date     :screen-value = string(?  /* для партий по умолчанию "Годен до" не задан */
                                                        ,x_parts.cst-code:format)
          x_parts.supp-type     :screen-value = string( { trg/partsprm.i "supp-type" "buf_trn-doc." }
                                                        , x_parts.supp-type :format )
          x_parts.supp-code     :screen-value = string( { trg/partsprm.i "supp-code" "buf_trn-doc." }
                                                        , x_parts.supp-code :format )
          fi-out-code         :screen-value = "резерв"
        .

        define variable v-vat-type  as character no-undo .
        define variable v-vat-pc    as decimal   no-undo .
        define variable v-slt-type  as character no-undo .
        define variable v-slt-pc    as decimal   no-undo .

        run partscr_get-default-values in this-procedure
          (buffer buf_doc-line
          ,output v-vat-type
          ,output v-vat-pc
          ,output v-slt-type
          ,output v-slt-pc
          ) .

        assign
          fi-vat-type :screen-value = string(v-vat-type
                                            ,fi-vat-type :format )
          fi-vat-pc   :screen-value = string(v-vat-pc
                                            ,fi-vat-pc :format)
          fi-slt-type :screen-value = string(v-slt-type
                                            ,fi-slt-type :format)
          fi-slt-pc   :screen-value = string(v-slt-pc
                                            ,fi-slt-pc :format)
        .

        run update-last-date-offset in this-procedure .

        find first buf_supp-clients no-lock
          where buf_supp-clients.obj-type = string (x_parts.supp-type :screen-value)
            and buf_supp-clients.obj-code = integer(x_parts.supp-code :screen-value)
          no-error .
        if available buf_supp-clients
        then do:
          assign
            fi-supp :screen-value = buf_supp-clients.obj-name
          .
        end.

        if v-goods-serial = true
        then do:
          if buf_trn-doc.flag_ = no
          then do:
            if buf_doc-line.cli-base-rate <> 1
            then do:
              message
                "Коэффициент пересчета для серийных товаров должен быть 1"
                view-as alert-box error .
              undo, return error .
            end.
            assign
              x_parts.cli-qnty  :screen-value = '1'
              x_parts.qnty      :screen-value = '1'
              x_parts.fact-qnty :screen-value = '1'
            .
          end.
        end.

        { gbl/hostcode.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          v-host-code
        }

        { gbl/basecode.i
          v-host-code
          v-base-code
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении кода базовой валюты для фирмы" v-host-code skip
            view-as alert-box error .
        end.

        find first buf_currency no-lock
          where buf_currency.curr-code = v-base-code
          no-error .
        if available buf_currency
        then do:
          assign
            val-price-base :screen-value = buf_currency.curr-abbr
            val-base-code  :screen-value = string(buf_currency.curr-code
                                                ,val-base-code :format
                                                )
          .
        end.

        /* считываем название р_у_блевой валюты */
        find first buf_currency no-lock
          where buf_currency.curr-code = 0
          .
        assign
          val-price-rubl :screen-value = buf_currency.curr-abbr
          val-rubl-code  :screen-value = string(buf_currency.curr-code
                                              ,val-rubl-code :format
                                              )
        .

        assign
          v-same-currency = (v-base-code = 0)
        .

        /* артикул, производитель */
        assign
          FI-goods-artic          :screen-value  = string(buf_doc-line.artic)
          FI-goods-prod-type-code :screen-value  = string(buf_doc-line.prod-type)
                                                 + " "
                                                 + string(buf_doc-line.prod-code)
        .

        if available buf_goods
        then do:
          assign
            fi-gds-name         :screen-value = buf_goods.gds-name
            fi-unit             :screen-value = string(buf_goods.unit-base
                                                          ,fi-unit:format)
            fi-unit-2           :screen-value = string(buf_goods.unit-base
                                                          ,fi-unit-2:format)
          .
        end.

        if available buf_clients
        then do:
          assign
            fi-clients-name :screen-value = buf_clients.obj-name
          .
        end.
      end.
    end.

    run display-dependent-info in this-procedure .

    assign
      session:immediate-display = v-old-immediate-display
    .

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-price Dialog-Frame
PROCEDURE display-price :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter v-new-price-cli  like x_parts.price-cli  no-undo .
  define input parameter v-new-price-base like x_parts.price-rubl no-undo .
  define input parameter v-new-price-rubl like x_parts.price-rubl no-undo .

  do with frame {&frame-name}:
    if x_parts.price-cli :visible
    then do:
      if string(decimal(x_parts.price-cli :screen-value)
               ,x_parts.price-cli :format )
      <> string(v-new-price-cli
               ,x_parts.price-cli :format )
      then do:
        assign
          x_parts.price-cli :screen-value = string(v-new-price-cli
                                                ,x_parts.price-cli :format )
        .
      end.
    end.

    if x_parts.price-base :visible
    then do:
      if string(decimal(x_parts.price-base :screen-value)
               ,x_parts.price-base :format )
      <> string(v-new-price-base
               ,x_parts.price-base :format )
      then do:
        assign
          x_parts.price-base :screen-value = string(v-new-price-base
                                                ,x_parts.price-base :format )
        .
      end.
    end.

    if x_parts.price-rubl :visible
    then do:
      if string(decimal(x_parts.price-rubl :screen-value)
               ,x_parts.price-rubl :format )
      <> string(v-new-price-rubl
               ,x_parts.price-rubl :format )
      then do:
        assign
          x_parts.price-rubl :screen-value = string(v-new-price-rubl
                                                ,x_parts.price-rubl :format )
        .
      end.
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-fields Dialog-Frame
PROCEDURE enable-fields :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_parts    for x_parts .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_goods    for ub.goods .

  do with frame {&frame-name}:
      assign
        v-fields-enabled = true
      .

      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        .
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        .
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        .

      find first buf_parts no-lock
        where recid(buf_parts) = v-parts-recid
        no-error .

      assign
        x_parts.PS :read-only = false
      .

      define variable l-external-income as logical no-undo .
      assign
        l-external-income = true
      .

      if  l-external-income = true
      and v-goods-petroleum = true
      then do:
        message
          "Во внешнем приходе топливо нельзя редактировать через партии" skip
          view-as alert-box information .
        undo, return error . /* --->>>--- */
      end.

      assign
        v-can-change-part-code = false
      .

      /* определяем поле ввода количества, разрешенное для ввода */
      run determine-enable-qnty in this-procedure
        (output v-enable-qnty            /* p-enable-qnty          */
        ).

      /* определяем, можно ли менять поставщика */
      /* поставщика можно менять для любой порожденной партии */
      /* возвратной накладной и для инвентаризации */
      assign
        v-can-change-supp = false
      .

      define variable v-can-change-price as logical no-undo .
      assign
        v-can-change-price = true
      .
        define variable confvalue     as character initial ? no-undo.
        define variable conftype      as character initial ? no-undo.
        { gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
        for each thbjattr_thbj-attr :
            if thbjattr_thbj-attr.prop-code = 'part-prc' then v-can-change-price = thbjattr_thbj-attr.property-value-logical  .
        end.

      v-can-change-part-code = true .
      assign
        x_parts.part-code     :sensitive = /*(v-alcohol-prod = false )*/ false
      .
      if v-alcohol-prod = true
      then do:
        assign
          b-alc-attr :visible   = true
          b-alc-attr :sensitive = true
        .
      end.

      assign
        x_parts.cst-code    :sensitive = v-can-change-part-code
        x_parts.last-date   :sensitive = v-can-change-part-code
        b-choose-last-date  :sensitive = v-can-change-part-code
        fi-last-date-offset :sensitive = v-can-change-part-code

        /* цену поставщика можно задавать всегда */
        /* учетную цену в документе внешнего прихода задавать нельзя */
        x_parts.price-cli  :sensitive = (v-can-change-part-code
                                      and x_parts.price-cli :visible
                                      and v-can-change-price
                                      and l-external-income )
        x_parts.price-base :sensitive = (v-can-change-part-code
                                      and v-can-change-price )
        x_parts.price-rubl :sensitive = (v-can-change-part-code
                                      and v-can-change-price
                                       )

        b-edit-price     :sensitive = /* (v-can-change-part-code
                                      and v-can-change-price
                                      and not v-same-currency )
                                      */
                                      false
        x_parts.qnty       :sensitive = ( (v-enable-qnty = "qnty":u)     and not (v-goods-serial and v-create-part)
                                      )
                                      or ( (v-goods-twounit = true)
                                          and (v-enable-qnty = "cli-qnty":u )
                                        )
        x_parts.fact-qnty  :sensitive = (v-enable-qnty = "fact-qnty":u)
        x_parts.cli-qnty   :sensitive = (v-enable-qnty = "cli-qnty":u) and not (v-goods-serial and v-create-part)
        fi-slt-pc        :sensitive = (v-can-change-part-code
                                      and v-can-change-price
                                      )
        fi-vat-pc        :sensitive = (v-can-change-part-code
                                      and v-can-change-price
                                      )
      .

      if fi-slt-pc :sensitive = true
      then do:
        assign
          fi-slt-pc :fgcolor = ?
        .
      end.
      else do:
        assign
          fi-slt-pc :fgcolor = 4
        .
      end.

      if fi-vat-pc :sensitive = true
      then do:
        assign
          fi-vat-pc :fgcolor = ?
        .
      end.
      else do:
        assign
          fi-vat-pc :fgcolor = 4
        .
      end.

      if v-create-part
      then do:

        define variable v-new-qnty as decimal no-undo .

        run guess-parts-qnty in this-procedure
          (buffer buf_doc-line
          ,output v-new-qnty
          ).
        if x_parts.qnty :sensitive
        then do:
          assign
            x_parts.qnty  :screen-value = string(v-new-qnty
                                              ,x_parts.qnty :format )
          .
        end.
        if x_parts.fact-qnty :sensitive
        then do:
          assign
            x_parts.fact-qnty :screen-value = string(v-new-qnty
                                                  ,x_parts.fact-qnty :format )
          .
        end.
        if x_parts.cli-qnty :sensitive
        then do:
          assign
            x_parts.cli-qnty  :screen-value = string(v-new-qnty
                                                  ,x_parts.cli-qnty :format )
          .
        end.

        run display-dependent-info in this-procedure .
      end.

      if v-can-change-supp
      then do:
        assign
          x_parts.supp-type :sensitive = true
          x_parts.supp-code :sensitive = true
          r-supp :sensitive          = true
        .
        if v-create-part
        then do:
          if x_parts.supp-type :sensitive
          then do:
            assign
              x_parts.supp-type :screen-value = {&cmp}
            .
          end.
          if x_parts.supp-code :sensitive
          then do:
            assign
              x_parts.supp-code :screen-value = ?
            .
          end.
        end.
      end.

      define variable v-is-hold as logical   no-undo .
      { gbl/hold-doc.i
        buf_trn-doc.doc-code
        v-is-hold
      }

      if v-can-change-supp = true
      then do:
        if available buf_parts
        then do:
          define variable v-create-old-return as logical no-undo .
          define variable v-reason as character no-undo .

          run partscr_check-valid-supp in this-procedure
            (input  buf_parts.supp-type
            ,input  buf_parts.supp-code
            ,input  { trg/partsprm.i "supp-type" "buf_trn-doc." }
            ,input  { trg/partsprm.i "supp-code" "buf_trn-doc." }
            ,input  buf_trn-doc.ext-doc-type
            ,output v-create-old-return
            ,output v-reason
            ).

          if v-create-old-return = true
          then do:
            assign
              v-display-price-cli    = true
              v-enable-price-cli     = true
            .
            if  v-is-fin = true
            then do:
              assign
                v-enable-contract      = true
              .
              if buf_parts.contract-code <> 0
              then do:
                assign
                  v-enable-cli-exch-code = false
                .
              end.
              else do:
                assign
                  v-enable-cli-exch-code = true
                .
              end.
            end.
            else do:
              assign
                v-enable-cli-exch-code = true
                v-enable-contract      = false
              .
            end.
          end.
          else do:
            assign
              v-display-price-cli    = false
              v-enable-price-cli     = false
              v-enable-cli-exch-code = false
              v-enable-contract      = false
            .
          end.
        end.
        else do:
          assign
            v-display-price-cli    = true
            v-enable-price-cli     = true
            v-enable-cli-exch-code = true
            v-enable-contract      = false
          .
        end.

        run update-enable-price-cli in this-procedure .
        run update-exch-code-enable in this-procedure .
        run display-dependent-info in this-procedure .
      end.


      assign
        x_parts.part-code      :modified = false
        x_parts.cst-code       :modified = false
        x_parts.last-date      :modified = false
        fi-last-date-offset  :modified = false
        x_parts.price-base     :modified = false
        x_parts.price-rubl     :modified = false
        fi-vat-pc            :modified = false
        fi-slt-pc            :modified = false
        x_parts.qnty           :modified = false
        x_parts.fact-qnty      :modified = false
        x_parts.cli-qnty       :modified = false
        x_parts.PS             :modified = false
        x_parts.supp-type      :modified = false
        x_parts.supp-code      :modified = false
        fi-contract-prn-code :modified = false
        v-modified-contract-code       = false
        v-modified-exch-code           = false
      .

      if available buf_parts
      and buf_parts.out-code <> buf_trn-doc.doc-code
      then do:
        if x_parts.qnty :sensitive
        then do:
          assign
            x_parts.qnty      :modified = true
          .
        end.
        if x_parts.fact-qnty :sensitive
        then do:
          assign
            x_parts.fact-qnty :modified = true
          .
        end.
      end.

      define variable l-enable-button as logical no-undo .

      assign
        b-exit :label in frame {&frame-name} = "&Ввод"
      .

      assign
        b-save :sensitive = true
        b-quit :sensitive = true
        b-rest :sensitive = true
      .

      if x_parts.cli-qnty :sensitive
      then do:
        apply 'entry':u to x_parts.cli-qnty.
      end.
      else do:
        if x_parts.fact-qnty:sensitive
        then do:
          apply 'entry':u to x_parts.fact-qnty.
        end.
        else do:
          if x_parts.qnty:sensitive
          then do:
            apply 'entry':u to x_parts.qnty.
          end.
        end.
      end.
      if v-alcohol-prod = true
      then do:
        assign
          b-alc-attr :visible   = true
          b-alc-attr :sensitive = true
        .
      end.
  end. /* do with frame */

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY fi-vat-pc fi-slt-pc fi-last-date-offset fi-contract-prn-code
          tot-price-cli tot-price-rubl tot-price-base FI-goods-artic fi-gds-name
          FI-goods-prod-type-code FI-clients-name FI-b-code fi-out-code
          FI-label-kolichestvo FI-label-ed-izm FI-label-koefficient fi-unit-cli
          fi-unit fi-unit-2 fi-vat-type fi-slt-type fi-supp fi-contract-name
          FI-label-cena FI-label-summa FI-label-val val-price-cli val-rubl-code
          val-price-rubl val-base-code val-price-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x_parts THEN
    DISPLAY x_parts.PS x_parts.cli-qnty x_parts.cli-base-rate x_parts.qnty
          x_parts.fact-qnty x_parts.part-code x_parts.cst-code x_parts.supp-type
          x_parts.supp-code x_parts.last-date x_parts.price-cli
          x_parts.exch-code x_parts.price-rubl x_parts.price-base
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-prev b-next b-alc-attr b-help RECT-2 RECT-3 RECT-4
         RECT-1 x_parts.PS fi-vat-pc fi-slt-pc x_parts.supp-type
         x_parts.supp-code r-supp x_parts.last-date b-choose-last-date
         fi-last-date-offset fi-contract-prn-code r-contract b-edit-price
         FI-goods-artic fi-gds-name FI-goods-prod-type-code FI-clients-name
         FI-b-code fi-out-code FI-label-kolichestvo FI-label-ed-izm
         FI-label-koefficient fi-unit-cli fi-unit fi-unit-2 fi-vat-type
         fi-slt-type fi-supp fi-contract-name FI-label-cena FI-label-summa
         FI-label-val val-price-cli val-rubl-code val-price-rubl val-base-code
         val-price-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE guess-parts-qnty Dialog-Frame
PROCEDURE guess-parts-qnty :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define parameter buffer buf_doc-line for ub.doc-line .

  define buffer buf_trn-doc for ub.trn-doc .
  define output parameter p-guess-qnty as decimal no-undo .

  &scop partrqst-prefix v-total-parts-
  {&partrqst-var}

  run partrqst in this-procedure
    (input  buf_doc-line.doc-code        /* p-doc-code               */
    ,input  buf_doc-line.obj-type        /* p-obj-type               */
    ,input  buf_doc-line.obj-code        /* p-obj-code               */
    ,input  buf_doc-line.artic           /* p-artic                  */
    ,input  buf_doc-line.prod-type       /* p-prod-type              */
    ,input  buf_doc-line.prod-code       /* p-prod-code              */
    &scop partrqst-prefix v-total-parts-
    {&partrqst-param}
    ).

  case v-enable-qnty :
    when "qnty":u
    then do:
      define variable v-chg-qnty as decimal   no-undo .
      if valid-handle(h-call-prog)
      then do:
        run get-attr-chg-qnty in h-call-prog
          (output v-chg-qnty).
      end.

      /* для документа инвентаризации следует брать поле fact-qnty */
      define variable v-doc-line-qnty as decimal   no-undo .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
        .

      if buf_trn-doc.doc-type = {&inventory}
      then do:
        assign
          v-doc-line-qnty = buf_doc-line.fact-qnty
        .
      end.
      else do:
        assign
          v-doc-line-qnty = buf_doc-line.doc-qnty
        .
      end.

      assign
        p-guess-qnty = max(0, v-doc-line-qnty + v-chg-qnty  - v-total-parts-qnty)
      .
    end.
    when "fact-qnty":u
    then do:
      assign
        p-guess-qnty = max(0, buf_doc-line.fact-qnty - v-total-parts-fact-qnty)
      .
    end.
    when "cli-qnty":u
    then do:
      assign
        p-guess-qnty = max(0, buf_doc-line.cli-qnty  - v-total-parts-cli-qnty)
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-host-code as integer   no-undo .

  do
  on error   undo , return error
  on end-key undo , return error
  :
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_goods    for ub.goods .

    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/curr-r-b.i
      v-curr-r-b
    }

    define variable v-attr-value as character no-undo .
    define variable v-attr-type  as character no-undo .

    { gbl/conf-rd.i
      "'is-fin'"
      "''"
      "''"
      0
      "''"
      "''"
      "''"
      no
      v-attr-value
      v-attr-type
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка чтения конфигурационного параметра" 'is-fin' skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    else do:
      assign
        v-is-fin = lookup(v-attr-value, "true,yes") > 0
      .
    end.

    { gbl/hostcode.i
      buf_doc-line.obj-type
      buf_doc-line.obj-code
      v-host-code
    }

define variable varcontract       as character no-undo .
define variable varcontract-type  as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date      like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
define variable v-mastc           as logical   no-undo init false .

         define variable varvalue as character no-undo.
         define variable vartype  as character no-undo.

     { str/tdat-val.i
     buf_doc-line.doc-code
     {&trdcattr-trn-is-gds}
     varvalue
     vartype
     no-error
   }
         if varvalue = "yes" then 
         do:
    run adm/shattri.p (
      input "get":U
      ,input buf_doc-line.obj-type
      ,input buf_doc-line.obj-code
      ,input {&attr-contr-in}
      ,input  "contr-in-income"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-contract
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
end.
else do:
    run adm/shattri.p (
      input "get":U
      ,input buf_doc-line.obj-type
      ,input buf_doc-line.obj-code
      ,input {&attr-contr-in}
      ,input  "contr-in-income-NP"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-contract
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .   
end.   
    RUN enable_UI.

    assign
      v-create-part = false
    .

    { gbl/gdscdat.i
      p-gds-code
      "'serial=request':u"
      v-goods-serial
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при получении атрибута товара" skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "serial=request" skip
        view-as alert-box .
      undo, return error .
    end.

    { gbl/gdscdat.i
      p-gds-code
      "'twounit=request':u"
      v-goods-twounit
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-alcohol-value as character no-undo .
    define variable v-alcohol-type  as character no-undo .

    { gbl/conf-rd.i
      "'alcohol':u"
      "0"
      "''"
      0
      "''"
      "''"
      "''"
      no
      v-alcohol-value
      v-alcohol-type
      no-error
    }
    if  not error-status :error
    and lookup(v-alcohol-value, 'true,yes':u) > 0
    then do:
      { gbl/gdscdat.i
        p-gds-code
        "'alcohol-prod=request':u"
        v-alcohol-prod
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          'alcohol-prod=request':u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    else do:
      assign
        v-alcohol-prod = false
      .
    end.

    define variable v-petroleum as logical   no-undo .
    define variable v-pieces    as logical   no-undo .

    { str/is-petrl.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      v-petroleum
      v-pieces
      }

    assign
      v-goods-petroleum = ((v-petroleum = true)
                           and (v-pieces = false)
                          )
    .

    run disable-fields .
    run display-fields .
    run enable-fields  .
    hide b-prev in frame {&frame-name}
         b-next b-save in frame {&frame-name} .
    wait-for go of frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE record-modified Dialog-Frame
PROCEDURE record-modified :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-record-modified as logical no-undo .

  define buffer buf_parts    for x_parts .

  do with frame {&frame-name}
  :
    if x_parts.part-code :sensitive
    then do:
      if x_parts.part-code :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.cst-code :sensitive
    then do:
      if x_parts.cst-code :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.last-date :sensitive
    then do:
      if x_parts.last-date :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if fi-last-date-offset :sensitive
    then do:
      if fi-last-date-offset :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.price-cli :sensitive
    then do:
      if x_parts.price-cli :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.price-base :sensitive
    then do:
      if x_parts.price-base :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.price-rubl :sensitive
    then do:
      if x_parts.price-rubl :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if fi-vat-pc :sensitive
    then do:
      if fi-vat-pc :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if fi-slt-pc :sensitive
    then do:
      if fi-slt-pc :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.qnty :sensitive
    then do:
      if x_parts.qnty :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.fact-qnty :sensitive
    then do:
      if x_parts.fact-qnty :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.cli-qnty :sensitive
    then do:
      if x_parts.cli-qnty :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.PS :read-only = false
    then do:
      if x_parts.PS :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.supp-type :sensitive
    then do:
      if x_parts.supp-type :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if x_parts.supp-code :sensitive
    then do:
      if x_parts.supp-code :modified = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if v-can-change-supp = true
    then do:
      if v-modified-exch-code = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    if  v-can-change-supp = true
    and v-is-fin          = true
    then do:
      if v-modified-contract-code = true
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

    /* Атрибуты алкогольной продукции */
    if v-alcohol-prod = true
    then do:
      find first buf_parts no-lock
        where recid(buf_parts) = v-parts-recid
        no-error .
      if available buf_parts and
        (v-alc-mark-db-num         <> buf_parts.mark-db-num             or
         v-alc-mark-code           <> buf_parts.mark-code               or
         v-alc-bottling-date       <> buf_parts.alc-bottling-date       or
         v-alc-ref-ab-path         <> buf_parts.alc-ref-ab-path         or
         v-alc-quality-certif-path <> buf_parts.alc-quality-certif-path or
         v-alc-certif-path         <> buf_parts.alc-certif-path
        )
      then do:
        assign
          p-record-modified = true
        .
        return . /* --->>>--- */
      end.
    end.

  end. /* do with frame */

  assign
    p-record-modified = false
  .
  return . /* --->>>--- */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame
PROCEDURE reopen-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input parameter v-new-parts-recid as recid no-undo .

  if valid-handle(h-call-prog)
  then do:

    run reopen-query in h-call-prog
      .

    run reposition-parts in h-call-prog
      (input  string(v-new-parts-recid)
      ,output v-new-parts-recid
      ).

    apply 'entry':u to b-exit in frame {&frame-name} .

    if v-new-parts-recid <> ?
    then do:
      define buffer buf_parts for x_parts .
      find first buf_parts no-lock
        where recid(buf_parts) = v-new-parts-recid
        no-error .
      assign
        v-parts-recid = v-new-parts-recid
      .
      if available buf_parts
      then do:
        run disable-fields .
        run display-fields .
        run enable-fields .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-parts Dialog-Frame
PROCEDURE reposition-parts :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter v-direction as character no-undo .

  define variable v-new-parts-recid as recid no-undo .

  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(h-call-prog)
  then do:
    run reposition-parts in h-call-prog
      (input  v-direction
      ,output v-new-parts-recid
      ).

    if v-new-parts-recid <> ?
    then do:
      define buffer buf_parts for x_parts .
      find first buf_parts no-lock
        where recid(buf_parts) = v-new-parts-recid
        no-error .
      assign
        v-parts-recid = v-new-parts-recid
      .
      if available buf_parts
      then do:
        run disable-fields .
        run display-fields .
        run enable-fields .
      end.
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-dependent-price Dialog-Frame
PROCEDURE update-dependent-price :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if v-can-change-supp = true
      then do:
        if v-enable-price-rubl = false
        then do:
          assign
            x_parts.price-rubl :screen-value = x_parts.price-cli :screen-value
          .
        end.

        if v-enable-price-base = false
        then do:
          case v-price-base-source
          :
            when 'price-cli':u
            then do:
              assign
                x_parts.price-base :screen-value = x_parts.price-cli :screen-value
              .
            end.
            when 'price-rubl':u
            then do:
              assign
                x_parts.price-base :screen-value = x_parts.price-rubl :screen-value
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Неизвестное значение v-price-base-source" v-price-base-source skip
                view-as alert-box error .
            end.
          end.
        end.
      end.
    end. /* do with frame */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-enable-price-cli Dialog-Frame
PROCEDURE update-enable-price-cli :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      assign
        fi-contract-prn-code :sensitive = v-enable-contract
        r-contract           :sensitive = v-enable-contract
      .

      if v-display-price-cli = true
      then do:
        assign
          x_parts.cli-base-rate :screen-value = "1"
        .
        assign
          fi-unit-cli          :visible = true
          val-price-cli        :visible = true
          x_parts.cli-base-rate  :visible = true
          x_parts.exch-code      :visible = true
          r-exch-code          :visible = true
          x_parts.price-cli      :visible = true
          x_parts.cli-qnty       :visible = true
          tot-price-cli        :visible = true
          FI-label-koefficient :visible = true
        .
        assign
          fi-unit-cli          :sensitive = false
          val-price-cli        :sensitive = false
          x_parts.cli-base-rate  :sensitive = false
          x_parts.exch-code      :sensitive = v-enable-cli-exch-code
          r-exch-code          :sensitive = v-enable-cli-exch-code
          x_parts.price-cli      :sensitive = v-enable-price-cli
          x_parts.cli-qnty       :sensitive = false
          tot-price-cli        :sensitive = false
          FI-label-koefficient :sensitive = false
        .
        if v-curr-r-b = {&r-b-base}
        then do:
          assign
            x_parts.price-cli :screen-value = x_parts.price-base :screen-value
          .
        end.
        else do:
          assign
            x_parts.price-cli :screen-value = x_parts.price-rubl :screen-value
          .
        end.
        assign
          x_parts.cli-qnty :screen-value = x_parts.fact-qnty :screen-value
        .
      end.
      else do:
        assign
          fi-unit-cli          :sensitive = false
          val-price-cli        :sensitive = false
          x_parts.cli-base-rate  :sensitive = false
          x_parts.exch-code      :sensitive = false
          r-exch-code          :sensitive = false
          x_parts.price-cli      :sensitive = false
          x_parts.cli-qnty       :sensitive = false
          tot-price-cli        :sensitive = false
          FI-label-koefficient :sensitive = false
        .
        assign
          fi-unit-cli          :visible = false
          val-price-cli        :visible = false
          x_parts.cli-base-rate  :visible = false
          x_parts.exch-code      :visible = false
          r-exch-code          :visible = false
          x_parts.price-cli      :visible = false
          x_parts.cli-qnty       :visible = false
          tot-price-cli        :visible = false
          FI-label-koefficient :visible = false
        .
      end.

      if x_parts.exch-code :sensitive
      then do:
        assign
          x_parts.exch-code :fgcolor = ?
        .
      end.
      else do:
        assign
          x_parts.exch-code :fgcolor = 4
        .
      end.
    end. /* do with frame */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-exch-code-dependent Dialog-Frame
PROCEDURE update-exch-code-dependent :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_currency for ub.currency .

  do
  on error undo, return error return-value
  :
    find first buf_currency no-lock
      where buf_currency.curr-code = v-exch-code
      no-error .
    if not available buf_currency then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Неизвестный код валюты" v-exch-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    else do:
      do with frame {&frame-name}
      :
        assign
          x_parts.exch-code :screen-value = string(buf_currency.curr-code
                                                ,x_parts.exch-code :format
                                                )
          val-price-cli   :screen-value = string(buf_currency.curr-abbr
                                                ,val-price-cli  :format
                                                )
        .
      end. /* do with frame */
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-exch-code-enable Dialog-Frame
PROCEDURE update-exch-code-enable :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* обновить состояния полей, которые зависят от кода валюты */

  do
  on error undo, return error return-value
  :
      assign
        v-price-base-source = '':u
        v-enable-price-rubl = true
        v-enable-price-base = true
      .

      if v-enable-price-cli = true
      then do:
        if v-exch-code = 0
        then do:
          assign
            v-enable-price-rubl = false
            /* источником для р_у_блёвой цены является цена поставщика */
          .
        end.
        else do:
          assign
            v-enable-price-rubl = true
          .
        end.

        if v-exch-code = (input frame {&frame-name} val-base-code)
        then do:
          assign
            v-enable-price-base = false
            v-price-base-source = 'price-cli':u
          .
        end.
        else do:
          assign
            v-enable-price-base = true
          .
        end.
      end.

      if (input frame {&frame-name} val-base-code) = 0
      then do:
        assign
          v-enable-price-base = false
          v-price-base-source = 'price-rubl':u
        .
      end.

    if v-enable-price-rubl = true
    then do:
      assign
        x_parts.price-rubl :sensitive = true
      .
    end.
    else do:
      assign
        x_parts.price-rubl :sensitive = false
      .
    end.

    if v-enable-price-base = true
    then do:
      assign
        x_parts.price-base :sensitive = true
      .
    end.
    else do:
      assign
        x_parts.price-base :sensitive = false
      .
    end.

    run update-dependent-price in this-procedure .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-last-date-offset Dialog-Frame
PROCEDURE update-last-date-offset :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do with frame {&frame-name}
  :
    define variable v-last-date-offset as integer   no-undo .

    define variable v-today     as date      no-undo .
    define variable v-time      as integer   no-undo .

    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ) .

    run godendo-date-to-offset in this-procedure
      (input  v-today                                     /* p-today  */
      ,input  (input frame {&frame-name} x_parts.last-date) /* p-date   */
      ,output v-last-date-offset                          /* p-offset */
      ) .
    assign
      fi-last-date-offset :screen-value = string(v-last-date-offset
                                                ,fi-last-date-offset :format
                                                )
    .

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-record Dialog-Frame
PROCEDURE update-record :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define output parameter v-close-window    as logical no-undo .
  define variable v-ok as logical   no-undo .

  define variable v-record-modified as logical no-undo .
  define variable l-edit-reserv     as logical no-undo .

  assign
    v-close-window = false
  .

  run record-modified in this-procedure
    (output v-record-modified
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры record-modified" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  /* message 'v-record-modified' v-record-modified . */
  if  v-record-modified = false
  and v-create-part = false
  then do:
    /* запись не менялась */
    return . /* --->>>-- */
  end.

  define variable v-root-node as integer no-undo .

  define buffer buf_parts    for x_parts .
  define buffer buf_goods    for ub.goods .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_trn-doc  for ub.trn-doc .

  do
  transaction
  on error undo, return error
  :
    if v-can-change-part-code
    then do:
      run validate-part-code in this-procedure
        (input v-new-parts-part-code /* p-new-part-code  */
        ,input v-parts-recid         /* p-parts-recid    */
        ,input p-doc-code            /* p-doc-code       */
        ,input p-gds-code            /* p-gds-code       */
        ,input v-goods-serial        /* p-goods-serial   */
        ) no-error .
      if error-status :error
      then do:
        apply 'entry':u to x_parts.part-code in frame {&frame-name} .
        undo, return error .
      end.
    end.
    if  x_parts.price-base :sensitive
    then do:
      if decimal(x_parts.price-base :screen-value) = ?
      then do:
        message
          substitute("Не задана учётная цена (&1)"
                    ,val-price-base :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to x_parts.price-base .
        undo, return error .
      end.

      if decimal(x_parts.price-base :screen-value) = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Учётная цена (&1) равна нулю"
                    ,val-price-base :screen-value
                    ) skip
          "Партия будет сохранена с нулевой учётной ценой." skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to x_parts.price-base .
          undo, return error .
        end.
      end.
    end.

    if  x_parts.price-rubl :sensitive
    then do:
      if decimal(x_parts.price-rubl :screen-value) = ?
      then do:
        message
          substitute("Не задана учётная цена (&1)"
                    ,val-price-rubl :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to x_parts.price-rubl .
        undo, return error .
      end.

      if decimal(x_parts.price-rubl :screen-value) = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Учётная цена (&1) равна нулю"
                    ,val-price-rubl :screen-value
                    ) skip
          "Партия будет сохранена с нулевой учётной ценой." skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to x_parts.price-rubl .
          undo, return error .
        end.
      end.
    end.

    if  x_parts.price-cli :sensitive
    then do:
      if decimal(x_parts.price-cli :screen-value) = ?
      then do:
        message
          substitute("Не задана цена поставщика (&1)"
                    ,val-price-cli :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to x_parts.price-cli .
        undo, return error .
      end.

      if decimal(x_parts.price-cli :screen-value) = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Цена поставщика (&1) равна нулю"
                    ,val-price-cli :screen-value
                    ) skip
          "Партия будет сохранена с нулевой ценой поставщика." skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to x_parts.price-cli .
          undo, return error .
        end.
      end.
    end.


    find first buf_trn-doc
      where buf_trn-doc.doc-code = p-doc-code
      .
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
      .


      find first buf_parts
        where recid(buf_parts) = v-parts-recid
        .

    assign
      l-edit-reserv = (buf_parts.out-code = buf_trn-doc.doc-code)
    .

    if buf_parts.in-code = buf_parts.out-code
    then do:
      if x_parts.part-code :sensitive
      then do:
        /* определяем корневой узел шкалы */
        { gbl/rootnode.i
          buf_parts.artic
          buf_parts.prod-type
          buf_parts.prod-code
          v-root-node
        }

        if v-goods-twounit = true
        then do:
          if length(buf_parts.part-code) > 10
          or index(buf_parts.part-code, {&part-split} ) > 0
          then do:
            message
              "Код партии ювелирных изделий должен быть меньше или равен 10 символов" skip
              "И не должен содержать знак" {&part-split} skip
              view-as alert-box error .
            apply 'entry':u to x_parts.part-code .
            undo, return error .
          end.
        end.

        assign
          buf_parts.part-code = string(x_parts.part-code :screen-value)
        .
      end.

      if v-can-change-part-code
      then do:
        if x_parts.price-cli :sensitive
        then do:
          assign
            buf_parts.price-cli = decimal(x_parts.price-cli :screen-value)
          .
        end.

        if fi-vat-pc :sensitive
        then do:
          assign
            buf_parts.vat-pc = decimal(fi-vat-pc :screen-value)
          .
        end.
        if fi-slt-pc :sensitive
        then do:
          assign
            buf_parts.slt-pc = decimal(fi-slt-pc :screen-value)
          .
        end.
        assign
          buf_parts.price-base = decimal(x_parts.price-base :screen-value)
        .
        assign
          buf_parts.price-rubl = decimal(x_parts.price-rubl :screen-value)
        .
        if not( buf_trn-doc.doc-type     = {&income}
                and buf_trn-doc.internal = false)
        then do:

          /* для всех документов кроме внешнего прихода*/
          if  buf_parts.cli-base-rate = 1
          and buf_parts.exch-code     = 0
          then do:
            assign
              buf_parts.price-cli = buf_parts.price-rubl
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при создании партии" skip
              "Документ" buf_doc-line.price-base skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              "Для порожденной партии cli-base-rate отличен от 1" skip
              "cli-base-rate" buf_parts.cli-base-rate skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.

      define variable v-create-old-return as logical no-undo .
      define variable v-reason as character no-undo .

      assign
        v-create-old-return = false
      .

      if x_parts.cst-code :sensitive
      then do:
        assign
          buf_parts.cst-code = string(x_parts.cst-code :screen-value)
        .
      end.

      if x_parts.last-date :sensitive
      then do:
        assign
          buf_parts.last-date = date(x_parts.last-date :screen-value)
        .
      end.

      if  v-can-change-supp = true
      and v-is-fin          = true
      then do:
        assign
          buf_parts.contract-code = v-contract-code
        .
      end.

      if v-can-change-supp = true
      then do:
        assign
          buf_parts.exch-code = v-exch-code
        .
        if x_parts.price-cli :sensitive
        then do:
          assign
            buf_parts.price-cli = input frame {&frame-name} x_parts.price-cli
          .
        end.
      end.

      if buf_parts.contract-code = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка заведения партии" skip
          "Номер контракта имеет неопределённое значение" skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if  v-is-fin = false
      and buf_parts.contract-code <> 0
      then do:
        message
          "В системе отсутствует АРМ взаиморасчёты" skip
          "Нельзя задавать контракт для партии" skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if  v-is-fin   = true
      and v-contract = true
      and v-create-old-return = true
      and buf_parts.contract-code = 0
      then do:
        message
          "Необходимо указать контракт для партии старого возврата," skip
          "так как в системе включён АРМ взаиморасчёты" skip
          "и включён параметр обязательного заведения контракта" skip
          view-as alert-box information .
        apply 'entry':u to fi-contract-prn-code .
        undo, return error return-value .
      end.

      if  v-create-part = true
      and buf_parts.contract-code <> 0
      then do:
        /* у партии задан контракт */
        /* копируем часть параметров из контракта */

        define variable v-host-code as integer   no-undo .
        { gbl/hostcode.i
          buf_parts.obj-type
          buf_parts.obj-code
          v-host-code
        }

        define buffer buf_contract for ub.contract .
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = buf_parts.contract-code
          no-error .
        if not available buf_contract
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании контракта партии" skip
            "Код фирмы" v-host-code skip
            "Код контракта" buf_parts.contract-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        define variable v-contract-purch-code as integer   no-undo .

        { gbl/cntpurch.i
          buf_contract.contract-type
          v-contract-purch-code
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении типа поставки для контракта" skip
            "Код фирмы" v-host-code skip
            "Код контракта" buf_contract.contract-code skip
            "Тип контракта" buf_contract.contract-type skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        assign
          buf_parts.exch-code  = buf_contract.curr-code
          buf_parts.purch-code = v-contract-purch-code
        .
      end.
    end.

    if x_parts.PS :read-only = false
    then do:
      assign
        buf_parts.PS = x_parts.PS :screen-value
      .
    end.

    /* Атрибуты алкогольной продукции */
    if v-alcohol-prod = true
    then do:
      assign
        buf_parts.mark-db-num             = v-alc-mark-db-num
        buf_parts.mark-code               = v-alc-mark-code
        buf_parts.alc-bottling-date       = v-alc-bottling-date
        buf_parts.alc-ref-ab-path         = v-alc-ref-ab-path
        buf_parts.alc-quality-certif-path = v-alc-quality-certif-path
        buf_parts.alc-certif-path         = v-alc-certif-path
        buf_parts.alc-imp-type = v-alc-imp-type
        buf_parts.alc-imp-code = v-alc-imp-code
      .
    end.

    define variable v-chg-cli-qnty  like x_parts.cli-qnty  no-undo .
    define variable v-chg-qnty      like x_parts.qnty      no-undo .
    define variable v-chg-fact-qnty like x_parts.fact-qnty no-undo .


    assign
      v-chg-cli-qnty  = 0
      v-chg-qnty      = 0
      v-chg-fact-qnty = 0
    .

    /* определяем количество,
      на которое необходимо изменить зарезервированную партию
     */
    case v-enable-qnty :
      when "cli-qnty":u
      then do:
        assign
          v-chg-cli-qnty = input frame {&frame-name} x_parts.cli-qnty - buf_parts.cli-qnty
        .
        if v-goods-twounit = true
        then do:
          assign
            v-chg-qnty = input frame {&frame-name} x_parts.qnty - buf_parts.qnty
          .
        end.
      end.
      when "qnty":u
      then do:
        /* определяем количество,
          на которое необходимо изменить зарезервированную партию
          в случае редактирования количества по партии
        */
        case buf_parts.out-code :
          when {&free-code}
          then do:
            assign
              v-chg-qnty = - input frame {&frame-name} x_parts.qnty
            .
          end.
          when {&output-code}
          then do:
            assign
              v-chg-qnty = input frame {&frame-name} x_parts.qnty
            .
          end.
          when buf_trn-doc.doc-code
          then do:
            if lookup(buf_trn-doc.doc-type, {&expense_write-off}) > 0
            then do:
              assign
                v-chg-qnty = (buf_parts.qnty - input frame {&frame-name} x_parts.qnty)
              .
            end.
            else do:
              assign
                v-chg-qnty = - (buf_parts.qnty - input frame {&frame-name} x_parts.qnty)
              .
            end.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Попытка изменить партию, не принадлежащую документу" skip
              "Партия зарезервирована за документом" buf_parts.out-code skip
              "Текущий документ" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error .
          end.
        end case .
        /* Проверка допустимости резервирования партий */
        define variable l-process-part      as logical   no-undo .

        /* значение по умолчанию - список типов приобретения для резервирования */
        define variable v-purch-code-list      as character no-undo .
        define variable v-purch-code-list-type as character no-undo .

        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-purchcodelist}
            v-purch-code-list
            v-purch-code-list-type
        }
        if v-purch-code-list = {&purchase-codes}
        then do:
          /* если заданы все типы приобретения - то резервируем без ограничений */
          assign
            v-purch-code-list = "":u
          .
        end.

        /* анализ допустимости резервирования партии */
        { gbl/part-prc.i
          buf_parts
          buf_trn-doc
          "false"
          "'':u"
          "'':u"
          p-pl-code
          v-goods-twounit
          v-purch-code-list
          v-chg-qnty
          "true"
          v-reason
          l-process-part
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении возможности резервирования партии" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.

        /* не позволяем накладывать дополнительные резервы, */
        /* но позволяем снимать ранее наложенные резервы */
        if  l-process-part <> true
        and input frame {&frame-name} x_parts.qnty <> 0
        then do:
          message
            v-reason
            view-as alert-box information .
          undo, return error .
        end.
      end.
      when "fact-qnty":u
      then do:
        case buf_parts.out-code :
          when buf_trn-doc.doc-code
          then do:
            assign
              v-chg-fact-qnty = input frame {&frame-name} x_parts.fact-qnty - buf_parts.fact-qnty
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Попытка редактирования фактических количеств, не принадлежащую документу" skip
              "Партия зарезервирована за документом" buf_parts.out-code skip
              "Текущий документ" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error .
          end.
        end case .
      end.
      otherwise do:
/*        assign*/
/*          v-chg-qnty = 0*/
/*        .*/
/*        message*/
/*          vss-workfile vss-revision vss-description skip*/
/*          "Неизвестное значение" "v-enable-qnty":u skip*/
/*          v-enable-qnty skip*/
/*          view-as alert-box error .*/
/*        undo, return error .*/
      end.
    end case .

    if v-chg-cli-qnty  <> 0
    or v-chg-qnty      <> 0
    or v-chg-fact-qnty <> 0
    then do:
      /* производим резервирование на основании запрошенных количеств */
      case v-enable-qnty :
        when "cli-qnty":u
        then do:
          if v-goods-twounit = false
          then do:
            assign
              buf_parts.cli-qnty  = buf_parts.cli-qnty + v-chg-cli-qnty
              buf_parts.qnty      = buf_parts.cli-qnty * buf_parts.cli-base-rate
              buf_parts.fact-qnty = buf_parts.qnty
            .
          end.
          else do:
            assign
              buf_parts.cli-qnty  = buf_parts.cli-qnty + v-chg-cli-qnty
              buf_parts.qnty      = buf_parts.qnty     + v-chg-qnty
              buf_parts.fact-qnty = buf_parts.qnty
              buf_parts.cli-base-rate = buf_parts.qnty / buf_parts.cli-qnty
            .

            define variable v-road-tax as decimal   no-undo .

            if v-curr-r-b = {&r-b-base}
            then do:
              assign
                v-road-tax = buf_parts.road-tax-base
              .
            end.
            else do:
              assign
                v-road-tax = buf_parts.road-tax-rubl
              .
            end.

            { str/in-vat.i
              buf_trn-doc.doc-code
              buf_trn-doc.base-rate
              buf_trn-doc.base-scale
              buf_trn-doc.exch-rate
              buf_trn-doc.exch-scale
              buf_trn-doc.vat-type
              buf_trn-doc.slt-type
              buf_parts.artic
              buf_parts.prod-type
              buf_parts.prod-code
              buf_parts.price-cli
              buf_parts.cli-base-rate
              buf_parts.price-rubl
              buf_parts.vat-pc
              buf_parts.slt-pc
              v-road-tax
              buf_parts.transport-rubl
              buf_parts.other-rubl
              v-price-cli
              v-price-cli-unit-base
              v-price-road-tax
              v-price-other-exp
              v-price-transport-exp
              v-price-without-abs
              v-price-slt
              v-price-no-slt
              v-price-vat
              v-price-no-vat-slt
              v-price-rubl
              v-price-road-tax-rubl
              v-price-other-exp-rubl
              v-price-transport-exp-rubl
              v-price-without-abs-rubl
              v-price-slt-rubl
              v-price-no-slt-rubl
              v-price-vat-rubl
              v-price-no-vat-slt-rubl
              v-price-base
              v-price-road-tax-base
              v-price-other-exp-base
              v-price-transport-exp-base
              v-price-without-abs-base
              v-price-slt-base
              v-price-no-slt-base
              v-price-vat-base
              v-price-no-vat-slt-base
              no-error
              }
            if error-status :error
            then do:
              return error "Ошибка при пересчете линии документа".
            end.
            assign
              buf_parts.price-cli  = v-price-cli
              buf_parts.price-base = v-price-base
              buf_parts.price-rubl = v-price-rubl
            .
          end.

          if buf_parts.qnty < 0
          then do:
            message
              "Количество по документу не может быть отрицательным"
              view-as alert-box .
            undo, return error .
          end.
        end.

        when "fact-qnty":u
        then do:
          assign
            buf_parts.fact-qnty = buf_parts.fact-qnty + v-chg-fact-qnty
          .
          if buf_parts.fact-qnty < 0
          then do:
            message
              "Фактическое количество не может быть отрицательным"
              view-as alert-box.
            apply 'entry':u to x_parts.fact-qnty.
            undo, return error .
          end.

          if buf_parts.fact-qnty > buf_parts.qnty
          then do:
            message
              "Фактическое количество не может превышать количества по документу"
              view-as alert-box.
            apply 'entry':u to x_parts.fact-qnty.
            undo, return error .
          end.

          if v-goods-serial = true
          and buf_parts.fact-qnty <> buf_parts.qnty
          and buf_parts.fact-qnty <> 0
          then do:
            message
              "Для серийных товаров фактическое количество" skip
              "должно равняться 1 или 0" skip
              view-as alert-box .
            apply 'entry':u to x_parts.fact-qnty.
            undo, return error .
          end.

          if v-goods-twounit = true
          then do:
            if buf_parts.fact-qnty <> buf_parts.qnty
            and buf_parts.fact-qnty <> 0
            then do:
              message
                "Для ювелирных изделий фактическое количество" skip
                "должно равняться" buf_parts.qnty "или 0" skip
                view-as alert-box .
              apply 'entry':u to x_parts.fact-qnty.
              undo, return error .
            end.
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
        end.

        when "qnty":u
        then do:
          define variable v-real-chg-qnty like x_parts.qnty no-undo .
          run partrsrv in this-procedure
            (input  v-chg-qnty      /* p-chg-qnty      */
            ,input  v-goods-serial  /* p-goods-serial  */
            ,input  v-goods-twounit /* p-goods-twounit */
            ,input  false           /* p-unreserv-only */
            ,buffer buf_parts       /* buf_orig_parts  */
            ,buffer buf_trn-doc     /* buf_trn-doc     */
            ,output v-real-chg-qnty /* p-real-chg-qnty */
            ,output v-parts-recid   /* p-parts-recid   */
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при резервировании партии" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          if v-parts-recid = ?
          then do:
            assign
              v-close-window = true
            .
          end.
          if v-chg-qnty <> v-real-chg-qnty
          then do:
            message
              "Запрошенное количество недоступно." skip
              "Была произведена автоматическая коррекция запрошенного количества." skip
              "Запрошено" v-chg-qnty skip
              "Зарезервировано" v-real-chg-qnty skip
              view-as alert-box .
          end.
        end.
      end case .
    end.


      /* удаление партии в документе внешнего прихода */
      if (buf_trn-doc.flag_ = no  and buf_parts.qnty <= 0)
      or (buf_trn-doc.flag_ = yes and buf_parts.qnty <= 0 and buf_parts.fact-qnty <= 0)
      then do:
        delete buf_parts .
        message
          "Количество в партиии нулевое !" skip
          "Партия удаляется" skip
          view-as alert-box.
        return .
      end.

    if available buf_parts
    then do:
      if v-goods-twounit = true
      then do:
        /* проверяем допустимое количество для партии товара */
        { gbl/unitqnty.i
          buf_goods.unit-cli
          buf_parts.artic
          buf_parts.prod-type
          buf_parts.prod-code
          "'Ед.изм. поставщика'"
          buf_parts.cli-qnty
          no-error
        }
        if error-status :error
        then do:
          message
            "Не прошел контроль количества товара" skip
            "Попробуйте ввести другое количество" skip
            view-as alert-box information .
          undo, return error .
        end.
      end.

      /* проверяем допустимое количество для партии товара */
      { gbl/unitqnty.i
        buf_goods.unit-base
        buf_parts.artic
        buf_parts.prod-type
        buf_parts.prod-code
        "''"
        buf_parts.fact-qnty
        no-error
      }
      if error-status :error
      then do:
        message
          "Не прошел контроль количества товара" skip
          "Попробуйте ввести другое количество" skip
          view-as alert-box information .
        undo, return error .
      end.
    end.
  end.

  assign
    v-create-part = false
  .

  if valid-handle(h-call-prog)
  then do:
    run data-changed in h-call-prog .
  end.

.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-contract Dialog-Frame
PROCEDURE validate-contract :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-host-code as integer   no-undo .

  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_contract for ub.contract .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      .

    { gbl/hostcode.i
      buf_trn-doc.obj-type
      buf_trn-doc.obj-code
      v-host-code
    }
    if input frame {&frame-name} fi-contract-prn-code <> fi-contract-prn-code
    then do:
      run validate-supp in this-procedure
        (input (input frame {&frame-name} x_parts.supp-type)
        ,input (input frame {&frame-name} x_parts.supp-code)
        ) no-error .
      if error-status :error
      then do:
        message
          "Неправильно задан поставщик" skip
          "" (input frame {&frame-name} x_parts.supp-type)
            (input frame {&frame-name} x_parts.supp-code) skip
          view-as alert-box error .
        undo, return no-apply .
      end.

      run check-contract-code in this-procedure
        (input  "input":u
        ,input  v-host-code
        ,input  (input frame {&frame-name} x_parts.supp-type)
        ,input  (input frame {&frame-name} x_parts.supp-code)
        ,input  input frame {&frame-name} fi-contract-prn-code
        ,input  parparentproc
        ,input  buf_trn-doc.doc-date
        ,input  ""
        ,output v-contract-code
        ) no-error .
      if error-status :error
      or v-contract-code = ?
      then do:
        if return-value <> ""
        or error-status :get-message(1) <> ""
        then do:
          message
            "Ошибка при заведении номера договора." skip
            return-value skip
            error-status :get-message(1)
          view-as alert-box error .
        end.
        return error .
      end.

      assign
        v-modified-contract-code = true
      .

      if v-contract-code <> 0
      then do:
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = v-contract-code
          .
        display
          buf_contract.contract-prn-code @ fi-contract-prn-code
          substitute("&1 Вн.н. &2"
                    ,string(buf_contract.contract-date,'99/99/9999':u)
                    ,v-contract-code) @ fi-contract-name
          with frame {&frame-name} .

        assign
          v-enable-cli-exch-code = false
          v-modified-exch-code   = true
          v-exch-code            = buf_contract.curr-code
        .
        run update-exch-code-dependent in this-procedure .
        run update-enable-price-cli    in this-procedure .
        run update-exch-code-enable    in this-procedure .
      end.
      else do:
        display
          "" @ fi-contract-prn-code
          "" @ fi-contract-name
          with frame {&frame-name} .

        assign
          v-enable-cli-exch-code = true
          v-modified-exch-code   = true
          v-exch-code            = 0
        .
        run update-exch-code-dependent in this-procedure .
        run update-enable-price-cli    in this-procedure .
        run update-exch-code-enable    in this-procedure .
      end.

      assign
        fi-contract-prn-code
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-exch-code Dialog-Frame
PROCEDURE validate-exch-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_currency for ub.currency .

  do
  on error undo, return error return-value
  :
    if input frame {&frame-name} x_parts.exch-code <> v-exch-code
    then do:
      find first buf_currency no-lock
        where buf_currency.curr-code = input frame {&frame-name} x_parts.exch-code
        no-error .
      if not available buf_currency
      then do:
        message
          "Неизвестный код валюты" skip
          "Код валюты" input frame {&frame-name} x_parts.exch-code skip
          view-as alert-box error .
        apply 'entry':u to x_parts.exch-code in frame {&frame-name} .
        undo, return error return-value .
      end.
      else do:
        assign
          v-modified-exch-code          = true
          v-exch-code                   = buf_currency.curr-code
        .
        run update-exch-code-dependent in this-procedure .
        run update-exch-code-enable    in this-procedure .
      end.

    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-part-code Dialog-Frame
PROCEDURE validate-part-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-new-part-code  as character no-undo .
  define input parameter p-parts-recid    as recid     no-undo .
  define input parameter p-doc-code       as character no-undo .
  define input parameter p-gds-code       as integer   no-undo .
  define input parameter p-goods-serial   as logical   no-undo .

  define buffer buf_goods    for ub.goods .
  define buffer buf_doc-line for ub.doc-line .
  define buffer lookup_parts for x_parts .

  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .

  find first buf_doc-line no-lock
    where buf_doc-line.doc-code  = p-doc-code
      and buf_doc-line.artic     = buf_goods.artic
      and buf_doc-line.prod-type = buf_goods.prod-type
      and buf_doc-line.prod-code = buf_goods.prod-code
    .

  find first lookup_parts no-lock
    where lookup_parts.obj-type  = buf_doc-line.obj-type
      and lookup_parts.obj-code  = buf_doc-line.obj-code
      and lookup_parts.artic     = buf_doc-line.artic
      and lookup_parts.prod-type = buf_doc-line.prod-type
      and lookup_parts.prod-code = buf_doc-line.prod-code
      and lookup_parts.in-code   = buf_doc-line.doc-code
      and lookup_parts.out-code  = buf_doc-line.doc-code
      and lookup_parts.part-code = p-new-part-code
      and recid (lookup_parts) <> p-parts-recid
    no-error .
  if available lookup_parts
  then do:

    define variable v-show-part-code as character no-undo .

    if p-new-part-code = '':u
    then do:
      assign
        v-show-part-code = '------':u
      .
    end.
    else do:
      assign
        v-show-part-code = p-new-part-code
      .
    end.

    message
      "Партия с номером <<" + v-show-part-code + ">> уже есть"
      view-as alert-box error .
    undo, return error .
  end.

  if  p-goods-serial  = true
  and p-new-part-code = ""
  then do:
    message
      "Для серийных товаров - серийный номер обязателен"
      view-as alert-box error .
    undo, return error .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-qnty Dialog-Frame
PROCEDURE validate-qnty :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bufr_parts for ub.parts  .
define buffer free_parts for ub.parts  .
define buffer ras_parts for ub.parts  .
define buffer rez_parts for ub.parts  .
define buffer buf_goods  for ub.goods  .
define variable v-delta as decimal   no-undo .
define variable v-rashod as decimal   no-undo .
define variable v-rezerv as decimal   no-undo .
define variable v-qnty  as decimal   no-undo .
v-qnty = decimal ( x_parts.cli-qnty :screen-value in frame {&frame-name} ) *
         decimal ( x_parts.cli-base-rate :screen-value in frame {&frame-name} ) .

find first buf_goods no-lock
  where buf_goods.gds-code = p-gds-code no-error .

/* Найдем реальную партию . Количество можно только уменьшить */
    find first bufr_parts no-lock where
               bufr_parts.artic = buf_goods.artic and
               bufr_parts.prod-type = buf_goods.prod-type and
               bufr_parts.prod-code = buf_goods.prod-code and
               bufr_parts.in-code   = p-in-code and
               bufr_parts.part-code = p-part-code and
               bufr_parts.out-code  = p-out-code
      no-error .

  if bufr_parts.fact-qnty < v-qnty then do:
     message
     "Изменить Количество можно только в меньшую сторону !!!"
     view-as alert-box information .
     return error .
  end.

  v-delta = bufr_parts.cli-qnty - v-qnty .

  /* Найдем свободную зону партии . Количество можно уменьшить если хватает в свободной зоне */
  /*  find first free_parts no-lock where
               free_parts.artic = buf_goods.artic and
               free_parts.prod-type = buf_goods.prod-type and
               free_parts.prod-code = buf_goods.prod-code and
               free_parts.in-code   = p-in-code and
               free_parts.part-code = p-part-code and
               free_parts.out-code  = {&free-code}  and
               free_parts.rsrv-free = true
      no-error .
  if not available free_parts then do:
     message
     "Свободная зона уже израсходована."
     "Изменение невозможно !!!"
     view-as alert-box information .
     return error .
  end.

  if free_parts.fact-qnty < v-delta then do:
     message
     "Свободная зона уже израсходована. Осталось" free_parts.fact-qnty
     "Можно уменьшить приход не более чем на это количество !!!"
     view-as alert-box information .
     return error .
  end. */

/* Проверим раходную зону + резерв незакрытых расходов   , она должна не больше чем в новом приходе */
    v-rashod =  0 .
    find first ras_parts no-lock where
               ras_parts.artic     = buf_goods.artic and
               ras_parts.prod-type = buf_goods.prod-type and
               ras_parts.prod-code = buf_goods.prod-code and
               ras_parts.in-code   = p-in-code and
               ras_parts.part-code = p-part-code and
               ras_parts.out-code  = {&output-code} and
               ras_parts.rsrv-free = no
      no-error .
  if available ras_parts  then do:
      v-rashod = ras_parts.fact-qnty .
  end.

    v-rezerv = 0 .
    for each rez_parts no-lock where
            rez_parts.artic     = buf_goods.artic and
            rez_parts.prod-type = buf_goods.prod-type and
            rez_parts.prod-code = buf_goods.prod-code and
            rez_parts.in-code   = p-in-code and
            rez_parts.part-code = p-part-code and
            rez_parts.out-code <> p-in-code and
            rez_parts.out-code <> {&free-code} and
            rez_parts.status_    = false  and
            rez_parts.rsrv-free = true :

        v-rezerv = v-rezerv + rez_parts.fact-qnty .
    end.
   v-rashod = v-rashod + v-rezerv .

  if v-rashod > v-qnty then do:
     message
     "Израсходовано больше чем в приходе "  skip
     "Израсходовано и зарезервировано :" v-rashod "(" v-rezerv ")"
     view-as alert-box information .
     return error .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-supp Dialog-Frame
PROCEDURE validate-supp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-supp-type like x_parts.supp-type no-undo .
  define input parameter p-supp-code like x_parts.supp-code no-undo .

  def buffer buf_supp-clients for clients .

  define variable v-create-old-return as logical   no-undo .
  define variable v-reason            as character no-undo .

  do
  on error undo, return error return-value
  :
    if  v-supp-type = p-supp-type
    and v-supp-code = p-supp-code
    then do:
      /* поставщик не поменялся */
      return .
    end.

    find buf_supp-clients  no-lock
      where buf_supp-clients.obj-type = p-supp-type
        and buf_supp-clients.obj-code = p-supp-code
      no-error.
    if not available buf_supp-clients
    then do:
      if p-supp-type = ""
      or p-supp-type = ?
      or p-supp-code = 0
      or p-supp-code = ?
      then do:
        message
          "Не задан тип или код поставщика" skip
          p-supp-type p-supp-code skip
          view-as alert-box information .
      end.
      else do:
        message
          "Неправильный код или тип поставщика" skip
          p-supp-type p-supp-code skip
          view-as alert-box information .
      end.
      apply 'entry':u to x_parts.supp-type in frame {&frame-name}.
      return error.
    end.

    if buf_supp-clients.stts <> 0
    then do:
      message
        "Клиент" buf_supp-clients.obj-name "удален" skip
        "Выберите другого клиента" skip
        view-as alert-box information .
      return error .
    end.

    define buffer buf_trn-doc for ub.trn-doc .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      .

    run partscr_check-valid-supp in this-procedure
      (input  p-supp-type
      ,input  p-supp-code
      ,input  { trg/partsprm.i "supp-type" "buf_trn-doc." }
      ,input  { trg/partsprm.i "supp-code" "buf_trn-doc." }
      ,input  buf_trn-doc.ext-doc-type
      ,output v-create-old-return
      ,output v-reason
      ).
    if v-reason <> ""
    then do:
      message
        v-reason
        view-as alert-box error .
      undo, return error .
    end.

    assign
      v-supp-type = p-supp-type
      v-supp-code = p-supp-code
    .

    run clear-contract-value in this-procedure .

    assign
      fi-supp :screen-value = buf_supp-clients.obj-name
      fi-supp :modified     = false
    .

    if v-create-old-return = true
    then do:
      assign
        v-display-price-cli    = true
        v-enable-price-cli     = true
        v-enable-cli-exch-code = true
      .
      if v-is-fin = true
      then do:
        assign
          v-enable-contract    = true
        .
      end.
      else do:
        assign
          v-enable-contract    = false
        .
      end.
    end.
    else do:
      assign
        v-display-price-cli    = false
        v-enable-price-cli     = false
        v-enable-cli-exch-code = false
        v-enable-contract      = false
      .
    end.
    run update-enable-price-cli in this-procedure .
    run update-exch-code-enable in this-procedure .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME