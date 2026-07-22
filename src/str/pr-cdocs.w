&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf_c-price-doc FOR ub.c-price-doc.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаленные переоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-host-code AS integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ gbl/fltopend.i defproc }

/* Local Variable Definitions ---                                       */
define variable sort-column-name as character no-undo .
define variable filter-point as character no-undo init "Список удаленных переоценок" .
define variable filter-point0 as character no-undo init "Список_удаленных_переоценок" .
define variable p-open-query     as logical   no-undo .
define variable l-query-was-opened as logical no-undo init true .
define variable doc-rec as recid no-undo .
define variable p-find-next      as logical   no-undo .
define variable p-find-condition as character no-undo .




&scop cop-l1      buf_c-price-doc.doc-num
&scop cop-l2      buf_c-price-doc.status_
&scop cop-l3      buf_c-price-doc.doc-date
&scop cop-l4      buf_c-price-doc.fact-date
&scop cop-l5      buf_c-price-doc.host-code
&scop cop-l6      buf_c-price-doc.obj-type
&scop cop-l7      buf_c-price-doc.obj-code
&scop cop-l8      buf_c-price-doc.out-code
&scop cop-l9      buf_c-price-doc.corr-date
&scop cop-l10     buf_c-price-doc.corr-doc-code
&scop cop-l11     buf_c-price-doc.corr-man
&scop cop-l12     buf_c-price-doc.creid
&scop cop-l13     buf_c-price-doc.is-corr
&scop cop-l14     buf_c-price-doc.is-del-act
&scop col-l1      '№ Переоценки'
&scop col-l2      'Статус'
&scop col-l3      'Дата!док.'
&scop col-l4      'Факт'
&scop col-l5      'Фирма'
&scop col-l6      'Тип'
&scop col-l7      'Код'
&scop col-l8      'ПН'
&scop col-l9      'Дата посл.!корр.'
&scop col-l10     'Номер !док.корр.'
&scop col-l11     'Удалил'
&scop col-l12     'Создал'
&scop col-l13     'Корр.в!статусе АКТ'
&scop col-l14     'Удален в !статусе АКТ'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-ovr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_c-price-doc

/* Definitions for BROWSE br-ovr                                        */
&Scoped-define FIELDS-IN-QUERY-br-ovr {&cop-l1} {&cop-l2} {&cop-l3} {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10} {&cop-l11} {&cop-l12} {&cop-l13} {&cop-l14}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ovr {&cop-l1}
&Scoped-define SELF-NAME br-ovr
&Scoped-define QUERY-STRING-br-ovr FOR EACH buf_c-price-doc       WHERE buf_c-price-doc.host-code = p-host-code and buf_c-price-doc.is-del = true NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-ovr OPEN QUERY {&SELF-NAME} FOR EACH buf_c-price-doc       WHERE buf_c-price-doc.host-code = p-host-code and buf_c-price-doc.is-del = true NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-ovr buf_c-price-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-ovr buf_c-price-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define BUFFER-FIELDS-IN-QUERY-Dialog-Frame buf_c-price-doc.PS ~

&Scoped-define ENABLED-BUFFER-FIELDS-IN-QUERY-Dialog-Frame buf_c-price-doc.PS ~

&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ovr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.buf_c-price-doc.PS
&Scoped-define ENABLED-TABLES ub.buf_c-price-doc
&Scoped-define FIRST-ENABLED-TABLE ub.buf_c-price-doc
&Scoped-Define ENABLED-OBJECTS B-Cancel B-History B-Help br-ovr
&Scoped-Define DISPLAYED-FIELDS ub.buf_c-price-doc.PS
&Scoped-define DISPLAYED-TABLES ub.buf_c-price-doc
&Scoped-define FIRST-DISPLAYED-TABLE ub.buf_c-price-doc


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-History
     LABEL "&История"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY br-ovr FOR
      buf_c-price-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ovr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ovr Dialog-Frame _FREEFORM
  QUERY br-ovr NO-LOCK DISPLAY
      {&cop-l1}   COLUMN-LABEL  {&col-l1}    FORMAT "X(14)":U
  {&cop-l2}   COLUMN-LABEL  {&col-l2}    FORMAT "X(8)":U
  {&cop-l3}   COLUMN-LABEL  {&col-l3}    FORMAT "99/99/99":U
  {&cop-l4}   COLUMN-LABEL  {&col-l4}    FORMAT "99/99/99":U
  {&cop-l5}   COLUMN-LABEL  {&col-l5}    FORMAT "99999":U
  {&cop-l6}   COLUMN-LABEL  {&col-l6}    FORMAT "X(3)":U
  {&cop-l7}   COLUMN-LABEL  {&col-l7}    FORMAT "99999":U
  {&cop-l8}   COLUMN-LABEL  {&col-l8}    FORMAT "X(14)":U
  {&cop-l9}   COLUMN-LABEL  {&col-l9}    FORMAT "99/99/99":U
  {&cop-l10}  COLUMN-LABEL  {&col-l10}   FORMAT "X(14)":U
  {&cop-l11}  COLUMN-LABEL  {&col-l11}   FORMAT "X(8)":U
  {&cop-l12}  COLUMN-LABEL  {&col-l12}   FORMAT "X(8)":U
  {&cop-l13}  COLUMN-LABEL  {&col-l13}   FORMAT "yes/no":U
  {&cop-l14}  COLUMN-LABEL  {&col-l14}   FORMAT "yes/no":U
  ENABLE
      {&cop-l1}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.25 BY 17.25 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-History AT ROW 1 COL 11
     B-Help AT ROW 1 COL 89
     br-ovr AT ROW 2 COL 1
     ub.buf_c-price-doc.PS AT ROW 19.5 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 97.5 BY 3.25
     SPACE(0.75) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Удаленные переоценки"
         CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_c-price-doc B "NEW SHARED" ? ub c-price-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-ovr B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       br-ovr:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ovr
/* Query rebuild information for BROWSE br-ovr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_c-price-doc
      WHERE buf_c-price-doc.host-code = p-host-code and buf_c-price-doc.is-del = true NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "buf_c-price-doc.host-code = p-host-code and buf_c-price-doc.is-del = true"
     _Query            is OPENED
*/  /* BROWSE br-ovr */
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Удаленные переоценки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-History
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-History Dialog-Frame
ON CHOOSE OF B-History IN FRAME Dialog-Frame /* История */
DO:
  run str/pr-cdoc.w (parParentProc , buf_c-price-doc.host-code,  buf_c-price-doc.doc-num) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ovr
&Scoped-define SELF-NAME br-ovr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ovr Dialog-Frame
ON VALUE-CHANGED OF br-ovr IN FRAME Dialog-Frame
DO:
  DISPLAY buf_c-price-doc.PS WITH FRAME {&FRAME-NAME}.
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

{ gbl/mv-clmn.i
 &ext-col = 14
 &start-column = 2
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
}

{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name       =   "c-price-doc"
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
  &sort-clmn_1    =   "{&cop-l1}"
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
  &sort-clmn_12    =  "{&cop-l12}"
  &sort-clmn_13    =  "{&cop-l13}"
  &sort-clmn_14    =  "{&cop-l14}"
&open-query     = "run OpenBr."
&open-query-otherwise = "run OpenBr."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes" }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  {&cop-l1}:read-only in browse {&browse-name} = true .
  run enable_ui.
  run openbr.

  wait-for go of frame {&frame-name}.
end.
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
  IF AVAILABLE buf_c-price-doc THEN
    DISPLAY buf_c-price-doc.PS
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-History B-Help br-ovr buf_c-price-doc.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_clients for ub.clients  .
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

&scop flt-open-open-query OPEN QUERY br-ovr FOR EACH buf_c-price-doc

&scop flt-open-dyn_open-query  FOR EACH buf_c-price-doc

&scop flt-open-query-handle query br-ovr:handle

&scop flt-open-find-buffer-name buf_c-price-doc

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          buf_c-price-doc

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer buf_c-price-doc for ub.c-price-doc.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .
       find first buf_clients no-lock where buf_clients.obj-code = p-host-code and buf_clients.obj-type = {&cmp} no-error .
       if not available buf_clients then return .

       ASSIGN frame {&frame-name}:TITLE = "Удаленные переоценки   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(p-host-code).
      { gbl/fltopend.i
        &where-cond = " buf_c-price-doc.host-code = p-host-code  AND buf_c-price-doc.is-del = TRUE "
        &dyn_where-cond = " substitute (' buf_c-price-doc.host-code = &1  AND buf_c-price-doc.is-del = TRUE ' , p-host-code ) "
        &use-ind    = " USE-INDEX del "
        &by         = " " }


if not p-open-query then
REPOSITION br-ovr to recid doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-ovr:handle:reposition-to-rowid(v-fltopend-rowid) no-error.

{&SetCursorNo}

END PROCEDURE.
PROCEDURE Set-filter-name :
 define input parameter p-filter-name as character no-undo .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME