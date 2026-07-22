&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE find_c-chk-doc NO-UNDO LIKE c-chk-doc.
DEFINE BUFFER X_c-chk-doc FOR c-chk-doc.
DEFINE BUFFER X_chk-doc FOR chk-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision: eb58aa57459c, 2002, rls $
$Author: EShklyar $
$Date: Wed Sep 18 21:01:08 2019 +0300 $
$Workfile: cchkdocs.w $
$Archive: str/cchkdocs.w $

Список истории чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/13/06
Author: Bakhtadze Natalya
Creation date: 01/13/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
define input parameter p-doc-code like ub.chk-doc.doc-code no-undo .
define input parameter p-obj-type like ub.chk-doc.obj-type no-undo.
define input parameter p-obj-code like ub.chk-doc.obj-code no-undo.

/*типы документов в выборке*/
define input-output param p-rid-list    as  char no-undo . /* список recid'ов выбранных c-chk-doc */

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: eb58aa57459c, 2002, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: EShklyar $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Wed Sep 18 21:01:08 2019 +0300 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: cchkdocs.w $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: str/cchkdocs.w $":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории чеков":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ ref/tmpchgs.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ cmp/showinf.i }
{ str/shftnmef.i c-chk-doc shift-name }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
{ gbl/thbj-def.i }

define variable filter-label as character no-undo init "Список истории чеков" .
define variable filter-label0 as character no-undo init "Список истории чеков" .
define variable filter-point as character no-undo init "cchkdocs" .
define variable filter-point0 as character no-undo init "cchkdocs" .

define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.

DEFINE VARIABLE v-host-code like ub.sysconf.host-code no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .

define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-l-mask  as logical no-undo .
define variable v-param-type as character no-undo .
define variable v_d-card  as character no-undo .

{ str/paycardv.i }

FUNCTION get-wro-name returns character(input p-write-off-code as integer):
&SCOP wro-code (if p-write-off-code = ? then {&question-mark} else string(p-write-off-code))
return {&wro-name}.
END FUNCTION.

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-chk-doc

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs mark-string(RECID( X_c-chk-doc), v-rid-list) X_c-chk-doc.corr-date string(X_c-chk-doc.corr-time, "HH:MM") X_c-chk-doc.corr-user-db-num usrfulnf(X_c-chk-doc.corr-user-name) X_c-chk-doc.office X_c-chk-doc.is-add X_c-chk-doc.is-del X_c-chk-doc.doc-code X_c-chk-doc.chk-num X_c-chk-doc.chk-date X_c-chk-doc.shift-date shift-name-no-err(buffer X_c-chk-doc) (string (X_c-chk-doc.chk-time, "HH:MM")) X_c-chk-doc.netto X_c-chk-doc.tot-doc X_c-chk-doc.discnt X_c-chk-doc.sub-discnt X_c-chk-doc.pay-desk X_c-chk-doc.cashier X_c-chk-doc.sales-man X_c-chk-doc.out-code v_d-card   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs X_c-chk-doc.cashier   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-docs X_c-chk-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-docs X_c-chk-doc
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH X_c-chk-doc NO-LOCK
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH X_c-chk-doc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-docs X_c-chk-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs X_c-chk-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-lkp b-restore B-print ~
B-sch B-Help BR-docs ED-notes BR-changes mark-num 
&Scoped-Define DISPLAYED-OBJECTS ED-notes mark-num 

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

DEFINE BUTTON B-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

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

DEFINE BUTTON b-restore 
     LABEL "Восс&танов." 
     SIZE 10 BY 1.

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ED-notes AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY BR-docs FOR X_c-chk-doc SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(50)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.

DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      mark-string(RECID( X_c-chk-doc), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-chk-doc.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      string(X_c-chk-doc.corr-time, "HH:MM")
      X_c-chk-doc.corr-user-db-num FORMAT ">>>>9":U
      usrfulnf(X_c-chk-doc.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-chk-doc.office COLUMN-LABEL "_Тип_" FORMAT "X(7)":U
      X_c-chk-doc.is-add FORMAT "+/":U
      X_c-chk-doc.is-del FORMAT "+/":U
      X_c-chk-doc.doc-code COLUMN-LABEL "Номер_чека" FORMAT "X(20)":U
      X_c-chk-doc.chk-num COLUMN-LABEL "N_по_кассе" FORMAT "->>>>>>>>9":U
      X_c-chk-doc.chk-date FORMAT "99/99/9999":U
      X_c-chk-doc.shift-date COLUMN-LABEL "Смена_от" FORMAT "99/99/9999":U
      shift-name-no-err(buffer X_c-chk-doc) COLUMN-LABEL "№ см." FORMAT "X(6)":U
            WIDTH 7
      (string (X_c-chk-doc.chk-time, "HH:MM"))
      X_c-chk-doc.netto COLUMN-LABEL "Сумма_оплат" FORMAT "->>>,>>>,>>9.99":U
      X_c-chk-doc.tot-doc COLUMN-LABEL "Сумма_товарная" FORMAT "->>>,>>>,>>9.99":U
      X_c-chk-doc.discnt COLUMN-LABEL "Скидка_общая" FORMAT "->>>,>>>,>>9.99":U
      X_c-chk-doc.sub-discnt COLUMN-LABEL "Скидка_на_итог" FORMAT "->>>,>>>,>>9.99":U
      X_c-chk-doc.pay-desk FORMAT ">>>9":U
      X_c-chk-doc.cashier FORMAT "99999":U
      X_c-chk-doc.sales-man COLUMN-LABEL "Прод-w" FORMAT "99999":U
      X_c-chk-doc.out-code COLUMN-LABEL "Номер_РН" FORMAT "X(14)":U
      v_d-card COLUMN-LABEL "N_диск._карты" FORMAT "X(19)":U
  ENABLE
      X_c-chk-doc.cashier
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.04.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lkp AT ROW 1 COL 41
     b-restore AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-docs AT ROW 2.67 COL 1
     ED-notes AT ROW 12.08 COL 1 NO-LABEL
     BR-changes AT ROW 14.67 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.50) SKIP(18.67)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-chk-doc T "?" NO-UNDO ub c-chk-doc
      TABLE: X_c-chk-doc B "?" ? ub c-chk-doc
      TABLE: X_chk-doc B "?" ? ub chk-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes ED-notes Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
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
OPEN QUERY {&SELF-NAME} FOR EACH X_c-chk-doc NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-docs FOR X_c-chk-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  run proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  if available X_c-chk-doc then do:
    { gbl/markstrn.i X_c-chk-doc v-rid-list }
    glog = br-docs:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-docs:select-next-row ().
        apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
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
    run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-restore
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-restore Dialog-Frame
ON CHOOSE OF b-restore IN FRAME Dialog-Frame /* Восстанов. */
DO:
  run proc-b-restore IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-chk-doc ) AND
  ( v-rid-list = ""
  or
  b-mark:sensitive = no
  ) then
    v-rid-list = string( recid( X_c-chk-doc ) ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
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
ON RETURN OF BR-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&self-name} IN FRAME {&frame-name}
DO:
if b-sel:sensitive in frame {&frame-name} then dO:
    if b-mark:sensitive then do:
        apply "choose" to b-mark in frame {&frame-name}.
    end.
    else do:
        apply "choose" to b-sel in frame {&frame-name}.
    end.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE dops as character no-undo .
  dops = if available X_c-chk-doc then X_c-chk-doc.ps else '':U.
  ED-notes:screen-value = dops.
  run proc-view-changes in this-procedure .

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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-docs" }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }
{ gbl/setfltnm.i }

{ gbl/brwrefre.i "v-doc-rec = recid(X_c-chk-doc). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-docs to recid v-doc-rec no-error. v-doc-rec = ?. ~
              apply 'value-changed' to br-docs. " }

{ gbl/srt-clmd.i
&browse-name = "br-docs"
&frame-name  = {&frame-name}
&table-name = "X_c-chk-doc"
&ext-col = 17
&start-column  = 7
&sort-column-name     = "sort-column-name"
&sort-clmn_2   = "X_c-chk-doc.corr-date"
&sort-clmn_9   = "X_c-chk-doc.doc-code"
&sort-clmn_11   = "X_c-chk-doc.chk-date"
&sort-clmn_12   = "X_c-chk-doc.shift-date"
&open-query = "run OpenBr  in this-procedure ( input yes, input no, input '')."
&open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '')."
&re-move-clmn = "no"
&mv-brw-default = "yes"
}
{ gbl/mv-clmn.i
  &browse-name = "br-docs"
  &frame-name = "{&frame-name}"
  &ext-col = 17
  &start-column = 7
}



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 
{ gbl/getcntxt.i get }

if p-mode <> "one":U
and p-mode <> {&deletion}
and p-mode <> {&add-def}
then do:
  message vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-mode" p-mode
  view-as alert-box ERROR.
  return.
end.
  define variable n_MyEnable AS LOGICAL no-undo .
  if p-mode = "one":U then do:
    FIND FIRST X_c-chk-doc No-LOCK where
                X_c-chk-doc.doc-code = p-doc-code 
                No-ERROR.
    if not avail X_c-chk-doc then do:
    n_MyEnable = yes .
      message "История изменений для чека " p-doc-code " не найдена." view-as alert-box .
    end.
  end.

if not n_MyEnable then do: 

  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-chk-doc No-LOCK where
                 recid(find_c-chk-doc) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-chk-doc then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
  end.
  run adm/shattri.p (
      input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-dc-ref}
    ,input  {&attr-dc-ref_l-mask} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-l-mask
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

for each thbjattr_thbj-attr where
       thbjattr_thbj-attr.obj-type = p-obj-type
   and thbjattr_thbj-attr.obj-code = p-obj-code
   and thbjattr_thbj-attr.upper-prop-code = {&attr-dc-ref}
on error undo, return error return-value :
  case thbjattr_thbj-attr.prop-code:
    when {&attr-dc-ref_l-mask} then do:
      assign
      par-l-mask = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.

    run MyEnable in this-procedure .
    RUn OpenBR in this-procedure ( input yes, input no, input '':U).
    HIDE mark-num in frame {&frame-name} .
    REPOSITION br-docs to row 1 No-ERROR.
    run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
    run diasize_init in this-procedure .
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
end.

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
  DISPLAY ED-notes mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-lkp b-restore B-print B-sch B-Help BR-docs 
         ED-notes BR-changes mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-line-changes-current Dialog-Frame 
PROCEDURE get-line-changes-current :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-chip-num like ub.c-chk-doc.chip-num no-undo .
define variable v-chg-fields as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable v-real-field-name as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-doc-attr for ub.chk-doc-attr.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
for each buf_chk-gds no-lock where
            buf_chk-gds.doc-code = p-doc-code,
    first buf_c-chk-gds no-lock where
         buf_c-chk-gds.doc-code = p-doc-code
     AND buf_c-chk-gds.chip-num = p-chip-num
     AND buf_c-chk-gds.line-num = buf_chk-gds.line-num
            :
  buffer-compare
  buf_chk-gds to buf_c-chk-gds
  case-sensitive
  save result in v-chg-fields.
&scop fields-name-list  "b-code,depart-code,depart-id,depart-type,discnt,doc-qnty,is-error," + ~
                        "line-num,line-sign,line-type,loc1,nozzle-code,pass-gds,price-base,price-list-id,price-service,pump," + ~
                        "road-tax,sales-man,salesman-psn-code,src-code,src-discnt,src-price,src-qnty," + ~
                        "src-sum,sum-base,time-oper,write-off-code"

&scop fields-label-list "Бар-код в БД,Код подразделения,ID подразделения,Тип подразделения,Скидка в БД,Количество,Ош," + ~
                        "Номер строки,Знак строки,Тип,Резервуар,Пистолет,Ввод кода товара,Цена в БД,Прайс-лист,Цена серв. эл-та,Номер ТРК," + ~
                        "Дорожный налог,Продавец,Код продавца в БД,Исходный бар-код,Скидка в чеке,Цена чека,Количество в чеке," + ~
                        "Сумма строки в чеке,Сумма строки в БД,Время в сек,Код списания"

&scop fields-function-list ",,,,,,," + ~
                        ",,,,,,,,,," + ~
                        ",,,,,,," + ~
                        ",,,get-wro-name"


  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    v-field-function = entry(jj, {&fields-function-list})
    v-real-field-name = entry(1, v-field-name, ':')
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-gds&1&2&1&3"
                                     ,{&delim-par}
                                     ,buf_chk-gds.line-num
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка товара &1 &2"
                                     ,buf_chk-gds.line-num
                                     ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-gds:buffer-field(v-real-field-name):buffer-value)
    temp-changes.v_new = string(buffer buf_chk-gds:buffer-field(v-real-field-name):buffer-value)
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
for each buf_chk-pay no-lock where
            buf_chk-pay.doc-code = p-doc-code,
    first buf_c-chk-pay no-lock where
         buf_c-chk-pay.doc-code = p-doc-code
     AND buf_c-chk-pay.chip-num = p-chip-num
     AND buf_c-chk-pay.line-num = buf_chk-pay.line-num:
  buffer-compare
  buf_chk-pay to buf_c-chk-pay
  case-sensitive
  save result in v-chg-fields.

&scop fields-name-list "bank-rate,bank-scale,cash-rate,curr-code,is-error,line-num,line-sign," + ~
                       "line-type,pass-pay,pay-card,pay-code,time-oper," + ~
                       "tot-base,tot-rubl,tot-sum"


&scop fields-label-list "Курс ЦБ РФ,Масштаб курса банка ЦБ РФ,Курс,Код валюты,Ош,Номер строки,Знак строки," + ~
                        "Тип,Прохождение платежа (картой или вручную),Номер пл карты карты,код оплаты,Время в сек," + ~
                        "Сумма в баз.в.,Сумма в {&abbr_rub}.,Сумма в валюте оплаты"


  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    /*
    v-field-function = entry(jj, {&fields-function-list})
    */
    v-real-field-name = entry(1, v-field-name, ':')
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-pay&1&2&2&3"
                                     ,{&delim-par}
                                     ,buf_chk-pay.line-num
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка оплат &1 &2"
                                      ,buf_chk-pay.line-num
                                      ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-pay:buffer-field(v-real-field-name):buffer-value)
    temp-changes.v_new = string(buffer buf_chk-pay:buffer-field(v-real-field-name):buffer-value)
    .
  end.
end.

for each buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = p-doc-code,
    first buf_c-chk-discnt no-lock where
          buf_c-chk-discnt.doc-code = p-doc-code
      AND buf_c-chk-discnt.chip-num = p-chip-num
      AND buf_c-chk-discnt.line-num = buf_chk-discnt.line-num
  :
  if buf_c-chk-discnt.record-type = 2 then NEXT.
  buffer-compare
  buf_chk-discnt to buf_c-chk-discnt
  case-sensitive
  save result in v-chg-fields.

&scop fields-name-list  "discnt-id,discnt-type,discnt-value-abs,discnt-value-pcnt,is-error,line-num,line-sign," + ~
                        "line-type,object-line-num,object-qnty,object-sum,pass-discnt,record-type,time-oper,value-type"

&scop fields-label-list  "Вн.№ скидки,Тип скидки,Abs значение скидки,Проц значение скидки,Ош,№ строки скидки,Знак строки," + ~
                         "Тип,№ товарной строки для скидки,Количество,Сумма до скидки,Ввод скидки (картой или вручную),Тип записи,Время в сек,Тип значения"


  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    /*v-field-function = entry(jj, {&fields-function-list})*/
    v-real-field-name = entry(1, v-field-name, ':')
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-discnt&1&2&1&3&1&4&1&5&1&6"
                                     ,{&delim-par}
                                     ,buf_chk-discnt.record-type
                                     ,buf_chk-discnt.line-num
                                     ,buf_chk-discnt.object-line-num
                                     ,buf_chk-discnt.discnt-id
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка скидки &1 &2 к строке &3 &4"
                                     ,buf_chk-discnt.line-num
                                     ,(if buf_chk-discnt.record-type = 0 then ' (исх) ' else ' (выч) ')
                                     ,buf_chk-discnt.object-line-num
                                     ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-discnt:buffer-field(v-real-field-name):buffer-value)
    temp-changes.v_new = string(buffer buf_chk-discnt:buffer-field(v-real-field-name):buffer-value)
    .
  end.
end.
for each buf_chk-doc-attr no-lock where
            buf_chk-doc-attr.doc-code = p-doc-code,
    first buf_c-chk-doc-attr no-lock where
         buf_c-chk-doc-attr.chip-num = p-chip-num
      AND buf_c-chk-doc-attr.doc-code = p-doc-code
   AND buf_c-chk-doc-attr.attr-code = buf_chk-doc-attr.attr-code:
  buffer-compare
  buf_chk-doc-attr to buf_c-chk-doc-attr
  case-sensitive
  save result in v-chg-fields.

&scop fields-name-list "attr-code,attr-value"
&scop fields-label-list "Код атрибута,Значение атрибута"

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    /*v-field-function = entry(jj, {&fields-function-list})*/
    v-real-field-name = entry(1, v-field-name, ':')
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-doc-attr&1&2&2&3"
                                     ,{&delim-par}
                                     ,buf_chk-doc-attr.attr-code
                                     ,v-field-name)
    temp-changes.l_name = substitute("Атрибут чека &1 &2"
                                      ,buf_chk-doc-attr.attr-code
                                      ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-doc-attr:buffer-field(v-field-name):buffer-value)
    temp-changes.v_new = string(buffer buf_chk-doc-attr:buffer-field(v-field-name):buffer-value)
    .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-line-changes-hist Dialog-Frame 
PROCEDURE get-line-changes-hist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code like ub.c-chk-doc.doc-code no-undo .
define input parameter p-chip-num like ub.c-chk-doc.chip-num no-undo.
define input parameter p-new-chip-num like ub.c-chk-doc.chip-num no-undo.
define input parameter p-is-add      like ub.c-chk-doc.is-add no-undo .
define input parameter p-is-del      like ub.c-chk-doc.is-del no-undo .
define variable v-chg-fields as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable v-real-field-name as character no-undo .
define buffer new_c-chk-gds for ub.c-chk-gds.
define buffer new_c-chk-pay for ub.c-chk-pay.
define buffer new_c-chk-discnt for ub.c-chk-discnt.
define buffer new_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
if p-is-del or p-is-add then do:
  assign
  v-chg-fields = get-all-fields("chk-gds":U)
  v-chg-fields = replace(v-chg-fields, "obj-type,":U, "":U)
  v-chg-fields = replace(v-chg-fields, "obj-code,":U, "":U)
  v-chg-fields = replace(v-chg-fields, "doc-code,":U, "":U)
  v-chg-fields = replace(v-chg-fields, "out-code,":U, "":U)
  v-chg-fields = replace(v-chg-fields, {&comma-char}, {&comma-char})
  v-chg-fields = trim(v-chg-fields, {&comma-char})
  .
end.
for each new_c-chk-gds no-lock where
            new_c-chk-gds.doc-code = p-doc-code
        AND new_c-chk-gds.chip-num = p-new-chip-num
            ,
    first buf_c-chk-gds no-lock where
         buf_c-chk-gds.doc-code = p-doc-code
     AND buf_c-chk-gds.chip-num = p-chip-num
     AND buf_c-chk-gds.line-num = new_c-chk-gds.line-num
            :
  if not (p-is-del or p-is-add ) then
  buffer-compare
  new_c-chk-gds to buf_c-chk-gds
  case-sensitive
  save result in v-chg-fields.


&scop fields-name-list  "b-code,depart-code,depart-id,depart-type,discnt,doc-qnty,is-error," + ~
                        "line-num,line-sign,line-type,loc1,nozzle-code,pass-gds,price-base,price-list-id,price-service,pump," + ~
                        "road-tax,sales-man,salesman-psn-code,src-code,src-discnt,src-price,src-qnty," + ~
                        "src-sum,sum-base,time-oper,write-off-code"

&scop fields-label-list "Бар-код в БД,Код подразделения,ID подразделения,Тип подразделения,Скидка в БД,Количество,Ош," + ~
                        "Номер строки,Знак строки,Тип,Резервуар,Пист,Ввод кода товара,Цена в БД,Прайс-лист,Цена серв. эл-та,Номер ТРК," + ~
                        "Дорожный налог,Продавец,Код продавца в БД,Исходный бар-код,Скидка в чеке,Цена чека,Количество в чеке," + ~
                        "Сумма строки в чеке,Сумма строки в БД,Время в сек,Код списания"

&scop fields-function-list ",,,,,,," + ~
                        ",,,,,,,,,," + ~
                        ",,,,,,," + ~
                        ",,,"

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    v-field-function = entry(jj, {&fields-function-list})
    v-real-field-name = entry(1, v-field-name, ":")
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-gds&1&2&1&3"
                                      ,{&delim-par}
                                      ,new_c-chk-gds.line-num
                                      ,v-field-name)
    temp-changes.l_name = substitute("Строка товара &1 &2"
                                      ,new_c-chk-gds.line-num
                                      ,v-field-label)
    temp-changes.v_old = (if p-is-add
                          then "":U
                          else string(buffer buf_c-chk-gds:buffer-field(v-real-field-name):buffer-value))
    temp-changes.v_new = (if p-is-del
                          then "":U
                          else string(buffer new_c-chk-gds:buffer-field(v-real-field-name):buffer-value))
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
if p-is-del or p-is-add
then
assign
v-chg-fields = get-all-fields("chk-pay":U)
v-chg-fields = replace(v-chg-fields, "obj-type,":U, "":U)
v-chg-fields = replace(v-chg-fields, "obj-code,":U, "":U)
v-chg-fields = replace(v-chg-fields, "doc-code,":U, "":U)
v-chg-fields = replace(v-chg-fields, "out-code,":U, "":U)
.
for each new_c-chk-pay no-lock where
            new_c-chk-pay.doc-code = p-doc-code
        AND new_c-chk-pay.chip-num = p-new-chip-num
            ,
    first buf_c-chk-pay no-lock where
          buf_c-chk-pay.doc-code = p-doc-code
      AND buf_c-chk-pay.chip-num = p-chip-num
      AND buf_c-chk-pay.line-num = new_c-chk-pay.line-num:
  if not (p-is-del or p-is-add ) then
  buffer-compare
  new_c-chk-pay to buf_c-chk-pay
  case-sensitive
  save result in v-chg-fields.

&scop fields-name-list "bank-rate,bank-scale,cash-rate,curr-code,is-error,line-num,line-sign," + ~
                       "line-type,pass-pay,pay-card,pay-code,time-oper," + ~
                       "tot-base,tot-rubl,tot-sum"


&scop fields-label-list "Курс ЦБ РФ,Масштаб курса банка ЦБ РФ,Курс,Код валюты,Ош,Номер строки,Знак строки," + ~
                        "Тип,Прохождение платежа (картой или вручную),Номер пл карты карты,код оплаты,Время в сек," + ~
                        "Сумма в баз.в.,Сумма в {&abbr_rub}.,Сумма в валюте оплаты"


  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    /*v-field-function = entry(jj, {&fields-function-list})*/
    v-real-field-name = entry(1, v-field-name, ':')
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-pay &1&2&1&3":U
                                     ,{&delim-par}
                                     ,new_c-chk-pay.line-num
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка оплат &1 &2"
                                      ,new_c-chk-pay.line-num
                                      ,v-field-label)
    temp-changes.v_old = (if p-is-add
                         then '':U
                         else string(buffer buf_c-chk-pay:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if p-is-del
                         then '':U
                         else string(buffer new_c-chk-pay:buffer-field(v-field-name):buffer-value))
    .
  end.
end.
if p-is-del or p-is-add
then
assign
v-chg-fields = get-all-fields("chk-discnt":U)
v-chg-fields = replace(v-chg-fields, "obj-type,":U, "":U)
v-chg-fields = replace(v-chg-fields, "obj-code,":U, "":U)
v-chg-fields = replace(v-chg-fields, "doc-code,":U, "":U)
v-chg-fields = replace(v-chg-fields, "out-code,":U, "":U)
.
for each new_c-chk-discnt no-lock where
            new_c-chk-discnt.doc-code = p-doc-code
        AND new_c-chk-discnt.chip-num = p-new-chip-num
            ,
    first buf_c-chk-discnt no-lock where
         buf_c-chk-discnt.doc-code = p-doc-code
     AND buf_c-chk-discnt.chip-num = p-chip-num
     AND buf_c-chk-discnt.line-num = new_c-chk-discnt.line-num
  :
  if not (p-is-del or p-is-add ) then
  buffer-compare
  new_c-chk-discnt to buf_c-chk-discnt
  case-sensitive
  save result in v-chg-fields.

&scop fields-name-list  "discnt-id,discnt-type,discnt-value-abs,discnt-value-pcnt,is-error,line-num,line-sign," + ~
                        "line-type,object-line-num,object-qnty,object-sum,pass-discnt,record-type,time-oper,value-type"

&scop fields-label-list  "Вн.№ скидки,Тип скидки,Abs значение скидки,Проц значение скидки,Ош,№ строки скидки,Знак строки," + ~
                         "Тип,№ товарной строки для скидки,Количество,Сумма до скидки,Ввод скидки (картой или вручную),Тип записи,Время в сек,Тип значения"


  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    /*v-field-function = entry(jj, {&fields-function-list})*/
    v-real-field-name = entry(1, v-field-name, ':')
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-discnt&1&2&1&3&1&4&1&5&1&6"
                                     ,{&delim-par}
                                     ,new_c-chk-discnt.record-type
                                     ,new_c-chk-discnt.line-num
                                     ,new_c-chk-discnt.object-line-num
                                     ,new_c-chk-discnt.discnt-id
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка скидки &1 &2 к строке товара &3 &4"
                                     ,new_c-chk-discnt.line-num
                                     ,(if new_c-chk-discnt.record-type = 0 then ' (исх) ' else ' (выч) ')
                                     ,new_c-chk-discnt.object-line-num
                                     ,v-field-label)
    temp-changes.v_old = (if p-is-add
                         then '':U
                         else string(buffer buf_c-chk-discnt:buffer-field(v-real-field-name):buffer-value))
    temp-changes.v_new = (if p-is-del
                         then '':U
                         else string(buffer new_c-chk-discnt:buffer-field(v-real-field-name):buffer-value))
    .
  end.
end.
assign
v-chg-fields = get-all-fields("chk-doc-attr":U)
.
for each new_c-chk-doc-attr no-lock where
            new_c-chk-doc-attr.doc-code = p-doc-code
        AND new_c-chk-doc-attr.chip-num = p-new-chip-num
            ,
    first buf_c-chk-doc-attr no-lock where
         buf_c-chk-doc-attr.doc-code = p-doc-code
     AND buf_c-chk-doc-attr.chip-num = p-chip-num
   AND buf_c-chk-doc-attr.attr-code = new_c-chk-doc-attr.attr-code:
  if not (p-is-del or p-is-add ) then
  buffer-compare
  new_c-chk-doc-attr to buf_c-chk-doc-attr
  case-sensitive
  save result in v-chg-fields.

&scop fields-name-list "attr-code,attr-value"
&scop fields-label-list "Код атрибута,Значение атрибута"

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    /*v-field-function = entry(jj, {&fields-function-list})*/
    v-real-field-name = entry(1, v-field-name, ':')
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-doc-attr&1&2&2&3"
                                     ,{&delim-par}
                                     ,new_c-chk-doc-attr.attr-code
                                     ,v-field-name)
    temp-changes.l_name = substitute("Атрибут чека &1 &2"
                                      ,new_c-chk-doc-attr.attr-code
                                      ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-doc-attr:buffer-field(v-field-name):buffer-value)
    temp-changes.v_new = string(buffer new_c-chk-doc-attr:buffer-field(v-field-name):buffer-value)
    .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define buffer buf_currency for ub.currency.
ASSIGN
br-docs:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 6
X_c-chk-doc.cashier:READ-ONLY IN BROWSE br-docs = YES
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 50
temp-changes.v_old:width in browse br-changes = 20
temp-changes.v_new:width in browse br-changes = 20
.

if p-mode =  "one":u then do:
  assign
  p-obj-type = X_c-chk-doc.obj-type
  p-obj-code = X_c-chk-doc.obj-code
  .
end.

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/basecode.i v-host-code v-base-code }
find first buf_currency no-lock where
        buf_currency.curr-code = v-base-code.
assign
v-base-type = buf_currency.curr-abbr.


DISPLAY
ED-notes
mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
b-help
br-docs
b-lkp
b-restore WHEN (LOOKUP("b-restore", bttns) > 0 and p-mode = {&deletion})
b-sel  when LOOKUP("b-sel":U, bttns) > 0
b-mark when LOOKUP("b-mark":U, bttns) > 0
b-sch
b-print
br-changes
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
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
title0 = "Список истории чеков" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH X_c-chk-doc

&scop flt-open-dyn_open-query FOR EACH X_c-chk-doc

&scop flt-open-query-handle QUERY br-docs:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-chk-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-chk-doc

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


  CASE p-mode :
    WHEN "one":U        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1", filter-label0)
     frame {&frame-name} :title = substitute("История изменения чека &1", p-doc-code)
     .

     { gbl/fltopend.i
        &where-cond = " X_c-chk-doc.doc-code = p-doc-code "
        &dyn_where-cond = " substitute('X_c-chk-doc.doc-code = &1&2&1', ~{&double-quote~}, p-doc-code )"
        &use-ind    = "  "
        &by         = " by X_c-chk-doc.chip-num descending " }
    END.
    WHEN {&deletion}        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1 удаленные чеки", filter-label0)
     frame {&frame-name} :title = substitute("Чеки, удаленные в &1&2", p-obj-type, p-obj-code)
     .

     { gbl/fltopend.i
        &where-cond = " X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-del = yes "
        &dyn_where-cond = " substitute('X_c-chk-doc.obj-type = &1&2&1 and X_c-chk-doc.obj-code = &3 and X_c-chk-doc.is-del = yes ' ~
                              , ~{&double-quote~}, p-obj-type, p-obj-code)"
        &use-ind    = " use-index idel "
        &by         = "  " }
    END.
    WHEN {&add-def}        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1 созданные вручную чеки", filter-label0)
     frame {&frame-name} :title = substitute("Чеки, созданные вручную  в &1&2", p-obj-type, p-obj-code)
     .
     { gbl/fltopend.i
        &where-cond = " X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-add = yes "
        &dyn_where-cond = " substitute('X_c-chk-doc.obj-type = &1&2&1 and X_c-chk-doc.obj-code = &3 and X_c-chk-doc.is-add = yes ' ~
                                , ~{&double-quote~}, p-obj-type, p-obj-code)"
        &use-ind    = " use-index iadd "
        &by         = "  " }
    END.
END CASE.

if not p-open-query then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame 
PROCEDURE proc-b-lkp :
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
if not available X_c-chk-doc then return.
v-doc-rec = recid(X_c-chk-doc).
DO WHILE next-prev = '':U:
  if NOT available X_c-chk-doc then do:
    message "Неправильно выбрана запись истории чека." view-as alert-box ERROR.
    return no-apply.
  end.
  v-doc-rec = recid (X_c-chk-doc).
  run str/suprcchk.w (
                   input parparentproc
                  ,input {&lookup}
                  ,input X_c-chk-doc.obj-type
                  ,input X_c-chk-doc.obj-code
                  ,input-output v-doc-rec
                  ,input this-procedure:handle
                  ,input-output next-prev
                              ) no-error.
  END .

reposition br-docs to recid v-doc-rec no-error.
apply "entry" to br-docs in frame {&frame-name}.
apply "value-changed" to br-docs in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame 
PROCEDURE proc-b-print :
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable v-time as character no-undo .
define variable v-shift-name-num as character no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( v-base-type ) + " )" )
  .
end.



DEFINE FRAME Chk-List
X_c-chk-doc.corr-date COLUMN-LABEL "Дата корр"
v-time                COLUMN-LABEL "Время корр"
X_c-chk-doc.corr-user-db-num
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(18)"
X_c-chk-doc.is-add FORMAT "+/"
X_c-chk-doc.is-del FORMAT "+/"
X_c-chk-doc.office       column-label "Тип_"                format "X(8)"
X_c-chk-doc.doc-code      column-label "Номер_чека"  format "X(17)"
X_c-chk-doc.chk-num       column-label "N_по_кассе" format "->>>>>>9"
X_c-chk-doc.chk-date       column-label "Дата" format "99/99/9999"
for-time                  column-label "Время"   format "X(5)"
X_c-chk-doc.shift-date      column-label "Смена_от" format "99/99/9999"
v-shift-name-num      column-label "N_см."  FORMAT "X(6)"
X_c-chk-doc.netto             column-label "Сумма_оплат"
X_c-chk-doc.pay-desk      column-label "Касса"
X_c-chk-doc.cashier         column-label "Кассир"       format ">>>>9"
X_c-chk-doc.sales-man    column-label "Прод-ц"       format ">>>>9"
X_c-chk-doc.out-code       column-label "Номер_РН"
v_d-card           column-label "Номер_диск._карты"              space(0)
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", {&A4_LS}).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                    input parParentProc
                                    ,input {&LS_PS_A4}
                                    ,input yes /*p-is-stream*/
                                    ,input no /*p-append*/
                                    ).
v-doc-rec = recid( X_c-chk-doc ).
DO WHILE available X_c-chk-doc :
      GET prev br-docs.
END.


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X({&A4_LS})" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Chk-List  .
run waitfram-show in this-procedure ( input "Ждите...").
GET next br-docs.
DO WHILE available X_c-chk-doc :
  if par-l-mask then v_d-card = substring(X_c-chk-doc.d-card,1,6) + "XXXXXX" + substring (X_c-chk-doc.d-card,13,4).
  else v_d-card = X_c-chk-doc.d-card .
  
  Display STREAM PrnLibStream
  X_c-chk-doc.corr-date
  string(X_c-chk-doc.corr-time, "HH:MM") @ v-time
  X_c-chk-doc.corr-user-db-num
  usrfulnf(X_c-chk-doc.corr-user-name) @ v-for-user-name
  X_c-chk-doc.is-add
  X_c-chk-doc.is-del
  X_c-chk-doc.office
  X_c-chk-doc.doc-code
  X_c-chk-doc.chk-num
  X_c-chk-doc.chk-date
  string(X_c-chk-doc.chk-time, "HH:mm") @ for-time
  X_c-chk-doc.shift-date
  shift-name-no-err(buffer X_c-chk-doc) @ v-shift-name-num
  X_c-chk-doc.netto
  X_c-chk-doc.pay-desk
  X_c-chk-doc.cashier
  X_c-chk-doc.sales-man
  if X_c-chk-doc.out-code <> ? then X_c-chk-doc.out-code else "" @ X_c-chk-doc.out-code
  v_d-card
  with FRAME Chk-List .
  
DOWN STREAM PrnLibStream 1 with FRAME CHk-List  .
assign
accum-count = accum-count + 1
.
GET next br-docs.
END.
UNDERLINE  STREAM PrnLibStream
X_c-chk-doc.corr-date
v-time
X_c-chk-doc.corr-user-db-num
v-for-user-name
X_c-chk-doc.is-add
X_c-chk-doc.is-del
X_c-chk-doc.office
X_c-chk-doc.doc-code
X_c-chk-doc.chk-num
X_c-chk-doc.chk-date
for-time
X_c-chk-doc.shift-date
v-shift-name-num
X_c-chk-doc.netto
X_c-chk-doc.pay-desk
X_c-chk-doc.cashier
X_c-chk-doc.sales-man
X_c-chk-doc.out-code
v_d-card

with FRAME Chk-List .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-chk-doc.doc-code
accum-count @ X_c-chk-doc.chk-num
with frame Chk-List.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME fin-bank-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-docs to recid v-doc-rec no-error.
APPLY "entry" to br-docs.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-restore Dialog-Frame 
PROCEDURE proc-b-restore :
define variable glog as logical no-undo .
  if available X_c-chk-doc
  then do:
    define variable v-chk-act-host-code as integer   no-undo .
    { gbl/hostcode.i
      X_c-chk-doc.obj-type
      X_c-chk-doc.obj-code
      v-chk-act-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_receipt_input':U
      {&cntxt-object}
      v-chk-act-host-code
      X_c-chk-doc.obj-type
      X_c-chk-doc.obj-code
      0
      0
      0
      true
      glog
    }

    if NOT glog then  return error.
    glog = no.
    message
    "Вы уверены, что хотите ВОССТАНОВИТЬ данный чек?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return.
    run str/chk-rest.p ( input X_c-chk-doc.doc-code) no-error.
    if error-status:error then do:
      message
      substitute("Ошибка при восстановлении чека &1&2&3&2&4"
                  , X_c-chk-doc.doc-code
                  ,{&new-line}
                  , error-status:get-message(1)
                  , return-value
                  )
      view-as alert-box error.
    end.
  end.
  get prev br-docs.
  if available X_c-chk-doc then do:
    assign
    v-doc-rec = recid(X_c-chk-doc).
  end.
  run OpenBr in this-procedure ( input yes, input no, input '':U).
  APPLY "ENTRY" to br-docs in frame {&frame-name} .
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
  tbl = 'c-chk-doc'
  join-tbl = 'X_c-chk-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Смена от', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смен', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'Номер продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w (
                    input parparentproc
                  , INPUT (filter-point + {&delim-par} + filter-label)
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer new_c-chk-doc for ub.c-chk-doc.
define buffer current_chk-doc for ub.chk-doc.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable v-real-field-name as character no-undo .


for each temp-changes:
    delete temp-changes.
END.
if not available X_c-chk-doc then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
if X_c-chk-doc.is-del then do:
  assign
  v-chg-fields = get-all-fields("chk-doc")
  .
  run get-line-changes-hist in this-procedure (
                                               input X_c-chk-doc.doc-code
                                             , input X_c-chk-doc.chip-num
                                             , input X_c-chk-doc.chip-num
                                             , input X_c-chk-doc.is-add and X_c-chk-doc.chip-num = 1
                                             , input X_c-chk-doc.is-del).
end.
else do:
  find first new_c-chk-doc no-lock where
              new_c-chk-doc.doc-code = X_c-chk-doc.doc-code
                AND new_c-chk-doc.chip-num > X_c-chk-doc.chip-num no-error.
  if not available new_c-chk-doc then do:
      find first current_chk-doc no-lock where
                  current_chk-doc.doc-code = X_c-chk-doc.doc-code no-error.

      if not available current_chk-doc then do:
          return error.
      end.
      buffer-compare current_chk-doc except PS to X_c-chk-doc
      case-sensitive
      save result in v-chg-fields.
      run get-line-changes-current in this-procedure ( input X_c-chk-doc.chip-num).
  end.
  else do:
      buffer-compare new_c-chk-doc except PS  chip-num corr-date corr-user-name corr-user-db-num  to X_c-chk-doc
      case-sensitive
      save result in v-chg-fields.
      run get-line-changes-hist in this-procedure (
                                                   input X_c-chk-doc.doc-code
                                                 , input X_c-chk-doc.chip-num
                                                 , input new_c-chk-doc.chip-num
                                                 , input X_c-chk-doc.is-add and X_c-chk-doc.chip-num = 1
                                                 , input X_c-chk-doc.is-del
                                                 ).
  end.
end.

&scop fields-name-list "cash-rate,cash-scale,cashier,cashier-psn-code,chk-date,chk-num,chk-time,chk-type," + ~
                       "correct,d-card,d-pcnt,discnt,doc-code,doc-num,doc-qnty,netto,obj-code,obj-type,office," + ~
                       "out-code,pay-desk,price-type,PS,sales-man,salesman-psn-code,shift-date,shift-num,src-d-pcnt," + ~
                       "src-shift-date,tot-doc,z-number"

&scop fields-label-list  "Курс валюты кассы,Масштаб ваюты кассы,Кассир,Код кассира в БД,Дата,№ Чек на кассе,Время,Тип чека,"  + ~
                         "OK,Дисконтная карта,Процент скидки,Скидка общая,Номер,Номер документа,Количество,Сумма оплат,Код объекта,Тип объекта,Тип," + ~
                         "Номер РН,Касса,Тип цены,Примечание,Продавец,Код продавца в БД,Дата смены (учета),Порядок Смен,Процент скидки на кассе," + ~
                         "Дата смены на кассе,Сумма ценах продажи,Номер z-отчета"

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    /*v-field-function = entry(jj, {&fields-function-list})*/
    v-real-field-name = entry(1, v-field-name, ':')
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-doc&1&2"
                                     ,{&delim-par}
                                     ,v-field-name)
    temp-changes.l_name = substitute("Шапка чека &1"
                                     ,v-field-label)
    temp-changes.v_old = (if X_c-chk-doc.is-add  and X_c-chk-doc.chip-num = 1
                          then "":U
                          else string(buffer X_c-chk-doc:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if X_c-chk-doc.is-del
                          then "":U
                          else (if X_c-chk-doc.is-add  and X_c-chk-doc.chip-num = 1
                                then string(buffer X_c-chk-doc:buffer-field(v-field-name):buffer-value)
                                else (if available new_c-chk-doc
                                        then string(buffer new_c-chk-doc:buffer-field(v-field-name):buffer-value)
                                        else string(buffer current_chk-doc:buffer-field(v-field-name):buffer-value)
                                      )
                              )
                          )
    .
end.

Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-c-chk-doc Dialog-Frame 
PROCEDURE reposition-c-chk-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-chk-doc-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-docs.
    end.
    when "last":U
    then do:
      get last br-docs.
    end.
    when "prev":U
    then do:
      get prev br-docs.
      if not available X_c-chk-doc then do:
        message
        "Это первый чек списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available X_c-chk-doc then do:
        message
        "Это последний чек списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-chk-doc-recid = recid(X_c-chk-doc)
  .
  run reposition-query in this-procedure
    (input p-chk-doc-recid
    ).




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame 
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-docs to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
    apply "VALUE-CHANGED":u to browse {&browse-name} .
  end. /* do with frame */




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

