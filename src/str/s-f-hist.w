&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER X_c-schet-fact-doc FOR ub.c-schet-fact-doc.
DEFINE BUFFER X_schet-fact-doc FOR ub.schet-fact-doc.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории счетов-фактур

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05

*/
/*
         ! ! !  В Н И М А Н И Е  ! ! !
   не забудь: после исправления файла в UIB
   САМОЕ ГЛАВНОЕ - подставить new shared в DEFINE QUERY br-c-schet-fact-doc !!!!!!!
*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code    as integer   no-undo .
define input parameter p-doc-code as character no-undo .
/*define input parameter bttns  as character   no-undo .*/
/*define input-output param p-rid-list    as  character no-undo .*/


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$revision: 6 $":u.
define variable vss-author      as character no-undo initial "$author: mkochetkov $":u.
define variable vss-date        as character no-undo initial "$date: 12.04.06 14:35 $":u.
define variable vss-workfile    as character no-undo initial "$workfile: s-f-hist.w $":u.
define variable vss-archive     as character no-undo initial "$archive: /ver15_0/str/s-f-hist.w $":u.
define variable vss-description as character no-undo initial "Список истории счетов-фактур":u.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/flt-def.i  }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }

define variable  p-rid-list    as  character no-undo .
define variable  bttns  as character   no-undo .

define variable filter-point as character no-undo initial "Список истории счетов-фактур" .
define variable filter-point0 as character no-undo initial "Список истории счетов-фактур" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable title0 as character no-undo.

define temp-table temp-changes no-undo
  field f_name as character
  field l_name as character
  field v_old as character
  field v_new as character
index pi is unique primary f_name.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

&Scoped-define line-num 7

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-schet-fact-doc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-schet-fact-doc temp-changes

/* Definitions for BROWSE br-c-schet-fact-doc                                 */
&Scoped-define FIELDS-IN-QUERY-br-c-schet-fact-doc (mark-string(recid(X_c-schet-fact-doc), p-rid-list)) X_c-schet-fact-doc.doc-code X_c-schet-fact-doc.doc-date  X_c-schet-fact-doc.status_  string( X_c-schet-fact-doc.cli-type + ' ' + string(X_c-schet-fact-doc.cli-code))  X_c-schet-fact-doc.cli-name X_c-schet-fact-doc.sum-rubl X_c-schet-fact-doc.ext-doc-type  X_c-schet-fact-doc.in-doc-code  X_c-schet-fact-doc.contract-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-schet-fact-doc ~
X_c-schet-fact-doc.doc-code
&Scoped-define ENABLED-TABLES-IN-QUERY-br-c-schet-fact-doc X_c-schet-fact-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-c-schet-fact-doc X_c-schet-fact-doc
&Scoped-define OPEN-QUERY-br-c-schet-fact-doc OPEN QUERY br-c-schet-fact-doc FOR EACH X_c-schet-fact-doc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-c-schet-fact-doc X_c-schet-fact-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-schet-fact-doc X_c-schet-fact-doc


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel B-lookup B-sch B-Help ~
br-c-schet-fact-doc BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-c-schet-fact-doc FOR X_c-schet-fact-doc SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-schet-fact-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-schet-fact-doc Dialog-Frame _STRUCTURED
  QUERY br-c-schet-fact-doc DISPLAY
      (mark-string(recid(X_c-schet-fact-doc), p-rid-list)) COLUMN-LABEL "*" FORMAT "x(1)"
      X_c-schet-fact-doc.corr-date                    COLUMN-LABEL "Дата!изменения"  FORMAT "99/99/99"
      string(X_c-schet-fact-doc.corr-time,"HH:MM")    COLUMN-LABEL "Время!изменения" FORMAT "X(5)"
      usrfulnf(X_c-schet-fact-doc.corr-user-name)     COLUMN-LABEL "Оператор"        FORMAT "X(18)"
      X_c-schet-fact-doc.doc-code                     COLUMN-LABEL "Номер"           FORMAT "X(16)"
      X_c-schet-fact-doc.doc-date                     COLUMN-LABEL "Дата"  FORMAT "99/99/99"
      X_c-schet-fact-doc.status_                      COLUMN-LABEL "Статус"          FORMAT "X(4)"
      string( X_c-schet-fact-doc.cli-type + ' ' + string(X_c-schet-fact-doc.cli-code)) COLUMN-LABEL "Тип/код!контрагента" FORMAT "x(10)"
      X_c-schet-fact-doc.cli-name                     COLUMN-LABEL "Контрагент"      FORMAT "x(40)"
      X_c-schet-fact-doc.sum-rubl                     COLUMN-LABEL "Сумма"           FORMAT ">>>,>>>,>>>,>>>,>>>.<<"
      X_c-schet-fact-doc.ext-doc-type                 COLUMN-LABEL "Тип"    FORMAT "X(3)"
      X_c-schet-fact-doc.in-doc-code                  COLUMN-LABEL "По док-ту"  FORMAT "X(12)"
      X_c-schet-fact-doc.contract-code                COLUMN-LABEL "Вн.№ договора"  FORMAT ">>>>>>>>>>9"
    ENABLE
      X_c-schet-fact-doc.doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 13.71.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(35)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(40)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.88 BY 5.83.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31
     B-sch AT ROW 1 COL 41
     B-Help AT ROW 1 COL 86.25
     br-c-schet-fact-doc AT ROW 2 COL 1.38
     BR-changes AT ROW 16.04 COL 1.38
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(77.49) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список договоров"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-schet-fact-doc B "?" ? ub ub.c-schet-fact-doc
      TABLE: X_schet-fact-doc B "?" ? ub ub.schet-fact-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-c-schet-fact-doc B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-c-schet-fact-doc Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       br-c-schet-fact-doc:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-schet-fact-doc
/* Query rebuild information for BROWSE br-c-schet-fact-doc
*/  /* BROWSE br-c-schet-fact-doc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* Список платежей */
DO:
    run gbl/markqwa.p ( input b-mark:sensitive, input p-rid-list) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable g-log  as logical   no-undo .
  if not available X_c-schet-fact-doc then return no-apply.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_schet-fact-doc_update':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }

  if not g-log then  return .
  run str/s-f-doc.w (input parparentproc,input p-host-code, input X_c-schet-fact-doc.db-num, {&lookup}, input X_c-schet-fact-doc.doc-code, input X_c-schet-fact-doc.chip-num) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-schet-fact-doc then do:
      if can-do( p-rid-list, string( recid( X_c-schet-fact-doc ) ) ) then do:
          p-rid-list = replace( p-rid-list, {&comma-char} + string( recid( X_c-schet-fact-doc ) ), "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-schet-fact-doc ) ) + {&comma-char}, "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-schet-fact-doc ) ), "") .
      end.
      else
      p-rid-list = p-rid-list + ( if p-rid-list = "" then "" else {&comma-char} ) + string( recid( X_c-schet-fact-doc ) ) .
      loc#log = br-c-schet-fact-doc:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = br-c-schet-fact-doc:select-next-row ().
          apply "VALUE-CHANGED" to br-c-schet-fact-doc in frame {&frame-name}.
      end.
      if num-entries( p-rid-list ) = 0 then hide mark-num in frame {&frame-name}.
      else disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-c-schet-fact-doc in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
    tbl = 'c-schet-fact-doc'
    join-tbl = 'X_c-schet-fact-doc'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('doc-code', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-date', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('host-code', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Вн.Номер', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-type', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('base-rate', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('base-scale', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS',         '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('book-code', 'Номер в книге', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-address', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-inn', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-name', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-address', 'Адрес поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-inn', 'ИНН  поставщика', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type', 'Тип  поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-code', 'Код  поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-name', 'Имя  поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('Gruz-otprav', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('Gruz-poluch', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ext-doc-type', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('gtd', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('country', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-date', 'Дата прихода', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-doc-code', 'Номер док-та прих.', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-doc-date', 'Дата док-та прих.', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-code', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pay-date', 'Дата платежа', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-db-num', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-date', 'Сист. дата', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-time', 'Сист. время', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-time', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-user-db-num', 'Польз. база факт', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-user-name', 'Польз. факт', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('fact-order', 'порядок', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('sum-rubl', 'сумма {&abbr_rub}', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-base', 'сумма б.в.', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
  DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
     ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
     ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
    run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
    RUN OpenBr(yes, no, '':U).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-schet-fact-doc ) AND ( p-rid-list = "" ) then  p-rid-list = string( recid( X_c-schet-fact-doc ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-schet-fact-doc
&Scoped-define SELF-NAME br-c-schet-fact-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-schet-fact-doc Dialog-Frame
ON RETURN OF br-c-schet-fact-doc IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-c-schet-fact-doc IN FRAME Dialog-Frame
DO:
  if b-sel:sensitive in frame {&frame-name} then
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
    else                     apply "choose" to b-sel in frame {&frame-name}.
  else if b-lookup:sensitive then apply "choose" to b-lookup in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-schet-fact-doc Dialog-Frame
ON VALUE-CHANGED OF br-c-schet-fact-doc IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
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

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-schet-fact-doc.doc-code"
  &open-query     = "run OpenBr(yes, no, no)."
  &open-query-otherwise = "run OpenBr(yes, no, no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn = "no"
  &mv-brw-default = "no"
}
/*  &sort-clmn_2    = "X_c-schet-fact-doc.corr-user-name"*/


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  find first X_schet-fact-doc no-lock  where X_schet-fact-doc.host-code = p-host-code and X_schet-fact-doc.doc-code = p-doc-code no-error .
  if not available X_schet-fact-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-host-code и/или p-doc-code"  p-host-code p-doc-code
    view-as alert-box ERROR.
    return.
  end.

  assign
    br-c-schet-fact-doc:num-locked-columns = 1
    X_c-schet-fact-doc.doc-code:read-only in browse br-c-schet-fact-doc = yes
  .

  find first ub.clients no-lock where ub.clients.obj-code = p-host-code and ub.clients.obj-type = {&cmp} .
  title0 = "Список истории счетов-фактур" + {&space-char}  + substitute(" Фирма: (&1) &2 Cчет-фактура : &3 от &4", p-host-code, ub.clients.obj-name,  X_schet-fact-doc.doc-code, string(X_schet-fact-doc.doc-date,"99/99/9999")) .

  RUN MyEnable.

  DISABLE
    b-sel   when  NOT can-do( bttns, "b-sel" )
    b-mark  when  NOT can-do( bttns, "b-mark")
  WITH FRAME {&frame-name}.

  RUn OpenBR(yes, no, '':U).
  HIDE mark-num in frame {&frame-name} .
  if p-rid-list <> "":U then assign v-doc-rec = integer(entry(1, p-rid-list)) .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY mark-num      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-sel B-lookup B-sch B-Help br-c-schet-fact-doc BR-changes mark-num    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
  DISPLAY mark-num WITH FRAME Dialog-Frame.
  ENABLE  b-quit  B-lookup  b-sel  B-mark  B-sch  B-Help  mark-num  br-c-schet-fact-doc  BR-changes WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

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
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then assign sort-column-phrase = ""  .
    otherwise    assign sort-column-phrase = "by " + sort-column-name  .
  end case.


  &scop flt-open-open-query OPEN QUERY br-c-schet-fact-doc FOR EACH X_c-schet-fact-doc
  &scop flt-open-dyn_open-query  FOR EACH X_c-schet-fact-doc
  &scop flt-open-query-handle query br-c-schet-fact-doc:handle
  &scop flt-open-open-query-tail
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-query p-open-query
  &scop flt-open-table-name X_c-schet-fact-doc
  &scop flt-open-search-option no-lock
  &scop flt-open-find-next p-find-next
  &scop flt-open-find-recid v-doc-rec
  &scop flt-open-find-condition p-find-condition
  &scop flt-open-find-buffer-name X_c-schet-fact-doc

  define variable l-open-query as logical   no-undo .
  filter-point = filter-point0 .

  ASSIGN frame {&frame-name}:TITLE = title0 .
  { gbl/fltopend.i
    &where-cond = " X_c-schet-fact-doc.host-code = p-host-code AND X_c-schet-fact-doc.doc-code  = p-doc-code "
    &DYN_where-cond = " substitute(' X_c-schet-fact-doc.host-code = &1 AND X_c-schet-fact-doc.doc-code = &3&2&3 ', p-host-code, p-doc-code, ~{&double-quote~}) "
    &use-ind    = "  "
    &by         = "  "
  }

  REPOSITION br-c-schet-fact-doc to recid v-doc-rec No-ERROR.
  if error-status:error then REPOSITION br-c-schet-fact-doc to row 1 No-ERROR.
  else  REPOSITION br-c-schet-fact-doc to row {&line-num} No-ERROR.
/*  br-c-schet-fact-doc:SET-REPOSITIONED-ROW({&line-num}, "CONDITIONAL") .*/
/*    { gbl/brwrepos.i }*/
/*  end.*/

  run proc-view-changes in this-procedure no-error.
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
  define buffer new_c-schet-fact-doc for ub.c-schet-fact-doc.
  define buffer current_schet-fact-doc for ub.schet-fact-doc.
  define variable v-chg-fields as character no-undo.
  define variable v-old-fields as character no-undo.
  define variable v-new-fields as character no-undo.
  define variable ii as integer no-undo.

  for each temp-changes:  delete temp-changes.  END.

  find first new_c-schet-fact-doc no-lock
    where new_c-schet-fact-doc.host-code     = X_c-schet-fact-doc.host-code
      and new_c-schet-fact-doc.doc-code = X_c-schet-fact-doc.doc-code
      and new_c-schet-fact-doc.chip-num      > X_c-schet-fact-doc.chip-num
    no-error.

  if not available new_c-schet-fact-doc then do:
    find first current_schet-fact-doc no-lock
      where current_schet-fact-doc.host-code = X_c-schet-fact-doc.host-code
       and current_schet-fact-doc.doc-code = x_c-schet-fact-doc.doc-code
    no-error.
    if not available current_schet-fact-doc then return error.
    buffer-compare current_schet-fact-doc to X_c-schet-fact-doc save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_c-schet-fact-doc except chip-num corr-date corr-time corr-user-name corr-user-db-num to X_c-schet-fact-doc save result in v-chg-fields.
  end.

  &scop  disp-field ~
    when "~{&field-name~}":U then do: ~
    create temp-changes. ~
    assign ~
    temp-changes.f_name = "~{&field-name~}":U ~
    temp-changes.l_name = ~{&field-label~} ~
    temp-changes.v_old = string(X_c-schet-fact-doc.~{&field-name~}) ~
    temp-changes.v_new = (if available new_c-schet-fact-doc  ~
                             then string(new_c-schet-fact-doc.~{&field-name~})  ~
                             else string(current_schet-fact-doc.~{&field-name~})) ~
    . ~
    end. ~

  do ii = 1 to num-entries(v-chg-fields):
    CASE entry(ii, v-chg-fields):
      &scop field-name doc-code
      &scop field-label "Номер"
      {&disp-field}
      &scop field-name contract-code
      &scop field-label "Код договора"
      {&disp-field}
      &scop field-name doc-date
      &scop field-label "Дата"
      {&disp-field}
      &scop field-name ext-doc-type
      &scop field-label "Тип"
      {&disp-field}
      &scop field-name status_
      &scop field-label "Статус"
      {&disp-field}
      &scop field-name curr-code
      &scop field-label "Код валюты"
      {&disp-field}
      &scop field-name own-name
      &scop field-label "Фирма"
      {&disp-field}
      &scop field-name own-address
      &scop field-label "Фирма - Адрес"
      {&disp-field}
      &scop field-name own-inn
      &scop field-label "Фирма - ~{&abbr_inn_allshift~}"
      {&disp-field}
      &scop field-name cli-type
      &scop field-label "Тип контрагента"
      {&disp-field}
      &scop field-name cli-code
      &scop field-label "Код контрагента"
      {&disp-field}
      &scop field-name cli-name
      &scop field-label "Наименование контрагента"
      {&disp-field}
      &scop field-name cli-address
      &scop field-label "Адрес контрагента"
      {&disp-field}
      &scop field-name cli-inn
      &scop field-label "~{&abbr_inn_allshift~} контрагента"
      {&disp-field}
      &scop field-name base-rate
      &scop field-label "Курс валюты"
      {&disp-field}
      &scop field-name base-scale
      &scop field-label "Масштаб валюты"
      {&disp-field}
      &scop field-name PS
      &scop field-label "Примечания"
      {&disp-field}
      &scop field-name book-code
      &scop field-label "Номер в книге"
      {&disp-field}
      &scop field-name Gruz-otprav
      &scop field-label "Грузоотправитель"
      {&disp-field}
      &scop field-name Gruz-poluch
      &scop field-label "Грузополучатель"
      {&disp-field}
      &scop field-name gtd
      &scop field-label "ГТД"
      {&disp-field}
      &scop field-name country
      &scop field-label "Страна"
      {&disp-field}
      &scop field-name in-date
      &scop field-label "Дата прихода"
      {&disp-field}
      &scop field-name in-doc-code
      &scop field-label "Номер док-та прихода"
      {&disp-field}
      &scop field-name in-doc-date
      &scop field-label "Дата док-та прихода"
      {&disp-field}
      &scop field-name obj-type
      &scop field-label "Тип объекта"
      {&disp-field}
      &scop field-name obj-code
      &scop field-label "Код объекта"
      {&disp-field}
      &scop field-name pay-date
      &scop field-label "Дата платежа"
      {&disp-field}
      &scop field-name user-db-num
      &scop field-label "База опер."
      {&disp-field}
      &scop field-name user-name
      &scop field-label "Имя опер."
      {&disp-field}
      &scop field-name sys-date
      &scop field-label "Сист. дата"
      {&disp-field}
      &scop field-name sys-time
      &scop field-label "Сист. время"
      {&disp-field}
      &scop field-name fact-date
      &scop field-label "Факт. дата"
      {&disp-field}
      &scop field-name fact-time
      &scop field-label "Факт. время"
      {&disp-field}
      &scop field-name fact-user-db-num
      &scop field-label "Факт. база опер."
      {&disp-field}
      &scop field-name fact-user-name
      &scop field-label "Факт. имя опер."
      {&disp-field}
      &scop field-name fact-order
      &scop field-label "порядковый номер документа"
      {&disp-field}
      &scop field-name sum-rubl
      &scop field-label "Сумма {&abbr_rub}"
      {&disp-field}
      &scop field-name sum-base
      &scop field-label "Сумма б.вал."
      {&disp-field}
      &scop field-name sum-VAT-no-rubl
      &scop field-label "Сумма, не облагаемая НДС, {&abbr_rub}"
      {&disp-field}
      &scop field-name sum-VAT-no-base
      &scop field-label "Сумма, не облагаемая НДС, б.вал."
      {&disp-field}
      &scop field-name sum-VAT-0-rubl
      &scop field-label "Сумма, облагаемая НДС 0%, {&abbr_rub}"
      {&disp-field}
      &scop field-name sum-VAT-0-base
      &scop field-label "Сумма, облагаемая НДС 0%, б.вал."
      {&disp-field}
      &scop field-name sum-VAT-10-rubl
      &scop field-label "Сумма, облагаемая НДС 10%, {&abbr_rub}"
      {&disp-field}
      &scop field-name sum-VAT-10-base
      &scop field-label "Сумма, облагаемая НДС 10%, б.вал."
      {&disp-field}
      &scop field-name sum-VAT-10-rubl
      &scop field-label "Сумма НДС 10%, {&abbr_rub}"
      {&disp-field}
      &scop field-name sum-VAT-10-base
      &scop field-label "Сумма НДС 10%, б.вал."
      {&disp-field}
      &scop field-name sum-VAT-20-rubl
      &scop field-label "Сумма, облагаемая НДС 20%, {&abbr_rub}"
      {&disp-field}
      &scop field-name sum-VAT-20-base
      &scop field-label "Сумма, облагаемая НДС 20%, б.вал."
      {&disp-field}
      &scop field-name sum-VAT-20-rubl
      &scop field-label "Сумма НДС 10%, {&abbr_rub}"
      {&disp-field}
      &scop field-name sum-VAT-20-base
      &scop field-label "Сумма НДС 10%, б.вал."
      {&disp-field}
    END CASE.
  end.

  Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME