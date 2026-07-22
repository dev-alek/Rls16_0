&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройки для ОТЧЕТОВ

Автор: Чернова Светлана Александровна
Дата создания: 07/04/07
Author: Svetlana Chernova
Creation date: 07/04/07

This .W file was created with the Progress AppBuilder.

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.
define input parameter p-type        as char no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки для ОТЧЕТОВ" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/onewin.i   }
{ str/lib-trn.i }

define buffer obj_thbj-attr for ub.thbj-attr.
define buffer glb_thbj-attr for ub.thbj-attr.
define buffer frm_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-ttho     as handle no-undo .
define variable v-tthg    as handle no-undo .
define variable v-tthf    as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-report as logical no-undo.
define variable v-to-create-report-g as logical no-undo.
define variable v-to-create-report-f as logical no-undo.
define variable str-attr as character no-undo .
define temp-table thbjattr_thbj-attr-o no-undo like thbjattr_thbj-attr .
define temp-table thbjattr_thbj-attr-g no-undo like thbjattr_thbj-attr .
define temp-table thbjattr_thbj-attr-f no-undo like thbjattr_thbj-attr .
define variable v-obj-type  as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-host-code as integer   no-undo .
define variable fl as character no-undo .
define variable v-onewin-point as character no-undo .
/* Поля для assign НЕЗАБЫТЬ ДОБАВИТЬ СУДА НОВЫЕ !!! */

&Scoped-define page-1p  prt-z-no actuate sum-from sum-step sum-to sumvals ~
ardecldt  shft-qty ~
xl-delim  rep-sort ~
alcgrpgd s-alcgrpgd cplot cdens 
&Scoped-define page-1p rep-shift-format rep-excel rep-password
&Scoped-define page-2p

v-ttho = buffer thbjattr_thbj-attr-o:table-handle .
v-tthg = buffer thbjattr_thbj-attr-g:table-handle .
v-tthf = buffer thbjattr_thbj-attr-f:table-handle .
 if g#db-num <> 0 and p-obj-type = "" and  p-obj-code = 0
    then p-mode = {&lookup} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit BUTTON-1 B-quit B-Help I-actuate ~
BUTTON-2 I-ardecldt I-rep-sort I-sum-from I-sum-step I-sum-to I-sumvals ~
I-prt-z-no I-shft-qty RECT-2 I-xl-delim I-alcgrpgd I-cplot I-cdens ~
I-rep-excel actuate B-10 prt-z-no sum-from sum-step sum-to sumvals B-17 ~
xl-delim rep-sort B-set_rep-sort ardecldt B-11 shft-qty rep-shift-format ~
rep-password B-alcgrpgd cplot B-set_cplot cdens rep-excel F-button-1 ~
F-button-2 v-actuate v-prt-z-no FILL-IN-2 v-sum-from v-sum-step v-sum-to ~
v-sumvals v-xl-delim v-rep-sort v-ardecldt v-shft-qty v-alcgrpgd v-cplot ~
v-cdens 
&Scoped-Define DISPLAYED-OBJECTS actuate prt-z-no sum-from sum-step sum-to ~
sumvals xl-delim rep-sort ardecldt shft-qty rep-shift-format rep-password ~
alcgrpgd cplot cdens rep-excel F-button-1 F-button-2 v-actuate v-prt-z-no ~
FILL-IN-2 v-sum-from v-sum-step v-sum-to v-sumvals v-xl-delim v-rep-sort ~
v-ardecldt v-shft-qty v-alcgrpgd s-alcgrpgd v-cplot v-cdens 

/* Custom List Definitions                                              */
/* page-1,page-2,List-3,List-4,List-5,List-6                            */
&Scoped-define page-1 I-actuate I-ardecldt I-rep-sort I-sum-from I-sum-step ~
I-sum-to I-sumvals I-prt-z-no I-shft-qty I-xl-delim I-alcgrpgd I-cplot ~
I-cdens I-rep-excel actuate B-10 prt-z-no sum-from sum-step sum-to sumvals ~
B-17 xl-delim rep-sort B-set_rep-sort ardecldt B-11 shft-qty alcgrpgd ~
B-alcgrpgd cplot B-set_cplot cdens v-actuate v-prt-z-no FILL-IN-2 ~
v-sum-from v-sum-step v-sum-to v-sumvals v-xl-delim v-rep-sort v-ardecldt ~
v-shft-qty v-alcgrpgd s-alcgrpgd v-cplot v-cdens 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-10 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-11 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .79.

DEFINE BUTTON B-17 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-alcgrpgd 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-set_cplot 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 2.63 BY 1.08.

DEFINE BUTTON B-set_rep-sort 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 2.63 BY 1.08.

DEFINE BUTTON BUTTON-1 
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&1.Параметры" 
     SIZE 14 BY 1.13 TOOLTIP "Закладка №1".

DEFINE BUTTON BUTTON-2 
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&2.Параметры" 
     SIZE 14 BY 1.13 TOOLTIP "Закладка №2".

DEFINE VARIABLE rep-shift-format AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 1 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Стандарт",1,
                     "Форма 1",2,
                     "Форма 3",3
     DROP-DOWN-LIST
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE cplot AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.38 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE rep-sort AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.38 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE sumvals AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 24.63 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE alcgrpgd AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 10.63 BY 1 NO-UNDO.

DEFINE VARIABLE ardecldt AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE F-button-1 AS CHARACTER FORMAT "X(256)":U INITIAL "№ &1." 
      VIEW-AS TEXT 
     SIZE 5 BY .67 TOOLTIP "Закладка №1" NO-UNDO.

DEFINE VARIABLE F-button-2 AS CHARACTER FORMAT "X(256)":U INITIAL "№ &2." 
      VIEW-AS TEXT 
     SIZE 4.75 BY .67 TOOLTIP "Закладка №2" NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Диапозоны для ОТЧЕТА ~"Почасовой отчет по диапазонам сумм продаж~"" 
      VIEW-AS TEXT 
     SIZE 65 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE s-alcgrpgd AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 51.25 BY .67 NO-UNDO.

DEFINE VARIABLE sum-from AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE VARIABLE sum-step AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 14 BY .79 NO-UNDO.

DEFINE VARIABLE sum-to AS DECIMAL FORMAT "->>>>>>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE VARIABLE v-actuate AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 70 BY .79 NO-UNDO.

DEFINE VARIABLE v-alcgrpgd AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 32.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-ardecldt AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 47.75 BY .79 NO-UNDO.

DEFINE VARIABLE v-cdens AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 40 BY .79 NO-UNDO.

DEFINE VARIABLE v-cplot AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 48.25 BY .79 NO-UNDO.

DEFINE VARIABLE v-prt-z-no AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 42.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-rep-sort AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 48.25 BY .79 NO-UNDO.

DEFINE VARIABLE v-shft-qty AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 41 BY .79 NO-UNDO.

DEFINE VARIABLE v-sum-from AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 12.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-sum-step AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 5.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-sum-to AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 12.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-sumvals AS CHARACTER FORMAT "X(256)":U INITIAL "Список" 
      VIEW-AS TEXT 
     SIZE 6.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-xl-delim AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 50.75 BY .79 NO-UNDO.

DEFINE VARIABLE xl-delim AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE IMAGE I-actuate
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-alcgrpgd
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-ardecldt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-cdens
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-cplot
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-prt-z-no
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-rep-excel
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-rep-sort
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-shft-qty
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-sum-from
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-sum-step
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-sum-to
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-sumvals
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-xl-delim
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE VARIABLE cdens AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "По средней", 0,
"По чекам", 1
     SIZE 28 BY .79
     FONT 4 NO-UNDO.

DEFINE VARIABLE shft-qty AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Расчетно-книжный остаток", "system",
"Фактический остаток", "state"
     SIZE 38 BY .79
     FONT 4 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL  GROUP-BOX  
     SIZE 101 BY .25.

DEFINE VARIABLE actuate AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 72.63 BY .79 NO-UNDO.

DEFINE VARIABLE prt-z-no AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY .79 NO-UNDO.

DEFINE VARIABLE rep-excel AS LOGICAL INITIAL yes 
     LABEL "Вывод отчетов в EXCEL" 
     VIEW-AS TOGGLE-BOX
     SIZE 57.25 BY .83 NO-UNDO.

DEFINE VARIABLE rep-password AS LOGICAL INITIAL no 
     LABEL "Excel для отчетов, защита от редактирования" 
     VIEW-AS TOGGLE-BOX
     SIZE 57.25 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     BUTTON-1 AT ROW 1 COL 34.63 WIDGET-ID 342
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 98
     BUTTON-2 AT ROW 1 COL 48.38 WIDGET-ID 344
     actuate AT ROW 2.25 COL 2.75 WIDGET-ID 268
     B-10 AT ROW 3 COL 2.75 WIDGET-ID 298
     prt-z-no AT ROW 3.08 COL 6 WIDGET-ID 300
     sum-from AT ROW 4.75 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 272
     sum-step AT ROW 4.75 COL 34.63 COLON-ALIGNED NO-LABEL WIDGET-ID 288
     sum-to AT ROW 5.58 COL 17 NO-LABEL WIDGET-ID 270
     sumvals AT ROW 5.58 COL 36.63 NO-LABEL WIDGET-ID 284
     B-17 AT ROW 6.5 COL 2.75 WIDGET-ID 378
     xl-delim AT ROW 6.5 COL 4 COLON-ALIGNED NO-LABEL WIDGET-ID 386
     rep-sort AT ROW 7.5 COL 2.75 NO-LABEL WIDGET-ID 278
     B-set_rep-sort AT ROW 7.5 COL 49.63 WIDGET-ID 480
     ardecldt AT ROW 8.58 COL 2.75 NO-LABEL WIDGET-ID 274
     B-11 AT ROW 9.58 COL 2.75 WIDGET-ID 314
     shft-qty AT ROW 9.58 COL 47.63 NO-LABEL WIDGET-ID 308
     rep-shift-format AT ROW 10.58 COL 26.63 COLON-ALIGNED NO-LABEL WIDGET-ID 488
     rep-password AT ROW 11.75 COL 2.5 WIDGET-ID 368
     alcgrpgd AT ROW 12.83 COL 34.38 COLON-ALIGNED NO-LABEL WIDGET-ID 472
     B-alcgrpgd AT ROW 12.83 COL 47.25 WIDGET-ID 464
     cplot AT ROW 13.88 COL 2.75 NO-LABEL WIDGET-ID 478
     B-set_cplot AT ROW 13.88 COL 49 WIDGET-ID 476
     cdens AT ROW 15.25 COL 47 NO-LABEL WIDGET-ID 494
     rep-excel AT ROW 16.33 COL 2.25 WIDGET-ID 370
     F-button-1 AT ROW 1.25 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 350
     F-button-2 AT ROW 1.25 COL 47.25 COLON-ALIGNED NO-LABEL WIDGET-ID 348
     v-actuate AT ROW 2.25 COL 5.63 NO-LABEL WIDGET-ID 122
     v-prt-z-no AT ROW 3.08 COL 9.38 NO-LABEL WIDGET-ID 304
     FILL-IN-2 AT ROW 4 COL 2 NO-LABEL WIDGET-ID 338
     v-sum-from AT ROW 4.75 COL 2.75 NO-LABEL WIDGET-ID 172
     v-sum-step AT ROW 4.75 COL 30 NO-LABEL WIDGET-ID 178
     v-sum-to AT ROW 5.58 COL 2.75 NO-LABEL WIDGET-ID 184
     v-sumvals AT ROW 5.58 COL 30 NO-LABEL WIDGET-ID 208
     v-xl-delim AT ROW 6.5 COL 10.25 NO-LABEL WIDGET-ID 384
     v-rep-sort AT ROW 7.5 COL 52.75 NO-LABEL WIDGET-ID 160
     v-ardecldt AT ROW 8.63 COL 14.75 NO-LABEL WIDGET-ID 132
     v-shft-qty AT ROW 9.58 COL 6 NO-LABEL WIDGET-ID 312
     v-alcgrpgd AT ROW 12.83 COL 2.75 NO-LABEL WIDGET-ID 470
     s-alcgrpgd AT ROW 13.04 COL 48.63 COLON-ALIGNED NO-LABEL WIDGET-ID 474
     v-cplot AT ROW 13.96 COL 52.25 NO-LABEL WIDGET-ID 484
     v-cdens AT ROW 15.25 COL 5 NO-LABEL WIDGET-ID 498
     "Форма сменного отчета:" VIEW-AS TEXT
          SIZE 23.63 BY .67 AT ROW 10.67 COL 2.75 WIDGET-ID 486
     I-actuate AT ROW 2.25 COL 1 WIDGET-ID 118
     I-ardecldt AT ROW 8.67 COL 1 WIDGET-ID 128
     I-rep-sort AT ROW 7.5 COL 1 WIDGET-ID 158
     I-sum-from AT ROW 4.75 COL 1 WIDGET-ID 168
     I-sum-step AT ROW 4.75 COL 27.63 WIDGET-ID 174
     I-sum-to AT ROW 5.58 COL 1 WIDGET-ID 180
     I-sumvals AT ROW 5.58 COL 27.63 WIDGET-ID 204
     I-prt-z-no AT ROW 3.08 COL 1 WIDGET-ID 302
     I-shft-qty AT ROW 9.58 COL 1 WIDGET-ID 306
     RECT-2 AT ROW 2 COL 1 WIDGET-ID 346
     I-xl-delim AT ROW 6.5 COL 1 WIDGET-ID 380
     I-alcgrpgd AT ROW 12.88 COL 1 WIDGET-ID 466
     I-cplot AT ROW 13.88 COL 1 WIDGET-ID 482
     I-cdens AT ROW 15.25 COL 1 WIDGET-ID 490
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     I-rep-excel AT ROW 11.75 COL 1 WIDGET-ID 500
     SPACE(98.24) SKIP(10.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки для ОТЧЕТОВ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR TOGGLE-BOX actuate IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN alcgrpgd IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN ardecldt IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR BUTTON B-10 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-11 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-17 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-alcgrpgd IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-set_cplot IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-set_rep-sort IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RADIO-SET cdens IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR EDITOR cplot IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       cplot:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR IMAGE I-actuate IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-alcgrpgd IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-ardecldt IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-cdens IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-cplot IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-prt-z-no IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-rep-excel IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-rep-sort IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-shft-qty IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-sum-from IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-sum-step IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-sum-to IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-sumvals IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-xl-delim IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX prt-z-no IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR EDITOR rep-sort IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN s-alcgrpgd IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR RADIO-SET shft-qty IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN sum-from IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN sum-step IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN sum-to IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR EDITOR sumvals IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN v-actuate IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-actuate:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-alcgrpgd IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-alcgrpgd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ardecldt IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-ardecldt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-cdens IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-cdens:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-cplot IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-cplot:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-prt-z-no IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-prt-z-no:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-rep-sort IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-rep-sort:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-shft-qty IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-shft-qty:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-sum-from IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-sum-from:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-sum-step IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-sum-step:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-sum-to IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-sum-to:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-sumvals IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-sumvals:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-xl-delim IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-xl-delim:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN xl-delim IN FRAME Dialog-Frame
   1                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки для ОТЧЕТОВ */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки для ОТЧЕТОВ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-10
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-10 Dialog-Frame
ON CHOOSE OF B-10 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-report-obj},
       "prt-z-no"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-11
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-11 Dialog-Frame
ON CHOOSE OF B-11 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-report-obj},
       "shft-qty"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-17
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-17 Dialog-Frame
ON CHOOSE OF B-17 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-report-firm},
       "xl-delim"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-alcgrpgd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-alcgrpgd Dialog-Frame
ON CHOOSE OF B-alcgrpgd IN FRAME Dialog-Frame
DO:

define variable v-rid-list as character no-undo .
 if p-mode = {&lookup} then return .
    run ref/gds-grp.w (
                  input parparentproc
                , input ('b-sel')
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input-output v-rid-list) NO-ERROR.
 if error-status :error or v-rid-list = "" then return no-apply .
 define buffer buf_gds-grp for ub.gds-grp  .
 find first buf_gds-grp no-lock where recid(buf_gds-grp) = int(v-rid-list) no-error .
 if error-status :error then return no-apply .
 alcgrpgd   = buf_gds-grp.node-code .
 s-alcgrpgd = buf_gds-grp.node-name .
 DISPLAY alcgrpgd s-alcgrpgd  with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-set_cplot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-set_cplot Dialog-Frame
ON CHOOSE OF B-set_cplot IN FRAME Dialog-Frame
DO:
  RUN proc-set_cplot IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-set_rep-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-set_rep-sort Dialog-Frame
ON CHOOSE OF B-set_rep-sort IN FRAME Dialog-Frame
DO:
  RUN proc-set_rep-sort IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame /* 1.Параметры */
DO:
    if fl = '' then do:
       /*assign  FRAME {&FRAME-NAME} {&page-2p} */ .  /* пока пусто */
    end.
    fl = ''  .
    DISPLAY {&page-1} with FRAME {&FRAME-NAME}.
    /*HIDE {&page-2} IN FRAME {&FRAME-NAME}. */     /* пока пусто */
button-1:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame {&frame-name} .
button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
F-button-1:fgcolor = 1   .
f-button-2:fgcolor = ? .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 Dialog-Frame
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame /* 2.Параметры */
DO:
    assign  FRAME {&FRAME-NAME} {&page-1p} .
    DISPLAY {&page-2} with FRAME {&FRAME-NAME}.
    HIDE {&page-1} IN FRAME {&FRAME-NAME}.

    button-2:LOAD-IMAGE-UP("adeicon\ts-up":U)        in frame {&frame-name} .
    button-1:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
    F-button-2:fgcolor = 1   .
    f-button-1:fgcolor = ? .



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-actuate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-actuate Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-actuate IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-alcgrpgd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-alcgrpgd Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-alcgrpgd IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ardecldt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ardecldt Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ardecldt IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-cdens
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-cdens Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-cdens IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-cplot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-cplot Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-cplot IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-prt-z-no
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-prt-z-no Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-prt-z-no IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-rep-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-rep-excel Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-rep-excel IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-rep-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-rep-sort Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-rep-sort IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-shft-qty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-shft-qty Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-shft-qty IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-sum-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-sum-from Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-sum-from IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-sum-step
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-sum-step Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-sum-step IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-sum-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-sum-to Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-sum-to IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-sumvals
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-sumvals Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-sumvals IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-xl-delim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-xl-delim Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-xl-delim IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rep-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rep-excel Dialog-Frame
ON VALUE-CHANGED OF rep-excel IN FRAME Dialog-Frame /* Вывод отчетов в EXCEL */
DO:
  assign rep-excel .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rep-password
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rep-password Dialog-Frame
ON VALUE-CHANGED OF rep-password IN FRAME Dialog-Frame /* Excel для отчетов, защита от редактирования */
DO:
  assign rep-password .
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
{ gbl/ed_date.i ardecldt }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

if p-obj-type <> "" then
   frame {&frame-name}:title = frame {&frame-name}:title + (if p-obj-type = {&cmp} then " фирма" else " маг") + string(p-obj-code) .

define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_nakl-par_lookup':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
   if loc#log <> yes then do: return error. end.
    run init-tt.
    run enable_UI.
    run init-proc.
    fl = 'new' .  /* флаг для закладок */
    apply  "CHOOSE":U   to  button-1 in frame {&frame-name} .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  DISPLAY actuate prt-z-no sum-from sum-step sum-to sumvals xl-delim rep-sort 
          ardecldt shft-qty rep-shift-format rep-password alcgrpgd cplot cdens 
          rep-excel F-button-1 F-button-2 v-actuate v-prt-z-no FILL-IN-2 
          v-sum-from v-sum-step v-sum-to v-sumvals v-xl-delim v-rep-sort 
          v-ardecldt v-shft-qty v-alcgrpgd s-alcgrpgd v-cplot v-cdens 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit BUTTON-1 B-quit B-Help I-actuate BUTTON-2 I-ardecldt I-rep-sort 
         I-sum-from I-sum-step I-sum-to I-sumvals I-prt-z-no I-shft-qty RECT-2 
         I-xl-delim I-alcgrpgd I-cplot I-cdens I-rep-excel actuate B-10 
         prt-z-no sum-from sum-step sum-to sumvals B-17 xl-delim rep-sort 
         B-set_rep-sort ardecldt B-11 shft-qty rep-shift-format 
         B-alcgrpgd cplot B-set_cplot cdens F-button-1 F-button-2 
         v-actuate v-prt-z-no FILL-IN-2 v-sum-from v-sum-step v-sum-to 
         v-sumvals v-xl-delim v-rep-sort v-ardecldt v-shft-qty v-alcgrpgd 
         v-cplot v-cdens 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
for each thbjattr_thbj-attr-o:
  delete thbjattr_thbj-attr-o.
end.

for each thbjattr_thbj-attr-g:
  delete thbjattr_thbj-attr-g.
end.
for each thbjattr_thbj-attr-f:
  delete thbjattr_thbj-attr-f.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
if p-type = 'glob' then do:
  run adm/shattri.p (
      input "init":U
    , input ""
    , input 0
    , input {&attr-report-glob}
    , input "":U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output TABLE-HANDLE v-tthg
    ) no-error .
  
  if error-status:error then do:
    message
    "Не удалось получить начальные значения настроек GLOB" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo, return error .
end.
end.
if p-type = 'firm' then do:
    run adm/shattri.p (
        input "init":U
      , input v-obj-type
      , input v-obj-code
      , input {&attr-report-firm}
      , input "":U
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output v-param-type
      , input-output TABLE-HANDLE v-tthf
      ) no-error .
    if error-status:error then do:
      message
      "Не удалось получить начальные значения настроек firm" skip
      error-status:get-message(1) return-value
      view-as alert-box error .
      undo, return error .
    end.
end.

if p-type = 'obj' then do:    
    run adm/shattri.p (
        input "init":U
      , input p-obj-type
      , input p-obj-code
      , input {&attr-report-obj}
      , input "":U
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output v-param-type
      , input-output TABLE-HANDLE v-ttho
      ) no-error .
    
    if error-status:error then do:
      message
      "Не удалось получить начальные значения настроек OBJ" skip
      error-status:get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error .
    end.
end.
&scop telo1  IF thbjattr_thbj-attr-o.prop-code = ~{&attr-report-obj_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr-o.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid2=" + string(recid(thbjattr_thbj-attr-o)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.

&scop telo1gc  when ~{&attr-report-glob_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr-g.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid3=" + string(recid(thbjattr_thbj-attr-g)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.

&scop telo1g  IF thbjattr_thbj-attr-g.prop-code = ~{&attr-report-glob_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr-g.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid3=" + string(recid(thbjattr_thbj-attr-g)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.

&scop telo1f  IF thbjattr_thbj-attr-f.prop-code = ~{&attr-report-firm_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr-f.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid4=" + string(recid(thbjattr_thbj-attr-f)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.

FOR EACH thbjattr_thbj-attr-g :
  case thbjattr_thbj-attr-g.prop-code :
    
&scop pole actuate
&scop type logical
{&telo1gc}

&scop pole ardecldt
&scop type date
{&telo1gc}

&scop pole rep-sort
&scop type character
{&telo1gc}

&scop pole sum-from
&scop type decimal
{&telo1gc}

&scop pole sum-step
&scop type decimal
{&telo1gc}

&scop pole sum-to
&scop type decimal
{&telo1gc}

&scop pole sumvals
&scop type character
{&telo1gc}

&scop pole alcgrpgd
&scop type integer
{&telo1gc}

&scop pole rep-shift-format
&scop type integer
{&telo1gc}

&scop pole cplot
&scop type character
{&telo1gc}

&scop pole cdens
&scop type integer
{&telo1gc}

&scop pole rep-excel
&scop type logical
{&telo1gc}

&scop pole rep-password
&scop type logical
{&telo1gc}

    otherwise .
  end case .
/* 17/VIII-2018 - перенесено в case  
&scop pole actuate
&scop type logical
{&telo1g}

&scop pole ardecldt
&scop type date
{&telo1g}


&scop pole rep-sort
&scop type character
{&telo1g}

&scop pole sum-from
&scop type decimal
{&telo1g}

&scop pole sum-step
&scop type decimal
{&telo1g}

&scop pole sum-to
&scop type decimal
{&telo1g}

&scop pole sumvals
&scop type character
{&telo1g}


&scop pole alcgrpgd
&scop type integer
{&telo1g}

&scop pole rep-shift-format
&scop type integer
{&telo1g}

&scop pole cplot
&scop type character
{&telo1g}

&scop pole cdens
&scop type integer
{&telo1g}

&scop pole rep-excel
&scop type logical
{&telo1g}
*/

  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-g to temp-thbj-attr.

end.


FOR EACH thbjattr_thbj-attr-o
:


&scop pole prt-z-no
&scop type logical
{&telo1}

&scop pole shft-qty
&scop type character
{&telo1}


  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-o to temp-thbj-attr.

END.

FOR EACH thbjattr_thbj-attr-f
:
&scop pole xl-delim
&scop type character
{&telo1f}


  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-f to temp-thbj-attr.

end.


define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .

&scop telo2 run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-report-obj} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
v-~{&pole~} = v-~{&pole~}:screen-value .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .

&scop telo2g run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-report-glob} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
v-~{&pole~} = v-~{&pole~}:screen-value .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .

&scop telo2f run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-report-firm} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
v-~{&pole~} = v-~{&pole~}:screen-value .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .



&scop pole prt-z-no
{&telo2}

&scop pole shft-qty
{&telo2}

&scop pole actuate
{&telo2g}

&scop pole alcgrpgd
{&telo2g}

&scop pole ardecldt
{&telo2g}

&scop pole rep-sort
{&telo2g}

&scop pole cplot
{&telo2g}

&scop pole cdens
{&telo2g}

&scop pole sum-from
{&telo2g}

&scop pole sum-step
{&telo2g}

&scop pole sum-to
{&telo2g}

&scop pole sumvals
{&telo2g}

&scop pole xl-delim
{&telo2f}


 define buffer buf_gds-grp for ub.gds-grp  .
 find first buf_gds-grp no-lock where buf_gds-grp.node-code = alcgrpgd no-error .
 if available buf_gds-grp then do:
 alcgrpgd   = buf_gds-grp.node-code .
 s-alcgrpgd = buf_gds-grp.node-name .
 DISPLAY alcgrpgd s-alcgrpgd  with FRAME {&FRAME-NAME}.
 end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
define variable v-i as integer   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-found as decimal   no-undo .
  if p-mode = {&update} then do:

    find first obj_thbj-attr exclusive-lock where
              obj_thbj-attr.obj-type = p-obj-type
        and   obj_thbj-attr.obj-code = p-obj-code
        and   obj_thbj-attr.upper-prop-code = {&attr-report-obj}
        and   obj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked obj_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-report-obj} skip
        "Запись ПАРАМЕТРОВ по объектам занята"
        view-as alert-box error .
        undo, return error.
      end.


    find first frm_thbj-attr exclusive-lock where
              frm_thbj-attr.obj-type = v-obj-type
        and   frm_thbj-attr.obj-code = v-obj-code
        and   frm_thbj-attr.upper-prop-code = {&attr-report-firm}
        and   frm_thbj-attr.prop-code = '':u no-wait no-error.
     if locked frm_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-report-obj} skip
        "Запись ПАРАМЕТРОВ по фирмам занята"
        view-as alert-box error .
        undo, return error.
      end.

    find first glb_thbj-attr exclusive-lock where
              glb_thbj-attr.obj-type = ""
        and   glb_thbj-attr.obj-code = 0
        and   glb_thbj-attr.upper-prop-code = {&attr-report-glob}
        and   glb_thbj-attr.prop-code = '':u no-wait no-error.
     if locked glb_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-report-glob} skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first obj_thbj-attr no-lock where
          obj_thbj-attr.obj-type = p-obj-type
    and   obj_thbj-attr.obj-code = p-obj-code
    and   obj_thbj-attr.upper-prop-code = {&attr-report-obj}
    and   obj_thbj-attr.prop-code = '':u no-error.
    find first glb_thbj-attr no-lock where
          glb_thbj-attr.obj-type = ""
    and   glb_thbj-attr.obj-code = 0
    and   glb_thbj-attr.upper-prop-code = {&attr-report-glob}
    and   glb_thbj-attr.prop-code = '':u no-error.
    find first frm_thbj-attr no-lock where
          frm_thbj-attr.obj-type = v-obj-type
    and   frm_thbj-attr.obj-code = v-obj-code
    and   frm_thbj-attr.upper-prop-code = {&attr-report-firm}
    and   frm_thbj-attr.prop-code = '':u no-error.

  end.

  if not available obj_thbj-attr then do:
    assign
      v-to-create-report  = true
      .
    message
    substitute ("Внимание!!!&1Параметра obj НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.

  end.

  if not available glb_thbj-attr then do:
    assign
      v-to-create-report-g  = true
      .
    message
    substitute ("Внимание!!!&1Гл.Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.

  end.
  if not available frm_thbj-attr then do:
    assign
      v-to-create-report-f  = true
      .
    message
    substitute ("Внимание!!!&1 firm Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.

  end.


  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> {&update} then do:
     disable
     {&page-1p}
     {&page-2p}
     with frame {&frame-name}.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
  /* глобальные */  if not ( p-obj-type = "" and p-obj-code = 0 ) then do:
     disable
     actuate
     alcgrpgd
     ardecldt
     rep-sort
     sum-from
     sum-step
     sum-to
     sumvals
     cplot
     rep-shift-format 
     cdens
     with frame {&frame-name}.
     hide rep-excel rep-password I-rep-excel in frame {&frame-name} .
  end.
  /* по фирме */
  if not ( p-obj-type = {&cmp} or  ( p-obj-type = "" and p-obj-code = 0 ) ) then do:
     disable
     xl-delim
     with frame {&frame-name}.
  end.
  /*это редактор и он read-only*/
  if p-type = 'glob' then
  enable
  rep-sort
  cplot
  rep-shift-format
  cdens
  rep-excel
  rep-password
  with frame {&frame-name} .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    v-obj-type = p-obj-type .
    v-obj-code = p-obj-code .
    if p-obj-type <> {&cmp}  and p-obj-type <> "" then  do:

       { gbl/hostcode.i
         p-obj-type
         p-obj-code
         v-host-code
         }
        v-obj-type = {&cmp}      .
        v-obj-code = v-host-code .
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE onewin_custom-add-item Dialog-Frame 
PROCEDURE onewin_custom-add-item :
/* не менять название это callback!!!
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-onewin-handle AS HANDLE NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-ii as integer no-undo .
define variable v-is-petrolium as logical no-undo .
define variable v-is-pieces as logical no-undo .
define variable v-b-code as integer no-undo .
define variable v-exists as logical no-undo .
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
define buffer buf_goods for ub.goods.
define buffer buf_temp_onewin_items for temp_onewin_items.
case v-onewin-point :
  when {&attr-report-glob_cplot} then do:
    run ref/cashpays.w (
                   input parparentproc
                  ,input "b-mark,b-sel":U
                  ,input {&all}
                  ,input 0 /*v-host-code*/
                  ,input '' /*p-obj-type*/
                  ,input 0 /*p-obj-code*/
                  ,output v-rid-list) no-error.
    IF NOT ERROR-STATUS:ERROR
    AND v-rid-list <> '' THEN DO:
      _ii:
      do v-ii = 1 to num-entries(v-rid-list):
        FIND FIRST buf_cash-pay NO-LOCK WHERE
                  RECID(buf_cash-pay) = INTEGER(entry(v-ii, v-rid-list)) NO-ERROR.
        IF AVAILABLE buf_cash-pay THEN DO:
          if buf_cash-pay.curr-code <> 0 then do:
            message
            substitute("Нельзя добавить тип кассового платежа с валютой, отличной от национальной&1"  +
                      "Игнорируем выбор платежа &2 (код &3 валюта &4)"
                      , {&new-line}
                      , buf_cash-pay.obj-name
                      , buf_cash-pay.cdpay-code
                      , buf_cash-pay.curr-code
                      )
            view-as alert-box warning .
            next _ii.
          end.
          find first buf_temp_onewin_items where
                  buf_temp_onewin_items.itmextkey = string(buf_cash-pay.cdpay-code) no-error.
          if not available temp_onewin_items then do:
            run onewin_check-item in p-onewin-handle (
                                                       input string(buf_cash-pay.cdpay-code)
                                                      ,output v-exists) no-error.
            if v-exists then do:
              message
              "Вы уже выбрали этот тип кассового платежа!"
              view-as alert-box warning.
              return.
            end.
            run onewin_add-item in p-onewin-handle (
                  input string(buf_cash-pay.cdpay-code)
                , input substitute("&1-&2"
                                  , string(buf_cash-pay.cdpay-code, ">>>>9")
                                  , buf_cash-pay.obj-name
                                  )
                , ''
                , input yes
            ).
          end.
          else do:
            message
            "Вы уже выбрали этот тип кассового платежа!"
            view-as alert-box warning.
            return.
          end.
        END.
      end. /*do v-ii = 1 to num-entries(v-rid-list):*/
    END. /*    IF NOT ERROR-STATUS:ERROR*/
  end. /*when cplot*/
  when {&attr-report-glob_rep-sort} then do:
    run ref/gds-ref.p ( input parparentproc
                      , input "b-sel,b-mark"
                      , input {&current}
                      , input {&all}
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , output v-rid-list
                      ) no-error.
    IF NOT ERROR-STATUS:ERROR
    AND v-rid-list <> '' THEN DO:
      _ii:
      do v-ii = 1 to num-entries(v-rid-list):
        FIND FIRST buf_goods NO-LOCK WHERE
                  RECID(buf_goods) = INTEGER(entry(v-ii, v-rid-list)) NO-ERROR.
        IF AVAILABLE buf_goods THEN DO:
          { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code v-is-petrolium v-is-pieces no-error }
          if error-status:error
          or not v-is-petrolium
          or v-is-pieces then do:
            message
            substitute("Нельзя добавить товар с кодом &1 &2"  +
                      "Он не является весовым топливом&2" +
                      "Игнорируем выбор товара"
                      , buf_goods.gds-code
                      , {&new-line}
                      )
            view-as alert-box warning .
            next _II.
          end.

          { gbl/gdsbcode.i buf_goods.gds-code ? v-b-code no-error }
          if not error-status:error then do:
            find first buf_temp_onewin_items where
                    buf_temp_onewin_items.itmextkey = string(buf_goods.gds-code) no-error.
            if not available temp_onewin_items then do:
              run onewin_check-item in p-onewin-handle (
                                                        input string(buf_goods.gds-code)
                                                        ,output v-exists) no-error.
              if v-exists then do:
                message
                "Вы уже выбрали этот товар!"
                view-as alert-box warning.
                return.
              end.

              run onewin_add-item in p-onewin-handle (
                    input string(buf_goods.gds-code)
                  , input substitute("&1-&2"
                                    , string(buf_goods.gds-code)
                                    , buf_goods.gds-name
                                    )
                  , ''
                  , input yes
              ).
            end.
            else do:
              message
              "Вы уже выбрали этот товар!"
              view-as alert-box warning.
              return.
            end.

          end. /*if error-status:error*/
        end. /*IF AVAILABLE buf_goods THEN DO:*/
      END. /*do v-ii*/
    end. /*if not es*/
  end. /*when rep-sort*/
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE onewin_get-bttns Dialog-Frame 
PROCEDURE onewin_get-bttns :
/*------------------------------------------------------------------------------
не менять название! это callback
  ----------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER p-bttns as character no-undo .
if p-mode = {&lookup} or not p-type = 'glob'  then do:  /* Если у вас будут списки не для глобальных параметров, то увы... придется как-то разделить этот механизм */
  p-bttns = "".
end.
else do:
  p-bttns = "b-add,b-del,b-up,b-down,b-exit".
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-set_cplot Dialog-Frame 
PROCEDURE proc-set_cplot :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DEFINE VARIABLE v-local-cplot AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cur-ext-key AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-accepted AS logical NO-UNDO.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
define buffer buf_temp_onewin_items for temp_onewin_items.
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected.
run onewin_clear in this-procedure.
_ii:
DO v-ii = 1 TO NUM-ENTRIES(cplot):
  FIND FIRST buf_cash-pay NO-LOCK WHERE
            buf_cash-pay.cdpay-code = INTEGER(ENTRY(v-ii, cplot) )
       AND buf_cash-pay.curr-code = 0 NO-ERROR.
  IF AVAILABLE buf_cash-pay THEN DO:
        run onewin_add-item in this-procedure (
              input string(buf_cash-pay.cdpay-code)
            , input substitute("&1-&2"
                               , string(buf_cash-pay.cdpay-code, ">>>>9")
                               , buf_cash-pay.obj-name
                               )
            , ''
            , input yes
        ).

  END.
END.
v-onewin-point = {&attr-report-glob_cplot}.
run gbl/onewin.w (
      input parparentproc
    , input 1
    , input v-cplot
    , input "":U
    , input "&Тест"
    , input table temp_onewin_items
    , output table temp_onewin_itemsSelected
    , output v-cur-ext-key
    , output v-accepted
).
IF v-accepted THEN DO:
  FOR EACH buf_temp_onewin_itemsSelected:
    FIND FIRST buf_cash-pay NO-LOCK WHERE
              buf_cash-pay.cdpay-code = integer(buf_temp_onewin_itemsSelected.itmextkey)
        AND    buf_cash-pay.curr-code = 0
        NO-ERROR.
    IF AVAILABLE buf_cash-pay THEN DO:
      v-local-cplot = v-local-cplot + (IF v-local-cplot = '' THEN '' ELSE {&comma-char}) +
                      STRING(buf_cash-pay.cdpay-code).
    END.
  END.
  ASSIGN
  cplot = v-local-cplot.
  cplot:SCREEN-VALUE IN FRAME {&FRAME-NAME} = v-local-cplot.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-set_rep-sort Dialog-Frame 
PROCEDURE proc-set_rep-sort :
define variable v-ii as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-local_rep-sort as character no-undo .
define variable v-b-code as integer no-undo .
DEFINE VARIABLE v-cur-ext-key AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-accepted AS logical NO-UNDO.
define buffer buf_temp_onewin_items for temp_onewin_items.
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected.
run onewin_clear in this-procedure.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
do v-ii = 1 to num-entries(rep-sort):
  find first buf_goods no-lock where
          buf_goods.gds-code = integer(entry(v-ii, rep-sort)) no-error.
  if available buf_goods then do:
  run onewin_add-item in this-procedure (
        input string(buf_goods.gds-code)
      , input substitute("&1 - &2"
                          ,buf_goods.gds-code
                          ,buf_goods.gds-name)
      , ''
      , input yes
  ).
  end.
end.
v-onewin-point = {&attr-report-glob_rep-sort}.
run gbl/onewin.w (
      input parparentproc
    , input 1
    , input v-rep-sort
    , input "":U
    , input "&Тест"
    , input table temp_onewin_items
    , output table temp_onewin_itemsSelected
    , output v-cur-ext-key
    , output v-accepted
).

IF v-accepted THEN DO:
  FOR EACH buf_temp_onewin_itemsSelected:
    find first buf_goods no-lock where
              buf_goods.gds-code = integer(buf_temp_onewin_itemsSelected.itmextkey) no-error.
    if available buf_goods then do:
      assign
      v-local_rep-sort = v-local_rep-sort +
                          (if v-local_rep-sort = '' then '' else {&comma-char}) +
                          trim(string(buf_goods.gds-code)).
    end.
  end.
  assign
  rep-sort = v-local_rep-sort.
  rep-sort:screen-value in frame {&frame-name} = v-local_rep-sort.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-sale-add as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
define variable v-sameg as logical no-undo .
define variable v-samef as logical no-undo .
IF p-mode = {&LOOKUP} THEN RETURN .
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    ibs.th.gbl.gbl-var:g#db-num
    ibs.th.gbl.gbl-var:g#userid
    {&action-head-code-main}
    'actn_nakl-par_update':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.

ASSIGN
    actuate FRAME {&FRAME-NAME}
    alcgrpgd
    ardecldt
    rep-sort
    sum-from
    sum-step
    sum-to
    sumvals
    prt-z-no
    shft-qty
    cplot
    rep-shift-format
    rep-excel
    rep-password
    cdens
 .
 
assign
  fh = frame {&frame-name}:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:

    find first thbjattr_thbj-attr-o where
               recid(thbjattr_thbj-attr-o) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-o then do:
    assign
    buffer thbjattr_thbj-attr-o:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  if wh:private-data begins "recid3=" then do:
    find first thbjattr_thbj-attr-g where
               recid(thbjattr_thbj-attr-g) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-g then do:
        assign
           buffer thbjattr_thbj-attr-g:buffer-field ("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.

  if wh:private-data begins "recid4=" then do:

    find first thbjattr_thbj-attr-f where
               recid(thbjattr_thbj-attr-f) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-f then do:
    assign
    buffer thbjattr_thbj-attr-f:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.

  wh = wh:next-sibling.
end.

do transaction
on error undo, return error return-value
:

  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input {&attr-report-obj}
      , input table thbjattr_thbj-attr-o
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.

  if ( p-obj-type = "" and p-obj-code = 0 ) or p-obj-type = {&cmp} then do:
      run thbjattr_set-section in this-procedure (
            input p-obj-type
          , input p-obj-code
          , input {&attr-report-firm}
          , input table thbjattr_thbj-attr-f
      ) no-error.
      if error-status:error then do:
        message error-status:get-message(1)  skip
        return-value
        view-as alert-box.
        undo, return error.
      end.
  end.

  if p-obj-type = "" and p-obj-code = 0  then do:
      run thbjattr_set-section in this-procedure (
            input p-obj-type
          , input p-obj-code
          , input {&attr-report-glob}
          , input table thbjattr_thbj-attr-g
      ) no-error.
      if error-status:error then do:
        message error-status:get-message(1)  skip
        return-value
        view-as alert-box.
        undo, return error.
      end.
  end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

