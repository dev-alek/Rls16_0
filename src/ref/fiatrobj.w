&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Плановые цифры по объектам для фин.блока

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 08/09/04 12:00

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Плановые цифры по объектам для фин.блока ".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ gbl/thbjattr.i }
{ gbl/waitfram.i }
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc AS WIDGET-HANDLE  no-undo .
define input parameter  parhost-code like ub.clients.obj-code no-undo.

define variable  pardefobj-type     like ub.clients.obj-type no-undo.
define variable  pardefobj-code     like ub.clients.obj-code no-undo.
define variable  parobj-type        like ub.clients.obj-type no-undo.
define variable  parobj-code        like ub.clients.obj-code no-undo.
/* Local Variable Definitions ---                                       */

define temp-table tt-shst no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
field obj-name like ub.clients.obj-name
FIELD Ostatok-start AS DECIMAL
FIELD plan-pri      AS DECIMAL
FIELD proch         AS DECIMAL
FIELD proch-ras     AS DECIMAL
field upd           as log
field upd1          as log
field upd2          as log
field upd3          as log
field upd4          as log

index pi is unique primary obj-type obj-code.
define buffer bf_tt-shst for tt-shst.

define variable g-log as logical no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-shst

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-shst

/* Definitions for BROWSE b-shst                                        */
&Scoped-define FIELDS-IN-QUERY-b-shst tt-shst.obj-code tt-shst.obj-type tt-shst.obj-name tt-shst.Ostatok-start tt-shst.plan-pri tt-shst.proch tt-shst.proch-ras
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-shst tt-shst.Ostatok-start tt-shst.plan-pri tt-shst.proch tt-shst.proch-ras
&Scoped-define ENABLED-TABLES-IN-QUERY-b-shst tt-shst
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-b-shst tt-shst
&Scoped-define SELF-NAME b-shst
&Scoped-define QUERY-STRING-b-shst FOR EACH tt-shst indexed-reposition
&Scoped-define OPEN-QUERY-b-shst OPEN QUERY {&SELF-NAME} FOR EACH tt-shst indexed-reposition.
&Scoped-define TABLES-IN-QUERY-b-shst tt-shst
&Scoped-define FIRST-TABLE-IN-QUERY-b-shst tt-shst


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-shst}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help b-shst

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-shst FOR
      tt-shst SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-shst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-shst Dialog-Frame _FREEFORM
  QUERY b-shst DISPLAY
      tt-shst.obj-code        format ">>>>9"
tt-shst.obj-type
tt-shst.obj-name        column-label "Наименование" format "x(30)"
tt-shst.Ostatok-start   column-label "Остаток на !начало дня" format ">>>>>>>>9.99"
tt-shst.plan-pri        column-label "План прихода" format ">>>>>>>>9.99"
tt-shst.proch           column-label "Прочие доходы" format ">>>>>>>>9.99"
tt-shst.proch-ras       column-label "Прочие расходы" format "->>>>>>>>9.99"
enable
tt-shst.Ostatok-start
tt-shst.plan-pri
tt-shst.proch
tt-shst.proch-ras
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.6 BY 12.97.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.6
     b-cancel AT ROW 1 COL 12.1
     b-help AT ROW 1 COL 88
     b-shst AT ROW 2.3 COL 1.4
     SPACE(0.24) SKIP(0.18)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Плановые цифры по объектам"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB b-shst b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-shst
/* Query rebuild information for BROWSE b-shst
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-shst indexed-reposition.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-shst */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Плановые цифры по объектам */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
if can-find (first tt-shst  where tt-shst.upd      = true ) then do:
  MESSAGE "Данные были изменены!" "Выйти без сохранения ?"  view-as alert-box question
  buttons yes-no title "Вопрос"
   update v-ok as logical.
     if v-ok = false  then do:
        return no-apply.
     end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i  b-exit }
  message "Сохраняем изменение и выходим ? " view-as alert-box question
   buttons yes-no title "Вопрос"
   update v-ok as logical.
     if v-ok = false  then do:
     return no-apply.
     end.
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-shst
&Scoped-define SELF-NAME b-shst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-shst Dialog-Frame
ON ROW-LEAVE OF b-shst IN FRAME Dialog-Frame
DO:
  IF dec( tt-shst.proch-ras:screen-value IN BROWSE {&browse-name}) <> tt-shst.proch-ras
  or dec( tt-shst.proch:screen-value IN BROWSE {&browse-name}) <> tt-shst.proch
  or dec( tt-shst.ostatok-start:screen-value IN BROWSE {&browse-name}) <> tt-shst.Ostatok-start
  or dec( tt-shst.plan-pri:screen-value IN BROWSE {&browse-name}) <> tt-shst.plan-pri
  THEN
    assign
      tt-shst.upd      = true
    .

  if dec( tt-shst.ostatok-start:screen-value IN BROWSE {&browse-name}) <> tt-shst.Ostatok-start
  THEN
    assign
      tt-shst.upd1      = true
    .
  if dec( tt-shst.plan-pri:screen-value IN BROWSE {&browse-name}) <> tt-shst.plan-pri
  THEN
    assign
      tt-shst.upd2      = true
    .
  if dec( tt-shst.proch:screen-value IN BROWSE {&browse-name}) <> tt-shst.proch
  THEN
    assign
      tt-shst.upd3      = true
    .
  IF dec( tt-shst.proch-ras:screen-value IN BROWSE {&browse-name}) <> tt-shst.proch-ras
  THEN
    assign
      tt-shst.upd4      = true
    .


END.

ON LEAVE OF tt-shst.proch-ras in browse {&browse-name}
DO:
define variable sss  as character no-undo .
  IF dec(tt-shst.proch-ras:screen-value IN BROWSE {&browse-name}) > 0  THEN do:
        MESSAGE "Расход дожен быть < 0 !!! "  .
        sss =  string(dec(tt-shst.proch-ras:screen-value IN BROWSE {&browse-name}) * ( - 1 )) .
        tt-shst.proch-ras:screen-value IN BROWSE {&browse-name} = sss.
        RETURN NO-APPLY.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* **************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  DO TRANSACTION:
    RUN lock-fin-plan IN THIS-PROCEDURE.
  END.
  run load-tt in this-procedure.
  run enable_UI in this-procedure.
  find first bf_tt-shst where bf_tt-shst.obj-type = pardefobj-type and
                              bf_tt-shst.obj-code = pardefobj-code no-error.
  if available bf_tt-shst then do:
    reposition b-shst to recid recid(bf_tt-shst) no-error .
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure.

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
  ENABLE b-exit b-cancel b-help b-shst
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fin-plan-attr-proc Dialog-Frame
PROCEDURE fin-plan-attr-proc :
do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable v-type as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .

run adm/shattri.p (
              input "init":U
            , input tt-shst.obj-type
            , input tt-shst.obj-code
            , input {&attr-fin-plan}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT table-handle v-tth
            ) no-error .
if error-status:error
then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr WHERE
        thbjattr_thbj-ATTR.obj-type = tt-shst.obj-type
    AND thbjattr_thbj-ATTR.obj-code = tt-shst.obj-code:
  CASE thbjattr_thbj-attr.prop-code :
    WHEN {&attr-fin-plan_fin-ostatok-start} THEN DO:
      tt-shst.ostatok-start = thbjattr_thbj-attr.property-value-decimal.
    END.
    WHEN {&attr-fin-plan_fin-plan-pri}  THEN DO:
      tt-shst.plan-pri = thbjattr_thbj-attr.property-value-decimal.
    END.
    WHEN {&attr-fin-plan_fin-proch}  THEN DO:
      tt-shst.proch = thbjattr_thbj-attr.property-value-decimal.
    END.
    WHEN {&attr-fin-plan_fin-proch-ras}  THEN DO:
      tt-shst.proch-ras = thbjattr_thbj-attr.property-value-decimal.
    END.
  END CASE.

END.
end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-tt Dialog-Frame
PROCEDURE load-tt :
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_shop FOR ub.shop.
DEFINE BUFFER buf_store FOR ub.store.
/**/
run waitfram-show in this-procedure ( "Ждите..." ).
if parhost-code = ? then do:
 for each buf_shop no-lock,
   first buf_clients where buf_clients.obj-type = {&shop}       and
                       buf_clients.obj-code = buf_shop.obj-code and
                       buf_clients.stts     = 0
                       no-lock on error undo, return error return-value :
   create tt-shst.
   assign
     tt-shst.upd      = false
     tt-shst.obj-type = {&shop}
     tt-shst.obj-code =  buf_shop.obj-code
     tt-shst.obj-name =  buf_clients.obj-name.

     run fin-plan-attr-proc in this-procedure
        ( tt-shst.obj-type ,
          tt-shst.obj-code ).
 end.
 for each buf_store no-lock,
   first buf_clients where buf_clients.obj-type = {&stock}       and
                       buf_clients.obj-code = buf_store.obj-code and
                       buf_clients.stts     = 0              no-lock on error undo, return error return-value :
   create tt-shst.
   assign
     tt-shst.upd      = false
     tt-shst.obj-type = {&stock}
     tt-shst.obj-code =  buf_store.obj-code
     tt-shst.obj-name = buf_clients.obj-name.
     run fin-plan-attr-proc in this-procedure
        ( tt-shst.obj-type ,
          tt-shst.obj-code ).

 end.
end.
else do:
 for each buf_shop where buf_shop.host-code = parhost-code no-lock,
   first buf_clients where buf_clients.obj-type = {&shop}       and
                       buf_clients.obj-code = buf_shop.obj-code and
                       buf_clients.stts     = 0             no-lock on error undo, return error return-value :
   create tt-shst.
   assign
     tt-shst.upd      = false
     tt-shst.obj-type = {&shop}
     tt-shst.obj-code =  buf_shop.obj-code
     tt-shst.obj-name = buf_clients.obj-name.
     run fin-plan-attr-proc in this-procedure
        ( tt-shst.obj-type ,
          tt-shst.obj-code ).

 end.
 for each buf_store where buf_store.host-code = parhost-code no-lock,
   first buf_clients where buf_clients.obj-type = {&stock}       and
                       buf_clients.obj-code = buf_store.obj-code and
                       buf_clients.stts     = 0              no-lock on error undo, return error return-value :
   create tt-shst.
   assign
     tt-shst.upd      = false
     tt-shst.obj-type = {&stock}
     tt-shst.obj-code = buf_store.obj-code
     tt-shst.obj-name = buf_clients.obj-name.
     run fin-plan-attr-proc in this-procedure
        ( tt-shst.obj-type ,
          tt-shst.obj-code ).
 end.
end.
run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lock-fin-plan Dialog-Frame
PROCEDURE lock-fin-plan :
DEFINE BUFFER buf_CLIENTS FOR UB.CLIENTS.
define buffer buf_thbj-attr for ub.thbj-attr.
IF pARhost-code = ? THEN DO:
  FOR EACH buf_thbj-attr EXCLUSIVE-LOCK WHERE
          buf_thbj-attr.upper-prop-code = {&attr-fin-plan}
  ON error undo, RETURN error:
    find current locked_thbj-attr exclusive-lock .
    release locked_thbj-attr .
  END.
END.
ELSE DO:
  FOR EACH buf_thbj-attr exclusive-lock WHERE
            buf_thbj-attr.upper-prop-code = {&attr-fin-plan},
      FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = locked_thbj-attr.obj-type
        AND buf_clients.obj-code = locked_thbj-attr.obj-code
        AND buf_clients.host-code = pARhost-code
  ON error undo, RETURN error:
    find current locked_thbj-attr exclusive-lock .
    release locked_thbj-attr .
  END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
run waitfram-show in this-procedure ( INPUT "Ждите. Идет сохранение данных ").

  for each tt-shst  where tt-shst.upd      = true
   :
   if tt-shst.upd1      = true THEN DO:
     find FIRST thbjattr_thbj-attr WHERE
                thbjattr_thbj-attr.obj-type = tt-shst.obj-type
         AND    thbjattr_thbj-attr.obj-code = tt-shst.obj-code
         AND    thbjattr_thbj-attr.upper-prop-code = {&attr-fin-plan}
         AND    thbjattr_thbj-attr.prop-code = {&ATTR-fin-plan_fin-ostatok-start}.
     ASSIGN
     thbjattr_thbj-attr.property-value-decimal = tt-shst.ostatok-start.
   END.
   if tt-shst.upd2      = true THEN DO:
       find FIRST thbjattr_thbj-attr WHERE
                  thbjattr_thbj-attr.obj-type = tt-shst.obj-type
           AND    thbjattr_thbj-attr.obj-code = tt-shst.obj-code
           AND    thbjattr_thbj-attr.upper-prop-code = {&attr-fin-plan}
           AND    thbjattr_thbj-attr.prop-code = {&ATTR-fin-plan_fin-plan-pri}.
       ASSIGN
       thbjattr_thbj-attr.property-value-decimal = tt-shst.plan-pri.

   END.
   if tt-shst.upd3      = true THEN DO:
       find FIRST thbjattr_thbj-attr WHERE
                  thbjattr_thbj-attr.obj-type = tt-shst.obj-type
           AND    thbjattr_thbj-attr.obj-code = tt-shst.obj-code
           AND    thbjattr_thbj-attr.upper-prop-code = {&attr-fin-plan}
           AND    thbjattr_thbj-attr.prop-code = {&ATTR-fin-plan_fin-proch}.
       ASSIGN
       thbjattr_thbj-attr.property-value-decimal = tt-shst.proch.

   END.
   if tt-shst.upd4      = true THEN DO:
       find FIRST thbjattr_thbj-attr WHERE
                  thbjattr_thbj-attr.obj-type = tt-shst.obj-type
           AND    thbjattr_thbj-attr.obj-code = tt-shst.obj-code
           AND    thbjattr_thbj-attr.upper-prop-code = {&attr-fin-plan}
           AND    thbjattr_thbj-attr.prop-code = {&ATTR-fin-plan_fin-proch-ras}.
       ASSIGN
       thbjattr_thbj-attr.property-value-decimal = tt-shst.proch-ras.

   END.
   RUN thbjattr_set-section IN this-procedure ( INPUT tt-shst.obj-type
                                               ,INPUT tt-shst.obj-code
                                               ,INPUT {&attr-fin-plan}
                                               ,INPUT TABLE-HANDLE v-tth ).
end. /* for each */
run waitfram-hide in this-procedure.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME