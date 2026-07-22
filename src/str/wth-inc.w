&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR clients.
DEFINE BUFFER buf_obj FOR clients.
DEFINE BUFFER buf_wth FOR wealth.
DEFINE BUFFER buf_wth-line FOR wth-line.
DEFINE BUFFER current-place FOR wth-place.
DEFINE BUFFER first_wth-line FOR wth-line.
DEFINE BUFFER out-place FOR wth-place.
DEFINE TEMP-TABLE tt-wth-doc NO-UNDO LIKE wth-doc.
DEFINE BUFFER wth-doc FOR wth-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перемещение МЦ: добавление, изменение, просмотр

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parcli-type like ub.clients.obj-type no-undo.
define input parameter parcli-code like ub.clients.obj-code no-undo.
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo.
define input parameter par-type like ub.wth-doc.doc-type no-undo.
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as CHARACTER no-undo .

/* Local Variable Definitions ---                                        */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "перемещение МЦ: добавление, изменение, просмотр":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/chkleave.i }
{ str/shftnmef.i tt-wth-doc shift-name temp }
{ str/wthcalib.i }
{ str/attrlist.i }
{ gbl/thbjattr.i }


/* Temp-Table and Buffer definitions                                    */
define temp-table tt-wth-line  no-undo like ub.wth-line .
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
       { str/ttpardt0.i }.
define temp-table tt-wth-parts no-undo like ub.wth-parts.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

/*DEFINE SHARED QUERY BR-docs FOR wth-doc SCROLLING.*/
define buffer bf_wth-doc for ub.wth-doc.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
DEFINE VARIABLE v_rid      AS CHAR NO-UNDO.
DEFINE VARIABLE l-shift-on AS LOG  NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE locked-out as logical no-undo .
DEFINE VARIABLE locked-current as logical no-undo .
DEFINE VARIABLE locked-inter_ as logical no-undo .
DEFINE VARIABLE locked-cli  as logical no-undo .
DEFINE VARIABLE v-view-fact as logical no-undo .
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-inter AS LOGICAL NO-UNDO .
define variable parext-type-name as character no-undo.
define variable v-ref-rec as recid no-undo .

define buffer auto-wth-doc-lock_batchprocess for ub.batchprocess .
DEFINE BUFFER cli-buf         FOR ub.clients.
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_wth-par   for ub.wth-par.
define buffer bind_wth-doc  for ub.wth-doc.
define buffer bind_inkas    for ub.inkas.
define buffer buf_wth-dtl   for ub.wth-dtl.

&scope type-psnattr-view "{&bef-WDEDT_Inc_Ext},{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli},{&bef-WDEDT_exch}"
&scope type-sfattr-view "{&bef-WDEDT_Inc_Ext},{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli}"
&scope place-name-label "Название места"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-lines

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_wth-line buf_wth

/* Definitions for BROWSE BR-lines                                      */
&Scoped-define FIELDS-IN-QUERY-BR-lines buf_wth-line.wth-code buf_wth.wth-name get-place-name(buf_wth-line.obj-type, buf_wth-line.obj-code, buf_wth-line.w-p-code) buf_wth-line.doc-sum buf_wth-line.fact-sum buf_wth-line.sum-gds-rubl buf_wth-line.sum-gds-base buf_wth-line.credate buf_wth-line.creid buf_wth-line.price-rubl buf_wth-line.price-base   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-lines buf_wth-line.creid   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-lines buf_wth-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-lines buf_wth-line
&Scoped-define SELF-NAME BR-lines
&Scoped-define QUERY-STRING-BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK, ~
             EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-lines OPEN QUERY {&SELF-NAME} FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK, ~
             EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-lines buf_wth-line buf_wth
&Scoped-define FIRST-TABLE-IN-QUERY-BR-lines buf_wth-line
&Scoped-define SECOND-TABLE-IN-QUERY-BR-lines buf_wth


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wth-doc.doc-date tt-wth-doc.fact-date ~
tt-wth-doc.shift-date tt-wth-doc.shift-name tt-wth-doc.shift-num ~
tt-wth-doc.obj-code tt-wth-doc.cli-type tt-wth-doc.cli-code ~
tt-wth-doc.doc-sum tt-wth-doc.operator tt-wth-doc.deliver ~
tt-wth-doc.receiver tt-wth-doc.cli-name 
&Scoped-define ENABLED-TABLES tt-wth-doc
&Scoped-define FIRST-ENABLED-TABLE tt-wth-doc
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-bind B-prev B-next B-Help ~
r-sht for-current-w-p-code B-current B-cli for-out-w-p-code B-out ~
B-operator B-shcfact B-deliver B-receiver BR-lines B-add B-lookup B-del ~
B-chk B-bar B-barRange B-allZone B-hist for-object for-current-w-p-name ~
for-out-w-p-name operator-name deliver-name receiver-name 
&Scoped-Define DISPLAYED-FIELDS tt-wth-doc.doc-code tt-wth-doc.doc-date ~
tt-wth-doc.fact-date tt-wth-doc.shift-date tt-wth-doc.shift-name ~
tt-wth-doc.shift-num tt-wth-doc.obj-type tt-wth-doc.obj-code ~
tt-wth-doc.cli-type tt-wth-doc.cli-code tt-wth-doc.doc-sum ~
tt-wth-doc.fact-sum tt-wth-doc.sum-gds-rubl tt-wth-doc.sum-gds-base ~
tt-wth-doc.operator tt-wth-doc.deliver tt-wth-doc.receiver ~
tt-wth-doc.cli-name 
&Scoped-define DISPLAYED-TABLES tt-wth-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-wth-doc
&Scoped-Define DISPLAYED-OBJECTS for-current-w-p-code for-out-w-p-code ~
f-atrDSF f-atrNSF f-atrPaydoc f-atrReceiver f-atrproxy for-object ~
for-current-w-p-name for-out-w-p-name operator-name deliver-name ~
receiver-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-psnattr,List-4,List-5,list-attr                   */
&Scoped-define List-psnattr f-atrReceiver f-atrproxy 
&Scoped-define list-attr f-atrDSF f-atrNSF f-atrPaydoc 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-place-name Dialog-Frame 
FUNCTION get-place-name RETURNS CHARACTER
  (   INPUT p-obj-type AS CHARACTER
     ,INPUT p-obj-code AS INTEGER
     ,INPUT p-w-p-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-allZone 
     LABEL "Вся зона" 
     SIZE 10 BY 1.

DEFINE BUTTON B-bar 
     LABEL "Сканер" 
     SIZE 10 BY 1.

DEFINE BUTTON B-barRange 
     LABEL "Скан.расш." 
     SIZE 11 BY 1.

DEFINE BUTTON B-bind 
     LABEL "Свя&зать" 
     SIZE 10 BY 1.

DEFINE BUTTON B-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-chk 
     LABEL "Че&ки" 
     SIZE 10 BY 1.

DEFINE BUTTON B-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-current 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-deliver 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 10 BY 1.

DEFINE BUTTON B-lookup 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON B-next AUTO-GO 
     LABEL "&>>" 
     SIZE 4 BY 1.

DEFINE BUTTON B-operator 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-out 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3.13 BY 1.

DEFINE BUTTON B-prev AUTO-GO 
     LABEL "&<<" 
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-receiver 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-shcfact 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1 TOOLTIP "Сгенерировать номер счет-фактуры".

DEFINE BUTTON r-sht 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc" 
     SIZE 3 BY .88.

DEFINE VARIABLE deliver-name AS CHARACTER FORMAT "X(40)" 
      VIEW-AS TEXT 
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE f-atrDSF AS DATE FORMAT "99/99/9999":U 
     LABEL "Счет-фактура:  Дата" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-atrNSF AS CHARACTER FORMAT "X(256)":U 
     LABEL "№" 
     VIEW-AS FILL-IN 
     SIZE 12.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-atrPaydoc AS CHARACTER FORMAT "X(256)":U 
     LABEL "К плат.расч. док-ту" 
     VIEW-AS FILL-IN 
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE f-atrproxy AS CHARACTER FORMAT "X(256)":U 
     LABEL "Доверенность" 
     VIEW-AS FILL-IN 
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE f-atrReceiver AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE for-current-w-p-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0 
     LABEL "Место хран." 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE for-current-w-p-name AS CHARACTER FORMAT "X(20)" 
      VIEW-AS TEXT 
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)" 
      VIEW-AS TEXT 
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-out-w-p-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0 
     LABEL "Место хран." 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE for-out-w-p-name AS CHARACTER FORMAT "X(20)" 
      VIEW-AS TEXT 
     SIZE 16.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE operator-name AS CHARACTER FORMAT "X(40)" 
      VIEW-AS TEXT 
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE receiver-name AS CHARACTER FORMAT "X(40)" 
      VIEW-AS TEXT 
     SIZE 21 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-lines FOR 
      buf_wth-line, 
      buf_wth SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-lines Dialog-Frame _FREEFORM
  QUERY BR-lines NO-LOCK DISPLAY
      buf_wth-line.wth-code FORMAT ">>>>>>>>9":U
      buf_wth.wth-name FORMAT "X(40)":U
      get-place-name(buf_wth-line.obj-type, buf_wth-line.obj-code, buf_wth-line.w-p-code) FORMAT "X(20)" COLUMN-LABEL {&place-name-label}
      buf_wth-line.doc-sum FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Кол-во (док.)'
      buf_wth-line.fact-sum FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Кол-во (факт)'
      buf_wth-line.sum-gds-rubl FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Сумма по связ. тов. ({&abbr_rubl}.)'
      buf_wth-line.sum-gds-base FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Сумма по связ. тов. (б.в.)'
      buf_wth-line.credate FORMAT "99/99/99":U
      buf_wth-line.creid FORMAT "X(16)":U
      buf_wth-line.price-rubl
      buf_wth-line.price-base
  ENABLE
      buf_wth-line.creid
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.13 BY 7.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.5
     b-quit AT ROW 1 COL 11.5
     B-bind AT ROW 1 COL 21.5
     B-prev AT ROW 1 COL 31.5
     B-next AT ROW 1 COL 35.38
     B-Help AT ROW 1 COL 95
     tt-wth-doc.doc-code AT ROW 2.5 COL 6.5 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
          FGCOLOR 4 
     tt-wth-doc.doc-date AT ROW 2.5 COL 26.5 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     tt-wth-doc.fact-date AT ROW 2.5 COL 44.5 COLON-ALIGNED
          LABEL "Факт"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
          FGCOLOR 4 
     tt-wth-doc.shift-date AT ROW 2.5 COL 63.5 COLON-ALIGNED
          LABEL "Смена"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
          FGCOLOR 4 
     tt-wth-doc.shift-name AT ROW 2.5 COL 77 COLON-ALIGNED
          LABEL "№" FORMAT "X(5)"
          VIEW-AS FILL-IN 
          SIZE 5.5 BY 1
          FGCOLOR 4 
     tt-wth-doc.shift-num AT ROW 2.5 COL 87 COLON-ALIGNED
          LABEL "П."
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
          FGCOLOR 4 
     r-sht AT ROW 2.5 COL 93 WIDGET-ID 24
     tt-wth-doc.obj-type AT ROW 4 COL 13.5 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1" 
          DROP-DOWN-LIST
          SIZE 6.38 BY 1
     tt-wth-doc.obj-code AT ROW 4 COL 20.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     for-current-w-p-code AT ROW 4 COL 67 COLON-ALIGNED
     B-current AT ROW 4 COL 79.63
     tt-wth-doc.cli-type AT ROW 5.25 COL 13.5 COLON-ALIGNED
          LABEL "Контрагент"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1" 
          DROP-DOWN-LIST
          SIZE 6.38 BY 1
     tt-wth-doc.cli-code AT ROW 5.25 COL 20.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     B-cli AT ROW 5.25 COL 33
     for-out-w-p-code AT ROW 5.33 COL 67 COLON-ALIGNED
     B-out AT ROW 5.33 COL 79.63
     tt-wth-doc.doc-sum AT ROW 6.75 COL 21.5 COLON-ALIGNED
          LABEL "Кол-во по документу"
          VIEW-AS FILL-IN 
          SIZE 17.5 BY 1
          FGCOLOR 4 
     tt-wth-doc.fact-sum AT ROW 6.75 COL 67 COLON-ALIGNED
          LABEL "Кол-во факт"
          VIEW-AS FILL-IN 
          SIZE 18.38 BY 1
          FGCOLOR 4 
     tt-wth-doc.sum-gds-rubl AT ROW 7.75 COL 21.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Сумма по тов." FORMAT "->,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 17.5 BY 1
          FGCOLOR 4 
     tt-wth-doc.sum-gds-base AT ROW 7.75 COL 67 COLON-ALIGNED WIDGET-ID 4
          LABEL "Сумма по тов.(баз.вал)" FORMAT "->>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 18.38 BY 1
          FGCOLOR 4 
     tt-wth-doc.operator AT ROW 9.5 COL 10.5 COLON-ALIGNED
          LABEL "Составил"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     B-operator AT ROW 9.5 COL 23
     f-atrDSF AT ROW 9.5 COL 67 COLON-ALIGNED WIDGET-ID 12
     f-atrNSF AT ROW 9.5 COL 82 COLON-ALIGNED WIDGET-ID 10
     B-shcfact AT ROW 9.5 COL 96.5 WIDGET-ID 14
     B-deliver AT ROW 10.5 COL 23
     tt-wth-doc.deliver AT ROW 10.54 COL 10.5 COLON-ALIGNED
          LABEL "Отпустил"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     f-atrPaydoc AT ROW 10.54 COL 67 COLON-ALIGNED WIDGET-ID 18
     tt-wth-doc.receiver AT ROW 11.54 COL 10.5 COLON-ALIGNED
          LABEL "Получил"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     B-receiver AT ROW 11.54 COL 23
     f-atrReceiver AT ROW 11.58 COL 10.5 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     f-atrproxy AT ROW 11.58 COL 67 COLON-ALIGNED WIDGET-ID 22
     BR-lines AT ROW 12.75 COL 1
     B-add AT ROW 20.33 COL 1
     B-lookup AT ROW 20.33 COL 11
     B-chg AT ROW 20.33 COL 21
     B-del AT ROW 20.33 COL 31
     B-chk AT ROW 20.33 COL 41
     B-bar AT ROW 20.33 COL 51 WIDGET-ID 6
     B-barRange AT ROW 20.33 COL 61 WIDGET-ID 16
     B-allZone AT ROW 20.33 COL 72 WIDGET-ID 8
     B-hist AT ROW 20.33 COL 82
     for-object AT ROW 4 COL 34.5 COLON-ALIGNED NO-LABEL
     for-current-w-p-name AT ROW 4 COL 81.5 COLON-ALIGNED NO-LABEL
     tt-wth-doc.cli-name AT ROW 5.25 COL 34.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT 
          SIZE 19 BY 1
          FGCOLOR 4 
     for-out-w-p-name AT ROW 5.25 COL 81 COLON-ALIGNED NO-LABEL
     operator-name AT ROW 9.5 COL 24.5 COLON-ALIGNED NO-LABEL
     deliver-name AT ROW 10.5 COL 24.5 COLON-ALIGNED NO-LABEL
     receiver-name AT ROW 11.58 COL 24.5 COLON-ALIGNED NO-LABEL
     SPACE(52.37) SKIP(9.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Документ движения материальных ценностей"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_obj B "?" ? ub clients
      TABLE: buf_wth B "?" ? ub wealth
      TABLE: buf_wth-line B "?" ? ub wth-line
      TABLE: current-place B "?" ? ub wth-place
      TABLE: first_wth-line B "?" ? ub wth-line
      TABLE: out-place B "?" ? ub wth-place
      TABLE: tt-wth-doc T "?" NO-UNDO ub wth-doc
      TABLE: wth-doc B "?" ? ub wth-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-lines f-atrproxy Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-chg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-shcfact:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-doc.cli-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.cli-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-wth-doc.cli-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.deliver IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.doc-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-doc.doc-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.doc-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-atrDSF IN FRAME Dialog-Frame
   NO-ENABLE 6                                                          */
ASSIGN 
       f-atrDSF:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-atrNSF IN FRAME Dialog-Frame
   NO-ENABLE 6                                                          */
ASSIGN 
       f-atrNSF:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-atrPaydoc IN FRAME Dialog-Frame
   NO-ENABLE 6                                                          */
ASSIGN 
       f-atrPaydoc:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-atrproxy IN FRAME Dialog-Frame
   NO-ENABLE 3                                                          */
ASSIGN 
       f-atrproxy:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-atrReceiver IN FRAME Dialog-Frame
   NO-ENABLE 3                                                          */
ASSIGN 
       f-atrReceiver:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-doc.fact-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.fact-sum IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
ASSIGN 
       tt-wth-doc.fact-sum:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-wth-doc.obj-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-doc.operator IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.receiver IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.shift-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.shift-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-wth-doc.shift-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.sum-gds-base IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
ASSIGN 
       tt-wth-doc.sum-gds-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-doc.sum-gds-rubl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
ASSIGN 
       tt-wth-doc.sum-gds-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-lines
/* Query rebuild information for BROWSE BR-lines
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,
      EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _JoinCode[1]      = "buf_wth-line.doc-code = Temp-Tables.tt-wth-doc.doc-code"
     _JoinCode[2]      = "buf_wth.wth-code = buf_wth-line.wth-code"
     _Query            is NOT OPENED
*/  /* BROWSE BR-lines */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Документ движения материальных ценностей */
DO:

/*   APPLY 'choose':U TO b-quit. */
/*   RETURN NO-APPLY.            */
  p-next-prev = "QUIT".
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
{ gbl/stdbtn.i }
  run proc-b-add in this-procedure  no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-allZone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-allZone Dialog-Frame
ON CHOOSE OF B-allZone IN FRAME Dialog-Frame /* Вся зона */
DO:
{ gbl/stdbtn.i }
  def var v-zone as char no-undo.
  run proc-save-doc in this-procedure ( input no) No-ERROR.
  if error-status:error
  or return-value = 'error'
  then return 'error'.
  assign
  v-doc-rec = recid(bf_wth-doc)
  .

  case tt-wth-doc.ext-doc-type:
    when {&WDEDT_Exp_Ext} or when {&WDEDT_Dst_Free}     then v-zone = {&free-code}.
    when {&WDEDT_Exp_Int_Put} or when {&WDEDT_Dst_Put} then v-zone = {&put-zone}.
    when {&WDEDT_Dst_Cli} or when {&WDEDT_Put_Cli} or when {&WDEDT_Exch} then v-zone = {&cli-zone}.
    otherwise do:
      message "Для данного типа документа функция ВСЯ ЗОНА не доступна." view-as alert-box.
      return no-apply.
    end.
  end case.
  define variable v_rid-list AS CHAR NO-UNDO.
  run ref/wth-ref.w (
                 input parparentproc
                ,input "b-sel,b-mark":U
                ,input tt-wth-doc.host-code
                ,input tt-wth-doc.obj-type
                ,input tt-wth-doc.obj-code
                ,input "wth-ser":U
                ,input-OUTPUT v_rid-list ) no-error.
  if error-status:error then do:
    message return-value + error-status:get-message(1) view-as alert-box error title 'Ошибка при запуске справочника МЦ'.
    return.
  end.
  if v_rid-list = "":u then return no-apply.

  run proc-allZone in this-procedure (v_rid-list
                                     ,v-zone)  no-error.
  if error-status:error then do:
    run waitfram-hide in this-procedure .
    message return-value + error-status:get-message(1) view-as alert-box error.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-bar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-bar Dialog-Frame
ON CHOOSE OF B-bar IN FRAME Dialog-Frame /* Сканер */
DO:
  run proc-save-doc in this-procedure ( input no) No-ERROR.
  if error-status:error
  or return-value = 'error'
  then return no-apply.

  run str/bar-wth.w ( input bf_wth-doc.doc-code
                       ,input for-current-w-p-code
                       ,input for-out-w-p-code ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
  END.
RUN control-doc NO-ERROR.
  {&OPEN-QUERY-BR-lines}
  apply "entry" to br-lines.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-barRange
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-barRange Dialog-Frame
ON CHOOSE OF B-barRange IN FRAME Dialog-Frame /* Скан.расш. */
DO:
  run proc-save-doc in this-procedure ( input no) No-ERROR.
  if error-status:error
  or return-value = 'error'
  then return no-apply.

  run str/barwthrg.w ( input bf_wth-doc.doc-code
                       ,input for-current-w-p-code
                       ,input for-out-w-p-code ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
  END.
RUN control-doc NO-ERROR.
  {&OPEN-QUERY-BR-lines}
  apply "entry" to br-lines.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-bind
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-bind Dialog-Frame
ON CHOOSE OF B-bind IN FRAME Dialog-Frame /* Связать */
DO:
{ gbl/stdbtn.i }
define variable rid#  AS RECID NO-UNDO.
  DEFINE VARIABLE rid-list as character no-undo.
  IF par-mode = {&lookup} THEN DO:
    RETURN NO-APPLY.
  END.
  FIND FIRST bind_wth-doc NO-LOCK WHERE
                   bind_wth-doc.doc-code = bf_wth-doc.source-ref NO-ERROR.
  IF AVAIL bind_wth-doc THEN DO:
    MESSAGE
      "Документ уже связан с документом" bf_wth-doc.source-ref "!" SKIP( 1 )
      "Вы уверены, что хотите вместо этой связи подставить новую?  "
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF glog <> YES THEN DO:
        RETURN NO-APPLY.
    END.
  END.
  rid-list = '':U.
  run str/wth-docs.w ( input parparentproc
                   ,input 'b-sel':U
                   ,input {&company}
                   ,input parhost-code
                   ,input parobj-type
                   ,input parobj-code
                   ,input  '':U
                   ,input 0
                   ,INPUT '':U
                   ,input '':U
                   ,input '':U
                   ,input-OUTPUT rid-list ).
  rid# = integer(rid-list).
  FIND FIRST bind_wth-doc NO-LOCK WHERE
                   RECID( bind_wth-doc ) = rid# NO-ERROR.
  IF AVAIL bind_wth-doc THEN DO:
    IF rid# = RECID( bf_wth-doc ) OR
      bind_wth-doc.doc-code = bf_wth-doc.doc-code THEN DO:
      MESSAGE "Нельзя связать документ с самим собой!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
    END.
    ASSIGN
    bf_wth-doc.source-ref = bind_wth-doc.doc-code
    bf_wth-doc.source-type = {&wthd-wth-doc}
    .
    ASSIGN
    B-Bind :TOOLTIP IN FRAME {&FRAME-NAME} = "Связан с " + bf_wth-doc.source-ref.
  END.
  ELSE DO:
    ASSIGN
    B-Bind :TOOLTIP IN FRAME {&FRAME-NAME} = "":U.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
{ gbl/stdbtn.i }
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
 if not avail buf_wth-line then return no-apply.
  run proc-save-doc in this-procedure ( input no) No-ERROR.
  ASSIGN
  v-line-rec = RECID( buf_wth-line )
  v-doc-rec = recid(bf_wth-doc)
  FOR-CURRENT-W-P-CODE
  FOR-OUT-W-P-CODE
  .

  if error-status:error
  or return-value = 'error'
  then return no-apply.
  run str/wth-inca.w (
                    input parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,INPUT {&update}
                   ,input v-doc-rec
                   ,input for-current-w-p-code
                   ,input for-out-w-p-code
                   ,INPUT tt-wth-doc.ext-doc-type
                   ,input-output v-LINE-REC ) .
  ASSIGN
  glog = br-lines:REFRESH( ).
RUN control-doc NO-ERROR.
  apply "entry" to br-lines.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chk Dialog-Frame
ON CHOOSE OF B-chk IN FRAME Dialog-Frame /* Чеки */
DO:
{ gbl/stdbtn.i }
  DEFINE VARIABLE loc-ref-list as character no-undo.
  DEFINE VARIABLE var-doc-code like ub.wth-doc.doc-code no-undo .
  if tt-wth-doc.borned then do:
    assign
    var-doc-code = tt-wth-doc.source-ref.
  end.
  else do:
    var-doc-code = tt-wth-doc.doc-code.
  end.
  run str/chk-docs.w (
                  input parparentproc
                 ,input '':U
                 ,input 'out-code':U
                 ,input ?
                 ,input parobj-type
                 ,input parobj-code
                 ,input var-doc-code
                 ,input '' /*d-card*/
                 ,input 0 /*p-pay-desk*/
                 ,input ? /*start-date*/
                 ,input ? /*end-date*/
                 ,input 0
                 ,output loc-ref-list) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
 define variable v_rid as character no-undo.
 define variable ref-rec as recid no-undo .

   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-type AND
            buf_clients.obj-code = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                 input parparentproc
               ,input "b-sel":U
               ,input tt-wth-doc.cli-type
               ,input {&all}
               ,input {&all}
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).

  END.
  ELSE DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  tt-wth-doc.cli-type:screen-value
               ,input {&all}
               ,input {&current}
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      CASE buf_clients.obj-type:
        when {&shop} then dO:
          find first ub.shop No-LOCK WHERE
                    ub.shop.obj-code = buf_clients.obj-code No-ERROR.
          if ub.shop.host-code <> tt-wth-doc.host-code then do:
            message "Нельзя выбрать магазин другой фирмы!"
            view-as alert-box error .
            return no-apply.
          end.
        end.
        when {&stock} then do:
          find first ub.store No-LOCK WHERE
                    ub.store.obj-code = buf_clients.obj-code No-ERROR.
          if ub.store.host-code <> tt-wth-doc.host-code then do:
            message "Нельзя выбрать склад другой фирмы!"
            view-as alert-box error .
            return no-apply.
          end.
        end.
      end CASE.
      ASSIGN
      tt-wth-doc.cli-code = buf_clients.obj-code
      tt-wth-doc.cli-type = buf_clients.obj-type
      tt-wth-doc.cli-name = buf_clients.obj-name
      .
      DISPLAY
      tt-wth-doc.cli-type
      tt-wth-doc.cli-code
      tt-wth-doc.cli-name
      WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.  /*v_rid <> ""*/
  ELSE DO:
    RETURN NO-APPLY.
  END.
  run control-out in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-current
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-current Dialog-Frame
ON CHOOSE OF B-current IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
define variable v_rid as character no-undo.
define variable ref-rec as recid no-undo .
v_rid = "":U.
/*  FIND FIRST current-place NO-LOCK WHERE
              current-place.host-code = tt-wth-doc.host-code AND
              current-place.obj-type    = tt-wth-doc.obj-type AND
              current-place.obj-code    = tt-wth-doc.obj-code AND
              current-place.w-p-code    = INPUT FRAME {&FRAME-NAME} for-current-w-p-code NO-ERROR.
  IF AVAIL current-place THEN DO:
    if tt-wth-doc.auto-fill and current-place.cash-desk = 0 then do:
      message
      "Для автоматического документа место хранения должно быть кассой"
      view-as alert-box error.
      return no-apply.
    end.
    ASSIGN
    v_rid = string(RECID( current-place ))
    .
  END.  */
  run ref/wthplref.w (
                   input parparentproc
                  ,INPUT "b-sel":U
                  ,INPUT tt-wth-doc.host-code
                  ,INPUT tt-wth-doc.obj-type
                  ,INPUT tt-wth-doc.obj-code
                  ,input {&g___object}
                  ,input-OUTPUT v_rid ).
    IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST current-place NO-LOCK WHERE
                      RECID( current-place ) = ref-rec NO-ERROR.
    IF AVAIL current-place THEN DO:
      if tt-wth-doc.auto-fill and current-place.cash-desk = 0 then do:
        message
        "Для автоматического документа место хранения должно быть кассой"
        view-as alert-box error.
        return no-apply.
      end.
      DISPLAY
      current-place.w-p-code @ for-current-w-p-code
      current-place.w-p-name @ for-current-w-p-name
       WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO: /*v_rid = ""*/
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }
 run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-deliver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-deliver Dialog-Frame
ON CHOOSE OF B-deliver IN FRAME Dialog-Frame
DO:
RUN local-psn-chk  in this-procedure ( input "deliver", input "button").
   apply "entry" to tt-wth-doc.deliver in FRAME {&FRAME-NAME}.
   return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
 run proc-save-doc in this-procedure (input (if tt-wth-doc.auto-fill then no else yes)) No-ERROR.
 if error-status:error
 or return-value = 'error'
 then return no-apply.

 p-doc-rec = v-doc-rec.
 APPLY "GO":U TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
{ gbl/stdbtn.i }
  if not avail buf_wth-line then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:

{ gbl/stdbtn.i }

/* MESSAGE buf_wth-line VIEW-AS ALERT-BOX ERROR. */
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
 if not avail buf_wth-line then return no-apply.

  ASSIGN
  v-line-rec = RECID( buf_wth-line )
  v-doc-rec = recid(bf_wth-doc)
  FOR-CURRENT-W-P-CODE
  FOR-OUT-W-P-CODE
  .
  run str/wth-inca.w (  input parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,INPUT {&lookup}
                   ,input v-doc-rec
                   ,input for-current-w-p-code
                   ,input for-out-w-p-code
                   ,INPUT tt-wth-doc.ext-doc-type
                   ,input-output v-LINE-REC ) no-error.
  if error-status:error then do:
    message return-value error-status:get-message(1) view-as alert-box.
  end.
  apply "entry" to br-lines.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
{ gbl/stdbtn.i }
     run reposition-wth-doc in this-procedure
  (input 'next':U
  ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-operator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-operator Dialog-Frame
ON CHOOSE OF B-operator IN FRAME Dialog-Frame
DO:
 RUN local-psn-chk in this-procedure ( input "operator", input "button").
   apply "entry" to tt-wth-doc.operator in FRAME {&FRAME-NAME}.
   return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-out
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-out Dialog-Frame
ON CHOOSE OF B-out IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
  define variable was_found  AS LOG  NO-UNDO.
  define variable ref-rec as recid no-undo .

  IF tt-wth-doc.cli-type = {&shop} OR
     tt-wth-doc.cli-type = {&stock} THEN DO:
    IF CAN-FIND( buf_clients NO-LOCK WHERE
         buf_clients.obj-type = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-type   AND
         buf_clients.obj-code = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-code )
    THEN DO:
      CASE INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-type :
        WHEN {&shop}  THEN DO:
          FIND FIRST ub.shop  NO-LOCK WHERE
                            ub.shop.host-code = tt-wth-doc.host-code  AND
                            ub.shop.obj-code  = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-code  NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.shop ).
        END.
        WHEN {&stock} THEN DO:
          FIND FIRST ub.store NO-LOCK WHERE
                            ub.store.host-code = tt-wth-doc.host-code AND
                            ub.store.obj-code = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-code NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.store ).
        END.
      END CASE.
    END.
  END.

  FIND FIRST out-place NO-LOCK WHERE
                    out-place.host-code = tt-wth-doc.host-code               AND
                    out-place.obj-type    = tt-wth-doc.cli-type  AND
                    out-place.obj-code    = tt-wth-doc.cli-code  AND
                    out-place.w-p-code    = INPUT FRAME {&FRAME-NAME} for-out-w-p-code NO-ERROR.
  IF AVAIL out-place THEN DO:
    ASSIGN v_rid = string(RECID( out-place ))
    .
  END.

  run ref/wthplref.w (
                   input parparentproc
                  ,INPUT "b-sel":U
                  ,INPUT tt-wth-doc.host-code
                  ,INPUT tt-wth-doc.cli-type
                  ,INPUT tt-wth-doc.cli-code
                  ,input {&g___object}
                  ,input-output v_rid ).

  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND out-place NO-LOCK WHERE
            RECID( out-place ) = ref-rec NO-ERROR.
    IF AVAIL out-place THEN DO:
      DISPLAY
      out-place.w-p-code @ for-out-w-p-code
      out-place.w-p-name @ for-out-w-p-name
      WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
{ gbl/stdbtn.i }
     run reposition-wth-doc in this-procedure
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
    IF par-mode = {&add-def} THEN DO:
    IF CAN-FIND( FIRST ub.wth-line NO-LOCK WHERE
                       ub.wth-line.doc-code = bf_wth-doc.doc-code ) THEN DO:
      MESSAGE
        "Документ не будет сохранен, а вся введенная Вами информация будет потеряна!" SKIP
        "Для того, чтобы сохранить документ, нужно нажать кнопку ~"" +
        B-exit:LABEL IN FRAME {&FRAME-NAME} + "~"." SKIP( 1 )
        "Вы уверены, что хотите выйти БЕЗ СОХРАНЕНИЯ?" SKIP
        "YES[ДА] - Выйти БЕЗ СОХРАНЕНИЯ;" SKIP
        "NO[НЕТ] - Остаться в документе."
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE "Выход из документа без сохранения" UPDATE glog.
      IF glog = NO THEN DO:
        RETURN NO-APPLY.
      END.
    END.
    DO TRANSACTION ON ERROR UNDO, LEAVE :
      FIND CURRENT bf_wth-doc EXCLUSIVE-LOCK.
      DELETE bf_wth-doc.
      p-doc-rec = ?.

    END. /* TRANSACTION */
  END.
  /* скручивание счетчика номера сч.-фактуры при отмене изменений */
  define variable v-atrValue    as character no-undo .
  define variable v-atrType     as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-param-type as character no-undo .
  define variable v-stfactpref as character no-undo .
  define variable v-numsfact   as integer no-undo .
  if f-atrNSF <> f-atrNsf:screen-value then do:
  v-atrValue =  f-atrNsf:screen-value.
  run adm/shattri.p (
        input "get":U
        ,input  tt-wth-doc.obj-type
        ,input  tt-wth-doc.obj-code
        ,input  {&attr-wthdoc_obj}
        ,input  '':U /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF not error-status:error  then do:
      for each thbjattr_thbj-attr no-lock:
        if thbjattr_thbj-attr.prop-code = {&attr-wthdoc_obj_stfactpref} then v-stfactpref = thbjattr_thbj-attr.property-value-character.
        if thbjattr_thbj-attr.prop-code = {&attr-wthdoc_obj_numsfact} then v-numsfact = thbjattr_thbj-attr.property-value-integer.
      end.
    end.
    if v-atrValue = v-stfactpref + string(v-numsfact) then do:
      v-numsfact = v-numsfact - 1.
      RUN thbjattr_write IN THIS-PROCEDURE (
            input tt-wth-doc.obj-type
          ,input tt-wth-doc.obj-code
          ,input {&attr-wthdoc_obj}
          ,input {&attr-wthdoc_obj_numsfact}
          ,input '':U
          ,input ?
          ,input 0
          ,input v-numsfact
          ,input no
      ) NO-ERROR.
      IF ERROR-STATUS:error THEN do:
        MESSAGE ERROR-STATUS:get-message(1)  SKIP
        RETURN-VALUE
        VIEW-AS ALERT-BOX warning.
        /*UNDO, RETURN ERROR. */
      END.

    end.
  end.

   p-next-prev = "QUIT".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-receiver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-receiver Dialog-Frame
ON CHOOSE OF B-receiver IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk in this-procedure ( input "receiver", input "button").
  apply "entry" to tt-wth-doc.receiver in FRAME {&FRAME-NAME}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-shcfact
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-shcfact Dialog-Frame
ON CHOOSE OF B-shcfact IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
define variable v-nsf as character no-undo.
define variable v-dsf as date no-undo.
if f-atrNsf:screen-value > '' then do:
  message
  "Номер сч.-фактуры заполнен." skip
  "Сгенерировать новый номер?"
  view-as alert-box question buttons yes-no update choice as log.
  if choice then.
  else return no-apply.
end.
run str/wthsfgen.p (
                   input tt-wth-doc.obj-type
                  ,input tt-wth-doc.obj-code
                  ,output v-nsf ) no-error.
if error-status:error then do:
  MESSAGE ERROR-STATUS:get-message(1)  SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX.
  return.
end.
f-atrNSF:screen-value = v-nsf.
v-dsf = date(f-atrdsf:screen-value) no-error.
if v-dsf = ? then f-atrdsf:screen-value = tt-wth-doc.doc-date:screen-value.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.cli-code Dialog-Frame
ON LEAVE OF tt-wth-doc.cli-code IN FRAME Dialog-Frame /* cli-code */
DO:
  assign frame {&FRAME-NAME} tt-wth-doc.cli-type
                             tt-wth-doc.cli-code.
    FIND FIRST buf_clients NO-LOCK WHERE
                buf_clients.obj-type = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-type AND
                buf_clients.obj-code = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-code NO-ERROR.
  IF AVAIL buf_clients THEN DO:
    CASE buf_clients.obj-type:
      when {&shop} then dO:
        find first ub.shop No-LOCK WHERE
                   ub.shop.obj-code = buf_clients.obj-code No-ERROR.
        if ub.shop.host-code <> tt-wth-doc.host-code then do:
          message "Нельзя выбрать магазин другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to tt-wth-doc.cli-code in frame {&frame-name}.
          return no-apply.
        end.
      end.
      when {&stock} then do:
        find first ub.store No-LOCK WHERE
                   ub.store.obj-code = buf_clients.obj-code No-ERROR.
        if ub.store.host-code <> tt-wth-doc.host-code then do:
          message "Нельзя выбрать склад другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to tt-wth-doc.cli-code in frame {&frame-name}.
          return no-apply.
        end.
      end.
      when {&cmp} then do:
            end.
    end CASE.
    DISPLAY
    buf_clients.obj-name @ tt-wth-doc.cli-name WITH FRAME {&FRAME-NAME}.
  END.
  run control-out in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.cli-type Dialog-Frame
ON VALUE-CHANGED OF tt-wth-doc.cli-type IN FRAME Dialog-Frame /* Контрагент */
DO:
  assign frame {&FRAME-NAME} tt-wth-doc.cli-type
                             tt-wth-doc.cli-code.
 run control-out in this-procedure.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-type AND
          buf_clients.obj-code = INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-code NO-ERROR.

/* if buf_clients.obj-type = {&cmp} and
    buf_Clients.obj-code = parhost-code then do:
        release buf_clients.
        display
        0 @ tt-wth-doc.cli-code
        '':U @ tt-wth-doc.cli-name WITH FRAME {&FRAME-NAME}.

 end.  */

IF AVAIL buf_clients THEN DO:
    DISPLAY
    buf_clients.obj-name @ tt-wth-doc.cli-name WITH FRAME {&FRAME-NAME}.
END.
ELSE DO:
    DISPLAY
    "":U @ tt-wth-doc.cli-name WITH FRAME {&FRAME-NAME}.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.deliver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.deliver Dialog-Frame
ON LEAVE OF tt-wth-doc.deliver IN FRAME Dialog-Frame /* Отпустил */
DO:
  if input frame {&frame-name} tt-wth-doc.deliver <> tt-wth-doc.deliver then do:
    run local-psn-chk in this-procedure ( input "deliver", input "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.deliver Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.deliver IN FRAME Dialog-Frame /* Отпустил */
OR return OF tt-wth-doc.deliver IN FRAME {&frame-name} DO:
  run local-psn-chk in this-procedure ( input "deliver", input "ret-mouse").
  apply "entry" to tt-wth-doc.deliver in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.fact-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.fact-date Dialog-Frame
ON LEAVE OF tt-wth-doc.fact-date IN FRAME Dialog-Frame /* Факт */
DO:
   run chk-upd-date in this-procedure ( input self :name ) no-error.
   if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.fact-date Dialog-Frame
ON RETURN OF tt-wth-doc.fact-date IN FRAME Dialog-Frame /* Факт */
DO:
    if tt-wth-doc.fact-date:sensitive in frame {&frame-name} then do:
    apply "entry" to tt-wth-doc.shift-date in frame {&frame-name}.
  end.
  else do:
    apply "entry" to b-add in frame {&frame-name}.
  end.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME for-current-w-p-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL for-current-w-p-code Dialog-Frame
ON LEAVE OF for-current-w-p-code IN FRAME Dialog-Frame /* Место хран. */
DO:
    FIND FIRST current-place NO-LOCK WHERE
            current-place.host-code = tt-wth-doc.host-code AND
            current-place.obj-type = tt-wth-doc.obj-type      AND
            current-place.obj-code = tt-wth-doc.obj-code      AND
            current-place.w-p-code = INPUT FRAME {&FRAME-NAME} for-current-w-p-code NO-ERROR.
  IF AVAIL current-place THEN DO:
    DISPLAY
    current-place.w-p-name @ for-current-w-p-name
    WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME for-out-w-p-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL for-out-w-p-code Dialog-Frame
ON LEAVE OF for-out-w-p-code IN FRAME Dialog-Frame /* Место хран. */
DO:
  if chkleave
    (input last-event :widget-enter /* p-widget-enter */
    ,input "b-quit,b-out":u /* p-button-list  */
    )
  then do:
    FIND FIRST out-place NO-LOCK WHERE
            out-place.host-code = tt-wth-doc.host-code AND
            out-place.obj-type = tt-wth-doc.cli-type AND
            out-place.obj-code = tt-wth-doc.cli-code AND
            out-place.w-p-code = INPUT FRAME {&FRAME-NAME} for-out-w-p-code NO-ERROR.
    IF AVAIL out-place THEN DO:
      DISPLAY
      out-place.w-p-name @ for-out-w-p-name
          WITH FRAME {&FRAME-NAME}.
    END.
    else  IF NOT AVAIL out-place AND
      int(for-out-w-p-code:screen-value) <> 0 AND
      int(for-out-w-p-code:screen-value) <> ? AND
      tt-wth-doc.doc-type <> {&return} and
      tt-wth-doc.doc-type <> {&income} and
      tt-wth-doc.exter_ = no  and
      tt-wth-doc.inter_ = no THEN DO:
      message  substitute( "Не найдено место хранения МЦ &1 в справочнике!"
                        ,for-out-w-p-code:screen-value
                      ).
     return no-apply.
    end.
    else display    "":U @ for-out-w-p-name
          WITH FRAME {&FRAME-NAME}.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.obj-type Dialog-Frame
ON VALUE-CHANGED OF tt-wth-doc.obj-type IN FRAME Dialog-Frame /* Объект */
DO:
   FIND FIRST buf_obj NO-LOCK WHERE
          buf_obj.obj-type = INPUT FRAME {&FRAME-NAME} tt-wth-doc.obj-type AND
          buf_obj.obj-code = INPUT FRAME {&FRAME-NAME} tt-wth-doc.obj-code NO-ERROR.
   IF AVAIL buf_obj THEN DO:
    DISPLAY
    buf_obj.obj-name @ for-object WITH FRAME {&FRAME-NAME}.
   END.
   ELSE DO:
        DISPLAY
        "":U @ for-object WITH FRAME {&FRAME-NAME}.
   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.operator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.operator Dialog-Frame
ON LEAVE OF tt-wth-doc.operator IN FRAME Dialog-Frame /* Составил */
DO:
  if input frame {&frame-name} tt-wth-doc.operator <> tt-wth-doc.operator then do:
    run local-psn-chk in this-procedure ( input "operator", input "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.operator Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.operator IN FRAME Dialog-Frame /* Составил */
OR return OF tt-wth-doc.operator IN FRAME {&frame-name} DO:
  run local-psn-chk in this-procedure (input "operator", input "ret-mouse").
  apply "entry" to tt-wth-doc.operator in frame {&frame-name}.
  return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sht
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sht Dialog-Frame
ON CHOOSE OF r-sht IN FRAME Dialog-Frame /* r-acc */
DO:
  run proc-sht no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.receiver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.receiver Dialog-Frame
ON LEAVE OF tt-wth-doc.receiver IN FRAME Dialog-Frame /* Получил */
DO:
  if input frame {&frame-name} tt-wth-doc.receiver <> tt-wth-doc.receiver then do:
    run local-psn-chk in this-procedure (input "receiver", input "leave").
    if  input frame {&frame-name} tt-wth-doc.receiver > 0 then do:
      hide f-AtrReceiver in  frame {&frame-name}.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.receiver Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.receiver IN FRAME Dialog-Frame /* Получил */
OR return OF tt-wth-doc.receiver IN FRAME {&frame-name} DO:
  run local-psn-chk in this-procedure (input "receiver", input "ret-mouse").
  apply "entry" to tt-wth-doc.receiver in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-lines
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
/* зацикливание формы */
on "END-ERROR":U, stop of frame {&frame-name} do:
  apply "choose" to b-quit in frame {&frame-name}.
end.

{ gbl/getcntxt.i get }
p-next-prev = '':U.
n-p: do while p-next-prev = '':U :
/* Секция триггеров обработки смены */
on leave of tt-wth-doc.shift-date in frame {&frame-name} do:
  if input frame {&frame-name} tt-wth-doc.shift-date <> tt-wth-doc.shift-date then do:
    assign
      tt-wth-doc.shift-name = ""
      tt-wth-doc.shift-num  = 0.
    display tt-wth-doc.shift-name tt-wth-doc.shift-num with frame {&frame-name}.
    apply "entry" to tt-wth-doc.shift-name in frame {&frame-name}.
    return no-apply.
  end.
end.

on return of tt-wth-doc.shift-date in frame {&frame-name} do:
  apply "entry" to tt-wth-doc.shift-name in frame {&frame-name}.
  return no-apply.
end.

on return of tt-wth-doc.shift-name in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.

on return of tt-wth-doc.shift-num in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.


on leave of tt-wth-doc.shift-num  in frame {&frame-name} do:
  if not available tt-wth-doc then return .
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

on leave of tt-wth-doc.shift-name in frame {&frame-name} do:
if not available tt-wth-doc then return .
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    if par-mode <> {&update} and par-mode <> {&add-def} and par-mode <> {&lookup} then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова par-mode"
        view-as alert-box ERROR.
        return error.
    end.
    if not par-mode = {&lookup} then
    p-next-prev = "QUIT".
    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = parhost-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = parobj-type AND
                ub.clients.obj-code = parobj-code No-ERROR.
    if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parobj-type/parobj-code"
            view-as alert-box ERROR.
            return error.
    end.

    if parcli-type <> '':U or parcli-code <> 0 then do:
        find first ub.clients No-LOCK WHERE
                    ub.clients.obj-type = parcli-type AND
                    ub.clients.obj-code = parcli-code No-ERROR.
        if not avail ub.clients then do:
            message vss-workfile vss-revision vss-description skip
                            "Неверный параметр вызова parcli-type/parcli-code"
                view-as alert-box ERROR.
                return error.
        end.
    end.
    if LOOKUP(parext-type, {&WDEDT_List}) = 0 then do:
            message vss-workfile vss-revision vss-description skip
                            "Неверный параметр вызова parext-type"
                view-as alert-box ERROR.
                return error.
    end.
    tt-wth-doc.cli-type:list-items = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char} +
                                    {&shop} + {&comma-char} +
                                    {&stock} + {&comma-char}.
    tt-wth-doc.obj-type:list-items = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char} +
                                    {&shop} + {&comma-char} +
                                    {&stock} + {&comma-char}.
  Run fill-tables no-error.
  if error-status:error then return error.
  if par-mode = {&update} then do:
    if  parobj-type <> tt-wth-doc.obj-type
    or parobj-code <> tt-wth-doc.obj-code then do:
            message vss-workfile vss-revision vss-description skip
               "Документ может быть изменен только на активной стороне!"
                view-as alert-box ERROR.
                return error.
    end.
  end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
end. /* do while */
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-upd-date Dialog-Frame 
PROCEDURE chk-upd-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter parself-name as character no-undo.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
if input frame {&frame-name} tt-wth-doc.fact-date  <> tt-wth-doc.fact-date  or
   input frame {&frame-name} tt-wth-doc.shift-date <> tt-wth-doc.shift-date or
   input frame {&frame-name} tt-wth-doc.shift-num  <> tt-wth-doc.shift-num then do:
if parself-name = "fact-date" then do:
  { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
  if input frame {&frame-name} tt-wth-doc.fact-date > v-today then do:
     message "Фактическая Дата документа не должна быть больше сегодняшней даты на объекте." view-as alert-box error.
     display tt-wth-doc.fact-date with frame {&frame-name}.
     return error.
  end.
  assign glog = no.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-doc_create-back-shift':U
    {&cntxt-object}
    tt-wth-doc.host-code
    tt-wth-doc.obj-type
    tt-wth-doc.obj-code
    0
    0
    0
    true
    glog
  }
  if glog = no then do:
     display tt-wth-doc.fact-date with frame {&frame-name}.
     return error.
  end.
/*  assign glog = no.
  message "Вы хотите изменить фактическую дату?" skip
          "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
     display tt-wth-doc.fact-date with frame {&frame-name}.
     return error.
  end.  */
end.
assign frame {&frame-name}
  tt-wth-doc.fact-date
  tt-wth-doc.shift-date
  tt-wth-doc.shift-num
  tt-wth-doc.shift-name.
assign tt-wth-doc.fact-time = (24 * 60 * 60).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-doc Dialog-Frame 
PROCEDURE control-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
tt-wth-doc.doc-sum = bf_wth-doc.doc-sum
tt-wth-doc.fact-sum = bf_wth-doc.fact-sum
tt-wth-doc.sum-gds-rubl = bf_wth-doc.sum-gds-rubl
tt-wth-doc.sum-gds-base = bf_wth-doc.sum-gds-base
.
DISPLAY
tt-wth-doc.doc-sum
tt-wth-doc.sum-gds-rubl
tt-wth-doc.sum-gds-base
tt-wth-doc.fact-sum when lookup(tt-wth-doc.ext-doc-type, {&WDEDT_dec}) = 0
with frame {&frame-name} .
run control-line in this-procedure ( output lock-doc).
run lock-proc in this-procedure (input lock-doc).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-line Dialog-Frame 
PROCEDURE control-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lock-doc as logical no-undo.
IF CAN-FIND(FIRST ub.wth-line No-LOCK WHERE
                  ub.wth-line.doc-code = tt-wth-doc.doc-code) then do:
 lock-doc = yes.
end.
else do:
 lock-doc = no.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-out Dialog-Frame 
PROCEDURE control-out :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 IF INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-type = {&prs}   OR
    INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-type = {&cmp}
    or tt-wth-doc.ext-doc-type = {&WDEDT_Put_Sale}  THEN DO:
    DISABLE
    for-out-w-p-code
    B-out
    WITH FRAME {&FRAME-NAME}.
    HIDE
    for-out-w-p-code IN FRAME {&FRAME-NAME}
    for-out-w-p-name IN FRAME {&FRAME-NAME}
    B-out    IN FRAME {&FRAME-NAME}
    .
    locked-out = yes.
  END.
  ELSE IF (INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-type = {&shop}  OR
          INPUT FRAME {&FRAME-NAME} tt-wth-doc.cli-type = {&stock})
          and not tt-wth-doc.ext-doc-type = {&WDEDT_Put_Sale} THEN DO:
    DISPLAY
    for-out-w-p-code WITH FRAME {&FRAME-NAME}.
    ENABLE
    for-out-w-p-code
    B-out
    WITH FRAME {&FRAME-NAME}.
    locked-out = no.
  END.

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
  DISPLAY for-current-w-p-code for-out-w-p-code f-atrDSF f-atrNSF f-atrPaydoc 
          f-atrReceiver f-atrproxy for-object for-current-w-p-name 
          for-out-w-p-name operator-name deliver-name receiver-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-doc THEN 
    DISPLAY tt-wth-doc.doc-code tt-wth-doc.doc-date tt-wth-doc.fact-date 
          tt-wth-doc.shift-date tt-wth-doc.shift-name tt-wth-doc.shift-num 
          tt-wth-doc.obj-type tt-wth-doc.obj-code tt-wth-doc.cli-type 
          tt-wth-doc.cli-code tt-wth-doc.doc-sum tt-wth-doc.fact-sum 
          tt-wth-doc.sum-gds-rubl tt-wth-doc.sum-gds-base tt-wth-doc.operator 
          tt-wth-doc.deliver tt-wth-doc.receiver tt-wth-doc.cli-name 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-bind B-prev B-next B-Help tt-wth-doc.doc-date 
         tt-wth-doc.fact-date tt-wth-doc.shift-date tt-wth-doc.shift-name 
         tt-wth-doc.shift-num r-sht tt-wth-doc.obj-code for-current-w-p-code 
         B-current tt-wth-doc.cli-type tt-wth-doc.cli-code B-cli 
         for-out-w-p-code B-out tt-wth-doc.doc-sum tt-wth-doc.operator 
         B-operator B-shcfact B-deliver tt-wth-doc.deliver tt-wth-doc.receiver 
         B-receiver BR-lines B-add B-lookup B-del B-chk B-bar B-barRange 
         B-allZone B-hist for-object for-current-w-p-name tt-wth-doc.cli-name 
         for-out-w-p-name operator-name deliver-name receiver-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame 
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
for each tt-wth-doc:
    delete tt-wth-doc.
end.

IF par-mode = {&add-def} then do:
   run gbl/factdate.p (
                     INPUT        parobj-type
                    ,INPUT        parobj-code
                    ,INPUT-OUTPUT f-date
                    ,INPUT-OUTPUT f-time
                    ,INPUT-OUTPUT s-date
                    ,INPUT-OUTPUT s-num
                    ,INPUT-OUTPUT s-name
                    ,INPUT        YES
                      ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      return error.
    END.
    DO TRANSACTION ON ERROR UNDO, RETURN ERROR:
      { trg/wth-docr.i tt-wth-doc par-type NO NO " " v-cntxt-userid parext-type}
      ASSIGN
      tt-wth-doc.shift-date = s-date
      tt-wth-doc.shift-num  = s-num
      tt-wth-doc.shift-name = s-name
      tt-wth-doc.doc-date   = f-date
      tt-wth-doc.fact-date  = if (lookup(tt-wth-doc.ext-doc-type,{&WDEDT_List-Ser}) > 0 and s-num <> 0) then s-date else f-date       /*Такой костыль вводится для правильного формирования отчетности на сменных объектах*/
      /*      tt-wth-doc.operator   = 0
      tt-wth-doc.receiver   = 0
      tt-wth-doc.deliver    = 0  */
      tt-wth-doc.auto-fill = parauto-fill
      .
      { trg/wth-docr.i bf_wth-doc par-type NO NO tt-wth-doc.doc-code v-cntxt-userid parext-type}
      ASSIGN
      bf_wth-doc.shift-date = s-date
      bf_wth-doc.shift-num  = s-num
      bf_wth-doc.shift-name = s-name
      bf_wth-doc.doc-date   = f-date
/*      bf_wth-doc.operator   = 0
      bf_wth-doc.receiver   = 0
      bf_wth-doc.deliver    = 0   */
      bf_wth-doc.auto-fill = parauto-fill
      v-doc-rec = recid(bf_wth-doc)
      .
      /*нет таких чеков МЦ чтобы были типа приход и внешние - автома документ */
      /*автома доку-ты МЦ приход внешние бывают только из продажи - на просмотре*/
      if parauto-fill = yes and lookup(parext-type, {&WDEDT_List-income}) > 0 and
        not (par-mode = {&lookup}) then do:
        assign
        locked-inter_ = yes
        .
      end.
    END.
/*     FIND FIRST buf_obj No-LOCK WHERe                     */
/*                 buf_obj.obj-type = parobj-type AND       */
/*                 buf_obj.obj-code = parobj-code No-ERROR. */
end.
else do:
  if par-mode = {&lookup} then do:
    FIND FIRST bf_wth-doc NO-LOCK WHERE
                recid(bf_wth-doc) = p-doc-rec.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
      FIND FIRST bf_wth-doc EXCLUSIVE-LOCK WHERE
                 recid(bf_wth-doc) = p-doc-rec.
    END.
  END.
  IF NOT AVAIL bf_wth-doc then
  return error.

  v-doc-rec = p-doc-rec.
  if bf_wth-doc.status_ = {&fact} and par-mode <> {&lookup} then do:
     message "Документ движения МЦ с N" bf_wth-doc.doc-code  "имеет статус" bf_wth-doc.status_ SKIP
                      "Изменения не допускаются"
        view-as alert-box error.
        return error.
    end.
  create tt-wth-doc.
  buffer-copy bf_wth-doc to tt-wth-doc.
/*     FIND FIRST buf_obj No-LOCK WHERe                                        */
/*                 buf_obj.obj-type = tt-wth-doc.obj-type AND                  */
/*                 buf_obj.obj-code = tt-wth-doc.obj-code No-ERROR.            */
/*     if not avail buf_obj then do:                                           */
/*       message "Документ движения МЦ N" bf_wth-doc.doc-code  skip            */
/*               "Неверный объект" bf_wth-doc.obj-type bf_wth-doc.obj-code     */
/*       view-as alert-box ERROR.                                              */
/*       return error.                                                         */
/*     end.                                                                    */
/*     FIND FIRST buf_clients No-LOCK WHERe                                    */
/*                 buf_clients.obj-type = tt-wth-doc.cli-type AND              */
/*                 buf_clients.obj-code = tt-wth-doc.cli-code No-ERROR.        */
/*     if not avail buf_clients then do:                                       */
/*       message "Документ движения МЦ N" bf_wth-doc.doc-code  skip            */
/*               "Неверный контрагент" bf_wth-doc.cli-type bf_wth-doc.cli-code */
/*       view-as alert-box ERROR.                                              */
/*       return error.                                                         */
/*     end.                                                                    */
    FIND FIRST buf_wth-line No-LOCK where
               BUF_WTH-LINE.DOC-CODE = TT-WTH-DOC.doc-code nO-ERROR.
    if avail buf_wth-line then do:
      for-current-w-p-code =  buf_wth-line.w-p-code.
      for-out-w-p-code =  buf_wth-line.out-code.
/*      find first current-place No-LOCK WHERE
                    current-place.w-p-code = buf_wth-line.w-p-code NO-ERROR.
      if avail current-place then
      assign
      for-current-w-p-code = current-place.w-p-code
      for-current-w-p-name = current-place.w-p-name
      .
      find first out-place No-LOCK WHERE
                    out-place.w-p-code = buf_wth-line.out-code NO-ERROR.
      if avail out-place then
      assign
      for-out-w-p-code = out-place.w-p-code
      for-out-w-p-name = out-place.w-p-name
      . */
    end.
    CASE tt-wth-doc.source-type:
      when {&wthd-wth-doc} then do:
        FIND FIRST bind_wth-doc NO-LOCK WHERE
                   bind_wth-doc.doc-code = tt-wth-doc.source-ref NO-ERROR.
      end.
      when {&wthd-cash-desk} then do:
        FIND FIRST bind_inkas NO-LOCK WHERE
                   bind_inkas.inkas-code = tt-wth-doc.source-ref NO-ERROR.

      end.
    END CASE.
    IF (tt-wth-doc.source-type = {&wthd-wth-doc} and AVAIL bind_wth-doc) OR
       (tt-wth-doc.source-type = {&wthd-cash-desk} and AVAIL bind_inkas)
       THEN DO:
      ASSIGN
      B-Bind:TOOLTIP
      IN FRAME {&FRAME-NAME} = "Связан с " + tt-wth-doc.source-type + {&space-char} + tt-wth-doc.source-ref.
    END.
    ELSE DO:
      ASSIGN
      B-Bind:TOOLTIP
      IN FRAME {&FRAME-NAME} = "":U.
    END.
end.

if tt-wth-doc.auto-fill = yes and par-mode <> {&lookup} then do:
  { str/lockawth.i }
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-psn-chk Dialog-Frame 
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE v-ref-rec AS RECID NO-UNDO.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "operator" and p-action = "ret-mouse" then do:
   { str/psn-chk.i operator ret-mouse tt-wth-doc v-ref-rec }
end.
if p-man = "operator" and p-action = "button" then do:
   { str/psn-chk.i operator button tt-wth-doc v-ref-rec }
end.
if p-man = "operator" and p-action = "leave" then do:
   { str/psn-chk.i operator leave tt-wth-doc v-ref-rec }
end.
if p-man = "deliver" and p-action = "ret-mouse" then do:
   { str/psn-chk.i deliver ret-mouse tt-wth-doc v-ref-rec }
end.
if p-man = "deliver" and p-action = "button" then do:
   { str/psn-chk.i deliver button tt-wth-doc v-ref-rec }
end.
if p-man = "deliver" and p-action = "leave" then do:
   { str/psn-chk.i deliver leave tt-wth-doc v-ref-rec }
end.
if p-man = "receiver" and p-action = "ret-mouse" then do:
   { str/psn-chk.i receiver ret-mouse tt-wth-doc v-ref-rec }
end.
if p-man = "receiver" and p-action = "button" then do:
   { str/psn-chk.i receiver button tt-wth-doc v-ref-rec }
end.
if p-man = "receiver" and p-action = "leave" then do:
   { str/psn-chk.i receiver leave tt-wth-doc v-ref-rec }
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lock-proc Dialog-Frame 
PROCEDURE lock-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER lock-doc as logical no-undo.

if lock-doc then do:
    DISABLE
    b-cli
    tt-wth-doc.cli-type
    tt-wth-doc.cli-code
    B-current  when for-current-w-p-code > 0
   /* tt-wth-doc.inter_    */
    B-out
    for-current-w-p-code when for-current-w-p-code > 0
    for-out-w-p-code /*when  for-out-w-p-code > 0*/
    with frame {&frame-name}
    .
    enable
    b-chg when par-mode <> {&lookup}
    b-del when par-mode <> {&lookup} and not tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-income}) > 0 and not tt-wth-doc.exter_)
    b-lookup
    B-current when for-current-w-p-code = 0 and tt-wth-doc.ext-doc-type <> {&WDEDT_Dst_Cli}
    for-current-w-p-code when for-current-w-p-code = 0 and tt-wth-doc.ext-doc-type <> {&WDEDT_Dst_Cli}
    with frame {&frame-name}
    .
end.
else do:
    ENABLE
    b-cli when (not tt-wth-doc.inter_ and not locked-cli)
    tt-wth-doc.cli-type when (not tt-wth-doc.inter_  and not locked-cli)
    tt-wth-doc.cli-code when (not tt-wth-doc.inter_  and not locked-cli)
    B-current  when  tt-wth-doc.ext-doc-type <> {&WDEDT_Dst_Cli}
    for-current-w-p-code  when  tt-wth-doc.ext-doc-type <> {&WDEDT_Dst_Cli}
    with frame {&frame-name}
    .
    disable
    b-chg
    b-del
    b-lookup
      with frame {&frame-name}
    .
    run control-out.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE v-place-name-h AS HANDLE NO-UNDO.
ASSIGN
v-place-name-h = browse br-lines:FIRST-COLUMN
.
DO WHILE VALID-HANDLE(v-place-name-h):
  IF v-place-name-h:label = {&place-name-label} THEN DO:
      LEAVE.
  END.
  v-place-name-h = v-place-name-h:NEXT-COLUMN
  .
END.
IF lookup(tt-wth-doc.ext-doc-type , {&wdedt_rcpt-gds}) = 0 THEN DO:
    ASSIGN
    v-place-name-h:VISIBLE = NO
    .

END.

assign
tt-wth-doc.sum-gds-rubl:label in frame {&frame-name} = "Сумма по тов.({&abbr_rubl}).".
if lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-write-off}) > 0
or tt-wth-doc.doc-type = {&declaration}
or tt-wth-doc.inter_ = yes
/* or tt-wth-doc.ext-doc-type = {&WDEDT_Put_Sale}*/ then  /*Если списание, клиент есть собств. фирма и изменение запрещено*/
    assign
    locked-cli = yes
    .
else     locked-cli = no.

if (tt-wth-doc.doc-type = {&income} and tt-wth-doc.inter_ = no and  not tt-wth-doc.exter_ ) then
assign v-view-fact = yes.
else v-view-fact = no.

buf_wth-line.creid:READ-ONLY IN BROWSE BR-lines = YES.
{ str/psn-chk.i operator on tt-wth-doc v-ref-rec }
{ str/psn-chk.i deliver  on tt-wth-doc v-ref-rec }
{ str/psn-chk.i receiver on tt-wth-doc v-ref-rec }
if tt-wth-doc.ext-doc-type = {&WDEDT_Put_Cli} then do:
  tt-wth-doc.deliver:label = 'Получил'.
  tt-wth-doc.receiver:label = 'Возвратил'.
end.
if tt-wth-doc.ext-doc-type = {&WDEDT_Inc_Ext} then do:
  tt-wth-doc.deliver:label = 'Получил'.
  tt-wth-doc.receiver:label = 'Отпустил'.
end.
if tt-wth-doc.doc-type = {&Write-off} then do:
  tt-wth-doc.operator:label = 'Председ.'.
  tt-wth-doc.deliver:label = 'Комиссия'.
  tt-wth-doc.receiver:label = 'Комиссия'.
end.

/*Сначала все показываем по документу. Потом триггерами на leave и value-changed показываеи имена клиентов и МХ*/

    DISPLAY
    tt-wth-doc.fact-date
    tt-wth-doc.doc-code
    tt-wth-doc.doc-date
    tt-wth-doc.shift-num
    shift-name-no-err(buffer tt-wth-doc) @ tt-wth-doc.shift-name
    tt-wth-doc.shift-date
    tt-wth-doc.obj-code
    tt-wth-doc.obj-type
    tt-wth-doc.cli-code
    tt-wth-doc.cli-type
    tt-wth-doc.fact-sum  when v-view-fact
    tt-wth-doc.doc-sum
    tt-wth-doc.operator
    tt-wth-doc.deliver
    tt-wth-doc.receiver
    tt-wth-doc.sum-gds-rubl when lookup(tt-wth-doc.ext-doc-type,{&WDEDT_List-UnSer}) = 0
    tt-wth-doc.sum-gds-base when lookup(tt-wth-doc.ext-doc-type,{&WDEDT_List-UnSer}) = 0
    for-out-w-p-code
    for-current-w-p-code  when  lookup(tt-wth-doc.ext-doc-type, {&WDEDT_Dst_Cli}) = 0
                                and
                                lookup(tt-wth-doc.ext-doc-type, {&WDEDT_rcpt-gds}) = 0
  WITH FRAME {&frame-name}.
  APPLY "VALUE-CHANGED":U TO tt-wth-doc.cli-type IN FRAME {&FRAME-NAME}.
  APPLY "VALUE-CHANGED":U TO tt-wth-doc.obj-type IN FRAME {&FRAME-NAME}.
  IF lookup(tt-wth-doc.ext-doc-type, {&WDEDT_Dst_Cli}) = 0
  and lookup(tt-wth-doc.ext-doc-type, {&WDEDT_rcpt-gds}) = 0
  then do:
  APPLY "LEAVE":U TO for-current-w-p-code IN FRAME {&FRAME-NAME}.
  END.
  APPLY "LEAVE":U TO for-out-w-p-code IN FRAME {&FRAME-NAME}.
  if lookup(tt-wth-doc.ext-doc-type, {&type-psnattr-view}) > 0
  OR lookup(tt-wth-doc.ext-doc-type, {&type-sfattr-view}) > 0 then
  run proc-init-attr no-error.
  IF par-mode = {&add-def} OR
        par-mode = {&update} THEN DO:
      IF par-mode = {&add-def} THEN DO:
        ENABLE
        tt-wth-doc.doc-date
     /*   tt-wth-doc.doc-sum when (NOT tt-wth-doc.auto-fill AND lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-income}) > 0)*/
        b-quit
        WITH FRAME {&FRAME-NAME}.
/*        HIDE
        tt-wth-doc.fact-date IN FRAME {&FRAME-NAME}
        .  */
      END.
      ELSE DO:
        IF tt-wth-doc.status_ = {&wayb}      THEN DO:
           ENABLE
            tt-wth-doc.doc-date
          /*  tt-wth-doc.doc-sum when (NOT tt-wth-doc.auto-fill AND lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-income}) > 0 )*/
            b-cli when (NOT tt-wth-doc.inter_ AND Not locked-cli)
                  WITH FRAME {&FRAME-NAME}.
            HIDE
            b-quit
            tt-wth-doc.fact-date IN FRAME {&FRAME-NAME}
            .
        END.
        ELSE IF tt-wth-doc.status_ = {&permitted} THEN DO:
     /*     HIDE
          tt-wth-doc.fact-date
          IN FRAME {&FRAME-NAME}.  */
          ENABLE
          tt-wth-doc.fact-sum  when v-view-fact
          b-chg when NOT tt-wth-doc.auto-fill
          WITH FRAME {&FRAME-NAME}.
          assign
          locked-out = yes
          locked-current = yes
          .
        END.
      END. /*update*/

      ENABLE
      b-add  when NOT tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-income}) > 0 and not tt-wth-doc.exter_)
      b-del  when not tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-income}) > 0 and not tt-wth-doc.exter_)
      b-bar  when NOT tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-income}) > 0 and not tt-wth-doc.exter_) and lookup(tt-wth-doc.ext-doc-type,{&WDEDT_List-UnSer}) = 0 and  tt-wth-doc.ext-doc-type <> {&WDEDT_exch}
      b-barRange  when NOT tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-income}) > 0 and not tt-wth-doc.exter_) and lookup(tt-wth-doc.ext-doc-type,{&WDEDT_List-UnSer}) = 0 and  tt-wth-doc.ext-doc-type <> {&WDEDT_exch}
     /* b-chg when  tt-wth-doc.auto-fill  */
      tt-wth-doc.cli-type when not locked-cli
      tt-wth-doc.cli-code when not locked-cli
      b-cli when not locked-cli
      tt-wth-doc.operator
      tt-wth-doc.deliver
      tt-wth-doc.receiver   when not lookup(tt-wth-doc.ext-doc-type, {&type-psnattr-view}) > 0
      b-operator
      B-deliver
      B-receiver
      B-exit
      b-quit
      b-lookup
      b-bind when NOT (tt-wth-doc.auto-fill)
      b-allZone when (parext-type = {&WDEDT_Exp_Ext}  or  parext-type = {&WDEDT_Exp_Int_Put} or parext-type = {&WDEDT_put_Cli} or parext-type = {&WDEDT_Dst_Put} or parext-type = {&WDEDT_Dst_Free} ) and not tt-wth-doc.auto-fill
            B-shcfact when tt-wth-doc.doc-type = {&expense} and tt-wth-doc.exter_
      WITH FRAME {&FRAME-NAME}.
      if lookup(tt-wth-doc.ext-doc-type, {&type-psnattr-view}) > 0 then
        enable {&list-psnattr}
        WITH FRAME {&FRAME-NAME}.
        f-atrReceiver:move-to-top().
      if lookup(tt-wth-doc.ext-doc-type, {&type-sfattr-view}) > 0 then  do:
        ENABLE  {&list-attr}
                 b-shcfact
        WITH FRAME {&FRAME-NAME}.
      end.
      HIDE
      b-prev IN FRAME {&FRAME-NAME}
      B-Next IN FRAME {&FRAME-NAME}
      .
      /* смены и факт даты */

          enable tt-wth-doc.fact-date /* when tt-wth-doc.auto-fill = no */
          with frame {&frame-name}.
          { gbl/objat.i
            tt-wth-doc.obj-type
            tt-wth-doc.obj-code
            "'shift-on=request'"
            glog
            no-error
          }
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при запуске процедуры objat" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            return error.
          end.
          if glog then do:
            display tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name r-sht with frame {&frame-name}.
            if tt-wth-doc.auto-fill = no then
            enable tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name
                   r-sht
            with frame {&frame-name}.
          end.


    END. /*update add-def*/
    ELSE IF par-mode = {&lookup}  THEN DO:
      assign
      b-quit:label = "&Выход"
      b-quit:col = 1
      .
      ENABLE
      B-Prev
      B-Next
      b-quit
      WITH FRAME {&FRAME-NAME}.
      HIDE
      b-exit
      b-current   IN FRAME {&FRAME-NAME}
      B-out   IN FRAME {&FRAME-NAME}
      B-cli   IN FRAME {&FRAME-NAME}
      B-operator IN FRAME {&FRAME-NAME}
      B-Deliver  IN FRAME {&FRAME-NAME}
      B-Receiver IN FRAME {&FRAME-NAME}
      .
      assign
      locked-out = yes
      locked-current = yes
      .
      if lookup(tt-wth-doc.ext-doc-type, {&type-psnattr-view}) > 0 then
        view {&list-psnattr}
        in FRAME {&FRAME-NAME}.
        f-atrReceiver:move-to-top().
      if lookup(tt-wth-doc.ext-doc-type, {&type-sfattr-view}) > 0 then  do:
        view  {&list-attr}
        in FRAME {&FRAME-NAME}.
      end.

    END.
    ENABLE
    b-help
    br-lines
    b-lookup
    b-hist when par-mode <> {&add-def}
    b-chk when tt-wth-doc.auto-fill  and  (lookup(tt-wth-doc.ext-doc-type,{&WDEDT_List-Ser}) >  0
                                           or
                                           lookup(tt-wth-doc.ext-doc-type, {&WDEDT_rcpt-wth}) >  0
                                           )
    WITH FRAME {&FRAME-NAME}.
    /*Отображаем суммы по связанным товарам  если документ не только для простых МЦ*/

    if lookup(tt-wth-doc.ext-doc-type,{&WDEDT_List-UnSer}) > 0 then do:
/*      hide
      tt-wth-doc.sum-gds-base
      tt-wth-doc.sum-gds-rubl
      in frame  {&FRAME-NAME}.   */
      buf_wth-line.sum-gds-base:visible in browse br-lines = no.
      buf_wth-line.sum-gds-rubl:visible in browse br-lines = no.
    end.
    else do:
       view
      tt-wth-doc.sum-gds-base
      tt-wth-doc.sum-gds-rubl
      in frame  {&FRAME-NAME}.
    end.
    if  v-view-fact  = yes then
    view
    tt-wth-doc.fact-sum
    in frame {&frame-name}.

    if lookup(tt-wth-doc.ext-doc-type, {&WDEDT_dec}) > 0 then do:
      HIDE
      tt-wth-doc.fact-sum
      IN FRAME {&FRAME-NAME}.
      assign
      buf_wth-line.fact-sum:visible in browse br-lines = no.
    end.

    if lookup(tt-wth-doc.ext-doc-type , {&WDEDT_Dst_Cli}) > 0
    or lookup(tt-wth-doc.ext-doc-type , {&WDEDT_rcpt-gds}) > 0
    then do:
      hide
      for-current-w-p-code
      for-current-w-p-name
      b-current
      IN FRAME {&FRAME-NAME}.
    end.

    {&OPEN-QUERY-BR-lines}

    APPLY "ENTRY":U TO br-lines IN FRAME {&FRAME-NAME}.

   run control-line in this-procedure ( output lock-doc).
   run lock-proc in this-procedure ( input lock-doc).
 /*    if not lock-doc and not par-mode = {&lookup} then
 run proc-inter in this-procedure (input tt-wth-doc.exter_) no-error. */
   parext-type-name = ENTRY(LOOKUP(tt-wth-doc.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full}) no-error.

   ASSIGN
    FRAME {&FRAME-NAME} :TITLE = substitute("Документ № &1 движения материальных ценностей - &2"
                                            ,tt-wth-doc.doc-code
                                             , CAPS(parext-type-name) ).
  VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-allZone Dialog-Frame 
PROCEDURE proc-allZone :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter v_rid-list as char no-undo.
define input parameter p-zone as character no-undo.
define variable v-ii    as integer      no-undo.
define variable v-is-parts  as logical      no-undo.
define variable parline-rec as recid no-undo.
define variable v-count    as integer      no-undo.
empty temp-table tt-wth-line.
v-count = 0.

/*FOR-CURRENT-W-P-CODE
  FOR-OUT-W-P-CODE  */
/*Резервируем партии,Заполняем временные таблицы по линиям и номиналам */
do transaction on error undo, return error return-value
               on quit undo, return
               on stop undo, return :
  do v-ii = 1 to num-entries(v_rid-list, {&comma-char})
  on error undo, next:
    v-is-parts = no.
    empty temp-table tt-wth-parts.
    empty temp-table tt-par-dtl.
    find first buf_wth no-lock where recid(buf_wth) = int(entry(v-ii,v_rid-list,{&comma-char})) .
    if can-find(first buf_wth-line where buf_wth-line.wth-code = buf_wth.wth-code
                                     and buf_wth-line.doc-code = tt-wth-doc.doc-code
               )
    then do:
      message substitute('Для МЦ &1 (код &2) уже есть линия в документе.',buf_wth.wth-name,buf_wth.wth-code) view-as alert-box.
      next.
    end.
    run waitfram-show in this-procedure ( input substitute("Создание линии для МЦ &1",buf_wth.wth-name) ).
       for each buf_wth-parts share-lock where
             buf_wth-parts.out-code = p-zone
         and buf_wth-parts.obj-code = tt-wth-doc.obj-code
         and buf_wth-parts.obj-type = tt-wth-doc.obj-type
         and  buf_wth-parts.wth-code = buf_wth.wth-code
         and (if p-zone = {&cli-zone} then (buf_wth-parts.cli-code = tt-wth-doc.cli-code
                                       and buf_wth-parts.cli-type = tt-wth-doc.cli-type)
              else buf_wth-parts.w-p-code = FOR-CURRENT-W-P-CODE
              )
        use-index  out-code
         :
         v-is-parts = yes.
         create tt-wth-parts.
         buffer-copy buf_wth-parts to tt-wth-parts
         assign tt-wth-parts.out-code = tt-wth-doc.doc-code
                tt-wth-parts.ext-doc-type = tt-wth-doc.ext-doc-type
                tt-wth-parts.shift-date = tt-wth-doc.shift-date
                tt-wth-parts.shift-num = tt-wth-doc.shift-num
                tt-wth-parts.obj-type = tt-wth-doc.obj-type
                tt-wth-parts.obj-code = tt-wth-doc.obj-code
                tt-wth-parts.w-p-code = FOR-CURRENT-W-P-CODE
         .
    end. /*parts*/
    if v-is-parts = no
    then next.
    /*Если есть партии запускаем процедуру резервирования */
    run trg/wthrspt.p (input table tt-wth-parts
                      ,input no ) no-error.
    if error-status:error then do:
      message return-value + error-status:get-message(1) view-as alert-box error.
      undo, next.
    end.
   /*создание детализации по номиналам*/
    for each buf_wth-par no-lock where
             buf_wth-par.wth-code = buf_wth.wth-code
        :
        create tt-par-dtl.
        buffer-copy buf_wth-par using wth-code
                                      par-code
                                      par-rate
                                      par-val
                 to tt-par-dtl.
        assign
               tt-par-dtl.w-p-code = FOR-CURRENT-W-P-CODE
               tt-par-dtl.doc-code = tt-wth-doc.doc-code
        .
        { str/dtlsum.i tt-par-dtl buf_wth-parts }
    end. /*wth-par*/
    parline-rec = ?.
    create tt-wth-line.
    assign tt-wth-line.wth-code = buf_wth.wth-code
           tt-wth-line.doc-code = tt-wth-doc.doc-code
           tt-wth-line.w-p-code =   FOR-CURRENT-W-P-CODE
    .
    { str/wthlnsum.i tt-wth-line tt-par-dtl}
    run str/wth-lnc1.p (
                      input-output parline-rec
                      ,{&add-def}
                      ,input no
                      ,input tt-wth-doc.doc-code
                      ,input tt-wth-line.wth-code
                      ,input FOR-CURRENT-W-P-CODE
                      ,input FOR-OUT-W-P-CODE
                      ,input tt-wth-line.doc-sum
                      ,input tt-wth-line.fact-sum
                      ,input table tt-par-dtl
                      ,input no /*par-log*/
                      ,input tt-wth-doc.ext-doc-type
                      ,input tt-wth-line.sum-gds-rubl
                      ,input tt-wth-line.sum-gds-base
                      ) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
      message return-value + error-status:get-message(1) view-as alert-box.
      undo, next.
    end.
    v-count = v-count + 1.
  end. /*v-ii*/
  assign
  tt-wth-doc.doc-sum = bf_wth-doc.doc-sum
  tt-wth-doc.fact-sum = bf_wth-doc.fact-sum
  tt-wth-doc.sum-gds-rubl = bf_wth-doc.sum-gds-rubl
  tt-wth-doc.sum-gds-base = bf_wth-doc.sum-gds-base
  .
  DISPLAY
  tt-wth-doc.doc-sum
  tt-wth-doc.sum-gds-rubl
  tt-wth-doc.sum-gds-base
  tt-wth-doc.fact-sum when lookup(tt-wth-doc.ext-doc-type, {&WDEDT_dec}) = 0
  with frame {&frame-name} .
  run control-line in this-procedure ( output lock-doc).
  run lock-proc in this-procedure (input lock-doc).
  {&OPEN-QUERY-BR-lines}
  reposition br-lines to recid parline-rec no-error.
  run waitfram-hide in this-procedure .
  message substitute('Добавлено &1 линий.',v-count) view-as alert-box.
  apply "entry" to br-lines.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame 
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE loc-ref-list as character no-undo .
DEFINE VARIABLE valid-chk-type-list as character no-undo .
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE ii-ok as integer no-undo .
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .

define buffer what_chk-doc  for ub.chk-doc .
define buffer buf_chk-doc  for ub.chk-doc .
run proc-save-doc in this-procedure ( input no) No-ERROR.

if error-status:error
or return-value = 'error'
then return 'error'.
assign
v-doc-rec = recid(bf_wth-doc)
v-line-rec = ?
frame {&frame-name} FOR-CURRENT-W-P-CODE
FOR-OUT-W-P-CODE
.
CASE tt-wth-doc.auto-fill:
  when no then do:
    run str/wth-inca.w ( input parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,INPUT {&add-def}
                   ,input v-doc-rec
                   ,input for-current-w-p-code
                   ,input for-out-w-p-code
                   ,INPUT tt-wth-doc.ext-doc-type
                   ,input-output v-LINE-REC ) no-error.

    if error-status:error then do:
      message error-status:get-message(1) return-value view-as alert-box.
      run control-line in this-procedure ( output lock-doc).
      run lock-proc in this-procedure (input lock-doc).
      return 'error'.
    end.
  end. /*when not auto-fill*/
  when yes then do:
    /*определим какие чеки уже здесь лежат ?*/
    FIND FIRST what_chk-doc No-LOCK WHERE
               what_chk-doc.out-code = tt-wth-doc.doc-code No-ERROR.
    if available what_chk-doc then do:
      assign
      valid-chk-type-list = string(what_chk-doc.chk-type).
      run str/chk-docs.w (
                     input parparentproc
                    ,input 'b-sel,b-mark':U
                    ,input 'free':U
                    ,input ?
                    ,input parobj-type
                    ,input parobj-code
                    ,input what_chk-doc.chk-type
                    ,input '':U
                    ,input 0 /*p-pay-desk*/
                    ,input ?
                    ,input ?
                    ,input 0
                    ,output loc-ref-list) no-error.
      if error-status:error then return 'error'.
    end.
    else do:
        IF lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-expense}) > 0 then do:
          valid-chk-type-list = {&cd-expense} + {&comma-char} + {&encashment}.
        end.
        IF lookup(tt-wth-doc.ext-doc-type, {&WDEDT_List-income}) > 0 then do:
          valid-chk-type-list = {&cd-fund}.
        end.
            run str/chk-docs.w (
                     input parparentproc
                    ,input 'b-sel,b-mark':U
                    ,input 'free':U
                    ,input ?
                    ,input parobj-type
                    ,input parobj-code
                    ,input 0
                    ,input '':U
                    ,input 0 /*p-pay-desk*/
                    ,input ?
                    ,input ?
                    ,input 0
                    ,output loc-ref-list) no-error.
      if error-status:error then return 'error'.
    end.
    if loc-ref-list = "":U then return.
  _ii:
  DO ii = 1 to num-entries(loc-ref-list):
  find first buf_chk-doc exclusive-lock where
                  recid(buf_chk-doc) = integer(entry(ii, loc-ref-list)) No-ERROR.
      if not avail buf_chk-doc or
        LOOKUP(string(buf_chk-doc.chk-type), valid-chk-type-list) = 0 then NEXT _ii.
      if tt-wth-doc.shift-date = ? then do:
        if buf_chk-doc.shift-date <> tt-wth-doc.doc-date then NEXT _ii.
      end.
      else do:
        if NOT (buf_chk-doc.shift-date = tt-wth-doc.shift-date AND
                buf_chk-doc.shift-num = tt-wth-doc.shift-num) then NEXT _ii.
      end.
      if avail(what_chk-doc) and buf_chk-doc.pay-desk <> what_chk-doc.pay-desk then NEXT _ii.
      run str/inc-wth1.p (
        buffer buf_chk-doc
      ,input 1 /*добавить чек*/
      ,input tt-wth-doc.doc-code
      ,input for-current-w-p-code
      ,input for-out-w-p-code
      ,input tt-wth-doc.ext-doc-type
      ,input buf_chk-doc.chk-type
      ,input no
      ) no-error .
      if error-status:error then NEXT _ii.
      ii-ok = ii-ok + 1.
  END.
  if ii - 1 <> ii-ok then do:
    message
    "Из выбранных Вами " (ii - 1 ) "чеков"
    "удалось включить в документ" ii-ok
    view-as alert-box WARNING.
  end.
  end.
END CASE.
RUN control-doc NO-ERROR.
{&OPEN-QUERY-BR-lines}
reposition br-lines to recid v-line-rec no-error.
apply "entry" to br-lines.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame 
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE loc-ref-list as character no-undo .
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-ok as integer no-undo.
define variable v-line-rec as recid no-undo .

DEFINE buffer buf_chk-doc for ub.chk-doc .

if not avail buf_wth-line then return no-apply.
  IF tt-wth-doc.status_ <> {&wayb} THEN DO:
    MESSAGE "Документ закрыт - удалять матценности нельзя!"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
END.
CASE tt-wth-doc.auto-fill:
  when no then do:
    MESSAGE
    "Вы уверены, что хотите удалить строку?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF glog <> YES THEN DO:
      RETURN NO-APPLY.
    END.
    ASSIGN v-line-rec = RECID( buf_wth-line).
    Erase-Block:
    DO ON ERROR UNDO Erase-Block, LEAVE Erase-Block
       ON STOP  UNDO Erase-Block, LEAVE Erase-Block :

      run str/wth-lnc1.p (
                       input-output v-line-rec
                      ,input  {&deletion}
                      ,no
                      ,input buf_wth-line.doc-code
                      ,input buf_wth-line.wth-code
                      ,input buf_wth-line.w-p-code
                      ,input buf_wth-line.out-code
                      ,input 0
                      ,input 0
                      ,input table tt-par-dtl
                      ,input yes
                      ,input tt-wth-doc.ext-doc-type
                      ,input buf_wth-line.sum-gds-rubl
                      ,input buf_wth-line.sum-gds-base
                      ) .
    END.
  end.
  when yes then do:
    run str/chk-docs.w (
                   input parparentproc
                  ,input 'b-sel,b-mark':U
                  ,input 'out-code':U
                  ,input ?
                  ,input parobj-type
                  ,input parobj-code
                  ,input tt-wth-doc.doc-code
                  ,input ''
                  ,input 0 /*p-pay-desk*/
                  ,input ?
                  ,input ?
                  ,input 0
                  ,output loc-ref-list) no-error.
    if error-status:error then return error.
    if loc-ref-list = '':U then return.
     _ii:
  DO ii = 1 to num-entries(loc-ref-list):
  find first buf_chk-doc exclusive-lock where
                  recid(buf_chk-doc) = integer(entry(ii, loc-ref-list)) No-ERROR.
      if not avail buf_chk-doc or
        buf_chk-doc.out-code <> tt-wth-doc.doc-code then NEXT _ii.
      run str/inc-wth1.p (
        buffer buf_chk-doc
      ,input - 1 /*удалить чек*/
      ,input tt-wth-doc.doc-code
      ,input 0
      ,input for-out-w-p-code
      ,input tt-wth-doc.ext-doc-type
      ,input buf_chk-doc.chk-type
      ,input no
      ) no-error .
      if error-status:error then NEXT _ii.
      ii-ok = ii-ok + 1.
  END.
  if ii - 1 <> ii-ok then do:
    message
    "Из выбранных Вами " (ii - 1)  "чеков"
    "удалось удалить из документа" ii-ok
    view-as alert-box WARNING.
  end.
  end.
END CASE.
RUN control-doc NO-ERROR.
{&OPEN-QUERY-BR-lines}

/*RUN Myenable in this-procedure .   */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-attr Dialog-Frame 
PROCEDURE proc-init-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define variable v-atrValue    as character no-undo .
  define variable v-atrType     as character no-undo .
  { str/wthatval.i
      tt-wth-doc.doc-code
      {&wthcattr-dsf}
      v-atrValue
      v-atrType
      NO-ERROR
  }
f-atrDSF = date(v-atrValue) NO-ERROR.
v-atrValue = ''.
  { str/wthatval.i
      tt-wth-doc.doc-code
      {&wthcattr-nsf}
      v-atrValue
      v-atrType
      NO-ERROR
  }
f-atrNSF = v-atrValue.
v-atrValue = ''.
  { str/wthatval.i
      tt-wth-doc.doc-code
      {&wthcattr-paydoc}
      v-atrValue
      v-atrType
      NO-ERROR
  }
f-atrPaydoc = v-atrValue.
v-atrValue = ''.
    { str/wthatval.i
      tt-wth-doc.doc-code
      {&wthcattr-proxy}
      v-atrValue
      v-atrType
      NO-ERROR
  }
f-atrproxy = v-atrValue.
v-atrValue = ''.
      { str/wthatval.i
      tt-wth-doc.doc-code
      {&wthcattr-receiver}
      v-atrValue
      v-atrType
      NO-ERROR
  }
f-atrReceiver = v-atrValue.
DISP {&list-attr} {&list-psnattr}  f-atrdsf WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-inter__ Dialog-Frame 
PROCEDURE proc-inter__ :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter loc-inter like ub.wth-doc.inter_ no-undo.

CASE loc-inter :
    when yes then do:
        assign
        tt-wth-doc.cli-type = tt-wth-doc.obj-type
        tt-wth-doc.cli-code = tt-wth-doc.obj-code
        .
        display
        tt-wth-doc.cli-type
        tt-wth-doc.cli-code
        with frame {&frame-name}.
        disable
        tt-wth-doc.cli-type
        tt-wth-doc.cli-code
        b-cli
        with frame {&frame-name}.
        assign
        for-out-w-p-code = 0
        .
        enable
        b-out
        for-out-w-p-code
        with frame {&frame-name}.
        display
        '':U @ for-out-w-p-name
        with frame {&frame-name}.
        APPLY "VALUE-CHANGED" to tt-wth-doc.cli-type.
                if available out-place then
                display
                out-place.w-p-code @ for-out-w-p-code
                out-place.w-p-name @ for-out-w-p-name
                with frame {&frame-name}.

    end.
    when no then do:
      release out-place.
      if not locked-cli  then do:
        assign
        tt-wth-doc.cli-type = {&cmp}
        tt-wth-doc.cli-code = 0
        .
        display
        tt-wth-doc.cli-type
        tt-wth-doc.cli-code
        '':U @ tt-wth-doc.cli-name
        with frame {&frame-name}.
      end.
      ENABLE
      tt-wth-doc.cli-type when (lock-doc = no and locked-cli = no)
      tt-wth-doc.cli-code when (lock-doc = no and locked-cli = no)
      b-cli when (lock-doc = no and locked-cli = no)
      with frame {&frame-name}.
      assign
      for-out-w-p-code = 0
      for-out-w-p-name = '':U
      .
      hide
      for-out-w-p-code
      b-out
      for-out-w-p-name
      in frame {&frame-name}.
    end.
end CASE.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-doc Dialog-Frame 
PROCEDURE proc-save-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 define input parameter parlines-exist as logical no-undo .
 define variable v-doc-rec as recid no-undo .
 define variable varcli-name as character no-undo .

 IF par-mode = {&lookup} THEN DO:
    RETURN NO-APPLY.
 END.
 if tt-wth-doc.ext-doc-type <> {&WDEDT_Dst_Cli} and not avail current-place then do:
  message "Не определено место хранения МЦ"
  view-as alert-box error.
  APPLY "ENTRY":U TO for-current-w-p-code IN FRAME {&FRAME-NAME}.
  return error.
 end.

/* if tt-wth-doc.cli-type = {&shop} or
    tt-wth-doc.cli-type = {&stock} then do:
   if not available out-place then dO:
     APPLY "ENTRY":U TO for-out-w-p-code IN FRAME {&FRAME-NAME}.
     return error.
   end.
 end.  */
 assign
 frame {&frame-name}
 tt-wth-doc.doc-date
 tt-wth-doc.cli-type
 tt-wth-doc.cli-code
 tt-wth-doc.operator
 tt-wth-doc.deliver
 tt-wth-doc.receiver
 tt-wth-doc.fact-date
 tt-wth-doc.shift-date
 tt-wth-doc.shift-num
 tt-wth-doc.shift-name
 tt-wth-doc.doc-sum when not tt-wth-doc.auto-fill
 tt-wth-doc.fact-sum when not tt-wth-doc.auto-fill
.
if      tt-wth-doc.cli-type = tt-wth-doc.obj-type
    and tt-wth-doc.cli-code = tt-wth-doc.obj-code
    and for-current-w-p-code:screen-value > '':U
    and for-current-w-p-code:screen-value = for-out-w-p-code:screen-value
then do:
  message "Нельзя перемещать МЦ в место их хранения."
  view-as alert-box error.
  APPLY "ENTRY":U TO for-out-w-p-code IN FRAME {&FRAME-NAME}.
  return error.
end.
run trg/wth-inc2.p (
                 input no
                ,input tt-wth-doc.doc-code
                ,input tt-wth-doc.host-code
                ,input tt-wth-doc.obj-type
                ,input tt-wth-doc.obj-code
                ,input tt-wth-doc.cli-type
                ,input tt-wth-doc.cli-code
                ,input tt-wth-doc.operator
                ,input tt-wth-doc.deliver
                ,input tt-wth-doc.receiver
                ,input tt-wth-doc.doc-type
                ,input tt-wth-doc.auto-fill
                ,input tt-wth-doc.exter_
                ,input tt-wth-doc.inter_
                ,input tt-wth-doc.source-ref
                ,input tt-wth-doc.source-type
                ,input tt-wth-doc.borned
                ,input parlines-exist
                ,input tt-wth-doc.ext-doc-type
                ,output varcli-name) no-error.
if error-status:error then do:
  { gbl/reterhnd.i 'error' " " no-undo }
  return error.
end.

 v-doc-rec = recid(bf_wth-doc).
run waitfram-show in this-procedure ( input "Сохранение шапки документа..." ).

 run str/wth-inc1.p (
                  input no   /*silent*/
                 ,input-output v-doc-rec
                 ,input        {&update}
                 ,input tt-wth-doc.doc-code
                 ,input tt-wth-doc.host-code
                 ,input tt-wth-doc.obj-type
                 ,input tt-wth-doc.obj-code
                 ,input tt-wth-doc.cli-type
                 ,input tt-wth-doc.cli-code
                 ,input tt-wth-doc.doc-date
                 ,input tt-wth-doc.fact-date
                 ,input tt-wth-doc.shift-date
                 ,input tt-wth-doc.shift-num
                 ,input tt-wth-doc.shift-name
                 ,input tt-wth-doc.operator
                 ,input tt-wth-doc.deliver
                 ,input tt-wth-doc.receiver
                 ,input tt-wth-doc.doc-type
                 ,input tt-wth-doc.auto-fill
                 ,input tt-wth-doc.exter_
                 ,input tt-wth-doc.inter_
                 ,input tt-wth-doc.source-ref
                 ,input tt-wth-doc.source-type
                 ,input tt-wth-doc.borned
                 ,input tt-wth-doc.doc-sum
                 ,input tt-wth-doc.fact-sum
                 ,input tt-wth-doc.PS
                 ,input tt-wth-doc.status_
                 ,input parlines-exist
                 ,input tt-wth-doc.ext-doc-type
                 ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    return 'error'.
  END.
   /*Если изменились атрибуты запускаем процедуры сохранения атрибутов*/
  if f-atrNSF <> f-atrNsf:screen-value
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , {&wthcattr-nsf}
                     , f-atrNsf:screen-value
                     ) no-error.
  end.
  if   f-atrDSF <> date(f-atrDSF:screen-value)
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , {&wthcattr-dsf}
                     , f-atrDsf:screen-value
                     ) no-error.
  end.
  if f-atrPaydoc <> f-atrPaydoc:screen-value
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , {&wthcattr-paydoc}
                     , f-atrPaydoc:screen-value
                     ) no-error.
  end.
    if f-atrproxy <> f-atrproxy:screen-value
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , {&wthcattr-proxy}
                     , f-atrproxy:screen-value
                     ) no-error.
  end.
    if f-atrReceiver <> f-atrReceiver:screen-value
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , {&wthcattr-Receiver}
                     , f-atrReceiver:screen-value
                     ) no-error.
  end.
  ASSIGN FRAME {&FRAME-NAME} {&list-attr}.
  /* Если во внутр. приходе изменили МХ (а это разрешено, т.к. при создании расхода может быть не известно МХ),
   то синхронизирую МЦ в линиях, номиналах и партиях.   Не красиво, но пока не придумала как лучше  */
  if for-current-w-p-code <> int(for-current-w-p-code:screen-value) and par-mode = {&update}
      and tt-wth-doc.doc-type = {&income} and not tt-wth-doc.exter_ then do:
    for each buf_wth-line exclusive-lock where
      buf_wth-line.doc-code = tt-wth-doc.doc-code:
      buf_wth-line.w-p-code =  int(for-current-w-p-code:screen-value) .
    end.
    for each buf_wth-dtl exclusive-lock where buf_wth-dtl.doc-code = tt-wth-doc.doc-code :
      buf_wth-dtl.w-p-code =    int(for-current-w-p-code:screen-value).
    end.
    for each buf_wth-parts exclusive-lock where
             buf_wth-parts.out-code =  tt-wth-doc.doc-code:
        buf_wth-parts.w-p-code = int(for-current-w-p-code:screen-value).
    end.
    run fill-tables.
  end.
  ASSIGN
  FOR-CURRENT-W-P-CODE
  FOR-OUT-W-P-CODE
  .
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-name Dialog-Frame 
PROCEDURE proc-shift-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.

  if input frame {&frame-name} tt-wth-doc.shift-name <> tt-wth-doc.shift-name then do:
    if input frame {&frame-name} tt-wth-doc.shift-date <> ? then do:

      for each  bf_shift-obj where bf_shift-obj.obj-type   = tt-wth-doc.obj-type                             and
                                   bf_shift-obj.obj-code   = tt-wth-doc.obj-code                             and
                                   bf_shift-obj.shift-date = input frame {&frame-name} tt-wth-doc.shift-date and
                                   bf_shift-obj.shift-name = input frame {&frame-name} tt-wth-doc.shift-name no-lock on error undo, return error return-value :
        assign
          varfind-shift = varfind-shift + 1
          varshift-date = bf_shift-obj.shift-date
          varshift-num  = bf_shift-obj.shift-num.
      end.

      if varfind-shift = 0 or varfind-shift > 1 then do:
        if varfind-shift = 0 then do:
          message "Не найдена смена: " tt-wth-doc.obj-type " " tt-wth-doc.obj-code
                  " Дата " input frame {&frame-name} tt-wth-doc.shift-date " Номер смены " input frame {&frame-name} tt-wth-doc.shift-name " ."
          view-as alert-box error.
        end.
        else do:
          message "Найдено более одной смены с одним номером в сменном дне. Объект: " tt-wth-doc.obj-type " " tt-wth-doc.obj-code
                  " Дата " input frame {&frame-name} tt-wth-doc.shift-date " Номер смены " input frame {&frame-name} tt-wth-doc.shift-name " ."
          view-as alert-box error.
        end.
        display tt-wth-doc.shift-name with frame {&frame-name}.
        run proc-sht no-error.
        if error-status:error then do: return error. end.
      end.
      else do:
        assign frame {&frame-name}
          tt-wth-doc.shift-name.
        assign
          tt-wth-doc.shift-date = varshift-date
          tt-wth-doc.shift-num  = varshift-num.
        display tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name with frame {&frame-name}.
        if tt-wth-doc.fact-date = ? then do: assign tt-wth-doc.fact-date = tt-wth-doc.shift-date tt-wth-doc.fact-time = (24 * 60 * 60). display tt-wth-doc.fact-date with frame {&frame-name}. end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-num Dialog-Frame 
PROCEDURE proc-shift-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer bf_shift-obj   for ub.shift-obj.
  if input frame {&frame-name} tt-wth-doc.shift-num <> tt-wth-doc.shift-num then do:
    if input frame {&frame-name} tt-wth-doc.shift-date <> ? then do:
      find first bf_shift-obj where bf_shift-obj.obj-type   = tt-wth-doc.obj-type                             and
                                    bf_shift-obj.obj-code   = tt-wth-doc.obj-code                             and
                                    bf_shift-obj.shift-date = input frame {&frame-name} tt-wth-doc.shift-date and
                                    bf_shift-obj.shift-num  = input frame {&frame-name} tt-wth-doc.shift-num  no-lock no-error.
      if not available bf_shift-obj then do:
        message "Не найдена смена: " tt-wth-doc.obj-type " " tt-wth-doc.obj-code
                " Дата " input frame {&frame-name} tt-wth-doc.shift-date " Порядок смены " input frame {&frame-name} tt-wth-doc.shift-num " ."
        view-as alert-box error.
        display tt-wth-doc.shift-num with frame {&frame-name}.
        run proc-sht no-error.
        if error-status:error then do:
          return error.
        end.
      end.
      else do:
        assign
          tt-wth-doc.shift-date = bf_shift-obj.shift-date
          tt-wth-doc.shift-num  = bf_shift-obj.shift-num
          tt-wth-doc.shift-name = bf_shift-obj.shift-name.
        display tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name with frame {&frame-name}.
        if tt-wth-doc.fact-date = ? then do:
          assign
            tt-wth-doc.fact-date = tt-wth-doc.shift-date
            tt-wth-doc.fact-time = (24 * 60 * 60).
          display tt-wth-doc.fact-date with frame {&frame-name}.
        end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sht Dialog-Frame 
PROCEDURE proc-sht :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer   bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-sel', 'obj', tt-wth-doc.obj-type, tt-wth-doc.obj-code ,'':u, input-output varrid-list) no-error .
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        tt-wth-doc.shift-date = bf_shift-obj.shift-date
        tt-wth-doc.shift-num  = bf_shift-obj.shift-num
        tt-wth-doc.shift-name = bf_shift-obj.shift-name.
      display tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name with frame {&frame-name}.
      /*if tt-wth-doc.fact-date = ? then do: */
        assign
          tt-wth-doc.fact-date = tt-wth-doc.shift-date
          tt-wth-doc.fact-time = (24 * 60 * 60).
        display tt-wth-doc.fact-date with frame {&frame-name}.
      /*end.  */
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-wrt-attr Dialog-Frame 
PROCEDURE proc-wrt-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define  input parameter p-doc-code   like ub.wth-doc.doc-code    no-undo.
define  input parameter p-attr-code  like ub.wth-doc-attr.attr-code  no-undo.
define  input parameter p-attr-value like ub.wth-doc-attr.attr-value no-undo.

    { str/wthatwrt.i
        p-doc-code
        p-attr-code
        p-attr-value
        no-error     }
    if error-status :error then do:
      message error-status :error error-status :get-message( 1 ) '"' + p-attr-code + '"'
      view-as alert-box error.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-wth-doc Dialog-Frame 
PROCEDURE reposition-wth-doc :
define input parameter p-direction as character no-undo .
define variable v-new-wth-doc-recid as recid no-undo .

do
on error undo, return error
:


  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-wth-doc in p-call-prog
      (input  p-direction
      ,output v-new-wth-doc-recid
      ).

    if v-new-wth-doc-recid <> ?
    then do:
      define buffer buf_wth-doc for ub.wth-doc .
      find first buf_wth-doc no-lock
        where recid(buf_wth-doc) = v-new-wth-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-wth-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов МЦ не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-place-name Dialog-Frame 
FUNCTION get-place-name RETURNS CHARACTER
  (   INPUT p-obj-type AS CHARACTER
     ,INPUT p-obj-code AS INTEGER
     ,INPUT p-w-p-code AS INTEGER ) :
DEFINE BUFFER buf_wth-place FOR ub.wth-place.
IF p-w-p-code = 0 
AND lookup(tt-wth-doc.ext-doc-type, {&WDEDT_rcpt-gds}) = 0 THEN DO:
    RETURN ''.
END.
FIND FIRST buf_wth-place NO-LOCK WHERE
    buf_wth-place.obj-type = p-obj-type
 AND buf_wth-place.obj-code = p-obj-code 
 AND buf_wth-place.w-p-code = p-w-p-code NO-ERROR.
IF AVAILABLE buf_wth-place THEN DO:
  RETURN buf_wth-place.w-p-name.
END.
RETURN "!!!Неизвестное МХ МЦ".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

