&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients-obj FOR ub.clients.
DEFINE TEMP-TABLE temp-clients  NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE temp-dis-rule NO-UNDO LIKE ub.dis-rule
       field old-des as character.
DEFINE TEMP-TABLE temp-cpdisc NO-UNDO LIKE ub.dis-cp-rule
       field rule-label as character.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установка/удаление скидок по видам кассовых платежей

Автор: Мазуров Виталий Александрович
Дата создания: 06/03/11
Author: Mazurov Vitaly
Creation date: 06/03/11

*/


/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-subject as character no-undo.
define input parameter p-host-code like ub.dis-cp-rule.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo. /*текущий объект*/
define input parameter parobj-code like ub.clients.obj-code no-undo. /*текущий объект*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Установка/удаление скидок по видам кассовых платежей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/bitoper.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ ref/temp-dsc.i "NEW SHARED" ~{&table_dis-cp-rule~} parbj-type parobj-code }
{ ref/discprul.i interface parparentproc }
/*{ ref/disgdsru.i interface parparentproc temp-disc }*/
{ gbl/get-regf.i }
{ trg/new-bcod.i }
{ cmp/trg-def.i } /*определение переменных для просмотра лога pro-copy*/

&scoped-define  discpru-type-get-error message "Ошибка при определении названия и типа скидки на платеж!" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  discpru-value-get-error message "Ошибка при определении значения скидки на платеж!" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

define variable add-obj-type like ub.clients.obj-type no-undo .
define variable add-obj-code like ub.clients.obj-code no-undo .
define variable add-option   as character no-undo.
define variable updated      as logical   no-undo.
define variable temp-doc-rec as recid     no-undo.
define variable glog         as logical   no-undo .
define variable v-tab-order  as character no-undo.
define variable loc-glob     as logical   no-undo .
define variable loc-firm     as logical   no-undo .
define variable loc-object   as logical   no-undo .
define variable dflt-cd      as character no-undo .
define variable v-auto-go    as logical   no-undo init NO . /*Пакетный режим p-auto-go*/

define variable v-rid-list as character no-undo . /*список recid платежей*/

define temp-table tt-dis-rule       no-undo like ub.dis-rule.
define temp-table tt0-term_dis-rule no-undo like ub.dis-rule.
define temp-table old-temp-disc     no-undo like temp-disc.

define buffer del_temp-disc for temp-disc.

&SCOPED-DEFINE cd-type-code temp-disc.pos-type
&SCOPED-DEFINE cd-type-code2 del_temp-disc.pos-type
&SCOPED-DEFINE cd-type-name2 entry (lookup (~{&cd-type-code2~}, ~{&cd-type-codes~}), ~{&cd-type-codes-full~})

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-add

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-disc del_temp-disc

/* Definitions for BROWSE BR-add                                        */
&Scoped-define FIELDS-IN-QUERY-BR-add {&cd-type-name} discpru-get-disc-role-label (temp-disc.discnt-role) temp-disc.templ-rl-root temp-disc.time-templ-rl-root discpru-get-disc-label( INPUT temp-disc.templ-rl-root) temp-disc.rule-num get-objregion(temp-disc.obj-type, temp-disc.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-add
&Scoped-define SELF-NAME BR-add
&Scoped-define QUERY-STRING-BR-add FOR EACH temp-disc where temp-disc.action = yes NO-LOCK
&Scoped-define OPEN-QUERY-BR-add OPEN QUERY {&SELF-NAME} FOR EACH temp-disc where temp-disc.action = yes NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-add temp-disc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-add temp-disc


/* Definitions for BROWSE BR-del                                        */
&Scoped-define FIELDS-IN-QUERY-BR-del {&cd-type-name2} discpru-get-disc-role-label ( DEL_temp-disc.discnt-role) del_temp-disc.templ-rl-root del_temp-disc.time-templ-rl-root discpru-get-disc-label( INPUT del_temp-disc.templ-rl-root) del_temp-disc.rule-num get-objregion(del_temp-disc.obj-type, del_temp-disc.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-del
&Scoped-define SELF-NAME BR-del
&Scoped-define QUERY-STRING-BR-del FOR EACH del_temp-disc where del_temp-disc.action = no NO-LOCK
&Scoped-define OPEN-QUERY-BR-del OPEN QUERY {&SELF-NAME} FOR EACH del_temp-disc where del_temp-disc.action = no NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-del del_temp-disc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-del del_temp-disc

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-add}~
    ~{&OPEN-QUERY-BR-del}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-obj B-list B-Help b-add ~
B-chg B-del BR-add b-add-2 B-chg-2 B-del-2 BR-del

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

DEFINE MENU MENU-b-add-2
       MENU-ITEM m_pos-type-2   LABEL "m_pos-type-2"
       MENU-ITEM m_no-pos-2     LABEL "По накладной"
       MENU-ITEM m_bo-2         LABEL "Бэкофис"       .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Выбрать скидку для добавления".

DEFINE BUTTON b-add-2
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Выбрать скидку для удаления".

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg-2
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del-2
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit
     LABEL "&Ввод"
     SIZE 10 BY 1 TOOLTIP "Установить/изменить/удалить скидки по списку"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-list
     LABEL "&Список платежей"
     SIZE 20 BY 1 TOOLTIP "Создание списка".

DEFINE BUTTON B-obj
     LABEL "&Список объектов"
     SIZE 20 BY 1 TOOLTIP "Создание списка".

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-add FOR
      temp-disc SCROLLING.

DEFINE QUERY BR-del FOR
      del_temp-disc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-add Dialog-Frame _FREEFORM
  QUERY BR-add DISPLAY
      {&cd-type-name} column-label "Место!использ."  format "X(10)"
discpru-get-disc-role-label (temp-disc.discnt-role) column-label "Тип скидки" FORMAT "X(255)":U WIDTH 35
temp-disc.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
temp-disc.time-templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!типа!распис"
discpru-get-disc-label( INPUT temp-disc.templ-rl-root) FORMAT "X(255)":U WIDTH 45
temp-disc.rule-num COLUMN-LABEL "Код правила" FORMAT ">>>>>>>>9"
get-objregion(temp-disc.obj-type, temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут добавлены/изменены скидки".

DEFINE BROWSE BR-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-del Dialog-Frame _FREEFORM
  QUERY BR-del DISPLAY
      {&cd-type-name2}                               column-label "Место!использ."  format "X(10)"
      discpru-get-disc-role-label ( DEL_temp-disc.discnt-role) column-label "Тип скидки"      FORMAT "X(255)":U WIDTH 35
      del_temp-disc.templ-rl-root                    COLUMN-LABEL "Код!шаблона"     FORMAT ">>>>>>>>9":U
      del_temp-disc.time-templ-rl-root               COLUMN-LABEL "Код!типа!распис" FORMAT ">>>>>>>>9":U
      discpru-get-disc-label( INPUT del_temp-disc.templ-rl-root)                   FORMAT "X(255)":U WIDTH 45
      del_temp-disc.rule-num                         COLUMN-LABEL "Код правила"     FORMAT ">>>>>>>>9"
      get-objregion(del_temp-disc.obj-type, del_temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут удалены скидки".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-obj AT ROW 1 COL 26.5
     B-list AT ROW 1 COL 47.5
     B-Help AT ROW 1 COL 92
     b-add AT ROW 2.5 COL 1
     B-chg AT ROW 2.5 COL 11
     B-del AT ROW 2.5 COL 21
     BR-add AT ROW 3.5 COL 1
     b-add-2 AT ROW 12.75 COL 1
     B-chg-2 AT ROW 12.75 COL 11 WIDGET-ID 2
     B-del-2 AT ROW 12.75 COL 21
     BR-del AT ROW 14 COL 1
     SPACE(0.00) SKIP(0.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients-obj B "?" ? ub clients
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-add B-del Dialog-Frame */
/* BROWSE-TAB BR-del B-del-2 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.

ASSIGN
       b-add-2:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add-2:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-add
/* Query rebuild information for BROWSE BR-add
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-disc where temp-disc.action = yes NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-add */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-del
/* Query rebuild information for BROWSE BR-del
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH del_temp-disc where del_temp-disc.action = no NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-del */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
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
  run proc-b-add in this-procedure ( input add-option) no-error .
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-2 Dialog-Frame
ON CHOOSE OF b-add-2 IN FRAME Dialog-Frame /* Добавить */
DO:
  if add-option = '':U then do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-b-add-2 in this-procedure ( input add-option) no-error .
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  run proc-b-chg in this-procedure ( input "change":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg-2 Dialog-Frame
ON CHOOSE OF B-chg-2 IN FRAME Dialog-Frame /* Изменить */
DO:
  run proc-b-chg-2 in this-procedure ( input "change":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable loc#log as logical no-undo.
  if not avail temp-disc then return no-apply.
  loc#log = no.
  message
     "Вы уверены, что хотите удалить скидку" skip
     "из списка скидок подлежащих установке/изменению?" skip
  view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
  run temp-dsc-delete in this-procedure (
                                             input temp-disc.pos-type
                                            ,input temp-disc.discnt-role
                                            ,input temp-disc.nonunique
                                            ,input temp-disc.host-code
                                            ,input temp-disc.obj-type
                                            ,input temp-disc.obj-code
                                            ,input temp-disc.action
                                            ,output loc#log) no-error .

    if error-status:error or not loc#log then do:
        return no-apply.
    end.
     updated = yes.
    run init-proc in this-procedure .
    APPLY "ENTRY" to br-add.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-2 Dialog-Frame
ON CHOOSE OF B-del-2 IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable loc#log as logical no-undo.
  if not avail del_temp-disc then return no-apply.
  loc#log = no.
  message
     "Вы уверены, что хотите удалить скидку" skip
     "из списка скидок, подлежащих удалению?" skip
  view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
  run temp-dsc-delete in this-procedure (
                                             input del_temp-disc.pos-type
                                            ,input del_temp-disc.discnt-role
                                            ,input del_temp-disc.nonunique
                                            ,input del_temp-disc.host-code
                                            ,input del_temp-disc.obj-type
                                            ,input del_temp-disc.obj-code
                                            ,input del_temp-disc.action
                                            ,output loc#log) no-error .
    if error-status:error or not loc#log then do:
        return no-apply.
    end.
    updated = yes.
    run init-proc in this-procedure .
    APPLY "ENTRY" to br-del.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-b-exit IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-list Dialog-Frame
ON CHOOSE OF B-list IN FRAME Dialog-Frame /* Список платежей */
DO:
      run ref/cashpays.w (
          parparentproc
          ,"b-sel,b-mark"
          ,{&all}
          ,p-host-code
          ,parobj-type
          ,parobj-code
          ,output v-rid-list ) .

  assign
  b-list:label = "&Список платежей"
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame /* Список объектов */
DO:
  RUN proc-b-obj IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_bo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_bo Dialog-Frame
ON CHOOSE OF MENU-ITEM m_bo /* Бэкофис */
DO:
  add-option = {&cd-type-bo}.
  run proc-b-add in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_bo-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_bo-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_bo-2 /* Бэкофис */
DO:
    add-option = {&cd-type-bo}.
  run proc-b-add-2 in this-procedure ( input add-option ) no-error.
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
  run proc-b-add in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_no-pos-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_no-pos-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_no-pos-2 /* По накладной */
DO:
   add-option = {&cd-type-no-cd}.
  run proc-b-add-2 in this-procedure ( input add-option ) no-error.
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
  run proc-b-add in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_pos-typ e-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_pos-type-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_pos-type-2 /* m_pos-type-2 */
DO:
   add-option = dflt-cd.
  run proc-b-add-2 in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-add
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if lookup(par-subject, {&table_dis-cp-rule}) = 0 then do:

    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра par-subject" par-subject
    view-as alert-box error.
    return error.
  end.
  CASE par-subject:
    when {&table_dis-cp-rule}
    then do:
      if v-cntxt-db-num = 0 then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_cp-discount_global_work':U
          {&cntxt-global}
          0
          '':U
          0
          0
          0
          0
          false
          loc-glob
          }
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_cp-discount_firm_work':U
          {&cntxt-firm}
          v-cntxt-host-code-obj
          '':U
          0
          0
          0
          0
          false
          loc-firm
          }

      end.
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_cp-discount_object_work':U
        {&cntxt-object}
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        0
        0
        0
        false
        loc-object
      }
      if ((if v-cntxt-db-num = 0 and loc-glob then 1 else 0) +
      (if v-cntxt-db-num = 0 and loc-firm then 1 else 0) +
      (if loc-object then 1 else 0)) = 0 then do:
        message
        "У Вас отсутствуют права на назначение скидки на тип платежа как по объекту, так и по фирме и глобально" skip
        "либо Вы находитесь в БД, в которой их назначить невозможно"
        view-as alert-box error .
        undo, return.
      end.
    end.
  END CASE.
  find first X_clients-obj no-lock where
              X_clients-obj.obj-type = parobj-type AND
              X_clients-obj.obj-code = parobj-code no-error .
  if not avail X_clients-obj then do:
    message vss-workfile vss-revision vss-description skip
    "Неверное значение параметра parobj-type и/или parobj-code" parobj-type parobj-code
    view-as alert-box error.
    return error.
  end.
  RUN enable_UI in this-procedure .
  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-add Dialog-Frame
PROCEDURE choose-to-add :
define input parameter p-attr-code as character no-undo .

assign
add-option = p-attr-code
.
 APPLY "CHOOSE" to b-add in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-delete Dialog-Frame
PROCEDURE choose-to-delete :
define input parameter p-attr-code as character no-undo .

assign
add-option = p-attr-code
.
APPLY "CHOOSE" to b-add-2 in frame {&frame-name} .
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
  ENABLE B-exit b-quit B-obj B-list B-Help b-add B-chg B-del BR-add b-add-2
         B-chg-2 B-del-2 BR-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
assign
add-option = ""
add-obj-type = "":U
add-obj-code = 0
.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ch AS WIDGET-HANDLE NO-UNDO.
ch = br-add:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO ii = 1 TO br-add:NUM-COLUMNS IN FRAME {&FRAME-NAME}:
    ASSIGN
    ch:RESIZABLE = YES.
    ch = ch:NEXT-COLUMN.
END.


assign
b-add:MENU-MOUSE in frame {&frame-name} = 1
b-add-2:MENU-MOUSE in frame {&frame-name} = 1
.
RUN proc-title IN THIS-PROCEDURE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
/*Добавить скидки*/
PROCEDURE proc-b-add :
define input parameter p-pos-type as character no-undo.

define variable v-deleted       as logical   no-undo .
define variable v-rid           as character no-undo .
define variable v-rec           as recid     no-undo .
define variable v-cfg-nonunique as character no-undo .

define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_temp-disc    for temp-disc.

do
on error undo, return error :
  /*Выбор типов возможных скидок, возвращает RECID строки dis-cfg-rule (похоже справочник типов скидок)*/
  run ref/dis-pos.w ( input parparentproc
                     ,input "b-sel":U
                     ,input "cd-type-list"
                     ,input (if v-cntxt-db-num = 0 and loc-glob then 1 else 0)
                     ,input (if v-cntxt-db-num = 0 and loc-firm then 1 else 0)
                     ,input 1
                     ,input {&table_dis-cp-rule}
                     ,input '':U
                     ,input ?
                     ,input p-pos-type
                     ,input '':U
                     ,input-output v-rid ) no-error.
  /*Если ошибка или не выбрали, то завершаем добавление*/
  IF ERROR-STATUS:ERROR
  OR v-rid = '':U THEN DO:
    RETURN.
  END.

  find first buf_dis-cfg-rule where recid(buf_dis-cfg-rule) = int(v-rid) no-lock no-error.
  if not avail buf_dis-cfg-rule then do:
      RETURN.
  end.
  v-cfg-nonunique = substitute("@&1", buf_dis-cfg-rule.nonunique).

  /*Пишем скидку*/
  run temp-dsc-write in this-procedure (
                                         input yes /*p-add*/
                                        ,input buf_dis-cfg-rule.pos-type
                                        ,input buf_dis-cfg-rule.templ-rl-root
                                        ,input buf_dis-cfg-rule.time-templ-rl-root
                                        ,input buf_dis-cfg-rule.discnt-role
                                        ,input v-cfg-nonunique
                                        ,input p-host-code
                                        ,input parobj-type
                                        ,input parobj-code
                                        ,input 0
                                        ,input yes
                                        ,input-output v-rec
                                  ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    if not return-value = "not-set" then do:
      {&discpru-type-get-error}
    end.
    undo,  return error.
  END.
  updated = yes.
  find first buf_temp-disc no-lock where
            recid(buf_temp-disc) = v-rec no-error.
  if avail buf_temp-disc then
  temp-doc-rec = recid(buf_temp-disc).
  else temp-doc-rec = ?.
  Run init-proc in this-procedure no-error.
  if error-status:error then do:
    undo, return error.
  end.
  REPOSITION br-add to recid temp-doc-rec no-error.
  /*Добавляем/изменяем правила*/
  run proc-b-chg in this-procedure ( input "":U) no-error.
  if error-status:error then do:
      run temp-dsc-delete in this-procedure (
                                               input buf_dis-cfg-rule.pos-type
                                              ,input buf_dis-cfg-rule.discnt-role
                                              ,input v-cfg-nonunique
                                              ,input p-host-code
                                              ,input parobj-type
                                              ,input parobj-code
                                              ,input yes
                                              ,output v-deleted
                                              ) no-error .
    Run init-proc in this-procedure no-error.
    undo, return error.
  end.
  APPLY "ENTRY" to br-add in frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add-2 Dialog-Frame
PROCEDURE proc-b-add-2 :
define input parameter p-pos-type as character no-undo.
DEFINE VARIABLE v-deleted as logical no-undo .
define variable loc#log as logical no-undo.
define variable loc-action as logical no-undo.
define variable v-rid as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-cfg-nonunique as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .

define buffer buf_temp-disc for temp-disc.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.

CASE par-subject :
  WHEN {&table_dis-cp-rule} THEN DO:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "cd-type-list"
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT 1
                        ,input {&table_dis-cp-rule}
                        ,input '':U
                        ,input ?
                        ,INPUT p-pos-type
                        ,input '':U
                        ,INPUT-OUTPUT v-rid) NO-ERROR.
    IF ERROR-STATUS:ERROR
    OR v-rid = '':U THEN DO:
      RETURN.
    END.

    find first buf_dis-cfg-rule where recid(buf_dis-cfg-rule) = int(v-rid) no-lock no-error.
    if not avail buf_dis-cfg-rule then do:
        RETURN.
    end.
    v-cfg-nonunique = substitute("@&1", buf_dis-cfg-rule.nonunique).

    run temp-dsc-write in this-procedure (
                                            input yes /*p-add*/
                                           ,input buf_dis-cfg-rule.pos-type
                                           ,input buf_dis-cfg-rule.templ-rl-root
                                           ,input buf_dis-cfg-rule.time-templ-rl-root
                                           ,input buf_dis-cfg-rule.discnt-role
                                           ,input v-cfg-nonunique
                                           ,input p-host-code
                                           ,input parobj-type
                                           ,input parobj-code
                                           ,input v-rule-num
                                           ,input no
                                           ,input-output v-rec )  no-error .
     IF ERROR-STATUS:ERROR THEN DO:
      if not return-value = "not-set" then do:
        {&discpru-type-get-error}
        return error .
      end .
    END .
    define buffer bb_temp-disc for temp-disc .
    find first bb_temp-disc no-error .
  END .
END CASE .
updated = yes .
find first buf_temp-disc no-lock where
          recid(buf_temp-disc) = v-rec no-error .
if avail buf_temp-disc then
  temp-doc-rec = recid(buf_temp-disc) .
  else temp-doc-rec = ? .
Run init-proc in this-procedure .
reposition BR-del to recid temp-doc-rec no-error .
if error-status:error then return error .

run proc-b-chg-2 in this-procedure ( input "":U) no-error .
if error-status:error then do:
    run temp-dsc-delete in this-procedure (
                                             input buf_dis-cfg-rule.pos-type
                                            ,input buf_dis-cfg-rule.discnt-role
                                            ,input v-cfg-nonunique
                                            ,input p-host-code
                                            ,input parobj-type
                                            ,input parobj-code
                                            ,input no
                                            ,output v-deleted
                                            ) no-error .
  Run init-proc in this-procedure no-error .
  undo, return error .
end .
APPLY "ENTRY" to br-del in frame {&frame-name} .
END PROCEDURE .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
define input parameter p-mode as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
if not avail temp-disc then return error .
  RUN temp-dsc-VALUE IN THIS-PROCEDURE (
                                       input temp-disc.pos-type
                                      ,input temp-disc.templ-rl-root
                                      ,input temp-disc.time-templ-rl-root
                                      ,input temp-disc.discnt-role
                                      ,input temp-disc.nonunique
                                      ,input temp-disc.host-code
                                      ,input temp-disc.obj-type
                                      ,input temp-disc.obj-code
                                      ,input {&add-def} /*p-0mode*/
                                      ,input p-mode
                                      ,input recid(temp-disc)
                                      ,OUTPUT v-rule-num
                                      ,output v-nonunique
                                      ) NO-ERROR .
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> "not-set":U then do:
      {&discpru-value-get-error}
      RETURN error .
    end .
  END .
  if return-value = "not-set":U
  and p-mode <> "change":U then do:
    delete temp-disc.
    glog = br-add:refresh() in frame {&frame-name} no-error .
    return .
  end .
  v-rec = recid(temp-disc) .
  run temp-dsc-write (
                       input no /*p-add*/
                      ,input temp-disc.pos-type
                      ,input temp-disc.templ-rl-root
                      ,input temp-disc.time-templ-rl-root
                      ,input temp-disc.discnt-role
                      ,input temp-disc.nonunique
                      ,input temp-disc.host-code
                      ,input temp-disc.obj-type
                      ,input temp-disc.obj-code
                      ,input v-rule-num
                      ,input temp-disc.action
                      ,input-output v-rec
                      ) no-error .
  IF not error-status:error then do:
    assign
    updated = yes
    .
  END .
  glog = br-add:refresh() in frame {&frame-name} no-error .
  APPLY "ENTRY" to br-add.
END PROCEDURE .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg-2 Dialog-Frame
PROCEDURE proc-b-chg-2 :
define input parameter p-mode as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
if not avail del_temp-disc then return error .
  RUN temp-dsc-VALUE IN THIS-PROCEDURE (
                                       input del_temp-disc.pos-type
                                      ,input del_temp-disc.templ-rl-root
                                      ,input del_temp-disc.time-templ-rl-root
                                      ,input del_temp-disc.discnt-role
                                      ,input del_temp-disc.nonunique
                                      ,input del_temp-disc.host-code
                                      ,input del_temp-disc.obj-type
                                      ,input del_temp-disc.obj-code
                                      ,input {&deletion} /*p-0mode*/
                                      ,input p-mode
                                      ,input recid(del_temp-disc)
                                      ,OUTPUT v-rule-num
                                      ,output v-nonunique
                                      ) NO-ERROR .
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> "not-set":U then do:
      {&discpru-value-get-error}
      RETURN error .
    end .
  END .
  if return-value = "not-set":U
  and p-mode <> "change":U then do:
    delete del_temp-disc .
    glog = br-del:refresh() in frame {&frame-name} no-error .
    return .
  end .
  v-rec = recid(del_temp-disc) .
  run temp-dsc-write (
                       input no /*p-add*/
                      ,input del_temp-disc.pos-type
                      ,input del_temp-disc.templ-rl-root
                      ,input del_temp-disc.time-templ-rl-root
                      ,input del_temp-disc.discnt-role
                      ,input del_temp-disc.nonunique
                      ,input del_temp-disc.host-code
                      ,input del_temp-disc.obj-type
                      ,input del_temp-disc.obj-code
                      ,input v-rule-num
                      ,input del_temp-disc.action
                      ,input-output v-rec
                      ) no-error .
  IF not error-status:error then do:
    assign
    updated = yes
    .
  END .
  glog = br-del:refresh() in frame {&frame-name} no-error .
  APPLY "ENTRY" to br-del.
END PROCEDURE .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exit Dialog-Frame
PROCEDURE proc-b-exit :
define variable loc#log      as logical no-undo .
define variable v-not-all-ok as logical no-undo .

define variable v-des           like ub.dis-rule.des .
define variable v-templ-rl-root like ub.dis-rule.templ-rl-root .

define variable p-parent-handle  as widget-handle no-undo .
define variable v-view-log       as logical       no-undo .
define variable v-host-code      like temp-disc.host-code .

define buffer buf_temp-disc              for temp-disc.
define buffer buf_dis-rule               for ub.dis-rule.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

/*Проверяем наличие скидок*/
if not can-find(first temp-disc) then do:
    message "Вы не определили список скидок для изменения (добавления, удаления)"
    view-as alert-box .
    return no-apply .
end .
/*Проверяем наличие списка товаров/баркодов*/
if v-rid-list = ''
then do:
    message "Вы не определили список платежей"
    view-as alert-box .
    return no-apply .
end .
/*Проверяем наличие списка объектов*/
if not can-find(first buf_userobjs_temp-user-obj) then do:
    message "Вы не определили список объектов, скидки" skip
            "будут применены только к текущему объекту." skip
            "Продолжить?"
    view-as alert-box question buttons yes-no update loc#log .
    if not loc#log then do:
      return no-apply .
    end .
end .
/*Проверяем, что все выбранные объекты принадлежат тек фирме*/
for each buf_userobjs_temp-user-obj exclusive-lock:
    { gbl/hostcode.i buf_userobjs_temp-user-obj.obj-type buf_userobjs_temp-user-obj.obj-code v-host-code }
    if not p-host-code = v-host-code then do:
        message "Вы выбрали " buf_userobjs_temp-user-obj.obj-type buf_userobjs_temp-user-obj.obj-code " не принадлежащий текущей фирме" skip
                buf_userobjs_temp-user-obj.obj-type buf_userobjs_temp-user-obj.obj-code " будет исключен из списка объектов." skip
                "Продолжить?"
        view-as alert-box question buttons yes-no update loc#log .
        if not loc#log then do:
            return no-apply .
        end .
        else do:
            delete buf_userobjs_temp-user-obj .
        end.
    end.
end.

message
"Вы уверены, что Вы хотите провести изменение (добавление, удаление) скидок платежей на объекте" SKIP
"по всему определенному Вами списку?"
view-as alert-box QUESTION buttons YES-NO update loc#log .
if loc#log then do:
 /*Сохраняем список правил*/
 run save-temp-disc in this-procedure no-error.

 _main:
 DO
 on error undo, return no-apply
 :
    /*Формируем temp-disc по всем объектам*/
    run make-full-temp-disc in this-procedure no-error.

    /*Пишем скидки*/
    CASE par-subject:
    when {&table_dis-cp-rule} then do:
        run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input "ref/csh-lst.p":U
              , input v-rid-list
              , input v-auto-go /*p-auto-go*/
              , input "&Стоп":U
              , input "Изменение скидок платежей по списку"
        ) no-error .
        if error-status:error then do:
            /*run rest-temp-disc in this-procedure no-error.*/ /*Восстанавливаем список*/
            undo _main, return error .
        end.
    end .
    END CASE .

  END. /*DO*/

  /*Восстанавливаем список*/
  run rest-temp-disc in this-procedure no-error.
end . /*if loc#log*/

END PROCEDURE .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-title Dialog-Frame
PROCEDURE proc-title :
IF parobj-type = {&shop} THEN DO:
  { gbl/dflt-cd.i parobj-type parobj-code dflt-cd }
END .
if parobj-type = {&stock} then do:
  dflt-cd = {&cd-type-no-cd} .
end .
ASSIGN
MENU-ITEM m_pos-type:LABEL IN MENU menu-b-add  = dflt-cd
MENU-ITEM m_pos-type:sensitive IN MENU menu-b-add  = ((dflt-cd <> '':U) and (dflt-cd <> {&cd-type-no-cd}))
MENU-ITEM m_pos-type-2:LABEL IN MENU menu-b-add-2  = dflt-cd
MENU-ITEM m_pos-type-2:sensitive IN MENU menu-b-add-2  = ((dflt-cd <> '':U) and (dflt-cd <> {&cd-type-no-cd}))
.

frame {&frame-name}:title = substitute("Изменение скидок на платежи, &1 &2"
                                          ,parobj-type
                                          ,parobj-code) .
assign
    /*v-tab-order = "b-exit,b-quit,rs-list,b-list,b-list-2,b-help,rs-obj-type,f-obj-code,b-obj,T-delete-ok,b-add,b-add-2".*/
v-tab-order = "b-exit,b-quit,b-list,b-help,b-obj,b-add,b-add-2" .

APPLY "ENTRY" TO b-add IN FRAME {&FRAME-NAME} .
END PROCEDURE .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-obj Dialog-Frame
PROCEDURE proc-b-obj :
define variable v-user-select as logical   no-undo .

/*Получаем список объектов*/
{ gbl/uobjsman.i
  parparentproc
  v-cntxt-db-num
  v-cntxt-userid
  p-host-code
  parobj-type
  parobj-code
  v-user-select
}

define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

find first buf_userobjs_temp-user-obj no-lock no-error.
if not avail buf_userobjs_temp-user-obj
/*if v-user-select <> true*/
then do:
  message
  "Объект не выбран"
  view-as alert-box information .
  undo, return error return-value .
end.

END PROCEDURE .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_set-cp-list Dialog-Frame
PROCEDURE cb_set-cp-list :
  define output parameter p-rid-list as character no-undo.
  assign
    p-rid-list = v-rid-list
  .
END PROCEDURE .
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rest-temp-disc Dialog-Frame
PROCEDURE rest-temp-disc :
  define buffer buf_temp-disc              for temp-disc.
  define buffer buf_old-temp-disc          for old-temp-disc.

  for each temp-disc exclusive-lock :
     delete temp-disc.
  end.
  for each buf_old-temp-disc no-lock :
     create buf_temp-disc.
     buffer-copy buf_old-temp-disc to buf_temp-disc.
  end.
  glog = br-del:refresh() in frame {&frame-name} no-error .
  glog = br-add:refresh() in frame {&frame-name} no-error .
END PROCEDURE .
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-temp-disc Dialog-Frame
PROCEDURE save-temp-disc :
  define buffer buf_temp-disc              for temp-disc.
  define buffer buf_old-temp-disc          for old-temp-disc.

  for each old-temp-disc exclusive-lock :
      delete old-temp-disc.
  end.
  for each buf_temp-disc no-lock :
      create buf_old-temp-disc.
      buffer-copy buf_temp-disc to buf_old-temp-disc.
  end.
END PROCEDURE .
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-full-temp-disc Dialog-Frame
PROCEDURE make-full-temp-disc :
  define buffer buf_temp-disc              for temp-disc.
  define buffer buf_dis-rule               for ub.dis-rule.
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  define variable v-des           like ub.dis-rule.des .
  define variable v-templ-rl-root like ub.dis-rule.templ-rl-root .
  define variable v-discnt-value  like ub.dis-rule.discnt-value .
  define variable v-discnt-type   like ub.dis-rule.discnt-type .

  _userobjs_temp-user-obj:
  for each buf_userobjs_temp-user-obj no-lock :
      /*Пропустим текущий объект*/
      if buf_userobjs_temp-user-obj.obj-type = parobj-type and
         buf_userobjs_temp-user-obj.obj-code = parobj-code then do:
           next _userobjs_temp-user-obj .
      end.

      /*Перебираем правила для текущего объекта*/
      _temp-disc:
      for each temp-disc exclusive-lock
      where temp-disc.obj-type = parobj-type
        and temp-disc.obj-code = parobj-code :
          /*Ищем наличие правила для объекта из списка buf_userobjs_temp-user-obj*/
          find first buf_temp-disc no-lock
          where buf_temp-disc.obj-type           = buf_userobjs_temp-user-obj.obj-type
            and buf_temp-disc.obj-code           = buf_userobjs_temp-user-obj.obj-code
            and buf_temp-disc.templ-rl-root      = temp-disc.templ-rl-root
            and buf_temp-disc.time-templ-rl-root = temp-disc.time-templ-rl-root
            and buf_temp-disc.discnt-role        = temp-disc.discnt-role
            and buf_temp-disc.nonunique          = temp-disc.nonunique
            and buf_temp-disc.cfg-nonunique      = temp-disc.cfg-nonunique
            and buf_temp-disc.pos-type           = temp-disc.pos-type
            and buf_temp-disc.action             = temp-disc.action
          no-error.
          /*Если есть, то берем следующее правило*/
          if avail buf_temp-disc then do:
              next _temp-disc.
          end.
          /*Если нет, то создаем новую запись в списке правил для объекта из списка buf_userobjs_temp-user-obj*/
          create buf_temp-disc.
          buffer-copy temp-disc
          except obj-type obj-code
          to buf_temp-disc
          assign
            buf_temp-disc.obj-type = buf_userobjs_temp-user-obj.obj-type
            buf_temp-disc.obj-code = buf_userobjs_temp-user-obj.obj-code
          .

          /*Добываем номер правила для объекта из списка buf_userobjs_temp-user-obj*/
          if not ( temp-disc.rule-num = ? or temp-disc.rule-num = 0 ) then do:
              /*Получим данные по правилу для текущего объекта*/
              find first buf_dis-rule no-lock
              where buf_dis-rule.rule-num = temp-disc.rule-num no-error.
              if avail buf_dis-rule then do:
                  assign
                    v-des           = buf_dis-rule.des
                    v-templ-rl-root = buf_dis-rule.templ-rl-root
                    v-discnt-value  = buf_dis-rule.discnt-value
                    v-discnt-type   = buf_dis-rule.discnt-type
                  .
                  /*Ищем такое же правило на объекте из списка buf_userobjs_temp-user-obj*/
                  find first buf_dis-rule no-lock
                  where buf_dis-rule.des           = v-des
                    and buf_dis-rule.host-code     = temp-disc.host-code
                    and buf_dis-rule.obj-type      = buf_userobjs_temp-user-obj.obj-type
                    and buf_dis-rule.obj-code      = buf_userobjs_temp-user-obj.obj-code
                    and buf_dis-rule.templ-rl-root = v-templ-rl-root
                    and buf_dis-rule.discnt-value  = v-discnt-value
                    and buf_dis-rule.discnt-type   = v-discnt-type
                    and buf_dis-rule.root          = yes no-error.
                  if avail buf_dis-rule then do:
                      assign
                        buf_temp-disc.rule-num = buf_dis-rule.rule-num /*Нашли и присваиваем номер правила*/
                      .
                  end.
                  else do:
                      /*Не нашли, копируем правило из текущего объекта в объект из списка и присваиваем ему новый номер*/
                      run copy-rule in this-procedure (
                            input  temp-disc.rule-num
                           ,input  buf_userobjs_temp-user-obj.obj-type
                           ,input  buf_userobjs_temp-user-obj.obj-code
                           ,output buf_temp-disc.rule-num
                           ,input-output buf_temp-disc.label_  /*сюда вернется сообщение об ошибке, буде таковая произойдет*/
                      ) no-error.
                  end.
              end. /*if avail buf_dis-rule*/
          end.
      end. /*for each temp-disc*/
  end. /*for buf_userobjs_temp-user-obj*/

END PROCEDURE .
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE copy-rule Dialog-Frame
PROCEDURE copy-rule :
  define input  param p-rule-num as integer   no-undo .
  define input  param p-obj-type as character no-undo .
  define input  param p-obj-code as integer   no-undo .
  define output param p-new-rnum as integer   no-undo init ? .  /*номер нового правила*/
  define input-output param p-err-msg as character no-undo .    /*сообщение об ошибке*/

  define variable v-cd-type as character no-undo .

  define buffer src_dis-rule for ub.dis-rule .
  define buffer trg_dis-rule for ub.dis-rule .

  /*Проверим возможность копирования скидки*/
  run check-possible-copy in this-procedure (
         input  p-rule-num
        ,input  p-obj-type
        ,input  p-obj-code
        ,output p-new-rnum
  ) no-error.
  if error-status :error then do:
      if not p-err-msg = '' then p-err-msg = p-err-msg + ', ' .
      p-err-msg = error-status:get-message(1) .
      return .
  end.

  /*Получим POS объекта*/
  { gbl/dflt-cd.i p-obj-type p-obj-code v-cd-type }

  /*Копируем правило, привязываем его к объекту и присваиваем новый номер.*/
  _lmain:
  DO
  on error undo, return
  :
      find first src_dis-rule no-lock
      where src_dis-rule.rule-num = p-rule-num no-error .
      if error-status:error then do:
          if not p-err-msg = '' then p-err-msg = p-err-msg + ', ' .
          p-err-msg = error-status:get-message(1) .
          undo _lmain, return error .
      end.

      create trg_dis-rule no-error.
      if error-status:error then do:
          if not p-err-msg = '' then p-err-msg = p-err-msg + ', ' .
          p-err-msg = error-status:get-message(1) .
          undo _lmain, return error .
      end.

      buffer-copy src_dis-rule
      except rule-num rl-root obj-type obj-code
      to trg_dis-rule
      assign
        trg_dis-rule.rule-num = p-new-rnum
        trg_dis-rule.rl-root  = p-new-rnum
        trg_dis-rule.obj-type = p-obj-type
        trg_dis-rule.obj-code = p-obj-code
      no-error.
      if error-status:error then do:
          if not p-err-msg = '' then p-err-msg = p-err-msg + ', ' .
          p-err-msg = error-status:get-message(1) .
          undo _lmain, return error .
      end.

  END.

END PROCEDURE .
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-possible-copy Dialog-Frame
PROCEDURE check-possible-copy :
  define input  param p-rule-num as integer   no-undo .
  define input  param p-obj-type as character no-undo .
  define input  param p-obj-code as integer   no-undo .
  define output param p-new-rnum as integer   no-undo init ?.

  define variable v-err-msg as character no-undo init ''.
  define variable v-cd-type as character no-undo .

  define buffer buf_dis-rule     for ub.dis-rule .
  define buffer buf_dis-cfg-rule for ub.dis-cfg-rule .

  find first buf_dis-rule no-lock
  where buf_dis-rule.rule-num = p-rule-num no-error .
  if not avail buf_dis-rule then do:
      v-err-msg = substitute("Не найдено правило &1", p-rule-num ) .
      return error v-err-msg .
  end.

  if not (buf_dis-rule.sts = int({&used-status-int})) then do:
      v-err-msg = substitute("Нельзя копировать правило в статусе &1", {&used-status-int}) .
      return error v-err-msg .
  end.

  if buf_dis-rule.obj-type = ''
  or not (buf_dis-rule.obj-type = {&shop} or
          buf_dis-rule.obj-type = {&stock}) then do:
      v-err-msg = substitute("Нельзя копировать правило, которое действует &1", get-region( p-host-code, parobj-type, parobj-code )) .
      return error v-err-msg .
  end.

  /*Получим POS объекта*/
  { gbl/dflt-cd.i p-obj-type p-obj-code v-cd-type }

  find first buf_dis-cfg-rule no-lock
  where buf_dis-cfg-rule.table-name    = {&table_dis-cp-rule}
    and buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
    and buf_dis-cfg-rule.pos-type      = v-cd-type no-error .
  if not avail buf_dis-cfg-rule then do:
      v-err-msg = substitute("Не найдено правило скидки с шаблоном &1 POS &2 для &3&4"
                            , buf_dis-rule.templ-rl-root
                            , v-cd-type
                            , p-obj-type
                            , p-obj-code ) .
      return error v-err-msg .
  end.

  if not (v-cd-type = {&cd-type-bo} or v-cd-type = {&cd-type-no-cd}) then do:
      if p-obj-type = {&stock} then do:
          v-err-msg = substitute("Нельзя скопировать правила скидки на объект &1&2"
                                , p-obj-type
                                , p-obj-code ) .
          return error v-err-msg .
      end.
  end.

  /*Расчитаем новый номер правила*/
  run gen-b-code in this-procedure ( input {&gbl-dr-code}, output p-new-rnum) no-error .
  if error-status:error then do:
      v-err-msg = substitute("Не удалось расчитать новый номер правила скидки &1 (gen-b-code) на &2&3&4&5&4&6" ~
                            , p-rule-num
                            , p-obj-type
                            , p-obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ) .
      assign
        p-new-rnum = ?
      .
      return error v-err-msg .
  end.

END PROCEDURE .
&ANALYZE-RESUME

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME