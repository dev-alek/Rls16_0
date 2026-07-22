

&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История типов прайс-листов

Автор: Чернова Светлана Александровна
Дата создания: 03/05/05
Author: Svetlana Chernova
Creation date: 03/05/05

*/
define input parameter parparentproc  as widget-handle no-undo.
define input parameter par-plt-id     as integer   no-undo .
define input parameter par-plt-db-num as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История типов прайс-листов".
{ cmp/vssrevis.i }
/*кнопки для нажатия*/


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
{ gbl/usrfulnf.i   }
{ gbl/fltopend.i defproc }

&Scoped-Define main-file ub.c-price-list-type

define variable filter-point  as character no-undo init "История Групп кол-в для ценообразовани" .
define variable filter-point0 as character no-undo init "История_Групп_кол-в_для_ценообразовани" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

DEFINE /* NEW SHARED  */ var br-handle as handle no-undo.

define buffer find_code for ub.c-price-list-type .
DEFINE NEW SHARED BUFFER buf_c-price-list-type FOR ub.c-price-list-type .

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
&Scoped-define INTERNAL-TABLES temp-changes buf_c-price-list-type

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs buf_c-price-list-type.code-value buf_c-price-list-type.descr buf_c-price-list-type.plt-id buf_c-price-list-type.pdf-id {&status-int-name} @ t-s buf_c-price-list-type.level-1 "Уровень1" buf_c-price-list-type.level-2 "Уровень2" buf_c-price-list-type.level-3 "Уровень3"
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH buf_c-price-list-type no-lock
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_c-price-list-type no-lock.
&Scoped-define TABLES-IN-QUERY-BR-docs buf_c-price-list-type
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs buf_c-price-list-type


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

DEFINE new shared QUERY BR-docs FOR
      buf_c-price-list-type SCROLLING.
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
buf_c-price-list-type.chip-num   FORMAT ">>>>>>>>>9"
buf_c-price-list-type.name      COLUMN-LABEL "Наименование группы ! " FORMAT "x(30)"
buf_c-price-list-type.sys-date   COLUMN-LABEL "Дата"
buf_c-price-list-type.sys-time-chr COLUMN-LABEL "Время" FORMAT "x(5)"
buf_c-price-list-type.corr-date  COLUMN-LABEL "Дата!изм"    LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
STRING(buf_c-price-list-type.corr-time, "HH:MM")    @ buf_c-price-list-type.corr-time COLUMN-LABEL "Время!изм" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_c-price-list-type.corr-user-name   COLUMN-LABEL "Кто менял" FORMAT "x(9)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
usrfulnf(buf_c-price-list-type.corr-user-name) COLUMN-LABEL "Кто менял!ФИО" FORMAT "x(15)"   LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_c-price-list-type.corr-user-db-num COLUMN-LABEL "В !БД"  FORMAT ">>>>9"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3


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
         TITLE "История Группы кол-в для ценообразования"
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
OPEN QUERY {&SELF-NAME} FOR EACH buf_c-price-list-type no-lock.
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
  if not available buf_c-price-list-type then run OpenBr (yes, no, '':U).

/*  run proc-view-changes in this-procedure no-error.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_c-price-list-type then do:
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
  p-file-label =  "История Группы кол-в для ценообразования".

temp-changes.l_name:RESIZABLE in browse BR-changes = true .
temp-changes.v_old:RESIZABLE  in browse BR-changes = true .
temp-changes.v_new:RESIZABLE  in browse BR-changes = true .


define buffer buf_clients for  ub.clients .
  RUN my-enable_UI.
  RUn OpenBR(yes, no, '':U).

  apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
  wait-for go of frame {&frame-name}.
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


&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf_c-price-list-type  /* where  buf_c-price-list-type.plt-id = par-plt-id */

&scop flt-open-dyn_open-query  FOR EACH buf_c-price-list-type

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf_c-price-list-type

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_c-price-list-type

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition  /* buf_c-price-list-type.plt-id = par-plt-id  */

&scop flt-open-find-buffer-def define buffer buf_c-price-list-type for ub.c-price-list-type.

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .
       filter-point = filter-point0 .


       ASSIGN frame {&frame-name}:TITLE = title0 .
      { gbl/fltopend.i
        &where-cond = " buf_c-price-list-type.plt-id = par-plt-id and buf_c-price-list-type.plt-db-num = par-plt-db-num "
        &dyn_where-cond = " substitute(' buf_c-price-list-type.plt-id = &1  and buf_c-price-list-type.plt-db-num = &2 ', par-plt-id , par-plt-db-num )"
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
  tbl = 'c-price-list-type'
  join-tbl = 'buf_c-price-list-type'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('plt-id', 'Внутр.№ ТПЛ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('who', '', 'usr', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

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
define input parameter parplt-id as char no-undo.

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
define buffer old_c-price-list-type   for ub.c-price-list-type.
define buffer current_price-list-type for ub.price-list-type.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
for each temp-changes:
    delete temp-changes.
END.
if not available buf_c-price-list-type then do:
  open query br-changes for each temp-changes.
  return.
end.

find first old_c-price-list-type no-lock where
           old_c-price-list-type.plt-id      = buf_c-price-list-type.plt-id and
           old_c-price-list-type.plt-db-num  = buf_c-price-list-type.plt-db-num and
           old_c-price-list-type.chip-num  <   buf_c-price-list-type.chip-num no-error.

if not available old_c-price-list-type then do:
        find first current_price-list-type no-lock where
                   current_price-list-type.plt-id      = buf_c-price-list-type.plt-id and
                   current_price-list-type.plt-db-num  = buf_c-price-list-type.plt-db-num
                   no-error.
        if not available current_price-list-type then do:
            return error.
        end.
        buffer-compare current_price-list-type  to buf_c-price-list-type
        save result in v-chg-fields.
end.
else do:
    buffer-compare old_c-price-list-type except chip-num corr-date corr-time corr-user-name corr-user-db-num to buf_c-price-list-type
    save result in v-chg-fields.
end.

&scop  disp-field ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name = "~{&field-name~}":U ~
        temp-changes.l_name = ~{&field-label~} ~
        temp-changes.v_new  = string(buf_c-price-list-type.~{&field-name~}) ~
        temp-changes.v_old  = (if available old_c-price-list-type  ~
                                then string(old_c-price-list-type.~{&field-name~})  ~
                                else "Создание шапки" ) ~
        . ~
  end.

/* message "HEADER = " skip v-chg-fields. */

if num-entries(v-chg-fields) > 0 then do:
do ii = 1 to num-entries(v-chg-fields):
CASE entry(ii, v-chg-fields):
&scop field-name db-num-chg
 &scop field-label "БД изм."
{&disp-field}
&scop field-name name
&scop field-label "Наименование"
{&disp-field}
&scop field-name plt-db-num
 &scop field-label "ДБ "
{&disp-field}
&scop field-name plt-id
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
&scop field-name ban-discnt
&scop field-label "Шавлон Скидки"
{&disp-field}
&scop field-name bgr-db-num
&scop field-label "БД"
{&disp-field}
&scop field-name bgr-id
&scop field-label "№"
{&disp-field}
&scop field-name calc-increase-pc
&scop field-label "% по умолчанию"
{&disp-field}
&scop field-name calc-method
&scop field-label "метод расчета по умолчанию"
{&disp-field}
&scop field-name calc-round-base
&scop field-label "база округления"
{&disp-field}
&scop field-name calc-round-method
&scop field-label "метод округления"
{&disp-field}
&scop field-name create-price-doc
&scop field-label "Переоценки"
{&disp-field}
&scop field-name curr-code
&scop field-label "Код валюты"
{&disp-field}
&scop field-name fix-cource-crc-base
&scop field-label "Фиксировать баз.вал."
{&disp-field}
&scop field-name fix-cource-crc-doc
&scop field-label "Фиксировать курс вал.ПЛ"
{&disp-field}
&scop field-name gop-db-num-for-calc-turnover
&scop field-label "ДБ"
{&disp-field}
&scop field-name gop-db-num
&scop field-label "ДБ"
{&disp-field}
&scop field-name gop-id-for-calc-turnover
&scop field-label "№ группы оборотов"
{&disp-field}
&scop field-name gop-id
&scop field-label "№ группы объектов"
{&disp-field}
&scop field-name have-rs-qnty-group
&scop field-label "Есть кол. группа"
{&disp-field}
&scop field-name have-rs-sum-group
&scop field-label "Есть сумм. группа"
{&disp-field}
&scop field-name have-rs-turn-group
&scop field-label "Есть группа оборотов "
{&disp-field}
&scop field-name have-tog-db-num
&scop field-label "ДБ"
{&disp-field}
&scop field-name have-tog-id
&scop field-label "№ Группы оборотов"
{&disp-field}
&scop field-name main
&scop field-label "Главный"
{&disp-field}
&scop field-name obj-turnover
&scop field-label "Объекты для оборота"
{&disp-field}
&scop field-name only-gbd
&scop field-label "Создание ПЛ только в ГБД"
{&disp-field}
&scop field-name plt-main-db-num
&scop field-label "БД главного ТПЛ"
{&disp-field}
&scop field-name plt-main-id
&scop field-label "№ главного ТПЛ"
{&disp-field}
&scop field-name priority
&scop field-label "Приоритет"
{&disp-field}
&scop field-name qgr-db-num
&scop field-label "БД кол.группы"
{&disp-field}
&scop field-name qgr-id
&scop field-label "№ кол.группы"
{&disp-field}
&scop field-name rs-buyer
&scop field-label "Связь с покупателями"
{&disp-field}
&scop field-name send-cassa
&scop field-label "На кассы"
{&disp-field}
&scop field-name sgr-db-num
&scop field-label "БД сумм.группы"
{&disp-field}
&scop field-name sgr-id
&scop field-label "№ сумм.группы"
{&disp-field}
&scop field-name tog-db-num
&scop field-label "БД группы оборотов"
{&disp-field}
&scop field-name tog-id
&scop field-label "№ группы оборотов"
{&disp-field}
&scop field-name ttg-summa
&scop field-label "Оборот в группе оборотов"
{&disp-field}
&scop field-name under-hand-corr
&scop field-label "Ручное изменение"
{&disp-field}
&scop field-name under-perc
&scop field-label "% скидки подчиненного ПЛ"
{&disp-field}
&scop field-name under-round-base
&scop field-label "база округления подчиненного ПЛ"
{&disp-field}
&scop field-name under-round-method
&scop field-label "метод округления подчиненного ПЛ"
{&disp-field}
&scop field-name under-rule
&scop field-label "правило подчиненного ПЛ"
{&disp-field}
&scop field-name under-type-list
&scop field-label "Подчиненный ПЛ"
{&disp-field}
&scop field-name use-cash-pay
&scop field-label "Огр по типам кассового пл"
{&disp-field}
&scop field-name use-cassa
&scop field-label "по кассам"
{&disp-field}
&scop field-name use-gds-group
&scop field-label "по группам товаров"
{&disp-field}
&scop field-name use-obj
&scop field-label "по объектам"
{&disp-field}
&scop field-name use-pay-type
&scop field-label "по типам платежа"
{&disp-field}
&scop field-name work-date
&scop field-label "Работа по дате на объекте"
{&disp-field}



END CASE.
end.
end.

/* GDS_GRP */

define buffer old_c-price-list-type-gds-grp for ub.c-price-list-type-gds-grp  .
for each ub.c-price-list-type-gds-grp where
         ub.c-price-list-type-gds-grp.plt-id      = buf_c-price-list-type.plt-id     and
         ub.c-price-list-type-gds-grp.plt-db-num  = buf_c-price-list-type.plt-db-num and
         ub.c-price-list-type-gds-grp.chip-num    = buf_c-price-list-type.chip-num
         :
     find first old_c-price-list-type-gds-grp no-lock where
         old_c-price-list-type-gds-grp.plt-id      = ub.c-price-list-type-gds-grp.plt-id    and
         old_c-price-list-type-gds-grp.plt-db-num  = ub.c-price-list-type-gds-grp.plt-db-num and
         old_c-price-list-type-gds-grp.node-code  = ub.c-price-list-type-gds-grp.node-code     and
         old_c-price-list-type-gds-grp.chip-num    < ub.c-price-list-type-gds-grp.chip-num
         use-index pi no-error .

         if available old_c-price-list-type-gds-grp then do:
            buffer-compare old_c-price-list-type-gds-grp except chip-num corr-date corr-time corr-user-name corr-user-db-num  to ub.c-price-list-type-gds-grp
            save result in v-chg-fields.
         end.


 /* message "STR line = "  skip v-chg-fields. */


&scop  disp-field-line ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="grp"  + string(ub.c-price-list-type-gds-grp.node-code ) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.ГРУППА-"   + string(ub.c-price-list-type-gds-grp.node-code ) + " " + ~{&field-label~} ~
        temp-changes.v_new = string(ub.c-price-list-type-gds-grp.~{&field-name~}) ~
        temp-changes.v_old =  (if available old_c-price-list-type-gds-grp  ~
                                then string(old_c-price-list-type-gds-grp.~{&field-name~})  ~
                                else "" ) ~
      . ~
  end. ~

&scop  disp-field-line-status ~
  when "~{&field-name~}":U then do: ~
    if ub.c-price-list-type-gds-grp.stts = 1 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="grp"   + string(ub.c-price-list-type-gds-grp.node-code ) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.ГРУППА-"   + string(ub.c-price-list-type-gds-grp.node-code ) + " " + ~{&field-label~} ~
        temp-changes.v_new = "удален" ~
        temp-changes.v_old =  (if available old_c-price-list-type-gds-grp  ~
                                then "текущий" ~
                                else "" ) ~
      . ~
     end. ~
    if ub.c-price-list-type-gds-grp.stts = 0 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="grp"   + string(ub.c-price-list-type-gds-grp.node-code ) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.ГРУППА-"   + string(ub.c-price-list-type-gds-grp.node-code ) + " " + ~{&field-label~} ~
        temp-changes.v_new = "текущий" ~
        temp-changes.v_old =  (if available old_c-price-list-type-gds-grp  ~
                                then "удален" ~
                                else "" ) ~
      . ~
     end. ~
  end. ~


  IF num-entries(v-chg-fields) = 0 THEN DO:
    create temp-changes.
      assign
        temp-changes.f_name = "grp" + string(ub.c-price-list-type-gds-grp.node-code ) + "ADD":U
        temp-changes.l_name = "Доб.ГРУППА-"   + string(ub.c-price-list-type-gds-grp.node-code )
        temp-changes.v_new  = ""
        temp-changes.v_old  = ""
      .
  END.

    do ii = 1 to num-entries(v-chg-fields):
      CASE entry(ii, v-chg-fields):
        &scop field-name node-code
        &scop field-label "Код группы"
        {&disp-field-line}
        &scop field-name plt-db-num
        &scop field-label "БД "
        {&disp-field-line}
        &scop field-name plt-id
        &scop field-label "№ "
        {&disp-field-line}
        &scop field-name stts
        &scop field-label "Статус строки"
        {&disp-field-line-status}
        &scop field-name db-num-chg
        &scop field-label "БД"
        {&disp-field-line}
        &scop field-name sys-date
        &scop field-label "Дата"
        {&disp-field-line}
        &scop field-name sys-time-chr
        &scop field-label "Время"
        {&disp-field-line}
        &scop field-name sys-time
        &scop field-label "Время (int)"
        {&disp-field-line}
        &scop field-name who
        &scop field-label "Кто"
        {&disp-field-line}

      end case.
    end.
end.

/* cassa */
define buffer old_c-price-list-type-cassa for ub.c-price-list-type-cassa  .
for each ub.c-price-list-type-cassa where
         ub.c-price-list-type-cassa.plt-id      = buf_c-price-list-type.plt-id     and
         ub.c-price-list-type-cassa.plt-db-num  = buf_c-price-list-type.plt-db-num and
         ub.c-price-list-type-cassa.chip-num    = buf_c-price-list-type.chip-num
         :
     find first old_c-price-list-type-cassa no-lock where
         old_c-price-list-type-cassa.plt-id      = ub.c-price-list-type-cassa.plt-id     and
         old_c-price-list-type-cassa.plt-db-num  = ub.c-price-list-type-cassa.plt-db-num and
         old_c-price-list-type-cassa.cash-num    = ub.c-price-list-type-cassa.cash-num   and
         old_c-price-list-type-cassa.obj-code    = ub.c-price-list-type-cassa.obj-code   and
         old_c-price-list-type-cassa.pos-type    = ub.c-price-list-type-cassa.pos-type   and
         old_c-price-list-type-cassa.chip-num    < ub.c-price-list-type-cassa.chip-num
         use-index pi no-error .

         if available old_c-price-list-type-cassa then do:
            buffer-compare old_c-price-list-type-cassa except chip-num corr-date corr-time corr-user-name corr-user-db-num  to ub.c-price-list-type-cassa
            save result in v-chg-fields.
         end.


 /* message "STR line = "  skip v-chg-fields. */

&scop  disp-field-line ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="cassa"  + string(ub.c-price-list-type-cassa.cash-num) + "/" + string(ub.c-price-list-type-cassa.obj-code) + string(ub.c-price-list-type-cassa.pos-type) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.КАССА-"   + string(ub.c-price-list-type-cassa.cash-num) + "/" + string(ub.c-price-list-type-cassa.obj-code) + string(ub.c-price-list-type-cassa.pos-type) + " " + ~{&field-label~} ~
        temp-changes.v_new = string(ub.c-price-list-type-cassa.~{&field-name~}) ~
        temp-changes.v_old =  (if available old_c-price-list-type-cassa  ~
                                then string(old_c-price-list-type-cassa.~{&field-name~})  ~
                                else "" ) ~
      . ~
  end. ~

&scop  disp-field-line-status ~
  when "~{&field-name~}":U then do: ~
    if ub.c-price-list-type-cassa.stts = 1 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="cassa"   + string(ub.c-price-list-type-cassa.cash-num) + "/" + string(ub.c-price-list-type-cassa.obj-code) + string(ub.c-price-list-type-cassa.pos-type) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.КАССА-" + string(ub.c-price-list-type-cassa.cash-num) + "/" + string(ub.c-price-list-type-cassa.obj-code) + string(ub.c-price-list-type-cassa.pos-type) + " " + ~{&field-label~} ~
        temp-changes.v_new = "удален" ~
        temp-changes.v_old =  (if available old_c-price-list-type-cassa  ~
                                then "текущий" ~
                                else "" ) ~
      . ~
     end. ~
    if ub.c-price-list-type-cassa.stts = 0 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="cassa"  + string(ub.c-price-list-type-cassa.cash-num) + "/" + string(ub.c-price-list-type-cassa.obj-code) + string(ub.c-price-list-type-cassa.pos-type) + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.КАССА-"  + string(ub.c-price-list-type-cassa.cash-num) + "/" + string(ub.c-price-list-type-cassa.obj-code) + string(ub.c-price-list-type-cassa.pos-type) + " " + ~{&field-label~} ~
        temp-changes.v_new = "текущий" ~
        temp-changes.v_old =  (if available old_c-price-list-type-cassa  ~
                                then "удален" ~
                                else "" ) ~
      . ~
     end. ~
  end. ~


  IF num-entries(v-chg-fields) = 0 THEN DO:
    create temp-changes.
      assign
        temp-changes.f_name = "cassa" + string(ub.c-price-list-type-cassa.cash-num) + "/" + string(ub.c-price-list-type-cassa.obj-code) + string(ub.c-price-list-type-cassa.pos-type)+ "ADD":U
        temp-changes.l_name = "Доб.КАССА-"  + string(ub.c-price-list-type-cassa.cash-num) + "/" + string(ub.c-price-list-type-cassa.obj-code) + string(ub.c-price-list-type-cassa.pos-type)
        temp-changes.v_new  = ""
        temp-changes.v_old  = ""
      .
  END.

    do ii = 1 to num-entries(v-chg-fields):
      CASE entry(ii, v-chg-fields):
        &scop field-name plt-db-num
        &scop field-label "БД "
        {&disp-field-line}
        &scop field-name plt-id
        &scop field-label "№ "
        {&disp-field-line}
        &scop field-name stts
        &scop field-label "Статус строки"
        {&disp-field-line-status}
        &scop field-name db-num-chg
        &scop field-label "БД"
        {&disp-field-line}
        &scop field-name sys-date
        &scop field-label "Дата"
        {&disp-field-line}
        &scop field-name sys-time-chr
        &scop field-label "Время"
        {&disp-field-line}
        &scop field-name sys-time
        &scop field-label "Время (int)"
        {&disp-field-line}
        &scop field-name who
        &scop field-label "Кто"
        {&disp-field-line}
        &scop field-name db-num
        &scop field-label "БД "
        {&disp-field-line}
        &scop field-name obj-code
        &scop field-label "код объекта"
        {&disp-field-line}
        &scop field-name pos-type
        &scop field-label "Тип POS"
        {&disp-field-line}
        &scop field-name cash-num
        &scop field-label "№ POS"
        {&disp-field-line}
      end case.
    end.
end.

/* pay-type */
define buffer old_c-price-list-type-pay-type for ub.c-price-list-type-pay-type  .
for each ub.c-price-list-type-pay-type where
         ub.c-price-list-type-pay-type.plt-id      = buf_c-price-list-type.plt-id     and
         ub.c-price-list-type-pay-type.plt-db-num  = buf_c-price-list-type.plt-db-num and
         ub.c-price-list-type-pay-type.chip-num    = buf_c-price-list-type.chip-num
         :
     find first old_c-price-list-type-pay-type no-lock where
         old_c-price-list-type-pay-type.plt-id      = ub.c-price-list-type-pay-type.plt-id     and
         old_c-price-list-type-pay-type.plt-db-num  = ub.c-price-list-type-pay-type.plt-db-num and
         old_c-price-list-type-pay-type.pay-code    = ub.c-price-list-type-pay-type.pay-code   and
         old_c-price-list-type-pay-type.chip-num    < ub.c-price-list-type-pay-type.chip-num
         use-index pi no-error .

         if available old_c-price-list-type-pay-type then do:
            buffer-compare old_c-price-list-type-pay-type except chip-num corr-date corr-time corr-user-name corr-user-db-num  to ub.c-price-list-type-pay-type
            save result in v-chg-fields.
         end.


  /* message "STR line1 = "  skip v-chg-fields. */

&scop  disp-field-line ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="pay-type"  + string(ub.c-price-list-type-pay-type.pay-code)   + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.ТИП платежа-"   + string(ub.c-price-list-type-pay-type.pay-code)   + " " + ~{&field-label~} ~
        temp-changes.v_new = string(ub.c-price-list-type-pay-type.~{&field-name~}) ~
        temp-changes.v_old =  (if available old_c-price-list-type-pay-type  ~
                                then string(old_c-price-list-type-pay-type.~{&field-name~})  ~
                                else "" ) ~
      . ~
  end. ~

&scop  disp-field-line-status ~
  when "~{&field-name~}":U then do: ~
    if ub.c-price-list-type-pay-type.stts = 1 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="pay-type"   + string(ub.c-price-list-type-pay-type.pay-code)   + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.ТИП платежа-" + string(ub.c-price-list-type-pay-type.pay-code)   + " " + ~{&field-label~} ~
        temp-changes.v_new = "удален" ~
        temp-changes.v_old =  (if available old_c-price-list-type-pay-type  ~
                                then "текущий" ~
                                else "" ) ~
      . ~
     end. ~
    if ub.c-price-list-type-pay-type.stts = 0 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="pay-type"  + string(ub.c-price-list-type-pay-type.pay-code)   + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.ТИП платежа-"  + string(ub.c-price-list-type-pay-type.pay-code)   + " " + ~{&field-label~} ~
        temp-changes.v_new = "текущий" ~
        temp-changes.v_old =  (if available old_c-price-list-type-pay-type  ~
                                then "удален" ~
                                else "" ) ~
      . ~
     end. ~
  end. ~


  IF num-entries(v-chg-fields) = 0 THEN DO:
    create temp-changes.
      assign
        temp-changes.f_name = "pay-type" + string(ub.c-price-list-type-pay-type.pay-code)  + "ADD":U
        temp-changes.l_name = "Доб.ТИП платежа-"  + string(ub.c-price-list-type-pay-type.pay-code)
        temp-changes.v_new  = ""
        temp-changes.v_old  = ""
      .
  END.

    do ii = 1 to num-entries(v-chg-fields):
      CASE entry(ii, v-chg-fields):
        &scop field-name plt-db-num
        &scop field-label "БД "
        {&disp-field-line}
        &scop field-name plt-id
        &scop field-label "№ "
        {&disp-field-line}
        &scop field-name stts
        &scop field-label "Статус строки"
        {&disp-field-line-status}
        &scop field-name db-num-chg
        &scop field-label "БД"
        {&disp-field-line}
        &scop field-name sys-date
        &scop field-label "Дата"
        {&disp-field-line}
        &scop field-name sys-time-chr
        &scop field-label "Время"
        {&disp-field-line}
        &scop field-name sys-time
        &scop field-label "Время (int)"
        {&disp-field-line}
        &scop field-name who
        &scop field-label "Кто"
        {&disp-field-line}
        &scop field-name pay-code
        &scop field-label "код"
        {&disp-field-line}
      end case.
    end.
end.

/* cash-pay */
define buffer old_c-price-list-type-cash-pay for ub.c-price-list-type-cash-pay  .
for each ub.c-price-list-type-cash-pay where
         ub.c-price-list-type-cash-pay.plt-id      = buf_c-price-list-type.plt-id     and
         ub.c-price-list-type-cash-pay.plt-db-num  = buf_c-price-list-type.plt-db-num and
         ub.c-price-list-type-cash-pay.chip-num    = buf_c-price-list-type.chip-num
         :
     find first old_c-price-list-type-cash-pay no-lock where
         old_c-price-list-type-cash-pay.plt-id      = ub.c-price-list-type-cash-pay.plt-id     and
         old_c-price-list-type-cash-pay.plt-db-num  = ub.c-price-list-type-cash-pay.plt-db-num and
         old_c-price-list-type-cash-pay.cdpay-code    = ub.c-price-list-type-cash-pay.cdpay-code   and
         old_c-price-list-type-cash-pay.curr-code     = ub.c-price-list-type-cash-pay.curr-code   and
         old_c-price-list-type-cash-pay.chip-num    < ub.c-price-list-type-cash-pay.chip-num
         use-index pi no-error .

         if available old_c-price-list-type-cash-pay then do:
            buffer-compare old_c-price-list-type-cash-pay except chip-num corr-date corr-time corr-user-name corr-user-db-num  to ub.c-price-list-type-cash-pay
            save result in v-chg-fields.
         end.


  /* message "STR line2 = "  skip v-chg-fields. */

&scop  disp-field-line ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="cash-pay"  + string(ub.c-price-list-type-cash-pay.cdpay-code) + string(ub.c-price-list-type-cash-pay.curr-code)  + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.ТИП касс.платежа-"   + string(ub.c-price-list-type-cash-pay.cdpay-code) + string(ub.c-price-list-type-cash-pay.curr-code)   + " " + ~{&field-label~} ~
        temp-changes.v_new = string(ub.c-price-list-type-cash-pay.~{&field-name~}) ~
        temp-changes.v_old =  (if available old_c-price-list-type-cash-pay  ~
                                then string(old_c-price-list-type-cash-pay.~{&field-name~})  ~
                                else "" ) ~
      . ~
  end. ~

&scop  disp-field-line-status ~
  when "~{&field-name~}":U then do: ~
    if ub.c-price-list-type-cash-pay.stts = 1 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="cash-pay"   + string(ub.c-price-list-type-cash-pay.cdpay-code)  + string(ub.c-price-list-type-cash-pay.curr-code)   + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.ТИП касс.платежа-" + string(ub.c-price-list-type-cash-pay.cdpay-code)  + string(ub.c-price-list-type-cash-pay.curr-code)   + " " + ~{&field-label~} ~
        temp-changes.v_new = "удален" ~
        temp-changes.v_old =  (if available old_c-price-list-type-cash-pay  ~
                                then "текущий" ~
                                else "" ) ~
      . ~
     end. ~
    if ub.c-price-list-type-cash-pay.stts = 0 then do: ~
    create temp-changes. ~
      assign ~
        temp-changes.f_name ="cash-pay"  + string(ub.c-price-list-type-cash-pay.cdpay-code)  + string(ub.c-price-list-type-cash-pay.curr-code)   + "~{&field-name~}":U ~
        temp-changes.l_name ="Изм.ТИП касс.платежа-"  + string(ub.c-price-list-type-cash-pay.cdpay-code)  + string(ub.c-price-list-type-cash-pay.curr-code)   + " " + ~{&field-label~} ~
        temp-changes.v_new = "текущий" ~
        temp-changes.v_old =  (if available old_c-price-list-type-cash-pay  ~
                                then "удален" ~
                                else "" ) ~
      . ~
     end. ~
  end. ~


  IF num-entries(v-chg-fields) = 0 THEN DO:
    create temp-changes.
      assign
        temp-changes.f_name = "cash-pay" + string(ub.c-price-list-type-cash-pay.cdpay-code) + string(ub.c-price-list-type-cash-pay.curr-code)   + "ADD":U
        temp-changes.l_name = "Доб.ТИП касс.платежа-"  + string(ub.c-price-list-type-cash-pay.cdpay-code)  + string(ub.c-price-list-type-cash-pay.curr-code)
        temp-changes.v_new  = ""
        temp-changes.v_old  = ""
      .
  END.

    do ii = 1 to num-entries(v-chg-fields):
      CASE entry(ii, v-chg-fields):
        &scop field-name plt-db-num
        &scop field-label "БД "
        {&disp-field-line}
        &scop field-name plt-id
        &scop field-label "№ "
        {&disp-field-line}
        &scop field-name stts
        &scop field-label "Статус строки"
        {&disp-field-line-status}
        &scop field-name db-num-chg
        &scop field-label "БД"
        {&disp-field-line}
        &scop field-name sys-date
        &scop field-label "Дата"
        {&disp-field-line}
        &scop field-name sys-time-chr
        &scop field-label "Время"
        {&disp-field-line}
        &scop field-name sys-time
        &scop field-label "Время (int)"
        {&disp-field-line}
        &scop field-name who
        &scop field-label "Кто"
        {&disp-field-line}
        &scop field-name cdpay-code
        &scop field-label "код"
        {&disp-field-line}
        &scop field-name  curr-code
        &scop field-label "код валюты"
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