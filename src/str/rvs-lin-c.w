&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rvs-line NO-UNDO LIKE c-rvs-line
field meas-calc-qnty     AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
field meas-calc-dens     AS DECIMAL FORMAT "9.9999999999":U INITIAL 0
field meas-cli-calc-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
field izmer-density      AS DECIMAL FORMAT "9.9999999999":U INITIAL 0
.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран работы со строкой сверки

Автор: Шаланин Сергей
Дата создания: 10/10/16
Author: Shalanin Sergey
Creation date: 10/10/16



*/

define  input parameter parparentproc   as handle    no-undo .
define  input parameter p-code-rec-line as recid     no-undo .
define  input parameter parmode         as character no-undo .
define  input parameter partitle        as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Экран работы со строкой сверки":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ ref/gds-attr.i }
{ str/placelib.i }
/*{ ref/sr-izm.i sr-izmerenia ds}*/
/*{ ref/sr-izm.i " " proc }*/
{ gbl/ptrlprop.i def}
{ gbl/cur-time.i }



define variable g-log        as logical   no-undo.
define variable varexpptr    as character no-undo.
define variable vardata-type as character no-undo.
define variable varlog       as logical   no-undo.
define variable v-return-val as character no-undo initial "":U .
define variable v-min-dens   as decimal   no-undo.
define variable v-max-dens   as decimal   no-undo.
define variable v-attr-type  as character no-undo.
define variable v-gds-ptrl-densities as character no-undo.
define variable pomi-licvalue as character no-undo init 'no':U.
define variable pomi-lictype  as character no-undo.

define variable v-value           as character no-undo.
define variable v-ok              as logical   no-undo.


define buffer buf_goods       for ub.goods .
define buffer bf_rvs-doc      for ub.c-rvs-doc.
define buffer bf_pl-level     for ub.pl-level.
define buffer bf-nxt_pl-level for ub.pl-level.
define buffer buf2_place      for ub.place.

define stream outstream.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-rvs-line

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-rvs-line.system-qnty ~
tt-rvs-line.system-cli-qnty tt-rvs-line.orig-system-qnty ~
tt-rvs-line.orig-system-cli-qnty tt-rvs-line.measure-qnty ~
tt-rvs-line.state-measure-qnty tt-rvs-line.meas-calc-qnty ~
tt-rvs-line.measure-tc-qnty ~
tt-rvs-line.state-measure-tc-qnty tt-rvs-line.density ~
tt-rvs-line.state-density tt-rvs-line.meas-calc-dens ~
tt-rvs-line.izmer-density tt-rvs-line.add-qnty tt-rvs-line.state-add-qnty ~
tt-rvs-line.brutto-qnty tt-rvs-line.state-brutto-qnty ~
tt-rvs-line.brutto-tc-qnty tt-rvs-line.state-brutto-tc-qnty ~
tt-rvs-line.measure-cli-qnty tt-rvs-line.state-measure-cli-qnty ~
tt-rvs-line.meas-cli-calc-qnty  ~
tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty ~
tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol ~
tt-rvs-line.level-total tt-rvs-line.state-level-total ~
tt-rvs-line.level-water tt-rvs-line.state-level-water ~
tt-rvs-line.temperature tt-rvs-line.state-temperature ~
tt-rvs-line.temp-layer1 tt-rvs-line.temp-layer2 tt-rvs-line.temp-layer3 ~
tt-rvs-line.state-temp-layer1 tt-rvs-line.state-temp-layer2 ~
tt-rvs-line.state-temp-layer3 tt-rvs-line.meas-mh-qnty ~
tt-rvs-line.state-mh-qnty tt-rvs-line.meas-am-qnty ~
tt-rvs-line.state-am-qnty tt-rvs-line.meas-cf-qnty ~
tt-rvs-line.state-cf-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-rvs-line.state-measure-qnty tt-rvs-line.meas-calc-qnty ~
tt-rvs-line.state-density tt-rvs-line.state-add-qnty ~
tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-cli-qnty ~
tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total ~
tt-rvs-line.state-temperature tt-rvs-line.state-temp-layer1 ~
tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-rvs-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-rvs-line
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-rvs-line SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-rvs-line SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-rvs-line
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-rvs-line


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-rvs-line.state-measure-qnty ~
tt-rvs-line.meas-calc-qnty tt-rvs-line.state-density ~
tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-qnty ~
tt-rvs-line.state-brutto-cli-qnty tt-rvs-line.state-level-petrol ~
tt-rvs-line.state-level-total tt-rvs-line.state-temperature ~
tt-rvs-line.state-temp-layer1 tt-rvs-line.state-temp-layer2 ~
tt-rvs-line.state-temp-layer3
&Scoped-define ENABLED-TABLES tt-rvs-line
&Scoped-define FIRST-ENABLED-TABLE tt-rvs-line
&Scoped-Define ENABLED-OBJECTS b-save b-cancel b-help RECT-2 RECT-3 b-calc ~
mass-float-cov
&Scoped-Define DISPLAYED-FIELDS tt-rvs-line.system-qnty ~
tt-rvs-line.system-cli-qnty tt-rvs-line.orig-system-qnty ~
tt-rvs-line.orig-system-cli-qnty tt-rvs-line.measure-qnty ~
tt-rvs-line.state-measure-qnty tt-rvs-line.meas-calc-qnty ~
tt-rvs-line.measure-tc-qnty ~
tt-rvs-line.state-measure-tc-qnty tt-rvs-line.density ~
tt-rvs-line.state-density tt-rvs-line.meas-calc-dens ~
tt-rvs-line.izmer-density tt-rvs-line.add-qnty tt-rvs-line.state-add-qnty ~
tt-rvs-line.brutto-qnty tt-rvs-line.state-brutto-qnty ~
tt-rvs-line.brutto-tc-qnty tt-rvs-line.state-brutto-tc-qnty ~
tt-rvs-line.measure-cli-qnty tt-rvs-line.state-measure-cli-qnty ~
tt-rvs-line.meas-cli-calc-qnty ~
tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty ~
tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol ~
tt-rvs-line.level-total tt-rvs-line.state-level-total ~
tt-rvs-line.level-water tt-rvs-line.state-level-water ~
tt-rvs-line.temperature tt-rvs-line.state-temperature ~
tt-rvs-line.temp-layer1 tt-rvs-line.temp-layer2 tt-rvs-line.temp-layer3 ~
tt-rvs-line.state-temp-layer1 tt-rvs-line.state-temp-layer2 ~
tt-rvs-line.state-temp-layer3 tt-rvs-line.meas-mh-qnty ~
tt-rvs-line.state-mh-qnty tt-rvs-line.meas-am-qnty ~
tt-rvs-line.state-am-qnty tt-rvs-line.meas-cf-qnty ~
tt-rvs-line.state-cf-qnty
&Scoped-define DISPLAYED-TABLES tt-rvs-line
&Scoped-define FIRST-DISPLAYED-TABLE tt-rvs-line
&Scoped-Define DISPLAYED-OBJECTS varmeasure-water-qnty varstate-water-qnty ~
varmeasure-water-cli-qnty varstate-water-cli-qnty mass-float-cov

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 Dialog-Frame tt-rvs-line.measure-qnty ~
tt-rvs-line.density tt-rvs-line.add-qnty tt-rvs-line.brutto-qnty ~
tt-rvs-line.measure-cli-qnty tt-rvs-line.brutto-cli-qnty ~
tt-rvs-line.level-petrol tt-rvs-line.level-total tt-rvs-line.level-water ~
tt-rvs-line.temperature tt-rvs-line.temp-layer1 tt-rvs-line.temp-layer2 ~
tt-rvs-line.temp-layer3 tt-rvs-line.meas-mh-qnty tt-rvs-line.meas-am-qnty ~
tt-rvs-line.meas-cf-qnty tt-rvs-line.meas-calc-qnty tt-rvs-line.meas-calc-dens ~
tt-rvs-line.meas-cli-calc-qnty
&Scoped-define List-2 tt-rvs-line.state-measure-qnty ~
tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-density ~
tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-qnty ~
tt-rvs-line.state-brutto-tc-qnty tt-rvs-line.state-measure-cli-qnty ~
tt-rvs-line.state-brutto-cli-qnty tt-rvs-line.state-level-petrol ~
tt-rvs-line.state-level-total tt-rvs-line.state-level-water ~
tt-rvs-line.state-temperature tt-rvs-line.state-temp-layer1 ~
tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3 ~
tt-rvs-line.state-mh-qnty tt-rvs-line.state-am-qnty ~
tt-rvs-line.state-cf-qnty tt-rvs-line.izmer-density
&Scoped-define List-3 tt-rvs-line.state-measure-tc-qnty ~
tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-tc-qnty ~
tt-rvs-line.state-temperature tt-rvs-line.state-temp-layer1 ~
tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc
     LABEL "Рассчитать"
     SIZE 13 BY .88.

DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mass-float-cov AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Масса плавающего покрытия"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE varmeasure-water-cli-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Вес воды"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE varmeasure-water-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Измер. вода"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE varstate-water-cli-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Факт вес воды"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE varstate-water-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Факт вода"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 52.25 BY 21.71.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47.88 BY 21.75.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-rvs-line SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     tt-rvs-line.system-qnty AT ROW 2.25 COL 26 COLON-ALIGNED
          LABEL "Объем расчетно-книжный"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
     tt-rvs-line.system-cli-qnty AT ROW 2.25 COL 74 COLON-ALIGNED
          LABEL "Вес расчетно-книжный"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
     tt-rvs-line.orig-system-qnty AT ROW 3.25 COL 25 COLON-ALIGNED
          LABEL "Первоначально"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
          FGCOLOR 4
     tt-rvs-line.orig-system-cli-qnty AT ROW 3.25 COL 73 COLON-ALIGNED
          LABEL "Первоначально"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
          FGCOLOR 4
     tt-rvs-line.measure-qnty AT ROW 4.75 COL 28.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-qnty AT ROW 4.75 COL 73.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.meas-calc-qnty AT ROW 5.75 COL 34 COLON-ALIGNED WIDGET-ID 20
          LABEL "Остаток рассчит. по измер."
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.measure-tc-qnty AT ROW 6.75 COL 28.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-tc-qnty AT ROW 6.75 COL 73.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.density AT ROW 7.75 COL 28.25 COLON-ALIGNED FORMAT "9.9999999999"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-density AT ROW 7.75 COL 73.25 COLON-ALIGNED FORMAT "9.9999999999"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     b-calc AT ROW 7.75 COL 89 WIDGET-ID 6
     tt-rvs-line.meas-calc-dens AT ROW 8.75 COL 34 COLON-ALIGNED WIDGET-ID 8
          LABEL "Плотность расчит. по измер."
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.izmer-density AT ROW 8.75 COL 79 COLON-ALIGNED WIDGET-ID 4
          LABEL "Плотность измер.для ПО МИ"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.add-qnty AT ROW 9.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-add-qnty AT ROW 9.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-qnty AT ROW 10.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-qnty AT ROW 10.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-tc-qnty AT ROW 11.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-tc-qnty AT ROW 11.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     varmeasure-water-qnty AT ROW 12.75 COL 28.13 COLON-ALIGNED
     varstate-water-qnty AT ROW 12.75 COL 73.5 COLON-ALIGNED
     tt-rvs-line.measure-cli-qnty AT ROW 13.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. вес"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-cli-qnty AT ROW 13.75 COL 73.5 COLON-ALIGNED
          LABEL "Факт вес"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-rvs-line.meas-cli-calc-qnty AT ROW 14.75 COL 34 COLON-ALIGNED WIDGET-ID 10
          LABEL "Вес расчит. по измер."
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-cli-qnty AT ROW 15.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. брутто вес"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-cli-qnty AT ROW 15.75 COL 73.5 COLON-ALIGNED
          LABEL "Факт брутто вес"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     varmeasure-water-cli-qnty AT ROW 16.75 COL 28.13 COLON-ALIGNED
     varstate-water-cli-qnty AT ROW 16.75 COL 73.5 COLON-ALIGNED
     tt-rvs-line.level-petrol AT ROW 17.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. уровень топлива"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-level-petrol AT ROW 17.75 COL 73.5 COLON-ALIGNED format ">>,>>9.999"
          LABEL "Факт уровень топлива"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.level-total AT ROW 18.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. общий уровень"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-level-total AT ROW 18.75 COL 73.5 COLON-ALIGNED format ">>,>>9.999"
          LABEL "Факт общий уровень"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.level-water AT ROW 19.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. уровень воды"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-level-water AT ROW 19.75 COL 73.5 COLON-ALIGNED format ">>,>>9.999"
          LABEL "Факт уровень воды"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.temperature AT ROW 20.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-temperature AT ROW 20.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.temp-layer1 AT ROW 21.75 COL 8.5 COLON-ALIGNED
          LABEL "ИзмT1"
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.temp-layer2 AT ROW 21.75 COL 23.88 COLON-ALIGNED
          LABEL "ИзмT2"
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.temp-layer3 AT ROW 21.75 COL 39.25 COLON-ALIGNED
          LABEL "ИзмT3"
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.state-temp-layer1 AT ROW 21.75 COL 54.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.state-temp-layer2 AT ROW 21.75 COL 71.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.state-temp-layer3 AT ROW 21.75 COL 87.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.meas-mh-qnty AT ROW 22.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.state-mh-qnty AT ROW 22.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.meas-am-qnty AT ROW 23.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-rvs-line.state-am-qnty AT ROW 23.75 COL 73.5 COLON-ALIGNED
          LABEL "Факт сумма оборота"
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.meas-cf-qnty AT ROW 24.75 COL 29.13 COLON-ALIGNED
          LABEL "Измеренное кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.state-cf-qnty AT ROW 24.75 COL 74.5 COLON-ALIGNED
          LABEL "Факт кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     mass-float-cov AT ROW 26.5 COL 54 COLON-ALIGNED WIDGET-ID 2
     RECT-2 AT ROW 4.54 COL 50.25
     RECT-3 AT ROW 4.5 COL 2
     SPACE(53.36) SKIP(2.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ сверки"
         CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-rvs-line T "?" NO-UNDO ub rvs-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME 1                                                         */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-rvs-line.add-qnty IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line.brutto-cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.brutto-qnty IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line.brutto-tc-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-rvs-line.density IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-FORMAT                                               */
/* SETTINGS FOR FILL-IN tt-rvs-line.izmer-density IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-rvs-line.level-petrol IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.level-total IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.level-water IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.meas-am-qnty IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line.meas-calc-dens IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-rvs-line.meas-cf-qnty IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.meas-cli-calc-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-rvs-line.meas-mh-qnty IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line.measure-cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.measure-qnty IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line.measure-tc-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-rvs-line.orig-system-cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line.orig-system-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-add-qnty IN FRAME Dialog-Frame
   2 3                                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-am-qnty IN FRAME Dialog-Frame
   NO-ENABLE 2 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-brutto-cli-qnty IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-brutto-qnty IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-brutto-tc-qnty IN FRAME Dialog-Frame
   NO-ENABLE 2 3                                                        */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-cf-qnty IN FRAME Dialog-Frame
   NO-ENABLE 2 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-density IN FRAME Dialog-Frame
   2 EXP-FORMAT                                                         */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-level-petrol IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-level-total IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-level-water IN FRAME Dialog-Frame
   NO-ENABLE 2 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-measure-cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE 2 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-measure-tc-qnty IN FRAME Dialog-Frame
   NO-ENABLE 2 3                                                        */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-mh-qnty IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-temp-layer1 IN FRAME Dialog-Frame
   2 3                                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-temp-layer2 IN FRAME Dialog-Frame
   2 3                                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-temp-layer3 IN FRAME Dialog-Frame
   2 3                                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line.state-temperature IN FRAME Dialog-Frame
   2 3                                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line.system-cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line.system-qnty IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rvs-line.temp-layer1 IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.temp-layer2 IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.temp-layer3 IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN tt-rvs-line.temperature IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN varmeasure-water-cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varmeasure-water-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varstate-water-cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varstate-water-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-rvs-line"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Документ сверки */
DO:
  assign
    v-return-val = "cancel"
  .
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }
  assign
    v-return-val = "cancel"
  .
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON CHOOSE OF b-calc IN FRAME Dialog-Frame /* Рассчитать */
DO:

define variable v-mm as com-handle.
define variable v-proc as character no-undo.

define variable v-code            as character no-undo.
define variable ii                as integer   no-undo.

define variable place-type        as integer no-undo.
define variable place-SI          as integer no-undo.
define variable place-diameter    as decimal no-undo.
define variable place-ratio-error as decimal no-undo.
define variable dens-prov         as decimal no-undo format "9.9999999999":U.

define variable CalibTable        as character no-undo initial "".
define variable ToolType          as integer no-undo.
define variable A_LevelMeasurementTool  as decimal no-undo.
define variable DeltaAbs_H              as decimal no-undo.
define variable DeltaAbs_H_Water        as decimal no-undo.
define variable DeltaAbs_R              as decimal no-undo.
define variable DeltaAbs_Tv             as decimal no-undo.
define variable DeltaAbs_Tr             as decimal no-undo.
define variable DeltaOtn_N              as decimal no-undo.
define variable DeltaOtn_K              as decimal no-undo.
define variable temp-for-pomi           as integer no-undo.
define variable error-string            as character no-undo.
define variable v-is-meas               as logical no-undo.
define variable v-mm-density            as decimal no-undo.

/*define buffer buf_clob-bind for ub.clob-bind.*/
define buffer buf_sr-izmerenia for ub.sr-izmerenia .
define buffer buf_place     for ub.place.



  assign frame {&frame-name} tt-rvs-line.state-level-total   .
  assign frame {&frame-name} tt-rvs-line.state-level-water   .
  assign frame {&frame-name} tt-rvs-line.state-temp-layer1   .
  assign frame {&frame-name} tt-rvs-line.state-temp-layer2   .
  assign frame {&frame-name} tt-rvs-line.state-temp-layer3   .
  assign frame {&frame-name} tt-rvs-line.state-temperature   .
  assign frame {&frame-name} tt-rvs-line.izmer-density       .
  assign frame {&frame-name} mass-float-cov                  .
  _trpomi :
    do on error undo, return no-apply :
    /*данные по резервуару для ПО МИ*/
    do ii = 1 to num-entries({&list-place-attr},','):
      v-code = entry(ii,{&list-place-attr}) .
      run placelib_get-attr  ( input v-code
                              ,input tt-rvs-line.obj-code
                              ,input tt-rvs-line.obj-type
                              ,input tt-rvs-line.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      case v-code :
        when {&place-type} then do :
          if v-ok then place-type = integer(v-value) .
        end.
        when {&place-SI} then do :
          if v-ok then place-si = integer(v-value) .
        end.
        when {&place-diameter} then do :
          if v-ok then place-diameter = decimal(v-value) .
        end.
/*        when {&place-ratio-error} then do :                  */
/*          if v-ok then place-ratio-error = decimal(v-value) .*/
/*        end.                                                 */
        when {&place-dens-prov} then do :
          if v-ok then dens-prov = decimal(v-value) .
        end.
      end case.
    end.
    /*..........................................*/

    /*градуировочная таблица резервуара для ПО МИ*/
    for last pl-level no-lock
        where pl-level.pl-code  = tt-rvs-line.pl-code
          and pl-level.obj-code = tt-rvs-line.obj-code
          and pl-level.obj-type = tt-rvs-line.obj-type by pl-level.pl-level
          :
          CalibTable = Substitute("&1=&2","1",(pl-level.pl-qnty / (pl-level.pl-level))) .
    end.
    for each  pl-level no-lock
        where pl-level.pl-code  = tt-rvs-line.pl-code
          and pl-level.obj-code = tt-rvs-line.obj-code
          and pl-level.obj-type = tt-rvs-line.obj-type by pl-level.pl-level
          :
          if CalibTable = "" then CalibTable = Substitute("&1=&2",(pl-level.pl-level ),pl-level.pl-qnty ) .
                            else CalibTable = CalibTable + ";" + Substitute("&1=&2",(pl-level.pl-level ),pl-level.pl-qnty ) .
    end.

    CalibTable = CalibTable + ";" + fill({&space-char},(2048 - length(CalibTable))).

    /*..........................................*/

    /*данные по средству измерения резервуара для ПО МИ*/
    if place-si  = 0 then do :
      message
        substitute ("Для складского места &1 не заданно средство измерения",tt-rvs-line.pl-code)
      view-as alert-box error.
      undo _trpomi, return no-apply.
    end.
    else do :
      find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si no-error.
      if not available buf_sr-izmerenia then do :
        message
        "Ошибка работы с библиотекой ПО МИ"
        substitute( 'Не найдено средство измерения с кодом &1', place-si ) skip
        view-as alert-box error.
        undo _trpomi, return no-apply.
      end.
      else do :
        assign
          ToolType               = buf_sr-izmerenia.sr-type-id
          A_LevelMeasurementTool = buf_sr-izmerenia.sr-temp-line
          DeltaAbs_H             = buf_sr-izmerenia.sr-abs-err-neft-water
          DeltaAbs_H_Water       = buf_sr-izmerenia.sr-abs-err-water
          DeltaAbs_R             = buf_sr-izmerenia.sr-abs-err-dens
          DeltaAbs_Tv            = buf_sr-izmerenia.sr-abs-err-temp-vol
          DeltaAbs_Tr            = buf_sr-izmerenia.sr-abs-err-temp-dens
          DeltaOtn_N             = buf_sr-izmerenia.sr-otnos
          .
      end.
    end.
    /*..........................................*/

    { gbl/ptrlprop.i
      run
      tt-rvs-line.obj-type
      tt-rvs-line.obj-code
    }
    if not error-status :error then do:
      if ptrlprop-temp-for-pomi = 1 then temp-for-pomi = 15 .
                                    else temp-for-pomi = 20 .
    end.
    /*метод применяемый к данному типу резервуара и */
    find first buf_place no-lock
         where buf_place.obj-code = tt-rvs-line.obj-code
           and buf_place.obj-type = tt-rvs-line.obj-type
           and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
    if buf_place.is-meas  = yes then do :
      if place-type = 1 then do :
        v-proc = "Rosneft.MethodOfMetering13" .
        DeltaOtn_K = 0.20 .
      end.
      else do :
        v-proc = "Rosneft.MethodOfMetering6" .
        DeltaOtn_K = 0.25 .
      end.
    end.
    else do :
      if place-type = 1 then do :
        v-proc = "Rosneft.MethodOfMetering12" .
        DeltaOtn_K = 0.20 .
      end.
      else do :
        v-proc = "Rosneft.MethodOfMetering5" .
        DeltaOtn_K = 0.25 .
      end.
    end.
    /*..............................................*/
    if tt-rvs-line.izmer-density = ? or tt-rvs-line.izmer-density = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите плотность измер.для ПО МИ"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.izmer-density in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-level-total = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите факт. общий уровень"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-total in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-level-water = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите факт. уровень топлива"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-petrol in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temp-layer1 = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите Т1"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temp-layer1 in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temp-layer2 = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите Т2"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temp-layer2 in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temp-layer3 = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите Т3"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temp-layer3 in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temperature = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите температуру"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temperature in frame {&frame-name}.
      undo _trpomi, return .
    end.


    RELEASE OBJECT v-mm NO-ERROR.
    v-mm = ?.

    CREATE value(v-proc) v-mm no-error.
    IF ERROR-STATUS:ERROR
    OR NOT VALID-HANDLE(v-mm)
    THEN DO:
      message
      "Не удается подключиться к COM-серверу библиотеки для работы с ПО МИ "
      view-as alert-box error.
      enable
        tt-rvs-line.state-density
        tt-rvs-line.state-measure-qnty
      with frame Dialog-Frame.
      RELEASE OBJECT v-mm NO-ERROR.
      v-mm = ?.
      undo _trpomi, return no-apply .
    END.
    ELSE DO :
      ASSIGN
        v-mm:H                      = integer( tt-rvs-line.state-level-total) * 10
        v-mm:H_water                = integer( tt-rvs-line.state-level-water) * 10
        v-mm:CalibrationTable       = CalibTable
        v-mm:Tr                     = tt-rvs-line.state-temperature
        v-mm:R                      = ( tt-rvs-line.izmer-density * 1000 )
        v-mm:Tcy                    = temp-for-pomi
        v-mm:ToolType               = ToolType
        v-mm:DeltaOtn_K             = DeltaOtn_K
        v-mm:A_Reservoir            = 0.0000125
        v-mm:DeltaAbs_H             = DeltaAbs_H
        v-mm:DeltaAbs_H_Water       = DeltaAbs_H_Water
        v-mm:DeltaAbs_R             = DeltaAbs_R
        v-mm:DeltaAbs_Tv            = DeltaAbs_Tv
        v-mm:DeltaAbs_Tr            = DeltaAbs_Tr
        v-mm:DeltaOtn_N             = DeltaOtn_N
      .
      output stream outstream to value ("pomi.log")  append.
      put stream outstream
                                      cur-time-string()                  format "x(16)"  skip
          'Процедура                ' v-proc                             format "x(128)" skip
          'H                      = ' ( tt-rvs-line.state-level-total * 10 )             skip
          'H_water                = ' ( tt-rvs-line.state-level-water * 10 )             skip
          'CalibrationTable       = ' CalibTable                        format "x(2048)" skip
          'Tr                     = ' tt-rvs-line.state-temperature                      skip
          'R                      = ' ( tt-rvs-line.izmer-density * 1000 )               skip
          'Tcy                    = ' temp-for-pomi                                      skip
          'ToolType               = ' ToolType                                           skip
          'DeltaOtn_K             = ' DeltaOtn_K                                         skip
          'A_Reservoir            = ' 0.0000125                                          skip
          'DeltaAbs_H             = ' DeltaAbs_H                                         skip
          'DeltaAbs_H_Water       = ' DeltaAbs_H_Water                                   skip
          'DeltaAbs_R             = ' DeltaAbs_R                                         skip
          'DeltaAbs_Tv            = ' DeltaAbs_Tv                                        skip
          'DeltaAbs_Tr            = ' DeltaAbs_Tr                                        skip
          'DeltaOtn_N             = ' DeltaOtn_N                                         skip
      .

      if place-type = 1 then do :
        v-mm:Rprov = ( dens-prov * 1000 ) .
        v-mm:Mpokr = mass-float-cov .
        put stream outstream
          "v-mm:Rprov             = " ( dens-prov * 1000 ) skip
          "v-mm:Mpokr             = " mass-float-cov skip
        .
      end.
      find first buf_place no-lock
          where buf_place.obj-code = tt-rvs-line.obj-code
            and buf_place.obj-type = tt-rvs-line.obj-type
            and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
      if buf_place.is-meas  = yes then do :
         v-mm:Tv = tt-rvs-line.state-temperature .
      end.
      else do :
        if place-type <> 1 then do :
          v-mm:D = place-diameter .
          put stream outstream
            "v-mm:D                      = " place-diameter                skip
          .
        end.
        assign
          v-mm:T_lower                = tt-rvs-line.state-temp-layer1
          v-mm:T_middle               = tt-rvs-line.state-temp-layer2
          v-mm:T_upper                = tt-rvs-line.state-temp-layer3
          v-mm:A_LevelMeasurementTool = A_LevelMeasurementTool
        .
        put stream outstream
          "v-mm:T_lower                = " tt-rvs-line.state-temp-layer1 skip
          "v-mm:T_middle               = " tt-rvs-line.state-temp-layer2 skip
          "v-mm:T_upper                = " tt-rvs-line.state-temp-layer3 skip
          "v-mm:A_LevelMeasurementTool = " A_LevelMeasurementTool        skip
        .
      end.
      output stream outstream close.
      v-mm:Exec() .
      if v-mm:Result <> 0 then do :
        error-string = v-mm:ResultDetail .
        output stream outstream to value ("pomi.log")  append.
        put stream outstream error-string format "X(1024)" skip.
        message
        substitute('Ошибка работы библиотеки ПО МИ. &1',error-string)
        view-as alert-box error.
        RELEASE OBJECT v-mm NO-ERROR.
        v-mm = ?.
        output stream outstream close.
        undo _trpomi, return no-apply .
      end.
      else do :
        v-mm-density = decimal(v-mm:Rcy) / 1000 .
        assign
          tt-rvs-line.state-measure-qnty     = v-mm:Vcy
          tt-rvs-line.state-density          = v-mm-density
          tt-rvs-line.state-measure-cli-qnty = tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density
        .
        display
          tt-rvs-line.state-measure-qnty
          tt-rvs-line.state-density
          tt-rvs-line.state-measure-cli-qnty
         with frame {&frame-name} .
        output stream outstream to value ("pomi.log")  append.
        put stream outstream
        "v-mm:Vcy"  tt-rvs-line.state-measure-qnty     skip
        "v-mm:Rcy"  tt-rvs-line.state-density          skip .
        output stream outstream close.
        run volume-water no-error.
        if error-status :error then do :
                                 enable
                                   tt-rvs-line.state-density
                                   tt-rvs-line.state-measure-qnty
                                   tt-rvs-line.state-add-qnty
                                   tt-rvs-line.state-brutto-qnty
                                   tt-rvs-line.state-brutto-cli-qnty
                                 with frame Dialog-Frame.
                                 undo _trpomi, return .
                               end.
        run chg-density no-error.
        if error-status :error then do :
                                 enable
                                   tt-rvs-line.state-density
                                   tt-rvs-line.state-measure-qnty
                                   tt-rvs-line.state-add-qnty
                                   tt-rvs-line.state-brutto-qnty
                                   tt-rvs-line.state-brutto-cli-qnty
                                 with frame Dialog-Frame.
                                 undo _trpomi, return .
                               end.
        run weath-water no-error.
        if error-status:error then do :
                                enable
                                  tt-rvs-line.state-density
                                  tt-rvs-line.state-measure-qnty
                                  tt-rvs-line.state-add-qnty
                                  tt-rvs-line.state-brutto-qnty
                                  tt-rvs-line.state-brutto-cli-qnty
                                with frame Dialog-Frame.
                                undo _trpomi, return .
                              end.
      end.
    END.
  end.
  enable
    tt-rvs-line.state-density
    tt-rvs-line.state-measure-qnty
    tt-rvs-line.state-add-qnty
    tt-rvs-line.state-brutto-qnty
    tt-rvs-line.state-brutto-cli-qnty
  with frame Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Ввод */
DO:
  define variable v-water     as decimal   no-undo .
  define variable v-water-cli as decimal   no-undo .

  { gbl/stdbtn.i }
  if input frame {&frame-name} tt-rvs-line.state-measure-qnty >
     input frame {&frame-name} tt-rvs-line.state-brutto-qnty  then do:
     message "Объем топлива больше общего объема."
     view-as alert-box error.
     apply "entry" to tt-rvs-line.state-measure-qnty in frame {&frame-name}.
     return no-apply.
  end.

  assign
    v-water     = input frame {&frame-name} tt-rvs-line.state-brutto-qnty - input frame {&frame-name} tt-rvs-line.state-measure-qnty
    v-water-cli = input frame {&frame-name} tt-rvs-line.state-brutto-cli-qnty - input frame {&frame-name} tt-rvs-line.state-measure-cli-qnty
  .

  if ( v-water <> ?
       and v-water <> 0
       and ( v-water-cli = ?
             or v-water-cli = 0
           )
     )
     or
     ( v-water-cli <> ?
       and v-water-cli <> 0
       and ( v-water = ?
             or v-water = 0
           )
     )
  then do:
     message
       substitute( "Объем воды (&1) не соответствует его весу (&2)!", v-water, v-water-cli )
       view-as alert-box error.
     return no-apply.
  end.

  find first c-rvs-line where recid(c-rvs-line) =  p-code-rec-line no-error.
  /* Все validation */
  run level-water  in this-procedure ( input yes ) no-error.
  if error-status :error then do:
    apply "ENTRY":U to tt-rvs-line.state-level-petrol in frame {&frame-name}.
    return no-apply.
  end.
  run volume-water in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  run chg-density  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  run weath-water  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  assign frame {&frame-name} {&list-3}.
  buffer-copy tt-rvs-line to c-rvs-line.

  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "izmer-density" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "izmer-density"
      rvs-line-attr.attr-value = string(tt-rvs-line.izmer-density)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.izmer-density) .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "mass-float-cov" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "mass-float-cov"
      rvs-line-attr.attr-value = string(mass-float-cov) .
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(mass-float-cov) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-add-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-add-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-add-qnty IN FRAME Dialog-Frame /* Факт в трубопроводе */
DO:
  assign frame {&frame-name} {&self-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-add-qnty Dialog-Frame
ON return OF tt-rvs-line.state-add-qnty IN FRAME Dialog-Frame /* Факт в трубопроводе */
DO:
  apply "entry" to tt-rvs-line.state-brutto-qnty in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-brutto-cli-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-brutto-cli-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-brutto-cli-qnty IN FRAME Dialog-Frame /* Факт брутто вес */
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  run weath-water no-error.
  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-brutto-cli-qnty Dialog-Frame
ON return OF tt-rvs-line.state-brutto-cli-qnty IN FRAME Dialog-Frame /* Факт брутто вес */
DO:
  apply "entry" to tt-rvs-line.state-level-petrol in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-brutto-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-brutto-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-brutto-qnty IN FRAME Dialog-Frame /* Факт брутто */
DO:
if input frame {&frame-name} {&self-name} <> {&self-name} then do:
  run volume-water no-error.
  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-brutto-qnty Dialog-Frame
ON return OF tt-rvs-line.state-brutto-qnty IN FRAME Dialog-Frame /* Факт брутто */
DO:
  apply "entry" to tt-rvs-line.state-measure-tc-qnty in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-brutto-tc-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-brutto-tc-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-brutto-tc-qnty IN FRAME Dialog-Frame /* Факт брутто(tc) */
DO:
  assign frame {&frame-name} tt-rvs-line.state-brutto-tc-qnty.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-brutto-tc-qnty Dialog-Frame
ON return OF tt-rvs-line.state-brutto-tc-qnty IN FRAME Dialog-Frame /* Факт брутто(tc) */
DO:
  apply "entry" to tt-rvs-line.state-brutto-cli-qnty in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-density Dialog-Frame
ON LEAVE OF tt-rvs-line.state-density IN FRAME Dialog-Frame /* Плотность */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
     run chg-density no-error.
     if error-status:error then return no-apply.
     run weath-water no-error.
     if error-status:error then return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-density Dialog-Frame
ON return OF tt-rvs-line.state-density IN FRAME Dialog-Frame /* Плотность */
DO:
  apply "entry" to tt-rvs-line.state-add-qnty in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-rvs-line.izmer-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.izmer-density Dialog-Frame
ON LEAVE OF tt-rvs-line.izmer-density IN FRAME Dialog-Frame /* Плотность */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    if input frame {&frame-name} tt-rvs-line.izmer-density = ?
      or ( buf_goods.unit-base <> buf_goods.unit-cli
          and ( input frame {&frame-name} tt-rvs-line.izmer-density <= 0
                or input frame {&frame-name} tt-rvs-line.izmer-density >= 1
              )
        )
      or ( buf_goods.unit-base = buf_goods.unit-cli
          and input frame {&frame-name} tt-rvs-line.izmer-density <> 1
        )
    then do:
      message "Неверно определена плотность топлива измер. для ПО МИ." view-as alert-box error.
      apply "entry" to tt-rvs-line.izmer-density .
      return no-apply.
    end.

    assign frame {&frame-name} tt-rvs-line.izmer-density.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-rvs-line.izmer-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.izmer-density Dialog-Frame
ON RETURN OF tt-rvs-line.izmer-density IN FRAME Dialog-Frame /* Плотность */
DO:
  apply "entry" to tt-rvs-line.state-level-petrol in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME tt-rvs-line.state-level-petrol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-level-petrol Dialog-Frame
ON LEAVE OF tt-rvs-line.state-level-petrol IN FRAME Dialog-Frame /* Факт уровень топлива */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    RUN local-tarir ("state-level-petrol").
    run level-water in this-procedure ( input no ) /* no-error */ .
    /* if error-status :error then do: return no-apply. end. */
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-level-petrol Dialog-Frame
ON return OF tt-rvs-line.state-level-petrol IN FRAME Dialog-Frame /* Факт уровень топлива */
DO:
  apply "entry" to tt-rvs-line.state-level-total in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-level-total
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-level-total Dialog-Frame
ON LEAVE OF tt-rvs-line.state-level-total IN FRAME Dialog-Frame /* Факт общий уровень */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    RUN local-tarir ("state-level-total").
    run level-water in this-procedure ( input no ) /* no-error */ .
    /* if error-status :error then do: return no-apply. end. */
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-level-total Dialog-Frame
ON return OF tt-rvs-line.state-level-total IN FRAME Dialog-Frame /* Факт общий уровень */
DO:
  apply "entry" to tt-rvs-line.state-temperature in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-measure-cli-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-cli-qnty Dialog-Frame
ON return OF tt-rvs-line.state-measure-cli-qnty IN FRAME Dialog-Frame /* Факт вес */
DO:
  apply "entry" to tt-rvs-line.state-brutto-cli-qnty in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-measure-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame /* Факт остаток */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
     run volume-water no-error.
     if error-status:error then return no-apply.
     if tt-rvs-line.state-density <> 0 and
        tt-rvs-line.state-density <> ? then do:
        run chg-density no-error.
        if error-status:error then return no-apply.
        run weath-water no-error.
        if error-status:error then return no-apply.
     end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-qnty Dialog-Frame
ON return OF tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame /* Факт остаток */
DO:
  apply "entry" to tt-rvs-line.state-measure-tc-qnty in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-measure-tc-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-tc-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-measure-tc-qnty IN FRAME Dialog-Frame /* Факт остаток(tc) */
DO:
  assign frame {&frame-name} tt-rvs-line.state-measure-tc-qnty.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-tc-qnty Dialog-Frame
ON return OF tt-rvs-line.state-measure-tc-qnty IN FRAME Dialog-Frame /* Факт остаток(tc) */
DO:
  apply "entry" to tt-rvs-line.state-density in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-temp-layer1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-temp-layer1 Dialog-Frame
ON LEAVE OF tt-rvs-line.state-temp-layer1 IN FRAME Dialog-Frame /* T1 */
DO:
    assign frame {&frame-name} {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-temp-layer1 Dialog-Frame
ON return OF tt-rvs-line.state-temp-layer1 IN FRAME Dialog-Frame /* T1 */
DO:
  apply "entry" to tt-rvs-line.state-temp-layer2 in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-temp-layer2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-temp-layer2 Dialog-Frame
ON LEAVE OF tt-rvs-line.state-temp-layer2 IN FRAME Dialog-Frame /* T2 */
DO:
    assign frame {&frame-name} {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-temp-layer2 Dialog-Frame
ON return OF tt-rvs-line.state-temp-layer2 IN FRAME Dialog-Frame /* T2 */
DO:
  apply "entry" to tt-rvs-line.state-temp-layer3 in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-temp-layer3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-temp-layer3 Dialog-Frame
ON LEAVE OF tt-rvs-line.state-temp-layer3 IN FRAME Dialog-Frame /* T3 */
DO:
    assign frame {&frame-name} {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-temp-layer3 Dialog-Frame
ON return OF tt-rvs-line.state-temp-layer3 IN FRAME Dialog-Frame /* T3 */
DO:
  if pomi-licvalue  = "yes" then do:
    apply "entry" to mass-float-cov in frame {&frame-name}.
    return no-apply.
  end.
  else do :
    apply "entry" to b-save in frame {&frame-name}.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mass-float-cov Dialog-Frame
ON return OF mass-float-cov IN FRAME Dialog-Frame /* масса плавающего покрытия */
DO:
  apply "entry" to b-calc in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-temperature
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-temperature Dialog-Frame
ON LEAVE OF tt-rvs-line.state-temperature IN FRAME Dialog-Frame /* Температура */
DO:
    assign frame {&frame-name} {&self-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-temperature Dialog-Frame
ON return OF tt-rvs-line.state-temperature IN FRAME Dialog-Frame /* Температура */
DO:
  apply "entry" to tt-rvs-line.state-temp-layer1 in frame {&frame-name}.
  return no-apply.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }

  
     find first c-rvs-line where recid(c-rvs-line) =  p-code-rec-line no-lock no-error.
  if not available c-rvs-line then do:
     message "Неверно переданы параметры."
             "Не найдена строка сверка " p-code-rec-line " ."
     view-as alert-box error.
     return error.
  end.
  create tt-rvs-line.
  buffer-copy c-rvs-line to tt-rvs-line.
  release rvs-line.
  find first bf_rvs-doc where bf_rvs-doc.rvs-code = tt-rvs-line.rvs-code.
  { str/gtexpptr.i bf_rvs-doc.host-code bf_rvs-doc.obj-type bf_rvs-doc.obj-code yes no varexpptr no-error }
  if error-status :error or lookup( varexpptr, {&calc-petrol-list} ) = 0 then do: assign varexpptr = ?. end.

  RUN enable_UI IN THIS-PROCEDURE.

  if tt-rvs-line.system-qnty <> tt-rvs-line.orig-system-qnty
    and tt-rvs-line.system-cli-qnty <> tt-rvs-line.orig-system-cli-qnty
  then do:
    assign
      tt-rvs-line.orig-system-cli-qnty :label in frame Dialog-Frame = "":U
    .
  end.
  if tt-rvs-line.system-qnty <> tt-rvs-line.orig-system-qnty then do:
    display
      tt-rvs-line.orig-system-qnty
      with frame Dialog-Frame.
  end.
  else do:
    hide
      tt-rvs-line.orig-system-qnty
      in frame Dialog-Frame.
  end.
  if tt-rvs-line.system-cli-qnty <> tt-rvs-line.orig-system-cli-qnty then do:
    display
      tt-rvs-line.orig-system-cli-qnty
      with frame Dialog-Frame.
  end.
  else do:
    hide
      tt-rvs-line.orig-system-cli-qnty
      in frame Dialog-Frame.
  end.

  if parmode <> {&update} then do:
     disable {&list-2} with frame {&frame-name}.
  end.
  else
    do:
      find first buf2_place no-lock where
                 buf2_place.obj-code = tt-rvs-line.obj-code and
                 buf2_place.obj-type = tt-rvs-line.obj-type and
                 buf2_place.pl-code  = tt-rvs-line.pl-code
      no-error.  
      case bf_rvs-doc.rvs-type:
        when {&rvs-before-doc} or when {&rvs-after-doc} then
        do: 
          if available buf2_place then
          do:
            if buf2_place.is-meas = yes then
            do:
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-on-doc_upd-revision':U
                {&cntxt-object}
                bf_rvs-doc.host-code
                bf_rvs-doc.obj-type
                bf_rvs-doc.obj-code
                0
                0
                0
                false
                g-log
               }
             end.
             else
             do:
               g-log = yes.
             end.
          end.
        end.
        when {&rvs-shift}
        then do:
            if available buf2_place then do :  
                if buf2_place.is-meas then do :
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_rvs-shift_upd-revision':U
                    {&cntxt-object}
                    bf_rvs-doc.host-code
                    bf_rvs-doc.obj-type
                    bf_rvs-doc.obj-code
                    0
                    0
                    0
                    false
                    g-log
                  }
                end.
                else do :
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_rvs-shift_upd-immeas':U
                    {&cntxt-object}
                    bf_rvs-doc.host-code
                    bf_rvs-doc.obj-type
                    bf_rvs-doc.obj-code
                    0
                    0
                    0
                    false
                    g-log
                  } 
                end. 
            end.        
        end.
        when {&rvs-control}
        then do:
            if available buf2_place then do :  
                if buf2_place.is-meas then do :
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_rvs-control_upd-revision':U
                    {&cntxt-object}
                    bf_rvs-doc.host-code
                    bf_rvs-doc.obj-type
                    bf_rvs-doc.obj-code
                    0
                    0
                    0
                    false
                    g-log
                  }
                end.
                else do :
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_rvs-control_upd-immeas':U
                    {&cntxt-object}
                    bf_rvs-doc.host-code
                    bf_rvs-doc.obj-type
                    bf_rvs-doc.obj-code
                    0
                    0
                    0
                    false
                    g-log
                  } 
                end.
            end.         
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип сверки" skip
            "Тип документа" bf_rvs-doc.rvs-type skip
            "Код документа" bf_rvs-doc.rvs-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
     if not g-log then do:
        disable {&list-2} with frame {&frame-name}.
     end.
  end.
  if parmode <> {&update} then do:
    disable b-save with frame {&frame-name}.
  end.
  run volume-measure-water in this-procedure                 no-error.
  run weath-measure-water  in this-procedure                 no-error.
  run level-measure-water  in this-procedure                 no-error.
  run volume-water         in this-procedure                 no-error.
  run weath-water          in this-procedure                 no-error.
  run level-water          in this-procedure ( input no ) /* no-error */ .
  find first buf_goods no-lock
    where buf_goods.gds-code = tt-rvs-line.gds-code
    .
  if buf_goods.unit-base = buf_goods.unit-cli then do:
    assign
      tt-rvs-line.density       = 1.0
      tt-rvs-line.state-density = 1.0
    .
    disable
      tt-rvs-line.density
      tt-rvs-line.state-density
      with frame {&frame-name}.
  end.
  /*   Отключили определение параметра использования ПО к МИ, т.к. приведение плотности теперь работает только при приемки    
  run gbl/conf-rd.p ("pomi-lic", "", "", 0, "", "", "", no, output pomi-licvalue, output pomi-lictype) no-error.
  
  if error-status:error or
  */
  
  if pomi-licvalue = "no" then do :
    hide
      tt-rvs-line.meas-calc-qnty
      tt-rvs-line.meas-calc-dens
      tt-rvs-line.meas-cli-calc-qnty
      tt-rvs-line.izmer-density
      mass-float-cov
      b-calc
      in frame Dialog-Frame.
  end.
  else  do :
    view
      tt-rvs-line.izmer-density
    in frame Dialog-Frame.
    enable
      tt-rvs-line.izmer-density
    with frame Dialog-Frame.
    disable
      tt-rvs-line.state-density
      tt-rvs-line.state-measure-qnty
      tt-rvs-line.state-add-qnty
      tt-rvs-line.state-brutto-qnty
      tt-rvs-line.state-brutto-cli-qnty
    with frame Dialog-Frame.

    for each rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         :
          case rvs-line-attr.attr-code :
            when "meas-calc-qnty" then do :
              tt-rvs-line.meas-calc-qnty = decimal(rvs-line-attr.attr-value) .
            end.
            when "meas-calc-dens" then do :
              tt-rvs-line.meas-calc-dens = decimal(rvs-line-attr.attr-value) .
            end.
            when "meas-cli-calc-qnty" then do :
              tt-rvs-line.meas-cli-calc-qnty = decimal(rvs-line-attr.attr-value) .
            end.
            when "izmer-density" then do :
              tt-rvs-line.izmer-density = decimal(rvs-line-attr.attr-value) .
            end.
            when "mass-float-cov" then do :
              mass-float-cov = decimal(rvs-line-attr.attr-value) .
            end.
          end case.
    end.
    display
      tt-rvs-line.meas-calc-qnty
      tt-rvs-line.meas-calc-dens
      tt-rvs-line.meas-cli-calc-qnty
      tt-rvs-line.izmer-density
      mass-float-cov
    with frame {&frame-name}.
    run placelib_get-attr  ( input {&place-type}
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
    if v-ok then do :
      if integer(v-value) <> 1 then
      hide
        mass-float-cov
      in frame {&frame-name}.
    end.
  end.
  if parmode <> {&update} then do:
     disable tt-rvs-line.izmer-density with frame {&frame-name}.
     disable mass-float-cov with frame {&frame-name}.
     disable b-calc with frame {&frame-name}.
  end.
  assign frame {&frame-name} :title = frame {&frame-name} :title + " - " + parmode
                                    + " - " +  partitle.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
return v-return-val .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-density Dialog-Frame
PROCEDURE chg-density :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if input frame {&frame-name} tt-rvs-line.state-density = ?
  or ( buf_goods.unit-base <> buf_goods.unit-cli
       and ( input frame {&frame-name} tt-rvs-line.state-density <= 0
             or input frame {&frame-name} tt-rvs-line.state-density >= 1
           )
     )
  or ( buf_goods.unit-base = buf_goods.unit-cli
       and input frame {&frame-name} tt-rvs-line.state-density <> 1
     )
then do:
   message "Неверно определена плотность топлива." view-as alert-box error.
   return error.
end.

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
    if (input frame {&frame-name} tt-rvs-line.state-density) < v-min-dens
    or (input frame {&frame-name} tt-rvs-line.state-density) > v-max-dens
    then do:
      message
        substitute("Введенное значение плотности находится вне заданного диапазона: &1.",
        v-gds-ptrl-densities )
        view-as alert-box error .
      return error.
    end.
  end.

assign frame {&frame-name} tt-rvs-line.state-density.
assign
  tt-rvs-line.state-measure-cli-qnty = tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density
.
display tt-rvs-line.state-measure-cli-qnty with frame {&frame-name}.
if tt-rvs-line.state-measure-cli-qnty > tt-rvs-line.state-brutto-cli-qnty then do:
  message "Измеренный вес больше веса брутто. Подставить измеренный вес в вес брутто?"
  view-as alert-box question buttons yes-no update varlog.
  if varlog = yes then do:
    assign
      tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty.
    display tt-rvs-line.state-brutto-cli-qnty with frame {&frame-name}.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY varmeasure-water-qnty varstate-water-qnty varmeasure-water-cli-qnty
          varstate-water-cli-qnty mass-float-cov
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-rvs-line THEN
    DISPLAY tt-rvs-line.system-qnty tt-rvs-line.system-cli-qnty
          tt-rvs-line.orig-system-qnty tt-rvs-line.orig-system-cli-qnty
          tt-rvs-line.measure-qnty tt-rvs-line.state-measure-qnty
          tt-rvs-line.meas-calc-qnty tt-rvs-line.measure-tc-qnty tt-rvs-line.state-measure-tc-qnty
          tt-rvs-line.density tt-rvs-line.state-density
          tt-rvs-line.meas-calc-dens tt-rvs-line.izmer-density
          tt-rvs-line.add-qnty tt-rvs-line.state-add-qnty
          tt-rvs-line.brutto-qnty tt-rvs-line.state-brutto-qnty
          tt-rvs-line.brutto-tc-qnty tt-rvs-line.state-brutto-tc-qnty
          tt-rvs-line.measure-cli-qnty tt-rvs-line.state-measure-cli-qnty
          tt-rvs-line.meas-cli-calc-qnty
          tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty
          tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol
          tt-rvs-line.level-total tt-rvs-line.state-level-total
          tt-rvs-line.level-water tt-rvs-line.state-level-water
          tt-rvs-line.temperature tt-rvs-line.state-temperature
          tt-rvs-line.temp-layer1 tt-rvs-line.temp-layer2
          tt-rvs-line.temp-layer3 tt-rvs-line.state-temp-layer1
          tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3
          tt-rvs-line.meas-mh-qnty tt-rvs-line.state-mh-qnty
          tt-rvs-line.meas-am-qnty tt-rvs-line.state-am-qnty
          tt-rvs-line.meas-cf-qnty tt-rvs-line.state-cf-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help RECT-2 RECT-3 tt-rvs-line.state-measure-qnty
         tt-rvs-line.state-density b-calc tt-rvs-line.state-add-qnty
         tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-cli-qnty
         tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total
         tt-rvs-line.state-temperature tt-rvs-line.state-temp-layer1
         tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3
         mass-float-cov
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE level-measure-water Dialog-Frame
PROCEDURE level-measure-water :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
display input frame {&frame-name} tt-rvs-line.level-total -
        input frame {&frame-name} tt-rvs-line.level-petrol @
        tt-rvs-line.level-water with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE level-water Dialog-Frame
PROCEDURE level-water :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-mode as logical no-undo.

  define variable is_OK as logical no-undo initial yes.

  if input frame {&frame-name} tt-rvs-line.state-level-petrol >
     input frame {&frame-name} tt-rvs-line.state-level-total  then do:
    assign is_OK = no.
    if p-mode = yes then do:
      message "Уровень топлива больше значения общего уровня." view-as alert-box error.
      return error.
    end.
  end.
  display input frame {&frame-name} tt-rvs-line.state-level-total  -
          input frame {&frame-name} tt-rvs-line.state-level-petrol @
                                    tt-rvs-line.state-level-water
  with frame {&frame-name}.
  if is_OK = yes then do:
    assign frame {&frame-name} tt-rvs-line.state-level-water
                               tt-rvs-line.state-level-petrol
                               tt-rvs-line.state-level-total.
  end.
END PROCEDURE. /* level-water */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-tarir Dialog-Frame
PROCEDURE local-tarir :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER paraction AS CHARACTER NO-UNDO.
DEFINE VARIABLE varlevel-sm-q AS DECIMAL NO-UNDO.
define variable vartarirvalue as character no-undo.
define variable vartarirtype  as character no-undo.
define variable varlevel-sm   as integer   no-undo.
define buffer bf_place for ub.place.

run gbl/conf-rd.p ("tarir", "", "", 0, "", "", "", no, output vartarirvalue, output vartarirtype) no-error.
/*Если работаем по тарировочным таблицам*/
if vartarirvalue = "yes" then do:
  CASE paraction:
    WHEN "state-level-total" THEN DO:
      ASSIGN
        varlevel-sm-q = input frame {&frame-name} tt-rvs-line.state-level-total.
    END.
    WHEN "state-level-petrol" THEN DO:
      ASSIGN
        varlevel-sm-q = input frame {&frame-name} tt-rvs-line.state-level-petrol.
    END.
  END CASE.
  assign
    varlevel-sm = trunc (varlevel-sm-q, 0).
  find first bf_place where bf_place.pl-code = tt-rvs-line.pl-code no-lock.
  find first bf_pl-level where bf_pl-level.obj-type = tt-rvs-line.obj-type      and
                               bf_pl-level.obj-code = tt-rvs-line.obj-code      and
                               bf_pl-level.pl-code  = bf_place.pl-code          and
                               bf_pl-level.pl-level = varlevel-sm            no-error.
  if not available bf_pl-level then do:
    message "Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара " bf_place.loc1 " не задан объем для уровня " varlevel-sm view-as alert-box error.
    return no-apply.
  end.
  else do:
    if varlevel-sm = varlevel-sm-q then do:
      if error-status:error then return no-apply.
      display bf_pl-level.pl-qnty @ tt-rvs-line.state-brutto-qnty bf_pl-level.pl-qnty @ tt-rvs-line.state-measure-qnty with frame {&frame-name}.
    end.
    else do:
      assign
        varlevel-sm = varlevel-sm + 1.
      find first bf-nxt_pl-level where bf-nxt_pl-level.obj-type = tt-rvs-line.obj-type   and
                                       bf-nxt_pl-level.obj-code = tt-rvs-line.obj-code   and
                                       bf-nxt_pl-level.pl-code  = bf_place.pl-code       and
                                       bf-nxt_pl-level.pl-level = varlevel-sm            no-error.
      if not available bf-nxt_pl-level then do:
        message "Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара " bf_place.loc1 " не задан объем для уровня " varlevel-sm " измерение " varlevel-sm-q view-as alert-box error.
        return no-apply.
      end.
      else do:
        display bf_pl-level.pl-qnty + (bf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) @ tt-rvs-line.state-brutto-qnty
                bf_pl-level.pl-qnty + (bf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) @ tt-rvs-line.state-measure-qnty with frame {&frame-name}.
      end.
    end.
    assign
      tt-rvs-line.state-brutto-qnty = input frame {&frame-name} tt-rvs-line.state-measure-qnty.
    display tt-rvs-line.state-brutto-qnty with frame {&frame-name}.
    if tt-rvs-line.state-density <> 0 and
        tt-rvs-line.state-density <> ? then do:
        run chg-density.
        run weath-water.
    end.

    CASE paraction:
      WHEN "state-level-total" THEN DO:
        DISPLAY input frame {&frame-name} tt-rvs-line.state-level-total @ tt-rvs-line.state-level-petrol WITH FRAME {&FRAME-NAME}.
      END.
      WHEN "state-level-petrol" THEN DO:
        DISPLAY input frame {&frame-name} tt-rvs-line.state-level-petrol @ tt-rvs-line.state-level-total WITH FRAME {&FRAME-NAME}.
      END.
    END CASE.
    run volume-water.

  end.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE volume-measure-water Dialog-Frame
PROCEDURE volume-measure-water :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
display input frame {&frame-name} tt-rvs-line.brutto-qnty -
        input frame {&frame-name} tt-rvs-line.measure-qnty @
        varmeasure-water-qnty with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE volume-water Dialog-Frame
PROCEDURE volume-water :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
display input frame {&frame-name} tt-rvs-line.state-brutto-qnty -
        input frame {&frame-name} tt-rvs-line.state-measure-qnty @
        varstate-water-qnty with frame {&frame-name}.
        assign frame {&frame-name} tt-rvs-line.state-brutto-qnty
                                   tt-rvs-line.state-measure-qnty.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE weath-measure-water Dialog-Frame
PROCEDURE weath-measure-water :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
display input frame {&frame-name} tt-rvs-line.brutto-cli-qnty -
        input frame {&frame-name} tt-rvs-line.measure-cli-qnty @
        varmeasure-water-cli-qnty with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE weath-water Dialog-Frame
PROCEDURE weath-water :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if input frame {&frame-name} tt-rvs-line.state-measure-cli-qnty >
   input frame {&frame-name} tt-rvs-line.state-brutto-cli-qnty then do:
   message "Вес топлива больше общего веса."
   view-as alert-box error.
   return error.
end.
display input frame {&frame-name} tt-rvs-line.state-brutto-cli-qnty -
        input frame {&frame-name} tt-rvs-line.state-measure-cli-qnty @
        varstate-water-cli-qnty with frame {&frame-name}.
assign frame {&frame-name} tt-rvs-line.state-brutto-cli-qnty
                           tt-rvs-line.state-measure-cli-qnty.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
