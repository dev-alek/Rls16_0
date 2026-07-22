&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

История партий документа МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 11/12/07
Author: Polina Gridchina
Creation date: 11/12/07

Input:

Output:

*/

 /*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-coll-point     as character no-undo .  /*Справочник, Документ, Выбор, wth-ser*/
define input parameter p-edit-mode  as character no-undo . /*Редактирование, просмотр*/
define input parameter p-wth-code   as integer   no-undo.
define input parameter p-par-code   as INTEGER   no-undo.
define input parameter p-ser-code   as INTEGER   no-undo.
define input parameter p-db-num     as INTEGER no-undo.
define input parameter p-c-wth-doc    as character no-undo.
define input parameter p-w-p-code   as INTEGER no-undo.
define input parameter p-cli-type  like clients.obj-type no-undo .
define input parameter p-cli-code  like clients.obj-code no-undo .
define input parameter p-type      as character no-undo.


/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История партий документа МЦ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

define variable filter-point as character no-undo init "Партии_МЦ" .
define variable sort-column-name as character no-undo .
define variable v-prt-rec  as recid no-undo .
DEFINE VARIABLE v-out-name AS CHAR NO-UNDO format 'x(12)':U.
define variable rid-list   as character no-undo .
define variable v-SerDb    as character    no-undo.
DEFINE VARIABLE v-w-p-name AS CHAR NO-UNDO .



DEFINE BUFFER b-c-wth-doc   FOR ub.c-wth-doc.
DEFINE BUFFER b-wealth    FOR ub.wealth.
DEFINE BUFFER b-wth-par   FOR ub.wth-par.
DEFINE BUFFER b-goods     FOR ub.goods.
define buffer b-wth-ser   for ub.wth-ser.
DEFINE NEW SHARED BUFFER X_c-wth-parts FOR ub.c-wth-parts.
DEFINE BUFFER b-clients   FOR ub.clients.
define buffer buf_wth-place   for ub.wth-place.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-parts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-wth-parts

/* Definitions for BROWSE br-parts                                      */
&Scoped-define FIELDS-IN-QUERY-br-parts mark-string( recid(X_c-wth-parts), rid-list ) substitute('&1-&2',X_c-wth-parts.ser-code,X_c-wth-parts.db-num) @ v-SerDb if X_c-wth-parts.stts = 0 then X_c-wth-parts.fact-rangeFrom else ? if X_c-wth-parts.stts = 0 then X_c-wth-parts.fact-rangeTo else ? if X_c-wth-parts.stts = 0 then X_c-wth-parts.fact-qnty else 0 get-cli-name(X_c-wth-parts.obj-type,X_c-wth-parts.obj-code ) get-w-p-name(X_c-wth-parts.w-p-code, X_c-wth-parts.obj-type,X_c-wth-parts.obj-code) @ v-w-p-name get-wthparts-out-code(X_c-wth-parts.out-code) @ v-out-name X_c-wth-parts.in-code X_c-wth-parts.price-rubl X_c-wth-parts.price-base X_c-wth-parts.VAT-pc X_c-wth-parts.contract-code X_c-wth-parts.doc-rangeFrom X_c-wth-parts.doc-rangeTo X_c-wth-parts.qnty-doc X_c-wth-parts.doc-code get-cli-name(X_c-wth-parts.in-obj-type,X_c-wth-parts.out-obj-code ) get-cli-name(X_c-wth-parts.supp-type,X_c-wth-parts.supp-code ) get-cli-name(X_c-wth-parts.cli-type,X_c-wth-parts.cli-code ) get-cli-name(X_c-wth-parts.sale-obj-type,X_c-wth-parts.sale-obj-code ) get-cli-name(X_c-wth-parts.out-obj-type,X_c-wth-parts.out-obj-code ) X_c-wth-parts.fact-date X_c-wth-parts.shift-date X_c-wth-parts.shift-num X_c-wth-parts.host-code ENTRY(LOOKUP(X_c-wth-parts.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full}) X_c-wth-parts.fact-num X_c-wth-parts.fact-order X_c-wth-parts.stts X_c-wth-parts.TYPE
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-parts
&Scoped-define SELF-NAME br-parts
&Scoped-define QUERY-STRING-br-parts FOR EACH X_c-wth-parts NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-parts OPEN QUERY {&SELF-NAME} FOR EACH X_c-wth-parts NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-parts X_c-wth-parts
&Scoped-define FIRST-TABLE-IN-QUERY-br-parts X_c-wth-parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-parts}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-mark B-sel b-lkp B-sch ~
B-print B-Help RECT-1 br-parts fl-wth-code fl-wth-name fl-wth-par ~
fl-par-val fl-artic fl-prodType fl-ProdCode fl-obj-name Fn-rs-obj
&Scoped-Define DISPLAYED-OBJECTS fl-wth-code fl-wth-name fl-wth-par ~
fl-par-val fl-gds fl-artic fl-prodType fl-ProdCode fl-obj-name Fn-rs-obj

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( f-cli-type AS CHAR, f-cli-code as int  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-w-p-name Dialog-Frame
FUNCTION get-w-p-name RETURNS CHARACTER
  ( vf-w-p-code AS int ,vf-obj-type as char, vf-obj-code as int )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-wthparts-out-code Dialog-Frame
FUNCTION get-wthparts-out-code RETURNS CHARACTER
  ( vf-out-code AS CHAR )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 6.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 6.5 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 4.5 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE fl-artic AS CHARACTER FORMAT "X(16)":U INITIAL "0"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 22 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-par-val AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Номинал"
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-ProdCode AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-prodType AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-wth-code AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL "Код МЦ"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-wth-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название МЦ"
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-wth-par AS INTEGER FORMAT "999":U INITIAL 0
     LABEL "Код номинала"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Fn-rs-obj AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 2.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-parts FOR
      X_c-wth-parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-parts Dialog-Frame _FREEFORM
  QUERY br-parts NO-LOCK DISPLAY
      mark-string( recid(X_c-wth-parts), rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      substitute('&1-&2',X_c-wth-parts.ser-code,X_c-wth-parts.db-num) @ v-SerDb COLUMN-LABEL "Код серии"
      if X_c-wth-parts.stts = 0 then X_c-wth-parts.fact-rangeFrom else ? COLUMN-LABEL "Диапазон с" FORMAT "->>>>>>>>9":U
      if X_c-wth-parts.stts = 0 then X_c-wth-parts.fact-rangeTo else ? COLUMN-LABEL "по" FORMAT "->>>>>>>>9":U
      if X_c-wth-parts.stts = 0 then X_c-wth-parts.fact-qnty else 0 FORMAT "->>>,>>>,>>9":U  COLUMN-LABEL "Количество"
      get-cli-name(X_c-wth-parts.obj-type,X_c-wth-parts.obj-code )   COLUMN-LABEL "Объект"     FORMAT "X(14)":U
      get-w-p-name(X_c-wth-parts.w-p-code, X_c-wth-parts.obj-type,X_c-wth-parts.obj-code) @ v-w-p-name COLUMN-LABEL "МХ"
      get-wthparts-out-code(X_c-wth-parts.out-code) @ v-out-name COLUMN-LABEL "Документ\зона"
      X_c-wth-parts.in-code COLUMN-LABEL "Накл. порожд." FORMAT "X(14)":U
      X_c-wth-parts.price-rubl FORMAT "->>,>>>,>>9.99":U
      X_c-wth-parts.price-base FORMAT "->>,>>>,>>9.99":U
      X_c-wth-parts.VAT-pc FORMAT ">9.9<%":U
      X_c-wth-parts.contract-code COLUMN-LABEL "Договор" FORMAT "9999999":U   WIDTH 11.5
      X_c-wth-parts.doc-rangeFrom FORMAT "->,>>>,>>>,>>9":U
      X_c-wth-parts.doc-rangeTo FORMAT "->,>>>,>>>,>>9":U
      X_c-wth-parts.qnty-doc FORMAT "->>>,>>>,>>9":U
      X_c-wth-parts.doc-code COLUMN-LABEL "Документ"
      get-cli-name(X_c-wth-parts.in-obj-type,X_c-wth-parts.out-obj-code )  COLUMN-LABEL "Объект нач. приобрет."   FORMAT "X(14)":U
      get-cli-name(X_c-wth-parts.supp-type,X_c-wth-parts.supp-code )    COLUMN-LABEL "Поставщик"    FORMAT "X(14)":U
      get-cli-name(X_c-wth-parts.cli-type,X_c-wth-parts.cli-code )   COLUMN-LABEL "Покупатель"     FORMAT "X(14)":U
      get-cli-name(X_c-wth-parts.sale-obj-type,X_c-wth-parts.sale-obj-code )  COLUMN-LABEL "Объект реализ."   FORMAT "X(14)":U
      get-cli-name(X_c-wth-parts.out-obj-type,X_c-wth-parts.out-obj-code )   COLUMN-LABEL "Объект погаш."   FORMAT "X(14)":U
      X_c-wth-parts.fact-date FORMAT "99/99/99":U
      X_c-wth-parts.shift-date FORMAT "99/99/99":U
      X_c-wth-parts.shift-num FORMAT ">9":U
      X_c-wth-parts.host-code COLUMN-LABEL "Код фирмы" FORMAT ">>>>>>>>9":U
      ENTRY(LOOKUP(X_c-wth-parts.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full}) FORMAT "X(18)":U   column-label 'Расш. тип'
      X_c-wth-parts.fact-num FORMAT "->,>>>,>>9":U
      X_c-wth-parts.fact-order FORMAT "9999999999999999999999.9999999999":U
      X_c-wth-parts.stts FORMAT ">9":U
      X_c-wth-parts.TYPE
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 15.25 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 18
     b-quit AT ROW 1 COL 11 WIDGET-ID 20
     B-mark AT ROW 1 COL 21 WIDGET-ID 12
     B-sel AT ROW 1 COL 24 WIDGET-ID 16
     b-lkp AT ROW 1 COL 34 WIDGET-ID 22
     B-sch AT ROW 1 COL 80.5 WIDGET-ID 60
     B-print AT ROW 1 COL 85 WIDGET-ID 14
     B-Help AT ROW 1 COL 91.5 WIDGET-ID 8
     br-parts AT ROW 2.75 COL 1 WIDGET-ID 200
     fl-wth-code AT ROW 18.25 COL 3.5 WIDGET-ID 44
     fl-wth-name AT ROW 18.25 COL 34 COLON-ALIGNED WIDGET-ID 50
     fl-wth-par AT ROW 18.25 COL 67.5 COLON-ALIGNED WIDGET-ID 48
     fl-par-val AT ROW 18.25 COL 91 COLON-ALIGNED WIDGET-ID 52
     fl-gds AT ROW 19.25 COL 9.5 COLON-ALIGNED WIDGET-ID 58
     fl-artic AT ROW 19.25 COL 34 COLON-ALIGNED WIDGET-ID 46
     fl-prodType AT ROW 19.25 COL 61 COLON-ALIGNED WIDGET-ID 54
     fl-ProdCode AT ROW 19.25 COL 67.5 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     fl-obj-name AT ROW 19.25 COL 73 COLON-ALIGNED NO-LABEL WIDGET-ID 290
     Fn-rs-obj AT ROW 3 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 312
     RECT-1 AT ROW 18 COL 1 WIDGET-ID 300
     SPACE(0.00) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии серийных МЦ" WIDGET-ID 100.


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
/* BROWSE-TAB br-parts RECT-1 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fl-gds IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       fl-prodType:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN fl-wth-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-parts
/* Query rebuild information for BROWSE br-parts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-wth-parts NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-parts */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Партии серийных МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
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


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:

define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
/* { gbl/chk-actg.i                  */
/* v-cntxt-db-num                    */
/* v-cntxt-userid                    */
/* {&action-head-code-main}          */
/* 'actn_wealth_work':U              */
/* {&cntxt-global}                   */
/* 0                                 */
/* '':U                              */
/* 0                                 */
/* 0                                 */
/* 0                                 */
/* 0                                 */
/* true                              */
/* glog                              */
/* }                                 */
/* if NOT glog then return no-apply. */
rep-rec = recid(X_c-wth-parts).
        run str/wthcprtl.w (
                         input parparentproc
                        ,INPUT {&LOOKUP}
                        ,input rep-rec).
if rep-rec <> ? then do:
  v-prt-rec = rep-rec.
  RUn OpenBr in this-procedure .
  apply "entry" to BR-parts in frame {&frame-name}.
end.
else do:
  apply "entry" to BR-parts in frame {&frame-name}.
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
 define variable glog as logical no-undo .
   if available X_c-wth-parts then do:
     { gbl/markstrn.i X_c-wth-parts rid-list }
     br-parts:refresh().
     if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
             glog = br-parts:select-next-row ().
             apply "iteration-changed" to br-parts in frame {&frame-name}.
         end.
   end.
   apply "entry" to br-parts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
 define variable doc-rec as recid no-undo .
     doc-rec = recid( X_c-wth-parts ).
     DO WHILE available X_c-wth-parts :
           GET prev br-parts.
     END.
   run PrintProc in this-procedure no-error.
   reposition br-parts to recid doc-rec no-error.
   apply "entry" to br-parts in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
/*   { gbl/stdbtn.i }                                                      */
/*                                                                         */
/*   define variable v-ok as logical no-undo .                             */
/*   assign                                                                */
/*     v-ok = false                                                        */
/*   .                                                                     */
/*   if v-data-changed = true                                              */
/*   then do:                                                              */
/*     message                                                             */
/*       "Данные были изменены" skip                                       */
/*       "Вы действительно хотите отказаться от ВСЕХ изменений" skip       */
/*       "с момента последнего открытия окна партий?" skip                 */
/*       view-as alert-box question buttons yes-no update v-ok .           */
/*     if v-ok <> true                                                     */
/*     then do:                                                            */
/*       return no-apply .                                                 */
/*     end.                                                                */
/*   end.                                                                  */
/*                                                                         */
/*   if  v-need-check-diff-qnty = true                                     */
/*   and v-chg-qnty <> 0                                                   */
/*   then do:                                                              */
/*     message                                                             */
/*       "Необходимо создать партии с общим количеством" v-chg-qnty skip   */
/*       "Отказ от редактирования партий приведет к тому," skip            */
/*       "что не будет зарезервировано необходимое количество товара" skip */
/*       "Вы действительно хотите отказаться от редактирования партий?"    */
/*       view-as alert-box question buttons yes-no update v-ok .           */
/*     if v-ok <> true                                                     */
/*     then do:                                                            */
/*       return no-apply .                                                 */
/*     end.                                                                */
/*   end.                                                                  */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'c-wth-parts'
  join-tbl = 'X_c-wth-parts'
  dim = '0':U
  fld = '':U
  lab = '':U
  spr = '':U
  .
  run fltfield-add in this-procedure('wth-code', 'Код МЦ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ser-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('gds-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-rangeFrom', 'Диапазон с', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-rangeTo', 'Диапазон по', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'obj',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('w-p-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-code', 'Номер порожд. док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Номер договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Покупатель', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-type{&delim-flt}supp-code', 'Поставщик', 'supp',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sale-obj-type{&delim-flt}sale-obj-code', 'Объект реализации', 'obj',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-obj-type{&delim-flt}out-obj-code', 'Объект погашения', 'obj',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


    DO on stop undo, leave:
        run gbl/filter.w ( input parparentproc
                         , input filter-point
                         , input tbl
                         , input join-tbl
                         , input  fld
                         , input lab
                         , input spr
                         , input dim).
        RUN OpenBr in this-procedure .
    END .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if  available X_c-wth-parts AND (rid-list = ""  or
        b-mark:sensitive = no)
    then
     rid-list = string( recid( X_c-wth-parts ) ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-parts
&Scoped-define SELF-NAME br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts Dialog-Frame
ON VALUE-CHANGED OF br-parts IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_c-wth-parts THEN DO WITH FRAME {&FRAME-NAME}:
      DISP X_c-wth-parts.wth-code  @ fl-wth-code
           X_c-wth-parts.par-code @ fl-wth-par.
      FIND FIRST b-wealth WHERE b-wealth.wth-code = X_c-wth-parts.wth-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wealth THEN DISP b-wealth.wth-name @ fl-wth-name.
      ELSE fl-wth-name:SCREEN-VALUE = '?':U.
      FIND FIRST b-wth-par WHERE b-wth-par.wth-code =  X_c-wth-parts.wth-code AND b-wth-par.par-code = X_c-wth-parts.par-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wth-par THEN DISP b-wth-par.par-val @ fl-par-val.
      ELSE fl-par-val:SCREEN-VALUE = '?':U.
      FIND FIRST b-goods WHERE b-goods.gds-code = X_c-wth-parts.gds-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-goods THEN DO: DISP b-goods.artic     @ fl-artic
                                     b-goods.prod-type @ fl-prodType
                                     b-goods.prod-code @ fl-prodCode
                                     b-goods.gds-name  @ fl-gds.
             fl-obj-name:SCREEN-VALUE = get-cli-name(b-goods.prod-type,b-goods.prod-code).
      END.
      ELSE   ASSIGN fl-artic:SCREEN-VALUE = '?':U
             fl-prodType:SCREEN-VALUE = '?':U
             fl-prodCode:SCREEN-VALUE = '?':U
             fl-gds:SCREEN-VALUE = '?':U.

      ENABLE b-lkp  .
  END.
  ELSE DO:
      DISABLE b-lkp WITH FRAME {&FRAME-NAME}.
  END.
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
{ gbl/setfltnm.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }
{ gbl/brwrepos.i
&browse-name = "br-parts"
&line-num=5
}
CASE p-coll-point:
    WHEN "document":U THEN DO:
    END.
    OTHERWISE DO:
        message vss-workfile vss-revision vss-description skip
        "Неверный вызов - p-coll-point=" p-coll-point
        view-as alert-box ERROR.
        return.
    END.
END CASE.
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
if p-edit-mode = {&LOOKUP} THEN do:
  /* в режиме просмотра - не открываем транзакцию */
  MAIN-BLOCK:
  DO
  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  :
   /*run enable_UI . */
   run main-block-procedure no-error .
    if error-status :error
    then do:
      undo MAIN-BLOCK, LEAVE MAIN-BLOCK .
    end.
  END.
end.
else do:
      message vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова - p-edit-mode=" p-edit-mode
      view-as alert-box error.
      return.
end.
RUN disable_UI.

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
  DISPLAY fl-wth-code fl-wth-name fl-wth-par fl-par-val fl-gds fl-artic
          fl-prodType fl-ProdCode fl-obj-name Fn-rs-obj
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-mark B-sel b-lkp B-sch B-print B-Help RECT-1 br-parts
         fl-wth-code fl-wth-name fl-wth-par fl-par-val fl-artic fl-prodType
         fl-ProdCode fl-obj-name Fn-rs-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main-block-procedure Dialog-Frame
PROCEDURE main-block-procedure :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if p-wth-code > 0 or p-coll-point = {&wth-par} then do:
  find first b-wealth where b-wealth.wth-code = p-wth-code no-lock no-error.
  if not available b-wealth then do:
    message substitute("Не найдена МЦ с кодом &1!",p-wth-code)
    view-as alert-box error.
    return error.
  end.
end.
if p-par-code > 0 or p-coll-point = {&wth-par} then do:
  find first b-wth-par where b-wth-par.wth-code = p-wth-code
                          and  b-wth-par.par-code = p-par-code
  no-lock no-error.
  if not available b-wth-par then do:
    message substitute("Не найден номинал МЦ. Код номинала: &1, Код МЦ: &2!",p-par-code, p-wth-code)
    view-as alert-box error.
    return error.
  end.
end.
if p-ser-code > 0 or p-coll-point = {&wth-ser} then do:
  find first b-wth-ser where b-wth-ser.ser-code = p-ser-code
                           and b-wth-ser.db-num = p-db-num
  no-lock no-error.
  if not available b-wth-ser then do:
    message substitute("Не найдена серия МЦ. Код серии &1-&2!",p-ser-code, p-db-num)
    view-as alert-box error.
    return error.
  end.
end.

if p-coll-point = 'document':U then do:
  if p-edit-mode = {&lookup} then
  FIND FIRST b-c-wth-doc WHERE b-c-wth-doc.doc-code = p-c-wth-doc NO-LOCK NO-ERROR.
  ELSE FIND FIRST b-c-wth-doc WHERE b-c-wth-doc.doc-code = p-c-wth-doc exclusive-lock NO-ERROR.
  if not available b-c-wth-doc then do:
    message substitute("Не найден документ с номером &1!",p-c-wth-doc)
    view-as alert-box error.
    return error.
  end.

end.
run MyEnable.
RUN openBr.
wait-for 'go' of frame    Dialog-Frame  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*MESSAGE p-c-wth-doc SKIP p-curr-obj-type SKIP p-curr-obj-code  VIEW-AS ALERT-BOX.*/
br-parts:NUM-LOCKED-COLUMNS IN FRAME  {&FRAME-NAME}  = 4 .

DEF VAR rs-list AS CHAR.


IF p-coll-point = 'document' THEN DO:
    FIND FIRST b-c-wth-doc WHERE b-c-wth-doc.doc-code = p-c-wth-doc NO-LOCK NO-ERROR.
END.

ENABLE b-exit when not p-edit-mode = {&lookup}
    b-quit
    b-lkp
    br-parts
    b-sch
    b-print
    b-help
  WITH FRAME {&FRAME-NAME}.
if p-coll-point = 'document':U then do:
    if p-edit-mode = {&lookup} then  do:
      b-quit:label = 'Выход'.
    end.
end.
else do:
  b-quit:label = 'Выход'.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable l-query-was-opened as logical no-undo .
DEF VAR zone-list AS CHAR.

DEFINE VARIABLE cur-wth-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE cur-par-val AS INTEGER NO-UNDO.
DEFINE VARIABLE cur-par-unit AS CHARACTER NO-UNDO.
DEFINE VARIABLE cur-ser-name AS CHARACTER NO-UNDO.

DEFINE VARIABLE cur-wth-ext-doc-type AS character NO-UNDO.
DEFINE VARIABLE cur-wth-ext-doc-type-text AS character NO-UNDO.
DEFINE VARIABLE cur-c-wth-doc-code AS CHARACTER NO-UNDO.
zone-list = SUBSTITUTE('&1,&2,&3,&4',{&free-code},{&cli-zone},{&put-zone},{&output-code}).



IF AVAILABLE b-wealth THEN cur-wth-name = b-wealth.wth-name.
ELSE cur-wth-name = '?':U.
IF AVAILABLE b-wth-par THEN assign cur-par-val  = b-wth-par.par-val
                                   cur-par-unit = b-wth-par.par-unit.
ELSE assign cur-par-val  = ?
            cur-par-unit = '':U.
IF AVAILABLE b-c-wth-doc THEN do:
    cur-wth-ext-doc-type = b-c-wth-doc.ext-doc-type.
    cur-wth-ext-doc-type-text = ENTRY (lookup(b-c-wth-doc.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full }).
    cur-c-wth-doc-code = b-c-wth-doc.doc-code.
END.
ELSE do:
    cur-wth-ext-doc-type = '?':U.
    cur-c-wth-doc-code = '?':U.
END.
if available b-wth-ser then  cur-ser-name = b-wth-ser.series.

run waitfram-show in this-procedure (  input "Ждите...").
define variable sort-column-phrase as character no-undo .

/* sort-column-name = " fact-rangefrom ". */

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-query-handle query br-parts:handle
&scop flt-open-dyn_open-query FOR EACH X_c-wth-parts
&scop flt-open-find-buffer-name X_c-wth-parts



&scop flt-open-query-def 'DEFINE SHARED BUFFER X_c-wth-parts for ub.c-wth-parts. ~
    DEFINE shared QUERY br-parts FOR X_c-wth-parts SCROLLING. ~
    '
&scop flt-open-open-query OPEN QUERY br-parts FOR EACH X_c-wth-parts

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes



CASE p-coll-point:
    when 'document' then do:
      ASSIGN frame {&frame-name}:TITLE = substitute("Партии номинала &1 &2 МЦ &3 Документ: &4 № &5 &6 " ,cur-par-val, cur-par-unit, cur-wth-name, cur-wth-ext-doc-type-text ,cur-c-wth-doc-code, if p-edit-mode = {&lookup} then {&lookup} else "":U).
          { gbl/fltopend.i
            &where-cond = " X_c-wth-parts.wth-code = p-wth-code and X_c-wth-parts.w-p-code = p-w-p-code ~
            and X_c-wth-parts.par-code = p-par-code and X_c-wth-parts.out-code = p-c-wth-doc "
            &use-ind = "  "
            &by = " by X_c-wth-parts.fact-rangefrom "
            &dyn_where-cond = " substitute('
              X_c-wth-parts.wth-code = &2     and ~
              X_c-wth-parts.w-p-code = &3     and ~
              X_c-wth-parts.par-code = &4     and ~
              X_c-wth-parts.out-code = &1&5&1     ~
              ' ~
              , ~{&double-quote~}
              , p-wth-code  ~
              , p-w-p-code  ~
              , p-par-code  ~
              , p-c-wth-doc ~
              ) ~
              "
            &by = "' by X_c-wth-parts.fact-rangefrom '"
          }
    end.
END CASE.

if v-prt-rec <> ? then reposition br-parts to recid v-prt-rec no-error.
apply "entry" to br-parts in frame {&frame-name}.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED":U to br-parts.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame
PROCEDURE PrintProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable v-obj    as character    no-undo.
define variable v-cli    as character    no-undo.

DEFINE FRAME Wth-List
X_c-wth-parts.wth-code       column-label "Код МЦ"
v-SerDb                    column-label "Код серии"
X_c-wth-parts.fact-rangeFrom column-label "Диапазон с"
X_c-wth-parts.fact-rangeTo   column-label "Диапазон по"
X_c-wth-parts.par-code       column-label "Код номинала"
X_c-wth-parts.w-p-code       column-label "Код МХ"
v-obj                      column-label "Объект"
v-out-name                 column-label "Зона"
X_c-wth-parts.in-code        column-label "Накл. порожд."
v-cli                      column-label "Покупатель"  format 'x(12)'


HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(138)" AT 1
with width {&A4_CW} down stream-io use-text    .
Line = fill("-", 122).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&Cs_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Wth-List  .
run waitfram-show in this-procedure ( input "Ждите...").
GET next BR-parts.
DO WHILE available X_c-wth-parts :
  Display STREAM PrnLibStream
      X_c-wth-parts.wth-code
      substitute('&1-&2',X_c-wth-parts.ser-code,X_c-wth-parts.db-num) @ v-SerDb
      X_c-wth-parts.fact-rangeFrom
      X_c-wth-parts.fact-rangeTo
      X_c-wth-parts.par-code
      X_c-wth-parts.w-p-code
      substitute('&1 &2',X_c-wth-parts.obj-type,X_c-wth-parts.obj-code) @ v-obj
      get-wthparts-out-code(X_c-wth-parts.out-code) @ v-out-name
      X_c-wth-parts.in-code
      substitute('&1 &2',X_c-wth-parts.cli-type,X_c-wth-parts.cli-code) @ v-cli
  with FRAME Wth-List .
  DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
  GET next BR-parts.
END.
UNDERLINE  STREAM PrnLibStream
    X_c-wth-parts.wth-code
    v-SerDb
    X_c-wth-parts.fact-rangeFrom
    X_c-wth-parts.fact-rangeTo
    X_c-wth-parts.par-code
    X_c-wth-parts.w-p-code
    v-obj
    v-out-name
    X_c-wth-parts.in-code
    v-cli
with FRAME Wth-List .
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( f-cli-type AS CHAR, f-cli-code as int  ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

For FIRST b-clients WHERE b-clients.obj-type = f-cli-type AND
                       b-clients.obj-code = f-cli-code NO-LOCK:
  return   b-clients.obj-name.
end.
RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-w-p-name Dialog-Frame
FUNCTION get-w-p-name RETURNS CHARACTER
  ( vf-w-p-code AS int ,vf-obj-type as char, vf-obj-code as int ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
if vf-w-p-code = 0 or vf-w-p-code = ? then return "":U.
for first buf_wth-place no-lock where buf_wth-place.w-p-code = vf-w-p-code
                                  and buf_wth-place.obj-type = vf-obj-type
                                  and buf_wth-place.obj-code = vf-obj-code:
  return buf_wth-place.w-p-name.
end.
return string(vf-w-p-code).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-wthparts-out-code Dialog-Frame
FUNCTION get-wthparts-out-code RETURNS CHARACTER
  ( vf-out-code AS CHAR ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
CASE vf-out-code:
    WHEN {&free-code}   THEN RETURN 'свободно'.
    WHEN {&output-code} THEN RETURN 'списано'.
    WHEN {&put-zone}    THEN RETURN 'погашено'.
    WHEN {&cli-zone}    THEN RETURN 'у клиента'.
    WHEN {&forged}      THEN RETURN 'фальш.'.
END CASE.
RETURN vf-out-code.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME