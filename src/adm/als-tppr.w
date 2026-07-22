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

Редактирование атрибута магазина (clients-attr) "alias-type-price" "alias-object-price"

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 11/24/04
*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */


DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (clients-attr) alias-type-price alias-object-price".
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RS-alias-type-price ~
v-obj-code v-obj-type v-obj-name
&Scoped-Define DISPLAYED-OBJECTS RS-alias-type-price v-obj-code v-obj-type ~
v-obj-name

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

DEFINE BUTTON r-obj-firm
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Выбор из списка объектов".

DEFINE VARIABLE v-obj-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "Объект посредник"
      VIEW-AS TEXT
     SIZE 9.5 BY .67 NO-UNDO.

DEFINE VARIABLE v-obj-name AS CHARACTER FORMAT "X(40)":U
      VIEW-AS TEXT
     SIZE 31 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-obj-type AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 3.5 BY .67 NO-UNDO.

DEFINE VARIABLE RS-alias-type-price AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3
     SIZE 64.5 BY 4.25 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 21
     RS-alias-type-price AT ROW 2.25 COL 2 NO-LABEL
     r-obj-firm AT ROW 7 COL 35.5
     v-obj-code AT ROW 7.25 COL 19 COLON-ALIGNED
     v-obj-type AT ROW 7.25 COL 29.5 COLON-ALIGNED NO-LABEL
     v-obj-name AT ROW 7.25 COL 36.5 COLON-ALIGNED NO-LABEL
     SPACE(12.87) SKIP(2.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тип цены межфирменного и внутреннего перемещения при продаже товара другой фирмой"
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

/* SETTINGS FOR BUTTON r-obj-firm IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Тип цены межфирменного и внутреннего перемещения при продаже товара другой фирмой */
DO:
  run proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тип цены межфирменного и внутреннего перемещения при продаже товара другой фирмой */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj-firm Dialog-Frame
ON CHOOSE OF r-obj-firm IN FRAME Dialog-Frame
DO:
DEFINE buffer b#clients for ub.clients.
define variable  rid-list AS CHAR NO-UNDO.
define variable rep-rec2 as recid no-undo .

run ref/cli-all.w ( parParentProc, input "b-sel", {&shop}, ?, ?, ?, ?, ?, output  rid-list).
Assign rep-rec2 = integer(rid-list) no-error.
find first b#clients WHERE recid(b#clients) = rep-rec2 No-LOCK No-ERROR.

      if avail b#clients then do:
          Assign
              v-obj-code = b#clients.obj-code
              v-obj-type = b#clients.obj-type
              v-obj-name = b#clients.obj-name .
      end.

      Display   v-obj-code  v-obj-name  v-obj-type
      with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-alias-type-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-alias-type-price Dialog-Frame
ON VALUE-CHANGED OF RS-alias-type-price IN FRAME Dialog-Frame
DO:
  ASSIGN rs-alias-type-price.
  IF  rs-alias-type-price = INTEGER({&alias-type-price-m}) THEN DO:
      DISPLAY r-obj-firm v-obj-code v-obj-name v-obj-type WITH FRAME {&FRAME-NAME}.
      ENABLE  r-obj-firm  WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      HIDE r-obj-firm v-obj-code v-obj-name v-obj-type IN FRAME {&FRAME-NAME}.
  END.
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
  AND p-obj-type <> {&stock} THEN DO:
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
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-alias-tpsi}
        AND   locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-alias-tpsi}
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
  DISPLAY RS-alias-type-price v-obj-code v-obj-type v-obj-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RS-alias-type-price v-obj-code v-obj-type
         v-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
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
            , input {&attr-alias-tpsi}
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
  IF thbjattr_thbj-attr.prop-code = {&attr-alias-tpsi_alias-type-price} THEN DO:
    rs-alias-type-price = thbjattr_thbj-attr.property-value-integer.
  END.
  IF thbjattr_thbj-attr.prop-code = {&attr-alias-tpsi_alias-object-price} THEN DO:
    ASSIGN
    v-obj-type = entry(1, thbjattr_thbj-attr.property-value-character)
    v-obj-code = integer(entry(2, thbjattr_thbj-attr.property-value-character))
    no-error
    .
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable Dialog-Frame
PROCEDURE myenable :
DEFINE buffer b#clients for ub.clients.
RS-alias-type-price:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = "Не задан,0," +  {&alias-type-price-radio}  .
if rs-alias-type-price = INTEGER({&alias-type-price-m}) then do:

find first b#clients WHERE
          b#clients.obj-type = v-obj-type
      and b#clients.obj-code = v-obj-code no-lock no-error.
if avail b#clients then do:
  Assign
      v-obj-code = b#clients.obj-code
      v-obj-type = b#clients.obj-type
      v-obj-name = b#clients.obj-name .
end.
else
  Assign
  v-obj-code = 0
  v-obj-type = ""
  v-obj-name = "" .
  Display
  v-obj-code
  v-obj-name
  v-obj-type
  with frame {&frame-name} .
end.
DISPLAY
RS-alias-type-price
v-obj-code
v-obj-type
v-obj-name
WITH FRAME {&FRAME-NAME}.
ENABLE
B-exit when p-mode = {&update}
b-quit
B-Help  when p-mode = {&update}
RS-alias-type-price  when p-mode = {&update}
r-obj-firm when p-mode = {&update}
WITH FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
  DISABLE
  RS-alias-type-price
  r-obj-firm
  v-obj-code
  v-obj-name
  v-obj-type WITH FRAME {&FRAME-NAME}.
  HIDE B-exit IN FRAME {&FRAME-NAME}.
  b-quit:LABEL = "&Выход".
  b-quit:column = 1.
  DISPLAY
  b-quit
  WITH FRAME {&FRAME-NAME}.
END.
view frame {&frame-name} .
APPLY "VALUE-CHANGED":U TO RS-alias-type-price IN FRAME {&FRAME-NAME}.
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
define variable ii as integer no-undo .
define variable v-same as logical no-undo .
define variable v-param-type as character no-undo .

IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
RS-alias-type-price
v-obj-code
v-obj-type .
IF v-obj-code = 0
AND RS-alias-type-price = INT({&alias-type-price-m}) THEN DO:
  MESSAGE
  "Не задан Объект посредник!".
  RETURN ERROR.
END.

find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-alias-tpsi_alias-type-price}.
assign
thbjattr_thbj-attr.property-value-integer = rs-alias-type-price.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-alias-tpsi_alias-object-price}.
assign
thbjattr_thbj-attr.property-value-character = v-obj-type + {&comma-char} + STRING(v-obj-code).
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
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
            , input {&attr-alias-tpsi}
            , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output table-handle v-tth
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
      ,input {&attr-alias-tpsi}
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
