&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*
         ! ! !  В Н И М А Н И Е  ! ! !
   не забудь: после исправления файла в UIB

   САМОЕ ГЛАВНОЕ - подставить new shared в DEFINE QUERY br-docs !!!!!!!
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История Переоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06


*/
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "История Переоценки".
{ cmp/vssrevis.i }
/* кнопки для нажатия */
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter par-doc-num as character no-undo .


define variable  p-doc-type   as character no-undo .
define variable  p-status_   as character no-undo .
define variable  p-char      as character no-undo .

define variable g-log as logical no-undo .
define variable doc-rec as recid no-undo .
define variable g#report-num as integer no-undo .

define variable p-base-code as integer no-undo .
define variable t-s   as character no-undo .
define variable p-sts as integer no-undo .


/* Local Variable Definitions ---                                       */

{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }

&Scoped-Define main-file c-price-doc

define variable filter-point as character no-undo init "История переоценки" .
define variable filter-point0 as character no-undo init "История_переоценки " .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

DEFINE /* NEW SHARED  */ var br-handle as handle no-undo.

define buffer find_code for c-price-doc .
DEFINE NEW SHARED BUFFER buf_c-price-doc FOR c-price-doc .

define temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
index pi is unique primary
f_name.

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
&Scoped-define INTERNAL-TABLES temp-changes buf_c-price-doc

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs buf_c-price-doc.doc-num buf_c-price-doc.chip-num buf_c-price-doc.bge-date buf_c-price-doc.acc-date buf_c-price-doc.is-back-date buf_c-price-doc.is-corr buf_c-price-doc.is-del buf_c-price-doc.is-del-act buf_c-price-doc.rest-qnty buf_c-price-doc.rest-sale buf_c-price-doc.host-code buf_c-price-doc.status_ buf_c-price-doc.doc-date buf_c-price-doc.fact-date buf_c-price-doc.obj-type + " " + string(buf_c-price-doc.obj-code) buf_c-price-doc.out-code buf_c-price-doc.sys-date STRING(buf_c-price-doc.sys-time-int, "HH:MM") @ buf_c-price-doc.sys-time-int buf_c-price-doc.corr-date STRING(buf_c-price-doc.corr-time, "HH:MM") @ buf_c-price-doc.corr-time buf_c-price-doc.corr-man usrfulnf(buf_c-price-doc.corr-man) buf_c-price-doc.corr-user-db-num   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs   
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH buf_c-price-doc no-lock
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_c-price-doc no-lock.
&Scoped-define TABLES-IN-QUERY-BR-docs buf_c-price-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs buf_c-price-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-Help BR-docs BR-changes 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помощь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch 
     LABEL "Фильтр" 
     SIZE 10 BY 1 TOOLTIP "Фильтрация списка"
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY BR-docs FOR 
      buf_c-price-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(30)"
      temp-changes.v_old COLUMn-LABEL "Было" format "X(35)"
      temp-changes.v_new COLUMn-LABEL "Стало" format "X(35)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90.75 BY 11.08.

DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      buf_c-price-doc.doc-num      COLUMN-LABEL "№ Переоценки"
buf_c-price-doc.chip-num      FORMAT ">>>>>>>>>9"
buf_c-price-doc.bge-date  COLUMN-LABEL "Дата внеш.!проводки"
buf_c-price-doc.acc-date  COLUMN-LABEL "Дата!проводки"
buf_c-price-doc.is-back-date COLUMN-LABEL "Корр.'задним'!числом"
buf_c-price-doc.is-corr      COLUMN-LABEL "Корректировка!АКТа"
buf_c-price-doc.is-del       COLUMN-LABEL "Удаление!переоценки"
buf_c-price-doc.is-del-act   COLUMN-LABEL "Удаление!в стат. АКТ"
buf_c-price-doc.rest-qnty
buf_c-price-doc.rest-sale
buf_c-price-doc.host-code FORMAT ">>>>>>>>>9" COLUMN-LABEL "Фирма"
buf_c-price-doc.status_    COLUMN-LABEL "Статус"
buf_c-price-doc.doc-date  FORMAT "99/99/99" COLUMN-LABEL "Дата!док-та"
buf_c-price-doc.fact-date FORMAT "99/99/99" COLUMN-LABEL "Дата!факт"
buf_c-price-doc.obj-type + " " + string(buf_c-price-doc.obj-code) COLUMN-LABEL "Объект" FORMAT "x(10)"
buf_c-price-doc.out-code  COLUMN-LABEL "ПН"
buf_c-price-doc.sys-date  COLUMN-LABEL "Дата !корректировки"
STRING(buf_c-price-doc.sys-time-int, "HH:MM")  FORMAT "x(6)" @ buf_c-price-doc.sys-time-int COLUMN-LABEL "Время!корр."
buf_c-price-doc.corr-date  COLUMN-LABEL "Дата!изменения"    LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
STRING(buf_c-price-doc.corr-time, "HH:MM")  FORMAT "x(6)" @ buf_c-price-doc.corr-time COLUMN-LABEL "Время!изменения" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_c-price-doc.corr-man   COLUMN-LABEL "Кто менял"    LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
usrfulnf(buf_c-price-doc.corr-man)   COLUMN-LABEL "Кто менял!ФИО"    LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_c-price-doc.corr-user-db-num COLUMN-LABEL "В !БД"  FORMAT ">>>>>9"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 90 BY 10.04.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-sch AT ROW 1 COL 20
     B-Help AT ROW 1 COL 81.5
     BR-docs AT ROW 2.21 COL 1.25
     BR-changes AT ROW 12.5 COL 1
     SPACE(0.00) SKIP(0.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История заказа"
         CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes BR-docs Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-sch IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2
       BR-docs:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

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
OPEN QUERY {&SELF-NAME} FOR EACH buf_c-price-doc no-lock.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История заказа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  /*
  message error-status :get-message(1) return-value .

  if error-status:error then return no-apply.
  */
  if not available buf_c-price-doc then run OpenBr (yes, no, '':U).

/*  run proc-view-changes in this-procedure no-error.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_c-price-doc then do:
  run proc-view-changes in this-procedure no-error.
end.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

/* Нaзвание таблицы */
define variable p-file-label as character no-undo .

temp-changes.l_name:RESIZABLE in browse BR-changes = true .
temp-changes.v_old:RESIZABLE  in browse BR-changes = true .
temp-changes.v_new:RESIZABLE  in browse BR-changes = true .


define buffer buf_clients for  ub.clients .
  run my-enable_ui.
  run openbr (yes, no, '':u).

  apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
  wait-for go of frame {&frame-name}.
END.
run disable_ui.

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
  ENABLE B-Cancel B-Help BR-docs BR-changes 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable_UI Dialog-Frame 
PROCEDURE my-enable_UI :
{ gbl/basecode.i par-host-code p-base-code }
  ENABLE B-Cancel
         B-sch
         B-Help
         BR-docs
         BR-changes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
def var l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.

title0 = caps(p-file-label) + {&space-char}.

{&SetCursorWait}
def var sort-column-phrase as character no-undo .

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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf_c-price-doc  /* where  buf_c-price-doc.doc-num = par-doc-num and  buf_c-price-doc.rcv-code =  par-rcv-code */

&scop flt-open-dyn_open-query  FOR EACH BUF_c-price-doc

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf_c-price-doc

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_c-price-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition  /* buf_c-price-doc.doc-num = par-doc-num and  buf_c-price-doc.rcv-code =  par-rcv-code */

&scop flt-open-find-buffer-def define buffer buf_c-price-doc for c-price-doc.

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .
       find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
       if not available buf_clients then return .
       filter-point = filter-point0 .


       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " Код фирмы " +  string(par-host-code).
      { gbl/fltopend.i
        &where-cond = " buf_c-price-doc.doc-num = par-doc-num  "
        &dyn_where-cond = " substitute(' buf_c-price-doc.doc-num =  &1 '  , ~{&double-quote~} , par-doc-num ) "
        &use-ind    = "  "
        &by         = "  " }

if not p-open-query then
REPOSITION br-docs to recid doc-rec No-ERROR.

if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.

{&SetCursorNo}
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
assign
  tbl = 'c-price-doc'
  join-tbl = 'buf_c-price-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-num', 'Внутр.№', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr ( yes, no, '':u).
END. /* Filter-Block */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame 
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-num as char no-undo.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer new_c-price-doc for ub.c-price-doc.
define buffer current_price-doc for ub.price-doc.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
for each temp-changes:
    delete temp-changes.
END.
if not available buf_c-price-doc then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
find first new_c-price-doc no-lock where
           new_c-price-doc.doc-num  = buf_c-price-doc.doc-num and
           new_c-price-doc.chip-num  > buf_c-price-doc.chip-num no-error.

if not available new_c-price-doc then do:
        find first current_price-doc no-lock where
                   current_price-doc.doc-num  = buf_c-price-doc.doc-num no-error.
            if not available current_price-doc then do:
            return error.
        end.
        buffer-compare current_price-doc  to buf_c-price-doc
        save result in v-chg-fields.
end.
else do:
    buffer-compare new_c-price-doc except chip-num corr-date corr-time corr-man corr-user-db-num to buf_c-price-doc
    save result in v-chg-fields.
end.


&scop  disp-field ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name = "~{&field-name~}":U ~
        temp-changes.l_name = ~{&field-label~} ~
        temp-changes.v_old = string(buf_c-price-doc.~{&field-name~}) ~
        temp-changes.v_new = (if available new_c-price-doc  ~
                                then string(new_c-price-doc.~{&field-name~})  ~
                                else string(current_price-doc.~{&field-name~})) ~
      . ~
  end. ~

/* message "HEADER = " skip v-chg-fields.*/

if num-entries(v-chg-fields) > 0 then do:
define variable v-1 as integer   no-undo .
v-1 = num-entries(v-chg-fields) .
do ii = 1 to v-1 :
CASE entry(ii, v-chg-fields):
&scop field-name  doc-num
&scop field-label "Номер"
{&disp-field}
&scop field-name  host-code
&scop field-label "Код фирмы"
{&disp-field}
&scop field-name  status_
&scop field-label "Статус"
{&disp-field}
&scop field-name  PS
&scop field-label "Примечание"
{&disp-field}
&scop field-name  base-rate
&scop field-label "Курс"
{&disp-field}
&scop field-name  base-scale
&scop field-label "Масш-б"
{&disp-field}
&scop field-name  doc-date
&scop field-label "Дата документа"
{&disp-field}
&scop field-name  fact-date
&scop field-label "Дата факт"
{&disp-field}
&scop field-name  fact-num
&scop field-label "Номер факт"
{&disp-field}
&scop field-name  fact-order
&scop field-label "Номер факт-ордер"
{&disp-field}
&scop field-name  fact-time
&scop field-label "Время факт закрытия"
{&disp-field}
&scop field-name  obj-code
&scop field-label "Код Объекта"
{&disp-field}
&scop field-name  obj-type
&scop field-label "Тип Объекта"
{&disp-field}
&scop field-name  out-code
&scop field-label "Номер ПН"
{&disp-field-rcv}
&scop field-name  user-db-num
&scop field-label "user-db-num"
{&disp-field-ord}

&scop field-name   acc-date
&scop field-label "проводка"
{&disp-field-ord}
&scop field-name  bge-date
&scop field-label "внеш. проводка"
{&disp-field-ord}
&scop field-name  creid
&scop field-label "создал"
{&disp-field-ord}
&scop field-name  is-back-date
&scop field-label "корр. задним числом"
{&disp-field-ord}
&scop field-name  is-corr
&scop field-label "корр.акта"
{&disp-field-ord}
&scop field-name  is-del
&scop field-label "удаление"
{&disp-field-ord}
&scop field-name  is-del-act
&scop field-label "удаление в статусе АКТ"
{&disp-field-ord}

&scop field-name  rest-base
&scop field-label "остаток в баз.вал."
{&disp-field-ord}
&scop field-name  rest-last
&scop field-label "rest-last"
{&disp-field-ord}
&scop field-name  rest-qnty
&scop field-label "остаток"
{&disp-field-ord}
&scop field-name  rest-sale
&scop field-label "rest-sale"
{&disp-field-ord}
&scop field-name  sale-base
&scop field-label "sale-base"
{&disp-field-ord}
&scop field-name  vat
&scop field-label "НДС %"
{&disp-field-ord}

&scop field-name  slt
&scop field-label "НСП %"
{&disp-field-ord}


END CASE.
end.
end.

&scop  disp-field-line ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="line" + string(ub.c-price-list.line-num ) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.строки-" + string(ub.c-price-list.line-num ) + " " + ~{&field-label~} ~
        temp-changes.v_new = string(ub.c-price-list.~{&field-name~}) ~
        temp-changes.v_old =  (if available old_c-price-list  ~
                                then string(old_c-price-list.~{&field-name~})  ~
                                else "") ~
      . ~
  end. ~


define buffer old_c-price-list for ub.c-price-list  .

for each ub.c-price-list where
         ub.c-price-list.doc-num = buf_c-price-doc.doc-num and
         ub.c-price-list.chip-num = buf_c-price-doc.chip-num
         :
     find last old_c-price-list no-lock where
         old_c-price-list.doc-num   = ub.c-price-list.doc-num  and
         old_c-price-list.artic      = ub.c-price-list.artic     and
         old_c-price-list.prod-type  = ub.c-price-list.prod-type and
         old_c-price-list.prod-code  = ub.c-price-list.prod-code and
         old_c-price-list.chip-num   < buf_c-price-doc.chip-num
         use-index pi no-error .

         if available old_c-price-list then do:
              buffer-compare ub.c-price-list to old_c-price-list
              save result in v-chg-fields.
         end.

/* message "STR = "  skip v-chg-fields. */

define variable v-2 as integer   no-undo .
v-2 = num-entries(v-chg-fields) .
        do ii = 1 to v-2 :
            CASE entry(ii, v-chg-fields):
              &scop field-name  doc-qnty
              &scop field-label "Количество"
              {&disp-field-line}

              &scop field-name  price-sale
              &scop field-label "Цена продажи"
              {&disp-field-line}

            end case.
        end.
end.
Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame 
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

