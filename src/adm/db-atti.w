&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-attr NO-UNDO LIKE ub.db-attr
       field user-can-edit as log
       field code as char
       field value_ as char
       INDEX attrc is
       UNIQUE PRIMARY
       code
       INDEX attrcl is UNIQUE
       attr-code
       .


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/04/05
Author: Bakhtadze Natalya
Creation date: 10/04/05

------------------------------------------------------------------------*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-db-num as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/db-attr.i "interface" parparentproc }
{ gbl/getcntxt.i def }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc }

define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as char no-undo.
define variable ini-title as char no-undo.
define variable temp-doc-rec as recid no-undo.
define variable dops as character no-undo.
define variable dopst as character no-undo.
define variable v-tab-order as character no-undo .
define variable alco-val-log as logical no-undo .
define buffer buf_db for ub.db.
define buffer bufc_db for ub.db.

&scoped-define  db-attr-type-get-error message "Ошибка при определении названия и типа атрибута БД" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  db-attr-value-get-error message "Ошибка при определении значения атрибута БД!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

DEFINE MENU MENU-b-add .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-attr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-attr

/* Definitions for BROWSE br-attr                                       */
&Scoped-define FIELDS-IN-QUERY-br-attr temp-attr.attr-code ~
temp-attr.attr-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-attr
&Scoped-define QUERY-STRING-br-attr FOR EACH temp-attr NO-LOCK
&Scoped-define OPEN-QUERY-br-attr OPEN QUERY br-attr FOR EACH temp-attr NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-attr temp-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-attr temp-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-add b-lkp b-chg b-del b-help ~
db-db-num
&Scoped-Define DISPLAYED-OBJECTS db-db-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут БД".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут БД".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут БД".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE VARIABLE db-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 11 BY 1
     BGCOLOR 3  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-attr FOR
      temp-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-attr Dialog-Frame _STRUCTURED
  QUERY br-attr DISPLAY
      temp-attr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(100)":U
      temp-attr.attr-value COLUMN-LABEL "Значение" FORMAT "X(34)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.8 BY 15.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-add AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1.03 COL 70.1
     br-attr AT ROW 4.47 COL 1
     db-db-num AT ROW 3.13 COL 2
     SPACE(82.80) SKIP(18.06)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты БД".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-attr T "?" NO-UNDO ub db-attr
      ADDITIONAL-FIELDS:
          field user-can-edit as log
          field code as char
          field value_ as char
          INDEX attrc is
          UNIQUE PRIMARY
          code
          INDEX attrcl is UNIQUE
          attr-code

      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-attr b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BROWSE br-attr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN db-db-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-attr
/* Query rebuild information for BROWSE br-attr
     _TblList          = "Temp-Tables.temp-attr"
     _FldNameList[1]   > Temp-Tables.temp-attr.attr-code
"temp-attr.attr-code" "Атрибут" "X(100)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.temp-attr.attr-value
"temp-attr.attr-value" "Значение" "X(34)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE br-attr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты БД */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable loc#log as logical no-undo.
define buffer buf_temp-attr for temp-attr.
if add-option = "" then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-add-chg in this-procedure ( input yes) no-error .
if error-status:error then do:
  add-option = "":U.
  return no-apply.
end.
Run init-proc in this-procedure .
find first buf_temp-attr no-lock where
                        buf_temp-attr.code = add-option no-error.
add-option = "":U.
if avail buf_temp-attr then
    temp-doc-rec = recid(buf_temp-attr).
    else temp-doc-rec = ?.
reposition BR-attr to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-attr then return no-apply.
  run proc-add-chg in this-procedure ( input no) no-error .
  if error-status:error then return no-apply.
  RUN init-proc in this-procedure .
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
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable glog as logical no-undo .
DEFINE VARIABLE v-check AS CHARACTER NO-UNDO.
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  if not avail temp-attr then return no-apply.
  run db-attr-code in this-procedure (
                       input  temp-attr.code
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
    run value(v-check) (
                       input p-db-num
                      ,input temp-attr.code
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
  "Вы уверены, что хотите удалить атрибут " temp-attr.attr-code skip
  " для БД"
  view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
    run db-attr-delete in this-procedure (
                                           input p-db-num
                                          ,input temp-attr.code
                                          ,output loc#log) no-error .
    if error-status:error or not loc#log then do:
       {&db-attr-delete-get-error}
       return no-apply.
    end.
    delete temp-attr.
    updated = yes.
    run init-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  IF not AVAILABLE temp-attr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-attr
&Scoped-define SELF-NAME br-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-attr Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-attr IN FRAME Dialog-Frame
DO:
  if not avail temp-attr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-attr Dialog-Frame
ON RETURN OF br-attr IN FRAME Dialog-Frame
DO:
  if not avail temp-attr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
 { gbl/app_help.i }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/brwrefre.i }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-quit in frame {&frame-name}." }

frame {&frame-name}:TITLE = frame {&frame-name}:TITLE.
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { ref/attr-pop.i prepare }
  RUN MyEnable in this-procedure no-error.
  if error-status:error then return error.
  Run init-proc in this-procedure .
  view frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input {&table_db-attr} ).
if updated then return {&update}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-edit Dialog-Frame
PROCEDURE choose-to-edit :
define input parameter p-attr-code as character no-undo .

assign
add-option = p-attr-code
.
APPLY "CHOOSE" to b-add in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY db-db-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-add b-lkp b-chg b-del b-help db-db-num
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

define buffer buf_db for ub.db.
define buffer buf_db-attr for ub.db-attr.
for each  Temp-attr share-lock: delete Temp-attr. end.

add-option = "".

find first buf_db where
         buf_db.db-num =  p-db-num  no-lock no-error .

Assign
db-db-num = buf_db.db-num
.
display db-db-num
with frame {&frame-name}  .

   For each buf_db-attr where
            buf_db-attr.db-num  = p-db-num  no-lock :
      run db-attr-code in this-procedure (
                         input buf_db-attr.attr-code ,
                          output attr-type ,
                          output attr-format,
                          output attr-label,
                          output attr-user-can-edit,
                          output attr-output-display,
                          output attr-other ).

      if attr-output-display = true then DO:
          run db-attr-value in this-procedure (
                               input buf_db-attr.db-num
                              ,input buf_db-attr.attr-code
                              ,output attr-value
                              ,output attr-type ).

          create temp-attr.
          assign
          temp-attr.attr-code = attr-label
          temp-attr.value_ = buf_db-attr.attr-value
          temp-attr.attr-value = (if attr-type = {&type-log}
                                  then string(attr-value = "yes":U, attr-format)
                                  else attr-value)
          temp-attr.user-can-edit = attr-user-can-edit
          temp-attr.code = buf_db-attr.attr-code
          .
      End.
    End.   /* FOR EACH */
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable alco-val as character no-undo .
define variable alco-type as character no-undo .
assign
b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE
v-tab-order = "b-quit,b-add,b-lkp,b-chg,b-del,b-help,br-attr"
temp-attr.attr-code:width in browse br-attr = 50
temp-attr.attr-code:resizable in browse br-attr = yes
.
if p-mode <> {&lookup} then do:
  run attr-pop-create-items in this-procedure  (
                                                input {&table_db-attr}
                                                ,input 'db-attr-manual-edit'   /*p-get-section-num-proc-name*/
                                                ,input 'db-attr-tooltip'
                                                ,input 'choose-to-edit'
                                                ,input menu menu-b-add:handle
                                                ,input {&db-attr-list}
                                              ).
end.
DISPLAY db-db-num
WITH FRAME {&frame-name} .
ENABLE
b-quit
/*
b-del when p-mode <> {&lookup}
b-add when p-mode <> {&lookup}
b-chg when p-mode <> {&lookup}
*/
/*b-lkp*/
b-help br-attr db-db-num
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
ASSIGN b-add:MENU-MOUSE = 1.
HIDE
b-add
b-del
b-chg
b-lkp
IN FRAME {&FRAME-NAME}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "ENTRY" to br-attr.
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
define variable v-spr-param as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-ask-labels as character no-undo .
define variable choice as integer no-undo .

define var loc#log as logical no-undo.
case p-add:
  when yes then do:
    run db-attr-code in this-procedure (
       input  add-option          /* p-code           */
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
    if p-mode <> {&add-def} then do:
      run temp-db-attr-exist in this-procedure (
                                     input p-db-num
                                    ,input add-option
                                    ,output loc#log)  no-error.
      if error-status:error then return error.
      if loc#log then do:
        message
        "Данный атрибут уже существует"
        view-as alert-box error .
        return error.
      end.
    end.

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
                                          input p-db-num
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
    run db-attr-code in this-procedure (
                                     input temp-attr.code
                                    ,output attr-type
                                    ,output attr-format
                                    ,output attr-label
                                    ,output attr-user-can-edit
                                    ,output attr-output-display
                                    ,output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        {&db-attr-type-get-error}
        return error.
    END.
    RUN db-attr-VALUE IN THIS-PROCEDURE (
                                          INPUT p-db-num
                                         ,input temp-attr.code
                                         ,OUTPUT ATTR-VALUE
                                         ,OUTPUT attr-type) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        {&db-attr-value-get-error}
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
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-param":U then do:
      assign
      v-spr-param = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
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
      'title=':u + "Изменение атрибута БД" + '\':u
    + 'text1=':u + attr-label + '\':u
    + 'format=' + (if attr-type = {&type-log} then "yes/no" else attr-format) + '\':u
    + 'type=' + attr-type + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=' + (if p-mode <> {&update} then 'yes':u else 'no':u) + '\':u
    , input-output attr-value
        ).
    if return-value = 'false':u then return error.
  END.
  ELSE DO:
    if v-spr-param = "":U then do:
      run  value(v-spr)
                  in this-procedure (
                                       input p-db-num
                                      ,input-output attr-value
                                      ,output v-setted) no-error .
    end.
    else do:
      run  value( v-spr )
                in this-procedure (
                                       input p-db-num
                                      ,input v-spr-param
                                      ,input-output attr-value
                                      ,output v-setted) no-error .
    end.
    if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check)(
                       input p-db-num
                      ,input (if p-add = yes then add-option else temp-attr.attr-code)
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

  run db-attr-write in this-procedure (
                                     input p-db-num
                                    ,input (if p-add then add-option else temp-attr.code)
                                    ,input attr-value
                                   ) no-error .
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
  END.
  else do:
      {&db-attr-write-get-error}
  end.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as char no-undo .              /*для знач по умолч*/
define variable v-run-name as character no-undo .
define variable jj as integer no-undo .

run db-attr-code in this-procedure (
                                      input temp-attr.code
                                      ,output attr-type
                                      ,output attr-format
                                      ,output attr-label
                                      ,output attr-user-can-edit
                                      ,output attr-output-display
                                      ,output attr-other) no-error.
IF ERROR-STATUS:ERROR THEN DO:
    {&db-attr-type-get-error}
    return error.
END.
do jj = 1 to num-entries(attr-other, {&slash-char}):
  if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "display" then do:
    v-run-name = entry(2, entry(jj, attr-other, {&slash-char}), "=":U).
    run value(v-run-name) in this-procedure (
                                             input p-db-num
                                            ,input temp-attr.attr-code
                                            ,input temp-attr.value_
                                             )
                                             no-error .
    if error-status:error then undo, return error .
    return .
  end.
END.
BELL.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-db-attr-exist Dialog-Frame
PROCEDURE temp-db-attr-exist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error
  :
    define input parameter p-db-num like ub.db-attr.db-num   no-undo .
    define input parameter p-code     like ub.db-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .

    define buffer buf_db-attr for ub.db-attr .
    define buffer buf_temp-attr for temp-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run db-attr-code in this-procedure (
                                            input  p-code           /* p-code           */
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

    find first buf_temp-attr no-lock where
               buf_temp-attr.db-num  = p-db-num AND
               buf_temp-attr.attr-code = p-code no-error .
    if available buf_temp-attr then do:
      P-EXIST = YES.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME