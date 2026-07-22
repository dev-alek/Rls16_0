&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
define TEMP-TABLE tt-c-usr-hist like ub.c-usr-hist .
DEFINE BUFFER find_c-usr-hist FOR c-usr-hist.
DEFINE BUFFER X_c-usr-hist    FOR tt-c-usr-hist.
/*DEFINE BUFFER X_clients FOR clients.     */
/*DEFINE BUFFER X_curr-sysconf FOR sysconf.*/
/*DEFINE BUFFER X_goods FOR goods.         */
/*DEFINE BUFFER X_place FOR place.         */
/*DEFINE BUFFER X_sysconf FOR sysconf.     */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список полной истории пользователя

Автор: Шкляр Елена
Дата создания: 01/22/04
Author: Shklyar Elena
Creation date: 01/22/04

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo.
define input parameter p-userid         as character        no-undo.

/*контекст сессии*/
define variable bttns           as char no-undo .
/*кнопки для нажатия*/

define variable p-mode          as char no-undo .
/*может быть {&all} "one":U {&g___object} "subject":U */
define variable p-subject       like ub.c-plc-hist.subject no-undo .


/*записи в выборке*/
define variable p-rid-list      as char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории пользователя":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
{ gbl/color.i }
define variable filter-point     as character no-undo init "cusrhist" .
define variable filter-point0    as character no-undo init "cusrhist" .
define variable filter-label     as character no-undo init "История пользователя" .
define variable filter-label0    as character no-undo init "История пользователя" .
define variable v-rid-list       as character no-undo .
define variable sort-column-name as character no-undo .
define variable print-option     as character no-undo.
DEFINE VARIABLE v-db-num         like ub.db.db-num no-undo .
define variable v-doc-rec        as recid     no-undo .
define variable v-find           as logical   no-undo.
define variable v-pl-name        like ub.place.pl-name no-undo.
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr   as character no-undo .
define variable v-subject-chr    as character no-undo .
define variable v-host-code      like ub.sysconf.host-code no-undo .

/*вспомогат*/
define variable dops             as character no-undo format "X(250)".
define variable dopst            as character no-undo format "X(1)".

define buffer X_curr_sysconf for ub.sysconf.
{ ref/tmpchgs.i "NEW SHARED"}

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-usr-hist

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-usr-hist                                   */
&Scoped-define FIELDS-IN-QUERY-br-usr-hist mark-string(recid(X_c-usr-hist), v-rid-list) X_c-usr-hist.corr-date string(X_c-usr-hist.corr-time, "HH:MM:SS":U) usrfulnf(X_c-usr-hist.corr-user-name) get-action(X_c-usr-hist.action) X_c-usr-hist.corr-user-db-num X_c-usr-hist.subject
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-usr-hist X_c-usr-hist.corr-DATE
&Scoped-define ENABLED-TABLES-IN-QUERY-br-usr-hist X_c-usr-hist
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-usr-hist X_c-usr-hist
&Scoped-define SELF-NAME br-usr-hist
&Scoped-define QUERY-STRING-br-usr-hist FOR EACH X_c-usr-hist NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-usr-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-usr-hist NO-LOCK by X_c-usr-hist.corr-date desc INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-br-usr-hist X_c-usr-hist
&Scoped-define FIRST-TABLE-IN-QUERY-br-usr-hist X_c-usr-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel cb-user-table B-print ~
B-sch B-Help B-lookup br-usr-hist BR-changes mark-num 
&Scoped-Define DISPLAYED-OBJECTS cb-user-table mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame 
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-place Dialog-Frame 
FUNCTION get-place RETURNS CHARACTER
  ( p-obj-type as character, p-obj-code as integer, p-pl-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-subject Dialog-Frame 
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
  LABEL "Помо&щь" 
  SIZE 3 BY 1
  BGCOLOR 8 .

DEFINE BUTTON B-lookup 
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

DEFINE BUTTON B-sch 
  LABEL "&Фильтр" 
  SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
  LABEL "Вы&бор" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
  VIEW-AS TEXT 
  SIZE 6 BY 1
  FGCOLOR 4 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
  temp-changes SCROLLING.

DEFINE QUERY br-usr-hist FOR
  X_c-usr-hist SCROLLING.
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
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.29.

DEFINE BROWSE br-usr-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-usr-hist Dialog-Frame _FREEFORM
  QUERY br-usr-hist NO-LOCK DISPLAY
  mark-string(recid(X_c-usr-hist), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
  X_c-usr-hist.corr-date FORMAT "99/99/9999":U
  string(X_c-usr-hist.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
  usrfulnf(X_c-usr-hist.corr-user-name) FORMAT "X(18)":U
  get-action(X_c-usr-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
  X_c-usr-hist.corr-user-db-num FORMAT ">>>>9":U
  X_c-usr-hist.subject COLUMN-LABEL "Предмет изменений" FORMAT "X(15)":U
  ENABLE
      X_c-usr-hist.corr-DATE
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  b-quit AT ROW 1 COL 1
  B-mark AT ROW 1 COL 11
  b-sel AT ROW 1 COL 21
  B-print AT ROW 1 COL 89
  B-sch AT ROW 1 COL 92
  B-Help AT ROW 1 COL 95
  B-lookup AT ROW 1.04 COL 45
  br-usr-hist AT ROW 2 COL 1
  BR-changes AT ROW 13.75 COL 1
  mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
  SPACE(78.74) SKIP(20.07)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Полная история по пользователю"
  CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-plc-hist B "?" NO-UNDO ub c-plc-hist
      TABLE: X_c-plc-hist B "?" ? ub c-plc-hist
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr-sysconf B "?" ? ub sysconf
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_place B "?" ? ub place
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-usr-hist B-lookup Dialog-Frame */
/* BROWSE-TAB BR-changes br-usr-hist Dialog-Frame */
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-usr-hist
/* Query rebuild information for BROWSE br-usr-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-usr-hist NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-plc-hist */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Полная история по пользователю */
  DO:
    p-rid-list = v-rid-list.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Полная история по пользователю */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
  DO:
    define variable loc#log as logical no-undo .
    if available X_c-usr-hist then 
    do:
    { gbl/markstrn.i X_c-usr-hist v-rid-list }
      loc#log = br-usr-hist:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
      do:
        loc#log = br-usr-hist:select-next-row ().
        apply "VALUE-CHANGED" to br-usr-hist in frame {&frame-name}.
      end.
      if num-entries( v-rid-list ) = 0
        then
        hide mark-num in frame {&frame-name}.
      else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-usr-hist in frame {&frame-name}.
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
    if ( available X_c-usr-hist ) then 
    do:
      if ( v-rid-list = "" ) or b-mark:sensitive = no
        then
        v-rid-list = string( recid( X_c-usr-hist ) ) .
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME sch-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-obj-code Dialog-Frame
ON ROW-DISPLAY OF BR-changes IN FRAME Dialog-Frame /* коду */
DO:
   if temp-changes.fNotChange
   then do:
      temp-changes.l_name:fGCOLOR in browse BR-changes = GRAY_COLOR.
      temp-changes.v_old:fGCOLOR in browse BR-changes  = GRAY_COLOR.
      temp-changes.v_new:fGCOLOR in browse BR-changes  = GRAY_COLOR.
   end.
   else do:
      temp-changes.l_name:fGCOLOR in browse BR-changes = BLACK_COLOR.
      temp-changes.v_old:fGCOLOR in browse BR-changes = BLACK_COLOR.
      temp-changes.v_new:fGCOLOR in browse BR-changes = BLACK_COLOR.
   end.
   
          
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-usr-hist
&Scoped-define SELF-NAME br-usr-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-usr-hist Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-usr-hist IN FRAME Dialog-Frame
  DO:
    run proc-br-usr-hist in this-procedure no-error.
    if error-status:error then return no-apply.


  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-usr-hist Dialog-Frame
ON RETURN OF br-usr-hist IN FRAME Dialog-Frame
  DO:
    run proc-br-usr-hist in this-procedure no-error.
    if error-status:error then return no-apply.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-usr-hist Dialog-Frame
ON VALUE-CHANGED OF br-usr-hist IN FRAME Dialog-Frame
  DO:
    run proc-view-changes in this-procedure no-error.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable v-date-start as date no-undo .
  define variable v-date-end   as date no-undo .
  
  v-date-end = today .
  v-date-start = v-date-end - 30 .

  for each X_c-usr-hist:
    delete X_c-usr-hist .
  end.
  for each c-usr-hist where c-usr-hist.user-id = p-userid and c-usr-hist.corr-date > v-date-start 
    and (c-usr-hist.corr-date < v-date-end or c-usr-hist.corr-date = v-date-end) by c-usr-hist.corr-date desc:
    create X_c-usr-hist .
    buffer-copy c-usr-hist to X_c-usr-hist .
  end.
        
  {&OPEN-QUERY-br-usr-hist}
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
    REPOSITION br-usr-hist to recid integer(entry(1, v-rid-list)) No-ERROR.

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
  ------------------------------------------------------------------------------*/
  DISPLAY mark-num b-sel B-print B-sch B-Help B-lookup 
    BR-changes 
    WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark  br-usr-hist 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
  assign
    br-usr-hist:num-locked-columns in frame {&frame-name}  = 1
    X_c-usr-hist.corr-DATE:read-only in browse br-usr-hist = yes
    br-changes:title                                       = "":U
    temp-changes.l_name:resizable in browse br-changes     = true
    temp-changes.v_old:resizable in browse br-changes      = true
    temp-changes.v_new:resizable in browse br-changes      = true
    temp-changes.l_name:width in browse br-changes         = 30
    temp-changes.v_old:width in browse br-changes          = 40
    temp-changes.v_new:width in browse br-changes          = 40
    .
  VIEW frame {&frame-name} .
  DISPLAY
    mark-num
    B-mark 
    when lookup("b-mark":U, bttns) > 0
    b-sel 
    when lookup("b-sel":U, bttns) > 0
    B-lookup
    B-sch
    B-Print
    B-Help
    WITH FRAME {&frame-name} .
  ENABLE
    b-quit
  
    br-usr-hist
    BR-changes mark-num
    WITH FRAME {&frame-name} .
  VIEW FRAME {&frame-name} .
  hide b-lookup 
    in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical   no-undo .
  define variable v-title            as character no-undo .
  define variable title0             as character no-undo.
  title0 = "История складского места" + {&space-char}.
  run waitfram-show in this-procedure ( input "Ждите...").

  define variable sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then 
      do:
        assign
          sort-column-phrase = ""
          .
      end.
    otherwise 
    do:
      assign
        sort-column-phrase = "by " + sort-column-name
        .
    end.
  end case.


&scop flt-open-open-query OPEN QUERY br-usr-hist FOR EACH X_c-usr-hist

&scop flt-open-open-query-tail

&scop flt-open-query-handle query br-usr-hist:handle

&scop flt-open-dyn_open-query  FOR EACH X_c-usr-hist

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-usr-hist

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-usr-hist

&scop flt-open-waitfram yes

  define variable l-open-query as logical no-undo .
  CASE p-mode :
    WHEN {&all}        THEN 
      DO:
        assign
          filter-point = filter-point0 + p-mode
          filter-label = substitute("&1", filter-label0)
          .
  { gbl/fltopend.i
      &where-cond = " TRUE "
      &use-ind    = " use-index  ie02 "
      &by         = "  " }
      END.
  END CASE.

  if not p-open-query  and v-doc-rec <> ? then
    REPOSITION br-usr-hist to recid v-doc-rec No-ERROR.
  if not p-open-query and v-fltopend-rowid[1] <> ? then
    query br-usr-hist:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
  run waitfram-hide in this-procedure .
  APPLY "VALUE-CHANGED" TO br-usr-hist in frame {&frame-name}.
  APPLY "ENTRY" TO br-usr-hist.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-plc-hist Dialog-Frame 
PROCEDURE proc-br-plc-hist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }
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
  define variable v-description as character no-undo .
  for each temp-changes:
    delete temp-changes.
  END.
  if not available X_c-usr-hist then 
  do:
    Open QUery br-changes for each temp-changes.
    return.
  end.

  run str/cuserhistv.p (
    input X_c-usr-hist.user-id
    ,input X_c-usr-hist.chip-num
    ,input X_c-usr-hist.corr-user-db-num
    ,input X_c-usr-hist.subject
    ,input X_c-usr-hist.action
    ,input no /*p-silent*/
    ,output v-description
    ) no-error .
  Open QUery br-changes for each temp-changes.
  assign
    br-changes:title in frame {&frame-name} = v-description
    .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame 
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  &scop hn-action-code trim(string(p-action))
  define variable dops as character no-undo.
  assign 
    dops = {&hn-action-name} no-error.

  RETURN dops.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-place Dialog-Frame 
FUNCTION get-place RETURNS CHARACTER
  ( p-obj-type as character, p-obj-code as integer, p-pl-code as integer ) :
  /*------------------------------------------------------------------------------
    Purpose:
      Notes:
  ------------------------------------------------------------------------------*/
  define buffer buf_place for ub.place.
  find first buf_place no-lock where
    buf_place.obj-type = p-obj-type
    AND  buf_place.obj-code = p-obj-code
    AND  buf_place.pl-code = p-pl-code no-error.
  if not available buf_place then 
  do:
    return "!!! Неизвестное складское место!!!".
  end.

  RETURN buf_place.pl-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-subject Dialog-Frame 
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-plc-hist-code p-subject
  RETURN {&hn-plc-hist-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

