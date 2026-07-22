&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-odisc NO-UNDO LIKE ub.dis-dct-rule
       field rule-label as character.
DEFINE TEMP-TABLE tt0-dis-dct-rule NO-UNDO LIKE ub.dis-dct-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Скидки ДЛЯ типов ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/07
Author: Bakhtadze Natalya
Creation date: 05/27/07


------------------------------------------------------------------------*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-type as character no-undo.
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-pos-type as character no-undo .
define input parameter p-discnt-role-list as character no-undo .
define INPUT-OUTPUT parameter table for tt0-dis-dct-rule.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Скидки на тип ДК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ ref/disdctru.i "interface" parparentproc temp-odisc }

define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as CHARACTER no-undo.
define variable ini-title as char no-undo.
define variable temp-doc-rec as recid no-undo.
define variable dops as character no-undo.
define variable dopst as character no-undo.
define variable v-tab-order as character no-undo .
DEFINE VARIABLE dflt-cd AS CHARACTER NO-UNDO.
define variable loc-glob as logical no-undo .
define variable loc-firm as logical no-undo .
define variable loc-object as logical no-undo .
{ ref/send-ref.i dops dopst }
{ gbl/get-regf.i }
{ cmp/dc-list.i dc-list def "new shared" }
&scoped-define  disdcrul-type-get-error message "Ошибка при определении названия и типа скидки на тип ДК!" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  gdsorule-num-get-error message "Ошибка при определении значения скидки на тип ДК!" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

&scoped-define label-clmn_2 'Тип скидки'
&GLOBAL-DEFINE cd-type-code temp-odisc.pos-type

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-dct

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-odisc

/* Definitions for BROWSE br-dis-dct                                    */
&Scoped-define FIELDS-IN-QUERY-br-dis-dct temp-odisc.templ-rl-root disdctru-get-disc-label(temp-odisc.templ-rl-root) temp-odisc.rule-num temp-odisc.rl-root get-region(temp-odisc.host-code, temp-odisc.obj-type, temp-odisc.obj-code) {&cd-type-name}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-dct
&Scoped-define SELF-NAME br-dis-dct
&Scoped-define QUERY-STRING-br-dis-dct FOR EACH temp-odisc NO-LOCK
&Scoped-define OPEN-QUERY-br-dis-dct OPEN QUERY {&SELF-NAME} FOR EACH temp-odisc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-dis-dct temp-odisc
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-dct temp-odisc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-dis-dct}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-add B-lookup b-chg b-del ~
b-help card-type card-emitent
&Scoped-Define DISPLAYED-OBJECTS card-type card-emitent

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-add
       MENU-ITEM m_pos-type     LABEL "m_pos-type"
       MENU-ITEM m_no-pos       LABEL "По накладной"
       MENU-ITEM m_bo           LABEL "Бэкофис"      .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить скидку на тип ДК".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить скидку на тип ДК".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалитиь  скидку на тип ДК".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1 TOOLTIP "Выход с сохранением".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE VARIABLE card-emitent AS INTEGER FORMAT ">>>>>>>>>>9":U INITIAL 0
     LABEL "Эмитент"
      VIEW-AS TEXT
     SIZE 16.4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE card-type AS CHARACTER FORMAT "X(16)":U
     LABEL "Тип карты"
      VIEW-AS TEXT
     SIZE 16.4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-dct FOR
      temp-odisc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-dct
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-dct Dialog-Frame _FREEFORM
  QUERY br-dis-dct DISPLAY
      temp-odisc.templ-rl-root COLUMN-LABEL "Тип правила" FORMAT ">>>9":U
disdctru-get-disc-label(temp-odisc.templ-rl-root) COLUMN-LABEL {&label-clmn_2} FORMAT "X(255)":U WIDTH 50
temp-odisc.rule-num COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9":U
temp-odisc.rl-root COLUMN-LABEL "№ корн.!правила" FORMAT ">>>>>>>>9":U
get-region(temp-odisc.host-code, temp-odisc.obj-type, temp-odisc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)":U
{&cd-type-name} FORMAT "X(20)":U COLUMn-LABEL "Место использ."
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1 COL 95
     br-dis-dct AT ROW 4 COL 1
     card-type AT ROW 2.27 COL 1
     card-emitent AT ROW 2.27 COL 30.5 WIDGET-ID 2
     SPACE(43.10) SKIP(18.92)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Скидки на типы ДК".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-odisc T "?" NO-UNDO ub dis-dct-rule
      ADDITIONAL-FIELDS:
          field rule-label as character
      END-FIELDS.
      TABLE: tt0-dis-dct-rule T "?" NO-UNDO ub dis-dct-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-dct b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.

/* SETTINGS FOR BROWSE br-dis-dct IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN card-emitent IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN card-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-dct
/* Query rebuild information for BROWSE br-dis-dct
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-odisc NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-dis-dct */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Скидки на типы ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  if p-pos-type = '':U then do:
    if add-option = '':U then do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
    end.
    if add-option = '':U then return no-apply.
  end.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-odisc then return no-apply.
  run proc-add-chg in this-procedure ( input no, input temp-odisc.pos-type) no-error .
  if error-status:error then return no-apply.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical no-undo.
define variable v-deleted as logical no-undo .
define variable v-rule-label as character no-undo .
  if not avail temp-odisc then return no-apply.
    run disdctru-name in this-procedure
      (input  temp-odisc.templ-rl-root        /* p-templ-rl-root           */
      ,output v-rule-label          /* p-label          */
      ) no-error .
    if error-status :error then do:
      return no-apply .
    end.
  loc#log = no.
&scop cd-type-code temp-odisc.pos-type
  message
  substitute("Вы уверены, что хотите удалить скидку &1 (место использ &2) для типа ДК &3 (эмитент &4)"
           ,temp-odisc.templ-rl-root
           ,{&cd-type-name}
           ,p-type
           ,p-emitent-host-code
           )
          view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
  delete temp-odisc.
  updated = yes.
 {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
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
  if not avail temp-odisc then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-dct
&Scoped-define SELF-NAME br-dis-dct
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-dct Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-dis-dct IN FRAME Dialog-Frame
DO:
  if not avail temp-odisc then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-dct Dialog-Frame
ON RETURN OF br-dis-dct IN FRAME Dialog-Frame
DO:
  if not avail temp-odisc then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-dct Dialog-Frame
ON VALUE-CHANGED OF br-dis-dct IN FRAME Dialog-Frame
DO:
  IF v-cntxt-db-num > 0
  AND (temp-odisc.obj-type = '':U
  OR temp-odisc.host-code = 0) THEN DO:
     DISABLE
     b-chg
     with FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      enable
      b-chg WHEN (p-mode <> {&lookup})
      with FRAME {&FRAME-NAME}.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_bo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_bo Dialog-Frame
ON CHOOSE OF MENU-ITEM m_bo /* Бэкофис */
DO:
    add-option = {&cd-type-bo}.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_no-pos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_no-pos Dialog-Frame
ON CHOOSE OF MENU-ITEM m_no-pos /* По накладной */
DO:
  add-option = {&cd-type-no-cd}.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_pos-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_pos-type Dialog-Frame
ON CHOOSE OF MENU-ITEM m_pos-type /* m_pos-type */
DO:
  add-option = dflt-cd.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
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
  for each  temp-odisc share-lock:
    delete temp-odisc.
  end.
  RUN MyEnable in this-procedure .
  Run init-proc in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .
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
  DISPLAY card-type card-emitent
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-add B-lookup b-chg b-del b-help card-type card-emitent
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
define variable v-rule-label as character no-undo .         /* лабел атрибута    */
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_clients for ub.clients.
for each  temp-odisc share-lock:
  if p-mode = {&update}
  and (temp-odisc.obj-type = p-obj-type
      and
      temp-odisc.obj-code = p-obj-code)
  or (v-cntxt-db-num = 0
      and temp-odisc.obj-type = '':U
      and
      temp-odisc.obj-code = 0)
  or (v-cntxt-db-num = 0
      and temp-odisc.obj-type = {&cmp}
      and temp-odisc.obj-code = p-host-code)
      then do:
  end.
  else do:
    delete temp-odisc.
  end.
end.
if p-mode <> {&add-def} then do:
  Assign
  card-type = p-TYPE
  card-emitent = p-emitent-host-code
  .
  display
  card-type
  card-emitent
  with frame {&frame-name}  .
end.
 For each tt0-dis-dct-rule where
         tt0-dis-dct-rule.type  = p-type
    and  tt0-dis-dct-rule.emitent-host-code  = p-emitent-host-code
    no-lock :
    if p-pos-type <> '':U
    and p-pos-type <> tt0-dis-dct-rule.pos-type then do:
      NEXT.
    end.
    if lookup(tt0-dis-dct-rule.discnt-role, p-discnt-role-list) = 0 then next.
    run disdctru-name ( input tt0-dis-dct-rule.templ-rl-root
                        ,output v-rule-label
                         ).
    find first temp-odisc where
              temp-odisc.discnt-role = tt0-dis-dct-rule.discnt-role
          AND temp-odisc.host-code = tt0-dis-dct-rule.host-code
          AND temp-odisc.obj-code = tt0-dis-dct-rule.obj-code
          AND temp-odisc.obj-type = tt0-dis-dct-rule.obj-type
          AND temp-odisc.type = tt0-dis-dct-rule.type
          AND temp-odisc.emitent-host-code = tt0-dis-dct-rule.emitent-host-code
          AND temp-odisc.nonunique = tt0-dis-dct-rule.nonunique
          AND temp-odisc.pos-type = tt0-dis-dct-rule.pos-type
          no-error.
    if not available temp-odisc then do:
      create temp-odisc.
      assign
      temp-odisc.host-code = tt0-dis-dct-rule.host-code
      temp-odisc.obj-code = tt0-dis-dct-rule.obj-code
      temp-odisc.obj-type = tt0-dis-dct-rule.obj-type
      temp-odisc.type = tt0-dis-dct-rule.type
      temp-odisc.emitent-host-code = tt0-dis-dct-rule.emitent-host-code
      temp-odisc.pos-type = tt0-dis-dct-rule.pos-type
      temp-odisc.nonunique = tt0-dis-dct-rule.nonunique
      temp-odisc.discnt-role = tt0-dis-dct-rule.discnt-role
      .
    end.
    assign
    temp-odisc.templ-rl-root = tt0-dis-dct-rule.templ-rl-root
    temp-odisc.time-templ-rl-root = tt0-dis-dct-rule.time-templ-rl-root
    temp-odisc.rule-num =  tt0-dis-dct-rule.rule-num
    temp-odisc.rl-root =  tt0-dis-dct-rule.rl-root
    temp-odisc.rule-label = v-rule-label
    .
  End.   /* FOR EACH */
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.
v-h = br-dis-dct:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-clmn_2} then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
IF p-obj-type = {&shop} THEN DO:
  { gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
END.
if p-obj-type = {&stock} then do:
  dflt-cd = {&cd-type-no-cd}.
end.
ASSIGN
b-add:POPUP-MENU IN FRAME {&frame-name} = MENU MENU-b-add:HANDLE
b-add:MENU-MOUSE = 1
MENU-ITEM m_pos-type:LABEL IN MENU menu-b-add  = dflt-cd
MENU-ITEM m_pos-type:sensitive IN MENU menu-b-add  = ((dflt-cd <> '':U) and (dflt-cd <> {&cd-type-no-cd}))
.
if p-pos-type <> '':U then do:
  assign
  MENU-ITEM m_pos-type:sensitive IN MENU menu-b-add  = (MENU-ITEM m_pos-type:LABEL IN MENU menu-b-add = p-pos-type)
  MENU-ITEM m_bo:sensitive IN MENU menu-b-add  = (p-pos-type = {&cd-type-bo})
  MENU-ITEM m_no-pos:sensitive IN MENU menu-b-add  = (p-pos-type = {&cd-type-no-cd})
  .
end.
assign
v-tab-order = "b-exit,b-quit,b-add,b-lookup,b-chg,b-del,b-help,br-dis-dct".
                        .
DISPLAY
card-type
card-emitent
WITH FRAME {&frame-name}.
ENABLE
b-exit when (p-mode <> {&lookup} )
b-quit
b-del when (p-mode <> {&lookup} )
b-add when (p-mode <> {&lookup} )
b-chg when (p-mode <> {&lookup} )
b-lookup
b-help br-dis-dct
card-type
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
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "ENTRY" to br-dis-dct.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-chg Dialog-Frame
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo.
define input parameter p-pos-type as character no-undo.
define variable v-rule-label as character no-undo .         /*лабел атрибута */
DEFINE VARIABLE v-rule-num as integer no-undo .
define variable v-setted as logical no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
define variable v-cfg-nonunique as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-pos-type as character no-undo .
define variable v-discnt-role as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .

define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_temp-odisc for temp-odisc.
CASE p-add:
  when yes then do:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT (if p-pos-type = '':U then {&all} else "cd-type-list")
                        ,INPUT (if v-cntxt-db-num = 0 and loc-glob  then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 and loc-firm  then 1 else 0)
                        ,INPUT (if loc-object then 1 else 0)
                        ,input {&table_dis-dct-rule}
                        ,input '':U
                        ,input ?
                        ,INPUT p-pos-type
                        ,input p-discnt-role-list
                        ,INPUT-OUTPUT v-rid-list) NO-ERROR.
   IF ERROR-STATUS:ERROR
   OR v-rid-list = '':U THEN DO:
      RETURN.
   END.
   FIND FIRST buf_dis-cfg-rule NO-LOCK where
             recid(buf_dis-cfg-rule) = INTEGER(v-rid-list).
    assign
    v-templ-rl-root = buf_dis-cfg-rule.templ-rl-root
    v-time-templ-rl-root = buf_dis-cfg-rule.time-templ-rl-root
    V-cfg-NONUNIQUE = buf_dis-cfg-rule.nonunique
    v-pos-type   = buf_dis-cfg-rule.pos-type
    v-discnt-role = buf_dis-cfg-rule.discnt-role
    .
    assign
    added = yes.
    v-rule-num = 0.
   if (buf_dis-cfg-rule.has-global +
       buf_dis-cfg-rule.has-host +
       buf_dis-cfg-rule.has-obj) > 1 then do:
      /*надо выбрать todo*/
      define variable v-sel-vals as character no-undo .
      define variable v-sel-labels as character no-undo .
      define variable var-region as character no-undo .
      assign
      v-sel-vals = v-sel-vals +
                    (if buf_dis-cfg-rule.has-global = 1
                    then (fill({&space-char}, 3)  + string(0) + {&comma-char})
                    else "":U)
      v-sel-labels = v-sel-labels +
                    (if buf_dis-cfg-rule.has-global  = 1
                    then ("Глобально" + {&comma-char})
                    else "":U)
      .
      assign
      v-sel-vals = v-sel-vals +
                    (if buf_dis-cfg-rule.has-host = 1
                    then ({&cmp}  + string(v-cntxt-host-code-obj)  + {&comma-char})
                    else "":U)
      v-sel-labels = v-sel-labels +
                    (if buf_dis-cfg-rule.has-host = 1
                    then ("Фирма"  + string(v-cntxt-host-code-obj) + {&comma-char})
                    else "":U)
      .
      assign
      v-sel-vals = v-sel-vals +
                    (if buf_dis-cfg-rule.has-obj = 1
                    then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + {&comma-char})
                    else "":U)
      v-sel-labels = v-sel-labels +
                    (if buf_dis-cfg-rule.has-obj = 1
                    then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + {&comma-char})
                    else "":U)
      .
      run gbl/d-list.w (
                          input "b-sel":U
                          ,input "Выберите область действия"
                          ,input v-sel-vals
                          ,input v-sel-labels
                          ,input {&comma-char}
                          ,input "":U
                          ,output var-region) no-error.
      if error-status:error then do:
        return error.
      end.
      assign
      v-obj-type = (if var-region begins {&cmp}
                    then ''
                    else trim(substring(var-region, 1, 3))
                    )
      v-obj-code = (if var-region begins {&cmp}
                    then 0
                    else  integer(substring(var-region, 4))
                    )
      v-host-code = (if var-region begins {&cmp}
                      then integer(substring(var-region, 4))
                      else 0)
      .
      if v-host-code = 0
       and v-obj-type <> '':U then do:
        { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
      end.
    end. /*if (buf_dis-cfg-rule.has-global +*/
    else do:
      if buf_dis-cfg-rule.has-obj = 1 then do:
        assign
        v-obj-type = p-obj-type
        v-obj-code = p-obj-code
        .
      end.
      if buf_dis-cfg-rule.has-host = 1 then do:
        { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
        assign
        v-obj-type = ""
        v-obj-code = 0
        .
      end.
      if buf_dis-cfg-rule.has-glob = 1 then do:
        assign
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        .
      end.
    end.
  end. /*when add*/
  when no then do:
    find first buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.table-name = {&table_dis-dct-rule}
          and buf_dis-cfg-rule.discnt-role = temp-odisc.discnt-role
          and buf_dis-cfg-rule.pos-type = temp-odisc.pos-type
          no-error .
    if available buf_dis-cfg-rule then do:
      assign
      v-nonunique = buf_dis-cfg-rule.nonunique.
    end.
    v-rule-num  = temp-odisc.rule-num.
  end. /*when chg*/
END CASE.
run disdctru-edit in this-procedure (
                                       input (if p-add then {&add-def} else {&update})
                                      ,input p-type
                                      ,input p-emitent-host-code
                                      ,input (if p-add then v-host-code else temp-odisc.host-code)
                                      ,input (if p-add then v-obj-type  else temp-odisc.obj-type)
                                      ,input (if p-add then v-obj-code  else temp-odisc.obj-code)
                                      ,INPUT (if p-add then v-pos-type else temp-odisc.pos-type)
                                      ,input (if p-add then v-discnt-role else temp-odisc.discnt-role)
                                      ,input (if p-add then v-templ-rl-root else temp-odisc.templ-rl-root)
                                      ,input (if p-add then v-time-templ-rl-root else temp-odisc.time-templ-rl-root)
                                      ,input v-cfg-nonunique
                                      ,input 1
                                      ,input-output v-rule-num
                                      ,input-output v-nonunique
                                      ,output v-setted ) no-error.
if not v-setted then return error.
run temp-disdcrul-write in this-procedure (
                                           input p-type
                                          ,input p-emitent-host-code
                                          ,input (if p-add then v-host-code else temp-odisc.host-code)
                                          ,input (if p-add then v-obj-type else temp-odisc.obj-type)
                                          ,input (if p-add then v-obj-code else temp-odisc.obj-code)
                                          ,input (if p-add then v-pos-type else temp-odisc.pos-type)
                                          ,input (if p-add then v-templ-rl-root else temp-odisc.templ-rl-root)
                                          ,input (if p-add then v-time-templ-rl-root else temp-odisc.time-templ-rl-root)
                                          ,input (if p-add then v-discnt-role else temp-odisc.discnt-role)
                                          ,input (if p-add then ? else temp-odisc.nonunique)
                                          ,input v-rule-num
                                          ,input v-nonunique
                                          ) no-error .
IF not error-status:error then do:
  assign
  updated = yes
  .
  br-dis-dct:refresh() in frame {&frame-name} no-error .
END.
assign
added = no.
if p-add = yes then do:
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  find first buf_temp-odisc no-lock where
            buf_temp-odisc.pos-type = add-option
        AND buf_temp-odisc.templ-rl-root = v-templ-rl-root
        AND buf_temp-odisc.nonunique = v-nonunique
       and buf_temp-odisc.pos-type = add-option
       and buf_temp-odisc.host-code = v-host-code
       and buf_temp-odisc.obj-type = v-obj-type
       and buf_temp-odisc.obj-code = v-obj-code
      no-error.
  add-option = '':U.
  if avail buf_temp-odisc then
      temp-doc-rec = recid(buf_temp-odisc).
      else temp-doc-rec = ?.
  reposition br-dis-dct to recid temp-doc-rec no-error.
  if error-status:error then return no-apply.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lookup Dialog-Frame
PROCEDURE proc-b-lookup :
define variable disc-label as character no-undo .         /*лабел скидки*/
run disdctru-name in this-procedure (
                                      input temp-odisc.templ-rl-root
                                    , output disc-label
                                ) no-error.
IF ERROR-STATUS:ERROR THEN DO:
    {&disdcrul-type-get-error}
    return error.
END.
run ref/show-dr.p ( input parparentproc
                   ,input temp-odisc.rule-num) no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
for each temp-odisc NO-LOCK where
         temp-odisc.type = p-type
     and temp-odisc.emitent-host-code = p-emitent-host-code
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile ):
  if temp-odisc.obj-type = "" and v-cntxt-db-num <> 0 then next.
  if temp-odisc.host-code = 0 and v-cntxt-db-num <> 0 then next.
  find first tt0-dis-dct-rule NO-LOCK WHERE
          tt0-dis-dct-rule.type = temp-odisc.type
    AND   tt0-dis-dct-rule.host-code = temp-odisc.host-code
    AND   tt0-dis-dct-rule.obj-type = temp-odisc.obj-type
    AND   tt0-dis-dct-rule.obj-code = temp-odisc.obj-code
    AND   tt0-dis-dct-rule.pos-type = temp-odisc.pos-type
    AND   tt0-dis-dct-rule.discnt-role = temp-odisc.discnt-role
    AND tt0-dis-dct-rule.nonunique = temp-odisc.nonunique
    no-error.
  assign
  v-updated = no.
  if available  tt0-dis-dct-rule then do:
    BUFFER-COMPARE temp-odisc
                TO tt0-dis-dct-rule
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
    run tt0-disdcrul-write in this-procedure(
                                     input p-type
                                    ,input p-emitent-host-code
                                    ,input temp-odisc.host-code
                                    ,input temp-odisc.obj-type
                                    ,input temp-odisc.obj-code
                                    ,input temp-odisc.pos-type
                                    ,input temp-odisc.templ-rl-root
                                    ,input temp-odisc.time-templ-rl-root
                                    ,input temp-odisc.discnt-role
                                    ,input temp-odisc.rule-num
                                    ,input temp-odisc.nonunique
                                    )  no-error.
    if error-status:error then do:
      message
      "Ошибка при сохранении скидки на тип ДК" skip
      "Тип" p-type skip
      "Эмитент" p-emitent-host-code skip
      "объект" temp-odisc.obj-type temp-odisc.obj-code
      "Фирма" temp-odisc.host-code
      "Тип скидки" temp-odisc.templ-rl-root
      "Место использ." temp-odisc.pos-type
      view-as alert-box  error .
      undo, return error  .
    end.
    updated = yes.
  end.
End.
FOR EACH tt0-dis-dct-rule where
         tt0-dis-dct-rule.type = p-type
     and tt0-dis-dct-rule.emitent-host-code = p-emitent-host-code
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile ):
  if p-pos-type <> '':U
  and p-pos-type <> tt0-dis-dct-rule.pos-type then do:
    NEXT.
  end.
  if tt0-dis-dct-rule.obj-type = "" and v-cntxt-db-num <> 0 then next.
  if tt0-dis-dct-rule.host-code = 0 and v-cntxt-db-num <> 0 then next.

  FIND FIRST temp-odisc NO-LOCK WHERE
            temp-odisc.type = tt0-dis-dct-rule.type
        AND temp-odisc.host-code = tt0-dis-dct-rule.host-code
        AND temp-odisc.obj-type = tt0-dis-dct-rule.obj-type
        AND temp-odisc.obj-code = tt0-dis-dct-rule.obj-code
        AND temp-odisc.pos-type = tt0-dis-dct-rule.pos-type
        AND temp-odisc.discnt-role = tt0-dis-dct-rule.discnt-role
        AND temp-odisc.nonunique = tt0-dis-dct-rule.nonunique
        NO-ERROR.
    IF NOT AVAILABLE temp-odisc THEN DO:
      DELETE tt0-dis-dct-rule.
      assign
      v-deleted = yes.
    END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-disdcrul-write Dialog-Frame
PROCEDURE temp-disdcrul-write :
do
  on error undo, return error
  :
    define input parameter p-type like ub.dis-dct-rule.type   no-undo .
    define input parameter p-emitent-host-code like ub.dis-dct-rule.emitent-host-code no-undo .
    define input parameter p-host-code like ub.dis-dct-rule.host-code no-undo .
    define input parameter p-obj-type like ub.dis-dct-rule.obj-type   no-undo .
    define input parameter p-obj-code like ub.dis-dct-rule.obj-code   no-undo .
    define input parameter p-pos-type like ub.dis-dct-rule.pos-type  no-undo .
    define input parameter p-templ-rl-root     like ub.dis-dct-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root     like ub.dis-dct-rule.time-templ-rl-root  no-undo .
    define input parameter p-discnt-role like ub.dis-dct-rule.discnt-role no-undo .
    define input parameter p-was-nonunique like ub.dis-dct-rule.nonunique no-undo .
    define input parameter p-rule-num  like ub.dis-dct-rule.rule-num no-undo .
    define input parameter p-nonunique like ub.dis-dct-rule.nonunique no-undo .
    define variable v-rule-label as character no-undo .
    define buffer buf_temp-odisc for temp-odisc .
    define buffer buf_Dis-rule for ub.dis-rule.

    run disdctru-name in this-procedure (
                                           input  p-templ-rl-root           /* p-templ-rl-root           */
                                          ,output v-rule-label          /* p-label          */
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-odisc exclusive-lock where
               buf_temp-odisc.type  = p-type
           and buf_temp-odisc.emitent-host-code = p-emitent-host-code
           AND buf_temp-odisc.host-code  = p-host-code
           AND buf_temp-odisc.obj-type  = p-obj-type
           AND buf_temp-odisc.obj-code  = p-obj-code
           AND buf_temp-odisc.pos-type  = p-pos-type
           AND buf_temp-odisc.discnt-role = p-discnt-role
           AND buf_temp-odisc.nonunique = (if p-was-nonunique = ? then p-nonunique else p-was-nonunique)
           no-error no-wait .
    if not available buf_temp-odisc then do:
      create buf_temp-odisc .
      assign
      buf_temp-odisc.type  = p-type
      buf_temp-odisc.emitent-host-code = p-emitent-host-code
      buf_temp-odisc.obj-type  = p-obj-type
      buf_temp-odisc.obj-code  = p-obj-code
      buf_temp-odisc.host-code  = p-host-code
      buf_temp-odisc.pos-type  = p-pos-type
      buf_temp-odisc.rule-num = p-rule-num
      buf_temp-odisc.nonunique = p-nonunique
      buf_temp-odisc.discnt-role = p-discnt-role
      no-error
      .
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num.

    ASSIGN
    buf_temp-odisc.rule-num =  p-rule-num
    buf_temp-odisc.time-templ-rl-root = p-time-templ-rl-root
    buf_temp-odisc.nonunique = p-nonunique
    buf_temp-odisc.templ-rl-root = p-templ-rl-root
    buf_temp-odisc.rl-root = buf_dis-rule.rl-root
    no-error.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tt0-disdcrul-write Dialog-Frame
PROCEDURE tt0-disdcrul-write :
do
on error undo, return error
:

  define input parameter p-type like ub.dis-dct-rule.type   no-undo .
  define input parameter p-emitent-host-code like ub.dis-dct-rule.emitent-host-code no-undo .
  define input parameter p-host-code like ub.dis-dct-rule.host-code no-undo .
  define input parameter p-obj-type like ub.dis-dct-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-dct-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-dct-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-dct-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-dct-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role       like ub.dis-dct-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-dct-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-dct-rule.nonunique no-undo .

  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule .
  define buffer buf_Dis-rule for ub.dis-rule.

  run disdctru-name in this-procedure (
                                      input  p-templ-rl-root           /* p-templ-rl-root           */
                                      ,output v-rule-label          /* p-label          */
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.

  find first buf_tt0-dis-dct-rule exclusive-lock where
              buf_tt0-dis-dct-rule.type  = p-type
          and buf_tt0-dis-dct-rule.emitent-host-code  = p-emitent-host-code
          AND buf_tt0-dis-dct-rule.host-code  = p-host-code
          AND buf_tt0-dis-dct-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-dct-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-dct-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-dct-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-dct-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-dct-rule then do:
    create buf_tt0-dis-dct-rule .
    assign
    buf_tt0-dis-dct-rule.type  = p-type
    buf_tt0-dis-dct-rule.emitent-host-code  = p-emitent-host-code
    buf_tt0-dis-dct-rule.obj-type  = p-obj-type
    buf_tt0-dis-dct-rule.obj-code  = p-obj-code
    buf_tt0-dis-dct-rule.host-code  = p-host-code
    buf_tt0-dis-dct-rule.pos-type  = p-pos-type
    buf_tt0-dis-dct-rule.nonunique = p-nonunique
    buf_tt0-dis-dct-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-dct-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-dct-rule.rule-num = p-rule-num
  buf_tt0-dis-dct-rule.rl-root = buf_Dis-rule.rl-root
  buf_tt0-dis-dct-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-dct-rule.nonunique = p-nonunique
  no-error.

  release buf_tt0-dis-dct-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME