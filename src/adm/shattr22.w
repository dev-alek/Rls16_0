&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Редактирование атрибута магазина (thbj-attr) "gds-ref_obj"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'gds-ref_obj'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ ref/grplibfn.i }
DEFINE TEMP-TABLE tt-gdsreffi NO-UNDO
FIELD table-name AS CHARACTER
FIELD field-name AS CHARACTER
FIELD field-label AS CHARACTER
FIELD field-format AS CHARACTER
FIELD field-width AS DECIMAL
FIELD field-is-selected AS INTEGER
INDEX pi IS UNIQUE PRIMARY
table-name
field-name
INDEX iis
field-is-selected
.
DEFINE BUFFER sel_tt-gdsreffi FOR tt-gdsreffi.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-gdsscrvw AS CHARACTER NO-UNDO.
DEFINE BUFFER cli-buf FOR ub.clients .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
DEFINE TEMP-TABLE temp-gdsscrvw NO-UNDO
FIELD tbl-name AS CHARACTER
FIELD fld-name AS CHARACTER
FIELD custom-label AS CHARACTER
FIELD is-on AS LOGICAL
INDEX pi IS UNIQUE PRIMARY tbl-name fld-name
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-gdsscrvw

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-gdsscrvw

/* Definitions for BROWSE BR-gdsscrvw                                   */
&Scoped-define FIELDS-IN-QUERY-BR-gdsscrvw temp-gdsscrvw.custom-label temp-gdsscrvw.is-on
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gdsscrvw temp-gdsscrvw.is-on
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-gdsscrvw temp-gdsscrvw
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-gdsscrvw temp-gdsscrvw
&Scoped-define SELF-NAME BR-gdsscrvw
&Scoped-define QUERY-STRING-BR-gdsscrvw FOR EACH temp-gdsscrvw
&Scoped-define OPEN-QUERY-BR-gdsscrvw OPEN QUERY br-gdsscrvw FOR EACH temp-gdsscrvw.
&Scoped-define TABLES-IN-QUERY-BR-gdsscrvw temp-gdsscrvw
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gdsscrvw temp-gdsscrvw


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-gdsscrvw}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help B-dfltggrp BR-gdsscrvw t-chg-bcod f-image-dir
&Scoped-Define DISPLAYED-OBJECTS f-dfltggrp f-grp-name t-chg-bcod f-image-dir 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-2 f-dfltggrp B-dfltggrp f-grp-name f-image-dir

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-dfltggrp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 4 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-dfltggrp AS INTEGER FORMAT "->,>>>,>>9":U INITIAL -1
     LABEL "Гр.товаров по умолч."
     VIEW-AS FILL-IN NATIVE
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE f-grp-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 61 BY 1
     FGCOLOR 3  NO-UNDO.
     
DEFINE VARIABLE f-image-dir AS CHARACTER FORMAT "X(256)":U
     label "Директория для фото"
     VIEW-AS FILL-IN NATIVE
     SIZE 61 BY 1
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE t-chg-bcod AS LOGICAL INITIAL no 
     LABEL "Запрещена работа с Доп-БК" 
     VIEW-AS TOGGLE-BOX
     SIZE 49.4 BY .81 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-gdsscrvw FOR
      temp-gdsscrvw SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-gdsscrvw
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gdsscrvw Dialog-Frame _FREEFORM
  QUERY BR-gdsscrvw DISPLAY
      temp-gdsscrvw.custom-label  COLUMN-LABEL "Поле" FORMAT "X(25)"
temp-gdsscrvw.is-on COLUMN-LABEL "Показывать" VIEW-AS TOGGLE-BOX
ENABLE
temp-gdsscrvw.is-on
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 42 BY 6.13
         TITLE "Поля в экране покупателя" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-dfltggrp AT ROW 3.13 COL 21 COLON-ALIGNED WIDGET-ID 22
     B-dfltggrp AT ROW 3.13 COL 32.5 WIDGET-ID 24
     f-grp-name AT ROW 3.13 COL 35 COLON-ALIGNED NO-LABEL WIDGET-ID 68
     t-chg-bcod AT ROW 5.91 COL 2.6 WIDGET-ID 70
     f-image-dir at row 12 col 2.6 widget-id 80
     BR-gdsscrvw AT ROW 5 COL 57 WIDGET-ID 100
     SPACE(0.24) SKIP(12.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Набор опций работы со справочниками товаров"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
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
/* BROWSE-TAB BR-gdsscrvw f-grp-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-dfltggrp IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN f-dfltggrp IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
ASSIGN
       f-dfltggrp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-grp-name IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
ASSIGN
       f-grp-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gdsscrvw
/* Query rebuild information for BROWSE BR-gdsscrvw
     _START_FREEFORM
OPEN QUERY br-gdsscrvw FOR EACH temp-gdsscrvw.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-gdsscrvw */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Набор опций работы со справочниками товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dfltggrp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dfltggrp Dialog-Frame
ON CHOOSE OF B-dfltggrp IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-grp AS INTEGER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable glog as logical no-undo .
define buffer buf_gds-grp for ub.gds-grp.
IF f-dfltggrp <> -1  THEN DO:
  v-grp = f-dfltggrp.
END.
find first buf_gds-grp no-lock where
         buf_gds-grp.node-code = v-grp no-error.
if available buf_gds-grp then do:
  v-rid-list = string(recid(buf_gds-grp)).
end.
    run ref/gds-grp.w (
                  input parparentproc
                , input ({&g#term} + ',b-sel')
                , input p-obj-type
                , input p-obj-code
                , input-output v-rid-list) NO-ERROR.
IF NOT ERROR-STATUS:ERROR
and v-rid-list <> '':U
THEN DO:
  find first buf_gds-grp no-lock where
            recid(buf_gds-grp) = integer(v-rid-list) no-error.
  if available buf_gds-grp then do:
    f-dfltggrp = buf_gds-grp.node-code.
  end.
  RUN set-full-grp-name IN THIS-PROCEDURE ( INPUT f-dfltggrp) .
END.
if error-status:error
or v-rid-list = '':U then do:
  message
  "Хотите УБРАТЬ ЗАДАНИЕ ГРУППЫ ПО УМОЛЧАНИЮ?"
  view-as alert-box question buttons yes-no update glog.
  if glog then do:
    f-dfltggrp = -1.
    RUN set-full-grp-name IN THIS-PROCEDURE ( INPUT f-dfltggrp) .
  end.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gdsscrvw
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

ON value-changed OF temp-gdsscrvw.is-on IN BROWSE br-gdsscrvw DO:
DEFINE BUFFER buf_temp-gdsscrvw FOR temp-gdsscrvw.
if not avail temp-gdsscrvw then return no-apply.

FIND FIRST buf_temp-gdsscrvw WHERE RECID(buf_temp-gdsscrvw) = RECID(temp-gdsscrvw).
ASSIGN
buf_temp-gdsscrvw.is-on = LOGICAL(temp-gdsscrvw.is-on:SCREEN-VALUE IN BROWSE br-gdsscrvw).
end.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&stock}
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
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-gds-ref_obj}
        AND LOCKED_thbj-attr.prop-code = "":U
        NO-WAIT NO-ERROR.
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
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-gds-ref_obj}
    AND   LOCKED_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.
  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN Myenable in this-procedure .
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
  DISPLAY f-dfltggrp f-grp-name t-chg-bcod f-image-dir 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help B-dfltggrp t-chg-bcod BR-gdsscrvw f-image-dir
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
DEFINE VARIABLE v-gds-copy-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-gdsreffi-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as char no-undo .              /*для знач по умолч*/
define variable v-db as logical   no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-global as logical no-undo .
define variable v-need-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .


FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run thbjattr_code in this-procedure (
   input  {&attr-gds-ref_obj}
  ,input ''
  ,output attr-label
  ,output attr-user-can-edit
  ,output attr-output-display
  ,output attr-other
  ,output v-need-prop-list
  ,output v-prop-type-list
  ,output v-prop-label-list
  ,output v-global
  ,output v-host
  ,output v-shop
  ,output v-store
  ,output v-db
  ) no-error .

run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-gds-ref_obj}
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
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
/* Получив необходимые данные по аттрибуту из adm/shattri.p - заполняем временную таблицу "thbjattr_thbj-attr" в БД */
FOR EACH thbjattr_thbj-attr:
  if lookup(thbjattr_thbj-attr.prop-code, v-need-prop-list) = 0 then do:
    delete thbjattr_thbj-attr.
    next.
  end.
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  IF v-entry = {&attr-gds-ref_obj_dfltggrp} THEN DO:
    ASSIGN
    f-dfltggrp = thbjattr_thbj-attr.property-value-integer
    f-dfltggrp:private-data IN FRAME {&FRAME-NAME} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
    RUN set-full-grp-name IN THIS-PROCEDURE ( INPUT f-dfltggrp) .
  END.
  IF v-entry = {&attr-gds-ref_obj_chg-bcod} THEN DO:
    ASSIGN
    t-chg-bcod = thbjattr_thbj-attr.property-value-logical
    t-chg-bcod:private-data IN FRAME {&FRAME-NAME} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-gds-ref_obj_gdsscrvw} THEN DO:
    ASSIGN
    v-gdsscrvw = thbjattr_thbj-attr.property-value-character
    .
  END.
  IF v-entry = {&attr-gds-ref_obj_image-dir} THEN DO:
    ASSIGN
    f-image-dir = thbjattr_thbj-attr.property-value-character
    f-image-dir:private-data IN FRAME {&FRAME-NAME} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.

  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE BUFFER buf_custom-labels FOR ub.custom-labels.
DEFINE BUFFER buf_temp-gdsscrvw FOR temp-gdsscrvw.
FOR EACH buf_custom-labels NO-LOCK WHERE
        buf_custom-labels.CALL-TYPE = "add-fields"
    AND buf_custom-labels.CALL-point = "gdsscrvw":
  CREATE buf_temp-gdsscrvw.
  ASSIGN
  buf_temp-gdsscrvw.tbl-name = buf_custom-labels.tbl-name
  buf_temp-gdsscrvw.fld-name = buf_custom-labels.fld-name
  buf_temp-gdsscrvw.custom-label = buf_custom-labels.custom-label
  buf_temp-gdsscrvw.is-on = LOOKUP(substitute("&1.&2"
                                              , buf_custom-labels.tbl-name
                                              , buf_custom-labels.fld-name
                                              )

                                    , v-gdsscrvw) > 0
  .
END.
ASSIGN
temp-gdsscrvw.is-on:read-only IN BROWSE br-gdsscrvw = (p-mode = {&LOOKUP}).
if p-obj-type = {&shop}
or p-obj-type = {&stock} then do:
  ASSIGN
  FRAME {&FRAME-NAME}:TITLE = substitute("&1 &2&3"
                                         ,FRAME {&FRAME-NAME}:TITLE
                                         ,p-obj-type
                                         ,p-obj-code)
  .
end.

v-tab-order = "b-dfltggrp,t-chg-bcod,f-image-dir".
display
f-dfltggrp
f-grp-name
t-chg-bcod
f-image-dir
with frame {&frame-name} .
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
b-dfltggrp WHEN p-mode = {&UPDATE}
t-chg-bcod WHEN p-mode = {&UPDATE}
f-image-dir WHEN p-mode = {&UPDATE}
br-gdsscrvw
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    b-quit:column = 1
    .
END.
OPEN QUERY br-gdsscrvw FOR EACH temp-gdsscrvw.
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
define variable v-param-type as character no-undo .
define variable v-gds-copy-list as character no-undo .
define variable v-gdsreffi as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
DEFINE BUFFER buf_temp-gdsscrvw FOR temp-gdsscrvw.

IF p-mode = {&LOOKUP} THEN RETURN ERROR.
v-gdsscrvw = "".
fOR EACH buf_temp-gdsscrvw:

   IF buf_temp-gdsscrvw.is-on THEN DO:
      ASSIGN
      v-gdsscrvw =  substitute("&1,&2.&3"
                              ,v-gdsscrvw
                              , buf_temp-gdsscrvw.tbl-name
                              , buf_temp-gdsscrvw.fld-name).
   END.
END.
ASSIGN
v-gdsscrvw = TRIM(v-gdsscrvw, {&comma-char}).
ASSIGN
FRAME {&FRAME-NAME}
f-dfltggrp
t-chg-bcod
f-image-dir
.
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
  end.
  wh = wh:next-sibling.
end.
release thbjattr_thbj-attr.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-gds-ref_gdsscrvw}.
assign
thbjattr_thbj-attr.property-value-character = v-gdsscrvw
.
release thbjattr_thbj-attr.
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
            , input {&attr-gds-ref_obj}
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
      ,input {&attr-gds-ref_obj}
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-full-grp-name Dialog-Frame
PROCEDURE set-full-grp-name :
DEFINE INPUT PARAMETER p-node-code AS INTEGER NO-UNDO.
DEFINE BUFFER buf_gds-grp FOR ub.gds-grp.
if p-node-code <> -1 then do:
  find first buf_gds-grp no-lock where
            buf_gds-grp.node-code = p-node-code no-error.
  if not available buf_gds-grp then do:
    assign
    f-grp-name = '!!!!НЕВЕРНЫЙ КОД ГРУППЫ':U
    .
  END.
 else do:
   run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output f-grp-name) no-error.
   if error-status:error then do:
    assign
    f-grp-name = '!!!!НЕ УДАЛОСЬ НАЙТИ ПОЛНОЕ ИМЯ ГРУППЫ':U
    .
   end.
 end.
end.
else do:
  ASSIGN
  f-grp-name = '':U
  .
end.
DISPLAY
f-grp-name
f-dfltggrp
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

