
&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_price-doc-forming FOR ub.price-doc-forming.
DEFINE BUFFER buf_price-doc-forming-gds FOR ub.price-doc-forming-gds.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision: f47d21f63b8b, 1891, rls $
$Author: EShklyar $
$Date: Fri Jun 07 16:26:45 2019 +0300 $
$Workfile: mplform.w $
$Archive: str/mplform.w $

Корректировка строки ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 07/24/06
Author: Svetlana Chernova
Creation date: 07/24/06

*/

define input parameter parParentProc as widget-handle no-undo.
define input parameter line-mode     as character no-undo .
define input parameter doc-rec       as recid no-undo .      /* recid price-doc-forming */
define input parameter p-doc-rec     as recid no-undo.       /* price-doc-forming-gds */
define input parameter p-disc        as decimal no-undo.     /* increase-pc  */
define input parameter r-m           as character no-undo.   /* round-method */
define input parameter r-b           as decimal no-undo.     /* round-base   */
define input parameter c-m           as character no-undo.   /* calc-method */
define input  parameter p-exch-rate  as decimal   no-undo .
define input  parameter p-exch-scale as decimal   no-undo .
define input  parameter p-base-rate  as decimal   no-undo .
define input  parameter p-base-scale as decimal   no-undo .
define output parameter stp-cycle    as logical no-undo.


define variable g#log    as logical no-undo .
define variable line-rec as recid   no-undo .

define variable cost-base    like ub.gds-obj.avrg-base no-undo.   /* для вызова g d savrg .p  */
define variable cost-rubl    like ub.gds-obj.avrg-rubl no-undo.   /* для вызова g d savrg .p  */
define variable v-price-base like ub.gds-obj.avrg-base no-undo.   /* для вызова g d snovat .p */
define variable v-price-rubl like ub.gds-obj.avrg-rubl no-undo.   /* для вызова g d snovat .p */
define variable cur-rt-base  like ub.gds-obj.avrg-base no-undo.   /* для вызова g d snovat .p */
define variable cur-rt-rubl  like ub.gds-obj.avrg-rubl no-undo.   /* для вызова g d snovat .p */
define variable doc-code     as character no-undo . /* код документа для копирования цены */
define variable old-price-sale-doc as decimal no-undo .

define variable common-price as decimal   no-undo .
define variable copy-type as character no-undo .
define variable copy-code as integer   no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: f47d21f63b8b, 1891, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 07 16:26:45 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mplform.w $":U .
define variable vss-archive     as character no-undo init "$Archive: str/mplform.w $":U .
define variable vss-description as character no-undo init "Корректировка строки ДНЦ".
define variable tt-price-sale as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable tt-price-prodwihvat as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable tt-prod-vat         as decimal no-undo.   /* для вызова g d s n o v a t . p */
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/showinf.i      }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i get }
{ gbl/getsect.i  def }
{ str/lib-trn.i      }
{ cmp/croslist.i     }
{ gbl/clntattr.i     }
{ ref/xobjgrp.i      }  /* список объектов  */
{ ref/grpobj.i       }
{ ref/gdsoattr.i     }
{ str/hvrdtax.i      }
{ gbl/tax-name.i     }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ str/alt-calc.i func }
{ str/alt-calc.i proc }
{ str/mpl-lib.i  pr-doc }
{ str/mpl-lib3.i }
{ trg/factord.i  }
{ str/lastincs.i }
{ trg/check-bc.i }

define buffer bb-price-doc-forming-gds for ub.price-doc-forming-gds .
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf-price-list-type for ub.price-list-type  .

define variable v-rb-base as logical   no-undo .

/*define variable var-pr-r-b as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }
*/
{ gbl/rbisbase.i v-rb-base }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_price-doc-forming-gds ub.goods

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH buf_price-doc-forming-gds       WHERE recid(buf_price-doc-forming-gds) = p-doc-rec NO-LOCK, ~
             EACH ub.goods OF buf_price-doc-forming-gds NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH buf_price-doc-forming-gds       WHERE recid(buf_price-doc-forming-gds) = p-doc-rec NO-LOCK, ~
             EACH ub.goods OF buf_price-doc-forming-gds NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame buf_price-doc-forming-gds ~
ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame buf_price-doc-forming-gds
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame ub.goods


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS buf_price-doc-forming-gds.price-sale-doc ~
buf_price-doc-forming-gds.pdf-id buf_price-doc-forming-gds.artic ~
buf_price-doc-forming-gds.prod-code buf_price-doc-forming-gds.prod-type ~
buf_price-doc-forming-gds.b-code ub.goods.gds-name
&Scoped-define ENABLED-TABLES buf_price-doc-forming-gds ub.goods
&Scoped-define FIRST-ENABLED-TABLE buf_price-doc-forming-gds
&Scoped-define SECOND-ENABLED-TABLE ub.goods
&Scoped-Define ENABLED-OBJECTS info b-calc B-save b-quit B-Help b-curr ~
old-price new-old pc-prev loc-gds-obj-avrg op-avrg pc-avrg old-avrg ~
new-avrg loc-gds-obg-last op-last pc-last old-last new-last loc-in-code ~
loc-in-date akt-num akt-date v-dis
&Scoped-Define DISPLAYED-FIELDS buf_price-doc-forming-gds.price-sale-doc ~
buf_price-doc-forming-gds.pdf-id buf_price-doc-forming-gds.artic ~
buf_price-doc-forming-gds.prod-code buf_price-doc-forming-gds.prod-type ~
buf_price-doc-forming-gds.b-code ub.goods.gds-name
&Scoped-define DISPLAYED-TABLES buf_price-doc-forming-gds ub.goods
&Scoped-define FIRST-DISPLAYED-TABLE buf_price-doc-forming-gds
&Scoped-define SECOND-DISPLAYED-TABLE ub.goods
&Scoped-Define DISPLAYED-OBJECTS info b-curr old-price new-old pc-prev ~
loc-gds-obj-avrg op-avrg pc-avrg old-avrg new-avrg loc-gds-obg-last op-last ~
pc-last old-last new-last loc-in-code loc-in-date akt-num akt-date v-dis

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc
     LABEL "Рас&чет":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exit-cycl AUTO-GO
     LABEL "СтопЦикл"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Со&хр"
     SIZE 10 BY 1
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

DEFINE VARIABLE v-dis AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Наценка"
      VIEW-AS TEXT
     SIZE 9.25 BY .67
     FGCOLOR 1  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      buf_price-doc-forming-gds,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     info AT ROW 13.25 COL 3 COLON-ALIGNED NO-LABEL
     buf_price-doc-forming-gds.price-sale-doc AT ROW 5.88 COL 33.38 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 15 BY 1
          FGCOLOR 4
     buf_price-doc-forming-gds.road-tax-doc AT ROW 14.25 COL 39 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     buf_price-doc-forming-gds.excise-doc AT ROW 15.13 COL 39 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     b-calc AT ROW 1 COL 21
     B-save AT ROW 1 COL 1
     b-quit AT ROW 1 COL 31
     b-exit-cycl AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74
     buf_price-doc-forming-gds.pdf-id AT ROW 2.75 COL 2 NO-LABEL FORMAT ">>>>>>>>>9"
           VIEW-AS TEXT
          SIZE 14.5 BY .67
          FGCOLOR 4
     buf_price-doc-forming-gds.artic AT ROW 2.75 COL 15.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 17.5 BY .67
          BGCOLOR 3 FGCOLOR 15
     buf_price-doc-forming-gds.prod-code AT ROW 2.75 COL 33.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 9.25 BY .67
          BGCOLOR 3 FGCOLOR 15
     buf_price-doc-forming-gds.prod-type AT ROW 2.75 COL 43.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 9 BY .67
          BGCOLOR 3 FGCOLOR 15
     buf_price-doc-forming-gds.b-code AT ROW 2.75 COL 62.13 COLON-ALIGNED FORMAT "99999999999":U
          LABEL "Бар-код"
           VIEW-AS TEXT
          SIZE 12 BY .67
          BGCOLOR 3 FGCOLOR 15
     b-curr AT ROW 2.75 COL 75 COLON-ALIGNED NO-LABEL
     ub.goods.gds-name AT ROW 3.63 COL 2 NO-LABEL
           VIEW-AS TEXT
          SIZE 82.25 BY 1
          FGCOLOR 4
     old-price AT ROW 5.88 COL 18.38 COLON-ALIGNED NO-LABEL
     new-old AT ROW 5.88 COL 48.38 COLON-ALIGNED NO-LABEL
     pc-prev AT ROW 5.88 COL 63.38 COLON-ALIGNED NO-LABEL
     loc-gds-obj-avrg AT ROW 7.83 COL 5.38 NO-LABEL
     op-avrg AT ROW 7.83 COL 18.38 COLON-ALIGNED NO-LABEL
     pc-avrg AT ROW 7.83 COL 33.38 COLON-ALIGNED NO-LABEL
     old-avrg AT ROW 7.83 COL 48.38 COLON-ALIGNED NO-LABEL
     new-avrg AT ROW 7.83 COL 63.38 COLON-ALIGNED NO-LABEL
     loc-gds-obg-last AT ROW 9.83 COL 5.38 NO-LABEL
     op-last AT ROW 9.83 COL 18.38 COLON-ALIGNED NO-LABEL
     pc-last AT ROW 9.83 COL 33.38 COLON-ALIGNED NO-LABEL
     old-last AT ROW 9.83 COL 48.38 COLON-ALIGNED NO-LABEL
     new-last AT ROW 9.83 COL 63.38 COLON-ALIGNED NO-LABEL
     loc-in-code AT ROW 11.75 COL 5.38 NO-LABEL
     loc-in-date AT ROW 11.75 COL 18.38 COLON-ALIGNED NO-LABEL
     akt-num AT ROW 11.75 COL 48.38 COLON-ALIGNED NO-LABEL
     akt-date AT ROW 11.75 COL 63.38 COLON-ALIGNED NO-LABEL
     v-dis AT ROW 16.25 COL 39 COLON-ALIGNED
     "РАЗНИЦА стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 6.83 COL 50.38
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 6.83 COL 65.38
          BGCOLOR 3 FGCOLOR 15
     "Последняя" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 8.83 COL 5.38
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 8.83 COL 35.38
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 8.83 COL 20.38
          BGCOLOR 3 FGCOLOR 15
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-save CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     "ПРОЦЕНТ стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 6.83 COL 20.38
          BGCOLOR 3 FGCOLOR 15
     "Учетная" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 6.83 COL 5.38
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ" VIEW-AS TEXT
          SIZE 15 BY .96 AT ROW 4.83 COL 65.38
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 4.83 COL 50.38
          BGCOLOR 3 FGCOLOR 15
     "Новая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 4.83 COL 35.38
          BGCOLOR 3 FGCOLOR 15
     "Накладная" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 10.83 COL 5.38
          BGCOLOR 3 FGCOLOR 15
     "Старая" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 4.83 COL 20.38
          BGCOLOR 3 FGCOLOR 15
     "Дата" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 10.83 COL 65.38
          BGCOLOR 3 FGCOLOR 15
     "Старый акт" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 10.83 COL 50.38
          BGCOLOR 3 FGCOLOR 15
     "Дата" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 10.83 COL 20.38
          BGCOLOR 3 FGCOLOR 15
     "" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 10.83 COL 35.38
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 8.83 COL 65.38
          BGCOLOR 3 FGCOLOR 15
     "РАЗНИЦА стар." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 8.83 COL 50.38
          BGCOLOR 3 FGCOLOR 15
     "ПРОЦЕНТ нов." VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 6.83 COL 35.38
          BGCOLOR 3 FGCOLOR 15
     "Цена" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 4.83 COL 5.38
          BGCOLOR 3 FGCOLOR 15
     SPACE(63.87) SKIP(11.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка переоценки"
         DEFAULT-BUTTON B-save CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_price-doc-forming B "?" ? ub price-doc-forming
      TABLE: buf_price-doc-forming-gds B "?" ? ub price-doc-forming-gds
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   Custom                                                               */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN buf_price-doc-forming-gds.artic IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN buf_price-doc-forming-gds.b-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR BUTTON b-exit-cycl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN buf_price-doc-forming-gds.excise-doc IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       buf_price-doc-forming-gds.excise-doc:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN ub.goods.gds-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc-gds-obg-last IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc-gds-obj-avrg IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc-in-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN buf_price-doc-forming-gds.pdf-id IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN buf_price-doc-forming-gds.price-sale-doc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN buf_price-doc-forming-gds.prod-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN buf_price-doc-forming-gds.road-tax-doc IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       buf_price-doc-forming-gds.road-tax-doc:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_price-doc-forming-gds
      WHERE recid(buf_price-doc-forming-gds) = p-doc-rec NO-LOCK,
      EACH ub.goods OF buf_price-doc-forming-gds NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "recid(price-doc-forming-gds) = p-doc-rec"
     _Query            is NOT OPENED
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
if line-mode = {&lookup} then return .

assign frame  {&frame-name}
     buf_price-doc-forming-gds.price-sale-doc
     buf_price-doc-forming-gds.road-tax-doc
     buf_price-doc-forming-gds.excise-doc
     .
  assign
    buf_price-doc-forming-gds.d-pcnt          = p-disc
    buf_price-doc-forming-gds.calc-method     = c-m
    buf_price-doc-forming-gds.price-calc-doc  = buf_price-doc-forming-gds.price-sale-doc
    buf_price-doc-forming-gds.price-calc-rubl = buf_price-doc-forming-gds.price-sale-rubl
    buf_price-doc-forming-gds.price-calc-base = buf_price-doc-forming-gds.price-sale-base
    buf_price-doc-forming-gds.price-sale-rubl = buf_price-doc-forming-gds.price-sale-doc * p-exch-rate / p-exch-scale
    buf_price-doc-forming-gds.road-tax-rubl   = buf_price-doc-forming-gds.road-tax-doc   * p-exch-rate / p-exch-scale
    buf_price-doc-forming-gds.excise-rubl     = buf_price-doc-forming-gds.excise-doc     * p-exch-rate / p-exch-scale
    buf_price-doc-forming-gds.price-sale-base = buf_price-doc-forming-gds.price-sale-rubl / p-base-rate * p-base-scale
    buf_price-doc-forming-gds.road-tax-base   = buf_price-doc-forming-gds.road-tax-rubl   / p-base-rate * p-base-scale
    buf_price-doc-forming-gds.excise-base     = buf_price-doc-forming-gds.excise-rubl     / p-base-rate * p-base-scale
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
     buf_price-doc-forming-gds.price-sale-doc
     buf_price-doc-forming-gds.road-tax-doc
     buf_price-doc-forming-gds.excise-doc
     .
  assign
    buf_price-doc-forming-gds.d-pcnt          = p-disc
    buf_price-doc-forming-gds.calc-method     = c-m
    buf_price-doc-forming-gds.price-calc-doc  = buf_price-doc-forming-gds.price-sale-doc
    buf_price-doc-forming-gds.price-calc-rubl = buf_price-doc-forming-gds.price-sale-rubl
    buf_price-doc-forming-gds.price-calc-base = buf_price-doc-forming-gds.price-sale-base
    buf_price-doc-forming-gds.price-sale-rubl = buf_price-doc-forming-gds.price-sale-doc * p-exch-rate / p-exch-scale
    buf_price-doc-forming-gds.road-tax-rubl   = buf_price-doc-forming-gds.road-tax-doc   * p-exch-rate / p-exch-scale
    buf_price-doc-forming-gds.excise-rubl     = buf_price-doc-forming-gds.excise-doc     * p-exch-rate / p-exch-scale
    buf_price-doc-forming-gds.price-sale-base = buf_price-doc-forming-gds.price-sale-rubl / p-base-rate * p-base-scale
    buf_price-doc-forming-gds.road-tax-base   = buf_price-doc-forming-gds.road-tax-rubl   / p-base-rate * p-base-scale
    buf_price-doc-forming-gds.excise-base     = buf_price-doc-forming-gds.excise-rubl     / p-base-rate * p-base-scale
  .
  assign
    stp-cycle  =  false
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buf_price-doc-forming-gds.excise-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buf_price-doc-forming-gds.excise-doc Dialog-Frame
ON LEAVE OF buf_price-doc-forming-gds.excise-doc IN FRAME Dialog-Frame /* Акциз (валюта документа) */
DO:
    run upd-field in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buf_price-doc-forming-gds.price-sale-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buf_price-doc-forming-gds.price-sale-doc Dialog-Frame
ON LEAVE OF buf_price-doc-forming-gds.price-sale-doc IN FRAME Dialog-Frame /* price-sale-doc */
DO:
  run upd-field in this-procedure no-error.
  run calc-pr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buf_price-doc-forming-gds.road-tax-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buf_price-doc-forming-gds.road-tax-doc Dialog-Frame
ON LEAVE OF buf_price-doc-forming-gds.road-tax-doc IN FRAME Dialog-Frame /* Дорожный налог (валюта документа) */
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

if line-mode = {&lookup} then
find first buf_price-doc-forming-gds no-lock where recid(buf_price-doc-forming-gds) = p-doc-rec .
else
find first buf_price-doc-forming-gds exclusive-lock where recid(buf_price-doc-forming-gds) = p-doc-rec .

find first buf_price-doc-forming no-lock where
           buf_price-doc-forming.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-forming.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-forming.pdf-id     = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-forming.pdf-db     = buf_price-doc-forming-gds.pdf-db
           no-error.
find first buf_goods no-lock where
           buf_goods.artic     = buf_price-doc-forming-gds.artic and
           buf_goods.prod-type = buf_price-doc-forming-gds.prod-type and
           buf_goods.prod-code = buf_price-doc-forming-gds.prod-code
           no-error .
find first ub.goods no-lock where
           ub.goods.artic     = buf_price-doc-forming-gds.artic and
           ub.goods.prod-type = buf_price-doc-forming-gds.prod-type and
           ub.goods.prod-code = buf_price-doc-forming-gds.prod-code
           no-error .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = buf_price-doc-forming-gds.b-code no-error .

if buf_bar-code.unit-cli <> buf_goods.unit-base then do:
    message "Изменение в режиме НЕОСНОВНЫЕ ЦЕНЫ !" view-as alert-box information .
    return .
 end.

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
  if  line-mode = {&lookup} then do:
     enable b-exit-cycl with frame {&FRAME-NAME}.
     b-exit-cycl:label = "Выход" .
     disable buf_price-doc-forming-gds.price-sale-doc
     B-save
     b-calc
     b-quit
     with frame {&FRAME-NAME}.
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
define variable v-tmp-price-doc as decimal   no-undo .
define variable v-tmp-price-rubl as decimal   no-undo .
define variable v-tmp-price-base as decimal   no-undo .
v-tmp-price-doc = input frame {&frame-name} buf_price-doc-forming-gds.price-sale-doc .
v-tmp-price-rubl = v-tmp-price-doc   * p-exch-rate / p-exch-scale .
v-tmp-price-base = v-tmp-price-rubl   / p-base-rate * p-base-scale.

if available ub.gds-obj then do:
  if v-rb-base = true  then do:
      assign
          new-avrg = v-tmp-price-base - ub.gds-obj.avrg-base
          new-last = v-tmp-price-base - ub.gds-obj.last-base
          pc-avrg  = (v-tmp-price-base / ub.gds-obj.avrg-base - 1) * 100
          pc-last  = (v-tmp-price-base / ub.gds-obj.last-base - 1) * 100
          old-avrg = old-price - ub.gds-obj.avrg-base
          old-last = old-price - ub.gds-obj.last-base
          op-avrg  = (old-price / ub.gds-obj.avrg-base - 1) * 100
          op-last  = (old-price / ub.gds-obj.last-base - 1) * 100
      .
  end.
  else do:
      assign
          new-avrg = v-tmp-price-rubl - ub.gds-obj.avrg-rubl
          new-last = v-tmp-price-rubl - ub.gds-obj.last-rubl
          pc-avrg  = (v-tmp-price-rubl / ub.gds-obj.avrg-rubl - 1) * 100
          pc-last  = (v-tmp-price-rubl / ub.gds-obj.last-rubl - 1) * 100
          old-avrg = old-price - ub.gds-obj.avrg-rubl
          old-last = old-price - ub.gds-obj.last-rubl
          op-avrg  = (old-price / ub.gds-obj.avrg-rubl - 1) * 100
          op-last  = (old-price / ub.gds-obj.last-rubl - 1) * 100
      .
  end.

  display  pc-avrg pc-last new-avrg new-last old-avrg old-last op-avrg op-last with frame {&frame-name} no-error .
end.
if v-rb-base = true  then do:
    new-old = v-tmp-price-base - old-price.
    pc-prev = (v-tmp-price-base / old-price - 1) * 100.
end.
else do:
    new-old = v-tmp-price-rubl - old-price.
    pc-prev = (v-tmp-price-rubl / old-price - 1) * 100.
end.
display  new-old pc-prev   with frame {&frame-name} no-error .

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
  DISPLAY info b-curr old-price new-old pc-prev loc-gds-obj-avrg op-avrg pc-avrg
          old-avrg new-avrg loc-gds-obg-last op-last pc-last old-last new-last
          loc-in-code loc-in-date akt-num akt-date v-dis
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_price-doc-forming-gds THEN
    DISPLAY buf_price-doc-forming-gds.price-sale-doc
          buf_price-doc-forming-gds.pdf-id buf_price-doc-forming-gds.artic
          buf_price-doc-forming-gds.prod-code
          buf_price-doc-forming-gds.prod-type buf_price-doc-forming-gds.b-code
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.goods THEN
    DISPLAY ub.goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE info buf_price-doc-forming-gds.price-sale-doc b-calc B-save b-quit
         B-Help buf_price-doc-forming-gds.pdf-id
         buf_price-doc-forming-gds.artic buf_price-doc-forming-gds.prod-code
         buf_price-doc-forming-gds.prod-type buf_price-doc-forming-gds.b-code
         b-curr ub.goods.gds-name old-price new-old pc-prev loc-gds-obj-avrg
         op-avrg pc-avrg old-avrg new-avrg loc-gds-obg-last op-last pc-last
         old-last new-last loc-in-code loc-in-date akt-num akt-date v-dis
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
define variable cur-dn like ub.price-list.doc-num   no-undo.
define variable cur-pr like ub.price-list.price-sale   no-undo.

define buffer lp-price-doc-forming for ub.price-doc-forming.

define variable dor-nal as character no-undo .
define variable ff as logical no-undo .

define variable is-petrolium  as logical             no-undo.
define variable is-pieces     as logical             no-undo.
define variable v-rec as recid no-undo.
define variable t-ret as logical no-undo .
define buffer lp-price-doc for ub.price-doc  .
find first buf-price-list-type no-lock where
           buf-price-list-type.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf-price-list-type.plt-db-num = buf_price-doc-forming-gds.plt-db-num
           no-error .

run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf-price-list-type.gop-id , buf-price-list-type.gop-db-num ) .
run metod-delobj-usr (
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id    ,
    buf_price-doc-forming.plt-db-num
   ).

for each x_obj-group :
    v-obj-type = x_obj-group.obj-type .
    v-obj-code = x_obj-group.obj-code .
    if ( v-obj-type = v-cntxt-obj-type and
         v-obj-code = v-cntxt-obj-code )   then leave.

end.


c-m   = {&pr-calc-no} .
v-dis =  p-disc.

  frame {&frame-name}:title = frame {&frame-name}:title + " -  " + line-mode + " объект " + v-obj-type + string (v-obj-code).
  run tax-name in this-procedure ( input {&road-tax}, output  dor-nal) .
  assign buf_price-doc-forming-gds.road-tax-doc :label in frame {&frame-name} = dor-nal .


/* Проверочка наличия Третьего налога */

      If available  buf_goods Then DO:
          v-rec = recid (buf_goods).
           t-ret =  session:SET-WAIT-STATE("GENERAL") .
           { str/is-petrl.i
               buf_price-doc-forming-gds.artic
               buf_price-doc-forming-gds.prod-type
               buf_price-doc-forming-gds.prod-code
               is-petrolium
               is-pieces
           }

           t-ret =  session:SET-WAIT-STATE("") .
              if ( hvrdtax( v-rec ) = true and
                 is-petrolium = true )
                then  do :
                /* изменение дорналога в Румынии-топливо права */
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_overvalue_update':U
                    {&cntxt-object}
                    v-cntxt-host-code-obj
                    v-cntxt-obj-type
                    v-cntxt-obj-code
                    0
                    0
                    0
                    true
                    ff
                  }
                    if ff then do:
                           enable buf_price-doc-forming-gds.road-tax-doc with frame {&frame-name} .
                    end.
              end.
      end.

{ gbl/r-b-abbr.i v-cntxt-host-code-obj b-curr }

find  first ub.gds-obj where
         ub.gds-obj.obj-code = v-obj-code and
         ub.gds-obj.obj-type = v-obj-type and
         ub.gds-obj.gds-code = ub.goods.gds-code
         no-lock no-error.

  if available  ub.gds-obj then
   assign
        loc-gds-obg-last =  if var-pr-r-b = "rubl" then  ub.gds-obj.last-rubl else ub.gds-obj.last-base
        loc-gds-obj-avrg =  if var-pr-r-b = "rubl" then  ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
        loc-in-code = ub.gds-obj.in-code
        loc-in-date = ub.gds-obj.in-date
     .

  { gbl/bcodeprc.i
    v-obj-type
    v-obj-code
    buf_price-doc-forming-gds.b-code
    0
    0
    cur-dn
    cur-pr
    cur-rt
    cur-ex
    no-error }

     old-price =  cur-pr.
     akt-num = cur-dn.
     if cur-dn <> ? then find first lp-price-doc where lp-price-doc.doc-num = cur-dn no-lock no-error .
     if available  lp-price-doc then
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
     buf_price-doc-forming-gds.road-tax-doc
     buf_price-doc-forming-gds.excise-doc
     with frame {&FRAME-NAME}.

   enable
     old-price
     loc-in-code
     loc-in-date
     v-dis
     loc-gds-obg-last
     loc-gds-obj-avrg
     b-curr
     akt-num
     akt-date

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

define variable par-type       as character no-undo .
define variable par-pr-discm       as character no-undo .
define variable p-node-code    like ub.goods.grp-code no-undo .
define variable p-prc-min      as decimal no-undo .
define variable p-prc-max      as decimal no-undo .
define variable p-increase-pc  as decimal no-undo .
define variable p-round-method as character no-undo .
define variable p-base         as decimal no-undo .
define variable p-value-margin as integer no-undo .
define variable p-type-margin  as logical no-undo .
define variable p-value-increase  as integer no-undo .
define variable p-type-increase   as logical no-undo .
define variable p-value-rmethod   as integer no-undo .
define variable p-type-rmethod    as logical no-undo .
define variable v-host-code as integer   no-undo .
define variable new_par as character no-undo init "" .

define buffer bl_goods for ub.goods.
find first bl_goods   where
          bl_goods.artic     = buf_price-doc-forming-gds.artic     and
          bl_goods.prod-code = buf_price-doc-forming-gds.prod-code and
          bl_goods.prod-type = buf_price-doc-forming-gds.prod-type no-lock no-error .
if error-status :error then return error.


for each x_obj-group :
  /* Получим из секции переоценок нужные переменные */
  { gbl/getsect.i run x_obj-group.obj-type x_obj-group.obj-code   {&attr-overval}  }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'pr-discm' then par-pr-discm =  thbjattr_thbj-attr.property-value-character .
  end.
  new_par = new_par + trim(par-pr-discm) + {&delim-par} .
end.
/* проверим */
define variable v-i as integer   no-undo init 0.
  for each  x_obj-group :
      v-i = v-i + 1.
      if entry( v-i, new_par , {&delim-par} ) <> trim ( par-pr-discm ) then do:
          message "На выбранных объектах используются настройки параметра par-pr-discm ! Для расчета выбран "
                  trim ( par-pr-discm ) skip " для товара  " skip
                  "код     :" bl_goods.gds-code  skip
                  "артикул :" bl_goods.artic     skip
                  "производитель :" bl_goods.prod-type skip
                                    bl_goods.prod-code skip
                  "По объекту :" skip
                      v-obj-type  skip
                      v-obj-code  skip
                   view-as alert-box information .
          leave.
      end.
  end.

if trim(par-pr-discm) = "" then return .
    assign
      p-node-code  = bl_goods.grp-code
    .

    run gds-attr-margin-value in this-procedure
    ( input   bl_goods.gds-code,
      input   v-obj-type ,
      input   v-obj-code ,
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
        when "sale-":u then     do: info = info + " от продажной цены " .          end.
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

define variable calc-method    as character no-undo. /* способ расчета цены - исходная цена */
define variable increase-pc    as decimal no-undo. /* процент наценки (с минусом - скидки)*/
define variable round-method   as character no-undo. /* способ округления */
define variable round-base     as decimal no-undo. /* база для округления / коэффициент */

    assign
       calc-method    = buf_price-doc-forming-gds.calc-method
       increase-pc    = p-disc
       round-method   = r-m
       round-base     = r-b
       .

  if decimal ( buf_price-doc-forming-gds.price-sale-doc :screen-value in frame {&frame-name}) <> buf_price-doc-forming-gds.price-sale-doc then do:
    assign
      buf_price-doc-forming-gds.calc-method     = c-m
      buf_price-doc-forming-gds.price-calc-doc  = buf_price-doc-forming-gds.price-sale-doc
      buf_price-doc-forming-gds.price-sale-doc  = decimal ( buf_price-doc-forming-gds.price-sale-doc :screen-value in frame {&frame-name})
      buf_price-doc-forming-gds.price-sale-rubl = buf_price-doc-forming-gds.price-sale-doc  * p-exch-rate / p-exch-scale
      buf_price-doc-forming-gds.price-sale-base = buf_price-doc-forming-gds.price-sale-rubl / p-base-rate * p-base-scale
      .
    /* пересчитываем цены по неосновным для этого кода */
    assign
       calc-method    = c-m
       increase-pc    = p-disc
       round-method   = r-m
       round-base     = r-b
       .
      find current buf_price-doc-forming no-lock .
      run calc-price-sub in this-procedure
         (input  buf_price-doc-forming-gds.b-code,
          input  recid ( buf_price-doc-forming ),
          input  calc-method,
          input  increase-pc,
          input  round-method,
          input  round-base,
          input  doc-code,
          input  common-price,
          input  copy-type,
          input  copy-code,
          output calc-rec) no-error.
       if error-status :error then undo, return error.

  end.


If decimal ( buf_price-doc-forming-gds.excise-doc :screen-value in frame {&frame-name} ) <> buf_price-doc-forming-gds.excise-doc then do:
    /* изменены налоги */
    assign
      buf_price-doc-forming-gds.excise-doc     = decimal ( buf_price-doc-forming-gds.excise-doc     :screen-value in frame {&frame-name})
      buf_price-doc-forming-gds.excise-rubl = buf_price-doc-forming-gds.excise-doc  * p-exch-rate / p-exch-scale
      buf_price-doc-forming-gds.excise-base = buf_price-doc-forming-gds.excise-rubl / p-base-rate * p-base-scale
    .
End.

If decimal ( buf_price-doc-forming-gds.road-tax-doc :screen-value in frame {&frame-name}) <> buf_price-doc-forming-gds.road-tax-doc then do:
/* Проверочка наличия Третьего налога */
       Find first buf_goods no-lock where
            buf_goods.artic     = buf_price-doc-forming-gds.artic and
            buf_goods.prod-type = buf_price-doc-forming-gds.prod-type and
            buf_goods.prod-code = buf_price-doc-forming-gds.prod-code
            no-error .

      If available  buf_goods Then DO:
              if hvrdtax( recid(buf_goods)) = false  then  do :
                  /*нет стеклопосуды */
                 message "В товаре нет компонента цены '"   buf_price-doc-forming-gds.road-tax-doc:label  "' ,  изменять нельзя ! " .
              end.
              /* есть стеклопосуда */
              else do:
                /* изменение стеклопосуды права */
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_overvalue_update':U
                    {&cntxt-object}
                    v-cntxt-host-code-obj
                    v-cntxt-obj-type
                    v-cntxt-obj-code
                    0
                    0
                    0
                    true
                    ff
                  }
                    if not ff then  /* Если прав нет то ..... */    do :
                       buf_price-doc-forming-gds.road-tax-doc   = buf_price-doc-forming-gds.road-tax-doc.
                    end.
                    else  do :
                        buf_price-doc-forming-gds.road-tax-doc = decimal ( buf_price-doc-forming-gds.road-tax-doc:screen-value in frame {&frame-name} ) .
                    end.
                    buf_price-doc-forming-gds.road-tax-rubl = buf_price-doc-forming-gds.road-tax-doc  * p-exch-rate / p-exch-scale.
                    buf_price-doc-forming-gds.road-tax-base = buf_price-doc-forming-gds.road-tax-rubl / p-base-rate * p-base-scale.
              end.
      end.
 end.

 Display buf_price-doc-forming-gds.excise-doc buf_price-doc-forming-gds.price-sale-doc buf_price-doc-forming-gds.road-tax-doc  with frame {&frame-name} .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME