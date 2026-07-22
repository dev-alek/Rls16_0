&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_store FOR ub.store.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина гарантийный запас по АBC в днях

Автор: Чернова Светлана Александровна
Дата создания: 04/10/06
Author: Svetlana Chernova
Creation date: 04/10/06

(clients-attr) "abc-sale-day"

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */


define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.shop.obj-code no-undo.
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (clients-attr) abc-sale-day".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i  }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i DEF }
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-host-code LIKE ub.shop.host-code NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

define variable str-attr AS CHARACTER NO-UNDO .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help v-a v-b v-c v-d v-E v-F 
&Scoped-Define DISPLAYED-OBJECTS v-a v-b v-c v-d v-E v-F 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "&Помощь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-a AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "A" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-b AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "B" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-c AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "C" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-d AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "D" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-E AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "E" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-F AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "F" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 21
     v-a AT ROW 2.5 COL 10.5 COLON-ALIGNED
     v-b AT ROW 3.75 COL 10.5 COLON-ALIGNED
     v-c AT ROW 5 COL 10.5 COLON-ALIGNED
     v-d AT ROW 6.5 COL 10.5 COLON-ALIGNED
     v-E AT ROW 7.75 COL 10.5 COLON-ALIGNED
     v-F AT ROW 9 COL 10.5 COLON-ALIGNED
     SPACE(11.12) SKIP(1.87)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Гарантийный запас в днях для ABC"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_store B "?" ? ub store
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Гарантийный запас в днях для ABC */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Гарантийный запас в днях для ABC */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-a
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-a Dialog-Frame
ON LEAVE OF v-a IN FRAME Dialog-Frame /* A */
DO:
  ASSIGN v-a.
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
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&cmp}
  AND p-obj-type <> {&stock}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num AND v-cntxt-db-num <> 0 THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  end.
  if p-obj-type = {&cmp} then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
    v-host-code = p-obj-code.
  end.
  if p-obj-type = {&stock} then do:
    FIND FIRST X_store NO-LOCK WHERE X_store.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_store THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num AND v-cntxt-db-num <> 0 THEN DO:
        MESSAGE
        "Нельзя менять параметры склада в чужой БД" skip
        "склад принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-abc-sale-day}
        AND   locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) ФИРМЫ/МАГАЗИНА/СКЛАДА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-abc-sale-day}
    AND   locked_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.


  end.
  run FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  run Myenable in this-procedure .
   wait-for go of frame {&frame-name}.
end.
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
  DISPLAY v-a v-b v-c v-d v-E v-F 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help v-a v-b v-c v-d v-E v-F 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Fill-widgets Dialog-Frame 
PROCEDURE Fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-abc-sale-day}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT TABLE-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_A} THEN DO:
    v-a = thbjattr_thbj-attr.property-value-integer.
    v-a:private-data IN FRAME {&FRAME-NAME} = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_B} THEN DO:
    v-b = thbjattr_thbj-attr.property-value-integer.
    v-b:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_C} THEN DO:
    v-c = thbjattr_thbj-attr.property-value-integer.
    v-c:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_D} THEN DO:
    v-D = thbjattr_thbj-attr.property-value-integer.
    v-d:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_E} THEN DO:
    v-E = thbjattr_thbj-attr.property-value-integer.
    v-e:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-abc-sale-day_F} THEN DO:
    v-F = thbjattr_thbj-attr.property-value-integer.
    v-f:private-data = "recid=" + string(recid(thbjattr_thbj-attr)).
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DISPLAY
v-a
v-b
v-c
v-d
v-E
v-F
with frame {&frame-name} .
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
v-a WHEN p-mode = {&UPDATE}
v-b WHEN p-mode = {&UPDATE}
v-c WHEN p-mode = {&UPDATE}
v-d WHEN p-mode = {&UPDATE}
v-E WHEN p-mode = {&UPDATE}
v-F WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  hide
  b-exit in frame {&frame-name}.
  b-quit:label = "&Выход".
  b-quit:column = 1.
  display
  b-quit with frame {&frame-name}.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-sale-add as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .

IF p-mode = {&LOOKUP} THEN RETURN ERROR.

ASSIGN
FRAME {&FRAME-NAME}
v-a v-b v-c v-d v-E v-F .
assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    thbjattr_thbj-attr.obj-type = p-obj-type.
    thbjattr_thbj-attr.obj-code = p-obj-code.
  end.
  wh = wh:next-sibling.
end.

v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type         = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code         = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code        = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
/*проверим корректность*/
run adm/shattri.p (
  input "check":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-abc-sale-day}
  , INPUT '':U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-handle v-tth
  ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.

do TRANSACTION
on error undo, return error return-value
:

  RUN thbjattr_set-section IN THIS-PROCEDURE (
       input p-obj-type
      ,input p-obj-code
      ,input {&attr-abc-sale-day}
      ,INPUT table thbjattr_thbj-attr
  ) NO-ERROR.
  IF ERROR-STATUS:error THEN do:
    MESSAGE ERROR-STATUS:get-message(1)  SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

