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
field izmer-density      AS DECIMAL FORMAT "9.9999":U INITIAL 0
field calc-add-mass      AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field sum-mass           AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field sum-vol            AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field fact-calc-add-mass AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field fact-sum-mass      AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field fact-sum-vol       AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0 
field vol-pf-sug         AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field state-vol-pf-sug   AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field dens-pf-sug        AS DECIMAL FORMAT "9.9999":U INITIAL 0
field state-dens-pf-sug  AS DECIMAL FORMAT "9.9999":U INITIAL 0
field pressure-sug       AS DECIMAL FORMAT ">>>>>9.99999":U INITIAL 0
field state-pressure-sug AS DECIMAL FORMAT ">>>>>9.99999":U INITIAL 0
.

define new shared temp-table tt-sug-struct no-undo
  field ii as integer
  field key_ as character
  field val_ as decimal format ">>9.<<"
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

Экран работы со строкой сверки СУГ

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
{ gbl/ptrlprop.i def}
{ gbl/cur-time.i }
{ cmp/trg-def.i  }
{ gbl/getsect.i def }
{ str/initiator.i }
{ gbl/color.i }
{ str/pokmi-dyn.i }

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
define variable v-sug-struct-val as character no-undo .
define variable v-POkMI-result-attr     as character no-undo.
define variable v-POkMI-warnings        as character no-undo init "" .

define variable place-diameter    as decimal no-undo .
define variable pl-dens-sr-izm    as integer no-undo .
define variable pl-level-sr-izm   as integer no-undo .
define variable pl-temp-sr-izm    as integer no-undo .
define variable v-dnst-mi-old     as integer no-undo .
define variable v-tmp-mi-old      as integer no-undo .
define variable v-lvl-mi-old      as integer no-undo .

define variable is-main-tank      as logical no-undo .
define variable place-SI          as integer no-undo.

define variable v-revision-mode   as logical no-undo init no .
define variable v-first-enter     as logical no-undo init yes .
define variable v-value           as character no-undo.
define variable v-ok              as logical   no-undo.
define VARIABLE ii as integer no-undo .

define variable twice-place-data as character no-undo .

define buffer buf_goods        for ub.goods .
define buffer buf_rvs-doc      for ub.rvs-doc.
define buffer buf_rvs-doc-attr for ub.rvs-doc-attr .
define buffer buf_rvs-line     for ub.rvs-line .
define buffer bf_pl-level      for ub.pl-level.
define buffer buf-nxt_pl-level for ub.pl-level.
define buffer buf2_place       for ub.place.
define buffer bf_place         for ub.place.
define buffer buf_trn-doc      for ub.trn-doc .
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
tt-rvs-line.state-measure-qnty ~
tt-rvs-line.measure-tc-qnty ~
tt-rvs-line.vol-pf-sug tt-rvs-line.state-vol-pf-sug ~
tt-rvs-line.dens-pf-sug tt-rvs-line.state-dens-pf-sug ~
tt-rvs-line.pressure-sug tt-rvs-line.state-pressure-sug ~
tt-rvs-line.state-measure-tc-qnty tt-rvs-line.density ~
tt-rvs-line.state-density ~
tt-rvs-line.izmer-density tt-rvs-line.add-qnty tt-rvs-line.state-add-qnty ~
tt-rvs-line.brutto-qnty tt-rvs-line.state-brutto-qnty ~
tt-rvs-line.measure-cli-qnty tt-rvs-line.state-measure-cli-qnty ~
tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty ~
tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol ~
tt-rvs-line.level-total tt-rvs-line.state-level-total ~
tt-rvs-line.level-water tt-rvs-line.state-level-water ~
tt-rvs-line.temperature tt-rvs-line.state-temperature ~
tt-rvs-line.meas-mh-qnty ~
tt-rvs-line.state-mh-qnty tt-rvs-line.meas-am-qnty ~
tt-rvs-line.state-am-qnty tt-rvs-line.meas-cf-qnty ~
tt-rvs-line.state-cf-qnty tt-rvs-line.izmer-density 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-rvs-line.state-vol-pf-sug ~
tt-rvs-line.state-dens-pf-sug ~
tt-rvs-line.state-pressure-sug ~
tt-rvs-line.state-measure-qnty ~
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
tt-rvs-line.state-vol-pf-sug ~
tt-rvs-line.state-dens-pf-sug ~
tt-rvs-line.state-pressure-sug ~
tt-rvs-line.state-density ~
tt-rvs-line.izmer-density tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-qnty ~
tt-rvs-line.state-brutto-cli-qnty tt-rvs-line.state-level-petrol ~
tt-rvs-line.state-level-total tt-rvs-line.state-temperature 
&Scoped-define ENABLED-TABLES tt-rvs-line
&Scoped-define FIRST-ENABLED-TABLE tt-rvs-line
&Scoped-Define ENABLED-OBJECTS b-save RECT-2 RECT-3 b-cancel b-help b-calc ~
delta-mass-qnty CriticalDif /* mass-float-cov */
&Scoped-Define DISPLAYED-FIELDS tt-rvs-line.system-qnty ~
tt-rvs-line.system-cli-qnty tt-rvs-line.orig-system-qnty ~
tt-rvs-line.orig-system-cli-qnty tt-rvs-line.measure-qnty ~
tt-rvs-line.state-measure-qnty ~
tt-rvs-line.measure-tc-qnty ~
tt-rvs-line.vol-pf-sug tt-rvs-line.state-vol-pf-sug ~
tt-rvs-line.dens-pf-sug tt-rvs-line.state-dens-pf-sug ~
tt-rvs-line.pressure-sug tt-rvs-line.state-pressure-sug ~
tt-rvs-line.state-measure-tc-qnty tt-rvs-line.density ~
tt-rvs-line.state-density ~
tt-rvs-line.izmer-density tt-rvs-line.add-qnty tt-rvs-line.state-add-qnty ~
tt-rvs-line.brutto-qnty tt-rvs-line.state-brutto-qnty ~
tt-rvs-line.measure-cli-qnty tt-rvs-line.state-measure-cli-qnty ~
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
tt-rvs-line.meas-cf-qnty 
&Scoped-define List-2 tt-rvs-line.state-measure-qnty ~
tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-density ~
tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-qnty ~
tt-rvs-line.state-measure-cli-qnty ~
tt-rvs-line.state-brutto-cli-qnty tt-rvs-line.state-level-petrol ~
tt-rvs-line.state-level-total tt-rvs-line.state-level-water ~
tt-rvs-line.state-temperature ~
tt-rvs-line.state-mh-qnty tt-rvs-line.state-am-qnty ~
tt-rvs-line.state-cf-qnty tt-rvs-line.izmer-density 
&Scoped-define List-3 tt-rvs-line.state-measure-tc-qnty ~
tt-rvs-line.state-add-qnty ~
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
          
DEFINE BUTTON b-sug-struct 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Состав СУГ" 
     SIZE 3 BY .87.
     
DEFINE BUTTON b-rez 
     LABEL "&Резервуары" 
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE delta-mass-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Отн. погр. изм. массы СУГ (ПОкМИ)" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.
     
DEFINE VARIABLE abs-delta-mass-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Абс. погр. изм. массы СУГ (ПОкМИ)" 
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

define variable level-prc as decimal format ">>9.99":U initial ? .
define variable str-level-prc as character format "X(28)" .
define variable str-level-total as character format "X(28)" .
define variable str-level-sug as character format "X(28)" .
define variable str-level-water as character format "X(28)" .
define variable str-level-total-fact as character format "X(28)" .
define variable str-level-sug-fact as character format "X(28)" .
define variable str-level-water-fact as character format "X(28)" .

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

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 54 BY 24.75.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 52 BY 24.75.

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
     b-rez at row 1 col 21
     b-help AT ROW 1 COL 21
     b-POkMI-result at row 1 col 90
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
     tt-rvs-line.system-qnty AT ROW 2.25 COL 10 
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем расчетно-книжный (л)"
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
     tt-rvs-line.system-cli-qnty AT ROW 2.25 COL 74 COLON-ALIGNED
          LABEL "Вес расчетно-книжный (кг)"
          FORMAT "->>,>>>,>>9.9":U
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
     tt-rvs-line.orig-system-qnty AT ROW 3.25 COL 25 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Первоначально (л)"
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
          FGCOLOR 4 
     tt-rvs-line.orig-system-cli-qnty AT ROW 3.25 COL 73 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Первоначально (кг)"
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
          FGCOLOR 4 
     tt-rvs-line.measure-qnty AT ROW 6.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Измер. остаток (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-measure-qnty AT ROW 6.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Факт ост. общ. ЖФ+ПФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.measure-tc-qnty AT ROW 16.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Измер. объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-measure-tc-qnty AT ROW 16.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.vol-pf-sug AT ROW 17.75 COL 35 COLON-ALIGNED
          LABEL "Измер. объем СУГ ПФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-vol-pf-sug AT ROW 17.75 COL 90 COLON-ALIGNED
          LABEL "Объем СУГ ПФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.density AT ROW 19.75 COL 35 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Измер. Плотность ЖФ (г/см3)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-density AT ROW 19.75 COL 90 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Плотность ЖФ (г/см3)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     b-calc AT ROW 23.75 COL 65 WIDGET-ID 6
     b-sug-struct at row 20.25 col 104.8 
     tt-rvs-line.dens-pf-sug AT ROW 20.75 COL 35 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Измер. плотность ПФ (г/см3)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-dens-pf-sug AT ROW 20.75 COL 90 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Плотность ПФ (г/см3)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.add-qnty AT ROW 12.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем в трубопроводе (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.calc-add-mass AT ROW 13.75 COL 35 COLON-ALIGNED
          LABEL "Рассч. Масса в трубопроводе (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.fact-calc-add-mass AT ROW 13.75 COL 90 COLON-ALIGNED
          LABEL "Рассч. Масса в трубопроводе (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     abs-delta-mass-add-qnty AT ROW 14.75 COL 90 COLON-ALIGNED
     tt-rvs-line.state-add-qnty AT ROW 12.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем в трубопроводе (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.brutto-qnty AT ROW 12.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Общий объём СУГ ЖФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-qnty AT ROW 12.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Факт объём (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     varmeasure-water-qnty AT ROW 27.75 COL 35 COLON-ALIGNED
     varstate-water-qnty AT ROW 27.75 COL 90 COLON-ALIGNED
     varsum-vol AT ROW 28.75 COL 35 COLON-ALIGNED
     varstate-sum-vol AT ROW 28.75 COL 90 COLON-ALIGNED
     tt-rvs-line.measure-qnty AT ROW 16.75 COL 35 COLON-ALIGNED
          LABEL "Измер. объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-measure-qnty AT ROW 16.75 COL 90 COLON-ALIGNED
          LABEL "Объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.measure-cli-qnty AT ROW 18.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Измер. Масса СУГ (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-measure-cli-qnty AT ROW 18.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Масса СУГ (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         CANCEL-BUTTON b-cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-rvs-line.brutto-cli-qnty AT ROW 17.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Общая масса (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-cli-qnty AT ROW 17.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Факт общая масса (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.sum-vol AT ROW 24.75 COL 35 COLON-ALIGNED
          LABEL "Общий Объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.sum-mass AT ROW 25.75 COL 35 COLON-ALIGNED
          LABEL "Общая Масса СУГ (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.fact-sum-vol AT ROW 24.75 COL 90 COLON-ALIGNED
          LABEL "Общий Объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.fact-sum-mass AT ROW 25.75 COL 90 COLON-ALIGNED
          LABEL "Общая Масса СУГ (кг)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     varmeasure-water-cli-qnty AT ROW 27.75 COL 28.13 COLON-ALIGNED
     varstate-water-cli-qnty AT ROW 27.75 COL 90 COLON-ALIGNED
     tt-rvs-line.level-petrol AT ROW 8.75 COL 30 COLON-ALIGNED format ">>,>>9.9"
          LABEL "Измер. уровень СУГ (см)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-level-petrol AT ROW 8.75 COL 90 COLON-ALIGNED format ">>,>>9.9"
          LABEL "Факт уровень СУГ (см)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.level-total AT ROW 6.75 COL 30 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. общий уровень (см)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-level-total AT ROW 6.75 COL 90 COLON-ALIGNED format ">>,>>9.9"
          LABEL "Факт общий уровень (см)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88 
     tt-rvs-line.level-water AT ROW 7.75 COL 30 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. уровень воды (см)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-level-water AT ROW 7.75 COL 90 COLON-ALIGNED format ">>,>>9.9"
          LABEL "Факт уровень воды (см)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     str-level-sug AT ROW 8.75 COL 30 COLON-ALIGNED
          LABEL "Измер. уровень СУГ (см)"
          VIEW-AS FILL-IN 
          SIZE 20 BY .88
     str-level-sug-fact AT ROW 8.75 COL 90 COLON-ALIGNED
          LABEL "Факт уровень СУГ (см)"
          VIEW-AS FILL-IN 
          SIZE 20 BY .88
     str-level-total AT ROW 6.75 COL 30 COLON-ALIGNED
          LABEL "Измер. общий уровень (см)"
          VIEW-AS FILL-IN 
          SIZE 20 BY .88
     str-level-total-fact AT ROW 6.75 COL 90 COLON-ALIGNED
          LABEL "Факт общий уровень (см)"
          VIEW-AS FILL-IN 
          SIZE 20 BY .88
     str-level-water AT ROW 7.75 COL 30 COLON-ALIGNED
          LABEL "Измер. уровень воды (см)"
          VIEW-AS FILL-IN 
          SIZE 20 BY .88
     str-level-water-fact AT ROW 7.75 COL 90 COLON-ALIGNED
          LABEL "Факт уровень воды (см)"
          VIEW-AS FILL-IN 
          SIZE 20 BY .88
     tt-rvs-line.temperature AT ROW 9.75 COL 30 COLON-ALIGNED
          FORMAT "->>9.9":U
          LABEL "Температура средняя (°С)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.state-temperature AT ROW 9.75 COL 90 COLON-ALIGNED
          FORMAT "->>9.9":U
          LABEL "Температура продукта в рез. (°С)"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-rvs-line.meas-mh-qnty AT ROW 23.75 COL 29.13 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     tt-rvs-line.state-mh-qnty AT ROW 32.75 COL 15.5 COLON-ALIGNED
          LABEL "Оборот по ТРК"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt-rvs-line.meas-am-qnty AT ROW 31.75 COL 29.13 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     tt-rvs-line.state-am-qnty AT ROW 32.75 COL 55.5 COLON-ALIGNED
          LABEL "Сумма оборота по ТРК"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt-rvs-line.meas-cf-qnty AT ROW 32.75 COL 30.13 COLON-ALIGNED
          LABEL "Измеренное кол-во наливов"
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         CANCEL-BUTTON b-cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-rvs-line.state-cf-qnty AT ROW 32.75 COL 95.5 COLON-ALIGNED
          LABEL "Количество наливов"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt-rvs-line.pressure-sug AT ROW 29.75 COL 35 COLON-ALIGNED
          LABEL "Изм. давление (МПа)"
          VIEW-AS FILL-IN 
          SIZE 17 BY .88
     tt-rvs-line.state-pressure-sug AT ROW 29.75 COL 90 COLON-ALIGNED
          LABEL "Давление (МПа)"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88  
     level-prc at row 30.75 COL 90 COLON-ALIGNED
          label "Уровень наполнения (%)"
          VIEW-AS FILL-IN 
          SIZE 6 BY .88    
     delta-mass-qnty AT ROW 21.75 COL 90 COLON-ALIGNED  WIDGET-ID 22
     abs-delta-mass-qnty AT ROW 22.75 COL 90 COLON-ALIGNED  WIDGET-ID 22
     CriticalDif AT ROW 4.25 COL 34 COLON-ALIGNED WIDGET-ID 2
/*     mass-float-cov AT ROW 26.5 COL 54 COLON-ALIGNED WIDGET-ID 2*/
/*       "Погр. изм." VIEW-AS TEXT                             */
/*          SIZE 12.5 BY .75 AT ROW 24.75 COL 88.5 WIDGET-ID 24*/
     
     RECT-2 AT ROW 6.5 COL 54
     RECT-3 AT ROW 6.5 COL 2
     SPACE(2) SKIP(1)
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
    return .
  end .
  else do :
    if lvl_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
      return .
    end .
    if not lvl_sr-izmerenia.sr-level
    then do :
      message "Средство измерения НЕ измеряет уровень!" view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
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
  enable
    tt-rvs-line.state-level-total
    tt-rvs-line.state-level-water
    tt-rvs-line.state-temperature
    b-sug-struct
  with frame {&frame-name}.
  /*
  if v-revision-mode
  then do :
    if v-mi-dnst > 0
    and v-mi-tmp > 0
    then do :
      enable
        tt-rvs-line.state-level-total
        tt-rvs-line.state-level-water
        tt-rvs-line.state-temperature
        b-sug-struct
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
          b-sug-struct
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
  */
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
    return .
  end .
  else do :
    if dnst_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
      return .
    end .
    if not dnst_sr-izmerenia.sr-density
    then do :
      message "Средство измерения НЕ измеряет плотность!" view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
      return .
    end .
  end .
  v-mi-dnst-name = dnst_sr-izmerenia.sr-model .
  display v-mi-dnst-name with frame {&frame-name}.
  enable v-mi-dnst-name with frame {&frame-name}.
  assign v-mi-dnst .
  
  if dnst_sr-izmerenia.sr-temperature
  and v-mi-dnst <> v-mi-tmp
  and b-mi-tmp:sensitive
  then do :
/*    message "Для измерения плотности выбрано дополнительное СИ " + v-mi-dnst-name + ". Установить данное СИ для измерения температуры автоматически?"*/
/*    view-as alert-box buttons yes-no update vlog .                                                                                                   */
/*    if vlog                                                                                                                                          */
/*    then do :                                                                                                                                        */
      v-mi-tmp = v-mi-dnst .
      v-mi-tmp:screen-value = v-mi-dnst:screen-value .
      v-mi-tmp-name = v-mi-dnst-name .
      apply "leave" to v-mi-tmp in frame Dialog-Frame .
/*    end .*/
  end .
  /*
  if rdc-value = 'pomi-rn'
  then do :
    if string(v-mi-dnst) <> v-old-val
    then do :
      tt-rvs-line.state-density = 0 .
    end .
/*    tt-rvs-line.state-temperature = 0 .*/
    display tt-rvs-line.state-density /* tt-rvs-line.state-temperature */ with  frame {&frame-name}.
    if v-revision-mode
    then do :
      if v-mi-lvl > 0
      and v-mi-tmp > 0
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
          tt-rvs-line.state-temperature
          b-sug-struct
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
            b-sug-struct
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
  */
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
    return .
  end .
  else do :
    if tmp_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
      return .
    end .
    if not tmp_sr-izmerenia.sr-temperature
    then do :
      message "Средство измерения НЕ измеряет температуру!" view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
      return .
    end .
  end .
  v-mi-tmp-name = tmp_sr-izmerenia.sr-model .
  display v-mi-tmp-name with frame {&frame-name}.
  enable v-mi-tmp-name with frame {&frame-name}.
  assign v-mi-tmp .
  if string(v-mi-tmp) <> v-old-val
  then do :
    tt-rvs-line.state-temperature = 0 .
  end .
  display tt-rvs-line.state-temperature  with frame {&frame-name}.
  
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
  /*
  if v-revision-mode
  then do :
    if v-mi-dnst > 0
    and v-mi-lvl > 0
    then do :
      enable
        tt-rvs-line.state-level-total
        tt-rvs-line.state-level-water
        tt-rvs-line.state-temperature
        b-sug-struct
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
          b-sug-struct
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
  */
  apply "leave" to tt-rvs-line.state-level-total in frame Dialog-Frame .
end .

&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON CHOOSE OF b-calc IN FRAME Dialog-Frame /* Рассчитать */
DO:

define variable v-mm as com-handle.
define variable v-proc as character no-undo.
define variable v-pokmi-dll-version as character no-undo .

define variable v-code            as character no-undo.
define variable ii                as integer   no-undo.

define variable place-type        as integer no-undo.
define variable place-SI          as integer no-undo.
define variable place-diameter    as decimal no-undo.
define variable place-ratio-error as decimal no-undo.
define variable dens-prov         as decimal no-undo format "9.9999999999":U.

define variable CalibTable        as character no-undo initial "".
define variable ToolType          as integer no-undo.
define variable LevelToolType          as integer no-undo.
define variable A_LevelMeasurementTool  as decimal no-undo.
define variable DeltaAbs_H              as decimal no-undo.
define variable DeltaAbs_H_Water        as decimal no-undo.
define variable DeltaAbs_R_liquid          as decimal no-undo.
define variable DeltaAbs_R_gas    as decimal no-undo.
define variable DeltaAbs_Tv             as decimal no-undo.
define variable DeltaAbs_Tr             as decimal no-undo.
define variable DeltaOtn_N              as decimal no-undo init 0.05 .
define variable DeltaOtn_H              as decimal no-undo.
define variable DeltaOtn_H_Water        as decimal no-undo.
define variable DeltaOtn_R              as decimal no-undo.
define variable DeltaOtn_K              as decimal no-undo.
define variable DeltaOtn_K_Full         as decimal no-undo.
define variable Use_DeltaOtn_R_liquid_IN as logical no-undo.
define variable DeltaOtn_R_liquid_IN    as decimal no-undo.
define variable A_Reservoir             as decimal no-undo init 0.0000125 .
define variable temp-for-pomi           as integer no-undo.
define variable error-string            as character no-undo.
define variable v-is-meas               as logical no-undo.
define variable v-mm-density            as decimal no-undo.


define variable DeltaV1                 as decimal no-undo .
define variable DeltaV2                 as decimal no-undo .
define variable DeltaVSugFull           as decimal no-undo .

define variable vErr as character no-undo .
define variable vWrn as character no-undo .
define variable vDllVersion as character no-undo .

define variable C_HN              as decimal no-undo .
define variable C_HN_delta        as decimal no-undo .
define variable C_full            as decimal no-undo .
define variable V_liquid          as decimal no-undo .
define variable V_gas             as decimal no-undo .
define variable M_liquid          as decimal no-undo .
define variable M_gas             as decimal no-undo .
define variable M                 as decimal no-undo .
define variable Kf                as decimal no-undo .
define variable DeltaOtn_R_liquid as decimal no-undo .
define variable DeltaOtn_R_gas    as decimal no-undo .
define variable DeltaOtn_M_liquid as decimal no-undo .
define variable DeltaOtn_M_gas    as decimal no-undo .
define variable DeltaOtn_M        as decimal no-undo .
define variable H_min_liquid      as decimal no-undo .
define variable H_min             as decimal no-undo .
define variable A                 as decimal no-undo .
define variable B                 as decimal no-undo .

define buffer buf_sr-izmerenia for ub.sr-izmerenia .
define buffer dens_sr-izmerenia for ub.sr-izmerenia .
define buffer temp_sr-izmerenia for ub.sr-izmerenia .
define buffer level_sr-izmerenia for ub.sr-izmerenia .
define buffer buf_place     for ub.place.

define buffer full_pl-level for ub.pl-level .
define buffer sug1_pl-level for ub.pl-level .
define buffer sug2_pl-level for ub.pl-level .
define buffer buf_pl-level-attr for ub.pl-level-attr .

define buffer bf_goods for ub.goods .
define buffer bf_place for ub.place .


  assign frame {&frame-name} tt-rvs-line.state-level-total   .
  assign frame {&frame-name} tt-rvs-line.state-level-water   .
  assign frame {&frame-name} tt-rvs-line.state-temperature   .
  assign frame {&frame-name} CriticalDif .
  _trpomi :
    do on error undo, return no-apply :
      
    if tt-rvs-line.state-density = ? or tt-rvs-line.state-density = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите плотность ЖФ "
      view-as alert-box error.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-dens-pf-sug = ? or tt-rvs-line.state-dens-pf-sug = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите плотность ПФ "
      view-as alert-box error.
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
    if tt-rvs-line.state-temperature = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите температуру"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temperature in frame {&frame-name}.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-pressure-sug = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите давление"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-pressure-sug in frame {&frame-name}.
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
        when {&place-dens-prov} then do :
          if v-ok then dens-prov = decimal(v-value) .
        end.
      end case.
    end.
    /*..........................................*/

    /*градуировочная таблица резервуара для ПОкМИ*/
    find last sug1_pl-level no-lock
        where sug1_pl-level.pl-code  = tt-rvs-line.pl-code
          and sug1_pl-level.obj-code = tt-rvs-line.obj-code
          and sug1_pl-level.obj-type = tt-rvs-line.obj-type
          and sug1_pl-level.pl-level <= tt-rvs-line.state-level-total
          no-error .
    if not available sug1_pl-level
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
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = sug1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = sug1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = sug1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = sug1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "tarir-delta"
                                          :      
      DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) . 
    end .   
    if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .
    
    DeltaV1 = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = sug1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = sug1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = sug1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = sug1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :      
      DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
    end .
          
    find first sug2_pl-level no-lock
        where sug2_pl-level.pl-code  = tt-rvs-line.pl-code
          and sug2_pl-level.obj-code = tt-rvs-line.obj-code
          and sug2_pl-level.obj-type = tt-rvs-line.obj-type
          and sug2_pl-level.pl-level > tt-rvs-line.state-level-total
          no-error .
    if not available sug2_pl-level
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
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = sug2_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = sug2_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = sug2_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = sug2_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :      
      DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
    end .
    
    find last full_pl-level no-lock
        where full_pl-level.pl-code  = tt-rvs-line.pl-code
          and full_pl-level.obj-code = tt-rvs-line.obj-code
          and full_pl-level.obj-type = tt-rvs-line.obj-type
          no-error .
    if not available full_pl-level
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
    DeltaOtn_K_Full = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = full_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = full_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = full_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = full_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "tarir-delta"
                                          :      
      DeltaOtn_K_Full = decimal(buf_pl-level-attr.attr-value) . 
    end .   
    if DeltaOtn_K_Full = ? then DeltaOtn_K_Full = 0.25 .
    
    DeltaVSugFull = ? .
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = full_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = full_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = full_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = full_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :      
      DeltaVSugFull = decimal(buf_pl-level-attr.attr-value) no-error . 
    end .
          
    CalibTable = Substitute("&1=&2", sug1_pl-level.pl-level, (sug1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + {&new-line} .
    CalibTable = CalibTable + Substitute("&1=&2", sug2_pl-level.pl-level, (sug2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") + {&new-line} .
    CalibTable = CalibTable + Substitute("&1=&2", full_pl-level.pl-level, (full_pl-level.pl-qnty / 1000)) + (if DeltaVSugFull > 0 then ("=" + trim(string(DeltaVSugFull, ">>9.9999"))) else "") .
    
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
            DeltaAbs_H             = buf_sr-izmerenia.sr-abs-err-neft-water
            DeltaAbs_H_Water       = buf_sr-izmerenia.sr-abs-err-water
            DeltaAbs_R_liquid         = buf_sr-izmerenia.sr-abs-err-dens-lgas-liquid
            DeltaAbs_R_gas   = buf_sr-izmerenia.sr-abs-err-dens-lgas-vapor
            DeltaOtn_R             = buf_sr-izmerenia.sr-relative-err-dens
            Use_DeltaOtn_R_liquid_IN = buf_sr-izmerenia.sr-relative-err-dens-lgas-liquid <> ?
            DeltaOtn_R_liquid_IN     = buf_sr-izmerenia.sr-relative-err-dens-lgas-liquid
            DeltaOtn_N             = 0.05
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
/*        message                                                                                                            */
/*          substitute ("Для складского места &1 не заданно дополнительное средство измерения плотности",tt-rvs-line.pl-code)*/
/*        view-as alert-box error.                                                                                           */
/*        undo _trpomi, return no-apply.*/
      end .
      else
      if v-mi-dnst <> place-si 
      or not available buf_sr-izmerenia
      then do :
        find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst no-error.
        if not available dens_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ "
          substitute( 'Не найдено средство измерения с кодом &1', pl-dens-sr-izm ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply.
        end.
        else do :
/*          BTS-146                                                                                                                                                                               */
/*          message 'Для показателя "Плотность" настройки вспомогательного средства измерения не применяются. Применяются параметры и настройки библиотеки ПОкМИ.' view-as alert-box information .*/
/*          assign                                                           */
/*            ToolType               = dens_sr-izmerenia.sr-type-id          */
/*            DeltaAbs_R             = dens_sr-izmerenia.sr-abs-err-dens     */
/*            DeltaOtn_R             = dens_sr-izmerenia.sr-relative-err-dens*/
/*          .                                                                */
          assign
            DeltaAbs_R_liquid            = dens_sr-izmerenia.sr-abs-err-dens-lgas-liquid
            DeltaAbs_R_gas      = dens_sr-izmerenia.sr-abs-err-dens-lgas-vapor
            Use_DeltaOtn_R_liquid_IN  = dens_sr-izmerenia.sr-relative-err-dens-lgas-liquid <> ?
            DeltaOtn_R_liquid_IN      = dens_sr-izmerenia.sr-relative-err-dens-lgas-liquid
          .
        end.
      end .
/*      BTS-146                   */
/*      DeltaAbs_R_liquid       = 0 .*/
/*      DeltaAbs_R_gas = 0 .*/
    end .
    
/*    if pl-rvd-temp                                                                                                           */
/*    then do :                                                                                                                */
/*      if pl-temp-sr-izm = 0                                                                                                  */
/*      or pl-temp-sr-izm = ?                                                                                                  */
/*      then do :                                                                                                              */
/*        message                                                                                                              */
/*          substitute ("Для складского места &1 не заданно дополнительное средство измерения температуры",tt-rvs-line.pl-code)*/
/*        view-as alert-box error.                                                                                             */
/*        undo _trpomi, return no-apply.                                                                                       */
/*      end .                                                                                                                  */
/*      else                                                                                                                   */
/*      if pl-temp-sr-izm <> place-si                                                                                          */
/*      or not available buf_sr-izmerenia                                                                                      */
/*      then do :                                                                                                              */
/*        find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = pl-temp-sr-izm no-error.                    */
/*        if not available temp_sr-izmerenia then do :                                                                         */
/*          message                                                                                                            */
/*          "Ошибка работы с библиотекой ПОкМИ"                                                                                */
/*          substitute( 'Не найдено средство измерения с кодом &1', pl-temp-sr-izm ) skip                                      */
/*          view-as alert-box error.                                                                                           */
/*          undo _trpomi, return no-apply.                                                                                     */
/*        end.                                                                                                                 */
/*        else do :                                                                                                            */
/*          assign                                                                                                             */
/*            DeltaAbs_Tv            = temp_sr-izmerenia.sr-abs-err-temp-vol                                                   */
/*            DeltaAbs_Tr            = temp_sr-izmerenia.sr-abs-err-temp-dens                                                  */
/*          .                                                                                                                  */
/*        end.                                                                                                                 */
/*      end .                                                                                                                  */
/*    end .                                                                                                                    */
    
/*    if available level_sr-izmerenia                               */
/*    then                                                          */
/*      LevelToolType = level_sr-izmerenia.sr-type-level-measuring .*/
/*    else                                                          */
/*      LevelToolType = buf_sr-izmerenia.sr-type-level-measuring .  */
    
    if DeltaAbs_H       = ? then DeltaAbs_H = 0 .
    if DeltaAbs_H_Water = ? then DeltaAbs_H_Water = 0 .
    if DeltaAbs_R_liquid   = ? then DeltaAbs_R_liquid = 0 .
    if DeltaAbs_R_gas   = ? then DeltaAbs_R_gas = 0 .
    if DeltaAbs_Tv      = ? then DeltaAbs_Tv = 0 .
    if DeltaAbs_Tr      = ? then DeltaAbs_Tr = 0 .
    if DeltaOtn_N       = ? then DeltaOtn_N = 0 .
    if DeltaOtn_H       = ? then DeltaOtn_H = 0 .
    if DeltaOtn_H_Water = ? then DeltaOtn_H_Water = 0 .
    if DeltaOtn_R       = ? then DeltaOtn_R = 0 .
    if LevelToolType    = ? then LevelToolType = 0 .
    if A_LevelMeasurementTool = ? then A_LevelMeasurementTool = 0 .
    if Use_DeltaOtn_R_liquid_IN = ? then Use_DeltaOtn_R_liquid_IN = false.
    if DeltaOtn_R_liquid_IN = ? then DeltaOtn_R_liquid_IN = 0.
    
    /*..........................................*/

    /*метод применяемый к данному типу резервуара и */
    find first buf_place no-lock
         where buf_place.obj-code = tt-rvs-line.obj-code
           and buf_place.obj-type = tt-rvs-line.obj-type
           and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
    v-proc = "CMethodOfMetering53" .
    /*..............................................*/
    
    MM53
      (input tt-rvs-line.state-level-total * 10,
       input CalibTable,
       input tt-rvs-line.state-temperature,
       input tt-rvs-line.state-density * 1000,
       input tt-rvs-line.state-dens-pf-sug * 1000,
       input A_Reservoir,
       input DeltaOtn_K,
       input DeltaOtn_K, /* DeltaOtn_K_Full */
       input DeltaAbs_H,
       input DeltaAbs_R_liquid,
       input DeltaAbs_R_gas,
       input (if Use_DeltaOtn_R_liquid_IN then -1 else 0),
       input DeltaOtn_R_liquid_IN,
       input DeltaOtn_N,
       input 1, /* Round_M */
       input 2, /* Round_T */
       input 2, /* Round_R */
       
       output C_HN,
       output C_HN_delta,
       output C_full,
       output V_liquid,
       output V_gas,
       output M_liquid,
       output M_gas,
       output M,
       output Kf,
       output DeltaOtn_H,
       output DeltaOtn_R_liquid,
       output DeltaOtn_R_gas,
       output DeltaOtn_M_liquid,
       output DeltaOtn_M_gas,
       output DeltaOtn_M,
       output H_min_liquid,
       output H_min,
       output A,
       output B,
       
       output vErr,
       output vWrn,
       output vDllVersion)
    no-error .

    assign varstate-water-qnty .

    OUTPUT stream outstream to value ("pomi.log") append.
            PUT STREAM outstream unformatted
            "    " SKIP
            "    " SKIP
            cur-time-string()           FORMAT "x(16)"    SKIP
            'Процедура             '                 v-proc                      FORMAT "x(128)"   SKIP
            'Версия dll: '              v-pokmi-dll-version                              SKIP
            'CODE_PL                = ' tt-rvs-line.pl-code                           SKIP
            'H                      = ' tt-rvs-line.state-level-total * 10                    SKIP
            'CalibrationTable       = ' CalibTable                    SKIP
            'T                      = ' tt-rvs-line.state-temperature               SKIP
            'R_liquid               = ' trim(string(tt-rvs-line.state-density * 1000, ">>>9.9<"))                         SKIP
            'R_gas                  = ' trim(string(tt-rvs-line.state-dens-pf-sug * 1000, ">>>9.9<"))        SKIP
            'A_Reservoir            = ' A_Reservoir                                   SKIP
            'DeltaOtn_K             = ' DeltaOtn_K                                    SKIP
            'DeltaOtn_K_Full        = ' DeltaOtn_K_Full                               SKIP
            'DeltaAbs_H             = ' DeltaAbs_H                                    SKIP
            'DeltaAbs_R_liquid      = ' DeltaAbs_R_liquid                             SKIP
            'DeltaAbs_R_gas         = ' DeltaAbs_R_gas                                SKIP
            'DeltaOtn_N             = ' DeltaOtn_N                                    SKIP
            'Use_DeltaOtn_R_liquid_IN = ' Use_DeltaOtn_R_liquid_IN                    SKIP
            'DeltaOtn_R_liquid_IN     = ' DeltaOtn_R_liquid_IN                        SKIP
            'Round_M                = ' 1                                   SKIP
            'Round_T                = ' 2                                   SKIP
            'Round_R                = ' 2                                   SKIP
    .
    
    output stream outstream close.
    if trim(vErr) > "" then do :
      error-string = substitute("~nРезервуар: &1.~n", buf_place.loc1) + replace(vErr,";0x","~n0x") .
      output stream outstream to value ("pomi.log")  append.
      put stream outstream error-string format "X(1024)" skip.
      message
      substitute('Ошибка работы библиотеки ПОкМИ. &1',error-string)
      view-as alert-box error.
      output stream outstream close.
      undo _trpomi, return no-apply .
    end.
    else do :

      if C_HN = 0 then
      do:
        error-string = "Ошибка входного параметра CalibrationTable. Библеотека ПОкМИ вернула C_HN = 0." .
        output stream outstream to value ("pomi.log")  append.
        put stream outstream error-string skip.
        message
          substitute('Ошибка входных параметров в библиотеку ПОкМИ.~n &1',error-string)
          view-as alert-box error
        .
        output stream outstream close.
        undo _trpomi, return no-apply .
      end.      
        
      assign 
        tt-rvs-line.state-measure-qnty      = V_liquid * 1000 
        tt-rvs-line.state-measure-tc-qnty   = V_liquid * 1000 
        tt-rvs-line.state-vol-pf-sug        = V_gas * 1000 
        tt-rvs-line.state-measure-cli-qnty  = M
      .
      
      assign
        tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty * tt-rvs-line.state-density  
        tt-rvs-line.fact-sum-vol = tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty 
        tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty 
        varstate-sum-vol = input frame {&frame-name} varstate-water-qnty + tt-rvs-line.state-measure-qnty 
      .
      
      abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 .
      
      tt-rvs-line.state-brutto-qnty = tt-rvs-line.fact-sum-vol .
      tt-rvs-line.state-brutto-cli-qnty  = tt-rvs-line.state-brutto-qnty * tt-rvs-line.state-density .
      
      if  tt-rvs-line.state-measure-cli-qnty > 200000 then delta-mass-qnty = 0.5 . else delta-mass-qnty = 0.65. 
      
      abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
      
      display
      delta-mass-qnty
      tt-rvs-line.state-density
      tt-rvs-line.state-measure-cli-qnty
      tt-rvs-line.state-measure-qnty
      tt-rvs-line.fact-sum-vol
      tt-rvs-line.fact-sum-mass
      tt-rvs-line.fact-calc-add-mass
      tt-rvs-line.state-vol-pf-sug
      abs-delta-mass-add-qnty
      abs-delta-mass-qnty
      varstate-sum-vol
       with frame {&frame-name} .
      output stream outstream to value ("pomi.log")  append.
      put stream outstream unformatted
        "C_HN              = " C_HN    skip
        "C_HN_delta        = " C_HN_delta          skip 
        "C_full            = " C_full SKIP
        "V_liquid          = " V_liquid  SKIP
        "V_gas             = " V_gas   SKIP 
        "M_liquid          = " M_liquid  SKIP
        "M_gas             = " M_gas  SKIP
        "M                 = " M   SKIP
        "Kf                = " Kf  SKIP
        "DeltaOtn_H        = " DeltaOtn_H SKIP
        "DeltaOtn_R_liquid = " DeltaOtn_R_liquid  SKIP
        "DeltaOtn_R_gas    = " DeltaOtn_R_gas  SKIP
        "DeltaOtn_M_liquid = " DeltaOtn_M_liquid SKIP
        "DeltaOtn_M_gas    = " DeltaOtn_M_gas  SKIP
        "DeltaOtn_M        = " DeltaOtn_M  SKIP
        "H_min_liquid      = " H_min_liquid  SKIP
        "H_min             = " H_min  SKIP
        "A                 = " A  SKIP
        "B                 = " B  SKIP SKIP
        "Warnings          = " vWrn   SKIP
      .
      output stream outstream close.
      
      assign
        v-POkMI-result-attr = 
          "Общая масса СУГ, кг: " + string(M, "->>,>>>,>>9.9":U) + {&new-line} +
          "Относительная погрешность измерения массы СУГ, %: "  + string(DeltaOtn_M, ">>>>>>>9.99") + {&new-line} +
          "Объем ЖФ СУГ, л: " + string((V_liquid * 1000), "->>,>>>,>>9":U) + {&new-line} +
          "Объем ПФ СУГ, л: " + string((V_gas * 1000), "->>,>>>,>>9":U) + {&new-line}
          
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
      if error-status :error then do :
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
  rvs-line-attr.attr-value = "yes" .
  release rvs-line-attr no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-rez
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rez Dialog-Frame
ON CHOOSE OF b-rez IN FRAME Dialog-Frame /* Отмена */
DO:
  if twice-place-data > ""
  then do :
    message twice-place-data view-as alert-box information .
  end.
  else do :
    message "Нет данных" view-as alert-box .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sug-struct
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sug-struct Dialog-Frame
ON CHOOSE OF b-sug-struct IN FRAME Dialog-Frame /* Состав СУГ */
DO:
  define variable v-out-dens    as decimal no-undo .
  define variable v-out-dens-pf as decimal no-undo .
  define variable vOk           as logical no-undo .
  
  if tt-rvs-line.state-temperature = ?
  then do :
    message "Введите температуру!" view-as alert-box .
    return no-apply .
  end .
  
  if tt-rvs-line.state-pressure-sug = ?
  then do :
    message "Введите давление!" view-as alert-box .
    return no-apply .
  end .
  
  run str/rvs-lin-sug-struct.w (input tt-rvs-line.obj-type,
                                input tt-rvs-line.obj-code,
                                input tt-rvs-line.pl-code,
                                input tt-rvs-line.gds-code,
                                input tt-rvs-line.rvs-code,
                                input tt-rvs-line.state-temperature,
                                input tt-rvs-line.state-pressure-sug,
                                output v-out-dens,
                                output v-out-dens-pf,
                                output vOk)
                                .
  if vOk
  then do :
    assign
      tt-rvs-line.state-density     = v-out-dens
      tt-rvs-line.state-dens-pf-sug = v-out-dens-pf
    .
    assign v-hand-input-dnst = true .
    
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
    
    display tt-rvs-line.state-density tt-rvs-line.state-dens-pf-sug with frame Dialog-Frame .
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
  
  define variable v-rvd-reason   as character no-undo .
  define variable v-ITSM-num     as character no-undo .
  define variable v-oper-fio     as character no-undo .
    
  define buffer olddens-rvs-line-attr for ub.rvs-line-attr .
  define variable v-is-olddens as logical no-undo initial no .
  
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
  
  if tt-rvs-line.state-measure-qnty > tt-rvs-line.state-brutto-qnty
  then do:
     message "Объем топлива больше общего объема."
     view-as alert-box error.
     apply "entry" to tt-rvs-line.state-measure-qnty in frame {&frame-name}.
     return no-apply.
  end.
  
  
  if rdc-value = "pomi-rn"
  and b-calc:sensitive
  then do :
/*    if tt-rvs-line.izmer-density = ? or tt-rvs-line.izmer-density = 0         */
/*    then do :                                                                 */
/*      message "Сохранение введенных параметров НП невозможно." skip (1)       */
/*              "Плотность НП унаследована у предыдущего документа сверки." skip*/
/*              'Введите измеренную плотность и нажмите кнопку "Рассчитать".'   */
/*      view-as alert-box information.                                          */
/*      apply "entry" to tt-rvs-line.izmer-density in frame {&frame-name}.      */
/*      return no-apply.                                                        */
/*    end.                                                                      */
    
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "is-calc" no-error.
    if not available rvs-line-attr
    or (available rvs-line-attr and rvs-line-attr.attr-value <> "yes") 
    then do :
      message "Сохранение введенных параметров СУГ невозможно." skip (1)
              "Не выполнено приведение параметров СУГ к стандартной температуре." skip
              'Нажмите кнопку "Рассчитать" и повторите попытку.'
      view-as alert-box information.
      apply "entry" to b-calc in frame {&frame-name}.
      return no-apply.
    end.  
  end.    

/*  assign                                                                                                                                    */
/*    v-water     = input frame {&frame-name} tt-rvs-line.state-brutto-qnty - input frame {&frame-name} tt-rvs-line.state-measure-qnty        */
/*    v-water-cli = input frame {&frame-name} tt-rvs-line.state-brutto-cli-qnty - input frame {&frame-name} tt-rvs-line.state-measure-cli-qnty*/
/*  .                                                                                                                                         */
/*                                                                                                                                            */
/*  if ( v-water <> ?                                                                                                                         */
/*       and v-water <> 0                                                                                                                     */
/*       and ( v-water-cli = ?                                                                                                                */
/*             or v-water-cli = 0                                                                                                             */
/*           )                                                                                                                                */
/*     )                                                                                                                                      */
/*     or                                                                                                                                     */
/*     ( v-water-cli <> ?                                                                                                                     */
/*       and v-water-cli <> 0                                                                                                                 */
/*       and ( v-water = ?                                                                                                                    */
/*             or v-water = 0                                                                                                                 */
/*           )                                                                                                                                */
/*     )                                                                                                                                      */
/*  then do:                                                                                                                                  */
/*     message                                                                                                                                */
/*       substitute( "Объем воды (&1) не соответствует его весу (&2)!", v-water, v-water-cli )                                                */
/*       view-as alert-box error.                                                                                                             */
/*     return no-apply.                                                                                                                       */
/*  end.                                                                                                                                      */

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
/*  run volume-water in this-procedure               no-error.*/
/*  if error-status :error then do: return no-apply. end.*/
  run chg-density  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  run weath-water  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  assign frame {&frame-name} {&list-3}.
  assign 
    tt-rvs-line.state-brutto-qnty = tt-rvs-line.state-measure-qnty + varstate-water-qnty
    tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty + varstate-water-qnty
    tt-rvs-line.state-level-petrol = tt-rvs-line.state-level-total - tt-rvs-line.state-level-water
  .
  if not rdc-value = "pomi-rn"
  then do :
    if tt-rvs-line.state-temperature = ?
    then do :
      message "Не заполнено обязательное поле «Температура средняя»" view-as alert-box .
      return no-apply .
    end .
  end .
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
  if buf_rvs-line.temperature = ?
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
/*  find first rvs-line-attr exclusive-lock                        */
/*       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code      */
/*         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type      */
/*         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code      */
/*         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code       */
/*         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code      */
/*         and rvs-line-attr.attr-code = "mass-float-cov" no-error.*/
/*  if not available rvs-line-attr then do :                       */
/*    create rvs-line-attr.                                        */
/*    assign                                                       */
/*      rvs-line-attr.obj-code  = tt-rvs-line.obj-code             */
/*      rvs-line-attr.obj-type  = tt-rvs-line.obj-type             */
/*      rvs-line-attr.gds-code  = tt-rvs-line.gds-code             */
/*      rvs-line-attr.pl-code   = tt-rvs-line.pl-code              */
/*      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code             */
/*      rvs-line-attr.attr-code = "mass-float-cov"                 */
/*      rvs-line-attr.attr-value = string(mass-float-cov) .        */
/*    .                                                            */
/*  end.                                                           */
/*  else do :                                                      */
/*    rvs-line-attr.attr-value = string(mass-float-cov) .          */
/*  end.                                                           */

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
         and rvs-line-attr.attr-code = "vol-pf-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "vol-pf-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.vol-pf-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.vol-pf-sug) .
  end.
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "state-vol-pf-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "state-vol-pf-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.state-vol-pf-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.state-vol-pf-sug) .
  end.
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "dens-pf-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "dens-pf-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.dens-pf-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.dens-pf-sug) .
  end.
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "state-dens-pf-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "state-dens-pf-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.state-dens-pf-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.state-dens-pf-sug) .
  end.
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "pressure-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "pressure-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.pressure-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.pressure-sug) .
  end.
  
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "state-pressure-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "state-pressure-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.state-pressure-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.state-pressure-sug) .
  end.
  
  if delta-mass-qnty = ? or delta-mass-qnty > 0.65 or delta-mass-qnty <= 0 then delta-mass-qnty = 0.65 .
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
          rvs-line-attr.attr-value = string(delta-mass-qnty)
          .
  end.
  
  abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
  find first rvs-line-attr exclusive-lock
      where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      and rvs-line-attr.attr-code = "abs-delta-mass-qnty" no-error.
  if available rvs-line-attr then
  do :
      rvs-line-attr.attr-value = string(abs-delta-mass-qnty)  .
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
          rvs-line-attr.attr-code  = "abs-delta-mass-qnty"
          rvs-line-attr.attr-value = string(abs-delta-mass-qnty)
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
  
  release rvs-line-attr no-error .
  
  { gbl/ptrlprop.i
    run
    tt-rvs-line.obj-type
    tt-rvs-line.obj-code
  }

  if buf_rvs-doc.rvs-type = {&rvs-before-doc}
  then do :
    if ptrlprop-calc-free-vol-sug
    then do:
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_rvs-doc.out-code no-error .
      if available buf_trn-doc
      and buf_trn-doc.reason-code = 99
      then do :
        is-main-tank = no .
        run placelib_get-attr  ( input {&place-com-tanks}
                                ,input tt-rvs-line.obj-code
                                ,input tt-rvs-line.obj-type
                                ,input tt-rvs-line.pl-code
                                ,output v-value
                                ,output v-ok      ) no-error.
        if v-ok
        and v-value > ""
        then do :
          run placelib_get-attr  ( input {&place-is-main}
                                  ,input tt-rvs-line.obj-code
                                  ,input tt-rvs-line.obj-type
                                  ,input tt-rvs-line.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          and logical(v-value)
          then do :
            is-main-tank = yes .
          end .
        end .
        else do :
          is-main-tank = yes .
        end . 
        if is-main-tank
        then do :
          find first buf_doc-pl no-lock where buf_doc-pl.obj-type   = tt-rvs-line.obj-type
            and buf_doc-pl.obj-code   = tt-rvs-line.obj-code
            and buf_doc-pl.gds-code   = tt-rvs-line.gds-code
            and buf_doc-pl.pl-code    = tt-rvs-line.pl-code
            and buf_doc-pl.out-code   = buf_rvs-doc.out-code
            no-error .
          if not available buf_doc-pl
          then do :
            message "В накладной для товара " string(tt-rvs-line.gds-code) " нет распределения по местам хранения!" view-as alert-box .
            return no-apply .
          end .                                
          
          find first buf_place no-lock where buf_place.obj-code = tt-rvs-line.obj-code
            and buf_place.obj-type = tt-rvs-line.obj-type
            and buf_place.pl-code  = tt-rvs-line.pl-code
            no-error.
                   
          assign 
            v-free-vol = 0.85 * buf_place.max-qnty - tt-rvs-line.state-measure-qnty
          .
          
          if v-free-vol >= buf_doc-pl.fact-qnty
          then do :
            find first buf_doc-pl-attr exclusive-lock
              where buf_doc-pl-attr.obj-code  = buf_doc-pl.obj-code
              and buf_doc-pl-attr.obj-type  = buf_doc-pl.obj-type
              and buf_doc-pl-attr.gds-code  = buf_doc-pl.gds-code
              and buf_doc-pl-attr.pl-code   = buf_doc-pl.pl-code
              and buf_doc-pl-attr.out-code  = buf_doc-pl.out-code
              and buf_doc-pl-attr.attr-code = "free-vol-exceed" no-error.
            if available buf_doc-pl-attr
            then do :
              buf_doc-pl-attr.attr-value = string(no)  .
            end.
            else do :
              create buf_doc-pl-attr.
              assign
                buf_doc-pl-attr.obj-code   = buf_doc-pl.obj-code
                buf_doc-pl-attr.obj-type   = buf_doc-pl.obj-type
                buf_doc-pl-attr.gds-code   = buf_doc-pl.gds-code
                buf_doc-pl-attr.pl-code    = buf_doc-pl.pl-code
                buf_doc-pl-attr.out-code   = buf_doc-pl.out-code
                buf_doc-pl-attr.attr-code  = "free-vol-exceed"
                buf_doc-pl-attr.attr-value = string(no)
                .
            end.
          end .
          else do :
            run ref/message_volue.w(input string(round(buf_doc-pl.fact-qnty, 0)) ,
              input buf_place.loc1,
              input string(round(v-free-vol, 0)),
              input false) no-error .
            find first buf_doc-pl-attr exclusive-lock
              where buf_doc-pl-attr.obj-code  = buf_doc-pl.obj-code
              and buf_doc-pl-attr.obj-type  = buf_doc-pl.obj-type
              and buf_doc-pl-attr.gds-code  = buf_doc-pl.gds-code
              and buf_doc-pl-attr.pl-code   = buf_doc-pl.pl-code
              and buf_doc-pl-attr.out-code  = buf_doc-pl.out-code
              and buf_doc-pl-attr.attr-code = "free-vol-exceed" no-error.
            if available buf_doc-pl-attr then
            do :
              buf_doc-pl-attr.attr-value = string(yes)  .
            end.
            else
            do :
              create buf_doc-pl-attr.
              assign
                buf_doc-pl-attr.obj-code   = buf_doc-pl.obj-code
                buf_doc-pl-attr.obj-type   = buf_doc-pl.obj-type
                buf_doc-pl-attr.gds-code   = buf_doc-pl.gds-code
                buf_doc-pl-attr.pl-code    = buf_doc-pl.pl-code
                buf_doc-pl-attr.out-code   = buf_doc-pl.out-code
                buf_doc-pl-attr.attr-code  = "free-vol-exceed"
                buf_doc-pl-attr.attr-value = string(yes)
                .
            end.       
          end . 
        end . /* is-main-tank */
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
         
    assign v-free-vol = 0.85 * buf_place.max-qnty .
    
    if tt-rvs-line.fact-sum-vol > 0
    then do :
      if v-free-vol >= tt-rvs-line.fact-sum-vol
      then do :
        find first buf_doc-pl-attr exclusive-lock
          where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
          and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
          and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
          and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
          and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
          and buf_doc-pl-attr.attr-code = "free-vol-exceed-after" no-error.
        if available buf_doc-pl-attr
        then do :
          assign buf_doc-pl-attr.attr-value = string(no)  .
        end.
        else do :
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
      else do :
        find first buf_doc-pl-attr exclusive-lock
          where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
          and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
          and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
          and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
          and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
          and buf_doc-pl-attr.attr-code = "free-vol-exceed-after" no-error.      
        if available (buf_doc-pl-attr)
        then do :
          assign buf_doc-pl-attr.attr-value = string(yes) .
        end .
        else do :
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


  define variable v-mi-par-list      as character no-undo .
  define variable v-mi-par-list-text as character no-undo .
  define variable v-mi-old-val-list  as character no-undo .
  define variable v-mi-new-val-list  as character no-undo .
    
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
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-rvs-line.state-pressure-sug
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-pressure-sug Dialog-Frame
ON LEAVE OF tt-rvs-line.state-pressure-sug IN FRAME Dialog-Frame /* Давление */
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
/*  run volume-water no-error.                 */
/*  if error-status:error then return no-apply.*/
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


&Scoped-define SELF-NAME tt-rvs-line.state-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-density Dialog-Frame
ON LEAVE OF tt-rvs-line.state-density IN FRAME Dialog-Frame /* Плотность */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    assign tt-rvs-line.state-density .
    tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty * tt-rvs-line.state-density .
    tt-rvs-line.fact-sum-mass = tt-rvs-line.state-measure-cli-qnty + tt-rvs-line.fact-calc-add-mass .
    display tt-rvs-line.fact-sum-mass tt-rvs-line.fact-calc-add-mass with frame {&frame-name} .
    assign v-hand-input-dnst = true .
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
/*     run chg-density no-error.                  */
/*     if error-status:error then return no-apply.*/
/*     run weath-water no-error.                  */
/*     if error-status:error then return no-apply.*/
/*     if tarir-value = 'yes'                  */
/*     then do :                               */
/*       run local-tarir("state-level-total") .*/
/*     end.                                    */
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME varstate-water-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varstate-water-qnty Dialog-Frame
ON LEAVE OF varstate-water-qnty IN FRAME Dialog-Frame /* Плотность */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
     assign varstate-sum-vol = input frame {&frame-name} tt-rvs-line.state-measure-qnty + input frame {&frame-name} {&self-name} .
     display varstate-sum-vol with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-rvs-line.state-measure-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
     assign tt-rvs-line.state-measure-qnty .
     tt-rvs-line.fact-sum-vol = input frame {&frame-name} {&self-name} + input frame {&frame-name} tt-rvs-line.state-add-qnty .
     varstate-sum-vol = input frame {&frame-name} {&self-name} + (if input frame {&frame-name} varstate-water-qnty = ? then 0 else input frame {&frame-name} varstate-water-qnty) .
     display tt-rvs-line.fact-sum-vol varstate-sum-vol with frame {&frame-name}.
/*     run volume-water no-error.*/
/*     if error-status:error then return no-apply.*/
     if tt-rvs-line.state-density <> 0 and
        tt-rvs-line.state-density <> ? then do:
        run chg-density no-error.
        if error-status:error then return no-apply.
        run weath-water no-error.
        if error-status:error then return no-apply.
     end.
/*     tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty .*/
     abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 no-error .
     display  abs-delta-mass-add-qnty with frame {&frame-name}.
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


&Scoped-define SELF-NAME tt-rvs-line.state-level-water
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-level-water Dialog-Frame
ON LEAVE OF tt-rvs-line.state-level-water IN FRAME Dialog-Frame /* Факт уровень топлива */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
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
      tt-rvs-line.state-level-petrol = input frame {&frame-name} tt-rvs-line.state-level-total - input frame {&frame-name} tt-rvs-line.state-level-water .
      display tt-rvs-line.state-level-petrol with frame {&frame-name}.
/*    RUN local-tarir ("state-level-total").*/
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
/*      if v-revision-mode                                              */
/*      and v-mi-lvl > 0                                                */
/*      and v-mi-dnst > 0                                               */
/*      and v-mi-tmp > 0                                                */
/*      then                                                            */
/*        enable tt-rvs-line.state-temperature with frame {&frame-name}.*/
/*      if not v-revision-mode                                          */
/*      and v-mi-tmp > 0                                                */
/*      then                                                            */
        enable tt-rvs-line.state-temperature with frame {&frame-name}.
    end .
    if (pl-rvd-dens or v-revision-mode)
    and rdc-value = "pomi-rn"
    then do :
/*      if v-revision-mode                             */
/*      and v-mi-lvl > 0                               */
/*      and v-mi-dnst > 0                              */
/*      and v-mi-tmp > 0                               */
/*      then                                           */
/*        enable b-sug-struct with frame {&frame-name}.*/
/*      if not v-revision-mode                         */
/*      and v-mi-dnst > 0                              */
/*      then                                           */
        enable b-sug-struct with frame {&frame-name}. 
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
        disable tt-rvs-line.state-temperature with frame {&frame-name} .
        disable b-sug-struct with frame {&frame-name} .
      end .
    end .
  end .
  else do :
    if rdc-value = "pomi-rn"
    then
      disable tt-rvs-line.state-temperature with frame {&frame-name} .
    disable b-sug-struct with frame {&frame-name} .
  end .
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
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
      assign v-hand-input-lvl = true .
      run level-water in this-procedure ( input no ) /* no-error */ .
      tt-rvs-line.state-level-petrol = input frame {&frame-name} tt-rvs-line.state-level-total - input frame {&frame-name} tt-rvs-line.state-level-water .
      display tt-rvs-line.state-level-petrol with frame {&frame-name}.
/*    RUN local-tarir ("state-level-total").*/
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


&Scoped-define SELF-NAME tt-rvs-line.state-measure-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame /* Факт остаток */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
/*     run volume-water no-error.*/
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

&Scoped-define SELF-NAME tt-rvs-line.state-measure-cli-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-measure-cli-qnty Dialog-Frame
ON LEAVE OF tt-rvs-line.state-measure-cli-qnty IN FRAME Dialog-Frame /* Факт остаток */
DO:
  if input frame {&frame-name} {&self-name} <> {&self-name} then do:
    assign tt-rvs-line.state-measure-cli-qnty .
    tt-rvs-line.fact-sum-mass = tt-rvs-line.state-measure-cli-qnty + (tt-rvs-line.state-add-qnty * tt-rvs-line.state-density) .
    display tt-rvs-line.fact-sum-mass with frame {&frame-name} .
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


&Scoped-define SELF-NAME tt-rvs-line.state-temperature
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rvs-line.state-temperature Dialog-Frame
ON LEAVE OF tt-rvs-line.state-temperature IN FRAME Dialog-Frame /* Температура */
DO:
    if input frame {&frame-name} {&self-name} <> {&self-name} then do:
      assign v-hand-input-tmp = true .
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

  find first buf_rvs-doc exclusive-lock
    where buf_rvs-doc.rvs-code = tt-rvs-line.rvs-code
    .

  RUN enable_UI IN THIS-PROCEDURE.
  
  define variable str       as character no-undo .
  define variable str1      as character no-undo .
  find first rvs-line-attr exclusive-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "twice-place-data" no-error.
  if available rvs-line-attr then do :
    twice-place-data = trim(rvs-line-attr.attr-value) .
    twice-place-data = trim(twice-place-data, {&new-line}) .
    display b-rez with frame Dialog-Frame.
    enable b-rez with frame Dialog-Frame.
    assign
      str-level-total       = ""
      str-level-total-fact  = ""
      str-level-sug         = ""
      str-level-sug-fact    = ""
      str-level-water       = ""
      str-level-water-fact  = ""
      str-level-prc         = ""
    .
    find first place no-lock where place.obj-type = tt-rvs-line.obj-type
                               and place.obj-code = tt-rvs-line.obj-code
                               and place.pl-code  = tt-rvs-line.pl-code
                               no-error .
    do ii = 1 to num-entries(twice-place-data, {&new-line}) :
      str = entry(ii, twice-place-data, {&new-line}) .
      str1 = trim(entry(1, str, ":")) no-error.
      if error-status:error then next .
      if str1 = "Общий уровень"
      then do :
        str-level-total = str-level-total + "," + trim(entry(2, str, ":")) .
      end.
      if str1 = "Уровень СУГ"
      then do :
        str-level-sug = str-level-sug + "," + trim(entry(2, str, ":")) .
      end.
      if str1 = "Уровень воды"
      then do :
        str-level-water = str-level-water + "," + trim(entry(2, str, ":")) .
      end.
    end.
    assign
      str-level-total = trim(str-level-total, ",")
      str-level-total = trim(str-level-total)
      str-level-sug = trim(str-level-sug, ",")
      str-level-sug = trim(str-level-sug)
      str-level-water = trim(str-level-water, ",")
      str-level-water = trim(str-level-water)
      str-level-total-fact = str-level-total
      str-level-sug-fact = str-level-sug
      str-level-water-fact = str-level-water
    .
/*    do ii = 1 to num-entries(str-level-total):                                                                                                                                                      */
/*      str-level-prc = str-level-prc + ", " + string((decimal(trim(entry(ii,str-level-sug))) + decimal(trim(entry(ii,str-level-water))) ) / decimal(trim(entry(ii,str-level-total))), ">>>>9.<<<" ) .*/
/*    end.                                                                                                                                                                                            */
/*    assign                                                                                                                                                                                          */
/*      str-level-prc = trim(str-level-prc, ",")                                                                                                                                                      */
/*      str-level-prc = trim(str-level-prc)                                                                                                                                                           */
/*    .                                                                                                                                                                                               */
    hide
      tt-rvs-line.level-petrol
      tt-rvs-line.state-level-petrol
      tt-rvs-line.level-water
      tt-rvs-line.state-level-water
      tt-rvs-line.level-total
      tt-rvs-line.state-level-total
    in frame Dialog-Frame.
    display
      str-level-total
      str-level-total-fact
      str-level-sug
      str-level-sug-fact
      str-level-water
      str-level-water-fact
    with frame Dialog-Frame.
  end.
  else do :
    hide b-rez in frame Dialog-Frame.
    hide
      str-level-total
      str-level-total-fact
      str-level-sug
      str-level-sug-fact
      str-level-water
      str-level-water-fact
    in frame Dialog-Frame.
  end.

/*  if tt-rvs-line.system-qnty <> tt-rvs-line.orig-system-qnty              */
/*    and tt-rvs-line.system-cli-qnty <> tt-rvs-line.orig-system-cli-qnty   */
/*  then do:                                                                */
/*    assign                                                                */
/*      tt-rvs-line.orig-system-cli-qnty :label in frame Dialog-Frame = "":U*/
/*    .                                                                     */
/*  end.                                                                    */
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
     disable b-sug-struct with frame {&frame-name}.
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
        undo, return .
     end.
  end.
  
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
      RUN gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", NO, OUTPUT rdc-value, OUTPUT rdc-type) NO-ERROR.
           
      run gbl/conf-rd.p ("tarir", "", "", 0, "", "", "", no, output tarir-value, output tarir-type) no-error.
  hide
      /* ДОРАБОТКИ ПО ЛНД */
      tt-rvs-line.meas-am-qnty
      tt-rvs-line.meas-cf-qnty
      tt-rvs-line.meas-mh-qnty
      tt-rvs-line.brutto-cli-qnty
      tt-rvs-line.state-brutto-cli-qnty
      varmeasure-water-cli-qnty
      varstate-water-cli-qnty
      tt-rvs-line.brutto-qnty
      tt-rvs-line.state-brutto-qnty
      tt-rvs-line.measure-tc-qnty
      tt-rvs-line.state-measure-tc-qnty
      tt-rvs-line.measure-qnty
      tt-rvs-line.state-measure-qnty
      tt-rvs-line.izmer-density
      in frame Dialog-Frame.
  if rdc-value <>  "pomi-rn" then do :
    hide
      tt-rvs-line.izmer-density
      b-calc
      in frame Dialog-Frame.
      
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
/*            when "mass-float-cov" then do :                       */
/*              mass-float-cov = decimal(rvs-line-attr.attr-value) .*/
/*            end.                                                  */
      when "delta-mass-qnty" then do :
        delta-mass-qnty = decimal(rvs-line-attr.attr-value) .
      end.
      when "CriticalDif" then do :
        CriticalDif = decimal(rvs-line-attr.attr-value) .
      end.
      when "vol-pf-sug" then do :
        tt-rvs-line.vol-pf-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "state-vol-pf-sug" then do :
        tt-rvs-line.state-vol-pf-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "dens-pf-sug" then do :
        tt-rvs-line.dens-pf-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "state-dens-pf-sug" then do :
        tt-rvs-line.state-dens-pf-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "pressure-sug" then do :
        tt-rvs-line.pressure-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "state-pressure-sug" then do :
        tt-rvs-line.state-pressure-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "sug-water-qnty" then do :
        varmeasure-water-qnty = decimal(rvs-line-attr.attr-value) .
        varstate-water-qnty = varmeasure-water-qnty .
      end.
    end case.
  end.
  release rvs-line-attr no-error .
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
  
  find first bf_place no-lock where bf_place.obj-type = tt-rvs-line.obj-type
                               and bf_place.obj-code = tt-rvs-line.obj-code
                               and bf_place.pl-code  = tt-rvs-line.pl-code
                               .
/*  run placelib_get-attr  ( input {&place-type}         */
/*                          ,input tt-rvs-line.obj-code  */
/*                          ,input tt-rvs-line.obj-type  */
/*                          ,input tt-rvs-line.pl-code   */
/*                          ,output v-value              */
/*                          ,output v-ok      ) no-error.*/
/*  if v-ok then do :                                    */
/*    if integer(v-value) <> 1 then                      */
/*    hide                                               */
/*      mass-float-cov                                   */
/*    in frame {&frame-name}.                            */
/*  end.                                                 */
  
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
  
  assign tt-rvs-line.calc-add-mass = tt-rvs-line.add-qnty * input frame {&frame-name} tt-rvs-line.density .
  assign tt-rvs-line.sum-vol = tt-rvs-line.measure-qnty + tt-rvs-line.add-qnty .
  assign tt-rvs-line.sum-mass = tt-rvs-line.calc-add-mass + tt-rvs-line.measure-cli-qnty .
  assign varsum-vol = input frame {&frame-name} varmeasure-water-qnty + tt-rvs-line.measure-qnty .
  
  assign
    tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty * input frame {&frame-name} tt-rvs-line.state-density 
    tt-rvs-line.fact-sum-vol = tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty 
    tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty 
    tt-rvs-line.state-brutto-qnty = tt-rvs-line.fact-sum-vol
    varstate-sum-vol = input frame {&frame-name} varstate-water-qnty + tt-rvs-line.state-measure-qnty 
  .
  
  abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 .
  abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
  
  if tt-rvs-line.level-total = 0
  or tt-rvs-line.level-total = ?
  then do :
    find first place no-lock where place.obj-type = tt-rvs-line.obj-type
                               and place.obj-code = tt-rvs-line.obj-code
                               and place.pl-code  = tt-rvs-line.pl-code
                               .
    tt-rvs-line.level-total = place.max-qnty .  
    tt-rvs-line.state-level-total = tt-rvs-line.level-total .                         
  end.
  
  if tt-rvs-line.state-dens-pf-sug = ?
  or tt-rvs-line.state-dens-pf-sug = 0
  then do :
    tt-rvs-line.state-dens-pf-sug = tt-rvs-line.dens-pf-sug .
  end.
  
  if tt-rvs-line.state-pressure-sug = ?
  or tt-rvs-line.state-pressure-sug = 0
  then do :
    tt-rvs-line.state-pressure-sug = tt-rvs-line.pressure-sug .
  end.
  
  if tt-rvs-line.state-measure-qnty = tt-rvs-line.fact-sum-vol
  then do :
    tt-rvs-line.fact-sum-vol = tt-rvs-line.fact-sum-vol + tt-rvs-line.state-add-qnty .
  end.
  
  if tt-rvs-line.state-measure-cli-qnty = tt-rvs-line.state-brutto-cli-qnty
  then do :
    tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-brutto-cli-qnty + (tt-rvs-line.state-add-qnty * tt-rvs-line.state-density) .
  end.
  
  if tt-rvs-line.measure-qnty = tt-rvs-line.sum-vol
  then do :
    tt-rvs-line.sum-vol = tt-rvs-line.sum-vol + tt-rvs-line.add-qnty .
  end.
  
  if tt-rvs-line.measure-cli-qnty = tt-rvs-line.brutto-cli-qnty
  then do :
    tt-rvs-line.brutto-cli-qnty = tt-rvs-line.brutto-cli-qnty + (tt-rvs-line.add-qnty * tt-rvs-line.density) .
  end.
  
  level-prc = (tt-rvs-line.state-level-petrol + tt-rvs-line.state-level-water) / tt-rvs-line.state-level-total * 100 .

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
    abs-delta-mass-qnty
    delta-mass-qnty
    tt-rvs-line.vol-pf-sug
    tt-rvs-line.state-vol-pf-sug
    tt-rvs-line.dens-pf-sug
    tt-rvs-line.state-dens-pf-sug
    tt-rvs-line.pressure-sug
    tt-rvs-line.state-pressure-sug
    varmeasure-water-qnty
    varstate-water-qnty
    level-prc
  with frame {&frame-name}.
  
/*  if str-level-prc > ""                            */
/*  then do :                                        */
/*    hide level-prc in frame {&frame-name}.         */
/*    display str-level-prc with frame {&frame-name}.*/
/*  end.                                             */
  
  hide
    level-prc
  in frame {&frame-name}.
  
/*  run volume-measure-water in this-procedure                 no-error.*/
  run weath-measure-water  in this-procedure                 no-error.
  run level-measure-water  in this-procedure                 no-error.
/*  run volume-water         in this-procedure                 no-error.*/
  run weath-water          in this-procedure                 no-error.
  run level-water          in this-procedure ( input no ) /* no-error */ .
  
  empty temp-table tt-sug-struct .
  find first rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "sug-struct" no-error.
  if available rvs-line-attr
  then do :
    v-sug-struct-val = rvs-line-attr.attr-value .
    do ii = 1 to num-entries(v-sug-struct-val) :
      create tt-sug-struct .
      assign
        tt-sug-struct.ii = ii - 1
        tt-sug-struct.val_ = decimal(entry(ii, v-sug-struct-val))
      .
      case tt-sug-struct.ii :
        when 0  then tt-sug-struct.key_ = "метан" .
        when 1  then tt-sug-struct.key_ = "этан" .
        when 2  then tt-sug-struct.key_ = "пропан" .
        when 3  then tt-sug-struct.key_ = "н-бутан" .
        when 4  then tt-sug-struct.key_ = "и-бутан" .
        when 5  then tt-sug-struct.key_ = "н-пентан" .
        when 6  then tt-sug-struct.key_ = "и-пентан" .
        when 7  then tt-sug-struct.key_ = "н-гексан" .
        when 8  then tt-sug-struct.key_ = "н-гептан" .
        when 9  then tt-sug-struct.key_ = "н-октан" .
        when 10 then tt-sug-struct.key_ = "н-нонан" .
        when 11 then tt-sug-struct.key_ = "н-декан" .
        when 12 then tt-sug-struct.key_ = "азот" .
        when 13 then tt-sug-struct.key_ = "диоксид углерода" .
        when 14 then tt-sug-struct.key_ = "Сероводород" .
        when 15 then tt-sug-struct.key_ = "Псевдокомпонент" .
      end case .
    end .
  end .
  error-status:error = false .
 
  if rdc-value = 'pomi-rn'
  then do :
    display
      delta-mass-qnty
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
/*    disable mass-float-cov with frame {&frame-name}.*/
    disable b-calc b-sug-struct with frame {&frame-name}.
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
      tt-rvs-line.state-temperature
      tt-rvs-line.state-level-petrol
      tt-rvs-line.state-level-water
      tt-rvs-line.state-level-total
      tt-rvs-line.state-add-qnty
      varstate-water-qnty
      b-sug-struct
      b-calc
    with frame {&frame-name}.
    
    enable
      tt-rvs-line.state-measure-qnty
    with frame {&frame-name}.
    
    if bf_place.is-meas
    then do :
      disable
        tt-rvs-line.state-measure-qnty
        tt-rvs-line.state-density
        tt-rvs-line.state-measure-cli-qnty
      with frame {&frame-name}.
      if rdc-value = 'pomi-rn'
      then do :
        enable b-calc with frame {&frame-name}.
      end .
      
      if pl-rvd-dens and rdc-value = 'pomi-rn'
  /*    and tt-rvs-line.state-level-total > 0   */
      then do :
        if v-first-enter
        then do :
          tt-rvs-line.state-density = 0 .
/*          tt-rvs-line.state-temperature = ? .*/
          display tt-rvs-line.state-density tt-rvs-line.state-temperature with frame {&frame-name}.
        end .
/*        if not v-revision-mode*/
/*        and v-mi-dnst > 0     */
/*        then                  */
          enable b-sug-struct with frame {&frame-name}.
      end.
      else do :
        disable b-sug-struct with frame {&frame-name}.
      end.
      
      if pl-rvd-lvl
      then do :
        if rdc-value = 'pomi-rn'
        then do :
          if v-first-enter
          then do :
            tt-rvs-line.state-level-total = 0 .
            tt-rvs-line.state-level-water = 0 .
            display tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame {&frame-name}.
          end .
          if v-mi-lvl > 0
          then
            enable
              tt-rvs-line.state-level-total
              tt-rvs-line.state-level-water
              tt-rvs-line.state-temperature
              b-sug-struct
            with frame {&frame-name}.
        end .
        else do :
          enable
            tt-rvs-line.state-level-total
            tt-rvs-line.state-level-water
            tt-rvs-line.state-temperature
            tt-rvs-line.state-density
          with frame {&frame-name}.
        end .
      end.
      else do :
        disable tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame {&frame-name}.
      end.
      if pl-rvd-temp 
  /*    and tt-rvs-line.state-level-total > 0   */
      then do :
        if rdc-value = 'pomi-rn'
        then do :
          if v-first-enter
          then do :
            tt-rvs-line.state-temperature = ? .
            display tt-rvs-line.state-temperature with frame {&frame-name}.
          end .
/*          if not v-revision-mode                                          */
/*          and v-mi-tmp > 0                                                */
/*          then                                                            */
/*            enable tt-rvs-line.state-temperature with frame {&frame-name}.*/
        end .
        else do :
          enable tt-rvs-line.state-temperature with frame {&frame-name}.
        end .
      end.
      else do :
        disable tt-rvs-line.state-temperature with frame {&frame-name}.
      end.
    end .
    else do :
      enable
        tt-rvs-line.state-temperature
        tt-rvs-line.state-measure-qnty
        tt-rvs-line.state-density
        tt-rvs-line.state-measure-cli-qnty
      with frame {&frame-name}.
    end .
    if rdc-value = 'pomi-rn'
    then do :
      enable
        v-mi-lvl b-mi-lvl v-mi-lvl-name
        v-mi-dnst b-mi-dnst v-mi-dnst-name
        v-mi-tmp b-mi-tmp v-mi-tmp-name
      with frame Dialog-Frame.
      hide
        hide-text-dop-si
      in frame Dialog-Frame. 
      
      tt-rvs-line.state-density:fgcolor = RED_COLOR .
      tt-rvs-line.state-dens-pf-sug:fgcolor = RED_COLOR .
      tt-rvs-line.state-level-total:fgcolor = RED_COLOR .
      tt-rvs-line.state-level-water:fgcolor = RED_COLOR .
      tt-rvs-line.state-temperature:fgcolor = RED_COLOR .
      tt-rvs-line.state-pressure-sug:fgcolor = RED_COLOR .
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
  and rdc-value = 'pomi-rn'
  then do :
    assign
      tt-rvs-line.state-level-total = 0
      tt-rvs-line.state-level-water = 0
      tt-rvs-line.state-density = 0
      tt-rvs-line.state-temperature = ?
    .
    display
      tt-rvs-line.state-level-total
      tt-rvs-line.state-level-water
      tt-rvs-line.state-density
      tt-rvs-line.state-temperature
    with frame {&frame-name}.
    disable
      b-sug-struct
      tt-rvs-line.state-temperature
      tt-rvs-line.state-density
    with frame {&frame-name}.
  end .
  
  if rdc-value = 'pomi-rn'
  and parmode = {&update}
  then do :
    if v-revision-mode
    then do :
      if v-mi-lvl > 0
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
      if pl-rvd-lvl
      and v-mi-lvl > 0
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
  then do :
    enable tt-rvs-line.state-pressure-sug with frame {&frame-name}.
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
        disable tt-rvs-line.state-temperature with frame {&frame-name} .
        disable b-sug-struct with frame {&frame-name} .
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

/*assign frame {&frame-name} tt-rvs-line.state-density tt-rvs-line.state-measure-cli-qnty tt-rvs-line.state-brutto-cli-qnty .*/
/*assign                                                                                           */
/*  tt-rvs-line.state-measure-cli-qnty = tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density*/
/*  tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty + varstate-water-qnty   */
/*  tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty  * tt-rvs-line.state-density       */
/*.                                                                                                */
abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 no-error .
display tt-rvs-line.state-measure-cli-qnty tt-rvs-line.fact-calc-add-mass with frame {&frame-name}.
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
          tt-rvs-line.measure-tc-qnty tt-rvs-line.state-measure-tc-qnty
          tt-rvs-line.vol-pf-sug tt-rvs-line.state-vol-pf-sug
          tt-rvs-line.dens-pf-sug tt-rvs-line.state-dens-pf-sug
          tt-rvs-line.pressure-sug tt-rvs-line.state-pressure-sug
          tt-rvs-line.density tt-rvs-line.state-density
          tt-rvs-line.izmer-density
          tt-rvs-line.add-qnty tt-rvs-line.state-add-qnty
          tt-rvs-line.brutto-qnty tt-rvs-line.state-brutto-qnty
/*          tt-rvs-line.brutto-tc-qnty tt-rvs-line.state-brutto-tc-qnty*/
          tt-rvs-line.measure-cli-qnty tt-rvs-line.state-measure-cli-qnty
/*          tt-rvs-line.meas-cli-calc-qnty*/
          tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty
          tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol
          tt-rvs-line.level-total tt-rvs-line.state-level-total
          tt-rvs-line.level-water tt-rvs-line.state-level-water
          tt-rvs-line.temperature tt-rvs-line.state-temperature
          tt-rvs-line.meas-mh-qnty tt-rvs-line.state-mh-qnty
          tt-rvs-line.meas-am-qnty tt-rvs-line.state-am-qnty
          tt-rvs-line.meas-cf-qnty tt-rvs-line.state-cf-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help RECT-2 RECT-3 tt-rvs-line.state-measure-tc-qnty
         tt-rvs-line.state-density b-calc b-sug-struct tt-rvs-line.state-add-qnty tt-rvs-line.state-measure-cli-qnty
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
/*display input frame {&frame-name} tt-rvs-line.level-total - */
/*        input frame {&frame-name} tt-rvs-line.level-petrol @*/
/*        tt-rvs-line.level-water with frame {&frame-name}.   */
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
/*  tt-rvs-line.state-level-petrol = input frame {&frame-name} tt-rvs-line.state-level-total - input frame {&frame-name} tt-rvs-line.state-level-water .*/
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
                  display tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty + varstate-water-qnty  @ varstate-sum-vol
                      with frame {&frame-name}.
          end.
          else
          do:
              assign
                  varstate-water-qnty = bf_pl-level.pl-qnty  .
              display  varstate-water-qnty with frame {&frame-name}.
/*              display tt-rvs-line.state-brutto-qnty +  varstate-water-qnty  @ tt-rvs-line.state-brutto-qnty*/
/*              with frame {&frame-name}.                                                                    */
              display tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty + varstate-water-qnty  @ varstate-sum-vol
                      with frame {&frame-name}.
/*              DISPLAY tt-rvs-line.state-measure-qnty with frame {&frame-name} .*/
          end.
      end.  
          else do:
              assign
                  varstate-water-qnty = 0  .
              display  varstate-water-qnty with frame {&frame-name}.
                
              display tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty @ varstate-sum-vol
              with frame {&frame-name}.
/*              DISPLAY tt-rvs-line.state-measure-qnty with frame {&frame-name} .*/

          end.    

      assign
        tt-rvs-line.state-brutto-qnty = input frame {&frame-name} tt-rvs-line.state-measure-qnty + varstate-water-qnty.
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
    
    if tt-rvs-line.state-measure-cli-qnty = ?
    then do :
       tt-rvs-line.state-measure-cli-qnty = input frame {&frame-name} tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density .
       tt-rvs-line.fact-sum-mass = tt-rvs-line.state-measure-cli-qnty + tt-rvs-line.fact-calc-add-mass .
    end.
    
    varstate-sum-vol = input frame {&frame-name} tt-rvs-line.state-measure-qnty + varstate-water-qnty .
    
    display  abs-delta-mass-add-qnty  tt-rvs-line.state-measure-cli-qnty tt-rvs-line.fact-sum-mass varstate-sum-vol with frame {&frame-name}.

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
display input frame {&frame-name} tt-rvs-line.sum-vol -
        input frame {&frame-name} tt-rvs-line.measure-qnty -
        input frame {&frame-name} tt-rvs-line.add-qnty @
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
if input frame {&frame-name} tt-rvs-line.fact-sum-vol -
   input frame {&frame-name} tt-rvs-line.state-measure-qnty -
   input frame {&frame-name} tt-rvs-line.state-add-qnty <> ?
then
display input frame {&frame-name} tt-rvs-line.fact-sum-vol -
        input frame {&frame-name} tt-rvs-line.state-measure-qnty -
        input frame {&frame-name} tt-rvs-line.state-add-qnty @
        varstate-water-qnty with frame {&frame-name}.
else
if tt-rvs-line.fact-sum-vol -
   tt-rvs-line.state-measure-qnty -
   tt-rvs-line.state-add-qnty <> ?
then
display tt-rvs-line.fact-sum-vol - tt-rvs-line.state-measure-qnty - tt-rvs-line.state-add-qnty @
        varstate-water-qnty with frame {&frame-name}.        
/*        assign frame {&frame-name} tt-rvs-line.state-brutto-qnty  */
/*                                   tt-rvs-line.state-measure-qnty.*/
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
/*display input frame {&frame-name} tt-rvs-line.brutto-cli-qnty -                                           */
/*        input frame {&frame-name} tt-rvs-line.measure-cli-qnty -                                          */
/*        (input frame {&frame-name} tt-rvs-line.add-qnty * input frame {&frame-name} tt-rvs-line.density) @*/
/*        varmeasure-water-cli-qnty with frame {&frame-name}.                                               */
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

