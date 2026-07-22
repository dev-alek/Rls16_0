&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-oattr NO-UNDO LIKE ub.gds-obj-attr
       field user-can-edit as log
       field code as char
       field value_ as character
       INDEX attrc is
       UNIQUE PRIMARY
       code
       obj-type
       obj-code
       INDEX attrcl is UNIQUE
       attr-code
       obj-type
       obj-code
       .
DEFINE TEMP-TABLE tt0-gds-obj-attr NO-UNDO LIKE ub.gds-obj-attr.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsoatti.w $
$Archive: ref/gdsoatti.w $

Атрибуты товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

------------------------------------------------------------------------*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-mode-obj as character no-undo . /*g__Object all cmp "db":U*/
define input parameter p-gds-code as integer no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
define INPUT-OUTPUT parameter table for tt0-gds-obj-attr.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdsoatti.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gdsoatti.w $":U .
define variable vss-description as character no-undo init "Атрибуты товара на объекте ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ ref/gdsoattr.i "interface" parparentproc }
{ cmp/goa-list.i goa-list def "new shared" }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc }

define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as char no-undo.
define variable ini-title as char no-undo.
define variable temp-doc-rec as recid no-undo.
define variable dops as character no-undo.
define variable dopst as character no-undo.
define variable v-curr-obj-type like ub.gds-obj-attr.obj-type no-undo .
define variable v-curr-obj-code like ub.gds-obj-attr.obj-code no-undo .
define variable v-is-tpsi-object as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-tab-order as character no-undo .

{ ref/send-ref.i dops dopst }

{ cmp/gds-list.i gds-list def "new shared" }
&scoped-define  gdsoattr-type-get-error message "Ошибка при определении названия и типа атрибута товара на объекте!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  gdsoattr-value-get-error message "Ошибка при определении значения атрибута товара на объекте!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-add.

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
&Scoped-define INTERNAL-TABLES temp-oattr

/* Definitions for BROWSE br-attr                                       */
&Scoped-define FIELDS-IN-QUERY-br-attr temp-oattr.attr-code ~
temp-oattr.attr-value temp-oattr.obj-type temp-oattr.obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-attr
&Scoped-define QUERY-STRING-br-attr FOR EACH temp-oattr NO-LOCK
&Scoped-define OPEN-QUERY-br-attr OPEN QUERY br-attr FOR EACH temp-oattr NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-attr temp-oattr
&Scoped-define FIRST-TABLE-IN-QUERY-br-attr temp-oattr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-add B-lookup b-chg b-del ~
b-help RS-p-mode goods-artic Goods-dsc-name goods-gds-code goods-prod-type ~
goods-prod-code goods-prod-name
&Scoped-Define DISPLAYED-OBJECTS RS-p-mode goods-artic Goods-dsc-name ~
goods-gds-code goods-prod-type goods-prod-code goods-prod-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут товара на объекте".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут товара на объекте".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить атрибут товара на объекте".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1 TOOLTIP "Выход с сохранением".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE VARIABLE goods-artic AS CHARACTER FORMAT "X(16)":U
      VIEW-AS TEXT
     SIZE 16.38 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Goods-dsc-name AS CHARACTER FORMAT "X(60)":U
      VIEW-AS TEXT
     SIZE 61.63 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-gds-code AS INTEGER FORMAT ">>>>>>>>>>":U INITIAL 0
      VIEW-AS TEXT
     SIZE 11 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-prod-code AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.63 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-prod-name AS CHARACTER FORMAT "X(60)":U
      VIEW-AS TEXT
     SIZE 46.75 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-prod-type AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 3.75 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE RS-p-mode AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Текущий", "1",
"Объекты фирмы", "2",
"Объекты БД", "3"
     SIZE 16.88 BY 2 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-attr FOR
      temp-oattr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-attr Dialog-Frame _STRUCTURED
  QUERY br-attr DISPLAY
      temp-oattr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(50)":U
      temp-oattr.attr-value COLUMN-LABEL "Значение" FORMAT "X(34)":U
      temp-oattr.obj-type FORMAT "X(3)":U
      temp-oattr.obj-code FORMAT "99999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.75 BY 15.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1.04 COL 70.13
     RS-p-mode AT ROW 2.08 COL 81.63 NO-LABEL
     br-attr AT ROW 4.46 COL 1
     goods-artic AT ROW 2.13 COL 1.88 NO-LABEL
     Goods-dsc-name AT ROW 2.13 COL 19 NO-LABEL
     goods-gds-code AT ROW 3.29 COL 1.75 NO-LABEL
     goods-prod-type AT ROW 3.29 COL 19 NO-LABEL
     goods-prod-code AT ROW 3.29 COL 23.38 NO-LABEL
     goods-prod-name AT ROW 3.29 COL 33.75 NO-LABEL
     "Объекты:" VIEW-AS TEXT
          SIZE 15.38 BY .92 AT ROW 1.13 COL 81.63
          FGCOLOR 4
     SPACE(2.74) SKIP(17.90)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты товара на объекте".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-oattr T "?" NO-UNDO ub gds-obj-attr
      ADDITIONAL-FIELDS:
          field user-can-edit as log
          field code as char
          field value_ as character
          INDEX attrc is
          UNIQUE PRIMARY
          code
          obj-type
          obj-code
          INDEX attrcl is UNIQUE
          attr-code
          obj-type
          obj-code

      END-FIELDS.
      TABLE: tt0-gds-obj-attr T "?" NO-UNDO ub gds-obj-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-attr RS-p-mode Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BROWSE br-attr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN goods-artic IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN Goods-dsc-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN goods-gds-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN goods-prod-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN goods-prod-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN goods-prod-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-attr
/* Query rebuild information for BROWSE br-attr
     _TblList          = "Temp-Tables.temp-oattr"
     _FldNameList[1]   > Temp-Tables.temp-oattr.attr-code
"temp-oattr.attr-code" "Атрибут" "X(50)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.temp-oattr.attr-value
"temp-oattr.attr-value" "Значение" "X(34)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   = Temp-Tables.temp-oattr.obj-type
     _FldNameList[4]   = Temp-Tables.temp-oattr.obj-code
     _Query            is OPENED
*/  /* BROWSE br-attr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты товара на объекте */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define buffer buf_temp-oattr for temp-oattr.
  if add-option = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
  end.
  if add-option = "":U then return no-apply.
  run proc-add-chg in this-procedure (yes ) no-error.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  find first buf_temp-oattr no-lock where
             buf_temp-oattr.code = add-option no-error.
  add-option = "":U.
  if avail buf_temp-oattr then
      temp-doc-rec = recid(buf_temp-oattr).
      else temp-doc-rec = ?.
  reposition br-attr to recid temp-doc-rec no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-oattr then return no-apply.
  run proc-add-chg in this-procedure ( no) no-error .
  if error-status:error then return no-apply.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log             as logical   no-undo .
define variable attr-type           as character no-undo . /*тип атрибута*/
define variable attr-format         as character no-undo . /* формат атрибута*/
define variable attr-label          as character no-undo . /*лабел атрибута */
define variable attr-user-can-edit  as logical   no-undo . /*пользователь может изменять в броусе*/
define variable attr-output-display as logical   no-undo . /*виден в броусе*/
define variable attr-other          as character no-undo . /*еще чего - нибудь*/
define variable jj                  as integer   no-undo .
define variable v-check             as character no-undo .
define variable v-correct           as logical   no-undo .
define variable v-error-code        as character no-undo .
  if not available temp-oattr then return no-apply.
    run gdsoattr-name in this-procedure
      (input  temp-oattr.code           /* p-code           */
      ,output attr-type           /* p-type           */
      ,output attr-format         /* p-format         */
      ,output attr-label          /* p-label          */
      ,output attr-user-can-edit  /* p-user-can-edit  */
      ,output attr-output-display /* p-output-display */
      ,output attr-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      return no-apply .
    end.
  if not attr-user-can-edit then do:
    message
    "Атрибут нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
  end.
   do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check-ext":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
  end.
  if v-check <> "":U then do:
    run value(v-check)(
                        input p-gds-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input attr-value
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



  loc#log = no.
  message "Вы уверены, что хотите удалить атрибут " temp-oattr.attr-code skip
          "на объекте " temp-oattr.obj-type temp-oattr.obj-code " для товара " goods-dsc-name
          view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
  delete temp-oattr.
  updated = yes.
 {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  define buffer time_gds-obj-attr for ub.gds-obj-attr .
  define variable v-now as datetime no-undo .
/*  disable triggers for load of time_gds-obj-attr .*/
  if available (temp-oattr) and temp-oattr.code = "dt-seasons" then do:
    v-now = now .
    find first time_gds-obj-attr exclusive-lock where time_gds-obj-attr.attr-code = "change-dt-seasons" and 
    time_gds-obj-attr.gds-code = temp-oattr.gds-code and 
    time_gds-obj-attr.obj-code = temp-oattr.obj-code and 
    time_gds-obj-attr.obj-type = temp-oattr.obj-type no-error .
    if not available (time_gds-obj-attr) then 
    do:
      create time_gds-obj-attr .
      assign
        time_gds-obj-attr.attr-code = "change-dt-seasons" 
        time_gds-obj-attr.gds-code  = temp-oattr.gds-code  
        time_gds-obj-attr.obj-code  = temp-oattr.obj-code 
        time_gds-obj-attr.obj-type  = temp-oattr.obj-type
        .
    end.
    time_gds-obj-attr.attr-value  = iso-date(v-now) .
    end.  
   RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not available temp-oattr then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
/*
  FOR EACH temp-oattr no-LOCK:
    run gdsoattrr-write in this-procedure(
                                            input p-gds-code,
                                            input temp-oattr.obj-type,
                                            input temp-oattr.obj-code,
                                            input temp-oattr.code,
                                            input temp-oattr.attr-value)  no-error.

  END.
  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-attr
&Scoped-define SELF-NAME br-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-attr Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-attr IN FRAME Dialog-Frame
DO:
  if not avail temp-oattr then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-attr Dialog-Frame
ON RETURN OF br-attr IN FRAME Dialog-Frame
DO:
  if not avail temp-oattr then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-p-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-p-mode Dialog-Frame
ON VALUE-CHANGED OF RS-p-mode IN FRAME Dialog-Frame
DO:
  assign
  rs-p-mode
  p-mode-obj = rs-p-mode
  .
  DO TRANSACTION on error undo,  return no-apply on stop undo, return no-apply:
    case rs-p-mode:
      when {&cmp} then do:
        disable
        b-del
        b-add
        b-chg
        with frame {&frame-name}.
      end.
      when {&g___object} then do:
        enable
        b-del when p-mode <> {&lookup}
        b-add when p-mode <> {&lookup}
        b-chg when p-mode <> {&lookup}
        with frame {&frame-name}.
      end.
      when {&all} then do:
        disable
        b-del when p-mode = {&update}
        b-add when p-mode = {&update}
        b-chg when p-mode = {&update}
        with frame {&frame-name}.
      end.
      when "db":U then do:
        disable
        b-del when p-mode = {&update}
        b-add when p-mode = {&update}
        b-chg when p-mode = {&update}
        with frame {&frame-name}.
      end.
    END CASE.
    for each temp-oattr:
      if p-mode = {&update}
      and (temp-oattr.obj-type = p-obj-type
          and
          temp-oattr.obj-code = p-obj-code) then.
      else
      delete temp-oattr.
    end.
    run attr-pop-clean-up in this-procedure ( input {&table_gds-obj-attr} ).
    run MyENable in this-procedure .
    RUn init-proc(p-mode-obj).
  END.
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
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  ini-title  = frame {&frame-name}:TITLE.
  if NOT (p-mode = {&lookup}
        or p-mode = {&update}
        or p-mode = {&add-def}
        ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-mode" p-mode
    view-as alert-box ERROR.
    return error.
  end.
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  /*проверим что update может быть только на текущем объекте*/
  if p-mode = {&update}
  or p-mode = {&add-def}
  then do:
    assign
    v-curr-obj-type = v-cntxt-obj-type
    v-curr-obj-code = v-cntxt-obj-code
    .
    if not(p-obj-type = v-curr-obj-type
           and
           p-obj-code = v-curr-obj-code)
       or v-curr-obj-type = "":U
       or v-curr-obj-code = 0
      then do:
      message
      vss-workfile vss-revision vss-description skip
      "Редактирование атрибутов товара на объекте доступно только на текущем объекте" skip
      "Текущий объект" v-curr-obj-type v-curr-obj-code
      view-as alert-box error .
      undo, return error.
    end.
  end.
  for each  temp-oattr share-lock:
    delete temp-oattr.
  end.
  { ref/attr-pop.i prepare }
  RUN MyEnable in this-procedure .
  Run init-proc(p-mode-obj).
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
run attr-pop-clean-up in this-procedure ( input {&table_gds-obj-attr} ).
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
  DISPLAY RS-p-mode goods-artic Goods-dsc-name goods-gds-code goods-prod-type
          goods-prod-code goods-prod-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-add B-lookup b-chg b-del b-help RS-p-mode goods-artic
         Goods-dsc-name goods-gds-code goods-prod-type goods-prod-code
         goods-prod-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
DEFINE INPUT PARAMETER pp-mode as character no-undo.
/*{&all}  все объекты
{&g___object} выбранный объект
{&cmp} фирма
"db":U
*/
define variable  attr-type           as character no-undo . /* тип атрибута      */
define variable  attr-format         as character no-undo . /* формат атрибута   */
define variable  attr-label          as character no-undo . /* лабел атрибута    */
define variable  attr-value          as character no-undo . /* значение атрибута */
define variable  attr-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
define variable  attr-output-display as logical   no-undo . /* виден в броусе    */
define variable  attr-other          as character no-undo . /* еще чего - нибудь */
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer buf_prods for ub.clients.
for each  temp-oattr share-lock:
  if p-mode = {&update}
  and (temp-oattr.obj-type = p-obj-type
      and
      temp-oattr.obj-code = p-obj-code) then.
  else
  delete temp-oattr.
end.
if p-mode <> {&add-def} then do:
  find first buf_goods where
           buf_goods.gds-code =  p-gds-code no-lock no-error .
  find first buf_prods where
              buf_prods.obj-code =  buf_goods.prod-code
          and buf_prods.obj-type =  buf_goods.prod-type  no-lock no-error .

  Assign
  goods-dsc-name  = buf_Goods.gds-name
  goods-artic     = buf_goods.artic
  goods-gds-code  = buf_goods.gds-code
  goods-prod-type = buf_goods.prod-type
  goods-prod-code = buf_goods.prod-code
  goods-prod-name = buf_prods.obj-name
  .
display Goods-dsc-name goods-gds-code goods-artic
goods-prod-type goods-prod-code goods-prod-name
  with frame {&frame-name}  .
end.
 For each tt0-gds-obj-attr where
         tt0-gds-obj-attr.gds-code  = p-gds-code  no-lock :
    if pp-mode = {&g___object} and NOT
      (tt0-gds-obj-attr.obj-code = p-obj-code AND
       tt0-gds-obj-attr.obj-type = p-obj-type) then NEXT.
    if pp-mode = {&cmp} then do:
      find first buf_clients no-lock where
              buf_Clients.obj-type = tt0-gds-obj-attr.obj-type
          AND buf_Clients.obj-code = tt0-gds-obj-attr.obj-code no-error .
      if not avail buf_Clients or buf_Clients.host-code <> v-host-code then NEXT.
    end.
    if pp-mode = "db":U then do:
      find first buf_clients no-lock where
              buf_Clients.obj-type = tt0-gds-obj-attr.obj-type
          AND buf_Clients.obj-code = tt0-gds-obj-attr.obj-code no-error .
      if not avail buf_Clients or buf_Clients.db-num <> v-cntxt-db-num then NEXT.
    end.
    run gdsoattr-name ( input tt0-gds-obj-attr.attr-code ,
                        output attr-type ,
                        output attr-format,
                        output attr-label,
                        output attr-user-can-edit,
                        output attr-output-display,
                        output attr-other ).

    if attr-output-display = true then DO:
      find first temp-oattr where
                temp-oattr.code = tt0-gds-obj-attr.attr-code
            AND temp-oattr.obj-code = tt0-gds-obj-attr.obj-code
            AND temp-oattr.obj-type = tt0-gds-obj-attr.obj-type
            AND temp-oattr.gds-code = tt0-gds-obj-attr.gds-code no-error.
      if not available temp-oattr then do:
        create temp-oattr.
        assign
        temp-oattr.attr-code = attr-label
        Temp-oattr.value_ = tt0-gds-obj-attr.attr-value
        Temp-oattr.attr-value = (if attr-type = {&type-log}
                                then string(tt0-gds-obj-attr.attr-value = "yes":U, attr-format)
                                else tt0-gds-obj-attr.attr-value)
        temp-oattr.user-can-edit = attr-user-can-edit
        temp-oattr.code = tt0-gds-obj-attr.attr-code
        temp-oattr.obj-code = tt0-gds-obj-attr.obj-code
        temp-oattr.obj-type = tt0-gds-obj-attr.obj-type
        temp-oattr.gds-code = tt0-gds-obj-attr.gds-code
        .
      end.
    End.
  End.   /* FOR EACH */
  case pp-mode:
    when {&all} then do:
    end.
    when "db" then do:
        frame {&frame-name}:TITLE = ini-title + " - объекты БД " +
                                    string(v-cntxt-db-num).

    end.
    when {&g___object} then do:
        frame {&frame-name}:TITLE = ini-title + {&space-char} +
                                    p-obj-type + {&space-char} +
                                    string(p-obj-code).
    end.
    when {&cmp} then do:
        frame {&frame-name}:TITLE = ini-title + " - объекты фирмы " +
                                    string(v-host-code).
    end.
  end case.
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
ASSIGN
b-add:POPUP-MENU IN FRAME {&frame-name} = MENU MENU-b-add:HANDLE
b-add:MENU-MOUSE = 1
.
assign
v-tab-order = "b-exit,b-quit,b-add,b-lookup,b-chg,b-del,b-help,br-attr".
if p-mode <> {&lookup}
and (rs-p-mode = {&g___object}
     or
     rs-p-mode = '')
then do:
  run attr-pop-create-items in this-procedure  (
                                                input {&table_gds-obj-attr}
                                                ,input 'gdsoattr-manual-edit'   /*p-get-section-num-proc-name*/
                                                ,input 'gdsoattr-tooltip'
                                                ,input 'choose-to-edit'
                                                ,input menu menu-b-add:handle
                                                ,input {&gdsoattr-list}
                                              ).
end.
assign
rs-p-mode:radio-buttons in frame {&frame-name} = "Текущий" + {&comma-char} + {&g___object} + {&comma-char} +
                        "Объекты фирмы" + {&comma-char} + {&cmp} + {&comma-char} +
                        "Объекты БД" + {&comma-char} + "db" +
                        (if v-cntxt-db-num = 0 then ({&comma-char} + "Все объекты" + {&comma-char} + {&all}) else "":U)
                        .
RS-p-mode =  p-mode-obj.
DISPLAY Goods-dsc-name goods-gds-code goods-artic RS-p-mode
    WITH FRAME Dialog-Frame.
ENABLE
b-exit when (p-mode <> {&lookup} and p-mode-obj = {&g___object})
b-quit
b-del when (p-mode <> {&lookup} and p-mode-obj = {&g___object})
b-add when (p-mode <> {&lookup} and p-mode-obj = {&g___object})
b-chg when (p-mode <> {&lookup} and p-mode-obj = {&g___object})
b-lookup
b-help br-attr Goods-dsc-name goods-gds-code goods-artic
RS-p-mode WHEN (p-mode-obj = {&cmp} OR p-mode-obj = {&g___object})
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
if p-mode = {&lookup} then do:
  hide
  b-exit
  in frame {&frame-name} .
  assign
  b-quit:label = "&Выход"
  b-quit:col    = 1
  .
end.
if p-mode <> {&lookup} then do:
  if p-mode-obj = {&g___object} then do:
    run gbl/tpsi-obj.p (
                    input p-obj-type
                    ,input p-obj-code
                    ,output v-is-tpsi-object
                                        ) no-error .
  end.
  find first tt-attr-property where
            tt-attr-property.table-name = {&table_gds-obj-attr}
        and tt-attr-property.attr-code = {&attr-proprietor-o} no-error.
  if available tt-attr-property then do:
    assign
    tt-attr-property.menu-item-handle:sensitive = v-is-tpsi-object
    .
  end.
end.
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
define input parameter p-add as logical no-undo.
define variable attr-type           as character no-undo . /*тип атрибута*/
define variable attr-format         as character no-undo . /* формат атрибута*/
define variable attr-label          as character no-undo . /*лабел атрибута */
define variable attr-user-can-edit  as logical   no-undo . /*пользователь может изменять в броусе*/
define variable attr-output-display as logical   no-undo . /*виден в броусе*/
define variable attr-other          as character no-undo . /*еще чего - нибудь*/
define variable attr-value          as character no-undo . /*для знач по умолч*/
DEFINE VARIABLE v-attr-value        as character no-undo .
define variable loc#log             as logical   no-undo .
DEFINE VARIABLE v-init              as character no-undo .
define variable jj                  as integer   no-undo .
DEFINE VARIABLE v-spr               as character no-undo .
define variable v-spr-param         as character no-undo .
DEFINE VARIABLE v-setted            as logical   no-undo .
DEFINE VARIABLE v-deleted           as logical   no-undo .
define variable v-check             as character no-undo .
define variable v-error-code        as character no-undo .
define variable v-correct           as logical   no-undo .
CASE p-add:
  when yes then do:
    if p-mode <> {&add-def} then do:
      run temp-gdsoattr-exist in this-procedure(
                                      input p-gds-code,
                                      input p-obj-type,
                                      input p-obj-code,
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
    run gdsoattr-name in this-procedure
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
                    in this-procedure (p-gds-code, p-obj-type, p-obj-code, output attr-value) no-error .
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
  end. /*when add*/
  when no then do:
    run gdsoattr-name in this-procedure(input temp-oattr.code,
                                    output attr-type,
                                    output attr-format,
                                    output attr-label,
                                    output attr-user-can-edit,
                                    output attr-output-display,
                                    output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        {&gdsoattr-type-get-error}
        return error.
    END.
    attr-value  = temp-oattr.value_.
  end. /*when chg*/
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-ext":U
    or entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr":U
    then do:
      assign
      v-spr = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-param":U then do:
      assign
      v-spr-param = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check-ext":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
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
      'title=':u + "Изменение атрибута товара на объекте" + '\':u
    + 'text1=':u + attr-label + '\':u
    + 'format=' + (if attr-type = {&type-log} then "yes/no" else attr-format) + '\':u
    + 'type=' + attr-type + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=' + (if p-mode = {&lookup} then 'yes':u else 'no':u) + '\':u
    , input-output attr-value
    ).
    if return-value = 'false':u then return error.
  end.
  else do:
    if v-spr-param = "":U then do:
      run  value(v-spr) in this-procedure
                                    (
                                        input p-gds-code
                                      ,input p-obj-type
                                      ,input p-obj-code
                                      ,input-output attr-value
                                      ,output v-setted) no-error .

    end.
    else do:
      run  value(v-spr) in this-procedure
                                   (
                                       input p-gds-code
                                      ,input p-obj-type
                                      ,input p-obj-code
                                      ,input v-spr-param
                                      ,input-output attr-value
                                      ,output v-setted) no-error .


    end.
      if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check)(
                       input p-gds-code
                      ,input p-obj-type
                      ,input p-obj-code
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
  run temp-gdsoattr-write(
      input p-gds-code,
      input p-obj-type,
      input p-obj-code,
      input (if p-add then add-option else temp-oattr.code),
      input attr-value) no-error .
  IF not error-status:error then do:
      assign
      updated = yes
      .
     br-attr:refresh() in frame {&frame-name} no-error .
  END.
  assign
  added = no.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lookup Dialog-Frame
PROCEDURE proc-b-lookup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable attr-type           as character no-undo . /*тип атрибута*/
define variable attr-format         as character no-undo . /* формат атрибута*/
define variable attr-label          as character no-undo . /*лабел атрибута */
define variable attr-user-can-edit  as logical   no-undo . /*пользователь может изменять в броусе*/
define variable attr-output-display as logical   no-undo . /*виден в броусе*/
define variable attr-other          as character no-undo . /*еще чего - нибудь*/
define variable attr-value          as character no-undo . /*для знач по умолч*/
define variable v-run-name          as character no-undo .
define variable jj                  as integer   no-undo .

run gdsoattr-name in this-procedure(input temp-oattr.code,
                                output attr-type,
                                output attr-format,
                                output attr-label,
                                output attr-user-can-edit,
                                output attr-output-display,
                                output attr-other) no-error.
IF ERROR-STATUS:ERROR THEN DO:
    {&gdsoattr-type-get-error}
    return error.
END.
do jj = 1 to num-entries(attr-other, {&slash-char}):
  if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "display" then do:
    v-run-name = entry(2, entry(jj, attr-other, {&slash-char}), "=":U).
    run value(v-run-name) in this-procedure(
                                             input p-gds-code
                                            ,input temp-oattr.attr-code
                                            ,input temp-oattr.value_
                                            ,input p-obj-type
                                            ,input p-obj-code
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define variable v-type as character no-undo .
define variable v-issue-host-code like ub.sysconf.host-code no-undo .
for each temp-oattr NO-LOCK where
         temp-oattr.gds-code = p-gds-code
     AND temp-oattr.obj-type = p-obj-type
     AND temp-oattr.obj-code = p-obj-code:
   find first tt0-gds-obj-attr NO-LOCK WHERE
          tt0-gds-obj-attr.gds-code = temp-oattr.gds-code
    AND   tt0-gds-obj-attr.obj-type = temp-oattr.obj-type
    AND   tt0-gds-obj-attr.obj-code = temp-oattr.obj-code
    AND   tt0-gds-obj-attr.attr-code = temp-oattr.code no-error.
  assign
  v-updated = no.
  if available  tt0-gds-obj-attr then do:
    BUFFER-COMPARE temp-oattr
                TO tt0-gds-obj-attr
                case-sensitive
                SAVE result IN v-updated-str.
    assign
    v-created = yes
    v-updated = (v-updated-str <> "":U)
    .
  end.
  else do:
    assign
    v-updated = yes.
  end.
  if v-updated then do:
    run tt0-gdsoattr-write in this-procedure(
                                    input p-gds-code,
                                    input temp-oattr.obj-type,
                                    input temp-oattr.obj-code,
                                    input temp-oattr.code,
                                    input temp-oattr.value_)  no-error.
    if error-status:error then do:
      message
      "Ошибка при сохранении атрибута товара на объекте" skip
      "товар" p-gds-code skip
      "объект" temp-oattr.obj-type temp-oattr.obj-code
      "Атрибут" temp-oattr.attr-code
      view-as alert-box  error .
      undo, return error  .
    end.
    updated = yes.
  end.
  ASSIGN
  p-updated = v-updated OR p-updated.
End.
FOR EACH tt0-gds-obj-attr where
         tt0-gds-obj-attr.gds-code = p-gds-code
     AND tt0-gds-obj-attr.obj-type = p-obj-type
     AND tt0-gds-obj-attr.obj-code = p-obj-code:
  FIND FIRST temp-oattr NO-LOCK WHERE
            temp-oattr.gds-code = tt0-gds-obj-attr.gds-code
        AND temp-oattr.obj-type = tt0-gds-obj-attr.obj-type
        AND temp-oattr.obj-code = tt0-gds-obj-attr.obj-code
        AND temp-oattr.code = tt0-gds-obj-attr.attr-code NO-ERROR.
    IF NOT AVAILABLE temp-oattr THEN DO:
      DELETE tt0-gds-obj-attr.
      assign
      v-deleted = yes.
      ASSIGN
      p-updated = (v-deleted OR p-updated).
    END.
END.
if p-updated
and p-update-instantly then do:
  run ref/gdsoatr1.p (
                     input p-mode
                    ,input p-gds-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-gds-obj-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов товара на объекте:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
    undo, return error .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-gdsoattr-exist Dialog-Frame
PROCEDURE temp-gdsoattr-exist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .

    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define buffer buf_temp-oattr for temp-oattr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdsoattr-name in this-procedure
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

    find first buf_temp-oattr no-lock where
               buf_temp-oattr.gds-code  = p-gds-code AND
               buf_temp-oattr.obj-type  = p-obj-type AND
               buf_temp-oattr.obj-code  = p-obj-code AND
               buf_temp-oattr.attr-code = p-code no-error .
    if available buf_temp-oattr then do:
      P-EXIST = YES.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-gdsoattr-write Dialog-Frame
PROCEDURE temp-gdsoattr-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :

    define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .

    define buffer buf_temp-oattr for temp-oattr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdsoattr-name in this-procedure
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
    find first buf_temp-oattr exclusive-lock where
               buf_temp-oattr.gds-code  = p-gds-code AND
               buf_temp-oattr.obj-type  = p-obj-type AND
               buf_temp-oattr.obj-code  = p-obj-code AND
               buf_temp-oattr.code      = p-code no-error no-wait .
    if not available buf_temp-oattr then do:
      create buf_temp-oattr .
      assign
        buf_temp-oattr.gds-code  = p-gds-code
        buf_temp-oattr.obj-type  = p-obj-type
        buf_temp-oattr.obj-code  = p-obj-code
        buf_temp-oattr.attr-code = v-label
        buf_temp-oattr.code      = p-code
        buf_temp-oattr.attr-value = (if v-type = {&type-log} then string(logical(p-value), v-format) else p-value)
        buf_temp-oattr.value_ = p-value
        no-error
      .
    end.
    ELSE
    ASSIGN
    buf_temp-oattr.attr-value = (if v-type = {&type-log} then string(logical(p-value), v-format) else p-value)
    buf_temp-oattr.value_ = p-value
    no-error.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tt0-gdsoattr-write Dialog-Frame
PROCEDURE tt0-gdsoattr-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :

    define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .

    define buffer buf_tt0-gds-obj-attr for tt0-gds-obj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdsoattr-name in this-procedure
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

    find first buf_tt0-gds-obj-attr exclusive-lock where
               buf_tt0-gds-obj-attr.gds-code  = p-gds-code AND
               buf_tt0-gds-obj-attr.obj-type  = p-obj-type AND
               buf_tt0-gds-obj-attr.obj-code  = p-obj-code AND
               buf_tt0-gds-obj-attr.attr-code = p-code no-error .
    if not available buf_tt0-gds-obj-attr then do:
      create buf_tt0-gds-obj-attr .
      assign
        buf_tt0-gds-obj-attr.gds-code  = p-gds-code
        buf_tt0-gds-obj-attr.obj-type  = p-obj-type
        buf_tt0-gds-obj-attr.obj-code  = p-obj-code
        buf_tt0-gds-obj-attr.attr-code = p-code
        buf_tt0-gds-obj-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_tt0-gds-obj-attr.attr-value = p-value no-error.
    release buf_tt0-gds-obj-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME