&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-out-prt


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER b-c-b FOR bar-code.
DEFINE BUFFER buf_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-out-prt 
/*

$Revision: 81f7d91a817a, 3654, rls $
$Author: SSlivenko $
$Date: 2024/01/31 10:15:43 $
$Workfile: out-prt.w $
$Archive: str/out-prt.w $

Задание док. и факт. количества по признаку или артикулу в рас, возврат, при, спи накладных (внешних и внутренних)

Автор: Чернова Светлана Александровна
Дата создания: 12/01/06
Author: Svetlana Chernova
Creation date: 12/01/06

create: Суслов Алексей Юрьевич

РАБОТАЕТ В UIB !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Внимание!!! Работать с doc или fact кол-вами и ценами определяется переменной v-work-with-qnty

----------------------------------------------------------------------- */

&Scoped-define WINDOW-NAME d-out-prt
&Scoped-define FRAME-NAME  d-out-prt
&Scoped-define align       colon-aligned
&Scoped-define text        view-as text       size-chars
&Scoped-define fill-in     view-as fill-in    size-chars
&Scoped-define toggle      view-as toggle-box size-chars
&Scoped-define tail        by 1.00
&Scoped-define color       {&tail} fgcolor 4
&Scoped-define color1      {&tail} bgcolor 3 fgcolor 15

define buffer t-doc   for ub.trn-doc.
define buffer g-d-b   for ub.gds-dtl.
define buffer out-dtl for ub.gds-dtl. /* признак внутренней РН */
define buffer bf_prod-bc for ub.prod-bc.
define buffer in_doc-line for ub.doc-line.
define buffer in_parts for ub.parts.
define buffer out_parts for ub.parts.
define buffer buf_gen-attr for ub.gen-attr .
define buffer buf_gds-obj for ub.gds-obj .

define buffer buf_marking for ub.marking .
define buffer buf_marking-child for ub.marking .
define buffer buf_marking-lines for ub.marking-lines .

define new shared temp-table tt-doc-pl no-undo
field pl-code as integer format "99999999999"
field pl-code2 as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code as integer format "99999999999"
field cli-qnty like ub.doc-pl.cli-qnty
field cli-fact-qnty like ub.doc-pl.cli-fact-qnty
field cli-doc-qnty like ub.doc-pl.cli-doc-qnty
field rest-af-qnty like ub.doc-pl.rest-af-qnty
field cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty
field rest-bf-qnty like ub.doc-pl.rest-bf-qnty
field cli-rest-bf-qnty like ub.doc-pl.cli-rest-bf-qnty
index pi obj-type obj-code pl-code out-code gds-code
index doc out-code gds-code obj-code obj-type pl-code
index gds-code gds-code
.

/* ***************************  Definitions  ************************** */
/* Parameter Definition */
define input parameter ParParentProc as widget-handle no-undo .
define input parameter doc-rec       as recid         no-undo .
define input parameter line-rec      as recid         no-undo .
define input parameter gds-rec       as recid         no-undo .
define input parameter prt-mode      as character     no-undo .
define input parameter cur-rec       as recid         no-undo .
define input parameter node-type     as character     no-undo .

/* VSS Variable Definition */
define variable vss-revision    as character no-undo initial "$Revision: 81f7d91a817a, 3654, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2024/01/31 10:15:43 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: out-prt.w $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/out-prt.w $":U .
define variable vss-description as character no-undo initial "Задание док. и факт. количества по признаку или артикулу в рас, возврат, при, спи накладных (внешних и внутренних)":U .

{ cmp/vssrevis.i "substitute('&1|&2':u,cur-rec,node-type)" }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ str/get-pr.i   def }
{ gbl/tax-name.i }
{ gbl/cur-time.i }
{ str/lib-trn.i  }
{ str/lib-calc.i }
{ trg/factord.i  }
{ str/mpl-auto.i }
{ trg/partsplt.i }
{ gbl/ptrlprop.i def            }
{ str/out-ptrl.i def one-line   }
{ str/prslnew.i "proc"         }
{ gbl/lineattr.i    }
{ gbl/getsect.i  def }
{ gbl/key-rec.i  }
{ cmp/ini-lib.i  }
{ utl/gtin.i }
{ str/utd-typemark.i }

/* Local Variable Definition -- For  r s r v - o u t . i */
define variable chg-qnty     like ub.gds-dtl.doc-qnty no-undo initial ?.
define variable rec-inv-line as   recid               no-undo.
/* Local Variable Definition */
define variable v-work-with-qnty           as character no-undo .
define variable v-undo-all                 as logical   no-undo .
define variable is-petrolium               as logical   no-undo .
define variable is-pieces                  as logical   no-undo .
define variable v-ptrl-without-rvs         as character no-undo .
define variable v-attr-type                as character no-undo .
define variable v-hold-doc                 as logical   no-undo .
define variable varis-new                  as logical   no-undo .
define variable varroad-tax-label          as character no-undo .
define variable r-recid-petrol-kg          as recid     no-undo .
define variable add-def-mode               as logical   no-undo .
define variable changed-price              as character no-undo .
define variable g#host-name                as character no-undo .
define variable g#host-code                as integer   no-undo .
define variable g#log                      as logical   no-undo .
define variable base-code                  as integer   no-undo .
define variable base-type                  as character no-undo .
define variable prt-rec                    as recid     no-undo .
define variable v-place-rsrv               as logical   no-undo .
define variable par-1                      as character no-undo .
define variable par-0                      as logical   no-undo .
define variable v-gds-ptrl-densities       as character no-undo.
define variable v-min-dens                 as decimal   no-undo.
define variable v-max-dens                 as decimal   no-undo.

define variable v-old-doc-qnty             like ub.gds-dtl.doc-qnty no-undo .
define variable v-old-doc-cli-qnty         like ub.gds-dtl.doc-qnty no-undo .
define variable v-old-fact-qnty            like ub.gds-dtl.doc-qnty no-undo .
define variable v-old-fact-cli-qnty        like ub.gds-dtl.doc-qnty no-undo .

define variable pr-naklvalue               as logical   no-undo .
define variable pr-nakltype                as character initial ?         no-undo.
define variable pr-genmrg                  as character initial ?         no-undo.

define variable v-is-return                as logical   no-undo initial no  .
define variable in-part-rec                as integer   no-undo .
define variable v-new-qnty                 as decimal   no-undo .
define variable v-free-qnty                as decimal   no-undo .
define variable v-no-add-marks             as logical   no-undo initial no .

define variable vIsExemplarGoods           as logical   no-undo .
define variable v-mark-weight              as decimal   no-undo .
define variable v-isweighed                as logical   no-undo .
define variable vRightChngQntyCode         as character no-undo .
define variable vRightChngQnty             as logical   no-undo .
define variable vBackSale                  as logical   no-undo initial no. /* признак возврата по договору "Обратная продажа" */
{ gbl/objsrv.i }
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
define variable v-pack-qnty as integer no-undo .
define variable vScanMark   as character no-undo.

define variable varvalue as character no-undo .
define variable vartype  as character no-undo .
define temp-table tt-parts-all   no-undo like ub.parts .
define temp-table tt-parts-split no-undo like ub.parts
  index pi is unique primary
    obj-type
    obj-code
    artic
    prod-type
    prod-code
    in-code
    out-code
    part-code
    pl-code
.

{ref/imagelist.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-out-prt

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES price-list

/* Definitions for DIALOG-BOX d-out-prt                                 */
&Scoped-define FIELDS-IN-QUERY-d-out-prt price-list.doc-num 
&Scoped-define ENABLED-FIELDS-IN-QUERY-d-out-prt price-list.doc-num 
&Scoped-define ENABLED-TABLES-IN-QUERY-d-out-prt price-list
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-d-out-prt price-list
&Scoped-define QUERY-STRING-d-out-prt FOR EACH price-list SHARE-LOCK
&Scoped-define OPEN-QUERY-d-out-prt OPEN QUERY d-out-prt FOR EACH price-list SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-out-prt price-list
&Scoped-define FIRST-TABLE-IN-QUERY-d-out-prt price-list


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS gds-dtl.artic buf_goods.gds-name ~
gds-dtl.prod-code gds-dtl.prod-type clients.obj-name b-c-b.b-code ~
gds-prt.f-name prt-obj.free-qnty price-list.doc-num doc-line.temperature ~
doc-line.road-tax doc-line.doc-density gds-dtl.discnt-rubl ~
gds-dtl.discnt-base gds-dtl.discnt-pc gds-dtl.discnt-type gds-dtl.doc-qnty ~
gds-dtl.price-rubl gds-dtl.price-base gds-dtl.fact-qnty buf_goods.qnty-cart ~
buf_goods.unit-base 
&Scoped-define ENABLED-TABLES gds-dtl buf_goods clients b-c-b gds-prt ~
prt-obj price-list doc-line
&Scoped-define FIRST-ENABLED-TABLE gds-dtl
&Scoped-define SECOND-ENABLED-TABLE buf_goods
&Scoped-define THIRD-ENABLED-TABLE clients
&Scoped-define FOURTH-ENABLED-TABLE b-c-b
&Scoped-define FIFTH-ENABLED-TABLE gds-prt
&Scoped-define SIXTH-ENABLED-TABLE prt-obj
&Scoped-define SEVENTH-ENABLED-TABLE price-list
&Scoped-define EIGHTH-ENABLED-TABLE doc-line
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-arch b-place c-reason ~
b-history b-help RECT-gds RECT-tot RECT-discnt RECT-qnty g-image ~
varprod-bc-str r-price v-price-rubl-kg v-price-base-kg v-qnty-kg ~
v-fact-qnty-kg b-corr-price-sale tot-rubl tot-base TEXT-1 base-curr 
&Scoped-Define DISPLAYED-FIELDS gds-dtl.artic buf_goods.gds-name ~
gds-dtl.prod-code gds-dtl.prod-type clients.obj-name b-c-b.b-code ~
gds-prt.f-name prt-obj.free-qnty price-list.doc-num doc-line.temperature ~
doc-line.road-tax doc-line.doc-density gds-dtl.discnt-rubl ~
gds-dtl.discnt-base gds-dtl.discnt-pc gds-dtl.discnt-type gds-dtl.doc-qnty ~
gds-dtl.price-rubl gds-dtl.price-base gds-dtl.fact-qnty buf_goods.qnty-cart ~
buf_goods.unit-base 
&Scoped-define DISPLAYED-TABLES gds-dtl buf_goods clients b-c-b gds-prt ~
prt-obj price-list doc-line
&Scoped-define FIRST-DISPLAYED-TABLE gds-dtl
&Scoped-define SECOND-DISPLAYED-TABLE buf_goods
&Scoped-define THIRD-DISPLAYED-TABLE clients
&Scoped-define FOURTH-DISPLAYED-TABLE b-c-b
&Scoped-define FIFTH-DISPLAYED-TABLE gds-prt
&Scoped-define SIXTH-DISPLAYED-TABLE prt-obj
&Scoped-define SEVENTH-DISPLAYED-TABLE price-list
&Scoped-define EIGHTH-DISPLAYED-TABLE doc-line
&Scoped-Define DISPLAYED-OBJECTS c-reason varprod-bc-str v-price-rubl-kg ~
v-price-base-kg v-qnty-kg v-fact-qnty-kg tot-rubl tot-base TEXT-1 base-curr 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-addinf DEFAULT 
     LABEL "Доп.ин&ф." 
     SIZE 10 BY 1.

DEFINE BUTTON b-arch 
     LABEL "Док.цены":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-corr-price-sale 
     IMAGE-UP FILE "cmp/check.bmp":U
     IMAGE-DOWN FILE "cmp/check.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/check.bmp":U
     LABEL "" 
     SIZE 3 BY .79 TOOLTIP "Выбор цены".

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-history 
     LABEL "Ис&тория" 
     SIZE 10 BY 1 TOOLTIP "История изменения строки документа".

DEFINE BUTTON b-place 
     LABEL "Место хр.":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE BUTTON b-rvs-af DEFAULT 
     LABEL "Св.после" 
     SIZE 10 BY 1.

DEFINE BUTTON b-rvs-bf DEFAULT 
     LABEL "Св.до" 
     SIZE 10 BY 1.

DEFINE BUTTON r-price 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .79 TOOLTIP "Выбор цены".

DEFINE VARIABLE c-reason AS integer FORMAT "-999":U INITIAL 0 
     LABEL "Причина списания" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "",0
     DROP-DOWN-LIST
     SIZE 38.25 BY 1 NO-UNDO.

DEFINE VARIABLE base-curr AS CHARACTER FORMAT "x(3)":U 
      VIEW-AS TEXT 
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE TEXT-1 AS CHARACTER FORMAT "x(3)":U 
      VIEW-AS TEXT 
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Сумма" 
     VIEW-AS FILL-IN 
     SIZE 23 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-fact-qnty-kg LIKE inv-line.wast-cli-qnty
     LABEL "Факт,кг" 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-price-base-kg AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-price-rubl-kg AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0 
     LABEL "Цена,кг" 
     VIEW-AS FILL-IN 
     SIZE 23 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-qnty-kg LIKE inv-line.wast-cli-qnty
     LABEL "По док,кг" 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varprod-bc-str AS CHARACTER FORMAT "X(40)" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1 NO-UNDO.

DEFINE IMAGE g-image
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 18.5 BY 3.75.

DEFINE RECTANGLE RECT-discnt
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 95.5 BY 6.

DEFINE RECTANGLE RECT-gds
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 76 BY 3.75.

DEFINE RECTANGLE RECT-qnty
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 41.75 BY 4.5.

DEFINE RECTANGLE RECT-tot
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 95.5 BY 12.25.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY d-out-prt FOR 
      price-list SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-out-prt
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-arch AT ROW 1 COL 21
     b-place AT ROW 1 COL 31 WIDGET-ID 2
     b-addinf AT ROW 1 COL 41
     b-rvs-bf AT ROW 1 COL 51 WIDGET-ID 6
     c-reason AT ROW 1 COL 51.25 COLON-ALIGNED WIDGET-ID 12
     b-rvs-af AT ROW 1 COL 61 WIDGET-ID 4
     b-history AT ROW 1 COL 78.5
     b-help AT ROW 1 COL 88.5
     gds-dtl.artic AT ROW 2.58 COL 3.75 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 17 BY 1
     buf_goods.gds-name AT ROW 2.58 COL 19.38 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 50 BY 1
          FGCOLOR 4 
     varprod-bc-str AT ROW 3.58 COL 3.75 NO-LABEL
     gds-dtl.prod-code AT ROW 4.58 COL 3.75 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     gds-dtl.prod-type AT ROW 4.58 COL 13.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 8 BY 1
     clients.obj-name AT ROW 4.58 COL 22.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 50 BY 1
          FGCOLOR 4 
     b-c-b.b-code AT ROW 6.46 COL 20 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
          FGCOLOR 4 
     gds-prt.f-name AT ROW 6.46 COL 30.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 25 BY 1
          FGCOLOR 4 
     prt-obj.free-qnty AT ROW 6.5 COL 70.25 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
          FGCOLOR 4 
     price-list.doc-num AT ROW 7.46 COL 20 COLON-ALIGNED
          LABEL "Переоценка"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     doc-line.temperature AT ROW 7.5 COL 70.25 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 7 BY 1
          FGCOLOR 4 
     doc-line.road-tax AT ROW 8.46 COL 20 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     doc-line.doc-density AT ROW 8.5 COL 70.25 COLON-ALIGNED FORMAT "9.9999999999"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
          FGCOLOR 4 
     gds-dtl.discnt-rubl AT ROW 9.92 COL 10 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 23 BY 1
          FGCOLOR 4 
     gds-dtl.discnt-base AT ROW 9.92 COL 34 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 19 BY 1
          FGCOLOR 4 
     gds-dtl.discnt-pc AT ROW 9.92 COL 53 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 8 BY 1
          FGCOLOR 4 
     gds-dtl.discnt-type AT ROW 9.92 COL 63.5
          VIEW-AS TOGGLE-BOX
          SIZE 11 BY 1
     gds-dtl.doc-qnty AT ROW 11.42 COL 80.25 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY 1
          FGCOLOR 4 
     gds-dtl.price-rubl AT ROW 11.46 COL 10 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 23 BY 1
          FGCOLOR 4 
     gds-dtl.price-base AT ROW 11.46 COL 34 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 19 BY 1
          FGCOLOR 4 
     gds-dtl.fact-qnty AT ROW 12.42 COL 80.25 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY 1
          FGCOLOR 4 
     r-price AT ROW 12.5 COL 31.88
     v-price-rubl-kg AT ROW 13.33 COL 10 COLON-ALIGNED
     v-price-base-kg AT ROW 13.33 COL 34 COLON-ALIGNED NO-LABEL
     v-qnty-kg AT ROW 13.42 COL 80.25 COLON-ALIGNED HELP
          ""
          LABEL "По док,кг"
          FGCOLOR 4 
    WITH VIEW-AS DIALOG-BOX 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON b-exit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME d-out-prt
     v-fact-qnty-kg AT ROW 14.42 COL 80.25 COLON-ALIGNED HELP
          ""
          LABEL "Факт,кг"
          FGCOLOR 4 
     gds-dtl.new-price-sale AT ROW 14.54 COL 20.75 COLON-ALIGNED WIDGET-ID 8
          VIEW-AS FILL-IN 
          SIZE 22 BY 1 TOOLTIP "Переоценка до закрытия документа"
     b-corr-price-sale AT ROW 14.63 COL 45 WIDGET-ID 10
     tot-rubl AT ROW 16 COL 10 COLON-ALIGNED
     tot-base AT ROW 16 COL 34 COLON-ALIGNED NO-LABEL
     buf_goods.qnty-cart AT ROW 16 COL 80.25 COLON-ALIGNED
          LABEL "В упаковке"
          VIEW-AS FILL-IN 
          SIZE 13 BY 1
          FGCOLOR 4 
     TEXT-1 AT ROW 17.25 COL 10 COLON-ALIGNED NO-LABEL
     base-curr AT ROW 17.25 COL 34 COLON-ALIGNED NO-LABEL
     buf_goods.unit-base AT ROW 17.25 COL 80.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT 
          SIZE 4 BY 1
          BGCOLOR 3 FGCOLOR 15 
     RECT-gds AT ROW 2.25 COL 2.5
     RECT-tot AT ROW 6.25 COL 2
     RECT-discnt AT ROW 9.75 COL 2
     RECT-qnty AT ROW 11.25 COL 55.75
     g-image AT ROW 2.25 COL 79 WIDGET-ID 8
     SPACE(1.12) SKIP(12.50)
    WITH VIEW-AS DIALOG-BOX 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE ""
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Temp-Tables and Buffers:
      TABLE: b-c-b B "?" ? ub bar-code
      TABLE: buf_goods B "?" ? ub ub.goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-out-prt
   FRAME-NAME                                                           */
ASSIGN 
       FRAME d-out-prt:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN gds-dtl.artic IN FRAME d-out-prt
   ALIGN-L                                                              */
/* SETTINGS FOR BUTTON b-addinf IN FRAME d-out-prt
   NO-ENABLE                                                            */
ASSIGN 
       b-addinf:HIDDEN IN FRAME d-out-prt           = TRUE.

/* SETTINGS FOR BUTTON b-rvs-af IN FRAME d-out-prt
   NO-ENABLE                                                            */
ASSIGN 
       b-rvs-af:HIDDEN IN FRAME d-out-prt           = TRUE.

/* SETTINGS FOR BUTTON b-rvs-bf IN FRAME d-out-prt
   NO-ENABLE                                                            */
ASSIGN 
       b-rvs-bf:HIDDEN IN FRAME d-out-prt           = TRUE.

/* SETTINGS FOR FILL-IN doc-line.doc-density IN FRAME d-out-prt
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN price-list.doc-num IN FRAME d-out-prt
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN gds-dtl.new-price-sale IN FRAME d-out-prt
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN gds-dtl.prod-code IN FRAME d-out-prt
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN buf_goods.qnty-cart IN FRAME d-out-prt
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN v-fact-qnty-kg IN FRAME d-out-prt
   LIKE = ub.inv-line.wast-cli-qnty EXP-LABEL EXP-HELP                  */
/* SETTINGS FOR FILL-IN v-qnty-kg IN FRAME d-out-prt
   LIKE = ub.inv-line.wast-cli-qnty EXP-LABEL EXP-HELP EXP-SIZE         */
/* SETTINGS FOR FILL-IN varprod-bc-str IN FRAME d-out-prt
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-out-prt
/* Query rebuild information for DIALOG-BOX d-out-prt
     _TblList          = "ub.price-list"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX d-out-prt */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-out-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-out-prt d-out-prt
ON END-ERROR OF FRAME d-out-prt
DO:
  apply "CHOOSE":U to b-quit in frame {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-addinf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-addinf d-out-prt
ON CHOOSE OF b-addinf IN FRAME d-out-prt /* Доп.инф. */
DO:

  define variable v-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
  define variable v-new-density          like ub.doc-line.fact-density no-undo .
  define variable v-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .

  if t-doc.doc-type = {&income} then do:
    assign
      v-new-fact-qnty     = ( input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty )
      v-new-density       = ub.doc-line.fact-density
      v-new-cli-fact-qnty = ( input frame {&FRAME-NAME} v-fact-qnty-kg )
    .

    run proc-b-addinfo in this-procedure
      ( input        parparentproc
       ,input        ( if prt-mode <> {&lookup} then {&update} else {&lookup} )
       ,input        ub.doc-line.doc-code
       ,input        buf_goods.gds-code
       ,input        stfactplvalue
       ,input        varauto-tank
       ,input        varupd-fact-qnty
       ,input        input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty
       ,input        ub.doc-line.doc-density
       ,input-output v-new-fact-qnty
       ,input-output v-new-density
       ,input-output v-new-cli-fact-qnty
       ,input-output v-prt-car-num
       ,input-output v-prt-car-vol
       ,input-output v-prt-tests
       ,input-output v-prt-autoent-obj-type
       ,input-output v-prt-autoent-obj-code
       ,input-output v-prt-item-pour
       ,input-output v-prt-time-pour
       ,input-output v-prt-tank-vol
       ,input-output v-prt-tank-temp
       ,input-output v-prt-tank-water
       ,input-output v-prt-tank-density
       ,input-output v-prt-tank-weight
       ,input-output v-prt-time-income
       ,input-output v-prt-start-real-date
       ,input-output v-prt-start-real-time
       ,input-output v-prt-end-real-date
       ,input-output v-prt-end-real-time
       ,input-output v-prt-mouth
       ,input-output v-prt-fio
       ,input-output v-prt-ptbotype
       ,input-output v-prt-ptbocode
       ,input-output v-prt-a-b-tarir
       ,input-output v-diameter
       ,input-output v-place-si
       ,input-output v-tank-density-pomi
       ,input-output v-prt-certif-fuel 
       ,input-output v-prt-norm-doc 
       ,input-output v-prt-num-passport 
       ,input-output v-prt-validity-certif
       ,input-output v-prt-passport-plotn
       ,input-output v-prt-num-plotn             
       ,input-output v-prt-date-pov-plotn     
      ) no-error .

    if error-status :error then do:
      message
        substitute("Ошибка при изменении дополнительной информации.") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply .
    end.
    if ( input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty ) <> v-new-fact-qnty
      or ( input frame {&FRAME-NAME} v-fact-qnty-kg ) <> v-new-cli-fact-qnty
      or ub.doc-line.fact-density <> v-new-density
    then do:
      run correct-fact-qnty in this-procedure
        ( input v-new-fact-qnty
         ,input v-new-density
        ) no-error .
    end.

  end.
  else do:
    run str/out-ladd.w
      ( input ParParentProc
       ,input ( if prt-mode <> {&lookup} then {&update} else {&lookup} )
       ,input-output v-prt-car-num
       ,input-output v-prt-autoent-obj-type
       ,input-output v-prt-autoent-obj-code
      ) no-error.
    if error-status :error then do:
      message
          vss-workfile vss-revision vss-description
          skip(1)
          skip "Ошибка дополнительных данных строки."
          skip return-value
          skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
      view-as alert-box error.
      undo, return no-apply .
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-arch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-arch d-out-prt
ON CHOOSE OF b-arch IN FRAME d-out-prt /* Док.цены */
DO:
  define variable calc_price-base as decimal no-undo.
  define variable calc_price-rubl as decimal no-undo.

  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    ub.doc-line.obj-type
    ub.doc-line.obj-code
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    v-chk-act-host-code
    ub.doc-line.obj-type
    ub.doc-line.obj-code
    0
    0
    0
    true
    g#log
  }
  if g#log <> yes then do: return no-apply. end.
  assign
    calc_price-base = ub.doc-line.price-base * ub.gds-dtl.fact-qnty
    calc_price-rubl = ub.doc-line.price-rubl * ub.gds-dtl.fact-qnty
  .
  message "Сумма в ценах документа:" skip
    string( calc_price-base,     "->>,>>>,>>>,>>9.99":U ) base-type skip
    string( calc_price-rubl, "->>,>>>,>>>,>>>,>>9.99":U ) "{&abbr_rub_allshift}"     skip( 2 )
          "Сумма к оплате:" skip
    string( tot-base,     "->>,>>>,>>>,>>9.99":U ) base-type skip
    string( tot-rubl, "->>,>>>,>>>,>>>,>>9.99":U ) "{&abbr_rub_allshift}"     skip( 2 )
          "Разница:" skip
    string( tot-base - calc_price-base,     "->>,>>>,>>>,>>9.99":U ) base-type skip
    string( tot-rubl - calc_price-rubl, "->>,>>>,>>>,>>>,>>9.99":U ) "{&abbr_rub_allshift}"     skip( 2 )
          "Наценка:"
    string( ( tot-base - calc_price-base ) / calc_price-base * 100, "->>9.9<%":U )
  view-as alert-box title 'Товар: "' + buf_goods.gds-name + '".  Признак: "' + ub.gds-prt.f-name + '".'.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-corr-price-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-corr-price-sale d-out-prt
ON CHOOSE OF b-corr-price-sale IN FRAME d-out-prt
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-out-prt
ON CHOOSE OF b-exit IN FRAME d-out-prt /* Ввод */
DO:

  { gbl/stdbtn.i }
  define variable total_gds-dtl_doc-qnty  like ub.gds-dtl.doc-qnty      no-undo.
  define variable total_gds-dtl_fact-qnty like ub.gds-dtl.fact-qnty     no-undo.
  define variable t_qty                   like ub.gds-dtl.fact-qnty     no-undo.
  define variable varprt-obj_free-qnty    like ub.prt-obj.free-qnty     no-undo.
  define variable v-ok                    as   logical                  no-undo .
  define variable v-new-fact-qnty         like ub.doc-line.fact-qnty    no-undo .
  define variable v-new-density           like ub.doc-line.fact-density no-undo .
  define variable v-new-cli-fact-qnty     like ub.doc-line.fact-qnty    no-undo .

  if prt-mode = {&lookup} then do:
    return no-apply.
  end.
      if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then
      do:
        if can-find(first buf_marking-lines where 
                          buf_marking-lines.out-code = t-doc.doc-code
                      and buf_marking-lines.gds-code = buf_goods.gds-code) then 
          return .
      end. 
    
  run check-fact-qnty in this-procedure no-error .
  if error-status :error then return no-apply.

  block_save:
  do transaction
  on error undo block_save, return no-apply
  :
    /* Если кол-во в базовых единицах товара получается дробное, то ошибка. */
    if can-find( first ub.units where ub.units.unit-name = buf_goods.unit-base
                        and lookup( {&pieces}, ub.units.type) > 0 ) and
      truncate( input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty,  0 )
          <>    input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty
    then do:
      message "Базовая единица товара " buf_goods.unit-base " - штучная." skip
              "Кол-во по документу должно быть целым."
      view-as alert-box error.
      return no-apply.
    end.
    if t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} then do:
      if c-reason > 0 then do:
        find first ub.doc-line-attr no-lock where ub.doc-line-attr.doc-code = t-doc.doc-code and
        ub.doc-line-attr.gds-code = buf_goods.gds-code and
        ub.doc-line-attr.attr-code = "reasonSpisan" no-error .
        if not available (ub.doc-line-attr) then do:
          create ub.doc-line-attr .
          assign
          ub.doc-line-attr.doc-code = t-doc.doc-code
          ub.doc-line-attr.gds-code = buf_goods.gds-code
          ub.doc-line-attr.attr-code = "reasonSpisan"
          .
        end.
        ub.doc-line-attr.attr-value = string (c-reason) .
      end.
    end.
    if t-doc.doc-type = {&expense}
    and buf_goods.qnty-cart <> 0
    and not v-is-return
    and not v-isweighed
    then do:
      if (input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty / buf_goods.qnty-cart) - round (input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty / buf_goods.qnty-cart, 0) <> 0 then do:
        if available ub.prt-obj then do:
          assign
            varprt-obj_free-qnty = ub.prt-obj.free-qnty
          .
        end.
        else do:
          assign
            varprt-obj_free-qnty = 0
          .
        end.
        if t-doc.status_ = {&inquiry} or
          ( varprt-obj_free-qnty + ub.gds-dtl.doc-qnty > buf_goods.qnty-cart and
            varprt-obj_free-qnty + ub.gds-dtl.doc-qnty <> input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty ) then do:
          assign
            g#log = yes
          .
          message "Товар рекомендуется выписывать упаковками." skip( 2 )
                  "Округлить до целого числа упаковок ?"
          view-as alert-box question buttons YES-NO update g#log.
          if g#log then do:
            if round( input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty / buf_goods.qnty-cart, 0 ) = 0 then do:
              display
                buf_goods.qnty-cart @ ub.gds-dtl.doc-qnty
              with frame {&FRAME-NAME}.
            end.
            else do:
              display
                round( input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty / buf_goods.qnty-cart, 0 ) *
                                                buf_goods.qnty-cart  @ ub.gds-dtl.doc-qnty
              with frame {&FRAME-NAME}.
            end.
          end.
        end.
      end.
    end.

    if prt-mode = {&prt-def} or prt-mode = {&inv-def} then do:
      assign
        total_gds-dtl_doc-qnty  = 0
        total_gds-dtl_fact-qnty = 0
      .
      for each g-d-b where g-d-b.prod-code = ub.doc-line.prod-code
                      and g-d-b.prod-type = ub.doc-line.prod-type
                      and g-d-b.artic     = ub.doc-line.artic
                      and g-d-b.doc-code  = ub.doc-line.doc-code
                      and g-d-b.prt-code <> ub.gds-dtl.prt-code :
        assign
          total_gds-dtl_doc-qnty  = total_gds-dtl_doc-qnty  + g-d-b.doc-qnty
          total_gds-dtl_fact-qnty = total_gds-dtl_fact-qnty + g-d-b.fact-qnty
        .
      end. /* for each g-d-b */
      assign
        total_gds-dtl_doc-qnty  = total_gds-dtl_doc-qnty  + ( input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty  )
        total_gds-dtl_fact-qnty = total_gds-dtl_fact-qnty + ( input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty )
      .
      /*
      if t-doc.doc-type = {&income} and not t-doc.internal  and
        ( ( total_gds-dtl_doc-qnty  > ub.doc-line.doc-qnty  and v-work-with-qnty = "doc":U ) or
        (   total_gds-dtl_fact-qnty > ub.doc-line.fact-qnty and v-work-with-qnty = "fact":U ) )
      then do:
        message "Внимание ! Количество по всем признакам шкалы уже превышает"
                "количество по артикулу."
        view-as alert-box warning.
      end.
      */
    end. /* prt-mode = {&prt-def} or prt-mode = {&inv-def} */
    run re-calcpr in this-procedure .

    if is-petrolium = yes
      and is-pieces = no
      and not is-gas(buf_goods.gds-code)
    then do:
      if { str/valddnst.i chk ub.doc-line.doc-density "buf_goods.unit-base = buf_goods.unit-cli" } <> true then do:
        message
          "Неверное значение плотности для топлива:" ub.doc-line.doc-density "." skip
          "Плотность топлива должна быть в диапазоне: больше 0 и меньше 1."
          view-as alert-box error title " ОШИБКА!!! ".
        apply "ENTRY":U to ub.doc-line.doc-density in frame {&FRAME-NAME}.
        return no-apply.
      end. /* density */
      if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
        if (ub.doc-line.doc-density) < v-min-dens
        or (ub.doc-line.doc-density) > v-max-dens
        then do:
            message
              substitute("Введенное значение плотности находится вне заданного диапазона: &1.",
              v-gds-ptrl-densities )
              view-as alert-box error .
            apply "ENTRY":U to ub.doc-line.doc-density in frame {&FRAME-NAME}.
            return no-apply .
        end.
      end.

      if t-doc.doc-type = {&income} then do:
        if v-work-with-qnty = "fact":U
          or v-work-with-qnty = "fact-doc":U
        then do:
          assign
            v-ok = true
          .
          run chkdcrvs in this-procedure
            ( input  t-doc.doc-code
            ,input  buf_goods.gds-code
            ,output v-ok
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            return no-apply .
          end.
          if v-ok = true then do:
            assign
              v-new-fact-qnty     = (input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty)
              v-new-density       = ub.doc-line.fact-density
              v-new-cli-fact-qnty = (input frame {&FRAME-NAME} v-fact-qnty-kg)
            .
            run local-state-fact-rvs in this-procedure
              ( input        t-doc.doc-code
              ,input        buf_goods.gds-code
              ,input        stfactplvalue
              ,input        varrevision
              ,input        varupd-fact-qnty
              ,input        (input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty)
              ,input        ub.doc-line.doc-density
              ,input-output v-new-fact-qnty
              ,input-output v-new-density
              ,input-output v-new-cli-fact-qnty
              ) no-error .
            if error-status :error then do:
              message
                "Ошибка при установке факт кол-ва (revision)." skip
                return-value
                view-as alert-box error .
              undo block_save, return no-apply .
            end. /* error */

            if ( input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty ) <> v-new-fact-qnty
              or ( input frame {&FRAME-NAME} v-fact-qnty-kg ) <> v-new-cli-fact-qnty
              or ub.doc-line.fact-density <> v-new-density
            then do:
              run correct-fact-qnty in this-procedure
                ( input v-new-fact-qnty
                ,input v-new-density
                ) no-error .
            end.

            assign
              v-new-fact-qnty     = (input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty)
              v-new-density       = ub.doc-line.fact-density
              v-new-cli-fact-qnty = (input frame {&FRAME-NAME} v-fact-qnty-kg)
            .

            run eq-qnty-rvs-pl in this-procedure
              ( input        t-doc.doc-code
              ,input        buf_goods.gds-code
              ,input        varupd-fact-qnty
              ,input-output v-new-fact-qnty
              ,input-output v-new-density
              ,input-output v-new-cli-fact-qnty
              ,      output v-ok
              ) no-error .
            if error-status :error then do:
              message
                "Ошибка при установке факт кол-ва по местам хранения." skip
                return-value
                view-as alert-box error .
              undo block_save, return no-apply .
            end. /* error */

            if ( input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty ) <> v-new-fact-qnty
              or ( input frame {&FRAME-NAME} v-fact-qnty-kg ) <> v-new-cli-fact-qnty
              or ub.doc-line.fact-density <> v-new-density
            then do:
              assign
                ub.doc-line.fact-density = v-new-density
              .
              display
                v-new-fact-qnty @ ub.gds-dtl.fact-qnty
                v-new-fact-qnty * v-new-density when v-fact-qnty-kg :visible = true @ v-fact-qnty-kg
                with frame {&frame-name} .

            end.
            if v-ok = false then do:
              return .
            end.
          end.
        end.

        run str/in-laddout.w
          ( input        parParentProc
          ,input        "set-attr":U
          ,input        t-doc.doc-code
          ,input        buf_goods.gds-code
          ,input-output v-prt-car-num
          ,input-output v-prt-car-vol
          ,input-output v-prt-tests
          ,input-output v-prt-autoent-obj-type
          ,input-output v-prt-autoent-obj-code
          ,input-output v-prt-item-pour
          ,input-output v-prt-time-pour
          ,input-output v-prt-tank-vol
          ,input-output v-prt-tank-temp
          ,input-output v-prt-tank-water
          ,input-output v-prt-tank-density
          ,input-output v-prt-tank-weight
          ,input-output v-prt-time-income
          ,input-output v-prt-start-real-date
          ,input-output v-prt-start-real-time
          ,input-output v-prt-end-real-date
          ,input-output v-prt-end-real-time
          ,input-output v-prt-mouth
          ,input-output v-prt-fio
          ,input-output v-prt-ptbotype
          ,input-output v-prt-ptbocode
          ,input-output v-prt-a-b-tarir
          ,input-output v-diameter
          ,input-output v-place-si
          ,input-output v-tank-density-pomi
          ,input-output v-prt-certif-fuel 
          ,input-output v-prt-norm-doc 
          ,input-output v-prt-num-passport 
          ,input-output v-prt-validity-certif
          ,input-output v-prt-passport-plotn
          ,input-output v-prt-num-plotn             
          ,input-output v-prt-date-pov-plotn   
          ,      output was_setting
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при сохранении дополнительной информации!") skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return no-apply.
        end.
      end.
      else do:
        run write-doc-line-attr in this-procedure (
              input ub.doc-line.doc-code
            , input buf_goods.gds-code
            , input "car-num":U
            , input v-prt-car-num
        ).
        run write-doc-line-attr in this-procedure (
              input ub.doc-line.doc-code
            , input buf_goods.gds-code
            , input "autoent-obj-type":U
            , input v-prt-autoent-obj-type
        ).
        run write-doc-line-attr in this-procedure (
              input ub.doc-line.doc-code
            , input buf_goods.gds-code
            , input "autoent-obj-code":U
            , input v-prt-autoent-obj-code
        ).
      end.

    end. /* petrol */

    run check-place-rsrv in this-procedure
      no-error .
    if error-status :error then do:
      undo block_save, return no-apply.
    end.

    /* Проверка не должна быть на накл + */
    if ub.gds-dtl.fact-qnty :sensitive in frame {&frame-name} = true
      and input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty = 0.0
      and ub.gds-dtl.doc-qnty = 0.0
    then do:
      message
        "Установлено факт количество = 0. Изменения игнорируются."
        view-as alert-box information.
      undo block_save, return no-apply.
    end.


    if input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty = 0.0 then do:
      if v-work-with-qnty = "doc":U then do:
        message
          "Установлено количество = 0. Изменения игнорируются."
          view-as alert-box information.
        undo block_save, return no-apply.
      end.
    end.
    else do:
      if ( ( input frame {&FRAME-NAME} ub.gds-dtl.price-base = ? and not t-doc.print-rubl )
            or
            ( input frame {&FRAME-NAME} ub.gds-dtl.price-rubl = ? and t-doc.print-rubl )
          )
        and t-doc.status_ <> {&inquiry}
        and t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}
      then do:
        message
          "Указана неизвестная цена. Изменения игнорируются."
          view-as alert-box information.
        undo block_save, return no-apply.
      end.
    end.
    
    if v-is-return
    then do :
      if v-work-with-qnty = "doc":U then do:
        v-new-qnty = input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty - ub.gds-dtl.doc-qnty .
      end .
      else do :
        v-new-qnty = input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty - ub.gds-dtl.fact-qnty .
      end .
      find first in_parts no-lock where recid(in_parts) = in-part-rec no-error .
      if available in_parts
      then do :
        v-free-qnty = in_parts.fact-qnty .
        for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&table_parts}
                                        and buf_gen-attr.attr-code  = "in-part-key"
                                        and buf_gen-attr.attr-value = {key/parts.i in_parts },
        first out_parts no-lock where out_parts.obj-type  = entry(2, buf_gen-attr.p-key, {&delim-key})
                                  and out_parts.obj-code  = integer(entry(3, buf_gen-attr.p-key, {&delim-key}))
                                  and out_parts.artic     = entry(4, buf_gen-attr.p-key, {&delim-key})
                                  and out_parts.prod-type = entry(5, buf_gen-attr.p-key, {&delim-key})
                                  and out_parts.prod-code = integer(entry(6, buf_gen-attr.p-key, {&delim-key}))
                                  and out_parts.in-code   = entry(7, buf_gen-attr.p-key, {&delim-key})
                                  and out_parts.out-code  = entry(8, buf_gen-attr.p-key, {&delim-key})
                                  and out_parts.part-code = entry(9, buf_gen-attr.p-key, {&delim-key})
        :
          v-free-qnty = v-free-qnty - out_parts.fact-qnty .
        end .
        
        find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = t-doc.obj-type
                                         and buf_gds-obj.obj-code  = t-doc.obj-code
                                         and buf_gds-obj.artic     = buf_goods.artic
                                         and buf_gds-obj.prod-type = buf_goods.prod-type
                                         and buf_gds-obj.prod-code = buf_goods.prod-code
                                         no-error .
        if error-status :error
        then do:
          message
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo block_save, return no-apply.
        end.
        
        if buf_gds-obj.free-qnty < v-new-qnty
        then do :
          message substitute ("Возвращаемое количество превышает текущий остаток, равный &1. Возврат не возможен.", buf_gds-obj.free-qnty) view-as alert-box .
          display
            ub.gds-dtl.doc-qnty
          with frame {&FRAME-NAME}.
          undo block_save, return no-apply.
        end .
        
        if v-new-qnty > v-free-qnty
        then do :
          if t-doc.reason-code = 25 /* Корректировка поступления */
          then do :
            v-no-add-marks = yes .
            message "Введенное количество превышает максимально допустимое к возврату по выбранной партии. Количество установлено максимально возможным" view-as alert-box .
            if node-type begins "scan-marks"
            then do :
              if v-work-with-qnty = "doc":U
              then do:
                display
                  ub.gds-dtl.doc-qnty
                with frame {&FRAME-NAME}.
              end .
              else do :
                display
                  ub.gds-dtl.fact-qnty
                with frame {&FRAME-NAME}.
              end .
            end .
            else do :
              if v-work-with-qnty = "doc":U
              then do:
                display
                  ub.gds-dtl.doc-qnty + v-free-qnty @ ub.gds-dtl.doc-qnty
                with frame {&FRAME-NAME}.
              end .
              else do :
                display
                  ub.gds-dtl.fact-qnty + v-free-qnty @ ub.gds-dtl.fact-qnty
                with frame {&FRAME-NAME}.
              end .
            end .
          end .
          if t-doc.reason-code = 23 /* Обратная продажа */
          then do :
            if node-type begins "scan-marks"
            and v-free-qnty < 0
            then do : end .
            else do :
              message "Введенное количество превышает максимально допустимое к возврату по выбранной партии, продолжить оформление возврата указанного количества?"
              view-as alert-box question buttons yes-no update g#log .
              if not g#log
              then do :
                v-no-add-marks = yes .
                if node-type begins "scan-marks"
                then do :
                  display
                    ub.gds-dtl.doc-qnty
                  with frame {&FRAME-NAME}.
                end .
                else do :
                  display
                    ub.gds-dtl.doc-qnty
                  with frame {&FRAME-NAME}.
                  undo block_save, return no-apply.
                end .
              end .
            end .
          end .
        end .
        
        if buf_gds-obj.free-qnty < v-new-qnty
        then do :
          message substitute ("Возвращаемое количество превышает текущий остаток, равный &1. Возврат не возможен.", buf_gds-obj.free-qnty) view-as alert-box .
          display
            ub.gds-dtl.doc-qnty
          with frame {&FRAME-NAME}.
          undo block_save, return no-apply.
        end .
        
        
        node-type = {&g#term} .
      end .
    end .

    run rsrv-out in this-procedure
      no-error .
    if error-status :error then do:
      message
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo block_save, return no-apply.
    end.
    
    if v-is-return
    and available in_parts
    then do :
      for each out_parts no-lock where out_parts.obj-type  = in_parts.obj-type
                                   and out_parts.obj-code  = in_parts.obj-code
                                   and out_parts.artic     = in_parts.artic
                                   and out_parts.prod-type = in_parts.prod-type
                                   and out_parts.prod-code = in_parts.prod-code
                                   and out_parts.out-code  = t-doc.doc-code
      :
        find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&table_parts}
                                          and buf_gen-attr.p-key      = {key/parts.i out_parts } 
                                          and buf_gen-attr.attr-code  = "in-part-key"
                                          no-error .
        if not available buf_gen-attr
        then do :
          create buf_gen-attr .
          assign
            buf_gen-attr.table-name = {&table_parts}          
            buf_gen-attr.p-key      = {key/parts.i out_parts }
            buf_gen-attr.attr-code  = "in-part-key"          
            buf_gen-attr.attr-value = {key/parts.i in_parts }
          .
        end .                                  
      end .
    end .

/*    assign*/
/*      prt-rec  = recid( ub.gds-dtl )*/
/*    .*/
/*    find ub.doc-line no-lock*/
/*      where recid( ub.doc-line ) = line-rec*/
/*    .*/
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history d-out-prt
ON CHOOSE OF b-history IN FRAME d-out-prt /* История */
DO:
  define variable v-list as character no-undo.
  run str/docclins.w (
      input        parparentproc,                    /* p-parent-proc  */
      input        '':U,                             /* p-bttns        */
      input        'one':U,                          /* p-mode         */
      input        ub.doc-line.obj-type,                /* p-obj-type     */
      input        ub.doc-line.obj-code,               /* p-obj-code     */
      input        ub.gds-dtl.doc-code,                 /* p-doc-code     */
      input        ub.gds-dtl.artic,                    /* p-artic        */
      input        ub.gds-dtl.prod-type ,               /* p-prod-type    */
      input        ub.gds-dtl.prod-code ,               /* p-prod-code    */
      input-output v-list                            /* p-rid-list     */
      ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-place d-out-prt
ON CHOOSE OF b-place IN FRAME d-out-prt /* Место хр. */
DO:
  { gbl/stdbtn.i }

  if v-place-rsrv <> true
    or b-place :sensitive in frame {&frame-name} <> true
  then do:
    return .
  end.

  run edit-doc-pl in this-procedure
    ( input (if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then t-doc.ext-doc-type else if prt-mode = {&lookup} then {&lookup} else {&update} )
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-out-prt
ON CHOOSE OF b-quit IN FRAME d-out-prt /* Отмена */
DO:

  if prt-mode <> {&lookup} then do:
    if add-def-mode = yes then do:
      delete ub.gds-dtl.
      assign
        prt-rec = ?
      .
    end.
    else do:
      if decimal(trim(ub.gds-dtl.doc-qnty:screen-value   )) <> decimal(trim(string (ub.gds-dtl.doc-qnty    ,ub.gds-dtl.doc-qnty:format ) )  )
        or decimal(trim(ub.gds-dtl.fact-qnty:screen-value  )) <> decimal(trim(string (ub.gds-dtl.fact-qnty   ,ub.gds-dtl.fact-qnty:format ))  )
        or decimal(trim(ub.gds-dtl.price-base:screen-value )) <> decimal(trim(string (ub.gds-dtl.price-base  ,ub.gds-dtl.price-base:format )) )
        or decimal(trim(ub.gds-dtl.price-rubl:screen-value )) <> decimal(trim(string (ub.gds-dtl.price-rubl  ,ub.gds-dtl.price-rubl:format )) )
        or decimal(trim(ub.gds-dtl.discnt-base:screen-value)) <> decimal(trim(string (ub.gds-dtl.discnt-base ,ub.gds-dtl.discnt-base:format) ))
        or decimal(trim(ub.doc-line.temperature:screen-value)) <> decimal(trim(string ( ub.doc-line.temperature , ub.doc-line.temperature:format )))
        or decimal(trim(ub.doc-line.doc-density    :screen-value)) <> decimal(trim(string ( ub.doc-line.doc-density     , ub.doc-line.doc-density    :format )))
        or decimal(trim(ub.gds-dtl.discnt-rubl:screen-value)) <> decimal(trim(string (ub.gds-dtl.discnt-rubl ,ub.gds-dtl.discnt-rubl:format )))
      then do:
        message
          "Сделанные изменения будут отменены." skip
          "Вы действительно хотите выйти без сохранения?"
          view-as alert-box question buttons yes-no update g#log .
        if g#log = false  then do:
          return no-apply .
        end.
      end.
    end.
    assign
      v-undo-all = true
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-dtl.discnt-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.discnt-base d-out-prt
ON LEAVE OF gds-dtl.discnt-base IN FRAME d-out-prt /* Скидка */
DO:
    assign
    ub.gds-dtl.discnt-base
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-dtl.discnt-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.discnt-pc d-out-prt
ON LEAVE OF gds-dtl.discnt-pc IN FRAME d-out-prt /* Скидка */
DO:
    assign
    ub.gds-dtl.discnt-pc
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-dtl.discnt-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.discnt-rubl d-out-prt
ON LEAVE OF gds-dtl.discnt-rubl IN FRAME d-out-prt /* Скидка */
DO:
    assign
    ub.gds-dtl.discnt-rubl
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-dtl.discnt-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.discnt-type d-out-prt
ON VALUE-CHANGED OF gds-dtl.discnt-type IN FRAME d-out-prt /* Процент */
DO:
    assign
    ub.gds-dtl.discnt-type
  .
  if ub.gds-dtl.discnt-type /* процент */ then do:
    enable  ub.gds-dtl.discnt-pc                          with frame {&FRAME-NAME}.
    disable ub.gds-dtl.discnt-base ub.gds-dtl.discnt-rubl with frame {&FRAME-NAME}.
  end.
  else do:
    enable  ub.gds-dtl.discnt-rubl when     t-doc.print-rubl
            ub.gds-dtl.discnt-base when not t-doc.print-rubl
                                   with frame {&FRAME-NAME}.
    disable ub.gds-dtl.discnt-pc   with frame {&FRAME-NAME}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME c-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-reason d-out-prt
ON VALUE-CHANGED OF c-reason IN FRAME d-out-prt /* Процент */
DO:
    assign
    c-reason
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME doc-line.doc-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL doc-line.doc-density d-out-prt
ON LEAVE OF doc-line.doc-density IN FRAME d-out-prt /* Плотность */
DO:

  define buffer buf_doc-pl for ub.doc-pl .

  if input frame {&FRAME-NAME} ub.doc-line.doc-density <> ub.doc-line.doc-density then do:
    assign
      ub.doc-line.doc-density
    .
    if is-petrolium = yes
      and is-pieces = no
    then do:
      if { str/valddnst.i chk ub.doc-line.doc-density "buf_goods.unit-base = buf_goods.unit-cli" } <> yes
      then do:
        message
          "Неверное значение плотности."
          view-as alert-box.
        apply "ENTRY":U to ub.doc-line.doc-density in frame {&FRAME-NAME}.
        return no-apply.
      end.
      if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
        if ((ub.doc-line.doc-density) < v-min-dens or (ub.doc-line.doc-density) > v-max-dens)
        then do:
          message
            "Плотность не входит в диапазон."
            view-as alert-box.
          apply "ENTRY":U to ub.doc-line.doc-density in frame {&FRAME-NAME}.
          return no-apply.
        end.
      end.
      assign
        ub.doc-line.cli-base-rate = 1.00 / ub.doc-line.doc-density
        ub.doc-line.fact-density  = ub.doc-line.doc-density
      .
      if v-price-rubl-kg :sensitive in frame {&frame-name} = true
        and v-price-rubl-kg <> 0.0
        and v-price-rubl-kg <> ?
      then do:
        assign
          ub.gds-dtl.price-rubl = v-price-rubl-kg * ub.doc-line.doc-density
          ub.gds-dtl.price-base = v-price-base-kg * ub.doc-line.doc-density
        .
        display
          ub.gds-dtl.price-rubl
          ub.gds-dtl.price-base
          with frame {&FRAME-NAME}.
      end.
      else do:
        assign
          v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.doc-density
          v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.doc-density
        .
        display
          v-price-rubl-kg
          v-price-base-kg
          with frame {&FRAME-NAME}.
      end.
      if v-qnty-kg :sensitive in frame {&frame-name} = true then do:
        display
          input frame {&FRAME-NAME} v-qnty-kg / ub.doc-line.doc-density @ ub.gds-dtl.doc-qnty
          with frame {&FRAME-NAME}.
      end.
      else do:
        display
          input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty * ub.doc-line.doc-density @ v-qnty-kg
          with frame {&FRAME-NAME}.
      end.

      if v-place-rsrv = true
        and not ( last-event :event-type   = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
      then do:
        find first tt-doc-pl
          no-error .
        if available tt-doc-pl then do:
          run edit-doc-pl in this-procedure
            ( input {&autoupdate} + {&delim-par} + "update-dens":U
            ).
        end.
        else do:
          run edit-doc-pl in this-procedure
            ( input {&autoupdate}
            ).
        end.
      end.
    end. /* petrol */
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL doc-line.doc-density d-out-prt
ON RETURN OF doc-line.doc-density IN FRAME d-out-prt /* Плотность */
DO:
  if t-doc.doc-type = {&return} then do:
    if v-price-rubl-kg :sensitive then do:
      apply "ENTRY":U to v-price-rubl-kg in frame {&FRAME-NAME}.
      return no-apply.
    end.
    else do:
      if v-price-base-kg :sensitive then do:
        apply "ENTRY":U to v-price-base-kg in frame {&FRAME-NAME}.
        return no-apply.
      end.
      else do:
        if ub.gds-dtl.price-rubl :sensitive then do:
          apply "ENTRY":U to ub.gds-dtl.price-rubl in frame {&FRAME-NAME}.
          return no-apply.
        end.
        else do:
          if ub.gds-dtl.price-base :sensitive then do:
            apply "ENTRY":U to ub.gds-dtl.price-base in frame {&FRAME-NAME}.
            return no-apply.
          end.
        end.
      end.
    end.
  end.
  else do:
    if v-price-rubl-kg :sensitive
      and ( (input frame {&frame-name} v-price-rubl-kg ) = ?
            or (input frame {&frame-name} v-price-rubl-kg ) = 0.0
          )
    then do:
      apply "ENTRY":U to v-price-rubl-kg in frame {&FRAME-NAME}.
      return no-apply.
    end.
    else do:
      if v-price-base-kg :sensitive
        and ( (input frame {&frame-name} v-price-base-kg ) = ?
              or (input frame {&frame-name} v-price-base-kg ) = 0.0
            )
      then do:
        apply "ENTRY":U to v-price-base-kg in frame {&FRAME-NAME}.
        return no-apply.
      end.
      else do:
        if ub.gds-dtl.price-rubl :sensitive
          and (input frame {&frame-name} ub.gds-dtl.price-rubl ) = ?
        then do:
          apply "ENTRY":U to ub.gds-dtl.price-rubl in frame {&FRAME-NAME}.
          return no-apply.
        end.
        else do:
          if ub.gds-dtl.price-base :sensitive
            and (input frame {&frame-name} ub.gds-dtl.price-base ) = ?
          then do:
            apply "ENTRY":U to ub.gds-dtl.price-base in frame {&FRAME-NAME}.
            return no-apply.
          end.
          else do:
            apply "leave":U to {&self-name} in frame {&FRAME-NAME}.
            apply "CHOOSE":U to b-exit in frame {&FRAME-NAME}.
          end.
        end.
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-dtl.doc-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.doc-qnty d-out-prt
ON ENTRY OF gds-dtl.doc-qnty IN FRAME d-out-prt /* Количество по документу */
DO:
  assign
    v-old-doc-qnty = input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.doc-qnty d-out-prt
ON LEAVE OF gds-dtl.doc-qnty IN FRAME d-out-prt /* Количество по документу */
DO:
  run l-doc-qnty in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.doc-qnty d-out-prt
ON return OF gds-dtl.doc-qnty IN FRAME d-out-prt /* Количество по документу */
DO:

  if t-doc.doc-type = {&return} then do:
    if ub.gds-dtl.price-rubl :sensitive then do:
      apply "ENTRY":U to ub.gds-dtl.price-rubl in frame {&FRAME-NAME}.
      return no-apply.
    end.
    else if ub.gds-dtl.price-base :sensitive then do:
      apply "ENTRY":U to ub.gds-dtl.price-base in frame {&FRAME-NAME}.
      return no-apply.
    end.
  end.
  else do:
    if ub.doc-line.doc-density:sensitive then do:
      apply "entry" to ub.doc-line.doc-density in frame {&frame-name}.
      return no-apply.
    end.
    else do:
      if ub.gds-dtl.price-rubl :sensitive
        and (input frame {&frame-name} ub.gds-dtl.price-rubl ) = ?
      then do:
        apply "ENTRY":U to ub.gds-dtl.price-rubl in frame {&FRAME-NAME}.
        return no-apply.
      end.
      else do:
        if ub.gds-dtl.price-base :sensitive
          and (input frame {&frame-name} ub.gds-dtl.price-base ) = ?
        then do:
          apply "ENTRY":U to ub.gds-dtl.price-base in frame {&FRAME-NAME}.
          return no-apply.
        end.
        else do:
          apply "leave":U to {&self-name} in frame {&FRAME-NAME}.
          apply "CHOOSE":U to b-exit in frame {&FRAME-NAME}.
        end.
      end.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-dtl.fact-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.fact-qnty d-out-prt
ON ENTRY OF gds-dtl.fact-qnty IN FRAME d-out-prt /* Фактическое количество */
DO:
  assign
    v-old-fact-qnty = input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.fact-qnty d-out-prt
ON LEAVE OF gds-dtl.fact-qnty IN FRAME d-out-prt /* Фактическое количество */
DO:
  run l-fact-qnty in this-procedure no-error .
  if error-status :error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.fact-qnty d-out-prt
ON RETURN OF gds-dtl.fact-qnty IN FRAME d-out-prt /* Фактическое количество */
DO:
  apply "leave":U to {&self-name} in frame {&FRAME-NAME}.
  if error-status :error then do:
    return no-apply.
  end.
  apply "CHOOSE":U to b-exit in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME g-image
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL g-image d-out-prt
ON mouse-select-dblclick OF g-image IN FRAME d-out-prt
DO:
   DEFINE VARIABLE v-main-code LIKE ub.bar-code.b-code NO-UNDO.
    IF AVAILABLE buf_goods THEN
    DO:
        { gbl/gdsbcode.i buf_goods.gds-code ? v-main-code }
        RUN ref/imagelist.w (ParParentProc, "":U, v-main-code, {&lookup}).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-dtl.new-price-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.new-price-sale d-out-prt
ON LEAVE OF gds-dtl.new-price-sale IN FRAME d-out-prt /* Новая цена продажи */
DO:

  if input frame {&frame-name} ub.gds-dtl.new-price-sale   <>  ub.gds-dtl.new-price-sale  then do:
      run lineattr-write in this-procedure (
          t-doc.doc-code ,
          buf_goods.gds-code ,
          {&lineattr-corr-price-sale},
          string(ub.gds-dtl.new-price-sale)
          ).
      ub.gds-dtl.price-corr = 1.
     display b-corr-price-sale with frame {&frame-name} .
     assign ub.gds-dtl.new-price-sale .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-dtl.price-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.price-base d-out-prt
ON LEAVE OF gds-dtl.price-base IN FRAME d-out-prt /* Цена */
DO:

  if input frame {&FRAME-NAME} ub.gds-dtl.price-base > 5000
    and base-code = 1
  then do:
    message
      "Внимание !!!" skip( 2 )
      "ВАЛЮТНАЯ цена превышает 5,000 !" skip( 2 )
      {&tabulation} "Вы не ошиблись ?"
      view-as alert-box warning title " В Н И М А Н И Е  ! ! ! ".
  end.
  if ub.gds-dtl.price-base <> input frame {&FRAME-NAME} ub.gds-dtl.price-base then do:
    assign
      ub.gds-dtl.price-base
    .
    assign
      ub.gds-dtl.ov = yes
      ub.gds-dtl.price-rubl = ub.gds-dtl.price-base * t-doc.base-rate / t-doc.base-scale
      tot-rubl = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
      tot-base = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
    .
    display
      ub.gds-dtl.price-rubl
      tot-rubl
      tot-base
      with frame {&frame-name}.
    if is-petrolium = true
      and is-pieces = false
      and { str/valddnst.i chk ub.doc-line.doc-density "buf_goods.unit-base = buf_goods.unit-cli" } = true
    then do:
      assign
        v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.fact-density
        v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.fact-density
      .
      display
        v-price-rubl-kg
        v-price-base-kg
      with frame {&FRAME-NAME}.
    end.
  end.
  run re-calcpr in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-dtl.price-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-dtl.price-rubl d-out-prt
ON LEAVE OF gds-dtl.price-rubl IN FRAME d-out-prt /* Цена */
DO:

  if ub.gds-dtl.price-rubl <> input frame {&FRAME-NAME} ub.gds-dtl.price-rubl then do:
    assign
      ub.gds-dtl.price-rubl
      .
    assign
      ub.gds-dtl.ov         = yes
      ub.gds-dtl.price-base = ub.gds-dtl.price-rubl / t-doc.base-rate * t-doc.base-scale
    .
    assign
      tot-rubl = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
      tot-base = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
    .
    display
      ub.gds-dtl.price-base
      tot-rubl
      tot-base
      with frame {&frame-name}.

    if is-petrolium = true
      and is-pieces = false
      and { str/valddnst.i chk ub.doc-line.doc-density "buf_goods.unit-base = buf_goods.unit-cli" } = true
    then do:
      assign
        v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.fact-density
        v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.fact-density
      .
      display
        v-price-rubl-kg
        v-price-base-kg
        with frame {&FRAME-NAME}.
    end.
  end. /* ub.gds-dtl.price-rubl <> input frame {&FRAME-NAME} ub.gds-dtl.price-rubl */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-price d-out-prt
ON CHOOSE OF r-price IN FRAME d-out-prt
DO:
  run ch-price in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME doc-line.temperature
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL doc-line.temperature d-out-prt
ON LEAVE OF doc-line.temperature IN FRAME d-out-prt /* Температура */
DO:
    assign
    ub.doc-line.temperature
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-fact-qnty-kg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-fact-qnty-kg d-out-prt
ON ENTRY OF v-fact-qnty-kg IN FRAME d-out-prt /* Факт,кг */
DO:
  assign
    v-old-fact-cli-qnty = input frame {&FRAME-NAME} v-fact-qnty-kg
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-fact-qnty-kg d-out-prt
ON LEAVE OF v-fact-qnty-kg IN FRAME d-out-prt /* Факт,кг */
DO:
  if ( lookup( t-doc.doc-type, {&income_return} ) > 0 and t-doc.internal
    and ( ub.gds-prt.upper-code = buf_goods.prt-root /* выключены шкалы на тек. объекте */ or
    can-find( out-dtl no-lock where out-dtl.doc-code  = t-doc.out-code    and
                                    out-dtl.artic     = ub.gds-dtl.artic     and
                                    out-dtl.prod-type = ub.gds-dtl.prod-type and
                                    out-dtl.prod-code = ub.gds-dtl.prod-code and
                                    out-dtl.prt-code  = ub.gds-dtl.prt-code  ) ) /* включены и на объекте-источнике */
    or not lookup( t-doc.doc-type, {&income_return} ) > 0
    or ( t-doc.doc-type = {&return} and not t-doc.internal ) )
    and round (input frame {&FRAME-NAME} v-fact-qnty-kg / ub.doc-line.fact-density, 1) > round(ub.gds-dtl.doc-qnty, 1)
  then do:
    message "Фактическое количество товара не может быть больше количества по накладной." view-as alert-box.
    apply "ENTRY":U to v-fact-qnty-kg in frame {&FRAME-NAME}.
    return no-apply.
  end.
  if v-old-fact-cli-qnty <> input frame {&FRAME-NAME} v-fact-qnty-kg then do:

      if is-petrolium = yes
      and is-pieces = no
      and { str/valddnst.i chk ub.doc-line.fact-density "buf_goods.unit-base = buf_goods.unit-cli" } = yes
    then do:
      display
        input frame {&FRAME-NAME} v-fact-qnty-kg / ub.doc-line.fact-density @ ub.gds-dtl.fact-qnty
      with frame {&FRAME-NAME}.
    end. /* petrol */

    if v-place-rsrv = true
      and not ( last-event :event-type = "progress":u
                and last-event :widget-enter = b-place :handle
              )
    then do:
      run edit-doc-pl in this-procedure
        ( input {&autoupdate}
        ).
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-fact-qnty-kg d-out-prt
ON RETURN OF v-fact-qnty-kg IN FRAME d-out-prt /* Факт,кг */
DO:
  apply "leave":U to {&self-name} in frame {&FRAME-NAME}.
  apply "CHOOSE":U to b-exit in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-price-base-kg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-price-base-kg d-out-prt
ON LEAVE OF v-price-base-kg IN FRAME d-out-prt
DO:

  if input frame {&FRAME-NAME} v-price-base-kg > 5000 and base-code = 1 then do:
    message "Внимание !!!" skip( 2 )
            "ВАЛЮТНАЯ цена превышает 5,000 !" skip( 2 )
            {&tabulation} "Вы не ошиблись ?"
    view-as alert-box warning title " В Н И М А Н И Е  ! ! ! ".
  end.
  if v-price-base-kg <> input frame {&FRAME-NAME} v-price-base-kg then do:
    assign
      v-price-rubl-kg
    .
    assign
      ub.gds-dtl.ov   = yes
      v-price-rubl-kg = v-price-base-kg * t-doc.base-rate / t-doc.base-scale
    .
    display
      v-price-rubl-kg
      v-price-base-kg
      with frame {&FRAME-NAME}.
    if { str/valddnst.i chk ub.doc-line.fact-density "buf_goods.unit-base = buf_goods.unit-cli" } = yes then do:
      assign
        ub.gds-dtl.price-rubl = v-price-rubl-kg * ub.doc-line.fact-density
        ub.gds-dtl.price-base = v-price-base-kg * ub.doc-line.fact-density
        tot-rubl = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
        tot-base = ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
      .
      display
        ub.gds-dtl.price-rubl
        ub.gds-dtl.price-base
        tot-rubl
        tot-base
        with frame {&FRAME-NAME}.
    end. /* density */
  end. /* v-price-base-kg <> input frame {&FRAME-NAME} v-price-base-kg */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-price-rubl-kg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-price-rubl-kg d-out-prt
ON LEAVE OF v-price-rubl-kg IN FRAME d-out-prt /* Цена,кг */
DO:
    define variable chg-price-rubl as logical no-undo.

  if v-price-rubl-kg <> input frame {&FRAME-NAME} v-price-rubl-kg then do:
    assign
      v-price-rubl-kg
    .
    assign
      ub.gds-dtl.ov   = yes
      v-price-base-kg = v-price-rubl-kg / t-doc.base-rate * t-doc.base-scale
    .
    display
      v-price-rubl-kg
      v-price-base-kg
      with frame {&FRAME-NAME}.
    if { str/valddnst.i chk ub.doc-line.fact-density "buf_goods.unit-base = buf_goods.unit-cli" } = yes then do:
      assign
        ub.gds-dtl.price-rubl = v-price-rubl-kg * ub.doc-line.fact-density
        ub.gds-dtl.price-base = v-price-base-kg * ub.doc-line.fact-density
        tot-rubl = input frame {&frame-name} ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
        tot-base = input frame {&frame-name} ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
      .
      display
        ub.gds-dtl.price-rubl
        ub.gds-dtl.price-base
        tot-rubl
        tot-base
        with frame {&FRAME-NAME}.
    end. /* density */
  end. /* v-price-rubl-kg <> input frame {&FRAME-NAME} v-price-rubl-kg */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-qnty-kg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-qnty-kg d-out-prt
ON ENTRY OF v-qnty-kg IN FRAME d-out-prt /* По док,кг */
DO:
  assign
    v-old-doc-cli-qnty = input frame {&FRAME-NAME} v-qnty-kg
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-qnty-kg d-out-prt
ON LEAVE OF v-qnty-kg IN FRAME d-out-prt /* По док,кг */
DO:
  define variable varprt-obj_free-qnty like ub.prt-obj.free-qnty no-undo.

  if v-old-doc-cli-qnty <> input frame {&FRAME-NAME} v-qnty-kg then do:

    if { str/valddnst.i chk ub.doc-line.doc-density "buf_goods.unit-base = buf_goods.unit-cli" } = yes then do:
      if ( v-price-rubl-kg       =  ? or  v-price-rubl-kg       =  0 ) and
        ( ub.gds-dtl.price-rubl <> ? and ub.gds-dtl.price-rubl <> 0 ) then do:
        assign
          v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.doc-density
        .
        display v-price-rubl-kg with frame {&FRAME-NAME}.
      end.
      else do:
        assign
          ub.gds-dtl.price-rubl = v-price-rubl-kg * ub.doc-line.doc-density
        .
        display ub.gds-dtl.price-rubl with frame {&FRAME-NAME}.
      end.
      if ( v-price-base-kg       =  ? or  v-price-base-kg       =  0 ) and
        ( ub.gds-dtl.price-base <> ? and ub.gds-dtl.price-base <> 0 ) then do:
        assign
          v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.doc-density
        .
        display v-price-base-kg with frame {&FRAME-NAME}.
      end.
      else do:
        assign
          ub.gds-dtl.price-base = v-price-base-kg * ub.doc-line.doc-density
        .
        display ub.gds-dtl.price-rubl with frame {&FRAME-NAME}.
      end.
      if input frame {&FRAME-NAME} v-qnty-kg <> ? and input frame {&FRAME-NAME} v-qnty-kg <> 0 then do:
        display input frame {&FRAME-NAME} v-qnty-kg / ub.doc-line.doc-density @ ub.gds-dtl.doc-qnty with frame {&FRAME-NAME}.
      end.
    end. /* density */

    if ( is-petrolium = yes
        and is-pieces = no
        and { str/valddnst.i chk ub.doc-line.doc-density "buf_goods.unit-base = buf_goods.unit-cli" } = yes
      )
      or not ( is-petrolium = yes
                and is-pieces = no
              )
    then do:
      if v-place-rsrv = true
        and not ( last-event :event-type = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
      then do:
        run edit-doc-pl in this-procedure
          ( input {&autoupdate}
          ).
      end.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-qnty-kg d-out-prt
ON RETURN OF v-qnty-kg IN FRAME d-out-prt /* По док,кг */
DO:
  if t-doc.doc-type = {&return} then do:
    if v-price-rubl-kg :sensitive then do:
      apply "ENTRY":U to v-price-rubl-kg in frame {&FRAME-NAME}.
      return no-apply.
    end.
    else do:
      if v-price-base-kg :sensitive then do:
        apply "ENTRY":U to v-price-base-kg in frame {&FRAME-NAME}.
        return no-apply.
      end.
    end.
  end.
  else do:
    if ub.doc-line.doc-density :sensitive then do:
      apply "entry" to ub.doc-line.doc-density in frame {&frame-name}.
      return no-apply.
    end.
    else do:
      if v-price-rubl-kg :sensitive
        and (input frame {&frame-name} v-price-rubl-kg ) = ?
      then do:
        apply "ENTRY":U to v-price-rubl-kg in frame {&FRAME-NAME}.
        return no-apply.
      end.
      else do:
        if v-price-base-kg :sensitive
          and (input frame {&frame-name} v-price-base-kg ) = ?
        then do:
          apply "ENTRY":U to v-price-base-kg in frame {&FRAME-NAME}.
          return no-apply.
        end.
        else do:
          apply "leave":U to {&self-name} in frame {&FRAME-NAME}.
          apply "CHOOSE":U to b-exit in frame {&FRAME-NAME}.
        end.
      end.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-out-prt 


/* ***************************  Main Block  *************************** */
 /* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent. */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
/* Restore the current-window if it is an icon. Otherwise the dialog box will be hidden */
IF CURRENT-WINDOW :WINDOW-STATE = WINDOW-MINIMIZED THEN DO: CURRENT-WINDOW :WINDOW-STATE = WINDOW-NORMAL. END.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

define menu m-rvs-af
    menu-item m-rvs-af-1 label "Сверка резервуара"  accelerator "alt-1"
    menu-item m-rvs-af-2 label "Просмотр"           accelerator "alt-2"
    menu-item m-rvs-af-3 label "Редактирование"     accelerator "alt-3".

define menu m-rvs-bf
    menu-item m-rvs-bf-1 label "Сверка резервуара"  accelerator "alt-1"
    menu-item m-rvs-bf-2 label "Просмотр"           accelerator "alt-2"
    menu-item m-rvs-bf-3 label "Редактирование"     accelerator "alt-3".

on choose of menu-item m-rvs-bf-1 in menu m-rvs-bf
do:
  { gbl/stdbtn.i b-rvs-bf }

  run action-rvs-line in this-procedure
    ( input {&update}
     ,input "meas":U
     ,input {&rvs-before-doc}
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.

end.

on choose of menu-item m-rvs-af-1 in menu m-rvs-af
do:
  { gbl/stdbtn.i b-rvs-af }

  run action-rvs-line in this-procedure
    ( input {&update}
     ,input "meas":U
     ,input {&rvs-after-doc}
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.

end.


on choose of menu-item m-rvs-bf-2 in menu m-rvs-bf
or choose of b-rvs-bf in frame {&frame-name}
do:
  { gbl/stdbtn.i b-rvs-bf }

  run action-rvs-line in this-procedure
    ( input {&lookup}
     ,input "edit":U
     ,input {&rvs-before-doc}
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.

end.

on choose of menu-item m-rvs-af-2 in menu m-rvs-af
or choose of b-rvs-af in frame {&frame-name}
do:
  { gbl/stdbtn.i b-rvs-af }

  run action-rvs-line in this-procedure
    ( input {&lookup}
     ,input "edit":U
     ,input {&rvs-after-doc}
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.

end.

on choose of menu-item m-rvs-bf-3 in menu m-rvs-bf
do:
  { gbl/stdbtn.i b-rvs-bf }

  run action-rvs-line in this-procedure
    ( input {&update}
     ,input "edit":U
     ,input {&rvs-before-doc}
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.

end.

on choose of menu-item m-rvs-af-3 in menu m-rvs-af
do:
  { gbl/stdbtn.i b-rvs-af }

  run action-rvs-line in this-procedure
    ( input {&update}
     ,input "edit":U
     ,input {&rvs-after-doc}
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.

end.


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :

  define buffer buf_doc-pl   for ub.doc-pl.
  define buffer buf_currency for ub.currency  .
  define buffer buf_doc-pl-attr for ub.doc-pl-attr .
  define buffer buf_contract    for ub.contract.

  define variable vGtin     as character no-undo.
  define variable vGtinQnty as integer no-undo.
  define variable vExistGdsDtl as logical no-undo init true. /* признак, что gds-dtl уже есть */
  
  if num-entries(prt-mode, {&delim-par}) = 2
  then do :
    if entry(2, prt-mode, {&delim-par}) begins "return"
    then do :
      v-is-return = true .
      in-part-rec = integer(trim(entry(2, prt-mode, {&delim-par}), "return=")) no-error .
    end .
    prt-mode = entry(1, prt-mode, {&delim-par}) .
  end .

  assign
    v-undo-all = false
    TEXT-1 = "{&abbr_rub_allshift}"
  .
  display TEXT-1 with frame {&frame-name} .

  find first t-doc no-lock
    where recid(t-doc) = doc-rec
    .
  if v-is-return then
  do:
    for first buf_contract no-lock where
              buf_contract.host-code     = t-doc.host-code
          and buf_contract.contract-code = t-doc.contract-code
    :
      vBackSale = (buf_contract.spec-check = 23). /* Возврат по "Обратной продаже" */
    end.
  end.
    
  find first ub.gds-prt no-lock
    where recid( ub.gds-prt ) = cur-rec
    .
  if prt-mode = {&prt-def}
    and node-type <> {&g#term}
  then do:
    message
      "В режиме ШКАЛА можно указывать количества только по терминальным признакам."
      view-as alert-box.
    undo main-block, return error.
  end.

  { gbl/getcntxt.i  get }
  { gbl/hostname.i
    t-doc.obj-type
    t-doc.obj-code
    g#host-code
    g#host-name
  }
  { gbl/basecode.i
    g#host-code
    base-code
  }
  find first buf_currency no-lock
    where buf_currency.curr-code = base-code
    no-error.
  if available buf_currency then do:
    assign
      base-type = buf_currency.curr-abbr
    .
  end.

{ gbl/conf-rd.i "'ptoldfil'" t-doc.host-code t-doc.obj-type t-doc.obj-code "''" "''" "''" no ptoldfilvalue ptoldfiltype no-error }

  pr-genmrg   =  "" .
  pr-naklvalue = false  .

if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then do:

/* Получим из секции переоценок нужные переменные */

{ gbl/gtplmrgn.i
  parparentproc
  t-doc.obj-type
  t-doc.obj-code
  par-1
  pr-genmrg
  par-1
  no-error }

{ gbl/gtplpnakl.i
  parparentproc
  t-doc.obj-type
  t-doc.obj-code
  par-0
  pr-naklvalue
  par-0
  no-error }

end.

  assign
    stfactplvalue    = "":U
    varupd-fact-qnty = false
  .

  if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then do:

     varupd-fact-qnty = true .
     if t-doc.status_ =  {&inquiry} then do:
        assign
          v-work-with-qnty = "doc":U
         .
     end.
     else do:
        assign
          v-work-with-qnty = "fact-doc":U
        .
     end.
  end.
  else do:
    if t-doc.status_ <> {&fact}
      and t-doc.status_ <> {&permitted}
      and t-doc.flag_ = false
    then do:
      assign
        v-work-with-qnty = "doc":U
      .
    end.
    else do:
      assign
        v-work-with-qnty = "fact":U
      .
      if t-doc.ext-doc-type <> {&TDEDT_Vozvrat_Perem} then do:
        assign
          varupd-fact-qnty = true
        .
      end.
    end.
  end.

  find buf_goods   no-lock
    where recid( buf_goods ) = gds-rec
    .
  find ub.clients no-lock
    where ub.clients.obj-code = buf_goods.prod-code
      and ub.clients.obj-type = buf_goods.prod-type
    .
  find ub.prt-obj no-lock
    where ub.prt-obj.prt-code  = ub.gds-prt.node-code
      and ub.prt-obj.prod-code = buf_goods.prod-code
      and ub.prt-obj.prod-type = buf_goods.prod-type
      and ub.prt-obj.artic     = buf_goods.artic
      and ub.prt-obj.obj-code  = t-doc.obj-code
      and ub.prt-obj.obj-type  = t-doc.obj-type
    no-error.

  if prt-mode = {&lookup} then do:
    find ub.doc-line no-lock
      where recid( ub.doc-line ) = line-rec
      .
    find ub.gds-dtl  no-lock
      where ub.gds-dtl.prt-code  = ub.gds-prt.node-code
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.artic     = ub.doc-line.artic
        and ub.gds-dtl.doc-code  = t-doc.doc-code
      no-error.
    find ub.inv-line no-lock
      where ub.inv-line.doc-code  = t-doc.doc-code
        and ub.inv-line.artic     = ub.doc-line.artic
        and ub.inv-line.prod-code = ub.doc-line.prod-code
        and ub.inv-line.prod-type = ub.doc-line.prod-type
      no-error.
  end. /* prt-mode = {&lookup} */
  else do: /* prt-mode <> {&lookup} */
    find first t-doc
      where recid(t-doc) = doc-rec
      .
    find ub.doc-line exclusive-lock
      where recid( ub.doc-line ) = line-rec
      .
    find ub.gds-dtl  exclusive-lock
      where ub.gds-dtl.prt-code  = ub.gds-prt.node-code
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.artic     = ub.doc-line.artic
        and ub.gds-dtl.doc-code  = t-doc.doc-code
      no-error.
    find ub.inv-line exclusive-lock
      where ub.inv-line.doc-code  = ub.doc-line.doc-code
        and ub.inv-line.artic     = ub.doc-line.artic
        and ub.inv-line.prod-code = ub.doc-line.prod-code
        and ub.inv-line.prod-type = ub.doc-line.prod-type
      no-error.
  end. /* prt-mode <> {&lookup} */

  assign
    r-recid-petrol-kg = ( if available ub.inv-line then recid( ub.inv-line ) else ? )
  .

  { gbl/hold-doc.i
    t-doc.doc-code
    v-hold-doc
  }

  { gbl/gdsobjat.i
    t-doc.obj-type
    t-doc.obj-code
    buf_goods.artic
    buf_goods.prod-type
    buf_goods.prod-code
    "'place-rsrv=request'"
    v-place-rsrv
    no-error
  }
  if error-status :error then do:
    undo main-block, return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.

  if not available ub.gds-dtl then do:
    vExistGdsDtl = false.
    if ( lookup( t-doc.doc-type, {&income_return} ) > 0
      and t-doc.internal
      and ( ub.gds-prt.upper-code = buf_goods.prt-root /* выключены шкалы на тек. объекте */ or
        can-find( out-dtl no-lock where out-dtl.doc-code  = t-doc.out-code       and
                                        out-dtl.artic     = ub.gds-dtl.artic     and
                                        out-dtl.prod-type = ub.gds-dtl.prod-type and
                                        out-dtl.prod-code = ub.gds-dtl.prod-code and
                                        out-dtl.prt-code  = ub.gds-dtl.prt-code  ) ) /* включены и на объекте-источнике */
      or lookup( t-doc.doc-type, {&income_return} ) = 0 )
      and ( t-doc.flag_ or t-doc.status_ = {&permitted} ) or
      prt-mode = {&lookup}
    then do:
      /* 1. на внутреннем приходе-возврате при перемещении с объекта без признаков
            на объект с признаками требуется пересортица
          2. расход-списание
          3. просмотр */
      message "Товара с таким признаком нет в данной накладной." view-as alert-box.
      undo main-block, return error.
    end.
    { str/crgdsdtl.i
      t-doc.obj-code
      t-doc.obj-type
      t-doc.doc-code
      ub.doc-line.artic
      ub.doc-line.prod-code
      ub.doc-line.prod-type
      ub.gds-prt.node-code
      yes
      no-error
    }
    if error-status :error then do:
      message
        "Ошибка при создании признака." skip
        return-value
        view-as alert-box error.
      undo main-block, return error.
    end.
    assign
      add-def-mode = true
    .
    find first ub.gds-dtl
      where ub.gds-dtl.doc-code  = t-doc.doc-code
        and ub.gds-dtl.artic     = ub.doc-line.artic
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.prt-code  = ub.gds-prt.node-code
      .
    assign
      ub.gds-dtl.price-base  = ?
      ub.gds-dtl.price-rubl  = ?
      v-price-base-kg        = ?
      v-price-rubl-kg        = ?
      ub.gds-dtl.discnt-type = yes /* процент */
      ub.gds-dtl.discnt-base = 0
      ub.gds-dtl.discnt-rubl = 0
      ub.gds-dtl.discnt-pc   = 0
    .
    if t-doc.doc-type = {&income} and prt-mode = {&prt-def} and not t-doc.internal then do:
      /* внеш ПН - цена из ub.doc-line и остаток количества */
      assign
        ub.gds-dtl.price-base = ub.doc-line.price-base
        ub.gds-dtl.price-rubl = ub.doc-line.price-rubl
      .
      for each g-d-b where g-d-b.prod-code = ub.doc-line.prod-code
                       and g-d-b.prod-type = ub.doc-line.prod-type
                       and g-d-b.artic     = ub.doc-line.artic
                       and g-d-b.doc-code  = ub.doc-line.doc-code :
        accumulate g-d-b.doc-qnty  ( total )
                   g-d-b.fact-qnty ( total ) .
      end.
      if v-work-with-qnty = "doc":U then do:
        if ub.doc-line.doc-qnty - ( accum total g-d-b.doc-qnty ) > 0 then do:
          display
            ub.doc-line.doc-qnty - ( accum total g-d-b.doc-qnty ) @ ub.gds-dtl.doc-qnty
          with frame {&FRAME-NAME}.
        end.
        else do:
          display
            0 @ ub.gds-dtl.doc-qnty
          with frame {&FRAME-NAME}.
        end.
      end.
      else do:
        if ub.doc-line.fact-qnty - ( accum total g-d-b.fact-qnty ) > 0 then do:
          display
            ub.doc-line.fact-qnty - ( accum total g-d-b.fact-qnty ) @ ub.gds-dtl.fact-qnty
          with frame {&FRAME-NAME}.
        end.
        else do:
          display
            0 @ ub.gds-dtl.fact-qnty
          with frame {&FRAME-NAME}.
        end.
      end.
    end.
    if lookup( t-doc.doc-type, {&income_return} ) > 0 and prt-mode = {&prt-def} and t-doc.internal then do:
      /* подставить цену из РН (в ПН) или ПН (в ВН) - она равна цене в первом признаке,
        исходного док-та в этой БД может и не быть */

      find first g-d-b no-lock where g-d-b.doc-code  = ub.doc-line.doc-code
                                 and g-d-b.prod-type = ub.doc-line.prod-type
                                 and g-d-b.prod-code = ub.doc-line.prod-code
                                 and g-d-b.artic     = ub.doc-line.artic
                                 and g-d-b.prt-code  <> ub.gds-prt.node-code no-error.
      if available g-d-b then do:
        assign
          ub.gds-dtl.price-base = g-d-b.price-base
          ub.gds-dtl.price-rubl = g-d-b.price-rubl
        .
      end.
    end.
  end.  /* not available ub.gds-dtl */
  if prt-mode <> {&lookup} then do:
    { str/set-pr.i recid(ub.gds-dtl) no ub.gds-dtl.doc-qnty no-error }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "333"
        view-as alert-box error
      .
      undo main-block, return error return-value.
    end.
    find ub.gds-prt no-lock where recid( ub.gds-prt ) = cur-rec.
  end.
  
  if v-is-return and in-part-rec > 0 
  and (not vExistGdsDtl or not vBackSale) /* BTS-2021 - для возврата по Обратной продаже, что открываем уже 
                                             существующую запись и тогда цену НЕ берем из партии */
  then do :
    find first in_parts no-lock where recid(in_parts) = in-part-rec no-error .
    if available in_parts
    then do :
      assign
        ub.gds-dtl.price-base = in_parts.price-base
        ub.gds-dtl.price-rubl = in_parts.price-rubl
        ub.gds-dtl.ov         = yes
      . 
    end .                                
  end.

  assign
    frame {&FRAME-NAME} :title = "Документ №  " + t-doc.doc-code + "    " +  {&row} + "     " + prt-mode
  .
  assign
    base-curr = base-type
  .

  if v-place-rsrv = yes then do:
    { str/is-petrl.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      is-petrolium
      is-pieces
      no-error
    }
    if error-status :error then do:
      assign
        is-petrolium = no
        is-pieces    = no
      .
    end.

    if is-petrolium = true
      and is-pieces = false
    then do:
      if /* t-doc.internal = true
        or */ v-hold-doc = true
      then do:
        message
          substitute( "Товар (код &1) топливный!", buf_goods.gds-code ) skip
          "Поэтому не может участвовать в межфирменном перемещении!" skip
          view-as alert-box.
        undo main-block, return error.
      end.
      run gds-attr-value in this-procedure
        ( input  buf_goods.gds-code
          ,input  {&attr-ptrl-without-rvs}
          ,output v-ptrl-without-rvs
          ,output v-attr-type
        ) .
      run gds-attr-value in this-procedure
        ( input  buf_goods.gds-code
          ,input  {&attr-gds-ptrl-densities}
          ,output v-gds-ptrl-densities
          ,output v-attr-type
        ) .
        if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
            assign
              v-min-dens = decimal(replace(entry(1, v-gds-ptrl-densities, "-":U ), "кг\л", "":U))
              v-max-dens = decimal(replace(entry(2, v-gds-ptrl-densities, "-":U ), "кг\л":U, "":U))
            no-error .
        end.
      { gbl/ptrlprop.i run t-doc.obj-type t-doc.obj-code }

      if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then do:
/*    пока не разрешаем изменение фактического кол-ва и плотности во внутреннем приходе*/
/*    { gbl/conf-rd.i "'stfactpl'" 0 "''" 0 "''" "''" "''" no  stfactplvalue stfactpltype no-error }*/

            assign
              varupd-fact-qnty = false
            .
      end.

      assign
        ub.gds-dtl.price-rubl :label in frame {&frame-name} = substitute("Цена,&1", buf_goods.unit-base )
        v-price-rubl-kg       :label in frame {&frame-name} = substitute("Цена,&1", buf_goods.unit-cli )
        ub.gds-dtl.doc-qnty   :label in frame {&frame-name} = substitute("По док,&1", buf_goods.unit-base )
        ub.gds-dtl.fact-qnty  :label in frame {&frame-name} = substitute("Факт,&1", buf_goods.unit-base )
        v-qnty-kg             :label in frame {&frame-name} = substitute("По док,&1", buf_goods.unit-cli )
        v-fact-qnty-kg        :label in frame {&frame-name} = substitute("Факт,&1", buf_goods.unit-cli )
      .
      if t-doc.status_ <> {&fact}
        and prt-mode <> {&lookup}
      then do:
        assign
          b-rvs-bf:popup-menu in frame {&frame-name} = menu m-rvs-bf:handle
          b-rvs-bf:menu-mouse = 1
          b-rvs-af:popup-menu in frame {&frame-name} = menu m-rvs-af:handle
          b-rvs-af:menu-mouse = 1
        .
      end.

      run str/in-laddout.w
        ( input        parParentProc
         ,input        "get-attr":U
         ,input        t-doc.doc-code
         ,input        buf_goods.gds-code
         ,input-output v-prt-car-num
         ,input-output v-prt-car-vol
         ,input-output v-prt-tests
         ,input-output v-prt-autoent-obj-type
         ,input-output v-prt-autoent-obj-code
         ,input-output v-prt-item-pour
         ,input-output v-prt-time-pour
         ,input-output v-prt-tank-vol
         ,input-output v-prt-tank-temp
         ,input-output v-prt-tank-water
         ,input-output v-prt-tank-density
         ,input-output v-prt-tank-weight
         ,input-output v-prt-time-income
         ,input-output v-prt-start-real-date
         ,input-output v-prt-start-real-time
         ,input-output v-prt-end-real-date
         ,input-output v-prt-end-real-time
         ,input-output v-prt-mouth
         ,input-output v-prt-fio
         ,input-output v-prt-ptbotype
         ,input-output v-prt-ptbocode
         ,input-output v-prt-a-b-tarir
         ,input-output v-diameter
         ,input-output v-place-si
         ,input-output v-tank-density-pomi
         ,input-output v-prt-certif-fuel 
         ,input-output v-prt-norm-doc 
         ,input-output v-prt-num-passport 
         ,input-output v-prt-validity-certif
         ,input-output v-prt-passport-plotn
         ,input-output v-prt-num-plotn             
         ,input-output v-prt-date-pov-plotn   
         ,      output was_setting
        ) .

      if stfactplvalue <> "":U then do:
        { str/chkqtpl.i
          stfactplvalue
          varupd-fact-qnty
          varrevision
          varpercrev
          varauto-tank
          varpercauto
          varinv
          varpercinv
          varinv-set
          no-error
        }
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Разборе строки параметра stfactpl" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return error .
        end.
      end.
    end.
    else do:
      assign
        ptrlprop-expptrl = ?
      .
    end.


    for each tt-doc-pl
    on error undo main-block, return error error-status :get-message(1)
    :
      delete tt-doc-pl .
    end.
    for each buf_doc-pl no-lock
      where buf_doc-pl.obj-type = t-doc.obj-type
        and buf_doc-pl.obj-code = t-doc.obj-code
        and buf_doc-pl.out-code = t-doc.doc-code
        and buf_doc-pl.gds-code = buf_goods.gds-code
    on error undo main-block, return error error-status :get-message(1)
    :
      create tt-doc-pl .
      buffer-copy buf_doc-pl to tt-doc-pl .
      if t-doc.ext-doc-type = {&TDEDT_Ras_Object}
      then 
      for first buf_doc-pl-attr no-lock
          where buf_doc-pl-attr.obj-type    = buf_doc-pl.obj-type
            and buf_doc-pl-attr.obj-code    = buf_doc-pl.obj-code
            and buf_doc-pl-attr.pl-code     = buf_doc-pl.pl-code
            and buf_doc-pl-attr.out-code    = buf_doc-pl.out-code            
            and buf_doc-pl-attr.gds-code    = buf_doc-pl.gds-code
            and buf_doc-pl-attr.attr-code   = 'place2' :
           assign tt-doc-pl.pl-code2 = integer(buf_doc-pl-attr.attr-value) .
      end.
      if t-doc.ext-doc-type = {&TDEDT_Pri_Object}
      then
      for first buf_doc-pl-attr no-lock
          where buf_doc-pl-attr.obj-type    = buf_doc-pl.obj-type
            and buf_doc-pl-attr.obj-code    = buf_doc-pl.obj-code
            and buf_doc-pl-attr.attr-value  = string(buf_doc-pl.pl-code)
            and buf_doc-pl-attr.out-code    = (replace(buf_doc-pl.out-code, '=', '-'))            
            and buf_doc-pl-attr.gds-code    = buf_doc-pl.gds-code
            and buf_doc-pl-attr.attr-code   = 'place2' :
          assign tt-doc-pl.pl-code2 = buf_doc-pl-attr.pl-code .
      end.
    end.

    find first tt-doc-pl no-lock
      no-error.
    if not available tt-doc-pl
      and add-def-mode <> true
    then do:
      message
        substitute( "Товар &1", buf_goods.gds-code ) skip
        "не распределен по местам хранения."
        view-as alert-box.
    end.
  end.

  IF mImagePh THEN
  DO:
    IF AVAILABLE buf_goods THEN
    DO:
        DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
        DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
        RUN gds-attr-value (buf_goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
        RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, INPUT buf_goods.gds-code,OUTPUT vImageList).
        vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
    END.
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
  END.
  ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
  if t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} then run init-temp in this-procedure no-error .
  run UI-on in this-procedure
    no-error .
  if error-status :error then do:
    undo main-block, return error return-value.
  end.

  if v-place-rsrv = yes then do:
    enable
      b-place
      with frame {&frame-name}
    .
  end.
  else do:
    hide
      b-place
      in frame {&frame-name}
    .
  end.
  
  if node-type begins "scan-marks" then
    vScanMark = entry(2,node-type,{&delim-key}).

  if prt-mode = {&lookup} then do:
    if not is-petrolium then do:
      if ub.gds-dtl.fact-qnty:hidden = false
      then do:
        display
          v-fact-qnty-kg
        with frame {&FRAME-NAME}.
      end.
      display
        v-qnty-kg
      with frame {&FRAME-NAME}.
                
      v-qnty-kg             = ub.gds-dtl.doc-qnty / buf_goods.cli-base-rate.
      v-fact-qnty-kg        = ub.gds-dtl.fact-qnty / buf_goods.cli-base-rate.
      v-qnty-kg:screen-value = string (v-qnty-kg).
      v-fact-qnty-kg:screen-value = string (v-fact-qnty-kg).
      assign
        ub.gds-dtl.price-rubl :label in frame {&frame-name} = substitute("Цена,&1", buf_goods.unit-base )
        v-price-rubl-kg       :label in frame {&frame-name} = substitute("Цена,&1", buf_goods.unit-cli )
        ub.gds-dtl.doc-qnty   :label in frame {&frame-name} = substitute("По док,&1", buf_goods.unit-base )
        ub.gds-dtl.fact-qnty  :label in frame {&frame-name} = substitute("Факт,&1", buf_goods.unit-base )
        v-qnty-kg             :label in frame {&frame-name} = substitute("По док,&1", buf_goods.unit-cli )
        v-fact-qnty-kg        :label in frame {&frame-name} = substitute("Факт,&1", buf_goods.unit-cli )
      .
    end.
    wait-for go of frame {&FRAME-NAME} focus b-exit.
  end.
  else do: /* prt-mode <> {&lookup} */
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
    RUN gds-attr-value (
                        INPUT buf_goods.gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT varvalue,
                        OUTPUT vartype
                        ).
    if varvalue > ""
    and EDOParSec:GetIsMarkingForType(varvalue)
    then do :
      disable
        ub.gds-dtl.fact-qnty
        ub.gds-dtl.doc-qnty
      with frame {&FRAME-NAME} . 
    end .
    
    v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code) .
    
    if v-is-return
    and (EDOParSec:GetIsArticForType(varvalue)
     or EDOParSec:GetIsEDOForType(varvalue)
     or EDOParSec:GetIsMarkingForType(varvalue))
    then do :
      disable
        ub.gds-dtl.fact-qnty
        ub.gds-dtl.doc-qnty
      with frame {&FRAME-NAME} . 
      if node-type = "Transitional"
      then do :
        enable
          ub.gds-dtl.doc-qnty
        with frame {&FRAME-NAME} . 
      end .
    end .
  
    if v-work-with-qnty = "doc":U then do:
      if t-doc.doc-type = {&expense} and input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty = 0 then do:
        if ptrlprop-expptrl = {&calc-petrol-weight}
          and v-qnty-kg :sensitive in frame {&FRAME-NAME}
        then do:
          display
            1 @ v-qnty-kg
          with frame {&FRAME-NAME}.
        end.
        else do:
          display
            1 @ ub.gds-dtl.doc-qnty
          with frame {&FRAME-NAME}.
          if v-is-return
          then do :
            display
              0 @ ub.gds-dtl.doc-qnty
            with frame {&FRAME-NAME}.
          end .
        end.
      end.

      if ptrlprop-expptrl = {&calc-petrol-weight}
        and v-qnty-kg :sensitive in frame {&FRAME-NAME}
      then do:
        wait-for go of frame {&FRAME-NAME} focus v-qnty-kg .
      end. /* q-ty, kg */
      else do: /* q-ty, l */
        if not is-petrolium then do:
          display
            ub.gds-dtl.doc-qnty
            v-qnty-kg
          with frame {&FRAME-NAME}.
          
          if ub.gds-dtl.fact-qnty:hidden = false
          then do:
            display
              v-fact-qnty-kg
            with frame {&FRAME-NAME}.
          end.
                    
          v-qnty-kg             = ub.gds-dtl.doc-qnty / buf_goods.cli-base-rate.
          v-fact-qnty-kg        = ub.gds-dtl.fact-qnty / buf_goods.cli-base-rate.
          v-qnty-kg:screen-value = string (v-qnty-kg).
          v-fact-qnty-kg:screen-value = string (v-fact-qnty-kg).
          assign
            ub.gds-dtl.price-rubl :label in frame {&frame-name} = substitute("Цена,&1", buf_goods.unit-base )
            v-price-rubl-kg       :label in frame {&frame-name} = substitute("Цена,&1", buf_goods.unit-cli )
            ub.gds-dtl.doc-qnty   :label in frame {&frame-name} = substitute("По док,&1", buf_goods.unit-base )
            ub.gds-dtl.fact-qnty  :label in frame {&frame-name} = substitute("Факт,&1", buf_goods.unit-base )
            v-qnty-kg             :label in frame {&frame-name} = substitute("По док,&1", buf_goods.unit-cli )
            v-fact-qnty-kg        :label in frame {&frame-name} = substitute("Факт,&1", buf_goods.unit-cli )
          .
          if t-doc.doc-type = {&expense} and input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty = 0 then do:
            if ptrlprop-expptrl = {&calc-petrol-weight}
              and v-qnty-kg :sensitive in frame {&FRAME-NAME}
            then do:
              display
                1 @ v-qnty-kg
              with frame {&FRAME-NAME}.
            end.
            else do:
              display
                1 @ ub.gds-dtl.doc-qnty
              with frame {&FRAME-NAME}.
              if v-is-return
              or v-isweighed
              then do :
                display
                  0 @ ub.gds-dtl.doc-qnty
                with frame {&FRAME-NAME}.
              end .
            end.
          end.
        end.
        if t-doc.ext-doc-type = {&TDEDT_Ras_Perem} or 
           t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} then
        do:
            run isExemplarGoods in this-procedure 
              (t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code, output vIsExemplarGoods).
            if vIsExemplarGoods
            or v-isweighed 
            then do:
              if t-doc.ext-doc-type = {&TDEDT_Ras_Perem} and 
                 can-find(first buf_marking-lines no-lock where 
                                  buf_marking-lines.out-code = ub.gds-dtl.doc-code
                              and buf_marking-lines.gds-code = buf_goods.gds-code) then
              do:  /* для ПЕРЕМЕЩЕНИЯ РАСХОД проверим есть ли марки по товару, и если есть, то кол-во редактировать нельзя */
                vRightChngQnty = false.  
              end.
              else
              do:
                  vRightChngQntyCode = if t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} 
                      then 'actn_write-off_add-no-mark':U
                      else 'actn_tdedt-ras-perem_add-no-mark':U.
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    vRightChngQntyCode
                    {&cntxt-object}
                    t-doc.host-code
                    t-doc.obj-type
                    t-doc.obj-code
                    0
                    0
                    0
                    false
                    vRightChngQnty
                  }
              end.
              if not vRightChngQnty then
                disable ub.gds-dtl.doc-qnty with frame {&frame-name}.
            end.
        end.

        if node-type begins "scan-marks" then do:
          
          find first buf_marking no-lock where buf_marking.mark begins entry(2,node-type,{&delim-key}) no-error .
          if v-is-return
          then do :
            if available buf_marking
            then do :
              if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
              and EDOParSec:GetIsMarkingForType(varvalue)
              then do :
                message "Марка " buf_marking.mark " не в свободной зоне!" view-as alert-box .
                undo, return error .
              end .
              if v-isweighed
              then do :
                v-mark-weight = MarkWeight(buf_marking.mark).
                if v-mark-weight = 0
                or v-mark-weight = ?
                then do :
                  message "Марка не может быть добавлена, т.к. в БД отсутствует ее вес." view-as alert-box .
                  undo, return error .
                end .
                ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + v-mark-weight) .
              end .
              else do :
                ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + 1).
              end .
            end .
            else do :
              if v-isweighed
              then do :
                message "Марка не найдена в БД." view-as alert-box .
                undo, return error .
              end .
              else do :
                ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + 1).
              end .
            end .
          end .
          else do :
            if not available buf_marking
            then do :
              undo, return error return-value .
            end .
            if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB
            then do :
              message "Марка " buf_marking.mark " не в свободной зоне!" view-as alert-box .
              undo, return error .
            end . 
            
            
            if buf_marking.box-qnty = 0 then
            do:
              vGtin     = getGtinByDM(buf_marking.mark) .
              vGtinQnty = getQntyCodeByGtin(vGtin).
            end.
            
            if v-isweighed
            then do :
              v-mark-weight = MarkWeight(buf_marking.mark).
              if v-mark-weight = 0
              or v-mark-weight = ?
              then do :
                message "Марка не может быть добавлена, т.к. в БД отсутствует ее вес." view-as alert-box .
                undo, return error .
              end .
              find first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking.mark-parent
                                                     and buf_marking-lines.out-code = ub.gds-dtl.doc-code
                                                     no-error .
              if not available buf_marking-lines
              then do :
                ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + v-mark-weight).
              end .
            end .
            else do :
              case buf_marking.unit-ext : 
                when "LEVEL2"
                then do : 
                  ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + if buf_marking.box-qnty <> 0 then buf_marking.box-qnty else vGtinQnty).
                end .
                when "LEVEL1"
                then do :
                  assign v-pack-qnty = 0 .
                  for each buf_marking-child no-lock where buf_marking-child.mark-parent = buf_marking.mark,
                  first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking-child.mark-parent
                                                    and buf_marking-lines.out-code = ub.gds-dtl.doc-code :
                    assign v-pack-qnty = v-pack-qnty + 1 .                                  
                  end .
                  ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + buf_marking.box-qnty - v-pack-qnty).
                end .
                otherwise do :
                  find first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking.mark-parent
                                                         and buf_marking-lines.out-code = ub.gds-dtl.doc-code
                                                         no-error .
                  if not available buf_marking-lines
                  then do :
                    ub.gds-dtl.doc-qnty:screen-value  = string(ub.gds-dtl.doc-qnty + if buf_marking.box-qnty <> 0 then buf_marking.box-qnty else vGtinQnty).
                  end .
                end .
              end case .
            end .
          end .
          
          apply "LEAVE":U to ub.gds-dtl.doc-qnty in frame {&FRAME-NAME}.
          apply "CHOOSE":U to b-exit in frame {&FRAME-NAME}.
        end.
        else do:   
        wait-for go of frame {&FRAME-NAME} focus ub.gds-dtl.doc-qnty .
        end.
      end. /* q-ty, l */
    end. /* qnty */
    else do: /* fact */
      if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then
      do:
        if can-find(first buf_marking-lines where 
                          buf_marking-lines.out-code = ub.gds-dtl.doc-code
                      and buf_marking-lines.gds-code = buf_goods.gds-code) then 
          disable ub.gds-dtl.fact-qnty with frame {&frame-name}. 
      end. 
      
      if t-doc.ext-doc-type = {&TDEDT_Ras_Perem} or 
         t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} then
      do:
          run isExemplarGoods in this-procedure 
            (t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code, output vIsExemplarGoods).
          if vIsExemplarGoods
          or v-isweighed 
          then do:
            if t-doc.ext-doc-type = {&TDEDT_Ras_Perem} and 
               can-find(first buf_marking-lines no-lock where 
                                buf_marking-lines.out-code = ub.gds-dtl.doc-code
                            and buf_marking-lines.gds-code = buf_goods.gds-code) then
            do:  /* для ПЕРЕМЕЩЕНИЯ РАСХОД проверим есть ли марки по товару, и если есть, то кол-во редактировать нельзя */
              vRightChngQnty = false.  
            end.
            else
            do:
                vRightChngQntyCode = if t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} 
                    then 'actn_write-off_add-no-mark':U
                    else 'actn_tdedt-ras-perem_add-no-mark':U.
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  vRightChngQntyCode
                  {&cntxt-object}
                  t-doc.host-code
                  t-doc.obj-type
                  t-doc.obj-code
                  0
                  0
                  0
                  false
                  vRightChngQnty
                }
            end.
            if not vRightChngQnty then
              disable ub.gds-dtl.fact-qnty with frame {&frame-name}.
          end.
      end.
      
      if ptrlprop-expptrl = {&calc-petrol-weight}
        and v-fact-qnty-kg :sensitive in frame {&FRAME-NAME}
      then do:
        wait-for go of frame {&FRAME-NAME} focus v-fact-qnty-kg.
      end. /* fact, kg */
      else do:
        if ub.gds-dtl.fact-qnty :sensitive in frame {&FRAME-NAME} then do:
          wait-for go of frame {&FRAME-NAME} focus ub.gds-dtl.fact-qnty.
        end.
        else do:
          wait-for go of frame {&FRAME-NAME} focus b-exit.
        end.
      end. /* fact, l */
    end. /* fact */
  end.


END. /* MAIN-BLOCK */
RUN disable_UI IN THIS-PROCEDURE.

if v-no-add-marks
then do :
  return "no-add-marks" .
end .
if v-undo-all = true then do:
  undo, return error.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-price d-out-prt 
PROCEDURE ch-price :
define variable v-cli-type    as character no-undo .
define variable v-cli-code    as integer   no-undo .
define variable v-main-b-code as integer   no-undo .
define variable v-b-code      as integer   no-undo .
define variable v-obj-type    as character no-undo .
define variable v-obj-code    as integer   no-undo .
define variable v-qnty-doc    as decimal   no-undo .
define variable v-sum-doc     as decimal   no-undo .
define variable v-fact-order  as decimal   no-undo .
define variable v-plt-id      as integer   no-undo .
define variable v-plt-db-num  as integer   no-undo .
define variable v-pdf-id      as integer   no-undo .
define variable v-pdf-db-num  as integer   no-undo .
define variable v-sale-price-base as decimal   no-undo .
define variable v-sale-price-rubl as decimal   no-undo .

  do
  on error undo, return error return-value
  :
  { gbl/gdsbcode.i
     b-c-b.gds-code
     ?
     v-main-b-code }

 run fact-order-mpl  in this-procedure (
     input t-doc.doc-date ,
     input t-doc.obj-type ,
     input t-doc.obj-code ,
     output v-fact-order )
     .
     /* message
     t-doc.doc-date skip
     t-doc.obj-type skip
     t-doc.obj-code skip
     v-fact-order   skip
     .
     */

assign
  v-cli-type      = t-doc.cli-type
  v-cli-code      = t-doc.cli-code
  v-b-code        = b-c-b.b-code
  v-obj-type      = t-doc.obj-type
  v-obj-code      = t-doc.obj-code
  .
  if ub.gds-dtl.doc-qnty:visible in frame {&frame-name} and ub.gds-dtl.doc-qnty:SENSITIVE then
     v-qnty-doc      = input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty.
  if ub.gds-dtl.fact-qnty:visible in frame {&frame-name} and ub.gds-dtl.fact-qnty:SENSITIVE then
     v-qnty-doc      = input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty.

 v-sum-doc       = 0 . /* ЭТО ПРАВИЛЬНО ! реальная сумма проставляется при пересчете */
 run str/chmpldoc.w
        (input parparentproc
        ,input  v-cli-type
        ,input  v-cli-code
        ,input  v-main-b-code
        ,input  v-b-code
        ,input  v-obj-type
        ,input  v-obj-code
        ,input  v-qnty-doc
        ,input  v-sum-doc
        ,input  string(t-doc.pay-code)
        ,input  ""
        ,input  v-fact-order
        ,output v-plt-id
        ,output v-plt-db-num
        ,output v-pdf-id
        ,output v-pdf-db-num
        ,output v-sale-price-base
        ,output v-sale-price-rubl
        ).
if v-plt-id = ? then return.
 if ub.gds-dtl.price-rubl:visible in frame {&frame-name} and ub.gds-dtl.price-rubl:SENSITIVE then do:
    display v-sale-price-rubl @ ub.gds-dtl.price-rubl with frame {&frame-name} .
    display v-sale-price-base @ ub.gds-dtl.price-base with frame  {&frame-name} .
    apply "leave" to ub.gds-dtl.price-rubl in frame {&frame-name}.
 end.
 else do:
    if ub.gds-dtl.price-base:visible and  ub.gds-dtl.price-base:SENSITIVE then do:
        ub.gds-dtl.price-base = v-sale-price-base .
        display ub.gds-dtl.price-base with frame {&frame-name} .
        display v-sale-price-rubl @ ub.gds-dtl.price-rubl with frame {&frame-name} .
        display v-sale-price-base @ ub.gds-dtl.price-base with frame  {&frame-name} .
        apply "leave" to ub.gds-dtl.price-base in frame {&frame-name}.
    end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-place-rsrv d-out-prt 
PROCEDURE check-place-rsrv :
define variable d_fact-qnty     as decimal no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal no-undo initial 0.00 .
  define variable d_cli-qnty      as decimal no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal no-undo initial 0.00 .
  define variable d_density       as decimal no-undo              .

  do
  on error undo, return error return-value
  :

    if v-place-rsrv <> true
      or b-place :sensitive in frame {&frame-name} <> true
    then do:
      return .
    end.

    if v-work-with-qnty = "fact":U
      or v-work-with-qnty = "fact-doc":U
    then do:
      if input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty < input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty then do:
        message
          substitute( 'Фактическое количество в строке накладной (&1 &2) больше количества по документу (&3 &2).'
                      ,input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty
                      ,buf_goods.unit-base
                      ,input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty
                    )
          view-as alert-box error .
        undo, return error .
      end.
    end.

    assign
      d_fact-qnty     = 0.00
      d_doc-qnty      = 0.00
      d_cli-qnty      = 0.00
      d_cli-fact-qnty = 0.00
      d_cli-doc-qnty  = 0.00
    .
    for each tt-doc-pl no-lock
    on error undo, return error return-value
    :
      assign
        d_cli-qnty      = d_cli-qnty      + tt-doc-pl.cli-qnty
        d_fact-qnty     = d_fact-qnty     + tt-doc-pl.fact-qnty
        d_doc-qnty      = d_doc-qnty      + tt-doc-pl.doc-qnty
        d_cli-fact-qnty = d_cli-fact-qnty + tt-doc-pl.cli-fact-qnty
        d_cli-doc-qnty  = d_cli-doc-qnty  + tt-doc-pl.cli-doc-qnty
      .
    end. /* for each tt-doc-pl */

    if input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty <> d_doc-qnty then do:
      message
        substitute( 'Количество по документу в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения: &2.&3'
                    , input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty
                    , d_doc-qnty
                    , {&new-line}
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if ( v-qnty-kg :sensitive in frame {&frame-name} = true
        and input frame {&FRAME-NAME} v-qnty-kg <> d_cli-doc-qnty
      )
      or
      ( v-qnty-kg :sensitive in frame {&frame-name} = false
        and absolute( input frame {&FRAME-NAME} v-qnty-kg - d_cli-doc-qnty ) > 0.001
      )
    then do:
      message
        substitute( 'Количество в ед.пост-ка в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ с суммарным количеством в ед.пост-ка по местам хранения: &2.&3'
                    + 'Нажмите кнопку "&4" и исправьте количества по местам хранения&3'
                    + 'или исправьте количество в строке накладной.'
                    , input frame {&FRAME-NAME} v-qnty-kg
                    , d_cli-doc-qnty
                    , {&new-line}
                    , replace( b-place :label in frame {&frame-name}, "&", "":U )
                  )
        view-as alert-box error .
      undo, return error .
    end.

    if v-work-with-qnty = "fact":U
      or v-work-with-qnty = "fact-doc":U
    then do:
      if input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty <> d_fact-qnty then do:
        message
          substitute( 'Фактическое количество в строке накладной: &1 &3'
                      + 'НЕ СОВПАДАЕТ &3 с суммарным фактическим количеством по местам хранения: &2.&3'
                      , input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty
                      , d_fact-qnty
                      , {&new-line}
                    )
          view-as alert-box error .
        undo, return error .
      end.
      if ( v-fact-qnty-kg :sensitive in frame {&frame-name} = true
          and input frame {&FRAME-NAME} v-fact-qnty-kg <> d_cli-fact-qnty
        )
        or
        ( v-fact-qnty-kg :sensitive in frame {&frame-name} = false
          and absolute( input frame {&FRAME-NAME} v-fact-qnty-kg - d_cli-fact-qnty ) > 0.001
        )
      then do:
        message
          substitute( 'Фактическое количество в ед.пост-ка в строке накладной: &1 &3'
                      + 'НЕ СОВПАДАЕТ &3 с суммарным фактическим количеством в ед.пост-ка по местам хранения: &2.&3'
                      + 'Нажмите кнопку "&4" и исправьте фактические количества в ед.пост-ка по местам хранения&3'
                      + 'или исправьте фактическое количество в ед.пост-ка в строке накладной.'
                      , input frame {&FRAME-NAME} v-fact-qnty-kg
                      , d_cli-fact-qnty
                      , {&new-line}
                      , replace( b-place :label in frame {&frame-name}, "&", "":U )
                    )
          view-as alert-box error .
        undo, return error .
      end.
    end.

    if buf_goods.unit-base <> buf_goods.unit-cli
    and not is-gas(buf_goods.gds-code)
    then do:
      assign
        d_density = d_cli-doc-qnty / d_doc-qnty
      .
      if ( d_density <= 0.00 or d_density >= 1.00 )
        and ( ub.gds-dtl.doc-qnty :sensitive in frame {&frame-name}
              or v-qnty-kg :sensitive in frame {&frame-name}
            )
      then do:
        message
          substitute( 'Заявленная плотность топлива (&1) не соответствует ожидаемому. Кол-во: &2л и &3кг.'
                      , d_density
                      , d_doc-qnty
                      , d_cli-doc-qnty
                    )
          view-as alert-box error .
        undo, return error .
      end.
      assign
        d_density = d_cli-fact-qnty / d_fact-qnty
      .
      if ( d_density <= 0.00 or d_density >= 1.00 )
        and ub.gds-dtl.fact-qnty :sensitive in frame {&frame-name}
      then do:
        message
          substitute( 'Фактическая плотность топлива (&1) не соответствует ожидаемому. Кол-во: &2л и &3кг.'
                    , d_density
                    , d_fact-qnty
                    , d_cli-fact-qnty
                    )
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end. /* on error */
end procedure. /* check-place-rsrv */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE correct-fact-qnty d-out-prt 
PROCEDURE correct-fact-qnty :
define input parameter p-newfact-qnty like ub.doc-line.fact-qnty   no-undo .
  define input parameter p-density      like ub.doc-line.doc-density no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    define buffer buf-next_tt-doc-pl for tt-doc-pl .

    assign
      ub.doc-line.fact-density = p-density
    .
    display
      p-newfact-qnty @ ub.gds-dtl.fact-qnty
      p-newfact-qnty * p-density when v-fact-qnty-kg :visible = true @ v-fact-qnty-kg
      with frame {&frame-name} .

    find first tt-doc-pl no-lock
    .
    find first buf-next_tt-doc-pl no-lock
      where buf-next_tt-doc-pl.obj-type =  tt-doc-pl.obj-type
        and buf-next_tt-doc-pl.obj-code =  tt-doc-pl.obj-code
        and buf-next_tt-doc-pl.pl-code  <> tt-doc-pl.pl-code
      no-error .
    if available buf-next_tt-doc-pl then do:
      for each tt-doc-pl
      on error undo, return error return-value
      :
        assign
          tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-density
        .
      end. /* for each tt-doc-pl */
      run edit-doc-pl in this-procedure
        ( input {&autoupdate}
        ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
    end. /* if available buf-next_tt-doc-pl */
    else do: /* if not available buf-next_tt-doc-pl */
      assign
        tt-doc-pl.fact-qnty     = p-newfact-qnty
        tt-doc-pl.cli-fact-qnty = p-newfact-qnty * p-density
      .
    end. /* if not available tt-doc-pl */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-out-prt 
PROCEDURE disable_UI :
HIDE FRAME {&FRAME-NAME} NO-PAUSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE edit-doc-pl d-out-prt 
PROCEDURE edit-doc-pl :
define input  parameter p-edit-doc-pl-mode as character no-undo .

  define variable d_fact-qnty     as decimal   no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal   no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal   no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal   no-undo initial 0.00 .

  define variable v-log           as logical   no-undo .
  define variable v-upd-units     as character no-undo .

  if v-qnty-kg :sensitive  in frame {&frame-name} = true
    or v-fact-qnty-kg :sensitive  in frame {&frame-name} = true
  then do:
    assign
      v-upd-units = "cli":U
    .
  end.
  else do:
    assign
      v-upd-units = "base":U
    .
  end.

  if v-place-rsrv = false then do:
    message
      substitute( "Товар &1 не привязывается к местам хранения.", buf_goods.gds-code )
      view-as alert-box.
    return .
  end.

  if prt-mode = {&lookup}
    or t-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
  then do:
    assign
      p-edit-doc-pl-mode = {&lookup}
    .
  end.
  else do:
    if is-petrolium = yes
      and is-pieces = no
      and v-work-with-qnty = "doc":U
    then do:
      if ub.doc-line.doc-density = 0
        or ub.doc-line.doc-density = ?
      then do:
        message
          "Не указана плотность"
          view-as alert-box information.
        if ub.doc-line.doc-density :sensitive in frame {&frame-name} then do:
          apply "entry" to ub.doc-line.doc-density in frame {&frame-name} .
        end.
        return error .
      end.
    end.
  end.

  run str/doc-pls.w
    ( input parparentproc
     ,input p-edit-doc-pl-mode
     ,input v-work-with-qnty
     ,input v-upd-units
     ,input t-doc.doc-code
     ,input buf_goods.gds-code
     ,input ub.doc-line.unit-cli
     ,input ub.doc-line.cli-base-rate
     ,input ub.doc-line.doc-density
     ,input ub.doc-line.fact-density
     ,input input frame {&frame-name} v-qnty-kg
     ,input input frame {&frame-name} ub.gds-dtl.doc-qnty
     ,input input frame {&frame-name} ub.gds-dtl.fact-qnty
     ,input input frame {&frame-name} v-qnty-kg
     ,input input frame {&frame-name} v-fact-qnty-kg
     ,input ?
     ,input ?
     ,input ?
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при разбиении кол-ва по местам хранения." skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.

  if prt-mode <> {&lookup} then do:

    for each tt-doc-pl no-lock
    on error undo, return error return-value
    :
      assign
        d_fact-qnty     = d_fact-qnty     + tt-doc-pl.fact-qnty
        d_doc-qnty      = d_doc-qnty      + tt-doc-pl.doc-qnty
        d_cli-fact-qnty = d_cli-fact-qnty + tt-doc-pl.cli-fact-qnty
        d_cli-doc-qnty  = d_cli-doc-qnty  + tt-doc-pl.cli-doc-qnty
      .
    end. /* for each next_doc-pl */

    assign
      v-log = true
    .

    if v-work-with-qnty = "doc":U
      and ( input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty <> d_doc-qnty
            or
            ( ub.gds-dtl.doc-qnty :sensitive in frame {&FRAME-NAME} = true
              and absolute( input frame {&FRAME-NAME} v-qnty-kg - d_cli-doc-qnty ) > 0.001
            )
            or
            ( v-qnty-kg :sensitive in frame {&FRAME-NAME} = true
              and input frame {&FRAME-NAME} v-qnty-kg <> d_cli-doc-qnty
            )
          )
    then do:
      message
        substitute( "Документарная сумма по местам хранения: &1 &2 (&3 &4)", d_doc-qnty, buf_goods.unit-base, d_cli-doc-qnty, buf_goods.unit-cli ) skip
        substitute( "Документарное кол-во по строке документа: &1 &2 (&3 &4)"
                   ,input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty
                   ,buf_goods.unit-base
                   ,input frame {&FRAME-NAME} v-qnty-kg
                   ,buf_goods.unit-cli
                  ) skip(1)
        substitute( "Будем менять документарное количество по строке на &1 &2 (&3 &4)?", d_doc-qnty, buf_goods.unit-base, d_cli-doc-qnty, buf_goods.unit-cli )
        view-as alert-box question buttons yes-no update v-log.

      if v-log = true then do:
/*        assign*/
/*          ub.gds-dtl.doc-qnty = d_doc-qnty*/
/*          v-qnty-kg = d_cli-doc-qnty*/
/*        .*/
/*        assign*/
/*          ub.doc-line.doc-density  = d_cli-doc-qnty / d_doc-qnty*/
/*          ub.doc-line.fact-density = ub.doc-line.doc-density*/
        .
        display
          d_doc-qnty @ ub.gds-dtl.doc-qnty
/*          ub.doc-line.doc-density when ub.doc-line.doc-density :visible in frame {&FRAME-NAME} = true*/
          d_doc-qnty * ub.doc-line.doc-density when v-qnty-kg :visible in frame {&FRAME-NAME} = true @ v-qnty-kg
          with frame {&FRAME-NAME} .
      end.
    end.

    if ( v-work-with-qnty = "fact":U
         or v-work-with-qnty = "fact-doc":U
       )
      and varupd-fact-qnty = true
      and ( input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty <> d_fact-qnty
            or
            ( v-fact-qnty-kg :sensitive in frame {&FRAME-NAME} = true
              and input frame {&FRAME-NAME} v-fact-qnty-kg <> d_cli-fact-qnty
            )
            or
            ( ub.gds-dtl.fact-qnty :sensitive in frame {&FRAME-NAME} = true
              and absolute( input frame {&FRAME-NAME} v-fact-qnty-kg - d_cli-fact-qnty ) > 0.001
            )
          )
    then do:
      message
        substitute( "Фактическая сумма по местам хранения: &1 &2 (&3 &4)", d_fact-qnty, buf_goods.unit-base, d_cli-fact-qnty, buf_goods.unit-cli ) skip
        substitute( "Фактическое кол-во по строке документа: &1 &2 (&3 &4)"
                    ,input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty
                    ,buf_goods.unit-base
                    ,input frame {&FRAME-NAME} v-fact-qnty-kg
                    ,buf_goods.unit-cli ) skip(1)
        substitute( "Будем менять фактическое количество по строке на &1 &2 (&3 &4)?", d_fact-qnty, buf_goods.unit-base, d_cli-fact-qnty, buf_goods.unit-cli )
        view-as alert-box question buttons yes-no update v-log.

      if v-log = true then do:
        assign
          v-old-fact-qnty     = d_fact-qnty
          v-old-fact-cli-qnty = d_cli-fact-qnty
        .
        display
          d_fact-qnty @ ub.gds-dtl.fact-qnty
          d_cli-fact-qnty when v-fact-qnty-kg :visible in frame {&FRAME-NAME} = true @ v-fact-qnty-kg
          with frame {&FRAME-NAME}
        .
        if v-work-with-qnty = "fact-doc":U then do:
          run str/doc-pls.w
            ( input parparentproc
            ,input {&autoupdate} + {&delim-par} + "calc-qnty":U
            ,input v-work-with-qnty
            ,input v-upd-units
            ,input t-doc.doc-code
            ,input buf_goods.gds-code
            ,input ub.doc-line.unit-cli
            ,input ub.doc-line.cli-base-rate
            ,input ub.doc-line.doc-density
            ,input ub.doc-line.fact-density
            ,input input frame {&frame-name} v-qnty-kg
            ,input input frame {&frame-name} ub.gds-dtl.doc-qnty
            ,input input frame {&frame-name} ub.gds-dtl.fact-qnty
            ,input input frame {&frame-name} v-qnty-kg
            ,input input frame {&frame-name} v-fact-qnty-kg
            ,input ?
            ,input ?
            ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
        end.
      end.
    end.
  end. /* if line-mode <> {&lookup} */
end procedure. /* edit-doc-pl */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE l-doc-qnty d-out-prt 
PROCEDURE l-doc-qnty :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable vGtin     as character no-undo.
  define variable vGtinQnty as integer no-undo.
  define variable v-mark-weight as decimal no-undo .
  
  if v-isweighed
  then do :
    for each buf_marking-lines no-lock where
             buf_marking-lines.out-code = t-doc.doc-code
         and buf_marking-lines.obj-type = t-doc.obj-type
         and buf_marking-lines.obj-code = t-doc.obj-code
         and buf_marking-lines.gds-code = buf_goods.gds-code
         and buf_marking-lines.doc-level = 1,
        first buf_marking no-lock where
              buf_marking.mark = buf_marking-lines.mark
    :
      v-mark-weight = v-mark-weight + MarkWeight(buf_marking.mark).
    end.
    if v-mark-weight > input frame {&frame-name} ub.gds-dtl.doc-qnty then 
    do:
      message "Нельзя ввести количество меньше, чем просканировано марок по товару" view-as alert-box. 
      ub.gds-dtl.doc-qnty:screen-value = string(v-mark-weight).
      apply "enrty" to ub.gds-dtl.doc-qnty in frame {&frame-name}.
      return error.  
    end.
  end .
  else  
  if vIsExemplarGoods then
  do:  /* для поэкземплярного учета проверим: введенное кол-во не должно быть < просканированных марок */
    for each buf_marking-lines no-lock where
             buf_marking-lines.out-code = t-doc.doc-code
         and buf_marking-lines.obj-type = t-doc.obj-type
         and buf_marking-lines.obj-code = t-doc.obj-code
         and buf_marking-lines.gds-code = buf_goods.gds-code
         and buf_marking-lines.doc-level = 1,
        first buf_marking no-lock where
              buf_marking.mark = buf_marking-lines.mark
    :
      assign
        vGtin     = getGtinByDM(buf_marking.mark)
        vGtinQnty = vGtinQnty  + getQntyCodeByGtin(vGtin)
      .
    end.
    if vGtinQnty > input frame {&frame-name} ub.gds-dtl.doc-qnty then 
    do:
      message "Нельзя ввести количество меньше, чем просканировано марок по товару" view-as alert-box. 
      ub.gds-dtl.doc-qnty:screen-value = string(vGtinQnty).
      apply "enrty" to ub.gds-dtl.doc-qnty in frame {&frame-name}.
      return error.  
    end.  
  end.

  { str/set-pr.i recid(ub.gds-dtl) yes "input frame {&frame-name} ub.gds-dtl.doc-qnty" no-error }
  if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error
    .
  assign
    tot-rubl = input frame {&frame-name} ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
    tot-base = input frame {&frame-name} ub.gds-dtl.doc-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
  .
  display
    ub.gds-dtl.price-base
    ub.gds-dtl.price-rubl
    ub.gds-dtl.discnt-base
    ub.gds-dtl.discnt-rubl
    tot-rubl
    tot-base
    with frame {&frame-name}.
  if is-petrolium = yes and is-pieces = no then do:
    if { str/valddnst.i chk ub.doc-line.doc-density "buf_goods.unit-base = buf_goods.unit-cli" } = yes then do:
      assign
        v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.doc-density
        v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.doc-density
      .
      display
        v-price-rubl-kg
        v-price-base-kg
        input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty * ub.doc-line.doc-density @ v-qnty-kg
      with frame {&FRAME-NAME}.
    end. /* density */
  end. /* petrol */
  else do:
    assign
      v-qnty-kg             = decimal (ub.gds-dtl.doc-qnty:screen-value) / buf_goods.cli-base-rate
      v-fact-qnty-kg        = decimal (ub.gds-dtl.fact-qnty:screen-value) / buf_goods.cli-base-rate
    no-error.
    v-qnty-kg:screen-value = string (v-qnty-kg).
    v-fact-qnty-kg:screen-value = string (v-fact-qnty-kg).
  end.

  if v-old-doc-qnty <> input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty then do:
    if ( is-petrolium = yes
        and is-pieces = no
        and { str/valddnst.i chk ub.doc-line.doc-density "buf_goods.unit-base = buf_goods.unit-cli" } = yes
      )
      or not ( is-petrolium = yes
                and is-pieces = no
              )
    then do:
      if v-place-rsrv = true
        and not ( last-event :event-type = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
      then do:
        run edit-doc-pl in this-procedure
          ( input {&autoupdate}
          ).
      end.
    end.
  end.
  run re-calcpr in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE l-fact-qnty d-out-prt 
PROCEDURE l-fact-qnty :
  run check-fact-qnty in this-procedure no-error .
  if error-status:error then return error. 

  { str/set-pr.i recid(ub.gds-dtl) yes "input frame {&frame-name} ub.gds-dtl.fact-qnty" no-error }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error
    .
  end.
  assign
    tot-rubl = input frame {&frame-name} ub.gds-dtl.fact-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
    tot-base = input frame {&frame-name} ub.gds-dtl.fact-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
  .
  display
    ub.gds-dtl.price-base
    ub.gds-dtl.price-rubl
    ub.gds-dtl.discnt-base
    ub.gds-dtl.discnt-rubl
    tot-rubl
    tot-base
    with frame {&FRAME-NAME}.

  if is-petrolium = true
    and is-pieces = false
    and { str/valddnst.i chk ub.doc-line.fact-density "buf_goods.unit-base = buf_goods.unit-cli" } = true
  then do:
    display
      input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty * ub.doc-line.fact-density @ v-fact-qnty-kg
      with frame {&FRAME-NAME}.
  end.
  if v-old-fact-qnty <> input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty then do:
    if v-place-rsrv = true
      and not ( last-event :event-type = "progress":u
                and last-event :widget-enter = b-place :handle
              )
    then do:
      run edit-doc-pl in this-procedure
        ( input {&autoupdate}
        ).
    end.
  end.
  run re-calcpr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-fact-qnty d-out-prt 
PROCEDURE check-fact-qnty :
/* Если кол-во в базовых единицах товара получается дробное, то ошибка.*/
  if can-find( first ub.units where ub.units.unit-name = buf_goods.unit-base
                      and lookup( {&pieces}, ub.units.type ) > 0 ) and
    truncate( input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty,  0 )
        <>    input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty
  then do:
    message "Базовая единица товара " buf_goods.unit-base " - штучная." skip
            "Кол-во по факту должно быть целым."
    view-as alert-box error.
    return error.
  end.
  if ( ( lookup( t-doc.doc-type, {&income_return} ) > 0
         and t-doc.internal = true
         and ( ub.gds-prt.upper-code = buf_goods.prt-root /* выключены шкалы на тек. объекте */
               or can-find( out-dtl no-lock
                            where out-dtl.doc-code  = t-doc.out-code
                              and out-dtl.artic     = ub.gds-dtl.artic
                              and out-dtl.prod-type = ub.gds-dtl.prod-type
                              and out-dtl.prod-code = ub.gds-dtl.prod-code
                              and out-dtl.prt-code  = ub.gds-dtl.prt-code
                           )
             ) /* включены и на объекте-источнике */
       )
       or ( t-doc.doc-type = {&return}
            and t-doc.internal = false
          )
       or lookup( t-doc.doc-type, {&income_return} ) = 0
     )
    and input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty > ( if is-petrolium = true and is-pieces = false then 0.001 else 0.0 )
  then do:
    message
      "Фактическое количество товара не может быть больше количества по накладной."
      view-as alert-box.
    apply "ENTRY":U to ub.gds-dtl.fact-qnty in frame {&FRAME-NAME}.
    return error.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE leave-price-rubl d-out-prt 
PROCEDURE leave-price-rubl :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
      run re-calcpr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE new-price-s d-out-prt 
PROCEDURE new-price-s :
/* продажная цена до закрытия прихода на факт */
  do
  on error undo, return error return-value
  :

if not ( pr-naklvalue = yes and pr-genmrg = {&typeprice_before-margin} ) then do:
   hide  ub.gds-dtl.new-price-sale  in frame {&frame-name}
         b-corr-price-sale in frame {&frame-name}
         .
   return.
end.

if prt-mode = {&lookup} then do:
end.
else do:
  define variable l-ok as logical   no-undo .
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_income_price-sale':U
      {&cntxt-object}
      t-doc.host-code
      t-doc.obj-type
      t-doc.obj-code
      0
      0
      0
      false
      l-ok
    }
    if l-ok = true
    then do:
      enable ub.gds-dtl.new-price-sale  with frame {&frame-name} .
    end.
end.

define variable p-exist   as logical  no-undo .
run lineattr-exist in this-procedure (
    input t-doc.doc-code  ,
    input buf_goods.gds-code    ,
    input {&lineattr-corr-price-sale} ,
    output p-exist ) .

if p-exist then display b-corr-price-sale with frame {&frame-name} .
           else hide    b-corr-price-sale in frame {&frame-name} .

ub.gds-dtl.new-price-sale:tooltip = "Цена будет перенесена в переоценку до закрытия этой накладной до ФАКТ" .
display ub.gds-dtl.new-price-sale with frame {&frame-name} .

  end.

end procedure. /* new-price-s */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-case d-out-prt 
PROCEDURE proc-case :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-action-name as character no-undo .

  if is-petrolium = yes
    and is-pieces = no
  then do:
    if available ub.inv-line then do:
      assign
        v-price-rubl-kg   = ub.inv-line.wast-rubl
        v-price-base-kg   = ub.inv-line.wast-base
        v-fact-qnty-kg    = ub.inv-line.wast-cli-qnty
        v-qnty-kg         = ub.doc-line.cli-qnty
      .
    end. /* if available ub.inv-line */
    else do: /* if not available ub.inv-line */
      if { str/valddnst.i chk ub.doc-line.doc-density "buf_goods.unit-base = buf_goods.unit-cli" } = yes then do:
        assign
          v-price-rubl-kg = ub.gds-dtl.price-rubl / ub.doc-line.doc-density
          v-price-base-kg = ub.gds-dtl.price-base / ub.doc-line.doc-density
          v-qnty-kg       = ub.gds-dtl.doc-qnty   * ub.doc-line.doc-density
          v-fact-qnty-kg  = ub.gds-dtl.fact-qnty  * ub.doc-line.fact-density
        .
      end. /* density */
      else do:
        assign
          v-price-rubl-kg = 0.0
          v-price-base-kg = 0.0
          v-qnty-kg       = 0.0
          v-fact-qnty-kg  = 0.0
        .
      end.
    end. /* if not available ub.inv-line */
    if prt-mode <> {&lookup}
      and buf_goods.unit-base = buf_goods.unit-cli
      and ( ub.doc-line.doc-density = ?
            or ub.doc-line.doc-density = 0.0
          )
    then do:
      assign
        ub.doc-line.doc-density   = 1.0
        ub.doc-line.cli-base-rate = 1.0
        ub.doc-line.fact-density  = 1.0
      .
    end.

    display
      v-price-rubl-kg
      v-price-base-kg
      v-qnty-kg
      v-fact-qnty-kg
      ub.doc-line.doc-density
      ub.doc-line.temperature
      with frame {&FRAME-NAME}.

    if (t-doc.flag_ = true or t-doc.status_ = {&fact})
    and t-doc.ext-doc-type <> {&TDEDT_Pri_Object} and t-doc.ext-doc-type <> {&TDEDT_Ras_Object}
    then do:
      enable
        b-addinf
        with frame {&frame-name}.
      if t-doc.doc-type = {&income}
        and lookup(v-ptrl-without-rvs, 'true,yes':u) = 0
      then do:
        enable
          b-rvs-bf
          b-rvs-af
          with frame {&frame-name}.
      end.
    end.
  end. /* is-petrolium = yes and is-pieces = no */
  else do:
    hide
      v-price-rubl-kg
      v-price-base-kg
      v-qnty-kg
      v-fact-qnty-kg
      ub.doc-line.doc-density
      ub.doc-line.temperature
      in frame {&FRAME-NAME}
    .
  end.

  case t-doc.doc-type :
    when {&expense}
    or when {&write-off}
    or when {&return}
    then do:
      if prt-mode = {&inv-def}
        or prt-mode = {&prt-def}
      then do:
        if v-work-with-qnty = "doc":U then do:
          if t-doc.discnt-type = {&row} then do:
            if ub.gds-dtl.discnt-type /* процент */ then do:
              assign
                ub.gds-dtl.discnt-base = ub.gds-dtl.price-base * ub.gds-dtl.discnt-pc / 100
                ub.gds-dtl.discnt-rubl = ub.gds-dtl.price-rubl * ub.gds-dtl.discnt-pc / 100
              .
              enable ub.gds-dtl.discnt-pc with frame {&FRAME-NAME}.
            end.
            else do:
              if t-doc.print-rubl then do:
                assign
                  ub.gds-dtl.discnt-pc   = ub.gds-dtl.discnt-rubl * 100 / ub.gds-dtl.price-rubl
                  ub.gds-dtl.discnt-base = ub.gds-dtl.discnt-rubl       / t-doc.base-rate * t-doc.base-scale
                .
                if ub.gds-dtl.discnt-pc = ? then do:
                  assign
                    ub.gds-dtl.discnt-pc = 0.
                end.
                enable ub.gds-dtl.discnt-rubl with frame {&FRAME-NAME}.
              end.
              else do:
                assign
                  ub.gds-dtl.discnt-pc   = ub.gds-dtl.discnt-base * 100 / ub.gds-dtl.price-base
                  ub.gds-dtl.discnt-rubl = ub.gds-dtl.discnt-base *       t-doc.base-rate / t-doc.base-scale
                .
                if ub.gds-dtl.discnt-pc = ? then do:
                  assign
                    ub.gds-dtl.discnt-pc = 0.
                end.
                enable ub.gds-dtl.discnt-base with frame {&FRAME-NAME}.
              end.
            end.
            enable ub.gds-dtl.discnt-type with frame {&FRAME-NAME}.
          end.

          if lookup( t-doc.doc-type, {&expense_write-off} ) > 0 then do:
            if available ub.prt-obj    then do: display ub.prt-obj.free-qnty  with frame {&FRAME-NAME}. end.
            if available ub.price-list then do: display ub.price-list.doc-num with frame {&FRAME-NAME}. end.
          end.
          if t-doc.internal = false then do:
            case t-doc.doc-type :
              when {&expense} then do:
                assign
                  v-action-name = 'actn_expense_price':U
                .
              end.
              when {&write-off} then do:
                assign
                  v-action-name = 'actn_write-off_price':U
                .
              end.
              when {&return} then do:
                assign
                  v-action-name = 'actn_return_price':U
                .
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" t-doc.doc-type skip
                  "Код документа" t-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              v-action-name
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              false
              g#log
            }
          end.
          else do:
            assign
              g#log = no
            .
          end.
          if is-petrolium = true
            and is-pieces = false
            and ptrlprop-expptrl = {&calc-petrol-weight}
            and buf_goods.unit-base <> buf_goods.unit-cli
          then do:
            enable
              v-qnty-kg
              with frame {&FRAME-NAME}.
          end.
          else do:
            enable
              ub.gds-dtl.doc-qnty
              with frame {&FRAME-NAME}.
          end.

          if is-petrolium = true
            and is-pieces = false
            and buf_goods.unit-base <> buf_goods.unit-cli
          then do:
            enable
              ub.doc-line.temperature
              ub.doc-line.doc-density
              with frame {&FRAME-NAME}.
          end. /* is-petrolium = yes and is-pieces = no */


          if ( g#log and t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} )
            or ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} and t-doc.status_ = {&inquiry} )
          then do:
            if is-petrolium = true
              and is-pieces = false
              and ptrlprop-expptrl = {&calc-petrol-weight}
              and buf_goods.unit-base <> buf_goods.unit-cli
            then do:
              if t-doc.print-rubl = true then do:
                enable
                  v-price-rubl-kg
                  with frame {&FRAME-NAME}.
              end.
              else do:
                enable
                  v-price-base-kg
                  with frame {&FRAME-NAME}.
              end.
            end.
            else do:
              if t-doc.print-rubl = true then do:
                if not v-is-return
                then
                enable
                  ub.gds-dtl.price-rubl
                  with frame {&FRAME-NAME}
                .
              end.
              else do:
                if not v-is-return
                then
                enable
                  ub.gds-dtl.price-base
                  with frame {&FRAME-NAME}
                .
              end.
            end.
          end.
        end. /* if v-work-with-qnty = "doc":U */
        else do:
          hide
            ub.prt-obj.free-qnty  in frame {&FRAME-NAME}
            ub.price-list.doc-num in frame {&FRAME-NAME}
          .
          if t-doc.ext-doc-type <> {&TDEDT_Vozvrat_Perem} then do:
            if is-petrolium = yes
              and is-pieces = no
              and ptrlprop-expptrl = {&calc-petrol-weight}
              and buf_goods.unit-base <> buf_goods.unit-cli
            then do:
              enable
                v-fact-qnty-kg
                with frame {&FRAME-NAME}.
            end. /* petrol */
            else do:
              enable
                ub.gds-dtl.fact-qnty
                with frame {&FRAME-NAME}.
            end.
          end.
        end. /* if t-doc.flag_ or t-doc.status_ = {&permitted} */
      end. /* if prt-mode = {&inv-def} or prt-mode = {&prt-def} */

      if ub.gds-dtl.ov = yes then do: hide ub.price-list.doc-num in frame {&FRAME-NAME}. end.
      if prt-mode = {&lookup} then do: hide ub.prt-obj.free-qnty ub.price-list.doc-num in frame {&FRAME-NAME}. end.
      if t-doc.discnt-type = {&row} then do:
        display ub.gds-dtl.discnt-type with frame {&FRAME-NAME}.
      end.
      else do:
        hide ub.gds-dtl.discnt-type in frame {&FRAME-NAME}.
      end.
      if ub.gds-dtl.ov and t-doc.status_ <> {&fact} then do:
        assign
          ub.price-list.doc-num :fgcolor = 4
        .
        display "Не цена объекта" @ ub.price-list.doc-num with frame {&FRAME-NAME}.
      end.
      display ub.gds-dtl.discnt-base ub.gds-dtl.discnt-rubl ub.gds-dtl.discnt-pc with frame {&FRAME-NAME}.
      if t-doc.internal then do:
        hide ub.gds-dtl.discnt-base ub.gds-dtl.discnt-rubl ub.gds-dtl.discnt-pc
                ub.gds-dtl.discnt-type in frame {&FRAME-NAME}.
      end.
    end.

    when {&income} then do:
      if prt-mode = {&inv-def} or prt-mode = {&prt-def} then do:
        if v-work-with-qnty = "doc":U then do:
          if ptrlprop-expptrl = {&calc-petrol-weight}
            and buf_goods.unit-base <> buf_goods.unit-cli
          then do:
            enable
              v-qnty-kg
            with frame {&FRAME-NAME}.
            if t-doc.status_ = {&inquiry} and t-doc.internal then do:
              if t-doc.print-rubl = yes then do:
                enable
                  v-price-rubl-kg
                with frame {&FRAME-NAME}.
              end. /* rubl */
              else do: /* base */
                enable
                  v-price-base-kg
                with frame {&FRAME-NAME}.
              end. /* base */
            end. /* t-doc.status_ = {&inquiry} and t-doc.internal */
          end. /* ptrlprop-expptrl = {&calc-petrol-weight} */
          else do: /* ptrlprop-expptrl = {&calc-petrol-volume} or ? */
            enable
              ub.gds-dtl.doc-qnty
            with frame {&FRAME-NAME}.
            if t-doc.status_ = {&inquiry} and t-doc.internal then do:
              if t-doc.print-rubl = yes then do:
                enable
                  ub.gds-dtl.price-rubl
                with frame {&FRAME-NAME}.
              end. /* rubl */
              else do: /* base */
                enable
                  ub.gds-dtl.price-base
                with frame {&FRAME-NAME}.
              end. /* base */
            end. /* t-doc.status_ = {&inquiry} and t-doc.internal */
          end. /* ptrlprop-expptrl = {&calc-petrol-volume} or ? */
        end. /* doc */
        else do: /* fact */
          if varupd-fact-qnty = true then do:
            if ptrlprop-expptrl = {&calc-petrol-weight}
              and buf_goods.unit-base <> buf_goods.unit-cli
            then do:
              enable
                v-fact-qnty-kg
                with frame {&FRAME-NAME}.
            end. /* ptrlprop-expptrl = {&calc-petrol-weight} */
            else do: /* ptrlprop-expptrl = {&calc-petrol-volume} or ? */
              enable
                ub.gds-dtl.fact-qnty
                with frame {&FRAME-NAME}.
            end. /* ptrlprop-expptrl = {&calc-petrol-volume} or ? */
          end.
        end. /* fact */
      end. /* prt-mode = {&inv-def} or {&prt-def} */
      hide ub.prt-obj.free-qnty ub.price-list.doc-num ub.gds-dtl.discnt-base ub.gds-dtl.discnt-rubl
           ub.gds-dtl.discnt-pc ub.gds-dtl.discnt-type in frame {&FRAME-NAME}.
    end.
  end case. /* t-doc.doc-type */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE re-calcpr d-out-prt 
PROCEDURE re-calcpr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if pr-naklvalue = yes and pr-genmrg = {&typeprice_before-margin} and prt-mode <> {&lookup} then do:

  { str/prslnew.i
    "run"
    pr-genmrg
    pr-naklvalue
    t-doc.doc-code
    ub.gds-dtl.artic
    ub.gds-dtl.prod-type
    ub.gds-dtl.prod-code
    ub.gds-dtl.price-rubl
    ub.gds-dtl.price-base
    ub.gds-dtl.price-rubl
    ub.gds-dtl.price-base
    ub.gds-dtl.new-price-sale
    }

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-doc-line-attr d-out-prt 
PROCEDURE read-doc-line-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code       as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-attr-code      as character        no-undo.
define output parameter p-attr-value    as character        no-undo.

   define buffer buf_doc-line-attr       for ub.doc-line-attr.
do
for buf_doc-line-attr
on error undo, return error
:
    find first buf_doc-line-attr no-lock
         where buf_doc-line-attr.doc-code     = p-doc-code
           and buf_doc-line-attr.gds-code     = p-gds-code
           and buf_doc-line-attr.attr-code    = p-attr-code
    no-error.
    if available buf_doc-line-attr
    then do:
        assign
            p-attr-value = buf_doc-line-attr.attr-value
        .
    end.
    else do:
        assign
            p-attr-value = "":U
        .
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rsrv-out d-out-prt 
PROCEDURE rsrv-out :
define variable v-chg-qnty      as decimal   no-undo .
  define variable v-chg-doc-qnty  as decimal   no-undo .
  define variable v-chg-fact-qnty as decimal   no-undo .
  define variable v-density       as decimal   no-undo .
  define variable v-mem-qnty      as decimal   no-undo .
  define variable v-split-count   as integer   no-undo .
  define variable v-pl-code       like ub.pl-gds.pl-code no-undo .

  define buffer buf_doc-pl   for ub.doc-pl .
  define buffer buf_parts    for ub.parts  .
  define buffer buf_doc-pl-attr for ub.doc-pl-attr .

  do
  on error undo, return error return-value
  :
    if not( is-petrolium = yes
            and is-pieces = no
          )
    then do: /* НЕ топливо */
      if v-work-with-qnty = "doc":U then do:
        if vScanMark <> "" then do:
          { str/rsrv-out.i "doc" "input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty" "is-marks" vScanMark}
        end.
        else do:  
        { str/rsrv-out.i "doc" "input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty" }
      end.
      end.
      else do:
        if vScanMark <> "" then do:
          { str/rsrv-out.i "fact" "input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty" "is-marks" vScanMark}
        end.
      else do:
        { str/rsrv-out.i "fact" "input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty" }
      end.
      end.
    end. /* НЕ топливо */
    else do: /* топливо */
      if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then do: /* #2366, для прихода внутреннего */
          for each buf_parts exclusive-lock /* ищем партию, на которой применили сброс (в накладной) и востанавливаем факт кол-во в указанное в диалоге */
              where buf_parts.out-code = t-doc.doc-code
              and buf_parts.obj-type = t-doc.obj-type
              and buf_parts.obj-code = t-doc.obj-code
              and buf_parts.artic = buf_goods.artic
              and buf_parts.prod-type = buf_goods.prod-type
              and buf_parts.prod-code = buf_goods.prod-code
              and buf_parts.fact-qnty = 0:
                buf_parts.fact-qnty = buf_parts.qnty.
          end.
      end. 
      /* разрезервируем ранее зарезервированный товар по местам хранения */
      if v-work-with-qnty = "fact-doc":U then do:
        assign
          v-chg-qnty = 0.0
        .
        for each buf_parts
          where buf_parts.out-code  = t-doc.doc-code
            and buf_parts.obj-type  = t-doc.obj-type
            and buf_parts.obj-code  = t-doc.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
            and buf_parts.pl-code   = 0
        on error undo, return error substitute( "&1 (rsrv-doc-pl). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          if v-work-with-qnty = "doc":U then do:
            assign
              v-chg-qnty = v-chg-qnty + (- buf_parts.qnty)
            .
          end.
          else do:
            assign
              v-chg-qnty = v-chg-qnty + (- buf_parts.fact-qnty)
            .
          end.
        end.
        if v-chg-qnty <> 0.0 then do:
          assign
            v-mem-qnty = v-chg-qnty
          .
          run trg/rsrv-dtl.p
            ( input        ParParentProc
            , input        substitute( '&1,&2=&3,&4=3'
                                      , {&rsrv-dtl_action_reserv}
                                      , {&rsrv-dtl_pl-code}
                                      , 0
                                      , {&rsrv-dtl_negative-check}
                                      )
            , buffer       ub.gds-dtl
            , input-output v-chg-qnty
            , input-output ub.doc-line.price-base
            , input-output ub.doc-line.price-rubl
            , input        -1
            , input if node-type begins 'scan-mark' then entry(2,node-type,{&delim-key}) else vScanMark
            ) no-error .
          if error-status :error then do:
            undo, return error substitute( '&1&2&3', return-value, {&new-line}, error-status :get-message( 1 ) ) .
          end.
          if v-chg-qnty <> v-mem-qnty then do:
            undo, return error substitute( 'Не удалось снять резервы по товару &1 без места хранения.', buf_goods.gds-code ) .
          end.
        end.
      end.

      for each buf_doc-pl
        where buf_doc-pl.obj-type = t-doc.obj-type
          and buf_doc-pl.obj-code = t-doc.obj-code
          and buf_doc-pl.out-code = t-doc.doc-code
          and buf_doc-pl.gds-code = buf_goods.gds-code
      on error undo, return error substitute( "&1 (rsrv-doc-pl). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        if v-work-with-qnty = "doc":U then do:
          assign
            v-chg-qnty = (- buf_doc-pl.doc-qnty)
          .
        end.
        else do:
          assign
            v-chg-qnty = (- buf_doc-pl.fact-qnty)
          .
        end.
        if v-chg-qnty <> 0.0 then do:
          assign
            v-mem-qnty = v-chg-qnty
          .
          run trg/rsrv-dtl.p
            ( input        ParParentProc
            , input        substitute( '&1,&2=&3,&4=3'
                                      , {&rsrv-dtl_action_reserv}
                                      , {&rsrv-dtl_pl-code}
                                      , buf_doc-pl.pl-code
                                      , {&rsrv-dtl_negative-check}
                                      )
            , buffer       ub.gds-dtl
            , input-output v-chg-qnty
            , input-output ub.doc-line.price-base
            , input-output ub.doc-line.price-rubl
            , input        -1
            , input if node-type begins 'scan-mark' then entry(2,node-type,{&delim-key}) else vScanMark
            ) no-error .
          if error-status :error then do:
            undo, return error substitute( '&1&2&3', return-value, {&new-line}, error-status :get-message( 1 ) ) .
          end.
          if v-chg-qnty <> v-mem-qnty then do:
            undo, return error substitute( 'Не удалось снять резервы по товару &1 на месте хранения &2 .', buf_goods.gds-code, buf_doc-pl.pl-code ) .
          end.
        end.
        delete buf_doc-pl .
      end.
      if v-work-with-qnty = "doc":U then do:
        { str/rsrv-out.i "doc" "input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty" "not-rsrv" }
      end.
      else do:
        { str/rsrv-out.i "fact" "input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty" "not-rsrv"  }
      end.

      /* разобъем партии если это требуется */
      if v-work-with-qnty = "fact-doc":U then do:
        /* сначала склеим, если ранее разбивали */
        for each buf_parts
          where buf_parts.out-code  = t-doc.doc-code
            and buf_parts.obj-type  = t-doc.obj-type
            and buf_parts.obj-code  = t-doc.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
        on error undo, return error substitute( "&1 (rsrv-doc-pl). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          if num-entries( buf_parts.part-code, {&part-split} ) > 1 then do:
            run trg/partjoin.p
              ( input buf_parts.obj-type
               ,input buf_parts.obj-code
               ,input buf_parts.artic
               ,input buf_parts.prod-type
               ,input buf_parts.prod-code
               ,input buf_parts.in-code
               ,input buf_parts.out-code
               ,input buf_parts.part-code
              ) no-error.
            if error-status :error then do:
              undo, return error substitute( "&1 (rsrv-out). Не удалось объединить партию с номером &2!&3&4&3&5", vss-workfile, buf_parts.part-code, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
            end.
          end.
        end.

        for each tt-parts-all
        on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          delete tt-parts-all .
        end.
        for each tt-parts-split
        on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          delete tt-parts-split .
        end.
        assign
          v-chg-doc-qnty = 0.0
        .
        for each buf_parts
          where buf_parts.out-code  = t-doc.doc-code
            and buf_parts.obj-type  = t-doc.obj-type
            and buf_parts.obj-code  = t-doc.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
        on error undo, return error substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          assign
            buf_parts.cli-qnty = buf_parts.qnty / buf_parts.cli-base-rate
            v-chg-doc-qnty     = v-chg-doc-qnty + buf_parts.qnty
          .
          create tt-parts-all .
          buffer-copy buf_parts to tt-parts-all .
        end.
        for each tt-doc-pl
        on error undo, return error substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          assign
            v-mem-qnty = tt-doc-pl.doc-qnty
          .
          block_parts-search:
          do while v-mem-qnty > 0
          on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            find first tt-parts-all no-error .
            if not available tt-parts-all then do:
              leave block_parts-search.
            end.
            find first buf_parts
              where buf_parts.obj-type  = tt-parts-all.obj-type
                and buf_parts.obj-code  = tt-parts-all.obj-code
                and buf_parts.artic     = tt-parts-all.artic
                and buf_parts.prod-type = tt-parts-all.prod-type
                and buf_parts.prod-code = tt-parts-all.prod-code
                and buf_parts.in-code   = tt-parts-all.in-code
                and buf_parts.out-code  = tt-parts-all.out-code
                and buf_parts.part-code = tt-parts-all.part-code
              .
            if tt-parts-all.qnty <= v-mem-qnty then do:
              create tt-parts-split .
              buffer-copy tt-parts-all to tt-parts-split
                assign
                  tt-parts-split.pl-code   = tt-doc-pl.pl-code
                  tt-parts-split.qnty      = tt-parts-all.qnty
                  tt-parts-split.cli-qnty  = tt-parts-all.cli-qnty
                .
              assign
                v-mem-qnty     = v-mem-qnty     - tt-parts-all.qnty
                v-chg-doc-qnty = v-chg-doc-qnty - tt-parts-all.qnty
              .
              delete tt-parts-all .
            end.
            else do:
              create tt-parts-split .
              buffer-copy tt-parts-all to tt-parts-split
                assign
                  tt-parts-split.pl-code   = tt-doc-pl.pl-code
                  tt-parts-split.qnty      = v-mem-qnty
                  tt-parts-split.cli-qnty  = tt-parts-split.qnty / buf_parts.cli-base-rate /* * buf_parts.cli-qnty / buf_parts.qnty*/
              .
              assign
                tt-parts-all.qnty      = tt-parts-all.qnty      - tt-parts-split.qnty
                tt-parts-all.cli-qnty  = tt-parts-all.cli-qnty  - tt-parts-split.cli-qnty
                v-mem-qnty             = 0.0
                v-chg-doc-qnty         = v-chg-doc-qnty         - tt-parts-split.qnty
              .
            end.
          end.
        end.
        for each tt-parts-all
        on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          delete tt-parts-all .
        end.
        if v-chg-doc-qnty <> 0.0 then do:
          undo, return error substitute( '&1 (rsrv-out). &2 &3 не распределено по местам хранения!', vss-workfile, v-chg-doc-qnty, buf_goods.unit-base ).
        end.

        for each buf_parts exclusive-lock
          where buf_parts.out-code  = t-doc.doc-code
            and buf_parts.obj-type  = t-doc.obj-type
            and buf_parts.obj-code  = t-doc.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
        on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          for each temp-parts-qnty
          on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            delete temp-parts-qnty .
          end.
          assign
            v-split-count = 0
          .
          for each tt-parts-split
            where tt-parts-split.obj-type  = buf_parts.obj-type
              and tt-parts-split.obj-code  = buf_parts.obj-code
              and tt-parts-split.artic     = buf_parts.artic
              and tt-parts-split.prod-type = buf_parts.prod-type
              and tt-parts-split.prod-code = buf_parts.prod-code
              and tt-parts-split.in-code   = buf_parts.in-code
              and tt-parts-split.out-code  = buf_parts.out-code
              and tt-parts-split.part-code = buf_parts.part-code
          on error undo, return error  substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
          :
            assign
              v-split-count = v-split-count + 1
              v-pl-code     = tt-parts-split.pl-code
            .
            create temp-parts-qnty.
            assign
              temp-parts-qnty.cli-qnty  = tt-parts-split.cli-qnty
              temp-parts-qnty.qnty      = tt-parts-split.qnty
              temp-parts-qnty.fact-qnty = tt-parts-split.fact-qnty
              temp-parts-qnty.pl-code   = tt-parts-split.pl-code
            .
            delete tt-parts-split .
          end.
          if v-split-count >= 1 and not t-doc.doc-code matches "*=*" then do:
            /* загонять туда надо и партии, которые разбивать не нужно,                          */
            /* но нужно, чтобы менялся part-code для сохранения уникальности партии в резервуаре */
            run trg/partsplt.p
              ( input buf_parts.obj-type
               ,input buf_parts.obj-code
               ,input buf_parts.artic
               ,input buf_parts.prod-type
               ,input buf_parts.prod-code
               ,input buf_parts.in-code
               ,input buf_parts.out-code
               ,input buf_parts.part-code
               ,input table temp-parts-qnty
              ) no-error.
            if error-status :error then do:
              undo, return error substitute( "&1 (rsrv-out). Не удалось разбить партию с номером &2!&3&4&3&5", vss-workfile, buf_parts.part-code, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
            end.
          end.
        end.
        for each temp-parts-qnty
        on error undo, return error substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
          delete temp-parts-qnty .
        end.
      end. /* if v-work-with-qnty = "fact-doc":U then do: */

      /* зарезервируем товар по местам хранения */
      for each tt-doc-pl
      on error undo, return error substitute( "&1 (rsrv-out). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      :
        create buf_doc-pl .
        buffer-copy tt-doc-pl to buf_doc-pl .
        
        if t-doc.ext-doc-type = {&TDEDT_Ras_Object} /*and tt-doc-pl.pl-code2 <> ? and tt-doc-pl.pl-code2 <> 0*/
        then do :
            find first  buf_doc-pl-attr exclusive-lock
                  where buf_doc-pl-attr.obj-type    = tt-doc-pl.obj-type
                    and buf_doc-pl-attr.obj-code    = tt-doc-pl.obj-code
                    and buf_doc-pl-attr.pl-code     = tt-doc-pl.pl-code
                    and buf_doc-pl-attr.out-code    = tt-doc-pl.out-code            
                    and buf_doc-pl-attr.gds-code    = tt-doc-pl.gds-code
                    and buf_doc-pl-attr.attr-code   = 'place2' no-error .
            if not available buf_doc-pl-attr then do :
                create buf_doc-pl-attr .
                assign
                    buf_doc-pl-attr.obj-type = tt-doc-pl.obj-type
                    buf_doc-pl-attr.obj-code = tt-doc-pl.obj-code 
                    buf_doc-pl-attr.pl-code  = tt-doc-pl.pl-code
                    buf_doc-pl-attr.out-code = tt-doc-pl.out-code 
                    buf_doc-pl-attr.gds-code = tt-doc-pl.gds-code
                    buf_doc-pl-attr.attr-code = 'place2'
                .
            end.
            assign
                buf_doc-pl-attr.attr-value = string(tt-doc-pl.pl-code2)
            .
        end.

        if v-work-with-qnty = "doc":U then do:
          assign
            v-chg-qnty = tt-doc-pl.doc-qnty
          .
        end.
        else do:
          assign
            v-chg-qnty = tt-doc-pl.fact-qnty
          .
        end.
        assign
          v-mem-qnty = v-chg-qnty
        .
        run trg/rsrv-dtl.p
          ( input        ParParentProc
          , input        substitute( '&1,&2=&3,&4=3'
                                    , {&rsrv-dtl_action_reserv}
                                    , {&rsrv-dtl_pl-code}
                                    , tt-doc-pl.pl-code
                                    , {&rsrv-dtl_negative-check}
                                    )
          , buffer       ub.gds-dtl
          , input-output v-chg-qnty
          , input-output ub.doc-line.price-base
          , input-output ub.doc-line.price-rubl
          , input        -1
          , input if node-type begins 'scan-mark' then entry(2,node-type,{&delim-key}) else vScanMark
          ) no-error .
        if error-status :error then do:
          undo, return error substitute( '&1&2&3', return-value, {&new-line}, error-status :get-message( 1 ) ) .
        end.
        if v-chg-qnty <> v-mem-qnty then do:
          undo, return error substitute( 'По товару &1 на месте хранения &2 возможно зарезервировать только &3 &4.'
                                         ,buf_goods.gds-code
                                         ,tt-doc-pl.pl-code
                                         ,v-chg-qnty
                                         ,buf_goods.unit-base
                                       ) .
        end.
      end. /* for each tt-doc-pl */

      if v-work-with-qnty = "doc":U then do:
        { str/rsrv-out.i "doc" "input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty" "not-rsrv" }
      end.
      else do:
        { str/rsrv-out.i "fact" "input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty" "not-rsrv"  }
      end.

      if v-work-with-qnty = "doc":U then do:
        assign
          v-qnty-kg = ub.gds-dtl.doc-qnty * ub.doc-line.doc-density
          v-density = ub.doc-line.doc-density
        .
      end.
      else do:
        assign
          v-fact-qnty-kg = ub.gds-dtl.fact-qnty * ub.doc-line.fact-density
          v-density      = ub.doc-line.fact-density
        .
      end.

      { str/corinvln.i
        ub.doc-line.doc-code
        ub.doc-line.artic
        ub.doc-line.prod-type
        ub.doc-line.prod-code
        v-price-rubl-kg
        v-price-base-kg
        0
        0
        "( if v-work-with-qnty = 'doc':U then v-qnty-kg else v-fact-qnty-kg )"
        v-density
        rec-inv-line
      }
    end. /* топливо */
  end. /* on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on d-out-prt 
PROCEDURE UI-on :
define variable v-data-type     as character no-undo.
  define variable calc_after-qnty as decimal no-undo.
  define variable isRightEditPrice as logical no-undo.
  disable all  with frame {&FRAME-NAME}.

  if prt-mode <> {&lookup} then do:
   enable  b-exit b-quit b-help b-arch b-history with frame {&FRAME-NAME}.
  end.
  else do:
    /* просмотр */
    hide    b-exit in frame {&FRAME-NAME}.
    b-quit:label = "&Выход".
    b-quit:column = 1.
    enable  b-quit b-help b-arch b-history with frame {&FRAME-NAME}.
  end.

  run tax-name in this-procedure ( input {&road-tax}, output varroad-tax-label ) no-error.
  assign
    ub.doc-line.road-tax :label in frame {&FRAME-NAME} = varroad-tax-label
  .

  RUN proc-case .

  assign
    tot-rubl = ub.gds-dtl.fact-qnty * ( ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl )
    tot-base = ub.gds-dtl.fact-qnty * ( ub.gds-dtl.price-base - ub.gds-dtl.discnt-base )
  .
  { gbl/barcodcr.i
      buf_goods.gds-code
      ub.gds-dtl.prt-code
      "''"
      "''"
      buf_goods.unit-base
      1
      varis-new
      b-c-b
  }
  display b-c-b.b-code with frame {&FRAME-NAME}.
  find first bf_prod-bc where bf_prod-bc.b-code = b-c-b.b-code no-lock no-error.
  if available bf_prod-bc then do:
    assign
      varprod-bc-str = bf_prod-bc.b-str.
    display varprod-bc-str with frame {&frame-name}.
  end.

  display tot-rubl tot-base base-curr ub.clients.obj-name ub.gds-prt.f-name
          ub.gds-dtl.artic ub.gds-dtl.prod-code ub.gds-dtl.prod-type
          ub.gds-dtl.price-rubl ub.gds-dtl.price-base
          buf_goods.gds-name buf_goods.unit-base buf_goods.qnty-cart ub.doc-line.road-tax with frame {&FRAME-NAME}.
  if ptrlprop-expptrl = {&calc-petrol-weight} then do:
    display
      buf_goods.unit-cli @ buf_goods.unit-base
    with frame {&FRAME-NAME}.
  end.
  if input frame {&FRAME-NAME} ub.gds-dtl.doc-qnty = 0
    and input frame {&FRAME-NAME} ub.gds-dtl.fact-qnty = 0
  then do:
    display
      ub.gds-dtl.doc-qnty
      ub.gds-dtl.fact-qnty
      with frame {&FRAME-NAME}.
  end.

  if ub.gds-prt.upper-code = buf_goods.prt-root then do:
    hide
      ub.gds-prt.f-name in frame {&FRAME-NAME}.
  end.
  if v-work-with-qnty = "doc":U then do:
    hide
      ub.gds-dtl.fact-qnty
      v-fact-qnty-kg
      in frame {&FRAME-NAME}
    .
  end.

if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} then do:
  IF ( ub.gds-dtl.price-rubl:VISIBLE AND ub.gds-dtl.price-rubl:sensitive ) OR
     ( ub.gds-dtl.price-base:VISIBLE AND ub.gds-dtl.price-base:sensitive )
     THEN
     ENABLE r-price with frame {&FRAME-NAME}.
  if prt-mode <> {&lookup} and v-is-return and vBackSale then
  do:
  /* BTS-2021 Для док-тов возврата расхода внешнего по договору со схемой возврата «Обратная продажа»  */
  /* и наличием права «actn_expense_price» даем редактировать цену                                     */
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_expense_price'
      {&cntxt-object}
      t-doc.host-code
      t-doc.obj-type
      t-doc.obj-code
      0
      0
      0
      false
      isRightEditPrice
    }
    if isRightEditPrice then
      enable ub.gds-dtl.price-rubl with frame {&FRAME-NAME}.  
  end.
end.
else if prt-mode <> {&lookup} and t-doc.ext-doc-type = {&TDEDT_Pri_Perem} and is-petrolium and not is-pieces then do:
    /* #2901, разрешаем редактирование, если применили сброс факт количеств */    
    enable
        ub.gds-dtl.fact-qnty
        v-fact-qnty-kg
        with frame {&FRAME-NAME}
    .
end.
else do:
   hide r-price in frame {&FRAME-NAME}.
end.

if t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} then do:
  if prt-mode <> {&lookup} then enable c-reason with frame {&frame-name} .
  else disable c-reason with frame {&frame-name} .
end.
else do:
  c-reason:hidden in frame {&frame-name} .
end.
g-image:SENSITIVE = g-image:VISIBLE.
if prt-mode <> {&lookup} and ub.gds-dtl.price-corr = 0 then do :
  define variable v-pr as decimal   no-undo .
  { str/prslnew.i
    "run"
    pr-genmrg
    pr-naklvalue
    t-doc.doc-code
    ub.gds-dtl.artic
    ub.gds-dtl.prod-type
    ub.gds-dtl.prod-code
    ub.gds-dtl.price-rubl
    ub.gds-dtl.price-base
    ub.gds-dtl.price-rubl
    ub.gds-dtl.price-base
    v-pr
    no-error
    }

    display v-pr @ ub.gds-dtl.new-price-sale with frame {&frame-name} .
    assign ub.gds-dtl.new-price-sale.

end.
run new-price-s in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-doc-line-attr d-out-prt 
PROCEDURE write-doc-line-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code       as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-attr-code      as character        no-undo.
define input parameter p-attr-value     as character        no-undo.

define buffer buf_doc-line-attr       for ub.doc-line-attr.

do
for buf_doc-line-attr
on error undo, return error
:
    find first buf_doc-line-attr exclusive-lock
         where buf_doc-line-attr.doc-code     = p-doc-code
           and buf_doc-line-attr.gds-code     = p-gds-code
           and buf_doc-line-attr.attr-code    = p-attr-code
    no-error.
    if available buf_doc-line-attr
    then do:
        if p-attr-value = ?
        or p-attr-value = "":U
        then do:
            delete buf_doc-line-attr.
        end.
        else do:
            assign
                buf_doc-line-attr.attr-value = p-attr-value
            .
        end.
    end.
    else do:
        if p-attr-value = ?
        or p-attr-value = "":U
        then do:
          /* do nothing */
          assign
            p-attr-value = '':U
          no-error .
        end.
        else do:
            create buf_doc-line-attr.
            assign
                buf_doc-line-attr.doc-code     = p-doc-code
                buf_doc-line-attr.gds-code     = p-gds-code
                buf_doc-line-attr.attr-code    = p-attr-code
                buf_doc-line-attr.attr-value   = p-attr-value
            no-error .
        end.
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp d-out-prt 
PROCEDURE init-temp :
  /* --------------------------------------------------------------------
                      Purpose:     ENABLE the User Interface
                      Parameters:  <none>
                      Notes:       Here we display/view/enable the widgets in the
                                   user-interface.  In addition, OPEN all queries
                                   associated with each FRAME and BROWSE.
                                   These statements here are based on the "Other
                                   Settings" section of the widget Property Sheets.
                       -------------------------------------------------------------------- */

  define variable ii          as integer   no-undo .
  define variable reason      as character no-undo .
  define variable reason-code as character no-undo .
  define variable reason-name as character no-undo .
  define buffer buf_trn-reason for ub.trn-reason .
    { gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-nakl_par} }

  for first thbjattr_thbj-attr no-lock where thbjattr_thbj-attr.prop-code = {&attr-nakl_par_reasons-write-off}:
    reason-code  = thbjattr_thbj-attr.property-value-character .
  end.
  if reason-code <> "" then 
  do:
    do ii = 1 to num-entries(reason-code):
      reason-name = "" .
      for first buf_trn-reason no-lock where buf_trn-reason.reason-code = integer(entry(ii,reason-code)):
        reason-name = buf_trn-reason.reason-name .
      end.  
      reason = reason + {&comma-char} + reason-name + {&comma-char} + entry(ii,reason-code) .
    end.
    reason = trim(reason,{&comma-char}).
    ASSIGN
      c-reason:LIST-ITEM-PAIRS  in frame {&frame-name} = reason .
  end.
  if prt-mode <> {&add-def} then do:
        find first ub.doc-line-attr no-lock where ub.doc-line-attr.doc-code = t-doc.doc-code and
        ub.doc-line-attr.gds-code = buf_goods.gds-code and
        ub.doc-line-attr.attr-code = "reasonSpisan" no-error .
        if available (ub.doc-line-attr) then do:
          c-reason = integer (doc-line-attr.attr-value) .
          display c-reason with frame {&frame-name} .
        end.  
    end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
