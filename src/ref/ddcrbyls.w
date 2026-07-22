&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients-obj FOR ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Механизм простановки скидок на различные сущности - dis-dc-rule

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
define input parameter p-host-code like ub.clients.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo.
/*текущий объект*/
define input parameter p-obj-code like ub.clients.obj-code no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Скидки по отдельной ДК." .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/dc-list.i dc-list def "new shared" }
{ cmp/bitoper.i }
{ ref/temp-dsc.i "NEW SHARED" ~{&table_dis-dc-rule~} p-obj-type p-obj-code }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/get-regf.i }
{ ref/disdcrul.i interface parparentproc temp-disc }
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
&Scoped-define FIELDS-IN-QUERY-BR-add {&cd-type-name} dis-dc-rule-name (temp-disc.discnt-role) temp-disc.templ-rl-root disdcrul-get-disc-label( INPUT temp-disc.templ-rl-root) temp-disc.rule-num get-region(temp-disc.host-code, temp-disc.obj-type, temp-disc.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-add
&Scoped-define SELF-NAME BR-add
&Scoped-define QUERY-STRING-BR-add FOR EACH temp-disc where temp-disc.action = yes NO-LOCK
&Scoped-define OPEN-QUERY-BR-add OPEN QUERY {&SELF-NAME} FOR EACH temp-disc where temp-disc.action = yes NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-add temp-disc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-add temp-disc


/* Definitions for BROWSE BR-del                                        */
&Scoped-define FIELDS-IN-QUERY-BR-del {&cd-type-name2} dis-dc-rule-name ( DEL_temp-disc.discnt-role) del_temp-disc.templ-rl-root disdcrul-get-disc-label( INPUT del_temp-disc.templ-rl-root) del_temp-disc.rule-num get-region(del_temp-disc.host-code, del_temp-disc.obj-type, del_temp-disc.obj-code)
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
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-list B-Help Rs-obj-type ~
f-obj-code B-obj T-delete-ok b-add B-chg B-del BR-add b-add-2 B-chg-2 ~
B-del-2 BR-del F-obj-name
&Scoped-Define DISPLAYED-OBJECTS Rs-obj-type f-obj-code T-delete-ok ~
F-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD dis-dc-rule-name Dialog-Frame
FUNCTION dis-dc-rule-name RETURNS CHARACTER
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
     LABEL "&Список"
     SIZE 10 BY 1 TOOLTIP "Создание списка".

DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE F-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 52.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Rs-obj-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 16.5 BY 1 NO-UNDO.

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
      {&cd-type-name} column-label "Место использ."  format "X(15)"
dis-dc-rule-name (temp-disc.discnt-role) column-label "Тип скидки" FORMAT "X(255)":U WIDTH 35
temp-disc.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
disdcrul-get-disc-label( INPUT temp-disc.templ-rl-root) FORMAT "X(255)":U WIDTH 45
temp-disc.rule-num COLUMN-LABEL "Код правила" FORMAT ">>>>>>>>9"
get-region(temp-disc.host-code, temp-disc.obj-type, temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут добавлены/изменены скидки".

DEFINE BROWSE BR-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-del Dialog-Frame _FREEFORM
  QUERY BR-del DISPLAY
      {&cd-type-name2} column-label "Место использ."  format "X(15)"
dis-dc-rule-name ( DEL_temp-disc.discnt-role) column-label "Тип скидки" FORMAT "X(255)":U WIDTH 35
del_temp-disc.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
disdcrul-get-disc-label( INPUT del_temp-disc.templ-rl-root) FORMAT "X(255)":U WIDTH 45
del_temp-disc.rule-num COLUMN-LABEL "Код правила" FORMAT ">>>>>>>>9"
get-region(del_temp-disc.host-code, del_temp-disc.obj-type, del_temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут удалены скидки".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-list AT ROW 1 COL 41
     B-Help AT ROW 1 COL 95
     Rs-obj-type AT ROW 2.25 COL 1 NO-LABEL
     f-obj-code AT ROW 2.25 COL 16 COLON-ALIGNED NO-LABEL
     B-obj AT ROW 2.25 COL 27
     T-delete-ok AT ROW 3.5 COL 1.5
     b-add AT ROW 4.75 COL 1
     B-chg AT ROW 4.75 COL 11
     B-del AT ROW 4.75 COL 21
     BR-add AT ROW 5.75 COL 1
     b-add-2 AT ROW 14 COL 1
     B-chg-2 AT ROW 14 COL 11 WIDGET-ID 2
     B-del-2 AT ROW 14 COL 21
     BR-del AT ROW 15 COL 1
     F-obj-name AT ROW 2.25 COL 30 COLON-ALIGNED NO-LABEL
     SPACE(14.50) SKIP(20.08)
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
  "из списка атрибутов, подлежащих удалению?" skip
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
ON CHOOSE OF B-list IN FRAME Dialog-Frame /* Список */
DO:
define variable v-host-code as integer no-undo .
  CASE par-subject:
    when {&table_dis-dc-rule}
    then do:
      { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
      run str/dc-list.w ( input parparentproc, input v-host-code, input p-obj-type, input p-obj-code).
    end.
  END CASE.
  assign
  b-list:width = 10
  b-list:label = "&Список"
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


&Scoped-define SELF-NAME f-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-obj-code Dialog-Frame
ON LEAVE OF f-obj-code IN FRAME Dialog-Frame
DO:
   { gbl/stdbtn.i }
  if   input frame {&frame-name} f-obj-code <> 0 then do:
    run check-obj in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.

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


&Scoped-define SELF-NAME Rs-obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-obj-type Dialog-Frame
ON VALUE-CHANGED OF Rs-obj-type IN FRAME Dialog-Frame
DO:
    assign
  RS-obj-type.
  if   input frame {&frame-name} f-obj-code <> 0 then do:
    run check-obj in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.

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
  if lookup(par-subject, {&table_dis-dc-rule}) = 0 then do:

    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра par-subject" par-subject
    view-as alert-box error.
    return error.
  end.
  CASE par-subject:
    when {&table_dis-dc-rule}
    then do:
       if v-cntxt-db-num = 0 then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_dc-discount_global_work':U
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
          'actn_dc-discount_firm_work':U
          {&cntxt-firm}
          p-host-code
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
        'actn_dc-discount_object_work':U
        {&cntxt-object}
        p-host-code
        p-obj-type
        p-obj-code
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
        "У Вас отсутствуют права на назначение скидки на ДК как по объекту, так и по фирме и глобально" skip
        "либо Вы находитесь в БД, в которой их назначить невозможно"
        view-as alert-box error .
        undo, return.
      end.
    END.
  END CASE.
  find first X_clients-obj no-lock where
              X_clients-obj.obj-type = p-obj-type AND
              X_clients-obj.obj-code = p-obj-code no-error .
  if not avail X_clients-obj then do:
    message vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-obj-type и/или p-obj-code" p-obj-type p-obj-code
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-obj Dialog-Frame
PROCEDURE check-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where
              buf_clients.obj-code = input frame {&frame-name} f-obj-code
         and buf_clients.obj-type = input frame {&frame-name} RS-obj-type no-error.
if not available buf_clients then do:
  if input frame {&frame-name} f-obj-code <> ?  then
    message "Неправильный код или тип объекта" .
  apply "entry" to f-obj-code in frame {&frame-name}.
  return error.
end.
find first X_clients-obj no-lock where recid(X_clients-obj) = recid(buf_clients).
assign
p-obj-type = buf_clients.obj-type
p-obj-code = buf_clients.obj-code
RS-obj-type = buf_clients.obj-type
f-obj-code = buf_clients.obj-code
f-obj-name = buf_clients.obj-name
.

display
RS-obj-type
f-obj-code
f-obj-name
with frame {&frame-name}.
RUN proc-title IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY Rs-obj-type f-obj-code T-delete-ok F-obj-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-list B-Help Rs-obj-type f-obj-code B-obj T-delete-ok
         b-add B-chg B-del BR-add b-add-2 B-chg-2 B-del-2 BR-del F-obj-name
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

ASSIGN
RS-obj-type:radio-buttons = "Маг" + {&comma-char} + {&shop} + {&comma-char} +
                                    "Скл" + {&comma-char} + {&stock}
RS-obj-type = p-obj-type
f-obj-code = p-obj-code
f-obj-name = X_clients-obj.obj-name
.

DISPLAY
RS-obj-type
f-obj-code
f-obj-name
WITH FRAME {&FRAME-NAME}.

RUN proc-title IN THIS-PROCEDURE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define input parameter p-pos-type as character no-undo.
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-rid-list as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-rec as recid no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_temp-disc for temp-disc.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
do
on error undo, return error :
  run ref/dis-pos.w ( INPUT parparentproc
                      ,INPUT "b-sel":U
                      ,INPUT "cd-type-list"
                      ,INPUT (if v-cntxt-db-num = 0 and loc-glob then 1 else 0)
                      ,INPUT (if v-cntxt-db-num = 0 and loc-firm then 1 else 0)
                      ,INPUT 1
                      ,input {&table_dis-dc-rule}
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
  run set-region in this-procedure ( buffer buf_dis-cfg-rule
                                   , output v-host-code
                                   , output v-obj-type
                                   , output v-obj-code
                                   ).
  run temp-dsc-write in this-procedure (
                                         input yes /*p-add*/
                                        ,input buf_dis-cfg-rule.pos-type
                                        ,input buf_dis-cfg-rule.templ-rl-root
                                        ,input buf_dis-cfg-rule.time-templ-rl-root
                                        ,input buf_dis-cfg-rule.discnt-role
                                        ,input buf_dis-cfg-rule.nonunique
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
  run proc-b-chg in this-procedure ( input "":U) no-error.
  if error-status:error then do:
      run temp-dsc-delete in this-procedure (
                                               input buf_dis-cfg-rule.pos-type
                                              ,input buf_dis-cfg-rule.discnt-role
                                              ,input buf_dis-cfg-rule.nonunique
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
define variable dflt-cd as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_temp-disc for temp-disc.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
CASE par-subject :
  WHEN {&table_dis-dc-rule} THEN DO:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "cd-type-list"
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT 1
                        ,input {&table_dis-dc-rule}
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
    run set-region in this-procedure ( buffer buf_dis-cfg-rule
                                    , OUTPUT v-host-code
                                    , output v-obj-type
                                    , output v-obj-code).
    run temp-dsc-write in this-procedure (
                                            input yes /*p-add*/
                                           ,input buf_dis-cfg-rule.pos-type
                                           ,input buf_dis-cfg-rule.templ-rl-root
                                           ,input buf_dis-cfg-rule.time-templ-rl-root
                                           ,input buf_dis-cfg-rule.discnt-role
                                           ,input buf_dis-cfg-rule.nonunique
                                           ,input v-host-code
                                           ,input v-obj-type
                                           ,input v-obj-code
                                           ,input v-rule-num /*rule-num*/
                                           ,input no
                                           ,input-output v-rec
                                               )  no-error.
     IF ERROR-STATUS:ERROR THEN DO:
      if return-value = "not-set" then do:
      end.
      else do:
        {&temp-dsc-type-get-error}
        return error.
      end.
    END.
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
                                            ,input buf_dis-cfg-rule.nonunique
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
                                      ,input {&add-def} /*p0mode*/
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
    RETURN error.
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
                                      ,input {&deletion} /*p-0-mode*/
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
    RETURN error.
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
define variable v-host-code as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_temp-disc for temp-disc.
if not can-find(first temp-disc) then do:
    message "Вы не определили список скидок для изменения (добавления, удаления)"
    view-as alert-box.
    return no-apply.
end.
ASSIGN
FRAME {&FRAME-NAME} t-delete-ok.
CASE par-subject:
  when {&table_dis-dc-rule} then do:
    if not can-find(first dc-list) then do:
      message "Вы не определили список ДК"
      view-as alert-box.
      return no-apply.
    end.
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    for each buf_temp-disc:
      if buf_temp-disc.action = yes then do:
        find first buf_dis-rule no-lock where
                  buf_Dis-rule.rule-num = buf_temp-disc.rule-num no-error.
        if not available buf_dis-rule
        or (buf_Dis-rule.obj-code > 0
        and not (

                buf_dis-rule.obj-type = p-obj-type
                and
                buf_dis-rule.obj-code = p-obj-code)
              )
        or (buf_Dis-rule.host-code > 0
        and not (
                buf_dis-rule.host-code = v-host-code)
              )

        or not (buf_dis-rule.sts = integer({&current-status-int})) then do:
  &scop dis-dc-rule-code buf_temp-disc.discnt-role
  &scop status-code {&current-status-int}
          if buf_dis-rule.obj-code > 0 then do:
            message
            substitute("&1 &2&3: значение кода правила скидки должно указывать&4" +
                        "на существующее правило в статусе &5 и принадлежащее &2&3"
                        ,{&dis-dc-rule-name}
                        ,p-obj-type
                        ,p-obj-code
                        ,{&new-line}
                        ,{&status-int-name}
                        )
            view-as alert-box error .
            undo, return error .
          end.
          else do:
            message
            substitute("&1 фирма &2: значение кода правила скидки должно указывать&3" +
                        "на существующее правило в статусе &4 и принадлежащее фирме &2"
                        ,{&dis-dc-rule-name}
                        ,v-host-code
                        ,{&new-line}
                        ,{&status-int-name}
                        )
            view-as alert-box error .
            undo, return error .

          end.
        end.
      end.
    end.

    message
    "Вы уверены, что Вы хотите провести изменение (добавление, удаление) скидок по отдельным ДК" SKIP
    "всего определенного Вами списка?"
    view-as alert-box QUESTION buttons YES-NO update loc#log.
    if loc#log then do:
      run str/diallog.w (
              input parparentproc
            , input this-procedure
            , input "ref/ddcr-lst.p":U
            , input (string(p-host-code) + {&delim-par} + p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + string(t-delete-ok))
            , input no /*p-auto-go*/
            , input "&Стоп":U
            , input substitute("Изменение скидок на отдельные ДК (фирма &1 объект &2&3) по списку ДК"
                                , p-host-code
                                , p-obj-type
                                , p-obj-code
                                )
        ) no-error.
      assign
      v-not-all-ok = can-find(first dc-list).
    end.
  end.
END CASE.
if v-not-all-ok and t-delete-ok then do:
  assign
  b-list:width = 30
  b-list:label = "Список неизменившихся".
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
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
  p-obj-type
  p-obj-code
  v-host-code
}

{ gbl/uobjsone.i
  parparentproc
  v-cntxt-db-num
  v-cntxt-userid
  v-host-code
  p-obj-type
  p-obj-code
  v-user-select
  v-obj-type
  v-obj-code
}
if v-user-select <> true
then do:
  message
  "Объект не выбран"
  view-as alert-box information .
  undo, return error return-value .
end.

find first buf_clients-obj no-lock
  where buf_clients-obj.obj-type = v-obj-type
    and buf_clients-obj.obj-code = v-obj-code
    no-error.
if not avail buf_clients-obj
then do:
  message
    "Не найден объект!" skip
    view-as alert-box error.
  return no-apply.
end.
find first X_clients-obj no-lock where recid(X_clients-obj) = recid(buf_clients-obj).
assign
p-obj-type =  X_clients-obj.obj-type
p-obj-code = X_clients-obj.obj-code
RS-obj-type = X_clients-obj.obj-type
f-obj-code = X_clients-obj.obj-code
f-obj-name  = X_clients-obj.obj-name
.
display
rs-obj-type
f-obj-code
f-obj-name
with frame {&frame-name}.
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
for each buf_temp-disc :
  if (buf_temp-disc.obj-type = {&shop}
  or buf_temp-disc.obj-type = {&stock} )
  and not (buf_temp-disc.obj-type = p-obj-type
           and
           buf_temp-disc.obj-code = p-obj-code)
  then do:
    delete buf_temp-disc.
    next.
  end.
  if buf_temp-disc.host-code <> v-host-code then delete buf_temp-disc.
end.
RUN proc-title IN THIS-PROCEDURE.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-title Dialog-Frame
PROCEDURE proc-title :
IF p-obj-type = {&shop} THEN DO:
  { gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
END.
if p-obj-type = {&stock} then do:
  dflt-cd = {&cd-type-no-cd}.
end.
ASSIGN
MENU-ITEM m_pos-type:LABEL IN MENU menu-b-add  = dflt-cd
MENU-ITEM m_pos-type:sensitive IN MENU menu-b-add  = ((dflt-cd <> '':U) and (dflt-cd <> {&cd-type-no-cd}))
MENU-ITEM m_pos-type-2:LABEL IN MENU menu-b-add-2  = dflt-cd
MENU-ITEM m_pos-type-2:sensitive IN MENU menu-b-add-2  = ((dflt-cd <> '':U) and (dflt-cd <> {&cd-type-no-cd}))
.

CASE par-subject:
  WHEN {&table_dis-dc-rule} THEN DO:
    frame {&frame-name}:title = substitute("Изменение скидок на отдельные ДК &1&2 по списку ДК"
                                          ,p-obj-type
                                          ,p-obj-code) .
    assign
    v-tab-order = "b-exit,b-quit,b-list,b-help,rs-obj-type,f-obj-code,b-obj,T-delete-ok,b-add,b-add-2".
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
                   THEN p-obj-code
                   ELSE 0)

    v-obj-type = (IF v-obj-type = {&shop}
                   OR v-obj-type = {&stock}
                   THEN p-obj-type
                   ELSE '':U)
    .
  end.
  else do:
    if buf_dis-cfg-rule.has-obj = 1 then do:
      assign
      v-obj-type = p-obj-type
      v-obj-code = p-obj-code
      .
      { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    end.
    if buf_dis-cfg-rule.has-host = 1 then do:
      { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION dis-dc-rule-name Dialog-Frame
FUNCTION dis-dc-rule-name RETURNS CHARACTER
  ( INPUT p-discnt-role AS character ) :
DEFINE variable v-dis-dc-rule-name AS CHARACTER NO-UNDO.
&SCOPED-DEFINE dis-dc-rule-code p-discnt-role
v-dis-dc-rule-name = {&dis-dc-rule-name}.
RETURN v-dis-dc-rule-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
