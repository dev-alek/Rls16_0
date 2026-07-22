&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
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

Корректировка строки переоценок

Автор: Чернова Светлана Александровна
Дата создания: 02/19/02
Author: Svetlana Chernova
Creation date: 02/19/02


*/
define input  parameter parParentProc as widget-handle no-undo.
define input  parameter line-mode as character no-undo .
define input  parameter doc-rec as recid no-undo . /* recid ub.price-doc */
define input param p-doc-rec as recid no-undo.        /* recid ub.price-list */
define input param p-disc as decimal no-undo.
define input param r-m  as char no-undo.
define input param r-b as decimal no-undo.
define input param  c-m  as char no-undo.
define output param stp-cycle as log no-undo.

define variable g#log as logical   no-undo .
define variable line-rec as recid no-undo .

define variable cost-base    like ub.gds-obj.avrg-base no-undo.   /* для вызова g d savrg .p */
define variable cost-rubl    like ub.gds-obj.avrg-rubl no-undo.   /* для вызова g d savrg .p */
define variable v-price-base like ub.gds-obj.avrg-base no-undo.   /* для вызова g d snovat .p */
define variable v-price-rubl like ub.gds-obj.avrg-rubl no-undo.   /* для вызова g d snovat .p */
define variable cur-rt-base  like ub.gds-obj.avrg-base no-undo.   /* для вызова g d snovat .p */
define variable cur-rt-rubl  like ub.gds-obj.avrg-rubl no-undo.   /* для вызова g d snovat .p */
define variable doc-code     as char    no-undo. /* код документа для копирования цены */

define variable old-price-sale as decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Формирование приказа переоценки".
define variable tt-price-sale as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable tt-price-prodwihvat as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable tt-prod-vat         as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable v-str as character no-undo .
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/showinf.i      }
{ cmp/library.i      }
{ str/lib-trn.i      }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i get }
{ cmp/croslist.i     }
{ gbl/clntattr.i     }
{ ref/grpobj.i       }
{ ref/gdsoattr.i     }
{ str/hvrdtax.i      }
{ gbl/tax-name.i     }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ trg/check-bc.i }
{ str/alt-calc.i func-befor }
{ str/alt-calc.i func }
{ str/alt-calc.i proc }
{ str/alt-calc.i pr-list }
{ str/alt-calc.i "main-road-tax" }
{ str/doc-code.i }
{ str/lvldsc.i   }
define buffer bb-price-list for ub.price-list .
define buffer p-doc for ub.price-doc .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.price-list ub.goods

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ub.price-list.price-sale ~
price-list.doc-num ub.price-list.artic ub.price-list.prod-code ~
price-list.prod-type ub.price-list.b-code ub.goods.gds-name ub.price-list.doc-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ub.price-list.price-sale ~
price-list.doc-num ub.price-list.artic ub.price-list.prod-code ~
price-list.prod-type ub.price-list.b-code ub.goods.gds-name ub.price-list.doc-qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ub.price-list ub.goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.price-list
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.goods

&Scoped-define FIELD-PAIRS-IN-QUERY-Dialog-Frame~
 ~{&FP1}price-sale ~{&FP2}price-sale ~{&FP3}~
 ~{&FP1}doc-num ~{&FP2}doc-num ~{&FP3}~
 ~{&FP1}artic ~{&FP2}artic ~{&FP3}~
 ~{&FP1}prod-code ~{&FP2}prod-code ~{&FP3}~
 ~{&FP1}prod-type ~{&FP2}prod-type ~{&FP3}~
 ~{&FP1}b-code ~{&FP2}b-code ~{&FP3}~
 ~{&FP1}gds-name ~{&FP2}gds-name ~{&FP3}~
 ~{&FP1}doc-qnty ~{&FP2}doc-qnty ~{&FP3}
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.price-list ~
      WHERE recid(ub.price-list) = p-doc-rec SHARE-LOCK, ~
      EACH ub.goods OF ub.price-list SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.price-list ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.price-list


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.price-list.price-sale ub.price-list.doc-num ~
price-list.artic ub.price-list.prod-code ub.price-list.prod-type ~
price-list.b-code ub.goods.gds-name ub.price-list.doc-qnty
&Scoped-define FIELD-PAIRS~
 ~{&FP1}price-sale ~{&FP2}price-sale ~{&FP3}~
 ~{&FP1}doc-num ~{&FP2}doc-num ~{&FP3}~
 ~{&FP1}artic ~{&FP2}artic ~{&FP3}~
 ~{&FP1}prod-code ~{&FP2}prod-code ~{&FP3}~
 ~{&FP1}prod-type ~{&FP2}prod-type ~{&FP3}~
 ~{&FP1}b-code ~{&FP2}b-code ~{&FP3}~
 ~{&FP1}gds-name ~{&FP2}gds-name ~{&FP3}~
 ~{&FP1}doc-qnty ~{&FP2}doc-qnty ~{&FP3}
&Scoped-define ENABLED-TABLES ub.price-list ub.goods
&Scoped-define FIRST-ENABLED-TABLE ub.price-list
&Scoped-define SECOND-ENABLED-TABLE ub.goods
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 info b-calc B-save b-quit ~
B-Help b-curr old-price new-old pc-prev loc-gds-obj-avrg op-avrg pc-avrg ~
old-avrg new-avrg loc-gds-obg-last op-last pc-last old-last new-last ~
loc-in-code loc-in-date akt-num akt-date s-old s-new s-new-old v-dis
&Scoped-Define DISPLAYED-FIELDS ub.price-list.price-sale ub.price-list.doc-num ~
price-list.artic ub.price-list.prod-code ub.price-list.prod-type ~
price-list.b-code ub.goods.gds-name ub.price-list.doc-qnty
&Scoped-Define DISPLAYED-OBJECTS info b-curr old-price new-old pc-prev ~
loc-gds-obj-avrg op-avrg pc-avrg old-avrg new-avrg loc-gds-obg-last op-last ~
pc-last old-last new-last loc-in-code loc-in-date akt-num akt-date s-old ~
s-new s-new-old v-dis

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc
     LABEL "Рас&чет":L
     SIZE 8.75 BY 1.08.

DEFINE BUTTON b-exit-cycl AUTO-GO
     LABEL "СтопЦикл"
     SIZE 9 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 9 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 9 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Со&хр"
     SIZE 9 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE akt-date AS DATE FORMAT "99/99/99"
      VIEW-AS TEXT
     SIZE 14.88 BY 1.

DEFINE VARIABLE akt-num AS CHARACTER FORMAT "X(8)"
      VIEW-AS TEXT
     SIZE 14 BY 1.

DEFINE VARIABLE b-curr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE info AS CHARACTER FORMAT "X(256)"
      VIEW-AS TEXT
     SIZE 75.13 BY .67
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-gds-obg-last AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE loc-gds-obj-avrg AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE loc-in-code AS CHARACTER FORMAT "X(8)"
      VIEW-AS TEXT
     SIZE 14 BY 1.

DEFINE VARIABLE loc-in-date AS DATE FORMAT "99/99/99"
      VIEW-AS TEXT
     SIZE 15.13 BY 1.

DEFINE VARIABLE new-avrg AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE new-last AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE new-old AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE old-avrg AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE old-last AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE old-price AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY 1 TOOLTIP "Предыдущая переоценка" NO-UNDO.

DEFINE VARIABLE op-avrg AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE op-last AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14.63 BY 1 NO-UNDO.

DEFINE VARIABLE pc-avrg AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE pc-last AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14.75 BY 1 NO-UNDO.

DEFINE VARIABLE pc-prev AS DECIMAL FORMAT "->,>>9.<<<%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE s-new AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE s-new-old AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE s-old AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE v-dis AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Наценка"
      VIEW-AS TEXT
     SIZE 9.25 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 83.25 BY 2.17
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76.25 BY 10.21.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.price-list,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     info AT ROW 13.54 COL 4 COLON-ALIGNED NO-LABEL
     ub.price-list.price-sale AT ROW 4.25 COL 33.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 15 BY 1
          FGCOLOR 4
     ub.price-list.road-tax AT ROW 14.54 COL 19.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     ub.price-list.excise AT ROW 14.54 COL 45.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     b-calc AT ROW 15.75 COL 32.88
     B-save AT ROW 15.83 COL 7.38
     b-quit AT ROW 15.83 COL 47.75
     b-exit-cycl AT ROW 15.83 COL 18.88
     B-Help AT ROW 15.75 COL 61.5
     ub.price-list.doc-num AT ROW 1.13 COL 1.75 NO-LABEL
           VIEW-AS TEXT
          SIZE 14.13 BY .67
          FGCOLOR 4
     ub.price-list.artic AT ROW 1.13 COL 15.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 17.5 BY .67
          BGCOLOR 3 FGCOLOR 15
     ub.price-list.prod-code AT ROW 1.13 COL 33.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 9.25 BY .67
          BGCOLOR 3 FGCOLOR 15
     ub.price-list.prod-type AT ROW 1.13 COL 43.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 9 BY .67
          BGCOLOR 3 FGCOLOR 15
     ub.price-list.b-code AT ROW 1.13 COL 61.88 COLON-ALIGNED
          LABEL "Бар-код"
           VIEW-AS TEXT
          SIZE 10 BY .67
          BGCOLOR 3 FGCOLOR 15
     b-curr AT ROW 1.13 COL 77 COLON-ALIGNED NO-LABEL
     ub.goods.gds-name AT ROW 2 COL 1.75 NO-LABEL
           VIEW-AS TEXT
          SIZE 82.25 BY 1
          FGCOLOR 4
     old-price AT ROW 4.25 COL 18.13 COLON-ALIGNED NO-LABEL
     new-old AT ROW 4.25 COL 48.13 COLON-ALIGNED NO-LABEL
     pc-prev AT ROW 4.25 COL 63.13 COLON-ALIGNED NO-LABEL
     loc-gds-obj-avrg AT ROW 6.21 COL 5.13 NO-LABEL
     op-avrg AT ROW 6.21 COL 18.13 COLON-ALIGNED NO-LABEL
     pc-avrg AT ROW 6.21 COL 33.13 COLON-ALIGNED NO-LABEL
     old-avrg AT ROW 6.21 COL 48.13 COLON-ALIGNED NO-LABEL
     new-avrg AT ROW 6.21 COL 63.13 COLON-ALIGNED NO-LABEL
     loc-gds-obg-last AT ROW 8.21 COL 5.13 NO-LABEL
     op-last AT ROW 8.21 COL 18.13 COLON-ALIGNED NO-LABEL
     pc-last AT ROW 8.21 COL 33.13 COLON-ALIGNED NO-LABEL
     old-last AT ROW 8.21 COL 48.13 COLON-ALIGNED NO-LABEL
     new-last AT ROW 8.21 COL 63.13 COLON-ALIGNED NO-LABEL
     loc-in-code AT ROW 10.13 COL 5.13 NO-LABEL
     loc-in-date AT ROW 10.13 COL 18.13 COLON-ALIGNED NO-LABEL
     akt-num AT ROW 10.13 COL 48.13 COLON-ALIGNED NO-LABEL
     akt-date AT ROW 10.13 COL 63.13 COLON-ALIGNED NO-LABEL
     s-old AT ROW 12.29 COL 18.13 COLON-ALIGNED NO-LABEL
     s-new AT ROW 12.29 COL 33.13 COLON-ALIGNED NO-LABEL
     s-new-old AT ROW 12.29 COL 48.13 COLON-ALIGNED NO-LABEL
     ub.price-list.doc-qnty AT ROW 12.29 COL 63.13 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 15 BY 1
     v-dis AT ROW 14.67 COL 72.5 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
     RECT-2 AT ROW 3.17 COL 4.5
     "РАЗНИЦА стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
.
/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     "Новая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     "Учетная" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ" VIEW-AS TEXT
          SIZE 15 BY .96 AT ROW 3.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 3.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "Новая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 3.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     "КОЛИЧЕСТВО" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "Старая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
     "Накладная" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "СУММА" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 11.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "Дата" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "Старая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 3.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
     "Старый акт" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 50.13
          BGCOLOR 3 FGCOLOR 15
     "" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     "Дата" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 9.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     "Цена" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 3.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 5.21 COL 65.13
          BGCOLOR 3 FGCOLOR 15
     "Последняя" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 5.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 20.13
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 7.21 COL 35.13
          BGCOLOR 3 FGCOLOR 15
     SPACE(34.12) SKIP(8.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка переоценки"
         DEFAULT-BUTTON B-save CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   Custom                                                               */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ub.price-list.artic IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.price-list.b-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR BUTTON b-exit-cycl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.price-list.doc-num IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ub.price-list.excise IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       ub.price-list.excise:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN ub.goods.gds-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc-gds-obg-last IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc-gds-obj-avrg IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc-in-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ub.price-list.price-sale IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.price-list.prod-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.price-list.road-tax IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       ub.price-list.road-tax:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.price-list,ub.goods OF ub.price-list"
     _Options          = "SHARE-LOCK"
     _Where[1]         = "recid(ub.price-list) = p-doc-rec"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Строка переоценки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON CHOOSE OF b-calc IN FRAME Dialog-Frame /* Расчет */
DO:
run calc-pr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit-cycl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit-cycl Dialog-Frame
ON CHOOSE OF b-exit-cycl IN FRAME Dialog-Frame /* СтопЦикл */
DO:
assign frame  {&frame-name}
     ub.price-list.price-sale
     .
     assign
     ub.price-list.d-pcnt       = p-disc
     ub.price-list.calc-method  = c-m
     ub.price-list.price-calc = ub.price-list.price-sale
     .

     assign
     stp-cycle  =  true

     .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отказ */
DO:
       stp-cycle  =  false.
       return "error".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохр */
DO:
 run upd-field in this-procedure .
 run calc-pr in this-procedure .
assign frame  {&frame-name}
     ub.price-list.price-sale
     .
     assign
     ub.price-list.d-pcnt       = p-disc
     ub.price-list.calc-method  = c-m
     ub.price-list.price-calc = ub.price-list.price-sale
     .
     stp-cycle  =  false.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.price-list.excise
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.price-list.excise Dialog-Frame
ON LEAVE OF ub.price-list.excise IN FRAME Dialog-Frame /* Акциз */
DO:
    run upd-field in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.price-list.price-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.price-list.price-sale Dialog-Frame
ON LEAVE OF ub.price-list.price-sale IN FRAME Dialog-Frame /* Цена продажи (вал) */
DO:
  run upd-field in this-procedure no-error.
  run calc-pr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.price-list.road-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.price-list.road-tax Dialog-Frame
ON LEAVE OF ub.price-list.road-tax IN FRAME Dialog-Frame /* Дорожный налог */
DO:
    run upd-field in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

find first p-doc where recid(p-doc) = doc-rec no-lock no-error.
find first ub.price-list where recid(ub.price-list) = p-doc-rec .
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_ui in this-procedure .
  run loc-init in this-procedure  .

  if  line-mode = "ЦИКЛ":U then do:
     enable  b-exit-cycl with frame {&FRAME-NAME}.
     display b-exit-cycl  with frame {&FRAME-NAME}.
     end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-pr Dialog-Frame
PROCEDURE calc-pr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if p-doc.status_ <> {&act-overvalue} and available ub.gds-obj then do:
  new-avrg = input frame {&frame-name} ub.price-list.price-sale - ub.gds-obj.avrg-rubl.
  new-last = input frame {&frame-name} ub.price-list.price-sale - ub.gds-obj.last-rubl.
  pc-avrg = (input frame {&frame-name} ub.price-list.price-sale / ub.gds-obj.avrg-rubl - 1) * 100.
  pc-last  = (input frame {&frame-name} ub.price-list.price-sale / ub.gds-obj.last-rubl - 1) * 100.
  old-avrg = old-price - ub.gds-obj.avrg-rubl.
  old-last = old-price - ub.gds-obj.last-rubl.
  op-avrg = (old-price / ub.gds-obj.avrg-rubl - 1) * 100.
  op-last = (old-price / ub.gds-obj.last-rubl - 1) * 100.
  disp pc-avrg pc-last new-avrg new-last old-avrg old-last op-avrg op-last with frame {&frame-name} no-error .
end.
new-old = input frame {&frame-name} ub.price-list.price-sale - old-price.
pc-prev = (input frame {&frame-name} ub.price-list.price-sale / old-price - 1) * 100.
s-new-old = new-old * ub.price-list.doc-qnty.
s-old = old-price * ub.price-list.doc-qnty.
s-new = input frame {&frame-name} ub.price-list.price-sale * ub.price-list.doc-qnty.
disp new-old pc-prev s-new-old s-old s-new ub.price-list.doc-qnty with frame {&frame-name} no-error .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY info b-curr old-price new-old pc-prev loc-gds-obj-avrg op-avrg pc-avrg
          old-avrg new-avrg loc-gds-obg-last op-last pc-last old-last new-last
          loc-in-code loc-in-date akt-num akt-date s-old s-new s-new-old v-dis
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.goods THEN
    DISPLAY ub.goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.price-list THEN
    DISPLAY ub.price-list.price-sale ub.price-list.doc-num ub.price-list.artic
          ub.price-list.prod-code ub.price-list.prod-type ub.price-list.b-code
          ub.price-list.doc-qnty
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 info ub.price-list.price-sale b-calc B-save b-quit B-Help
         ub.price-list.doc-num ub.price-list.artic ub.price-list.prod-code
         ub.price-list.prod-type ub.price-list.b-code b-curr ub.goods.gds-name old-price
         new-old pc-prev loc-gds-obj-avrg op-avrg pc-avrg old-avrg new-avrg
         loc-gds-obg-last op-last pc-last old-last new-last loc-in-code
         loc-in-date akt-num akt-date s-old s-new s-new-old ub.price-list.doc-qnty
         v-dis
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loc-init Dialog-Frame
PROCEDURE loc-init :
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable cur-pr like ub.price-list.price-sale    no-undo.
define buffer lp-price-doc for ub.price-doc.
define buffer buff-goods for ub.goods.
define variable dor-nal as character no-undo .
define variable ff as logical no-undo .

define variable   is-petrolium  as logical             no-undo.
define variable   is-pieces     as logical             no-undo.
define variable v-rec as recid no-undo.
define variable t-ret as logical no-undo .

c-m = {&pr-calc-no} .
v-dis =  p-disc.

  frame {&frame-name}:title = frame {&frame-name}:title + " -  " + line-mode.
  run tax-name in this-procedure ( input {&road-tax}, output  dor-nal) .
  assign ub.price-list.road-tax :label in frame {&frame-name} = dor-nal .

  Find first buff-goods no-lock where
        buff-goods.artic     = ub.price-list.artic and
        buff-goods.prod-type = ub.price-list.prod-type and
        buff-goods.prod-code = ub.price-list.prod-code
        no-error .

/* Проверочка наличия Третьего налога */

      If avail buff-goods Then DO:
          v-rec = recid (buff-goods).
           t-ret =  session:SET-WAIT-STATE("GENERAL") .
           { str/is-petrl.i
               ub.price-list.artic
               ub.price-list.prod-type
               ub.price-list.prod-code
               is-petrolium
               is-pieces
           }

           t-ret =  session:SET-WAIT-STATE("") .
              IF ( hvrdtax( v-rec ) = true and
                 is-petrolium = true )
                then  DO :
                /* изменение дорналога в Румынии-топливо права */
                  define variable v-chk-act-host-code as integer   no-undo .
                  { gbl/hostcode.i
                    ub.price-list.obj-code
                    ub.price-list.obj-type
                    v-chk-act-host-code
                  }
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_overvalue_update':U
                    {&cntxt-object}
                    v-chk-act-host-code
                    ub.price-list.obj-code
                    ub.price-list.obj-type
                    0
                    0
                    0
                    true
                    ff
                  }
                    If ff Then do:
                           enable ub.price-list.road-tax with frame {&frame-name} .
                    End.
              End.
      End.




{ gbl/r-b-abbr.i v-cntxt-host-code-obj b-curr }

find  first ub.gds-obj where
         ub.gds-obj.obj-code = ub.price-list.obj-code and
         ub.gds-obj.obj-type = ub.price-list.obj-type and
         ub.gds-obj.gds-code = ub.goods.gds-code
         no-lock no-error.

  if avail ub.gds-obj then
   assign
        loc-gds-obg-last =  if var-pr-r-b = "rubl" then  ub.gds-obj.last-rubl else ub.gds-obj.last-base
        loc-gds-obj-avrg =  if var-pr-r-b = "rubl" then  ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
        loc-in-code = ub.gds-obj.in-code
        loc-in-date = ub.gds-obj.in-date
     .
  find first p-doc where recid(p-doc) = doc-rec no-lock no-error.
  { gbl/bcodeprc.i
    ub.price-list.obj-type
    ub.price-list.obj-code
    ub.price-list.b-code
    0
    ub.price-list.fact-order
    cur-dn
    cur-pr
    cur-rt
    cur-ex
    no-error }
     old-price =  cur-pr.
     akt-num = cur-dn.
     if cur-dn <> ? then find first lp-price-doc where lp-price-doc.doc-num = cur-dn no-lock no-error .
     if avail lp-price-doc then
              akt-date = lp-price-doc.fact-date .
              else akt-date = ?.
   display
     old-price
     v-dis
     loc-gds-obg-last
     loc-gds-obj-avrg
     loc-in-code
     loc-in-date
     b-curr akt-num akt-date
     ub.price-list.road-tax
     ub.price-list.excise
     with frame {&FRAME-NAME}.

   enable
     old-price
     loc-in-code
     loc-in-date
     v-dis
     loc-gds-obg-last
     loc-gds-obj-avrg
     b-curr akt-num akt-date

     with frame {&FRAME-NAME}.
     run calc-pr in this-procedure .
     run sel-info in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-info Dialog-Frame
PROCEDURE sel-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

define variable par-type as character no-undo .
define variable p-node-code like ub.goods.grp-code no-undo .
define variable p-prc-min as decimal no-undo .
define variable p-prc-max as decimal no-undo .
define variable p-increase-pc as decimal no-undo .
define variable p-round-method as character no-undo .
define variable p-base         as decimal no-undo .
define variable p-value-margin   as integer no-undo .
define variable p-type-margin    as logical no-undo .
define variable p-value-increase   as integer no-undo .
define variable p-type-increase    as logical no-undo .
define variable p-value-rmethod   as integer no-undo .
define variable p-type-rmethod    as logical no-undo .



define buffer bl_goods for ub.goods.
define variable l-par as logical   no-undo .

   run chec-par in this-procedure (
         output l-par
        ,input  p-doc.host-code
        ,input  p-doc.obj-type
        ,input  p-doc.obj-code
      ) no-error .

if trim(par-pr-discm) = "" then return .
    find first bl_goods   where ub.price-list.artic     = bl_goods.artic     and
                                ub.price-list.prod-code = bl_goods.prod-code and
                                ub.price-list.prod-type = bl_goods.prod-type no-lock no-error .
                            if error-status :error then return error.
    assign
      p-node-code  = bl_goods.grp-code
    .
    run gds-attr-margin-value in this-procedure
    ( input   bl_goods.gds-code,
      input   p-doc.obj-type ,
      input   p-doc.obj-code ,
      output  p-prc-min  ,
      output  p-prc-max  ,
      output  p-increase-pc,
      output  p-round-method  ,
      output  p-base          ,
      output  p-value-margin    ,
      output  p-type-margin  ,
      output  p-value-increase    ,
      output  p-type-increase ,
      output  p-value-rmethod   ,
      output  p-type-rmethod

                ) .

    if p-type-margin = false  then return.

     info = "ИНТЕРВАЛ НАЦЕНКИ" .
      case  par-pr-discm :
        when "cost":u then     do: info = info + " от учетной цены " .    end.
        when "cost-vat":u then do: info = info + " от учетной цены без налогов " .       end.
        when "sale":u then     do: info = info + " от продажной цены " .       end.
        when "sale-":u then     do: info = info + " от продажной цены " .       end.
        when "prod":u then     do: info = info + " от цены производителя с НДС" .  end.
        when "prod-vat":u then     do: info = info + " от цены производителя без НДС" .       end.

      end case.
      info = info + " от " + string(p-prc-min) + "% до " + string (p-prc-max) + "% ".
      display info  with frame {&FRAME-NAME}.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE upd-field Dialog-Frame
PROCEDURE upd-field :
define variable ff as logical no-undo .
define variable ff1 as logical init true no-undo .
define variable cur-dn as decimal no-undo .
define variable cur-pr as decimal no-undo .
define variable cur-rt as decimal no-undo .
define variable cur-ex as decimal no-undo .
define variable calc-rec as recid no-undo.  /* последняя посчитанная запись - не используется */
define buffer buff-goods for ub.goods .
define buffer p-doc for ub.price-doc.


define variable calc-method    as char    no-undo. /* способ расчета цены - исходная цена */
define variable increase-pc    as decimal no-undo. /* процент наценки (с минусом - скидки)*/
define variable round-method   as char    no-undo. /* способ округления */
define variable round-base     as decimal no-undo. /* база для округления / коэффициент */


  /* NO-LOCK !!! */
  find current ub.price-list.
  find first p-doc where p-doc.doc-num = ub.price-list.doc-num no-lock no-error.
    assign
       calc-method    = ub.price-list.calc-method
       increase-pc    = p-disc
       round-method   = r-m
       round-base     = r-b
       .

  if dec (ub.price-list.price-sale :screen-value in frame {&frame-name}) <> ub.price-list.price-sale then do:
    assign
      ub.price-list.calc-method = c-m
      ub.price-list.price-calc = ub.price-list.price-sale
      ub.price-list.price-sale = dec (ub.price-list.price-sale :screen-value in frame {&frame-name})
      .
    /* пересчитываем цены по неосновным для этого кода */
    assign
       calc-method    = c-m
       increase-pc    = p-disc
       round-method   = r-m
       round-base     = r-b
       .
        run calc-pr-sub in this-procedure  (input  ub.price-list.b-code,
                          input  p-doc.doc-num,
                          input  calc-method,
                          input  increase-pc,
                          input  round-method,
                          input  round-base,
                          output calc-rec) no-error.
        if error-status :error then
          undo, return error.

  end.


If dec (ub.price-list.excise :screen-value in frame {&frame-name} ) <> ub.price-list.excise then do:
    /* изменены налоги */
    assign
    ub.price-list.excise     = dec (ub.price-list.excise     :screen-value in frame {&frame-name})
    .
End.

If dec (ub.price-list.road-tax :screen-value in frame {&frame-name}) <> ub.price-list.road-tax then do:
/* Проверочка наличия Третьего налога */
       Find first buff-goods no-lock where
            buff-goods.artic     = ub.price-list.artic and
            buff-goods.prod-type = ub.price-list.prod-type and
            buff-goods.prod-code = ub.price-list.prod-code
            no-error .

      If avail buff-goods Then DO:
              IF hvrdtax( recid(buff-goods)) = false  then  DO :
                  /*нет стеклопосуды */
                 message "В товаре нет компонента цены '"   ub.price-list.road-tax:label  "' ,  изменять нельзя ! " .
              End.
              /* есть стеклопосуда */
              Else do:
                /* изменение стеклопосуды права */
                  define variable v-chk-act-host-code as integer   no-undo .
                  { gbl/hostcode.i
                    ub.price-list.obj-code
                    ub.price-list.obj-type
                    v-chk-act-host-code
                  }
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_overvalue_update':U
                    {&cntxt-object}
                    v-chk-act-host-code
                    ub.price-list.obj-code
                    ub.price-list.obj-type
                    0
                    0
                    0
                    true
                    ff
                  }
                    if not ff then do :
                       /* Если прав нет то ..... */
                      assign
                        ub.price-list.road-tax   = ub.price-list.road-tax
                      .
                    end.
                    else do :
                      assign
                        ub.price-list.road-tax = dec(ub.price-list.road-tax:screen-value in frame {&frame-name})
                      .
                    end.
              End.
      End.
 end.

 Display ub.price-list.excise ub.price-list.price-sale ub.price-list.road-tax  with frame {&frame-name} .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME