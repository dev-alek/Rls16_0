&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER x-abcxyz-analysis FOR ub.abcxyz-analysis.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список заголовков ABC+XYZ-анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/30/05
Author: Svetlana Chernova
Creation date: 03/30/05

*/
/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-bttn        as character no-undo .
define output parameter p-rid-list    as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список заголовков ABC-анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
{ gbl/color.i    }
{ rep/gn-extp.i  }  /*Процедуры для определения имени расширенного типа документов*/
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

&scop cop-l1       mark-string(recid( x-abcxyz-analysis), p-rid-list)
&scop dyn_cop-l1       substitute('dynamic-function(&1mark-string&1, recid(x-abc-analysis), &1&2&1)', ~{&double-quote~}, p-rid-list)
&scop cop-l2      x-abcxyz-analysis.abc-id
&scop cop-l3      x-abcxyz-analysis.xyz-id
&scop cop-l4      x-abcxyz-analysis.abc-date-create
&scop cop-l5      STRING (x-abcxyz-analysis.abc-time-create,'HH:MM')
&scop cop-l6      x-abcxyz-analysis.abc-db-num-create
&scop cop-l7      x-abcxyz-analysis.abc-who-create

&scop col-l1       '*'
&scop col-l2       'Наименование'
&scop col-l3       'Критерий!анализа'
&scop col-l4       'Дата!создания'
&scop col-l5       'Время!созд'
&scop col-l6       'БД'
&scop col-l7       'Кто провел!анализ'

define variable mark-str  as character no-undo.
define variable v-doc-rec as recid no-undo.
define variable filter-point as character no-undo init "Ассортиментная матрица" .
define variable filter-point0 as character no-undo init "Состав_ассортиментной_матрицы" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .

define variable par-abc-type as character no-undo .
define variable v-b as decimal   no-undo .
define variable v-c as decimal   no-undo .
define variable v-d as decimal   no-undo .
define variable v-e as decimal   no-undo .
define variable v-f as decimal   no-undo .

define variable  v-def as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-ABC

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x-abcxyz-analysis

/* Definitions for BROWSE BROWSE-ABC                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-ABC mark-string(recid( x-abcxyz-analysis), p-rid-list) x-abcxyz-analysis.abcx-name x-abcxyz-analysis.abcx-date-create STRING (x-abcxyz-analysis.abcx-time-create,'HH:MM') x-abcxyz-analysis.abcx-db-num-create x-abcxyz-analysis.abcx-who-create
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-ABC
&Scoped-define SELF-NAME BROWSE-ABC
&Scoped-define QUERY-STRING-BROWSE-ABC FOR EACH x-abcxyz-analysis NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-ABC OPEN QUERY {&SELF-NAME} FOR EACH x-abcxyz-analysis NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-ABC x-abcxyz-analysis
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-ABC x-abcxyz-analysis


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-ABC}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS x-abcxyz-analysis.abcx-name
&Scoped-define ENABLED-TABLES x-abcxyz-analysis
&Scoped-define FIRST-ENABLED-TABLE x-abcxyz-analysis
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-lookup ~
B-lookup-2 B-print B-Help B-lookup-3 BROWSE-ABC mark-num v-user-name
&Scoped-Define DISPLAYED-FIELDS x-abcxyz-analysis.abcx-name
&Scoped-define DISPLAYED-TABLES x-abcxyz-analysis
&Scoped-define FIRST-DISPLAYED-TABLE x-abcxyz-analysis
&Scoped-Define DISPLAYED-OBJECTS mark-num v-user-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Формирование нового анализа".

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр ABC"
     SIZE 13.5 BY 1 TOOLTIP "Просмотр анализа ABC".

DEFINE BUTTON B-lookup-2
     LABEL "&Просмотр XYZ"
     SIZE 13.5 BY 1 TOOLTIP "Просмотр анализа XYZ".

DEFINE BUTTON B-lookup-3
     LABEL "Просмотр ABC+XYZ"
     SIZE 27 BY 1 TOOLTIP "Просмотр анализа ABC+XYZ".

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-ABC FOR
      x-abcxyz-analysis SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-ABC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-ABC Dialog-Frame _FREEFORM
  QUERY BROWSE-ABC NO-LOCK DISPLAY
      mark-string(recid( x-abcxyz-analysis), p-rid-list)  COLUMN-LABEL "*" FORMAT "X(1)":U
      x-abcxyz-analysis.abcx-name                         COLUMN-LABEL "Наименование" FORMAT "x(60)":U
      x-abcxyz-analysis.abcx-date-create                  COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      STRING (x-abcxyz-analysis.abcx-time-create,'HH:MM') COLUMN-LABEL "Время!созд" FORMAT "x(5)":U WIDTH 5
      x-abcxyz-analysis.abcx-db-num-create                COLUMN-LABEL "БД" FORMAT ">>>>9":U
      x-abcxyz-analysis.abcx-who-create                   COLUMN-LABEL "Кто провел!сравнение" FORMAT "X(15)":U WIDTH 10
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 14
     B-sel AT ROW 1 COL 17
     B-add AT ROW 1 COL 27
     B-del AT ROW 1 COL 37
     B-lookup AT ROW 1 COL 47
     B-lookup-2 AT ROW 1 COL 60.5
     B-print AT ROW 1 COL 77.5
     B-Help AT ROW 1 COL 87.5
     B-lookup-3 AT ROW 2 COL 47
     BROWSE-ABC AT ROW 3 COL 1
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL
     v-user-name AT ROW 20.5 COL 79.5 COLON-ALIGNED WIDGET-ID 2
     x-abcxyz-analysis.abcx-name AT ROW 21.5 COL 1.5 NO-LABEL
           VIEW-AS TEXT
          SIZE 95.5 BY .67 TOOLTIP "Наименование анализа"
          FGCOLOR 4
     SPACE(1.00) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сопоставление ABC-XYZ анализов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x-abcxyz-analysis B "NEW SHARED" ? ub abcxyz-analysis
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-ABC B-lookup-3 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN x-abcxyz-analysis.abcx-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR BUTTON B-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       BROWSE-ABC:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-ABC
/* Query rebuild information for BROWSE BROWSE-ABC
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x-abcxyz-analysis NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-ABC */
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сопоставление ABC-XYZ анализов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_delivery-storage_work':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    loc#log
  }

  if not loc#log then return no-apply.

  run proc-add (output loc-doc-rec ) no-error  .
  if error-status :error then message
  error-status :get-message(1)
  return-value .

  if loc-doc-rec <> ? then do:
      run openbr in this-procedure .
      reposition {&browse-name} to recid loc-doc-rec no-error.
      {&cant-positioning}
  end.

  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
  apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical   no-undo .
 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_delivery-storage_work':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    loc#log
  }

  if not loc#log then return no-apply.

    message "Удалить АВС анализ ?"
      view-as alert-box question
      buttons yes-no
      update g-log as logical.
    if g-log = false then return no-apply.
    run waitfram-show ("Ждите...").
    run proc-b-del in this-procedure .
    run waitfram-hide in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр ABC */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.
define buffer bb_abc-analysis for ub.abc-analysis.
find first bb_abc-analysis no-lock where
           bb_abc-analysis.abc-id = {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.abc-id and
           bb_abc-analysis.db-num = {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.db-num no-error .

           ASSIGN

loc-doc-rec = recid(bb_abc-analysis).

 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_delivery-storage_work':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
   if not loc#log then return no-apply .
   run ref/abcanali.w
     ( input parparentproc ,
       input {&lookup} ,
       input bb_abc-analysis.abc-id ,
       input bb_abc-analysis.db-num ,
       input-output loc-doc-rec
       ) .

   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup-2 Dialog-Frame
ON CHOOSE OF B-lookup-2 IN FRAME Dialog-Frame /* Просмотр XYZ */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.
define buffer bb_xyz-analysis for ub.xyz-analysis.
find first bb_xyz-analysis no-lock where
           bb_xyz-analysis.xyz-id = {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.xyz-id and
           bb_xyz-analysis.db-num = {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.db-num no-error .

assign
loc-doc-rec = recid(bb_xyz-analysis).

 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_delivery-storage_work':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
    if not loc#log then return no-apply .
   run ref/xyzanali.w ( INPUT parParentProc ,INPUT  {&lookup} ,INPUT bb_xyz-analysis.xyz-id , INPUT bb_xyz-analysis.db-num , input-output loc-doc-rec ) .

   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup-3 Dialog-Frame
ON CHOOSE OF B-lookup-3 IN FRAME Dialog-Frame /* Просмотр ABC+XYZ */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.

assign
loc-doc-rec = recid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}).

 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_delivery-storage_work':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
   if not  loc#log then return no-apply .
   run ref/abcxyzi.w ( INPUT parParentProc ,INPUT {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.abcx-id , INPUT {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}.db-num ) .

   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}  then do:
    { gbl/markstrn.i {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} p-rid-list }
    loc#log = {&BROWSE-NAME}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&BROWSE-NAME}:select-next-row ().
        apply "VALUE-CHANGED" to {&BROWSE-NAME} in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
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

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  p-rid-list = "" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
   IF  p-rid-list = "" THEN DO:
      IF AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} THEN p-rid-list = string(RECID({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}})).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-ABC
&Scoped-define SELF-NAME BROWSE-ABC
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-ABC Dialog-Frame
ON VALUE-CHANGED OF BROWSE-ABC IN FRAME Dialog-Frame
DO:
  if available x-abcxyz-analysis then do:
        { gbl/usrfulnm.i
         x-abcxyz-analysis.abcx-who-create
         v-user-name }

     display v-user-name  x-abcxyz-analysis.abcx-name with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/setfltnm.i no-button }
{ gbl/app_help.i }
/*{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = x-abcxyz-analysis
  &label-clmn_1     =   "{&col-l1}"
  &label-clmn_2     =   "{&col-l2}"
  &label-clmn_3     =   "{&col-l3}"
  &label-clmn_4     =   "{&col-l4}"
  &label-clmn_5     =   "{&col-l5}"
  &label-clmn_6     =   "{&col-l6}"
  &label-clmn_7     =   "{&col-l7}"
  &label-clmn_8     =   "{&col-l8}"
  &label-clmn_9     =   "{&col-l9}"
  &label-clmn_10    =   "{&col-l10}"
  &label-clmn_11    =   "{&col-l11}"
  &label-clmn_12    =   "{&col-l12}"
  &label-clmn_13    =   "{&col-l13}"
  &label-clmn_14    =   "{&col-l14}"
  &label-clmn_15    =   "{&col-l15}"
  &label-clmn_16    =   "{&col-l16}"
  &sort-clmn_1    =   "{&cop-l1}"
  &dyn_sort-clmn_1    =   "{&dyn_cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &sort-clmn_10   =   "{&cop-l10}"
  &sort-clmn_11   =   "{&cop-l11}"
  &sort-clmn_12   =   "{&cop-l12}"
  &sort-clmn_13    =  "{&cop-l13}"
  &sort-clmn_14   =   "{&cop-l14}"
  &sort-clmn_15    =  "{&cop-l15}"
  &sort-clmn_16    =  "{&cop-l16}"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

  */
{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    /*
    { gbl/mv-clmn.i
    &browse-name = "{&browse-name}"
    &frame-name = "{&frame-name}"
    &ext-col = 16
    &start-column = 3
    }
      */
  { gbl/curdbnum.i v-db-num }
  RUN my_enable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
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
  DISPLAY mark-num v-user-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-abcxyz-analysis THEN
    DISPLAY x-abcxyz-analysis.abcx-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-lookup B-lookup-2 B-print B-Help
         B-lookup-3 BROWSE-ABC mark-num v-user-name x-abcxyz-analysis.abcx-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable par-type as character no-undo .

   /*
   {&cop-l2}:resizable in browse BROWSE-ABC = true .
   {&cop-l3}:resizable in browse BROWSE-ABC = true .
     */
  ENABLE b-quit
         B-mark      when LOOKUP("b-mark":U, p-bttn ) > 0
         mark-num
         B-sel       when LOOKUP("b-sel":U, p-bttn ) > 0
         B-add       when LOOKUP("b-add":U, p-bttn ) > 0
         B-del       when LOOKUP("b-del":U, p-bttn ) > 0
         B-lookup
         B-lookup-2
         B-lookup-3
         B-print
         B-Help
         browse-abc
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  RUN OpenBR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBR Dialog-Frame
PROCEDURE OpenBR :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable p-open-query     as logical   no-undo init true .
def var l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable  p-find-next      as logical   no-undo .
define variable  p-find-condition as character no-undo .

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

define variable title0 as character no-undo init "Список Ассортиментных матриц".


&scop flt-open-open-query OPEN QUERY BROWSE-Abc FOR EACH x-abcxyz-analysis

&scop flt-open-dyn_open-query  FOR EACH x-abcxyz-analysis

&scop flt-open-query-handle query BROWSE-ABC:handle

&scop flt-open-find-buffer-name x-abcxyz-analysis

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          x-abcxyz-analysis

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer x-abcxyz-analysis for ub.abcxyz-analysis .

&scop flt-open-debug-file

&scop flt-open-waitfram             true


{ gbl/fltopend.i
  &where-cond = " true   "
  &where-cond = " 'true'   "
  &use-ind    = " "
  &by         = " " }

APPLY "ENTRY" TO BROWSE-ABC in frame {&frame-name}.
APPLY "VALUE-CHANGED" TO BROWSE-ABC in frame {&frame-name}.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame
PROCEDURE proc-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output  parameter p-doc-rec as recid     no-undo .

run ref/abcxyzc.p ( INPUT parParentProc , output p-doc-rec ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
define variable br-handle as handle NO-UNDO.
define variable g#log  as logical   no-undo .
if not available x-abcxyz-analysis then return error.
 find current x-abcxyz-analysis exclusive-lock no-error .
        if not available x-abcxyz-analysis then do:
          message vss-workfile vss-revision vss-description skip
                    error-status :get-message(1)   skip
                    "Ошибка при определении записи x-abcxyz-analysis"
                    view-as alert-box error .
          return .
        end.
  delete x-abcxyz-analysis .
  br-handle = {&browse-name}:handle in frame {&frame-name} .
  if valid-handle (br-handle) then do:
    g#log = br-handle:select-next-row().
    if not g#log then g#log = br-handle:select-prev-row().
    loc-doc-rec = RECID(x-abcxyz-analysis) .
  end.

   RUN OpenBr.
   apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
   reposition {&browse-name} to recid loc-doc-rec no-error.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
def var sym1  as char format "X(1)" init ":".
def var sym2  as char format "X(1)" init ":".
def var sym3  as char format "X(1)" init ":".
def var sym4  as char format "X(1)" init ":".
def var sym5  as char format "X(1)" init ":".
def var sym6  as char format "X(1)" init ":".
def var sym7  as char format "X(1)" init ":".
def var sym8  as char format "X(1)" init ":".
def var sym9  as char format "X(1)" init ":".
def var sym10 as char format "X(1)" init ":".
def var sym11 as char format "X(1)" init ":".
def var sym12 as char format "X(1)" init ":".

def var date_string     as      char    no-undo.
def var Line                as      char    no-undo.
def var for-time as char.
define variable v-time  as character no-undo .

DEFINE FRAME prt-frame
      x-abcxyz-analysis.abcx-name                         COLUMN-LABEL "Наименование! " FORMAT "x(60)":U
      x-abcxyz-analysis.abcx-date-create                  COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      v-time COLUMN-LABEL "Время!созд" FORMAT "x(5)":U
      x-abcxyz-analysis.abcx-db-num-create                COLUMN-LABEL "БД" FORMAT ">>>>9":U
      x-abcxyz-analysis.abcx-who-create                   COLUMN-LABEL "Кто провел!сравнение" FORMAT "X(10)":U
      HEADER  date_string AT 5 format "X(35)"
      string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
      Line format "X(199)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

    Line = fill("-", 255).
    date_string = cur-time-print() .
    run prn-lib-open-stream  in this-procedure (
       input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(232)" SKIP(1) .
    FORM HEADER
            Line format "X(199)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
            with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите печатаю...").

    run OpenBR.
     DO WHILE available x-abcxyz-analysis :
        Display STREAM PrnLibStream
            x-abcxyz-analysis.abcx-name
            x-abcxyz-analysis.abcx-date-create
            STRING (x-abcxyz-analysis.abcx-time-create,'HH:MM') @ v-time
            x-abcxyz-analysis.abcx-db-num-create
            x-abcxyz-analysis.abcx-who-create
            with FRAME prt-frame .
            DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
            GET next BROWSE-ABC.
      END.
      UNDERLINE  STREAM PrnLibStream
            x-abcxyz-analysis.abcx-name
            x-abcxyz-analysis.abcx-date-create
            v-time
            x-abcxyz-analysis.abcx-db-num-create
            x-abcxyz-analysis.abcx-who-create
    with FRAME prt-frame .

    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
