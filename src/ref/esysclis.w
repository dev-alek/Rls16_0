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
DEFINE BUFFER X_ext-system FOR ub.ext-system.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Коды объектов внешней системы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/31/07
Author: Bakhtadze Natalya
Creation date: 07/31/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
define input parameter p-esys-id as integer no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Коды объектов внешней системы".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/mrk-strf.i }
{ ref/extclass.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ gbl/fltopend.i defproc }


define variable g#report-num as integer no-undo .
define stream OutStr-html .

define variable i as integer no-undo.

define variable v-cli-obj-type as character no-undo.
define variable v-cli-obj-code as character no-undo.
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "esysclis".
define variable filter-label     as character NO-UNDO INIT "Коды объектов внешней системы".
define variable filter-point0     as character NO-UNDO INIT "esysclis".
define variable filter-label0     as character NO-UNDO INIT "Коды объектов внешней системы".
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.

define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */

define variable v-report-name as character no-undo.         /* Наименование отчёта */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-esys-cli

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-classif X_clients

/* Definitions for BROWSE br-esys-cli                                   */
&Scoped-define FIELDS-IN-QUERY-br-esys-cli mark-string(recid(X_ext-classif), v-rid-list) X_ext-classif.KEY#_one get-esys-name(X_ext-classif.KEY#_one) X_ext-classif.charkey_one X_ext-classif.charkey_three X_clients.obj-type X_clients.obj-code X_clients.obj-name   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-esys-cli
&Scoped-define SELF-NAME br-esys-cli
&Scoped-define QUERY-STRING-br-esys-cli FOR EACH X_ext-classif NO-LOCK, ~
       FIRST X_clients NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-esys-cli OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK, ~
       FIRST X_clients NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-esys-cli X_ext-classif X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-br-esys-cli X_ext-classif
&Scoped-define SECOND-TABLE-IN-QUERY-br-esys-cli X_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-esys-cli}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-add b-del b-cli b-esys ~
b-look b-sch b-print B-Help fill-cli-vn fill-cli-th br-esys-cli mark-num 
&Scoped-Define DISPLAYED-OBJECTS fill-cli-vn fill-cli-th mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-type-code Dialog-Frame
FUNCTION get-cli-type-code RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-esys-name Dialog-Frame
FUNCTION get-esys-name RETURNS CHARACTER
  ( INPUT p-esys-id AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cli
     LABEL "Объект"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-esys
     LABEL "ВС"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-look 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

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

DEFINE VARIABLE fill-cli-th AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код объекта/клиента в TH" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fill-cli-vn AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код объекта/клиента во внешней системе" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-esys-cli FOR X_ext-classif, X_clients SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-esys-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-esys-cli Dialog-Frame _FREEFORM
  QUERY br-esys-cli NO-LOCK DISPLAY
      mark-string(recid(X_ext-classif), v-rid-list) COLUMN-LABEL "" FORMAT "X(1)"
X_ext-classif.KEY#_one  COLUMN-LABEL "Код!внешней!системы" FORMAT ">>>>>>>>9"
get-esys-name(X_ext-classif.KEY#_one) COLUMN-LABEL "Внешняя система" FORMAT "X(30)"
X_ext-classif.charkey_one  COLUMN-LABEL "Тип!объ!во!внеш.!сист." FORMAT "X(3)"
X_ext-classif.charkey_three  COLUMN-LABEL "Код!объ.!во!внеш.!сист." FORMAT "X(16)"
X_clients.obj-type COLUMN-LABEL "Тип!объекта" FORMAT "X(3)"
X_clients.obj-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>>>>>9"
X_clients.obj-name COLUMN-LABEL "Название объекта" FORMAT "X(60)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 116 BY 17.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 6
     b-add AT ROW 1 COL 31 WIDGET-ID 14
     b-del AT ROW 1 COL 41 WIDGET-ID 16
     b-cli AT ROW 1 COL 51 WIDGET-ID 2
     b-esys AT ROW 1 COL 61 WIDGET-ID 18
     b-look AT ROW 1 COL 71.13 WIDGET-ID 24
     b-sch AT ROW 1 COL 102.5 WIDGET-ID 12
     b-print AT ROW 1 COL 106 WIDGET-ID 10
     B-Help AT ROW 1 COL 113
     fill-cli-vn AT ROW 3 COL 40.5 COLON-ALIGNED WIDGET-ID 20
     fill-cli-th AT ROW 3 COL 93 COLON-ALIGNED WIDGET-ID 22
     br-esys-cli AT ROW 5.5 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(97.00) SKIP(21.41)
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
      TABLE: X_ext-system B "?" ? ub ext-system
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-esys-cli fill-cli-th Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-esys-cli
/* Query rebuild information for BROWSE br-esys-cli
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK, FIRST X_clients NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-esys-cli FOR X_ext-classif, X_clients SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-esys-cli */
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
ON CHOOSE OF b-cli IN FRAME Dialog-Frame /* Объект */
DO:
  IF NOT AVAILABLE X_clients THEN RETURN NO-APPLY.
  run ref/showcli.p ( INPUT parparentproc
                     ,INPUT X_clients.obj-type
                     ,INPUT X_clients.obj-code) NO-ERROR.
  APPLY "entry" TO br-esys-cli.
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


&Scoped-define SELF-NAME b-esys
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-esys Dialog-Frame
ON CHOOSE OF b-esys IN FRAME Dialog-Frame /* ВС */
DO:
define variable v-have-rights    as logical        no-undo.
define variable v-success    as logical        no-undo.
define variable v-esys-id   as integer        no-undo.
  IF NOT AVAILABLE X_ext-classif THEN RETURN NO-APPLY.
 ASSIGN
 v-esys-id = X_ext-classif.key#_one.
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_openxml-subsystem_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    yes
    v-have-rights
    }
    if v-have-rights = yes
    then do:
                  run bge/oxmlspci.w (
                input parparentproc
              , input {&lookup}
              , input-output v-esys-id
              , input 0 /*v-db-num*/
              , output v-success
          ) no-error.
 end.

  APPLY "entry" TO br-esys-cli.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-look
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-look Dialog-Frame
ON CHOOSE OF b-look IN FRAME Dialog-Frame /* Просмотр */
DO:
define VARIABLE v-ok as LOGICAL no-undo .
    if ( available X_ext-classif ) then do:
      
      find first ub.ext-system no-lock where
      ub.ext-system.esys-id = integer(X_ext-classif.KEY#_one) no-error .
      
run ref/esysclii.w (INPUT parparentproc
                   ,input {&lookup}
                   ,input substitute("Добавление кода объекта во внешней системе &1 для &2&3"
                              ,ub.ext-system.esys-name
                              ,X_clients.obj-type
                              ,X_clients.obj-code)
                   ,input INTEGER (ub.ext-system.esys-type)
                   ,input-output X_ext-classif.CharKey_One
                   ,input-output X_ext-classif.CharKey_Three
                   ,input-output X_ext-classif.CharKey_Two
                   ,output v-ok) no-error.
if not v-ok then return NO-APPLY.
end.
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
    loc#log = br-esys-cli:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-esys-cli:select-next-row ().
        apply "VALUE-CHANGED" to br-esys-cli in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-esys-cli in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
    
    
      run get-full-path-RepViewer(output v-full-path-RepView).   
  
run get-report-num in parParentProc(output g#report-num).

 run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).

run create-file(v-file-name-rep-htm). 
    
    
  run proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  
    run search-full-path-Report(input v-file-name-rep-htm).
run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm).
  
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




ON ENTER OF fill-cli-vn IN FRAME Dialog-Frame /* fill-in-code-system */
DO:
  /* new trigger */  
   find first ub.ext-classif no-lock  where 
                                        ub.ext-classif.charkey_three = fill-cli-vn:screen-value 
                                        and (if fill-cli-th:screen-value > "" then
                                             ub.ext-classif.Key#_One = integer(fill-cli-th:screen-value) else true)
                                        and  ub.ext-classif.classif-subject = {&table_clients} 
                                        and  ub.ext-classif.classif-name = {&extclass_clients_esys} no-error.
                                        
  if available ub.ext-classif then reposition br-esys-cli to rowid rowid(ub.ext-classif).
                           else message "Указанный код объекта/клиента во внешней системе отсутствует. ".
  apply "entry" to br-esys-cli in frame {&frame-name} .
  return no-apply.                    
  
END.

ON ENTER OF fill-cli-th IN FRAME Dialog-Frame /* fill-in-code-th */
DO:
  /* new trigger */ 
  
  find first ub.ext-classif no-lock   where integer(ENTRY(3, ub.ext-classif.uniq-key-rec, {&delim-key})) = integer(fill-cli-th:screen-value) 
                                         and (if fill-cli-vn:screen-value>"" then
                                              ub.ext-classif.CharKey_One = fill-cli-vn:screen-value else true )
                                         and ub.ext-classif.classif-subject = {&table_clients} 
                                         and ub.ext-classif.classif-name = {&extclass_clients_esys}  no-error.                                         
  if available ub.ext-classif then reposition br-esys-cli to rowid rowid(ub.ext-classif).
                           else message "Указанный код объекта/клиента в TH отсутствует. ".
  apply "entry" to br-esys-cli in frame {&frame-name} .  
  return no-apply.  
END.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-esys-cli
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
  v-rid-list = p-rid-list.
  if not (p-list-mode = {&all}
         or
         p-list-mode = "one") then  do:
    message
    substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
    view-as alert-box error .
    undo, return error .
  end.
  if p-list-mode = "one" then do:
    find first X_ext-system no-lock where
              X_ext-system.db-num = 0
          and X_ext-system.esys-id = p-esys-id no-error.
    if not available X_ext-system then do:
      message
      substitute("Неверное значение параметра p-esys-id=&1&2" +
                  "Нет внешней системы &1 с db-num = 0"
                , p-esys-id)
      view-as alert-box error .
      undo, return error .
    end.
  end.
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
  DISPLAY fill-cli-vn fill-cli-th mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-del b-cli b-esys b-look b-sch b-print 
         B-Help fill-cli-vn fill-cli-th br-esys-cli mark-num 
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
b-look
b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction)
b-esys
b-sch
fill-cli-vn
fill-cli-th
B-Help
br-esys-cli
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

&scop flt-open-open-query         OPEN QUERY br-esys-cli FOR EACH X_ext-classif

&scop flt-open-dyn_open-query     FOR EACH X_ext-classif

&scop flt-open-query-handle       QUERY br-esys-cli:handle

&scop flt-open-open-query-tail  , FIRST X_clients NO-LOCK WHERE ~
                                  X_clients.obj-type = ENTRY(2, X_eXt-classif.uniq-key-rec, {&delim-key}) AND ~
                                  X_clients.obj-code = integer(ENTRY(3, X_eXt-classif.uniq-key-rec, {&delim-key}))


&scop flt-open-query-was-opened   l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point         filter-point

&scop flt-open-set-filter-name    set-filter-name

&scop flt-open-indexed-reposition INDEXED-REPOSITION
filter-point = filter-point0 + p-list-mode .

case p-list-mode :
  when {&all} then do:
    title0 = "Объекты и клиенты во внешних системах".
    ASSIGN
    frame {&frame-name}:title = substitute("&1", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
    { gbl/fltopend.i
      &where-cond = " X_ext-classif.classif-subject = ~{&table_clients~} ~
                      and X_ext-classif.classif-name = ~{&extclass_clients_esys~} ~
                      AND X_ext-classif.db-num = 0"
      &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                      and X_ext-classif.classif-name = &1&3&1 ~
                      AND X_ext-classif.db-num = 0', ~{&double-quote~}, ~{&table_clients~}, ~{&extclass_clients_esys~})"

      &use-ind    = "  "
      &by         = "  " }
  end.
  when "one" then do:
    title0 = substitute("Объекты внешней системы &1", p-esys-id).
    ASSIGN
    frame {&frame-name}:title = substitute("&1", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
    { gbl/fltopend.i
      &where-cond = " X_ext-classif.classif-subject = ~{&table_clients~} ~
                      and X_ext-classif.classif-name = ~{&extclass_clients_esys~} ~
                      AND X_ext-classif.db-num = 0 ~
                      AND X_ext-classif.key#_one = p-esys-id"
      &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                      and X_ext-classif.classif-name = &1&3&1 ~
                      AND X_ext-classif.db-num = 0 ~
                      AND X_ext-classif.key#_one = &4', ~{&double-quote~}, ~{&table_clients~}, ~{&extclass_clients_esys~}, p-esys-id)"

      &use-ind    = "  "
      &by         = "  " }

  end.
end case.
APPLY "entry" TO br-esys-cli.
if available X_ext-classif then do:
    APPLY "VALUE-CHANGED":U to {&browse-name}.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame 
PROCEDURE proc-b-add :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-rid as recid no-undo .
DEFINE VARIABLE v-ok AS logical NO-UNDO.
define variable v-esys-id as integer no-undo .
DEFINE VARIABLE v-value-character2 AS character NO-UNDO.
define variable v-value-character as character no-undo .
define VARIABLE v-value-character3  as character  no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-esys-uniq-key-rec as character no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-system for ub.ext-system.
define buffer buf_ext-classif for ub.ext-classif .
if not available X_ext-system then do:
  message
  "Выберите внешнюю систему, для которой Вы хотите добавить запись объекта"
  view-as alert-box .
  run bge/oxmlexts.p (
        input parparentproc
      , input 2                         /* 2- Единичный выбор - 0. Множественный - 1*/
      , input substitute("esys-type > &1", {&openxml-type-ordinal}) /*p-where-string*/
      , input v-esys-uniq-key-rec        /* То, что уже выбрано (список) */
      , output v-rid-list          /* Список выбранных подсистем ( string( db-num ) + chr(6) + string( esys-id ) )*/
      , output v-ok               /* yes, если выбор был сделан. no - Если был отказ от выбора */
  ).
  if v-ok then do:
    run gen-row-keyr in this-procedure
      ( input v-rid-list
        ,input ?
        ,input "ub"
        ,input ?
        ,input no-lock
        ,output v-tbl-row
        ,output v-tbl-name
      ).
    find first buf_ext-system no-lock where
              rowid(buf_ext-system) = v-tbl-row.
  end.
  else do:
   undo, return error .
  end.
end.
else do:
    find first buf_ext-system no-lock where
              rowid(buf_ext-system) = rowid(X_ext-system).
end.
message
"Выберите объект, для которого Вы хотите добавить запись во внешней системе"
view-as alert-box .
run ref/cli-all.w (   input parparentproc
                  ,input "b-sel"
                  ,input {&all}
                  ,input {&all}
                  ,input {&current}
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input "":U
                  ,output v-rid-list) no-error.
if v-rid-list = '':U then return no-apply.
find first buf_clients where recid (buf_clients) = integer (v-rid-list) no-lock no-error.
/*if not (buf_clients.obj-type = {&shop}          */
/*       or                                       */
/*       buf_clients.obj-type = {&stock}) then do:*/
/*  message                                       */
/*  "Можно выбрать только МАГАЗИН или СКЛАД"      */
/*  view-as alert-box error .                     */
/*  undo, return error .                          */
/*end.                                            */
assign
v-value-character = buf_clients.obj-type
v-value-character2 = string(buf_clients.obj-code)
.
find first buf_ext-classif NO-LOCK where buf_ext-classif.classif-subject = {&table_clients}
                                     and buf_ext-classif.classif-name = {&extclass_clients_esys}
                                     and buf_ext-classif.CharKey_One = STRING (buf_ext-system.esys-id)
                                     and buf_ext-classif.CharKey_One = v-value-character
                                     and buf_ext-classif.CharKey_Three = v-value-character2 no-error .
if AVAILABLE (buf_ext-classif) then do:
  v-value-character3 = buf_ext-classif.CharKey_Two .
end.                                       
run ref/esysclii.w (INPUT parparentproc 
                   ,input {&add-def}
                   ,input substitute("Добавление кода объекта во внешней системе &1 для &2&3"
                              ,buf_ext-system.esys-name
                              ,buf_clients.obj-type
                              ,buf_clients.obj-code)
                   ,input INTEGER (buf_ext-system.esys-type)                               
                   ,input-output v-value-character
                   ,input-output v-value-character2
                   ,input-output v-value-character3
                   ,output v-ok) no-error.
if not v-ok then return error.
run gen-key-rec IN THIS-PROCEDURE ( input {&table_clients}
                               ,input (buffer buf_clients:handle)
                               ,output v-uniq-key-rec).
run ref/extclas1.p ( INPUT {&add-def}
                    ,INPUT NO /*p-silent*/
                    ,INPUT-OUTPUT v-rid
                    ,INPUT {&table_clients} /*p-classif-subject*/
                    ,INPUT {&extclass_clients_esys} /*p-classif-name*/
                    ,input 0 /*p-db-num*/
                    ,input buf_ext-system.esys-id  /*p-key#_one*/
                    ,input 0 /*p-Key#_Two*/
                    ,input 0 /*p-key#_Three*/
                    ,input v-value-character  /*p-CharKey_One */
                    ,input v-value-character3 /*p-CharKey_two */
                    ,input v-value-character2 /*p-CharKey_three */
                    ,input 0 /*p-nonunique */
                    ,input v-uniq-key-rec ) no-error.
if error-status:error then do:
 /* message error-status:get-message(1) view-as alert-box .*/
  undo, return error .
end.
if v-rid <> ? then do:
  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition br-esys-cli to recid v-rid no-error .
  apply "entry" to br-esys-cli in frame {&frame-name} .
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
"Вы действительно хотите удалить эту запись?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN ERROR.
run ref/extclas3.p ( INPUT NO /*p-silent*/
                    ,INPUT v-rec) NO-ERROR.
if not error-status:error then do:
  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition br-esys-cli to row 1 no-error .
  apply "entry" to br-esys-cli in frame {&frame-name} .
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
DEFINE VARIABLE v-esys-name AS CHARACTER NO-UNDO.


output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 12px; ' + chr(125) skip
        '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
        '      htm' skip
        '      .rotate ' + chr(123) skip
        '        -webkit-transform: rotate(-90deg);' skip
        '        -moz-transform: rotate(-90deg);' skip
        '        -ms-transform: rotate(-90deg);' skip
        '        -o-transform: rotate(-90deg);' skip
        '        transform: rotate(-90deg);' skip


        '        -webkit-transform-origin: 50% 50%;' skip
        '        -moz-transform-origin: 50% 50%;' skip
        '        -ms-transform-origin: 50% 50%;' skip
        '        -o-transform-origin: 50% 50%;' skip
        '        transform-origin: 50% 50%;' skip


        '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
        '          ' + chr(125) skip
        '            th' + ' ' + chr(123) skip
        '            border: 1px black solid;' skip
        '            word-wrap: break-word;' skip
        '          ' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        .
        
        
    put stream OutStr-html unformatted
        ' <body>' skip
        '   <table name="ВС" fit_to_page="true" orientation="portrait" outline_below="false">' skip
        '     <thead>' skip
        '       <tr class="set_columns">' skip
        '         <td style="width: 60px; border: none;"></td>' skip   
        '         <td style="width: 120px; border: none;"></td>' skip     
        '         <td style="width: 60px; border: none;"></td>' skip   
        '         <td style="width: 100px; border: none;"></td>' skip   
        '         <td style="width: 60px; border: none;"></td>' skip  
        '         <td style="width: 100px; border: none;"></td>' skip    
        '         <td style="width: 200px; border: none;"></td>' skip    
           '</tr>' skip
.

put stream OutStr-html unformatted
        '       <tr>' skip
        '         <td colspan="7" style="border: none;text-align: center; font-weight: bold">Объекты и Клиенты всех внешних систем</td>' skip
        '</tr>' skip
        '       <tr>' skip
        '         <td colspan="7" style="border: none;text-align: left; font-weight: bold">Дата печати: ' + STRING(DAY(TODAY), "99") + "." + STRING(MONTH(TODAY), "99") + "." + STRING(YEAR(TODAY), "9999") +  "   " + substring(string(time,"HH:MM:SS"),1,2) + ":" + substring(string(time,"HH:MM:SS"),4,2) +   '</td>' skip
        '</tr>' skip
        .


    put stream OutStr-html unformatted
        '     <tbody>' skip
        '       <tr>' skip
        '         <th  style="background-color:#ffffcc; text-align: center;">Код внешней системы </th>' skip
        '         <th  style="background-color:#ffffcc; text-align: center;">Внешняя система</th>' skip
        '         <th  style="background-color:#ffffcc; text-align: center;">Тип объекта во внешней системе</th>' skip
        '         <th  style="background-color:#ffffcc; text-align: center;">Код объекта во внешней системе</th>' skip
        '         <th  style="background-color:#ffffcc; text-align: center;">Тип Объекта</th>' skip
        '         <th  style="background-color:#ffffcc; text-align: center;">Код объекта</th>' skip
                '         <th  style="background-color:#ffffcc; text-align: center;">Название объекта</th>' skip
        
        '</tr>'
        .
    output stream OutStr-html close.
        
        
output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
        
        
for each  ub.ext-classif where     ub.ext-classif.classif-subject = {&table_clients} 
    and  ub.ext-classif.classif-name = {&extclass_clients_esys} :
        
        
    i = i + 1.
    v-cli-obj-type = ENTRY(2, ub.eXt-classif.uniq-key-rec, {&delim-key}) no-error.      
    v-cli-obj-code =   ENTRY(3, ub.ext-classif.uniq-key-rec, {&delim-key}) no-error.
             
    find first clients where clients.obj-code =   integer(v-cli-obj-code) and  clients.obj-type =    v-cli-obj-type no-lock no-error.
                               
    put stream OutStr-html unformatted
        '       <tr >' skip
        '         <td style="display: yes; text-align: center; font-weight: bold">' +  string(ext-classif.KEY#_one) + '</td>' skip
        '         <td text_wrap="true" style="display: yes; text-align:  right; font-weight: bold">'  + get-esys-name(ext-classif.key#_one) + '</td>' skip
        '         <td style="display: yes; text-align:  right; font-weight: bold">'   + ext-classif.charKEY_one + '</td>' skip
        '         <td style="display: yes; text-align:  right; font-weight: bold">'   + ext-classif.charkey_three + '</td>' skip
        '         <td style="display: yes; text-align:  right; font-weight: bold">'   +  v-cli-obj-type + '</td>' skip
        '         <td style="display: yes; text-align:  right; font-weight: bold">'   + v-cli-obj-code + '</td>' skip
        '         <td text_wrap="true" style="display: yes; text-align:  right; font-weight: bold">'   + clients.obj-name + '</td>' skip
        '       </tr>' skip
        .                           
end.      

    put stream OutStr-html unformatted
        '       <tr >' skip
        '         <td colspan = "7" style="display: yes; text-align:  left; font-weight: bold">Количество записей : '   + string(i) + '</td>' skip
        '       </tr>' skip
  .


put stream OutStr-html unformatted
    '     </tbody>' skip
    '   </table>' skip
    '  </body>' skip
    ' </html>' skip
    . /* Точка для закрытия Put */
output stream OutStr-html close.                                 
                                        
                                        
                                        
i = 0.

END PROCEDURE.


 procedure define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
/* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + "Объекты_и_Клиенты_ВС" + ".html".

end procedure.


procedure create-file:              /* СоздЛюбогоФайлаНаДиске(input полный_путь_с_именем) */
/* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.


procedure Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
/* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

end procedure.

procedure get-full-path-RepViewer:  /* Получение полного пути к исполняемому файлу RV.exe (output Полный_путь_имя_файла_RV.exe) */
/* Получение полного пути к exe-файлу просмотровщика отчётов */
    define output parameter p-fill-path-RepView as character no-undo.

    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.



procedure search-full-path-Report:  /* Только проверка, есть файл отчёта HTML или нет(тогда вывод сбщ-ош) */
/* Поиск файла */
    define input parameter p-file-name as character no-undo.

    if search(p-file-name) = ? then
        do:
            message "Не найден файл отчёта: " p-file-name view-as alert-box error.
        end.
    else
        do:
            p-file-name = search(p-file-name).
        end.

end procedure.






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

run fltfield-add in this-procedure('key#_one', 'Код внешней системы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('key#_two', 'Код объекта во внешней системе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_one', 'Тип объекта во внешней системе', '',
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
      reposition br-esys-cli to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-esys-cli in frame {&frame-name} .
    APPLY "VALUE-CHANGED" to br-esys-cli.
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS CHARACTER ) :
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
DEFINE BUFFER buf_clients FOR ub.clients.
RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT p-uniq-key-rec
                                    ,input ?
                                    ,INPUT "ub"
                                    ,INPUT ? /*p-bh-handle*/
                                    ,INPUT NO-LOCK
                                    ,OUTPUT v-rowid
                                    ,OUTPUT v-tbl-name) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1)
    error-status :get-message(2)
  view-as alert-box error.
  undo, return error.
end.
IF v-rowid = ? THEN RETURN 'НЕИЗВЕСТНЫЙ КЛИЕНТ'.

FIND FIRST buf_clients NO-LOCK WHERE ROWID(buf_clients) = v-rowid.
RETURN buf_clients.obj-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-type-code Dialog-Frame
FUNCTION get-cli-type-code RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character ) :
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
DEFINE BUFFER buf_clients FOR ub.clients.

    RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT p-uniq-key-rec
                                        ,INPUT ?
                                        ,INPUT "ub"
                                        ,INPUT ? /*p-bh-handle*/
                                        ,INPUT NO-LOCK
                                        ,OUTPUT v-rowid
                                        ,OUTPUT v-tbl-name) NO-ERROR.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1)
        error-status :get-message(2)
      view-as alert-box error.
      undo, return error.
    end.

    IF v-rowid = ? THEN RETURN ''.

    FIND FIRST buf_clients NO-LOCK WHERE ROWID(buf_clients) = v-rowid.
    RETURN substitute("&1&2"
                      ,buf_clients.obj-type
                      ,buf_Clients.obj-code).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-esys-name Dialog-Frame
FUNCTION get-esys-name RETURNS CHARACTER
  ( INPUT p-esys-id AS INTEGER ) :
DEFINE BUFFER buf_ext-system FOR ub.ext-system.
FIND FIRST buf_ext-system NO-LOCK WHERE
          buf_Ext-system.db-num = 0
      AND buf_Ext-system.esys-id = p-esys-id NO-ERROR.
IF AVAILABLE buf_ext-system THEN DO:
   RETURN buf_ext-system.esys-name.
END.
RETURN "!!Неизвестная внешняя система".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
