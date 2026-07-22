&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_ext-classif FOR ub.ext-classif.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Коды соответствия контрагентов

Автор: Самков Сергей Васильевич
Дата создания: 14/05/12
Author: Samkov Sergey
Creation date: 14/05/12

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER  bttns       AS character NO-UNDO.
DEFINE INPUT PARAMETER  p-list-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER  p-dop-par    AS character NO-UNDO.
DEFINE input-output PARAMETER p-rid-list  AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Коды соответствия контрагентов".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/mrk-strf.i }
{ ref/extclass.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ gbl/fltopend.i defproc }
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "соответствие_контрагентов".
define variable filter-label     as character NO-UNDO INIT "Коды соответствия контрагентов".
define variable filter-point0    as character NO-UNDO INIT "соответствие_контрагентов".
define variable filter-label0    as character NO-UNDO INIT "Коды соответствия контрагентов".
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-host-code as integer no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-ext-contragent

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-classif X_clients

/* Definitions for BROWSE br-ext-contragent                                   */
&Scoped-define FIELDS-IN-QUERY-br-ext-contragent mark-string(recid(X_ext-classif), v-rid-list) X_ext-classif.CharKey_One X_ext-classif.KEY#_one X_clients.obj-name X_ext-classif.CharKey_two X_ext-classif.KEY#_two get-client-name(X_ext-classif.KEY#_two,X_ext-classif.CharKey_two) /*X_ext-classif.db-num*/
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ext-contragent
&Scoped-define SELF-NAME br-ext-contragent
&Scoped-define QUERY-STRING-br-ext-contragent FOR EACH X_ext-classif NO-LOCK, ~
       FIRST X_clients NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-ext-contragent OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK, ~
       FIRST X_clients NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-ext-contragent X_ext-classif X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-br-ext-contragent X_ext-classif
&Scoped-define SECOND-TABLE-IN-QUERY-br-ext-contragent X_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ext-contragent}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-add b-del b-cli ~
b-sch b-print B-Help br-ext-contragent mark-num fill-in-code-th fill-in-code-system
&Scoped-Define DISPLAYED-OBJECTS mark-num fill-in-code-th fill-in-code-system

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-client-name Dialog-Frame
FUNCTION get-client-name RETURNS CHARACTER
  ( INPUT p-obj-code AS integer, INPUT p-obj-type AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cli
     LABEL "Клиент"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-sconf
     LABEL "Фирма"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fill-in-code-system AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код контрагента в ВС" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO. 
     
DEFINE VARIABLE fill-in-code-th AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код клиента в ТН" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.  

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-ext-contragent FOR X_ext-classif, X_clients SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ext-contragent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ext-contragent Dialog-Frame _FREEFORM
  QUERY br-ext-contragent NO-LOCK DISPLAY
      mark-string(recid(X_ext-classif), v-rid-list) COLUMN-LABEL "" FORMAT "X(1)"
X_ext-classif.CharKey_One COLUMN-LABEL "Тип!клиента" FORMAT "X(3)"
X_ext-classif.KEY#_one  COLUMN-LABEL "Код!клиента" FORMAT ">>>>>>>>9"
X_clients.obj-name COLUMN-LABEL "Название клиента" FORMAT "X(30)"
X_ext-classif.CharKey_two COLUMN-LABEL "Тип!контрагента" FORMAT "X(3)"
X_ext-classif.KEY#_two COLUMN-LABEL "Код!контрагента" FORMAT ">>>>>>>>9"
get-client-name(X_ext-classif.KEY#_two,X_ext-classif.CharKey_two) COLUMN-LABEL "Название контрагента" FORMAT "X(30)"
/*X_ext-classif.db-num COLUMN-LABEL "Номер!БД" FORMAT "->>>>9"*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.3 BY 20.37 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 6
     b-add AT ROW 1 COL 31 WIDGET-ID 14
     b-del AT ROW 1 COL 41 WIDGET-ID 16
     b-cli AT ROW 1 COL 51 WIDGET-ID 2
     b-sch AT ROW 1 COL 86 WIDGET-ID 12
     b-print AT ROW 1 COL 89 WIDGET-ID 10
     B-Help AT ROW 1 COL 95
     br-ext-contragent AT ROW 4.00 COL 1.5 WIDGET-ID 100
     fill-in-code-th AT ROW 2.50 COL 20 COLON-ALIGNED WIDGET-ID 2
     fill-in-code-system AT ROW 2.50 COL 60 COLON-ALIGNED WIDGET-ID 2
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(79.30) SKIP(21.26)
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
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_ext-classif B "?" ? ub ext-classif
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-ext-contragent B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ext-contragent
/* Query rebuild information for BROWSE br-ext-contragent
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK, FIRST X_clients NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-ext-contragent FOR X_ext-classif, X_clients SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-ext-contragent */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli Dialog-Frame
ON CHOOSE OF b-cli IN FRAME Dialog-Frame /* Клиент */
DO:
  IF NOT AVAILABLE X_clients THEN RETURN NO-APPLY.
  run ref/showcli.p ( INPUT parparentproc
                     ,INPUT X_clients.obj-type
                     ,INPUT X_clients.obj-code) NO-ERROR.
  APPLY "entry" TO br-ext-contragent.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE X_ext-classif THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_ext-classif then do:
    { gbl/markstrn.i X_ext-classif v-rid-list }
    loc#log = br-ext-contragent:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-ext-contragent:select-next-row ().
        apply "VALUE-CHANGED" to br-ext-contragent in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-ext-contragent in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_ext-classif ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_ext-classif ) ) .
  end.

END.

ON ENTER OF fill-in-code-th IN FRAME Dialog-Frame /* fill-in-code-th */
DO:
  /* new trigger */ 
   find first X_ext-classif no-lock   where X_ext-classif.Key#_One=integer(fill-in-code-th:screen-value) 
                                         and (if fill-in-code-system:screen-value>"" then
                                              X_ext-classif.KEY#_two = integer(fill-in-code-system:screen-value) else true )
                                         and X_ext-classif.classif-subject = {&table_clients} 
                                         and X_ext-classif.classif-name = {&extclass_code_org_code_client} no-error.                                         
  if available X_ext-classif then reposition br-ext-contragent to rowid rowid(X_ext-classif).
                           else message "Указанный код клиента в TH отсутствует. ".
  apply "entry" to br-ext-contragent in frame {&frame-name} .  
  return no-apply.  
END.

ON ENTER OF fill-in-code-system IN FRAME Dialog-Frame /* fill-in-code-system */
DO:
  /* new trigger */  
   find first X_ext-classif no-lock  where 
                                        X_ext-classif.KEY#_two = integer(fill-in-code-system:screen-value) 
                                        and (if fill-in-code-th:screen-value > "" then
                                             X_ext-classif.Key#_One = integer(fill-in-code-th:screen-value) else true)
                                        and X_ext-classif.classif-subject = {&table_clients} 
                                        and X_ext-classif.classif-name = {&extclass_code_org_code_client} no-error.
                                        
  if available X_ext-classif then reposition br-ext-contragent to rowid rowid(X_ext-classif).
                           else message "Указанный код контрагента в ВС отсутствует. ".
  apply "entry" to br-ext-contragent in frame {&frame-name} .
  return no-apply.                  
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ext-contragent
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  case p-list-mode:
    when {&all} then do:
    end.
    otherwise do:
       message
       substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
       view-as alert-box error.
       undo, return error .
    end.
  end.
  v-rid-list = p-rid-list.

  RUN Myenable.
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-del b-cli b-sch b-print B-Help
         br-ext-contragent mark-num fill-in-code-th fill-in-code-system
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ENABLE
b-quit
b-cli
b-print
b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction)
b-sch
B-Help
br-ext-contragent
fill-in-code-th 
fill-in-code-system
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo .
define buffer buf_clients for ub.clients.

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
&scop flt-open-debug-file

&scop flt-open-open-query         OPEN QUERY br-ext-contragent FOR EACH X_ext-classif

&scop flt-open-dyn_open-query     FOR EACH X_ext-classif

&scop flt-open-query-handle      QUERY br-ext-contragent:handle

&scop flt-open-open-query-tail  , FIRST X_clients NO-LOCK WHERE ~
                                  X_clients.obj-type = ENTRY(2, X_eXt-classif.uniq-key-rec, {&delim-key}) AND ~
                                  X_clients.obj-code = integer(ENTRY(3, X_eXt-classif.uniq-key-rec, {&delim-key}))

&scop flt-open-dyn_open-query-tail  substitute(', FIRST X_clients NO-LOCK WHERE ~
                                  X_clients.obj-type = ENTRY(2, X_eXt-classif.uniq-key-rec, {&delim-key}) AND ~
                                  X_clients.obj-code = integer(ENTRY(3, X_eXt-classif.uniq-key-rec, {&delim-key}))')



&scop flt-open-query-was-opened   l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point         filter-point

&scop flt-open-set-filter-name    set-filter-name

&scop flt-open-indexed-reposition INDEXED-REPOSITION
filter-point = filter-point0 + p-list-mode .

case p-list-mode:
 when {&all} then do:
  title0 = "Коды соответствия контрагентов".
  ASSIGN
  frame {&frame-name}:title = substitute("&1", title0)
  filter-label = SUBSTITUTE("&1"
                            , frame {&frame-name}:title
                            )
  .
  { gbl/fltopend.i
          &where-cond = " X_ext-classif.classif-subject = ~{&table_clients~} ~
                          and X_ext-classif.classif-name = ~{&extclass_code_org_code_client~}"
          &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                          and X_ext-classif.classif-name = &1&3&1', {&double-quote}, ~{&table_clients~}, ~{&extclass_code_org_code_client~})"

          &use-ind    = "  "
          &by         = "  " }

 end.
end case.

APPLY "entry" TO br-ext-contragent.
if available X_ext-classif then do:
    APPLY "VALUE-CHANGED":U to {&browse-name}.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE VARIABLE v-obj-type AS CHARACTER NO-UNDO.
define variable v-obj-code as integer no-undo .
DEFINE VARIABLE v-ext-obj-type AS CHARACTER NO-UNDO.
define variable v-ext-obj-code as integer no-undo .
/*define variable v-db-num as integer  no-undo .*/
DEFINE VARIABLE v-ok AS logical NO-UNDO.
define variable v-uniq-key-rec as character no-undo .
define variable v-rid as recid no-undo .

define buffer buf_db for ub.db .
define buffer buf_clients for ub.clients.

run ref\cli-eadd.w( parparentproc
                  , output v-obj-type
                  , output v-obj-code
                  , output v-ext-obj-type
                  , output v-ext-obj-code
/*                  , output v-db-num*/
                  , output v-ok
                  ).
if v-ok then do:
  find first buf_clients no-lock
    where buf_clients.obj-type = v-obj-type
      and buf_clients.obj-code = v-obj-code
    no-error.
  if not avail buf_clients then do:
    message
      substitute( "Не возможно найти клиента &1 &2", v-obj-type, string( v-obj-code ) )
      view-as alert-box error .
    undo, return error .
  end.
/*  find first buf_db no-lock*/
/*    where buf_db.db-num = v-db-num*/
/*    no-error .*/
/*  if not avail buf_db then do:*/
/*    message*/
/*      substitute( "Не существует база &1", string( v-db-num ) )*/
/*      view-as alert-box error .*/
/*    undo, return error .*/
/*  end.*/

  run gen-key-rec IN THIS-PROCEDURE
    ( input {&table_clients}
     ,input (buffer buf_clients:handle)
     ,output v-uniq-key-rec ).

  run ref/extclas1.p ( INPUT {&add-def}
                      ,INPUT NO /*p-silent*/
                      ,INPUT-OUTPUT v-rid
                      ,INPUT {&table_clients} /*p-classif-subject*/
                      ,INPUT {&extclass_code_org_code_client} /*p-classif-name*/
                      ,input /*v-db-num*/ (-1) /*p-db-num*/
                      ,input v-obj-code /*p-key#_one*/
                      ,input v-ext-obj-code /*p-Key#_Two*/
                      ,input 0 /*p-key#_Three*/
                      ,input v-obj-type /*'':U*/ /*p-CharKey_One */
                      ,input v-ext-obj-type /*p-CharKey_two */
                      ,input "" /*p-CharKey_three */
                      ,input (if buf_clients.obj-type = {&cmp} then 1000000000 else 0) + buf_clients.obj-code /*p-nonunique */
                      ,input v-uniq-key-rec ) no-error.
  if error-status:error then do:
    undo, return error .
  end.
end.
if v-rid <> ? then do:
  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition br-ext-contragent to recid v-rid no-error .
  apply "entry" to br-ext-contragent in frame {&frame-name} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
IF NOT AVAILABLE X_ext-classif THEN UNDO, RETURN ERROR.
v-rec = recid(X_ext-classif).
MESSAGE
"Вы действительно хотитет удалить эту запись?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN ERROR.
run ref/extclas3.p ( INPUT NO /*p-silent*/
                    ,INPUT v-rec) NO-ERROR.
if not error-status:error then do:
  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition br-ext-contragent to row 1 no-error .
  apply "entry" to br-ext-contragent in frame {&frame-name} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
DEFINE VARIABLE date_string              as   character no-undo .
DEFINE VARIABLE Line                     as   character no-undo .
DEFINE VARIABLE for-time                 as   character no-undo .
DEFINE VARIABLE accum-count              as   integer   no-undo .
define variable v-rid                    as   recid no-undo .
DEFINE VARIABLE v-firm-name AS CHARACTER NO-UNDO.

DEFINE FRAME list1
X_ext-classif.CharKey_One COLUMN-LABEL "Тип!клиента" FORMAT "X(3)"
X_ext-classif.KEY#_one  COLUMN-LABEL "Код!клиента" FORMAT ">>>>9"
X_clients.obj-name COLUMN-LABEL "Название клиента" FORMAT "X(45)"
X_ext-classif.CharKey_two COLUMN-LABEL "Тип!контрагента" FORMAT "X(3)"
X_ext-classif.KEY#_two COLUMN-LABEL "Код!контрагента" FORMAT ">>>>>>9"
v-firm-name COLUMN-LABEL "Название контрагента" FORMAT "X(45)"
/*X_ext-classif.db-num COLUMN-LABEL "Номер!БД" FORMAT "->>>>9"*/
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 75 PAGE-NUMBER(PrnLibStream) AT 85 FORMAT ">>9" SKIP
Line format "X(131)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 131).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input  {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(131)" SKIP(1) .
FORM HEADER
Line format "X(131)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
v-rid = recid(X_ext-classif).
FORM with FRAME List1.
run waitfram-show in this-procedure ( input "Ждите...").
DO WHILE available X_ext-classif :
   GET prev br-ext-contragent.
END.
GET next br-ext-contragent.
DO WHILE available X_ext-classif :
  v-firm-name = get-client-name(X_ext-classif.key#_two,X_ext-classif.CharKey_two).
  Display STREAM PrnLibStream
  X_ext-classif.CharKey_One
  X_ext-classif.KEY#_one
  X_clients.obj-name
  X_ext-classif.CharKey_two
  X_ext-classif.KEY#_two
  v-firm-name
/*  X_ext-classif.db-num COLUMN-LABEL "Номер!БД" FORMAT "->>>>9"*/
  with FRAME List1.
  DOWN STREAM PrnLibStream
  1
  with FRAME List1.
  assign
  accum-count = accum-count + 1
  .
  GET next br-ext-contragent.
END.
UNDERLINE  STREAM PrnLibStream
X_ext-classif.CharKey_One
X_ext-classif.KEY#_one
X_clients.obj-name
X_ext-classif.CharKey_two
X_ext-classif.KEY#_two
v-firm-name
/*X_ext-classif.db-num*/
with FRAME List1.
DISPLAY STREAM PrnLibStream
accum-count @ X_ext-classif.key#_one
with frame List1.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME List1.
output  STREAM PrnLibStream CLOSE.
reposition br-ext-contragent to recid v-rid no-error .
apply "ENTRY" to br-ext-contragent in frame {&frame-name} .
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_ext-classif then recid(X_ext-classif) else ?)
.
assign
tbl = {&table_ext-classif}
join-tbl = 'X_ext-classif'
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('key#_one', 'Код Фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + {&delim-par} + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-ext-contragent to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-ext-contragent in frame {&frame-name} .
    APPLY "VALUE-CHANGED" to br-ext-contragent.
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-client-name Dialog-Frame
FUNCTION get-client-name RETURNS CHARACTER
  ( INPUT p-obj-code AS integer, INPUT p-obj-type AS character )  :
  define variable v-client-name as character no-undo .
  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        v-client-name = (if buf_clients.stts = 0
                       then buf_clients.obj-name
                       else (substring (buf_clients.obj-name, 1, 20)
                            + fill (" " , 20 - length (substring (buf_clients.obj-name, 1, 20)))
                            + {&deleted-stat_}
                            )
                      )
      .
    end.
  end.
  return v-client-name .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME