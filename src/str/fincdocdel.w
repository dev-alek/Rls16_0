&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаленные фин. документы

Автор: Кирюхин Сергей
Дата создания: 03/04/12
Author: Sergei Kiryxin
Creation date: 03/04/12

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc    as widget-handle no-undo.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-mode           as character no-undo .
define input parameter p-list           as character no-undo.


define input parameter p-host-code              like ub.c-fin-doc.host-code             no-undo .
define input parameter p-obj-type               like ub.c-fin-doc.obj-type              no-undo .
define input parameter p-obj-code               like ub.c-fin-doc.obj-code              no-undo .
define input parameter p-status_                like ub.c-fin-doc.status_               no-undo.
define input parameter p-fin-doc-type           like ub.c-fin-doc.fin-doc-type          no-undo.
define input parameter p-fin-ext-doc-type       like ub.c-fin-doc.fin-ext-doc-type      no-undo.
define input parameter p-start-date             like ub.c-fin-doc.doc-date              no-undo .
define input parameter p-end-date               like ub.c-fin-doc.doc-date              no-undo .
define input parameter p-trn-doc-code           like ub.c-fin-doc.trn-doc-code          no-undo.
define input parameter p-receiver-type          like ub.c-fin-doc.receiver-type         no-undo.
define input parameter p-receiver-code          like ub.c-fin-doc.receiver-code         no-undo.
define input parameter p-receiver-r-schet       like ub.c-fin-doc.receiver-r-schet      no-undo.
define input parameter p-payer-type             like ub.c-fin-doc.payer-type            no-undo.
define input parameter p-payer-code             like ub.c-fin-doc.payer-code            no-undo.
define input parameter p-payer-r-schet          like ub.c-fin-doc.payer-r-schet         no-undo.
define input parameter p-curr-code              like ub.c-fin-doc.curr-code             no-undo.
define input parameter p-receiver-code-schet    like ub.c-fin-doc.receiver-code-schet   no-undo.
define input parameter p-payer-code-schet       like ub.c-fin-doc.payer-code-schet      no-undo.
define input parameter p-contract-code          like ub.c-fin-doc.contract-code         no-undo.
define input parameter p-cor-acc                like ub.c-fin-doc.cor-acc               no-undo.
define input parameter p-cor-acc1               like ub.c-fin-doc.cor-acc1              no-undo.
define input parameter p-an-uchet-code          like ub.c-fin-doc.an-uchet-code         no-undo.
define input parameter p-cel-nazn-code          like ub.c-fin-doc.cel-nazn-code         no-undo.

/* Temp-Table and Buffer definitions                                    */

define buffer buf_c-fin-doc for ub.c-fin-doc.
define buffer buf_clients for ub.clients.

/* Local Variable Definitions ---                                       */
define variable print-option     as character no-undo.
define variable title0           as character no-undo.
define variable filter-point     as character no-undo init "fincdocdel".
define variable filter-point0    as character no-undo init "fincdocdel".
define variable filter-label     as character no-undo init "Удаленные фин. документы".
define variable filter-label0    as character no-undo init "Удаленные фин. документы".
define variable v-rid-list       as character no-undo.
define variable sort-column-name as character no-undo.
define variable client-option    as character no-undo.
define variable schet-option     as character no-undo.
define variable v-doc-rec        as recid no-undo.
define variable is-cash-mode     as logical no-undo init ?.
define variable v-db-num         like ub.db.db-num no-undo.
/*выше - вспомогательные переменные*/


define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Удаленыне фин. документы":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-fin-doc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_c-fin-doc

/* Definitions for BROWSE BR-c-fin-doc                                  */
&Scoped-define FIELDS-IN-QUERY-BR-c-fin-doc buf_c-fin-doc.fin-doc-type buf_c-fin-doc.prn-doc-code buf_c-fin-doc.fin-doc-code buf_c-fin-doc.doc-date buf_c-fin-doc.fact-date buf_c-fin-doc.corr-date string(buf_c-fin-doc.corr-time, "hh:mm") usrfulnf(buf_c-fin-doc.corr-user-name) buf_c-fin-doc.sum-doc buf_c-fin-doc.receiver-name buf_c-fin-doc.receiver-type + string(buf_c-fin-doc.receiver-code) buf_c-fin-doc.payer-name buf_c-fin-doc.payer-type + string(buf_c-fin-doc.payer-code)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-fin-doc   
&Scoped-define SELF-NAME BR-c-fin-doc
&Scoped-define QUERY-STRING-BR-c-fin-doc FOR EACH buf_c-fin-doc where (buf_c-fin-doc.host-code = p-curr-host-code) and (buf_c-fin-doc.is-del = yes) by buf_c-fin-doc.corr-date descending
&Scoped-define OPEN-QUERY-BR-c-fin-doc OPEN QUERY {&SELF-NAME} FOR EACH buf_c-fin-doc where (buf_c-fin-doc.host-code = p-curr-host-code) and (buf_c-fin-doc.is-del = yes) by buf_c-fin-doc.corr-date descending.
&Scoped-define TABLES-IN-QUERY-BR-c-fin-doc buf_c-fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-fin-doc buf_c-fin-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-c-fin-doc}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-lkp B-print B-sch B-Help ~
BR-c-fin-doc FILL-IN-data FILL-IN-doc-code 
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-data FILL-IN-doc-code 

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

DEFINE BUTTON b-lkp 
     LABEL "&Просм" 
     SIZE 10 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Выход" 
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE VARIABLE FILL-IN-data AS DATE FORMAT "99/99/9999":U 
     LABEL "дата удаления" 
     VIEW-AS FILL-IN 
     SIZE 12.8 BY .95 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE FILL-IN-doc-code AS CHARACTER FORMAT "X(256)":U 
     LABEL "нач. номера документа" 
     VIEW-AS FILL-IN 
     SIZE 40 BY .95 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-c-fin-doc FOR 
      buf_c-fin-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-fin-doc Dialog-Frame _FREEFORM
  QUERY BR-c-fin-doc DISPLAY
      buf_c-fin-doc.fin-doc-type                                         FORMAT "X(3)":U
      buf_c-fin-doc.prn-doc-code                                         FORMAT "X(14)":U
      buf_c-fin-doc.fin-doc-code               COLUMN-LABEL "Вн.N"       FORMAT "99999999":U
      buf_c-fin-doc.doc-date                                             FORMAT "99/99/9999":U
      buf_c-fin-doc.fact-date                  COLUMN-LABEL "Дата факт"  FORMAT "99/99/9999":U
      buf_c-fin-doc.corr-date                  COLUMN-LABEL "Дата удал." FORMAT "99/99/9999":U      
      string(buf_c-fin-doc.corr-time, "hh:mm") COLUMN-LABEL "Время"      FORMAT "X(5)":U     
      usrfulnf(buf_c-fin-doc.corr-user-name)   COLUMN-LABEL "Удалил"     FORMAT "X(14)":U      
      buf_c-fin-doc.sum-doc                                              FORMAT ">>,>>>,>>>,>>9.99":U
      buf_c-fin-doc.receiver-name              COLUMN-LABEL "Получатель" FORMAT "X(25)":U
      buf_c-fin-doc.receiver-type + string(buf_c-fin-doc.receiver-code) COLUMN-LABEL "Получатель" FORMAT "X(7)":U
      buf_c-fin-doc.payer-name                 COLUMN-LABEL "Плательщик" FORMAT "X(25)":U
      buf_c-fin-doc.payer-type + string(buf_c-fin-doc.payer-code) COLUMN-LABEL "Плательщик" FORMAT "X(7)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 16.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1.2 WIDGET-ID 10
     b-lkp AT ROW 1 COL 38 WIDGET-ID 4
     B-print AT ROW 1 COL 89 WIDGET-ID 8
     B-sch AT ROW 1 COL 92 WIDGET-ID 12
     B-Help AT ROW 1 COL 95 WIDGET-ID 18
     BR-c-fin-doc AT ROW 2.43 COL 2 WIDGET-ID 200
     FILL-IN-data AT ROW 19.81 COL 17 COLON-ALIGNED WIDGET-ID 16
     FILL-IN-doc-code AT ROW 19.81 COL 56 COLON-ALIGNED WIDGET-ID 14
     SPACE(0.99) SKIP(0.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Удаленные финансовые документы" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-fin-doc B-Help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-fin-doc
/* Query rebuild information for BROWSE BR-c-fin-doc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_c-fin-doc where (buf_c-fin-doc.host-code = p-curr-host-code) and (buf_c-fin-doc.is-del = yes) by buf_c-fin-doc.corr-date descending.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-c-fin-doc */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просм */
DO:
if not available buf_c-fin-doc then return no-apply.
run proc_lookup in this-procedure.
apply "ENTRY" to br-c-fin-doc.
if error-status:error then do:
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to BR-c-fin-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
  apply "ENTRY" to br-c-fin-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-fin-doc
&Scoped-define SELF-NAME BR-c-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-fin-doc Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-c-fin-doc IN FRAME Dialog-Frame
or RETURN OF BR-c-fin-doc IN FRAME Dialog-Frame
DO:
  apply "choose" to b-lkp in frame {&frame-name}.
  apply "ENTRY" to br-c-fin-doc.
  return no-apply.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-data
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-data Dialog-Frame
ON CTRL-J OF FILL-IN-data IN FRAME Dialog-Frame /* дата удаления */
DO:
    find next buf_c-fin-doc where (buf_c-fin-doc.host-code = p-curr-host-code) and (buf_c-fin-doc.is-del = yes) and buf_c-fin-doc.corr-date = date(FILL-IN-data:screen-value) no-error.
    if available buf_c-fin-doc
    then
    reposition BR-c-fin-doc to rowid rowid(buf_c-fin-doc).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-data Dialog-Frame
ON RETURN OF FILL-IN-data IN FRAME Dialog-Frame /* дата удаления */
DO:
    find first buf_c-fin-doc where (buf_c-fin-doc.host-code = p-curr-host-code) and (buf_c-fin-doc.is-del = yes) and buf_c-fin-doc.corr-date = date(FILL-IN-data:screen-value) no-error.
    if available buf_c-fin-doc
    then
    reposition BR-c-fin-doc to rowid rowid(buf_c-fin-doc).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-doc-code Dialog-Frame
ON CTRL-J OF FILL-IN-doc-code IN FRAME Dialog-Frame /* нач. номера документа */
DO:
    find next buf_c-fin-doc where (buf_c-fin-doc.host-code = p-curr-host-code) and (buf_c-fin-doc.is-del = yes) and buf_c-fin-doc.prn-doc-code begins FILL-IN-doc-code:screen-value no-error.
    if available buf_c-fin-doc
    then
    reposition BR-c-fin-doc to rowid rowid(buf_c-fin-doc).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-doc-code Dialog-Frame
ON RETURN OF FILL-IN-doc-code IN FRAME Dialog-Frame /* нач. номера документа */
DO:
    find first buf_c-fin-doc where (buf_c-fin-doc.host-code = p-curr-host-code) and (buf_c-fin-doc.is-del = yes) and buf_c-fin-doc.prn-doc-code begins FILL-IN-doc-code:screen-value no-error.
    if available buf_c-fin-doc
    then
    reposition BR-c-fin-doc to rowid rowid(buf_c-fin-doc).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-c-fin-doc" }
{ gbl/brwrefre.i "v-doc-rec = recid(buf_c-fin-doc). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-c-fin-doc to recid v-doc-rec no-error. v-doc-rec = ?. " }
{ gbl/setfltnm.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
  RUN enable_UI.
  RUN OpenBR in this-procedure ( input yes, input no, input '':U).
  
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
  DISPLAY FILL-IN-data FILL-IN-doc-code 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-lkp B-print B-sch B-Help BR-c-fin-doc FILL-IN-data 
         FILL-IN-doc-code 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
                        Purpose:                                                                                                                                          
                        Notes:                                                                                                                                            
        ------------------------------------------------------------------------------*/
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable title0 as character no-undo.
define variable v-filter-name as character no-undo .
title0 = frame {&frame-name}:TITLE.
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

&scop flt-open-open-query OPEN QUERY br-c-fin-doc FOR EACH buf_c-fin-doc

&scop flt-open-dyn_open-query FOR EACH buf_c-fin-doc

&scop flt-open-query-handle QUERY br-c-fin-doc:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_c-fin-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer buf_c-fin-doc for c-fin-doc.

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
filter-point = filter-point0.


    if p-open-query then do:

    end.
    filter-label = substitute("&1", filter-label0).

if p-open-query then do:
 
   for first buf_clients where buf_clients.obj-type = "орг" and buf_clients.obj-code = p-host-code :
    frame {&frame-name}:TITLE  = "Удаленные финансовые документы" + {&space-char} + substitute(" Фирма: (&1) &2", p-host-code, buf_clients.obj-name).
  end.
 
    filter-label = substitute("&1 Удаленные в статусе ФАКТ", filter-label0)
                                      .
    { gbl/fltopend.i
      &where-cond = " buf_c-fin-doc.host-code = p-host-code AND buf_c-fin-doc.is-del = yes "
      &dyn_where-cond = " substitute('buf_c-fin-doc.host-code = &1 AND buf_c-fin-doc.is-del = yes ', p-host-code)"
      &use-ind    = "  " 
      &by         = " by buf_c-fin-doc.corr-date descending " }

end.

if not p-open-query and v-doc-rec <> ? then
reposition br-c-fin-doc to recid v-doc-rec no-error.

if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-fin-doc:handle:reposition-to-rowid(v-fltopend-rowid) no-error.

run waitfram-hide in this-procedure .

apply "VALUE-CHANGED" to br-c-fin-doc in frame {&frame-name}.
apply "ENTRY" to br-c-fin-doc.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame 
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
                        Purpose:                                                                                                                                          
                        Notes:                                                                                                                                            
        ------------------------------------------------------------------------------*/
    run proc-print-list no-error.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
                        Purpose:                                                                                                                                          
                        Notes:                                                                                                                                            
        ------------------------------------------------------------------------------*/
assign
  tbl = 'c-fin-doc'
  join-tbl = 'buf_c-fin-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'.
  
run fltfield-add in this-procedure('fin-doc-type', 'Тип', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('prn-doc-code', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fin-doc-code ', 'Вн. №', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-date', 'Дата док-та', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fact-date', 'Дата факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('corr-date', 'Дата удал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('corr-time', 'Время', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('corr-user-name', 'Удалил', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('sum-doc', 'Сумма', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('receiver-name', 'Получатель', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('payer-name', 'Плательщик', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
do on stop     undo Filter-Block, leave Filter-Block
    on error   undo Filter-Block, leave Filter-Block
    on end-key undo Filter-Block, leave Filter-Block :
  run gbl/filter.w ( input parparentproc
                   , input (filter-point + {&delim-par} + filter-label)
                   , input tbl
                   , input join-tbl
                   , input fld
                   , input lab
                   , input spr
                   , input dim ).
  run OpenBr in this-procedure ( input yes, input no, input '':U).
end. /* Filter-Block */

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-list Dialog-Frame 
PROCEDURE proc-print-list :
/*------------------------------------------------------------------------------
                        Purpose: Печатает browse                                                                                                                                         
                        Notes:                                                                                                                                            
        ------------------------------------------------------------------------------*/
define variable v-doc-rec        as recid     no-undo.
define variable accum-count      as integer   no-undo.
define variable date_string      as character no-undo.
define variable c-Line           as character no-undo.
define variable c-corr-time      as character no-undo.
define variable c-corr-user-name as character no-undo.
define variable c-receiver       as character no-undo /*type + code*/.
define variable c-payer          as character no-undo /*type + code*/.

define frame c-fin-doc-list
      buf_c-fin-doc.fin-doc-type                                         format "X(4)":U
      buf_c-fin-doc.prn-doc-code                                         format "X(16)":U
      buf_c-fin-doc.fin-doc-code               column-label "Вн.N"       format "999999999":U
      buf_c-fin-doc.doc-date                                             format "99/99/9999":U
      buf_c-fin-doc.fact-date                  column-label "Дата факт"  format "99/99/9999":U
      buf_c-fin-doc.corr-date                  column-label "Дата удал." format "99/99/9999":U      
      c-corr-time                              column-label "Время"      format "X(5)":U
      c-corr-user-name                         column-label "Удалил"     format "X(16)":U
      buf_c-fin-doc.sum-doc                                              format ">>,>>>,>>>,>>9.99":U
      buf_c-fin-doc.receiver-name              column-label "Получатель" format "X(25)":U
      c-receiver                               column-label ""           format "X(7)":U
      buf_c-fin-doc.payer-name                 column-label "Плательщик" format "X(25)":U
      c-payer                                  column-label ""           format "X(7)":U
    
header  date_string at 5 format "X(35)"
    string( "Страница " ) format "X(9)" at 115 page-number(PrnLibStream) at 125 format ">>9" skip
    c-Line format "X(178)" at 1
    with width {&DOS_CW_2} down stream-io use-text    .

    c-Line = fill("-", 198).
    date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


put stream PrnLibStream
    space(25) ( frame {&frame-name}:title )
    format "x(90)" skip(1) .
    form header
    c-Line format "X(178)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    view  stream PrnLibStream frame BottomFrame .

form with frame c-fin-doc-list.

run waitfram-show in this-procedure ("Ждите...").

v-doc-rec = recid(buf_c-fin-doc).
do while available buf_c-fin-doc :
  get prev BR-c-fin-doc.
end.
get next BR-c-fin-doc.
do while available buf_c-fin-doc :
    c-corr-time = string(buf_c-fin-doc.corr-time, "hh:mm").
    c-corr-user-name = usrfulnf(buf_c-fin-doc.corr-user-name).
    c-receiver = buf_c-fin-doc.receiver-type + string(buf_c-fin-doc.receiver-code).
    c-payer = buf_c-fin-doc.payer-type + string(buf_c-fin-doc.payer-code).
    display stream PrnLibStream
        buf_c-fin-doc.fin-doc-type
        buf_c-fin-doc.prn-doc-code
        buf_c-fin-doc.fin-doc-code
        buf_c-fin-doc.doc-date
        buf_c-fin-doc.fact-date
        buf_c-fin-doc.corr-date 
        c-corr-time
        c-corr-user-name
        buf_c-fin-doc.sum-doc
        buf_c-fin-doc.receiver-name
        c-receiver
        buf_c-fin-doc.payer-name
        c-payer
        with frame c-fin-doc-list.
    down stream PrnLibStream 1
        with frame c-fin-doc-list.
        
  assign accum-count = accum-count + 1.
  get next BR-c-fin-doc.
end.

underline stream PrnLibStream
        buf_c-fin-doc.fin-doc-type
        buf_c-fin-doc.prn-doc-code
        buf_c-fin-doc.fin-doc-code
        buf_c-fin-doc.doc-date
        buf_c-fin-doc.fact-date
        buf_c-fin-doc.corr-date 
        c-corr-time
        c-corr-user-name
        buf_c-fin-doc.sum-doc
        buf_c-fin-doc.receiver-name
        c-receiver
        buf_c-fin-doc.payer-name
        c-payer
      with frame c-fin-doc-list.
display stream PrnLibStream
    "ИТОГО" @ buf_c-fin-doc.fin-doc-type
    accum-count @ buf_c-fin-doc.prn-doc-code
    with frame c-fin-doc-list.
hide  stream PrnLibStream frame BottomFrame.
hide  stream PrnLibStream frame c-fin-doc-list.
output  STREAM PrnLibStream CLOSE.
reposition BR-c-fin-doc to recid v-doc-rec no-error.
APPLY "entry" to br-c-fin-doc.

run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc_lookup Dialog-Frame 
PROCEDURE proc_lookup :
/*------------------------------------------------------------------------------
            Процедура для просмотра записей. взято из findocs.w и убрана часть с редактированием.                                                                     
    ------------------------------------------------------------------------------*/

define variable loc#log     as logical no-undo.
define variable loc-doc-rec as recid   no-undo .
define variable lock-obj    as logical no-undo .

do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-doc_lookup':U
    {&cntxt-firm}
    p-curr-host-code
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
end.

if not loc#log then return error.
case p-mode:
  when {&g___object}
  or when "type-object"
  or when "type-stat-object"
  then do:
    assign
    lock-obj = yes
    .
  end.
end.
assign
loc-doc-rec = recid(buf_c-fin-doc).
  case buf_c-fin-doc.fin-doc-type:
    when {&income-cash} then do:
            run ref/fncdoci1.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&expense-cash} then do:
            run ref/fncdoci2.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&income-cashless} then do:
            run ref/fncdoci3.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&expense-cashless} then do:
            run ref/fncdoci4.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&income-payoff} then do:
            run ref/fncdoci5.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
    when {&expense-payoff} then do:
            run ref/fncdoci6.w
                          (
                             input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input {&lookup}
                            ,input buf_c-fin-doc.host-code /*p-host-code*/
                            ,input buf_c-fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input buf_c-fin-doc.fin-ext-doc-type
                            ,input-output loc-doc-rec
                                        )
            .
    end.
end case.
if error-status:error then do:
  undo, return error .
end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

