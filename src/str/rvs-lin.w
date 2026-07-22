&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rvs-line NO-UNDO LIKE rvs-line
field meas-calc-qnty     AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field meas-calc-dens     AS DECIMAL FORMAT "9.9999":U INITIAL 0
field meas-cli-calc-qnty AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field izmer-density      AS DECIMAL FORMAT "9.9999":U INITIAL 0 decimals 10
field calc-add-mass      AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field sum-mass           AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field sum-vol            AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field fact-calc-add-mass AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field fact-sum-mass      AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field fact-sum-vol       AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0 
field temp-izm-vol       as decimal format "->>>9.9":U initial ? decimals 10
.

define new shared temp-table tt-temps-tab no-undo
  field ii as integer
  field key_ as character
  field temperature as decimal format "->>>9.9"
  index pi 
    as primary unique
    ii
.

define new shared temp-table tt-temps no-undo
  field ii as integer
  field key_ as character
  field temperature as decimal format "->>>9.9"
  index pi 
    as primary unique
    ii
.

define new shared temp-table tt-dens no-undo
  field ii as integer
  field key_ as character
  field density as decimal format "9.9999"
  index pi 
    as primary unique
    ii
.

define new shared temp-table tt-dens-temp no-undo
  field ii as integer
  field key_ as character
  field density as decimal format "9.9999"
  field temperature as decimal format "->>>9.9"
  index pi 
    as primary unique
    ii
.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран работы со строкой сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/23/07
Author: Dmitry Ukhanov
Creation date: 07/23/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 09/12/05

*/

define  input parameter parparentproc   as handle    no-undo .
define  input parameter parrec-rvs-line as recid     no-undo .
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
{ cmp/trg-def.i  }
{ gbl/getsect.i def }
{ str/initiator.i }
{ gbl/color.i }
{ str/pokmi-dyn.i }
{ str/calibrationbelt.i }

define variable g-log        as logical   no-undo.
define variable g-log2       as logical   no-undo.
define variable varlog       as logical   no-undo.
define variable v-return-val as character no-undo initial "":U .
define variable v-min-dens   as decimal   no-undo.
define variable v-max-dens   as decimal   no-undo.
define variable v-attr-type  as character no-undo.
define variable v-gds-ptrl-densities as character no-undo.
define variable rdc-value as character no-undo .
define variable rdc-type  as character no-undo.
define variable tarir-value as character no-undo .
define variable tarir-type  as character no-undo.
define variable pl-asi-sertif as logical no-undo .
define variable pl-rvd-dens as logical no-undo .
define variable pl-rvd-lvl as logical no-undo .
define variable pl-rvd-temp as logical no-undo .
define variable pl-error-mass as decimal no-undo .
define variable v-hand-input-dnst as logical no-undo initial no .
define variable v-hand-input-tmp as logical no-undo initial no .
define variable v-hand-input-lvl as logical no-undo initial no .

define variable place-diameter    as decimal no-undo .
define variable pl-dens-sr-izm    as integer no-undo .
define variable pl-level-sr-izm   as integer no-undo .
define variable pl-temp-sr-izm    as integer no-undo .
define variable v-dnst-mi-old     as integer no-undo .
define variable v-tmp-mi-old      as integer no-undo .
define variable v-lvl-mi-old      as integer no-undo .

define variable place-type        as integer no-undo.

define variable place-SI          as integer no-undo.

define variable v-revision-mode   as logical no-undo init no .
define variable v-first-enter     as logical no-undo init yes .

define variable v-POkMI-result-attr     as character no-undo.
define variable v-POkMI-warnings        as character no-undo init "" .

define variable v-value           as character no-undo.
define variable v-ok              as logical   no-undo.
define VARIABLE ii as integer no-undo .

define variable vAutomationDegree as integer no-undo extent 3 init [2,1,3].

define buffer buf_goods        for ub.goods .
define buffer buf_rvs-doc      for ub.rvs-doc.
define buffer buf_rvs-doc-attr for ub.rvs-doc-attr .
define buffer buf_rvs-line     for ub.rvs-line .
define buffer bf_pl-level      for ub.pl-level.
define buffer buf-nxt_pl-level for ub.pl-level.
define buffer buf2_place       for ub.place.
define buffer dnst_sr-izmerenia for sr-izmerenia .
define buffer tmp_sr-izmerenia for sr-izmerenia .
define buffer lvl_sr-izmerenia for sr-izmerenia .
define stream sinp .

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
tt-rvs-line.meas-cli-calc-qnty tt-rvs-line.temp-izm-vol ~
tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty ~
tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol ~
tt-rvs-line.level-total tt-rvs-line.state-level-total ~
tt-rvs-line.level-water tt-rvs-line.state-level-water ~
tt-rvs-line.temperature tt-rvs-line.state-temperature ~
tt-rvs-line.meas-mh-qnty ~
tt-rvs-line.state-mh-qnty tt-rvs-line.meas-am-qnty ~
tt-rvs-line.state-am-qnty tt-rvs-line.meas-cf-qnty ~
tt-rvs-line.state-cf-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-rvs-line.state-measure-qnty tt-rvs-line.meas-calc-qnty ~
tt-rvs-line.state-density tt-rvs-line.state-add-qnty ~
tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-cli-qnty ~
tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total ~
tt-rvs-line.state-temperature
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
tt-rvs-line.state-level-total tt-rvs-line.state-temperature 
&Scoped-define ENABLED-TABLES tt-rvs-line
&Scoped-define FIRST-ENABLED-TABLE tt-rvs-line
&Scoped-Define ENABLED-OBJECTS b-save RECT-2 RECT-3 b-cancel b-help b-calc ~
delta-mass-qnty CriticalDif /* mass-float-cov */
&Scoped-Define DISPLAYED-FIELDS tt-rvs-line.system-qnty ~
tt-rvs-line.system-cli-qnty tt-rvs-line.orig-system-qnty ~
tt-rvs-line.orig-system-cli-qnty tt-rvs-line.measure-qnty ~
tt-rvs-line.state-measure-qnty tt-rvs-line.meas-calc-qnty ~
tt-rvs-line.measure-tc-qnty tt-rvs-line.temp-izm-vol ~
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
tt-rvs-line.meas-mh-qnty ~
tt-rvs-line.state-mh-qnty tt-rvs-line.meas-am-qnty ~
tt-rvs-line.state-am-qnty tt-rvs-line.meas-cf-qnty ~
tt-rvs-line.state-cf-qnty 
&Scoped-define DISPLAYED-TABLES tt-rvs-line
&Scoped-define FIRST-DISPLAYED-TABLE tt-rvs-line
&Scoped-Define DISPLAYED-OBJECTS varmeasure-water-qnty varstate-water-qnty ~
varmeasure-water-cli-qnty varstate-water-cli-qnty CriticalDif ~
varstate-sum-vol varsum-vol
/*mass-float-cov*/

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 Dialog-Frame tt-rvs-line.measure-qnty ~
tt-rvs-line.density tt-rvs-line.add-qnty tt-rvs-line.brutto-qnty ~
tt-rvs-line.measure-cli-qnty tt-rvs-line.brutto-cli-qnty ~
tt-rvs-line.level-petrol tt-rvs-line.level-total tt-rvs-line.level-water ~
tt-rvs-line.temperature tt-rvs-line.meas-mh-qnty tt-rvs-line.meas-am-qnty ~
tt-rvs-line.meas-cf-qnty tt-rvs-line.meas-calc-qnty tt-rvs-line.meas-calc-dens ~
tt-rvs-line.meas-cli-calc-qnty
&Scoped-define List-2 tt-rvs-line.state-measure-qnty ~
tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-density ~
tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-qnty ~
tt-rvs-line.state-brutto-tc-qnty tt-rvs-line.state-measure-cli-qnty ~
tt-rvs-line.state-brutto-cli-qnty tt-rvs-line.state-level-petrol ~
tt-rvs-line.state-level-total tt-rvs-line.state-level-water ~
tt-rvs-line.state-temperature tt-rvs-line.temp-izm-vol ~
tt-rvs-line.state-mh-qnty tt-rvs-line.state-am-qnty ~
tt-rvs-line.state-cf-qnty tt-rvs-line.izmer-density
&Scoped-define List-3 tt-rvs-line.state-measure-tc-qnty ~
tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-tc-qnty ~
tt-rvs-line.state-temperature  

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc 
     LABEL "Рассчитать" 
     SIZE 13 BY .88.
     
DEFINE BUTTON b-POkMI-result 
     LABEL "Результаты ПОкМИ" 
     SIZE 17 BY 1 .

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
     
DEFINE BUTTON b-temperature 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Установка температуры" 
     SIZE 3 BY .87.
     
DEFINE BUTTON b-density 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Установка плотности" 
     SIZE 3 BY .87.
     
DEFINE BUTTON b-mi-lvl 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     tooltip "уровня" 
     SIZE 3 BY .87.
     
DEFINE BUTTON b-mi-dnst 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     tooltip "плотности" 
     SIZE 3 BY .87.
     
DEFINE BUTTON b-mi-tmp 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     tooltip "температуры" 
     SIZE 3 BY .87.

DEFINE VARIABLE v-mi-lvl AS integer FORMAT ">>>>>9":U
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-dnst AS integer FORMAT ">>>>>9":U
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-tmp AS integer FORMAT ">>>>>9":U
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

define variable v-mi-tmp-dnst as integer no-undo .
     
DEFINE VARIABLE v-mi-lvl-name AS character FORMAT "X(10)":U
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-dnst-name AS character FORMAT "X(10)":U
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-mi-tmp-name AS character FORMAT "X(10)":U
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE delta-mass-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Отн. погр. изм. массы НП" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.
     
DEFINE VARIABLE abs-delta-mass-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Абс. погр. изм. массы НП" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.
     
DEFINE VARIABLE abs-delta-mass-add-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Абс. погр. изм. массы в трубопр." 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

/*DEFINE VARIABLE mass-float-cov AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0*/
/*     LABEL "Масса плавающего покрытия"                                   */
/*     VIEW-AS FILL-IN                                                     */
/*     SIZE 13 BY .88 NO-UNDO.                                             */

DEFINE VARIABLE CriticalDif AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL ?
     LABEL "Сверхнормативные расхождения" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE varmeasure-water-cli-qnty AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0 
     LABEL "Масса воды (кг)" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE varmeasure-water-qnty AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0 
     LABEL "Объем воды (л)" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE varstate-water-cli-qnty AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0 
     LABEL "Факт масса воды (кг)" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.
     
DEFINE VARIABLE varsum-vol AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0 
     LABEL "Объем наполнения (л)" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE varstate-sum-vol AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0 
     LABEL "Объем наполнения (л)" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE varstate-water-qnty AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0 
     LABEL "Объем воды (л)" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.
     
DEFINE VARIABLE v-sec-num AS character FORMAT "X(3)":U
     LABEL "Номер секции" 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.   
     
define variable t-tank-cleaning as logical
     view-as toggle-box
     size 2 by 1 no-undo .  
     
DEFINE VARIABLE t-tank-cleaning-text1 AS character FORMAT "X(9)":U
     VIEW-AS FILL-IN 
     SIZE 9 BY 0.7 NO-UNDO init "Зачистка".   
     
DEFINE VARIABLE t-tank-cleaning-text2 AS character FORMAT "X(11)":U
     VIEW-AS FILL-IN 
     SIZE 11 BY 0.7 NO-UNDO init "резервуара".    

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
define variable hide-text-dop-si as character no-undo .

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     v-sec-num at row 1 col 60
     b-POkMI-result at row 1 col 87
     "Доп. средства измерения:" at row 5.25 col 11
       view-as text
       size 25 by .88
     hide-text-dop-si at row 5.25 col 11
       view-as text
       size 25 by .88 no-label
     v-mi-dnst at row 5.25 col 40 label "p"
     v-mi-dnst-name at row 5.25 col 40 label "p"
     b-mi-dnst at row 5.25 col 54
     v-mi-lvl at row 5.25 col 58 label "l"
     v-mi-lvl-name at row 5.25 col 58 label "l"
     b-mi-lvl at row 5.25 col 72
     v-mi-tmp at row 5.25 col 76 label "T"
     v-mi-tmp-name at row 5.25 col 76 label "T"
     b-mi-tmp at row 5.25 col 90  
     t-tank-cleaning at row 5.25 col 94 no-label
     t-tank-cleaning-text1 at row 4.95 col 96.1 no-label
     t-tank-cleaning-text2 at row 5.55 col 96 no-label
     tt-rvs-line.system-qnty AT ROW 2.25 COL 34 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U 
          LABEL "Объем расчетно-книжный (л)"
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
     tt-rvs-line.system-cli-qnty AT ROW 2.25 COL 76 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Масса расчетно-книжная (кг)"
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
     tt-rvs-line.orig-system-qnty AT ROW 3.25 COL 34 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Первоначально (л)"
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
          FGCOLOR 4 
     tt-rvs-line.orig-system-cli-qnty AT ROW 3.25 COL 76 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Первоначально (кг)"
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
          FGCOLOR 4 
     tt-rvs-line.measure-qnty AT ROW 6.75 COL 28.25 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-measure-qnty AT ROW 6.75 COL 85 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.meas-calc-qnty AT ROW 7.75 COL 34 COLON-ALIGNED WIDGET-ID 20
          LABEL "Остаток рассчит. по измер."
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.measure-tc-qnty AT ROW 8.75 COL 28.25 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-measure-tc-qnty AT ROW 8.75 COL 85 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.density AT ROW 18.75 COL 32 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Измер. Плотность НП (г/см3)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-density AT ROW 18.75 COL 85 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Плотность НП (г/см3)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     b-calc AT ROW 10.75 COL 65 WIDGET-ID 6
     tt-rvs-line.meas-calc-dens AT ROW 10.75 COL 35 /* COLON-ALIGNED */ WIDGET-ID 8
          FORMAT "9.9999"
          LABEL "Плотность расчит. по измер. (г/см3)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.izmer-density AT ROW 9.75 COL 85 COLON-ALIGNED WIDGET-ID 4
          FORMAT "9.9999"
          LABEL "Плотность НП в резервуаре (г/см3)"
          VIEW-AS FILL-IN 
          SIZE 7.5 BY .88
     b-density at row 9.75 col 97
     tt-rvs-line.temp-izm-vol AT ROW 11.75 COL 85 COLON-ALIGNED WIDGET-ID 4
          LABEL "Температура НП в резервуаре (°С)"
          VIEW-AS FILL-IN 
          SIZE 7.5 BY .88
     b-temperature at row 11.75 col 97     
     tt-rvs-line.add-qnty AT ROW 12.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем в трубопроводе (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.calc-add-mass AT ROW 13.75 COL 35 COLON-ALIGNED
          LABEL "Рассч. Масса в трубопроводе (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.fact-calc-add-mass AT ROW 13.75 COL 85 COLON-ALIGNED
          LABEL "Рассч. Масса в трубопроводе (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     abs-delta-mass-add-qnty AT ROW 14.75 COL 85 COLON-ALIGNED
     tt-rvs-line.state-add-qnty AT ROW 12.75 COL 85 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем в трубопроводе (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.brutto-qnty AT ROW 12.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-qnty AT ROW 12.75 COL 85 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.brutto-tc-qnty AT ROW 13.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-tc-qnty AT ROW 13.75 COL 85 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     varmeasure-water-qnty AT ROW 25.75 COL 28.13 COLON-ALIGNED
     varstate-water-qnty AT ROW 25.75 COL 85 COLON-ALIGNED
     varsum-vol AT ROW 26.75 COL 28.13 COLON-ALIGNED
     varstate-sum-vol AT ROW 26.75 COL 85 COLON-ALIGNED
     tt-rvs-line.measure-qnty AT ROW 16.75 COL 32 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Рассч. Объем НП (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-measure-qnty AT ROW 16.75 COL 85 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем НП (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.measure-cli-qnty AT ROW 17.75 COL 32 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Измер. Масса НП (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-measure-cli-qnty AT ROW 17.75 COL 85 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Масса НП (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         CANCEL-BUTTON b-cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-rvs-line.meas-cli-calc-qnty AT ROW 16.75 COL 34 COLON-ALIGNED WIDGET-ID 10
          LABEL "Масса расчит. по измер. (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-cli-qnty AT ROW 17.75 COL 28.13 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Измер. брутто масса (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-cli-qnty AT ROW 17.75 COL 85 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Факт брутто масса (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.sum-vol AT ROW 22.75 COL 28.13 COLON-ALIGNED
          LABEL "Общий Объем НП (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.sum-mass AT ROW 23.75 COL 28.13 COLON-ALIGNED
          LABEL "Общая Масса НП (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.fact-sum-vol AT ROW 22.75 COL 85 COLON-ALIGNED
          LABEL "Общий Объем НП (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.fact-sum-mass AT ROW 23.75 COL 85 COLON-ALIGNED
          LABEL "Общая Масса НП (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     varmeasure-water-cli-qnty AT ROW 25.75 COL 28.13 COLON-ALIGNED
     varstate-water-cli-qnty AT ROW 25.75 COL 85 COLON-ALIGNED
     tt-rvs-line.level-petrol AT ROW 19.75 COL 30 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. уровень топлива (см)"
          VIEW-AS FILL-IN 
          SIZE 9 BY .88
     tt-rvs-line.state-level-petrol AT ROW 19.75 COL 85 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Факт уровень топлива (см)"
          VIEW-AS FILL-IN 
          SIZE 9 BY .88
     tt-rvs-line.level-total AT ROW 6.75 COL 28 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. общий уровень (см)"
          VIEW-AS FILL-IN 
          SIZE 9 BY .88
     tt-rvs-line.state-level-total AT ROW 6.75 COL 85 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Факт общий уровень (см)"
          VIEW-AS FILL-IN 
          SIZE 9 BY .88 
     tt-rvs-line.level-water AT ROW 7.75 COL 28 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. уровень воды (см)"
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt-rvs-line.state-level-water AT ROW 7.75 COL 85 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Факт уровень воды (см)"
          VIEW-AS FILL-IN 
          SIZE 9 BY .88
     tt-rvs-line.temperature AT ROW 8.75 COL 28 COLON-ALIGNED
          FORMAT "->>9.9":U
          LABEL "Измер. Температура (°С)"
          VIEW-AS FILL-IN 
          SIZE 9 BY .88
     tt-rvs-line.state-temperature AT ROW 8.75 COL 85 COLON-ALIGNED
          FORMAT "->>9.9":U
          LABEL "Температура НП при измер. плотн. (°С)"
          VIEW-AS FILL-IN 
          SIZE 7.5 BY .88
/*     tt-rvs-line.temp-layer1 AT ROW 5.75 COL 41 COLON-ALIGNED      */
/*          LABEL "T1"                                               */
/*          VIEW-AS FILL-IN                                          */
/*          SIZE 6 BY .88                                            */
/*     tt-rvs-line.temp-layer2 AT ROW 6.75 COL 41 COLON-ALIGNED      */
/*          LABEL "T2"                                               */
/*          VIEW-AS FILL-IN                                          */
/*          SIZE 6 BY .88                                            */
/*     tt-rvs-line.temp-layer3 AT ROW 7.75 COL 41 COLON-ALIGNED      */
/*          LABEL "T3"                                               */
/*          VIEW-AS FILL-IN                                          */
/*          SIZE 6 BY .88                                            */
/*     tt-rvs-line.state-temp-layer1 AT ROW 5.75 COL 91 COLON-ALIGNED*/
/*          VIEW-AS FILL-IN                                          */
/*          SIZE 8 BY .88                                            */
/*     tt-rvs-line.state-temp-layer2 AT ROW 6.75 COL 91 COLON-ALIGNED*/
/*          VIEW-AS FILL-IN                                          */
/*          SIZE 8 BY .88                                            */
/*     tt-rvs-line.state-temp-layer3 AT ROW 7.75 COL 91 COLON-ALIGNED*/
/*          VIEW-AS FILL-IN                                          */
/*          SIZE 8 BY .88                                            */
     tt-rvs-line.meas-mh-qnty AT ROW 24.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     tt-rvs-line.state-mh-qnty AT ROW 29.25 COL 15.5 COLON-ALIGNED
          LABEL "Оборот по ТРК"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt-rvs-line.meas-am-qnty AT ROW 25.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     tt-rvs-line.state-am-qnty AT ROW 29.25 COL 55.5 COLON-ALIGNED
          LABEL "Сумма оборота по ТРК"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt-rvs-line.meas-cf-qnty AT ROW 26.75 COL 29.13 COLON-ALIGNED
          LABEL "Измеренное кол-во наливов"
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         CANCEL-BUTTON b-cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-rvs-line.state-cf-qnty AT ROW 29.25 COL 95.5 COLON-ALIGNED
          LABEL "Количество наливов"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     delta-mass-qnty AT ROW 19.75 COL 85 COLON-ALIGNED  WIDGET-ID 22
     abs-delta-mass-qnty AT ROW 20.75 COL 85 COLON-ALIGNED  WIDGET-ID 22
     CriticalDif AT ROW 4.25 COL 34 COLON-ALIGNED WIDGET-ID 2
/*     mass-float-cov AT ROW 26.5 COL 54 COLON-ALIGNED WIDGET-ID 2*/
/*       "Погр. изм." VIEW-AS TEXT                             */
/*          SIZE 12.5 BY .75 AT ROW 24.75 COL 88.5 WIDGET-ID 24*/
     
     RECT-2 AT ROW 6.5 COL 50.25
     RECT-3 AT ROW 6.5 COL 2
     SPACE(58.61) SKIP(2.74)
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
  
  release rvs-line-attr no-error .
  
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-POkMI-result
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-POkMI-result Dialog-Frame
ON CHOOSE OF b-POkMI-result IN FRAME Dialog-Frame /* Отмена */
DO:
  if trim(v-POkMI-warnings) > ""
  then do :
    message (v-POkMI-result-attr + {&new-line} + " " + {&new-line} + " " + {&new-line} + "Предупреждения:" + {&new-line} + v-POkMI-warnings) view-as alert-box information .
  end .
  else do :
    message v-POkMI-result-attr view-as alert-box information .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-mi-lvl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mi-lvl Dialog-Frame
ON CHOOSE OF b-mi-lvl IN FRAME Dialog-Frame 
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type as character no-undo.
  
  v-node-code = 0 .
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input {&lookup}     ,
                    input "0,1"         ,
                    input "lvl"         ,
                    input-output v-node-code,
                    output v-sr-type) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    v-mi-lvl = v-node-code.
    v-mi-lvl:screen-value = string(v-node-code).
    find first lvl_sr-izmerenia no-lock where lvl_sr-izmerenia.node-code = v-mi-lvl .
    apply "leave" to v-mi-lvl in frame Dialog-Frame .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on entry of v-mi-lvl-name IN FRAME Dialog-Frame 
do:
  apply "entry" to v-mi-lvl in frame Dialog-Frame.
end .

on entry of v-mi-lvl IN FRAME Dialog-Frame 
do:
  hide v-mi-lvl-name in frame Dialog-Frame.
end .

on return of v-mi-lvl IN FRAME Dialog-Frame 
do:
  apply "leave" to v-mi-lvl IN FRAME Dialog-Frame .
end .  

on del, backspace, "?" of v-mi-lvl in frame Dialog-Frame
do :
  v-mi-lvl = ? .
  v-mi-lvl:screen-value = "?" .
end . 
  
on leave of v-mi-lvl IN FRAME Dialog-Frame 
do:
  define variable v-old-val as character no-undo .
  
  v-old-val = string(v-mi-lvl) .
  find first lvl_sr-izmerenia no-lock where lvl_sr-izmerenia.node-code = integer(v-mi-lvl:screen-value) no-error .
  if not available lvl_sr-izmerenia
  then do :
    if v-mi-lvl:screen-value <> "?"
    and v-mi-lvl:screen-value <> "0"
    then do :
      message ("Не найдено средтсво измерения с кодом " + v-mi-lvl:screen-value) view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
    end .
/*    apply "choose" to b-mi-lvl in frame {&frame-name}.*/
    return .
  end .
  else do :
    if lvl_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
/*      apply "choose" to b-mi-lvl in frame {&frame-name}.*/
      return .
    end .
    if not lvl_sr-izmerenia.sr-level
    then do :
      message "Средство измерения НЕ измеряет уровень!" view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
/*      apply "choose" to b-mi-lvl in frame {&frame-name}.*/
      return .
    end .
  end .
  v-mi-lvl-name = lvl_sr-izmerenia.sr-model .
  display v-mi-lvl-name with frame {&frame-name}.
  enable v-mi-lvl-name with frame {&frame-name}.
  assign v-mi-lvl .
  if string(v-mi-lvl) <> v-old-val
  then do :
    tt-rvs-line.state-level-total = 0 .
    tt-rvs-line.state-level-water = 0 .
  end .
  display tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame {&frame-name}.
  if v-revision-mode
  then do :
    if v-mi-dnst > 0
    and v-mi-tmp > 0
    then do :
      enable
        tt-rvs-line.state-level-total
        tt-rvs-line.state-level-water
        b-temperature
        b-density
      with frame {&frame-name}.
    end .
  end .
  else do :
    if ((pl-rvd-lvl and v-mi-lvl > 0) or not pl-rvd-lvl)
    and ((pl-rvd-dens and v-mi-dnst > 0) or not pl-rvd-dens)
    and ((pl-rvd-temp and v-mi-tmp > 0) or not pl-rvd-temp)
    then do :
      if pl-rvd-lvl
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame {&frame-name}.
      end .
      if pl-rvd-dens
      then do :
        enable
          b-density
        with frame {&frame-name}.
      end .
      if pl-rvd-temp
      then do :
        enable
          b-temperature
        with frame {&frame-name}.
      end .
    end .
  end .
  apply "leave" to tt-rvs-line.state-level-total in frame Dialog-Frame .
end .

&Scoped-define SELF-NAME b-mi-dnst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mi-dnst Dialog-Frame
ON CHOOSE OF b-mi-dnst IN FRAME Dialog-Frame 
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type-id as character no-undo.
  define variable v-sr-type-izm as character no-undo .
  v-node-code = 0 .
  
/*  if available tmp_sr-izmerenia                           */
/*  then do :                                               */
/*    v-sr-type-izm = string(tmp_sr-izmerenia.sr-type-izm) .*/
/*  end .                                                   */
/*  else do :                                               */
    v-sr-type-izm = "0,1" .
/*  end .*/
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input {&lookup}     ,
                    input v-sr-type-izm ,
                    input "dnst"        ,
                    input-output v-node-code,
                    output v-sr-type-id) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    if v-mi-dnst:screen-value <> "?"
    then do :
      if integer(v-mi-dnst:screen-value) <> v-node-code
      then do :
        v-mi-tmp-dnst = 0 .
        find first rvs-line-attr exclusive-lock
             where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
               and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
               and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
               and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
               and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
               and rvs-line-attr.attr-code = "mi-tmp-dnst" no-error.
        if available rvs-line-attr
        then do :
          rvs-line-attr.attr-value = string(v-mi-tmp-dnst) .
        end.
      end .
    end .
    v-mi-dnst = v-node-code.
    v-mi-dnst:screen-value = string(v-node-code).
    find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst .
    apply "leave" to v-mi-dnst in frame Dialog-Frame .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on entry of v-mi-dnst-name IN FRAME Dialog-Frame 
do:
  apply "entry" to v-mi-dnst in frame Dialog-Frame.
end .

on entry of v-mi-dnst IN FRAME Dialog-Frame 
do:
  hide v-mi-dnst-name in frame Dialog-Frame.
end .

on return of v-mi-dnst IN FRAME Dialog-Frame 
do:
  apply "leave" to v-mi-dnst IN FRAME Dialog-Frame .
end .

on del, backspace, "?" of v-mi-dnst in frame Dialog-Frame
do :
  v-mi-dnst = ? .
  v-mi-dnst:screen-value = "?" .
end .

on leave of v-mi-dnst IN FRAME Dialog-Frame 
do:
  define variable vlog as logical no-undo .
  define variable v-old-val as character no-undo .
  
  v-old-val = string(v-mi-dnst) .
  find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = integer(v-mi-dnst:screen-value) no-error .
  if not available dnst_sr-izmerenia
  then do :
    if v-mi-dnst:screen-value <> "?"
    and v-mi-dnst:screen-value <> "0"
    then do :
      message ("Не найдено средство измерения с кодом " + v-mi-dnst:screen-value) view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
    end .
/*    apply "choose" to b-mi-dnst in frame {&frame-name}.*/
    return .
  end .
  else do :
    if dnst_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
/*      apply "choose" to b-mi-dnst in frame {&frame-name}.*/
      return .
    end .
    if not dnst_sr-izmerenia.sr-density
    then do :
      message "Средство измерения НЕ измеряет плотность!" view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
/*      apply "choose" to b-mi-dnst in frame {&frame-name}.*/
      return .
    end .
  end .
  v-mi-dnst-name = dnst_sr-izmerenia.sr-model .
  display v-mi-dnst-name with frame {&frame-name}.
  enable v-mi-dnst-name with frame {&frame-name}.
  assign v-mi-dnst .
  if rdc-value = 'pomi-rn'
  then do :
    if string(v-mi-dnst) <> v-old-val
    then do :
      v-mi-tmp-dnst = 0 .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "mi-tmp-dnst" no-error.
      if available rvs-line-attr
      then do :
        rvs-line-attr.attr-value = string(v-mi-tmp-dnst) .
      end.
      tt-rvs-line.izmer-density = 0 .
      tt-rvs-line.state-temperature = ? .
    end .
    display tt-rvs-line.izmer-density tt-rvs-line.state-temperature with frame {&frame-name}.
    if v-revision-mode
    then do :
      if v-mi-lvl > 0
      and v-mi-tmp > 0
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
          b-temperature
          b-density
        with frame {&frame-name}.
      end .
    end .
    else do :
      if ((pl-rvd-lvl and v-mi-lvl > 0) or not pl-rvd-lvl)
      and ((pl-rvd-dens and v-mi-dnst > 0) or not pl-rvd-dens)
      and ((pl-rvd-temp and v-mi-tmp > 0) or not pl-rvd-temp)
      then do :
        if pl-rvd-lvl
        then do :
          enable
            tt-rvs-line.state-level-total
            tt-rvs-line.state-level-water
          with frame {&frame-name}.
        end .
        if pl-rvd-dens
        then do :
          enable
            b-density
          with frame {&frame-name}.
        end .
        if pl-rvd-temp
        then do :
          enable
            b-temperature
          with frame {&frame-name}.
        end .
      end .
    end .
    if pl-rvd-dens <> pl-rvd-temp
    then do :
      find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp no-error .
      if (available tmp_sr-izmerenia and tmp_sr-izmerenia.sr-type-izm = 0 and tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature)
      or (available dnst_sr-izmerenia and dnst_sr-izmerenia.sr-type-izm = 0 and dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
      then do :
        message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, "
                "если дополнительное автоматизированное СИ предназначено для измерения обоих параметров." skip
                "Подайте заявку в службу поддержки для приведения параметров в соответствие требованиям бизнес-процесса."
        view-as alert-box .
      end .
    end .
    if dnst_sr-izmerenia.sr-temperature
    and v-mi-dnst <> v-mi-tmp
    and b-mi-tmp:sensitive
    then do :
/*      message "Для измерения плотности выбрано дополнительное СИ " + v-mi-dnst-name + ". Установить данное СИ для измерения температуры автоматически?"*/
/*      view-as alert-box buttons yes-no update vlog .                                                                                                   */
/*      if vlog                                                                                                                                          */
/*      then do :                                                                                                                                        */
        v-mi-tmp = v-mi-dnst .
        v-mi-tmp:screen-value = v-mi-dnst:screen-value .
        v-mi-tmp-name = v-mi-dnst-name .
        apply "leave" to v-mi-tmp in frame Dialog-Frame .
/*      end .*/
    end .
  end .
  else do :
    if string(v-mi-dnst) <> v-old-val
    then do :
      tt-rvs-line.state-density = 0 .
    end .
    display tt-rvs-line.state-density with frame {&frame-name}.
    if v-revision-mode
    then do :
      if v-mi-lvl > 0
      and v-mi-tmp > 0
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
          tt-rvs-line.state-temperature
          tt-rvs-line.state-density
        with frame {&frame-name}.
      end .
    end .
    else do :
      if ((pl-rvd-lvl and v-mi-lvl > 0) or not pl-rvd-lvl)
      and ((pl-rvd-dens and v-mi-dnst > 0) or not pl-rvd-dens)
      and ((pl-rvd-temp and v-mi-tmp > 0) or not pl-rvd-temp)
      then do :
        if pl-rvd-lvl
        then do :
          enable
            tt-rvs-line.state-level-total
            tt-rvs-line.state-level-water
          with frame {&frame-name}.
        end .
        if pl-rvd-dens
        then do :
          enable
            tt-rvs-line.state-density
          with frame {&frame-name}.
        end .
        if pl-rvd-temp
        then do :
          enable
            tt-rvs-line.state-temperature
          with frame {&frame-name}.
        end .
      end .
    end .
  end .
  apply "leave" to tt-rvs-line.state-level-total in frame Dialog-Frame .
end .

&Scoped-define SELF-NAME b-mi-tmp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mi-tmp Dialog-Frame
ON CHOOSE OF b-mi-tmp IN FRAME Dialog-Frame 
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type-id as character no-undo.
  define variable v-sr-type-izm as character no-undo .
  v-node-code = 0 .
  
/*  if available dnst_sr-izmerenia                           */
/*  then do :                                                */
/*    v-sr-type-izm = string(dnst_sr-izmerenia.sr-type-izm) .*/
/*  end .                                                    */
/*  else do :                                                */
    v-sr-type-izm = "0,1" .
/*  end .*/
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input {&lookup}     ,
                    input v-sr-type-izm ,
                    input "tmp"         ,
                    input-output v-node-code,
                    output v-sr-type-id) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    v-mi-tmp = v-node-code.
    v-mi-tmp:screen-value = string(v-node-code).
    find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp .
    apply "leave" to v-mi-tmp in frame Dialog-Frame .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on entry of v-mi-tmp-name IN FRAME Dialog-Frame 
do:
  apply "entry" to v-mi-tmp in frame Dialog-Frame.
end .

on entry of v-mi-tmp IN FRAME Dialog-Frame 
do:
  hide v-mi-tmp-name in frame Dialog-Frame.
end .

on return of v-mi-tmp IN FRAME Dialog-Frame 
do:
  apply "leave" to v-mi-tmp IN FRAME Dialog-Frame .
end .

on del, backspace, "?" of v-mi-tmp in frame Dialog-Frame
do :
  v-mi-tmp = ? .
  v-mi-tmp:screen-value = "?" .
end .

on leave of v-mi-tmp IN FRAME Dialog-Frame 
do:
  define variable vlog as logical no-undo .
  define variable v-old-val as character no-undo .
  
  v-old-val = string(v-mi-tmp) .
  find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = integer(v-mi-tmp:screen-value) no-error .
  if not available tmp_sr-izmerenia
  then do :
    if v-mi-tmp:screen-value <> "?"
    and v-mi-tmp:screen-value <> "0"
    then do :
      message ("Не найдено средтсво измерения с кодом " + v-mi-tmp:screen-value) view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
    end .
/*    apply "choose" to b-mi-tmp in frame {&frame-name}.*/
    return .
  end .
  else do :
    if tmp_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
/*      apply "choose" to b-mi-tmp in frame {&frame-name}.*/
      return .
    end .
    if not tmp_sr-izmerenia.sr-temperature
    then do :
      message "Средство измерения НЕ измеряет температуру!" view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
/*      apply "choose" to b-mi-tmp in frame {&frame-name}.*/
      return .
    end .
  end .
  v-mi-tmp-name = tmp_sr-izmerenia.sr-model .
  display v-mi-tmp-name with frame {&frame-name}.
  enable v-mi-tmp-name with frame {&frame-name}.
  assign v-mi-tmp .
  if string(v-mi-tmp) <> v-old-val
  then do :
    tt-rvs-line.temp-izm-vol = ? .
  end .
  display tt-rvs-line.temp-izm-vol with frame {&frame-name}.
  if v-revision-mode
  then do :
    if v-mi-dnst > 0
    and v-mi-lvl > 0
    then do :
      enable
        tt-rvs-line.state-level-total
        tt-rvs-line.state-level-water
        b-temperature
        b-density
      with frame {&frame-name}.
    end .
  end .
  else do :
    if ((pl-rvd-lvl and v-mi-lvl > 0) or not pl-rvd-lvl)
    and ((pl-rvd-dens and v-mi-dnst > 0) or not pl-rvd-dens)
    and ((pl-rvd-temp and v-mi-tmp > 0) or not pl-rvd-temp)
    then do :
      if pl-rvd-lvl
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame {&frame-name}.
      end .
      if pl-rvd-dens
      then do :
        enable
          b-density
        with frame {&frame-name}.
      end .
      if pl-rvd-temp
      then do :
        enable
          b-temperature
        with frame {&frame-name}.
      end .
    end .
  end .
  if pl-rvd-dens <> pl-rvd-temp
  then do :
    find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst no-error .
    if (available tmp_sr-izmerenia and tmp_sr-izmerenia.sr-type-izm = 0 and tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature)
    or (available dnst_sr-izmerenia and dnst_sr-izmerenia.sr-type-izm = 0 and dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
    then do :
      message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, "
              "если дополнительное автоматизированное СИ предназначено для измерения обоих параметров." skip
              "Подайте заявку в службу поддержки для приведения параметров в соответствие требованиям бизнес-процесса."
      view-as alert-box .
    end .
  end .
  if tmp_sr-izmerenia.sr-density
  and v-mi-tmp <> v-mi-dnst
  and b-mi-dnst:sensitive
  then do :
/*    message "Для измерения температуры выбрано дополнительное СИ " + v-mi-dnst-name + ". Установить данное СИ для измерения плотности автоматически?"*/
/*    view-as alert-box buttons yes-no update vlog .                                                                                                   */
/*    if vlog                                                                                                                                          */
/*    then do :                                                                                                                                        */
      v-mi-dnst = v-mi-tmp .
      v-mi-dnst:screen-value = v-mi-tmp:screen-value .
      v-mi-dnst-name = v-mi-tmp-name .
      apply "leave" to v-mi-dnst in frame Dialog-Frame .
/*    end .*/
  end .
  apply "leave" to tt-rvs-line.state-level-total in frame Dialog-Frame .
end .

on value-changed of t-tank-cleaning in frame Dialog-Frame
do :
  assign t-tank-cleaning .
  find first rvs-line-attr exclusive-lock
     where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
       and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
       and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
       and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
       and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
       and rvs-line-attr.attr-code = "is-calc" no-error.
  if available rvs-line-attr
  then do :
    rvs-line-attr.attr-value = string(no) .
  end .
end .

&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON CHOOSE OF b-calc IN FRAME Dialog-Frame /* Рассчитать */
DO:

define variable v-proc as character no-undo.
define variable v-pokmi-dll-version as character no-undo .

define variable v-code            as character no-undo.
define variable ii                as integer   no-undo.

define variable place-ratio-error as decimal no-undo.
define variable dens-prov         as decimal no-undo format "9.9999999999":U.

define variable CalibTable        as character no-undo initial "".
define variable CalibBelt         as character no-undo initial "".
define variable ToolType          as integer no-undo.
define variable LevelToolType          as integer no-undo.
define variable A_LevelMeasurementTool  as decimal no-undo.
define variable DeltaAbs_H              as decimal no-undo.
define variable DeltaAbs_H_Water        as decimal no-undo.
define variable DeltaAbs_R              as decimal no-undo.
define variable DeltaAbs_Tv             as decimal no-undo.
define variable DeltaAbs_Tr             as decimal no-undo.
define variable DeltaOtn_N              as decimal no-undo init 0.05 .
define variable DeltaOtn_K              as decimal no-undo.
define variable A_Reservoir             as decimal no-undo init 0.0000125 .
define variable DeadZone_Reservoir      as decimal no-undo.
define variable DeltaOtn_H              as decimal no-undo.
define variable DeltaOtn_H_Water        as decimal no-undo.
define variable DeltaOtn_R              as decimal no-undo.
define variable ToolAutomationLevel_H   as integer no-undo.
define variable ToolAutomationLevel_H_Water as integer no-undo.
define variable ToolAutomationLevel_R   as integer no-undo.
define variable ToolAutomationLevel_Tv  as integer no-undo.
define variable ToolAutomationLevel_Tr  as integer no-undo.
define variable DeltaAbs_H_CalcType     as integer no-undo.
define variable DeltaAbs_H_Water_CalcType   as integer no-undo.
define variable temp-for-pomi           as integer no-undo.
define variable error-string            as character no-undo.
define variable v-is-meas               as logical no-undo.
define variable v-mm-density            as decimal no-undo.
define variable place-ponton            as logical no-undo .
define variable place-ponton-mass       as decimal no-undo .
define variable place-ponton-height     as decimal no-undo .

define variable DeltaV1                 as decimal no-undo .
define variable DeltaV2                 as decimal no-undo .
define variable WaterDeltaV1            as decimal no-undo .
define variable WaterDeltaV2            as decimal no-undo .

define variable Tv                      as decimal no-undo .
define variable Tr                      as decimal no-undo .
define variable R                       as decimal no-undo .

define variable v-POkMI-result          as character no-undo.

define buffer buf_sr-izmerenia for sr-izmerenia .
define buffer dens_sr-izmerenia for sr-izmerenia .
define buffer temp_sr-izmerenia for sr-izmerenia .
define buffer level_sr-izmerenia for sr-izmerenia .
define buffer temp-dens_sr-izmerenia for sr-izmerenia .
define buffer buf_place     for ub.place.

define buffer water1_pl-level  for ub.pl-level .
define buffer water2_pl-level  for ub.pl-level .
define buffer total1_pl-level  for ub.pl-level .
define buffer total2_pl-level  for ub.pl-level .
define buffer buf_pl-level-attr for ub.pl-level-attr .

define buffer bf_goods for ub.goods .
define buffer bf_place for ub.place .

define variable vErr as character no-undo .
define variable vWrn as character no-undo .
define variable vDllVersion as character no-undo .

define variable V_total      as decimal no-undo .
define variable V_water      as decimal no-undo .
define variable DeltaV       as decimal no-undo .
define variable Vcy          as decimal no-undo .
define variable Rcy          as decimal no-undo .
define variable V_product    as decimal no-undo .
define variable V            as decimal no-undo .
define variable Rv           as decimal no-undo .
define variable M            as decimal no-undo .
define variable CTL_base_alt as decimal no-undo .
define variable CPL_base_alt as decimal no-undo .
define variable CTPL_base_alt as decimal no-undo .
define variable Fp_base_alt  as decimal no-undo .
define variable CTL_obs_base as decimal no-undo .
define variable CPL_obs_base as decimal no-undo .
define variable CTPL_obs_base as decimal no-undo .
define variable Fp_obs_base  as decimal no-undo .
define variable DeltaOtn_Vcy as decimal no-undo .
define variable DeltaOtn_Vm  as decimal no-undo .
define variable DeltaOtn_M   as decimal no-undo .
define variable VolumetricExpansion as decimal no-undo .


  assign frame {&frame-name} tt-rvs-line.state-level-total   .
  assign frame {&frame-name} tt-rvs-line.state-level-water   .
/*  assign frame {&frame-name} tt-rvs-line.state-temp-layer1   .*/
/*  assign frame {&frame-name} tt-rvs-line.state-temp-layer2   .*/
/*  assign frame {&frame-name} tt-rvs-line.state-temp-layer3   .*/
  assign frame {&frame-name} tt-rvs-line.state-temperature   .
  assign frame {&frame-name} tt-rvs-line.izmer-density       .
  assign frame {&frame-name} tt-rvs-line.temp-izm-vol       .
/*  assign frame {&frame-name} mass-float-cov                  .*/
  assign frame {&frame-name} CriticalDif .
  assign frame {&frame-name} delta-mass-qnty . 
  _trpomi :
    do on error undo, return no-apply :
    
    if tt-rvs-line.izmer-density = ? or tt-rvs-line.izmer-density = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите плотность измер.для ПОкМИ"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.izmer-density in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-level-total = ? or tt-rvs-line.state-level-total = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите факт. общий уровень"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-total in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-level-water = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите факт. уровень воды"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-water in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temperature = ?
    then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите температуру"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temperature in frame {&frame-name}.
      undo _trpomi, return .
    end.
    
    if tt-rvs-line.temp-izm-vol = ?
    then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите температуру измерения объема"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.temp-izm-vol in frame {&frame-name}.
      undo _trpomi, return .
    end.
    
    /*данные по резервуару для ПОкМИ*/
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
/*        when {&place-temp-coef} then do :              */
/*          if v-ok then A_Reservoir = decimal(v-value) .*/
/*        end.                                           */
        when {&place-dead-high} then do :
          if v-ok then DeadZone_Reservoir = decimal(v-value) .
        end.
        when {&place-ponton} then do :
          if v-ok then place-ponton = logical(v-value) .
        end.
        when {&place-ponton-mass} then do :
          if v-ok then place-ponton-mass = decimal(v-value) .
        end.
        when {&place-ponton-height} then do :
          if v-ok then place-ponton-height = decimal(v-value) .
        end.
      end case.
    end.
    /*..........................................*/

    /*градуировочная таблица резервуара для ПОкМИ*/
/*    for last pl-level no-lock                                                                                                */
/*        where pl-level.pl-code  = tt-rvs-line.pl-code                                                                        */
/*          and pl-level.obj-code = tt-rvs-line.obj-code                                                                       */
/*          and pl-level.obj-type = tt-rvs-line.obj-type by pl-level.pl-level                                                  */
/*          :                                                                                                                  */
/*          CalibTable = Substitute("&1=&2","1",(pl-level.pl-qnty / (pl-level.pl-level))) .                                    */
/*    end.                                                                                                                     */
/*    for each  pl-level no-lock                                                                                               */
/*        where pl-level.pl-code  = tt-rvs-line.pl-code                                                                        */
/*          and pl-level.obj-code = tt-rvs-line.obj-code                                                                       */
/*          and pl-level.obj-type = tt-rvs-line.obj-type by pl-level.pl-level                                                  */
/*          :                                                                                                                  */
/*          if CalibTable = "" then CalibTable = Substitute("&1=&2",(pl-level.pl-level ),pl-level.pl-qnty ) .                  */
/*                            else CalibTable = CalibTable + ";" + Substitute("&1=&2",(pl-level.pl-level ),pl-level.pl-qnty ) .*/
/*    end.                                                                                                                     */
/*                                                                                                                             */
/*    CalibTable = CalibTable + ";" + fill({&space-char},(2048 - length(CalibTable))).                                         */
    
    if tt-rvs-line.state-level-water > 0
    then do :
      find last water1_pl-level no-lock where water1_pl-level.pl-code  = tt-rvs-line.pl-code
                                          and water1_pl-level.obj-code = tt-rvs-line.obj-code
                                          and water1_pl-level.obj-type = tt-rvs-line.obj-type
                                          and water1_pl-level.pl-level <= tt-rvs-line.state-level-water
                                          no-error .
      if available water1_pl-level
      then do :
        WaterDeltaV1 = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = water1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = water1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = water1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :      
          WaterDeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
        end .
      end .
      if available water1_pl-level 
      and water1_pl-level.pl-level <> tt-rvs-line.state-level-water
      then do :
        find first water2_pl-level no-lock where water2_pl-level.pl-code  = tt-rvs-line.pl-code
                                            and water2_pl-level.obj-code = tt-rvs-line.obj-code
                                            and water2_pl-level.obj-type = tt-rvs-line.obj-type
                                            and water2_pl-level.pl-level >= tt-rvs-line.state-level-water
                                            no-error .
        if available water2_pl-level
        then do :
          WaterDeltaV2 = ? .
          for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water2_pl-level.pl-code
                                                and buf_pl-level-attr.obj-code = water2_pl-level.obj-code
                                                and buf_pl-level-attr.obj-type = water2_pl-level.obj-type
                                                and buf_pl-level-attr.pl-level = water2_pl-level.pl-level
                                                and buf_pl-level-attr.attr-code = "deltaV"
                                                :      
            WaterDeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
          end .
        end .
      end .
    end .  
    find last total1_pl-level no-lock where total1_pl-level.pl-code  = tt-rvs-line.pl-code
                                        and total1_pl-level.obj-code = tt-rvs-line.obj-code
                                        and total1_pl-level.obj-type = tt-rvs-line.obj-type
                                        and total1_pl-level.pl-level <= tt-rvs-line.state-level-total
                                        no-error . 
    if not available total1_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = tt-rvs-line.gds-code no-error .
      find first bf_place no-lock where bf_place.pl-code = tt-rvs-line.pl-code no-error .
      message 
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return .
    end .
    
    DeltaOtn_K = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "tarir-delta"
                                          :      
      DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) . 
    end .   
    if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .  
    
    DeltaV1 = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :      
      DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
    end . 
                               
    find first total2_pl-level no-lock where total2_pl-level.pl-code  = tt-rvs-line.pl-code
                                        and total2_pl-level.obj-code = tt-rvs-line.obj-code
                                        and total2_pl-level.obj-type = tt-rvs-line.obj-type
                                        and total2_pl-level.pl-level > tt-rvs-line.state-level-total
                                        no-error .   
    if not available total2_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = tt-rvs-line.gds-code no-error .
      find first bf_place no-lock where bf_place.pl-code = tt-rvs-line.pl-code no-error .
      message 
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return .
    end .  
    
    DeltaV2 = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total2_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total2_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total2_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total2_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :      
      DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
    end .                                  
    
    if available water1_pl-level
    then do :
      CalibTable = Substitute("&1=&2", water1_pl-level.pl-level, (water1_pl-level.pl-qnty / 1000)) + (if WaterDeltaV1 > 0 then ("=" + trim(string(WaterDeltaV1, ">>9.9999"))) else "") + {&new-line} .
    end . 
    if available water2_pl-level
    then do :
      CalibTable = CalibTable + Substitute("&1=&2", water2_pl-level.pl-level, (water2_pl-level.pl-qnty / 1000)) + (if WaterDeltaV2 > 0 then ("=" + trim(string(WaterDeltaV2, ">>9.9999"))) else "") + {&new-line} .
    end .  
    CalibTable = CalibTable + Substitute("&1=&2", total1_pl-level.pl-level, (total1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + {&new-line} . 
    CalibTable = CalibTable + Substitute("&1=&2", total2_pl-level.pl-level, (total2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") .
    
    if t-tank-cleaning
    then do :
      CalibTable = "0=0" + {&new-line} + "1=0" .
    end .
    
    CalibBelt = getCalibrationBelt(
        tt-rvs-line.obj-type, 
        tt-rvs-line.obj-code,
        tt-rvs-line.pl-code,
        tt-rvs-line.state-level-total,
        if tt-rvs-line.state-level-water <> ? then tt-rvs-line.state-level-water else 0
    ).
    if t-tank-cleaning
    then do :
      assign CalibBelt = "" .
    end .

    /*..........................................*/

    /*данные по средству измерения резервуара для ПОкМИ*/

    if (pl-rvd-lvl
    and pl-rvd-dens
    and pl-rvd-temp)
    or v-revision-mode
    then do : end .
    else do :
      if place-si = 0
      or place-si = ?
      then do :
        message
          substitute ("Для складского места &1 не заданно средство измерения",tt-rvs-line.pl-code)
        view-as alert-box error.
        undo _trpomi, return no-apply.
      end.
      else do :
        find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si no-error.
        if not available buf_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', place-si ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply.
        end.
        else do :
          assign
            ToolType               = buf_sr-izmerenia.sr-type-id
            A_LevelMeasurementTool = buf_sr-izmerenia.sr-temp-line
            ToolAutomationLevel_H  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            ToolAutomationLevel_H_Water = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_H             = buf_sr-izmerenia.sr-abs-err-neft-water
            DeltaAbs_H_Water       = buf_sr-izmerenia.sr-abs-err-water
            ToolAutomationLevel_R  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_R             = buf_sr-izmerenia.sr-abs-err-dens
            ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_Tv            = buf_sr-izmerenia.sr-abs-err-temp-vol
            ToolAutomationLevel_Tr = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_Tr            = buf_sr-izmerenia.sr-abs-err-temp-dens
            DeltaOtn_N             = 0.05
            DeltaOtn_H             = buf_sr-izmerenia.sr-relative-err-neft-water
            DeltaOtn_H_Water       = buf_sr-izmerenia.sr-relative-err-water
            DeltaOtn_R             = buf_sr-izmerenia.sr-relative-err-dens
            DeltaAbs_H_CalcType    = buf_sr-izmerenia.sr-type-level-measuring + 1
            DeltaAbs_H_Water_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
          .
        end.
      end.
    end.
    
    if pl-rvd-lvl
    or v-revision-mode
    then do :
      if v-mi-lvl = 0
      or v-mi-lvl = ?
      then do :
        message
          substitute ("Для складского места &1 не заданно дополнительное средство измерения уровня",tt-rvs-line.pl-code)
        view-as alert-box error.
        undo _trpomi, return no-apply.
      end .
      else
      if v-mi-lvl <> place-si
      or not available buf_sr-izmerenia
      then do :
        find first level_sr-izmerenia no-lock where level_sr-izmerenia.node-code = v-mi-lvl no-error.
        if not available level_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-lvl ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply.
        end.
        else do :
          assign
            A_LevelMeasurementTool = level_sr-izmerenia.sr-temp-line
            DeltaAbs_H             = level_sr-izmerenia.sr-abs-err-neft-water
            DeltaAbs_H_Water       = level_sr-izmerenia.sr-abs-err-water
            DeltaOtn_H             = level_sr-izmerenia.sr-relative-err-neft-water
            DeltaOtn_H_Water       = level_sr-izmerenia.sr-relative-err-water
          .
        end.
      end .
    end .
    
    if pl-rvd-dens
    or v-revision-mode
    then do :
      if v-mi-dnst = 0
      or v-mi-dnst = ?
      then do :
        message
          substitute ("Для складского места &1 не заданно дополнительное средство измерения плотности",tt-rvs-line.pl-code)
        view-as alert-box error.
        undo _trpomi, return no-apply.
      end .
      else
      if v-mi-dnst <> place-si 
      or not available buf_sr-izmerenia
      then do :
        find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst no-error.
        if not available dens_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-dnst ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply.
        end.
        else do :
          assign
            ToolType               = dens_sr-izmerenia.sr-type-id
            DeltaAbs_R             = dens_sr-izmerenia.sr-abs-err-dens
            DeltaOtn_R             = dens_sr-izmerenia.sr-relative-err-dens
          .
        end.
      end .
    end .
    
    if pl-rvd-temp
    or v-revision-mode
    then do :
      if v-mi-tmp = 0
      or v-mi-tmp = ?
      then do :
        message
          substitute ("Для складского места &1 не заданно дополнительное средство измерения температуры",tt-rvs-line.pl-code)
        view-as alert-box error.
        undo _trpomi, return no-apply.
      end .
      else
      if v-mi-tmp <> place-si 
      or not available buf_sr-izmerenia
      then do :
        find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = v-mi-tmp no-error.
        if not available temp_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-tmp ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply.
        end.
        else do :
          assign
            DeltaAbs_Tv            = temp_sr-izmerenia.sr-abs-err-temp-vol
            DeltaAbs_Tr            = temp_sr-izmerenia.sr-abs-err-temp-dens
            ToolAutomationLevel_Tr = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
          .
        end.
      end .
    end .
    
    if v-mi-tmp-dnst > 0
    and v-mi-tmp-dnst <> v-mi-tmp
    then do :
      for first temp-dens_sr-izmerenia no-lock where temp-dens_sr-izmerenia.node-code = v-mi-tmp-dnst :
        assign 
          DeltaAbs_Tr = temp-dens_sr-izmerenia.sr-abs-err-temp-dens when temp-dens_sr-izmerenia.sr-abs-err-temp-dens > 0
          ToolAutomationLevel_Tr = vAutomationDegree[temp-dens_sr-izmerenia.sr-type-izm + 1]
        .
      end .
    end .
    
    if available level_sr-izmerenia
    then assign
      LevelToolType = level_sr-izmerenia.sr-type-level-measuring 
      ToolAutomationLevel_H  = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
      ToolAutomationLevel_H_Water = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
      DeltaAbs_H_CalcType = level_sr-izmerenia.sr-type-level-measuring + 1
      DeltaAbs_H_Water_CalcType = level_sr-izmerenia.sr-type-level-measuring + 1
    .
    else assign
      LevelToolType = buf_sr-izmerenia.sr-type-level-measuring 
      ToolAutomationLevel_H  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      ToolAutomationLevel_H_Water = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      DeltaAbs_H_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
      DeltaAbs_H_Water_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
    .
    
    if avail temp_sr-izmerenia then
      ToolAutomationLevel_Tv = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1].
    else 
      ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1].
      
    if avail dens_sr-izmerenia then
      ToolAutomationLevel_R  = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1].
    else 
      ToolAutomationLevel_R = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1].

    if available dens_sr-izmerenia
    and dens_sr-izmerenia.sr-type-izm = 3
    and dens_sr-izmerenia.sr-temperature
    then do :
      DeltaAbs_Tr = dens_sr-izmerenia.sr-abs-err-temp-dens .
      ToolAutomationLevel_Tr = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1].
    end .
    
    if DeltaAbs_H       = ? then DeltaAbs_H = 0 .
    if DeltaAbs_H_Water = ? then DeltaAbs_H_Water = 0 .
    if DeltaAbs_R       = ? then DeltaAbs_R = 0 .
    if DeltaAbs_Tv      = ? then DeltaAbs_Tv = 0 .
    if DeltaAbs_Tr      = ? then DeltaAbs_Tr = 0 .
    if DeltaOtn_N       = ? then DeltaOtn_N = 0 .
    if DeltaOtn_H       = ? then DeltaOtn_H = 0 .
    if DeltaOtn_H_Water = ? then DeltaOtn_H_Water = 0 .
    if DeltaOtn_R       = ? then DeltaOtn_R = 0 .
    if LevelToolType    = ? then LevelToolType = 0 .
    if ToolType         = ? then ToolType = 0 .
    if A_LevelMeasurementTool      = ? then A_LevelMeasurementTool = 0 .
    if ToolAutomationLevel_Tr      = ? then ToolAutomationLevel_Tr =0.
    if ToolAutomationLevel_H       = ? then ToolAutomationLevel_H = 0.
    if ToolAutomationLevel_H_Water = ? then ToolAutomationLevel_H_Water = 0.
    if ToolAutomationLevel_Tv      = ? then ToolAutomationLevel_Tv = 0.
    if ToolAutomationLevel_R       = ? then ToolAutomationLevel_R = 0.
    if DeltaAbs_H_CalcType         = ? then DeltaAbs_H_CalcType = 0.
    if DeltaAbs_H_Water_CalcType   = ? then DeltaAbs_H_Water_CalcType = 0.
    
    if tt-rvs-line.state-level-water = 0
    then do :
      ToolAutomationLevel_H_Water = 3 .
      DeltaAbs_H_Water_CalcType = 1 .
      DeltaAbs_H_Water = 0 .
      DeltaOtn_H_Water = 0 .
    end .
    
    /*..........................................*/
    
    if LevelToolType > 0
    then do :
      MM57
        (input tt-rvs-line.state-level-total * 10,
         input LevelToolType,
         output DeltaAbs_H,
         output vErr,
         output vWrn,
         output vDllVersion)
      .  
      OUTPUT stream outstream to value ("pomi.log") append.
      PUT STREAM outstream unformatted
                  "    " SKIP
                  "    " SKIP
                  cur-time-string()           FORMAT "x(16)"    SKIP
                  'Процедура             "CMethodOfMetering57"'       SKIP
                  'Версия dll: '            vDllVersion   skip
                  'CODE_PL                = ' tt-rvs-line.pl-code                           SKIP
                  'H                      = ' tt-rvs-line.state-level-total * 10                  SKIP
                  'ToolType               = ' LevelToolType                                      SKIP
                      SKIP SKIP 
      .
      output stream outstream close.
        
      if trim(vErr) > "" then do :
        output stream outstream to value ("pomi.log")  append.
        put stream outstream vErr format "X(1024)" skip.
        output stream outstream close.
        message substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) view-as alert-box .
        undo _trpomi, return no-apply .
      end.
      else do :
        OUTPUT stream outstream to value ("pomi.log")  append.
        PUT STREAM outstream unformatted
            "DeltaAbs_H = " DeltaAbs_H  SKIP
        .
        OUTPUT stream outstream close.
      end .
    end .
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
    
    assign
      Tr = tt-rvs-line.state-temperature
      Tv = if tt-rvs-line.temp-izm-vol <> ? then tt-rvs-line.temp-izm-vol else tt-rvs-line.state-temperature 
      R = ( tt-rvs-line.izmer-density * 1000 )
    .
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "Tr"
                                      :
      assign Tr = decimal(rvs-line-attr.attr-value) .
    end . 
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "Tv"
                                      :
      assign Tv = decimal(rvs-line-attr.attr-value) .
    end . 
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "R"
                                      :
      assign R = decimal(rvs-line-attr.attr-value) * 1000 .
    end . 
    /*метод применяемый к данному типу резервуара и */
    find first buf_place no-lock
         where buf_place.obj-code = tt-rvs-line.obj-code
           and buf_place.obj-type = tt-rvs-line.obj-type
           and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
    if place-type = 1 then do :
      v-proc = "CMethodOfMetering13" .
      MM13
        (input 0.0, /*(if place-ponton then place-ponton-mass else 0.0)*/
         input 0.0, /*(if place-ponton then dens-prov * 1000 else 0.0)*/
         input 0.0,
         input 0.0, /*(if place-ponton then place-ponton-height else 0.0)*/
         input tt-rvs-line.state-level-total * 10,
         input (if tt-rvs-line.state-level-water <> ? then tt-rvs-line.state-level-water * 10 else 0.0),
         input CalibTable,
         input CalibBelt,
         input 0.0, /* P0 */
         input 0.0, /* PV */
         input Tv,
         input Tr,
         input R,
         input temp-for-pomi,
         input ToolType,
         input DeltaOtn_K,
         input DeadZone_Reservoir,
         input A_Reservoir,
         input A_LevelMeasurementTool,
         input ToolAutomationLevel_H,
         input ToolAutomationLevel_H_Water,
         input ToolAutomationLevel_R,
         input ToolAutomationLevel_Tv,
         input ToolAutomationLevel_Tr,
         input DeltaAbs_H_CalcType,
         input DeltaAbs_H_Water_CalcType,
         input DeltaAbs_H,
         input DeltaAbs_H_Water,
         input DeltaAbs_R,
         input DeltaAbs_Tv,
         input DeltaAbs_Tr,
         input DeltaOtn_N,
         input 1, /* Round_M */
         input 2, /* Round_T */
         input 2, /* Round_R */
         
         output V_total,
         output V_water,
         output DeltaV,
         output V_product,
         output Vcy,
         output Rcy,
         output V,
         output CTL_base_alt,
         output CPL_base_alt,
         output CTPL_base_alt,
         output Fp_base_alt,
         output CTL_obs_base,
         output CPL_obs_base,
         output CTPL_obs_base,
         output Fp_obs_base,
         output Rv,
         output DeltaOtn_Vcy,
         output DeltaOtn_Vm,
         output M,
         output DeltaOtn_M,
         output VolumetricExpansion,
         
         output vErr,
         output vWrn,
         output vDllVersion)
      no-error .
    end.
    else do :
      v-proc = "CMethodOfMetering6" .
      MM6
        (input tt-rvs-line.state-level-total * 10,
         input (if tt-rvs-line.state-level-water <> ? then tt-rvs-line.state-level-water * 10 else 0.0),
         input CalibTable,
         input CalibBelt,
         input 0.0, /* P0 */
         input Tv,
         input Tr,
         input R,
         input temp-for-pomi,
         input ToolType,
         input DeltaOtn_K,
         input DeadZone_Reservoir,
         input A_Reservoir,
         input A_LevelMeasurementTool,
         input ToolAutomationLevel_H,
         input ToolAutomationLevel_H_Water,
         input ToolAutomationLevel_R,
         input ToolAutomationLevel_Tv,
         input ToolAutomationLevel_Tr,
         input DeltaAbs_H_CalcType,
         input DeltaAbs_H_Water_CalcType,
         input DeltaAbs_H,
         input DeltaAbs_H_Water,
         input DeltaAbs_R,
         input DeltaAbs_Tv,
         input DeltaAbs_Tr,
         input DeltaOtn_N,
         input 1, /* Round_M */
         input 2, /* Round_T */
         input 2, /* Round_R */
         
         output V_total,
         output V_water,
         output DeltaV,
         output V_product,
         output Vcy,
         output Rcy,
         output V,
         output CTL_base_alt,
         output CPL_base_alt,
         output CTPL_base_alt,
         output Fp_base_alt,
         output CTL_obs_base,
         output CPL_obs_base,
         output CTPL_obs_base,
         output Fp_obs_base,
         output Rv,
         output DeltaOtn_Vcy,
         output DeltaOtn_Vm,
         output M,
         output DeltaOtn_M,
         output VolumetricExpansion,
         
         output vErr,
         output vWrn,
         output vDllVersion)
      no-error .
    end.
    /*..............................................*/

    OUTPUT stream outstream to value ("pomi.log") append.
    PUT STREAM outstream unformatted
      "    " SKIP
      "    " SKIP
      cur-time-string()           FORMAT "x(16)"    SKIP
      'Процедура   "'              v-proc       '"'               FORMAT "x(128)"   SKIP
      'Версия dll: '              vDllVersion                           SKIP
      'CODE_PL                     = ' tt-rvs-line.pl-code                      SKIP
      'H                           = ' tt-rvs-line.state-level-total * 10 SKIP
      'H_water                     = ' (if tt-rvs-line.state-level-water <> ? then tt-rvs-line.state-level-water * 10 else 0.0) SKIP
      'CalibrationTable            = ' CalibTable                    SKIP
      'CalibrationBelt             = ' CalibBelt                    SKIP
      'ToolAutomationLevel_H       = ' ToolAutomationLevel_H     SKIP
      'ToolAutomationLevel_H_Water = ' ToolAutomationLevel_H_Water    SKIP
      'ToolAutomationLevel_R       = ' ToolAutomationLevel_R     SKIP
      'ToolAutomationLevel_Tv      = ' ToolAutomationLevel_Tv    SKIP
      'ToolAutomationLevel_Tr      = ' ToolAutomationLevel_Tr    SKIP
      'DeltaAbs_H_CalcType         = ' DeltaAbs_H_CalcType       SKIP
      'DeltaAbs_H_Water_CalcType   = ' DeltaAbs_H_Water_CalcType SKIP
      'Tv                          = ' round(Tv, 2)              SKIP
      'Tr                          = ' round(Tr, 2)              SKIP
      'R                           = ' round(R, 2)               SKIP
      'Tcy                         = ' temp-for-pomi                       SKIP
      'ToolType                    = ' ToolType                            SKIP
      'DeadZone_Reservoir          = ' DeadZone_Reservoir                  SKIP
      'DeltaOtn_K                  = ' DeltaOtn_K                          SKIP
      'A_Reservoir                 = ' A_Reservoir                         SKIP
      'A_LevelMeasurementTool      = ' A_LevelMeasurementTool              skip
      'DeltaAbs_H                  = ' DeltaAbs_H                          SKIP
      'DeltaAbs_H_Water            = ' DeltaAbs_H_Water                    SKIP
      'DeltaAbs_R                  = ' DeltaAbs_R                          SKIP
      'DeltaAbs_Tv                 = ' DeltaAbs_Tv                         SKIP
      'DeltaAbs_Tr                 = ' DeltaAbs_Tr                         SKIP
      'DeltaOtn_N                  = ' DeltaOtn_N                          SKIP
      'Round_M                     = ' 1                                   SKIP
      'Round_T                     = ' 2                                   SKIP
      'Round_R                     = ' 2                                   SKIP
    .
      
    if place-type = 1
    and place-ponton
    then do :
      put stream outstream unformatted
        "Rprov                  = " 0.0 skip
        "Mpokr                  = " 0.0 skip
        "Vdisp                  = " 0.0 skip
        "CoverFloatingHeight    = " 0.0 skip
      .
    end.
      
    output stream outstream close.
      
    if trim(vErr) > "" then do :
      error-string = substitute("~nРезервуар: &1.~n", if avail buf2_place then buf2_place.loc1 else "") 
                   + replace(vErr,";0x","~n0x") .
      output stream outstream to value ("pomi.log")  append.
      put stream outstream error-string format "X(1024)" skip.
      message
      substitute('Ошибка работы библиотеки ПОкМИ. &1',error-string)
      view-as alert-box error.
      output stream outstream close.
      undo _trpomi, return no-apply .
    end.
    else do :
      v-mm-density = Rv / 1000 .
      varstate-water-qnty = V_water * 1000 .
      assign        
        tt-rvs-line.state-measure-qnty     = V * 1000       
        tt-rvs-line.state-measure-cli-qnty = M        
        tt-rvs-line.state-brutto-qnty      = tt-rvs-line.state-measure-qnty + varstate-water-qnty
        tt-rvs-line.state-density          = v-mm-density
      .
      
      assign
        tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty * tt-rvs-line.state-density  
        tt-rvs-line.fact-sum-vol = tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty 
        tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty 
        varstate-sum-vol = varstate-water-qnty + tt-rvs-line.state-measure-qnty 
      .
      
      abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 .
      
      tt-rvs-line.state-brutto-cli-qnty  = tt-rvs-line.state-brutto-qnty * tt-rvs-line.state-density .
      
      if  tt-rvs-line.state-measure-cli-qnty > 200000 then delta-mass-qnty = 0.5 . else delta-mass-qnty = 0.65.   
      
      abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
      
      display
        delta-mass-qnty 
/*        tt-rvs-line.state-brutto-qnty    */
/*        tt-rvs-line.state-brutto-cli-qnty*/
/*        tt-rvs-line.state-measure-qnty*/
        tt-rvs-line.state-density
        tt-rvs-line.state-measure-cli-qnty
        tt-rvs-line.state-measure-qnty
        tt-rvs-line.fact-sum-vol
        tt-rvs-line.fact-sum-mass
        tt-rvs-line.fact-calc-add-mass
        abs-delta-mass-add-qnty
        abs-delta-mass-qnty
        varstate-sum-vol
        varstate-water-qnty
      with frame {&frame-name} .
      
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
              and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
              and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
              and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
              and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
              and rvs-line-attr.attr-code = "pokmi-water-qnty" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = string(V_water * 1000) .
      end.
      else do :
        create rvs-line-attr.
          assign
              rvs-line-attr.obj-code   = tt-rvs-line.obj-code
              rvs-line-attr.obj-type   = tt-rvs-line.obj-type
              rvs-line-attr.gds-code   = tt-rvs-line.gds-code
              rvs-line-attr.pl-code    = tt-rvs-line.pl-code
              rvs-line-attr.rvs-code   = tt-rvs-line.rvs-code
              rvs-line-attr.attr-code  = "pokmi-water-qnty"
              rvs-line-attr.attr-value = string(V_water * 1000)
          .
      END.
        
      assign
        v-POkMI-result =
          "V_total             = " + string(V_total)       + {&new-line} +
          "V_water             = " + string(V_water)       + {&new-line} +
          "DeltaV              = " + string(DeltaV)         + {&new-line} +
          "Vcy                 = " + string(Vcy)           + {&new-line} +
          "Rcy                 = " + string(Rcy)            + {&new-line} +
          "V_product           = " + string(V_product)      + {&new-line} +
          "V                   = " + string(V)              + {&new-line} + 
          "Rv                  = " + string(Rv)               + {&new-line} +
          "M                   = " + string(M)                 + {&new-line} +
          "CTL_base_alt        = " + string(CTL_base_alt)  + {&new-line} +
          "CPL_base_alt        = " + string(CPL_base_alt)  + {&new-line} +
          "CTPL_base_alt       = " + string(CTPL_base_alt)  + {&new-line} +
          "Fp_base_alt         = " + string(Fp_base_alt)   + {&new-line} +
          "CTL_obs_base        = " + string(CTL_obs_base)  + {&new-line} +
          "CPL_obs_base        = " + string(CPL_obs_base)  + {&new-line} +
          "CTPL_obs_base       = " + string(CTPL_obs_base)  + {&new-line} +
          "Fp_obs_base         = " + string(Fp_obs_base)   + {&new-line} +
          "DeltaOtn_Vcy        = " + string(DeltaOtn_Vcy)  + {&new-line} +
          "DeltaOtn_Vm         = " + string(DeltaOtn_Vm)   + {&new-line} +
          "DeltaOtn_M          = " + string(DeltaOtn_M)       + {&new-line} +
          "VolumetricExpansion = " + string(VolumetricExpansion) + {&new-line} +
          "Warnings            = " + vWrn
      .
      OUTPUT stream outstream to value ("pomi.log")  append.
      PUT STREAM outstream unformatted v-POkMI-result skip .
      OUTPUT stream outstream close.
      
      assign
        v-POkMI-result-attr = 
          "Масса НП, кг: " + string(M, "->>,>>>,>>9.9":U) + {&new-line} +
          "Относительная погрешность измерения массы нефтепродукта, %: "  + string(DeltaOtn_M, "->>,>>9.99":U) + {&new-line} +
          "Плотность, приведенная к стандартным условиям, г/см3: " + string((Rcy / 1000), "9.9999":U) + {&new-line} +
          "Объем, приведенный к стандартным условиям, л: " + string((Vcy * 1000), "->>,>>>,>>9":U) + {&new-line} +
          "Объем НП при температуре его измерения, л: " + string((V * 1000), "->>,>>>,>>9":U) + {&new-line} +
          "Объем воды, л: " + string((V_water * 1000), "->>,>>>,>>9":U)
      
        v-POkMI-warnings = vWrn
      .
      
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
              and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
              and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
              and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
              and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
              and rvs-line-attr.attr-code = "POkMI-result" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = v-POkMI-result-attr .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "POkMI-result"
          rvs-line-attr.attr-value = v-POkMI-result-attr
        .
      end.
      
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
              and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
              and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
              and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
              and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
              and rvs-line-attr.attr-code = "POkMI-warnings" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = v-POkMI-warnings .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "POkMI-warnings"
          rvs-line-attr.attr-value = v-POkMI-warnings
        .
      end.
      
      enable
        b-POkMI-result
      with frame Dialog-Frame.
      
      run volume-water no-error.
      if error-status :error then do :
                               undo _trpomi, return .
                             end.
      run chg-density no-error.
      if error-status :error then do :
                               undo _trpomi, return .
                             end.
      run weath-water no-error.
      if error-status:error then do :
                              undo _trpomi, return .
                            end.
    end.
  end.
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "is-calc" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "is-calc"
    .
  end.
  assign rvs-line-attr.attr-value = "yes" .
  release rvs-line-attr no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-temperature
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-temperature Dialog-Frame
ON CHOOSE OF b-temperature IN FRAME Dialog-Frame /* Ввод */
DO:
  define buffer temp_sr-izmerenia for sr-izmerenia .
  define buffer dens_sr-izmerenia for sr-izmerenia .
  define variable vOk as logical no-undo .
  define variable v-out-temp as decimal no-undo .
  define variable v-calc-type as integer no-undo init 1 .
  define variable v-izm-temps as character no-undo .
  define variable v-izm-temps-tab as character no-undo .
  
  if pl-rvd-temp
  or v-revision-mode
  then do :
    find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = v-mi-tmp no-error.  
  end .
  else do :
    find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = place-si no-error.
  end .
  if not available temp_sr-izmerenia
  then do :
    message "Для резервуара не задано основное средство измерения или средство измерения температуры!" view-as alert-box .
    return no-apply .
  end .
  if not temp_sr-izmerenia.sr-temperature
  then do :
    message "Средство измерения " string(temp_sr-izmerenia.node-code) " не может измерять температуру!" view-as alert-box .
    return no-apply .
  end . 
  if temp_sr-izmerenia.sr-type-izm = 2 /* 2 - Измерительная система */
  then do :
    message "Средство измерения температуры " string(temp_sr-izmerenia.node-code) " является измерительной системой! Значение температуры определяется показателями СИ." view-as alert-box .
    return no-apply .
  end .                 
  for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                    and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                    and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                    and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                    and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                    and rvs-line-attr.attr-code = "temp-calc-type"
                                    :
    v-calc-type = integer(rvs-line-attr.attr-value) .                                  
  end .        

  run str/rvs-lin-temperature.w (input temp_sr-izmerenia.sr-type-izm,
                                 input place-type,
                                 input place-diameter,
                                 input (if place-type = 1 then ((tt-rvs-line.state-level-total - tt-rvs-line.state-level-water) * 10) else (tt-rvs-line.state-level-total * 10)),
                                 input-output v-calc-type,
                                 output v-out-temp,
                                 output vOk)
                                 .
  if vOk
  then do :      
    tt-rvs-line.temp-izm-vol = v-out-temp .    
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "Tv" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "Tv"
        rvs-line-attr.attr-value = string(v-out-temp)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(v-out-temp) .
    end.                    
    display tt-rvs-line.temp-izm-vol with frame Dialog-Frame .
        
    assign v-hand-input-tmp = true .
    
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "temp-calc-type" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "temp-calc-type"
        rvs-line-attr.attr-value = string(v-calc-type)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(v-calc-type) .
    end.
    
    if pl-rvd-temp
    and not pl-rvd-dens
    then do :
      tt-rvs-line.state-temperature = v-out-temp .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "Tr" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "Tr"
          rvs-line-attr.attr-value = string(v-out-temp)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(v-out-temp) .
      end.
      display tt-rvs-line.state-temperature with frame Dialog-Frame .
    end . 
    
    if (pl-rvd-temp
    and pl-rvd-dens)
    or v-revision-mode
    then do :
      find first rvs-line-attr no-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "state-temp-changed" no-error.
      if available rvs-line-attr
      and logical(rvs-line-attr.attr-value)
      then do : end .
      else do :
        tt-rvs-line.state-temperature = v-out-temp .
        find first rvs-line-attr exclusive-lock
             where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
               and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
               and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
               and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
               and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
               and rvs-line-attr.attr-code = "Tr" no-error.
        if not available rvs-line-attr then do :
          create rvs-line-attr.
          assign
            rvs-line-attr.obj-code  = tt-rvs-line.obj-code
            rvs-line-attr.obj-type  = tt-rvs-line.obj-type
            rvs-line-attr.gds-code  = tt-rvs-line.gds-code
            rvs-line-attr.pl-code   = tt-rvs-line.pl-code
            rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
            rvs-line-attr.attr-code = "Tr"
            rvs-line-attr.attr-value = string(v-out-temp)
          .
        end.
        else do :
          rvs-line-attr.attr-value = string(v-out-temp) .
        end.
        display tt-rvs-line.state-temperature with frame Dialog-Frame .
      end .       
    end .
    
    find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "is-calc" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = string(no) .
    end .
    
    v-izm-temps-tab = string(temp_sr-izmerenia.sr-type-izm) + ";" .
    if temp_sr-izmerenia.sr-type-izm = 0 /* 0 - Автоматизированное СИ */
    then do :
      for each tt-temps-tab no-lock by tt-temps-tab.ii descending :
        v-izm-temps-tab = v-izm-temps-tab + string(tt-temps-tab.temperature) + "," .
      end .
    end .
    else do :
      for each tt-temps-tab no-lock by tt-temps-tab.ii :
        v-izm-temps-tab = v-izm-temps-tab + string(tt-temps-tab.temperature) + "," .
      end .
    end .
    v-izm-temps-tab = trim(v-izm-temps-tab, ",") .
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "izm-temps-tab" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "izm-temps-tab"
        rvs-line-attr.attr-value = v-izm-temps-tab
      .
    end.
    else do :
      rvs-line-attr.attr-value = v-izm-temps-tab .
    end.
    
    if pl-rvd-dens
    or v-revision-mode
    then do :
      find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst no-error.
    end .
    else do :
      find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = place-si no-error.
    end .
  
    if available dens_sr-izmerenia 
    and dens_sr-izmerenia.sr-type-izm = 0 /* 0 - Автоматизированное СИ */
    then do :
/*      tt-rvs-line.state-temperature = v-out-temp .                   */
/*      display tt-rvs-line.state-temperature with frame Dialog-Frame .*/
      
      v-izm-temps = string(dens_sr-izmerenia.sr-type-izm) + ";" .
      for each tt-temps no-lock by tt-temps.ii descending :
        v-izm-temps = v-izm-temps + string(tt-temps.temperature) + "," .
      end .
      v-izm-temps = trim(v-izm-temps, ",") .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "izm-temps"
          rvs-line-attr.attr-value = v-izm-temps
        .
      end.
      else do :
        rvs-line-attr.attr-value = v-izm-temps .
      end.
    end .
  end .                              
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-density Dialog-Frame
ON CHOOSE OF b-density IN FRAME Dialog-Frame /* Ввод */
DO:
  define buffer dens_sr-izmerenia for sr-izmerenia .
  define variable vOk as logical no-undo .
  define variable v-out-dens as decimal no-undo .
  define variable v-out-temp as decimal no-undo .
  define variable v-izm-temps as character no-undo .
  define variable v-izm-denses as character no-undo .
  define variable v-calc-type as integer no-undo init 1 .
  
  if pl-rvd-dens
  or v-revision-mode
  then do :
    find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst no-error.
  end .
  else do :
    find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = place-si no-error.
  end .   
  if not available dens_sr-izmerenia
  then do :
    message "Для резервуара не задано основное средство измерения или средство измерения плотности!" view-as alert-box .
    return no-apply .
  end .
  if not dens_sr-izmerenia.sr-density
  then do :
    message "Средство измерения " string(dens_sr-izmerenia.node-code) " не может измерять плотность!" view-as alert-box .
    return no-apply .
  end .
  if dens_sr-izmerenia.sr-type-izm = 2 /* 2 - Измерительная система*/
  then do :
    message "Средство измерения плотности " string(dens_sr-izmerenia.node-code) " является измерительной системой! Значение плотности определяется показателями СИ." view-as alert-box .
    return no-apply .
  end .
  if dens_sr-izmerenia.sr-type-izm = 0 /* 0 - Автоматизированное СИ */
  then do :  
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "dens-calc-type"
                                      :
      v-calc-type = integer(rvs-line-attr.attr-value) .                                  
    end .                  
    run str/rvs-lin-density.w (input dens_sr-izmerenia.sr-type-izm,
                               input place-type,
                               input place-diameter,
                               input (if place-type = 1 then ((tt-rvs-line.state-level-total - tt-rvs-line.state-level-water) * 10) else (tt-rvs-line.state-level-total * 10)),
                               input-output v-calc-type,
                               output v-out-dens,
                               output vOk)
                               .
    if vOk
    then do :
      assign
        tt-rvs-line.izmer-density = v-out-dens                          
        tt-rvs-line.state-density = tt-rvs-line.izmer-density
      .
      
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "R" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "R"
          rvs-line-attr.attr-value = string(v-out-dens)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(v-out-dens) .
      end.
      display tt-rvs-line.izmer-density tt-rvs-line.state-density with frame Dialog-Frame . 
      
      assign v-hand-input-dnst = true .
      
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "dens-calc-type" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "dens-calc-type"
          rvs-line-attr.attr-value = string(v-calc-type)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(v-calc-type) .
      end.
      
      find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "is-calc" no-error.
      if available rvs-line-attr
      then do :
        rvs-line-attr.attr-value = string(no) .
      end .
      
      v-izm-denses = string(dens_sr-izmerenia.sr-type-izm) + ";" .
      for each tt-dens no-lock by tt-dens.ii descending :
        v-izm-denses = v-izm-denses + string(tt-dens.density) + "," .
      end .
      v-izm-denses = trim(v-izm-denses, ",") .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-denses" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "izm-denses"
          rvs-line-attr.attr-value = v-izm-denses
        .
      end.
      else do :
        rvs-line-attr.attr-value = v-izm-denses .
      end.
    end .
  end .
  if dens_sr-izmerenia.sr-type-izm = 1 /* 1 - Неавтоматизированное СИ */
  then do :
    v-mi-tmp-dnst = v-mi-tmp .
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "mi-tmp-dnst"
                                      :
      v-mi-tmp-dnst = integer(rvs-line-attr.attr-value) .                                  
    end .
    if v-mi-tmp-dnst = ? then v-mi-tmp-dnst = 0 .                    
    run str/rvs-lin-dens-temp.w (input parparentproc,
                                 input dens_sr-izmerenia.sr-type-izm,
                                 input place-type,
                                 input place-diameter,
                                 input tt-rvs-line.state-level-total * 10,
                                 input-output v-mi-tmp-dnst,
                                 output v-out-dens,
                                 output v-out-temp,
                                 output vOk)
                                 .
    if vOk
    then do : 
      assign      
        tt-rvs-line.izmer-density = v-out-dens                    
        tt-rvs-line.state-density = tt-rvs-line.izmer-density
      .                           
      
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "R" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "R"
          rvs-line-attr.attr-value = string(v-out-dens)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(v-out-dens) .
      end.
      display tt-rvs-line.izmer-density tt-rvs-line.state-density with frame Dialog-Frame . 
      
      assign v-hand-input-dnst = true .
      assign v-hand-input-tmp = true .
      tt-rvs-line.state-temperature = v-out-temp .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "Tr" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "Tr"
          rvs-line-attr.attr-value = string(v-out-temp)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(v-out-temp) .
      end.
      display tt-rvs-line.state-temperature with frame Dialog-Frame .
      
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "mi-tmp-dnst" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "mi-tmp-dnst"
          rvs-line-attr.attr-value = string(v-mi-tmp-dnst)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(v-mi-tmp-dnst) .
      end.
      
      find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "is-calc" no-error.
      if available rvs-line-attr
      then do :
        rvs-line-attr.attr-value = string(no) .
      end .
      
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "state-temp-changed" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "state-temp-changed"
          rvs-line-attr.attr-value = string(yes)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(yes) .
      end.
      
      v-izm-temps = string(dens_sr-izmerenia.sr-type-izm) + ";" .
      v-izm-denses = string(dens_sr-izmerenia.sr-type-izm) + ";" .
      for each tt-dens-temp no-lock by tt-dens-temp.ii :
        v-izm-temps = v-izm-temps + string(tt-dens-temp.temperature) + "," .
        v-izm-denses = v-izm-denses + string(tt-dens-temp.density) + "," .
      end .
      v-izm-temps = trim(v-izm-temps, ",") .
      v-izm-denses = trim(v-izm-denses, ",") .
      
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "izm-temps"
          rvs-line-attr.attr-value = v-izm-temps
        .
      end.
      else do :
        rvs-line-attr.attr-value = v-izm-temps .
      end.
      
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-denses" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "izm-denses"
          rvs-line-attr.attr-value = v-izm-denses
        .
      end.
      else do :
        rvs-line-attr.attr-value = v-izm-denses .
      end.
    end .
  end .                              
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Ввод */
DO:
  define variable v-water     as decimal   no-undo .
  define variable v-water-cli as decimal   no-undo .
  define variable v-free-vol  as decimal   no-undo .
  define variable v-vid-action        as integer no-undo .
  define variable v-vid-param         as longchar no-undo .
  { gbl/stdbtn.i }
  define variable v-shift-date like ub.shift-obj.shift-date no-undo .
  define variable v-shift-num  like ub.shift-obj.shift-num no-undo .
  define variable v-shift-name like ub.shift-obj.shift-name no-undo.
  
  define buffer olddens-rvs-line-attr for ub.rvs-line-attr .
  define variable v-is-olddens as logical no-undo initial no .
  
  define variable v-rvd-reason   as character no-undo .
  define variable v-ITSM-num     as character no-undo .
  define variable v-oper-fio     as character no-undo .
  
  define buffer buf_doc-pl for ub.doc-pl .
  define buffer buf_place for ub.place .
  define buffer buf_doc-pl-attr for doc-pl-attr .
    
  { gbl/curshift.i
    buf_rvs-doc.obj-type
    buf_rvs-doc.obj-code
    v-shift-date
    v-shift-num
    v-shift-name
    no-error
  }
  
/*  if tt-rvs-line.state-measure-qnty > tt-rvs-line.state-brutto-qnty  then do:*/
/*     message "Объем топлива больше общего объема."                           */
/*     view-as alert-box error.                                                */
/*     apply "entry" to tt-rvs-line.state-measure-qnty in frame {&frame-name}. */
/*     return no-apply.                                                        */
/*  end.                                                                       */
  
  
  if rdc-value = "pomi-rn" then do :
    if tt-rvs-line.izmer-density = ? or tt-rvs-line.izmer-density = 0
    then do :
      message "Сохранение введенных параметров НП невозможно." skip (1)
              "Плотность НП унаследована у предыдущего документа сверки." skip
              'Введите измеренную плотность и нажмите кнопку "Рассчитать".'
      view-as alert-box information.
      apply "entry" to tt-rvs-line.izmer-density in frame {&frame-name}.
      return no-apply.
    end.
    
    find first rvs-line-attr no-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "is-calc" no-error.
    if not available rvs-line-attr
    or (available rvs-line-attr and rvs-line-attr.attr-value <> "yes") 
    then do :
      message "Сохранение введенных параметров НП невозможно." skip (1)
              "Не выполнено приведение параметров НП к стандартной температуре." skip
              'Нажмите кнопку "Рассчитать" и повторите попытку.'
      view-as alert-box information.
      apply "entry" to b-calc in frame {&frame-name}.
      return no-apply.
    end.  
  end.    

  

  find first buf_rvs-line
    where recid(buf_rvs-line) =  parrec-rvs-line
    no-error.
  find first buf_rvs-doc no-lock
    where buf_rvs-doc.rvs-code = tt-rvs-line.rvs-code
    .
  /* Все validation */
  run level-water in this-procedure
    ( input yes
    ) no-error.
  if error-status :error then do:
    apply "ENTRY":U to tt-rvs-line.state-level-total in frame {&frame-name}.
    return no-apply.
  end.
  run volume-water in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  run chg-density  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  run weath-water  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  assign frame {&frame-name} {&list-3}.
  assign tt-rvs-line.state-level-petrol = tt-rvs-line.state-level-total - tt-rvs-line.state-level-water .
  buffer-copy tt-rvs-line to buf_rvs-line.
  
  if v-revision-mode
  and rdc-value = "pomi-rn"
  then do : /* Пишем атрибут с причинами установки РВД, чтобы записать в историю при закрытии на факт */
    find first buf_place no-lock
         where buf_place.obj-code = tt-rvs-line.obj-code
           and buf_place.obj-type = tt-rvs-line.obj-type
           and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
           
    find first buf_rvs-doc-attr exclusive-lock where buf_rvs-doc-attr.rvs-code = buf_rvs-doc.rvs-code
                                                 and buf_rvs-doc-attr.attr-code = "rvd-reason"
                                                 no-error .
    if available buf_rvs-doc-attr
    then do :
      v-rvd-reason = entry(1, buf_rvs-doc-attr.attr-value, {&delim-par}) .
      v-ITSM-num = entry(2, buf_rvs-doc-attr.attr-value, {&delim-par}) .
      v-oper-fio = entry(3, buf_rvs-doc-attr.attr-value, {&delim-par}) .
    end .
    else do :
      run ref/rvd-reasons.w (input parparentproc,
                             input -1, /*Инвентаризация РГС */
                             output v-rvd-reason,
                             output v-ITSM-num,
                             output v-oper-fio)
                             .
      if v-rvd-reason = ?
      then do :
        return no-apply .
      end .
           
      create buf_rvs-doc-attr .
      assign
        buf_rvs-doc-attr.rvs-code = buf_rvs-doc.rvs-code
        buf_rvs-doc-attr.attr-code = "rvd-reason"
        buf_rvs-doc-attr.attr-value = v-rvd-reason + {&delim-par} +
                                    v-ITSM-num + {&delim-par} +
                                    v-oper-fio + {&delim-par}
      .
    end .
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "rvd-reason" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "rvd-reason"
      .
    end.
    if v-mi-dnst = ? then v-mi-dnst = 0 . 
    if v-mi-lvl = ? then v-mi-lvl = 0 . 
    if v-mi-tmp = ? then v-mi-tmp = 0 . 
    if place-SI = ? then place-SI = 0 .
    if pl-dens-sr-izm = ? then pl-dens-sr-izm = 0 .
    if pl-level-sr-izm = ? then pl-level-sr-izm = 0 .
    if pl-temp-sr-izm = ? then pl-temp-sr-izm = 0 .
    rvs-line-attr.attr-value = ("Установка РВД на объекте " +
                                  buf_rvs-doc.obj-type + string(buf_rvs-doc.obj-code) +
                                  " сверка " + buf_rvs-doc.rvs-code + " " +
                                  " рез. " + string(tt-rvs-line.pl-code) + ": " +
                                  "p,T,l" + ";" + 
                                  "yes" + ";" +
                                  v-rvd-reason + ";" +
                                  v-ITSM-num + ";" +
                                  v-oper-fio +
                                  {&delim-key} +
                                  buf_rvs-doc.obj-type + {&delim-cmd} +
                                  string(buf_rvs-doc.obj-code) + {&delim-cmd} +
                                  string(v-shift-date) + {&delim-cmd} +
                                  string(v-shift-num) + {&delim-cmd} +
                                  string(tt-rvs-line.pl-code) + {&delim-cmd} +
                                  "p,T,l" + {&delim-cmd} + 
                                  "yes" + {&delim-cmd} +
                                  v-rvd-reason + {&delim-cmd} +
                                  v-ITSM-num + {&delim-cmd} +
                                  v-oper-fio + {&delim-cmd} +
                                  string(yes) + {&delim-cmd} +
                                  string(yes) + {&delim-cmd} +
                                  string(yes) + {&delim-cmd} +
                                  string(buf_place.is-meas) + {&delim-cmd} +
                                  buf_rvs-doc.rvs-code + {&delim-cmd} + 
                                  string(place-SI) + {&delim-cmd} +
                                  string(place-SI) + {&delim-cmd} +
                                  string(pl-dens-sr-izm) + {&delim-cmd} +
                                  string(v-mi-dnst) + {&delim-cmd} +
                                  string(pl-level-sr-izm) + {&delim-cmd} +
                                  string(v-mi-lvl) + {&delim-cmd} +
                                  string(pl-temp-sr-izm) + {&delim-cmd} +
                                  string(v-mi-tmp) )
                                  .
                                                 
  end .

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
         and rvs-line-attr.attr-code = "temp-izm-vol" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "temp-izm-vol"
      rvs-line-attr.attr-value = string(tt-rvs-line.temp-izm-vol)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.temp-izm-vol) .
  end.
  
  if rdc-value = "pomi-rn"
  then do :
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "mi-lvl" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "mi-lvl"
        rvs-line-attr.attr-value = string(v-mi-lvl)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(v-mi-lvl) .
    end.
    
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "mi-dnst" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "mi-dnst"
        rvs-line-attr.attr-value = string(v-mi-dnst)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(v-mi-dnst) .
    end.
    
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "mi-tmp" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "mi-tmp"
        rvs-line-attr.attr-value = string(v-mi-tmp)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(v-mi-tmp) .
    end.
    
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "tank-cleaning" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "tank-cleaning"
        rvs-line-attr.attr-value = string(t-tank-cleaning)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(t-tank-cleaning) .
    end.
  end .
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "input-type-p" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "input-type-p"
    .
  end.
  if buf_rvs-line.density = ? or buf_rvs-line.density = 0
  then do :
    rvs-line-attr.attr-value = "р" .
  end.
  else do :
    if v-hand-input-dnst /* Плотность редактировалась */
    then do :
      if rvs-line-attr.attr-value = "а" then rvs-line-attr.attr-value = "ак" .
      if rvs-line-attr.attr-value = "ф" then rvs-line-attr.attr-value = "фк" .
    end.
    else do :
      find first olddens-rvs-line-attr no-lock
           where olddens-rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and olddens-rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and olddens-rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and olddens-rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and olddens-rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and olddens-rvs-line-attr.attr-code = "is-olddens" no-error.
      if available olddens-rvs-line-attr
      then do :
        v-is-olddens = logical(olddens-rvs-line-attr.attr-value) no-error.
        if error-status:error then v-is-olddens = no .
      end.
      else do :
        v-is-olddens = no .
      end.
      if v-is-olddens and 
      (rvs-line-attr.attr-value = "а" or rvs-line-attr.attr-value = "ф")
      then rvs-line-attr.attr-value = "п" .
    end.
  end.
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "input-type-t" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "input-type-t"
    .
  end.
  if buf_rvs-line.temperature = ?
  then do :
    rvs-line-attr.attr-value = "р" .
  end.
  else do :
    if v-hand-input-tmp /* Температура редактировалась */
    then do :
      if rvs-line-attr.attr-value = "а" then rvs-line-attr.attr-value = "ак" .
      if rvs-line-attr.attr-value = "ф" then rvs-line-attr.attr-value = "фк" .
    end.
    else do :
      find first olddens-rvs-line-attr no-lock
           where olddens-rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and olddens-rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and olddens-rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and olddens-rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and olddens-rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and olddens-rvs-line-attr.attr-code = "is-olddens" no-error.
      if available olddens-rvs-line-attr
      then do :
        v-is-olddens = logical(olddens-rvs-line-attr.attr-value) no-error.
        if error-status:error then v-is-olddens = no .
      end.
      else do :
        v-is-olddens = no .
      end.
      if v-is-olddens and 
      (rvs-line-attr.attr-value = "а" or rvs-line-attr.attr-value = "ф")
      then rvs-line-attr.attr-value = "п" .
    end.
  end.
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "input-type-l" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "input-type-l"
    .
  end.
  if buf_rvs-line.level-total = ?
  then do :
    rvs-line-attr.attr-value = "р" .
  end.
  else do :
    if v-hand-input-lvl /* Уровень редактировалась */
    then do :
      if rvs-line-attr.attr-value = "а" then rvs-line-attr.attr-value = "ак" .
      if rvs-line-attr.attr-value = "ф" then rvs-line-attr.attr-value = "фк" .
    end.
  end.
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "first-enter" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "first-enter"
      rvs-line-attr.attr-value = string(no) .
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(no) .
  end.

find first rvs-line-attr exclusive-lock
    where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
    and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
    and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
    and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
    and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
    and rvs-line-attr.attr-code = "delta-mass-qnty" no-error.
if available rvs-line-attr then
do :
    rvs-line-attr.attr-value = string(delta-mass-qnty)  .
end.
else
do :
    create rvs-line-attr.
    assign
        rvs-line-attr.obj-code   = tt-rvs-line.obj-code
        rvs-line-attr.obj-type   = tt-rvs-line.obj-type
        rvs-line-attr.gds-code   = tt-rvs-line.gds-code
        rvs-line-attr.pl-code    = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code   = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code  = "delta-mass-qnty"
        rvs-line-attr.attr-value = string( delta-mass-qnty)
        .
end.

find first rvs-line-attr exclusive-lock
    where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
    and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
    and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
    and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
    and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
    and rvs-line-attr.attr-code = "hand-save" no-error.
if available rvs-line-attr then
do :
    rvs-line-attr.attr-value = string(yes)  .
end.
else
do :
    create rvs-line-attr.
    assign
        rvs-line-attr.obj-code   = tt-rvs-line.obj-code
        rvs-line-attr.obj-type   = tt-rvs-line.obj-type
        rvs-line-attr.gds-code   = tt-rvs-line.gds-code
        rvs-line-attr.pl-code    = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code   = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code  = "hand-save"
        rvs-line-attr.attr-value = string(yes)
        .
end.

release rvs-line-attr no-error .


{ gbl/ptrlprop.i
  run
  tt-rvs-line.obj-type
  tt-rvs-line.obj-code
}

if buf_rvs-doc.rvs-type = {&rvs-before-doc}
then do :
if ptrlprop-calc-free-vol then do:

  define variable infoSectionsTotal as class ibs.th.str.InfoSectionsTotal no-undo.
  define variable iisec as integer no-undo .
  define variable v-doc-volume as decimal no-undo init 0.0 .
  define buffer buf_trn-doc for ub.trn-doc .
      
/*  find first buf_doc-pl no-lock where buf_doc-pl.obj-type   = tt-rvs-line.obj-type                                             */
/*                                  and buf_doc-pl.obj-code   = tt-rvs-line.obj-code                                             */
/*                                  and buf_doc-pl.gds-code   = tt-rvs-line.gds-code                                             */
/*                                  and buf_doc-pl.pl-code    = tt-rvs-line.pl-code                                              */
/*                                  and buf_doc-pl.out-code   = buf_rvs-doc.out-code                                             */
/*                                  no-error .                                                                                   */
/*  if not available buf_doc-pl                                                                                                  */
/*  then do :                                                                                                                    */
/*    message "В накладной для товара " string(tt-rvs-line.gds-code) " нет распределения по местам хранения!" view-as alert-box .*/
/*    return no-apply .                                                                                                          */
/*  end .                                                                                                                        */
  
  find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_rvs-doc.out-code no-error .
  
  find first buf_place no-lock where buf_place.obj-code = tt-rvs-line.obj-code
                                 and buf_place.obj-type = tt-rvs-line.obj-type
                                 and buf_place.pl-code  = tt-rvs-line.pl-code
                                 no-error.
           
  assign v-free-vol = 0.95 * buf_place.max-qnty - varstate-sum-vol .
  
  infoSectionsTotal = new ibs.th.str.InfoSectionsTotal(buf_trn-doc.doc-code, tt-rvs-line.gds-code, {&lookup}).
          
  sect_ :
  do iisec = 1 to infoSectionsTotal:SectionNum :
    infoSectionsTotal:GetInfoSectionProp (iisec).
    if infoSectionsTotal:InfoSectionCurr:ListTank <> buf_place.loc1
    then
      next sect_ .
    if v-sec-num <> ""
    and v-sec-num <> infoSectionsTotal:InfoSectionCurr:SectionName
    then
      next sect_ .
    
    if infoSectionsTotal:InfoSectionCurr:DocVolume > 0
    then do :
      v-doc-volume = v-doc-volume + infoSectionsTotal:InfoSectionCurr:DocVolume . 
    end .
    else do :
      v-doc-volume = v-doc-volume + infoSectionsTotal:InfoSectionCurr:DocQnty .
    end .
  end . 
  
  if v-doc-volume > 0
  then do :
    if v-free-vol >= v-doc-volume
    then do :
      find first buf_doc-pl-attr exclusive-lock
          where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
          and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
          and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
          and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
          and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
          and buf_doc-pl-attr.attr-code = "free-vol-exceed"
      no-error.
      if available buf_doc-pl-attr then
      do :
        buf_doc-pl-attr.attr-value = string(no)  .
      end.
      else
      do :
        create buf_doc-pl-attr.
        assign
          buf_doc-pl-attr.obj-code   = tt-rvs-line.obj-code
          buf_doc-pl-attr.obj-type   = tt-rvs-line.obj-type
          buf_doc-pl-attr.gds-code   = tt-rvs-line.gds-code
          buf_doc-pl-attr.pl-code    = tt-rvs-line.pl-code
          buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
          buf_doc-pl-attr.attr-code  = "free-vol-exceed"
          buf_doc-pl-attr.attr-value = string(no)
          .
      end.
    end .
    else 
    do :
      run ref/message_volue.w(input string(round(v-doc-volume, 0)),
        input buf_place.loc1,
        input string(round(v-free-vol, 0)),
        input true) no-error .
/*        message "Внимание! Объем нефтепродукта по ТТН " string(round(v-doc-volume, 0))                                                                 */
/*          "л превышает допустимое значение для слива в резервуар " buf_place.loc1 " - "                                                                */
/*          string(round(v-free-vol, 0)) "л." skip                                                                                                       */
/*          "Проверьте введенные данные из ТТН или значение фактического объема в резервуаре в сверке до слива"                                          */
/*          " и при необходимости проинформируйте ответственное лицо ОГ в соответствии со схемой оповещения. Если данные корректны, прием запрещен!" skip*/
/*          "ВНИМАНИЕ!!! Прием невозможен, недостаточно свободного объема резервуара!!!"                                                                 */
/*          view-as alert-box .                                                                                                                          */
      find first buf_doc-pl-attr exclusive-lock
        where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
        and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
        and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
        and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
        and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
        and buf_doc-pl-attr.attr-code = "free-vol-exceed" no-error.
      if available buf_doc-pl-attr then
      do :
        buf_doc-pl-attr.attr-value = string(yes)  .
      end.
      else
      do :
        create buf_doc-pl-attr.
        assign
          buf_doc-pl-attr.obj-code   = tt-rvs-line.obj-code
          buf_doc-pl-attr.obj-type   = tt-rvs-line.obj-type
          buf_doc-pl-attr.gds-code   = tt-rvs-line.gds-code
          buf_doc-pl-attr.pl-code    = tt-rvs-line.pl-code
          buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
          buf_doc-pl-attr.attr-code  = "free-vol-exceed"
          buf_doc-pl-attr.attr-value = string(yes)
          .
      end.       
    end .
  end .                            
end .
end.
  if buf_rvs-doc.rvs-type = {&rvs-after-doc} then 
  do:
    /*Для сверки после*/
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_rvs-doc.out-code no-error .
  
    find first buf_place no-lock where buf_place.obj-code = tt-rvs-line.obj-code
      and buf_place.obj-type = tt-rvs-line.obj-type
      and buf_place.pl-code  = tt-rvs-line.pl-code
      no-error.
           
    assign 
      v-free-vol = 0.95 * buf_place.max-qnty.
    v-doc-volume = tt-rvs-line.fact-sum-vol .
  
    if v-doc-volume > 0
      then 
    do :
      if v-free-vol >= v-doc-volume
        then 
      do :
        find first buf_doc-pl-attr exclusive-lock
          where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
          and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
          and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
          and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
          and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
          and buf_doc-pl-attr.attr-code = "free-vol-exceed-after" no-error.
        if available buf_doc-pl-attr then
        do :
          buf_doc-pl-attr.attr-value = string(no)  .
        end.
        else
        do :
          create buf_doc-pl-attr.
          assign
            buf_doc-pl-attr.obj-code   = tt-rvs-line.obj-code
            buf_doc-pl-attr.obj-type   = tt-rvs-line.obj-type
            buf_doc-pl-attr.gds-code   = tt-rvs-line.gds-code
            buf_doc-pl-attr.pl-code    = tt-rvs-line.pl-code
            buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
            buf_doc-pl-attr.attr-code  = "free-vol-exceed-after"
            buf_doc-pl-attr.attr-value = string(no)
            .
        end.
      end .
      else 
      do :
        find first buf_doc-pl-attr exclusive-lock
          where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
          and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
          and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
          and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
          and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
          and buf_doc-pl-attr.attr-code = "free-vol-exceed" 
          and buf_doc-pl-attr.attr-value = string(yes) no-error.
        if available (buf_doc-pl-attr) then 
        do:
/*      /*Проверка на права техподдержки*/*/
/*          { gbl/chk-actg.i              */
/*    v-cntxt-db-num                      */
/*    v-cntxt-userid                      */
/*    {&action-head-code-main}            */
/*    'actn_global-trn_update':U          */
/*    {&cntxt-global}                     */
/*    0                                   */
/*    '':U                                */
/*    0                                   */
/*    0                                   */
/*    0                                   */
/*    0                                   */
/*    false                               */
/*    g-log                               */
/*  }                                     */
/*          if not g-log then                                                                                                           */
/*          do:                                                                                                                         */
/*            message "Выполнен слив с превышением свободного объема резервуара. Недостаточно прав продолжения работы с накладной." skip*/
/*              "Проинформируйте ответственное лицо ОГ в соответствии с принятым в ОГ порядком оповещения."                             */
/*              view-as alert-box.                                                                                                      */
/*            apply "choose" to b-cancel in frame {&frame-name} .                                                                       */
/*          end.                                                                                                                        */
/*          else                                                                                                                        */
/*          do:                                                                                                                         */
/*            message "Выполнен слив с превышением свободного объема резервуара." skip                                                  */
/*              "Вы уверены, что хотите продолжить работу с накладной?"                                                                 */
/*              view-as alert-box question buttons yes-no update lChoice as logical .                                                   */
/*            if lChoice then                                                                                                           */
/*            do:                                                                                                                       */
              find first buf_doc-pl-attr exclusive-lock
                where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
                and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
                and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
                and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
                and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
                and buf_doc-pl-attr.attr-code = "free-vol-exceed-after" no-error.      
              if available (buf_doc-pl-attr) then               
                buf_doc-pl-attr.attr-value = string(yes)  .
              else
              do :
                create buf_doc-pl-attr.
                assign
                  buf_doc-pl-attr.obj-code   = tt-rvs-line.obj-code
                  buf_doc-pl-attr.obj-type   = tt-rvs-line.obj-type
                  buf_doc-pl-attr.gds-code   = tt-rvs-line.gds-code
                  buf_doc-pl-attr.pl-code    = tt-rvs-line.pl-code
                  buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
                  buf_doc-pl-attr.attr-code  = "free-vol-exceed-after"
                  buf_doc-pl-attr.attr-value = string(yes)
                  .        
              end.
/*            end.                                                 */
/*            else                                                 */
/*            do:                                                  */
/*              apply "choose" to b-cancel in frame {&frame-name} .*/
/*            end.                                                 */
/*          end.                                                   */
        end .        
        else 
        do:
          find first buf_doc-pl-attr exclusive-lock
            where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
            and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
            and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
            and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
            and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
            and buf_doc-pl-attr.attr-code = "free-vol-exceed-after" no-error.      
          if available (buf_doc-pl-attr) then               
            buf_doc-pl-attr.attr-value = string(yes)  .
          else
          do :
            create buf_doc-pl-attr.
            assign
              buf_doc-pl-attr.obj-code   = tt-rvs-line.obj-code
              buf_doc-pl-attr.obj-type   = tt-rvs-line.obj-type
              buf_doc-pl-attr.gds-code   = tt-rvs-line.gds-code
              buf_doc-pl-attr.pl-code    = tt-rvs-line.pl-code
              buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
              buf_doc-pl-attr.attr-code  = "free-vol-exceed-after"
              buf_doc-pl-attr.attr-value = string(yes)
              .        
          end.        
        end.
      end.
      
    end.  
  end.

  define variable v-mi-par-list as character no-undo .
  define variable v-mi-par-list-text as character no-undo .
  define variable v-mi-old-val-list as character no-undo .
  define variable v-mi-new-val-list as character no-undo .
  
  v-mi-par-list = "" .
  v-mi-old-val-list = "" .
  v-mi-new-val-list = "" .
  
  if rdc-value = "pomi-rn"
  then do :
    if v-dnst-mi-old = v-mi-dnst
    and v-lvl-mi-old = v-mi-lvl
    and v-tmp-mi-old = v-mi-tmp
    then do :
    end .
    else do :
      if v-dnst-mi-old <> v-mi-dnst
      then do :
        assign
          v-mi-par-list = v-mi-par-list + "p" + ","
          v-mi-old-val-list = v-mi-old-val-list + string(v-dnst-mi-old) + ","
          v-mi-new-val-list = v-mi-new-val-list + string(v-mi-dnst) + ","
        .
      end .
      if v-lvl-mi-old <> v-mi-lvl
      then do :
        assign
          v-mi-par-list = v-mi-par-list + "l" + ","
          v-mi-old-val-list = v-mi-old-val-list + string(v-lvl-mi-old) + ","
          v-mi-new-val-list = v-mi-new-val-list + string(v-mi-lvl) + ","
        .
      end .
      if v-tmp-mi-old <> v-mi-tmp
      then do :
        assign
          v-mi-par-list = v-mi-par-list + "t"
          v-mi-old-val-list = v-mi-old-val-list + string(v-tmp-mi-old)
          v-mi-new-val-list = v-mi-new-val-list + string(v-mi-tmp)
        .
      end .
      assign
        v-mi-par-list = trim(v-mi-par-list, ",")
        v-mi-old-val-list = trim(v-mi-old-val-list, ",")
        v-mi-new-val-list = trim(v-mi-new-val-list, ",")
        v-mi-par-list-text = v-mi-par-list
      .
      v-mi-par-list-text = replace(v-mi-par-list-text, "p", " плотность") .
      v-mi-par-list-text = replace(v-mi-par-list-text, "l", " уровень") .
      v-mi-par-list-text = replace(v-mi-par-list-text, "t", " температура") .
      
      run trg/userlog.p (
              input 'mi-change'
            , input ("Изменение средств измерений на объекте " +
                    buf_rvs-doc.obj-type + string(buf_rvs-doc.obj-code) +
                    "в сверке " + string(buf_rvs-doc.rvs-code) + 
                    " рез. " + string(tt-rvs-line.pl-code) + ": " +
                    v-mi-par-list + ";" + 
                    v-mi-old-val-list + ";" +
                    v-mi-new-val-list +
                    {&delim-key} +
                    buf_rvs-doc.obj-type + {&delim-cmd} +
                    string(buf_rvs-doc.obj-code) + {&delim-cmd} +
                    string(v-shift-date) + {&delim-cmd} +
                    string(v-shift-num) + {&delim-cmd} +
                    string(tt-rvs-line.pl-code) + {&delim-cmd} +
                    v-mi-par-list + {&delim-cmd} + 
                    v-mi-old-val-list + {&delim-cmd} +
                    v-mi-new-val-list + {&delim-cmd} +
                    string(buf_rvs-doc.rvs-code)   )
            , input ?
            , input ?
            , input ""
            ) no-error.
      if error-status :error
      then do:
          message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
      end.
      
      define variable v-log as logical no-undo .
      find first buf_place no-lock
           where buf_place.obj-code = tt-rvs-line.obj-code
             and buf_place.obj-type = tt-rvs-line.obj-type
             and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
      message
        "Для параметра/ов" v-mi-par-list-text " изменены дополнительные средства измерения. Сохранить выбранные средства измерения"
        v-mi-par-list-text " в качестве средств измерения по умолчанию для резервуара " buf_place.loc1 " " buf_place.pl-name "?"
      view-as alert-box question buttons yes-no update v-log .
      if v-log
      then do :
        if v-dnst-mi-old <> v-mi-dnst
        then do :
          run placelib_write-attr  ( input {&place-SI-dens}
                                    ,input buf_place.obj-code
                                    ,input buf_place.obj-type
                                    ,input buf_place.pl-code
                                    ,input string(v-mi-dnst)
                                    ,output v-ok      ) no-error.
        end .
        if v-lvl-mi-old <> v-mi-lvl
        then do :
          run placelib_write-attr  ( input {&place-SI-level}
                                    ,input buf_place.obj-code
                                    ,input buf_place.obj-type
                                    ,input buf_place.pl-code
                                    ,input string(v-mi-lvl)
                                    ,output v-ok      ) no-error.
        end .
        if v-tmp-mi-old <> v-mi-tmp
        then do :
          run placelib_write-attr  ( input {&place-SI-temp}
                                    ,input buf_place.obj-code
                                    ,input buf_place.obj-type
                                    ,input buf_place.pl-code
                                    ,input string(v-mi-tmp)
                                    ,output v-ok      ) no-error.
        end .
      end .
    end . 
  end .

  v-vid-action = 56 .
  v-vid-param = 
          "Initiator=" + v-initiator + {&delim-par} +
          "SHOP_NUM=" + string(buf_rvs-doc.obj-code) + {&delim-par} +
          "DocType=" + string(buf_rvs-doc.rvs-type) + {&delim-par} +
          "DocNum=" + string(buf_rvs-doc.rvs-code) + {&delim-par} +
/*            "ShiftNum=" + string(bf_rvs-doc.shift-num) + {&delim-par} +  */
/*            "ShiftDate=" + string(bf_rvs-doc.shift-date) + {&delim-par} +*/
          "SHIFT_NUM_DOC=" + (if string(buf_rvs-doc.shift-num) = ? then '' else string(buf_rvs-doc.shift-num)) + (if string(buf_rvs-doc.shift-date) = ? then '' else string(buf_rvs-doc.shift-date, "99999999")) + {&delim-par} +  
          "SHIFT_NUM=" + (if string(v-shift-num) = ? then '' else string(v-shift-num)) + (if string(v-shift-date) = ? then '' else string(v-shift-date, "99999999")) + {&delim-par} +

          
          "PlCode=" + string( tt-rvs-line.pl-code) + {&delim-par} +
          "RESULT=0" + {&delim-par} +
/*            "Density=" + string(  tt-rvs-line.density ) + {&delim-par} +*/
          "Temperature=" +  (if string(tt-rvs-line.state-temperature) = ? then '' else string(tt-rvs-line.state-temperature)) + {&delim-par} +
          
          "StateDensity="        +  (if string(tt-rvs-line.state-density) = ? then '' else string(tt-rvs-line.state-density)) + {&delim-par} +
          
          "StateMeasureQnty="    +  (if string( tt-rvs-line.state-measure-qnty) = ? then '' else string( tt-rvs-line.state-measure-qnty)) + {&delim-par} +
          "StateBruttoQnty="  +  (if string(  tt-rvs-line.state-brutto-qnty) = ? then '' else string(  tt-rvs-line.state-brutto-qnty)) + {&delim-par} +

          "StateMeasureCliQnty=" +  (if string(  tt-rvs-line.state-measure-cli-qnty) = ? then '' else string(  tt-rvs-line.state-measure-cli-qnty)) + {&delim-par} +

          "StateBruttoCliQnty=" +  (if string(  tt-rvs-line.state-brutto-cli-qnty) = ? then '' else string(   tt-rvs-line.state-brutto-cli-qnty)) + {&delim-par} +

          "StateLevelTotal="  +  (if string(  tt-rvs-line.state-level-total) = ? then '' else string(  tt-rvs-line.state-level-total)) + {&delim-par} +
          "StateLevelPetrol=" +  (if string(  tt-rvs-line.state-level-petrol) = ? then '' else string( tt-rvs-line.state-level-petrol)) + {&delim-par} +

          "StateLevelWater=" +  (if string(  tt-rvs-line.state-level-water) = ? then '' else string(  tt-rvs-line.state-level-water)) + {&delim-par} +
          
          "StateMeasureTcQnty="  +  (if string(  tt-rvs-line.state-measure-tc-qnty  ) = ? then '' else string(   tt-rvs-line.state-measure-tc-qnty  )) + {&delim-par} + 
          "StateBruttoTcQnty="  +  (if string(  tt-rvs-line.state-brutto-tc-qnty  ) = ? then '' else string(    tt-rvs-line.state-brutto-tc-qnty  )) + {&delim-par} + 
                      
          "Description=".
            
  run trg/userlog.p (
      input {&nwsdochs_action_create}
      , input {&table_rvs-doc}
      , input ( buffer buf_rvs-doc:handle )
      , input v-vid-action
      , input v-vid-param
      ) no-error.
  if error-status :error
  then do:
    message substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ) 
            view-as alert-box.
    return no-apply.
  end.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-add-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-add-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-add-qnty IN FRAME Dialog-Frame /* Факт в трубопроводе */
DO:
  assign frame {&frame-name} {&self-name}.
  assign tt-rvs-line.fact-sum-vol = tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty .
  display tt-rvs-line.fact-sum-vol with frame {&frame-name} .
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


/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-brutto-tc-qnty Dialog-Frame  */
/*ON return OF tt-rvs-line.state-brutto-tc-qnty IN FRAME Dialog-Frame /* Факт брутто(tc) */*/
/*DO:                                                                                      */
/*  apply "entry" to tt-rvs-line.state-brutto-cli-qnty in frame {&frame-name}.             */
/*  return no-apply.                                                                       */
/*END.                                                                                     */
/*                                                                                         */
/*/* _UIB-CODE-BLOCK-END */                                                                */
/*&ANALYZE-RESUME                                                                          */


&Scoped-define SELF-NAME tt-rvs-line.state-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-density Dialog-Frame
ON LEAVE OF tt-rvs-line.state-density IN FRAME Dialog-Frame /* Плотность */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name}
  then do:
    assign frame {&frame-name} tt-rvs-line.state-density.
    run chg-density no-error.
    if error-status:error then return no-apply.
    run weath-water no-error.
    if error-status:error then return no-apply.
    if tarir-value = 'yes'
    then do :
      run local-tarir("state-level-total") .
    end.
    assign v-hand-input-dnst = true .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME varstate-water-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varstate-water-qnty Dialog-Frame
ON LEAVE OF varstate-water-qnty IN FRAME Dialog-Frame /* Плотность */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name}
  then do:
    assign varstate-sum-vol = input frame {&frame-name} tt-rvs-line.state-measure-qnty + input frame {&frame-name} {&self-name} .
    display varstate-sum-vol with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-rvs-line.state-measure-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame /* Объем НП */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name}
  then do:
    assign frame {&frame-name} {&self-name} .
    tt-rvs-line.fact-sum-vol = input frame {&frame-name} {&self-name} + input frame {&frame-name} tt-rvs-line.state-add-qnty .
    varstate-sum-vol = input frame {&frame-name} {&self-name} + (if input frame {&frame-name} varstate-water-qnty = ? then 0 else input frame {&frame-name} varstate-water-qnty) .
    tt-rvs-line.state-brutto-qnty = varstate-sum-vol .
    display tt-rvs-line.fact-sum-vol varstate-sum-vol with frame {&frame-name}.
    run volume-water no-error.
    if error-status:error then return no-apply.
    if tt-rvs-line.state-density <> 0 
    and tt-rvs-line.state-density <> ?
    then do:
      run chg-density no-error.
      if error-status:error then return no-apply.
      run weath-water no-error.
      if error-status:error then return no-apply.
    end.
    tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty .
    abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 no-error .
    display tt-rvs-line.fact-sum-mass tt-rvs-line.state-measure-qnty abs-delta-mass-add-qnty with frame {&frame-name}.
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
  if input frame {&frame-name} {&self-name} <> {&self-name}
  then do:
    if input frame {&frame-name} tt-rvs-line.izmer-density = ?
    or ( buf_goods.unit-base <> buf_goods.unit-cli
        and ( input frame {&frame-name} tt-rvs-line.izmer-density < 0
              or input frame {&frame-name} tt-rvs-line.izmer-density >= 1
            )
      )
    or ( buf_goods.unit-base = buf_goods.unit-cli
        and input frame {&frame-name} tt-rvs-line.izmer-density <> 1
      )
    then do:
      message "Неверно определена плотность топлива измер. для ПОкМИ." view-as alert-box error.
      apply "entry" to tt-rvs-line.izmer-density .
      return no-apply.
    end.

    assign frame {&frame-name} tt-rvs-line.izmer-density.
    
    assign v-hand-input-dnst = true .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-level-water
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-level-water Dialog-Frame
ON LEAVE OF tt-rvs-line.state-level-water IN FRAME Dialog-Frame /* Факт уровень топлива */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name}
  then do:
    assign v-hand-input-lvl = true .
    
    find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "is-calc" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = string(no) .
    end .
    
    run level-water in this-procedure ( input no ) /* no-error */ .
      
    RUN local-tarir ("state-level-total").
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
  if input frame {&frame-name} tt-rvs-line.state-level-total <> ?
  and input frame {&frame-name} tt-rvs-line.state-level-total > 0
  then do :
    if (pl-rvd-temp or v-revision-mode)
    and rdc-value = "pomi-rn"
    then do :
      if v-revision-mode
      and v-mi-lvl > 0
      and v-mi-dnst > 0
      and v-mi-tmp > 0
      then
        enable b-temperature with frame {&frame-name}. 
      if not v-revision-mode
      and v-mi-tmp > 0
      then
        enable b-temperature with frame {&frame-name}.
    end .
    if (pl-rvd-dens or v-revision-mode)
    and rdc-value = "pomi-rn"
    then do :
      if v-revision-mode
      and v-mi-lvl > 0
      and v-mi-dnst > 0
      and v-mi-tmp > 0
      then
        enable b-density with frame {&frame-name}. 
      if not v-revision-mode
      and v-mi-dnst > 0
      then
        enable b-density with frame {&frame-name}. 
    end .
    
    if ((pl-rvd-dens and pl-rvd-temp)
     or v-revision-mode)
    and v-mi-dnst > 0
    and v-mi-tmp > 0
    and rdc-value = "pomi-rn"
    then do :
      find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst no-error .
      find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp no-error .
      if available dnst_sr-izmerenia
      and available tmp_sr-izmerenia
      and dnst_sr-izmerenia.node-code <> tmp_sr-izmerenia.node-code
      and ((dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
        or (tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature))
      then do :
        disable b-temperature with frame {&frame-name} .
        disable b-density with frame {&frame-name} .
      end .
    end .
    if v-revision-mode
    and t-tank-cleaning:visible
    then do :
      if input frame {&frame-name} tt-rvs-line.state-level-total < 1
      then do :
        enable t-tank-cleaning with frame {&frame-name} .
      end .
      else do :
        assign t-tank-cleaning = no .
        display t-tank-cleaning with frame {&frame-name} .
        disable t-tank-cleaning with frame {&frame-name} .
      end .
    end .
  end .
  else do :
    disable b-temperature with frame {&frame-name} .
    disable b-density with frame {&frame-name} .
    
    if v-revision-mode
    and t-tank-cleaning:visible
    then do :
      assign t-tank-cleaning = no .
      display t-tank-cleaning with frame {&frame-name} .
      disable t-tank-cleaning with frame {&frame-name} .
    end .
  end .
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    assign v-hand-input-lvl = true .
    empty temp-table tt-temps .
    empty temp-table tt-dens .
    empty temp-table tt-dens-temp .
    
    find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = "0;" .
    end .
    
    find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-denses" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = "0;" .
    end .
    
    find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "is-calc" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = string(no) .
    end .
    
    run level-water in this-procedure ( input no ) /* no-error */ .
      
    RUN local-tarir ("state-level-total").
    /* if error-status :error then do: return no-apply. end. */
  end.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-level-total Dialog-Frame
ON return OF tt-rvs-line.state-level-total IN FRAME Dialog-Frame /* Факт общий уровень */
DO:
/*  apply "entry" to tt-rvs-line.state-temperature in frame {&frame-name}.*/
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rvs-line.state-measure-cli-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-cli-qnty Dialog-Frame
ON leave OF tt-rvs-line.state-measure-cli-qnty IN FRAME Dialog-Frame /* Факт вес */
DO:
  assign frame {&frame-name} tt-rvs-line.state-measure-cli-qnty .
  if not tt-rvs-line.state-measure-qnty:sensitive
  and rdc-value <> 'pomi-rn'
  then do :
    assign
      tt-rvs-line.state-measure-qnty = tt-rvs-line.state-measure-cli-qnty / tt-rvs-line.state-density
      varstate-sum-vol = (if varstate-water-qnty <> ? then varstate-water-qnty else 0) + tt-rvs-line.state-measure-qnty
      tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty
      tt-rvs-line.state-brutto-qnty     = tt-rvs-line.state-measure-qnty + (if varstate-water-qnty <> ? then varstate-water-qnty else 0)
      tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty + (if varstate-water-qnty <> ? then varstate-water-qnty else 0)
    .
    display tt-rvs-line.state-measure-cli-qnty tt-rvs-line.state-measure-qnty tt-rvs-line.fact-sum-mass varstate-sum-vol with frame {&frame-name}.
  end .
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
/*  apply "entry" to tt-rvs-line.state-temp-layer1 in frame {&frame-name}.*/
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

  if parmode = {&update} then do:
    find first buf_rvs-line exclusive-lock
      where recid(buf_rvs-line) = parrec-rvs-line
      no-error.
  end.
  else do:
    find first buf_rvs-line no-lock
      where recid(buf_rvs-line) = parrec-rvs-line
      no-error.
  end.
  if not available buf_rvs-line then do:
     message "Неверно переданы параметры."
             "Не найдена строка сверки с recid " parrec-rvs-line " ."
     view-as alert-box error.
     return error.
  end.
  create tt-rvs-line.
  buffer-copy buf_rvs-line to tt-rvs-line.
  
  if parmode = {&update} then do:
  find first buf_rvs-doc exclusive-lock
    where buf_rvs-doc.rvs-code = tt-rvs-line.rvs-code
    .
  end.
  else do:
  find first buf_rvs-doc no-lock
    where buf_rvs-doc.rvs-code = tt-rvs-line.rvs-code
    .
  end.

    
  RUN enable_UI IN THIS-PROCEDURE.
  
  if num-entries(buf_rvs-doc.rvs-code, "-") = 3
  then do :
    v-sec-num = entry(2, buf_rvs-doc.rvs-code, "-") .
    display v-sec-num with frame Dialog-Frame.
  end .
  else do :
    hide v-sec-num in frame Dialog-Frame.
  end .

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
  
  run placelib_get-attr  ( input {&place-type}
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if v-ok then place-type = integer(v-value) .
  
  run placelib_get-attr  ( input {&place-rvd-dnsty}
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok then pl-rvd-dens = no.
  else pl-rvd-dens = logical(v-value) .
  
  run placelib_get-attr  ( input {&place-rvd-lvl}
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok then pl-rvd-lvl = no.
  else pl-rvd-lvl = logical(v-value) .
  
  run placelib_get-attr  ( input {&place-rvd-tmp}
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok then pl-rvd-temp = no.
  else pl-rvd-temp = logical(v-value) .

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
      case buf_rvs-doc.rvs-type:
        when {&rvs-before-doc} or when {&rvs-after-doc} then
        do: 
          if available buf2_place then
          do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_rvs-control_upd-revision':U
              {&cntxt-object}
              buf_rvs-doc.host-code
              buf_rvs-doc.obj-type
              buf_rvs-doc.obj-code
              0
              0
              0
              false
              g-log2
            }
            if g-log2
            then do :
              v-revision-mode = yes .
            end .
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_rvs-on-doc_upd-revision':U
              {&cntxt-object}
              buf_rvs-doc.host-code
              buf_rvs-doc.obj-type
              buf_rvs-doc.obj-code
              0
              0
              0
              false
              g-log
            }
            if g-log
            then do :
/*              v-revision-mode = yes .*/
            end .
            else do :
              if buf2_place.is-meas
              and not pl-rvd-dens
              and not pl-rvd-lvl
              and not pl-rvd-temp
              then do :
              end .
              else do :
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_rvs-control_upd-immeas':U
                  {&cntxt-object}
                  buf_rvs-doc.host-code
                  buf_rvs-doc.obj-type
                  buf_rvs-doc.obj-code
                  0
                  0
                  0
                  false
                  g-log
                } 
              end .
            end .
          end.
        end.
        when {&rvs-shift}
        then do:
            if available buf2_place then do :  
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-shift_upd-revision':U
                {&cntxt-object}
                buf_rvs-doc.host-code
                buf_rvs-doc.obj-type
                buf_rvs-doc.obj-code
                0
                0
                0
                false
                g-log
              }
              if g-log
              then do :
                v-revision-mode = yes .
              end .
              else do :
                if buf2_place.is-meas
                and not pl-rvd-dens
                and not pl-rvd-lvl
                and not pl-rvd-temp
                then do :
                end.
                else do :
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_rvs-shift_upd-immeas':U
                    {&cntxt-object}
                    buf_rvs-doc.host-code
                    buf_rvs-doc.obj-type
                    buf_rvs-doc.obj-code
                    0
                    0
                    0
                    false
                    g-log
                  } 
                end.
              end . 
            end.        
        end.
        when {&rvs-control}
        then do:
            if available buf2_place then do :  
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-control_upd-revision':U
                {&cntxt-object}
                buf_rvs-doc.host-code
                buf_rvs-doc.obj-type
                buf_rvs-doc.obj-code
                0
                0
                0
                false
                g-log
              }
              if g-log
              then do :
                v-revision-mode = yes .
              end .
              else do :
                if buf2_place.is-meas
                and not pl-rvd-dens
                and not pl-rvd-lvl
                and not pl-rvd-temp
                then do :
                end.
                else do :
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_rvs-control_upd-immeas':U
                    {&cntxt-object}
                    buf_rvs-doc.host-code
                    buf_rvs-doc.obj-type
                    buf_rvs-doc.obj-code
                    0
                    0
                    0
                    false
                    g-log
                  } 
                end.
              end .
            end.         
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип сверки" skip
            "Тип документа" buf_rvs-doc.rvs-type skip
            "Код документа" buf_rvs-doc.rvs-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
     if not g-log then do:
        message "Недостаточно прав для редактирования!" view-as alert-box error .
        undo, return error.
     end.
  end.
  
  if buf_rvs-doc.rvs-type = {&rvs-control}
  and buf_rvs-doc.status_ = {&permitted}
  then do :
    find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
            and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
            and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
            and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
            and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
            and rvs-line-attr.attr-code = "tank-cleaning" no-error.
    if available rvs-line-attr
    then do :
      t-tank-cleaning = logical(rvs-line-attr.attr-value) .
    end .
    
    display
      t-tank-cleaning
      t-tank-cleaning-text1
      t-tank-cleaning-text2
    with frame {&frame-name} .
    if v-revision-mode
    and tt-rvs-line.state-level-total > 0 
    and tt-rvs-line.state-level-total < 1
    and parmode = {&update}
    then do :
      enable t-tank-cleaning with frame {&frame-name} .
    end .
  end .
  else do :
    hide
      t-tank-cleaning
      t-tank-cleaning-text1
      t-tank-cleaning-text2
    in frame {&frame-name} .
  end .
  
  run placelib_get-attr  ( input {&place-SI}
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then place-si = integer(v-value) .
  else place-si = ? .
  
  run placelib_get-attr  ( input {&place-SI-temp}
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then pl-temp-sr-izm = integer(v-value) .
  else pl-temp-sr-izm = ? .
  
  run placelib_get-attr  ( input {&place-SI-dens}
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then pl-dens-sr-izm = integer(v-value) .
  else pl-dens-sr-izm = ? .
  
  run placelib_get-attr  ( input {&place-SI-level}
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then pl-level-sr-izm = integer(v-value) .
  else pl-level-sr-izm = ? .
  
  if parmode <> {&update} then do:
    disable b-save with frame {&frame-name}.
  end.
  else do :
    if pl-rvd-dens <> pl-rvd-temp
    then do :
      find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = pl-temp-sr-izm no-error .
      find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = pl-dens-sr-izm no-error .
      if (available tmp_sr-izmerenia and tmp_sr-izmerenia.sr-type-izm = 0 and tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature)
      or (available dnst_sr-izmerenia and dnst_sr-izmerenia.sr-type-izm = 0 and dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
      then do :
        message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, "
                "если дополнительное автоматизированное СИ предназначено для измерения обоих параметров." skip
                "Подайте заявку в службу поддержки для приведения параметров в соответствие требованиям бизнес-процесса."
        view-as alert-box .
      end .
    end .
  end .
  
  RUN gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", NO, OUTPUT rdc-value, OUTPUT rdc-type) NO-ERROR.
      
  run gbl/conf-rd.p ("tarir", "", "", 0, "", "", "", no, output tarir-value, output tarir-type) no-error.
      
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
      
  hide
    tt-rvs-line.meas-am-qnty
    tt-rvs-line.meas-cf-qnty
    tt-rvs-line.meas-mh-qnty
    tt-rvs-line.level-petrol
    tt-rvs-line.state-level-petrol
    tt-rvs-line.brutto-cli-qnty
    tt-rvs-line.state-brutto-cli-qnty
    tt-rvs-line.meas-cli-calc-qnty
    varmeasure-water-cli-qnty
    varstate-water-cli-qnty
    tt-rvs-line.brutto-tc-qnty
    tt-rvs-line.state-brutto-tc-qnty
    tt-rvs-line.brutto-qnty
    tt-rvs-line.state-brutto-qnty
    tt-rvs-line.meas-calc-dens
    tt-rvs-line.measure-tc-qnty
    tt-rvs-line.state-measure-tc-qnty
    tt-rvs-line.measure-qnty
    tt-rvs-line.state-measure-qnty
    tt-rvs-line.meas-calc-qnty
  in frame Dialog-Frame.
  
  if rdc-value <>  "pomi-rn" then do :
    hide
      tt-rvs-line.izmer-density
      delta-mass-qnty
      abs-delta-mass-qnty
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
  end.

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
          when "temp-izm-vol" then do :
            tt-rvs-line.temp-izm-vol = decimal(rvs-line-attr.attr-value) .
          end.
          when "delta-mass-qnty" then do :
            delta-mass-qnty = decimal(rvs-line-attr.attr-value) .
          end.
          when "CriticalDif" then do :
            CriticalDif = decimal(rvs-line-attr.attr-value) .
          end.
        end case.
  end.
  release rvs-line-attr no-error .
  if rdc-value =  "pomi-rn" then do :
    display
      tt-rvs-line.izmer-density
      delta-mass-qnty
    with frame {&frame-name}.
  end.
  display
    CriticalDif
  with frame {&frame-name}.
  
  find first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "first-enter" no-error.
  if available rvs-line-attr
  then do :
    v-first-enter = logical(rvs-line-attr.attr-value) .
  end .
  else do :
    v-first-enter = yes .
  end .
   
  
  run placelib_get-attr  ( input {&place-asi-sertif}
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok
  then pl-asi-sertif = no.
  else
  if v-value > ""
  then pl-asi-sertif = logical(v-value) .
  else pl-asi-sertif = no.
  
  
  run placelib_get-attr  ( input {&place-diameter}
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then place-diameter = decimal(v-value) .
  else place-diameter = ? . 
  
  if rdc-value =  "pomi-rn"
  then do :
    define buffer dop_sr-izmerenia for sr-izmerenia .
    
    find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
            and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
            and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
            and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
            and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
            and rvs-line-attr.attr-code = "mi-lvl" no-error.
    if available rvs-line-attr
    then do :
      v-mi-lvl = integer(rvs-line-attr.attr-value) .
    end .
    else do :
      v-mi-lvl = pl-level-sr-izm .
    end .
    for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-lvl :
      v-mi-lvl-name = dop_sr-izmerenia.sr-model .
      display v-mi-lvl-name with frame {&frame-name}.
    end .
    if parmode = {&update} then enable v-mi-lvl-name with frame {&frame-name}.
    if v-mi-lvl = 0 then v-mi-lvl = ? .
    
    find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
            and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
            and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
            and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
            and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
            and rvs-line-attr.attr-code = "mi-dnst" no-error.
    if available rvs-line-attr
    then do :
      v-mi-dnst = integer(rvs-line-attr.attr-value) .
    end .
    else do :
      v-mi-dnst = pl-dens-sr-izm .
    end .
    for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-dnst :
      v-mi-dnst-name = dop_sr-izmerenia.sr-model .
      display v-mi-dnst-name with frame {&frame-name}.
    end .
    if parmode = {&update} then enable v-mi-dnst-name with frame {&frame-name}.
    if v-mi-dnst = 0 then v-mi-dnst = ? .
    
    find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
            and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
            and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
            and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
            and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
            and rvs-line-attr.attr-code = "mi-tmp" no-error.
    if available rvs-line-attr
    then do :
      v-mi-tmp = integer(rvs-line-attr.attr-value) .
    end .
    else do :
      v-mi-tmp = pl-temp-sr-izm .
    end .
    for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-tmp :
      v-mi-tmp-name = dop_sr-izmerenia.sr-model .
      display v-mi-tmp-name with frame {&frame-name}.
    end .
    if parmode = {&update} then enable v-mi-tmp-name with frame {&frame-name}.
    if v-mi-tmp = 0 then v-mi-tmp = ? .
    
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "mi-tmp-dnst"
                                      :
      v-mi-tmp-dnst = integer(rvs-line-attr.attr-value) .                                  
    end .
        
    assign
      v-dnst-mi-old = v-mi-dnst
      v-tmp-mi-old  = v-mi-tmp 
      v-lvl-mi-old  = v-mi-lvl 
    .
  end .
  
  run placelib_get-attr  ( input {&place-error-mass}
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok then pl-error-mass = ?.
  else pl-error-mass = decimal(v-value) .
  
  assign
    tt-rvs-line.calc-add-mass = tt-rvs-line.add-qnty * input frame {&frame-name} tt-rvs-line.density 
    tt-rvs-line.sum-vol = tt-rvs-line.measure-qnty + tt-rvs-line.add-qnty 
    tt-rvs-line.sum-mass = tt-rvs-line.calc-add-mass + tt-rvs-line.measure-cli-qnty 
    varsum-vol = tt-rvs-line.brutto-qnty
    
    tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty * input frame {&frame-name} tt-rvs-line.state-density 
    tt-rvs-line.fact-sum-vol = tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty 
    tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty 
    varstate-sum-vol = tt-rvs-line.state-brutto-qnty 
  .
  
/*  if tt-rvs-line.state-measure-qnty = ? then tt-rvs-line.state-measure-qnty = tt-rvs-line.fact-calc-vol .*/
  
  abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 .
  abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
  
  display
    tt-rvs-line.calc-add-mass
    tt-rvs-line.measure-qnty
    tt-rvs-line.sum-vol
    tt-rvs-line.sum-mass
    varsum-vol
    
    tt-rvs-line.fact-calc-add-mass
    tt-rvs-line.state-measure-qnty
    tt-rvs-line.fact-sum-vol
    tt-rvs-line.fact-sum-mass
    varstate-sum-vol
    
    abs-delta-mass-add-qnty
    
    tt-rvs-line.temp-izm-vol
  with frame {&frame-name}.
  
  if rdc-value = 'pomi-rn'
  then do :
    display
      abs-delta-mass-qnty
    with frame {&frame-name}.
  end.
  else
  if tt-rvs-line.density = ? and parmode = {&update} and tarir-value <> "yes"
  then do :
    enable
      tt-rvs-line.state-measure-qnty
      varstate-water-qnty
    with frame Dialog-Frame.
  end.
                        
  if parmode <> {&update} then do:
    disable tt-rvs-line.izmer-density with frame {&frame-name}.
    disable tt-rvs-line.temp-izm-vol with frame {&frame-name}.
/*    disable mass-float-cov with frame {&frame-name}.*/
    disable b-calc b-temperature b-density with frame {&frame-name}.
    if rdc-value =  "pomi-rn"
    then do :
      hide
        hide-text-dop-si
      in frame Dialog-Frame. 
    end .
    else do :
      hide
        v-mi-lvl b-mi-lvl v-mi-lvl-name
        v-mi-dnst b-mi-dnst v-mi-dnst-name
        v-mi-tmp b-mi-tmp v-mi-tmp-name
      in frame Dialog-Frame.
      display
        hide-text-dop-si
      with frame Dialog-Frame.
    end .
  end.
  else do :
    disable
      tt-rvs-line.izmer-density
      tt-rvs-line.state-temperature
      tt-rvs-line.state-density
    with frame {&frame-name}.
    if pl-rvd-dens and rdc-value = 'pomi-rn'
    then do :
      if v-first-enter
      then do :
        tt-rvs-line.izmer-density = 0 .
        tt-rvs-line.state-density = 0 .
/*        tt-rvs-line.state-temperature = ? .*/
        display tt-rvs-line.izmer-density tt-rvs-line.state-density with frame {&frame-name}.
      end .
      if not v-revision-mode
      and v-mi-dnst > 0
      and tt-rvs-line.state-level-total > 0
      then
        enable b-density with frame {&frame-name}.
    end.
    else do :
      if tt-rvs-line.state-level-total = 0
      or tt-rvs-line.state-level-total = ?
      then
        disable b-density with frame {&frame-name}.
    end.
    if pl-rvd-dens and rdc-value <> 'pomi-rn'
    and tt-rvs-line.state-level-total > 0
    then do :
      enable tt-rvs-line.state-density with frame {&frame-name}.
    end.
    else do :
      disable tt-rvs-line.state-density with frame {&frame-name}.
    end.
    if pl-rvd-lvl
    then do :
      if rdc-value =  "pomi-rn"
      then do :
        if v-first-enter
        then do :
          tt-rvs-line.state-level-total = 0 .
          tt-rvs-line.state-level-water = 0 .
          display tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame {&frame-name}.
        end .
        if not v-revision-mode
        and v-mi-lvl > 0
        then
          enable tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame {&frame-name}.
      end .
      else do :
        enable tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame {&frame-name}.
      end .
    end.
    else do :
      disable tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame {&frame-name}.
    end.
    if (pl-rvd-temp or tt-rvs-line.density = ?)
    then do :
      if rdc-value =  "pomi-rn"
      then do :
        if v-first-enter
        then do :
          tt-rvs-line.temp-izm-vol = ? .
          tt-rvs-line.state-temperature = ? .
          display tt-rvs-line.temp-izm-vol tt-rvs-line.state-temperature with frame {&frame-name}.
        end .
        if not v-revision-mode
        and v-mi-tmp > 0
        and tt-rvs-line.state-level-total > 0
        then
          enable b-temperature with frame {&frame-name}.
      end .
    end.
    else do :
      if tt-rvs-line.state-level-total = 0
      or tt-rvs-line.state-level-total = ?
      then
        disable b-temperature with frame {&frame-name}.
    end.
    if rdc-value =  "pomi-rn"
    then do :
      enable
        v-mi-lvl b-mi-lvl v-mi-lvl-name
        v-mi-dnst b-mi-dnst v-mi-dnst-name
        v-mi-tmp b-mi-tmp v-mi-tmp-name
      with frame Dialog-Frame.
      hide
        hide-text-dop-si
      in frame Dialog-Frame. 
      
      tt-rvs-line.izmer-density:fgcolor = RED_COLOR .
      tt-rvs-line.state-level-total:fgcolor = RED_COLOR .
      tt-rvs-line.state-level-water:fgcolor = RED_COLOR .
      tt-rvs-line.state-temperature:fgcolor = RED_COLOR .
      tt-rvs-line.temp-izm-vol:fgcolor = RED_COLOR .
    end .
    else do :
      hide
        v-mi-lvl b-mi-lvl v-mi-lvl-name
        v-mi-dnst b-mi-dnst v-mi-dnst-name
        v-mi-tmp b-mi-tmp v-mi-tmp-name
      in frame Dialog-Frame.
      display
        hide-text-dop-si
      with frame Dialog-Frame.
    end .
  end.
  
  if v-revision-mode
  and v-first-enter
  and rdc-value =  "pomi-rn"
  then do :
    assign
      tt-rvs-line.state-level-total = 0
      tt-rvs-line.state-level-water = 0
      tt-rvs-line.temp-izm-vol = ?
      tt-rvs-line.izmer-density = 0
      tt-rvs-line.state-density = 0
      tt-rvs-line.state-temperature = ?
    .
    display
      tt-rvs-line.state-level-total
      tt-rvs-line.state-level-water
      tt-rvs-line.temp-izm-vol
      tt-rvs-line.izmer-density
      tt-rvs-line.state-density
      tt-rvs-line.state-temperature
    with frame {&frame-name}.
    disable
      b-density
      b-temperature
      tt-rvs-line.state-density
    with frame {&frame-name}.
  end .
  
  if rdc-value =  "pomi-rn"
  and parmode = {&update}
  then do :
    if v-revision-mode
    then do :
      if v-mi-lvl > 0
      and v-mi-dnst > 0
      and v-mi-tmp > 0
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame {&frame-name}.
      end .
      else do :
        disable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame {&frame-name}.
      end .
    end .
    else do :
      if not pl-rvd-temp
      then do :
        disable v-mi-tmp b-mi-tmp v-mi-tmp-name with frame {&frame-name}.
      end .
      if not pl-rvd-dens
      then do :
        disable v-mi-dnst b-mi-dnst v-mi-dnst-name with frame {&frame-name}.
      end .
      if not pl-rvd-lvl
      then do :
        disable v-mi-lvl b-mi-lvl v-mi-lvl-name with frame {&frame-name}.
      end .
/*      if ((pl-rvd-lvl and v-mi-lvl > 0) or not pl-rvd-lvl)    */
/*      and ((pl-rvd-dens and v-mi-dnst > 0) or not pl-rvd-dens)*/
/*      and ((pl-rvd-temp and v-mi-tmp > 0) or not pl-rvd-temp) */
      if (pl-rvd-lvl and v-mi-lvl > 0)
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame {&frame-name}.
      end .
      else do :
        disable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame {&frame-name}.
      end .
    end .
  
/*    display                 */
/*      v-mi-lvl              */
/*      v-mi-dnst             */
/*      v-mi-tmp              */
/*    with frame Dialog-Frame.*/
  end .
  
  if parmode = {&update}
  and rdc-value =  "pomi-rn"
  then do :
    if not b-density:sensitive
    and (tt-rvs-line.izmer-density = 0 or tt-rvs-line.izmer-density = ?)
    then do :
      tt-rvs-line.izmer-density = tt-rvs-line.state-density .
      display tt-rvs-line.izmer-density with frame Dialog-Frame .
    end .
    apply "leave" to tt-rvs-line.state-level-total in frame Dialog-Frame .
    
    if pl-rvd-dens
    and pl-rvd-temp
    and v-mi-dnst > 0
    and v-mi-tmp > 0
    then do :
      find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst no-error .
      find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp no-error .
      if available dnst_sr-izmerenia
      and available tmp_sr-izmerenia
      and dnst_sr-izmerenia.node-code <> tmp_sr-izmerenia.node-code
      and ((dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
        or (tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature))
      then do :
        message "Бизнес-процессом не предусмотрено использование разных дополнительных СИ по параметрам температура и плотность, при условии, что одно из установленных дополнительных СИ, предназначено для измерения обоих параметров." skip
                "Установите для температуры и плотности соответствующие требованиям дополнительные СИ."
        view-as alert-box .
        disable b-temperature with frame {&frame-name} .
        disable b-density with frame {&frame-name} .
      end .
    end .
  end .
  
  find first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "POkMI-result" no-error.
  if available rvs-line-attr then do :
    v-POkMI-result-attr = rvs-line-attr.attr-value .
    enable
      b-POkMI-result
    with frame Dialog-Frame.
  end.
  else do :
    disable
      b-POkMI-result
    with frame Dialog-Frame.
  end.
  
  for first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "POkMI-warnings"
  :
    v-POkMI-warnings = rvs-line-attr.attr-value .
  end .
  
  if rdc-value <> 'pomi-rn'
  then do :
    hide
      b-temperature
      b-density
      tt-rvs-line.temp-izm-vol
      b-POkMI-result
    in frame Dialog-Frame.
    if parmode = {&update}
    then do :
      enable 
        tt-rvs-line.state-density
        tt-rvs-line.state-temperature
        tt-rvs-line.state-measure-cli-qnty
        tt-rvs-line.state-level-total
        tt-rvs-line.state-level-water
        tt-rvs-line.state-measure-qnty
      with frame {&frame-name}.
    end .
  end .
  
  
  define variable sr-type-temp as integer no-undo .
  define variable sr-type-temp-tab as integer no-undo .
  define variable sr-type-dens as integer no-undo .
  define variable v-izm-temps-attr as character no-undo .
  define variable v-izm-temps-tab-attr as character no-undo .  
  define variable v-izm-denses-attr as character no-undo .
  define variable it as integer no-undo .
  define variable id as integer no-undo .
  define variable ikey as integer no-undo .

  find first rvs-line-attr no-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps-tab" no-error.
  if available rvs-line-attr then do :
    sr-type-temp-tab = integer(entry(1, rvs-line-attr.attr-value, ";")) no-error .
    v-izm-temps-tab-attr = entry(2, rvs-line-attr.attr-value, ";") no-error .
  end . 
  case sr-type-temp-tab :
    when 0
    then do :
      ikey = num-entries(v-izm-temps-tab-attr) .
      do it = 1 to num-entries(v-izm-temps-tab-attr) :
        find first tt-temps-tab no-lock where tt-temps-tab.ii = ikey no-error .
        if not available tt-temps-tab
        then do :
          create tt-temps-tab .
          assign
            tt-temps-tab.ii = ikey
            tt-temps-tab.key_ = "t" + string(ikey)
            tt-temps-tab.temperature = decimal(entry(it, v-izm-temps-tab-attr))
          .
        end .
        ikey = ikey - 1 .
      end .
    end .
    when 1
    then do :
      do it = 1 to num-entries(v-izm-temps-tab-attr) :
        find first tt-temps-tab no-lock where tt-temps-tab.ii = it no-error .
        if not available tt-temps-tab
        then do :
          if place-type = 1
          and it = 3
          then do :
            tt-temps-tab.key_ = "tср" no-error .
          end .
          create tt-temps-tab .
          assign
            tt-temps-tab.ii = it
            tt-temps-tab.temperature = decimal(entry(it, v-izm-temps-tab-attr))
          .
          case it :
            when 1 then tt-temps-tab.key_ = "tн" .
            when 2 then tt-temps-tab.key_ = "tср" .
            when 3 then tt-temps-tab.key_ = "tв" .
          end case .
          if place-type = 1
          and it = 2
          then do :
            tt-temps-tab.key_ = "tв" no-error .
          end .
        end .
      end .
    end .
  end case . 

  find first rvs-line-attr no-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps" no-error.
  if available rvs-line-attr then do :
    sr-type-temp = integer(entry(1, rvs-line-attr.attr-value, ";")) no-error .
    v-izm-temps-attr = entry(2, rvs-line-attr.attr-value, ";") no-error .
  end .  
 
  find first rvs-line-attr no-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-denses" no-error.
  if available rvs-line-attr then do :
    sr-type-dens = integer(entry(1, rvs-line-attr.attr-value, ";")) no-error .
    v-izm-denses-attr = entry(2, rvs-line-attr.attr-value, ";") no-error .
  end .         
  
  case sr-type-temp :
    when 0
    then do :
      ikey = num-entries(v-izm-temps-attr) .
      do it = 1 to num-entries(v-izm-temps-attr) :
        find first tt-temps no-lock where tt-temps.ii = ikey no-error .
        if not available tt-temps
        then do :
          create tt-temps .
          assign
            tt-temps.ii = ikey
            tt-temps.key_ = "t" + string(ikey)
            tt-temps.temperature = decimal(entry(it, v-izm-temps-attr))
          .
        end .
        ikey = ikey - 1 .
      end .
    end .
    when 1
    then do :
      do it = 1 to num-entries(v-izm-temps-attr) :
        find first tt-temps no-lock where tt-temps.ii = it no-error .
        if not available tt-temps
        then do :
          if place-type = 1
          and it = 3
          then do :
            tt-temps.key_ = "tср" no-error .
          end .
          create tt-temps .
          assign
            tt-temps.ii = it
            tt-temps.temperature = decimal(entry(it, v-izm-temps-attr))
          .
          case it :
            when 1 then tt-temps.key_ = "tн" .
            when 2 then tt-temps.key_ = "tср" .
            when 3 then tt-temps.key_ = "tв" .
          end case .
          if place-type = 1
          and it = 2
          then do :
            tt-temps.key_ = "tв" no-error .
          end .
        end .
      end .
    end .
  end case . 
  
  case sr-type-dens :
    when 0
    then do :
      ikey = num-entries(v-izm-denses-attr) .
      do id = 1 to num-entries(v-izm-denses-attr) :
        find first tt-dens no-lock where tt-dens.ii = ikey no-error .
        if not available tt-dens
        then do :
          create tt-dens .
          assign
            tt-dens.ii = ikey
            tt-dens.key_ = "P" + string(ikey) + (if ikey = 1 then "(низ)" else "")
            tt-dens.density = decimal(entry(id, v-izm-denses-attr))
          .
        end .
        ikey = ikey - 1 .
      end .
    end .
    when 1
    then do :
      do id = 1 to num-entries(v-izm-denses-attr) :
        find first tt-dens-temp no-lock where tt-dens-temp.ii = id no-error .
        if not available tt-dens-temp
        then do :
          create tt-dens-temp .
          assign
            tt-dens-temp.ii = id
            tt-dens-temp.density = decimal(entry(id, v-izm-denses-attr))
          .
          tt-dens-temp.temperature = decimal(entry(id, v-izm-temps-attr)) no-error .
          case id :
            when 1 then tt-dens-temp.key_ = "Pн" .
            when 2 then tt-dens-temp.key_ = "Pср" .
            when 3 then tt-dens-temp.key_ = "Pв" .
          end case .
        end .
      end .
    end .
  end case .
        
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
   message "Неверно определена плотность топлива." skip buf_goods.unit-base skip buf_goods.unit-cli skip tt-rvs-line.state-density view-as alert-box error.
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

/*assign frame {&frame-name} tt-rvs-line.state-density.*/

if tt-rvs-line.state-measure-qnty:sensitive
then
  tt-rvs-line.state-measure-cli-qnty = tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density
.
else
assign
  tt-rvs-line.state-measure-qnty = tt-rvs-line.state-measure-cli-qnty / tt-rvs-line.state-density
.
  
assign
  tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty + (if varstate-water-qnty <> ? then varstate-water-qnty else 0)
/*  tt-rvs-line.state-brutto-qnty      = tt-rvs-line.state-measure-qnty + (if varstate-water-qnty <> ? then varstate-water-qnty else 0)*/
  tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty  * tt-rvs-line.state-density
  tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty
  varstate-sum-vol = tt-rvs-line.state-brutto-qnty 
.
abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 no-error .
display tt-rvs-line.state-measure-cli-qnty tt-rvs-line.fact-calc-add-mass tt-rvs-line.state-measure-qnty tt-rvs-line.fact-sum-mass varstate-sum-vol with frame {&frame-name}.
/*display tt-rvs-line.state-brutto-cli-qnty with frame {&frame-name}.*/
/*if tt-rvs-line.state-measure-cli-qnty > tt-rvs-line.state-brutto-cli-qnty then do:    */
/*  message "Измеренный вес больше веса брутто. Подставить измеренный вес в вес брутто?"*/
/*  view-as alert-box question buttons yes-no update varlog.                            */
/*  if varlog = yes then do:                                                            */
/*    assign                                                                            */
/*      tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty.         */
/*    display tt-rvs-line.state-brutto-cli-qnty with frame {&frame-name}.               */
/*  end.                                                                                */
/*end.                                                                                  */

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
          varstate-water-cli-qnty delta-mass-qnty varstate-sum-vol varsum-vol /*mass-float-cov */
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
          tt-rvs-line.meas-cli-calc-qnty tt-rvs-line.temp-izm-vol
          tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty
          tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol
          tt-rvs-line.level-total tt-rvs-line.state-level-total
          tt-rvs-line.level-water tt-rvs-line.state-level-water
          tt-rvs-line.temperature tt-rvs-line.state-temperature
          tt-rvs-line.meas-mh-qnty tt-rvs-line.state-mh-qnty
          tt-rvs-line.meas-am-qnty tt-rvs-line.state-am-qnty
          tt-rvs-line.meas-cf-qnty tt-rvs-line.state-cf-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help RECT-2 RECT-3 tt-rvs-line.state-measure-qnty
         tt-rvs-line.state-density b-calc tt-rvs-line.state-add-qnty
         tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-cli-qnty
         tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total
         tt-rvs-line.state-temperature
/*         mass-float-cov*/
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

/*  if input frame {&frame-name} tt-rvs-line.state-level-petrol >                        */
/*     input frame {&frame-name} tt-rvs-line.state-level-total  then do:                 */
/*    assign is_OK = no.                                                                 */
/*    if p-mode = yes then do:                                                           */
/*      message "Уровень топлива больше значения общего уровня." view-as alert-box error.*/
/*      return error.                                                                    */
/*    end.                                                                               */
/*  end.                                                                                 */
  tt-rvs-line.state-level-petrol = input frame {&frame-name} tt-rvs-line.state-level-total - input frame {&frame-name} tt-rvs-line.state-level-water .
/*  display input frame {&frame-name} tt-rvs-line.state-level-total  -*/
/*          input frame {&frame-name} tt-rvs-line.state-level-petrol @*/
/*                                    tt-rvs-line.state-level-water   */
/*  with frame {&frame-name}.                                         */
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
define buffer buf_place for ub.place.
define variable  v-file-name as character no-undo.
define variable v-delta-mas-qnty as decimal no-undo.
define variable v-full-name as character no-undo.
    define variable tt-level-water     as integer no-undo.
    define variable tt-level-water-dec as decimal no-undo.
    define variable v-water-qnty       as decimal no-undo. 
    define buffer bf-water-nxt_pl-level for pl-level.
    define variable varlevel-sm-water as decimal no-undo.
    
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
  find first buf_place no-lock 
    where buf_place.pl-code = tt-rvs-line.pl-code
    .
  find first bf_pl-level
    where bf_pl-level.obj-type = tt-rvs-line.obj-type
      and bf_pl-level.obj-code = tt-rvs-line.obj-code
      and bf_pl-level.pl-code  = buf_place.pl-code
      and bf_pl-level.pl-level = varlevel-sm
    no-error.
  if not available bf_pl-level then do:
    message "Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара " buf_place.loc1 " не задан объем для уровня " varlevel-sm view-as alert-box error.
    return no-apply.
  end.
  else do:
    if varlevel-sm = varlevel-sm-q then do:
      if error-status:error then return no-apply.
      display
/*        bf_pl-level.pl-qnty @ tt-rvs-line.state-brutto-qnty */
/*        bf_pl-level.pl-qnty @ tt-rvs-line.state-measure-qnty*/
        bf_pl-level.pl-qnty @ tt-rvs-line.state-measure-qnty
        bf_pl-level.pl-qnty + tt-rvs-line.state-add-qnty @ tt-rvs-line.fact-sum-vol
        with frame {&frame-name}.
    end.
    else do:
      assign
        varlevel-sm = varlevel-sm + 1.
      find first buf-nxt_pl-level
        where buf-nxt_pl-level.obj-type = tt-rvs-line.obj-type
          and buf-nxt_pl-level.obj-code = tt-rvs-line.obj-code
          and buf-nxt_pl-level.pl-code  = buf_place.pl-code
          and buf-nxt_pl-level.pl-level = varlevel-sm
        no-error.
      if not available buf-nxt_pl-level then do:
        message "Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара " buf_place.loc1 " не задан объем для уровня " varlevel-sm " измерение " varlevel-sm-q view-as alert-box error.
        return no-apply.
      end.
      else do:
        display
/*          bf_pl-level.pl-qnty + (buf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) @ tt-rvs-line.state-brutto-qnty */
/*          bf_pl-level.pl-qnty + (buf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) @ tt-rvs-line.state-measure-qnty*/
          bf_pl-level.pl-qnty + (buf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) @ tt-rvs-line.state-measure-qnty
          bf_pl-level.pl-qnty + (buf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) + tt-rvs-line.state-add-qnty @ tt-rvs-line.fact-sum-vol
          with frame {&frame-name}.
      end.
    end.
      if  tt-rvs-line.state-level-water <> 0 then 
      do: 
          find first bf_pl-level where bf_pl-level.obj-type = tt-rvs-line.obj-type      and
              bf_pl-level.obj-code = tt-rvs-line.obj-code      and
              bf_pl-level.pl-code  = buf_place.pl-code          and
              bf_pl-level.pl-level = tt-rvs-line.state-level-water           no-error.
          if not available bf_pl-level then
          do:

                  assign
                      varlevel-sm-water = tt-rvs-line.state-level-water  + 1.
                  for each  bf-water-nxt_pl-level where bf-water-nxt_pl-level.obj-type = tt-rvs-line.obj-type  and
                      bf-water-nxt_pl-level.obj-code = tt-rvs-line.obj-code  and
                      bf-water-nxt_pl-level.pl-code  = buf_place.pl-code  and
                      bf-water-nxt_pl-level.pl-level  <  varlevel-sm-water   and        
                      bf-water-nxt_pl-level.pl-level > tt-rvs-line.state-level-water  - 1 no-lock  :  
                      v-water-qnty = abs (  abs (v-water-qnty )  -  bf-water-nxt_pl-level.pl-qnty / 10 )  .
                                  
                      if  bf-water-nxt_pl-level.pl-level > tt-rvs-line.state-level-water  - 1 and bf-water-nxt_pl-level.pl-level < tt-rvs-line.state-level-water  then 
                      do: 
                          tt-level-water =  bf-water-nxt_pl-level.pl-qnty.
                          tt-level-water-dec =  tt-rvs-line.state-level-water - bf-water-nxt_pl-level.pl-level .
                      end.
                  end. 
                  varstate-water-qnty =  tt-level-water +  tt-level-water-dec *  v-water-qnty * 10  . 
                  display  varstate-water-qnty with frame {&frame-name}.
/*                  display tt-rvs-line.state-brutto-qnty +  varstate-water-qnty  @ tt-rvs-line.state-brutto-qnty*/
/*                      with frame {&frame-name}.                                                                */
                  display tt-rvs-line.state-measure-qnty + varstate-water-qnty  @ varstate-sum-vol
                      with frame {&frame-name}.
          end.
          else
          do:
              assign
                  varstate-water-qnty = bf_pl-level.pl-qnty  .
              display  varstate-water-qnty with frame {&frame-name}.
/*              display tt-rvs-line.state-brutto-qnty +  varstate-water-qnty  @ tt-rvs-line.state-brutto-qnty*/
/*              with frame {&frame-name}.                                                                    */
              display tt-rvs-line.state-measure-qnty + varstate-water-qnty  @ varstate-sum-vol
                      with frame {&frame-name}.
/*              DISPLAY tt-rvs-line.state-measure-qnty with frame {&frame-name} .*/
          end.
      end.  
          else do:
              assign
                  varstate-water-qnty = 0  .
              display  varstate-water-qnty with frame {&frame-name}.
                
              display tt-rvs-line.state-measure-qnty @ varstate-sum-vol
              with frame {&frame-name}.
/*              DISPLAY tt-rvs-line.state-measure-qnty with frame {&frame-name} .*/

          end.    

      assign
        tt-rvs-line.state-measure-qnty
        tt-rvs-line.state-measure-qnty = tt-rvs-line.state-measure-qnty - varstate-water-qnty 
        tt-rvs-line.state-brutto-qnty = tt-rvs-line.state-measure-qnty + varstate-water-qnty
      .
        display tt-rvs-line.state-measure-qnty with frame {&frame-name}.
/*        display tt-rvs-line.state-brutto-qnty with frame {&frame-name}.*/
        if tt-rvs-line.state-density <> 0 and
            tt-rvs-line.state-density <> ? then 
        do:
            run chg-density.
            run weath-water.
        end.
        
      if rdc-value = "pomi-rn"  then do:
        /*Тип резервуара*/
        run placelib_get-attr in this-procedure  (
            input {&place-type}
            ,input tt-rvs-line.obj-code
            ,input tt-rvs-line.obj-type
            ,input tt-rvs-line.pl-code
            ,output v-value
            ,output v-ok      ) no-error.
        if v-ok then 
        do :

    /*CASE paraction:
      WHEN "state-level-total" THEN DO:
        DISPLAY input frame {&frame-name} tt-rvs-line.state-level-total @ tt-rvs-line.state-level-petrol WITH FRAME {&FRAME-NAME}.
      END.
      WHEN "state-level-petrol" THEN DO:
        DISPLAY input frame {&frame-name} tt-rvs-line.state-level-petrol @ tt-rvs-line.state-level-total WITH FRAME {&FRAME-NAME}.
      END.
    END CASE.*/
            { gbl/getsect.i run  tt-rvs-line.obj-type  tt-rvs-line.obj-code  {&attr-petrol} }
    
            if integer(v-value) = 1 then 
            do:
                for each thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-petrol_Delta-mass-vert}:    
                    assign 
                        v-full-name = thbjattr_thbj-attr.property-value-character .
                end.
            end.    
            else 
            do:
                for each thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-petrol_Delta-mass-horiz}:    
                    assign 
                        v-full-name = thbjattr_thbj-attr.property-value-character .
                end.
            end.     
            do ii = 1 to NUM-ENTRIES(v-full-name,{&new-line}): 
                v-file-name = string(entry(ii,v-full-name,{&new-line})).
                if    tt-rvs-line.state-level-petrol = decimal ( entry(1, v-file-name, ";")  )  then 
                do: 
                    v-delta-mas-qnty =  decimal( entry(2, v-file-name, ";") ) no-error.
                end.
            end.
        end.
        if v-delta-mas-qnty > 0.65 then v-delta-mas-qnty = 0.65 .
        delta-mass-qnty = v-delta-mas-qnty.
        display  delta-mass-qnty with frame {&frame-name}.
        end.
        
    abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 no-error .
    
/*    if tt-rvs-line.state-measure-cli-qnty = ?*/
/*    then do :                                */
       tt-rvs-line.state-measure-cli-qnty = input frame {&frame-name} tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density .
       tt-rvs-line.fact-sum-mass = tt-rvs-line.state-measure-cli-qnty + tt-rvs-line.fact-calc-add-mass .
/*    end.*/
    tt-rvs-line.fact-sum-vol = tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty .
    varstate-sum-vol = input frame {&frame-name} tt-rvs-line.state-measure-qnty + varstate-water-qnty .
    
    display 
      abs-delta-mass-add-qnty
      tt-rvs-line.fact-sum-vol
      tt-rvs-line.state-measure-cli-qnty
      tt-rvs-line.fact-sum-mass
      varstate-sum-vol
    with frame {&frame-name}.

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
/*  display input frame {&frame-name} tt-rvs-line.brutto-qnty - */
/*          input frame {&frame-name} tt-rvs-line.measure-qnty @*/
/*          varmeasure-water-qnty with frame {&frame-name}.     */
  display ? @ varmeasure-water-qnty with frame {&frame-name}.
  for first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "measure-water-qnty"
  :
    display decimal(rvs-line-attr.attr-value) @ varmeasure-water-qnty with frame {&frame-name}.
  end .         
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
if rdc-value <>  "pomi-rn"
then do :
  if tt-rvs-line.state-brutto-qnty -
     tt-rvs-line.state-measure-qnty <> ?
  then
  display tt-rvs-line.state-brutto-qnty - tt-rvs-line.state-measure-qnty @
          varstate-water-qnty with frame {&frame-name}.
  else        
  if input frame {&frame-name} tt-rvs-line.state-brutto-qnty -
     input frame {&frame-name} tt-rvs-line.state-measure-qnty <> ?
  then
  display input frame {&frame-name} tt-rvs-line.state-brutto-qnty -
          input frame {&frame-name} tt-rvs-line.state-measure-qnty @
          varstate-water-qnty with frame {&frame-name}.
end.
else do :
  for first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "pokmi-water-qnty"
  :
    display decimal(rvs-line-attr.attr-value) @ varstate-water-qnty with frame {&frame-name}.
  end .
end .
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
/*if input frame {&frame-name} tt-rvs-line.state-measure-cli-qnty >      */
/*   input frame {&frame-name} tt-rvs-line.state-brutto-cli-qnty then do:*/
/*   message "Вес топлива больше общего веса."                           */
/*   view-as alert-box error.                                            */
/*   return error.                                                       */
/*end.                                                                   */
/*display input frame {&frame-name} tt-rvs-line.state-brutto-cli-qnty -  */
/*        input frame {&frame-name} tt-rvs-line.state-measure-cli-qnty @ */
/*        varstate-water-cli-qnty with frame {&frame-name}.              */
/*assign frame {&frame-name} tt-rvs-line.state-brutto-cli-qnty           */
/*                           tt-rvs-line.state-measure-cli-qnty.         */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

