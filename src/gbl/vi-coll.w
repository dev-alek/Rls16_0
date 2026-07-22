&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройки просмотра брауза

Автор: Чернова Светлана Александровна
Дата создания: 11/08/05
Author: Svetlana Chernova
Creation date: 11/08/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  as handle no-undo .
define input  parameter p-proc-handle  as handle no-undo .
define input  parameter p-call-point   as character no-undo .  /* см    u s r - f l t . i  */
define input  parameter p-other        as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки просмотра брауза".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }


/* Local Variable Definitions ---                                       */
DEFINE TEMP-TABLE x_usr-flt NO-UNDO LIKE ubflt.usr-flt
field id as integer
field field-name as char
field field-vis  as log
field field-size as dec
field field-num  as int
index pi field-num.


 define variable g-log as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x_usr-flt

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 /* x_usr-flt.id */ x_usr-flt.field-name x_usr-flt.field-vis x_usr-flt.field-size x_usr-flt.field-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 x_usr-flt.field-size
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 x_usr-flt
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 x_usr-flt
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH x_usr-flt NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH x_usr-flt NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 x_usr-flt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 x_usr-flt


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel B-Help BROWSE-2 B-up B-down ~
B-vis B-no-vis B-set-def

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-down
     LABEL "Вниз"
     SIZE 13.63 BY 1 TOOLTIP "Переместить запись ниже"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 13.63 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-no-vis
     LABEL "Скрыть"
     SIZE 13.63 BY 1 TOOLTIP "Колонка не видна"
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-set-def
     LABEL "По умолчанию"
     SIZE 13.63 BY 1 TOOLTIP "Установить все значения по умолчанию".

DEFINE BUTTON B-up
     LABEL "Вверх"
     SIZE 13.63 BY 1 TOOLTIP "Переместить запись выше"
     BGCOLOR 8 .

DEFINE BUTTON B-vis
     LABEL "Показать"
     SIZE 13.63 BY 1 TOOLTIP "Колонка видна"
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      x_usr-flt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 NO-LOCK DISPLAY
      /*  x_usr-flt.id  */
      x_usr-flt.field-name column-label "Название колонки" format "x(40)"
      x_usr-flt.field-vis  column-label "Наличие" format "да/нет"
      x_usr-flt.field-size column-label "Ширина"   format ">>>>>>9.99"
      x_usr-flt.field-num  column-label "N/N"
      enable x_usr-flt.field-size
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 65 BY 20.54 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 13
     B-Help AT ROW 1 COL 66.63
     BROWSE-2 AT ROW 3 COL 1 WIDGET-ID 100
     B-up AT ROW 4 COL 67 WIDGET-ID 2
     B-down AT ROW 5.25 COL 67 WIDGET-ID 4
     B-vis AT ROW 6.5 COL 67 WIDGET-ID 6
     B-no-vis AT ROW 7.75 COL 67 WIDGET-ID 8
     B-set-def AT ROW 9 COL 67 WIDGET-ID 12
     SPACE(0.61) SKIP(13.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки колонок в таблице"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x_usr-flt NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки колонок в таблице */
DO:
  run save-proc in this-procedure  no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки колонок в таблице */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-down Dialog-Frame
ON CHOOSE OF B-down IN FRAME Dialog-Frame /* Вниз */
DO:
define buffer buf_next for x_usr-flt  .
define variable old-number as integer   no-undo .
define variable new-number as integer   no-undo .
define variable cur-number as integer   no-undo .
define variable v-recid as recid no-undo .
  if available x_usr-flt then do:
  v-recid = recid (x_usr-flt) .
  old-number = x_usr-flt.field-num .
  new-number = x_usr-flt.field-num + 1 .
  cur-number = {&BROWSE-NAME}:focused-row .

  find first buf_next where buf_next.field-num = new-number no-error .
    if available buf_next then do:
      buf_next.field-num  = old-number .
      x_usr-flt.field-num = new-number .
      {&OPEN-QUERY-BROWSE-2}
      {&BROWSE-NAME}:set-repositioned-row(cur-number + 1)  no-error .
      reposition {&browse-name} to recid v-recid no-error.

    end.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-no-vis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-no-vis Dialog-Frame
ON CHOOSE OF B-no-vis IN FRAME Dialog-Frame /* Скрыть */
DO:
  if available x_usr-flt then do:
      x_usr-flt.field-vis = false .
      g-log =  {&BROWSE-NAME}:refresh() .
      g-log = {&BROWSE-NAME}:select-next-row().

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-set-def
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-set-def Dialog-Frame
ON CHOOSE OF B-set-def IN FRAME Dialog-Frame /* По умолчанию */
DO:
  for each x_usr-flt:
       delete x_usr-flt.
  end.
  run init-proc in this-procedure
  ( input "set_def" ) .
  {&OPEN-QUERY-BROWSE-2}
  APPLY 'ENTRY':U TO {&BROWSE-NAME}.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-up Dialog-Frame
ON CHOOSE OF B-up IN FRAME Dialog-Frame /* Вверх */
DO:
define buffer buf_prev for x_usr-flt  .
define variable old-number as integer   no-undo .
define variable new-number as integer   no-undo .
define variable cur-number as integer   no-undo .
define variable v-recid as recid no-undo .
  if available x_usr-flt then do:
  v-recid = recid (x_usr-flt) .
  old-number = x_usr-flt.field-num .
  new-number = x_usr-flt.field-num - 1 .
  cur-number = {&BROWSE-NAME}:focused-row.

  find first buf_prev where buf_prev.field-num = new-number no-error .
    if available buf_prev then do:
      buf_prev.field-num  = old-number .
      x_usr-flt.field-num = new-number .
      {&OPEN-QUERY-BROWSE-2}
      {&BROWSE-NAME}:set-repositioned-row(cur-number - 1)  no-error .
      reposition {&browse-name} to recid v-recid no-error.

    end.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-vis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-vis Dialog-Frame
ON CHOOSE OF B-vis IN FRAME Dialog-Frame /* Показать */
DO:
  if available x_usr-flt then do:
      x_usr-flt.field-vis = true  .
      g-log =  {&BROWSE-NAME}:refresh().
      g-log = {&BROWSE-NAME}:select-next-row().
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  if available x_usr-flt then do:
  if x_usr-flt.field-vis = no then
      x_usr-flt.field-name:fgcolor in browse {&browse-name}  = 7.
      else x_usr-flt.field-name :fgcolor in browse {&browse-name} = ?.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-2 IN FRAME Dialog-Frame
DO:

END.

ON return OF x_usr-flt.field-size in browse BROWSE-2
DO:

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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init-proc in this-procedure
  ( input "init" ) .
  run enable_ui in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

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
  ENABLE B-OK B-Cancel B-Help BROWSE-2 B-up B-down B-vis B-no-vis B-set-def
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii as integer   no-undo .
define variable v-vis  as character no-undo .
define variable v-size as character no-undo .
define variable v-num as character no-undo .

define input parameter v-set-def as character .

if  v-set-def <> "set_def" then do:
run uf-get in this-procedure (
     input  p-call-point
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
    ) no-error  .
  end.
  if v-set-def = "set_def" OR v-uf-List_ = "" or v-uf-List_ = ? or error-status :error then do:
        case p-call-point :
          /* Заказы по типам */
          when {&uf-cli-zakz} + {&f-p} then do:
            assign
              v-num  =  {&cli-zakzfp-p-ord}
              v-size =  {&cli-zakzfp-p-siz}
              v-vis  =  {&cli-zakzfp-p-vis}
              .
          end.
          when {&uf-cli-zakz} + {&o-p} then do:
            assign
              v-num  = {&cli-zakzOp-p-ord}
              v-size = {&cli-zakzOp-p-siz}
              v-vis  = {&bef-cli-zakzOp-p-vis}
              .
          end.
          when {&uf-cli-zakz} + {&o-f} then do:
            assign
              v-num  =  {&cli-zakzOF-p-ord}
              v-size =  {&cli-zakzOF-p-siz}
              v-vis  =  {&cli-zakzOF-p-vis}
              .
          end.
          /* Список документов */
          when {&uf-all-docs}   then do:
            assign
              v-num  = {&all-docs-p-ord}
              v-size = {&all-docs-p-siz}
              v-vis  = {&bef-all-docs-p-vis}
              .
          end.
          when {&uf-contspec}   then do:
            assign
              v-num  = {&contspec-p-ord}
              v-size = {&contspec-p-siz}
              v-vis  = {&bef-contspec-p-vis}
              .
          end.
          when {&uf-contspec-gds}   then do:
            assign
              v-num  = {&contspec-g-ord}
              v-size = {&contspec-g-siz}
              v-vis  = {&bef-contspec-g-vis}
              .
          end.
        end case.
    end.
    else do:
      assign
        v-num   = entry(1, v-uf-List_, {&delim-par})
        v-size  = entry(2, v-uf-List_, {&delim-par})
        v-vis   = entry(3, v-uf-List_, {&delim-par})
        .
    end.
    
    repeat ii = 1 to num-entries(p-other,"#") :
        create x_usr-flt .
        assign
        x_usr-flt.id         =  ii   .
        x_usr-flt.field-name = entry(ii,p-other,"#") no-error.
        x_usr-flt.field-vis  = logical(entry(ii,v-vis )) no-error.
        x_usr-flt.field-size = decimal(entry(ii,v-size)) no-error.
        x_usr-flt.field-num  = if lookup(string(ii),v-num,',') = 0 then ii else lookup(string(ii),v-num,',') no-error.
         .
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  ENABLE B-Cancel b-help B-OK
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  B-Cancel:label = "Выход" .
  hide b-ok in frame {&frame-name} .

  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-sp-ord  as character no-undo .
define variable v-sp-size as character no-undo .
define variable v-sp-vis  as character no-undo .

v-sp-ord  = "" .
v-sp-size = "" .
v-sp-vis  = "" .

for each   x_usr-flt break by x_usr-flt.id :
  v-sp-size = v-sp-size + string ( x_usr-flt.field-size )   + ","  .
  v-sp-vis  = v-sp-vis  + string ( x_usr-flt.field-vis  )   + ","  .
end.

for each   x_usr-flt break by x_usr-flt.field-num :
  v-sp-ord  = v-sp-ord  + string ( x_usr-flt.id  )   + ","  .
end.

v-sp-ord  = trim(v-sp-ord , "," ) .
v-sp-size = trim(v-sp-size, "," ) .
v-sp-vis  = trim(v-sp-vis , "," ) .

define variable v-list-new as character no-undo .

assign
  v-list-new  = v-sp-ord +  {&delim-par}
              + v-sp-size  +  {&delim-par}
              + v-sp-vis   +  {&delim-par}
              .
run uf-set in this-procedure(
     input p-call-point
    ,input v-cntxt-userid
    ,input v-list-new
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error   .

  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "123"
    view-as alert-box error
  .
  message 'Изменения вступят в силу при следующем входе в список !'
           /*p-call-point skip v-list-new */
           view-as alert-box information .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME