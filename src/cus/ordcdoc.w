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

История заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История заказа ".
{ cmp/vssrevis.i }
/*кнопки для нажатия*/
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter par-doc-code as character no-undo .
define input parameter par-rcv-code as character no-undo .


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

&Scoped-Define main-file c-ord-doc

define variable filter-point as character no-undo init "История заказа1" .
define variable filter-point0 as character no-undo init "История_заказа1 " .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

DEFINE /* NEW SHARED  */ var br-handle as handle no-undo.

define buffer find_code for ub.c-ord-doc .
DEFINE NEW SHARED BUFFER buf_c-ord-doc FOR ub.c-ord-doc .

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
&Scoped-define INTERNAL-TABLES temp-changes buf_c-ord-doc

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs buf_c-ord-doc.chip-num buf_c-ord-doc.doc-code buf_c-ord-doc.rcv-code buf_c-ord-doc.host-code buf_c-ord-doc.doc-type buf_c-ord-doc.status_ buf_c-ord-doc.flag_ buf_c-ord-doc.doc-date buf_c-ord-doc.fact-date buf_c-ord-doc.ship-date buf_c-ord-doc.cli-type + " " + string(buf_c-ord-doc.cli-code) buf_c-ord-doc.obj-type + " " + string(buf_c-ord-doc.obj-code) STRING(buf_c-ord-doc.ship-time, "HH:MM") @ buf_c-ord-doc.ship-time /*STRING(buf_c-ord-doc.fact-ship-time, "HH:MM") @ buf_c-ord-doc.fact-ship-time */ buf_c-ord-doc.cons-code buf_c-ord-doc.sys-date STRING(buf_c-ord-doc.sys-time-int, "HH:MM") @ buf_c-ord-doc.sys-time-int buf_c-ord-doc.corr-date STRING(buf_c-ord-doc.corr-time, "HH:MM") @ buf_c-ord-doc.corr-time buf_c-ord-doc.corr-user-name usrfulnf (buf_c-ord-doc.corr-user-name) buf_c-ord-doc.corr-user-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH buf_c-ord-doc no-lock
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_c-ord-doc no-lock.
&Scoped-define TABLES-IN-QUERY-BR-docs buf_c-ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs buf_c-ord-doc


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
      buf_c-ord-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(130)"
      temp-changes.v_old COLUMn-LABEL "Было" format "X(35)"
      temp-changes.v_new COLUMn-LABEL "Стало" format "X(35)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.08.

DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      buf_c-ord-doc.chip-num FORMAT ">>>>>>>>>9"
buf_c-ord-doc.doc-code COLUMN-LABEL "Заказ"
buf_c-ord-doc.rcv-code COLUMN-LABEL "Номер !Поставки"
buf_c-ord-doc.host-code FORMAT ">>>>>>>>9" COLUMN-LABEL "Фирма"
buf_c-ord-doc.doc-type
buf_c-ord-doc.status_
buf_c-ord-doc.flag_     FORMAT "+/-"
buf_c-ord-doc.doc-date  FORMAT "99/99/99"
buf_c-ord-doc.fact-date FORMAT "99/99/99"
buf_c-ord-doc.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99"
buf_c-ord-doc.cli-type + " " + string(buf_c-ord-doc.cli-code) COLUMN-LABEL "Поставщик" FORMAT "x(10)"
buf_c-ord-doc.obj-type + " " + string(buf_c-ord-doc.obj-code) COLUMN-LABEL "Объект" FORMAT "x(10)"
STRING(buf_c-ord-doc.ship-time, "HH:MM")  FORMAT "x(6)" @ buf_c-ord-doc.ship-time COLUMN-LABEL "Время доставки"
/*STRING(buf_c-ord-doc.fact-ship-time, "HH:MM")  FORMAT "x(6)" @ buf_c-ord-doc.fact-ship-time COLUMN-LABEL "Факт" */
buf_c-ord-doc.cons-code COLUMN-LABEL "СЗФП"
buf_c-ord-doc.sys-date
STRING(buf_c-ord-doc.sys-time-int, "HH:MM")  FORMAT "x(6)" @ buf_c-ord-doc.sys-time-int COLUMN-LABEL "Время"
buf_c-ord-doc.corr-date  COLUMN-LABEL "Дата!изменения"   /* LABEL-FGCOLOR 15 LABEL-BGCOLOR 3 */
STRING(buf_c-ord-doc.corr-time, "HH:MM")  FORMAT "x(6)" @ buf_c-ord-doc.corr-time COLUMN-LABEL "Время!изменения" /*LABEL-FGCOLOR 15 LABEL-BGCOLOR 3*/
buf_c-ord-doc.corr-user-name   COLUMN-LABEL "Кто менял!Код"    /*LABEL-FGCOLOR 15 LABEL-BGCOLOR 3*/
usrfulnf (buf_c-ord-doc.corr-user-name) COLUMN-LABEL "Кто менял!ФИО"   /* LABEL-FGCOLOR 15 LABEL-BGCOLOR 3*/
buf_c-ord-doc.corr-user-db-num COLUMN-LABEL "В !БД"  FORMAT ">>>>>9" /* LABEL-FGCOLOR 15 LABEL-BGCOLOR 3*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 97.75 BY 10.04.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-sch AT ROW 1 COL 11
     B-Help AT ROW 1 COL 89
     BR-docs AT ROW 2.21 COL 1.25
     BR-changes AT ROW 12.5 COL 1
     SPACE(0.12) SKIP(0.00)
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
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1
       BR-docs:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE
       BR-docs:COLUMN-MOVABLE IN FRAME Dialog-Frame         = TRUE.

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
OPEN QUERY {&SELF-NAME} FOR EACH buf_c-ord-doc no-lock.
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
  if not available buf_c-ord-doc then run OpenBr (yes, no, '':U).

/*  run proc-view-changes in this-procedure no-error.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_c-ord-doc then do:
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
{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name=br-docs }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BR-changes :handle
  ) .
run diasize_init in this-procedure .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

/* Нaзвание таблицы */
define variable p-file-label as character no-undo .
if par-rcv-code = "" then do:
  p-file-label =  "История заказа".
  buf_c-ord-doc.rcv-code:VISIBLE IN BROWSE br-docs = false .
end.
else do:
  p-file-label =  "История поставки".
end.

temp-changes.l_name:RESIZABLE in browse BR-changes = true .
temp-changes.v_old:RESIZABLE  in browse BR-changes = true .
temp-changes.v_new:RESIZABLE  in browse BR-changes = true .



define buffer buf_clients for  ub.clients .
  run my-enable_ui .
  run openbr (yes, no, '':u).
  hide B-sch in frame {&frame-name} .
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
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.

title0 = caps(p-file-label) + {&space-char}.

{&SetCursorWait}
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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf_c-ord-doc  /* where  buf_c-ord-doc.doc-code = par-doc-code and  buf_c-ord-doc.rcv-code =  par-rcv-code */

&scop flt-open-dyn_open-query  FOR EACH buf_c-ord-doc

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf_c-ord-doc

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_c-ord-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition  /* buf_c-ord-doc.doc-code = par-doc-code and  buf_c-ord-doc.rcv-code =  par-rcv-code */

&scop flt-open-find-buffer-def define buffer buf_c-ord-doc for c-ord-doc.

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .
       find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
       if not available buf_clients then return .
       filter-point = filter-point0 .


       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " Код фирмы " +  string(par-host-code).
      { gbl/fltopend.i
        &where-cond = " buf_c-ord-doc.doc-code = par-doc-code and  buf_c-ord-doc.rcv-code =  par-rcv-code  "
        &dyn_where-cond = "substitute(' buf_c-ord-doc.doc-code = &1&2&1 and  buf_c-ord-doc.rcv-code = &1&3&1 '  , ~{&double-quote~} , par-doc-code, par-rcv-code ) "
        &use-ind    = "  "
        &by         = " by buf_c-ord-doc.corr-date by buf_c-ord-doc.corr-time" }

if not p-open-query then
REPOSITION br-docs to recid doc-rec No-ERROR.
{&SetCursorNo}
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'c-ord-doc'
  join-tbl = 'buf_c-ord-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Внутр.№', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*TODO*/

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
define input parameter pardoc-code as char no-undo.

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
define buffer new_c-ord-doc for ub.c-ord-doc.
define buffer current_ord-doc for ub.ord-doc.
define buffer current_ord-doc-rcv for ub.ord-doc-rcv.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
for each temp-changes:
    delete temp-changes.
END.
if not available buf_c-ord-doc then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
find first new_c-ord-doc no-lock where
           new_c-ord-doc.doc-code  = buf_c-ord-doc.doc-code and
           new_c-ord-doc.rcv-code  = buf_c-ord-doc.rcv-code and
           new_c-ord-doc.chip-num  > buf_c-ord-doc.chip-num no-error.

if not available new_c-ord-doc then do:
    if buf_c-ord-doc.rcv-code = "" then do:
        find first current_ord-doc no-lock where
                   current_ord-doc.doc-code  = buf_c-ord-doc.doc-code no-error.
            if not available current_ord-doc then do:
            return error.
        end.
        buffer-compare current_ord-doc  to buf_c-ord-doc
        save result in v-chg-fields.
    end.
    else do:
        find first current_ord-doc-rcv no-lock where
                  current_ord-doc-rcv.rcv-code  = buf_c-ord-doc.rcv-code and
                  current_ord-doc-rcv.doc-code  = buf_c-ord-doc.doc-code no-error.
            if not available current_ord-doc-rcv then do:
            return error.
        end.
        buffer-compare current_ord-doc-rcv  to buf_c-ord-doc
        save result in v-chg-fields.
    end.
end.
else do:
    buffer-compare new_c-ord-doc except chip-num corr-date corr-time corr-user-name corr-user-db-num to buf_c-ord-doc
    save result in v-chg-fields.
end.

&scop  disp-field ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
    if buf_c-ord-doc.rcv-code = "" or  buf_c-ord-doc.rcv-code = ? then do: ~
      assign ~
        temp-changes.f_name = "~{&field-name~}":U ~
        temp-changes.l_name = ~{&field-label~} ~
        temp-changes.v_old  = string(buf_c-ord-doc.~{&field-name~}) ~
        temp-changes.v_new  = (if available new_c-ord-doc  ~
                                then string(new_c-ord-doc.~{&field-name~})  ~
                                else string(current_ord-doc.~{&field-name~})) ~
        . ~
    end. ~
    else do: ~
      assign ~
        temp-changes.f_name = "~{&field-name~}":U ~
        temp-changes.l_name = ~{&field-label~} ~
        temp-changes.v_old  = string(buf_c-ord-doc.~{&field-name~}) ~
        temp-changes.v_new  = (if available new_c-ord-doc  ~
                                then string(new_c-ord-doc.~{&field-name~})  ~
                                else string(current_ord-doc-rcv.~{&field-name~})) ~
      . ~
    end. ~
  end. ~


&scop  disp-field-rcv ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name = "~{&field-name~}":U ~
        temp-changes.l_name = ~{&field-label~} ~
        temp-changes.v_old = string(buf_c-ord-doc.~{&field-name~}) ~
        temp-changes.v_new = (if available new_c-ord-doc  ~
                                then string(new_c-ord-doc.~{&field-name~})  ~
                                else string(current_ord-doc-rcv.~{&field-name~})) ~
      . ~
  end. ~

&scop  disp-field-ord ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name = "~{&field-name~}":U ~
        temp-changes.l_name = ~{&field-label~} ~
        temp-changes.v_old = string(buf_c-ord-doc.~{&field-name~}) ~
        temp-changes.v_new = (if available new_c-ord-doc  ~
                                then string(new_c-ord-doc.~{&field-name~})  ~
                                else string(current_ord-doc.~{&field-name~})) ~
      . ~
  end. ~

&scop  disp-field-ord-rcv ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name = "~{&field-name~}":U ~
        temp-changes.l_name = ~{&field-label~} ~
        temp-changes.v_old = string(buf_c-ord-doc.~{&field-name~}) ~
        temp-changes.v_new = (if available new_c-ord-doc  ~
                                   then string(new_c-ord-doc.~{&field-name~})  ~
else (if available current_ord-doc then string(current_ord-doc.~{&field-name~}) ~
                                   else string(current_ord-doc-rcv.~{&field-name~}) )) ~
      . ~
  end. ~

/* message "HEADER = " skip v-chg-fields. */
define variable v-nn as integer   no-undo .
v-nn = num-entries (v-chg-fields) .

if v-nn  > 0 then do:
do ii = 1 to v-nn :
CASE entry(ii, v-chg-fields):
&scop field-name  doc-code
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
&scop field-label "base-rate"
{&disp-field}
&scop field-name  base-scale
&scop field-label "base-scale"
{&disp-field}
&scop field-name  cli-code
&scop field-label "Код поставщика"
{&disp-field}
&scop field-name  cli-type
&scop field-label "Тип поставщика"
{&disp-field}
&scop field-name  cons-code
&scop field-label "Номер СЗФП"
{&disp-field}
&scop field-name  cycle-day
&scop field-label "кол-во дней повтор.заказов"
{&disp-field}
&scop field-name  date-pay
&scop field-label "Статус EDI"
{&disp-field}
&scop field-name  doc-date
&scop field-label "Дата документа"
{&disp-field}
&scop field-name  doc-type
&scop field-label "Тип документа"
{&disp-field}
&scop field-name  exch-code
&scop field-label "Валюта"
{&disp-field}
&scop field-name  exch-date
&scop field-label "Дата валюты"
{&disp-field}
&scop field-name  exch-rate
&scop field-label "exch-rate"
{&disp-field}
&scop field-name  exch-scale
&scop field-label "exch-scale"
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
&scop field-name  fact-ship-time
&scop field-label "Время факт доставки"
{&disp-field-rcv}
&scop field-name  fact-time
&scop field-label "Время факт закрытия"
{&disp-field}
&scop field-name  flag_
&scop field-label "Флаг"
{&disp-field}
&scop field-name  host-code
&scop field-label "Фирма"
{&disp-field}
&scop field-name  obj-code
&scop field-label "Код Объекта"
{&disp-field}
&scop field-name  obj-type
&scop field-label "Тип объекта"
{&disp-field}
&scop field-name  order-type
&scop field-label "Тип"
{&disp-field}
&scop field-name  rcv-code
&scop field-label "Номер Поставки"
{&disp-field-rcv}
&scop field-name  real-date-create
&scop field-label "Дата создания документа"
{&disp-field}
&scop field-name  real-time-create
&scop field-label "Время создания документа"
{&disp-field}
&scop field-name  shift-date
&scop field-label "Дата смены"
{&disp-field}
&scop field-name  shift-name
&scop field-label "Номер смены"
{&disp-field}
&scop field-name  ship-date
&scop field-label "Дата доставки"
{&disp-field}
&scop field-name  ship-time
&scop field-label "Время доставки"
{&disp-field}
&scop field-name  status_
&scop field-label "Статус"
{&disp-field}
&scop field-name  sum-service
&scop field-label "Сумма серв"
{&disp-field}
&scop field-name  sum-ship
&scop field-label "Сумма доставки"
{&disp-field}
&scop field-name  tot-lines
&scop field-label "Строк всего"
{&disp-field}
&scop field-name  agnt
&scop field-label "agnt"
{&disp-field-ord}
&scop field-name  boss
&scop field-label "boss"
{&disp-field-ord}
&scop field-name  cli-name
&scop field-label "Поставщик"
{&disp-field-ord}
&scop field-name  contract-code
&scop field-label "Договор Вн.№"
{&disp-field-ord}
&scop field-name  cycle-day
&scop field-label "Дней-цикл"
{&disp-field-ord}
&scop field-name  date-sale-1
&scop field-label "период продаж с"
{&disp-field-ord}
&scop field-name  date-sale-2
&scop field-label "период продаж по"
{&disp-field-ord}
&scop field-name  doc-type
&scop field-label "Тип"
{&disp-field-ord}
&scop field-name  e-method
&scop field-label "метод расчета"
{&disp-field-ord}
&scop field-name  end-date
&scop field-label "end-date"
{&disp-field-ord}
&scop field-name  ord-method
&scop field-label "метод расчета_"
{&disp-field-ord}
&scop field-name  order-type
&scop field-label "тип заказа"
{&disp-field-ord}
&scop field-name  out-code
&scop field-label "на документ"
{&disp-field-ord}
&scop field-name  pay-code
&scop field-label "Тип платежа"
{&disp-field-ord}
&scop field-name  user-db-num
&scop field-label "БД кто менял"
{&disp-field-ord-rcv}
&scop field-name  user-name
&scop field-label "Кто менял"
{&disp-field-ord-rcv}
&scop field-name  wrkr
&scop field-label "Код Кладовщика"
{&disp-field-ord}
&scop field-name  sum-cli
&scop field-label "Сумма в ценах поставщика"
{&disp-field-ord}
&scop field-name  sum-rubl
&scop field-label "Сумма в нац.вал"
{&disp-field-ord}
&scop field-name  sum-base
&scop field-label "Сумма в баз.вал"
{&disp-field-ord}
&scop field-name  cr-fo2
&scop field-label "ФО2 сгенерировано"
{&disp-field-ord}
&scop field-name cr-fo
&scop field-label "ФО сгенерировано"
{&disp-field-ord}
&scop field-name need-fo2
&scop field-label "Нужно создать ФО2"
{&disp-field-ord}
&scop field-name need-fo
&scop field-label "Нужно создать ФО"
{&disp-field-ord}
&scop field-name fo-date2
&scop field-label "ФО2 Создано"
{&disp-field-ord}
&scop field-name fo-date
&scop field-label  "ФО создано"
{&disp-field-ord}
&scop field-name buyer-out-code
&scop field-label  "buyer-out-code"
{&disp-field-ord}
&scop field-name cli-point-code
&scop field-label  "cli-point-code"
{&disp-field-ord}
&scop field-name cli-point-db-num
&scop field-label  "cli-point-db-num"
{&disp-field-ord}
&scop field-name contract-code
&scop field-label  "№ договора"
{&disp-field-ord}
&scop field-name deliv-subj-code
&scop field-label  "Код доставки"
{&disp-field-ord}
&scop field-name deliv-type-code
&scop field-label  "Код доставки _тип"
{&disp-field-ord}
&scop field-name obj-point-code
&scop field-label  "obj-point-code"
{&disp-field-ord}
&scop field-name obj-point-db-num
&scop field-label  "obj-point-db-num"
{&disp-field-ord}
&scop field-name ord-date1
&scop field-label  "1"
{&disp-field-ord}
&scop field-name ord-date2
&scop field-label  "2"
{&disp-field-ord}
&scop field-name ord-date3
&scop field-label  "3"
{&disp-field-ord}
&scop field-name ord-dec1
&scop field-label  "4"
{&disp-field-ord}
&scop field-name ord-dec2
&scop field-label  "5"
{&disp-field-ord}
&scop field-name ord-dec3
&scop field-label  "6"
{&disp-field-ord}
&scop field-name ord-int1
&scop field-label  "7"
{&disp-field-ord}
&scop field-name ord-int2
&scop field-label  "8"
{&disp-field-ord}
&scop field-name ord-int3
&scop field-label  "9"
{&disp-field-ord}
&scop field-name qnty
&scop field-label  "Количество"
{&disp-field-ord}
&scop field-name sub-par
&scop field-label  "10"
{&disp-field-ord}
&scop field-name transport-cli-code
&scop field-label  "transport-cli-code"
{&disp-field-ord}
&scop field-name transport-cli-type
&scop field-label  "transport-cli-type"
{&disp-field-ord}
&scop field-name transport-condition
&scop field-label  "Условия доставки"
{&disp-field-ord}
&scop field-name transport-contract
&scop field-label  "Транспортный договор"
{&disp-field-ord}
&scop field-name transport-host-code
&scop field-label  "Фирма ТрДоговора"
{&disp-field-ord}
&scop field-name transport-value
&scop field-label  "Сумма транспортных расходов"
{&disp-field-ord}
&scop field-name transport-VAT
&scop field-label  "транспортный НДС"
{&disp-field-ord}
&scop field-name VAT-type
&scop field-label  "Тип НДС"
{&disp-field-ord}


END CASE.
end.
end.

&scop  disp-field-line ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="line" + string(ub.c-ord-line.line-num ) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.строки-" + string(ub.c-ord-line.line-num ) + " " + ~{&field-label~} ~
        temp-changes.v_new = string(ub.c-ord-line.~{&field-name~}) ~
        temp-changes.v_old =  (if available old_c-ord-line  ~
                                then string(old_c-ord-line.~{&field-name~})  ~
                                else "") ~
      . ~
  end. ~


define buffer old_c-ord-line for ub.c-ord-line  .

for each ub.c-ord-line where
         ub.c-ord-line.doc-code = buf_c-ord-doc.doc-code and
         ub.c-ord-line.chip-num = buf_c-ord-doc.chip-num
         :
     find last old_c-ord-line no-lock where
         old_c-ord-line.doc-code   = ub.c-ord-line.doc-code  and
         old_c-ord-line.artic      = ub.c-ord-line.artic     and
         old_c-ord-line.prod-type  = ub.c-ord-line.prod-type and
         old_c-ord-line.prod-code  = ub.c-ord-line.prod-code and
         old_c-ord-line.chip-num   < buf_c-ord-doc.chip-num
         use-index pi no-error .

         if available old_c-ord-line then do:
              buffer-compare ub.c-ord-line to old_c-ord-line
              save result in v-chg-fields.
         end.

         /* message "STR = "  skip v-chg-fields. */
         v-nn = num-entries (v-chg-fields) .
        do ii = 1 to v-nn:
            CASE entry(ii, v-chg-fields):
              &scop field-name  status_
              &scop field-label "Статус строки"
              {&disp-field-line}

              &scop field-name  qnty
              &scop field-label "Количество"
              {&disp-field-line}

              &scop field-name  cli-qnty
              &scop field-label "Кол.во пост"
              {&disp-field-line}

              &scop field-name  price-cli
              &scop field-label "Цена поставщика"
              {&disp-field-line}

              &scop field-name  price-rubl
              &scop field-label "Цена в нац.вал."
              {&disp-field-line}

              &scop field-name  price-base
              &scop field-label "Цена в баз.вал."
              {&disp-field-line}

              &scop field-name  sum-cli
              &scop field-label "Сумма в ценах поставщика"
              {&disp-field-line}

              &scop field-name  sum-rubl
              &scop field-label "Сумма в нац.вал."
              {&disp-field-line}

              &scop field-name  sum-base
              &scop field-label "Сумма в баз.вал."
              {&disp-field-line}
              &scop field-name  sum-VAT
              &scop field-label "Сумма НДС"
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

