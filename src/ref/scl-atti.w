&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE Temp-hattr NO-UNDO LIKE ub.scales-attr
       field user-can-edit as log
       field code as character
       field value_ as character.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/16/04
Author: Bakhtadze Natalya
Creation date: 06/16/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter mode as char no-undo.
define input parameter p-db-num like ub.scales-attr.db-num no-undo.
define input parameter p-scales-num like ub.scales-attr.scales-num no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты весов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ ref/scl-attr.i interface }
{ cmp/library.i }
{ cmp/showinf.i }

define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
define buffer buf_scales for ub.scales.

&scoped-define  scl-attr-type-get-error message "Ошибка при определении названия и типа атрибута весов!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  scl-attr-value-get-error message "Ошибка при определении значения атрибута весов!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  scl-attr-write-get-error message "Ошибка при изменении значения атрибута весов!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

&scoped-define  scl-attr-delete-get-error message "Ошибка при удалении атрибута весов!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-SCL-ATTRS

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Temp-hattr

/* Definitions for BROWSE BR-SCL-ATTRS                                  */
&Scoped-define FIELDS-IN-QUERY-BR-SCL-ATTRS Temp-hattr.attr-code ~
Temp-hattr.attr-value 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-SCL-ATTRS 
&Scoped-define QUERY-STRING-BR-SCL-ATTRS FOR EACH Temp-hattr NO-LOCK
&Scoped-define OPEN-QUERY-BR-SCL-ATTRS OPEN QUERY BR-SCL-ATTRS FOR EACH Temp-hattr NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-SCL-ATTRS Temp-hattr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-SCL-ATTRS Temp-hattr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-SCL-ATTRS}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-ins b-chg b-del b-help scl-db-num ~
scl-scales-type scl-scales-num scl-scales-name 
&Scoped-Define DISPLAYED-OBJECTS scl-db-num scl-scales-type scl-scales-num ~
scl-scales-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-ins 
       MENU-ITEM m_tara-weight  LABEL "Веса и коды тары".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg 
     LABEL "&Изменить":L 
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут весов".

DEFINE BUTTON b-del 
     LABEL "&Удалить":L 
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут весов".

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-ins 
     LABEL "&Добавить":L 
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут весов".

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE VARIABLE scl-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "БД" 
      VIEW-AS TEXT 
     SIZE 9.63 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE scl-scales-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Название" 
      VIEW-AS TEXT 
     SIZE 43 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE scl-scales-num AS INTEGER FORMAT ">>>9":U INITIAL 0 
     LABEL "№" 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE scl-scales-type AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип" 
      VIEW-AS TEXT 
     SIZE 21.5 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-SCL-ATTRS FOR 
      Temp-hattr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-SCL-ATTRS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-SCL-ATTRS Dialog-Frame _STRUCTURED
  QUERY BR-SCL-ATTRS DISPLAY
      Temp-hattr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(50)":U
      Temp-hattr.attr-value COLUMN-LABEL "Значение" FORMAT "X(50)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 91 BY 15.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-ins AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     b-help AT ROW 1.04 COL 70.13
     BR-SCL-ATTRS AT ROW 4.46 COL 2
     scl-db-num AT ROW 2.13 COL 1
     scl-scales-type AT ROW 2.13 COL 19.5 COLON-ALIGNED
     scl-scales-num AT ROW 3.25 COL 2
     scl-scales-name AT ROW 3.29 COL 19.5 COLON-ALIGNED
     SPACE(28.50) SKIP(15.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Атрибуты весов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: Temp-hattr T "?" NO-UNDO ub scales-attr
      ADDITIONAL-FIELDS:
          field user-can-edit as log
          field code as character
          field value_ as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-SCL-ATTRS b-help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       b-ins:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-ins:HANDLE.

/* SETTINGS FOR BROWSE BR-SCL-ATTRS IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN scl-db-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN scl-scales-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-SCL-ATTRS
/* Query rebuild information for BROWSE BR-SCL-ATTRS
     _TblList          = "Temp-Tables.Temp-hattr"
     _FldNameList[1]   > Temp-Tables.Temp-hattr.attr-code
"Temp-hattr.attr-code" "Атрибут" "X(50)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.Temp-hattr.attr-value
"Temp-hattr.attr-value" "Значение" "X(50)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BR-SCL-ATTRS */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты весов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-hattr then return no-apply.
  run proc-add-chg in this-procedure (no ) no-error.
  if error-status:error then return no-apply.
  RUN init-proc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical no-undo.
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE v-check AS CHARACTER NO-UNDO.
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  if not avail temp-hattr then return no-apply.
  run scl-attr-code (
    input  temp-hattr.code
    ,output attr-type
    ,output attr-format
    ,output attr-label
    ,output attr-user-can-edit
    ,output attr-output-display
    ,output attr-other
    ) .
  if not attr-user-can-edit then do:
    message
    "Атрибут нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
  end.
     do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
  end.
  if v-check <> "":U then do:
    run value(v-check)(
                       input p-db-num
                      ,INPUT p-scales-num
                      ,input temp-hattr.code
                      ,input "0":U
                      ,input {&deletion}
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности удаления атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return no-apply .
    end.
    if not v-correct then do:
      message
      "Удаление атрибута некорректно" skip
      return-value
      view-as alert-box error .
      undo, return no-apply .
    end.
  end.


  glog = no.
  message
  "Вы уверены, что хотите удалить атрибут " temp-hattr.attr-code skip
  " для весов"
  view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
    run scl-attr-delete in this-procedure(
                                    input p-db-num,
                                    input p-scales-num,
                                    input temp-hattr.code,
                                    output loc#log) no-error .
    if error-status:error or not loc#log then do:
       {&scl-attr-delete-get-error}
       return no-apply.
    end.
    delete temp-hattr.
    updated = yes.
    run init-proc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ins Dialog-Frame
ON CHOOSE OF b-ins IN FRAME Dialog-Frame /* Добавить */
DO:
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable loc#log as logical no-undo.
define buffer buf_temp-hattr for temp-hattr.
if add-option = "" then do:
  run gbl/pop-up.p (self:handle, no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-add-chg in this-procedure (yes) no-error .
if error-status:error then do:
  add-option = "":U.
  return no-apply.
end.
Run init-proc.
find first buf_temp-hattr no-lock where
                        buf_temp-hattr.code = add-option no-error.
add-option = "":U.
if avail buf_temp-hattr then
    temp-doc-rec = recid(buf_temp-hattr).
    else temp-doc-rec = ?.
reposition BR-SCL-ATTRS to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход  */
DO:
/*
  for each temp-hattr no-lock:
    run scl-attr-write in this-procedure(
                                    input p-db-num,
                                    input add-option,
                                    input temp-hattr.attr-value)  no-error.
    updated = yes.
  End.
  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_tara-weight
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_tara-weight Dialog-Frame
ON CHOOSE OF MENU-ITEM m_tara-weight /* Веса и коды тары */
DO:
  add-option = {&scl-attr-tare-weight}.
   apply "CHOOSE" to b-ins in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-SCL-ATTRS
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */
 { gbl/app_help.i }

 frame {&frame-name}:TITLE = frame {&frame-name}:TITLE.
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   IF mode <> {&UPDATE}
   AND mode <> {&lookup} THEN DO:
      MESSAGE
      substitute("Неверное значение параметра p-mode = &1", mode)
      VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR.
   END.
  find first buf_scales
  where buf_scales.db-num =  p-db-num
    AND buf_scales.scales-num = p-scales-num
    no-lock  .
  RUN MyEnable no-error.
  if error-status:error then return error.
  Run init-proc.
  view frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
if updated then return {&update}.

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
  DISPLAY scl-db-num scl-scales-type scl-scales-num scl-scales-name 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-ins b-chg b-del b-help scl-db-num scl-scales-type 
         scl-scales-num scl-scales-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
define var  attr-type as character no-undo .          /* тип атрибута      */
define var  attr-format as character no-undo .        /* формат атрибута   */
define var  attr-label as character no-undo .         /* лабел атрибута    */
define var  attr-value as character no-undo .         /* значение атрибута */
define var  attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define var  attr-output-display as logical no-undo .  /* виден в броусе    */
define var  attr-other as char no-undo .              /* еще чего - нибудь */

define buffer buf_scales-attr for ub.scales-attr.
for each  Temp-hattr share-lock: delete Temp-hattr. end.

add-option = "".

Assign
    scl-db-num = buf_scales.db-num
    scl-scales-num = buf_scales.scales-num
    scl-scales-type = buf_scales.scales-type
    scl-scales-name = buf_scales.scales-name
    .
display scl-db-num scl-scales-num scl-scales-type scl-scales-name
  with frame {&frame-name}  .

   For each buf_scales-attr where
            buf_scales-attr.db-num  = p-db-num
       and  buf_scales-attr.scales-num  = p-scales-num
            no-lock :
          run scl-attr-code ( input buf_scales-attr.attr-code ,
                              output attr-type ,
                              output attr-format,
                              output attr-label,
                              output attr-user-can-edit,
                              output attr-output-display,
                              output attr-other ).

          if attr-output-display = true then DO:
              run scl-attr-value ( input buf_scales-attr.db-num,
                                  input buf_scales-attr.scales-num,
                                  input buf_scales-attr.attr-code,
                                  output attr-value,
                                  output attr-type ).

              create Temp-hattr.
              assign Temp-hattr.attr-code = attr-label
                     Temp-hattr.value_ = buf_scales-attr.attr-value
                     Temp-hattr.attr-value = (if attr-type = {&type-log}
                                              then string(attr-value = "yes":U, attr-format)
                                              else attr-value)
                     Temp-hattr.user-can-edit = attr-user-can-edit
                     Temp-hattr.code = buf_scales-attr.attr-code
                    .
                End.
    End.   /* FOR EACH */
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define var  attr-type as character no-undo .          /* тип атрибута      */
define var  attr-format as character no-undo .        /* формат атрибута   */
define var  attr-label as character no-undo .         /* лабел атрибута    */
define var  attr-value as character no-undo .         /* значение атрибута */
define var  attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define var  attr-output-display as logical no-undo .  /* виден в броусе    */
define var  attr-other as char no-undo .              /* еще чего - нибудь */

define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-scl as character no-undo .
define variable v-scl-list as character no-undo .
if mode <> {&lookup} then do:
  do ii = 1 to num-entries({&scl-attr-list}):
    run scl-attr-code (
      input  entry(ii, {&scl-attr-list})
      ,output attr-type
      ,output attr-format
      ,output attr-label
      ,output attr-user-can-edit
      ,output attr-output-display
      ,output attr-other
      ) .
    do jj = 1 to num-entries(attr-other, {&slash-char}):
      if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "scl":U then do:
        assign
        v-scl = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
        v-scl-list = v-scl-list + (if ii = 1 then "":U else {&slash-char}) + v-scl
        .
      end.
    end.
  end.
    assign
    MENU-ITEM m_tara-weight:private-data in menu MENU-b-ins = {&scl-attr-tare-weight}
    .
    assign
    /*номер атрибута в листе*/
    ii = LOOKUP(MENU-ITEM m_tara-weight:private-data in menu MENU-b-ins, {&scl-attr-list})
    /*список весов для атрибута*/
    v-scl = entry(ii, v-scl-list, {&slash-char})
    /*входит наша касса в этот список?*/
    MENU-ITEM m_tara-weight:sensitive in menu MENU-b-ins = (LOOKUP(buf_scales.scales-type, v-scl)  > 0)
    .
  end.

  ENABLE
  b-quit
  b-del when mode = {&update}
  b-ins when mode = {&update}
  b-chg when mode = {&update}
  b-help BR-SCL-ATTRS
  WITH FRAME {&frame-name} .
  VIEW FRAME {&frame-name} .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  ASSIGN b-ins:MENU-MOUSE = 1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-chg Dialog-Frame 
PROCEDURE proc-add-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-add as logical no-undo .
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-init as character no-undo .

define variable jj as integer no-undo.
DEFINE VARIABLE v-spr as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .

define var loc#log as logical no-undo.
case p-add:
  when yes then do:
    if mode <> {&add-def} then do:
      run temp-scl-attr-exist in this-procedure(
                                    input p-db-num,
                                    input p-scales-num,
                                    input add-option,
                                    output loc#log)  no-error.
      if error-status:error then return error.
      if loc#log then do:
        message
        "Данный атрибут уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    run scl-attr-code in this-procedure
      (input  add-option          /* p-code           */
      ,output attr-type           /* p-type           */
      ,output attr-format         /* p-format         */
      ,output attr-label          /* p-label          */
      ,output attr-user-can-edit  /* p-user-can-edit  */
      ,output attr-output-display /* p-output-display */
      ,output attr-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      return error .
    end.
    assign
    added = yes.
    do jj = 1 to num-entries(attr-other, {&slash-char}):
      if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "init":U then do:
        assign
        v-init = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
        .
      end.
    end. /*jj*/
    if  v-init <> "":U then do:
        run  value(v-init)
                    in this-procedure (
                                          p-db-num
                                        , p-scales-num
                                        , output attr-value) no-error .
          if error-status:error then do:
              assign
              attr-value = "":U
              .
          end.
    end.
    CASE attr-type:
      when {&type-log} then do:
        assign
        v-attr-value = "yes":U
        .
      end.
      when {&type-int} or when {&type-dec} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else string(0)
        .
      end.
      when {&type-date} then do:
        assign
        v-attr-value = ?
        .
      end.
      when {&type-char} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-value = v-attr-value
    .
  end.
  when no then do:
    run scl-attr-code in this-procedure(input TEMP-hattr.code,
                                    output attr-type,
                                    output attr-format,
                                    output attr-label,
                                    output attr-user-can-edit,
                                    output attr-output-display,
                                    output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        {&scl-attr-type-get-error}
        return error.
    END.
    RUN scl-attr-VALUE IN THIS-PROCEDURE(
                                         INPUT p-db-num,
                                         input p-scales-num,
                                         input TEMP-hattr.code,
                                         OUTPUT ATTR-VALUE,
                                         OUTPUT attr-type) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        {&scl-attr-value-get-error}
        return error.
    END.
  end.
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr":U then do:
      assign
      v-spr = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.

  end.
  if v-spr = "":U then do:

  run gbl/d-prompt.w (
    'title=':u + "Изменение атрибута весов" + '\':u
  + 'text1=':u + attr-label + '\':u
  + 'format=' + (if attr-type = {&type-log} then "yes/no" else attr-format) + '\':u
  + 'type=' + attr-type + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=20\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
  + 'readonly=' + (if mode <> {&update} then 'yes':u else 'no':u) + '\':u
  , input-output attr-value
      ).
  if return-value = 'false':u then return error.
  END.
  ELSE DO:

      run  value(v-spr)
                  in this-procedure (
                                       input p-db-num
                                      ,INPUT p-scales-num
                                      ,input-output attr-value
                                      ,output v-setted) no-error .
      if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check)(
                       input p-db-num
                      ,input p-scales-num
                      ,input (if p-add = yes then add-option else temp-hattr.attr-code)
                      ,input attr-value
                      ,input (if p-add then {&add-def} else {&update})
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности задаваемого значения атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return error .
    end.
    if not v-correct then do:
      message
      "Задаваемое значение атрибута некорректно" skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
  end.


  run scl-attr-write in this-procedure(
                                    input p-db-num,
                                    input p-scales-num,
                                    input (if p-add then add-option else temp-hattr.code),
                                    input attr-value
                                   ) no-error .
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
  END.
  else do:
      {&scl-attr-write-get-error}
  end.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-scl-attr-exist Dialog-Frame 
PROCEDURE temp-scl-attr-exist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .
    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_temp-hattr for temp-hattr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run scl-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_temp-hattr exclusive-lock
      where buf_temp-hattr.db-num  = p-db-num
        and buf_temp-hattr.scales-num  = p-scales-num
        and buf_temp-hattr.attr-code = p-code
      no-error .

    if  available buf_temp-hattr then do:
      p-exist = yes.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

