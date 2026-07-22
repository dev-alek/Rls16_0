&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame

/* ***************************  Definitions  ************************** */

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История Групп оборотов для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 03/03/05
Author: Svetlana Chernova
Creation date: 03/03/05

*/
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter par-tog-id     as integer   no-undo .
define input parameter par-tog-db-num as integer   no-undo .

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "История Групп оборотов для ценообразовани  ".
{ cmp/vssrevis.i }


define variable  p-doc-type   as character no-undo .
define variable  p-status_    as character no-undo .
define variable  p-char       as character no-undo .

define variable g-log        as logical no-undo .
define variable doc-rec      as recid no-undo .
define variable g#report-num as integer no-undo .

define variable p-base-code as integer no-undo .
define variable t-s         as character no-undo .
define variable p-sts       as integer no-undo .


/* Local Variable Definitions ---                                       */

{ cmp/trg-def.i    }
{ cmp/showinf.i    }
{ gbl/flt-def.i    }
{ gbl/cur-time.i   }
{ cmp/r-pril.i new }
{ gbl/fltfield.i   }
{ gbl/prn-lib.i    }
{ gbl/waitfram.i   }
{ gbl/fltopend.i defproc }

&Scoped-Define main-file ub.c-turnover-group

define variable filter-point  as character no-undo init "История Групп оборотов для ценообразовани" .
define variable filter-point0 as character no-undo init "История_Групп_оборотов_для_ценообразовани" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

DEFINE /* NEW SHARED  */ var br-handle as handle no-undo.

define buffer find_code for ub.c-turnover-group .
DEFINE BUFFER buf_c-turnover-group FOR ub.c-turnover-group .

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

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes buf_c-turnover-group

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs buf_c-turnover-group.code-value buf_c-turnover-group.descr buf_c-turnover-group.tog-id buf_c-turnover-group.pdf-id {&status-int-name} @ t-s buf_c-turnover-group.level-1 "Уровень1" buf_c-turnover-group.level-2 "Уровень2" buf_c-turnover-group.level-3 "Уровень3"
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH buf_c-turnover-group no-lock
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_c-turnover-group no-lock.
&Scoped-define TABLES-IN-QUERY-BR-docs buf_c-turnover-group
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs buf_c-turnover-group


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
      buf_c-turnover-group SCROLLING.
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
buf_c-turnover-group.chip-num   FORMAT ">>>>>>>>>9"
buf_c-turnover-group.name      COLUMN-LABEL "Наименование группы ! " FORMAT "x(30)"
buf_c-turnover-group.sys-date   COLUMN-LABEL "Дата"
buf_c-turnover-group.sys-time-chr COLUMN-LABEL "Время" FORMAT "x(5)"
buf_c-turnover-group.corr-date  COLUMN-LABEL "Дата!изм"    LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
STRING(buf_c-turnover-group.corr-time, "HH:MM")    @ buf_c-turnover-group.corr-time COLUMN-LABEL "Время!изм" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_c-turnover-group.corr-user-name   COLUMN-LABEL "Кто менял" FORMAT "x(10)"   LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_c-turnover-group.corr-user-db-num COLUMN-LABEL "В !БД"  FORMAT ">>>>9"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 90 BY 10.04.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-sch AT ROW 1 COL 11
     B-Help AT ROW 1 COL 81.5
     BR-docs AT ROW 2.21 COL 1.25
     BR-changes AT ROW 12.5 COL 1
     SPACE(0.00) SKIP(0.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История Группы оборотов для ценообразования"
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
                                                                        */
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes BR-docs Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-sch IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

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
OPEN QUERY {&SELF-NAME} FOR EACH buf_c-turnover-group no-lock.
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История Справочника Кодов аналитического учета */
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
  if not available buf_c-turnover-group then run OpenBr (yes, no, '':U).

/*  run proc-view-changes in this-procedure no-error.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_c-turnover-group then do:
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
  p-file-label =  "История Группы объектов для ценообразования".

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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf_c-turnover-group

&scop flt-open-dyn_open-query  FOR EACH buf_c-turnover-group

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf_c-turnover-group

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_c-turnover-group

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer buf_c-turnover-group for ub.c-turnover-group.

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .
       filter-point = filter-point0 .


       ASSIGN frame {&frame-name}:TITLE = title0 .
      { gbl/fltopend.i
        &where-cond = " buf_c-turnover-group.tog-id = par-tog-id and buf_c-turnover-group.tog-db-num = par-tog-db-num "
        &dyn_where-cond =  " substitute ( ' buf_c-turnover-group.tog-id = &1 and buf_c-turnover-group.tog-db-num = &2 ', par-tog-id , par-tog-db-num ) "
        &use-ind    = "  "
        &by         = "  " }

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
  tbl = 'c-turnover-group'
  join-tbl = 'buf_c-turnover-group'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('tog-id', 'Внутр.№', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('who', '', 'usr', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', '', 'usr', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr (yes, no, '':u).
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
define input parameter partog-id as char no-undo.

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
define buffer old_c-turnover-group   for ub.c-turnover-group.
define buffer current_turnover-group for ub.turnover-group.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
for each temp-changes:
    delete temp-changes.
END.
if not available buf_c-turnover-group then do:
  open query br-changes for each temp-changes.
  return.
end.

find first old_c-turnover-group no-lock where
           old_c-turnover-group.tog-id      = buf_c-turnover-group.tog-id and
           old_c-turnover-group.tog-db-num  = buf_c-turnover-group.tog-db-num and
           old_c-turnover-group.chip-num  <   buf_c-turnover-group.chip-num no-error.

if not available old_c-turnover-group then do:
        find first current_turnover-group no-lock where
                   current_turnover-group.tog-id      = buf_c-turnover-group.tog-id and
                   current_turnover-group.tog-db-num  = buf_c-turnover-group.tog-db-num
                   no-error.
        if not available current_turnover-group then do:
            return error.
        end.
        buffer-compare current_turnover-group  to buf_c-turnover-group
        save result in v-chg-fields.
end.
else do:
    buffer-compare old_c-turnover-group except chip-num corr-date corr-time corr-user-name corr-user-db-num to buf_c-turnover-group
    save result in v-chg-fields.
end.

&scop  disp-field ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name = "~{&field-name~}":U ~
        temp-changes.l_name = ~{&field-label~} ~
        temp-changes.v_new  = string(buf_c-turnover-group.~{&field-name~}) ~
        temp-changes.v_old  = (if available old_c-turnover-group  ~
                                then string(old_c-turnover-group.~{&field-name~})  ~
                                else "Создание шапки" ) ~
        . ~
  end.

/*  message "HEADER = " skip v-chg-fields. */

if num-entries(v-chg-fields) > 0 then do:
do ii = 1 to num-entries(v-chg-fields):
CASE entry(ii, v-chg-fields):
&scop field-name db-num-chg
 &scop field-label "БД изм."
{&disp-field}
&scop field-name name
&scop field-label "Наименование"
{&disp-field}
&scop field-name tog-db-num
 &scop field-label "ДБ "
{&disp-field}
&scop field-name tog-id
 &scop field-label "№ группы"
{&disp-field}
&scop field-name stts
 &scop field-label "Статус"
{&disp-field}
&scop field-name sys-date
 &scop field-label "Дата"
{&disp-field}
&scop field-name sys-time-chr
 &scop field-label "Время"
{&disp-field}
&scop field-name sys-time
 &scop field-label "Время (int)"
{&disp-field}
&scop field-name who
 &scop field-label "Кто"
{&disp-field}

END CASE.
end.
end.

/* DB */

define buffer old_c-tnv-in-turnover-group for ub.c-tnv-in-turnover-group  .
for each ub.c-tnv-in-turnover-group where
         ub.c-tnv-in-turnover-group.tog-id      = buf_c-turnover-group.tog-id     and
         ub.c-tnv-in-turnover-group.tog-db-num  = buf_c-turnover-group.tog-db-num and
         ub.c-tnv-in-turnover-group.chip-num    = buf_c-turnover-group.chip-num
         :
     find first old_c-tnv-in-turnover-group no-lock where
         old_c-tnv-in-turnover-group.tog-id      = ub.c-tnv-in-turnover-group.tog-id    and
         old_c-tnv-in-turnover-group.tog-db-num  = ub.c-tnv-in-turnover-group.tog-db-num and
         old_c-tnv-in-turnover-group.ttg-summa  = ub.c-tnv-in-turnover-group.ttg-summa     and
         old_c-tnv-in-turnover-group.chip-num    < ub.c-tnv-in-turnover-group.chip-num
         use-index pi no-error .

         if available old_c-tnv-in-turnover-group then do:
            buffer-compare old_c-tnv-in-turnover-group except chip-num corr-date corr-time corr-user-name corr-user-db-num  to ub.c-tnv-in-turnover-group
            save result in v-chg-fields.
         end.

            /* message "STR line = "  skip v-chg-fields. */

&scop  disp-field-line ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="oborot"  + string(ub.c-tnv-in-turnover-group.ttg-summa ) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.Оборот-"   + string(ub.c-tnv-in-turnover-group.ttg-summa ) + " " + ~{&field-label~} ~
        temp-changes.v_new = string(ub.c-tnv-in-turnover-group.~{&field-name~}) ~
        temp-changes.v_old =  (if available old_c-tnv-in-turnover-group  ~
                                then string(old_c-tnv-in-turnover-group.~{&field-name~})  ~
                                else "" ) ~
      . ~
  end. ~

&scop  disp-field-line-status ~
  when "~{&field-name~}":U then do: ~
    if ub.c-tnv-in-turnover-group.stts = 1 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="oborot"   + string(ub.c-tnv-in-turnover-group.ttg-summa ) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.Оборот-"   + string(ub.c-tnv-in-turnover-group.ttg-summa ) + " " + ~{&field-label~} ~
        temp-changes.v_new = "удален" ~
        temp-changes.v_old =  (if available old_c-tnv-in-turnover-group  ~
                                then "текущий" ~
                                else "" ) ~
      . ~
     end. ~
    if ub.c-tnv-in-turnover-group.stts = 0 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="oborot"   + string(ub.c-tnv-in-turnover-group.ttg-summa ) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.Оборот-"   + string(ub.c-tnv-in-turnover-group.ttg-summa ) + " " + ~{&field-label~} ~
        temp-changes.v_new = "текущий" ~
        temp-changes.v_old =  (if available old_c-tnv-in-turnover-group  ~
                                then "удален" ~
                                else "" ) ~
      . ~
     end. ~
  end. ~


  IF num-entries(v-chg-fields) = 0 THEN DO:
    create temp-changes.
      assign
        temp-changes.f_name = "oborot" + string(ub.c-tnv-in-turnover-group.ttg-summa ) + "ADD":U
        temp-changes.l_name = "Доб.Оборот-"   + string(ub.c-tnv-in-turnover-group.ttg-summa )
        temp-changes.v_new  = ""
        temp-changes.v_old  = ""
      .
  END.

   do ii = 1 to num-entries(v-chg-fields):
  CASE entry(ii, v-chg-fields):
&scop field-name ttg-summa
&scop field-label "Оборот "
{&disp-field-line}
&scop field-name tog-db-num
&scop field-label "БД ТПЛ"
{&disp-field-line}
&scop field-name tog-id
&scop field-label "№ ТПЛ"
{&disp-field-line}
&scop field-name stts
&scop field-label "Статус строки"
{&disp-field-line-status}
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