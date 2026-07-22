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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Механизм простановки скидок на различные сущности - dis-gds-rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 23/07/02
Author: Bakhtadze Natalya
Creation date: 23/07/02

*/


/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-subject as character no-undo.
/*на какой таблице работаем - может быть dis-gds-rule*/
define input parameter parobj-type like ub.clients.obj-type no-undo.
/*текущий объект*/
define input parameter parobj-code like ub.clients.obj-code no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Скидки товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/bb-list.i bb-list def "new shared" }
{ cmp/bitoper.i }
{ ref/temp-dsc.i "NEW SHARED" ~{&table_dis-gds-rule~} parbj-type parobj-code }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ ref/disgdsru.i interface parparentproc temp-disc }
{ gbl/get-regf.i }
{ trg/new-bcod.i }
{ cmp/trg-def.i } /*определение переменных для просмотра лога pro-copy*/
&scoped-define  temp-dsc-type-get-error message "Ошибка при определении названия и типа скидки !" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  temp-dsc-value-get-error message "Ошибка при определении значения скидки !" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

define variable add-option as char no-undo.
DEFINE VARIABLE add-obj-type like ub.clients.obj-type no-undo .
DEFINE VARIABLE add-obj-code like ub.clients.obj-code no-undo .
define variable updated as logical no-undo.
define variable temp-doc-rec as recid no-undo.
define buffer del_temp-disc for temp-disc.
define variable glog as logical no-undo .
define variable v-tab-order AS character no-undo.
define variable loc-glob as logical no-undo .
define variable loc-firm as logical no-undo .
define variable loc-object as logical no-undo .
define variable dflt-cd as character no-undo .
define variable v-auto-go    as logical no-undo init yes . /*Пакетный режим p-auto-go*/

define temp-table tt-dis-rule       no-undo like ub.dis-rule.
define temp-table tt0-term_dis-rule no-undo like ub.dis-rule.
define temp-table old-temp-disc     no-undo like temp-disc.

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
&Scoped-define FIELDS-IN-QUERY-BR-add {&cd-type-name} dis-gds-rule-name (temp-disc.discnt-role) temp-disc.templ-rl-root temp-disc.time-templ-rl-root disgdsru-get-disc-label( INPUT temp-disc.templ-rl-root) temp-disc.rule-num get-objregion(temp-disc.obj-type, temp-disc.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-add
&Scoped-define SELF-NAME BR-add
&Scoped-define QUERY-STRING-BR-add FOR EACH temp-disc where temp-disc.action = yes NO-LOCK
&Scoped-define OPEN-QUERY-BR-add OPEN QUERY {&SELF-NAME} FOR EACH temp-disc where temp-disc.action = yes NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-add temp-disc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-add temp-disc


/* Definitions for BROWSE BR-del                                        */
&Scoped-define FIELDS-IN-QUERY-BR-del {&cd-type-name2} dis-gds-rule-name ( DEL_temp-disc.discnt-role) del_temp-disc.templ-rl-root del_temp-disc.time-templ-rl-root disgdsru-get-disc-label( INPUT del_temp-disc.templ-rl-root) del_temp-disc.rule-num get-objregion(del_temp-disc.obj-type, del_temp-disc.obj-code)
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
&Scoped-Define ENABLED-OBJECTS B-exit b-quit rs-list B-list B-list-2 B-Help ~
/*Rs-obj-type f-obj-code*/ B-obj T-delete-ok b-add B-chg B-del BR-add b-add-2 ~
B-chg-2 B-del-2 BR-del /*F-obj-name*/
&Scoped-Define DISPLAYED-OBJECTS rs-list /*Rs-obj-type f-obj-code*/ T-delete-ok /*~*/
/*F-obj-name*/

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD dis-gds-rule-name Dialog-Frame
FUNCTION dis-gds-rule-name RETURNS CHARACTER
  ( INPUT p-discnt-role AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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
     LABEL "&Список товаров"
     SIZE 20 BY 1 TOOLTIP "Создание списка".

DEFINE BUTTON B-list-2
     LABEL "&Список кодов"
     SIZE 20 BY 1 TOOLTIP "Создание списка".

DEFINE BUTTON B-obj
     LABEL "&Список объектов"
     SIZE 20 BY 1 TOOLTIP "Создание списка".

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 52.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-list AS CHARACTER INITIAL "gds-list"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Товары", "gds-list",
"Бар-коды", "bb-list"
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE T-delete-ok AS LOGICAL INITIAL no
     LABEL "Удалять записи списка в случае удачного изменения"
     VIEW-AS TOGGLE-BOX
     SIZE 52 BY 1 NO-UNDO.

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
dis-gds-rule-name (temp-disc.discnt-role) column-label "Тип скидки" FORMAT "X(255)":U WIDTH 35
temp-disc.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
temp-disc.time-templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!типа!распис"
disgdsru-get-disc-label( INPUT temp-disc.templ-rl-root) FORMAT "X(255)":U WIDTH 45
temp-disc.rule-num COLUMN-LABEL "Код правила" FORMAT ">>>>>>>>9"
get-objregion(temp-disc.obj-type, temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут добавлены/изменены скидки".

DEFINE BROWSE BR-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-del Dialog-Frame _FREEFORM
  QUERY BR-del DISPLAY
      {&cd-type-name2} column-label "Место!использ."  format "X(10)"
dis-gds-rule-name ( DEL_temp-disc.discnt-role) column-label "Тип скидки" FORMAT "X(255)":U WIDTH 35
del_temp-disc.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
del_temp-disc.time-templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!типа!распис"
disgdsru-get-disc-label( INPUT del_temp-disc.templ-rl-root) FORMAT "X(255)":U WIDTH 45
del_temp-disc.rule-num COLUMN-LABEL "Код правила" FORMAT ">>>>>>>>9"
get-objregion(del_temp-disc.obj-type, del_temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут удалены скидки".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     rs-list AT ROW 1 COL 22 NO-LABEL WIDGET-ID 6
     B-list AT ROW 1 COL 51
     B-list-2 AT ROW 1 COL 71 WIDGET-ID 4
     B-Help AT ROW 1 COL 92
     T-delete-ok AT ROW 3.5 COL 1.5
     b-add AT ROW 4.77 COL 1
     B-chg AT ROW 4.77 COL 11
     B-del AT ROW 4.77 COL 21
     BR-add AT ROW 5.77 COL 1
     b-add-2 AT ROW 14 COL 1
     B-chg-2 AT ROW 14 COL 11 WIDGET-ID 2
     B-del-2 AT ROW 14 COL 21
     BR-del AT ROW 15 COL 1
     B-obj AT ROW 2.27 COL 1
     SPACE(15.12) SKIP(20.06)
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
  message "Вы уверены, что хотите удалить скидку"  "<" temp-disc.label_ ">" skip
                     "из списка скидок подлежащих установке/изменению?"  skip
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
  "Вы уверены, что хотите удалить скидку" "<" del_temp-disc.label_ ">" skip
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
ON CHOOSE OF B-list IN FRAME Dialog-Frame /* Список товаров */
DO:
define variable v-host-code as integer no-undo .
  CASE par-subject:
    when {&table_dis-gds-rule}
    then do:
      { gbl/hostcode.i parobj-type parobj-code v-host-code }
      run str/gds-list.w ( input parparentproc, input v-host-code, input parobj-type, input parobj-code).
    end.
  END CASE.
  assign
  b-list:label = "&Список товаров"
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-list-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-list-2 Dialog-Frame
ON CHOOSE OF B-list-2 IN FRAME Dialog-Frame /* Список кодов */
DO:
define variable v-host-code as integer no-undo .
  CASE par-subject:
    when {&table_dis-gds-rule}
    then do:
      run str/bb-list.w ( input parparentproc, input parobj-type, input parobj-code, input '').
    end.
  END CASE.
  assign
  b-list-2:label = "&Список кодов"
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame /* Btn 1 */
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


&Scoped-define SELF-NAME m_pos-type-2
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


&Scoped-define SELF-NAME rs-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-list Dialog-Frame
ON VALUE-CHANGED OF rs-list IN FRAME Dialog-Frame
DO:
  assign
  rs-list.
  for each temp-disc:
    delete temp-disc.
  end.
  Run init-proc in this-procedure no-error.
  if error-status:error then do:
    undo, return no-apply.
  end.
  CASE rs-list:
    WHEN "gds-list" THEN DO:
      ENABLE
      b-list
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      b-list-2
      WITH FRAME {&FRAME-NAME}.
    END.
    WHEN "bb-list" THEN DO:
      ENABLE
      b-list-2
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      b-list
      WITH FRAME {&FRAME-NAME}.
    END.
  END CASE.
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
  if lookup(par-subject, {&table_dis-gds-rule}) = 0 then do:

    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра par-subject" par-subject
    view-as alert-box error.
    return error.
  end.
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
  DISPLAY rs-list /*Rs-obj-type f-obj-code*/ T-delete-ok /*F-obj-name*/
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit rs-list B-list B-list-2 B-Help /*Rs-obj-type f-obj-code*/
         B-obj T-delete-ok b-add B-chg B-del BR-add b-add-2 B-chg-2 B-del-2
         BR-del /*F-obj-name*/
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
APPLY "VALUE-CHANGED" to rs-list.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
/*Добавить скидки*/
PROCEDURE proc-b-add :
define input parameter p-pos-type as character no-undo.

define variable v-deleted       as logical   no-undo .
define variable v-rid-list as character no-undo .
define variable v-host-code as integer no-undo .
define variable v-rec as recid no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-cfg-nonunique as character no-undo .

define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_temp-disc    for temp-disc.

do
on error undo, return error :

  run ref/dis-pos.w ( INPUT parparentproc
                      ,INPUT "b-sel":U
                      ,INPUT "cd-type-list"
                      ,INPUT (if v-cntxt-db-num = 0 and loc-glob then 1 else 0)
                      ,INPUT (if v-cntxt-db-num = 0 and loc-firm then 1 else 0)
                      ,INPUT 1
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
  /*Проверка можно ли применить выбранную скидку к списку товаров или баркодов.*/
  FIND FIRST buf_dis-cfg-rule NO-LOCK where
            recid(buf_dis-cfg-rule) = INTEGER(v-rid-list).
  if buf_dis-cfg-rule.nonunique <> ''
  and num-entries(buf_dis-cfg-rule.nonunique, ".") > 1 then do:
    case buf_dis-cfg-rule.nonunique:
      when "bar-code.b-code" then do:
        if rs-list = "gds-list" then do:
          message
          "Нельзя задать такую скидку по списку товаров!"
          view-as alert-box error .
          return error.
        end.
        v-cfg-nonunique = substitute("@&1", buf_dis-cfg-rule.nonunique).
      end.
      otherwise do:
        message
        substitute("Неизвестная опция для дифференциации скидки внутри одного товара=&1", buf_dis-cfg-rule.nonunique)
        view-as alert-box error .
        return error.
      end.
    end case.
  end.
  else do:
    if rs-list = "bb-list" then do:
      message
      "Нельзя задать такую скидку по списку бар-кодов!"
      view-as alert-box error .
      return error.
    end.
    v-cfg-nonunique = buf_dis-cfg-rule.nonunique.
  end.
  assign
  v-obj-type = parobj-type
  v-obj-code = parobj-code
  .
  { gbl/hostcode.i parobj-type parobj-code v-host-code }
  /*Пишем скидку*/
  run temp-dsc-write in this-procedure (
                                         input yes /*p-add*/
                                        ,input buf_dis-cfg-rule.pos-type
                                        ,input buf_dis-cfg-rule.templ-rl-root
                                        ,input buf_dis-cfg-rule.time-templ-rl-root
                                        ,input buf_dis-cfg-rule.discnt-role
                                        ,input v-cfg-nonunique
                                        ,input v-host-code
                                        ,input v-obj-type
                                        ,input v-obj-code
                                        ,input 0
                                        ,input yes
                                        ,input-output v-rec
                                  ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value = "not-set" then do:
    end.
    else do:
      {&temp-dsc-type-get-error}
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
                                              ,input v-host-code
                                              ,input v-obj-type
                                              ,input v-obj-code
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
define variable v-rid-list as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-rule-num as integer no-undo .
define variable v-cfg-nonunique as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
define buffer buf_temp-disc for temp-disc.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
CASE par-subject :
  WHEN {&table_dis-gds-rule} THEN DO:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "cd-type-list"
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT 1
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
    if buf_dis-cfg-rule.nonunique <> ''
    and num-entries(buf_dis-cfg-rule.nonunique, ".") > 1 then do:
      case buf_dis-cfg-rule.nonunique:
        when "bar-code.b-code" then do:
          if rs-list = "gds-list" then do:
            message
            "Нельзя задать такую скидку по списку товаров!"
            view-as alert-box error .
            return error.
          end.
          v-cfg-nonunique = substitute("@&1", buf_dis-cfg-rule.nonunique).
        end.
        otherwise do:
          message
          substitute("Неизвестная опция для дифференциации скидки внутри одного товара=&1", buf_dis-cfg-rule.nonunique)
          view-as alert-box error .
          return error.
        end.
      end case.
    end.
    else do:
      if rs-list = "bb-list" then do:
        message
        "Нельзя задать такую скидку по списку бар-кодов!"
        view-as alert-box error .
        return error.
      end.
      v-cfg-nonunique = buf_dis-cfg-rule.nonunique.
    end.
    assign
    v-obj-type = parobj-type
    v-obj-code = parobj-code
    .
    { gbl/hostcode.i parobj-type parobj-code v-host-code }
    run temp-dsc-write in this-procedure (
                                            input yes /*p-add*/
                                           ,input buf_dis-cfg-rule.pos-type
                                           ,input buf_dis-cfg-rule.templ-rl-root
                                           ,input buf_dis-cfg-rule.time-templ-rl-root
                                           ,input buf_dis-cfg-rule.discnt-role
                                           ,input v-cfg-nonunique
                                           ,input v-host-code
                                           ,input v-obj-type
                                           ,input v-obj-code
                                           ,input v-rule-num
                                           ,input no
                                           ,input-output v-rec )  no-error.
     IF ERROR-STATUS:ERROR THEN DO:
      if return-value = "not-set" then do:
      end.
      else do:
        {&temp-dsc-type-get-error}
        return error.
      end.
    END.
    define buffer bb_temp-disc for temp-disc.
    find first bb_temp-disc no-error.
  END.
END CASE.
updated = yes.
find first buf_temp-disc no-lock where
          recid(buf_temp-disc) = v-rec no-error .
if avail buf_temp-disc then
  temp-doc-rec = recid(buf_temp-disc).
  else temp-doc-rec = ?.
Run init-proc in this-procedure .
reposition BR-del to recid temp-doc-rec no-error.
if error-status:error then return error.

run proc-b-chg-2 in this-procedure ( input "":U) no-error.
if error-status:error then do:
    run temp-dsc-delete in this-procedure (
                                             input buf_dis-cfg-rule.pos-type
                                            ,input buf_dis-cfg-rule.discnt-role
                                            ,input v-cfg-nonunique
                                            ,input v-host-code
                                            ,input v-obj-type
                                            ,input v-obj-code
                                            ,input no
                                            ,output v-deleted
                                            ) no-error .
  Run init-proc in this-procedure no-error.
  undo, return error.
end.
APPLY "ENTRY" to br-del in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
define input parameter p-mode as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
if not avail temp-disc then return error.
  RUN temp-dsc-VALUE IN THIS-PROCEDURE (
                                       input temp-disc.pos-type
                                      ,input temp-disc.templ-rl-root
                                      ,input temp-disc.time-templ-rl-root
                                      ,input temp-disc.discnt-role
                                      ,input temp-disc.cfg-nonunique
                                      ,input temp-disc.host-code
                                      ,input temp-disc.obj-type
                                      ,input temp-disc.obj-code
                                      ,input {&add-def} /*p-0mode*/
                                      ,input p-mode
                                      ,input recid(temp-disc)
                                      ,OUTPUT v-rule-num
                                      ,output v-nonunique
                                      ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> "not-set":U then do:
      {&temp-dsc-value-get-error}
      RETURN error.
    end.
  END.
  if return-value = "not-set":U
  and p-mode <> "change":U then do:
    delete temp-disc.
    glog = br-add:refresh() in frame {&frame-name} no-error .
    return .
  end.
  v-rec = recid(temp-disc).
  run temp-dsc-write (
                       input no /*p-add*/
                      ,input temp-disc.pos-type
                      ,input temp-disc.templ-rl-root
                      ,input temp-disc.time-templ-rl-root
                      ,input temp-disc.discnt-role
                      ,input temp-disc.cfg-nonunique
                      ,input temp-disc.host-code
                      ,input temp-disc.obj-type
                      ,input temp-disc.obj-code
                      ,input v-rule-num
                      ,input temp-disc.action
                      ,input-output v-rec
                      ) no-error.
  IF not error-status:error then do:
    assign
    updated = yes
    .
  END.
  glog = br-add:refresh() in frame {&frame-name} no-error .
  APPLY "ENTRY" to br-add.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg-2 Dialog-Frame
PROCEDURE proc-b-chg-2 :
define input parameter p-mode as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
if not avail del_temp-disc then return error.
  RUN temp-dsc-VALUE IN THIS-PROCEDURE (
                                       input del_temp-disc.pos-type
                                      ,input del_temp-disc.templ-rl-root
                                      ,input del_temp-disc.time-templ-rl-root
                                      ,input del_temp-disc.discnt-role
                                      ,input del_temp-disc.cfg-nonunique
                                      ,input del_temp-disc.host-code
                                      ,input del_temp-disc.obj-type
                                      ,input del_temp-disc.obj-code
                                      ,input {&deletion} /*p-0mode*/
                                      ,input p-mode
                                      ,input recid(del_temp-disc)
                                      ,OUTPUT v-rule-num
                                      ,output v-nonunique
                                      ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> "not-set":U then do:
      {&temp-dsc-value-get-error}
      RETURN error.
    end.
  END.
  if return-value = "not-set":U
  and p-mode <> "change":U then do:
    delete del_temp-disc.
    glog = br-del:refresh() in frame {&frame-name} no-error .
    return .
  end.
  v-rec = recid(del_temp-disc).
  run temp-dsc-write (
                       input no /*p-add*/
                      ,input del_temp-disc.pos-type
                      ,input del_temp-disc.templ-rl-root
                      ,input del_temp-disc.time-templ-rl-root
                      ,input del_temp-disc.discnt-role
                      ,input del_temp-disc.cfg-nonunique
                      ,input del_temp-disc.host-code
                      ,input del_temp-disc.obj-type
                      ,input del_temp-disc.obj-code
                      ,input v-rule-num
                      ,input del_temp-disc.action
                      ,input-output v-rec
                      ) no-error.
  IF not error-status:error then do:
    assign
    updated = yes
    .
  END.
  glog = br-del:refresh() in frame {&frame-name} no-error .
  APPLY "ENTRY" to br-del.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exit Dialog-Frame
PROCEDURE proc-b-exit :
define variable loc#log as logical no-undo .
define variable v-not-all-ok as logical no-undo .
define variable v-host-code  as integer no-undo .

define variable v-des           like ub.dis-rule.des .
define variable v-templ-rl-root like ub.dis-rule.templ-rl-root .

define variable p-parent-handle  as widget-handle no-undo .
define variable v-view-log as logical no-undo .

define buffer buf_temp-disc for temp-disc.
define buffer buf_old-temp-disc          for old-temp-disc.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

/*Проверяем наличие скидок*/
if not can-find(first temp-disc) then do:
    message "Вы не определили список скидок для изменения (добавления, удаления)"
    view-as alert-box.
    return no-apply.
end.
/*Проверяем наличие списка товаров/баркодов*/
    if (rs-list = "gds-list" and not can-find(first gds-list))
    or (rs-list = "bb-list" and not can-find(first bb-list))
      then do:
      message "Вы не определили список товаров/бар-кодов"
      view-as alert-box.
      return no-apply.
    end.
/*Проверяем наличие списка объектов*/
if not can-find(first buf_userobjs_temp-user-obj) then do:
    message "Вы не определили список объектов, скидки" skip
            "будут применены только к текущему объекту." skip
            "Продолжить?"
    view-as alert-box question buttons yes-no update loc#log .
    if not loc#log then do:
      return no-apply .
      end.
    end.
ASSIGN
FRAME {&FRAME-NAME} t-delete-ok .

    message
    "Вы уверены, что Вы хотите провести изменение (добавление, удаление) скидок товара на объекте" SKIP
    "по всему определенному Вами списку?"
    view-as alert-box QUESTION buttons YES-NO update loc#log.
    if loc#log then do:
 _main:
 DO
 on error undo, return no-apply
 :

    /*Пишем скидки по тек объекту*/
    CASE par-subject:
    when {&table_dis-gds-rule} then do:
      run str/diallog.w (
              input parparentproc
            , input this-procedure
            , input "ref/dgr-lst.p":U
            , input (parobj-type + {&delim-par} +
                     string(parobj-code) + {&delim-par} +
                     string(t-delete-ok) + {&delim-par} +
                     rs-list
                     )
              , input v-auto-go /*p-auto-go*/
            , input "&Стоп":U
            , input substitute("Изменение скидок товаров на объекте &1&2 по списку товаров (бар-кодов)"
                                , parobj-type
                                , parobj-code
                                )
        ) no-error.
        if error-status:error then do:
            undo _main, return error .
        end.
    end .
    END CASE .

    /*Привязываем правила скидки к объектам, если не привязаны.*/
    run proc-check-rule1 in this-procedure no-error.
    if error-status:error then do:
        assign
        v-view-log = yes.
        { str/cdviewlg.i
        "'!!!При копировании скидок на объекты произошли ошибки!!!'"
        "'dgrbylst.txt'" }
        undo _main, return error .
    end .

    /*Сохраняем список правил*/
    for each old-temp-disc exclusive-lock :
        delete old-temp-disc.
    end.
    for each buf_temp-disc no-lock :
        create buf_old-temp-disc.
        buffer-copy buf_temp-disc to buf_old-temp-disc.
    end.

    /*Проверяем наличие списка на удаление*/
    find first temp-disc no-lock
    where temp-disc.action = no no-error.
    if avail temp-disc then do:
          /*Удаляем action yes, оставляем список только на удаление*/
          for each temp-disc exclusive-lock
          where temp-disc.action = yes :
              delete temp-disc.
          end.
          glog = br-add:refresh() in frame {&frame-name} no-error .
          find first temp-disc no-lock no-error.

          _userobjs_temp-user-obj:
          for each buf_userobjs_temp-user-obj no-lock :
              /*Пропустим текущий объект*/
              if buf_userobjs_temp-user-obj.obj-type = parobj-type and
                 buf_userobjs_temp-user-obj.obj-code = parobj-code then do:
                   next _userobjs_temp-user-obj .
              end.

              /*Изменяем данные объекта во временной табличке для dgr-lst.p*/
              for each temp-disc exclusive-lock :
                  assign
                    temp-disc.obj-type = buf_userobjs_temp-user-obj.obj-type .
                    temp-disc.obj-code = buf_userobjs_temp-user-obj.obj-code .
                  .
                  /*Добываем номер правила для объекта*/
                  if not ( temp-disc.rule-num = ? or temp-disc.rule-num = 0 ) then do:
                      find first buf_dis-rule no-lock
                      where buf_dis-rule.rule-num = temp-disc.rule-num no-error.
                      if avail buf_dis-rule then do:
      assign
                            v-des           = buf_dis-rule.des
                            v-templ-rl-root = buf_dis-rule.templ-rl-root
                          .
                          find first buf_dis-rule no-lock
                          where buf_dis-rule.des = v-des
                            and buf_dis-rule.host-code = temp-disc.host-code
                            and buf_dis-rule.obj-type  = temp-disc.obj-type
                            and buf_dis-rule.obj-code  = temp-disc.obj-code
                            and buf_dis-rule.templ-rl-root = v-templ-rl-root
                            and buf_dis-rule.root = yes no-error.
                          if avail buf_dis-rule then do:
                              assign
                                temp-disc.rule-num = buf_dis-rule.rule-num
                              .
                          end.
                      end.
                  end.
              end. /*for each temp-disc*/
              /*Пишем по объекту*/
              run str/diallog.w (
                    input parparentproc
                  , input this-procedure
                  , input "ref/dgr-lst.p":U
                  , input (buf_userobjs_temp-user-obj.obj-type + {&delim-par} +
                           string( buf_userobjs_temp-user-obj.obj-code ) + {&delim-par} +
                           string(t-delete-ok) + {&delim-par} +
                           rs-list
                           )
                  , input v-auto-go /*p-auto-go*/
                  , input "&Стоп":U
                  , input substitute("Изменение скидок товаров на объекте &1&2 по списку товаров (баркодов)"
                                      , buf_userobjs_temp-user-obj.obj-type
                                      , buf_userobjs_temp-user-obj.obj-code
                                      )
              ) no-error .
              if error-status:error then do:
                   undo _main, return error .
              end.
          end . /*for each buf_userobjs_temp-user-obj*/
    end .

    /*Восстанавливаем список*/
    for each temp-disc exclusive-lock :
       delete temp-disc.
    end.
    for each buf_old-temp-disc no-lock :
       create buf_temp-disc.
       buffer-copy buf_old-temp-disc to buf_temp-disc.
  end.
    glog = br-del:refresh() in frame {&frame-name} no-error .
    glog = br-add:refresh() in frame {&frame-name} no-error .

  END. /*DO*/
end . /*if loc#log*/

assign
v-not-all-ok = (if rs-list = "gds-list" then can-find(first gds-list) else can-find(bb-list)) .

if v-not-all-ok and t-delete-ok then do:
  if rs-list = "gds-list" then do:
    assign
    b-list:label = "Неизменившиеся".
  end.
  else do:
    assign
    b-list-2:label = "Неизменившиеся".
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-check-rule1 Dialog-Frame
/*Привязываем правила скидки к объектам, если не привязаны.*/
PROCEDURE proc-check-rule1 :
  define variable v-parameter    as character no-undo.
  define variable t-dis-gds-rule as logical   no-undo init yes. /*копировать привязанные товары*/
  define variable v-cd-type      as character no-undo .
  define variable v-host-code    as integer   no-undo .
  define variable v-cli-host-code as integer   no-undo .
  define variable v-cli-obj-code  as integer   no-undo .
  define variable v-cli-obj-type  as character   no-undo .

  define buffer buf_temp-dis-rule for temp-dis-rule.
  define buffer buf_temp-clients  for temp-clients.
  define buffer buf_dis-rule      for ub.dis-rule.
  define buffer buf_clients       for ub.clients.
  define buffer buf_host-clients  for ub.clients.

  define buffer buf_temp-disc              for temp-disc .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  /*Почистим временные таблички*/
  for each temp-dis-rule:
      delete temp-dis-rule.
  end.
  for each temp-clients:
      delete temp-clients.
  end.
  /*Получим код фирмы тек объекта*/
  { gbl/hostcode.i parobj-type parobj-code v-host-code }
  /*Получим POS тек объекта и используем как базовый для всех остальных объектов*/
  { gbl/dflt-cd.i parobj-type parobj-code v-cd-type }

  /*Просматриваем правила*/
  _temp-disc:
  for each buf_temp-disc no-lock :
      /*Пропускаем список на удаление*/
      if not buf_temp-disc.action = yes then do:
          next _temp-disc .
      end.
      /*Просматриваем список объектов*/
      _temp-user-obj:
      for each buf_userobjs_temp-user-obj no-lock :
          /*Текущий объект пропускаем*/
          if buf_userobjs_temp-user-obj.obj-type = parobj-type
            and buf_userobjs_temp-user-obj.obj-code = parobj-code then do:
                next _temp-user-obj.
          end.
          /*Получим код фирмы объекта*/
          { gbl/hostcode.i buf_userobjs_temp-user-obj.obj-type buf_userobjs_temp-user-obj.obj-code v-cli-host-code }
          /*Надо положить данные по объекту и правилу во временные таблички
            temp-clients - список объектов/фирм
            temp-dis-rule - список оригинальных правил для копировани*/

          /*есть ли правило во временной табличке*/
          find first buf_temp-dis-rule no-lock
          where buf_temp-dis-rule.rule-num = buf_temp-disc.rule-num no-error.
          /*если нет то ищем в списке правил*/
          if not avail buf_temp-dis-rule then do:
                  find first buf_dis-rule no-lock
              where buf_dis-rule.rule-num = buf_temp-disc.rule-num no-error.
              /*если правило не глобальное и ( не фирменное или клиент не принадлежит текущей фирме ) то копируем*/
              if avail buf_dis-rule and
                 not buf_dis-rule.host-code = 0 and
                 ( not buf_dis-rule.obj-code = 0 or not buf_dis-rule.host-code = v-cli-host-code )
              then do:
              create buf_temp-dis-rule.
              buffer-copy buf_dis-rule to buf_temp-dis-rule.
          end.
              else do: /*нам не нужно это правило*/
                  next _temp-disc.
              end.
          end.
          /*если правило не глобальное и не фирменное, то ищем объект*/
          if not buf_temp-dis-rule.host-code = 0 and not buf_temp-dis-rule.obj-code = 0 then do:
              assign
                v-cli-obj-type = buf_userobjs_temp-user-obj.obj-type
                v-cli-obj-code = buf_userobjs_temp-user-obj.obj-code
              .
          end.
          else if not buf_temp-dis-rule.host-code = v-cli-host-code and not buf_temp-dis-rule.host-code = 0 then do:
              /*если клиент не принадлежит текущей фирме, то ищем фирму*/
              assign
                v-cli-obj-type = {&cmp}
                v-cli-obj-code = v-cli-host-code
              .
          end.
          /*есть ли объект во временной табличке*/
          find first buf_temp-clients no-lock
          where buf_temp-clients.obj-type = v-cli-obj-type
            and buf_temp-clients.obj-code = v-cli-obj-code no-error.
          /*если нет то ищем в списке объектов*/
          if not avail buf_temp-clients then do:
              find first buf_clients no-lock
              where buf_clients.obj-type = v-cli-obj-type
                and buf_clients.obj-code = v-cli-obj-code no-error.
              if avail buf_clients then do:
                  create buf_temp-clients.
                  buffer-copy buf_clients to buf_temp-clients.
              end.
          end.

      end. /*for each buf_userobjs_temp-user-obj*/
  end. /*for each buf_temp-disc*/

  FIND FIRST buf_temp-dis-rule NO-ERROR.
  IF NOT AVAILABLE buf_temp-dis-rule THEN DO:
     RETURN.
  END.
  FIND FIRST buf_temp-clients NO-ERROR.
  IF NOT AVAILABLE buf_temp-clients THEN DO:
     RETURN.
  END.

  /*Ну собственно копир правила*/
  ASSIGN
  v-parameter = STRING(t-dis-gds-rule) + {&delim-par} + v-cd-type
  .
  run str/diallog.w ( input parparentproc
            , input this-procedure
            , input ('proc-copy':U + {&delim-par} +
                     "1" + {&delim-par} +
                     "0" + {&delim-par} +
                     "1" + {&delim-par} +
                     "1" + {&delim-par} +
                     "yes")
            , input v-parameter
            , input v-auto-go /*p-auto-go*/
            , input 'Прервать'
            , input 'Копирование скидок') no-error .

  if error-status:error then do:
      return error .
  end .

END PROCEDURE .
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-obj Dialog-Frame
PROCEDURE proc-b-obj :
define variable v-user-select as logical   no-undo .
define variable v-obj-type    as character no-undo .
define variable v-obj-code    as integer   no-undo .
define variable v-host-code as integer   no-undo .

define buffer buf_clients-obj for ub.clients.
define buffer buf_temp-disc for temp-disc.

{ gbl/hostcode.i
  parobj-type
  parobj-code
  v-host-code
}

/*Получаем список объектов*/
{ gbl/uobjsman.i
  parparentproc
  v-cntxt-db-num
  v-cntxt-userid
  v-host-code
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

/*
RUN proc-title IN THIS-PROCEDURE.
*/

{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-title Dialog-Frame
PROCEDURE proc-title :
IF parobj-type = {&shop} THEN DO:
  { gbl/dflt-cd.i parobj-type parobj-code dflt-cd }
END.
if parobj-type = {&stock} then do:
  dflt-cd = {&cd-type-no-cd}.
end.
ASSIGN
MENU-ITEM m_pos-type:LABEL IN MENU menu-b-add  = dflt-cd
MENU-ITEM m_pos-type:sensitive IN MENU menu-b-add  = ((dflt-cd <> '':U) and (dflt-cd <> {&cd-type-no-cd}))
MENU-ITEM m_pos-type-2:LABEL IN MENU menu-b-add-2  = dflt-cd
MENU-ITEM m_pos-type-2:sensitive IN MENU menu-b-add-2  = ((dflt-cd <> '':U) and (dflt-cd <> {&cd-type-no-cd}))
.

CASE par-subject:
  WHEN {&table_dis-gds-rule} THEN DO:
    frame {&frame-name}:title = substitute("Изменение скидок на товар (бар-код), действующих на объекте &1&2 по списку товаров"
                                          ,parobj-type
                                          ,parobj-code) .
    assign
    /*v-tab-order = "b-exit,b-quit,rs-list,b-list,b-list-2,b-help,rs-obj-type,f-obj-code,b-obj,T-delete-ok,b-add,b-add-2".*/
    v-tab-order = "b-exit,b-quit,rs-list,b-list,b-list-2,b-help,rs-obj-type,b-obj,T-delete-ok,b-add,b-add-2" .
  END.
END CASE.
APPLY "ENTRY" TO b-add IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-write Dialog-Frame
PROCEDURE proc-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-region Dialog-Frame
PROCEDURE set-region :
DEFINE PARAMETER BUFFER buf_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE OUTPUT PARAMETER v-host-code AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER v-obj-type AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER v-obj-code AS integer NO-UNDO.
define variable v-sel-vals as character no-undo .
define variable v-sel-labels as character no-undo .
define variable var-region as character no-undo .

  if (buf_dis-cfg-rule.has-global +
      buf_dis-cfg-rule.has-host +
      buf_dis-cfg-rule.has-obj) > 1 then do:
    /*надо выбрать todo*/
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
    v-obj-type = substring(var-region, 1, 3)
    v-obj-code = integer(substring(var-region, 4))
    /*нам надо переконверитить из "   0" (глобально)  или "орг1" или "маг20" переконвертить к виду
    0 "" 0
    1 "" 0
    1 "маг" 20
    */
    v-host-code = (IF v-obj-type = "" THEN 0 ELSE v-obj-code)
    v-obj-code = (IF v-obj-type = {&shop}
                   OR v-obj-type = {&stock}
                   THEN parobj-code
                   ELSE 0)

    v-obj-type = (IF v-obj-type = {&shop}
                   OR v-obj-type = {&stock}
                   THEN parobj-type
                   ELSE '':U)
    .
  end.
  else do:
    if buf_dis-cfg-rule.has-obj = 1 then do:
      assign
      v-obj-type = parobj-type
      v-obj-code = parobj-code
      .
      { gbl/hostcode.i parobj-type parobj-code v-host-code }
    end.
    if buf_dis-cfg-rule.has-host = 1 then do:
      { gbl/hostcode.i parobj-type parobj-code v-host-code }
      assign
      v-obj-type = "":U
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


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION dis-gds-rule-name Dialog-Frame
FUNCTION dis-gds-rule-name RETURNS CHARACTER
  ( INPUT p-discnt-role AS character ) :
DEFINE variable v-dis-gds-rule-name AS CHARACTER NO-UNDO.
&SCOPED-DEFINE dis-gds-rule-code p-discnt-role
v-dis-gds-rule-name = {&dis-gds-rule-name}.
RETURN v-dis-gds-rule-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy Dialog-Frame
PROCEDURE proc-copy :
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.


DEFINE VARIABLE V-DIS-GDS-RULE   AS LOGICAL   NO-UNDO.
define variable v-cd-type        as character no-undo .
define variable LOG-FILE-NAME    as character no-undo .
define variable v-dr-ii          as integer   no-undo .
define variable v-dr-ii-ok       as integer   no-undo .
define variable v-dgr-ii         as integer   no-undo .
define variable v-dgr-ii-ok      as integer   no-undo .
define variable v-loc-dgr-ii     as integer   no-undo .
define variable v-loc-dgr-ii-ok  as integer   no-undo .
define variable v-rule-num-count as integer   no-undo .
define variable v-rule-num       as integer   no-undo .
define variable v-upper-rule-num as integer   no-undo .
define variable v-err-cnt        as integer   no-undo init 0 .

define variable v-recid as recid     no-undo .
define variable glog    as logical   no-undo .
define variable dflt-cd as character no-undo .

define variable v-add-upd as logical no-undo .
define variable v-do-it   as logical no-undo init yes .

define buffer buf_temp-dis-rule for temp-dis-rule .
define buffer buf_temp-clients  for temp-clients .
define buffer term_dis-rule     for ub.dis-rule .
define buffer trg_dis-rule      for ub.dis-rule .
define buffer src_dis-rule      for ub.dis-rule .
define buffer src_dis-gds-rule  for ub.dis-gds-rule .
define buffer buf_dis-cfg-rule  for ub.dis-cfg-rule .
define buffer buf_dis-rule      for ub.dis-rule .
define buffer buf_tt0           for tt0-term_dis-rule .

define buffer src_dis-gds-rule-attr for ub.dis-gds-rule-attr .
define buffer trg_dis-gds-rule-attr for ub.dis-gds-rule-attr .

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-message-laud  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

if num-entries(p-parameter, {&delim-par}) <> 2
then do:
  MESSAGE substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 2"
                             , num-entries(p-parameter, {&delim-par}))
  VIEW-AS ALERT-BOX ERROR
  .
  RETURN error.
end.
ASSIGN
V-DIS-GDS-RULE = LOGICAL(ENTRY(1, P-PARAMETER, {&delim-par} ))
v-cd-type = entry(2, p-parameter, {&delim-par} )
.
LOG-file-name = substitute("&1.txt", entry(1, this-procedure:file-name, ".")).
log-file-name = entry( num-entries(log-file-name, {&slash-char}), log-file-name, {&slash-char}).

for each tt0-term_dis-rule:
  delete tt0-term_dis-rule.
end.
for each tt-dis-rule:
  delete tt-dis-rule.
end.

create tt0-term_dis-rule.
_temp-dis-rule:
for each buf_temp-dis-rule:
  if buf_temp-dis-rule.sts <> integer({&used-status-int}) then do:
     &scop used-status-code string(buf_temp-dis-rule.sts)
     &scop my-message  substitute("Нельзя копировать правило в статусе &1", ~{&used-status-int-name~})
     {&display-message}.
     assign
       v-dr-ii = v-dr-ii + 1
       v-err-cnt = v-err-cnt + 1 .
  end.
  /*
  if buf_temp-dis-rule.obj-type = ''
  or not (buf_temp-dis-rule.obj-type = {&shop}
          or
          buf_temp-dis-rule.obj-type = {&stock}) then do:
     &scop my-message  substitute("Нельзя копировать правило, которое действует &1" ~
                               , get-region( buf_temp-dis-rule.host-code,  buf_temp-dis-rule.obj-type, buf_temp-dis-rule.obj-code))
     {&display-message}.
     assign
       v-dr-ii = v-dr-ii + 1
       v-err-cnt = v-err-cnt + 1 .
   end.
  */
  run disrules-fill-properties in this-procedure ( input buf_temp-dis-rule.templ-rl-root).
  FIND FIRST buf_dis-cfg-rule NO-LOCK where
            buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
        and buf_dis-cfg-rule.templ-rl-root = buf_temp-dis-rule.templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = buf_temp-dis-rule.time-templ-rl-root
        and buf_dis-cfg-rule.pos-type = v-cd-type
        no-error
         .
  _temp-clients:
  for each buf_temp-clients :
    if not (v-cd-type = {&cd-type-bo} or v-cd-type = {&cd-type-no-cd}) and
       not buf_temp-clients.obj-type = {&cmp}
    then do:
      if buf_temp-clients.obj-type = {&stock} then do:
        &scop my-message substitute("Нельзя скопировать правила скидки на объект &1&2"  ~
                                    , buf_temp-clients.obj-type ~
                                    , buf_temp-clients.obj-code ~
                                    )
        {&display-message}.
        assign
          v-dr-ii = v-dr-ii + 1
          v-err-cnt = v-err-cnt + 1 .
        next _temp-clients.
      end.
      dflt-cd = ''.
      { gbl/dflt-cd.i buf_temp-clients.obj-type buf_temp-clients.obj-code dflt-cd }
      if dflt-cd <> v-cd-type then do:
        &scop my-message substitute("Нельзя скопировать правила скидки на объект &1&2&3" + ~
                                    "На нем работает POS типа &4" ~
                                    , buf_temp-clients.obj-type ~
                                    , buf_temp-clients.obj-code ~
                                    , ~{&new-line~} ~
                                    , dflt-cd)
        {&display-message}.
        assign
          v-dr-ii = v-dr-ii + 1
          v-err-cnt = v-err-cnt + 1 .
        next _temp-clients.
      end.
    end.
    for each tt-dis-rule:
      delete tt-dis-rule.
    end.

    create tt-dis-rule.
    assign
    tt-dis-rule.des = buf_temp-dis-rule.des
    tt-dis-rule.host-code          = ( if buf_temp-clients.host-code = ? then buf_temp-clients.obj-code  else buf_temp-clients.host-code ) /*buf_temp-dis-rule.host-code*/
    tt-dis-rule.obj-type           = ( if buf_temp-clients.host-code = ? then buf_temp-dis-rule.obj-type else buf_temp-clients.obj-type )
    tt-dis-rule.obj-code           = ( if buf_temp-clients.host-code = ? then buf_temp-dis-rule.obj-code else buf_temp-clients.obj-code )
    tt-dis-rule.discnt-type        = buf_temp-dis-rule.discnt-type
    tt-dis-rule.discnt-value       = buf_temp-dis-rule.discnt-value
    tt-dis-rule.time-rule-num      = buf_temp-dis-rule.time-rule-num
    tt-dis-rule.time-templ-rl-root = buf_temp-dis-rule.time-templ-rl-root
    tt-dis-rule.tot-sum            = buf_temp-dis-rule.tot-sum
    tt-dis-rule.sts                = buf_temp-dis-rule.sts
    tt-dis-rule.doc-qnty           = buf_temp-dis-rule.doc-qnty
    .
    /*Здесь ищем тип правила привязанного к указанному объекту*/
    /*run gbl\inidebug.p.
    find first buf_dis-rule no-lock where
              /*buf_dis-rule.des = tt-dis-rule.des*/
              buf_dis-rule.discnt-type        = tt-dis-rule.discnt-type
          and buf_dis-rule.discnt-value       = tt-dis-rule.discnt-value
          and buf_dis-rule.time-rule-num      = tt-dis-rule.time-rule-num
          and buf_dis-rule.time-templ-rl-root = tt-dis-rule.time-templ-rl-root
          and buf_dis-rule.tot-sum            = tt-dis-rule.tot-sum
          and buf_dis-rule.sts                = tt-dis-rule.sts
          and buf_dis-rule.doc-qnty           = tt-dis-rule.doc-qnty

          and buf_dis-rule.host-code = tt-dis-rule.host-code
          and buf_dis-rule.obj-type = tt-dis-rule.obj-type
          and buf_dis-rule.obj-code = tt-dis-rule.obj-code
          and buf_dis-rule.templ-rl-root = buf_temp-dis-rule.templ-rl-root
          and buf_dis-rule.root = yes no-error.
    if available buf_dis-rule then do:
      /*message
      substitute("Найдено правило скидки &1&2 на &3&4 c типом &5&2" +
                 "все равно копировать??"
                 , buf_dis-rule.des
                 , {&new-line}
                 , buf_dis-rule.obj-type
                 , buf_dis-rule.obj-code
                 , buf_dis-rule.templ-rl-root)
      view-as alert-box question buttons yes-no update glog.
      if not glog then next _temp-clients.*/
      assign
        v-add-upd = false
        v-upper-rule-num = buf_dis-rule.rule-num
        v-recid = recid(buf_dis-rule)
      .
    end.
    else do:
      v-add-upd = true .
    end.*/
    v-add-upd = true .
    buffer-copy buf_temp-dis-rule
    except des
    host-code
    obj-type
    obj-code
    to tt-dis-rule .
    for each tt0-term_dis-rule:
        delete tt0-term_dis-rule .
    end.
    v-rule-num-count = 0 .
    /*Тут список конкретных правил для данного объекта*/
    for each term_dis-rule no-lock
    where term_dis-rule.upper-rule-num = buf_temp-dis-rule.rule-num :
        v-rule-num-count = v-rule-num-count + 1.
        create tt0-term_dis-rule.
        buffer-copy term_dis-rule
        except host-code obj-type obj-code
        rule-num upper-rule-num rl-root
        to tt0-term_dis-rule
        assign
        tt0-term_dis-rule.host-code      = buf_temp-clients.host-code
        tt0-term_dis-rule.obj-type       = buf_temp-clients.obj-type
        tt0-term_dis-rule.obj-code       = buf_temp-clients.obj-code
        tt0-term_dis-rule.rule-num       = v-rule-num-count
        tt0-term_dis-rule.upper-rule-num = (if v-add-upd then buf_temp-dis-rule.templ-rl-root else v-upper-rule-num)
        tt0-term_dis-rule.rl-root        = buf_temp-dis-rule.templ-rl-root
        .
        release tt0-term_dis-rule.
    end.
    if not v-add-upd then do:
      find first tt0-term_dis-rule no-lock no-error .
      find first buf_dis-rule no-lock where
              buf_dis-rule.host-code      = tt0-term_dis-rule.host-code
          and buf_dis-rule.obj-type       = tt0-term_dis-rule.obj-type
          and buf_dis-rule.obj-code       = tt0-term_dis-rule.obj-code
          and buf_dis-rule.templ-rl-root  = tt0-term_dis-rule.templ-rl-root
          and buf_dis-rule.root           = false
          and buf_dis-rule.upper-rule-num = tt0-term_dis-rule.upper-rule-num
      no-error.
      if avail buf_dis-rule then do:
          assign
            tt0-term_dis-rule.rule-num = buf_dis-rule.rule-num
          .
      end.

      else do:
         /*если не найдено, то надо сделать буфферкопи из tt0, расчитать и присвоить rule-num*/
         run gen-b-code in this-procedure ( input {&gbl-dr-code}, output v-rule-num) no-error .
         if error-status:error then do:
              &scop my-message substitute("Не удалось скопировать правило скидки &1 (gen-b-code) на &2&3&4&5&4&6" ~
                                            , buf_temp-dis-rule.rule-num ~
                                            , buf_temp-clients.obj-type ~
                                            , buf_temp-clients.obj-code  ~
                                            , ~{&new-line~} ~
                                            , error-status:get-message(1)  ~
                                            , return-value )
              {&display-message}.
              assign
                v-dr-ii = v-dr-ii + 1
                v-err-cnt = v-err-cnt + 1 .
              next _temp-clients.
         end.
         find first buf_tt0 no-lock no-error.
         if avail buf_tt0 then do:
             create buf_dis-rule.
             buffer-copy buf_tt0
             except rule-num
             to buf_dis-rule
             assign
             buf_dis-rule.rule-num = v-rule-num
             buf_tt0.rule-num = v-rule-num
             .
         end.
         else do:
            /*Правило нашли, но подправил нет, значит не копируем, а сразу привязываем товар.*/
            v-do-it = false .
            /*return error.*/
         end.
      end.

    end.
    /*номер правила для временнЫх скидок*/
    find first buf_tt0 no-lock no-error.
    if avail buf_tt0 and buf_tt0.time-templ-rl-root > 0 then do:
      assign
        tt-dis-rule.time-rule-num = buf_tt0.time-rule-num
      .
    end.

    v-dr-ii = v-dr-ii + 1.

    if v-do-it then do:
        run ref/dis-rul1.p (
        input (if v-add-upd then ? else v-upper-rule-num)
        ,input v-cd-type
        ,input buf_temp-dis-rule.templ-rl-root
        ,input buf_temp-dis-rule.templ-rl-root
        ,input buf_temp-dis-rule.des
        ,input tt-dis-rule.dis-kat
        ,input tt-dis-rule.discnt-type
        ,input tt-dis-rule.doc-qnty
        ,input tt-dis-rule.tot-sum
        ,input tt-dis-rule.charkey_one
        ,input tt-dis-rule.charkey_two
        ,input tt-dis-rule.charkey_three
        ,input tt-dis-rule.deckey_one
        ,input tt-dis-rule.deckey_two
        ,input tt-dis-rule.deckey_three
        ,input tt-dis-rule.key#_one
        ,input tt-dis-rule.key#_two
        ,input tt-dis-rule.key#_three
        ,input tt-dis-rule.subject-type
        ,input tt-dis-rule.time-templ-rl-root
        ,input (if tt-dis-rule.time-templ-rl-root = 0 then 0 else tt-dis-rule.time-rule-num)
        ,input tt-dis-rule.upper-rule-num
        ,input tt-dis-rule.value-type
        ,input tt-dis-rule.host-code
        ,INPUT tt-dis-rule.obj-type
        ,INPUT tt-dis-rule.obj-code
        ,INPUT tt-dis-rule.discnt-value
        ,input table tt0-term_dis-rule
        ,input-output v-recid
        ,input (if v-add-upd then {&add-def} else {&update})
        ,input yes /*p-silent */
        ) NO-ERROR.
        if error-status:error then do:
          &scop my-message substitute("Не удалось скопировать правило скидки &1 на &2&3&4&5&4&6" ~
                                        , buf_temp-dis-rule.rule-num ~
                                        , buf_temp-clients.obj-type ~
                                        , buf_temp-clients.obj-code  ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1)  ~
                                        , return-value )
          {&display-message}.
          assign
            v-dr-ii = v-dr-ii + 1
            v-err-cnt = v-err-cnt + 1
          .
          next _temp-clients.
        end.
    end.

    assign
      v-do-it = true
      v-dr-ii-ok = v-dr-ii-ok + 1
    .
    if v-dis-gds-rule then do:
        assign
          v-loc-dgr-ii = 0
          v-loc-dgr-ii-ok = 0
        .
        find first trg_dis-rule no-lock
        where recid(trg_dis-rule) = v-recid no-error.
        if available buf_dis-cfg-rule then do:
            for each src_dis-gds-rule no-lock
            where src_dis-gds-rule.obj-type = ( if buf_temp-clients.host-code = ? then {&cmp}                      else buf_temp-dis-rule.obj-type )
              and src_dis-gds-rule.obj-code = ( if buf_temp-clients.host-code = ? then buf_temp-dis-rule.host-code else buf_temp-dis-rule.obj-code )
              and src_dis-gds-rule.rule-num = buf_temp-dis-rule.rule-num
              and src_dis-gds-rule.pos-type = v-cd-type :
                assign
                  v-dgr-ii = v-dgr-ii + 1
                  v-loc-dgr-ii = v-loc-dgr-ii + 1
                .
                /*для фирменных правил*/
                if buf_temp-clients.host-code = ? then do:
                    run cmp-disgdsru-write in this-procedure (
                                                         input src_dis-gds-rule.gds-code
                                                        ,input {&cmp}
                                                        ,input trg_dis-rule.host-code
                                                        ,input v-cd-type
                                                        ,input trg_dis-rule.templ-rl-root
                                                        ,input src_dis-gds-rule.time-templ-rl-root
                                                        ,input buf_dis-cfg-rule.discnt-role
                                                        ,input trg_dis-rule.rule-num
                                                        ,input src_dis-gds-rule.nonunique
                                                       )  no-error.
                end.
                else do: /*для объектов*/
                run disgdsru-write in this-procedure ( input buf_temp-clients.obj-type
                                                      ,input buf_temp-clients.obj-code
                                                      ,input src_dis-gds-rule.gds-code
                                                      ,input v-cd-type
                                                      ,input buf_dis-cfg-rule.discnt-role
                                                      ,input trg_dis-rule.templ-rl-root
                                                      ,input src_dis-gds-rule.time-templ-rl-root /*,input trg_dis-rule.time-templ-rl-root*/
                                                      ,input trg_dis-rule.rule-num
                                                      ,input src_dis-gds-rule.nonunique          /*,input buf_dis-cfg-rule.nonunique*/
                )  no-error.
                end.
                if error-status :error then do:
                    &scop my-message substitute("Не удалось привязать правило скидки &1 к товару с кодом &2 на &3&4&5&6&5&7" ~
                        , trg_dis-rule.rule-num ~
                        , src_dis-gds-rule.gds-code ~
                        , buf_temp-clients.obj-type ~
                        , buf_temp-clients.obj-code  ~
                        , ~{&new-line~} ~
                        , error-status:get-message(1)  ~
                        , return-value )

                    {&display-message} .
                    assign
                      v-dr-ii = v-dr-ii + 1
                      v-err-cnt = v-err-cnt + 1
                    .
                end.
                else do:
                    /*Для бонусов*/
                    if buf_dis-cfg-rule.discnt-role = 'bonus-qnty' and
                       buf_dis-cfg-rule.nonunique   = 'bar-code.b-code'
                    then do:
                        for each src_dis-gds-rule-attr no-lock
                        where src_dis-gds-rule-attr.gds-code    = src_dis-gds-rule.gds-code
                          and src_dis-gds-rule-attr.obj-type    = src_dis-gds-rule.obj-type       /*parobj-type*/
                          and src_dis-gds-rule-attr.obj-code    = src_dis-gds-rule.obj-code       /*parobj-code*/
                          and src_dis-gds-rule-attr.pos-type    = v-cd-type
                          and src_dis-gds-rule-attr.discnt-role = buf_dis-cfg-rule.discnt-role
                          and src_dis-gds-rule-attr.nonunique   = src_dis-gds-rule.nonunique
                        :
                            find first trg_dis-gds-rule-attr exclusive-lock
                            where trg_dis-gds-rule-attr.gds-code    = src_dis-gds-rule.gds-code
                              and trg_dis-gds-rule-attr.obj-type    = ( if buf_temp-clients.host-code = ? then {&cmp}                 else buf_temp-clients.obj-type )
                              and trg_dis-gds-rule-attr.obj-code    = ( if buf_temp-clients.host-code = ? then trg_dis-rule.host-code else buf_temp-clients.obj-code )
                              and trg_dis-gds-rule-attr.pos-type    = v-cd-type
                              and trg_dis-gds-rule-attr.discnt-role = buf_dis-cfg-rule.discnt-role
                              and trg_dis-gds-rule-attr.nonunique   = src_dis-gds-rule.nonunique
                              and trg_dis-gds-rule-attr.attr-value  = src_dis-gds-rule-attr.attr-value
                            no-error.
                            if not avail trg_dis-gds-rule-attr then do:
                                create trg_dis-gds-rule-attr .
                                buffer-copy src_dis-gds-rule-attr
                                except obj-type obj-code
                                to trg_dis-gds-rule-attr
                                assign
                                  trg_dis-gds-rule-attr.obj-type = ( if buf_temp-clients.host-code = ? then {&cmp}                 else buf_temp-clients.obj-type )
                                  trg_dis-gds-rule-attr.obj-code = ( if buf_temp-clients.host-code = ? then trg_dis-rule.host-code else buf_temp-clients.obj-code )
                                .
                            end.
                        end. /*for each src_dis-gds-rule-attr*/
                    end.
                    assign
                      v-dgr-ii-ok = v-dgr-ii-ok + 1
                      v-loc-dgr-ii-ok = v-loc-dgr-ii-ok + 1
                    .
                end.
            end. /*for each src_dis-gds-rule no-lock where*/
        end.
    end. /*if v-dis-gds-rule then do:*/

    if v-dis-gds-rule then do:
      &scop my-count-message substitute("Пр. скидок: OK &1 из &2, привязки: OK &3 из &4", v-dr-ii-ok, v-dr-ii, v-dgr-ii-ok, v-dgr-ii)
      {&display-count-message} .
    end.
    else do:
      &scop my-count-message substitute("Пр. скидок: OK &1 из &2", v-dr-ii-ok, v-dr-ii)
      {&display-count-message} .
    end.
  end. /*for each buf_temp-clients where*/
  if v-dis-gds-rule  then do:
    &scop my-message substitute("привязки Правила &1: OK &2 из &3", buf_temp-dis-rule.rule-num, v-loc-dgr-ii, v-loc-dgr-ii-ok)
    {&display-message}.
  end.
  end. /*for each buf_temp-dis-rule:*/
if v-dis-gds-rule then do:
  &scop my-message substitute("Пр. скидок: OK &1 из &2, привязки: OK &3 из &4", v-dr-ii-ok, v-dr-ii, v-dgr-ii-ok, v-dgr-ii)
  {&display-message}.
end.
else do:
  &scop my-message substitute("Пр. скидок: OK &1 из &2", v-dr-ii-ok, v-dr-ii)
  {&display-message}.
end.
&scop my-message substitute("Копирование закончено")
{&display-message}.
{&display-count-message}.

/*Если в процессе были ошибки, то возвращаем ошибку, чтобы просмотрели лог файл.*/
if v-err-cnt > 0 then do:
    return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME