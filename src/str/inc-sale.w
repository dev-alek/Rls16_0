&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-chk


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-trn-doc NO-UNDO LIKE ub.trn-doc.
DEFINE NEW SHARED BUFFER X_chk-doc FOR ub.chk-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-chk
/*------------------------------------------------------------------------

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inc-sale.w $
$Archive: str/inc-sale.w $

Закачка чеков в продажу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/17/05
Author: Bakhtadze Natalya
Creation date: 09/17/05

Author:  Черных В.
Created: 21.10.98

------------------------------------------------------------------------ */

/* ***************************  Definitions  ************************** */
define input parameter parparentproc AS WIDGET-HANDLE no-undo.
define input parameter p-mode as character no-undo .
/*update для закачки чеков delete для показа после удаления чеков*/
define input parameter p-host-code like ub.clients.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-augetres as logical no-undo .
define input parameter p-is-tpsi-obj as logical no-undo .
define parameter buffer ink-doc for ub.inkas.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: inc-sale.w $":u .
define variable vss-archive     as character no-undo init "$Archive: str/inc-sale.w $":u .
define variable vss-description as character no-undo init "Закачка чеков в продажу" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i }
{ str/lib-trn.i  }
{ cmp/operlist.i }
{ cmp/library.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ str/lib-def.i  }
{ str/trdcalib.i }
{ str/inkas-ps.i }
{ str/tpsidoc.i SHARED }
{ gbl/thbj-def.i }

define buffer buf_sysconf for ub.sysconf.
DEFINE                BUFFER ret-doc    FOR ub.trn-doc.
DEFINE                BUFFER r-doc      FOR ub.chk-doc.
DEFINE                BUFFER r-gds      FOR ub.chk-gds.
define variable v-ref-rec  as recid no-undo .
define variable v-base-code  like ub.sysconf.base-code no-undo .
define variable v-cash-pay   like ub.sysconf.cash-pay  no-undo .
define variable temp-qnty like ub.gds-dtl.fact-qnty no-undo .
define variable temp-qnty-prts like ub.gds-dtl.fact-qnty no-undo .
define variable prev-code like ub.chk-gds.doc-code no-undo .
define variable for-shift-name AS character.
define variable for-shift-num like ub.chk-doc.shift-num.
define variable for-shift-date like ub.chk-doc.shift-date.
/*использовать смены на кассе для данного объекта*/
define variable cas-shft as logical no-undo init no.
define variable one-sale-per-day as logical no-undo .
/*использовать смены для данного объекта*/
define variable l-shift-on as logical no-undo init no.
/*в продажу закачивать чеки только по одному выбранному курсу*/
define variable one-curs as logical no-undo init no.
/*откуда были взяты курсы валют из спула или BO*/
define variable cas-curs as logical no-undo init no.
/*откуда брать цены в накладную - из чека или из прайс-листа*/
define variable prcl-spl as logical no-undo init no.
/*тип алгоритма для размаза*/
define variable pay-gds-algo as character no-undo .
/*код дорожного налога*/
define variable rdtaxcd  as INTEGER                  no-undo.
/*код акциза*/
define variable exctaxcd  as INTEGER                  no-undo.
/*фактор дор налога*/
define variable factorrt as decimal no-undo.
/*типы ед изм для дор нал*/
/*код стеклопосуды*/
define variable btltaxcd  as INTEGER                  no-undo.
define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable cursh like ub.curr-shop.exch-rate init 0.
define variable cursh-scale like ub.curr-shop.exch-rate.
define variable cursh-date1 like ub.curr-shop.exch-date.
define variable cursh-date2 like ub.curr-shop.exch-date.
define variable cursh-time1 like ub.curr-shop.exch-time.
define variable cursh-time2 like ub.curr-shop.exch-time.
define variable v-curr-r-b as character no-undo .
define variable is-wth as logical   no-undo .
define variable glog as logical no-undo .
define variable old-doc-date   like ub.inkas.doc-date no-undo .
define variable old-shift-name AS character  no-undo .
define variable old-shift-date like ub.inkas.shift-date no-undo .
define variable old-shift-num  like ub.inkas.shift-num  no-undo .
define variable new-shift-name as character  no-undo .
define variable new-doc-date   like ub.inkas.doc-date no-undo .
define variable new-shift-date like ub.inkas.shift-date no-undo .
define variable new-shift-num  like ub.inkas.shift-num  no-undo .
define variable filter-point as character no-undo init "inc-sale":U .
define variable filter-point0 as character no-undo init "inc-sale":U .
define variable filter-label as character no-undo init "Закачка чеков в продажу":U .
define variable filter-label0 as character no-undo init "Закачка чеков в продажу":U .

define variable sort-column-name as character no-undo .
define variable v-filter-rec    as character no-undo .
define variable v-filter-name   as character no-undo .
define variable v-where-phrase  as character no-undo .
define variable v-sort-phrase   as character no-undo .
define variable v-where-phrase-rus  as character no-undo .
define variable v-sort-phrase-rus   as character no-undo .
define variable title0 as character no-undo init "Формирование  ОТЧЕТА  О  ПРОДАЖЕ".
define variable v-rid-list as character no-undo .
/*можно редактировать дату курс чеков и фильтр потому что НЕТ ЧЕКОВ В ПРОДАЖЕ*/
define variable v-can-edit-header as logical no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type as character no-undo .
define variable ps-where-rus as character no-undo .
define variable ind as integer no-undo .
define variable v-shift-name               as character no-undo.
define variable v-shift-name-num           as character no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .


define buffer lock-batchprocess for ub.batchprocess .
define buffer buf_sale-doc for ub.sale-doc.
DEFINE BUFFER cli-buf FOR ub.clients .

&SCOPED-DEFINE sale-doc-kind buf_sale-doc.doc-kind

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-chk
&Scoped-define BROWSE-NAME br-saledoc
&Scoped-define QUERY-NAME QUERY-chk-doc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_sale-doc tt-trn-doc X_chk-doc

/* Definitions for BROWSE br-saledoc                                    */
&Scoped-define FIELDS-IN-QUERY-br-saledoc buf_sale-doc.doc-code {&sale-doc-name} Buf_sale-doc.chr-office ENTRY(lookup(buf_sale-doc.ext-doc-type , {&comma-char} + {&TDEDT_List} + {&comma-char} + {&manufacturing}) , {&comma-char} + {&TDEDT_List-full} + {&comma-char} + {&manufacturing}) (buf_sale-doc.cli-type + string(buf_sale-doc.cli-code)) buf_sale-doc.cli-name buf_sale-doc.chk-amount buf_sale-doc.gds-amount buf_sale-doc.fact-qnty buf_sale-doc.doc-qnty buf_sale-doc.tot-lines buf_sale-doc.tot-dtl /* msign main-doc in-inkas FILLED */
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-saledoc
&Scoped-define SELF-NAME br-saledoc
&Scoped-define QUERY-STRING-br-saledoc FOR EACH buf_sale-doc WHERE buf_sale-doc.inkas-code = ink-doc.inkas-code
&Scoped-define OPEN-QUERY-br-saledoc OPEN QUERY {&SELF-NAME} FOR EACH buf_sale-doc WHERE buf_sale-doc.inkas-code = ink-doc.inkas-code.
&Scoped-define TABLES-IN-QUERY-br-saledoc buf_sale-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-saledoc buf_sale-doc


/* Definitions for DIALOG-BOX d-chk                                     */
&Scoped-define FIELDS-IN-QUERY-d-chk tt-trn-doc.wrkr tt-trn-doc.agnt ~
tt-trn-doc.boss
&Scoped-define ENABLED-FIELDS-IN-QUERY-d-chk tt-trn-doc.wrkr ~
tt-trn-doc.agnt tt-trn-doc.boss
&Scoped-define ENABLED-TABLES-IN-QUERY-d-chk tt-trn-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-d-chk tt-trn-doc
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-chk ~
    ~{&OPEN-QUERY-br-saledoc}
&Scoped-define QUERY-STRING-d-chk FOR EACH tt-trn-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-d-chk OPEN QUERY d-chk FOR EACH tt-trn-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-chk tt-trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-d-chk tt-trn-doc


/* Definitions for QUERY QUERY-chk-doc                                  */
&Scoped-define SELF-NAME QUERY-chk-doc
&Scoped-define QUERY-STRING-QUERY-chk-doc FOR EACH X_chk-doc       WHERE X_chk-doc.obj-type = p-obj-type  AND X_chk-doc.obj-code = p-obj-code  AND X_chk-doc.out-code = ? NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-QUERY-chk-doc OPEN QUERY {&SELF-NAME} FOR EACH X_chk-doc       WHERE X_chk-doc.obj-type = p-obj-type  AND X_chk-doc.obj-code = p-obj-code  AND X_chk-doc.out-code = ? NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-QUERY-chk-doc X_chk-doc
&Scoped-define FIRST-TABLE-IN-QUERY-QUERY-chk-doc X_chk-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.chk-doc.shift-date ub.chk-doc.chk-num ~
ub.chk-doc.office ub.chk-doc.pay-desk ub.chk-doc.cashier ~
ub.chk-doc.sales-man ub.chk-doc.doc-code ub.chk-doc.netto ~
ub.chk-doc.sub-discnt tt-trn-doc.wrkr ub.chk-doc.tot-doc ub.chk-doc.discnt ~
tt-trn-doc.agnt tt-trn-doc.boss
&Scoped-define ENABLED-TABLES ub.chk-doc tt-trn-doc
&Scoped-define FIRST-ENABLED-TABLE ub.chk-doc
&Scoped-define SECOND-ENABLED-TABLE tt-trn-doc
&Scoped-Define ENABLED-OBJECTS b-exit RECT-1 b-quit B-sch b-doc b-help ~
RS-get-method br-saledoc chk-amount gds-amount line-out dtl-out ~
nf-chk-amount nf-gds-amount line-ret dtl-ret f-shift-name f-shift-num time_ ~
f-chk-type r-wrkr r-agnt r-boss wrkr-name agnt-name curs-mes boss-name
&Scoped-Define DISPLAYED-FIELDS ub.chk-doc.shift-date ub.chk-doc.chk-num ~
ub.chk-doc.office ub.chk-doc.pay-desk ub.chk-doc.cashier ~
ub.chk-doc.sales-man ub.chk-doc.doc-code ub.chk-doc.netto ~
ub.chk-doc.sub-discnt tt-trn-doc.wrkr ub.chk-doc.tot-doc ub.chk-doc.discnt ~
tt-trn-doc.agnt tt-trn-doc.boss
&Scoped-define DISPLAYED-TABLES ub.chk-doc tt-trn-doc
&Scoped-define FIRST-DISPLAYED-TABLE ub.chk-doc
&Scoped-define SECOND-DISPLAYED-TABLE tt-trn-doc
&Scoped-Define DISPLAYED-OBJECTS RS-get-method chk-amount gds-amount ~
line-out dtl-out nf-chk-amount nf-gds-amount line-ret dtl-ret f-shift-name ~
f-shift-num time_ f-chk-type wrkr-name agnt-name curs-mes boss-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-doc
     LABEL "&Документ"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 11 BY 1.

DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .87.

DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .87.

DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .87.

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE chk-amount AS INTEGER FORMAT "->>>9":U INITIAL 0
     LABEL "ВСЕГО Чеков по продаже"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.

DEFINE VARIABLE curs-mes AS CHARACTER FORMAT "X(70)":U
      VIEW-AS TEXT
     SIZE 50 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE dtl-out AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Признаков"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.

DEFINE VARIABLE dtl-ret AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Признаков"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.

DEFINE VARIABLE f-chk-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 26 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-shift-name AS CHARACTER FORMAT "X(3)":U
     LABEL "№ смены"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-shift-num AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Пор. смены"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE gds-amount AS INTEGER FORMAT "->>>>9":U INITIAL 0
     LABEL "строк чеков"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.

DEFINE VARIABLE line-out AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Товаров"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.

DEFINE VARIABLE line-ret AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Товаров"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.

DEFINE VARIABLE nf-chk-amount AS INTEGER FORMAT "->>>9":U INITIAL 0
     LABEL "невключенных в документы"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.

DEFINE VARIABLE nf-gds-amount AS INTEGER FORMAT "->>>>9":U INITIAL 0
     LABEL "строк чеков"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.

DEFINE VARIABLE time_ AS CHARACTER FORMAT "x(8)"
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 10.3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-get-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все свободные чеки по объекту с заданными условиями", "inc-salr",
"Чеки выборочно", "chk-docs"
     SIZE 70.5 BY 1.77 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 96 BY 3.77
     BGCOLOR 8 FGCOLOR 0 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-saledoc FOR
      buf_sale-doc SCROLLING.

DEFINE QUERY d-chk FOR
      tt-trn-doc SCROLLING.

DEFINE NEW SHARED QUERY QUERY-chk-doc FOR
                X_chk-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-saledoc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-saledoc d-chk _FREEFORM
  QUERY br-saledoc DISPLAY
      buf_sale-doc.doc-code COLUMN-LABEL "№ док-та"
{&sale-doc-name} COLUMN-LABEL "Операция"  format "X(45)" WIDTH 20
Buf_sale-doc.chr-office COLUMN-LABEL "Т/y" FORMAT "X(1)"
ENTRY(lookup(buf_sale-doc.ext-doc-type
             , {&comma-char} + {&TDEDT_List} + {&comma-char} + {&manufacturing})
      , {&comma-char} + {&TDEDT_List-full}  + {&comma-char} + {&manufacturing}) COLUMN-LABEL "Тип док-та"   format "X(20)"
(buf_sale-doc.cli-type + string(buf_sale-doc.cli-code)) COLUMN-LABEL "Тип/код контрагента" FORMAT "X(12)"
buf_sale-doc.cli-name COLUMN-LABEL "Контрагент" FORMAT "X(25)"
buf_sale-doc.chk-amount COLUMN-LABEL "Чеков"
buf_sale-doc.gds-amount COLUMN-LABEL "Строк чеков"
buf_sale-doc.fact-qnty  COLUMN-LABEL "Кол-во по включ.чекам!/факт. кол-во"
buf_sale-doc.doc-qnty   COLUMN-LABEL "Кол-во зарезервир.!/док. кол-во"
buf_sale-doc.tot-lines  COLUMN-LABEL "Товаров"
buf_sale-doc.tot-dtl    COLUMN-LABEL "Признаков"
/*
msign
main-doc
in-inkas
 FILLED
 */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.5
         FONT 4 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-chk
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-sch AT ROW 1 COL 41
     b-doc AT ROW 1 COL 61
     b-help AT ROW 1 COL 95
     RS-get-method AT ROW 2.27 COL 7 NO-LABEL
     br-saledoc AT ROW 4.27 COL 1
     chk-amount AT ROW 10.5 COL 26.5 COLON-ALIGNED
     gds-amount AT ROW 10.5 COL 45.3 COLON-ALIGNED
     line-out AT ROW 10.5 COL 72 COLON-ALIGNED
     dtl-out AT ROW 10.5 COL 89 COLON-ALIGNED
     nf-chk-amount AT ROW 12.5 COL 26.5 COLON-ALIGNED
     nf-gds-amount AT ROW 12.5 COL 45.3 COLON-ALIGNED
     line-ret AT ROW 12.5 COL 72 COLON-ALIGNED
     dtl-ret AT ROW 12.5 COL 89 COLON-ALIGNED
     ub.chk-doc.shift-date AT ROW 14 COL 44 COLON-ALIGNED
          LABEL "&Дата смены (учета)" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          BGCOLOR 8 FGCOLOR 4
     f-shift-name AT ROW 14 COL 67 COLON-ALIGNED
     f-shift-num AT ROW 14 COL 84.5 COLON-ALIGNED
     ub.chk-doc.chk-num AT ROW 15.13 COL 7 COLON-ALIGNED FORMAT "->>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 7.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     time_ AT ROW 15.13 COL 37.5 COLON-ALIGNED
     ub.chk-doc.office AT ROW 15.2 COL 60.3 COLON-ALIGNED FORMAT "X(8)"
          VIEW-AS FILL-IN
          SIZE 10.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     f-chk-type AT ROW 15.2 COL 71 COLON-ALIGNED NO-LABEL
     ub.chk-doc.pay-desk AT ROW 16.37 COL 7 COLON-ALIGNED FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.cashier AT ROW 16.37 COL 21 COLON-ALIGNED FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 6.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.sales-man AT ROW 16.37 COL 37.5 COLON-ALIGNED FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 6.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.doc-code AT ROW 16.47 COL 50.5 COLON-ALIGNED
          LABEL "Номер" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.netto AT ROW 17.5 COL 15.8 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.sub-discnt AT ROW 17.57 COL 50.6 COLON-ALIGNED
          LABEL "Сумма списания" FORMAT "->>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 14.9 BY 1
          BGCOLOR 8 FGCOLOR 4
     tt-trn-doc.wrkr AT ROW 18.13 COL 71.5 COLON-ALIGNED WIDGET-ID 18
          LABEL "К&л-к"
          VIEW-AS FILL-IN
          SIZE 9.8 BY 1
     r-wrkr AT ROW 18.27 COL 96.1 WIDGET-ID 14
     ub.chk-doc.tot-doc AT ROW 18.77 COL 15.8 COLON-ALIGNED
          LABEL "Сумма товарная" FORMAT "->>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 19.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.discnt AT ROW 18.83 COL 50.6 COLON-ALIGNED FORMAT "->>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 14.9 BY 1
          BGCOLOR 8 FGCOLOR 4
     tt-trn-doc.agnt AT ROW 19.13 COL 71.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "И&сп."
          VIEW-AS FILL-IN
          SIZE 9.8 BY 1
     r-agnt AT ROW 19.27 COL 96 WIDGET-ID 10
     tt-trn-doc.boss AT ROW 20.13 COL 71.5 COLON-ALIGNED WIDGET-ID 6
          LABEL "&М-р"
          VIEW-AS FILL-IN
          SIZE 9.8 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME d-chk
     r-boss AT ROW 20.27 COL 96 WIDGET-ID 12
     wrkr-name AT ROW 18.13 COL 82 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     agnt-name AT ROW 19.13 COL 82 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     curs-mes AT ROW 20 COL 2 COLON-ALIGNED NO-LABEL
     boss-name AT ROW 20.13 COL 82 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     "ВОЗВРАТ" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 12.5 COL 56.5
          BGCOLOR 3 FGCOLOR 15
     "РАСХОД" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 10.5 COL 56.5
          BGCOLOR 3 FGCOLOR 15
     "Проставлять в док-ты:" VIEW-AS TEXT
          SIZE 22 BY 1 AT ROW 17 COL 77 WIDGET-ID 16
          FGCOLOR 4
     RECT-1 AT ROW 10 COL 1.5
     SPACE(1.74) SKIP(7.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Формирование  ОТЧЕТА  О  ПРОДАЖЕ":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-trn-doc T "?" NO-UNDO ub trn-doc
      TABLE: X_chk-doc B "NEW SHARED" ? ub chk-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-chk
   FRAME-NAME                                                           */
/* BROWSE-TAB br-saledoc RS-get-method d-chk */
ASSIGN
       FRAME d-chk:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN tt-trn-doc.agnt IN FRAME d-chk
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-trn-doc.boss IN FRAME d-chk
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.chk-doc.cashier IN FRAME d-chk
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.chk-doc.chk-num IN FRAME d-chk
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.chk-doc.discnt IN FRAME d-chk
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.chk-doc.doc-code IN FRAME d-chk
   EXP-LABEL EXP-FORMAT                                                 */
ASSIGN
       f-shift-name:HIDDEN IN FRAME d-chk           = TRUE.

ASSIGN
       f-shift-num:HIDDEN IN FRAME d-chk           = TRUE.

/* SETTINGS FOR FILL-IN ub.chk-doc.office IN FRAME d-chk
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.chk-doc.pay-desk IN FRAME d-chk
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.chk-doc.sales-man IN FRAME d-chk
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN ub.chk-doc.shift-date IN FRAME d-chk
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN ub.chk-doc.sub-discnt IN FRAME d-chk
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN ub.chk-doc.tot-doc IN FRAME d-chk
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-trn-doc.wrkr IN FRAME d-chk
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-saledoc
/* Query rebuild information for BROWSE br-saledoc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_sale-doc WHERE buf_sale-doc.inkas-code = ink-doc.inkas-code.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-saledoc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-chk
/* Query rebuild information for DIALOG-BOX d-chk
     _TblList          = "Temp-Tables.tt-trn-doc"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-chk */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK QUERY QUERY-chk-doc
/* Query rebuild information for QUERY QUERY-chk-doc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_chk-doc
      WHERE X_chk-doc.obj-type = p-obj-type
 AND X_chk-doc.obj-code = p-obj-code
 AND X_chk-doc.out-code = ? NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE NEW SHARED QUERY QUERY-chk-doc FOR
                X_chk-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Design-Parent    is DIALOG-BOX d-chk @ ( 2.43 , 3.3 )
*/  /* QUERY QUERY-chk-doc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-chk d-chk
ON END-ERROR OF FRAME d-chk /* Формирование  ОТЧЕТА  О  ПРОДАЖЕ */
DO:
    apply "choose" to b-quit .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-trn-doc.agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.agnt d-chk
ON LEAVE OF tt-trn-doc.agnt IN FRAME d-chk /* Исп. */
DO:
  if input frame {&frame-name} tt-trn-doc.agnt <> tt-trn-doc.agnt then do:
    run local-psn-chk in this-procedure ("agnt", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.agnt d-chk
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.agnt IN FRAME d-chk /* Исп. */
OR RETURN OF tt-trn-doc.agnt IN FRAME {&frame-name} DO:
  run local-psn-chk in this-procedure ("agnt", "ret-mouse").
  apply "entry" to tt-trn-doc.boss in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc d-chk
ON CHOOSE OF b-doc IN FRAME d-chk /* Документ */
DO:
define variable v-doc-type as character no-undo .
define variable v-doc-code as character no-undo .
define variable glog as logical no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
  assign
  v-doc-type = buf_sale-doc.doc-type
  v-doc-code = buf_sale-doc.doc-code
 .
  if v-doc-type = {&manufacturing} then do:
    find first buf_fbr-doc no-lock where
              buf_fbr-doc.doc-code = v-doc-code  no-error .
    if not available buf_fbr-doc then do:
      message
      substitute("Не найден документ производства с № &1", v-doc-code)
      view-as alert-box error .
      return no-apply.
    end.
    run str/fbr-lkp.p (
                  input parparentproc
                , input recid(buf_fbr-doc)).
  end.
  else do:
    run str/showdoc.p
            (input parparentproc
            ,input v-doc-code
            ,input ""
            ,input ""
            ,input 0
            ,input ?
            ).
 end.
  APPLY "ENTRY" TO  br-saledoc.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-chk
ON CHOOSE OF b-exit IN FRAME d-chk /* Ввод  */
DO:
    DO /*TRANSACTION*/ on ERROR undo, return no-apply
                                  on STOP undo, return no-apply  :
        RUN IncProcStart in this-procedure ( input yes) .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-chk
ON CHOOSE OF b-quit IN FRAME d-chk /* Отмена */
DO:
  if p-mode = {&update} then return "cancell":U .
  else return '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch d-chk
ON CHOOSE OF B-sch IN FRAME d-chk /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-trn-doc.boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.boss d-chk
ON LEAVE OF tt-trn-doc.boss IN FRAME d-chk /* М-р */
DO:
  if input frame {&frame-name} tt-trn-doc.boss <> tt-trn-doc.boss then do:
    run local-psn-chk in this-procedure ("boss", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.boss d-chk
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.boss IN FRAME d-chk /* М-р */
OR RETURN OF tt-trn-doc.boss IN FRAME {&frame-name} DO:
  run local-psn-chk in this-procedure ("boss", "ret-mouse").
  apply "entry" to tt-trn-doc.boss in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-shift-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-shift-name d-chk
ON LEAVE OF f-shift-name IN FRAME d-chk /* № смены */
DO:
  /*проверка на интерегер - случая когда l-shift-on = no cash-shft = yes*/
  run proc-shift-name in this-procedure no-error .
  if error-status:error then do:
    return no-apply.
  end.
  display
  integer(f-shift-name) @ f-shift-num
  with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-shift-name d-chk
ON VALUE-CHANGED OF f-shift-name IN FRAME d-chk /* № смены */
DO:
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
  assign f-shift-name .
  assign
  v-shift-name  = f-shift-name
  f-shift-num  = integer(f-shift-name)
  ink-doc.shift-num = f-shift-num
  ink-doc.shift-date = ink-doc.doc-date
  ink-doc.shift-name = f-shift-name
  .
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = ink-doc.inkas-code
     and  buf_sale-doc.order > 0,
          first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    buf_trn-doc.shift-num = f-shift-num
    buf_trn-doc.shift-date = ink-doc.doc-date
    buf_trn-doc.shift-name = f-shift-name
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME QUERY-chk-doc
&Scoped-define SELF-NAME r-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-agnt d-chk
ON CHOOSE OF r-agnt IN FRAME d-chk /* r-acc */
DO:
  RUN local-psn-chk in this-procedure ("agnt", "button").
  apply "entry" to tt-trn-doc.agnt in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-boss d-chk
ON CHOOSE OF r-boss IN FRAME d-chk /* r-acc */
DO:
    RUN local-psn-chk in this-procedure ("boss", "button").
  apply "entry" to tt-trn-doc.boss in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-wrkr d-chk
ON CHOOSE OF r-wrkr IN FRAME d-chk /* r-acc */
DO:
  RUN local-psn-chk in this-procedure ("wrkr", "button").
  apply "entry" to tt-trn-doc.wrkr in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-get-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-get-method d-chk
ON VALUE-CHANGED OF RS-get-method IN FRAME d-chk
DO:
   RUN IncProcStart in this-procedure ( input no).
   ASSIGN
   rs-get-method.
   CASE rs-get-method:
     WHEN "chk-docs" THEN DO:
        if not ink-doc.is-mand-sale-filter then
        DISABLE
        b-sch
        with FRAME {&FRAME-NAME}.
        ASSIGN
        v-rid-list = "":U.
        run str/chk-docs.w (
                         input parparentproc
                        ,input ('b-sel,b-mark':U )
                        ,input "to-sale"
                        ,input ?
                        ,input ink-doc.obj-type
                        ,input ink-doc.obj-code
                        ,input ink-doc.inkas-code
                        ,input '':U
                        ,input 0 /*p-pay-desk*/
                        ,input  ?
                        ,input  ?
                        ,input 0
                        ,output v-rid-list) no-error.
         IF v-rid-list = "":U  THEN DO:
             ASSIGN
             rs-get-method = "inc-salr".
             ENABLE
             b-sch when (not ink-doc.is-mand-sale-filter or NOT can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code ))
             with frame {&frame-name} .
             DISPLAY rs-get-method
             with frame {&frame-name}
             .
             RETURN NO-APPLY.
         END.
       END.
       WHEN "inc-salr":U THEN DO:
           v-rid-list = "":U.
           ENABLE
           b-sch when (NOT ink-doc.is-mand-sale-filter or can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code ))
           with FRAME {&FRAME-NAME}.
      END.
   END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.chk-doc.shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.chk-doc.shift-date d-chk
ON RETURN OF ub.chk-doc.shift-date IN FRAME d-chk /* Дата смены (учета) */
DO:
    apply "choose" to b-exit in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-trn-doc.wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.wrkr d-chk
ON LEAVE OF tt-trn-doc.wrkr IN FRAME d-chk /* Кл-к */
DO:
  if input frame {&frame-name} tt-trn-doc.wrkr <> tt-trn-doc.wrkr then do:
    run local-psn-chk in this-procedure ("wrkr", "leave").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.wrkr d-chk
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.wrkr IN FRAME d-chk /* Кл-к */
OR RETURN OF tt-trn-doc.wrkr IN FRAME {&frame-name} DO:
  run local-psn-chk in this-procedure ("wrkr", "ret-mouse").
  apply "entry" to tt-trn-doc.agnt in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-saledoc
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-chk


/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/setfltnm.i }
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

if p-mode = {&update} then do:
  assign
  rdtaxcd  = integer({&road-tax-code})
  exctaxcd = integer({&excise-tax-code})
  btltaxcd = integer({&road-tax-code}).

  { gbl/curr-r-b.i
    v-curr-r-b
  }

  define variable v-is-wth as character no-undo .
  { gbl/conf-rd.i
    "'is-wth':u"
    "'':u"
    "'':u"
    0
    "'':u"
    "'':u"
    "'':u"
    no
    v-is-wth
    par-type
    no-error
  }
  if error-status :error
  or par-type <> {&type-log}
  or v-is-wth <> 'yes':u
  then do:
    assign
    is-wth = no
    .
  end.
  else do:
    is-wth = yes.
  end.

  { gbl/getsect.i run "''" 0 {&attr-nakl_par} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'factorrt' then factorrt = thbjattr_thbj-attr.property-value-integer .
  end.
  empty temp-table thbjattr_thbj-attr.

  if rdtaxcd > 0 then do:
      FIND FIRST ub.tax No-LOCK WHERE ub.tax.tax-code = rdtaxcd No-ERROR.
      if not avail ub.tax then do:
          message "Не найден дорожный налог!" view-as alert-box ERROR.
          return error.
      end.
  end.

  if exctaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = exctaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден акциз!" view-as alert-box ERROR.
          return error.
      end.
  end.

  if btltaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = btltaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден налог (доп.компонента для цены) стеклопосуды!" view-as alert-box ERROR.
          return error.
      end.
  end.
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.

  run adm/shattri.p (
      input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  {&attr-get-chk}
      ,input  "":U /*p-param-code*/
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output v-param-type
      , INPUT-OUTPUT table-handle v-tth
      ) no-error .

  IF error-status:error then do:
     message
     substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-obj-type
              , p-obj-code
              , {&new-line}
              , error-status:get-message(1)
              , return-value )
     view-as alert-box error .
     undo, return error .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-get-chk}
        and thbjattr_thbj-attr.prop-code = {&attr-get-chk_cas-shft} no-error.
  if available thbjattr_thbj-attr then do:
    /*найдем параметр - использовать смены на кассе или нет*/
    cas-shft = thbjattr_thbj-attr.property-value-logical.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-get-chk}
        and thbjattr_thbj-attr.prop-code = {&attr-get-chk_cas-curs} no-error.
  if available thbjattr_thbj-attr then do:
    /*курс брать из чеков?*/
    cas-curs = thbjattr_thbj-attr.property-value-logical.
  end.
  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'shift-on=request'"
    l-shift-on
  }

  if l-shift-on and not cas-shft then do:
          message "Внимание! На текущем объекте требуется использование смен" skip
              "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
              view-as alert-box ERROR.
      return ERROR.
  end.

  /*найдем параметр - чеки по одному выбранному курсу или нет*/
  /*найдем параметр - откуда брать цены на товар в накладную - из чека или из прайс-листа*/
  /*по умолчанию из чека*/
  run adm/shattri.p (
      input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  {&attr-autosale}
      ,input  "":U /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF error-status:error then do:
     message
     substitute("Ошибка при получении опций работы с продажей НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-obj-type
              , p-obj-code
              , {&new-line}
              , error-status:get-message(1)
              , return-value )
     view-as alert-box error .
     undo, return error .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_prcl-spl} no-error.
  if available thbjattr_thbj-attr then do:
    prcl-spl = thbjattr_thbj-attr.property-value-logical.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_one-curs} no-error.
  if available thbjattr_thbj-attr then do:
    /*курс брать из чеков?*/
    one-curs = thbjattr_thbj-attr.property-value-logical.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_one-sale-per-day} no-error.
  if available thbjattr_thbj-attr then do:
    assign
    one-sale-per-day = thbjattr_thbj-attr.property-value-logical
    .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_pay-gds-algo} no-error.
  if available thbjattr_thbj-attr then do:
    assign
    pay-gds-algo = thbjattr_thbj-attr.property-value-character
    .
  end.
end. /*if p-mode = {&update}*/


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  for each tt-trn-doc:
    delete tt-trn-doc.
  end.
  create tt-trn-doc.
/* ink-doc already available */
  if p-mode = {&update} then do:
   if ink-doc.status_ = {&fact} then do:
      message
      "Продажа уже закрыта !!"
      view-as alert-box error .
      undo main-block, return error .
    end.
    if ink-doc.is-mand-sale-filter then do:
      _lock-inc-sale:
      DO while ind < 100 :
        run gbl/lock-prc.p
          (input {&lock-prc-inc-sale}
          ,input p-obj-code
          ,input 0
          ,input 0
          ,input p-obj-type
          ,input ""
          ,input ""
          ,input (
                  "Код объекта" + ",,," +
                  "Тип объекта" +  ",,,Закачка чеков в продажу"
                )
          ,input no
          ,buffer lock-batchprocess
          ) no-error .
        if not error-status:error then do:
          leave _lock-inc-sale.
        end.
        message
        substitute("Для объекта &1&2 включена настройка <В продажу чеки только по фильтру (если задан)>,&3" +
                  "поэтому одновременно на одном магазине можно работать только с одной продажей&3" +
                  "В настоящий момент ресурс закачки чеков в продажу занят&3" +
                  "Попробуйте позже"
                  , p-obj-type
                  , p-obj-code
                  , {&new-line})
        view-as alert-box WARNING.
        undo main-block, return error .
      end.
    end.

    find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code.
    { gbl/basecode.i p-host-code v-base-code }
    FIND FIRST ub.shop WHERE ub.shop.obj-code = p-obj-code NO-LOCK .
    FIND FIRST ub.trn-doc WHERE ub.trn-doc.doc-code = ink-doc.inkas-code exclusive.
    FIND FIRST ret-doc WHERE ret-doc.doc-code = ub.trn-doc.out-code exclusive no-error .
    assign
    chk-amount = ink-doc.num-chk
    line-out = 0
    dtl-out = 0
    line-ret = 0
    dtl-ret = 0
    gds-amount = 0
    nf-chk-amount = 0
    nf-gds-amount = 0
    .
    ASSIGN
    tt-trn-doc.wrkr = trn-doc.wrkr
    tt-trn-doc.agnt = trn-doc.agnt
    tt-trn-doc.boss = trn-doc.boss
    .
  end. /*if p-mode = {&update}*/
  if p-mode = {&lookup} then do:
    find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code.
    { gbl/basecode.i p-host-code v-base-code }
    FIND FIRST shop WHERE shop.obj-code = p-obj-code NO-LOCK .
    FIND FIRST trn-doc no-lock WHERE trn-doc.doc-code = ink-doc.inkas-code.
    FIND FIRST ret-doc no-lock WHERE ret-doc.doc-code = trn-doc.out-code no-error .
    ASSIGN
    tt-trn-doc.wrkr = trn-doc.wrkr
    tt-trn-doc.agnt = trn-doc.agnt
    tt-trn-doc.boss = trn-doc.boss
    .
  end.
  if ink-doc.is-mand-sale-filter then do:
    /*получим значение фильтра и в Myenable покажем его*/
    assign
    v-filter-name = ink-doc.sale-filter-name
    v-where-phrase = ink-doc.sale-filter
    v-where-phrase-rus = ink-doc.sale-filter-rus
    .
  end.
  if can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code ) then do:
    FIND FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code use-index sale
    NO-LOCK .
    assign
    time_ = string( ub.chk-doc.chk-time, "HH:MM" )
    cursh = ub.trn-doc.exch-rate
    cursh-scale = ub.trn-doc.exch-scale
    cursh-date1 = ub.chk-doc.chk-date
    cursh-time1 = ub.chk-doc.chk-time
    curs-mes = "В продажу чеки с курсом баз.вал. = " +
                        string(ub.trn-doc.exch-rate / ub.trn-doc.exch-scale, ">>,>>9.9999").
    run get-inkas-ps in this-procedure (
                                        buffer ink-doc
                                      , output chk-amount
                                      , output gds-amount
                                      , output line-out
                                      , output dtl-out
                                      , output line-ret
                                      , output dtl-ret
                                      , output nf-chk-amount
                                      , output nf-gds-amount
                                      , output ps-where-rus
                                      ).
  end.
  assign
  old-doc-date   =  ink-doc.doc-date
  old-shift-date =  ink-doc.shift-date
  old-shift-num  =  ink-doc.shift-num
  old-shift-nAME  =  ink-doc.shift-nAME
  .
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus chk-doc.shift-date .
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-filter d-chk
PROCEDURE check-filter :
define variable v-dup as logical no-undo .
define buffer buf_inkas for ub.inkas.

do
on error undo, return error
:
  for each buf_Inkas no-lock where
          buf_inkas.obj-type = ink-doc.obj-type
      AND buf_inkas.obj-code = ink-doc.obj-code
      AND buf_inkas.status_  = {&g___new}
      and recid(buf_inkas) <> recid(ink-doc)
      :
    if buf_inkas.sale-filter = v-where-phrase then do:
      if cas-shft then do:
        if buf_inkas.shift-date = ink-doc.shift-date
        and buf_inkas.shift-nAME = ink-doc.shift-nAME then do:
          assign
          v-dup = yes.
          /* пропускаем, если не та дата и смена*/
        end.
      end. /*cas-shft*/
      else do:
        if ub.shop.day-only then do:
          if buf_inkas.shift-date = ink-doc.shift-date then do:
            assign
            v-dup = yes.
          end.
          /* пропускаем, если не та дата */
        end.
        else do:
          assign
          v-dup = yes.
        end.
      end. /*not cas-shft*/
      if v-dup then do:
        message
        substitute("Для объекта &1&2 включена настройка <В продажу чеки только по фильтру (если задан)>,&3" +
                  "и найден отчет о продаже с №&4, полученный по фильтру&3<&5>&3" +
                  "поэтому ВЫ НЕ МОЖЕТЕ УСТАНОВИТЬ ФИЛЬТР &3<&5>&3 для продажи &6&3"
                  , ink-doc.obj-type
                  , ink-doc.obj-code
                  , {&new-line}
                  , buf_inkas.inkas-code
                  , v-where-phrase-rus
                  , ink-doc.inkas-code
                  )
        view-as alert-box ERROR.
        undo, return error.
      end.
    end.
  end.
end. /*doe*/

end procedure. /* check-filter */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-chk  _DEFAULT-DISABLE
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
  HIDE FRAME d-chk.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-chk d-chk
PROCEDURE display-chk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-chk-amount AS INTEGER NO-UNDO.
define input parameter p-nf-chk-amount as integer no-undo .
&scop receipt-code string(X_chk-doc.chk-type)
DISPLAY
p-chk-amount @ chk-amount
p-nf-chk-amount @ nf-chk-amount
with frame {&frame-name}.
if available X_chk-doc then
DISPLAY
X_chk-doc.cashier @ ub.chk-doc.cashier
X_chk-doc.shift-date @ ub.chk-doc.shift-date
X_chk-doc.chk-num    @ ub.chk-doc.chk-num
string( X_chk-doc.chk-time, "HH:MM" ) @ time_
X_chk-doc.office  @ ub.chk-doc.office
X_chk-doc.discnt @ ub.chk-doc.discnt
X_chk-doc.netto  @ ub.chk-doc.netto
X_chk-doc.doc-code  @ ub.chk-doc.doc-code
X_chk-doc.sub-discnt  @ ub.chk-doc.sub-discnt
X_chk-doc.pay-desk  @ ub.chk-doc.pay-desk
X_chk-doc.sales-man @ ub.chk-doc.sales-man
X_chk-doc.tot-doc   @ ub.chk-doc.tot-doc
{&receipt-name}  @ f-chk-type
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-ink-doc d-chk
PROCEDURE display-ink-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-gds-amount  as integer no-undo .
define input parameter p-nf-gds-amount  as integer no-undo .
define input parameter p-line-out    as integer no-undo .
define input parameter p-line-ret    as integer no-undo .
define input parameter p-dtl-out     as integer no-undo .
define input parameter p-dtl-ret     as integer no-undo .

DISPLAY
p-dtl-out @ dtl-out
p-dtl-ret @ dtl-ret
p-line-out @ line-out
p-line-ret @ line-ret
p-gds-amount @ gds-amount
p-nf-gds-amount @ nf-gds-amount
with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Enable_UI d-chk  _DEFAULT-ENABLE
PROCEDURE Enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY RS-get-method chk-amount gds-amount line-out dtl-out nf-chk-amount
          nf-gds-amount line-ret dtl-ret f-shift-name f-shift-num time_
          f-chk-type wrkr-name agnt-name curs-mes boss-name
      WITH FRAME d-chk.
  IF AVAILABLE tt-trn-doc THEN
    DISPLAY tt-trn-doc.wrkr tt-trn-doc.agnt tt-trn-doc.boss
      WITH FRAME d-chk.
  IF AVAILABLE ub.chk-doc THEN
    DISPLAY ub.chk-doc.shift-date ub.chk-doc.chk-num ub.chk-doc.office
          ub.chk-doc.pay-desk ub.chk-doc.cashier ub.chk-doc.sales-man
          ub.chk-doc.doc-code ub.chk-doc.netto ub.chk-doc.sub-discnt
          ub.chk-doc.tot-doc ub.chk-doc.discnt
      WITH FRAME d-chk.
  ENABLE b-exit RECT-1 b-quit B-sch b-doc b-help RS-get-method br-saledoc
         chk-amount gds-amount line-out dtl-out nf-chk-amount nf-gds-amount
         line-ret dtl-ret ub.chk-doc.shift-date f-shift-name f-shift-num
         ub.chk-doc.chk-num time_ ub.chk-doc.office f-chk-type
         ub.chk-doc.pay-desk ub.chk-doc.cashier ub.chk-doc.sales-man
         ub.chk-doc.doc-code ub.chk-doc.netto ub.chk-doc.sub-discnt
         tt-trn-doc.wrkr r-wrkr ub.chk-doc.tot-doc ub.chk-doc.discnt
         tt-trn-doc.agnt r-agnt tt-trn-doc.boss r-boss wrkr-name agnt-name
         curs-mes boss-name
      WITH FRAME d-chk.
  {&OPEN-BROWSERS-IN-QUERY-d-chk}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE IncProc d-chk
PROCEDURE IncProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-ii     as integer no-undo .
define variable v-ii-ok  as integer no-undo .
define variable v-rc-ii as integer no-undo .
define variable v-rc-max as integer no-undo .
DEFINE VARIABLE v-query-prepare AS CHARACTER NO-UNDO.
define variable v-error-status as logical no-undo .
define variable v-error-status-message as character no-undo .
if rs-get-method = "inc-salr":U
or ink-doc.is-mand-sale-filter
then do:
  ASSIGN
  v-query-prepare = substitute("for each X_chk-doc no-lock where ":U +
                            "X_chk-doc.obj-type = '&1'":U +
                            " AND X_chk-doc.obj-code = &2":U +
                            " AND X_chk-doc.out-code = ? ", p-obj-type, p-obj-code).
  if cas-shft then do:
    ASSIGN
    v-query-prepare = v-query-prepare +
                    substitute(" AND X_chk-doc.shift-date = &1 AND X_chk-doc.shift-num = &2"
                              , string(ink-doc.shift-date, "99/99/9999")
                              , ink-doc.shift-num).
    /* пропускаем, если не та дата */
  end. /*cas-shft*/
  else do:
      if ub.shop.day-only then do:
          ASSIGN
          v-query-prepare = v-query-prepare +
                          substitute(" AND X_chk-doc.shift-date = &1", string(ink-doc.shift-date, "99/99/9999")).
                          .
        /* пропускаем, если не та дата */
      end.
      else do:
          ASSIGN
          v-query-prepare = v-query-prepare +
                          substitute(" AND X_chk-doc.shift-date <= &1", string(ink-doc.shift-date, "99/99/9999")).
        /* пропускаем, если не та дата */
      end.
  end. /*not cas-shft*/
  if rs-get-method = "chk-docs":U then do:
    assign
    v-query-prepare = v-query-prepare + substitute(" AND lookup(string(recid(X_chk-doc)), '&1') > 0 ", v-rid-list)
    .
  end.
  assign
  glog =
  QUERY query-chk-doc:QUERY-PREPARE(v-query-prepare + v-where-phrase) No-error.
  IF not glog
  THEN DO:
      MESSAGE
      "Ошибка - неверно выбран или построен ФИЛЬТР" skip
      error-status:get-message(1) skip
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.

  END.

  assign
  glog = QUERY query-chk-doc:query-OPEN() NO-ERROR.
  IF not glog
  THEN DO:
      MESSAGE
      "Неверно выбран или построен ФИЛЬТР"
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  ASSIGN
  glog = QUERY query-chk-doc:GET-FIRST(no-LOCK) NO-ERROR.
  IF not glog THEN DO:
    message
    "Нет чеков, удовлетворяющих условиям закачки в продажу" skip
    view-as alert-box WARNING .
    RETURN.
  END.
  ASSIGN
  glog = QUERY query-chk-doc:GET-FIRST(exclusive-LOCK, no-wait) NO-ERROR.
  do while locked (X_chk-doc ) and available X_chk-doc:
     glog = QUERY query-chk-doc:GET-NEXT(exclusive-LOCK, no-wait) NO-ERROR.
  end.
end.
else do:
  assign
  v-rc-max = num-entries(v-rid-list).
  _v-rc:
  do while v-rc-ii < v-rc-max:
    assign
    v-rc-ii = v-rc-ii + 1
    .
    find first X_chk-doc exclusive-lock where
              recid(X_chk-doc) = integer(entry(v-rc-ii, v-rid-list))  no-wait no-error.
    if locked X_chk-doc or not available X_chk-doc then do:
       next _v-rc.
    end.
    else leave _v-rc.
  end.
  if not available X_chk-doc
  or locked(X_chk-doc) then do:
    message
    "Ни один из выбранных Вами чеков не может быть сейчас закачан в продажу" skip
    "Возможно они заняты другим пользователем"
    view-as alert-box Warning.
    return.
  end.
end.
run str/inc-salr.p (
                 input  parparentproc
                ,input  this-procedure
                ,input-output v-ii
                ,input-output v-ii-ok
                ,input (IF rs-get-method = "chk-docs":U and ink-doc.is-mand-sale-filter THEN no ELSE (if ink-doc.sale-filter = "":U then no else yes))
                ,input v-where-phrase-rus
                ,INPUT (IF rs-get-method = "chk-docs":U and not ink-doc.is-mand-sale-filter THEN v-rid-list ELSE "":U)
                ,input  p-obj-type
                ,input  p-obj-code
                ,input  v-curr-r-b
                ,input  is-wth
                ,input  cas-shft
                ,input  one-curs
                ,input  cas-curs
                ,input  cursh
                ,input  cursh-scale
                ,input  prcl-spl
                ,input  pay-gds-algo
                ,input  rdtaxcd
                ,input  exctaxcd
                ,input  factorrt
                ,input  btltaxcd
                ,input  gds-amount
                ,input  chk-amount
                ,input  line-out
                ,input  line-ret
                ,input  dtl-out
                ,input  dtl-ret
                ,input  nf-chk-amount
                ,input  nf-gds-amount
                ,input  shop.day-only
                ,input  old-doc-date
                ,input  old-shift-date
                ,input  old-shift-num
                ,input  new-doc-date
                ,input  new-shift-date
                ,input  new-shift-num
                ,buffer ink-doc
                ,buffer ub.trn-doc
                ,buffer ret-doc
                ,buffer buf_sysconf
    ) NO-ERROR.
assign
v-error-status = error-status:error
v-error-status-message = error-status:get-message(1)
.
enable
br-saledoc
with frame {&frame-name} .
{&OPEN-QUERY-br-saledoc}
if not p-augetres then do:
  if v-ii = 0 then do:
    if v-error-status then
    message
    "Произошла ошибка при закачке чеков в продажу" skip
    v-error-status-message skip
    return-value
    view-as alert-box .
    else
    message
    "Нет чеков, удовлетворяющих условиям закачки в продажу" skip
    view-as alert-box WARNING .
  end.
  else do:
    message
    substitute("Просмотрено &1 чеков, успешно закачано в продажу &2", v-ii, v-ii-ok)
    view-as alert-box WARNING .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE IncProcStart d-chk
PROCEDURE IncProcStart :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-run as logical no-undo .
if p-mode <> {&update} then return.
define variable v-deleted as logical no-undo .
DEFINE VARIABLE screen-shift-num AS INTEGER NO-UNDO.
DEFINE VARIABLE screen-shift-name AS character NO-UNDO.
DEFINE VARIABLE screen-shift-date AS date NO-UNDO.
define variable v-dopi as integer no-undo .

define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.

ASSIGN
screen-shift-num = input frame {&frame-name} f-shift-num
screen-shift-name = input frame {&frame-name} f-shift-name
screen-shift-date = input frame {&frame-name} ub.chk-doc.shift-date
.
if screen-shift-date <> ink-doc.doc-date OR
(cas-shft AND screen-shift-name <> ink-doc.shift-name) then do:
  glog = yes.
  message substitute("Вы поменяли предложенную дату отчета о продаже&1&2" +
                     "Вы хотите, чтобы в отчет попали чеки &3 &4 &5?"
                      ,(if cas-shft then "  И/ИЛИ № смены отчета о продаже"  else "" )
                      ,{&NEW-LINE}
                      ,(if ub.shop.day-only then "ЗА " else "ПО ")
                      ,string(screen-shift-date, "99/99/9999")
                      ,(if cas-shft
                        then SUBSTITUTE(" за смену № &1 &2"
                                          ,screen-shift-name
                                          ,(if screen-shift-num = integer(screen-shift-name)
                                            then screen-shift-name
                                            else (screen-shift-name + "(" +
                                                  string(screen-shift-num) + ")"
                                                 )
                                           )
                                        )
                          else "")
                       )
  view-as alert-box question buttons YES-NO update glog.
  if NOT glog then return error .
/*проверим а может уже есть продажа за данный день/смену?*/
  if one-sale-per-day then do:
    define variable v-shift-date as date no-undo .
    define variable v-shift-num as integer no-undo .
    define variable v-mes as character no-undo .
    define buffer buf_inkas for ub.inkas.
    v-shift-date = input frame {&frame-name} chk-doc.shift-date.
    v-shift-num = ink-doc.shift-num.
    if l-shift-on
    or cas-shft
    then do:
      find first buf_inkas no-lock where
                buf_inkas.obj-type =  ink-doc.obj-type
            and buf_inkas.obj-code =  ink-doc.obj-code
            and buf_inkas.shift-date = v-shift-date
            and buf_inkas.shift-num = v-shift-num
            no-error.
      if available buf_inkas then do:
        v-mes = substitute("Нельзя создать вторую продажу за смену &1 П. &2 - запрещено параметрами"
                          , string(v-shift-date, "99/99/9999")
                          , v-shift-num
                            ).

      end.
    end.
    else do:
      find first buf_inkas no-lock where
                buf_inkas.obj-type =  ink-doc.obj-type
            and buf_inkas.obj-code =  ink-doc.obj-code
            and buf_inkas.doc-date = v-shift-date no-error.
      if available buf_inkas then do:
        v-mes = substitute("Нельзя создать вторую продажу за день &1 - запрещено параметрами"
                          , string(v-shift-date, "99/99/9999")
                          ).

      end.
    end.
  end.
  if available buf_inkas then do:
    message v-mes view-as alert-box error .
    return error .
  end.
  assign
  ink-doc.doc-date = input frame {&frame-name} chk-doc.shift-date
  ink-doc.shift-date = ink-doc.doc-date
  ink-doc.shift-name = input frame {&frame-name} f-shift-name
  .
end. /*изменилась дата отчета*/
for each buf_sale-doc where
        buf_sale-doc.inkas-code = ink-doc.inkas-code
    and buf_sale-doc.order > 0,
    first buf_trn-doc exclusive-lock where
        buf_trn-doc.doc-code = buf_sale-doc.doc-code
ON ERROR UNDO, RETURN ERROR:
  assign
  buf_trn-doc.wrkr = tt-trn-doc.wrkr
  buf_trn-doc.agnt = tt-trn-doc.agnt
  buf_trn-doc.boss = tt-trn-doc.boss
  .
end. /*for each buf_sale-doc,*/
if cas-shft then do:
  assign
  v-dopi = integer(f-shift-name)
  no-error .
  if error-status:error
  or v-dopi <= 0
  or v-dopi > 99
  then do:
    message
    "Номер смены должен быть числом >0!" view-as alert-box ERROR.
    return error.
  end.
  ASSIGN f-shift-name.
  /*проверим f-shift-num f-shift-name*/
  assign
  f-shift-num = (if not l-shift-on then integer(f-shift-name) else f-shift-num)
  ink-doc.shift-num = f-shift-num
  ink-doc.shift-nAME = F-shift-nAME
  ink-doc.shift-date = ink-doc.doc-date
  new-doc-date      = ink-doc.doc-date
  new-shift-date      = ink-doc.shift-date
  new-shift-num       = ink-doc.shift-num
  new-shift-name       = ink-doc.shift-name
  .
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = ink-doc.inkas-code
      and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
          buf_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    buf_Trn-doc.shift-num = f-shift-num
    buf_Trn-doc.shift-name = f-shift-name
    buf_trn-doc.shift-date = ink-doc.doc-date
    .
  end. /*for each buf_sale-doc,*/
end. /*  if cas-shft then do:*/
else do:
  assign
  ink-doc.shift-num = 0
  ink-doc.shift-date = ink-doc.doc-date
  new-doc-date      = ink-doc.doc-date
  new-shift-date      = ink-doc.shift-date
  new-shift-num       = 0
  new-shift-name      = '':U
  .
end.
 if shop.day-only then do:
   if can-find( first chk-doc where chk-doc.obj-type = p-obj-type and
                                   chk-doc.obj-code = p-obj-code and
                                   chk-doc.out-code = ? and
                                    chk-doc.shift-date < ink-doc.doc-date ) then  do:
      glog = yes.
      message substitute("Имеются чеки за более раннюю дату,&1" +
                         "не включенные ни в один отчет о продаже.&1" +
                         "Не забудьте создать отчет о продаже&1" +
                         "и включить в него эти чеки.&1&1" +
                         "Продолжать ?"
                         ,{&new-line})
      view-as alert-box question buttons YES-NO update glog.
      if NOT glog then return error .
    end.
  end. /*if shop.day-only then do:*/
  else do:
    if can-find( first ub.inkas where ub.inkas.obj-type = p-obj-type and
                                 ub.inkas.obj-code = p-obj-code and
                                 ub.inkas.status_ = {&fact} and
                                 ub.inkas.doc-date > ink-doc.doc-date ) then do:
      glog = yes.
      message substitute("Уже имеется отчет о продаже, содержащий чеки,&1"  +
                         "дата которых БОЛЬШЕ указанной Вами.&1"  +
                         "Вы уверены, что в базе появились новые чеки ?&1"
                        , {&new-line})
      view-as alert-box question buttons YES-NO update glog.
      if NOT glog then  return error .
    end.
  end.
/*в отчете нет чеков*/
if NOT can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code )  then  do:
  FIND LAST ub.curr-shop WHERE ub.curr-shop.obj-type = p-obj-type and
                            ub.curr-shop.obj-code = p-obj-code and
                            ub.curr-shop.curr-code = v-base-code and
                            ub.curr-shop.exch-date <= ink-doc.doc-date NO-LOCK no-error.
  if available ub.curr-shop then do:
    /* ставим текущий магазинный курс - все лучше, чем складской */
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = buf_sale-doc.doc-code:
      assign
      buf_trn-doc.base-rate = curr-shop.exch-rate
      buf_trn-doc.base-scale = curr-shop.exch-scale
      .
      /*ЭТОГО ЧЕРНЫХ НЕ ПРЕДУСМОТРЕЛ*/
      if v-curr-r-b = {&r-b-base} then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end. /*for each buf_sale-doc,*/
  end. /* if available curr-shop then */
  else do: /* на всякий случай, чтобы избежать деления на 0,
             чего быть не должно : отсутствие курса проявляется еще при закачке чеков */
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = buf_sale-doc.doc-code:
      assign
      buf_trn-doc.base-rate   = 1
      buf_trn-doc.base-scale = 1
      .
      /*ЭТОГО ЧЕРНЫХ НЕ ПРЕДУСМОТРЕЛ*/
      if v-curr-r-b = {&r-b-base} then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end. /*for each buf_sale-doc,*/
    message substitute("Нет магазинного курса базовой валюты&1"  +
                      "на дату &2!&1" +
                      "Курс в накладных устанавливается равным 1."
                      ,{&NEW-LINE}
                      ,string(ink-doc.doc-date, "99/99/9999"))
    view-as alert-box error .
  end. /** на всякий случай, чтобы избежать деления на 0,*/
  if ink-doc.is-mand-sale-filter and p-run then do:
    /*предупреждение*/
    message
    substitute("Для объекта &1&2 включена настройка <В продажу чеки только по фильтру (если задан)>,&3" +
               "поэтому ТОЛЬКО СЕЙЧАС - пока продажа ПУСТА - ВЫ МОЖЕТЕ УСТАНОВИТЬ ИЛИ ИЗМЕНИТЬ ФИЛЬТР&3&3" +
               "УСТАНОВИТЬ или ИЗМЕНИТЬ ФИЛЬТР ?"
              , ink-doc.obj-type
              , ink-doc.obj-code
              , {&new-line}
               )
    view-as alert-box QUESTION buttons YES-NO update glog.
    if glog then do:
      run proc-b-sch in this-procedure.
    end.
    else do:
    end.
    if v-where-phrase = "":U then do:
      message
      substitute("Фильтр НЕ УСТАНОВЛЕН&1" +
                "Закачка чеков в продажу НЕВОЗМОЖНА"
                 ,{&NEW-LINE})
      view-as alert-box error .
      return error .
    end.
    run check-filter in this-procedure no-error .
    if error-status:error then undo, return error .
  end. /*if sale-filter and p-run then do:*/
  if one-curs then do:
      run str/selcursh.w (
                     input parparentproc,
                     input ink-doc.obj-type,
                     input ink-doc.obj-code,
                     input v-base-code,
                     input ink-doc.doc-date,
                    input shop.day-only,
                    input-output cursh,
                    output cursh-scale,
                    input-output cursh-date1,
                    output cursh-date2,
                    input-output cursh-time1,
                    output cursh-time2) no-error.
    if error-status:error or cursh = 0 then return error.
      message
      substitute("В продажу попадут чеки с курсом базовой валюты &1 (масштаб &2)"
                , cursh
                , cursh-scale)
      view-as alert-box .
  end. /*if one-curs*/
  assign
  ink-doc.shift-num = (if cas-shft then f-shift-num else 0)
  ink-doc.shift-name = (if cas-shft then f-shift-name else '')
  .
  for each buf_sale-doc where
           buf_sale-doc.inkas-code = ink-doc.inkas-code
      and  buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
          buf_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    buf_trn-doc.doc-date = ink-doc.doc-date
    buf_trn-doc.shift-num = (if cas-shft then f-shift-num else 0)
    buf_trn-doc.shift-name = (if cas-shft then f-shift-name else '')
    .
    If one-curs then do:
      assign
      buf_trn-doc.base-rate = cursh
      buf_trn-doc.base-scale = cursh-scale
      .

      if v-curr-r-b = {&r-b-base} then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end. /*If one-curs then do:*/
  end. /*for each buf_sale-doc,*/
end. /*if NOT can-find( FIRST chk-doc WHERE chk-doc.out-code = ink-doc.inkas-code )  then  do:*/
else do:
  FIND LAST curr-shop WHERE curr-shop.obj-type = p-obj-type and
                            curr-shop.obj-code = p-obj-code and
                            curr-shop.curr-code = v-base-code and
                            curr-shop.exch-date <= ink-doc.doc-date NO-LOCK no-error.
  if available curr-shop then do:
    /* ставим текущий магазинный курс - все лучше, чем складской */
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
         and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = buf_sale-doc.doc-code:
      assign
      buf_trn-doc.base-rate = curr-shop.exch-rate
      buf_trn-doc.base-scale = curr-shop.exch-scale
      .
      /*ЭТОГО ЧЕРНЫХ НЕ ПРЕДУСМОТРЕЛ*/
      if v-curr-r-b = {&r-b-base} then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end. /*for each buf_sale-doc,*/
  end. /* if available curr-shop then */
  else do: /* на всякий случай, чтобы избежать деления на 0,
             чего быть не должно : отсутствие курса проявляется еще при закачке чеков */
    for each buf_sale-doc where
            buf_Sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = buf_sale-doc.doc-code:
      assign
      buf_trn-doc.base-rate   = 1
      buf_trn-doc.base-scale = 1
      .
      /*ЭТОГО ЧЕРНЫХ НЕ ПРЕДУСМОТРЕЛ*/
      if v-curr-r-b = {&r-b-base} then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end. /*for each buf_sale-doc,*/
    message "Нет магазинного курса базовой валюты" skip
            "на дату " ink-doc.doc-date " !" skip
            "Курс в накладных устанавливается равным 1."
    view-as alert-box error .
  end. /** на всякий случай, чтобы избежать деления на 0,*/
end. /* продажа не пуста*/
if p-run then
run IncProc in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-psn-chk d-chk
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "wrkr" and p-action = "ret-mouse" then do:
   { str/psn-chk.i wrkr ret-mouse tt-trn-doc v-ref-rec }
end.
if p-man = "wrkr" and p-action = "button" then do:
   { str/psn-chk.i wrkr button tt-trn-doc v-ref-rec }
end.
if p-man = "wrkr" and p-action = "leave" then do:
   { str/psn-chk.i wrkr leave tt-trn-doc v-ref-rec }
end.
if p-man = "agnt" and p-action = "ret-mouse" then do:
   { str/psn-chk.i agnt ret-mouse tt-trn-doc v-ref-rec }
end.
if p-man = "agnt" and p-action = "button" then do:
   { str/psn-chk.i agnt button tt-trn-doc v-ref-rec }
end.
if p-man = "agnt" and p-action = "leave" then do:
   { str/psn-chk.i agnt leave tt-trn-doc v-ref-rec }
end.
if p-man = "boss" and p-action = "ret-mouse" then do:
   { str/psn-chk.i boss ret-mouse tt-trn-doc v-ref-rec }
end.
if p-man = "boss" and p-action = "button" then do:
   { str/psn-chk.i boss button tt-trn-doc v-ref-rec }
end.
if p-man = "boss" and p-action = "leave" then do:
   { str/psn-chk.i boss leave tt-trn-doc v-ref-rec }
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable d-chk
PROCEDURE MyEnable :
ASSIGN
rs-get-method = "inc-salr".
/*
assign
buf_sale-doc.doc-label:resizable  in browse br-saledoc = yes
buf_all-binded-docs.doc-label:resizable  in browse br-all-bind-docs = yes
.
*/
find first tt-trn-doc.
{ str/psn-chk.i wrkr on tt-trn-doc v-ref-rec }
{ str/psn-chk.i agnt on tt-trn-doc v-ref-rec }
{ str/psn-chk.i boss on tt-trn-doc v-ref-rec }

IF ink-doc.is-mand-sale-filter THEN DO:
    ASSIGN
    rs-get-method:radio-buttons IN FRAME {&FRAME-NAME} =
    "Все свободные чеки по объекту с заданными условиями" +  {&comma-char} +
    "inc-salr":U + {&comma-char} +
    "Чеки выборочно - удовлетворяющие заданным условиям" + {&comma-char} +
    "chk-docs".

END.
DISPLAY
chk-amount
nf-chk-amount
dtl-ret
gds-amount
nf-gds-amount
time_
line-out
dtl-out
line-ret
curs-mes
rs-get-method
tt-trn-doc.wrkr
tt-trn-doc.agnt
tt-trn-doc.boss
WITH FRAME {&frame-name} .
&scop receipt-code string(chk-doc.chk-type)

IF AVAILABLE ub.chk-doc and p-mode <> {&lookup} THEN
DISPLAY
ub.chk-doc.shift-date
ub.chk-doc.discnt
ub.chk-doc.netto
ub.chk-doc.office
{&receipt-name} @ f-chk-type
ub.chk-doc.sub-discnt
ub.chk-doc.tot-doc
ub.chk-doc.pay-desk
ub.chk-doc.cashier
ub.chk-doc.chk-num
ub.chk-doc.doc-code
ub.chk-doc.sales-man
WITH FRAME {&FRAME-NAME}.
if p-mode <> {&update} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
ENABLE
RECT-1
f-shift-name  when p-mode = {&update}
b-help
b-doc WHEN p-mode = {&LOOKUP}
ub.chk-doc.shift-date  when p-mode = {&update}
ub.chk-doc.discnt
chk-amount
nf-chk-amount
B-sch when (p-mode= {&update} and not ink-doc.is-mand-sale-filter or NOT can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code ))
dtl-ret
gds-amount
nf-gds-amount
time_
chk-doc.netto
chk-doc.office
f-chk-type
ub.chk-doc.sub-discnt
ub.chk-doc.tot-doc
line-out
ub.chk-doc.pay-desk
dtl-out
ub.chk-doc.cashier
line-ret
chk-doc.chk-num
b-exit when p-mode = {&update}
b-quit
chk-doc.doc-code
chk-doc.sales-man
curs-mes
rs-get-method when (p-mode= {&update}  and (ink-doc.is-mand-sale-filter = no  or not can-find(first ub.chk-doc no-lock where ub.chk-doc.out-code = ink-doc.inkas-code)))
br-saledoc
tt-trn-doc.wrkr WHEN p-mode = {&UPDATE}
tt-trn-doc.agnt WHEN p-mode = {&UPDATE}
tt-trn-doc.boss WHEN p-mode = {&UPDATE}
r-wrkr WHEN p-mode = {&UPDATE}
r-agnt WHEN p-mode = {&UPDATE}
r-boss WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name} .
if p-mode <> {&update} then do:
  hide
  b-exit in frame {&frame-name} .
end.
{&OPEN-BROWSERS-IN-QUERY-d-chk}
{&OPEN-QUERY-br-saledoc}
assign
f-Shift-name = if cas-shft or p-mode = {&lookup} then ink-doc.shift-name else '':U
f-Shift-num = if cas-shft or p-mode = {&lookup} then ink-doc.shift-num else 0
.
if p-mode = {&update} then do:
  if ink-doc.is-mand-sale-filter
  and (ink-doc.sale-filter  <> '':U
      or
      ink-doc.sale-filter  <> ?)
      then do:
    RUN Set-filter-name IN THIS-PROCEDURE ( input v-filter-name).
  end.
  else if not can-find(first chk-doc no-lock where chk-doc.out-code = ink-doc.inkas-code) and not ink-doc.is-mand-sale-filter then do:
    /*не будем устанавливать файл по умолчанию если sale-filter*/
    run gbl/flt-get.p (
    input filter-point
    ,output v-filter-rec
    ,output v-filter-name
    ,output v-where-phrase
    ,output v-sort-phrase
    ,output v-where-phrase-rus
    ,output v-sort-phrase-rus
    ).
    RUN Set-filter-name IN THIS-PROCEDURE ( input v-filter-name).
  end.
  if l-shift-on OR can-find( FIRST chk-doc WHERE chk-doc.out-code = ink-doc.inkas-code )  then  do:
    DISABLE
    chk-doc.shift-date
    f-shift-num /*when cas-shft*/
    f-shift-name /*when cas-shft*/
    with frame {&frame-name}.
  end.
end. /*update*/

DISPLAY
f-shift-num when (cas-shft or (p-mode = {&lookup} and ink-doc.shift-num <> 0))
f-shift-name when (cas-shft or (p-mode = {&lookup} and ink-doc.shift-name <> ''))
ink-doc.doc-date @ chk-doc.shift-date
with frame {&frame-name}.
DISABLE
chk-amount
nf-chk-amount
gds-amount
nf-gds-amount
line-out
dtl-out
line-ret
dtl-ret
WITH frame {&frame-name}.
if p-mode = {&update} then do:
  DISABLE
  chk-doc.cashier
  chk-doc.chk-num
  chk-doc.sales-man
  chk-doc.netto
  chk-doc.doc-code
  chk-doc.discnt
  time_
  chk-doc.sub-discnt
  chk-doc.office
  f-chk-type
  chk-doc.tot-doc
  chk-doc.pay-desk
  WITH frame {&frame-name}.
  if  not cas-shft
  then
  HIDE
  f-shift-num
  f-shift-name
  in frame {&frame-name}.
  HIDE b-doc
  in frame {&frame-name}.
end.
else do:
  HIDE
  rs-get-method
  chk-doc.cashier
  chk-doc.chk-num
  chk-doc.sales-man
  chk-doc.netto
  chk-doc.doc-code
  chk-doc.discnt
  time_
  chk-doc.sub-discnt
  chk-doc.office
  f-chk-type
  chk-doc.tot-doc
  chk-doc.pay-desk
  in frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch d-chk
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'chk-doc'
  join-tbl = 'X_chk-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-type', 'Тип чека', 'receipt-code',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Т или у', 'gds-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Смена от', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смен', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc
                   , INPUT (filter-point + {&delim-par} + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN set-filter IN THIS-PROCEDURE ( input YES) no-error.
  if error-status:error then do:
    undo filter-block, return error .
  end.
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-name d-chk
PROCEDURE proc-shift-name :
define variable v-dopi as integer no-undo .
assign
v-dopi = integer(f-shift-name:screen-value in frame {&frame-name} )
no-error .
if error-status:error
or v-dopi <= 0
or v-dopi > 99 then do:
  message "Неверный номер смены!" view-as alert-box ERROR.
  return no-apply.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter d-chk
PROCEDURE set-filter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-on-off AS LOGICAL NO-UNDO.

define variable v-attr-value as character no-undo .
define variable v-deleted    as logical no-undo .
CASE p-on-off :
    WHEN yes THEN DO:
         run gbl/flt-get.p (
           input filter-point
          ,output v-filter-rec
          ,output v-filter-name
          ,output v-where-phrase
          ,output v-sort-phrase
          ,output v-where-phrase-rus
          ,output v-sort-phrase-rus
          ).
      if v-filter-rec <> ? then do:
        assign
        ink-doc.sale-filter = v-where-phrase
        ink-doc.sale-filter-name = v-filter-name
        ink-doc.sale-filter-rus  = v-where-phrase-rus
        .
      end.
      if ink-doc.is-mand-sale-filter then do:
        run check-filter in this-procedure no-error .
        if error-status:error then undo, return error .
        /*проверим а фильтр допустим ли?*/
        /*запишем в ink-doc для продажи*/
        if v-filter-rec <> ? then do:
          assign
          ink-doc.sale-filter = v-where-phrase
          ink-doc.sale-filter-name = v-filter-name
          ink-doc.sale-filter-rus = v-where-phrase-rus
          .
        end.
        else do:
          assign
          ink-doc.sale-filter = ?
          ink-doc.sale-filter-name = ?
          ink-doc.sale-filter-rus = ?
          .
          assign
          v-where-phrase = "":U
          .
        end.
      end.
    END.
    WHEN no THEN DO:
      ASSIGN
      v-filter-rec = ?
      v-filter-name = "":U
      v-where-phrase = "":U
      v-sort-phrase = "":U
      v-where-phrase-rus = "":U
      v-sort-phrase-rus = "":U
      .
      if ink-doc.is-mand-sale-filter then do:
        assign
        ink-doc.sale-filter = ?
        ink-doc.sale-filter-name = ?
        ink-doc.sale-filter-rus = ?
        .
      end.
    END.
END CASE.
  assign
  frame {&frame-name}:title = title0.
  if v-filter-rec <> ? then
  RUN Set-filter-name IN THIS-PROCEDURE ( input v-filter-name).
  else do:
    RUN Set-filter-name IN THIS-PROCEDURE ( input "":U).
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
