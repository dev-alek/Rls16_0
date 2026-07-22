&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_host FOR clients.
DEFINE BUFFER buf_obj FOR clients.
DEFINE BUFFER X_c-inkas FOR c-inkas.
DEFINE BUFFER X_inkas FOR inkas.
DEFINE BUFFER X_trn-doc FOR trn-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/01/05
Author: Bakhtadze Natalya
Creation date: 06/01/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
/*par-mode бывает
 'one'
 {&deleted}
*/
define input parameter par-mode as character no-undo .
/*кнопки для нажатия*/
define input parameter p-inkas-code like ub.c-inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
/*типы документов в выборке*/
define input-output param p-rid-list    as  char no-undo . /* список recid'ов выбранных inkas */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список продаж".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i new }
{ gbl/flt-def.i }
{ cmp/breakstr.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ str/shftnmef.i c-inkas shift-name }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable filter-label as character no-undo init "История продаж " .
define variable filter-label0 as character no-undo init "История продаж " .
define variable filter-point0 as character no-undo init "salclist" .
define variable filter-point as character no-undo init "salclist" .
define variable sort-column-name as character no-undo .
DEFINE VARIABLE varhost-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE varhost-name like ub.clients.obj-name no-undo .
define variable cas-shft as logical no-undo init no.
define variable ptwounit as logical no-undo init yes .
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .
DEFINE NEW SHARED VARIABLE br-handle as handle no-undo.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-curr-r-b AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-is-fbr-obj AS LOGICAL NO-UNDO INIT ?.
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO INIT ?.

{ ref/tmpchgs.i }
&SCOPED-DEFINE sort-clmn_2 usrfulnf(X_c-inkas.corr-user-name)
&scoped-define label-clmn_2 'Изменил'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes X_c-inkas

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs mark-string( recid(X_c-inkas), v-rid-list ) X_c-inkas.inkas-code X_c-inkas.doc-date X_c-inkas.fact-date X_c-inkas.shift-date shift-name-no-err(BUFFER X_c-inkas) X_c-inkas.real-corr-date string(X_c-inkas.corr-time, "HH:MM:SS") {&sort-clmn_2} X_c-inkas.corr-date X_c-inkas.corr-shift-date X_c-inkas.corr-shift-num X_c-inkas.netto X_c-inkas.tot-doc X_c-inkas.discnt X_c-inkas.sub-discnt X_c-inkas.qnty (X_c-inkas.discnt / X_c-inkas.tot-doc * 100) X_c-inkas.num-chk X_c-inkas.num-chk-nf X_c-inkas.status_ X_c-inkas.flag_ X_c-inkas.is-auto-born X_c-inkas.is-auto-get X_c-inkas.is-auto-rsrv X_c-inkas.is-auto-close X_c-inkas.auto-comp X_c-inkas.AUTO-fbr X_c-inkas.rest-dish X_c-inkas.rest-ingr X_c-inkas.auto-tpsi X_c-inkas.rest-tpsi   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs   
&Scoped-define SELF-NAME BR-docs
&Scoped-define OPEN-QUERY-BR-docs /* OPEN QUERY {&SELF-NAME} FOR EACH X_c-inkas NO-LOCK INDEXED-REPOSITION. */ RUN reopen-query IN THIS-PROCEDURE.
&Scoped-define TABLES-IN-QUERY-BR-docs X_c-inkas
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs X_c-inkas


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-print B-sch B-Help ~
BR-docs ED-notes sch-code sch-date sch-fact BR-changes mark-num l-qnty qnty ~
l-num-chk num-chk shop-name f-search-label 
&Scoped-Define DISPLAYED-OBJECTS ED-notes sch-code sch-date sch-fact ~
mark-num l-qnty qnty l-num-chk num-chk shop-name f-search-label 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE VARIABLE ED-notes AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-search-label AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по:" 
      VIEW-AS TEXT 
     SIZE 10.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-num-chk AS CHARACTER FORMAT "X(256)":U INITIAL "Число чеков" 
      VIEW-AS TEXT 
     SIZE 12.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-qnty AS CHARACTER FORMAT "X(256)":U INITIAL "Кол-во товара" 
      VIEW-AS TEXT 
     SIZE 13.5 BY .67 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE num-chk AS INTEGER FORMAT "->>>,>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 16.13 BY .67 NO-UNDO.

DEFINE VARIABLE qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 16.13 BY .67 NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)":U 
     LABEL "номеру" 
     VIEW-AS FILL-IN 
     SIZE 12.5 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U 
     LABEL "дате" 
     VIEW-AS FILL-IN 
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-fact AS DATE FORMAT "99/99/9999":U 
     LABEL "дате факт" 
     VIEW-AS FILL-IN 
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE shop-name AS CHARACTER FORMAT "X(25)":U 
      VIEW-AS TEXT 
     SIZE 27 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE qUERY BR-docs FOR X_c-inkas scrolling.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.

DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs NO-LOCK DISPLAY
      mark-string( recid(X_c-inkas), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
  X_c-inkas.inkas-code FORMAT "X(14)":U
  X_c-inkas.doc-date FORMAT "99/99/9999":U
  X_c-inkas.fact-date FORMAT "99/99/9999":U
  X_c-inkas.shift-date COLUMN-LABEL "Дата смены!(учета)" FORMAT "99/99/9999":U
  shift-name-no-err(BUFFER X_c-inkas) COLUMN-LABEL "№ см." FORMAT "x(6)":U
  X_c-inkas.real-corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999"
  string(X_c-inkas.corr-time, "HH:MM:SS") COLUMN-LABEL "Время корр" FORMAT "X(8)"
  {&sort-clmn_2} column-label {&label-clmn_2} FORMAT "X(12)"
  X_c-inkas.corr-date COLUMN-LABEL "Дата корр!(на объ.)" FORMAT "99/99/9999"
  X_c-inkas.corr-shift-date COLUMN-LABEL "Дата смены!корр." FORMAT "99/99/9999"
  X_c-inkas.corr-shift-num COLUMN-LABEL "№ смены!корр." FORMAT ">9"
  X_c-inkas.netto COLUMN-LABEL "Нетто" FORMAT "->>>,>>>,>>>,>>9.99":U
  X_c-inkas.tot-doc COLUMN-LABEL "Сумма товарная" FORMAT "->>>,>>>,>>>,>>9.99":U
  X_c-inkas.discnt FORMAT "->,>>>,>>>,>>9.99":U
  X_c-inkas.sub-discnt COLUMN-LABEL "Списания" FORMAT "->>>,>>>,>>9.99":U
  X_c-inkas.qnty COLUMN-LABEL "Кол-во товаров" FORMAT "->>,>>>,>>9.<<<":U
  (X_c-inkas.discnt / X_c-inkas.tot-doc * 100) COLUMN-LABEL "%" FORMAT "->>>>>9.9":U
  X_c-inkas.num-chk FORMAT ">>>,>>9":U COLUMN-LABEL "Чеков"
  X_c-inkas.num-chk-nf FORMAT ">>>,>>9":U COLUMN-LABEL "Чеков!нд"
  X_c-inkas.status_ FORMAT "X(8)":U
  X_c-inkas.flag_ COLUMN-LABEL "ОК" FORMAT "+/":U
  X_c-inkas.is-auto-born COLUMN-LABEL "Авто!созд" FORMAT "+/":U
  X_c-inkas.is-auto-get COLUMN-LABEL "Авто!чеки" FORMAT "+/":U
  X_c-inkas.is-auto-rsrv COLUMN-LABEL "Авто!резерв" FORMAT "+/":U
  X_c-inkas.is-auto-close COLUMN-LABEL "Авто!закр" FORMAT "+/":U
  X_c-inkas.auto-comp COLUMN-LABEL "Ком!пенс" FORMAT "+/":U
  X_c-inkas.AUTO-fbr  COLUMN-LABEL "Авто!пр-во" FORMAT "+/":U
  X_c-inkas.rest-dish COLUMN-LABEL "Ост-ки!блюд" FORMAT "+/":U
  X_c-inkas.rest-ingr COLUMN-LABEL "Ост-ки!ингр" FORMAT "+/":U
  X_c-inkas.auto-tpsi COLUMN-LABEL "ТПСИ" FORMAT "+/":U
  X_c-inkas.rest-tpsi COLUMN-LABEL "Ост-ки!ТПСИ" FORMAT "+/":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.63 BY 7.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-docs AT ROW 2 COL 1
     ED-notes AT ROW 9.5 COL 1 NO-LABEL
     sch-code AT ROW 12.58 COL 18.25 COLON-ALIGNED
     sch-date AT ROW 12.58 COL 41.38 COLON-ALIGNED
     sch-fact AT ROW 12.63 COL 66.25 COLON-ALIGNED
     BR-changes AT ROW 14.25 COL 1
     mark-num AT ROW 1 COL 14 NO-LABEL
     l-qnty AT ROW 11.5 COL 40.5 NO-LABEL WIDGET-ID 6
     qnty AT ROW 11.54 COL 53.25 COLON-ALIGNED NO-LABEL
     l-num-chk AT ROW 11.58 COL 5 NO-LABEL WIDGET-ID 4
     num-chk AT ROW 11.58 COL 16.25 COLON-ALIGNED NO-LABEL
     shop-name AT ROW 11.75 COL 70 COLON-ALIGNED NO-LABEL
     f-search-label AT ROW 12.75 COL 1.5 NO-LABEL
     SPACE(87.12) SKIP(6.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Продажи"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_host B "?" ? ub clients
      TABLE: buf_obj B "?" ? ub clients
      TABLE: X_c-inkas B "?" ? ub c-inkas
      TABLE: X_inkas B "?" ? ub inkas
      TABLE: X_trn-doc B "?" ? ub trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes sch-fact Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-docs:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* SETTINGS FOR FILL-IN f-search-label IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       f-search-label:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN l-num-chk IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-qnty IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH X_c-inkas NO-LOCK INDEXED-REPOSITION. */
RUN reopen-query IN THIS-PROCEDURE.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE qUERY BR-docs FOR X_c-inkas scrolling.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Продажи */
OR ENDKEY OF FRAME {&frame-name} DO:
  run gbl/markqwa.p (
                input b-mark:sensitive
               ,input v-rid-list
                ) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Продажи */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Продажи */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
  if available X_c-inkas then do:
    { gbl/markstrn.i X_c-inkas v-rid-list }
    glog = br-docs:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-docs:select-next-row ().
        apply "iteration-changed" to br-docs in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-docs in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_c-inkas then return no-apply.
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:

   if ( available X_c-inkas ) AND ( v-rid-list = ""
   or
   b-mark:sensitive = no
   ) then
    v-rid-list = string( recid( X_c-inkas ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON ANY-PRINTABLE OF BR-docs IN FRAME Dialog-Frame
DO:
  sch-code:screen-value = sch-code:screen-value + last-event:label.
    apply "entry" to sch-code in frame {&frame-name}.
apply "end" to sch-code in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-sel.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
define buffer buf_clients for ub.clients.
  if available X_c-inkas then do:
    assign
    num-chk = X_c-inkas.num-chk
    qnty = X_c-inkas.qnty
    ed-notes = replace(X_c-inkas.PS, {&delim-par}, {&space-char}).
    FIND FIRST buf_clients where
                          buf_clients.obj-type = X_c-inkas.obj-type AND
                 buf_clients.obj-code = X_c-inkas.obj-code NO-LOCK NO-ERROR.
    IF avail buf_clients then assign
    shop-name = buf_clients.obj-name.
    else shop-name = string(X_c-inkas.obj-code).
    display
    ed-notes
    num-chk
    qnty
    shop-name when (par-mode <> {&g___object} and par-mode <> {&g___new})
    with frame {&frame-name} .
   end.
   else do:
       ASSIGN
       ed-notes:SCREEN-VALUE = '':U.
        display
        '':U @ num-chk
        '':U @ qnty
        '':U shop-name
         with frame {&frame-name} .
   end.
  DEFINE VARIABLE dops as character no-undo .
  run proc-view-changes in this-procedure no-error.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
/*
    define buffer ps_inkas for inkas.
   DO on stop undo, return no-apply:
        FIND PS_inkas where recid (ps_inkas) = recid(X_c-inkas) exclusive.
        if ps_inkas.PS <> input frame {&frame-name} ed-notes then
        ps_inkas.PS = input frame {&frame-name} ed-notes.
    END.
  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
   run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
   run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* дате */
DO:
   run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-date, "doc-date") no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* дате */
DO:
    run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-fact
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact Dialog-Frame
ON CTRL-J OF sch-fact IN FRAME Dialog-Frame /* дате факт */
DO:
   run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact Dialog-Frame
ON RETURN OF sch-fact IN FRAME Dialog-Frame /* дате факт */
DO:
  run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/setfltnm.i }
{ gbl/brwrefre.i }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/curr-r-b.i
      v-curr-r-b
    }
  v-rid-list = p-rid-list.
  FIND FIRST ub.sys-ctrl NO-LOCK.
  if avail ub.sys-ctrl then do:
    FIND FIRST ub.db no-LOCK where
              ub.db.db-num = ub.sys-ctrl.db-num NO-ERROR.
    if not avail ub.db then do:
      message "Отсутствует запись о БД (db)"
      view-as alert-box ERROR.
      return error.
    end.
  END.
  CASE par-mode:
    WHEN {&deleted} + {&comma-char} + {&g___object}
    or when {&deleted} + {&comma-char} + {&company}
    then do:
      FIND FIRST buf_obj No-LOCK WHERE
                      buf_obj.obj-type = p-obj-type and
                      buf_obj.obj-code = p-obj-code No-ERROR.
      if not avail buf_obj then do:
        message vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-obj-type и/или p-obj-code"
        p-obj-type p-obj-code
        view-as alert-box ERROR.
        return.
      end.
    end.
    when 'one':U
    then do:
      FIND FIRST X_inkas No-LOCK WHERE
                      X_inkas.inkas-code = p-inkas-code No-ERROR.
      if not avail X_inkas then do:
        message vss-workfile vss-revision vss-description skip
        view-as alert-box ERROR.
        return.
      end.
    end.
    otherwise do:
        message vss-workfile vss-revision vss-description skip
        "Неверный вызов - par-mode=" par-mode
        view-as alert-box ERROR.
        return.
    end.
  end CASE.
  if par-mode = {&deleted} + {&comma-char} + {&g___object} then do:
     run get-params in this-procedure ( input p-obj-type, input p-obj-code) .
   end.
  if v-rid-list <> "":U then do:
    assign
    v-doc-rec = integer(entry(1, v-rid-list))
    .
  end.

  RUN MyEnable in this-procedure .
  RUn openbr in this-procedure ( input yes, input no, input '':U).
  Hide mark-num in frame {&frame-name} .
/*
{ gbl/mv-clmn.i
&browse-name = "br-docs"
&frame-name = "{&frame-name}"
&ext-col = 32
&start-column = 6
&prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26'"
&prev-order-column-condition_1 = " par-mode = 'object-all' "
&prev-order-column_2 = "'1,2,3,4,5,6,7,15,16,8,9,10,11,12,13,14,17,18,19,20,21,22,23,24,25,267'"
&prev-order-column-condition_2 = " par-mode <> 'object-all' "

}
*/
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
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
  DISPLAY ED-notes sch-code sch-date sch-fact mark-num l-qnty qnty l-num-chk 
          num-chk shop-name f-search-label 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-print B-sch B-Help BR-docs ED-notes sch-code 
         sch-date sch-fact BR-changes mark-num l-qnty qnty l-num-chk num-chk 
         shop-name f-search-label 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Get-params Dialog-Frame 
PROCEDURE Get-params :
define input parameter locp-obj-type like ub.clients.obj-type no-undo.
define input parameter locp-obj-code like ub.clients.obj-code no-undo.

define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.

find first ub.shop No-LOCK WHERE
ub.shop.obj-code = locp-obj-code No-ERROR.
if not available ub.shop then return.

/*найдем параметр - использовать смены на кассе или нет*/
{ gbl/cas-shft.i locp-obj-type locp-obj-code cas-shft }
  ASSIGN
  v-is-fbr-obj = ub.shop.is-catering.
  run gbl/tpsi-obj.p ( input locp-obj-type
                      ,input locp-obj-code
                      ,output v-is-tpsi-obj) no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable v-shift as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable lh as widget-handle no-undo .
define variable v-updated as character no-undo .
br-docs:num-locked-columns in frame {&frame-name} = 7.
ASSIGN
v-tab-order = "b-quit,b-mark,b-sel,b-sch,b-print,b-help," +
              "br-docs,sch-code,sch-date,sch-fact"
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
DISPLAY
ED-notes
sch-code
sch-date
sch-fact
qnty
shop-name when (par-mode <>  {&deleted} + {&comma-char} + {&g___object} )
num-chk
f-search-label
l-num-chk
l-qnty
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
B-sel when lookup("b-sel":U, bttns) > 0
B-sch
B-print
B-Help
BR-docs
ED-notes
sch-code
sch-date
sch-fact
mark-num
br-changes when not par-mode begins {&deleted}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if par-mode begins {&deleted} then do:
 assign
 v-shift = br-changes:height
fh = frame {&frame-name}:first-child
hh = fh:first-child
.

  do while valid-handle(hh):
    IF lookup(hh:type, "button,fill-in,literal,text,rectangle,Radio-set,editor") > 0
      AND hh:ROW >= br-docs:ROW + br-docs:height
      and hh:row <= 21
      and lookup(v-updated, hh:name) = 0 THEN DO:
          hh:ROW = hh:ROW + v-shift.
         assign
          v-updated = v-updated + {&comma-char} + hh:name.

          IF hh:TYPE = "fill-in"
          AND valid-handle(hh:side-label-handle) THEN dO:
            lh = hh:SIDE-LABEL-HANDLE.
            lh:ROW = lh:ROW + v-shift.
        END.
      END.
      hh = hh:next-sibling.
  END.
  assign
  br-changes:visible = no
  br-docs:height = br-docs:height + v-shift.
end.
IF par-mode = 'one'
THEN DO:
  HIDE
  f-search-label
  sch-code
  sch-date
  sch-fact
  IN FRAME {&FRAME-NAME}.
END.
IF NOT v-is-fbr-obj = YES THEN DO:
  ASSIGN
  X_c-inkas.AUTO-fbr:VISIBLE IN BROWSE br-docs = NO
  X_c-inkas.rest-dish:VISIBLE IN BROWSE br-docs = NO
  X_c-inkas.rest-ingr:VISIBLE IN BROWSE br-docs = NO
  .
END.
IF NOT v-is-tpsi-obj = YES THEN DO:
  ASSIGN
  X_c-inkas.AUTO-tpsi:VISIBLE IN BROWSE br-docs = NO
  X_c-inkas.rest-tpsi:VISIBLE IN BROWSE br-docs = NO
  .
END.
case par-mode:
  when {&deleted} + {&comma-char} + {&g___object} then do:
    assign
    frame {&frame-name} :title = substitute("Удаленные продажи по &1&2", p-obj-type, p-obj-code).
  end.
  when {&deleted} + {&comma-char} + {&company} then do:
    assign
    frame {&frame-name} :title = substitute("Удаленные продажи по фирме &1", p-host-code).
  end.
  when {&deleted} then do:
    assign
    frame {&frame-name} :title = substitute("Удаленные продажи").
  end.
  when 'one' then do:
    assign
    frame {&frame-name} :title = substitute("История продажи &1", X_inkas.inkas-code).
  end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Продажи".
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .

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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH X_c-inkas

&scop flt-open-dyn_open-query FOR EACH X_c-inkas

&scop flt-open-query-handLe QUERY br-docs:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-inkas

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-inkas


&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + par-mode.

CASE par-mode :
WHEN {&deleted} + {&comma-char} + {&g___object}       THEN DO:
   assign
   filter-label = substitute("&1 Один объект, удаленные на факт", filter-label0).
  if p-open-query then do:
    assign
    frame {&frame-name}:title = substitute("&1 &2&3 удаленные на факт",  title0, p-obj-type, p-obj-code).

  end.
  { gbl/fltopend.i
    &where-cond = " X_c-inkas.obj-type = p-obj-type ~
                and X_c-inkas.obj-code = p-obj-code ~
                and X_c-inkas.is-del = yes "
    &dyn_where-cond = " substitute('X_c-inkas.obj-type = &1&2&1 ~
                and X_c-inkas.obj-code = &3 ~
                and X_c-inkas.is-del = yes ', ~{&double-quote~}, p-obj-type, p-obj-code)"

    &use-ind    = "  "
    &by         = "  " }
END.
WHEN {&deleted} + {&comma-char} + {&company}       THEN DO:
  assign
  filter-label = substitute("&1 Один фирма, удаленные на факт", filter-label0).
  if p-open-query then do:
    assign
    frame {&frame-name}:title = substitute("&1 Фирма &2 удаленные на факт",  title0, p-host-code).

  end.
  { gbl/fltopend.i
    &where-cond = " X_c-inkas.host-code = p-host-code ~
                and X_c-inkas.is-del = yes "
    &dyn_where-cond = " substitute('X_c-inkas.host-code = &1 ~
                and X_c-inkas.is-del = yes ', ~{&double-quote~}, p-host-code)"

    &use-ind    = "  "
    &by         = "  " }
END.
WHEN {&deleted} THEN DO:
  assign
  filter-label = substitute("&1, удаленные на факт", filter-label0).
  if p-open-query then do:
    assign
    frame {&frame-name}:title = substitute("&1 удаленные на факт",  title0).

  end.

  { gbl/fltopend.i
    &where-cond = " X_c-inkas.is-del = yes "
    &use-ind    = "  "
    &by         = "  " }
END.

WHEN 'one':U  THEN DO:
  assign
  filter-label = substitute("&1, Одна продажа", filter-label0).
  if p-open-query then do:
    assign
    frame {&frame-name}:title = substitute("Продажа &1",  p-inkas-code).

  end.

    ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Продажа: &1", p-inkas-code).
  { gbl/fltopend.i
    &where-cond = " X_c-inkas.inkas-code = p-inkas-code "
    &dyn_where-cond = " substitute('X_c-inkas.inkas-code = &1&2&1', ~{&double-quote~}, p-inkas-code )"
    &use-ind    = "  "
    &by         = "  " }
END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame 
PROCEDURE proc-b-print :
DEFINE VARIABLE v-frame-width as integer no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
DEFINE VARIABLE v-for-time AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-discnt-pcnt AS decimal NO-UNDO.
define variable v-shift-name-num as character no-undo .
define variable v-for-user-name as character no-undo .
DEFINE FRAME c-inkas-list
X_c-inkas.office COLUMN-LABEL "У" FORMAT "+/-":U
X_c-inkas.inkas-code FORMAT "X(14)":U
X_c-inkas.doc-date FORMAT "99/99/9999":U
X_c-inkas.fact-date FORMAT "99/99/9999":U
X_c-inkas.shift-date COLUMN-LABEL "Дата смены!(учета)" FORMAT "99/99/9999":U
v-shift-name-num COLUMN-LABEL "№ см." FORMAT "X(6)":U
X_c-inkas.real-corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999"
v-for-time /*string(X_c-inkas.corr-time, "HH:MM:SS") */ COLUMN-LABEL "Время корр" FORMAT "X(8)"
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(12)"
X_c-inkas.corr-date COLUMN-LABEL "Дата корр!(на объ.)" FORMAT "99/99/9999"
X_c-inkas.corr-shift-date COLUMN-LABEL "Дата смены!корр." FORMAT "99/99/9999"
X_c-inkas.corr-shift-num COLUMN-LABEL "№ смены!корр." FORMAT ">9"
X_c-inkas.netto COLUMN-LABEL "Нетто" FORMAT "->>>,>>>,>>>,>>9.99":U
X_c-inkas.tot-doc COLUMN-LABEL "Сумма товарная" FORMAT "->>>,>>>,>>>,>>9.99":U
X_c-inkas.discnt FORMAT "->,>>>,>>>,>>9.99":U
X_c-inkas.sub-discnt COLUMN-LABEL "Списания" FORMAT "->>>,>>>,>>9.99":U
X_c-inkas.qnty COLUMN-LABEL "Кол-во товаров" FORMAT "->>,>>>,>>9.<<<":U
/*(X_c-inkas.discnt / X_c-inkas.tot-doc * 100)*/ v-discnt-pcnt COLUMN-LABEL "%" FORMAT "->>>>>9.9":U
X_c-inkas.num-chk FORMAT ">>>,>>9":U column-label "Чеков"
X_c-inkas.num-chk-nf FORMAT ">>>,>>9":U column-label "Чеков!нд"
X_c-inkas.status_ FORMAT "X(8)":U
X_c-inkas.flag_ COLUMN-LABEL "ОК" FORMAT "+/":U
X_c-inkas.is-auto-born COLUMN-LABEL "Авто!созд" FORMAT "+/":U
X_c-inkas.is-auto-get COLUMN-LABEL "Авто!чеки" FORMAT "+/":U
X_c-inkas.is-auto-rsrv COLUMN-LABEL "Авто!резерв" FORMAT "+/":U
X_c-inkas.is-auto-close COLUMN-LABEL "Авто!закр" FORMAT "+/":U
X_c-inkas.auto-comp COLUMN-LABEL "Ком!пенс" FORMAT "+/":U
X_c-inkas.AUTO-fbr  COLUMN-LABEL "Авто!пр-во" FORMAT "+/":U
X_c-inkas.rest-dish COLUMN-LABEL "Ост-ки!блюд" FORMAT "+/":U
X_c-inkas.rest-ingr COLUMN-LABEL "Ост-ки!ингр" FORMAT "+/":U
X_c-inkas.auto-tpsi COLUMN-LABEL "ТПСИ" FORMAT "+/":U
X_c-inkas.rest-tpsi COLUMN-LABEL "Ост-ки!ТПСИ" FORMAT "+/":U
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 198).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X({&A4_LS})" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME c-inkas-list  .
run waitfram-show in this-procedure ( input "Ждите...").


v-doc-rec = recid( X_c-inkas ).
DO WHILE available X_c-inkas :
    GET prev br-docs.
END.
GET next br-docs.
DO WHILE available X_c-inkas :
  Display STREAM PrnLibStream
  X_c-inkas.office
  X_c-inkas.inkas-code
  X_c-inkas.doc-date
  X_c-inkas.fact-date
  X_c-inkas.shift-date
  shift-name-no-err(buffer X_c-inkas) @ v-shift-name-num
  X_c-inkas.real-corr-date
  string(X_c-inkas.corr-time, "HH:MM:SS") @ v-for-time
  usrfulnf(X_c-inkas.corr-user-name) @ v-for-user-name
  X_c-inkas.corr-date
  X_c-inkas.corr-shift-date
  X_c-inkas.corr-shift-num
  X_c-inkas.netto
  X_c-inkas.tot-doc
  X_c-inkas.discnt
  X_c-inkas.sub-discnt
  X_c-inkas.qnty
  (X_c-inkas.discnt / X_c-inkas.tot-doc * 100) @ v-discnt-pcnt
  X_c-inkas.num-chk
  X_c-inkas.num-chk-nf
  X_c-inkas.status_
  X_c-inkas.flag_
  X_c-inkas.is-auto-born
  X_c-inkas.is-auto-get
  X_c-inkas.is-auto-rsrv
  X_c-inkas.is-auto-close
  X_c-inkas.auto-comp
  X_c-inkas.AUTO-fbr
  X_c-inkas.rest-dish
  X_c-inkas.rest-ingr
  X_c-inkas.auto-tpsi
  X_c-inkas.rest-tpsi
  with FRAME c-inkas .
  DOWN STREAM PrnLibStream 1
  with FRAME c-inkas  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-docs.
END.
UNDERLINE  STREAM PrnLibStream
X_c-inkas.office
X_c-inkas.inkas-code
X_c-inkas.doc-date
X_c-inkas.fact-date
X_c-inkas.shift-date
v-shift-name-num
X_c-inkas.real-corr-date
v-for-time
v-for-user-name
X_c-inkas.corr-date
X_c-inkas.corr-shift-date
X_c-inkas.corr-shift-num
X_c-inkas.netto
X_c-inkas.tot-doc
X_c-inkas.discnt
X_c-inkas.sub-discnt
X_c-inkas.qnty
v-discnt-pcnt
X_c-inkas.num-chk
X_c-inkas.num-chk-nf
X_c-inkas.status_
X_c-inkas.flag_
X_c-inkas.is-auto-born
X_c-inkas.is-auto-get
X_c-inkas.is-auto-rsrv
X_c-inkas.is-auto-close
X_c-inkas.auto-comp
X_c-inkas.AUTO-fbr
X_c-inkas.rest-dish
X_c-inkas.rest-ingr
X_c-inkas.auto-tpsi
X_c-inkas.rest-tpsi
with FRAME c-inkas  .

DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_c-inkas.inkas-code
accum-count @ v-for-user-name
with frame c-inkas-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME c-inkas-List.
output  STREAM PrnLibStream CLOSE.
reposition br-docs to recid v-doc-rec no-error.
run waitfram-hide in this-procedure .
apply "entry" to br-docs in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
tbl = 'c-inkas'
join-tbl = 'X_c-inkas'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('inkas-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('acc-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('num-chk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('num-chk-nf', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('qnty', 'Кол-во', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Услуги(для <старых> продаж)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок Смен', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
  ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
  ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
run gbl/filter.w ( INPUT parparentproc,
                  INPUT (filter-point + {&delim-par} +
                          filter-label + {&delim-par} +
                          string(yes))
                , INPUT tbl
                , INPUT join-tbl
                , INPUT fld
                , INPUT lab
                , INPUT spr
                , INPUT dim ).
RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Proc-find-code Dialog-Frame 
PROCEDURE Proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.inkas.inkas-code no-undo.
assign
sch-date = ?
sch-fact = ? .
display
sch-date
sch-fact
with frame {&frame-name}.

assign
pardoc-code = {&double-quote} + pardoc-code + {&double-quote}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input par-next  /* p-find-next  */
  ,input substitute("and X_c-inkas.inkas-code   begins &1 "
    , pardoc-code)
  ).
apply "entry":u to sch-code in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame 
PROCEDURE proc-find-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.inkas.doc-date no-undo.
define input parameter parwhat-date as character no-undo.

define variable var-datechr as character no-undo.
display
'':U @ sch-code
with frame {&frame-name}.

assign
var-datechr = string(day(par-date)) + {&slash-char} +
              string(month(par-date)) + {&slash-char} +
              string(year(par-date)).

case parwhat-date:
  when "doc-date":U then do:
    assign
    sch-fact = ?.
    display
    sch-fact
    with frame {&frame-name}.
    run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and X_c-inkas.doc-date = &1 "
      , var-datechr)
    ).
    apply "entry":u to sch-date in frame {&frame-name}.
  end.
  when "fact-date":U then do:
    assign
    sch-date = ?.
    display
    sch-date
    with frame {&frame-name}.
    run OpenBr in this-procedure
      (input false /* p-open-query */
      ,input par-next  /* p-find-next  */
      ,input substitute("and X_c-inkas.fact-date = &1 "
      , var-datechr)
      ).
    apply "entry":u to sch-fact in frame {&frame-name}.
  end.

END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-inkas then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

 &scop fields-name-list ~
 "doc-date,host-code,inkas-code,is-back-date,is-corr,is-del,PS," + ~
 "user-db-num,user-name,acc-date,auto-comp,auto-fbr,auto-tpsi,discnt,fact-date,flag_,is-auto-born,is-auto-close,is-auto-get," + ~
 "is-auto-rsrv,is-mand-sale-filter,netto,num-chk,num-chk-nf,obj-code,office,qnty,rest-dish,rest-ingr," + ~
 "rest-tpsi,sale-filter-name,sale-filter-rus,shift-date,shift-num,shift-name,status_,sub-discnt,tot-doc"


define variable v-label-param as character no-undo .

v-label-param =
  "doc-date" + {&delim-par} + "Дата док-та" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "inkas-code" + {&delim-par} + "Номер" + {&delim-par} + "" + {&delim-flf}
 + "is-back-date" + {&delim-par} + "Продажа закрыта <задним числом>" + {&delim-par} + "" + {&delim-flf}
 + "is-corr" + {&delim-par} + "Продажа корректировалась в стат. <факт>" + {&delim-par} + "" + {&delim-flf}
 + "is-del" + {&delim-par} + "Продажа удалена в статусе <факт>" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "user-db-num" + {&delim-par} + "БД продажи" + {&delim-par} + "" + {&delim-flf}
 + "user-name" + {&delim-par} + "Оператор" + {&delim-par} + "" + {&delim-flf}
 + "acc-date" + {&delim-par} + "Дата проводки" + {&delim-par} + "" + {&delim-flf}
 + "auto-comp" + {&delim-par} + "Автокомпенсация" + {&delim-par} + "" + {&delim-flf}
 + "auto-fbr" + {&delim-par} + "Автом. пр-во" + {&delim-par} + "" + {&delim-flf}
 + "auto-tpsi" + {&delim-par} + "?" + {&delim-par} + "" + {&delim-flf}
 + "discnt" + {&delim-par} + "Скидка общая" + {&delim-par} + "" + {&delim-flf}
 + "fact-date" + {&delim-par} + "Дата Факт" + {&delim-par} + "" + {&delim-flf}
 + "flag_" + {&delim-par} + "Закр для редакт." + {&delim-par} + "" + {&delim-flf}
 + "is-auto-born" + {&delim-par} + "Автосоздание" + {&delim-par} + "" + {&delim-flf}
 + "is-auto-close" + {&delim-par} + "Автозакрытие" + {&delim-par} + "" + {&delim-flf}
 + "is-auto-get" + {&delim-par} + "Аавтозакачка чеков" + {&delim-par} + "" + {&delim-flf}
 + "is-auto-rsrv" + {&delim-par} + "Авторезервирование" + {&delim-par} + "" + {&delim-flf}
 + "is-mand-sale-filter" + {&delim-par} + "Обязательно применение фильтра по чекам" + {&delim-par} + "" + {&delim-flf}
 + "netto" + {&delim-par} + "Сумма оплат" + {&delim-par} + "" + {&delim-flf}
 + "num-chk" + {&delim-par} + "Число чеков" + {&delim-par} + "" + {&delim-flf}
 + "num-chk-nf" + {&delim-par} + "Число чеков нд" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Магазин" + {&delim-par} + "" + {&delim-flf}
 + "office" + {&delim-par} + "Услуги" + {&delim-par} + "" + {&delim-flf}
 + "qnty" + {&delim-par} + "Кол-во товара" + {&delim-par} + "" + {&delim-flf}
 + "rest-dish" + {&delim-par} + "Учесть остатки блюд в автопр-ве" + {&delim-par} + "" + {&delim-flf}
 + "rest-ingr" + {&delim-par} + "Учесть остатки ингр. в автопр-ве" + {&delim-par} + "" + {&delim-flf}
 + "rest-tpsi" + {&delim-par} + "Учесть остатки ТПСИ" + {&delim-par} + "" + {&delim-flf}
 + "sale-filter-name" + {&delim-par} + "Имя фильтра по чекам" + {&delim-par} + "" + {&delim-flf}
 + "sale-filter-rus" + {&delim-par} + "Фильтр по чекам" + {&delim-par} + "" + {&delim-flf}
 + "shift-date" + {&delim-par} + "Дата смены" + {&delim-par} + "" + {&delim-flf}
 + "shift-num" + {&delim-par} + "Порядок Смен" + {&delim-par} + "" + {&delim-flf}
 + "shift-name" + {&delim-par} + "№ Смены" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "sub-discnt" + {&delim-par} + "Сумма списания" + {&delim-par} + "" + {&delim-flf}
 + "tot-doc" + {&delim-par} + "Сумма брутто в ценах продажи" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-inkas:handle
                                            ,input  {&table_inkas}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


Open QUery br-changes for each temp-changes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame 
PROCEDURE reopen-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if available X_c-inkas then v-doc-rec = recid(X_c-inkas).
run OpenBr in this-procedure( input yes, input no, input '':U).
reposition br-docs to recid v-doc-rec no-error.
apply 'value-changed' to  br-docs in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

