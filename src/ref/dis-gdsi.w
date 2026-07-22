&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-odisc NO-UNDO LIKE ub.dis-gds-rule
       field rule-label as character.
DEFINE TEMP-TABLE tt0-dis-gds-rule NO-UNDO LIKE ub.dis-gds-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Скидки товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/11/06
Author: Bakhtadze Natalya
Creation date: 10/11/06

------------------------------------------------------------------------*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-mode-obj as character no-undo . /*g__Object all cmp "db":U*/
define input parameter p-gds-code as integer no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-pos-type as character no-undo .
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
define INPUT-OUTPUT parameter table for tt0-dis-gds-rule.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Скидки товара на объекте ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/disrules.i work }
{ ref/disgdsru.i "interface" parparentproc temp-odisc }
{ cmp/goa-list.i goa-list def "new shared" }

define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as CHARACTER no-undo.
define variable ini-title as char no-undo.
define variable temp-doc-rec as recid no-undo.
define variable dops as character no-undo.
define variable dopst as character no-undo.
define variable v-curr-obj-type like ub.dis-gds-rule.obj-type no-undo .
define variable v-curr-obj-code like ub.dis-gds-rule.obj-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-tab-order as character no-undo .
DEFINE VARIABLE dflt-cd AS CHARACTER NO-UNDO.
define variable loc-glob as logical no-undo .
define variable loc-firm as logical no-undo .
define variable loc-object as logical no-undo .
define variable v-grp-code as integer no-undo.
define variable v-rec-list as character no-undo init ''.

define buffer buf_goods for ub.goods.

{ ref/send-ref.i dops dopst }
{ gbl/get-regf.i }
{ cmp/gds-list.i gds-list def "new shared" }

&scoped-define  disgdsru-type-get-error message "Ошибка при определении названия и типа скидки товара на объекте!" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  gdsorule-num-get-error message "Ошибка при определении значения скидки товара на объекте!" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

&SCOPED-DEFINE cd-type-code temp-odisc.pos-type

&SCOPED-DEFINE label-clmn_2 'Тип скидки'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-odisc

/* Definitions for BROWSE br-dis-gds                                    */
&Scoped-define FIELDS-IN-QUERY-br-dis-gds temp-odisc.templ-rl-root disgdsru-get-disc-label(temp-odisc.templ-rl-root) temp-odisc.rule-num temp-odisc.nonunique get-objregion(temp-odisc.obj-type, temp-odisc.obj-code) {&cd-type-name} temp-odisc.rl-root
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-gds
&Scoped-define SELF-NAME br-dis-gds
&Scoped-define QUERY-STRING-br-dis-gds FOR EACH temp-odisc NO-LOCK
&Scoped-define OPEN-QUERY-br-dis-gds OPEN QUERY {&SELF-NAME} FOR EACH temp-odisc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-dis-gds temp-odisc
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-gds temp-odisc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-dis-gds}

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

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-add
       MENU-ITEM m_pos-type     LABEL "m_pos-type"
       MENU-ITEM m_no-pos       LABEL "По накладной"
       MENU-ITEM m_bo           LABEL "Бэкофис"       .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить скидку товара".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить скидку товара".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  скидку товара".

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

DEFINE VARIABLE goods-artic AS CHARACTER FORMAT "X(16)":U
      VIEW-AS TEXT
     SIZE 16.4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Goods-dsc-name AS CHARACTER FORMAT "X(60)":U
      VIEW-AS TEXT
     SIZE 61.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-gds-code AS INTEGER FORMAT ">>>>>>>>>>":U INITIAL 0
      VIEW-AS TEXT
     SIZE 11 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-prod-code AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-prod-name AS CHARACTER FORMAT "X(60)":U
      VIEW-AS TEXT
     SIZE 46.8 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-prod-type AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 3.8 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE RS-p-mode AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Текущий", "1",
"Объекты фирмы", "2",
"Объекты БД", "3"
     SIZE 16.9 BY 2 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-gds FOR
      temp-odisc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-gds Dialog-Frame _FREEFORM
  QUERY br-dis-gds DISPLAY
      temp-odisc.templ-rl-root COLUMN-LABEL "" FORMAT ">9":U
disgdsru-get-disc-label(temp-odisc.templ-rl-root) COLUMN-LABEL {&label-clmn_2} FORMAT "X(255)":U WIDTH 50
temp-odisc.rule-num COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9":U
temp-odisc.nonunique COLUMN-LABEL "Детализ." FORMAT "X(11)":U
get-objregion(temp-odisc.obj-type, temp-odisc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
{&cd-type-name} FORMAT "X(15)":U COLUMN-LABEL "Место!использ."
temp-odisc.rl-root COLUMN-LABEL "№ корн.!правила" FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.8 BY 15.5
         FONT 4.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1 COL 95
     RS-p-mode AT ROW 2.33 COL 81.5 NO-LABEL
     br-dis-gds AT ROW 4.47 COL 1
     goods-artic AT ROW 2.13 COL 1.9 NO-LABEL
     Goods-dsc-name AT ROW 2.13 COL 19 NO-LABEL
     goods-gds-code AT ROW 3.3 COL 1.8 NO-LABEL
     goods-prod-type AT ROW 3.3 COL 19 NO-LABEL
     goods-prod-code AT ROW 3.3 COL 23.4 NO-LABEL
     goods-prod-name AT ROW 3.3 COL 33.8 NO-LABEL
     "Объекты:" VIEW-AS TEXT
          SIZE 11.9 BY .93 AT ROW 1.13 COL 81.6
          FGCOLOR 4
     SPACE(6.30) SKIP(17.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Скидки товара".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-odisc T "?" NO-UNDO ub dis-gds-rule
      ADDITIONAL-FIELDS:
          field rule-label as character
      END-FIELDS.
      TABLE: tt0-dis-gds-rule T "?" NO-UNDO ub dis-gds-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-gds RS-p-mode Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.

/* SETTINGS FOR BROWSE br-dis-gds IN FRAME Dialog-Frame
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-gds
/* Query rebuild information for BROWSE br-dis-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-odisc NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-dis-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Скидки товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  if add-option = '':U then do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if add-option = '':U then return no-apply.
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
define variable jj as integer no-undo .
define variable v-rule-label as character no-undo .
  if not avail temp-odisc then return no-apply.
    run disgdsru-name in this-procedure
      (input  temp-odisc.templ-rl-root        /* p-templ-rl-root           */
      ,output v-rule-label          /* p-label          */
      ) no-error .
    if error-status :error then do:
      return no-apply .
    end.
  loc#log = no.
  if temp-odisc.obj-type = ""
  and temp-odisc.obj-code = 0
  and v-cntxt-db-num > 0
  then do:
    message
    "Нельзя удалять в УБД скидки, которые действуют ГЛОБАЛЬНО или на ФИРМЕ"
    view-as alert-box error .
    undo, return no-apply.
  end.
&scop cd-type-code temp-odisc.pos-type
  message
  substitute("Вы уверены, что хотите удалить скидку &1 (место использования &2) на &3&4&6для товара &5"
           ,v-rule-label
           ,{&cd-type-name}
           ,temp-odisc.obj-type
           ,temp-odisc.obj-code
           ,goods-dsc-name
           , {&new-line})
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


&Scoped-define BROWSE-NAME br-dis-gds
&Scoped-define SELF-NAME br-dis-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-gds Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-dis-gds IN FRAME Dialog-Frame
DO:
  if not avail temp-odisc then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-gds Dialog-Frame
ON RETURN OF br-dis-gds IN FRAME Dialog-Frame
DO:
  if not avail temp-odisc then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-gds Dialog-Frame
ON VALUE-CHANGED OF br-dis-gds IN FRAME Dialog-Frame
DO:
  IF v-cntxt-db-num > 0
  AND (temp-odisc.obj-type = {&cmp}
  OR temp-odisc.obj-type = '':U) THEN DO:
     DISABLE
     b-chg
     with FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      enable
      b-chg WHEN (p-mode <> {&lookup} and p-mode-obj = {&g___object})
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
    for each temp-odisc:
      if p-mode = {&update}
      and (temp-odisc.obj-type = p-obj-type
          and
          temp-odisc.obj-code = p-obj-code)
      or temp-odisc.obj-type = {&cmp}
      or temp-odisc.obj-type = ""  then.
      else
      delete temp-odisc.
    end.
    run MyENable in this-procedure .
    RUn init-proc in this-procedure ( input p-mode-obj).
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
  assign
  loc-glob = no
  loc-firm = no
  loc-object = no
  .
  for first buf_goods fields(grp-code) no-lock
       where buf_goods.gds-code = p-gds-code:
    v-grp-code = buf_goods.grp-code.
  end.
  if v-cntxt-db-num = 0 then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_gds-discount_global_work':U
      {&cntxt-global}
      0
      '':U
      0
      0
      v-grp-code
      0
      false
      loc-glob
      }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_gds-discount_firm_work':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      v-grp-code
      0
      false
      loc-firm
      }

   end.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_gds-discount_object_work':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      v-grp-code
      0
      false
      loc-object
    }
  if ((if v-cntxt-db-num = 0 and loc-glob then 1 else 0) +
  (if v-cntxt-db-num = 0 and loc-firm then 1 else 0) +
  (if loc-object then 1 else 0)) = 0
  and p-mode <> {&lookup}
  then do:
    message
    "У Вас отсутствуют права на назначение скидки на товар как по объекту, так и глобально" skip
    "либо Вы находитесь в БД, в которой их назначить невозможно"
    view-as alert-box error .
    undo, return.
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
    if v-cntxt-db-num > 0 then do:
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
  end.
  for each  temp-odisc share-lock:
    delete temp-odisc.
  end.
  RUN MyEnable in this-procedure .
  Run init-proc in this-procedure ( input p-mode-obj).
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
define variable v-rule-label as character no-undo .         /* лабел атрибута    */
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer buf_prods for ub.clients.
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
      and temp-odisc.obj-code = v-cntxt-host-code-obj)
      then do:
  end.
  else do:
    delete temp-odisc.
  end.
end.
if p-mode <> {&add-def} then do:
  find first buf_goods where
           buf_goods.gds-code =  p-gds-code no-lock no-error .
  find first buf_prods where
              buf_prods.obj-code =  buf_goods.prod-code
          and buf_prods.obj-type =  buf_goods.prod-type  no-lock no-error .

  Assign
  Goods-dsc-name = buf_Goods.gds-name
  goods-artic    = buf_goods.artic
  goods-gds-code = buf_goods.gds-code
  goods-prod-type = buf_goods.prod-type
  goods-prod-code = buf_goods.prod-code
  goods-prod-name = buf_prods.obj-name
  .
  display
  Goods-dsc-name
  goods-gds-code
  goods-artic
  goods-prod-type
  goods-prod-code
  goods-prod-name
  with frame {&frame-name}  .
end.

  for each tt0-dis-gds-rule no-lock
  where tt0-dis-gds-rule.gds-code = p-gds-code :

      if tt0-dis-gds-rule.discnt-role  = '':U and
         tt0-dis-gds-rule.pos-type     = '':U and
         tt0-dis-gds-rule.nonunique    = '':U then next .

      if pp-mode = {&g___object} and
        (tt0-dis-gds-rule.obj-type = {&shop} or tt0-dis-gds-rule.obj-type = {&stock}) and
        not (tt0-dis-gds-rule.obj-code = p-obj-code and tt0-dis-gds-rule.obj-type = p-obj-type) and
        not (tt0-dis-gds-rule.obj-type = {&cmp}) and
        not (tt0-dis-gds-rule.obj-type = "") then next.

      /*если по объекту или фирме, а привязка к правилу другой фирмы*/
      if ( pp-mode = {&g___object} or pp-mode = {&cmp} ) and
         ( tt0-dis-gds-rule.obj-type = {&cmp} and not tt0-dis-gds-rule.obj-code = v-host-code ) then next.

      if tt0-dis-gds-rule.obj-type <> "" and tt0-dis-gds-rule.obj-type <>{&cmp} then do:
        if pp-mode = {&cmp} then do:
          find first buf_clients no-lock where
                  buf_Clients.obj-type = tt0-dis-gds-rule.obj-type
                  and buf_Clients.obj-code = tt0-dis-gds-rule.obj-code no-error .
              if not avail buf_Clients or buf_Clients.host-code <> v-host-code then next.
        end.
        if pp-mode = "db":U then do:
          find first buf_clients no-lock where
                  buf_Clients.obj-type = tt0-dis-gds-rule.obj-type
                  and buf_Clients.obj-code = tt0-dis-gds-rule.obj-code no-error .
              if not avail buf_Clients or buf_Clients.db-num <> v-cntxt-db-num then next.
        end.
    end.

      if p-pos-type <> '':U and p-pos-type <> tt0-dis-gds-rule.pos-type then next.

      run disgdsru-name ( input tt0-dis-gds-rule.templ-rl-root, output v-rule-label ).

    find first temp-odisc where
              temp-odisc.discnt-role = tt0-dis-gds-rule.discnt-role
          AND temp-odisc.obj-code = tt0-dis-gds-rule.obj-code
          AND temp-odisc.obj-type = tt0-dis-gds-rule.obj-type
          AND temp-odisc.gds-code = tt0-dis-gds-rule.gds-code
          AND temp-odisc.nonunique = tt0-dis-gds-rule.nonunique
          AND temp-odisc.pos-type = tt0-dis-gds-rule.pos-type
          no-error.
    if not available temp-odisc then do:
      create temp-odisc.
      assign
      temp-odisc.obj-code = tt0-dis-gds-rule.obj-code
      temp-odisc.obj-type = tt0-dis-gds-rule.obj-type
      temp-odisc.gds-code = tt0-dis-gds-rule.gds-code
      temp-odisc.pos-type = tt0-dis-gds-rule.pos-type
      temp-odisc.nonunique = tt0-dis-gds-rule.nonunique
      temp-odisc.discnt-role = tt0-dis-gds-rule.discnt-role
      .
    end.
      assign
    temp-odisc.templ-rl-root = tt0-dis-gds-rule.templ-rl-root
    temp-odisc.time-templ-rl-root = tt0-dis-gds-rule.time-templ-rl-root
    temp-odisc.rule-num =  tt0-dis-gds-rule.rule-num
    temp-odisc.rule-label = v-rule-label
    temp-odisc.rl-root = tt0-dis-gds-rule.rl-root
    .
  end.   /* for each tt0-dis-gds-rule */

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
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.
v-h = br-dis-gds:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
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
assign
v-tab-order = "b-exit,b-quit,b-add,b-lookup,b-chg,b-del,b-help,br-dis-gds".
assign
rs-p-mode:radio-buttons in frame {&frame-name} = "Текущий" + {&comma-char} + {&g___object} + {&comma-char} +
                        "Объекты фирмы" + {&comma-char} + {&cmp} + {&comma-char} +
                        "Объекты БД" + {&comma-char} + "db" +
                        (if v-cntxt-db-num = 0 then ({&comma-char} + "Все объекты" + {&comma-char} + {&all}) else "":U)
                        .
RS-p-mode =  p-mode-obj.
DISPLAY
Goods-dsc-name
goods-gds-code
goods-artic
RS-p-mode
WITH FRAME {&frame-name}.
ENABLE
b-exit when (p-mode <> {&lookup} and p-mode-obj = {&g___object})
b-quit
b-del when (p-mode <> {&lookup} and p-mode-obj = {&g___object})
b-add when (p-mode <> {&lookup} and p-mode-obj = {&g___object})
b-chg when (p-mode <> {&lookup} and p-mode-obj = {&g___object})
b-lookup
b-help br-dis-gds Goods-dsc-name goods-gds-code goods-artic
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
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "ENTRY" to br-dis-gds.
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
define variable v-discnt-role as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_temp-odisc for temp-odisc.
CASE p-add:
  when yes then do:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "cd-type-list"
                        ,INPUT (if v-cntxt-db-num = 0 and loc-glob  then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 and loc-firm  then 1 else 0)
                        ,INPUT (if loc-object then 1 else 0)
                        ,input {&table_dis-gds-rule}
                        ,input '':U
                        ,input ?
                        ,INPUT p-pos-type
                        ,input '':U
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
      v-obj-type = trim(substring(var-region, 1, 3))
      v-obj-code = integer(substring(var-region, 4))
      v-host-code = (if var-region begins {&cmp}
                     then integer(substring(var-region, 4))
                     else 0)
      .
      if v-host-code = 0
       and v-obj-type <> '':U then do:
        { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
      end.

    end.
    else do:
      if buf_dis-cfg-rule.has-obj = 1 then do:
        assign
        v-obj-type = p-obj-type
        v-obj-code = p-obj-code
        .
      end.
      if buf_dis-cfg-rule.has-host = 1 then do:
        define variable v-host-code as integer no-undo .
        { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
        assign
        v-obj-type = {&cmp}
        v-obj-code = v-host-code
        .
      end.
      if buf_dis-cfg-rule.has-glob = 1 then do:
        assign
        v-obj-type = '':U
        v-obj-code = 0
        .
      end.
    end.
  end. /*when add*/
  when no then do:
    find first buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
          and buf_dis-cfg-rule.discnt-role = temp-odisc.discnt-role
          and buf_dis-cfg-rule.pos-type = temp-odisc.pos-type
          and buf_dis-cfg-rule.templ-rl-root = temp-odisc.templ-rl-root
          no-error .
    if available buf_dis-cfg-rule then do:
      assign
      v-cfg-nonunique = buf_dis-cfg-rule.nonunique.
    end.
    v-rule-num  = temp-odisc.rule-num.
    v-nonunique = temp-odisc.nonunique.
  end. /*when chg*/
END CASE.
if v-cfg-nonunique <> ''
and num-entries(v-cfg-nonunique, ".") > 1
then do:
  case v-cfg-nonunique:
    when "bar-code.b-code" then do:
      /*надо запустить выбор баркода*/
      /*тут мы можем выбрать только ОДИН основной/неосновной код и к НЕМУ кучу дополнительных,
        либо кучу дополнительных от одного основного/неосновного кода*/
      define variable v-rec-num  as integer   no-undo .
      define variable v-rec-cnt  as integer   no-undo init 0 .
      define variable v-rec-osn  as character no-undo init '' .
      define variable v-rec-dk   as character no-undo init '' .
      define buffer buf_bar-code for ub.bar-code.
      define buffer buf_prod-bc for ub.prod-bc.
      if p-add then do:
      run ref/alt-cds.w (
           input parParentProc
          ,input p-obj-type
          ,input p-obj-code
            ,input "all-no-part-dk"
          ,input p-gds-code
          ,input p-gds-code
          ,output v-rec-list) no-error.
      if v-rec-list = '' then undo, return error.
        /*посчитаем сколько НЕ доп кодов выбрано*/
        do v-rec-num = 1 to num-entries( v-rec-list, {&comma-char} ) :
            if not entry( v-rec-num, v-rec-list, {&comma-char} ) begins "dk" then do:
               assign
                 v-rec-osn = entry( v-rec-num, v-rec-list, {&comma-char} )
                 v-rec-cnt = v-rec-cnt + 1
               .
            end.
            else v-rec-dk = substring( entry( v-rec-num, v-rec-list, {&comma-char} ), 3 ) .
        end.

        /*если больше одного НЕ доп кода, то ошибка*/
        if v-rec-cnt > 1 then do:
          message
          "ВЫ выбрали более одного осн/неосн баркода"
          view-as alert-box Error.
          undo, return error .
        end.
        /*если основной/неосновной код выбран то ищем в bar-code
          если нет, то в prod-bc*/
        if v-rec-cnt = 1 then do:
            find first buf_bar-code no-lock where recid(buf_bar-code) = integer(v-rec-osn) no-error .
            if not avail buf_bar-code then do:
                message
                "Не найден выбранный осн/неосн баркод."
                view-as alert-box Error.
                undo, return error .
            end.
            assign
              v-cfg-nonunique = "@" + string(buf_bar-code.b-code)
              v-nonunique = string(buf_bar-code.b-code)
            .
        end.
        if not v-rec-dk = '' then do:
            find first buf_prod-bc no-lock where recid(buf_prod-bc) = integer(v-rec-dk) no-error .
            if not avail buf_prod-bc then do:
        message
                "Не найден выбранный дополнительный баркод."
        view-as alert-box Error.
        undo, return error .
      end.
            /*Доп коды не от выбранного основного кода*/
            if v-rec-cnt = 1 and not buf_bar-code.b-code = buf_prod-bc.b-code then do:
                message
                "Неверные дополнительные коды ."
                view-as alert-box Error.
                undo, return error .
            end.
            assign
              v-cfg-nonunique = "@" + string(buf_prod-bc.b-code)
              v-nonunique = string(buf_prod-bc.b-code)
            .
        end.
     end.
      else do:
        v-cfg-nonunique = "@" + temp-odisc.nonunique.
        v-nonunique = string(temp-odisc.nonunique).
      end.
    end.
    otherwise do:
      message
      substitute("Неизвестная опция для дифференциации скидки внутри одного товара=&1", v-cfg-nonunique)
      view-as alert-box error .
      return error.
    end.
  end case.
end.

run disgdsru-edit in this-procedure (
                                       input (if p-add then {&add-def} else {&update})
                                      ,input p-gds-code
                                      ,input (if p-add then v-obj-type else temp-odisc.obj-type)
                                      ,input (if p-add then v-obj-code else temp-odisc.obj-code)
                                      ,INPUT (if p-add then p-pos-type else temp-odisc.pos-type)
                                      ,input (if p-add then v-discnt-role else temp-odisc.discnt-role)
                                      ,input (if p-add then v-templ-rl-root else temp-odisc.templ-rl-root)
                                      ,input (if p-add then v-time-templ-rl-root else temp-odisc.time-templ-rl-root)
                                      ,input v-cfg-nonunique
                                      ,input 1
                                      ,input-output v-rule-num
                                      ,input-output v-nonunique
                                      ,output v-setted ) no-error.
if not v-setted then return error.
run temp-disgdsru-write in this-procedure (
                                           input p-gds-code
                                          ,input (if p-add then v-obj-type else temp-odisc.obj-type)
                                          ,input (if p-add then v-obj-code else temp-odisc.obj-code)
                                          ,input (if p-add then p-pos-type else temp-odisc.pos-type)
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
  br-dis-gds:refresh() in frame {&frame-name} no-error .
END.
assign
added = no.
if p-add = yes then do:
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  find first buf_temp-odisc no-lock where
            buf_temp-odisc.obj-type = v-obj-type
        AND buf_temp-odisc.obj-code = v-obj-code
        AND buf_temp-odisc.pos-type = add-option
        AND buf_temp-odisc.discnt-role = v-discnt-role
        AND buf_temp-odisc.nonunique = v-nonunique
      no-error.
  add-option = '':U.
  if avail buf_temp-odisc then
      temp-doc-rec = recid(buf_temp-odisc).
      else temp-doc-rec = ?.
  reposition br-dis-gds to recid temp-doc-rec no-error.
  if error-status:error then return no-apply.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lookup Dialog-Frame
PROCEDURE proc-b-lookup :
define variable disc-label as character no-undo .         /*лабел скидки*/

run disgdsru-name in this-procedure (
                                      input temp-odisc.templ-rl-root
                                    , output disc-label
                                ) no-error.
IF ERROR-STATUS:ERROR THEN DO:
    {&disgdsru-type-get-error}
    return error.
END.
run dsp-dis-rule in this-procedure  (
                                       input temp-odisc.gds-code
                                      ,input temp-odisc.nonunique
                                      ,input temp-odisc.obj-type
                                      ,input temp-odisc.obj-code
                                      ,input temp-odisc.discnt-role
                                      ,input temp-odisc.pos-type
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
         temp-odisc.gds-code = p-gds-code
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile ):
   find first tt0-dis-gds-rule NO-LOCK WHERE
          tt0-dis-gds-rule.gds-code = temp-odisc.gds-code
    AND   tt0-dis-gds-rule.obj-type = temp-odisc.obj-type
    AND   tt0-dis-gds-rule.obj-code = temp-odisc.obj-code
    AND   tt0-dis-gds-rule.pos-type = temp-odisc.pos-type
    AND   tt0-dis-gds-rule.discnt-role = temp-odisc.discnt-role
    AND   tt0-dis-gds-rule.nonunique = temp-odisc.nonunique
    no-error.
  assign
  v-updated = no.
  if available  tt0-dis-gds-rule then do:
    BUFFER-COMPARE temp-odisc
                TO tt0-dis-gds-rule
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
    if temp-odisc.obj-type = {&cmp} and v-cntxt-db-num <> 0 then do:
      message
      "Нельзя редактировать в УБД скидки, которые действуют ГЛОБАЛЬНО или на ФИРМЕ"
      view-as alert-box error.
      next.
    end.
    if temp-odisc.obj-type = '':U and v-cntxt-db-num <> 0 then do:
      message
      "Нельзя редактировать в УБД скидки, которые действуют ГЛОБАЛЬНО или на ФИРМЕ"
      view-as alert-box error.
      next.
    end.
    run tt0-disgdsru-write in this-procedure(
                                     input p-gds-code
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
      "Ошибка при сохранении скидки на товара на объекте" skip
      "товар" p-gds-code skip
      "объект" temp-odisc.obj-type temp-odisc.obj-code
      "Тип скидки" temp-odisc.discnt-role
      "POS" temp-odisc.pos-type
      view-as alert-box  error .
      undo, return error  .
    end.
    updated = yes.
  end.
  ASSIGN
  p-updated = v-updated OR p-updated.
End.
FOR EACH tt0-dis-gds-rule where
         tt0-dis-gds-rule.gds-code = p-gds-code
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile ):

  if p-pos-type <> '':U
  and p-pos-type <> tt0-dis-gds-rule.pos-type then do:
    NEXT.
  end.
  FIND FIRST temp-odisc NO-LOCK WHERE
            temp-odisc.gds-code = tt0-dis-gds-rule.gds-code
        AND temp-odisc.obj-type = tt0-dis-gds-rule.obj-type
        AND temp-odisc.obj-code = tt0-dis-gds-rule.obj-code
        AND temp-odisc.pos-type = tt0-dis-gds-rule.pos-type
        AND temp-odisc.discnt-role = tt0-dis-gds-rule.discnt-role
        AND temp-odisc.nonunique = tt0-dis-gds-rule.nonunique
        NO-ERROR.
    IF NOT AVAILABLE temp-odisc THEN DO:
      if tt0-dis-gds-rule.obj-type = {&cmp} and v-cntxt-db-num <> 0 then do:
        message
        "Нельзя редактировать в УБД скидки, которые действуют ГЛОБАЛЬНО или на ФИРМЕ"
        view-as alert-box error.
        next.
      end.
      if tt0-dis-gds-rule.obj-type = '':U and v-cntxt-db-num <> 0 then do:
        message
        "Нельзя редактировать в УБД скидки, которые действуют ГЛОБАЛЬНО или на ФИРМЕ"
        view-as alert-box error.
        next.
      end.
      DELETE tt0-dis-gds-rule.
      assign
      v-deleted = yes.
      ASSIGN
      p-updated = (v-deleted OR p-updated).
    END.
END.
if p-updated
and p-update-instantly then do:
  run ref/disgdsr1.p (
                     input p-mode + {&comma-char} + v-rec-list
                    ,input p-gds-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-dis-gds-rule
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении скидок товара на объекте:&1&2&1&3"
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-disgdsru-write Dialog-Frame
PROCEDURE temp-disgdsru-write :
do
  on error undo, return error
  :

    define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
    define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
    define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
    define input parameter p-pos-type like ub.dis-gds-rule.pos-type  no-undo .
    define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
    define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
    define input parameter p-was-nonunique like ub.dis-gds-rule.nonunique no-undo .
    define input parameter p-rule-num  like ub.dis-gds-rule.rule-num no-undo .
    define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .
    define variable v-rule-label as character no-undo .
    define buffer buf_temp-odisc for temp-odisc .
    define buffer buf_Dis-rule for ub.dis-rule.

    run disgdsru-name in this-procedure (
                                           input  p-templ-rl-root           /* p-templ-rl-root           */
                                          ,output v-rule-label          /* p-label          */
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-odisc exclusive-lock where
               buf_temp-odisc.gds-code  = p-gds-code
           AND buf_temp-odisc.obj-type  = p-obj-type
           AND buf_temp-odisc.obj-code  = p-obj-code
           AND buf_temp-odisc.pos-type  = p-pos-type
           AND buf_temp-odisc.discnt-role = p-discnt-role
           AND buf_temp-odisc.nonunique = (if p-was-nonunique = ? then p-nonunique else p-was-nonunique)
           no-error no-wait .
    if not available buf_temp-odisc then do:
      create buf_temp-odisc .
      assign
      buf_temp-odisc.gds-code  = p-gds-code
      buf_temp-odisc.obj-type  = p-obj-type
      buf_temp-odisc.obj-code  = p-obj-code
      buf_temp-odisc.pos-type  = p-pos-type
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
    buf_temp-odisc.templ-rl-root = p-templ-rl-root
    buf_temp-odisc.rl-root = buf_dis-rule.rl-root
    buf_temp-odisc.nonunique = p-nonunique
    no-error.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tt0-disgdsru-write Dialog-Frame
PROCEDURE tt0-disgdsru-write :
do
on error undo, return error
:

  define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
  define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-gds-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-gds-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .

  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-gds-rule for tt0-dis-gds-rule .
  define buffer buf_dis-rule for ub.dis-rule.

  run disgdsru-name in this-procedure (
                                      input  p-templ-rl-root           /* p-templ-rl-root           */
                                      ,output v-rule-label          /* p-label          */
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.

  find first buf_tt0-dis-gds-rule exclusive-lock where
              buf_tt0-dis-gds-rule.gds-code  = p-gds-code
          AND buf_tt0-dis-gds-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-gds-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-gds-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-gds-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-gds-rule then do:
    create buf_tt0-dis-gds-rule .
    assign
    buf_tt0-dis-gds-rule.gds-code  = p-gds-code
    buf_tt0-dis-gds-rule.obj-type  = p-obj-type
    buf_tt0-dis-gds-rule.obj-code  = p-obj-code
    buf_tt0-dis-gds-rule.pos-type  = p-pos-type
    buf_tt0-dis-gds-rule.nonunique = p-nonunique
    buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rule-num = p-rule-num
  buf_tt0-dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-gds-rule.nonunique = p-nonunique
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rl-root = buf_Dis-rule.rl-root
  no-error.
  release buf_tt0-dis-gds-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME